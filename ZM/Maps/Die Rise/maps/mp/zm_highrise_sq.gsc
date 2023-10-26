// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_highrise_sq_atd;
#include maps\mp\zm_highrise_sq_slb;
#include maps\mp\zm_highrise_sq_ssp;
#include maps\mp\zm_highrise_sq_pts;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zm_highrise_sq;

init()
{
    if ( isdefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
    {
        sq_easy_cleanup();
        return;
    }

    flag_init( "sq_disabled" );
    flag_init( "sq_branch_complete" );
    flag_init( "sq_tower_active" );
    flag_init( "sq_player_has_sniper" );
    flag_init( "sq_player_has_ballistic" );
    flag_init( "sq_ric_tower_complete" );
    flag_init( "sq_max_tower_complete" );
    flag_init( "sq_players_out_of_sync" );
    flag_init( "sq_ball_picked_up" );
    register_map_navcard( "navcard_held_zm_highrise", "navcard_held_zm_transit" );
    ss_buttons = getentarray( "sq_ss_button", "targetname" );

    for ( i = 0; i < ss_buttons.size; i++ )
    {
        ss_buttons[i] usetriggerrequirelookat();
        ss_buttons[i] sethintstring( "" );
        ss_buttons[i] setcursorhint( "HINT_NOICON" );
    }

    level thread mahjong_tiles_setup();
    flag_init( "sq_nav_built" );
    declare_sidequest( "sq", ::init_sidequest, ::sidequest_logic, ::complete_sidequest, ::generic_stage_start, ::generic_stage_complete );
    maps\mp\zm_highrise_sq_atd::init();
    maps\mp\zm_highrise_sq_slb::init();
    declare_sidequest( "sq_1", ::init_sidequest_1, ::sidequest_logic_1, ::complete_sidequest, ::generic_stage_start, ::generic_stage_complete );
    maps\mp\zm_highrise_sq_ssp::init_1();
    maps\mp\zm_highrise_sq_pts::init_1();
    declare_sidequest( "sq_2", ::init_sidequest_2, ::sidequest_logic_2, ::complete_sidequest, ::generic_stage_start, ::generic_stage_complete );
    maps\mp\zm_highrise_sq_ssp::init_2();
    maps\mp\zm_highrise_sq_pts::init_2();
    level thread init_navcard();
    level thread init_navcomputer();
    precache_sidequest_assets();
}

sq_highrise_clientfield_init()
{
    registerclientfield( "toplayer", "clientfield_sq_vo", 5000, 5, "int" );
    level.sq_clientfield_vo["none"] = 0;
    level.sq_clientfield_vo["vox_maxi_sidequest_activ_dragons_0"] = 1;
    level.sq_clientfield_vo["vox_maxi_sidequest_congratulate_0"] = 2;
    level.sq_clientfield_vo["vox_maxi_sidequest_create_trample_0"] = 3;
    level.sq_clientfield_vo["vox_maxi_sidequest_create_trample_1"] = 4;
    level.sq_clientfield_vo["vox_maxi_sidequest_create_trample_2"] = 5;
    level.sq_clientfield_vo["vox_maxi_sidequest_create_trample_3"] = 6;
    level.sq_clientfield_vo["vox_maxi_sidequest_create_trample_4"] = 7;
    level.sq_clientfield_vo["vox_maxi_sidequest_fail_0"] = 8;
    level.sq_clientfield_vo["vox_maxi_sidequest_fail_1"] = 9;
    level.sq_clientfield_vo["vox_maxi_sidequest_fail_2"] = 10;
    level.sq_clientfield_vo["vox_maxi_sidequest_fail_3"] = 11;
    level.sq_clientfield_vo["vox_maxi_sidequest_lion_balls_0"] = 12;
    level.sq_clientfield_vo["vox_maxi_sidequest_lion_balls_1"] = 13;
    level.sq_clientfield_vo["vox_maxi_sidequest_lion_balls_2"] = 14;
    level.sq_clientfield_vo["vox_maxi_sidequest_lion_balls_3"] = 15;
    level.sq_clientfield_vo["vox_maxi_sidequest_lion_balls_4"] = 16;
    level.sq_clientfield_vo["vox_maxi_sidequest_max_com_0"] = 17;
    level.sq_clientfield_vo["vox_maxi_sidequest_max_com_1"] = 18;
    level.sq_clientfield_vo["vox_maxi_sidequest_max_com_2"] = 19;
    level.sq_clientfield_vo["vox_maxi_sidequest_punch_tower_0"] = 20;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_0"] = 21;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_1"] = 22;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_2"] = 23;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_3"] = 24;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_4"] = 25;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_5"] = 26;
    level.sq_clientfield_vo["vox_maxi_sidequest_reincar_zombie_6"] = 27;
    level.sq_clientfield_vo["vox_maxi_sidequest_sec_symbols_0"] = 28;
    level.sq_clientfield_vo["vox_maxi_sidequest_sec_symbols_1"] = 29;
    level.sq_clientfield_vo["vox_maxi_sidequest_sniper_rifle_0"] = 30;
    level.sq_clientfield_vo["vox_maxi_sidequest_tower_complete_0"] = 31;
}

