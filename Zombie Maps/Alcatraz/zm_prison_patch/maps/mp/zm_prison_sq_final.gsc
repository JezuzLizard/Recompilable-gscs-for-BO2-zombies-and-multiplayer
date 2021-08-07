#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_ai_brutus;
#include maps/mp/zm_alcatraz_sq;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/_visionset_mgr;
#include maps/mp/zm_alcatraz_sq_nixie;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

onplayerconnect_sq_final()
{
}

stage_one()
{
	if ( isDefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
	{
		sq_final_easy_cleanup();
		return;
	}
	precachemodel( "p6_zm_al_audio_headset_icon" );
	flag_wait( "quest_completed_thrice" );
	flag_wait( "spoon_obtained" );
	flag_wait( "warden_blundergat_obtained" );
/#
	players = getplayers();
	_a51 = players;
	_k51 = getFirstArrayKey( _a51 );
	while ( isDefined( _k51 ) )
	{
		player = _a51[ _k51 ];
		player.fq_client_hint = newclienthudelem( player );
		player.fq_client_hint.x = 25;
		player.fq_client_hint.y = 200;
		player.fq_client_hint.alignx = "center";
		player.fq_client_hint.aligny = "bottom";
		player.fq_client_hint.fontscale = 1,6;
		player.fq_client_hint.alpha = 1;
		player.fq_client_hint.sort = 20;
		player.fq_client_hint settext( 386 + " - " + 481 + " - " + 101 + " - " + 872 );
		_k51 = getNextArrayKey( _a51, _k51 );
#/
	}
	i = 1;
	while ( i < 4 )
	{
		m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
		m_nixie_tube thread nixie_tube_scramble_protected_effects( i );
		i++;
	}
	level waittill_multiple( "nixie_tube_trigger_1", "nixie_tube_trigger_2", "nixie_tube_trigger_3" );
	level thread nixie_final_codes( 386 );
	level thread nixie_final_codes( 481 );
	level thread nixie_final_codes( 101 );
	level thread nixie_final_codes( 872 );
	level waittill_multiple( "nixie_final_" + 386, "nixie_final_" + 481, "nixie_final_" + 101, "nixie_final_" + 872 );
	nixie_tube_off();
/#
	players = getplayers();
	_a88 = players;
	_k88 = getFirstArrayKey( _a88 );
	while ( isDefined( _k88 ) )
	{
		player = _a88[ _k88 ];
		player.fq_client_hint destroy();
		_k88 = getNextArrayKey( _a88, _k88 );
#/
	}
	m_nixie_tube = getent( "nixie_tube_1", "targetname" );
	m_nixie_tube playsoundwithnotify( "vox_brutus_nixie_right_0", "scary_voice" );
	m_nixie_tube waittill( "scary_voice" );
	wait 3;
	level thread stage_two();
}

sq_final_easy_cleanup()
{
	t_plane_fly_afterlife = getent( "plane_fly_afterlife_trigger", "script_noteworthy" );
	t_plane_fly_afterlife delete();
}

nixie_tube_off()
{
	level notify( "kill_nixie_input" );
	wait 1;
	i = 1;
	while ( i < 4 )
	{
		m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
		j = 0;
		while ( j < 10 )
		{
			m_nixie_tube hidepart( "J_" + j );
			j++;
		}
		wait 0,3;
		i++;
	}
}

nixie_final_codes( nixie_code )
{
	maps/mp/zm_alcatraz_sq_nixie::nixie_tube_add_code( nixie_code );
	level waittill( "nixie_" + nixie_code );
	level notify( "kill_nixie_input" );
	flag_set( "nixie_puzzle_solved" );
	flag_clear( "nixie_ee_flashing" );
	goal_num_1 = maps/mp/zm_alcatraz_sq_nixie::get_split_number( 1, nixie_code );
	goal_num_2 = maps/mp/zm_alcatraz_sq_nixie::get_split_number( 2, nixie_code );
	goal_num_3 = maps/mp/zm_alcatraz_sq_nixie::get_split_number( 3, nixie_code );
	nixie_tube_win_effects_all_tubes_final( goal_num_2, goal_num_3, goal_num_1 );
	flag_set( "nixie_ee_flashing" );
	flag_clear( "nixie_puzzle_solved" );
	maps/mp/zm_alcatraz_sq_nixie::nixie_reset_control( 0 );
	level notify( "nixie_final_" + nixie_code );
}

nixie_tube_scramble_protected_effects( n_tube_index )
{
	self endon( "nixie_scramble_stop" );
	level endon( "nixie_tube_trigger_" + n_tube_index );
	n_change_rate = 0,1;
	unrestricted_scramble_num = [];
	unrestricted_scramble_num[ 1 ] = array( 0, 2, 5, 6, 7 );
	unrestricted_scramble_num[ 2 ] = array( 2, 4, 5, 6, 9 );
	unrestricted_scramble_num[ 3 ] = array( 0, 3, 4, 7, 8, 9 );
	n_number_to_display = random( unrestricted_scramble_num[ n_tube_index ] );
	while ( 1 )
	{
		self hidepart( "J_" + n_number_to_display );
		n_number_to_display = random( unrestricted_scramble_num[ n_tube_index ] );
		self showpart( "J_" + n_number_to_display );
		self playsound( "zmb_quest_nixie_count" );
		wait n_change_rate;
	}
}

nixie_final_audio_cue_code()
{
	m_nixie_tube = getent( "nixie_tube_1", "targetname" );
	m_nixie_tube playsoundwithnotify( "vox_brutus_nixie_right_0", "scary_voice" );
	m_nixie_tube waittill( "scary_voice" );
}

nixie_tube_win_effects_all_tubes_final( goal_num_1, goal_num_2, goal_num_3 )
{
	if ( !isDefined( goal_num_1 ) )
	{
		goal_num_1 = 0;
	}
	if ( !isDefined( goal_num_2 ) )
	{
		goal_num_2 = 0;
	}
	if ( !isDefined( goal_num_3 ) )
	{
		goal_num_3 = 0;
	}
	a_nixie_tube = [];
	a_nixie_tube[ 1 ] = getent( "nixie_tube_1", "targetname" );
	a_nixie_tube[ 2 ] = getent( "nixie_tube_2", "targetname" );
	a_nixie_tube[ 3 ] = getent( "nixie_tube_3", "targetname" );
	n_off_tube = 1;
	start_time = 0;
	while ( start_time < 2 )
	{
		i = 1;
		while ( i < ( 3 + 1 ) )
		{
			if ( i == n_off_tube )
			{
				a_nixie_tube[ i ] hidepart( "J_" + level.a_nixie_tube_code[ i ] );
				i++;
				continue;
			}
			else
			{
				a_nixie_tube[ i ] showpart( "J_" + level.a_nixie_tube_code[ i ] );
				if ( i == 1 || n_off_tube == 2 && i == 3 && n_off_tube == 1 )
				{
					a_nixie_tube[ i ] playsound( "zmb_quest_nixie_count" );
				}
			}
			i++;
		}
		n_off_tube++;
		if ( n_off_tube > 3 )
		{
			n_off_tube = 1;
		}
		wait_network_frame();
		start_time += 0,15;
	}
	a_nixie_tube[ 1 ] showpart( "J_" + level.a_nixie_tube_code[ 1 ] );
	a_nixie_tube[ 2 ] showpart( "J_" + level.a_nixie_tube_code[ 2 ] );
	a_nixie_tube[ 3 ] showpart( "J_" + level.a_nixie_tube_code[ 3 ] );
	while ( level.a_nixie_tube_code[ 1 ] != goal_num_1 || level.a_nixie_tube_code[ 2 ] != goal_num_2 && level.a_nixie_tube_code[ 3 ] != goal_num_3 )
	{
		n_current_tube = 1;
		n_goal = goal_num_1;
		if ( level.a_nixie_tube_code[ n_current_tube ] == goal_num_1 )
		{
			n_current_tube = 2;
			n_goal = goal_num_2;
			if ( level.a_nixie_tube_code[ n_current_tube ] == goal_num_2 )
			{
				n_current_tube = 3;
				n_goal = goal_num_3;
			}
		}
		wait_network_frame();
		j = 0;
		while ( level.a_nixie_tube_code[ n_current_tube ] != n_goal )
		{
			a_nixie_tube[ n_current_tube ] hidepart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			level.a_nixie_tube_code[ n_current_tube ]--;

			if ( level.a_nixie_tube_code[ n_current_tube ] == -1 )
			{
				level.a_nixie_tube_code[ n_current_tube ] = 9;
			}
			a_nixie_tube[ n_current_tube ] showpart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			if ( ( j % 3 ) == 0 )
			{
				a_nixie_tube[ n_current_tube ] playsound( "zmb_quest_nixie_count" );
			}
			j++;
			wait 0,05;
		}
	}
	a_nixie_tube[ 2 ] playsound( "zmb_quest_nixie_count_final" );
	wait_network_frame();
}

stage_two()
{
	audio_logs = [];
	audio_logs[ 0 ] = [];
	audio_logs[ 0 ][ 0 ] = "vox_guar_tour_vo_1_0";
	audio_logs[ 0 ][ 1 ] = "vox_guar_tour_vo_2_0";
	audio_logs[ 0 ][ 2 ] = "vox_guar_tour_vo_3_0";
	audio_logs[ 2 ] = [];
	audio_logs[ 2 ][ 0 ] = "vox_guar_tour_vo_4_0";
	audio_logs[ 3 ] = [];
	audio_logs[ 3 ][ 0 ] = "vox_guar_tour_vo_5_0";
	audio_logs[ 3 ][ 1 ] = "vox_guar_tour_vo_6_0";
	audio_logs[ 4 ] = [];
	audio_logs[ 4 ][ 0 ] = "vox_guar_tour_vo_7_0";
	audio_logs[ 5 ] = [];
	audio_logs[ 5 ][ 0 ] = "vox_guar_tour_vo_8_0";
	audio_logs[ 6 ] = [];
	audio_logs[ 6 ][ 0 ] = "vox_guar_tour_vo_9_0";
	audio_logs[ 6 ][ 1 ] = "vox_guar_tour_vo_10_0";
	play_sq_audio_log( 0, audio_logs[ 0 ], 0 );
	i = 2;
	while ( i <= 6 )
	{
		play_sq_audio_log( i, audio_logs[ i ], 1 );
		i++;
	}
	level.m_headphones delete();
	t_plane_fly_afterlife = getent( "plane_fly_afterlife_trigger", "script_noteworthy" );
	t_plane_fly_afterlife playsound( "zmb_easteregg_laugh" );
	trigger_is_on = 0;
	while ( 1 )
	{
		players = getplayers();
		if ( players.size > 1 )
		{
			arlington_is_present = 0;
			_a339 = players;
			_k339 = getFirstArrayKey( _a339 );
			while ( isDefined( _k339 ) )
			{
				player = _a339[ _k339 ];
				if ( isDefined( player ) && player.character_name == "Arlington" )
				{
					arlington_is_present = 1;
				}
				_k339 = getNextArrayKey( _a339, _k339 );
			}
			if ( arlington_is_present && !trigger_is_on )
			{
				t_plane_fly_afterlife trigger_on();
				trigger_is_on = 1;
			}
			else
			{
				if ( !arlington_is_present && trigger_is_on )
				{
					t_plane_fly_afterlife trigger_off();
					trigger_is_on = 0;
				}
			}
		}
		else
		{
			if ( trigger_is_on )
			{
				t_plane_fly_afterlife trigger_off();
				trigger_is_on = 0;
			}
		}
		wait 0,1;
	}
}

headphones_rotate()
{
	self endon( "death" );
	while ( 1 )
	{
		self rotateyaw( 360, 3 );
		self waittill( "rotatedone" );
	}
}

play_sq_audio_log( num, a_vo, b_use_trig )
{
	v_pos = getstruct( "sq_at_" + num, "targetname" ).origin;
	if ( !isDefined( level.m_headphones ) )
	{
		level.m_headphones = spawn( "script_model", v_pos );
		level.m_headphones ghostindemo();
		level.m_headphones setmodel( "p6_zm_al_audio_headset_icon" );
		playfxontag( level._effect[ "powerup_on" ], level.m_headphones, "tag_origin" );
		level.m_headphones thread headphones_rotate();
		level.m_headphones playloopsound( "zmb_spawn_powerup_loop" );
		level.m_headphones trigger_off();
	}
	else
	{
		level.m_headphones trigger_on();
		level.m_headphones.origin = v_pos;
	}
	if ( b_use_trig )
	{
		trigger = spawn( "trigger_radius", level.m_headphones.origin - vectorScale( ( 1, 1, 1 ), 80 ), 0, 30, 150 );
		trigger waittill( "trigger" );
		trigger delete();
	}
	level.m_headphones trigger_off();
	level setclientfield( "toggle_futz", 1 );
	players = getplayers();
	_a411 = players;
	_k411 = getFirstArrayKey( _a411 );
	while ( isDefined( _k411 ) )
	{
		player = _a411[ _k411 ];
		maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_audio_log", player );
		_k411 = getNextArrayKey( _a411, _k411 );
	}
	i = 0;
	while ( i < a_vo.size )
	{
		level.m_headphones playsoundwithnotify( a_vo[ i ], "at_done" );
		level.m_headphones waittill( "at_done" );
		wait 0,5;
		i++;
	}
	level setclientfield( "toggle_futz", 0 );
	players = getplayers();
	_a426 = players;
	_k426 = getFirstArrayKey( _a426 );
	while ( isDefined( _k426 ) )
	{
		player = _a426[ _k426 ];
		maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_audio_log", player );
		_k426 = getNextArrayKey( _a426, _k426 );
	}
}

final_flight_setup()
{
	t_plane_fly_afterlife = getent( "plane_fly_afterlife_trigger", "script_noteworthy" );
	t_plane_fly_afterlife thread final_flight_trigger();
	t_plane_fly_afterlife trigger_off();
}

final_flight_trigger()
{
	t_plane_fly = getent( "plane_fly_trigger", "targetname" );
	self setcursorhint( "HINT_NOICON" );
	self sethintstring( "" );
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_triggerer );
		if ( isplayer( e_triggerer ) )
		{
			while ( isDefined( level.custom_plane_validation ) )
			{
				valid = self [[ level.custom_plane_validation ]]( e_triggerer );
				while ( !valid )
				{
					continue;
				}
			}
			players = getplayers();
			while ( players.size < 2 )
			{
				continue;
			}
			b_everyone_is_ready = 1;
			_a480 = players;
			_k480 = getFirstArrayKey( _a480 );
			while ( isDefined( _k480 ) )
			{
				player = _a480[ _k480 ];
				if ( isDefined( player ) || player.sessionstate == "spectator" && player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
				{
					b_everyone_is_ready = 0;
				}
				_k480 = getNextArrayKey( _a480, _k480 );
			}
			while ( !b_everyone_is_ready )
			{
				continue;
			}
			while ( flag( "plane_is_away" ) )
			{
				continue;
			}
			flag_set( "plane_is_away" );
			t_plane_fly trigger_off();
			_a504 = players;
			_k504 = getFirstArrayKey( _a504 );
			while ( isDefined( _k504 ) )
			{
				player = _a504[ _k504 ];
				if ( isDefined( player ) )
				{
/#
					iprintlnbold( "LINK PLAYER TO PLANE, START COUNTDOWN IF NOT YET STARTED" );
#/
					player thread final_flight_player_thread();
				}
				_k504 = getNextArrayKey( _a504, _k504 );
			}
			return;
		}
	}
}

