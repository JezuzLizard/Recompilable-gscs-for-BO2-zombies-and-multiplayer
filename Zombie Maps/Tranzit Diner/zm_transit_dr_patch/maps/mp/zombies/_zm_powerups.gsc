#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	precacheshader( "specialty_doublepoints_zombies" );
	precacheshader( "specialty_instakill_zombies" );
	precacheshader( "specialty_firesale_zombies" );
	precacheshader( "zom_icon_bonfire" );
	precacheshader( "zom_icon_minigun" );
	precacheshader( "black" );
	set_zombie_var( "zombie_insta_kill", 0, undefined, undefined, 1 );
	set_zombie_var( "zombie_point_scalar", 1, undefined, undefined, 1 );
	set_zombie_var( "zombie_drop_item", 0 );
	set_zombie_var( "zombie_timer_offset", 350 );
	set_zombie_var( "zombie_timer_offset_interval", 30 );
	set_zombie_var( "zombie_powerup_fire_sale_on", 0 );
	set_zombie_var( "zombie_powerup_fire_sale_time", 30 );
	set_zombie_var( "zombie_powerup_bonfire_sale_on", 0 );
	set_zombie_var( "zombie_powerup_bonfire_sale_time", 30 );
	set_zombie_var( "zombie_powerup_insta_kill_on", 0, undefined, undefined, 1 );
	set_zombie_var( "zombie_powerup_insta_kill_time", 30, undefined, undefined, 1 );
	set_zombie_var( "zombie_powerup_point_doubler_on", 0, undefined, undefined, 1 );
	set_zombie_var( "zombie_powerup_point_doubler_time", 30, undefined, undefined, 1 );
	set_zombie_var( "zombie_powerup_drop_increment", 2000 );
	set_zombie_var( "zombie_powerup_drop_max_per_round", 4 );
	onplayerconnect_callback( ::init_player_zombie_vars );
	level._effect[ "powerup_on" ] = loadfx( "misc/fx_zombie_powerup_on" );
	level._effect[ "powerup_off" ] = loadfx( "misc/fx_zombie_powerup_off" );
	level._effect[ "powerup_grabbed" ] = loadfx( "misc/fx_zombie_powerup_grab" );
	level._effect[ "powerup_grabbed_wave" ] = loadfx( "misc/fx_zombie_powerup_wave" );
	if ( isDefined( level.using_zombie_powerups ) && level.using_zombie_powerups )
	{
		level._effect[ "powerup_on_red" ] = loadfx( "misc/fx_zombie_powerup_on_red" );
		level._effect[ "powerup_grabbed_red" ] = loadfx( "misc/fx_zombie_powerup_red_grab" );
		level._effect[ "powerup_grabbed_wave_red" ] = loadfx( "misc/fx_zombie_powerup_red_wave" );
	}
	level._effect[ "powerup_on_solo" ] = loadfx( "misc/fx_zombie_powerup_solo_on" );
	level._effect[ "powerup_grabbed_solo" ] = loadfx( "misc/fx_zombie_powerup_solo_grab" );
	level._effect[ "powerup_grabbed_wave_solo" ] = loadfx( "misc/fx_zombie_powerup_solo_wave" );
	level._effect[ "powerup_on_caution" ] = loadfx( "misc/fx_zombie_powerup_caution_on" );
	level._effect[ "powerup_grabbed_caution" ] = loadfx( "misc/fx_zombie_powerup_caution_grab" );
	level._effect[ "powerup_grabbed_wave_caution" ] = loadfx( "misc/fx_zombie_powerup_caution_wave" );
	init_powerups();
	if ( !level.enable_magic )
	{
		return;
	}
	thread watch_for_drop();
	thread setup_firesale_audio();
	thread setup_bonfiresale_audio();
	level.use_new_carpenter_func = ::start_carpenter_new;
	level.board_repair_distance_squared = 562500;
}

