#include maps/mp/bots/_bot;
#include maps/mp/gametypes/_rank;
#include maps/mp/_utility;

init()
{
	if ( !isgamerepenabled() )
	{
		return;
	}
	if ( isgamerepinitialized() )
	{
		return;
	}
	game[ "gameRepInitialized" ] = 1;
	game[ "gameRep" ][ "players" ] = [];
	game[ "gameRep" ][ "playerNames" ] = [];
	game[ "gameRep" ][ "max" ] = [];
	game[ "gameRep" ][ "playerCount" ] = 0;
	gamerepinitializeparams();
}

isgamerepinitialized()
{
	if ( !isDefined( game[ "gameRepInitialized" ] ) || !game[ "gameRepInitialized" ] )
	{
		return 0;
	}
	return 1;
}

isgamerepenabled()
{
	if ( maps/mp/bots/_bot::is_bot_ranked_match() )
	{
		return 0;
	}
	if ( sessionmodeiszombiesgame() )
	{
		return 0;
	}
	if ( !level.rankedmatch )
	{
		return 0;
	}
	return 1;
}

gamerepinitializeparams()
{
	threshold_exceeded_score = 0;
	threshold_exceeded_score_per_min = 1;
	threshold_exceeded_kills = 2;
	threshold_exceeded_deaths = 3;
	threshold_exceeded_kd_ratio = 4;
	threshold_exceeded_kills_per_min = 5;
	threshold_exceeded_plants = 6;
	threshold_exceeded_defuses = 7;
	threshold_exceeded_captures = 8;
	threshold_exceeded_defends = 9;
	threshold_exceeded_total_time_played = 10;
	threshold_exceeded_tactical_insertion_use = 11;
	threshold_exceeded_join_attempts = 12;
	threshold_exceeded_xp = 13;
	threshold_exceeded_splitscreen = 14;
	game[ "gameRep" ][ "params" ] = [];
	game[ "gameRep" ][ "params" ][ 0 ] = "score";
	game[ "gameRep" ][ "params" ][ 1 ] = "scorePerMin";
	game[ "gameRep" ][ "params" ][ 2 ] = "kills";
	game[ "gameRep" ][ "params" ][ 3 ] = "deaths";
	game[ "gameRep" ][ "params" ][ 4 ] = "killDeathRatio";
	game[ "gameRep" ][ "params" ][ 5 ] = "killsPerMin";
	game[ "gameRep" ][ "params" ][ 6 ] = "plants";
	game[ "gameRep" ][ "params" ][ 7 ] = "defuses";
	game[ "gameRep" ][ "params" ][ 8 ] = "captures";
	game[ "gameRep" ][ "params" ][ 9 ] = "defends";
	game[ "gameRep" ][ "params" ][ 10 ] = "totalTimePlayed";
	game[ "gameRep" ][ "params" ][ 11 ] = "tacticalInsertions";
	game[ "gameRep" ][ "params" ][ 12 ] = "joinAttempts";
	game[ "gameRep" ][ "params" ][ 13 ] = "xp";
	game[ "gameRep" ][ "ignoreParams" ] = [];
	game[ "gameRep" ][ "ignoreParams" ][ 0 ] = "totalTimePlayed";
	game[ "gameRep" ][ "gameLimit" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "default" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "tdm" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "dm" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "dom" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "hq" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "sd" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "dem" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "ctf" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "koth" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "conf" ] = [];
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "score" ] = threshold_exceeded_score;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "score" ] = 20000;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "scorePerMin" ] = threshold_exceeded_score_per_min;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "scorePerMin" ] = 250;
	game[ "gameRep" ][ "gameLimit" ][ "dem" ][ "scorePerMin" ] = 1000;
	game[ "gameRep" ][ "gameLimit" ][ "tdm" ][ "scorePerMin" ] = 700;
	game[ "gameRep" ][ "gameLimit" ][ "dm" ][ "scorePerMin" ] = 950;
	game[ "gameRep" ][ "gameLimit" ][ "dom" ][ "scorePerMin" ] = 1000;
	game[ "gameRep" ][ "gameLimit" ][ "sd" ][ "scorePerMin" ] = 200;
	game[ "gameRep" ][ "gameLimit" ][ "ctf" ][ "scorePerMin" ] = 600;
	game[ "gameRep" ][ "gameLimit" ][ "hq" ][ "scorePerMin" ] = 1000;
	game[ "gameRep" ][ "gameLimit" ][ "koth" ][ "scorePerMin" ] = 1000;
	game[ "gameRep" ][ "gameLimit" ][ "conf" ][ "scorePerMin" ] = 1000;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "kills" ] = threshold_exceeded_kills;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "kills" ] = 75;
	game[ "gameRep" ][ "gameLimit" ][ "tdm" ][ "kills" ] = 40;
	game[ "gameRep" ][ "gameLimit" ][ "sd" ][ "kills" ] = 15;
	game[ "gameRep" ][ "gameLimit" ][ "dm" ][ "kills" ] = 31;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "deaths" ] = threshold_exceeded_deaths;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "deaths" ] = 50;
	game[ "gameRep" ][ "gameLimit" ][ "dm" ][ "deaths" ] = 15;
	game[ "gameRep" ][ "gameLimit" ][ "tdm" ][ "deaths" ] = 40;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "killDeathRatio" ] = threshold_exceeded_kd_ratio;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "killDeathRatio" ] = 30;
	game[ "gameRep" ][ "gameLimit" ][ "tdm" ][ "killDeathRatio" ] = 50;
	game[ "gameRep" ][ "gameLimit" ][ "sd" ][ "killDeathRatio" ] = 20;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "killsPerMin" ] = threshold_exceeded_kills_per_min;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "killsPerMin" ] = 15;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "plants" ] = threshold_exceeded_plants;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "plants" ] = 10;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "defuses" ] = threshold_exceeded_defuses;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "defuses" ] = 10;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "captures" ] = threshold_exceeded_captures;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "captures" ] = 30;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "defends" ] = threshold_exceeded_defends;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "defends" ] = 50;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "totalTimePlayed" ] = threshold_exceeded_total_time_played;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "totalTimePlayed" ] = 600;
	game[ "gameRep" ][ "gameLimit" ][ "dom" ][ "totalTimePlayed" ] = 600;
	game[ "gameRep" ][ "gameLimit" ][ "dem" ][ "totalTimePlayed" ] = 1140;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "tacticalInsertions" ] = threshold_exceeded_tactical_insertion_use;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "tacticalInsertions" ] = 20;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "joinAttempts" ] = threshold_exceeded_join_attempts;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "joinAttempts" ] = 3;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "xp" ] = threshold_exceeded_xp;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "xp" ] = 25000;
	game[ "gameRep" ][ "gameLimit" ][ "id" ][ "splitscreen" ] = threshold_exceeded_splitscreen;
	game[ "gameRep" ][ "gameLimit" ][ "default" ][ "splitscreen" ] = 8;
}

