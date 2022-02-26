// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_ffotd;
#include maps\mp\zombies\_zm;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\zombies\_zm_bot;
#include maps\mp\zombies\_zm_clone;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_playerhealth;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_gump;
#include maps\mp\zombies\_zm_timer;
#include maps\mp\zombies\_zm_traps;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_tombstone;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\_demo;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\zombies\_zm_pers_upgrades_system;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_game_module;

init()
{
    level.player_out_of_playable_area_monitor = 1;
    level.player_too_many_weapons_monitor = 1;
    level.player_too_many_weapons_monitor_func = ::player_too_many_weapons_monitor;
    level.player_too_many_players_check = 1;
    level.player_too_many_players_check_func = ::player_too_many_players_check;
    level._use_choke_weapon_hints = 1;
    level._use_choke_blockers = 1;
    level.passed_introscreen = 0;

    if ( !isdefined( level.custom_ai_type ) )
        level.custom_ai_type = [];

    level.custom_ai_spawn_check_funcs = [];
    level.spawn_funcs = [];
    level.spawn_funcs["allies"] = [];
    level.spawn_funcs["axis"] = [];
    level.spawn_funcs["team3"] = [];
    level thread maps\mp\zombies\_zm_ffotd::main_start();
    level.zombiemode = 1;
    level.revivefeature = 0;
    level.swimmingfeature = 0;
    level.calc_closest_player_using_paths = 0;
    level.zombie_melee_in_water = 1;
    level.put_timed_out_zombies_back_in_queue = 1;
    level.use_alternate_poi_positioning = 1;
    level.zmb_laugh_alias = "zmb_laugh_richtofen";
    level.sndannouncerisrich = 1;
    level.scr_zm_ui_gametype = getdvar( "ui_gametype" );
    level.scr_zm_ui_gametype_group = getdvar( _hash_6B64B9B4 );
    level.scr_zm_map_start_location = getdvar( _hash_C955B4CD );
    level.curr_gametype_affects_rank = 0;
    gametype = tolower( getdvar( "g_gametype" ) );

    if ( "zclassic" == gametype || "zstandard" == gametype )
        level.curr_gametype_affects_rank = 1;

    level.grenade_multiattack_bookmark_count = 1;
    level.rampage_bookmark_kill_times_count = 3;
    level.rampage_bookmark_kill_times_msec = 6000;
    level.rampage_bookmark_kill_times_delay = 6000;
    level thread watch_rampage_bookmark();

    if ( !isdefined( level._zombies_round_spawn_failsafe ) )
        level._zombies_round_spawn_failsafe = maps\mp\zombies\_zm::round_spawn_failsafe;

    level.zombie_visionset = "zombie_neutral";

    if ( getdvar( _hash_5DF80895 ) == "1" )
        level.zombie_anim_intro = 1;
    else
        level.zombie_anim_intro = 0;

    precache_shaders();
    precache_models();
    precacherumble( "explosion_generic" );
    precacherumble( "dtp_rumble" );
    precacherumble( "slide_rumble" );
    precache_zombie_leaderboards();
    level._zombie_gib_piece_index_all = 0;
    level._zombie_gib_piece_index_right_arm = 1;
    level._zombie_gib_piece_index_left_arm = 2;
    level._zombie_gib_piece_index_right_leg = 3;
    level._zombie_gib_piece_index_left_leg = 4;
    level._zombie_gib_piece_index_head = 5;
    level._zombie_gib_piece_index_guts = 6;
    level._zombie_gib_piece_index_hat = 7;

    if ( !isdefined( level.zombie_ai_limit ) )
        level.zombie_ai_limit = 24;

    if ( !isdefined( level.zombie_actor_limit ) )
        level.zombie_actor_limit = 31;

    maps\mp\_visionset_mgr::init();
    init_dvars();
    init_strings();
    init_levelvars();
    init_sounds();
    init_shellshocks();
    init_flags();
    init_client_flags();
    registerclientfield( "world", "zombie_power_on", 1, 1, "int" );

    if ( !( isdefined( level._no_navcards ) && level._no_navcards ) )
    {
        if ( level.scr_zm_ui_gametype_group == "zclassic" && !level.createfx_enabled )
        {
            registerclientfield( "allplayers", "navcard_held", 1, 4, "int" );
            level.navcards = [];
            level.navcards[0] = "navcard_held_zm_transit";
            level.navcards[1] = "navcard_held_zm_highrise";
            level.navcards[2] = "navcard_held_zm_buried";
            level thread setup_player_navcard_hud();
        }
    }

    register_offhand_weapons_for_level_defaults();
    level thread drive_client_connected_notifies();
/#
    maps\mp\zombies\_zm_devgui::init();
#/
    maps\mp\zombies\_zm_zonemgr::init();
    maps\mp\zombies\_zm_unitrigger::init();
    maps\mp\zombies\_zm_audio::init();
    maps\mp\zombies\_zm_blockers::init();
    maps\mp\zombies\_zm_bot::init();
    maps\mp\zombies\_zm_clone::init();
    maps\mp\zombies\_zm_buildables::init();
    maps\mp\zombies\_zm_equipment::init();
    maps\mp\zombies\_zm_laststand::init();
    maps\mp\zombies\_zm_magicbox::init();
    maps\mp\zombies\_zm_perks::init();
    maps\mp\zombies\_zm_playerhealth::init();
    maps\mp\zombies\_zm_power::init();
    maps\mp\zombies\_zm_powerups::init();
    maps\mp\zombies\_zm_score::init();
    maps\mp\zombies\_zm_spawner::init();
    maps\mp\zombies\_zm_gump::init();
    maps\mp\zombies\_zm_timer::init();
    maps\mp\zombies\_zm_traps::init();
    maps\mp\zombies\_zm_weapons::init();
    init_function_overrides();
    level thread last_stand_pistol_rank_init();
    level thread maps\mp\zombies\_zm_tombstone::init();
    level thread post_all_players_connected();
    init_utility();
    maps\mp\_utility::registerclientsys( "lsm" );
    maps\mp\zombies\_zm_stats::init();
    initializestattracking();

    if ( get_players().size <= 1 )
        incrementcounter( "global_solo_games", 1 );
    else if ( level.systemlink )
        incrementcounter( "global_systemlink_games", 1 );
    else if ( getdvarint( "splitscreen_playerCount" ) == get_players().size )
        incrementcounter( "global_splitscreen_games", 1 );
    else
        incrementcounter( "global_coop_games", 1 );

    onplayerconnect_callback( ::zm_on_player_connect );
    maps\mp\zombies\_zm_pers_upgrades::pers_upgrade_init();
    set_demo_intermission_point();
    level thread maps\mp\zombies\_zm_ffotd::main_end();
    level thread track_players_intersection_tracker();
    level thread onallplayersready();
    level thread startunitriggers();
    level thread maps\mp\gametypes_zm\_zm_gametype::post_init_gametype();
}

post_main()
{
    level thread init_custom_ai_type();
}

startunitriggers()
{
    flag_wait_any( "start_zombie_round_logic", "start_encounters_match_logic" );
    level thread maps\mp\zombies\_zm_unitrigger::main();
}

drive_client_connected_notifies()
{
    while ( true )
    {
        level waittill( "connected", player );

        player reset_rampage_bookmark_kill_times();
        player callback( "on_player_connect" );
    }
}

fade_out_intro_screen_zm( hold_black_time, fade_out_time, destroyed_afterwards )
{
    if ( !isdefined( level.introscreen ) )
    {
        level.introscreen = newhudelem();
        level.introscreen.x = 0;
        level.introscreen.y = 0;
        level.introscreen.horzalign = "fullscreen";
        level.introscreen.vertalign = "fullscreen";
        level.introscreen.foreground = 0;
        level.introscreen setshader( "black", 640, 480 );
        level.introscreen.immunetodemogamehudsettings = 1;
        level.introscreen.immunetodemofreecamera = 1;
        wait 0.05;
    }

    level.introscreen.alpha = 1;

    if ( isdefined( hold_black_time ) )
        wait( hold_black_time );
    else
        wait 0.2;

    if ( !isdefined( fade_out_time ) )
        fade_out_time = 1.5;

    level.introscreen fadeovertime( fade_out_time );
    level.introscreen.alpha = 0;
    wait 1.6;
    level.passed_introscreen = 1;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        players[i] setclientuivisibilityflag( "hud_visible", 1 );

        if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
        {
            if ( isdefined( level.player_movement_suppressed ) )
            {
                players[i] freezecontrols( level.player_movement_suppressed );
/#
                println( " Unfreeze controls 4" );
#/
                continue;
            }

            if ( !( isdefined( players[i].hostmigrationcontrolsfrozen ) && players[i].hostmigrationcontrolsfrozen ) )
            {
                players[i] freezecontrols( 0 );
/#
                println( " Unfreeze controls 5" );
#/
            }
        }
    }

    if ( destroyed_afterwards == 1 )
        level.introscreen destroy();

    flag_set( "initial_blackscreen_passed" );
}

onallplayersready()
{
    timeout = gettime() + 5000;

    while ( getnumexpectedplayers() == 0 && gettime() < timeout )
        wait 0.1;
/#
    println( "ZM >> player_count_expected=" + getnumexpectedplayers() );
#/
    player_count_actual = 0;

    while ( getnumconnectedplayers() < getnumexpectedplayers() || player_count_actual != getnumexpectedplayers() )
    {
        players = get_players();
        player_count_actual = 0;

        for ( i = 0; i < players.size; i++ )
        {
            players[i] freezecontrols( 1 );

            if ( players[i].sessionstate == "playing" )
                player_count_actual++;
        }
/#
        println( "ZM >> Num Connected =" + getnumconnectedplayers() + " Expected : " + getnumexpectedplayers() );
#/
        wait 0.1;
    }

    setinitialplayersconnected();
/#
    println( "ZM >> We have all players - START ZOMBIE LOGIC" );
#/
    if ( 1 == getnumconnectedplayers() && getdvarint( _hash_B0FB65D0 ) == 1 )
    {
        level thread add_bots();
        flag_set( "initial_players_connected" );
    }
    else
    {
        players = get_players();

        if ( players.size == 1 )
        {
            flag_set( "solo_game" );
            level.solo_lives_given = 0;

            foreach ( player in players )
                player.lives = 0;

            level maps\mp\zombies\_zm::set_default_laststand_pistol( 1 );
        }

        flag_set( "initial_players_connected" );

        while ( !aretexturesloaded() )
            wait 0.05;

        thread start_zombie_logic_in_x_sec( 3.0 );
    }

    fade_out_intro_screen_zm( 5.0, 1.5, 1 );
}

start_zombie_logic_in_x_sec( time_to_wait )
{
    wait( time_to_wait );
    flag_set( "start_zombie_round_logic" );
}

getallotherplayers()
{
    aliveplayers = [];

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( !isdefined( level.players[i] ) )
            continue;

        player = level.players[i];

        if ( player.sessionstate != "playing" || player == self )
            continue;

        aliveplayers[aliveplayers.size] = player;
    }

    return aliveplayers;
}

getfreespawnpoint( spawnpoints, player )
{
    if ( !isdefined( spawnpoints ) )
    {
/#
        iprintlnbold( "ZM >> No free spawn points in map" );
#/
        return undefined;
    }

    if ( !isdefined( game["spawns_randomized"] ) )
    {
        game["spawns_randomized"] = 1;
        spawnpoints = array_randomize( spawnpoints );
        random_chance = randomint( 100 );

        if ( random_chance > 50 )
            set_game_var( "side_selection", 1 );
        else
            set_game_var( "side_selection", 2 );
    }

    side_selection = get_game_var( "side_selection" );

    if ( get_game_var( "switchedsides" ) )
    {
        if ( side_selection == 2 )
            side_selection = 1;
        else if ( side_selection == 1 )
            side_selection = 2;
    }

    if ( isdefined( player ) && isdefined( player.team ) )
    {
        for ( i = 0; isdefined( spawnpoints ) && i < spawnpoints.size; i++ )
        {
            asm_cond( player.team == "allies" && isdefined( spawnpoints[i].script_int ) && spawnpoints[i].script_int == 1, loc_90B8 );
            arrayremovevalue( spawnpoints, spawnpoints[i] );
            i = 0;
            asm_jump( loc_90FF );
            asm_cond( player.team != "allies" && isdefined( spawnpoints[i].script_int ) && spawnpoints[i].script_int == 2, loc_90FC );
            arrayremovevalue( spawnpoints, spawnpoints[i] );
            i = 0;
            asm_jump( loc_90FF );
        }
    }

    if ( !isdefined( self.playernum ) )
    {
        if ( self.team == "allies" )
        {
            self.playernum = get_game_var( "_team1_num" );
            set_game_var( "_team1_num", self.playernum + 1 );
        }
        else
        {
            self.playernum = get_game_var( "_team2_num" );
            set_game_var( "_team2_num", self.playernum + 1 );
        }
    }

    for ( j = 0; j < spawnpoints.size; j++ )
    {
        if ( !isdefined( spawnpoints[j].en_num ) )
        {
            for ( m = 0; m < spawnpoints.size; m++ )
                spawnpoints[m].en_num = m;
        }

        if ( spawnpoints[j].en_num == self.playernum )
            return spawnpoints[j];
    }

    return spawnpoints[0];
}

delete_in_createfx()
{
    exterior_goals = getstructarray( "exterior_goal", "targetname" );

    for ( i = 0; i < exterior_goals.size; i++ )
    {
        if ( !isdefined( exterior_goals[i].target ) )
            continue;

        targets = getentarray( exterior_goals[i].target, "targetname" );

        for ( j = 0; j < targets.size; j++ )
            targets[j] self_delete();
    }

    if ( isdefined( level.level_createfx_callback_thread ) )
        level thread [[ level.level_createfx_callback_thread ]]();
}

add_bots()
{
    for ( host = gethostplayer(); !isdefined( host ); host = gethostplayer() )
        wait 0.05;

    wait 4.0;
    zbot_spawn();
    setdvar( "bot_AllowMovement", "1" );
    setdvar( "bot_PressAttackBtn", "1" );
    setdvar( "bot_PressMeleeBtn", "1" );

    while ( get_players().size < 2 )
        wait 0.05;

    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        players[i] freezecontrols( 0 );
/#
        println( " Unfreeze controls 6" );
#/
    }

    level.numberbotsadded = 1;
    flag_set( "start_zombie_round_logic" );
}

zbot_spawn()
{
    player = gethostplayer();
    spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
    spawnpoint = getfreespawnpoint( spawnpoints );
    bot = addtestclient();

    if ( !isdefined( bot ) )
    {
/#
        println( "Could not add test client" );
#/
        return;
    }

    bot.pers["isBot"] = 1;
    bot.equipment_enabled = 0;
    yaw = spawnpoint.angles[1];
    bot thread zbot_spawn_think( spawnpoint.origin, yaw );
    return bot;
}

zbot_spawn_think( origin, yaw )
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self setorigin( origin );
        angles = ( 0, yaw, 0 );
        self setplayerangles( angles );
    }
}

post_all_players_connected()
{
    level thread end_game();
    flag_wait( "start_zombie_round_logic" );
/#
    println( "sessions: mapname=", level.script, " gametype zom isserver 1 player_count=", get_players().size );
#/
    level thread clear_mature_blood();
    level thread round_end_monitor();

    if ( !level.zombie_anim_intro )
    {
        if ( isdefined( level._round_start_func ) )
            level thread [[ level._round_start_func ]]();
    }

    level thread players_playing();
    disablegrenadesuicide();
    level.startinvulnerabletime = getdvarint( _hash_4E44E32D );

    if ( !isdefined( level.music_override ) )
        level.music_override = 0;
}

init_custom_ai_type()
{
    if ( isdefined( level.custom_ai_type ) )
    {
        for ( i = 0; i < level.custom_ai_type.size; i++ )
            [[ level.custom_ai_type[i] ]]();
    }
}

zombiemode_melee_miss()
{
    if ( isdefined( self.enemy.curr_pay_turret ) )
        self.enemy dodamage( getdvarint( "ai_meleeDamage" ), self.origin, self, self, "none", "melee" );
}

player_track_ammo_count()
{
    self notify( "stop_ammo_tracking" );
    self endon( "disconnect" );
    self endon( "stop_ammo_tracking" );
    ammolowcount = 0;
    ammooutcount = 0;

    while ( true )
    {
        wait 0.5;
        weap = self getcurrentweapon();

        if ( !isdefined( weap ) || weap == "none" || !can_track_ammo( weap ) )
            continue;

        if ( self getammocount( weap ) > 5 || self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            ammooutcount = 0;
            ammolowcount = 0;
            continue;
        }

        if ( self getammocount( weap ) > 0 )
        {
            if ( ammolowcount < 1 )
            {
                self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "ammo_low" );
                ammolowcount++;
            }
        }
        else if ( ammooutcount < 1 )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "ammo_out" );
            ammooutcount++;
        }

        wait 20;
    }
}

can_track_ammo( weap )
{
    if ( !isdefined( weap ) )
        return false;

    switch ( weap )
    {
        case "zombie_tazer_flourish":
        case "zombie_sickle_flourish":
        case "zombie_knuckle_crack":
        case "zombie_fists_zm":
        case "zombie_builder_zm":
        case "zombie_bowie_flourish":
        case "time_bomb_zm":
        case "time_bomb_detonator_zm":
        case "tazer_knuckles_zm":
        case "tazer_knuckles_upgraded_zm":
        case "slowgun_zm":
        case "slowgun_upgraded_zm":
        case "screecher_arms_zm":
        case "riotshield_zm":
        case "none":
        case "no_hands_zm":
        case "lower_equip_gasmask_zm":
        case "humangun_zm":
        case "humangun_upgraded_zm":
        case "equip_gasmask_zm":
        case "equip_dieseldrone_zm":
        case "death_throe_zm":
        case "chalk_draw_zm":
        case "alcatraz_shield_zm":
            return false;
        default:
            if ( is_zombie_perk_bottle( weap ) || is_placeable_mine( weap ) || is_equipment( weap ) || issubstr( weap, "knife_ballistic_" ) || getsubstr( weap, 0, 3 ) == "gl_" || weaponfuellife( weap ) > 0 || weap == level.revive_tool )
                return false;
    }

    return true;
}

spawn_vo()
{
    wait 1;
    players = get_players();

    if ( players.size > 1 )
    {
        player = random( players );
        index = maps\mp\zombies\_zm_weapons::get_player_index( player );
        player thread spawn_vo_player( index, players.size );
    }
}

spawn_vo_player( index, num )
{
    sound = "plr_" + index + "_vox_" + num + "play";
    self playsoundwithnotify( sound, "sound_done" );

    self waittill( "sound_done" );
}

precache_shaders()
{
    precacheshader( "hud_chalk_1" );
    precacheshader( "hud_chalk_2" );
    precacheshader( "hud_chalk_3" );
    precacheshader( "hud_chalk_4" );
    precacheshader( "hud_chalk_5" );
    precacheshader( "zom_icon_community_pot" );
    precacheshader( "zom_icon_community_pot_strip" );
    precacheshader( "zom_icon_player_life" );
    precacheshader( "waypoint_revive" );
}

precache_models()
{
    precachemodel( "p_zom_win_bars_01_vert04_bend_180" );
    precachemodel( "p_zom_win_bars_01_vert01_bend_180" );
    precachemodel( "p_zom_win_bars_01_vert04_bend" );
    precachemodel( "p_zom_win_bars_01_vert01_bend" );
    precachemodel( "p_zom_win_cell_bars_01_vert04_bent" );
    precachemodel( "p_zom_win_cell_bars_01_vert01_bent" );
    precachemodel( "tag_origin" );
    precachemodel( "zombie_z_money_icon" );

    if ( isdefined( level.precachecustomcharacters ) )
        self [[ level.precachecustomcharacters ]]();
}

init_shellshocks()
{
    level.player_killed_shellshock = "zombie_death";
    precacheshellshock( level.player_killed_shellshock );
    precacheshellshock( "pain" );
    precacheshellshock( "explosion" );
}

