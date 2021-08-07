//checked includes match cerberus output
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_ee_main;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	declare_sidequest_stage( "little_girl_lost", "step_3", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage() //checked matches cerberus output
{
	level._cur_stage_name = "step_3";
	level.check_valid_poi = ::mech_zombie_hole_valid;
	create_buttons_and_triggers();
}

stage_logic() //checked matches cerberus output
{
	/*
/#
	iprintln( level._cur_stage_name + " of little girl lost started" );
#/
	*/
	level thread watch_for_triple_attack();
	flag_wait( "ee_mech_zombie_hole_opened" );
	wait_network_frame();
	stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success ) //checked changed to match cerberus output
{
	level.check_valid_poi = undefined;
	level notify( "fire_link_cooldown" );
	flag_set( "fire_link_enabled" );
	a_buttons = getentarray( "fire_link_button", "targetname" );
	array_delete( a_buttons );
	a_structs = getstructarray( "fire_link", "targetname" );
	foreach ( unitrigger_stub in a_structs )
	{
		unregister_unitrigger( unitrigger_stub );
	}
}

create_buttons_and_triggers() //checked changed to match cerberus output
{
	a_structs = getstructarray( "fire_link", "targetname" );
	foreach ( unitrigger_stub in a_structs )
	{
		unitrigger_stub.radius = 36;
		unitrigger_stub.height = 256;
		unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
		unitrigger_stub.cursor_hint = "HINT_NOICON";
		unitrigger_stub.require_look_at = 1;
		m_model = spawn( "script_model", unitrigger_stub.origin );
		m_model setmodel( "p_rus_alarm_button" );
		m_model.angles = unitrigger_stub.angles;
		m_model.targetname = "fire_link_button";
		m_model thread ready_to_activate( unitrigger_stub );
		wait_network_frame();
	}
}

ready_to_activate( unitrigger_stub ) //checked matches cerberus output
{
	self endon( "death" );
	self playsoundwithnotify( "vox_maxi_robot_sync_0", "sync_done" );
	self waittill( "sync_done" );
	wait 0.5;
	self playsoundwithnotify( "vox_maxi_robot_await_0", "ready_to_use" );
	self waittill( "ready_to_use" );
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::activate_fire_link );
}

watch_for_triple_attack() //checked matches cerberus output
{
	t_hole = getent( "fire_link_damage", "targetname" );
	while ( !flag( "ee_mech_zombie_hole_opened" ) )
	{
		t_hole waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( isDefined( weaponname ) && weaponname == "beacon_zm" && flag( "fire_link_enabled" ) )
		{
			playsoundatposition( "zmb_squest_robot_floor_collapse", t_hole.origin );
			wait 3;
			m_floor = getent( "easter_mechzombie_spawn", "targetname" );
			m_floor delete();
			flag_set( "ee_mech_zombie_hole_opened" );
			t_hole delete();
			return;
		}
	}
}

mech_zombie_hole_valid( valid ) //checked matches cerberus output
{
	t_hole = getent( "fire_link_damage", "targetname" );
	if ( self istouching( t_hole ) )
	{
		return 1;
	}
	return valid;
}

activate_fire_link() //checked changed to match cerberus output
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		self playsound( "zmb_squest_robot_button" );
		if ( flag( "three_robot_round" ) )
		{
			level thread fire_link_cooldown( self );
			self playsound( "zmb_squest_robot_button_activate" );
			self playloopsound( "zmb_squest_robot_button_timer", 0.5 );
			flag_waitopen( "fire_link_enabled" );
			self stoploopsound( 0.5 );
			self playsound( "zmb_squest_robot_button_deactivate" );
		}
		else
		{
			self playsound( "vox_maxi_robot_abort_0" );
			self playsound( "zmb_squest_robot_button_deactivate" );
			wait 3;
		}
	}
}

fire_link_cooldown( t_button ) //checked matches cerberus output
{
	level notify( "fire_link_cooldown" );
	level endon( "fire_link_cooldown" );
	flag_set( "fire_link_enabled" );
	if ( isDefined( t_button ) )
	{
		t_button playsound( "vox_maxi_robot_activated_0" );
	}
	wait 25;
	if ( isDefined( t_button ) )
	{
		t_button playsound( "vox_maxi_robot_deactivated_0" );
	}
	flag_clear( "fire_link_enabled" );
}

