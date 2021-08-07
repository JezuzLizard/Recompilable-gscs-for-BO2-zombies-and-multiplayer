#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

pers_boards_updated( zbarrier ) //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_boards ) )
	{
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( !is_true( self.pers_upgrades_awarded[ "board" ] ) )
			{
				if ( level.round_number >= level.pers_boarding_round_start )
				{
					self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_boarding", 0 );
					if ( self.pers[ "pers_boarding" ] >= level.pers_boarding_number_of_boards_required )
					{
						if ( isDefined( zbarrier ) )
						{
							self.upgrade_fx_origin = zbarrier.origin;
						}
					}
				}
			}
		}
	}
}

pers_revive_active() //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( self.pers_upgrades_awarded[ "revive" ] ) )
		{
			return 1;
		}
	}
	return 0;
}

pers_increment_revive_stat( reviver ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		reviver maps/mp/zombies/_zm_stats::increment_client_stat( "pers_revivenoperk", 0 );
	}
}

pers_mulit_kill_headshot_active() //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( self.pers_upgrades_awarded[ "multikill_headshots" ] ) )
		{
			return 1;
		}
	}
	return 0;
}

pers_check_for_pers_headshot( time_of_death, zombie ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( self.pers[ "last_headshot_kill_time" ] == time_of_death )
		{
			self.pers[ "zombies_multikilled" ]++;
		}
		else
		{
			self.pers[ "zombies_multikilled" ] = 1;
		}
		self.pers[ "last_headshot_kill_time" ] = time_of_death;
		if ( self.pers[ "zombies_multikilled" ] == 2 )
		{
			if ( isDefined( zombie ) )
			{
				self.upgrade_fx_origin = zombie.origin;
			}
			self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_multikill_headshots", 0 );
			self.non_headshot_kill_counter = 0;
		}
	}
}

cash_back_player_drinks_perk() //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( level.pers_upgrade_cash_back ) )
		{
			if ( is_true self.pers_upgrades_awarded[ "cash_back" ] ) )
			{
				self thread cash_back_money_reward();
				self thread cash_back_player_prone_check( 1 );
			}
			else if ( self.pers[ "pers_cash_back_bought" ] < level.pers_cash_back_num_perks_required )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_cash_back_bought", 0 );
				return;
			}
			else
			{
				self thread cash_back_player_prone_check( 0 );
			}
		}
	}
}

cash_back_money_reward() //checked matches cerberus output
{
	self endon( "death" );
	step = 5;
	amount_per_step = int( level.pers_cash_back_money_reward / step );
	for ( i = 0; i < step; i++ )
	{
		self maps/mp/zombies/_zm_score::add_to_player_score( amount_per_step );
		wait 0.2;
	}
}

cash_back_player_prone_check( got_ability ) //checked changed to match cerberus output
{
	self endon( "death" );
	prone_time = 2.5;
	start_time = getTime();
	while ( 1 )
	{
		time = getTime();
		dt = ( time - start_time ) / 1000;
		if ( dt > prone_time )
		{
			break;
		}
		if ( self getstance() == "prone" )
		{
			if ( !got_ability )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_cash_back_prone", 0 );
				wait 0.8;
			}
			return;
		}
		wait 0.01;
	}
	if ( got_ability )
	{
		self notify( "cash_back_failed_prone" );
	}
}

pers_upgrade_insta_kill_upgrade_check() //checked changed to match cerberus output
{
	if ( is_true( level.pers_upgrade_insta_kill ) )
	{
		self endon( "death" );
		if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			return;
		}
		players = get_players();
		for ( i = 0; i < players.size; i++ )
		{
			e_player = players[ i ];
			if ( is_true( e_player.pers_upgrades_awarded[ "insta_kill" ] ) )
			{
				e_player thread insta_kill_upgraded_player_kill_func( level.pers_insta_kill_upgrade_active_time );
			}
		}
		if ( !is_true( self.pers_upgrades_awarded[ "insta_kill" ] ) )
		{
			kills_start = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "kills" );
			self waittill( "insta_kill_over" );
			kills_end = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "kills" );
			num_killed = kills_end - kills_start;
			if ( num_killed > 0 )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( "pers_insta_kill", 0 );
			}
			else
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_insta_kill", 0 );
			}
		}
	}
}

