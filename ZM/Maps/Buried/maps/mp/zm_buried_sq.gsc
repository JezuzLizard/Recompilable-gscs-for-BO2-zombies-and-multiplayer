// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\_visionset_mgr;
#include maps\mp\zm_buried_sq_bt;
#include maps\mp\zm_buried_sq_mta;
#include maps\mp\zm_buried_sq_gl;
#include maps\mp\zm_buried_sq_ftl;
#include maps\mp\zm_buried_sq_ll;
#include maps\mp\zm_buried_sq_ts;
#include maps\mp\zm_buried_sq_ctw;
#include maps\mp\zm_buried_sq_tpo;
#include maps\mp\zm_buried_sq_ip;
#include maps\mp\zm_buried_sq_ows;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_buried_amb;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_score;

init()
{
    level thread sq_prestart_hide();

    if ( !is_sidequest_allowed( "zclassic" ) )
    {
        sq_easy_cleanup();
        return;
    }

    sq_buried_register_visionset();
    register_map_navcard( "navcard_held_zm_buried", "navcard_held_zm_highrise" );
    ss_buttons = getentarray( "sq_ss_button", "targetname" );

    for ( i = 0; i < ss_buttons.size; i++ )
    {
        ss_buttons[i] usetriggerrequirelookat();
        ss_buttons[i] sethintstring( "" );
        ss_buttons[i] setcursorhint( "HINT_NOICON" );
    }

    flag_init( "sq_players_out_of_sync" );
    flag_init( "sq_nav_built" );
    flag_init( "sq_is_ric_tower_built" );
    flag_init( "sq_is_max_tower_built" );
    flag_init( "sq_amplifiers_broken" );
    flag_init( "sq_wisp_success" );
    flag_init( "sq_intro_vo_done" );
    flag_init( "sq_started" );
    sq_assign_signs();
    declare_sidequest( "sq", ::init_sidequest, ::sidequest_logic, ::complete_sidequest, ::generic_stage_start, ::generic_stage_complete );
    maps\mp\zm_buried_sq_bt::init();
    maps\mp\zm_buried_sq_mta::init();
    maps\mp\zm_buried_sq_gl::init();
    maps\mp\zm_buried_sq_ftl::init();
    maps\mp\zm_buried_sq_ll::init();
    maps\mp\zm_buried_sq_ts::init();
    maps\mp\zm_buried_sq_ctw::init();
    maps\mp\zm_buried_sq_tpo::init();
    maps\mp\zm_buried_sq_ip::init();
    maps\mp\zm_buried_sq_ows::init();
    level thread init_navcard();
    level thread init_navcomputer();
    level thread navcomputer_waitfor_navcard();
    level thread sq_metagame();
    onplayerconnect_callback( ::sq_metagame_on_player_connect );
    precache_sidequest_assets();
/#
    level thread setup_sq_debug();
#/
    level thread end_game_reward_richtofen_wrapper();
    level thread end_game_reward_maxis_wrapper();
    flag_wait( "start_zombie_round_logic" );
    sidequest_start( "sq" );
}

precache_sq()
{
    precachemodel( "p6_zm_bu_lantern_silver_on" );
    precachemodel( "p6_zm_bu_ether_amplifier" );
    precachemodel( "p6_zm_bu_ether_amplifier_dmg" );
    precachemodel( "p6_zm_bu_sign_tunnel_bone" );
    precachemodel( "p6_zm_bu_sign_tunnel_consumption" );
    precachemodel( "p6_zm_bu_sign_tunnel_dry" );
    precachemodel( "p6_zm_bu_sign_tunnel_ground" );
    precachemodel( "p6_zm_bu_sign_tunnel_lunger" );
    precachemodel( "p6_zm_bu_gallows" );
    precachemodel( "p6_zm_bu_guillotine" );
    precachemodel( "p6_zm_bu_end_game_machine" );
    precachemodel( "p6_zm_bu_button" );
    precachemodel( "p6_zm_bu_sign_tunnel_bone_code" );
    precachemodel( "p6_zm_bu_sign_tunnel_consump_code" );
    precachemodel( "p6_zm_bu_sign_tunnel_dry_code" );
    precachemodel( "p6_zm_bu_sign_tunnel_ground_code" );
    precachemodel( "p6_zm_bu_sign_tunnel_lunger_code" );
    precachemodel( "p6_zm_bu_maze_switch_red" );
    precachemodel( "p6_zm_bu_maze_switch_green" );
    precachemodel( "p6_zm_bu_maze_switch_blue" );
    precachemodel( "p6_zm_bu_maze_switch_yellow" );
    precachemodel( "p6_zm_bu_target" );
    precachemodel( "fxanim_zom_buried_orbs_mod" );
    precachevehicle( "heli_quadrotor2_zm" );
}

sq_prestart_hide()
{

}

