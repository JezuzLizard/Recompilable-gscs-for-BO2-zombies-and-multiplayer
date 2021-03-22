#include maps/mp/gametypes/_hostmigration;
#include maps/mp/gametypes/_dev;
#include maps/mp/_multi_extracam;
#include maps/mp/gametypes/_friendicons;
#include maps/mp/_bb;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/gametypes/_healthoverlay;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/teams/_teams;
#include maps/mp/gametypes/_menus;
#include maps/mp/_decoy;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/_objpoints;
#include maps/mp/gametypes/_spectating;
#include maps/mp/gametypes/_deathicons;
#include maps/mp/gametypes/_shellshock;
#include maps/mp/gametypes/_killcam;
#include maps/mp/gametypes/_scoreboard;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/gametypes/_clientids;
#include maps/mp/gametypes/_serversettings;
#include maps/mp/_challenges;
#include maps/mp/_music;
#include maps/mp/gametypes/_weapons;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/_demo;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_wager;
#include maps/mp/gametypes/_persistence;
#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/bots/_bot;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_globallogic_defaults;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_globallogic_spawn;
#include maps/mp/_gamerep;
#include maps/mp/_gameadvertisement;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_class;
#include maps/mp/gametypes/_globallogic_ui;
#include maps/mp/gametypes/_tweakables;
#include common_scripts/utility;
#include maps/mp/_busing;
#include maps/mp/_burnplayer;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;


init() //checked matches bo3 _globallogic.gsc within reason
{

	// hack to allow maps with no scripts to run correctly
	if ( !isDefined( level.tweakablesInitialized ) )
		maps\mp\gametypes\_tweakables::init();
	
	init_session_mode_flags();

	level.splitscreen = isSplitScreen();
	level.xenon = (GetDvar( "xenonGame") == "true");
	level.ps3 = (GetDvar( "ps3Game") == "true");
	level.wiiu = (GetDvar( "wiiuGame") == "true");

	level.onlineGame = SessionModeIsOnlineGame();
	level.systemlink = sessionmodeissystemlink();
	if ( level.xenon || level.ps3 || level.wiiu )
	{
		level.console = 1;
	}
	else
	{
		level.console = 0;
	}
	
	if ( !ispregame() )
	{
		level.rankedMatch = GameModeIsUsingXP();
	}
	level.leagueMatch = GameModeIsMode( level.GAMEMODE_LEAGUE_MATCH );
	
	level.contractsEnabled = !GetGametypeSetting( "disableContracts" );
		
	if ( GameModeIsMode( level.GAMEMODE_BASIC_TRAINING ) )
	{
		level.contractsEnabled = false;
	}
		/*
	/#
	if ( GetDvarint( "scr_forcerankedmatch" ) == 1 )
		level.rankedMatch = true;
	#/
		*/
	level.script = toLower( GetDvar( "mapname" ) );
	level.gametype = toLower( GetDvar( "g_gametype" ) );

	level.teamBased = false;
	level.teamCount = GetGametypeSetting( "teamCount" );
	level.multiTeam = ( level.teamCount > 2 );
	
	if ( SessionModeIsZombiesGame() )
	{
		level.zombie_team_index = level.teamCount + 1;
		if ( 2 == level.zombie_team_index )
		{
			level.zombie_team = "axis";
		}
		else
		{
			level.zombie_team = "team" + level.zombie_team_index;
		}
	}

	// used to loop through all valid playing teams ( not spectator )
	// can also be used to check if a team is valid ( isdefined( level.teams[team] ) )
	// NOTE: added in the same order they are defined in code
	level.teams = [];
	level.teamIndex = [];
	
	teamCount = level.teamCount;
	
	level.teams[ "allies" ] = "allies";
	level.teams[ "axis" ] = "axis";

	level.teamIndex[ "neutral" ] = 0; // Neutral team set to 0 so that it can be used by objectives
	level.teamIndex[ "allies" ] = 1;
	level.teamIndex[ "axis" ] = 2;
	
	for( teamIndex = 3; teamIndex <= teamCount; teamIndex++ )
	{
		level.teams[ "team" + teamIndex ] = "team" + teamIndex;
		level.teamIndex[ "team" + teamIndex ] = teamIndex;
	}
	
	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;
	
	level.endGameOnScoreLimit = true;
	level.endGameOnTimeLimit = true;
	level.scoreRoundBased = false;
	level.resetPlayerScoreEveryRound = false;
	
	level.gameForfeited= false;
	level.forceAutoAssign = false;
	
	level.halftimeType = "halftime";
	level.halftimeSubCaption = &"MP_SWITCHING_SIDES_CAPS";
	
	level.lastStatusTime = 0;
	level.wasWinning = [];
	
	level.lastSlowProcessFrame = 0;
	
	level.placement = [];
	foreach( team in level.teams )
	{
		level.placement[team] = [];
	}
	level.placement["all"] = [];
	
	level.postRoundTime = 7.0;//Kevin Sherwood changed to 9 to have enough time for music stingers
	
	level.inOvertime = false;
	
	level.defaultOffenseRadius = 560;

	level.dropTeam = GetDvarint( "sv_maxclients" );
	
	level.inFinalKillcam = false;

	maps\mp\gametypes\_globallogic_ui::init();

	registerDvars();
	maps\mp\gametypes\_class::initPerkDvars();

	level.oldschool = ( GetDvarint( "scr_oldschool" ) == 1 );
	if ( level.oldschool )
	{
		logString( "game mode: oldschool" );
	
		SetDvar( "jump_height", 64 );
		SetDvar( "jump_slowdownEnable", 0 );
		SetDvar( "bg_fallDamageMinHeight", 256 );
		SetDvar( "bg_fallDamageMaxHeight", 512 );
		SetDvar( "player_clipSizeMultiplier", 2.0 );
	}

	precacheModel( "tag_origin" );
	precacheRumble( "dtp_rumble" );
	precacheRumble( "slide_rumble" );
	
	precache_mp_leaderboards();
	
	// sets up the flame fx
	maps\mp\_burnplayer::initBurnPlayer();
	
	if ( !isDefined( game["tiebreaker"] ) )
		game["tiebreaker"] = false;
		
	maps\mp\gametypes\_globallogic_audio::registerDialogGroup( "introboost", true );
	maps\mp\gametypes\_globallogic_audio::registerDialogGroup( "status", true );

	thread maps\mp\_gameadvertisement::init();
	thread maps\mp\_gamerep::init();
	level.disablechallenges = 0;
	if(level.leaguematch )
	{
		level.disablechallenges = 1;
	}
	level.disablestattracking = 0;
}

registerDvars() //checked matches bo3 _globallogic.gsc within reason
{
	if ( GetDvar( "scr_oldschool" ) == "" )
		SetDvar( "scr_oldschool", "0" );
		
	makeDvarServerInfo( "scr_oldschool" );

	if ( GetDvar( "ui_guncycle" ) == "" )
		SetDvar( "ui_guncycle", 0 );
		
	makedvarserverinfo( "ui_guncycle" );

	if ( GetDvar( "ui_weapon_tiers" ) == "" )
		SetDvar( "ui_weapon_tiers", 0 );
	makedvarserverinfo( "ui_weapon_tiers" );

	SetDvar( "ui_text_endreason", "");
	makeDvarServerInfo( "ui_text_endreason", "" );

	setMatchFlag( "bomb_timer", 0 );
	
	setMatchFlag( "enable_popups", 1 );
	
	setMatchFlag( "pregame", isPregame() );

	if ( GetDvar( "scr_vehicle_damage_scalar" ) == "" )
		SetDvar( "scr_vehicle_damage_scalar", "1" );
		
	level.vehicleDamageScalar = GetDvarfloat( "scr_vehicle_damage_scalar");

	level.fire_audio_repeat_duration = GetDvarint( "fire_audio_repeat_duration" );
	level.fire_audio_random_max_duration = GetDvarint( "fire_audio_random_max_duration" );
	teamname = getcustomteamname(level.teamindex["allies"]);
	if(isdefined(teamname))
	{
		setdvar("g_customTeamName_Allies", teamname);
	}
	else
	{
		setdvar("g_customTeamName_Allies", "");
	}
	teamname = getcustomteamname(level.teamindex["axis"]);
	if(isdefined(teamname))
	{
		setdvar("g_customTeamName_Axis", teamname);
	}
	else
	{
		setdvar("g_customTeamName_Axis", "");
	}
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 ) //checked matches bo3 _globallogic.gsc within reason
{
}

SetupCallbacks() //checked matches bo3 _globallogic.gsc within reason
{
	level.spawnPlayer = maps\mp\gametypes\_globallogic_spawn::spawnPlayer;
	level.spawnPlayerPrediction = maps\mp\gametypes\_globallogic_spawn::spawnPlayerPrediction;
	level.spawnClient = maps\mp\gametypes\_globallogic_spawn::spawnClient;
	level.spawnSpectator = maps\mp\gametypes\_globallogic_spawn::spawnSpectator;
	level.spawnIntermission = maps\mp\gametypes\_globallogic_spawn::spawnIntermission;
	level.onPlayerScore = maps\mp\gametypes\_globallogic_score::default_onPlayerScore;
	level.onTeamScore = maps\mp\gametypes\_globallogic_score::default_onTeamScore;
	
	level.waveSpawnTimer = ::waveSpawnTimer;
	level.spawnMessage =	maps\mp\gametypes\_globallogic_spawn::default_spawnMessage;
	
	level.onSpawnPlayer = ::blank;
	level.onSpawnPlayerUnified = ::blank;
	level.onSpawnSpectator = maps\mp\gametypes\_globallogic_defaults::default_onSpawnSpectator;
	level.onSpawnIntermission = maps\mp\gametypes\_globallogic_defaults::default_onSpawnIntermission;
	level.onRespawnDelay = ::blank;

	level.onForfeit = maps\mp\gametypes\_globallogic_defaults::default_onForfeit;
	level.onTimeLimit = maps\mp\gametypes\_globallogic_defaults::default_onTimeLimit;
	level.onScoreLimit = maps\mp\gametypes\_globallogic_defaults::default_onScoreLimit;
	level.onAliveCountChange = maps\mp\gametypes\_globallogic_defaults::default_onAliveCountChange;
	level.onDeadEvent = maps\mp\gametypes\_globallogic_defaults::default_onDeadEvent;
	level.onOneLeftEvent = maps\mp\gametypes\_globallogic_defaults::default_onOneLeftEvent;
	level.giveTeamScore = maps\mp\gametypes\_globallogic_score::giveTeamScore;
	level.onLastTeamAliveEvent = undefined;

	level.getTimeLimit = maps\mp\gametypes\_globallogic_defaults::default_getTimeLimit;
	level.getTeamKillPenalty = maps\mp\gametypes\_globallogic_defaults::default_getTeamKillPenalty;
	level.getTeamKillScore = maps\mp\gametypes\_globallogic_defaults::default_getTeamKillScore;

	level.isKillBoosting = maps\mp\gametypes\_globallogic_score::default_isKillBoosting;

	level._setTeamScore = maps\mp\gametypes\_globallogic_score::_setTeamScore;
	level._setPlayerScore = maps\mp\gametypes\_globallogic_score::_setPlayerScore;

	level._getTeamScore = maps\mp\gametypes\_globallogic_score::_getTeamScore;
	level._getPlayerScore = maps\mp\gametypes\_globallogic_score::_getPlayerScore;
	
	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;
	level.onPlayerKilledExtraUnthreadedCBs = []; //< Array of other CB function pointers

	level.onTeamOutcomeNotify = maps\mp\gametypes\_hud_message::teamOutcomeNotify;
	level.onOutcomeNotify = maps\mp\gametypes\_hud_message::outcomeNotify;
	level.onTeamWagerOutcomeNotify = maps\mp\gametypes\_hud_message::teamWagerOutcomeNotify;
	level.onWagerOutcomeNotify = maps\mp\gametypes\_hud_message::wagerOutcomeNotify;
	level.setMatchScoreHUDElemForTeam = maps\mp\gametypes\_hud_message::setMatchScoreHUDElemForTeam;
	level.onEndGame = ::blank;
	level.onRoundEndGame = maps\mp\gametypes\_globallogic_defaults::default_onRoundEndGame;
	level.onMedalAwarded = ::blank;

	maps\mp\gametypes\_globallogic_ui::SetupCallbacks();
}

