#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_net;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	init_blockers();
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "open_nearest_door", ::quantum_bomb_open_nearest_door_result, 35, ::quantum_bomb_open_nearest_door_validation );
	}
}

init_blockers()
{
	level.exterior_goals = getstructarray( "exterior_goal", "targetname" );
	array_thread( level.exterior_goals, ::blocker_init );
	zombie_doors = getentarray( "zombie_door", "targetname" );
	if ( isDefined( zombie_doors ) )
	{
		flag_init( "door_can_close" );
		array_thread( zombie_doors, ::door_init );
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	array_thread( zombie_debris, ::debris_init );
	flag_blockers = getentarray( "flag_blocker", "targetname" );
	array_thread( flag_blockers, ::flag_blocker );
}

door_init()
{
	self.type = undefined;
	self.purchaser = undefined;
	self._door_open = 0;
	targets = getentarray( self.target, "targetname" );
	while ( isDefined( self.script_flag ) && !isDefined( level.flag[ self.script_flag ] ) )
	{
		while ( isDefined( self.script_flag ) )
		{
			tokens = strtok( self.script_flag, "," );
			i = 0;
			while ( i < tokens.size )
			{
				flag_init( self.script_flag );
				i++;
			}
		}
	}
	if ( !isDefined( self.script_noteworthy ) )
	{
		self.script_noteworthy = "default";
	}
	self.doors = [];
	i = 0;
	while ( i < targets.size )
	{
		targets[ i ] door_classify( self );
		if ( !isDefined( targets[ i ].og_origin ) )
		{
			targets[ i ].og_origin = targets[ i ].origin;
			targets[ i ].og_angles = targets[ i ].angles;
		}
		i++;
	}
	cost = 1000;
	if ( isDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	self setcursorhint( "HINT_NOICON" );
	self thread door_think();
	if ( isDefined( self.script_noteworthy ) )
	{
		if ( self.script_noteworthy == "electric_door" || self.script_noteworthy == "electric_buyable_door" )
		{
			if ( getDvar( "ui_gametype" ) == "zgrief" )
			{
				self setinvisibletoall();
				return;
			}
			self sethintstring( &"ZOMBIE_NEED_POWER" );
			if ( isDefined( level.door_dialog_function ) )
			{
				self thread [[ level.door_dialog_function ]]();
			}
			return;
		}
		else
		{
			if ( self.script_noteworthy == "local_electric_door" )
			{
				if ( getDvar( "ui_gametype" ) == "zgrief" )
				{
					self setinvisibletoall();
					return;
				}
				self sethintstring( &"ZOMBIE_NEED_LOCAL_POWER" );
				if ( isDefined( level.door_dialog_function ) )
				{
					self thread [[ level.door_dialog_function ]]();
				}
				return;
			}
			else
			{
				if ( self.script_noteworthy == "kill_counter_door" )
				{
					self sethintstring( &"ZOMBIE_DOOR_ACTIVATE_COUNTER", cost );
					return;
				}
			}
		}
	}
	self set_hint_string( self, "default_buy_door_" + cost );
}

door_classify( parent_trig )
{
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "clip" )
	{
		parent_trig.clip = self;
		parent_trig.script_string = "clip";
		break;
}
else
{
	if ( !isDefined( self.script_string ) )
	{
		if ( isDefined( self.script_angles ) )
		{
			self.script_string = "rotate";
		}
		else
		{
			if ( isDefined( self.script_vector ) )
			{
				self.script_string = "move";
			}
		}
		break;
}
else if ( !isDefined( self.script_string ) )
{
	self.script_string = "";
}
switch( self.script_string )
{
	case "anim":
/#
		assert( isDefined( self.script_animname ), "Blocker_init: You must specify a script_animname for " + self.targetname );
#/
/#
		assert( isDefined( level.scr_anim[ self.script_animname ] ), "Blocker_init: You must define a level.scr_anim for script_anim -> " + self.script_animname );
#/
/#
		assert( isDefined( level.blocker_anim_func ), "Blocker_init: You must define a level.blocker_anim_func" );
#/
		break;
	case "counter_1s":
		parent_trig.counter_1s = self;
		return;
		case "counter_10s":
			parent_trig.counter_10s = self;
			return;
			case "counter_100s":
				parent_trig.counter_100s = self;
				return;
				case "explosives":
					if ( !isDefined( parent_trig.explosives ) )
					{
						parent_trig.explosives = [];
					}
					parent_trig.explosives[ parent_trig.explosives.size ] = self;
					return;
			}
		}
		if ( self.classname == "script_brushmodel" )
		{
			self disconnectpaths();
		}
		parent_trig.doors[ parent_trig.doors.size ] = self;
	}
}

door_buy()
{
	self waittill( "trigger", who, force );
	if ( getDvarInt( "zombie_unlock_all" ) > 0 || isDefined( force ) && force )
	{
		return 1;
	}
	if ( !who usebuttonpressed() )
	{
		return 0;
	}
	if ( who in_revive_trigger() )
	{
		return 0;
	}
	if ( is_player_valid( who ) )
	{
		players = get_players();
		if ( self._door_open == 1 )
		{
			self.purchaser = undefined;
		}
		else if ( who.score >= self.zombie_cost )
		{
			who maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
			maps/mp/_demo::bookmark( "zm_player_door", getTime(), who );
			who maps/mp/zombies/_zm_stats::increment_client_stat( "doors_purchased" );
			who maps/mp/zombies/_zm_stats::increment_player_stat( "doors_purchased" );
			self.purchaser = who;
		}
		else
		{
			play_sound_at_pos( "no_purchase", self.doors[ 0 ].origin );
			if ( isDefined( level.custom_generic_deny_vo_func ) )
			{
				who thread [[ level.custom_generic_deny_vo_func ]]( 1 );
			}
			else
			{
				who maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "door_deny" );
			}
			return 0;
		}
	}
	return 1;
}

door_delay()
{
	while ( isDefined( self.explosives ) )
	{
		i = 0;
		while ( i < self.explosives.size )
		{
			self.explosives[ i ] show();
			i++;
		}
	}
	if ( !isDefined( self.script_int ) )
	{
		self.script_int = 5;
	}
	all_trigs = getentarray( self.target, "target" );
	i = 0;
	while ( i < all_trigs.size )
	{
		all_trigs[ i ] trigger_off();
		i++;
	}
	wait self.script_int;
	i = 0;
	while ( i < self.script_int )
	{
/#
		iprintln( self.script_int - i );
#/
		wait 1;
		i++;
	}
	while ( isDefined( self.explosives ) )
	{
		i = 0;
		while ( i < self.explosives.size )
		{
			playfx( level._effect[ "def_explosion" ], self.explosives[ i ].origin, anglesToForward( self.explosives[ i ].angles ) );
			self.explosives[ i ] hide();
			i++;
		}
	}
}