gamerepplayerconnected()
{
	if ( !isgamerepenabled() )
	{
		return;
	}
	name = self.name;
/#
#/
	if ( !isDefined( game[ "gameRep" ][ "players" ][ name ] ) )
	{
		game[ "gameRep" ][ "players" ][ name ] = [];
		j = 0;
		while ( j < game[ "gameRep" ][ "params" ].size )
		{
			paramname = game[ "gameRep" ][ "params" ][ j ];
			game[ "gameRep" ][ "players" ][ name ][ paramname ] = 0;
			j++;
		}
		game[ "gameRep" ][ "players" ][ name ][ "splitscreen" ] = self issplitscreen();
		game[ "gameRep" ][ "players" ][ name ][ "joinAttempts" ] = 1;
		game[ "gameRep" ][ "players" ][ name ][ "connected" ] = 1;
		game[ "gameRep" ][ "players" ][ name ][ "xpStart" ] = self getrankxpstat();
		game[ "gameRep" ][ "playerNames" ][ game[ "gameRep" ][ "playerCount" ] ] = name;
		game[ "gameRep" ][ "playerCount" ]++;
	}
	else
	{
		if ( !game[ "gameRep" ][ "players" ][ name ][ "connected" ] )
		{
			game[ "gameRep" ][ "players" ][ name ][ "joinAttempts" ]++;
			game[ "gameRep" ][ "players" ][ name ][ "connected" ] = 1;
			game[ "gameRep" ][ "players" ][ name ][ "xpStart" ] = self getrankxpstat();
		}
	}
}