precache_mp_leaderboards() //checked matches bo3 _globallogic.gsc within reason
{
	if(maps/mp/bots/_bot::is_bot_ranked_match())
	{
		return;
	}
	if( SessionModeIsZombiesGame() )
		return;

	if( !level.rankedMatch )
		return;
		
	mapname = GetDvar( "mapname" ); 

	globalLeaderboards = "LB_MP_GB_XPPRESTIGE LB_MP_GB_TOTALXP_AT LB_MP_GB_TOTALXP_LT LB_MP_GB_WINS_AT LB_MP_GB_WINS_LT LB_MP_GB_KILLS_AT LB_MP_GB_KILLS_LT LB_MP_GB_ACCURACY_AT LB_MP_GB_ACCURACY_LT";
	careerleaderboard = "";
	switch(level.gametype)
	{
		case "gun":
		case "oic":
		case "sas":
		case "shrp":
			break;
		default:
			careerleaderboard = " LB_MP_GB_SCOREPERMINUTE";
			break;
	}

	gamemodeleaderboard = " LB_MP_GM_" + level.gametype;
	gamemodeleaderboardext = " LB_MP_GM_" + level.gametype + "_EXT";
	gamemodehcleaderboard = "";
	gamemodehcleaderboardext = "";

	hardcoremode = getgametypesetting("hardcoreMode");
	if(isdefined(hardcoremode) && hardcoremode)
	{
		gamemodehcleaderboard = gamemodeleaderboard + "_HC";
		gamemodehcleaderboardext = gamemodeleaderboardext + "_HC";
	}
	mapLeaderboard = " LB_MP_MAP_" + getsubstr( mapname, 3, mapname.size ); // strip the MP_ from the map name
		
	precacheleaderboards(globalleaderboards + careerleaderboard + gamemodeleaderboard + gamemodeleaderboardext + gamemodehcleaderboard + gamemodehcleaderboardext + mapleaderboard);	
}

compareTeamByGameStat( gameStat, teamA, teamB, previous_winner_score ) //checked matches bo3 _globallogic.gsc within reason
{
	winner = undefined;
	
	if ( teamA == "tie" )
	{
		winner = "tie";
		
		if ( previous_winner_score < game[gameStat][teamB] )
			winner = teamB;
	}
	else if ( game[gameStat][teamA] == game[gameStat][teamB] )
		winner = "tie";
	else if ( game[gameStat][teamB] > game[gameStat][teamA] )
		winner = teamB;
	else
		winner = teamA;
	
	return winner;
}

determineTeamWinnerByGameStat( gameStat ) //checked matches bo3 _globallogic.gsc within reason
{
	teamKeys = GetArrayKeys(level.teams);
	winner = teamKeys[0];
	previous_winner_score = game[gameStat][winner];
	
	for ( teamIndex = 1; teamIndex < teamKeys.size; teamIndex++ )
	{
		winner = compareTeamByGameStat( gameStat, winner, teamKeys[teamIndex], previous_winner_score);
		
		if ( winner != "tie" )
		{
			previous_winner_score = game[gameStat][winner];
		}	
	}
	
	return winner;
}

compareTeamByTeamScore( teamA, teamB, previous_winner_score ) //checked matches bo3 _globallogic.gsc within reason
{
	winner = undefined;
  teamBScore = [[level._getTeamScore]]( teamB );

	if ( teamA == "tie" )
	{
		winner = "tie";
		
		if ( previous_winner_score < teamBScore )
			winner = teamB;
			
		return winner;
	}
	
  teamAScore = [[level._getTeamScore]]( teamA );

	if ( teamBScore == teamAScore )
		winner = "tie";
	else if ( teamBScore > teamAScore )
		winner = teamB;
	else
		winner = teamA;
		
	return winner;
}

determineTeamWinnerByTeamScore( ) //checked matches bo3 _globallogic.gsc within reason
{
	teamKeys = GetArrayKeys(level.teams);
	winner = teamKeys[0];
	previous_winner_score = [[level._getTeamScore]]( winner );
	
	for ( teamIndex = 1; teamIndex < teamKeys.size; teamIndex++ )
	{
		winner = compareTeamByTeamScore( winner, teamKeys[teamIndex], previous_winner_score);
		
		if ( winner != "tie" )
		{
			previous_winner_score = [[level._getTeamScore]]( winner );
		}	
	}
	
	return winner;
}

forceEnd(hostsucks) //checked matches bo3 _globallogic.gsc within reason
{
	if (!isDefined(hostsucks))
		hostsucks = false;

	if ( level.hostForcedEnd || level.forcedEnd )
		return;

	winner = undefined;
	
	if ( level.teamBased )
	{
		winner = determineTeamWinnerByGameStat("teamScores");
		maps\mp\gametypes\_globallogic_utils::logTeamWinString( "host ended game", winner );
	}
	else
	{
		winner = maps\mp\gametypes\_globallogic_score::getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "host ended game, win: " + winner.name );
		else
			logString( "host ended game, tie" );
	}
	
	level.forcedEnd = true;
	level.hostForcedEnd = true;
	
	if (hostsucks)
	{
		endString = &"MP_HOST_SUCKS";
	}
	else
	{
		if ( level.splitscreen )
			endString = &"MP_ENDED_GAME";
		else
			endString = &"MP_HOST_ENDED_GAME";
	}
	
	setMatchFlag( "disableIngameMenu", 1 );
	makeDvarServerInfo( "ui_text_endreason", endString );
	SetDvar( "ui_text_endreason", endString );
	thread endGame( winner, endString );
}

killserverPc() //checked matches bo3 _globallogic.gsc within reason
{
	if ( level.hostForcedEnd || level.forcedEnd )
		return;
		
	winner = undefined;
	
	if ( level.teamBased )
	{
		winner = determineTeamWinnerByGameStat("teamScores");
		maps\mp\gametypes\_globallogic_utils::logTeamWinString( "host ended game", winner );
	}
	else
	{
		winner = maps\mp\gametypes\_globallogic_score::getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "host ended game, win: " + winner.name );
		else
			logString( "host ended game, tie" );
	}
	
	level.forcedEnd = true;
	level.hostForcedEnd = true;
	
	level.killserver = true;
	
	endString = &"MP_HOST_ENDED_GAME";
	
		/*
/#
		PrintLn("kill server; ending game\n");
#/
		*/
	thread endGame( winner, endString );
}

atleasttwoteams() //checked changed to match bo3 _globallogic.gsc
{
	valid_count = 0;
	
	foreach ( team in level.teams )
	{ 
		if ( level.playerCount[team] != 0 )
		{
			valid_count++;
		}
	}
	
	if ( valid_count < 2 )
	{
		return false;
	}
	
	return true;
}

checkIfTeamForfeits( team ) //checked matches bo3 _globallogic.gsc within reason
{
	if(!game["everExisted"][team])
	{
		return 0;
	}
	if ( level.playerCount[team] < 1 && totalPlayerCount() > 0 )
	{
		return true;
	}
	
	return false;
}

checkForAnyTeamForfeit() //checked does not match bo3 _globallogic.gsc did not change
{
	forfeit_count = 0;
	valid_team = undefined;
	foreach(team in level.teams)
	{
		if(checkifteamforfeits(team))
		{
			forfeit_count++;
			if(!level.multiteam)
			{
				thread [[level.onforfeit]](team);
				return 1;
			}
		}
		else 
		{
			valid_team = team;
		}
	}
	if(level.multiteam && forfeit_count == level.teams.size - 1)
	{
		thread [[level.onforfeit]](valid_team);
		return 1;
	}
	return 0;
}

doSpawnQueueUpdates() //checked matches bo3 _globallogic.gsc within reason
{
	foreach( team in level.teams )
	{
		if ( level.spawnQueueModified[team] ) 
		{
			[[level.onAliveCountChange]]( team );
		}
	}
}

isTeamAllDead( team ) //checked matches bo3 _globallogic.gsc within reason
{
	if ( level.everExisted[team] && !level.aliveCount[team] && !level.playerLives[team] )
	{
		return 1;
	}
	return 0; 
}

areAllTeamsDead( ) //checked matches bo3 _globallogic.gsc within reason
{
	foreach( team in level.teams )
	{
		// if team was alive and now they are not
		if ( !isTeamAllDead( team ) )
		{	
			return false;
		}
	}
	
	return true;
}

allDeadTeamCount( ) //checked does not exist in bo3 _globallogic.gsc leaving in
{
	count = 0;
	foreach( team in level.teams )
	{
		// if team was alive and now they are not
		if ( isTeamAllDead( team ) )
		{	
			count++;
		}
	}
	
	return count;
}

getlastteamalive()
{
	count = 0;
	everexistedcount = 0;
	aliveteam = undefined;
	foreach(team in level.teams)
	{
		if(level.everexisted[team])
		{
			if(!isteamalldead(team))
			{
				aliveteam = team;
				count++;
			}
			everexistedcount++;
		}
	}
	if(everexistedcount > 1 && count == 1)
	{
		return aliveteam;
	}
	return undefined;
}

doDeadEventUpdates() //checked changed to match bo3 _globallogic.gsc
{
	if ( level.teamBased )
	{
		// if all teams were alive and now they are all dead in the same instance
		if ( areAllTeamsDead( ) )
		{
			[[level.onDeadEvent]]( "all" );
			return true;
		}
		if ( !isdefined( level.onDeadEvent ) )
		{
			lastTeamAlive = getLastTeamAlive();
			if ( isdefined( lastTeamAlive ) )
			{
				[[level.onLastTeamAliveEvent]]( lastTeamAlive );
				return true;
			}
		}
		else
		{
			foreach( team in level.teams )
			{
				// if team was alive and now they are not
				if ( isTeamAllDead( team ) )
				{	
					[[level.onDeadEvent]]( team );
					return true;
				}
			}
		}
	}
	else
	{
		// everyone is dead
		if ( totalAliveCount() == 0 && totalPlayerLives() == 0 && level.maxPlayerCount > 1 )
		{
			[[ level.onDeadEvent ]]( "all" );
			return true;
		}
	}
	
	return false;
}

isOnlyOneLeftAliveOnTeam( team ) //checked matches bo3 _globallogic.gsc within reason
{
	if ( level.lastAliveCount[team] > 1 && level.aliveCount[team] == 1 && level.playerLives[team] == 1 )  
	{
		return 1;
	}
	return 0; 
}


doOneLeftEventUpdates() //checked matches bo3 _globallogic.gsc within reason
{
	if ( level.teamBased )
	{
		foreach( team in level.teams )
		{
			// one "team" left
			if ( isOnlyOneLeftAliveOnTeam( team ) )
			{	
				[[level.onOneLeftEvent]]( team );
				return true;
			}
		}
	}
	else
	{
		// last man standing
		if ( (totalAliveCount() == 1) && (totalPlayerLives() == 1) && level.maxPlayerCount > 1 )
		{
			[[level.onOneLeftEvent]]( "all" );
			return true;
		}
	}
	
	return false;
}