door_activate( time, open, quick, use_blocker_clip_for_pathing )
{
	if ( !isDefined( open ) )
	{
		open = 1;
	}
	if ( !isDefined( time ) )
	{
		time = 1;
		if ( isDefined( self.script_transition_time ) )
		{
			time = self.script_transition_time;
		}
	}
	if ( isDefined( self.door_moving ) )
	{
		if ( isDefined( self.script_noteworthy ) || self.script_noteworthy == "clip" && isDefined( self.script_string ) && self.script_string == "clip" )
		{
			if ( !is_true( use_blocker_clip_for_pathing ) )
			{
				if ( !open )
				{
					return;
				}
			}
		}
		else
		{
			return;
		}
	}
	self.door_moving = 1;
	if ( open || isDefined( quick ) && !quick )
	{
		self notsolid();
	}
	if ( self.classname == "script_brushmodel" )
	{
		if ( open )
		{
			self connectpaths();
		}
	}
	if ( isDefined( self.script_noteworthy ) || self.script_noteworthy == "clip" && isDefined( self.script_string ) && self.script_string == "clip" )
	{
		if ( !open )
		{
			self delay_thread( time, ::self_disconnectpaths );
			wait 0,1;
			self solid();
		}
		return;
	}
	if ( isDefined( self.script_sound ) )
	{
		if ( open )
		{
			playsoundatposition( self.script_sound, self.origin );
		}
		else
		{
			playsoundatposition( self.script_sound + "_close", self.origin );
		}
	}
	else
	{
		play_sound_at_pos( "door_slide_open", self.origin );
	}
	scale = 1;
	if ( !open )
	{
		scale = -1;
	}
	switch( self.script_string )
	{
		case "rotate":
			if ( isDefined( self.script_angles ) )
			{
				rot_angle = self.script_angles;
				if ( !open )
				{
					rot_angle = self.og_angles;
				}
				self rotateto( rot_angle, time, 0, 0 );
				self thread door_solid_thread();
				if ( !open )
				{
					self thread disconnect_paths_when_done();
				}
			}
			wait randomfloat( 0,15 );
			break;
		case "move":
		case "slide_apart":
			if ( isDefined( self.script_vector ) )
			{
				vector = vectorScale( self.script_vector, scale );
				if ( time >= 0,5 )
				{
					self moveto( self.origin + vector, time, time * 0,25, time * 0,25 );
				}
				else
				{
					self moveto( self.origin + vector, time );
				}
				self thread door_solid_thread();
				if ( !open )
				{
					self thread disconnect_paths_when_done();
				}
			}
			wait randomfloat( 0,15 );
			break;
		case "anim":
			self [[ level.blocker_anim_func ]]( self.script_animname );
			self thread door_solid_thread_anim();
			wait randomfloat( 0,15 );
			break;
		case "physics":
			self thread physics_launch_door( self );
			wait 0,1;
			break;
	}
}

kill_trapped_zombies( trigger )
{
	zombies = getaiarray( level.zombie_team );
	if ( !isDefined( zombies ) )
	{
		return;
	}
	i = 0;
	while ( i < zombies.size )
	{
		if ( !isDefined( zombies[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( zombies[ i ] istouching( trigger ) )
		{
			zombies[ i ].marked_for_recycle = 1;
			zombies[ i ] dodamage( zombies[ i ].health + 666, trigger.origin, self );
			wait randomfloat( 0,15 );
			i++;
			continue;
		}
		else
		{
			if ( isDefined( level.custom_trapped_zombies ) )
			{
				zombies[ i ] thread [[ level.custom_trapped_zombies ]]();
				wait randomfloat( 0,15 );
			}
		}
		i++;
	}
}

any_player_touching( trigger )
{
	_a530 = get_players();
	_k530 = getFirstArrayKey( _a530 );
	while ( isDefined( _k530 ) )
	{
		player = _a530[ _k530 ];
		if ( player istouching( trigger ) )
		{
			return 1;
		}
		wait 0,01;
		_k530 = getNextArrayKey( _a530, _k530 );
	}
	return 0;
}

any_player_touching_any( trigger, more_triggers )
{
	_a541 = get_players();
	_k541 = getFirstArrayKey( _a541 );
	while ( isDefined( _k541 ) )
	{
		player = _a541[ _k541 ];
		while ( is_player_valid( player, 0, 1 ) )
		{
			if ( isDefined( trigger ) && player istouching( trigger ) )
			{
				return 1;
			}
			while ( isDefined( more_triggers ) && more_triggers.size > 0 )
			{
				_a548 = more_triggers;
				_k548 = getFirstArrayKey( _a548 );
				while ( isDefined( _k548 ) )
				{
					trig = _a548[ _k548 ];
					if ( isDefined( trig ) && player istouching( trig ) )
					{
						return 1;
					}
					_k548 = getNextArrayKey( _a548, _k548 );
				}
			}
		}
		_k541 = getNextArrayKey( _a541, _k541 );
	}
	return 0;
}

any_zombie_touching_any( trigger, more_triggers )
{
	zombies = getaiarray( level.zombie_team );
	_a560 = zombies;
	_k560 = getFirstArrayKey( _a560 );
	while ( isDefined( _k560 ) )
	{
		zombie = _a560[ _k560 ];
		if ( isDefined( trigger ) && zombie istouching( trigger ) )
		{
			return 1;
		}
		while ( isDefined( more_triggers ) && more_triggers.size > 0 )
		{
			_a565 = more_triggers;
			_k565 = getFirstArrayKey( _a565 );
			while ( isDefined( _k565 ) )
			{
				trig = _a565[ _k565 ];
				if ( isDefined( trig ) && zombie istouching( trig ) )
				{
					return 1;
				}
				_k565 = getNextArrayKey( _a565, _k565 );
			}
		}
		_k560 = getNextArrayKey( _a560, _k560 );
	}
	return 0;
}

wait_trigger_clear( trigger, more_triggers, end_on )
{
	self endon( end_on );
	while ( any_player_touching_any( trigger, more_triggers ) || any_zombie_touching_any( trigger, more_triggers ) )
	{
		wait 1;
	}
/#
	println( "ZM BLOCKER local door trigger clear\n" );
#/
	self notify( "trigger_clear" );
}

waittill_door_trigger_clear_local_power_off( trigger, all_trigs )
{
	self endon( "trigger_clear" );
	while ( 1 )
	{
		if ( isDefined( self.local_power_on ) && self.local_power_on )
		{
			self waittill( "local_power_off" );
		}
/#
		println( "ZM BLOCKER local door power off\n" );
#/
		self wait_trigger_clear( trigger, all_trigs, "local_power_on" );
	}
}

waittill_door_trigger_clear_global_power_off( trigger, all_trigs )
{
	self endon( "trigger_clear" );
	while ( 1 )
	{
		if ( isDefined( self.power_on ) && self.power_on )
		{
			self waittill( "power_off" );
		}
/#
		println( "ZM BLOCKER global door power off\n" );
#/
		self wait_trigger_clear( trigger, all_trigs, "power_on" );
	}
}

waittill_door_can_close()
{
	trigger = undefined;
	if ( isDefined( self.door_hold_trigger ) )
	{
		trigger = getent( self.door_hold_trigger, "targetname" );
	}
	all_trigs = getentarray( self.target, "target" );
	switch( self.script_noteworthy )
	{
		case "local_electric_door":
			if ( isDefined( trigger ) || isDefined( all_trigs ) )
			{
				self waittill_door_trigger_clear_local_power_off( trigger, all_trigs );
				self thread kill_trapped_zombies( trigger );
			}
			else
			{
				if ( isDefined( self.local_power_on ) && self.local_power_on )
				{
					self waittill( "local_power_off" );
				}
			}
			return;
			case "electric_door":
				if ( isDefined( trigger ) || isDefined( all_trigs ) )
				{
					self waittill_door_trigger_clear_global_power_off( trigger, all_trigs );
					if ( isDefined( trigger ) )
					{
						self thread kill_trapped_zombies( trigger );
					}
				}
				else
				{
					if ( isDefined( self.power_on ) && self.power_on )
					{
						self waittill( "power_off" );
					}
				}
				return;
		}
	}
}

door_think()
{
	self endon( "kill_door_think" );
	cost = 1000;
	if ( isDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	self sethintlowpriority( 1 );
	for ( ;; )
	{
		while ( 1 )
		{
			switch( self.script_noteworthy )
			{
				case "local_electric_door":
					if ( isDefined( self.local_power_on ) && !self.local_power_on )
					{
						self waittill( "local_power_on" );
					}
					if ( isDefined( self._door_open ) && !self._door_open )
					{
/#
						println( "ZM BLOCKER local door opened\n" );
#/
						self door_opened( cost, 1 );
						if ( !isDefined( self.power_cost ) )
						{
							self.power_cost = 0;
						}
						self.power_cost += 200;
					}
					self sethintstring( "" );
					if ( isDefined( level.local_doors_stay_open ) && level.local_doors_stay_open )
					{
						return;
					}
					wait 3;
					self waittill_door_can_close();
					self door_block();
					if ( isDefined( self._door_open ) && self._door_open )
					{
/#
						println( "ZM BLOCKER local door closed\n" );
#/
						self door_opened( cost, 1 );
					}
					self sethintstring( &"ZOMBIE_NEED_LOCAL_POWER" );
					wait 3;
				}
				case "electric_door":
					if ( isDefined( self.power_on ) && !self.power_on )
					{
						self waittill( "power_on" );
					}
					if ( isDefined( self._door_open ) && !self._door_open )
					{
/#
						println( "ZM BLOCKER global door opened\n" );
#/
						self door_opened( cost, 1 );
						if ( !isDefined( self.power_cost ) )
						{
							self.power_cost = 0;
						}
						self.power_cost += 200;
					}
					self sethintstring( "" );
					if ( isDefined( level.local_doors_stay_open ) && level.local_doors_stay_open )
					{
						return;
					}
					wait 3;
					self waittill_door_can_close();
					self door_block();
					if ( isDefined( self._door_open ) && self._door_open )
					{
/#
						println( "ZM BLOCKER global door closed\n" );
#/
						self door_opened( cost, 1 );
					}
					self sethintstring( &"ZOMBIE_NEED_POWER" );
					wait 3;
				}
				case "electric_buyable_door":
					flag_wait( "power_on" );
					self set_hint_string( self, "default_buy_door_" + cost );
					while ( !self door_buy() )
					{
						continue;
					}
					case "delay_door":
						while ( !self door_buy() )
						{
							continue;
						}
						self door_delay();
						break;
					default:
						if ( isDefined( level._default_door_custom_logic ) )
						{
							self [[ level._default_door_custom_logic ]]();
							break;
					}
					else while ( !self door_buy() )
					{
						continue;
					}
				}
				self door_opened( cost );
				if ( !flag( "door_can_close" ) )
				{
					return;
				}
				else }
		}
	}
}

