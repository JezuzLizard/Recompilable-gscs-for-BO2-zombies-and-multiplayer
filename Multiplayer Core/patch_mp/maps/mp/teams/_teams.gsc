// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_persistence;
#include maps\mp\gametypes\_globallogic_ui;
#include maps\mp\gametypes\_spectating;

init()
{
    precacheshader( "mpflag_spectator" );
    game["strings"]["autobalance"] = &"MP_AUTOBALANCE_NOW";
    precachestring( &"MP_AUTOBALANCE_NOW" );

    if ( getdvar( "scr_teambalance" ) == "" )
        setdvar( "scr_teambalance", "0" );

    level.teambalance = getdvarint( "scr_teambalance" );
    level.teambalancetimer = 0;

    if ( getdvar( "scr_timeplayedcap" ) == "" )
        setdvar( "scr_timeplayedcap", "1800" );

    level.timeplayedcap = int( getdvarint( "scr_timeplayedcap" ) );
    level.freeplayers = [];

    if ( level.teambased )
    {
        level.alliesplayers = [];
        level.axisplayers = [];
        level thread onplayerconnect();
        level thread updateteambalancedvar();
        wait 0.15;

        if ( level.rankedmatch || level.leaguematch )
            level thread updateplayertimes();
    }
    else
    {
        level thread onfreeplayerconnect();
        wait 0.15;

        if ( level.rankedmatch || level.leaguematch )
            level thread updateplayertimes();
    }
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onjoinedteam();
        player thread onjoinedspectators();
        player thread trackplayedtime();
    }
}

onfreeplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread trackfreeplayedtime();
    }
}

onjoinedteam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );

        self logstring( "joined team: " + self.pers["team"] );
        self updateteamtime();
    }
}

onjoinedspectators()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_spectators" );

        self.pers["teamTime"] = undefined;
    }
}

trackplayedtime()
{
    self endon( "disconnect" );

    foreach ( team in level.teams )
        self.timeplayed[team] = 0;

    self.timeplayed["free"] = 0;
    self.timeplayed["other"] = 0;
    self.timeplayed["alive"] = 0;

    if ( !isdefined( self.timeplayed["total"] ) || !( level.gametype == "twar" && 0 < game["roundsplayed"] && 0 < self.timeplayed["total"] ) )
        self.timeplayed["total"] = 0;

    while ( level.inprematchperiod )
        wait 0.05;

    for (;;)
    {
        if ( game["state"] == "playing" )
        {
            if ( isdefined( level.teams[self.sessionteam] ) )
            {
                self.timeplayed[self.sessionteam]++;
                self.timeplayed["total"]++;

                if ( isalive( self ) )
                    self.timeplayed["alive"]++;
            }
            else if ( self.sessionteam == "spectator" )
                self.timeplayed["other"]++;
        }

        wait 1.0;
    }
}

updateplayertimes()
{
    nexttoupdate = 0;

    for (;;)
    {
        nexttoupdate++;

        if ( nexttoupdate >= level.players.size )
            nexttoupdate = 0;

        if ( isdefined( level.players[nexttoupdate] ) )
        {
            level.players[nexttoupdate] updateplayedtime();
            level.players[nexttoupdate] maps\mp\gametypes\_persistence::checkcontractexpirations();
        }

        wait 1.0;
    }
}

updateplayedtime()
{
    pixbeginevent( "updatePlayedTime" );

    foreach ( team in level.teams )
    {
        if ( self.timeplayed[team] )
        {
            self addplayerstat( "time_played_" + team, int( min( self.timeplayed[team], level.timeplayedcap ) ) );
            self addplayerstatwithgametype( "time_played_total", int( min( self.timeplayed[team], level.timeplayedcap ) ) );
        }
    }

    if ( self.timeplayed["other"] )
    {
        self addplayerstat( "time_played_other", int( min( self.timeplayed["other"], level.timeplayedcap ) ) );
        self addplayerstatwithgametype( "time_played_total", int( min( self.timeplayed["other"], level.timeplayedcap ) ) );
    }

    if ( self.timeplayed["alive"] )
    {
        timealive = int( min( self.timeplayed["alive"], level.timeplayedcap ) );
        self maps\mp\gametypes\_persistence::incrementcontracttimes( timealive );
        self addplayerstat( "time_played_alive", timealive );
    }

    pixendevent();

    if ( game["state"] == "postgame" )
        return;

    foreach ( team in level.teams )
        self.timeplayed[team] = 0;

    self.timeplayed["other"] = 0;
    self.timeplayed["alive"] = 0;
}

