// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_buried_sq;
#include maps\mp\zombies\_zm_zonemgr;

init()
{
    flag_init( "sq_ip_puzzle_complete" );
    level.sq_bp_buttons = [];
    s_lightboard = getstruct( "zm_sq_lightboard", "targetname" );
    s_lightboard sq_bp_spawn_board();
    declare_sidequest_stage( "sq", "ip", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    if ( flag( "sq_is_max_tower_built" ) )
        level thread stage_vo_max();
    else
        level thread stage_vo_ric();

    level._cur_stage_name = "ip";
    clientnotify( "ip" );
}

stage_vo_max()
{
    s_struct = getstruct( "sq_gallows", "targetname" );
    trigger = spawn( "trigger_radius", s_struct.origin, 0, 128, 72 );
    m_maxis_vo_spot = spawn( "script_model", s_struct.origin );
    m_maxis_vo_spot setmodel( "tag_origin" );
    maxissay( "vox_maxi_sidequest_ip_0", m_maxis_vo_spot );
    maxissay( "vox_maxi_sidequest_ip_1", m_maxis_vo_spot );
    m_lightboard = getent( "sq_bp_board", "targetname" );
    trigger = spawn( "trigger_radius", m_lightboard.origin, 0, 128, 72 );

    trigger waittill( "trigger" );

    maxissay( "vox_maxi_sidequest_ip_2", m_lightboard );
    maxissay( "vox_maxi_sidequest_ip_3", m_lightboard );
}

stage_vo_ric()
{
    richtofensay( "vox_zmba_sidequest_ip_0", 10 );
    richtofensay( "vox_zmba_sidequest_ip_1", 5.5 );
    richtofensay( "vox_zmba_sidequest_ip_2", 8 );
    richtofensay( "vox_zmba_sidequest_ip_3", 11 );

    if ( !isdefined( level.rich_sq_player ) )
        return;

    while ( !level.rich_sq_player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_maze" ) )
        wait 1;

    richtofensay( "vox_zmba_sidequest_ip_4", 8 );
}

stage_logic()
{
/#
    iprintlnbold( "IP Started" );
#/
    if ( flag( "sq_is_max_tower_built" ) )
    {
        a_button_structs = getstructarray( "sq_bp_button", "targetname" );
        array_thread( a_button_structs, ::sq_bp_spawn_trigger );
        m_lightboard = getent( "sq_bp_board", "targetname" );
        m_lightboard setclientfield( "buried_sq_bp_set_lightboard", 1 );

        while ( !flag( "sq_ip_puzzle_complete" ) )
        {
            sq_bp_start_puzzle_lights();
            sq_bp_delete_green_lights();
            wait_network_frame();
            wait_network_frame();
            wait_network_frame();
            wait_network_frame();
            wait_network_frame();
        }
    }
    else
    {
        sq_ml_spawn_levers();
        a_levers = getentarray( "sq_ml_lever", "targetname" );
        array_thread( a_levers, ::sq_ml_spawn_trigger );
        level thread sq_ml_puzzle_logic();
        flag_wait( "sq_ip_puzzle_complete" );
    }

    wait_network_frame();
    stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{

}

sq_bp_spawn_trigger()
{
    level endon( "sq_ip_puzzle_complete" );
    self.trig = spawn( "trigger_radius_use", self.origin, 0, 16, 16 );
    self.trig setcursorhint( "HINT_NOICON" );
    self.trig sethintstring( &"ZM_BURIED_SQ_BUT_U" );
    self.trig triggerignoreteam();
    self.trig usetriggerrequirelookat();

    while ( true )
    {
        self.trig waittill( "trigger" );

        self.trig sethintstring( "" );
        level thread sq_bp_button_pressed( self.script_string, self.trig );
        wait 1;
        self.trig sethintstring( &"ZM_BURIED_SQ_BUT_U" );
    }
}

sq_bp_spawn_board()
{
    m_board = spawn( "script_model", self.origin );
    m_board.angles = self.angles;
    m_board setmodel( "p6_zm_bu_bulb_puzzle_machine" );
    m_board.targetname = "sq_bp_board";
}

sq_bp_button_pressed( str_tag, trig )
{
    if ( isdefined( level.str_sq_bp_active_light ) )
    {
        if ( level.str_sq_bp_active_light == str_tag )
        {
            trig playsound( "zmb_sq_bell_yes" );
            sq_bp_light_on( str_tag, "green" );
            level notify( "sq_bp_correct_button" );
        }
        else
        {
            trig playsound( "zmb_sq_bell_no" );
            level notify( "sq_bp_wrong_button" );
            m_light = sq_bp_light_on( str_tag, "yellow" );
        }
    }
    else
    {
        m_light = sq_bp_light_on( str_tag, "yellow" );
        trig playsound( "zmb_sq_bell_no" );
    }

    wait 1;

    if ( isdefined( m_light ) )
        level setclientfield( m_light, 0 );
}

sq_bp_start_puzzle_lights()
{
    level endon( "sq_bp_wrong_button" );
    level endon( "sq_bp_timeout" );
    a_button_structs = getstructarray( "sq_bp_button", "targetname" );
    a_tags = [];

    foreach ( m_button in a_button_structs )
        a_tags[a_tags.size] = m_button.script_string;

    a_tags = array_randomize( a_tags );
    m_lightboard = getent( "sq_bp_board", "targetname" );

    if ( !isdefined( level.t_start ) )
        level.t_start = spawn( "trigger_radius_use", m_lightboard.origin, 0, 16, 16 );

    level.t_start setcursorhint( "HINT_NOICON" );
    level.t_start sethintstring( &"ZM_BURIED_SQ_SWIT_U" );
    level.t_start triggerignoreteam();
    level.t_start usetriggerrequirelookat();

    level.t_start waittill( "trigger" );

    level.t_start delete();

    foreach ( str_tag in a_tags )
    {
        wait_network_frame();
        wait_network_frame();
        level thread sq_bp_set_current_bulb( str_tag );

        level waittill( "sq_bp_correct_button" );
    }

    flag_set( "sq_ip_puzzle_complete" );
    a_button_structs = getstructarray( "sq_bp_button", "targetname" );

    foreach ( s_button in a_button_structs )
    {
        if ( isdefined( s_button.trig ) )
            s_button.trig delete();
    }
}

sq_bp_set_current_bulb( str_tag )
{
    level endon( "sq_bp_correct_button" );
    level endon( "sq_bp_wrong_button" );
    level endon( "sq_bp_timeout" );

    if ( isdefined( level.m_sq_bp_active_light ) )
        level.str_sq_bp_active_light = "";

    level.m_sq_bp_active_light = sq_bp_light_on( str_tag, "yellow" );
    level.str_sq_bp_active_light = str_tag;
    wait 10;
    level notify( "sq_bp_timeout" );
}

sq_bp_delete_green_lights()
{
    a_button_structs = getstructarray( "sq_bp_button", "targetname" );

    foreach ( m_button in a_button_structs )
    {
        str_clientfield = "buried_sq_bp_" + m_button.script_string;
        level setclientfield( str_clientfield, 0 );
    }

    if ( isdefined( level.m_sq_bp_active_light ) )
        level.str_sq_bp_active_light = "";
}

sq_bp_light_on( str_tag, str_color )
{
    str_clientfield = "buried_sq_bp_" + str_tag;
    n_color = 1;

    if ( str_color == "green" )
        n_color = 2;

    level setclientfield( str_clientfield, 0 );
    wait_network_frame();
    level setclientfield( str_clientfield, n_color );
    return str_clientfield;
}

debug_tag( str_tag )
{
/#
    self endon( "death" );

    while ( true )
    {
        debugstar( self gettagorigin( str_tag ), 1, ( 1, 0, 0 ) );
        wait 0.05;
    }
#/
}

sq_ml_spawn_lever( n_index )
{
    m_lever = spawn( "script_model", ( 0, 0, 0 ) );
    m_lever setmodel( self.model );
    m_lever.targetname = "sq_ml_lever";

    while ( true )
    {
        v_spot = self.origin;
        v_angles = self.angles;

        if ( isdefined( level._maze._active_perm_list[n_index] ) )
        {
            is_flip = randomint( 2 );
            s_spot = getstruct( level._maze._active_perm_list[n_index], "script_noteworthy" );
            v_right = anglestoright( s_spot.angles );
            v_offset = vectornormalize( v_right ) * 2;

            if ( is_flip )
                v_offset *= -1;

            v_spot = s_spot.origin + vectorscale( ( 0, 0, 1 ), 48.0 ) + v_offset;
            v_angles = s_spot.angles + vectorscale( ( 0, 1, 0 ), 90.0 );

            if ( is_flip )
                v_angles = s_spot.angles - vectorscale( ( 0, 1, 0 ), 90.0 );
        }

        m_lever.origin = v_spot;
        m_lever.angles = v_angles;
/#
        m_lever thread sq_ml_show_lever_debug( v_spot, n_index );
#/
        level waittill( "zm_buried_maze_changed" );
    }
}

sq_ml_show_lever_debug( v_spot, n_index )
{
    level endon( "zm_buried_maze_changed" );
/#
    while ( true )
    {
        line( self.origin, v_spot, ( 0, 0, 1 ) );
        print3d( self.origin, "" + n_index, ( 0, 1, 0 ), 1, 2 );
        wait 0.05;
    }
#/
}

sq_ml_spawn_trigger()
{
    v_right = anglestoforward( self.angles );
    v_offset = vectornormalize( v_right ) * 8;
    self.trig = spawn( "trigger_box_use", self.origin - v_offset, 0, 16, 16, 16 );
    self.trig enablelinkto();
    self.trig linkto( self );
    self.trig setcursorhint( "HINT_NOICON" );
    self.trig sethintstring( &"ZM_BURIED_SQ_SWIT_U" );
    self.trig triggerignoreteam();
    self.trig usetriggerrequirelookat();
    self.is_flipped = 0;
    self useanimtree( -1 );

    while ( true )
    {
        self.trig waittill( "trigger" );

        self setanim( level.maze_switch_anim["switch_down"] );
        self.trig sethintstring( "" );
        self.is_flipped = 1;
        self.n_flip_number = level.sq_ml_curr_lever;
        level.sq_ml_curr_lever++;
        self.trig playsound( "zmb_sq_maze_switch" );

        level waittill( "sq_ml_reset_levers" );

        self setanim( level.maze_switch_anim["switch_up"] );
        self.trig sethintstring( &"ZM_BURIED_SQ_SWIT_U" );
        self.is_flipped = 0;
    }
}

sq_ml_spawn_levers()
{
    if ( maps\mp\zombies\_zm_zonemgr::player_in_zone( "zone_maze" ) )
        level waittill( "zm_buried_maze_changed" );

    a_lever_structs = getstructarray( "sq_maze_lever", "targetname" );

    for ( i = 0; i < a_lever_structs.size; i++ )
        a_lever_structs[i] thread sq_ml_spawn_lever( i );
}

sq_ml_puzzle_logic()
{
    a_levers = getentarray( "sq_ml_lever", "targetname" );
    level.sq_ml_curr_lever = 0;
    a_levers = array_randomize( a_levers );

    for ( i = 0; i < a_levers.size; i++ )
        a_levers[i].n_lever_order = i;

    while ( true )
    {
        level.sq_ml_curr_lever = 0;
        sq_ml_puzzle_wait_for_levers();
        n_correct = 0;

        foreach ( m_lever in a_levers )
        {
            if ( m_lever.n_flip_number == m_lever.n_lever_order )
            {
                playfxontag( level._effect["sq_spark"], m_lever, "tag_origin" );
                n_correct++;
                m_lever playsound( "zmb_sq_maze_correct_spark" );
            }
        }
/#
        iprintlnbold( "Levers Correct: " + n_correct );
#/
        if ( n_correct == a_levers.size )
            flag_set( "sq_ip_puzzle_complete" );

        level waittill( "zm_buried_maze_changed" );

        level notify( "sq_ml_reset_levers" );
        wait 1;
    }
}

sq_ml_puzzle_wait_for_levers()
{
    a_levers = getentarray( "sq_ml_lever", "targetname" );
    are_all_flipped = 0;

    while ( !are_all_flipped )
    {
        are_all_flipped = 1;

        foreach ( m_lever in a_levers )
        {
            if ( m_lever.is_flipped == 0 )
                are_all_flipped = 0;
        }

        wait 1;
    }
}
