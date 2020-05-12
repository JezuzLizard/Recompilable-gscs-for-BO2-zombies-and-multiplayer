#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "fxanim_props_dlc4" );

tomb_ambient_precache()
{
	precachemodel( "veh_t6_dlc_zm_zeppelin" );
}

init_tomb_ambient_scripts()
{
	tomb_ambient_precache();
	registerclientfield( "world", "sky_battle_ambient_fx", 14000, 1, "int" );
	level thread start_sky_battle();
	level thread init_zeppelin( "sky_cowbell_zeppelin_low", "stop_ambient_zeppelins" );
	delay_thread( 20, ::init_zeppelin, "sky_cowbell_zeppelin_mid", "stop_ambient_zeppelins" );
	delay_thread( 40, ::init_zeppelin, "sky_cowbell_zeppelin_high", "stop_ambient_zeppelins" );
	level thread vista_robot_pose();
}

init_zeppelin( str_script_noteworthy, str_ender )
{
	level endon( str_ender );
	a_path_structs = getstructarray( str_script_noteworthy, "script_noteworthy" );
	while ( a_path_structs.size > 0 )
	{
		m_zeppelin = spawn( "script_model", ( 0, 0, 0 ) );
		m_zeppelin setmodel( "veh_t6_dlc_zm_zeppelin" );
		m_zeppelin setforcenocull();
		while ( 1 )
		{
			m_zeppelin move_zeppelin_down_new_path( a_path_structs );
		}
	}
}

move_zeppelin_down_new_path( a_structs )
{
	s_path_start = get_unused_struct( a_structs );
	self ghost();
	self moveto( s_path_start.origin, 0,1 );
	self rotateto( s_path_start.angles, 0,1 );
	self waittill( "movedone" );
	self show();
	if ( !isDefined( s_path_start.goal_struct ) )
	{
/#
		assert( isDefined( s_path_start.target ), "move_zeppelin_down_new_path found start struct at " + s_path_start.origin + " without a target! These are needed for zeppelin splines!" );
#/
		s_path_start.goal_struct = getstruct( s_path_start.target, "targetname" );
/#
		assert( isDefined( s_path_start.goal_struct ), "move_zeppelin_down_new_path couldn't find goal for path start struct at " + s_path_start.origin );
#/
	}
	n_move_time = randomfloatrange( 120, 150 );
	self moveto( s_path_start.goal_struct.origin, n_move_time );
	self waittill( "movedone" );
}

get_unused_struct( a_structs )
{
	a_valid_structs = [];
	b_no_unused_structs = 0;
	while ( !a_valid_structs.size )
	{
		_a90 = a_structs;
		_k90 = getFirstArrayKey( _a90 );
		while ( isDefined( _k90 ) )
		{
			struct = _a90[ _k90 ];
			if ( !isDefined( struct.used ) || b_no_unused_structs )
			{
				struct.used = 0;
			}
			if ( !struct.used )
			{
				a_valid_structs[ a_valid_structs.size ] = struct;
			}
			_k90 = getNextArrayKey( _a90, _k90 );
		}
		if ( !a_valid_structs.size )
		{
			b_no_unused_structs = 1;
		}
	}
	s_unused = random( a_valid_structs );
	s_unused.used = 1;
	return s_unused;
}

start_sky_battle()
{
	flag_wait( "start_zombie_round_logic" );
	level setclientfield( "sky_battle_ambient_fx", 1 );
}

vista_robot_pose()
{
	flag_wait( "start_zombie_round_logic" );
	a_robots = getstructarray( "trench_downed_robot_struct", "targetname" );
	i = 0;
	while ( i < a_robots.size )
	{
		if ( !isDefined( a_robots[ i ].angles ) )
		{
			a_robots[ i ].angles = ( 0, 0, 0 );
		}
		v_origin = getstartorigin( a_robots[ i ].origin, a_robots[ i ].angles, %ai_zombie_giant_robot_vista );
		v_angles = getstartangles( a_robots[ i ].origin, a_robots[ i ].angles, %ai_zombie_giant_robot_vista );
		e_robot = spawn( "script_model", v_origin );
		e_robot.angles = v_angles;
		e_robot setmodel( "veh_t6_dlc_zm_robot" );
		e_robot useanimtree( -1 );
		e_robot setanim( %ai_zombie_giant_robot_vista, 1, 0, 1 );
		i++;
	}
}
