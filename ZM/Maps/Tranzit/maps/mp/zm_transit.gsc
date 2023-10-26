// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zm_transit_utility;
#include maps\mp\zombies\_zm_weapon_locker;
#include maps\mp\zm_transit_gamemodes;
#include maps\mp\zombies\_zm_banking;
#include maps\mp\zm_transit_ffotd;
#include maps\mp\zm_transit_bus;
#include maps\mp\zm_transit_automaton;
#include maps\mp\zombies\_zm_equip_turbine;
#include maps\mp\zm_transit_fx;
#include maps\mp\zombies\_zm;
#include maps\mp\animscripts\zm_death;
#include maps\mp\teams\_teamset_cdc;
#include maps\mp\_sticky_grenade;
#include maps\mp\zombies\_load;
#include maps\mp\zm_transit_ai_screecher;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zm_transit_lava;
#include maps\mp\zm_transit_power;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_weap_riotshield;
#include maps\mp\zombies\_zm_weap_jetgun;
#include maps\mp\zombies\_zm_weap_emp_bomb;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_weap_tazer_knuckles;
#include maps\mp\zombies\_zm_weap_bowie;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_ballistic_knife;
#include maps\mp\_visionset_mgr;
#include maps\mp\zm_transit_achievement;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zm_transit_openings;
#include character\c_transit_player_farmgirl;
#include character\c_transit_player_oldman;
#include character\c_transit_player_engineer;
#include character\c_transit_player_reporter;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\zm_transit_cling;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zm_transit_sq;
#include maps\mp\zm_transit_distance_tracking;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_tombstone;

gamemode_callback_setup()
{
    maps\mp\zm_transit_gamemodes::init();
}

encounter_init()
{
    precacheshader( "sun_moon_zombie" );
    level.precachecustomcharacters = ::precache_team_characters;
    level.givecustomcharacters = ::give_team_characters;
}

zgrief_init()
{
    encounter_init();
    level thread maps\mp\zombies\_zm_banking::delete_bank_teller();
    flag_wait( "start_zombie_round_logic" );
    level.custom_intermission = ::transit_standard_intermission;

    if ( isdefined( level.scr_zm_map_start_location ) && level.scr_zm_map_start_location == "transit" )
        level thread lava_damage_depot();
}

survival_init()
{
    level.force_team_characters = 1;
    level.should_use_cia = 0;

    if ( randomint( 100 ) > 50 )
        level.should_use_cia = 1;

    level.precachecustomcharacters = ::precache_team_characters;
    level.givecustomcharacters = ::give_team_characters;
    level.dog_spawn_func = ::dog_spawn_transit_logic;
    level thread maps\mp\zombies\_zm_banking::delete_bank_teller();
    flag_wait( "start_zombie_round_logic" );
    level.custom_intermission = ::transit_standard_intermission;

    if ( isdefined( level.scr_zm_map_start_location ) && level.scr_zm_map_start_location == "transit" )
        level thread lava_damage_depot();
}

zclassic_init()
{
    level.precachecustomcharacters = ::precache_personality_characters;
    level.givecustomcharacters = ::give_personality_characters;
    level.setupcustomcharacterexerts = ::setup_personality_character_exerts;
    level.level_specific_init_powerups = ::add_transit_powerups;
    level.powerup_intro_vox = ::powerup_intro_vox;
    level.powerup_vo_available = ::powerup_vo_available;
    level.buildable_build_custom_func = ::buildable_build_custom_func;
    level.custom_update_retrieve_trigger = ::transit_bus_update_retrieve_trigger;
    level.buildable_pickup_vo_override = ::transit_buildable_vo_override;
    precachemodel( "p6_zm_window_dest_glass_small_broken" );
    precachemodel( "p6_zm_window_dest_glass_big_broken" );
    precachemodel( "p6_zm_keycard" );
    flag_wait( "start_zombie_round_logic" );
    level.custom_intermission = ::transit_intermission;
    level.custom_trapped_zombies = ::kill_zombies_depot;
    level thread lava_damage_depot();
    level thread bank_teller_init();
    level thread transit_breakable_glass_init();
    level thread sndsetupmusiceasteregg();
    level thread bank_pap_hint();
    level thread power_pap_hint();
    level thread sndtoiletflush();
}

zclassic_preinit()
{
    zclassic_init();
}

zcleansed_preinit()
{
    level._zcleansed_weapon_progression = array( "rpd_zm", "srm1216_zm", "judge_zm", "qcw05_zm", "kard_zm" );
    survival_init();
}

zcontainment_preinit()
{
    survival_init();
}

zdeadpool_preinit()
{
    encounter_init();
}

zgrief_preinit()
{
    registerclientfield( "toplayer", "meat_stink", 1, 1, "int" );
    zgrief_init();
    level thread delete_bus_pieces();
}

zmeat_preinit()
{
    encounter_init();
}

znml_preinit()
{
    survival_init();
}

zpitted_preinit()
{
    encounter_init();
}

zrace_preinit()
{
    encounter_init();
}

zstandard_preinit()
{
    survival_init();
    level thread delete_bus_pieces();
}

zturned_preinit()
{
    encounter_init();
}

createfx_callback()
{
    ents = getentarray();

    for ( i = 0; i < ents.size; i++ )
    {
        if ( ents[i].classname != "info_player_start" )
            ents[i] delete();
    }
}

