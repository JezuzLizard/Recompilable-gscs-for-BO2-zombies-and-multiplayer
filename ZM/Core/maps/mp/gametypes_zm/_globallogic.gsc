// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\_busing;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_tweakables;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\gametypes_zm\_globallogic_spawn;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic_defaults;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\_demo;
#include maps\mp\gametypes_zm\_globallogic_player;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\_music;
#include maps\mp\_challenges;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\gametypes_zm\_serversettings;
#include maps\mp\gametypes_zm\_clientids;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\gametypes_zm\_scoreboard;
#include maps\mp\gametypes_zm\_shellshock;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_gameobjects;
#include maps\mp\gametypes_zm\_spawnlogic;
#include maps\mp\gametypes_zm\_dev;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_globallogic;

init()
{
    if ( !isdefined( level.tweakablesinitialized ) )
        maps\mp\gametypes_zm\_tweakables::init();

    init_session_mode_flags();
    level.splitscreen = issplitscreen();
    level.xenon = getdvar( "xenonGame" ) == "true";
    level.ps3 = getdvar( "ps3Game" ) == "true";
    level.wiiu = getdvar( "wiiuGame" ) == "true";
    level.onlinegame = sessionmodeisonlinegame();
    level.systemlink = sessionmodeissystemlink();
    level.console = level.xenon || level.ps3 || level.wiiu;
    level.rankedmatch = gamemodeisusingxp() && !ispregame();
    level.leaguematch = gamemodeismode( level.gamemode_league_match );
    level.wagermatch = 0;
    level.contractsenabled = !getgametypesetting( "disableContracts" );
    level.contractsenabled = 0;
/#
    if ( getdvarint( "scr_forcerankedmatch" ) == 1 )
        level.rankedmatch = 1;
#/
    level.script = tolower( getdvar( "mapname" ) );
    level.gametype = tolower( getdvar( "g_gametype" ) );
    level.teambased = 0;
    level.teamcount = getgametypesetting( "teamCount" );
    level.multiteam = level.teamcount > 2;

    if ( sessionmodeiszombiesgame() )
    {
        level.zombie_team_index = level.teamcount + 1;

        if ( 2 == level.zombie_team_index )
            level.zombie_team = "axis";
        else
            level.zombie_team = "team" + level.zombie_team_index;
    }

    level.teams = [];
    level.teamindex = [];
    teamcount = level.teamcount;
    level.teams["allies"] = "allies";
    level.teams["axis"] = "axis";
    level.teamindex["neutral"] = 0;
    level.teamindex["allies"] = 1;
    level.teamindex["axis"] = 2;

    for ( teamindex = 3; teamindex <= teamcount; teamindex++ )
    {
        level.teams["team" + teamindex] = "team" + teamindex;
        level.teamindex["team" + teamindex] = teamindex;
    }

    level.overrideteamscore = 0;
    level.overrideplayerscore = 0;
    level.displayhalftimetext = 0;
    level.displayroundendtext = 1;
    level.endgameonscorelimit = 1;
    level.endgameontimelimit = 1;
    level.scoreroundbased = 0;
    level.resetplayerscoreeveryround = 0;
    level.gameforfeited = 0;
    level.forceautoassign = 0;
    level.halftimetype = "halftime";
    level.halftimesubcaption = &"MP_SWITCHING_SIDES_CAPS";
    level.laststatustime = 0;
    level.waswinning = [];
    level.lastslowprocessframe = 0;
    level.placement = [];

    foreach ( team in level.teams )
        level.placement[team] = [];

    level.placement["all"] = [];
    level.postroundtime = 7.0;
    level.inovertime = 0;
    level.defaultoffenseradius = 560;
    level.dropteam = getdvarint( "sv_maxclients" );
    level.infinalkillcam = 0;
    maps\mp\gametypes_zm\_globallogic_ui::init();
    registerdvars();
    level.oldschool = getdvarint( "scr_oldschool" ) == 1;

    if ( level.oldschool )
    {
        logstring( "game mode: oldschool" );
        setdvar( "jump_height", 64 );
        setdvar( "jump_slowdownEnable", 0 );
        setdvar( "bg_fallDamageMinHeight", 256 );
        setdvar( "bg_fallDamageMaxHeight", 512 );
        setdvar( "player_clipSizeMultiplier", 2.0 );
    }

    precachemodel( "tag_origin" );
    precacherumble( "dtp_rumble" );
    precacherumble( "slide_rumble" );
    precachestatusicon( "hud_status_dead" );
    precachestatusicon( "hud_status_connecting" );
    precache_mp_leaderboards();

    if ( !isdefined( game["tiebreaker"] ) )
        game["tiebreaker"] = 0;

    maps\mp\gametypes_zm\_globallogic_audio::registerdialoggroup( "item_destroyed", 1 );
    maps\mp\gametypes_zm\_globallogic_audio::registerdialoggroup( "introboost", 1 );
    maps\mp\gametypes_zm\_globallogic_audio::registerdialoggroup( "status", 1 );
}