updateGameEvents() //checked matches bo3 _globallogic.gsc within reason
{
	/*
/#
	if( GetDvarint( "scr_hostmigrationtest" ) == 1 )
	{
		return;
	}
#/
	*/
	if ( level.rankedMatch && !level.inGracePeriod || level.wagerMatch && !level.inGracePeriod || level.leagueMatch && !level.inGracePeriod )
	{
		if ( level.teamBased )
		{
			if (!level.gameForfeited )
			{
				if( game["state"] == "playing" && checkForAnyTeamForfeit() )
				{
					return;
				}
			}
			else // level.gameForfeited==true
			{
				if ( atleasttwoteams() )
				{
					level.gameForfeited = false;
					level notify( "abort forfeit" );
				}
			}
		}
		else
		{
			if (!level.gameForfeited)
			{
				if ( totalPlayerCount() == 1 && level.maxPlayerCount > 1 )
				{
					thread [[level.onForfeit]]();
					return;
				}
			}
			else // level.gameForfeited==true
			{
				if ( totalPlayerCount() > 1 )
				{
					level.gameForfeited = false;
					level notify( "abort forfeit" );
				}
			}
		}
	}
		
	if ( !level.playerQueuedRespawn && !level.numLives && !level.inOverTime )
		return;
		
	if ( level.inGracePeriod )
		return;

	if ( level.playerQueuedRespawn )
	{
		doSpawnQueueUpdates();
	}
	
	if ( doDeadEventUpdates() )
		return;
		
	if ( doOneLeftEventUpdates() )
		return;
}


matchStartTimer() //checked does not match bo3 _globallogic.gsc did not change
{	
	visionSetNaked( "mpIntro", 0 );

	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;

	waitForPlayers();
	matchStartText setText( game["strings"]["match_starting_in"] );

	matchStartTimer = createServerFontString( "objective", 2.2 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer.sort = 1001;
	matchStartTimer.color = (1,1,0);
	matchStartTimer.foreground = false;
	matchStartTimer.hidewheninmenu = true;
	
	
	//Since the scaling is disabled, we cant see the pulse effect by scaling. We need to change keep switching between 
	//some small and big font to get the pulse effect. This will be fixed when we have fixed set of different sizes fonts.
	
	//matchStartTimer maps\mp\gametypes\_hud::fontPulseInit();

	countTime = int( level.prematchPeriod );
	
	if ( countTime >= 2 )
	{
		while ( countTime > 0 && !level.gameEnded )
		{
			matchStartTimer setValue( countTime );
			//matchStartTimer thread maps\mp\gametypes\_hud::fontPulse( level );
			if ( countTime == 2 )
				visionSetNaked( GetDvar( "mapname" ), 3.0 );
			countTime--;
			foreach(player in level.players)
			{
				player playlocalsound("uin_start_count_down");
			}
			wait ( 1.0 );
		}
	}
	else
	{
		visionSetNaked( GetDvar( "mapname" ), 1.0 );
	}

	matchStartTimer destroyElem();
	matchStartText destroyElem();
}

matchStartTimerSkip() //checked does not match bo3 _globallogic.gsc did not change
{
	if ( !isPregame() )
		visionSetNaked( GetDvar( "mapname" ), 0 );
	else
		visionSetNaked( "mpIntro", 0 );
}

notifyTeamWaveSpawn( team, time ) //checked matches bo3 _globallogic.gsc within reason
{
	if ( time - level.lastWave[team] > (level.waveDelay[team] * 1000) )
	{
		level notify ( "wave_respawn_" + team );
		level.lastWave[team] = time;
		level.wavePlayerSpawnIndex[team] = 0;
	}
}

waveSpawnTimer() //checked matches bo3 _globallogic.gsc within reason
{
	level endon( "game_ended" );

	while ( game["state"] == "playing" )
	{
		time = getTime();
		
		foreach( team in level.teams )
		{
			notifyTeamWaveSpawn( team, time );
		}
		wait ( 0.05 );
	}
}


hostIdledOut() //checked matches bo3 _globallogic.gsc within reason
{
	hostPlayer = getHostPlayer();
	/*
/#
	if( GetDvarint( "scr_writeconfigstrings" ) == 1  || GetDvarint( "scr_hostmigrationtest" ) == 1 )
		return false;
#/
	*/
	// host never spawned
	if ( isDefined( hostPlayer ) && !hostPlayer.hasSpawned && !isDefined( hostPlayer.selectedClass ) )
		return true;

	return false;
}

IncrementMatchCompletionStat( gameMode, playedOrHosted, stat ) //checked matches bo3 _globallogic.gsc within reason
{
	self AddDStat( "gameHistory", gameMode, "modeHistory", playedOrHosted, stat, 1 );
}

SetMatchCompletionStat( gameMode, playedOrHosted, stat ) //checked matches bo3 _globallogic.gsc within reason
{
	self SetDStat( "gameHistory", gameMode, "modeHistory", playedOrHosted, stat, 1 );
}

GetCurrentGameMode() //checked does not exist in bo3 _globallogic.gsc
{
	if( GameModeIsMode( level.GAMEMODE_LEAGUE_MATCH ) )
		return "leaguematch";
		
	return "publicmatch";
}

getteamscoreratio()
{
	playerteam = self.pers["team"];
	score = getteamscore(playerteam);
	otherteamscore = 0;
	foreach(team in level.teams)
	{
		if(team == playerteam)
		{
		}
		else 
		{
			otherteamscore = otherteamscore + getteamscore(team);
		}
	}
	if(level.teams.size > 1)
	{
		otherteamscore = otherteamscore / level.teams.size - 1;
	}
	if(otherteamscore != 0)
	{
		return float(score) / float(otherteamscore);
	}
	return score;
}

gethighestscore()
{
	highestscore = -999999999;
	for(index = 0; index < level.players.size; index++)
	{
		player = level.players[index];
		if(player.score > highestscore)
		{
			highestscore = player.score;
		}
	}
	return highestscore;
}

getnexthighestscore(score)
{
	highestscore = -999999999;
	for(index = 0; index < level.players.size; index++)
	{
		player = level.players[index];
		if(player.score >= score)
		{
		}
		else 
		{
			if(player.score > highestscore)
			{
				highestscore = player.score;
			}
		}
	}
	return highestscore;
}

sendAfterActionReport() //checked matches bo3 _globallogic.gsc within reason
{
	/*
/#
	if( GetDvarint( "scr_writeconfigstrings" ) == 1 )
		return;
#/
	*/
	if ( !level.onlineGame )
	{
		return;
	}

	if( isPregame() )
		return;

	if ( SessionModeIsZombiesGame() )
	{
		return;
	}
		
	//Send After Action Report information to the client
	index = 0;
	while ( index < level.players.size )
	{
		player = level.players[index];

		if ( player is_bot() )
		{
			index++;
			continue;
		}
		
		//Find the Nemesis for each player
		nemesis = player.pers["nemesis_name"];

		if( !isDefined( player.pers["killed_players"][nemesis] ) )
			player.pers["killed_players"][nemesis] = 0;
		if( !isDefined( player.pers["killed_by"][nemesis] ) )
			player.pers["killed_by"][nemesis] = 0;

		//Get the kill to death spread of the player
		spread = player.kills - player.deaths;
		
		if( player.pers["cur_kill_streak"] > player.pers["best_kill_streak"] )
			player.pers["best_kill_streak"] = player.pers["cur_kill_streak"];	
	
		if ( level.rankedMatch || level.wagerMatch || level.leagueMatch )	
			player maps\mp\gametypes\_persistence::setAfterActionReportStat( "privateMatch", 0 );
		else
			player maps\mp\gametypes\_persistence::setAfterActionReportStat( "privateMatch", 1 );

		player setNemesisXuid( player.pers["nemesis_xuid"] );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "nemesisName", nemesis );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "nemesisRank", player.pers["nemesis_rank"] );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "nemesisRankIcon", player.pers["nemesis_rankIcon"] );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "nemesisKills", player.pers["killed_players"][nemesis] );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "nemesisKilledBy", player.pers["killed_by"][nemesis] );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "bestKillstreak", player.pers["best_kill_streak"] );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "kills", player.kills );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "deaths", player.deaths );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "headshots", player.headshots );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "score", player.score );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "xpEarned", int( player.pers["summary"]["xp"] ) );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "cpEarned", int( player.pers["summary"]["codpoints"] ) );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "miscBonus", int( player.pers["summary"]["challenge"] + player.pers["summary"]["misc"] ) );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "matchBonus", int( player.pers["summary"]["match"] ) );
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "demoFileID", getDemoFileID() );
		player maps\mp\gametypes\_persistence::setafteractionreportstat("leagueTeamID", player getleagueteamid());
	
		teamscoreratio = player getteamscoreratio();
		scoreboardposition = getplacementforplayer(player);
		if(scoreboardposition < 0)
		{
			scoreboardposition = level.players.size;
		}
		player gamehistoryfinishmatch(4, player.kills, player.deaths, player.score, scoreboardposition, teamscoreratio);

		placement = level.placement["all"];			
		for ( otherPlayerIndex = 0; otherPlayerIndex < placement.size; otherPlayerIndex++ )
		{
			if ( level.placement["all"][otherPlayerIndex] == player )
			{
				recordPlayerStats( player, "position", otherPlayerIndex );				
			}				
		}
		
		if ( level.wagerMatch )
		{
			recordPlayerStats( player, "wagerPayout", player.wagerWinnings );
			player maps\mp\gametypes\_wager::setWagerAfterActionReportStats();
			player maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerMatch", 1 );
		}
		else
		{
			player maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerMatch", 0 );
		}
		player maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerMatchFailed", 0 );

		if ( level.rankedMatch || level.wagerMatch || level.leagueMatch )	
			player maps\mp\gametypes\_persistence::setAfterActionReportStat( "valid", 1 );
			
		if ( IsDefined( player.pers["matchesPlayedStatsTracked"] ) )
		{
			gameMode = GetCurrentGameMode();
			
			player IncrementMatchCompletionStat( gameMode, "played", "completed" );
				
			if ( IsDefined( player.pers["matchesHostedStatsTracked"] ) )
			{
				player IncrementMatchCompletionStat( gameMode, "hosted", "completed" );
				player.pers["matchesHostedStatsTracked"] = undefined;
			}
			
			player.pers["matchesPlayedStatsTracked"] = undefined;
		}

		recordPlayerStats( player, "highestKillStreak", player.pers["best_kill_streak"] );
		recordPlayerStats( player, "numUavCalled", player maps\mp\killstreaks\_killstreaks::getKillstreakUsage("uav_used") );
		recordPlayerStats( player, "numDogsCalled", player maps\mp\killstreaks\_killstreaks::getKillstreakUsage("dogs_used") );
		recordPlayerStats( player, "numDogsKills", player.pers["dog_kills"] );
		
		recordPlayerMatchEnd( player );
		RecordPlayerStats(player, "presentAtEnd", 1 );
		index++;
	}
}

