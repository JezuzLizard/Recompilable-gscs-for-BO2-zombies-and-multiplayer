#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_ai_sloth;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_weap_time_bomb;
#include maps/mp/zombies/_zm_perk_vulture;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm;
#include maps/mp/zm_buried_ee;
#include maps/mp/zm_buried_maze;
#include maps/mp/zm_buried_power;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zm_buried_buildables;
#include maps/mp/zm_buried_fountain;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache()
{
	precacheshellshock( "electrocution" );
	if ( getDvar( "createfx" ) != "" )
	{
		return;
	}
	maps/mp/zombies/_zm_ai_ghost::init_animtree();
	level thread lsat_trigger_tweak();
	setup_buildables();
	maps/mp/zombies/_zm_equip_turbine::init( &"ZOMBIE_EQUIP_TURBINE_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_TURBINE_HOWTO" );
	maps/mp/zombies/_zm_equip_turbine::init_animtree();
	maps/mp/zombies/_zm_equip_springpad::init( &"ZM_BURIED_EQ_SP_PHS", &"ZM_BURIED_EQ_SP_HTS" );
	maps/mp/zombies/_zm_equip_subwoofer::init( &"ZM_BURIED_EQ_SW_PHS", &"ZM_BURIED_EQ_SW_HTS" );
	maps/mp/zombies/_zm_equip_headchopper::init( &"ZM_BURIED_EQ_HC_PHS", &"ZM_BURIED_EQ_HC_HTS" );
	level.springpad_attack_delay = 0,2;
	maps/mp/zm_buried_fountain::init_fountain();
	level thread perk_vulture_custom_scripts();
}

setup_buildables()
{
	classicbuildables = array( "sq_common", "turbine", "springpad_zm", "subwoofer_zm", "headchopper_zm", "booze", "candy", "chalk", "sloth", "keys_zm", "buried_sq_oillamp", "buried_sq_tpo_switch", "buried_sq_ghost_lamp", "buried_sq_bt_m_tower", "buried_sq_bt_r_tower" );
	maps/mp/zm_buried_buildables::include_buildables( classicbuildables );
	maps/mp/zm_buried_buildables::init_buildables( classicbuildables );
}

main()
{
	flag_init( "sq_minigame_active" );
	setdvar( "player_sliding_velocity_cap", 80 );
	setdvar( "player_sliding_wishspeed", 800 );
	level.buildables_built[ "pap" ] = 1;
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "processing" );
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	if ( !isDefined( level.zombie_include_buildables ) )
	{
		setup_buildables();
	}
	level thread maps/mp/zombies/_zm_buildables::think_buildables();
	level thread maps/mp/zm_buried_power::electric_switch();
	level thread maps/mp/zm_buried_maze::maze_think();
/#
	level thread setup_temp_sloth_triggers();
	level thread generator_open_sesame();
	level thread fountain_open_sesame();
#/
	flag_wait( "initial_blackscreen_passed" );
	level thread vo_level_start();
	level thread vo_stay_topside();
	level thread vo_fall_down_hole();
	level thread vo_find_town();
	level thread dart_game_init();
	level thread piano_init();
	level thread sliding_bookcase_init();
	level thread quick_revive_solo_watch();
	level thread zm_treasure_chest_init();
	level thread maps/mp/zm_buried_ee::init_ghost_piano();
	level thread buried_set_underground_lighting();
	exploder( 666 );
	level.zm_traversal_override = ::zm_traversal_override;
	level.zm_mantle_over_40_move_speed_override = ::mantle_over_40_move_speed_override;
	blockers = getentarray( "main_street_blocker", "targetname" );
	_a116 = blockers;
	_k116 = getFirstArrayKey( _a116 );
	while ( isDefined( _k116 ) )
	{
		blocker = _a116[ _k116 ];
		blocker disconnectpaths();
		_k116 = getNextArrayKey( _a116, _k116 );
	}
	level.insta_kill_triggers = getentarray( "instant_death", "targetname" );
	array_thread( level.insta_kill_triggers, ::squashed_death_init, 0 );
	if ( isDefined( level.sloth ) )
	{
		level.sloth.custom_crawler_pickup_func = ::sloth_crawler_pickup_vulture_fx_correction_func;
		level.sloth.custom_box_move_func = ::sloth_box_move_show_vulture_fx;
	}
	maps/mp/zombies/_zm::register_player_damage_callback( ::classic_player_damage_callback );
}

vo_level_start()
{
	wait 5;
	random( get_players() ) maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "game_start" );
}

vo_stay_topside()
{
	flag_wait( "start_zombie_round_logic" );
	level waittill( "between_round_over" );
	wait 4;
	players_in_start_area = maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_start", 1 );
	if ( isDefined( players_in_start_area ) && players_in_start_area.size > 0 )
	{
		random( players_in_start_area ) maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "stay_topside" );
	}
}

vo_fall_down_hole()
{
	stables_roof_trigger = spawn( "trigger_radius", ( -1304, -320, 332 ), 0, 128, 128 );
	while ( 1 )
	{
		stables_roof_trigger waittill( "trigger", player );
		if ( isplayer( player ) )
		{
			level notify( "stables_roof_discovered" );
			level.vo_player_who_discovered_stables_roof = player;
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "fall_down_hole" );
			break;
		}
		else
		{
			wait 0,05;
		}
	}
	while ( isDefined( player ) && isDefined( player.isspeaking ) && player.isspeaking )
	{
		wait 1;
	}
	players_in_start_area = maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_start", 1 );
	if ( isDefined( players_in_start_area ) && players_in_start_area.size > 0 )
	{
		random( players_in_start_area ) maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "fall_down_hole_response" );
	}
	stables_roof_trigger delete();
}

vo_find_town()
{
	level waittill( "stables_roof_discovered" );
	while ( 1 )
	{
		players_in_town_area = maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_street_lighteast", 1 );
		players_in_town_area = arraycombine( players_in_town_area, maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_street_lightwest", 1 ), 0, 0 );
		if ( isDefined( players_in_town_area ) && players_in_town_area.size > 0 )
		{
			random( players_in_town_area ) maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "find_town" );
			return;
		}
		wait 2;
	}
}

generator_oil_lamp_control()
{
	lignts_on = 0;
	level.generator_power_states_color = 0;
	while ( 1 )
	{
		wait_for_buildable( "oillamp_zm" );
		level.generator_is_active = 1;
		level setclientfield( "GENERATOR_POWER_STATES_COLOR", level.generator_power_states_color );
		level setclientfield( "GENERATOR_POWER_STATES", 1 );
		level thread reset_generator_lerp_val();
		exploder( 300 );
		if ( isDefined( level.oil_lamp_power ) )
		{
			oil_lamp_power = level.oil_lamp_power;
			level.oil_lamp_power = undefined;
		}
		else
		{
			oil_lamp_power = 1;
		}
		if ( !isDefined( level.generator_buildable_full_power_time ) )
		{
			level.generator_buildable_full_power_time = 300;
		}
		full_power_wait_time = level.generator_buildable_full_power_time * oil_lamp_power;
		wait full_power_wait_time;
		level setclientfield( "GENERATOR_POWER_STATES", 2 );
		level thread lerp_down_generator_light_levels( level.generator_buildable_blinkout_time );
		wait level.generator_buildable_blinkout_time;
		level setclientfield( "GENERATOR_POWER_STATES", 0 );
		level.generator_power_states_color = 0;
		stop_exploder( 300 );
		level notify( level.str_generator_power_runs_out_notify );
		level.generator_is_active = 0;
		wait 0,01;
	}
}

