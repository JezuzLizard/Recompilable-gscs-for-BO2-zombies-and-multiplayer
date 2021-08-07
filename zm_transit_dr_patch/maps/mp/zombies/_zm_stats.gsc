#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level.player_stats_init = ::player_stats_init;
	level.add_client_stat = ::add_client_stat;
	level.increment_client_stat = ::increment_client_stat;
	level.track_gibs = ::do_stats_for_gibs;
}

player_stats_init()
{
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "kills", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "suicides", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "downs", 0 );
	self.downs = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "downs" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "revives", 0 );
	self.revives = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "revives" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "perks_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "headshots", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "head_gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "right_arm_gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "left_arm_gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "right_leg_gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "left_leg_gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "melee_kills", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "grenade_kills", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "doors_purchased", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "distance_traveled", 0 );
	self.distance_traveled = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "distance_traveled" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "total_shots", 0 );
	self.total_shots = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "total_shots" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "hits", 0 );
	self.hits = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "hits" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "deaths", 0 );
	self.deaths = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "deaths" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "boards", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "wins", 0 );
	self.totalwins = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "totalwins" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "losses", 0 );
	self.totallosses = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "totallosses" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "failed_revives", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sacrifices", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "failed_sacrifices", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "drops", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "nuke_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "insta_kill_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "full_ammo_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "double_points_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "meat_stink_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "carpenter_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "fire_sale_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "use_magicbox", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "grabbed_from_magicbox", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "use_pap", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pap_weapon_grabbed", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pap_weapon_not_grabbed", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_armorvest_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_quickrevive_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_rof_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_fastreload_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_flakjacket_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_additionalprimaryweapon_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_longersprint_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_deadshot_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_scavenger_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_finalstand_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_grenadepulldeath_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "specialty_nomotionsensor" + "_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "claymores_planted", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "claymores_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "ballistic_knives_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "wallbuy_weapons_purchased", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "ammo_purchased", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "upgraded_ammo_purchased", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "power_turnedon", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "power_turnedoff", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "planted_buildables_pickedup", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "buildables_built", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "time_played_total", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "weighted_rounds_played", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "contaminations_received", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "contaminations_given", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zdogs_killed", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zdog_rounds_finished", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zdog_rounds_lost", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "killed_by_zdog", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "screecher_minigames_won", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "screecher_minigames_lost", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "screechers_killed", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "screecher_teleporters_used", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "avogadro_defeated", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "killed_by_avogadro", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "cheat_too_many_weapons", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "cheat_out_of_playable", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "cheat_too_friendly", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "cheat_total", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_boarding", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_revivenoperk", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_multikill_headshots", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_cash_back_bought", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_cash_back_prone", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_insta_kill", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_insta_kill_stabs", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_jugg", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_jugg_downgrade_count", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_carpenter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_carpenter_downgrade_count", 0, 1 );
	self.successful_revives = 0;
	self.failed_revives = 0;
	self.failed_cash_back_prones = 0;
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "score", 0 );
	if ( level.resetplayerscoreeveryround )
	{
		self.pers[ "score" ] = 0;
	}
	self.pers[ "score" ] = level.player_starting_points;
	self.score = self.pers[ "score" ];
	self incrementplayerstat( "score", self.score );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zteam", 0 );
	if ( isDefined( level.level_specific_stats_init ) )
	{
		[[ level.level_specific_stats_init ]]();
	}
	if ( !isDefined( self.stats_this_frame ) )
	{
		self.pers_upgrade_force_test = 1;
		self.stats_this_frame = [];
		self.pers_upgrades_awarded = [];
	}
	self.pers[ "last_headshot_kill_time" ] = getTime();
	self.pers[ "zombies_multikilled" ] = 0;
	self.non_headshot_kill_counter = 0;
}