registerdvars()
{
    if ( getdvar( "scr_oldschool" ) == "" )
        setdvar( "scr_oldschool", "0" );

    makedvarserverinfo( "scr_oldschool" );

    if ( getdvar( "ui_guncycle" ) == "" )
        setdvar( "ui_guncycle", 0 );

    makedvarserverinfo( "ui_guncycle" );

    if ( getdvar( "ui_weapon_tiers" ) == "" )
        setdvar( "ui_weapon_tiers", 0 );

    makedvarserverinfo( "ui_weapon_tiers" );
    setdvar( "ui_text_endreason", "" );
    makedvarserverinfo( "ui_text_endreason", "" );
    setmatchflag( "bomb_timer", 0 );
    setmatchflag( "enable_popups", 1 );
    setmatchflag( "pregame", ispregame() );

    if ( getdvar( "scr_vehicle_damage_scalar" ) == "" )
        setdvar( "scr_vehicle_damage_scalar", "1" );

    level.vehicledamagescalar = getdvarfloat( "scr_vehicle_damage_scalar" );
    level.fire_audio_repeat_duration = getdvarint( _hash_917E4521 );
    level.fire_audio_random_max_duration = getdvarint( _hash_C2DCBC26 );
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{

}

setupcallbacks()
{
    level.spawnplayer = maps\mp\gametypes_zm\_globallogic_spawn::spawnplayer;
    level.spawnplayerprediction = maps\mp\gametypes_zm\_globallogic_spawn::spawnplayerprediction;
    level.spawnclient = maps\mp\gametypes_zm\_globallogic_spawn::spawnclient;
    level.spawnspectator = maps\mp\gametypes_zm\_globallogic_spawn::spawnspectator;
    level.spawnintermission = maps\mp\gametypes_zm\_globallogic_spawn::spawnintermission;
    level.onplayerscore = maps\mp\gametypes_zm\_globallogic_score::default_onplayerscore;
    level.onteamscore = maps\mp\gametypes_zm\_globallogic_score::default_onteamscore;
    level.wavespawntimer = ::wavespawntimer;
    level.spawnmessage = maps\mp\gametypes_zm\_globallogic_spawn::default_spawnmessage;
    level.onspawnplayer = ::blank;
    level.onspawnplayerunified = ::blank;
    level.onspawnspectator = maps\mp\gametypes_zm\_globallogic_defaults::default_onspawnspectator;
    level.onspawnintermission = maps\mp\gametypes_zm\_globallogic_defaults::default_onspawnintermission;
    level.onrespawndelay = ::blank;
    level.onforfeit = maps\mp\gametypes_zm\_globallogic_defaults::default_onforfeit;
    level.ontimelimit = maps\mp\gametypes_zm\_globallogic_defaults::default_ontimelimit;
    level.onscorelimit = maps\mp\gametypes_zm\_globallogic_defaults::default_onscorelimit;
    level.onalivecountchange = maps\mp\gametypes_zm\_globallogic_defaults::default_onalivecountchange;
    level.ondeadevent = maps\mp\gametypes_zm\_globallogic_defaults::default_ondeadevent;
    level.ononeleftevent = maps\mp\gametypes_zm\_globallogic_defaults::default_ononeleftevent;
    level.giveteamscore = maps\mp\gametypes_zm\_globallogic_score::giveteamscore;
    level.onlastteamaliveevent = undefined;
    level.gettimelimit = maps\mp\gametypes_zm\_globallogic_defaults::default_gettimelimit;
    level.getteamkillpenalty = ::blank;
    level.getteamkillscore = ::blank;
    level.iskillboosting = maps\mp\gametypes_zm\_globallogic_score::default_iskillboosting;
    level._setteamscore = maps\mp\gametypes_zm\_globallogic_score::_setteamscore;
    level._setplayerscore = maps\mp\gametypes_zm\_globallogic_score::_setplayerscore;
    level._getteamscore = maps\mp\gametypes_zm\_globallogic_score::_getteamscore;
    level._getplayerscore = maps\mp\gametypes_zm\_globallogic_score::_getplayerscore;
    level.onprecachegametype = ::blank;
    level.onstartgametype = ::blank;
    level.onplayerconnect = ::blank;
    level.onplayerdisconnect = ::blank;
    level.onplayerdamage = ::blank;
    level.onplayerkilled = ::blank;
    level.onplayerkilledextraunthreadedcbs = [];
    level.onteamoutcomenotify = maps\mp\gametypes_zm\_hud_message::teamoutcomenotify;
    level.onoutcomenotify = maps\mp\gametypes_zm\_hud_message::outcomenotify;
    level.onteamwageroutcomenotify = maps\mp\gametypes_zm\_hud_message::teamwageroutcomenotify;
    level.onwageroutcomenotify = maps\mp\gametypes_zm\_hud_message::wageroutcomenotify;
    level.setmatchscorehudelemforteam = maps\mp\gametypes_zm\_hud_message::setmatchscorehudelemforteam;
    level.onendgame = ::blank;
    level.onroundendgame = maps\mp\gametypes_zm\_globallogic_defaults::default_onroundendgame;
    level.onmedalawarded = ::blank;
    maps\mp\gametypes_zm\_globallogic_ui::setupcallbacks();
}

precache_mp_leaderboards()
{
    if ( sessionmodeiszombiesgame() )
        return;

    if ( !level.rankedmatch )
        return;

    mapname = getdvar( "mapname" );
    globalleaderboards = "LB_MP_GB_XPPRESTIGE LB_MP_GB_TOTALXP_AT LB_MP_GB_TOTALXP_LT LB_MP_GB_WINS_AT LB_MP_GB_WINS_LT LB_MP_GB_KILLS_AT LB_MP_GB_KILLS_LT LB_MP_GB_ACCURACY_AT LB_MP_GB_ACCURACY_LT";
    gamemodeleaderboard = " LB_MP_GM_" + level.gametype;

    if ( getdvarint( _hash_46E18E53 ) )
        gamemodeleaderboard += "_HC";

    mapleaderboard = " LB_MP_MAP_" + getsubstr( mapname, 3, mapname.size );
    precacheleaderboards( globalleaderboards + gamemodeleaderboard + mapleaderboard );
}

compareteambygamestat( gamestat, teama, teamb, previous_winner_score )
{
    winner = undefined;

    if ( teama == "tie" )
    {
        winner = "tie";

        if ( previous_winner_score < game[gamestat][teamb] )
            winner = teamb;
    }
    else if ( game[gamestat][teama] == game[gamestat][teamb] )
        winner = "tie";
    else if ( game[gamestat][teamb] > game[gamestat][teama] )
        winner = teamb;
    else
        winner = teama;

    return winner;
}

determineteamwinnerbygamestat( gamestat )
{
    teamkeys = getarraykeys( level.teams );
    winner = teamkeys[0];
    previous_winner_score = game[gamestat][winner];

    for ( teamindex = 1; teamindex < teamkeys.size; teamindex++ )
    {
        winner = compareteambygamestat( gamestat, winner, teamkeys[teamindex], previous_winner_score );

        if ( winner != "tie" )
            previous_winner_score = game[gamestat][winner];
    }

    return winner;
}

compareteambyteamscore( teama, teamb, previous_winner_score )
{
    winner = undefined;
    teambscore = [[ level._getteamscore ]]( teamb );

    if ( teama == "tie" )
    {
        winner = "tie";

        if ( previous_winner_score < teambscore )
            winner = teamb;

        return winner;
    }

    teamascore = [[ level._getteamscore ]]( teama );

    if ( teambscore == teamascore )
        winner = "tie";
    else if ( teambscore > teamascore )
        winner = teamb;
    else
        winner = teama;

    return winner;
}

determineteamwinnerbyteamscore()
{
    teamkeys = getarraykeys( level.teams );
    winner = teamkeys[0];
    previous_winner_score = [[ level._getteamscore ]]( winner );

    for ( teamindex = 1; teamindex < teamkeys.size; teamindex++ )
    {
        winner = compareteambyteamscore( winner, teamkeys[teamindex], previous_winner_score );

        if ( winner != "tie" )
            previous_winner_score = [[ level._getteamscore ]]( winner );
    }

    return winner;
}

forceend( hostsucks )
{
    if ( !isdefined( hostsucks ) )
        hostsucks = 0;

    if ( level.hostforcedend || level.forcedend )
        return;

    winner = undefined;

    if ( level.teambased )
    {
        winner = determineteamwinnerbygamestat( "teamScores" );
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "host ended game", winner );
    }
    else
    {
        winner = maps\mp\gametypes_zm\_globallogic_score::gethighestscoringplayer();

        if ( isdefined( winner ) )
            logstring( "host ended game, win: " + winner.name );
        else
            logstring( "host ended game, tie" );
    }

    level.forcedend = 1;
    level.hostforcedend = 1;

    if ( hostsucks )
        endstring = &"MP_HOST_SUCKS";
    else if ( level.splitscreen )
        endstring = &"MP_ENDED_GAME";
    else
        endstring = &"MP_HOST_ENDED_GAME";

    setmatchflag( "disableIngameMenu", 1 );
    makedvarserverinfo( "ui_text_endreason", endstring );
    setdvar( "ui_text_endreason", endstring );
    thread endgame( winner, endstring );
}

killserverpc()
{
    if ( level.hostforcedend || level.forcedend )
        return;

    winner = undefined;

    if ( level.teambased )
    {
        winner = determineteamwinnerbygamestat( "teamScores" );
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "host ended game", winner );
    }
    else
    {
        winner = maps\mp\gametypes_zm\_globallogic_score::gethighestscoringplayer();

        if ( isdefined( winner ) )
            logstring( "host ended game, win: " + winner.name );
        else
            logstring( "host ended game, tie" );
    }

    level.forcedend = 1;
    level.hostforcedend = 1;
    level.killserver = 1;
    endstring = &"MP_HOST_ENDED_GAME";
/#
    println( "kill server; ending game\\n" );
#/
    thread endgame( winner, endstring );
}

someoneoneachteam()
{
    foreach ( team in level.teams )
    {
        if ( level.playercount[team] == 0 )
            return false;
    }

    return true;
}

checkifteamforfeits( team )
{
    if ( !level.everexisted[team] )
        return false;

    if ( level.playercount[team] < 1 && totalplayercount() > 0 )
        return true;

    return false;
}

checkforanyteamforfeit()
{
    foreach ( team in level.teams )
    {
        if ( checkifteamforfeits( team ) )
        {
            thread [[ level.onforfeit ]]( team );
            return true;
        }
    }

    return false;
}

dospawnqueueupdates()
{
    foreach ( team in level.teams )
    {
        if ( level.spawnqueuemodified[team] )
            [[ level.onalivecountchange ]]( team );
    }
}

isteamalldead( team )
{
    return level.everexisted[team] && !level.alivecount[team] && !level.playerlives[team];
}

areallteamsdead()
{
    foreach ( team in level.teams )
    {
        if ( !isteamalldead( team ) )
            return false;
    }

    return true;
}

alldeadteamcount()
{
    count = 0;

    foreach ( team in level.teams )
    {
        if ( isteamalldead( team ) )
            count++;
    }

    return count;
}