init_strings()
{
    precachestring( &"ZOMBIE_WEAPONCOSTAMMO" );
    precachestring( &"ZOMBIE_ROUND" );
    precachestring( &"SCRIPT_PLUS" );
    precachestring( &"ZOMBIE_GAME_OVER" );
    precachestring( &"ZOMBIE_SURVIVED_ROUND" );
    precachestring( &"ZOMBIE_SURVIVED_ROUNDS" );
    precachestring( &"ZOMBIE_SURVIVED_NOMANS" );
    precachestring( &"ZOMBIE_EXTRA_LIFE" );
    add_zombie_hint( "undefined", &"ZOMBIE_UNDEFINED" );
    add_zombie_hint( "default_treasure_chest", &"ZOMBIE_RANDOM_WEAPON_COST" );
    add_zombie_hint( "default_treasure_chest_950", &"ZOMBIE_RANDOM_WEAPON_950" );
    add_zombie_hint( "powerup_fire_sale_cost", &"ZOMBIE_FIRE_SALE_COST" );
    add_zombie_hint( "default_buy_barrier_piece_10", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_10" );
    add_zombie_hint( "default_buy_barrier_piece_20", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_20" );
    add_zombie_hint( "default_buy_barrier_piece_50", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_50" );
    add_zombie_hint( "default_buy_barrier_piece_100", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_100" );
    add_zombie_hint( "default_reward_barrier_piece", &"ZOMBIE_BUTTON_REWARD_BARRIER" );
    add_zombie_hint( "default_reward_barrier_piece_10", &"ZOMBIE_BUTTON_REWARD_BARRIER_10" );
    add_zombie_hint( "default_reward_barrier_piece_20", &"ZOMBIE_BUTTON_REWARD_BARRIER_20" );
    add_zombie_hint( "default_reward_barrier_piece_30", &"ZOMBIE_BUTTON_REWARD_BARRIER_30" );
    add_zombie_hint( "default_reward_barrier_piece_40", &"ZOMBIE_BUTTON_REWARD_BARRIER_40" );
    add_zombie_hint( "default_reward_barrier_piece_50", &"ZOMBIE_BUTTON_REWARD_BARRIER_50" );
    add_zombie_hint( "default_buy_debris", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_COST" );
    add_zombie_hint( "default_buy_debris_100", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_100" );
    add_zombie_hint( "default_buy_debris_200", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_200" );
    add_zombie_hint( "default_buy_debris_250", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_250" );
    add_zombie_hint( "default_buy_debris_500", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_500" );
    add_zombie_hint( "default_buy_debris_750", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_750" );
    add_zombie_hint( "default_buy_debris_1000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1000" );
    add_zombie_hint( "default_buy_debris_1250", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1250" );
    add_zombie_hint( "default_buy_debris_1500", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1500" );
    add_zombie_hint( "default_buy_debris_1750", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1750" );
    add_zombie_hint( "default_buy_debris_2000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_2000" );
    add_zombie_hint( "default_buy_debris_3000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_3000" );
    add_zombie_hint( "default_buy_door", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST" );
    add_zombie_hint( "default_buy_door_close", &"ZOMBIE_BUTTON_BUY_CLOSE_DOOR" );
    add_zombie_hint( "default_buy_door_100", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_100" );
    add_zombie_hint( "default_buy_door_200", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_200" );
    add_zombie_hint( "default_buy_door_250", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_250" );
    add_zombie_hint( "default_buy_door_500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_500" );
    add_zombie_hint( "default_buy_door_750", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_750" );
    add_zombie_hint( "default_buy_door_1000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1000" );
    add_zombie_hint( "default_buy_door_1250", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1250" );
    add_zombie_hint( "default_buy_door_1500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1500" );
    add_zombie_hint( "default_buy_door_1750", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1750" );
    add_zombie_hint( "default_buy_door_2000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_2000" );
    add_zombie_hint( "default_buy_door_2500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_2500" );
    add_zombie_hint( "default_buy_door_3000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_3000" );
    add_zombie_hint( "default_buy_door_4000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_4000" );
    add_zombie_hint( "default_buy_door_8000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_8000" );
    add_zombie_hint( "default_buy_door_16000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_16000" );
    add_zombie_hint( "default_buy_area", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_COST" );
    add_zombie_hint( "default_buy_area_100", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_100" );
    add_zombie_hint( "default_buy_area_200", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_200" );
    add_zombie_hint( "default_buy_area_250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_250" );
    add_zombie_hint( "default_buy_area_500", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_500" );
    add_zombie_hint( "default_buy_area_750", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_750" );
    add_zombie_hint( "default_buy_area_1000", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1000" );
    add_zombie_hint( "default_buy_area_1250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1250" );
    add_zombie_hint( "default_buy_area_1500", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1500" );
    add_zombie_hint( "default_buy_area_1750", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1750" );
    add_zombie_hint( "default_buy_area_2000", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_2000" );
}

init_sounds()
{
    add_sound( "end_of_round", "mus_zmb_round_over" );
    add_sound( "end_of_game", "mus_zmb_game_over" );
    add_sound( "chalk_one_up", "mus_zmb_chalk" );
    add_sound( "purchase", "zmb_cha_ching" );
    add_sound( "no_purchase", "zmb_no_cha_ching" );
    add_sound( "playerzombie_usebutton_sound", "zmb_zombie_vocals_attack" );
    add_sound( "playerzombie_attackbutton_sound", "zmb_zombie_vocals_attack" );
    add_sound( "playerzombie_adsbutton_sound", "zmb_zombie_vocals_attack" );
    add_sound( "zombie_head_gib", "zmb_zombie_head_gib" );
    add_sound( "rebuild_barrier_piece", "zmb_repair_boards" );
    add_sound( "rebuild_barrier_metal_piece", "zmb_metal_repair" );
    add_sound( "rebuild_barrier_hover", "zmb_boards_float" );
    add_sound( "debris_hover_loop", "zmb_couch_loop" );
    add_sound( "break_barrier_piece", "zmb_break_boards" );
    add_sound( "grab_metal_bar", "zmb_bar_pull" );
    add_sound( "break_metal_bar", "zmb_bar_break" );
    add_sound( "drop_metal_bar", "zmb_bar_drop" );
    add_sound( "blocker_end_move", "zmb_board_slam" );
    add_sound( "barrier_rebuild_slam", "zmb_board_slam" );
    add_sound( "bar_rebuild_slam", "zmb_bar_repair" );
    add_sound( "zmb_rock_fix", "zmb_break_rock_barrier_fix" );
    add_sound( "zmb_vent_fix", "evt_vent_slat_repair" );
    add_sound( "door_slide_open", "zmb_door_slide_open" );
    add_sound( "door_rotate_open", "zmb_door_slide_open" );
    add_sound( "debris_move", "zmb_weap_wall" );
    add_sound( "open_chest", "zmb_lid_open" );
    add_sound( "music_chest", "zmb_music_box" );
    add_sound( "close_chest", "zmb_lid_close" );
    add_sound( "weapon_show", "zmb_weap_wall" );
    add_sound( "break_stone", "break_stone" );
}

init_levelvars()
{
    level.is_zombie_level = 1;
    level.laststandpistol = "m1911_zm";
    level.default_laststandpistol = "m1911_zm";
    level.default_solo_laststandpistol = "m1911_upgraded_zm";
    level.start_weapon = "m1911_zm";
    level.first_round = 1;
    level.start_round = getgametypesetting( "startRound" );
    level.round_number = level.start_round;
    level.enable_magic = getgametypesetting( "magic" );
    level.headshots_only = getgametypesetting( "headshotsonly" );
    level.player_starting_points = level.round_number * 500;
    level.round_start_time = 0;
    level.pro_tips_start_time = 0;
    level.intermission = 0;
    level.dog_intermission = 0;
    level.zombie_total = 0;
    level.total_zombies_killed = 0;
    level.hudelem_count = 0;
    level.zombie_spawn_locations = [];
    level.zombie_rise_spawners = [];
    level.current_zombie_array = [];
    level.current_zombie_count = 0;
    level.zombie_total_subtract = 0;
    level.destructible_callbacks = [];
    level.zombie_vars = [];

    foreach ( team in level.teams )
        level.zombie_vars[team] = [];

    difficulty = 1;
    column = int( difficulty ) + 1;
    set_zombie_var( "zombie_health_increase", 100, 0, column );
    set_zombie_var( "zombie_health_increase_multiplier", 0.1, 1, column );
    set_zombie_var( "zombie_health_start", 150, 0, column );
    set_zombie_var( "zombie_spawn_delay", 2.0, 1, column );
    set_zombie_var( "zombie_new_runner_interval", 10, 0, column );
    set_zombie_var( "zombie_move_speed_multiplier", 8, 0, column );
    set_zombie_var( "zombie_move_speed_multiplier_easy", 2, 0, column );
    set_zombie_var( "zombie_max_ai", 24, 0, column );
    set_zombie_var( "zombie_ai_per_player", 6, 0, column );
    set_zombie_var( "below_world_check", -1000 );
    set_zombie_var( "spectators_respawn", 1 );
    set_zombie_var( "zombie_use_failsafe", 1 );
    set_zombie_var( "zombie_between_round_time", 10 );
    set_zombie_var( "zombie_intermission_time", 15 );
    set_zombie_var( "game_start_delay", 0, 0, column );
    set_zombie_var( "penalty_no_revive", 0.1, 1, column );
    set_zombie_var( "penalty_died", 0.0, 1, column );
    set_zombie_var( "penalty_downed", 0.05, 1, column );
    set_zombie_var( "starting_lives", 1, 0, column );
    set_zombie_var( "zombie_score_kill_4player", 50 );
    set_zombie_var( "zombie_score_kill_3player", 50 );
    set_zombie_var( "zombie_score_kill_2player", 50 );
    set_zombie_var( "zombie_score_kill_1player", 50 );
    set_zombie_var( "zombie_score_kill_4p_team", 30 );
    set_zombie_var( "zombie_score_kill_3p_team", 35 );
    set_zombie_var( "zombie_score_kill_2p_team", 45 );
    set_zombie_var( "zombie_score_kill_1p_team", 0 );
    set_zombie_var( "zombie_score_damage_normal", 10 );
    set_zombie_var( "zombie_score_damage_light", 10 );
    set_zombie_var( "zombie_score_bonus_melee", 80 );
    set_zombie_var( "zombie_score_bonus_head", 50 );
    set_zombie_var( "zombie_score_bonus_neck", 20 );
    set_zombie_var( "zombie_score_bonus_torso", 10 );
    set_zombie_var( "zombie_score_bonus_burn", 10 );
    set_zombie_var( "zombie_flame_dmg_point_delay", 500 );
    set_zombie_var( "zombify_player", 0 );

    if ( issplitscreen() )
        set_zombie_var( "zombie_timer_offset", 280 );

    level thread init_player_levelvars();
    level.gamedifficulty = getgametypesetting( "zmDifficulty" );

    if ( level.gamedifficulty == 0 )
        level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    else
        level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    if ( level.round_number == 1 )
        level.zombie_move_speed = 1;
    else
    {
        for ( i = 1; i <= level.round_number; i++ )
        {
            timer = level.zombie_vars["zombie_spawn_delay"];

            if ( timer > 0.08 )
            {
                level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
                continue;
            }

            if ( timer < 0.08 )
                level.zombie_vars["zombie_spawn_delay"] = 0.08;
        }
    }

    level.speed_change_max = 0;
    level.speed_change_num = 0;
}

init_player_levelvars()
{
    flag_wait( "start_zombie_round_logic" );
    difficulty = 1;
    column = int( difficulty ) + 1;

    for ( i = 0; i < 8; i++ )
    {
        points = 500;

        if ( i > 3 )
            points = 3000;

        points = set_zombie_var( "zombie_score_start_" + ( i + 1 ) + "p", points, 0, column );
    }
}

init_dvars()
{
    if ( getdvar( _hash_FA91EA91 ) == "" )
        setdvar( "zombie_debug", "0" );

    if ( getdvar( _hash_B0FB65D0 ) == "" )
        setdvar( "scr_zm_enable_bots", "0" );

    if ( getdvar( _hash_FA81816F ) == "" )
        setdvar( "zombie_cheat", "0" );

    if ( level.script != "zombie_cod5_prototype" )
        setdvar( "magic_chest_movable", "1" );

    setdvar( "revive_trigger_radius", "75" );
    setdvar( "player_lastStandBleedoutTime", "45" );
    setdvar( "scr_deleteexplosivesonspawn", "0" );
}

init_function_overrides()
{
    level.callbackplayerdamage = ::callback_playerdamage;
    level.overrideplayerdamage = ::player_damage_override;
    level.callbackplayerkilled = ::player_killed_override;
    level.playerlaststand_func = ::player_laststand;
    level.callbackplayerlaststand = ::callback_playerlaststand;
    level.prevent_player_damage = ::player_prevent_damage;
    level.callbackactorkilled = ::actor_killed_override;
    level.callbackactordamage = ::actor_damage_override_wrapper;
    level.custom_introscreen = ::zombie_intro_screen;
    level.custom_intermission = ::player_intermission;
    level.global_damage_func = maps\mp\zombies\_zm_spawner::zombie_damage;
    level.global_damage_func_ads = maps\mp\zombies\_zm_spawner::zombie_damage_ads;
    level.reset_clientdvars = ::onplayerconnect_clientdvars;
    level.zombie_last_stand = ::last_stand_pistol_swap;
    level.zombie_last_stand_pistol_memory = ::last_stand_save_pistol_ammo;
    level.zombie_last_stand_ammo_return = ::last_stand_restore_pistol_ammo;
    level.player_becomes_zombie = ::zombify_player;
    level.validate_enemy_path_length = ::default_validate_enemy_path_length;
}

callback_playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    self endon( "disconnect" );
    [[ maps\mp\zombies\_zm_laststand::playerlaststand ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
}

codecallback_destructibleevent( event, param1, param2, param3 )
{
    if ( event == "broken" )
    {
        notify_type = param1;
        attacker = param2;
        weapon = param3;

        if ( isdefined( level.destructible_callbacks[notify_type] ) )
            self thread [[ level.destructible_callbacks[notify_type] ]]( notify_type, attacker );

        self notify( event, notify_type, attacker );
    }
    else if ( event == "breakafter" )
    {
        piece = param1;
        time = param2;
        damage = param3;
        self thread breakafter( time, damage, piece );
    }
}

breakafter( time, damage, piece )
{
    self notify( "breakafter" );
    self endon( "breakafter" );
    wait( time );
    self dodamage( damage, self.origin, undefined, undefined );
}

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
/#
    println( "ZM Callback_PlayerDamage" + idamage + "\n" );
#/
    if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker.sessionteam == self.sessionteam && !eattacker hasperk( "specialty_noname" ) && !( isdefined( self.is_zombie ) && self.is_zombie ) )
    {
        self process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );

        if ( self != eattacker )
        {
/#
            println( "Exiting - players can't hurt each other." );
#/
            return;
        }
        else if ( smeansofdeath != "MOD_GRENADE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_BURNED" && smeansofdeath != "MOD_SUICIDE" )
        {
/#
            println( "Exiting - damage type verbotten." );
#/
            return;
        }
    }

    if ( isdefined( level.pers_upgrade_insta_kill ) && level.pers_upgrade_insta_kill )
        self maps\mp\zombies\_zm_pers_upgrades_functions::pers_insta_kill_melee_swipe( smeansofdeath, eattacker );

    if ( isdefined( self.overrideplayerdamage ) )
        idamage = self [[ self.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
    else if ( isdefined( level.overrideplayerdamage ) )
        idamage = self [[ level.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
/#
    assert( isdefined( idamage ), "You must return a value from a damage override function." );
#/
    if ( isdefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
    {
        maxhealth = self.maxhealth;
        self.health += idamage;
        self.maxhealth = maxhealth;
    }

    if ( isdefined( self.divetoprone ) && self.divetoprone == 1 )
    {
        if ( smeansofdeath == "MOD_GRENADE_SPLASH" )
        {
            dist = distance2d( vpoint, self.origin );

            if ( dist > 32 )
            {
                dot_product = vectordot( anglestoforward( self.angles ), vdir );

                if ( dot_product > 0 )
                    idamage = int( idamage * 0.5 );
            }
        }
    }
/#
    println( "CB PD" );
#/
    if ( isdefined( level.prevent_player_damage ) )
    {
        if ( self [[ level.prevent_player_damage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) )
            return;
    }

    idflags |= level.idflags_no_knockback;

    if ( idamage > 0 && shitloc == "riotshield" )
        shitloc = "torso_upper";
/#
    println( "Finishplayerdamage wrapper." );
#/
    self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    self finishplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

register_player_friendly_fire_callback( callback )
{
    if ( !isdefined( level.player_friendly_fire_callbacks ) )
        level.player_friendly_fire_callbacks = [];

    level.player_friendly_fire_callbacks[level.player_friendly_fire_callbacks.size] = callback;
}

process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( isdefined( level.player_friendly_fire_callbacks ) )
    {
        foreach ( callback in level.player_friendly_fire_callbacks )
            self [[ callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
    }
}

init_flags()
{
    flag_init( "solo_game" );
    flag_init( "start_zombie_round_logic" );
    flag_init( "start_encounters_match_logic" );
    flag_init( "spawn_point_override" );
    flag_init( "power_on" );
    flag_init( "crawler_round" );
    flag_init( "spawn_zombies", 1 );
    flag_init( "dog_round" );
    flag_init( "begin_spawning" );
    flag_init( "end_round_wait" );
    flag_init( "wait_and_revive" );
    flag_init( "instant_revive" );
    flag_init( "initial_blackscreen_passed" );
    flag_init( "initial_players_connected" );
}

init_client_flags()
{
    if ( isdefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
    {
        level._zombie_scriptmover_flag_board_horizontal_fx = 14;
        level._zombie_scriptmover_flag_board_vertical_fx = 13;
    }

    if ( isdefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
        level._zombie_scriptmover_flag_rock_fx = 12;

    level._zombie_player_flag_cloak_weapon = 14;

    if ( !( isdefined( level.disable_deadshot_clientfield ) && level.disable_deadshot_clientfield ) )
        registerclientfield( "toplayer", "deadshot_perk", 1, 1, "int" );

    registerclientfield( "actor", "zombie_riser_fx", 1, 1, "int" );

    if ( !( isdefined( level._no_water_risers ) && level._no_water_risers ) )
        registerclientfield( "actor", "zombie_riser_fx_water", 1, 1, "int" );

    if ( isdefined( level._foliage_risers ) && level._foliage_risers )
        registerclientfield( "actor", "zombie_riser_fx_foliage", 12000, 1, "int" );

    if ( isdefined( level.risers_use_low_gravity_fx ) && level.risers_use_low_gravity_fx )
        registerclientfield( "actor", "zombie_riser_fx_lowg", 1, 1, "int" );
}

init_fx()
{
    level.createfx_callback_thread = ::delete_in_createfx;
    level._effect["wood_chunk_destory"] = loadfx( "impacts/fx_large_woodhit" );
    level._effect["fx_zombie_bar_break"] = loadfx( "maps/zombie/fx_zombie_bar_break" );
    level._effect["fx_zombie_bar_break_lite"] = loadfx( "maps/zombie/fx_zombie_bar_break_lite" );

    if ( !( isdefined( level.fx_exclude_edge_fog ) && level.fx_exclude_edge_fog ) )
        level._effect["edge_fog"] = loadfx( "maps/zombie/fx_fog_zombie_amb" );

    level._effect["chest_light"] = loadfx( "maps/zombie/fx_zmb_tranzit_marker_glow" );

    if ( !( isdefined( level.fx_exclude_default_eye_glow ) && level.fx_exclude_default_eye_glow ) )
        level._effect["eye_glow"] = loadfx( "misc/fx_zombie_eye_single" );

    level._effect["headshot"] = loadfx( "impacts/fx_flesh_hit" );
    level._effect["headshot_nochunks"] = loadfx( "misc/fx_zombie_bloodsplat" );
    level._effect["bloodspurt"] = loadfx( "misc/fx_zombie_bloodspurt" );

    if ( !( isdefined( level.fx_exclude_tesla_head_light ) && level.fx_exclude_tesla_head_light ) )
        level._effect["tesla_head_light"] = loadfx( "maps/zombie/fx_zombie_tesla_neck_spurt" );

    level._effect["zombie_guts_explosion"] = loadfx( "maps/zombie/fx_zmb_tranzit_torso_explo" );
    level._effect["rise_burst_water"] = loadfx( "maps/zombie/fx_mp_zombie_hand_dirt_burst" );
    level._effect["rise_billow_water"] = loadfx( "maps/zombie/fx_mp_zombie_body_dirt_billowing" );
    level._effect["rise_dust_water"] = loadfx( "maps/zombie/fx_mp_zombie_body_dust_falling" );
    level._effect["rise_burst"] = loadfx( "maps/zombie/fx_mp_zombie_hand_dirt_burst" );
    level._effect["rise_billow"] = loadfx( "maps/zombie/fx_mp_zombie_body_dirt_billowing" );
    level._effect["rise_dust"] = loadfx( "maps/zombie/fx_mp_zombie_body_dust_falling" );
    level._effect["fall_burst"] = loadfx( "maps/zombie/fx_mp_zombie_hand_dirt_burst" );
    level._effect["fall_billow"] = loadfx( "maps/zombie/fx_mp_zombie_body_dirt_billowing" );
    level._effect["fall_dust"] = loadfx( "maps/zombie/fx_mp_zombie_body_dust_falling" );
    level._effect["character_fire_death_sm"] = loadfx( "env/fire/fx_fire_zombie_md" );
    level._effect["character_fire_death_torso"] = loadfx( "env/fire/fx_fire_zombie_torso" );

    if ( !( isdefined( level.fx_exclude_default_explosion ) && level.fx_exclude_default_explosion ) )
        level._effect["def_explosion"] = loadfx( "explosions/fx_default_explosion" );

    if ( !( isdefined( level._uses_default_wallbuy_fx ) && !level._uses_default_wallbuy_fx ) )
    {
        level._effect["870mcs_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_870mcs" );
        level._effect["ak74u_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_ak74u" );
        level._effect["beretta93r_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_berreta93r" );
        level._effect["bowie_knife_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_bowie" );
        level._effect["claymore_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_claymore" );
        level._effect["m14_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_m14" );
        level._effect["m16_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" );
        level._effect["mp5k_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_mp5k" );
        level._effect["rottweil72_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_olympia" );
    }

    if ( !( isdefined( level._uses_sticky_grenades ) && !level._uses_sticky_grenades ) )
    {
        if ( !( isdefined( level.disable_fx_zmb_wall_buy_semtex ) && level.disable_fx_zmb_wall_buy_semtex ) )
            level._effect["sticky_grenade_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_semtex" );
    }

    if ( !( isdefined( level._uses_taser_knuckles ) && !level._uses_taser_knuckles ) )
        level._effect["tazer_knuckles_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_taseknuck" );

    if ( isdefined( level.buildable_wallbuy_weapons ) )
        level._effect["dynamic_wallbuy_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_question" );

    if ( !( isdefined( level.disable_fx_upgrade_aquired ) && level.disable_fx_upgrade_aquired ) )
        level._effect["upgrade_aquired"] = loadfx( "maps/zombie/fx_zmb_tanzit_upgrade" );
}

zombie_intro_screen( string1, string2, string3, string4, string5 )
{
    flag_wait( "start_zombie_round_logic" );
}

players_playing()
{
    players = get_players();
    level.players_playing = players.size;
    wait 20;
    players = get_players();
    level.players_playing = players.size;
}

onplayerconnect_clientdvars()
{
    self setclientcompass( 0 );
    self setclientthirdperson( 0 );
    self resetfov();
    self setclientthirdpersonangle( 0 );
    self setclientammocounterhide( 1 );
    self setclientminiscoreboardhide( 1 );
    self setclienthudhardcore( 0 );
    self setclientplayerpushamount( 1 );
    self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
    self setclientaimlockonpitchstrength( 0.0 );
    self maps\mp\zombies\_zm_laststand::player_getup_setup();
}

checkforalldead( excluded_player )
{
    players = get_players();
    count = 0;

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( excluded_player ) && excluded_player == players[i] )
            continue;

        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !( players[i].sessionstate == "spectator" ) )
            count++;
    }

    if ( count == 0 && !( isdefined( level.no_end_game_check ) && level.no_end_game_check ) )
        level notify( "end_game" );
}

onplayerspawned()
{
    self endon( "disconnect" );
    self notify( "stop_onPlayerSpawned" );
    self endon( "stop_onPlayerSpawned" );

    for (;;)
    {
        self waittill( "spawned_player" );

        if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
        {
            self freezecontrols( 0 );
/#
            println( " Unfreeze controls 7" );
#/
        }

        self.hits = 0;
        self init_player_offhand_weapons();
        lethal_grenade = self get_player_lethal_grenade();

        if ( !self hasweapon( lethal_grenade ) )
        {
            self giveweapon( lethal_grenade );
            self setweaponammoclip( lethal_grenade, 0 );
        }

        self recordplayerrevivezombies( self );
/#
        if ( getdvarint( _hash_FA81816F ) >= 1 && getdvarint( _hash_FA81816F ) <= 3 )
            self enableinvulnerability();
#/
        self setactionslot( 3, "altMode" );
        self playerknockback( 0 );
        self setclientthirdperson( 0 );
        self resetfov();
        self setclientthirdpersonangle( 0 );
        self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
        self cameraactivate( 0 );
        self.num_perks = 0;
        self.on_lander_last_stand = undefined;
        self setblur( 0, 0.1 );
        self.zmbdialogqueue = [];
        self.zmbdialogactive = 0;
        self.zmbdialoggroups = [];
        self.zmbdialoggroup = "";

        if ( isdefined( level.player_out_of_playable_area_monitor ) && level.player_out_of_playable_area_monitor )
            self thread player_out_of_playable_area_monitor();

        if ( isdefined( level.player_too_many_weapons_monitor ) && level.player_too_many_weapons_monitor )
            self thread [[ level.player_too_many_weapons_monitor_func ]]();

        if ( isdefined( level.player_too_many_players_check ) && level.player_too_many_players_check )
            level thread [[ level.player_too_many_players_check_func ]]();

        self.disabled_perks = [];

        if ( isdefined( self.player_initialized ) )
        {
            if ( self.player_initialized == 0 )
            {
                self.player_initialized = 1;
                self giveweapon( self get_player_lethal_grenade() );
                self setweaponammoclip( self get_player_lethal_grenade(), 0 );
                self setclientammocounterhide( 0 );
                self setclientminiscoreboardhide( 0 );
                self.is_drinking = 0;
                self thread player_zombie_breadcrumb();
                self thread player_monitor_travel_dist();
                self thread player_monitor_time_played();

                if ( isdefined( level.custom_player_track_ammo_count ) )
                    self thread [[ level.custom_player_track_ammo_count ]]();
                else
                    self thread player_track_ammo_count();

                self thread shock_onpain();
                self thread player_grenade_watcher();
                self maps\mp\zombies\_zm_laststand::revive_hud_create();

                if ( isdefined( level.zm_gamemodule_spawn_func ) )
                    self thread [[ level.zm_gamemodule_spawn_func ]]();

                self thread player_spawn_protection();

                if ( !isdefined( self.lives ) )
                    self.lives = 0;
            }
        }
    }
}

player_spawn_protection()
{
    self endon( "disconnect" );
    x = 0;

    while ( x < 60 )
    {
        self.ignoreme = 1;
        x++;
        wait 0.05;
    }

    self.ignoreme = 0;
}

spawn_life_brush( origin, radius, height )
{
    life_brush = spawn( "trigger_radius", origin, 0, radius, height );
    life_brush.script_noteworthy = "life_brush";
    return life_brush;
}

in_life_brush()
{
    life_brushes = getentarray( "life_brush", "script_noteworthy" );

    if ( !isdefined( life_brushes ) )
        return false;

    for ( i = 0; i < life_brushes.size; i++ )
    {
        if ( self istouching( life_brushes[i] ) )
            return true;
    }

    return false;
}

spawn_kill_brush( origin, radius, height )
{
    kill_brush = spawn( "trigger_radius", origin, 0, radius, height );
    kill_brush.script_noteworthy = "kill_brush";
    return kill_brush;
}

in_kill_brush()
{
    kill_brushes = getentarray( "kill_brush", "script_noteworthy" );

    if ( !isdefined( kill_brushes ) )
        return false;

    for ( i = 0; i < kill_brushes.size; i++ )
    {
        if ( self istouching( kill_brushes[i] ) )
            return true;
    }

    return false;
}

in_enabled_playable_area()
{
    playable_area = getentarray( "player_volume", "script_noteworthy" );

    if ( !isdefined( playable_area ) )
        return false;

    for ( i = 0; i < playable_area.size; i++ )
    {
        if ( maps\mp\zombies\_zm_zonemgr::zone_is_enabled( playable_area[i].targetname ) && self istouching( playable_area[i] ) )
            return true;
    }

    return false;
}

get_player_out_of_playable_area_monitor_wait_time()
{
/#
    if ( isdefined( level.check_kill_thread_every_frame ) && level.check_kill_thread_every_frame )
        return 0.05;
#/
    return 3;
}

player_out_of_playable_area_monitor()
{
    self notify( "stop_player_out_of_playable_area_monitor" );
    self endon( "stop_player_out_of_playable_area_monitor" );
    self endon( "disconnect" );
    level endon( "end_game" );

    while ( !isdefined( self.characterindex ) )
        wait 0.05;

    wait( 0.15 * self.characterindex );

    while ( true )
    {
        if ( self.sessionstate == "spectator" )
        {
            wait( get_player_out_of_playable_area_monitor_wait_time() );
            continue;
        }

        if ( is_true( level.hostmigration_occured ) )
        {
            wait( get_player_out_of_playable_area_monitor_wait_time() );
            continue;
        }

        if ( !self in_life_brush() && ( self in_kill_brush() || !self in_enabled_playable_area() ) )
        {
            if ( !isdefined( level.player_out_of_playable_area_monitor_callback ) || self [[ level.player_out_of_playable_area_monitor_callback ]]() )
            {
/#
                if ( isdefined( level.kill_thread_test_mode ) && level.kill_thread_test_mode )
                {
                    iprintlnbold( "out of playable" );
                    wait( get_player_out_of_playable_area_monitor_wait_time() );
                    continue;
                }

                if ( self isinmovemode( "ufo", "noclip" ) || isdefined( level.disable_kill_thread ) && level.disable_kill_thread || getdvarint( _hash_FA81816F ) > 0 )
                {
                    wait( get_player_out_of_playable_area_monitor_wait_time() );
                    continue;
                }
#/
                self maps\mp\zombies\_zm_stats::increment_map_cheat_stat( "cheat_out_of_playable" );
                self maps\mp\zombies\_zm_stats::increment_client_stat( "cheat_out_of_playable", 0 );
                self maps\mp\zombies\_zm_stats::increment_client_stat( "cheat_total", 0 );
                self playlocalsound( level.zmb_laugh_alias );
                wait 0.5;

                if ( get_players().size == 1 && flag( "solo_game" ) && ( isdefined( self.waiting_to_revive ) && self.waiting_to_revive ) )
                    level notify( "end_game" );
                else
                {
                    self disableinvulnerability();
                    self.lives = 0;
                    self dodamage( self.health + 1000, self.origin );
                    self.bleedout_time = 0;
                }
            }
        }

        wait( get_player_out_of_playable_area_monitor_wait_time() );
    }
}

get_player_too_many_weapons_monitor_wait_time()
{
    return 3;
}

player_too_many_weapons_monitor_takeaway_simultaneous( primary_weapons_to_take )
{
    self endon( "player_too_many_weapons_monitor_takeaway_sequence_done" );
    self waittill_any( "player_downed", "replace_weapon_powerup" );

    for ( i = 0; i < primary_weapons_to_take.size; i++ )
        self takeweapon( primary_weapons_to_take[i] );

    self maps\mp\zombies\_zm_score::minus_to_player_score( self.score );
    self give_start_weapon( 0 );

    if ( !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        self decrement_is_drinking();
    else if ( flag( "solo_game" ) )
        self.score_lost_when_downed = 0;

    self notify( "player_too_many_weapons_monitor_takeaway_sequence_done" );
}

player_too_many_weapons_monitor_takeaway_sequence( primary_weapons_to_take )
{
    self thread player_too_many_weapons_monitor_takeaway_simultaneous( primary_weapons_to_take );
    self endon( "player_downed" );
    self endon( "replace_weapon_powerup" );
    self increment_is_drinking();
    score_decrement = round_up_to_ten( int( self.score / ( primary_weapons_to_take.size + 1 ) ) );

    for ( i = 0; i < primary_weapons_to_take.size; i++ )
    {
        self playlocalsound( level.zmb_laugh_alias );
        self switchtoweapon( primary_weapons_to_take[i] );
        self maps\mp\zombies\_zm_score::minus_to_player_score( score_decrement );
        wait 3;
        self takeweapon( primary_weapons_to_take[i] );
    }

    self playlocalsound( level.zmb_laugh_alias );
    self maps\mp\zombies\_zm_score::minus_to_player_score( self.score );
    wait 1;
    self give_start_weapon( 1 );
    self decrement_is_drinking();
    self notify( "player_too_many_weapons_monitor_takeaway_sequence_done" );
}

player_too_many_weapons_monitor()
{
    self notify( "stop_player_too_many_weapons_monitor" );
    self endon( "stop_player_too_many_weapons_monitor" );
    self endon( "disconnect" );
    level endon( "end_game" );
    scalar = self.characterindex;

    if ( !isdefined( scalar ) )
        scalar = self getentitynumber();

    wait( 0.15 * scalar );

    while ( true )
    {
        if ( self has_powerup_weapon() || self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || self.sessionstate == "spectator" )
        {
            wait( get_player_too_many_weapons_monitor_wait_time() );
            continue;
        }
/#
        if ( getdvarint( _hash_FA81816F ) > 0 )
        {
            wait( get_player_too_many_weapons_monitor_wait_time() );
            continue;
        }
#/
        weapon_limit = get_player_weapon_limit( self );
        primaryweapons = self getweaponslistprimaries();

        if ( primaryweapons.size > weapon_limit )
        {
            self maps\mp\zombies\_zm_weapons::take_fallback_weapon();
            primaryweapons = self getweaponslistprimaries();
        }

        primary_weapons_to_take = [];

        for ( i = 0; i < primaryweapons.size; i++ )
        {
            if ( maps\mp\zombies\_zm_weapons::is_weapon_included( primaryweapons[i] ) || maps\mp\zombies\_zm_weapons::is_weapon_upgraded( primaryweapons[i] ) )
                primary_weapons_to_take[primary_weapons_to_take.size] = primaryweapons[i];
        }

        if ( primary_weapons_to_take.size > weapon_limit )
        {
            if ( !isdefined( level.player_too_many_weapons_monitor_callback ) || self [[ level.player_too_many_weapons_monitor_callback ]]( primary_weapons_to_take ) )
            {
                self maps\mp\zombies\_zm_stats::increment_map_cheat_stat( "cheat_too_many_weapons" );
                self maps\mp\zombies\_zm_stats::increment_client_stat( "cheat_too_many_weapons", 0 );
                self maps\mp\zombies\_zm_stats::increment_client_stat( "cheat_total", 0 );
                self thread player_too_many_weapons_monitor_takeaway_sequence( primary_weapons_to_take );

                self waittill( "player_too_many_weapons_monitor_takeaway_sequence_done" );
            }
        }

        wait( get_player_too_many_weapons_monitor_wait_time() );
    }
}

player_monitor_travel_dist()
{
    self endon( "disconnect" );
    self notify( "stop_player_monitor_travel_dist" );
    self endon( "stop_player_monitor_travel_dist" );

    for ( prevpos = self.origin; 1; prevpos = self.origin )
    {
        wait 0.1;
        self.pers["distance_traveled"] += distance( self.origin, prevpos );
    }
}

player_monitor_time_played()
{
    self endon( "disconnect" );
    self notify( "stop_player_monitor_time_played" );
    self endon( "stop_player_monitor_time_played" );
    flag_wait( "start_zombie_round_logic" );

    for (;;)
    {
        wait 1.0;
        maps\mp\zombies\_zm_stats::increment_client_stat( "time_played_total" );
    }
}

reset_rampage_bookmark_kill_times()
{
    if ( !isdefined( self.rampage_bookmark_kill_times ) )
    {
        self.rampage_bookmark_kill_times = [];
        self.ignore_rampage_kill_times = 0;
    }

    for ( i = 0; i < level.rampage_bookmark_kill_times_count; i++ )
        self.rampage_bookmark_kill_times[i] = 0;
}

add_rampage_bookmark_kill_time()
{
    now = gettime();

    if ( now <= self.ignore_rampage_kill_times )
        return;

    oldest_index = 0;
    oldest_time = now + 1;

    for ( i = 0; i < level.rampage_bookmark_kill_times_count; i++ )
    {
        if ( !self.rampage_bookmark_kill_times[i] )
        {
            oldest_index = i;
            break;
            continue;
        }

        if ( oldest_time > self.rampage_bookmark_kill_times[i] )
        {
            oldest_index = i;
            oldest_time = self.rampage_bookmark_kill_times[i];
        }
    }

    self.rampage_bookmark_kill_times[oldest_index] = now;
}

watch_rampage_bookmark()
{
    while ( true )
    {
        wait 0.05;
        waittillframeend;
        now = gettime();
        oldest_allowed = now - level.rampage_bookmark_kill_times_msec;
        players = get_players();

        for ( player_index = 0; player_index < players.size; player_index++ )
        {
            player = players[player_index];
/#
            if ( isdefined( player.pers["isBot"] ) && player.pers["isBot"] )
                continue;
#/
            for ( time_index = 0; time_index < level.rampage_bookmark_kill_times_count; time_index++ )
            {
                if ( !player.rampage_bookmark_kill_times[time_index] )
                {
                    break;
                    continue;
                }

                if ( oldest_allowed > player.rampage_bookmark_kill_times[time_index] )
                {
                    player.rampage_bookmark_kill_times[time_index] = 0;
                    break;
                }
            }

            if ( time_index >= level.rampage_bookmark_kill_times_count )
            {
                maps\mp\_demo::bookmark( "zm_player_rampage", gettime(), player );
                player reset_rampage_bookmark_kill_times();
                player.ignore_rampage_kill_times = now + level.rampage_bookmark_kill_times_delay;
            }
        }
    }
}

player_grenade_multiattack_bookmark_watcher( grenade )
{
    self endon( "disconnect" );
    waittillframeend;

    if ( !isdefined( grenade ) )
        return;

    inflictorentnum = grenade getentitynumber();
    inflictorenttype = grenade getentitytype();
    inflictorbirthtime = 0;

    if ( isdefined( grenade.birthtime ) )
        inflictorbirthtime = grenade.birthtime;

    ret_val = grenade waittill_any_timeout( 15, "explode" );

    if ( !isdefined( self ) || isdefined( ret_val ) && "timeout" == ret_val )
        return;

    self.grenade_multiattack_count = 0;
    self.grenade_multiattack_ent = undefined;
    waittillframeend;

    if ( !isdefined( self ) )
        return;

    count = level.grenade_multiattack_bookmark_count;

    if ( isdefined( grenade.grenade_multiattack_bookmark_count ) && grenade.grenade_multiattack_bookmark_count )
        count = grenade.grenade_multiattack_bookmark_count;

    bookmark_string = "zm_player_grenade_multiattack";

    if ( isdefined( grenade.use_grenade_special_long_bookmark ) && grenade.use_grenade_special_long_bookmark )
        bookmark_string = "zm_player_grenade_special_long";
    else if ( isdefined( grenade.use_grenade_special_bookmark ) && grenade.use_grenade_special_bookmark )
        bookmark_string = "zm_player_grenade_special";

    if ( count <= self.grenade_multiattack_count && isdefined( self.grenade_multiattack_ent ) )
        adddemobookmark( level.bookmark[bookmark_string], gettime(), self getentitynumber(), 255, 0, inflictorentnum, inflictorenttype, inflictorbirthtime, 0, self.grenade_multiattack_ent getentitynumber() );

    self.grenade_multiattack_count = 0;
}

player_grenade_watcher()
{
    self endon( "disconnect" );
    self notify( "stop_player_grenade_watcher" );
    self endon( "stop_player_grenade_watcher" );
    self.grenade_multiattack_count = 0;

    while ( true )
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( isdefined( grenade ) && isalive( grenade ) )
            grenade.team = self.team;

        self thread player_grenade_multiattack_bookmark_watcher( grenade );

        if ( isdefined( level.grenade_watcher ) )
            self [[ level.grenade_watcher ]]( grenade, weapname );
    }
}

player_prevent_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    if ( !isdefined( einflictor ) || !isdefined( eattacker ) )
        return false;

    if ( einflictor == self || eattacker == self )
        return false;

    if ( isdefined( einflictor ) && isdefined( einflictor.team ) )
    {
        if ( !( isdefined( einflictor.damage_own_team ) && einflictor.damage_own_team ) )
        {
            if ( einflictor.team == self.team )
                return true;
        }
    }

    return false;
}

player_revive_monitor()
{
    self endon( "disconnect" );
    self notify( "stop_player_revive_monitor" );
    self endon( "stop_player_revive_monitor" );

    while ( true )
    {
        self waittill( "player_revived", reviver );

        self playsoundtoplayer( "zmb_character_revived", self );

        if ( isdefined( level.isresetting_grief ) && level.isresetting_grief )
            continue;

        bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "revived", self.origin );

        if ( isdefined( reviver ) )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "revive_up" );
            points = self.score_lost_when_downed;
/#
            println( "ZM >> LAST STAND - points = " + points );
#/
            reviver maps\mp\zombies\_zm_score::player_add_points( "reviver", points );
            self.score_lost_when_downed = 0;
        }
    }
}

laststand_giveback_player_perks()
{
    if ( isdefined( self.laststand_perks ) )
    {
        lost_perk_index = int( -1 );

        if ( self.laststand_perks.size > 1 )
            lost_perk_index = randomint( self.laststand_perks.size - 1 );

        for ( i = 0; i < self.laststand_perks.size; i++ )
        {
            if ( self hasperk( self.laststand_perks[i] ) )
                continue;

            if ( i == lost_perk_index )
                continue;

            maps\mp\zombies\_zm_perks::give_perk( self.laststand_perks[i] );
        }
    }
}

remote_revive_watch()
{
    self endon( "death" );
    self endon( "player_revived" );

    for ( keep_checking = 1; keep_checking; keep_checking = 0 )
    {
        self waittill( "remote_revive", reviver );

        asm_cond( reviver.team == self.team, loc_C024 );
    }

    self maps\mp\zombies\_zm_laststand::remote_revive( reviver );
}

remove_deadshot_bottle()
{
    wait 0.05;

    if ( isdefined( self.lastactiveweapon ) && self.lastactiveweapon == "zombie_perk_bottle_deadshot" )
        self.lastactiveweapon = "none";
}

take_additionalprimaryweapon()
{
    weapon_to_take = undefined;

    if ( isdefined( self._retain_perks ) && self._retain_perks || isdefined( self._retain_perks_array ) && ( isdefined( self._retain_perks_array["specialty_additionalprimaryweapon"] ) && self._retain_perks_array["specialty_additionalprimaryweapon"] ) )
        return weapon_to_take;

    primary_weapons_that_can_be_taken = [];
    primaryweapons = self getweaponslistprimaries();

    for ( i = 0; i < primaryweapons.size; i++ )
    {
        if ( maps\mp\zombies\_zm_weapons::is_weapon_included( primaryweapons[i] ) || maps\mp\zombies\_zm_weapons::is_weapon_upgraded( primaryweapons[i] ) )
            primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size] = primaryweapons[i];
    }

    pwtcbt = primary_weapons_that_can_be_taken.size;

    while ( pwtcbt >= 3 )
    {
        weapon_to_take = primary_weapons_that_can_be_taken[pwtcbt - 1];
        pwtcbt--;

        if ( weapon_to_take == self getcurrentweapon() )
            self switchtoweapon( primary_weapons_that_can_be_taken[0] );

        self takeweapon( weapon_to_take );
    }

    return weapon_to_take;
}

player_laststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
/#
    println( "ZM >> LAST STAND - player_laststand called" );
#/
    b_alt_visionset = 0;
    self allowjump( 0 );
    currweapon = self getcurrentweapon();
    statweapon = currweapon;

    if ( is_alt_weapon( statweapon ) )
        statweapon = weaponaltweaponname( statweapon );

    self addweaponstat( statweapon, "deathsDuringUse", 1 );

    if ( isdefined( self.hasperkspecialtytombstone ) && self.hasperkspecialtytombstone )
        self.laststand_perks = maps\mp\zombies\_zm_tombstone::tombstone_save_perks( self );

    if ( isdefined( self.pers_upgrades_awarded["perk_lose"] ) && self.pers_upgrades_awarded["perk_lose"] )
        self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_perk_lose_save();

    players = get_players();

    if ( players.size == 1 && flag( "solo_game" ) )
    {
        if ( self.lives > 0 && self hasperk( "specialty_quickrevive" ) )
            self thread wait_and_revive();
    }

    if ( self hasperk( "specialty_additionalprimaryweapon" ) )
        self.weapon_taken_by_losing_specialty_additionalprimaryweapon = take_additionalprimaryweapon();

    if ( isdefined( self.hasperkspecialtytombstone ) && self.hasperkspecialtytombstone )
    {
        self [[ level.tombstone_laststand_func ]]();
        self thread [[ level.tombstone_spawn_func ]]();
        self.hasperkspecialtytombstone = undefined;
        self notify( "specialty_scavenger_stop" );
    }

    self clear_is_drinking();
    self thread remove_deadshot_bottle();
    self thread remote_revive_watch();
    self maps\mp\zombies\_zm_score::player_downed_penalty();
    self disableoffhandweapons();
    self thread last_stand_grenade_save_and_return();

    if ( smeansofdeath != "MOD_SUICIDE" && smeansofdeath != "MOD_FALLING" )
    {
        if ( !( isdefined( self.intermission ) && self.intermission ) )
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "revive_down" );
        else if ( isdefined( level.custom_player_death_vo_func ) && !self [[ level.custom_player_death_vo_func ]]() )
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "exert_death" );
    }

    bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "downed", self.origin );

    if ( isdefined( level._zombie_minigun_powerup_last_stand_func ) )
        self thread [[ level._zombie_minigun_powerup_last_stand_func ]]();

    if ( isdefined( level._zombie_tesla_powerup_last_stand_func ) )
        self thread [[ level._zombie_tesla_powerup_last_stand_func ]]();

    if ( self hasperk( "specialty_grenadepulldeath" ) )
    {
        b_alt_visionset = 1;

        if ( isdefined( level.custom_laststand_func ) )
            self thread [[ level.custom_laststand_func ]]();
    }

    if ( isdefined( self.intermission ) && self.intermission )
    {
        bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "died", self.origin );
        wait 0.5;
        self stopsounds();

        level waittill( "forever" );
    }

    if ( !b_alt_visionset )
        visionsetlaststand( "zombie_last_stand", 1 );
}

failsafe_revive_give_back_weapons( excluded_player )
{
    for ( i = 0; i < 10; i++ )
    {
        wait 0.05;
        players = get_players();

        foreach ( player in players )
        {
            if ( player == excluded_player || !isdefined( player.reviveprogressbar ) || player maps\mp\zombies\_zm_laststand::is_reviving_any() )
                continue;
/#
            iprintlnbold( "FAILSAFE CLEANING UP REVIVE HUD AND GUN" );
#/
            player maps\mp\zombies\_zm_laststand::revive_give_back_weapons( "none" );

            if ( isdefined( player.reviveprogressbar ) )
                player.reviveprogressbar maps\mp\gametypes_zm\_hud_util::destroyelem();

            if ( isdefined( player.revivetexthud ) )
                player.revivetexthud destroy();
        }
    }
}

spawnspectator()
{
    self endon( "disconnect" );
    self endon( "spawned_spectator" );
    self notify( "spawned" );
    self notify( "end_respawn" );

    if ( level.intermission )
        return;

    if ( isdefined( level.no_spectator ) && level.no_spectator )
    {
        wait 3;
        exitlevel();
    }

    self.is_zombie = 1;
    level thread failsafe_revive_give_back_weapons( self );
    self notify( "zombified" );

    if ( isdefined( self.revivetrigger ) )
    {
        self.revivetrigger delete();
        self.revivetrigger = undefined;
    }

    self.zombification_time = gettime();
    resettimeout();
    self stopshellshock();
    self stoprumble( "damage_heavy" );
    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.maxhealth = self.health;
    self.shellshocked = 0;
    self.inwater = 0;
    self.friendlydamage = undefined;
    self.hasspawned = 1;
    self.spawntime = gettime();
    self.afk = 0;
/#
    println( "*************************Zombie Spectator***" );
#/
    self detachall();

    if ( isdefined( level.custom_spectate_permissions ) )
        self [[ level.custom_spectate_permissions ]]();
    else
        self setspectatepermissions( 1 );

    self thread spectator_thread();
    self spawn( self.origin, self.angles );
    self notify( "spawned_spectator" );
}

setspectatepermissions( ison )
{
    self allowspectateteam( "allies", ison && self.team == "allies" );
    self allowspectateteam( "axis", ison && self.team == "axis" );
    self allowspectateteam( "freelook", 0 );
    self allowspectateteam( "none", 0 );
}

spectator_thread()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );
}

spectator_toggle_3rd_person()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );
    third_person = 1;
    self set_third_person( 1 );
}

set_third_person( value )
{
    if ( value )
    {
        self setclientthirdperson( 1 );
        self setclientthirdpersonangle( 354 );
        self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
    }
    else
    {
        self setclientthirdperson( 0 );
        self setclientthirdpersonangle( 0 );
        self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
    }

    self resetfov();
}

last_stand_revive()
{
    level endon( "between_round_over" );
    players = get_players();
    laststand_count = 0;

    foreach ( player in players )
    {
        if ( !is_player_valid( player ) )
            laststand_count++;
    }

    if ( laststand_count == players.size )
    {
        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() && players[i].revivetrigger.beingrevived == 0 )
                players[i] maps\mp\zombies\_zm_laststand::auto_revive( players[i] );
        }
    }
}

last_stand_pistol_rank_init()
{
    level.pistol_values = [];
    level.pistol_values[level.pistol_values.size] = "m1911_zm";
    level.pistol_values[level.pistol_values.size] = "c96_zm";
    level.pistol_values[level.pistol_values.size] = "cz75_zm";
    level.pistol_values[level.pistol_values.size] = "cz75dw_zm";
    level.pistol_values[level.pistol_values.size] = "kard_zm";
    level.pistol_values[level.pistol_values.size] = "fiveseven_zm";
    level.pistol_values[level.pistol_values.size] = "beretta93r_zm";
    level.pistol_values[level.pistol_values.size] = "beretta93r_extclip_zm";
    level.pistol_values[level.pistol_values.size] = "fivesevendw_zm";
    level.pistol_values[level.pistol_values.size] = "rnma_zm";
    level.pistol_values[level.pistol_values.size] = "python_zm";
    level.pistol_values[level.pistol_values.size] = "judge_zm";
    level.pistol_values[level.pistol_values.size] = "cz75_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "cz75dw_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "kard_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "fiveseven_upgraded_zm";
    level.pistol_value_solo_replace_below = level.pistol_values.size - 1;
    level.pistol_values[level.pistol_values.size] = "m1911_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "c96_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "beretta93r_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "beretta93r_extclip_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "fivesevendw_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "rnma_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "python_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "judge_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "ray_gun_zm";
    level.pistol_values[level.pistol_values.size] = "raygun_mark2_zm";
    level.pistol_values[level.pistol_values.size] = "freezegun_zm";
    level.pistol_values[level.pistol_values.size] = "ray_gun_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "raygun_mark2_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "freezegun_upgraded_zm";
    level.pistol_values[level.pistol_values.size] = "microwavegundw_zm";
    level.pistol_values[level.pistol_values.size] = "microwavegundw_upgraded_zm";
}

last_stand_pistol_swap()
{
    if ( self has_powerup_weapon() )
        self.lastactiveweapon = "none";

    if ( !self hasweapon( self.laststandpistol ) )
        self giveweapon( self.laststandpistol );

    ammoclip = weaponclipsize( self.laststandpistol );
    doubleclip = ammoclip * 2;

    if ( isdefined( self._special_solo_pistol_swap ) && self._special_solo_pistol_swap || self.laststandpistol == level.default_solo_laststandpistol && !self.hadpistol )
    {
        self._special_solo_pistol_swap = 0;
        self.hadpistol = 0;
        self setweaponammostock( self.laststandpistol, doubleclip );
    }
    else if ( flag( "solo_game" ) && self.laststandpistol == level.default_solo_laststandpistol )
        self setweaponammostock( self.laststandpistol, doubleclip );
    else if ( self.laststandpistol == level.default_laststandpistol )
        self setweaponammostock( self.laststandpistol, doubleclip );
    else if ( self.laststandpistol == "ray_gun_zm" || self.laststandpistol == "ray_gun_upgraded_zm" )
    {
        if ( self.stored_weapon_info[self.laststandpistol].total_amt >= ammoclip )
        {
            self setweaponammoclip( self.laststandpistol, ammoclip );
            self.stored_weapon_info[self.laststandpistol].given_amt = ammoclip;
        }
        else
        {
            self setweaponammoclip( self.laststandpistol, self.stored_weapon_info[self.laststandpistol].total_amt );
            self.stored_weapon_info[self.laststandpistol].given_amt = self.stored_weapon_info[self.laststandpistol].total_amt;
        }

        self setweaponammostock( self.laststandpistol, 0 );
    }
    else if ( self.stored_weapon_info[self.laststandpistol].stock_amt >= doubleclip )
    {
        self setweaponammostock( self.laststandpistol, doubleclip );
        self.stored_weapon_info[self.laststandpistol].given_amt = doubleclip + self.stored_weapon_info[self.laststandpistol].clip_amt + self.stored_weapon_info[self.laststandpistol].left_clip_amt;
    }
    else
    {
        self setweaponammostock( self.laststandpistol, self.stored_weapon_info[self.laststandpistol].stock_amt );
        self.stored_weapon_info[self.laststandpistol].given_amt = self.stored_weapon_info[self.laststandpistol].total_amt;
    }

    self switchtoweapon( self.laststandpistol );
}

last_stand_best_pistol()
{
    pistol_array = [];
    current_weapons = self getweaponslistprimaries();

    for ( i = 0; i < current_weapons.size; i++ )
    {
        class = weaponclass( current_weapons[i] );

        if ( issubstr( current_weapons[i], "knife_ballistic_" ) )
            class = "knife";

        if ( class == "pistol" || class == "pistolspread" || class == "pistol spread" )
        {
            if ( current_weapons[i] != level.default_laststandpistol && !flag( "solo_game" ) || !flag( "solo_game" ) && current_weapons[i] != level.default_solo_laststandpistol )
            {
                if ( self getammocount( current_weapons[i] ) <= 0 )
                    continue;
            }

            pistol_array_index = pistol_array.size;
            pistol_array[pistol_array_index] = spawnstruct();
            pistol_array[pistol_array_index].gun = current_weapons[i];
            pistol_array[pistol_array_index].value = 0;

            for ( j = 0; j < level.pistol_values.size; j++ )
            {
                if ( level.pistol_values[j] == current_weapons[i] )
                {
                    pistol_array[pistol_array_index].value = j;
                    break;
                }
            }
        }
    }

    self.laststandpistol = last_stand_compare_pistols( pistol_array );
}

last_stand_compare_pistols( struct_array )
{
    if ( !isarray( struct_array ) || struct_array.size <= 0 )
    {
        self.hadpistol = 0;

        if ( isdefined( self.stored_weapon_info ) )
        {
            stored_weapon_info = getarraykeys( self.stored_weapon_info );

            for ( j = 0; j < stored_weapon_info.size; j++ )
            {
                if ( stored_weapon_info[j] == level.laststandpistol )
                    self.hadpistol = 1;
            }
        }

        return level.laststandpistol;
    }

    highest_score_pistol = struct_array[0];

    for ( i = 1; i < struct_array.size; i++ )
    {
        if ( struct_array[i].value > highest_score_pistol.value )
            highest_score_pistol = struct_array[i];
    }

    if ( flag( "solo_game" ) )
    {
        self._special_solo_pistol_swap = 0;

        if ( highest_score_pistol.value <= level.pistol_value_solo_replace_below )
        {
            self.hadpistol = 0;
            self._special_solo_pistol_swap = 1;

            if ( isdefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive && ( !self hasperk( "specialty_quickrevive" ) && !self hasperk( "specialty_quickrevive" ) ) )
                return highest_score_pistol.gun;
            else
                return level.laststandpistol;
        }
        else
            return highest_score_pistol.gun;
    }
    else
        return highest_score_pistol.gun;
}

last_stand_save_pistol_ammo()
{
    weapon_inventory = self getweaponslist( 1 );
    self.stored_weapon_info = [];

    for ( i = 0; i < weapon_inventory.size; i++ )
    {
        weapon = weapon_inventory[i];
        class = weaponclass( weapon );

        if ( issubstr( weapon, "knife_ballistic_" ) )
            class = "knife";

        if ( class == "pistol" || class == "pistolspread" || class == "pistol spread" )
        {
            self.stored_weapon_info[weapon] = spawnstruct();
            self.stored_weapon_info[weapon].clip_amt = self getweaponammoclip( weapon );
            self.stored_weapon_info[weapon].left_clip_amt = 0;
            dual_wield_name = weapondualwieldweaponname( weapon );

            if ( "none" != dual_wield_name )
                self.stored_weapon_info[weapon].left_clip_amt = self getweaponammoclip( dual_wield_name );

            self.stored_weapon_info[weapon].stock_amt = self getweaponammostock( weapon );
            self.stored_weapon_info[weapon].total_amt = self.stored_weapon_info[weapon].clip_amt + self.stored_weapon_info[weapon].left_clip_amt + self.stored_weapon_info[weapon].stock_amt;
            self.stored_weapon_info[weapon].given_amt = 0;
        }
    }

    self last_stand_best_pistol();
}

last_stand_restore_pistol_ammo()
{
    self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;

    if ( !isdefined( self.stored_weapon_info ) )
        return;

    weapon_inventory = self getweaponslist( 1 );
    weapon_to_restore = getarraykeys( self.stored_weapon_info );

    for ( i = 0; i < weapon_inventory.size; i++ )
    {
        weapon = weapon_inventory[i];

        if ( weapon != self.laststandpistol )
            continue;

        for ( j = 0; j < weapon_to_restore.size; j++ )
        {
            check_weapon = weapon_to_restore[j];

            if ( weapon == check_weapon )
            {
                dual_wield_name = weapondualwieldweaponname( weapon_to_restore[j] );

                if ( weapon != level.default_laststandpistol )
                {
                    last_clip = self getweaponammoclip( weapon );
                    last_left_clip = 0;

                    if ( "none" != dual_wield_name )
                        last_left_clip = self getweaponammoclip( dual_wield_name );

                    last_stock = self getweaponammostock( weapon );
                    last_total = last_clip + last_left_clip + last_stock;
                    used_amt = self.stored_weapon_info[weapon].given_amt - last_total;

                    if ( used_amt >= self.stored_weapon_info[weapon].stock_amt )
                    {
                        used_amt -= self.stored_weapon_info[weapon].stock_amt;
                        self.stored_weapon_info[weapon].stock_amt = 0;
                        self.stored_weapon_info[weapon].clip_amt -= used_amt;

                        if ( self.stored_weapon_info[weapon].clip_amt < 0 )
                            self.stored_weapon_info[weapon].clip_amt = 0;
                    }
                    else
                    {
                        new_stock_amt = self.stored_weapon_info[weapon].stock_amt - used_amt;

                        if ( new_stock_amt < self.stored_weapon_info[weapon].stock_amt )
                            self.stored_weapon_info[weapon].stock_amt = new_stock_amt;
                    }
                }

                self setweaponammoclip( weapon_to_restore[j], self.stored_weapon_info[weapon_to_restore[j]].clip_amt );

                if ( "none" != dual_wield_name )
                    self setweaponammoclip( dual_wield_name, self.stored_weapon_info[weapon_to_restore[j]].left_clip_amt );

                self setweaponammostock( weapon_to_restore[j], self.stored_weapon_info[weapon_to_restore[j]].stock_amt );
                break;
            }
        }
    }
}

last_stand_take_thrown_grenade()
{
    self endon( "disconnect" );
    self endon( "bled_out" );
    self endon( "player_revived" );

    self waittill( "grenade_fire", grenade, weaponname );

    if ( isdefined( self.lsgsar_lethal ) && weaponname == self.lsgsar_lethal )
        self.lsgsar_lethal_nade_amt--;

    if ( isdefined( self.lsgsar_tactical ) && weaponname == self.lsgsar_tactical )
        self.lsgsar_tactical_nade_amt--;
}

last_stand_grenade_save_and_return()
{
    if ( isdefined( level.isresetting_grief ) && level.isresetting_grief )
        return;

    self endon( "disconnect" );
    self endon( "bled_out" );
    level endon( "between_round_over" );
    self.lsgsar_lethal_nade_amt = 0;
    self.lsgsar_has_lethal_nade = 0;
    self.lsgsar_tactical_nade_amt = 0;
    self.lsgsar_has_tactical_nade = 0;
    self.lsgsar_lethal = undefined;
    self.lsgsar_tactical = undefined;

    if ( self isthrowinggrenade() )
        self thread last_stand_take_thrown_grenade();

    weapons_on_player = self getweaponslist( 1 );

    for ( i = 0; i < weapons_on_player.size; i++ )
    {
        if ( self is_player_lethal_grenade( weapons_on_player[i] ) )
        {
            self.lsgsar_has_lethal_nade = 1;
            self.lsgsar_lethal = self get_player_lethal_grenade();
            self.lsgsar_lethal_nade_amt = self getweaponammoclip( self get_player_lethal_grenade() );
            self setweaponammoclip( self get_player_lethal_grenade(), 0 );
            self takeweapon( self get_player_lethal_grenade() );
            continue;
        }

        if ( self is_player_tactical_grenade( weapons_on_player[i] ) )
        {
            self.lsgsar_has_tactical_nade = 1;
            self.lsgsar_tactical = self get_player_tactical_grenade();
            self.lsgsar_tactical_nade_amt = self getweaponammoclip( self get_player_tactical_grenade() );
            self setweaponammoclip( self get_player_tactical_grenade(), 0 );
            self takeweapon( self get_player_tactical_grenade() );
        }
    }

    self waittill( "player_revived" );

    if ( self.lsgsar_has_lethal_nade )
    {
        self set_player_lethal_grenade( self.lsgsar_lethal );
        self giveweapon( self.lsgsar_lethal );
        self setweaponammoclip( self.lsgsar_lethal, self.lsgsar_lethal_nade_amt );
    }

    if ( self.lsgsar_has_tactical_nade )
    {
        self set_player_tactical_grenade( self.lsgsar_tactical );
        self giveweapon( self.lsgsar_tactical );
        self setweaponammoclip( self.lsgsar_tactical, self.lsgsar_tactical_nade_amt );
    }

    self.lsgsar_lethal_nade_amt = undefined;
    self.lsgsar_has_lethal_nade = undefined;
    self.lsgsar_tactical_nade_amt = undefined;
    self.lsgsar_has_tactical_nade = undefined;
    self.lsgsar_lethal = undefined;
    self.lsgsar_tactical = undefined;
}

spectators_respawn()
{
    level endon( "between_round_over" );

    if ( !isdefined( level.zombie_vars["spectators_respawn"] ) || !level.zombie_vars["spectators_respawn"] )
        return;

    if ( !isdefined( level.custom_spawnplayer ) )
        level.custom_spawnplayer = ::spectator_respawn;

    while ( true )
    {
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i].sessionstate == "spectator" && isdefined( players[i].spectator_respawn ) )
            {
                players[i] [[ level.spawnplayer ]]();
                thread refresh_player_navcard_hud();

                if ( isdefined( level.script ) && level.round_number > 6 && players[i].score < 1500 )
                {
                    players[i].old_score = players[i].score;

                    if ( isdefined( level.spectator_respawn_custom_score ) )
                        players[i] [[ level.spectator_respawn_custom_score ]]();

                    players[i].score = 1500;
                }
            }
        }

        wait 1;
    }
}

spectator_respawn()
{
/#
    println( "*************************Respawn Spectator***" );
#/
/#
    assert( isdefined( self.spectator_respawn ) );
#/
    origin = self.spectator_respawn.origin;
    angles = self.spectator_respawn.angles;
    self setspectatepermissions( 0 );
    new_origin = undefined;

    if ( isdefined( level.check_valid_spawn_override ) )
        new_origin = [[ level.check_valid_spawn_override ]]( self );

    if ( !isdefined( new_origin ) )
        new_origin = check_for_valid_spawn_near_team( self, 1 );

    if ( isdefined( new_origin ) )
    {
        if ( !isdefined( new_origin.angles ) )
            angles = ( 0, 0, 0 );
        else
            angles = new_origin.angles;

        self spawn( new_origin.origin, angles );
    }
    else
        self spawn( origin, angles );

    if ( isdefined( self get_player_placeable_mine() ) )
    {
        self takeweapon( self get_player_placeable_mine() );
        self set_player_placeable_mine( undefined );
    }

    self maps\mp\zombies\_zm_equipment::equipment_take();
    self.is_burning = undefined;
    self.abilities = [];
    self.is_zombie = 0;
    self.ignoreme = 0;
    setclientsysstate( "lsm", "0", self );
    self reviveplayer();
    self notify( "spawned_player" );

    if ( isdefined( level._zombiemode_post_respawn_callback ) )
        self thread [[ level._zombiemode_post_respawn_callback ]]();

    self maps\mp\zombies\_zm_score::player_reduce_points( "died" );
    self maps\mp\zombies\_zm_melee_weapon::spectator_respawn_all();
    claymore_triggers = getentarray( "claymore_purchase", "targetname" );

    for ( i = 0; i < claymore_triggers.size; i++ )
    {
        claymore_triggers[i] setvisibletoplayer( self );
        claymore_triggers[i].claymores_triggered = 0;
    }

    self thread player_zombie_breadcrumb();
    self thread return_retained_perks();
    return 1;
}

check_for_valid_spawn_near_team( revivee, return_struct )
{
    if ( isdefined( level.check_for_valid_spawn_near_team_callback ) )
    {
        spawn_location = [[ level.check_for_valid_spawn_near_team_callback ]]( revivee, return_struct );
        return spawn_location;
    }
    else
    {
        players = get_players();
        spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();
        closest_group = undefined;
        closest_distance = 100000000;
        backup_group = undefined;
        backup_distance = 100000000;

        if ( spawn_points.size == 0 )
            return undefined;

        for ( i = 0; i < players.size; i++ )
        {
            if ( is_player_valid( players[i], undefined, 1 ) && players[i] != self )
            {
                for ( j = 0; j < spawn_points.size; j++ )
                {
                    if ( isdefined( spawn_points[j].script_int ) )
                        ideal_distance = spawn_points[j].script_int;
                    else
                        ideal_distance = 1000;

                    if ( spawn_points[j].locked == 0 )
                    {
                        plyr_dist = distancesquared( players[i].origin, spawn_points[j].origin );

                        if ( plyr_dist < ideal_distance * ideal_distance )
                        {
                            if ( plyr_dist < closest_distance )
                            {
                                closest_distance = plyr_dist;
                                closest_group = j;
                            }

                            continue;
                        }

                        if ( plyr_dist < backup_distance )
                        {
                            backup_group = j;
                            backup_distance = plyr_dist;
                        }
                    }
                }
            }

            if ( !isdefined( closest_group ) )
                closest_group = backup_group;

            if ( isdefined( closest_group ) )
            {
                spawn_location = get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct );

                if ( isdefined( spawn_location ) )
                    return spawn_location;
            }
        }

        return undefined;
    }
}

get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct )
{
    spawn_array = getstructarray( spawn_points[closest_group].target, "targetname" );
    spawn_array = array_randomize( spawn_array );

    for ( k = 0; k < spawn_array.size; k++ )
    {
        if ( isdefined( spawn_array[k].plyr ) && spawn_array[k].plyr == revivee getentitynumber() )
        {
            if ( positionwouldtelefrag( spawn_array[k].origin ) )
            {
                spawn_array[k].plyr = undefined;
                break;
                continue;
            }

            if ( isdefined( return_struct ) && return_struct )
            {
                return spawn_array[k];
                continue;
            }

            return spawn_array[k].origin;
        }
    }

    for ( k = 0; k < spawn_array.size; k++ )
    {
        if ( positionwouldtelefrag( spawn_array[k].origin ) )
            continue;

        if ( !isdefined( spawn_array[k].plyr ) || spawn_array[k].plyr == revivee getentitynumber() )
        {
            spawn_array[k].plyr = revivee getentitynumber();

            if ( isdefined( return_struct ) && return_struct )
            {
                return spawn_array[k];
                continue;
            }

            return spawn_array[k].origin;
        }
    }

    if ( isdefined( return_struct ) && return_struct )
        return spawn_array[0];

    return spawn_array[0].origin;
}

check_for_valid_spawn_near_position( revivee, v_position, return_struct )
{
    spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

    if ( spawn_points.size == 0 )
        return undefined;

    closest_group = undefined;
    closest_distance = 100000000;
    backup_group = undefined;
    backup_distance = 100000000;

    for ( i = 0; i < spawn_points.size; i++ )
    {
        if ( isdefined( spawn_points[i].script_int ) )
            ideal_distance = spawn_points[i].script_int;
        else
            ideal_distance = 1000;

        if ( spawn_points[i].locked == 0 )
        {
            dist = distancesquared( v_position, spawn_points[i].origin );

            if ( dist < ideal_distance * ideal_distance )
            {
                if ( dist < closest_distance )
                {
                    closest_distance = dist;
                    closest_group = i;
                }
            }
            else if ( dist < backup_distance )
            {
                backup_group = i;
                backup_distance = dist;
            }
        }

        if ( !isdefined( closest_group ) )
            closest_group = backup_group;
    }

    if ( isdefined( closest_group ) )
    {
        spawn_location = get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct );

        if ( isdefined( spawn_location ) )
            return spawn_location;
    }

    return undefined;
}

check_for_valid_spawn_within_range( revivee, v_position, return_struct, min_distance, max_distance )
{
    spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

    if ( spawn_points.size == 0 )
        return undefined;

    closest_group = undefined;
    closest_distance = 100000000;

    for ( i = 0; i < spawn_points.size; i++ )
    {
        if ( spawn_points[i].locked == 0 )
        {
            dist = distance( v_position, spawn_points[i].origin );

            if ( dist >= min_distance && dist <= max_distance )
            {
                if ( dist < closest_distance )
                {
                    closest_distance = dist;
                    closest_group = i;
                }
            }
        }
    }

    if ( isdefined( closest_group ) )
    {
        spawn_location = get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct );

        if ( isdefined( spawn_location ) )
            return spawn_location;
    }

    return undefined;
}

get_players_on_team( exclude )
{
    teammates = [];
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i].spawn_side == self.spawn_side && !isdefined( players[i].revivetrigger ) && players[i] != exclude )
            teammates[teammates.size] = players[i];
    }

    return teammates;
}

get_safe_breadcrumb_pos( player )
{
    players = get_players();
    valid_players = [];
    min_dist = 22500;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !is_player_valid( players[i] ) )
            continue;

        valid_players[valid_players.size] = players[i];
    }

    for ( i = 0; i < valid_players.size; i++ )
    {
        count = 0;

        for ( q = 1; q < player.zombie_breadcrumbs.size; q++ )
        {
            if ( distancesquared( player.zombie_breadcrumbs[q], valid_players[i].origin ) < min_dist )
                continue;

            count++;

            if ( count == valid_players.size )
                return player.zombie_breadcrumbs[q];
        }
    }

    return undefined;
}

default_max_zombie_func( max_num )
{
/#
    count = getdvarint( _hash_CF687B54 );

    if ( count > -1 )
        return count;
#/
    max = max_num;

    if ( level.round_number < 2 )
        max = int( max_num * 0.25 );
    else if ( level.round_number < 3 )
        max = int( max_num * 0.3 );
    else if ( level.round_number < 4 )
        max = int( max_num * 0.5 );
    else if ( level.round_number < 5 )
        max = int( max_num * 0.7 );
    else if ( level.round_number < 6 )
        max = int( max_num * 0.9 );

    return max;
}

round_spawning()
{
    level endon( "intermission" );
    level endon( "end_of_round" );
    level endon( "restart_round" );
/#
    level endon( "kill_round" );
#/
    if ( level.intermission )
        return;
/#
    if ( getdvarint( _hash_FA81816F ) == 2 || getdvarint( _hash_FA81816F ) >= 4 )
        return;
#/
    if ( level.zombie_spawn_locations.size < 1 )
    {
/#
        assertmsg( "No active spawners in the map.  Check to see if the zone is active and if it's pointing to spawners." );
#/
        return;
    }

    ai_calculate_health( level.round_number );
    count = 0;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i].zombification_time = 0;

    max = level.zombie_vars["zombie_max_ai"];
    multiplier = level.round_number / 5;

    if ( multiplier < 1 )
        multiplier = 1;

    if ( level.round_number >= 10 )
        multiplier *= ( level.round_number * 0.15 );

    player_num = get_players().size;

    if ( player_num == 1 )
        max += int( 0.5 * level.zombie_vars["zombie_ai_per_player"] * multiplier );
    else
        max += int( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] * multiplier );

    if ( !isdefined( level.max_zombie_func ) )
        level.max_zombie_func = ::default_max_zombie_func;

    if ( !( isdefined( level.kill_counter_hud ) && level.zombie_total > 0 ) )
    {
        level.zombie_total = [[ level.max_zombie_func ]]( max );
        level notify( "zombie_total_set" );
    }

    if ( isdefined( level.zombie_total_set_func ) )
        level thread [[ level.zombie_total_set_func ]]();

    if ( level.round_number < 10 || level.speed_change_max > 0 )
        level thread zombie_speed_up();

    mixed_spawns = 0;
    old_spawn = undefined;

    while ( true )
    {
        while ( get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
            wait 0.1;

        while ( get_current_actor_count() >= level.zombie_actor_limit )
        {
            clear_all_corpses();
            wait 0.1;
        }

        flag_wait( "spawn_zombies" );

        while ( level.zombie_spawn_locations.size <= 0 )
            wait 0.1;

        run_custom_ai_spawn_checks();
        spawn_point = level.zombie_spawn_locations[randomint( level.zombie_spawn_locations.size )];

        if ( !isdefined( old_spawn ) )
            old_spawn = spawn_point;
        else if ( spawn_point == old_spawn )
            spawn_point = level.zombie_spawn_locations[randomint( level.zombie_spawn_locations.size )];

        old_spawn = spawn_point;

        if ( isdefined( level.mixed_rounds_enabled ) && level.mixed_rounds_enabled == 1 )
        {
            spawn_dog = 0;

            if ( level.round_number > 30 )
            {
                if ( randomint( 100 ) < 3 )
                    spawn_dog = 1;
            }
            else if ( level.round_number > 25 && mixed_spawns < 3 )
            {
                if ( randomint( 100 ) < 2 )
                    spawn_dog = 1;
            }
            else if ( level.round_number > 20 && mixed_spawns < 2 )
            {
                if ( randomint( 100 ) < 2 )
                    spawn_dog = 1;
            }
            else if ( level.round_number > 15 && mixed_spawns < 1 )
            {
                if ( randomint( 100 ) < 1 )
                    spawn_dog = 1;
            }

            if ( spawn_dog )
            {
                keys = getarraykeys( level.zones );

                for ( i = 0; i < keys.size; i++ )
                {
                    if ( level.zones[keys[i]].is_occupied )
                    {
                        akeys = getarraykeys( level.zones[keys[i]].adjacent_zones );

                        for ( k = 0; k < akeys.size; k++ )
                        {
                            if ( level.zones[akeys[k]].is_active && !level.zones[akeys[k]].is_occupied && level.zones[akeys[k]].dog_locations.size > 0 )
                            {
                                maps\mp\zombies\_zm_ai_dogs::special_dog_spawn( undefined, 1 );
                                level.zombie_total--;
                                wait_network_frame();
                            }
                        }
                    }
                }
            }
        }

        if ( isdefined( level.zombie_spawners ) )
        {
            if ( isdefined( level.use_multiple_spawns ) && level.use_multiple_spawns )
            {
                if ( isdefined( spawn_point.script_int ) )
                {
                    if ( isdefined( level.zombie_spawn[spawn_point.script_int] ) && level.zombie_spawn[spawn_point.script_int].size )
                        spawner = random( level.zombie_spawn[spawn_point.script_int] );
                    else
                    {
/#
                        assertmsg( "Wanting to spawn from zombie group " + spawn_point.script_int + "but it doens't exist" );
#/
                    }
                }
                else if ( isdefined( level.zones[spawn_point.zone_name].script_int ) && level.zones[spawn_point.zone_name].script_int )
                    spawner = random( level.zombie_spawn[level.zones[spawn_point.zone_name].script_int] );
                else if ( isdefined( level.spawner_int ) && ( isdefined( level.zombie_spawn[level.spawner_int].size ) && level.zombie_spawn[level.spawner_int].size ) )
                    spawner = random( level.zombie_spawn[level.spawner_int] );
                else
                    spawner = random( level.zombie_spawners );
            }
            else
                spawner = random( level.zombie_spawners );

            ai = spawn_zombie( spawner, spawner.targetname, spawn_point );
        }

        if ( isdefined( ai ) )
        {
            level.zombie_total--;
            ai thread round_spawn_failsafe();
            count++;
        }

        wait( level.zombie_vars["zombie_spawn_delay"] );
        wait_network_frame();
    }
}

run_custom_ai_spawn_checks()
{
    foreach ( str_id, s in level.custom_ai_spawn_check_funcs )
    {
        if ( [[ s.func_check ]]() )
        {
            a_spawners = [[ s.func_get_spawners ]]();
            level.zombie_spawners = arraycombine( level.zombie_spawners, a_spawners, 0, 0 );

            if ( isdefined( level.use_multiple_spawns ) && level.use_multiple_spawns )
            {
                foreach ( sp in a_spawners )
                {
                    if ( isdefined( sp.script_int ) )
                    {
                        if ( !isdefined( level.zombie_spawn[sp.script_int] ) )
                            level.zombie_spawn[sp.script_int] = [];

                        if ( !isinarray( level.zombie_spawn[sp.script_int], sp ) )
                            level.zombie_spawn[sp.script_int][level.zombie_spawn[sp.script_int].size] = sp;
                    }
                }
            }

            if ( isdefined( s.func_get_locations ) )
            {
                a_locations = [[ s.func_get_locations ]]();
                level.zombie_spawn_locations = arraycombine( level.zombie_spawn_locations, a_locations, 0, 0 );
            }

            continue;
        }

        a_spawners = [[ s.func_get_spawners ]]();

        foreach ( sp in a_spawners )
            arrayremovevalue( level.zombie_spawners, sp );

        if ( isdefined( level.use_multiple_spawns ) && level.use_multiple_spawns )
        {
            foreach ( sp in a_spawners )
            {
                if ( isdefined( sp.script_int ) && isdefined( level.zombie_spawn[sp.script_int] ) )
                    arrayremovevalue( level.zombie_spawn[sp.script_int], sp );
            }
        }

        if ( isdefined( s.func_get_locations ) )
        {
            a_locations = [[ s.func_get_locations ]]();

            foreach ( s_loc in a_locations )
                arrayremovevalue( level.zombie_spawn_locations, s_loc );
        }
    }
}

register_custom_ai_spawn_check( str_id, func_check, func_get_spawners, func_get_locations )
{
    if ( !isdefined( level.custom_ai_spawn_check_funcs[str_id] ) )
        level.custom_ai_spawn_check_funcs[str_id] = spawnstruct();

    level.custom_ai_spawn_check_funcs[str_id].func_check = func_check;
    level.custom_ai_spawn_check_funcs[str_id].func_get_spawners = func_get_spawners;
    level.custom_ai_spawn_check_funcs[str_id].func_get_locations = func_get_locations;
}

zombie_speed_up()
{
    if ( level.round_number <= 3 )
        return;

    level endon( "intermission" );
    level endon( "end_of_round" );
    level endon( "restart_round" );
/#
    level endon( "kill_round" );
#/
    while ( level.zombie_total > 4 )
        wait 2.0;

    for ( num_zombies = get_current_zombie_count(); num_zombies > 3; num_zombies = get_current_zombie_count() )
        wait 2.0;

    for ( zombies = get_round_enemy_array(); zombies.size > 0; zombies = get_round_enemy_array() )
    {
        if ( zombies.size == 1 && ( isdefined( zombies[0].has_legs ) && zombies[0].has_legs ) )
        {
            if ( isdefined( level.zombie_speed_up ) )
                zombies[0] thread [[ level.zombie_speed_up ]]();
            else if ( zombies[0].zombie_move_speed != "sprint" )
            {
                zombies[0] set_zombie_run_cycle( "sprint" );
                zombies[0].zombie_move_speed_original = zombies[0].zombie_move_speed;
            }
        }

        wait 0.5;
    }
}

round_spawning_test()
{
    while ( true )
    {
        spawn_point = level.zombie_spawn_locations[randomint( level.zombie_spawn_locations.size )];
        spawner = random( level.zombie_spawners );
        ai = spawn_zombie( spawner, spawner.targetname, spawn_point );

        ai waittill( "death" );

        wait 5;
    }
}

round_pause( delay )
{
    if ( !isdefined( delay ) )
        delay = 30;

    level.countdown_hud = create_counter_hud();
    level.countdown_hud setvalue( delay );
    level.countdown_hud.color = ( 1, 1, 1 );
    level.countdown_hud.alpha = 1;
    level.countdown_hud fadeovertime( 2.0 );
    wait 2.0;
    level.countdown_hud.color = vectorscale( ( 1, 0, 0 ), 0.21 );
    level.countdown_hud fadeovertime( 3.0 );
    wait 3;

    while ( delay >= 1 )
    {
        wait 1;
        delay--;
        level.countdown_hud setvalue( delay );
    }

    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] playlocalsound( "zmb_perks_packa_ready" );

    level.countdown_hud fadeovertime( 1.0 );
    level.countdown_hud.color = ( 1, 1, 1 );
    level.countdown_hud.alpha = 0;
    wait 1.0;
    level.countdown_hud destroy_hud();
}

round_start()
{
/#
    println( "ZM >> round_start start" );
#/
    if ( isdefined( level.round_prestart_func ) )
        [[ level.round_prestart_func ]]();
    else
    {
        n_delay = 2;

        if ( isdefined( level.zombie_round_start_delay ) )
            n_delay = level.zombie_round_start_delay;

        wait( n_delay );
    }

    level.zombie_health = level.zombie_vars["zombie_health_start"];

    if ( getdvarint( "scr_writeConfigStrings" ) == 1 )
    {
        wait 5;
        exitlevel();
        return;
    }

    if ( level.zombie_vars["game_start_delay"] > 0 )
        round_pause( level.zombie_vars["game_start_delay"] );

    flag_set( "begin_spawning" );

    if ( !isdefined( level.round_spawn_func ) )
        level.round_spawn_func = ::round_spawning;
/#
    if ( getdvarint( _hash_7688603C ) )
        level.round_spawn_func = ::round_spawning_test;
#/
    if ( !isdefined( level.round_wait_func ) )
        level.round_wait_func = ::round_wait;

    if ( !isdefined( level.round_think_func ) )
        level.round_think_func = ::round_think;

    level thread [[ level.round_think_func ]]();
}

play_door_dialog()
{
    level endon( "power_on" );
    self endon( "warning_dialog" );
    timer = 0;

    while ( true )
    {
        wait 0.05;
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            dist = distancesquared( players[i].origin, self.origin );

            if ( dist > 4900 )
            {
                timer = 0;
                continue;
            }

            while ( dist < 4900 && timer < 3 )
            {
                wait 0.5;
                timer++;
            }

            if ( dist > 4900 && timer >= 3 )
            {
                self playsound( "door_deny" );
                players[i] maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "door_deny" );
                wait 3;
                self notify( "warning_dialog" );
            }
        }
    }
}

wait_until_first_player()
{
    players = get_players();

    if ( !isdefined( players[0] ) )
        level waittill( "first_player_ready" );
}

round_one_up()
{
    level endon( "end_game" );

    if ( isdefined( level.noroundnumber ) && level.noroundnumber == 1 )
        return;

    if ( !isdefined( level.doground_nomusic ) )
        level.doground_nomusic = 0;

    if ( level.first_round )
    {
        intro = 1;

        if ( isdefined( level._custom_intro_vox ) )
            level thread [[ level._custom_intro_vox ]]();
        else
            level thread play_level_start_vox_delayed();
    }
    else
        intro = 0;

    if ( level.round_number == 5 || level.round_number == 10 || level.round_number == 20 || level.round_number == 35 || level.round_number == 50 )
    {
        players = get_players();
        rand = randomintrange( 0, players.size );
        players[rand] thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "round_" + level.round_number );
    }

    if ( intro )
    {
        if ( isdefined( level.host_ended_game ) && level.host_ended_game )
            return;

        wait 6.25;
        level notify( "intro_hud_done" );
        wait 2;
    }
    else
        wait 2.5;

    reportmtu( level.round_number );
}

round_over()
{
    if ( isdefined( level.noroundnumber ) && level.noroundnumber == 1 )
        return;

    time = level.zombie_vars["zombie_between_round_time"];
    players = getplayers();

    for ( player_index = 0; player_index < players.size; player_index++ )
    {
        if ( !isdefined( players[player_index].pers["previous_distance_traveled"] ) )
            players[player_index].pers["previous_distance_traveled"] = 0;

        distancethisround = int( players[player_index].pers["distance_traveled"] - players[player_index].pers["previous_distance_traveled"] );
        players[player_index].pers["previous_distance_traveled"] = players[player_index].pers["distance_traveled"];
        players[player_index] incrementplayerstat( "distance_traveled", distancethisround );

        if ( players[player_index].pers["team"] != "spectator" )
        {
            zonename = players[player_index] get_current_zone();

            if ( isdefined( zonename ) )
                players[player_index] recordzombiezone( "endingZone", zonename );
        }
    }

    recordzombieroundend();
    wait( time );
}

round_think( restart )
{
    if ( !isdefined( restart ) )
        restart = 0;
/#
    println( "ZM >> round_think start" );
#/
    level endon( "end_round_think" );

    if ( !( isdefined( restart ) && restart ) )
    {
        if ( isdefined( level.initial_round_wait_func ) )
            [[ level.initial_round_wait_func ]]();

        if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
        {
            players = get_players();

            foreach ( player in players )
            {
                if ( !( isdefined( player.hostmigrationcontrolsfrozen ) && player.hostmigrationcontrolsfrozen ) )
                {
                    player freezecontrols( 0 );
/#
                    println( " Unfreeze controls 8" );
#/
                }

                player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
            }
        }
    }

    setroundsplayed( level.round_number );

    for (;;)
    {
        maxreward = 50 * level.round_number;

        if ( maxreward > 500 )
            maxreward = 500;

        level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
        level.pro_tips_start_time = gettime();
        level.zombie_last_run_time = gettime();

        if ( isdefined( level.zombie_round_change_custom ) )
            [[ level.zombie_round_change_custom ]]();
        else
        {
            level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
            round_one_up();
        }

        maps\mp\zombies\_zm_powerups::powerup_round_start();
        players = get_players();
        array_thread( players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset );

        if ( !( isdefined( level.headshots_only ) && level.headshots_only ) && !restart )
            level thread award_grenades_for_survivors();

        bbprint( "zombie_rounds", "round %d player_count %d", level.round_number, players.size );
/#
        println( "ZM >> round_think, round=" + level.round_number + ", player_count=" + players.size );
#/
        level.round_start_time = gettime();

        while ( level.zombie_spawn_locations.size <= 0 )
            wait 0.1;

        level thread [[ level.round_spawn_func ]]();
        level notify( "start_of_round" );
        recordzombieroundstart();
        players = getplayers();

        for ( index = 0; index < players.size; index++ )
        {
            zonename = players[index] get_current_zone();

            if ( isdefined( zonename ) )
                players[index] recordzombiezone( "startingZone", zonename );
        }

        if ( isdefined( level.round_start_custom_func ) )
            [[ level.round_start_custom_func ]]();

        [[ level.round_wait_func ]]();
        level.first_round = 0;
        level notify( "end_of_round" );
        level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
        uploadstats();

        if ( isdefined( level.round_end_custom_logic ) )
            [[ level.round_end_custom_logic ]]();

        players = get_players();

        if ( isdefined( level.no_end_game_check ) && level.no_end_game_check )
        {
            level thread last_stand_revive();
            level thread spectators_respawn();
        }
        else if ( 1 != players.size )
            level thread spectators_respawn();

        players = get_players();
        array_thread( players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
        timer = level.zombie_vars["zombie_spawn_delay"];

        if ( timer > 0.08 )
            level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
        else if ( timer < 0.08 )
            level.zombie_vars["zombie_spawn_delay"] = 0.08;

        if ( level.gamedifficulty == 0 )
            level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
        else
            level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

        level.round_number++;

        if ( 255 < level.round_number )
            level.round_number = 255;

        setroundsplayed( level.round_number );
        matchutctime = getutc();
        players = get_players();

        foreach ( player in players )
        {
            if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
                player maps\mp\zombies\_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );

            player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
            player maps\mp\zombies\_zm_stats::update_playing_utc_time( matchutctime );
        }

        check_quickrevive_for_hotjoin();
        level round_over();
        level notify( "between_round_over" );
        restart = 0;
    }
}

award_grenades_for_survivors()
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i].is_zombie )
        {
            lethal_grenade = players[i] get_player_lethal_grenade();

            if ( !players[i] hasweapon( lethal_grenade ) )
            {
                players[i] giveweapon( lethal_grenade );
                players[i] setweaponammoclip( lethal_grenade, 0 );
            }

            if ( players[i] getfractionmaxammo( lethal_grenade ) < 0.25 )
            {
                players[i] setweaponammoclip( lethal_grenade, 2 );
                continue;
            }

            if ( players[i] getfractionmaxammo( lethal_grenade ) < 0.5 )
            {
                players[i] setweaponammoclip( lethal_grenade, 3 );
                continue;
            }

            players[i] setweaponammoclip( lethal_grenade, 4 );
        }
    }
}