sq_easy_cleanup()
{
    computer_buildable_trig = getent( "sq_common_buildable_trigger", "targetname" );
    computer_buildable_trig delete();
    sq_buildables = getentarray( "buildable_sq_common", "targetname" );

    foreach ( item in sq_buildables )
        item delete();

    a_balls = getentarray( "sq_dragon_lion_ball", "targetname" );
    array_delete( a_balls );
    a_tiles = getentarray( "mahjong_tile", "script_noteworthy" );
    array_delete( a_tiles );
    a_emblems_lit = getentarray( "elevator_dragon_lit", "targetname" );
    array_delete( a_emblems_lit );
    a_emblems = getentarray( "elevator_dragon_icon", "targetname" );
    array_delete( a_emblems );
    a_emblems = getentarray( "atd2_marker_lit", "targetname" );
    array_delete( a_emblems );
}

init_player_sidequest_stats()
{
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_highrise_started", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_held_zm_transit", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_held_zm_highrise", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_held_zm_buried", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_applied_zm_highrise", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_highrise_maxis_reset", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_highrise_rich_reset", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_highrise_rich_complete", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_highrise_maxis_complete", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_highrise_last_completed", 0 );
}

start_highrise_sidequest()
{
    flag_wait( "start_zombie_round_logic" );
    sidequest_start( "sq" );
}

#using_animtree("fxanim_props");