self_and_flag_wait( msg )
{
	self endon( msg );
	if ( isDefined( self.power_door_ignore_flag_wait ) && self.power_door_ignore_flag_wait )
	{
		level waittill( "forever" );
	}
	else
	{
		flag_wait( msg );
	}
}

door_block()
{
	while ( isDefined( self.doors ) )
	{
		i = 0;
		while ( i < self.doors.size )
		{
			if ( isDefined( self.doors[ i ].script_noteworthy ) || self.doors[ i ].script_noteworthy == "clip" && isDefined( self.doors[ i ].script_string ) && self.doors[ i ].script_string == "clip" )
			{
				self.doors[ i ] solid();
			}
			i++;
		}
	}
}

door_opened( cost, quick_close )
{
	if ( isDefined( self.door_is_moving ) && self.door_is_moving )
	{
		return;
	}
	self.has_been_opened = 1;
	all_trigs = getentarray( self.target, "target" );
	self.door_is_moving = 1;
	_a822 = all_trigs;
	_k822 = getFirstArrayKey( _a822 );
	while ( isDefined( _k822 ) )
	{
		trig = _a822[ _k822 ];
		trig.door_is_moving = 1;
		trig trigger_off();
		trig.has_been_opened = 1;
		if ( !isDefined( trig._door_open ) || trig._door_open == 0 )
		{
			trig._door_open = 1;
			trig notify( "door_opened" );
		}
		else
		{
			trig._door_open = 0;
		}
		if ( isDefined( trig.script_flag ) && trig._door_open == 1 )
		{
			tokens = strtok( trig.script_flag, "," );
			i = 0;
			while ( i < tokens.size )
			{
				flag_set( tokens[ i ] );
				i++;
			}
		}
		else while ( isDefined( trig.script_flag ) && trig._door_open == 0 )
		{
			tokens = strtok( trig.script_flag, "," );
			i = 0;
			while ( i < tokens.size )
			{
				flag_clear( tokens[ i ] );
				i++;
			}
		}
		if ( isDefined( quick_close ) && quick_close )
		{
			trig set_hint_string( trig, "" );
		}
		else
		{
			if ( trig._door_open == 1 && flag( "door_can_close" ) )
			{
				trig set_hint_string( trig, "default_buy_door_close" );
				break;
			}
			else
			{
				if ( trig._door_open == 0 )
				{
					trig set_hint_string( trig, "default_buy_door_" + cost );
				}
			}
		}
		_k822 = getNextArrayKey( _a822, _k822 );
	}
	level notify( "door_opened" );
	if ( isDefined( self.doors ) )
	{
		is_script_model_door = 0;
		have_moving_clip_for_door = 0;
		use_blocker_clip_for_pathing = 0;
		_a878 = self.doors;
		_k878 = getFirstArrayKey( _a878 );
		while ( isDefined( _k878 ) )
		{
			door = _a878[ _k878 ];
			if ( is_true( door.ignore_use_blocker_clip_for_pathing_check ) )
			{
			}
			else if ( door.classname == "script_model" )
			{
				is_script_model_door = 1;
			}
			else
			{
				if ( door.classname == "script_brushmodel" && isDefined( door.script_noteworthy ) && door.script_noteworthy != "clip" || !isDefined( door.script_string ) && door.script_string != "clip" )
				{
					have_moving_clip_for_door = 1;
				}
			}
			_k878 = getNextArrayKey( _a878, _k878 );
		}
		if ( is_script_model_door )
		{
			use_blocker_clip_for_pathing = !have_moving_clip_for_door;
		}
		i = 0;
		while ( i < self.doors.size )
		{
			self.doors[ i ] thread door_activate( self.doors[ i ].script_transition_time, self._door_open, quick_close, use_blocker_clip_for_pathing );
			i++;
		}
		if ( self.doors.size )
		{
			play_sound_at_pos( "purchase", self.doors[ 0 ].origin );
		}
	}
	level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
	wait 1;
	self.door_is_moving = 0;
	_a921 = all_trigs;
	_k921 = getFirstArrayKey( _a921 );
	while ( isDefined( _k921 ) )
	{
		trig = _a921[ _k921 ];
		trig.door_is_moving = 0;
		_k921 = getNextArrayKey( _a921, _k921 );
	}
	if ( isDefined( quick_close ) && quick_close )
	{
		i = 0;
		while ( i < all_trigs.size )
		{
			all_trigs[ i ] trigger_on();
			i++;
		}
		return;
	}
	while ( flag( "door_can_close" ) )
	{
		wait 2;
		i = 0;
		while ( i < all_trigs.size )
		{
			all_trigs[ i ] trigger_on();
			i++;
		}
	}
}

physics_launch_door( door_trig )
{
	vec = vectorScale( vectornormalize( self.script_vector ), 10 );
	self rotateroll( 5, 0,05 );
	wait 0,05;
	self moveto( self.origin + vec, 0,1 );
	self waittill( "movedone" );
	self physicslaunch( self.origin, self.script_vector * 300 );
	wait 60;
	self delete();
}

door_solid_thread()
{
	self waittill_either( "rotatedone", "movedone" );
	self.door_moving = undefined;
	while ( 1 )
	{
		players = get_players();
		player_touching = 0;
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] istouching( self ) )
			{
				player_touching = 1;
				break;
			}
			else
			{
				i++;
			}
		}
		if ( !player_touching )
		{
			self solid();
			return;
		}
		wait 1;
	}
}

door_solid_thread_anim()
{
	self waittillmatch( "door_anim" );
	return "end";
	self.door_moving = undefined;
	while ( 1 )
	{
		players = get_players();
		player_touching = 0;
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] istouching( self ) )
			{
				player_touching = 1;
				break;
			}
			else
			{
				i++;
			}
		}
		if ( !player_touching )
		{
			self solid();
			return;
		}
		wait 1;
	}
}

disconnect_paths_when_done()
{
	self waittill_either( "rotatedone", "movedone" );
	self disconnectpaths();
}

self_disconnectpaths()
{
	self disconnectpaths();
}

