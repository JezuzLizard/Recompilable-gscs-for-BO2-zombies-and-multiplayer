// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\zm_alcatraz_sq_nixie;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zm_alcatraz_sq;
#include maps\mp\zombies\_zm_afterlife;
#include maps\mp\zombies\_zm_ai_brutus;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm;

onplayerconnect_sq_final()
{

}

stage_one()
{
    if ( isdefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
    {
        sq_final_easy_cleanup();
        return;
    }

    precachemodel( "p6_zm_al_audio_headset_icon" );
    flag_wait( "quest_completed_thrice" );
    flag_wait( "spoon_obtained" );
    flag_wait( "warden_blundergat_obtained" );
/#
    players = getplayers();

    foreach ( player in players )
    {
        player.fq_client_hint = newclienthudelem( player );
        player.fq_client_hint.x = 25;
        player.fq_client_hint.y = 200;
        player.fq_client_hint.alignx = "center";
        player.fq_client_hint.aligny = "bottom";
        player.fq_client_hint.fontscale = 1.6;
        player.fq_client_hint.alpha = 1;
        player.fq_client_hint.sort = 20;
        player.fq_client_hint settext( 386 + " - " + 481 + " - " + 101 + " - " + 872 );
    }
#/
    for ( i = 1; i < 4; i++ )
    {
        m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
        m_nixie_tube thread nixie_tube_scramble_protected_effects( i );
    }

    level waittill_multiple( "nixie_tube_trigger_1", "nixie_tube_trigger_2", "nixie_tube_trigger_3" );
    level thread nixie_final_codes( 386 );
    level thread nixie_final_codes( 481 );
    level thread nixie_final_codes( 101 );
    level thread nixie_final_codes( 872 );
    level waittill_multiple( "nixie_final_" + 386, "nixie_final_" + 481, "nixie_final_" + 101, "nixie_final_" + 872 );
    nixie_tube_off();
/#
    players = getplayers();

    foreach ( player in players )
        player.fq_client_hint destroy();
#/
    m_nixie_tube = getent( "nixie_tube_1", "targetname" );
    m_nixie_tube playsoundwithnotify( "vox_brutus_nixie_right_0", "scary_voice" );

    m_nixie_tube waittill( "scary_voice" );

    wait 3;
    level thread stage_two();
}

sq_final_easy_cleanup()
{
    t_plane_fly_afterlife = getent( "plane_fly_afterlife_trigger", "script_noteworthy" );
    t_plane_fly_afterlife delete();
}

nixie_tube_off()
{
    level notify( "kill_nixie_input" );
    wait 1;

    for ( i = 1; i < 4; i++ )
    {
        m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );

        for ( j = 0; j < 10; j++ )
            m_nixie_tube hidepart( "J_" + j );

        wait 0.3;
    }
}

nixie_final_codes( nixie_code )
{
    maps\mp\zm_alcatraz_sq_nixie::nixie_tube_add_code( nixie_code );

    level waittill( "nixie_" + nixie_code );

    level notify( "kill_nixie_input" );
    flag_set( "nixie_puzzle_solved" );
    flag_clear( "nixie_ee_flashing" );
    goal_num_1 = maps\mp\zm_alcatraz_sq_nixie::get_split_number( 1, nixie_code );
    goal_num_2 = maps\mp\zm_alcatraz_sq_nixie::get_split_number( 2, nixie_code );
    goal_num_3 = maps\mp\zm_alcatraz_sq_nixie::get_split_number( 3, nixie_code );
    nixie_tube_win_effects_all_tubes_final( goal_num_2, goal_num_3, goal_num_1 );
    flag_set( "nixie_ee_flashing" );
    flag_clear( "nixie_puzzle_solved" );
    maps\mp\zm_alcatraz_sq_nixie::nixie_reset_control( 0 );
    level notify( "nixie_final_" + nixie_code );
}