sq_buried_clientfield_init()
{
    registerclientfield( "actor", "buried_sq_maxis_ending_update_eyeball_color", 12000, 1, "int" );
    registerclientfield( "scriptmover", "AmplifierShaderConstant", 12000, 5, "float" );
    registerclientfield( "scriptmover", "vulture_wisp", 12000, 1, "int" );
    registerclientfield( "world", "vulture_wisp_orb_count", 12000, 3, "int" );
    registerclientfield( "world", "sq_tpo_special_round_active", 12000, 1, "int" );
    registerclientfield( "world", "buried_sq_maxis_ending", 12000, 1, "int" );
    registerclientfield( "world", "buried_sq_richtofen_ending", 12000, 1, "int" );
    registerclientfield( "world", "sq_gl_b_vt", 12000, 1, "int" );
    registerclientfield( "world", "sq_gl_b_bb", 12000, 1, "int" );
    registerclientfield( "world", "sq_gl_b_a", 12000, 1, "int" );
    registerclientfield( "world", "sq_gl_b_ws", 12000, 1, "int" );
    registerclientfield( "world", "sq_ctw_m_t_l", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_animate", 12000, 1, "int" );
    registerclientfield( "world", "buried_sq_egm_bulb_0", 12000, 1, "int" );
    registerclientfield( "world", "buried_sq_egm_bulb_1", 12000, 1, "int" );
    registerclientfield( "world", "buried_sq_egm_bulb_2", 12000, 1, "int" );
    registerclientfield( "world", "buried_sq_egm_0_0", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_0_1", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_0_2", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_1_0", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_1_1", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_1_2", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_2_0", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_2_1", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_2_2", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_3_0", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_3_1", 12000, 2, "int" );
    registerclientfield( "world", "buried_sq_egm_3_2", 12000, 2, "int" );
    registerclientfield( "scriptmover", "buried_sq_bp_set_lightboard", 13000, 1, "int" );
    registerclientfield( "world", "buried_sq_bp_light_01", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_02", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_03", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_04", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_05", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_06", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_07", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_08", 13000, 2, "int" );
    registerclientfield( "world", "buried_sq_bp_light_09", 13000, 2, "int" );
}

sq_buried_register_visionset()
{
    vsmgr_register_info( "visionset", "cheat_bw", 12000, 17, 1, 1 );
}

sq_easy_cleanup()
{
    computer_buildable_trig = getent( "sq_common_buildable_trigger", "targetname" );
    computer_buildable_trig delete();
    sq_buildables = getentarray( "buildable_sq_common", "targetname" );

    foreach ( item in sq_buildables )
        item delete();

    t_generator = getent( "generator_use_trigger", "targetname" );

    if ( isdefined( t_generator ) )
        t_generator delete();

    gallow_col = getentarray( "gallow_col", "targetname" );

    foreach ( collmap in gallow_col )
    {
        collmap connectpaths();
        collmap delete();
    }
}

init_player_sidequest_stats()
{
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_buried_started", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_held_zm_transit", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_held_zm_highrise", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_held_zm_buried", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "navcard_applied_zm_buried", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_buried_maxis_reset", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_buried_rich_reset", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_buried_rich_complete", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_buried_maxis_complete", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "sq_buried_last_completed", 0 );
}

init_sidequest()
{
    sq_spawn_props();
    players = get_players();
    thread sq_refresh_player_navcard_hud();
    level.maxcompleted = 0;
    level.richcompleted = 0;
    level.m_sq_start_sign = undefined;

    foreach ( player in players )
    {
        player.buried_sq_started = 1;
        lastcompleted = player maps\mp\zombies\_zm_stats::get_global_stat( "sq_buried_last_completed" );

        if ( lastcompleted == 1 )
        {
            level.richcompleted = 1;
            continue;
        }

        if ( lastcompleted == 2 )
            level.maxcompleted = 1;
    }

    level waittill( "buildables_setup" );

    if ( level.richcompleted )
    {
        if ( !level.maxcompleted )
            playfx_on_tower( "sq_tower_bolts" );
        else
            flag_set( "sq_players_out_of_sync" );

        playfx_on_tower( "sq_tower_r" );
        a_model_names = array( "p6_zm_bu_sq_crystal", "p6_zm_bu_sq_satellite_dish" );
        a_pieces = level.sq_rtower_buildable.buildablezone.pieces;
        sq_delete_tower_pieces( a_model_names, a_pieces );
    }

    if ( level.maxcompleted )
    {
        if ( !level.richcompleted )
            playfx_on_tower( "sq_tower_bolts" );

        playfx_on_tower( "sq_tower_m" );
        a_model_names = array( "p6_zm_bu_sq_vaccume_tube", "p6_zm_bu_sq_buildable_battery" );
        a_pieces = level.sq_mtower_buildable.buildablezone.pieces;
        sq_delete_tower_pieces( a_model_names, a_pieces );
    }
}

sq_delete_tower_pieces( a_model_names, a_pieces )
{
    foreach ( piece in a_pieces )
    {
        foreach ( str_model in a_model_names )
        {
            if ( piece.modelname == str_model )
                piece maps\mp\zombies\_zm_buildables::piece_unspawn();
        }
    }
}

sq_metagame_clear_tower_pieces()
{
    a_model_names = array( "p6_zm_bu_sq_crystal", "p6_zm_bu_sq_satellite_dish", "p6_zm_bu_sq_vaccume_tube", "p6_zm_bu_sq_buildable_battery", "p6_zm_bu_sq_antenna", "p6_zm_bu_sq_wire_spool" );
    a_pieces = level.sq_rtower_buildable.buildablezone.pieces;
    sq_delete_tower_pieces( a_model_names, a_pieces );
    a_pieces = level.sq_mtower_buildable.buildablezone.pieces;
    sq_delete_tower_pieces( a_model_names, a_pieces );
    players = get_players();

    foreach ( player in players )
    {
        piece = player maps\mp\zombies\_zm_buildables::player_get_buildable_piece( 2 );

        if ( !isdefined( piece ) )
            continue;

        foreach ( str_model in a_model_names )
        {
            if ( piece.modelname == str_model )
                player maps\mp\zombies\_zm_buildables::player_destroy_piece( piece );
        }
    }
}

sq_spawn_props()
{
    sq_spawn_model_at_struct( "sq_guillotine", "p6_zm_bu_guillotine" );
}

sq_spawn_model_at_struct( str_struct, str_model )
{
    s_struct = getstruct( str_struct, "targetname" );

    if ( !isdefined( s_struct ) )
        return undefined;

    m_prop = spawn( "script_model", s_struct.origin );
    m_prop.angles = s_struct.angles;
    m_prop setmodel( str_model );
    m_prop.targetname = str_struct;
    return m_prop;
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
    level thread watch_nav_computer_built();

    if ( isdefined( level.maxcompleted ) && level.maxcompleted && ( isdefined( level.richcompleted ) && level.richcompleted ) )
    {
        flag_set( "sq_intro_vo_done" );
        return;
    }

    stage_start( "sq", "bt" );

    level waittill( "sq_bt_over" );

    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_1" );
    stage_start( "sq", "mta" );

    level waittill( "sq_mta_over" );

    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_2" );
    stage_start( "sq", "gl" );

    level waittill( "sq_gl_over" );

    stage_start( "sq", "ftl" );

    level waittill( "sq_ftl_over" );

    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_3" );
    stage_start( "sq", "ll" );

    level waittill( "sq_ll_over" );

    while ( !flag( "sq_wisp_success" ) )
    {
        stage_start( "sq", "ts" );

        level waittill( "sq_ts_over" );

        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_4" );
        stage_start( "sq", "ctw" );

        level waittill( "sq_ctw_over" );
    }

    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_5" );
    stage_start( "sq", "tpo" );

    level waittill( "sq_tpo_over" );

    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_6" );
    stage_start( "sq", "ip" );

    level waittill( "sq_ip_over" );

    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_7" );
    stage_start( "sq", "ows" );

    level waittill( "sq_ows_over" );

    delay_thread( 0.75, ::snddelayedsidequest8 );
    level notify( "buried_sidequest_achieved" );

    if ( flag( "sq_is_max_tower_built" ) )
    {
        str_fx = "sq_tower_m";
        level.buried_sq_maxis_complete = 1;
        level notify( "sq_maxis_complete" );
        update_sidequest_stats( "sq_buried_maxis_complete" );
    }
    else
    {
        str_fx = "sq_tower_r";
        level.buried_sq_richtofen_complete = 1;
        level notify( "sq_richtofen_complete" );
        update_sidequest_stats( "sq_buried_rich_complete" );
    }

    playfx_on_tower( str_fx, 1 );
    level thread sq_give_player_rewards();
    flag_clear( "sq_started" );
    sq_metagame_reset_machine();
}

playfx_on_tower( str_fx, delete_old = 0 )
{
    a_fx_spots = getentarray( "sq_complete_tower_fx", "targetname" );

    if ( delete_old )
    {
        foreach ( m_fx_spot in a_fx_spots )
            m_fx_spot delete();
    }

    s_spot = getstruct( "sq_end_smoke", "targetname" );
    m_fx_spot = spawn( "script_model", s_spot.origin );
    m_fx_spot.angles = s_spot.angles;
    m_fx_spot setmodel( "tag_origin" );
    m_fx_spot.targetname = "sq_complete_tower_fx";

    if ( delete_old )
        playfx( level._effect[str_fx], s_spot.origin, anglestoforward( s_spot.angles ) );
    else
        playfxontag( level._effect[str_fx], m_fx_spot, "tag_origin" );
}

snddelayedsidequest8()
{
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sidequest_8" );
}

sq_give_player_rewards()
{
    players = get_players();

    foreach ( player in players )
        player thread sq_give_player_all_perks();
}

sq_give_player_all_perks()
{
    machines = getentarray( "zombie_vending", "targetname" );
    perks = [];

    for ( i = 0; i < machines.size; i++ )
    {
        if ( machines[i].script_noteworthy == "specialty_weapupgrade" )
            continue;

        perks[perks.size] = machines[i].script_noteworthy;
    }

    foreach ( perk in perks )
    {
        if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
            continue;

        if ( self hasperk( perk ) || self maps\mp\zombies\_zm_perks::has_perk_paused( perk ) )
            continue;

        self maps\mp\zombies\_zm_perks::give_perk( perk, 0 );
        wait 0.25;
    }

    self._retain_perks = 1;
    self thread watch_for_respawn();
}

watch_for_respawn()
{
    self endon( "disconnect" );
    self waittill_either( "spawned_player", "player_revived" );
    wait_network_frame();
    self sq_give_player_all_perks();
    self setmaxhealth( level.zombie_vars["zombie_perk_juggernaut_health"] );
}

watch_nav_computer_built()
{
    if ( !( isdefined( level.navcomputer_spawned ) && level.navcomputer_spawned ) )
        wait_for_buildable( "sq_common" );

    flag_set( "sq_nav_built" );

    if ( !( isdefined( level.navcomputer_spawned ) && level.navcomputer_spawned ) )
        update_sidequest_stats( "sq_buried_started" );
}

sq_assign_signs()
{
    a_signs = getstructarray( "sq_tunnel_sign", "targetname" );

    foreach ( s_sign in a_signs )
    {
        m_sign = spawn( "script_model", s_sign.origin );
        m_sign.angles = s_sign.angles;
        m_sign.target = s_sign.target;
        m_sign.targetname = "sq_tunnel_sign";
        m_sign setmodel( s_sign.model );
    }

    a_signs = getentarray( "sq_tunnel_sign", "targetname" );
    a_sign_keys = array_randomize( getarraykeys( a_signs ) );
    a_max_signs = array( a_signs[a_sign_keys[0]], a_signs[a_sign_keys[1]], a_signs[a_sign_keys[2]] );
    a_ric_signs = array( a_signs[a_sign_keys[3]], a_signs[a_sign_keys[4]], a_max_signs[0] );

    foreach ( m_sign in a_max_signs )
        m_sign.is_max_sign = 1;

    foreach ( m_sign in a_ric_signs )
        m_sign.is_ric_sign = 1;
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
    org = ( 2990, 287.75, 123.75 );
    angles = vectorscale( ( 0, 0, 1 ), 71.99 );
    maps\mp\zombies\_zm_utility::place_navcard( model, level.map_navcard, org, angles );
}

init_navcomputer()
{
    flag_wait( "start_zombie_round_logic" );
    spawn_navcomputer = 1;
    players = get_players();

    foreach ( player in players )
    {
        built_comptuer = player maps\mp\zombies\_zm_stats::get_global_stat( "sq_buried_started" );

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
    flag_wait( "sq_nav_built" );
    spawn_trigger = 1;
    players = get_players();

    foreach ( player in players )
    {
        card_swiped = player maps\mp\zombies\_zm_stats::get_global_stat( "navcard_applied_zm_buried" );

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
                update_sidequest_stats( "navcard_applied_zm_buried" );
                who.navcard_grabbed = undefined;
                wait 1;
                navcomputer_use_trig delete();
                sq_metagame_reset_machine();
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

    if ( stat_name == "sq_buried_maxis_complete" )
        maxis_complete = 1;
    else if ( stat_name == "sq_buried_rich_complete" )
        rich_complete = 1;

    players = get_players();

    foreach ( player in players )
    {
        if ( stat_name == "sq_buried_started" )
            player.buried_sq_started = 1;
        else if ( stat_name == "navcard_applied_zm_buried" )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( level.navcard_needed, 0 );
            thread sq_refresh_player_navcard_hud();
        }
        else if ( !( isdefined( player.buried_sq_started ) && player.buried_sq_started ) )
            continue;

        if ( rich_complete )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( "sq_buried_last_completed", 1 );
            incrementcounter( "global_zm_total_rich_sq_complete_buried", 1 );
        }
        else if ( maxis_complete )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( "sq_buried_last_completed", 2 );
            incrementcounter( "global_zm_total_max_sq_complete_buried", 1 );
        }

        player maps\mp\zombies\_zm_stats::increment_client_stat( stat_name, 0 );
    }

    if ( rich_complete || maxis_complete )
        level notify( "buried_sidequest_achieved" );
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

richtofensay( vox_line, time, play_in_3d )
{
    level endon( "end_game" );
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    if ( isdefined( level.richcompleted ) && level.richcompleted && !( isdefined( level.metagame_sq_complete ) && level.metagame_sq_complete ) )
        return;

    level endon( "richtofen_c_complete" );

    if ( !isdefined( time ) )
        time = 2;

    while ( isdefined( level.richtofen_talking_to_samuel ) && level.richtofen_talking_to_samuel )
        wait 1;
/#
    iprintlnbold( "Richtoffen Says: " + vox_line );
#/
    while ( isdefined( level.rich_sq_player ) && ( isdefined( level.rich_sq_player.isspeaking ) && level.rich_sq_player.isspeaking ) )
        wait 0.05;

    if ( !isdefined( level.rich_sq_player ) || !is_player_valid( level.rich_sq_player ) )
        return;

    if ( isdefined( level.metagame_sq_richtofen_complete ) && level.metagame_sq_richtofen_complete )
    {
        stuhlingerpossessed();
        delay_thread( time, ::stuhlingerpossessed, 0 );
    }

    if ( isdefined( play_in_3d ) && play_in_3d )
        level.rich_sq_player playsound( vox_line );
    else
        level.rich_sq_player playsoundtoplayer( vox_line, level.rich_sq_player );

    if ( !( isdefined( level.richtofen_talking_to_samuel ) && level.richtofen_talking_to_samuel ) )
        level thread richtofen_talking( time );
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

maxissay( vox_line, m_spot_override, b_wait_for_nearby_speakers )
{
    level endon( "end_game" );
    level endon( "intermission" );

    if ( !isdefined( level.m_maxis_vo_spot ) )
    {
        s_spot = getstruct( "maxis_vo_spot", "targetname" );
        level.m_maxis_vo_spot = spawn( "script_model", s_spot.origin );
        level.m_maxis_vo_spot setmodel( "tag_origin" );
    }

    if ( isdefined( level.maxcompleted ) && level.maxcompleted && !( isdefined( level.metagame_sq_complete ) && level.metagame_sq_complete ) )
        return;

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    while ( isdefined( level.maxis_talking ) && level.maxis_talking )
        wait 0.05;

    level.maxis_talking = 1;
/#
    iprintlnbold( "Maxis Says: " + vox_line );
#/
    m_vo_spot = level.m_maxis_vo_spot;

    if ( isdefined( m_spot_override ) )
        m_vo_spot = m_spot_override;

    if ( isdefined( b_wait_for_nearby_speakers ) && b_wait_for_nearby_speakers )
    {
        nearbyplayers = get_array_of_closest( m_vo_spot.origin, get_players(), undefined, undefined, 256 );

        if ( isdefined( nearbyplayers ) && nearbyplayers.size > 0 )
        {
            foreach ( player in nearbyplayers )
            {
                while ( isdefined( player ) && ( isdefined( player.isspeaking ) && player.isspeaking ) )
                    wait 0.05;
            }
        }
    }

    level thread maxissayvoplay( m_vo_spot, vox_line );

    level waittill( "MaxisSay_vo_finished" );
}

maxissayvoplay( m_vo_spot, vox_line )
{
    m_vo_spot playsoundwithnotify( vox_line, "sound_done" + vox_line );

    m_vo_spot waittill( "sound_done" + vox_line );

    level.maxis_talking = 0;
    level notify( "MaxisSay_vo_finished" );
}

setup_sq_debug()
{
/#
    while ( !isdefined( level.custom_devgui ) )
        wait 1;

    if ( getdvarint( _hash_5256118F ) > 0 )
    {
        execdevgui( "devgui_zombie_buried_sq" );

        if ( isdefined( level.custom_devgui ) )
            temp = level.custom_devgui;

        level.custom_devgui = [];
        level.custom_devgui[level.custom_devgui.size] = ::devgui_sq;

        if ( isdefined( temp ) )
            level.custom_devgui[level.custom_devgui.size] = temp;

        thread zombie_devgui_player_sq_commands();
    }
#/
}

zombie_devgui_player_sq_commands()
{
/#
    flag_wait( "start_zombie_round_logic" );
    wait 1;
    players = get_players();
    level.sq_players = players;

    for ( i = 0; i < players.size; i++ )
    {
        ip1 = i + 1;
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Transit:1/Held\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_TRANSIT; set zombie_devgui nc_on\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Transit:1/Not Held\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_TRANSIT; set zombie_devgui nc_off\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Transit:1/Applied\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_TRANSIT; set zombie_devgui nc_app\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Transit:1/Not Applied\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_TRANSIT; set zombie_devgui nc_napp\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Transit:1/None:0\" \"set dg_sq_player " + ip1 + "; set dg_sq_map TRANSIT; set zombie_devgui comp_0\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Transit:1/Maxis:1\" \"set dg_sq_player " + ip1 + "; set dg_sq_map TRANSIT; set zombie_devgui comp_2\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Transit:1/Ricky:2\" \"set dg_sq_player " + ip1 + "; set dg_sq_map TRANSIT; set zombie_devgui comp_1\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Highrise:2/Held\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_HIGHRISE; set zombie_devgui nc_on\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Highrise:2/Not Held\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_HIGHRISE; set zombie_devgui nc_off\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Highrise:2/Applied\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_HIGHRISE; set zombie_devgui nc_app\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Highrise:2/Not Applied\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_HIGHRISE; set zombie_devgui nc_napp\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Highrise:2/None:0\" \"set dg_sq_player " + ip1 + "; set dg_sq_map HIGHRISE; set zombie_devgui comp_0\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Highrise:2/Maxis:1\" \"set dg_sq_player " + ip1 + "; set dg_sq_map HIGHRISE; set zombie_devgui comp_2\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Highrise:2/Ricky:2\" \"set dg_sq_player " + ip1 + "; set dg_sq_map HIGHRISE; set zombie_devgui comp_1\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Buried:3/Held\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_BURIED; set zombie_devgui nc_on\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Buried:3/Not Held\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_BURIED; set zombie_devgui nc_off\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Buried:3/Applied\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_BURIED; set zombie_devgui nc_app\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Navcard:1/Buried:3/NotApplied\" \"set dg_sq_player " + ip1 + "; set dg_sq_map ZM_BURIED; set zombie_devgui nc_napp\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Buried:3/None:0\" \"set dg_sq_player " + ip1 + "; set dg_sq_map BURIED; set zombie_devgui comp_0\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Buried:3/Maxis:1\" \"set dg_sq_player " + ip1 + "; set dg_sq_map BURIED; set zombie_devgui comp_2\" \\n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Buried/SQ:1/Players:1/" + players[i].name + "/Completed:2/Buried:3/Ricky:2\" \"set dg_sq_player " + ip1 + "; set dg_sq_map BURIED; set zombie_devgui comp_1\" \\n" );
    }
#/
}

devgui_sq( cmd )
{
/#
    cmd_strings = strtok( cmd, " " );
    b_found_entry = 1;

    switch ( cmd_strings[0] )
    {
        case "sq_tpo_warp":
            warp_to_struct_position( "sq_debug_warp_tpo" );
            break;
        case "sq_tpo_give_item":
            level notify( "sq_tpo_give_item" );
            break;
        case "sq_set_maxis":
            set_side_maxis();
            break;
        case "sq_set_richtofen":
            set_side_richtofen();
            break;
        case "sq_ts_quicktest":
            set_sq_ts_quickset();
            break;
        case "sq_ows_start":
            set_sq_ows_start();
            break;
        case "sq_ll_show_code":
            set_sq_ll_show_code();
            break;
        case "sq_ending_richtofen":
            level notify( "end_game_reward_starts_richtofen" );
            break;
        case "sq_ending_maxis":
            level notify( "end_game_reward_starts_maxis" );
            break;
        case "sq_complete_current":
            stage_completed( "sq", level._last_stage_started );
            break;
        case "nc_on":
        case "nc_off":
        case "nc_napp":
        case "nc_app":
        case "comp_2":
        case "comp_1":
        case "comp_0":
            pindex = getdvarint( _hash_DAD9AAFF );

            if ( !isdefined( pindex ) || pindex < 1 )
                pindex = 1;

            sq_player = level.sq_players[pindex - 1];
            sq_level = getdvar( _hash_2685E710 );
            sq_set_stat( sq_player, sq_level, cmd_strings[0] );
            break;
        case "sq_start_stage_ts":
        case "sq_start_stage_tpo":
        case "sq_start_stage_ows":
        case "sq_start_stage_mta":
        case "sq_start_stage_ll":
        case "sq_start_stage_ip":
        case "sq_start_stage_gl":
        case "sq_start_stage_ftl":
        case "sq_start_stage_bt":
            skip_to_sq_stage( cmd_strings[0] );
            break;
        default:
            b_found_entry = 0;
            break;
    }

    return b_found_entry;
#/
}

sq_set_stat( sq_player, sq_level, sq_cmd )
{
/#
    switch ( sq_cmd )
    {
        case "nc_on":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "NAVCARD_HELD_" + sq_level, 1 );
            break;
        case "nc_off":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "NAVCARD_HELD_" + sq_level, 0 );
            break;
        case "nc_app":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "NAVCARD_APPLIED_" + sq_level, 1 );
            break;
        case "nc_napp":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "NAVCARD_APPLIED_" + sq_level, 0 );
            break;
        case "comp_0":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "SQ_" + sq_level + "_LAST_COMPLETED", 0 );
            break;
        case "comp_1":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "SQ_" + sq_level + "_LAST_COMPLETED", 1 );
            break;
        case "comp_2":
            sq_player maps\mp\zombies\_zm_stats::set_global_stat( "SQ_" + sq_level + "_LAST_COMPLETED", 2 );
            break;
    }