init_sidequest()
{
    players = get_players();
    thread sq_refresh_player_navcard_hud();
    a_balls = getentarray( "sq_sliquify_ball", "targetname" );

    foreach ( m_ball in a_balls )
    {
        m_ball.can_pickup = 0;
        m_ball hide();
    }

    scriptmodelsuseanimtree( #animtree );
    level.scr_anim["fxanim_props"]["trample_gen_ab"] = %fxanim_zom_highrise_trample_gen_ab_anim;
    level.scr_anim["fxanim_props"]["trample_gen_ba"] = %fxanim_zom_highrise_trample_gen_ba_anim;
    level.scr_anim["fxanim_props"]["trample_gen_cd"] = %fxanim_zom_highrise_trample_gen_cd_anim;
    level.scr_anim["fxanim_props"]["trample_gen_dc"] = %fxanim_zom_highrise_trample_gen_dc_anim;
    level thread vo_maxis_do_quest();
    level thread vo_weapon_watcher();
    level.maxcompleted = 0;
    level.richcompleted = 0;

    foreach ( player in players )
    {
        player.highrise_sq_started = 1;
        lastcompleted = player maps\mp\zombies\_zm_stats::get_global_stat( "sq_highrise_last_completed" );

        if ( lastcompleted == 1 )
        {
            level.richcompleted = 1;
            continue;
        }

        if ( lastcompleted == 2 )
            level.maxcompleted = 1;
    }

    if ( level.richcompleted )
    {
        if ( level.maxcompleted )
            flag_set( "sq_players_out_of_sync" );
        else
            tower_in_sync_lightning();

        exploder( 1003 );
    }

    if ( level.maxcompleted )
    {
        if ( !flag( "sq_players_out_of_sync" ) )
            tower_in_sync_lightning();

        exploder( 903 );
    }
}

init_sidequest_1()
{

}

init_sidequest_2()
{

}

generic_stage_start()
{
/#
    level thread cheat_complete_stage();
#/
    level._stage_active = 1;
}

cheat_complete_stage()
{
    level endon( "reset_sundial" );

    while ( true )
    {
        if ( getdvar( _hash_1186DB2D ) != "" )
        {
            if ( isdefined( level._last_stage_started ) )
            {
                setdvar( "cheat_sq", "" );
                stage_completed( "sq", level._last_stage_started );
            }
        }

        wait 0.1;
    }
}

sidequest_logic()
{
    level thread temp_test_fx();

    if ( is_true( level.maxcompleted ) && is_true( level.richcompleted ) )
        return;

    level thread watch_nav_computer_built();
    flag_wait( "power_on" );
    level thread vo_richtofen_power_on();
    flag_wait( "sq_nav_built" );

    if ( !is_true( level.navcomputer_spawned ) )
        update_sidequest_stats( "sq_highrise_started" );

    level thread navcomputer_waitfor_navcard();
    stage_start( "sq", "atd" );

    level waittill( "sq_atd_over" );

    stage_start( "sq", "slb" );

    level waittill( "sq_slb_over" );

    if ( !is_true( level.richcompleted ) )
        level thread sidequest_start( "sq_1" );

    if ( !is_true( level.maxcompleted ) )
        level thread sidequest_start( "sq_2" );

    flag_wait( "sq_branch_complete" );
    tower_punch_watcher();

    if ( flag( "sq_ric_tower_complete" ) )
        update_sidequest_stats( "sq_highrise_rich_complete" );
    else if ( flag( "sq_max_tower_complete" ) )
        update_sidequest_stats( "sq_highrise_maxis_complete" );
}

sidequest_logic_1()
{
    stage_start( "sq_1", "ssp_1" );

    level waittill( "sq_1_ssp_1_over" );

    stage_start( "sq_1", "pts_1" );

    level waittill( "sq_1_pts_1_over" );

    flag_set( "sq_branch_complete" );
    flag_set( "sq_ric_tower_complete" );
    exploder( 1001 );
    clientnotify( "start_fireball_dragon_b" );
    wait 0.1;
    clientnotify( "fxanim_dragon_b_start" );
    wait( getanimlength( %fxanim_zom_highrise_dragon_b_anim ) );
    exploder( 1002 );
    level thread vo_richtofen_punch_tower();
}

sidequest_logic_2()
{
    stage_start( "sq_2", "ssp_2" );

    level waittill( "sq_2_ssp_2_over" );

    stage_start( "sq_2", "pts_2" );

    level waittill( "sq_2_pts_2_over" );

    exploder( 901 );
    clientnotify( "start_fireball_dragon_a" );
    wait 0.1;
    clientnotify( "fxanim_dragon_a_start" );
    wait( getanimlength( %fxanim_zom_highrise_dragon_a_anim ) );
    exploder( 902 );
    flag_set( "sq_branch_complete" );
    flag_set( "sq_max_tower_complete" );
    level thread vo_maxis_punch_tower();
}

watch_nav_computer_built()
{
    if ( !is_true( level.navcomputer_spawned ) )
        wait_for_buildable( "sq_common" );

    flag_set( "sq_nav_built" );
}

get_specific_player( num )
{
    players = get_players();
    return undefined;
}

tower_punch_watcher()
{
    level thread playtoweraudio();
    a_leg_trigs = [];

    foreach ( str_wind in level.a_wind_order )
        a_leg_trigs[a_leg_trigs.size] = "sq_tower_" + str_wind;

    level.n_cur_leg = 0;
    level.sq_leg_punches = 0;

    foreach ( str_leg in a_leg_trigs )
    {
        t_leg = getent( str_leg, "script_noteworthy" );
        t_leg thread tower_punch_watch_leg( a_leg_trigs );
    }

    flag_wait( "sq_tower_active" );
/#
    iprintlnbold( "TOWER ACTIVE" );
#/
    if ( flag( "sq_ric_tower_complete" ) )
    {
        exploder_stop( 1002 );
        exploder_stop( 903 );
        exploder( 1003 );
    }
    else
    {
        exploder_stop( 902 );
        exploder_stop( 1003 );
        exploder( 903 );
    }

    wait 1;
    level thread tower_in_sync_lightning();
    wait 1;
    level thread sq_give_all_perks();
}

tower_in_sync_lightning()
{
    s_tower_top = getstruct( "sq_zombie_launch_target", "targetname" );
    playfx( level._effect["sidequest_tower_bolts"], s_tower_top.origin - vectorscale( ( 0, 0, 1 ), 88.0 ), ( 0, 0, 1 ) );
}

playtoweraudio()
{
    origin = ( 2207, 682, 3239 );
    ent = spawn( "script_origin", origin );
    ent playsound( "zmb_sq_tower_powerup_start_1" );
    ent playloopsound( "zmb_sq_tower_powerup_loop_1", 1 );
    flag_wait( "sq_tower_active" );
    ent stoploopsound( 2 );
    ent playsound( "zmb_sq_tower_powerup_start_2" );
    wait 2;
    ent playloopsound( "zmb_sq_tower_powerup_loop_2", 1 );
}

tower_punch_watch_leg( a_leg_trigs )
{
    while ( !flag( "sq_tower_active" ) )
    {
        self waittill( "trigger", who );

        if ( level.n_cur_leg < a_leg_trigs.size && isplayer( who ) && ( who.current_melee_weapon == "tazer_knuckles_zm" || who.current_melee_weapon == "tazer_knuckles_upgraded_zm" ) )
        {
            if ( self.script_noteworthy == a_leg_trigs[level.n_cur_leg] )
            {
                level.n_cur_leg++;
                self playsound( "zmb_sq_leg_powerup_" + level.n_cur_leg );

                if ( level.n_cur_leg == 4 )
                    flag_set( "sq_tower_active" );
            }
            else
            {
                level.n_cur_leg = 0;
                self playsound( "zmb_sq_leg_powerdown" );
            }

            level.sq_leg_punches++;
            self playsound( "zmb_sq_leg_powerup_" + level.sq_leg_punches );

            if ( level.sq_leg_punches >= 4 && !flag( "sq_tower_active" ) )
            {
                wait 1;
                self playsound( "zmb_sq_leg_powerdown" );
                exploder_stop( 1002 );
                exploder_stop( 902 );
                cur_round = level.round_number;

                level waittill( "start_of_round" );

                level.sq_leg_punches = 0;
                wait 2;

                if ( flag( "sq_ric_tower_complete" ) )
                    exploder( 1002 );
                else
                    exploder( 902 );
            }
        }
    }
}

mahjong_tiles_setup()
{
    a_winds = array_randomize( array( "north", "south", "east", "west" ) );
    a_colors = array_randomize( array( "blk", "blu", "grn", "red" ) );
    a_locs = array_randomize( getstructarray( "sq_tile_loc_random", "targetname" ) );
    assert( a_locs.size > a_winds.size, "zm_highrise_sq: not enough locations for mahjong tiles!" );
    a_wind_order = array( "none" );

    for ( i = 0; i < a_winds.size; i++ )
    {
        a_wind_order[a_wind_order.size] = a_winds[i];
        m_wind_tile = getent( "tile_" + a_winds[i] + "_" + a_colors[i], "targetname" );
        m_wind_tile.script_noteworthy = undefined;
        s_spot = a_locs[i];

        if ( a_winds[i] == "north" )
            s_spot = getstruct( "sq_tile_loc_north", "targetname" );

        m_wind_tile.origin = s_spot.origin;
        m_wind_tile.angles = s_spot.angles;
    }

    for ( i = 0; i < a_colors.size; i++ )
    {
        m_num_tile = getent( "tile_" + ( i + 1 ) + "_" + a_colors[i], "targetname" );
        m_num_tile.script_noteworthy = undefined;
        s_spot = a_locs[i + a_winds.size];
        m_num_tile.origin = s_spot.origin;
        m_num_tile.angles = s_spot.angles;
    }

    a_tiles = getentarray( "mahjong_tile", "script_noteworthy" );
    array_delete( a_tiles );
    level.a_wind_order = a_winds;
}

light_dragon_fireworks( str_dragon, n_num_fireworks )
{
    for ( i = 0; i < n_num_fireworks; i++ )
    {
        wait 1;
        clientnotify( str_dragon + "_start_firework" );
        wait 1;
    }
}

temp_test_fx()
{
    n_index = 0;

    level waittill( "temp_play_next_sq_fx" );

    clientnotify( "r_drg_tail" );
    clientnotify( "m_drg_tail" );

    while ( n_index < 7 )
    {
        level waittill( "temp_play_next_sq_fx" );

        clientnotify( "r_start_firework" );
        clientnotify( "m_start_firework" );
        n_index++;
    }

    level waittill( "temp_play_next_sq_fx" );

    exploder( 901 );
    clientnotify( "start_fireball_dragon_b" );
    wait 0.1;
    clientnotify( "fxanim_dragon_b_start" );

    level waittill( "temp_play_next_sq_fx" );

    clientnotify( "start_fireball_dragon_a" );
    wait 0.1;
    clientnotify( "fxanim_dragon_a_start" );

    level waittill( "temp_play_next_sq_fx" );

    wait 1;
    exploder( 902 );
    wait 1;
    exploder( 903 );

    level waittill( "temp_play_next_sq_fx" );

    stop_exploder( 901 );
    stop_exploder( 902 );
    stop_exploder( 903 );
    exploder( 1001 );
    exploder( 1002 );
    exploder( 1003 );
}

generic_stage_complete()
{
    level._stage_active = 0;
}

complete_sidequest()
{
    level thread sidequest_done();
}

sidequest_done()
{

}

get_variant_from_entity_num( player_number = 0 )
{
    post_fix = "a";

    switch ( player_number )
    {
        case 0:
            post_fix = "a";
            break;
        case 1:
            post_fix = "b";
            break;
        case 2:
            post_fix = "c";
            break;
        case 3:
            post_fix = "d";
            break;
    }

    return post_fix;
}

init_navcard()
{
    flag_wait( "start_zombie_round_logic" );
    spawn_card = 1;
    players = get_players();

    foreach ( player in players )
    {
        has_card = does_player_have_map_navcard( player );

        if ( has_card )
        {
            player.navcard_grabbed = level.map_navcard;
            spawn_card = 0;
        }
    }

    thread sq_refresh_player_navcard_hud();

    if ( !spawn_card )
        return;

    model = "p6_zm_keycard";
    org = ( 1743, 1070, 3244.5 );
    angles = ( 0, 0, 0 );
    maps\mp\zombies\_zm_utility::place_navcard( model, level.map_navcard, org, angles );
}

init_navcomputer()
{
    flag_wait( "start_zombie_round_logic" );
    spawn_navcomputer = 1;
    players = get_players();

    foreach ( player in players )
    {
        built_comptuer = player maps\mp\zombies\_zm_stats::get_global_stat( "sq_highrise_started" );

        if ( !built_comptuer )
        {
            spawn_navcomputer = 0;
            break;
        }
    }

    if ( !spawn_navcomputer )
        return;

    level.navcomputer_spawned = 1;
    get_players()[0] maps\mp\zombies\_zm_buildables::player_finish_buildable( level.sq_buildable.buildablezone );

    if ( isdefined( level.sq_buildable ) && isdefined( level.sq_buildable.model ) )
    {
        buildable = level.sq_buildable.buildablezone;

        for ( i = 0; i < buildable.pieces.size; i++ )
        {
            if ( isdefined( buildable.pieces[i].model ) )
            {
                buildable.pieces[i].model delete();
                maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( buildable.pieces[i].unitrigger );
            }

            if ( isdefined( buildable.pieces[i].part_name ) )
            {
                buildable.stub.model notsolid();
                buildable.stub.model show();
                buildable.stub.model showpart( buildable.pieces[i].part_name );
            }
        }
    }
}

navcomputer_waitfor_navcard()
{
    spawn_trigger = 1;
    players = get_players();

    foreach ( player in players )
    {
        card_swiped = player maps\mp\zombies\_zm_stats::get_global_stat( "navcard_applied_zm_highrise" );

        if ( card_swiped )
        {
            spawn_trigger = 0;
            break;
        }
    }

    if ( !spawn_trigger )
        return;

    computer_buildable_trig = getent( "sq_common_buildable_trigger", "targetname" );
    trig_pos = getstruct( "sq_common_key", "targetname" );
    navcomputer_use_trig = spawn( "trigger_radius_use", trig_pos.origin, 0, 48, 48 );
    navcomputer_use_trig setcursorhint( "HINT_NOICON" );
    navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_USE" );
    navcomputer_use_trig triggerignoreteam();

    while ( true )
    {
        navcomputer_use_trig waittill( "trigger", who );

        if ( isplayer( who ) && is_player_valid( who ) )
        {
            if ( does_player_have_correct_navcard( who ) )
            {
                navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_SUCCESS" );
                who playsound( "zmb_sq_navcard_success" );
                update_sidequest_stats( "navcard_applied_zm_highrise" );
                who.navcard_grabbed = undefined;
                wait 1;
                navcomputer_use_trig delete();
                return;
            }
            else
            {
                navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_FAIL" );
                who playsound( "zmb_sq_navcard_fail" );
                wait 1;
                navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_USE" );
            }
        }
    }
}

update_sidequest_stats( stat_name )
{
    maxis_complete = 0;
    rich_complete = 0;
    started = 0;

    if ( stat_name == "sq_highrise_maxis_complete" )
        maxis_complete = 1;
    else if ( stat_name == "sq_highrise_rich_complete" )
        rich_complete = 1;

    players = get_players();

    foreach ( player in players )
    {
        if ( stat_name == "sq_highrise_started" )
            player.highrise_sq_started = 1;
        else if ( stat_name == "navcard_applied_zm_highrise" )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( level.navcard_needed, 0 );
            thread sq_refresh_player_navcard_hud();
        }
        else if ( !is_true( player.highrise_sq_started ) )
            continue;

        if ( rich_complete )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( "sq_highrise_last_completed", 1 );
            incrementcounter( "global_zm_total_rich_sq_complete_highrise", 1 );
        }
        else if ( maxis_complete )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( "sq_highrise_last_completed", 2 );
            incrementcounter( "global_zm_total_max_sq_complete_highrise", 1 );
        }

        player maps\mp\zombies\_zm_stats::increment_client_stat( stat_name, 0 );
    }

    if ( rich_complete || maxis_complete )
        level notify( "highrise_sidequest_achieved" );
}