nixie_tube_scramble_protected_effects( n_tube_index )
{
    self endon( "nixie_scramble_stop" );
    level endon( "nixie_tube_trigger_" + n_tube_index );
    n_change_rate = 0.1;
    unrestricted_scramble_num = [];
    unrestricted_scramble_num[1] = array( 0, 2, 5, 6, 7 );
    unrestricted_scramble_num[2] = array( 2, 4, 5, 6, 9 );
    unrestricted_scramble_num[3] = array( 0, 3, 4, 7, 8, 9 );
    n_number_to_display = random( unrestricted_scramble_num[n_tube_index] );

    while ( true )
    {
        self hidepart( "J_" + n_number_to_display );
        n_number_to_display = random( unrestricted_scramble_num[n_tube_index] );
        self showpart( "J_" + n_number_to_display );
        self playsound( "zmb_quest_nixie_count" );
        wait( n_change_rate );
    }
}

nixie_final_audio_cue_code()
{
    m_nixie_tube = getent( "nixie_tube_1", "targetname" );
    m_nixie_tube playsoundwithnotify( "vox_brutus_nixie_right_0", "scary_voice" );

    m_nixie_tube waittill( "scary_voice" );
}

nixie_tube_win_effects_all_tubes_final( goal_num_1 = 0, goal_num_2 = 0, goal_num_3 = 0 )
{
    a_nixie_tube = [];
    a_nixie_tube[1] = getent( "nixie_tube_1", "targetname" );
    a_nixie_tube[2] = getent( "nixie_tube_2", "targetname" );
    a_nixie_tube[3] = getent( "nixie_tube_3", "targetname" );
    n_off_tube = 1;

    for ( start_time = 0; start_time < 2; start_time += 0.15 )
    {
        for ( i = 1; i < 3 + 1; i++ )
        {
            if ( i == n_off_tube )
            {
                a_nixie_tube[i] hidepart( "J_" + level.a_nixie_tube_code[i] );
                continue;
            }

            a_nixie_tube[i] showpart( "J_" + level.a_nixie_tube_code[i] );

            if ( i == 1 && n_off_tube == 2 || i == 3 && n_off_tube == 1 )
                a_nixie_tube[i] playsound( "zmb_quest_nixie_count" );
        }

        n_off_tube++;

        if ( n_off_tube > 3 )
            n_off_tube = 1;

        wait_network_frame();
    }

    a_nixie_tube[1] showpart( "J_" + level.a_nixie_tube_code[1] );
    a_nixie_tube[2] showpart( "J_" + level.a_nixie_tube_code[2] );
    a_nixie_tube[3] showpart( "J_" + level.a_nixie_tube_code[3] );

    while ( level.a_nixie_tube_code[1] != goal_num_1 || level.a_nixie_tube_code[2] != goal_num_2 || level.a_nixie_tube_code[3] != goal_num_3 )
    {
        n_current_tube = 1;
        n_goal = goal_num_1;

        if ( level.a_nixie_tube_code[n_current_tube] == goal_num_1 )
        {
            n_current_tube = 2;
            n_goal = goal_num_2;

            if ( level.a_nixie_tube_code[n_current_tube] == goal_num_2 )
            {
                n_current_tube = 3;
                n_goal = goal_num_3;
            }
        }

        wait_network_frame();
        j = 0;

        while ( level.a_nixie_tube_code[n_current_tube] != n_goal )
        {
            a_nixie_tube[n_current_tube] hidepart( "J_" + level.a_nixie_tube_code[n_current_tube] );
            level.a_nixie_tube_code[n_current_tube]--;

            if ( level.a_nixie_tube_code[n_current_tube] == -1 )
                level.a_nixie_tube_code[n_current_tube] = 9;

            a_nixie_tube[n_current_tube] showpart( "J_" + level.a_nixie_tube_code[n_current_tube] );

            if ( j % 3 == 0 )
                a_nixie_tube[n_current_tube] playsound( "zmb_quest_nixie_count" );

            j++;
            wait 0.05;
        }
    }

    a_nixie_tube[2] playsound( "zmb_quest_nixie_count_final" );
    wait_network_frame();
}

