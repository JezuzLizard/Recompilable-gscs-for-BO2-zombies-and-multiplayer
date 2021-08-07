//checked includes match cerberus output
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_nuked_perks() //checked changed to match cerberus output
{
	level.perk_arrival_vehicle = getent( "perk_arrival_vehicle", "targetname" );
	level.perk_arrival_vehicle setmodel( "tag_origin" );
	flag_init( "perk_vehicle_bringing_in_perk" );
	structs = getstructarray( "zm_perk_machine", "targetname" );
	for ( i = 0; i < structs.size; i++ )
	{
		structs[ i ] structdelete();
	}
	level.nuked_perks = [];
	level.nuked_perks[ 0 ] = spawnstruct();
	level.nuked_perks[ 0 ].model = "zombie_vending_revive";
	level.nuked_perks[ 0 ].script_noteworthy = "specialty_quickrevive";
	level.nuked_perks[ 0 ].turn_on_notify = "revive_on";
	level.nuked_perks[ 1 ] = spawnstruct();
	level.nuked_perks[ 1 ].model = "zombie_vending_sleight";
	level.nuked_perks[ 1 ].script_noteworthy = "specialty_fastreload";
	level.nuked_perks[ 1 ].turn_on_notify = "sleight_on";
	level.nuked_perks[ 2 ] = spawnstruct();
	level.nuked_perks[ 2 ].model = "zombie_vending_doubletap2";
	level.nuked_perks[ 2 ].script_noteworthy = "specialty_rof";
	level.nuked_perks[ 2 ].turn_on_notify = "doubletap_on";
	level.nuked_perks[ 3 ] = spawnstruct();
	level.nuked_perks[ 3 ].model = "zombie_vending_jugg";
	level.nuked_perks[ 3 ].script_noteworthy = "specialty_armorvest";
	level.nuked_perks[ 3 ].turn_on_notify = "juggernog_on";
	level.nuked_perks[ 4 ] = spawnstruct();
	level.nuked_perks[ 4 ].model = "p6_anim_zm_buildable_pap";
	level.nuked_perks[ 4 ].script_noteworthy = "specialty_weapupgrade";
	level.nuked_perks[ 4 ].turn_on_notify = "Pack_A_Punch_on";
	players = getnumexpectedplayers();
	if ( players == 1 )
	{
		level.override_perk_targetname = "zm_perk_machine_override";
		revive_perk_structs = getstructarray( "solo_revive", "targetname" );
		for ( i = 0; i < revive_perk_structs.size; i++ )
		{
			random_revive_structs[ i ] = getstruct( revive_perk_structs[ i ].target, "targetname" );
			random_revive_structs[ i ].script_int = revive_perk_structs[ i ].script_int;
		}
		level.random_revive_structs = array_randomize( random_revive_structs );
		level.random_revive_structs[ 0 ].targetname = "zm_perk_machine_override";
		level.random_revive_structs[ 0 ].model = level.nuked_perks[ 0 ].model;
		level.random_revive_structs[ 0 ].blocker_model = getent( level.random_revive_structs[ 0 ].target, "targetname" );
		level.random_revive_structs[ 0 ].script_noteworthy = level.nuked_perks[ 0 ].script_noteworthy;
		level.random_revive_structs[ 0 ].turn_on_notify = level.nuked_perks[ 0 ].turn_on_notify;
		if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
		{
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
		}
		level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_revive_structs[ 0 ];
		/*
/#
		level.random_revive_structs[ 0 ] thread draw_debug_location();
#/
		*/
		random_perk_structs = [];
		perk_structs = getstructarray( "zm_random_machine", "script_noteworthy" );
		perk_structs = array_exclude( perk_structs, revive_perk_structs );
		for ( i = 0; i < perk_structs.size; i++ )
		{
			random_perk_structs[ i ] = getstruct( perk_structs[ i ].target, "targetname" );
			random_perk_structs[ i ].script_int = perk_structs[ i ].script_int;
		}
		level.random_perk_structs = array_randomize( random_perk_structs );
		for ( i = 1; i < 5; i++ )
		{
			level.random_perk_structs[ i ].targetname = "zm_perk_machine_override";
			level.random_perk_structs[ i ].model = level.nuked_perks[ i ].model;
			level.random_perk_structs[ i ].blocker_model = getent( level.random_perk_structs[ i ].target, "targetname" );
			level.random_perk_structs[ i ].script_noteworthy = level.nuked_perks[ i ].script_noteworthy;
			level.random_perk_structs[ i ].turn_on_notify = level.nuked_perks[ i ].turn_on_notify;
			if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
			{
				level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
			}
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_perk_structs[ i ];
			/*
/#
			level.random_perk_structs[ i ] thread draw_debug_location();
#/
			*/
		}
		return;
	}
	level.override_perk_targetname = "zm_perk_machine_override";
	random_perk_structs = [];
	perk_structs = getstructarray( "zm_random_machine", "script_noteworthy" );
	for ( i = 0; i < perk_structs.size; i++ )
	{
		random_perk_structs[ i ] = getstruct( perk_structs[ i ].target, "targetname" );
		random_perk_structs[ i ].script_int = perk_structs[ i ].script_int;
	}
	level.random_perk_structs = array_randomize( random_perk_structs );
	for ( i = 0; i < 5; i++ )
	{
		level.random_perk_structs[ i ].targetname = "zm_perk_machine_override";
		level.random_perk_structs[ i ].model = level.nuked_perks[ i ].model;
		level.random_perk_structs[ i ].blocker_model = getent( level.random_perk_structs[ i ].target, "targetname" );
		level.random_perk_structs[ i ].script_noteworthy = level.nuked_perks[ i ].script_noteworthy;
		level.random_perk_structs[ i ].turn_on_notify = level.nuked_perks[ i ].turn_on_notify;
		if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
		{
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
		}
		level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_perk_structs[ i ];
		/*
/#
		level.random_perk_structs[ i ] thread draw_debug_location();
#/
		*/
	}
}

