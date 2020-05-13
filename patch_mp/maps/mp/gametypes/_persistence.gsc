//checked includes changed to match cerberus output
#include maps/mp/gametypes/_persistence;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/bots/_bot;
#include maps/mp/_popups;
#include maps/mp/_scoreevents;
#include maps/mp/_medals;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_class;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	level.persistentdatainfo = [];
	level.maxrecentstats = 10;
	level.maxhitlocations = 19;
	maps/mp/gametypes/_class::init();
	maps/mp/gametypes/_rank::init();
	level thread maps/mp/_challenges::init();
	level thread maps/mp/_medals::init();
	level thread maps/mp/_scoreevents::init();
	maps/mp/_popups::init();
	level thread onplayerconnect();
	level thread initializestattracking();
	level thread uploadglobalstatcounters();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player.enabletext = 1;
	}
}

initializestattracking() //checked changed to match cerberus output
{
	level.globalexecutions = 0;
	level.globalchallenges = 0;
	level.globalsharepackages = 0;
	level.globalcontractsfailed = 0;
	level.globalcontractspassed = 0;
	level.globalcontractscppaid = 0;
	level.globalkillstreakscalled = 0;
	level.globalkillstreaksdestroyed = 0;
	level.globalkillstreaksdeathsfrom = 0;
	level.globallarryskilled = 0;
	level.globalbuzzkills = 0;
	level.globalrevives = 0;
	level.globalafterlifes = 0;
	level.globalcomebacks = 0;
	level.globalpaybacks = 0;
	level.globalbackstabs = 0;
	level.globalbankshots = 0;
	level.globalskewered = 0;
	level.globalteammedals = 0;
	level.globalfeetfallen = 0;
	level.globaldistancesprinted = 0;
	level.globaldembombsprotected = 0;
	level.globaldembombsdestroyed = 0;
	level.globalbombsdestroyed = 0;
	level.globalfraggrenadesfired = 0;
	level.globalsatchelchargefired = 0;
	level.globalshotsfired = 0;
	level.globalcrossbowfired = 0;
	level.globalcarsdestroyed = 0;
	level.globalbarrelsdestroyed = 0;
	level.globalbombsdestroyedbyteam = [];
	foreach ( team in level.teams )
	{
		level.globalbombsdestroyedbyteam[ team ] = 0;
	}
}