insta_kill_upgraded_player_kill_func( active_time ) //checked changed to match cerberus output
{
	self endon( "death" );
	wait 0.25;
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_disabled() )
	{
		return;
	}
	self thread maps/mp/zombies/_zm_pers_upgrades::insta_kill_pers_upgrade_icon();
	start_time = getTime();
	zombie_collide_radius = 50;
	zombie_player_height_test = 100;
	while ( 1 )
	{
		time = getTime();
		dt = ( time - start_time ) / 1000;
		if ( dt > active_time )
		{
			break;
		}
		if ( !maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
		{
			break;
		}
		a_zombies = getaiarray( level.zombie_team );
		e_closest = undefined;
		i = 0;
		while ( i < a_zombies.size )
		{
			e_zombie = a_zombies[ i ];
			if ( isDefined( e_zombie.marked_for_insta_upgraded_death ) )
			{
				i++;
				continue;
			}
			height_diff = abs( self.origin[ 2 ] - e_zombie.origin[ 2 ] );
			if ( height_diff < zombie_player_height_test )
			{
				dist = distance2d( self.origin, e_zombie.origin );
				if ( dist < zombie_collide_radius )
				{
					dist_max = dist;
					e_closest = e_zombie;
				}
			}
			i++;
		}
		if ( isDefined( e_closest ) )
		{
			e_closest.marked_for_insta_upgraded_death = 1;
			e_closest dodamage( e_closest.health + 666, e_closest.origin, self, self, "none", "MOD_PISTOL_BULLET", 0, "knife_zm" );
		}
		wait 0.01;
	}
}

pers_insta_kill_melee_swipe( smeansofdeath, eattacker ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( isDefined( smeansofdeath ) && smeansofdeath == "MOD_MELEE" )
		{
			if ( isplayer( self ) && maps/mp/zombies/_zm_pers_upgrades::is_insta_kill_upgraded_and_active() )
			{
				self notify( "pers_melee_swipe" );
				level.pers_melee_swipe_zombie_swiper = eattacker;
			}
		}
	}
}

pers_upgrade_jugg_player_death_stat() //checked matches cerberus output
{
	if ( is_true( level.pers_upgrade_jugg ) )
	{
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
		{
			if ( !is_true( self.pers_upgrades_awarded[ "jugg" ] ) )
			{
				if ( level.round_number <= level.pers_jugg_hit_and_die_round_limit )
				{
					self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_jugg", 0 );
				}
			}
		}
	}
}

pers_jugg_active() //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( self.pers_upgrades_awarded[ "jugg" ] ) )
		{
			return 1;
		}
	}
	return 0;
}

pers_upgrade_flopper_damage_check( smeansofdeath, idamage ) //checked changed to match cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return 0;
	}
	if ( !isDefined( smeansofdeath ) || smeansofdeath != "MOD_FALLING" )
	{
		return 0;
	}
	if ( !is_true( self.pers_upgrades_awarded[ "flopper" ] ) )
	{
		if ( idamage < level.pers_flopper_min_fall_damage_activate )
		{
			return 0;
		}
		if ( !isDefined( self.pers_num_flopper_damages ) )
		{
			self.pers_num_flopper_damages = 0;
		}
		self.pers_num_flopper_damages++;
		if ( self.pers_num_flopper_damages >= level.pers_flopper_damage_counter )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_flopper_counter", 0 );
			/*
/#
			iprintlnbold( "FLOPPER STAT: INCREMENTED" );
#/
			*/
		}
	}
	else if ( !is_true( self.pers_flopper_active ) )
	{
		if ( idamage >= level.pers_flopper_min_fall_damage_deactivate )
		{
			self notify( "pers_flopper_lost" );
		}
		return 0;
	}
	if ( idamage > 0 )
	{
		self notify( "activate_pers_flopper_effect" );
		return 1;
	}
	return 0;
}

divetonuke_precache_override_func() //checked matches cerberus output
{
	precacheshader( "specialty_divetonuke_zombies" );
	level._effect[ "divetonuke_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
}

pers_upgrade_flopper_watcher() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "pers_flopper_lost" );
	while ( 1 )
	{
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_disabled() )
		{
			wait 0.01;
		}
		else
		{
			self waittill( "dtp_start" );
			self.pers_flopper_active = 1;
			self thread pers_flopper_dtn();
			self waittill( "dtp_end" );
			self.pers_flopper_active = undefined;
		}
	}
}

