#include codescripts/struct;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main_start()
{
	level thread spawned_collision_ffotd();
	level thread spawn_kill_brushes();
	level thread respawn_struct_fix();
	onplayerconnect_callback( ::one_inch_punch_take_think );
}

main_end()
{
	level thread player_spawn_fix();
	level thread update_charger_position();
	level thread traversal_blocker_disabler();
}

update_charger_position()
{
	_a26 = level.a_elemental_staffs;
	_k26 = getFirstArrayKey( _a26 );
	while ( isDefined( _k26 ) )
	{
		e_staff = _a26[ _k26 ];
		e_staff moveto( e_staff.charger.origin, 0,05 );
		_k26 = getNextArrayKey( _a26, _k26 );
	}
	_a31 = level.a_elemental_staffs_upgraded;
	_k31 = getFirstArrayKey( _a31 );
	while ( isDefined( _k31 ) )
	{
		e_staff = _a31[ _k31 ];
		e_staff moveto( e_staff.charger.origin, 0,05 );
		_k31 = getNextArrayKey( _a31, _k31 );
	}
}

spawned_collision_ffotd()
{
	precachemodel( "collision_ai_64x64x10" );
	precachemodel( "collision_wall_256x256x10_standard" );
	precachemodel( "collision_wall_512x512x10_standard" );
	precachemodel( "collision_geo_256x256x10_standard" );
	precachemodel( "collision_geo_512x512x10_standard" );
	precachemodel( "collision_geo_ramp_standard" );
	precachemodel( "collision_player_512x512x512" );
	precachemodel( "collision_geo_32x32x128_standard" );
	precachemodel( "collision_geo_64x64x128_standard" );
	precachemodel( "collision_geo_64x64x256_standard" );
	precachemodel( "collision_player_wall_256x256x10" );
	precachemodel( "collision_player_wall_512x512x10" );
	precachemodel( "collision_player_wall_32x32x10" );
	precachemodel( "collision_geo_64x64x10_standard" );
	precachemodel( "p6_zm_tm_barbedwire_tube" );
	precachemodel( "p6_zm_tm_rubble_rebar_group" );
	flag_wait( "start_zombie_round_logic" );
	m_disconnector = spawn( "script_model", ( -568, -956, 160 ), 1 );
	m_disconnector setmodel( "collision_ai_64x64x10" );
	m_disconnector.angles = vectorScale( ( 0, 0, -1 ), 35 );
	m_disconnector disconnectpaths();
	m_disconnector ghost();
	if ( isDefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
	{
		collision1a = spawn( "script_model", ( 1128, -2664,25, 122 ) );
		collision1a setmodel( "collision_player_wall_256x256x10" );
		collision1a.angles = vectorScale( ( 0, 0, -1 ), 285 );
		collision1a ghost();
		collision1b = spawn( "script_model", ( 909,5, -2856,5, -6 ) );
		collision1b setmodel( "collision_player_wall_512x512x10" );
		collision1b.angles = vectorScale( ( 0, 0, -1 ), 195 );
		collision1b ghost();
		collision1c = spawn( "script_model", ( 415, -2989, -6 ) );
		collision1c setmodel( "collision_player_wall_512x512x10" );
		collision1c.angles = vectorScale( ( 0, 0, -1 ), 195 );
		collision1c ghost();
		collision2a = spawn( "script_model", ( -6760, -6536, 280 ) );
		collision2a setmodel( "collision_geo_512x512x10_standard" );
		collision2a.angles = ( 0, 0, -1 );
		collision2a ghost();
		collision2b = spawn( "script_model", ( -6224, -6536, 280 ) );
		collision2b setmodel( "collision_geo_512x512x10_standard" );
		collision2b.angles = ( 0, 0, -1 );
		collision2b ghost();
		collision2c = spawn( "script_model", ( -5704, -6536, 280 ) );
		collision2c setmodel( "collision_geo_512x512x10_standard" );
		collision2c.angles = ( 0, 0, -1 );
		collision2c ghost();
		collision3a = spawn( "script_model", ( 1088, 4216, -192 ) );
		collision3a setmodel( "collision_geo_256x256x10_standard" );
		collision3a.angles = ( 0, 0, -1 );
		collision3a ghost();
		collision4a = spawn( "script_model", ( 545,36, -2382,3, 404 ) );
		collision4a setmodel( "collision_wall_256x256x10_standard" );
		collision4a.angles = ( 0, 293,8, 180 );
		collision4a ghost();
		collision4b = spawn( "script_model", ( 579,36, -2367,3, 264 ) );
		collision4b setmodel( "collision_geo_ramp_standard" );
		collision4b.angles = ( 0, 293,8, 180 );
		collision4b ghost();
		collision5a = spawn( "script_model", ( 67,87, -3193,25, 504 ) );
		collision5a setmodel( "collision_player_512x512x512" );
		collision5a.angles = vectorScale( ( 0, 0, -1 ), 14,1 );
		collision5a ghost();
		collision5b = spawn( "script_model", ( 292,5, -2865,5, 286 ) );
		collision5b setmodel( "collision_geo_32x32x128_standard" );
		collision5b.angles = ( 270, 22,4, 0 );
		collision5b ghost();
		collision5c = spawn( "script_model", ( 292,5, -2865,5, 266 ) );
		collision5c setmodel( "collision_geo_32x32x128_standard" );
		collision5c.angles = ( 270, 22,4, 0 );
		collision5c ghost();
		collision5d = spawn( "script_model", ( 339, -3024,5, 280 ) );
		collision5d setmodel( "collision_geo_64x64x128_standard" );
		collision5d.angles = ( 270, 18,2, 0 );
		collision5d ghost();
		model5a = spawn( "script_model", ( 248,15, -2917,26, 351,01 ) );
		model5a setmodel( "p6_zm_tm_barbedwire_tube" );
		model5a.angles = ( 6,00001, 188, 90 );
		collision6a = spawn( "script_model", ( -227,25, 4010,25, -96 ) );
		collision6a setmodel( "collision_player_wall_256x256x10" );
		collision6a.angles = vectorScale( ( 0, 0, -1 ), 265,299 );
		collision6a ghost();
		model6a = spawn( "script_model", ( -231,124, 4093,08, -230,685 ) );
		model6a setmodel( "p6_zm_tm_rubble_rebar_group" );
		model6a.angles = ( 25,883, 2,13901, 0,55601 );
		collision7a = spawn( "script_model", ( 599, -2478, 184 ) );
		collision7a setmodel( "collision_geo_64x64x128_standard" );
		collision7a.angles = ( 270, 14,7, 0 );
		collision7a ghost();
		collision8a = spawn( "script_model", ( -3190, -555, -111 ) );
		collision8a setmodel( "collision_player_wall_512x512x10" );
		collision8a.angles = vectorScale( ( 0, 0, -1 ), 1,8 );
		collision8a ghost();
		collision11a = spawn( "script_model", ( 812,812, -64,1434, 384 ) );
		collision11a setmodel( "collision_player_wall_256x256x10" );
		collision11a.angles = vectorScale( ( 0, 0, -1 ), 9,99998 );
		collision11a ghost();
		collision12a = spawn( "script_model", ( 180, 4128, 40 ) );
		collision12a setmodel( "collision_player_wall_512x512x10" );
		collision12a.angles = vectorScale( ( 0, 0, -1 ), 270 );
		collision12a ghost();
		collision13a = spawn( "script_model", ( 2088, 588, 240 ) );
		collision13a setmodel( "collision_player_wall_512x512x10" );
		collision13a.angles = ( 0, 0, -1 );
		collision13a ghost();
		collision14a = spawn( "script_model", ( -787, 375, 380 ) );
		collision14a setmodel( "collision_player_wall_256x256x10" );
		collision14a.angles = ( 0, 0, -1 );
		collision14a ghost();
		collision14b = spawn( "script_model", ( -899, 375, 236 ) );
		collision14b setmodel( "collision_player_wall_32x32x10" );
		collision14b.angles = ( 0, 0, -1 );
		collision14b ghost();
		collision15a = spawn( "script_model", ( 1704, 2969,34, -187,83 ) );
		collision15a setmodel( "collision_geo_64x64x10_standard" );
		collision15a.angles = vectorScale( ( 0, 0, -1 ), 47,4 );
		collision15a ghost();
	}
}

spawn_kill_brushes()
{
	t_killbrush_1 = spawn( "trigger_box", ( 1643, 2168, 96 ), 0, 256, 1200, 512 );
	t_killbrush_1.script_noteworthy = "kill_brush";
	t_killbrush_2 = spawn( "trigger_box", ( -1277, 892, 184 ), 0, 148, 88, 128 );
	t_killbrush_2.script_noteworthy = "kill_brush";
}

one_inch_punch_take_think()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "bled_out" );
		self.one_inch_punch_flag_has_been_init = 0;
		if ( self ent_flag_exist( "melee_punch_cooldown" ) )
		{
		}
	}
}

