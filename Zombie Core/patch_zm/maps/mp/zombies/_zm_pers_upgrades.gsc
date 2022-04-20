#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

pers_upgrade_init() //checked matches cerberus output
{
	setup_pers_upgrade_boards();
	setup_pers_upgrade_revive();
	setup_pers_upgrade_multi_kill_headshots();
	setup_pers_upgrade_cash_back();
	setup_pers_upgrade_insta_kill();
	setup_pers_upgrade_jugg();
	setup_pers_upgrade_carpenter();
	setup_pers_upgrade_flopper();
	setup_pers_upgrade_perk_lose();
	setup_pers_upgrade_pistol_points();
	setup_pers_upgrade_double_points();
	setup_pers_upgrade_sniper();
	setup_pers_upgrade_box_weapon();
	setup_pers_upgrade_nube();
	level thread pers_upgrades_monitor();
}

pers_abilities_init_globals() //checked matches cerberus output
{
	self.successful_revives = 0;
	self.failed_revives = 0;
	self.failed_cash_back_prones = 0;
	self.pers[ "last_headshot_kill_time" ] = getTime();
	self.pers[ "zombies_multikilled" ] = 0;
	self.non_headshot_kill_counter = 0;
	if ( is_true( level.pers_upgrade_box_weapon ) )
	{
		self.pers_box_weapon_awarded = undefined;
	}
	if ( is_true( level.pers_upgrade_nube ) )
	{
		self thread pers_nube_unlock_watcher();
	}
}

is_pers_system_active() //checked matches cerberus output
{
	if ( !is_classic() )
	{
		return 0;
	}
	if ( is_pers_system_disabled() )
	{
		return 0;
	}
	return 1;
}

is_pers_system_disabled() //checked matches cerberus output
{
	if ( level flag_exists( "sq_minigame_active" ) && flag( "sq_minigame_active" ) )
	{
		return 1;
	}
	return 0;
}

setup_pers_upgrade_boards() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_boards ) )
	{
		level.pers_boarding_round_start = 10;
		level.pers_boarding_number_of_boards_required = 74;
		pers_register_upgrade( "board", ::pers_upgrade_boards_active, "pers_boarding", level.pers_boarding_number_of_boards_required, 0 );
	}
}

setup_pers_upgrade_revive() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_revive ) )
	{
		level.pers_revivenoperk_number_of_revives_required = 17;
		level.pers_revivenoperk_number_of_chances_to_keep = 1;
		pers_register_upgrade( "revive", ::pers_upgrade_revive_active, "pers_revivenoperk", level.pers_revivenoperk_number_of_revives_required, 1 );
	}
}

setup_pers_upgrade_multi_kill_headshots() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_multi_kill_headshots ) )
	{
		level.pers_multikill_headshots_required = 5;
		level.pers_multikill_headshots_upgrade_reset_counter = 25;
		pers_register_upgrade( "multikill_headshots", ::pers_upgrade_headshot_active, "pers_multikill_headshots", level.pers_multikill_headshots_required, 0 );
	}
}

setup_pers_upgrade_cash_back() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_cash_back ) )
	{
		level.pers_cash_back_num_perks_required = 50;
		level.pers_cash_back_perk_buys_prone_required = 15;
		level.pers_cash_back_failed_prones = 1;
		level.pers_cash_back_money_reward = 1000;
		pers_register_upgrade( "cash_back", ::pers_upgrade_cash_back_active, "pers_cash_back_bought", level.pers_cash_back_num_perks_required, 0 );
		add_pers_upgrade_stat( "cash_back", "pers_cash_back_prone", level.pers_cash_back_perk_buys_prone_required );
	}
}

setup_pers_upgrade_insta_kill() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_insta_kill ) )
	{
		level.pers_insta_kill_num_required = 2;
		level.pers_insta_kill_upgrade_active_time = 18;
		pers_register_upgrade( "insta_kill", ::pers_upgrade_insta_kill_active, "pers_insta_kill", level.pers_insta_kill_num_required, 0 );
	}
}

