#include maps/mp/zombies/_zm_audio;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "fxanim_props_dlc4" );

main()
{
	precachemodel( "p6_power_lever" );
	onplayerconnect_callback( ::on_player_connect_crypt );
	flag_init( "staff_air_zm_upgrade_unlocked" );
	flag_init( "staff_water_zm_upgrade_unlocked" );
	flag_init( "staff_fire_zm_upgrade_unlocked" );
	flag_init( "staff_lightning_zm_upgrade_unlocked" );
	flag_init( "disc_rotation_active" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_crypt" );
	init_crypt_gems();
	chamber_disc_puzzle_init();
}

on_player_connect_crypt()
{
	discs = getentarray( "crypt_puzzle_disc", "script_noteworthy" );
	_a42 = discs;
	_k42 = getFirstArrayKey( _a42 );
	while ( isDefined( _k42 ) )
	{
		disc = _a42[ _k42 ];
		disc delay_thread( 0,5, ::bryce_cake_light_update, 0 );
		_k42 = getNextArrayKey( _a42, _k42 );
	}
}

chamber_disc_puzzle_init()
{
	level.gem_start_pos = [];
	level.gem_start_pos[ "crypt_gem_fire" ] = 2;
	level.gem_start_pos[ "crypt_gem_air" ] = 3;
	level.gem_start_pos[ "crypt_gem_ice" ] = 0;
	level.gem_start_pos[ "crypt_gem_elec" ] = 1;
	chamber_discs = getentarray( "crypt_puzzle_disc", "script_noteworthy" );
	array_thread( chamber_discs, ::chamber_disc_run );
	flag_wait( "chamber_entrance_opened" );
	chamber_discs_randomize();
}

chamber_disc_run()
{
	flag_wait( "start_zombie_round_logic" );
	self.position = 0;
	self bryce_cake_light_update( 0 );
	if ( isDefined( self.target ) )
	{
		a_levers = getentarray( self.target, "targetname" );
		_a77 = a_levers;
		_k77 = getFirstArrayKey( _a77 );
		while ( isDefined( _k77 ) )
		{
			e_lever = _a77[ _k77 ];
			e_lever.trigger_stub = tomb_spawn_trigger_radius( e_lever.origin, 100, 1 );
			e_lever.trigger_stub.require_look_at = 0;
			if ( !isDefined( e_lever.script_string ) && isDefined( "clockwise" ) )
			{
				if ( isDefined( e_lever.script_string ) && isDefined( "clockwise" ) )
				{
					clockwise = e_lever.script_string == "clockwise";
				}
			}
			e_lever.trigger_stub thread chamber_disc_trigger_run( self, e_lever, clockwise );
			_k77 = getNextArrayKey( _a77, _k77 );
		}
		self thread chamber_disc_move_to_position();
	}
	self useanimtree( -1 );
	n_wait = randomfloatrange( 0, 5 );
	wait n_wait;
	self setanim( %fxanim_zom_tomb_chamber_piece_anim );
}

init_crypt_gems()
{
	disc = getent( "crypt_puzzle_disc_main", "targetname" );
	gems = getentarray( "crypt_gem", "script_noteworthy" );
	_a101 = gems;
	_k101 = getFirstArrayKey( _a101 );
	while ( isDefined( _k101 ) )
	{
		gem = _a101[ _k101 ];
		gem linkto( disc );
		gem thread run_crypt_gem_pos();
		_k101 = getNextArrayKey( _a101, _k101 );
	}
}

light_discs_bottom_to_top()
{
	discs = getentarray( "crypt_puzzle_disc", "script_noteworthy" );
	i = 1;
	while ( i <= 4 )
	{
		_a113 = discs;
		_k113 = getFirstArrayKey( _a113 );
		while ( isDefined( _k113 ) )
		{
			disc = _a113[ _k113 ];
			if ( !isDefined( disc.script_int ) || !isDefined( i ) && isDefined( disc.script_int ) && isDefined( i ) && disc.script_int == i )
			{
				disc bryce_cake_light_update( 1 );
				break;
			}
			else
			{
				_k113 = getNextArrayKey( _a113, _k113 );
			}
		}
		wait 1;
		i++;
	}
}

run_crypt_gem_pos()
{
	str_weapon = undefined;
	complete_flag = undefined;
	str_orb_path = undefined;
	str_glow_fx = undefined;
	n_element = self.script_int;
	switch( self.targetname )
	{
		case "crypt_gem_air":
			str_weapon = "staff_air_zm";
			complete_flag = "staff_air_zm_upgrade_unlocked";
			str_orb_path = "air_orb_exit_path";
			str_final_pos = "air_orb_plinth_final";
			break;
		case "crypt_gem_ice":
			str_weapon = "staff_water_zm";
			complete_flag = "staff_water_zm_upgrade_unlocked";
			str_orb_path = "ice_orb_exit_path";
			str_final_pos = "ice_orb_plinth_final";
			break;
		case "crypt_gem_fire":
			str_weapon = "staff_fire_zm";
			complete_flag = "staff_fire_zm_upgrade_unlocked";
			str_orb_path = "fire_orb_exit_path";
			str_final_pos = "fire_orb_plinth_final";
			break;
		case "crypt_gem_elec":
			str_weapon = "staff_lightning_zm";
			complete_flag = "staff_lightning_zm_upgrade_unlocked";
			str_orb_path = "lightning_orb_exit_path";
			str_final_pos = "lightning_orb_plinth_final";
			break;
		default:
/#
			assertmsg( "Unknown crypt gem targetname: " + self.targetname );
#/
			return;
	}
	e_gem_model = puzzle_orb_chamber_to_crypt( str_orb_path, self );
	e_main_disc = getent( "crypt_puzzle_disc_main", "targetname" );
	e_gem_model linkto( e_main_disc );
	str_targetname = self.targetname;
	self delete();
	e_gem_model setcandamage( 1 );
	while ( 1 )
	{
		e_gem_model waittill( "damage", damage, attacker, direction_vec, point, mod, tagname, modelname, partname, weaponname );
		if ( weaponname == str_weapon )
		{
			break;
		}
		else
		{
		}
	}
	e_gem_model setclientfield( "element_glow_fx", n_element );
	e_gem_model playsound( "zmb_squest_crystal_charge" );
	e_gem_model playloopsound( "zmb_squest_crystal_charge_loop", 2 );
	while ( 1 )
	{
		if ( chamber_disc_gem_has_clearance( str_targetname ) )
		{
			break;
		}
		else level waittill( "crypt_disc_rotation" );
	}
	flag_set( "disc_rotation_active" );
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "side_sting_5" );
	light_discs_bottom_to_top();
	level thread puzzle_orb_pillar_show();
	e_gem_model unlink();
	s_ascent = getstruct( "orb_crypt_ascent_path", "targetname" );
	v_next_pos = ( e_gem_model.origin[ 0 ], e_gem_model.origin[ 1 ], s_ascent.origin[ 2 ] );
	e_gem_model setclientfield( "element_glow_fx", n_element );
	playfxontag( level._effect[ "puzzle_orb_trail" ], e_gem_model, "tag_origin" );
	e_gem_model playsound( "zmb_squest_crystal_leave" );
	e_gem_model puzzle_orb_move( v_next_pos );
	flag_clear( "disc_rotation_active" );
	level thread chamber_discs_randomize();
	e_gem_model puzzle_orb_follow_path( s_ascent );
	v_next_pos = ( e_gem_model.origin[ 0 ], e_gem_model.origin[ 1 ], e_gem_model.origin[ 2 ] + 2000 );
	e_gem_model puzzle_orb_move( v_next_pos );
	s_chamber_path = getstruct( str_orb_path, "targetname" );
	str_model = e_gem_model.model;
	e_gem_model delete();
	e_gem_model = puzzle_orb_follow_return_path( s_chamber_path, n_element );
	s_final = getstruct( str_final_pos, "targetname" );
	e_gem_model puzzle_orb_move( s_final.origin );
	e_new_gem = spawn( "script_model", s_final.origin );
	e_new_gem setmodel( e_gem_model.model );
	e_new_gem.script_int = n_element;
	e_new_gem setclientfield( "element_glow_fx", n_element );
	e_gem_model delete();
	e_new_gem playsound( "zmb_squest_crystal_arrive" );
	e_new_gem playloopsound( "zmb_squest_crystal_charge_loop", 0,1 );
	flag_set( complete_flag );
}

