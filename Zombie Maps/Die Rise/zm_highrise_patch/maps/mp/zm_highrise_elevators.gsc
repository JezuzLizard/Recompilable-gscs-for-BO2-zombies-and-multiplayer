#include maps/mp/zombies/_zm_ai_leaper;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zm_highrise_distance_tracking;
#include maps/mp/zm_highrise_utility;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#using_animtree( "zombie_perk_elevator" );

init_perk_elvators_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

init_elevators()
{
	level thread init_perk_elevators_anims();
/#
	init_elevator_devgui();
#/
}

quick_revive_solo_watch()
{
	if ( flag( "solo_game" ) )
	{
		self.body perkelevatordoor( 1 );
	}
	machine_triggers = getentarray( "vending_revive", "target" );
	machine_trigger = machine_triggers[ 0 ];
	triggeroffset = machine_trigger.origin - self.body.origin;
	machineoffset = level.quick_revive_machine.origin - self.body.origin;
	while ( 1 )
	{
		level waittill_any( "revive_off", "revive_hide" );
		self.body.lock_doors = 1;
		self.body perkelevatordoor( 0 );
		machine_trigger unlink();
		wait 1;
		machine_trigger.origin += vectorScale( ( 0, 1, 0 ), 10000 );
		level waittill( "revive_on" );
		wait 1;
		machine_trigger.origin = self.body.origin + triggeroffset;
		machine_trigger linkto( self.body );
		level.quick_revive_machine.origin = self.body.origin + machineoffset;
		level.quick_revive_machine linkto( self.body );
		level.quick_revive_machine show();
		self.body.lock_doors = 0;
		self.body perkelevatordoor( 1 );
	}
}

init_perk_elevators_anims()
{
	level.perk_elevators_door_open_state = %v_zombie_elevator_doors_open;
	level.perk_elevators_door_close_state = %v_zombie_elevator_doors_close;
	level.perk_elevators_door_movement_state = %v_zombie_elevator_doors_idle_movement;
	level.perk_elevators_anims = [];
	level.perk_elevators_anims[ "vending_chugabud" ][ 0 ] = %v_zombie_elevator_doors_whoswho_banging_before_leaving;
	level.perk_elevators_anims[ "vending_chugabud" ][ 1 ] = %v_zombie_elevator_doors_whoswho_trying_to_close;
	level.perk_elevators_anims[ "vending_doubletap" ][ 0 ] = %v_zombie_elevator_doors_doubletap_banging_before_leaving;
	level.perk_elevators_anims[ "vending_doubletap" ][ 1 ] = %v_zombie_elevator_doors_doubletap_trying_to_close;
	level.perk_elevators_anims[ "vending_jugg" ][ 0 ] = %v_zombie_elevator_doors_jugg_banging_before_leaving;
	level.perk_elevators_anims[ "vending_jugg" ][ 1 ] = %v_zombie_elevator_doors_jugg_trying_to_close;
	level.perk_elevators_anims[ "vending_revive" ][ 0 ] = %v_zombie_elevator_doors_marathon_banging_before_leaving;
	level.perk_elevators_anims[ "vending_revive" ][ 1 ] = %v_zombie_elevator_doors_marathon_trying_to_close;
	level.perk_elevators_anims[ "vending_additionalprimaryweapon" ][ 0 ] = %v_zombie_elevator_doors_mulekick_banging_before_leaving;
	level.perk_elevators_anims[ "vending_additionalprimaryweapon" ][ 1 ] = %v_zombie_elevator_doors_mulekick_trying_to_close;
	level.perk_elevators_anims[ "specialty_weapupgrade" ][ 0 ] = %v_zombie_elevator_doors_pap_banging_before_leaving;
	level.perk_elevators_anims[ "specialty_weapupgrade" ][ 1 ] = %v_zombie_elevator_doors_pap_trying_to_close;
	level.perk_elevators_anims[ "vending_sleight" ][ 0 ] = %v_zombie_elevator_doors_speed_banging_before_leaving;
	level.perk_elevators_anims[ "vending_sleight" ][ 1 ] = %v_zombie_elevator_doors_speed_trying_to_close;
}

perkelevatoruseanimtree()
{
	self useanimtree( -1 );
}

perkelevatordoor( set )
{
	self endon( "death" );
	animtime = 1;
	if ( is_true( set ) )
	{
		self.door_state = set;
		self setanim( level.perk_elevators_door_open_state, 1, animtime, 1 );
		wait getanimlength( level.perk_elevators_door_open_state );
	}
	else
	{
		self.door_state = set;
		self setanim( level.perk_elevators_door_close_state, 1, animtime, 1 );
		wait getanimlength( level.perk_elevators_door_close_state );
	}
	self notify( "PerkElevatorDoor" );
}

get_link_entity_for_host_migration()
{
	_a127 = level.elevators;
	_k127 = getFirstArrayKey( _a127 );
	while ( isDefined( _k127 ) )
	{
		elevator = _a127[ _k127 ];
		if ( isDefined( elevator.body.trig ) )
		{
			if ( self istouching( elevator.body.trig ) )
			{
				return elevator.body;
			}
		}
		_k127 = getNextArrayKey( _a127, _k127 );
	}
	escape_pod = getent( "elevator_bldg1a_body", "targetname" );
	if ( self istouching( escape_pod ) )
	{
		return escape_pod;
	}
	if ( distance( escape_pod.origin, self.origin ) < 128 )
	{
		return escape_pod;
	}
	return undefined;
}

escape_pod_host_migration_respawn_check( escape_pod )
{
	wait 0,2;
	dif = self.origin[ 2 ] - escape_pod.origin[ 2 ];
/#
	println( "Escape_pod_host_migration_respawn_check :" );
#/
/#
	println( "dif : " + dif );
#/
	if ( dif > 100 )
	{
/#
		println( "Finding a better place for the player to be." );
#/
		self maps/mp/gametypes_zm/_hostmigration::hostmigration_put_player_in_better_place();
	}
	else
	{
/#
		println( "Taking no action." );
#/
	}
}