init_powerups()
{
	flag_init( "zombie_drop_powerups" );
	if ( isDefined( level.enable_magic ) && level.enable_magic )
	{
		flag_set( "zombie_drop_powerups" );
	}
	if ( !isDefined( level.active_powerups ) )
	{
		level.active_powerups = [];
	}
	if ( !isDefined( level.zombie_powerup_array ) )
	{
		level.zombie_powerup_array = [];
	}
	if ( !isDefined( level.zombie_special_drop_array ) )
	{
		level.zombie_special_drop_array = [];
	}
	add_zombie_powerup( "nuke", "zombie_bomb", &"ZOMBIE_POWERUP_NUKE", ::func_should_always_drop, 0, 0, 0, "misc/fx_zombie_mini_nuke_hotness" );
	add_zombie_powerup( "insta_kill", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_always_drop, 0, 0, 0, undefined, "powerup_instant_kill", "zombie_powerup_insta_kill_time", "zombie_powerup_insta_kill_on" );
	add_zombie_powerup( "full_ammo", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 0, 0, 0 );
	add_zombie_powerup( "double_points", "zombie_x2_icon", &"ZOMBIE_POWERUP_DOUBLE_POINTS", ::func_should_always_drop, 0, 0, 0, undefined, "powerup_double_points", "zombie_powerup_point_doubler_time", "zombie_powerup_point_doubler_on" );
	add_zombie_powerup( "carpenter", "zombie_carpenter", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_drop_carpenter, 0, 0, 0 );
	add_zombie_powerup( "fire_sale", "zombie_firesale", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_drop_fire_sale, 0, 0, 0, undefined, "powerup_fire_sale", "zombie_powerup_fire_sale_time", "zombie_powerup_fire_sale_on" );
	add_zombie_powerup( "bonfire_sale", "zombie_pickup_bonfire", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_bon_fire", "zombie_powerup_bonfire_sale_time", "zombie_powerup_bonfire_sale_on" );
	add_zombie_powerup( "minigun", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_drop_minigun, 1, 0, 0, undefined, "powerup_mini_gun", "zombie_powerup_minigun_time", "zombie_powerup_minigun_on" );
	add_zombie_powerup( "free_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_FREE_PERK", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "tesla", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_tesla", "zombie_powerup_tesla_time", "zombie_powerup_tesla_on" );
	add_zombie_powerup( "random_weapon", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "bonus_points_player", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "bonus_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "lose_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_LOSE_POINTS", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "lose_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "empty_clip", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "insta_kill_ug", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_instant_kill_ug", "zombie_powerup_insta_kill_ug_time", "zombie_powerup_insta_kill_ug_on", 5000 );
	if ( isDefined( level.level_specific_init_powerups ) )
	{
		[[ level.level_specific_init_powerups ]]();
	}
	randomize_powerups();
	level.zombie_powerup_index = 0;
	randomize_powerups();
	level.rare_powerups_active = 0;
	level.firesale_vox_firstime = 0;
	level thread powerup_hud_monitor();
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "random_powerup", ::quantum_bomb_random_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
		[[ level.quantum_bomb_register_result_func ]]( "random_zombie_grab_powerup", ::quantum_bomb_random_zombie_grab_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
		[[ level.quantum_bomb_register_result_func ]]( "random_weapon_powerup", ::quantum_bomb_random_weapon_powerup_result, 60, level.quantum_bomb_in_playable_area_validation_func );
		[[ level.quantum_bomb_register_result_func ]]( "random_bonus_or_lose_points_powerup", ::quantum_bomb_random_bonus_or_lose_points_powerup_result, 25, level.quantum_bomb_in_playable_area_validation_func );
	}
	registerclientfield( "scriptmover", "powerup_fx", 1000, 3, "int" );
}

init_player_zombie_vars()
{
	self.zombie_vars[ "zombie_powerup_minigun_on" ] = 0;
	self.zombie_vars[ "zombie_powerup_minigun_time" ] = 0;
	self.zombie_vars[ "zombie_powerup_tesla_on" ] = 0;
	self.zombie_vars[ "zombie_powerup_tesla_time" ] = 0;
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_on" ] = 0;
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] = 18;
}

powerup_hud_monitor()
{
	flag_wait( "start_zombie_round_logic" );
	if ( isDefined( level.current_game_module ) && level.current_game_module == 2 )
	{
		return;
	}
	flashing_timers = [];
	flashing_values = [];
	flashing_timer = 10;
	flashing_delta_time = 0;
	flashing_is_on = 0;
	flashing_value = 3;
	flashing_min_timer = 0,15;
	while ( flashing_timer >= flashing_min_timer )
	{
		if ( flashing_timer < 5 )
		{
			flashing_delta_time = 0,1;
		}
		else
		{
			flashing_delta_time = 0,2;
		}
		if ( flashing_is_on )
		{
			flashing_timer = flashing_timer - flashing_delta_time - 0,05;
			flashing_value = 2;
		}
		else
		{
			flashing_timer -= flashing_delta_time;
			flashing_value = 3;
		}
		flashing_timers[ flashing_timers.size ] = flashing_timer;
		flashing_values[ flashing_values.size ] = flashing_value;
		flashing_is_on = !flashing_is_on;
	}
	client_fields = [];
	powerup_keys = getarraykeys( level.zombie_powerups );
	powerup_key_index = 0;
	while ( powerup_key_index < powerup_keys.size )
	{
		if ( isDefined( level.zombie_powerups[ powerup_keys[ powerup_key_index ] ].client_field_name ) )
		{
			powerup_name = powerup_keys[ powerup_key_index ];
			client_fields[ powerup_name ] = spawnstruct();
			client_fields[ powerup_name ].client_field_name = level.zombie_powerups[ powerup_name ].client_field_name;
			client_fields[ powerup_name ].solo = level.zombie_powerups[ powerup_name ].solo;
			client_fields[ powerup_name ].time_name = level.zombie_powerups[ powerup_name ].time_name;
			client_fields[ powerup_name ].on_name = level.zombie_powerups[ powerup_name ].on_name;
		}
		powerup_key_index++;
	}
	client_field_keys = getarraykeys( client_fields );
	while ( 1 )
	{
		wait 0,05;
		waittillframeend;
		players = get_players();
		playerindex = 0;
		while ( playerindex < players.size )
		{
			client_field_key_index = 0;
			while ( client_field_key_index < client_field_keys.size )
			{
				player = players[ playerindex ];
/#
				if ( isDefined( player.pers[ "isBot" ] ) && player.pers[ "isBot" ] )
				{
					client_field_key_index++;
					continue;
#/
				}
				else
				{
					if ( isDefined( level.powerup_player_valid ) )
					{
						if ( !( [[ level.powerup_player_valid ]]( player ) ) )
						{
							client_field_key_index++;
							continue;
						}
					}
					else client_field_name = client_fields[ client_field_keys[ client_field_key_index ] ].client_field_name;
					time_name = client_fields[ client_field_keys[ client_field_key_index ] ].time_name;
					on_name = client_fields[ client_field_keys[ client_field_key_index ] ].on_name;
					powerup_timer = undefined;
					powerup_on = undefined;
					if ( client_fields[ client_field_keys[ client_field_key_index ] ].solo )
					{
						if ( isDefined( player._show_solo_hud ) && player._show_solo_hud == 1 )
						{
							powerup_timer = player.zombie_vars[ time_name ];
							powerup_on = player.zombie_vars[ on_name ];
						}
					}
					else if ( isDefined( level.zombie_vars[ player.team ][ time_name ] ) )
					{
						powerup_timer = level.zombie_vars[ player.team ][ time_name ];
						powerup_on = level.zombie_vars[ player.team ][ on_name ];
					}
					else
					{
						if ( isDefined( level.zombie_vars[ time_name ] ) )
						{
							powerup_timer = level.zombie_vars[ time_name ];
							powerup_on = level.zombie_vars[ on_name ];
						}
					}
					if ( isDefined( powerup_timer ) && isDefined( powerup_on ) )
					{
						player set_clientfield_powerups( client_field_name, powerup_timer, powerup_on, flashing_timers, flashing_values );
						client_field_key_index++;
						continue;
					}
					else
					{
						player setclientfieldtoplayer( client_field_name, 0 );
					}
				}
				client_field_key_index++;
			}
			playerindex++;
		}
	}
}

set_clientfield_powerups( clientfield_name, powerup_timer, powerup_on, flashing_timers, flashing_values )
{
	if ( powerup_on )
	{
		if ( powerup_timer < 10 )
		{
			flashing_value = 3;
			i = flashing_timers.size - 1;
			while ( i > 0 )
			{
				if ( powerup_timer < flashing_timers[ i ] )
				{
					flashing_value = flashing_values[ i ];
					break;
				}
				else
				{
					i--;

				}
			}
			self setclientfieldtoplayer( clientfield_name, flashing_value );
		}
		else
		{
			self setclientfieldtoplayer( clientfield_name, 1 );
		}
	}
	else
	{
		self setclientfieldtoplayer( clientfield_name, 0 );
	}
}

randomize_powerups()
{
	level.zombie_powerup_array = array_randomize( level.zombie_powerup_array );
}

get_next_powerup()
{
	powerup = level.zombie_powerup_array[ level.zombie_powerup_index ];
	level.zombie_powerup_index++;
	if ( level.zombie_powerup_index >= level.zombie_powerup_array.size )
	{
		level.zombie_powerup_index = 0;
		randomize_powerups();
	}
	return powerup;
}

get_valid_powerup()
{
/#
	if ( isDefined( level.zombie_devgui_power ) && level.zombie_devgui_power == 1 )
	{
		return level.zombie_powerup_array[ level.zombie_powerup_index ];
#/
	}
	if ( isDefined( level.zombie_powerup_boss ) )
	{
		i = level.zombie_powerup_boss;
		level.zombie_powerup_boss = undefined;
		return level.zombie_powerup_array[ i ];
	}
	if ( isDefined( level.zombie_powerup_ape ) )
	{
		powerup = level.zombie_powerup_ape;
		level.zombie_powerup_ape = undefined;
		return powerup;
	}
	powerup = get_next_powerup();
	while ( 1 )
	{
		while ( !( [[ level.zombie_powerups[ powerup ].func_should_drop_with_regular_powerups ]]() ) )
		{
			powerup = get_next_powerup();
		}
		return powerup;
	}
}

minigun_no_drop()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].zombie_vars[ "zombie_powerup_minigun_on" ] == 1 )
		{
			return 1;
		}
		i++;
	}
	if ( !flag( "power_on" ) )
	{
		if ( flag( "solo_game" ) )
		{
			if ( level.solo_lives_given == 0 )
			{
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	return 0;
}

get_num_window_destroyed()
{
	num = 0;
	i = 0;
	while ( i < level.exterior_goals.size )
	{
		if ( all_chunks_destroyed( level.exterior_goals[ i ], level.exterior_goals[ i ].barrier_chunks ) )
		{
			num += 1;
		}
		i++;
	}
	return num;
}

watch_for_drop()
{
	flag_wait( "start_zombie_round_logic" );
	flag_wait( "begin_spawning" );
	players = get_players();
	score_to_drop = ( players.size * level.zombie_vars[ "zombie_score_start_" + players.size + "p" ] ) + level.zombie_vars[ "zombie_powerup_drop_increment" ];
	while ( 1 )
	{
		flag_wait( "zombie_drop_powerups" );
		players = get_players();
		curr_total_score = 0;
		i = 0;
		while ( i < players.size )
		{
			if ( isDefined( players[ i ].score_total ) )
			{
				curr_total_score += players[ i ].score_total;
			}
			i++;
		}
		if ( curr_total_score > score_to_drop )
		{
			level.zombie_vars[ "zombie_powerup_drop_increment" ] *= 1,14;
			score_to_drop = curr_total_score + level.zombie_vars[ "zombie_powerup_drop_increment" ];
			level.zombie_vars[ "zombie_drop_item" ] = 1;
		}
		wait 0,5;
	}
}

add_zombie_powerup( powerup_name, model_name, hint, func_should_drop_with_regular_powerups, solo, caution, zombie_grabbable, fx, client_field_name, time_name, on_name, clientfield_version )
{
	if ( !isDefined( clientfield_version ) )
	{
		clientfield_version = 1;
	}
	if ( isDefined( level.zombie_include_powerups ) && !isDefined( level.zombie_include_powerups[ powerup_name ] ) )
	{
		return;
	}
	precachemodel( model_name );
	precachestring( hint );
	struct = spawnstruct();
	if ( !isDefined( level.zombie_powerups ) )
	{
		level.zombie_powerups = [];
	}
	struct.powerup_name = powerup_name;
	struct.model_name = model_name;
	struct.weapon_classname = "script_model";
	struct.hint = hint;
	struct.func_should_drop_with_regular_powerups = func_should_drop_with_regular_powerups;
	struct.solo = solo;
	struct.caution = caution;
	struct.zombie_grabbable = zombie_grabbable;
	if ( isDefined( fx ) )
	{
		struct.fx = loadfx( fx );
	}
	level.zombie_powerups[ powerup_name ] = struct;
	level.zombie_powerup_array[ level.zombie_powerup_array.size ] = powerup_name;
	add_zombie_special_drop( powerup_name );
	if ( !level.createfx_enabled )
	{
		if ( isDefined( client_field_name ) )
		{
			registerclientfield( "toplayer", client_field_name, clientfield_version, 2, "int" );
			struct.client_field_name = client_field_name;
			struct.time_name = time_name;
			struct.on_name = on_name;
		}
	}
}

add_zombie_special_drop( powerup_name )
{
	level.zombie_special_drop_array[ level.zombie_special_drop_array.size ] = powerup_name;
}

include_zombie_powerup( powerup_name )
{
	if ( !isDefined( level.zombie_include_powerups ) )
	{
		level.zombie_include_powerups = [];
	}
	level.zombie_include_powerups[ powerup_name ] = 1;
}

powerup_round_start()
{
	level.powerup_drop_count = 0;
}

powerup_drop( drop_point )
{
	if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
	{
/#
		println( "^3POWERUP DROP EXCEEDED THE MAX PER ROUND!" );
#/
		return;
	}
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}
	rand_drop = randomint( 100 );
	if ( rand_drop > 2 )
	{
		if ( !level.zombie_vars[ "zombie_drop_item" ] )
		{
			return;
		}
		debug = "score";
	}
	else
	{
		debug = "random";
	}
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	level.powerup_drop_count++;
	powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + vectorScale( ( 0, 0, 0 ), 40 ) );
	valid_drop = 0;
	i = 0;
	while ( i < playable_area.size )
	{
		if ( powerup istouching( playable_area[ i ] ) )
		{
			valid_drop = 1;
		}
		i++;
	}
	if ( valid_drop && level.rare_powerups_active )
	{
		pos = ( drop_point[ 0 ], drop_point[ 1 ], drop_point[ 2 ] + 42 );
		if ( check_for_rare_drop_override( pos ) )
		{
			level.zombie_vars[ "zombie_drop_item" ] = 0;
			valid_drop = 0;
		}
	}
	if ( !valid_drop )
	{
		level.powerup_drop_count--;

		powerup delete();
		return;
	}
	powerup powerup_setup();
	print_powerup_drop( powerup.powerup_name, debug );
	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();
	powerup thread powerup_move();
	powerup thread powerup_emp();
	level.zombie_vars[ "zombie_drop_item" ] = 0;
	level notify( "powerup_dropped" );
}

specific_powerup_drop( powerup_name, drop_spot, powerup_team, powerup_location )
{
	powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_spot + vectorScale( ( 0, 0, 0 ), 40 ) );
	level notify( "powerup_dropped" );
	if ( isDefined( powerup ) )
	{
		powerup powerup_setup( powerup_name, powerup_team, powerup_location );
		powerup thread powerup_timeout();
		powerup thread powerup_wobble();
		powerup thread powerup_grab( powerup_team );
		powerup thread powerup_move();
		powerup thread powerup_emp();
		return powerup;
	}
}

quantum_bomb_random_powerup_result( position )
{
	if ( !isDefined( level.zombie_include_powerups ) || !level.zombie_include_powerups.size )
	{
		return;
	}
	keys = getarraykeys( level.zombie_include_powerups );
	while ( keys.size )
	{
		index = randomint( keys.size );
		if ( !level.zombie_powerups[ keys[ index ] ].zombie_grabbable )
		{
			skip = 0;
			switch( keys[ index ] )
			{
				case "bonus_points_player":
				case "bonus_points_team":
				case "random_weapon":
					skip = 1;
					break;
				case "fire_sale":
				case "full_ammo":
				case "insta_kill":
				case "minigun":
					if ( randomint( 4 ) )
					{
						skip = 1;
					}
					break;
				case "bonfire_sale":
				case "free_perk":
				case "tesla":
					if ( randomint( 20 ) )
					{
						skip = 1;
					}
					break;
				default:
				}
				while ( skip )
				{
					arrayremovevalue( keys, keys[ index ] );
				}
				self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_good" );
				[[ level.quantum_bomb_play_player_effect_at_position_func ]]( position );
				level specific_powerup_drop( keys[ index ], position );
				return;
				continue;
			}
			else arrayremovevalue( keys, keys[ index ] );
		}
	}
}

quantum_bomb_random_zombie_grab_powerup_result( position )
{
	if ( !isDefined( level.zombie_include_powerups ) || !level.zombie_include_powerups.size )
	{
		return;
	}
	keys = getarraykeys( level.zombie_include_powerups );
	while ( keys.size )
	{
		index = randomint( keys.size );
		if ( level.zombie_powerups[ keys[ index ] ].zombie_grabbable )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_bad" );
			[[ level.quantum_bomb_play_player_effect_at_position_func ]]( position );
			level specific_powerup_drop( keys[ index ], position );
			return;
			continue;
		}
		else
		{
			arrayremovevalue( keys, keys[ index ] );
		}
	}
}