player_spawn_fix()
{
	s_zone_nml_18 = level.zones[ "zone_nml_18" ];
	s_zone_nml_19 = level.zones[ "zone_nml_19" ];
	add_adjacent_zone( "zone_nml_18", "zone_nml_19", "activate_zone_ruins" );
}

respawn_struct_fix()
{
	spawn1 = createstruct();
	spawn1.model = undefined;
	spawn1.origin = ( 2400, 120, 160 );
	spawn1.targetname = "nml_11_spawn_points";
	spawn1.radius = 32;
	spawn1.script_int = 1;
	spawn2 = createstruct();
	spawn2.model = undefined;
	spawn2.origin = ( 2392, 360, 160 );
	spawn2.targetname = "nml_11_spawn_points";
	spawn2.radius = 32;
	spawn2.script_int = 1;
	spawn3 = createstruct();
	spawn3.model = undefined;
	spawn3.origin = ( 2616, 152, 160 );
	spawn3.targetname = "nml_11_spawn_points";
	spawn3.radius = 32;
	spawn3.script_int = 1;
}

traversal_blocker_disabler()
{
	level endon( "activate_zone_nml" );
	pos1 = ( -1509, 3912, -168 );
	pos2 = ( 672, 3720, -179 );
	b_too_close = 0;
	while ( level.round_number < 10 && !b_too_close )
	{
		a_players = getplayers();
		_a310 = a_players;
		_k310 = getFirstArrayKey( _a310 );
		while ( isDefined( _k310 ) )
		{
			player = _a310[ _k310 ];
			if ( distancesquared( player.origin, pos1 ) < 4096 || distancesquared( player.origin, pos2 ) < 4096 )
			{
				b_too_close = 1;
			}
			_k310 = getNextArrayKey( _a310, _k310 );
		}
		wait 1;
	}
	m_traversal_blocker = getent( "traversal_blocker", "targetname" );
	m_traversal_blocker.origin += vectorScale( ( 0, 0, -1 ), 10000 );
	m_traversal_blocker connectpaths();
}