gamerepplayerdisconnected()
{
	if ( !isgamerepenabled() )
	{
		return;
	}
	name = self.name;
	if ( !isDefined( game[ "gameRep" ][ "players" ][ name ] ) || !isDefined( self.pers[ "summary" ] ) )
	{
		return;
	}
/#
#/
	self gamerepupdatenonpersistentplayerinformation();
	self gamerepupdatepersistentplayerinformation();
	game[ "gameRep" ][ "players" ][ name ][ "connected" ] = 0;
}

gamerepupdatenonpersistentplayerinformation()
{
	name = self.name;
	if ( !isDefined( game[ "gameRep" ][ "players" ][ name ] ) )
	{
		return;
	}
	game[ "gameRep" ][ "players" ][ name ][ "totalTimePlayed" ] += self.timeplayed[ "total" ];
	if ( isDefined( self.tacticalinsertioncount ) )
	{
		game[ "gameRep" ][ "players" ][ name ][ "tacticalInsertions" ] += self.tacticalinsertioncount;
	}
}

gamerepupdatepersistentplayerinformation()
{
	name = self.name;
	if ( !isDefined( game[ "gameRep" ][ "players" ][ name ] ) )
	{
		return;
	}
	if ( game[ "gameRep" ][ "players" ][ name ][ "totalTimePlayed" ] != 0 )
	{
		timeplayed = game[ "gameRep" ][ "players" ][ name ][ "totalTimePlayed" ];
	}
	else
	{
		timeplayed = 1;
	}
	game[ "gameRep" ][ "players" ][ name ][ "score" ] = self.score;
	game[ "gameRep" ][ "players" ][ name ][ "scorePerMin" ] = int( game[ "gameRep" ][ "players" ][ name ][ "score" ] / ( timeplayed / 60 ) );
	game[ "gameRep" ][ "players" ][ name ][ "kills" ] = self.kills;
	game[ "gameRep" ][ "players" ][ name ][ "deaths" ] = self.deaths;
	if ( game[ "gameRep" ][ "players" ][ name ][ "deaths" ] != 0 )
	{
		game[ "gameRep" ][ "players" ][ name ][ "killDeathRatio" ] = int( ( game[ "gameRep" ][ "players" ][ name ][ "kills" ] / game[ "gameRep" ][ "players" ][ name ][ "deaths" ] ) * 100 );
	}
	else
	{
		game[ "gameRep" ][ "players" ][ name ][ "killDeathRatio" ] = game[ "gameRep" ][ "players" ][ name ][ "kills" ] * 100;
	}
	game[ "gameRep" ][ "players" ][ name ][ "killsPerMin" ] = int( game[ "gameRep" ][ "players" ][ name ][ "kills" ] / ( timeplayed / 60 ) );
	game[ "gameRep" ][ "players" ][ name ][ "plants" ] = self.plants;
	game[ "gameRep" ][ "players" ][ name ][ "defuses" ] = self.defuses;
	game[ "gameRep" ][ "players" ][ name ][ "captures" ] = self.captures;
	game[ "gameRep" ][ "players" ][ name ][ "defends" ] = self.defends;
	game[ "gameRep" ][ "players" ][ name ][ "xp" ] = self getrankxpstat() - game[ "gameRep" ][ "players" ][ name ][ "xpStart" ];
	game[ "gameRep" ][ "players" ][ name ][ "xpStart" ] = self getrankxpstat();
}

getparamvalueforplayer( playername, paramname )
{
	if ( isDefined( game[ "gameRep" ][ "players" ][ playername ][ paramname ] ) )
	{
		return game[ "gameRep" ][ "players" ][ playername ][ paramname ];
	}
/#
	assertmsg( "Unknown parameter " + paramname + "for individual player" );
#/
}

