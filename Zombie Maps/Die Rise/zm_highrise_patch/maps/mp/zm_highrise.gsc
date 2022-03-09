// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_weapon_locker;
#include maps\mp\zm_highrise_gamemodes;
#include maps\mp\zm_highrise_sq;
#include maps\mp\zombies\_zm_banking;
#include maps\mp\zm_highrise_fx;
#include maps\mp\zm_highrise_ffotd;
#include maps\mp\zm_highrise_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zm_highrise_amb;
#include maps\mp\zm_highrise_elevators;
#include maps\mp\zombies\_load;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zm_highrise_classic;
#include maps\mp\zombies\_zm_ai_leaper;
#include maps\mp\zm_highrise;
#include maps\mp\_sticky_grenade;
#include maps\mp\zombies\_zm_weap_bowie;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_ballistic_knife;
#include maps\mp\zombies\_zm_weap_slipgun;
#include maps\mp\zombies\_zm_weap_tazer_knuckles;
#include maps\mp\zm_highrise_achievement;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_highrise_distance_tracking;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_perks;
#include character\c_highrise_player_farmgirl;
#include character\c_highrise_player_oldman;
#include character\c_highrise_player_engineer;
#include character\c_highrise_player_reporter;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_chugabud;

gamemode_callback_setup()
{
    maps\mp\zm_highrise_gamemodes::init();
}

survival_init()
{
    level.precachecustomcharacters = ::precache_personality_characters;
    level.givecustomcharacters = ::give_personality_characters;
    level.setupcustomcharacterexerts = ::setup_personality_character_exerts;
    level.buildable_build_custom_func = ::buildable_build_custom_func;
    level.use_female_animations = 1;
    vend_trigs = getentarray( "zombie_vending", "targetname" );

    foreach ( ent in vend_trigs )
    {
        if ( isdefined( ent.clip ) )
            ent.clip delete();
    }

    flag_wait( "start_zombie_round_logic" );
}

zclassic_preinit()
{
    setdvar( "player_sliding_velocity_cap", 80.0 );
    setdvar( "player_sliding_wishspeed", 800.0 );
    registerclientfield( "scriptmover", "clientfield_escape_pod_tell_fx", 5000, 1, "int" );
    registerclientfield( "scriptmover", "clientfield_escape_pod_sparks_fx", 5000, 1, "int" );
    registerclientfield( "scriptmover", "clientfield_escape_pod_impact_fx", 5000, 1, "int" );
    registerclientfield( "scriptmover", "clientfield_escape_pod_light_fx", 5000, 1, "int" );
    registerclientfield( "actor", "clientfield_whos_who_clone_glow_shader", 5000, 1, "int" );
    registerclientfield( "toplayer", "clientfield_whos_who_audio", 5000, 1, "int" );
    registerclientfield( "toplayer", "clientfield_whos_who_filter", 5000, 1, "int" );
    level.whos_who_client_setup = 1;
    maps\mp\zm_highrise_sq::sq_highrise_clientfield_init();
    precachemodel( "p6_zm_keycard" );
    precachemodel( "p6_zm_hr_keycard" );
    precachemodel( "fxanim_zom_highrise_trample_gen_mod" );
    level.banking_map = "zm_transit";
    level.weapon_locker_map = "zm_transit";
    level thread maps\mp\zombies\_zm_banking::init();
    survival_init();

    if ( !( isdefined( level.banking_update_enabled ) && level.banking_update_enabled ) )
        return;

    weapon_locker = spawnstruct();
    weapon_locker.origin = ( 2159, 610, 1343 );
    weapon_locker.angles = vectorscale( ( 0, 1, 0 ), 60.0 );
    weapon_locker.targetname = "weapons_locker";
    deposit_spot = spawnstruct();
    deposit_spot.origin = ( 2247, 553, 1326 );
    deposit_spot.angles = vectorscale( ( 0, 1, 0 ), 60.0 );
    deposit_spot.script_length = 16;
    deposit_spot.targetname = "bank_deposit";
    withdraw_spot = spawnstruct();
    withdraw_spot.origin = ( 2280, 611, 1330 );
    withdraw_spot.angles = vectorscale( ( 0, 1, 0 ), 60.0 );
    withdraw_spot.script_length = 16;
    withdraw_spot.targetname = "bank_withdraw";
    level thread maps\mp\zombies\_zm_weapon_locker::main();
    weapon_locker thread maps\mp\zombies\_zm_weapon_locker::triggerweaponslockerwatch();
    level thread maps\mp\zombies\_zm_banking::main();
    deposit_spot thread maps\mp\zombies\_zm_banking::bank_deposit_unitrigger();
    withdraw_spot thread maps\mp\zombies\_zm_banking::bank_withdraw_unitrigger();
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
    maps\mp\zm_highrise_fx::main();
    level thread maps\mp\zm_highrise_ffotd::main_start();
    level thread maps\mp\zm_highrise_utility::main_start();
    level.level_createfx_callback_thread = ::createfx_callback;

    if ( !isdefined( level.vsmgr_prio_visionset_zm_whos_who ) )
        level.vsmgr_prio_visionset_zm_whos_who = 123;

    level.default_game_mode = "zclassic";
    level.default_start_location = "rooftop";
    setup_rex_starts();
    maps\mp\zombies\_zm::init_fx();
    maps\mp\animscripts\zm_death::precache_gib_fx();
    level.zombiemode = 1;
    level._no_water_risers = 1;
    maps\mp\zm_highrise_amb::main();
    level._override_eye_fx = level._effect["blue_eyes"];
    level.level_specific_stats_init = ::init_highrise_stats;
    level.hostmigration_link_entity_callback = maps\mp\zm_highrise_elevators::get_link_entity_for_host_migration;
    level.hostmigration_ai_link_entity_callback = maps\mp\zm_highrise_elevators::get_link_entity_for_host_migration;
    maps\mp\zombies\_load::main();

    if ( getdvar( "createfx" ) != "" )
        return;

    setdvar( "r_lightGridEnableTweaks", 1 );
    setdvar( "r_lightGridIntensity", 1.25 );
    setdvar( "r_lightGridContrast", -0.25 );
    maps\mp\gametypes_zm\_spawning::level_use_unified_spawning( 1 );
    level.givecustomloadout = ::givecustomloadout;
    level.custom_player_fake_death = ::zm_player_fake_death;
    level.custom_player_fake_death_cleanup = ::zm_player_fake_death_cleanup;
    level.initial_round_wait_func = ::initial_round_wait_func;
    level.zombie_init_done = ::zombie_init_done;
    level.check_for_valid_spawn_near_team_callback = ::highrise_respawn_override;
    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 1;
    level.pap_interaction_height = 47;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.zombiemode_using_chugabud_perk = 1;
    level.zombiemode_using_additionalprimaryweapon_perk = 1;
    level._custom_zombie_audio_func = ::custom_zombie_audio_func;
    init_persistent_abilities();
    level._zmbvoxlevelspecific = ::init_level_specific_audio;
    maps\mp\zm_highrise_classic::init_escape_elevators_animtree();
    maps\mp\zm_highrise_elevators::init_perk_elvators_animtree();
    level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;
    level.zombiemode_offhand_weapon_give_override = ::offhand_weapon_give_override;
    level._zombie_custom_add_weapons = ::custom_add_weapons;
    level._allow_melee_weapon_switching = 1;
    level.custom_ai_type = [];
    level.custom_ai_type[level.custom_ai_type.size] = maps\mp\zombies\_zm_ai_leaper::init;
    level.banking_update_enabled = 1;
    level.raygun2_included = 1;
    include_weapons();
    include_powerups();
    include_equipment_for_level();
    init_level_specific_wall_buy_fx();
    level.special_weapon_magicbox_check = ::highrise_special_weapon_magicbox_check;
    level.melee_anim_state = ::melee_anim_state;
    level.pandora_fx_func = ::zm_highrise_pandora_fx_func;
    maps\mp\zm_highrise_elevators::init_elevator_perks();
    level.custom_vending_precaching = maps\mp\zm_highrise::custom_vending_precaching;
    maps\mp\zombies\_zm::init();
    level thread maps\mp\_sticky_grenade::init();
    maps\mp\zombies\_zm_weap_bowie::init();
    level.legacy_cymbal_monkey = 1;
    maps\mp\zombies\_zm_weap_cymbal_monkey::init();
    maps\mp\zombies\_zm_weap_claymore::init();
    maps\mp\zombies\_zm_weap_ballistic_knife::init();
    maps\mp\zombies\_zm_weap_slipgun::init();
    maps\mp\zombies\_zm_weap_tazer_knuckles::init();
    level maps\mp\zm_highrise_achievement::init();
    precacheitem( "death_throe_zm" );

    if ( level.splitscreen && getdvarint( "splitscreen_playerCount" ) > 2 )
        level.optimise_for_splitscreen = 1;
    else
        level.optimise_for_splitscreen = 0;

    precache_team_whos_who_characters();
    maps\mp\zombies\_zm_ai_leaper::precache();
    level thread maps\mp\zm_highrise_sq::start_highrise_sidequest();
    level.zones = [];
    level.zone_manager_init_func = ::highrise_zone_init;
    init_zones[0] = "zone_green_start";
    init_zones[1] = "zone_orange_level3a";
    init_zones[2] = "zone_green_level3d";
    init_zones[3] = "zone_blue_level2a";
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

    level.speed_change_round = 15;
    level.speed_change_max = 5;
    level._audio_custom_response_line = ::highrise_audio_custom_response_line;
    setup_zone_monitor();
    setup_leapers();
    level thread toggle_leaper_traversals();
    level thread toggle_zombie_traversals();
    level thread toggle_leaper_collision();
    level thread electric_switch();
    level.ignore_equipment = ::ignore_equipment;
/#
    execdevgui( "devgui_zombie_highrise" );
    level.custom_devgui = ::zombie_highrise_devgui;
    adddebugcommand( "devgui_cmd \"Zombies:1/Highrise:15/Lighting:3/Power On:1\" \"set zombie_devgui_hrpowerlighting on\" \n" );
    adddebugcommand( "devgui_cmd \"Zombies:1/Highrise:15/Lighting:3/Power Off:2\" \"set zombie_devgui_hrpowerlighting off\" \n" );
    level thread watch_lightpower_devgui();
#/
    level thread maps\mp\zombies\_zm::post_main();
    level thread maps\mp\zm_highrise_ffotd::main_end();
    level thread maps\mp\zm_highrise_utility::main_end();
    level thread maps\mp\zm_highrise_distance_tracking::zombie_tracking_init();
    trigs = getentarray( "force_from_prone", "targetname" );
    array_thread( trigs, ::player_force_from_prone );
    level._dont_unhide_quickervive_on_hotjoin = 1;
}

