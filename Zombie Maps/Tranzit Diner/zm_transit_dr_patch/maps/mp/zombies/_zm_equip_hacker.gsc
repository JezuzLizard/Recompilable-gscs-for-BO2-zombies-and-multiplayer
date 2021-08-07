#include maps/mp/zombies/_zm_equip_hacker;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_hacker_zm" ) )
	{
		return;
	}
	maps/mp/zombies/_zm_equipment::register_equipment( "equip_hacker_zm", &"ZOMBIE_EQUIP_HACKER_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_HACKER_HOWTO", undefined, "hacker" );
	level._hackable_objects = [];
	level._pooled_hackable_objects = [];
	onplayerconnect_callback( ::hacker_on_player_connect );
	level thread hack_trigger_think();
	level thread hacker_trigger_pool_think();
	level thread hacker_round_reward();
	if ( getDvarInt( #"53BD7080" ) == 1 )
	{
		level thread hacker_debug();
	}
}

hacker_round_reward()
{
	while ( 1 )
	{
		level waittill( "end_of_round" );
		if ( !isDefined( level._from_nml ) )
		{
			players = get_players();
			i = 0;
			while ( i < players.size )
			{
				if ( isDefined( players[ i ] get_player_equipment() ) && players[ i ] get_player_equipment() == "equip_hacker_zm" )
				{
					if ( isDefined( players[ i ].equipment_got_in_round[ "equip_hacker_zm" ] ) )
					{
						got_in_round = players[ i ].equipment_got_in_round[ "equip_hacker_zm" ];
						rounds_kept = level.round_number - got_in_round;
						rounds_kept -= 1;
						if ( rounds_kept > 0 )
						{
							rounds_kept = min( rounds_kept, 5 );
							score = rounds_kept * 500;
							players[ i ] maps/mp/zombies/_zm_score::add_to_player_score( int( score ) );
						}
					}
				}
				i++;
			}
		}
		else level._from_nml = undefined;
	}
}

hacker_debug()
{
	while ( 1 )
	{
		i = 0;
		while ( i < level._hackable_objects.size )
		{
			hackable = level._hackable_objects[ i ];
			if ( isDefined( hackable.pooled ) && hackable.pooled )
			{
				if ( isDefined( hackable._trigger ) )
				{
					col = vectorScale( ( 0, 0, 1 ), 255 );
					if ( isDefined( hackable.custom_debug_color ) )
					{
						col = hackable.custom_debug_color;
					}
/#
					print3d( hackable.origin, "+", col, 1, 1 );
#/
				}
				else
				{
/#
					print3d( hackable.origin, "+", vectorScale( ( 0, 0, 1 ), 255 ), 1, 1 );
#/
				}
				i++;
				continue;
			}
			else
			{
/#
				print3d( hackable.origin, "+", vectorScale( ( 0, 0, 1 ), 255 ), 1, 1 );
#/
			}
			i++;
		}
		wait 0,1;
	}
}

hacker_trigger_pool_think()
{
	if ( !isDefined( level._zombie_hacker_trigger_pool_size ) )
	{
		level._zombie_hacker_trigger_pool_size = 8;
	}
	pool_active = 0;
	level._hacker_pool = [];
	while ( 1 )
	{
		if ( pool_active )
		{
			if ( !any_hackers_active() )
			{
				destroy_pooled_items();
			}
			else
			{
				sweep_pooled_items();
				add_eligable_pooled_items();
			}
		}
		else
		{
			if ( any_hackers_active() )
			{
				pool_active = 1;
			}
		}
		wait 0,1;
	}
}

destroy_pooled_items()
{
	pool_active = 0;
	i = 0;
	while ( i < level._hacker_pool.size )
	{
		level._hacker_pool[ i ]._trigger delete();
		level._hacker_pool[ i ]._trigger = undefined;
		i++;
	}
	level._hacker_pool = [];
}

sweep_pooled_items()
{
	new_hacker_pool = [];
	i = 0;
	while ( i < level._hacker_pool.size )
	{
		if ( level._hacker_pool[ i ] should_pooled_object_exist() )
		{
			new_hacker_pool[ new_hacker_pool.size ] = level._hacker_pool[ i ];
			i++;
			continue;
		}
		else
		{
			level._hacker_pool[ i ]._trigger delete();
			level._hacker_pool[ i ]._trigger = undefined;
		}
		i++;
	}
	level._hacker_pool = new_hacker_pool;
}

should_pooled_object_exist()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] hacker_active() )
		{
			if ( isDefined( self.entity ) )
			{
				if ( self.entity != players[ i ] )
				{
					if ( distance2dsquared( players[ i ].origin, self.entity.origin ) <= ( self.radius * self.radius ) )
					{
						return 1;
					}
				}
			}
			else
			{
				if ( distance2dsquared( players[ i ].origin, self.origin ) <= ( self.radius * self.radius ) )
				{
					return 1;
				}
			}
		}
		i++;
	}
	return 0;
}