setup_pers_upgrade_jugg() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_jugg ) )
	{
		level.pers_jugg_hit_and_die_total = 3;
		level.pers_jugg_hit_and_die_round_limit = 2;
		level.pers_jugg_round_reached_max = 1;
		level.pers_jugg_round_lose_target = 15;
		level.pers_jugg_upgrade_health_bonus = 90;
		pers_register_upgrade( "jugg", ::pers_upgrade_jugg_active, "pers_jugg", level.pers_jugg_hit_and_die_total, 0 );
	}
}

setup_pers_upgrade_carpenter() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_carpenter ) )
	{
		level.pers_carpenter_zombie_kills = 1;
		pers_register_upgrade( "carpenter", ::pers_upgrade_carpenter_active, "pers_carpenter", level.pers_carpenter_zombie_kills, 0 );
	}
}

setup_pers_upgrade_flopper() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_flopper ) )
	{
		level.pers_flopper_damage_counter = 6;
		level.pers_flopper_counter = 1;
		level.pers_flopper_min_fall_damage_activate = 30;
		level.pers_flopper_min_fall_damage_deactivate = 50;
		pers_register_upgrade( "flopper", ::pers_upgrade_flopper_active, "pers_flopper_counter", level.pers_flopper_counter, 0 );
	}
}

setup_pers_upgrade_perk_lose() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_perk_lose ) )
	{
		level.pers_perk_round_reached_max = 6;
		level.pers_perk_lose_counter = 3;
		pers_register_upgrade( "perk_lose", ::pers_upgrade_perk_lose_active, "pers_perk_lose_counter", level.pers_perk_lose_counter, 0 );
	}
}

setup_pers_upgrade_pistol_points() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_pistol_points ) )
	{
		level.pers_pistol_points_num_kills_in_game = 8;
		level.pers_pistol_points_accuracy = 0.25;
		level.pers_pistol_points_counter = 1;
		pers_register_upgrade( "pistol_points", ::pers_upgrade_pistol_points_active, "pers_pistol_points_counter", level.pers_pistol_points_counter, 0 );
	}
}

setup_pers_upgrade_double_points() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_double_points ) )
	{
		level.pers_double_points_score = 2500;
		level.pers_double_points_counter = 1;
		pers_register_upgrade( "double_points", ::pers_upgrade_double_points_active, "pers_double_points_counter", level.pers_double_points_counter, 0 );
	}
}

setup_pers_upgrade_sniper() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_sniper ) )
	{
		level.pers_sniper_round_kills_counter = 5;
		level.pers_sniper_kill_distance = 800;
		level.pers_sniper_counter = 1;
		level.pers_sniper_misses = 3;
		pers_register_upgrade( "sniper", ::pers_upgrade_sniper_active, "pers_sniper_counter", level.pers_sniper_counter, 0 );
	}
}

setup_pers_upgrade_box_weapon() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_box_weapon ) )
	{
		level.pers_box_weapon_counter = 5;
		level.pers_box_weapon_lose_round = 10;
		pers_register_upgrade( "box_weapon", ::pers_upgrade_box_weapon_active, "pers_box_weapon_counter", level.pers_box_weapon_counter, 0 );
	}
}

setup_pers_upgrade_nube() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_nube ) )
	{
		level.pers_nube_counter = 1;
		level.pers_nube_lose_round = 10;
		level.pers_numb_num_kills_unlock = 5;
		pers_register_upgrade( "nube", ::pers_upgrade_nube_active, "pers_nube_counter", level.pers_nube_counter, 0 );
	}
}

pers_upgrade_boards_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	last_round_number = level.round_number;
	while ( 1 )
	{
		self waittill( "pers_stats_end_of_round" );
		if ( level.round_number >= last_round_number )
		{
			if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
			{
				if ( self.rebuild_barrier_reward == 0 )
				{
					self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_boarding", 0 );
					return;
				}
			}
		}
		last_round_number = level.round_number;
	}
}

