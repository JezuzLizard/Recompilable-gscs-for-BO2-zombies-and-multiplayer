#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level thread spawnkilltrigger();
	maps/mp/mp_frostbite_fx::main();
	precachemodel( "dh_facilities_sign_08" );
	precachemodel( "p6_fro_concrete_planter" );
	precachemodel( "p6_fro_bookstore_window_trm" );
	precachemodel( "collision_clip_256x256x10" );
	precachemodel( "collision_clip_64x64x10" );
	precachemodel( "collision_physics_256x256x10" );
	precachemodel( "collision_clip_32x32x32" );
	precachemodel( "collision_clip_128x128x10" );
	precachemodel( "collision_clip_wall_32x32x10" );
	precachemodel( "collision_clip_wall_64x64x10" );
	precachemodel( "collision_mp_frost_kitchen_weap" );
	maps/mp/_load::main();
	maps/mp/mp_frostbite_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_frostbite" );
	prop1 = spawn( "script_model", ( -972, 559, 182 ) );
	prop1.angles = vectorScale( ( 0, 0, 1 ), 90 );
	prop2 = spawn( "script_model", ( -973, 521, 182 ) );
	prop2.angles = vectorScale( ( 0, 0, 1 ), 90 );
	prop3 = spawn( "script_model", ( -972, 485, 182 ) );
	prop3.angles = vectorScale( ( 0, 0, 1 ), 90 );
	prop4 = spawn( "script_model", ( -966, 558, 182 ) );
	prop4.angles = vectorScale( ( 0, 0, 1 ), 270 );
	prop5 = spawn( "script_model", ( -965, 522, 182 ) );
	prop5.angles = vectorScale( ( 0, 0, 1 ), 270 );
	prop6 = spawn( "script_model", ( -966, 484, 182 ) );
	prop6.angles = vectorScale( ( 0, 0, 1 ), 270 );
	prop1 setmodel( "dh_facilities_sign_08" );
	prop2 setmodel( "dh_facilities_sign_08" );
	prop3 setmodel( "dh_facilities_sign_08" );
	prop4 setmodel( "dh_facilities_sign_08" );
	prop5 setmodel( "dh_facilities_sign_08" );
	prop6 setmodel( "dh_facilities_sign_08" );
	planter1 = spawn( "script_model", ( -1609, -827,405, 131,751 ) );
	planter1.angles = ( 359,846, 90,58, 89,9993 );
	planter2 = spawn( "script_model", ( -1609, -827,41, 81,75 ) );
	planter2.angles = ( 359,846, 90,58, 89,9993 );
	planter1 setmodel( "p6_fro_concrete_planter" );
	planter2 setmodel( "p6_fro_concrete_planter" );
	brick1 = spawn( "script_model", ( 1129, 703, 95,75 ) );
	brick1.angles = ( 90, 180, -90 );
	brick2 = spawn( "script_model", ( 1127,75, 712, 95,75 ) );
	brick2.angles = ( 90, 180, -90 );
	brick3 = spawn( "script_model", ( 1129, 703, 47,75 ) );
	brick3.angles = ( 90, 180, -90 );
	brick4 = spawn( "script_model", ( 1127,75, 712, 47,75 ) );
	brick4.angles = ( 90, 180, -90 );
	brick5 = spawn( "script_model", ( 1129, 694, 95,75 ) );
	brick5.angles = ( 90, 180, -90 );
	brick6 = spawn( "script_model", ( 1129, 694, 47,75 ) );
	brick6.angles = ( 90, 180, -90 );
	brick7 = spawn( "script_model", ( 1129, 685, 95,75 ) );
	brick7.angles = ( 90, 180, -90 );
	brick8 = spawn( "script_model", ( 1129, 685, 47,75 ) );
	brick8.angles = ( 90, 180, -90 );
	brick1 setmodel( "p6_fro_bookstore_window_trm" );
	brick2 setmodel( "p6_fro_bookstore_window_trm" );
	brick3 setmodel( "p6_fro_bookstore_window_trm" );
	brick4 setmodel( "p6_fro_bookstore_window_trm" );
	brick5 setmodel( "p6_fro_bookstore_window_trm" );
	brick6 setmodel( "p6_fro_bookstore_window_trm" );
	brick7 setmodel( "p6_fro_bookstore_window_trm" );
	brick8 setmodel( "p6_fro_bookstore_window_trm" );
	spawncollision( "collision_clip_256x256x10", "collider", ( 145, -1295,5, 115,5 ), vectorScale( ( 0, 0, 1 ), 88,9 ) );
	spawncollision( "collision_clip_256x256x10", "collider", ( 28, -1295,5, 115,5 ), vectorScale( ( 0, 0, 1 ), 88,9 ) );
	spawncollision( "collision_clip_256x256x10", "collider", ( 252,5, -1251,5, 114 ), ( 0, 45,1, -88,9 ) );
	spawncollision( "collision_clip_64x64x10", "collider", ( 448, 1577, -10,5 ), vectorScale( ( 0, 0, 1 ), 277 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 1199, 89, 67,5 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 84,5, 361,75, 66,5 ), ( 359,904, 8,05247, 11,9159 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 80, 390, 69,5 ), vectorScale( ( 0, 0, 1 ), 9,19998 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 75,5, 418, 66,75 ), ( 1,00357, 9,19998, -11 ) );
	spawncollision( "collision_clip_128x128x10", "collider", ( 244,75, -860, -45 ), vectorScale( ( 0, 0, 1 ), 27 ) );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( 958,5, 716,5, 130 ), vectorScale( ( 0, 0, 1 ), 5,6 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -1126, -909, 44,5 ), vectorScale( ( 0, 0, 1 ), 105,6 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -1130, -789,5, 44,5 ), vectorScale( ( 0, 0, 1 ), 83,9 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -1130, -789,5, 107 ), vectorScale( ( 0, 0, 1 ), 83,9 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -1126, -909, 106 ), vectorScale( ( 0, 0, 1 ), 105,6 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -1130, -789,5, 164,5 ), vectorScale( ( 0, 0, 1 ), 83,9 ) );
	spawncollision( "collision_mp_frost_kitchen_weap", "collider", ( 1994, -281,5, 16 ), ( 0, 0, 1 ) );
	setdvar( "compassmaxrange", "2100" );
	visionsetnaked( "mp_frostbite", 1 );
	game[ "strings" ][ "war_callsign_a" ] = &"MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings" ][ "war_callsign_b" ] = &"MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings" ][ "war_callsign_c" ] = &"MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings" ][ "war_callsign_d" ] = &"MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings" ][ "war_callsign_e" ] = &"MPUI_CALLSIGN_MAPNAME_E";
	game[ "strings_menu" ][ "war_callsign_a" ] = "@MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings_menu" ][ "war_callsign_b" ] = "@MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings_menu" ][ "war_callsign_c" ] = "@MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings_menu" ][ "war_callsign_d" ] = "@MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings_menu" ][ "war_callsign_e" ] = "@MPUI_CALLSIGN_MAPNAME_E";
	level.onplayerkilledextraunthreadedcbs[ level.onplayerkilledextraunthreadedcbs.size ] = ::on_player_killed;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level glass_node_fix();
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2250", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
}