add_eligable_pooled_items()
{
	candidates = [];
	i = 0;
	while ( i < level._hackable_objects.size )
	{
		hackable = level._hackable_objects[ i ];
		if ( isDefined( hackable.pooled ) && hackable.pooled && !isDefined( hackable._trigger ) )
		{
			if ( !isinarray( level._hacker_pool, hackable ) )
			{
				if ( hackable should_pooled_object_exist() )
				{
					candidates[ candidates.size ] = hackable;
				}
			}
		}
		i++;
	}
	i = 0;
	while ( i < candidates.size )
	{
		candidate = candidates[ i ];
		height = 72;
		radius = 32;
		if ( isDefined( candidate.radius ) )
		{
			radius = candidate.radius;
		}
		if ( isDefined( self.height ) )
		{
			height = candidate.height;
		}
		trigger = spawn( "trigger_radius_use", candidate.origin, 0, radius, height );
		trigger usetriggerrequirelookat();
		trigger setcursorhint( "HINT_NOICON" );
		trigger.radius = radius;
		trigger.height = height;
		trigger.beinghacked = 0;
		candidate._trigger = trigger;
		level._hacker_pool[ level._hacker_pool.size ] = candidate;
		i++;
	}
}

any_hackers_active()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] hacker_active() )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

register_hackable( name, callback_func, qualifier_func )
{
	structs = getstructarray( name, "script_noteworthy" );
	if ( !isDefined( structs ) )
	{
/#
		println( "Error:  register_hackable called on script_noteworthy " + name + " but no such structs exist." );
#/
		return;
	}
	i = 0;
	while ( i < structs.size )
	{
		if ( !isinarray( level._hackable_objects, structs[ i ] ) )
		{
			structs[ i ]._hack_callback_func = callback_func;
			structs[ i ]._hack_qualifier_func = qualifier_func;
			structs[ i ].pooled = level._hacker_pooled;
			if ( isDefined( structs[ i ].targetname ) )
			{
				structs[ i ].hacker_target = getent( structs[ i ].targetname, "targetname" );
			}
			level._hackable_objects[ level._hackable_objects.size ] = structs[ i ];
			if ( isDefined( level._hacker_pooled ) )
			{
				level._pooled_hackable_objects[ level._pooled_hackable_objects.size ] = structs[ i ];
			}
			structs[ i ] thread hackable_object_thread();
			wait_network_frame();
		}
		i++;
	}
}

register_hackable_struct( struct, callback_func, qualifier_func )
{
	if ( !isinarray( level._hackable_objects, struct ) )
	{
		struct._hack_callback_func = callback_func;
		struct._hack_qualifier_func = qualifier_func;
		struct.pooled = level._hacker_pooled;
		if ( isDefined( struct.targetname ) )
		{
			struct.hacker_target = getent( struct.targetname, "targetname" );
		}
		level._hackable_objects[ level._hackable_objects.size ] = struct;
		if ( isDefined( level._hacker_pooled ) )
		{
			level._pooled_hackable_objects[ level._pooled_hackable_objects.size ] = struct;
		}
		struct thread hackable_object_thread();
	}
}

register_pooled_hackable_struct( struct, callback_func, qualifier_func )
{
	level._hacker_pooled = 1;
	register_hackable_struct( struct, callback_func, qualifier_func );
	level._hacker_pooled = undefined;
}

register_pooled_hackable( name, callback_func, qualifier_func )
{
	level._hacker_pooled = 1;
	register_hackable( name, callback_func, qualifier_func );
	level._hacker_pooled = undefined;
}