update_players_stats_at_match_end( players )
{
	game_mode = getDvar( "ui_gametype" );
	game_mode_group = level.scr_zm_ui_gametype_group;
	map_location_name = level.scr_zm_map_start_location;
	if ( map_location_name == "" )
	{
		map_location_name = "default";
	}
	if ( isDefined( level.gamemodulewinningteam ) )
	{
		if ( level.gamemodulewinningteam == "B" )
		{
			matchrecorderincrementheaderstat( "winningTeam", 1 );
		}
		else
		{
			if ( level.gamemodulewinningteam == "A" )
			{
				matchrecorderincrementheaderstat( "winningTeam", 2 );
			}
		}
	}
	recordmatchsummaryzombieendgamedata( game_mode, game_mode_group, map_location_name, level.round_number );
	newtime = getTime();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( player is_bot() )
		{
			i++;
			continue;
		}
		else
		{
			distance = player get_stat_distance_traveled();
			player addplayerstatwithgametype( "distance_traveled", distance );
			player add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "time_played_total", player.pers[ "time_played_total" ] );
			recordplayermatchend( player );
			recordplayerstats( player, "presentAtEnd", 1 );
			player maps/mp/zombies/_zm_weapons::updateweapontimingszm( newtime );
			if ( isDefined( level._game_module_stat_update_func ) )
			{
				player [[ level._game_module_stat_update_func ]]();
			}
			old_high_score = player get_game_mode_stat( game_mode, "score" );
			if ( player.score_total > old_high_score )
			{
				player set_game_mode_stat( game_mode, "score", player.score_total );
			}
			if ( gamemodeismode( level.gamemode_public_match ) )
			{
				player gamehistoryfinishmatch( 4, 0, 0, 0, 0, 0 );
				if ( isDefined( player.pers[ "matchesPlayedStatsTracked" ] ) )
				{
					gamemode = maps/mp/gametypes_zm/_globallogic::getcurrentgamemode();
					player maps/mp/gametypes_zm/_globallogic::incrementmatchcompletionstat( gamemode, "played", "completed" );
					if ( isDefined( player.pers[ "matchesHostedStatsTracked" ] ) )
					{
						player maps/mp/gametypes_zm/_globallogic::incrementmatchcompletionstat( gamemode, "hosted", "completed" );
					}
				}
			}
			if ( !isDefined( player.pers[ "previous_distance_traveled" ] ) )
			{
				player.pers[ "previous_distance_traveled" ] = 0;
			}
			distancethisround = int( player.pers[ "distance_traveled" ] - player.pers[ "previous_distance_traveled" ] );
			player.pers[ "previous_distance_traveled" ] = player.pers[ "distance_traveled" ];
			player incrementplayerstat( "distance_traveled", distancethisround );
		}
		i++;
	}
}

update_playing_utc_time( matchendutctime )
{
	current_days = int( matchendutctime / 86400 );
	last_days = self get_global_stat( "TIMESTAMPLASTDAY1" );
	last_days = int( last_days / 86400 );
	diff_days = current_days - last_days;
	timestamp_name = "";
	if ( diff_days > 0 )
	{
		i = 5;
		while ( i > diff_days )
		{
			timestamp_name = "TIMESTAMPLASTDAY" + ( i - diff_days );
			timestamp_name_to = "TIMESTAMPLASTDAY" + i;
			timestamp_value = self get_global_stat( timestamp_name );
			self set_global_stat( timestamp_name_to, timestamp_value );
			i--;

		}
		i = 2;
		while ( i <= diff_days && i < 6 )
		{
			timestamp_name = "TIMESTAMPLASTDAY" + i;
			self set_global_stat( timestamp_name, 0 );
			i++;
		}
		self set_global_stat( "TIMESTAMPLASTDAY1", matchendutctime );
	}
}

survival_classic_custom_stat_update()
{
}

grief_custom_stat_update()
{
}

add_game_mode_group_stat( game_mode, stat_name, value )
{
	self adddstat( "PlayerStatsByGameTypeGroup", game_mode, stat_name, "statValue", value );
}

set_game_mode_group_stat( game_mode, stat_name, value )
{
	self setdstat( "PlayerStatsByGameTypeGroup", game_mode, stat_name, "statValue", value );
}

get_game_mode_group_stat( game_mode, stat_name )
{
	return self getdstat( "PlayerStatsByGameTypeGroup", game_mode, stat_name, "statValue" );
}