reset_generator_lerp_val()
{
	wait 1;
	level setclientfield( "GENERATOR_POWER_STATES_LERP", 1 );
}

lerp_down_generator_light_levels( blinkout_time )
{
	wait_lights1 = blinkout_time * 0,05;
	wait_delay1 = blinkout_time * 0,3;
	wait_lights2 = blinkout_time * 0,1;
	wait_delay2 = blinkout_time * 0,4;
	wait_lights3 = blinkout_time * 0,15;
	level thread lerp_generator_lights( wait_lights1, 1, 0,84 );
	level waittill( "generator_lerp_done" );
	wait wait_delay1;
	level thread lerp_generator_lights( wait_lights2, 0,84, 0,4 );
	level waittill( "generator_lerp_done" );
	wait wait_delay2;
	level thread lerp_generator_lights( wait_lights3, 0,4, 0 );
	level waittill( "generator_lerp_done" );
}

lerp_generator_lights( total_time, start_val, end_val )
{
	start_time = getTime();
	end_time = start_time + ( total_time * 1000 );
	lerp_step = 1;
	last_lerp = start_time;
	while ( 1 )
	{
		time = getTime();
		if ( time >= end_time )
		{
			break;
		}
		else
		{
			dt = ( time - last_lerp ) / 1000;
			if ( dt >= lerp_step )
			{
				elapsed = time - start_time;
				if ( elapsed )
				{
					delta = elapsed / ( total_time * 1000 );
					val = lerpfloat( start_val, end_val, delta );
					level setclientfield( "GENERATOR_POWER_STATES_LERP", val );
				}
				last_lerp = time;
			}
			wait 0,01;
		}
	}
	level notify( "generator_lerp_done" );
}

collapsing_holes_init()
{
	trigs = getentarray( "hole_breakthrough", "targetname" );
	clientfieldnames = [];
	_a398 = trigs;
	_k398 = getFirstArrayKey( _a398 );
	while ( isDefined( _k398 ) )
	{
		trig = _a398[ _k398 ];
		parts = getentarray( trig.target, "targetname" );
		_a401 = parts;
		_k401 = getFirstArrayKey( _a401 );
		while ( isDefined( _k401 ) )
		{
			part = _a401[ _k401 ];
			if ( isDefined( part.script_noteworthy ) && part.script_noteworthy == "clip" )
			{
				trig.clip = part;
			}
			else
			{
				trig.boards = part;
			}
			_k401 = getNextArrayKey( _a401, _k401 );
		}
		if ( isDefined( trig.script_string ) )
		{
			clientfieldnames[ trig.script_string ] = 1;
		}
		_k398 = getNextArrayKey( _a398, _k398 );
	}
	keys = getarraykeys( clientfieldnames );
	i = 0;
	while ( i < keys.size )
	{
		registerclientfield( "world", keys[ i ], 12000, 1, "int" );
		i++;
	}
	if ( isDefined( trigs ) )
	{
		array_thread( trigs, ::collapsing_holes );
		array_thread( trigs, ::tunnel_breach );
	}
}

collapsing_holes()
{
	self endon( "breached" );
	if ( !isDefined( self ) && !isDefined( self.boards ) )
	{
		return;
	}
	self waittill( "trigger", who );
	if ( is_player_valid( who ) )
	{
		if ( isDefined( self.script_string ) )
		{
			level setclientfield( self.script_string, 1 );
			note = "none";
			if ( isDefined( self.script_noteworthy ) )
			{
				note = self.script_noteworthy;
			}
/#
			println( "***!!!*** Set client field " + self.script_string + " Associated script_noteworthy " + note );
#/
		}
		if ( isDefined( self.boards ) )
		{
			if ( isDefined( self.script_int ) )
			{
				exploder( self.script_int );
			}
			else
			{
				playfx( level._effect[ "wood_chunk_destory" ], self.boards.origin );
			}
			self thread sndcollapsing();
			self.boards delete();
			if ( isDefined( self.clip ) )
			{
				self.clip delete();
			}
			self notify( "breached" );
			self delete();
		}
	}
}

sndcollapsing()
{
	if ( !isDefined( self.script_noteworthy ) )
	{
		return;
	}
	if ( self.script_noteworthy == "hole_small_2" )
	{
		self playsound( "zmb_floor_collapse" );
	}
	else if ( self.script_noteworthy == "hole_small_1" )
	{
		self playsound( "zmb_floor_collapse" );
	}
	else
	{
		if ( self.script_noteworthy == "hole_large_1" )
		{
			self playsound( "zmb_floor_collapse" );
		}
	}
}

tunnel_breach()
{
	level endon( "intermission" );
	self endon( "breached" );
	if ( !isDefined( self ) && !isDefined( self.boards ) )
	{
		return;
	}
	self.boards.health = 99999;
	self.boards setcandamage( 1 );
	self.boards.damage_state = 0;
	while ( 1 )
	{
		self.boards waittill( "damage", amount, attacker, direction, point, dmg_type, modelname, tagname, partname, weaponname );
		if ( isDefined( weaponname ) && weaponname != "emp_grenade_zm" || weaponname == "ray_gun_zm" && weaponname == "ray_gun_upgraded_zm" )
		{
			continue;
		}
		if ( isDefined( amount ) && amount <= 1 )
		{
			continue;
		}
		if ( isplayer( attacker ) && dmg_type != "MOD_PROJECTILE" && dmg_type != "MOD_PROJECTILE_SPLASH" && dmg_type != "MOD_EXPLOSIVE" && dmg_type != "MOD_EXPLOSIVE_SPLASH" || dmg_type == "MOD_GRENADE" && dmg_type == "MOD_GRENADE_SPLASH" )
		{
			if ( self.boards.damage_state == 0 )
			{
				self.boards.damage_state = 1;
			}
			if ( isDefined( self.script_int ) )
			{
				exploder( self.script_int );
			}
			else
			{
				playfx( level._effect[ "wood_chunk_destory" ], self.origin );
			}
			if ( isDefined( self.script_string ) )
			{
				level setclientfield( self.script_string, 1 );
			}
			if ( isDefined( self.script_flag ) )
			{
				flag_set( self.script_flag );
			}
			if ( isDefined( self.clip ) )
			{
				self.clip connectpaths();
				self.clip delete();
			}
			self.boards delete();
			self notify( "breached" );
			self delete();
			return;
		}
	}
}