quantum_bomb_random_weapon_powerup_result( position )
{
	self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_good" );
	[[ level.quantum_bomb_play_player_effect_at_position_func ]]( position );
	level specific_powerup_drop( "random_weapon", position );
}

quantum_bomb_random_bonus_or_lose_points_powerup_result( position )
{
	rand = randomint( 10 );
	powerup = "bonus_points_team";
	switch( rand )
	{
		case 0:
		case 1:
			powerup = "lose_points_team";
			if ( isDefined( level.zombie_include_powerups[ powerup ] ) )
			{
				self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_bad" );
				break;
		}
		else case 2:
		case 3:
		case 4:
			powerup = "bonus_points_player";
			if ( isDefined( level.zombie_include_powerups[ powerup ] ) )
			{
				break;
		}
		else default:
			powerup = "bonus_points_team";
			break;
	}
	[[ level.quantum_bomb_play_player_effect_at_position_func ]]( position );
	level specific_powerup_drop( powerup, position );
}

special_powerup_drop( drop_point )
{
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}
	powerup = spawn( "script_model", drop_point + vectorScale( ( 0, 0, 0 ), 40 ) );
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	valid_drop = 0;
	i = 0;
	while ( i < playable_area.size )
	{
		if ( powerup istouching( playable_area[ i ] ) )
		{
			valid_drop = 1;
			break;
		}
		else
		{
			i++;
		}
	}
	if ( !valid_drop )
	{
		powerup delete();
		return;
	}
	powerup special_drop_setup();
}

cleanup_random_weapon_list()
{
	self waittill( "death" );
	arrayremovevalue( level.random_weapon_powerups, self );
}

powerup_setup( powerup_override, powerup_team, powerup_location )
{
	powerup = undefined;
	if ( !isDefined( powerup_override ) )
	{
		powerup = get_valid_powerup();
	}
	else
	{
		powerup = powerup_override;
		if ( powerup == "tesla" && tesla_powerup_active() )
		{
			powerup = "minigun";
		}
	}
	struct = level.zombie_powerups[ powerup ];
	if ( powerup == "random_weapon" )
	{
		self.weapon = maps/mp/zombies/_zm_magicbox::treasure_chest_chooseweightedrandomweapon();
/#
		weapon = getDvar( "scr_force_weapon" );
		if ( weapon != "" && isDefined( level.zombie_weapons[ weapon ] ) )
		{
			self.weapon = weapon;
			setdvar( "scr_force_weapon", "" );
#/
		}
		self.base_weapon = self.weapon;
		if ( !isDefined( level.random_weapon_powerups ) )
		{
			level.random_weapon_powerups = [];
		}
		level.random_weapon_powerups[ level.random_weapon_powerups.size ] = self;
		self thread cleanup_random_weapon_list();
		if ( isDefined( level.zombie_weapons[ self.weapon ].upgrade_name ) && !randomint( 4 ) )
		{
			self.weapon = level.zombie_weapons[ self.weapon ].upgrade_name;
		}
		self setmodel( getweaponmodel( self.weapon ) );
		self useweaponhidetags( self.weapon );
		offsetdw = vectorScale( ( 0, 0, 0 ), 3 );
		self.worldgundw = undefined;
		if ( maps/mp/zombies/_zm_magicbox::weapon_is_dual_wield( self.weapon ) )
		{
			self.worldgundw = spawn( "script_model", self.origin + offsetdw );
			self.worldgundw.angles = self.angles;
			self.worldgundw setmodel( maps/mp/zombies/_zm_magicbox::get_left_hand_weapon_model_name( self.weapon ) );
			self.worldgundw useweaponhidetags( self.weapon );
			self.worldgundw linkto( self, "tag_weapon", offsetdw, ( 0, 0, 0 ) );
		}
	}
	else
	{
		self setmodel( struct.model_name );
	}
	maps/mp/_demo::bookmark( "zm_powerup_dropped", getTime(), undefined, undefined, 1 );
	playsoundatposition( "zmb_spawn_powerup", self.origin );
	if ( isDefined( powerup_team ) )
	{
		self.powerup_team = powerup_team;
	}
	if ( isDefined( powerup_location ) )
	{
		self.powerup_location = powerup_location;
	}
	self.powerup_name = struct.powerup_name;
	self.hint = struct.hint;
	self.solo = struct.solo;
	self.caution = struct.caution;
	self.zombie_grabbable = struct.zombie_grabbable;
	self.func_should_drop_with_regular_powerups = struct.func_should_drop_with_regular_powerups;
	if ( isDefined( struct.fx ) )
	{
		self.fx = struct.fx;
	}
	self playloopsound( "zmb_spawn_powerup_loop" );
	level.active_powerups[ level.active_powerups.size ] = self;
}

special_drop_setup()
{
	powerup = undefined;
	is_powerup = 1;
	if ( level.round_number <= 10 )
	{
		powerup = get_valid_powerup();
	}
	else
	{
		powerup = level.zombie_special_drop_array[ randomint( level.zombie_special_drop_array.size ) ];
		if ( level.round_number > 15 && randomint( 100 ) < ( ( level.round_number - 15 ) * 5 ) )
		{
			powerup = "nothing";
		}
	}
	switch( powerup )
	{
		case "all_revive":
		case "bonfire_sale":
		case "bonus_points_player":
		case "bonus_points_team":
		case "carpenter":
		case "double_points":
		case "empty_clip":
		case "fire_sale":
		case "free_perk":
		case "insta_kill":
		case "lose_perk":
		case "lose_points_team":
		case "minigun":
		case "nuke":
		case "random_weapon":
		case "tesla":
			break;
		case "full_ammo":
			if ( level.round_number > 10 && randomint( 100 ) < ( ( level.round_number - 10 ) * 5 ) )
			{
				powerup = level.zombie_powerup_array[ randomint( level.zombie_powerup_array.size ) ];
			}
			break;
		case "dog":
			if ( level.round_number >= 15 )
			{
				is_powerup = 0;
				dog_spawners = getentarray( "special_dog_spawner", "targetname" );
				thread play_sound_2d( "sam_nospawn" );
			}
			else
			{
				powerup = get_valid_powerup();
			}
			break;
		default:
			if ( isDefined( level._zombiemode_special_drop_setup ) )
			{
				is_powerup = [[ level._zombiemode_special_drop_setup ]]( powerup );
			}
			else
			{
				is_powerup = 0;
				playfx( level._effect[ "lightning_dog_spawn" ], self.origin );
				playsoundatposition( "pre_spawn", self.origin );
				wait 1,5;
				playsoundatposition( "zmb_bolt", self.origin );
				earthquake( 0,5, 0,75, self.origin, 1000 );
				playrumbleonposition( "explosion_generic", self.origin );
				playsoundatposition( "spawn", self.origin );
				wait 1;
				thread play_sound_2d( "sam_nospawn" );
				self delete();
			}
	}
	if ( is_powerup )
	{
		playfx( level._effect[ "lightning_dog_spawn" ], self.origin );
		playsoundatposition( "pre_spawn", self.origin );
		wait 1,5;
		playsoundatposition( "zmb_bolt", self.origin );
		earthquake( 0,5, 0,75, self.origin, 1000 );
		playrumbleonposition( "explosion_generic", self.origin );
		playsoundatposition( "spawn", self.origin );
		self powerup_setup( powerup );
		self thread powerup_timeout();
		self thread powerup_wobble();
		self thread powerup_grab();
		self thread powerup_move();
		self thread powerup_emp();
	}
}

powerup_zombie_grab_trigger_cleanup( trigger )
{
	self waittill_any( "powerup_timedout", "powerup_grabbed", "hacked" );
	trigger delete();
}

powerup_zombie_grab( powerup_team )
{
	self endon( "powerup_timedout" );
	self endon( "powerup_grabbed" );
	self endon( "hacked" );
	zombie_grab_trigger = spawn( "trigger_radius", self.origin - vectorScale( ( 0, 0, 0 ), 40 ), 4, 32, 72 );
	zombie_grab_trigger enablelinkto();
	zombie_grab_trigger linkto( self );
	zombie_grab_trigger setteamfortrigger( level.zombie_team );
	self thread powerup_zombie_grab_trigger_cleanup( zombie_grab_trigger );
	poi_dist = 300;
	if ( isDefined( level._zombie_grabbable_poi_distance_override ) )
	{
		poi_dist = level._zombie_grabbable_poi_distance_override;
	}
	zombie_grab_trigger create_zombie_point_of_interest( poi_dist, 2, 0, 1, undefined, undefined, powerup_team );
	while ( isDefined( self ) )
	{
		zombie_grab_trigger waittill( "trigger", who );
		if ( isDefined( level._powerup_grab_check ) )
		{
			while ( !( self [[ level._powerup_grab_check ]]( who ) ) )
			{
				continue;
			}
		}
		else if ( !isDefined( who ) || !isai( who ) )
		{
			continue;
		}
		playfx( level._effect[ "powerup_grabbed_red" ], self.origin );
		playfx( level._effect[ "powerup_grabbed_wave_red" ], self.origin );
		switch( self.powerup_name )
		{
			case "lose_points_team":
				level thread lose_points_team_powerup( self );
				players = get_players();
				players[ randomintrange( 0, players.size ) ] thread powerup_vo( "lose_points" );
				break;
			case "lose_perk":
				level thread lose_perk_powerup( self );
				break;
			case "empty_clip":
				level thread empty_clip_powerup( self );
				break;
			default:
				if ( isDefined( level._zombiemode_powerup_zombie_grab ) )
				{
					level thread [[ level._zombiemode_powerup_zombie_grab ]]( self );
				}
				if ( isDefined( level._game_mode_powerup_zombie_grab ) )
				{
					level thread [[ level._game_mode_powerup_zombie_grab ]]( self, who );
				}
				else
				{
/#
					println( "Unrecognized poweup." );
#/
				}
				break;
		}
		level thread maps/mp/zombies/_zm_audio::do_announcer_playvox( "powerup", self.powerup_name );
		wait 0,1;
		playsoundatposition( "zmb_powerup_grabbed", self.origin );
		self stoploopsound();
		self powerup_delete();
		self notify( "powerup_grabbed" );
	}
}