add_game_mode_stat( game_mode, stat_name, value )
{
	self adddstat( "PlayerStatsByGameType", game_mode, stat_name, "statValue", value );
}

set_game_mode_stat( game_mode, stat_name, value )
{
	self setdstat( "PlayerStatsByGameType", game_mode, stat_name, "statValue", value );
}

get_game_mode_stat( game_mode, stat_name )
{
	return self getdstat( "PlayerStatsByGameType", game_mode, stat_name, "statValue" );
}

get_global_stat( stat_name )
{
	return self getdstat( "PlayerStatsList", stat_name, "StatValue" );
}

set_global_stat( stat_name, value )
{
	self setdstat( "PlayerStatsList", stat_name, "StatValue", value );
}

add_global_stat( stat_name, value )
{
	self adddstat( "PlayerStatsList", stat_name, "StatValue", value );
}

get_map_stat( stat_name )
{
	return self getdstat( "PlayerStatsByMap", level.script, stat_name );
}

set_map_stat( stat_name, value )
{
	self setdstat( "PlayerStatsByMap", level.script, stat_name, value );
}

add_map_stat( stat_name, value )
{
	self adddstat( "PlayerStatsByMap", level.script, stat_name, value );
}

get_location_gametype_stat( start_location, game_type, stat_name )
{
	return self getdstat( "PlayerStatsByStartLocation", start_location, "startLocationGameTypeStats", game_type, "stats", stat_name, "StatValue" );
}

set_location_gametype_stat( start_location, game_type, stat_name, value )
{
	self setdstat( "PlayerStatsByStartLocation", start_location, "startLocationGameTypeStats", game_type, "stats", stat_name, "StatValue", value );
}

add_location_gametype_stat( start_location, game_type, stat_name, value )
{
	self adddstat( "PlayerStatsByStartLocation", start_location, "startLocationGameTypeStats", game_type, "stats", stat_name, "StatValue", value );
}

get_map_weaponlocker_stat( stat_name )
{
	return self getdstat( "PlayerStatsByMap", level.script, "weaponLocker", stat_name );
}

set_map_weaponlocker_stat( stat_name, value )
{
	if ( isDefined( value ) )
	{
		self setdstat( "PlayerStatsByMap", level.script, "weaponLocker", stat_name, value );
	}
	else
	{
		self setdstat( "PlayerStatsByMap", level.script, "weaponLocker", stat_name, 0 );
	}
}

add_map_weaponlocker_stat( stat_name, value )
{
	self adddstat( "PlayerStatsByMap", level.script, "weaponLocker", stat_name, value );
}

has_stored_weapondata()
{
	storedweapon = self get_map_weaponlocker_stat( "name" );
	if ( isDefined( storedweapon ) && isstring( storedweapon ) || storedweapon == "" && isint( storedweapon ) && storedweapon == 0 )
	{
		return 0;
	}
	return 1;
}

get_stored_weapondata()
{
	if ( self has_stored_weapondata() )
	{
		weapondata = [];
		weapondata[ "name" ] = self get_map_weaponlocker_stat( "name" );
		weapondata[ "lh_clip" ] = self get_map_weaponlocker_stat( "lh_clip" );
		weapondata[ "clip" ] = self get_map_weaponlocker_stat( "clip" );
		weapondata[ "stock" ] = self get_map_weaponlocker_stat( "stock" );
		weapondata[ "alt_clip" ] = self get_map_weaponlocker_stat( "alt_clip" );
		weapondata[ "alt_stock" ] = self get_map_weaponlocker_stat( "alt_stock" );
		return weapondata;
	}
	return undefined;
}

clear_stored_weapondata()
{
	self set_map_weaponlocker_stat( "name", "" );
	self set_map_weaponlocker_stat( "lh_clip", 0 );
	self set_map_weaponlocker_stat( "clip", 0 );
	self set_map_weaponlocker_stat( "stock", 0 );
	self set_map_weaponlocker_stat( "alt_clip", 0 );
	self set_map_weaponlocker_stat( "alt_stock", 0 );
}

