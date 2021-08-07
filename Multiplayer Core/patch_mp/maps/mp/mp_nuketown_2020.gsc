//checked includes changed to match cerberus output
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_globallogic_defaults;
#include maps/mp/_compass;
#include maps/mp/mp_nuketown_2020_amb;
#include maps/mp/_load;
#include maps/mp/mp_nuketown_2020_fx;
#include maps/mp/_events;
#include common_scripts/utility;
#include maps/mp/_utility;

//current version of the compiler doesn't compile this correctly causing the server to crash on load
//#using_animtree( "fxanim_props" );

main() //checked matches cerberus output
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_nuketown_2020_fx::main();
	precachemodel( "collision_physics_32x32x128" );
	precachemodel( "collision_physics_32x32x32" );
	precachemodel( "collision_physics_wall_32x32x10" );
	precachemodel( "collision_clip_32x32x32" );
	precachemodel( "collision_vehicle_128x128x128" );
	precachemodel( "collision_missile_128x128x10" );
	precachemodel( "nt_2020_doorframe_black" );
	precachemodel( "collision_vehicle_32x32x10" );
	precachemodel( "collision_physics_256x256x10" );
	precachemodel( "collision_physics_cylinder_32x128" );
	precachemodel( "collision_missile_32x32x128" );
	precachemodel( "collision_physics_32x32x10" );
	precachemodel( "collision_clip_wall_64x64x10" );
	precachemodel( "collision_physics_wall_64x64x10" );
	precachemodel( "collision_physics_128x128x10" );
	maps/mp/_load::main();
	maps/mp/mp_nuketown_2020_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_nuketown_2020" );
	spawncollision( "collision_physics_32x32x128", "collider", ( 1216, 167.5, 235 ), ( 0, 3.69986, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( 1213, 227, 235 ), ( 0, 10.9, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( 1196, 315.5, 235 ), ( 0, 15.2, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( 1151.5, 427, 235 ), ( 0, 27.8, -90 ) );
	spawncollision( "collision_physics_32x32x32", "collider", ( 1109, 488, 235 ), ( 0, 46.2, -90 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 1067, 291, 240 ), vectorScale( ( 0, 1, 0 ), 14.3 ) );
	prop1 = spawn( "script_model", ( 678.485, 583.124, -91.75 ) );
	prop1.angles = ( 270, 198.902, 86.0983 );
	prop2 = spawn( "script_model", ( 705.49, 482.12, -91.75 ) );
	prop2.angles = ( 270, 198.902, 86.0983 );
	prop3 = spawn( "script_model", ( 732.49, 381.37, -91.75 ) );
	prop3.angles = ( 270, 198.902, 86.0983 );
	prop1 setmodel( "nt_2020_doorframe_black" );
	prop2 setmodel( "nt_2020_doorframe_black" );
	prop3 setmodel( "nt_2020_doorframe_black" );
	busprop1 = spawn( "script_model", ( -121.962, 53.5963, -24.241 ) );
	busprop1.angles = ( 274.162, 199.342, 86.5184 );
	busprop1 setmodel( "nt_2020_doorframe_black" );
	spawncollision( "collision_clip_32x32x32", "collider", ( 817.5, 415, 77 ), vectorScale( ( 0, 1, 0 ), 15.2 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 859, 430, 77.5 ), vectorScale( ( 0, 1, 0 ), 15.2 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 894, 439.5, 77.5 ), vectorScale( ( 0, 1, 0 ), 15.2 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 926.5, 448.5, 77.5 ), vectorScale( ( 0, 1, 0 ), 15.2 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 1257.5, 489, -68 ), vectorScale( ( 0, 1, 0 ), 15.2 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 1288.5, 497.5, -68 ), vectorScale( ( 0, 1, 0 ), 15.2 ) );
	spawncollision( "collision_missile_128x128x10", "collider", ( 570.655, 214.604, -10.5 ), vectorScale( ( 0, 1, 0 ), 284.5 ) );
	spawncollision( "collision_missile_128x128x10", "collider", ( 558.345, 260.896, -10.5 ), vectorScale( ( 0, 1, 0 ), 284.5 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -1422, 40.5, 4.5 ), vectorScale( ( 0, 1, 0 ), 72.2 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 883.75, 826.5, 195.75 ), ( 0, 263.2, -90 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 770, 824.75, 195.75 ), ( 0, 276.4, -90 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 661.25, 801, 195.75 ), ( 0, 287.4, -90 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 560.75, 751.75, 195.75 ), ( 0, 302, -90 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( 1325, 532, 14 ), vectorScale( ( 0, 1, 0 ), 14.9 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( 1369, 542.5, 14 ), vectorScale( ( 0, 1, 0 ), 14.9 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -1936, 699.5, -49 ), ( 359.339, 356.866, -11.7826 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -1936, 703.5, -28.5 ), ( 359.339, 356.866, -11.7826 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( 1013.5, 76.5, 42 ), vectorScale( ( 0, 1, 0 ), 15 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -458.5, 589, 63 ), ( 1.3179, 341.742, 3.9882 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( 653, 344.5, 147 ), vectorScale( ( 0, 1, 0 ), 14.7 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( 653, 344.5, 98 ), vectorScale( ( 0, 1, 0 ), 14.7 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -611.5, 535, 90.5 ), ( 359.952, 250.338, 9.04601 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1168.13, 200.5, 222.485 ), ( 352.436, 6.33769, -2.04434 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1147.43, 295.5, 219.708 ), ( 352.293, 18.1248, -1.3497 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1113.81, 391.5, 218.7 ), ( 352.832, 23.1409, -0.786543 ) );
	level.onspawnintermission = ::nuked_intermission;
	level.endgamefunction = ::nuked_end_game;
	setdvar( "compassmaxrange", "2100" );
	precacheitem( "vcs_controller_mp" );
	precachemenu( "vcs" );
	precachemodel( "nt_sign_population" );
	precachemodel( "nt_sign_population_vcs" );
	precachestring( &"MPUI_USE_VCS_HINT" );
	level.const_fx_exploder_nuke = 1001;
	level.headless_mannequin_count = 0;
	level.destructible_callbacks[ "headless" ] = ::mannequin_headless;
	level thread nuked_population_sign_think();
	level.disableoutrovisionset = 1;
	destructible_car_anims = [];
	destructible_car_anims[ "car1" ] = %fxanim_mp_nuked2025_car01_anim;
	destructible_car_anims[ "car2" ] = %fxanim_mp_nuked2025_car02_anim;
	destructible_car_anims[ "displayGlass" ] = %fxanim_mp_nuked2025_display_glass_anim;
	level thread nuked_mannequin_init();
	level thread nuked_powerlevel_think();
	level thread nuked_bomb_drop_think();
}

levelspawndvars( reset_dvars ) //checked matches cerberus output
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1600", reset_dvars );
	ss.dead_friend_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_radius", "1300", reset_dvars );
	ss.dead_friend_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_timeout_seconds", "8", reset_dvars );
	ss.dead_friend_influencer_count = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_count", "7", reset_dvars );
}

move_spawn_point( targetname, start_point, new_point ) //checked changed to match cerberus output
{
	spawn_points = getentarray( targetname, "classname" );
	for ( i = 0; i < spawn_points.size; i++ )
	{
		if ( distancesquared( spawn_points[ i ].origin, start_point ) < 1 )
		{
			spawn_points[ i ].origin = new_point;
			return;
		}
	}
}

nuked_mannequin_init() //checked partially changed to match cerberus output see info.md
{
	destructibles = getentarray( "destructible", "targetname" );
	mannequins = nuked_mannequin_filter( destructibles );
	level.mannequin_count = mannequins.size;
	if ( mannequins.size <= 0 )
	{
		return;
	}
	camerastart = getstruct( "endgame_camera_start", "targetname" );
	level.endgamemannequin = getclosest( camerastart.origin, mannequins );
	remove_count = mannequins.size - 25;
	remove_count = clamp( remove_count, 0, remove_count );
	mannequins = array_randomize( mannequins );
	i = 0;
	while ( i < remove_count )
	{
		/*
/#
		assert( isDefined( mannequins[ i ].target ) );
#/
		*/
		if ( level.endgamemannequin == mannequins[ i ] )
		{
			i++;
			continue;
		}
		collision = getent( mannequins[ i ].target, "targetname" );
		/*
/#
		assert( isDefined( collision ) );
#/
		*/
		collision delete();
		mannequins[ i ] delete();
		level.mannequin_count--;
		i++;
	}
	level waittill( "prematch_over" );
	level.mannequin_time = getTime();
}

nuked_mannequin_filter( destructibles ) //checked changed to match cerberus output
{
	mannequins = [];
	for ( i = 0; i < destructibles.size; i++ )
	{
		destructible = destructibles[ i ];
		if ( issubstr( destructible.destructibledef, "male" ) )
		{
			mannequins[ mannequins.size ] = destructible;
		}
	}
	return mannequins;
}

mannequin_headless( notifytype, attacker ) //checked matches cerberus output
{
	if ( getTime() < ( level.mannequin_time + ( getdvarintdefault( "vcs_timelimit", 120 ) * 1000 ) ) )
	{
		level.headless_mannequin_count++;
		if ( level.headless_mannequin_count == level.mannequin_count )
		{
			level thread do_vcs();
		}
	}
}

nuked_intermission() //checked matches cerberus output
{
	maps/mp/gametypes/_globallogic_defaults::default_onspawnintermission();
}

nuked_end_game() //checked matches cerberus output
{
	if ( waslastround() )
	{
		level notify( "nuke_detonation" );
		level thread nuke_detonation();
	}
}

nuke_detonation() //checked changed to match cerberus output
{
	level notify( "bomb_drop_pre" );
	clientnotify( "bomb_drop_pre" );
	bomb_loc = getent( "bomb_loc", "targetname" );
	bomb_loc playsound( "amb_end_nuke_2d" );
	destructibles = getentarray( "destructible", "targetname" );
	for ( i = 0; i < destructibles.size; i++ )
	{
		if ( getsubstr( destructibles[ i ].destructibledef, 0, 4 ) == "veh_" )
		{
			destructibles[ i ] hide();
		}
	}
	displaysign = getent( "nuke_display_glass_server", "targetname" );
	/*
/#
	assert( isDefined( displaysign ) );
#/
	*/
	displaysign hide();
	bombwaitpretime = getdvarfloatdefault( "scr_nuke_car_pre", 0.5 );
	wait bombwaitpretime;
	exploder( level.const_fx_exploder_nuke );
	bomb_loc = getent( "bomb_loc", "targetname" );
	bomb_loc playsound( "amb_end_nuke" );
	level notify( "bomb_drop" );
	clientnotify( "bomb_drop" );
	bombwaittime = getdvarfloatdefault( "scr_nuke_car_flip", 3.25 );
	wait bombwaittime;
	clientnotify( "nuke_car_flip" );
	location = level.endgamemannequin.origin + ( 0, -20, 50 );
	radiusdamage( location, 128, 128, 128 );
	physicsexplosionsphere( location, 128, 128, 1 );
	mannequinwaittime = getdvarfloatdefault( "scr_nuke_mannequin_flip", 0,25 );
	wait mannequinwaittime;
	level.endgamemannequin rotateto( level.endgamemannequin.angles + vectorScale( ( 0, 0, 1 ), 90 ), 0.7 );
	level.endgamemannequin moveto( level.endgamemannequin.origin + vectorScale( ( 0, 1, 0 ), 90 ), 1 );
}

nuked_bomb_drop_think() //checked changed to match cerberus output
{
	camerastart = getstruct( "endgame_camera_start", "targetname" );
	cameraend = getstruct( camerastart.target, "targetname" );
	bomb_loc = getent( "bomb_loc", "targetname" );
	cam_move_time = set_dvar_float_if_unset( "scr_cam_move_time", "4.0" );
	bomb_explode_delay = set_dvar_float_if_unset( "scr_bomb_explode_delay", "2.75" );
	env_destroy_delay = set_dvar_float_if_unset( "scr_env_destroy_delay", "0.5" );
	for ( ;; )
	{
		camera = spawn( "script_model", camerastart.origin );
		camera.angles = camerastart.angles;
		camera setmodel( "tag_origin" );
		level waittill( "bomb_drop_pre" );
		level notify( "fxanim_dome_explode_start" );
		for ( i = 0; i < get_players().size; i++ )
		{
			player = get_players()[ i ];
			player camerasetposition( camera );
			player camerasetlookat();
			player cameraactivate( 1 );
			player setdepthoffield( 0, 128, 7000, 10000, 6, 1,8 );
		}
		camera moveto( cameraend.origin, cam_move_time, 0, 0 );
		camera rotateto( cameraend.angles, cam_move_time, 0, 0 );
		bombwaittime = getdvarfloatdefault( "mp_nuketown_2020_bombwait", 3 );
		wait bombwaittime;
		wait env_destroy_delay;
		cameraforward = anglesToForward( cameraend.angles );
		physicsexplosionsphere( bomb_loc.origin, 128, 128, 1 );
		radiusdamage( bomb_loc.origin, 128, 128, 128 );
	}
}

nuked_population_sign_think() //checked changed to match beta dump
{
	tens_model = getent( "counter_tens", "targetname" );
	ones_model = getent( "counter_ones", "targetname" );
	step = 36;
	ones = 0;
	tens = 0;
	tens_model rotateroll( step, 0.05 );
	ones_model rotateroll( step, 0.05 );
	for ( ;; )
	{
		wait 1;
		for ( ;; )
		{
			num_players = get_players().size;
			dial = ones + ( tens * 10 );
			if ( num_players < dial )
			{
				ones--;

				time = set_dvar_float_if_unset( "scr_dial_rotate_time", "0.5" );
				if ( ones < 0 )
				{
					ones = 9;
					tens_model rotateroll( 0 - step, time );
					tens--;

				}
				ones_model rotateroll( 0 - step, time );
				ones_model waittill( "rotatedone" );
				continue;
			}
			if ( num_players > dial )
			{
				ones++;
				time = set_dvar_float_if_unset( "scr_dial_rotate_time", "0.5" );
				if ( ones > 9 )
				{
					ones = 0;
					tens_model rotateroll( step, time );
					tens++;
				}
				ones_model rotateroll( step, time );
				ones_model waittill( "rotatedone" );
				continue;
			}
			else
			{
				break;
			}
		}
	}
}

do_vcs() //checked matches cerberus output
{
	if ( getdvarintdefault( "disable_vcs", 0 ) )
	{
		return;
	}
	if ( !getgametypesetting( "allowMapScripting" ) )
	{
		return;
	}
	if ( !level.onlinegame || !sessionmodeisprivate() )
	{
		return;
	}
	if ( level.wiiu )
	{
		return;
	}
	targettag = getent( "player_tv_position", "targetname" );
	level.vcs_trigger = spawn( "trigger_radius_use", targettag.origin, 0, 64, 64 );
	level.vcs_trigger setcursorhint( "HINT_NOICON" );
	level.vcs_trigger sethintstring( &"MPUI_USE_VCS_HINT" );
	level.vcs_trigger triggerignoreteam();
	screen = getent( "nuketown_tv", "targetname" );
	screen setmodel( "nt_sign_population_vcs" );
	while ( 1 )
	{
		level.vcs_trigger waittill( "trigger", player );
		if ( player isusingremote() || !isalive( player ) )
		{
			continue;
		}
		prevweapon = player getcurrentweapon();
		if ( prevweapon == "none" || maps/mp/killstreaks/_killstreaks::iskillstreakweapon( prevweapon ) )
		{
			continue;
		}
		level.vcs_trigger setinvisibletoall();
		player giveweapon( "vcs_controller_mp" );
		player switchtoweapon( "vcs_controller_mp" );
		player setstance( "stand" );
		placementtag = spawn( "script_model", player.origin );
		placementtag.angles = player.angles;
		player playerlinktoabsolute( placementtag );
		placementtag moveto( targettag.origin, 0.5, 0.05, 0.05 );
		placementtag rotateto( targettag.angles, 0.5, 0.05, 0.05 );
		player enableinvulnerability();
		player openmenu( "vcs" );
		player wait_till_done_playing_vcs();
		if ( !level.gameended )
		{
			if ( isDefined( player ) )
			{
				player disableinvulnerability();
				player unlink();
				player takeweapon( "vcs_controller_mp" );
				player switchtoweapon( prevweapon );
			}
			level.vcs_trigger setvisibletoall();
		}
	}
}

wait_till_done_playing_vcs() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "menuresponse", menu, response );
		return;
	}
}

nuked_powerlevel_think() //checked matches cerberus output
{
	pin_model = getent( "nuketown_sign_needle", "targetname" );
	pin_model thread pin_think();
}

pin_think() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "entityshutdown" );
	self endon( "delete" );
	startangle = 128;
	normalangle = 65 + randomfloatrange( -30, 15 );
	yellowangle = -35 + randomfloatrange( -5, 5 );
	redangle = -95 + randomfloatrange( -10, 10 );
	endangle = -138;
	self.angles = ( startangle, self.angles[ 1 ], self.angles[ 2 ] );
	waittillframeend;
	if ( islastround() || isoneround() )
	{
		if ( level.timelimit )
		{
			add_timed_event( 10, "near_end_game" );
			self pin_move( yellowangle, level.timelimit * 60 );
		}
		else if ( level.scorelimit )
		{
			add_score_event( int( level.scorelimit * 0,9 ), "near_end_game" );
			self pin_move( normalangle, 300 );
		}
		notifystr = level waittill_any_return( "near_end_game", "game_ended" );
		if ( notifystr == "near_end_game" )
		{
			self pin_check_rotation( 0, 3 );
			self pin_move( redangle, 10 );
			level waittill( "game_ended" );
		}
		self pin_check_rotation( 0, 2 );
		self pin_move( redangle, 2 );
	}
	else if ( level.timelimit )
	{
		self pin_move( normalangle, level.timelimit * 60 );
	}
	else
	{
		self pin_move( normalangle, 300 );
	}
	level waittill( "nuke_detonation" );
	self pin_check_rotation( 0, 0.05 );
	self pin_move( endangle, 0,1 );
}

pin_move( angle, time ) //checked matches cerberus output
{
	angles = ( angle, self.angles[ 1 ], self.angles[ 2 ] );
	self rotateto( angles, time );
}

pin_check_rotation( angle, time ) //checked matches cerberus output
{
	if ( self.angles[ 0 ] > angle )
	{
		self pin_move( angle, time );
		self waittill( "rotatedone" );
	}
}