sq_give_all_perks()
{
    vending_triggers = getentarray( "zombie_vending", "targetname" );
    perks = [];

    for ( i = 0; i < vending_triggers.size; i++ )
    {
        perk = vending_triggers[i].script_noteworthy;

        if ( perk == "specialty_weapupgrade" )
            continue;

        perks[perks.size] = perk;
    }

    if ( flag( "sq_ric_tower_complete" ) )
    {
        v_fireball_start_loc = ( 1946, 608, 3338 );
        n_fireball_exploder = 1001;
    }
    else
    {
        v_fireball_start_loc = ( 1068, -1362, 3340.5 );
        n_fireball_exploder = 901;
    }

    players = getplayers();

    foreach ( player in players )
    {
        player thread sq_give_player_perks( perks, v_fireball_start_loc, n_fireball_exploder );

        level waittill( "sq_fireball_hit_player" );
    }
}

sq_give_player_perks( perks, v_fireball_start_loc, n_fireball_exploder )
{
    exploder( n_fireball_exploder );
    m_fireball = spawn( "script_model", v_fireball_start_loc );
    m_fireball setmodel( "tag_origin" );
    playfxontag( level._effect["sidequest_dragon_fireball_max"], m_fireball, "tag_origin" );

    do
    {
        wait_network_frame();
        v_to_player = vectornormalize( self gettagorigin( "J_SpineLower" ) - m_fireball.origin );
        v_move_spot = m_fireball.origin + v_to_player * 48;
        m_fireball.origin = v_move_spot;
    }
    while ( distancesquared( m_fireball.origin, self gettagorigin( "J_SpineLower" ) ) > 2304 );

    m_fireball.origin = self gettagorigin( "J_SpineLower" );
    m_fireball linkto( self, "J_SpineLower" );
    wait 1.5;
    playfx( level._effect["sidequest_flash"], m_fireball.origin );
    m_fireball delete();
    level notify( "sq_fireball_hit_player" );

    foreach ( perk in perks )
    {
        if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
            continue;

        if ( self hasperk( perk ) || self maps\mp\zombies\_zm_perks::has_perk_paused( perk ) )
            continue;

        self maps\mp\zombies\_zm_perks::give_perk( perk, 0 );
        wait 1;
    }
}