powerup_grab( powerup_team )
{
	if ( isDefined( self ) && self.zombie_grabbable )
	{
		self thread powerup_zombie_grab( powerup_team );
		return;
	}
	self endon( "powerup_timedout" );
	self endon( "powerup_grabbed" );
	range_squared = 4096;
	while ( isDefined( self ) )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( self.powerup_name != "minigun" && self.powerup_name != "tesla" && self.powerup_name != "random_weapon" && self.powerup_name == "meat_stink" || players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ] usebuttonpressed() && players[ i ] in_revive_trigger() )
			{
				i++;
				continue;
			}
			else
			{
				if ( distancesquared( players[ i ].origin, self.origin ) < range_squared )
				{
					if ( isDefined( level._powerup_grab_check ) )
					{
						if ( !( self [[ level._powerup_grab_check ]]( players[ i ] ) ) )
						{
							i++;
							continue;
						}
					}
					else if ( isDefined( level.zombie_powerup_grab_func ) )
					{
						level thread [[ level.zombie_powerup_grab_func ]]();
						break;
				}
				else switch( self.powerup_name )
				{
					case "nuke":
						level thread nuke_powerup( self, players[ i ].team );
						players[ i ] thread powerup_vo( "nuke" );
						zombies = getaiarray( level.zombie_team );
						players[ i ].zombie_nuked = arraysort( zombies, self.origin );
						players[ i ] notify( "nuke_triggered" );
						break;
					case "full_ammo":
						level thread full_ammo_powerup( self, players[ i ] );
						players[ i ] thread powerup_vo( "full_ammo" );
						break;
					case "double_points":
						level thread double_points_powerup( self, players[ i ] );
						players[ i ] thread powerup_vo( "double_points" );
						break;
					case "insta_kill":
						level thread insta_kill_powerup( self, players[ i ] );
						players[ i ] thread powerup_vo( "insta_kill" );
						break;
					case "carpenter":
						if ( is_classic() )
						{
							players[ i ] thread persistent_carpenter_ability_check();
						}
						if ( isDefined( level.use_new_carpenter_func ) )
						{
							level thread [[ level.use_new_carpenter_func ]]( self.origin );
						}
						else level thread start_carpenter( self.origin );
						players[ i ] thread powerup_vo( "carpenter" );
						break;
					case "fire_sale":
						level thread start_fire_sale( self );
						players[ i ] thread powerup_vo( "firesale" );
						break;
					case "bonfire_sale":
						level thread start_bonfire_sale( self );
						players[ i ] thread powerup_vo( "firesale" );
						break;
					case "minigun":
						level thread minigun_weapon_powerup( players[ i ] );
						players[ i ] thread powerup_vo( "minigun" );
						break;
					case "free_perk":
						level thread free_perk_powerup( self );
						break;
					case "tesla":
						level thread tesla_weapon_powerup( players[ i ] );
						players[ i ] thread powerup_vo( "tesla" );
						break;
					case "random_weapon":
						if ( !level random_weapon_powerup( self, players[ i ] ) )
						{
							i++;
							continue;
						}
						else case "bonus_points_player":
							level thread bonus_points_player_powerup( self, players[ i ] );
							players[ i ] thread powerup_vo( "bonus_points_solo" );
							break;
						case "bonus_points_team":
							level thread bonus_points_team_powerup( self );
							players[ i ] thread powerup_vo( "bonus_points_team" );
							break;
						case "teller_withdrawl":
							level thread teller_withdrawl( self, players[ i ] );
							break;
						default:
							if ( isDefined( level._zombiemode_powerup_grab ) )
							{
								level thread [[ level._zombiemode_powerup_grab ]]( self, players[ i ] );
							}
							else /#
							println( "Unrecognized poweup." );
#/
							break;
					}
					maps/mp/_demo::bookmark( "zm_player_powerup_grabbed", getTime(), players[ i ] );
					if ( should_award_stat( self.powerup_name ) )
					{
						players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "drops" );
						players[ i ] maps/mp/zombies/_zm_stats::increment_player_stat( "drops" );
						players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( self.powerup_name + "_pickedup" );
						players[ i ] maps/mp/zombies/_zm_stats::increment_player_stat( self.powerup_name + "_pickedup" );
					}
					if ( self.solo )
					{
						playfx( level._effect[ "powerup_grabbed_solo" ], self.origin );
						playfx( level._effect[ "powerup_grabbed_wave_solo" ], self.origin );
					}
					else if ( self.caution )
					{
						playfx( level._effect[ "powerup_grabbed_caution" ], self.origin );
						playfx( level._effect[ "powerup_grabbed_wave_caution" ], self.origin );
					}
					else
					{
						playfx( level._effect[ "powerup_grabbed" ], self.origin );
						playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );
					}
					if ( isDefined( self.stolen ) && self.stolen )
					{
						level notify( "monkey_see_monkey_dont_achieved" );
					}
					if ( isDefined( self.grabbed_level_notify ) )
					{
						level notify( self.grabbed_level_notify );
					}
					self.claimed = 1;
					self.power_up_grab_player = players[ i ];
					wait 0,1;
					playsoundatposition( "zmb_powerup_grabbed", self.origin );
					self stoploopsound();
					self hide();
					if ( self.powerup_name != "fire_sale" )
					{
						if ( isDefined( self.power_up_grab_player ) )
						{
							if ( isDefined( level.powerup_intro_vox ) )
							{
								level thread [[ level.powerup_intro_vox ]]( self );
								return;
								break;
							}
							else
							{
								if ( isDefined( level.powerup_vo_available ) )
								{
									can_say_vo = [[ level.powerup_vo_available ]]();
									if ( !can_say_vo )
									{
										self powerup_delete();
										self notify( "powerup_grabbed" );
										return;
									}
								}
							}
						}
					}
					level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( self.powerup_name, self.power_up_grab_player.pers[ "team" ] );
					self powerup_delete();
					self notify( "powerup_grabbed" );
				}
			}
			i++;
		}
		wait 0,1;
	}
}

start_fire_sale( item )
{
	if ( level.zombie_vars[ "zombie_powerup_fire_sale_time" ] > 0 && is_true( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) )
	{
		level.zombie_vars[ "zombie_powerup_fire_sale_time" ] += 30;
		return;
	}
	level notify( "powerup fire sale" );
	level endon( "powerup fire sale" );
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "fire_sale" );
	level.zombie_vars[ "zombie_powerup_fire_sale_on" ] = 1;
	level thread toggle_fire_sale_on();
	level.zombie_vars[ "zombie_powerup_fire_sale_time" ] = 30;
	while ( level.zombie_vars[ "zombie_powerup_fire_sale_time" ] > 0 )
	{
		wait 0,05;
		level.zombie_vars[ "zombie_powerup_fire_sale_time" ] -= 0,05;
	}
	level.zombie_vars[ "zombie_powerup_fire_sale_on" ] = 0;
	level notify( "fire_sale_off" );
}

start_bonfire_sale( item )
{
	level notify( "powerup bonfire sale" );
	level endon( "powerup bonfire sale" );
	temp_ent = spawn( "script_origin", ( 0, 0, 0 ) );
	temp_ent playloopsound( "zmb_double_point_loop" );
	level.zombie_vars[ "zombie_powerup_bonfire_sale_on" ] = 1;
	level thread toggle_bonfire_sale_on();
	level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] = 30;
	while ( level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] > 0 )
	{
		wait 0,05;
		level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] -= 0,05;
	}
	level.zombie_vars[ "zombie_powerup_bonfire_sale_on" ] = 0;
	level notify( "bonfire_sale_off" );
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] playsound( "zmb_points_loop_off" );
		i++;
	}
	temp_ent delete();
}

start_carpenter( origin )
{
	window_boards = getstructarray( "exterior_goal", "targetname" );
	total = level.exterior_goals.size;
	carp_ent = spawn( "script_origin", ( 0, 0, 0 ) );
	carp_ent playloopsound( "evt_carpenter" );
	while ( 1 )
	{
		windows = get_closest_window_repair( window_boards, origin );
		if ( !isDefined( windows ) )
		{
			carp_ent stoploopsound( 1 );
			carp_ent playsoundwithnotify( "evt_carpenter_end", "sound_done" );
			carp_ent waittill( "sound_done" );
			break;
		}
		else arrayremovevalue( window_boards, windows );
		while ( 1 )
		{
			if ( all_chunks_intact( windows, windows.barrier_chunks ) )
			{
				break;
			}
			else chunk = get_random_destroyed_chunk( windows, windows.barrier_chunks );
			if ( !isDefined( chunk ) )
			{
				break;
			}
			else
			{
				windows thread maps/mp/zombies/_zm_blockers::replace_chunk( windows, chunk, undefined, maps/mp/zombies/_zm_powerups::is_carpenter_boards_upgraded(), 1 );
				if ( isDefined( windows.clip ) )
				{
					windows.clip enable_trigger();
					windows.clip disconnectpaths();
				}
				else
				{
					blocker_disconnect_paths( windows.neg_start, windows.neg_end );
				}
				wait_network_frame();
				wait 0,05;
			}
		}
		wait_network_frame();
	}
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] maps/mp/zombies/_zm_score::player_add_points( "carpenter_powerup", 200 );
		i++;
	}
	carp_ent delete();
}

get_closest_window_repair( windows, origin )
{
	current_window = undefined;
	shortest_distance = undefined;
	i = 0;
	while ( i < windows.size )
	{
		if ( all_chunks_intact( windows, windows[ i ].barrier_chunks ) )
		{
			i++;
			continue;
		}
		else if ( !isDefined( current_window ) )
		{
			current_window = windows[ i ];
			shortest_distance = distancesquared( current_window.origin, origin );
			i++;
			continue;
		}
		else
		{
			if ( distancesquared( windows[ i ].origin, origin ) < shortest_distance )
			{
				current_window = windows[ i ];
				shortest_distance = distancesquared( windows[ i ].origin, origin );
			}
		}
		i++;
	}
	return current_window;
}

powerup_vo( type )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( isDefined( level.powerup_vo_available ) )
	{
		if ( !( [[ level.powerup_vo_available ]]() ) )
		{
			return;
		}
	}
	wait randomfloatrange( 2, 2,5 );
	if ( type == "tesla" )
	{
		self maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", type );
	}
	else
	{
		self maps/mp/zombies/_zm_audio::create_and_play_dialog( "powerup", type );
	}
	if ( isDefined( level.custom_powerup_vo_response ) )
	{
		level [[ level.custom_powerup_vo_response ]]( self, type );
	}
}

powerup_wobble_fx()
{
	self endon( "death" );
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( isDefined( level.powerup_fx_func ) )
	{
		self thread [[ level.powerup_fx_func ]]();
		return;
	}
	if ( self.solo )
	{
		self setclientfield( "powerup_fx", 2 );
	}
	else if ( self.caution )
	{
		self setclientfield( "powerup_fx", 4 );
	}
	else if ( self.zombie_grabbable )
	{
		self setclientfield( "powerup_fx", 3 );
	}
	else
	{
		self setclientfield( "powerup_fx", 1 );
	}
}

powerup_wobble()
{
	self endon( "powerup_grabbed" );
	self endon( "powerup_timedout" );
	self thread powerup_wobble_fx();
	while ( isDefined( self ) )
	{
		waittime = randomfloatrange( 2,5, 5 );
		yaw = randomint( 360 );
		if ( yaw > 300 )
		{
			yaw = 300;
		}
		else
		{
			if ( yaw < 60 )
			{
				yaw = 60;
			}
		}
		yaw = self.angles[ 1 ] + yaw;
		new_angles = ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) );
		self rotateto( new_angles, waittime, waittime * 0,5, waittime * 0,5 );
		if ( isDefined( self.worldgundw ) )
		{
			self.worldgundw rotateto( new_angles, waittime, waittime * 0,5, waittime * 0,5 );
		}
		wait randomfloat( waittime - 0,1 );
	}
}