quick_revive_solo_watch()
{
	machine_triggers = getentarray( "vending_revive", "target" );
	machine_trigger = machine_triggers[ 0 ];
	while ( 1 )
	{
		level waittill_any( "solo_revive", "revive_off", "revive_hide" );
		if ( isDefined( machine_trigger.machine ) )
		{
			machine_trigger.machine maps/mp/zombies/_zm_equip_headchopper::destroyheadchopperstouching();
		}
	}
}

sliding_bookcase_init()
{
	bookcase_triggers = getentarray( "zombie_sliding_bookcase", "script_noteworthy" );
	_a604 = bookcase_triggers;
	_k604 = getFirstArrayKey( _a604 );
	while ( isDefined( _k604 ) )
	{
		trig = _a604[ _k604 ];
		trig.doors = [];
		targets = getentarray( trig.target, "targetname" );
		_a610 = targets;
		_k610 = getFirstArrayKey( _a610 );
		while ( isDefined( _k610 ) )
		{
			target = _a610[ _k610 ];
			target notsolid();
			if ( target.classname == "script_brushmodel" )
			{
				target connectpaths();
			}
			if ( target.classname == "script_model" )
			{
				trig thread sliding_bookcase_wobble( target );
			}
			target maps/mp/zombies/_zm_blockers::door_classify( trig );
			target.startpos = target.origin;
			target.startang = target.angles;
			if ( target.classname == "script_brushmodel" )
			{
				target solid();
			}
			_k610 = getNextArrayKey( _a610, _k610 );
		}
		_k604 = getNextArrayKey( _a604, _k604 );
	}
	array_thread( bookcase_triggers, ::sliding_bookcase_think );
}

sliding_bookcase_think()
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isDefined( who.bookcase_entering_callback ) )
		{
			who thread [[ who.bookcase_entering_callback ]]( self.doors[ 0 ] );
		}
		self playsound( "zmb_sliding_bookcase_open" );
		while ( isDefined( self.doors[ 0 ].door_moving ) || self.doors[ 0 ].door_moving && isDefined( self._door_open ) && self._door_open )
		{
			continue;
		}
		_a657 = self.doors;
		_k657 = getFirstArrayKey( _a657 );
		while ( isDefined( _k657 ) )
		{
			piece = _a657[ _k657 ];
			piece thread sliding_bookcase_activate( 1 );
			_k657 = getNextArrayKey( _a657, _k657 );
		}
		while ( isDefined( self.doors[ 0 ].door_moving ) || self.doors[ 0 ].door_moving && self sliding_bookcase_occupied() )
		{
			wait 0,1;
		}
		_a667 = self.doors;
		_k667 = getFirstArrayKey( _a667 );
		while ( isDefined( _k667 ) )
		{
			piece = _a667[ _k667 ];
			piece thread sliding_bookcase_activate( 0 );
			_k667 = getNextArrayKey( _a667, _k667 );
		}
		self._door_open = 0;
		self playsound( "zmb_sliding_bookcase_close" );
	}
}

sliding_bookcase_activate( open )
{
	if ( !isDefined( open ) )
	{
		open = 1;
	}
	if ( isDefined( self.door_moving ) )
	{
		return;
	}
	self.door_moving = 1;
	if ( isDefined( self.script_sound ) )
	{
		if ( open )
		{
		}
	}
	scale = 1;
	speed = 15;
	if ( !open )
	{
		scale = -1;
		speed = 13;
	}
	switch( self.script_string )
	{
		case "move":
			if ( isDefined( self.script_vector ) )
			{
				vector = vectorScale( self.script_vector, scale );
				movetopos = self.origin;
				if ( open )
				{
					if ( isDefined( self.startpos ) )
					{
						movetopos = self.startpos + vector;
					}
					else
					{
						movetopos = self.origin + vector;
					}
					self._door_open = 1;
				}
				else
				{
					if ( isDefined( self.startpos ) )
					{
						movetopos = self.startpos;
					}
					else
					{
						movetopos = self.origin - vector;
					}
					self._door_open = 0;
				}
				dist = distance( self.origin, movetopos );
				time = dist / speed;
				q_time = time * 0,25;
				if ( q_time > 1 )
				{
					q_time = 1;
				}
				self moveto( movetopos, time, q_time, q_time );
				self thread maps/mp/zombies/_zm_blockers::door_solid_thread();
			}
			break;
	}
}

sliding_bookcase_occupied()
{
	is_occupied = 0;
	players = get_players();
	_a772 = players;
	_k772 = getFirstArrayKey( _a772 );
	while ( isDefined( _k772 ) )
	{
		player = _a772[ _k772 ];
		if ( is_occupied > 0 )
		{
			break;
		}
		else
		{
			if ( player istouching( self ) )
			{
				is_occupied++;
			}
			_k772 = getNextArrayKey( _a772, _k772 );
		}
	}
	ghosts = getentarray( "ghost_zombie_spawner", "script_noteworthy" );
	_a786 = ghosts;
	_k786 = getFirstArrayKey( _a786 );
	while ( isDefined( _k786 ) )
	{
		ghost = _a786[ _k786 ];
		if ( is_occupied > 0 )
		{
			break;
		}
		else
		{
			if ( ghost istouching( self ) )
			{
				is_occupied++;
			}
			_k786 = getNextArrayKey( _a786, _k786 );
		}
	}
	if ( is_occupied > 0 )
	{
		if ( isDefined( self.doors[ 0 ].startpos ) && self.doors[ 0 ].startpos == self.doors[ 0 ].origin )
		{
			_a803 = self.doors;
			_k803 = getFirstArrayKey( _a803 );
			while ( isDefined( _k803 ) )
			{
				piece = _a803[ _k803 ];
				piece thread sliding_bookcase_activate( 1 );
				_k803 = getNextArrayKey( _a803, _k803 );
			}
			self._door_open = 1;
		}
		return 1;
	}
	return 0;
}

sliding_bookcase_wobble( model )
{
	while ( 1 )
	{
		if ( isDefined( self.doors[ 0 ].door_moving ) && self.doors[ 0 ].door_moving )
		{
			model rotateto( ( randomfloatrange( -2,5, 2,5 ), randomfloatrange( -0,5, 0,5 ), randomfloatrange( -0,5, 0,5 ) ), 0,5, 0,125, 0,125 );
			wait ( 0,5 - 0,125 );
			continue;
		}
		else
		{
			if ( isDefined( model.startang ) && model.angles != model.startang )
			{
				model rotateto( model.startang, 0,5, 0,125, 0,125 );
				model waittill( "rotatedone" );
				break;
			}
			else
			{
				wait 0,5;
			}
		}
	}
}

