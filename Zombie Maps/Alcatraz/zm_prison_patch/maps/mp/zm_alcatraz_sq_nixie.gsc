#include maps/mp/zm_alcatraz_sq;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_afterlife;
#include maps/_vehicle;
#include maps/_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

setup_nixie_tubes_puzzle()
{
	level.a_nixie_tube_code = [];
	level.a_nixie_tube_solution = [];
	t_elevator_door = getent( "nixie_elevator_door", "targetname" );
	t_elevator_door trigger_off();
	m_rigging = get_craftable_piece_model( "plane", "rigging" );
	m_citadel_elevator = getent( "citadel_elevator", "targetname" );
	m_rigging linkto( m_citadel_elevator );
	level thread nixie_tube_notifier();
	level thread nixie_tube_elevator_door();
	while ( !flag( "nixie_puzzle_completed" ) )
	{
		generate_unrestricted_nixie_tube_solution();
		n_code = nixie_tube_add_code( level.a_nixie_tube_solution[ 1 ], level.a_nixie_tube_solution[ 2 ], level.a_nixie_tube_solution[ 3 ] );
		i = 1;
		while ( i < 4 )
		{
			m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
			m_nixie_tube thread nixie_tube_thread( i );
			m_nixie_clue = getent( "nixie_clue_" + i, "script_noteworthy" );
			j = 0;
			while ( j < 10 )
			{
				m_nixie_clue hidepart( "J_" + j );
				j++;
			}
			players = getplayers();
			_a76 = players;
			_k76 = getFirstArrayKey( _a76 );
			while ( isDefined( _k76 ) )
			{
				player = _a76[ _k76 ];
				if ( isDefined( player ) && isDefined( player.afterlife ) && player.afterlife )
				{
					m_nixie_clue setvisibletoplayer( player );
				}
				_k76 = getNextArrayKey( _a76, _k76 );
			}
			m_nixie_clue showpart( "J_" + level.a_nixie_tube_solution[ i ] );
			i++;
		}
		level waittill( "nixie_" + n_code );
		flag_set( "nixie_puzzle_solved" );
		nixie_tube_remove_code( n_code );
		i = 1;
		while ( i < 4 )
		{
			m_nixie_clue = getent( "nixie_clue_" + i, "script_noteworthy" );
			m_nixie_clue setinvisibletoall();
			i++;
		}
		nixie_tube_2 = getent( "nixie_tube_2", "targetname" );
		nixie_tube_2 playsound( "zmb_quest_nixie_success" );
		level thread nixie_tube_elevator_drops();
		nixie_tube_win_effects_all_tubes( 0, 6, 0 );
		wait 0,5;
		n_countdown = 60;
		level thread sndnixietubecountdown( n_countdown );
		i = 1;
		while ( i < 4 )
		{
			m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
			level notify( "nixie_tube_trigger_" + i );
			m_nixie_tube thread nixie_tube_thread_play_countdown( i, n_countdown );
			i++;
		}
		flag_set( "nixie_countdown_started" );
		flag_wait( "nixie_countdown_expired" );
		if ( !flag( "nixie_puzzle_completed" ) )
		{
			t_elevator_door = getent( "nixie_elevator_door", "targetname" );
			t_elevator_door trigger_off();
			flag_clear( "nixie_countdown_started" );
			flag_clear( "nixie_countdown_expired" );
			flag_clear( "nixie_puzzle_solved" );
			nixie_tube_elevator_rises();
		}
	}
	m_nixie_tube = getent( "nixie_tube_2", "targetname" );
	m_nixie_tube playsound( "zmb_quest_nixie_success" );
/#
	iprintlnbold( "nixie puzzle solved!" );
#/
	flag_clear( "nixie_puzzle_solved" );
	array_delete( getentarray( "wires_nixie_elevator", "script_noteworthy" ) );
	stop_exploder( 3400 );
	stop_exploder( 3500 );
	stop_exploder( 3600 );
	i = 1;
	while ( i < 4 )
	{
		m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
		m_nixie_tube thread afterlife_interact_object_think();
		m_nixie_tube thread nixie_tube_thread( i );
		i++;
	}
}