powerup_timeout()
{
	if ( isDefined( level._powerup_timeout_override ) && !isDefined( self.powerup_team ) )
	{
		self thread [[ level._powerup_timeout_override ]]();
		return;
	}
	self endon( "powerup_grabbed" );
	self endon( "death" );
	self endon( "powerup_reset" );
	self show();
	wait_time = 15;
	if ( isDefined( level._powerup_timeout_custom_time ) )
	{
		time = [[ level._powerup_timeout_custom_time ]]( self );
		if ( time == 0 )
		{
			return;
		}
		wait_time = time;
	}
	wait wait_time;
	i = 0;
	while ( i < 40 )
	{
		if ( i % 2 )
		{
			self ghost();
			if ( isDefined( self.worldgundw ) )
			{
				self.worldgundw ghost();
			}
		}
		else
		{
			self show();
			if ( isDefined( self.worldgundw ) )
			{
				self.worldgundw show();
			}
		}
		if ( i < 15 )
		{
			wait 0,5;
			i++;
			continue;
		}
		else if ( i < 25 )
		{
			wait 0,25;
			i++;
			continue;
		}
		else
		{
			wait 0,1;
		}
		i++;
	}
	self notify( "powerup_timedout" );
	self powerup_delete();
}

powerup_delete()
{
	arrayremovevalue( level.active_powerups, self, 0 );
	if ( isDefined( self.worldgundw ) )
	{
		self.worldgundw delete();
	}
	self delete();
}

powerup_delete_delayed( time )
{
	if ( isDefined( time ) )
	{
		wait time;
	}
	else
	{
		wait 0,01;
	}
	self powerup_delete();
}

nuke_powerup( drop_item, player_team )
{
	location = drop_item.origin;
	playfx( drop_item.fx, location );
	level thread nuke_flash();
	wait 0,5;
	zombies = getaiarray( level.zombie_team );
	zombies = arraysort( zombies, location );
	zombies_nuked = [];
	i = 0;
	while ( i < zombies.size )
	{
		if ( isDefined( zombies[ i ].ignore_nuke ) && zombies[ i ].ignore_nuke )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( zombies[ i ].marked_for_death ) && zombies[ i ].marked_for_death )
			{
				i++;
				continue;
			}
			else
			{
				if ( isDefined( zombies[ i ].nuke_damage_func ) )
				{
					zombies[ i ] thread [[ zombies[ i ].nuke_damage_func ]]();
					i++;
					continue;
				}
				else if ( is_magic_bullet_shield_enabled( zombies[ i ] ) )
				{
					i++;
					continue;
				}
				else
				{
					zombies[ i ].marked_for_death = 1;
					zombies[ i ].nuked = 1;
					zombies_nuked[ zombies_nuked.size ] = zombies[ i ];
				}
			}
		}
		i++;
	}
	i = 0;
	while ( i < zombies_nuked.size )
	{
		wait randomfloatrange( 0,1, 0,7 );
		if ( !isDefined( zombies_nuked[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( is_magic_bullet_shield_enabled( zombies_nuked[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( i < 5 && !zombies_nuked[ i ].isdog )
			{
				zombies_nuked[ i ] thread maps/mp/animscripts/zm_death::flame_death_fx();
			}
			if ( !zombies_nuked[ i ].isdog )
			{
				if ( isDefined( zombies_nuked[ i ].no_gib ) && !zombies_nuked[ i ].no_gib )
				{
					zombies_nuked[ i ] maps/mp/zombies/_zm_spawner::zombie_head_gib();
				}
				zombies_nuked[ i ] playsound( "evt_nuked" );
			}
			zombies_nuked[ i ] dodamage( zombies_nuked[ i ].health + 666, zombies_nuked[ i ].origin );
		}
		i++;
	}
	players = get_players( player_team );
	i = 0;
	while ( i < players.size )
	{
		players[ i ] maps/mp/zombies/_zm_score::player_add_points( "nuke_powerup", 400 );
		i++;
	}
}

nuke_flash()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] play_sound_2d( "evt_nuke_flash" );
		i++;
	}
	level thread devil_dialog_delay();
	fadetowhite = newhudelem();
	fadetowhite.x = 0;
	fadetowhite.y = 0;
	fadetowhite.alpha = 0;
	fadetowhite.horzalign = "fullscreen";
	fadetowhite.vertalign = "fullscreen";
	fadetowhite.foreground = 1;
	fadetowhite setshader( "white", 640, 480 );
	fadetowhite fadeovertime( 0,2 );
	fadetowhite.alpha = 0,8;
	wait 0,5;
	fadetowhite fadeovertime( 1 );
	fadetowhite.alpha = 0;
	wait 1,1;
	fadetowhite destroy();
}

double_points_powerup( drop_item, player )
{
	level notify( "powerup points scaled_" + player.team );
	level endon( "powerup points scaled_" + player.team );
	team = player.team;
	level thread point_doubler_on_hud( drop_item, team );
	if ( isDefined( level.current_game_module ) && level.current_game_module == 2 )
	{
		if ( isDefined( player._race_team ) )
		{
			if ( player._race_team == 1 )
			{
				level._race_team_double_points = 1;
			}
			else
			{
				level._race_team_double_points = 2;
			}
		}
	}
	level.zombie_vars[ team ][ "zombie_point_scalar" ] = 2;
	players = get_players();
	player_index = 0;
	while ( player_index < players.size )
	{
		if ( team == players[ player_index ].team )
		{
			players[ player_index ] setclientfield( "score_cf_double_points_active", 1 );
		}
		player_index++;
	}
	wait 30;
	level.zombie_vars[ team ][ "zombie_point_scalar" ] = 1;
	level._race_team_double_points = undefined;
	players = get_players();
	player_index = 0;
	while ( player_index < players.size )
	{
		if ( team == players[ player_index ].team )
		{
			players[ player_index ] setclientfield( "score_cf_double_points_active", 0 );
		}
		player_index++;
	}
}

full_ammo_powerup( drop_item, player )
{
	players = get_players( player.team );
	if ( isDefined( level._get_game_module_players ) )
	{
		players = [[ level._get_game_module_players ]]( player );
	}
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			i++;
			continue;
		}
		else
		{
			primary_weapons = players[ i ] getweaponslist( 1 );
			players[ i ] notify( "zmb_max_ammo" );
			players[ i ] notify( "zmb_lost_knife" );
			players[ i ] notify( "zmb_disable_claymore_prompt" );
			players[ i ] notify( "zmb_disable_spikemore_prompt" );
			x = 0;
			while ( x < primary_weapons.size )
			{
				if ( level.headshots_only && is_lethal_grenade( primary_weapons[ x ] ) )
				{
					x++;
					continue;
				}
				else
				{
					if ( isDefined( level.zombie_include_equipment ) && isDefined( level.zombie_include_equipment[ primary_weapons[ x ] ] ) )
					{
						x++;
						continue;
					}
					else
					{
						if ( players[ i ] hasweapon( primary_weapons[ x ] ) )
						{
							players[ i ] givemaxammo( primary_weapons[ x ] );
						}
					}
				}
				x++;
			}
		}
		i++;
	}
	level thread full_ammo_on_hud( drop_item, player.team );
}

insta_kill_powerup( drop_item, player )
{
	level notify( "powerup instakill_" + player.team );
	level endon( "powerup instakill_" + player.team );
	if ( isDefined( level.insta_kill_powerup_override ) )
	{
		level thread [[ level.insta_kill_powerup_override ]]( drop_item, player );
		return;
	}
	if ( is_classic() )
	{
		player thread player_insta_kill_upgrade_check();
	}
	team = player.team;
	level thread insta_kill_on_hud( drop_item, team );
	level.zombie_vars[ team ][ "zombie_insta_kill" ] = 1;
	wait 30;
	level.zombie_vars[ team ][ "zombie_insta_kill" ] = 0;
	players = get_players( team );
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( players[ i ] ) )
		{
			players[ i ] notify( "insta_kill_over" );
		}
		i++;
	}
}

is_insta_kill_active()
{
	return level.zombie_vars[ self.team ][ "zombie_insta_kill" ];
}

player_insta_kill_upgrade_check()
{
	if ( isDefined( level.pers_upgrade_insta_kill ) && level.pers_upgrade_insta_kill )
	{
		self endon( "death" );
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			e_player = players[ i ];
			if ( isDefined( e_player.pers_upgrades_awarded[ "insta_kill" ] ) && e_player.pers_upgrades_awarded[ "insta_kill" ] )
			{
				e_player thread insta_kill_upgraded_player_kill_func( level.pers_insta_kill_upgrade_active_time );
			}
			i++;
		}
		if ( isDefined( self.pers_upgrades_awarded[ "insta_kill" ] ) && !self.pers_upgrades_awarded[ "insta_kill" ] )
		{
			kills_start = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "kills" );
			self waittill( "insta_kill_over" );
			kills_end = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "kills" );
			num_killed = kills_end - kills_start;
			if ( num_killed > 0 )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_insta_kill", 0 );
				return;
			}
			else
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_insta_kill", 0 );
			}
		}
	}
}

insta_kill_upgraded_player_kill_func( active_time )
{
	self endon( "death" );
	wait 0,25;
	self thread maps/mp/zombies/_zm_pers_upgrades::insta_kill_pers_upgrade_icon();
	start_time = getTime();
	zombie_collide_radius = 50;
	zombie_player_height_test = 100;
	while ( 1 )
	{
		time = getTime();
		dt = ( time - start_time ) / 1000;
		if ( dt > active_time )
		{
			return;
		}
		else if ( !is_insta_kill_active() )
		{
			return;
		}
		else
		{
			a_zombies = getaiarray( level.zombie_team );
			e_closest = undefined;
			i = 0;
			while ( i < a_zombies.size )
			{
				e_zombie = a_zombies[ i ];
				if ( isDefined( e_zombie.marked_for_insta_upgraded_death ) )
				{
					i++;
					continue;
				}
				else
				{
					height_diff = abs( self.origin[ 2 ] - e_zombie.origin[ 2 ] );
					if ( height_diff < zombie_player_height_test )
					{
						dist = distance2d( self.origin, e_zombie.origin );
						if ( dist < zombie_collide_radius )
						{
							dist_max = dist;
							e_closest = e_zombie;
						}
					}
				}
				i++;
			}
			if ( isDefined( e_closest ) )
			{
				e_closest.marked_for_insta_upgraded_death = 1;
				e_closest dodamage( e_closest.health + 666, e_closest.origin, self, self, "none", "MOD_PISTOL_BULLET", 0, "knife_zm" );
			}
			wait 0,01;
		}
	}
}

