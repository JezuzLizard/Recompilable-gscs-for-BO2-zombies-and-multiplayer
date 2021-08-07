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
	precachemodel( "p6_zm_tm_note_rock_01_anim" );
	flag_init( "ice_puzzle_1_complete" );
	flag_init( "ice_puzzle_2_complete" );
	flag_init( "ice_upgrade_available" );
	flag_init( "ice_tile_flipping" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 4, "vox_sam_ice_puz_solve_0" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 4, "vox_sam_ice_puz_solve_1" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 4, "vox_sam_ice_puz_solve_2" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_water1" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_water2" );
	ice_puzzle_1_init();
	level thread ice_puzzle_2_init();
	level thread ice_puzzle_1_run();
	flag_wait( "ice_puzzle_1_complete" );
	playsoundatposition( "zmb_squest_step1_finished", ( 0, 0, 0 ) );
	level thread rumble_players_in_chamber( 5, 3 );
	ice_puzzle_1_cleanup();
	level thread ice_puzzle_2_run();
	flag_wait( "ice_puzzle_2_complete" );
	flag_wait( "staff_water_zm_upgrade_unlocked" );
}

ice_puzzle_1_init()
{
	ice_tiles_randomize();
	a_ceiling_tile_brushes = getentarray( "ice_ceiling_tile", "script_noteworthy" );
	level.unsolved_tiles = a_ceiling_tile_brushes;
	_a68 = a_ceiling_tile_brushes;
	_k68 = getFirstArrayKey( _a68 );
	while ( isDefined( _k68 ) )
	{
		tile = _a68[ _k68 ];
		tile.showing_tile_side = 0;
		tile.value = int( tile.script_string );
		tile thread ceiling_tile_flip();
		tile thread ceiling_tile_process_damage();
		_k68 = getNextArrayKey( _a68, _k68 );
	}
	a_ice_ternary_digit_brushes = getentarray( "ice_chamber_digit", "targetname" );
	_a77 = a_ice_ternary_digit_brushes;
	_k77 = getFirstArrayKey( _a77 );
	while ( isDefined( _k77 ) )
	{
		digit = _a77[ _k77 ];
		digit ghost();
		digit notsolid();
		_k77 = getNextArrayKey( _a77, _k77 );
	}
	level.ternary_digits = [];
	level.ternary_digits[ 0 ] = array( -1, 0, -1 );
	level.ternary_digits[ 1 ] = array( -1, 1, -1 );
	level.ternary_digits[ 2 ] = array( -1, 2, -1 );
	level.ternary_digits[ 3 ] = array( 1, -1, 0 );
	level.ternary_digits[ 4 ] = array( 1, -1, 1 );
	level.ternary_digits[ 5 ] = array( 1, -1, 2 );
	level.ternary_digits[ 6 ] = array( 2, -1, 0 );
	level.ternary_digits[ 7 ] = array( 2, -1, 1 );
	level.ternary_digits[ 8 ] = array( 2, -1, 2 );
	level.ternary_digits[ 9 ] = array( 1, 0, 0 );
	level.ternary_digits[ 10 ] = array( 1, 0, 1 );
	level.ternary_digits[ 11 ] = array( 1, 0, 2 );
	level thread update_ternary_display();
}

ice_puzzle_1_cleanup()
{
	a_ceiling_tile_brushes = getentarray( "ice_ceiling_tile", "script_noteworthy" );
	_a105 = a_ceiling_tile_brushes;
	_k105 = getFirstArrayKey( _a105 );
	while ( isDefined( _k105 ) )
	{
		tile = _a105[ _k105 ];
		tile thread ceiling_tile_flip( 0 );
		_k105 = getNextArrayKey( _a105, _k105 );
	}
	a_ice_ternary_digit_brushes = getentarray( "ice_chamber_digit", "targetname" );
	array_delete( a_ice_ternary_digit_brushes );
}