debris_init()
{
	cost = 1000;
	if ( isDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	self set_hint_string( self, "default_buy_debris_" + cost );
	self setcursorhint( "HINT_NOICON" );
	if ( isDefined( self.script_flag ) && !isDefined( level.flag[ self.script_flag ] ) )
	{
		flag_init( self.script_flag );
	}
	self thread debris_think();
}

debris_think()
{
	if ( isDefined( level.custom_debris_function ) )
	{
		self [[ level.custom_debris_function ]]();
	}
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill( "trigger", who, force );
			if ( getDvarInt( "zombie_unlock_all" ) > 0 || isDefined( force ) && force )
			{
			}
			else
			{
				while ( !who usebuttonpressed() )
				{
					continue;
				}
				while ( who in_revive_trigger() )
				{
					continue;
				}
			}
			if ( is_player_valid( who ) )
			{
				players = get_players();
				if ( getDvarInt( "zombie_unlock_all" ) > 0 )
				{
					break;
				}
				else if ( who.score >= self.zombie_cost )
				{
					who maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
					maps/mp/_demo::bookmark( "zm_player_door", getTime(), who );
					who maps/mp/zombies/_zm_stats::increment_client_stat( "doors_purchased" );
					who maps/mp/zombies/_zm_stats::increment_player_stat( "doors_purchased" );
					break;
				}
				else
				{
					play_sound_at_pos( "no_purchase", self.origin );
					who maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "door_deny" );
				}
			}
			bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", who.name, who.score, level.round_number, self.zombie_cost, self.script_flag, self.origin, "door" );
			junk = getentarray( self.target, "targetname" );
			while ( isDefined( self.script_flag ) )
			{
				tokens = strtok( self.script_flag, "," );
				i = 0;
				while ( i < tokens.size )
				{
					flag_set( tokens[ i ] );
					i++;
				}
			}
			play_sound_at_pos( "purchase", self.origin );
			level notify( "junk purchased" );
			move_ent = undefined;
			clip = undefined;
			i = 0;
			while ( i < junk.size )
			{
				junk[ i ] connectpaths();
				if ( isDefined( junk[ i ].script_noteworthy ) )
				{
					if ( junk[ i ].script_noteworthy == "clip" )
					{
						clip = junk[ i ];
						i++;
						continue;
					}
				}
				else struct = undefined;
				if ( isDefined( junk[ i ].script_linkto ) )
				{
					struct = getstruct( junk[ i ].script_linkto, "script_linkname" );
					if ( isDefined( struct ) )
					{
						move_ent = junk[ i ];
						junk[ i ] thread debris_move( struct );
					}
					else
					{
						junk[ i ] delete();
					}
					i++;
					continue;
				}
				else
				{
					junk[ i ] delete();
				}
				i++;
			}
			all_trigs = getentarray( self.target, "target" );
			i = 0;
			while ( i < all_trigs.size )
			{
				all_trigs[ i ] delete();
				i++;
			}
			if ( isDefined( clip ) )
			{
				if ( isDefined( move_ent ) )
				{
					move_ent waittill( "movedone" );
				}
				clip delete();
			}
			return;
		}
		else
		{
		}
	}
}

debris_move( struct )
{
	self script_delay();
	self notsolid();
	self play_sound_on_ent( "debris_move" );
	playsoundatposition( "zmb_lightning_l", self.origin );
	if ( isDefined( self.script_firefx ) )
	{
		playfx( level._effect[ self.script_firefx ], self.origin );
	}
	while ( isDefined( self.script_noteworthy ) )
	{
		while ( self.script_noteworthy == "jiggle" )
		{
			num = randomintrange( 3, 5 );
			og_angles = self.angles;
			i = 0;
			while ( i < num )
			{
				angles = og_angles + ( -5 + randomfloat( 10 ), -5 + randomfloat( 10 ), -5 + randomfloat( 10 ) );
				time = randomfloatrange( 0,1, 0,4 );
				self rotateto( angles, time );
				wait ( time - 0,05 );
				i++;
			}
		}
	}
	time = 0,5;
	if ( isDefined( self.script_transition_time ) )
	{
		time = self.script_transition_time;
	}
	self moveto( struct.origin, time, time * 0,5 );
	self rotateto( struct.angles, time * 0,75 );
	self waittill( "movedone" );
	if ( isDefined( self.script_fxid ) )
	{
		playfx( level._effect[ self.script_fxid ], self.origin );
		playsoundatposition( "zmb_zombie_spawn", self.origin );
	}
	self delete();
}

blocker_disconnect_paths( start_node, end_node, two_way )
{
}

blocker_connect_paths( start_node, end_node, two_way )
{
}

blocker_init()
{
	if ( !isDefined( self.target ) )
	{
		return;
	}
	targets = getentarray( self.target, "targetname" );
	self.barrier_chunks = [];
	j = 0;
	while ( j < targets.size )
	{
		if ( targets[ j ] iszbarrier() )
		{
			self.zbarrier = targets[ j ];
			if ( isDefined( self.zbarrier.script_string ) )
			{
			}
			else
			{
			}
			m_collision = "p6_anim_zm_barricade_board_collision";
			precachemodel( m_collision );
			self.zbarrier setzbarriercolmodel( m_collision );
			self.zbarrier.chunk_health = [];
			i = 0;
			while ( i < self.zbarrier getnumzbarrierpieces() )
			{
				self.zbarrier.chunk_health[ i ] = 0;
				i++;
			}
		}
		else if ( isDefined( targets[ j ].script_string ) && targets[ j ].script_string == "rock" )
		{
			targets[ j ].material = "rock";
		}
		if ( isDefined( targets[ j ].script_parameters ) )
		{
			if ( targets[ j ].script_parameters == "grate" )
			{
				if ( isDefined( targets[ j ].script_noteworthy ) )
				{
					if ( targets[ j ].script_noteworthy != "2" && targets[ j ].script_noteworthy != "3" && targets[ j ].script_noteworthy != "4" || targets[ j ].script_noteworthy == "5" && targets[ j ].script_noteworthy == "6" )
					{
						targets[ j ] hide();
/#
						iprintlnbold( " Hide " );
#/
					}
				}
				break;
			}
			else if ( targets[ j ].script_parameters == "repair_board" )
			{
				targets[ j ].unbroken_section = getent( targets[ j ].target, "targetname" );
				if ( isDefined( targets[ j ].unbroken_section ) )
				{
					targets[ j ].unbroken_section linkto( targets[ j ] );
					targets[ j ] hide();
					targets[ j ] notsolid();
					targets[ j ].unbroken = 1;
					if ( isDefined( targets[ j ].unbroken_section.script_noteworthy ) && targets[ j ].unbroken_section.script_noteworthy == "glass" )
					{
						targets[ j ].material = "glass";
						targets[ j ] thread destructible_glass_barricade( targets[ j ].unbroken_section, self );
						break;
					}
					else
					{
						if ( isDefined( targets[ j ].unbroken_section.script_noteworthy ) && targets[ j ].unbroken_section.script_noteworthy == "metal" )
						{
							targets[ j ].material = "metal";
						}
					}
				}
				break;
			}
			else
			{
				if ( targets[ j ].script_parameters == "barricade_vents" )
				{
					targets[ j ].material = "metal_vent";
				}
			}
		}
		if ( isDefined( targets[ j ].targetname ) )
		{
			if ( targets[ j ].targetname == "auto2" )
			{
			}
		}
		targets[ j ] update_states( "repaired" );
		targets[ j ].destroyed = 0;
		targets[ j ] show();
		targets[ j ].claimed = 0;
		targets[ j ].anim_grate_index = 0;
		targets[ j ].og_origin = targets[ j ].origin;
		targets[ j ].og_angles = targets[ j ].angles;
		self.barrier_chunks[ self.barrier_chunks.size ] = targets[ j ];
		j++;
	}
	target_nodes = getnodearray( self.target, "targetname" );
	j = 0;
	while ( j < target_nodes.size )
	{
		if ( target_nodes[ j ].type == "Begin" )
		{
			self.neg_start = target_nodes[ j ];
			if ( isDefined( self.neg_start.target ) )
			{
				self.neg_end = getnode( self.neg_start.target, "targetname" );
			}
			blocker_disconnect_paths( self.neg_start, self.neg_end );
		}
		j++;
	}
	if ( isDefined( self.zbarrier ) )
	{
		if ( isDefined( self.barrier_chunks ) )
		{
			i = 0;
			while ( i < self.barrier_chunks.size )
			{
				self.barrier_chunks[ i ] delete();
				i++;
			}
			self.barrier_chunks = [];
		}
	}
	if ( isDefined( self.zbarrier ) && should_delete_zbarriers() )
	{
		self.zbarrier delete();
		self.zbarrier = undefined;
		return;
	}
	self blocker_attack_spots();
	self.trigger_location = getstruct( self.target, "targetname" );
	self thread blocker_think();
}