draw_debug_location() //checked matches cerberus output
{
}

wait_for_round_range( start_round, end_round ) //checked matches cerberus output
{
	round_to_spawn = randomintrange( start_round, end_round );
	while ( level.round_number < round_to_spawn )
	{
		wait 1;
	}
}

bring_random_perk( machines, machine_triggers ) //checked matches cerberus output
{
	count = machines.size;
	if ( count <= 0 )
	{
		return;
	}
	index = randomintrange( 0, count );
	bring_perk( machines[ index ], machine_triggers[ index ] );
	arrayremoveindex( machines, index );
	arrayremoveindex( machine_triggers, index );
}

bring_perk( machine, trigger ) //checked changed to match cerberus output
{
	players = get_players();
	is_doubletap = 0;
	is_sleight = 0;
	is_revive = 0;
	is_jugger = 0;
	flag_waitopen( "perk_vehicle_bringing_in_perk" );
	playsoundatposition( "zmb_perks_incoming_quad_front", ( 0, 0, 0 ) );
	playsoundatposition( "zmb_perks_incoming_alarm", ( -2198, 486, 327 ) );
	machine setclientfield( "clientfield_perk_intro_fx", 1 );
	machine.fx = spawn( "script_model", machine.origin );
	machine.fx playloopsound( "zmb_perks_incoming_loop", 6 );
	machine.fx thread perk_incoming_sound();
	machine.fx.angles = machine.angles;
	machine.fx setmodel( "tag_origin" );
	machine.fx linkto( machine );
	machine linkto( level.perk_arrival_vehicle, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	start_node = getvehiclenode( "perk_arrival_path_" + machine.script_int, "targetname" );
	/*
/#
	level.perk_arrival_vehicle thread draw_debug_location();
#/
	*/
	level.perk_arrival_vehicle perk_follow_path( start_node );
	machine unlink();
	offset = ( 0, 0, 0 );
	if ( issubstr( machine.targetname, "doubletap" ) )
	{
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 20 );
		is_doubletap = 1;
	}
	else if ( issubstr( machine.targetname, "sleight" ) )
	{
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 5 );
		is_sleight = 1;
	}
	else if ( issubstr( machine.targetname, "revive" ) )
	{
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		trigger.blocker_model hide();
		is_revive = 1;
	}
	else if ( issubstr( machine.targetname, "jugger" ) )
	{
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		is_jugger = 1;
	}
	if ( !is_revive )
	{
		trigger.blocker_model delete();
	}
	machine.original_pos += ( offset[ 0 ], offset[ 1 ], 0 );
	machine.origin = machine.original_pos;
	machine.angles = machine.original_angles;
	if ( is_revive )
	{
		level.quick_revive_final_pos = machine.origin;
		level.quick_revive_final_angles = machine.angles;
	}
	machine.fx stoploopsound( 0.5 );
	machine setclientfield( "clientfield_perk_intro_fx", 0 );
	playsoundatposition( "zmb_perks_incoming_land", machine.origin );
	trigger trigger_on();
	machine thread bring_perk_landing_damage();
	machine.fx unlink();
	machine.fx delete();
	machine notify( machine.turn_on_notify );
	level notify( machine.turn_on_notify );
	machine vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
	machine playsound( "zmb_perks_power_on" );
	machine maps/mp/zombies/_zm_perks::perk_fx( undefined, 1 );
	if ( is_revive )
	{
		level.revive_machine_spawned = 1;
		machine thread maps/mp/zombies/_zm_perks::perk_fx( "revive_light" );
	}
	else if ( is_jugger )
	{
		machine thread maps/mp/zombies/_zm_perks::perk_fx( "jugger_light" );
	}
	else if ( is_doubletap )
	{
		machine thread maps/mp/zombies/_zm_perks::perk_fx( "doubletap_light" );
	}
	else if ( is_sleight )
	{
		machine thread maps/mp/zombies/_zm_perks::perk_fx( "sleight_light" );
	}
}