stage_two()
{
    audio_logs = [];
    audio_logs[0] = [];
    audio_logs[0][0] = "vox_guar_tour_vo_1_0";
    audio_logs[0][1] = "vox_guar_tour_vo_2_0";
    audio_logs[0][2] = "vox_guar_tour_vo_3_0";
    audio_logs[2] = [];
    audio_logs[2][0] = "vox_guar_tour_vo_4_0";
    audio_logs[3] = [];
    audio_logs[3][0] = "vox_guar_tour_vo_5_0";
    audio_logs[3][1] = "vox_guar_tour_vo_6_0";
    audio_logs[4] = [];
    audio_logs[4][0] = "vox_guar_tour_vo_7_0";
    audio_logs[5] = [];
    audio_logs[5][0] = "vox_guar_tour_vo_8_0";
    audio_logs[6] = [];
    audio_logs[6][0] = "vox_guar_tour_vo_9_0";
    audio_logs[6][1] = "vox_guar_tour_vo_10_0";
    play_sq_audio_log( 0, audio_logs[0], 0 );

    for ( i = 2; i <= 6; i++ )
        play_sq_audio_log( i, audio_logs[i], 1 );

    level.m_headphones delete();
    t_plane_fly_afterlife = getent( "plane_fly_afterlife_trigger", "script_noteworthy" );
    t_plane_fly_afterlife playsound( "zmb_easteregg_laugh" );
    trigger_is_on = 0;

    while ( true )
    {
        players = getplayers();

        if ( players.size > 1 )
        {
            arlington_is_present = 0;

            foreach ( player in players )
            {
                if ( isdefined( player ) && player.character_name == "Arlington" )
                    arlington_is_present = 1;
            }

            if ( arlington_is_present && !trigger_is_on )
            {
                t_plane_fly_afterlife trigger_on();
                trigger_is_on = 1;
            }
            else if ( !arlington_is_present && trigger_is_on )
            {
                t_plane_fly_afterlife trigger_off();
                trigger_is_on = 0;
            }
        }
        else if ( trigger_is_on )
        {
            t_plane_fly_afterlife trigger_off();
            trigger_is_on = 0;
        }

        wait 0.1;
    }
}

headphones_rotate()
{
    self endon( "death" );

    while ( true )
    {
        self rotateyaw( 360, 3 );

        self waittill( "rotatedone" );
    }
}

play_sq_audio_log( num, a_vo, b_use_trig )
{
    v_pos = getstruct( "sq_at_" + num, "targetname" ).origin;

    if ( !isdefined( level.m_headphones ) )
    {
        level.m_headphones = spawn( "script_model", v_pos );
        level.m_headphones ghostindemo();
        level.m_headphones setmodel( "p6_zm_al_audio_headset_icon" );
        playfxontag( level._effect["powerup_on"], level.m_headphones, "tag_origin" );
        level.m_headphones thread headphones_rotate();
        level.m_headphones playloopsound( "zmb_spawn_powerup_loop" );
        level.m_headphones trigger_off();
    }
    else
    {
        level.m_headphones trigger_on();
        level.m_headphones.origin = v_pos;
    }

    if ( b_use_trig )
    {
        trigger = spawn( "trigger_radius", level.m_headphones.origin - vectorscale( ( 0, 0, 1 ), 80.0 ), 0, 30, 150 );

        trigger waittill( "trigger" );

        trigger delete();
    }

    level.m_headphones trigger_off();
    level setclientfield( "toggle_futz", 1 );
    players = getplayers();

    foreach ( player in players )
        maps\mp\_visionset_mgr::vsmgr_activate( "visionset", "zm_audio_log", player );

    for ( i = 0; i < a_vo.size; i++ )
    {
        level.m_headphones playsoundwithnotify( a_vo[i], "at_done" );

        level.m_headphones waittill( "at_done" );

        wait 0.5;
    }

    level setclientfield( "toggle_futz", 0 );
    players = getplayers();

    foreach ( player in players )
        maps\mp\_visionset_mgr::vsmgr_deactivate( "visionset", "zm_audio_log", player );
}

