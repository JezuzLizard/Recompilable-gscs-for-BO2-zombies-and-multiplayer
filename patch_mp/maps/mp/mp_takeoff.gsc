#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include common_scripts/utility;
#include maps/mp/_events;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
	maps/mp/mp_takeoff_fx::main();
	precachemodel( "collision_nosight_wall_64x64x10" );
	precachemodel( "collision_clip_wall_128x128x10" );
	precachemodel( "collision_mp_takeoff_solar_weap" );
	maps/mp/_load::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_takeoff" );
	setdvar( "compassmaxrange", "2100" );
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
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -915, 790, 212 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -979, 790, 212 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -1043, 790, 212 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -1083, 790, 212 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -915, 790, 148 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -979, 790, 148 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -1043, 790, 148 ), ( 0, 0, 1 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -1083, 790, 148 ), ( 0, 0, 1 ) );
	spawncollision( "collision_clip_wall_128x128x10", "collider", ( 136, 2511, 245,5 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_mp_takeoff_solar_weap", "collider", ( 580, 3239,5, 32,5 ), ( 0, 0, 1 ) );
	maps/mp/gametypes/_spawning::level_use_unified_spawning( 1 );
	level thread dog_jump_think();
	level.disableoutrovisionset = 1;
	level.mptakeoffrocket = getent( "takeoff_rocket", "targetname" );
/#
	assert( isDefined( level.mptakeoffrocket ), "Unable to find entity with targetname: 'takeoff_rocket'" );
#/
	level.endgamefunction = ::takeoff_end_game;
	level.preendgamefunction = ::takeoff_pre_end_game;
	level thread setuprocketcamera();
/#
	execdevgui( "devgui_mp_takeoff" );
	level thread watchdevnotify();
	level thread devgui_endgame();
#/
}

dog_jump_think()
{
	origin = ( 209, 3819, 91 );
	trigger = spawn( "trigger_box", origin, getaitriggerflags(), 64, 32, 64 );
	trigger setexcludeteamfortrigger( "none" );
	for ( ;; )
	{
		trigger waittill( "trigger", entity );
		if ( isai( entity ) )
		{
			glassradiusdamage( origin, 64, 5001, 5000 );
			trigger delete();
			return;
		}
	}
}

setuprocketcamera()
{
	wait 0,1;
	getrocketcamera();
}

getrocketcamera()
{
	camerastruct = getstruct( "endgame_first_camera", "targetname" );
/#
	assert( isDefined( camerastruct ), "Unable to find entity with targetname: 'endgame_first_camera'" );
#/
	if ( !isDefined( level.rocketcamera ) )
	{
		level.rocketcamera = spawn( "script_model", camerastruct.origin );
		level.rocketcamera setmodel( "tag_origin" );
	}
	else
	{
		level.rocketcamera.origin = camerastruct.origin;
	}
	level.rocketcamera.angles = camerastruct.angles;
	return level.rocketcamera;
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2300", reset_dvars );
}

watchdevnotify()
{
/#
	startvalue = 0;
	setdvarint( "scr_takeoff_rocket", startvalue );
	for ( ;; )
	{
		takeoff_rocket = getDvarInt( #"12AE1013" );
		if ( takeoff_rocket != startvalue )
		{
			level notify( "dev_takeoff_rocket" );
			startvalue = takeoff_rocket;
		}
		wait 0,2;
#/
	}
}

devgui_endgame()
{
/#
	rocket = level.mptakeoffrocket;
	assert( isDefined( rocket ), "Unable to find entity with targetname: 'takeoff_rocket'" );
	rocketorigin = rocket.origin;
	rocketangles = rocket.angles;
	rocketmodel = rocket.model;
	for ( ;; )
	{
		level waittill( "dev_takeoff_rocket" );
		visionsetnaked( "blackout", 0,1 );
		thread takeoff_pre_end_game();
		wait 1;
		visionsetnaked( "mp_takeoff", 0,1 );
		thread takeoff_end_game();
		wait 4,5;
		level notify( "debug_end_takeoff" );
		wait 1;
		visionsetnaked( "mp_takeoff", 0,1 );
		i = 0;
		while ( i < level.players.size )
		{
			player = level.players[ i ];
			player cameraactivate( 0 );
			i++;
		}
		stop_exploder( 1001 );
		rocket delete();
		rocket = spawn( "script_model", rocketorigin );
		rocket.angles = rocketangles;
		rocket setmodel( rocketmodel );
		level.mptakeoffrocket = rocket;
#/
	}
}

water_trigger_init()
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	_a206 = triggers;
	_k206 = getFirstArrayKey( _a206 );
	while ( isDefined( _k206 ) )
	{
		trigger = _a206[ _k206 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k206 = getNextArrayKey( _a206, _k206 );
	}
	triggers = getentarray( "water_killbrush", "targetname" );
	_a218 = triggers;
	_k218 = getFirstArrayKey( _a218 );
	while ( isDefined( _k218 ) )
	{
		trigger = _a218[ _k218 ];
		trigger thread player_splash_think();
		_k218 = getNextArrayKey( _a218, _k218 );
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
	_a283 = triggers;
	_k283 = getFirstArrayKey( _a283 );
	while ( isDefined( _k283 ) )
	{
		trigger = _a283[ _k283 ];
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
		_k283 = getNextArrayKey( _a283, _k283 );
	}
	return 0;
}

takeoff_pre_end_game( timetillendgame, debug )
{
	if ( !isDefined( debug ) )
	{
		level waittill( "play_final_killcam" );
		wait 10;
	}
	rocket = level.mptakeoffrocket;
/#
	assert( isDefined( rocket ), "Unable to find entity with targetname: 'takeoff_rocket'" );
#/
	rocket rocket_thrusters_initialize();
}

takeoff_end_game()
{
/#
	level endon( "debug_end_takeoff" );
#/
	level.rocket_camera = 0;
	rocket = level.mptakeoffrocket;
	rocket playsound( "evt_shuttle_launch" );
/#
	assert( isDefined( rocket ), "Unable to find entity with targetname: 'takeoff_rocket'" );
#/
	rocket rocket_thrusters_initialize();
	cameraone = getrocketcamera();
	cameraone thread vibrateaftertime( getdvarfloatdefault( "mp_takeoff_shakewait", 0,5 ) );
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		player camerasetposition( cameraone );
		player camerasetlookat();
		player cameraactivate( 1 );
		player setdepthoffield( 0, 0, 512, 512, 4, 0 );
		i++;
	}
	level.rocket_camera = 1;
	rocket thread rocket_move();
	wait 4;
	visionsetnaked( "blackout", getdvarfloatdefault( "mp_takeoff_fade_black", 0,5 ) );
}

rocket_thrusters_initialize()
{
	if ( !isDefined( self.thrustersinited ) )
	{
		self.thrustersinited = 1;
		exploder( 1001 );
		playfxontag( level._effect[ "fx_mp_tak_shuttle_thruster_lg" ], self, "tag_fx" );
		playfxontag( level._effect[ "fx_mp_tak_shuttle_thruster_sm" ], self, "tag_fx5" );
		playfxontag( level._effect[ "fx_mp_tak_shuttle_thruster_md" ], self, "tag_fx6" );
		playfxontag( level._effect[ "fx_mp_tak_shuttle_thruster_sm" ], self, "tag_fx7" );
	}
}

rocket_move()
{
	origin = self.origin;
	heightincrease = getdvarintdefault( "mp_takeoff_rocket_start_height", 0 );
	self.origin += ( 0, 0, heightincrease );
	movetime = getdvarintdefault( "mp_takeoff_moveTime", 17 );
	moveaccelratio = getdvarfloatdefault( "mp_takeoff_moveAccel", 1 );
	self moveto( self.origin + vectorScale( ( 0, 0, 1 ), 50000 ), movetime, movetime * moveaccelratio );
	self waittill( "movedone" );
	origin = self.origin;
}

vibrateaftertime( waittime )
{
	self endon( "death" );
/#
	level endon( "debug_end_takeoff" );
#/
	wait waittime;
	pitchvibrateamplitude = getdvarfloatdefault( "mp_takeoff_start", 0,1 );
	vibrateamplitude = getdvarfloatdefault( "mp_takeoff_a_start", 0,1 );
	vibratetime = 0,05;
	originalangles = self.angles;
	for ( ;; )
	{
		angles0 = ( originalangles[ 0 ] - pitchvibrateamplitude, originalangles[ 1 ], originalangles[ 2 ] - vibrateamplitude );
		angles1 = ( originalangles[ 0 ] + pitchvibrateamplitude, originalangles[ 1 ], originalangles[ 2 ] + vibrateamplitude );
		self rotateto( angles0, vibratetime );
		self waittill( "rotatedone" );
		self rotateto( angles1, vibratetime );
		self waittill( "rotatedone" );
		vibrateamplitude *= getdvarfloatdefault( "mp_takeoff_amp_vredux", 1,12 );
		pitchvibrateamplitude = 0 - pitchvibrateamplitude;
		pitchvibrateamplitude *= getdvarfloatdefault( "mp_takeoff_amp_predux", 1,11 );
	}
}