sq_refresh_player_navcard_hud_internal()
{
    self endon( "disconnect" );
    navcard_bits = 0;

    for ( i = 0; i < level.navcards.size; i++ )
    {
        hasit = self maps\mp\zombies\_zm_stats::get_global_stat( level.navcards[i] );

        if ( isdefined( self.navcard_grabbed ) && self.navcard_grabbed == level.navcards[i] )
            hasit = 1;

        if ( hasit )
            navcard_bits += ( 1 << i );
    }

    wait_network_frame();
    self setclientfield( "navcard_held", 0 );

    if ( navcard_bits > 0 )
    {
        wait_network_frame();
        self setclientfield( "navcard_held", navcard_bits );
    }
}

sq_refresh_player_navcard_hud()
{
    if ( !isdefined( level.navcards ) )
        return;

    players = get_players();

    foreach ( player in players )
        player thread sq_refresh_player_navcard_hud_internal();
}

vo_maxis_do_quest()
{
    wait 20;

    if ( 1 )
        maxissay( "vox_maxi_sidequest_max_com_0" );
    else
    {
        maxissay( "vox_maxi_sidequest_max_com_1" );
        maxissay( "vox_maxi_sidequest_max_com_2" );
    }
}

vo_richtofen_power_on()
{
    wait 6;
    richtofensay( "vox_zmba_sidequest_power_on_0" );
}