pers_flopper_dtn() //checked matches cerberus output
{
	self endon( "disconnect" );
	self waittill( "activate_pers_flopper_effect" );
	if ( isDefined( level.pers_flopper_divetonuke_func ) )
	{
		self thread [[ level.pers_flopper_divetonuke_func ]]( self, self.origin );
	}
}

pers_flopper_explode( attacker, origin ) //checked matches cerberus output
{
	self endon( "disconnect" );
	radius = level.zombie_vars[ "zombie_perk_divetonuke_radius" ];
	min_damage = level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ];
	max_damage = level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ];
	if ( is_true( level.pers_flopper_network_optimized ) )
	{
		attacker thread pers_flopper_damage_network_optimized( origin, radius, max_damage, min_damage, "MOD_GRENADE_SPLASH" );
	}
	else
	{
		radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	}
	attacker setclientfield( "phd_flopper_effects", 1 );
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_perk_divetonuke", attacker );
	wait 1;
	maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_perk_divetonuke", attacker );
	attacker setclientfield( "phd_flopper_effects", 0 );
}

pers_flopper_damage_network_optimized( origin, radius, max_damage, min_damage, damage_mod ) //checked partially changed to match cerberus output //for loops don't work with continues used while loop
{
	self endon( "disconnect" );
	a_zombies = get_array_of_closest( origin, get_round_enemy_array(), undefined, undefined, radius );
	network_stall_counter = 0;
	if ( isDefined( a_zombies ) )
	{
		i = 0;
		while ( i < a_zombies.size )
		{
			e_zombie = a_zombies[ i ];
			if ( !isDefined( e_zombie ) || !isalive( e_zombie ) )
			{
				i++;
				continue;
			}
			dist = distance( e_zombie.origin, origin );
			damage = min_damage + ( ( max_damage - min_damage ) * ( 1 - ( dist / radius ) ) );
			e_zombie dodamage( damage, e_zombie.origin, self, self, 0, damage_mod );
			network_stall_counter--;
			if ( network_stall_counter <= 0 )
			{
				wait_network_frame();
				network_stall_counter = randomintrange( 1, 3 );
			}
			i++;
		}
	}
}

pers_upgrade_pistol_points_kill() //checked matches cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	if ( !isDefined( self.pers_num_zombies_killed_in_game ) )
	{
		self.pers_num_zombies_killed_in_game = 0;
	}
	self.pers_num_zombies_killed_in_game++;
	if ( !is_true( self.pers_upgrades_awarded[ "pistol_points" ] ) )
	{
		if ( self.pers_num_zombies_killed_in_game >= level.pers_pistol_points_num_kills_in_game )
		{
			accuracy = self pers_get_player_accuracy();
			if ( accuracy <= level.pers_pistol_points_accuracy )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_pistol_points_counter", 0 );
				/*
/#
				iprintlnbold( "PISTOL POINTS STAT: INCREMENTED" );
#/
				*/
			}
		}
	}
	else
	{
		self notify( "pers_pistol_points_kill" );
	}
}

pers_upgrade_pistol_points_set_score( score, event, mod, damage_weapon ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( self.pers_upgrades_awarded[ "pistol_points" ] ) )
		{
			if ( isDefined( event ) )
			{
				if ( event == "rebuild_board" )
				{
					return score;
				}
				if ( isDefined( damage_weapon ) )
				{
					weapon_class = getweaponclasszm( damage_weapon );
					if ( weapon_class != "weapon_pistol" )
					{
						return score;
					}
				}
				if ( isDefined( mod ) && isstring( mod ) && mod == "MOD_PISTOL_BULLET" )
				{
					score *= 2;
				}
			}
		}
	}
	return score;
}