dodeadeventupdates()
{
    if ( level.teambased )
    {
        if ( areallteamsdead() )
        {
            [[ level.ondeadevent ]]( "all" );
            return true;
        }

        if ( isdefined( level.onlastteamaliveevent ) )
        {
            if ( alldeadteamcount() == level.teams.size - 1 )
            {
                foreach ( team in level.teams )
                {
                    if ( !isteamalldead( team ) )
                    {
                        [[ level.onlastteamaliveevent ]]( team );
                        return true;
                    }
                }
            }
        }
        else
        {
            foreach ( team in level.teams )
            {
                if ( isteamalldead( team ) )
                {
                    [[ level.ondeadevent ]]( team );
                    return true;
                }
            }
        }
    }
    else if ( totalalivecount() == 0 && totalplayerlives() == 0 && level.maxplayercount > 1 )
    {
        [[ level.ondeadevent ]]( "all" );
        return true;
    }

    return false;
}

isonlyoneleftaliveonteam( team )
{
    return level.lastalivecount[team] > 1 && level.alivecount[team] == 1 && level.playerlives[team] == 1;
}

doonelefteventupdates()
{
    if ( level.teambased )
    {
        foreach ( team in level.teams )
        {
            if ( isonlyoneleftaliveonteam( team ) )
            {
                [[ level.ononeleftevent ]]( team );
                return true;
            }
        }
    }
    else if ( totalalivecount() == 1 && totalplayerlives() == 1 && level.maxplayercount > 1 )
    {
        [[ level.ononeleftevent ]]( "all" );
        return true;
    }

    return false;
}

updategameevents()
{
/#
    if ( getdvarint( "scr_hostmigrationtest" ) == 1 )
        return;
#/
    if ( ( level.rankedmatch || level.wagermatch || level.leaguematch ) && !level.ingraceperiod )
    {
        if ( level.teambased )
        {
            if ( !level.gameforfeited )
            {
                if ( game["state"] == "playing" && checkforanyteamforfeit() )
                    return;
            }
            else if ( someoneoneachteam() )
            {
                level.gameforfeited = 0;
                level notify( "abort forfeit" );
            }
        }
        else if ( !level.gameforfeited )
        {
            if ( totalplayercount() == 1 && level.maxplayercount > 1 )
            {
                thread [[ level.onforfeit ]]();
                return;
            }
        }
        else if ( totalplayercount() > 1 )
        {
            level.gameforfeited = 0;
            level notify( "abort forfeit" );
        }
    }

    if ( !level.playerqueuedrespawn && !level.numlives && !level.inovertime )
        return;

    if ( level.ingraceperiod )
        return;

    if ( level.playerqueuedrespawn )
        dospawnqueueupdates();

    if ( dodeadeventupdates() )
        return;

    if ( doonelefteventupdates() )
        return;
}

matchstarttimer()
{
    visionsetnaked( "mpIntro", 0 );
    matchstarttext = createserverfontstring( "objective", 1.5 );
    matchstarttext setpoint( "CENTER", "CENTER", 0, -40 );
    matchstarttext.sort = 1001;
    matchstarttext settext( game["strings"]["waiting_for_teams"] );
    matchstarttext.foreground = 0;
    matchstarttext.hidewheninmenu = 1;
    waitforplayers();
    matchstarttext settext( game["strings"]["match_starting_in"] );
    matchstarttimer = createserverfontstring( "objective", 2.2 );
    matchstarttimer setpoint( "CENTER", "CENTER", 0, 0 );
    matchstarttimer.sort = 1001;
    matchstarttimer.color = ( 1, 1, 0 );
    matchstarttimer.foreground = 0;
    matchstarttimer.hidewheninmenu = 1;
    counttime = int( level.prematchperiod );

    if ( counttime >= 2 )
    {
        while ( counttime > 0 && !level.gameended )
        {
            matchstarttimer setvalue( counttime );

            if ( counttime == 2 )
                visionsetnaked( getdvar( "mapname" ), 3.0 );

            counttime--;
            wait 1.0;
        }
    }
    else
        visionsetnaked( getdvar( "mapname" ), 1.0 );

    matchstarttimer destroyelem();
    matchstarttext destroyelem();
}

matchstarttimerskip()
{
    if ( !ispregame() )
        visionsetnaked( getdvar( "mapname" ), 0 );
    else
        visionsetnaked( "mpIntro", 0 );
}

notifyteamwavespawn( team, time )
{
    if ( time - level.lastwave[team] > level.wavedelay[team] * 1000 )
    {
        level notify( "wave_respawn_" + team );
        level.lastwave[team] = time;
        level.waveplayerspawnindex[team] = 0;
    }
}

wavespawntimer()
{
    level endon( "game_ended" );

    while ( game["state"] == "playing" )
    {
        time = gettime();

        foreach ( team in level.teams )
            notifyteamwavespawn( team, time );

        wait 0.05;
    }
}

hostidledout()
{
    hostplayer = gethostplayer();
/#
    if ( getdvarint( "scr_writeConfigStrings" ) == 1 || getdvarint( "scr_hostmigrationtest" ) == 1 )
        return false;
#/
    if ( isdefined( hostplayer ) && !hostplayer.hasspawned && !isdefined( hostplayer.selectedclass ) )
        return true;

    return false;
}

incrementmatchcompletionstat( gamemode, playedorhosted, stat )
{
    self adddstat( "gameHistory", gamemode, "modeHistory", playedorhosted, stat, 1 );
}

setmatchcompletionstat( gamemode, playedorhosted, stat )
{
    self setdstat( "gameHistory", gamemode, "modeHistory", playedorhosted, stat, 1 );
}

getcurrentgamemode()
{
    return "publicmatch";
}

displayroundend( winner, endreasontext )
{
    if ( level.displayroundendtext )
    {
        if ( winner == "tie" )
            maps\mp\_demo::gameresultbookmark( "round_result", level.teamindex["neutral"], level.teamindex["neutral"] );
        else
            maps\mp\_demo::gameresultbookmark( "round_result", level.teamindex[winner], level.teamindex["neutral"] );

        setmatchflag( "cg_drawSpectatorMessages", 0 );
        players = level.players;

        for ( index = 0; index < players.size; index++ )
        {
            player = players[index];

            if ( !isdefined( player.pers["team"] ) )
            {
                player [[ level.spawnintermission ]]( 1 );
                player closemenu();
                player closeingamemenu();
                continue;
            }

            if ( level.wagermatch )
            {
                if ( level.teambased )
                    player thread [[ level.onteamwageroutcomenotify ]]( winner, 1, endreasontext );
                else
                    player thread [[ level.onwageroutcomenotify ]]( winner, endreasontext );
            }
            else if ( level.teambased )
            {
                player thread [[ level.onteamoutcomenotify ]]( winner, 1, endreasontext );
                player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "ROUND_END" );
            }
            else
            {
                player thread [[ level.onoutcomenotify ]]( winner, 1, endreasontext );
                player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "ROUND_END" );
            }

            player setclientuivisibilityflag( "hud_visible", 0 );
            player setclientuivisibilityflag( "g_compassShowEnemies", 0 );
        }
    }

    if ( waslastround() )
        roundendwait( level.roundenddelay, 0 );
    else
    {
        thread maps\mp\gametypes_zm\_globallogic_audio::announceroundwinner( winner, level.roundenddelay / 4 );
        roundendwait( level.roundenddelay, 1 );
    }
}

displayroundswitch( winner, endreasontext )
{
    switchtype = level.halftimetype;

    if ( switchtype == "halftime" )
    {
        if ( isdefined( level.nextroundisovertime ) && level.nextroundisovertime )
            switchtype = "overtime";
        else if ( level.roundlimit )
        {
            if ( game["roundsplayed"] * 2 == level.roundlimit )
                switchtype = "halftime";
            else
                switchtype = "intermission";
        }
        else if ( level.scorelimit )
        {
            if ( game["roundsplayed"] == level.scorelimit - 1 )
                switchtype = "halftime";
            else
                switchtype = "intermission";
        }
        else
            switchtype = "intermission";
    }

    leaderdialog = maps\mp\gametypes_zm\_globallogic_audio::getroundswitchdialog( switchtype );
    setmatchtalkflag( "EveryoneHearsEveryone", 1 );
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];

        if ( !isdefined( player.pers["team"] ) )
        {
            player [[ level.spawnintermission ]]( 1 );
            player closemenu();
            player closeingamemenu();
            continue;
        }

        player maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( leaderdialog );
        player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "ROUND_SWITCH" );

        if ( level.wagermatch )
            player thread [[ level.onteamwageroutcomenotify ]]( switchtype, 1, level.halftimesubcaption );
        else
            player thread [[ level.onteamoutcomenotify ]]( switchtype, 0, level.halftimesubcaption );

        player setclientuivisibilityflag( "hud_visible", 0 );
    }

    roundendwait( level.halftimeroundenddelay, 0 );
}