uploadglobalstatcounters() //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	level waittill( "game_ended" );
	if ( !level.rankedmatch && !level.wagermatch )
	{
		return;
	}
	totalkills = 0;
	totaldeaths = 0;
	totalassists = 0;
	totalheadshots = 0;
	totalsuicides = 0;
	totaltimeplayed = 0;
	totalflagscaptured = 0;
	totalflagsreturned = 0;
	totalhqsdestroyed = 0;
	totalhqscaptured = 0;
	totalsddefused = 0;
	totalsdplants = 0;
	totalhumiliations = 0;
	totalsabdestroyedbyteam = [];
	foreach ( team in level.teams )
	{
		totalsabdestroyedbyteam[ team ] = 0;
	}
	switch( level.gametype )
	{
		case "dem":
			bombzonesleft = 0;
			index = 0;
			while ( index < level.bombzones.size )
			{
				if ( !isDefined( level.bombzones[ index ].bombexploded ) || !level.bombzones[ index ].bombexploded )
				{
					level.globaldembombsprotected++;
					index++;
					continue;
				}
				level.globaldembombsdestroyed++;
				index++;
			}
		case "sab":
			foreach(team in level.teams)
			{
					totalsabdestroyedbyteam[ team ] = level.globalbombsdestroyedbyteam[ team ];
			}
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		totaltimeplayed += min( player.timeplayed[ "total" ], level.timeplayedcap );
	}
	incrementcounter( "global_executions", level.globalexecutions );
	incrementcounter( "global_sharedpackagemedals", level.globalsharepackages );
	incrementcounter( "global_dem_bombsdestroyed", level.globaldembombsdestroyed );
	incrementcounter( "global_dem_bombsprotected", level.globaldembombsprotected );
	incrementcounter( "global_contracts_failed", level.globalcontractsfailed );
	incrementcounter( "global_killstreaks_called", level.globalkillstreakscalled );
	incrementcounter( "global_killstreaks_destroyed", level.globalkillstreaksdestroyed );
	incrementcounter( "global_killstreaks_deathsfrom", level.globalkillstreaksdeathsfrom );
	incrementcounter( "global_buzzkills", level.globalbuzzkills );
	incrementcounter( "global_revives", level.globalrevives );
	incrementcounter( "global_afterlifes", level.globalafterlifes );
	incrementcounter( "global_comebacks", level.globalcomebacks );
	incrementcounter( "global_paybacks", level.globalpaybacks );
	incrementcounter( "global_backstabs", level.globalbackstabs );
	incrementcounter( "global_bankshots", level.globalbankshots );
	incrementcounter( "global_skewered", level.globalskewered );
	incrementcounter( "global_teammedals", level.globalteammedals );
	incrementcounter( "global_fraggrenadesthrown", level.globalfraggrenadesfired );
	incrementcounter( "global_c4thrown", level.globalsatchelchargefired );
	incrementcounter( "global_shotsfired", level.globalshotsfired );
	incrementcounter( "global_crossbowfired", level.globalcrossbowfired );
	incrementcounter( "global_carsdestroyed", level.globalcarsdestroyed );
	incrementcounter( "global_barrelsdestroyed", level.globalbarrelsdestroyed );
	incrementcounter( "global_challenges_finished", level.globalchallenges );
	incrementcounter( "global_contractscppaid", level.globalcontractscppaid );
	incrementcounter( "global_distancesprinted100inches", int( level.globaldistancesprinted ) );
	incrementcounter( "global_combattraining_botskilled", level.globallarryskilled );
	incrementcounter( "global_distancefeetfallen", int( level.globalfeetfallen ) );
	incrementcounter( "global_minutes", int( totaltimeplayed / 60 ) );
	if ( !waslastround() )
	{
		return;
	}
	wait 0.05;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		totalkills += player.kills;
		totaldeaths += player.deaths;
		totalassists += player.assists;
		totalheadshots += player.headshots;
		totalsuicides += player.suicides;
		totalhumiliations += player.humiliated;
		totaltimeplayed += int( min( player.timeplayed[ "alive" ], level.timeplayedcap ) );
		switch( level.gametype )
		{
			case "ctf":
				totalflagscaptured += player.captures;
				totalflagsreturned += player.returns;
				break;
			case "koth":
				totalhqsdestroyed += player.destructions;
				totalhqscaptured += player.captures;
				break;
			case "sd":
				totalsddefused += player.defuses;
				totalsdplants += player.plants;
				break;
			case "sab":
				if ( isDefined( player.team ) && isDefined( level.teams[ player.team ] ) )
				{
					totalsabdestroyedbyteam[ player.team ] += player.destructions;
				}
				break;
		}
	}
	if ( maps/mp/bots/_bot::is_bot_ranked_match() )
	{
		incrementcounter( "global_combattraining_gamesplayed", 1 );
	}
	incrementcounter( "global_kills", totalkills );
	incrementcounter( "global_deaths", totaldeaths );
	incrementcounter( "global_assists", totalassists );
	incrementcounter( "global_headshots", totalheadshots );
	incrementcounter( "global_suicides", totalsuicides );
	incrementcounter( "global_games", 1 );
	incrementcounter( "global_ctf_flagscaptured", totalflagscaptured );
	incrementcounter( "global_ctf_flagsreturned", totalflagsreturned );
	incrementcounter( "global_hq_destroyed", totalhqsdestroyed );
	incrementcounter( "global_hq_captured", totalhqscaptured );
	incrementcounter( "global_snd_defuses", totalsddefused );
	incrementcounter( "global_snd_plants", totalsdplants );
	incrementcounter( "global_sab_destroyedbyops", totalsabdestroyedbyteam[ "allies" ] );
	incrementcounter( "global_sab_destroyedbycommunists", totalsabdestroyedbyteam[ "axis" ] );
	incrementcounter( "global_humiliations", totalhumiliations );
	if ( isDefined( game[ "wager_pot" ] ) )
	{
		incrementcounter( "global_wageredcp", game[ "wager_pot" ] );
	}
}