pers_upgrade_double_points_pickup_start() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	if ( is_true( self.double_points_ability_check_active ) )
	{
		self.double_points_ability_start_time = getTime();
		return;
	}
	self.double_points_ability_check_active = 1;
	level.pers_double_points_active = 1;
	start_points = self.score;
	if ( isDefined( self.account_value ) )
	{
		bank_account_value_start = self.account_value;
	}
	else
	{
		bank_account_value_start = 0;
	}
	self.double_points_ability_start_time = getTime();
	last_score = self.score;
	ability_lost = 0;
	while ( 1 )
	{
		if ( self.score > last_score )
		{
			ability_lost = 1;
		}
		last_score = self.score;
		time = getTime();
		dt = time - self.double_points_ability_start_time / 1000;
		if ( dt >= 30 )
		{
			break;
		}
		wait 0.1;
	}
	level.pers_double_points_active = undefined;
	if ( isDefined( self.account_value ) )
	{
		bank_account_value_end = self.account_value;
	}
	else
	{
		bank_account_value_end = 0;
	}
	if ( bank_account_value_end < bank_account_value_start )
	{
		withdrawal_number = bank_account_value_start - bank_account_value_end;
		withdrawal_fees = level.ta_vaultfee * withdrawal_number;
		withdrawal_amount = level.bank_deposit_ddl_increment_amount * withdrawal_number;
		bank_withdrawal_total = withdrawal_amount - withdrawal_fees;
	}
	else
	{
		bank_withdrawal_total = 0;
	}
	if ( is_true( self.pers_upgrades_awarded[ "double_points" ] ) )
	{
		if ( ability_lost == 1 )
		{
			self notify( "double_points_lost" );
		}
	}
	else
	{
		total_points = self.score - start_points;
		total_points -= bank_withdrawal_total;
		if ( total_points >= level.pers_double_points_score )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_double_points_counter", 0 );
			/*
/#
			iprintlnbold( "PISTOL POINTS STAT: INCREMENTED" );
#/
			*/
		}
	}
	self.double_points_ability_check_active = undefined;
}

pers_upgrade_double_points_set_score( score ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( self.pers_upgrades_awarded[ "double_points" ] ) )
		{
			if ( is_true( level.pers_double_points_active ) )
			{
				score = int( score * 0.5 );
			}
		}
	}
	return score;
}

pers_upgrade_double_points_cost( current_cost ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( is_true( self.pers_upgrades_awarded[ "double_points" ] ) )
		{
			current_cost = int( current_cost / 2 );
		}
	}
	return current_cost;
}

is_pers_double_points_active() //checked matches cerberus output
{
	if ( is_true( self.pers_upgrades_awarded[ "double_points" ] ) )
	{
		if ( is_true( level.pers_double_points_active ) )
		{
			return 1;
		}
	}
	return 0;
}

pers_upgrade_perk_lose_bought() //checked changed to match cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	wait 1;
	if ( !is_true( self.pers_upgrades_awarded[ "perk_lose" ] ) )
	{
		if ( level.round_number <= level.pers_perk_round_reached_max )
		{
			if ( !isDefined( self.bought_all_perks ) )
			{
				a_perks = self get_perk_array( 0 );
				if ( isDefined( a_perks ) && a_perks.size == 4 )
				{
					self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_perk_lose_counter", 0 );
					/*
/#
					iprintlnbold( "PERK LOSE STAT: INCREMENTED" );
#/
					*/
					self.bought_all_perks = 1;
				}
			}
		}
	}
	else if ( isDefined( self.pers_perk_lose_start_round ) )
	{
		if ( level.round_number > 1 && self.pers_perk_lose_start_round == level.round_number )
		{
			self notify( "pers_perk_lose_lost" );
		}
	}
}

pers_upgrade_perk_lose_save() //checked changed to match cerberus output
{
	while ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( isDefined( self.perks_active ) )
		{
			self.a_saved_perks = [];
			self.a_saved_perks = arraycopy( self.perks_active );
		}
		else
		{
			self.a_saved_perks = self get_perk_array( 0 );
		}
		self.a_saved_primaries = self getweaponslistprimaries();
		self.a_saved_primaries_weapons = [];
		index = 0;
		foreach ( weapon in self.a_saved_primaries )
		{
			self.a_saved_primaries_weapons[ index ] = maps/mp/zombies/_zm_weapons::get_player_weapondata( self, weapon );
			index++;
		}
	}
}

