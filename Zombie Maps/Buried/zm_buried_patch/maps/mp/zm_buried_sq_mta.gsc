#include maps/mp/zm_buried_sq;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	flag_init( "sq_amplifiers_on" );
	a_amp_structs = getstructarray( "sq_amplifier_spot" );
	_a16 = a_amp_structs;
	_k16 = getFirstArrayKey( _a16 );
	while ( isDefined( _k16 ) )
	{
		s_amp_spot = _a16[ _k16 ];
		m_amplifier = spawn( "script_model", s_amp_spot.origin );
		m_amplifier thread mta_amplifier_init();
		_k16 = getNextArrayKey( _a16, _k16 );
	}
	declare_sidequest_stage( "sq", "mta", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
	a_amplifiers = getentarray( "sq_amplifier", "targetname" );
	array_thread( a_amplifiers, ::mta_amplifier_found_watcher );
	level thread stage_vo_max();
	level thread stage_vo_ric();
	level._cur_stage_name = "mta";
	clientnotify( "mta" );
}

stage_logic()
{
/#
	iprintlnbold( "MTA Started" );
#/
	flag_wait_any( "sq_amplifiers_on", "sq_amplifiers_broken" );
	wait_network_frame();
	stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{
}

stage_vo_max()
{
	level thread stage_vo_max_amp_broken();
	level waittill( "mta_amp_found", amp );
	maxissay( "vox_maxi_sidequest_amp_0", amp );
	maxissay( "vox_maxi_sidequest_amp_1", amp );
}

stage_vo_max_amp_broken()
{
	level waittill( "mta_amp_broken", amp );
	maxissay( "vox_maxi_sidequest_amp_2", amp );
	level waittill( "mta_amp_broken", amp );
	maxissay( "vox_maxi_sidequest_amp_3", amp );
	level waittill( "mta_amp_broken", amp );
	maxissay( "vox_maxi_sidequest_amp_4", amp );
	level waittill( "mta_amp_broken", amp );
	maxissay( "vox_maxi_sidequest_amp_5", amp );
	maxissay( "vox_maxi_sidequest_gl_0", amp );
	maxissay( "vox_maxi_sidequest_gl_1", amp );
}

stage_vo_ric()
{
	level thread stage_vo_ric_amp_amplified();
	level waittill( "mta_amp_found_by_sam" );
	richtofensay( "vox_zmba_sidequest_amp_0", 10 );
	richtofensay( "vox_zmba_sidequest_amp_1", 7 );
}

stage_vo_ric_amp_amplified()
{
	level waittill( "mta_amp_amplified" );
	richtofensay( "vox_zmba_sidequest_amp_2", 6 );
	richtofensay( "vox_zmba_sidequest_amp_3", 4 );
}

mta_amplifier_found_watcher()
{
	self endon( "damaged_by_subwoofer" );
	self endon( "amplifier_filled" );
	if ( self.amplifier_state != "base" )
	{
		return;
	}
	trigger = spawn( "trigger_radius", self.origin, 0, 128, 72 );
	trigger waittill( "trigger", who );
	if ( isDefined( level.rich_sq_player ) && who == level.rich_sq_player )
	{
		level notify( "mta_amp_found_by_sam" );
	}
	else
	{
		level notify( "mta_amp_found" );
	}
}

mta_amplifier_init()
{
	self setmodel( "p6_zm_bu_ether_amplifier" );
	self.targetname = "sq_amplifier";
	self.script_noteworthy = "subwoofer_target";
	self.amplifier_state = "base";
	self playloopsound( "zmb_sq_amplifier_empty_loop", 1 );
	self setcandamage( 1 );
	self thread mta_amplifier_subwoofer_watch();
	self mta_amplifier_damage_watch();
}

mta_amplifier_subwoofer_watch()
{
	self waittill( "damaged_by_subwoofer" );
/#
	iprintlnbold( "Amplifier Broken" );
#/
	self.amplifier_state = "broken";
	self setmodel( "p6_zm_bu_ether_amplifier_dmg" );
	self stoploopsound( 0,1 );
	self playsound( "zmb_sq_amplifier_destroy" );
	level notify( "mta_amp_broken" );
	mta_check_all_amplifier_states();
}

mta_amplifier_damage_watch()
{
	self endon( "damaged_by_subwoofer" );
	n_slowgun_count = 0;
	while ( 1 )
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_type, str_tag, str_model, str_part, str_weapon );
		if ( str_weapon == "slowgun_zm" || str_weapon == "slowgun_upgraded_zm" )
		{
			n_slowgun_count++;
			shader_amount = linear_map( n_slowgun_count, 0, 25, 0, 1 );
			self setclientfield( "AmplifierShaderConstant", shader_amount );
			if ( n_slowgun_count >= 25 )
			{
/#
				iprintlnbold( "Amplifier Filled" );
#/
				self thread mta_amplifier_filled_fx();
				self.amplifier_state = "filled";
				self playsound( "zmb_sq_amplifier_fill" );
				self playloopsound( "zmb_sq_amplifier_full_loop", 1 );
				self notify( "amplifier_filled" );
				level notify( "mta_amp_amplified" );
				break;
			}
		}
		else
		{
			wait_network_frame();
		}
	}
	mta_check_all_amplifier_states();
}

mta_amplifier_filled_fx()
{
	while ( 1 )
	{
		playfx( level._effect[ "sq_ether_amp_trail" ], self.origin + vectorScale( ( 0, 0, 1 ), 46 ) );
		wait 1;
	}
}

mta_check_all_amplifier_states()
{
	is_all_broken = 1;
	is_all_filled = 1;
	a_amplifiers = getentarray( "sq_amplifier", "targetname" );
	_a226 = a_amplifiers;
	_k226 = getFirstArrayKey( _a226 );
	while ( isDefined( _k226 ) )
	{
		m_amplifier = _a226[ _k226 ];
		if ( m_amplifier.amplifier_state != "filled" )
		{
			is_all_filled = 0;
		}
		if ( m_amplifier.amplifier_state != "broken" )
		{
			is_all_broken = 0;
		}
		_k226 = getNextArrayKey( _a226, _k226 );
	}
	if ( is_all_filled )
	{
		flag_set( "sq_amplifiers_on" );
	}
	else
	{
		if ( is_all_broken )
		{
			flag_set( "sq_amplifiers_broken" );
		}
	}
}