ai_calculate_health( round_number )
{
    level.zombie_health = level.zombie_vars["zombie_health_start"];

    for ( i = 2; i <= round_number; i++ )
    {
        if ( i >= 10 )
        {
            old_health = level.zombie_health;
            level.zombie_health += int( level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"] );

            if ( level.zombie_health < old_health )
            {
                level.zombie_health = old_health;
                return;
            }

            continue;
        }

        level.zombie_health = int( level.zombie_health + level.zombie_vars["zombie_health_increase"] );
    }
}

ai_zombie_health( round_number )
{
    zombie_health = level.zombie_vars["zombie_health_start"];

    for ( i = 2; i <= round_number; i++ )
    {
        if ( i >= 10 )
        {
            old_health = zombie_health;
            zombie_health += int( zombie_health * level.zombie_vars["zombie_health_increase_multiplier"] );

            if ( zombie_health < old_health )
                return old_health;

            continue;
        }

        zombie_health = int( zombie_health + level.zombie_vars["zombie_health_increase"] );
    }

    return zombie_health;
}

round_spawn_failsafe_debug()
{
/#
    level notify( "failsafe_debug_stop" );
    level endon( "failsafe_debug_stop" );
    start = gettime();
    level.chunk_time = 0;

    while ( true )
    {
        level.failsafe_time = gettime() - start;

        if ( isdefined( self.lastchunk_destroy_time ) )
            level.chunk_time = gettime() - self.lastchunk_destroy_time;

        wait_network_frame();
    }
#/
}

round_spawn_failsafe()
{
    self endon( "death" );
    prevorigin = self.origin;

    while ( true )
    {
        if ( !level.zombie_vars["zombie_use_failsafe"] )
            return;

        if ( isdefined( self.ignore_round_spawn_failsafe ) && self.ignore_round_spawn_failsafe )
            return;

        wait 30;

        if ( !self.has_legs )
            wait 10.0;

        if ( isdefined( self.is_inert ) && self.is_inert )
            continue;

        if ( isdefined( self.lastchunk_destroy_time ) )
        {
            if ( gettime() - self.lastchunk_destroy_time < 8000 )
                continue;
        }

        if ( self.origin[2] < level.zombie_vars["below_world_check"] )
        {
            if ( isdefined( level.put_timed_out_zombies_back_in_queue ) && level.put_timed_out_zombies_back_in_queue && !flag( "dog_round" ) && !( isdefined( self.isscreecher ) && self.isscreecher ) )
            {
                level.zombie_total++;
                level.zombie_total_subtract++;
            }
/#

#/
            self dodamage( self.health + 100, ( 0, 0, 0 ) );
            break;
        }

        if ( distancesquared( self.origin, prevorigin ) < 576 )
        {
            if ( isdefined( level.put_timed_out_zombies_back_in_queue ) && level.put_timed_out_zombies_back_in_queue && !flag( "dog_round" ) )
            {
                if ( !self.ignoreall && !( isdefined( self.nuked ) && self.nuked ) && !( isdefined( self.marked_for_death ) && self.marked_for_death ) && !( isdefined( self.isscreecher ) && self.isscreecher ) && ( isdefined( self.has_legs ) && self.has_legs ) )
                {
                    level.zombie_total++;
                    level.zombie_total_subtract++;
                }
            }

            level.zombies_timeout_playspace++;
/#

#/
            self dodamage( self.health + 100, ( 0, 0, 0 ) );
            break;
        }

        prevorigin = self.origin;
    }
}

round_wait()
{
    level endon( "restart_round" );
/#
    if ( getdvarint( _hash_7688603C ) )
        level waittill( "forever" );
#/
/#
    if ( getdvarint( _hash_FA81816F ) == 2 || getdvarint( _hash_FA81816F ) >= 4 )
        level waittill( "forever" );
#/
    wait 1;

    if ( flag( "dog_round" ) )
    {
        wait 7;

        while ( level.dog_intermission )
            wait 0.5;

        increment_dog_round_stat( "finished" );
    }
    else
    {
        while ( true )
        {
            should_wait = 0;

            if ( isdefined( level.is_ghost_round_started ) && [[ level.is_ghost_round_started ]]() )
                should_wait = 1;
            else
                should_wait = get_current_zombie_count() > 0 || level.zombie_total > 0 || level.intermission;

            if ( !should_wait )
                return;

            if ( flag( "end_round_wait" ) )
                return;

            wait 1.0;
        }
    }
}

zombify_player()
{
    self maps\mp\zombies\_zm_score::player_died_penalty();
    bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "died", self.origin );
    self recordplayerdeathzombies();

    if ( isdefined( level.deathcard_spawn_func ) )
        self [[ level.deathcard_spawn_func ]]();

    if ( !isdefined( level.zombie_vars["zombify_player"] ) || !level.zombie_vars["zombify_player"] )
    {
        self thread spawnspectator();
        return;
    }

    self.ignoreme = 1;
    self.is_zombie = 1;
    self.zombification_time = gettime();
    self.team = level.zombie_team;
    self notify( "zombified" );

    if ( isdefined( self.revivetrigger ) )
        self.revivetrigger delete();

    self.revivetrigger = undefined;
    self setmovespeedscale( 0.3 );
    self reviveplayer();
    self takeallweapons();
    self giveweapon( "zombie_melee", 0 );
    self switchtoweapon( "zombie_melee" );
    self disableweaponcycling();
    self disableoffhandweapons();
    setclientsysstate( "zombify", 1, self );
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow();
    self thread playerzombie_player_damage();
    self thread playerzombie_soundboard();
}