chamber_disc_move_to_position()
{
	new_angles = ( self.angles[ 0 ], self.position * 90, self.angles[ 2 ] );
	self rotateto( new_angles, 1, 0, 0 );
	self playsound( "zmb_crypt_disc_turn" );
	wait ( 1 * 0,75 );
	self bryce_cake_light_update( 0 );
	wait ( 1 * 0,25 );
	self bryce_cake_light_update( 0 );
	self playsound( "zmb_crypt_disc_stop" );
	rumble_nearby_players( self.origin, 1000, 2 );
}

chamber_discs_move_all_to_position( discs )
{
	if ( !isDefined( discs ) )
	{
		discs = undefined;
	}
	flag_set( "disc_rotation_active" );
	if ( !isDefined( discs ) )
	{
		discs = getentarray( "chamber_puzzle_disc", "script_noteworthy" );
	}
	_a285 = discs;
	_k285 = getFirstArrayKey( _a285 );
	while ( isDefined( _k285 ) )
	{
		e_disc = _a285[ _k285 ];
		e_disc chamber_disc_move_to_position();
		_k285 = getNextArrayKey( _a285, _k285 );
	}
	flag_clear( "disc_rotation_active" );
}

chamber_disc_get_gem_position( gem_name )
{
	disc = getent( "crypt_puzzle_disc_main", "targetname" );
	return ( disc.position + level.gem_start_pos[ gem_name ] ) % 4;
}

