//checked includes match cerberus output
#include maps/mp/zombies/_zm;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_clone;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_tomb_teleporter;
#include maps/mp/zombies/_zm_weap_one_inch_punch;
#include maps/mp/zombies/_zm_ai_mechz;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zm_tomb_giant_robot_ffotd;
#include maps/mp/zombies/_zm_net;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

//Uncomment anim tree when compiler supports it.
//#using_animtree( "zm_tomb_giant_robot_hatch" );

init_giant_robot_glows() //checked changed to match cerberus output
{
	maps/mp/zm_tomb_giant_robot_ffotd::init_giant_robot_glows_start();
	precacheitem( "falling_hands_tomb_zm" );
	precachemodel( "veh_t6_dlc_zm_robot_foot_hatch" );
	precachemodel( "veh_t6_dlc_zm_robot_foot_hatch_lights" );
	flag_init( "foot_shot" );
	flag_init( "three_robot_round" );
	flag_init( "fire_link_enabled" );
	flag_init( "timeout_vo_robot_0" );
	flag_init( "timeout_vo_robot_1" );
	flag_init( "timeout_vo_robot_2" );
	level thread setup_giant_robot_devgui();
	level.gr_foot_hatch_closed = [];
	level.gr_foot_hatch_closed[ 0 ] = 1;
	level.gr_foot_hatch_closed[ 1 ] = 1;
	level.gr_foot_hatch_closed[ 2 ] = 1;
	a_gr_head_triggers = getstructarray( "giant_robot_head_exit_trigger", "script_noteworthy" );
	foreach ( struct in a_gr_head_triggers )
	{
		gr_head_exit_trigger_start( struct );
	}
	level thread handle_wind_tunnel_bunker_collision();
	level thread handle_tank_bunker_collision();
	maps/mp/zm_tomb_giant_robot_ffotd::init_giant_robot_glows_end();
}

init_animtree() //checked matches cerberus output
{
	scriptmodelsuseanimtree( -1 );
}

init_giant_robot() //checked matches cerberus output
{
	maps/mp/zm_tomb_giant_robot_ffotd::init_giant_robot_start();
	registerclientfield( "actor", "register_giant_robot", 14000, 1, "int" );
	registerclientfield( "world", "start_anim_robot_0", 14000, 1, "int" );
	registerclientfield( "world", "start_anim_robot_1", 14000, 1, "int" );
	registerclientfield( "world", "start_anim_robot_2", 14000, 1, "int" );
	registerclientfield( "world", "play_foot_stomp_fx_robot_0", 14000, 2, "int" );
	registerclientfield( "world", "play_foot_stomp_fx_robot_1", 14000, 2, "int" );
	registerclientfield( "world", "play_foot_stomp_fx_robot_2", 14000, 2, "int" );
	registerclientfield( "world", "play_foot_open_fx_robot_0", 14000, 2, "int" );
	registerclientfield( "world", "play_foot_open_fx_robot_1", 14000, 2, "int" );
	registerclientfield( "world", "play_foot_open_fx_robot_2", 14000, 2, "int" );
	registerclientfield( "world", "eject_warning_fx_robot_0", 14000, 1, "int" );
	registerclientfield( "world", "eject_warning_fx_robot_1", 14000, 1, "int" );
	registerclientfield( "world", "eject_warning_fx_robot_2", 14000, 1, "int" );
	registerclientfield( "allplayers", "eject_steam_fx", 14000, 1, "int" );
	registerclientfield( "allplayers", "all_tubes_play_eject_steam_fx", 14000, 1, "int" );
	registerclientfield( "allplayers", "gr_eject_player_impact_fx", 14000, 1, "int" );
	registerclientfield( "toplayer", "giant_robot_rumble_and_shake", 14000, 2, "int" );
	registerclientfield( "world", "church_ceiling_fxanim", 14000, 1, "int" );
	level thread giant_robot_initial_spawns();
	level.custom_intermission = ::tomb_standard_intermission;
	init_footstep_safe_spots();
	maps/mp/zm_tomb_giant_robot_ffotd::init_giant_robot_end();
}

init_footstep_safe_spots() //checked changed to match cerberus output
{
	level.giant_robot_footstep_safe_spots = [];
	make_safe_spot_trigger_box_at_point( ( -493, -198, 389 ), ( 0, 0, 0 ), 80, 64, 150 );
}

make_safe_spot_trigger_box_at_point( v_origin, v_angles, n_length, n_width, n_height ) //checked matches cerberus output
{
	trig = spawn( "trigger_box", v_origin, 0, n_length, n_width, n_height );
	trig.angles = v_angles;
	level.giant_robot_footstep_safe_spots[ level.giant_robot_footstep_safe_spots.size ] = trig;
}

tomb_can_revive_override( player_down ) //checked matches cerberus output used is_true() instead
{
	if ( is_true( player_down.is_stomped ) )
	{
		return 0;
	}
	return 1;
}

giant_robot_initial_spawns() //checked changed to match cerberus output
{
	flag_wait( "start_zombie_round_logic" );
	level.a_giant_robots = [];
	for ( i = 0; i < 3; i++ )
	{
		level.gr_foot_hatch_closed[ i ] = 1;
		trig_stomp_kill_right = getent( "trig_stomp_kill_right_" + i, "targetname" );
		trig_stomp_kill_left = getent( "trig_stomp_kill_left_" + i, "targetname" );
		trig_stomp_kill_right enablelinkto();
		trig_stomp_kill_left enablelinkto();
		clip_foot_right = getent( "clip_foot_right_" + i, "targetname" );
		clip_foot_left = getent( "clip_foot_left_" + i, "targetname" );
		sp_giant_robot = getent( "ai_giant_robot_" + i, "targetname" );
		ai = sp_giant_robot spawnactor();
		ai maps/mp/zm_tomb_giant_robot_ffotd::giant_robot_spawn_start();
		ai.is_giant_robot = 1;
		ai.giant_robot_id = i;
		tag_right_foot = ai gettagorigin( "TAG_ATTACH_HATCH_RI" );
		tag_left_foot = ai gettagorigin( "TAG_ATTACH_HATCH_LE" );
		trig_stomp_kill_right.origin = tag_right_foot + vectorScale( ( 0, 0, 1 ), 72 );
		trig_stomp_kill_right.angles = ai gettagangles( "TAG_ATTACH_HATCH_RI" );
		trig_stomp_kill_left.origin = tag_left_foot + vectorScale( ( 0, 0, 1 ), 72 );
		trig_stomp_kill_left.angles = ai gettagangles( "TAG_ATTACH_HATCH_LE" );
		wait 0,1;
		trig_stomp_kill_right linkto( ai, "TAG_ATTACH_HATCH_RI", vectorScale( ( 0, 0, 1 ), 72 ) );
		wait_network_frame();
		trig_stomp_kill_left linkto( ai, "TAG_ATTACH_HATCH_LE", vectorScale( ( 0, 0, 1 ), 72 ) );
		wait_network_frame();
		ai.trig_stomp_kill_right = trig_stomp_kill_right;
		ai.trig_stomp_kill_left = trig_stomp_kill_left;
		clip_foot_right.origin = tag_right_foot + ( 0, 0, 1 );
		clip_foot_left.origin = tag_left_foot + ( 0, 0, 1 );
		clip_foot_right.angles = ai gettagangles( "TAG_ATTACH_HATCH_RI" );
		clip_foot_left.angles = ai gettagangles( "TAG_ATTACH_HATCH_LE" );
		wait 0,1;
		clip_foot_right linkto( ai, "TAG_ATTACH_HATCH_RI", ( 0, 0, 1 ) );
		wait_network_frame();
		clip_foot_left linkto( ai, "TAG_ATTACH_HATCH_LE", ( 0, 0, 1 ) );
		wait_network_frame();
		ai.clip_foot_right = clip_foot_right;
		ai.clip_foot_left = clip_foot_left;
		ai.is_zombie = 0;
		ai.targetname = "giant_robot_walker_" + i;
		ai.animname = "giant_robot_walker";
		ai.script_noteworthy = "giant_robot";
		ai.audio_type = "giant_robot";
		ai.ignoreall = 1;
		ai.ignoreme = 1;
		ai setcandamage( 0 );
		ai magic_bullet_shield();
		ai setplayercollision( 1 );
		ai setforcenocull();
		ai setfreecameralockonallowed( 0 );
		ai.goalradius = 100000;
		ai setgoalpos( ai.origin );
		ai setclientfield( "register_giant_robot", 1 );
		ai ghost();
		ai ent_flag_init( "robot_head_entered" );
		ai ent_flag_init( "kill_trigger_active" );
		level.a_giant_robots[ i ] = ai;
		ai maps/mp/zm_tomb_giant_robot_ffotd::giant_robot_spawn_end();
		wait_network_frame();
	}
	level thread robot_cycling();
}

