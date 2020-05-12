#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	flag_init( "air_puzzle_1_complete" );
	flag_init( "air_puzzle_2_complete" );
	flag_init( "air_upgrade_available" );
	air_puzzle_1_init();
	air_puzzle_2_init();
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 2, "vox_sam_wind_puz_solve_1" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 2, "vox_sam_wind_puz_solve_0" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 2, "vox_sam_wind_puz_solve_2" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_air1" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_air2" );
	level thread air_puzzle_1_run();
	flag_wait( "air_puzzle_1_complete" );
	playsoundatposition( "zmb_squest_step1_finished", ( 0, 0, 0 ) );
	level thread air_puzzle_1_cleanup();
	level thread rumble_players_in_chamber( 5, 3 );
	level thread air_puzzle_2_run();
}

air_puzzle_1_init()
{
	level.a_ceiling_rings = getentarray( "ceiling_ring", "script_noteworthy" );
	_a56 = level.a_ceiling_rings;
	_k56 = getFirstArrayKey( _a56 );
	while ( isDefined( _k56 ) )
	{
		e_ring = _a56[ _k56 ];
		e_ring ceiling_ring_init();
		_k56 = getNextArrayKey( _a56, _k56 );
	}
}

air_puzzle_1_cleanup()
{
	i = 1;
	while ( i <= 3 )
	{
		n_move = ( 4 - i ) * 20;
		e_ring = getent( "ceiling_ring_0" + i, "targetname" );
		e_ring rotateyaw( 360, 1,5, 0,5, 0 );
		e_ring movez( n_move, 1,5, 0,5, 0 );
		e_ring waittill( "movedone" );
		i++;
	}
	playsoundatposition( "zmb_squest_wind_ring_disappear", level.a_ceiling_rings[ 0 ].origin );
}

air_puzzle_1_run()
{
	array_thread( level.a_ceiling_rings, ::ceiling_ring_run );
}

check_puzzle_solved()
{
	num_solved = 0;
	_a85 = level.a_ceiling_rings;
	_k85 = getFirstArrayKey( _a85 );
	while ( isDefined( _k85 ) )
	{
		e_ring = _a85[ _k85 ];
		if ( e_ring.script_int != e_ring.position )
		{
			return 0;
		}
		_k85 = getNextArrayKey( _a85, _k85 );
	}
	return 1;
}

ceiling_ring_randomize()
{
	n_offset_from_final = randomintrange( 1, 4 );
	self.position = ( self.script_int + n_offset_from_final ) % 4;
	ceiling_ring_update_position();
/#
	assert( self.position != self.script_int );
#/
}

ceiling_ring_update_position()
{
	new_angles = ( self.angles[ 0 ], self.position * 90, self.angles[ 2 ] );
	self rotateto( new_angles, 0,5, 0,2, 0,2 );
	self playsound( "zmb_squest_wind_ring_turn" );
	self waittill( "rotatedone" );
}

ceiling_ring_rotate()
{
	self.position = ( self.position + 1 ) % 4;
/#
	if ( self.position == self.script_int )
	{
		iprintlnbold( "Ring is in place." );
#/
	}
	self ceiling_ring_update_position();
	solved = check_puzzle_solved();
	if ( solved && !flag( "air_puzzle_1_complete" ) )
	{
		self thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( 2 );
		flag_set( "air_puzzle_1_complete" );
	}
}

ceiling_ring_init()
{
	self.position = 0;
}

ceiling_ring_run()
{
	level endon( "air_puzzle_1_complete" );
	self setcandamage( 1 );
	self.position = 0;
	ceiling_ring_randomize();
	n_rotations = 0;
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, mod, tagname, modelname, partname, weaponname );
		if ( weaponname == "staff_air_zm" )
		{
			level notify( "vo_try_puzzle_air1" );
			self ceiling_ring_rotate();
			rumble_nearby_players( self.origin, 1500, 2 );
			n_rotations++;
			if ( ( n_rotations % 4 ) == 0 )
			{
				level notify( "vo_puzzle_bad" );
			}
			continue;
		}
		else
		{
			level notify( "vo_puzzle_confused" );
		}
	}
}