set_stored_weapondata( weapondata )
{
	self set_map_weaponlocker_stat( "name", weapondata[ "name" ] );
	self set_map_weaponlocker_stat( "lh_clip", weapondata[ "lh_clip" ] );
	self set_map_weaponlocker_stat( "clip", weapondata[ "clip" ] );
	self set_map_weaponlocker_stat( "stock", weapondata[ "stock" ] );
	self set_map_weaponlocker_stat( "alt_clip", weapondata[ "alt_clip" ] );
	self set_map_weaponlocker_stat( "alt_stock", weapondata[ "alt_stock" ] );
}

add_client_stat( stat_name, stat_value, include_gametype )
{
	if ( getDvar( "ui_zm_mapstartlocation" ) == "" )
	{
		return;
	}
	if ( !isDefined( include_gametype ) )
	{
		include_gametype = 1;
	}
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( stat_name, stat_value, 0, include_gametype );
	self.stats_this_frame[ stat_name ] = 1;
}

increment_player_stat( stat_name )
{
	if ( getDvar( "ui_zm_mapstartlocation" ) == "" )
	{
		return;
	}
	self incrementplayerstat( stat_name, 1 );
}

increment_root_stat( stat_name, stat_value )
{
	self adddstat( stat_name, stat_value );
}

increment_client_stat( stat_name, include_gametype )
{
	add_client_stat( stat_name, 1, include_gametype );
}

zero_client_stat( stat_name, include_gametype )
{
	current_stat_count = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( stat_name );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( stat_name, current_stat_count * -1, 0, include_gametype );
	self.stats_this_frame[ stat_name ] = 1;
}

increment_map_cheat_stat( stat_name )
{
	self adddstat( "PlayerStatsByMap", level.script, "cheats", stat_name, 1 );
}

get_stat_distance_traveled()
{
	miles = int( self.pers[ "distance_traveled" ] / 63360 );
	remainder = ( self.pers[ "distance_traveled" ] / 63360 ) - miles;
	if ( miles < 1 && remainder < 0,5 )
	{
		miles = 1;
	}
	else
	{
		if ( remainder >= 0,5 )
		{
			miles++;
		}
	}
	return miles;
}

get_stat_round_number()
{
	return level.round_number;
}

get_stat_combined_rank_value_survival_classic()
{
	rounds = get_stat_round_number();
	kills = self.pers[ "kills" ];
	if ( rounds > 99 )
	{
		rounds = 99;
	}
	result = ( rounds * 10000000 ) + kills;
	return result;
}

get_stat_combined_rank_value_grief()
{
	wins = self.pers[ "wins" ];
	losses = self.pers[ "losses" ];
	if ( wins > 9999 )
	{
		wins = 9999;
	}
	if ( losses > 9999 )
	{
		losses = 9999;
	}
	losses_value = 9999 - losses;
	result = ( wins * 10000 ) + losses_value;
	return result;
}