updateteamtime()
{
    if ( game["state"] != "playing" )
        return;

    self.pers["teamTime"] = gettime();
}

updateteambalancedvar()
{
    for (;;)
    {
        teambalance = getdvarint( "scr_teambalance" );

        if ( level.teambalance != teambalance )
            level.teambalance = getdvarint( "scr_teambalance" );

        timeplayedcap = getdvarint( "scr_timeplayedcap" );

        if ( level.timeplayedcap != timeplayedcap )
            level.timeplayedcap = int( getdvarint( "scr_timeplayedcap" ) );

        wait 1;
    }
}

changeteam( team )
{
    if ( self.sessionstate != "dead" )
    {
        self.switching_teams = 1;
        self.joining_team = team;
        self.leaving_team = self.pers["team"];
        self suicide();
    }

    self.pers["team"] = team;
    self.team = team;
    self.pers["weapon"] = undefined;
    self.pers["spawnweapon"] = undefined;
    self.pers["savedmodel"] = undefined;
    self.pers["teamTime"] = undefined;
    self.sessionteam = self.pers["team"];

    if ( !level.teambased )
        self.ffateam = team;

    self maps\mp\gametypes\_globallogic_ui::updateobjectivetext();
    self maps\mp\gametypes\_spectating::setspectatepermissions();
    self setclientscriptmainmenu( game["menu_class"] );
    self openmenu( game["menu_class"] );
    self notify( "end_respawn" );
}

countplayers()
{
    players = level.players;
    playercounts = [];

    foreach ( team in level.teams )
        playercounts[team] = 0;

    foreach ( player in level.players )
    {
        if ( player == self )
            continue;

        team = player.pers["team"];

        if ( isdefined( team ) && isdefined( level.teams[team] ) )
            playercounts[team]++;
    }

    return playercounts;
}

trackfreeplayedtime()
{
    self endon( "disconnect" );

    foreach ( team in level.teams )
        self.timeplayed[team] = 0;

    self.timeplayed["other"] = 0;
    self.timeplayed["total"] = 0;
    self.timeplayed["alive"] = 0;

    for (;;)
    {
        if ( game["state"] == "playing" )
        {
            team = self.pers["team"];

            if ( isdefined( team ) && isdefined( level.teams[team] ) && self.sessionteam != "spectator" )
            {
                self.timeplayed[team]++;
                self.timeplayed["total"]++;

                if ( isalive( self ) )
                    self.timeplayed["alive"]++;
            }
            else
                self.timeplayed["other"]++;
        }

        wait 1.0;
    }
}

set_player_model( team, weapon )
{
    weaponclass = getweaponclass( weapon );
    bodytype = "default";

    switch ( weaponclass )
    {
        case "weapon_sniper":
            bodytype = "rifle";
            break;
        case "weapon_cqb":
            bodytype = "spread";
            break;
        case "weapon_lmg":
            bodytype = "mg";
            break;
        case "weapon_smg":
            bodytype = "smg";
            break;
    }

    self detachall();
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );

    if ( level.multiteam )
    {
        bodytype = "default";

        switch ( team )
        {
            case "team8":
            case "team7":
                team = "allies";
                break;
        }
    }

    self [[ game["set_player_model"][team][bodytype] ]]();
}

getteamflagmodel( teamref )
{
/#
    assert( isdefined( game["flagmodels"] ) );
#/
/#
    assert( isdefined( game["flagmodels"][teamref] ) );
#/
    return game["flagmodels"][teamref];
}

getteamflagcarrymodel( teamref )
{
/#
    assert( isdefined( game["carry_flagmodels"] ) );
#/
/#
    assert( isdefined( game["carry_flagmodels"][teamref] ) );
#/
    return game["carry_flagmodels"][teamref];
}

getteamflagicon( teamref )
{
/#
    assert( isdefined( game["carry_icon"] ) );
#/
/#
    assert( isdefined( game["carry_icon"][teamref] ) );
#/
    return game["carry_icon"][teamref];
}