robot_cycling() //checked partially changed to match cerberus output
{
	three_robot_round = 0;
	last_robot = -1;
	level thread giant_robot_intro_walk( 1 );
	level waittill( "giant_robot_intro_complete" );
	while ( 1 )
	{
		if ( level.round_number % 4 && three_robot_round != level.round_number )
		{
			flag_set( "three_robot_round" );
		}
		if ( flag( "ee_all_staffs_placed" ) && !flag( "ee_mech_zombie_hole_opened" ) )
		{
			flag_set( "three_robot_round" );
		}
		/*
/#
		if ( isDefined( level.devgui_force_three_robot_round ) && level.devgui_force_three_robot_round )
		{
			flag_set( "three_robot_round" );
#/
		}
		*/
		if ( flag( "three_robot_round" ) )
		{
			level.zombie_ai_limit = 22;
			random_number = randomint( 3 );
			if ( random_number == 2 )
			{
				level thread giant_robot_start_walk( 2 );
			}
			else
			{
				level thread giant_robot_start_walk( 2, 0 );
			}
			wait 5;
			if ( random_number == 0 )
			{
				level thread giant_robot_start_walk( 0 );
			}
			else
			{
				level thread giant_robot_start_walk( 0, 0 );
			}
			wait 5;
			if ( random_number == 1 )
			{
				level thread giant_robot_start_walk( 1 );
			}
			else
			{
				level thread giant_robot_start_walk( 1, 0 );
			}
			level waittill( "giant_robot_walk_cycle_complete" );
			level waittill( "giant_robot_walk_cycle_complete" );
			level waittill( "giant_robot_walk_cycle_complete" );
			wait 5;
			level.zombie_ai_limit = 24;
			three_robot_round = level.round_number;
			last_robot = -1;
			flag_clear( "three_robot_round" );
		}
		else
		{
			if ( !flag( "activate_zone_nml" ) )
			{
				random_number = randomint( 2 );
			}
			else
			{
				random_number = randomint( 3 );
			}
			/*
/#
			if ( isDefined( level.devgui_force_giant_robot ) )
			{
				random_number = level.devgui_force_giant_robot;
#/
			}
			*/
			last_robot = random_number;
			level thread giant_robot_start_walk( random_number );
			level waittill( "giant_robot_walk_cycle_complete" );
			wait 5;
		}
	}
}

giant_robot_intro_walk( n_robot_id ) //checked changed to match cerberus output
{
	ai = getent( "giant_robot_walker_" + n_robot_id, "targetname" );
	ai attach( "veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_LE" );
	ai attach( "veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_RI" );
	ai thread giant_robot_think( ai.trig_stomp_kill_right, ai.trig_stomp_kill_left, ai.clip_foot_right, ai.clip_foot_left, undefined, 3 );
	level thread starting_spawn_light();
	wait 0.5;
	level setclientfield( "play_foot_stomp_fx_robot_" + ai.giant_robot_id, 2 );
	level thread giant_robot_intro_exploder();
	a_players = getplayers();
	foreach ( player in a_players )
	{
		player setclientfieldtoplayer( "giant_robot_rumble_and_shake", 3 );
		player thread turn_clientside_rumble_off();
	}
	level waittill( "giant_robot_walk_cycle_complete" );
	level notify( "giant_robot_intro_complete" );
}

giant_robot_intro_exploder() //checked matches cerberus output
{
	exploder( 111 );
	wait 3;
	stop_exploder( 111 );
}

giant_robot_start_walk( n_robot_id, b_has_hatch ) //checked changed to match cerberus output
{
	if ( !isDefined( b_has_hatch ) )
	{
		b_has_hatch = 1;
	}
	ai = getent( "giant_robot_walker_" + n_robot_id, "targetname" );
	level.gr_foot_hatch_closed[ n_robot_id ] = 1;
	ai.b_has_hatch = b_has_hatch;
	ai ent_flag_clear( "kill_trigger_active" );
	ai ent_flag_clear( "robot_head_entered" );
	if ( isDefined( ai.b_has_hatch ) && ai.b_has_hatch )
	{
		m_sole = getent( "target_sole_" + n_robot_id, "targetname" );
	}
	if ( isDefined( m_sole ) && isDefined( ai.b_has_hatch ) && ai.b_has_hatch )
	{
		m_sole setcandamage( 1 );
		m_sole.health = 99999;
		m_sole useanimtree( -1 );
		m_sole unlink();
	}
	wait 10;
	if ( isDefined( m_sole ) )
	{
		if ( cointoss() )
		{
			ai.hatch_foot = "left";
		}
		else
		{
			ai.hatch_foot = "right";
		}
		/*
/#
		if ( isDefined( level.devgui_force_giant_robot_foot ) && isDefined( ai.b_has_hatch ) && ai.b_has_hatch )
		{
			ai.hatch_foot = level.devgui_force_giant_robot_foot;
#/
		}
		*/
		if ( ai.hatch_foot == "left" )
		{
			n_sole_origin = ai gettagorigin( "TAG_ATTACH_HATCH_LE" );
			v_sole_angles = ai gettagangles( "TAG_ATTACH_HATCH_LE" );
			ai.hatch_foot = "left";
			str_sole_tag = "TAG_ATTACH_HATCH_LE";
			ai attach( "veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_RI" );
		}
		else if ( ai.hatch_foot == "right" )
		{
			n_sole_origin = ai gettagorigin( "TAG_ATTACH_HATCH_RI" );
			v_sole_angles = ai gettagangles( "TAG_ATTACH_HATCH_RI" );
			ai.hatch_foot = "right";
			str_sole_tag = "TAG_ATTACH_HATCH_RI";
			ai attach( "veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_LE" );
		}
		m_sole.origin = n_sole_origin;
		m_sole.angles = v_sole_angles;
		wait 0.1;
		m_sole linkto( ai, str_sole_tag, ( 0, 0, 0 ) );
		m_sole show();
		ai attach( "veh_t6_dlc_zm_robot_foot_hatch_lights", str_sole_tag );
	}
	if ( isDefined( ai.b_has_hatch ) && !ai.b_has_hatch )
	{
		ai attach( "veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_RI" );
		ai attach( "veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_LE" );
	}
	wait 0.05;
	ai thread giant_robot_think( ai.trig_stomp_kill_right, ai.trig_stomp_kill_left, ai.clip_foot_right, ai.clip_foot_left, m_sole, n_robot_id );
}

giant_robot_think( trig_stomp_kill_right, trig_stomp_kill_left, clip_foot_right, clip_foot_left, m_sole, n_robot_id ) //checked changed to match cerberus output use is_true() instead
{
	self thread robot_walk_animation( n_robot_id );
	self show();
	if ( isDefined( m_sole ) )
	{
		self thread sole_cleanup( m_sole );
	}
	self.is_walking = 1;
	self thread monitor_footsteps( trig_stomp_kill_right, "right" );
	self thread monitor_footsteps( trig_stomp_kill_left, "left" );
	self thread monitor_footsteps_fx( trig_stomp_kill_right, "right" );
	self thread monitor_footsteps_fx( trig_stomp_kill_left, "left" );
	self thread monitor_shadow_notetracks( "right" );
	self thread monitor_shadow_notetracks( "left" );
	self thread sndgrthreads( "left" );
	self thread sndgrthreads( "right" );
	if ( isDefined( m_sole ) && level.gr_foot_hatch_closed[ n_robot_id ] && is_true( self.b_has_hatch ) )
	{
		self thread giant_robot_foot_waittill_sole_shot( m_sole );
	}
	a_players = getplayers();
	if ( n_robot_id != 3 && !is_true( level.giant_robot_discovered ) )
	{
		foreach ( player in a_players )
		{
			player thread giant_robot_discovered_vo( self );
		}
	}
	if ( flag( "three_robot_round" ) && !is_true( level.three_robot_round_vo ) )
	{
		foreach ( player in a_players )
		{
			player thread three_robot_round_vo( self );
		}
	}
	if ( n_robot_id != 3 && !is_true( level.shoot_robot_vo ) )
	{
		foreach ( player in a_players )
		{
			player thread shoot_at_giant_robot_vo( self );
		}
	}
	self waittill( "giant_robot_stop" );
	self.is_walking = 0;
	self stopanimscripted();
	sp_giant_robot = getent( "ai_giant_robot_" + self.giant_robot_id, "targetname" );
	self.origin = sp_giant_robot.origin;
	level setclientfield( "play_foot_open_fx_robot_" + self.giant_robot_id, 0 );
	self ghost();
	self detachall();
	level notify( "giant_robot_walk_cycle_complete" );
}

sole_cleanup( m_sole ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "giant_robot_stop" );
	wait_network_frame();
	m_sole clearanim( %root, 0 );
	wait_network_frame();
	m_sole setanim( %ai_zombie_giant_robot_hatch_close, 1, 0.2, 1 );
}

giant_robot_foot_waittill_sole_shot( m_sole ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "giant_robot_stop" );
	if ( isDefined( self.hatch_foot ) && self.hatch_foot == "left" )
	{
		str_tag = "TAG_ATTACH_HATCH_LE";
		n_foot = 2;
	}
	else if ( isDefined( self.hatch_foot ) && self.hatch_foot == "right" )
	{
		str_tag = "TAG_ATTACH_HATCH_RI";
		n_foot = 1;
	}
	self waittillmatch( "scripted_walk" );
	return "kill_zombies_leftfoot_1";
	wait 1;
	m_sole waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
	m_sole.health = 99999;
	level.gr_foot_hatch_closed[ self.giant_robot_id ] = 0;
	level setclientfield( "play_foot_open_fx_robot_" + self.giant_robot_id, n_foot );
	m_sole clearanim( %ai_zombie_giant_robot_hatch_close, 1 );
	m_sole setanim( %ai_zombie_giant_robot_hatch_open, 1, 0.2, 1 );
	n_time = getanimlength( %ai_zombie_giant_robot_hatch_open );
	wait n_time;
	m_sole clearanim( %ai_zombie_giant_robot_hatch_open, 1 );
	m_sole setanim( %ai_zombie_giant_robot_hatch_open_idle, 1, 0.2, 1 );
}