vo_richtofen_nav_card()
{
    switch ( self.characterindex )
    {
        case 2:
            break;
        case 0:
            break;
        case 3:
            break;
        case 1:
            break;
    }

    if ( 1 )
        level thread vo_maxis_first_tower();
    else if ( 0 )
        level thread vo_richtofen_first_tower();
}

vo_richtofen_first_tower()
{
    richtofensay( "vox_zmba_sidequest_congratulate_0" );
    richtofensay( "vox_zmba_sidequest_congratulate_1" );
}

vo_maxis_first_tower()
{
    maxissay( "vox_maxi_sidequest_congratulate_0" );
}

vo_find_nav_card()
{
    switch ( self.characterindex )
    {
        case 2:
            break;
        case 0:
            break;
        case 3:
            break;
        case 1:
            break;
    }
}

vo_maxis_find_sniper()
{
    maxissay( "vox_maxi_sidequest_sniper_rifle_0" );
}

vo_richtofen_find_sniper()
{
    richtofensay( "vox_zmba_sidequest_sniper_rifle_0" );
    wait 10;
    richtofensay( "vox_zmba_sidequest_sniper_rifle_1" );
}

vo_maxis_player_has_pap_ballistic()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_reincar_zombie_2" );
}

vo_richtofen_punch_tower()
{
    richtofensay( "vox_zmba_sidequest_punch_tower_0" );
    richtofensay( "vox_zmba_sidequest_punch_tower_1" );
    richtofensay( "vox_zmba_sidequest_punch_tower_2" );
    richtofensay( "vox_zmba_sidequest_punch_tower_3" );
}