update_global_counters_on_match_end()
{
	deaths = 0;
	kills = 0;
	melee_kills = 0;
	headshots = 0;
	suicides = 0;
	downs = 0;
	revives = 0;
	perks_drank = 0;
	gibs = 0;
	doors_purchased = 0;
	distance_traveled = 0;
	total_shots = 0;
	boards = 0;
	sacrifices = 0;
	drops = 0;
	nuke_pickedup = 0;
	insta_kill_pickedup = 0;
	full_ammo_pickedup = 0;
	double_points_pickedup = 0;
	meat_stink_pickedup = 0;
	carpenter_pickedup = 0;
	fire_sale_pickedup = 0;
	use_magicbox = 0;
	grabbed_from_magicbox = 0;
	use_pap = 0;
	pap_weapon_grabbed = 0;
	specialty_armorvest_drank = 0;
	specialty_quickrevive_drank = 0;
	specialty_fastreload_drank = 0;
	specialty_longersprint_drank = 0;
	specialty_scavenger_drank = 0;
	specialty_rof_drank = 0;
	specialty_deadshot_drank = 0;
	specialty_flakjacket_drank = 0;
	specialty_additionalprimaryweapon_drank = 0;
	specialty_finalstand_drank = 0;
	specialty_grenadepulldeath_drank = 0;
	perk_vulture_drank = 0;
	claymores_planted = 0;
	claymores_pickedup = 0;
	ballistic_knives_pickedup = 0;
	wallbuy_weapons_purchased = 0;
	power_turnedon = 0;
	power_turnedoff = 0;
	planted_buildables_pickedup = 0;
	ammo_purchased = 0;
	upgraded_ammo_purchased = 0;
	buildables_built = 0;
	time_played = 0;
	contaminations_received = 0;
	contaminations_given = 0;
	cheat_too_many_weapons = 0;
	cheat_out_of_playable_area = 0;
	cheat_too_friendly = 0;
	cheat_total = 0;
	players = get_players();
	_a631 = players;
	_k631 = getFirstArrayKey( _a631 );
	while ( isDefined( _k631 ) )
	{
		player = _a631[ _k631 ];
		deaths += player.pers[ "deaths" ];
		kills += player.pers[ "kills" ];
		headshots += player.pers[ "headshots" ];
		suicides += player.pers[ "suicides" ];
		melee_kills += player.pers[ "melee_kills" ];
		downs += player.pers[ "downs" ];
		revives += player.pers[ "revives" ];
		perks_drank += player.pers[ "perks_drank" ];
		specialty_armorvest_drank += player.pers[ "specialty_armorvest_drank" ];
		specialty_quickrevive_drank += player.pers[ "specialty_quickrevive_drank" ];
		specialty_fastreload_drank += player.pers[ "specialty_fastreload_drank" ];
		specialty_longersprint_drank += player.pers[ "specialty_longersprint_drank" ];
		specialty_rof_drank += player.pers[ "specialty_rof_drank" ];
		specialty_deadshot_drank += player.pers[ "specialty_deadshot_drank" ];
		specialty_scavenger_drank += player.pers[ "specialty_scavenger_drank" ];
		specialty_flakjacket_drank += player.pers[ "specialty_flakjacket_drank" ];
		specialty_additionalprimaryweapon_drank += player.pers[ "specialty_additionalprimaryweapon_drank" ];
		specialty_finalstand_drank += player.pers[ "specialty_finalstand_drank" ];
		specialty_grenadepulldeath_drank += player.pers[ "specialty_grenadepulldeath_drank" ];
		perk_vulture_drank += player.pers[ "specialty_nomotionsensor" + "_drank" ];
		gibs += player.pers[ "gibs" ];
		doors_purchased += player.pers[ "doors_purchased" ];
		distance_traveled += player get_stat_distance_traveled();
		boards += player.pers[ "boards" ];
		sacrifices += player.pers[ "sacrifices" ];
		drops += player.pers[ "drops" ];
		nuke_pickedup += player.pers[ "nuke_pickedup" ];
		insta_kill_pickedup += player.pers[ "insta_kill_pickedup" ];
		full_ammo_pickedup += player.pers[ "full_ammo_pickedup" ];
		double_points_pickedup += player.pers[ "double_points_pickedup" ];
		meat_stink_pickedup += player.pers[ "meat_stink_pickedup" ];
		carpenter_pickedup += player.pers[ "carpenter_pickedup" ];
		fire_sale_pickedup += player.pers[ "fire_sale_pickedup" ];
		use_magicbox += player.pers[ "use_magicbox" ];
		grabbed_from_magicbox += player.pers[ "grabbed_from_magicbox" ];
		use_pap += player.pers[ "use_pap" ];
		pap_weapon_grabbed += player.pers[ "pap_weapon_grabbed" ];
		claymores_planted += player.pers[ "claymores_planted" ];
		claymores_pickedup += player.pers[ "claymores_pickedup" ];
		ballistic_knives_pickedup += player.pers[ "ballistic_knives_pickedup" ];
		wallbuy_weapons_purchased += player.pers[ "wallbuy_weapons_purchased" ];
		power_turnedon += player.pers[ "power_turnedon" ];
		power_turnedoff += player.pers[ "power_turnedoff" ];
		planted_buildables_pickedup += player.pers[ "planted_buildables_pickedup" ];
		buildables_built += player.pers[ "buildables_built" ];
		ammo_purchased += player.pers[ "ammo_purchased" ];
		upgraded_ammo_purchased += player.pers[ "upgraded_ammo_purchased" ];
		total_shots += player.total_shots;
		time_played += player.pers[ "time_played_total" ];
		contaminations_received += player.pers[ "contaminations_received" ];
		contaminations_given += player.pers[ "contaminations_given" ];
		cheat_too_many_weapons += player.pers[ "cheat_too_many_weapons" ];
		cheat_out_of_playable_area += player.pers[ "cheat_out_of_playable" ];
		cheat_too_friendly += player.pers[ "cheat_too_friendly" ];
		cheat_total += player.pers[ "cheat_total" ];
		_k631 = getNextArrayKey( _a631, _k631 );
	}
	game_mode = getDvar( "ui_gametype" );
	incrementcounter( "global_zm_" + game_mode, 1 );
	incrementcounter( "global_zm_games", 1 );
	if ( game_mode == "zclassic" || level.script == "zm_nuked" )
	{
		incrementcounter( "global_zm_games_" + level.script, 1 );
	}
	incrementcounter( "global_zm_killed", level.global_zombies_killed );
	incrementcounter( "global_zm_killed_by_players", kills );
	incrementcounter( "global_zm_killed_by_traps", level.zombie_trap_killed_count );
	spacer = "";
	if ( level.round_number < 10 )
	{
		spacer = "0";
	}
	incrementcounter( "global_zm_players_reached_round_" + spacer + level.round_number, players.size );
	incrementcounter( "global_zm_headshots", headshots );
	incrementcounter( "global_zm_suicides", suicides );
	incrementcounter( "global_zm_melee_kills", melee_kills );
	incrementcounter( "global_zm_downs", downs );
	incrementcounter( "global_zm_deaths", deaths );
	incrementcounter( "global_zm_revives", revives );
	incrementcounter( "global_zm_perks_drank", perks_drank );
	incrementcounter( "global_zm_specialty_armorvest_drank", specialty_armorvest_drank );
	incrementcounter( "global_zm_specialty_quickrevive_drank", specialty_quickrevive_drank );
	incrementcounter( "global_zm_specialty_fastreload_drank", specialty_fastreload_drank );
	incrementcounter( "global_zm_specialty_longersprint_drank", specialty_longersprint_drank );
	incrementcounter( "global_zm_specialty_rof_drank", specialty_rof_drank );
	incrementcounter( "global_zm_specialty_deadshot_drank", specialty_deadshot_drank );
	incrementcounter( "global_zm_specialty_scavenger_drank", specialty_scavenger_drank );
	incrementcounter( "global_zm_specialty_flakjacket_drank", specialty_flakjacket_drank );
	incrementcounter( "global_zm_specialty_additionalprimaryweapon_drank", specialty_additionalprimaryweapon_drank );
	incrementcounter( "global_zm_specialty_finalstand_drank", specialty_finalstand_drank );
	incrementcounter( "global_zm_specialty_grenadepulldeath_drank", specialty_grenadepulldeath_drank );
	incrementcounter( "global_zm_" + "specialty_nomotionsensor", perk_vulture_drank );
	incrementcounter( "global_zm_gibs", gibs );
	incrementcounter( "global_zm_distance_traveled", int( distance_traveled ) );
	incrementcounter( "global_zm_doors_purchased", doors_purchased );
	incrementcounter( "global_zm_boards", boards );
	incrementcounter( "global_zm_sacrifices", sacrifices );
	incrementcounter( "global_zm_drops", drops );
	incrementcounter( "global_zm_total_nuke_pickedup", nuke_pickedup );
	incrementcounter( "global_zm_total_insta_kill_pickedup", insta_kill_pickedup );
	incrementcounter( "global_zm_total_full_ammo_pickedup", full_ammo_pickedup );
	incrementcounter( "global_zm_total_double_points_pickedup", double_points_pickedup );
	incrementcounter( "global_zm_total_meat_stink_pickedup", double_points_pickedup );
	incrementcounter( "global_zm_total_carpenter_pickedup", carpenter_pickedup );
	incrementcounter( "global_zm_total_fire_sale_pickedup", fire_sale_pickedup );
	incrementcounter( "global_zm_use_magicbox", use_magicbox );
	incrementcounter( "global_zm_grabbed_from_magicbox", grabbed_from_magicbox );
	incrementcounter( "global_zm_use_pap", use_pap );
	incrementcounter( "global_zm_pap_weapon_grabbed", pap_weapon_grabbed );
	incrementcounter( "global_zm_claymores_planted", claymores_planted );
	incrementcounter( "global_zm_claymores_pickedup", claymores_pickedup );
	incrementcounter( "global_zm_ballistic_knives_pickedup", ballistic_knives_pickedup );
	incrementcounter( "global_zm_wallbuy_weapons_purchased", wallbuy_weapons_purchased );
	incrementcounter( "global_zm_power_turnedon", power_turnedon );
	incrementcounter( "global_zm_power_turnedoff", power_turnedoff );
	incrementcounter( "global_zm_planted_buildables_pickedup", planted_buildables_pickedup );
	incrementcounter( "global_zm_buildables_built", buildables_built );
	incrementcounter( "global_zm_ammo_purchased", ammo_purchased );
	incrementcounter( "global_zm_upgraded_ammo_purchased", upgraded_ammo_purchased );
	incrementcounter( "global_zm_total_shots", total_shots );
	incrementcounter( "global_zm_time_played", time_played );
	incrementcounter( "global_zm_contaminations_received", contaminations_received );
	incrementcounter( "global_zm_contaminations_given", contaminations_given );
	incrementcounter( "global_zm_cheat_players_too_friendly", cheat_too_friendly );
	incrementcounter( "global_zm_cheats_cheat_too_many_weapons", cheat_too_many_weapons );
	incrementcounter( "global_zm_cheats_out_of_playable", cheat_out_of_playable_area );
	incrementcounter( "global_zm_total_cheats", cheat_total );
}

