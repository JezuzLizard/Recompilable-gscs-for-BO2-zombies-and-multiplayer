#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm;
#include maps/mp/zm_tomb_amb;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	registerclientfield( "actor", "ee_zombie_fist_fx", 14000, 1, "int" );
	registerclientfield( "actor", "ee_zombie_soul_portal", 14000, 1, "int" );
	registerclientfield( "world", "ee_sam_portal", 14000, 2, "int" );
	registerclientfield( "vehicle", "ee_plane_fx", 14000, 1, "int" );
	registerclientfield( "world", "ee_ending", 14000, 1, "int" );
	precache_models();
	flag_init( "ee_all_staffs_crafted" );
	flag_init( "ee_all_staffs_upgraded" );
	flag_init( "ee_all_staffs_placed" );
	flag_init( "ee_mech_zombie_hole_opened" );
	flag_init( "ee_mech_zombie_fight_completed" );
	flag_init( "ee_maxis_drone_retrieved" );
	flag_init( "ee_all_players_upgraded_punch" );
	flag_init( "ee_souls_absorbed" );
	flag_init( "ee_samantha_released" );
	flag_init( "ee_quadrotor_disabled" );
	flag_init( "ee_sam_portal_active" );
	if ( !is_sidequest_allowed( "zclassic" ) )
	{
		return;
	}
/#
	level thread setup_ee_main_devgui();
#/
	declare_sidequest( "little_girl_lost", ::init_sidequest, ::sidequest_logic, ::complete_sidequest, ::generic_stage_start, ::generic_stage_end );
	maps/mp/zm_tomb_ee_main_step_1::init();
	maps/mp/zm_tomb_ee_main_step_2::init();
	maps/mp/zm_tomb_ee_main_step_3::init();
	maps/mp/zm_tomb_ee_main_step_4::init();
	maps/mp/zm_tomb_ee_main_step_5::init();
	maps/mp/zm_tomb_ee_main_step_6::init();
	maps/mp/zm_tomb_ee_main_step_7::init();
	maps/mp/zm_tomb_ee_main_step_8::init();
	flag_wait( "start_zombie_round_logic" );
	sidequest_start( "little_girl_lost" );
}

precache_models()
{
	precachemodel( "p_rus_alarm_button" );
	precachemodel( "p6_zm_tm_staff_holder" );
	precachemodel( "p6_zm_tm_runes" );
	precachemodel( "drone_collision" );
}

init_sidequest()
{
	level.n_ee_step = 0;
	level.n_ee_robot_staffs_planted = 0;
}

sidequest_logic()
{
	level._cur_stage_name = "step_0";
	flag_wait( "ee_all_staffs_crafted" );
	flag_wait( "all_zones_captured" );
	level.n_ee_step++;
	level thread zombie_blood_hint_watch();
	stage_start( "little_girl_lost", "step_1" );
	level waittill( "little_girl_lost_step_1_over" );
	stage_start( "little_girl_lost", "step_2" );
	level waittill( "little_girl_lost_step_2_over" );
	level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_ee_step2", 15 );
	stage_start( "little_girl_lost", "step_3" );
	level waittill( "little_girl_lost_step_3_over" );
	level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_ee_step3", 35 );
	stage_start( "little_girl_lost", "step_4" );
	level waittill( "little_girl_lost_step_4_over" );
	level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_ee_step4", 30 );
	stage_start( "little_girl_lost", "step_5" );
	level waittill( "little_girl_lost_step_5_over" );
	level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_ee_step5", 29 );
	stage_start( "little_girl_lost", "step_6" );
	level waittill( "little_girl_lost_step_6_over" );
	level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_ee_step6", 28 );
	stage_start( "little_girl_lost", "step_7" );
	level waittill( "little_girl_lost_step_7_over" );
	level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_ee_step7", 31 );
	stage_start( "little_girl_lost", "step_8" );
	level waittill( "little_girl_lost_step_8_over" );
}