dart_game_init()
{
	dart_board = getentarray( "dart_board", "targetname" );
	if ( !isDefined( dart_board ) )
	{
		return;
	}
	_a860 = dart_board;
	_k860 = getFirstArrayKey( _a860 );
	while ( isDefined( _k860 ) )
	{
		piece = _a860[ _k860 ];
		piece thread dart_game_piece_think();
		_k860 = getNextArrayKey( _a860, _k860 );
	}
}

dart_game_piece_think()
{
	self setcandamage( 1 );
	while ( 1 )
	{
		self waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		if ( isDefined( inflictor ) && isplayer( inflictor ) && dart_game_is_valid_weapon( weaponname ) )
		{
			while ( !inflictor dart_game_is_award_valid() )
			{
				continue;
			}
			if ( distance2dsquared( inflictor.origin, self.origin ) > 16384 )
			{
				award = 0;
				switch( self.script_noteworthy )
				{
					case "white_ring":
						award = 50;
						break;
					case "black_ring":
						award = 25;
						break;
					case "bullseye":
						award = 100;
						break;
				}
				inflictor dart_game_give_award( award );
			}
		}
	}
}

dart_game_is_valid_weapon( weaponname )
{
	if ( issubstr( weaponname, "knife_ballistic_" ) )
	{
		return 1;
	}
	return 0;
}

dart_game_is_award_valid()
{
	if ( isDefined( self.dart_round ) && self.dart_round == level.round_number )
	{
		if ( isDefined( self.dart_round_score ) && self.dart_round_score >= 200 )
		{
			return 0;
		}
	}
	else
	{
		self.dart_round = level.round_number;
		self.dart_round_score = 0;
	}
	return 1;
}

dart_game_give_award( award )
{
	if ( ( self.dart_round_score + award ) > 200 )
	{
		award = 200 - self.dart_round_score;
	}
	self.dart_round_score += award;
	self maps/mp/zombies/_zm_score::add_to_player_score( award );
}

piano_init()
{
	array_thread( getentarray( "piano_key", "targetname" ), ::pianothink );
	array_thread( getentarray( "piano_damage", "targetname" ), ::pianodamagethink );
}

pianothink()
{
	note = self.script_noteworthy;
	self usetriggerrequirelookat();
	self sethintstring( &"NULL_EMPTY" );
	self setcursorhint( "HINT_NOICON" );
	for ( ;; )
	{
		self waittill( "trigger", who );
		if ( who istouching( self ) )
		{
/#
			iprintlnbold( "Playing Piano Key: " + note );
#/
			self playsound( "zmb_piano_" + note );
		}
	}
}

pianodamagethink()
{
	noise_level = array( "soft", "loud" );
	for ( ;; )
	{
		self waittill( "trigger", who );
		type = random( noise_level );
		if ( isDefined( who ) && isplayer( who ) )
		{
/#
			iprintlnbold( "Piano Damage: " + type );
#/
			self playsound( "zmb_piano_damage_" + type );
		}
	}
}

zm_treasure_chest_init()
{
	done = 0;
	level.maze_chests = [];
	while ( isDefined( level.chests ) && !done )
	{
		done = 1;
		_a1009 = level.chests;
		_k1009 = getFirstArrayKey( _a1009 );
		while ( isDefined( _k1009 ) )
		{
			chest = _a1009[ _k1009 ];
			if ( issubstr( chest.script_noteworthy, "maze_chest" ) )
			{
				done = 0;
				level.maze_chests[ level.maze_chests.size ] = chest;
				arrayremovevalue( level.chests, chest );
				break;
			}
			else
			{
				_k1009 = getNextArrayKey( _a1009, _k1009 );
			}
		}
	}
	maps/mp/zombies/_zm_magicbox::init_starting_chest_location( "start_chest" );
	trig = getent( "maze_box_trigger", "targetname" );
	if ( isDefined( trig ) )
	{
		trig waittill( "trigger", who );
		if ( is_player_valid( who ) )
		{
			while ( isDefined( level.maze_chests ) && level.maze_chests.size > 0 )
			{
				i = 0;
				while ( i < level.maze_chests.size )
				{
					level.chests[ level.chests.size ] = level.maze_chests[ i ];
					i++;
				}
			}
			trig delete();
		}
	}
}

generator_open_sesame()
{
/#
	while ( 1 )
	{
		level waittill_any( "open_sesame", "generator_lights_on" );
		level.oil_lamp_power = 60;
#/
	}
}

fountain_open_sesame()
{
/#
	level waittill( "open_sesame" );
	level notify( "courtyard_fountain_open" );
	level notify( "_destroy_maze_fountain" );
#/
}

setup_temp_sloth_triggers()
{
/#
	sloth_triggers = getentarray( "sloth_barricade", "targetname" );
	_a1073 = sloth_triggers;
	_k1073 = getFirstArrayKey( _a1073 );
	while ( isDefined( _k1073 ) )
	{
		trigger = _a1073[ _k1073 ];
		trigger thread watch_opensesame();
		_k1073 = getNextArrayKey( _a1073, _k1073 );
	}
	level waittill_any( "open_sesame", "open_sloth_barricades" );
	level notify( "jail_barricade_down" );
#/
}

watch_opensesame()
{
/#
	self endon( "death" );
	script_flag = self.script_flag;
	target = self.target;
	level waittill_any( "open_sesame", "open_sloth_barricades" );
	self open_barricade( script_flag, target );
#/
}

open_barricade( script_flag, target )
{
/#
	if ( isDefined( script_flag ) && level flag_exists( script_flag ) )
	{
		flag_set( script_flag );
	}
	while ( isDefined( target ) )
	{
		barricades = getentarray( target, "targetname" );
		while ( isDefined( barricades ) && barricades.size )
		{
			_a1103 = barricades;
			_k1103 = getFirstArrayKey( _a1103 );
			while ( isDefined( _k1103 ) )
			{
				barricade = _a1103[ _k1103 ];
				if ( isDefined( self.func_no_delete ) )
				{
					barricade [[ self.func_no_delete ]]();
				}
				else
				{
					barricade delete();
				}
				_k1103 = getNextArrayKey( _a1103, _k1103 );
			}
		}
	}
	if ( isDefined( self.func_no_delete ) )
	{
		self [[ self.func_no_delete ]]();
	}
	else
	{
		self delete();
#/
	}
}

perk_vulture_custom_scripts()
{
}

zm_traversal_override( traversealias )
{
	self.no_restart = 0;
	if ( is_true( self.is_sloth ) )
	{
		node = self getnegotiationstartnode();
		if ( isDefined( node ) )
		{
			if ( isDefined( self.buildable_model ) )
			{
				if ( isDefined( node.script_parameters ) )
				{
					return node.script_parameters;
				}
			}
			if ( isDefined( node.script_string ) )
			{
				return node.script_string;
			}
		}
	}
	return traversealias;
}