gamehistoryplayerkicked()
{
	teamscoreratio = self getteamscoreratio();
	scoreboardposition = getplacementforplayer(self);
	if(scoreboardposition < 0)
	{
		scoreboardposition = level.players.size;
	}
	/*
	/#
		/#
			assert(isdefined(self.kills));
		#/
		/#
			assert(isdefined(self.deaths));
		#/
		/#
			assert(isdefined(self.score));
		#/
		/#
			assert(isdefined(scoreboardposition));
		#/
		/#
			assert(isdefined(teamscoreratio));
		#/
	#/
	*/
	self gamehistoryfinishmatch(2, self.kills, self.deaths, self.score, scoreboardposition, teamscoreratio);
	if(isdefined(self.pers["matchesPlayedStatsTracked"]))
	{
		gamemode = getcurrentgamemode();
		self incrementmatchcompletionstat(gamemode, "played", "kicked");
		self.pers["matchesPlayedStatsTracked"] = undefined;
	}
	uploadstats(self);
	wait(1);
}

gamehistoryplayerquit()
{
	teamscoreratio = self getteamscoreratio();
	scoreboardposition = getplacementforplayer(self);
	if(scoreboardposition < 0)
	{
		scoreboardposition = level.players.size;
	}
	self gamehistoryfinishmatch(3, self.kills, self.deaths, self.score, scoreboardposition, teamscoreratio);
	if(isdefined(self.pers["matchesPlayedStatsTracked"]))
	{
		gamemode = getcurrentgamemode();
		self incrementmatchcompletionstat(gamemode, "played", "quit");
		if(isdefined(self.pers["matchesHostedStatsTracked"]))
		{
			self incrementmatchcompletionstat(gamemode, "hosted", "quit");
			self.pers["matchesHostedStatsTracked"] = undefined;
		}
		self.pers["matchesPlayedStatsTracked"] = undefined;
	}
	uploadstats(self);
	if(!self ishost())
	{
		wait(1);
	}
}

displayRoundEnd( winner, endReasonText ) //checked matches bo3 _globallogic.gsc within reason
{
	if ( level.displayRoundEndText )
	{
		if(level.teambased)
		{
			if ( winner == "tie" )
			{
				maps\mp\_demo::gameResultBookmark( "round_result", level.teamIndex[ "neutral" ], level.teamIndex[ "neutral" ] );
			}
			else
			{
				maps\mp\_demo::gameResultBookmark( "round_result", level.teamIndex[ winner ], level.teamIndex[ "neutral" ] );
			}
		}
		setmatchflag( "cg_drawSpectatorMessages", 0 );
		players = level.players;
		index = 0;
		while ( index < players.size )
		{
			player = players[index];
			if(!waslastround())
			{
				player notify("round_ended");
			}
			if ( !isDefined( player.pers["team"] ) )
			{
				player [[level.spawnIntermission]]( true );
				player closeMenu();
				player closeInGameMenu();
				index++;
				continue;
			}
			
			if ( level.wagerMatch )
			{
				if ( level.teamBased )
					player thread [[level.onTeamWagerOutcomeNotify]]( winner, true, endReasonText );
				else
					player thread [[level.onWagerOutcomeNotify]]( winner, endReasonText );
			}
			else
			{
				if ( level.teamBased )
				{
					player thread [[level.onTeamOutcomeNotify]]( winner, true, endReasonText );
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "ROUND_END" );		
				}
				else
				{
					player thread [[level.onOutcomeNotify]]( winner, true, endReasonText );
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "ROUND_END" );
				}
			}
	
     		player setClientUIVisibilityFlag( "hud_visible", 0 );
			player setClientUIVisibilityFlag( "g_compassShowEnemies", 0 );
			index++;
		}
	}

	if ( wasLastRound() )
	{
		roundEndWait( level.roundEndDelay, false );
	}
	else
	{
		thread maps\mp\gametypes\_globallogic_audio::announceRoundWinner( winner, level.roundEndDelay / 4 );
		roundEndWait( level.roundEndDelay, true );
	}
}

displayRoundSwitch( winner, endReasonText ) //checked matches bo3 _globallogic.gsc within reason
{
	switchType = level.halftimeType;
	if ( switchType == "halftime" )
	{
		if ( is_true( level.nextRoundIsOvertime ) )
		{
			switchType = "overtime";
		}
		else
		{
			if ( level.roundLimit )
			{
				if ( (game["roundsplayed"] * 2) == level.roundLimit )
					switchType = "halftime";
				else
					switchType = "intermission";
			}
			else if ( level.scoreLimit )
			{
				if ( game["roundsplayed"] == (level.scoreLimit - 1) )
					switchType = "halftime";
				else
					switchType = "intermission";
			}
			else
			{
				switchType = "intermission";
			}
		}
	}
	
	leaderdialog = maps\mp\gametypes\_globallogic_audio::getRoundSwitchDialog( switchType );
	
	SetMatchTalkFlag( "EveryoneHearsEveryone", 1 );

	players = level.players;
	index = 0;
	while ( index < players.size )
	{
		player = players[index];
		
		if ( !isDefined( player.pers["team"] ) )
		{
			player [[level.spawnIntermission]]( true );
			player closeMenu();
			player closeInGameMenu();
			index++;
			continue;
		}
		
		player maps\mp\gametypes\_globallogic_audio::leaderDialogOnPlayer( leaderdialog );
		player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "ROUND_SWITCH" );
		
		if ( level.wagerMatch )
			player thread [[level.onTeamWagerOutcomeNotify]]( switchType, true, level.halftimeSubCaption );
		else
			player thread [[level.onTeamOutcomeNotify]]( switchType, false, level.halftimeSubCaption );
        player setClientUIVisibilityFlag( "hud_visible", 0 );
        index++;
	}

	roundEndWait( level.halftimeRoundEndDelay, false );
}

displayGameEnd( winner, endReasonText ) //checked matches bo3 _globallogic.gsc within reason
{
	SetMatchTalkFlag( "EveryoneHearsEveryone", 1 );
	setmatchflag( "cg_drawSpectatorMessages", 0 );

	if ( level.teambased )
	{
		if ( winner == "tie" )
		{
			maps\mp\_demo::gameResultBookmark( "game_result", level.teamIndex[ "neutral" ], level.teamIndex[ "neutral" ] );
		}
		else
		{ 
			maps\mp\_demo::gameResultBookmark( "game_result", level.teamIndex[ winner ], level.teamIndex[ "neutral" ] );
		}
	}
	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	players = level.players;
	index = 0;
	while ( index < players.size )
	{
		player = players[index];
	
		if ( !isDefined( player.pers["team"] ) )
		{
			player [[level.spawnIntermission]]( true );
			player closeMenu();
			player closeInGameMenu();
			index++;
			continue;
		}
		
		if ( level.wagerMatch )
		{
			if ( level.teamBased )
				player thread [[level.onTeamWagerOutcomeNotify]]( winner, false, endReasonText );
			else
				player thread [[level.onWagerOutcomeNotify]]( winner, endReasonText );
		}
		else
		{
			if ( level.teamBased )
			{
				player thread [[level.onTeamOutcomeNotify]]( winner, false, endReasonText );
			}
			else
			{
				player thread [[level.onOutcomeNotify]]( winner, false, endReasonText );
				
				if ( isDefined( winner ) && player == winner )
				{
					music = game["music"]["victory_" + player.team];
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( music );
				}
				else if ( !level.splitScreen )
				{
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "LOSE" );
				}
			}
		}
		
    	player setClientUIVisibilityFlag( "hud_visible", 0 );
		player setClientUIVisibilityFlag( "g_compassShowEnemies", 0 );
		index++;
	}
	
	if ( level.teamBased )
	{
		thread maps\mp\gametypes\_globallogic_audio::announceGameWinner( winner, level.postRoundTime / 2 );

		players = level.players;
		for ( index = 0; index < players.size; index++ )
		{
			player = players[index];
			team = player.pers["team"];
	
			if ( level.splitscreen )
			{
				if ( winner == "tie" )
				{
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "DRAW" );
				}						
				else if ( winner == team )
				{	
					music = game["music"]["victory_" + player.team];
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( music );			
				}
				else
				{
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "LOSE" );	
				}	
			}
			else
			{
				if ( winner == "tie" )
				{
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "DRAW" );
				}				
				else if ( winner == team )
				{
					music = game["music"]["victory_" + player.team];
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( music );
				}
				else
				{
					player maps\mp\gametypes\_globallogic_audio::set_music_on_player( "LOSE" );	
				}
			}
		}
	}
	
	bbPrint( "session_epilogs", "reason %s", endReasonText );

	// tagTMR<NOTE>: all round data aggregates that cannot be summed from other tables post-runtime
	bbPrint( "mpmatchfacts", "gametime %d winner %s killstreakcount %d", gettime(), winner, level.killstreak_counter );
	
	roundEndWait( level.postRoundTime, true );
}

getEndReasonText() //checked matches bo3 _globallogic.gsc within reason
{
	if ( IsDefined( level.endReasonText ) )
	{
		return level.endReasonText;
	}
	
	if ( hitRoundLimit() || hitRoundWinLimit() )
		return  game["strings"]["round_limit_reached"];
	else if ( hitScoreLimit() )
		return  game["strings"]["score_limit_reached"];

	if ( level.forcedEnd )
	{
		if ( level.hostForcedEnd )
			return &"MP_HOST_ENDED_GAME";
		else
			return &"MP_ENDED_GAME";
	}
	return game["strings"]["time_limit_reached"];
}

resetOutcomeForAllPlayers() //checked matches bo3 _globallogic.gsc within reason
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player notify ( "reset_outcome" );
	}
}

startNextRound( winner,	endReasonText ) //checked matches bo3 _globallogic.gsc within reason
{
	if ( !isOneRound() )
	{
		displayRoundEnd( winner, endReasonText );

		maps\mp\gametypes\_globallogic_utils::executePostRoundEvents();
		
		if ( !wasLastRound() )
		{
			if ( checkRoundSwitch() )
			{
				displayRoundSwitch( winner, endReasonText );
			}
			
			if ( is_true( level.nextRoundIsOvertime ) )
			{
				if ( !IsDefined( game["overtime_round"] ) )
				{
					game["overtime_round"] = 1;
				}
				else
				{
					game["overtime_round"]++;
				}
			}

			SetMatchTalkFlag( "DeadChatWithDead", level.voip.deadChatWithDead );
			SetMatchTalkFlag( "DeadChatWithTeam", level.voip.deadChatWithTeam );
			SetMatchTalkFlag( "DeadHearTeamLiving", level.voip.deadHearTeamLiving );
			SetMatchTalkFlag( "DeadHearAllLiving", level.voip.deadHearAllLiving );
			SetMatchTalkFlag( "EveryoneHearsEveryone", level.voip.everyoneHearsEveryone );
			SetMatchTalkFlag( "DeadHearKiller", level.voip.deadHearKiller );
			SetMatchTalkFlag( "KillersHearVictim", level.voip.killersHearVictim );
				
			game["state"] = "playing";
			level.allowBattleChatter = GetGametypeSetting( "allowBattleChatter" );
			map_restart( true );
			return true;
		}
	}
	return false;
}

	
settopplayerstats()
{
	if(level.rankedmatch || level.wagermatch)
	{
		placement = level.placement["all"];
		topthreeplayers = min(3, placement.size);
		for(index = 0; index < topthreeplayers; index++)
		{
			if(level.placement["all"][index].score)
			{
				if(!index)
				{
					level.placement["all"][index] addplayerstatwithgametype("TOPPLAYER", 1);
					level.placement["all"][index] notify("topplayer");
				}
				else
				{
					level.placement["all"][index] notify("nottopplayer");
				}
				level.placement["all"][index] addplayerstatwithgametype("TOP3", 1);
				level.placement["all"][index] addplayerstat("TOP3ANY", 1);
				if(level.hardcoremode)
				{
					level.placement["all"][index] addplayerstat("TOP3ANY_HC", 1);
				}
				if(level.multiteam)
				{
					level.placement["all"][index] addplayerstat("TOP3ANY_MULTITEAM", 1);
				}
				level.placement["all"][index] notify("top3");
			}
		}
		for(index = 3; index < placement.size; index++)
		{
			level.placement["all"][index] notify("nottop3");
			level.placement["all"][index] notify("nottopplayer");
		}
		if(level.teambased)
		{
			foreach(team in level.teams)
			{
				settopteamstats(team);
			}
		}
	}
}