perk_incoming_sound() //checked matches cerberus output
{
	self endon( "death" );
	wait 10;
	self playsound( "zmb_perks_incoming" );
}

bring_perk_landing_damage() //checked partially changed to match cerberus output see info.md No. 2
{
	player_prone_damage_radius = 300;
	earthquake( 0.7, 2.5, self.origin, 1000 );
	radiusdamage( self.origin, player_prone_damage_radius, 10, 5, undefined, "MOD_EXPLOSIVE" );
	exploder( 500 + self.script_int );
	exploder( 511 );
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( distancesquared( players[ i ].origin, self.origin ) <= ( player_prone_damage_radius * player_prone_damage_radius ) )
		{
			players[ i ] setstance( "prone" );
			players[ i ] shellshock( "default", 1.5 );
			radiusdamage( players[ i ].origin, player_prone_damage_radius / 2, 10, 5, undefined, "MOD_EXPLOSIVE" );
		}
	}
	zombies = getaiarray( level.zombie_team );
	for ( i = 0; i < zombies.size; i++ )
	{
		zombie = zombies[ i ];
		if ( !isDefined( zombie ) || !isalive( zombie ) )
		{
		}
		else
		{
			if ( distancesquared( zombie.origin, self.origin ) > 250000 )
			{
			}
			else
			{
				zombie thread perk_machine_knockdown_zombie( self.origin );
			}
		}
	}
}

perk_machine_knockdown_zombie( origin ) //checked matches cerberus output
{
	self.a.gib_ref = random( array( "guts", "right_arm", "left_arm" ) );
	self thread maps/mp/animscripts/zm_death::do_gib();
	level.zombie_total++;
	level.zombie_total_subtract++;
	self dodamage( self.health + 100, origin );
}

perk_follow_path( node ) //checked matches cerberus output
{
	flag_set( "perk_vehicle_bringing_in_perk" );
	self notify( "newpath" );
	if ( isDefined( node ) )
	{
		self.attachedpath = node;
	}
	pathstart = self.attachedpath;
	self.currentnode = self.attachedpath;
	if ( !isDefined( pathstart ) )
	{
		return;
	}
	self attachpath( pathstart );
	self startpath();
	self waittill( "reached_end_node" );
	flag_clear( "perk_vehicle_bringing_in_perk" );
}

turn_perks_on() //checked matches cerberus output
{
	wait 3;
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
}

perks_from_the_sky() //checked matches cerberus output
{
	level thread turn_perks_on();
	top_height = 8000;
	machines = [];
	machine_triggers = [];
	machines[ 0 ] = getent( "vending_revive", "targetname" );
	if ( !isDefined( machines[ 0 ] ) )
	{
		return;
	}
	machine_triggers[ 0 ] = getent( "vending_revive", "target" );
	move_perk( machines[ 0 ], top_height, 5, 0.001 );
	machine_triggers[ 0 ] trigger_off();
	machines[ 1 ] = getent( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = getent( "vending_doubletap", "target" );
	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();
	machines[ 2 ] = getent( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = getent( "vending_sleight", "target" );
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();
	machines[ 3 ] = getent( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = getent( "vending_jugg", "target" );
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();
	machine_triggers[ 4 ] = getent( "specialty_weapupgrade", "script_noteworthy" );
	machines[ 4 ] = getent( machine_triggers[ 4 ].target, "targetname" );
	move_perk( machines[ 4 ], top_height, 5, 0.001 );
	machine_triggers[ 4 ] trigger_off();
	flag_wait( "initial_blackscreen_passed" );
	wait randomfloatrange( 5, 15 );
	players = get_players();
	if ( players.size == 1 )
	{
		wait 4;
		index = 0;
		bring_perk( machines[ index ], machine_triggers[ index ] );
		arrayremoveindex( machines, index );
		arrayremoveindex( machine_triggers, index );
	}
	wait_for_round_range( 3, 5 );
	wait randomintrange( 30, 60 );
	bring_random_perk( machines, machine_triggers );
	wait_for_round_range( 6, 9 );
	wait randomintrange( 30, 60 );
	bring_random_perk( machines, machine_triggers );
	wait_for_round_range( 10, 14 );
	wait randomintrange( 60, 120 );
	bring_random_perk( machines, machine_triggers );
	wait_for_round_range( 15, 19 );
	wait randomintrange( 60, 120 );
	bring_random_perk( machines, machine_triggers );
	wait_for_round_range( 20, 25 );
	wait randomintrange( 60, 120 );
	bring_random_perk( machines, machine_triggers );
}

move_perk( ent, dist, time, accel ) //checked matches cerberus output 
{
	ent.original_pos = ent.origin;
	ent.original_angles = ent.angles;
	pos = ( ent.origin[ 0 ], ent.origin[ 1 ], ent.origin[ 2 ] + dist );
	ent moveto( pos, time, accel, accel );
}