mantle_over_40_move_speed_override()
{
	traversealias = "barrier_walk";
	if ( is_true( self.is_sloth ) )
	{
		return traversealias;
	}
	switch( self.zombie_move_speed )
	{
		case "run_floating":
			traversealias = "barrier_run_floating";
			break;
		case "walk_floating":
			traversealias = "barrier_walk_floating";
			break;
		default:
/#
			assertmsg( "Zombie move speed of '" + self.zombie_move_speed + "' is not supported for mantle_over_40." );
#/
	}
	return traversealias;
}

hide_boxes_for_minigame()
{
	if ( isDefined( level.chests ) && isDefined( level.chest_index ) )
	{
		chest = level.chests[ level.chest_index ];
		if ( !isDefined( chest ) )
		{
			return;
		}
		if ( isDefined( chest.unitrigger_stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( chest.unitrigger_stub );
		}
		if ( isDefined( chest.pandora_light ) )
		{
			chest.pandora_light delete();
		}
		chest.hidden = 1;
		if ( isDefined( chest.zbarrier ) )
		{
			i = 0;
			while ( i < chest.zbarrier getnumzbarrierpieces() )
			{
				chest.zbarrier hidezbarrierpiece( i );
				i++;
			}
			chest.zbarrier notify( "zbarrier_state_change" );
			chest.zbarrier maps/mp/zombies/_zm_perk_vulture::vulture_perk_shows_mystery_box( 0 );
		}
	}
	level.disable_firesale_drop = 1;
}

unhide_boxes_for_minigame()
{
	chest = level.chests[ level.chest_index ];
	if ( !isDefined( chest ) )
	{
		return;
	}
	chest thread [[ level.pandora_fx_func ]]();
	chest.zbarrier maps/mp/zombies/_zm_magicbox::set_magic_box_zbarrier_state( "initial" );
	chest.zbarrier maps/mp/zombies/_zm_perk_vulture::vulture_perk_shows_mystery_box( 1 );
	level.disable_firesale_drop = 0;
}

store_worldstate_for_minigame()
{
	flag_set( "sq_minigame_active" );
	if ( isDefined( level._world_state_stored_for_minigame ) )
	{
/#
		assertmsg( "store_worldstate_for_minigame called more than once." );
#/
		return;
	}
	flag_set( "time_bomb_stores_door_state" );
	level._world_state_stored_for_minigame = spawnstruct();
	maps/mp/zombies/_zm_weap_time_bomb::_time_bomb_saves_data( 0, level._world_state_stored_for_minigame );
	give_default_minigame_loadout();
	onplayerconnect_callback( ::give_player_minigame_loadout_wrapper );
}

restore_worldstate_for_minigame()
{
	if ( !isDefined( level._world_state_stored_for_minigame ) )
	{
/#
		assertmsg( "restore_worldstate_for_minigame called with no prior call to store_worldstate_for_minigame." );
#/
		return;
	}
	level.timebomb_override_struct = level._world_state_stored_for_minigame;
	level.round_spawn_func = ::maps/mp/zombies/_zm::round_spawning;
	maps/mp/zombies/_zm_weap_time_bomb::time_bomb_restores_saved_data( 0, level._world_state_stored_for_minigame );
	level thread delay_destroy_timebomb_override_structs();
	blockers = getentarray( "main_street_blocker", "targetname" );
	_a1280 = blockers;
	_k1280 = getFirstArrayKey( _a1280 );
	while ( isDefined( _k1280 ) )
	{
		blocker = _a1280[ _k1280 ];
		blocker.origin += vectorScale( ( 0, 0, -1 ), 360 );
		blocker disconnectpaths();
		_k1280 = getNextArrayKey( _a1280, _k1280 );
	}
	unhide_boxes_for_minigame();
	level setclientfield( "GENERATOR_POWER_STATES", 0 );
	flag_clear( "sq_minigame_active" );
	level notify( "sq_boss_battle_complete" );
}

delay_destroy_timebomb_override_structs()
{
	wait 3;
	flag_clear( "time_bomb_stores_door_state" );
	level._world_state_stored_for_minigame = undefined;
	level.timebomb_override_struct = undefined;
}

give_default_minigame_loadout()
{
	players = get_players();
	_a1307 = players;
	_k1307 = getFirstArrayKey( _a1307 );
	while ( isDefined( _k1307 ) )
	{
		player = _a1307[ _k1307 ];
		player give_player_minigame_loadout();
		_k1307 = getNextArrayKey( _a1307, _k1307 );
	}
}

give_player_minigame_loadout_wrapper()
{
	if ( flag( "sq_minigame_active" ) )
	{
		self give_player_minigame_loadout();
	}
}

give_player_minigame_loadout()
{
	self.dontspeak = 1;
	self takeallweapons();
	self maps/mp/zombies/_zm_weapons::weapon_give( "ak74u_zm", 0 );
	self give_start_weapon( 0 );
	self giveweapon( "knife_zm" );
	if ( self hasweapon( self get_player_lethal_grenade() ) )
	{
		self getweaponammoclip( self get_player_lethal_grenade() );
	}
	else
	{
		self giveweapon( self get_player_lethal_grenade() );
	}
	self setweaponammoclip( self get_player_lethal_grenade(), 2 );
	a_current_perks = self getperks();
	_a1345 = a_current_perks;
	_k1345 = getFirstArrayKey( _a1345 );
	while ( isDefined( _k1345 ) )
	{
		perk = _a1345[ _k1345 ];
		self notify( perk + "_stop" );
		_k1345 = getNextArrayKey( _a1345, _k1345 );
	}
	self.dontspeak = undefined;
}

minigame_blockers_disable()
{
	a_clip_brushes_full = get_minigame_clip_brushes();
	_a1366 = a_clip_brushes_full;
	_k1366 = getFirstArrayKey( _a1366 );
	while ( isDefined( _k1366 ) )
	{
		clip_ai = _a1366[ _k1366 ];
		clip_ai notsolid();
		clip_ai connectpaths();
		_k1366 = getNextArrayKey( _a1366, _k1366 );
	}
	a_models = get_minigame_blocker_models();
	_a1383 = a_models;
	_k1383 = getFirstArrayKey( _a1383 );
	while ( isDefined( _k1383 ) )
	{
		model = _a1383[ _k1383 ];
		model thread blocker_model_remove();
		_k1383 = getNextArrayKey( _a1383, _k1383 );
	}
	toggle_doors_along_richtofen_street( 0 );
	toggle_door_triggers( 1 );
	a_sloth_barriers = get_minigame_sloth_barriers();
	_a1396 = a_sloth_barriers;
	_k1396 = getFirstArrayKey( _a1396 );
	while ( isDefined( _k1396 ) )
	{
		barrier = _a1396[ _k1396 ];
		while ( isDefined( barrier.target ) )
		{
			a_pieces = getentarray( barrier.target, "targetname" );
			_a1401 = a_pieces;
			_k1401 = getFirstArrayKey( _a1401 );
			while ( isDefined( _k1401 ) )
			{
				piece = _a1401[ _k1401 ];
				if ( isDefined( piece.is_hidden ) && !piece.is_hidden )
				{
					piece maps/mp/zombies/_zm_ai_sloth::hide_sloth_barrier();
				}
				_k1401 = getNextArrayKey( _a1401, _k1401 );
			}
		}
		if ( isDefined( barrier.is_hidden ) && !barrier.is_hidden )
		{
			barrier maps/mp/zombies/_zm_ai_sloth::hide_sloth_barrier();
		}
		_k1396 = getNextArrayKey( _a1396, _k1396 );
	}
}

minigame_blockers_enable()
{
	a_clip_brushes_full = get_minigame_clip_brushes();
	_a1429 = a_clip_brushes_full;
	_k1429 = getFirstArrayKey( _a1429 );
	while ( isDefined( _k1429 ) )
	{
		clip_ai = _a1429[ _k1429 ];
		clip_ai solid();
		clip_ai disconnectpaths();
		_k1429 = getNextArrayKey( _a1429, _k1429 );
	}
	a_structs = get_minigame_blocker_structs();
	_a1445 = a_structs;
	_k1445 = getFirstArrayKey( _a1445 );
	while ( isDefined( _k1445 ) )
	{
		struct = _a1445[ _k1445 ];
		struct thread blocker_model_promote();
		_k1445 = getNextArrayKey( _a1445, _k1445 );
	}
	toggle_doors_along_richtofen_street( 1 );
	toggle_door_triggers( 0 );
	a_sloth_barriers = get_minigame_sloth_barriers();
	_a1458 = a_sloth_barriers;
	_k1458 = getFirstArrayKey( _a1458 );
	while ( isDefined( _k1458 ) )
	{
		barrier = _a1458[ _k1458 ];
		while ( isDefined( barrier.target ) )
		{
			a_pieces = getentarray( barrier.target, "targetname" );
			_a1463 = a_pieces;
			_k1463 = getFirstArrayKey( _a1463 );
			while ( isDefined( _k1463 ) )
			{
				piece = _a1463[ _k1463 ];
				if ( isDefined( piece.is_hidden ) && piece.is_hidden )
				{
					piece maps/mp/zombies/_zm_ai_sloth::unhide_sloth_barrier();
				}
				_k1463 = getNextArrayKey( _a1463, _k1463 );
			}
		}
		if ( isDefined( barrier.is_hidden ) && barrier.is_hidden )
		{
			barrier maps/mp/zombies/_zm_ai_sloth::unhide_sloth_barrier();
		}
		_k1458 = getNextArrayKey( _a1458, _k1458 );
	}
}

get_minigame_sloth_barriers()
{
	a_barriers_filtered = [];
	while ( flag_exists( "sq_minigame_active" ) && flag( "sq_minigame_active" ) )
	{
		a_sloth_barriers = getentarray( "sloth_barricade", "targetname" );
		if ( flag( "richtofen_minigame_active" ) || flag( "richtofen_game_complete" ) )
		{
			a_blocked_barrier_list = array( "jail" );
		}
		else
		{
			a_blocked_barrier_list = [];
		}
		i = 0;
		while ( i < a_sloth_barriers.size )
		{
			if ( isDefined( a_sloth_barriers[ i ].script_location ) && isinarray( a_blocked_barrier_list, a_sloth_barriers[ i ].script_location ) )
			{
				a_barriers_filtered[ a_barriers_filtered.size ] = a_sloth_barriers[ i ];
			}
			i++;
		}
	}
	return a_barriers_filtered;
}

get_minigame_blocker_structs()
{
	if ( flag_exists( "sq_minigame_active" ) && flag( "sq_minigame_active" ) )
	{
		if ( flag( "richtofen_minigame_active" ) || flag( "richtofen_game_complete" ) )
		{
			a_structs = getstructarray( "minigame_richtofen_blocker", "targetname" );
		}
		else
		{
			a_structs = getstructarray( "minigame_maxis_blocker", "script_noteworthy" );
		}
	}
	else
	{
		a_structs = getstructarray( "minigame_richtofen_blocker", "targetname" );
		a_structs = arraycombine( a_structs, getstructarray( "minigame_maxis_blocker", "script_noteworthy" ), 0, 0 );
	}
	return a_structs;
}

get_minigame_blocker_models()
{
	if ( flag_exists( "sq_minigame_active" ) && flag( "sq_minigame_active" ) )
	{
		if ( flag( "richtofen_minigame_active" ) || flag( "richtofen_game_complete" ) )
		{
			a_models = getentarray( "minigame_richtofen_blocker", "targetname" );
		}
		else
		{
			a_models = getentarray( "minigame_maxis_blocker", "script_noteworthy" );
		}
	}
	else
	{
		a_models = getentarray( "minigame_richtofen_blocker", "targetname" );
		a_models = arraycombine( a_models, getentarray( "minigame_maxis_blocker", "script_noteworthy" ), 0, 0 );
	}
	return a_models;
}

get_minigame_clip_brushes( str_name_append )
{
	if ( flag_exists( "sq_minigame_active" ) && flag( "sq_minigame_active" ) )
	{
		if ( flag( "richtofen_minigame_active" ) || flag( "richtofen_game_complete" ) )
		{
			str_name = "minigame_richtofen_clip";
			str_key = "targetname";
		}
		else
		{
			str_name = "minigame_maxis_clip";
			str_key = "script_noteworthy";
		}
		a_clip = getentarray( _append_name( str_name, str_name_append ), str_key );
	}
	else
	{
		a_clip = getentarray( _append_name( "minigame_richtofen_clip", str_name_append ), "targetname" );
		a_clip = arraycombine( a_clip, getentarray( _append_name( "minigame_maxis_clip", str_name_append ), "script_noteworthy" ), 0, 0 );
	}
	return a_clip;
}

_append_name( str_name, str_name_append )
{
	if ( isDefined( str_name_append ) )
	{
		str_name = ( str_name + "_" ) + str_name_append;
	}
	return str_name;
}

blocker_model_promote()
{
/#
	assert( isDefined( self.model ), "model not set for minigame blocker at " + self.origin );
#/
	m_blocker = spawn( "script_model", self.origin + vectorScale( ( 0, 0, -1 ), 100 ) );
	if ( !isDefined( self.angles ) )
	{
		self.angles = ( 0, 0, -1 );
	}
	m_blocker.angles = self.angles;
	m_blocker setmodel( self.model );
	m_blocker.targetname = self.targetname;
	m_blocker.script_noteworthy = self.script_noteworthy;
	m_blocker movez( 100, 5, 0,5, 0,5 );
	earthquake( 0,3, 5, self.origin + vectorScale( ( 0, 0, -1 ), 100 ), 128 );
}

blocker_model_remove()
{
	earthquake( 0,3, 5, self.origin + vectorScale( ( 0, 0, -1 ), 100 ), 128 );
	self movez( -100, 5, 0,5, 0,5 );
	self waittill( "movedone" );
	if ( isDefined( self ) )
	{
		self delete();
	}
}

toggle_doors_along_richtofen_street( b_should_close )
{
	if ( !isDefined( b_should_close ) )
	{
		b_should_close = 1;
	}
	a_door_names = array( "general_store_door1" );
	a_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < a_door_names.size )
	{
		j = 0;
		while ( j < a_doors.size )
		{
			if ( isDefined( a_doors[ j ].script_flag ) && a_doors[ j ].script_flag == a_door_names[ i ] )
			{
				if ( b_should_close )
				{
					a_doors[ j ] thread close_open_door();
					j++;
					continue;
				}
				else
				{
					a_doors[ j ] thread open_closed_door();
				}
			}
			j++;
		}
		i++;
	}
}