final_flight_setup()
{
    t_plane_fly_afterlife = getent( "plane_fly_afterlife_trigger", "script_noteworthy" );
    t_plane_fly_afterlife thread final_flight_trigger();
    t_plane_fly_afterlife trigger_off();
}

final_flight_trigger()
{
    t_plane_fly = getent( "plane_fly_trigger", "targetname" );
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( "" );

    while ( isdefined( self ) )
    {
        self waittill( "trigger", e_triggerer );

        if ( isplayer( e_triggerer ) )
        {
            if ( isdefined( level.custom_plane_validation ) )
            {
                valid = self [[ level.custom_plane_validation ]]( e_triggerer );

                if ( !valid )
                    continue;
            }

            players = getplayers();

            if ( players.size < 2 )
                continue;

            b_everyone_is_ready = 1;

            foreach ( player in players )
            {
                if ( !isdefined( player ) || player.sessionstate == "spectator" || player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                    b_everyone_is_ready = 0;
            }

            if ( !b_everyone_is_ready )
                continue;

            if ( flag( "plane_is_away" ) )
                continue;

            flag_set( "plane_is_away" );
            t_plane_fly trigger_off();

            foreach ( player in players )
            {
                if ( isdefined( player ) )
                {
/#
                    iprintlnbold( "LINK PLAYER TO PLANE, START COUNTDOWN IF NOT YET STARTED" );
#/
                    player thread final_flight_player_thread();
                }
            }

            return;
        }
    }
}

final_flight_player_thread()
{
    self endon( "death_or_disconnect" );
    self.on_a_plane = 1;
    self.dontspeak = 1;
    self setclientfieldtoplayer( "isspeaking", 1 );
/#
    iprintlnbold( "plane boarding thread started" );
#/
    if ( !( isdefined( self.afterlife ) && self.afterlife ) )
    {
        self.keep_perks = 1;
        self afterlife_remove();
        self.afterlife = 1;
        self thread afterlife_laststand();

        self waittill( "player_fake_corpse_created" );
    }

    self afterlife_infinite_mana( 1 );
    level.final_flight_activated = 1;
    level.final_flight_players[level.final_flight_players.size] = self;
    a_nml_teleport_targets = [];

    for ( i = 1; i < 6; i++ )
        a_nml_teleport_targets[i - 1] = getstruct( "nml_telepoint_" + i, "targetname" );

    self.n_passenger_index = level.final_flight_players.size;
    a_players = [];
    a_players = getplayers();

    if ( a_players.size == 1 )
        self.n_passenger_index = 1;

    m_plane_craftable = getent( "plane_craftable", "targetname" );
    m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
    m_plane_about_to_crash ghost();
    veh_plane_flyable = getent( "plane_flyable", "targetname" );
    veh_plane_flyable show();
    flag_set( "plane_boarded" );
    t_plane_fly = getent( "plane_fly_trigger", "targetname" );
    str_hint_string = "BOARD FINAL FLIGHT";
    t_plane_fly sethintstring( str_hint_string );
    self playerlinktodelta( m_plane_craftable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
    self allowcrouch( 1 );
    self allowstand( 0 );
    self clientnotify( "sndFFCON" );
    flag_wait( "plane_departed" );
    level notify( "sndStopBrutusLoop" );
    self clientnotify( "sndPS" );
    self playsoundtoplayer( "zmb_plane_takeoff", self );
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "plane_takeoff", self );
    m_plane_craftable ghost();
    self playerlinktodelta( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
    self setclientfieldtoplayer( "effects_escape_flight", 1 );
    flag_wait( "plane_approach_bridge" );
    self thread maps\mp\zm_alcatraz_sq::snddelayedimp();
    self setclientfieldtoplayer( "effects_escape_flight", 2 );
    self unlink();
    self playerlinktoabsolute( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
    flag_wait( "plane_zapped" );
    flag_set( "activate_player_zone_bridge" );
    self playsoundtoplayer( "zmb_plane_fall", self );
    self setclientfieldtoplayer( "effects_escape_flight", 3 );
    self.dontspeak = 1;
    self setclientfieldtoplayer( "isspeaking", 1 );
    self playerlinktodelta( m_plane_about_to_crash, "tag_player_crouched_" + ( self.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
    flag_wait( "plane_crashed" );
    self thread fadetoblackforxsec( 0, 2, 0, 0.5, "black" );
    self unlink();
    self allowstand( 1 );
    self setstance( "stand" );
    self allowcrouch( 0 );
    flag_clear( "spawn_zombies" );
    self setorigin( a_nml_teleport_targets[self.n_passenger_index].origin );
    e_poi = getstruct( "plane_crash_poi", "targetname" );
    vec_to_target = e_poi.origin - self.origin;
    vec_to_target = vectortoangles( vec_to_target );
    vec_to_target = ( 0, vec_to_target[1], 0 );
    self setplayerangles( vec_to_target );
    n_shellshock_duration = 5;
    self shellshock( "explosion", n_shellshock_duration );
    self.on_a_plane = 0;
    stage_final();
}

stage_final()
{
    level notify( "stage_final" );
    level endon( "stage_final" );
    b_everyone_alive = 0;

    while ( isdefined( b_everyone_alive ) && !b_everyone_alive )
    {
        b_everyone_alive = 1;
        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( isdefined( player.afterlife ) && player.afterlife )
            {
                b_everyone_alive = 0;
                wait 0.05;
                break;
            }
        }
    }

    level._should_skip_ignore_player_logic = ::final_showdown_zombie_logic;
    flag_set( "spawn_zombies" );
    array_func( getplayers(), maps\mp\zombies\_zm_afterlife::afterlife_remove );
    p_weasel = undefined;
    a_player_team = [];
    a_players = getplayers();

    foreach ( player in a_players )
    {
        player.dontspeak = 1;
        player setclientfieldtoplayer( "isspeaking", 1 );

        if ( player.character_name == "Arlington" )
        {
            p_weasel = player;
            continue;
        }

        a_player_team[a_player_team.size] = player;
    }

    if ( isdefined( p_weasel ) && a_player_team.size > 0 )
    {
        level.longregentime = 1000000;
        level.playerhealth_regularregendelay = 1000000;
        p_weasel.team = level.zombie_team;
        p_weasel.pers["team"] = level.zombie_team;
        p_weasel.sessionteam = level.zombie_team;
        p_weasel.maxhealth = a_player_team.size * 2000;
        p_weasel.health = p_weasel.maxhealth;

        foreach ( player in a_player_team )
        {
            player.maxhealth = 2000;
            player.health = player.maxhealth;
        }

        s_start_point = getstruct( "final_fight_starting_point_weasel", "targetname" );

        if ( isdefined( p_weasel ) && isdefined( s_start_point ) )
        {
            playfx( level._effect["afterlife_teleport"], p_weasel.origin );
            p_weasel setorigin( s_start_point.origin );
            p_weasel setplayerangles( s_start_point.angles );
            playfx( level._effect["afterlife_teleport"], p_weasel.origin );
        }

        for ( i = 0; i < a_player_team.size; i++ )
        {
            s_start_point = getstruct( "final_fight_starting_point_hero_" + ( i + 1 ), "targetname" );

            if ( isdefined( a_player_team[i] ) && isdefined( s_start_point ) )
            {
                playfx( level._effect["afterlife_teleport"], a_player_team[i].origin );
                a_player_team[i] setorigin( s_start_point.origin );
                a_player_team[i] setplayerangles( s_start_point.angles );
                playfx( level._effect["afterlife_teleport"], a_player_team[i].origin );
            }
        }

        level thread final_showdown_track_weasel( p_weasel );
        level thread final_showdown_track_team( a_player_team );
        n_spawns_needed = 2;

        for ( i = n_spawns_needed; i > 0; i-- )
            maps\mp\zombies\_zm_ai_brutus::brutus_spawn_in_zone( "zone_golden_gate_bridge", 1 );

        level thread final_battle_vo( p_weasel, a_player_team );
        level notify( "pop_goes_the_weasel_achieved" );

        level waittill( "showdown_over" );
    }
    else if ( isdefined( p_weasel ) )
        level.winner = "weasel";
    else
        level.winner = "team";

    level clientnotify( "sndSQF" );
    level.brutus_respawn_after_despawn = 0;
    level thread clean_up_final_brutuses();
    wait 2;

    if ( level.winner == "weasel" )
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            player freezecontrols( 1 );
            player maps\mp\zombies\_zm_stats::increment_client_stat( "prison_ee_good_ending", 0 );
            player thread fadetoblackforxsec( 0, 5, 0.5, 0, "white" );
            player create_ending_message( &"ZM_PRISON_GOOD" );
            player.client_hint.sort = 55;
            player.client_hint.color = ( 0, 0, 0 );
            playsoundatposition( "zmb_quest_final_white_good", ( 0, 0, 0 ) );
            level.sndgameovermusicoverride = "game_over_final_good";
        }

        level.custom_intermission = ::player_intermission_bridge;
    }
    else
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            player freezecontrols( 1 );
            player maps\mp\zombies\_zm_stats::increment_client_stat( "prison_ee_bad_ending", 0 );
            player thread fadetoblackforxsec( 0, 5, 0.5, 0, "white" );
            player create_ending_message( &"ZM_PRISON_BAD" );
            player.client_hint.sort = 55;
            player.client_hint.color = ( 0, 0, 0 );
            playsoundatposition( "zmb_quest_final_white_bad", ( 0, 0, 0 ) );
            level.sndgameovermusicoverride = "game_over_final_bad";
        }
    }

    wait 5;
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isdefined( player.client_hint ) )
            player thread destroy_tutorial_message();

        if ( isdefined( player.revivetrigger ) )
        {
            player thread revive_success( player, 0 );
            player cleanup_suicide_hud();
        }

        if ( isdefined( player ) )
            player ghost();
    }

    if ( isdefined( p_weasel ) )
    {
        p_weasel.team = "allies";
        p_weasel.pers["team"] = "allies";
        p_weasel.sessionteam = "allies";
        p_weasel ghost();
    }

    level notify( "end_game" );
}

