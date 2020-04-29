#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

main()
{
	if ( getDvar( "mapname" ) == "mp_background" )
	{
		return;
	}
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	registerroundswitch( 0, 9 );
	registertimelimit( 0, 1440 );
	registerscorelimit( 0, 50000 );
	registerroundlimit( 0, 10 );
	registerroundwinlimit( 0, 10 );
	registernumlives( 0, 100 );
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.scoreroundbased = getgametypesetting( "roundscorecarry" ) == 0;
	level.teamscoreperkill = getgametypesetting( "teamScorePerKill" );
	level.teamscoreperdeath = getgametypesetting( "teamScorePerDeath" );
	level.teamscoreperheadshot = getgametypesetting( "teamScorePerHeadshot" );
	level.teambased = 1;
	level.overrideteamscore = 1;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onroundendgame = ::onroundendgame;
	level.onroundswitch = ::onroundswitch;
	level.onplayerkilled = ::onplayerkilled;
	game[ "dialog" ][ "gametype" ] = "tdm_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hctdm_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	setscoreboardcolumns( "score", "kills", "deaths", "kdratio", "assists" );
}

onstartgametype()
{
	setclientnamemode( "auto_change" );
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	if ( game[ "switchedsides" ] )
	{
		oldattackers = game[ "attackers" ];
		olddefenders = game[ "defenders" ];
		game[ "attackers" ] = olddefenders;
		game[ "defenders" ] = oldattackers;
	}
	allowed[ 0 ] = "tdm";
	level.displayroundendtext = 0;
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 0, 0, 0 );
	level.spawnmaxs = ( 0, 0, 0 );
	_a135 = level.teams;
	_k135 = getFirstArrayKey( _a135 );
	while ( isDefined( _k135 ) )
	{
		team = _a135[ _k135 ];
		setobjectivetext( team, &"OBJECTIVES_TDM" );
		setobjectivehinttext( team, &"OBJECTIVES_TDM_HINT" );
		if ( level.splitscreen )
		{
			setobjectivescoretext( team, &"OBJECTIVES_TDM" );
		}
		else
		{
			setobjectivescoretext( team, &"OBJECTIVES_TDM_SCORE" );
		}
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, "mp_tdm_spawn" );
		maps/mp/gametypes/_spawnlogic::placespawnpoints( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
		_k135 = getNextArrayKey( _a135, _k135 );
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
/#
	level.spawn_start = [];
	_a161 = level.teams;
	_k161 = getFirstArrayKey( _a161 );
	while ( isDefined( _k161 ) )
	{
		team = _a161[ _k161 ];
		level.spawn_start[ team ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
		_k161 = getNextArrayKey( _a161, _k161 );
#/
	}
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	if ( !isoneround() )
	{
		level.displayroundendtext = 1;
		if ( isscoreroundbased() )
		{
			maps/mp/gametypes/_globallogic_score::resetteamscores();
		}
	}
}

onspawnplayerunified( question )
{
	self.usingobj = undefined;
	if ( level.usestartspawns && !level.ingraceperiod && !level.playerqueuedrespawn )
	{
		level.usestartspawns = 0;
	}
	spawnteam = self.pers[ "team" ];
	if ( game[ "switchedsides" ] )
	{
		spawnteam = getotherteam( spawnteam );
	}
	if ( isDefined( question ) )
	{
		question = 1;
	}
	if ( isDefined( question ) )
	{
		question = -1;
	}
	if ( isDefined( spawnteam ) )
	{
		spawnteam = spawnteam;
	}
	if ( !isDefined( spawnteam ) )
	{
		spawnteam = -1;
	}
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn, question )
{
	pixbeginevent( "TDM:onSpawnPlayer" );
	self.usingobj = undefined;
	if ( isDefined( question ) )
	{
		question = 1;
	}
	if ( isDefined( question ) )
	{
		question = -1;
	}
	spawnteam = self.pers[ "team" ];
	if ( isDefined( spawnteam ) )
	{
		spawnteam = spawnteam;
	}
	if ( !isDefined( spawnteam ) )
	{
		spawnteam = -1;
	}
	if ( level.ingraceperiod )
	{
		spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( spawnteam ) );
		if ( !spawnpoints.size )
		{
			spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::getteamstartspawnname( spawnteam, "mp_sab_spawn" ) );
		}
		if ( !spawnpoints.size )
		{
			if ( game[ "switchedsides" ] )
			{
				spawnteam = getotherteam( spawnteam );
			}
			spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( spawnteam );
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( spawnpoints );
		}
		else
		{
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( spawnpoints );
		}
	}
	else
	{
		if ( game[ "switchedsides" ] )
		{
			spawnteam = getotherteam( spawnteam );
		}
		spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( spawnteam );
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( spawnpoints );
	}
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "tdm" );
	}
	pixendevent();
}

onendgame( winningteam )
{
	if ( isDefined( winningteam ) && isDefined( level.teams[ winningteam ] ) )
	{
		maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( winningteam, 1 );
	}
}

onroundswitch()
{
	game[ "switchedsides" ] = !game[ "switchedsides" ];
	while ( level.roundscorecarry == 0 )
	{
		_a288 = level.teams;
		_k288 = getFirstArrayKey( _a288 );
		while ( isDefined( _k288 ) )
		{
			team = _a288[ _k288 ];
			[[ level._setteamscore ]]( team, game[ "roundswon" ][ team ] );
			_k288 = getNextArrayKey( _a288, _k288 );
		}
	}
}

onroundendgame( roundwinner )
{
	if ( level.roundscorecarry == 0 )
	{
		_a299 = level.teams;
		_k299 = getFirstArrayKey( _a299 );
		while ( isDefined( _k299 ) )
		{
			team = _a299[ _k299 ];
			[[ level._setteamscore ]]( team, game[ "roundswon" ][ team ] );
			_k299 = getNextArrayKey( _a299, _k299 );
		}
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "roundswon" );
	}
	else
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbyteamscore();
	}
	return winner;
}

onscoreclosemusic()
{
	teamscores = [];
	while ( !level.gameended )
	{
		scorelimit = level.scorelimit;
		scorethreshold = scorelimit * 0,1;
		scorethresholdstart = abs( scorelimit - scorethreshold );
		scorelimitcheck = scorelimit - 10;
		topscore = 0;
		runnerupscore = 0;
		_a327 = level.teams;
		_k327 = getFirstArrayKey( _a327 );
		while ( isDefined( _k327 ) )
		{
			team = _a327[ _k327 ];
			score = [[ level._getteamscore ]]( team );
			if ( score > topscore )
			{
				runnerupscore = topscore;
				topscore = score;
			}
			else
			{
				if ( score > runnerupscore )
				{
					runnerupscore = score;
				}
			}
			_k327 = getNextArrayKey( _a327, _k327 );
		}
		scoredif = topscore - runnerupscore;
		if ( scoredif <= scorethreshold && scorethresholdstart <= topscore )
		{
			thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "TIME_OUT", "both" );
			thread maps/mp/gametypes/_globallogic_audio::actionmusicset();
			return;
		}
		wait 1;
	}
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( isplayer( attacker ) == 0 || attacker.team == self.team )
	{
		return;
	}
	attacker maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( attacker.team, level.teamscoreperkill );
	self maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( self.team, level.teamscoreperdeath * -1 );
	if ( smeansofdeath == "MOD_HEAD_SHOT" )
	{
		attacker maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( attacker.team, level.teamscoreperheadshot );
	}
}