#/
}

warp_to_struct_position( str_value, str_key = "targetname" )
{
    a_warp_structs = getstructarray( str_value, str_key );
    a_players = get_players();
    assert( a_warp_structs.size > a_players.size, "warp_to_struct_position found more players than structs for '" + str_key + "' = '" + str_value + "'! Add more structs to fix this" );

    for ( i = 0; i < a_players.size; i++ )
    {
        a_players[i] setorigin( a_warp_structs[i].origin );
        a_players[i] setplayerangles( a_warp_structs[i].angles );
    }
}

set_side_richtofen()
{
    flag_set( "sq_is_ric_tower_built" );
    flag_clear( "sq_is_max_tower_built" );
}

set_side_maxis()
{
    flag_set( "sq_is_max_tower_built" );
    flag_clear( "sq_is_ric_tower_built" );
}

set_sq_ts_quickset()
{
    flag_set( "sq_ts_quicktest" );
}

set_sq_ows_start()
{
    flag_set( "sq_ows_start" );
}

set_sq_ll_show_code()
{
    maps\mp\zm_buried_sq_ll::sq_ll_show_code();
}

sq_debug_print_vo( str_vo )
{
    temp_str = "" + str_vo;
/#
    iprintln( temp_str );
#/
    a_words = strtok( str_vo, " " );
    n_wait = a_words.size * 0.25;
    wait( n_wait );
}