final_showdown_track_weasel( p_weasel )
{
    level endon( "showdown_over" );

    while ( true )
    {
        if ( !isdefined( p_weasel ) || p_weasel maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            level.winner = "team";
            level notify( "showdown_over" );
        }

        wait 0.05;
    }
}

final_showdown_track_team( a_player_team )
{
    level endon( "showdown_over" );

    while ( true )
    {
        weasel_won = 1;

        foreach ( player in a_player_team )
        {
            if ( is_player_valid( player, 0, 0 ) )
                weasel_won = 0;
        }

        if ( isdefined( weasel_won ) && weasel_won )
        {
            level.winner = "weasel";
            level notify( "showdown_over" );
        }

        wait 0.05;
    }
}

final_showdown_zombie_logic()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( player.character_name == "Arlington" )
            self.ignore_player[self.ignore_player.size] = player;
    }

    return 1;
}

final_showdown_create_icon( player, enemy )
{
    height_offset = 60;
    hud_elem = newclienthudelem( player );
    hud_elem.x = enemy.origin[0];
    hud_elem.y = enemy.origin[1];
    hud_elem.z = enemy.origin[2] + height_offset;
    hud_elem.alpha = 1;
    hud_elem.archived = 1;
    hud_elem setshader( "waypoint_kill_red", 8, 8 );
    hud_elem setwaypoint( 1 );
    hud_elem.foreground = 1;
    hud_elem.hidewheninmenu = 1;
    hud_elem thread final_showdown_update_icon( enemy );
    waittill_any_ents( level, "showdown_over", enemy, "disconnect" );
    hud_elem destroy();
}