displaygameend( winner, endreasontext )
{
    setmatchtalkflag( "EveryoneHearsEveryone", 1 );
    setmatchflag( "cg_drawSpectatorMessages", 0 );

    if ( winner == "tie" )
        maps\mp\_demo::gameresultbookmark( "game_result", level.teamindex["neutral"], level.teamindex["neutral"] );
    else
        maps\mp\_demo::gameresultbookmark( "game_result", level.teamindex[winner], level.teamindex["neutral"] );

    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];

        if ( !isdefined( player.pers["team"] ) )
        {
            player [[ level.spawnintermission ]]( 1 );
            player closemenu();
            player closeingamemenu();
            continue;
        }

        if ( level.wagermatch )
        {
            if ( level.teambased )
                player thread [[ level.onteamwageroutcomenotify ]]( winner, 0, endreasontext );
            else
                player thread [[ level.onwageroutcomenotify ]]( winner, endreasontext );
        }
        else if ( level.teambased )
            player thread [[ level.onteamoutcomenotify ]]( winner, 0, endreasontext );
        else
        {
            player thread [[ level.onoutcomenotify ]]( winner, 0, endreasontext );

            if ( isdefined( winner ) && player == winner )
                player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "VICTORY" );
            else if ( !level.splitscreen )
                player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "LOSE" );
        }

        player setclientuivisibilityflag( "hud_visible", 0 );
        player setclientuivisibilityflag( "g_compassShowEnemies", 0 );
    }

    if ( level.teambased )
    {
        thread maps\mp\gametypes_zm\_globallogic_audio::announcegamewinner( winner, level.postroundtime / 2 );
        players = level.players;

        for ( index = 0; index < players.size; index++ )
        {
            player = players[index];
            team = player.pers["team"];

            if ( level.splitscreen )
            {
                if ( winner == "tie" )
                    player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "DRAW" );
                else if ( winner == team )
                    player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "VICTORY" );
                else
                    player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "LOSE" );

                continue;
            }

            if ( winner == "tie" )
            {
                player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "DRAW" );
                continue;
            }

            if ( winner == team )
            {
                player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "VICTORY" );
                continue;
            }

            player maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "LOSE" );
        }
    }

    bbprint( "session_epilogs", "reason %s", endreasontext );
    bbprint( "mpmatchfacts", "gametime %d winner %s killstreakcount %d", gettime(), winner, level.killstreak_counter );
    roundendwait( level.postroundtime, 1 );
}

getendreasontext()
{
    if ( hitroundlimit() || hitroundwinlimit() )
        return game["strings"]["round_limit_reached"];
    else if ( hitscorelimit() )
        return game["strings"]["score_limit_reached"];

    if ( level.forcedend )
    {
        if ( level.hostforcedend )
            return &"MP_HOST_ENDED_GAME";
        else
            return &"MP_ENDED_GAME";
    }

    return game["strings"]["time_limit_reached"];
}

resetoutcomeforallplayers()
{
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];
        player notify( "reset_outcome" );
    }
}

startnextround( winner, endreasontext )
{
    if ( !isoneround() )
    {
        displayroundend( winner, endreasontext );
        maps\mp\gametypes_zm\_globallogic_utils::executepostroundevents();

        if ( !waslastround() )
        {
            if ( checkroundswitch() )
                displayroundswitch( winner, endreasontext );

            if ( isdefined( level.nextroundisovertime ) && level.nextroundisovertime )
            {
                if ( !isdefined( game["overtime_round"] ) )
                    game["overtime_round"] = 1;
                else
                    game["overtime_round"]++;
            }

            setmatchtalkflag( "DeadChatWithDead", level.voip.deadchatwithdead );
            setmatchtalkflag( "DeadChatWithTeam", level.voip.deadchatwithteam );
            setmatchtalkflag( "DeadHearTeamLiving", level.voip.deadhearteamliving );
            setmatchtalkflag( "DeadHearAllLiving", level.voip.deadhearallliving );
            setmatchtalkflag( "EveryoneHearsEveryone", level.voip.everyonehearseveryone );
            setmatchtalkflag( "DeadHearKiller", level.voip.deadhearkiller );
            setmatchtalkflag( "KillersHearVictim", level.voip.killershearvictim );
            game["state"] = "playing";
            level.allowbattlechatter = getgametypesetting( "allowBattleChatter" );
            map_restart( 1 );
            return true;
        }
    }

    return false;
}

settopplayerstats()
{
    if ( level.rankedmatch || level.wagermatch )
    {
        placement = level.placement["all"];
        topthreeplayers = min( 3, placement.size );

        for ( index = 0; index < topthreeplayers; index++ )
        {
            if ( level.placement["all"][index].score )
            {
                if ( !index )
                {
                    level.placement["all"][index] addplayerstatwithgametype( "TOPPLAYER", 1 );
                    level.placement["all"][index] notify( "topplayer" );
                }
                else
                    level.placement["all"][index] notify( "nottopplayer" );

                level.placement["all"][index] addplayerstatwithgametype( "TOP3", 1 );
                level.placement["all"][index] notify( "top3" );
            }
        }

        for ( index = 3; index < placement.size; index++ )
        {
            level.placement["all"][index] notify( "nottop3" );
            level.placement["all"][index] notify( "nottopplayer" );
        }

        if ( level.teambased )
        {
            foreach ( team in level.teams )
                settopteamstats( team );
        }
    }
}

settopteamstats( team )
{
    placementteam = level.placement[team];
    topthreeteamplayers = min( 3, placementteam.size );

    if ( placementteam.size < 5 )
        return;

    for ( index = 0; index < topthreeteamplayers; index++ )
    {
        if ( placementteam[index].score )
            placementteam[index] addplayerstatwithgametype( "TOP3TEAM", 1 );
    }
}

getgamelength()
{
    if ( !level.timelimit || level.forcedend )
    {
        gamelength = maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() / 1000;
        gamelength = min( gamelength, 1200 );
    }
    else
        gamelength = level.timelimit * 60;

    return gamelength;
}

gamehistoryplayerquit()
{
    if ( !gamemodeismode( level.gamemode_public_match ) )
        return;

    teamscoreratio = 0;
    self gamehistoryfinishmatch( 3, 0, 0, 0, 0, teamscoreratio );

    if ( isdefined( self.pers["matchesPlayedStatsTracked"] ) )
    {
        gamemode = getcurrentgamemode();
        self incrementmatchcompletionstat( gamemode, "played", "quit" );

        if ( isdefined( self.pers["matchesHostedStatsTracked"] ) )
        {
            self incrementmatchcompletionstat( gamemode, "hosted", "quit" );
            self.pers["matchesHostedStatsTracked"] = undefined;
        }

        self.pers["matchesPlayedStatsTracked"] = undefined;
    }

    uploadstats( self );
    wait 1;
}