sq_metagame()
{
    level endon( "sq_metagame_player_connected" );
    flag_wait( "sq_intro_vo_done" );

    if ( flag( "sq_started" ) )
        level waittill( "buried_sidequest_achieved" );

    level thread sq_metagame_turn_off_watcher();
    is_blue_on = 0;
    is_orange_on = 0;
    m_endgame_machine = getstruct( "sq_endgame_machine", "targetname" );
    a_tags = [];
    a_tags[0][0] = "TAG_LIGHT_1";
    a_tags[0][1] = "TAG_LIGHT_2";
    a_tags[0][2] = "TAG_LIGHT_3";
    a_tags[1][0] = "TAG_LIGHT_4";
    a_tags[1][1] = "TAG_LIGHT_5";
    a_tags[1][2] = "TAG_LIGHT_6";
    a_tags[2][0] = "TAG_LIGHT_7";
    a_tags[2][1] = "TAG_LIGHT_8";
    a_tags[2][2] = "TAG_LIGHT_9";
    a_tags[3][0] = "TAG_LIGHT_10";
    a_tags[3][1] = "TAG_LIGHT_11";
    a_tags[3][2] = "TAG_LIGHT_12";
    a_stat = [];
    a_stat[0] = "sq_transit_last_completed";
    a_stat[1] = "sq_highrise_last_completed";
    a_stat[2] = "sq_buried_last_completed";
    a_stat_nav = [];
    a_stat_nav[0] = "navcard_applied_zm_transit";
    a_stat_nav[1] = "navcard_applied_zm_highrise";
    a_stat_nav[2] = "navcard_applied_zm_buried";
    a_stat_nav_held = [];
    a_stat_nav_held[0] = "navcard_applied_zm_transit";
    a_stat_nav_held[1] = "navcard_applied_zm_highrise";
    a_stat_nav_held[2] = "navcard_applied_zm_buried";
    bulb_on = [];
    bulb_on[0] = 0;
    bulb_on[1] = 0;
    bulb_on[2] = 0;
    level.n_metagame_machine_lights_on = 0;
    flag_wait( "start_zombie_round_logic" );
    sq_metagame_clear_lights();
    players = get_players();
    player_count = players.size;
/#
    if ( getdvarint( _hash_FA81816F ) >= 1 )
        player_count = 4;
#/
    for ( n_player = 0; n_player < player_count; n_player++ )
    {
        for ( n_stat = 0; n_stat < a_stat.size; n_stat++ )
        {
            if ( isdefined( players[n_player] ) )
            {
                n_stat_value = players[n_player] maps\mp\zombies\_zm_stats::get_global_stat( a_stat[n_stat] );
                n_stat_nav_value = players[n_player] maps\mp\zombies\_zm_stats::get_global_stat( a_stat_nav[n_stat] );
            }
/#
            if ( getdvarint( _hash_FA81816F ) >= 1 )
            {
                n_stat_value = getdvarint( _hash_FA81816F );
                n_stat_nav_value = getdvarint( _hash_FA81816F );
            }
#/
            if ( n_stat_value == 1 )
            {
                m_endgame_machine sq_metagame_machine_set_light( n_player, n_stat, "sq_bulb_blue" );
                is_blue_on = 1;
            }
            else if ( n_stat_value == 2 )
            {
                m_endgame_machine sq_metagame_machine_set_light( n_player, n_stat, "sq_bulb_orange" );
                is_orange_on = 1;
            }

            if ( n_stat_nav_value )
            {
                level setclientfield( "buried_sq_egm_bulb_" + n_stat, 1 );
                bulb_on[n_stat] = 1;
            }
        }
    }

    if ( level.n_metagame_machine_lights_on == 12 )
    {
        if ( is_blue_on && is_orange_on )
            return;
        else if ( !bulb_on[0] || !bulb_on[1] || !bulb_on[2] )
            return;
    }
    else
        return;

    m_endgame_machine.activate_trig = spawn( "trigger_radius", m_endgame_machine.origin, 0, 128, 72 );

    m_endgame_machine.activate_trig waittill( "trigger" );

    m_endgame_machine.activate_trig delete();
    m_endgame_machine.activate_trig = undefined;
    level setclientfield( "buried_sq_egm_animate", 1 );
    m_endgame_machine.endgame_trig = spawn( "trigger_radius_use", m_endgame_machine.origin, 0, 16, 16 );
    m_endgame_machine.endgame_trig setcursorhint( "HINT_NOICON" );
    m_endgame_machine.endgame_trig sethintstring( &"ZM_BURIED_SQ_EGM_BUT" );
    m_endgame_machine.endgame_trig triggerignoreteam();
    m_endgame_machine.endgame_trig usetriggerrequirelookat();

    m_endgame_machine.endgame_trig waittill( "trigger" );

    m_endgame_machine.endgame_trig delete();
    m_endgame_machine.endgame_trig = undefined;
    level thread sq_metagame_clear_tower_pieces();
    playsoundatposition( "zmb_endgame_mach_button", m_endgame_machine.origin );
    players = get_players();

    foreach ( player in players )
    {
        for ( i = 0; i < a_stat.size; i++ )
        {
            player maps\mp\zombies\_zm_stats::set_global_stat( a_stat[i], 0 );
            player maps\mp\zombies\_zm_stats::set_global_stat( a_stat_nav_held[i], 0 );
            player maps\mp\zombies\_zm_stats::set_global_stat( a_stat_nav[i], 0 );
        }
    }

    sq_metagame_clear_lights();

    if ( is_orange_on )
        level notify( "end_game_reward_starts_maxis" );
    else
        level notify( "end_game_reward_starts_richtofen" );
}