isgamerepparamvalid( paramname )
{
	gametype = level.gametype;
	if ( !isDefined( game[ "gameRep" ] ) )
	{
		return 0;
	}
	if ( !isDefined( game[ "gameRep" ][ "gameLimit" ] ) )
	{
		return 0;
	}
	if ( !isDefined( game[ "gameRep" ][ "gameLimit" ][ gametype ] ) )
	{
		return 0;
	}
	if ( !isDefined( game[ "gameRep" ][ "gameLimit" ][ gametype ][ paramname ] ) && !isDefined( game[ "gameRep" ][ "gameLimit" ][ "default" ][ paramname ] ) )
	{
		return 0;
	}
	return 1;
}

isgamerepparamignoredforreporting( paramname )
{
	if ( isDefined( game[ "gameRep" ][ "ignoreParams" ][ paramname ] ) )
	{
		return 1;
	}
	return 0;
}

getgamerepparamlimit( paramname )
{
	gametype = level.gametype;
	if ( isDefined( game[ "gameRep" ][ "gameLimit" ][ gametype ] ) )
	{
		if ( isDefined( game[ "gameRep" ][ "gameLimit" ][ gametype ][ paramname ] ) )
		{
			return game[ "gameRep" ][ "gameLimit" ][ gametype ][ paramname ];
		}
	}
	if ( isDefined( game[ "gameRep" ][ "gameLimit" ][ "default" ][ paramname ] ) )
	{
		return game[ "gameRep" ][ "gameLimit" ][ "default" ][ paramname ];
	}
/#
	assertmsg( "Default values for parameter " + paramname + " is not defined." );
#/
}

setmaximumparamvalueforcurrentgame( paramname, value )
{
	if ( !isDefined( game[ "gameRep" ][ "max" ][ paramname ] ) )
	{
		game[ "gameRep" ][ "max" ][ paramname ] = value;
		return;
	}
	if ( game[ "gameRep" ][ "max" ][ paramname ] < value )
	{
		game[ "gameRep" ][ "max" ][ paramname ] = value;
	}
}

gamerepupdateinformationforround()
{
	if ( !isgamerepenabled() )
	{
		return;
	}
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		player gamerepupdatenonpersistentplayerinformation();
		i++;
	}
}

gamerepanalyzeandreport()
{
	if ( !isgamerepenabled() )
	{
		return;
	}
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		player gamerepupdatepersistentplayerinformation();
		i++;
	}
	splitscreenplayercount = 0;
	i = 0;
	while ( i < game[ "gameRep" ][ "playerNames" ].size )
	{
		playername = game[ "gameRep" ][ "playerNames" ][ i ];
		j = 0;
		while ( j < game[ "gameRep" ][ "params" ].size )
		{
			paramname = game[ "gameRep" ][ "params" ][ j ];
			if ( isgamerepparamvalid( paramname ) )
			{
				setmaximumparamvalueforcurrentgame( paramname, getparamvalueforplayer( playername, paramname ) );
			}
			j++;
		}
		paramname = "splitscreen";
		splitscreenplayercount += getparamvalueforplayer( playername, paramname );
		i++;
	}
	setmaximumparamvalueforcurrentgame( paramname, splitscreenplayercount );
	j = 0;
	while ( j < game[ "gameRep" ][ "params" ].size )
	{
		paramname = game[ "gameRep" ][ "params" ][ j ];
		if ( isgamerepparamvalid( paramname ) && game[ "gameRep" ][ "max" ][ paramname ] >= getgamerepparamlimit( paramname ) )
		{
			gamerepprepareandreport( paramname );
		}
		j++;
	}
	paramname = "splitscreen";
	if ( game[ "gameRep" ][ "max" ][ paramname ] >= getgamerepparamlimit( paramname ) )
	{
		gamerepprepareandreport( paramname );
	}
}

gamerepprepareandreport( paramname )
{
	if ( !isDefined( game[ "gameRep" ][ "gameLimit" ][ "id" ][ paramname ] ) )
	{
		return;
	}
	if ( isgamerepparamignoredforreporting( paramname ) )
	{
		return;
	}
	gamerepthresholdexceeded( game[ "gameRep" ][ "gameLimit" ][ "id" ][ paramname ] );
}
