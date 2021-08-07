#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level thread achievement_tomb_sidequest();
	level thread achievement_all_your_base();
	level thread achievement_playing_with_power();
	level.achievement_sound_func = ::achievement_sound_func;
	onplayerconnect_callback( ::onplayerconnect );
}

achievement_sound_func( achievement_name_lower )
{
	self endon( "disconnect" );
	if ( !sessionmodeisonlinegame() )
	{
		return;
	}
	i = 0;
	while ( i < ( self getentitynumber() + 1 ) )
	{
		wait_network_frame();
		i++;
	}
	self thread do_player_general_vox( "general", "achievement" );
}

init_player_achievement_stats()
{
	if ( !is_gametype_active( "zclassic" ) )
	{
		return;
	}
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_tomb_sidequest", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_not_a_gold_digger", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_all_your_base", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_kung_fu_grip", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_playing_with_power", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_im_on_a_tank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_saving_the_day_all_day", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_master_of_disguise", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_overachiever", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc4_master_wizard", 0 );
}

onplayerconnect()
{
	self thread achievement_not_a_gold_digger();
	self thread achievement_kung_fu_grip();
	self thread achievement_im_on_a_tank();
	self thread achievement_saving_the_day_all_day();
	self thread achievement_master_of_disguise();
	self thread achievement_master_wizard();
	self thread achievement_overachiever();
}

achievement_tomb_sidequest()
{
	level endon( "end_game" );
	level waittill( "tomb_sidequest_complete" );
/#
#/
	level giveachievement_wrapper( "ZM_DLC4_TOMB_SIDEQUEST", 1 );
}

achievement_all_your_base()
{
	level endon( "end_game" );
	level waittill( "all_zones_captured_none_lost" );
/#
#/
	level giveachievement_wrapper( "ZM_DLC4_ALL_YOUR_BASE", 1 );
}

achievement_playing_with_power()
{
	level endon( "end_game" );
	flag_wait( "ee_all_staffs_crafted" );
/#
#/
	level giveachievement_wrapper( "ZM_DLC4_PLAYING_WITH_POWER", 1 );
}

achievement_overachiever()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "all_challenges_complete" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_OVERACHIEVER" );
}

achievement_not_a_gold_digger()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "dig_up_weapon_shared" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_NOT_A_GOLD_DIGGER" );
}

achievement_kung_fu_grip()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill_multiple( "mechz_grab_released_self", "mechz_grab_released_friendly" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_KUNG_FU_GRIP" );
}

achievement_im_on_a_tank()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "rode_tank_around_map" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_IM_ON_A_TANK" );
}

achievement_saving_the_day_all_day()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill_multiple( "revived_player", "quick_revived_player", "revived_player_with_quadrotor", "revived_player_with_upgraded_staff" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_SAVING_THE_DAY_ALL_DAY" );
}

_zombie_blood_achievement_think()
{
	self endon( "zombie_blood_over" );
	b_finished_achievement = 0;
	if ( !isDefined( self.zombie_blood_revives ) )
	{
		self.zombie_blood_revives = 0;
	}
	if ( !isDefined( self.zombie_blood_generators_started ) )
	{
		self.zombie_blood_generators_started = 0;
	}
	b_did_capture = 0;
	n_revives = 0;
	while ( 1 )
	{
		str_action = waittill_any_return( "completed_zone_capture", "do_revive_ended_normally", "revived_player_with_quadrotor", "revived_player_with_upgraded_staff" );
		if ( issubstr( str_action, "revive" ) )
		{
			self.zombie_blood_revives++;
		}
		else
		{
			if ( str_action == "completed_zone_capture" )
			{
				self.zombie_blood_generators_started++;
			}
		}
		if ( self.zombie_blood_generators_started > 0 && self.zombie_blood_revives >= 3 )
		{
			return 1;
		}
	}
}

achievement_master_of_disguise()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "zombie_blood" );
		b_finished_achievement = self _zombie_blood_achievement_think();
		if ( isDefined( b_finished_achievement ) && b_finished_achievement )
		{
			break;
		}
		else
		{
		}
	}
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_MASTER_OF_DISGUISE" );
}

watch_equipped_weapons_for_upgraded_staffs()
{
	self endon( "disconnect" );
	self endon( "stop_weapon_switch_watcher_thread" );
	while ( 1 )
	{
		self waittill( "weapon_change", str_weapon );
		while ( self.sessionstate != "playing" )
		{
			continue;
		}
		if ( str_weapon == "staff_water_upgraded_zm" )
		{
			self notify( "upgraded_water_staff_equipped" );
			continue;
		}
		else if ( str_weapon == "staff_lightning_upgraded_zm" )
		{
			self notify( "upgraded_lightning_staff_equipped" );
			continue;
		}
		else if ( str_weapon == "staff_fire_upgraded_zm" )
		{
			self notify( "upgraded_fire_staff_equipped" );
			continue;
		}
		else
		{
			if ( str_weapon == "staff_air_upgraded_zm" )
			{
				self notify( "upgraded_air_staff_equipped" );
			}
		}
	}
}

achievement_master_wizard()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self thread watch_equipped_weapons_for_upgraded_staffs();
	self waittill_multiple( "upgraded_air_staff_equipped", "upgraded_lightning_staff_equipped", "upgraded_water_staff_equipped", "upgraded_fire_staff_equipped" );
	self notify( "stop_weapon_switch_watcher_thread" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC4_MASTER_WIZARD" );
}