final_showdown_update_icon( enemy )
{
    level endon( "showdown_over" );
    enemy endon( "disconnect" );
    height_offset = 60;

    while ( isdefined( enemy ) )
    {
        self.x = enemy.origin[0];
        self.y = enemy.origin[1];
        self.z = enemy.origin[2] + height_offset;
        wait 0.05;
    }
}

revive_trigger_should_ignore_sight_checks( player_down )
{
    if ( level.final_flight_activated )
        return true;

    return false;
}

final_battle_vo( p_weasel, a_player_team )
{
    level endon( "showdown_over" );
    wait 10;
    a_players = arraycopy( a_player_team );
    player = a_players[randomintrange( 0, a_players.size )];
    arrayremovevalue( a_players, player );

    if ( a_players.size > 0 )
        player_2 = a_players[randomintrange( 0, a_players.size )];

    if ( isdefined( player ) )
        player final_battle_reveal();

    wait 3;

    if ( isdefined( p_weasel ) )
        p_weasel playsoundontag( "vox_plr_3_end_scenario_0", "J_Head" );

    wait 1;

    foreach ( player in a_player_team )
    {
        level thread final_showdown_create_icon( player, p_weasel );
        level thread final_showdown_create_icon( p_weasel, player );
    }

    wait 10;

    if ( isdefined( player_2 ) )
        player_2 playsoundontag( "vox_plr_" + player_2.characterindex + "_end_scenario_1", "J_Head" );
    else if ( isdefined( player ) )
        player playsoundontag( "vox_plr_" + player.characterindex + "_end_scenario_1", "J_Head" );

    wait 4;

    if ( isdefined( p_weasel ) )
    {
        p_weasel playsoundontag( "vox_plr_3_end_scenario_1", "J_Head" );
        p_weasel.dontspeak = 0;
        p_weasel setclientfieldtoplayer( "isspeaking", 0 );
    }

    foreach ( player in a_player_team )
    {
        player.dontspeak = 0;
        player setclientfieldtoplayer( "isspeaking", 0 );
    }
}