vo_maxis_punch_tower()
{
    maxissay( "vox_maxi_sidequest_punch_tower_0" );
}

vo_weapon_watcher()
{
    while ( !flag( "sq_player_has_sniper" ) || !flag( "sq_player_has_ballistic" ) )
    {
        players = getplayers();

        foreach ( player in players )
        {
            if ( !flag( "sq_player_has_sniper" ) && isdefined( player.currentweapon ) && sq_is_weapon_sniper( player.currentweapon ) )
            {
                flag_set( "sq_player_has_sniper" );

                if ( isdefined( level.rich_sq_player ) && is_player_valid( level.rich_sq_player ) && player == level.rich_sq_player )
                    level thread vo_richtofen_find_sniper();
                else
                    level thread vo_maxis_find_sniper();

                continue;
            }

            if ( !flag( "sq_player_has_ballistic" ) && isdefined( player.currentweapon ) && player.currentweapon == "knife_ballistic_upgraded_zm" )
            {
                flag_set( "sq_player_has_ballistic" );
                level thread vo_maxis_player_has_pap_ballistic();
            }
        }

        wait 1;
    }
}

sq_is_weapon_sniper( str_weapon )
{
    a_snipers = array( "dsr50", "barretm82", "svu" );

    foreach ( str_sniper in a_snipers )
    {
        if ( issubstr( str_weapon, str_sniper ) )
            return true;
    }

    return false;
}

