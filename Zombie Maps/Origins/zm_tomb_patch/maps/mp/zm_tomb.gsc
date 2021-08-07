//checked includes changed to match cerberus output
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_challenges;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_devgui;
#include maps/mp/zombies/_zm_powerup_zombie_blood;
#include character/c_jap_takeo_dlc4;
#include character/c_ger_richtofen_dlc4;
#include character/c_rus_nikolai_dlc4;
#include character/c_usa_dempsey_dlc4;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/_visionset_mgr;
#include maps/mp/zm_tomb_chamber;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_tomb_ee_side;
#include maps/mp/zm_tomb_ee_main;
#include maps/mp/zm_tomb_main_quest;
#include maps/mp/zm_tomb_dig;
#include maps/mp/zm_tomb_ambient_scripts;
#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_weap_staff_revive;
#include maps/mp/zombies/_zm_weap_riotshield_tomb;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_weap_beacon;
#include maps/mp/_sticky_grenade;
#include maps/mp/zombies/_zm_perk_random;
#include maps/mp/zm_tomb_challenges;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_magicbox_tomb;
#include maps/mp/zm_tomb_distance_tracking;
#include maps/mp/zm_tomb_achievement;
#include maps/mp/zm_tomb;
#include maps/mp/zombies/_zm_weap_staff_air;
#include maps/mp/zombies/_zm_weap_staff_lightning;
#include maps/mp/zombies/_zm_weap_staff_water;
#include maps/mp/zombies/_zm_weap_staff_fire;
#include maps/mp/zombies/_zm_weap_one_inch_punch;
#include maps/mp/zombies/_zm_perk_electric_cherry;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_perk_divetonuke;
#include maps/mp/zm_tomb_vo;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zombies/_load;
#include maps/mp/zombies/_zm_ai_quadrotor;
#include maps/mp/zombies/_zm_ai_mechz;
#include maps/mp/zm_tomb_amb;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm;
#include maps/mp/zm_tomb_giant_robot;
#include maps/mp/zm_tomb_teleporter;
#include maps/mp/zm_tomb_capture_zones;
#include maps/mp/zm_tomb_quest_fire;
#include maps/mp/zm_tomb_tank;
#include maps/mp/zm_tomb_ffotd;
#include maps/mp/zm_tomb_fx;
#include maps/mp/zm_tomb_gamemodes;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

gamemode_callback_setup() //checked matches cerberus output
{
	maps/mp/zm_tomb_gamemodes::init();
}

survival_init() //checked matches cerberus output
{
	level.force_team_characters = 1;
	level.should_use_cia = 0;
	if ( randomint( 100 ) > 50 )
	{
		level.should_use_cia = 1;
	}
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
	flag_wait( "start_zombie_round_logic" );
}

zstandard_preinit() //checked matches cerberus output
{
}

createfx_callback() //checked changed to match cerberus output
{
	ents = getentarray();
	for ( i = 0; i < ents.size; i++ )
	{
		if ( ents[ i ].classname != "info_player_start" )
		{
			ents[ i ] delete();
		}
	}
}