final_flight_player_thread()
{
	self endon( "death_or_disconnect" );
	self.on_a_plane = 1;
	self.dontspeak = 1;
	self setclientfieldtoplayer( "isspeaking", 1 );
/#
	iprintlnbold( "plane boarding thread started" );
#/
	if ( isDefined( self.afterlife ) && !self.afterlife )
	{
		self.keep_perks = 1;
		self afterlife_remove();
		self.afterlife = 1;
		self thread afterlife_laststand();
		self waittill( "player_fake_corpse_created" );
	}
	self afterlife_infinite_mana( 1 );
	level.final_flight_activated = 1;
	level.final_flight_players[ level.final_flight_players.size ] = self;
	a_nml_teleport_targets = [];
	i = 1;
	while ( i < 6 )
	{
		a_nml_teleport_targets[ i - 1 ] = getstruct( "nml_telepoint_" + i, "targetname" );
		i++;
	}
	self.n_passenger_index = level.final_flight_players.size;
	a_players = [];
	a_players = getplayers();
	if ( a_players.size == 1 )
	{
		self.n_passenger_index = 1;
	}
	m_plane_craftable = getent( "plane_craftable", "targetname" );
	m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
	m_plane_about_to_crash ghost();
	veh_plane_flyable = getent( "plane_flyable", "targetname" );
	veh_plane_flyable show();
	flag_set( "plane_boarded" );
	t_plane_fly = getent( "plane_fly_trigger", "targetname" );
	str_hint_string = "BOARD FINAL FLIGHT";
	t_plane_fly sethintstring( str_hint_string );
	self playerlinktodelta( m_plane_craftable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	self allowcrouch( 1 );
	self allowstand( 0 );
	self clientnotify( "sndFFCON" );
	flag_wait( "plane_departed" );
	level notify( "sndStopBrutusLoop" );
	self clientnotify( "sndPS" );
	self playsoundtoplayer( "zmb_plane_takeoff", self );
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "plane_takeoff", self );
	m_plane_craftable ghost();
	self playerlinktodelta( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	self setclientfieldtoplayer( "effects_escape_flight", 1 );
	flag_wait( "plane_approach_bridge" );
	self thread maps/mp/zm_alcatraz_sq::snddelayedimp();
	self setclientfieldtoplayer( "effects_escape_flight", 2 );
	self unlink();
	self playerlinktoabsolute( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	flag_wait( "plane_zapped" );
	flag_set( "activate_player_zone_bridge" );
	self playsoundtoplayer( "zmb_plane_fall", self );
	self setclientfieldtoplayer( "effects_escape_flight", 3 );
	self.dontspeak = 1;
	self setclientfieldtoplayer( "isspeaking", 1 );
	self playerlinktodelta( m_plane_about_to_crash, "tag_player_crouched_" + ( self.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
	flag_wait( "plane_crashed" );
	self thread fadetoblackforxsec( 0, 2, 0, 0,5, "black" );
	self unlink();
	self allowstand( 1 );
	self setstance( "stand" );
	self allowcrouch( 0 );
	flag_clear( "spawn_zombies" );
	self setorigin( a_nml_teleport_targets[ self.n_passenger_index ].origin );
	e_poi = getstruct( "plane_crash_poi", "targetname" );
	vec_to_target = e_poi.origin - self.origin;
	vec_to_target = vectorToAngle( vec_to_target );
	vec_to_target = ( 0, vec_to_target[ 1 ], 0 );
	self setplayerangles( vec_to_target );
	n_shellshock_duration = 5;
	self shellshock( "explosion", n_shellshock_duration );
	self.on_a_plane = 0;
	stage_final();
}

stage_final()
{
	level notify( "stage_final" );
	level endon( "stage_final" );
	b_everyone_alive = 0;
	while ( isDefined( b_everyone_alive ) && !b_everyone_alive )
	{
		b_everyone_alive = 1;
		a_players = getplayers();
		_a648 = a_players;
		_k648 = getFirstArrayKey( _a648 );
		while ( isDefined( _k648 ) )
		{
			player = _a648[ _k648 ];
			if ( isDefined( player.afterlife ) && player.afterlife )
			{
				b_everyone_alive = 0;
				wait 0,05;
				break;
			}
			else
			{
				_k648 = getNextArrayKey( _a648, _k648 );
			}
		}
	}
	level._should_skip_ignore_player_logic = ::final_showdown_zombie_logic;
	flag_set( "spawn_zombies" );
	array_func( getplayers(), ::maps/mp/zombies/_zm_afterlife::afterlife_remove );
	p_weasel = undefined;
	a_player_team = [];
	a_players = getplayers();
	_a671 = a_players;
	_k671 = getFirstArrayKey( _a671 );
	while ( isDefined( _k671 ) )
	{
		player = _a671[ _k671 ];
		player.dontspeak = 1;
		player setclientfieldtoplayer( "isspeaking", 1 );
		if ( player.character_name == "Arlington" )
		{
			p_weasel = player;
		}
		else a_player_team[ a_player_team.size ] = player;
		_k671 = getNextArrayKey( _a671, _k671 );
	}
	if ( isDefined( p_weasel ) && a_player_team.size > 0 )
	{
		level.longregentime = 1000000;
		level.playerhealth_regularregendelay = 1000000;
		p_weasel.team = level.zombie_team;
		p_weasel.pers[ "team" ] = level.zombie_team;
		p_weasel.sessionteam = level.zombie_team;
		p_weasel.maxhealth = a_player_team.size * 2000;
		p_weasel.health = p_weasel.maxhealth;
		_a698 = a_player_team;
		_k698 = getFirstArrayKey( _a698 );
		while ( isDefined( _k698 ) )
		{
			player = _a698[ _k698 ];
			player.maxhealth = 2000;
			player.health = player.maxhealth;
			_k698 = getNextArrayKey( _a698, _k698 );
		}
		s_start_point = getstruct( "final_fight_starting_point_weasel", "targetname" );
		if ( isDefined( p_weasel ) && isDefined( s_start_point ) )
		{
			playfx( level._effect[ "afterlife_teleport" ], p_weasel.origin );
			p_weasel setorigin( s_start_point.origin );
			p_weasel setplayerangles( s_start_point.angles );
			playfx( level._effect[ "afterlife_teleport" ], p_weasel.origin );
		}
		i = 0;
		while ( i < a_player_team.size )
		{
			s_start_point = getstruct( "final_fight_starting_point_hero_" + ( i + 1 ), "targetname" );
			if ( isDefined( a_player_team[ i ] ) && isDefined( s_start_point ) )
			{
				playfx( level._effect[ "afterlife_teleport" ], a_player_team[ i ].origin );
				a_player_team[ i ] setorigin( s_start_point.origin );
				a_player_team[ i ] setplayerangles( s_start_point.angles );
				playfx( level._effect[ "afterlife_teleport" ], a_player_team[ i ].origin );
			}
			i++;
		}
		level thread final_showdown_track_weasel( p_weasel );
		level thread final_showdown_track_team( a_player_team );
		n_spawns_needed = 2;
		i = n_spawns_needed;
		while ( i > 0 )
		{
			maps/mp/zombies/_zm_ai_brutus::brutus_spawn_in_zone( "zone_golden_gate_bridge", 1 );
			i--;

		}
		level thread final_battle_vo( p_weasel, a_player_team );
		level notify( "pop_goes_the_weasel_achieved" );
		level waittill( "showdown_over" );
	}
	else
	{
		if ( isDefined( p_weasel ) )
		{
			level.winner = "weasel";
		}
		else
		{
			level.winner = "team";
		}
	}
	level clientnotify( "sndSQF" );
	level.brutus_respawn_after_despawn = 0;
	level thread clean_up_final_brutuses();
	wait 2;
	if ( level.winner == "weasel" )
	{
		a_players = getplayers();
		_a764 = a_players;
		_k764 = getFirstArrayKey( _a764 );
		while ( isDefined( _k764 ) )
		{
			player = _a764[ _k764 ];
			player freezecontrols( 1 );
			player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_ee_good_ending", 0 );
			player thread fadetoblackforxsec( 0, 5, 0,5, 0, "white" );
			player create_ending_message( &"ZM_PRISON_GOOD" );
			player.client_hint.sort = 55;
			player.client_hint.color = ( 1, 1, 1 );
			playsoundatposition( "zmb_quest_final_white_good", ( 1, 1, 1 ) );
			level.sndgameovermusicoverride = "game_over_final_good";
			_k764 = getNextArrayKey( _a764, _k764 );
		}
		level.custom_intermission = ::player_intermission_bridge;
	}
	else
	{
		a_players = getplayers();
		_a783 = a_players;
		_k783 = getFirstArrayKey( _a783 );
		while ( isDefined( _k783 ) )
		{
			player = _a783[ _k783 ];
			player freezecontrols( 1 );
			player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_ee_bad_ending", 0 );
			player thread fadetoblackforxsec( 0, 5, 0,5, 0, "white" );
			player create_ending_message( &"ZM_PRISON_BAD" );
			player.client_hint.sort = 55;
			player.client_hint.color = ( 1, 1, 1 );
			playsoundatposition( "zmb_quest_final_white_bad", ( 1, 1, 1 ) );
			level.sndgameovermusicoverride = "game_over_final_bad";
			_k783 = getNextArrayKey( _a783, _k783 );
		}
	}
	wait 5;
	a_players = getplayers();
	_a799 = a_players;
	_k799 = getFirstArrayKey( _a799 );
	while ( isDefined( _k799 ) )
	{
		player = _a799[ _k799 ];
		if ( isDefined( player.client_hint ) )
		{
			player thread destroy_tutorial_message();
		}
		if ( isDefined( player.revivetrigger ) )
		{
			player thread revive_success( player, 0 );
			player cleanup_suicide_hud();
		}
		if ( isDefined( player ) )
		{
			player ghost();
		}
		_k799 = getNextArrayKey( _a799, _k799 );
	}
	if ( isDefined( p_weasel ) )
	{
		p_weasel.team = "allies";
		p_weasel.pers[ "team" ] = "allies";
		p_weasel.sessionteam = "allies";
		p_weasel ghost();
	}
	level notify( "end_game" );
}

final_showdown_track_weasel( p_weasel )
{
	level endon( "showdown_over" );
	while ( 1 )
	{
		if ( !isDefined( p_weasel ) || p_weasel maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			level.winner = "team";
			level notify( "showdown_over" );
		}
		wait 0,05;
	}
}

final_showdown_track_team( a_player_team )
{
	level endon( "showdown_over" );
	while ( 1 )
	{
		weasel_won = 1;
		_a855 = a_player_team;
		_k855 = getFirstArrayKey( _a855 );
		while ( isDefined( _k855 ) )
		{
			player = _a855[ _k855 ];
			if ( is_player_valid( player, 0, 0 ) )
			{
				weasel_won = 0;
			}
			_k855 = getNextArrayKey( _a855, _k855 );
		}
		if ( isDefined( weasel_won ) && weasel_won )
		{
			level.winner = "weasel";
			level notify( "showdown_over" );
		}
		wait 0,05;
	}
}

final_showdown_zombie_logic()
{
	a_players = getplayers();
	_a877 = a_players;
	_k877 = getFirstArrayKey( _a877 );
	while ( isDefined( _k877 ) )
	{
		player = _a877[ _k877 ];
		if ( player.character_name == "Arlington" )
		{
			self.ignore_player[ self.ignore_player.size ] = player;
		}
		_k877 = getNextArrayKey( _a877, _k877 );
	}
	return 1;
}

final_showdown_create_icon( player, enemy )
{
	height_offset = 60;
	hud_elem = newclienthudelem( player );
	hud_elem.x = enemy.origin[ 0 ];
	hud_elem.y = enemy.origin[ 1 ];
	hud_elem.z = enemy.origin[ 2 ] + height_offset;
	hud_elem.alpha = 1;
	hud_elem.archived = 1;
	hud_elem setshader( "waypoint_kill_red", 8, 8 );
	hud_elem setwaypoint( 1 );
	hud_elem.foreground = 1;
	hud_elem.hidewheninmenu = 1;
	hud_elem thread final_showdown_update_icon( enemy );
	waittill_any_ents( level, "showdown_over", enemy, "disconnect" );
	hud_elem destroy();
}

final_showdown_update_icon( enemy )
{
	level endon( "showdown_over" );
	enemy endon( "disconnect" );
	height_offset = 60;
	while ( isDefined( enemy ) )
	{
		self.x = enemy.origin[ 0 ];
		self.y = enemy.origin[ 1 ];
		self.z = enemy.origin[ 2 ] + height_offset;
		wait 0,05;
	}
}

revive_trigger_should_ignore_sight_checks( player_down )
{
	if ( level.final_flight_activated )
	{
		return 1;
	}
	return 0;
}

final_battle_vo( p_weasel, a_player_team )
{
	level endon( "showdown_over" );
	wait 10;
	a_players = arraycopy( a_player_team );
	player = a_players[ randomintrange( 0, a_players.size ) ];
	arrayremovevalue( a_players, player );
	if ( a_players.size > 0 )
	{
		player_2 = a_players[ randomintrange( 0, a_players.size ) ];
	}
	if ( isDefined( player ) )
	{
		player final_battle_reveal();
	}
	wait 3;
	if ( isDefined( p_weasel ) )
	{
		p_weasel playsoundontag( "vox_plr_3_end_scenario_0", "J_Head" );
	}
	wait 1;
	_a967 = a_player_team;
	_k967 = getFirstArrayKey( _a967 );
	while ( isDefined( _k967 ) )
	{
		player = _a967[ _k967 ];
		level thread final_showdown_create_icon( player, p_weasel );
		level thread final_showdown_create_icon( p_weasel, player );
		_k967 = getNextArrayKey( _a967, _k967 );
	}
	wait 10;
	if ( isDefined( player_2 ) )
	{
		player_2 playsoundontag( "vox_plr_" + player_2.characterindex + "_end_scenario_1", "J_Head" );
	}
	else
	{
		if ( isDefined( player ) )
		{
			player playsoundontag( "vox_plr_" + player.characterindex + "_end_scenario_1", "J_Head" );
		}
	}
	wait 4;
	if ( isDefined( p_weasel ) )
	{
		p_weasel playsoundontag( "vox_plr_3_end_scenario_1", "J_Head" );
		p_weasel.dontspeak = 0;
		p_weasel setclientfieldtoplayer( "isspeaking", 0 );
	}
	_a996 = a_player_team;
	_k996 = getFirstArrayKey( _a996 );
	while ( isDefined( _k996 ) )
	{
		player = _a996[ _k996 ];
		player.dontspeak = 0;
		player setclientfieldtoplayer( "isspeaking", 0 );
		_k996 = getNextArrayKey( _a996, _k996 );
	}
}

final_battle_reveal()
{
	self endon( "death_or_disconnect" );
	self playsoundwithnotify( "vox_plr_" + self.characterindex + "_end_scenario_0", "showdown_icon_reveal" );
	self waittill( "showdown_icon_reveal" );
}

player_intermission_bridge()
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
	points = getstructarray( "final_cam", "targetname" );
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
					org = spawn( "script_model", self.origin + vectorScale( ( 1, 1, 1 ), 60 ) );
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

create_ending_message( str_msg )
{
	if ( !isDefined( self.client_hint ) )
	{
		self.client_hint = newclienthudelem( self );
		self.client_hint.alignx = "center";
		self.client_hint.aligny = "middle";
		self.client_hint.horzalign = "center";
		self.client_hint.vertalign = "bottom";
		if ( self issplitscreen() )
		{
			self.client_hint.y = -140;
		}
		else
		{
			self.client_hint.y = -250;
		}
		self.client_hint.foreground = 1;
		self.client_hint.font = "default";
		self.client_hint.fontscale = 50;
		self.client_hint.alpha = 1;
		self.client_hint.foreground = 1;
		self.client_hint.hidewheninmenu = 1;
		self.client_hint.color = ( 1, 1, 1 );
	}
	self.client_hint settext( str_msg );
}

custom_game_over_hud_elem( player )
{
	game_over = newclienthudelem( player );
	game_over.alignx = "center";
	game_over.aligny = "middle";
	game_over.horzalign = "center";
	game_over.vertalign = "middle";
	game_over.y -= 130;
	game_over.foreground = 1;
	game_over.fontscale = 3;
	game_over.alpha = 0;
	game_over.color = ( 1, 1, 1 );
	game_over.hidewheninmenu = 1;
	if ( isDefined( level.winner ) )
	{
		game_over settext( &"ZM_PRISON_LIFE_OVER" );
	}
	else
	{
		game_over settext( &"ZOMBIE_GAME_OVER" );
	}
	game_over fadeovertime( 1 );
	game_over.alpha = 1;
	if ( player issplitscreen() )
	{
		game_over.fontscale = 2;
		game_over.y += 40;
	}
	return game_over;
}

clean_up_final_brutuses()
{
	while ( 1 )
	{
		zombies = getaispeciesarray( "axis", "all" );
		i = 0;
		while ( i < zombies.size )
		{
			zombies[ i ] dodamage( 10000, zombies[ i ].origin );
			i++;
		}
		wait 1;
	}
}