playerzombie_player_damage()
{
    self endon( "death" );
    self endon( "disconnect" );
    self thread playerzombie_infinite_health();
    self.zombiehealth = level.zombie_health;

    while ( true )
    {
        self waittill( "damage", amount, attacker, directionvec, point, type );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
        {
            wait 0.05;
            continue;
        }

        self.zombiehealth -= amount;

        if ( self.zombiehealth <= 0 )
        {
            self thread playerzombie_downed_state();

            self waittill( "playerzombie_downed_state_done" );

            self.zombiehealth = level.zombie_health;
        }
    }
}

playerzombie_downed_state()
{
    self endon( "death" );
    self endon( "disconnect" );
    downtime = 15;
    starttime = gettime();
    endtime = starttime + downtime * 1000;
    self thread playerzombie_downed_hud();
    self.playerzombie_soundboard_disable = 1;
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow_stop();
    self disableweapons();
    self allowstand( 0 );
    self allowcrouch( 0 );
    self allowprone( 1 );

    while ( gettime() < endtime )
        wait 0.05;

    self.playerzombie_soundboard_disable = 0;
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow();
    self enableweapons();
    self allowstand( 1 );
    self allowcrouch( 0 );
    self allowprone( 0 );
    self notify( "playerzombie_downed_state_done" );
}

