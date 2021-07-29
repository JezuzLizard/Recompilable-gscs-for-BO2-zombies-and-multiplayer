#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level.player_stats_init = ::player_stats_init;
	level.add_client_stat = ::add_client_stat;
	level.track_gibs = ::do_stats_for_gibs;
}

player_stats_init()
{
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "kills", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "downs", 0 );
	self.downs = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "downs" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "revives", 0 );
	self.revives = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "revives" );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "perks_drank", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "headshots", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "gibs", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "head_gibs", 0 );
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
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "losses", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "time_played_total", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "weighted_rounds_played", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_boarding", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_revivenoperk", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_multikill_headshots", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_cash_back_bought", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_cash_back_prone", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_insta_kill", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_nube_5_times", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_jugg", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_jugg_downgrade_count", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_carpenter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_max_round_reached", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_flopper_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_perk_lose_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_pistol_points_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_double_points_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_sniper_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_box_weapon_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_melee_bonus_counter", 0, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "pers_nube_counter", 0, 1 );
	self maps/mp/zombies/_zm_pers_upgrades::pers_abilities_init_globals();
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "score", 0 );
	if ( level.resetplayerscoreeveryround )
	{
		self.pers[ "score" ] = 0;
	}
	self.pers[ "score" ] = level.player_starting_points;
	self.score = self.pers[ "score" ];
	self incrementplayerstat( "score", self.score );
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
}

update_players_stats_at_match_end( players )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
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
		else if ( level.gamemodulewinningteam == "A" )
		{
			matchrecorderincrementheaderstat( "winningTeam", 2 );
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
		for ( i = 5; i > diff_days; i-- )
		{
			timestamp_name = "TIMESTAMPLASTDAY" + ( i - diff_days );
			timestamp_name_to = "TIMESTAMPLASTDAY" + i;
			timestamp_value = self get_global_stat( timestamp_name );
			self set_global_stat( timestamp_name_to, timestamp_value );

		}
		for ( i = 2; i <= diff_days && i < 6; i++ )
		{
			timestamp_name = "TIMESTAMPLASTDAY" + i;
			self set_global_stat( timestamp_name, 0 );
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
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsByGameTypeGroup", game_mode, stat_name, "statValue", value );
}

set_game_mode_group_stat( game_mode, stat_name, value )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self setdstat( "PlayerStatsByGameTypeGroup", game_mode, stat_name, "statValue", value );
}

get_game_mode_group_stat( game_mode, stat_name )
{
	return self getdstat( "PlayerStatsByGameTypeGroup", game_mode, stat_name, "statValue" );
}

add_game_mode_stat( game_mode, stat_name, value )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsByGameType", game_mode, stat_name, "statValue", value );
}

set_game_mode_stat( game_mode, stat_name, value )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
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
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self setdstat( "PlayerStatsList", stat_name, "StatValue", value );
}

add_global_stat( stat_name, value )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsList", stat_name, "StatValue", value );
}

get_map_stat( stat_name, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	return self getdstat( "PlayerStatsByMap", map, stat_name );
}

set_map_stat( stat_name, value, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self setdstat( "PlayerStatsByMap", map, stat_name, value );
}

add_map_stat( stat_name, value, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsByMap", map, stat_name, value );
}

get_location_gametype_stat( start_location, game_type, stat_name )
{
	return self getdstat( "PlayerStatsByStartLocation", start_location, "startLocationGameTypeStats", game_type, "stats", stat_name, "StatValue" );
}

set_location_gametype_stat( start_location, game_type, stat_name, value )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self setdstat( "PlayerStatsByStartLocation", start_location, "startLocationGameTypeStats", game_type, "stats", stat_name, "StatValue", value );
}

add_location_gametype_stat( start_location, game_type, stat_name, value )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsByStartLocation", start_location, "startLocationGameTypeStats", game_type, "stats", stat_name, "StatValue", value );
}

get_map_weaponlocker_stat( stat_name, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	return self getdstat( "PlayerStatsByMap", map, "weaponLocker", stat_name );
}

set_map_weaponlocker_stat( stat_name, value, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	if ( isDefined( value ) )
	{
		self setdstat( "PlayerStatsByMap", map, "weaponLocker", stat_name, value );
	}
	else
	{
		self setdstat( "PlayerStatsByMap", map, "weaponLocker", stat_name, 0 );
	}
}

add_map_weaponlocker_stat( stat_name, value, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsByMap", map, "weaponLocker", stat_name, value );
}

has_stored_weapondata( map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	storedweapon = self get_map_weaponlocker_stat( "name", map );
	if ( isDefined( storedweapon ) || isstring( storedweapon ) && storedweapon == "" || isint( storedweapon ) && storedweapon == 0 )
	{
		return 0;
	}
	return 1;
}