should_delete_zbarriers()
{
	gametype = getDvar( "ui_gametype" );
	if ( !is_classic() && !is_standard() && gametype != "zgrief" )
	{
		return 1;
	}
	return 0;
}

destructible_glass_barricade( unbroken_section, node )
{
	unbroken_section setcandamage( 1 );
	unbroken_section.health = 99999;
	unbroken_section waittill( "damage", amount, who );
	if ( is_player_valid( who ) || who maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		self thread maps/mp/zombies/_zm_spawner::zombie_boardtear_offset_fx_horizontle( self, node );
		level thread remove_chunk( self, node, 1 );
		self update_states( "destroyed" );
		self notify( "destroyed" );
		self.unbroken = 0;
	}
}

blocker_attack_spots()
{
	spots = [];
	numslots = self.zbarrier getzbarriernumattackslots();
	numslots = int( max( numslots, 1 ) );
	if ( numslots % 2 )
	{
		spots[ spots.size ] = groundpos_ignore_water_new( self.zbarrier.origin + vectorScale( ( -1, 0, 0 ), 60 ) );
	}
	while ( numslots > 1 )
	{
		reps = floor( numslots / 2 );
		slot = 1;
		i = 0;
		while ( i < reps )
		{
			offset = self.zbarrier getzbarrierattackslothorzoffset() * ( i + 1 );
			spots[ spots.size ] = groundpos_ignore_water_new( spots[ 0 ] + ( anglesToRight( self.angles ) * offset ) + vectorScale( ( -1, 0, 0 ), 60 ) );
			slot++;
			if ( slot < numslots )
			{
				spots[ spots.size ] = groundpos_ignore_water_new( spots[ 0 ] + ( anglesToRight( self.angles ) * ( offset * -1 ) ) + vectorScale( ( -1, 0, 0 ), 60 ) );
				slot++;
			}
			i++;
		}
	}
	taken = [];
	i = 0;
	while ( i < spots.size )
	{
		taken[ i ] = 0;
		i++;
	}
	self.attack_spots_taken = taken;
	self.attack_spots = spots;
/#
	self thread debug_attack_spots_taken();
#/
}

blocker_choke()
{
	level._blocker_choke = 0;
	level endon( "stop_blocker_think" );
	while ( 1 )
	{
		wait 0,05;
		level._blocker_choke = 0;
	}
}

blocker_think()
{
	level endon( "stop_blocker_think" );
	if ( !isDefined( level._blocker_choke ) )
	{
		level thread blocker_choke();
	}
	use_choke = 0;
	if ( isDefined( level._use_choke_blockers ) && level._use_choke_blockers == 1 )
	{
		use_choke = 1;
	}
	while ( 1 )
	{
		wait 0,5;
		if ( use_choke )
		{
			if ( level._blocker_choke > 3 )
			{
				wait 0,05;
			}
		}
		level._blocker_choke++;
		while ( all_chunks_intact( self, self.barrier_chunks ) )
		{
			continue;
		}
		while ( no_valid_repairable_boards( self, self.barrier_chunks ) )
		{
			continue;
		}
		self blocker_trigger_think();
	}
}

player_fails_blocker_repair_trigger_preamble( player, players, trigger, hold_required )
{
	if ( !isDefined( trigger ) )
	{
		return 1;
	}
	if ( !is_player_valid( player ) )
	{
		return 1;
	}
	if ( players.size == 1 && isDefined( players[ 0 ].intermission ) && players[ 0 ].intermission == 1 )
	{
		return 1;
	}
	if ( hold_required && !player usebuttonpressed() )
	{
		return 1;
	}
	if ( !hold_required && !player use_button_held() )
	{
		return 1;
	}
	if ( player in_revive_trigger() )
	{
		return 1;
	}
	return 0;
}

has_blocker_affecting_perk()
{
	has_perk = undefined;
	if ( self hasperk( "specialty_fastreload" ) )
	{
		has_perk = "specialty_fastreload";
	}
	return has_perk;
}

do_post_chunk_repair_delay( has_perk )
{
	if ( !self script_delay() )
	{
		wait 1;
	}
}

handle_post_board_repair_rewards( cost, zbarrier )
{
	self maps/mp/zombies/_zm_stats::increment_client_stat( "boards" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "boards" );
	if ( isDefined( self.pers[ "boards" ] ) && ( self.pers[ "boards" ] % 10 ) == 0 )
	{
		self thread do_player_general_vox( "general", "reboard", 90 );
	}
	if ( isDefined( level.pers_upgrade_boards ) && level.pers_upgrade_boards )
	{
		if ( level.round_number >= level.pers_boarding_round_start )
		{
			if ( isDefined( zbarrier ) )
			{
				self.upgrade_fx_origin = zbarrier.origin;
			}
			if ( is_classic() )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_boarding", 0 );
			}
		}
	}
	self.rebuild_barrier_reward += cost;
	if ( self.rebuild_barrier_reward < level.zombie_vars[ "rebuild_barrier_cap_per_round" ] )
	{
		self maps/mp/zombies/_zm_score::player_add_points( "rebuild_board", cost );
		self play_sound_on_ent( "purchase" );
	}
	if ( isDefined( self.board_repair ) )
	{
		self.board_repair += 1;
	}
}

blocker_unitrigger_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		self.stub.trigger_target notify( "trigger" );
	}
}

blocker_trigger_think()
{
	if ( isDefined( level.no_board_repair ) && level.no_board_repair )
	{
		return;
	}
/#
	println( "ZM >> TRIGGER blocker_trigger_think " );
#/
	level endon( "stop_blocker_think" );
	cost = 10;
	if ( isDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	original_cost = cost;
	if ( !isDefined( self.unitrigger_stub ) )
	{
		radius = 94,21;
		height = 94,21;
		if ( isDefined( self.trigger_location ) )
		{
			trigger_location = self.trigger_location;
		}
		else
		{
			trigger_location = self;
		}
		if ( isDefined( trigger_location.radius ) )
		{
			radius = trigger_location.radius;
		}
		if ( isDefined( trigger_location.height ) )
		{
			height = trigger_location.height;
		}
		trigger_pos = groundpos( trigger_location.origin ) + vectorScale( ( -1, 0, 0 ), 4 );
		self.unitrigger_stub = spawnstruct();
		self.unitrigger_stub.origin = trigger_pos;
		self.unitrigger_stub.radius = radius;
		self.unitrigger_stub.height = height;
		self.unitrigger_stub.script_unitrigger_type = "unitrigger_radius";
		self.unitrigger_stub.hint_string = get_hint_string( self, "default_reward_barrier_piece" );
		self.unitrigger_stub.cursor_hint = "HINT_NOICON";
		self.unitrigger_stub.trigger_target = self;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::blocker_unitrigger_think );
		maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
		if ( !isDefined( trigger_location.angles ) )
		{
			trigger_location.angles = ( -1, 0, 0 );
		}
		self.unitrigger_stub.origin = ( groundpos( trigger_location.origin ) + vectorScale( ( -1, 0, 0 ), 4 ) ) + ( anglesToForward( trigger_location.angles ) * -11 );
	}
	self thread trigger_delete_on_repair();
	thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::blocker_unitrigger_think );