playerzombie_downed_hud()
{
    self endon( "death" );
    self endon( "disconnect" );
    text = newclienthudelem( self );
    text.alignx = "center";
    text.aligny = "middle";
    text.horzalign = "user_center";
    text.vertalign = "user_bottom";
    text.foreground = 1;
    text.font = "default";
    text.fontscale = 1.8;
    text.alpha = 0;
    text.color = ( 1, 1, 1 );
    text settext( &"ZOMBIE_PLAYERZOMBIE_DOWNED" );
    text.y = -113;

    if ( self issplitscreen() )
        text.y = -137;

    text fadeovertime( 0.1 );
    text.alpha = 1;

    self waittill( "playerzombie_downed_state_done" );

    text fadeovertime( 0.1 );
    text.alpha = 0;
}

playerzombie_infinite_health()
{
    self endon( "death" );
    self endon( "disconnect" );
    bighealth = 100000;

    while ( true )
    {
        if ( self.health < bighealth )
            self.health = bighealth;

        wait 0.1;
    }
}

playerzombie_soundboard()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.playerzombie_soundboard_disable = 0;
    self.buttonpressed_use = 0;
    self.buttonpressed_attack = 0;
    self.buttonpressed_ads = 0;
    self.usesound_waittime = 3000;
    self.usesound_nexttime = gettime();
    usesound = "playerzombie_usebutton_sound";
    self.attacksound_waittime = 3000;
    self.attacksound_nexttime = gettime();
    attacksound = "playerzombie_attackbutton_sound";
    self.adssound_waittime = 3000;
    self.adssound_nexttime = gettime();
    adssound = "playerzombie_adsbutton_sound";
    self.inputsound_nexttime = gettime();

    while ( true )
    {
        if ( self.playerzombie_soundboard_disable )
        {
            wait 0.05;
            continue;
        }

        if ( self usebuttonpressed() )
        {
            if ( self can_do_input( "use" ) )
            {
                self thread playerzombie_play_sound( usesound );
                self thread playerzombie_waitfor_buttonrelease( "use" );
                self.usesound_nexttime = gettime() + self.usesound_waittime;
            }
        }
        else if ( self attackbuttonpressed() )
        {
            if ( self can_do_input( "attack" ) )
            {
                self thread playerzombie_play_sound( attacksound );
                self thread playerzombie_waitfor_buttonrelease( "attack" );
                self.attacksound_nexttime = gettime() + self.attacksound_waittime;
            }
        }
        else if ( self adsbuttonpressed() )
        {
            if ( self can_do_input( "ads" ) )
            {
                self thread playerzombie_play_sound( adssound );
                self thread playerzombie_waitfor_buttonrelease( "ads" );
                self.adssound_nexttime = gettime() + self.adssound_waittime;
            }
        }

        wait 0.05;
    }
}

