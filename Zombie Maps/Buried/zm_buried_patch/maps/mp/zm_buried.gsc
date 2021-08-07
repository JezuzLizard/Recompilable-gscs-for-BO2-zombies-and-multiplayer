#include maps/mp/zm_buried;
#include maps/mp/zombies/_zm_equip_headchopper;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_ai_faller;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_devgui;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zm_buried_classic;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_weap_time_bomb;
#include maps/mp/zm_buried_jail;
#include maps/mp/zombies/_zm_perk_vulture;
#include maps/mp/zombies/_zm_perk_divetonuke;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/teams/_teamset_cdc;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zm_buried_buildables;
#include maps/mp/zm_buried_ffotd;
#include maps/mp/zm_buried_distance_tracking;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

gamemode_callback_setup()
{
	maps/mp/zm_buried_gamemodes::init();
}

survival_init()
{
	level.force_team_characters = 1;
	level.should_use_cia = 0;
	if ( randomint( 100 ) > 50 )
	{
		level.should_use_cia = 1;
	}
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
	zm_buried_common_init();
	flag_wait( "start_zombie_round_logic" );
}

zstandard_preinit()
{
	survival_init();
}

zcleansed_preinit()
{
	level._zcleansed_weapon_progression = array( "judge_zm", "srm1216_zm", "hk416_zm", "qcw05_zm", "kard_zm" );
	level.cymbal_monkey_clone_weapon = "srm1216_zm";
	trig_removal = getentarray( "zombie_door", "targetname" );
	_a52 = trig_removal;
	_k52 = getFirstArrayKey( _a52 );
	while ( isDefined( _k52 ) )
	{
		trig = _a52[ _k52 ];
		if ( isDefined( trig.script_parameters ) && trig.script_parameters == "grief_remove" )
		{
			trig delete();
		}
		if ( isDefined( trig.script_parameters ) && trig.script_parameters == "zcleansed_remove" )
		{
			parts = getentarray( trig.target, "targetname" );
			while ( isDefined( parts ) )
			{
				i = 0;
				while ( i < parts.size )
				{
					parts[ i ] delete();
					i++;
				}
			}
			trig delete();
		}
		_k52 = getNextArrayKey( _a52, _k52 );
	}
	survival_init();
}

zgrief_preinit()
{
	registerclientfield( "toplayer", "meat_stink", 1, 1, "int" );
	zgrief_init();
}

zgrief_init()
{
	encounter_init();
	zm_buried_common_init();
	flag_wait( "start_zombie_round_logic" );
	trig_removal = getentarray( "zombie_door", "targetname" );
	_a92 = trig_removal;
	_k92 = getFirstArrayKey( _a92 );
	while ( isDefined( _k92 ) )
	{
		trig = _a92[ _k92 ];
		if ( isDefined( trig.script_parameters ) && trig.script_parameters == "grief_remove" )
		{
			trig delete();
		}
		_k92 = getNextArrayKey( _a92, _k92 );
	}
}

encounter_init()
{
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
}

createfx_callback()
{
	ents = getentarray();
	i = 0;
	while ( i < ents.size )
	{
		if ( ents[ i ].classname != "info_player_start" )
		{
			ents[ i ] delete();
		}
		i++;
	}
}

zclassic_init()
{
	level.precachecustomcharacters = ::precache_personality_characters;
	level.givecustomcharacters = ::give_personality_characters;
	level.setupcustomcharacterexerts = ::setup_personality_character_exerts;
	level.check_valid_poi = ::check_valid_poi;
	level.tear_into_position = ::tear_into_position;
	level.tear_into_wait = ::tear_into_wait;
	level.melee_miss_func = ::melee_miss_func;
	precachemodel( "p6_zm_keycard" );
	zm_buried_common_init();
	level.banking_map = "zm_transit";
	level.weapon_locker_map = "zm_transit";
	level thread maps/mp/zombies/_zm_banking::init();
	level.disable_free_perks_before_power = 1;
	maps/mp/zm_buried_sq::sq_buried_clientfield_init();
	flag_wait( "start_zombie_round_logic" );
	level thread maps/mp/zombies/_zm_weapon_locker::main();
	level thread maps/mp/zombies/_zm_banking::main();
	level thread collapsing_catwalk_init();
	level thread maps/mp/zm_buried_distance_tracking::zombie_tracking_init();
	maps/mp/zombies/_zm_weapons::register_zombie_weapon_callback( "lsat_zm", ::player_give_lsat );
}

zclassic_preinit()
{
	zclassic_init();
}

zmaxis_preinit()
{
	zmaxis_init();
}

zmaxis_init()
{
	encounter_init();
	zm_buried_common_init();
	flag_wait( "start_zombie_round_logic" );
}

zrichtofen_preinit()
{
	zrichtofen_init();
}

zrichtofen_init()
{
	encounter_init();
	zm_buried_common_init();
	flag_wait( "start_zombie_round_logic" );
}

zm_buried_common_init()
{
	num_bits = 2;
	registerclientfield( "world", "GENERATOR_POWER_STATES", 12000, num_bits, "int" );
	registerclientfield( "world", "GENERATOR_POWER_STATES_COLOR", 12000, 1, "int" );
	registerclientfield( "world", "GENERATOR_POWER_STATES_LERP", 12000, 5, "float" );
	registerclientfield( "world", "cw_fall", 12000, 1, "int" );
	registerclientfield( "world", "maze_fountain_start", 12000, 1, "int" );
	registerclientfield( "world", "sloth_fountain_start", 12000, 1, "int" );
	registerclientfield( "world", "mansion_piano_play", 12000, 1, "int" );
	registerclientfield( "world", "saloon_piano_play", 12000, 1, "int" );
	registerclientfield( "world", "mus_noir_snapshot_loop", 12000, 1, "int" );
	registerclientfield( "world", "mus_zmb_egg_snapshot_loop", 12000, 1, "int" );
	registerclientfield( "toplayer", "sndBackgroundMus", 12000, 3, "int" );
	registerclientfield( "toplayer", "clientfield_underground_lighting", 12000, 1, "int" );
}