is_self_on_elevator()
{
	elevator_volumes = [];
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1d", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3a", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3d", "targetname" );
	_a190 = elevator_volumes;
	_k190 = getFirstArrayKey( _a190 );
	while ( isDefined( _k190 ) )
	{
		zone = _a190[ _k190 ];
		if ( self istouching( zone ) )
		{
			return 1;
		}
		_k190 = getNextArrayKey( _a190, _k190 );
	}
	_a198 = level.elevators;
	_k198 = getFirstArrayKey( _a198 );
	while ( isDefined( _k198 ) )
	{
		elevator = _a198[ _k198 ];
		if ( isDefined( elevator.body.trig ) )
		{
			if ( self istouching( elevator.body.trig ) )
			{
				return 1;
			}
		}
		_k198 = getNextArrayKey( _a198, _k198 );
	}
	escape_pod = getent( "elevator_bldg1a_body", "targetname" );
	if ( self istouching( escape_pod ) )
	{
		return 1;
	}
	if ( distance( escape_pod.origin, self.origin ) < 128 )
	{
		return 1;
	}
	return 0;
}

object_is_on_elevator()
{
	ground_ent = self getgroundent();
	depth = 0;
	while ( isDefined( ground_ent ) && depth < 2 )
	{
		if ( isDefined( ground_ent.is_elevator ) && ground_ent.is_elevator )
		{
			self.elevator_parent = ground_ent;
			return 1;
		}
		new_ground_ent = ground_ent getgroundent();
		if ( !isDefined( new_ground_ent ) || new_ground_ent == ground_ent )
		{
		}
		else
		{
			ground_ent = new_ground_ent;
			depth++;
		}
	}
	return 0;
}

elevator_level_for_floor( floor )
{
	flevel = "0";
	if ( isDefined( self.floors[ "" + ( floor + 1 ) ] ) )
	{
		flevel = "" + ( floor + 1 );
	}
	else
	{
		flevel = "0";
	}
	return flevel;
}

elevator_is_on_floor( floor )
{
	if ( self.body.current_level == floor )
	{
		return 1;
	}
	if ( self.floors[ self.body.current_level ].script_location == self.floors[ floor ].script_location )
	{
		return 1;
	}
	return 0;
}

elevator_path_nodes( elevatorname, floorname )
{
	name = "elevator_" + elevatorname + "_" + floorname;
	epaths = getnodearray( name, "script_noteworthy" );
	return epaths;
}

elevator_paths_onoff( onoff, target )
{
	while ( isDefined( self ) && self.size > 0 )
	{
		_a354 = self;
		_k354 = getFirstArrayKey( _a354 );
		while ( isDefined( _k354 ) )
		{
			node = _a354[ _k354 ];
			while ( isDefined( node.script_parameters ) && node.script_parameters == "roof_connect" )
			{
				_a358 = target;
				_k358 = getFirstArrayKey( _a358 );
				while ( isDefined( _k358 ) )
				{
					tnode = _a358[ _k358 ];
					if ( onoff )
					{
						maps/mp/zm_highrise_utility::highrise_link_nodes( node, tnode );
						maps/mp/zm_highrise_utility::highrise_link_nodes( tnode, node );
					}
					else
					{
						maps/mp/zm_highrise_utility::highrise_unlink_nodes( node, tnode );
						maps/mp/zm_highrise_utility::highrise_unlink_nodes( tnode, node );
					}
					_k358 = getNextArrayKey( _a358, _k358 );
				}
			}
			_k354 = getNextArrayKey( _a354, _k354 );
		}
	}
}

elevator_enable_paths( floor )
{
	self elevator_disable_paths( floor );
	paths = undefined;
	if ( !isDefined( floor ) || !isDefined( self.floors[ floor ].paths ) )
	{
		return;
	}
	else
	{
		paths = self.floors[ floor ].paths;
	}
	self.current_paths = paths;
	self.current_paths elevator_paths_onoff( 1, self.roof_paths );
}

elevator_disable_paths( floor )
{
	if ( isDefined( self.current_paths ) )
	{
		self.current_paths elevator_paths_onoff( 0, self.roof_paths );
	}
	self.current_paths = undefined;
}

init_elevator( elevatorname, force_starting_floor, force_starting_origin )
{
	if ( !isDefined( level.elevators ) )
	{
		level.elevators = [];
	}
	elevator = spawnstruct();
	elevator.name = elevatorname;
	elevator.body = undefined;
	level.elevators[ "bldg" + elevatorname ] = elevator;
	piece = getent( "elevator_bldg" + elevatorname + "_body", "targetname" );
	piece setmovingplatformenabled( 1 );
	piece.is_moving = 0;
	if ( !isDefined( piece ) )
	{
/#
		iprintlnbold( "Elevator with name: bldg" + elevatorname + " not found." );
#/
		return;
	}
	trig = getent( "elevator_bldg" + elevatorname + "_trigger", "targetname" );
	if ( isDefined( trig ) )
	{
		trig enablelinkto();
		trig linkto( piece );
		trig setmovingplatformenabled( 1 );
		piece.trig = trig;
		piece thread elevator_roof_watcher();
	}
	elevator.body = piece;
	piece.is_elevator = 1;
	elevator.body perkelevatoruseanimtree();
/#
	assert( isDefined( piece.script_location ) );
#/
	elevator.body.current_level = piece.script_location;
	elevator.body.starting_floor = piece.script_location;
	elevator.roof_paths = elevator_path_nodes( "bldg" + elevatorname, "moving" );
	elevator.floors = [];
	elevator.floors[ piece.script_location ] = piece;
	elevator.floors[ piece.script_location ].starting_position = piece.origin;
	elevator.floors[ piece.script_location ].paths = elevator_path_nodes( "bldg" + elevatorname, "floor" + piece.script_location );
	while ( isDefined( piece.target ) )
	{
		piece = getstruct( piece.target, "targetname" );
		piece.is_elevator = 1;
		if ( !isDefined( elevator.floors[ piece.script_location ] ) )
		{
			elevator.floors[ piece.script_location ] = piece;
			elevator.floors[ piece.script_location ].paths = elevator_path_nodes( "bldg" + elevatorname, "floor" + piece.script_location );
		}
	}
	if ( elevatorname != "3c" )
	{
		elevator.floors[ "" + elevator.floors.size ] = elevator.floors[ "1" ];
	}
	if ( isDefined( force_starting_floor ) )
	{
		elevator.body.force_starting_floor = force_starting_floor;
	}
	if ( isDefined( force_starting_origin ) )
	{
		elevator.body.force_starting_origin_offset = force_starting_origin;
	}
	level thread elevator_think( elevator );
	level thread elevator_depart_early( elevator );
	level thread elevator_sparks_fx( elevator );
/#
	init_elevator_devgui( "bldg" + elevatorname, elevator );
#/
}