deregister_hackable_struct( struct )
{
	if ( isinarray( level._hackable_objects, struct ) )
	{
		new_list = [];
		i = 0;
		while ( i < level._hackable_objects.size )
		{
			if ( level._hackable_objects[ i ] != struct )
			{
				new_list[ new_list.size ] = level._hackable_objects[ i ];
				i++;
				continue;
			}
			else
			{
				level._hackable_objects[ i ] notify( "hackable_deregistered" );
				if ( isDefined( level._hackable_objects[ i ]._trigger ) )
				{
					level._hackable_objects[ i ]._trigger delete();
				}
				if ( isDefined( level._hackable_objects[ i ].pooled ) && level._hackable_objects[ i ].pooled )
				{
					arrayremovevalue( level._hacker_pool, level._hackable_objects[ i ] );
					arrayremovevalue( level._pooled_hackable_objects, level._hackable_objects[ i ] );
				}
			}
			i++;
		}
		level._hackable_objects = new_list;
	}
}

deregister_hackable( noteworthy )
{
	new_list = [];
	i = 0;
	while ( i < level._hackable_objects.size )
	{
		if ( !isDefined( level._hackable_objects[ i ].script_noteworthy ) || level._hackable_objects[ i ].script_noteworthy != noteworthy )
		{
			new_list[ new_list.size ] = level._hackable_objects[ i ];
		}
		else
		{
			level._hackable_objects[ i ] notify( "hackable_deregistered" );
			if ( isDefined( level._hackable_objects[ i ]._trigger ) )
			{
				level._hackable_objects[ i ]._trigger delete();
			}
		}
		if ( isDefined( level._hackable_objects[ i ].pooled ) && level._hackable_objects[ i ].pooled )
		{
			arrayremovevalue( level._hacker_pool, level._hackable_objects[ i ] );
		}
		i++;
	}
	level._hackable_objects = new_list;
}

hack_trigger_think()
{
	while ( 1 )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			j = 0;
			while ( j < level._hackable_objects.size )
			{
				hackable = level._hackable_objects[ j ];
				if ( isDefined( hackable._trigger ) )
				{
					qualifier_passed = 1;
					if ( isDefined( hackable._hack_qualifier_func ) )
					{
						qualifier_passed = hackable [[ hackable._hack_qualifier_func ]]( player );
					}
					if ( player hacker_active() && qualifier_passed && !hackable._trigger.beinghacked )
					{
						hackable._trigger setinvisibletoplayer( player, 0 );
						j++;
						continue;
					}
					else
					{
						hackable._trigger setinvisibletoplayer( player, 1 );
					}
				}
				j++;
			}
			i++;
		}
		wait 0,1;
	}
}

is_facing( facee )
{
	orientation = self getplayerangles();
	forwardvec = anglesToForward( orientation );
	forwardvec2d = ( forwardvec[ 0 ], forwardvec[ 1 ], 0 );
	unitforwardvec2d = vectornormalize( forwardvec2d );
	tofaceevec = facee.origin - self.origin;
	tofaceevec2d = ( tofaceevec[ 0 ], tofaceevec[ 1 ], 0 );
	unittofaceevec2d = vectornormalize( tofaceevec2d );
	dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
	dot_limit = 0,8;
	if ( isDefined( facee.dot_limit ) )
	{
		dot_limit = facee.dot_limit;
	}
	return dotproduct > dot_limit;
}

can_hack( hackable )
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( !self hacker_active() )
	{
		return 0;
	}
	if ( !isDefined( hackable._trigger ) )
	{
		return 0;
	}
	if ( isDefined( hackable.player ) )
	{
		if ( hackable.player != self )
		{
			return 0;
		}
	}
	if ( self throwbuttonpressed() )
	{
		return 0;
	}
	if ( self fragbuttonpressed() )
	{
		return 0;
	}
	if ( isDefined( hackable._hack_qualifier_func ) )
	{
		if ( !( hackable [[ hackable._hack_qualifier_func ]]( self ) ) )
		{
			return 0;
		}
	}
	if ( !isinarray( level._hackable_objects, hackable ) )
	{
		return 0;
	}
	radsquared = 1024;
	if ( isDefined( hackable.radius ) )
	{
		radsquared = hackable.radius * hackable.radius;
	}
	origin = hackable.origin;
	if ( isDefined( hackable.entity ) )
	{
		origin = hackable.entity.origin;
	}
	if ( distance2dsquared( self.origin, origin ) > radsquared )
	{
		return 0;
	}
	if ( !isDefined( hackable.no_touch_check ) && !self istouching( hackable._trigger ) )
	{
		return 0;
	}
	if ( !self is_facing( hackable ) )
	{
		return 0;
	}
	if ( !isDefined( hackable.no_sight_check ) && !sighttracepassed( self.origin + vectorScale( ( 0, 0, 1 ), 50 ), origin, 0, undefined ) )
	{
		return 0;
	}
	if ( !isDefined( hackable.no_bullet_trace ) && !bullettracepassed( self.origin + vectorScale( ( 0, 0, 1 ), 50 ), origin, 0, undefined ) )
	{
		return 0;
	}
	return 1;
}

