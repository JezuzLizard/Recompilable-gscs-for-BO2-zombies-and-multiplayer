#include maps/mp/gametypes/_rank;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_utility;
#include common_scripts/utility;

getwinningteamfromloser( losing_team )
{
	if ( level.multiteam )
	{
		return "tie";
	}
	else
	{
		if ( losing_team == "axis" )
		{
			return "allies";
		}
	}
	return "axis";
}

default_onforfeit( team )
{
	level.gameforfeited = 1;
	level notify( "forfeit in progress" );
	level endon( "forfeit in progress" );
	level endon( "abort forfeit" );
	forfeit_delay = 20;
	announcement( game[ "strings" ][ "opponent_forfeiting_in" ], forfeit_delay, 0 );
	wait 10;
	announcement( game[ "strings" ][ "opponent_forfeiting_in" ], 10, 0 );
	wait 10;
	endreason = &"";
	if ( level.multiteam )
	{
		setdvar( "ui_text_endreason", game[ "strings" ][ "other_teams_forfeited" ] );
		endreason = game[ "strings" ][ "other_teams_forfeited" ];
		winner = team;
	}
	else if ( !isDefined( team ) )
	{
		setdvar( "ui_text_endreason", game[ "strings" ][ "players_forfeited" ] );
		endreason = game[ "strings" ][ "players_forfeited" ];
		winner = level.players[ 0 ];
	}
	else if ( isDefined( level.teams[ team ] ) )
	{
		endreason = game[ "strings" ][ team + "_forfeited" ];
		setdvar( "ui_text_endreason", endreason );
		winner = getwinningteamfromloser( team );
	}
	else
	{
/#
		assert( isDefined( team ), "Forfeited team is not defined" );
#/
/#
		assert( 0, "Forfeited team " + team + " is not allies or axis" );
#/
		winner = "tie";
	}
	level.forcedend = 1;
	if ( isplayer( winner ) )
	{
		logstring( "forfeit, win: " + winner getxuid() + "(" + winner.name + ")" );
	}
	else
	{
		maps/mp/gametypes/_globallogic_utils::logteamwinstring( "forfeit", winner );
	}
	thread maps/mp/gametypes/_globallogic::endgame( winner, endreason );
}

default_ondeadevent( team )
{
	if ( isDefined( level.teams[ team ] ) )
	{
		eliminatedstring = game[ "strings" ][ team + "_eliminated" ];
		iprintln( eliminatedstring );
		makedvarserverinfo( "ui_text_endreason", eliminatedstring );
		setdvar( "ui_text_endreason", eliminatedstring );
		winner = getwinningteamfromloser( team );
		maps/mp/gametypes/_globallogic_utils::logteamwinstring( "team eliminated", winner );
		thread maps/mp/gametypes/_globallogic::endgame( winner, eliminatedstring );
	}
	else makedvarserverinfo( "ui_text_endreason", game[ "strings" ][ "tie" ] );
	setdvar( "ui_text_endreason", game[ "strings" ][ "tie" ] );
	maps/mp/gametypes/_globallogic_utils::logteamwinstring( "tie" );
	if ( level.teambased )
	{
		thread maps/mp/gametypes/_globallogic::endgame( "tie", game[ "strings" ][ "tie" ] );
	}
	else
	{
		thread maps/mp/gametypes/_globallogic::endgame( undefined, game[ "strings" ][ "tie" ] );
	}
}

default_onlastteamaliveevent( team )
{
	if ( isDefined( level.teams[ team ] ) )
	{
		eliminatedstring = game[ "strings" ][ "enemies_eliminated" ];
		iprintln( eliminatedstring );
		makedvarserverinfo( "ui_text_endreason", eliminatedstring );
		setdvar( "ui_text_endreason", eliminatedstring );
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "teamScores" );
		maps/mp/gametypes/_globallogic_utils::logteamwinstring( "team eliminated", winner );
		thread maps/mp/gametypes/_globallogic::endgame( winner, eliminatedstring );
	}
	else makedvarserverinfo( "ui_text_endreason", game[ "strings" ][ "tie" ] );
	setdvar( "ui_text_endreason", game[ "strings" ][ "tie" ] );
	maps/mp/gametypes/_globallogic_utils::logteamwinstring( "tie" );
	if ( level.teambased )
	{
		thread maps/mp/gametypes/_globallogic::endgame( "tie", game[ "strings" ][ "tie" ] );
	}
	else
	{
		thread maps/mp/gametypes/_globallogic::endgame( undefined, game[ "strings" ][ "tie" ] );
	}
}