custom_vending_precaching()
{
    if ( isdefined( level.zombiemode_using_pack_a_punch ) && level.zombiemode_using_pack_a_punch )
    {
        precacheitem( "zombie_knuckle_crack" );
        precachemodel( "p6_anim_zm_buildable_pap" );
        precachemodel( "p6_anim_zm_buildable_pap_on" );
        precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
        precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
        level._effect["packapunch_fx"] = loadfx( "maps/zombie/fx_zmb_highrise_packapunch" );
        level.machine_assets["packapunch"] = spawnstruct();
        level.machine_assets["packapunch"].weapon = "zombie_knuckle_crack";
        level.machine_assets["packapunch"].off_model = "p6_anim_zm_buildable_pap";
        level.machine_assets["packapunch"].on_model = "p6_anim_zm_buildable_pap_on";
    }

    if ( isdefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
    {
        precacheitem( "zombie_perk_bottle_additionalprimaryweapon" );
        precacheshader( "specialty_additionalprimaryweapon_zombies" );
        precachemodel( "zombie_vending_three_gun" );
        precachemodel( "zombie_vending_three_gun_on" );
        precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
        level._effect["additionalprimaryweapon_light"] = loadfx( "misc/fx_zombie_cola_arsenal_on" );
        level.machine_assets["additionalprimaryweapon"] = spawnstruct();
        level.machine_assets["additionalprimaryweapon"].weapon = "zombie_perk_bottle_additionalprimaryweapon";
        level.machine_assets["additionalprimaryweapon"].off_model = "zombie_vending_three_gun";
        level.machine_assets["additionalprimaryweapon"].on_model = "zombie_vending_three_gun_on";
    }

    if ( isdefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
    {
        precacheitem( "zombie_perk_bottle_deadshot" );
        precacheshader( "specialty_ads_zombies" );
        precachemodel( "zombie_vending_ads" );
        precachemodel( "zombie_vending_ads_on" );
        precachestring( &"ZOMBIE_PERK_DEADSHOT" );
        level._effect["deadshot_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
        level.machine_assets["deadshot"] = spawnstruct();
        level.machine_assets["deadshot"].weapon = "zombie_perk_bottle_deadshot";
        level.machine_assets["deadshot"].off_model = "zombie_vending_ads";
        level.machine_assets["deadshot"].on_model = "zombie_vending_ads_on";
    }

    if ( isdefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
    {
        precacheitem( "zombie_perk_bottle_nuke" );
        precacheshader( "specialty_divetonuke_zombies" );
        precachemodel( "zombie_vending_nuke" );
        precachemodel( "zombie_vending_nuke_on" );
        precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
        level._effect["divetonuke_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
        level.machine_assets["divetonuke"] = spawnstruct();
        level.machine_assets["divetonuke"].weapon = "zombie_perk_bottle_nuke";
        level.machine_assets["divetonuke"].off_model = "zombie_vending_nuke";
        level.machine_assets["divetonuke"].on_model = "zombie_vending_nuke_on";
    }

    if ( isdefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
    {
        precacheitem( "zombie_perk_bottle_doubletap" );
        precacheshader( "specialty_doubletap_zombies" );
        precachemodel( "zombie_vending_doubletap2" );
        precachemodel( "zombie_vending_doubletap2_on" );
        precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
        level._effect["doubletap_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
        level.machine_assets["doubletap"] = spawnstruct();
        level.machine_assets["doubletap"].weapon = "zombie_perk_bottle_doubletap";
        level.machine_assets["doubletap"].off_model = "zombie_vending_doubletap2";
        level.machine_assets["doubletap"].on_model = "zombie_vending_doubletap2_on";
    }

    if ( isdefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
    {
        precacheitem( "zombie_perk_bottle_jugg" );
        precacheshader( "specialty_juggernaut_zombies" );
        precachemodel( "zombie_vending_jugg" );
        precachemodel( "zombie_vending_jugg_on" );
        precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
        level._effect["jugger_light"] = loadfx( "misc/fx_zombie_cola_jugg_on" );
        level.machine_assets["juggernog"] = spawnstruct();
        level.machine_assets["juggernog"].weapon = "zombie_perk_bottle_jugg";
        level.machine_assets["juggernog"].off_model = "zombie_vending_jugg";
        level.machine_assets["juggernog"].on_model = "zombie_vending_jugg_on";
    }

    if ( isdefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
    {
        precacheitem( "zombie_perk_bottle_marathon" );
        precacheshader( "specialty_marathon_zombies" );
        precachemodel( "zombie_vending_marathon" );
        precachemodel( "zombie_vending_marathon_on" );
        precachestring( &"ZOMBIE_PERK_MARATHON" );
        level._effect["marathon_light"] = loadfx( "maps/zombie/fx_zmb_cola_staminup_on" );
        level.machine_assets["marathon"] = spawnstruct();
        level.machine_assets["marathon"].weapon = "zombie_perk_bottle_marathon";
        level.machine_assets["marathon"].off_model = "zombie_vending_marathon";
        level.machine_assets["marathon"].on_model = "zombie_vending_marathon_on";
    }

    if ( isdefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
    {
        precacheitem( "zombie_perk_bottle_revive" );
        precacheshader( "specialty_quickrevive_zombies" );
        precachemodel( "zombie_vending_revive" );
        precachemodel( "zombie_vending_revive_on" );
        precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
        level._effect["revive_light"] = loadfx( "misc/fx_zombie_cola_revive_on" );
        level._effect["revive_light_flicker"] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
        level.machine_assets["revive"] = spawnstruct();
        level.machine_assets["revive"].weapon = "zombie_perk_bottle_revive";
        level.machine_assets["revive"].off_model = "zombie_vending_revive";
        level.machine_assets["revive"].on_model = "zombie_vending_revive_on";
    }

    if ( isdefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
    {
        precacheitem( "zombie_perk_bottle_sleight" );
        precacheshader( "specialty_fastreload_zombies" );
        precachemodel( "zombie_vending_sleight" );
        precachemodel( "zombie_vending_sleight_on" );
        precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
        level._effect["sleight_light"] = loadfx( "misc/fx_zombie_cola_on" );
        level.machine_assets["speedcola"] = spawnstruct();
        level.machine_assets["speedcola"].weapon = "zombie_perk_bottle_sleight";
        level.machine_assets["speedcola"].off_model = "zombie_vending_sleight";
        level.machine_assets["speedcola"].on_model = "zombie_vending_sleight_on";
    }

    if ( isdefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
    {
        precacheitem( "zombie_perk_bottle_tombstone" );
        precacheshader( "specialty_tombstone_zombies" );
        precachemodel( "zombie_vending_tombstone" );
        precachemodel( "zombie_vending_tombstone_on" );
        precachemodel( "ch_tombstone1" );
        precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
        level._effect["tombstone_light"] = loadfx( "misc/fx_zombie_cola_on" );
        level.machine_assets["tombstone"] = spawnstruct();
        level.machine_assets["tombstone"].weapon = "zombie_perk_bottle_tombstone";
        level.machine_assets["tombstone"].off_model = "zombie_vending_tombstone";
        level.machine_assets["tombstone"].on_model = "zombie_vending_tombstone_on";
    }

    if ( isdefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
    {
        precacheitem( "zombie_perk_bottle_whoswho" );
        precacheshader( "specialty_quickrevive_zombies" );
        precachemodel( "p6_zm_vending_chugabud" );
        precachemodel( "p6_zm_vending_chugabud_on" );
        precachemodel( "ch_tombstone1" );
        precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
        level._effect["tombstone_light"] = loadfx( "misc/fx_zombie_cola_on" );
        level.machine_assets["whoswho"] = spawnstruct();
        level.machine_assets["whoswho"].weapon = "zombie_perk_bottle_whoswho";
        level.machine_assets["whoswho"].off_model = "p6_zm_vending_chugabud";
        level.machine_assets["whoswho"].on_model = "p6_zm_vending_chugabud_on";
    }
}

choose_a_line_to_play()
{
    if ( !isdefined( level.custom_zombie_sounds ) )
    {
        level.custom_zombie_sounds = array( "vox_zombie_sidequest_zombie_lies_0", "vox_zombie_sidequest_zombie_lies_1", "vox_zombie_sidequest_zombie_lies_2", "vox_zombie_sidequest_zombie_pain_0", "vox_zombie_sidequest_zombie_pain_1", "vox_zombie_sidequest_zombie_pain_2", "vox_zombie_sidequest_zombie_pain_3", "vox_zombie_sidequest_zombie_pain_4", "vox_zombie_sidequest_zombie_pain_5", "vox_zombie_sidequest_zombie_pain_6", "vox_zombie_sidequest_zombie_plea_0", "vox_zombie_sidequest_zombie_plea_1", "vox_zombie_sidequest_zombie_plea_2", "vox_zombie_sidequest_zombie_plea_3", "vox_zombie_sidequest_zombie_plea_4", "vox_zombie_sidequest_zombie_plea_5" );
        level.custom_zombie_sounds = randomize_array( level.custom_zombie_sounds );
        level.last_custom_sound_played = 0;
        level.custom_zombie_sound_play_frequences = array( 5, 10, 20, 30 );
        level.custom_zombie_sound_play_round_numbers = array( 2, 5, 7, 10 );
        level.custom_zombie_sound_played_interval = 6000;
    }
    else if ( level.last_custom_sound_played >= level.custom_zombie_sounds.size )
    {
        level.custom_zombie_sounds = randomize_array( level.custom_zombie_sounds );
        level.last_custom_sound_played = 0;
    }

    sound = level.custom_zombie_sounds[level.last_custom_sound_played];
    level.last_custom_sound_played++;
    return sound;
}

get_custom_zombie_sound_play_frequency()
{
    if ( !isdefined( level.custom_zombie_sounds ) )
        return 100;

    if ( isdefined( level.last_custom_zombie_sound_time ) )
    {
        if ( gettime() < level.last_custom_zombie_sound_time + level.custom_zombie_sound_played_interval )
            return 0;
    }

    if ( level.round_number >= level.custom_zombie_sound_play_round_numbers[level.custom_zombie_sound_play_round_numbers.size - 1] )
        return 40;

    for ( i = 0; i < level.custom_zombie_sound_play_round_numbers.size; i++ )
    {
        if ( level.round_number < level.custom_zombie_sound_play_round_numbers[i] )
            return level.custom_zombie_sound_play_frequences[i];
    }

    return 0;
}

custom_zombie_audio_func( alias, alias_type )
{
    if ( alias_type != "behind" )
    {
        if ( isdefined( level.isstuhlingeringame ) && level.isstuhlingeringame )
        {
            if ( randomint( 100 ) > 100 - get_custom_zombie_sound_play_frequency() )
            {
                players = get_players();

                foreach ( player in players )
                {
                    if ( isdefined( player.characterindex ) && player.characterindex == 1 )
                    {
                        level.last_custom_zombie_sound_time = gettime();
                        alias_to_play = choose_a_line_to_play();
                        self playsoundtoplayer( alias_to_play, player );
                        continue;
                    }

                    self playsoundtoplayer( alias, player );
                }

                return;
            }
        }
    }

    self playsound( alias );
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
        level.pers_treasure_chest_get_weapons_array_func = ::pers_treasure_chest_get_weapons_array_highrise;
        level.pers_upgrade_sniper = 1;
        level.pers_upgrade_pistol_points = 1;
        level.pers_upgrade_perk_lose = 1;
        level.pers_upgrade_double_points = 1;
        level.pers_upgrade_nube = 1;
    }
}

pers_treasure_chest_get_weapons_array_highrise()
{
    if ( !isdefined( level.pers_box_weapons ) )
    {
        level.pers_box_weapons = [];
        level.pers_box_weapons[level.pers_box_weapons.size] = "knife_ballistic_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "cymbal_monkey_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "judge_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "galil_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "hamr_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "python_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "ray_gun_zm";
        level.pers_box_weapons[level.pers_box_weapons.size] = "rpd_zm";
    }
}

watch_lightpower_devgui()
{
/#
    while ( true )
    {
        powercmd = getdvar( _hash_A84512A );

        if ( isdefined( powercmd ) && powercmd != "" )
        {
            if ( powercmd == "on" )
                clientnotify( "pwr" );
            else
                clientnotify( "pwo" );

            setdvar( "zombie_devgui_hrpowerlighting", "" );
        }

        wait 1.0;
    }
#/
}

setup_leapers()
{
    b_disable_leapers = isdefined( getdvarint( _hash_60AEA36D ) ) && getdvarint( _hash_60AEA36D );

    if ( b_disable_leapers )
        flag_init( "leaper_round" );
    else
        maps\mp\zombies\_zm_ai_leaper::enable_leaper_rounds();

    level.leapers_per_player = 6;
}

setup_zone_monitor()
{
    level.player_out_of_playable_area_monitor = 1;
    str_dvar_zone_monitor = getdvarint( _hash_E9322600 );

    if ( isdefined( str_dvar_zone_monitor ) && str_dvar_zone_monitor )
        level.player_out_of_playable_area_monitor = 0;

    str_dvar_zone_test = getdvarint( _hash_2313B5C5 );

    if ( isdefined( str_dvar_zone_test ) && str_dvar_zone_test )
    {
        level.kill_thread_test_mode = 1;
        level.check_kill_thread_every_frame = 1;
    }

    level.player_out_of_playable_area_monitor_callback = ::zm_highrise_zone_monitor_callback;
}

zm_highrise_zone_monitor_callback()
{
    b_kill_player = 1;

    if ( !self isonground() )
        b_kill_player = 0;

    if ( getnumconnectedplayers() == 1 )
    {
        if ( isdefined( self.lives ) && self.lives > 0 )
        {
            if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                b_kill_player = 0;
        }
    }

    if ( b_kill_player )
        self thread maps\mp\zm_highrise_classic::insta_kill_player( 0, 0 );

    return b_kill_player;
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

    if ( isdefined( self.is_armed ) && self.is_armed )
        return true;

    return false;
}

highrise_respawn_override( revivee, return_struct )
{
    players = get_players();
    spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

    if ( spawn_points.size == 0 )
        return undefined;

    for ( i = 0; i < players.size; i++ )
    {
        if ( is_player_valid( players[i], undefined, 1 ) && players[i] != self )
        {
            for ( j = 0; j < spawn_points.size; j++ )
            {
                if ( isdefined( spawn_points[j].script_noteworthy ) )
                {
                    zone = level.zones[spawn_points[j].script_noteworthy];

                    for ( k = 0; k < zone.volumes.size; k++ )
                    {
                        if ( players[i] istouching( zone.volumes[k] ) )
                        {
                            closest_group = j;
                            spawn_location = get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct );

                            if ( isdefined( spawn_location ) )
                                return spawn_location;
                        }
                    }
                }
            }
        }
    }
}

givecustomloadout( takeallweapons, alreadyspawned )
{
    self giveweapon( "knife_zm" );
    self give_start_weapon( 1 );
}

precache_team_whos_who_characters()
{
    precachemodel( "c_zom_player_engineer_dlc1_fb" );
    precachemodel( "c_zom_player_farmgirl_dlc1_fb" );
    precachemodel( "c_zom_player_oldman_dlc1_fb" );
    precachemodel( "c_zom_player_reporter_dlc1_fb" );
}

initcharacterstartindex()
{
    level.characterstartindex = randomint( 4 );
}

zm_player_fake_death_cleanup()
{
    if ( isdefined( self._fall_down_anchor ) )
    {
        self._fall_down_anchor delete();
        self._fall_down_anchor = undefined;
    }
}

zm_player_fake_death( vdir, smeansofdeath )
{
    level notify( "fake_death" );
    self notify( "fake_death" );
    stance = self getstance();
    self.ignoreme = 1;
    self enableinvulnerability();
    self takeallweapons();

    if ( isdefined( self.insta_killed ) && self.insta_killed || self maps\mp\zm_highrise_elevators::is_self_on_elevator() || isdefined( smeansofdeath ) && smeansofdeath == "MOD_FALLING" )
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

    self giveweapon( "death_throe_zm" );
    self switchtoweapon( "death_throe_zm" );

    if ( falling )
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

initial_round_wait_func()
{
    flag_wait( "initial_blackscreen_passed" );
}

offhand_weapon_overrride()
{
    register_lethal_grenade_for_level( "frag_grenade_zm" );
    level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
    register_lethal_grenade_for_level( "sticky_grenade_zm" );
    register_tactical_grenade_for_level( "cymbal_monkey_zm" );
    register_tactical_grenade_for_level( "emp_grenade_zm" );
    register_placeable_mine_for_level( "claymore_zm" );
    register_melee_weapon_for_level( "knife_zm" );
    register_melee_weapon_for_level( "bowie_knife_zm" );
    register_melee_weapon_for_level( "tazer_knuckles_zm" );
    level.zombie_melee_weapon_player_init = "knife_zm";
    register_equipment_for_level( "equip_springpad_zm" );
    level.zombie_equipment_player_init = undefined;

    if ( isdefined( level.slipgun_as_equipment ) && level.slipgun_as_equipment )
        register_equipment_for_level( "slipgun_zm" );
}

offhand_weapon_give_override( str_weapon )
{
    self endon( "death" );

    if ( is_tactical_grenade( str_weapon ) && isdefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( str_weapon ) )
    {
        self setweaponammoclip( self get_player_tactical_grenade(), 0 );
        self takeweapon( self get_player_tactical_grenade() );
    }

    return 0;
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
    add_zombie_weapon( "pdw57_zm", "pdw57_upgraded_zm", &"ZOMBIE_WEAPON_PDW57", 1000, "smg", "", undefined );
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
    add_zombie_weapon( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "wpck_m82a1", "", undefined, 1 );
    add_zombie_weapon( "svu_zm", "svu_upgraded_zm", &"ZOMBIE_WEAPON_SVU", 1000, "wpck_svuas", "", undefined );
    add_zombie_weapon( "rpd_zm", "rpd_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_rpd", "", undefined, 1 );
    add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_hamr", "", undefined, 1 );
    add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
    add_zombie_weapon( "sticky_grenade_zm", undefined, &"ZOMBIE_WEAPON_STICKY_GRENADE", 250, "grenade", "", 250 );
    add_zombie_weapon( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1000, "grenade", "", undefined );
    add_zombie_weapon( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
    add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_m32", "", undefined, 1 );
    add_zombie_weapon( "an94_zm", "an94_upgraded_zm", &"ZOMBIE_WEAPON_AN94", 1200, "", "", undefined );
    add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
    add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_zm", "knife_ballistic_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_bowie_zm", "knife_ballistic_bowie_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined );
    add_zombie_weapon( "tazer_knuckles_zm", undefined, &"ZOMBIE_WEAPON_TAZER_KNUCKLES", 100, "tazerknuckles", "", undefined );
    add_zombie_weapon( "slipgun_zm", undefined, &"ZOMBIE_WEAPON_SLIPGUN", 10, "slip", "", undefined );

    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
        add_zombie_weapon( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "raygun_mark2", "", undefined );
}

include_weapons()
{
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
    include_weapon( "svu_zm", 0 );
    include_weapon( "svu_upgraded_zm", 0 );
    include_weapon( "rpd_zm" );
    include_weapon( "rpd_upgraded_zm", 0 );
    include_weapon( "hamr_zm" );
    include_weapon( "hamr_upgraded_zm", 0 );
    include_weapon( "pdw57_zm", 0 );
    include_weapon( "pdw57_upgraded_zm", 0 );
    include_weapon( "usrpg_zm" );
    include_weapon( "usrpg_upgraded_zm", 0 );
    include_weapon( "m32_zm" );
    include_weapon( "m32_upgraded_zm", 0 );
    include_weapon( "an94_zm", 0 );
    include_weapon( "cymbal_monkey_zm" );
    include_weapon( "ray_gun_zm" );
    include_weapon( "ray_gun_upgraded_zm", 0 );
    include_weapon( "slipgun_zm", 0 );
    include_weapon( "slipgun_upgraded_zm", 0 );
    include_weapon( "tazer_knuckles_zm", 0 );
    include_weapon( "knife_ballistic_no_melee_zm", 0 );
    include_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
    include_weapon( "knife_ballistic_zm" );
    include_weapon( "knife_ballistic_upgraded_zm", 0 );
    include_weapon( "knife_ballistic_bowie_zm", 0 );
    include_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );
    level._uses_retrievable_ballisitic_knives = 1;
    add_limited_weapon( "m1911_zm", 0 );
    add_limited_weapon( "knife_ballistic_zm", 1 );
    add_limited_weapon( "slipgun_zm", 1 );
    add_limited_weapon( "slipgun_upgraded_zm", 1 );
    add_limited_weapon( "ray_gun_zm", 4 );
    add_limited_weapon( "ray_gun_upgraded_zm", 4 );
    add_limited_weapon( "knife_ballistic_upgraded_zm", 0 );
    add_limited_weapon( "knife_ballistic_no_melee_zm", 0 );
    add_limited_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
    add_limited_weapon( "knife_ballistic_bowie_zm", 0 );
    add_limited_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );
    add_weapon_locker_mapping( "lsat_zm", "hamr_zm" );
    add_weapon_locker_mapping( "lsat_upgraded_zm", "hamr_upgraded_zm" );
    add_weapon_locker_mapping( "rnma_zm", "python_zm" );
    add_weapon_locker_mapping( "rnma_upgraded_zm", "python_upgraded_zm" );

    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        include_weapon( "raygun_mark2_zm" );
        include_weapon( "raygun_mark2_upgraded_zm", 0 );
        add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
        add_limited_weapon( "raygun_mark2_zm", 1 );
        add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
    }
}

include_powerups()
{
    include_powerup( "nuke" );
    include_powerup( "insta_kill" );
    include_powerup( "double_points" );
    include_powerup( "full_ammo" );
    include_powerup( "carpenter" );
    include_powerup( "insta_kill_ug" );
    include_powerup( "free_perk" );
}

include_equipment_for_level()
{
    level.springpad_trigger_radius = 96;
    include_equipment( "equip_springpad_zm" );

    if ( isdefined( level.slipgun_as_equipment ) && level.slipgun_as_equipment )
        include_equipment( "slipgun_zm" );

    level.equipment_planted = ::equipment_planted;
    level.equipment_safe_to_drop = ::equipment_safe_to_drop;
    level.check_force_deploy_z = ::use_safe_spawn_on_elevator;
    level.safe_place_for_buildable_piece = ::safe_place_for_buildable_piece;
}

setup_rex_starts()
{
    add_gametype( "zclassic", ::dummy, "zclassic", ::dummy );
    add_gameloc( "rooftop", ::dummy, "rooftop", ::dummy );
}

dummy()
{

}

zombie_highrise_devgui( cmd )
{
/#
    cmd_strings = strtok( cmd, " " );

    switch ( cmd_strings[0] )
    {
        case "leaper_round_skip":
            if ( isdefined( level.next_leaper_round ) )
                maps\mp\zombies\_zm_devgui::zombie_devgui_goto_round( level.next_leaper_round );

            break;
        case "pick_up_keys":
            thread pick_up_keys();
            break;
        default:
            break;
    }
#/
}

pick_up_keys()
{
/#
    players = get_players();

    foreach ( player in players )
    {
        if ( isdefined( player player_get_buildable_piece() ) && player player_get_buildable_piece().buildablename == "keys_zm" )
            continue;

        candidate_list = [];

        foreach ( zone in level.zones )
        {
            if ( isdefined( zone.unitrigger_stubs ) )
                candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
        }

        foreach ( stub in candidate_list )
        {
            if ( isdefined( stub.piece ) && stub.piece.buildablename == "keys_zm" )
            {
                player thread maps\mp\zombies\_zm_buildables::player_take_piece( stub.piece );
                break;
            }
        }
    }
#/
}

highrise_zone_init()
{
    flag_init( "always_on" );
    flag_set( "always_on" );
    add_adjacent_zone( "zone_green_start", "zone_green_level1", "green_start_door" );
    add_adjacent_zone( "zone_green_start", "zone_green_escape_pod", "always_on" );
    add_adjacent_zone( "zone_green_escape_pod", "zone_green_escape_pod_ground", "always_on", 1 );
    add_adjacent_zone( "zone_blue_level4a", "zone_green_escape_pod_ground", "always_on", 1 );
    add_adjacent_zone( "zone_blue_level5", "zone_green_escape_pod_ground", "always_on", 1 );
    add_adjacent_zone( "zone_green_level1", "zone_green_level2a", "always_on" );
    add_adjacent_zone( "zone_green_level1", "zone_green_level2b", "always_on" );
    add_adjacent_zone( "zone_green_level2a", "zone_green_level2b", "green_level2_door2" );
    add_adjacent_zone( "zone_green_level2a", "zone_green_level3b", "always_on" );
    add_adjacent_zone( "zone_green_level2b", "zone_green_level3a", "always_on" );
    add_adjacent_zone( "zone_green_level3a", "zone_green_level3d", "always_on" );
    add_adjacent_zone( "zone_orange_level1", "zone_green_level3d", "always_on", 1 );
    add_adjacent_zone( "zone_green_level3b", "zone_green_level3c", "green_level3_door2" );
    add_adjacent_zone( "zone_orange_level1", "zone_orange_level2", "always_on" );
    add_adjacent_zone( "zone_orange_elevator_shaft_bottom", "zone_orange_level3a", "always_on" );
    add_adjacent_zone( "zone_orange_level3a", "zone_orange_level3b", "zone_orange_level3a_to_level3b" );
    add_adjacent_zone( "zone_blue_level5", "zone_blue_level4b", "blocker_blue_level_4_to_5" );
    add_adjacent_zone( "zone_blue_level4a", "zone_blue_level4b", "blue_level4_door2" );
    add_adjacent_zone( "zone_blue_level4a", "zone_blue_level4c", "blue_level4_door1" );
    add_adjacent_zone( "zone_blue_level2a", "zone_blue_level2b", "blue_level2_door1" );
    add_adjacent_zone( "zone_blue_level2b", "zone_blue_level1a", "blue_level2_door2" );
    add_adjacent_zone( "zone_blue_level1a", "zone_blue_level1b", "always_on" );
    add_adjacent_zone( "zone_blue_level1a", "zone_blue_level1c", "always_on" );
    add_adjacent_zone( "zone_blue_level2a", "zone_blue_level2c", "blocker_blue_level2a_to_level2c" );
    add_adjacent_zone( "zone_blue_level1b", "zone_blue_level2d", "always_on" );
    add_adjacent_zone( "zone_blue_level2d", "zone_blue_level2c", "blocker_blue_level1b_to_level2c" );
    add_adjacent_zone( "zone_green_level3b", "zone_blue_level1c", "always_on", 1 );
    level thread enable_zone_on_flag( "zone_blue_level4b", "power_on" );
    init_elevator_shaft_zones();
}

init_elevator_shaft_zones()
{
    a_zones = array( "zone_orange_elevator_shaft_middle_1", "zone_orange_elevator_shaft_middle_2", "zone_green_level1", "zone_green_level2a", "zone_green_level2b", "zone_green_level3a", "zone_green_level3b", "zone_green_level3c", "zone_blue_level1a", "zone_blue_level1b", "zone_blue_level2b", "zone_blue_level2c", "zone_blue_level4b", "zone_blue_level4c", "zone_blue_level5", "zone_orange_elevator_shaft_top", "zone_blue_level2a", "zone_orange_level3b" );

    foreach ( zone in a_zones )
    {
        zone_init( zone );
        enable_zone( zone );
    }
}

enable_zone_on_flag( str_zone_name, str_flag_name )
{
/#
    assert( flag_exists( str_flag_name ), "Tried to enable zone on flag, but flag " + str_flag_name + " hasn't been initialized" );
#/
/#
    assert( isdefined( level.zones[str_zone_name] ), "There is no zone with name '" + str_zone_name + " in the map!" );
#/
    flag_wait( str_flag_name );
    enable_zone( str_zone_name );
}

electric_switch()
{
    trig = getent( "use_elec_switch", "targetname" );
    master_switch = getent( "elec_switch", "targetname" );
    master_switch notsolid();
    trig sethintstring( &"ZOMBIE_ELECTRIC_SWITCH" );
    trig setvisibletoall();

    trig waittill( "trigger", user );

    trig setinvisibletoall();
    master_switch rotateroll( -90, 0.3 );
    master_switch playsound( "zmb_switch_flip" );
    master_switch playsound( "evt_poweron_front" );

    if ( isdefined( user ) )
        user thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "power", "power_on" );

    level thread maps\mp\zombies\_zm_perks::perk_unpause_all_perks();

    master_switch waittill( "rotatedone" );

    fx_spot = spawnstruct();
    fx_spot.origin = ( 2886, -132, 1296 );
    fx_spot.angles = vectorscale( ( 0, 1, 0 ), 240.0 );
    playfx( level._effect["switch_sparks"], fx_spot.origin, anglestoforward( fx_spot.angles ) );
    master_switch playsound( "zmb_turn_on" );
    level notify( "electric_door" );
    clientnotify( "power_on" );
    flag_set( "power_on" );
    stop_exploder( 10 );
    exploder( 11 );
}

precache_personality_characters()
{
    character\c_highrise_player_farmgirl::precache();
    character\c_highrise_player_oldman::precache();
    character\c_highrise_player_engineer::precache();
    character\c_highrise_player_reporter::precache();
    precachemodel( "c_zom_farmgirl_viewhands" );
    precachemodel( "c_zom_oldman_viewhands" );
    precachemodel( "c_zom_engineer_viewhands" );
    precachemodel( "c_zom_reporter_viewhands" );
}

give_personality_characters()
{
    if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_farmgirl_viewhands" ) )
        return;

    self detachall();

    if ( !isdefined( self.characterindex ) )
    {
        self.characterindex = assign_lowest_unused_character_index();

        if ( self.characterindex == 1 && !isdefined( level.isstuhlingeringame ) )
            level.isstuhlingeringame = 1;
    }

    self.favorite_wall_weapons_list = [];
    self.talks_in_danger = 0;
/#
    if ( getdvar( _hash_40772CF1 ) != "" )
        self.characterindex = getdvarint( _hash_40772CF1 );
#/
    switch ( self.characterindex )
    {
        case "2":
            self character\c_highrise_player_farmgirl::main();
            self setviewmodel( "c_zom_farmgirl_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
            self set_player_is_female( 1 );
            self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
            break;
        case "0":
            self character\c_highrise_player_oldman::main();
            self setviewmodel( "c_zom_oldman_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
            self set_player_is_female( 0 );
            self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
            break;
        case "3":
            self character\c_highrise_player_engineer::main();
            self setviewmodel( "c_zom_engineer_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
            self set_player_is_female( 0 );
            self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
            break;
        case "1":
            self character\c_highrise_player_reporter::main();
            self setviewmodel( "c_zom_reporter_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self.talks_in_danger = 1;
            level.rich_sq_player = self;
            self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
            self set_player_is_female( 0 );
            self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
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
    self maps\mp\zombies\_zm_audio::setexertvoice( self.characterindex + 1 );
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
                    continue;
                }

                if ( player.characterindex == 3 || player.characterindex == 1 )
                {
                    if ( randomint( 100 ) > 50 )
                        return 0;

                    return 2;
                }
            }
        }

        charindexarray = array_randomize( charindexarray );
        return charindexarray[0];
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

zombie_init_done()
{
    self.allowpain = 0;
    self.zombie_path_bad = 0;
    self thread maps\mp\zm_highrise_distance_tracking::escaped_zombies_cleanup_init();
    self thread elevator_traverse_watcher();

    if ( self.classname == "actor_zm_highrise_basic_03" )
    {
        health_bonus = int( self.maxhealth * 0.05 );
        self.maxhealth += health_bonus;

        if ( self.headmodel == "c_zom_zombie_chinese_head3_helmet" )
            self.maxhealth += health_bonus;

        self.health = self.maxhealth;
    }

    self setphysparams( 15, 0, 48 );
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

melee_anim_state()
{
    if ( flag( "leaper_round" ) )
    {
        mas = "zm_run_melee";
        melee_dist = distancesquared( self.origin, self.enemy.origin );
        kick_dist = 1024;

        if ( melee_dist < kick_dist )
            mas = "zm_jump_melee";

        self.melee_attack = 1;
        return mas;
    }

    return undefined;
}

toggle_leaper_collision()
{
    level endon( "end_game" );
    a_leaper_collision = getentarray( "leaper_clip", "targetname" );

    while ( true )
    {
        flag_waitopen( "leaper_round" );

        foreach ( clip_brush in a_leaper_collision )
        {
            clip_brush notsolid();
            clip_brush connectpaths();
        }

        flag_wait( "leaper_round" );

        foreach ( clip_brush in a_leaper_collision )
        {
            clip_brush solid();
            clip_brush connectpaths();
        }
    }
}

toggle_leaper_traversals()
{
    level endon( "end_game" );
    a_leaper_traversals = getentarray( "leaper_traversal_clip", "targetname" );

    while ( true )
    {
        flag_waitopen( "leaper_round" );

        foreach ( clip_brush in a_leaper_traversals )
        {
            clip_brush solid();
            clip_brush disconnectpaths();
            clip_brush notsolid();
        }

        flag_wait( "leaper_round" );

        foreach ( clip_brush in a_leaper_traversals )
        {
            clip_brush notsolid();
            clip_brush connectpaths();
        }
    }
}

toggle_zombie_traversals()
{
    level endon( "end_game" );
    a_zombie_only_traversals = getentarray( "zombie_traversal_clip", "targetname" );

    while ( true )
    {
        flag_waitopen( "leaper_round" );

        foreach ( clip_brush in a_zombie_only_traversals )
        {
            clip_brush notsolid();
            clip_brush connectpaths();
        }

        flag_wait( "leaper_round" );

        foreach ( clip_brush in a_zombie_only_traversals )
        {
            clip_brush solid();
            clip_brush disconnectpaths();
            clip_brush notsolid();
        }
    }
}

is_touching_instakill()
{
    foreach ( trigger in level.insta_kill_triggers )
    {
        if ( self istouching( trigger ) )
            return true;
    }

    return false;
}

player_force_from_prone()
{
    level endon( "intermission" );
    level endon( "end_game" );

    while ( true )
    {
        self waittill( "trigger", who );

        if ( who getstance() == "prone" && isplayer( who ) )
            who setstance( "crouch" );

        wait 0.1;
    }
}

equipment_safe_to_drop( weapon )
{
    if ( isdefined( self.origin ) && abs( self.origin[2] - weapon.origin[2] ) > 120 )
        return false;

    if ( !isdefined( weapon.canmove ) )
        weapon.canmove = weapon maps\mp\zm_highrise_elevators::object_is_on_elevator();

    if ( isdefined( weapon.canmove ) && weapon.canmove )
        return true;

    if ( weapon is_touching_instakill() )
        return false;

    return true;
}

use_safe_spawn_on_elevator( weapon, origin, angles )
{
    if ( !isdefined( weapon.canmove ) )
        weapon.canmove = weapon maps\mp\zm_highrise_elevators::object_is_on_elevator();

    if ( isdefined( weapon.canmove ) && weapon.canmove && ( isdefined( weapon.elevator_parent.is_moving ) && weapon.elevator_parent.is_moving ) )
        return true;

    return false;
}

equipment_planted( weapon, equipname, groundfrom )
{
    weaponelevator = groundfrom maps\mp\zm_highrise_elevators::object_is_on_elevator();

    if ( !weaponelevator && weapon is_touching_instakill() )
    {
        self maps\mp\zombies\_zm_equipment::equipment_take( equipname );
        wait 0.05;
        self notify( equipname + "_taken" );
        return;
    }

    if ( weaponelevator && isdefined( weapon.canmove ) && !weapon.canmove )
    {
        weapon.canmove = 1;
        maps\mp\zombies\_zm_unitrigger::reregister_unitrigger_as_dynamic( weapon.stub );
    }

    if ( isdefined( self ) && weaponelevator )
    {
        if ( isdefined( weapon ) )
        {
            parent = groundfrom.elevator_parent;
            weapon linkto( parent );
            weapon setmovingplatformenabled( 1 );

            if ( isdefined( weapon.stub ) )
            {
                weapon.stub.link_parent = parent;
                weapon.stub.origin_parent = weapon;
            }

            weapon.equipment_can_move = 1;
            weapon.isonbus = 1;
            weapon.move_parent = parent;
        }
    }
}

safe_place_for_buildable_piece( piece )
{
    if ( self is_jumping() )
        return false;

    return true;
}

zm_highrise_pandora_fx_func()
{
    self endon( "death" );
    self.pandora_light = spawn( "script_model", self.zbarrier.origin );
    self.pandora_light.angles = self.zbarrier.angles + vectorscale( ( -1, 0, -1 ), 90.0 );
    self.pandora_light setmodel( "tag_origin" );

    if ( !( isdefined( level._box_initialized ) && level._box_initialized ) )
    {
        flag_wait( "start_zombie_round_logic" );
        level._box_initialized = 1;
    }

    wait 1;

    if ( isdefined( self ) && isdefined( self.pandora_light ) )
    {
        n_pandora_fx = level._effect["lght_marker"];

        if ( is_magic_box_in_inverted_building() )
            n_pandora_fx = level._effect["pandora_box_inverted"];

        playfxontag( n_pandora_fx, self.pandora_light, "tag_origin" );
    }
}

is_magic_box_in_inverted_building()
{
    b_is_in_inverted_building = 0;
    a_boxes_in_inverted_building = array( "start_chest" );
    str_location = level.chests[level.chest_index].script_noteworthy;
/#
    assert( isdefined( str_location ), "is_magic_box_in_inverted_building() can't find magic box location" );
#/
    for ( i = 0; i < a_boxes_in_inverted_building.size; i++ )
    {
        if ( a_boxes_in_inverted_building[i] == str_location )
            b_is_in_inverted_building = 1;
    }

    return b_is_in_inverted_building;
}

init_highrise_stats()
{
    self maps\mp\zm_highrise_sq::init_player_sidequest_stats();
    self maps\mp\zm_highrise_achievement::init_player_achievement_stats();
}

init_level_specific_wall_buy_fx()
{
    level._effect["an94_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_an94" );
    level._effect["pdw57_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_pdw57" );
    level._effect["svu_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_svuas" );
}

init_level_specific_audio()
{
    init_highrise_player_dialogue();
    add_highrise_response_chance();
    level thread survivor_vox();
}

add_highrise_response_chance()
{
    add_vox_response_chance( "crawl_spawn", 10 );
    add_vox_response_chance( "reboard", 5 );
    add_vox_response_chance( "slipgun_kill", 10 );
    add_vox_response_chance( "leaper_round", 100 );
    add_vox_response_chance( "achievement", 100 );
    add_vox_response_chance( "power_on", 100 );
    add_vox_response_chance( "power_off", 100 );
    add_vox_response_chance( "upgrade", 100 );
    add_vox_response_chance( "build_pck_bspringpad_zm", 45 );
    add_vox_response_chance( "build_pck_bslipgun_zm", 45 );
    add_vox_response_chance( "build_pck_wspringpad_zm", 45 );
    add_vox_response_chance( "build_pck_wslipgun", 45 );
    add_vox_response_chance( "build_plc_springpad_zm", 45 );
    add_vox_response_chance( "build_plc_slipgun_zm", 45 );
    add_vox_response_chance( "build_pickup", 45 );
    add_vox_response_chance( "build_swap", 45 );
    add_vox_response_chance( "build_add", 45 );
    add_vox_response_chance( "build_final", 45 );
}

init_highrise_player_dialogue()
{
    level.vox zmbvoxadd( "player", "general", "revive_down", "bus_down", undefined );
    level.vox zmbvoxadd( "player", "general", "revive_up", "heal_revived", undefined );
    level.vox zmbvoxadd( "player", "general", "achievement", "earn_acheivement", undefined );
    level.vox zmbvoxadd( "player", "general", "no_money_weapon", "nomoney_weapon", undefined );
    level.vox zmbvoxadd( "player", "general", "no_money_box", "nomoney_box", undefined );
    level.vox zmbvoxadd( "player", "general", "exert_sigh", "exert_sigh", undefined );
    level.vox zmbvoxadd( "player", "general", "exert_laugh", "exert_laugh", undefined );
    level.vox zmbvoxadd( "player", "general", "pain_high", "pain_high", undefined );
    level.vox zmbvoxadd( "player", "kill", "slipgun_kill", "kill_sliquifier", undefined );
    level.vox zmbvoxadd( "player", "general", "leaper_round", "leaper_reveal", undefined );
    level.vox zmbvoxadd( "player", "general", "leaper_seen", "leaper_see", undefined );
    level.vox zmbvoxadd( "player", "general", "leaper_killed", "leaper_kill", undefined );
    level.vox zmbvoxadd( "player", "general", "leaper_attack", "leaper_attack", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_bspringpad_zm", "build_pck_bsteam", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_bslipgun_zm", "build_pck_bsliquifier", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wspringpad_zm", "build_pck_wsteam", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pck_wslipgun_zm", "build_pck_wsliquifier", undefined );
    level.vox zmbvoxadd( "player", "general", "build_plc_springpad_zm", "build_plc_steam", undefined );
    level.vox zmbvoxadd( "player", "general", "build_plc_slipgun_zm", "build_plc_sliquifier", undefined );
    level.vox zmbvoxadd( "player", "general", "build_pickup", "build_pickup", undefined );
    level.vox zmbvoxadd( "player", "general", "build_swap", "build_swap", undefined );
    level.vox zmbvoxadd( "player", "general", "build_add", "build_add", undefined );
    level.vox zmbvoxadd( "player", "general", "build_final", "build_final", undefined );
    level.vox zmbvoxadd( "player", "general", "intro", "power_off", undefined );
    level.vox zmbvoxadd( "player", "power", "power_on", "power_on", undefined );
    level.vox zmbvoxadd( "player", "general", "reboard", "rebuild_boards", undefined );
    level.vox zmbvoxadd( "player", "general", "upgrade", "find_secret", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_wait", "pap_wait", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_wait2", "pap_wait2", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_arm", "pap_arm", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_arm2", "pap_arm2", undefined );
    level.vox zmbvoxadd( "player", "general", "pap_hint", "pap_hint", undefined );
}

highrise_audio_custom_response_line( player, index, category, type )
{
    russman = 0;
    samuel = 1;
    misty = 2;
    marlton = 3;

    switch ( player.characterindex )
    {
        case "0":
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, samuel, marlton, category, type );
            break;
        case "1":
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, russman, misty, category, type );
            break;
        case "2":
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, marlton, samuel, category, type );
            break;
        case "3":
            level maps\mp\zombies\_zm_audio::setup_hero_rival( player, misty, russman, category, type );
            break;
    }
}

survivor_vox()
{
    trigger = spawn( "trigger_radius_use", ( 2398.5, -366, 1332.5 ), 0, 40, 72 );
    trigger setcursorhint( "HINT_NOICON" );
    trigger sethintstring( "" );
    trigger triggerignoreteam();

    level waittill( "power_on" );

    initiated = 0;

    while ( !initiated )
    {
        trigger waittill( "trigger", player );

        playsoundatposition( "zmb_zombie_arc", trigger.origin );
        start_time = gettime();
        end_time = start_time + 5000;

        while ( player usebuttonpressed() && player istouching( trigger ) && is_player_valid( player ) )
        {
            if ( gettime() > end_time )
                initiated = 1;

            wait 0.05;
        }
    }

    sur_num = 1;
    index = 0;
    count = 0;
    playsoundatposition( "zmb_buildable_piece_add", trigger.origin );

    while ( true )
    {
        trigger waittill( "trigger", player );

        if ( is_player_valid( player ) )
        {
            if ( sur_num == 1 )
                count = 7;
            else if ( sur_num == 2 )
                count = 5;
            else if ( sur_num == 3 )
                count = 6;
            else if ( sur_num == 4 )
                count = 4;
            else if ( sur_num == 5 )
                count = 1;

            for ( index = 0; index < count; index++ )
            {
                trigger playsoundwithnotify( "vox_sur" + sur_num + "_tv_distress_" + index, "vox_sur" + sur_num + "_tv_distress_" + index + "done" );

                trigger waittill( "vox_sur" + sur_num + "_tv_distress_" + index + "done" );

                trigger waittill( "trigger", player );
            }
        }

        sur_num++;

        if ( sur_num > 5 )
            sur_num = 1;

        wait 5;
    }
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

elevator_traverse_watcher()
{
    self endon( "death" );

    while ( true )
    {
        if ( is_true( self.is_traversing ) )
        {
            self.elevator_parent = undefined;

            if ( is_true( self maps\mp\zm_highrise_elevators::object_is_on_elevator() ) )
            {
                if ( isdefined( self.elevator_parent ) )
                {
                    if ( is_true( self.elevator_parent.is_moving ) )
                    {
                        playfx( level._effect["zomb_gib"], self.origin );

                        if ( !is_true( self.has_been_damaged_by_player ) )
                            level.zombie_total++;

                        self delete();
                        return;
                    }
                }
            }
        }

        wait 0.2;
    }
}

highrise_special_weapon_magicbox_check( weapon )
{
    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        if ( weapon == "ray_gun_zm" )
        {
            if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) || maps\mp\zombies\_zm_chugabud::is_weapon_available_in_chugabud_corpse( "raygun_mark2_zm", self ) )
                return false;
        }

        if ( weapon == "raygun_mark2_zm" )
        {
            if ( self has_weapon_or_upgrade( "ray_gun_zm" ) || maps\mp\zombies\_zm_chugabud::is_weapon_available_in_chugabud_corpse( "ray_gun_zm", self ) )
                return false;

            if ( randomint( 100 ) >= 33 )
                return false;
        }
    }

    return true;
}