main()
{
	maps/mp/zm_buried_fx::main();
	level thread maps/mp/zm_buried_ffotd::main_start();
	setdvarint( "sm_sunShadowSmallScriptPS3OnlyEnable", 1 );
	level.disable_fx_zmb_wall_buy_semtex = 1;
	level.disable_fx_zmb_tranzit_shield_explo = 1;
	level.default_game_mode = "zclassic";
	level.default_start_location = "processing";
	setup_rex_starts();
	level.disable_blackscreen_clientfield = 1;
	level.disable_deadshot_clientfield = 1;
	level.custom_zombie_player_loadout_init = 1;
	maps/mp/zm_buried_buildables::prepare_chalk_weapon_list();
	level.fx_exclude_edge_fog = 1;
	level.fx_exclude_tesla_head_light = 1;
	level.fx_exclude_default_explosion = 1;
	level.fx_exclude_default_eye_glow = 1;
	maps/mp/zombies/_zm::init_fx();
	maps/mp/animscripts/zm_death::precache_gib_fx();
	level.zombiemode = 1;
	level._no_water_risers = 1;
	level._foliage_risers = 1;
	maps/mp/zm_buried_amb::main();
	maps/mp/zombies/_zm_ai_ghost::precache_fx();
	maps/mp/zombies/_zm_ai_sloth::precache();
	maps/mp/zm_buried_sq::precache_sq();
	level.level_specific_stats_init = ::init_buried_stats;
	maps/mp/zombies/_load::main();
	setdvar( "zombiemode_path_minz_bias", 13 );
	if ( getDvar( "createfx" ) != "" )
	{
		return;
	}
	maps/mp/teams/_teamset_cdc::level_init();
	maps/mp/gametypes_zm/_spawning::level_use_unified_spawning( 1 );
	level.givecustomloadout = ::givecustomloadout;
	level.custom_player_fake_death = ::zm_player_fake_death;
	level.custom_player_fake_death_cleanup = ::zm_player_fake_death_cleanup;
	level.initial_round_wait_func = ::initial_round_wait_func;
	level.level_specific_init_powerups = ::add_buried_powerups;
	level.zombie_init_done = ::zombie_init_done;
	level.zombiemode_using_pack_a_punch = 1;
	level.zombiemode_reusing_pack_a_punch = 1;
	level.pap_interaction_height = 47;
	level.zombiemode_using_doubletap_perk = 1;
	level.zombiemode_using_juggernaut_perk = 1;
	level.zombiemode_using_revive_perk = 1;
	level.zombiemode_using_sleightofhand_perk = 1;
	level.zombiemode_using_additionalprimaryweapon_perk = 1;
	level.zombiemode_using_marathon_perk = 1;
	if ( is_gametype_active( "zclassic" ) )
	{
		maps/mp/zombies/_zm_perk_divetonuke::enable_divetonuke_perk_for_level();
		maps/mp/zombies/_zm_perk_vulture::enable_vulture_perk_for_level();
	}
	maps/mp/zm_buried_jail::init_jail_animtree();
	init_persistent_abilities();
	level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;
	level.zombiemode_offhand_weapon_give_override = ::offhand_weapon_give_override;
	level._zombie_custom_add_weapons = ::custom_add_weapons;
	level._allow_melee_weapon_switching = 1;
	if ( is_gametype_active( "zclassic" ) )
	{
		level.custom_ai_type = [];
		level.custom_ai_type[ level.custom_ai_type.size ] = ::maps/mp/zombies/_zm_ai_ghost::init;
		level.custom_ai_type[ level.custom_ai_type.size ] = ::maps/mp/zombies/_zm_ai_sloth::init;
		level.sloth_enable = 1;
	}
	level._zmbvoxlevelspecific = ::init_level_specific_audio;
	maps/mp/zm_buried_jail::init_jail();
	include_weapons();
	include_powerups();
	include_equipment_for_level();
	init_level_specific_wall_buy_fx();
	registerclientfield( "world", "buried_sq_maxis_eye_glow_override", 12000, 1, "int" );
	registerclientfield( "allplayers", "buried_sq_richtofen_player_eyes_stuhlinger", 12000, 1, "int" );
	registerclientfield( "allplayers", "phd_flopper_effects", 12000, 1, "int" );
	maps/mp/zombies/_zm::init();
	if ( !sessionmodeisonlinegame() )
	{
		level.pers_nube_lose_round = 0;
	}
	maps/mp/zombies/_zm_weap_bowie::init();
	maps/mp/zombies/_zm_weap_cymbal_monkey::init();
	maps/mp/zombies/_zm_weap_claymore::init();
	maps/mp/zombies/_zm_weap_ballistic_knife::init();
	maps/mp/zombies/_zm_weap_slowgun::init();
	level.slowgun_allow_player_paralyze = ::buried_paralyzer_check;
	maps/mp/zombies/_zm_weap_tazer_knuckles::init();
	if ( is_gametype_active( "zclassic" ) )
	{
		maps/mp/zombies/_zm_weap_time_bomb::init_time_bomb();
	}
	level maps/mp/zm_buried_achievement::init();
	precacheitem( "death_throe_zm" );
	if ( level.splitscreen && getDvarInt( "splitscreen_playerCount" ) > 2 )
	{
		level.optimise_for_splitscreen = 1;
	}
	else
	{
		level.optimise_for_splitscreen = 0;
	}
	maps/mp/zm_buried_maze::maze_precache();
	maps/mp/zm_buried_maze::init();
	if ( is_gametype_active( "zclassic" ) )
	{
		level thread maps/mp/zm_buried_sq::init();
	}
	level.zones = [];
	level.zone_manager_init_func = ::buried_zone_init;
	init_zones[ 0 ] = "zone_start";
	init_zones[ 1 ] = "zone_tunnels_north";
	init_zones[ 2 ] = "zone_tunnels_center";
	init_zones[ 3 ] = "zone_tunnels_south";
	init_zones[ 4 ] = "zone_stables";
	init_zones[ 5 ] = "zone_street_darkeast";
	init_zones[ 6 ] = "zone_street_darkwest";
	init_zones[ 7 ] = "zone_street_lightwest";
	init_zones[ 8 ] = "zone_street_lighteast";
	init_zones[ 9 ] = "zone_underground_bar";
	init_zones[ 10 ] = "zone_bank";
	init_zones[ 11 ] = "zone_general_store";
	init_zones[ 12 ] = "zone_candy_store";
	init_zones[ 13 ] = "zone_candy_store_floor2";
	init_zones[ 14 ] = "zone_toy_store";
	init_zones[ 15 ] = "zone_gun_store";
	init_zones[ 16 ] = "zone_underground_jail";
	init_zones[ 17 ] = "zone_start_lower";
	init_zones[ 18 ] = "zone_tunnels_south2";
	init_zones[ 19 ] = "zone_tunnels_north2";
	init_zones[ 20 ] = "zone_mansion";
	init_zones[ 21 ] = "zone_mansion_lawn";
	level thread maps/mp/zombies/_zm_zonemgr::manage_zones( init_zones );
	if ( isDefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
	{
		if ( is_classic() )
		{
			level.zombie_ai_limit = 20;
		}
		level.claymores_max_per_player /= 2;
		setdvar( "fx_marks_draw", 0 );
		setdvar( "disable_rope", 1 );
		setdvar( "cg_disableplayernames", 1 );
		setdvar( "disableLookAtEntityLogic", 1 );
	}
	else
	{
		level.zombie_ai_limit = 24;
	}
	level.speed_change_round = 15;
	level.speed_change_max = 5;
	level thread bell_watch();
	trigs = getentarray( "force_from_prone", "targetname" );
	array_thread( trigs, ::player_force_from_prone );
	level thread maps/mp/zm_buried_classic::collapsing_holes_init();
	if ( level.scr_zm_ui_gametype == "zcleansed" )
	{
		level thread init_turned_zones();
	}
	level.calc_closest_player_using_paths = 1;
	level.validate_enemy_path_length = ::buried_validate_enemy_path_length;
	level.customrandomweaponweights = ::buried_custom_weapon_weights;
	level.special_weapon_magicbox_check = ::buried_special_weapon_magicbox_check;
	if ( level.scr_zm_ui_gametype == "zclassic" )
	{
		level thread init_fountain_zone();
		level thread maps/mp/zm_buried_classic::generator_oil_lamp_control();
		level.ignore_equipment = ::ignore_equipment;
		level.ghost_zone_teleport_logic = ::buried_ghost_zone_teleport_logic;
		level.ghost_zone_fountain_teleport_logic = ::ghost_zone_fountain_teleport_logic;
		maps/mp/zombies/_zm_perk_vulture::add_additional_stink_locations_for_zone( "zone_bank", array( "zone_street_darkwest", "zone_gun_store" ) );
		level thread maps/mp/zombies/_zm::post_main();
	}
/#
	execdevgui( "devgui_zombie_buried" );
	level.custom_devgui = ::zombie_buried_devgui;
#/
	level thread maps/mp/zm_buried_ffotd::main_end();
}

buried_validate_enemy_path_length( player )
{
	max_dist = 1296;
	d = distancesquared( self.origin, player.origin );
	if ( d <= max_dist )
	{
		return 1;
	}
	return 0;
}

init_persistent_abilities()
{
	if ( is_classic() )
	{
		level.pers_upgrade_boards = 1;
		level.pers_upgrade_revive = 1;
		level.pers_upgrade_multi_kill_headshots = 1;
		level.pers_upgrade_cash_back = 1;
		level.pers_upgrade_insta_kill = 1;
		level.pers_upgrade_jugg = 1;
		level.pers_upgrade_carpenter = 1;
		level.pers_upgrade_flopper = 1;
		level.divetonuke_precache_override_func = ::maps/mp/zombies/_zm_pers_upgrades_functions::divetonuke_precache_override_func;
		level.pers_flopper_divetonuke_func = ::maps/mp/zombies/_zm_pers_upgrades_functions::pers_flopper_explode;
		level.pers_flopper_network_optimized = 1;
		level.pers_upgrade_sniper = 1;
		level.pers_upgrade_pistol_points = 1;
		level.pers_upgrade_perk_lose = 1;
		level.pers_upgrade_double_points = 1;
		level.pers_upgrade_box_weapon = 1;
		level.pers_magic_box_firesale = 1;
		level.pers_treasure_chest_get_weapons_array_func = ::pers_treasure_chest_get_weapons_array_buried;
		level.pers_upgrade_nube = 1;
	}
}

pers_treasure_chest_get_weapons_array_buried()
{
	if ( !isDefined( level.pers_box_weapons ) )
	{
		level.pers_box_weapons = [];
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "cymbal_monkey_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "ray_gun_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "raygun_mark2_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "slowgun_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "time_bomb_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "tar21_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "hamr_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "srm1216_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "knife_ballistic_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "galil_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "saiga12_zm";
	}
}

buried_custom_weapon_weights( keys )
{
	return keys;
}

buried_special_weapon_magicbox_check( weapon )
{
	if ( weapon == "ray_gun_zm" )
	{
		if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
		{
			return 0;
		}
	}
	if ( weapon == "raygun_mark2_zm" )
	{
		if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
		{
			return 0;
		}
	}
	while ( weapon == "time_bomb_zm" )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( is_player_valid( players[ i ], undefined, 1 ) && players[ i ] is_player_tactical_grenade( weapon ) )
			{
				return 0;
			}
			i++;
		}
	}
	return 1;
}

zombie_buried_devgui( cmd )
{
/#
	cmd_strings = strtok( cmd, " " );
	switch( cmd_strings[ 0 ] )
	{
		case "richtofen_street":
			level notify( "richtofen_street" );
			break;
		case "maxis_street":
			level notify( "maxis_street" );
			break;
		case "ghost_toggle_force_killable":
			if ( !isDefined( level.ghost_force_killable ) )
			{
				level.ghost_force_killable = 1;
			}
			else
			{
				level.ghost_force_killable = !level.ghost_force_killable;
			}
			break;
		case "ghost_toggle_debug":
			if ( !isDefined( level.ghost_debug ) )
			{
				level.ghost_debug = 1;
			}
			else
			{
				level.ghost_debug = !level.ghost_debug;
			}
			break;
		case "ghost_warp_to_mansion":
			if ( isDefined( level.ghost_devgui_warp_to_mansion ) )
			{
				[[ level.ghost_devgui_warp_to_mansion ]]();
			}
			break;
		case "ghost_toggle_no_ghost":
			if ( isDefined( level.ghost_devgui_toggle_no_ghost ) )
			{
				[[ level.ghost_devgui_toggle_no_ghost ]]();
			}
			break;
		case "spawn_vulture_stink":
			if ( isDefined( level.vulture_devgui_spawn_stink ) )
			{
				[[ level.vulture_devgui_spawn_stink ]]();
			}
			break;
		case "sloth_double_wide":
			if ( isDefined( level.sloth_devgui_double_wide ) )
			{
				[[ level.sloth_devgui_double_wide ]]();
			}
			break;
		case "sloth_destroy_barricade":
			if ( isDefined( level.sloth_devgui_barricade ) )
			{
				[[ level.sloth_devgui_barricade ]]();
			}
			break;
		case "sloth_toggle_doors":
			if ( !isDefined( level.sloth_debug_doors ) )
			{
				level.sloth_debug_doors = 1;
			}
			else
			{
				level.sloth_debug_doors = !level.sloth_debug_doors;
			}
			break;
		case "sloth_toggle_buildables":
			if ( !isDefined( level.sloth_debug_buildables ) )
			{
				level.sloth_debug_buildables = 1;
			}
			else
			{
				level.sloth_debug_buildables = !level.sloth_debug_buildables;
			}
			break;
		case "sloth_move_lamp":
			if ( isDefined( level.sloth_devgui_move_lamp ) )
			{
				[[ level.sloth_devgui_move_lamp ]]();
			}
			break;
		case "sloth_make_crawler":
			if ( isDefined( level.sloth_devgui_make_crawler ) )
			{
				[[ level.sloth_devgui_make_crawler ]]();
			}
			break;
		case "sloth_teleport":
			if ( isDefined( level.sloth_devgui_teleport ) )
			{
				[[ level.sloth_devgui_teleport ]]();
			}
			break;
		case "sloth_drink_booze":
			if ( isDefined( level.sloth_devgui_booze ) )
			{
				[[ level.sloth_devgui_booze ]]();
			}
			break;
		case "sloth_eat_candy":
			if ( isDefined( level.sloth_devgui_candy ) )
			{
				[[ level.sloth_devgui_candy ]]();
			}
			break;
		case "sloth_context":
			if ( isDefined( level.sloth_devgui_context ) )
			{
				[[ level.sloth_devgui_context ]]();
			}
			break;
		case "sloth_warp_to_jail":
			if ( isDefined( level.sloth_devgui_warp_to_jail ) )
			{
				[[ level.sloth_devgui_warp_to_jail ]]();
			}
			break;
		case "lights_on":
			level notify( "generator_lights_on" );
			break;
		case "sloth_open":
			level notify( "open_sloth_barricades" );
			level notify( "courtyard_fountain_open" );
			break;
		case "cell_open":
			level notify( "cell_open" );
			if ( isDefined( level.jail_open_door ) )
			{
				[[ level.jail_open_door ]]();
			}
			break;
		case "cell_close":
			level notify( "cell_close" );
			if ( isDefined( level.jail_close_door ) )
			{
				[[ level.jail_close_door ]]();
			}
			break;
		case "pick_up_keys":
			thread pick_up( "keys_zm" );
			break;
		case "pick_up_candy":
			if ( isDefined( level.jail_barricade_down ) && !level.jail_barricade_down )
			{
				level notify( "jail_barricade_down" );
				wait 0,05;
			}
			thread pick_up( "candy" );
			break;
		case "pick_up_booze":
			thread pick_up( "booze" );
			break;
		case "bell_ring":
			players = get_players();
			bells = getentarray( "church_bell", "targetname" );
			bell_ring( players[ 0 ], bells[ 0 ] );
			break;
		case "destroy_sloth_fountain":
			level notify( "courtyard_fountain_open" );
			break;
		case "destroy_maze_fountain":
			level notify( "_destroy_maze_fountain" );
			break;
		case "warp_player_to_maze_fountain":
			level notify( "warp_player_to_maze_fountain" );
			break;
		case "warp_player_to_courtyard_fountain":
			level notify( "warp_player_to_courtyard_fountain" );
			break;
		case "blue_monkey":
		case "green_ammo":
		case "green_double":
		case "green_insta":
		case "green_monkey":
		case "green_nuke":
		case "red_ammo":
		case "red_double":
		case "red_nuke":
		case "yellow_double":
		case "yellow_nuke":
			maps/mp/zombies/_zm_devgui::zombie_devgui_give_powerup( cmd_strings[ 0 ], 1 );
			break;
		case "slow_test":
			maps/mp/zombies/_zm_weap_time_bomb::slow_all_actors();
			thread maps/mp/zombies/_zm_weap_time_bomb::all_actors_resume_speed();
			flag_set( "time_bomb_enemies_restored" );
			case "catwalk_keep":
				level notify( "catwalk_collapsed" );
				break;
			case "start_ghost_piano":
				flag_set( "player_piano_song_active" );
				level notify( "player_can_interact_with_ghost_piano_player" );
				break;
			case "ghost_piano_warp_to_mansion_piano":
				level notify( "ghost_piano_warp_to_mansion_piano" );
				break;
			case "ghost_piano_warp_to_bar":
				level notify( "ghost_piano_warp_to_bar" );
				break;
			default:
			}
#/
		}
	}
}