default_onalivecountchange( team )
{
}

default_onroundendgame( winner )
{
	return winner;
}

default_ononeleftevent( team )
{
	if ( !level.teambased )
	{
		winner = maps/mp/gametypes/_globallogic_score::gethighestscoringplayer();
		if ( isDefined( winner ) )
		{
			logstring( "last one alive, win: " + winner.name );
		}
		else
		{
			logstring( "last one alive, win: unknown" );
		}
		thread maps/mp/gametypes/_globallogic::endgame( winner, &"MP_ENEMIES_ELIMINATED" );
	}
	else
	{
		index = 0;
		while ( index < level.players.size )
		{
			player = level.players[ index ];
			if ( !isalive( player ) )
			{
				index++;
				continue;
			}
			else if ( !isDefined( player.pers[ "team" ] ) || player.pers[ "team" ] != team )
			{
				index++;
				continue;
			}
			else
			{
				player maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "sudden_death" );
			}
			index++;
		}
	}
}

default_ontimelimit()
{
	winner = undefined;
	if ( level.teambased )
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "teamScores" );
		maps/mp/gametypes/_globallogic_utils::logteamwinstring( "time limit", winner );
	}
	else winner = maps/mp/gametypes/_globallogic_score::gethighestscoringplayer();
	if ( isDefined( winner ) )
	{
		logstring( "time limit, win: " + winner.name );
	}
	else
	{
		logstring( "time limit, tie" );
	}
	makedvarserverinfo( "ui_text_endreason", game[ "strings" ][ "time_limit_reached" ] );
	setdvar( "ui_text_endreason", game[ "strings" ][ "time_limit_reached" ] );
	thread maps/mp/gametypes/_globallogic::endgame( winner, game[ "strings" ][ "time_limit_reached" ] );
}

default_onscorelimit()
{
	if ( !level.endgameonscorelimit )
	{
		return 0;
	}
	winner = undefined;
	if ( level.teambased )
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "teamScores" );
		maps/mp/gametypes/_globallogic_utils::logteamwinstring( "scorelimit", winner );
	}
	else winner = maps/mp/gametypes/_globallogic_score::gethighestscoringplayer();
	if ( isDefined( winner ) )
	{
		logstring( "scorelimit, win: " + winner.name );
	}
	else
	{
		logstring( "scorelimit, tie" );
	}
	makedvarserverinfo( "ui_text_endreason", game[ "strings" ][ "score_limit_reached" ] );
	setdvar( "ui_text_endreason", game[ "strings" ][ "score_limit_reached" ] );
	thread maps/mp/gametypes/_globallogic::endgame( winner, game[ "strings" ][ "score_limit_reached" ] );
	return 1;
}

default_onspawnspectator( origin, angles )
{
	if ( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn( origin, angles );
		return;
	}
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray( spawnpointname, "classname" );
/#
	assert( spawnpoints.size, "There are no mp_global_intermission spawn points in the map.  There must be at least one." );
#/
	spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( spawnpoints );
	self spawn( spawnpoint.origin, spawnpoint.angles );
}

default_onspawnintermission()
{
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray( spawnpointname, "classname" );
	spawnpoint = spawnpoints[ 0 ];
	if ( isDefined( spawnpoint ) )
	{
		self spawn( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
/#
		maps/mp/_utility::error( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" );
#/
	}
}

default_gettimelimit()
{
	return clamp( getgametypesetting( "timeLimit" ), level.timelimitmin, level.timelimitmax );
}

default_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon )
{
	teamkill_penalty = 1;
	score = maps/mp/gametypes/_globallogic_score::_getplayerscore( attacker );
	if ( score == 0 )
	{
		teamkill_penalty = 2;
	}
	if ( maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
	{
		teamkill_penalty *= maps/mp/killstreaks/_killstreaks::getkillstreakteamkillpenaltyscale( sweapon );
	}
	return teamkill_penalty;
}

default_getteamkillscore( einflictor, attacker, smeansofdeath, sweapon )
{
	return maps/mp/gametypes/_rank::getscoreinfovalue( "team_kill" );
}