statgetwithgametype( dataname ) //checked matches cerberus output
{
	if ( isDefined( level.nopersistence ) && level.nopersistence )
	{
		return 0;
	}
	if ( !level.onlinegame )
	{
		return 0;
	}
	return self getdstat( "PlayerStatsByGameType", getgametypename(), dataname, "StatValue" );
}

getgametypename() //checked matches cerberus output
{
	if ( !isDefined( level.fullgametypename ) )
	{
		if ( isDefined( level.hardcoremode ) && level.hardcoremode && ispartygamemode() == 0 )
		{
			prefix = "HC";
		}
		else
		{
			prefix = "";
		}
		level.fullgametypename = tolower( prefix + level.gametype );
	}
	return level.fullgametypename;
}

ispartygamemode() //checked changed to match cerberus output
{
	switch( level.gametype )
	{
		case "gun":
		case "oic":
		case "sas":
		case "shrp":
			return 1;
	}
	return 0;
}

isstatmodifiable( dataname ) //checked changed at own discretion
{
	if ( level.rankedmatch || level.wagermatch )
	{
		return 1;
	}
	return 0;
}

statsetwithgametype( dataname, value, incvalue ) //checked matches cerberus output
{
	if ( isDefined( level.nopersistence ) && level.nopersistence )
	{
		return 0;
	}
	if ( !isstatmodifiable( dataname ) )
	{
		return;
	}
	if ( level.disablestattracking )
	{
		return;
	}
	self setdstat( "PlayerStatsByGameType", getgametypename(), dataname, "StatValue", value );
}

adjustrecentstats() //checked matches cerberus output
{
	/*
/#
	if ( getDvarInt( "scr_writeConfigStrings" ) == 1 || getDvarInt( "scr_hostmigrationtest" ) == 1 )
	{
		return;
#/
	}
	*/
	initializematchstats();
}

getrecentstat( isglobal, index, statname ) //checked changed to match cerberus output
{
	if ( level.wagermatch )
	{
		return self getdstat( "RecentEarnings", index, statname );
	}
	else if ( isglobal )
	{
		modename = maps/mp/gametypes/_globallogic::getcurrentgamemode();
		return self getdstat( "gameHistory", modename, "matchHistory", index, statname );
	}
	else
	{
		return self getdstat( "PlayerStatsByGameType", getgametypename(), "prevScores", index, statname );
	}
}

setrecentstat( isglobal, index, statname, value ) //checked matches cerberus output
{
	if ( isDefined( level.nopersistence ) && level.nopersistence )
	{
		return;
	}
	if ( !level.onlinegame )
	{
		return;
	}
	if ( !isstatmodifiable( statname ) )
	{
		return;
	}
	if ( index < 0 || index > 9 )
	{
		return;
	}
	if ( level.wagermatch )
	{
		self setdstat( "RecentEarnings", index, statname, value );
	}
	else if ( isglobal )
	{
		modename = maps/mp/gametypes/_globallogic::getcurrentgamemode();
		self setdstat( "gameHistory", modename, "matchHistory", "" + index, statname, value );
		return;
	}
	else
	{
		self setdstat( "PlayerStatsByGameType", getgametypename(), "prevScores", index, statname, value );
		return;
	}
}