zombie_blood_hint_watch()
{
	n_curr_step = level.n_ee_step;
	a_player_hint[ 0 ] = 0;
	a_player_hint[ 1 ] = 0;
	a_player_hint[ 2 ] = 0;
	a_player_hint[ 3 ] = 0;
	while ( !flag( "ee_samantha_released" ) )
	{
		level waittill( "player_zombie_blood", e_player );
		while ( n_curr_step != level.n_ee_step )
		{
			n_curr_step = level.n_ee_step;
			i = 0;
			while ( i < a_player_hint.size )
			{
				a_player_hint[ i ] = 0;
				i++;
			}
		}
		if ( !a_player_hint[ e_player.characterindex ] )
		{
			wait randomfloatrange( 3, 7 );
			if ( isDefined( e_player.vo_promises_playing ) && e_player.vo_promises_playing )
			{
				continue;
			}
			while ( isDefined( level.sam_talking ) && level.sam_talking )
			{
				wait 0,05;
			}
			if ( isDefined( e_player ) && isplayer( e_player ) && e_player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] )
			{
				a_player_hint[ e_player.characterindex ] = 1;
				set_players_dontspeak( 1 );
				level.sam_talking = 1;
				str_vox = get_zombie_blood_hint_vox();
				e_player playsoundtoplayer( str_vox, e_player );
				n_duration = soundgetplaybacktime( str_vox );
				wait ( n_duration / 1000 );
				level.sam_talking = 0;
				set_players_dontspeak( 0 );
			}
			continue;
		}
		else
		{
			if ( randomint( 100 ) < 20 )
			{
				wait randomfloatrange( 3, 7 );
				if ( isDefined( e_player.vo_promises_playing ) && e_player.vo_promises_playing )
				{
					continue;
				}
				while ( isDefined( level.sam_talking ) && level.sam_talking )
				{
					wait 0,05;
				}
				if ( isDefined( e_player ) && isplayer( e_player ) && e_player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] )
				{
					str_vox = get_zombie_blood_hint_generic_vox();
					if ( isDefined( str_vox ) )
					{
						set_players_dontspeak( 1 );
						level.sam_talking = 1;
						e_player playsoundtoplayer( str_vox, e_player );
						n_duration = soundgetplaybacktime( str_vox );
						wait ( n_duration / 1000 );
						level.sam_talking = 0;
						set_players_dontspeak( 0 );
					}
				}
			}
		}
	}
}

get_step_announce_vox()
{
	switch( level.n_ee_step )
	{
		case 1:
			return "vox_sam_all_staff_upgrade_key_0";
		case 2:
			return "vox_sam_all_staff_ascend_darkness_0";
		case 3:
			return "vox_sam_all_staff_rain_fire_0";
		case 4:
			return "vox_sam_all_staff_unleash_hoard_0";
		case 5:
			return "vox_sam_all_staff_skewer_beast_0";
		case 6:
			return "vox_sam_all_staff_fist_iron_0";
		case 7:
			return "vox_sam_all_staff_raise_hell_0";
		default:
			return undefined;
	}
}

get_zombie_blood_hint_vox()
{
	if ( flag( "all_zones_captured" ) )
	{
		return "vox_sam_upgrade_staff_clue_" + level.n_ee_step + "_0";
	}
	return "vox_sam_upgrade_staff_clue_" + level.n_ee_step + "_grbld_0";
}

get_zombie_blood_hint_generic_vox()
{
	if ( !isDefined( level.generic_clue_index ) )
	{
		level.generic_clue_index = 0;
	}
	vo_array[ 0 ] = "vox_sam_heard_by_all_1_0";
	vo_array[ 1 ] = "vox_sam_heard_by_all_2_0";
	vo_array[ 2 ] = "vox_sam_heard_by_all_3_0";
	vo_array[ 3 ] = "vox_sam_slow_progress_0";
	vo_array[ 4 ] = "vox_sam_slow_progress_2";
	vo_array[ 5 ] = "vox_sam_slow_progress_3";
	if ( level.generic_clue_index >= vo_array.size )
	{
		return undefined;
	}
	str_vo = vo_array[ level.generic_clue_index ];
	level.generic_clue_index++;
	return str_vo;
}