settopteamstats(team)
{
	placementteam = level.placement[team];
	topthreeteamplayers = min(3, placementteam.size);
	if(placementteam.size < 5)
	{
		return;
	}
	for(index = 0; index < topthreeteamplayers; index++)
	{
		if(placementteam[index].score)
		{
			placementteam[index] addplayerstat("TOP3TEAM", 1);
			placementteam[index] addplayerstat("TOP3ANY", 1);
			if(level.hardcoremode)
			{
				placementteam[index] addplayerstat("TOP3ANY_HC", 1);
			}
			if(level.multiteam)
			{
				placementteam[index] addplayerstat("TOP3ANY_MULTITEAM", 1);
			}
			placementteam[index] addplayerstatwithgametype("TOP3TEAM", 1);
		}
	}
}

getGameLength() //checked does not exist in bo3 _globallogic.gsc
{
	if ( !level.timeLimit || level.forcedEnd )
	{
		gameLength = maps\mp\gametypes\_globallogic_utils::getTimePassed() / 1000;		
		// cap it at 20 minutes to avoid exploiting
		gameLength = min( gameLength, 1200 );
	}
	else
	{
		gameLength = level.timeLimit * 60;
	}
	
	return gameLength;
}

endGame( winner, endReasonText ) //checked matches bo3 _globallogic.gsc within reason
{
	// return if already ending via host quit or victory
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	if ( isDefined( level.onEndGame ) )
		[[level.onEndGame]]( winner );

	//This wait was added possibly for wager match issues, but we think is no longer necessary. 
	//It was creating issues with multiple players calling this fuction when checking game score. In modes like HQ,
	//The game score is given to every player on the team that captured the HQ, so when the points are dished out it loops through
	//all players on that team and checks if the score limit has been reached. But since this wait occured before the game["state"]
	//could be set to "postgame" the check score thread would send the next player that reached the score limit into this function,
	//when the following code should only be hit once. If this wait turns out to be needed, we need to try pulling the game["state"] = "postgame";
	//up above the wait.
	//wait 0.05;
	
	if ( !level.wagerMatch )
		setMatchFlag( "enable_popups", 0 );
	if ( !isdefined( level.disableOutroVisionSet ) || level.disableOutroVisionSet == false ) 
	{
		if ( SessionModeIsZombiesGame() && level.forcedEnd )
		{
			visionSetNaked( "zombie_last_stand", 2.0 );
		}
		else
		{
			visionSetNaked( "mpOutro", 2.0 );
		}
	}
	
	setmatchflag( "cg_drawSpectatorMessages", 0 );
	setmatchflag( "game_ended", 1 );

	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	SetDvar( "g_gameEnded", 1 );
	level.inGracePeriod = false;
	level notify ( "game_ended" );
	level.allowBattleChatter = false;
	maps\mp\gametypes\_globallogic_audio::flushDialog();
	foreach(team in level.teams)
	{
		game["lastroundscore"][team] = getteamscore(team);
	}
	if ( !IsDefined( game["overtime_round"] ) || wasLastRound() ) // Want to treat all overtime rounds as a single round
	{
		game["roundsplayed"]++;
		game["roundwinner"][game["roundsplayed"]] = winner;
	
		//Added "if" check for FFA - Leif
		if( level.teambased )
		{
			game["roundswon"][winner]++;	
		}
	}

	if ( isdefined( winner ) && level.teambased && isdefined( level.teams[winner] ) )
	{
		level.finalKillCam_winner = winner;
	}
	else
	{
		level.finalKillCam_winner = "none";
	}
	
	setGameEndTime( 0 ); // stop/hide the timers
	
	updatePlacement();

	updateRankedMatch( winner );
	
	// freeze players
	players = level.players;
	
	newTime = getTime();
	gameLength = getGameLength();
	
	SetMatchTalkFlag( "EveryoneHearsEveryone", 1 );

	bbGameOver = 0;
	if ( isOneRound() || wasLastRound() )
	{
		bbGameOver = 1;
	}
	index = 0;
	while ( index < players.size )
	{
		player = players[index];
		player maps\mp\gametypes\_globallogic_player::freezePlayerForRoundEnd();
		player thread roundEndDoF( 4.0 );

		player maps\mp\gametypes\_globallogic_ui::freeGameplayHudElems();
		
		// Update weapon usage stats
		player maps\mp\gametypes\_weapons::updateWeaponTimings( newTime );
		
		player bbPlayerMatchEnd( gameLength, endReasonText, bbGameOver );

		if( isPregame() )
			index++;
			continue;

		if( level.rankedMatch || level.wagerMatch || level.leagueMatch && !player IsSplitscreen() )
		{
			if ( isDefined( player.setPromotion ) )
				player setDStat( "AfterActionReportStats", "lobbyPopup", "promotion" );
			else
				player setDStat( "AfterActionReportStats", "lobbyPopup", "summary" );
		}
		index++;
	}

	maps\mp\_music::setmusicstate( "SILENT" );
	maps\mp\_gamerep::gameRepUpdateInformationForRound();
	maps\mp\gametypes\_wager::finalizeWagerRound();
	maps\mp\gametypes\_gametype_variants::onRoundEnd();
	thread maps\mp\_challenges::roundEnd( winner );

	if ( startNextRound( winner, endReasonText ) )
	{
		return;
	}
	
	///////////////////////////////////////////
	// After this the match is really ending //
	///////////////////////////////////////////

	if ( !isOneRound() && !level.gameforfeited )
	{
		if ( isDefined( level.onRoundEndGame ) )
			winner = [[level.onRoundEndGame]]( winner );

		endReasonText = getEndReasonText();
	}
	if(!level.wagermatch && !sessionmodeiszombiesgame())
	{
		maps/mp/gametypes/_globallogic_score::updatewinlossstats(winner);
	}
	if(level.teambased)
	{
		if(winner == "tie")
		{
			recordgameresult("draw");
		}
		else
		{
			recordgameresult(winner);
		}
	}
	else if(!isdefined(winner))
	{
		recordgameresult("draw");
	}
	else
	{
		recordgameresult(winner.team);
	}
	skillUpdate( winner, level.teamBased );
	recordLeagueWinner( winner );
	
	setTopPlayerStats();
	thread maps\mp\_challenges::gameEnd( winner );

	if ( IsDefined( winner ) && !isDefined( level.skipGameEnd ) || !level.skipGameEnd )
	{
		if(isdefined(level.preendgamefunction))
		{
			thread [[level.preendgamefunction]](level.postroundtime);
		}
		displayGameEnd( winner, endReasonText );
	}
	if ( isOneRound() )
	{
		maps\mp\gametypes\_globallogic_utils::executePostRoundEvents();
	}
		
	level.intermission = true;

	maps\mp\_gamerep::gameRepAnalyzeAndReport();
	
	if( !isPregame() )
		thread sendAfterActionReport();
	maps\mp\gametypes\_wager::finalizeWagerGame();
	
	SetMatchTalkFlag( "EveryoneHearsEveryone", 1 );

	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		recordPlayerStats( player, "presentAtEnd", 1 );

		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome", level.infinalkillcam );
		player thread [[level.spawnIntermission]]();
        player setClientUIVisibilityFlag( "hud_visible", 1 );
	}
	if(isdefined(level.endgamefunction))
	{
		level thread [[level.endgamefunction]]();
	}
	//Eckert - Fading out sound
	level notify ( "sfade");
	logString( "game ended" );
	
	if ( !isDefined( level.skipGameEnd ) || !level.skipGameEnd )
		wait 5.0;
	
	exitLevel( false );

}

bbPlayerMatchEnd( gameLength, endReasonString, gameOver ) // self == player //checked does not exist in bo3 _globallogic.gsc leaving in
{		 
	playerRank = getPlacementForPlayer( self );
	
	totalTimePlayed = 0;
	if ( isDefined( self.timePlayed ) && isDefined( self.timePlayed["total"] ) )
	{
		totalTimePlayed = self.timePlayed["total"];
		if ( totalTimePlayed > gameLength )
		{
			totalTimePlayed = gameLength;
		}
	}

	xuid = self GetXUID();

	bbPrint( "mpplayermatchfacts", "score %d momentum %d endreason %s sessionrank %d playtime %d xuid %s gameover %d team %s",
		self.pers["score"],
		self.pers["momentum"],
		endReasonString,
		playerRank,
		totalTimePlayed,
		xuid,
		gameOver,
		self.pers["team"] );
}

roundEndWait( defaultDelay, matchBonus ) //checked matches bo3 _globallogic.gsc within reason
{
	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		index = 0;
		while ( index < players.size )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				index++;
				continue;
				
			notifiesDone = false;
			index++;
		}
		wait ( 0.5 );
	}

	if ( !matchBonus )
	{
		wait ( defaultDelay );
		level notify ( "round_end_done" );
		return;
	}

  wait ( defaultDelay / 2 );
	level notify ( "give_match_bonus" );
	wait ( defaultDelay / 2 );

	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		index = 0;
		while ( index < players.size )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				index++;
				continue;
				
			notifiesDone = false;
			index++;
		}
		wait ( 0.5 );
	}
	
	level notify ( "round_end_done" );
}


roundEndDOF( time ) //checked matches bo3 _globallogic.gsc within reason
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


checkTimeLimit() //checked matches bo3 _globallogic.gsc within reason
{
	if ( is_true( level.timeLimitOverride ) )
		return;
	
	if ( game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}
		
	if ( level.timeLimit <= 0 )
	{
		setGameEndTime( 0 );
		return;
	}
		
	if ( level.inPrematchPeriod )
	{
		setGameEndTime( 0 );
		return;
	}
	
	if ( level.timerStopped )
	{
		setGameEndTime( 0 );
		return;
	}
	
	if ( !isdefined( level.startTime ) )
		return;
	
	timeLeft = maps\mp\gametypes\_globallogic_utils::getTimeRemaining();
	
	// want this accurate to the millisecond
	setGameEndTime( getTime() + int(timeLeft) );
	
	if ( timeLeft > 0 )
		return;
	
	[[level.onTimeLimit]]();
}

allTeamsUnderScoreLimit() //checked does not exist in bo3 _globallogic.gsc leaving in
{
	foreach ( team in level.teams )
	{
		if ( game["teamScores"][team] >= level.scoreLimit )
			return false;
	}
	
	return true;
}

checkScoreLimit() //checked matches bo3 _globallogic.gsc within reason
{
	if ( game["state"] != "playing" )
		return false;

	if ( level.scoreLimit <= 0 )
		return false;

	if ( level.teamBased )
	{
		if( allTeamsUnderScoreLimit() )
			return false;
	}
	else
	{
		if ( !isPlayer( self ) )
			return false;

		if ( self.score < level.scoreLimit )
			return false;
	}

	[[level.onScoreLimit]]();
}


