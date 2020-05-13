//checked includes changed to match cerberus output
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_globallogic_ui;
#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_callbacksetup;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;


main() //checked matches cerberus output
{
	level.pregame = 1;
	/*
/#
	println( "Pregame main() level.pregame = " + level.pregame + "\n" );
#/
	*/
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	registertimelimit( 0, 1440 );
	registerscorelimit( 0, 5000 );
	registerroundlimit( 0, 1 );
	registerroundwinlimit( 0, 0 );
	registernumlives( 0, 0 );
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onendgame = ::onendgame;
	level.ontimelimit = ::ontimelimit;
	game[ "dialog" ][ "gametype" ] = "pregame_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	setscoreboardcolumns( "score", "kills", "deaths", "kdratio", "assists" );
	if ( getDvar( "party_minplayers" ) == "" )
	{
		setdvar( "party_minplayers", 4 );
	}
	level.pregame_minplayers = getDvarInt( "party_minplayers" );
	setmatchtalkflag( "EveryoneHearsEveryone", 1 );
}

onstartgametype() //checked changed to match cerberus output
{
	setclientnamemode( "auto_change" );
	level.spawnmins = ( 0, 0, 0 );
	level.spawnmaxs = ( 0, 0, 0 );
	foreach(team in level.teams)
	{
		setobjectivetext( team, &"OBJECTIVES_PREGAME" );
		setobjectivehinttext( team, &"OBJECTIVES_PREGAME_HINT" );
		if ( level.splitscreen )
		{
			setobjectivescoretext( team, &"OBJECTIVES_PREGAME" );
		}
		else
		{
			setobjectivescoretext( team, &"OBJECTIVES_PREGAME_SCORE" );
		}
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, "mp_dm_spawn" );
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.usestartspawns = 0;
	level.teambased = 0;
	level.overrideteamscore = 1;
	level.rankenabled = 0;
	level.medalsenabled = 0;
	allowed[ 0 ] = "dm";
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.killcam = 0;
	level.finalkillcam = 0;
	level.killstreaksenabled = 0;
	startpregame();
}

startpregame() //checked matches cerberus output
{
	game[ "strings" ][ "waiting_for_players" ] = &"MP_WAITING_FOR_X_PLAYERS";
	game[ "strings" ][ "pregame" ] = &"MP_PREGAME";
	game[ "strings" ][ "pregameover" ] = &"MP_MATCHSTARTING";
	game[ "strings" ][ "pregame_time_limit_reached" ] = &"MP_PREGAME_TIME_LIMIT";
	precachestring( game[ "strings" ][ "waiting_for_players" ] );
	precachestring( game[ "strings" ][ "pregame" ] );
	precachestring( game[ "strings" ][ "pregameover" ] );
	precachestring( game[ "strings" ][ "pregame_time_limit_reached" ] );
	thread pregamemain();
}

onspawnplayerunified() //checked matches cerberus output
{
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn ) //checked matches cerberus output
{
	spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( self.pers[ "team" ] );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_dm( spawnpoints );
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "dm" );
	}
}

onplayerclasschange( response ) //checked matches cerberus output
{
	self.pregameclassresponse = response;
}

endpregame() //checked changed to match cerberus output
{
	level.pregame = 0;
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[ index ];
		player maps/mp/gametypes/_globallogic_player::freezeplayerforroundend();
	}
	setmatchtalkflag( "EveryoneHearsEveryone", 0 );
	level.pregameplayercount destroyelem();
	level.pregamesubtitle destroyelem();
	level.pregametitle destroyelem();
}

getplayersneededcount() //checked changed to match cerberus output
{
	players = level.players;
	count = 0;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		team = player.team;
		class = player.class;
		if ( team != "spectator" )
		{
			count++;
		}
	}
	return int( level.pregame_minplayers - count );
}

saveplayerspregameinfo() //checked changed to match cerberus output
{
	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		team = player.team;
		class = player.pregameclassresponse;
		if ( isDefined( team ) && team != "" )
		{
			player setpregameteam( team );
		}
		if ( isDefined( class ) && class != "" )
		{
			player setpregameclass( class );
		}
	}
}