richtofensay( vox_line, time )
{
    level endon( "end_game" );
    level endon( "intermission" );

    if ( is_true( level.intermission ) )
        return;

    if ( is_true( level.richcompleted ) )
        return;

    level endon( "richtofen_c_complete" );

    if ( !isdefined( time ) )
        time = 2;

    while ( is_true( level.richtofen_talking_to_samuel ) )
        wait 1;

    if ( isdefined( level.rich_sq_player ) && is_player_valid( level.rich_sq_player ) )
    {
/#
        iprintlnbold( "Richtoffen Says: " + vox_line );
#/
        level.rich_sq_player playsoundtoplayer( vox_line, level.rich_sq_player );

        if ( !is_true( level.richtofen_talking_to_samuel ) )
            level thread richtofen_talking( time );
    }
}

richtofen_talking( time )
{
    level.rich_sq_player.dontspeak = 1;
    level.richtofen_talking_to_samuel = 1;
    wait( time );
    level.richtofen_talking_to_samuel = 0;

    if ( isdefined( level.rich_sq_player ) )
        level.rich_sq_player.dontspeak = 0;
}

maxissay( line )
{
    level endon( "end_game" );
    level endon( "intermission" );

    if ( is_true( level.maxcompleted ) )
        return;

    if ( is_true( level.intermission ) )
        return;

    while ( is_true( level.maxis_talking ) )
        wait 0.05;

    level.maxis_talking = 1;
/#
    iprintlnbold( "Maxis Says: " + line );
#/
    players = getplayers();

    foreach ( player in players )
        player setclientfieldtoplayer( "clientfield_sq_vo", level.sq_clientfield_vo[line] );

    wait 10;
    level.maxis_talking = 0;
}