pers_upgrade_perk_lose_restore() //checked changed to match cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		player_has_mule_kick = 0;
		discard_quickrevive = 0;
		if ( isDefined( self.a_saved_perks ) && self.a_saved_perks.size >= 2 )
		{
			for ( i = 0; i < self.a_saved_perks.size; i++ )
			{
				perk = self.a_saved_perks[ i ];
				if ( perk == "specialty_quickrevive" )
				{
					discard_quickrevive = 1;
				}
			}
			if ( discard_quickrevive == 1 )
			{
				size = self.a_saved_perks.size;
			}
			else
			{
				size = self.a_saved_perks.size - 1;
			}
			i = 0;
			while ( i < size )
			{
				perk = self.a_saved_perks[ i ];
				if ( discard_quickrevive == 1 && perk == "specialty_quickrevive" )
				{
					i++;
					continue;
				}
				if ( perk == "specialty_additionalprimaryweapon" )
				{
					player_has_mule_kick = 1;
				}
				if ( self hasperk( perk ) )
				{
					i++;
					continue;
				}
				self maps/mp/zombies/_zm_perks::give_perk( perk );
				wait_network_frame();
				i++;
			}
		}
		else if ( player_has_mule_kick )
		{
			a_current_weapons = self getweaponslistprimaries();
			for ( i = 0; i < self.a_saved_primaries_weapons.size; i++ )
			{
				saved_weapon = self.a_saved_primaries_weapons[ i ];
				found = 0;
				for ( j = 0; j < a_current_weapons.size; j++ )
				{
					current_weapon = a_current_weapons[ j ];
					if ( current_weapon == saved_weapon[ "name" ] )
					{
						found = 1;
						break;
					}
				}
				if ( found == 0 )
				{
					self maps/mp/zombies/_zm_weapons::weapondata_give( self.a_saved_primaries_weapons[ i ] );
					self switchtoweapon( a_current_weapons[ 0 ] );
					break;
				}
			}
		}
		self.a_saved_perks = undefined;
		self.a_saved_primaries = undefined;
		self.a_saved_primaries_weapons = undefined;
	}
}

pers_upgrade_sniper_kill_check( zombie, attacker ) //checked changed to match cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	if ( !isDefined( zombie ) || !isDefined( attacker ) || !isDefined( zombie.damageweapon ) )
	{
		return;
	}
	if ( is_true( zombie.marked_for_insta_upgraded_death ) )
	{
		return;
	}
	weapon = zombie.damageweapon;
	if ( !is_sniper_weapon( weapon ) )
	{
		return;
	}
	if ( is_true( self.pers_upgrades_awarded[ "sniper" ] ) )
	{
		self thread pers_sniper_score_reward();
	}
	else
	{
		dist = distance( zombie.origin, attacker.origin );
		if ( dist < level.pers_sniper_kill_distance )
		{
			return;
		}
		if ( !isDefined( self.pers_sniper_round ) )
		{
			self.pers_sniper_round = level.round_number;
			self.pers_sniper_kills = 0;
		}
		else if ( self.pers_sniper_round != level.round_number )
		{
			self.pers_sniper_round = level.round_number;
			self.pers_sniper_kills = 0;
		}
		self.pers_sniper_kills++;
		/*
/#
		iprintlnbold( "Pers: Long range Sniper Kill" );
#/
		*/
		if ( self.pers_sniper_kills >= level.pers_sniper_round_kills_counter )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_sniper_counter", 0 );
			/*
/#
			iprintlnbold( "SNIPER STAT: INCREMENTED" );
#/
			*/
		}
	}
}

pers_sniper_score_reward() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	while ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		total_score = 300;
		steps = 10;
		score_inc = int( total_score / steps );
		for ( i = 0; i < steps; i++ )
		{
			self maps/mp/zombies/_zm_score::add_to_player_score( score_inc );
			wait 0.25;
		}
	}
}

pers_sniper_player_fires( weapon, hit ) //checked changed to match cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	if ( isDefined( weapon ) && isDefined( hit ) )
	{
		if ( is_true( self.pers_upgrades_awarded[ "sniper" ] ) )
		{
			if ( is_sniper_weapon( weapon ) )
			{
				if ( !isDefined( self.num_sniper_misses ) )
				{
					self.num_sniper_misses = 0;
				}
				if ( hit )
				{
					self.num_sniper_misses = 0;
				}
				else
				{
					self.num_sniper_misses++;
					if ( self.num_sniper_misses >= level.pers_sniper_misses )
					{
						self notify( "pers_sniper_lost" );
						self.num_sniper_misses = 0;
					}
				}
			}
		}
	}
}

pers_get_player_accuracy() //checked matches cerberus output
{
	accuracy = 1;
	total_shots = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "total_shots" );
	total_hits = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "hits" );
	if ( total_shots > 0 )
	{
		accuracy = total_hits / total_shots;
	}
	return accuracy;
}