pick_up( thing )
{
/#
	players = get_players();
	_a885 = players;
	_k885 = getFirstArrayKey( _a885 );
	while ( isDefined( _k885 ) )
	{
		player = _a885[ _k885 ];
		if ( isDefined( player player_get_buildable_piece( 1 ) ) && player player_get_buildable_piece( 1 ).buildablename == thing )
		{
		}
		else
		{
			candidate_list = [];
			_a892 = level.zones;
			_k892 = getFirstArrayKey( _a892 );
			while ( isDefined( _k892 ) )
			{
				zone = _a892[ _k892 ];
				if ( isDefined( zone.unitrigger_stubs ) )
				{
					candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
				}
				_k892 = getNextArrayKey( _a892, _k892 );
			}
			_a901 = candidate_list;
			_k901 = getFirstArrayKey( _a901 );
			while ( isDefined( _k901 ) )
			{
				stub = _a901[ _k901 ];
				if ( isDefined( stub.piece ) && stub.piece.buildablename == thing )
				{
					player thread maps/mp/zombies/_zm_buildables::player_take_piece( stub.piece );
					break;
				}
				else
				{
					_k901 = getNextArrayKey( _a901, _k901 );
				}
			}
			if ( isDefined( player player_get_buildable_piece( 1 ) ) && player player_get_buildable_piece( 1 ).buildablename == thing )
			{
				break;
			}
			else
			{
				level notify( "player_purchase_" + thing );
			}
		}
		_k885 = getNextArrayKey( _a885, _k885 );
#/
	}
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
}

precache_team_characters()
{
	precachemodel( "c_zom_player_cdc_dlc1_fb" );
	precachemodel( "c_zom_hazmat_viewhands" );
	precachemodel( "c_zom_player_cia_dlc1_fb" );
	precachemodel( "c_zom_suit_viewhands" );
}

give_team_characters()
{
	self detachall();
	self set_player_is_female( 0 );
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = 1;
		if ( self.team == "axis" )
		{
			self.characterindex = 0;
		}
	}
	switch( self.characterindex )
	{
		case 0:
		case 2:
			self setmodel( "c_zom_player_cia_dlc1_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_suit_viewhands" );
			self.characterindex = 0;
			break;
		case 1:
		case 3:
			self setmodel( "c_zom_player_cdc_dlc1_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_hazmat_viewhands" );
			self.characterindex = 1;
			break;
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}

initcharacterstartindex()
{
	level.characterstartindex = randomint( 4 );
}

precache_personality_characters()
{
	character/c_transit_player_farmgirl::precache();
	character/c_transit_player_oldman::precache();
	character/c_transit_player_engineer::precache();
	character/c_buried_player_reporter_dam::precache();
	precachemodel( "c_zom_farmgirl_viewhands" );
	precachemodel( "c_zom_oldman_viewhands" );
	precachemodel( "c_zom_engineer_viewhands" );
	precachemodel( "c_zom_reporter_viewhands" );
}

give_personality_characters()
{
	if ( isDefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_farmgirl_viewhands" ) )
	{
		return;
	}
	self detachall();
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = assign_lowest_unused_character_index();
	}
	self.favorite_wall_weapons_list = [];
	self.talks_in_danger = 0;
/#
	if ( getDvar( #"40772CF1" ) != "" )
	{
		self.characterindex = getDvarInt( #"40772CF1" );
#/
	}
	switch( self.characterindex )
	{
		case 2:
			self character/c_transit_player_farmgirl::main();
			self setviewmodel( "c_zom_farmgirl_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "rottweil72_zm";
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "870mcs_zm";
			self set_player_is_female( 1 );
			break;
		case 0:
			self character/c_transit_player_oldman::main();
			self setviewmodel( "c_zom_oldman_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "frag_grenade_zm";
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "claymore_zm";
			self set_player_is_female( 0 );
			break;
		case 3:
			self character/c_transit_player_engineer::main();
			self setviewmodel( "c_zom_engineer_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m14_zm";
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m16_zm";
			self set_player_is_female( 0 );
			break;
		case 1:
			self character/c_buried_player_reporter_dam::main();
			self setviewmodel( "c_zom_reporter_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.talks_in_danger = 1;
			level.rich_sq_player = self;
			self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "beretta93r_zm";
			self set_player_is_female( 0 );
			break;
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self thread set_exert_id();
}

set_exert_id()
{
	self endon( "disconnect" );
	wait_network_frame();
	wait_network_frame();
	self maps/mp/zombies/_zm_audio::setexertvoice( self.characterindex + 1 );
}

setup_personality_character_exerts()
{
	level.exert_sounds[ 1 ][ "burp" ][ 0 ] = "vox_plr_0_exert_burp_0";
	level.exert_sounds[ 1 ][ "burp" ][ 1 ] = "vox_plr_0_exert_burp_1";
	level.exert_sounds[ 1 ][ "burp" ][ 2 ] = "vox_plr_0_exert_burp_2";
	level.exert_sounds[ 1 ][ "burp" ][ 3 ] = "vox_plr_0_exert_burp_3";
	level.exert_sounds[ 1 ][ "burp" ][ 4 ] = "vox_plr_0_exert_burp_4";
	level.exert_sounds[ 1 ][ "burp" ][ 5 ] = "vox_plr_0_exert_burp_5";
	level.exert_sounds[ 1 ][ "burp" ][ 6 ] = "vox_plr_0_exert_burp_6";
	level.exert_sounds[ 2 ][ "burp" ][ 0 ] = "vox_plr_1_exert_burp_0";
	level.exert_sounds[ 2 ][ "burp" ][ 1 ] = "vox_plr_1_exert_burp_1";
	level.exert_sounds[ 2 ][ "burp" ][ 2 ] = "vox_plr_1_exert_burp_2";
	level.exert_sounds[ 2 ][ "burp" ][ 3 ] = "vox_plr_1_exert_burp_3";
	level.exert_sounds[ 3 ][ "burp" ][ 0 ] = "vox_plr_2_exert_burp_0";
	level.exert_sounds[ 3 ][ "burp" ][ 1 ] = "vox_plr_2_exert_burp_1";
	level.exert_sounds[ 3 ][ "burp" ][ 2 ] = "vox_plr_2_exert_burp_2";
	level.exert_sounds[ 3 ][ "burp" ][ 3 ] = "vox_plr_2_exert_burp_3";
	level.exert_sounds[ 3 ][ "burp" ][ 4 ] = "vox_plr_2_exert_burp_4";
	level.exert_sounds[ 3 ][ "burp" ][ 5 ] = "vox_plr_2_exert_burp_5";
	level.exert_sounds[ 3 ][ "burp" ][ 6 ] = "vox_plr_2_exert_burp_6";
	level.exert_sounds[ 4 ][ "burp" ][ 0 ] = "vox_plr_3_exert_burp_0";
	level.exert_sounds[ 4 ][ "burp" ][ 1 ] = "vox_plr_3_exert_burp_1";
	level.exert_sounds[ 4 ][ "burp" ][ 2 ] = "vox_plr_3_exert_burp_2";
	level.exert_sounds[ 4 ][ "burp" ][ 3 ] = "vox_plr_3_exert_burp_3";
	level.exert_sounds[ 4 ][ "burp" ][ 4 ] = "vox_plr_3_exert_burp_4";
	level.exert_sounds[ 4 ][ "burp" ][ 5 ] = "vox_plr_3_exert_burp_5";
	level.exert_sounds[ 4 ][ "burp" ][ 6 ] = "vox_plr_3_exert_burp_6";
	level.exert_sounds[ 1 ][ "hitmed" ][ 0 ] = "vox_plr_0_exert_pain_medium_0";
	level.exert_sounds[ 1 ][ "hitmed" ][ 1 ] = "vox_plr_0_exert_pain_medium_1";
	level.exert_sounds[ 1 ][ "hitmed" ][ 2 ] = "vox_plr_0_exert_pain_medium_2";
	level.exert_sounds[ 1 ][ "hitmed" ][ 3 ] = "vox_plr_0_exert_pain_medium_3";
	level.exert_sounds[ 2 ][ "hitmed" ][ 0 ] = "vox_plr_1_exert_pain_medium_0";
	level.exert_sounds[ 2 ][ "hitmed" ][ 1 ] = "vox_plr_1_exert_pain_medium_1";
	level.exert_sounds[ 2 ][ "hitmed" ][ 2 ] = "vox_plr_1_exert_pain_medium_2";
	level.exert_sounds[ 2 ][ "hitmed" ][ 3 ] = "vox_plr_1_exert_pain_medium_3";
	level.exert_sounds[ 3 ][ "hitmed" ][ 0 ] = "vox_plr_2_exert_pain_medium_0";
	level.exert_sounds[ 3 ][ "hitmed" ][ 1 ] = "vox_plr_2_exert_pain_medium_1";
	level.exert_sounds[ 3 ][ "hitmed" ][ 2 ] = "vox_plr_2_exert_pain_medium_2";
	level.exert_sounds[ 3 ][ "hitmed" ][ 3 ] = "vox_plr_2_exert_pain_medium_3";
	level.exert_sounds[ 4 ][ "hitmed" ][ 0 ] = "vox_plr_3_exert_pain_medium_0";
	level.exert_sounds[ 4 ][ "hitmed" ][ 1 ] = "vox_plr_3_exert_pain_medium_1";
	level.exert_sounds[ 4 ][ "hitmed" ][ 2 ] = "vox_plr_3_exert_pain_medium_2";
	level.exert_sounds[ 4 ][ "hitmed" ][ 3 ] = "vox_plr_3_exert_pain_medium_3";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 0 ] = "vox_plr_0_exert_pain_high_0";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 1 ] = "vox_plr_0_exert_pain_high_1";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 2 ] = "vox_plr_0_exert_pain_high_2";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 3 ] = "vox_plr_0_exert_pain_high_3";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 0 ] = "vox_plr_1_exert_pain_high_0";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 1 ] = "vox_plr_1_exert_pain_high_1";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 2 ] = "vox_plr_1_exert_pain_high_2";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 3 ] = "vox_plr_1_exert_pain_high_3";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 0 ] = "vox_plr_2_exert_pain_high_0";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 1 ] = "vox_plr_2_exert_pain_high_1";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 2 ] = "vox_plr_2_exert_pain_high_2";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 3 ] = "vox_plr_2_exert_pain_high_3";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 0 ] = "vox_plr_3_exert_pain_high_0";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 1 ] = "vox_plr_3_exert_pain_high_1";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 2 ] = "vox_plr_3_exert_pain_high_2";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 3 ] = "vox_plr_3_exert_pain_high_3";
}