main() //checked matches cerberus output
{
	level._no_equipment_activated_clientfield = 1;
	level._no_navcards = 1;
	level._wallbuy_override_num_bits = 1;
	maps/mp/zm_tomb_fx::main();
	level thread maps/mp/zm_tomb_ffotd::main_start();
	level.default_game_mode = "zclassic";
	level.default_start_location = "tomb";
	setup_rex_starts();
	maps/mp/zm_tomb_tank::init_animtree();
	maps/mp/zm_tomb_quest_fire::init_animtree();
	maps/mp/zm_tomb_capture_zones::init_pap_animtree();
	maps/mp/zm_tomb_teleporter::init_animtree();
	maps/mp/zm_tomb_giant_robot::init_animtree();
	level.fx_exclude_edge_fog = 1;
	level.fx_exclude_tesla_head_light = 1;
	level.fx_exclude_default_explosion = 1;
	level.fx_exclude_footsteps = 1;
	level._uses_sticky_grenades = 1;
	level.disable_fx_zmb_wall_buy_semtex = 1;
	level._uses_taser_knuckles = 0;
	level.disable_fx_upgrade_aquired = 1;
	level._uses_default_wallbuy_fx = 0;
	maps/mp/zombies/_zm::init_fx();
	maps/mp/animscripts/zm_death::precache_gib_fx();
	level.zombiemode = 1;
	level._no_water_risers = 1;
	level.riser_fx_on_client = 1;
	maps/mp/zm_tomb_amb::main();
	maps/mp/zombies/_zm_ai_mechz::precache();
	maps/mp/zombies/_zm_ai_quadrotor::precache();
	level.n_active_ragdolls = 0;
	level.ragdoll_limit_check = ::ragdoll_attempt;
	level._limited_equipment = [];
	level._limited_equipment[ level._limited_equipment.size ] = "equip_dieseldrone_zm";
	level._limited_equipment[ level._limited_equipment.size ] = "staff_fire_zm";
	level._limited_equipment[ level._limited_equipment.size ] = "staff_air_zm";
	level._limited_equipment[ level._limited_equipment.size ] = "staff_lightning_zm";
	level._limited_equipment[ level._limited_equipment.size ] = "staff_water_zm";
	level.a_func_vehicle_damage_override = [];
	level.callbackvehicledamage = ::tomb_vehicle_damage_override_wrapper;
	level.level_specific_stats_init = ::init_tomb_stats;
	maps/mp/zombies/_load::main();
	setdvar( "zombiemode_path_minz_bias", 13 );
	setdvar( "tu14_bg_chargeShotExponentialAmmoPerChargeLevel", 1 );
	if ( getDvar( "createfx" ) == "1" )
	{
		return;
	}
	level_precache();

	maps/mp/gametypes_zm/_spawning::level_use_unified_spawning( 1 );
	level thread setup_tomb_spawn_groups();
	spawner_main_chamber_capture_zombies = getent( "chamber_capture_zombie_spawner", "targetname" );
	spawner_main_chamber_capture_zombies add_spawn_function( ::chamber_capture_zombie_spawn_init );
	level.has_richtofen = 0;
	level.givecustomloadout = ::givecustomloadout;
	level.precachecustomcharacters = ::precache_personality_characters;
	level.givecustomcharacters = ::give_personality_characters;
	level.setupcustomcharacterexerts = ::setup_personality_character_exerts;
	level._zmbvoxlevelspecific = maps/mp/zm_tomb_vo::init_level_specific_audio;
	level.custom_player_track_ammo_count = ::tomb_custom_player_track_ammo_count;
	level.custom_player_fake_death = ::zm_player_fake_death;
	level.custom_player_fake_death_cleanup = ::zm_player_fake_death_cleanup;
	level.initial_round_wait_func = ::initial_round_wait_func;
	level.zombie_init_done = ::zombie_init_done;
	level._zombies_round_spawn_failsafe = ::tomb_round_spawn_failsafe;
	level.random_pandora_box_start = 1;
	level.zombiemode_using_pack_a_punch = 1;
	level.zombiemode_reusing_pack_a_punch = 1;
	level.zombiemode_using_juggernaut_perk = 1;
	level.zombiemode_using_revive_perk = 1;
	level.zombiemode_using_sleightofhand_perk = 1;
	level.zombiemode_using_additionalprimaryweapon_perk = 1;
	level.zombiemode_using_marathon_perk = 1;
	level.zombiemode_using_deadshot_perk = 1;
	level.zombiemode_using_doubletap_perk = 1;
	level.zombiemode_using_random_perk = 1;
	level.zombiemode_using_divetonuke_perk = 1;
	maps/mp/zombies/_zm_perk_divetonuke::enable_divetonuke_perk_for_level();
	level.custom_electric_cherry_perk_threads = maps/mp/zombies/_zm_perks::register_perk_threads( "specialty_grenadepulldeath", ::tomb_custom_electric_cherry_reload_attack, maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_perk_lost );
	level.zombiemode_using_electric_cherry_perk = 1;
	maps/mp/zombies/_zm_perk_electric_cherry::enable_electric_cherry_perk_for_level();
	level.flopper_network_optimized = 1;
	level.perk_random_vo_func_usemachine = maps/mp/zm_tomb_vo::wunderfizz_used_vo;
	maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_precache();
	maps/mp/zombies/_zm_weap_staff_fire::precache();
	maps/mp/zombies/_zm_weap_staff_water::precache();
	maps/mp/zombies/_zm_weap_staff_lightning::precache();
	maps/mp/zombies/_zm_weap_staff_air::precache();
	level._custom_turn_packapunch_on = maps/mp/zm_tomb_capture_zones::pack_a_punch_dummy_init;
	level.custom_vending_precaching = ::custom_vending_precaching;
	level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;
	level.zombiemode_offhand_weapon_give_override = ::offhand_weapon_give_override;
	level._zombie_custom_add_weapons = ::custom_add_weapons;
	level._allow_melee_weapon_switching = 1;
	include_equipment( "equip_dieseldrone_zm" );
	include_equipment( "tomb_shield_zm" );
	level.custom_ai_type = [];
	level.raygun2_included = 1;
	include_weapons();
	include_powerups();
	include_perks_in_random_rotation();
	level maps/mp/zm_tomb_achievement::init();
	precacheitem( "death_throe_zm" );
	if ( level.splitscreen && getDvarInt( "splitscreen_playerCount" ) > 2 )
	{
		level.optimise_for_splitscreen = 1;
	}
	else
	{
		level.optimise_for_splitscreen = 0;
	}
	if ( isDefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
	{
		level.culldist = 2500;
	}
	else
	{
		level.culldist = 5500;
	}
	
	setculldist( level.culldist );
	level thread maps/mp/zm_tomb_distance_tracking::zombie_tracking_init();
	maps/mp/zombies/_zm_magicbox_tomb::init();
	level.special_weapon_magicbox_check = ::tomb_special_weapon_magicbox_check;
	maps/mp/zombies/_zm::init();
	level.callbackactordamage = ::tomb_actor_damage_override_wrapper;
	level._weaponobjects_on_player_connect_override = ::tomb_weaponobjects_on_player_connect_override;
	maps/mp/zombies/_zm_spawner::register_zombie_death_event_callback( ::tomb_zombie_death_event_callback );
	level.player_intersection_tracker_override = ::tomb_player_intersection_tracker_override;
	maps/mp/zm_tomb_challenges::challenges_init();
	maps/mp/zombies/_zm_perk_random::init();
	tomb_register_client_fields();
	register_burn_overlay();
	level thread maps/mp/_sticky_grenade::init();
	maps/mp/zm_tomb_tank::init();
	maps/mp/zombies/_zm_weap_beacon::init();
	maps/mp/zombies/_zm_weap_claymore::init();
	maps/mp/zombies/_zm_weap_riotshield_tomb::init();
	maps/mp/zombies/_zm_weap_staff_air::init();
	maps/mp/zombies/_zm_weap_staff_fire::init();
	maps/mp/zombies/_zm_weap_staff_lightning::init();
	maps/mp/zombies/_zm_weap_staff_water::init();
	maps/mp/zombies/_zm_weap_staff_revive::init();
	maps/mp/zombies/_zm_weap_cymbal_monkey::init();
	level._melee_weapons = [];
	maps/mp/zm_tomb_giant_robot::init_giant_robot_glows();
	maps/mp/zm_tomb_giant_robot::init_giant_robot();
	level.can_revive = maps/mp/zm_tomb_giant_robot::tomb_can_revive_override;
	maps/mp/zm_tomb_capture_zones::init_capture_zones();
	level.a_e_slow_areas = getentarray( "player_slow_area", "targetname" );
	maps/mp/zm_tomb_ambient_scripts::init_tomb_ambient_scripts();
	
	level thread maps/mp/zombies/_zm_ai_mechz::init();
	level thread maps/mp/zombies/_zm_perk_random::init_animtree();
	level thread maps/mp/zombies/_zm_ai_quadrotor::init();
	level.zombiemode_divetonuke_perk_func = ::tomb_custom_divetonuke_explode;
	set_zombie_var( "zombie_perk_divetonuke_min_damage", 500 );
	set_zombie_var( "zombie_perk_divetonuke_max_damage", 2000 );
	level.custom_laststand_func = ::tomb_custom_electric_cherry_laststand;
	maps/mp/zm_tomb_dig::init_shovel();
	level.n_crystals_pickedup = 0;
	level thread maps/mp/zm_tomb_main_quest::main_quest_init();
	level thread maps/mp/zm_tomb_teleporter::teleporter_init();
	level thread maps/mp/zombies/_zm_perk_random::start_random_machine();
	level.closest_player_override = ::tomb_closest_player_override;
	level.validate_enemy_path_length = ::tomb_validate_enemy_path_length;
	level thread maps/mp/zm_tomb_ee_main::init();
	level thread maps/mp/zm_tomb_ee_side::init();

	level.zones = [];
	level.zone_manager_init_func = ::working_zone_init;
	init_zones = [];
	init_zones[ 0 ] = "zone_start";
	level thread maps/mp/zombies/_zm_zonemgr::manage_zones( init_zones );
	if ( isDefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
	{
		if ( is_classic() )
		{
			level.zombie_ai_limit = 20;
		}
		setdvar( "fx_marks_draw", 0 );
		setdvar( "disable_rope", 1 );
		setdvar( "cg_disableplayernames", 1 );
		setdvar( "disableLookAtEntityLogic", 1 );
	}
	else
	{
		level.zombie_ai_limit = 24;
	}
	
	level thread drop_all_barriers();
	level thread traversal_blocker();
	onplayerconnect_callback( ::on_player_connect );
	maps/mp/zombies/_zm::register_player_damage_callback( ::tomb_player_damage_callback );
	level.custom_get_round_enemy_array_func = ::zm_tomb_get_round_enemy_array;
	flag_wait( "start_zombie_round_logic" );
	wait_network_frame();
	level notify( "specialty_additionalprimaryweapon_power_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	set_zombie_var( "zombie_use_failsafe", 0 );
	level check_solo_status();
	level thread adjustments_for_solo();
	level thread zone_capture_powerup();
	level thread clean_up_bunker_doors();
	level setclientfield( "lantern_fx", 1 );
	level thread maps/mp/zm_tomb_chamber::tomb_watch_chamber_player_activity();
	/*
/#
	maps/mp/zm_tomb_utility::setup_devgui();
#/
	*/
	init_weather_manager();
	level thread maps/mp/zm_tomb_ffotd::main_end();
}

tomb_register_client_fields() //checked matches cerberus output
{
	registerclientfield( "scriptmover", "stone_frozen", 14000, 1, "int" );
	n_bits = getminbitcountfornum( 5 );
	registerclientfield( "world", "rain_level", 14000, n_bits, "int" );
	registerclientfield( "world", "snow_level", 14000, n_bits, "int" );
	registerclientfield( "toplayer", "player_weather_visionset", 14000, 2, "int" );
	n_bits = getminbitcountfornum( 6 );
	registerclientfield( "toplayer", "player_rumble_and_shake", 14000, n_bits, "int" );
	registerclientfield( "scriptmover", "sky_pillar", 14000, 1, "int" );
	registerclientfield( "scriptmover", "staff_charger", 14000, 3, "int" );
	registerclientfield( "toplayer", "player_staff_charge", 14000, 2, "int" );
	registerclientfield( "toplayer", "player_tablet_state", 14000, 2, "int" );
	registerclientfield( "actor", "zombie_soul", 14000, 1, "int" );
	registerclientfield( "zbarrier", "magicbox_runes", 14000, 1, "int" );
	registerclientfield( "scriptmover", "barbecue_fx", 14000, 1, "int" );
	registerclientfield( "world", "cooldown_steam", 14000, 2, "int" );
	registerclientfield( "world", "mus_zmb_egg_snapshot_loop", 14000, 1, "int" );
	registerclientfield( "world", "sndMaelstromPlr0", 14000, 1, "int" );
	registerclientfield( "world", "sndMaelstromPlr1", 14000, 1, "int" );
	registerclientfield( "world", "sndMaelstromPlr2", 14000, 1, "int" );
	registerclientfield( "world", "sndMaelstromPlr3", 14000, 1, "int" );
	registerclientfield( "world", "sndChamberMusic", 14000, 3, "int" );
	registerclientfield( "actor", "foot_print_box_fx", 14000, 1, "int" );
	registerclientfield( "scriptmover", "foot_print_box_glow", 14000, 1, "int" );
	registerclientfield( "world", "crypt_open_exploder", 14000, 1, "int" );
	registerclientfield( "world", "lantern_fx", 14000, 1, "int" );
	registerclientfield( "allplayers", "oneinchpunch_impact", 14000, 1, "int" );
	registerclientfield( "actor", "oneinchpunch_physics_launchragdoll", 14000, 1, "int" );
}

register_burn_overlay() //checked matches cerberus output
{
	level.zm_transit_burn_max_duration = 2;
	if ( !isDefined( level.vsmgr_prio_overlay_zm_transit_burn ) )
	{
		level.vsmgr_prio_overlay_zm_transit_burn = 20;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_transit_burn", 14000, level.vsmgr_prio_overlay_zm_transit_burn, 15, 1, maps/mp/_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
}

tomb_closest_player_override( v_zombie_origin, a_players_to_check ) //checked partially changed to match cerberus output see info.md
{
	e_player_to_attack = undefined;
	while ( !isDefined( e_player_to_attack ) )
	{
		e_player_to_attack = tomb_get_closest_player_using_paths( v_zombie_origin, a_players_to_check );
		a_players = maps/mp/zm_tomb_tank::get_players_on_tank( 1 );
		if ( a_players.size > 0 )
		{
			e_player_closest_on_tank = undefined;
			n_dist_tank_min = 99999999;
			foreach ( e_player in a_players )
			{
				n_dist_sq = distance2dsquared( self.origin, e_player.origin );
				if ( n_dist_sq < n_dist_tank_min )
				{
					n_dist_tank_min = n_dist_sq;
					e_player_closest_on_tank = e_player;
				}
			}
			if ( is_player_valid( e_player_to_attack ) )
			{
				n_dist_for_path = distance2dsquared( self.origin, e_player_to_attack.origin );
				if ( n_dist_tank_min < n_dist_for_path )
				{
					e_player_to_attack = e_player_closest_on_tank;
				}
			}
			else if ( is_player_valid( e_player_closest_on_tank ) )
			{
				e_player_to_attack = e_player_closest_on_tank;
			}
		}
		wait 0.5;
	}
	return e_player_to_attack;
}

zm_tomb_get_round_enemy_array() //checked changed to match cerberus output see info.md
{
	enemies = [];
	valid_enemies = [];
	enemies = getaispeciesarray( level.zombie_team, "all" );
	for ( i = 0; i < enemies.size; i++ )
	{
		if ( ( !isDefined( enemies[ i ].script_noteworthy ) || enemies[ i ].script_noteworthy != "capture_zombie" ) && isDefined( enemies[ i ].ignore_enemy_count ) && enemies[ i ].ignore_enemy_count )
		{
		}
		else
		{
			valid_enemies[ valid_enemies.size ] = enemies[ i ];
		}
	}
	return valid_enemies;
}

tomb_player_damage_callback( e_inflictor, e_attacker, n_damage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name ) //checked did not change to match cerberus output changed at own discretion
{
	if ( isDefined( str_weapon ) )
	{
		if ( issubstr( str_weapon, "staff" ) )
		{
			return 0;
		}
		if ( str_weapon == "t72_turret" )
		{
			return 0;
		}
		if ( str_weapon == "quadrotorturret_zm" || str_weapon == "quadrotorturret_upgraded_zm" )
		{
			return 0;
		}
		if ( str_weapon == "zombie_markiv_side_cannon" )
		{
			return 0;
		}
		if ( str_weapon == "zombie_markiv_turret" )
		{
			return 0;
		}
		if ( str_weapon == "zombie_markiv_cannon" )
		{
			return 0;
		}
	}
	return n_damage;
}

tomb_random_perk_weights() //checked matches cerberus output
{
	temp_array = [];
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_rof", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_deadshot", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_additionalprimaryweapon", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_flakjacket", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_grenadepulldeath", 0 );
	}
	temp_array = array_randomize( temp_array );
	level._random_perk_machine_perk_list = array_randomize( level._random_perk_machine_perk_list );
	level._random_perk_machine_perk_list = arraycombine( level._random_perk_machine_perk_list, temp_array, 1, 0 );
	keys = getarraykeys( level._random_perk_machine_perk_list );
	return keys;
}

level_precache() //checked matches cerberus output
{
	precacheshader( "specialty_zomblood_zombies" );
	precachemodel( "c_zom_guard" );
	precachemodel( "p6_zm_tm_orb_fire" );
	precachemodel( "p6_zm_tm_orb_wind" );
	precachemodel( "p6_zm_tm_orb_lightning" );
	precachemodel( "p6_zm_tm_orb_ice" );
	precachemodel( "fx_tomb_vortex_beam_mesh" );
	precachemodel( "fxuse_sky_pillar_new" );
}

on_player_connect() //checked matches cerberus output
{
	self thread revive_watcher();
	wait_network_frame();
	self thread player_slow_movement_speed_monitor();
	self thread sndmeleewpnsound();
}

sndmeleewpnsound() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	level endon( "end_game" );
	while ( 1 )
	{
		while ( !self ismeleeing() )
		{
			wait 0.05;
		}
		current_melee_weapon = self get_player_melee_weapon();
		current_weapon = self getcurrentweapon();
		if ( current_weapon == "tomb_shield_zm" )
		{
			self playsound( "fly_riotshield_zm_swing" );
			while ( self ismeleeing() )
			{
				wait 0.05;
			}
			continue;
		}
		alias = "zmb_melee_whoosh_";
		if ( isDefined( self.is_player_zombie ) && self.is_player_zombie )
		{
			alias = "zmb_melee_whoosh_zmb_";
		}
		else if ( current_melee_weapon == "bowie_knife_zm" )
		{
			alias = "zmb_bowie_swing_";
		}
		else if ( current_melee_weapon == "one_inch_punch_zm" )
		{
			alias = "wpn_one_inch_punch_";
		}
		else if ( current_melee_weapon == "one_inch_punch_upgraded_zm" )
		{
			alias = "wpn_one_inch_punch_";
		}
		else if ( current_melee_weapon == "one_inch_punch_fire_zm" )
		{
			alias = "wpn_one_inch_punch_fire_";
		}
		else if ( current_melee_weapon == "one_inch_punch_air_zm" )
		{
			alias = "wpn_one_inch_punch_air_";
		}
		else if ( current_melee_weapon == "one_inch_punch_ice_zm" )
		{
			alias = "wpn_one_inch_punch_ice_";
		}
		else if ( current_melee_weapon == "one_inch_punch_lightning_zm" )
		{
			alias = "wpn_one_inch_punch_lightning_";
		}
		else if ( sndmeleewpn_isstaff( current_melee_weapon ) )
		{
			alias = "zmb_melee_staff_upgraded_";
		}
		self playsoundtoplayer( alias + "plr", self );
		wait_network_frame();
		if ( maps/mp/zombies/_zm_audio::sndisnetworksafe() )
		{
			self playsound( alias + "npc" );
		}
		while ( self ismeleeing() )
		{
			wait 0.05;
		}
		wait 0.05;
	}
}

sndmeleewpn_isstaff( weapon ) //checked matches cerberus output
{
	switch( weapon )
	{
		case "staff_air_melee_zm":
		case "staff_fire_melee_zm":
		case "staff_lightning_melee_zm":
		case "staff_melee_zm":
		case "staff_watermelee_zm":
			isstaff = 1;
			break;
		default:
			isstaff = 0;
	}
	return isstaff;
}

revive_watcher() //checked matches cerberus output
{
	self endon( "death_or_disconnect" );
	while ( 1 )
	{
		self waittill( "do_revive_ended_normally" );
		if ( self hasperk( "specialty_quickrevive" ) )
		{
			self notify( "quick_revived_player" );
		}
		else
		{
			self notify( "revived_player" );
		}
	}
}

setup_tomb_spawn_groups() //checked matches cerberus output
{
	level.use_multiple_spawns = 1;
	level.spawner_int = 1;
	level waittill( "start_zombie_round_logic" );
	level.zones[ "ug_bottom_zone" ].script_int = 2;
	level.zones[ "zone_nml_19" ].script_int = 2;
	level.zones[ "zone_chamber_0" ].script_int = 3;
	level.zones[ "zone_chamber_1" ].script_int = 3;
	level.zones[ "zone_chamber_2" ].script_int = 3;
	level.zones[ "zone_chamber_3" ].script_int = 3;
	level.zones[ "zone_chamber_4" ].script_int = 3;
	level.zones[ "zone_chamber_5" ].script_int = 3;
	level.zones[ "zone_chamber_6" ].script_int = 3;
	level.zones[ "zone_chamber_7" ].script_int = 3;
	level.zones[ "zone_chamber_8" ].script_int = 3;
	level.zones[ "zone_ice_stairs" ].script_int = 2;
	level.zones[ "zone_bolt_stairs" ].script_int = 2;
	level.zones[ "zone_air_stairs" ].script_int = 2;
	level.zones[ "zone_fire_stairs" ].script_int = 2;
	level.zones[ "zone_bolt_stairs_1" ].script_int = 2;
	level.zones[ "zone_air_stairs_1" ].script_int = 2;
	level.zones[ "zone_fire_stairs_1" ].script_int = 2;
}

chamber_capture_zombie_spawn_init() //checked matches cerberus output
{
	self endon( "death" );
	self waittill( "completed_emerging_into_playable_area" );
	self setclientfield( "zone_capture_zombie", 1 );
}

tomb_round_spawn_failsafe() //checked changed to match cerberus output
{
	self endon( "death" );
	prevorigin = self.origin;
	while ( 1 )
	{
		if ( isDefined( self.ignore_round_spawn_failsafe ) && self.ignore_round_spawn_failsafe )
		{
			return;
		}
		wait 15;
		if ( isDefined( self.is_inert ) && self.is_inert )
		{
			continue;
		}
		if ( isDefined( self.lastchunk_destroy_time ) )
		{
			if ( ( getTime() - self.lastchunk_destroy_time ) < 8000 )
			{
				continue;
			}
		}
		if ( self.origin[ 2 ] < -3000 )
		{
			if ( isDefined( level.put_timed_out_zombies_back_in_queue ) && level.put_timed_out_zombies_back_in_queue && !flag( "dog_round" ) && isDefined( self.isscreecher ) && !self.isscreecher )
			{
				level.zombie_total++;
				level.zombie_total_subtract++;
			}
			self dodamage( self.health + 100, ( 0, 0, 0 ) );
			break;
		}
		if ( distancesquared( self.origin, prevorigin ) < 576 )
		{
			if ( isDefined( level.put_timed_out_zombies_back_in_queue ) && level.put_timed_out_zombies_back_in_queue && !flag( "dog_round" ) )
			{
				if ( !self.ignoreall && isDefined( self.nuked ) && !self.nuked && isDefined( self.marked_for_death ) && !self.marked_for_death && isDefined( self.isscreecher ) && !self.isscreecher && isDefined( self.has_legs ) && self.has_legs && isDefined( self.is_brutus ) && !self.is_brutus )
				{
					level.zombie_total++;
					level.zombie_total_subtract++;
				}
			}
			level.zombies_timeout_playspace++;
			self dodamage( self.health + 100, ( 0, 0, 0 ) );
			break;
		}
		prevorigin = self.origin;
	}
}

givecustomloadout( takeallweapons, alreadyspawned ) //checked matches cerberus output
{
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
}

precache_team_characters() //checked matches cerberus output
{
	precachemodel( "c_zom_player_cdc_fb" );
	precachemodel( "c_zom_hazmat_viewhands" );
	precachemodel( "c_zom_player_cia_fb" );
	precachemodel( "c_zom_suit_viewhands" );
}

precache_personality_characters() //checked matches cerberus output
{
	character/c_usa_dempsey_dlc4::precache();
	character/c_rus_nikolai_dlc4::precache();
	character/c_ger_richtofen_dlc4::precache();
	character/c_jap_takeo_dlc4::precache();
	precachemodel( "c_zom_richtofen_viewhands" );
	precachemodel( "c_zom_nikolai_viewhands" );
	precachemodel( "c_zom_takeo_viewhands" );
	precachemodel( "c_zom_dempsey_viewhands" );
}

give_personality_characters() //checked matches cerberus output could not find dvar
{
	if ( isDefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_arlington_coat_viewhands" ) )
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
	/*
/#
	if ( getDvar( #"40772CF1" ) != "" )
	{
		self.characterindex = getDvarInt( #"40772CF1" );
#/
	}
	*/
	switch( self.characterindex )
	{
		case 0:
			self character/c_usa_dempsey_dlc4::main();
			self setviewmodel( "c_zom_dempsey_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self set_player_is_female( 0 );
			self.character_name = "Dempsey";
			break;
		case 1:
			self character/c_rus_nikolai_dlc4::main();
			self setviewmodel( "c_zom_nikolai_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self set_player_is_female( 0 );
			self.character_name = "Nikolai";
			break;
		case 2:
			self character/c_ger_richtofen_dlc4::main();
			self setviewmodel( "c_zom_richtofen_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self set_player_is_female( 0 );
			self.character_name = "Richtofen";
			break;
		case 3:
			self character/c_jap_takeo_dlc4::main();
			self setviewmodel( "c_zom_takeo_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self set_player_is_female( 0 );
			self.character_name = "Takeo";
			break;
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self thread set_exert_id();
}

set_exert_id() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait_network_frame();
	wait_network_frame();
	self maps/mp/zombies/_zm_audio::setexertvoice( self.characterindex + 1 );
}

assign_lowest_unused_character_index() //checked changed to match cerberus output
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
		if ( charindexarray[ 0 ] == 2 )
		{
			level.has_richtofen = 1;
		}
		return charindexarray[ 0 ];
	}
	else
	{
		n_characters_defined = 0;
		foreach ( player in players )
		{
			if ( isDefined( player.characterindex ) )
			{
				arrayremovevalue( charindexarray, player.characterindex, 0 );
				n_characters_defined++;
			}
		}
		if ( charindexarray.size > 0 )
		{
			if ( n_characters_defined == ( players.size - 1 ) )
			{
				if ( !is_true( level.has_richtofen ) )
				{
					level.has_richtofen = 1;
					return 2;
				}
			}
			charindexarray = array_randomize( charindexarray );
			if ( charindexarray[ 0 ] == 2 )
			{
				level.has_richtofen = 1;
			}
			return charindexarray[ 0 ];
		}
	}
	return 0;
}

give_team_characters() //checked matches cerberus output
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
			self setmodel( "c_zom_player_cia_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_suit_viewhands" );
			self.characterindex = 0;
			break;
		case 1:
		case 3:
			self setmodel( "c_zom_player_cdc_fb" );
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

initcharacterstartindex() //checked matches cerberus output
{
	level.characterstartindex = randomint( 4 );
}

zm_player_fake_death_cleanup() //checked matches cerberus output
{
	if ( isDefined( self._fall_down_anchor ) )
	{
		self._fall_down_anchor delete();
		self._fall_down_anchor = undefined;
	}
}

zm_player_fake_death( vdir ) //checked matches cerberus output
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
		wait 0.25;
		self freezecontrols( 1 );
	}
	else
	{
		self freezecontrols( 1 );
		self thread fall_down( vdir, stance );
		wait 1;
	}
}

fall_down( vdir, stance ) //checked matches cerberus output
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
		lerptime = 0.5;
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
		origin = ( origin + ( 0, 0, bounce ) ) - ( xyspeed * 0.1 );
		lerptime = bounce / 50;
		linker moveto( origin, lerptime, 0, lerptime );
		linker waittill( "movedone" );
		origin = ( origin + ( 0, 0, bounce * -1 ) ) + ( xyspeed * 0.1 );
		lerptime /= 2;
		linker moveto( origin, lerptime, lerptime );
		linker waittill( "movedone" );
		linker moveto( origin, 5, 0 );
	}
	wait 15;
	linker delete();
}

initial_round_wait_func() //checked matches cerberus output
{
	flag_wait( "initial_blackscreen_passed" );
}

offhand_weapon_overrride() //checked matches cerberus output
{
	register_lethal_grenade_for_level( "frag_grenade_zm" );
	level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
	register_lethal_grenade_for_level( "sticky_grenade_zm" );
	register_tactical_grenade_for_level( "cymbal_monkey_zm" );
	register_tactical_grenade_for_level( "emp_grenade_zm" );
	register_tactical_grenade_for_level( "beacon_zm" );
	register_placeable_mine_for_level( "claymore_zm" );
	register_melee_weapon_for_level( "knife_zm" );
	register_melee_weapon_for_level( "staff_air_melee_zm" );
	register_melee_weapon_for_level( "staff_fire_melee_zm" );
	register_melee_weapon_for_level( "staff_lightning_melee_zm" );
	register_melee_weapon_for_level( "staff_water_melee_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm";
	register_equipment_for_level( "tomb_shield_zm" );
	level.zombie_equipment_player_init = undefined;
	level.equipment_safe_to_drop = ::equipment_safe_to_drop;
}

equipment_safe_to_drop( weapon ) //checked matches cerberus output
{
	if ( !isDefined( self.origin ) )
	{
		return 1;
	}
	return 1;
}

offhand_weapon_give_override( str_weapon ) //checked matches cerberus output
{
	self endon( "death" );
	if ( is_tactical_grenade( str_weapon ) && isDefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( str_weapon ) )
	{
		self setweaponammoclip( self get_player_tactical_grenade(), 0 );
		self takeweapon( self get_player_tactical_grenade() );
	}
	return 0;
}

tomb_weaponobjects_on_player_connect_override() //checked matches cerberus output
{
	level.retrievable_knife_init_names = [];
	onplayerconnect_callback( ::weaponobjects_on_player_connect_override_internal );
}

tomb_player_intersection_tracker_override( e_player ) //checked changed to match cerberus output
{
	if ( isDefined( e_player.b_already_on_tank ) && e_player.b_already_on_tank || isDefined( self.b_already_on_tank ) && self.b_already_on_tank )
	{
		return 1;
	}
	if ( isDefined( e_player.giant_robot_transition ) && e_player.giant_robot_transition || isDefined( self.giant_robot_transition ) && self.giant_robot_transition )
	{
		return 1;
	}
	return 0;
}

init_tomb_stats() //checked matches cerberus output
{
	self maps/mp/zm_tomb_achievement::init_player_achievement_stats();
}

custom_add_weapons() //checked matches cerberus output
{
	level.laststandpistol = "c96_zm";
	level.default_laststandpistol = "c96_zm";
	level.default_solo_laststandpistol = "c96_upgraded_zm";
	level.start_weapon = "c96_zm";
	add_zombie_weapon( "mg08_zm", "mg08_upgraded_zm", &"ZOMBIE_WEAPON_MG08", 50, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon( "type95_zm", "type95_upgraded_zm", &"ZOMBIE_WEAPON_TYPE95", 50, "wpck_rifle", "", undefined, 1 );
	add_zombie_weapon( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_rifle", "", undefined, 1 );
	add_zombie_weapon( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_rifle", "", undefined, 1 );
	add_zombie_weapon( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "wpck_rifle", "", undefined, 1 );
	add_zombie_weapon( "mp44_zm", "mp44_upgraded_zm", &"ZMWEAPON_MP44_WALLBUY", 1400, "wpck_rifle", "", undefined, 1 );
	add_zombie_weapon( "scar_zm", "scar_upgraded_zm", &"ZOMBIE_WEAPON_SCAR", 50, "wpck_rifle", "", undefined, 1 );
	add_zombie_weapon( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 900, "wpck_shotgun", "", undefined, 1 );
	add_zombie_weapon( "srm1216_zm", "srm1216_upgraded_zm", &"ZOMBIE_WEAPON_SRM1216", 50, "wpck_shotgun", "", undefined, 1 );
	add_zombie_weapon( "ksg_zm", "ksg_upgraded_zm", &"ZOMBIE_WEAPON_KSG", 1100, "wpck_shotgun", "", undefined, 1 );
	add_zombie_weapon( "ak74u_zm", "ak74u_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "ak74u_extclip_zm", "ak74u_extclip_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "pdw57_zm", "pdw57_upgraded_zm", &"ZOMBIE_WEAPON_PDW57", 1000, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "thompson_zm", "thompson_upgraded_zm", &"ZMWEAPON_THOMPSON_WALLBUY", 1500, "wpck_smg", "", 800, 1 );
	add_zombie_weapon( "qcw05_zm", "qcw05_upgraded_zm", &"ZOMBIE_WEAPON_QCW05", 50, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "mp40_zm", "mp40_upgraded_zm", &"ZOMBIE_WEAPON_MP40", 1300, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "mp40_stalker_zm", "mp40_stalker_upgraded_zm", &"ZOMBIE_WEAPON_MP40", 1300, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "evoskorpion_zm", "evoskorpion_upgraded_zm", &"ZOMBIE_WEAPON_EVOSKORPION", 50, "wpck_smg", "", undefined, 1 );
	add_zombie_weapon( "ballista_zm", "ballista_upgraded_zm", &"ZMWEAPON_BALLISTA_WALLBUY", 500, "wpck_snipe", "", undefined, 1 );
	add_zombie_weapon( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_snipe", "", undefined, 1 );
	add_zombie_weapon( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon( "beretta93r_extclip_zm", "beretta93r_extclip_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon( "kard_zm", "kard_upgraded_zm", &"ZOMBIE_WEAPON_KARD", 50, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 1100, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon( "python_zm", "python_upgraded_zm", &"ZOMBIE_WEAPON_PYTHON", 50, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon( "c96_zm", "c96_upgraded_zm", &"ZOMBIE_WEAPON_C96", 50, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_duel", "", undefined, 1 );
	add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_crappy", "", undefined, 1 );
	add_zombie_weapon( "beacon_zm", undefined, &"ZOMBIE_WEAPON_BEACON", 2000, "wpck_explo", "", undefined, 1 );
	add_zombie_weapon( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1000, "wpck_explo", "", undefined, 1 );
	add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "wpck_explo", "", 250 );
	add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
	if ( isDefined( level.raygun2_included ) && level.raygun2_included )
	{
		add_zombie_weapon( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "wpck_raymk2", "", undefined );
	}
	add_zombie_weapon( "sticky_grenade_zm", undefined, &"ZOMBIE_WEAPON_STICKY_GRENADE", 250, "wpck_explo", "", 250 );
	add_zombie_weapon( "staff_air_zm", undefined, &"AIR_STAFF", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_air_upgraded_zm", undefined, &"AIR_STAFF_CHARGED", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_fire_zm", undefined, &"FIRE_STAFF", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_fire_upgraded_zm", undefined, &"FIRE_STAFF_CHARGED", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_lightning_zm", undefined, &"LIGHTNING_STAFF", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_lightning_upgraded_zm", undefined, &"LIGHTNING_STAFF_CHARGED", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_water_zm", undefined, &"WATER_STAFF", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_water_zm_cheap", undefined, &"WATER_STAFF", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_water_upgraded_zm", undefined, &"WATER_STAFF_CHARGED", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "staff_revive_zm", undefined, &"ZM_TOMB_WEAP_STAFF_REVIVE", 50, "wpck_rpg", "", undefined, 1 );
	change_weapon_cost( "mp40_zm", 1300 );
	level.weapons_using_ammo_sharing = 1;
	add_shared_ammo_weapon( "ak74u_extclip_zm", "ak74u_zm" );
	add_shared_ammo_weapon( "mp40_stalker_zm", "mp40_zm" );
	add_shared_ammo_weapon( "beretta93r_extclip_zm", "beretta93r_zm" );
}

include_weapons() //checked matches cerberus output
{
	include_weapon( "hamr_zm" );
	include_weapon( "hamr_upgraded_zm", 0 );
	include_weapon( "mg08_zm" );
	include_weapon( "mg08_upgraded_zm", 0 );
	include_weapon( "type95_zm" );
	include_weapon( "type95_upgraded_zm", 0 );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", 0 );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", 0 );
	include_weapon( "m14_zm", 0 );
	include_weapon( "m14_upgraded_zm", 0 );
	include_weapon( "mp44_zm", 0 );
	include_weapon( "mp44_upgraded_zm", 0 );
	include_weapon( "scar_zm" );
	include_weapon( "scar_upgraded_zm", 0 );
	include_weapon( "870mcs_zm", 0 );
	include_weapon( "870mcs_upgraded_zm", 0 );
	include_weapon( "ksg_zm" );
	include_weapon( "ksg_upgraded_zm", 0 );
	include_weapon( "srm1216_zm" );
	include_weapon( "srm1216_upgraded_zm", 0 );
	include_weapon( "ak74u_zm", 0 );
	include_weapon( "ak74u_upgraded_zm", 0 );
	include_weapon( "ak74u_extclip_zm" );
	include_weapon( "ak74u_extclip_upgraded_zm", 0 );
	include_weapon( "pdw57_zm" );
	include_weapon( "pdw57_upgraded_zm", 0 );
	include_weapon( "thompson_zm" );
	include_weapon( "thompson_upgraded_zm", 0 );
	include_weapon( "qcw05_zm" );
	include_weapon( "qcw05_upgraded_zm", 0 );
	include_weapon( "mp40_zm", 0 );
	include_weapon( "mp40_upgraded_zm", 0 );
	include_weapon( "mp40_stalker_zm" );
	include_weapon( "mp40_stalker_upgraded_zm", 0 );
	include_weapon( "evoskorpion_zm" );
	include_weapon( "evoskorpion_upgraded_zm", 0 );
	include_weapon( "ballista_zm", 0 );
	include_weapon( "ballista_upgraded_zm", 0 );
	include_weapon( "dsr50_zm" );
	include_weapon( "dsr50_upgraded_zm", 0 );
	include_weapon( "beretta93r_zm", 0 );
	include_weapon( "beretta93r_upgraded_zm", 0 );
	include_weapon( "beretta93r_extclip_zm" );
	include_weapon( "beretta93r_extclip_upgraded_zm", 0 );
	include_weapon( "kard_zm" );
	include_weapon( "kard_upgraded_zm", 0 );
	include_weapon( "fiveseven_zm", 0 );
	include_weapon( "fiveseven_upgraded_zm", 0 );
	include_weapon( "python_zm" );
	include_weapon( "python_upgraded_zm", 0 );
	include_weapon( "c96_zm", 0 );
	include_weapon( "c96_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "m32_zm" );
	include_weapon( "m32_upgraded_zm", 0 );
	include_weapon( "beacon_zm", 0 );
	include_weapon( "claymore_zm", 0 );
	include_weapon( "cymbal_monkey_zm" );
	include_weapon( "frag_grenade_zm", 0 );
	include_weapon( "knife_zm", 0 );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", 0 );
	include_weapon( "sticky_grenade_zm", 0 );
	include_weapon( "tomb_shield_zm", 0 );
	add_limited_weapon( "c96_zm", 0 );
	add_limited_weapon( "ray_gun_zm", 4 );
	add_limited_weapon( "ray_gun_upgraded_zm", 4 );
	include_weapon( "staff_air_zm", 0 );
	include_weapon( "staff_air_upgraded_zm", 0 );
	precacheitem( "staff_air_upgraded2_zm" );
	precacheitem( "staff_air_upgraded3_zm" );
	include_weapon( "staff_fire_zm", 0 );
	include_weapon( "staff_fire_upgraded_zm", 0 );
	precacheitem( "staff_fire_upgraded2_zm" );
	precacheitem( "staff_fire_upgraded3_zm" );
	include_weapon( "staff_lightning_zm", 0 );
	include_weapon( "staff_lightning_upgraded_zm", 0 );
	precacheitem( "staff_lightning_upgraded2_zm" );
	precacheitem( "staff_lightning_upgraded3_zm" );
	include_weapon( "staff_water_zm", 0 );
	include_weapon( "staff_water_zm_cheap", 0 );
	include_weapon( "staff_water_upgraded_zm", 0 );
	precacheitem( "staff_water_upgraded2_zm" );
	precacheitem( "staff_water_upgraded3_zm" );
	include_weapon( "staff_revive_zm", 0 );
	add_limited_weapon( "staff_air_zm", 0 );
	add_limited_weapon( "staff_air_upgraded_zm", 0 );
	add_limited_weapon( "staff_fire_zm", 0 );
	add_limited_weapon( "staff_fire_upgraded_zm", 0 );
	add_limited_weapon( "staff_lightning_zm", 0 );
	add_limited_weapon( "staff_lightning_upgraded_zm", 0 );
	add_limited_weapon( "staff_water_zm", 0 );
	add_limited_weapon( "staff_water_zm_cheap", 0 );
	add_limited_weapon( "staff_water_upgraded_zm", 0 );
	if ( isDefined( level.raygun2_included ) && level.raygun2_included )
	{
		include_weapon( "raygun_mark2_zm", 1 );
		include_weapon( "raygun_mark2_upgraded_zm", 0 );
		add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
		add_limited_weapon( "raygun_mark2_zm", 1 );
		add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
	}
}

include_powerups() //checked matches cerberus output
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "fire_sale" );
	include_powerup( "free_perk" );
	include_powerup( "zombie_blood" );
	include_powerup( "bonus_points_player" );
	include_powerup( "bonus_points_team" );
	level.level_specific_init_powerups = ::tomb_powerup_init;
	level._zombiemode_powerup_grab = ::tomb_powerup_grab;
	/*
/#
	setup_powerup_devgui();
#/
/#
	setup_oneinchpunch_devgui();
#/
/#
	setup_tablet_devgui();
#/
	*/
}

include_perks_in_random_rotation() //checked matches cerberus output
{
	include_perk_in_random_rotation( "specialty_armorvest" );
	include_perk_in_random_rotation( "specialty_quickrevive" );
	include_perk_in_random_rotation( "specialty_fastreload" );
	include_perk_in_random_rotation( "specialty_rof" );
	include_perk_in_random_rotation( "specialty_longersprint" );
	include_perk_in_random_rotation( "specialty_deadshot" );
	include_perk_in_random_rotation( "specialty_additionalprimaryweapon" );
	include_perk_in_random_rotation( "specialty_flakjacket" );
	include_perk_in_random_rotation( "specialty_grenadepulldeath" );
	level.custom_random_perk_weights = ::tomb_random_perk_weights;
}

tomb_powerup_init() //checked matches cerberus output
{
	maps/mp/zombies/_zm_powerup_zombie_blood::init( "c_zom_tomb_german_player_fb" );
}

tomb_powerup_grab( s_powerup, e_player ) //checked matches cerberus output
{
	if ( s_powerup.powerup_name == "zombie_blood" )
	{
		level thread maps/mp/zombies/_zm_powerup_zombie_blood::zombie_blood_powerup( s_powerup, e_player );
	}
}

setup_powerup_devgui() //checked matches cerberus output
{
	/*
/#
	setdvar( "zombie_blood", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Power Ups:2/Now:1/Drop Zombie Blood:1" "zombie_blood on"\n" );
	level thread watch_devgui_zombie_blood();
#/
	*/
}

setup_oneinchpunch_devgui() //checked matches cerberus output
{
	/*
/#
	setdvar( "test_oneinchpunch", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/OneInchPunch:2/OneInchPunch:1" "test_oneinchpunch on"\n" );
	setdvar( "test_oneinchpunch_upgraded", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/OneInchPunch:2/OneInchPunch_Upgraded:1" "test_oneinchpunch_upgraded on"\n" );
	setdvar( "test_oneinchpunch_air", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/OneInchPunch:2/OneInchPunch_Air:1" "test_oneinchpunch_air on"\n" );
	setdvar( "test_oneinchpunch_fire", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/OneInchPunch:2/OneInchPunch_Fire:1" "test_oneinchpunch_fire on"\n" );
	setdvar( "test_oneinchpunch_ice", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/OneInchPunch:2/OneInchPunch_Ice:1" "test_oneinchpunch_ice on"\n" );
	setdvar( "test_oneinchpunch_lightning", "off" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/OneInchPunch:2/OneInchPunch_Lightning:1" "test_oneinchpunch_lightning on"\n" );
	level thread watch_devgui_oneinchpunch();
#/
	*/
}

watch_devgui_oneinchpunch() //checked matches cerberus output
{
	/*
/#
	while ( 1 )
	{
		if ( getDvar( "test_oneinchpunch" ) == "on" )
		{
			setdvar( "test_oneinchpunch", "off" );
			player = get_players()[ 0 ];
			player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
		}
		else if ( getDvar( "test_oneinchpunch_upgraded" ) == "on" )
		{
			setdvar( "test_oneinchpunch_upgraded", "off" );
			player = get_players()[ 0 ];
			player.b_punch_upgraded = 1;
			player.str_punch_element = "upgraded";
			player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
		}
		else if ( getDvar( "test_oneinchpunch_air" ) == "on" )
		{
			setdvar( "test_oneinchpunch_air", "off" );
			player = get_players()[ 0 ];
			player.b_punch_upgraded = 1;
			player.str_punch_element = "air";
			player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
		}
		else if ( getDvar( "test_oneinchpunch_fire" ) == "on" )
		{
			setdvar( "test_oneinchpunch_fire", "off" );
			player = get_players()[ 0 ];
			player.b_punch_upgraded = 1;
			player.str_punch_element = "fire";
			player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
		}
		else if ( getDvar( "test_oneinchpunch_ice" ) == "on" )
		{
			setdvar( "test_oneinchpunch_ice", "off" );
			player = get_players()[ 0 ];
			player.b_punch_upgraded = 1;
			player.str_punch_element = "ice";
			player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
		}
		else
		{
			if ( getDvar( "test_oneinchpunch_lightning" ) == "on" )
			{
				setdvar( "test_oneinchpunch_lightning", "off" );
				player = get_players()[ 0 ];
				player.b_punch_upgraded = 1;
				player.str_punch_element = "lightning";
				player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
			}
		}
		wait 0.1;
#/
	}
	*/
}

setup_tablet_devgui() //checked matches cerberus output
{
	/*
/#
	setdvar( "test_player_tablet", "3" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/Easter Ann:3/Tablet-None:1" "test_player_tablet 0"\n" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/Easter Ann:3/Tablet-Clean:1" "test_player_tablet 1"\n" );
	adddebugcommand( "devgui_cmd "Zombies:2/Tomb:1/Easter Ann:3/Tablet-Dirty:1" "test_player_tablet 2"\n" );
	level thread watch_devgui_tablet();
#/
	*/
}

watch_devgui_tablet() //checked matches cerberus output
{
	/*
/#
	while ( 1 )
	{
		if ( getDvar( "test_player_tablet" ) != "3" )
		{
			player = get_players()[ 0 ];
			n_tablet_state = int( getDvar( "test_player_tablet" ) );
			player setclientfieldtoplayer( "player_tablet_state", n_tablet_state );
			setdvar( "test_player_tablet", "3" );
		}
		wait 0.1;
#/
	}
	*/
}

watch_devgui_zombie_blood() //checked matches cerberus output
{
	/*
/#
	while ( 1 )
	{
		if ( getDvar( "zombie_blood" ) == "on" )
		{
			setdvar( "zombie_blood", "off" );
			level thread maps/mp/zombies/_zm_devgui::zombie_devgui_give_powerup( "zombie_blood", 1 );
		}
		wait 0.1;
#/
	}
	*/
}

watch_devgui_double_points() //checked matches cerberus output
{
	/*
/#
	while ( 1 )
	{
		if ( getDvar( "double_points" ) == "on" )
		{
			setdvar( "double_points", "off" );
			level thread maps/mp/zombies/_zm_devgui::zombie_devgui_give_powerup( "double_points", 1 );
			iprintlnbold( "change" );
		}
		wait 0.1;
#/
	}
	*/
}

setup_rex_starts() //checked matches cerberus output
{
	add_gametype( "zclassic", ::dummy, "zclassic", ::dummy );
	add_gameloc( "tomb", ::dummy, "tomb", ::dummy );
}

dummy() //checked matches cerberus output
{
}

working_zone_init() //checked matches cerberus output
{
	flag_init( "always_on" );
	flag_set( "always_on" );
	add_adjacent_zone( "zone_robot_head", "zone_robot_head", "always_on" );
	add_adjacent_zone( "zone_start", "zone_start_a", "always_on" );
	add_adjacent_zone( "zone_start", "zone_start_b", "always_on" );
	add_adjacent_zone( "zone_start_a", "zone_start_b", "always_on" );
	add_adjacent_zone( "zone_start_a", "zone_bunker_1a", "activate_zone_bunker_1" );
	add_adjacent_zone( "zone_bunker_1a", "zone_bunker_1", "activate_zone_bunker_1" );
	add_adjacent_zone( "zone_bunker_1a", "zone_bunker_1", "activate_zone_bunker_3a" );
	add_adjacent_zone( "zone_bunker_1", "zone_bunker_3a", "activate_zone_bunker_3a" );
	add_adjacent_zone( "zone_bunker_3a", "zone_bunker_3b", "activate_zone_bunker_3a" );
	add_adjacent_zone( "zone_bunker_3a", "zone_bunker_3b", "activate_zone_bunker_3b" );
	add_adjacent_zone( "zone_bunker_3b", "zone_bunker_5a", "activate_zone_bunker_3b" );
	add_adjacent_zone( "zone_bunker_5a", "zone_bunker_5b", "activate_zone_bunker_3b" );
	add_adjacent_zone( "zone_start_b", "zone_bunker_2a", "activate_zone_bunker_2" );
	add_adjacent_zone( "zone_bunker_2a", "zone_bunker_2", "activate_zone_bunker_2" );
	add_adjacent_zone( "zone_bunker_2a", "zone_bunker_2", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_2", "zone_bunker_4a", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4a", "zone_bunker_4b", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4a", "zone_bunker_4c", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4b", "zone_bunker_4f", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4c", "zone_bunker_4d", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4c", "zone_bunker_4e", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4e", "zone_bunker_tank_c1", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4e", "zone_bunker_tank_d", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_tank_c", "zone_bunker_tank_c1", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_tank_d", "zone_bunker_tank_d1", "activate_zone_bunker_4a" );
	add_adjacent_zone( "zone_bunker_4a", "zone_bunker_4b", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4a", "zone_bunker_4c", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4b", "zone_bunker_4f", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4c", "zone_bunker_4d", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4c", "zone_bunker_4e", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4b", "zone_bunker_5a", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_5a", "zone_bunker_5b", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4e", "zone_bunker_tank_c1", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_4e", "zone_bunker_tank_d", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_tank_c", "zone_bunker_tank_c1", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_tank_d", "zone_bunker_tank_d1", "activate_zone_bunker_4b" );
	add_adjacent_zone( "zone_bunker_tank_a", "zone_nml_7", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_a", "zone_nml_7a", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_a", "zone_bunker_tank_a1", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_a1", "zone_bunker_tank_a2", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_a1", "zone_bunker_tank_b", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_b", "zone_bunker_tank_c", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_c", "zone_bunker_tank_c1", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_d", "zone_bunker_tank_d1", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_d1", "zone_bunker_tank_e", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_e", "zone_bunker_tank_e1", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_e1", "zone_bunker_tank_e2", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_e1", "zone_bunker_tank_f", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_tank_f", "zone_nml_1", "activate_zone_nml" );
	add_adjacent_zone( "zone_bunker_5b", "zone_nml_2a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_0", "zone_nml_1", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_0", "zone_nml_farm", "activate_zone_farm" );
	add_adjacent_zone( "zone_nml_1", "zone_nml_2", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_1", "zone_nml_4", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_1", "zone_nml_20", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_2", "zone_nml_2a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_2", "zone_nml_2b", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_2", "zone_nml_3", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_3", "zone_nml_4", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_3", "zone_nml_13", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_4", "zone_nml_5", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_4", "zone_nml_13", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_5", "zone_nml_farm", "activate_zone_farm" );
	add_adjacent_zone( "zone_nml_6", "zone_nml_2b", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_6", "zone_nml_7", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_6", "zone_nml_7a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_6", "zone_nml_8", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_7", "zone_nml_7a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_7", "zone_nml_9", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_7", "zone_nml_10", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_8", "zone_nml_10a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_8", "zone_nml_14", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_8", "zone_nml_16", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_9", "zone_nml_7a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_9", "zone_nml_9a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_9", "zone_nml_11", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_10", "zone_nml_10a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_10", "zone_nml_11", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_10a", "zone_nml_12", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_10a", "zone_village_4", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_11", "zone_nml_9a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_11", "zone_nml_11a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_11", "zone_nml_12", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_12", "zone_nml_11a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_12", "zone_nml_12a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_13", "zone_nml_15", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_14", "zone_nml_15", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_15", "zone_nml_17", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_15a", "zone_nml_14", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_15a", "zone_nml_15", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_16", "zone_nml_2b", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_16", "zone_nml_16a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_16", "zone_nml_18", "activate_zone_ruins" );
	add_adjacent_zone( "zone_nml_17", "zone_nml_17a", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_17", "zone_nml_18", "activate_zone_ruins" );
	add_adjacent_zone( "zone_nml_18", "zone_nml_19", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_farm", "zone_nml_celllar", "activate_zone_farm" );
	add_adjacent_zone( "zone_nml_farm", "zone_nml_farm_1", "activate_zone_farm" );
	add_adjacent_zone( "zone_nml_19", "ug_bottom_zone", "activate_zone_crypt" );
	add_adjacent_zone( "zone_village_0", "zone_nml_15", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_0", "zone_village_4b", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_1", "zone_village_1a", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_1", "zone_village_2", "activate_zone_village_1" );
	add_adjacent_zone( "zone_village_1", "zone_village_4b", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_1", "zone_village_5b", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_2", "zone_village_3", "activate_zone_village_1" );
	add_adjacent_zone( "zone_village_3", "zone_village_3a", "activate_zone_village_1" );
	add_adjacent_zone( "zone_village_3", "zone_ice_stairs", "activate_zone_village_1" );
	add_adjacent_zone( "zone_ice_stairs", "zone_ice_stairs_1", "activate_zone_village_1" );
	add_adjacent_zone( "zone_village_3a", "zone_village_3b", "activate_zone_village_1" );
	add_adjacent_zone( "zone_village_4", "zone_nml_14", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_4", "zone_village_4a", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_4", "zone_village_4b", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_5", "zone_nml_4", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_5", "zone_village_5a", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_5a", "zone_village_5b", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_6", "zone_village_5b", "activate_zone_village_0" );
	add_adjacent_zone( "zone_village_6", "zone_village_6a", "activate_zone_village_0" );
	add_adjacent_zone( "zone_chamber_0", "zone_chamber_1", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_0", "zone_chamber_3", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_0", "zone_chamber_4", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_1", "zone_chamber_2", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_1", "zone_chamber_3", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_1", "zone_chamber_4", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_1", "zone_chamber_5", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_2", "zone_chamber_4", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_2", "zone_chamber_5", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_3", "zone_chamber_4", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_3", "zone_chamber_6", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_3", "zone_chamber_7", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_4", "zone_chamber_5", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_4", "zone_chamber_6", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_4", "zone_chamber_7", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_4", "zone_chamber_8", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_5", "zone_chamber_7", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_5", "zone_chamber_8", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_6", "zone_chamber_7", "activate_zone_chamber" );
	add_adjacent_zone( "zone_chamber_7", "zone_chamber_8", "activate_zone_chamber" );
	add_adjacent_zone( "zone_bunker_1", "zone_bunker_1a", "activate_zone_bunker_1_tank" );
	add_adjacent_zone( "zone_bunker_1a", "zone_fire_stairs", "activate_zone_bunker_1_tank" );
	add_adjacent_zone( "zone_fire_stairs", "zone_fire_stairs_1", "activate_zone_bunker_1_tank" );
	add_adjacent_zone( "zone_bunker_2", "zone_bunker_2a", "activate_zone_bunker_2_tank" );
	add_adjacent_zone( "zone_bunker_4a", "zone_bunker_4b", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_4a", "zone_bunker_4c", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_4c", "zone_bunker_4d", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_4c", "zone_bunker_4e", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_4e", "zone_bunker_tank_c1", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_4e", "zone_bunker_tank_d", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_tank_c", "zone_bunker_tank_c1", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_tank_d", "zone_bunker_tank_d1", "activate_zone_bunker_4_tank" );
	add_adjacent_zone( "zone_bunker_tank_b", "zone_bunker_6", "activate_zone_bunker_6_tank" );
	add_adjacent_zone( "zone_bunker_1", "zone_bunker_6", "activate_zone_bunker_6_tank" );
	level thread activate_zone_trig( "trig_zone_bunker_1", "activate_zone_bunker_1_tank" );
	level thread activate_zone_trig( "trig_zone_bunker_2", "activate_zone_bunker_2_tank" );
	level thread activate_zone_trig( "trig_zone_bunker_4", "activate_zone_bunker_4_tank" );
	level thread activate_zone_trig( "trig_zone_bunker_6", "activate_zone_bunker_6_tank", "activate_zone_bunker_1_tank" );
	add_adjacent_zone( "zone_bunker_1a", "zone_fire_stairs", "activate_zone_bunker_1" );
	add_adjacent_zone( "zone_fire_stairs", "zone_fire_stairs_1", "activate_zone_bunker_1" );
	add_adjacent_zone( "zone_bunker_1a", "zone_fire_stairs", "activate_zone_bunker_3a" );
	add_adjacent_zone( "zone_fire_stairs", "zone_fire_stairs_1", "activate_zone_bunker_3a" );
	add_adjacent_zone( "zone_nml_9", "zone_air_stairs", "activate_zone_nml" );
	add_adjacent_zone( "zone_air_stairs", "zone_air_stairs_1", "activate_zone_nml" );
	add_adjacent_zone( "zone_nml_celllar", "zone_bolt_stairs", "activate_zone_farm" );
	add_adjacent_zone( "zone_bolt_stairs", "zone_bolt_stairs_1", "activate_zone_farm" );
}

activate_zone_trig( str_name, str_zone1, str_zone2 ) //checked matches cerberus output
{
	trig = getent( str_name, "targetname" );
	trig waittill( "trigger" );
	if ( isDefined( str_zone1 ) )
	{
		flag_set( str_zone1 );
	}
	if ( isDefined( str_zone2 ) )
	{
		flag_set( str_zone2 );
	}
	trig delete();
}

check_tank_platform_zone() //checked changed to match cerberus output
{
	while ( 1 )
	{
		level waittill( "newzoneActive", activezone );
		if ( activezone == "zone_bunker_3" )
		{
			break;
		}
		wait 1;
	}
	flag_set( "activate_zone_nml" );
}

tomb_vehicle_damage_override_wrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname ) //checked matches cerberus output
{
	if ( isDefined( level.a_func_vehicle_damage_override[ self.vehicletype ] ) )
	{
		return level.a_func_vehicle_damage_override[ self.vehicletype ];
	}
	return idamage;
}

drop_all_barriers() //checked changed to match cerberus output
{
	zkeys = getarraykeys( level.zones );
	for ( z = 0; z < level.zones.size; z++ )
	{
		zbarriers = get_all_zone_zbarriers( zkeys[ z ] );
		if ( !isDefined( zbarriers ) )
		{
			break;
		}
		else
		{
			foreach ( zbarrier in zbarriers )
			{
				zbarrier_pieces = zbarrier getnumzbarrierpieces();
				for ( i = 0; i < zbarrier_pieces; i++ )
				{
					zbarrier hidezbarrierpiece( i );
					zbarrier setzbarrierpiecestate( i, "open" );
				}
				wait 0.05;
			}
		}
	}
}

get_all_zone_zbarriers( zone_name ) //checked matches cerberus output
{
	if ( !isDefined( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
	return zone.zbarriers;
}

tomb_special_weapon_magicbox_check( weapon ) //checked matches cerberus output
{
	if ( isDefined( level.raygun2_included ) && level.raygun2_included )
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
			if ( randomint( 100 ) >= 33 )
			{
				return 0;
			}
		}
	}
	if ( weapon == "beacon_zm" )
	{
		if ( isDefined( self.beacon_ready ) && self.beacon_ready )
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	if ( isDefined( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
	{
		if ( self has_weapon_or_upgrade( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
		{
			return 0;
		}
	}
	return 1;
}

custom_vending_precaching() //checked changed to match cerberus output
{
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isDefined( level._custom_perks[ a_keys[ i ] ].precache_func ) )
			{
				level [[ level._custom_perks[ a_keys[ i ] ].precache_func ]]();
			}
		}
	}
	if ( isDefined( level.zombiemode_using_pack_a_punch ) && level.zombiemode_using_pack_a_punch )
	{
		precacheitem( "zombie_knuckle_crack" );
		precachemodel( "p6_anim_zm_buildable_pap" );
		precachemodel( "p6_anim_zm_buildable_pap_on" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
		level._effect[ "packapunch_fx" ] = loadfx( "maps/zombie/fx_zombie_packapunch" );
		level.machine_assets[ "packapunch" ] = spawnstruct();
		level.machine_assets[ "packapunch" ].weapon = "zombie_knuckle_crack";
	}
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		precacheitem( "zombie_perk_bottle_additionalprimaryweapon" );
		precacheshader( "specialty_additionalprimaryweapon_zombies" );
		precachemodel( "p6_zm_tm_vending_three_gun" );
		precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
		level._effect[ "additionalprimaryweapon_light" ] = loadfx( "misc/fx_zombie_cola_arsenal_on" );
		level.machine_assets[ "additionalprimaryweapon" ] = spawnstruct();
		level.machine_assets[ "additionalprimaryweapon" ].weapon = "zombie_perk_bottle_additionalprimaryweapon";
		level.machine_assets[ "additionalprimaryweapon" ].off_model = "p6_zm_tm_vending_three_gun";
		level.machine_assets[ "additionalprimaryweapon" ].on_model = "p6_zm_tm_vending_three_gun";
		level.machine_assets[ "additionalprimaryweapon" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "additionalprimaryweapon" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		precacheitem( "zombie_perk_bottle_deadshot" );
		precacheshader( "specialty_ads_zombies" );
		precachemodel( "zombie_vending_ads" );
		precachemodel( "zombie_vending_ads_on" );
		precachestring( &"ZOMBIE_PERK_DEADSHOT" );
		level._effect[ "deadshot_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
		level.machine_assets[ "deadshot" ] = spawnstruct();
		level.machine_assets[ "deadshot" ].weapon = "zombie_perk_bottle_deadshot";
		level.machine_assets[ "deadshot" ].off_model = "zombie_vending_ads";
		level.machine_assets[ "deadshot" ].on_model = "zombie_vending_ads_on";
		level.machine_assets[ "deadshot" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "deadshot" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
	{
		precacheitem( "zombie_perk_bottle_nuke" );
		precacheshader( "specialty_divetonuke_zombies" );
		precachemodel( "zombie_vending_nuke" );
		precachemodel( "zombie_vending_nuke_on" );
		precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
		level._effect[ "divetonuke_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
		level.machine_assets[ "divetonuke" ] = spawnstruct();
		level.machine_assets[ "divetonuke" ].weapon = "zombie_perk_bottle_nuke";
		level.machine_assets[ "divetonuke" ].off_model = "zombie_vending_nuke";
		level.machine_assets[ "divetonuke" ].on_model = "zombie_vending_nuke_on";
		level.machine_assets[ "divetonuke" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "divetonuke" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		precacheitem( "zombie_perk_bottle_doubletap" );
		precacheshader( "specialty_doubletap_zombies" );
		precachemodel( "zombie_vending_doubletap2" );
		precachemodel( "zombie_vending_doubletap2_on" );
		precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
		level._effect[ "doubletap_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
		level.machine_assets[ "doubletap" ] = spawnstruct();
		level.machine_assets[ "doubletap" ].weapon = "zombie_perk_bottle_doubletap";
		level.machine_assets[ "doubletap" ].off_model = "zombie_vending_doubletap2";
		level.machine_assets[ "doubletap" ].on_model = "zombie_vending_doubletap2_on";
		level.machine_assets[ "doubletap" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "doubletap" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		precacheitem( "zombie_perk_bottle_jugg" );
		precacheshader( "specialty_juggernaut_zombies" );
		precachemodel( "zombie_vending_jugg" );
		precachemodel( "zombie_vending_jugg_on" );
		precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
		level._effect[ "jugger_light" ] = loadfx( "misc/fx_zombie_cola_jugg_on" );
		level.machine_assets[ "juggernog" ] = spawnstruct();
		level.machine_assets[ "juggernog" ].weapon = "zombie_perk_bottle_jugg";
		level.machine_assets[ "juggernog" ].off_model = "zombie_vending_jugg";
		level.machine_assets[ "juggernog" ].on_model = "zombie_vending_jugg_on";
		level.machine_assets[ "juggernog" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "juggernog" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		precacheitem( "zombie_perk_bottle_marathon" );
		precacheshader( "specialty_marathon_zombies" );
		precachemodel( "zombie_vending_marathon" );
		precachemodel( "zombie_vending_marathon_on" );
		precachestring( &"ZOMBIE_PERK_MARATHON" );
		level._effect[ "marathon_light" ] = loadfx( "maps/zombie/fx_zmb_cola_staminup_on" );
		level.machine_assets[ "marathon" ] = spawnstruct();
		level.machine_assets[ "marathon" ].weapon = "zombie_perk_bottle_marathon";
		level.machine_assets[ "marathon" ].off_model = "zombie_vending_marathon";
		level.machine_assets[ "marathon" ].on_model = "zombie_vending_marathon_on";
		level.machine_assets[ "marathon" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "marathon" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		precacheitem( "zombie_perk_bottle_revive" );
		precacheshader( "specialty_quickrevive_zombies" );
		precachemodel( "p6_zm_tm_vending_revive" );
		precachemodel( "p6_zm_tm_vending_revive_on" );
		precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
		level._effect[ "revive_light" ] = loadfx( "misc/fx_zombie_cola_revive_on" );
		level._effect[ "revive_light_flicker" ] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
		level.machine_assets[ "revive" ] = spawnstruct();
		level.machine_assets[ "revive" ].weapon = "zombie_perk_bottle_revive";
		level.machine_assets[ "revive" ].off_model = "p6_zm_tm_vending_revive";
		level.machine_assets[ "revive" ].on_model = "p6_zm_tm_vending_revive_on";
		level.machine_assets[ "revive" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "revive" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		precacheitem( "zombie_perk_bottle_sleight" );
		precacheshader( "specialty_fastreload_zombies" );
		precachemodel( "zombie_vending_sleight" );
		precachemodel( "zombie_vending_sleight_on" );
		precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
		level._effect[ "sleight_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "speedcola" ] = spawnstruct();
		level.machine_assets[ "speedcola" ].weapon = "zombie_perk_bottle_sleight";
		level.machine_assets[ "speedcola" ].off_model = "zombie_vending_sleight";
		level.machine_assets[ "speedcola" ].on_model = "zombie_vending_sleight_on";
		level.machine_assets[ "speedcola" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "speedcola" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		precacheitem( "zombie_perk_bottle_tombstone" );
		precacheshader( "specialty_tombstone_zombies" );
		precachemodel( "zombie_vending_tombstone" );
		precachemodel( "zombie_vending_tombstone_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "tombstone" ] = spawnstruct();
		level.machine_assets[ "tombstone" ].weapon = "zombie_perk_bottle_tombstone";
		level.machine_assets[ "tombstone" ].off_model = "zombie_vending_tombstone";
		level.machine_assets[ "tombstone" ].on_model = "zombie_vending_tombstone_on";
		level.machine_assets[ "tombstone" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "tombstone" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		precacheitem( "zombie_perk_bottle_whoswho" );
		precacheshader( "specialty_quickrevive_zombies" );
		precachemodel( "p6_zm_vending_chugabud" );
		precachemodel( "p6_zm_vending_chugabud_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "whoswho" ] = spawnstruct();
		level.machine_assets[ "whoswho" ].weapon = "zombie_perk_bottle_whoswho";
		level.machine_assets[ "whoswho" ].off_model = "p6_zm_vending_chugabud";
		level.machine_assets[ "whoswho" ].on_model = "p6_zm_vending_chugabud_on";
		level.machine_assets[ "whoswho" ].power_on_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_on;
		level.machine_assets[ "whoswho" ].power_off_callback = maps/mp/zm_tomb_capture_zones::custom_vending_power_off;
	}
}

tomb_actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked matches cerberus output
{
	if ( isDefined( self.b_zombie_blood_damage_only ) && self.b_zombie_blood_damage_only )
	{
		if ( !isplayer( attacker ) || !attacker.zombie_vars[ "zombie_powerup_zombie_blood_on" ] )
		{
			return 0;
		}
	}
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "capture_zombie" && isDefined( attacker ) && isplayer( attacker ) )
	{
		if ( damage >= self.health )
		{
			if ( ( 100 * level.round_number ) > attacker.n_capture_zombie_points )
			{
				attacker maps/mp/zombies/_zm_score::player_add_points( "rebuild_board", 10 );
				attacker.n_capture_zombie_points += 10;
			}
		}
	}
	return_val = self maps/mp/zombies/_zm::actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( damage >= self.health )
	{
		if ( weapon == "zombie_markiv_cannon" && meansofdeath == "MOD_CRUSH" )
		{
			self thread zombie_gib_guts();
		}
		else if ( isDefined( self.b_on_tank ) && self.b_on_tank || isDefined( self.b_climbing_tank ) && self.b_climbing_tank )
		{
			self maps/mp/zm_tomb_tank::zombie_on_tank_death_animscript_callback( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		}
	}
	return return_val;
}

tomb_zombie_death_event_callback() //checked changed at own discretion
{
	if ( isDefined( self ) && isDefined( self.damagelocation ) && isDefined( self.damagemod ) && isDefined( self.damageweapon ) && isDefined( self.attacker ) && isplayer( self.attacker ) )
	{
		if ( is_headshot( self.damageweapon, self.damagelocation, self.damagemod ) && maps/mp/zombies/_zm_challenges::challenge_exists( "zc_headshots" ) && !isDefined( self.script_noteworthy ) && isDefined( "capture_zombie" ) )
		{
			self.attacker maps/mp/zombies/_zm_challenges::increment_stat( "zc_headshots" );
		}
		else if ( is_headshot( self.damageweapon, self.damagelocation, self.damagemod ) && maps/mp/zombies/_zm_challenges::challenge_exists( "zc_headshots" ) && isDefined( self.script_noteworthy ) && isDefined( "capture_zombie" ) && self.script_noteworthy != "capture_zombie" )
		{
			self.attacker maps/mp/zombies/_zm_challenges::increment_stat( "zc_headshots" );
		}
	}
}

zombie_init_done() //checked matches cerberus output
{
	self.allowpain = 0;
	self thread maps/mp/zm_tomb_distance_tracking::escaped_zombies_cleanup_init();
}

tomb_validate_enemy_path_length( player ) //checked matches cerberus output
{
	max_dist = 1296;
	d = distancesquared( self.origin, player.origin );
	if ( d <= max_dist )
	{
		return 1;
	}
	return 0;
}

show_zombie_count() //checked matches cerberus output
{
	self endon( "death_or_disconnect" );
	flag_wait( "start_zombie_round_logic" );
	while ( 1 )
	{
		n_round_zombies = get_current_zombie_count();
		str_hint = "Alive: " + n_round_zombies + "\nTo Spawn: " + level.zombie_total;
		iprintln( str_hint );
		wait 5;
	}
}

tomb_custom_divetonuke_explode( attacker, origin ) //checked matches cerberus output
{
	radius = level.zombie_vars[ "zombie_perk_divetonuke_radius" ];
	min_damage = level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ];
	max_damage = level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ];
	if ( isDefined( level.flopper_network_optimized ) && level.flopper_network_optimized )
	{
		attacker thread tomb_custom_divetonuke_explode_network_optimized( origin, radius, max_damage, min_damage, "MOD_GRENADE_SPLASH" );
	}
	else
	{
		radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	}
	playfx( level._effect[ "divetonuke_groundhit" ], origin );
	attacker playsound( "zmb_phdflop_explo" );
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_perk_divetonuke", attacker );
	wait 1;
	maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_perk_divetonuke", attacker );
}

tomb_custom_divetonuke_explode_network_optimized( origin, radius, max_damage, min_damage, damage_mod ) //checked partially changed to match cerberus output see info.md
{
	self endon( "disconnect" );
	a_all_zombies = getaispeciesarray( "axis", "all" );
	a_zombies = get_array_of_closest( origin, a_all_zombies, undefined, undefined, radius );
	network_stall_counter = 0;
	if ( isDefined( a_zombies ) )
	{
		i = 0;
		while ( i < a_zombies.size )
		{
			e_zombie = a_zombies[ i ];
			if ( !isDefined( e_zombie ) || !isalive( e_zombie ) )
			{
				i++;
				continue;
			}
			dist = distance( e_zombie.origin, origin );
			damage = min_damage + ( ( max_damage - min_damage ) * ( 1 - ( dist / radius ) ) );
			e_zombie dodamage( damage, e_zombie.origin, self, self, 0, damage_mod );
			network_stall_counter--;

			if ( network_stall_counter <= 0 )
			{
				wait_network_frame();
				network_stall_counter = randomintrange( 1, 3 );
			}
			i++;
		}
	}
}

tomb_custom_electric_cherry_laststand() //checked changed to match cerberus output
{
	visionsetlaststand( "zombie_last_stand", 1 );
	if ( isDefined( self ) )
	{
		playfx( level._effect[ "electric_cherry_explode" ], self.origin );
		self playsound( "zmb_cherry_explode" );
		self notify( "electric_cherry_start" );
		wait 0.05;
		a_zombies = getaispeciesarray( "axis", "all" );
		a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, 500 );
		for ( i = 0; i < a_zombies.size; i++ )
		{
			if ( isalive( self ) )
			{
				if ( a_zombies[ i ].health <= 1000 )
				{
					a_zombies[ i ] thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_death_fx();
					if ( isDefined( self.cherry_kills ) )
					{
						self.cherry_kills++;
					}
					self maps/mp/zombies/_zm_score::add_to_player_score( 40 );
				}
				else
				{
					a_zombies[ i ] thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_stun();
					a_zombies[ i ] thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_shock_fx();
				}
				wait 0.1;
				a_zombies[ i ] dodamage( 1000, self.origin, self, self, "none" );
			}
		}
		self notify( "electric_cherry_end" );
	}
}

tomb_custom_electric_cherry_reload_attack() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "stop_electric_cherry_reload_attack" );
	self.wait_on_reload = [];
	self.consecutive_electric_cherry_attacks = 0;
	while ( 1 )
	{
		self waittill( "reload_start" );
		str_current_weapon = self getcurrentweapon();
		if ( isinarray( self.wait_on_reload, str_current_weapon ) )
		{
			continue;
		}
		self.wait_on_reload[ self.wait_on_reload.size ] = str_current_weapon;
		self.consecutive_electric_cherry_attacks++;
		n_clip_current = self getweaponammoclip( str_current_weapon );
		n_clip_max = weaponclipsize( str_current_weapon );
		n_fraction = n_clip_current / n_clip_max;
		perk_radius = linear_map( n_fraction, 1, 0, 32, 128 );
		perk_dmg = linear_map( n_fraction, 1, 0, 1, 1045 );
		self thread maps/mp/zombies/_zm_perk_electric_cherry::check_for_reload_complete( str_current_weapon );
		if ( isDefined( self ) )
		{
			switch( self.consecutive_electric_cherry_attacks )
			{
				case 0:
				case 1:
					n_zombie_limit = undefined;
					break;
				case 2:
					n_zombie_limit = 8;
					break;
				case 3:
					n_zombie_limit = 4;
					break;
				case 4:
					n_zombie_limit = 2;
					break;
				default:
					n_zombie_limit = 0;
			}
			self thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_cooldown_timer( str_current_weapon );
			if ( isDefined( n_zombie_limit ) && n_zombie_limit == 0 )
			{
				continue;
			}
			self thread electric_cherry_reload_fx( n_fraction );
			self notify( "electric_cherry_start" );
			self playsound( "zmb_cherry_explode" );
			a_zombies = getaispeciesarray( "axis", "all" );
			a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, perk_radius );
			n_zombies_hit = 0;
			for ( i = 0; i < a_zombies.size; i++ )
			{
				if ( isalive( self ) && isalive( a_zombies[ i ] ) )
				{
					if ( isDefined( n_zombie_limit ) )
					{
						if ( n_zombies_hit < n_zombie_limit )
						{
							n_zombies_hit++;
						}
						else 
						{
							break;
						}
					}
					if ( a_zombies[ i ].health <= perk_dmg )
					{
						a_zombies[ i ] thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_death_fx();
						if ( isDefined( self.cherry_kills ) )
						{
							self.cherry_kills++;
						}
						self maps/mp/zombies/_zm_score::add_to_player_score( 40 );
					}
					else if ( !isDefined( a_zombies[ i ].is_mechz ) )
					{
						a_zombies[ i ] thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_stun();
					}
					a_zombies[ i ] thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_shock_fx();
					wait 0.1;
					if ( isalive( a_zombies[ i ] ) )
					{
						a_zombies[ i ] dodamage( perk_dmg, self.origin, self, self, "none" );
					}
				}
			}
			self notify( "electric_cherry_end" );
		}
	}
}

tomb_custom_player_track_ammo_count() //checked changed to match cerberus output
{
	self notify( "stop_ammo_tracking" );
	self endon( "disconnect" );
	self endon( "stop_ammo_tracking" );
	ammolowcount = 0;
	ammooutcount = 0;
	while ( 1 )
	{
		wait 0.5;
		weap = self getcurrentweapon();
		if ( isDefined( weap ) || weap == "none" || !tomb_can_track_ammo_custom( weap ) )
		{
			continue;
		}
		if ( self getammocount( weap ) > 5 || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
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
			self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "ammo_out" );
			ammooutcount++;
		}
		wait 20;
	}
}

tomb_can_track_ammo_custom( weap )
{
	if ( !isDefined( weap ) )
	{
		return 0;
	}
	switch( weap )
	{
		case "alcatraz_shield_zm":
		case "chalk_draw_zm":
		case "death_throe_zm":
		case "equip_dieseldrone_zm":
		case "equip_gasmask_zm":
		case "falling_hands_tomb_zm":
		case "humangun_upgraded_zm":
		case "humangun_zm":
		case "lower_equip_gasmask_zm":
		case "no_hands_zm":
		case "none":
		case "one_inch_punch_air_zm":
		case "one_inch_punch_fire_zm":
		case "one_inch_punch_ice_zm":
		case "one_inch_punch_lightning_zm":
		case "one_inch_punch_upgraded_zm":
		case "one_inch_punch_zm":
		case "riotshield_zm":
		case "screecher_arms_zm":
		case "slowgun_upgraded_zm":
		case "slowgun_zm":
		case "staff_revive_zm":
		case "tazer_knuckles_upgraded_zm":
		case "tazer_knuckles_zm":
		case "time_bomb_detonator_zm":
		case "time_bomb_zm":
		case "zombie_bowie_flourish":
		case "zombie_builder_zm":
		case "zombie_fists_zm":
		case "zombie_knuckle_crack":
		case "zombie_one_inch_punch_flourish":
		case "zombie_one_inch_punch_upgrade_flourish":
		case "zombie_sickle_flourish":
		case "zombie_tazer_flourish":
			return 0;
		default:
			if ( is_zombie_perk_bottle( weap ) || is_placeable_mine( weap ) || is_equipment( weap ) || issubstr( weap, "knife_ballistic_" ) || getsubstr( weap, 0, 3 ) == "gl_" || weaponfuellife( weap ) > 0 || weap == level.revive_tool )
			{
				return 0;
			}
	}
	return 1;
}