air_puzzle_2_init()
{
	a_smoke_pos = getstructarray( "puzzle_smoke_origin", "targetname" );
	_a179 = a_smoke_pos;
	_k179 = getFirstArrayKey( _a179 );
	while ( isDefined( _k179 ) )
	{
		s_smoke_pos = _a179[ _k179 ];
		s_smoke_pos.detector_brush = getent( s_smoke_pos.target, "targetname" );
		s_smoke_pos.detector_brush ghost();
		_k179 = getNextArrayKey( _a179, _k179 );
	}
}

air_puzzle_2_run()
{
	a_smoke_pos = getstructarray( "puzzle_smoke_origin", "targetname" );
	_a190 = a_smoke_pos;
	_k190 = getFirstArrayKey( _a190 );
	while ( isDefined( _k190 ) )
	{
		s_smoke_pos = _a190[ _k190 ];
		s_smoke_pos thread air_puzzle_smoke();
		_k190 = getNextArrayKey( _a190, _k190 );
	}
	while ( 1 )
	{
		level waittill( "air_puzzle_smoke_solved" );
		all_smoke_solved = 1;
		_a200 = a_smoke_pos;
		_k200 = getFirstArrayKey( _a200 );
		while ( isDefined( _k200 ) )
		{
			s_smoke_pos = _a200[ _k200 ];
			if ( !s_smoke_pos.solved )
			{
				all_smoke_solved = 0;
			}
			_k200 = getNextArrayKey( _a200, _k200 );
		}
		if ( all_smoke_solved )
		{
			a_players = getplayers();
			_a211 = a_players;
			_k211 = getFirstArrayKey( _a211 );
			while ( isDefined( _k211 ) )
			{
				e_player = _a211[ _k211 ];
				if ( e_player hasweapon( "staff_air_zm" ) )
				{
					e_player thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( 2 );
					break;
				}
				else
				{
					_k211 = getNextArrayKey( _a211, _k211 );
				}
			}
			flag_set( "air_puzzle_2_complete" );
			level thread play_puzzle_stinger_on_all_players();
			return;
		}
		else
		{
		}
	}
}

air_puzzle_smoke()
{
	self.e_fx = spawn( "script_model", self.origin );
	self.e_fx.angles = self.angles;
	self.e_fx setmodel( "tag_origin" );
	self.e_fx playloopsound( "zmb_squest_wind_incense_loop", 2 );
	s_dest = getstruct( "puzzle_smoke_dest", "targetname" );
	playfxontag( level._effect[ "air_puzzle_smoke" ], self.e_fx, "tag_origin" );
	self thread air_puzzle_run_smoke_direction();
	flag_wait( "air_puzzle_2_complete" );
	self.e_fx movez( -1000, 1, 0,1, 0,1 );
	self.e_fx waittill( "movedone" );
	wait 5;
	self.e_fx delete();
	self.detector_brush delete();
}

air_puzzle_run_smoke_direction()
{
	level endon( "air_puzzle_2_complete" );
	self endon( "death" );
	s_dest = getstruct( "puzzle_smoke_dest", "targetname" );
	v_to_dest = vectornormalize( s_dest.origin - self.origin );
	f_min_dot = cos( self.script_int );
	self.solved = 0;
	self.detector_brush setcandamage( 1 );
	direction_failures = 0;
	while ( 1 )
	{
		self.detector_brush waittill( "damage", damage, attacker, direction_vec, point, mod, tagname, modelname, partname, weaponname );
		if ( weaponname == "staff_air_zm" )
		{
			level notify( "vo_try_puzzle_air2" );
			new_yaw = vectoangles( direction_vec );
			new_orient = ( 0, new_yaw, 0 );
			self.e_fx rotateto( new_orient, 1, 0,3, 0,3 );
			self.e_fx waittill( "rotatedone" );
			f_dot = vectordot( v_to_dest, direction_vec );
			self.solved = f_dot > f_min_dot;
			if ( !self.solved )
			{
				direction_failures++;
				if ( direction_failures > 4 )
				{
					level notify( "vo_puzzle_confused" );
				}
			}
			else
			{
				if ( randomint( 100 ) < 10 )
				{
					level notify( "vo_puzzle_good" );
				}
			}
			level notify( "air_puzzle_smoke_solved" );
			continue;
		}
		else
		{
			if ( issubstr( weaponname, "staff" ) )
			{
				level notify( "vo_puzzle_bad" );
			}
		}
	}
}