is_sniper_weapon( weapon ) //checked matches cerberus output
{
	if ( !isDefined( weapon ) )
	{
		return 0;
	}
	if ( !isstring( weapon ) )
	{
		return 0;
	}
	if ( getsubstr( weapon, 0, 4 ) == "svu_" )
	{
		return 1;
	}
	if ( getsubstr( weapon, 0, 6 ) == "dsr50_" )
	{
		return 1;
	}
	if ( getsubstr( weapon, 0, 10 ) == "barretm82_" )
	{
		return 1;
	}
	return 0;
}

pers_upgrade_box_weapon_used( e_user, e_grabber ) //checked changed to match cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	if ( level.round_number >= level.pers_box_weapon_lose_round )
	{
		return;
	}
	if ( isDefined( e_grabber ) && isplayer( e_grabber ) )
	{
		if ( is_true( e_grabber.pers_box_weapon_awarded ) )
		{
			return;
		}
		if ( is_true( e_grabber.pers_upgrades_awarded[ "box_weapon" ] ) )
		{
			return;
		}
		e_grabber maps/mp/zombies/_zm_stats::increment_client_stat( "pers_box_weapon_counter", 0 );
	}
	else if ( isDefined( e_user ) && isplayer( e_user ) )
	{
		if ( is_true( e_user.pers_upgrades_awarded[ "box_weapon" ] ) )
		{
			return;
		}
		e_user maps/mp/zombies/_zm_stats::zero_client_stat( "pers_box_weapon_counter", 0 );
	}
}

pers_magic_box_teddy_bear() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	if ( is_true( level.pers_magic_box_firesale ) )
	{
		self thread pers_magic_box_firesale();
	}
	m_bear = spawn( "script_model", self.origin );
	m_bear setmodel( level.chest_joker_model );
	m_bear pers_magic_box_set_teddy_location( level.chest_index );
	self.pers_magix_box_teddy_bear = m_bear;
	m_bear setinvisibletoall();
	wait 0.1;
	m_bear setvisibletoplayer( self );
	while ( 1 )
	{
		box = level.chests[ level.chest_index ];
		if ( level.round_number >= level.pers_box_weapon_lose_round )
		{
			break;
		}
		if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_disabled() )
		{
			m_bear setinvisibletoall();
			while ( 1 )
			{
				if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_disabled() )
				{
					break;
				}
				wait 0.01;
			}
			m_bear setvisibletoplayer( self );
		}
		if ( flag( "moving_chest_now" ) )
		{
			m_bear setinvisibletoall();
			while ( flag( "moving_chest_now" ) )
			{
				wait 0.1;
			}
			m_bear pers_magic_box_set_teddy_location( level.chest_index );
			wait 0.1;
			m_bear setvisibletoplayer( self );
		}
		if ( is_true( level.sloth_moving_box ) )
		{
			m_bear setinvisibletoall();
			while ( is_true( level.sloth_moving_box ) )
			{
				wait 0.1;
			}
			m_bear pers_magic_box_set_teddy_location( level.chest_index );
			wait 0.1;
			m_bear setvisibletoplayer( self );
		}
		if ( is_true( box._box_open ) )
		{
			m_bear setinvisibletoall();
			while ( 1 )
			{
				if ( !is_true( box._box_open ) )
				{
					break;
				}
				wait 0.01;
			}
			m_bear setvisibletoplayer( self );
		}
		wait 0.01;
	}
	m_bear delete();
}

pers_magic_box_set_teddy_location( box_index ) //checked changed to match cerberus output
{
	box = level.chests[ box_index ];
	if ( isDefined( box.zbarrier ) )
	{
		v_origin = box.zbarrier.origin;
		v_angles = box.zbarrier.angles;
	}
	else
	{
		v_origin = box.origin;
		v_angles = box.angles;
	}
	v_up = anglesToUp( v_angles );
	height_offset = 22;
	self.origin = v_origin + ( v_up * height_offset );
	dp = vectordot( v_up, ( 0, 0, 1 ) );
	if ( dp > 0 )
	{
		v_angles_offset = vectorScale( ( 0, 1, 0 ), 90 );
	}
	else
	{
		v_angles_offset = ( 0, -90, -10 );
	}
	self.angles = v_angles + v_angles_offset;
}

