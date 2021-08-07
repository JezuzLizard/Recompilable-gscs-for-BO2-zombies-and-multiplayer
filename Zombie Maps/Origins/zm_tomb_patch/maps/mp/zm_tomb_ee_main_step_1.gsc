//checked includes matche cerberus output
#include maps/mp/zm_tomb_ee_main;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	declare_sidequest_stage( "little_girl_lost", "step_1", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage() //checked matches cerberus output
{
	level._cur_stage_name = "step_1";
}

stage_logic() //checked matches cerberus output
{
	/*
/#
	iprintln( level._cur_stage_name + " of little girl lost started" );
#/
	*/
	flag_wait( "ee_all_staffs_upgraded" );
	wait_network_frame();
	stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success ) //checked matches cerberus output
{
}