assign_lowest_unused_character_index()
{
	charindexarray = [];
	charindexarray[ 0 ] = 0;
	charindexarray[ 1 ] = 1;
	charindexarray[ 2 ] = 2;
	charindexarray[ 3 ] = 3;
	players = get_players();
	if ( players.size == 1 )
	{
		charindexarray = array_randomize( charindexarray );
		return charindexarray[ 0 ];
	}
	else
	{
		if ( players.size == 2 )
		{
			_a1190 = players;
			_k1190 = getFirstArrayKey( _a1190 );
			while ( isDefined( _k1190 ) )
			{
				player = _a1190[ _k1190 ];
				if ( isDefined( player.characterindex ) )
				{
					if ( player.characterindex == 2 || player.characterindex == 0 )
					{
						if ( randomint( 100 ) > 50 )
						{
							return 1;
						}
						return 3;
					}
					else
					{
						if ( player.characterindex == 3 || player.characterindex == 1 )
						{
							if ( randomint( 100 ) > 50 )
							{
								return 0;
							}
							return 2;
						}
					}
				}
				_k1190 = getNextArrayKey( _a1190, _k1190 );
			}
		}
		else _a1216 = players;
		_k1216 = getFirstArrayKey( _a1216 );
		while ( isDefined( _k1216 ) )
		{
			player = _a1216[ _k1216 ];
			if ( isDefined( player.characterindex ) )
			{
				arrayremovevalue( charindexarray, player.characterindex, 0 );
			}
			_k1216 = getNextArrayKey( _a1216, _k1216 );
		}
		if ( charindexarray.size > 0 )
		{
			return charindexarray[ 0 ];
		}
	}
	return 0;
}

zm_player_fake_death_cleanup()
{
	if ( isDefined( self._fall_down_anchor ) )
	{
		self._fall_down_anchor delete();
		self._fall_down_anchor = undefined;
	}
}

zm_player_fake_death( vdir )
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	stance = self getstance();
	self.ignoreme = 1;
	self enableinvulnerability();
	self takeallweapons();
	if ( isDefined( self.insta_killed ) && self.insta_killed )
	{
		self maps/mp/zombies/_zm::player_fake_death();
		self allowprone( 1 );
		self allowcrouch( 0 );
		self allowstand( 0 );
		wait 0,25;
		self freezecontrols( 1 );
	}
	else
	{
		self freezecontrols( 1 );
		self thread fall_down( vdir, stance );
		wait 1;
	}
}

fall_down( vdir, stance )
{
	self endon( "disconnect" );
	level endon( "game_module_ended" );
	self ghost();
	origin = self.origin;
	xyspeed = ( 0, 0, 0 );
	angles = self getplayerangles();
	angles = ( angles[ 0 ], angles[ 1 ], angles[ 2 ] + randomfloatrange( -5, 5 ) );
	if ( isDefined( vdir ) && length( vdir ) > 0 )
	{
		xyspeedmag = 40 + randomint( 12 ) + randomint( 12 );
		xyspeed = xyspeedmag * vectornormalize( ( vdir[ 0 ], vdir[ 1 ], 0 ) );
	}
	linker = spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = origin;
	linker.angles = angles;
	self._fall_down_anchor = linker;
	self playerlinkto( linker );
	self playsoundtoplayer( "zmb_player_death_fall", self );
	falling = stance != "prone";
	if ( falling )
	{
		origin = playerphysicstrace( origin, origin + xyspeed );
		eye = self get_eye();
		floor_height = ( 10 + origin[ 2 ] ) - eye[ 2 ];
		origin += ( 0, 0, floor_height );
		lerptime = 0,5;
		linker moveto( origin, lerptime, lerptime );
		linker rotateto( angles, lerptime, lerptime );
	}
	self freezecontrols( 1 );
	if ( falling )
	{
		linker waittill( "movedone" );
	}
	self giveweapon( "death_throe_zm" );
	self switchtoweapon( "death_throe_zm" );
	if ( falling )
	{
		bounce = randomint( 4 ) + 8;
		origin = ( origin + ( 0, 0, bounce ) ) - ( xyspeed * 0,1 );
		lerptime = bounce / 50;
		linker moveto( origin, lerptime, 0, lerptime );
		linker waittill( "movedone" );
		origin = ( origin + ( 0, 0, bounce * -1 ) ) + ( xyspeed * 0,1 );
		lerptime /= 2;
		linker moveto( origin, lerptime, lerptime );
		linker waittill( "movedone" );
		linker moveto( origin, 5, 0 );
	}
	wait 15;
	linker delete();
}

initial_round_wait_func()
{
	flag_wait( "initial_blackscreen_passed" );
}