sq_metagame_clear_lights()
{
    level setclientfield( "buried_sq_egm_animate", 0 );
    level setclientfield( "buried_sq_egm_bulb_0", 0 );
    level setclientfield( "buried_sq_egm_bulb_1", 0 );
    level setclientfield( "buried_sq_egm_bulb_2", 0 );
    level setclientfield( "buried_sq_egm_0_0", 0 );
    level setclientfield( "buried_sq_egm_0_1", 0 );
    level setclientfield( "buried_sq_egm_0_2", 0 );
    level setclientfield( "buried_sq_egm_1_0", 0 );
    level setclientfield( "buried_sq_egm_1_1", 0 );
    level setclientfield( "buried_sq_egm_1_2", 0 );
    level setclientfield( "buried_sq_egm_2_0", 0 );
    level setclientfield( "buried_sq_egm_2_1", 0 );
    level setclientfield( "buried_sq_egm_2_2", 0 );
    level setclientfield( "buried_sq_egm_3_0", 0 );
    level setclientfield( "buried_sq_egm_3_1", 0 );
    level setclientfield( "buried_sq_egm_3_2", 0 );
}

sq_metagame_on_player_connect()
{
    sq_metagame_reset_machine();
}

sq_metagame_turn_off_watcher()
{
    flag_wait( "sq_started" );
    sq_metagame_clear_lights();
    sq_metagame_reset_machine();
}