check_for_instakill( player, mod, hit_location )
{
	if ( isDefined( player ) && isalive( player ) && isDefined( level.check_for_instakill_override ) )
	{
		if ( !( self [[ level.check_for_instakill_override ]]( player ) ) )
		{
			return;
		}
		if ( player.use_weapon_type == "MOD_MELEE" )
		{
			player.last_kill_method = "MOD_MELEE";
		}
		else
		{
			player.last_kill_method = "MOD_UNKNOWN";
		}
		modname = remove_mod_from_methodofdeath( mod );
		if ( isDefined( self.no_gib ) && !self.no_gib )
		{
			self maps/mp/zombies/_zm_spawner::zombie_head_gib();
		}
		self.health = 1;
		self dodamage( self.health + 666, self.origin, player, self, hit_location, modname );
		player notify( "zombie_killed" );
	}
	if ( isDefined( player ) && isalive( player ) || level.zombie_vars[ player.team ][ "zombie_insta_kill" ] && isDefined( player.personal_instakill ) && player.personal_instakill )
	{
		if ( is_magic_bullet_shield_enabled( self ) )
		{
			return;
		}
		if ( isDefined( self.instakill_func ) )
		{
			self thread [[ self.instakill_func ]]();
			return;
		}
		if ( player.use_weapon_type == "MOD_MELEE" )
		{
			player.last_kill_method = "MOD_MELEE";
		}
		else
		{
			player.last_kill_method = "MOD_UNKNOWN";
		}
		modname = remove_mod_from_methodofdeath( mod );
		if ( flag( "dog_round" ) )
		{
			self.health = 1;
			self dodamage( self.health + 666, self.origin, player, self, hit_location, modname );
			player notify( "zombie_killed" );
			return;
		}
		else
		{
			if ( isDefined( self.no_gib ) && !self.no_gib )
			{
				self maps/mp/zombies/_zm_spawner::zombie_head_gib();
			}
			self.health = 1;
			self dodamage( self.health + 666, self.origin, player, self, hit_location, modname );
			player notify( "zombie_killed" );
		}
	}
}

insta_kill_on_hud( drop_item, player_team )
{
	if ( level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_on" ] )
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_time" ] = 30;
		return;
	}
	level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_on" ] = 1;
	level thread time_remaning_on_insta_kill_powerup( player_team );
}

time_remaning_on_insta_kill_powerup( player_team )
{
	temp_enta = spawn( "script_origin", ( 0, 0, 0 ) );
	temp_enta playloopsound( "zmb_insta_kill_loop" );
	while ( level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_time" ] >= 0 )
	{
		wait 0,05;
		level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_time" ] -= 0,05;
	}
	players = get_players( player_team );
	i = 0;
	while ( i < players.size )
	{
		players[ i ] playsound( "zmb_insta_kill" );
		i++;
	}
	temp_enta stoploopsound( 2 );
	level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_on" ] = 0;
	level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_time" ] = 30;
	temp_enta delete();
}

point_doubler_on_hud( drop_item, player_team )
{
	self endon( "disconnect" );
	if ( level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] )
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] = 30;
		return;
	}
	level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] = 1;
	level thread time_remaining_on_point_doubler_powerup( player_team );
}

time_remaining_on_point_doubler_powerup( player_team )
{
	temp_ent = spawn( "script_origin", ( 0, 0, 0 ) );
	temp_ent playloopsound( "zmb_double_point_loop" );
	while ( level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] >= 0 )
	{
		wait 0,05;
		level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] -= 0,05;
	}
	level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] = 0;
	players = get_players( player_team );
	i = 0;
	while ( i < players.size )
	{
		players[ i ] playsound( "zmb_points_loop_off" );
		i++;
	}
	temp_ent stoploopsound( 2 );
	level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] = 30;
	temp_ent delete();
}

toggle_bonfire_sale_on()
{
	level endon( "powerup bonfire sale" );
	if ( !isDefined( level.zombie_vars[ "zombie_powerup_bonfire_sale_on" ] ) )
	{
		return;
	}
	if ( level.zombie_vars[ "zombie_powerup_bonfire_sale_on" ] )
	{
		if ( isDefined( level.bonfire_init_func ) )
		{
			level thread [[ level.bonfire_init_func ]]();
		}
		level waittill( "bonfire_sale_off" );
	}
}

toggle_fire_sale_on()
{
	level endon( "powerup fire sale" );
	if ( !isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) )
	{
		return;
	}
	while ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] )
	{
		i = 0;
		while ( i < level.chests.size )
		{
			show_firesale_box = level.chests[ i ] [[ level._zombiemode_check_firesale_loc_valid_func ]]();
			if ( show_firesale_box )
			{
				level.chests[ i ].zombie_cost = 10;
				if ( level.chest_index != i )
				{
					level.chests[ i ].was_temp = 1;
					if ( is_true( level.chests[ i ].hidden ) )
					{
						level.chests[ i ] thread maps/mp/zombies/_zm_magicbox::show_chest();
					}
					wait_network_frame();
				}
			}
			i++;
		}
		level waittill( "fire_sale_off" );
		i = 0;
		while ( i < level.chests.size )
		{
			show_firesale_box = level.chests[ i ] [[ level._zombiemode_check_firesale_loc_valid_func ]]();
			if ( show_firesale_box )
			{
				if ( level.chest_index != i && isDefined( level.chests[ i ].was_temp ) )
				{
					level.chests[ i ].was_temp = undefined;
					level thread remove_temp_chest( i );
				}
				level.chests[ i ].zombie_cost = level.chests[ i ].old_cost;
			}
			i++;
		}
	}
}

fire_sale_weapon_wait()
{
	self.zombie_cost = self.old_cost;
	while ( isDefined( self.chest_user ) )
	{
		wait_network_frame();
	}
	self set_hint_string( self, "default_treasure_chest_" + self.zombie_cost );
}

remove_temp_chest( chest_index )
{
	while ( isDefined( level.chests[ chest_index ].chest_user ) || isDefined( level.chests[ chest_index ]._box_open ) && level.chests[ chest_index ]._box_open == 1 )
	{
		wait_network_frame();
	}
	if ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] )
	{
		level.chests[ chest_index ].was_temp = 1;
		level.chests[ chest_index ].zombie_cost = 10;
		return;
	}
	playfx( level._effect[ "poltergeist" ], level.chests[ chest_index ].orig_origin );
	level.chests[ chest_index ].zbarrier playsound( "zmb_box_poof_land" );
	level.chests[ chest_index ].zbarrier playsound( "zmb_couch_slam" );
	level.chests[ chest_index ] maps/mp/zombies/_zm_magicbox::hide_chest();
}

devil_dialog_delay()
{
	wait 1;
}

full_ammo_on_hud( drop_item, player_team )
{
	self endon( "disconnect" );
	hudelem = maps/mp/gametypes_zm/_hud_util::createserverfontstring( "objective", 2, player_team );
	hudelem maps/mp/gametypes_zm/_hud_util::setpoint( "TOP", undefined, 0, level.zombie_vars[ "zombie_timer_offset" ] - ( level.zombie_vars[ "zombie_timer_offset_interval" ] * 2 ) );
	hudelem.sort = 0,5;
	hudelem.alpha = 0;
	hudelem fadeovertime( 0,5 );
	hudelem.alpha = 1;
	if ( isDefined( drop_item ) )
	{
		hudelem.label = drop_item.hint;
	}
	hudelem thread full_ammo_move_hud( player_team );
}

full_ammo_move_hud( player_team )
{
	players = get_players( player_team );
	i = 0;
	while ( i < players.size )
	{
		players[ i ] playsound( "zmb_full_ammo" );
		i++;
	}
	wait 0,5;
	move_fade_time = 1,5;
	self fadeovertime( move_fade_time );
	self moveovertime( move_fade_time );
	self.y = 270;
	self.alpha = 0;
	wait move_fade_time;
	self destroy();
}

check_for_rare_drop_override( pos )
{
	if ( isDefined( flag( "ape_round" ) ) && flag( "ape_round" ) )
	{
		return 0;
	}
	return 0;
}

setup_firesale_audio()
{
	wait 2;
	intercom = getentarray( "intercom", "targetname" );
	while ( 1 )
	{
		while ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 0 )
		{
			wait 0,2;
		}
		i = 0;
		while ( i < intercom.size )
		{
			intercom[ i ] thread play_firesale_audio();
			i++;
		}
		while ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 1 )
		{
			wait 0,1;
		}
		level notify( "firesale_over" );
	}
}

play_firesale_audio()
{
	if ( isDefined( level.sndannouncerisrich ) && level.sndannouncerisrich )
	{
		self playloopsound( "mus_fire_sale_rich" );
	}
	else
	{
		self playloopsound( "mus_fire_sale" );
	}
	level waittill( "firesale_over" );
	self stoploopsound();
}

setup_bonfiresale_audio()
{
	wait 2;
	intercom = getentarray( "intercom", "targetname" );
	while ( 1 )
	{
		while ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 0 )
		{
			wait 0,2;
		}
		i = 0;
		while ( i < intercom.size )
		{
			intercom[ i ] thread play_bonfiresale_audio();
			i++;
		}
		while ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 1 )
		{
			wait 0,1;
		}
		level notify( "firesale_over" );
	}
}

play_bonfiresale_audio()
{
	if ( isDefined( level.sndannouncerisrich ) && level.sndannouncerisrich )
	{
		self playloopsound( "mus_fire_sale_rich" );
	}
	else
	{
		self playloopsound( "mus_fire_sale" );
	}
	level waittill( "firesale_over" );
	self stoploopsound();
}

free_perk_powerup( item )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( !players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ].sessionstate != "spectator" )
		{
			players[ i ] maps/mp/zombies/_zm_perks::give_random_perk();
		}
		i++;
	}
}

random_weapon_powerup_throttle()
{
	self.random_weapon_powerup_throttle = 1;
	wait 0,25;
	self.random_weapon_powerup_throttle = 0;
}

random_weapon_powerup( item, player )
{
	if ( player.sessionstate == "spectator" || player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( player.random_weapon_powerup_throttle ) && !player.random_weapon_powerup_throttle || player isswitchingweapons() && player.is_drinking > 0 )
	{
		return 0;
	}
	current_weapon = player getcurrentweapon();
	current_weapon_type = weaponinventorytype( current_weapon );
	if ( !is_tactical_grenade( item.weapon ) )
	{
		if ( current_weapon_type != "primary" && current_weapon_type != "altmode" )
		{
			return 0;
		}
		if ( !isDefined( level.zombie_weapons[ current_weapon ] ) && !maps/mp/zombies/_zm_weapons::is_weapon_upgraded( current_weapon ) && current_weapon_type != "altmode" )
		{
			return 0;
		}
	}
	player thread random_weapon_powerup_throttle();
	weapon_string = item.weapon;
	if ( weapon_string == "knife_ballistic_zm" )
	{
		weapon = player maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon_string, 0 );
	}
	else
	{
		if ( weapon_string == "knife_ballistic_upgraded_zm" )
		{
			weapon = player maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon_string, 1 );
		}
	}
	player thread maps/mp/zombies/_zm_weapons::weapon_give( weapon_string );
	return 1;
}