chamber_disc_gem_has_clearance( gem_name )
{
	gem_position = chamber_disc_get_gem_position( gem_name );
	discs = getentarray( "crypt_puzzle_disc", "script_noteworthy" );
	_a303 = discs;
	_k303 = getFirstArrayKey( _a303 );
	while ( isDefined( _k303 ) )
	{
		disc = _a303[ _k303 ];
		if ( !isDefined( disc.targetname ) || !isDefined( "crypt_puzzle_disc_main" ) && isDefined( disc.targetname ) && isDefined( "crypt_puzzle_disc_main" ) && disc.targetname == "crypt_puzzle_disc_main" )
		{
		}
		else
		{
			if ( disc.position != gem_position )
			{
				return 0;
			}
		}
		_k303 = getNextArrayKey( _a303, _k303 );
	}
	return 1;
}

chamber_disc_rotate( b_clockwise )
{
	if ( b_clockwise )
	{
		self.position = ( self.position + 1 ) % 4;
	}
	else
	{
		self.position = ( self.position + 3 ) % 4;
	}
	self chamber_disc_move_to_position();
}

bryce_cake_light_update( b_on )
{
	if ( !isDefined( b_on ) )
	{
		b_on = 1;
	}
	if ( !isDefined( self.n_bryce_cake ) )
	{
		self.n_bryce_cake = 0;
	}
	if ( !b_on )
	{
		self.n_bryce_cake = ( self.n_bryce_cake + 1 ) % 2;
	}
	else
	{
		self.n_bryce_cake = 2;
	}
	self setclientfield( "bryce_cake", self.n_bryce_cake );
}

chamber_discs_randomize()
{
	discs = getentarray( "crypt_puzzle_disc", "script_noteworthy" );
	prev_disc_pos = 0;
	_a345 = discs;
	_k345 = getFirstArrayKey( _a345 );
	while ( isDefined( _k345 ) )
	{
		disc = _a345[ _k345 ];
		if ( !isDefined( disc.target ) )
		{
		}
		else
		{
			disc.position = ( prev_disc_pos + randomintrange( 1, 3 ) ) % 4;
			prev_disc_pos = disc.position;
		}
		_k345 = getNextArrayKey( _a345, _k345 );
	}
	chamber_discs_move_all_to_position( discs );
}

chamber_disc_switch_spark()
{
	self setclientfield( "switch_spark", 1 );
	wait 0,5;
	self setclientfield( "switch_spark", 0 );
}

chamber_disc_trigger_run( e_disc, e_lever, b_clockwise )
{
	discs_to_rotate = array( e_disc );
	e_lever useanimtree( -1 );
	n_anim_time = getanimlength( %fxanim_zom_tomb_puzzle_lever_switch_anim );
	while ( 1 )
	{
		self waittill( "trigger", e_triggerer );
		if ( !flag( "disc_rotation_active" ) )
		{
			flag_set( "disc_rotation_active" );
			e_lever setanim( %fxanim_zom_tomb_puzzle_lever_switch_anim, 1, 0, 1 );
			e_lever playsound( "zmb_crypt_lever" );
			wait ( n_anim_time * 0,5 );
			e_lever thread chamber_disc_switch_spark();
			array_thread( discs_to_rotate, ::chamber_disc_rotate, b_clockwise );
			wait 1;
			e_lever clearanim( %fxanim_zom_tomb_puzzle_lever_switch_anim, 0 );
			flag_clear( "disc_rotation_active" );
			level notify( "vo_try_puzzle_crypt" );
		}
		level notify( "crypt_disc_rotation" );
	}
}