pers_upgrade_revive_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "player_failed_revive" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( self.failed_revives >= level.pers_revivenoperk_number_of_chances_to_keep )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_revivenoperk", 0 );
				self.failed_revives = 0;
				return;
			}
		}
	}
}

pers_upgrade_headshot_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "zombie_death_no_headshot" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			self.non_headshot_kill_counter++;
			if ( self.non_headshot_kill_counter >= level.pers_multikill_headshots_upgrade_reset_counter )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_multikill_headshots", 0 );
				self.non_headshot_kill_counter = 0;
				return;
			}
		}
	}
}

pers_upgrade_cash_back_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait 0.5;

	wait 0.5;
	while ( 1 )
	{
		self waittill( "cash_back_failed_prone" );
		wait 0.1;
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			self.failed_cash_back_prones++;
			if ( self.failed_cash_back_prones >= level.pers_cash_back_failed_prones )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_cash_back_bought", 0 );
				self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_cash_back_prone", 0 );
				self.failed_cash_back_prones = 0;
				wait 0.4;
				return;
			}
		}
	}
}

pers_upgrade_insta_kill_active() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	wait 0.2;
	wait 0.2;
	while ( 1 )
	{
		self waittill( "pers_melee_swipe" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( isDefined( level.pers_melee_swipe_zombie_swiper ) )
			{
				e_zombie = level.pers_melee_swipe_zombie_swiper;
				if ( isalive( e_zombie ) && is_true( e_zombie.is_zombie ) )
				{
					e_zombie.marked_for_insta_upgraded_death = 1;
					e_zombie dodamage( e_zombie.health + 666, e_zombie.origin, self, self, "none", "MOD_PISTOL_BULLET", 0, "knife_zm" );
				}
				level.pers_melee_swipe_zombie_swiper = undefined;
			}
			break;
		}
	}
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_insta_kill", 0 );
	self kill_insta_kill_upgrade_hud_icon();
	wait 0.4;
}

is_insta_kill_upgraded_and_active() //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( self maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
		{
			if ( is_true( self.pers_upgrades_awarded[ "insta_kill" ] ) )
			{
				return 1;
			}
		}
	}
	return 0;
}

pers_upgrade_jugg_active() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	wait 0.5;

	wait 0.5;
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "jugg_upgrade", 1, 0 );
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( level.round_number == level.pers_jugg_round_lose_target )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_jugg_downgrade_count", 0 );
				wait 0.5;
				if ( self.pers[ "pers_jugg_downgrade_count" ] >= level.pers_jugg_round_reached_max )
				{
					break;
				}
			}
		}
	}
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "jugg_upgrade", 1, 1 );
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_jugg", 0 );
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_jugg_downgrade_count", 0 );
}

pers_upgrade_carpenter_active() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	wait 0.2;
	wait 0.2;
	level waittill( "carpenter_finished" );
	self.pers_carpenter_kill = undefined;
	while ( 1 )
	{
		self waittill( "carpenter_zombie_killed_check_finished" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( !isDefined( self.pers_carpenter_kill ) )
			{
				break;
			}
		}
		self.pers_carpenter_kill = undefined;
	}
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_carpenter", 0 );
	wait 0.4;
}

persistent_carpenter_ability_check() //checked changed to match cerberus output
{
	if ( is_true( level.pers_upgrade_carpenter ) )
	{
		self endon( "disconnect" );
		if ( is_true( self.pers_upgrades_awarded[ "carpenter" ] ) )
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
			if ( !is_pers_system_disabled() )
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
					if ( is_true( self.pers_upgrades_awarded[ "carpenter" ] ) )
					{
						break;
					}
					else
					{
						self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_carpenter", 0 );
					}
				}
			}
			wait 0.05;
		}
		self notify( "carpenter_zombie_killed_check_finished" );
		self.pers_carpenter_zombie_check_active = undefined;
		level.pers_carpenter_boards_active = undefined;
	}
}