offhand_weapon_overrride()
{
	register_lethal_grenade_for_level( "frag_grenade_zm" );
	level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
	register_tactical_grenade_for_level( "cymbal_monkey_zm" );
	register_tactical_grenade_for_level( "emp_grenade_zm" );
	register_placeable_mine_for_level( "claymore_zm" );
	register_melee_weapon_for_level( "knife_zm" );
	register_melee_weapon_for_level( "bowie_knife_zm" );
	register_melee_weapon_for_level( "tazer_knuckles_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm";
	register_equipment_for_level( "equip_turbine_zm" );
	register_equipment_for_level( "equip_springpad_zm" );
	register_equipment_for_level( "equip_subwoofer_zm" );
	register_equipment_for_level( "equip_headchopper_zm" );
	level.zombie_equipment_player_init = undefined;
}

offhand_weapon_give_override( str_weapon )
{
	self endon( "death" );
	if ( is_tactical_grenade( str_weapon ) && isDefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( str_weapon ) )
	{
		self setweaponammoclip( self get_player_tactical_grenade(), 0 );
		self takeweapon( self get_player_tactical_grenade() );
	}
	return 0;
}

init_buried_stats()
{
	self maps/mp/zm_buried_sq::init_player_sidequest_stats();
	self maps/mp/zm_buried_achievement::init_player_achievement_stats();
}

init_level_specific_wall_buy_fx()
{
	level._effect[ "an94_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_an94" );
	level._effect[ "pdw57_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_pdw57" );
	level._effect[ "svu_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_svuas" );
	level._effect[ "lsat_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_lsat" );
	level._effect[ "tazer_knuckles_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_buried_buy_taseknuck" );
	level._effect[ "tazer_knuckles_zm_chalk_fx" ] = loadfx( "maps/zombie/fx_zmb_buried_dyn_taseknuck" );
	level._effect[ "870mcs_zm_chalk_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_dyn_870mcs" );
	level._effect[ "ak74u_zm_chalk_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_dyn_ak74u" );
	level._effect[ "an94_zm_chalk_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_dyn_an94" );
	level._effect[ "pdw57_zm_chalk_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_dyn_pdw57" );
	level._effect[ "svu_zm_chalk_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_dyn_svuas" );
}

custom_add_weapons()
{
	gametype = getDvar( "ui_gametype" );
	add_zombie_weapon( "m1911_zm", "m1911_upgraded_zm", &"ZOMBIE_WEAPON_M1911", 50, "", "", undefined );
	add_zombie_weapon( "rnma_zm", "rnma_upgraded_zm", &"ZOMBIE_WEAPON_RNMA", 50, "pickup_six_shooter", "", undefined, 1 );
	add_zombie_weapon( "judge_zm", "judge_upgraded_zm", &"ZOMBIE_WEAPON_JUDGE", 50, "wpck_judge", "", undefined, 1 );
	add_zombie_weapon( "kard_zm", "kard_upgraded_zm", &"ZOMBIE_WEAPON_KARD", 50, "wpck_kap", "", undefined, 1 );
	add_zombie_weapon( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 50, "wpck_57", "", undefined, 1 );
	add_zombie_weapon( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "", "", undefined );
	add_zombie_weapon( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_duel57", "", undefined, 1 );
	add_zombie_weapon( "ak74u_zm", "ak74u_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "smg", "", undefined );
	add_zombie_weapon( "mp5k_zm", "mp5k_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1000, "smg", "", undefined );
	add_zombie_weapon( "pdw57_zm", "pdw57_upgraded_zm", &"ZOMBIE_WEAPON_PDW57", 1000, "smg", "", undefined );
	if ( gametype == "zcleansed" )
	{
		add_zombie_weapon( "qcw05_zm", undefined, &"ZOMBIE_WEAPON_QCW05", 50, "wpck_chicom", "", undefined, 1 );
	}
	add_zombie_weapon( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 1500, "shotgun", "", undefined );
	add_zombie_weapon( "rottweil72_zm", "rottweil72_upgraded_zm", &"ZOMBIE_WEAPON_ROTTWEIL72", 500, "shotgun", "", undefined );
	add_zombie_weapon( "saiga12_zm", "saiga12_upgraded_zm", &"ZOMBIE_WEAPON_SAIGA12", 50, "wpck_saiga12", "", undefined, 1 );
	add_zombie_weapon( "srm1216_zm", "srm1216_upgraded_zm", &"ZOMBIE_WEAPON_SRM1216", 50, "wpck_m1216", "", undefined, 1 );
	add_zombie_weapon( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "rifle", "", undefined );
	add_zombie_weapon( "saritch_zm", "saritch_upgraded_zm", &"ZOMBIE_WEAPON_SARITCH", 50, "wpck_smr", "", undefined, 1 );
	add_zombie_weapon( "m16_zm", "m16_gl_upgraded_zm", &"ZOMBIE_WEAPON_M16", 1200, "burstrifle", "", undefined );
	add_zombie_weapon( "tar21_zm", "tar21_upgraded_zm", &"ZOMBIE_WEAPON_TAR21", 50, "wpck_mtar", "", undefined, 1 );
	add_zombie_weapon( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_galil", "", undefined, 1 );
	add_zombie_weapon( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_fal", "", undefined, 1 );
	add_zombie_weapon( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_dsr50", "", undefined, 1 );
	add_zombie_weapon( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "wpck_m82a1", "", undefined, 1 );
	add_zombie_weapon( "svu_zm", "svu_upgraded_zm", &"ZOMBIE_WEAPON_SVU", 1000, "wpck_svuas", "", undefined, 1 );
	add_zombie_weapon( "lsat_zm", "lsat_upgraded_zm", &"ZOMBIE_WEAPON_LSAT", 2000, "wpck_lsat", "", undefined, 1 );
	add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_hamr", "", undefined, 1 );
	add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
	add_zombie_weapon( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1000, "grenade", "", undefined );
	add_zombie_weapon( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_m32", "", undefined, 1 );
	add_zombie_weapon( "an94_zm", "an94_upgraded_zm", &"ZOMBIE_WEAPON_AN94", 1200, "", "", undefined );
	add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
	add_zombie_weapon( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "pickup_raymk2", "", undefined, 1 );
	add_zombie_weapon( "knife_ballistic_zm", "knife_ballistic_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined, 1 );
	add_zombie_weapon( "knife_ballistic_bowie_zm", "knife_ballistic_bowie_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined, 1 );
	add_zombie_weapon( "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined, 1 );
	add_zombie_weapon( "tazer_knuckles_zm", undefined, &"ZOMBIE_WEAPON_TAZER_KNUCKLES", 100, "tazerknuckles", "", undefined );
	add_zombie_weapon( "slowgun_zm", "slowgun_upgraded_zm", &"ZOMBIE_WEAPON_SLOWGUN", 10, "wpck_paralyzer", "", undefined, 1 );
}

less_than_normal()
{
	return 0,5;
}

include_weapons()
{
	gametype = getDvar( "ui_gametype" );
	include_weapon( "knife_zm", 0 );
	include_weapon( "frag_grenade_zm", 0 );
	include_weapon( "claymore_zm", 0 );
	include_weapon( "m1911_zm", 0 );
	include_weapon( "m1911_upgraded_zm", 0 );
	include_weapon( "rnma_zm" );
	include_weapon( "rnma_upgraded_zm", 0 );
	include_weapon( "judge_zm" );
	include_weapon( "judge_upgraded_zm", 0 );
	include_weapon( "kard_zm" );
	include_weapon( "kard_upgraded_zm", 0 );
	include_weapon( "fiveseven_zm" );
	include_weapon( "fiveseven_upgraded_zm", 0 );
	include_weapon( "beretta93r_zm", 0 );
	include_weapon( "beretta93r_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "ak74u_zm", 0 );
	include_weapon( "ak74u_upgraded_zm", 0 );
	include_weapon( "mp5k_zm", 0 );
	include_weapon( "mp5k_upgraded_zm", 0 );
	if ( gametype == "zcleansed" )
	{
		include_weapon( "qcw05_zm" );
	}
	include_weapon( "870mcs_zm", 0 );
	include_weapon( "870mcs_upgraded_zm", 0 );
	include_weapon( "rottweil72_zm", 0 );
	include_weapon( "rottweil72_upgraded_zm", 0 );
	include_weapon( "saiga12_zm" );
	include_weapon( "saiga12_upgraded_zm", 0 );
	include_weapon( "srm1216_zm" );
	include_weapon( "srm1216_upgraded_zm", 0 );
	include_weapon( "m14_zm", 0 );
	include_weapon( "m14_upgraded_zm", 0 );
	include_weapon( "saritch_zm" );
	include_weapon( "saritch_upgraded_zm", 0 );
	include_weapon( "m16_zm", 0 );
	include_weapon( "m16_gl_upgraded_zm", 0 );
	include_weapon( "tar21_zm" );
	include_weapon( "tar21_upgraded_zm", 0 );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", 0 );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", 0 );
	include_weapon( "dsr50_zm" );
	include_weapon( "dsr50_upgraded_zm", 0 );
	include_weapon( "barretm82_zm" );
	include_weapon( "barretm82_upgraded_zm", 0 );
	include_weapon( "svu_zm", 0 );
	include_weapon( "svu_upgraded_zm", 0 );
	include_weapon( "lsat_zm", 0 );
	include_weapon( "lsat_upgraded_zm", 0 );
	include_weapon( "hamr_zm" );
	include_weapon( "hamr_upgraded_zm", 0 );
	include_weapon( "pdw57_zm", 0 );
	include_weapon( "pdw57_upgraded_zm", 0 );
	include_weapon( "usrpg_zm" );
	include_weapon( "usrpg_upgraded_zm", 0 );
	include_weapon( "m32_zm" );
	include_weapon( "m32_upgraded_zm", 0 );
	include_weapon( "an94_zm", 0 );
	include_weapon( "an94_upgraded_zm", 0 );
	include_weapon( "cymbal_monkey_zm" );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", 0 );
	include_weapon( "raygun_mark2_zm", 1 );
	include_weapon( "raygun_mark2_upgraded_zm", 0 );
	include_weapon( "slowgun_zm", 1 );
	include_weapon( "slowgun_upgraded_zm", 0 );
	include_weapon( "tazer_knuckles_zm", 0 );
	include_weapon( "knife_ballistic_no_melee_zm", 0 );
	include_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
	include_weapon( "knife_ballistic_zm" );
	include_weapon( "knife_ballistic_upgraded_zm", 0 );
	include_weapon( "knife_ballistic_bowie_zm", 0 );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );
	level._uses_retrievable_ballisitic_knives = 1;
	add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
	add_limited_weapon( "m1911_zm", 0 );
	add_limited_weapon( "knife_ballistic_zm", 1 );
	add_limited_weapon( "slowgun_zm", 1 );
	add_limited_weapon( "slowgun_upgraded_zm", 1 );
	add_limited_weapon( "ray_gun_zm", 4 );
	add_limited_weapon( "ray_gun_upgraded_zm", 4 );
	add_limited_weapon( "knife_ballistic_upgraded_zm", 0 );
	add_limited_weapon( "knife_ballistic_no_melee_zm", 0 );
	add_limited_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
	add_limited_weapon( "knife_ballistic_bowie_zm", 0 );
	add_limited_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );
	add_limited_weapon( "raygun_mark2_zm", 4 );
	add_limited_weapon( "raygun_mark2_upgraded_zm", 4 );
	add_weapon_locker_mapping( "python_zm", "rnma_zm" );
	add_weapon_locker_mapping( "qcw05_zm", "pdw57_zm" );
	add_weapon_locker_mapping( "xm8_zm", "tar21_zm" );
	add_weapon_locker_mapping( "type95_zm", "tar21_zm" );
	add_weapon_locker_mapping( "rpd_zm", "galil_zm" );
	add_weapon_locker_mapping( "python_upgraded_zm", "rnma_upgraded_zm" );
	add_weapon_locker_mapping( "qcw05_upgraded_zm", "pdw57_upgraded_zm" );
	add_weapon_locker_mapping( "xm8_upgraded_zm", "tar21_upgraded_zm" );
	add_weapon_locker_mapping( "type95_upgraded_zm", "tar21_upgraded_zm" );
	add_weapon_locker_mapping( "rpd_upgraded_zm", "galil_upgraded_zm" );
}

include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "carpenter" );
	include_powerup( "fire_sale" );
	include_powerup( "teller_withdrawl" );
	include_powerup( "free_perk" );
	include_powerup( "insta_kill_ug" );
	include_powerup( "random_weapon" );
}

add_buried_powerups()
{
	maps/mp/zombies/_zm_powerups::add_zombie_powerup( "teller_withdrawl", "zombie_z_money_icon", &"ZOMBIE_TELLER_PICKUP_DEPOSIT", ::maps/mp/zombies/_zm_powerups::func_should_never_drop, 1, 0, 0 );
}

zombie_init_done()
{
	self.allowpain = 0;
	self.zombie_path_bad = 0;
	self thread maps/mp/zm_buried_distance_tracking::escaped_zombies_cleanup_init();
}

include_equipment_for_level()
{
	level.equipment_subwoofer_needs_power = 1;
	include_equipment( "equip_turbine_zm" );
	include_equipment( "equip_springpad_zm" );
	include_equipment( "equip_subwoofer_zm" );
	include_equipment( "equip_headchopper_zm" );
	level.equipment_planted = ::equipment_planted;
	level.equipment_safe_to_drop = ::equipment_safe_to_drop;
}

setup_rex_starts()
{
	add_gametype( "zclassic", ::dummy, "zclassic", ::dummy );
	add_gametype( "zcleansed", ::dummy, "zcleansed", ::dummy );
	add_gametype( "zgrief", ::dummy, "zgrief", ::dummy );
	add_gameloc( "processing", ::dummy, "processing", ::dummy );
	add_gameloc( "street", ::dummy, "street", ::dummy );
}

dummy()
{
}

buried_zone_init()
{
	flag_init( "always_on" );
	flag_set( "always_on" );
	add_adjacent_zone( "zone_tunnels_center", "zone_tunnels_north", "always_on" );
	add_adjacent_zone( "zone_tunnels_north", "zone_tunnels_north2", "tunnels2courthouse" );
	add_adjacent_zone( "zone_tunnels_south", "zone_tunnels_south2", "tunnel2saloon" );
	add_adjacent_zone( "zone_tunnels_south3", "zone_tunnels_south2", "always_on" );
	add_adjacent_zone( "zone_tunnels_center", "zone_tunnels_south", "always_on" );
	add_adjacent_zone( "zone_street_lightwest", "zone_general_store", "general_store_door1" );
	add_adjacent_zone( "zone_street_lighteast", "zone_general_store", "always_on" );
	add_adjacent_zone( "zone_street_darkwest", "zone_general_store", "general_store_door2" );
	add_adjacent_zone( "zone_street_lightwest", "zone_morgue_upstairs", "always_on" );
	add_adjacent_zone( "zone_street_fountain", "zone_mansion_lawn", "mansion_lawn_door1" );
	add_adjacent_zone( "zone_street_darkwest", "zone_gun_store", "gun_store_door1" );
	add_adjacent_zone( "zone_stables", "zone_street_lightwest", "always_on", 1 );
	add_adjacent_zone( "zone_street_darkwest", "zone_street_darkwest_nook", "darkwest_nook_door1" );
	add_adjacent_zone( "zone_street_darkwest", "zone_general_store", "general_store_door3" );
	add_adjacent_zone( "zone_street_darkwest_nook", "zone_stables", "stables_door2" );
	add_adjacent_zone( "zone_street_darkeast", "zone_underground_bar", "bar_door1" );
	add_adjacent_zone( "zone_street_darkeast", "zone_street_darkeast_nook", "always_on" );
	add_adjacent_zone( "zone_underground_courthouse2", "zone_underground_courthouse", "always_on" );
	add_adjacent_zone( "zone_street_lighteast", "zone_underground_courthouse", "courthouse_door1" );
	add_adjacent_zone( "zone_street_lightwest", "zone_underground_jail", "jail_door1" );
	add_adjacent_zone( "zone_street_lightwest", "zone_street_lightwest_alley", "jail_jugg" );
	add_adjacent_zone( "zone_underground_jail", "zone_underground_jail2", "always_on" );
	add_adjacent_zone( "zone_underground_jail2", "zone_street_lightwest", "always_on" );
	add_adjacent_zone( "zone_street_lighteast", "zone_candy_store", "candy_store_door1" );
	add_adjacent_zone( "zone_candy_store", "zone_candy_store_floor2", "always_on" );
	add_adjacent_zone( "zone_toy_store_floor2", "zone_candy_store_floor2", "always_on" );
	add_adjacent_zone( "zone_toy_store", "zone_toy_store_floor2", "always_on" );
	add_adjacent_zone( "zone_street_darkeast", "zone_toy_store_floor2", "always_on" );
	add_adjacent_zone( "zone_street_darkeast", "zone_toy_store", "candy_store_door2" );
	add_adjacent_zone( "zone_street_lighteast", "zone_candy_store_floor2", "candy2lighteast", 1 );
	add_adjacent_zone( "zone_street_darkeast", "zone_candy_store_floor2", "always_on", 1 );
	add_adjacent_zone( "zone_toy_store_tunnel", "zone_toy_store_floor2", "always_on", 1 );
	add_adjacent_zone( "zone_street_lighteast", "zone_street_fountain", "always_on" );
	add_adjacent_zone( "zone_street_fountain", "zone_church_graveyard", "always_on" );
	add_adjacent_zone( "zone_church_graveyard", "zone_church_main", "church_door1" );
	add_adjacent_zone( "zone_church_main", "zone_church_upstairs", "church_door1" );
	add_adjacent_zone( "zone_gun_store", "zone_tunnel_gun2stables", "gunshop2tunnel" );
	add_adjacent_zone( "zone_tunnel_gun2saloon", "zone_underground_bar", "always_on" );
	add_adjacent_zone( "zone_maze", "zone_mansion_backyard", "mansion_door1", 1 );
	add_adjacent_zone( "zone_maze", "zone_maze_staircase", "mansion_door1", 1 );
	add_adjacent_zone( "zone_stables", "zone_tunnel_gun2stables2", "always_on" );
	add_adjacent_zone( "zone_tunnel_gun2stables2", "zone_tunnel_gun2stables", "always_on" );
}

init_turned_zones()
{
	a_zones = array( "zone_street_lighteast", "zone_street_lightwest", "zone_street_darkeast", "zone_street_darkwest", "zone_church_main", "zone_church_upstairs", "zone_mansion", "zone_candy_store", "zone_candy_store_floor2", "zone_underground_courthouse", "zone_underground_jail", "zone_underground_jail2", "zone_toy_store", "zone_toy_store_floor2", "zone_underground_bar", "zone_gun_store", "zone_stables", "zone_bank", "zone_general_store", "zone_morgue_upstairs" );
	_a1796 = a_zones;
	_k1796 = getFirstArrayKey( _a1796 );
	while ( isDefined( _k1796 ) )
	{
		zone = _a1796[ _k1796 ];
		zone_init( zone );
		enable_zone( zone );
		_k1796 = getNextArrayKey( _a1796, _k1796 );
	}
}

init_fountain_zone()
{
	flag_wait( "fountain_transport_active" );
	if ( !isDefined( level.snd_ent ) )
	{
		level.snd_ent = spawn( "script_origin", ( 4918, 575, 11 ) );
		level.snd_ent playloopsound( "amb_water_vortex", 1 );
	}
	zone_volumes = getentarray( "zone_start_lower", "targetname" );
	_a1816 = zone_volumes;
	_k1816 = getFirstArrayKey( _a1816 );
	while ( isDefined( _k1816 ) )
	{
		zone = _a1816[ _k1816 ];
		zone.script_noteworthy = "player_volume";
		_k1816 = getNextArrayKey( _a1816, _k1816 );
	}
}

buried_ghost_zone_teleport_logic()
{
	if ( isDefined( level.zombie_ghost_round_states.is_teleporting ) && level.zombie_ghost_round_states.is_teleporting )
	{
		return;
	}
	if ( !isDefined( level.ghost_drop_down_locations ) || level.ghost_drop_down_locations.size < 1 )
	{
		return;
	}
	if ( !isDefined( level.zones[ "zone_start" ] ) || isDefined( level.zones[ "zone_start" ].is_occupied ) && level.zones[ "zone_start" ].is_occupied )
	{
		return;
	}
	if ( !isDefined( level.zones[ "zone_start_lower" ] ) || isDefined( level.zones[ "zone_start_lower" ].is_occupied ) && level.zones[ "zone_start_lower" ].is_occupied )
	{
		return;
	}
	teleport_location_index = 0;
	axises = getaiarray( "axis" );
	_a1847 = axises;
	_k1847 = getFirstArrayKey( _a1847 );
	while ( isDefined( _k1847 ) )
	{
		axis = _a1847[ _k1847 ];
		if ( is_true( axis.is_ghost ) && axis maps/mp/zombies/_zm_ai_ghost::is_in_start_area() )
		{
			if ( teleport_location_index == level.ghost_drop_down_locations.size )
			{
				teleport_location_index = 0;
			}
			teleport_location_origin = level.ghost_drop_down_locations[ teleport_location_index ].origin;
			teleport_location_angles = level.ghost_drop_down_locations[ teleport_location_index ].angles;
			axis forceteleport( teleport_location_origin, teleport_location_angles );
			teleport_location_index++;
		}
		_k1847 = getNextArrayKey( _a1847, _k1847 );
	}
}

ghost_zone_fountain_teleport_logic()
{
	if ( isDefined( level.zombie_ghost_round_states.is_teleporting ) && level.zombie_ghost_round_states.is_teleporting )
	{
		return;
	}
	if ( !isDefined( level.ghost_zone_start_lower_locations ) || level.ghost_zone_start_lower_locations.size < 1 )
	{
		return;
	}
	if ( !level.zones[ "zone_start_lower" ].is_occupied )
	{
		return;
	}
	teleport_location_index = 0;
	axises = getaiarray( "axis" );
	_a1888 = axises;
	_k1888 = getFirstArrayKey( _a1888 );
	while ( isDefined( _k1888 ) )
	{
		axis = _a1888[ _k1888 ];
		if ( is_true( axis.is_ghost ) && !axis maps/mp/zombies/_zm_ai_ghost::is_in_start_area() )
		{
			if ( isDefined( axis.favoriteenemy ) && axis.favoriteenemy maps/mp/zombies/_zm_ai_ghost::is_in_start_area() )
			{
				if ( teleport_location_index == level.ghost_zone_start_lower_locations.size )
				{
					teleport_location_index = 0;
				}
				teleport_location_origin = level.ghost_zone_start_lower_locations[ teleport_location_index ].origin;
				teleport_location_angles = level.ghost_zone_start_lower_locations[ teleport_location_index ].angles;
				axis forceteleport( teleport_location_origin, teleport_location_angles );
				teleport_location_index++;
			}
		}
		_k1888 = getNextArrayKey( _a1888, _k1888 );
	}
}

init_level_specific_audio()
{
	level thread establish_mystery_wallbuy_categories();
	level._audio_custom_response_line = ::buried_audio_custom_response_line;
	level.oh_shit_vo_cooldown = 0;
	level.snd_pers_upgrade_force_variant = 0;
	level.pers_upgrade_vo_spoken = 1;
	level.snd_pers_upgrade_force_type = "achievement";
	level.custom_banking_vo = 1;
	level.custom_buildable_need_part_vo = ::buried_custom_buildable_need_part_vo;
	level.custom_buildable_wrong_part_vo = ::buried_custom_buildable_wrong_part_vo;
	level.custom_bank_deposit_vo = ::buried_custom_bank_deposit_vo;
	level.custom_bank_withdrawl_vo = ::buried_custom_bank_withdrawl_vo;
	level.custom_faller_death = ::maps/mp/zombies/_zm_ai_faller::faller_death_ragdoll;
	if ( is_classic() )
	{
		level.audio_get_mod_type = ::buried_audio_get_mod_type_override;
		level.custom_kill_damaged_vo = ::maps/mp/zombies/_zm_audio::custom_kill_damaged_vo;
		level.gib_on_damage = ::buried_custom_zombie_gibbed_vo;
		level._audio_custom_weapon_check = ::buried_audio_custom_weapon_check;
		level._custom_zombie_oh_shit_vox_func = ::buried_custom_zombie_oh_shit_vox;
		level.custom_player_track_ammo_count = ::buried_player_track_ammo_count;
		onplayerconnect_callback( ::zm_buried_buildable_pickedup_vo );
		level thread ghost_steal_vo_watcher();
		level thread ghost_damage_vo_watcher();
		level thread sloth_first_encounter_vo();
		level thread sloth_crawler_vo();
	}
	buried_add_player_dialogue( "player", "general", "no_money_weapon", "nomoney_generic", undefined );
	buried_add_player_dialogue( "player", "general", "no_money_box", "nomoney_generic", undefined );
	buried_add_player_dialogue( "player", "general", "perk_deny", "nomoney_generic", undefined );
	buried_add_player_dialogue( "player", "kill", "closekill", "kill_close", undefined, 15 );
	buried_add_player_dialogue( "player", "kill", "damage", "kill_damaged", undefined, 50 );
	buried_add_player_dialogue( "player", "kill", "headshot", "kill_headshot", "resp_kill_headshot", 25 );
	buried_add_player_dialogue( "player", "kill", "raymk2", "kill_raymk2", undefined, 15 );
	buried_add_player_dialogue( "player", "kill", "paralyzer", "kill_paralyzer", undefined, 15 );
	buried_add_player_dialogue( "player", "kill", "headchopper", "kill_headchopper", undefined, 15 );
	buried_add_player_dialogue( "player", "kill", "subwoofer", "kill_subwoofer", undefined, 15 );
	buried_add_player_dialogue( "player", "kill", "six_shooter", "kill_six_shooter", undefined, 15 );
	buried_add_player_dialogue( "player", "perk", "specialty_armorvest", "perk_jugga", undefined, 100 );
	buried_add_player_dialogue( "player", "perk", "specialty_quickrevive", "perk_revive", undefined, 100 );
	buried_add_player_dialogue( "player", "perk", "specialty_fastreload", "perk_speed", undefined, 100 );
	buried_add_player_dialogue( "player", "perk", "specialty_rof", "perk_doubletap", undefined, 100 );
	buried_add_player_dialogue( "player", "perk", "specialty_longersprint", "perk_stamine", undefined, 100 );
	buried_add_player_dialogue( "player", "perk", "specialty_additionalprimaryweapon", "perk_mule", undefined, 100 );
	buried_add_player_dialogue( "player", "perk", "specialty_nomotionsensor", "perk_vulture", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "revive_up", "heal_revived", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "exert_sigh", "exert_sigh", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "exert_laugh", "exert_laugh", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "pain_high", "pain_high", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pickup", "build_pickup", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_swap", "build_swap", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_add", "build_add", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_final", "build_final", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_wrong_part", "build_wrong_part", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_need_part", "build_need_part", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_hc_final", "build_hc_final", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_bheadchopper_zm", "build_hc_take", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_plc_headchopper_zm", "build_hc_drop", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_wheadchopper_zm", "build_hc_pickup", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_sw_final", "build_sw_final", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_bsubwoofer_zm", "build_sw_take", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_plc_subwoofer_zm", "build_sw_drop", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_wsubwoofer_zm", "build_sw_pickup", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_trb_final", "build_trb_final", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_bturbine", "build_trb_take", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_plc_turbine", "build_trb_drop", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_wturbine", "build_trb_pickup", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_stm_final", "build_stm_final", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_bspringpad_zm", "build_stm_take", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_plc_springpad_zm", "build_stm_drop", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "build_pck_wspringpad_zm", "build_stm_pickup", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "gunshop_chalk_pickup", "gunshop_chalk", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "booze_pickup", "pickup_booze", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "candy_pickup", "pickup_candy", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "key_pickup", "pickup_key", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "first_bersek", "sloth_1st_bottle", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_generic_feed", "sloth_generic_feed", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_retreat_cell", "sloth_retreat_cell", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_clears_path", "sloth_clears_path", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_unlocked", "sloth_unlocked", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_run", "sloth_run", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_encounter", "sloth_encounter", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "sloth_crawler", "sloth_crawler", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "ghost_theft", "ghost_theft", undefined, 25 );
	buried_add_player_dialogue( "player", "general", "ghost_damage", "ghost_damage", undefined, 25 );
	buried_add_player_dialogue( "player", "general", "vulture_stink", "react_stink", "vulture_stink_react", 25 );
	buried_add_player_dialogue( "player", "general", "vulture_stink_react", "response_stink", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "vulture_ammo_drop", "ammo_drop", undefined, 15 );
	buried_add_player_dialogue( "player", "general", "vulture_money_drop", "money_drop", undefined, 15 );
	buried_add_player_dialogue( "player", "general", "throw_bomb", "throw_bomb", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "activate_bomb", "activate_bomb", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "ammo_switch", "ammo_switch", undefined, 100 );
	buried_add_player_dialogue( "player", "power", "power_on", "power_on", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "reboard", "rebuild_boards", undefined, 50 );
	buried_add_player_dialogue( "player", "general", "generic_wall_buy", "generic_wall_buy", undefined, 25 );
	buried_add_player_dialogue( "player", "general", "favorite_wall_buy", "favorite_wall_buy", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "in_maze", "in_maze", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "game_start", "game_start", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "find_town", "find_town", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "stay_topside", "stay_topside", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "fall_down_hole", "fall_down_hole", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "fall_down_hole_response", "fall_response", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "pap_wait", "pap_wait", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "pap_arm", "pap_arm", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "pap_wait2", "pap_wait2", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "pap_arm2", "pap_arm2", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "weapon_storage", "weapon_storage", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "wall_withdrawl", "wall_withdrawl", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "bank_deposit", "bank_deposit", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "bank_withdrawl", "bank_withdrawl", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "achievement", "earn_acheivement", undefined, 100 );
	buried_add_player_dialogue( "player", "quest", "find_secret", "find_secret", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "upgrade", "find_secret", undefined, 100 );
	buried_add_player_dialogue( "player", "general", "invisible_collision", "invisible_collision", undefined, 25 );
	buried_add_player_dialogue( "player", "general", "stuhlinger_possessed", "stuhlinger_2nd_possession_1", undefined, 100 );
}

buried_add_player_dialogue( speaker, category, type, alias, response, chance )
{
	level.vox zmbvoxadd( speaker, category, type, alias, response );
	if ( isDefined( chance ) )
	{
		add_vox_response_chance( type, chance );
	}
}

buried_audio_custom_response_line( player, index, category, type )
{
	while ( type == "vulture_stink" )
	{
		a_players = getplayers();
		arrayremovevalue( a_players, player );
		while ( a_players.size > 0 )
		{
			a_closest = get_array_of_closest( player.origin, a_players );
			i = 0;
			while ( i < a_closest.size )
			{
				if ( isDefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
				{
					if ( isalive( a_closest[ i ] ) )
					{
						n_dist = distance2dsquared( player.origin, a_closest[ i ].origin );
						if ( n_dist <= 250000 )
						{
							a_closest[ i ] thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "vulture_stink_react" );
							return;
						}
					}
				}
				i++;
			}
		}
	}
	russman = 0;
	samuel = 1;
	misty = 2;
	marlton = 3;
	switch( player.characterindex )
	{
		case 0:
			level maps/mp/zombies/_zm_audio::setup_hero_rival( player, samuel, marlton, category, type );
			break;
		case 1:
			level maps/mp/zombies/_zm_audio::setup_hero_rival( player, russman, misty, category, type );
			break;
		case 2:
			level maps/mp/zombies/_zm_audio::setup_hero_rival( player, marlton, samuel, category, type );
			break;
		case 3:
			level maps/mp/zombies/_zm_audio::setup_hero_rival( player, misty, russman, category, type );
			break;
	}
	return;
}

buried_audio_get_mod_type_override( impact, mod, weapon, zombie, instakill, dist, player )
{
	close_dist = 4096;
	med_dist = 15376;
	far_dist = 75625;
	a_str_mod = [];
	if ( isDefined( zombie.damageweapon ) && zombie.damageweapon == "cymbal_monkey_zm" )
	{
		a_str_mod[ a_str_mod.size ] = "monkey";
	}
	if ( weapon == "slowgun_zm" || weapon == "slowgun_upgraded_zm" )
	{
		a_str_mod[ a_str_mod.size ] = "paralyzer";
	}
	if ( weapon == "rnma_zm" || weapon == "rnma_upgraded_zm" )
	{
		a_str_mod[ a_str_mod.size ] = "six_shooter";
	}
	if ( is_headshot( weapon, impact, mod ) && dist >= far_dist )
	{
		a_str_mod[ a_str_mod.size ] = "headshot";
	}
	if ( is_explosive_damage( mod ) && weapon != "ray_gun_zm" && weapon != "ray_gun_upgraded_zm" && weapon != "raygun_mark2_zm" && weapon != "raygun_mark2_upgraded_zm" && isDefined( zombie.is_on_fire ) && !zombie.is_on_fire )
	{
		if ( !isinarray( a_str_mod, "monkey" ) )
		{
			if ( !instakill )
			{
				a_str_mod[ a_str_mod.size ] = "explosive";
			}
			else
			{
				a_str_mod[ a_str_mod.size ] = "weapon_instakill";
			}
		}
	}
	if ( weapon == "ray_gun_zm" || weapon == "ray_gun_upgraded_zm" )
	{
		if ( !isinarray( a_str_mod, "monkey" ) )
		{
			if ( dist > far_dist )
			{
				if ( !instakill )
				{
					a_str_mod[ a_str_mod.size ] = "raygun";
				}
				else
				{
					a_str_mod[ a_str_mod.size ] = "weapon_instakill";
				}
			}
		}
	}
	if ( weapon == "raygun_mark2_zm" || weapon == "raygun_mark2_upgraded_zm" )
	{
		if ( !isinarray( a_str_mod, "monkey" ) )
		{
			if ( dist > far_dist )
			{
				if ( !instakill )
				{
					a_str_mod[ a_str_mod.size ] = "raymk2";
				}
				else
				{
					a_str_mod[ a_str_mod.size ] = "weapon_instakill";
				}
			}
		}
	}
	if ( instakill )
	{
		if ( mod == "MOD_MELEE" )
		{
			a_str_mod[ a_str_mod.size ] = "melee_instakill";
		}
		else
		{
			a_str_mod[ a_str_mod.size ] = "weapon_instakill";
		}
	}
	if ( mod != "MOD_MELEE" && !zombie.has_legs )
	{
		a_str_mod[ a_str_mod.size ] = "crawler";
	}
	if ( mod != "MOD_BURNED" && dist < close_dist )
	{
		a_str_mod[ a_str_mod.size ] = "closekill";
	}
	if ( a_str_mod.size == 0 )
	{
		str_mod_final = "default";
	}
	else if ( a_str_mod.size == 1 )
	{
		str_mod_final = a_str_mod[ 0 ];
	}
	else
	{
		i = 0;
		while ( i < a_str_mod.size )
		{
			if ( cointoss() )
			{
				str_mod_final = a_str_mod[ i ];
			}
			i++;
		}
		str_mod_final = a_str_mod[ randomint( a_str_mod.size ) ];
	}
	return str_mod_final;
}

buried_custom_zombie_gibbed_vo()
{
	self endon( "death" );
	if ( isDefined( self.a.gib_ref ) && isalive( self ) )
	{
		if ( self.a.gib_ref != "no_legs" || self.a.gib_ref == "right_leg" && self.a.gib_ref == "left_leg" )
		{
			if ( isDefined( self.attacker ) && isplayer( self.attacker ) )
			{
				if ( isDefined( self.attacker.crawler_created_vo_cooldown ) && self.attacker.crawler_created_vo_cooldown )
				{
					return;
				}
				rand = randomintrange( 0, 100 );
				if ( rand < 15 )
				{
					self.attacker maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "crawl_spawn" );
					self.attacker thread crawler_created_vo_cooldown();
				}
			}
			return;
		}
		else
		{
			if ( isDefined( self.a.gib_ref ) || self.a.gib_ref == "right_arm" && self.a.gib_ref == "left_arm" )
			{
				if ( self.has_legs && isalive( self ) )
				{
					if ( isDefined( self.attacker ) && isplayer( self.attacker ) )
					{
						rand = randomintrange( 0, 100 );
						if ( rand < 7 )
						{
							self.attacker create_and_play_dialog( "general", "shoot_arm" );
						}
					}
				}
			}
		}
	}
}

crawler_created_vo_cooldown()
{
	self endon( "disconnect" );
	self.crawler_created_vo_cooldown = 1;
	wait 30;
	self.crawler_created_vo_cooldown = 0;
}

buried_audio_custom_weapon_check( weapon, magic_box )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( isDefined( magic_box ) && magic_box )
	{
		type = self maps/mp/zombies/_zm_weapons::weapon_type_check( weapon );
		return type;
	}
	if ( flag( "time_bomb_restore_active" ) )
	{
		return "crappy";
	}
	if ( issubstr( weapon, "upgraded" ) )
	{
		self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "wpck_pap" );
		return "crappy";
	}
	else
	{
		if ( weapon == "ray_gun_zm" )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", "ray_gun_zm" );
			return "crappy";
		}
		else
		{
			if ( weapon == "raygun_mark2_zm" )
			{
				self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "build_take_raygun" );
				return "crappy";
			}
			else
			{
				while ( isDefined( self.favorite_wall_weapons_list ) )
				{
					_a2385 = self.favorite_wall_weapons_list;
					_k2385 = getFirstArrayKey( _a2385 );
					while ( isDefined( _k2385 ) )
					{
						fav_weapon = _a2385[ _k2385 ];
						if ( weapon == fav_weapon )
						{
							self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "favorite_wall_buy" );
							return "crappy";
						}
						_k2385 = getNextArrayKey( _a2385, _k2385 );
					}
				}
			}
		}
	}
	self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "generic_wall_buy" );
	return "crappy";
}

buried_custom_zombie_oh_shit_vox()
{
	self endon( "death_or_disconnect" );
	while ( 1 )
	{
		wait 1;
		if ( isDefined( self.oh_shit_vo_cooldown ) && self.oh_shit_vo_cooldown )
		{
			continue;
		}
		players = get_players();
		zombs = get_round_enemy_array();
		if ( players.size <= 1 )
		{
			n_cooldown_time = 20;
		}
		else
		{
			n_cooldown_time = 15;
		}
		n_distance_sq = 62500;
		n_zombies = 5;
		n_chance = 30;
		close_zombs = 0;
		i = 0;
		while ( i < zombs.size )
		{
			if ( isDefined( zombs[ i ].favoriteenemy ) || zombs[ i ].favoriteenemy == self && !isDefined( zombs[ i ].favoriteenemy ) )
			{
				if ( distancesquared( zombs[ i ].origin, self.origin ) < n_distance_sq )
				{
					close_zombs++;
				}
			}
			i++;
		}
		if ( close_zombs >= n_zombies )
		{
			if ( randomint( 100 ) < n_chance && isDefined( self.isonbus ) && !self.isonbus )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "oh_shit" );
				self thread global_oh_shit_cooldown_timer( n_cooldown_time );
			}
		}
	}
}

