// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_tomb_ee_main;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zm_tomb_vo;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zm_tomb_chamber;

init()
{
    declare_sidequest_stage( "little_girl_lost", "step_8", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    level._cur_stage_name = "step_8";
    level.quadrotor_custom_behavior = ::move_into_portal;
}

stage_logic()
{
/#
    iprintln( level._cur_stage_name + " of little girl lost started" );
#/
    level notify( "tomb_sidequest_complete" );

    foreach ( player in get_players() )
    {
        if ( player is_player_in_chamber() )
            player thread fadetoblackforxsec( 0, 1, 0.5, 0.5, "white" );
    }

    wait 0.5;
    level setclientfield( "ee_sam_portal", 2 );
    level notify( "stop_random_chamber_walls" );
    a_walls = getentarray( "chamber_wall", "script_noteworthy" );

    foreach ( e_wall in a_walls )
    {
        e_wall thread maps\mp\zm_tomb_chamber::move_wall_up();
        e_wall hide();
    }

    flag_wait( "ee_quadrotor_disabled" );
    wait 1;
    level thread ee_samantha_say( "vox_sam_all_staff_freedom_0" );
    s_pos = getstruct( "player_portal_final", "targetname" );
    t_portal = tomb_spawn_trigger_radius( s_pos.origin, 100, 1 );
    t_portal.require_look_at = 1;
    t_portal.hint_string = &"ZM_TOMB_TELE";
    t_portal thread waittill_player_activates();
    level.ee_ending_beam_fx = spawn( "script_model", s_pos.origin + vectorscale( ( 0, 0, -1 ), 300.0 ) );
    level.ee_ending_beam_fx.angles = vectorscale( ( 0, 1, 0 ), 90.0 );
    level.ee_ending_beam_fx setmodel( "tag_origin" );
    playfxontag( level._effect["ee_beam"], level.ee_ending_beam_fx, "tag_origin" );
    level.ee_ending_beam_fx playsound( "zmb_squest_crystal_sky_pillar_start" );
    level.ee_ending_beam_fx playloopsound( "zmb_squest_crystal_sky_pillar_loop", 3 );
    flag_wait( "ee_samantha_released" );
    t_portal tomb_unitrigger_delete();
    wait_network_frame();
    stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success )
{

}

waittill_player_activates()
{
    while ( true )
    {
        self waittill( "trigger", player );

        flag_set( "ee_samantha_released" );
    }
}

move_into_portal()
{
    s_goal = getstruct( "maxis_portal_path", "targetname" );

    if ( distance2dsquared( self.origin, s_goal.origin ) < 250000 )
    {
        self setvehgoalpos( s_goal.origin, 1, 2, 1 );
        self waittill_any( "near_goal", "force_goal", "reached_end_node" );
        maxissay( "vox_maxi_drone_upgraded_1", self );
        wait 1;
        level thread maxissay( "vox_maxi_drone_upgraded_2", self );
        s_goal = getstruct( s_goal.target, "targetname" );
        self setvehgoalpos( s_goal.origin, 1, 0, 1 );
        self waittill_any( "near_goal", "force_goal", "reached_end_node" );
        self playsound( "zmb_qrdrone_leave" );
        flag_set( "ee_quadrotor_disabled" );
        self dodamage( 200, self.origin );
        self delete();
        level.maxis_quadrotor = undefined;
    }
}