updateGameTypeDvars() //checked matches bo3 _globallogic.gsc within reason
{
	level endon ( "game_ended" );
	
	while ( game["state"] == "playing" )
	{
		roundlimit = clamp( GetGametypeSetting( "roundLimit" ), level.roundLimitMin, level.roundLimitMax );
		if ( roundlimit != level.roundlimit )
		{
			level.roundlimit = roundlimit;
			level notify ( "update_roundlimit" );
		}

		timeLimit = [[level.getTimeLimit]]();
		if ( timeLimit != level.timeLimit )
		{
			level.timeLimit = timeLimit;
			SetDvar( "ui_timelimit", level.timeLimit );
			level notify ( "update_timelimit" );
		}
		thread checkTimeLimit();

		scoreLimit = clamp( GetGametypeSetting( "scoreLimit" ), level.scoreLimitMin, level.scoreLimitMax );
		if ( scoreLimit != level.scoreLimit )
		{
			level.scoreLimit = scoreLimit;
			SetDvar( "ui_scorelimit", level.scoreLimit );
			level notify ( "update_scorelimit" );
		}
		thread checkScoreLimit();
		
		// make sure we check time limit right when game ends
		if ( isdefined( level.startTime ) )
		{
			if ( maps\mp\gametypes\_globallogic_utils::getTimeRemaining() < 3000 )
			{
				wait .1;
				continue;
			}
		}
		wait 1;
	}
}


removeDisconnectedPlayerFromPlacement() //checked matches bo3 _globallogic.gsc within reason
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
			found = true;
		
		if ( found )
			level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
		return;
	
	level.placement["all"][ numPlayers - 1 ] = undefined;
	assert( level.placement["all"].size == numPlayers - 1 );
		/*
	/#
	maps\mp\gametypes\_globallogic_utils::assertProperPlacement();
	#/
		*/
	updateTeamPlacement();
	
	if ( level.teamBased )
		return;
		
	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}
	
}

updatePlacement() //checked matches bo3 _globallogic.gsc within reason
{
	
	if ( !level.players.size )
		return;

	level.placement["all"] = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( isdefined( level.teams[ level.players[index].team ] ) )
			level.placement["all"][level.placement["all"].size] = level.players[index];
	}
		
	placementAll = level.placement["all"];
	if(level.teambased)
	{
		for ( i = 1; i < placementAll.size; i++ )
		{
			player = placementAll[ i ];
			playerScore = player.score;
			for ( j = i - 1; j >= 0 && playerScore > placementAll[j].score || playerScore == placementAll[j].score && player.deaths < placementAll[j].deaths ; j-- )
			{
				placementAll[ j + 1 ] = placementAll[ j ];
			}
			placementAll[ j + 1 ] = player;
		}
	}
	else 
	{
		for(i = 1; i < placementall.size; i++)
		{
			player = placementall[i];
			playerscore = player.pointstowin;
			for(j = i - 1; j >= 0 && playerscore > placementall[j].pointstowin || playerscore == placementall[j].pointstowin && player.deaths < placementall[j].deaths; j--)
			{
				placementall[j + 1] = placementall[j];
			}
			placementall[j + 1] = player;
		}
	}
	level.placement["all"] = placementAll;
		/*
	/#
	maps\mp\gametypes\_globallogic_utils::assertProperPlacement();
	#/
		*/
	updateTeamPlacement();

}	


updateTeamPlacement() //checked matches bo3 _globallogic.gsc within reason
{
	foreach( team in level.teams )
	{
		placement[team]    = [];
	}
	placement["spectator"] = [];
	
	if ( !level.teamBased )
		return;
	
	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;
	
	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];
		
		placement[team][ placement[team].size ] = player;
	}
	
	foreach( team in level.teams )
	{
		level.placement[team] = placement[team];
	}
}

getPlacementForPlayer( player ) //checked matches bo3 _globallogic.gsc within reason
{
	updatePlacement();

	playerRank = -1;
	placement = level.placement["all"];
	for ( placementIndex = 0; placementIndex < placement.size; placementIndex++ )
	{
		if ( level.placement["all"][placementIndex] == player )
		{
			playerRank = (placementIndex + 1);
			break;
		}				
	}

	return playerRank;
}

sortDeadPlayers( team ) //checked matches bo3 _globallogic.gsc within reason
{
	// only need to sort if we are running queued respawn
	if ( !level.playerQueuedRespawn )
		return;
		
	// sort by death time
	for ( i = 1; i < level.deadPlayers[team].size; i++ )
	{
		player = level.deadPlayers[team][i];
		for ( j = i - 1; j >= 0 && player.deathTime < level.deadPlayers[team][j].deathTime; j-- )
			level.deadPlayers[team][j + 1] = level.deadPlayers[team][j];
		level.deadPlayers[team][j + 1] = player;
	}
	
	for ( i = 0; i < level.deadPlayers[team].size; i++ )
	{
		if ( level.deadPlayers[team][i].spawnQueueIndex != i )
		{
			level.spawnQueueModified[team] = true;
		}
		level.deadPlayers[team][i].spawnQueueIndex = i;
	}
}

istopscoringplayer(player)
{
	topplayer = 0;
	updateplacement();
	/#
		assert(level.placement["all"].size > 0);
	#/
	if(level.placement["all"].size == 0)
	{
		return 0;
	}
	if(level.teambased)
	{
		topscore = level.placement["all"][0].score;
		for(index = 0; index < level.placement["all"].size; index++)
		{
			if(level.placement["all"][index].score == 0)
			{
				break;
			}
			if(topscore > level.placement["all"][index].score)
			{
				break;
			}
			if(self == level.placement["all"][index])
			{
				topscoringplayer = 1;
				break;
			}
		}
	}
	else 
	{
		topscore = level.placement["all"][0].pointstowin;
		for(index = 0; index < level.placement["all"].size; index++)
		{
			if(level.placement["all"][index].pointstowin == 0)
			{
				break;
			}
			if(topscore > level.placement["all"][index].pointstowin)
			{
				break;
			}
			if(self == level.placement["all"][index])
			{
				topplayer = 1;
				break;
			}
		}
	}
	return topplayer;
}

totalAliveCount() //checked matches bo3 _globallogic.gsc within reason
{
	count = 0;
	foreach( team in level.teams )
	{
		count += level.aliveCount[team];
	}
	return count; 
}

totalPlayerLives() //checked matches bo3 _globallogic.gsc within reason
{
	count = 0;
	foreach( team in level.teams )
	{
		count += level.playerLives[team];
	}
	return count; 
}

totalPlayerCount() //checked does not exist in bo3 _globallogic.gsc
{
	count = 0;
	foreach( team in level.teams )
	{
		count += level.playerCount[team];
	}
	return count; 
}

initTeamVariables( team ) //checked matches bo3 _globallogic.gsc within reason
{
	
	if ( !isdefined( level.aliveCount ) )
		level.aliveCount = [];
	
	level.aliveCount[team] = 0;
	level.lastAliveCount[team] = 0;
	if(!isdefined(game["everExisted"]))
	{
		game["everExisted"] = [];
	}
	if(!isdefined(game["everExisted"][team]))
	{
		game["everExisted"][team] = 0;
	}
	level.everExisted[team] = false;
	level.waveDelay[team] = 0;
	level.lastWave[team] = 0;
	level.wavePlayerSpawnIndex[team] = 0;

	resetTeamVariables( team );
}

resetTeamVariables( team ) //checked matches bo3 _globallogic.gsc within reason
{
	level.playerCount[team] = 0;
	level.botsCount[team] = 0;
	level.lastAliveCount[team] = level.aliveCount[team];
	level.aliveCount[team] = 0;
	level.playerLives[team] = 0;
	level.alivePlayers[team] = [];
	level.deadPlayers[team] = [];
	level.squads[team] = [];
	level.spawnQueueModified[team] = false;
}

updateTeamStatus() //checked matches bo3 _globallogic.gsc within reason
{
	// run only once per frame, at the end of the frame.
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );
	waittillframeend;
	
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	if ( game["state"] == "postgame" )
		return;

	resetTimeout();
	
	foreach( team in level.teams )
	{
		resetTeamVariables( team );
	}
	
	level.activePlayers = [];

	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		player = players[i];
		
		if ( !isDefined( player ) && level.splitscreen )
			i++;
			continue;

		team = player.team;
		class = player.class;
		
		if ( team != "spectator" && isDefined( class ) && class != "" )
		{
			level.playerCount[team]++;
			
			if( isDefined( player.pers["isBot"] ) )
				level.botsCount[team]++;
			
			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;
				player.spawnQueueIndex = -1;
				
				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers[team].size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;
				}
				else
				{
					level.deadPlayers[team][level.deadPlayers[team].size] = player;
				}
			}
			else
			{
				level.deadPlayers[team][level.deadPlayers[team].size] = player;
				if ( player maps\mp\gametypes\_globallogic_spawn::maySpawn() )
					level.playerLives[team]++;
			}
		}
		i++;
	}
	
	totalAlive = totalAliveCount();
	
	if ( totalAlive > level.maxPlayerCount )
		level.maxPlayerCount = totalAlive;
	
	foreach( team in level.teams )
	{
		if ( level.aliveCount[team] )
			level.everExisted[team] = true;
	
		sortDeadPlayers( team );
	}

	level updateGameEvents();
}

checkTeamScoreLimitSoon( team ) //checked matches bo3 _globallogic.gsc within reason
{
	assert( IsDefined( team ) );
	
	if ( level.scoreLimit <= 0 )
		return;
		
	if ( !level.teamBased )
		return;
		
	// Give the data a minute to converge/settle
	if ( maps\mp\gametypes\_globallogic_utils::getTimePassed() < ( 60 * 1000 ) )
		return;
	
	timeLeft = maps\mp\gametypes\_globallogic_utils::getEstimatedTimeUntilScoreLimit( team );
	
	if ( timeLeft < 1 )
	{
		level notify( "match_ending_soon", "score" );
	}
}

checkPlayerScoreLimitSoon() //checked matches bo3 _globallogic.gsc within reason
{
	assert( IsPlayer( self ) );
	
	if ( level.scoreLimit <= 0 )
		return;
	
	if ( level.teamBased )
		return;
		
	// Give the data a minute to converge/settle
	if ( maps\mp\gametypes\_globallogic_utils::getTimePassed() < ( 60 * 1000 ) )
		return;
		
	timeLeft = maps\mp\gametypes\_globallogic_utils::getEstimatedTimeUntilScoreLimit( undefined );
	
	if ( timeLeft < 1 )
	{
		level notify( "match_ending_soon", "score" );
	}
}

timeLimitClock() //checked matches bo3 _globallogic.gsc within reason
{
	level endon ( "game_ended" );
	
	wait .05;
	
	clockObject = spawn( "script_origin", (0,0,0) );
	
	while ( game["state"] == "playing" )
	{
		if ( !level.timerStopped && level.timeLimit )
		{
			timeLeft = maps\mp\gametypes\_globallogic_utils::getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5); // adding .5 and flooring rounds it.
			
			if ( timeLeftInt == 601  )
				clientnotify ( "notify_10" );
			
			if ( timeLeftInt == 301  )
				clientnotify ( "notify_5" );
				
			if ( timeLeftInt == 60  )
				clientnotify ( "notify_1" );
				
			if ( timeLeftInt == 12 )
				clientnotify ( "notify_count" );
			
			if ( timeLeftInt >= 40 && timeLeftInt <= 60 )
				level notify ( "match_ending_soon", "time" );

			if ( timeLeftInt >= 30 && timeLeftInt <= 40 )
				level notify ( "match_ending_pretty_soon", "time" );
				
			if( timeLeftInt <= 32 )
			    level notify ( "match_ending_vox" );	

			if ( timeLeftInt <= 10 || timeLeftInt <= 30 && timeLeftInt % 2 == 0 )
			{
				level notify ( "match_ending_very_soon", "time" );
				// don't play a tick at exactly 0 seconds, that's when something should be happening!
				if ( timeLeftInt == 0 )
					break;
				
				clockObject playSound( "mpl_ui_timer_countdown" );
			}
			
			// synchronize to be exactly on the second
			if ( timeLeft - floor(timeLeft) >= .05 )
				wait timeLeft - floor(timeLeft);
		}

		wait ( 1.0 );
	}
}