pers_zombie_death_location_check( attacker, v_pos ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
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

insta_kill_pers_upgrade_icon() //checked matches cerberus output
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

time_remaining_pers_upgrade() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "kill_insta_kill_upgrade_hud_icon" );
	while ( self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] >= 0 )
	{
		wait 0.05;
		self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] -= 0.05;
	}
	self kill_insta_kill_upgrade_hud_icon();
}

kill_insta_kill_upgrade_hud_icon() //checked matches cerberus output
{
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_on" ] = 0;
	self._show_solo_hud = 0;
	self.zombie_vars[ "zombie_powerup_insta_kill_ug_time" ] = level.pers_insta_kill_upgrade_active_time;
	self notify( "kill_insta_kill_upgrade_hud_icon" );
}

pers_upgrade_flopper_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT FLOPPER UPGRADED ***" );
#/
	*/
	wait 0.5;
	self thread maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_flopper_watcher();
	self waittill( "pers_flopper_lost" );
	/*
/#
	iprintlnbold( "*** OH NO: Lost FLOPPER Upgrade ***" );
#/	
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_flopper_counter", 0 );
	self.pers_num_flopper_damages = 0;
}

pers_upgrade_perk_lose_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT PERK LOSE UPGRADED ***" );
#/
	*/
	wait 0.5;
	self.pers_perk_lose_start_round = level.round_number;
	self waittill( "pers_perk_lose_lost" );
	/*
/#
	iprintlnbold( "*** OH NO: Lost PERK LOSE Upgrade ***" );
#/
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_perk_lose_counter", 0 );
}

pers_upgrade_pistol_points_active() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT PISTOL POINTS UPGRADED ***" );
#/
	*/
	wait 0.5;
	while ( 1 )
	{
		self waittill( "pers_pistol_points_kill" );
		accuracy = self maps/mp/zombies/_zm_pers_upgrades_functions::pers_get_player_accuracy();
		if ( accuracy > level.pers_pistol_points_accuracy )
		{
			break;
		}
	}
	/*
/#
	iprintlnbold( "*** OH NO: Lost PISTOL POINTS Upgrade ***" );
#/
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_pistol_points_counter", 0 );
}

pers_upgrade_double_points_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT DOUBLE POINTS UPGRADED ***" );
#/
	*/
	wait 0.5;
	self waittill( "double_points_lost" );
	/*
/#
	iprintlnbold( "*** OH NO: Lost DOUBLE POINTS Upgrade ***" );
#/
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_double_points_counter", 0 );
}

pers_upgrade_sniper_active() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT SNIPER UPGRADED ***" );
#/
	*/
	wait 0.5;
	self waittill( "pers_sniper_lost" );
	/*
/#
	iprintlnbold( "*** OH NO: Lost SNIPER Upgrade ***" );
#/
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_sniper_counter", 0 );
}

pers_upgrade_box_weapon_active() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT BOX WEAPON UPGRADED ***" );
#/
	*/
	self thread maps/mp/zombies/_zm_pers_upgrades_functions::pers_magic_box_teddy_bear();
	wait 0.5;
	self.pers_box_weapon_awarded = 1;
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( level.round_number >= level.pers_box_weapon_lose_round )
			{
				break;
			}
		}
	}
	/*
/#
	iprintlnbold( "*** OH NO: Lost BOX WEAPON Upgrade ***" );
#/
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_box_weapon_counter", 0 );
}

pers_upgrade_nube_active() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	wait 0.5;
	/*
/#
	iprintlnbold( "*** WE'VE GOT NUBE UPGRADED ***" );
#/
	*/
	wait 0.5;
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( level.round_number >= level.pers_nube_lose_round )
			{
				break;
			}
		}
	}
	/*
/#
	iprintlnbold( "*** OH NO: Lost NUBE Upgrade ***" );
#/
	*/
	self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_nube_counter", 0 );
}