get_stored_weapondata( map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	if ( self has_stored_weapondata( map ) )
	{
		weapondata = [];
		weapondata[ "name" ] = self get_map_weaponlocker_stat( "name", map );
		weapondata[ "lh_clip" ] = self get_map_weaponlocker_stat( "lh_clip", map );
		weapondata[ "clip" ] = self get_map_weaponlocker_stat( "clip", map );
		weapondata[ "stock" ] = self get_map_weaponlocker_stat( "stock", map );
		weapondata[ "alt_clip" ] = self get_map_weaponlocker_stat( "alt_clip", map );
		weapondata[ "alt_stock" ] = self get_map_weaponlocker_stat( "alt_stock", map );
		return weapondata;
	}
	return undefined;
}

clear_stored_weapondata( map ) //checked matches cerberus output
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	self set_map_weaponlocker_stat( "name", "", map );
	self set_map_weaponlocker_stat( "lh_clip", 0, map );
	self set_map_weaponlocker_stat( "clip", 0, map );
	self set_map_weaponlocker_stat( "stock", 0, map );
	self set_map_weaponlocker_stat( "alt_clip", 0, map );
	self set_map_weaponlocker_stat( "alt_stock", 0, map );
}

set_stored_weapondata( weapondata, map )
{
	if ( !isDefined( map ) )
	{
		map = level.script;
	}
	self set_map_weaponlocker_stat( "name", weapondata[ "name" ], map );
	self set_map_weaponlocker_stat( "lh_clip", weapondata[ "lh_clip" ], map );
	self set_map_weaponlocker_stat( "clip", weapondata[ "clip" ], map );
	self set_map_weaponlocker_stat( "stock", weapondata[ "stock" ], map );
	self set_map_weaponlocker_stat( "alt_clip", weapondata[ "alt_clip" ], map );
	self set_map_weaponlocker_stat( "alt_stock", weapondata[ "alt_stock" ], map );
}

add_client_stat( stat_name, stat_value, include_gametype )
{
	if ( !self player_stat_exists( stat_name ) )
	{
		return;
	}
	if ( getDvar( "ui_zm_mapstartlocation" ) == "" || is_true( level.zm_disable_recording_stats ) )
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
	if ( !self player_stat_exists( stat_name ) )
	{
		return;
	}
	if ( getDvar( "ui_zm_mapstartlocation" ) == "" || is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self incrementplayerstat( stat_name, 1 );
}

increment_client_stat( stat_name, include_gametype )
{
	if ( !self player_stat_exists( stat_name ) )
	{
		return;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	add_client_stat( stat_name, 1, include_gametype );
}

set_client_stat( stat_name, stat_value, include_gametype )
{
	if ( !self player_stat_exists( stat_name ) )
	{
		return;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	current_stat_count = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( stat_name );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( stat_name, stat_value - current_stat_count, 0, include_gametype );
	self.stats_this_frame[ stat_name ] = 1;
}

zero_client_stat( stat_name, include_gametype )
{
	if ( !self player_stat_exists( stat_name ) )
	{
		return;
	}
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	current_stat_count = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( stat_name );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( stat_name, current_stat_count * -1, 0, include_gametype );
	self.stats_this_frame[ stat_name ] = 1;
}

increment_map_cheat_stat( stat_name )
{
	if ( is_true( level.zm_disable_recording_stats ) )
	{
		return;
	}
	self adddstat( "PlayerStatsByMap", level.script, "cheats", stat_name, 1 );
}

get_stat_distance_traveled()
{
	miles = int( self.pers[ "distance_traveled" ] / 63360 );
	remainder = ( self.pers[ "distance_traveled" ] / 63360 ) - miles;
	if ( miles < 1 && remainder < 0.5 )
	{
		miles = 1;
	}
	else if ( remainder >= 0.5 )
	{
		miles++;
	}
	return miles;
}

update_global_counters_on_match_end()
{
}

get_specific_stat( stat_category, stat_name )
{
	return self getdstat( stat_category, stat_name, "StatValue" );
}

do_stats_for_gibs( zombie, limb_tags_array )
{
	if ( isDefined( zombie ) && isDefined( zombie.attacker ) && isplayer( zombie.attacker ) )
	{	
		i = 0;
		while ( i < limb_tags_array.size )
		{
			stat_name = undefined;
			if ( limb == level._zombie_gib_piece_index_head )
			{
				stat_name = "head_gibs";
			}
			if ( !isDefined( stat_name ) )
			{
				i++;
				continue;
			}
			zombie.attacker increment_client_stat( stat_name, 0 );
			zombie.attacker increment_client_stat( "gibs" );
			i++;
		}
	}
}

adjustrecentstats()
{
	if ( !level.onlinegame || !gamemodeismode( level.gamemode_public_match ) )
	{
		return;
	}
	self.pers[ "lastHighestScore" ] = self getdstat( "HighestStats", "highest_score" );
	currgametype = level.gametype;
	self gamehistorystartmatch( getgametypeenumfromname( currgametype, 0 ) );
}

uploadstatssoon()
{
	self notify( "upload_stats_soon" );
	self endon( "upload_stats_soon" );
	self endon( "disconnect" );
	wait 1;
	uploadstats( self );
}

player_stat_exists( stat_name )
{
	return isDefined( self.pers[ stat_name ] );
}