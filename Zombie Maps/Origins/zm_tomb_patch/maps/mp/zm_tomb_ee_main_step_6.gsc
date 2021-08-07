//checked includes cerberus output
#include maps/mp/zombies/_zm_weap_one_inch_punch;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zm_tomb_ee_main;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	declare_sidequest_stage( "little_girl_lost", "step_6", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage() //checked matches cerberus output
{
	level._cur_stage_name = "step_6";
	maps/mp/zombies/_zm_spawner::add_custom_zombie_spawn_logic( ::ruins_fist_glow_monitor );
}

stage_logic() //checked matches cerberus output
{
	/*
/#
	iprintln( level._cur_stage_name + " of little girl lost started" );
#/
	*/
	level setclientfield( "sndChamberMusic", 1 );
	flag_wait( "ee_all_players_upgraded_punch" );
	level setclientfield( "sndChamberMusic", 0 );
	wait_network_frame();
	stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success ) //checked matches cerberus output
{
}

ruins_fist_glow_monitor() //checked changed to match cerberus output
{
	if ( flag( "ee_all_players_upgraded_punch" ) )
	{
		return;
	}
	if ( isDefined( self.zone_name ) && self.zone_name == "ug_bottom_zone" )
	{
		wait 0.1;
		self setclientfield( "ee_zombie_fist_fx", 1 );
		self.has_soul = 1;
		while ( isalive( self ) )
		{
			self waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
			if ( !isDefined( inflictor.n_ee_punch_souls ) )
			{
				inflictor.n_ee_punch_souls = 0;
				inflictor.b_punch_upgraded = 0;
			}
			if ( self.has_soul && inflictor.n_ee_punch_souls < 20 && isDefined( weaponname ) && weaponname == "one_inch_punch_zm" && is_true( self.completed_emerging_into_playable_area ) )
			{
				self setclientfield( "ee_zombie_fist_fx", 0 );
				self.has_soul = 0;
				playsoundatposition( "zmb_squest_punchtime_punched", self.origin );
				inflictor.n_ee_punch_souls++;
				if ( inflictor.n_ee_punch_souls == 20 )
				{
					level thread spawn_punch_upgrade_tablet( self.origin, inflictor );
				}
			}
		}
	}
}

spawn_punch_upgrade_tablet( v_origin, e_player ) //checked changed to match cerberus output
{
	m_tablet = spawn( "script_model", v_origin + vectorScale( ( 0, 0, 1 ), 50 ) );
	m_tablet setmodel( "p6_zm_tm_tablet" );
	m_fx = spawn( "script_model", m_tablet.origin );
	m_fx setmodel( "tag_origin" );
	m_fx setinvisibletoall();
	m_fx setvisibletoplayer( e_player );
	m_tablet linkto( m_fx );
	playfxontag( level._effect[ "special_glow" ], m_fx, "tag_origin" );
	m_fx thread rotate_punch_upgrade_tablet();
	m_tablet playloopsound( "zmb_squest_punchtime_tablet_loop", 0.5 );
	m_tablet setinvisibletoall();
	m_tablet setvisibletoplayer( e_player );
	while ( isDefined( e_player ) && !e_player istouching( m_tablet ) )
	{
		wait 0.05;
	}
	m_tablet delete();
	m_fx delete();
	e_player playsound( "zmb_squest_punchtime_tablet_pickup" );
	if ( isDefined( e_player ) )
	{
		e_player thread fadetoblackforxsec( 0, 0.3, 0.5, 0.5, "white" );
		a_zombies = getaispeciesarray( level.zombie_team, "all" );
		foreach ( zombie in a_zombies )
		{
			if ( distance2dsquared( e_player.origin, zombie.origin ) < 65536 && !is_true( zombie.is_mechz ) && is_true( zombie.has_legs ) && is_true( zombie.completed_emerging_into_playable_area ) )
			{
				zombie.v_punched_from = e_player.origin;
				zombie animcustom( maps/mp/zombies/_zm_weap_one_inch_punch::knockdown_zombie_animate );
			}
		}
		wait 1;
		e_player.b_punch_upgraded = 1;
		if ( e_player hasweapon( "staff_fire_upgraded_zm" ) )
		{
			e_player.str_punch_element = "fire";
		}
		else if ( e_player hasweapon( "staff_air_upgraded_zm" ) )
		{
			e_player.str_punch_element = "air";
		}
		else if ( e_player hasweapon( "staff_lightning_upgraded_zm" ) )
		{
			e_player.str_punch_element = "lightning";
		}
		else if ( e_player hasweapon( "staff_water_upgraded_zm" ) )
		{
			e_player.str_punch_element = "ice";
		}
		else
		{
			e_player.str_punch_element = "upgraded";
		}
		e_player thread maps/mp/zombies/_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
		a_players = getplayers();
		foreach ( player in a_players )
		{
			if ( !isDefined( player.b_punch_upgraded ) || !player.b_punch_upgraded )
			{
				return;
			}
		}
		flag_set( "ee_all_players_upgraded_punch" );
	}
}

rotate_punch_upgrade_tablet() //checked matches cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		self rotateyaw( 360, 5 );
		self waittill( "rotatedone" );
	}
}