pregamemain() //checked did not reference cerberus output used beta dump _pregame.gsc as a reference
{
	level endon( "game_ended" );
	green = ( 0.6, 0.9, 0.6 );
	red = ( 0.7, 0.3, 0.2 );
	yellow = ( 1, 1, 0 );
	white = ( 1, 1, 1 );
	titlesize = 3;
	textsize = 2;
	iconsize = 70;
	spacing = 30;
	font = "objective";
	level.pregametitle = createserverfontstring( font, titlesize );
	level.pregametitle setpoint( "TOP", undefined, 0, 70 );
	level.pregametitle.glowalpha = 1;
	level.pregametitle.foreground = 1;
	level.pregametitle.hidewheninmenu = 1;
	level.pregametitle.archived = 0;
	level.pregametitle settext( game[ "strings" ][ "pregame" ] );
	level.pregametitle.color = red;
	level.pregamesubtitle = createserverfontstring( font, 2 );
	level.pregamesubtitle setparent( level.pregametitle );
	level.pregamesubtitle setpoint( "TOP", "BOTTOM", 0, 0 );
	level.pregamesubtitle.glowalpha = 1;
	level.pregamesubtitle.foreground = 0;
	level.pregamesubtitle.hidewheninmenu = 1;
	level.pregamesubtitle.archived = 1;
	level.pregamesubtitle settext( game[ "strings" ][ "waiting_for_players" ] );
	level.pregamesubtitle.color = green;
	level.pregameplayercount = createserverfontstring( font, 2.2 );
	level.pregameplayercount setparent( level.pregametitle );
	level.pregameplayercount setpoint( "TOP", "BOTTOM", -11, 0 );
	level.pregamesubtitle.glowalpha = 1;
	level.pregameplayercount.sort = 1001;
	level.pregameplayercount.foreground = 0;
	level.pregameplayercount.hidewheninmenu = 1;
	level.pregameplayercount.archived = 1;
	level.pregameplayercount.color = yellow;
	level.pregameplayercount maps/mp/gametypes/_hud::fontpulseinit();
	oldcount = -1;
	for(;;)
	{
		wait( 1 );
		
		count = GetPlayersNeededCount();
		
		if ( 0 >= count )
		{
			break;
		}
		/*
/#			
		if ( GetDvarint( "scr_pregame_abort" ) > 0 )
		{
			SetDvar( "scr_pregame_abort", 0 );
			break;
		}
#/
		*/
		if ( oldcount != count )
		{
			level.pregamePlayerCount setValue( count );
			level.pregamePlayerCount thread maps\mp\gametypes\_hud::fontPulse( level );
			oldcount = count;
		}
	}
	level.pregameplayercount settext( "" );
	level.pregamesubtitle settext( game[ "strings" ][ "pregameover" ] );
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[ index ];
		player maps/mp/gametypes/_globallogic_player::freezeplayerforroundend();
		player maps/mp/gametypes/_globallogic_ui::freegameplayhudelems();
	}
	visionsetnaked( "mpIntro", 3 );
	wait 4;
	endpregame();
	pregamestartgame();
	saveplayerspregameinfo();
	map_restart( 0 );
}

onendgame( winner ) //checked matches cerberus output
{
	endpregame();
}

ontimelimit() //checked changed to match cerberus output
{
	winner = undefined;
	if ( level.teambased )
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "teamScores" );
		maps/mp/gametypes/_globallogic_utils::logteamwinstring( "time limit", winner );
	}
	else
	{
		winner = maps/mp/gametypes/_globallogic_score::gethighestscoringplayer();
		if ( isDefined( winner ) )
		{
			logstring( "time limit, win: " + winner.name );
		}
		else
		{
			logstring( "time limit, tie" );
		}
	}
	makedvarserverinfo( "ui_text_endreason", game[ "strings" ][ "pregame_time_limit_reached" ] );
	setdvar( "ui_text_endreason", game[ "strings" ][ "time_limit_reached" ] );
	thread maps/mp/gametypes/_globallogic::endgame( winner, game[ "strings" ][ "pregame_time_limit_reached" ] );
}

get_pregame_class() //checked matches cerberus output
{
	pclass = self getpregameclass();
	if ( isDefined( pclass ) && pclass[ 0 ] != "" )
	{
		return pclass;
	}
	else
	{
		return "smg_mp,0";
	}
}