complete_sidequest()
{
	level.sndgameovermusicoverride = "game_over_ee";
	a_players = getplayers();
	_a293 = a_players;
	_k293 = getFirstArrayKey( _a293 );
	while ( isDefined( _k293 ) )
	{
		player = _a293[ _k293 ];
		player freezecontrols( 1 );
		player thread fadetoblackforxsec( 0, 5, 0,5, 0, "white" );
		_k293 = getNextArrayKey( _a293, _k293 );
	}
	playsoundatposition( "zmb_squest_whiteout", ( 0, 0, -1 ) );
	delay_thread( 0,5, ::remove_portal_beam );
	level.custom_intermission = ::player_intermission_ee;
	level setclientfield( "ee_ending", 1 );
	wait_network_frame();
	level notify( "end_game" );
}

remove_portal_beam()
{
	if ( isDefined( level.ee_ending_beam_fx ) )
	{
		level.ee_ending_beam_fx delete();
	}
}

generic_stage_start()
{
	str_vox = get_step_announce_vox();
	if ( isDefined( str_vox ) )
	{
		level thread ee_samantha_say( str_vox );
	}
}

generic_stage_end()
{
	level.n_ee_step++;
	if ( level.n_ee_step <= 6 )
	{
		flag_wait( "all_zones_captured" );
	}
	wait_network_frame();
	wait_network_frame();
}

