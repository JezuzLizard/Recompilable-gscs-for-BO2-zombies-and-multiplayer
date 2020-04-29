#include maps/mp/gametypes/_globallogic;
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


init()
{
    if (!isDefined(level.tweakablesinitialized))
    {
        maps/mp/gametypes/_tweakables::init();
    }
    init_session_mode_flags();
    level.splitscreen = issplitscreen();
    level.xenon = getDvar(#"0xe0dde627") == "true";
    level.ps3 = getDvar(#"0xc15079f5") == "true";
    level.wiiu = getDvar(#"0xde5d2cdd") == "true";
    level.onlinegame = sessionmodeisonlinegame();
    level.systemlink = sessionmodeissystemlink();
    level.console = level.wiiu;
    level.rankedmatch = !(ispregame());
    level.leaguematch = gamemodeismode(level.gamemode_league_match);
    level.contractsenabled = !(getgametypesetting("disableContracts"));
    level.contractsenabled = 0;
    level.script = tolower(getDvar(#"0xb4b895c4"));
    level.gametype = tolower(getDvar(#"0x4f118387"));
    level.teambased = 0;
    level.teamcount = getgametypesetting("teamCount");
    level.multiteam = level.teamcount > 2;
    while (sessionmodeiszombiesgame())
    {
        level.zombie_team_index = level.teamcount + 1;
        if (2 == level.zombie_team_index)
        {
            level.zombie_team = "axis";
        }
        else
        {
            level.zombie_team = "team" + level.zombie_team_index;
        }
    }
    level.teams = [];
    level.teamindex = [];
    teamcount = level.teamcount;
    level.teams["allies"] = "allies";
    level.teams["axis"] = "axis";
    level.teamindex["neutral"] = 0;
    level.teamindex["allies"] = 1;
    level.teamindex["axis"] = 2;
    teamindex = 3;
    while (teamindex <= teamcount)
    {
        level.teams["team" + teamindex] = "team" + teamindex;
        level.teamindex["team" + teamindex] = teamindex;
        teamindex++;
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
    _a106 = level.teams;
    _k106 = getFirstArrayKey(_a106);
    while (isDefined(_k106))
    {
        team = _a106[_k106];
        level.placement[team] = [];
        _k106 = getNextArrayKey(_a106, _k106);
    }
    level.placement["all"] = [];
    level.postroundtime = 7;
    level.inovertime = 0;
    level.defaultoffenseradius = 560;
    level.dropteam = getDvarInt(#"0x851b42e5");
    level.infinalkillcam = 0;
    maps/mp/gametypes/_globallogic_ui::init();
    registerdvars();
    maps/mp/gametypes/_class::initperkdvars();
    level.oldschool = getDvarInt(#"0x38f47b13") == 1;
    if (level.oldschool)
    {
        logstring("game mode: oldschool");
        setdvar("jump_height", 64);
        setdvar("jump_slowdownEnable", 0);
        setdvar("bg_fallDamageMinHeight", 256);
        setdvar("bg_fallDamageMaxHeight", 512);
        setdvar("player_clipSizeMultiplier", 2);
    }
    precachemodel("tag_origin");
    precacherumble("dtp_rumble");
    precacherumble("slide_rumble");
    precachestatusicon("hud_status_dead");
    precachestatusicon("hud_status_connecting");
    precache_mp_leaderboards();
    maps/mp/_burnplayer::initburnplayer();
    if (!isDefined(game["tiebreaker"]))
    {
        game["tiebreaker"] = 0;
    }
    maps/mp/gametypes/_globallogic_audio::registerdialoggroup("introboost", 1);
    maps/mp/gametypes/_globallogic_audio::registerdialoggroup("status", 1);
    thread maps/mp/_gameadvertisement::init();
    thread maps/mp/_gamerep::init();
    level.disablechallenges = 0;
    while (level.leaguematch || getDvarInt(#"0x8d5c0c16") > 0)
    {
        level.disablechallenges = 1;
    }
    level.disablestattracking = getDvarInt(#"0x742cbfaf") > 0;
}

registerdvars()
{
    if (getDvar(#"0x38f47b13") == "")
    {
        setdvar("scr_oldschool", "0");
    }
    makedvarserverinfo("scr_oldschool");
    if (getDvar(#"0x6017b9c") == "")
    {
        setdvar("ui_guncycle", 0);
    }
    makedvarserverinfo("ui_guncycle");
    if (getDvar(#"0x41a6c572") == "")
    {
        setdvar("ui_weapon_tiers", 0);
    }
    makedvarserverinfo("ui_weapon_tiers");
    setdvar("ui_text_endreason", "");
    makedvarserverinfo("ui_text_endreason", "");
    setmatchflag("bomb_timer", 0);
    setmatchflag("enable_popups", 1);
    setmatchflag("pregame", ispregame());
    if (getDvar(#"0x23853f1f") == "")
    {
        setdvar("scr_vehicle_damage_scalar", "1");
    }
    level.vehicledamagescalar = getDvarFloat(#"0x23853f1f");
    level.fire_audio_repeat_duration = getDvarInt(#"0x917e4521");
    level.fire_audio_random_max_duration = getDvarInt(#"0xc2dcbc26");
    teamname = getcustomteamname(level.teamindex["allies"]);
    if (isDefined(teamname))
    {
        setdvar("g_customTeamName_Allies", teamname);
    }
    else
    {
        setdvar("g_customTeamName_Allies", "");
    }
    teamname = getcustomteamname(level.teamindex["axis"]);
    if (isDefined(teamname))
    {
        setdvar("g_customTeamName_Axis", teamname);
    }
    else
    {
        setdvar("g_customTeamName_Axis", "");
    }
}

blank(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
{
}

setupcallbacks()
{
    level.spawnplayer = ::spawnplayer;
    level.spawnplayerprediction = ::spawnplayerprediction;
    level.spawnclient = ::spawnclient;
    level.spawnspectator = ::spawnspectator;
    level.spawnintermission = ::spawnintermission;
    level.onplayerscore = ::default_onplayerscore;
    level.onteamscore = ::default_onteamscore;
    level.wavespawntimer = ::wavespawntimer;
    level.spawnmessage = ::default_spawnmessage;
    level.onspawnplayer = ::blank;
    level.onspawnplayerunified = ::blank;
    level.onspawnspectator = ::default_onspawnspectator;
    level.onspawnintermission = ::default_onspawnintermission;
    level.onrespawndelay = ::blank;
    level.onforfeit = ::default_onforfeit;
    level.ontimelimit = ::default_ontimelimit;
    level.onscorelimit = ::default_onscorelimit;
    level.onalivecountchange = ::default_onalivecountchange;
    level.ondeadevent = undefined;
    level.ononeleftevent = ::default_ononeleftevent;
    level.giveteamscore = ::giveteamscore;
    level.onlastteamaliveevent = ::default_onlastteamaliveevent;
    level.gettimelimit = ::default_gettimelimit;
    level.getteamkillpenalty = ::default_getteamkillpenalty;
    level.getteamkillscore = ::default_getteamkillscore;
    level.iskillboosting = ::default_iskillboosting;
    level._setteamscore = ::_setteamscore;
    level._setplayerscore = ::_setplayerscore;
    level._getteamscore = ::_getteamscore;
    level._getplayerscore = ::_getplayerscore;
    level.onprecachegametype = ::blank;
    level.onstartgametype = ::blank;
    level.onplayerconnect = ::blank;
    level.onplayerdisconnect = ::blank;
    level.onplayerdamage = ::blank;
    level.onplayerkilled = ::blank;
    level.onplayerkilledextraunthreadedcbs = [];
    level.onteamoutcomenotify = ::teamoutcomenotify;
    level.onoutcomenotify = ::outcomenotify;
    level.onteamwageroutcomenotify = ::teamwageroutcomenotify;
    level.onwageroutcomenotify = ::wageroutcomenotify;
    level.setmatchscorehudelemforteam = ::setmatchscorehudelemforteam;
    level.onendgame = ::blank;
    level.onroundendgame = ::default_onroundendgame;
    level.onmedalawarded = ::blank;
    maps/mp/gametypes/_globallogic_ui::setupcallbacks();
}

precache_mp_leaderboards()
{
    if (maps/mp/bots/_bot::is_bot_ranked_match())
    {
        return;
    }
    if (sessionmodeiszombiesgame())
    {
        return;
    }
    if (!level.rankedmatch)
    {
        return;
    }
    mapname = getDvar(#"0xb4b895c4");
    globalleaderboards = "LB_MP_GB_XPPRESTIGE LB_MP_GB_SCORE LB_MP_GB_KDRATIO LB_MP_GB_KILLS LB_MP_GB_WINS LB_MP_GB_DEATHS LB_MP_GB_XPMAXPERGAME LB_MP_GB_TACTICALINSERTS LB_MP_GB_TACTICALINSERTSKILLS LB_MP_GB_PRESTIGEXP LB_MP_GB_HEADSHOTS LB_MP_GB_WEAPONS_PRIMARY LB_MP_GB_WEAPONS_SECONDARY";
    careerleaderboard = "";
    switch (level.gametype)
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
    if (isDefined(hardcoremode) && hardcoremode)
    {
        gamemodehcleaderboard = gamemodeleaderboard + "_HC";
        gamemodehcleaderboardext = gamemodeleaderboardext + "_HC";
    }
    mapleaderboard = " LB_MP_MAP_" + getsubstr(mapname, 3, mapname.size);
    precacheleaderboards(globalleaderboards + careerleaderboard + gamemodeleaderboard + gamemodeleaderboardext + gamemodehcleaderboard + gamemodehcleaderboardext + mapleaderboard);
}

compareteambygamestat(gamestat, teama, teamb, previous_winner_score)
{
    winner = undefined;
    if (teama == "tie")
    {
        winner = "tie";
        if (previous_winner_score < game[gamestat][teamb])
        {
            winner = teamb;
        }
    }
    else
    {
        if (game[gamestat][teama] == game[gamestat][teamb])
        {
            winner = "tie";
        }
        else
        {
            if (game[gamestat][teamb] > game[gamestat][teama])
            {
                winner = teamb;
            }
            else
            {
                winner = teama;
            }
        }
    }
    return winner;
}

determineteamwinnerbygamestat(gamestat)
{
    teamkeys = getarraykeys(level.teams);
    winner = teamkeys[0];
    previous_winner_score = game[gamestat][winner];
    teamindex = 1;
    while (teamindex < teamkeys.size)
    {
        winner = compareteambygamestat(gamestat, winner, teamkeys[teamindex], previous_winner_score);
        if (winner != "tie")
        {
            previous_winner_score = game[gamestat][winner];
        }
        teamindex++;
    }
    return winner;
}

compareteambyteamscore(teama, teamb, previous_winner_score)
{
    winner = undefined;
    teambscore = [[level._getteamscore]](teamb);
    if (teama == "tie")
    {
        winner = "tie";
        if (previous_winner_score < teambscore)
        {
            winner = teamb;
        }
        return winner;
    }
    teamascore = [[level._getteamscore]](teama);
    if (teambscore == teamascore)
    {
        winner = "tie";
    }
    else
    {
        if (teambscore > teamascore)
        {
            winner = teamb;
        }
        else
        {
            winner = teama;
        }
    }
    return winner;
}

determineteamwinnerbyteamscore()
{
    teamkeys = getarraykeys(level.teams);
    winner = teamkeys[0];
    previous_winner_score = [[level._getteamscore]](winner);
    teamindex = 1;
    while (teamindex < teamkeys.size)
    {
        winner = compareteambyteamscore(winner, teamkeys[teamindex], previous_winner_score);
        if (winner != "tie")
        {
            previous_winner_score = [[level._getteamscore]](winner);
        }
        teamindex++;
    }
    return winner;
}

forceend(hostsucks)
{
    if (!isDefined(hostsucks))
    {
        hostsucks = 0;
    }
    if (level.hostforcedend || level.forcedend)
    {
        return;
    }
    winner = undefined;
    if (level.teambased)
    {
        winner = determineteamwinnerbygamestat("teamScores");
        maps/mp/gametypes/_globallogic_utils::logteamwinstring("host ended game", winner);
    }
    else
    {
        winner = maps/mp/gametypes/_globallogic_score::gethighestscoringplayer();
        if (isDefined(winner))
        {
            logstring("host ended game, win: " + winner.name);
        }
        else
        {
            logstring("host ended game, tie");
        }
    }
    level.forcedend = 1;
    level.hostforcedend = 1;
    if (hostsucks)
    {
        endstring = &"MP_HOST_SUCKS";
    }
    else
    {
        if (level.splitscreen)
        {
            endstring = &"MP_ENDED_GAME";
        }
        else
        {
            endstring = &"MP_HOST_ENDED_GAME";
        }
    }
    setmatchflag("disableIngameMenu", 1);
    makedvarserverinfo("ui_text_endreason", endstring);
    setdvar("ui_text_endreason", endstring);
    thread endgame(winner, endstring);
}

killserverpc()
{
    if (level.hostforcedend || level.forcedend)
    {
        return;
    }
    winner = undefined;
    if (level.teambased)
    {
        winner = determineteamwinnerbygamestat("teamScores");
        maps/mp/gametypes/_globallogic_utils::logteamwinstring("host ended game", winner);
    }
    else
    {
        winner = maps/mp/gametypes/_globallogic_score::gethighestscoringplayer();
        if (isDefined(winner))
        {
            logstring("host ended game, win: " + winner.name);
        }
        else
        {
            logstring("host ended game, tie");
        }
    }
    level.forcedend = 1;
    level.hostforcedend = 1;
    level.killserver = 1;
    endstring = &"MP_HOST_ENDED_GAME";
    thread endgame(winner, endstring);
}

atleasttwoteams()
{
    valid_count = 0;
    _a504 = level.teams;
    _k504 = getFirstArrayKey(_a504);
    while (isDefined(_k504))
    {
        team = _a504[_k504];
        if (level.playercount[team] != 0)
        {
            valid_count++;
        }
        _k504 = getNextArrayKey(_a504, _k504);
    }
    if (valid_count < 2)
    {
        return 0;
    }
    return 1;
}

checkifteamforfeits(team)
{
    if (!game["everExisted"][team])
    {
        return 0;
    }
    if (level.playercount[team] < 1 && totalplayercount() > 0)
    {
        return 1;
    }
    return 0;
}

checkforforfeit()
{
    forfeit_count = 0;
    valid_team = undefined;
    _a538 = level.teams;
    _k538 = getFirstArrayKey(_a538);
    while (isDefined(_k538))
    {
        team = _a538[_k538];
        if (checkifteamforfeits(team))
        {
            forfeit_count++;
            if (!level.multiteam)
            {
                thread [[level.onforfeit]](team);
                return 1;
            }
        }
        else
        {
            valid_team = team;
        }
        _k538 = getNextArrayKey(_a538, _k538);
    }
    if (level.multiteam && forfeit_count == level.teams.size - 1)
    {
        thread [[level.onforfeit]](valid_team);
        return 1;
    }
    return 0;
}

dospawnqueueupdates()
{
    _a567 = level.teams;
    _k567 = getFirstArrayKey(_a567);
    while (isDefined(_k567))
    {
        team = _a567[_k567];
        if (level.spawnqueuemodified[team])
        {
            [[level.onalivecountchange]](team);
        }
        _k567 = getNextArrayKey(_a567, _k567);
    }
}

isteamalldead(team)
{
    return !(level.playerlives[team]);
}

areallteamsdead()
{
    _a583 = level.teams;
    _k583 = getFirstArrayKey(_a583);
    while (isDefined(_k583))
    {
        team = _a583[_k583];
        if (!isteamalldead(team))
        {
            return 0;
        }
        _k583 = getNextArrayKey(_a583, _k583);
    }
    return 1;
}

getlastteamalive()
{
    count = 0;
    everexistedcount = 0;
    aliveteam = undefined;
    _a600 = level.teams;
    _k600 = getFirstArrayKey(_a600);
    while (isDefined(_k600))
    {
        team = _a600[_k600];
        if (level.everexisted[team])
        {
            if (!isteamalldead(team))
            {
                aliveteam = team;
                count++;
            }
            everexistedcount++;
        }
        _k600 = getNextArrayKey(_a600, _k600);
    }
    if (everexistedcount > 1 && count == 1)
    {
        return aliveteam;
    }
    return undefined;
}

dodeadeventupdates()
{
    if (level.teambased)
    {
        if (areallteamsdead())
        {
            [[level.ondeadevent]]("all");
            return 1;
        }
        if (!isDefined(level.ondeadevent))
        {
            lastteamalive = getlastteamalive();
            if (isDefined(lastteamalive))
            {
                [[level.onlastteamaliveevent]](lastteamalive);
                return 1;
            }
        }
        else
        {
            _a644 = level.teams;
            _k644 = getFirstArrayKey(_a644);
            while (isDefined(_k644))
            {
                team = _a644[_k644];
                if (isteamalldead(team))
                {
                    [[level.ondeadevent]](team);
                    return 1;
                }
                _k644 = getNextArrayKey(_a644, _k644);
            }
        }
    }
    else
    {
        if (totalalivecount() == 0 && totalplayerlives() == 0 && level.maxplayercount > 1)
        {
            [[level.ondeadevent]]("all");
            return 1;
        }
    }
    return 0;
}

isonlyoneleftaliveonteam(team)
{
    return level.playerlives[team] == 1;
}

doonelefteventupdates()
{
    if (level.teambased)
    {
        _a678 = level.teams;
        _k678 = getFirstArrayKey(_a678);
        while (isDefined(_k678))
        {
            team = _a678[_k678];
            if (isonlyoneleftaliveonteam(team))
            {
                [[level.ononeleftevent]](team);
                return 1;
            }
            _k678 = getNextArrayKey(_a678, _k678);
        }
    }
    else
    {
        if (totalalivecount() == 1 && totalplayerlives() == 1 && level.maxplayercount > 1)
        {
            [[level.ononeleftevent]]("all");
            return 1;
        }
    }
    return 0;
}

updategameevents()
{
    if (level.rankedmatch || level.wagermatch || level.leaguematch && !(level.ingraceperiod))
    {
        if (level.teambased)
        {
            if (!level.gameforfeited)
            {
                if (game["state"] == "playing" && checkforforfeit())
                {
                    return;
                }
            }
            else
            {
                if (atleasttwoteams())
                {
                    level.gameforfeited = 0;
                    level notify("abort forfeit");
                }
            }
        }
        else
        {
            if (!level.gameforfeited)
            {
                if (totalplayercount() == 1 && level.maxplayercount > 1)
                {
                    thread [[level.onforfeit]]();
                    return;
                }
            }
            else
            {
                if (totalplayercount() > 1)
                {
                    level.gameforfeited = 0;
                    level notify("abort forfeit");
                }
            }
        }
    }
    if (!(level.playerqueuedrespawn) && !(level.numlives) && !(level.inovertime))
    {
        return;
    }
    if (level.ingraceperiod)
    {
        return;
    }
    while (level.playerqueuedrespawn)
    {
        dospawnqueueupdates();
    }
    if (dodeadeventupdates())
    {
        return;
    }
    if (doonelefteventupdates())
    {
        return;
    }
}

matchstarttimer()
{
    visionsetnaked("mpIntro", 0);
    matchstarttext = createserverfontstring("objective", 1,5);
    matchstarttext setpoint("CENTER", "CENTER", 0, -40);
    matchstarttext.sort = 1001;
    matchstarttext settext(game["strings"]["waiting_for_teams"]);
    matchstarttext.foreground = 0;
    matchstarttext.hidewheninmenu = 1;
    waitforplayers();
    matchstarttext settext(game["strings"]["match_starting_in"]);
    matchstarttimer = createserverfontstring("big", 2,2);
    matchstarttimer setpoint("CENTER", "CENTER", 0, 0);
    matchstarttimer.sort = 1001;
    matchstarttimer.color = (1, 1, 0);
    matchstarttimer.foreground = 0;
    matchstarttimer.hidewheninmenu = 1;
    matchstarttimer maps/mp/gametypes/_hud::fontpulseinit();
    counttime = int(level.prematchperiod);
    if (counttime >= 2)
    {
        while (counttime > 0 && !(level.gameended))
        {
            matchstarttimer setvalue(counttime);
            matchstarttimer thread maps/mp/gametypes/_hud::fontpulse(level);
            if (counttime == 2)
            {
                visionsetnaked(getDvar(#"0xb4b895c4"), 3);
            }
            counttime--;
            _a804 = level.players;
            _k804 = getFirstArrayKey(_a804);
            while (isDefined(_k804))
            {
                player = _a804[_k804];
                player playlocalsound("uin_start_count_down");
                _k804 = getNextArrayKey(_a804, _k804);
            }
            wait 1;
        }
    }
    else
    {
        visionsetnaked(getDvar(#"0xb4b895c4"), 1);
    }
    matchstarttimer destroyelem();
    matchstarttext destroyelem();
}

matchstarttimerskip()
{
    if (!ispregame())
    {
        visionsetnaked(getDvar(#"0xb4b895c4"), 0);
    }
    else
    {
        visionsetnaked("mpIntro", 0);
    }
}

notifyteamwavespawn(team, time)
{
    if (time - level.lastwave[team] > level.wavedelay[team] * 1000)
    {
        level notify("wave_respawn_" + team);
        level.lastwave[team] = time;
        level.waveplayerspawnindex[team] = 0;
    }
}

wavespawntimer()
{
    level endon("game_ended");
    while (game["state"] == "playing")
    {
        time = getTime();
        _a847 = level.teams;
        _k847 = getFirstArrayKey(_a847);
        while (isDefined(_k847))
        {
            team = _a847[_k847];
            notifyteamwavespawn(team, time);
            _k847 = getNextArrayKey(_a847, _k847);
        }
        wait 0.05;
    }
}

hostidledout()
{
    hostplayer = gethostplayer();
    if (isDefined(hostplayer) && !(hostplayer.hasspawned) && !(isDefined(hostplayer.selectedclass)))
    {
        return 1;
    }
    return 0;
}

incrementmatchcompletionstat(gamemode, playedorhosted, stat)
{
    self adddstat("gameHistory", gamemode, "modeHistory", playedorhosted, stat, 1);
}

setmatchcompletionstat(gamemode, playedorhosted, stat)
{
    self setdstat("gameHistory", gamemode, "modeHistory", playedorhosted, stat, 1);
}

getcurrentgamemode()
{
    while (gamemodeismode(level.gamemode_league_match))
    {
        return "leaguematch";
    }
    return "publicmatch";
}

getteamscoreratio()
{
    playerteam = self.pers["team"];
    score = getteamscore(playerteam);
    otherteamscore = 0;
    _a898 = level.teams;
    _k898 = getFirstArrayKey(_a898);
    while (isDefined(_k898))
    {
        team = _a898[_k898];
        if (team == playerteam)
        {
        }
        else
        {
            otherteamscore = otherteamscore + getteamscore(team);
        }
        _k898 = getNextArrayKey(_a898, _k898);
    }
    if (level.teams.size > 1)
    {
        otherteamscore = otherteamscore / level.teams.size - 1;
    }
    if (otherteamscore != 0)
    {
        return float(score) / float(otherteamscore);
    }
    return score;
}

gethighestscore()
{
    highestscore = -999999999;
    index = 0;
    while (index < level.players.size)
    {
        player = level.players[index];
        if (player.score > highestscore)
        {
            highestscore = player.score;
        }
        index++;
    }
    return highestscore;
}

getnexthighestscore(score)
{
    highestscore = -999999999;
    index = 0;
    while (index < level.players.size)
    {
        player = level.players[index];
        if (player.score >= score)
        {
        }
        else
        {
            if (player.score > highestscore)
            {
                highestscore = player.score;
            }
        }
        index++;
    }
    return highestscore;
}

sendafteractionreport()
{
    if (!level.onlinegame)
    {
        return;
    }
    if (ispregame())
    {
        return;
    }
    if (sessionmodeiszombiesgame())
    {
        return;
    }
    index = 0;
    while (index < level.players.size)
    {
        player = level.players[index];
        if (player is_bot())
        {
        }
        else
        {
            nemesis = player.pers["nemesis_name"];
            if (!isDefined(player.pers["killed_players"][nemesis]))
            {
                player.pers["killed_players"][nemesis] = 0;
            }
            if (!isDefined(player.pers["killed_by"][nemesis]))
            {
                player.pers["killed_by"][nemesis] = 0;
            }
            spread = player.kills - player.deaths;
            if (player.pers["cur_kill_streak"] > player.pers["best_kill_streak"])
            {
                player.pers["best_kill_streak"] = player.pers["cur_kill_streak"];
            }
            if (level.rankedmatch || level.wagermatch || level.leaguematch)
            {
                player maps/mp/gametypes/_persistence::setafteractionreportstat("privateMatch", 0);
            }
            else
            {
                player maps/mp/gametypes/_persistence::setafteractionreportstat("privateMatch", 1);
            }
            player setnemesisxuid(player.pers["nemesis_xuid"]);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("nemesisName", nemesis);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("nemesisRank", player.pers["nemesis_rank"]);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("nemesisRankIcon", player.pers["nemesis_rankIcon"]);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("nemesisKills", player.pers["killed_players"][nemesis]);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("nemesisKilledBy", player.pers["killed_by"][nemesis]);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("bestKillstreak", player.pers["best_kill_streak"]);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("kills", player.kills);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("deaths", player.deaths);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("headshots", player.headshots);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("score", player.score);
            player maps/mp/gametypes/_persistence::setafteractionreportstat("xpEarned", int(player.pers["summary"]["xp"]));
            player maps/mp/gametypes/_persistence::setafteractionreportstat("cpEarned", int(player.pers["summary"]["codpoints"]));
            player maps/mp/gametypes/_persistence::setafteractionreportstat("miscBonus", int(player.pers["summary"]["challenge"] + player.pers["summary"]["misc"]));
            player maps/mp/gametypes/_persistence::setafteractionreportstat("matchBonus", int(player.pers["summary"]["match"]));
            player maps/mp/gametypes/_persistence::setafteractionreportstat("demoFileID", getdemofileid());
            player maps/mp/gametypes/_persistence::setafteractionreportstat("leagueTeamID", player getleagueteamid());
            teamscoreratio = player getteamscoreratio();
            scoreboardposition = getplacementforplayer(player);
            if (scoreboardposition < 0)
            {
                scoreboardposition = level.players.size;
            }
            player gamehistoryfinishmatch(4, player.kills, player.deaths, player.score, scoreboardposition, teamscoreratio);
            placement = level.placement["all"];
            otherplayerindex = 0;
            while (otherplayerindex < placement.size)
            {
                while (level.placement["all"][otherplayerindex] == player)
                {
                    recordplayerstats(player, "position", otherplayerindex);
                }
                otherplayerindex++;
            }
            if (level.wagermatch)
            {
                recordplayerstats(player, "wagerPayout", player.wagerwinnings);
                player maps/mp/gametypes/_wager::setwagerafteractionreportstats();
                player maps/mp/gametypes/_persistence::setafteractionreportstat("wagerMatch", 1);
            }
            else
            {
                player maps/mp/gametypes/_persistence::setafteractionreportstat("wagerMatch", 0);
            }
            player maps/mp/gametypes/_persistence::setafteractionreportstat("wagerMatchFailed", 0);
            if (level.rankedmatch || level.wagermatch || level.leaguematch)
            {
                player maps/mp/gametypes/_persistence::setafteractionreportstat("valid", 1);
            }
            if (isDefined(player.pers["matchesPlayedStatsTracked"]))
            {
                gamemode = getcurrentgamemode();
                player incrementmatchcompletionstat(gamemode, "played", "completed");
                if (isDefined(player.pers["matchesHostedStatsTracked"]))
                {
                    player incrementmatchcompletionstat(gamemode, "hosted", "completed");
                    player.pers["matchesHostedStatsTracked"] = undefined;
                }
                player.pers["matchesPlayedStatsTracked"] = undefined;
            }
            recordplayerstats(player, "highestKillStreak", player.pers["best_kill_streak"]);
            recordplayerstats(player, "numUavCalled", player maps/mp/killstreaks/_killstreaks::getkillstreakusage("uav_used"));
            recordplayerstats(player, "numDogsCalleD", player maps/mp/killstreaks/_killstreaks::getkillstreakusage("dogs_used"));
            recordplayerstats(player, "numDogsKills", player.pers["dog_kills"]);
            recordplayermatchend(player);
            recordplayerstats(player, "presentAtEnd", 1);
        }
        index++;
    }
}

gamehistoryplayerkicked()
{
    teamscoreratio = self getteamscoreratio();
    scoreboardposition = getplacementforplayer(self);
    if (scoreboardposition < 0) scoreboardposition = level.players.size;
    self gamehistoryfinishmatch(2, self.kills, self.deaths, self.score, scoreboardposition, teamscoreratio);
    if (isDefined(self.pers["matchesPlayedStatsTracked"]))
    {
        gamemode = getcurrentgamemode();
        self incrementmatchcompletionstat(gamemode, "played", "kicked");
        self.pers["matchesPlayedStatsTracked"] = undefined;
    }
    uploadstats(self);
    wait 1;
}

gamehistoryplayerquit()
{
    teamscoreratio = self getteamscoreratio();
    scoreboardposition = getplacementforplayer(self);
    if (scoreboardposition < 0)
    {
        scoreboardposition = level.players.size;
    }
    self gamehistoryfinishmatch(3, self.kills, self.deaths, self.score, scoreboardposition, teamscoreratio);
    if (isDefined(self.pers["matchesPlayedStatsTracked"]))
    {
        gamemode = getcurrentgamemode();
        self incrementmatchcompletionstat(gamemode, "played", "quit");
        if (isDefined(self.pers["matchesHostedStatsTracked"]))
        {
            self incrementmatchcompletionstat(gamemode, "hosted", "quit");
            self.pers["matchesHostedStatsTracked"] = undefined;
        }
        self.pers["matchesPlayedStatsTracked"] = undefined;
    }
    uploadstats(self);
    if (!self ishost())
    {
        wait 1;
    }
}

displayroundend(winner, endreasontext)
{
    while (level.displayroundendtext)
    {
        while (level.teambased)
        {
            if (winner == "tie")
            {
                maps/mp/_demo::gameresultbookmark("round_result", level.teamindex["neutral"], level.teamindex["neutral"]);
            }
            else
            {
                maps/mp/_demo::gameresultbookmark("round_result", level.teamindex[winner], level.teamindex["neutral"]);
            }
        }
        setmatchflag("cg_drawSpectatorMessages", 0);
        players = level.players;
        index = 0;
        while (index < players.size)
        {
            player = players[index];
            if (!waslastround())
            {
                player notify("round_ended");
            }
            if (!isDefined(player.pers["team"]))
            {
                player [[level.spawnintermission]](1);
                player closemenu();
                player closeingamemenu();
            }
            else
            {
                if (level.wagermatch)
                {
                    if (level.teambased)
                    {
                        player thread [[level.onteamwageroutcomenotify]](winner, 1, endreasontext);
                    }
                    else
                    {
                        player thread [[level.onwageroutcomenotify]](winner, endreasontext);
                    }
                }
                else
                {
                    if (level.teambased)
                    {
                        player thread [[level.onteamoutcomenotify]](winner, 1, endreasontext);
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player("ROUND_END");
                    }
                    else
                    {
                        player thread [[level.onoutcomenotify]](winner, 1, endreasontext);
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player("ROUND_END");
                    }
                }
                player setclientuivisibilityflag("hud_visible", 0);
                player setclientuivisibilityflag("g_compassShowEnemies", 0);
            }
            index++;
        }
    }
    if (waslastround())
    {
        roundendwait(level.roundenddelay, 0);
    }
    else
    {
        thread maps/mp/gametypes/_globallogic_audio::announceroundwinner(winner, level.roundenddelay / 4);
        roundendwait(level.roundenddelay, 1);
    }
}

displayroundswitch(winner, endreasontext)
{
    switchtype = level.halftimetype;
    if (switchtype == "halftime")
    {
        if (isDefined(level.nextroundisovertime) && level.nextroundisovertime)
        {
            switchtype = "overtime";
        }
        else
        {
            if (level.roundlimit)
            {
                if (game["roundsplayed"] * 2 == level.roundlimit)
                {
                    switchtype = "halftime";
                }
                else
                {
                    switchtype = "intermission";
                }
            }
            else
            {
                if (level.scorelimit)
                {
                    if (game["roundsplayed"] == level.scorelimit - 1)
                    {
                        switchtype = "halftime";
                    }
                    else
                    {
                        switchtype = "intermission";
                    }
                }
                else
                {
                    switchtype = "intermission";
                }
            }
        }
    }
    leaderdialog = maps/mp/gametypes/_globallogic_audio::getroundswitchdialog(switchtype);
    setmatchtalkflag("EveryoneHearsEveryone", 1);
    players = level.players;
    index = 0;
    while (index < players.size)
    {
        player = players[index];
        if (!isDefined(player.pers["team"]))
        {
            player [[level.spawnintermission]](1);
            player closemenu();
            player closeingamemenu();
        }
        else
        {
            player maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer(leaderdialog);
            player maps/mp/gametypes/_globallogic_audio::set_music_on_player("ROUND_SWITCH");
            if (level.wagermatch)
            {
                player thread [[level.onteamwageroutcomenotify]](switchtype, 1, level.halftimesubcaption);
            }
            else
            {
                player thread [[level.onteamoutcomenotify]](switchtype, 0, level.halftimesubcaption);
            }
            player setclientuivisibilityflag("hud_visible", 0);
        }
        index++;
    }
    roundendwait(level.halftimeroundenddelay, 0);
}

displaygameend(winner, endreasontext)
{
    setmatchtalkflag("EveryoneHearsEveryone", 1);
    setmatchflag("cg_drawSpectatorMessages", 0);
    while (level.teambased)
    {
        if (winner == "tie")
        {
            maps/mp/_demo::gameresultbookmark("game_result", level.teamindex["neutral"], level.teamindex["neutral"]);
        }
        else
        {
            maps/mp/_demo::gameresultbookmark("game_result", level.teamindex[winner], level.teamindex["neutral"]);
        }
    }
    players = level.players;
    index = 0;
    while (index < players.size)
    {
        player = players[index];
        if (!isDefined(player.pers["team"]))
        {
            player [[level.spawnintermission]](1);
            player closemenu();
            player closeingamemenu();
        }
        else
        {
            if (level.wagermatch)
            {
                if (level.teambased)
                {
                    player thread [[level.onteamwageroutcomenotify]](winner, 0, endreasontext);
                }
                else
                {
                    player thread [[level.onwageroutcomenotify]](winner, endreasontext);
                }
            }
            else
            {
                if (level.teambased)
                {
                    player thread [[level.onteamoutcomenotify]](winner, 0, endreasontext);
                }
                else
                {
                    player thread [[level.onoutcomenotify]](winner, 0, endreasontext);
                    if (isDefined(winner) && player == winner)
                    {
                        music = game["music"]["victory_" + player.team];
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player(music);
                    }
                    else
                    {
                        if (!level.splitscreen)
                        {
                            player maps/mp/gametypes/_globallogic_audio::set_music_on_player("LOSE");
                        }
                    }
                }
            }
            player setclientuivisibilityflag("hud_visible", 0);
            player setclientuivisibilityflag("g_compassShowEnemies", 0);
        }
        index++;
    }
    while (level.teambased)
    {
        thread maps/mp/gametypes/_globallogic_audio::announcegamewinner(winner, level.postroundtime / 2);
        players = level.players;
        index = 0;
        while (index < players.size)
        {
            player = players[index];
            team = player.pers["team"];
            if (level.splitscreen)
            {
                if (winner == "tie")
                {
                    player maps/mp/gametypes/_globallogic_audio::set_music_on_player("DRAW");
                }
                else
                {
                    if (winner == team)
                    {
                        music = game["music"]["victory_" + player.team];
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player(music);
                    }
                    else
                    {
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player("LOSE");
                    }
                }
            }
            else
            {
                if (winner == "tie")
                {
                    player maps/mp/gametypes/_globallogic_audio::set_music_on_player("DRAW");
                }
                else
                {
                    if (winner == team)
                    {
                        music = game["music"]["victory_" + player.team];
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player(music);
                    }
                    else
                    {
                        player maps/mp/gametypes/_globallogic_audio::set_music_on_player("LOSE");
                    }
                }
            }
            index++;
        }
    }
    bbprint("session_epilogs", "reason %s", endreasontext);
    bbprint("mpmatchfacts", "gametime %d winner %s killstreakcount %d", getTime(), winner, level.killstreak_counter);
    roundendwait(level.postroundtime, 1);
}

getendreasontext()
{
    while (isDefined(level.endreasontext))
    {
        return level.endreasontext;
    }
    if (hitroundlimit() || hitroundwinlimit())
    {
        return game["strings"]["round_limit_reached"];
    }
    else
    {
        if (hitscorelimit())
        {
            return game["strings"]["score_limit_reached"];
        }
    }
    if (level.forcedend)
    {
        if (level.hostforcedend)
        {
            return &"MP_HOST_ENDED_GAME";
        }
        else
        {
            return &"MP_ENDED_GAME";
        }
    }
    return game["strings"]["time_limit_reached"];
}

resetoutcomeforallplayers()
{
    players = level.players;
    index = 0;
    while (index < players.size)
    {
        player = players[index];
        player notify("reset_outcome");
        index++;
    }
}

startnextround(winner, endreasontext)
{
    if (!isoneround())
    {
        displayroundend(winner, endreasontext);
        maps/mp/gametypes/_globallogic_utils::executepostroundevents();
        if (!waslastround())
        {
            while (checkroundswitch())
            {
                displayroundswitch(winner, endreasontext);
            }
            if (isDefined(level.nextroundisovertime) && level.nextroundisovertime)
            {
                if (!isDefined(game["overtime_round"]))
                {
                    game["overtime_round"] = 1;
                }
                else
                {
                    game["overtime_round"]++;
                }
            }
            setmatchtalkflag("DeadChatWithDead", level.voip.deadchatwithdead);
            setmatchtalkflag("DeadChatWithTeam", level.voip.deadchatwithteam);
            setmatchtalkflag("DeadHearTeamLiving", level.voip.deadhearteamliving);
            setmatchtalkflag("DeadHearAllLiving", level.voip.deadhearallliving);
            setmatchtalkflag("EveryoneHearsEveryone", level.voip.everyonehearseveryone);
            setmatchtalkflag("DeadHearKiller", level.voip.deadhearkiller);
            setmatchtalkflag("KillersHearVictim", level.voip.killershearvictim);
            game["state"] = "playing";
            level.allowbattlechatter = getgametypesetting("allowBattleChatter");
            map_restart(1);
            return 1;
        }
    }
    return 0;
}

settopplayerstats()
{
    while (level.rankedmatch || level.wagermatch)
    {
        placement = level.placement["all"];
        topthreeplayers = min(3, placement.size);
        index = 0;
        while (index < topthreeplayers)
        {
            if (level.placement["all"][index].score)
            {
                if (!index)
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
                while (level.hardcoremode)
                {
                    level.placement["all"][index] addplayerstat("TOP3ANY_HC", 1);
                }
                while (level.multiteam)
                {
                    level.placement["all"][index] addplayerstat("TOP3ANY_MULTITEAM", 1);
                }
                level.placement["all"][index] notify("top3");
            }
            index++;
        }
        index = 3;
        while (index < placement.size)
        {
            level.placement["all"][index] notify("nottop3");
            level.placement["all"][index] notify("nottopplayer");
            index++;
        }
        while (level.teambased)
        {
            _a1500 = level.teams;
            _k1500 = getFirstArrayKey(_a1500);
            while (isDefined(_k1500))
            {
                team = _a1500[_k1500];
                settopteamstats(team);
                _k1500 = getNextArrayKey(_a1500, _k1500);
            }
        }
    }
}

settopteamstats(team)
{
    placementteam = level.placement[team];
    topthreeteamplayers = min(3, placementteam.size);
    if (placementteam.size < 5)
    {
        return;
    }
    index = 0;
    while (index < topthreeteamplayers)
    {
        while (placementteam[index].score)
        {
            placementteam[index] addplayerstat("TOP3TEAM", 1);
            placementteam[index] addplayerstat("TOP3ANY", 1);
            while (level.hardcoremode)
            {
                placementteam[index] addplayerstat("TOP3ANY_HC", 1);
            }
            while (level.multiteam)
            {
                placementteam[index] addplayerstat("TOP3ANY_MULTITEAM", 1);
            }
            placementteam[index] addplayerstatwithgametype("TOP3TEAM", 1);
        }
        index++;
    }
}

getgamelength()
{
    if (!(level.timelimit) || level.forcedend)
    {
        gamelength = maps/mp/gametypes/_globallogic_utils::gettimepassed() / 1000;
        gamelength = min(gamelength, 1200);
    }
    else
    {
        gamelength = level.timelimit * 60;
    }
    return gamelength;
}

endgame(winner, endreasontext)
{
    if (game["state"] == "postgame" || level.gameended)
    {
        return;
    }
    if (isDefined(level.onendgame))
    {
        [[level.onendgame]](winner);
    }
    if (!level.wagermatch)
    {
        setmatchflag("enable_popups", 0);
    }
    if (!(isDefined(level.disableoutrovisionset)) || level.disableoutrovisionset == 0)
    {
        if (sessionmodeiszombiesgame() && level.forcedend)
        {
            visionsetnaked("zombie_last_stand", 2);
        }
        else
        {
            visionsetnaked("mpOutro", 2);
        }
    }
    setmatchflag("cg_drawSpectatorMessages", 0);
    setmatchflag("game_ended", 1);
    game["state"] = "postgame";
    level.gameendtime = getTime();
    level.gameended = 1;
    setdvar("g_gameEnded", 1);
    level.ingraceperiod = 0;
    level notify("game_ended");
    level.allowbattlechatter = 0;
    maps/mp/gametypes/_globallogic_audio::flushdialog();
    _a1595 = level.teams;
    _k1595 = getFirstArrayKey(_a1595);
    while (isDefined(_k1595))
    {
        team = _a1595[_k1595];
        game["lastroundscore"][team] = getteamscore(team);
        _k1595 = getNextArrayKey(_a1595, _k1595);
    }
    if (!(isDefined(game["overtime_round"])) || waslastround())
    {
        game["roundsplayed"]++;
        game["roundwinner"][game["roundsplayed"]] = winner;
        if (level.teambased)
        {
            game["roundswon"][winner]++;
        }
    }
    if (isDefined(winner) && level.teambased && isDefined(level.teams[winner]))
    {
        level.finalkillcam_winner = winner;
    }
    else
    {
        level.finalkillcam_winner = "none";
    }
    setgameendtime(0);
    updateplacement();
    updaterankedmatch(winner);
    players = level.players;
    newtime = getTime();
    gamelength = getgamelength();
    setmatchtalkflag("EveryoneHearsEveryone", 1);
    bbgameover = 0;
    if (isoneround() || waslastround())
    {
        bbgameover = 1;
    }
    index = 0;
    while (index < players.size)
    {
        player = players[index];
        player maps/mp/gametypes/_globallogic_player::freezeplayerforroundend();
        player thread roundenddof(4);
        player maps/mp/gametypes/_globallogic_ui::freegameplayhudelems();
        player maps/mp/gametypes/_weapons::updateweapontimings(newtime);
        player bbplayermatchend(gamelength, endreasontext, bbgameover);
        if (ispregame())
        {
        }
        else
        {
            while (level.rankedmatch || level.wagermatch || level.leaguematch && !(player issplitscreen()))
            {
                if (level.leaguematch)
                {
                    player setdstat("AfterActionReportStats", "lobbyPopup", "leaguesummary");
                }
                else
                {
                    if (isDefined(player.setpromotion))
                    {
                        player setdstat("AfterActionReportStats", "lobbyPopup", "promotion");
                    }
                    else
                    {
                        player setdstat("AfterActionReportStats", "lobbyPopup", "summary");
                    }
                }
            }
        }
        index++;
    }
    maps/mp/_music::setmusicstate("SILENT");
    if (!level.infinalkillcam)
    {
    }
    maps/mp/_gamerep::gamerepupdateinformationforround();
    maps/mp/gametypes/_wager::finalizewagerround();
    thread maps/mp/_challenges::roundend(winner);
    if (startnextround(winner, endreasontext))
    {
        return;
    }
    if (!(isoneround()) && !(level.gameforfeited))
    {
        if (isDefined(level.onroundendgame))
        {
            winner = [[level.onroundendgame]](winner);
        }
        endreasontext = getendreasontext();
    }
    while (!(level.wagermatch) && !(sessionmodeiszombiesgame()))
    {
        maps/mp/gametypes/_globallogic_score::updatewinlossstats(winner);
    }
    if (level.teambased)
    {
        if (winner == "tie")
        {
            recordgameresult("draw");
        }
        else
        {
            recordgameresult(winner);
        }
    }
    else
    {
        if (!isDefined(winner))
        {
            recordgameresult("draw");
        }
        else
        {
            recordgameresult(winner.team);
        }
    }
    skillupdate(winner, level.teambased);
    recordleaguewinner(winner);
    settopplayerstats();
    thread maps/mp/_challenges::gameend(winner);
    if (!(isDefined(level.skipgameend)) || !(level.skipgameend))
    {
        if (isDefined(level.preendgamefunction))
        {
            thread [[level.preendgamefunction]](level.postroundtime);
        }
        displaygameend(winner, endreasontext);
    }
    if (isoneround())
    {
        maps/mp/gametypes/_globallogic_utils::executepostroundevents();
    }
    level.intermission = 1;
    maps/mp/_gamerep::gamerepanalyzeandreport();
    if (!ispregame())
    {
        thread sendafteractionreport();
    }
    maps/mp/gametypes/_wager::finalizewagergame();
    setmatchtalkflag("EveryoneHearsEveryone", 1);
    players = level.players;
    index = 0;
    while (index < players.size)
    {
        player = players[index];
        recordplayerstats(player, "presentAtEnd", 1);
        player closemenu();
        player closeingamemenu();
        player notify("reset_outcome");
        player thread [[level.spawnintermission]]();
        player setclientuivisibilityflag("hud_visible", 1);
        index++;
    }
    if (isDefined(level.endgamefunction))
    {
        level thread [[level.endgamefunction]]();
    }
    level notify("sfade");
    logstring("game ended");
    if (!(isDefined(level.skipgameend)) || !(level.skipgameend))
    {
        wait 5;
    }
    exitlevel(0);
}

bbplayermatchend(gamelength, endreasonstring, gameover)
{
    playerrank = getplacementforplayer(self);
    totaltimeplayed = 0;
    if (isDefined(self.timeplayed) && isDefined(self.timeplayed["total"]))
    {
        totaltimeplayed = self.timeplayed["total"];
        if (totaltimeplayed > gamelength)
        {
            totaltimeplayed = gamelength;
        }
    }
    xuid = self getxuid();
    bbprint("mpplayermatchfacts", "score %d momentum %d endreason %s sessionrank %d playtime %d xuid %s gameover %d team %s", self.pers["score"], self.pers["momentum"], endreasonstring, playerrank, totaltimeplayed, xuid, gameover, self.pers["team"]);
}

roundendwait(defaultdelay, matchbonus)
{
    notifiesdone = 0;
    if (!notifiesdone)
    {
        players = level.players;
        notifiesdone = 1;
        index = 0;
        while (index < players.size)
        {
            if (!(isDefined(players[index].doingnotify)) || !(players[index].doingnotify))
            {
            }
            else
            {
                notifiesdone = 0;
            }
            index++;
        }
        wait 0.5;
    }
    if (!matchbonus)
    {
        wait defaultdelay;
        level notify("round_end_done");
        return;
    }
    wait defaultdelay / 2;
    level notify("give_match_bonus");
    wait defaultdelay / 2;
    notifiesdone = 0;
    if (!notifiesdone)
    {
        players = level.players;
        notifiesdone = 1;
        index = 0;
        while (index < players.size)
        {
            if (!(isDefined(players[index].doingnotify)) || !(players[index].doingnotify))
            {
            }
            else
            {
                notifiesdone = 0;
            }
            index++;
        }
        wait 0.5;
    }
    level notify("round_end_done");
}

roundenddof(time)
{
    self setdepthoffield(0, 128, 512, 4000, 6, 1.8);
}

checktimelimit()
{
    if (isDefined(level.timelimitoverride) && level.timelimitoverride)
    {
        return;
    }
    if (game["state"] != "playing")
    {
        setgameendtime(0);
        return;
    }
    if (level.timelimit <= 0)
    {
        setgameendtime(0);
        return;
    }
    if (level.inprematchperiod)
    {
        setgameendtime(0);
        return;
    }
    if (level.timerstopped)
    {
        setgameendtime(0);
        return;
    }
    if (!isDefined(level.starttime))
    {
        return;
    }
    timeleft = maps/mp/gametypes/_globallogic_utils::gettimeremaining();
    setgameendtime(getTime() + int(timeleft));
    if (timeleft > 0)
    {
        return;
    }
    [[level.ontimelimit]]();
}

allteamsunderscorelimit()
{
    _a1917 = level.teams;
    _k1917 = getFirstArrayKey(_a1917);
    while (isDefined(_k1917))
    {
        team = _a1917[_k1917];
        if (game["teamScores"][team] >= level.scorelimit)
        {
            return 0;
        }
        _k1917 = getNextArrayKey(_a1917, _k1917);
    }
    return 1;
}

checkscorelimit()
{
    if (game["state"] != "playing")
    {
        return 0;
    }
    if (level.scorelimit <= 0)
    {
        return 0;
    }
    if (level.teambased)
    {
        if (allteamsunderscorelimit())
        {
            return 0;
        }
    }
    else
    {
        if (!isplayer(self))
        {
            return 0;
        }
        if (self.pointstowin < level.scorelimit)
        {
            return 0;
        }
    }
    [[level.onscorelimit]]();
}

updategametypedvars()
{
    level endon("game_ended");
    while (game["state"] == "playing")
    {
        roundlimit = clamp(getgametypesetting("roundLimit"), level.roundlimitmin, level.roundlimitmax);
        if (roundlimit != level.roundlimit)
        {
            level.roundlimit = roundlimit;
            level notify("update_roundlimit");
        }
        timelimit = [[level.gettimelimit]]();
        if (timelimit != level.timelimit)
        {
            level.timelimit = timelimit;
            setdvar("ui_timelimit", level.timelimit);
            level notify("update_timelimit");
        }
        thread checktimelimit();
        scorelimit = clamp(getgametypesetting("scoreLimit"), level.scorelimitmin, level.scorelimitmax);
        if (scorelimit != level.scorelimit)
        {
            level.scorelimit = scorelimit;
            setdvar("ui_scorelimit", level.scorelimit);
            level notify("update_scorelimit");
        }
        thread checkscorelimit();
        while (isDefined(level.starttime))
        {
            while (maps/mp/gametypes/_globallogic_utils::gettimeremaining() < 3000)
            {
                wait 0.1;
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
    i = 0;
    while (i < numplayers)
    {
        if (level.placement["all"][i] == self)
        {
            found = 1;
        }
        if (found)
        {
            level.placement["all"][i] = level.placement["all"][i + 1];
        }
        i++;
    }
    if (!found)
    {
        return;
    }
    level.placement["all"][numplayers - 1] = undefined;
    updateteamplacement();
    if (level.teambased)
    {
        return;
    }
    numplayers = level.placement["all"].size;
    i = 0;
    while (i < numplayers)
    {
        player = level.placement["all"][i];
        player notify("update_outcome");
        i++;
    }
}

updateplacement()
{
    if (!level.players.size)
    {
        return;
    }
    level.placement["all"] = [];
    index = 0;
    while (index < level.players.size)
    {
        if (isDefined(level.teams[level.players[index].team]))
        {
            level.placement["all"][level.placement["all"].size] = level.players[index];
        }
        index++;
    }
    placementall = level.placement["all"];
    if (level.teambased)
    {
        i = 1;
        while (i < placementall.size)
        {
            player = placementall[i];
            playerscore = player.score;
            j = i - 1;
            while (j >= 0 && playerscore > placementall[j].score || playerscore == placementall[j].score && player.deaths < placementall[j].deaths)
            {
                placementall[j + 1] = placementall[j];
                j--;
            }
            placementall[j + 1] = player;
            i++;
        }
    }
    else
    {
        i = 1;
        while (i < placementall.size)
        {
            player = placementall[i];
            playerscore = player.pointstowin;
            j = i - 1;
            while (j >= 0 && playerscore > placementall[j].pointstowin || playerscore == placementall[j].pointstowin && player.deaths < placementall[j].deaths)
            {
                placementall[j + 1] = placementall[j];
                j--;
            }
            placementall[j + 1] = player;
            i++;
        }
    }
    level.placement["all"] = placementall;
    updateteamplacement();
}

updateteamplacement()
{
    _a2085 = level.teams;
    _k2085 = getFirstArrayKey(_a2085);
    while (isDefined(_k2085))
    {
        team = _a2085[_k2085];
        placement[team] = [];
        _k2085 = getNextArrayKey(_a2085, _k2085);
    }
    placement["spectator"] = [];
    if (!level.teambased)
    {
        return;
    }
    placementall = level.placement["all"];
    placementallsize = placementall.size;
    i = 0;
    while (i < placementallsize)
    {
        player = placementall[i];
        team = player.pers["team"];
        placement[team][placement[team].size] = player;
        i++;
    }
    _a2105 = level.teams;
    _k2105 = getFirstArrayKey(_a2105);
    while (isDefined(_k2105))
    {
        team = _a2105[_k2105];
        level.placement[team] = placement[team];
        _k2105 = getNextArrayKey(_a2105, _k2105);
    }
}

getplacementforplayer(player)
{
    updateplacement();
    playerrank = -1;
    placement = level.placement["all"];
    placementindex = 0;
    while (placementindex < placement.size)
    {
        if (level.placement["all"][placementindex] == player)
        {
            playerrank = placementindex + 1;
        }
        else
        {
            placementindex++;
        }
    }
    return playerrank;
}

istopscoringplayer(player)
{
    topplayer = 0;
    updateplacement();
    if (level.placement["all"].size == 0)
    {
        return 0;
    }
    if (level.teambased)
    {
        topscore = level.placement["all"][0].score;
        index = 0;
        while (index < level.placement["all"].size)
        {
            if (level.placement["all"][index].score == 0)
            {
            }
            else
            {
                if (topscore > level.placement["all"][index].score)
                {
                }
                else
                {
                    if (self == level.placement["all"][index])
                    {
                        topscoringplayer = 1;
                    }
                    else
                    {
                        index++;
                    }
                }
            }
        }
    }
    else
    {
        topscore = level.placement["all"][0].pointstowin;
        index = 0;
        while (index < level.placement["all"].size)
        {
            if (level.placement["all"][index].pointstowin == 0)
            {
            }
            else
            {
                if (topscore > level.placement["all"][index].pointstowin)
                {
                }
                else
                {
                    if (self == level.placement["all"][index])
                    {
                        topplayer = 1;
                    }
                    else
                    {
                        index++;
                    }
                }
            }
        }
    }
    return topplayer;
}

sortdeadplayers(team)
{
    if (!level.playerqueuedrespawn)
    {
        return;
    }
    i = 1;
    while (i < level.deadplayers[team].size)
    {
        player = level.deadplayers[team][i];
        j = i - 1;
        while (j >= 0 && player.deathtime < level.deadplayers[team][j].deathtime)
        {
            level.deadplayers[team][j + 1] = level.deadplayers[team][j];
            j--;
        }
        level.deadplayers[team][j + 1] = player;
        i++;
    }
    i = 0;
    while (i < level.deadplayers[team].size)
    {
        if (level.deadplayers[team][i].spawnqueueindex != i)
        {
            level.spawnqueuemodified[team] = 1;
        }
        level.deadplayers[team][i].spawnqueueindex = i;
        i++;
    }
}

totalalivecount()
{
    count = 0;
    _a2211 = level.teams;
    _k2211 = getFirstArrayKey(_a2211);
    while (isDefined(_k2211))
    {
        team = _a2211[_k2211];
        count = count + level.alivecount[team];
        _k2211 = getNextArrayKey(_a2211, _k2211);
    }
    return count;
}

totalplayerlives()
{
    count = 0;
    _a2221 = level.teams;
    _k2221 = getFirstArrayKey(_a2221);
    while (isDefined(_k2221))
    {
        team = _a2221[_k2221];
        count = count + level.playerlives[team];
        _k2221 = getNextArrayKey(_a2221, _k2221);
    }
    return count;
}

totalplayercount()
{
    count = 0;
    _a2231 = level.teams;
    _k2231 = getFirstArrayKey(_a2231);
    while (isDefined(_k2231))
    {
        team = _a2231[_k2231];
        count = count + level.playercount[team];
        _k2231 = getNextArrayKey(_a2231, _k2231);
    }
    return count;
}

initteamvariables(team)
{
    if (!isDefined(level.alivecount))
    {
        level.alivecount = [];
    }
    level.alivecount[team] = 0;
    level.lastalivecount[team] = 0;
    if (!isDefined(game["everExisted"]))
    {
        game["everExisted"] = [];
    }
    if (!isDefined(game["everExisted"][team]))
    {
        game["everExisted"][team] = 0;
    }
    level.everexisted[team] = 0;
    level.wavedelay[team] = 0;
    level.lastwave[team] = 0;
    level.waveplayerspawnindex[team] = 0;
    resetteamvariables(team);
}

resetteamvariables(team)
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
    level notify("updating_team_status");
    level endon("updating_team_status");
    level endon("game_ended");
    waitTillFrameEnd;
    wait 0;
    if (game["state"] == "postgame")
    {
        return;
    }
    resettimeout();
    _a2291 = level.teams;
    _k2291 = getFirstArrayKey(_a2291);
    while (isDefined(_k2291))
    {
        team = _a2291[_k2291];
        resetteamvariables(team);
        _k2291 = getNextArrayKey(_a2291, _k2291);
    }
    level.activeplayers = [];
    players = level.players;
    i = 0;
    while (i < players.size)
    {
        player = players[i];
        if (!(isDefined(player)) && level.splitscreen)
        {
        }
        else
        {
            team = player.team;
            class = player.class;
            if (team != "spectator" && isDefined(class) && class != "")
            {
                level.playercount[team]++;
                if (isDefined(player.pers["isBot"]))
                {
                    level.botscount[team]++;
                }
                if (player.sessionstate == "playing")
                {
                    level.alivecount[team]++;
                    level.playerlives[team]++;
                    player.spawnqueueindex = -1;
                    if (isalive(player))
                    {
                        level.aliveplayers[team][level.aliveplayers[team].size] = player;
                        level.activeplayers[level.activeplayers.size] = player;
                    }
                    else
                    {
                        level.deadplayers[team][level.deadplayers[team].size] = player;
                    }
                }
                else
                {
                    level.deadplayers[team][level.deadplayers[team].size] = player;
                    if (player maps/mp/gametypes/_globallogic_spawn::mayspawn())
                    {
                        level.playerlives[team]++;
                    }
                }
            }
        }
        i++;
    }
    totalalive = totalalivecount();
    if (totalalive > level.maxplayercount)
    {
        level.maxplayercount = totalalive;
    }
    _a2346 = level.teams;
    _k2346 = getFirstArrayKey(_a2346);
    while (isDefined(_k2346))
    {
        team = _a2346[_k2346];
        if (level.alivecount[team])
        {
            game["everExisted"][team] = 1;
            level.everexisted[team] = 1;
        }
        sortdeadplayers(team);
        _k2346 = getNextArrayKey(_a2346, _k2346);
    }
    level updategameevents();
}

checkteamscorelimitsoon(team)
{
    if (level.scorelimit <= 0)
    {
        return;
    }
    if (!level.teambased)
    {
        return;
    }
    if (maps/mp/gametypes/_globallogic_utils::gettimepassed() < 60000)
    {
        return;
    }
    timeleft = maps/mp/gametypes/_globallogic_utils::getestimatedtimeuntilscorelimit(team);
    if (timeleft < 1)
    {
        level notify("match_ending_soon", "score");
    }
}

checkplayerscorelimitsoon()
{
    if (level.scorelimit <= 0)
    {
        return;
    }
    if (level.teambased)
    {
        return;
    }
    if (maps/mp/gametypes/_globallogic_utils::gettimepassed() < 60000)
    {
        return;
    }
    timeleft = maps/mp/gametypes/_globallogic_utils::getestimatedtimeuntilscorelimit(undefined);
    if (timeleft < 1)
    {
        level notify("match_ending_soon", "score");
    }
}

timelimitclock()
{
    level endon("game_ended");
    wait 0.05;
    clockobject = spawn("script_origin", (0, 0, 0));
    while (game["state"] == "playing")
    {
        if (!(level.timerstopped) && level.timelimit)
        {
            timeleft = maps/mp/gametypes/_globallogic_utils::gettimeremaining() / 1000;
            timeleftint = int(timeleft + 0.5);
            if (timeleftint == 601)
            {
                clientnotify("notify_10");
            }
            if (timeleftint == 301)
            {
                clientnotify("notify_5");
            }
            if (timeleftint == 60)
            {
                clientnotify("notify_1");
            }
            if (timeleftint == 12)
            {
                clientnotify("notify_count");
            }
            if (timeleftint >= 40 && timeleftint <= 60)
            {
                level notify("match_ending_soon", "time");
            }
            if (timeleftint >= 30 && timeleftint <= 40)
            {
                level notify("match_ending_pretty_soon", "time");
            }
            if (timeleftint <= 32)
            {
                level notify("match_ending_vox");
            }
            if (timeleftint <= 10 || timeleftint <= 30 && timeleftint % 2 == 0)
            {
                level notify("match_ending_very_soon", "time");
                if (timeleftint == 0)
                {
                }
                else
                {
                    clockobject playsound("mpl_ui_timer_countdown");
                }
                if (timeleft - floor(timeleft) >= 0.05)
                {
                    wait timeleft - floor(timeleft);
                }
            }
            wait 1;
        }
    }
}

timelimitclock_intermission(waittime)
{
    setgameendtime(getTime() + int(waittime * 1000));
    clockobject = spawn("script_origin", (0, 0, 0));
    if (waittime >= 10)
    {
        wait waittime - 10;
    }
    clockobject playsound("mpl_ui_timer_countdown");
    wait 1;
}

startgame()
{
    thread maps/mp/gametypes/_globallogic_utils::gametimer();
    level.timerstopped = 0;
    setmatchtalkflag("DeadChatWithDead", level.voip.deadchatwithdead);
    setmatchtalkflag("DeadChatWithTeam", level.voip.deadchatwithteam);
    setmatchtalkflag("DeadHearTeamLiving", level.voip.deadhearteamliving);
    setmatchtalkflag("DeadHearAllLiving", level.voip.deadhearallliving);
    setmatchtalkflag("EveryoneHearsEveryone", level.voip.everyonehearseveryone);
    setmatchtalkflag("DeadHearKiller", level.voip.deadhearkiller);
    setmatchtalkflag("KillersHearVictim", level.voip.killershearvictim);
    prematchperiod();
    level notify("prematch_over");
    thread timelimitclock();
    thread graceperiod();
    thread watchmatchendingsoon();
    thread maps/mp/gametypes/_globallogic_audio::musiccontroller();
    recordmatchbegin();
}

waitforplayers()
{
    starttime = getTime();
    while (getnumconnectedplayers() < 1)
    {
        wait 0.05;
        while (getTime() - starttime > 120000)
        {
            exitlevel(0);
        }
    }
}

prematchperiod()
{
    setmatchflag("hud_hardcore", level.hardcoremode);
    level endon("game_ended");
    if (level.prematchperiod > 0)
    {
        thread matchstarttimer();
        waitforplayers();
        wait level.prematchperiod;
    }
    else
    {
        matchstarttimerskip();
        wait 0.05;
    }
    level.inprematchperiod = 0;
    index = 0;
    while (index < level.players.size)
    {
        level.players[index] freeze_player_controls(0);
        level.players[index] enableweapons();
        index++;
    }
    maps/mp/gametypes/_wager::prematchperiod();
    if (game["state"] != "playing")
    {
        return;
    }
}

graceperiod()
{
    level endon("game_ended");
    if (isDefined(level.graceperiodfunc))
    {
        [[level.graceperiodfunc]]();
    }
    else
    {
        wait level.graceperiod;
    }
    level notify("grace_period_ending");
    wait 0.05;
    level.ingraceperiod = 0;
    if (game["state"] != "playing")
    {
        return;
    }
    while (level.numlives)
    {
        players = level.players;
        i = 0;
        while (i < players.size)
        {
            player = players[i];
            while (!(player.hasspawned) && player.sessionteam != "spectator" && !(isalive(player)))
            {
                player.statusicon = "hud_status_dead";
            }
            i++;
        }
    }
    level thread updateteamstatus();
}

watchmatchendingsoon()
{
    setdvar("xblive_matchEndingSoon", 0);
    level waittill("match_ending_soon", reason);
    setdvar("xblive_matchEndingSoon", 1);
}

assertteamvariables()
{
    while (!(level.createfx_enabled) && !(sessionmodeiszombiesgame()))
    {
        _a2604 = level.teams;
        _k2604 = getFirstArrayKey(_a2604);
        while (isDefined(_k2604))
        {
            team = _a2604[_k2604];
            _k2604 = getNextArrayKey(_a2604, _k2604);
        }
    }
}

anyteamhaswavedelay()
{
    _a2622 = level.teams;
    _k2622 = getFirstArrayKey(_a2622);
    while (isDefined(_k2622))
    {
        team = _a2622[_k2622];
        if (level.wavedelay[team])
        {
            return 1;
        }
        _k2622 = getNextArrayKey(_a2622, _k2622);
    }
    return 0;
}

callback_startgametype()
{
    level.prematchperiod = 0;
    level.intermission = 0;
    setmatchflag("cg_drawSpectatorMessages", 1);
    setmatchflag("game_ended", 0);
    if (!isDefined(game["gamestarted"]))
    {
        if (!isDefined(game["allies"]))
        {
            game["allies"] = "seals";
        }
        if (!isDefined(game["axis"]))
        {
            game["axis"] = "pmc";
        }
        if (!isDefined(game["attackers"]))
        {
            game["attackers"] = "allies";
        }
        if (!isDefined(game["defenders"]))
        {
            game["defenders"] = "axis";
        }
        _a2655 = level.teams;
        _k2655 = getFirstArrayKey(_a2655);
        while (isDefined(_k2655))
        {
            team = _a2655[_k2655];
            if (!isDefined(game[team]))
            {
                game[team] = "pmc";
            }
            _k2655 = getNextArrayKey(_a2655, _k2655);
        }
        if (!isDefined(game["state"]))
        {
            game["state"] = "playing";
        }
        precacherumble("damage_heavy");
        precacherumble("damage_light");
        precacheshader("white");
        precacheshader("black");
        makedvarserverinfo("scr_allies", "marines");
        makedvarserverinfo("scr_axis", "nva");
        makedvarserverinfo("cg_thirdPersonAngle", 354);
        setdvar("cg_thirdPersonAngle", 354);
        game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
        if (level.teambased)
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
        assertteamvariables();
        [[level.onprecachegametype]]();
        game["gamestarted"] = 1;
        game["totalKills"] = 0;
        _a2718 = level.teams;
        _k2718 = getFirstArrayKey(_a2718);
        while (isDefined(_k2718))
        {
            team = _a2718[_k2718];
            game["teamScores"][team] = 0;
            game["totalKillsTeam"][team] = 0;
            _k2718 = getNextArrayKey(_a2718, _k2718);
        }
        if (!ispregame())
        {
            level.prematchperiod = getgametypesetting("prematchperiod");
        }
        if (getDvarInt(#"0x1e0679b9") != 0)
        {
            _a2730 = level.teams;
            _k2730 = getFirstArrayKey(_a2730);
            while (isDefined(_k2730))
            {
                team = _a2730[_k2730];
                game["icons"][team] = "composite_emblem_team_axis";
                _k2730 = getNextArrayKey(_a2730, _k2730);
            }
            game["icons"]["allies"] = "composite_emblem_team_allies";
            game["icons"]["axis"] = "composite_emblem_team_axis";
        }
    }
    else
    {
        if (!level.splitscreen)
        {
            level.prematchperiod = getgametypesetting("preroundperiod");
        }
    }
    if (!isDefined(game["timepassed"]))
    {
        game["timepassed"] = 0;
    }
    if (!isDefined(game["roundsplayed"]))
    {
        game["roundsplayed"] = 0;
    }
    setroundsplayed(game["roundsplayed"]);
    if (isDefined(game["overtime_round"]))
    {
        setmatchflag("overtime", 1);
    }
    else
    {
        setmatchflag("overtime", 0);
    }
    if (!isDefined(game["roundwinner"]))
    {
        game["roundwinner"] = [];
    }
    if (!isDefined(game["lastroundscore"]))
    {
        game["lastroundscore"] = [];
    }
    if (!isDefined(game["roundswon"]))
    {
        game["roundswon"] = [];
    }
    if (!isDefined(game["roundswon"]["tie"]))
    {
        game["roundswon"]["tie"] = 0;
    }
    _a2773 = level.teams;
    _k2773 = getFirstArrayKey(_a2773);
    while (isDefined(_k2773))
    {
        team = _a2773[_k2773];
        if (!isDefined(game["roundswon"][team]))
        {
            game["roundswon"][team] = 0;
        }
        level.teamspawnpoints[team] = [];
        level.spawn_point_team_class_names[team] = [];
        _k2773 = getNextArrayKey(_a2773, _k2773);
    }
    level.skipvote = 0;
    level.gameended = 0;
    setdvar("g_gameEnded", 0);
    level.objidstart = 0;
    level.forcedend = 0;
    level.hostforcedend = 0;
    level.hardcoremode = getgametypesetting("hardcoreMode");
    while (level.hardcoremode)
    {
        logstring("game mode: hardcore");
        if (!isDefined(level.friendlyfiredelaytime))
        {
            level.friendlyfiredelaytime = 0;
        }
    }
    if (getDvar(#"0xd16d59fd") == "")
    {
        setdvar("scr_max_rank", "0");
    }
    level.rankcap = getDvarInt(#"0xd16d59fd");
    if (getDvar(#"0x4ebe2cf2") == "")
    {
        setdvar("scr_min_prestige", "0");
    }
    level.minprestige = getDvarInt(#"0x4ebe2cf2");
    level.usestartspawns = 1;
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
    if (getDvar(#"0xf7b30924") == "1")
    {
        level waittill("eternity");
    }
    if (sessionmodeiszombiesgame())
    {
        level.prematchperiod = 0;
        level.persistentdatainfo = [];
        level.maxrecentstats = 10;
        level.maxhitlocations = 19;
        level.globalshotsfired = 0;
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
        thread maps/mp/gametypes/_persistence::init();
        thread maps/mp/gametypes/_menus::init();
        thread maps/mp/gametypes/_hud::init();
        thread maps/mp/gametypes/_serversettings::init();
        thread maps/mp/gametypes/_clientids::init();
        thread maps/mp/teams/_teams::init();
        thread maps/mp/gametypes/_weapons::init();
        thread maps/mp/gametypes/_scoreboard::init();
        thread maps/mp/gametypes/_killcam::init();
        thread maps/mp/gametypes/_shellshock::init();
        thread maps/mp/gametypes/_deathicons::init();
        thread maps/mp/gametypes/_damagefeedback::init();
        thread maps/mp/gametypes/_healthoverlay::init();
        thread maps/mp/gametypes/_spectating::init();
        thread maps/mp/gametypes/_objpoints::init();
        thread maps/mp/gametypes/_gameobjects::init();
        thread maps/mp/gametypes/_spawnlogic::init();
        thread maps/mp/gametypes/_battlechatter_mp::init();
        thread maps/mp/killstreaks/_killstreaks::init();
        thread maps/mp/gametypes/_globallogic_audio::init();
        thread maps/mp/gametypes/_wager::init();
        thread maps/mp/bots/_bot::init();
        thread maps/mp/_decoy::init();
        thread maps/mp/_bb::init();
    }
    if (level.teambased)
    {
        thread maps/mp/gametypes/_friendicons::init();
    }
    thread maps/mp/gametypes/_hud_message::init();
    thread maps/mp/_multi_extracam::init();
    stringnames = getarraykeys(game["strings"]);
    index = 0;
    while (index < stringnames.size)
    {
        precachestring(game["strings"][stringnames][index]);
        index++;
    }
    _a2939 = level.teams;
    _k2939 = getFirstArrayKey(_a2939);
    while (isDefined(_k2939))
    {
        team = _a2939[_k2939];
        initteamvariables(team);
        _k2939 = getNextArrayKey(_a2939, _k2939);
    }
    level.maxplayercount = 0;
    level.activeplayers = [];
    level.allowannouncer = getgametypesetting("allowAnnouncer");
    if (!isDefined(level.timelimit))
    {
        registertimelimit(1, 1440);
    }
    if (!isDefined(level.scorelimit))
    {
        registerscorelimit(1, 500);
    }
    if (!isDefined(level.roundlimit))
    {
        registerroundlimit(0, 10);
    }
    if (!isDefined(level.roundwinlimit))
    {
        registerroundwinlimit(0, 10);
    }
    maps/mp/gametypes/_globallogic_utils::registerpostroundevent(::postroundfinalkillcam);
    maps/mp/gametypes/_globallogic_utils::registerpostroundevent(::postroundsidebet);
    makedvarserverinfo("ui_scorelimit");
    makedvarserverinfo("ui_timelimit");
    makedvarserverinfo("ui_allow_classchange", getDvar(#"0x53e50c7c"));
    wavedelay = level.waverespawndelay;
    if (wavedelay && !(ispregame()))
    {
        _a2972 = level.teams;
        _k2972 = getFirstArrayKey(_a2972);
        while (isDefined(_k2972))
        {
            team = _a2972[_k2972];
            level.wavedelay[team] = wavedelay;
            level.lastwave[team] = 0;
            _k2972 = getNextArrayKey(_a2972, _k2972);
        }
        level thread [[level.wavespawntimer]]();
    }
    level.inprematchperiod = 1;
    if (level.prematchperiod > 2)
    {
        level.prematchperiod = level.prematchperiod + randomfloat(4) - 2;
    }
    if (level.numlives || anyteamhaswavedelay() || level.playerqueuedrespawn)
    {
        level.graceperiod = 15;
    }
    else
    {
        level.graceperiod = 5;
    }
    level.ingraceperiod = 1;
    level.roundenddelay = 5;
    level.halftimeroundenddelay = 3;
    maps/mp/gametypes/_globallogic_score::updateallteamscores();
    level.killstreaksenabled = 1;
    if (getDvar(#"0xdfd7387c") == "")
    {
        setdvar("scr_game_rankenabled", 1);
    }
    level.rankenabled = getDvarInt(#"0xdfd7387c");
    if (getDvar(#"0x273f6466") == "")
    {
        setdvar("scr_game_medalsenabled", 1);
    }
    level.medalsenabled = getDvarInt(#"0x273f6466");
    if (level.hardcoremode && level.rankedmatch && getDvar(#"0x9c756af7") == "")
    {
        setdvar("scr_game_friendlyFireDelay", 1);
    }
    level.friendlyfiredelay = getDvarInt(#"0x9c756af7");
    if (getDvar(#"0x134d5297") == "")
    {
        [[level.onstartgametype]]();
    }
    while (getDvarInt(#"0x826eb3b9") == 1)
    {
        level.killstreaksenabled = 0;
    }
    level thread maps/mp/gametypes/_killcam::dofinalkillcam();
    thread startgame();
    level thread updategametypedvars();
}

forcedebughostmigration()
{}

registerfriendlyfiredelay(dvarstring, defaultvalue, minvalue, maxvalue)
{
    dvarstring = "scr_" + dvarstring + "_friendlyFireDelayTime";
    if (getDvar(#"dvarstring") == "")
    {
        setdvar(dvarstring, defaultvalue);
    }
    if (getDvarInt(#"dvarstring") > maxvalue)
    {
        setdvar(dvarstring, maxvalue);
    }
    else
    {
        if (getDvarInt(#"dvarstring") < minvalue)
        {
            setdvar(dvarstring, minvalue);
        }
    }
    level.friendlyfiredelaytime = getDvarInt(#"dvarstring");
}

checkroundswitch()
{
    if (!(isDefined(level.roundswitch)) || !(level.roundswitch))
    {
        return 0;
    }
    if (!isDefined(level.onroundswitch))
    {
        return 0;
    }
    if (game["roundsplayed"] % level.roundswitch == 0)
    {
        [[level.onroundswitch]]();
        return 1;
    }
    return 0;
}

listenforgameend()
{
    self waittill("host_sucks_end_game");
    level.skipvote = 1;
    if (!level.gameended)
    {
        level thread maps/mp/gametypes/_globallogic::forceend(1);
    }
}

getkillstreaks(player)
{
    killstreaknum = 0;
    while (killstreaknum < level.maxkillstreaks)
    {
        killstreak[killstreaknum] = "killstreak_null";
        killstreaknum++;
    }
    while (isplayer(player) && !(level.oldschool) && level.disableclassselection != 1 && !(isDefined(player.pers["isBot"])) && isDefined(player.killstreak))
    {
        currentkillstreak = 0;
        killstreaknum = 0;
        while (killstreaknum < level.maxkillstreaks)
        {
            if (isDefined(player.killstreak[killstreaknum]))
            {
                killstreak[currentkillstreak] = player.killstreak[killstreaknum];
                currentkillstreak++;
            }
            killstreaknum++;
        }
    }
    return killstreak;
}

updaterankedmatch(winner)
{
    if (level.rankedmatch)
    {
        if (hostidledout())
        {
            level.hostforcedend = 1;
            logstring("host idled out");
            endlobby();
        }
    }
    if (!(level.wagermatch) && !(sessionmodeiszombiesgame()))
    {
        maps/mp/gametypes/_globallogic_score::updatematchbonusscores(winner);
    }
}

//GLOBALLOGIC.GSC - Black Ops 2 GSC