elevator_roof_watcher()
{
	level endon( "end_game" );
	while ( 1 )
	{
		self.trig waittill( "trigger", who );
		while ( isDefined( who ) && isplayer( who ) )
		{
			while ( isDefined( who ) && who istouching( self.trig ) )
			{
				if ( self.is_moving )
				{
					self waittill_any( "movedone", "forcego" );
				}
				zombies = getaiarray( level.zombie_team );
				if ( isDefined( zombies ) && zombies.size > 0 )
				{
					_a535 = zombies;
					_k535 = getFirstArrayKey( _a535 );
					while ( isDefined( _k535 ) )
					{
						zombie = _a535[ _k535 ];
						climber = zombie zombie_for_elevator_unseen();
						if ( isDefined( climber ) )
						{
							break;
						}
						_k535 = getNextArrayKey( _a535, _k535 );
					}
					if ( isDefined( climber ) )
					{
						zombie zombie_climb_elevator( self );
						wait randomint( 30 );
					}
				}
				wait 0,5;
			}
		}
		wait 0,5;
	}
}

zombie_for_elevator_unseen()
{
	how_close = 600;
	distance_squared_check = how_close * how_close;
	zombie_seen = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		can_be_seen = self maps/mp/zm_highrise_distance_tracking::player_can_see_me( players[ i ] );
		if ( can_be_seen || distancesquared( self.origin, players[ i ].origin ) < distance_squared_check )
		{
			return undefined;
		}
		i++;
	}
	return self;
}