giant_robot_close_head_entrance( foot_side ) //checked changed to match cerberus output
{
	wait 5;
	level.gr_foot_hatch_closed[ self.giant_robot_id ] = 1;
	level setclientfield( "play_foot_open_fx_robot_" + self.giant_robot_id, 0 );
	m_sole = getent( "target_sole_" + self.giant_robot_id, "targetname" );
	if ( isDefined( m_sole ) )
	{
		m_sole clearanim( %ai_zombie_giant_robot_hatch_open, 1 );
		m_sole clearanim( %ai_zombie_giant_robot_hatch_open_idle, 1 );
		m_sole setanim( %ai_zombie_giant_robot_hatch_close, 1, 0.2, 1 );
	}
	if ( isDefined( foot_side ) )
	{
		if ( foot_side == "right" )
		{
			str_tag = "TAG_ATTACH_HATCH_RI";
		}
		else if ( foot_side == "left" )
		{
			str_tag = "TAG_ATTACH_HATCH_LE";
		}
		self detach( "veh_t6_dlc_zm_robot_foot_hatch_lights", str_tag );
	}
}

robot_walk_animation( n_robot_id ) //checked changed to match cerberus output
{
	if ( n_robot_id != 3 )
	{
		level setclientfield( "start_anim_robot_" + n_robot_id, 1 );
		self thread start_footprint_warning_vo( n_robot_id );
	}
	if ( n_robot_id == 0 )
	{
		animationid = self getanimfromasd( "zm_robot_walk_nml", 0 );
		str_anim_scripted_name = "zm_robot_walk_nml";
		s_robot_path = getstruct( "anim_align_robot_nml", "targetname" );
		s_robot_path.angles = ( 0, 0, 0 );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 0 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self waittillmatch( "scripted_walk" );
		return "end";
		animationid = self getanimfromasd( "zm_robot_walk_nml", 1 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 1 );
		self waittillmatch( "scripted_walk" );
		return "end";
		animationid = self getanimfromasd( "zm_robot_walk_nml", 2 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 2 );
		self waittillmatch( "scripted_walk" );
		return "end";
		self notify( "giant_robot_stop" );
	}
	else if ( n_robot_id == 1 )
	{
		animationid = self getanimfromasd( "zm_robot_walk_trenches", 0 );
		str_anim_scripted_name = "zm_robot_walk_trenches";
		s_robot_path = getstruct( "anim_align_robot_trenches", "targetname" );
		s_robot_path.angles = ( 0, 0, 0 );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 0 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self waittillmatch( "scripted_walk" );
		return "end";
		animationid = self getanimfromasd( "zm_robot_walk_trenches", 1 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 1 );
		self waittillmatch( "scripted_walk" );
		return "end";
		animationid = self getanimfromasd( "zm_robot_walk_trenches", 2 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 2 );
		self waittillmatch( "scripted_walk" );
		return "end";
		self notify( "giant_robot_stop" );
	}
	else if ( n_robot_id == 2 )
	{
		animationid = self getanimfromasd( "zm_robot_walk_village", 0 );
		str_anim_scripted_name = "zm_robot_walk_village";
		s_robot_path = getstruct( "anim_align_robot_village", "targetname" );
		s_robot_path.angles = ( 0, 0, 0 );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 0 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self waittillmatch( "scripted_walk" );
		return "end";
		animationid = self getanimfromasd( "zm_robot_walk_village", 1 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 1 );
		self waittillmatch( "scripted_walk" );
		return "end";
		animationid = self getanimfromasd( "zm_robot_walk_village", 2 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 2 );
		self waittillmatch( "scripted_walk" );
		return "end";
		self notify( "giant_robot_stop" );
	}
	else if ( n_robot_id == 3 )
	{
		animationid = self getanimfromasd( "zm_robot_walk_intro", 0 );
		str_anim_scripted_name = "zm_robot_walk_intro";
		s_robot_path = getstruct( "anim_align_robot_trenches", "targetname" );
		s_robot_path.angles = ( 0, 0, 0 );
		self animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 0 );
		self thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
		self waittillmatch( "scripted_walk" );
		return "end";
		self notify( "giant_robot_stop" );
	}
	if ( n_robot_id != 3 )
	{
		level setclientfield( "start_anim_robot_" + n_robot_id, 0 );
	}
}

sndgrthreads( side )
{
	self thread sndrobot( "soundfootstart_" + side, "zmb_robot_leg_move_" + side, side );
	self thread sndrobot( "soundfootwarning_" + side, "zmb_robot_foot_alarm", side );
	self thread sndrobot( "soundfootdown_" + side, "zmb_robot_leg_whoosh", side );
	self thread sndrobot( "soundfootalarm_" + side, "zmb_robot_pre_stomp_a", side );
}

sndrobot( notetrack, alias, side )
{
	self endon( "giant_robot_stop" );
	if ( side == "right" )
	{
		str_tag = "TAG_ATTACH_HATCH_RI";
	}
	else
	{
		if ( side == "left" )
		{
			str_tag = "TAG_ATTACH_HATCH_LE";
		}
	}
	while ( 1 )
	{
		self waittillmatch( "scripted_walk" );
		return notetrack;
		self playsoundontag( alias, str_tag );
		wait 0,1;
	}
}

monitor_footsteps( trig_stomp_kill, foot_side )
{
	self endon( "death" );
	self endon( "giant_robot_stop" );
	str_start_stomp = "kill_zombies_" + foot_side + "foot_1";
	str_end_stomp = "footstep_" + foot_side + "_large";
	while ( 1 )
	{
		self waittillmatch( "scripted_walk" );
		return str_start_stomp;
		self thread toggle_kill_trigger_flag( trig_stomp_kill, 1, foot_side );
		self waittillmatch( "scripted_walk" );
		return str_end_stomp;
		if ( self.giant_robot_id == 0 && foot_side == "left" )
		{
			self thread toggle_wind_bunker_collision();
		}
		else
		{
			if ( self.giant_robot_id == 1 && foot_side == "left" )
			{
				self thread toggle_tank_bunker_collision();
			}
		}
		wait 0,5;
		self thread toggle_kill_trigger_flag( trig_stomp_kill, 0, foot_side );
	}
}

monitor_footsteps_fx( trig_stomp_kill, foot_side )
{
	self endon( "death" );
	self endon( "giant_robot_stop" );
	str_end_stomp = "footstep_" + foot_side + "_large";
	while ( 1 )
	{
		level setclientfield( "play_foot_stomp_fx_robot_" + self.giant_robot_id, 0 );
		self waittillmatch( "scripted_walk" );
		return str_end_stomp;
		if ( foot_side == "right" )
		{
			level setclientfield( "play_foot_stomp_fx_robot_" + self.giant_robot_id, 1 );
		}
		else
		{
			level setclientfield( "play_foot_stomp_fx_robot_" + self.giant_robot_id, 2 );
		}
		trig_stomp_kill thread rumble_and_shake( self );
		if ( self.giant_robot_id == 2 )
		{
			self thread church_ceiling_fxanim( foot_side );
		}
		else
		{
			if ( self.giant_robot_id == 0 )
			{
				self thread play_pap_shake_fxanim( foot_side );
			}
		}
		wait_network_frame();
	}
}

monitor_shadow_notetracks( foot_side )
{
	self endon( "death" );
	self endon( "giant_robot_stop" );
	while ( 1 )
	{
		self waittillmatch( "scripted_walk" );
		return "shadow_" + foot_side;
		start_robot_stomp_warning_vo( foot_side );
	}
}

rumble_and_shake( robot )
{
	a_players = get_players();
	wait 0,2;
	_a893 = a_players;
	_k893 = getFirstArrayKey( _a893 );
	while ( isDefined( _k893 ) )
	{
		player = _a893[ _k893 ];
		if ( is_player_valid( player ) )
		{
			if ( isDefined( player.in_giant_robot_head ) )
			{
				if ( isDefined( player.giant_robot_transition ) && player.giant_robot_transition )
				{
					break;
				}
				else
				{
					if ( player.in_giant_robot_head == robot.giant_robot_id )
					{
						player setclientfieldtoplayer( "giant_robot_rumble_and_shake", 2 );
					}
					else
					{
					}
				}
				else dist = distance( player.origin, self.origin );
				if ( dist < 1500 )
				{
					player setclientfieldtoplayer( "giant_robot_rumble_and_shake", 3 );
					level notify( "sam_clue_giant" );
				}
				else if ( dist < 3000 )
				{
					player setclientfieldtoplayer( "giant_robot_rumble_and_shake", 2 );
				}
				else if ( dist < 6000 )
				{
					player setclientfieldtoplayer( "giant_robot_rumble_and_shake", 1 );
				}
				else
				{
				}
				player thread turn_clientside_rumble_off();
			}
		}
		_k893 = getNextArrayKey( _a893, _k893 );
	}
}

toggle_kill_trigger_flag( trig_stomp, b_flag, foot_side )
{
	if ( !isDefined( foot_side ) )
	{
		foot_side = undefined;
	}
	if ( b_flag )
	{
		self ent_flag_set( "kill_trigger_active" );
		trig_stomp thread activate_kill_trigger( self, foot_side );
	}
	else
	{
		self ent_flag_clear( "kill_trigger_active" );
		level notify( "stop_kill_trig_think" );
		if ( self ent_flag( "robot_head_entered" ) )
		{
			self ent_flag_clear( "robot_head_entered" );
			self thread giant_robot_close_head_entrance( foot_side );
			level thread giant_robot_head_teleport_timeout( self.giant_robot_id );
		}
	}
}

