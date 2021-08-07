#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/_utility;
#include common_scripts/utility;

pers_upgrade_init()
{
	setup_pers_upgrade_boards();
	setup_pers_upgrade_revive();
	setup_pers_upgrade_multi_kill_headshots();
	setup_pers_upgrade_cash_back();
	setup_pers_upgrade_insta_kill();
	setup_pers_upgrade_jugg();
	setup_pers_upgrade_carpenter();
	level thread pers_upgrades_monitor();
}

setup_pers_upgrade_boards()
{
	if ( isDefined( level.pers_upgrade_boards ) && level.pers_upgrade_boards )
	{
		level.pers_boarding_round_start = 10;
		level.pers_boarding_number_of_boards_required = 74;
		pers_register_upgrade( "board", ::pers_upgrade_boards_active, "pers_boarding", level.pers_boarding_number_of_boards_required, 0 );
	}
}

setup_pers_upgrade_revive()
{
	if ( isDefined( level.pers_upgrade_revive ) && level.pers_upgrade_revive )
	{
		level.pers_revivenoperk_number_of_revives_required = 17;
		level.pers_revivenoperk_number_of_chances_to_keep = 1;
		pers_register_upgrade( "revive", ::pers_upgrade_revive_active, "pers_revivenoperk", level.pers_revivenoperk_number_of_revives_required, 1 );
	}
}

setup_pers_upgrade_multi_kill_headshots()
{
	if ( isDefined( level.pers_upgrade_multi_kill_headshots ) && level.pers_upgrade_multi_kill_headshots )
	{
		level.pers_multikill_headshots_required = 5;
		level.pers_multikill_headshots_upgrade_reset_counter = 25;
		pers_register_upgrade( "multikill_headshots", ::pers_upgrade_headshot_active, "pers_multikill_headshots", level.pers_multikill_headshots_required, 0 );
	}
}

setup_pers_upgrade_cash_back()
{
	if ( isDefined( level.pers_upgrade_cash_back ) && level.pers_upgrade_cash_back )
	{
		level.pers_cash_back_num_perks_required = 50;
		level.pers_cash_back_perk_buys_prone_required = 15;
		level.pers_cash_back_failed_prones = 1;
		level.pers_cash_back_money_reward = 1000;
		pers_register_upgrade( "cash_back", ::pers_upgrade_cash_back_active, "pers_cash_back_bought", level.pers_cash_back_num_perks_required, 0 );
		add_pers_upgrade_stat( "cash_back", "pers_cash_back_prone", level.pers_cash_back_perk_buys_prone_required );
	}
}

setup_pers_upgrade_insta_kill()
{
	if ( isDefined( level.pers_upgrade_insta_kill ) && level.pers_upgrade_insta_kill )
	{
		level.pers_insta_kill_num_required = 2;
		level.pers_insta_kill_upgrade_active_time = 18;
		pers_register_upgrade( "insta_kill", ::pers_upgrade_insta_kill_active, "pers_insta_kill", level.pers_insta_kill_num_required, 0 );
	}
}

setup_pers_upgrade_jugg()
{
	if ( isDefined( level.pers_upgrade_jugg ) && level.pers_upgrade_jugg )
	{
		level.pers_jugg_hit_and_die_total = 3;
		level.pers_jugg_hit_and_die_round_limit = 2;
		level.pers_jugg_round_reached_max = 1;
		level.pers_jugg_round_lose_target = 15;
		level.pers_jugg_upgrade_health_bonus = 90;
		pers_register_upgrade( "jugg", ::pers_upgrade_jugg_active, "pers_jugg", level.pers_jugg_hit_and_die_total, 0 );
	}
}

pers_upgrade_jugg_player_death_stat()
{
	if ( isDefined( level.pers_upgrade_jugg ) && level.pers_upgrade_jugg )
	{
		if ( maps/mp/zombies/_zm_utility::is_classic() )
		{
			if ( isDefined( self.pers_upgrades_awarded[ "jugg" ] ) && !self.pers_upgrades_awarded[ "jugg" ] )
			{
				if ( level.round_number <= level.pers_jugg_hit_and_die_round_limit )
				{
					self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_jugg", 0 );
				}
			}
		}
	}
}

setup_pers_upgrade_carpenter()
{
	if ( isDefined( level.pers_upgrade_carpenter ) && level.pers_upgrade_carpenter )
	{
		level.pers_carpenter_zombie_kills = 1;
		pers_register_upgrade( "carpenter", ::pers_upgrade_carpenter_active, "pers_carpenter", level.pers_carpenter_zombie_kills, 0 );
	}
}

pers_upgrade_boards_active()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "pers_stats_end_of_round" );
		if ( self.rebuild_barrier_reward == 0 )
		{
			self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_boarding", 0 );
			return;
		}
	}
}

pers_upgrade_revive_active()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "player_failed_revive" );
		if ( self.failed_revives >= level.pers_revivenoperk_number_of_chances_to_keep )
		{
			self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_revivenoperk", 0 );
			self.failed_revives = 0;
			return;
		}
	}
}

pers_upgrade_headshot_active()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "zombie_death_no_headshot" );
		self.non_headshot_kill_counter++;
		if ( self.non_headshot_kill_counter >= level.pers_multikill_headshots_upgrade_reset_counter )
		{
			self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_multikill_headshots", 0 );
			self.non_headshot_kill_counter = 0;
			return;
		}
	}
}