endgame( winner, endreasontext )
{
    if ( game["state"] == "postgame" || level.gameended )
        return;

    if ( isdefined( level.onendgame ) )
        [[ level.onendgame ]]( winner );

    if ( !level.wagermatch )
        setmatchflag( "enable_popups", 0 );

    if ( !isdefined( level.disableoutrovisionset ) || level.disableoutrovisionset == 0 )
    {
        if ( sessionmodeiszombiesgame() && level.forcedend )
            visionsetnaked( "zombie_last_stand", 2.0 );
        else
            visionsetnaked( "mpOutro", 2.0 );
    }

    setmatchflag( "cg_drawSpectatorMessages", 0 );
    setmatchflag( "game_ended", 1 );
    game["state"] = "postgame";
    level.gameendtime = gettime();
    level.gameended = 1;
    setdvar( "g_gameEnded", 1 );
    level.ingraceperiod = 0;
    level notify( "game_ended" );
    level.allowbattlechatter = 0;
    maps\mp\gametypes_zm\_globallogic_audio::flushdialog();

    if ( !isdefined( game["overtime_round"] ) || waslastround() )
    {
        game["roundsplayed"]++;
        game["roundwinner"][game["roundsplayed"]] = winner;

        if ( level.teambased )
            game["roundswon"][winner]++;
    }

    if ( isdefined( winner ) && isdefined( level.teams[winner] ) )
        level.finalkillcam_winner = winner;
    else
        level.finalkillcam_winner = "none";

    setgameendtime( 0 );
    updateplacement();
    updaterankedmatch( winner );
    players = level.players;
    newtime = gettime();
    gamelength = getgamelength();
    setmatchtalkflag( "EveryoneHearsEveryone", 1 );
    bbgameover = 0;

    if ( isoneround() || waslastround() )
    {
        bbgameover = 1;

        if ( level.teambased )
        {
            if ( winner == "tie" )
                recordgameresult( "draw" );
            else
                recordgameresult( winner );
        }
        else if ( !isdefined( winner ) )
            recordgameresult( "draw" );
        else
            recordgameresult( winner.team );
    }

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];
        player maps\mp\gametypes_zm\_globallogic_player::freezeplayerforroundend();
        player thread roundenddof( 4.0 );
        player maps\mp\gametypes_zm\_globallogic_ui::freegameplayhudelems();
        player maps\mp\gametypes_zm\_weapons::updateweapontimings( newtime );
        player bbplayermatchend( gamelength, endreasontext, bbgameover );

        if ( ispregame() )
            continue;

        if ( ( level.rankedmatch || level.wagermatch || level.leaguematch ) && !player issplitscreen() )
        {
            if ( isdefined( player.setpromotion ) )
            {
                player setdstat( "AfterActionReportStats", "lobbyPopup", "promotion" );
                continue;
            }

            player setdstat( "AfterActionReportStats", "lobbyPopup", "summary" );
        }
    }

    maps\mp\_music::setmusicstate( "SILENT" );

    if ( !level.infinalkillcam )
    {

    }

    thread maps\mp\_challenges::roundend( winner );

    if ( startnextround( winner, endreasontext ) )
        return;

    if ( !isoneround() )
    {
        if ( isdefined( level.onroundendgame ) )
            winner = [[ level.onroundendgame ]]( winner );

        endreasontext = getendreasontext();
    }

    skillupdate( winner, level.teambased );
    recordleaguewinner( winner );
    settopplayerstats();
    thread maps\mp\_challenges::gameend( winner );

    if ( isdefined( winner ) && ( !isdefined( level.skipgameend ) || !level.skipgameend ) )
        displaygameend( winner, endreasontext );

    if ( isoneround() )
        maps\mp\gametypes_zm\_globallogic_utils::executepostroundevents();

    level.intermission = 1;
    setmatchtalkflag( "EveryoneHearsEveryone", 1 );
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];
        recordplayerstats( player, "presentAtEnd", 1 );
        player closemenu();
        player closeingamemenu();
        player notify( "reset_outcome" );
        player thread [[ level.spawnintermission ]]();
        player setclientuivisibilityflag( "hud_visible", 1 );
    }

    level notify( "sfade" );
    logstring( "game ended" );

    if ( !isdefined( level.skipgameend ) || !level.skipgameend )
        wait 5.0;

    exitlevel( 0 );
}

bbplayermatchend( gamelength, endreasonstring, gameover )
{
    playerrank = getplacementforplayer( self );
    totaltimeplayed = 0;

    if ( isdefined( self.timeplayed ) && isdefined( self.timeplayed["total"] ) )
    {
        totaltimeplayed = self.timeplayed["total"];

        if ( totaltimeplayed > gamelength )
            totaltimeplayed = gamelength;
    }

    xuid = self getxuid();
    bbprint( "mpplayermatchfacts", "score %d momentum %d endreason %s sessionrank %d playtime %d xuid %s gameover %d team %s", self.pers["score"], self.pers["momentum"], endreasonstring, playerrank, totaltimeplayed, xuid, gameover, self.pers["team"] );
}

roundendwait( defaultdelay, matchbonus )
{
    notifiesdone = 0;

    while ( !notifiesdone )
    {
        players = level.players;
        notifiesdone = 1;

        for ( index = 0; index < players.size; index++ )
        {
            if ( !isdefined( players[index].doingnotify ) || !players[index].doingnotify )
                continue;

            notifiesdone = 0;
        }

        wait 0.5;
    }

    if ( !matchbonus )
    {
        wait( defaultdelay );
        level notify( "round_end_done" );
        return;
    }

    wait( defaultdelay / 2 );
    level notify( "give_match_bonus" );
    wait( defaultdelay / 2 );
    notifiesdone = 0;

    while ( !notifiesdone )
    {
        players = level.players;
        notifiesdone = 1;

        for ( index = 0; index < players.size; index++ )
        {
            if ( !isdefined( players[index].doingnotify ) || !players[index].doingnotify )
                continue;

            notifiesdone = 0;
        }

        wait 0.5;
    }

    level notify( "round_end_done" );
}