activate_kill_trigger( robot, foot_side )
{
	level endon( "stop_kill_trig_think" );
	if ( foot_side == "left" )
	{
		str_foot_tag = "TAG_ATTACH_HATCH_LE";
	}
	else
	{
		if ( foot_side == "right" )
		{
			str_foot_tag = "TAG_ATTACH_HATCH_RI";
		}
	}
	while ( robot ent_flag( "kill_trigger_active" ) )
	{
		a_zombies = getaispeciesarray( level.zombie_team, "all" );
		a_zombies_to_kill = [];
		_a985 = a_zombies;
		_k985 = getFirstArrayKey( _a985 );
		while ( isDefined( _k985 ) )
		{
			zombie = _a985[ _k985 ];
			if ( distancesquared( zombie.origin, self.origin ) < 360000 )
			{
				if ( isDefined( zombie.is_giant_robot ) && zombie.is_giant_robot )
				{
					break;
				}
				else
				{
					if ( isDefined( zombie.marked_for_death ) && zombie.marked_for_death )
					{
						break;
					}
					else
					{
						if ( isDefined( zombie.robot_stomped ) && zombie.robot_stomped )
						{
							break;
						}
						else
						{
							if ( zombie istouching( self ) )
							{
								if ( isDefined( zombie.is_mechz ) && zombie.is_mechz )
								{
									zombie thread maps/mp/zombies/_zm_ai_mechz::mechz_robot_stomp_callback();
									break;
								}
								else
								{
									zombie setgoalpos( zombie.origin );
									zombie.marked_for_death = 1;
									a_zombies_to_kill[ a_zombies_to_kill.size ] = zombie;
									break;
								}
								else
								{
									if ( isDefined( zombie.is_mechz ) && !zombie.is_mechz && isDefined( zombie.has_legs ) && zombie.has_legs && isDefined( zombie.completed_emerging_into_playable_area ) && zombie.completed_emerging_into_playable_area )
									{
										n_my_z = zombie.origin[ 2 ];
										v_giant_robot = robot gettagorigin( str_foot_tag );
										n_giant_robot_z = v_giant_robot[ 2 ];
										z_diff = abs( n_my_z - n_giant_robot_z );
										if ( z_diff <= 100 )
										{
											zombie.v_punched_from = self.origin;
											zombie animcustom( ::maps/mp/zombies/_zm_weap_one_inch_punch::knockdown_zombie_animate );
										}
									}
								}
							}
						}
					}
				}
			}
			_k985 = getNextArrayKey( _a985, _k985 );
		}
		if ( a_zombies_to_kill.size > 0 )
		{
			level thread zombie_stomp_death( robot, a_zombies_to_kill );
			robot thread zombie_stomped_by_gr_vo( foot_side );
		}
		if ( isDefined( level.maxis_quadrotor ) )
		{
			if ( level.maxis_quadrotor istouching( self ) )
			{
				level.maxis_quadrotor thread quadrotor_stomp_death();
			}
		}
		a_boxes = getentarray( "foot_box", "script_noteworthy" );
		_a1052 = a_boxes;
		_k1052 = getFirstArrayKey( _a1052 );
		while ( isDefined( _k1052 ) )
		{
			m_box = _a1052[ _k1052 ];
			if ( m_box istouching( self ) )
			{
				m_box notify( "robot_foot_stomp" );
			}
			_k1052 = getNextArrayKey( _a1052, _k1052 );
		}
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( is_player_valid( players[ i ], 0, 1 ) )
			{
				if ( !players[ i ] istouching( self ) )
				{
					i++;
					continue;
				}
				else if ( players[ i ] is_in_giant_robot_footstep_safe_spot() )
				{
					i++;
					continue;
				}
				else if ( isDefined( players[ i ].in_giant_robot_head ) )
				{
					i++;
					continue;
				}
				else if ( isDefined( players[ i ].is_stomped ) && players[ i ].is_stomped )
				{
					i++;
					continue;
				}
				else
				{
					if ( !level.gr_foot_hatch_closed[ robot.giant_robot_id ] && isDefined( robot.hatch_foot ) && isDefined( robot.b_has_hatch ) && robot.b_has_hatch && issubstr( self.targetname, robot.hatch_foot ) && !self player_is_in_laststand() )
					{
						players[ i ].ignoreme = 1;
						players[ i ].teleport_initial_origin = self.origin;
						if ( robot.giant_robot_id == 0 )
						{
							level thread maps/mp/zm_tomb_teleporter::stargate_teleport_player( "head_0_teleport_player", players[ i ], 4, 0 );
							players[ i ].in_giant_robot_head = 0;
						}
						else if ( robot.giant_robot_id == 1 )
						{
							level thread maps/mp/zm_tomb_teleporter::stargate_teleport_player( "head_1_teleport_player", players[ i ], 4, 0 );
							players[ i ].in_giant_robot_head = 1;
							if ( players[ i ] maps/mp/zombies/_zm_zonemgr::player_in_zone( "zone_bunker_4d" ) || players[ i ] maps/mp/zombies/_zm_zonemgr::player_in_zone( "zone_bunker_4c" ) )
							{
								players[ i ].entered_foot_from_tank_bunker = 1;
							}
						}
						else
						{
							level thread maps/mp/zm_tomb_teleporter::stargate_teleport_player( "head_2_teleport_player", players[ i ], 4, 0 );
							players[ i ].in_giant_robot_head = 2;
						}
						robot ent_flag_set( "robot_head_entered" );
						players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_giant_robot_accessed", 0 );
						players[ i ] maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_giant_robot_accessed" );
						players[ i ] playsoundtoplayer( "zmb_bot_elevator_ride_up", players[ i ] );
						start_wait = 0;
						black_screen_wait = 4;
						fade_in_time = 0,01;
						fade_out_time = 0,2;
						players[ i ] thread fadetoblackforxsec( start_wait, black_screen_wait, fade_in_time, fade_out_time, "white" );
						n_transition_time = start_wait + black_screen_wait + fade_in_time + fade_out_time;
						n_start_time = start_wait + fade_in_time;
						players[ i ] thread player_transition_into_robot_head_start( n_start_time );
						players[ i ] thread player_transition_into_robot_head_finish( n_transition_time );
						players[ i ] thread player_death_watch_on_giant_robot();
						i++;
						continue;
					}
					else if ( isDefined( players[ i ].dig_vars[ "has_helmet" ] ) && players[ i ].dig_vars[ "has_helmet" ] )
					{
						players[ i ] thread player_stomp_fake_death( robot );
					}
					else
					{
						players[ i ] thread player_stomp_death( robot );
					}
					start_wait = 0;
					black_screen_wait = 5;
					fade_in_time = 0,01;
					fade_out_time = 0,2;
					players[ i ] thread fadetoblackforxsec( start_wait, black_screen_wait, fade_in_time, fade_out_time, "black", 1 );
				}
			}
			i++;
		}
		wait 0,05;
	}
}

is_in_giant_robot_footstep_safe_spot()
{
	b_is_in_safe_spot = 0;
	while ( isDefined( level.giant_robot_footstep_safe_spots ) )
	{
		_a1166 = level.giant_robot_footstep_safe_spots;
		_k1166 = getFirstArrayKey( _a1166 );
		while ( isDefined( _k1166 ) )
		{
			e_volume = _a1166[ _k1166 ];
			if ( self istouching( e_volume ) )
			{
				b_is_in_safe_spot = 1;
				break;
			}
			else
			{
				_k1166 = getNextArrayKey( _a1166, _k1166 );
			}
		}
	}
	return b_is_in_safe_spot;
}

player_stomp_death( robot )
{
	self endon( "death" );
	self endon( "disconnect" );
	self.is_stomped = 1;
	self playsound( "zmb_zombie_arc" );
	self freezecontrols( 1 );
	if ( self player_is_in_laststand() )
	{
		self shellshock( "explosion", 7 );
	}
	else
	{
		self dodamage( self.health, self.origin, robot );
	}
	self maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_giant_robot_stomped", 0 );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_giant_robot_stomped" );
	wait 5;
	self.is_stomped = 0;
	if ( isDefined( self.hostmigrationcontrolsfrozen ) && !self.hostmigrationcontrolsfrozen )
	{
		self freezecontrols( 0 );
	}
	self thread play_robot_crush_player_vo();
}

player_stomp_fake_death( robot )
{
	self endon( "death" );
	self endon( "disconnect" );
	self.is_stomped = 1;
	self playsound( "zmb_zombie_arc" );
	self freezecontrols( 1 );
	self setstance( "prone" );
	self shellshock( "explosion", 7 );
	wait 5;
	self.is_stomped = 0;
	if ( isDefined( self.hostmigrationcontrolsfrozen ) && !self.hostmigrationcontrolsfrozen )
	{
		self freezecontrols( 0 );
	}
	if ( isDefined( self.ee_stepped_on ) && !self.ee_stepped_on )
	{
		self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "robot_crush_golden" );
		self.ee_stepped_on = 1;
	}
}

zombie_stomp_death( robot, a_zombies_to_kill )
{
	n_interval = 0;
	i = 0;
	while ( i < a_zombies_to_kill.size )
	{
		zombie = a_zombies_to_kill[ i ];
		if ( !isDefined( zombie ) || !isalive( zombie ) )
		{
			i++;
			continue;
		}
		else
		{
			zombie dodamage( zombie.health, zombie.origin, robot );
			n_interval++;
			if ( n_interval >= 4 )
			{
				wait_network_frame();
				n_interval = 0;
			}
		}
		i++;
	}
}

quadrotor_stomp_death()
{
	self endon( "death" );
	self delete();
}

toggle_wind_bunker_collision()
{
	s_org = getstruct( "wind_tunnel_bunker", "script_noteworthy" );
	v_foot = self gettagorigin( "TAG_ATTACH_HATCH_LE" );
	if ( distance2dsquared( s_org.origin, v_foot ) < 57600 )
	{
		level notify( "wind_bunker_collision_on" );
		wait 5;
		level notify( "wind_bunker_collision_off" );
	}
}

toggle_tank_bunker_collision()
{
	s_org = getstruct( "tank_bunker", "script_noteworthy" );
	v_foot = self gettagorigin( "TAG_ATTACH_HATCH_LE" );
	if ( distance2dsquared( s_org.origin, v_foot ) < 57600 )
	{
		level notify( "tank_bunker_collision_on" );
		wait 5;
		level notify( "tank_bunker_collision_off" );
	}
}