main()
{
    level thread maps\mp\zm_transit_ffotd::main_start();
    level.hotjoin_player_setup = ::hotjoin_setup_player;
    level.level_createfx_callback_thread = ::createfx_callback;
    level.ignore_spawner_func = ::transit_ignore_spawner;
    level.default_game_mode = "zclassic";
    level.default_start_location = "transit";
    level._get_random_encounter_func = maps\mp\zm_transit_utility::get_random_encounter_match;
    setup_rex_starts();
    maps\mp\zm_transit_bus::init_animtree();
    maps\mp\zm_transit_bus::init_props_animtree();
    maps\mp\zm_transit_automaton::init_animtree();
    maps\mp\zombies\_zm_equip_turbine::init_animtree();
    maps\mp\zm_transit_fx::main();
    maps\mp\zombies\_zm::init_fx();
    maps\mp\animscripts\zm_death::precache_gib_fx();
    level.zombiemode = 1;
    level._no_water_risers = 1;
    level.riser_fx_on_client = 1;

    if ( !isdefined( level.zombie_surfing_kills ) )
    {
        level.zombie_surfing_kills = 1;
        level.zombie_surfing_kill_count = 6;
    }

    maps\mp\teams\_teamset_cdc::register();
    maps\mp\_sticky_grenade::init();
    level.level_specific_stats_init = ::init_transit_stats;
    maps\mp\zombies\_load::main();
    init_clientflags();
    level thread transit_pathnode_spawning();
    registerclientfield( "allplayers", "playerinfog", 1, 1, "int" );
    level.set_player_in_fog = ::set_player_in_fog;
    level.custom_breadcrumb_store_func = ::transit_breadcrumb_store_func;
    register_screecher_lights();

    if ( getdvar( "createfx" ) == "1" )
        return;

    maps\mp\teams\_teamset_cdc::level_init();
    maps\mp\zm_transit_ai_screecher::init();
    level.is_player_in_screecher_zone = ::is_player_in_screecher_zone;
    level.revive_trigger_spawn_override_link = ::revive_trigger_spawn_override_link;
    level.revive_trigger_should_ignore_sight_checks = ::revive_trigger_should_ignore_sight_checks;
    level.allow_move_in_laststand = ::allow_move_in_laststand;
    level.can_revive = ::can_revive;
    level.melee_miss_func = ::melee_miss_func;
    level.grenade_watcher = ::grenade_watcher;
    level.ignore_find_flesh = ::ignore_find_flesh;
    level.ignore_equipment = ::ignore_equipment;
    level.should_attack_equipment = ::should_attack_equipment;
    level.gib_on_damage = ::gib_on_damage;
    level.melee_anim_state = ::melee_anim_state;
    level.ignore_stop_func = ::ignore_stop_func;
    level.can_melee = ::can_melee;
    level.ignore_traverse = ::ignore_traverse;
    level.exit_level_func = ::exit_level_func;
    level.inert_substate_override = ::inert_substate_override;
    level.attack_item = ::attack_item;
    level.attack_item_stop = ::attack_item_stop;
    level.check_valid_poi = ::check_valid_poi;
    level.dog_melee_miss = ::dog_melee_miss;
    precacheshellshock( "lava" );
    precacheshellshock( "lava_small" );
    precache_survival_barricade_assets();
    include_game_modules();
    maps\mp\gametypes_zm\_spawning::level_use_unified_spawning( 1 );
    level.givecustomloadout = ::givecustomloadout;
    level.giveextrazombies = ::giveextrazombies;
    initcharacterstartindex();

    if ( level.xenon )
    {
        level.giveextrazombies = ::giveextrazombies;
        precacheextrazombies();
    }

    level.custom_player_fake_death = ::transit_player_fake_death;
    level.custom_player_fake_death_cleanup = ::transit_player_fake_death_cleanup;
    level.initial_round_wait_func = ::initial_round_wait_func;
    level.zombie_speed_up = ::zombie_speed_up;
    level.zombie_init_done = ::zombie_init_done;
    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 1;
    level.pap_interaction_height = 47;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_marathon_perk = 1;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.zombiemode_using_tombstone_perk = 1;
    init_persistent_abilities();
    level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;

    if ( is_classic() )
    {
        level.player_intersection_tracker_override = ::zombie_transit_player_intersection_tracker_override;
        level.taser_trig_adjustment = ( 2, 7, 0 );
    }

    level.player_too_many_weapons_monitor_callback = ::zombie_transit_player_too_many_weapons_monitor_callback;
    level._zmbvoxlevelspecific = ::zombie_transit_audio_alias_override;
    level._zombie_custom_add_weapons = ::custom_add_weapons;
    level._allow_melee_weapon_switching = 1;
    level.disable_melee_wallbuy_icons = 1;
    level.uses_gumps = 1;
    setdvar( "aim_target_fixed_actor_size", 1 );
    level.banking_update_enabled = 1;
    level.raygun2_included = 1;
    include_weapons();
    include_powerups();
    include_equipment_for_level();
    include_powered_items();
    level.powerup_bus_range = 500;
    level.pay_turret_cost = 300;
    level.auto_turret_cost = 500;
    setup_dvars();
    onplayerconnect_callback( ::setup_players );
    level thread disable_triggers();
    level thread maps\mp\zm_transit_lava::lava_damage_init();
    level.zm_transit_burn_max_duration = 2;
    level thread maps\mp\zm_transit_power::precache_models();
    setup_zombie_init();
    maps\mp\zombies\_zm::init();
    maps\mp\zombies\_zm_ai_basic::init_inert_zombies();
    maps\mp\zombies\_zm_weap_riotshield::init();
    maps\mp\zombies\_zm_weap_jetgun::init();
    level.special_weapon_magicbox_check = ::transit_special_weapon_magicbox_check;
    maps\mp\zombies\_zm_weap_emp_bomb::init();
    zm_transit_emp_init();
    level.legacy_cymbal_monkey = 1;
    maps\mp\zombies\_zm_weap_cymbal_monkey::init();
    maps\mp\zombies\_zm_weap_tazer_knuckles::init();
    maps\mp\zombies\_zm_weap_bowie::init();
    maps\mp\zombies\_zm_weap_claymore::init();
    maps\mp\zombies\_zm_weap_ballistic_knife::init();

    if ( !isdefined( level.vsmgr_prio_overlay_zm_transit_burn ) )
        level.vsmgr_prio_overlay_zm_transit_burn = 20;

    maps\mp\_visionset_mgr::vsmgr_register_info( "overlay", "zm_transit_burn", 1, level.vsmgr_prio_overlay_zm_transit_burn, 15, 1, maps\mp\_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
    level maps\mp\zm_transit_achievement::init();
    precacheitem( "death_throe_zm" );

    if ( level.splitscreen && getdvarint( "splitscreen_playerCount" ) > 2 )
        level.optimise_for_splitscreen = 1;
    else
        level.optimise_for_splitscreen = 0;

    if ( level.ps3 )
    {
        if ( isdefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
            level.culldist = 1500;
        else
            level.culldist = 4500;
    }
    else if ( isdefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
        level.culldist = 2500;
    else
        level.culldist = 5500;

    setculldist( level.culldist );
    level.zones = [];
    level.zone_manager_init_func = ::transit_zone_init;
    init_zones[0] = "zone_pri";
    init_zones[1] = "zone_station_ext";
    init_zones[2] = "zone_tow";

    if ( is_classic() )
    {
        init_zones[3] = "zone_far";
        init_zones[4] = "zone_pow";
        init_zones[5] = "zone_trans_1";
        init_zones[6] = "zone_trans_2";
        init_zones[7] = "zone_trans_3";
        init_zones[8] = "zone_trans_4";
        init_zones[9] = "zone_trans_5";
        init_zones[10] = "zone_trans_6";
        init_zones[11] = "zone_trans_7";
        init_zones[12] = "zone_trans_8";
        init_zones[13] = "zone_trans_9";
        init_zones[14] = "zone_trans_10";
        init_zones[15] = "zone_trans_11";
        init_zones[16] = "zone_amb_tunnel";
        init_zones[17] = "zone_amb_forest";
        init_zones[18] = "zone_amb_cornfield";
        init_zones[19] = "zone_amb_power2town";
        init_zones[20] = "zone_amb_bridge";
    }
    else
    {
        init_zones[3] = "zone_far_ext";
        init_zones[4] = "zone_brn";
    }

    level thread maps\mp\zombies\_zm_zonemgr::manage_zones( init_zones );

    if ( isdefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
    {
        if ( is_classic() )
            level.zombie_ai_limit = 20;

        setdvar( "fx_marks_draw", 0 );
        setdvar( "disable_rope", 1 );
        setdvar( "cg_disableplayernames", 1 );
        setdvar( "disableLookAtEntityLogic", 1 );
    }
    else
        level.zombie_ai_limit = 24;

    setdvar( "zombiemode_path_minz_bias", 13 );
    level thread maps\mp\zm_transit_ffotd::main_end();
    flag_wait( "start_zombie_round_logic" );
    level notify( "players_done_connecting" );
/#
    execdevgui( "devgui_zombie_transit" );
    level.custom_devgui = ::zombie_transit_devgui;
#/
    level thread set_transit_wind();

    if ( is_classic() )
        level thread player_name_fade_control();

    level._audio_custom_response_line = ::transit_audio_custom_response_line;
    level.speed_change_round = 15;
    level.speed_change_max = 5;
    init_screecher_zones();
    elec_door_triggers = getentarray( "local_electric_door", "script_noteworthy" );

    foreach ( trigger in elec_door_triggers )
    {
        if ( isdefined( trigger.door_hold_trigger ) && trigger.door_hold_trigger == "zombie_door_hold_farm" )
        {
            if ( isdefined( trigger.doors ) )
            {
                foreach ( door in trigger.doors )
                {
                    if ( door.origin == ( 8833, -5697, 135 ) )
                        door.ignore_use_blocker_clip_for_pathing_check = 1;
                }
            }
        }
    }
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
        level.pers_upgrade_box_weapon = 1;
        level.pers_magic_box_firesale = 1;
        level.pers_treasure_chest_get_weapons_array_func = ::pers_treasure_chest_get_weapons_array_transit;
        level.pers_upgrade_sniper = 1;
        level.pers_upgrade_pistol_points = 1;
        level.pers_upgrade_perk_lose = 1;
        level.pers_upgrade_double_points = 1;
        level.pers_upgrade_nube = 1;
    }
}

pers_treasure_chest_get_weapons_array_transit()
{
    if ( !isdefined( level.pers_box_weapons ) )
    {
        level.pers_box_weapons = [];
        level.pers_box_weapons[level.pers_box_weapons.size] = "knife_ballistic_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "cymbal_monkey_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "judge_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "emp_grenade_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "galil_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "hamr_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "ray_gun_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "rpd_zm";
    }
}

setup_rex_starts()
{
    add_gametype( "zclassic", ::dummy, "zclassic", ::dummy );
    add_gametype( "zstandard", ::dummy, "zstandard", ::dummy );
    add_gametype( "zgrief", ::dummy, "zgrief", ::dummy );
    add_gameloc( "transit", ::dummy, "transit", ::dummy );
    add_gameloc( "town", ::dummy, "town", ::dummy );
    add_gameloc( "farm", ::dummy, "farm", ::dummy );
}

dummy()
{

}

init_clientflags()
{
    level._clientflag_vehicle_bus_flashing_lights = 0;
    level._clientflag_vehicle_bus_head_lights = 1;
    level._clientflag_vehicle_bus_brake_lights = 2;
    level._clientflag_vehicle_bus_turn_signal_left_lights = 3;
    level._clientflag_vehicle_bus_turn_signal_right_lights = 4;
}

set_player_in_fog( onoff )
{
    if ( onoff )
        self setclientfield( "playerinfog", 1 );
    else
        self setclientfield( "playerinfog", 0 );
}

transit_breadcrumb_store_func( store_crumb )
{
    if ( isdefined( self.isonbus ) && self.isonbus )
        return 0;

    return store_crumb;
}

transit_ignore_spawner( spawner )
{
    if ( spawner.classname == "actor_zm_zombie_transit_screecher" )
        return true;

    return false;
}

allow_move_in_laststand( player_down )
{
    if ( isdefined( player_down.isonbus ) && player_down.isonbus )
        return false;

    return true;
}

can_revive( player_down )
{
    if ( isdefined( self.screecher ) )
        return false;

    return true;
}

melee_miss_func()
{
    if ( isdefined( self.enemy ) )
    {
        if ( isdefined( self.enemy.screecher ) || self.enemy getstance() == "prone" || self.enemy maps\mp\zombies\_zm_laststand::is_reviving_any() )
        {
            dist_sq = distancesquared( self.enemy.origin, self.origin );
            melee_dist_sq = self.meleeattackdist * self.meleeattackdist;

            if ( dist_sq < melee_dist_sq )
                self.enemy dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
        }
    }
}

grenade_watcher( grenade, weapname )
{
    if ( weapname == "frag_grenade_zm" || weapname == "claymore_zm" || weapname == "sticky_grenade_zm" )
        self thread maps\mp\zombies\_zm_ai_basic::grenade_watcher( grenade );
}

ignore_find_flesh()
{
    if ( isdefined( self.isonbus ) && self.isonbus )
        return true;

    return false;
}

ignore_equipment( zombie )
{
    if ( !( isdefined( zombie.completed_emerging_into_playable_area ) && zombie.completed_emerging_into_playable_area ) )
        return true;

    if ( isdefined( zombie.is_avogadro ) && zombie.is_avogadro )
        return true;

    if ( isdefined( zombie.is_inert ) && zombie.is_inert )
        return true;

    if ( isdefined( zombie.inert_delay ) )
        return true;

    return false;
}

should_attack_equipment( dist )
{
    if ( !isdefined( level.door_triggers ) )
        level.door_triggers = getentarray( "bus_door_trigger", "targetname" );

    for ( i = 0; i < level.door_triggers.size; i++ )
    {
        if ( self istouching( level.door_triggers[i] ) )
        {
            if ( dist < 4096 )
                return true;
        }
    }

    return false;
}

gib_on_damage()
{
    opening = self.opening;

    if ( isdefined( opening ) )
    {
        if ( isdefined( self.a.gib_ref ) && ( self.a.gib_ref == "left_arm" || self.a.gib_ref == "right_arm" ) )
        {
            level maps\mp\zombies\_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.a.gib_ref, self.attacker, self );
            opening.zombie = undefined;
            launchvector = ( 0, 0, -1 );
            self thread maps\mp\zombies\_zm_spawner::zombie_ragdoll_then_explode( launchvector, self.attacker );
            self notify( "killanimscript" );
            return;
        }
    }

    if ( isdefined( self.is_inert ) && self.is_inert )
    {
        if ( !( isdefined( self.has_legs ) && self.has_legs ) )
        {
            self notify( "stop_zombie_inert_transition" );
            self setanimstatefromasd( "zm_inert_crawl", maps\mp\zombies\_zm_ai_basic::get_inert_crawl_substate() );
        }
    }
}

melee_anim_state()
{
    if ( self.zombie_move_speed == "bus_walk" )
        return maps\mp\animscripts\zm_utility::append_missing_legs_suffix( "zm_walk_melee" );

    return undefined;
}

ignore_stop_func()
{
    if ( isdefined( self.is_inert ) && self.is_inert )
        return true;

    if ( isdefined( self.opening ) )
        return true;

    if ( isdefined( self.entering_bus ) )
        return true;

    return false;
}

can_melee()
{
    if ( isdefined( self.dont_die_on_me ) && self.dont_die_on_me )
        return false;

    if ( isdefined( self.isonbus ) && self.isonbus || isdefined( self.isonbusroof ) && self.isonbusroof )
    {
        if ( self.enemydistancesq > anim.meleerangesq )
            return false;
    }

    return true;
}

ignore_traverse()
{
    if ( isdefined( self.is_inert ) && self.is_inert )
    {
        if ( !( isdefined( self.in_place ) && self.in_place ) )
        {
            self setgoalpos( self.origin );

            if ( randomint( 100 ) > 50 )
                self setanimstatefromasd( "zm_inert", "inert1" );
            else
                self setanimstatefromasd( "zm_inert", "inert2" );

            self.in_place = 1;
        }

        return true;
    }

    return false;
}

exit_level_func()
{
    zombies = getaiarray( level.zombie_team );

    foreach ( zombie in zombies )
    {
        if ( isdefined( zombie.ignore_solo_last_stand ) && zombie.ignore_solo_last_stand )
            continue;

        if ( isdefined( zombie.find_exit_point ) )
        {
            zombie thread [[ zombie.find_exit_point ]]();
            continue;
        }

        if ( isdefined( zombie.isonbus ) && zombie.isonbus )
        {
            zombie thread find_exit_bus();
            continue;
        }

        if ( zombie.ignoreme )
        {
            zombie thread maps\mp\zombies\_zm::default_delayed_exit();
            continue;
        }

        zombie thread maps\mp\zombies\_zm::default_find_exit_point();
    }
}

inert_substate_override( substate )
{
    in_bar = 0;

    if ( flag( "OnTowDoorBar" ) )
    {
        if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_bar" ) )
            in_bar = 1;
    }

    if ( isdefined( self.isonbus ) && self.isonbus || in_bar )
    {
        if ( randomint( 100 ) > 50 )
            substate = "inert1";
        else
            substate = "inert2";
    }

    return substate;
}

attack_item()
{
    if ( isdefined( self.isonbus ) && self.isonbus )
        self linkto( level.the_bus );
}

attack_item_stop()
{
    if ( isdefined( self.isonbus ) && self.isonbus )
        self unlink();
}

check_valid_poi( valid )
{
    if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_bar" ) )
    {
        if ( !flag( "OnTowDoorBar" ) )
            return 0;
    }
    else if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_town_barber" ) )
    {
        if ( !flag( "OnTowDoorBarber" ) )
            return 0;
    }

    return valid;
}

dog_melee_miss()
{
    if ( isdefined( self.enemy ) )
    {
        stance = self.enemy getstance();

        if ( stance == "prone" || stance == "crouch" )
        {
            dist_sq = distancesquared( self.enemy.origin, self.origin );

            if ( dist_sq < 10000 )
            {
                meleedamage = getdvarint( "dog_MeleeDamage" );
                self.enemy dodamage( meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
            }
        }
    }
}

find_exit_loc()
{
    player = self.favoriteenemy;
    dist_zombie = 0;
    dist_player = 0;
    dest = 0;
    away = vectornormalize( self.origin - player.origin );
    endpos = self.origin + vectorscale( away, 600 );
    locs = array_randomize( level.enemy_dog_locations );

    for ( i = 0; i < locs.size; i++ )
    {
        dist_zombie = distancesquared( locs[i].origin, endpos );
        dist_player = distancesquared( locs[i].origin, player.origin );

        if ( dist_zombie < dist_player )
        {
            dest = i;
            break;
        }
    }

    if ( isdefined( locs[dest] ) )
        self.solo_revive_exit_pos = locs[dest].origin;
}

find_exit_bus()
{
    self endon( "death" );
    self.solo_revive_exit = 1;
    self notify( "endOnBus" );
    self thread maps\mp\zm_transit_openings::zombieexitbus();
    self find_exit_loc();
    off_the_bus = 0;

    while ( flag( "wait_and_revive" ) )
    {
        if ( !off_the_bus && self.ai_state == "find_flesh" )
        {
            off_the_bus = 1;
            self thread maps\mp\zombies\_zm::default_find_exit_point();
        }

        wait 0.1;
    }

    self.solo_revive_exit = 0;

    if ( !( isdefined( self.exiting_window ) && self.exiting_window ) )
    {
        if ( isdefined( self.isonbus ) && self.isonbus )
        {
            self notify( "stop_zombieExitBus" );
            self.walk_to_exit = 0;
            self thread zombiemoveonbus();
        }
    }
}

post_first_init()
{
    while ( !isdefined( anim.notfirsttime ) )
        wait 0.5;

    anim.meleerange = 36;
    anim.meleerangesq = anim.meleerange * anim.meleerange;
}

set_transit_wind()
{
    setdvar( "enable_global_wind", 1 );
    setdvar( "wind_global_vector", "-120 -115 -120" );
    setdvar( "wind_global_low_altitude", 0 );
    setdvar( "wind_global_hi_altitude", 2000 );
    setdvar( "wind_global_low_strength_percent", 0.5 );
}

revive_trigger_move_with_player()
{
    self endon( "stop_revive_trigger" );
    self endon( "death" );

    while ( isdefined( self.revivetrigger ) )
    {
        my_position = self gettagorigin( "J_SpineLower" );
        self.revivetrigger unlink();
        self.revivetrigger.origin = my_position;
        self.revivetrigger linkto( level.the_bus );
        wait 0.1;
    }
}

revive_trigger_should_ignore_sight_checks( player_down )
{
    if ( isdefined( player_down.isonbus ) && player_down.isonbus && level.the_bus.ismoving )
        return true;

    return false;
}

revive_trigger_spawn_override_link( player_down )
{
    radius = getdvarint( _hash_A17166B0 );
    player_down.revivetrigger = spawn( "trigger_radius", ( 0, 0, 0 ), 0, radius, radius );
    player_down.revivetrigger sethintstring( "" );
    player_down.revivetrigger setcursorhint( "HINT_NOICON" );
    player_down.revivetrigger setmovingplatformenabled( 1 );
    player_down.revivetrigger enablelinkto();

    if ( isdefined( player_down.isonbus ) && player_down.isonbus )
    {
        player_down.revivetrigger linkto( level.the_bus );
        player_down thread revive_trigger_move_with_player();
    }
    else
    {
        player_down.revivetrigger.origin = player_down.origin;
        player_down.revivetrigger linkto( player_down );
    }

    player_down.revivetrigger.beingrevived = 0;
    player_down.revivetrigger.createtime = gettime();
}

init_screecher_zones()
{
    foreach ( key in level.zone_keys )
    {
        if ( issubstr( key, "_trans_" ) || issubstr( key, "_amb_" ) )
        {
            level.zones[key].screecher_zone = 1;
            continue;
        }

        level.zones[key].screecher_zone = 0;
    }
}

is_player_in_screecher_zone( player )
{
    if ( isdefined( player.isonbus ) && player.isonbus )
        return false;

    if ( player_entered_safety_zone( player ) )
        return false;

    if ( player_entered_safety_light( player ) )
        return false;

    curr_zone = player get_current_zone( 1 );

    if ( isdefined( curr_zone ) && !( isdefined( curr_zone.screecher_zone ) && curr_zone.screecher_zone ) )
        return false;

    return true;
}

player_entered_safety_zone( player )
{
    if ( !isdefined( level.safety_volumes ) )
        level.safety_volumes = getentarray( "screecher_volume", "targetname" );

    if ( isdefined( player.last_safety_volume ) )
    {
        if ( player istouching( player.last_safety_volume ) )
            return true;
    }

    if ( isdefined( level.safety_volumes ) )
    {
        for ( i = 0; i < level.safety_volumes.size; i++ )
        {
            if ( player istouching( level.safety_volumes[i] ) )
            {
                player.last_safety_volume = level.safety_volumes[i];
                return true;
            }
        }
    }

    player.last_safety_volume = undefined;
    return false;
}

player_entered_safety_light( player )
{
    safety = getstructarray( "screecher_escape", "targetname" );

    if ( !isdefined( safety ) )
        return false;

    player.green_light = undefined;

    for ( i = 0; i < safety.size; i++ )
    {
        if ( !( isdefined( safety[i].power_on ) && safety[i].power_on ) )
            continue;

        if ( !isdefined( safety[i].radius ) )
            safety[i].radius = 256;

        plyr_dist = distancesquared( player.origin, safety[i].origin );

        if ( plyr_dist < safety[i].radius * safety[i].radius )
        {
            player.green_light = safety[i];
            return true;
        }
    }

    return false;
}

zombie_transit_player_intersection_tracker_override( other_player )
{
    if ( isdefined( self.isonbus ) && self.isonbus || isdefined( self.isonbus ) && self.isonbus )
        return true;

    if ( isdefined( other_player.isonbus ) && other_player.isonbus || isdefined( other_player.isonbus ) && other_player.isonbus )
        return true;

    return false;
}

precache_team_characters()
{
    precachemodel( "c_zom_player_cdc_fb" );
    precachemodel( "c_zom_hazmat_viewhands" );
    precachemodel( "c_zom_player_cia_fb" );
    precachemodel( "c_zom_suit_viewhands" );
}

precache_personality_characters()
{
    character\c_transit_player_farmgirl::precache();
    character\c_transit_player_oldman::precache();
    character\c_transit_player_engineer::precache();
    character\c_transit_player_reporter::precache();
    precachemodel( "c_zom_farmgirl_viewhands" );
    precachemodel( "c_zom_oldman_viewhands" );
    precachemodel( "c_zom_engineer_viewhands" );
    precachemodel( "c_zom_reporter_viewhands" );
}

precache_survival_barricade_assets()
{
    survival_barricades = getstructarray( "game_mode_object" );

    for ( i = 0; i < survival_barricades.size; i++ )
    {
        if ( isdefined( survival_barricades[i].script_string ) && survival_barricades[i].script_string == "survival" )
        {
            if ( isdefined( survival_barricades[i].script_parameters ) )
                precachemodel( survival_barricades[i].script_parameters );
        }
    }
}

initcharacterstartindex()
{
    level.characterstartindex = 0;
/#
    forcecharacter = getdvarint( _hash_FEE4CB69 );

    if ( forcecharacter != 0 )
        level.characterstartindex = forcecharacter - 1;
#/
}

precacheextrazombies()
{

}

giveextrazombies()
{

}

give_team_characters()
{
    if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_suit_viewhands" ) )
        return;

    self detachall();
    self set_player_is_female( 0 );

    if ( isdefined( level.should_use_cia ) )
    {
        if ( level.should_use_cia )
        {
            self setmodel( "c_zom_player_cia_fb" );
            self setviewmodel( "c_zom_suit_viewhands" );
            self.characterindex = 0;
        }
        else
        {
            self setmodel( "c_zom_player_cdc_fb" );
            self setviewmodel( "c_zom_hazmat_viewhands" );
            self.characterindex = 1;
        }
    }
    else
    {
        if ( !isdefined( self.characterindex ) )
        {
            self.characterindex = 1;

            if ( self.team == "axis" )
                self.characterindex = 0;
        }

        switch ( self.characterindex )
        {
            case 2:
            case 0:
                self setmodel( "c_zom_player_cia_fb" );
                self.voice = "american";
                self.skeleton = "base";
                self setviewmodel( "c_zom_suit_viewhands" );
                self.characterindex = 0;
                break;
            case 3:
            case 1:
                self setmodel( "c_zom_player_cdc_fb" );
                self.voice = "american";
                self.skeleton = "base";
                self setviewmodel( "c_zom_hazmat_viewhands" );
                self.characterindex = 1;
                break;
        }
    }

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self set_player_tombstone_index();
}

give_personality_characters()
{
    if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_farmgirl_viewhands" ) )
        return;

    self detachall();

    if ( !isdefined( self.characterindex ) )
        self.characterindex = assign_lowest_unused_character_index();

    self.favorite_wall_weapons_list = [];
    self.talks_in_danger = 0;
/#
    if ( getdvar( _hash_40772CF1 ) != "" )
        self.characterindex = getdvarint( _hash_40772CF1 );
#/
    switch ( self.characterindex )
    {
        case 2:
            self character\c_transit_player_farmgirl::main();
            self setviewmodel( "c_zom_farmgirl_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
            self set_player_is_female( 1 );
            break;
        case 0:
            self character\c_transit_player_oldman::main();
            self setviewmodel( "c_zom_oldman_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
            self set_player_is_female( 0 );
            break;
        case 3:
            self character\c_transit_player_engineer::main();
            self setviewmodel( "c_zom_engineer_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
            self set_player_is_female( 0 );
            break;
        case 1:
            self character\c_transit_player_reporter::main();
            self setviewmodel( "c_zom_reporter_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.talks_in_danger = 1;
            level.rich_sq_player = self;
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
            self set_player_is_female( 0 );
            break;
    }

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self set_player_tombstone_index();
    self thread set_exert_id();
}

set_exert_id()
{
    self endon( "disconnect" );
    wait_network_frame();
    wait_network_frame();
    self maps\mp\zombies\_zm_audio::setexertvoice( self.characterindex + 1 );
}

setup_personality_character_exerts()
{
    level.exert_sounds[1]["burp"][0] = "vox_plr_0_exert_burp_0";
    level.exert_sounds[1]["burp"][1] = "vox_plr_0_exert_burp_1";
    level.exert_sounds[1]["burp"][2] = "vox_plr_0_exert_burp_2";
    level.exert_sounds[1]["burp"][3] = "vox_plr_0_exert_burp_3";
    level.exert_sounds[1]["burp"][4] = "vox_plr_0_exert_burp_4";
    level.exert_sounds[1]["burp"][5] = "vox_plr_0_exert_burp_5";
    level.exert_sounds[1]["burp"][6] = "vox_plr_0_exert_burp_6";
    level.exert_sounds[2]["burp"][0] = "vox_plr_1_exert_burp_0";
    level.exert_sounds[2]["burp"][1] = "vox_plr_1_exert_burp_1";
    level.exert_sounds[2]["burp"][2] = "vox_plr_1_exert_burp_2";
    level.exert_sounds[2]["burp"][3] = "vox_plr_1_exert_burp_3";
    level.exert_sounds[3]["burp"][0] = "vox_plr_2_exert_burp_0";
    level.exert_sounds[3]["burp"][1] = "vox_plr_2_exert_burp_1";
    level.exert_sounds[3]["burp"][2] = "vox_plr_2_exert_burp_2";
    level.exert_sounds[3]["burp"][3] = "vox_plr_2_exert_burp_3";
    level.exert_sounds[3]["burp"][4] = "vox_plr_2_exert_burp_4";
    level.exert_sounds[3]["burp"][5] = "vox_plr_2_exert_burp_5";
    level.exert_sounds[3]["burp"][6] = "vox_plr_2_exert_burp_6";
    level.exert_sounds[4]["burp"][0] = "vox_plr_3_exert_burp_0";
    level.exert_sounds[4]["burp"][1] = "vox_plr_3_exert_burp_1";
    level.exert_sounds[4]["burp"][2] = "vox_plr_3_exert_burp_2";
    level.exert_sounds[4]["burp"][3] = "vox_plr_3_exert_burp_3";
    level.exert_sounds[4]["burp"][4] = "vox_plr_3_exert_burp_4";
    level.exert_sounds[4]["burp"][5] = "vox_plr_3_exert_burp_5";
    level.exert_sounds[4]["burp"][6] = "vox_plr_3_exert_burp_6";
    level.exert_sounds[1]["hitmed"][0] = "vox_plr_0_exert_pain_medium_0";
    level.exert_sounds[1]["hitmed"][1] = "vox_plr_0_exert_pain_medium_1";
    level.exert_sounds[1]["hitmed"][2] = "vox_plr_0_exert_pain_medium_2";
    level.exert_sounds[1]["hitmed"][3] = "vox_plr_0_exert_pain_medium_3";
    level.exert_sounds[2]["hitmed"][0] = "vox_plr_1_exert_pain_medium_0";
    level.exert_sounds[2]["hitmed"][1] = "vox_plr_1_exert_pain_medium_1";
    level.exert_sounds[2]["hitmed"][2] = "vox_plr_1_exert_pain_medium_2";
    level.exert_sounds[2]["hitmed"][3] = "vox_plr_1_exert_pain_medium_3";
    level.exert_sounds[3]["hitmed"][0] = "vox_plr_2_exert_pain_medium_0";
    level.exert_sounds[3]["hitmed"][1] = "vox_plr_2_exert_pain_medium_1";
    level.exert_sounds[3]["hitmed"][2] = "vox_plr_2_exert_pain_medium_2";
    level.exert_sounds[3]["hitmed"][3] = "vox_plr_2_exert_pain_medium_3";
    level.exert_sounds[4]["hitmed"][0] = "vox_plr_3_exert_pain_medium_0";
    level.exert_sounds[4]["hitmed"][1] = "vox_plr_3_exert_pain_medium_1";
    level.exert_sounds[4]["hitmed"][2] = "vox_plr_3_exert_pain_medium_2";
    level.exert_sounds[4]["hitmed"][3] = "vox_plr_3_exert_pain_medium_3";
    level.exert_sounds[1]["hitlrg"][0] = "vox_plr_0_exert_pain_high_0";
    level.exert_sounds[1]["hitlrg"][1] = "vox_plr_0_exert_pain_high_1";
    level.exert_sounds[1]["hitlrg"][2] = "vox_plr_0_exert_pain_high_2";
    level.exert_sounds[1]["hitlrg"][3] = "vox_plr_0_exert_pain_high_3";
    level.exert_sounds[2]["hitlrg"][0] = "vox_plr_1_exert_pain_high_0";
    level.exert_sounds[2]["hitlrg"][1] = "vox_plr_1_exert_pain_high_1";
    level.exert_sounds[2]["hitlrg"][2] = "vox_plr_1_exert_pain_high_2";
    level.exert_sounds[2]["hitlrg"][3] = "vox_plr_1_exert_pain_high_3";
    level.exert_sounds[3]["hitlrg"][0] = "vox_plr_2_exert_pain_high_0";
    level.exert_sounds[3]["hitlrg"][1] = "vox_plr_2_exert_pain_high_1";
    level.exert_sounds[3]["hitlrg"][2] = "vox_plr_2_exert_pain_high_2";
    level.exert_sounds[3]["hitlrg"][3] = "vox_plr_2_exert_pain_high_3";
    level.exert_sounds[4]["hitlrg"][0] = "vox_plr_3_exert_pain_high_0";
    level.exert_sounds[4]["hitlrg"][1] = "vox_plr_3_exert_pain_high_1";
    level.exert_sounds[4]["hitlrg"][2] = "vox_plr_3_exert_pain_high_2";
    level.exert_sounds[4]["hitlrg"][3] = "vox_plr_3_exert_pain_high_3";
}

givecustomloadout( takeallweapons, alreadyspawned )
{
    self giveweapon( "knife_zm" );
    self give_start_weapon( 1 );
}

transit_intermission()
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
    maps\mp\_visionset_mgr::vsmgr_deactivate( "overlay", "zm_transit_burn", self );
    self stopshellshock();
    self.game_over_bg = newclienthudelem( self );
    self.game_over_bg.x = 0;
    self.game_over_bg.y = 0;
    self.game_over_bg.horzalign = "fullscreen";
    self.game_over_bg.vertalign = "fullscreen";
    self.game_over_bg.foreground = 1;
    self.game_over_bg.sort = 1;
    self.game_over_bg setshader( "black", 640, 480 );
    self.game_over_bg.alpha = 1;

    if ( !isdefined( level.the_bus ) )
    {
        self.game_over_bg fadeovertime( 1 );
        self.game_over_bg.alpha = 0;
        wait 5;
        self.game_over_bg thread maps\mp\zombies\_zm::fade_up_over_time( 1 );
    }
    else
    {
        zonestocheck = [];
        zonestocheck[zonestocheck.size] = "zone_amb_bridge";
        zonestocheck[zonestocheck.size] = "zone_trans_11";
        zonestocheck[zonestocheck.size] = "zone_town_west";
        zonestocheck[zonestocheck.size] = "zone_town_west2";
        zonestocheck[zonestocheck.size] = "zone_tow";
        near_bridge = 0;

        foreach ( zone in zonestocheck )
        {
            if ( level.the_bus maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_amb_bridge" ) )
                near_bridge = 1;
        }

        if ( near_bridge )
        {
            trig = getent( "bridge_trig", "targetname" );
            trig notify( "trigger" );
        }

        org = spawn( "script_model", level.the_bus gettagorigin( "tag_camera" ) );
        org setmodel( "tag_origin" );
        org.angles = level.the_bus gettagangles( "tag_camera" );
        org linkto( level.the_bus );
        self setorigin( org.origin );
        self.angles = org.angles;

        if ( !flag( "OnPriDoorYar" ) || !flag( "OnPriDoorYar2" ) )
        {
            flag_set( "OnPriDoorYar" );
            wait_network_frame();
        }

        if ( !level.the_bus.ismoving )
        {
            level.the_bus.gracetimeatdestination = 0.1;
            level.the_bus notify( "depart_early" );
        }

        players = get_players();

        for ( j = 0; j < players.size; j++ )
        {
            player = players[j];
            player camerasetposition( org );
            player camerasetlookat();
            player cameraactivate( 1 );
        }

        self.game_over_bg fadeovertime( 1 );
        self.game_over_bg.alpha = 0;
        wait 12;
        self.game_over_bg fadeovertime( 1 );
        self.game_over_bg.alpha = 1;
        wait 1;
    }
}

transit_standard_intermission()
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
    maps\mp\_visionset_mgr::vsmgr_deactivate( "overlay", "zm_transit_burn", self );
    self stopshellshock();
    points = getstructarray( "intermission", "targetname" );
    point = undefined;

    if ( !isdefined( points ) || points.size == 0 )
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
    self.game_over_bg.x = 0;
    self.game_over_bg.y = 0;
    self.game_over_bg.horzalign = "fullscreen";
    self.game_over_bg.vertalign = "fullscreen";
    self.game_over_bg.foreground = 1;
    self.game_over_bg.sort = 1;
    self.game_over_bg setshader( "black", 640, 480 );
    self.game_over_bg.alpha = 1;
    org = undefined;

    while ( true )
    {
        foreach ( struct in points )
        {
            if ( isdefined( struct.script_string ) && struct.script_string == level.scr_zm_map_start_location )
                point = struct;
        }

        if ( !isdefined( point ) )
            point = points[0];

        if ( !isdefined( org ) )
            self spawn( point.origin, point.angles );

        if ( isdefined( point.target ) )
        {
            if ( !isdefined( org ) )
            {
                org = spawn( "script_model", self.origin + vectorscale( ( 0, 0, -1 ), 60.0 ) );
                org setmodel( "tag_origin" );
            }

            org.origin = point.origin;
            org.angles = point.angles;

            for ( j = 0; j < get_players().size; j++ )
            {
                player = get_players()[j];
                player camerasetposition( org );
                player camerasetlookat();
                player cameraactivate( 1 );
            }

            speed = 20;

            if ( isdefined( point.speed ) )
                speed = point.speed;

            target_point = getstruct( point.target, "targetname" );
            dist = distance( point.origin, target_point.origin );
            time = dist / speed;
            q_time = time * 0.25;

            if ( q_time > 1 )
                q_time = 1;

            self.game_over_bg fadeovertime( q_time );
            self.game_over_bg.alpha = 0;
            org moveto( target_point.origin, time, q_time, q_time );
            org rotateto( target_point.angles, time, q_time, q_time );
            wait( time - q_time );
            self.game_over_bg fadeovertime( q_time );
            self.game_over_bg.alpha = 1;
            wait( q_time );
        }
        else
        {
            self.game_over_bg fadeovertime( 1 );
            self.game_over_bg.alpha = 0;
            wait 5;
            self.game_over_bg thread fade_up_over_time( 1 );
        }
    }
}

meetupwithothercharacters()
{
    self endon( "disconnect" );
    isalone = 1;
    flag_wait( "begin_spawning" );

    while ( isalone )
    {
        players = get_players();

        if ( flag( "solo_game" ) )
            break;

        foreach ( player in players )
        {
            if ( player == self )
                continue;

            if ( distancesquared( self.origin, player.origin ) < 1048576 )
            {
/#
                println( "^2Transit Debug: " + self.name + " met up with " + player.name );
#/
                isalone = 0;
            }
        }

        wait 1;
    }

    self.characterrespawnpoint = undefined;
}

transit_respawn_override( player )
{
    if ( isdefined( player.characterrespawnpoint ) )
    {
/#
        println( "^2Transit Debug: Using character respawn point for " + player.name );
#/
        return player.characterrespawnpoint.origin;
    }

    return undefined;
}

disable_triggers()
{
    trig = getentarray( "trigger_Keys", "targetname" );

    for ( i = 0; i < trig.size; i++ )
        trig[i] trigger_off();
}

transit_zone_init()
{
    flag_init( "always_on" );
    flag_init( "init_classic_adjacencies" );
    flag_set( "always_on" );

    if ( is_classic() )
    {
        flag_set( "init_classic_adjacencies" );
        add_adjacent_zone( "zone_trans_2", "zone_trans_2b", "init_classic_adjacencies" );
        add_adjacent_zone( "zone_station_ext", "zone_trans_2b", "init_classic_adjacencies", 1 );
        add_adjacent_zone( "zone_town_west2", "zone_town_west", "init_classic_adjacencies" );
        add_adjacent_zone( "zone_town_south", "zone_town_church", "init_classic_adjacencies" );
        add_adjacent_zone( "zone_trans_pow_ext1", "zone_trans_7", "init_classic_adjacencies" );
        add_adjacent_zone( "zone_far", "zone_far_ext", "OnFarm_enter" );
    }
    else
    {
        playable_area = getentarray( "player_volume", "script_noteworthy" );

        foreach ( area in playable_area )
        {
            add_adjacent_zone( "zone_station_ext", "zone_trans_2b", "always_on" );

            if ( isdefined( area.script_parameters ) && area.script_parameters == "classic_only" )
                area delete();
        }
    }

    add_adjacent_zone( "zone_pri2", "zone_station_ext", "OnPriDoorYar", 1 );
    add_adjacent_zone( "zone_pri2", "zone_pri", "OnPriDoorYar3", 1 );

    if ( getdvar( "ui_zm_mapstartlocation" ) == "transit" )
    {
        level thread disconnect_door_zones( "zone_pri2", "zone_station_ext", "OnPriDoorYar" );
        level thread disconnect_door_zones( "zone_pri2", "zone_pri", "OnPriDoorYar3" );
    }

    add_adjacent_zone( "zone_station_ext", "zone_pri", "OnPriDoorYar2" );
    add_adjacent_zone( "zone_roadside_west", "zone_din", "OnGasDoorDin" );
    add_adjacent_zone( "zone_roadside_west", "zone_gas", "always_on" );
    add_adjacent_zone( "zone_roadside_east", "zone_gas", "always_on" );
    add_adjacent_zone( "zone_roadside_east", "zone_gar", "OnGasDoorGar" );
    add_adjacent_zone( "zone_trans_diner", "zone_roadside_west", "always_on", 1 );
    add_adjacent_zone( "zone_trans_diner", "zone_gas", "always_on", 1 );
    add_adjacent_zone( "zone_trans_diner2", "zone_roadside_east", "always_on", 1 );
    add_adjacent_zone( "zone_gas", "zone_din", "OnGasDoorDin" );
    add_adjacent_zone( "zone_gas", "zone_gar", "OnGasDoorGar" );
    add_adjacent_zone( "zone_diner_roof", "zone_din", "OnGasDoorDin", 1 );
    add_adjacent_zone( "zone_amb_cornfield", "zone_cornfield_prototype", "always_on" );
    add_adjacent_zone( "zone_tow", "zone_bar", "always_on", 1 );
    add_adjacent_zone( "zone_bar", "zone_tow", "OnTowDoorBar", 1 );
    add_adjacent_zone( "zone_tow", "zone_ban", "OnTowDoorBan" );
    add_adjacent_zone( "zone_ban", "zone_ban_vault", "OnTowBanVault" );
    add_adjacent_zone( "zone_tow", "zone_town_north", "always_on" );
    add_adjacent_zone( "zone_town_north", "zone_ban", "OnTowDoorBan" );
    add_adjacent_zone( "zone_tow", "zone_town_west", "always_on" );
    add_adjacent_zone( "zone_tow", "zone_town_south", "always_on" );
    add_adjacent_zone( "zone_town_south", "zone_town_barber", "always_on", 1 );
    add_adjacent_zone( "zone_tow", "zone_town_east", "always_on" );
    add_adjacent_zone( "zone_town_east", "zone_bar", "OnTowDoorBar" );
    add_adjacent_zone( "zone_tow", "zone_town_barber", "always_on", 1 );
    add_adjacent_zone( "zone_town_barber", "zone_tow", "OnTowDoorBarber", 1 );
    add_adjacent_zone( "zone_town_barber", "zone_town_west", "OnTowDoorBarber" );
    add_adjacent_zone( "zone_far_ext", "zone_brn", "OnFarm_enter" );
    add_adjacent_zone( "zone_far_ext", "zone_farm_house", "open_farmhouse" );
    add_adjacent_zone( "zone_prr", "zone_pow", "OnPowDoorRR", 1 );
    add_adjacent_zone( "zone_pcr", "zone_prr", "OnPowDoorRR" );
    add_adjacent_zone( "zone_pcr", "zone_pow_warehouse", "OnPowDoorWH" );
    add_adjacent_zone( "zone_pow", "zone_pow_warehouse", "OnPowDoorWH" );
    add_adjacent_zone( "zone_tbu", "zone_tow", "vault_opened", 1 );
}

include_powerups()
{
    gametype = getdvar( "ui_gametype" );
    include_powerup( "nuke" );
    include_powerup( "insta_kill" );
    include_powerup( "double_points" );
    include_powerup( "full_ammo" );
    include_powerup( "insta_kill_ug" );

    if ( gametype != "zgrief" )
        include_powerup( "carpenter" );

    if ( is_encounter() && gametype != "zgrief" )
        include_powerup( "minigun" );

    include_powerup( "teller_withdrawl" );
}

add_transit_powerups()
{
    maps\mp\zombies\_zm_powerups::add_zombie_powerup( "teller_withdrawl", "zombie_z_money_icon", &"ZOMBIE_TELLER_PICKUP_DEPOSIT", maps\mp\zombies\_zm_powerups::func_should_never_drop, 1, 0, 0 );
}

include_equipment_for_level()
{
    level.equipment_turret_needs_power = 1;
    level.equipment_etrap_needs_power = 1;
    include_equipment( "jetgun_zm" );
    include_equipment( "riotshield_zm" );
    include_equipment( "equip_turbine_zm" );
    include_equipment( "equip_turret_zm" );
    include_equipment( "equip_electrictrap_zm" );
    level.equipment_planted = ::equipment_planted;
    level.equipment_safe_to_drop = ::equipment_safe_to_drop;
    level.check_force_deploy_origin = ::use_safe_spawn_on_bus;
    limit_equipment( "jetgun_zm", 1 );
    level.explode_overheated_jetgun = 1;
    level.exploding_jetgun_fx = level._effect["lava_burning"];
}

transit_bus_update_retrieve_trigger( player )
{
    self endon( "death" );
    player endon( "zmb_lost_knife" );

    if ( isdefined( level.the_bus ) && ( isdefined( player.isonbus ) && player.isonbus ) )
    {
        wait 2.0;
        trigger = self.retrievabletrigger;
        trigger.origin = ( self.origin[0], self.origin[1], self.origin[2] + 10 );
        self linkto( level.the_bus );
        trigger linkto( self );
    }
    else
    {
        self waittill( "stationary" );

        trigger = self.retrievabletrigger;
        trigger.origin = ( self.origin[0], self.origin[1], self.origin[2] + 10 );
        trigger linkto( self );
    }
}

claymore_safe_to_plant()
{
    if ( self maps\mp\zm_transit_lava::object_touching_lava() )
        return false;

    if ( self.owner maps\mp\zm_transit_lava::object_touching_lava() )
        return false;

    return true;
}

claymore_planted( weapon )
{
    weapon waittill( "stationary" );

    if ( !isdefined( weapon ) )
        return;

    weaponbus = weapon maps\mp\zm_transit_bus::object_is_on_bus();

    if ( weaponbus )
    {
        if ( isdefined( weapon ) )
        {
            weapon setmovingplatformenabled( 1 );
            weapon.equipment_can_move = 1;
            weapon.isonbus = 1;
            weapon.move_parent = level.the_bus;

            if ( isdefined( weapon.damagearea ) )
                weapon.damagearea setmovingplatformenabled( 1 );
        }
    }
}

fakelinkto( linkee )
{
    self.backlinked = 1;

    while ( isdefined( self ) && isdefined( linkee ) )
    {
        self.origin = linkee.origin;
        self.angles = linkee.angles;
        wait 0.05;
    }
}

knife_planted( knife, trigger, parent )
{
    if ( !isdefined( knife ) )
        return;

    weaponbus = knife maps\mp\zm_transit_bus::object_is_on_bus();

    if ( weaponbus )
    {
        trigger linkto( knife );
        trigger setmovingplatformenabled( 1 );
        trigger.isonbus = 1;
        knife setmovingplatformenabled( 1 );
        knife.isonbus = 1;
    }
}

grenade_planted( grenade, model )
{
    if ( !isdefined( grenade ) )
        return;

    weaponbus = grenade maps\mp\zm_transit_bus::object_is_on_bus();

    if ( weaponbus )
    {
        if ( isdefined( grenade ) )
        {
            grenade setmovingplatformenabled( 1 );
            grenade.equipment_can_move = 1;
            grenade.isonbus = 1;
            grenade.move_parent = level.the_bus;

            if ( isdefined( model ) )
            {
                model setmovingplatformenabled( 1 );
                model linkto( level.the_bus );
                model.isonbus = 1;
                grenade fakelinkto( model );
            }
        }
    }
}

grenade_safe_to_throw( player, weapname )
{
    return 1;
}

grenade_safe_to_bounce( player, weapname )
{
    if ( !is_offhand_weapon( weapname ) && !is_grenade_launcher( weapname ) )
        return true;

    if ( self maps\mp\zm_transit_lava::object_touching_lava() )
        return false;

    return true;
}

equipment_safe_to_drop( weapon )
{
    if ( !isdefined( weapon.canmove ) )
        weapon.canmove = weapon maps\mp\zm_transit_bus::object_is_on_bus();

    if ( isdefined( weapon.canmove ) && weapon.canmove )
        return true;

    if ( weapon maps\mp\zm_transit_lava::object_touching_lava() )
        return false;

    return true;
}

use_safe_spawn_on_bus( weapon, origin, angles )
{
    if ( isdefined( self.isonbus ) && self.isonbus && level.the_bus.ismoving )
    {
        weapon.canmove = 1;
        return true;
    }

    return false;
}

equipment_planted( weapon, equipname, groundfrom )
{
    weaponbus = groundfrom maps\mp\zm_transit_bus::object_is_on_bus();

    if ( !weaponbus && weapon maps\mp\zm_transit_lava::object_touching_lava() )
    {
        self maps\mp\zombies\_zm_equipment::equipment_take( equipname );
        wait 0.05;
        self notify( equipname + "_taken" );
        return;
    }

    if ( isdefined( self ) && weaponbus )
    {
        if ( isdefined( weapon ) )
        {
            if ( isdefined( weapon.canmove ) && !weapon.canmove )
            {
                weapon.canmove = 1;
                reregister_unitrigger_as_dynamic( weapon.stub );
            }

            weapon linkto( level.the_bus );
            weapon setmovingplatformenabled( 1 );

            if ( isdefined( weapon.stub ) )
            {
                weapon.stub.link_parent = level.the_bus;
                weapon.stub.origin_parent = weapon;
            }

            weapon.equipment_can_move = 1;
            weapon.isonbus = 1;
            weapon.move_parent = level.the_bus;
        }
    }
}

offhand_weapon_overrride()
{
    register_lethal_grenade_for_level( "frag_grenade_zm" );
    level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
    register_lethal_grenade_for_level( "sticky_grenade_zm" );
    register_tactical_grenade_for_level( "cymbal_monkey_zm" );
    register_tactical_grenade_for_level( "emp_grenade_zm" );
    level.zombie_tactical_grenade_player_init = undefined;
    level.grenade_safe_to_throw = ::grenade_safe_to_throw;
    level.grenade_safe_to_bounce = ::grenade_safe_to_bounce;
    level.grenade_planted = ::grenade_planted;
    level.knife_planted = ::knife_planted;
    register_placeable_mine_for_level( "claymore_zm" );
    level.zombie_placeable_mine_player_init = undefined;
    level.claymore_safe_to_plant = ::claymore_safe_to_plant;
    level.claymore_planted = ::claymore_planted;
    register_melee_weapon_for_level( "knife_zm" );
    register_melee_weapon_for_level( "bowie_knife_zm" );
    register_melee_weapon_for_level( "tazer_knuckles_zm" );
    level.zombie_melee_weapon_player_init = "knife_zm";
    register_equipment_for_level( "jetgun_zm" );
    register_equipment_for_level( "riotshield_zm" );
    register_equipment_for_level( "equip_turbine_zm" );
    register_equipment_for_level( "equip_turret_zm" );
    register_equipment_for_level( "equip_electrictrap_zm" );
    level.zombie_equipment_player_init = undefined;
}

include_weapons()
{
    gametype = getdvar( "ui_gametype" );
    include_weapon( "knife_zm", 0 );
    include_weapon( "frag_grenade_zm", 0 );
    include_weapon( "claymore_zm", 0 );
    include_weapon( "sticky_grenade_zm", 0 );
    include_weapon( "m1911_zm", 0 );
    include_weapon( "m1911_upgraded_zm", 0 );
    include_weapon( "python_zm" );
    include_weapon( "python_upgraded_zm", 0 );
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
    include_weapon( "qcw05_zm" );
    include_weapon( "qcw05_upgraded_zm", 0 );
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
    include_weapon( "xm8_zm" );
    include_weapon( "xm8_upgraded_zm", 0 );
    include_weapon( "type95_zm" );
    include_weapon( "type95_upgraded_zm", 0 );
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
    include_weapon( "rpd_zm" );
    include_weapon( "rpd_upgraded_zm", 0 );
    include_weapon( "hamr_zm" );
    include_weapon( "hamr_upgraded_zm", 0 );
    include_weapon( "usrpg_zm" );
    include_weapon( "usrpg_upgraded_zm", 0 );
    include_weapon( "m32_zm" );
    include_weapon( "m32_upgraded_zm", 0 );
    include_weapon( "cymbal_monkey_zm" );
    include_weapon( "emp_grenade_zm", 1, undefined, ::less_than_normal );

    if ( is_classic() )
        include_weapon( "screecher_arms_zm", 0 );

    if ( gametype != "zgrief" )
    {
        include_weapon( "ray_gun_zm" );
        include_weapon( "ray_gun_upgraded_zm", 0 );
        include_weapon( "jetgun_zm", 0, undefined, ::less_than_normal );
        include_weapon( "riotshield_zm", 0 );
        include_weapon( "tazer_knuckles_zm", 0 );
        include_weapon( "knife_ballistic_no_melee_zm", 0 );
        include_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
        include_weapon( "knife_ballistic_zm" );
        include_weapon( "knife_ballistic_upgraded_zm", 0 );
        include_weapon( "knife_ballistic_bowie_zm", 0 );
        include_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );
        level._uses_retrievable_ballisitic_knives = 1;
        add_limited_weapon( "knife_ballistic_zm", 1 );
        add_limited_weapon( "jetgun_zm", 1 );
        add_limited_weapon( "ray_gun_zm", 4 );
        add_limited_weapon( "ray_gun_upgraded_zm", 4 );
        add_limited_weapon( "knife_ballistic_upgraded_zm", 0 );
        add_limited_weapon( "knife_ballistic_no_melee_zm", 0 );
        add_limited_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
        add_limited_weapon( "knife_ballistic_bowie_zm", 0 );
        add_limited_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );

        if ( isdefined( level.raygun2_included ) && level.raygun2_included )
        {
            include_weapon( "raygun_mark2_zm" );
            include_weapon( "raygun_mark2_upgraded_zm", 0 );
            add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
            add_limited_weapon( "raygun_mark2_zm", 1 );
            add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
        }
    }

    add_limited_weapon( "m1911_zm", 0 );
    add_weapon_locker_mapping( "lsat_zm", "hamr_zm" );
    add_weapon_locker_mapping( "lsat_upgraded_zm", "hamr_upgraded_zm" );
    add_weapon_locker_mapping( "svu_zm", "fnfal_zm" );
    add_weapon_locker_mapping( "svu_upgraded_zm", "fnfal_upgraded_zm" );
    add_weapon_locker_mapping( "pdw57_zm", "qcw05_zm" );
    add_weapon_locker_mapping( "pdw57_upgraded_zm", "qcw05_upgraded_zm" );
    add_weapon_locker_mapping( "an94_zm", "galil_zm" );
    add_weapon_locker_mapping( "an94_upgraded_zm", "galil_upgraded_zm" );
    add_weapon_locker_mapping( "rnma_zm", "python_zm" );
    add_weapon_locker_mapping( "rnma_upgraded_zm", "python_upgraded_zm" );
}

less_than_normal()
{
    return 0.5;
}

custom_add_weapons()
{
    add_zombie_weapon( "m1911_zm", "m1911_upgraded_zm", &"ZOMBIE_WEAPON_M1911", 50, "", "", undefined );
    add_zombie_weapon( "python_zm", "python_upgraded_zm", &"ZOMBIE_WEAPON_PYTHON", 50, "wpck_python", "", undefined, 1 );
    add_zombie_weapon( "judge_zm", "judge_upgraded_zm", &"ZOMBIE_WEAPON_JUDGE", 50, "wpck_judge", "", undefined, 1 );
    add_zombie_weapon( "kard_zm", "kard_upgraded_zm", &"ZOMBIE_WEAPON_KARD", 50, "wpck_kap", "", undefined, 1 );
    add_zombie_weapon( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 50, "wpck_57", "", undefined, 1 );
    add_zombie_weapon( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "", "", undefined );
    add_zombie_weapon( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_duel57", "", undefined, 1 );
    add_zombie_weapon( "ak74u_zm", "ak74u_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "smg", "", undefined );
    add_zombie_weapon( "mp5k_zm", "mp5k_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1000, "smg", "", undefined );
    add_zombie_weapon( "qcw05_zm", "qcw05_upgraded_zm", &"ZOMBIE_WEAPON_QCW05", 50, "wpck_chicom", "", undefined, 1 );
    add_zombie_weapon( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 1500, "shotgun", "", undefined );
    add_zombie_weapon( "rottweil72_zm", "rottweil72_upgraded_zm", &"ZOMBIE_WEAPON_ROTTWEIL72", 500, "shotgun", "", undefined );
    add_zombie_weapon( "saiga12_zm", "saiga12_upgraded_zm", &"ZOMBIE_WEAPON_SAIGA12", 50, "wpck_saiga12", "", undefined, 1 );
    add_zombie_weapon( "srm1216_zm", "srm1216_upgraded_zm", &"ZOMBIE_WEAPON_SRM1216", 50, "wpck_m1216", "", undefined, 1 );
    add_zombie_weapon( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "rifle", "", undefined );
    add_zombie_weapon( "saritch_zm", "saritch_upgraded_zm", &"ZOMBIE_WEAPON_SARITCH", 50, "wpck_sidr", "", undefined, 1 );
    add_zombie_weapon( "m16_zm", "m16_gl_upgraded_zm", &"ZOMBIE_WEAPON_M16", 1200, "burstrifle", "", undefined );
    add_zombie_weapon( "xm8_zm", "xm8_upgraded_zm", &"ZOMBIE_WEAPON_XM8", 50, "wpck_m8a1", "", undefined, 1 );
    add_zombie_weapon( "type95_zm", "type95_upgraded_zm", &"ZOMBIE_WEAPON_TYPE95", 50, "wpck_type25", "", undefined, 1 );
    add_zombie_weapon( "tar21_zm", "tar21_upgraded_zm", &"ZOMBIE_WEAPON_TAR21", 50, "wpck_x95l", "", undefined, 1 );
    add_zombie_weapon( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_galil", "", undefined, 1 );
    add_zombie_weapon( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_fal", "", undefined, 1 );
    add_zombie_weapon( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_dsr50", "", undefined, 1 );
    add_zombie_weapon( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "sniper", "", undefined );
    add_zombie_weapon( "rpd_zm", "rpd_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_rpd", "", undefined, 1 );
    add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_hamr", "", undefined, 1 );
    add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
    add_zombie_weapon( "sticky_grenade_zm", undefined, &"ZOMBIE_WEAPON_STICKY_GRENADE", 250, "grenade", "", 250 );
    add_zombie_weapon( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1000, "grenade", "", undefined );
    add_zombie_weapon( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
    add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_m32", "", undefined, 1 );
    add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
    add_zombie_weapon( "emp_grenade_zm", undefined, &"ZOMBIE_WEAPON_EMP_GRENADE", 2000, "wpck_emp", "", undefined, 1 );
    add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_zm", "knife_ballistic_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined );
    add_zombie_weapon( "knife_ballistic_bowie_zm", "knife_ballistic_bowie_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined );
    add_zombie_weapon( "riotshield_zm", undefined, &"ZOMBIE_WEAPON_RIOTSHIELD", 2000, "riot", "", undefined );
    add_zombie_weapon( "jetgun_zm", undefined, &"ZOMBIE_WEAPON_JETGUN", 2000, "jet", "", undefined );
    add_zombie_weapon( "tazer_knuckles_zm", undefined, &"ZOMBIE_WEAPON_TAZER_KNUCKLES", 100, "tazerknuckles", "", undefined );

    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
        add_zombie_weapon( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "raygun_mark2", "", undefined );
}

include_game_modules()
{

}

initial_round_wait_func()
{
    flag_wait( "initial_blackscreen_passed" );
}

zombie_speed_up()
{
    if ( isdefined( self.isonbus ) && self.isonbus )
        return;

    if ( self.zombie_move_speed != "sprint" )
        self set_zombie_run_cycle( "sprint" );
}

zombie_init_done()
{
    self.allowpain = 0;
    self setphysparams( 15, 0, 48 );
}

setup_dvars()
{
/#
    dvars = [];
    dvars[dvars.size] = "zombie_bus_debug_path";
    dvars[dvars.size] = "zombie_bus_debug_speed";
    dvars[dvars.size] = "zombie_bus_debug_near";
    dvars[dvars.size] = "zombie_bus_debug_attach";
    dvars[dvars.size] = "zombie_bus_skip_objectives";
    dvars[dvars.size] = "zombie_bus_debug_spawners";

    for ( i = 0; i < dvars.size; i++ )
    {
        if ( getdvar( dvars[i] ) == "" )
            setdvar( dvars[i], "0" );
    }
#/
}

setup_zombie_init()
{
    zombies = getentarray( "zombie_spawner", "script_noteworthy" );
    array_thread( zombies, ::add_spawn_function, ::custom_zombie_setup );
}

setup_players()
{
    self.isonbus = 0;
    self.isonbusroof = 0;
    self.isinhub = 1;
    self.insafearea = 1;
}

transit_player_fake_death( vdir )
{
    level notify( "fake_death" );
    self notify( "fake_death" );

    if ( isdefined( self.isonbus ) && self.isonbus )
        level thread transit_player_fake_death_zombies();

    stance = self getstance();
    self.ignoreme = 1;
    self enableinvulnerability();
    self takeallweapons();

    if ( isdefined( self.insta_killed ) && self.insta_killed || self istouching( getent( "depot_lava_pit", "targetname" ) ) || isdefined( self.isonbus ) && self.isonbus && level.the_bus.ismoving )
    {
        self maps\mp\zombies\_zm::player_fake_death();
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

transit_player_fake_death_zombies()
{
    zombies = getaiarray( level.zombie_team );

    foreach ( index, zombie in zombies )
    {
        if ( !isalive( zombie ) )
            continue;

        if ( isdefined( zombie.ignore_game_over_death ) && zombie.ignore_game_over_death )
            continue;

        if ( isdefined( zombie ) )
            zombie dodamage( zombie.health + 666, zombie.origin );

        if ( index % 3 == 0 )
            wait_network_frame();
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
    angles = ( angles[0], angles[1], angles[2] + randomfloatrange( -5, 5 ) );

    if ( isdefined( vdir ) && length( vdir ) > 0 )
    {
        xyspeedmag = 40 + randomint( 12 ) + randomint( 12 );
        xyspeed = xyspeedmag * vectornormalize( ( vdir[0], vdir[1], 0 ) );
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
        floor_height = 10 + origin[2] - eye[2];
        origin += ( 0, 0, floor_height );
        lerptime = 0.5;
        linker moveto( origin, lerptime, lerptime );
        linker rotateto( angles, lerptime, lerptime );
    }

    self freezecontrols( 1 );

    if ( falling )
        linker waittill( "movedone" );

    if ( isdefined( self.isonbus ) && self.isonbus )
        linker linkto( level.the_bus );

    self giveweapon( "death_throe_zm" );
    self switchtoweapon( "death_throe_zm" );

    if ( falling && !( isdefined( self.isonbus ) && self.isonbus ) )
    {
        bounce = randomint( 4 ) + 8;
        origin = origin + ( 0, 0, bounce ) - xyspeed * 0.1;
        lerptime = bounce / 50.0;
        linker moveto( origin, lerptime, 0, lerptime );

        linker waittill( "movedone" );

        origin = origin + ( 0, 0, bounce * -1 ) + xyspeed * 0.1;
        lerptime /= 2.0;
        linker moveto( origin, lerptime, lerptime );

        linker waittill( "movedone" );

        linker moveto( origin, 5, 0 );
    }

    wait 15;
    linker delete();
}

transit_player_fake_death_cleanup()
{
    if ( isdefined( self._fall_down_anchor ) )
    {
        self._fall_down_anchor delete();
        self._fall_down_anchor = undefined;
    }
}

custom_zombie_setup()
{
    if ( is_survival() && !is_standard() )
    {
        self.nearbus = 0;
        self.isonbus = 0;
        self.isonbusroof = 0;
        self.was_walking = 0;
        self.candropsafekey = 1;
        self.candropbuskey = 1;
        self.custom_points_on_turret_damage = 0;
    }
}

bunkerdoorrotate( open, time = 0.2 )
{
    rotate = self.script_float;

    if ( !open )
        rotate *= -1;

    if ( isdefined( self.script_angles ) )
    {
        self notsolid();
        self rotateto( self.script_angles, time, 0, 0 );
        self thread maps\mp\zombies\_zm_blockers::door_solid_thread();
    }
}

zm_transit_emp_init()
{
    level.custom_emp_detonate = ::zm_transit_emp_detonate;
    set_zombie_var( "emp_bus_off_range", 1200 );
    set_zombie_var( "emp_bus_off_time", 45 );
}

zm_transit_emp_detonate( grenade_origin )
{
    test_ent = spawn( "script_origin", grenade_origin );

    if ( test_ent maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_prr" ) )
    {
        if ( flag( "power_on" ) )
        {
            trig = getent( "powerswitch_buildable_trigger_power", "targetname" );
            trig notify( "trigger" );
        }
    }

    test_ent delete();
}

emp_detonate_boss( grenade_origin )
{

}

register_screecher_lights()
{
    level.safety_lights = getstructarray( "screecher_escape", "targetname" );

    for ( i = 0; i < level.safety_lights.size; i++ )
    {
        safety = level.safety_lights[i];
        name = safety.script_noteworthy;

        if ( !isdefined( name ) )
        {
/#
            println( "ERROR Unnamed screecher light detected" );
#/
            name = "light_" + i;
        }

        clientfieldname = "screecher_light_" + name;
        level.safety_lights[i].clientfieldname = clientfieldname;
        registerclientfield( "world", clientfieldname, 1, 1, "int" );
    }
}

include_powered_items()
{
    if ( is_classic() )
    {
        include_powered_item( ::bus_power_on, ::bus_power_off, ::bus_range, maps\mp\zombies\_zm_power::cost_negligible, 1, 1, undefined );

        if ( isdefined( level.safety_lights ) )
        {
            for ( i = 0; i < level.safety_lights.size; i++ )
                include_powered_item( ::safety_light_power_on, ::safety_light_power_off, ::safety_light_range, maps\mp\zombies\_zm_power::cost_low_if_local, 0, 0, level.safety_lights[i] );
        }
    }
}

bus_range( delta, origin, radius )
{
    if ( isdefined( level.the_bus ) )
    {
        if ( distance2dsquared( origin, level.the_bus.origin ) < radius * radius )
            return true;

        forward = anglestoforward( level.the_bus.angles );
        forward = vectorscale( forward, 275 );
        bus_front = level.the_bus.origin + forward;

        if ( distance2dsquared( origin, bus_front ) < radius * radius )
            return true;
    }

    return false;
}

bus_power_on( origin, radius )
{
/#
    println( "^1ZM POWER: bus on\\n" );
#/
    level.the_bus thread maps\mp\zm_transit_bus::bus_power_on();
}

bus_power_off( origin, radius )
{
/#
    println( "^1ZM POWER: bus off\\n" );
#/
    level.the_bus thread maps\mp\zm_transit_bus::bus_power_off();
}

safety_light_range( delta, origin, radius )
{
    if ( distancesquared( self.target.origin, origin ) < radius * radius )
        return true;

    return false;
}

safety_light_power_on( origin, radius )
{
/#
    println( "^1ZM POWER: bus on\\n" );
#/
    self.target.power_on = 1;
    self.target notify( "power_on" );

    if ( isdefined( self.target.clientfieldname ) )
        level setclientfield( self.target.clientfieldname, 1 );

    level notify( "safety_light_power_on", self );
}

safety_light_power_off( origin, radius )
{
/#
    println( "^1ZM POWER: bus off\\n" );
#/
    self.target.power_on = 0;
    self.target notify( "power_off" );

    if ( isdefined( self.target.clientfieldname ) )
        level setclientfield( self.target.clientfieldname, 0 );

    level notify( "safety_light_power_off", self );
}

zombie_transit_devgui( cmd )
{
/#
    cmd_strings = strtok( cmd, " " );

    switch ( cmd_strings[0] )
    {
        case "pickup":
            if ( !level.the_bus.upgrades[cmd_strings[1]].pickedup )
                level.the_bus.upgrades[cmd_strings[1]].trigger notify( "trigger", get_players()[0] );

            break;
        case "spawn":
            player = get_players()[0];
            spawnername = undefined;

            if ( cmd_strings[1] == "regular" )
                spawnername = "zombie_spawner";
            else if ( cmd_strings[1] == "screecher" )
            {

            }
            else
                return;

            direction = player getplayerangles();
            direction_vec = anglestoforward( direction );
            eye = player geteye();
            scale = 8000;
            direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
            trace = bullettrace( eye, eye + direction_vec, 0, undefined );
            guy = undefined;

            if ( cmd_strings[1] == "screecher" )
            {
                spawner = level.screecher_spawners[0];
                guy = maps\mp\zombies\_zm_utility::spawn_zombie( spawner );
            }
            else if ( cmd_strings[1] == "regular" )
            {
                spawners = getentarray( spawnername, "script_noteworthy" );
                spawner = spawners[0];
                guy = maps\mp\zombies\_zm_utility::spawn_zombie( spawner );
                guy.favoriteenemy = player;
                guy.script_string = "zombie_chaser";
                guy thread maps\mp\zombies\_zm_spawner::zombie_spawn_init();
                guy custom_zombie_setup();
            }

            guy forceteleport( trace["position"], player.angles + vectorscale( ( 0, 1, 0 ), 180.0 ) );
            break;
        case "test_attach":
            attach_name = getdvar( _hash_61FFB6CE );
            opening = level.the_bus maps\mp\zm_transit_openings::busgetopeningfortag( attach_name );
            jump = level.the_bus maps\mp\zm_transit_openings::_busgetjumptagfrombindtag( attach_name );

            if ( isdefined( opening ) )
            {
                if ( isdefined( opening.zombie ) )
                    iprintln( "Zombie already attached to opening: " + attach_name );
                else
                {
                    origin = level.the_bus gettagorigin( attach_name );

                    if ( isdefined( jump ) )
                    {
                        jump_origin = level.the_bus gettagorigin( jump );

                        if ( isdefined( opening.enabled ) && opening.enabled )
                            debugstar( jump_origin, 1000, ( 0, 1, 0 ) );
                        else
                            debugstar( jump_origin, 1000, ( 1, 0, 0 ) );
                    }

                    zombie_spawners = getentarray( "zombie_spawner", "script_noteworthy" );
                    zombie = spawn_zombie( zombie_spawners[0] );
                    zombie.cannotattachtobus = 1;
                    zombie thread maps\mp\zm_transit_openings::zombieattachtobus( level.the_bus, opening, 0 );
                }
            }
            else
                iprintln( "Couldn't find opening for tag: " + attach_name );

            break;
        case "attach_tag":
            setdvar( "zombie_bus_debug_attach", cmd_strings[1] );
            break;
        case "hatch_available":
            if ( isdefined( level.the_bus ) )
                level.the_bus notify( "hatch_mantle_allowed" );

            break;
        case "ambush_round":
            if ( isdefined( level.ambushpercentageperstop ) )
            {
                if ( cmd_strings[1] == "always" )
                    level.ambushpercentageperstop = 100;
                else if ( cmd_strings[1] == "never" )
                    level.ambushpercentageperstop = 0;
            }

            break;
        case "gas":
            if ( cmd_strings[1] == "add" )
                level.the_bus maps\mp\zm_transit_bus::busgasadd( getdvarint( _hash_69C4D2C1 ) );
            else if ( cmd_strings[1] == "remove" )
                level.the_bus maps\mp\zm_transit_bus::busgasremove( getdvarint( _hash_69C4D2C1 ) );

            break;
        case "force_bus_to_leave":
            level.the_bus notify( "depart_early" );

            if ( isdefined( level.bus_leave_hud ) )
                level.bus_leave_hud.alpha = 0;

            break;
        case "teleport_to_bus":
            get_players()[0] setorigin( level.the_bus localtoworldcoords( vectorscale( ( 0, 0, 1 ), 25.0 ) ) );
            break;
        case "teleport_bus":
            node = getvehiclenode( cmd_strings[1], "script_noteworthy" );

            if ( isdefined( node ) )
            {
                level.the_bus thread buspathblockerdisable();
                wait 0.1;
                level.the_bus attachpath( node );
                level.the_bus maps\mp\zm_transit_bus::busstopmoving( 1 );
                wait 0.1;
                level.the_bus thread buspathblockerenable();
            }

            break;
        case "avogadro_round_skip":
            if ( isdefined( level.next_avogadro_round ) )
                maps\mp\zombies\_zm_devgui::zombie_devgui_goto_round( level.next_avogadro_round );

            break;
        case "debug_print_emp_points":
            if ( !( isdefined( level.debug_print_emp_points ) && level.debug_print_emp_points ) )
            {
                level.debug_print_emp_points = 1;
                vehnodes = getvehiclenodearray( "emp_stop_point", "script_noteworthy" );

                foreach ( node in vehnodes )
                    maps\mp\zombies\_zm_devgui::showonespawnpoint( node, ( 0, 0, 1 ), "kill_debug_print_emp_points", undefined, "EMP STOP" );
            }

            break;
        case "debug_stop_print_emp_points":
            if ( isdefined( level.debug_print_emp_points ) && level.debug_print_emp_points )
            {
                level notify( "kill_debug_print_emp_points" );
                level.debug_print_emp_points = undefined;
            }

            break;
        default:
            break;
    }
#/
}

is_valid_powerup_location( powerup )
{
    valid = 0;

    if ( !isdefined( level.powerup_areas ) )
        level.powerup_areas = getentarray( "powerup_area", "script_noteworthy" );

    if ( !isdefined( level.playable_areas ) )
        level.playable_areas = getentarray( "player_volume", "script_noteworthy" );

    for ( i = 0; i < level.powerup_areas.size && !valid; i++ )
    {
        area = level.powerup_areas[i];
        valid = powerup istouching( area );
    }

    for ( i = 0; i < level.playable_areas.size && !valid; i++ )
    {
        area = level.playable_areas[i];
        valid = powerup istouching( area );
    }

    return valid;
}

zombie_transit_player_too_many_weapons_monitor_callback( weapon )
{
    if ( self maps\mp\zm_transit_cling::playerisclingingtobus() )
        return false;

    return true;
}

zombie_transit_audio_alias_override()
{
    maps\mp\zm_transit_automaton::initaudioaliases();
    init_transit_player_dialogue();
    add_transit_response_chance();
}

falling_death_init()
{
    trig = getent( "transit_falling_death", "targetname" );

    if ( isdefined( trig ) )
    {
        while ( true )
        {
            trig waittill( "trigger", who );

            if ( !( isdefined( who.insta_killed ) && who.insta_killed ) )
                who thread insta_kill_player();
        }
    }
}

insta_kill_player()
{
    self endon( "disconnect" );

    if ( isdefined( self.insta_killed ) && self.insta_killed )
        return;

    self maps\mp\zombies\_zm_buildables::player_return_piece_to_original_spawn();

    if ( is_player_killable( self ) )
    {
        self.insta_killed = 1;
        in_last_stand = 0;

        if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
            in_last_stand = 1;

        if ( getnumconnectedplayers() == 1 )
        {
            if ( isdefined( self.lives ) && self.lives > 0 )
            {
                self.waiting_to_revive = 1;
                points = getstruct( "zone_pcr", "script_noteworthy" );
                spawn_points = getstructarray( points.target, "targetname" );
                point = spawn_points[0];
                self dodamage( self.health + 1000, ( 0, 0, 0 ) );
                maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 1, level.zm_transit_burn_max_duration );
                wait 0.5;
                self freezecontrols( 1 );
                wait 0.25;
                self setorigin( point.origin + vectorscale( ( 0, 0, 1 ), 20.0 ) );
                self.angles = point.angles;

                if ( in_last_stand )
                {
                    flag_set( "instant_revive" );
                    wait_network_frame();
                    flag_clear( "instant_revive" );
                }
                else
                {
                    self thread maps\mp\zombies\_zm_laststand::auto_revive( self );
                    self.waiting_to_revive = 0;
                    self.solo_respawn = 0;
                    self.lives = 0;
                }

                self freezecontrols( 0 );
                self.insta_killed = 0;
            }
            else
            {
                self dodamage( self.health + 1000, ( 0, 0, 0 ) );
                maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 2, level.zm_transit_burn_max_duration );
            }
        }
        else
        {
            self dodamage( self.health + 1000, ( 0, 0, 0 ) );
            maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 1, level.zm_transit_burn_max_duration );
            wait_network_frame();
            self.bleedout_time = 0;
        }

        self notify( "burned" );
        self.insta_killed = 0;
    }
}

is_player_killable( player, checkignoremeflag )
{
    if ( !isdefined( player ) )
        return false;

    if ( !isalive( player ) )
        return false;

    if ( !isplayer( player ) )
        return false;

    if ( player.sessionstate == "spectator" )
        return false;

    if ( player.sessionstate == "intermission" )
        return false;

    if ( isdefined( checkignoremeflag ) && player.ignoreme )
        return false;

    return true;
}

delete_bus_pieces()
{
    wait 3;

    if ( isdefined( level._bus_pieces_deleted ) && level._bus_pieces_deleted )
        return;

    level._bus_pieces_deleted = 1;
    hatch_mantle = getent( "hatch_mantle", "targetname" );

    if ( isdefined( hatch_mantle ) )
        hatch_mantle delete();

    hatch_clip = getentarray( "hatch_clip", "targetname" );
    array_thread( hatch_clip, ::self_delete );
    plow_clip = getentarray( "plow_clip", "targetname" );
    array_thread( plow_clip, ::self_delete );
    light = getent( "busLight2", "targetname" );

    if ( isdefined( light ) )
        light delete();

    light = getent( "busLight1", "targetname" );

    if ( isdefined( light ) )
        light delete();

    blocker = getent( "bus_path_blocker", "targetname" );

    if ( isdefined( blocker ) )
        blocker delete();

    lights = getentarray( "bus_break_lights", "targetname" );
    array_thread( lights, ::self_delete );
    orgs = getentarray( "bus_bounds_origin", "targetname" );
    array_thread( orgs, ::self_delete );
    door_blocker = getentarray( "bus_door_blocker", "targetname" );
    array_thread( door_blocker, ::self_delete );
    driver = getent( "bus_driver_head", "targetname" );

    if ( isdefined( driver ) )
        driver delete();

    plow = getent( "trigger_plow", "targetname" );

    if ( isdefined( plow ) )
        plow delete();

    plow_attach_point = getent( "plow_attach_point", "targetname" );

    if ( isdefined( plow_attach_point ) )
        plow_attach_point delete();

    bus = getent( "the_bus", "targetname" );

    if ( isdefined( bus ) )
        bus delete();

    barriers = getzbarrierarray();

    foreach ( barrier in barriers )
    {
        if ( isdefined( barrier.classname ) && issubstr( barrier.classname, "zb_bus" ) )
        {
            for ( x = 0; x < barrier getnumzbarrierpieces(); x++ )
                barrier setzbarrierpiecestate( x, "opening" );

            barrier hide();
        }
    }
}

init_transit_stats()
{
    self maps\mp\zm_transit_sq::init_player_sidequest_stats();
    self maps\mp\zm_transit_achievement::init_player_achievement_stats();
}

kill_zombies_depot()
{
    if ( level.zones["zone_pri"].is_occupied == 1 || flag( "OnPriDoorYar2" ) )
        return;

    if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_pri" ) )
    {
        self.marked_for_recycle = 1;
        self dodamage( self.health + 666, self.origin, self );
        return;
    }

    if ( isdefined( self.zone_name ) && ( self.zone_name == "zone_pri" || self.zone_name == "zone_pri2" ) && ( self.ignoreall || !self in_playable_zone() ) )
    {
        self.marked_for_recycle = 1;
        self dodamage( self.health + 666, self.origin, self );
        return;
    }
}

in_playable_zone()
{
    if ( !isdefined( level.playable_areas ) )
        level.playable_areas = getentarray( "player_volume", "script_noteworthy" );

    foreach ( zone in level.playable_areas )
    {
        if ( self istouching( zone ) )
            return true;
    }

    return false;
}

lava_damage_depot()
{
    trigs = getentarray( "lava_damage", "targetname" );
    volume = getent( "depot_lava_volume", "targetname" );
    exploder( 2 );

    foreach ( trigger in trigs )
    {
        if ( isdefined( trigger.script_string ) && trigger.script_string == "depot_lava" )
            trig = trigger;
    }

    if ( isdefined( trig ) )
        trig.script_float = 0.05;

    while ( level.round_number < 3 )
        level waittill( "start_of_round" );

    while ( !volume depot_lava_seen() )
        wait 2;

    if ( isdefined( trig ) )
    {
        trig.script_float = 0.4;
        earthquake( 0.5, 1.5, trig.origin, 1000 );
        level clientnotify( "earth_crack" );
        crust = getent( "depot_black_lava", "targetname" );
        crust delete();
    }

    stop_exploder( 2 );
    exploder( 3 );
}

depot_lava_seen()
{
    check_volume = getent( "depot_lava_check", "targetname" );
    players = get_players();

    foreach ( player in players )
    {
        if ( player istouching( check_volume ) )
        {
            seen = self maps\mp\zm_transit_distance_tracking::player_can_see_me( player );

            if ( seen )
                return true;
        }
    }

    return false;
}

assign_lowest_unused_character_index()
{
    charindexarray = [];
    charindexarray[0] = 0;
    charindexarray[1] = 1;
    charindexarray[2] = 2;
    charindexarray[3] = 3;
    players = get_players();

    if ( players.size == 1 )
    {
        charindexarray = array_randomize( charindexarray );
        return charindexarray[0];
    }
    else if ( players.size == 2 )
    {
        foreach ( player in players )
        {
            if ( isdefined( player.characterindex ) )
            {
                if ( player.characterindex == 2 || player.characterindex == 0 )
                {
                    if ( randomint( 100 ) > 50 )
                        return 1;

                    return 3;
                }
                else if ( player.characterindex == 3 || player.characterindex == 1 )
                {
                    if ( randomint( 100 ) > 50 )
                        return 0;

                    return 2;
                }
            }
        }
    }
    else
    {
        foreach ( player in players )
        {
            if ( isdefined( player.characterindex ) )
                arrayremovevalue( charindexarray, player.characterindex, 0 );
        }

        if ( charindexarray.size > 0 )
            return charindexarray[0];
    }

    return 0;
}

dog_spawn_transit_logic( dog_array, favorite_enemy )
{
    dog_locs = array_randomize( level.enemy_dog_locations );

    for ( i = 0; i < dog_locs.size; i++ )
    {
        if ( isdefined( level.old_dog_spawn ) && level.old_dog_spawn == dog_locs[i] )
            continue;

        canuse = 1;
        players = get_players();

        foreach ( player in players )
        {
            if ( !canuse )
                continue;

            dist_squared = distancesquared( dog_locs[i].origin, player.origin );

            if ( dist_squared < 160000 || dist_squared > 1322500 )
                canuse = 0;
        }

        if ( canuse )
        {
            level.old_dog_spawn = dog_locs[i];
            return dog_locs[i];
        }
    }

    return dog_locs[0];
}

bank_teller_init()
{
    playfx( level._effect["fx_zmb_tranzit_key_glint"], ( 760, 461, -30 ), vectorscale( ( 0, -1, 0 ), 90.0 ) );
    playfx( level._effect["fx_zmb_tranzit_key_glint"], ( 760, 452, -30 ), vectorscale( ( 0, -1, 0 ), 90.0 ) );
}

player_name_fade_control()
{
    while ( true )
    {
        players = get_players();

        foreach ( player in players )
        {
            if ( !isdefined( player.infog ) )
            {
                player.infog = 0;
                player.old_infog = 0;
                player.infogtimer = 0;
            }

            player.old_infog = player.infog;
            infog = is_player_in_fog( player );

            if ( infog )
                player.infogtimer++;

            player.infog = infog;

            if ( player.infog != player.old_infog && !( isdefined( player.isonbus ) && player.isonbus ) )
            {
                if ( infog )
                {
                    if ( player.infogtimer < 5 )
                        continue;

                    line = "in_fog";
                }
                else
                {
                    if ( player.infogtimer < 15 )
                        continue;

                    line = "out_of_fog";
                    player.infogtimer = 0;
                }

                if ( maps\mp\zombies\_zm_audio::get_response_chance( line ) > randomint( 100 ) && !isdefined( player.screecher ) )
                    player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", line );
            }

            if ( isdefined( level.set_player_in_fog ) )
                player thread [[ level.set_player_in_fog ]]( infog );
        }

        wait 1;
    }
}

is_player_in_fog( player )
{
    if ( player_entered_safety_zone( player ) )
        return false;

    if ( player_entered_safety_light( player ) )
        return false;

    curr_zone = player get_current_zone( 1 );

    if ( isdefined( curr_zone ) && !( isdefined( curr_zone.screecher_zone ) && curr_zone.screecher_zone ) )
        return false;

    return true;
}

add_transit_response_chance()
{
    add_vox_response_chance( "in_fog", 100 );
    add_vox_response_chance( "out_of_fog", 65 );
    add_vox_response_chance( "killed_screecher", 20 );
    add_vox_response_chance( "screecher_attack", 5 );
    add_vox_response_chance( "screecher_flee", 50 );
    add_vox_response_chance( "screecher_cut", 15 );
    add_vox_response_chance( "screecher_flee_green", 75 );
    add_vox_response_chance( "crawl_spawn", 10 );
    add_vox_response_chance( "screecher_jumpoff", 50 );
    add_vox_response_chance( "reboard", 5 );
    add_vox_response_chance( "jetgun_kill", 10 );
    add_vox_response_chance( "achievement", 100 );
    add_vox_response_chance( "power_on", 100 );
    add_vox_response_chance( "power_off", 100 );
    add_vox_response_chance( "power_core", 100 );
    add_vox_response_chance( "upgrade", 100 );
    add_vox_response_chance( "build_pck_bshield", 45 );
    add_vox_response_chance( "build_pck_bturret", 45 );
    add_vox_response_chance( "build_pck_btrap", 45 );
    add_vox_response_chance( "build_pck_bturbine", 45 );
    add_vox_response_chance( "build_pck_bjetgun", 45 );
    add_vox_response_chance( "build_pck_wshield", 45 );
    add_vox_response_chance( "build_pck_wturret", 45 );
    add_vox_response_chance( "build_pck_wtrap", 45 );
    add_vox_response_chance( "build_pck_wturbine", 45 );
    add_vox_response_chance( "build_pck_wjetgun", 45 );
    add_vox_response_chance( "build_plc_shield", 45 );
    add_vox_response_chance( "build_plc_turret", 45 );
    add_vox_response_chance( "build_plc_trap", 45 );
    add_vox_response_chance( "build_plc_turbine", 45 );
    add_vox_response_chance( "build_pickup", 45 );
    add_vox_response_chance( "build_swap", 45 );
    add_vox_response_chance( "build_add", 45 );
    add_vox_response_chance( "build_final", 45 );
}

init_transit_player_dialogue()
{
    level.vox zmbvoxadd( "player", "general", "in_fog", "map_in_fog", undefined );
    level.vox zmbvoxadd( "player", "general", "out_of_fog", "map_out_fog", undefined );
    level.vox zmbvoxadd( "player", "perk", "specialty_scavenger", "perk_tombstone", undefined );
    level.vox zmbvoxadd( "player", "general", "revive_down", "bus_down", undefined );
    level.vox zmbvoxadd( "player", "general", "revive_up", "heal_revived", undefined );
    level.vox zmbvoxadd( "player", "general", "screecher_attack", "screecher_attack", "resp_screecher_attack" );
    level.vox zmbvoxadd( "player", "general", "hr_resp_screecher_attack", "hr_resp_screecher_attack", undefined );
    level.vox zmbvoxadd( "player", "general", "riv_resp_screecher_attack", "riv_resp_screecher_attack", undefined );
    level.vox zmbvoxadd( "player", "general", "screecher_flee", "screecher_flee", undefined );
    level.vox zmbvoxadd( "player", "general", "screecher_jumpoff", "screecher_off", undefined );
    level.vox zmbvoxadd( "player", "general", "screecher_flee_green", "screecher_teleport", undefined );
    level.vox zmbvoxadd( "player", "kill", "screecher", "kill_screecher", undefined );
    level.vox zmbvoxadd( "player", "general", "screecher_cut", "screecher_cut", undefined );
    level.vox zmbvoxadd( "player", "general", "achievement", "earn_acheivement", undefined );
    level.vox zmbvoxadd( "player", "general", "no_money_weapon", "nomoney_weapon", undefined );
    level.vox zmbvoxadd( "player", "general", "no_money_box", "nomoney_box", undefined );
    level.vox zmbvoxadd( "player", "general", "exert_sigh", "exert_sigh", undefined );
    level.vox zmbvoxadd( "player", "general", "exert_laugh", "exert_laugh", undefined );
    level.vox zmbvoxadd( "player", "general", "pain_high", "pain_high", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_bshield", "build_pck_bshield", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_bturret", "build_pck_bturret", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_btrap", "build_pck_btrap", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_bturbine", "build_pck_bturbine", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_bjetgun", "build_pck_bjetgun", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wshield", "build_pck_wshield", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wturret", "build_pck_wturret", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wtrap", "build_pck_wtrap", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wturbine", "build_pck_wturbine", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wjetgun", "build_pck_wjetgun", undefined );
    level.vox zmbvoxadd( "player", "general", "build_plc_shield", "build_plc_shield", undefined );
    level.vox zmbvoxadd( "player", "general", "build_plc_turret", "build_plc_turret", undefined );
    level.vox zmbvoxadd( "player", "general", "build_plc_trap", "build_plc_trap", undefined );
    level.vox zmbvoxadd( "player", "general", "build_plc_turbine", "build_plc_turbine", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pickup", "build_pickup", undefined );
    level.vox zmbvoxadd( "player", "general", "build_swap", "build_swap", undefined );
    level.vox zmbvoxadd( "player", "general", "build_add", "build_add", undefined );
    level.vox zmbvoxadd( "player", "general", "build_final", "build_final", undefined );
    level.vox zmbvoxadd( "player", "general", "intro", "power_off", undefined );
    level.vox zmbvoxadd( "player", "power", "power_on", "power_on", undefined );
    level.vox zmbvoxadd( "player", "power", "power_core", "power_core", undefined );
    level.vox zmbvoxadd( "player", "general", "reboard", "rebuild_boards", undefined );
    level.vox zmbvoxadd( "player", "general", "upgrade", "find_secret", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_bus", "map_out_bus", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_tunnel", "map_out_tunnel", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_diner", "map_out_diner", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_1forest", "map_out_1forest", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_farm", "map_out_farm", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_corn", "map_out_corn", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_power", "map_out_power", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_2forest", "map_out_2forest", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_town", "map_out_town", undefined );
    level.vox zmbvoxadd( "player", "general", "map_out_bridge", "map_out_bridge", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bus1", "map_in_bus1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_tunnel1", "map_in_tunnel1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_diner1", "map_in_diner1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_1forest1", "map_in_1forest1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_farm1", "map_in_farm1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_corn1", "map_in_corn1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_power1", "map_in_power1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_2forest1", "map_in_2forest1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_town1", "map_in_town1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bridge1", "map_in_bridge1", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bus2", "map_in_bus2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_tunnel2", "map_in_tunnel2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_diner2", "map_in_diner2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_1forest2", "map_in_1forest2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_farm2", "map_in_farm2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_corn2", "map_in_corn2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_power2", "map_in_power2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_2forest2", "map_in_2forest2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_town2", "map_in_town2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bridge2", "map_in_bridge2", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bus3", "map_in_bus3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_tunnel3", "map_in_tunnel3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_diner3", "map_in_diner3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_1forest3", "map_in_1forest3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_farm3", "map_in_farm3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_corn3", "map_in_corn3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_power3", "map_in_power3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_2forest3", "map_in_2forest3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_town3", "map_in_town3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bridge3", "map_in_bridge3", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bus4", "map_in_bus4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_tunnel4", "map_in_tunnel4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_diner4", "map_in_diner4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_1forest4", "map_in_1forest4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_farm4", "map_in_farm4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_corn4", "map_in_corn4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_power4", "map_in_power4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_2forest4", "map_in_2forest4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_town4", "map_in_town4", undefined );
    level.vox zmbvoxadd( "player", "general", "map_in_bridge4", "map_in_bridge4", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_zom_roof", "bus_zom_roof", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_zom_climb", "bus_zom_climb", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_zom_atk", "bus_zom_atk", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_zom_ent", "bus_zom_ent", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_zom_none", "bus_zom_none", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_zom_chase", "bus_zom_chase", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_stop", "bus_stop", undefined );
    level.vox zmbvoxadd( "player", "general", "bus_ride", "bus_ride", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_reveal", "avogadro_reveal", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_above", "avogadro_above", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_storm", "avogadro_storm", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_arrive", "avogadro_arrive", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_attack", "avogadro_attack", "resp_avogadro_attack" );
    level.vox zmbvoxadd( "player", "general", "hr_resp_avogadro_attack", "hr_resp_avogadro_attack", undefined );
    level.vox zmbvoxadd( "player", "general", "riv_resp_avogadro_attack", "riv_resp_avogadro_attack", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_wound", "avogadro_wound", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_flee", "avogadro_flee", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_onbus", "avogadro_onbus", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_atkbus", "avogadro_atkbus", undefined );
    level.vox zmbvoxadd( "player", "general", "avogadro_stopbus", "avogadro_stopbus", undefined );
    level.vox zmbvoxadd( "player", "general", "exert_death", "exert_death_high", undefined );
    level.vox zmbvoxadd( "player", "kill", "jetgun_kill", "kill_jet", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_wait", "pap_wait", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_wait2", "pap_wait2", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_arm", "pap_arm", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_arm2", "pap_arm2", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_hint", "pap_hint", undefined );
    maps\mp\zombies\_zm_audio_announcer::createvox( "first_drop", "first_drop" );
    level.station_pa_vox = [];

    for ( i = 0; i < 10; i++ )
        level.station_pa_vox[i] = "vox_stat_pa_generic_" + i;

    level.survivor_vox = [];

    for ( i = 0; i < 5; i++ )
        level.survivor_vox[i] = "vox_radi_distress_message_" + i;
}

transit_audio_custom_response_line( player, index, category, type )
{
    russman = 0;
    samuel = 1;
    misty = 2;
    marlton = 3;

    switch ( player.characterindex )
    {
        case 0:
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, samuel, marlton, category, type );
            break;
        case 1:
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, russman, misty, category, type );
            break;
        case 2:
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, marlton, samuel, category, type );
            break;
        case 3:
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, misty, russman, category, type );
            break;
    }
}

powerup_intro_vox( powerup )
{
    say_intro = 0;
    players = get_players();

    foreach ( player in players )
    {
        if ( player maps\mp\zombies\_zm_stats::get_global_stat( "POWERUP_INTRO_PLAYED" ) == 1 )
            continue;
        else
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( "powerup_intro_played", 1 );
            say_intro = 1;
        }
    }

    level.powerup_intro_vox = undefined;
    powerup_name = powerup.powerup_name;
    powerup thread maps\mp\zombies\_zm_powerups::powerup_delete();
    powerup notify( "powerup_grabbed" );

    if ( !say_intro )
    {
        level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( powerup_name );
        level.powerup_vo_available = undefined;
        return;
    }

    flag_clear( "zombie_drop_powerups" );
    level.powerup_intro = 1;
    org = spawn( "script_origin", get_players()[0].origin );
    org playsoundwithnotify( "vox_zmba_first_drop_0", "first_powerup_intro_done" );

    org waittill( "first_powerup_intro_done" );

    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( powerup_name );
    org delete();
    flag_set( "zombie_drop_powerups" );
    level.powerup_intro = 0;
    level.powerup_vo_available = undefined;
}

powerup_vo_available()
{
    wait 0.1;

    if ( isdefined( level.powerup_intro ) && level.powerup_intro )
        return false;

    return true;
}

buildable_build_custom_func( stub )
{
    buildable = stub.buildablezone;
    counter = 0;

    for ( i = 0; i < buildable.pieces.size; i++ )
    {
        if ( isdefined( buildable.pieces[i].built ) && buildable.pieces[i].built )
            counter++;
    }

    if ( counter == buildable.pieces.size - 1 )
        self thread do_player_general_vox( "general", "build_final", 45 );
}

bank_pap_hint()
{
    volume = getent( "zone_ban", "targetname" );

    while ( true )
    {
        players = get_players();

        foreach ( player in players )
        {
            if ( player istouching( volume ) && is_player_valid( player ) )
            {
                player thread do_player_general_vox( "general", "pap_hint", undefined, 100 );
                return;
            }
        }

        wait 10;
    }
}

power_pap_hint()
{
    trigs = getentarray( "local_electric_door", "script_noteworthy" );
    lab_trig = undefined;

    foreach ( trig in trigs )
    {
        if ( isdefined( trig.target ) && trig.target == "lab_secret_hatch" )
            lab_trig = trig;
    }

    if ( !isdefined( lab_trig ) )
        return;

    while ( true )
    {
        lab_trig waittill( "trigger", who );

        if ( isplayer( who ) && is_player_valid( who ) )
        {
            who thread do_player_general_vox( "general", "pap_hint", undefined, 100 );
            return;
        }
    }
}

transit_buildable_vo_override( name, from_world )
{
    if ( isdefined( level.power_cycled ) && level.power_cycled && name == "turbine" && !( isdefined( from_world ) && from_world ) && !flag( "power_on" ) )
    {
        level.maxis_turbine_pickedup_vox = 1;
        level thread maps\mp\zm_transit_sq::maxissay( "vox_maxi_build_complete_0", ( -6848, 5056, 56 ) );
        return true;
    }

    return false;
}

sndsetupmusiceasteregg()
{
    origins = [];
    origins[0] = ( -7562, 4570, -19 );
    origins[1] = ( 7914, -6557, 269 );
    origins[2] = ( 1864, -7, -19 );
    level.meteor_counter = 0;
    level.music_override = 0;

    for ( i = 0; i < origins.size; i++ )
        level thread sndmusicegg( origins[i] );
}

sndmusicegg( bear_origin )
{
    temp_ent = spawn( "script_origin", bear_origin );
    temp_ent playloopsound( "zmb_meteor_loop" );
    temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::waitfor_override );

    temp_ent waittill( "main_music_egg_hit", player );

    temp_ent stoploopsound( 1 );
    player playsound( "zmb_meteor_activate" );
    level.meteor_counter += 1;

    if ( level.meteor_counter == 3 )
        level thread sndplaymusicegg( player, temp_ent );
    else
    {
        wait 1.5;
        temp_ent delete();
    }
}

waitfor_override()
{
    if ( isdefined( level.music_override ) && level.music_override )
        return false;

    return true;
}

sndplaymusicegg( player, ent )
{
    wait 1;
    ent playsound( "mus_zmb_secret_song" );

    level waittill( "end_game" );

    ent stopsounds();
    wait 0.05;
    ent delete();
}

sndtoiletflush()
{
    toilettrig = spawn( "trigger_radius", ( 11182, 7584, -596 ), 0, 150, 5 );
    toilettrig sethintstring( "" );
    toilettrig setcursorhint( "HINT_NOICON" );

    while ( true )
    {
        toilettrig waittill( "trigger", who );

        if ( who is_player() )
        {
            toilettrig playsound( "zmb_toilet_flush" );
            wait 5;
        }

        wait 0.1;
    }
}

transit_special_weapon_magicbox_check( weapon )
{
    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        if ( weapon == "ray_gun_zm" )
        {
            if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) || maps\mp\zombies\_zm_tombstone::is_weapon_available_in_tombstone( "raygun_mark2_zm", self ) )
                return false;
        }

        if ( weapon == "raygun_mark2_zm" )
        {
            if ( self has_weapon_or_upgrade( "ray_gun_zm" ) || maps\mp\zombies\_zm_tombstone::is_weapon_available_in_tombstone( "ray_gun_zm", self ) )
                return false;

            if ( randomint( 100 ) >= 33 )
                return false;
        }
    }

    return true;
}
