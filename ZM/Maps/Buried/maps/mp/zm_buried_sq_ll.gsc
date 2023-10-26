// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_buried_sq;

init()
{
    flag_init( "sq_ll_generator_on" );
    declare_sidequest_stage( "sq", "ll", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    level._cur_stage_name = "ll";
    clientnotify( "ll" );
}

stage_logic()
{
/#
    iprintlnbold( "LL Started" );
#/
    if ( !isdefined( level.generator_power_states_color ) )
        level.generator_power_states_color = 0;

    sq_ll_show_code();
    wait_network_frame();
    stage_completed( "sq", level._cur_stage_name );
}

sq_ll_show_code()
{
    a_spots = getstructarray( "sq_code_pos", "targetname" );
    a_signs = getentarray( "sq_tunnel_sign", "targetname" );
    a_codes = [];

    foreach ( m_sign in a_signs )
    {
        if ( flag( "sq_is_max_tower_built" ) )
        {
            if ( isdefined( m_sign.is_max_sign ) )
                a_codes[a_codes.size] = m_sign.model + "_code";

            continue;
        }

        if ( isdefined( m_sign.is_ric_sign ) )
            a_codes[a_codes.size] = m_sign.model + "_code";
    }

    for ( i = 0; i < a_codes.size; i++ )
    {
        if ( a_codes[i] == "p6_zm_bu_sign_tunnel_consumption_code" )
            a_codes[i] = "p6_zm_bu_sign_tunnel_consump_code";
    }

    for ( i = 0; i < a_codes.size; i++ )
    {
        m_code = spawn( "script_model", a_spots[i].origin );
        m_code.angles = a_spots[i].angles;
        m_code setmodel( a_codes[i] );
    }

    if ( flag( "sq_is_max_tower_built" ) )
        level thread sq_ll_show_code_vo_max();
    else
        level thread sq_ll_show_code_vo_ric();
}

exit_stage( success )
{

}

sq_ll_show_code_vo_max()
{
    a_signs = getentarray( "sq_tunnel_sign", "targetname" );
    maxissay( "vox_maxi_sidequest_signs_0", a_signs[0] );
    maxissay( "vox_maxi_sidequest_signs_1", a_signs[0] );
}

sq_ll_show_code_vo_ric()
{
    richtofensay( "vox_zmba_sidequest_signs_0", 7 );
    richtofensay( "vox_zmba_sidequest_signs_1", 10 );
    richtofensay( "vox_zmba_sidequest_signs_2", 9 );
}