sq_metagame_reset_machine()
{
    level notify( "sq_metagame_player_connected" );
    m_endgame_machine = getstruct( "sq_endgame_machine", "targetname" );

    if ( isdefined( m_endgame_machine.activate_trig ) )
    {
        m_endgame_machine.activate_trig delete();
        m_endgame_machine.activate_trig = undefined;
    }

    if ( isdefined( m_endgame_machine.endgame_trig ) )
    {
        m_endgame_machine.endgame_trig delete();
        m_endgame_machine.endgame_trig = undefined;
    }

    level thread sq_metagame();
}

sq_metagame_machine_set_light( n_player, n_stat, str_fx )
{
    level.n_metagame_machine_lights_on++;
    fxcolorbit = 1;

    if ( str_fx == "sq_bulb_orange" )
        fxcolorbit = 2;

    level setclientfield( "buried_sq_egm_" + n_player + "_" + n_stat, fxcolorbit );
}

stuhlingerpossessed( bool )
{
    if ( !isdefined( level.rich_sq_player ) )
        return;

    if ( !isdefined( bool ) || bool )
    {
/#
        println( "Stuhlinger Possessed" );
#/
        level.rich_sq_player setclientfield( "buried_sq_richtofen_player_eyes_stuhlinger", 1 );
    }
    else
    {
/#
        println( "Stuhlinger Freed From Possessed" );
#/
        level.rich_sq_player setclientfield( "buried_sq_richtofen_player_eyes_stuhlinger", 0 );
    }
}