handle_wind_tunnel_bunker_collision()
{
	e_collision = getent( "clip_foot_bottom_wind", "targetname" );
	e_collision notsolid();
	e_collision connectpaths();
	while ( 1 )
	{
		level waittill( "wind_bunker_collision_on" );
		wait 0,1;
		e_collision solid();
		e_collision disconnectpaths();
		level waittill( "wind_bunker_collision_off" );
		e_collision notsolid();
		e_collision connectpaths();
	}
}

handle_tank_bunker_collision()
{
	e_collision = getent( "clip_foot_bottom_tank", "targetname" );
	e_collision notsolid();
	e_collision connectpaths();
	while ( 1 )
	{
		level waittill( "tank_bunker_collision_on" );
		wait 0,1;
		e_collision solid();
		e_collision disconnectpaths();
		level waittill( "tank_bunker_collision_off" );
		e_collision notsolid();
		e_collision connectpaths();
	}
}

church_ceiling_fxanim( foot_side )
{
	if ( foot_side == "left" )
	{
		tag_foot = self gettagorigin( "TAG_ATTACH_HATCH_LE" );
	}
	else
	{
		tag_foot = self gettagorigin( "TAG_ATTACH_HATCH_RI" );
	}
	s_church = getstruct( "giant_robot_church_marker", "targetname" );
	n_distance = distance2dsquared( tag_foot, s_church.origin );
	if ( n_distance < 1000000 )
	{
		level setclientfield( "church_ceiling_fxanim", 1 );
		wait_network_frame();
		level setclientfield( "church_ceiling_fxanim", 0 );
	}
}

play_pap_shake_fxanim( foot_side )
{
	if ( foot_side == "left" )
	{
		tag_foot = self gettagorigin( "TAG_ATTACH_HATCH_LE" );
	}
	else
	{
		tag_foot = self gettagorigin( "TAG_ATTACH_HATCH_RI" );
	}
	s_pap = getstruct( "giant_robot_pap_marker", "targetname" );
	wait 0,2;
	n_distance = distance2dsquared( tag_foot, s_pap.origin );
	if ( n_distance < 2250000 )
	{
		level setclientfield( "pap_monolith_ring_shake", 1 );
		wait_network_frame();
		level setclientfield( "pap_monolith_ring_shake", 0 );
	}
}

player_transition_into_robot_head_start( n_start_time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self.giant_robot_transition = 1;
	self.dontspeak = 1;
	self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 3 );
	wait 1,5;
	self setclientfieldtoplayer( "player_rumble_and_shake", 4 );
}

player_transition_into_robot_head_finish( n_transition_time )
{
	self endon( "death" );
	self endon( "disconnect" );
	wait n_transition_time;
	self setclientfieldtoplayer( "player_rumble_and_shake", 0 );
	self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 0 );
	self.giant_robot_transition = 0;
	wait 2;
	if ( !flag( "story_vo_playing" ) )
	{
		self.dontspeak = 0;
		self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "enter_robot" );
	}
	if ( !isDefined( level.sndrobotheadcount ) || level.sndrobotheadcount == 0 )
	{
		level.sndrobotheadcount = 4;
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "zone_robot_head" );
	}
	else
	{
		level.sndrobotheadcount--;

	}
}

gr_head_exit_trigger_start( s_origin )
{
	s_origin.unitrigger_stub = spawnstruct();
	s_origin.unitrigger_stub.origin = s_origin.origin;
	s_origin.unitrigger_stub.radius = 36;
	s_origin.unitrigger_stub.height = 256;
	s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	s_origin.unitrigger_stub.hint_string = &"ZM_TOMB_EHT";
	s_origin.unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_origin.unitrigger_stub.require_look_at = 1;
	s_origin.unitrigger_stub.target = s_origin.target;
	s_origin.unitrigger_stub.script_int = s_origin.script_int;
	s_origin.unitrigger_stub.is_available = 1;
	s_origin.unitrigger_stub.prompt_and_visibility_func = ::gr_head_eject_trigger_visibility;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( s_origin.unitrigger_stub, 1 );
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, ::player_exits_giant_robot_head_trigger_think );
}

gr_head_eject_trigger_visibility( player )
{
	if ( isDefined( self.stub.is_available )b_is_invis = !self.stub.is_available;
	self setinvisibletoplayer( player, b_is_invis );
	self sethintstring( self.stub.hint_string );
	return !b_is_invis;
}

reset_gr_head_unitriggers()
{
	maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::player_exits_giant_robot_head_trigger_think );
}

player_exits_giant_robot_head_trigger_think()
{
	self endon( "tube_used_for_timeout" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( isDefined( self.stub.is_available ) && !self.stub.is_available )
		{
			continue;
		}
		if ( !isplayer( player ) || !is_player_valid( player ) )
		{
			continue;
		}
		level thread init_player_eject_logic( self.stub, player );
		self.stub.is_available = 0;
	}
}

init_player_eject_logic( s_unitrigger, player, b_timeout )
{
	if ( !isDefined( b_timeout ) )
	{
		b_timeout = 0;
	}
	s_unitrigger.is_available = 0;
	s_origin = getstruct( s_unitrigger.target, "targetname" );
	v_origin = s_origin.origin;
	v_angles = s_origin.angles;
	m_linkpoint = spawn_model( "tag_origin", v_origin, v_angles );
	if ( isDefined( level.giant_robot_head_player_eject_thread_custom_func ) )
	{
		player thread [[ level.giant_robot_head_player_eject_thread_custom_func ]]( m_linkpoint, s_origin.script_noteworthy, b_timeout );
	}
	else
	{
		player thread giant_robot_head_player_eject_thread( m_linkpoint, s_origin.script_noteworthy, b_timeout );
	}
	tube_clone = player maps/mp/zombies/_zm_clone::spawn_player_clone( player, player.origin, undefined );
	player thread giant_robot_eject_disconnect_watcher( m_linkpoint, tube_clone );
	tube_clone linkto( m_linkpoint, "tag_origin", ( 0, 0, 1 ), ( 0, 0, 1 ) );
	tube_clone.ignoreme = 1;
	tube_clone show();
	tube_clone detachall();
	tube_clone setvisibletoall();
	tube_clone setinvisibletoplayer( player );
	tube_clone maps/mp/zombies/_zm_clone::clone_animate( "idle" );
	tube_clone thread tube_clone_falls_to_earth( m_linkpoint );
	m_linkpoint waittill( "movedone" );
	wait 6;
	s_unitrigger.is_available = 1;
}

giant_robot_head_player_eject_thread( m_linkpoint, str_tube, b_timeout )
{
	if ( !isDefined( b_timeout ) )
	{
		b_timeout = 0;
	}
	self endon( "death_or_disconnect" );
	self maps/mp/zm_tomb_giant_robot_ffotd::giant_robot_head_player_eject_start();
	str_current_weapon = self getcurrentweapon();
	self disableweapons();
	self disableoffhandweapons();
	self enableinvulnerability();
	self setstance( "stand" );
	self allowstand( 1 );
	self allowcrouch( 0 );
	self allowprone( 0 );
	self playerlinktodelta( m_linkpoint, "tag_origin", 1, 20, 20, 20, 20 );
	self setplayerangles( m_linkpoint.angles );
	self ghost();
	self.dontspeak = 1;
	self setclientfieldtoplayer( "isspeaking", 1 );
	self notify( "teleport" );
	self.giant_robot_transition = 1;
	self playsoundtoplayer( "zmb_bot_timeout_alarm", self );
	self.old_angles = self.angles;
	if ( !b_timeout )
	{
		self setclientfield( "eject_steam_fx", 1 );
		self thread in_tube_manual_looping_rumble();
		wait 3;
	}
	self stopsounds();
	wait_network_frame();
	self playsoundtoplayer( "zmb_giantrobot_exit", self );
	self notify( "end_in_tube_rumble" );
	self thread exit_gr_manual_looping_rumble();
	m_linkpoint moveto( m_linkpoint.origin + vectorScale( ( 0, 0, 1 ), 2000 ), 2,5 );
	self thread fadetoblackforxsec( 0, 2, 1, 0, "white" );
	wait 1;
	m_linkpoint moveto( self.teleport_initial_origin + vectorScale( ( 0, 0, 1 ), 3000 ), 0,05 );
	m_linkpoint.angles = vectorScale( ( 0, 0, 1 ), 90 );
	self enableweapons();
	self giveweapon( "falling_hands_tomb_zm" );
	self switchtoweaponimmediate( "falling_hands_tomb_zm" );
	self setweaponammoclip( "falling_hands_tomb_zm", 0 );
	wait 1;
	self playsoundtoplayer( "zmb_giantrobot_fall", self );
	self playerlinktodelta( m_linkpoint, "tag_origin", 1, 180, 180, 20, 20 );
	m_linkpoint moveto( self.teleport_initial_origin, 3, 1 );
	m_linkpoint thread play_gr_eject_impact_player_fx( self );
	m_linkpoint notify( "start_gr_eject_fall_to_earth" );
	self thread player_screams_while_falling();
	wait 2,75;
	self thread fadetoblackforxsec( 0, 1, 0, 0,5, "black" );
	self waittill( "gr_eject_fall_complete" );
	self takeweapon( "falling_hands_tomb_zm" );
	if ( isDefined( str_current_weapon ) && str_current_weapon != "none" )
	{
		self switchtoweaponimmediate( str_current_weapon );
	}
	self enableoffhandweapons();
	self unlink();
	m_linkpoint delete();
	self teleport_player_to_gr_footprint_safe_spot();
	self show();
	self setplayerangles( self.old_angles );
	self disableinvulnerability();
	self.dontspeak = 0;
	self allowstand( 1 );
	self allowcrouch( 1 );
	self allowprone( 1 );
	self setclientfieldtoplayer( "isspeaking", 0 );
	self.in_giant_robot_head = undefined;
	self.teleport_initial_origin = undefined;
	self.old_angles = undefined;
	self thread gr_eject_landing_rumble();
	self thread gr_eject_landing_rumble_on_position();
	self setclientfield( "eject_steam_fx", 0 );
	n_post_eject_time = 2,5;
	self setstance( "prone" );
	self shellshock( "explosion", n_post_eject_time );
	self.giant_robot_transition = 0;
	self notify( "gr_eject_sequence_complete" );
	if ( !flag( "story_vo_playing" ) )
	{
		self delay_thread( 3, ::maps/mp/zombies/_zm_audio::create_and_play_dialog, "general", "air_chute_landing" );
	}
/#
	debug_level = getDvarInt( "zombie_cheat" );
	if ( isDefined( debug_level ) && debug_level )
	{
		self enableinvulnerability();
#/
	}
	wait n_post_eject_time;
	self.ignoreme = 0;
	self maps/mp/zm_tomb_giant_robot_ffotd::giant_robot_head_player_eject_end();
}