bonus_points_player_powerup( item, player )
{
	points = randomintrange( 1, 25 ) * 100;
	if ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && player.sessionstate != "spectator" )
	{
		player maps/mp/zombies/_zm_score::player_add_points( "bonus_points_powerup", points );
	}
}

bonus_points_team_powerup( item )
{
	points = randomintrange( 1, 25 ) * 100;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( !players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ].sessionstate != "spectator" )
		{
			players[ i ] maps/mp/zombies/_zm_score::player_add_points( "bonus_points_powerup", points );
		}
		i++;
	}
}

lose_points_team_powerup( item )
{
	points = randomintrange( 1, 25 ) * 100;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( !players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ].sessionstate != "spectator" )
		{
			if ( ( players[ i ].score - points ) <= 0 )
			{
				players[ i ] maps/mp/zombies/_zm_score::minus_to_player_score( players[ i ].score );
				i++;
				continue;
			}
			else
			{
				players[ i ] maps/mp/zombies/_zm_score::minus_to_player_score( points );
			}
		}
		i++;
	}
}

lose_perk_powerup( item )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && player.sessionstate != "spectator" )
		{
			player maps/mp/zombies/_zm_perks::lose_random_perk();
		}
		i++;
	}
}

empty_clip_powerup( item )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && player.sessionstate != "spectator" )
		{
			weapon = player getcurrentweapon();
			player setweaponammoclip( weapon, 0 );
		}
		i++;
	}
}

minigun_weapon_powerup( ent_player, time )
{
	ent_player endon( "disconnect" );
	ent_player endon( "death" );
	ent_player endon( "player_downed" );
	if ( !isDefined( time ) )
	{
		time = 30;
	}
	if ( isDefined( level._minigun_time_override ) )
	{
		time = level._minigun_time_override;
	}
	if ( ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] || ent_player getcurrentweapon() == "minigun_zm" && isDefined( ent_player.has_minigun ) && ent_player.has_minigun )
	{
		if ( ent_player.zombie_vars[ "zombie_powerup_minigun_time" ] < time )
		{
			ent_player.zombie_vars[ "zombie_powerup_minigun_time" ] = time;
		}
		return;
	}
	ent_player notify( "replace_weapon_powerup" );
	ent_player._show_solo_hud = 1;
	level._zombie_minigun_powerup_last_stand_func = ::minigun_watch_gunner_downed;
	ent_player.has_minigun = 1;
	ent_player.has_powerup_weapon = 1;
	ent_player increment_is_drinking();
	ent_player._zombie_gun_before_minigun = ent_player getcurrentweapon();
	ent_player giveweapon( "minigun_zm" );
	ent_player switchtoweapon( "minigun_zm" );
	ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] = 1;
	level thread minigun_weapon_powerup_countdown( ent_player, "minigun_time_over", time );
	level thread minigun_weapon_powerup_replace( ent_player, "minigun_time_over" );
}

minigun_weapon_powerup_countdown( ent_player, str_gun_return_notify, time )
{
	ent_player endon( "death" );
	ent_player endon( "disconnect" );
	ent_player endon( "player_downed" );
	ent_player endon( str_gun_return_notify );
	ent_player endon( "replace_weapon_powerup" );
	setclientsysstate( "levelNotify", "minis", ent_player );
	ent_player.zombie_vars[ "zombie_powerup_minigun_time" ] = time;
	while ( ent_player.zombie_vars[ "zombie_powerup_minigun_time" ] > 0 )
	{
		wait 0,05;
		ent_player.zombie_vars[ "zombie_powerup_minigun_time" ] -= 0,05;
	}
	setclientsysstate( "levelNotify", "minie", ent_player );
	level thread minigun_weapon_powerup_remove( ent_player, str_gun_return_notify );
}

minigun_weapon_powerup_replace( ent_player, str_gun_return_notify )
{
	ent_player endon( "death" );
	ent_player endon( "disconnect" );
	ent_player endon( "player_downed" );
	ent_player endon( str_gun_return_notify );
	ent_player waittill( "replace_weapon_powerup" );
	ent_player takeweapon( "minigun_zm" );
	ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] = 0;
	ent_player.has_minigun = 0;
	ent_player decrement_is_drinking();
}

minigun_weapon_powerup_remove( ent_player, str_gun_return_notify )
{
	ent_player endon( "death" );
	ent_player endon( "player_downed" );
	ent_player takeweapon( "minigun_zm" );
	ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] = 0;
	ent_player._show_solo_hud = 0;
	ent_player.has_minigun = 0;
	ent_player.has_powerup_weapon = 0;
	ent_player notify( str_gun_return_notify );
	ent_player decrement_is_drinking();
	while ( isDefined( ent_player._zombie_gun_before_minigun ) )
	{
		player_weapons = ent_player getweaponslistprimaries();
		i = 0;
		while ( i < player_weapons.size )
		{
			if ( player_weapons[ i ] == ent_player._zombie_gun_before_minigun )
			{
				ent_player switchtoweapon( ent_player._zombie_gun_before_minigun );
				return;
			}
			i++;
		}
	}
	primaryweapons = ent_player getweaponslistprimaries();
	if ( primaryweapons.size > 0 )
	{
		ent_player switchtoweapon( primaryweapons[ 0 ] );
	}
	else
	{
		allweapons = ent_player getweaponslist( 1 );
		i = 0;
		while ( i < allweapons.size )
		{
			if ( is_melee_weapon( allweapons[ i ] ) )
			{
				ent_player switchtoweapon( allweapons[ i ] );
				return;
			}
			i++;
		}
	}
}

minigun_weapon_powerup_off()
{
	self.zombie_vars[ "zombie_powerup_minigun_time" ] = 0;
}

minigun_watch_gunner_downed()
{
	if ( isDefined( self.has_minigun ) && !self.has_minigun )
	{
		return;
	}
	primaryweapons = self getweaponslistprimaries();
	i = 0;
	while ( i < primaryweapons.size )
	{
		if ( primaryweapons[ i ] == "minigun_zm" )
		{
			self takeweapon( "minigun_zm" );
		}
		i++;
	}
	self notify( "minigun_time_over" );
	self.zombie_vars[ "zombie_powerup_minigun_on" ] = 0;
	self._show_solo_hud = 0;
	wait 0,05;
	self.has_minigun = 0;
	self.has_powerup_weapon = 0;
}

tesla_weapon_powerup( ent_player, time )
{
	ent_player endon( "disconnect" );
	ent_player endon( "death" );
	ent_player endon( "player_downed" );
	if ( !isDefined( time ) )
	{
		time = 11;
	}
	if ( ent_player.zombie_vars[ "zombie_powerup_tesla_on" ] || ent_player getcurrentweapon() == "tesla_gun_zm" && isDefined( ent_player.has_tesla ) && ent_player.has_tesla )
	{
		ent_player givemaxammo( "tesla_gun_zm" );
		if ( ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] < time )
		{
			ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] = time;
		}
		return;
	}
	ent_player notify( "replace_weapon_powerup" );
	ent_player._show_solo_hud = 1;
	level._zombie_tesla_powerup_last_stand_func = ::tesla_watch_gunner_downed;
	ent_player.has_tesla = 1;
	ent_player.has_powerup_weapon = 1;
	ent_player increment_is_drinking();
	ent_player._zombie_gun_before_tesla = ent_player getcurrentweapon();
	ent_player giveweapon( "tesla_gun_zm" );
	ent_player givemaxammo( "tesla_gun_zm" );
	ent_player switchtoweapon( "tesla_gun_zm" );
	ent_player.zombie_vars[ "zombie_powerup_tesla_on" ] = 1;
	level thread tesla_weapon_powerup_countdown( ent_player, "tesla_time_over", time );
	level thread tesla_weapon_powerup_replace( ent_player, "tesla_time_over" );
}

tesla_weapon_powerup_countdown( ent_player, str_gun_return_notify, time )
{
	ent_player endon( "death" );
	ent_player endon( "player_downed" );
	ent_player endon( str_gun_return_notify );
	ent_player endon( "replace_weapon_powerup" );
	setclientsysstate( "levelNotify", "minis", ent_player );
	ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] = time;
	while ( 1 )
	{
		ent_player waittill_any( "weapon_fired", "reload", "zmb_max_ammo" );
		if ( !ent_player getweaponammostock( "tesla_gun_zm" ) )
		{
			clip_count = ent_player getweaponammoclip( "tesla_gun_zm" );
			if ( !clip_count )
			{
				break;
			}
			else if ( clip_count == 1 )
			{
				ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] = 1;
			}
			else
			{
				if ( clip_count == 3 )
				{
					ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] = 6;
				}
			}
			continue;
		}
		else
		{
			ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] = 11;
		}
	}
	setclientsysstate( "levelNotify", "minie", ent_player );
	level thread tesla_weapon_powerup_remove( ent_player, str_gun_return_notify );
}

tesla_weapon_powerup_replace( ent_player, str_gun_return_notify )
{
	ent_player endon( "death" );
	ent_player endon( "disconnect" );
	ent_player endon( "player_downed" );
	ent_player endon( str_gun_return_notify );
	ent_player waittill( "replace_weapon_powerup" );
	ent_player takeweapon( "tesla_gun_zm" );
	ent_player.zombie_vars[ "zombie_powerup_tesla_on" ] = 0;
	ent_player.has_tesla = 0;
	ent_player decrement_is_drinking();
}

tesla_weapon_powerup_remove( ent_player, str_gun_return_notify )
{
	ent_player endon( "death" );
	ent_player endon( "player_downed" );
	ent_player takeweapon( "tesla_gun_zm" );
	ent_player.zombie_vars[ "zombie_powerup_tesla_on" ] = 0;
	ent_player._show_solo_hud = 0;
	ent_player.has_tesla = 0;
	ent_player.has_powerup_weapon = 0;
	ent_player notify( str_gun_return_notify );
	ent_player decrement_is_drinking();
	while ( isDefined( ent_player._zombie_gun_before_tesla ) )
	{
		player_weapons = ent_player getweaponslistprimaries();
		i = 0;
		while ( i < player_weapons.size )
		{
			if ( player_weapons[ i ] == ent_player._zombie_gun_before_tesla )
			{
				ent_player switchtoweapon( ent_player._zombie_gun_before_tesla );
				return;
			}
			i++;
		}
	}
	primaryweapons = ent_player getweaponslistprimaries();
	if ( primaryweapons.size > 0 )
	{
		ent_player switchtoweapon( primaryweapons[ 0 ] );
	}
	else
	{
		allweapons = ent_player getweaponslist( 1 );
		i = 0;
		while ( i < allweapons.size )
		{
			if ( is_melee_weapon( allweapons[ i ] ) )
			{
				ent_player switchtoweapon( allweapons[ i ] );
				return;
			}
			i++;
		}
	}
}

