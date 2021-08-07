//checked includes match cerberus output
#include maps/mp/zm_tomb_chamber;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zm_tomb_ee_main;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	declare_sidequest_stage( "little_girl_lost", "step_7", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage() //checked matches cerberus output
{
	level._cur_stage_name = "step_7";
	level.n_ee_portal_souls = 0;
}

stage_logic() //checked matches cerberus output
{
	/*
/#
	iprintln( level._cur_stage_name + " of little girl lost started" );
#/
	*/
	level thread monitor_puzzle_portal();
	level setclientfield( "sndChamberMusic", 2 );
	flag_wait( "ee_souls_absorbed" );
	level setclientfield( "sndChamberMusic", 3 );
	wait_network_frame();
	stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success ) //checked matches cerberus output
{
}

ee_zombie_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime ) //checked changed to match cerberus output
{
	if ( isDefined( attacker ) && isplayer( attacker ) && maps/mp/zm_tomb_chamber::is_point_in_chamber( self.origin ) )
	{
		level.n_ee_portal_souls++;
		if ( level.n_ee_portal_souls == 1 )
		{
			level thread ee_samantha_say( "vox_sam_generic_encourage_3" );
		}
		else if ( level.n_ee_portal_souls == floor( 33.33333 ) )
		{
			level thread ee_samantha_say( "vox_sam_generic_encourage_4" );
		}
		else if ( level.n_ee_portal_souls == floor( 66.66666 ) )
		{
			level thread ee_samantha_say( "vox_sam_generic_encourage_5" );
		}
		else if ( level.n_ee_portal_souls == 100 )
		{
			level thread ee_samantha_say( "vox_sam_generic_encourage_0" );
			flag_set( "ee_souls_absorbed" );
		}
		self setclientfield( "ee_zombie_soul_portal", 1 );
	}
}

monitor_puzzle_portal() //checked changed to match cerberus output
{
	/*
/#
	if ( is_true( level.ee_debug ) )
	{
		flag_set( "ee_sam_portal_active" );
		level setclientfield( "ee_sam_portal", 1 );
		return;
#/
	}
	*/
	while ( !flag( "ee_souls_absorbed" ) )
	{
		if ( all_staffs_inserted_in_puzzle_room() && !flag( "ee_sam_portal_active" ) )
		{
			flag_set( "ee_sam_portal_active" );
			level setclientfield( "ee_sam_portal", 1 );
		}
		else if ( !all_staffs_inserted_in_puzzle_room() && flag( "ee_sam_portal_active" ) )
		{
			flag_clear( "ee_sam_portal_active" );
			level setclientfield( "ee_sam_portal", 0 );
		}
		wait 0.5;
	}
}
