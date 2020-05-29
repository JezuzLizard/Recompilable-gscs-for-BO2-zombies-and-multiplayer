#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
	maps/mp/mp_hijacked_fx::main();
	precachemodel( "collision_physics_64x64x10" );
	precachemodel( "collision_physics_wall_64x64x10" );
	precachemodel( "collision_physics_cylinder_32x128" );
	precachemodel( "collision_clip_64x64x10" );
	maps/mp/_load::main();
	maps/mp/mp_hijacked_amb::main();
	if ( level.gametype == "dm" )
	{
		spawn( "mp_dm_spawn", ( 82, 262, -135,5 ), 0, 187, 0 );
		spawn( "mp_dm_spawn", ( 783,5, 90, 58 ), 0, 198, 0 );
		spawn( "mp_dm_spawn", ( 1103,5, -187,5, 192 ), 0, 165, 0 );
		spawn( "mp_dm_spawn", ( -3012, -178, -136 ), 0, 335, 0 );
		spawn( "mp_dm_spawn", ( -3016, 176, -136 ), 0, 28, 0 );
		spawn( "mp_dm_spawn", ( -1022,5, -109,5, -136 ), 0, 5, 0 );
		spawn( "mp_dm_spawn", ( -874, 661, -14 ), 0, 5, 0 );
		spawn( "mp_dm_spawn", ( -1048, -333, 201 ), 0, 69, 0 );
		spawn( "mp_dm_spawn", ( -1462,5, 169,5, -8 ), 0, 48, 0 );
	}
	if ( level.gametype == "tdm" )
	{
		spawn( "mp_tdm_spawn", ( 82, 262, -135,5 ), 0, 187, 0 );
		spawn( "mp_tdm_spawn", ( 783,5, 90, 58 ), 0, 198, 0 );
		spawn( "mp_tdm_spawn", ( 1103,5, -187,5, 192 ), 0, 165, 0 );
		spawn( "mp_tdm_spawn", ( -3012, -178, -136 ), 0, 335, 0 );
		spawn( "mp_tdm_spawn", ( -3016, 176, -136 ), 0, 28, 0 );
		spawn( "mp_tdm_spawn", ( -1022,5, -109,5, -136 ), 0, 5, 0 );
		spawn( "mp_tdm_spawn", ( -874, 661, -14 ), 0, 5, 0 );
		spawn( "mp_tdm_spawn", ( -1048, -333, 201 ), 0, 69, 0 );
		spawn( "mp_tdm_spawn", ( -1462,5, 169,5, -8 ), 0, 48, 0 );
	}
	if ( level.gametype == "conf" )
	{
		spawn( "mp_tdm_spawn", ( 82, 262, -135,5 ), 0, 187, 0 );
		spawn( "mp_tdm_spawn", ( 783,5, 90, 58 ), 0, 198, 0 );
		spawn( "mp_tdm_spawn", ( 1103,5, -187,5, 192 ), 0, 165, 0 );
		spawn( "mp_tdm_spawn", ( -3012, -178, -136 ), 0, 335, 0 );
		spawn( "mp_tdm_spawn", ( -3016, 176, -136 ), 0, 28, 0 );
		spawn( "mp_tdm_spawn", ( -1022,5, -109,5, -136 ), 0, 5, 0 );
		spawn( "mp_tdm_spawn", ( -874, 661, -14 ), 0, 5, 0 );
		spawn( "mp_tdm_spawn", ( -1048, -333, 201 ), 0, 69, 0 );
		spawn( "mp_tdm_spawn", ( -1462,5, 169,5, -8 ), 0, 48, 0 );
	}
	if ( level.gametype == "ctf" )
	{
		spawn( "mp_ctf_spawn_axis", ( 82, 262, -135,5 ), 0, 187, 0 );
		spawn( "mp_ctf_spawn_axis", ( 249, 682, 48 ), 0, 183, 0 );
		spawn( "mp_ctf_spawn_axis", ( 1103,5, -187,5, 192 ), 0, 165, 0 );
		spawn( "mp_ctf_spawn_allies", ( -1022,5, -109,5, -136 ), 0, 5, 0 );
		spawn( "mp_ctf_spawn_allies", ( -874, 661, -14 ), 0, 5, 0 );
		spawn( "mp_ctf_spawn_allies", ( -1462,5, 169,5, -8 ), 0, 48, 0 );
	}
	if ( level.gametype == "dom" )
	{
		spawn( "mp_dom_spawn", ( 82, 262, -135,5 ), 0, 187, 0 );
		spawn( "mp_dom_spawn", ( 249, 682, 48 ), 0, 183, 0 );
		spawn( "mp_dom_spawn", ( 1103,5, -187,5, 192 ), 0, 165, 0 );
		spawn( "mp_dom_spawn", ( -1022,5, -109,5, -136 ), 0, 5, 0 );
		spawn( "mp_dom_spawn", ( -874, 661, -14 ), 0, 5, 0 );
		spawn( "mp_dom_spawn", ( -1462,5, 169,5, -8 ), 0, 48, 0 );
		spawn( "mp_dom_spawn", ( -1048, -333, 201 ), 0, 69, 0 );
	}
	if ( level.gametype == "dem" )
	{
		spawn( "mp_dem_spawn_attacker", ( 1103,5, -187,5, 192 ), 0, 165, 0 );
		spawn( "mp_dem_spawn_attacker", ( 783,5, 90, 58 ), 0, 198, 0 );
	}
	maps/mp/_compass::setupminimap( "compass_map_mp_hijacked" );
	spawncollision( "collision_physics_64x64x10", "collider", ( 1660, 40, 59 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( 1633, 40, 48 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( 1660, -42, 59 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( 1632, -42, 48 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( 904, 18, 53 ), ( 0, 270, -90 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( 904, 91, 90 ), ( 0, 270, -90 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1055, 10, 216 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_clip_64x64x10", "collider", ( -1912,65, -245, -76,3463 ), vectorScale( ( 0, 0, 1 ), 282 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -1064, 412, 254 ), vectorScale( ( 0, 0, 1 ), 342,8 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -1112, 416,5, 284 ), vectorScale( ( 0, 0, 1 ), 316,3 ) );
	level.levelkothdisable = [];
	level.levelkothdisable[ level.levelkothdisable.size ] = spawn( "trigger_radius", ( 402, 181,5, 35 ), 0, 70, 128 );
	level.levelkothdisable[ level.levelkothdisable.size ] = spawn( "trigger_radius", ( -96, 320, 34 ), 0, 150, 80 );
	level thread water_trigger_init();
	if ( level.gametype == "koth" )
	{
		trigs = getentarray( "koth_zone_trigger", "targetname" );
		_a138 = trigs;
		_k138 = getFirstArrayKey( _a138 );
		while ( isDefined( _k138 ) )
		{
			trigger = _a138[ _k138 ];
			if ( trigger.origin == ( -239, 86, -83 ) )
			{
				trigger delete();
				break;
			}
			else
			{
				_k138 = getNextArrayKey( _a138, _k138 );
			}
		}
		trigger = spawn( "trigger_box", ( -204, 92, -128 ), 1, 2088, 504, 160 );
		trigger.targetname = "koth_zone_trigger";
	}
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1600", reset_dvars );
	ss.dead_friend_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_radius", "1400", reset_dvars );
	ss.dead_friend_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_timeout_seconds", "8", reset_dvars );
	ss.dead_friend_influencer_count = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_count", "10", reset_dvars );
	ss.enemy_spawned_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_timeout_seconds", "12", reset_dvars );
	ss.dom_unowned_flag_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dom_unowned_flag_influencer_radius", "1200", reset_dvars );
	ss.dom_unowned_flag_influencer_score = set_dvar_float_if_unset( "scr_spawn_dom_unowned_flag_influencer_score", "-25", reset_dvars );
	ss.dom_enemy_flag_influencer_radius[ 0 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_A_influencer_radius", "1200", reset_dvars );
}

water_trigger_init()
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	_a176 = triggers;
	_k176 = getFirstArrayKey( _a176 );
	while ( isDefined( _k176 ) )
	{
		trigger = _a176[ _k176 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k176 = getNextArrayKey( _a176, _k176 );
	}
	triggers = getentarray( "water_killbrush", "targetname" );
	_a188 = triggers;
	_k188 = getFirstArrayKey( _a188 );
	while ( isDefined( _k188 ) )
	{
		trigger = _a188[ _k188 ];
		trigger thread player_splash_think();
		_k188 = getNextArrayKey( _a188, _k188 );
	}
}

player_splash_think()
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isplayer( entity ) && isalive( entity ) )
		{
			self thread trigger_thread( entity, ::player_water_fx );
		}
	}
}

player_water_fx( player, endon_condition )
{
	maxs = self.origin + self getmaxs();
	if ( maxs[ 2 ] > 60 )
	{
		maxs += vectorScale( ( 0, 0, 1 ), 10 );
	}
	origin = ( player.origin[ 0 ], player.origin[ 1 ], maxs[ 2 ] );
	playfx( level._effect[ "water_splash_sm" ], origin );
}

water_trigger_think()
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isplayer( entity ) )
		{
			entity playsound( "mpl_splash_death" );
			playfx( level._effect[ "water_splash" ], entity.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
		}
	}
}

leveloverridetime( defaulttime )
{
	if ( self isinwater() )
	{
		return 0,4;
	}
	return defaulttime;
}

useintermissionpointsonwavespawn()
{
	return self isinwater();
}

isinwater()
{
	triggers = getentarray( "trigger_hurt", "classname" );
	_a253 = triggers;
	_k253 = getFirstArrayKey( _a253 );
	while ( isDefined( _k253 ) )
	{
		trigger = _a253[ _k253 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			if ( self istouching( trigger ) )
			{
				return 1;
			}
		}
		_k253 = getNextArrayKey( _a253, _k253 );
	}
	return 0;
}