ice_tiles_randomize()
{
	a_original_tiles = getentarray( "ice_tile_original", "targetname" );
	a_original_positions = [];
	_a120 = a_original_tiles;
	_k120 = getFirstArrayKey( _a120 );
	while ( isDefined( _k120 ) )
	{
		e_tile = _a120[ _k120 ];
		a_original_positions[ a_original_positions.size ] = e_tile.origin;
		_k120 = getNextArrayKey( _a120, _k120 );
	}
	a_unused_tiles = getentarray( "ice_ceiling_tile", "script_noteworthy" );
	n_total_tiles = a_unused_tiles.size;
	_a127 = a_original_positions;
	_k127 = getFirstArrayKey( _a127 );
	while ( isDefined( _k127 ) )
	{
		v_pos = _a127[ _k127 ];
		e_tile = random( a_unused_tiles );
		arrayremovevalue( a_unused_tiles, e_tile, 0 );
		e_tile moveto( v_pos, 0,5, 0,1, 0,1 );
		e_tile waittill( "movedone" );
		_k127 = getNextArrayKey( _a127, _k127 );
	}
/#
	assert( a_unused_tiles.size == ( n_total_tiles - a_original_positions.size ) );
#/
	array_delete( a_unused_tiles );
}

reset_tiles()
{
	a_ceiling_tile_brushes = getentarray( "ice_ceiling_tile", "script_noteworthy" );
	_a144 = a_ceiling_tile_brushes;
	_k144 = getFirstArrayKey( _a144 );
	while ( isDefined( _k144 ) )
	{
		tile = _a144[ _k144 ];
		tile thread ceiling_tile_flip( 1 );
		_k144 = getNextArrayKey( _a144, _k144 );
	}
}

update_ternary_display()
{
	a_ice_ternary_digit_brushes = getentarray( "ice_chamber_digit", "targetname" );
	level endon( "ice_puzzle_1_complete" );
	while ( 1 )
	{
		level waittill( "update_ice_chamber_digits", newval );
		_a160 = a_ice_ternary_digit_brushes;
		_k160 = getFirstArrayKey( _a160 );
		while ( isDefined( _k160 ) )
		{
			digit = _a160[ _k160 ];
			digit ghost();
			if ( isDefined( newval ) )
			{
				digit_slot = int( digit.script_noteworthy );
				shown_value = level.ternary_digits[ newval ][ digit_slot ];
				digit_value = int( digit.script_string );
				if ( shown_value == digit_value )
				{
					digit show();
				}
			}
			_k160 = getNextArrayKey( _a160, _k160 );
		}
	}
}

change_ice_gem_value()
{
	ice_gem = getent( "ice_chamber_gem", "targetname" );
	if ( level.unsolved_tiles.size != 0 )
	{
		correct_tile = random( level.unsolved_tiles );
		ice_gem.value = correct_tile.value;
		level notify( "update_ice_chamber_digits" );
	}
	else
	{
		level notify( "update_ice_chamber_digits" );
	}
}

process_gem_shooting()
{
	level endon( "ice_puzzle_1_complete" );
	ice_gem = getent( "ice_chamber_gem", "targetname" );
	ice_gem.value = -1;
	ice_gem setcandamage( 1 );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, mod, tagname, modelname, partname, weaponname );
		if ( weaponname == "staff_water_zm" )
		{
			change_ice_gem_value();
		}
	}
}

ice_puzzle_1_run()
{
	level thread process_gem_shooting();
	change_ice_gem_value();
}

ceiling_tile_flip( b_flip_to_tile_side )
{
	if ( !isDefined( b_flip_to_tile_side ) )
	{
		b_flip_to_tile_side = !self.showing_tile_side;
	}
	if ( b_flip_to_tile_side == self.showing_tile_side )
	{
		return;
	}
	self.showing_tile_side = !self.showing_tile_side;
	self rotateroll( 180, 0,5, 0,1, 0,1 );
	self playsound( "zmb_squest_ice_tile_flip" );
	if ( !self.showing_tile_side )
	{
		arrayremovevalue( level.unsolved_tiles, self, 0 );
	}
	else
	{
		level.unsolved_tiles[ level.unsolved_tiles.size ] = self;
	}
	if ( level.unsolved_tiles.size == 0 && !flag( "ice_puzzle_1_complete" ) )
	{
		self thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( 4 );
		flag_set( "ice_puzzle_1_complete" );
	}
	self waittill( "rotatedone" );
}