is_hacking( hackable )
{
	if ( can_hack( hackable ) )
	{
		return self usebuttonpressed();
	}
}

set_hack_hint_string()
{
	if ( isDefined( self._trigger ) )
	{
		if ( isDefined( self.custom_string ) )
		{
			self._trigger sethintstring( self.custom_string );
			return;
		}
		else if ( !isDefined( self.script_int ) || self.script_int <= 0 )
		{
			self._trigger sethintstring( &"ZOMBIE_HACK_NO_COST" );
			return;
		}
		else
		{
			self._trigger sethintstring( &"ZOMBIE_HACK", self.script_int );
		}
	}
}

tidy_on_deregister( hackable )
{
	self endon( "clean_up_tidy_up" );
	hackable waittill( "hackable_deregistered" );
	if ( isDefined( self.hackerprogressbar ) )
	{
		self.hackerprogressbar maps/mp/gametypes_zm/_hud_util::destroyelem();
	}
	if ( isDefined( self.hackertexthud ) )
	{
		self.hackertexthud destroy();
	}
}

hacker_do_hack( hackable )
{
	timer = 0;
	hacked = 0;
	hackable._trigger.beinghacked = 1;
	if ( !isDefined( self.hackerprogressbar ) )
	{
		self.hackerprogressbar = self maps/mp/gametypes_zm/_hud_util::createprimaryprogressbar();
	}
	if ( !isDefined( self.hackertexthud ) )
	{
		self.hackertexthud = newclienthudelem( self );
	}
	hack_duration = hackable.script_float;
	if ( self hasperk( "specialty_fastreload" ) )
	{
		hack_duration *= 0,66;
	}
	hack_duration = max( 1,5, hack_duration );
	self thread tidy_on_deregister( hackable );
	self.hackerprogressbar maps/mp/gametypes_zm/_hud_util::updatebar( 0,01, 1 / hack_duration );
	self.hackertexthud.alignx = "center";
	self.hackertexthud.aligny = "middle";
	self.hackertexthud.horzalign = "center";
	self.hackertexthud.vertalign = "bottom";
	self.hackertexthud.y = -113;
	if ( issplitscreen() )
	{
		self.hackertexthud.y = -107;
	}
	self.hackertexthud.foreground = 1;
	self.hackertexthud.font = "default";
	self.hackertexthud.fontscale = 1,8;
	self.hackertexthud.alpha = 1;
	self.hackertexthud.color = ( 0, 0, 1 );
	self.hackertexthud settext( &"ZOMBIE_HACKING" );
	self playloopsound( "zmb_progress_bar", 0,5 );
	while ( self is_hacking( hackable ) )
	{
		wait 0,05;
		timer += 0,05;
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			break;
		}
		else if ( timer >= hack_duration )
		{
			hacked = 1;
			break;
		}
		else
		{
		}
	}
	self stoploopsound( 0,5 );
	if ( hacked )
	{
		self playsound( "vox_mcomp_hack_success" );
	}
	else self playsound( "vox_mcomp_hack_fail" );
	if ( isDefined( self.hackerprogressbar ) )
	{
		self.hackerprogressbar maps/mp/gametypes_zm/_hud_util::destroyelem();
	}
	if ( isDefined( self.hackertexthud ) )
	{
		self.hackertexthud destroy();
	}
	hackable set_hack_hint_string();
	if ( isDefined( hackable._trigger ) )
	{
		hackable._trigger.beinghacked = 0;
	}
	self notify( "clean_up_tidy_up" );
	return hacked;
}

lowreadywatcher( player )
{
	player endon( "disconnected" );
	self endon( "kill_lowreadywatcher" );
	self waittill( "hackable_deregistered" );
}

