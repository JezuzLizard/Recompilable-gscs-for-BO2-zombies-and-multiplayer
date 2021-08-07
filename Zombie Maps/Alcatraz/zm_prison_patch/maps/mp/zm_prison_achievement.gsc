#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level thread achievement_full_lockdown();
	level thread achievement_pop_goes_the_weasel();
	level thread achievement_trapped_in_time();
	onplayerconnect_callback( ::onplayerconnect );
	level.achievement_sound_func = ::achievement_sound_func;
}

onplayerconnect()
{
	self thread achievement_no_one_escapes_alive();
	self thread achievement_feed_the_beast();
	self thread achievement_making_the_rounds();
	self thread achievement_acid_drip();
	self thread achievement_a_burst_of_flavor();
	self thread achievement_paranormal_progress();
	self thread achievement_gg_bridge();
}

achievement_sound_func( achievement_name_lower )
{
	self thread do_player_general_vox( "general", "achievement" );
}

init_player_achievement_stats()
{
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_prison_sidequest", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_feed_the_beast", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_making_the_rounds", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_acid_drip", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_full_lockdown", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_a_burst_of_flavor", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_paranormal_progress", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_gg_bridge", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_trapped_in_time", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc2_pop_goes_the_weasel", 0 );
}

achievement_full_lockdown()
{
	level endon( "end_game" );
	level.lockdown_track[ "magic_box" ] = 0;
	level.lockdown_track[ "speedcola_perk" ] = 0;
	level.lockdown_track[ "electric_cherry_perk" ] = 0;
	level.lockdown_track[ "jugg_perk" ] = 0;
	level.lockdown_track[ "deadshot_perk" ] = 0;
	level.lockdown_track[ "tap_perk" ] = 0;
	level.lockdown_track[ "plane_ramp" ] = 0;
	level.lockdown_track[ "craft_shield" ] = 0;
	level.lockdown_track[ "craft_kit" ] = 0;
	b_unlock = 0;
	while ( b_unlock == 0 )
	{
		level waittill( "brutus_locked_object" );
		b_unlock = 1;
		_a92 = level.lockdown_track;
		_k92 = getFirstArrayKey( _a92 );
		while ( isDefined( _k92 ) )
		{
			b_check = _a92[ _k92 ];
			if ( b_check == 0 )
			{
				b_unlock = 0;
				break;
			}
			else
			{
				_k92 = getNextArrayKey( _a92, _k92 );
			}
		}
	}
	level giveachievement_wrapper( "ZM_DLC2_FULL_LOCKDOWN", 1 );
}

achievement_trapped_in_time()
{
	level endon( "end_game" );
	level.trapped_track[ "acid" ] = 0;
	level.trapped_track[ "fan" ] = 0;
	level.trapped_track[ "tower" ] = 0;
	level.trapped_track[ "tower_upgrade" ] = 0;
	b_unlock = 0;
	while ( b_unlock == 0 )
	{
		level waittill_either( "trap_activated", "tower_trap_upgraded" );
		if ( level.round_number >= 10 )
		{
			return;
		}
		b_unlock = 1;
		_a131 = level.trapped_track;
		_k131 = getFirstArrayKey( _a131 );
		while ( isDefined( _k131 ) )
		{
			b_check = _a131[ _k131 ];
			if ( b_check == 0 )
			{
				b_unlock = 0;
				break;
			}
			else
			{
				_k131 = getNextArrayKey( _a131, _k131 );
			}
		}
	}
	level giveachievement_wrapper( "ZM_DLC2_TRAPPED_IN_TIME", 1 );
}

achievement_pop_goes_the_weasel()
{
	level endon( "end_game" );
	level waittill( "pop_goes_the_weasel_achieved" );
	level giveachievement_wrapper( "ZM_DLC2_POP_GOES_THE_WEASEL", 1 );
}

achievement_no_one_escapes_alive()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "player_at_bridge" );
	self giveachievement_wrapper( "ZM_DLC2_PRISON_SIDEQUEST" );
}

achievement_feed_the_beast()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "player_obtained_tomahawk" );
	self giveachievement_wrapper( "ZM_DLC2_FEED_THE_BEAST" );
}

achievement_making_the_rounds()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	n_completed_trips = 0;
	while ( n_completed_trips < 3 )
	{
		self waittill( "player_completed_cycle" );
		n_completed_trips++;
	}
	self giveachievement_wrapper( "ZM_DLC2_MAKING_THE_ROUNDS" );
}

achievement_acid_drip()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "player_obtained_acidgat" );
	self giveachievement_wrapper( "ZM_DLC2_ACID_DRIP" );
}

achievement_a_burst_of_flavor()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "electric_cherry_start" );
		self.cherry_kills = 0;
		self waittill( "electric_cherry_end" );
		if ( self.cherry_kills >= 10 )
		{
			break;
		}
		else
		{
		}
	}
	self giveachievement_wrapper( "ZM_DLC2_A_BURST_OF_FLAVOR" );
}

achievement_paranormal_progress()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "player_opened_afterlife_door" );
	self giveachievement_wrapper( "ZM_DLC2_PARANORMAL_PROGRESS" );
}

achievement_gg_bridge()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( 1 )
	{
		level waittill( "end_of_round" );
		if ( self maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_golden_gate_bridge" ) && level.round_number >= 15 )
		{
			level waittill( "end_of_round" );
			if ( self maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_golden_gate_bridge" ) )
			{
				break;
			}
		}
		else
		{
		}
	}
	self giveachievement_wrapper( "ZM_DLC2_GG_BRIDGE" );
}