/#
	if ( getDvarInt( "zombie_debug" ) > 0 )
	{
		thread debug_blocker( trigger_pos, radius, height );
#/
	}
	while ( 1 )
	{
		self waittill( "trigger", player );
		has_perk = player has_blocker_affecting_perk();
		if ( all_chunks_intact( self, self.barrier_chunks ) )
		{
			self notify( "all_boards_repaired" );
			return;
		}
		if ( no_valid_repairable_boards( self, self.barrier_chunks ) )
		{
			self notify( "no valid boards" );
			return;
		}
		while ( 1 )
		{
			players = get_players();
			if ( player_fails_blocker_repair_trigger_preamble( player, players, self.unitrigger_stub.trigger, 0 ) )
			{
				break;
			}
			else if ( isDefined( self.zbarrier ) )
			{
				chunk = get_random_destroyed_chunk( self, self.barrier_chunks );
				if ( isDefined( player.pers_upgrades_awarded[ "board" ] ) )
				{
					self thread replace_chunk( self, chunk, has_perk, player.pers_upgrades_awarded[ "board" ] );
				}
			}
			else
			{
				chunk = get_random_destroyed_chunk( self, self.barrier_chunks );
				if ( isDefined( chunk.script_parameter ) || chunk.script_parameters == "repair_board" && chunk.script_parameters == "barricade_vents" )
				{
					if ( isDefined( chunk.unbroken_section ) )
					{
						chunk show();
						chunk solid();
						chunk.unbroken_section self_delete();
					}
				}
				else
				{
					chunk show();
				}
				if ( isDefined( chunk.script_parameters ) && chunk.script_parameters != "board" || chunk.script_parameters == "repair_board" && chunk.script_parameters == "barricade_vents" )
				{
					if ( isDefined( level.use_clientside_board_fx ) && !level.use_clientside_board_fx )
					{
						if ( !isDefined( chunk.material ) || isDefined( chunk.material ) && chunk.material != "rock" )
						{
							chunk play_sound_on_ent( "rebuild_barrier_piece" );
						}
						playsoundatposition( "zmb_cha_ching", ( -1, 0, 0 ) );
					}
				}
				if ( chunk.script_parameters == "bar" )
				{
					chunk play_sound_on_ent( "rebuild_barrier_piece" );
					playsoundatposition( "zmb_cha_ching", ( -1, 0, 0 ) );
				}
				if ( isDefined( chunk.script_parameters ) )
				{
					if ( chunk.script_parameters == "bar" )
					{
						if ( isDefined( chunk.script_noteworthy ) )
						{
							if ( chunk.script_noteworthy == "5" )
							{
								chunk hide();
								break;
							}
							else
							{
								if ( chunk.script_noteworthy == "3" )
								{
									chunk hide();
								}
							}
						}
					}
				}
				if ( isDefined( player.pers_upgrades_awarded[ "board" ] ) )
				{
					self thread replace_chunk( self, chunk, has_perk, player.pers_upgrades_awarded[ "board" ] );
				}
			}
			if ( isDefined( self.clip ) )
			{
				self.clip enable_trigger();
				self.clip disconnectpaths();
			}
			else
			{
				blocker_disconnect_paths( self.neg_start, self.neg_end );
			}
			bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, original_cost, self.target, self.origin, "repair" );
			self do_post_chunk_repair_delay( has_perk );
			if ( !is_player_valid( player ) )
			{
				break;
			}
			else
			{
				player handle_post_board_repair_rewards( cost, self );
				if ( all_chunks_intact( self, self.barrier_chunks ) )
				{
					self notify( "all_boards_repaired" );
					return;
				}
				if ( no_valid_repairable_boards( self, self.barrier_chunks ) )
				{
					self notify( "no valid boards" );
					return;
				}
			}
		}
	}
}

random_destroyed_chunk_show()
{
	wait 0,5;
	self show();
}

door_repaired_rumble_n_sound()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( distance( players[ i ].origin, self.origin ) < 150 )
		{
			if ( isalive( players[ i ] ) )
			{
				players[ i ] thread board_completion();
			}
		}
		i++;
	}
}

board_completion()
{
	self endon( "disconnect" );
}

trigger_delete_on_repair()
{
	while ( 1 )
	{
		self waittill_either( "all_boards_repaired", "no valid boards" );
		maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
		return;
	}
}

blocker_doubler_hint( hint, original_cost )
{
	self endon( "death" );
	doubler_status = level.zombie_vars[ "zombie_powerup_point_doubler_on" ];
	while ( 1 )
	{
		wait 0,5;
		if ( doubler_status != level.zombie_vars[ "zombie_powerup_point_doubler_on" ] )
		{
			doubler_status = level.zombie_vars[ "zombie_powerup_point_doubler_on" ];
			cost = original_cost;
			if ( level.zombie_vars[ "zombie_powerup_point_doubler_on" ] )
			{
				cost = original_cost * 2;
			}
			self set_hint_string( self, hint + cost );
		}
	}
}

rebuild_barrier_reward_reset()
{
	self.rebuild_barrier_reward = 0;
}