zombie_climb_elevator( elev )
{
	self endon( "death" );
	self endon( "removed" );
	self endon( "sonicBoom" );
	level endon( "intermission" );
	self notify( "stop_find_flesh" );
	self.dont_throw_gib = 1;
	self.forcemovementscriptstate = 1;
	self.attachent = elev;
	self linkto( self.attachent, "tag_origin" );
	self.jumpingtoelev = 1;
	animstate = "zm_traverse_elevator";
	anim_name = "zm_zombie_climb_elevator";
	tag_origin = self.attachent gettagorigin( "tag_origin" );
	tag_angles = self.attachent gettagangles( "tag_origin" );
	self animmode( "noclip" );
	self animscripted( tag_origin, tag_angles, animstate, anim_name );
	self maps/mp/animscripts/zm_shared::donotetracks( "traverse_anim" );
	self animmode( "gravity" );
	self.dont_throw_gib = 0;
	self.jumpingtoelev = 0;
	self.forcemovementscriptstate = 0;
	self unlink();
	self setgoalpos( self.origin );
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

elev_clean_up_corpses()
{
	corpses = getcorpsearray();
	zombies = getaiarray( level.zombie_team );
	while ( isDefined( corpses ) )
	{
		i = 0;
		while ( i < corpses.size )
		{
			if ( corpses[ i ] istouching( self.trig ) )
			{
				corpses[ i ] thread elev_remove_corpses();
			}
			i++;
		}
	}
	while ( isDefined( zombies ) )
	{
		_a633 = zombies;
		_k633 = getFirstArrayKey( _a633 );
		while ( isDefined( _k633 ) )
		{
			zombie = _a633[ _k633 ];
			if ( zombie istouching( self.trig ) && zombie.health <= 0 )
			{
				zombie thread elev_remove_corpses();
			}
			_k633 = getNextArrayKey( _a633, _k633 );
		}
	}
}

elev_remove_corpses()
{
	playfx( level._effect[ "zomb_gib" ], self.origin );
	self delete();
}

elevator_next_floor( elevator, last, justchecking )
{
	if ( isDefined( elevator.body.force_starting_floor ) )
	{
		floor = elevator.body.force_starting_floor;
		if ( !justchecking )
		{
			elevator.body.force_starting_floor = undefined;
		}
		return floor;
	}
	if ( !isDefined( last ) )
	{
		return 0;
	}
	if ( ( last + 1 ) < elevator.floors.size )
	{
		return last + 1;
	}
	return 0;
}

elevator_initial_wait( elevator, minwait, maxwait, delaybeforeleaving )
{
	elevator.body endon( "forcego" );
	elevator.body waittill_any_or_timeout( randomintrange( minwait, maxwait ), "depart_early" );
	if ( !is_true( elevator.body.lock_doors ) )
	{
		elevator.body setanim( level.perk_elevators_anims[ elevator.body.perk_type ][ 0 ] );
	}
	if ( !is_true( elevator.body.departing_early ) )
	{
		wait delaybeforeleaving;
	}
	if ( elevator.body.perk_type == "specialty_weapupgrade" )
	{
		while ( flag( "pack_machine_in_use" ) )
		{
			wait 0,5;
		}
		wait randomintrange( 1, 3 );
	}
	while ( isDefined( level.elevators_stop ) || level.elevators_stop && isDefined( elevator.body.elevator_stop ) && elevator.body.elevator_stop )
	{
		wait 0,05;
	}
}

elevator_set_moving( moving )
{
	self.body.is_moving = moving;
	if ( self.body is_pap() )
	{
		level.pap_moving = moving;
	}
}

predict_floor( elevator, next, speed )
{
	next = elevator_next_floor( elevator, next, 1 );
	if ( isDefined( elevator.floors[ "" + ( next + 1 ) ] ) )
	{
		elevator.body.next_level = "" + ( next + 1 );
	}
	else
	{
		start_location = 1;
		elevator.body.next_level = "0";
	}
	floor_stop = elevator.floors[ elevator.body.next_level ];
	floor_goal = undefined;
	cur_level_start_pos = elevator.floors[ elevator.body.next_level ].starting_position;
	start_level_start_pos = elevator.floors[ elevator.body.starting_floor ].starting_position;
	if ( elevator.body.next_level == elevator.body.starting_floor || isDefined( cur_level_start_pos ) && isDefined( start_level_start_pos ) && cur_level_start_pos == start_level_start_pos )
	{
		floor_goal = cur_level_start_pos;
	}
	else
	{
		floor_goal = floor_stop.origin;
	}
	dist = distance( elevator.body.origin, floor_goal );
	time = dist / speed;
	if ( dist > 0 )
	{
		if ( elevator.body.origin[ 2 ] > floor_goal[ 2 ] )
		{
			clientnotify( elevator.name + "_d" );
			return;
		}
		else
		{
			clientnotify( elevator.name + "_u" );
		}
	}
}

elevator_think( elevator )
{
	current_floor = elevator.body.current_location;
	delaybeforeleaving = 5;
	skipinitialwait = 0;
	speed = 100;
	minwait = 5;
	maxwait = 20;
	flag_wait( "perks_ready" );
	if ( isDefined( elevator.body.force_starting_floor ) )
	{
		elevator.body.current_level = "" + elevator.body.force_starting_floor;
		elevator.body.origin = elevator.floors[ elevator.body.current_level ].origin;
		if ( isDefined( elevator.body.force_starting_origin_offset ) )
		{
			elevator.body.origin += ( 0, 0, elevator.body.force_starting_origin_offset );
		}
	}
	elevator.body.can_move = 1;
	elevator elevator_set_moving( 0 );
	elevator elevator_enable_paths( elevator.body.current_level );
	if ( elevator.body.perk_type == "vending_revive" )
	{
		minwait = level.packapunch_timeout;
		maxwait = minwait + 10;
		elevator thread quick_revive_solo_watch();
	}
	if ( elevator.body.perk_type == "vending_revive" && flag( "solo_game" ) )
	{
	}
	else
	{
		flag_wait( "power_on" );
	}
	elevator.body perkelevatordoor( 1 );
	next = undefined;
	while ( 1 )
	{
		start_location = 0;
		if ( isDefined( elevator.body.force_starting_floor ) )
		{
			skipinitialwait = 1;
		}
		elevator.body.departing = 1;
		if ( !is_true( elevator.body.lock_doors ) )
		{
			elevator.body setanim( level.perk_elevators_anims[ elevator.body.perk_type ][ 1 ] );
		}
		predict_floor( elevator, next, speed );
		if ( !is_true( skipinitialwait ) )
		{
			elevator_initial_wait( elevator, minwait, maxwait, delaybeforeleaving );
			if ( !is_true( elevator.body.lock_doors ) )
			{
				elevator.body setanim( level.perk_elevators_anims[ elevator.body.perk_type ][ 1 ] );
			}
		}
		next = elevator_next_floor( elevator, next, 0 );
		if ( isDefined( elevator.floors[ "" + ( next + 1 ) ] ) )
		{
			elevator.body.next_level = "" + ( next + 1 );
		}
		else
		{
			start_location = 1;
			elevator.body.next_level = "0";
		}
		floor_stop = elevator.floors[ elevator.body.next_level ];
		floor_goal = undefined;
		cur_level_start_pos = elevator.floors[ elevator.body.next_level ].starting_position;
		start_level_start_pos = elevator.floors[ elevator.body.starting_floor ].starting_position;
		if ( elevator.body.next_level == elevator.body.starting_floor || isDefined( cur_level_start_pos ) && isDefined( start_level_start_pos ) && cur_level_start_pos == start_level_start_pos )
		{
			floor_goal = cur_level_start_pos;
		}
		else
		{
			floor_goal = floor_stop.origin;
		}
		dist = distance( elevator.body.origin, floor_goal );
		time = dist / speed;
		if ( dist > 0 )
		{
			if ( elevator.body.origin[ 2 ] > floor_goal[ 2 ] )
			{
				clientnotify( elevator.name + "_d" );
				break;
			}
			else
			{
				clientnotify( elevator.name + "_u" );
			}
		}
		if ( is_true( start_location ) )
		{
			elevator.body thread squashed_death_alarm();
			if ( !skipinitialwait )
			{
				wait 3;
			}
		}
		skipinitialwait = 0;
		elevator.body.current_level = elevator.body.next_level;
		elevator notify( "floor_changed" );
		elevator elevator_disable_paths( elevator.body.current_level );
		elevator.body.departing = 0;
		elevator elevator_set_moving( 1 );
		if ( dist > 0 )
		{
			elevator.body moveto( floor_goal, time, time * 0,25, time * 0,25 );
			if ( isDefined( elevator.body.trig ) )
			{
				elevator.body thread elev_clean_up_corpses();
			}
			elevator.body thread elevator_move_sound();
			elevator.body waittill_any( "movedone", "forcego" );
		}
		elevator elevator_set_moving( 0 );
		elevator elevator_enable_paths( elevator.body.current_level );
		if ( elevator.body.perk_type == "vending_revive" && !flag( "solo_game" ) && !flag( "power_on" ) )
		{
			flag_wait( "power_on" );
		}
	}
}

is_pap()
{
	return self.perk_type == "specialty_weapupgrade";
}

squashed_death_alarm()
{
	if ( !is_true( self.squashed_death_alarm ) )
	{
		self.squashed_death_alarm = 1;
		alarm_origin = spawn( "script_origin", self squashed_death_alarm_nearest_point() );
		alarm_origin playloopsound( "amb_alarm_bell", 0,1 );
		self waittill_any( "movedone", "forcego" );
		alarm_origin delete();
		self.squashed_death_alarm = 0;
	}
}

squashed_death_alarm_nearest_point()
{
	positions = array( ( 1653, 2267, 3527 ), ( 1962, 1803, 3575 ), ( 1379, 1224, 3356 ), ( 3161, -35, 3032 ), ( 2745, -672, 3014 ), ( 2404, -754, 3019 ), ( 1381, -660, 2842 ) );
	closest = vectorScale( ( 0, 1, 0 ), 999999 );
	_a965 = positions;
	_k965 = getFirstArrayKey( _a965 );
	while ( isDefined( _k965 ) )
	{
		vector = _a965[ _k965 ];
		if ( distance2dsquared( self.origin, vector ) < distance2dsquared( self.origin, closest ) )
		{
			closest = vector;
		}
		_k965 = getNextArrayKey( _a965, _k965 );
	}
	return closest;
}

elevator_move_sound()
{
	self playsound( "zmb_elevator_ding" );
	wait 0,4;
	self playsound( "zmb_elevator_ding" );
	self playsound( "zmb_elevator_run_start" );
	self playloopsound( "zmb_elevator_run", 0,5 );
	self waittill( "movedone" );
	self stoploopsound( 0,5 );
	self playsound( "zmb_elevator_run_stop" );
	self playsound( "zmb_elevator_ding" );
}

init_elevator_perks()
{
	level.elevator_perks = [];
	level.elevator_perks_building = [];
	level.elevator_perks_building[ "green" ] = [];
	level.elevator_perks_building[ "blue" ] = [];
	level.elevator_perks_building[ "green" ][ 0 ] = spawnstruct();
	level.elevator_perks_building[ "green" ][ 0 ].model = "zombie_vending_revive";
	level.elevator_perks_building[ "green" ][ 0 ].script_noteworthy = "specialty_quickrevive";
	level.elevator_perks_building[ "green" ][ 0 ].turn_on_notify = "revive_on";
	a = 1;
	b = 2;
	if ( randomint( 100 ) > 50 )
	{
		a = 2;
		b = 1;
	}
	level.elevator_perks_building[ "green" ][ a ] = spawnstruct();
	level.elevator_perks_building[ "green" ][ a ].model = "p6_zm_vending_chugabud";
	level.elevator_perks_building[ "green" ][ a ].script_noteworthy = "specialty_finalstand";
	level.elevator_perks_building[ "green" ][ a ].turn_on_notify = "chugabud_on";
	level.elevator_perks_building[ "green" ][ b ] = spawnstruct();
	level.elevator_perks_building[ "green" ][ b ].model = "zombie_vending_sleight";
	level.elevator_perks_building[ "green" ][ b ].script_noteworthy = "specialty_fastreload";
	level.elevator_perks_building[ "green" ][ b ].turn_on_notify = "sleight_on";
	level.elevator_perks_building[ "blue" ][ 0 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 0 ].model = "zombie_vending_three_gun";
	level.elevator_perks_building[ "blue" ][ 0 ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.elevator_perks_building[ "blue" ][ 0 ].turn_on_notify = "specialty_additionalprimaryweapon_power_on";
	level.elevator_perks_building[ "blue" ][ 1 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 1 ].model = "zombie_vending_jugg";
	level.elevator_perks_building[ "blue" ][ 1 ].script_noteworthy = "specialty_armorvest";
	level.elevator_perks_building[ "blue" ][ 1 ].turn_on_notify = "juggernog_on";
	level.elevator_perks_building[ "blue" ][ 2 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 2 ].model = "zombie_vending_doubletap2";
	level.elevator_perks_building[ "blue" ][ 2 ].script_noteworthy = "specialty_rof";
	level.elevator_perks_building[ "blue" ][ 2 ].turn_on_notify = "doubletap_on";
	level.elevator_perks_building[ "blue" ][ 3 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 3 ].model = "p6_anim_zm_buildable_pap";
	level.elevator_perks_building[ "blue" ][ 3 ].script_noteworthy = "specialty_weapupgrade";
	level.elevator_perks_building[ "blue" ][ 3 ].turn_on_notify = "Pack_A_Punch_on";
	players_expected = getnumexpectedplayers();
	level.override_perk_targetname = "zm_perk_machine_override";
	level.elevator_perks_building[ "blue" ] = array_randomize( level.elevator_perks_building[ "blue" ] );
	level.elevator_perks = arraycombine( level.elevator_perks_building[ "green" ], level.elevator_perks_building[ "blue" ], 0, 0 );
	random_perk_structs = [];
	revive_perk_struct = getstruct( "force_quick_revive", "targetname" );
	revive_perk_struct = getstruct( revive_perk_struct.target, "targetname" );
	perk_structs = getstructarray( "zm_random_machine", "script_noteworthy" );
	i = 0;
	while ( i < perk_structs.size )
	{
		random_perk_structs[ i ] = getstruct( perk_structs[ i ].target, "targetname" );
		random_perk_structs[ i ].script_parameters = perk_structs[ i ].script_parameters;
		random_perk_structs[ i ].script_linkent = getent( "elevator_" + perk_structs[ i ].script_parameters + "_body", "targetname" );
		print( random_perk_structs[ i ].script_noteworthy + " " + random_perk_structs[ i ].script_parameters );
		i++;
	}
	green_structs = [];
	blue_structs = [];
	_a1075 = random_perk_structs;
	_k1075 = getFirstArrayKey( _a1075 );
	while ( isDefined( _k1075 ) )
	{
		perk_struct = _a1075[ _k1075 ];
		if ( isDefined( perk_struct.script_parameters ) )
		{
			if ( issubstr( perk_struct.script_parameters, "bldg1" ) )
			{
				green_structs[ green_structs.size ] = perk_struct;
				break;
			}
			else
			{
				blue_structs[ blue_structs.size ] = perk_struct;
			}
		}
		_k1075 = getNextArrayKey( _a1075, _k1075 );
	}
	green_structs = array_exclude( green_structs, revive_perk_struct );
	green_structs = array_randomize( green_structs );
	blue_structs = array_randomize( blue_structs );
	level.random_perk_structs = array( revive_perk_struct );
	level.random_perk_structs = arraycombine( level.random_perk_structs, green_structs, 0, 0 );
	level.random_perk_structs = arraycombine( level.random_perk_structs, blue_structs, 0, 0 );
	i = 0;
	while ( i < level.elevator_perks.size )
	{
		if ( !isDefined( level.random_perk_structs[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			level.random_perk_structs[ i ].targetname = "zm_perk_machine_override";
			level.random_perk_structs[ i ].model = level.elevator_perks[ i ].model;
			level.random_perk_structs[ i ].script_noteworthy = level.elevator_perks[ i ].script_noteworthy;
			level.random_perk_structs[ i ].turn_on_notify = level.elevator_perks[ i ].turn_on_notify;
			if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
			{
				level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
			}
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_perk_structs[ i ];
		}
		i++;
	}
}

random_elevator_perks()
{
	perks = array( "vending_additionalprimaryweapon", "vending_revive", "vending_chugabud", "vending_jugg", "vending_doubletap", "vending_sleight" );
	_a1127 = perks;
	_k1127 = getFirstArrayKey( _a1127 );
	while ( isDefined( _k1127 ) )
	{
		perk = _a1127[ _k1127 ];
		machine = getent( perk, "targetname" );
		trigger = getent( perk, "target" );
		if ( !isDefined( machine ) || !isDefined( trigger ) )
		{
		}
		else
		{
			elevator = machine get_perk_elevator();
			trigger enablelinkto();
			trigger linkto( machine );
			if ( isDefined( trigger.clip ) )
			{
				trigger.clip delete();
			}
			if ( isDefined( trigger.bump ) )
			{
				trigger.bump enablelinkto();
				trigger.bump linkto( machine );
			}
			if ( isDefined( elevator ) )
			{
				elevator.perk_type = perk;
				elevator elevator_perk_offset( machine, perk );
				machine linkto( elevator );
				machine._linked_ent = elevator;
				machine._linked_ent_moves = 1;
				machine._linked_ent_offset = machine.origin - elevator.origin;
				if ( perk == "vending_revive" )
				{
					level.quick_revive_linked_ent = elevator;
					level.quick_revive_linked_ent_moves = 1;
					level.quick_revive_linked_ent_offset = machine._linked_ent_offset;
				}
				level thread debugline( machine, elevator );
			}
		}
		_k1127 = getNextArrayKey( _a1127, _k1127 );
	}
	trigger = getent( "specialty_weapupgrade", "script_noteworthy" );
	if ( isDefined( trigger ) )
	{
		machine = getent( trigger.target, "targetname" );
		elevator = machine get_perk_elevator();
		trigger enablelinkto();
		trigger linkto( machine );
		if ( isDefined( trigger.clip ) )
		{
			trigger.clip delete();
		}
		if ( isDefined( elevator ) )
		{
			elevator.perk_type = "specialty_weapupgrade";
			machine linkto( elevator );
			level thread debugline( machine, elevator );
		}
	}
	flag_set( "perks_ready" );
}

elevator_perk_offset( machine, perk )
{
	scale = 14;
	switch( perk )
	{
		case "vending_revive":
			scale = 10;
			break;
		case "vending_additionalprimaryweapon":
			scale = 8;
			break;
		case "vending_jugg":
			scale = 6;
			break;
		case "vending_doubletap":
			scale = 5;
			break;
		case "vending_chugabud":
			scale = -3;
			break;
		case "vending_packapunch":
			scale = 0;
			break;
	}
	if ( scale == 0 )
	{
		return;
	}
	forward = anglesToForward( self.angles );
	machine.origin -= forward * scale;
}

debugline( ent1, ent2 )
{
/#
	org = ent2.origin;
	while ( 1 )
	{
		if ( !isDefined( ent1 ) )
		{
			return;
		}
		line( ent1.origin, org, ( 0, 1, 0 ) );
		wait 0,05;
#/
	}
}

get_perk_elevator()
{
	arraylist = level.random_perk_structs;
	x = 0;
	while ( x < arraylist.size )
	{
		struct = arraylist[ x ];
		if ( isDefined( struct.script_noteworthy ) && isDefined( self.targetname ) )
		{
			nw = struct.script_noteworthy;
			tn = self.targetname;
			if ( nw == "specialty_quickrevive" && tn != "vending_revive" && nw == "specialty_fastreload" && tn != "vending_sleight" && nw == "specialty_rof" && tn != "vending_doubletap" && nw == "specialty_armorvest" && tn != "vending_jugg" && nw == "specialty_finalstand" && tn != "vending_chugabud" && nw == "specialty_additionalprimaryweapon" || tn == "vending_additionalprimaryweapon" && nw == "specialty_weapupgrade" && tn == "vending_packapunch" )
			{
				if ( isDefined( struct.script_linkent ) )
				{
					return struct.script_linkent;
				}
			}
		}
		x++;
	}
	return undefined;
}

elevator_depart_early( elevator )
{
	touchent = elevator.body;
	if ( isDefined( elevator.body.trig ) )
	{
		touchent = elevator.body.trig;
	}
	while ( 1 )
	{
		while ( is_true( elevator.body.is_moving ) )
		{
			wait 0,5;
		}
		someone_touching_elevator = 0;
		players = get_players();
		_a1321 = players;
		_k1321 = getFirstArrayKey( _a1321 );
		while ( isDefined( _k1321 ) )
		{
			player = _a1321[ _k1321 ];
			if ( player istouching( touchent ) )
			{
				someone_touching_elevator = 1;
			}
			_k1321 = getNextArrayKey( _a1321, _k1321 );
		}
		if ( is_true( someone_touching_elevator ) )
		{
			someone_still_touching_elevator = 0;
			wait 5;
			players = get_players();
			_a1336 = players;
			_k1336 = getFirstArrayKey( _a1336 );
			while ( isDefined( _k1336 ) )
			{
				player = _a1336[ _k1336 ];
				if ( player istouching( touchent ) )
				{
					someone_still_touching_elevator = 1;
				}
				_k1336 = getNextArrayKey( _a1336, _k1336 );
			}
			if ( is_true( someone_still_touching_elevator ) )
			{
				elevator.body.departing_early = 1;
				elevator.body notify( "depart_early" );
				wait 3;
				elevator.body.departing_early = 0;
			}
		}
		wait 1;
	}
}

elevator_sparks_fx( elevator )
{
	while ( 1 )
	{
		while ( !is_true( elevator.body.door_state ) )
		{
			wait 1;
		}
		if ( is_true( elevator.body.departing ) )
		{
			playfxontag( level._effect[ "perk_elevator_departing" ], elevator.body, "tag_origin" );
		}
		else
		{
			playfxontag( level._effect[ "perk_elevator_idle" ], elevator.body, "tag_origin" );
		}
		wait 0,5;
	}
}

faller_location_logic()
{
	wait 1;
	faller_spawn_points = getstructarray( "faller_location", "script_noteworthy" );
	leaper_spawn_points = getstructarray( "leaper_location", "script_noteworthy" );
	spawn_points = arraycombine( faller_spawn_points, leaper_spawn_points, 1, 0 );
	dist_check = 16384;
	elevator_names = getarraykeys( level.elevators );
	elevators = [];
	i = 0;
	while ( i < elevator_names.size )
	{
		elevators[ i ] = getent( "elevator_" + elevator_names[ i ] + "_body", "targetname" );
		i++;
	}
	elevator_volumes = [];
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1d", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3a", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3d", "targetname" );
	level.elevator_volumes = elevator_volumes;
	while ( 1 )
	{
		_a1409 = spawn_points;
		_k1409 = getFirstArrayKey( _a1409 );
		while ( isDefined( _k1409 ) )
		{
			point = _a1409[ _k1409 ];
			should_block = 0;
			_a1412 = elevators;
			_k1412 = getFirstArrayKey( _a1412 );
			while ( isDefined( _k1412 ) )
			{
				elevator = _a1412[ _k1412 ];
				if ( distancesquared( elevator.origin, point.origin ) <= dist_check )
				{
					should_block = 1;
				}
				_k1412 = getNextArrayKey( _a1412, _k1412 );
			}
			if ( should_block )
			{
				point.is_enabled = 0;
				point.is_blocked = 1;
			}
			else if ( isDefined( point.is_blocked ) && point.is_blocked )
			{
				point.is_blocked = 0;
			}
			if ( !isDefined( point.zone_name ) )
			{
			}
			else
			{
				zone = level.zones[ point.zone_name ];
				if ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
				{
					point.is_enabled = 1;
				}
			}
			_k1409 = getNextArrayKey( _a1409, _k1409 );
		}
		players = get_players();
		_a1441 = elevator_volumes;
		_k1441 = getFirstArrayKey( _a1441 );
		while ( isDefined( _k1441 ) )
		{
			volume = _a1441[ _k1441 ];
			should_disable = 0;
			_a1444 = players;
			_k1444 = getFirstArrayKey( _a1444 );
			while ( isDefined( _k1444 ) )
			{
				player = _a1444[ _k1444 ];
				if ( is_player_valid( player ) )
				{
					if ( player istouching( volume ) )
					{
						should_disable = 1;
					}
				}
				_k1444 = getNextArrayKey( _a1444, _k1444 );
			}
			if ( should_disable )
			{
				disable_elevator_spawners( volume, spawn_points );
			}
			_k1441 = getNextArrayKey( _a1441, _k1441 );
		}
		wait 0,5;
	}
}

disable_elevator_spawners( volume, spawn_points )
{
	_a1468 = spawn_points;
	_k1468 = getFirstArrayKey( _a1468 );
	while ( isDefined( _k1468 ) )
	{
		point = _a1468[ _k1468 ];
		if ( isDefined( point.name ) && point.name == volume.targetname )
		{
			point.is_enabled = 0;
		}
		_k1468 = getNextArrayKey( _a1468, _k1468 );
	}
}

shouldsuppressgibs()
{
	elevator_volumes = [];
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1d", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3a", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3d", "targetname" );
	while ( 1 )
	{
		zombies = get_round_enemy_array();
		while ( isDefined( zombies ) )
		{
			_a1494 = zombies;
			_k1494 = getFirstArrayKey( _a1494 );
			while ( isDefined( _k1494 ) )
			{
				zombie = _a1494[ _k1494 ];
				shouldnotgib = 0;
				_a1500 = elevator_volumes;
				_k1500 = getFirstArrayKey( _a1500 );
				while ( isDefined( _k1500 ) )
				{
					zone = _a1500[ _k1500 ];
					if ( is_true( shouldnotgib ) )
					{
					}
					else
					{
						if ( zombie istouching( zone ) )
						{
							shouldnotgib = 1;
						}
					}
					_k1500 = getNextArrayKey( _a1500, _k1500 );
				}
				zombie.dont_throw_gib = shouldnotgib;
				_k1494 = getNextArrayKey( _a1494, _k1494 );
			}
		}
		wait randomfloatrange( 0,5, 1,5 );
	}
}

watch_for_elevator_during_faller_spawn()
{
	self endon( "death" );
	self endon( "risen" );
	self endon( "spawn_anim" );
	while ( 1 )
	{
		should_gib = 0;
		_a1531 = level.elevators;
		_k1531 = getFirstArrayKey( _a1531 );
		while ( isDefined( _k1531 ) )
		{
			elevator = _a1531[ _k1531 ];
			if ( self istouching( elevator.body ) )
			{
				should_gib = 1;
			}
			_k1531 = getNextArrayKey( _a1531, _k1531 );
		}
		if ( should_gib )
		{
			playfx( level._effect[ "zomb_gib" ], self.origin );
			if ( isDefined( self.has_been_damaged_by_player ) && !self.has_been_damaged_by_player && isDefined( self.is_leaper ) && !self.is_leaper )
			{
				level.zombie_total++;
			}
			if ( isDefined( self.is_leaper ) && self.is_leaper )
			{
				self maps/mp/zombies/_zm_ai_leaper::leaper_cleanup();
				self dodamage( self.health + 100, self.origin );
			}
			else
			{
				self delete();
			}
			return;
		}
		else
		{
			wait 0,1;
		}
	}
}

init_elevator_devgui( elevatorname, elevator )
{
/#
	if ( !isDefined( elevatorname ) )
	{
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/Stop All:1" "set zombie_devgui_hrelevatorstop all" \n" );
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/Unstop All:2" "set zombie_devgui_hrelevatorgo all" \n" );
		level thread watch_elevator_devgui( "all", 1 );
	}
	else
	{
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/" + elevatorname + "/Stop:1" "set zombie_devgui_hrelevatorstop " + elevatorname + "" \n" );
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/" + elevatorname + "/Go:2" "set zombie_devgui_hrelevatorgo " + elevatorname + "" \n" );
		i = 0;
		while ( i < elevator.floors.size )
		{
			fname = elevator.floors[ "" + i ].script_location;
			adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/" + elevatorname + "/stop " + i + " [floor " + fname + "]" "set zombie_devgui_hrelevatorfloor " + i + "; set zombie_devgui_hrelevatorgo " + elevatorname + "" \n" );
			i++;
		}
		elevator thread watch_elevator_devgui( elevatorname, 0 );
		elevator thread show_elevator_floor( elevatorname );
#/
	}
}