roundenddof( time )
{
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

checktimelimit()
{
    if ( isdefined( level.timelimitoverride ) && level.timelimitoverride )
        return;

    if ( game["state"] != "playing" )
    {
        setgameendtime( 0 );
        return;
    }

    if ( level.timelimit <= 0 )
    {
        setgameendtime( 0 );
        return;
    }

    if ( level.inprematchperiod )
    {
        setgameendtime( 0 );
        return;
    }

    if ( level.timerstopped )
    {
        setgameendtime( 0 );
        return;
    }

    if ( !isdefined( level.starttime ) )
        return;

    timeleft = maps\mp\gametypes_zm\_globallogic_utils::gettimeremaining();
    setgameendtime( gettime() + int( timeleft ) );

    if ( timeleft > 0 )
        return;

    [[ level.ontimelimit ]]();
}

allteamsunderscorelimit()
{
    foreach ( team in level.teams )
    {
        if ( game["teamScores"][team] >= level.scorelimit )
            return false;
    }

    return true;
}

checkscorelimit()
{
    if ( game["state"] != "playing" )
        return false;

    if ( level.scorelimit <= 0 )
        return false;

    if ( level.teambased )
    {
        if ( allteamsunderscorelimit() )
            return false;
    }
    else
    {
        if ( !isplayer( self ) )
            return false;

        if ( self.score < level.scorelimit )
            return false;
    }

    [[ level.onscorelimit ]]();
}

updategametypedvars()
{
    level endon( "game_ended" );

    while ( game["state"] == "playing" )
    {
        roundlimit = clamp( getgametypesetting( "roundLimit" ), level.roundlimitmin, level.roundlimitmax );

        if ( roundlimit != level.roundlimit )
        {
            level.roundlimit = roundlimit;
            level notify( "update_roundlimit" );
        }

        timelimit = [[ level.gettimelimit ]]();

        if ( timelimit != level.timelimit )
        {
            level.timelimit = timelimit;
            setdvar( "ui_timelimit", level.timelimit );
            level notify( "update_timelimit" );
        }

        thread checktimelimit();
        scorelimit = clamp( getgametypesetting( "scoreLimit" ), level.scorelimitmin, level.scorelimitmax );

        if ( scorelimit != level.scorelimit )
        {
            level.scorelimit = scorelimit;
            setdvar( "ui_scorelimit", level.scorelimit );
            level notify( "update_scorelimit" );
        }

        thread checkscorelimit();

        if ( isdefined( level.starttime ) )
        {
            if ( maps\mp\gametypes_zm\_globallogic_utils::gettimeremaining() < 3000 )
            {
                wait 0.1;
                continue;
            }
        }

        wait 1;
    }
}

removedisconnectedplayerfromplacement()
{
    offset = 0;
    numplayers = level.placement["all"].size;
    found = 0;

    for ( i = 0; i < numplayers; i++ )
    {
        if ( level.placement["all"][i] == self )
            found = 1;

        if ( found )
            level.placement["all"][i] = level.placement["all"][i + 1];
    }

    if ( !found )
        return;

    level.placement["all"][numplayers - 1] = undefined;
    assert( level.placement["all"].size == numplayers - 1 );
/#
    maps\mp\gametypes_zm\_globallogic_utils::assertproperplacement();
#/
    updateteamplacement();

    if ( level.teambased )
        return;

    numplayers = level.placement["all"].size;

    for ( i = 0; i < numplayers; i++ )
    {
        player = level.placement["all"][i];
        player notify( "update_outcome" );
    }
}

updateplacement()
{
    if ( !level.players.size )
        return;

    level.placement["all"] = [];

    for ( index = 0; index < level.players.size; index++ )
    {
        if ( isdefined( level.teams[level.players[index].team] ) )
            level.placement["all"][level.placement["all"].size] = level.players[index];
    }

    placementall = level.placement["all"];

    for ( i = 1; i < placementall.size; i++ )
    {
        player = placementall[i];
        playerscore = player.score;

        for ( j = i - 1; j >= 0 && ( playerscore > placementall[j].score || playerscore == placementall[j].score && player.deaths < placementall[j].deaths ); j-- )
            placementall[j + 1] = placementall[j];

        placementall[j + 1] = player;
    }

    level.placement["all"] = placementall;
/#
    maps\mp\gametypes_zm\_globallogic_utils::assertproperplacement();
#/
    updateteamplacement();
}

updateteamplacement()
{
    foreach ( team in level.teams )
        placement[team] = [];

    placement["spectator"] = [];

    if ( !level.teambased )
        return;

    placementall = level.placement["all"];
    placementallsize = placementall.size;

    for ( i = 0; i < placementallsize; i++ )
    {
        player = placementall[i];

        if ( isdefined( player ) )
        {
            team = player.pers["team"];
            placement[team][placement[team].size] = player;
        }
    }

    foreach ( team in level.teams )
        level.placement[team] = placement[team];
}

getplacementforplayer( player )
{
    updateplacement();
    playerrank = -1;
    placement = level.placement["all"];

    for ( placementindex = 0; placementindex < placement.size; placementindex++ )
    {
        if ( level.placement["all"][placementindex] == player )
        {
            playerrank = placementindex + 1;
            break;
        }
    }

    return playerrank;
}

sortdeadplayers( team )
{
    if ( !level.playerqueuedrespawn )
        return;

    for ( i = 1; i < level.deadplayers[team].size; i++ )
    {
        player = level.deadplayers[team][i];

        for ( j = i - 1; j >= 0 && player.deathtime < level.deadplayers[team][j].deathtime; j-- )
            level.deadplayers[team][j + 1] = level.deadplayers[team][j];

        level.deadplayers[team][j + 1] = player;
    }

    for ( i = 0; i < level.deadplayers[team].size; i++ )
    {
        if ( level.deadplayers[team][i].spawnqueueindex != i )
            level.spawnqueuemodified[team] = 1;

        level.deadplayers[team][i].spawnqueueindex = i;
    }
}

totalalivecount()
{
    count = 0;

    foreach ( team in level.teams )
        count += level.alivecount[team];

    return count;
}

totalplayerlives()
{
    count = 0;

    foreach ( team in level.teams )
        count += level.playerlives[team];

    return count;
}

totalplayercount()
{
    count = 0;

    foreach ( team in level.teams )
        count += level.playercount[team];

    return count;
}

initteamvariables( team )
{
    if ( !isdefined( level.alivecount ) )
        level.alivecount = [];

    level.alivecount[team] = 0;
    level.lastalivecount[team] = 0;
    level.everexisted[team] = 0;
    level.wavedelay[team] = 0;
    level.lastwave[team] = 0;
    level.waveplayerspawnindex[team] = 0;
    resetteamvariables( team );
}

resetteamvariables( team )
{
    level.playercount[team] = 0;
    level.botscount[team] = 0;
    level.lastalivecount[team] = level.alivecount[team];
    level.alivecount[team] = 0;
    level.playerlives[team] = 0;
    level.aliveplayers[team] = [];
    level.deadplayers[team] = [];
    level.squads[team] = [];
    level.spawnqueuemodified[team] = 0;
}

updateteamstatus()
{
    level notify( "updating_team_status" );
    level endon( "updating_team_status" );
    level endon( "game_ended" );
    waittillframeend;
    wait 0;

    if ( game["state"] == "postgame" )
        return;

    resettimeout();

    foreach ( team in level.teams )
        resetteamvariables( team );

    level.activeplayers = [];
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( !isdefined( player ) && level.splitscreen )
            continue;

        team = player.team;
        class = player.class;

        if ( team != "spectator" && ( isdefined( class ) && class != "" ) )
        {
            level.playercount[team]++;

            if ( isdefined( player.pers["isBot"] ) )
                level.botscount[team]++;

            if ( player.sessionstate == "playing" )
            {
                level.alivecount[team]++;
                level.playerlives[team]++;
                player.spawnqueueindex = -1;

                if ( isalive( player ) )
                {
                    level.aliveplayers[team][level.aliveplayers[team].size] = player;
                    level.activeplayers[level.activeplayers.size] = player;
                }
                else
                    level.deadplayers[team][level.deadplayers[team].size] = player;

                continue;
            }

            level.deadplayers[team][level.deadplayers[team].size] = player;

            if ( player maps\mp\gametypes_zm\_globallogic_spawn::mayspawn() )
                level.playerlives[team]++;
        }
    }

    totalalive = totalalivecount();

    if ( totalalive > level.maxplayercount )
        level.maxplayercount = totalalive;

    foreach ( team in level.teams )
    {
        if ( level.alivecount[team] )
            level.everexisted[team] = 1;

        sortdeadplayers( team );
    }

    level updategameevents();
}

checkteamscorelimitsoon( team )
{
    assert( isdefined( team ) );

    if ( level.scorelimit <= 0 )
        return;

    if ( !level.teambased )
        return;

    if ( maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() < 60000 )
        return;

    timeleft = maps\mp\gametypes_zm\_globallogic_utils::getestimatedtimeuntilscorelimit( team );

    if ( timeleft < 1 )
        level notify( "match_ending_soon", "score" );
}

checkplayerscorelimitsoon()
{
    assert( isplayer( self ) );

    if ( level.scorelimit <= 0 )
        return;

    if ( level.teambased )
        return;

    if ( maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() < 60000 )
        return;

    timeleft = maps\mp\gametypes_zm\_globallogic_utils::getestimatedtimeuntilscorelimit( undefined );

    if ( timeleft < 1 )
        level notify( "match_ending_soon", "score" );
}

timelimitclock()
{
    level endon( "game_ended" );
    wait 0.05;
    clockobject = spawn( "script_origin", ( 0, 0, 0 ) );

    while ( game["state"] == "playing" )
    {
        if ( !level.timerstopped && level.timelimit )
        {
            timeleft = maps\mp\gametypes_zm\_globallogic_utils::gettimeremaining() / 1000;
            timeleftint = int( timeleft + 0.5 );

            if ( timeleftint == 601 )
                clientnotify( "notify_10" );

            if ( timeleftint == 301 )
                clientnotify( "notify_5" );

            if ( timeleftint == 60 )
                clientnotify( "notify_1" );

            if ( timeleftint == 12 )
                clientnotify( "notify_count" );

            if ( timeleftint >= 40 && timeleftint <= 60 )
                level notify( "match_ending_soon", "time" );

            if ( timeleftint >= 30 && timeleftint <= 40 )
                level notify( "match_ending_pretty_soon", "time" );

            if ( timeleftint <= 32 )
                level notify( "match_ending_vox" );

            if ( timeleftint <= 10 || timeleftint <= 30 && timeleftint % 2 == 0 )
            {
                level notify( "match_ending_very_soon", "time" );

                if ( timeleftint == 0 )
                    break;

                clockobject playsound( "mpl_ui_timer_countdown" );
            }

            if ( timeleft - floor( timeleft ) >= 0.05 )
                wait( timeleft - floor( timeleft ) );
        }

        wait 1.0;
    }
}

timelimitclock_intermission( waittime )
{
    setgameendtime( gettime() + int( waittime * 1000 ) );
    clockobject = spawn( "script_origin", ( 0, 0, 0 ) );

    if ( waittime >= 10.0 )
        wait( waittime - 10.0 );

    for (;;)
    {
        clockobject playsound( "mpl_ui_timer_countdown" );
        wait 1.0;
    }
}