can_do_input( inputtype )
{
    if ( gettime() < self.inputsound_nexttime )
        return 0;

    cando = 0;

    switch ( inputtype )
    {
        case "use":
            if ( gettime() >= self.usesound_nexttime && !self.buttonpressed_use )
                cando = 1;

            break;
        case "attack":
            if ( gettime() >= self.attacksound_nexttime && !self.buttonpressed_attack )
                cando = 1;

            break;
        case "ads":
            if ( gettime() >= self.usesound_nexttime && !self.buttonpressed_ads )
                cando = 1;

            break;
        default:
/#
            assertmsg( "can_do_input(): didn't recognize inputType of " + inputtype );
#/
            break;
    }

    return cando;
}

playerzombie_play_sound( alias )
{
    self play_sound_on_ent( alias );
}

playerzombie_waitfor_buttonrelease( inputtype )
{
    if ( inputtype != "use" && inputtype != "attack" && inputtype != "ads" )
    {
/#
        assertmsg( "playerzombie_waitfor_buttonrelease(): inputType of " + inputtype + " is not recognized." );
#/
        return;
    }

    notifystring = "waitfor_buttonrelease_" + inputtype;
    self notify( notifystring );
    self endon( notifystring );

    if ( inputtype == "use" )
    {
        self.buttonpressed_use = 1;

        while ( self usebuttonpressed() )
            wait 0.05;

        self.buttonpressed_use = 0;
    }
    else if ( inputtype == "attack" )
    {
        self.buttonpressed_attack = 1;

        while ( self attackbuttonpressed() )
            wait 0.05;

        self.buttonpressed_attack = 0;
    }
    else if ( inputtype == "ads" )
    {
        self.buttonpressed_ads = 1;

        while ( self adsbuttonpressed() )
            wait 0.05;

        self.buttonpressed_ads = 0;
    }
}