reward_maxis_vo()
{
    m_endgame_machine = getstruct( "sq_endgame_machine", "targetname" );
    m_endgame_machine_ent = spawn( "script_origin", m_endgame_machine.origin );
    maxissay( "vox_maxi_end_game_maxis_wins_0", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_maxis_wins_1", m_endgame_machine_ent );
    maxissay( "vox_maxi_end_game_maxis_wins_2", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_maxis_wins_3", m_endgame_machine_ent );
    maxissay( "vox_maxi_end_game_maxis_wins_4", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_maxis_wins_5", m_endgame_machine_ent );
    maxissay( "vox_maxi_end_game_maxis_wins_6", m_endgame_machine_ent );
    m_endgame_machine_ent delete();
}

reward_richtofen_vo()
{
    m_endgame_machine = getstruct( "sq_endgame_machine", "targetname" );
    m_endgame_machine_ent = spawn( "script_origin", m_endgame_machine.origin );
    maxissay( "vox_zmba_end_game_richtofen_wins_0", m_endgame_machine_ent );
    maxissay( "vox_maxi_end_game_richtofen_wins_1", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_richtofen_wins_2", m_endgame_machine_ent );
    maxissay( "vox_maxi_end_game_richtofen_wins_3", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_richtofen_wins_4", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_richtofen_wins_5", m_endgame_machine_ent );
    maxissay( "vox_maxi_end_game_richtofen_wins_6", m_endgame_machine_ent );
    maxissay( "vox_zmba_end_game_richtofen_wins_7", m_endgame_machine_ent );
    m_endgame_machine_ent delete();
}

vo_stuhlingerpossessed()
{
    play_in_3d = 1;
    richtofensay( "vox_zmba_stuhlinger_1st_possession_1_0", 10, play_in_3d );
    wait 2;
    richtofensay( "vox_zmba_stuhlinger_1st_possession_2_0", 12, play_in_3d );
    wait 3;
    richtofensay( "vox_zmba_stuhlinger_1st_possession_3_0", 7, play_in_3d );
    wait 4;
    richtofensay( "vox_zmba_stuhlinger_1st_possession_4_0", 5, play_in_3d );
    wait 3;

    if ( isdefined( level.rich_sq_player ) )
    {
        while ( isdefined( level.rich_sq_player ) && ( isdefined( level.rich_sq_player.isspeaking ) && level.rich_sq_player.isspeaking ) )
            wait 1;

        richtofensay( "vox_plr_1_stuhlinger_2nd_possession_1_0", 4, !play_in_3d );
    }

    wait 4;
    richtofensay( "vox_zmba_stuhlinger_2nd_possession_2_0", 8, play_in_3d );
    wait 2;
    richtofensay( "vox_zmba_stuhlinger_2nd_possession_3_0", 12, play_in_3d );
    wait 1;
    richtofensay( "vox_zmba_stuhlinger_2nd_possession_5_0", 9, play_in_3d );
    noldvo = -1;

    while ( true )
    {
        wait( randomintrange( 120, 480 ) );

        for ( nvo = randomintrange( 1, 8 ); noldvo == nvo; nvo = randomintrange( 1, 8 ) )
        {

        }

        noldvo = nvo;

        switch ( nvo )
        {
            case 1:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_1_0", 5, play_in_3d );
                break;
            case 2:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_2_0", 7, play_in_3d );
                break;
            case 3:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_3_0", 9, play_in_3d );
                break;
            case 4:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_4_0", 12, play_in_3d );
                break;
            case 5:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_5_0", 7, play_in_3d );
                break;
            case 6:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_6_0", 8, play_in_3d );
                break;
            case 7:
                richtofensay( "vox_zmba_stuhlinger_3rd_possession_7_0", 8, play_in_3d );
                break;
        }
    }
}

end_game_reward_richtofen_wrapper()
{
    level waittill( "end_game_reward_starts_richtofen" );

    level.metagame_sq_complete = 1;
    level.metagame_sq_richtofen_complete = 1;
    end_game_reward_richtofen();
}

end_game_reward_richtofen()
{
    if ( isdefined( level.rich_sq_player ) )
        level.rich_sq_player.dontspeak = 1;

    meteors_stop_falling();
    run_richtofen_earthquake();
    level thread maps\mp\zm_buried_amb::sndmusicquestendgame( "mus_richtofens_delight", 98 );
    wait 2;
    reward_richtofen_vo();
    level thread vo_stuhlingerpossessed();
    mule_kick_allows_4_weapons();
    permanent_fire_sale();
}

run_richtofen_earthquake()
{
    level setclientfield( "buried_sq_richtofen_ending", 1 );
    wait 12;
}

meteors_stop_falling()
{
    stop_exploder( 666 );
}

mule_kick_allows_4_weapons()
{
    foreach ( player in get_players() )
    {
        if ( !isdefined( player._retain_perks_array ) )
            player._retain_perks_array = [];

        if ( !player hasperk( "specialty_additionalprimaryweapon" ) )
            player maps\mp\zombies\_zm_perks::give_perk( "specialty_additionalprimaryweapon", 0 );

        player._retain_perks_array["specialty_additionalprimaryweapon"] = 1;
    }

    level.additionalprimaryweapon_limit = 4;
}

permanent_fire_sale()
{
    level.zombie_vars["zombie_powerup_fire_sale_on"] = 1;
    level thread maps\mp\zombies\_zm_powerups::toggle_fire_sale_on();
    level.disable_firesale_drop = 1;
    wait 1;
    level notify( "powerup fire sale" );
    level notify( "firesale_over" );
}

end_game_reward_maxis_wrapper()
{
    level waittill( "end_game_reward_starts_maxis" );

    level setclientfield( "buried_sq_maxis_eye_glow_override", 1 );
    level.metagame_sq_complete = 1;
    level.metagame_sq_maxis_complete = 1;
    end_game_reward_maxis();
}

end_game_reward_maxis()
{
    run_maxis_earthquake();
    level.allowzmbannouncer = 0;
    level.zmb_laugh_alias = "zmb_laugh_child";
    level.sndfiresalemusoff = 1;
    level thread maps\mp\zm_buried_amb::sndmusicquestendgame( "mus_samanthas_desire", 98 );
    wait 2;
    reward_maxis_vo();
    setup_richtofen_possessed_zombies();
}

setup_richtofen_possessed_zombies()
{
    level._sq_m_possessed_zombie_vo = array( "vox_zmba_zombie_possession_1_0", "vox_zmba_zombie_possession_3_0", "vox_zmba_zombie_possession_4_0", "vox_zmba_zombie_possession_6_0", "vox_zmba_zombie_possession_8_0", "vox_zmba_zombie_possession_9_0", "vox_zmba_zombie_possession_10_0", "vox_zmba_zombie_possession_11_0", "vox_zmba_zombie_possession_12_0", "vox_zmba_zombie_possession_13_0" );
    maps\mp\zombies\_zm_spawner::add_cusom_zombie_spawn_logic( ::sq_maxis_ending_spawn_func );
}

run_maxis_earthquake()
{
    level setclientfield( "buried_sq_maxis_ending", 1 );
}

sq_maxis_ending_spawn_func()
{
    if ( isdefined( self.is_ghost ) && self.is_ghost )
        return;

    if ( can_spawn_richtofen_zombie() )
        self make_richtofen_zombie();
}

can_spawn_richtofen_zombie()
{
    if ( !isdefined( level.sq_richtofen_zombie ) )
    {
        level.sq_richtofen_zombie = spawnstruct();
        level.sq_richtofen_zombie.spawned = 0;
        level.sq_richtofen_zombie.last_killed_time = 0;
    }

    b_richtofen_zombie_active = level.sq_richtofen_zombie.spawned;
    b_cooldown_up = ( gettime() - level.sq_richtofen_zombie.last_killed_time ) * 0.001 > 30;
    b_can_spawn_richtofen_zombie = !b_richtofen_zombie_active && b_cooldown_up;
    return b_can_spawn_richtofen_zombie;
}

make_richtofen_zombie()
{
    self endon( "death" );
    level.sq_richtofen_zombie.spawned = 1;
    self setclientfield( "buried_sq_maxis_ending_update_eyeball_color", 1 );
    self thread richtofen_zombie_watch_death();

    self waittill( "completed_emerging_into_playable_area" );

    self thread richtofen_zombie_vo_watcher();
    self.deathfunction_old = self.deathfunction;
    self.deathfunction = ::richtofen_zombie_deathfunction_override;
}

richtofen_zombie_deathfunction_override()
{
    if ( !( isdefined( self.turning_into_ghost ) && self.turning_into_ghost ) )
    {
        self force_random_powerup_drop();

        if ( isdefined( self.attacker ) )
            self.attacker maps\mp\zombies\_zm_score::add_to_player_score( 500 );
    }

    return self [[ self.deathfunction_old ]]();
}

force_random_powerup_drop()
{
    self.no_powerups = 1;
    level maps\mp\zombies\_zm_powerups::specific_powerup_drop( maps\mp\zombies\_zm_powerups::get_valid_powerup(), self.origin );
}

richtofen_zombie_vo_watcher()
{
    self endon( "death" );
    players = get_players();
    can_see = 0;

    while ( !can_see )
    {
        wait 2;

        foreach ( player in players )
        {
            if ( distance2dsquared( self.origin, player.origin ) < 262144 && sighttracepassed( self gettagorigin( "tag_eye" ), player.origin, 0, undefined ) )
                can_see = 1;
        }
    }

    str_vox = randomint( level._sq_m_possessed_zombie_vo.size );
    self playsound( level._sq_m_possessed_zombie_vo[str_vox] );
}

richtofen_zombie_watch_death()
{
    while ( isdefined( self ) && isalive( self ) )
    {
/#
        if ( getdvarint( _hash_5256118F ) > 0 )
            debugstar( self.origin, 5, ( 1, 1, 0 ) );
#/
        wait 0.25;
    }

    richtofen_zombie_clear();
}

richtofen_zombie_clear()
{
    level.sq_richtofen_zombie.last_killed_time = gettime();
    level.sq_richtofen_zombie.spawned = 0;
}

skip_to_sq_stage( str_cmd )
{
    str_stage_name = getsubstr( str_cmd, 15 );
    a_stages = get_sq_stages_in_order();

    foreach ( str_stage in a_stages )
    {
        if ( str_stage == str_stage_name )
            break;

        if ( str_stage == "ctw" )
        {
            flag_set( "sq_wisp_success" );
            wait_network_frame();
        }

        level notify( "sq_" + str_stage + "_over" );
        stage_completed( "sq", str_stage );
        wait_network_frame();
    }

    if ( level._zombie_sidequests["sq"].stages[str_stage_name].completed )
        stage_start( "sq", str_stage_name );
}

get_sq_stages_in_order()
{
    a_keys = getarraykeys( level._zombie_sidequests["sq"].stages );
    a_stages_ordered = [];

    for ( i = 0; i < a_keys.size; i++ )
    {
        for ( j = 0; j < a_keys.size; j++ )
        {
            if ( level._zombie_sidequests["sq"].stages[a_keys[j]].stage_number == i )
            {
                a_stages_ordered[a_stages_ordered.size] = a_keys[j];
                break;
            }
        }
    }

    return a_stages_ordered;
}