watch_elevator_devgui( name, global )
{
/#
	while ( 1 )
	{
		stopcmd = getDvar( "zombie_devgui_hrelevatorstop" );
		if ( isDefined( stopcmd ) && stopcmd == name )
		{
			if ( global )
			{
				level.elevators_stop = 1;
			}
			else
			{
				if ( isDefined( self ) )
				{
					self.body.elevator_stop = 1;
				}
			}
			setdvar( "zombie_devgui_hrelevatorstop", "" );
		}
		gofloor = getDvarInt( "zombie_devgui_hrelevatorfloor" );
		gocmd = getDvar( "zombie_devgui_hrelevatorgo" );
		if ( isDefined( gocmd ) && gocmd == name )
		{
			if ( global )
			{
				level.elevators_stop = 0;
			}
			else
			{
				if ( isDefined( self ) )
				{
					self.body.elevator_stop = 0;
					if ( gofloor >= 0 )
					{
						self.body.force_starting_floor = gofloor;
					}
					self.body notify( "forcego" );
				}
			}
			setdvar( "zombie_devgui_hrelevatorfloor", "-1" );
			setdvar( "zombie_devgui_hrelevatorgo", "" );
		}
		wait 1;
#/
	}
}

show_elevator_floor( name )
{
/#
	while ( 1 )
	{
		if ( getDvarInt( #"B67910B4" ) )
		{
			floor = 0;
			forced = isDefined( self.body.force_starting_floor );
			color = vectorScale( ( 0, 1, 0 ), 0,7 );
			if ( forced )
			{
				color = ( 0,7, 0,3, 0 );
			}
			if ( isDefined( level.elevators_stop ) || level.elevators_stop && isDefined( self.body.elevator_stop ) && self.body.elevator_stop )
			{
				if ( forced )
				{
					color = vectorScale( ( 0, 1, 0 ), 0,7 );
				}
				else
				{
					color = vectorScale( ( 0, 1, 0 ), 0,7 );
				}
			}
			else
			{
				if ( self.body.is_moving )
				{
					if ( forced )
					{
						color = vectorScale( ( 0, 1, 0 ), 0,7 );
						break;
					}
					else
					{
						color = vectorScale( ( 0, 1, 0 ), 0,7 );
					}
				}
			}
			if ( isDefined( self.body.current_level ) )
			{
				floor = self.body.current_level;
			}
			text = "elv " + name + " stop " + self.body.current_level + " floor " + self.floors[ self.body.current_level ].script_location;
			pos = self.body.origin;
			print3d( pos, text, color, 1, 0,75, 1 );
		}
		wait 0,05;
#/
	}
}