all_staffs_inserted_in_puzzle_room()
{
	n_staffs_inserted = 0;
	_a350 = level.a_elemental_staffs;
	_k350 = getFirstArrayKey( _a350 );
	while ( isDefined( _k350 ) )
	{
		staff = _a350[ _k350 ];
		if ( staff.upgrade.charger.is_inserted )
		{
			n_staffs_inserted++;
		}
		_k350 = getNextArrayKey( _a350, _k350 );
	}
	if ( n_staffs_inserted == 4 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

ee_samantha_say( str_vox )
{
	flag_waitopen( "story_vo_playing" );
	flag_set( "story_vo_playing" );
	set_players_dontspeak( 1 );
	samanthasay( str_vox, get_players()[ 0 ] );
	set_players_dontspeak( 0 );
	flag_clear( "story_vo_playing" );
}

player_intermission_ee()
{
	self closemenu();
	self closeingamemenu();
	level endon( "stop_intermission" );
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "_zombie_game_over" );
	self.score = self.score_total;
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	points = getstructarray( "ee_cam", "targetname" );
	if ( !isDefined( points ) || points.size == 0 )
	{
		points = getentarray( "info_intermission", "classname" );
		if ( points.size < 1 )
		{
/#
			println( "NO info_intermission POINTS IN MAP" );
#/
			return;
		}
	}
	self.game_over_bg = newclienthudelem( self );
	self.game_over_bg.horzalign = "fullscreen";
	self.game_over_bg.vertalign = "fullscreen";
	self.game_over_bg setshader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;
	visionsetnaked( "cheat_bw", 0,05 );
	org = undefined;
	while ( 1 )
	{
		points = array_randomize( points );
		i = 0;
		while ( i < points.size )
		{
			point = points[ i ];
			if ( !isDefined( org ) )
			{
				self spawn( point.origin, point.angles );
			}
			if ( isDefined( points[ i ].target ) )
			{
				if ( !isDefined( org ) )
				{
					org = spawn( "script_model", self.origin + vectorScale( ( 0, 0, -1 ), 60 ) );
					org setmodel( "tag_origin" );
				}
				org.origin = points[ i ].origin;
				org.angles = points[ i ].angles;
				j = 0;
				while ( j < get_players().size )
				{
					player = get_players()[ j ];
					player camerasetposition( org );
					player camerasetlookat();
					player cameraactivate( 1 );
					j++;
				}
				speed = 20;
				if ( isDefined( points[ i ].speed ) )
				{
					speed = points[ i ].speed;
				}
				target_point = getstruct( points[ i ].target, "targetname" );
				dist = distance( points[ i ].origin, target_point.origin );
				time = dist / speed;
				q_time = time * 0,25;
				if ( q_time > 1 )
				{
					q_time = 1;
				}
				self.game_over_bg fadeovertime( q_time );
				self.game_over_bg.alpha = 0;
				org moveto( target_point.origin, time, q_time, q_time );
				org rotateto( target_point.angles, time, q_time, q_time );
				wait ( time - q_time );
				self.game_over_bg fadeovertime( q_time );
				self.game_over_bg.alpha = 1;
				wait q_time;
				i++;
				continue;
			}
			else
			{
				self.game_over_bg fadeovertime( 1 );
				self.game_over_bg.alpha = 0;
				wait 5;
				self.game_over_bg thread maps/mp/zombies/_zm::fade_up_over_time( 1 );
			}
			i++;
		}
	}
}

setup_ee_main_devgui()
{
/#
	wait 5;
	b_activated = 0;
	while ( !b_activated )
	{
		_a507 = getplayers();
		_k507 = getFirstArrayKey( _a507 );
		while ( isDefined( _k507 ) )
		{
			player = _a507[ _k507 ];
			if ( distance2d( player.origin, ( 2904, 5040, -336 ) ) < 100 && player usebuttonpressed() )
			{
				wait 2;
				if ( player usebuttonpressed() )
				{
					b_activated = 1;
				}
			}
			_k507 = getNextArrayKey( _a507, _k507 );
		}
		wait 0,05;
	}
	setdvar( "ee_main_progress", "off" );
	setdvar( "ee_main_end_level", "off" );
	setdvar( "ee_upgrade_beacon", "off" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/EE Main:1/Next Step:1" "ee_main_progress on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/EE Main:1/Upgrade Beacon:2" "ee_upgrade_beacon on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/EE Main:1/End Level:3" "ee_main_end_level on"\n" );
	level thread watch_devgui_ee_main();
#/
}

watch_devgui_ee_main()
{
/#
	while ( 1 )
	{
		if ( getDvar( "ee_main_progress" ) == "on" )
		{
			setdvar( "ee_main_progress", "off" );
			level.ee_debug = 1;
			flag_set( "samantha_intro_done" );
			switch( level._cur_stage_name )
			{
				case "step_0":
					flag_set( "ee_all_staffs_crafted" );
					flag_set( "all_zones_captured" );
					break;
				break;
				case "step_1":
					flag_set( "ee_all_staffs_upgraded" );
					level waittill( "little_girl_lost_step_1_over" );
					break;
				break;
				case "step_2":
					flag_set( "ee_all_staffs_placed" );
					level waittill( "little_girl_lost_step_2_over" );
					break;
				break;
				case "step_3":
					flag_set( "ee_mech_zombie_hole_opened" );
					m_floor = getent( "easter_mechzombie_spawn", "targetname" );
					if ( isDefined( m_floor ) )
					{
						m_floor delete();
					}
					level waittill( "little_girl_lost_step_3_over" );
					break;
				break;
				case "step_4":
					flag_set( "ee_mech_zombie_fight_completed" );
					flag_set( "ee_quadrotor_disabled" );
					level waittill( "little_girl_lost_step_4_over" );
					break;
				break;
				case "step_5":
					flag_set( "ee_maxis_drone_retrieved" );
					flag_clear( "ee_quadrotor_disabled" );
					level waittill( "little_girl_lost_step_5_over" );
					break;
				break;
				case "step_6":
					flag_set( "ee_all_players_upgraded_punch" );
					level waittill( "little_girl_lost_step_6_over" );
					break;
				break;
				case "step_7":
					flag_set( "ee_souls_absorbed" );
					level waittill( "little_girl_lost_step_7_over" );
					break;
				break;
				case "step_8":
					flag_set( "ee_quadrotor_disabled" );
					level waittill( "little_girl_lost_step_8_over" );
					break;
				break;
				default:
				}
			}
			if ( getDvar( "ee_main_end_level" ) == "on" )
			{
				setdvar( "ee_main_end_level", "off" );
				level setclientfield( "ee_sam_portal", 2 );
				complete_sidequest();
			}
			if ( getDvar( "ee_upgrade_beacon" ) == "on" )
			{
				setdvar( "ee_upgrade_beacon", "off" );
				setdvar( "force_three_robot_round", "on" );
				flag_set( "fire_link_enabled" );
				array_thread( get_players(), ::maps/mp/zombies/_zm_weapons::weapon_give, "beacon_zm" );
			}
			wait 0,05;
#/
		}
	}
}
