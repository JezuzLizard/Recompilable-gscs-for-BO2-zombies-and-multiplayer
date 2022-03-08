// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    level.pregame = 1;
/#
    println( "Pregame main() level.pregame = " + level.pregame + "\n" );
#/
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
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
    game["dialog"]["gametype"] = "pregame_start";
    game["dialog"]["offense_obj"] = "generic_boost";
    game["dialog"]["defense_obj"] = "generic_boost";
    setscoreboardcolumns( "score", "kills", "deaths", "kdratio", "assists" );

    if ( getdvar( "party_minplayers" ) == "" )
        setdvar( "party_minplayers", 4 );

    level.pregame_minplayers = getdvarint( "party_minplayers" );
    setmatchtalkflag( "EveryoneHearsEveryone", 1 );
}

onstartgametype()
{
    setclientnamemode( "auto_change" );
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );

    foreach ( team in level.teams )
    {
        setobjectivetext( team, &"OBJECTIVES_PREGAME" );
        setobjectivehinttext( team, &"OBJECTIVES_PREGAME_HINT" );

        if ( level.splitscreen )
            setobjectivescoretext( team, &"OBJECTIVES_PREGAME" );
        else
            setobjectivescoretext( team, &"OBJECTIVES_PREGAME_SCORE" );

        maps\mp\gametypes\_spawnlogic::addspawnpoints( team, "mp_dm_spawn" );
    }

    maps\mp\gametypes\_spawning::updateallspawnpoints();
    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getrandomintermissionpoint();
    setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
    level.usestartspawns = 0;
    level.teambased = 0;
    level.overrideteamscore = 1;
    level.rankenabled = 0;
    level.medalsenabled = 0;
    allowed[0] = "dm";
    maps\mp\gametypes\_gameobjects::main( allowed );
    maps\mp\gametypes\_spawning::create_map_placed_influencers();
    level.killcam = 0;
    level.finalkillcam = 0;
    level.killstreaksenabled = 0;
    startpregame();
}

startpregame()
{
    game["strings"]["waiting_for_players"] = &"MP_WAITING_FOR_X_PLAYERS";
    game["strings"]["pregame"] = &"MP_PREGAME";
    game["strings"]["pregameover"] = &"MP_MATCHSTARTING";
    game["strings"]["pregame_time_limit_reached"] = &"MP_PREGAME_TIME_LIMIT";
    precachestring( game["strings"]["waiting_for_players"] );
    precachestring( game["strings"]["pregame"] );
    precachestring( game["strings"]["pregameover"] );
    precachestring( game["strings"]["pregame_time_limit_reached"] );
    thread pregamemain();
}

onspawnplayerunified()
{
    maps\mp\gametypes\_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn )
{
    spawnpoints = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( self.pers["team"] );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_dm( spawnpoints );

    if ( predictedspawn )
        self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
    else
        self spawn( spawnpoint.origin, spawnpoint.angles, "dm" );
}

onplayerclasschange( response )
{
    self.pregameclassresponse = response;
}

endpregame()
{
    level.pregame = 0;
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];
        player maps\mp\gametypes\_globallogic_player::freezeplayerforroundend();
    }

    setmatchtalkflag( "EveryoneHearsEveryone", 0 );
    level.pregameplayercount destroyelem();
    level.pregamesubtitle destroyelem();
    level.pregametitle destroyelem();
}

getplayersneededcount()
{
    players = level.players;
    count = 0;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        team = player.team;
        class = player.class;

        if ( team != "spectator" )
            count++;
    }

    return int( level.pregame_minplayers - count );
}

saveplayerspregameinfo()
{
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        team = player.team;
        class = player.pregameclassresponse;

        if ( isdefined( team ) && team != "" )
            player setpregameteam( team );

        if ( isdefined( class ) && class != "" )
            player setpregameclass( class );
    }
}

pregamemain()
{
    level endon( "game_ended" );
    green = ( 0.6, 0.9, 0.6 );
    red = ( 0.7, 0.3, 0.2 );
    yellow = ( 1, 1, 0 );
    white = ( 1, 1, 1 );
    titlesize = 3.0;
    textsize = 2.0;
    iconsize = 70;
    spacing = 30;
    font = "objective";
    level.pregametitle = createserverfontstring( font, titlesize );
    level.pregametitle setpoint( "TOP", undefined, 0, 70 );
    level.pregametitle.glowalpha = 1;
    level.pregametitle.foreground = 1;
    level.pregametitle.hidewheninmenu = 1;
    level.pregametitle.archived = 0;
    level.pregametitle settext( game["strings"]["pregame"] );
    level.pregametitle.color = red;
    level.pregamesubtitle = createserverfontstring( font, 2.0 );
    level.pregamesubtitle setparent( level.pregametitle );
    level.pregamesubtitle setpoint( "TOP", "BOTTOM", 0, 0 );
    level.pregamesubtitle.glowalpha = 1;
    level.pregamesubtitle.foreground = 0;
    level.pregamesubtitle.hidewheninmenu = 1;
    level.pregamesubtitle.archived = 1;
    level.pregamesubtitle settext( game["strings"]["waiting_for_players"] );
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
    level.pregameplayercount maps\mp\gametypes\_hud::fontpulseinit();
    oldcount = -1;

    for (;;)
    {
        wait 1;
        count = getplayersneededcount();

        if ( 0 >= count )
            break;

/#
        if ( getdvarint( "scr_pregame_abort" ) > 0 )
        {
            setdvar( "scr_pregame_abort", 0 );
            break;
        }
#/

        if ( oldcount != count )
        {
            level.pregameplayercount setvalue( count );
            level.pregameplayercount thread maps\mp\gametypes\_hud::fontpulse( level );
            oldcount = count;
        }
    }

    level.pregameplayercount settext( "" );
    level.pregamesubtitle settext( game["strings"]["pregameover"] );
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];
        player maps\mp\gametypes\_globallogic_player::freezeplayerforroundend();
        player maps\mp\gametypes\_globallogic_ui::freegameplayhudelems();
    }

    visionsetnaked( "mpIntro", 3 );
    wait 4;
    endpregame();
    pregamestartgame();
    saveplayerspregameinfo();
    map_restart( 0 );
}

onendgame( winner )
{
    endpregame();
}

ontimelimit()
{
    winner = undefined;

    if ( level.teambased )
    {
        winner = maps\mp\gametypes\_globallogic::determineteamwinnerbygamestat( "teamScores" );
        maps\mp\gametypes\_globallogic_utils::logteamwinstring( "time limit", winner );
    }
    else
    {
        winner = maps\mp\gametypes\_globallogic_score::gethighestscoringplayer();

        if ( isdefined( winner ) )
            logstring( "time limit, win: " + winner.name );
        else
            logstring( "time limit, tie" );
    }

    makedvarserverinfo( "ui_text_endreason", game["strings"]["pregame_time_limit_reached"] );
    setdvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );
    thread maps\mp\gametypes\_globallogic::endgame( winner, game["strings"]["pregame_time_limit_reached"] );
}

get_pregame_class()
{
    pclass = self getpregameclass();

    if ( isdefined( pclass ) && pclass[0] != "" )
        return pclass;
    else
        return "smg_mp,0";
}