ceiling_tile_process_damage()
{
	level endon( "ice_puzzle_1_complete" );
	ice_gem = getent( "ice_chamber_gem", "targetname" );
	self setcandamage( 1 );
	ice_gem setcandamage( 1 );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, mod, tagname, modelname, partname, weaponname );
		if ( issubstr( weaponname, "water" ) && self.showing_tile_side && !flag( "ice_tile_flipping" ) )
		{
			level notify( "vo_try_puzzle_water1" );
			flag_set( "ice_tile_flipping" );
			if ( ice_gem.value == self.value )
			{
				level notify( "vo_puzzle_good" );
				self ceiling_tile_flip( 0 );
				rumble_nearby_players( self.origin, 1500, 2 );
				wait 0,2;
			}
			else
			{
				level notify( "vo_puzzle_bad" );
				reset_tiles();
				rumble_nearby_players( self.origin, 1500, 2 );
				wait 2;
			}
			change_ice_gem_value();
			flag_clear( "ice_tile_flipping" );
			continue;
		}
		else
		{
			level notify( "vo_puzzle_confused" );
		}
	}
}

ice_puzzle_2_init()
{
}

ice_puzzle_2_run()
{
	a_stone_positions = getstructarray( "puzzle_stone_water", "targetname" );
	level.ice_stones_remaining = a_stone_positions.size;
	_a328 = a_stone_positions;
	_k328 = getFirstArrayKey( _a328 );
	while ( isDefined( _k328 ) )
	{
		s_stone = _a328[ _k328 ];
		s_stone thread ice_stone_run();
		wait_network_frame();
		_k328 = getNextArrayKey( _a328, _k328 );
	}
}

ice_stone_run()
{
	v_up = anglesToUp( self.angles );
	v_spawn_pos = self.origin - ( 64 * v_up );
	self.e_model = spawn( "script_model", v_spawn_pos );
	self.e_model.angles = self.angles;
	self.e_model setmodel( "p6_zm_tm_note_rock_01_anim" );
	self.e_model moveto( self.origin, 1, 0,5, 0,5 );
	playfx( level._effect[ "digging" ], self.origin );
	self.e_model setcandamage( 1 );
	has_tried = 0;
	while ( !flag( "ice_puzzle_2_complete" ) )
	{
		self.e_model waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		level notify( "vo_try_puzzle_water2" );
		if ( issubstr( weaponname, "water" ) )
		{
			level notify( "vo_puzzle_good" );
			break;
		}
		else if ( has_tried )
		{
			level notify( "vo_puzzle_bad" );
		}
		has_tried = 1;
	}
	self.e_model setclientfield( "stone_frozen", 1 );
	playsoundatposition( "zmb_squest_ice_stone_freeze", self.origin );
	while ( !flag( "ice_puzzle_2_complete" ) )
	{
		self.e_model waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		if ( !issubstr( weaponname, "staff" ) && issubstr( type, "BULLET" ) )
		{
			level notify( "vo_puzzle_good" );
			break;
		}
		else level notify( "vo_puzzle_confused" );
	}
	self.e_model delete();
	playfx( level._effect[ "ice_explode" ], self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
	playsoundatposition( "zmb_squest_ice_stone_shatter", self.origin );
	level.ice_stones_remaining--;

	while ( level.ice_stones_remaining <= 0 && !flag( "ice_puzzle_2_complete" ) )
	{
		flag_set( "ice_puzzle_2_complete" );
		e_player = get_closest_player( self.origin );
		e_player thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( 4 );
		level thread play_puzzle_stinger_on_all_players();
		level.weather_snow = 5;
		level.weather_rain = 0;
		_a408 = getplayers();
		_k408 = getFirstArrayKey( _a408 );
		while ( isDefined( _k408 ) )
		{
			player = _a408[ _k408 ];
			player set_weather_to_player();
			_k408 = getNextArrayKey( _a408, _k408 );
		}
		wait 5;
		level.weather_snow = 0;
		level.weather_rain = 0;
		_a419 = getplayers();
		_k419 = getFirstArrayKey( _a419 );
		while ( isDefined( _k419 ) )
		{
			player = _a419[ _k419 ];
			player set_weather_to_player();
			_k419 = getNextArrayKey( _a419, _k419 );
		}
	}
}