player_screams_while_falling()
{
	self endon( "disconnect" );
	self stopsounds();
	wait_network_frame();
	self playsoundtoplayer( "vox_plr_" + self.characterindex + "_exit_robot_0", self );
}

tube_clone_falls_to_earth( m_linkpoint )
{
	m_linkpoint waittill( "start_gr_eject_fall_to_earth" );
	self maps/mp/zombies/_zm_clone::clone_animate( "falling" );
	m_linkpoint waittill( "movedone" );
	self delete();
}

in_tube_manual_looping_rumble()
{
	self endon( "end_in_tube_rumble" );
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 1 );
		wait_network_frame();
		self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 0 );
		wait_network_frame();
		wait 0,1;
	}
}

exit_gr_manual_looping_rumble()
{
	self endon( "end_exit_gr_rumble" );
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 1 );
		wait_network_frame();
		self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 0 );
		wait_network_frame();
		wait 0,1;
	}
}

gr_eject_landing_rumble()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "end_exit_gr_rumble" );
	wait_network_frame();
	self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 0 );
	wait_network_frame();
	self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 3 );
	wait_network_frame();
	self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 0 );
}

gr_eject_landing_rumble_on_position()
{
	self endon( "death" );
	self endon( "disconnect" );
	a_players = getplayers();
	_a1781 = a_players;
	_k1781 = getFirstArrayKey( _a1781 );
	while ( isDefined( _k1781 ) )
	{
		player = _a1781[ _k1781 ];
		if ( player == self )
		{
		}
		else if ( isDefined( player.giant_robot_transition ) && player.giant_robot_transition )
		{
		}
		else
		{
			if ( distance2dsquared( player.origin, self.origin ) < 250000 )
			{
				player thread gr_eject_landing_rumble();
			}
		}
		_k1781 = getNextArrayKey( _a1781, _k1781 );
	}
}

teleport_player_to_gr_footprint_safe_spot()
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( isDefined( self.entered_foot_from_tank_bunker ) && self.entered_foot_from_tank_bunker )
	{
		a_s_orgs = getstructarray( "tank_platform_safe_spots", "targetname" );
		_a1809 = a_s_orgs;
		_k1809 = getFirstArrayKey( _a1809 );
		while ( isDefined( _k1809 ) )
		{
			struct = _a1809[ _k1809 ];
			if ( !positionwouldtelefrag( struct.origin ) )
			{
				self setorigin( struct.origin );
				break;
			}
			else
			{
				_k1809 = getNextArrayKey( _a1809, _k1809 );
			}
		}
		self.entered_foot_from_tank_bunker = 0;
		return;
	}
	a_s_footprints = getstructarray( "giant_robot_footprint", "targetname" );
	a_s_footprints = get_array_of_closest( self.teleport_initial_origin, a_s_footprints );
	s_footprint = a_s_footprints[ 0 ];
	a_v_offset = [];
	a_v_offset[ 0 ] = ( 0, 0, 1 );
	a_v_offset[ 1 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 2 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 3 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 4 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 5 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 6 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 7 ] = vectorScale( ( 0, 0, 1 ), 50 );
	a_v_offset[ 8 ] = vectorScale( ( 0, 0, 1 ), 50 );
	i = 0;
	while ( i < a_v_offset.size )
	{
		v_origin = s_footprint.origin + a_v_offset[ i ];
		v_trace_start = v_origin + vectorScale( ( 0, 0, 1 ), 100 );
		v_final = playerphysicstrace( v_trace_start, v_origin );
		if ( !positionwouldtelefrag( v_final ) )
		{
			self setorigin( v_final );
			return;
		}
		else
		{
			i++;
		}
	}
}

giant_robot_head_teleport_timeout( n_robot_id )
{
	wait 15;
	n_players_in_robot = count_players_in_gr_head( n_robot_id );
	if ( n_players_in_robot == 0 )
	{
		return;
	}
	while ( flag( "maxis_audiolog_gr" + n_robot_id + "_playing" ) )
	{
		wait 0,1;
	}
	n_players_in_robot = count_players_in_gr_head( n_robot_id );
	if ( n_players_in_robot == 0 )
	{
		return;
	}
	level thread play_timeout_warning_vo( n_robot_id );
	maps/mp/zm_tomb_vo::reset_maxis_audiolog_unitrigger( n_robot_id );
	level setclientfield( "eject_warning_fx_robot_" + n_robot_id, 1 );
	a_players = getplayers();
	a_players[ 0 ] setclientfield( "all_tubes_play_eject_steam_fx", 1 );
	level waittill( "timeout_warning_vo_complete_" + n_robot_id );
	a_gr_head_triggers = getstructarray( "giant_robot_head_exit_trigger", "script_noteworthy" );
	a_shutdown_triggers = [];
	_a1896 = a_gr_head_triggers;
	_k1896 = getFirstArrayKey( _a1896 );
	while ( isDefined( _k1896 ) )
	{
		trigger = _a1896[ _k1896 ];
		if ( trigger.script_int == n_robot_id )
		{
			if ( isDefined( trigger.unitrigger_stub.is_available ) && trigger.unitrigger_stub.is_available )
			{
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( trigger.unitrigger_stub );
				a_shutdown_triggers[ a_shutdown_triggers.size ] = trigger;
			}
		}
		_k1896 = getNextArrayKey( _a1896, _k1896 );
	}
	a_players = getplayers();
	a_m_linkspots = [];
	_a1911 = a_players;
	_k1911 = getFirstArrayKey( _a1911 );
	while ( isDefined( _k1911 ) )
	{
		player = _a1911[ _k1911 ];
		if ( isDefined( player.in_giant_robot_head ) && player.in_giant_robot_head == n_robot_id )
		{
			if ( isDefined( player.giant_robot_transition ) && !player.giant_robot_transition )
			{
				if ( player player_is_in_laststand() )
				{
					if ( isDefined( player.waiting_to_revive ) && player.waiting_to_revive && a_players.size <= 1 )
					{
						flag_set( "instant_revive" );
						player.stopflashingbadlytime = getTime() + 1000;
						wait_network_frame();
						flag_clear( "instant_revive" );
						break;
					}
					else
					{
						player thread maps/mp/zombies/_zm_laststand::bleed_out();
						player notify( "gr_head_forced_bleed_out" );
						break;
					}
				}
				else
				{
					if ( isalive( player ) )
					{
						m_linkspot = spawn_model( "tag_origin", player.origin, player.angles );
						a_m_linkspots[ a_m_linkspots.size ] = m_linkspot;
						player start_drag_player_to_eject_tube( n_robot_id, m_linkspot );
						wait 0,1;
					}
				}
			}
		}
		_k1911 = getNextArrayKey( _a1911, _k1911 );
	}
	wait 10;
	maps/mp/zm_tomb_vo::restart_maxis_audiolog_unitrigger( n_robot_id );
	level setclientfield( "eject_warning_fx_robot_" + n_robot_id, 0 );
	a_players = getplayers();
	a_players[ 0 ] setclientfield( "all_tubes_play_eject_steam_fx", 0 );
	_a1958 = a_shutdown_triggers;
	_k1958 = getFirstArrayKey( _a1958 );
	while ( isDefined( _k1958 ) )
	{
		trigger = _a1958[ _k1958 ];
		if ( trigger.script_int == n_robot_id )
		{
			trigger thread reset_gr_head_unitriggers();
		}
		_k1958 = getNextArrayKey( _a1958, _k1958 );
	}
	while ( a_m_linkspots.size > 0 )
	{
		i = 0;
		while ( i < a_m_linkspots.size )
		{
			if ( isDefined( a_m_linkspots[ i ] ) )
			{
				a_m_linkspots[ i ] delete();
			}
			i++;
		}
	}
}

start_drag_player_to_eject_tube( n_robot_id, m_linkspot )
{
	self endon( "death" );
	self endon( "disconnect" );
	a_gr_head_triggers = getstructarray( "giant_robot_head_exit_trigger", "script_noteworthy" );
	a_gr_head_triggers = get_array_of_closest( self.origin, a_gr_head_triggers );
	_a1987 = a_gr_head_triggers;
	_k1987 = getFirstArrayKey( _a1987 );
	while ( isDefined( _k1987 ) )
	{
		trigger = _a1987[ _k1987 ];
		if ( trigger.unitrigger_stub.script_int == n_robot_id )
		{
			if ( isDefined( trigger.unitrigger_stub.is_available ) && trigger.unitrigger_stub.is_available )
			{
				self thread in_tube_manual_looping_rumble();
				trigger.unitrigger_stub.is_available = 0;
				s_tube = getstruct( trigger.target, "targetname" );
				self playerlinktodelta( m_linkspot, "tag_origin", 1, 20, 20, 20, 20 );
				self thread move_player_to_eject_tube( m_linkspot, s_tube, trigger );
				return;
			}
		}
		else
		{
			_k1987 = getNextArrayKey( _a1987, _k1987 );
		}
	}
}