hackable_object_thread()
{
	self endon( "hackable_deregistered" );
	height = 72;
	radius = 64;
	if ( isDefined( self.radius ) )
	{
		radius = self.radius;
	}
	if ( isDefined( self.height ) )
	{
		height = self.height;
	}
	if ( !isDefined( self.pooled ) )
	{
		trigger = spawn( "trigger_radius_use", self.origin, 0, radius, height );
		trigger usetriggerrequirelookat();
		trigger setcursorhint( "HINT_NOICON" );
		trigger.radius = radius;
		trigger.height = height;
		trigger.beinghacked = 0;
		self._trigger = trigger;
	}
	cost = 0;
	if ( isDefined( self.script_int ) )
	{
		cost = self.script_int;
	}
	duration = 1;
	if ( isDefined( self.script_float ) )
	{
		duration = self.script_float;
	}
	while ( 1 )
	{
		wait 0,1;
		while ( !isDefined( self._trigger ) )
		{
			continue;
		}
		players = get_players();
		if ( isDefined( self._trigger ) )
		{
			self._trigger sethintstring( "" );
			if ( isDefined( self.entity ) )
			{
				self.origin = self.entity.origin;
				self._trigger.origin = self.entity.origin;
				if ( isDefined( self.trigger_offset ) )
				{
					self._trigger.origin += self.trigger_offset;
				}
			}
		}
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] can_hack( self ) )
			{
				self set_hack_hint_string();
				break;
			}
			else
			{
				i++;
			}
		}
		i = 0;
		while ( i < players.size )
		{
			hacker = players[ i ];
			if ( !hacker is_hacking( self ) )
			{
				i++;
				continue;
			}
			else if ( hacker.score >= cost || cost <= 0 )
			{
				self thread lowreadywatcher( hacker );
				hack_success = hacker hacker_do_hack( self );
				self notify( "kill_lowreadywatcher" );
				if ( isDefined( hacker ) )
				{
				}
				if ( isDefined( hacker ) && hack_success )
				{
					if ( cost )
					{
						if ( cost > 0 )
						{
							hacker maps/mp/zombies/_zm_score::minus_to_player_score( cost );
							break;
						}
						else
						{
							hacker maps/mp/zombies/_zm_score::add_to_player_score( cost * -1 );
						}
					}
					hacker notify( "successful_hack" );
					if ( isDefined( self._hack_callback_func ) )
					{
						self thread [[ self._hack_callback_func ]]( hacker );
					}
				}
				i++;
				continue;
			}
			else
			{
				hacker play_sound_on_ent( "no_purchase" );
				hacker maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money", undefined, 1 );
			}
			i++;
		}
	}
}

hacker_on_player_connect()
{
	struct = spawnstruct();
	struct.origin = self.origin;
	struct.radius = 48;
	struct.height = 64;
	struct.script_float = 10;
	struct.script_int = 500;
	struct.entity = self;
	struct.trigger_offset = vectorScale( ( 0, 0, 1 ), 48 );
	register_pooled_hackable_struct( struct, ::player_hack, ::player_qualifier );
	struct thread player_hack_disconnect_watcher( self );
}

player_hack_disconnect_watcher( player )
{
	player waittill( "disconnect" );
	deregister_hackable_struct( self );
}

player_hack( hacker )
{
	if ( isDefined( self.entity ) )
	{
		self.entity maps/mp/zombies/_zm_score::player_add_points( "hacker_transfer", 500 );
	}
	if ( isDefined( hacker ) )
	{
		hacker thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "hack_plr" );
	}
}

player_qualifier( player )
{
	if ( player == self.entity )
	{
		return 0;
	}
	if ( self.entity maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( self.entity.sessionstate == "spectator" ) && self.entity.sessionstate == "spectator" )
	{
		return 0;
	}
	return 1;
}

hide_hint_when_hackers_active( custom_logic_func, custom_logic_func_param )
{
	invis_to_any = 0;
	while ( 1 )
	{
		if ( isDefined( custom_logic_func ) )
		{
			self [[ custom_logic_func ]]( custom_logic_func_param );
		}
		if ( maps/mp/zombies/_zm_equip_hacker::any_hackers_active() )
		{
			players = get_players();
			i = 0;
			while ( i < players.size )
			{
				if ( players[ i ] hacker_active() )
				{
					self setinvisibletoplayer( players[ i ], 1 );
					invis_to_any = 1;
					i++;
					continue;
				}
				else
				{
					self setinvisibletoplayer( players[ i ], 0 );
				}
				i++;
			}
		}
		else while ( invis_to_any )
		{
			invis_to_any = 0;
			players = get_players();
			i = 0;
			while ( i < players.size )
			{
				self setinvisibletoplayer( players[ i ], 0 );
				i++;
			}
		}
		wait 0,1;
	}
}

hacker_debug_print( msg, color )
{
/#
	if ( !getDvarInt( #"428DE100" ) )
	{
		return;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	print3d( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), msg, color, 1, 1, 40 );
#/
}