global_oh_shit_cooldown_timer( n_cooldown_time )
{
	self endon( "disconnect" );
	self.oh_shit_vo_cooldown = 1;
	wait n_cooldown_time;
	self.oh_shit_vo_cooldown = 0;
}

establish_mystery_wallbuy_categories()
{
	level.good_mystery_wallbuy = [];
	level.good_mystery_wallbuy[ 0 ] = "ak74u_zm";
	level.good_mystery_wallbuy[ 1 ] = "pdw57_zm";
	level.good_mystery_wallbuy[ 2 ] = "tazer_knuckles_zm";
	level.bad_mystery_wallbuy = [];
	level.bad_mystery_wallbuy[ 0 ] = "an94_zm";
	level.bad_mystery_wallbuy[ 1 ] = "svu_zm";
	level.bad_mystery_wallbuy[ 2 ] = "870mcs_zm";
}

buried_player_track_ammo_count()
{
	self notify( "stop_ammo_tracking" );
	self endon( "disconnect" );
	self endon( "stop_ammo_tracking" );
	ammolowcount = 0;
	ammooutcount = 0;
	while ( 1 )
	{
		wait 0,5;
		weap = self getcurrentweapon();
		while ( isDefined( weap ) || weap == "none" && !can_track_ammo( weap ) )
		{
			continue;
		}
		while ( self getammocount( weap ) > 5 || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			ammooutcount = 0;
			ammolowcount = 0;
		}
		if ( self getammocount( weap ) > 0 )
		{
			if ( ammolowcount < 1 )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ammo_low" );
				ammolowcount++;
			}
		}
		else if ( ammooutcount < 1 )
		{
			a_weapons = self getweaponslistprimaries();
			if ( a_weapons.size > 1 )
			{
				_a2523 = a_weapons;
				_k2523 = getFirstArrayKey( _a2523 );
				while ( isDefined( _k2523 ) )
				{
					weapon = _a2523[ _k2523 ];
					if ( weapon == weap )
					{
					}
					else if ( self getammocount( weapon ) > 0 )
					{
						self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ammo_switch" );
						self.ammo_switch_vo_played = 1;
						break;
					}
					else
					{
						_k2523 = getNextArrayKey( _a2523, _k2523 );
					}
				}
				if ( isDefined( self.ammo_switch_vo_played ) && !self.ammo_switch_vo_played )
				{
					self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ammo_out" );
					ammooutcount++;
				}
				self.ammo_switch_vo_played = 0;
				break;
			}
			else
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ammo_out" );
				ammooutcount++;
			}
		}
		wait 20;
	}
}