close_open_door()
{
	if ( isDefined( self._door_open ) || self._door_open && isDefined( self.has_been_opened ) && self.has_been_opened )
	{
		if ( isDefined( self.is_moving ) && self.is_moving )
		{
			self waittill_either( "movedone", "rotatedone" );
		}
		i = 0;
		while ( i < self.doors.size )
		{
			if ( isDefined( self.doors[ i ].og_angles ) )
			{
				self.doors[ i ].saved_angles = self.doors[ i ].angles;
				if ( isDefined( self.doors[ i ].script_string ) && self.doors[ i ].script_string == "rotate" )
				{
					self.doors[ i ] rotateto( self.doors[ i ].og_angles, 0,05, 0, 0 );
				}
				self.doors[ i ] solid();
				self.doors[ i ] disconnectpaths();
				self.doors[ i ].closed_by_minigame = 1;
			}
			i++;
		}
		self._door_open = 0;
		self.has_been_opened = 0;
		self.closed_by_minigame = 1;
	}
}

open_closed_door( bignoreminigameflag )
{
	if ( !isDefined( bignoreminigameflag ) )
	{
		bignoreminigameflag = 0;
	}
	if ( bignoreminigameflag || isDefined( self.closed_by_minigame ) && self.closed_by_minigame )
	{
		if ( isDefined( self.is_moving ) && self.is_moving )
		{
			self waittill_either( "movedone", "rotatedone" );
		}
		i = 0;
		while ( i < self.doors.size )
		{
			if ( bignoreminigameflag || isDefined( self.doors[ i ].closed_by_minigame ) && self.doors[ i ].closed_by_minigame )
			{
				if ( isDefined( self.doors[ i ].script_string ) && self.doors[ i ].script_string == "rotate" )
				{
					self.doors[ i ] rotateto( self.doors[ i ].script_angles, 1, 0, 0 );
				}
				self.doors[ i ] connectpaths();
				self.doors[ i ] notsolid();
				self.doors[ i ].closed_by_minigame = undefined;
				self.doors[ i ].saved_angles = undefined;
			}
			i++;
		}
		self.closed_by_minigame = undefined;
		self._door_open = 1;
		self.has_been_opened = 1;
	}
}