addrecentstat( isglobal, index, statname, value ) //checked matches cerberus output
{
	if ( isDefined( level.nopersistence ) && level.nopersistence )
	{
		return;
	}
	if ( !level.onlinegame )
	{
		return;
	}
	if ( !isstatmodifiable( statname ) )
	{
		return;
	}
	currstat = getrecentstat( isglobal, index, statname );
	setrecentstat( isglobal, index, statname, currstat + value );
}

setmatchhistorystat( statname, value ) //checked matches cerberus output
{
	modename = maps/mp/gametypes/_globallogic::getcurrentgamemode();
	historyindex = self getdstat( "gameHistory", modename, "currentMatchHistoryIndex" );
	setrecentstat( 1, historyindex, statname, value );
}

addmatchhistorystat( statname, value ) //checked matches cerberus output
{
	modename = maps/mp/gametypes/_globallogic::getcurrentgamemode();
	historyindex = self getdstat( "gameHistory", modename, "currentMatchHistoryIndex" );
	addrecentstat( 1, historyindex, statname, value );
}

initializematchstats() //checked matches cerberus output
{
	if ( isDefined( level.nopersistence ) && level.nopersistence )
	{
		return;
	}
	if ( !level.onlinegame )
	{
		return;
	}
	if ( !level.rankedmatch && !level.wagermatch && !level.leaguematch )
	{
		return;
	}
	self.pers[ "lastHighestScore" ] = self getdstat( "HighestStats", "highest_score" );
	currgametype = maps/mp/gametypes/_persistence::getgametypename();
	self gamehistorystartmatch( getgametypeenumfromname( currgametype, level.hardcoremode ) );
}

setafteractionreportstat( statname, value, index ) //checked changed to match cerberus output
{
	if ( self is_bot() )
	{
		return;
	}
		/*
/#
	if ( getDvarInt( "scr_writeConfigStrings" ) == 1 || getDvarInt( "scr_hostmigrationtest" ) == 1 )
	{
		return;
#/
	}
		*/
	if ( level.rankedmatch || level.wagermatch && level.leaguematch )
	{
		if ( isDefined( index ) )
		{
			self setdstat( "AfterActionReportStats", statname, index, value );
			return;
		}
		else
		{
			self setdstat( "AfterActionReportStats", statname, value );
		}
	}
}

codecallback_challengecomplete( rewardxp, maxval, row, tablenumber, challengetype, itemindex, challengeindex ) //checked matches cerberus output
{
	self luinotifyevent( &"challenge_complete", 7, challengeindex, itemindex, challengetype, tablenumber, row, maxval, rewardxp );
	self luinotifyeventtospectators( &"challenge_complete", 7, challengeindex, itemindex, challengetype, tablenumber, row, maxval, rewardxp );
}

codecallback_gunchallengecomplete( rewardxp, attachmentindex, itemindex, rankid ) //checked matches cerberus output
{
	self luinotifyevent( &"gun_level_complete", 4, rankid, itemindex, attachmentindex, rewardxp );
	self luinotifyeventtospectators( &"gun_level_complete", 4, rankid, itemindex, attachmentindex, rewardxp );
}

checkcontractexpirations() //checked matches cerberus output
{
}

incrementcontracttimes( timeinc ) //checked matches cerberus output
{
}

addcontracttoqueue( index, passed ) //checked matches cerberus output
{
}

uploadstatssoon() //checked matches cerberus output
{
	self notify( "upload_stats_soon" );
	self endon( "upload_stats_soon" );
	self endon( "disconnect" );
	wait 1;
	uploadstats( self );
}

codecallback_onaddplayerstat( dataname, value ) //checked matches cerberus output
{
}

codecallback_onaddweaponstat( weapname, dataname, value ) //checked matches cerberus output
{
}

processcontractsonaddstat( stattype, dataname, value, weapname ) //checked matches cerberus output
{
}