get_specific_stat( stat_category, stat_name )
{
	return self getdstat( stat_category, stat_name, "StatValue" );
}

do_stats_for_gibs( zombie, limb_tags_array )
{
	while ( isDefined( zombie ) && isDefined( zombie.attacker ) && isplayer( zombie.attacker ) )
	{
		_a780 = limb_tags_array;
		_k780 = getFirstArrayKey( _a780 );
		while ( isDefined( _k780 ) )
		{
			limb = _a780[ _k780 ];
			stat_name = undefined;
			if ( limb == level._zombie_gib_piece_index_right_arm )
			{
				stat_name = "right_arm_gibs";
			}
			else if ( limb == level._zombie_gib_piece_index_left_arm )
			{
				stat_name = "left_arm_gibs";
			}
			else if ( limb == level._zombie_gib_piece_index_right_leg )
			{
				stat_name = "right_leg_gibs";
			}
			else if ( limb == level._zombie_gib_piece_index_left_leg )
			{
				stat_name = "left_leg_gibs";
			}
			else
			{
				if ( limb == level._zombie_gib_piece_index_head )
				{
					stat_name = "head_gibs";
				}
			}
			if ( !isDefined( stat_name ) )
			{
			}
			else
			{
				zombie.attacker increment_client_stat( stat_name, 0 );
				zombie.attacker increment_client_stat( "gibs" );
			}
			_k780 = getNextArrayKey( _a780, _k780 );
		}
	}
}

initializematchstats()
{
	if ( !level.onlinegame || !gamemodeismode( level.gamemode_public_match ) )
	{
		return;
	}
	self.pers[ "lastHighestScore" ] = self getdstat( "HighestStats", "highest_score" );
	currgametype = level.gametype;
	self gamehistorystartmatch( getgametypeenumfromname( currgametype, 0 ) );
}

adjustrecentstats()
{
/#
	if ( getDvarInt( "scr_writeConfigStrings" ) == 1 || getDvarInt( "scr_hostmigrationtest" ) == 1 )
	{
		return;
#/
	}
	initializematchstats();
}

uploadstatssoon()
{
	self notify( "upload_stats_soon" );
	self endon( "upload_stats_soon" );
	self endon( "disconnect" );
	wait 1;
	uploadstats( self );
}