final_battle_reveal()
{
    self endon( "death_or_disconnect" );
    self playsoundwithnotify( "vox_plr_" + self.characterindex + "_end_scenario_0", "showdown_icon_reveal" );

    self waittill( "showdown_icon_reveal" );
}

player_intermission_bridge()
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
    points = getstructarray( "final_cam", "targetname" );

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
            self.game_over_bg thread maps\mp\zombies\_zm::fade_up_over_time( 1 );
        }
    }
}

create_ending_message( str_msg )
{
    if ( !isdefined( self.client_hint ) )
    {
        self.client_hint = newclienthudelem( self );
        self.client_hint.alignx = "center";
        self.client_hint.aligny = "middle";
        self.client_hint.horzalign = "center";
        self.client_hint.vertalign = "bottom";

        if ( self issplitscreen() )
            self.client_hint.y = -140;
        else
            self.client_hint.y = -250;

        self.client_hint.foreground = 1;
        self.client_hint.font = "default";
        self.client_hint.fontscale = 50;
        self.client_hint.alpha = 1;
        self.client_hint.foreground = 1;
        self.client_hint.hidewheninmenu = 1;
        self.client_hint.color = ( 1, 1, 1 );
    }

    self.client_hint settext( str_msg );
}

custom_game_over_hud_elem( player )
{
    game_over = newclienthudelem( player );
    game_over.alignx = "center";
    game_over.aligny = "middle";
    game_over.horzalign = "center";
    game_over.vertalign = "middle";
    game_over.y -= 130;
    game_over.foreground = 1;
    game_over.fontscale = 3;
    game_over.alpha = 0;
    game_over.color = ( 1, 1, 1 );
    game_over.hidewheninmenu = 1;

    if ( isdefined( level.winner ) )
        game_over settext( &"ZM_PRISON_LIFE_OVER" );
    else
        game_over settext( &"ZOMBIE_GAME_OVER" );

    game_over fadeovertime( 1 );
    game_over.alpha = 1;

    if ( player issplitscreen() )
    {
        game_over.fontscale = 2;
        game_over.y += 40;
    }

    return game_over;
}

clean_up_final_brutuses()
{
    while ( true )
    {
        zombies = getaispeciesarray( "axis", "all" );

        for ( i = 0; i < zombies.size; i++ )
            zombies[i] dodamage( 10000, zombies[i].origin );

        wait 1;
    }
}