startgame()
{
    thread maps\mp\gametypes_zm\_globallogic_utils::gametimer();
    level.timerstopped = 0;
    setmatchtalkflag( "DeadChatWithDead", level.voip.deadchatwithdead );
    setmatchtalkflag( "DeadChatWithTeam", level.voip.deadchatwithteam );
    setmatchtalkflag( "DeadHearTeamLiving", level.voip.deadhearteamliving );
    setmatchtalkflag( "DeadHearAllLiving", level.voip.deadhearallliving );
    setmatchtalkflag( "EveryoneHearsEveryone", level.voip.everyonehearseveryone );
    setmatchtalkflag( "DeadHearKiller", level.voip.deadhearkiller );
    setmatchtalkflag( "KillersHearVictim", level.voip.killershearvictim );
    prematchperiod();
    level notify( "prematch_over" );
    thread timelimitclock();
    thread graceperiod();
    thread watchmatchendingsoon();
    thread maps\mp\gametypes_zm\_globallogic_audio::musiccontroller();
    recordmatchbegin();
}

waitforplayers()
{

}

prematchperiod()
{
    setmatchflag( "hud_hardcore", level.hardcoremode );
    level endon( "game_ended" );

    if ( level.prematchperiod > 0 )
    {
        thread matchstarttimer();
        waitforplayers();
        wait( level.prematchperiod );
    }
    else
    {
        matchstarttimerskip();
        wait 0.05;
    }

    level.inprematchperiod = 0;

    for ( index = 0; index < level.players.size; index++ )
    {
        level.players[index] freeze_player_controls( 0 );
        level.players[index] enableweapons();
    }

    if ( game["state"] != "playing" )
        return;
}

graceperiod()
{
    level endon( "game_ended" );

    if ( isdefined( level.graceperiodfunc ) )
        [[ level.graceperiodfunc ]]();
    else
        wait( level.graceperiod );

    level notify( "grace_period_ending" );
    wait 0.05;
    level.ingraceperiod = 0;

    if ( game["state"] != "playing" )
        return;

    if ( level.numlives )
    {
        players = level.players;

        for ( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if ( !player.hasspawned && player.sessionteam != "spectator" && !isalive( player ) )
                player.statusicon = "hud_status_dead";
        }
    }

    level thread updateteamstatus();
}

watchmatchendingsoon()
{
    setdvar( "xblive_matchEndingSoon", 0 );

    level waittill( "match_ending_soon", reason );

    setdvar( "xblive_matchEndingSoon", 1 );
}

assertteamvariables()
{
    if ( !level.createfx_enabled && !sessionmodeiszombiesgame() )
    {
        foreach ( team in level.teams )
        {
            assert( isdefined( game["strings"][team + "_win"] ) );
            assert( isdefined( game["strings"][team + "_win_round"] ) );
            assert( isdefined( game["strings"][team + "_mission_accomplished"] ) );
            assert( isdefined( game["strings"][team + "_eliminated"] ) );
            assert( isdefined( game["strings"][team + "_forfeited"] ) );
            assert( isdefined( game["strings"][team + "_name"] ) );
            assert( isdefined( game["music"]["spawn_" + team] ) );
            assert( isdefined( game["music"]["victory_" + team] ) );
            assert( isdefined( game["icons"][team] ) );
            assert( isdefined( game["voice"][team] ) );
        }
    }
}

anyteamhaswavedelay()
{
    foreach ( team in level.teams )
    {
        if ( level.wavedelay[team] )
            return true;
    }

    return false;
}