tesla_weapon_powerup_off()
{
	self.zombie_vars[ "zombie_powerup_tesla_time" ] = 0;
}

tesla_watch_gunner_downed()
{
	if ( isDefined( self.has_tesla ) && !self.has_tesla )
	{
		return;
	}
	primaryweapons = self getweaponslistprimaries();
	i = 0;
	while ( i < primaryweapons.size )
	{
		if ( primaryweapons[ i ] == "tesla_gun_zm" )
		{
			self takeweapon( "tesla_gun_zm" );
		}
		i++;
	}
	self notify( "tesla_time_over" );
	self.zombie_vars[ "zombie_powerup_tesla_on" ] = 0;
	self._show_solo_hud = 0;
	wait 0,05;
	self.has_tesla = 0;
	self.has_powerup_weapon = 0;
}

tesla_powerup_active()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].zombie_vars[ "zombie_powerup_tesla_on" ] )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

print_powerup_drop( powerup, type )
{
/#
	if ( !isDefined( level.powerup_drop_time ) )
	{
		level.powerup_drop_time = 0;
		level.powerup_random_count = 0;
		level.powerup_score_count = 0;
	}
	time = ( getTime() - level.powerup_drop_time ) * 0,001;
	level.powerup_drop_time = getTime();
	if ( type == "random" )
	{
		level.powerup_random_count++;
	}
	else
	{
		level.powerup_score_count++;
	}
	println( "========== POWER UP DROPPED ==========" );
	println( "DROPPED: " + powerup );
	println( "HOW IT DROPPED: " + type );
	println( "--------------------" );
	println( "Drop Time: " + time );
	println( "Random Powerup Count: " + level.powerup_random_count );
	println( "Random Powerup Count: " + level.powerup_score_count );
	println( "======================================" );
#/
}

register_carpenter_node( node, callback )
{
	if ( !isDefined( level._additional_carpenter_nodes ) )
	{
		level._additional_carpenter_nodes = [];
	}
	node._post_carpenter_callback = callback;
	level._additional_carpenter_nodes[ level._additional_carpenter_nodes.size ] = node;
}

start_carpenter_new( origin )
{
	level.carpenter_powerup_active = 1;
	window_boards = getstructarray( "exterior_goal", "targetname" );
	if ( isDefined( level._additional_carpenter_nodes ) )
	{
		window_boards = arraycombine( window_boards, level._additional_carpenter_nodes, 0, 0 );
	}
	carp_ent = spawn( "script_origin", ( 0, 0, 0 ) );
	carp_ent playloopsound( "evt_carpenter" );
	boards_near_players = get_near_boards( window_boards );
	boards_far_from_players = get_far_boards( window_boards );
	level repair_far_boards( boards_far_from_players, maps/mp/zombies/_zm_powerups::is_carpenter_boards_upgraded() );
	i = 0;
	while ( i < boards_near_players.size )
	{
		window = boards_near_players[ i ];
		num_chunks_checked = 0;
		last_repaired_chunk = undefined;
		while ( 1 )
		{
			if ( all_chunks_intact( window, window.barrier_chunks ) )
			{
				break;
			}
			else chunk = get_random_destroyed_chunk( window, window.barrier_chunks );
			if ( !isDefined( chunk ) )
			{
				break;
			}
			else window thread maps/mp/zombies/_zm_blockers::replace_chunk( window, chunk, undefined, maps/mp/zombies/_zm_powerups::is_carpenter_boards_upgraded(), 1 );
			last_repaired_chunk = chunk;
			if ( isDefined( window.clip ) )
			{
				window.clip enable_trigger();
				window.clip disconnectpaths();
			}
			else
			{
				blocker_disconnect_paths( window.neg_start, window.neg_end );
			}
			wait_network_frame();
			num_chunks_checked++;
			if ( num_chunks_checked >= 20 )
			{
				break;
			}
			else
			{
			}
		}
		if ( isDefined( window.zbarrier ) )
		{
			if ( isDefined( last_repaired_chunk ) )
			{
				while ( window.zbarrier getzbarrierpiecestate( last_repaired_chunk ) == "closing" )
				{
					wait 0,05;
				}
				if ( isDefined( window._post_carpenter_callback ) )
				{
					window [[ window._post_carpenter_callback ]]();
				}
			}
			i++;
			continue;
		}
		else while ( isDefined( last_repaired_chunk ) && last_repaired_chunk.state == "mid_repair" )
		{
			wait 0,05;
		}
		i++;
	}
	carp_ent stoploopsound( 1 );
	carp_ent playsoundwithnotify( "evt_carpenter_end", "sound_done" );
	carp_ent waittill( "sound_done" );
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] maps/mp/zombies/_zm_score::player_add_points( "carpenter_powerup", 200 );
		i++;
	}
	carp_ent delete();
	level notify( "carpenter_finished" );
	level.carpenter_powerup_active = undefined;
}

is_carpenter_boards_upgraded()
{
	if ( isDefined( level.pers_carpenter_boards_active ) && level.pers_carpenter_boards_active == 1 )
	{
		return 1;
	}
	return 0;
}

get_near_boards( windows )
{
	players = get_players();
	boards_near_players = [];
	j = 0;
	while ( j < windows.size )
	{
		close = 0;
		i = 0;
		while ( i < players.size )
		{
			origin = undefined;
			if ( isDefined( windows[ j ].zbarrier ) )
			{
				origin = windows[ j ].zbarrier.origin;
			}
			else
			{
				origin = windows[ j ].origin;
			}
			if ( distancesquared( players[ i ].origin, origin ) <= level.board_repair_distance_squared )
			{
				close = 1;
				break;
			}
			else
			{
				i++;
			}
		}
		if ( close )
		{
			boards_near_players[ boards_near_players.size ] = windows[ j ];
		}
		j++;
	}
	return boards_near_players;
}

get_far_boards( windows )
{
	players = get_players();
	boards_far_from_players = [];
	j = 0;
	while ( j < windows.size )
	{
		close = 0;
		i = 0;
		while ( i < players.size )
		{
			origin = undefined;
			if ( isDefined( windows[ j ].zbarrier ) )
			{
				origin = windows[ j ].zbarrier.origin;
			}
			else
			{
				origin = windows[ j ].origin;
			}
			if ( distancesquared( players[ i ].origin, origin ) >= level.board_repair_distance_squared )
			{
				close = 1;
				break;
			}
			else
			{
				i++;
			}
		}
		if ( close )
		{
			boards_far_from_players[ boards_far_from_players.size ] = windows[ j ];
		}
		j++;
	}
	return boards_far_from_players;
}

repair_far_boards( barriers, upgrade )
{
	i = 0;
	while ( i < barriers.size )
	{
		barrier = barriers[ i ];
		if ( all_chunks_intact( barrier, barrier.barrier_chunks ) )
		{
			i++;
			continue;
		}
		else
		{
			while ( isDefined( barrier.zbarrier ) )
			{
				a_pieces = barrier.zbarrier getzbarrierpieceindicesinstate( "open" );
				while ( isDefined( a_pieces ) )
				{
					xx = 0;
					while ( xx < a_pieces.size )
					{
						chunk = a_pieces[ xx ];
						if ( upgrade )
						{
							barrier.zbarrier zbarrierpieceuseupgradedmodel( chunk );
							barrier.zbarrier.chunk_health[ chunk ] = barrier.zbarrier getupgradedpiecenumlives( chunk );
							xx++;
							continue;
						}
						else
						{
							barrier.zbarrier zbarrierpieceusedefaultmodel( chunk );
							barrier.zbarrier.chunk_health[ chunk ] = 0;
						}
						xx++;
					}
				}
				x = 0;
				while ( x < barrier.zbarrier getnumzbarrierpieces() )
				{
					barrier.zbarrier setzbarrierpiecestate( x, "closed" );
					barrier.zbarrier showzbarrierpiece( x );
					x++;
				}
			}
			if ( isDefined( barrier.clip ) )
			{
				barrier.clip enable_trigger();
				barrier.clip disconnectpaths();
			}
			else
			{
				blocker_disconnect_paths( barrier.neg_start, barrier.neg_end );
			}
			if ( ( i % 4 ) == 0 )
			{
				wait_network_frame();
			}
		}
		i++;
	}
}

func_should_never_drop()
{
	return 0;
}

func_should_always_drop()
{
	return 1;
}

func_should_drop_minigun()
{
	if ( minigun_no_drop() )
	{
		return 0;
	}
	return 1;
}

func_should_drop_carpenter()
{
	if ( get_num_window_destroyed() < 5 )
	{
		return 0;
	}
	return 1;
}

func_should_drop_fire_sale()
{
	if ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 1 || level.chest_moves < 1 )
	{
		return 0;
	}
	return 1;
}

powerup_move()
{
	self endon( "powerup_timedout" );
	self endon( "powerup_grabbed" );
	drag_speed = 75;
	while ( 1 )
	{
		self waittill( "move_powerup", moveto, distance );
		drag_vector = moveto - self.origin;
		range_squared = lengthsquared( drag_vector );
		if ( range_squared > ( distance * distance ) )
		{
			drag_vector = vectornormalize( drag_vector );
			drag_vector = distance * drag_vector;
			moveto = self.origin + drag_vector;
		}
		self.origin = moveto;
	}
}

powerup_emp()
{
	self endon( "powerup_timedout" );
	self endon( "powerup_grabbed" );
	while ( 1 )
	{
		level waittill( "emp_detonate", origin, radius );
		if ( distancesquared( origin, self.origin ) < ( radius * radius ) )
		{
			playfx( level._effect[ "powerup_off" ], self.origin );
			self thread powerup_delete_delayed();
			self notify( "powerup_timedout" );
		}
	}
}

get_powerups( origin, radius )
{
	if ( isDefined( origin ) && isDefined( radius ) )
	{
		powerups = [];
		_a3605 = level.active_powerups;
		_k3605 = getFirstArrayKey( _a3605 );
		while ( isDefined( _k3605 ) )
		{
			powerup = _a3605[ _k3605 ];
			if ( distancesquared( origin, powerup.origin ) < ( radius * radius ) )
			{
				powerups[ powerups.size ] = powerup;
			}
			_k3605 = getNextArrayKey( _a3605, _k3605 );
		}
		return powerups;
	}
	return level.active_powerups;
}

should_award_stat( powerup_name )
{
	if ( powerup_name != "teller_withdrawl" || powerup_name == "blue_monkey" && powerup_name == "free_perk" )
	{
		return 0;
	}
	if ( isDefined( level.statless_powerups ) && isDefined( level.statless_powerups[ powerup_name ] ) )
	{
		return 0;
	}
	return 1;
}

teller_withdrawl( powerup, player )
{
	player maps/mp/zombies/_zm_score::add_to_player_score( powerup.value );
}