move_player_to_eject_tube( m_linkspot, s_tube, trigger )
{
	self endon( "death" );
	self endon( "disconnect" );
	self.giant_robot_transition = 1;
	n_speed = 500;
	n_dist = distance( m_linkspot.origin, s_tube.origin );
	n_time = n_dist / n_speed;
	m_linkspot moveto( s_tube.origin, n_time );
	m_linkspot waittill( "movedone" );
	m_linkspot delete();
	level thread init_player_eject_logic( trigger.unitrigger_stub, self, 1 );
}

sndalarmtimeout()
{
	self endon( "teleport" );
	self endon( "disconnect" );
	self playsoundtoplayer( "zmb_bot_timeout_alarm", self );
	wait 2,5;
	self playsoundtoplayer( "zmb_bot_timeout_alarm", self );
}

play_gr_eject_impact_player_fx( player )
{
	player endon( "death" );
	player endon( "disconnect" );
	self waittill( "movedone" );
	player setclientfield( "gr_eject_player_impact_fx", 1 );
	wait_network_frame();
	player notify( "gr_eject_fall_complete" );
	wait 1;
	player setclientfield( "gr_eject_player_impact_fx", 0 );
}

player_death_watch_on_giant_robot()
{
	self endon( "disconnect" );
	self endon( "gr_eject_sequence_complete" );
	self waittill_either( "bled_out", "gr_head_forced_bleed_out" );
	self.entered_foot_from_tank_bunker = undefined;
	self.giant_robot_transition = undefined;
	self.in_giant_robot_head = undefined;
	self.ignoreme = 0;
	self.dontspeak = 0;
}

giant_robot_eject_disconnect_watcher( m_linkpoint, tube_clone )
{
	self endon( "gr_eject_sequence_complete" );
	self waittill( "disconnect" );
	if ( isDefined( m_linkpoint ) )
	{
		m_linkpoint delete();
	}
	if ( isDefined( tube_clone ) )
	{
		tube_clone delete();
	}
}

turn_clientside_rumble_off()
{
	self endon( "death" );
	self endon( "disconnect" );
	wait_network_frame();
	self setclientfieldtoplayer( "giant_robot_rumble_and_shake", 0 );
}

spawn_model( model_name, origin, angles, n_spawnflags )
{
	if ( !isDefined( n_spawnflags ) )
	{
		n_spawnflags = 0;
	}
	if ( !isDefined( origin ) )
	{
		origin = ( 0, 0, 1 );
	}
	model = spawn( "script_model", origin, n_spawnflags );
	model setmodel( model_name );
	if ( isDefined( angles ) )
	{
		model.angles = angles;
	}
	return model;
}

count_players_in_gr_head( n_robot_id )
{
	n_players_in_robot = 0;
	a_players = getplayers();
	_a2116 = a_players;
	_k2116 = getFirstArrayKey( _a2116 );
	while ( isDefined( _k2116 ) )
	{
		player = _a2116[ _k2116 ];
		if ( isDefined( player.in_giant_robot_head ) && player.in_giant_robot_head == n_robot_id )
		{
			n_players_in_robot++;
		}
		_k2116 = getNextArrayKey( _a2116, _k2116 );
	}
	return n_players_in_robot;
}

tomb_standard_intermission()
{
	self closemenu();
	self closeingamemenu();
	level endon( "stop_intermission" );
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "_zombie_game_over" );
	level thread setup_giant_robots_intermission();
	self.score = self.score_total;
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	points = getstructarray( "intermission", "targetname" );
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
					org = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 60 ) );
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

setup_giant_robots_intermission()
{
	i = 0;
	while ( i < 3 )
	{
		ai_giant_robot = getent( "giant_robot_walker_" + i, "targetname" );
		if ( !isDefined( ai_giant_robot ) )
		{
			i++;
			continue;
		}
		else
		{
			ai_giant_robot ghost();
			ai_giant_robot stopanimscripted( 0,05 );
			ai_giant_robot notify( "giant_robot_stop" );
			if ( i == 2 )
			{
				wait_network_frame();
				ai_giant_robot show();
				str_anim_scripted_name = "zm_robot_walk_village";
				s_robot_path = getstruct( "anim_align_robot_village", "targetname" );
				s_robot_path.angles = ( 0, 0, 1 );
				animationid = ai_giant_robot getanimfromasd( "zm_robot_walk_village", 1 );
				ai_giant_robot thread maps/mp/animscripts/zm_shared::donotetracks( "scripted_walk" );
				ai_giant_robot animscripted( s_robot_path.origin, s_robot_path.angles, str_anim_scripted_name, 1 );
			}
		}
		i++;
	}
}

giant_robot_discovered_vo( ai_giant_robot )
{
	ai_giant_robot endon( "giant_robot_stop" );
	self endon( "disconnect" );
	level endon( "giant_robot_discovered" );
	while ( 1 )
	{
		if ( distance2dsquared( self.origin, ai_giant_robot.origin ) < 16000000 )
		{
			if ( self is_player_looking_at( ai_giant_robot.origin + vectorScale( ( 0, 0, 1 ), 2000 ), 0,85 ) )
			{
				if ( isDefined( self.dontspeak ) && !self.dontspeak )
				{
					self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "discover_robot" );
					level.giant_robot_discovered = 1;
					level notify( "giant_robot_discovered" );
					return;
				}
			}
		}
		else
		{
			wait 0,1;
		}
	}
}

three_robot_round_vo( ai_giant_robot )
{
	ai_giant_robot endon( "giant_robot_stop" );
	self endon( "disconnect" );
	level endon( "three_robot_round_vo" );
	while ( 1 )
	{
		if ( distance2dsquared( self.origin, ai_giant_robot.origin ) < 16000000 )
		{
			if ( self is_player_looking_at( ai_giant_robot.origin + vectorScale( ( 0, 0, 1 ), 2000 ), 0,85 ) )
			{
				if ( isDefined( self.dontspeak ) && !self.dontspeak )
				{
					self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "see_robots" );
					level.three_robot_round_vo = 1;
					level notify( "three_robot_round_vo" );
					return;
				}
			}
		}
		else
		{
			wait 0,1;
		}
	}
}

shoot_at_giant_robot_vo( ai_giant_robot )
{
	ai_giant_robot endon( "giant_robot_stop" );
	self endon( "disconnect" );
	level endon( "shoot_robot_vo" );
	while ( 1 )
	{
		while ( distance2dsquared( self.origin, ai_giant_robot.origin ) < 16000000 && self is_player_looking_at( ai_giant_robot.origin + vectorScale( ( 0, 0, 1 ), 2000 ), 0,7 ) )
		{
			self waittill( "weapon_fired" );
			if ( distance2dsquared( self.origin, ai_giant_robot.origin ) < 16000000 && self is_player_looking_at( ai_giant_robot.origin + vectorScale( ( 0, 0, 1 ), 2000 ), 0,7 ) )
			{
				if ( isDefined( self.dontspeak ) && !self.dontspeak )
				{
					self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "shoot_robot" );
					level.shoot_robot_vo = 1;
					level notify( "shoot_robot_vo" );
					return;
				}
			}
		}
		wait 0,1;
	}
}

start_robot_stomp_warning_vo( foot_side )
{
	if ( foot_side == "right" )
	{
		str_tag = "TAG_ATTACH_HATCH_RI";
	}
	else
	{
		if ( foot_side == "left" )
		{
			str_tag = "TAG_ATTACH_HATCH_LE";
		}
	}
	v_origin = self gettagorigin( str_tag );
	a_s_footprint_all = getstructarray( "giant_robot_footprint_center", "targetname" );
	a_s_footprint = [];
	_a2384 = a_s_footprint_all;
	_k2384 = getFirstArrayKey( _a2384 );
	while ( isDefined( _k2384 ) )
	{
		footprint = _a2384[ _k2384 ];
		if ( footprint.script_int == self.giant_robot_id )
		{
			a_s_footprint[ a_s_footprint.size ] = footprint;
		}
		_k2384 = getNextArrayKey( _a2384, _k2384 );
	}
	if ( a_s_footprint.size == 0 )
	{
		return;
	}
	else
	{
		a_s_footprint = get_array_of_closest( v_origin, a_s_footprint );
		s_footprint = a_s_footprint[ 0 ];
	}
	a_players = getplayers();
	_a2404 = a_players;
	_k2404 = getFirstArrayKey( _a2404 );
	while ( isDefined( _k2404 ) )
	{
		player = _a2404[ _k2404 ];
		if ( distance2dsquared( player.origin, s_footprint.origin ) < 160000 )
		{
			player thread play_robot_stomp_warning_vo();
		}
		_k2404 = getNextArrayKey( _a2404, _k2404 );
	}
}

play_robot_stomp_warning_vo()
{
	a_players = getplayers();
	_a2417 = a_players;
	_k2417 = getFirstArrayKey( _a2417 );
	while ( isDefined( _k2417 ) )
	{
		player = _a2417[ _k2417 ];
		if ( player == self )
		{
		}
		else
		{
			if ( distance2dsquared( self.origin, player.origin ) < 640000 )
			{
				if ( player is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ) ) )
				{
					if ( isDefined( player.dontspeak ) && !player.dontspeak )
					{
						player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "warn_robot_foot" );
						return;
					}
				}
			}
		}
		else
		{
			_k2417 = getNextArrayKey( _a2417, _k2417 );
		}
	}
}