timeLimitClock_Intermission( waitTime ) //checked matches bo3 _globallogic.gsc within reason
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );
	
	if ( waitTime >= 10.0 )
		wait ( waitTime - 10.0 );
		
	for ( ;; )
	{
		clockObject playSound( "mpl_ui_timer_countdown" );
		wait ( 1.0 );
	}	
}


startGame() //checked does not match bo3 _globallogic.gsc did not change
{
	thread maps\mp\gametypes\_globallogic_utils::gameTimer();
	level.timerStopped = false;
	// RF, disabled this, as it is not required anymore.
	//thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	SetMatchTalkFlag( "DeadChatWithDead", level.voip.deadChatWithDead );
	SetMatchTalkFlag( "DeadChatWithTeam", level.voip.deadChatWithTeam );
	SetMatchTalkFlag( "DeadHearTeamLiving", level.voip.deadHearTeamLiving );
	SetMatchTalkFlag( "DeadHearAllLiving", level.voip.deadHearAllLiving );
	SetMatchTalkFlag( "EveryoneHearsEveryone", level.voip.everyoneHearsEveryone );
	SetMatchTalkFlag( "DeadHearKiller", level.voip.deadHearKiller );
	SetMatchTalkFlag( "KillersHearVictim", level.voip.killersHearVictim );
	

	prematchPeriod();
	level notify("prematch_over");

	thread timeLimitClock();
	thread gracePeriod();
	thread watchMatchEndingSoon();

	thread maps\mp\gametypes\_globallogic_audio::musicController();
	recordMatchBegin();
}


waitForPlayers() //checked does not match bo3 _globallogic.gsc did not change
{
	starttime = GetTime();
	while ( GetNumConnectedPlayers() < 1 )
	{
		wait ( 0.05 );
		if(GetTime() - starttime > 120000)
		{
			exitlevel(0);
		}
	}
}	

prematchPeriod() //checked matches bo3 _globallogic.gsc within reason
{
	setMatchFlag( "hud_hardcore", level.hardcoreMode );

	level endon( "game_ended" );
	
	if ( level.prematchPeriod > 0 )
	{
		thread matchStartTimer();

		waitForPlayers();

		wait ( level.prematchPeriod );
	}
	else
	{
		matchStartTimerSkip();
		
		wait 0.05;
	}
	
	level.inPrematchPeriod = false;
	
	for ( index = 0; index < level.players.size; index++ )
	{		
		level.players[index] freeze_player_controls( false );
		level.players[index] enableWeapons();
	}
	
	maps\mp\gametypes\_wager::prematchPeriod();

	if ( game["state"] != "playing" )
		return;
}
	
gracePeriod() //checked matches bo3 _globallogic.gsc within reason
{
	level endon("game_ended");
	
	if ( IsDefined( level.gracePeriodFunc ) )
	{
		[[ level.gracePeriodFunc ]]();
	}
	else
	{
		wait ( level.gracePeriod );
	}
	
	level notify ( "grace_period_ending" );
	wait ( 0.05 );
	
	level.inGracePeriod = false;
	
	if ( game["state"] != "playing" )
		return;
	
	if ( level.numLives )
	{
		// Players on a team but without a weapon show as dead since they can not get in this round
		players = level.players;
		
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) )
				player.statusicon = "hud_status_dead";
		}
	}
	
	level thread updateTeamStatus();
}

watchMatchEndingSoon() //checked matches bo3 _globallogic.gsc within reason
{
	SetDvar( "xblive_matchEndingSoon", 0 );
	level waittill( "match_ending_soon", reason );
	SetDvar( "xblive_matchEndingSoon", 1 );
}

assertTeamVariables( ) //checked matches bo3 _globallogic.gsc within reason
{
	// these are defined in the teamset file
	if ( !level.createFX_enabled && !SessionModeIsZombiesGame() )
	{
		foreach ( team in level.teams ) 
		{
			/*
			Assert( IsDefined( game["strings"][ team + "_win"] ) );
			Assert( IsDefined( game["strings"][ team + "_win_round"] ) );
			Assert( IsDefined( game["strings"][ team + "_mission_accomplished"] ) );
			Assert( IsDefined( game["strings"][ team + "_eliminated"] ) );
			Assert( IsDefined( game["strings"][ team + "_forfeited"] ) );
			Assert( IsDefined( game["strings"][ team + "_name"] ) );
			Assert( IsDefined( game["music"]["spawn_" + team] ) );
			Assert( IsDefined( game["music"]["victory_" + team] ) );
			Assert( IsDefined( game["icons"][team] ) );
			Assert( IsDefined( game["voice"][team] ) );
			*/
		}
	}
}

anyTeamHasWaveDelay() //checked matches bo3 _globallogic.gsc within reason
{
	foreach ( team in level.teams )
	{
		if ( level.waveDelay[team] )
			return true;
	}
	
	return false;
}