generate_unrestricted_nixie_tube_solution()
{
	a_restricted_solutions = [];
	a_restricted_solutions[ 0 ] = 115;
	a_restricted_solutions[ 1 ] = 935;
	a_restricted_solutions[ 2 ] = 386;
	a_restricted_solutions[ 3 ] = 481;
	a_restricted_solutions[ 4 ] = 101;
	a_restricted_solutions[ 5 ] = 872;
	a_numbers = [];
	i = 0;
	while ( i < 10 )
	{
		a_numbers[ i ] = i;
		i++;
	}
	i = 1;
	while ( i < 4 )
	{
		n_index = randomint( a_numbers.size );
		level.a_nixie_tube_solution[ i ] = a_numbers[ n_index ];
		arrayremoveindex( a_numbers, n_index );
		i++;
	}
	i = 0;
	while ( i < a_restricted_solutions.size )
	{
		b_is_restricted_solution = 1;
		restricted_solution = [];
		j = 1;
		while ( j < 4 )
		{
			restricted_solution[ j ] = get_split_number( j, a_restricted_solutions[ i ] );
			if ( restricted_solution[ j ] != level.a_nixie_tube_solution[ j ] )
			{
				b_is_restricted_solution = 0;
			}
			j++;
		}
		if ( b_is_restricted_solution )
		{
			n_index = randomint( a_numbers.size );
			level.a_nixie_tube_solution[ 3 ] = a_numbers[ n_index ];
		}
		i++;
	}
}

nixie_tube_notifier()
{
	if ( !isDefined( level.a_important_codes ) )
	{
		level.a_important_codes = [];
		level.a_important_codes[ level.a_important_codes.size ] = 115;
		level.a_important_codes[ level.a_important_codes.size ] = 935;
	}
	level thread nixie_115();
	level thread nixie_935();
	while ( !isDefined( level.a_nixie_tube_code ) || !isDefined( level.a_nixie_tube_code[ 3 ] ) )
	{
		wait 1;
	}
	while ( 1 )
	{
		codes_to_check = array_copy( level.a_important_codes );
		non_array_value = ( level.a_nixie_tube_code[ 1 ] * 100 ) + ( level.a_nixie_tube_code[ 2 ] * 10 ) + level.a_nixie_tube_code[ 3 ];
		_a240 = codes_to_check;
		_k240 = getFirstArrayKey( _a240 );
		while ( isDefined( _k240 ) )
		{
			code = _a240[ _k240 ];
			if ( code == non_array_value )
			{
				level notify( "nixie_" + code );
			}
			_k240 = getNextArrayKey( _a240, _k240 );
		}
		wait 2;
	}
}

nixie_tube_add_code( a, b, c )
{
	if ( isDefined( b ) )
	{
		non_array_value = ( a * 100 ) + ( b * 10 ) + c;
	}
	else
	{
		non_array_value = a;
	}
	level.a_important_codes[ level.a_important_codes.size ] = non_array_value;
	return non_array_value;
}

nixie_tube_remove_code( a, b, c )
{
	if ( isDefined( b ) )
	{
		non_array_value = ( a * 100 ) + ( b * 10 ) + c;
	}
	else
	{
		non_array_value = a;
	}
	arrayremovevalue( level.a_important_codes, non_array_value );
}

sndnixietubecountdown( num )
{
	level endon( "sndEndNixieCount" );
	ent = getent( "nixie_tube_2", "targetname" );
	i = num;
	while ( i > 0 )
	{
		if ( i <= 10 )
		{
			ent playsound( "zmb_quest_nixie_count_final" );
		}
		else
		{
			ent playsound( "zmb_quest_nixie_count" );
		}
		wait 1;
		i--;

	}
	ent playsound( "zmb_quest_nixie_fail" );
}