zombie_stomped_by_gr_vo( foot_side )
{
	self endon( "giant_robot_stop" );
	if ( foot_side == "right" )
	{
		str_tag = "TAG_ATTACH_HATCH_RI";
	}
	else
	{
		if ( foot_side == "left" )
		{
			str_tag = "TAG_ATTACH_HATCH_LE";
		}
	}
	v_origin = self gettagorigin( str_tag );
	a_players = getplayers();
	_a2454 = a_players;
	_k2454 = getFirstArrayKey( _a2454 );
	while ( isDefined( _k2454 ) )
	{
		player = _a2454[ _k2454 ];
		if ( distancesquared( v_origin, player.origin ) < 640000 )
		{
			if ( player is_player_looking_at( v_origin, 0,25 ) )
			{
				if ( isDefined( player.dontspeak ) && !player.dontspeak )
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "robot_crush_zombie" );
					return;
				}
			}
		}
		_k2454 = getNextArrayKey( _a2454, _k2454 );
	}
}

play_robot_crush_player_vo()
{
	self endon( "disconnect" );
	if ( self player_is_in_laststand() )
	{
		if ( cointoss() )
		{
			n_alt = 1;
		}
		else
		{
			n_alt = 0;
		}
		self playsoundwithnotify( "vox_plr_" + self.characterindex + "_robot_crush_player_" + n_alt, "sound_done" + "vox_plr_" + self.characterindex + "_robot_crush_player_" + n_alt );
	}
}

play_timeout_warning_vo( n_robot_id )
{
	flag_set( "timeout_vo_robot_" + n_robot_id );
	s_origin = getstruct( "eject_warning_fx_robot_" + n_robot_id, "targetname" );
	e_vo_origin = spawn_model( "tag_origin", s_origin.origin );
	e_vo_origin playsoundwithnotify( "vox_maxi_purge_robot_0", "vox_maxi_purge_robot_0_done" );
	e_vo_origin waittill( "vox_maxi_purge_robot_0_done" );
	a_players = getplayers();
	_a2499 = a_players;
	_k2499 = getFirstArrayKey( _a2499 );
	while ( isDefined( _k2499 ) )
	{
		player = _a2499[ _k2499 ];
		if ( isDefined( player.in_giant_robot_head ) && player.in_giant_robot_head == n_robot_id )
		{
			if ( isDefined( player.giant_robot_transition ) && !player.giant_robot_transition )
			{
				if ( isDefined( player.dontspeak ) && !player.dontspeak )
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "purge_robot" );
					break;
				}
			}
		}
		else
		{
			_k2499 = getNextArrayKey( _a2499, _k2499 );
		}
	}
	while ( isDefined( player ) && isDefined( player.isspeaking ) && player.isspeaking )
	{
		wait 0,1;
	}
	wait 1;
	e_vo_origin playsoundwithnotify( "vox_maxi_purge_countdown_0", "vox_maxi_purge_countdown_0_done" );
	e_vo_origin waittill( "vox_maxi_purge_countdown_0_done" );
	wait 1;
	level notify( "timeout_warning_vo_complete_" + n_robot_id );
	e_vo_origin playsoundwithnotify( "vox_maxi_purge_now_0", "vox_maxi_purge_now_0_done" );
	e_vo_origin waittill( "vox_maxi_purge_now_0_done" );
	e_vo_origin delete();
	flag_clear( "timeout_vo_robot_" + n_robot_id );
}

start_footprint_warning_vo( n_robot_id )
{
	wait 20;
	a_structs = getstructarray( "giant_robot_footprint_center", "targetname" );
	_a2540 = a_structs;
	_k2540 = getFirstArrayKey( _a2540 );
	while ( isDefined( _k2540 ) )
	{
		struct = _a2540[ _k2540 ];
		if ( struct.script_int == n_robot_id )
		{
			struct thread footprint_check_for_nearby_players( self );
		}
		_k2540 = getNextArrayKey( _a2540, _k2540 );
	}
}

footprint_check_for_nearby_players( ai_giant_robot )
{
	level endon( "footprint_warning_vo" );
	ai_giant_robot endon( "giant_robot_stop" );
	while ( 1 )
	{
		a_players = getplayers();
		_a2558 = a_players;
		_k2558 = getFirstArrayKey( _a2558 );
		while ( isDefined( _k2558 ) )
		{
			player = _a2558[ _k2558 ];
			if ( distance2dsquared( player.origin, self.origin ) < 90000 )
			{
				if ( distance2dsquared( player.origin, ai_giant_robot.origin ) < 16000000 )
				{
					if ( player.origin[ 0 ] > ai_giant_robot.origin[ 0 ] )
					{
						if ( isDefined( player.dontspeak ) && !player.dontspeak )
						{
							player do_player_general_vox( "general", "warn_robot" );
							level.footprint_warning_vo = 1;
							level notify( "footprint_warning_vo" );
							return;
						}
					}
				}
			}
			_k2558 = getNextArrayKey( _a2558, _k2558 );
		}
		wait 1;
	}
}

setup_giant_robot_devgui()
{
/#
	setdvar( "force_giant_robot_0", "off" );
	setdvar( "force_giant_robot_1", "off" );
	setdvar( "force_giant_robot_2", "off" );
	setdvar( "force_three_robot_round", "off" );
	setdvar( "force_left_foot", "off" );
	setdvar( "force_right_foot", "off" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Giant Robot:1/Force Robot 0 (NML):1" "force_giant_robot_0 on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Giant Robot:1/Force Robot 1 (Trench):2" "force_giant_robot_1 on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Giant Robot:1/Force Robot 2 (Village):3" "force_giant_robot_2 on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Giant Robot:1/Force Three Robot Round:4" "force_three_robot_round on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Giant Robot:1/Force Left Foot:5" "force_left_foot on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Giant Robot:1/Force Right Foot:6" "force_right_foot on"\n" );
	level thread watch_for_force_giant_robot();
#/
}

watch_for_force_giant_robot()
{
/#
	while ( 1 )
	{
		if ( getDvar( "force_giant_robot_0" ) == "on" )
		{
			setdvar( "force_giant_robot_0", "off" );
			if ( isDefined( level.devgui_force_giant_robot ) && level.devgui_force_giant_robot == 0 )
			{
				level.devgui_force_giant_robot = undefined;
				iprintlnbold( "Force Giant Robot off" );
				break;
			}
			else
			{
				level.devgui_force_giant_robot = 0;
				iprintlnbold( "Force Giant Robot 0 (NML)" );
			}
		}
		if ( getDvar( "force_giant_robot_1" ) == "on" )
		{
			setdvar( "force_giant_robot_1", "off" );
			if ( isDefined( level.devgui_force_giant_robot ) && level.devgui_force_giant_robot == 1 )
			{
				level.devgui_force_giant_robot = undefined;
				iprintlnbold( "Force Giant Robot off" );
				break;
			}
			else
			{
				level.devgui_force_giant_robot = 1;
				iprintlnbold( "Force Giant Robot 1 (Trench)" );
			}
		}
		if ( getDvar( "force_giant_robot_2" ) == "on" )
		{
			setdvar( "force_giant_robot_2", "off" );
			if ( isDefined( level.devgui_force_giant_robot ) && level.devgui_force_giant_robot == 2 )
			{
				level.devgui_force_giant_robot = undefined;
				iprintlnbold( "Force Giant Robot off" );
				break;
			}
			else
			{
				level.devgui_force_giant_robot = 2;
				iprintlnbold( "Force Giant Robot 2 (Village)" );
			}
		}
		if ( getDvar( "force_three_robot_round" ) == "on" )
		{
			setdvar( "force_three_robot_round", "off" );
			if ( isDefined( level.devgui_force_three_robot_round ) && level.devgui_force_three_robot_round )
			{
				level.devgui_force_three_robot_round = undefined;
				iprintlnbold( "Force Three Robot Round off" );
				break;
			}
			else
			{
				level.devgui_force_three_robot_round = 1;
				iprintlnbold( "Force Three Robot Round" );
			}
		}
		if ( getDvar( "force_left_foot" ) == "on" )
		{
			setdvar( "force_left_foot", "off" );
			if ( isDefined( level.devgui_force_giant_robot_foot ) && level.devgui_force_giant_robot_foot == "left" )
			{
				level.devgui_force_giant_robot_foot = undefined;
				iprintlnbold( "Force Giant Robot Foot Off" );
				break;
			}
			else
			{
				level.devgui_force_giant_robot_foot = "left";
				iprintlnbold( "Force Giant Robot Hatch on Left Foot" );
			}
		}
		if ( getDvar( "force_right_foot" ) == "on" )
		{
			setdvar( "force_right_foot", "off" );
			if ( isDefined( level.devgui_force_giant_robot_foot ) && level.devgui_force_giant_robot_foot == "right" )
			{
				level.devgui_force_giant_robot_foot = undefined;
				iprintlnbold( "Force Giant Robot Foot Off" );
				break;
			}
			else
			{
				level.devgui_force_giant_robot_foot = "right";
				iprintlnbold( "Force Giant Robot Hatch on Right Foot" );
			}
		}
		wait 0,05;
#/
	}
}

starting_spawn_light()
{
	light = getent( "start_bunker_footprint_light", "targetname" );
	if ( !isDefined( light ) )
	{
		return;
	}
	light setlightintensity( 0 );
	wait 5,4;
	i = 8;
	while ( i <= 16 )
	{
		light setlightintensity( i );
		wait 0,1;
		i += 8;
	}
}