callback_startgametype()
{
    level.prematchperiod = 0;
    level.intermission = 0;
    setmatchflag( "cg_drawSpectatorMessages", 1 );
    setmatchflag( "game_ended", 0 );

    if ( !isdefined( game["gamestarted"] ) )
    {
        if ( !isdefined( game["allies"] ) )
            game["allies"] = "seals";

        if ( !isdefined( game["axis"] ) )
            game["axis"] = "pmc";

        if ( !isdefined( game["attackers"] ) )
            game["attackers"] = "allies";

        if ( !isdefined( game["defenders"] ) )
            game["defenders"] = "axis";

        assert( game["attackers"] != game["defenders"] );

        foreach ( team in level.teams )
        {
            if ( !isdefined( game[team] ) )
                game[team] = "pmc";
        }

        if ( !isdefined( game["state"] ) )
            game["state"] = "playing";

        precacherumble( "damage_heavy" );
        precacherumble( "damage_light" );
        precacheshader( "white" );
        precacheshader( "black" );
        makedvarserverinfo( "scr_allies", "marines" );
        makedvarserverinfo( "scr_axis", "nva" );
        makedvarserverinfo( "cg_thirdPersonAngle", 354 );
        setdvar( "cg_thirdPersonAngle", 354 );
        game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";

        if ( level.teambased )
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
        assertteamvariables();
        [[ level.onprecachegametype ]]();
        game["gamestarted"] = 1;
        game["totalKills"] = 0;

        foreach ( team in level.teams )
        {
            game["teamScores"][team] = 0;
            game["totalKillsTeam"][team] = 0;
        }

        if ( !level.splitscreen && !ispregame() )
            level.prematchperiod = getgametypesetting( "prematchperiod" );

        if ( getdvarint( "xblive_clanmatch" ) != 0 )
        {
            foreach ( team in level.teams )
                game["icons"][team] = "composite_emblem_team_axis";

            game["icons"]["allies"] = "composite_emblem_team_allies";
            game["icons"]["axis"] = "composite_emblem_team_axis";
        }
    }

    if ( !isdefined( game["timepassed"] ) )
        game["timepassed"] = 0;

    if ( !isdefined( game["roundsplayed"] ) )
        game["roundsplayed"] = 0;

    setroundsplayed( game["roundsplayed"] );

    if ( !isdefined( game["roundwinner"] ) )
        game["roundwinner"] = [];

    if ( !isdefined( game["roundswon"] ) )
        game["roundswon"] = [];

    if ( !isdefined( game["roundswon"]["tie"] ) )
        game["roundswon"]["tie"] = 0;

    foreach ( team in level.teams )
    {
        if ( !isdefined( game["roundswon"][team] ) )
            game["roundswon"][team] = 0;

        level.teamspawnpoints[team] = [];
        level.spawn_point_team_class_names[team] = [];
    }

    level.skipvote = 0;
    level.gameended = 0;
    setdvar( "g_gameEnded", 0 );
    level.objidstart = 0;
    level.forcedend = 0;
    level.hostforcedend = 0;
    level.hardcoremode = getgametypesetting( "hardcoreMode" );

    if ( level.hardcoremode )
    {
        logstring( "game mode: hardcore" );

        if ( !isdefined( level.friendlyfiredelaytime ) )
            level.friendlyfiredelaytime = 0;
    }

    if ( getdvar( "scr_max_rank" ) == "" )
        setdvar( "scr_max_rank", "0" );

    level.rankcap = getdvarint( "scr_max_rank" );

    if ( getdvar( "scr_min_prestige" ) == "" )
        setdvar( "scr_min_prestige", "0" );

    level.minprestige = getdvarint( "scr_min_prestige" );
    level.usestartspawns = 1;
    level.roundscorecarry = getgametypesetting( "roundscorecarry" );
    level.allowhitmarkers = getgametypesetting( "allowhitmarkers" );
    level.playerqueuedrespawn = getgametypesetting( "playerQueuedRespawn" );
    level.playerforcerespawn = getgametypesetting( "playerForceRespawn" );
    level.perksenabled = getgametypesetting( "perksEnabled" );
    level.disableattachments = getgametypesetting( "disableAttachments" );
    level.disabletacinsert = getgametypesetting( "disableTacInsert" );
    level.disablecac = getgametypesetting( "disableCAC" );
    level.disableweapondrop = getgametypesetting( "disableweapondrop" );
    level.onlyheadshots = getgametypesetting( "onlyHeadshots" );
    level.minimumallowedteamkills = getgametypesetting( "teamKillPunishCount" ) - 1;
    level.teamkillreducedpenalty = getgametypesetting( "teamKillReducedPenalty" );
    level.teamkillpointloss = getgametypesetting( "teamKillPointLoss" );
    level.teamkillspawndelay = getgametypesetting( "teamKillSpawnDelay" );
    level.deathpointloss = getgametypesetting( "deathPointLoss" );
    level.leaderbonus = getgametypesetting( "leaderBonus" );
    level.forceradar = getgametypesetting( "forceRadar" );
    level.playersprinttime = getgametypesetting( "playerSprintTime" );
    level.bulletdamagescalar = getgametypesetting( "bulletDamageScalar" );
    level.playermaxhealth = getgametypesetting( "playerMaxHealth" );
    level.playerhealthregentime = getgametypesetting( "playerHealthRegenTime" );
    level.playerrespawndelay = getgametypesetting( "playerRespawnDelay" );
    level.playerobjectiveheldrespawndelay = getgametypesetting( "playerObjectiveHeldRespawnDelay" );
    level.waverespawndelay = getgametypesetting( "waveRespawnDelay" );
    level.spectatetype = getgametypesetting( "spectateType" );
    level.voip = spawnstruct();
    level.voip.deadchatwithdead = getgametypesetting( "voipDeadChatWithDead" );
    level.voip.deadchatwithteam = getgametypesetting( "voipDeadChatWithTeam" );
    level.voip.deadhearallliving = getgametypesetting( "voipDeadHearAllLiving" );
    level.voip.deadhearteamliving = getgametypesetting( "voipDeadHearTeamLiving" );
    level.voip.everyonehearseveryone = getgametypesetting( "voipEveryoneHearsEveryone" );
    level.voip.deadhearkiller = getgametypesetting( "voipDeadHearKiller" );
    level.voip.killershearvictim = getgametypesetting( "voipKillersHearVictim" );

    if ( getdvar( "r_reflectionProbeGenerate" ) == "1" )
        level waittill( "eternity" );

    if ( sessionmodeiszombiesgame() )
    {
        level.prematchperiod = 0;
        level.persistentdatainfo = [];
        level.maxrecentstats = 10;
        level.maxhitlocations = 19;
        level.globalshotsfired = 0;
        thread maps\mp\gametypes_zm\_hud::init();
        thread maps\mp\gametypes_zm\_serversettings::init();
        thread maps\mp\gametypes_zm\_clientids::init();
        thread maps\mp\gametypes_zm\_weaponobjects::init();
        thread maps\mp\gametypes_zm\_scoreboard::init();
        thread maps\mp\gametypes_zm\_shellshock::init();
        thread maps\mp\gametypes_zm\_spectating::init();
        thread maps\mp\gametypes_zm\_gameobjects::init();
        thread maps\mp\gametypes_zm\_spawnlogic::init();
        thread maps\mp\gametypes_zm\_globallogic_audio::init();
    }

    thread maps\mp\gametypes_zm\_hud_message::init();
    stringnames = getarraykeys( game["strings"] );

    for ( index = 0; index < stringnames.size; index++ )
        precachestring( game["strings"][stringnames[index]] );

    foreach ( team in level.teams )
        initteamvariables( team );

    level.maxplayercount = 0;
    level.activeplayers = [];
    level.allowannouncer = getgametypesetting( "allowAnnouncer" );

    if ( !isdefined( level.timelimit ) )
        registertimelimit( 1, 1440 );

    if ( !isdefined( level.scorelimit ) )
        registerscorelimit( 1, 500 );

    if ( !isdefined( level.roundlimit ) )
        registerroundlimit( 0, 10 );

    if ( !isdefined( level.roundwinlimit ) )
        registerroundwinlimit( 0, 10 );

    makedvarserverinfo( "ui_scorelimit" );
    makedvarserverinfo( "ui_timelimit" );
    makedvarserverinfo( "ui_allow_classchange", getdvar( "ui_allow_classchange" ) );
    wavedelay = level.waverespawndelay;

    if ( wavedelay && !ispregame() )
    {
        foreach ( team in level.teams )
        {
            level.wavedelay[team] = wavedelay;
            level.lastwave[team] = 0;
        }

        level thread [[ level.wavespawntimer ]]();
    }

    level.inprematchperiod = 1;

    if ( level.prematchperiod > 2.0 )
        level.prematchperiod += randomfloat( 4 ) - 2;

    if ( level.numlives || anyteamhaswavedelay() || level.playerqueuedrespawn )
        level.graceperiod = 15;
    else
        level.graceperiod = 5;

    level.ingraceperiod = 1;
    level.roundenddelay = 5;
    level.halftimeroundenddelay = 3;
    maps\mp\gametypes_zm\_globallogic_score::updateallteamscores();
    level.killstreaksenabled = 1;

    if ( getdvar( "scr_game_rankenabled" ) == "" )
        setdvar( "scr_game_rankenabled", 1 );

    level.rankenabled = getdvarint( "scr_game_rankenabled" );

    if ( getdvar( "scr_game_medalsenabled" ) == "" )
        setdvar( "scr_game_medalsenabled", 1 );

    level.medalsenabled = getdvarint( "scr_game_medalsenabled" );

    if ( level.hardcoremode && level.rankedmatch && getdvar( "scr_game_friendlyFireDelay" ) == "" )
        setdvar( "scr_game_friendlyFireDelay", 1 );

    level.friendlyfiredelay = getdvarint( "scr_game_friendlyFireDelay" );

    if ( getdvar( "createfx" ) == "" )
        [[ level.onstartgametype ]]();

    if ( getdvarint( _hash_826EB3B9 ) == 1 )
        level.killstreaksenabled = 0;
/#
    thread maps\mp\gametypes_zm\_dev::init();
#/
/#
    println( "Globallogic Callback_StartGametype() isPregame() = " + ispregame() + "\\n" );
#/
    thread startgame();
    level thread updategametypedvars();
/#
    if ( getdvarint( "scr_writeConfigStrings" ) == 1 )
    {
        level.skipgameend = 1;
        level.roundlimit = 1;
        wait 1;
        thread forceend( 0 );
    }

    if ( getdvarint( "scr_hostmigrationtest" ) == 1 )
        thread forcedebughostmigration();
#/
}

forcedebughostmigration()
{
/#
    while ( true )
    {
        maps\mp\gametypes_zm\_hostmigration::waittillhostmigrationdone();
        wait 60;
        starthostmigration();
        maps\mp\gametypes_zm\_hostmigration::waittillhostmigrationdone();
    }
#/
}

registerfriendlyfiredelay( dvarstring, defaultvalue, minvalue, maxvalue )
{
    dvarstring = "scr_" + dvarstring + "_friendlyFireDelayTime";

    if ( getdvar( dvarstring ) == "" )
        setdvar( dvarstring, defaultvalue );

    if ( getdvarint( dvarstring ) > maxvalue )
        setdvar( dvarstring, maxvalue );
    else if ( getdvarint( dvarstring ) < minvalue )
        setdvar( dvarstring, minvalue );

    level.friendlyfiredelaytime = getdvarint( dvarstring );
}

checkroundswitch()
{
    if ( !isdefined( level.roundswitch ) || !level.roundswitch )
        return false;

    if ( !isdefined( level.onroundswitch ) )
        return false;

    assert( game["roundsplayed"] > 0 );

    if ( game["roundsplayed"] % level.roundswitch == 0 )
    {
        [[ level.onroundswitch ]]();
        return true;
    }

    return false;
}

listenforgameend()
{
    self waittill( "host_sucks_end_game" );

    level.skipvote = 1;

    if ( !level.gameended )
        level thread maps\mp\gametypes_zm\_globallogic::forceend( 1 );
}

getkillstreaks( player )
{
    for ( killstreaknum = 0; killstreaknum < level.maxkillstreaks; killstreaknum++ )
        killstreak[killstreaknum] = "killstreak_null";

    if ( isplayer( player ) && !level.oldschool && level.disablecac != 1 && ( !isdefined( player.pers["isBot"] ) && isdefined( player.killstreak ) ) )
    {
        currentkillstreak = 0;

        for ( killstreaknum = 0; killstreaknum < level.maxkillstreaks; killstreaknum++ )
        {
            if ( isdefined( player.killstreak[killstreaknum] ) )
            {
                killstreak[currentkillstreak] = player.killstreak[killstreaknum];
                currentkillstreak++;
            }
        }
    }

    return killstreak;
}

updaterankedmatch( winner )
{
    if ( level.rankedmatch )
    {
        if ( hostidledout() )
        {
            level.hostforcedend = 1;
            logstring( "host idled out" );
            endlobby();
        }
    }

    if ( !level.wagermatch && !sessionmodeiszombiesgame() )
    {
        maps\mp\gametypes_zm\_globallogic_score::updatematchbonusscores( winner );
        maps\mp\gametypes_zm\_globallogic_score::updatewinlossstats( winner );
    }
}
