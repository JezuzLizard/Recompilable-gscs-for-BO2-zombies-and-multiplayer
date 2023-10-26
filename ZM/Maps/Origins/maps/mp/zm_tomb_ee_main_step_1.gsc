// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_tomb_ee_main;

init()
{
    declare_sidequest_stage( "little_girl_lost", "step_1", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    level._cur_stage_name = "step_1";
}

stage_logic()
{
/#
    iprintln( level._cur_stage_name + " of little girl lost started" );
#/
    flag_wait( "ee_all_staffs_upgraded" );
    wait_network_frame();
    stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success )
{

}