remove_chunk( chunk, node, destroy_immediately, zomb )
{
	chunk update_states( "mid_tear" );
	if ( isDefined( chunk.script_parameters ) )
	{
		if ( chunk.script_parameters != "board" || chunk.script_parameters == "repair_board" && chunk.script_parameters == "barricade_vents" )
		{
			chunk thread zombie_boardtear_audio_offset( chunk );
		}
	}
	if ( isDefined( chunk.script_parameters ) )
	{
		if ( chunk.script_parameters == "bar" )
		{
			chunk thread zombie_bartear_audio_offset( chunk );
		}
	}
	chunk notsolid();
	fx = "wood_chunk_destory";
	if ( isDefined( self.script_fxid ) )
	{
		fx = self.script_fxid;
	}
	if ( isDefined( chunk.script_moveoverride ) && chunk.script_moveoverride )
	{
		chunk hide();
	}
	if ( isDefined( chunk.script_parameters ) && chunk.script_parameters == "bar" )
	{
		if ( isDefined( chunk.script_noteworthy ) && chunk.script_noteworthy == "4" )
		{
			ent = spawn( "script_origin", chunk.origin );
			ent.angles = node.angles + vectorScale( ( -1, 0, 0 ), 180 );
			dist = 100;
			if ( isDefined( chunk.script_move_dist ) )
			{
				dist_max = chunk.script_move_dist - 100;
				dist = 100 + randomint( dist_max );
			}
			else
			{
				dist = 100 + randomint( 100 );
			}
			dest = ent.origin + ( anglesToForward( ent.angles ) * dist );
			trace = bullettrace( dest + vectorScale( ( -1, 0, 0 ), 16 ), dest + vectorScale( ( -1, 0, 0 ), 200 ), 0, undefined );
			if ( trace[ "fraction" ] == 1 )
			{
				dest += vectorScale( ( -1, 0, 0 ), 200 );
			}
			else
			{
				dest = trace[ "position" ];
			}
			chunk linkto( ent );
			time = ent fake_physicslaunch( dest, 300 + randomint( 100 ) );
			if ( randomint( 100 ) > 40 )
			{
				ent rotatepitch( 180, time * 0,5 );
			}
			else
			{
				ent rotatepitch( 90, time, time * 0,5 );
			}
			wait time;
			chunk hide();
			wait 0,1;
			ent delete();
		}
		else
		{
			ent = spawn( "script_origin", chunk.origin );
			ent.angles = node.angles + vectorScale( ( -1, 0, 0 ), 180 );
			dist = 100;
			if ( isDefined( chunk.script_move_dist ) )
			{
				dist_max = chunk.script_move_dist - 100;
				dist = 100 + randomint( dist_max );
			}
			else
			{
				dist = 100 + randomint( 100 );
			}
			dest = ent.origin + ( anglesToForward( ent.angles ) * dist );
			trace = bullettrace( dest + vectorScale( ( -1, 0, 0 ), 16 ), dest + vectorScale( ( -1, 0, 0 ), 200 ), 0, undefined );
			if ( trace[ "fraction" ] == 1 )
			{
				dest += vectorScale( ( -1, 0, 0 ), 200 );
			}
			else
			{
				dest = trace[ "position" ];
			}
			chunk linkto( ent );
			time = ent fake_physicslaunch( dest, 260 + randomint( 100 ) );
			if ( randomint( 100 ) > 40 )
			{
				ent rotatepitch( 180, time * 0,5 );
			}
			else
			{
				ent rotatepitch( 90, time, time * 0,5 );
			}
			wait time;
			chunk hide();
			wait 0,1;
			ent delete();
		}
		chunk update_states( "destroyed" );
		chunk notify( "destroyed" );
	}
	if ( isDefined( chunk.script_parameters ) && chunk.script_parameters != "board" || chunk.script_parameters == "repair_board" && chunk.script_parameters == "barricade_vents" )
	{
		ent = spawn( "script_origin", chunk.origin );
		ent.angles = node.angles + vectorScale( ( -1, 0, 0 ), 180 );
		dist = 100;
		if ( isDefined( chunk.script_move_dist ) )
		{
			dist_max = chunk.script_move_dist - 100;
			dist = 100 + randomint( dist_max );
		}
		else
		{
			dist = 100 + randomint( 100 );
		}
		dest = ent.origin + ( anglesToForward( ent.angles ) * dist );
		trace = bullettrace( dest + vectorScale( ( -1, 0, 0 ), 16 ), dest + vectorScale( ( -1, 0, 0 ), 200 ), 0, undefined );
		if ( trace[ "fraction" ] == 1 )
		{
			dest += vectorScale( ( -1, 0, 0 ), 200 );
		}
		else
		{
			dest = trace[ "position" ];
		}
		chunk linkto( ent );
		time = ent fake_physicslaunch( dest, 200 + randomint( 100 ) );
		if ( isDefined( chunk.unbroken_section ) )
		{
			if ( !isDefined( chunk.material ) || chunk.material != "metal" )
			{
				chunk.unbroken_section self_delete();
			}
		}
		if ( randomint( 100 ) > 40 )
		{
			ent rotatepitch( 180, time * 0,5 );
		}
		else
		{
			ent rotatepitch( 90, time, time * 0,5 );
		}
		wait time;
		if ( isDefined( chunk.unbroken_section ) )
		{
			if ( isDefined( chunk.material ) && chunk.material == "metal" )
			{
				chunk.unbroken_section self_delete();
			}
		}
		chunk hide();
		wait 0,1;
		ent delete();
		chunk update_states( "destroyed" );
		chunk notify( "destroyed" );
	}
	if ( isDefined( chunk.script_parameters ) && chunk.script_parameters == "grate" )
	{
		if ( isDefined( chunk.script_noteworthy ) && chunk.script_noteworthy == "6" )
		{
			ent = spawn( "script_origin", chunk.origin );
			ent.angles = node.angles + vectorScale( ( -1, 0, 0 ), 180 );
			dist = 100 + randomint( 100 );
			dest = ent.origin + ( anglesToForward( ent.angles ) * dist );
			trace = bullettrace( dest + vectorScale( ( -1, 0, 0 ), 16 ), dest + vectorScale( ( -1, 0, 0 ), 200 ), 0, undefined );
			if ( trace[ "fraction" ] == 1 )
			{
				dest += vectorScale( ( -1, 0, 0 ), 200 );
			}
			else
			{
				dest = trace[ "position" ];
			}
			chunk linkto( ent );
			time = ent fake_physicslaunch( dest, 200 + randomint( 100 ) );
			if ( randomint( 100 ) > 40 )
			{
				ent rotatepitch( 180, time * 0,5 );
			}
			else
			{
				ent rotatepitch( 90, time, time * 0,5 );
			}
			wait time;
			chunk hide();
			ent delete();
			chunk update_states( "destroyed" );
			chunk notify( "destroyed" );
			return;
		}
		else
		{
			chunk hide();
			chunk update_states( "destroyed" );
			chunk notify( "destroyed" );
		}
	}
}

remove_chunk_rotate_grate( chunk )
{
	if ( isDefined( chunk.script_parameters ) && chunk.script_parameters == "grate" )
	{
		chunk vibrate( vectorScale( ( -1, 0, 0 ), 270 ), 0,2, 0,4, 0,4 );
		return;
	}
}

zombie_boardtear_audio_offset( chunk )
{
	if ( isDefined( chunk.material ) && !isDefined( chunk.already_broken ) )
	{
		chunk.already_broken = 0;
	}
	if ( isDefined( chunk.material ) && chunk.material == "glass" && chunk.already_broken == 0 )
	{
		chunk playsound( "zmb_break_glass_barrier" );
		wait randomfloatrange( 0,3, 0,6 );
		chunk playsound( "zmb_break_glass_barrier" );
		chunk.already_broken = 1;
	}
	else
	{
		if ( isDefined( chunk.material ) && chunk.material == "metal" && chunk.already_broken == 0 )
		{
			chunk playsound( "grab_metal_bar" );
			wait randomfloatrange( 0,3, 0,6 );
			chunk playsound( "break_metal_bar" );
			chunk.already_broken = 1;
			return;
		}
		else
		{
			if ( isDefined( chunk.material ) && chunk.material == "rock" )
			{
				if ( isDefined( level.use_clientside_rock_tearin_fx ) && !level.use_clientside_rock_tearin_fx )
				{
					chunk playsound( "zmb_break_rock_barrier" );
					wait randomfloatrange( 0,3, 0,6 );
					chunk playsound( "zmb_break_rock_barrier" );
				}
				chunk.already_broken = 1;
				return;
			}
			else
			{
				if ( isDefined( chunk.material ) && chunk.material == "metal_vent" )
				{
					if ( isDefined( level.use_clientside_board_fx ) && !level.use_clientside_board_fx )
					{
						chunk playsound( "evt_vent_slat_remove" );
					}
					return;
				}
				else
				{
					if ( isDefined( level.use_clientside_board_fx ) && !level.use_clientside_board_fx )
					{
						chunk play_sound_on_ent( "break_barrier_piece" );
						wait randomfloatrange( 0,3, 0,6 );
						chunk play_sound_on_ent( "break_barrier_piece" );
					}
					chunk.already_broken = 1;
				}
			}
		}
	}
}

zombie_bartear_audio_offset( chunk )
{
	chunk play_sound_on_ent( "grab_metal_bar" );
	wait randomfloatrange( 0,3, 0,6 );
	chunk play_sound_on_ent( "break_metal_bar" );
	wait randomfloatrange( 1, 1,3 );
	chunk play_sound_on_ent( "drop_metal_bar" );
}

ensure_chunk_is_back_to_origin( chunk )
{
	if ( chunk.origin != chunk.og_origin )
	{
		chunk notsolid();
		chunk waittill( "movedone" );
	}
}

replace_chunk( barrier, chunk, perk, upgrade, via_powerup )
{
	if ( !isDefined( barrier.zbarrier ) )
	{
		chunk update_states( "mid_repair" );
/#
		assert( isDefined( chunk.og_origin ) );
#/
/#
		assert( isDefined( chunk.og_angles ) );
#/
		sound = "rebuild_barrier_hover";
		if ( isDefined( chunk.script_presound ) )
		{
			sound = chunk.script_presound;
		}
	}
	has_perk = 0;
	if ( isDefined( perk ) )
	{
		has_perk = 1;
	}
	if ( !isDefined( via_powerup ) && isDefined( sound ) )
	{
		play_sound_at_pos( sound, chunk.origin );
	}
	if ( upgrade )
	{
		barrier.zbarrier zbarrierpieceuseupgradedmodel( chunk );
		barrier.zbarrier.chunk_health[ chunk ] = barrier.zbarrier getupgradedpiecenumlives( chunk );
	}
	else
	{
		barrier.zbarrier zbarrierpieceusedefaultmodel( chunk );
		barrier.zbarrier.chunk_health[ chunk ] = 0;
	}
	scalar = 1;
	if ( has_perk )
	{
		if ( perk == "speciality_fastreload" )
		{
			scalar = 0,31;
		}
		else
		{
			if ( perk == "speciality_fastreload_upgrade" )
			{
				scalar = 0,2112;
			}
		}
	}
	barrier.zbarrier showzbarrierpiece( chunk );
	barrier.zbarrier setzbarrierpiecestate( chunk, "closing", scalar );
	waitduration = barrier.zbarrier getzbarrierpieceanimlengthforstate( chunk, "closing", scalar );
	wait waitduration;
}