remove_ignore_attacker()
{
    self notify( "new_ignore_attacker" );
    self endon( "new_ignore_attacker" );
    self endon( "disconnect" );

    if ( !isdefined( level.ignore_enemy_timer ) )
        level.ignore_enemy_timer = 0.4;

    wait( level.ignore_enemy_timer );
    self.ignoreattacker = undefined;
}

player_shield_facing_attacker( vdir, limit )
{
    orientation = self getplayerangles();
    forwardvec = anglestoforward( orientation );
    forwardvec2d = ( forwardvec[0], forwardvec[1], 0 );
    unitforwardvec2d = vectornormalize( forwardvec2d );
    tofaceevec = vdir * -1;
    tofaceevec2d = ( tofaceevec[0], tofaceevec[1], 0 );
    unittofaceevec2d = vectornormalize( tofaceevec2d );
    dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
    return dotproduct > limit;
}

player_damage_override_cheat( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
    return 0;
}

player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    if ( isdefined( level._game_module_player_damage_callback ) )
        self [[ level._game_module_player_damage_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

    idamage = self check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

    if ( isdefined( self.use_adjusted_grenade_damage ) && self.use_adjusted_grenade_damage )
    {
        self.use_adjusted_grenade_damage = undefined;

        if ( self.health > idamage )
            return idamage;
    }

    if ( !idamage )
        return 0;

    if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        return 0;

    if ( isdefined( einflictor ) )
    {
        if ( isdefined( einflictor.water_damage ) && einflictor.water_damage )
            return 0;
    }

    if ( isdefined( eattacker ) && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie || isplayer( eattacker ) ) )
    {
        if ( isdefined( self.hasriotshield ) && self.hasriotshield && isdefined( vdir ) )
        {
            if ( isdefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
            {
                if ( self player_shield_facing_attacker( vdir, 0.2 ) && isdefined( self.player_shield_apply_damage ) )
                {
                    self [[ self.player_shield_apply_damage ]]( 100, 0 );
                    return 0;
                }
            }
            else if ( !isdefined( self.riotshieldentity ) )
            {
                if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isdefined( self.player_shield_apply_damage ) )
                {
                    self [[ self.player_shield_apply_damage ]]( 100, 0 );
                    return 0;
                }
            }
        }
    }

    if ( isdefined( eattacker ) )
    {
        if ( isdefined( self.ignoreattacker ) && self.ignoreattacker == eattacker )
            return 0;

        if ( isdefined( self.is_zombie ) && self.is_zombie && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie ) )
            return 0;

        if ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie )
        {
            self.ignoreattacker = eattacker;
            self thread remove_ignore_attacker();

            if ( isdefined( eattacker.custom_damage_func ) )
                idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
            else if ( isdefined( eattacker.meleedamage ) )
                idamage = eattacker.meleedamage;
            else
                idamage = 50;
        }

        eattacker notify( "hit_player" );

        if ( smeansofdeath != "MOD_FALLING" )
        {
            self thread playswipesound( smeansofdeath, eattacker );

            if ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie || isplayer( eattacker ) )
                self playrumbleonentity( "damage_heavy" );

            canexert = 1;

            if ( isdefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
            {
                if ( isdefined( self.pers_upgrades_awarded["flopper"] ) && self.pers_upgrades_awarded["flopper"] )
                    canexert = smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH";
            }

            if ( isdefined( canexert ) && canexert )
            {
                if ( randomintrange( 0, 1 ) == 0 )
                    self thread maps\mp\zombies\_zm_audio::playerexert( "hitmed" );
                else
                    self thread maps\mp\zombies\_zm_audio::playerexert( "hitlrg" );
            }
        }
    }

    finaldamage = idamage;

    if ( is_placeable_mine( sweapon ) || sweapon == "freezegun_zm" || sweapon == "freezegun_upgraded_zm" )
        return 0;

    if ( isdefined( self.player_damage_override ) )
        self thread [[ self.player_damage_override ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

    if ( smeansofdeath == "MOD_FALLING" )
    {
        if ( self hasperk( "specialty_flakjacket" ) && isdefined( self.divetoprone ) && self.divetoprone == 1 )
        {
            if ( isdefined( level.zombiemode_divetonuke_perk_func ) )
                [[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );

            return 0;
        }

        if ( isdefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
        {
            if ( self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_flopper_damage_check( smeansofdeath, idamage ) )
                return 0;
        }
    }

    if ( smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
    {
        if ( self hasperk( "specialty_flakjacket" ) )
            return 0;

        if ( isdefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
        {
            if ( isdefined( self.pers_upgrades_awarded["flopper"] ) && self.pers_upgrades_awarded["flopper"] )
                return 0;
        }

        if ( self.health > 75 && !( isdefined( self.is_zombie ) && self.is_zombie ) )
            return 75;
    }

    if ( idamage < self.health )
    {
        if ( isdefined( eattacker ) )
        {
            if ( isdefined( level.custom_kill_damaged_vo ) )
                eattacker thread [[ level.custom_kill_damaged_vo ]]( self );
            else
                eattacker.sound_damage_player = self;

            if ( isdefined( eattacker.has_legs ) && !eattacker.has_legs )
                self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "crawl_hit" );
            else if ( isdefined( eattacker.animname ) && eattacker.animname == "monkey_zombie" )
                self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "monkey_hit" );
        }

        return finaldamage;
    }

    if ( isdefined( eattacker ) )
    {
        if ( isdefined( eattacker.animname ) && eattacker.animname == "zombie_dog" )
        {
            self maps\mp\zombies\_zm_stats::increment_client_stat( "killed_by_zdog" );
            self maps\mp\zombies\_zm_stats::increment_player_stat( "killed_by_zdog" );
        }
        else if ( isdefined( eattacker.is_avogadro ) && eattacker.is_avogadro )
        {
            self maps\mp\zombies\_zm_stats::increment_client_stat( "killed_by_avogadro", 0 );
            self maps\mp\zombies\_zm_stats::increment_player_stat( "killed_by_avogadro" );
        }
    }

    self thread clear_path_timers();

    if ( level.intermission )
        level waittill( "forever" );

    if ( level.scr_zm_ui_gametype == "zcleansed" && idamage > 0 )
    {
        if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker.team != self.team && ( !( isdefined( self.laststand ) && self.laststand ) && !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || !isdefined( self.last_player_attacker ) ) )
        {
            if ( isdefined( eattacker.maxhealth ) && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie ) )
                eattacker.health = eattacker.maxhealth;

            if ( isdefined( level.player_kills_player ) )
                self thread [[ level.player_kills_player ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
        }
    }

    if ( self.lives > 0 && self hasperk( "specialty_finalstand" ) )
    {
        self.lives--;

        if ( isdefined( level.chugabud_laststand_func ) )
        {
            self thread [[ level.chugabud_laststand_func ]]();
            return 0;
        }
    }

    players = get_players();
    count = 0;

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] == self || players[i].is_zombie || players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() || players[i].sessionstate == "spectator" )
            count++;
    }

    if ( count < players.size || isdefined( level._game_module_game_end_check ) && ![[ level._game_module_game_end_check ]]() )
    {
        if ( isdefined( self.lives ) && self.lives > 0 && ( isdefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive ) && self hasperk( "specialty_quickrevive" ) )
            self thread wait_and_revive();

        return finaldamage;
    }

    if ( players.size == 1 && flag( "solo_game" ) )
    {
        if ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) )
            self.intermission = 1;
    }

    solo_death = players.size == 1 && flag( "solo_game" ) && ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) );
    non_solo_death = count > 1 || players.size == 1 && !flag( "solo_game" );

    if ( ( solo_death || non_solo_death ) && !( isdefined( level.no_end_game_check ) && level.no_end_game_check ) )
    {
        level notify( "stop_suicide_trigger" );
        self thread maps\mp\zombies\_zm_laststand::playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );

        if ( !isdefined( vdir ) )
            vdir = ( 1, 0, 0 );

        self fakedamagefrom( vdir );

        if ( isdefined( level.custom_player_fake_death ) )
            self thread [[ level.custom_player_fake_death ]]( vdir, smeansofdeath );
        else
            self thread player_fake_death();
    }

    if ( count == players.size && !( isdefined( level.no_end_game_check ) && level.no_end_game_check ) )
    {
        if ( players.size == 1 && flag( "solo_game" ) )
        {
            if ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) )
            {
                self.lives = 0;
                level notify( "pre_end_game" );
                wait_network_frame();

                if ( flag( "dog_round" ) )
                    increment_dog_round_stat( "lost" );

                level notify( "end_game" );
            }
            else
                return finaldamage;
        }
        else
        {
            level notify( "pre_end_game" );
            wait_network_frame();

            if ( flag( "dog_round" ) )
                increment_dog_round_stat( "lost" );

            level notify( "end_game" );
        }

        return 0;
    }
    else
    {
        surface = "flesh";
        return finaldamage;
    }
}

clear_path_timers()
{
    zombies = getaiarray( level.zombie_team );

    foreach ( zombie in zombies )
    {
        if ( isdefined( zombie.favoriteenemy ) && zombie.favoriteenemy == self )
            zombie.zombie_path_timer = 0;
    }
}

check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    if ( !isdefined( level.player_damage_callbacks ) )
        return idamage;

    for ( i = 0; i < level.player_damage_callbacks.size; i++ )
    {
        newdamage = self [[ level.player_damage_callbacks[i] ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

        if ( -1 != newdamage )
            return newdamage;
    }

    return idamage;
}

register_player_damage_callback( func )
{
    if ( !isdefined( level.player_damage_callbacks ) )
        level.player_damage_callbacks = [];

    level.player_damage_callbacks[level.player_damage_callbacks.size] = func;
}

wait_and_revive()
{
    flag_set( "wait_and_revive" );

    if ( isdefined( self.waiting_to_revive ) && self.waiting_to_revive == 1 )
        return;

    if ( isdefined( self.pers_upgrades_awarded["perk_lose"] ) && self.pers_upgrades_awarded["perk_lose"] )
        self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_perk_lose_save();

    self.waiting_to_revive = 1;

    if ( isdefined( level.exit_level_func ) )
        self thread [[ level.exit_level_func ]]();
    else if ( get_players().size == 1 )
        self thread default_exit_level();

    solo_revive_time = 10.0;
    self.revive_hud settext( &"ZOMBIE_REVIVING_SOLO", self );
    self maps\mp\zombies\_zm_laststand::revive_hud_show_n_fade( solo_revive_time );
    flag_wait_or_timeout( "instant_revive", solo_revive_time );

    if ( flag( "instant_revive" ) )
        self maps\mp\zombies\_zm_laststand::revive_hud_show_n_fade( 1.0 );

    flag_clear( "wait_and_revive" );
    self maps\mp\zombies\_zm_laststand::auto_revive( self );
    self.lives--;
    self.waiting_to_revive = 0;

    if ( isdefined( self.pers_upgrades_awarded["perk_lose"] ) && self.pers_upgrades_awarded["perk_lose"] )
        self thread maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_perk_lose_restore();
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( !isdefined( self ) || !isdefined( attacker ) )
        return damage;

    if ( weapon == "tazer_knuckles_zm" || weapon == "jetgun_zm" )
        self.knuckles_extinguish_flames = 1;
    else if ( weapon != "none" )
        self.knuckles_extinguish_flames = undefined;

    if ( isdefined( attacker.animname ) && attacker.animname == "quad_zombie" )
    {
        if ( isdefined( self.animname ) && self.animname == "quad_zombie" )
            return 0;
    }

    if ( !isplayer( attacker ) && isdefined( self.non_attacker_func ) )
    {
        if ( isdefined( self.non_attack_func_takes_attacker ) && self.non_attack_func_takes_attacker )
            return self [[ self.non_attacker_func ]]( damage, weapon, attacker );
        else
            return self [[ self.non_attacker_func ]]( damage, weapon );
    }

    if ( !isplayer( attacker ) && !isplayer( self ) )
        return damage;

    if ( !isdefined( damage ) || !isdefined( meansofdeath ) )
        return damage;

    if ( meansofdeath == "" )
        return damage;

    old_damage = damage;
    final_damage = damage;

    if ( isdefined( self.actor_damage_func ) )
        final_damage = [[ self.actor_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
/#
    if ( getdvarint( _hash_5ABA6445 ) )
        println( "Perk/> Damage Factor: " + final_damage / old_damage + " - Pre Damage: " + old_damage + " - Post Damage: " + final_damage );
#/
    if ( attacker.classname == "script_vehicle" && isdefined( attacker.owner ) )
        attacker = attacker.owner;

    if ( isdefined( self.in_water ) && self.in_water )
    {
        if ( int( final_damage ) >= self.health )
            self.water_damage = 1;
    }

    attacker thread maps\mp\gametypes_zm\_weapons::checkhit( weapon );

    if ( attacker maps\mp\zombies\_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() && is_headshot( weapon, shitloc, meansofdeath ) )
        final_damage *= 2;

    if ( isdefined( level.headshots_only ) && level.headshots_only && isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( meansofdeath == "MOD_MELEE" && ( shitloc == "head" || shitloc == "helmet" ) )
            return int( final_damage );

        if ( is_explosive_damage( meansofdeath ) )
            return int( final_damage );
        else if ( !is_headshot( weapon, shitloc, meansofdeath ) )
            return 0;
    }

    return int( final_damage );
}

actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );

    if ( damage_override < self.health || !( isdefined( self.dont_die_on_me ) && self.dont_die_on_me ) )
        self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

actor_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
    if ( game["state"] == "postgame" )
        return;

    if ( isai( attacker ) && isdefined( attacker.script_owner ) )
    {
        if ( attacker.script_owner.team != self.aiteam )
            attacker = attacker.script_owner;
    }

    if ( attacker.classname == "script_vehicle" && isdefined( attacker.owner ) )
        attacker = attacker.owner;

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        multiplier = 1;

        if ( is_headshot( sweapon, shitloc, smeansofdeath ) )
            multiplier = 1.5;

        type = undefined;

        if ( isdefined( self.animname ) )
        {
            switch ( self.animname )
            {
                case "quad_zombie":
                    type = "quadkill";
                    break;
                case "ape_zombie":
                    type = "apekill";
                    break;
                case "zombie":
                    type = "zombiekill";
                    break;
                case "zombie_dog":
                    type = "dogkill";
                    break;
            }
        }
    }

    if ( isdefined( self.is_ziplining ) && self.is_ziplining )
        self.deathanim = undefined;

    if ( isdefined( self.actor_killed_override ) )
        self [[ self.actor_killed_override ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
}

round_end_monitor()
{
    while ( true )
    {
        level waittill( "end_of_round" );

        maps\mp\_demo::bookmark( "zm_round_end", gettime(), undefined, undefined, 1 );
        bbpostdemostreamstatsforround( level.round_number );
        wait 0.05;
    }
}

end_game()
{
    level waittill( "end_game" );

    check_end_game_intermission_delay();
/#
    println( "end_game TRIGGERED " );
#/
    clientnotify( "zesn" );

    if ( isdefined( level.sndgameovermusicoverride ) )
        level thread maps\mp\zombies\_zm_audio::change_zombie_music( level.sndgameovermusicoverride );
    else
        level thread maps\mp\zombies\_zm_audio::change_zombie_music( "game_over" );

    players = get_players();

    for ( i = 0; i < players.size; i++ )
        setclientsysstate( "lsm", "0", players[i] );

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] player_is_in_laststand() )
        {
            players[i] recordplayerdeathzombies();
            players[i] maps\mp\zombies\_zm_stats::increment_player_stat( "deaths" );
            players[i] maps\mp\zombies\_zm_stats::increment_client_stat( "deaths" );
            players[i] maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
        }

        if ( isdefined( players[i].revivetexthud ) )
            players[i].revivetexthud destroy();
    }

    stopallrumbles();
    level.intermission = 1;
    level.zombie_vars["zombie_powerup_insta_kill_time"] = 0;
    level.zombie_vars["zombie_powerup_fire_sale_time"] = 0;
    level.zombie_vars["zombie_powerup_point_doubler_time"] = 0;
    wait 0.1;
    game_over = [];
    survived = [];
    players = get_players();
    setmatchflag( "disableIngameMenu", 1 );

    foreach ( player in players )
    {
        player closemenu();
        player closeingamemenu();
    }

    if ( !isdefined( level._supress_survived_screen ) )
    {
        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( level.custom_game_over_hud_elem ) )
                game_over[i] = [[ level.custom_game_over_hud_elem ]]( players[i] );
            else
            {
                game_over[i] = newclienthudelem( players[i] );
                game_over[i].alignx = "center";
                game_over[i].aligny = "middle";
                game_over[i].horzalign = "center";
                game_over[i].vertalign = "middle";
                game_over[i].y -= 130;
                game_over[i].foreground = 1;
                game_over[i].fontscale = 3;
                game_over[i].alpha = 0;
                game_over[i].color = ( 1, 1, 1 );
                game_over[i].hidewheninmenu = 1;
                game_over[i] settext( &"ZOMBIE_GAME_OVER" );
                game_over[i] fadeovertime( 1 );
                game_over[i].alpha = 1;

                if ( players[i] issplitscreen() )
                {
                    game_over[i].fontscale = 2;
                    game_over[i].y += 40;
                }
            }

            survived[i] = newclienthudelem( players[i] );
            survived[i].alignx = "center";
            survived[i].aligny = "middle";
            survived[i].horzalign = "center";
            survived[i].vertalign = "middle";
            survived[i].y -= 100;
            survived[i].foreground = 1;
            survived[i].fontscale = 2;
            survived[i].alpha = 0;
            survived[i].color = ( 1, 1, 1 );
            survived[i].hidewheninmenu = 1;

            if ( players[i] issplitscreen() )
            {
                survived[i].fontscale = 1.5;
                survived[i].y += 40;
            }

            if ( level.round_number < 2 )
            {
                if ( level.script == "zombie_moon" )
                {
                    if ( !isdefined( level.left_nomans_land ) )
                    {
                        nomanslandtime = level.nml_best_time;
                        player_survival_time = int( nomanslandtime / 1000 );
                        player_survival_time_in_mins = maps\mp\zombies\_zm::to_mins( player_survival_time );
                        survived[i] settext( &"ZOMBIE_SURVIVED_NOMANS", player_survival_time_in_mins );
                    }
                    else if ( level.left_nomans_land == 2 )
                        survived[i] settext( &"ZOMBIE_SURVIVED_ROUND" );
                }
                else
                    survived[i] settext( &"ZOMBIE_SURVIVED_ROUND" );
            }
            else
                survived[i] settext( &"ZOMBIE_SURVIVED_ROUNDS", level.round_number );

            survived[i] fadeovertime( 1 );
            survived[i].alpha = 1;
        }
    }

    if ( isdefined( level.custom_end_screen ) )
        level [[ level.custom_end_screen ]]();

    for ( i = 0; i < players.size; i++ )
    {
        players[i] setclientammocounterhide( 1 );
        players[i] setclientminiscoreboardhide( 1 );
    }

    uploadstats();
    maps\mp\zombies\_zm_stats::update_players_stats_at_match_end( players );
    maps\mp\zombies\_zm_stats::update_global_counters_on_match_end();
    wait 1;
    wait 3.95;
    players = get_players();

    foreach ( player in players )
    {
        if ( isdefined( player.sessionstate ) && player.sessionstate == "spectator" )
            player.sessionstate = "playing";
    }

    wait 0.05;
    players = get_players();

    if ( !isdefined( level._supress_survived_screen ) )
    {
        for ( i = 0; i < players.size; i++ )
        {
            survived[i] destroy();
            game_over[i] destroy();
        }
    }
    else
    {
        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( players[i].survived_hud ) )
                players[i].survived_hud destroy();

            if ( isdefined( players[i].game_over_hud ) )
                players[i].game_over_hud destroy();
        }
    }

    intermission();
    wait( level.zombie_vars["zombie_intermission_time"] );
    level notify( "stop_intermission" );
    array_thread( get_players(), ::player_exit_level );
    bbprint( "zombie_epilogs", "rounds %d", level.round_number );
    wait 1.5;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] cameraactivate( 0 );

    exitlevel( 0 );
    wait 666;
}