on_player_killed( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( isDefined( smeansofdeath ) && smeansofdeath == "MOD_TRIGGER_HURT" )
	{
		depth = self depthinwater();
		if ( depth > 0 )
		{
			origin = self.origin + ( 0, 0, depth + 5 );
			self playsound( "mpl_splash_death" );
			playfx( level._effect[ "water_splash" ], origin );
		}
	}
}

leveloverridetime( defaulttime )
{
	if ( self.body depthinwater() > 0 )
	{
		return 0,4;
	}
	return defaulttime;
}

glass_node_fix()
{
	nodes = getallnodes();
	level thread glass_node_think( nodes[ 459 ] );
	level thread glass_node_think( nodes[ 454 ] );
}

glass_node_think( node )
{
	wait 0,25;
	ent = spawn( "script_model", node.origin, 1 );
	ent setmodel( level.deployedshieldmodel );
	ent hide();
	ent disconnectpaths();
	ent.origin -= vectorScale( ( 0, 0, 1 ), 64 );
	for ( ;; )
	{
		level waittill( "glass_smash", origin );
		if ( distancesquared( origin, node.origin ) < 65536 )
		{
			ent delete();
			return;
		}
	}
}

spawnkilltrigger()
{
	trigger = spawn( "trigger_radius", ( 536, -1304, -104 ), 0, 256, 128 );
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		player dodamage( player.health * 2, trigger.origin, trigger, trigger, "none", "MOD_SUICIDE", 0, "lava_mp" );
	}
}