zm_buried_buildable_pickedup_vo()
{
	self.buildable_pickedup_timer = 0;
}

ghost_steal_vo_watcher()
{
	while ( 1 )
	{
		level waittill( "ghost_drained_player", player );
		chance = get_response_chance( "ghost_theft" );
		if ( chance > randomintrange( 1, 100 ) )
		{
			player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ghost_theft" );
		}
	}
}

ghost_damage_vo_watcher()
{
	while ( 1 )
	{
		level waittill( "ghost_damaged_player", player );
		chance = get_response_chance( "ghost_damage" );
		if ( chance > randomintrange( 1, 100 ) )
		{
			player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ghost_damage" );
		}
	}
}

buried_custom_buildable_need_part_vo()
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( isDefined( self.build_need_part_vo_cooldown ) && !self.build_need_part_vo_cooldown )
	{
		self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "build_need_part" );
		self thread buildable_need_part_vo_cooldown();
	}
}

buildable_need_part_vo_cooldown()
{
	self endon( "disconnect" );
	self.build_need_part_vo_cooldown = 1;
	wait 60;
	self.build_need_part_vo_cooldown = 0;
}

buried_custom_buildable_wrong_part_vo()
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( isDefined( self.build_wrong_part_vo_cooldown ) && !self.build_wrong_part_vo_cooldown )
	{
		self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "build_wrong_part" );
		self thread buildable_wrong_part_vo_cooldown();
	}
}