pers_treasure_chest_choosespecialweapon( player ) //checked changed to match cerberus output
{
	rval = randomfloat( 1 );
	if ( !isDefined( player.pers_magic_box_weapon_count ) )
	{
		player.pers_magic_box_weapon_count = 0;
	}
	if ( ( player.pers_magic_box_weapon_count == 0 || rval < 0.6 ) && player.pers_magic_box_weapon_count < 2 )
	{
		player.pers_magic_box_weapon_count++;
		if ( isDefined( level.pers_treasure_chest_get_weapons_array_func ) )
		{
			[[ level.pers_treasure_chest_get_weapons_array_func ]]();
		}
		else
		{
			pers_treasure_chest_get_weapons_array();
		}
		keys = array_randomize( level.pers_box_weapons );
		/*
/#
		forced_weapon = getDvar( "scr_force_weapon" );
		if ( forced_weapon != "" && isDefined( level.zombie_weapons[ forced_weapon ] ) )
		{
			arrayinsert( keys, forced_weapon, 0 );
#/
		}
		*/
		pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
		for ( i = 0; i < keys.size; i++ )
		{
			if ( maps/mp/zombies/_zm_magicbox::treasure_chest_canplayerreceiveweapon( player, keys[ i ], pap_triggers ) )
			{
				return keys[ i ];
			}
		}
		return keys[ 0 ];
	}
	else
	{
		player.pers_magic_box_weapon_count = 0;
		weapon = maps/mp/zombies/_zm_magicbox::treasure_chest_chooseweightedrandomweapon( player );
		return weapon;
	}
}

pers_treasure_chest_get_weapons_array() //checked matches cerberus output
{
	if ( !isDefined( level.pers_box_weapons ) )
	{
		level.pers_box_weapons = [];
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "ray_gun_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "galil_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "knife_ballistic_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "srm1216_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "hamr_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "tar21_zm";
		level.pers_box_weapons[ level.pers_box_weapons.size ] = "raygun_mark2_zm";
	}
}

pers_magic_box_firesale() //checked partially changed to match cerberus output //for loop not changed because continues are broken in for loops while loops used instead
{
	self endon( "disconnect" );
	wait 1;
	while ( 1 )
	{
		while ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 1 )
		{
			wait 5;
			i = 0;
			while ( i < level.chests.size )
			{
				if ( i == level.chest_index )
				{
					i++;
					continue;
				}
				box = level.chests[ i ];
				self thread box_firesale_teddy_bear( box, i );
				i++;
			}
			while ( 1 )
			{
				if ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 0 )
				{
					break;
				}
				wait 0.01;
			}
		}
		if ( level.round_number >= level.pers_box_weapon_lose_round )
		{
			return;
		}
		wait 0.5;
	}
}

box_firesale_teddy_bear( box, box_index ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	m_bear = spawn( "script_model", self.origin );
	m_bear setmodel( level.chest_joker_model );
	m_bear pers_magic_box_set_teddy_location( box_index );
	m_bear setinvisibletoall();
	wait 0.1;
	m_bear setvisibletoplayer( self );
	while ( 1 )
	{
		if ( is_true( box._box_open ) )
		{
			m_bear setinvisibletoall();
			while ( 1 )
			{
				if ( !is_true( box._box_open ) )
				{
					break;
				}
				wait 0.01;
			}
			m_bear setvisibletoplayer( self );
		}
		if ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 0 )
		{
			break;
		}
		wait 0.01;
	}
	m_bear delete();
}

pers_nube_unlock_watcher() //checked  changed to match cerberus output
{
	self endon( "disconnect" );
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return;
	}
	self.pers_num_nube_kills = 0;
	if ( self.pers[ "pers_max_round_reached" ] >= level.pers_nube_lose_round )
	{
		return;
	}
	num_melee_kills = self.pers[ "melee_kills" ];
	num_headshot_kills = self.pers[ "headshots" ];
	num_boards = self.pers[ "boards" ];
	while ( 1 )
	{
		self waittill( "pers_player_zombie_kill" );
		if ( self.pers[ "pers_max_round_reached" ] >= level.pers_nube_lose_round )
		{
			self.pers_num_nube_kills = 0;
			return;
		}
		if ( num_melee_kills == self.pers[ "melee_kills" ] && num_headshot_kills == self.pers[ "headshots" ] && num_boards == self.pers[ "boards" ] )
		{
			self.pers_num_nube_kills++;
		}
		else
		{
			self.pers_num_nube_kills = 0;
			num_melee_kills = self.pers[ "melee_kills" ];
			num_headshot_kills = self.pers[ "headshots" ];
			num_boards = self.pers[ "boards" ];
		}
	}
}