toggle_door_triggers( b_allow_use )
{
	if ( !isDefined( b_allow_use ) )
	{
		b_allow_use = 1;
	}
	a_triggers = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < a_triggers.size )
	{
		if ( b_allow_use )
		{
			if ( isDefined( a_triggers[ i ].minigame_disabled ) && a_triggers[ i ].minigame_disabled )
			{
				a_triggers[ i ] trigger_on();
				a_triggers[ i ].minigame_disabled = undefined;
			}
			i++;
			continue;
		}
		else
		{
			a_triggers[ i ] trigger_off();
			a_triggers[ i ].minigame_disabled = 1;
		}
		i++;
	}
}

minigame_blockers_precache()
{
	a_structs = get_minigame_blocker_structs();
	_a1743 = a_structs;
	_k1743 = getFirstArrayKey( _a1743 );
	while ( isDefined( _k1743 ) )
	{
		struct = _a1743[ _k1743 ];
/#
		assert( isDefined( struct.model ), "blocker struct is missing model at " + struct.origin );
#/
		precachemodel( struct.model );
		_k1743 = getNextArrayKey( _a1743, _k1743 );
	}
}

buried_set_start_area_lighting()
{
	if ( isDefined( self.underground_lighting ) )
	{
		self setclientfieldtoplayer( "clientfield_underground_lighting", 0 );
	}
	self.underground_lighting = undefined;
}

squashed_death_init( kill_if_falling )
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isDefined( who.insta_killed ) && !who.insta_killed )
		{
			if ( isplayer( who ) )
			{
				who thread insta_kill_player( 1, kill_if_falling );
				break;
			}
			else
			{
				if ( isai( who ) )
				{
					who dodamage( who.health + 100, who.origin );
					who.insta_killed = 1;
					if ( isDefined( who.has_been_damaged_by_player ) && !who.has_been_damaged_by_player )
					{
						level.zombie_total++;
					}
				}
			}
		}
	}
}

classic_player_damage_callback( e_inflictor, e_attacker, n_damage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name )
{
	if ( isDefined( self.is_in_fountain_transport_trigger ) && self.is_in_fountain_transport_trigger && str_means_of_death == "MOD_FALLING" )
	{
		return 0;
	}
	return n_damage;
}

insta_kill_player( perks_can_respawn_player, kill_if_falling )
{
	self endon( "disconnect" );
	if ( isDefined( self.is_in_fountain_transport_trigger ) && self.is_in_fountain_transport_trigger )
	{
		return;
	}
	if ( isDefined( perks_can_respawn_player ) && perks_can_respawn_player == 0 )
	{
		if ( self hasperk( "specialty_quickrevive" ) )
		{
			self unsetperk( "specialty_quickrevive" );
		}
		if ( self hasperk( "specialty_finalstand" ) )
		{
			self unsetperk( "specialty_finalstand" );
		}
	}
	self maps/mp/zombies/_zm_buildables::player_return_piece_to_original_spawn();
	if ( isDefined( self.insta_killed ) && self.insta_killed )
	{
		return;
	}
	if ( isDefined( self.ignore_insta_kill ) )
	{
		self.disable_chugabud_corpse = 1;
		return;
	}
	if ( self hasperk( "specialty_finalstand" ) )
	{
		self.ignore_insta_kill = 1;
		self.disable_chugabud_corpse = 1;
		self dodamage( self.health + 1000, ( 0, 0, -1 ) );
		return;
	}
	if ( is_player_killable( self ) )
	{
		self.insta_killed = 1;
		in_last_stand = 0;
		self notify( "chugabud_effects_cleanup" );
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			in_last_stand = 1;
		}
		if ( getnumconnectedplayers() == 1 )
		{
			if ( isDefined( self.lives ) && self.lives > 0 )
			{
				self.waiting_to_revive = 1;
				found_node = get_insta_kill_spawn_point_from_nodes( self.origin, 400, 2000, 1000, 1 );
				if ( isDefined( found_node ) && found_node )
				{
					v_point = level.chugabud_spawn_struct.origin;
					v_angles = self.angles;
				}
				else
				{
					spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
					v_point = spawn_points[ 0 ].origin;
					v_angles = spawn_points[ 0 ].angles;
				}
				if ( in_last_stand == 0 )
				{
					self dodamage( self.health + 1000, ( 0, 0, -1 ) );
				}
				wait 0,5;
				self freezecontrols( 1 );
				wait 0,25;
				self setorigin( v_point + vectorScale( ( 0, 0, -1 ), 20 ) );
				self.angles = v_angles;
				if ( in_last_stand )
				{
					flag_set( "instant_revive" );
					self.stopflashingbadlytime = getTime() + 1000;
					wait_network_frame();
					flag_clear( "instant_revive" );
				}
				else
				{
					self thread maps/mp/zombies/_zm_laststand::auto_revive( self );
					self.waiting_to_revive = 0;
					self.solo_respawn = 0;
					self.lives = 0;
				}
				self freezecontrols( 0 );
				self.insta_killed = 0;
			}
			else
			{
				self dodamage( self.health + 1000, ( 0, 0, -1 ) );
			}
		}
		else
		{
			self dodamage( self.health + 1000, ( 0, 0, -1 ) );
			wait_network_frame();
			self.bleedout_time = 0;
		}
		self.insta_killed = 0;
	}
}