disable_end_game_intermission( delay )
{
    level.disable_intermission = 1;
    wait( delay );
    level.disable_intermission = undefined;
}

check_end_game_intermission_delay()
{
    if ( isdefined( level.disable_intermission ) )
    {
        while ( true )
        {
            if ( !isdefined( level.disable_intermission ) )
                break;

            wait 0.01;
        }
    }
}

upload_leaderboards()
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] uploadleaderboards();
}

initializestattracking()
{
    level.global_zombies_killed = 0;
    level.zombies_timeout_spawn = 0;
    level.zombies_timeout_playspace = 0;
    level.zombies_timeout_undamaged = 0;
    level.zombie_player_killed_count = 0;
    level.zombie_trap_killed_count = 0;
    level.zombie_pathing_failed = 0;
    level.zombie_breadcrumb_failed = 0;
}

uploadglobalstatcounters()
{
    incrementcounter( "global_zombies_killed", level.global_zombies_killed );
    incrementcounter( "global_zombies_killed_by_players", level.zombie_player_killed_count );
    incrementcounter( "global_zombies_killed_by_traps", level.zombie_trap_killed_count );
}

player_fake_death()
{
    level notify( "fake_death" );
    self notify( "fake_death" );
    self takeallweapons();
    self allowstand( 0 );
    self allowcrouch( 0 );
    self allowprone( 1 );
    self.ignoreme = 1;
    self enableinvulnerability();
    wait 1;
    self freezecontrols( 1 );
}

player_exit_level()
{
    self allowstand( 1 );
    self allowcrouch( 0 );
    self allowprone( 0 );

    if ( isdefined( self.game_over_bg ) )
    {
        self.game_over_bg.foreground = 1;
        self.game_over_bg.sort = 100;
        self.game_over_bg fadeovertime( 1 );
        self.game_over_bg.alpha = 1;
    }
}

player_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    level waittill( "forever" );
}

player_zombie_breadcrumb()
{
    self notify( "stop_player_zombie_breadcrumb" );
    self endon( "stop_player_zombie_breadcrumb" );
    self endon( "disconnect" );
    self endon( "spawned_spectator" );
    level endon( "intermission" );
    self.zombie_breadcrumbs = [];
    self.zombie_breadcrumb_distance = 576;
    self.zombie_breadcrumb_area_num = 3;
    self.zombie_breadcrumb_area_distance = 16;
    self store_crumb( self.origin );
    last_crumb = self.origin;
    self thread debug_breadcrumbs();

    while ( true )
    {
        wait_time = 0.1;

        if ( self.ignoreme )
        {
            wait( wait_time );
            continue;
        }

        store_crumb = 1;
        airborne = 0;
        crumb = self.origin;

        if ( !self isonground() && self isinvehicle() )
        {
            trace = bullettrace( self.origin + vectorscale( ( 0, 0, 1 ), 10.0 ), self.origin, 0, undefined );
            crumb = trace["position"];
        }

        if ( !airborne && distancesquared( crumb, last_crumb ) < self.zombie_breadcrumb_distance )
            store_crumb = 0;

        if ( airborne && self isonground() )
        {
            store_crumb = 1;
            airborne = 0;
        }

        if ( isdefined( level.custom_breadcrumb_store_func ) )
            store_crumb = self [[ level.custom_breadcrumb_store_func ]]( store_crumb );

        if ( isdefined( level.custom_airborne_func ) )
            airborne = self [[ level.custom_airborne_func ]]( airborne );

        if ( store_crumb )
        {
            debug_print( "Player is storing breadcrumb " + crumb );

            if ( isdefined( self.node ) )
                debug_print( "has closest node " );

            last_crumb = crumb;
            self store_crumb( crumb );
        }

        wait( wait_time );
    }
}

store_crumb( origin )
{
    offsets = [];
    height_offset = 32;
    index = 0;

    for ( j = 1; j <= self.zombie_breadcrumb_area_num; j++ )
    {
        offset = j * self.zombie_breadcrumb_area_distance;
        offsets[0] = ( origin[0] - offset, origin[1], origin[2] );
        offsets[1] = ( origin[0] + offset, origin[1], origin[2] );
        offsets[2] = ( origin[0], origin[1] - offset, origin[2] );
        offsets[3] = ( origin[0], origin[1] + offset, origin[2] );
        offsets[4] = ( origin[0] - offset, origin[1], origin[2] + height_offset );
        offsets[5] = ( origin[0] + offset, origin[1], origin[2] + height_offset );
        offsets[6] = ( origin[0], origin[1] - offset, origin[2] + height_offset );
        offsets[7] = ( origin[0], origin[1] + offset, origin[2] + height_offset );

        for ( i = 0; i < offsets.size; i++ )
        {
            self.zombie_breadcrumbs[index] = offsets[i];
            index++;
        }
    }
}

to_mins( seconds )
{
    hours = 0;
    minutes = 0;

    if ( seconds > 59 )
    {
        minutes = int( seconds / 60 );
        seconds = int( seconds * 1000 ) % 60000;
        seconds *= 0.001;

        if ( minutes > 59 )
        {
            hours = int( minutes / 60 );
            minutes = int( minutes * 1000 ) % 60000;
            minutes *= 0.001;
        }
    }

    if ( hours < 10 )
        hours = "0" + hours;

    if ( minutes < 10 )
        minutes = "0" + minutes;

    seconds = int( seconds );

    if ( seconds < 10 )
        seconds = "0" + seconds;

    combined = "" + hours + ":" + minutes + ":" + seconds;
    return combined;
}

intermission()
{
    level.intermission = 1;
    level notify( "intermission" );
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        setclientsysstate( "levelNotify", "zi", players[i] );
        players[i] setclientthirdperson( 0 );
        players[i] resetfov();
        players[i].health = 100;
        players[i] thread [[ level.custom_intermission ]]();
        players[i] stopsounds();
    }

    wait 0.25;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        setclientsysstate( "lsm", "0", players[i] );

    level thread zombie_game_over_death();
}

zombie_game_over_death()
{
    zombies = getaiarray( level.zombie_team );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( !isalive( zombies[i] ) )
            continue;

        zombies[i] setgoalpos( zombies[i].origin );
    }

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( !isalive( zombies[i] ) )
            continue;

        if ( isdefined( zombies[i].ignore_game_over_death ) && zombies[i].ignore_game_over_death )
            continue;

        wait( 0.5 + randomfloat( 2 ) );

        if ( isdefined( zombies[i] ) )
        {
            zombies[i] maps\mp\zombies\_zm_spawner::zombie_head_gib();
            zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
        }
    }
}

player_intermission()
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
    points = getstructarray( "intermission", "targetname" );

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
    self.game_over_bg.horzalign = "fullscreen";
    self.game_over_bg.vertalign = "fullscreen";
    self.game_over_bg setshader( "black", 640, 480 );
    self.game_over_bg.alpha = 1;
    org = undefined;

    while ( true )
    {
        points = array_randomize( points );

        for ( i = 0; i < points.size; i++ )
        {
            point = points[i];

            if ( !isdefined( org ) )
                self spawn( point.origin, point.angles );

            if ( isdefined( points[i].target ) )
            {
                if ( !isdefined( org ) )
                {
                    org = spawn( "script_model", self.origin + vectorscale( ( 0, 0, -1 ), 60.0 ) );
                    org setmodel( "tag_origin" );
                }

                org.origin = points[i].origin;
                org.angles = points[i].angles;

                for ( j = 0; j < get_players().size; j++ )
                {
                    player = get_players()[j];
                    player camerasetposition( org );
                    player camerasetlookat();
                    player cameraactivate( 1 );
                }

                speed = 20;

                if ( isdefined( points[i].speed ) )
                    speed = points[i].speed;

                target_point = getstruct( points[i].target, "targetname" );
                dist = distance( points[i].origin, target_point.origin );
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
                continue;
            }

            self.game_over_bg fadeovertime( 1 );
            self.game_over_bg.alpha = 0;
            wait 5;
            self.game_over_bg thread fade_up_over_time( 1 );
        }
    }
}

fade_up_over_time( t )
{
    self fadeovertime( t );
    self.alpha = 1;
}

default_exit_level()
{
    zombies = getaiarray( level.zombie_team );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( isdefined( zombies[i].ignore_solo_last_stand ) && zombies[i].ignore_solo_last_stand )
            continue;

        if ( isdefined( zombies[i].find_exit_point ) )
        {
            zombies[i] thread [[ zombies[i].find_exit_point ]]();
            continue;
        }

        if ( zombies[i].ignoreme )
        {
            zombies[i] thread default_delayed_exit();
            continue;
        }

        zombies[i] thread default_find_exit_point();
    }
}

default_delayed_exit()
{
    self endon( "death" );

    while ( true )
    {
        if ( !flag( "wait_and_revive" ) )
            return;

        if ( !self.ignoreme )
            break;

        wait 0.1;
    }

    self thread default_find_exit_point();
}

default_find_exit_point()
{
    self endon( "death" );
    player = get_players()[0];
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

    self notify( "stop_find_flesh" );
    self notify( "zombie_acquire_enemy" );

    if ( isdefined( locs[dest] ) )
        self setgoalpos( locs[dest].origin );

    while ( true )
    {
        b_passed_override = 1;

        if ( isdefined( level.default_find_exit_position_override ) )
            b_passed_override = [[ level.default_find_exit_position_override ]]();

        if ( !flag( "wait_and_revive" ) && b_passed_override )
            break;

        wait 0.1;
    }

    self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
}

play_level_start_vox_delayed()
{
    wait 3;
    players = get_players();
    num = randomintrange( 0, players.size );
    players[num] maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "intro" );
}

register_sidequest( id, sidequest_stat )
{
    if ( !isdefined( level.zombie_sidequest_stat ) )
    {
        level.zombie_sidequest_previously_completed = [];
        level.zombie_sidequest_stat = [];
    }

    level.zombie_sidequest_stat[id] = sidequest_stat;
    flag_wait( "start_zombie_round_logic" );
    level.zombie_sidequest_previously_completed[id] = 0;

    if ( level.systemlink || getdvarint( "splitscreen_playerCount" ) == get_players().size )
        return;

    if ( isdefined( level.zm_disable_recording_stats ) && level.zm_disable_recording_stats )
        return;

    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] maps\mp\zombies\_zm_stats::get_global_stat( level.zombie_sidequest_stat[id] ) )
        {
            level.zombie_sidequest_previously_completed[id] = 1;
            return;
        }
    }
}

is_sidequest_previously_completed( id )
{
    return isdefined( level.zombie_sidequest_previously_completed[id] ) && level.zombie_sidequest_previously_completed[id];
}

set_sidequest_completed( id )
{
    level notify( "zombie_sidequest_completed", id );
    level.zombie_sidequest_previously_completed[id] = 1;

    if ( level.systemlink )
        return;

    if ( getdvarint( "splitscreen_playerCount" ) == get_players().size )
        return;

    if ( isdefined( level.zm_disable_recording_stats ) && level.zm_disable_recording_stats )
        return;

    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( level.zombie_sidequest_stat[id] ) )
            players[i] maps\mp\zombies\_zm_stats::add_global_stat( level.zombie_sidequest_stat[id], 1 );
    }
}

playswipesound( mod, attacker )
{
    if ( isdefined( attacker.is_zombie ) && attacker.is_zombie )
    {
        self playsoundtoplayer( "evt_player_swiped", self );
        return;
    }
}

precache_zombie_leaderboards()
{
    if ( sessionmodeissystemlink() )
        return;

    globalleaderboards = "LB_ZM_GB_BULLETS_FIRED_AT ";
    globalleaderboards += "LB_ZM_GB_BULLETS_HIT_AT ";
    globalleaderboards += "LB_ZM_GB_DEATHS_AT ";
    globalleaderboards += "LB_ZM_GB_DISTANCE_TRAVELED_AT ";
    globalleaderboards += "LB_ZM_GB_DOORS_PURCHASED_AT ";
    globalleaderboards += "LB_ZM_GB_DOWNS_AT ";
    globalleaderboards += "LB_ZM_GB_GIBS_AT ";
    globalleaderboards += "LB_ZM_GB_GRENADE_KILLS_AT ";
    globalleaderboards += "LB_ZM_GB_HEADSHOTS_AT ";
    globalleaderboards += "LB_ZM_GB_KILLS_AT ";
    globalleaderboards += "LB_ZM_GB_PERKS_DRANK_AT ";
    globalleaderboards += "LB_ZM_GB_REVIVES_AT ";

    if ( sessionmodeisprivateonlinegame() )
    {
        precacheleaderboards( globalleaderboards );
        return;
    }

    maplocationname = level.scr_zm_map_start_location;

    if ( ( maplocationname == "default" || maplocationname == "" ) && isdefined( level.default_start_location ) )
        maplocationname = level.default_start_location;

    if ( ( level.scr_zm_ui_gametype_group == "zclassic" || level.scr_zm_ui_gametype_group == "zsurvival" ) && level.scr_zm_ui_gametype != "zcleansed" )
    {
        expectedplayernum = getnumexpectedplayers();

        if ( expectedplayernum == 1 )
            gamemodeleaderboard = "LB_ZM_GM_" + level.scr_zm_ui_gametype + "_" + maplocationname + "_" + expectedplayernum + "PLAYER";
        else
            gamemodeleaderboard = "LB_ZM_GM_" + level.scr_zm_ui_gametype + "_" + maplocationname + "_" + expectedplayernum + "PLAYERS";
    }
    else
        gamemodeleaderboard = "LB_ZM_GM_" + level.scr_zm_ui_gametype + "_" + maplocationname;

    precacheleaderboards( globalleaderboards + gamemodeleaderboard );
}

zm_on_player_connect()
{
    if ( level.passed_introscreen )
        self setclientuivisibilityflag( "hud_visible", 1 );

    thread refresh_player_navcard_hud();
    self thread watchdisconnect();
}

zm_on_player_disconnect()
{
    thread refresh_player_navcard_hud();
}

watchdisconnect()
{
    self notify( "watchDisconnect" );
    self endon( "watchDisconnect" );

    self waittill( "disconnect" );

    zm_on_player_disconnect();
}

increment_dog_round_stat( stat )
{
    players = get_players();

    foreach ( player in players )
        player maps\mp\zombies\_zm_stats::increment_client_stat( "zdog_rounds_" + stat );
}

setup_player_navcard_hud()
{
    flag_wait( "start_zombie_round_logic" );
    thread refresh_player_navcard_hud();
}

refresh_player_navcard_hud()
{
    if ( !isdefined( level.navcards ) )
        return;

    players = get_players();

    foreach ( player in players )
    {
        navcard_bits = 0;

        for ( i = 0; i < level.navcards.size; i++ )
        {
            hasit = player maps\mp\zombies\_zm_stats::get_global_stat( level.navcards[i] );

            if ( isdefined( player.navcard_grabbed ) && player.navcard_grabbed == level.navcards[i] )
                hasit = 1;

            if ( hasit )
                navcard_bits += ( 1 << i );
        }

        wait_network_frame();
        player setclientfield( "navcard_held", 0 );

        if ( navcard_bits > 0 )
        {
            wait_network_frame();
            player setclientfield( "navcard_held", navcard_bits );
        }
    }
}

check_quickrevive_for_hotjoin( disconnecting_player )
{
    solo_mode = 0;
    subtract_num = 0;
    should_update = 0;

    if ( isdefined( disconnecting_player ) )
        subtract_num = 1;

    players = get_players();

    if ( players.size - subtract_num == 1 || isdefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive )
    {
        solo_mode = 1;

        if ( !flag( "solo_game" ) )
            should_update = 1;

        flag_set( "solo_game" );
    }
    else
    {
        if ( flag( "solo_game" ) )
            should_update = 1;

        flag_clear( "solo_game" );
    }

    level.using_solo_revive = solo_mode;
    level.revive_machine_is_solo = solo_mode;
    set_default_laststand_pistol( solo_mode );

    if ( should_update && isdefined( level.quick_revive_machine ) )
        update_quick_revive( solo_mode );
}

set_default_laststand_pistol( solo_mode )
{
    if ( !solo_mode )
        level.laststandpistol = level.default_laststandpistol;
    else
        level.laststandpistol = level.default_solo_laststandpistol;
}

update_quick_revive( solo_mode )
{
    if ( !isdefined( solo_mode ) )
        solo_mode = 0;

    clip = undefined;

    if ( isdefined( level.quick_revive_machine_clip ) )
        clip = level.quick_revive_machine_clip;

    level.quick_revive_machine thread maps\mp\zombies\_zm_perks::reenable_quickrevive( clip, solo_mode );
}

player_too_many_players_check()
{
    max_players = 4;

    if ( level.scr_zm_ui_gametype == "zgrief" || level.scr_zm_ui_gametype == "zmeat" )
        max_players = 8;

    if ( get_players().size > max_players )
    {
        maps\mp\zombies\_zm_game_module::freeze_players( 1 );
        level notify( "end_game" );
    }
}