Callback_StartGameType() //checked does not match bo3 _globallogic.gsc did not change
{
	level.prematchPeriod = 0;
	level.intermission = false;

	setmatchflag( "cg_drawSpectatorMessages", 1 );
	setmatchflag( "game_ended", 0 );
	
	if ( !isDefined( game["gamestarted"] ) )
	{
		// defaults if not defined in level script
		if ( !isDefined( game["allies"] ) )
			game["allies"] = "seals";
		if ( !isDefined( game["axis"] ) )
			game["axis"] = "pmc";
		if ( !isDefined( game["attackers"] ) )
			game["attackers"] = "allies";
		if (  !isDefined( game["defenders"] ) )
			game["defenders"] = "axis";

		// if this hits the teams are not setup right
		/*
		assert( game["attackers"] != game["defenders"] );
		*/
		// TODO MTEAM - need to update this valid team
		foreach( team in level.teams )
		{
			if ( !isDefined( game[team] ) )
				game[team] = "pmc";
		}

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";
	
		precacheStatusIcon( "hud_status_dead" );
		precacheStatusIcon( "hud_status_connecting" );
		
		precacheRumble( "damage_heavy" );
		precacheRumble( "damage_light" );

		precacheShader( "white" );
		precacheShader( "black" );
		
		makeDvarServerInfo( "scr_allies", "marines" );
		makeDvarServerInfo( "scr_axis", "nva" );
		
		makeDvarServerInfo( "cg_thirdPersonAngle", 354 );

		SetDvar( "cg_thirdPersonAngle", 354 );

		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
		if ( level.teamBased )
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_PLAYERS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
		game["strings"]["waiting_to_spawn_ss"] = &"MP_WAITING_TO_SPAWN_SS";
		game["strings"]["you_will_spawn"] = &"MP_YOU_WILL_RESPAWN";
		game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
		game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";
		game["strings"]["last_stand"] = &"MPUI_LAST_STAND";
		
		game["strings"]["cowards_way"] = &"PLATFORM_COWARDS_WAY_OUT";
		
		game["strings"]["tie"] = &"MP_MATCH_TIE";
		game["strings"]["round_draw"] = &"MP_ROUND_DRAW";

		game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";
		game["strings"]["other_teams_forfeited"] = &"MP_OTHER_TEAMS_FORFEITED";

		assertTeamVariables();

		[[level.onPrecacheGameType]]();

		game["gamestarted"] = true;
		
		game["totalKills"] = 0;

		foreach( team in level.teams )
		{
			game["teamScores"][team] = 0;
			game["totalKillsTeam"][team] = 0;
		}
		if(!ispregame())
		{
			level.prematchperiod = getgametypesetting("prematchperiod");
		}
		if ( GetDvarint( "xblive_clanmatch" ) != 0 )
		{
			// TODO MTEAM is this code used anymore?
			foreach( team in level.teams )
			{
				game["icons"][team] = "composite_emblem_team_axis";
			}
			
			game["icons"]["allies"] = "composite_emblem_team_allies";
			game["icons"]["axis"] = "composite_emblem_team_axis";
		}
	}

	if(!isdefined(game["timepassed"]))
		game["timepassed"] = 0;

	if(!isdefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;
	SetRoundsPlayed( game["roundsplayed"] );
	
	if ( IsDefined( game["overtime_round"] ) )
	{
		SetMatchFlag( "overtime", 1 );
	}
	else
	{
		SetMatchFlag( "overtime", 0 );
	}
	
	if(!isdefined(game["roundwinner"] ))
		game["roundwinner"] = [];

	if(!isdefined(game["roundswon"] ))
		game["roundswon"] = [];

	if(!isdefined(game["roundswon"]["tie"] ))
		game["roundswon"]["tie"] = 0;

	foreach ( team in level.teams )
	{
		if(!isdefined(game["roundswon"][team] ))
			game["roundswon"][team] = 0;

		level.teamSpawnPoints[team] = [];
		level.spawn_point_team_class_names[team] = [];
	}

	level.skipVote = false;
	level.gameEnded = false;
	SetDvar( "g_gameEnded", 0 );

	level.objIDStart = 0;
	level.forcedEnd = false;
	level.hostForcedEnd = false;

	level.hardcoreMode = GetGametypeSetting( "hardcoreMode" );
	if ( level.hardcoreMode )
	{
		logString( "game mode: hardcore" );
		
		//set up friendly fire delay for hardcore
		if( !isDefined(level.friendlyFireDelayTime) )
			level.friendlyFireDelayTime = 0;
	}

	if ( GetDvar( "scr_max_rank" ) == "" )
			SetDvar( "scr_max_rank", "0" );
	level.rankCap = GetDvarint( "scr_max_rank" );
	
	if ( GetDvar( "scr_min_prestige" ) == "" )
	{
		SetDvar( "scr_min_prestige", "0" );
	}
	level.minPrestige = GetDvarint( "scr_min_prestige" );

	// this gets set to false when someone takes damage or a gametype-specific event happens.
	level.useStartSpawns = true;

	level.roundscorecarry = getgametypesetting("roundscorecarry");
	level.allowhitmarkers = getgametypesetting("allowhitmarkers");
	level.playerqueuedrespawn = getgametypesetting("playerQueuedRespawn");
	level.playerforcerespawn = getgametypesetting("playerForceRespawn");
	level.roundstartexplosivedelay = getgametypesetting("roundStartExplosiveDelay");
	level.roundstartkillstreakdelay = getgametypesetting("roundStartKillstreakDelay");
	level.perksenabled = getgametypesetting("perksEnabled");
	level.disableattachments = getgametypesetting("disableAttachments");
	level.disabletacinsert = getgametypesetting("disableTacInsert");
	level.disablecac = getgametypesetting("disableCAC");
	level.disableclassselection = getgametypesetting("disableClassSelection");
	level.disableweapondrop = getgametypesetting("disableweapondrop");
	level.onlyheadshots = getgametypesetting("onlyHeadshots");
	level.minimumallowedteamkills = getgametypesetting("teamKillPunishCount") - 1;
	level.teamkillreducedpenalty = getgametypesetting("teamKillReducedPenalty");
	level.teamkillpointloss = getgametypesetting("teamKillPointLoss");
	level.teamkillspawndelay = getgametypesetting("teamKillSpawnDelay");
	level.deathpointloss = getgametypesetting("deathPointLoss");
	level.leaderbonus = getgametypesetting("leaderBonus");
	level.forceradar = getgametypesetting("forceRadar");
	level.playersprinttime = getgametypesetting("playerSprintTime");
	level.bulletdamagescalar = getgametypesetting("bulletDamageScalar");
	level.playermaxhealth = getgametypesetting("playerMaxHealth");
	level.playerhealthregentime = getgametypesetting("playerHealthRegenTime");
	level.playerrespawndelay = getgametypesetting("playerRespawnDelay");
	level.playerobjectiveheldrespawndelay = getgametypesetting("playerObjectiveHeldRespawnDelay");
	level.waverespawndelay = getgametypesetting("waveRespawnDelay");
	level.suicidespawndelay = getgametypesetting("spawnsuicidepenalty");
	level.teamkilledspawndelay = getgametypesetting("spawnteamkilledpenalty");
	level.maxsuicidesbeforekick = getgametypesetting("maxsuicidesbeforekick");
	level.spectatetype = getgametypesetting("spectateType");
	level.voip = spawnstruct();
	level.voip.deadchatwithdead = getgametypesetting("voipDeadChatWithDead");
	level.voip.deadchatwithteam = getgametypesetting("voipDeadChatWithTeam");
	level.voip.deadhearallliving = getgametypesetting("voipDeadHearAllLiving");
	level.voip.deadhearteamliving = getgametypesetting("voipDeadHearTeamLiving");
	level.voip.everyonehearseveryone = getgametypesetting("voipEveryoneHearsEveryone");
	level.voip.deadhearkiller = getgametypesetting("voipDeadHearKiller");
	level.voip.killershearvictim = getgametypesetting("voipKillersHearVictim");

	if( GetDvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );
		
	if( SessionModeIsZombiesGame() )
	{
		level.prematchPeriod = 0;


		//thread maps\mp\gametypes\_persistence::init();
		level.persistentDataInfo = [];
		level.maxRecentStats = 10;
		level.maxHitLocations = 19;
		level.globalShotsFired = 0;
		thread maps/mp/gametypes/_hud::init();
		thread maps/mp/gametypes/_serversettings::init();
		thread maps/mp/gametypes/_clientids::init();
		thread maps/mp/gametypes/_weaponobjects::init();
		thread maps/mp/gametypes/_scoreboard::init();
		thread maps/mp/gametypes/_killcam::init();
		thread maps/mp/gametypes/_shellshock::init();
		thread maps/mp/gametypes/_deathicons::init();
		thread maps/mp/gametypes/_spectating::init();
		thread maps/mp/gametypes/_objpoints::init();
		thread maps/mp/gametypes/_gameobjects::init();
		thread maps/mp/gametypes/_spawnlogic::init();
		thread maps/mp/gametypes/_globallogic_audio::init();
		thread maps/mp/gametypes/_wager::init();
		thread maps/mp/bots/_bot::init();
		thread maps/mp/_decoy::init();
	}
	else
	{
		thread maps\mp\gametypes\_persistence::init();
		thread maps\mp\gametypes\_menus::init();
		thread maps\mp\gametypes\_hud::init();
		thread maps\mp\gametypes\_serversettings::init();
		thread maps\mp\gametypes\_clientids::init();
		thread maps\mp\teams\_teams::init();
		thread maps\mp\gametypes\_weapons::init();
		thread maps\mp\gametypes\_scoreboard::init();
		thread maps\mp\gametypes\_killcam::init();
		thread maps\mp\gametypes\_shellshock::init();
		thread maps\mp\gametypes\_deathicons::init();
		thread maps\mp\gametypes\_damagefeedback::init();
		thread maps\mp\gametypes\_healthoverlay::init();
		thread maps\mp\gametypes\_spectating::init();
		thread maps\mp\gametypes\_objpoints::init();
		thread maps\mp\gametypes\_gameobjects::init();
		thread maps\mp\gametypes\_spawnlogic::init();
		thread maps\mp\gametypes\_battlechatter_mp::init();
		thread maps\mp\killstreaks\_killstreaks::init();
		thread maps\mp\gametypes\_globallogic_audio::init();
		thread maps\mp\gametypes\_wager::init();
		thread maps\mp\bots\_bot::init();
		thread maps\mp\_decoy::init();
		thread maps\mp\_bb::init();
	}

	if ( level.teamBased )
		thread maps\mp\gametypes\_friendicons::init();
		
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\_multi_extracam::init();

	stringNames = getArrayKeys( game["strings"] );
	for ( index = 0; index < stringNames.size; index++ )
	{
		precacheString( game[ "strings" ][ stringNames[ index ] ] );
	}
	foreach( team in level.teams )
	{
		initTeamVariables( team );
	}
	
	level.maxPlayerCount = 0;
	level.activePlayers = [];

	level.allowAnnouncer = GetGametypeSetting( "allowAnnouncer" );

	if ( !isDefined( level.timeLimit ) )
		registerTimeLimit( 1, 1440 );
		
	if ( !isDefined( level.scoreLimit ) )
		registerScoreLimit( 1, 500 );

	if ( !isDefined( level.roundLimit ) )
		registerRoundLimit( 0, 10 );

	if ( !isDefined( level.roundWinLimit ) )
		registerRoundWinLimit( 0, 10 );
	
	// The order the following functions are registered in are the order they will get called
	maps\mp\gametypes\_globallogic_utils::registerPostRoundEvent( maps\mp\gametypes\_killcam::postRoundFinalKillcam );	
	maps\mp\gametypes\_globallogic_utils::registerPostRoundEvent( maps\mp\gametypes\_wager::postRoundSideBet );

	makeDvarServerInfo( "ui_scorelimit" );
	makeDvarServerInfo( "ui_timelimit" );
	makeDvarServerInfo( "ui_allow_classchange", GetDvar( "ui_allow_classchange" ) );

	waveDelay = level.waveRespawnDelay;
	if ( waveDelay && !isPreGame() )
	{
		foreach ( team in level.teams )
		{
			level.waveDelay[team] = waveDelay;
			level.lastWave[team] = 0;
		}
		
		level thread [[level.waveSpawnTimer]]();
	}
	
	level.inPrematchPeriod = true;
	
	if ( level.prematchPeriod > 2.0 )
		level.prematchPeriod = level.prematchPeriod + (randomFloat( 4 ) - 2); // live host obfuscation

	if ( level.numLives || anyTeamHasWaveDelay() || level.playerQueuedRespawn )
		level.gracePeriod = 15;
	else
		level.gracePeriod = 5;
		
	level.inGracePeriod = true;
	
	level.roundEndDelay = 5;
	level.halftimeRoundEndDelay = 3;
	
	maps\mp\gametypes\_globallogic_score::updateAllTeamScores();
	
	level.killstreaksenabled = GetGametypeSetting( "killstreaksenabled" );
	
	if ( GetDvar( "scr_game_rankenabled" ) == "" )
		SetDvar( "scr_game_rankenabled", true );
	level.rankEnabled = GetDvarint( "scr_game_rankenabled" );
	
	if ( GetDvar( "scr_game_medalsenabled" ) == "" )
		SetDvar( "scr_game_medalsenabled", true );
	level.medalsEnabled = GetDvarint( "scr_game_medalsenabled" );

	if( level.hardcoreMode && level.rankedMatch && GetDvar( "scr_game_friendlyFireDelay" ) == "" )
		SetDvar( "scr_game_friendlyFireDelay", true );
	level.friendlyFireDelay = GetDvarint( "scr_game_friendlyFireDelay" );

	// level gametype and features globals should be defaulted before this, and level.onstartgametype should reset them if desired
	if(GetDvar("createfx") == "")
	{
		[[level.onStartGameType]]();
	}

	// disable killstreaks for custom game modes
	if( GetDvarInt( "custom_killstreak_mode" ) == 1 )
	{
		level.killstreaksenabled = 0;
	}
	
	// this must be after onstartgametype for scr_showspawns to work when set at start of game
		/*
	/#
	thread maps\mp\gametypes\_dev::init();
	#/
		*/
	/*	
/#
	PrintLn( "Globallogic Callback_StartGametype() isPregame() = " + isPregame() + "\n" );
#/
	*/
	level thread maps\mp\gametypes\_killcam::doFinalKillcam();

	thread startGame();
	level thread updateGameTypeDvars();
	/*
/#
	if( GetDvarint( "scr_writeconfigstrings" ) == 1 )
	{
		level.skipGameEnd = true;
		level.roundLimit = 1;
		
		// let things settle
		wait(1);
//		level.forcedEnd = true;
		thread forceEnd( false );
//		thread endgame( "tie","" );
	}
	if( GetDvarint( "scr_hostmigrationtest" ) == 1 )
	{
		thread ForceDebugHostMigration();
	}
#/
	*/
}


ForceDebugHostMigration()
{	
		/*
	/#
	while (1)
	{
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
		wait(60);
		starthostmigration();
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
		//thread forceEnd( false );
	}
	#/
		*/
}


registerFriendlyFireDelay( dvarString, defaultValue, minValue, maxValue ) //checked matches bo3 _globallogic.gsc within reason
{
	dvarString = ("scr_" + dvarString + "_friendlyFireDelayTime");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );

	level.friendlyFireDelayTime = getDvarInt( dvarString );
}

checkRoundSwitch() //checked matches bo3 _globallogic.gsc within reason
{
	if ( !isdefined( level.roundSwitch ) || !level.roundSwitch )
		return false;
	if ( !isdefined( level.onRoundSwitch ) )
		return false;
	/*
	assert( game["roundsplayed"] > 0 );
	*/
	if ( game["roundsplayed"] % level.roundswitch == 0 )
	{
		[[level.onRoundSwitch]]();
		return true;
	}
		
	return false;
}


listenForGameEnd() //checked matches bo3 _globallogic.gsc within reason
{
	self waittill( "host_sucks_end_game" );
	//if ( level.console )
	//	endparty();
	level.skipVote = true;

	if ( !level.gameEnded )
		level thread maps\mp\gametypes\_globallogic::forceEnd(true);
}


getKillStreaks( player ) //checked matches bo3 _globallogic.gsc within reason
{
	for ( killstreakNum = 0; killstreakNum < level.maxKillstreaks; killstreakNum++ )
	{
		killstreak[ killstreakNum ] = "killstreak_null";
	}
	
	if ( isPlayer( player ) && !level.oldschool && level.disableCAC != 1 &&
	!isdefined( player.pers["isBot"] ) && isdefined( player.killstreak ) )
	{
		currentKillstreak = 0;
		for ( killstreakNum = 0; killstreakNum < level.maxKillstreaks; killstreakNum++ )
		{
				if ( isDefined( player.killstreak[ killstreakNum ] ) )
				{
					killstreak[ currentKillstreak ] = player.killstreak[ killstreakNum ];
					currentKillstreak++;
				}
		}
	}
	
	return killstreak;
}

updateRankedMatch(winner) //checked matches bo3 _globallogic.gsc within reason
{
	if ( level.rankedMatch )
	{
		if ( hostIdledOut() )
		{
			level.hostForcedEnd = true;
			logString( "host idled out" );
			endLobby();
		}
	}
	if ( !level.wagerMatch && !SessionModeIsZombiesGame() )
	{
		maps\mp\gametypes\_globallogic_score::updateMatchBonusScores( winner );
		maps\mp\gametypes\_globallogic_score::updateWinLossStats( winner );
	}
}