pers_nube_player_ranked_as_nube( player ) //checked matches cerberus output
{
	if ( player.pers_num_nube_kills >= level.pers_numb_num_kills_unlock )
	{
		return 1;
	}
	return 0;
}

pers_nube_weapon_upgrade_check( player, str_weapon ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( getsubstr( str_weapon, 0, 11 ) == "rottweil72_" )
		{
			if ( !is_true( player.pers_upgrades_awarded[ "nube" ] ) )
			{
				if ( pers_nube_player_ranked_as_nube( player ) )
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "pers_nube_counter", 0 );
					str_weapon = "ray_gun_zm";
					fx_org = player.origin;
					v_dir = anglesToForward( player getplayerangles() );
					v_up = anglesToUp( player getplayerangles() );
					fx_org = ( fx_org + ( v_dir * 5 ) ) + v_up * 12;
					player.upgrade_fx_origin = fx_org;
				}
			}
			else
			{
				str_weapon = "ray_gun_zm";
			}
		}
	}
	return str_weapon;
}

pers_nube_weapon_ammo_check( player, str_weapon ) //checked matches cerberus output
{
	if ( maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		if ( getsubstr( str_weapon, 0, 11 ) == "rottweil72_" )
		{
			if ( is_true( player.pers_upgrades_awarded[ "nube" ] ) )
			{
				if ( player hasweapon( "ray_gun_zm" ) )
				{
					str_weapon = "ray_gun_zm";
				}
				if ( player hasweapon( "ray_gun_upgraded_zm" ) )
				{
					str_weapon = "ray_gun_upgraded_zm";
				}
			}
		}
	}
	return str_weapon;
}

pers_nube_should_we_give_raygun( player_has_weapon, player, weapon_buy ) //checked partially changed to match cerberus output //changed at own discretion
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return player_has_weapon;
	}
	if ( player.pers[ "pers_max_round_reached" ] >= level.pers_nube_lose_round )
	{
		return player_has_weapon;
	}
	if ( !pers_nube_player_ranked_as_nube( player ) )
	{
		return player_has_weapon;
	}
	if ( isDefined( weapon_buy ) && getsubstr( weapon_buy, 0, 11 ) != "rottweil72_" )
	{
		return player_has_weapon;
	}
	if ( player hasweapon( "rottweil72_zm" ) || player hasweapon( "rottweil72_upgraded_zm" ) )
	{
		player_has_olympia = 1;
	}
	if ( player hasweapon( "ray_gun_zm" ) || player hasweapon( "ray_gun_upgraded_zm" ) )
	{
		player_has_raygun = 1;
	}
	if ( player_has_olympia && player_has_raygun )
	{
		player_has_weapon = 1;
	}
	else if ( pers_nube_player_ranked_as_nube( player ) && player_has_olympia && player_has_raygun == 0 )
	{
		player_has_weapon = 0;
	}
	else if ( is_true( player.pers_upgrades_awarded[ "nube" ] ) && player_has_raygun )
	{
		player_has_weapon = 1;
	}
	return player_has_weapon;
}

pers_nube_ammo_hint_string( player, weapon ) //checked matches cerberus output
{
	ammo_cost = 0;
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return 0;
	}
	if ( getsubstr( weapon, 0, 11 ) == "rottweil72_" )
	{
		ammo_cost = pers_nube_ammo_cost( player, ammo_cost );
	}
	if ( !ammo_cost )
	{
		return 0;
	}
	self.stub.hint_string = &"ZOMBIE_WEAPONAMMOONLY";
	self sethintstring( self.stub.hint_string, ammo_cost );
	return 1;
}

pers_nube_ammo_cost( player, ammo_cost ) //checked matches cerberus output
{
	if ( player hasweapon( "ray_gun_zm" ) )
	{
		ammo_cost = 250;
	}
	if ( player hasweapon( "ray_gun_upgraded_zm" ) )
	{
		ammo_cost = 4500;
	}
	return ammo_cost;
}

pers_nube_override_ammo_cost( player, weapon, ammo_cost ) //checked matches cerberus output
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return ammo_cost;
	}
	if ( getsubstr( weapon, 0, 11 ) == "rottweil72_" )
	{
		ammo_cost = pers_nube_ammo_cost( player, ammo_cost );
	}
	return ammo_cost;
}