nixie_tube_thread( n_tube_index, b_force_reset )
{
	if ( !isDefined( b_force_reset ) )
	{
		b_force_reset = 1;
	}
	level endon( "kill_nixie_input" );
	if ( b_force_reset )
	{
		level.a_nixie_tube_code[ n_tube_index ] = 0;
	}
	self thread afterlife_interact_object_think();
	i = 0;
	while ( i < 10 )
	{
		self hidepart( "J_off" );
		self hidepart( "J_" + i );
		i++;
	}
	self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
	while ( !flag( "nixie_puzzle_solved" ) )
	{
		level waittill( "nixie_tube_trigger_" + n_tube_index );
		while ( flag( "nixie_puzzle_solved" ) )
		{
			continue;
		}
		i = 0;
		while ( i < 10 )
		{
			self hidepart( "J_" + i );
			i++;
		}
		level.a_nixie_tube_code[ n_tube_index ]++;
		self playsound( "zmb_quest_nixie_count" );
		if ( level.a_nixie_tube_code[ n_tube_index ] > 9 )
		{
			level.a_nixie_tube_code[ n_tube_index ] = 0;
		}
		self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait 0,05;
		self notify( "afterlife_interact_reset" );
	}
}

nixie_tube_win_effects( n_tube_index, n_blink_rate )
{
	if ( !isDefined( n_blink_rate ) )
	{
		n_blink_rate = 0,25;
	}
	while ( !flag( "nixie_countdown_started" ) )
	{
		self hidepart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
		self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
	}
	self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
}

nixie_tube_win_effects_all_tubes( goal_num_1, goal_num_2, goal_num_3 )
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
	while ( start_time < 3 )
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
		j = 0;
		while ( j < 10 )
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
			wait 0,05;
			j++;
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

nixie_tube_thread_play_countdown( n_tube_index, n_countdown )
{
	level endon( "end_nixie_countdown" );
	n_tick_duration = 1;
	level.a_nixie_tube_code[ n_tube_index ] = get_split_number( n_tube_index, n_countdown );
/#
	iprintlnbold( "tube " + n_tube_index + " number is " + level.a_nixie_tube_code[ n_tube_index ] );
#/
	i = 0;
	while ( i < 10 )
	{
		self hidepart( "J_" + i );
		i++;
	}
	self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
	while ( n_countdown )
	{
		n_countdown--;

		self hidepart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		level.a_nixie_tube_code[ n_tube_index ] = get_split_number( n_tube_index, n_countdown );
		self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_tick_duration;
	}
	flag_set( "nixie_countdown_expired" );
	wait 0,05;
	flag_clear( "nixie_countdown_expired" );
}

get_split_number( n_tube_index, n_countdown )
{
	if ( n_tube_index == 1 )
	{
		return ( n_countdown - ( n_countdown % 100 ) ) / 100;
	}
	if ( n_tube_index == 2 )
	{
		n_temp = n_countdown % 100;
		n_temp -= n_countdown % 10;
		n_temp /= 10;
		return n_temp;
	}
	if ( n_tube_index == 3 )
	{
		return n_countdown % 10;
	}
}

nixie_tube_elevator_drops()
{
	n_elevator_drop_duration = 3;
	maps/mp/zm_alcatraz_sq::array_set_visible_to_all( getentarray( "generator_wires", "script_noteworthy" ), 0 );
	exploder( 3400 );
	exploder( 3500 );
	exploder( 3600 );
	m_citadel_elevator = getent( "citadel_elevator", "targetname" );
	a_m_script_models = [];
	a_m_script_models = getentarray( "script_model", "classname" );
	i = 0;
	while ( i < a_m_script_models.size )
	{
		if ( a_m_script_models[ i ].model == "veh_t6_dlc_zombie_part_rigging" )
		{
			playfxontag( level._effect[ "elevator_fall" ], a_m_script_models[ i ], "tag_origin" );
		}
		i++;
	}
	m_citadel_elevator playsound( "zmb_quest_elevator_move" );
	m_citadel_elevator moveto( m_citadel_elevator.origin + vectorScale( ( 0, 0, 0 ), 768 ), n_elevator_drop_duration, 1, 1 );
	wait n_elevator_drop_duration;
	t_elevator_door = getent( "nixie_elevator_door", "targetname" );
	t_elevator_door trigger_on();
}