get_insta_kill_spawn_point_from_nodes( v_origin, min_radius, max_radius, max_height, ignore_targetted_nodes )
{
	if ( !isDefined( level.chugabud_spawn_struct ) )
	{
		level.chugabud_spawn_struct = spawnstruct();
	}
	found_node = undefined;
	a_nodes = getnodesinradiussorted( v_origin, max_radius, min_radius, max_height, "pathnodes" );
	while ( isDefined( a_nodes ) && a_nodes.size > 0 )
	{
		a_player_volumes = getentarray( "player_volume", "script_noteworthy" );
		index = a_nodes.size - 1;
		i = index;
		while ( i >= 0 )
		{
			n_node = a_nodes[ i ];
			if ( ignore_targetted_nodes == 1 )
			{
				if ( isDefined( n_node.target ) )
				{
					i--;
					continue;
				}
			}
			else
			{
				if ( !positionwouldtelefrag( n_node.origin ) )
				{
					if ( maps/mp/zombies/_zm_utility::check_point_in_enabled_zone( n_node.origin, 1, a_player_volumes ) )
					{
						v_start = ( n_node.origin[ 0 ], n_node.origin[ 1 ], n_node.origin[ 2 ] + 30 );
						v_end = ( n_node.origin[ 0 ], n_node.origin[ 1 ], n_node.origin[ 2 ] - 30 );
						trace = bullettrace( v_start, v_end, 0, undefined );
						if ( trace[ "fraction" ] < 1 )
						{
							override_abort = 0;
							if ( isDefined( level._chugabud_reject_node_override_func ) )
							{
								override_abort = [[ level._chugabud_reject_node_override_func ]]( v_origin, n_node );
							}
							if ( !override_abort )
							{
								found_node = n_node;
								break;
							}
						}
					}
				}
			}
			else
			{
				i--;

			}
		}
	}
	if ( isDefined( found_node ) )
	{
		level.chugabud_spawn_struct.origin = found_node.origin;
		v_dir = vectornormalize( v_origin - level.chugabud_spawn_struct.origin );
		level.chugabud_spawn_struct.angles = vectorToAngle( v_dir );
		return 1;
	}
	return 0;
}

is_player_killable( player, checkignoremeflag )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( isDefined( self.intermission ) && self.intermission )
	{
		return 0;
	}
	if ( isDefined( checkignoremeflag ) && player.ignoreme )
	{
		return 0;
	}
	return 1;
}

buried_set_underground_lighting()
{
	e_info_volume = getent( "flashlight_found_info_volume", "targetname" );
	while ( 1 )
	{
		a_players = getplayers();
		while ( isDefined( a_players ) )
		{
			i = 0;
			while ( i < a_players.size )
			{
				player = a_players[ i ];
				if ( !isDefined( player.underground_lighting ) )
				{
					if ( player istouching( e_info_volume ) )
					{
						player setclientfieldtoplayer( "clientfield_underground_lighting", 1 );
						player.underground_lighting = 1;
					}
				}
				i++;
			}
		}
		wait 0,1;
	}
}

lsat_trigger_tweak()
{
	flag_wait_any( "start_zombie_round_logic", "start_encounters_match_logic" );
	wait 0,25;
	candidate_list = [];
	_a2138 = level.zones;
	_k2138 = getFirstArrayKey( _a2138 );
	while ( isDefined( _k2138 ) )
	{
		zone = _a2138[ _k2138 ];
		if ( isDefined( zone.unitrigger_stubs ) )
		{
			candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
		}
		_k2138 = getNextArrayKey( _a2138, _k2138 );
	}
	_a2147 = candidate_list;
	_k2147 = getFirstArrayKey( _a2147 );
	while ( isDefined( _k2147 ) )
	{
		stub = _a2147[ _k2147 ];
		if ( isDefined( stub.weapon_upgrade ) && stub.weapon_upgrade == "lsat_zm" )
		{
			stub thread hide_wallbuy();
		}
		_k2147 = getNextArrayKey( _a2147, _k2147 );
	}
}

hide_wallbuy()
{
	level waittill( "lsat_purchased" );
	if ( isDefined( level.catwalk_collapsed ) && level.catwalk_collapsed )
	{
		return;
	}
	maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self );
	wait 5;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self, ::weapon_spawn_think );
}

sloth_crawler_pickup_vulture_fx_correction_func()
{
	if ( isDefined( self.is_stink_zombie ) && self.is_stink_zombie && isDefined( self.stink_ent ) )
	{
		self maps/mp/zombies/_zm_perk_vulture::vulture_clientfield_actor_clear( "vulture_stink_trail_fx" );
		e_temp = self.stink_ent;
		e_temp.origin = self.origin + vectorScale( ( 0, 0, -1 ), 10000 );
		wait_network_frame();
		e_temp maps/mp/zombies/_zm_perk_vulture::vulture_clientfield_scriptmover_set( "vulture_stink_fx" );
		wait_network_frame();
		e_temp.origin = self gettagorigin( "J_SpineLower" );
		e_temp linkto( self, "J_SpineLower" );
		while ( isalive( self ) )
		{
			wait_network_frame();
		}
		e_temp unlink();
		e_temp maps/mp/zombies/_zm_perk_vulture::vulture_clientfield_scriptmover_clear( "vulture_stink_fx" );
	}
}

sloth_box_move_show_vulture_fx( b_show_fx )
{
	if ( isDefined( level.chests ) && level.chests.size > 0 && isDefined( level.chest_index ) )
	{
		level.chests[ level.chest_index ].zbarrier maps/mp/zombies/_zm_perk_vulture::vulture_perk_shows_mystery_box( b_show_fx );
	}
}