pers_upgrade_cash_back_active()
{
	self endon( "disconnect" );
	wait 0,5;
	wait 0,5;
	while ( 1 )
	{
		self waittill( "cash_back_failed_prone" );
		wait 0,1;
		self.failed_cash_back_prones++;
		if ( self.failed_cash_back_prones >= level.pers_cash_back_failed_prones )
		{
			self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_cash_back_bought", 0 );
			self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_cash_back_prone", 0 );
			self.failed_cash_back_prones = 0;
			wait 0,4;
			return;
		}
	}
}

pers_upgrade_insta_kill_active()
{
	self endon( "disconnect" );
	wait 0,2;
	wait 0,2;
	self waittill( "pers_melee_swipe" );
	if ( isDefined( level.pers_melee_swipe_zombie_swiper ) )
	{
		e_zombie = level.pers_melee_swipe_zombie_swiper;
		if ( isalive( e_zombie ) && isDefined( e_zombie.is_zombie ) && e_zombie.is_zombie )
		{
			e_zombie.marked_for_insta_upgraded_death = 1;
			e_zombie dodamage( e_zombie.health + 666, e_zombie.origin, self, self, "none", "MOD_PISTOL_BULLET", 0, "knife_zm" );
		}
		level.pers_melee_swipe_zombie_swiper = undefined;
	}
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_insta_kill", 0 );
	self kill_insta_kill_upgrade_hud_icon();
	wait 0,4;
}

is_insta_kill_upgraded_and_active()
{
	if ( is_classic() )
	{
		if ( self maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
		{
			if ( isDefined( self.pers_upgrades_awarded[ "insta_kill" ] ) && self.pers_upgrades_awarded[ "insta_kill" ] )
			{
				return 1;
			}
		}
	}
	return 0;
}

pers_upgrade_jugg_active()
{
	self endon( "disconnect" );
	wait 0,5;
	wait 0,5;
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "jugg_upgrade", 1, 0 );
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( level.round_number == level.pers_jugg_round_lose_target )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_jugg_downgrade_count", 0 );
			wait 0,5;
			if ( self.pers[ "pers_jugg_downgrade_count" ] >= level.pers_jugg_round_reached_max )
			{
				break;
			}
		}
		else
		{
		}
	}
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "jugg_upgrade", 1, 1 );
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_jugg", 0 );
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_jugg_downgrade_count", 0 );
}

pers_upgrade_carpenter_active()
{
	self endon( "disconnect" );
	wait 0,2;
	wait 0,2;
	level waittill( "carpenter_finished" );
	self.pers_carpenter_kill = undefined;
	while ( 1 )
	{
		self waittill( "carpenter_zombie_killed_check_finished" );
		if ( !isDefined( self.pers_carpenter_kill ) )
		{
			break;
		}
		else
		{
			self.pers_carpenter_kill = undefined;
		}
	}
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_carpenter", 0 );
	wait 0,4;
}

persistent_carpenter_ability_check()
{
	if ( isDefined( level.pers_upgrade_carpenter ) && level.pers_upgrade_carpenter )
	{
		self endon( "disconnect" );
		if ( isDefined( self.pers_upgrades_awarded[ "carpenter" ] ) && self.pers_upgrades_awarded[ "carpenter" ] )
		{
			level.pers_carpenter_boards_active = 1;
		}
		self.pers_carpenter_zombie_check_active = 1;
		self.pers_carpenter_kill = undefined;
		carpenter_extra_time = 3;
		carpenter_finished_start_time = undefined;
		level.carpenter_finished_start_time = undefined;
		while ( 1 )
		{
			if ( !isDefined( level.carpenter_powerup_active ) )
			{
				if ( !isDefined( level.carpenter_finished_start_time ) )
				{
					level.carpenter_finished_start_time = getTime();
				}
				time = getTime();
				dt = ( time - level.carpenter_finished_start_time ) / 1000;
				if ( dt >= carpenter_extra_time )
				{
					break;
				}
			}
			else if ( isDefined( self.pers_carpenter_kill ) )
			{
				if ( isDefined( self.pers_upgrades_awarded[ "carpenter" ] ) && self.pers_upgrades_awarded[ "carpenter" ] )
				{
					break;
				}
				else self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_carpenter", 0 );
			}
			wait 0,01;
		}
		self notify( "carpenter_zombie_killed_check_finished" );
		self.pers_carpenter_zombie_check_active = undefined;
		level.pers_carpenter_boards_active = undefined;
	}
}

pers_zombie_death_location_check( attacker, v_pos )
{
	if ( isDefined( level.pers_upgrade_carpenter ) && level.pers_upgrade_carpenter )
	{
		if ( is_classic() )
		{
			if ( is_player_valid( attacker ) )
			{
				if ( isDefined( attacker.pers_carpenter_zombie_check_active ) )
				{
					if ( !check_point_in_playable_area( v_pos ) )
					{
						attacker.pers_carpenter_kill = 1;
					}
				}
			}
		}
	}
}

insta_kill_pers_upgrade_icon()
{
	if ( self.zombie_vars[ "zombie_powerup_insta_kill_ug_on" ] )
	{
		self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] = level.pers_insta_kill_upgrade_active_time;
		return;
	}
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_on" ] = 1;
	self._show_solo_hud = 1;
	self thread time_remaining_pers_upgrade();
}

time_remaining_pers_upgrade()
{
	self endon( "disconnect" );
	self endon( "kill_insta_kill_upgrade_hud_icon" );
	while ( self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] >= 0 )
	{
		wait 0,05;
		self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] -= 0,05;
	}
	self kill_insta_kill_upgrade_hud_icon();
}

kill_insta_kill_upgrade_hud_icon()
{
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_on" ] = 0;
	self._show_solo_hud = 0;
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] = level.pers_insta_kill_upgrade_active_time;
	self notify( "kill_insta_kill_upgrade_hud_icon" );
}