nixie_tube_elevator_rises()
{
	elevator_rise_duration = 3;
	maps/mp/zm_alcatraz_sq::array_set_visible_to_all( getentarray( "generator_wires", "script_noteworthy" ), 1 );
	stop_exploder( 3400 );
	stop_exploder( 3500 );
	stop_exploder( 3600 );
	m_citadel_elevator = getent( "citadel_elevator", "targetname" );
	m_citadel_elevator moveto( m_citadel_elevator.origin + vectorScale( ( 0, 0, 0 ), 768 ), elevator_rise_duration, 1, 1 );
	m_citadel_elevator playsound( "zmb_quest_elevator_move" );
	wait elevator_rise_duration;
}

nixie_tube_elevator_door()
{
	t_elevator_door = getent( "nixie_elevator_door", "targetname" );
	t_elevator_door sethintstring( &"ZM_PRISON_KEY_DOOR" );
	t_elevator_door waittill( "trigger", e_triggerer );
	m_elevator_bottom_gate_l = getent( "elevator_bottom_gate_l", "targetname" );
	m_elevator_bottom_gate_r = getent( "elevator_bottom_gate_r", "targetname" );
	m_elevator_bottom_gate_l rotateyaw( -90, 0,5 );
	m_elevator_bottom_gate_r rotateyaw( 90, 0,5 );
	elevator_door_playerclip = getent( "elevator_door_playerclip", "targetname" );
	elevator_door_playerclip delete();
	flag_set( "nixie_puzzle_completed" );
	level notify( "sndEndNixieCount" );
	level notify( "end_nixie_countdown" );
	flag_set( "nixie_countdown_expired" );
	wait 0,05;
	flag_clear( "nixie_countdown_expired" );
	t_elevator_door delete();
}

nixie_tube_win_effects_ee( n_tube_index )
{
	n_blink_rate = 0,25;
	while ( !flag( "nixie_ee_flashing" ) )
	{
		self hidepart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
		self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
	}
	self showpart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
}

nixie_115()
{
	level waittill( "nixie_" + 115 );
	level notify( "kill_nixie_input" );
	flag_set( "nixie_puzzle_solved" );
	flag_clear( "nixie_ee_flashing" );
	level thread nixie_115_audio();
	nixie_tube_win_effects_all_tubes( 6, 6, 6 );
	flag_set( "nixie_ee_flashing" );
	flag_clear( "nixie_puzzle_solved" );
	nixie_reset_control();
}

nixie_115_audio()
{
	m_nixie_tube = getent( "nixie_tube_1", "targetname" );
	n_random_line = randomint( 3 );
	m_nixie_tube playsoundwithnotify( "vox_brutus_scary_voice_" + n_random_line, "scary_voice" );
	m_nixie_tube waittill( "scary_voice" );
}

nixie_935()
{
	level waittill( "nixie_" + 935 );
	level notify( "kill_nixie_input" );
	flag_set( "nixie_puzzle_solved" );
	flag_clear( "nixie_ee_flashing" );
	level thread nixie_935_audio();
	nixie_tube_win_effects_all_tubes( 7, 7, 7 );
	flag_set( "nixie_ee_flashing" );
	flag_clear( "nixie_puzzle_solved" );
	nixie_reset_control();
}

nixie_935_audio()
{
	if ( isDefined( level.music_override ) && !level.music_override )
	{
		level.music_override = 1;
		playsoundatposition( "mus_zmb_secret_song_2", ( 0, 0, 0 ) );
		wait 140;
		level.music_override = 0;
	}
	else
	{
		m_nixie_tube = getent( "nixie_tube_1", "targetname" );
		n_random_line = randomint( 3 );
		m_nixie_tube playsoundwithnotify( "vox_brutus_scary_voice_" + n_random_line, "scary_voice" );
		m_nixie_tube waittill( "scary_voice" );
	}
}

nixie_reset_control( b_reset_control )
{
	i = 1;
	while ( i < 4 )
	{
		m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
		m_nixie_tube thread afterlife_interact_object_think();
		m_nixie_tube thread nixie_tube_thread( i, b_reset_control );
		i++;
	}
}