buildable_wrong_part_vo_cooldown()
{
	self endon( "disconnect" );
	self.build_wrong_part_vo_cooldown = 1;
	wait 60;
	self.build_wrong_part_vo_cooldown = 0;
}

buried_custom_bank_deposit_vo()
{
	self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "bank_deposit" );
}

buried_custom_bank_withdrawl_vo()
{
	self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "bank_withdrawl" );
}

sloth_first_encounter_vo()
{
	trigger = getent( "sloth_first_encounter_trigger", "targetname" );
	while ( 1 )
	{
		trigger waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			if ( ent is_player_looking_at( level.sloth.origin, 0,25, 0 ) )
			{
				ent thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sloth_encounter" );
				trigger delete();
				return;
			}
		}
		else
		{
			wait 0,1;
		}
	}
}

sloth_crawler_vo()
{
	while ( 1 )
	{
		while ( !isDefined( level.sloth ) )
		{
			wait 1;
		}
		while ( level.sloth is_jail_state() )
		{
			wait 1;
		}
		while ( level.sloth.state == "berserk" || level.sloth.state == "crash" )
		{
			wait 1;
		}
		while ( isDefined( level.sloth.carrying_crawler ) && level.sloth.carrying_crawler )
		{
			wait 1;
		}
		while ( isDefined( level.time_bomb_detonation_vo ) && level.time_bomb_detonation_vo )
		{
			wait 1;
		}
		zombies = get_round_enemy_array();
		i = 0;
		while ( i < zombies.size )
		{
			zombie = zombies[ i ];
			while ( isDefined( zombie ) && isDefined( zombie.has_legs ) && !zombie.has_legs )
			{
				a_players = getplayers();
				_a2714 = a_players;
				_k2714 = getFirstArrayKey( _a2714 );
				while ( isDefined( _k2714 ) )
				{
					player = _a2714[ _k2714 ];
					if ( is_player_valid( player ) && isDefined( player.isspeaking ) && !player.isspeaking )
					{
						if ( player is_player_looking_at( zombie.origin, 0,25 ) )
						{
							if ( distancesquared( player.origin, level.sloth.origin ) < 9000000 )
							{
								player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sloth_crawler" );
								wait 10;
							}
						}
					}
					_k2714 = getNextArrayKey( _a2714, _k2714 );
				}
			}
			i++;
		}
		wait 1;
	}
}

collapsing_catwalk_init()
{
	level endon( "catwalk_collapsed" );
	trig = getent( "start_platform_trig", "targetname" );
	platform = getent( "start_platform", "targetname" );
	while ( 1 )
	{
		trig waittill( "trigger", who );
		if ( isplayer( who ) )
		{
			if ( isDefined( who.on_platform ) && !who.on_platform )
			{
				trig thread collapsing_platform_watcher( who, platform );
				return;
			}
		}
	}
}

collapsing_platform_watcher( who, platform )
{
	who.on_platform = 1;
	timed_collapse = 0;
	if ( isDefined( platform ) )
	{
		platform playsound( "zmb_catwalk_shake" );
	}
	jump_blocker_clip = getent( "start_platform_delayed_clip", "targetname" );
	earthquake( 0,3, 3, who.origin, 128 );
	level waittill_notify_or_timeout( "lsat_purchased", 2 );
	if ( isDefined( who ) )
	{
		who notify( "platform_collapse" );
		who.on_platform = 0;
	}
	if ( isDefined( platform ) )
	{
		exploder( 410 );
		platform notsolid();
		level setclientfield( "cw_fall", 1 );
		platform playsound( "zmb_catwalk_fall" );
		if ( isDefined( platform.pieces ) )
		{
			array_thread( platform.pieces, ::self_delete );
		}
		if ( isDefined( platform ) )
		{
			platform delete();
		}
	}
	wait 3;
	level notify( "catwalk_collapsed" );
	level.catwalk_collapsed = 1;
	if ( isDefined( jump_blocker_clip ) )
	{
		jump_blocker_clip delete();
	}
	if ( isDefined( self ) )
	{
		self delete();
	}
}

achievement_watcher_lsat_upgrade()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "pap_taken" );
	self notify( "player_upgraded_lsat_from_wall" );
}

player_give_lsat()
{
	level notify( "lsat_purchased" );
	if ( isDefined( level.catwalk_collapsed ) && !level.catwalk_collapsed )
	{
		self maps/mp/zombies/_zm_stats::increment_client_stat( "buried_lsat_purchased", 0 );
		self maps/mp/zombies/_zm_stats::increment_player_stat( "buried_lsat_purchased" );
		level.lsat_purchased = 1;
	}
	self thread achievement_watcher_lsat_upgrade();
	self giveweapon( "lsat_zm" );
	maps/mp/zombies/_zm_weapons::acquire_weapon_toggle( "lsat_zm", self );
	self givestartammo( "lsat_zm" );
	self switchtoweapon( "lsat_zm" );
}

bell_watch()
{
	bells = getentarray( "church_bell", "targetname" );
	array_thread( bells, ::bell_watch_ring );
}

bell_watch_ring()
{
	self endon( "delete" );
	self setcandamage( 1 );
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, mod, tagname, modelname, partname, weaponname );
		bell_ring( attacker, self );
	}
}

bell_ring( player, bell )
{
	level notify( "bell_rung" );
/#
#/
	bell playsound( "amb_church_bell" );
}

player_force_from_prone()
{
	level endon( "intermission" );
	level endon( "end_game" );
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isplayer( who ) && who getstance() == "prone" )
		{
			who setstance( "crouch" );
		}
		wait 0,1;
	}
}

check_valid_poi( valid )
{
	excludes = getentarray( "cymbal_monkey_exclude", "targetname" );
	while ( isDefined( excludes ) )
	{
		_a2921 = excludes;
		_k2921 = getFirstArrayKey( _a2921 );
		while ( isDefined( _k2921 ) )
		{
			volume = _a2921[ _k2921 ];
			if ( self istouching( volume ) )
			{
				return 0;
			}
			_k2921 = getNextArrayKey( _a2921, _k2921 );
		}
	}
	if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_mansion" ) )
	{
		return 0;
	}
	return valid;
}

tear_into_position()
{
	asd_name = "zm_zbarrier_board_tear_in";
	substate_index = self.attacking_spot_index * 6;
	anim_id = self getanimfromasd( asd_name, substate_index );
	zbarrier = self.first_node.zbarrier;
	start_org = getstartorigin( zbarrier.origin, zbarrier.angles, anim_id );
	start_ang = getstartangles( zbarrier.origin, zbarrier.angles, anim_id );
	self setgoalpos( start_org, start_ang );
	self thread tear_into_facing( start_org, start_ang );
}

tear_into_facing( start_org, start_ang )
{
	self endon( "death" );
	facing_dist = 256;
	while ( 1 )
	{
		dist = distancesquared( self.origin, start_org );
		if ( dist < facing_dist )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	self orientmode( "face angle", start_ang[ 1 ] );
}

tear_into_wait()
{
	return;
}

melee_miss_func()
{
	if ( isDefined( self.enemy ) )
	{
		if ( isDefined( level.sloth ) )
		{
			sloth_dist_sq = distancesquared( self.enemy.origin, level.sloth.origin );
			if ( sloth_dist_sq < 225 )
			{
				dist_sq = distancesquared( self.enemy.origin, self.origin );
				melee_dist_sq = self.meleeattackdist * self.meleeattackdist;
				if ( dist_sq < melee_dist_sq )
				{
					self.enemy dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
				}
			}
		}
	}
}

equipment_planted( weapon, equipname, groundfrom )
{
}

equipment_safe_to_drop( weapon )
{
	if ( isDefined( weapon.model ) && issubstr( weapon.model, "chopper" ) )
	{
		if ( maps/mp/zombies/_zm_equip_headchopper::check_headchopper_in_bad_area( weapon.origin ) )
		{
			return 0;
		}
	}
	valid_location = check_point_in_enabled_zone( weapon.origin, undefined, undefined );
	if ( isDefined( valid_location ) && !valid_location )
	{
		if ( weapon in_playable_area() )
		{
			return 1;
		}
		return 0;
	}
	return 1;
}

ignore_equipment( zombie )
{
	if ( isDefined( zombie.completed_emerging_into_playable_area ) && !zombie.completed_emerging_into_playable_area )
	{
		return 1;
	}
	if ( isDefined( zombie.is_ghost ) && zombie.is_ghost )
	{
		return 1;
	}
	if ( isDefined( zombie.is_sloth ) && zombie.is_sloth )
	{
		return 1;
	}
	if ( isDefined( self.equipname ) && self.equipname == "equip_headchopper_zm" )
	{
		if ( isDefined( self.headchopper_kills ) && self.headchopper_kills < 10 )
		{
			return 1;
		}
		else
		{
			if ( isDefined( zombie.headchopper_last_damage_time ) )
			{
				currenttime = getTime();
				if ( ( currenttime - zombie.headchopper_last_damage_time ) <= 2500 )
				{
					return 1;
				}
			}
		}
	}
	return 0;
}

buried_paralyzer_check()
{
	curr_zone = self get_current_zone();
	if ( isDefined( curr_zone ) )
	{
		if ( curr_zone == "zone_mansion" )
		{
			return 0;
		}
		if ( curr_zone == "zone_start" && self.origin[ 2 ] < 1222 )
		{
			return 0;
		}
	}
	return 1;
}

is_courthouse_open()
{
	if ( flag( "courthouse_door1" ) )
	{
		return 1;
	}
	if ( flag( "tunnel2saloon" ) && flag( "tunnels2courthouse" ) )
	{
		return 1;
	}
	return 0;
}

is_tunnel_open()
{
	if ( flag( "tunnel2saloon" ) )
	{
		return 1;
	}
	if ( flag( "tunnels2courthouse" ) && maps/mp/zm_buried::is_courthouse_open() )
	{
		return 1;
	}
	return 0;
}