open_all_zbarriers()
{
	_a2606 = level.exterior_goals;
	_k2606 = getFirstArrayKey( _a2606 );
	while ( isDefined( _k2606 ) )
	{
		barrier = _a2606[ _k2606 ];
		while ( isDefined( barrier.zbarrier ) )
		{
			x = 0;
			while ( x < barrier.zbarrier getnumzbarrierpieces() )
			{
				barrier.zbarrier setzbarrierpiecestate( x, "opening" );
				x++;
			}
		}
		if ( isDefined( barrier.clip ) )
		{
			barrier.clip disable_trigger();
			barrier.clip connectpaths();
		}
		else
		{
			blocker_connect_paths( barrier.neg_start, barrier.neg_end );
		}
		_k2606 = getNextArrayKey( _a2606, _k2606 );
	}
}

zombie_boardtear_audio_plus_fx_offset_repair_horizontal( chunk )
{
	if ( isDefined( chunk.material ) && chunk.material == "rock" )
	{
		if ( isDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
		{
			chunk clearclientflag( level._zombie_scriptmover_flag_rock_fx );
		}
		else
		{
			earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0,3, 0,6 );
			chunk play_sound_on_ent( "break_barrier_piece" );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
		}
	}
	else
	{
		if ( isDefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
		{
			chunk clearclientflag( level._zombie_scriptmover_flag_board_horizontal_fx );
			return;
		}
		else
		{
			earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0,3, 0,6 );
			chunk play_sound_on_ent( "break_barrier_piece" );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
		}
	}
}

zombie_boardtear_audio_plus_fx_offset_repair_verticle( chunk )
{
	if ( isDefined( chunk.material ) && chunk.material == "rock" )
	{
		if ( isDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
		{
			chunk clearclientflag( level._zombie_scriptmover_flag_rock_fx );
		}
		else
		{
			earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0,3, 0,6 );
			chunk play_sound_on_ent( "break_barrier_piece" );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
		}
	}
	else
	{
		if ( isDefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
		{
			chunk clearclientflag( level._zombie_scriptmover_flag_board_vertical_fx );
			return;
		}
		else
		{
			earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0,3, 0,6 );
			chunk play_sound_on_ent( "break_barrier_piece" );
			playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
		}
	}
}

zombie_gratetear_audio_plus_fx_offset_repair_horizontal( chunk )
{
	earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
	chunk play_sound_on_ent( "bar_rebuild_slam" );
	switch( randomint( 9 ) )
	{
		case 0:
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0, 0,3 );
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 1:
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0, 0,3 );
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 2:
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0, 0,3 );
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 3:
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0, 0,3 );
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 4:
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			wait randomfloatrange( 0, 0,3 );
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 5:
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 6:
			playfx( level._effect[ "fx_zombie_bar_break_lite" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 7:
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
		case 8:
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin + vectorScale( ( -1, 0, 0 ), 30 ) );
			break;
	}
}

zombie_bartear_audio_plus_fx_offset_repair_horizontal( chunk )
{
	earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
	chunk play_sound_on_ent( "bar_rebuild_slam" );
	switch( randomint( 9 ) )
	{
		case 0:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
			break;
		case 1:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_left" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
			break;
		case 2:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
			break;
		case 3:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_left" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
			break;
		case 4:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
			break;
		case 5:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
			break;
		case 6:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
			break;
		case 7:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_left" );
			break;
		case 8:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
			break;
	}
}

zombie_bartear_audio_plus_fx_offset_repair_verticle( chunk )
{
	earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), chunk.origin, 150 );
	chunk play_sound_on_ent( "bar_rebuild_slam" );
	switch( randomint( 9 ) )
	{
		case 0:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
			break;
		case 1:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_top" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_bottom" );
			break;
		case 2:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_bottom" );
			break;
		case 3:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_top" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
			break;
		case 4:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
			wait randomfloatrange( 0, 0,3 );
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
			break;
		case 5:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
			break;
		case 6:
			playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
			break;
		case 7:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_top" );
			break;
		case 8:
			playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_bottom" );
			break;
	}
}

add_new_zombie_spawners()
{
	if ( isDefined( self.target ) )
	{
		self.possible_spawners = getentarray( self.target, "targetname" );
	}
	if ( isDefined( self.script_string ) )
	{
		spawners = getentarray( self.script_string, "targetname" );
		self.possible_spawners = arraycombine( self.possible_spawners, spawners, 1, 0 );
	}
	if ( !isDefined( self.possible_spawners ) )
	{
		return;
	}
	zombies_to_add = self.possible_spawners;
	i = 0;
	while ( i < self.possible_spawners.size )
	{
		self.possible_spawners[ i ].is_enabled = 1;
		add_spawner( self.possible_spawners[ i ] );
		i++;
	}
}

flag_blocker()
{
	if ( !isDefined( self.script_flag_wait ) )
	{
/#
		assertmsg( "Flag Blocker at " + self.origin + " does not have a script_flag_wait key value pair" );
#/
		return;
	}
	if ( !isDefined( level.flag[ self.script_flag_wait ] ) )
	{
		flag_init( self.script_flag_wait );
	}
	type = "connectpaths";
	if ( isDefined( self.script_noteworthy ) )
	{
		type = self.script_noteworthy;
	}
	flag_wait( self.script_flag_wait );
	self script_delay();
	if ( type == "connectpaths" )
	{
		self connectpaths();
		self disable_trigger();
		return;
	}
	if ( type == "disconnectpaths" )
	{
		self disconnectpaths();
		self disable_trigger();
		return;
	}
/#
	assertmsg( "flag blocker at " + self.origin + ", the type "" + type + "" is not recognized" );
#/
}

update_states( states )
{
/#
	assert( isDefined( states ) );
#/
	self.state = states;
}

quantum_bomb_open_nearest_door_validation( position )
{
	range_squared = 32400;
	zombie_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zombie_doors.size )
	{
		if ( distancesquared( zombie_doors[ i ].origin, position ) < range_squared )
		{
			return 1;
		}
		i++;
	}
	zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );
	i = 0;
	while ( i < zombie_airlock_doors.size )
	{
		if ( distancesquared( zombie_airlock_doors[ i ].origin, position ) < range_squared )
		{
			return 1;
		}
		i++;
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	i = 0;
	while ( i < zombie_debris.size )
	{
		if ( distancesquared( zombie_debris[ i ].origin, position ) < range_squared )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

quantum_bomb_open_nearest_door_result( position )
{
	range_squared = 32400;
	zombie_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zombie_doors.size )
	{
		if ( distancesquared( zombie_doors[ i ].origin, position ) < range_squared )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_good" );
			zombie_doors[ i ] notify( "trigger" );
			[[ level.quantum_bomb_play_area_effect_func ]]( position );
			return;
		}
		i++;
	}
	zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );
	i = 0;
	while ( i < zombie_airlock_doors.size )
	{
		if ( distancesquared( zombie_airlock_doors[ i ].origin, position ) < range_squared )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_good" );
			zombie_airlock_doors[ i ] notify( "trigger" );
			[[ level.quantum_bomb_play_area_effect_func ]]( position );
			return;
		}
		i++;
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	i = 0;
	while ( i < zombie_debris.size )
	{
		if ( distancesquared( zombie_debris[ i ].origin, position ) < range_squared )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_good" );
			zombie_debris[ i ] notify( "trigger" );
			[[ level.quantum_bomb_play_area_effect_func ]]( position );
			return;
		}
		i++;
	}
}
