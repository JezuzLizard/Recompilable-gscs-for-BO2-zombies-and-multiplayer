// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_globallogic_player;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_globallogic_defaults;
#include maps\mp\gametypes_zm\_spawnlogic;

timeuntilspawn( includeteamkilldelay )
{
    if ( level.ingraceperiod && !self.hasspawned )
        return 0;

    respawndelay = 0;

    if ( self.hasspawned )
    {
        result = self [[ level.onrespawndelay ]]();

        if ( isdefined( result ) )
            respawndelay = result;
        else
            respawndelay = level.playerrespawndelay;

        if ( includeteamkilldelay && ( isdefined( self.teamkillpunish ) && self.teamkillpunish ) )
            respawndelay += maps\mp\gametypes_zm\_globallogic_player::teamkilldelay();
    }

    wavebased = level.waverespawndelay > 0;

    if ( wavebased )
        return self timeuntilwavespawn( respawndelay );

    return respawndelay;
}

allteamshaveexisted()
{
    foreach ( team in level.teams )
    {
        if ( !level.everexisted[team] )
            return false;
    }

    return true;
}

mayspawn()
{
    if ( isdefined( level.mayspawn ) && !self [[ level.mayspawn ]]() )
        return false;

    if ( level.inovertime )
        return false;

    if ( level.playerqueuedrespawn && !isdefined( self.allowqueuespawn ) && !level.ingraceperiod && !level.usestartspawns )
        return false;

    if ( level.numlives )
    {
        if ( level.teambased )
            gamehasstarted = allteamshaveexisted();
        else
            gamehasstarted = level.maxplayercount > 1 || !isoneround() && !isfirstround();

        if ( !self.pers["lives"] && gamehasstarted )
            return false;
        else if ( gamehasstarted )
        {
            if ( !level.ingraceperiod && !self.hasspawned && !level.wagermatch )
                return false;
        }
    }

    return true;
}

timeuntilwavespawn( minimumwait )
{
    earliestspawntime = gettime() + minimumwait * 1000;
    lastwavetime = level.lastwave[self.pers["team"]];
    wavedelay = level.wavedelay[self.pers["team"]] * 1000;

    if ( wavedelay == 0 )
        return 0;

    numwavespassedearliestspawntime = ( earliestspawntime - lastwavetime ) / wavedelay;
    numwaves = ceil( numwavespassedearliestspawntime );
    timeofspawn = lastwavetime + numwaves * wavedelay;

    if ( isdefined( self.wavespawnindex ) )
        timeofspawn += 50 * self.wavespawnindex;

    return ( timeofspawn - gettime() ) / 1000;
}

stoppoisoningandflareonspawn()
{
    self endon( "disconnect" );
    self.inpoisonarea = 0;
    self.inburnarea = 0;
    self.inflarevisionarea = 0;
    self.ingroundnapalm = 0;
}

spawnplayerprediction()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );
    self endon( "game_ended" );
    self endon( "joined_spectators" );
    self endon( "spawned" );

    while ( true )
    {
        wait 0.5;

        if ( isdefined( level.onspawnplayerunified ) && getdvarint( _hash_CF6EEB8B ) == 0 )
            maps\mp\gametypes_zm\_spawning::onspawnplayer_unified( 1 );
        else
            self [[ level.onspawnplayer ]]( 1 );
    }
}

giveloadoutlevelspecific( team, class )
{
    pixbeginevent( "giveLoadoutLevelSpecific" );

    if ( isdefined( level.givecustomcharacters ) )
        self [[ level.givecustomcharacters ]]();

    if ( isdefined( level.givecustomloadout ) )
        self [[ level.givecustomloadout ]]();

    pixendevent();
}

spawnplayer()
{
    pixbeginevent( "spawnPlayer_preUTS" );
    self endon( "disconnect" );
    self endon( "joined_spectators" );
    self notify( "spawned" );
    level notify( "player_spawned" );
    self notify( "end_respawn" );
    self setspawnvariables();

    if ( !self.hasspawned )
    {
        self.underscorechance = 70;
        self thread maps\mp\gametypes_zm\_globallogic_audio::sndstartmusicsystem();
    }

    if ( level.teambased )
        self.sessionteam = self.team;
    else
    {
        self.sessionteam = "none";
        self.ffateam = self.team;
    }

    hadspawned = self.hasspawned;
    self.sessionstate = "playing";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    self.statusicon = "";
    self.damagedplayers = [];

    if ( getdvarint( "scr_csmode" ) > 0 )
        self.maxhealth = getdvarint( "scr_csmode" );
    else
        self.maxhealth = level.playermaxhealth;

    self.health = self.maxhealth;
    self.friendlydamage = undefined;
    self.hasspawned = 1;
    self.spawntime = gettime();
    self.afk = 0;

    if ( self.pers["lives"] && ( !isdefined( level.takelivesondeath ) || level.takelivesondeath == 0 ) )
    {
        self.pers["lives"]--;

        if ( self.pers["lives"] == 0 )
        {
            level notify( "player_eliminated" );
            self notify( "player_eliminated" );
        }
    }

    self.laststand = undefined;
    self.revivingteammate = 0;
    self.burning = undefined;
    self.nextkillstreakfree = undefined;
    self.activeuavs = 0;
    self.activecounteruavs = 0;
    self.activesatellites = 0;
    self.deathmachinekills = 0;
    self.disabledweapon = 0;
    self resetusability();
    self maps\mp\gametypes_zm\_globallogic_player::resetattackerlist();
    self.diedonvehicle = undefined;

    if ( !self.wasaliveatmatchstart )
    {
        if ( level.ingraceperiod || maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() < 20000 )
            self.wasaliveatmatchstart = 1;
    }

    self setdepthoffield( 0, 0, 512, 512, 4, 0 );
    self resetfov();
    pixbeginevent( "onSpawnPlayer" );

    if ( isdefined( level.onspawnplayerunified ) && getdvarint( _hash_CF6EEB8B ) == 0 )
        self [[ level.onspawnplayerunified ]]();
    else
        self [[ level.onspawnplayer ]]( 0 );

    if ( isdefined( level.playerspawnedcb ) )
        self [[ level.playerspawnedcb ]]();

    pixendevent();
    pixendevent();
    level thread maps\mp\gametypes_zm\_globallogic::updateteamstatus();
    pixbeginevent( "spawnPlayer_postUTS" );
    self thread stoppoisoningandflareonspawn();
    self stopburning();
/#
    assert( maps\mp\gametypes_zm\_globallogic_utils::isvalidclass( self.class ) );
#/
    self giveloadoutlevelspecific( self.team, self.class );

    if ( level.inprematchperiod )
    {
        self freeze_player_controls( 1 );
        team = self.pers["team"];

        if ( isdefined( self.pers["music"].spawn ) && self.pers["music"].spawn == 0 )
        {
            if ( level.wagermatch )
                music = "SPAWN_WAGER";
            else
                music = game["music"]["spawn_" + team];

            self thread maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( music, 0, 0 );
            self.pers["music"].spawn = 1;
        }

        if ( level.splitscreen )
        {
            if ( isdefined( level.playedstartingmusic ) )
                music = undefined;
            else
                level.playedstartingmusic = 1;
        }

        if ( !isdefined( level.disableprematchmessages ) || level.disableprematchmessages == 0 )
        {
            thread maps\mp\gametypes_zm\_hud_message::showinitialfactionpopup( team );
            hintmessage = getobjectivehinttext( self.pers["team"] );

            if ( isdefined( hintmessage ) )
                self thread maps\mp\gametypes_zm\_hud_message::hintmessage( hintmessage );

            if ( isdefined( game["dialog"]["gametype"] ) && ( !level.splitscreen || self == level.players[0] ) )
            {
                if ( !isdefined( level.infinalfight ) || !level.infinalfight )
                {
                    if ( level.hardcoremode )
                        self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "gametype_hardcore" );
                    else
                        self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "gametype" );
                }
            }

            if ( team == game["attackers"] )
                self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "offense_obj", "introboost" );
            else
                self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "defense_obj", "introboost" );
        }
    }
    else
    {
        self freeze_player_controls( 0 );
        self enableweapons();

        if ( !hadspawned && game["state"] == "playing" )
        {
            pixbeginevent( "sound" );
            team = self.team;

            if ( isdefined( self.pers["music"].spawn ) && self.pers["music"].spawn == 0 )
            {
                self thread maps\mp\gametypes_zm\_globallogic_audio::set_music_on_player( "SPAWN_SHORT", 0, 0 );
                self.pers["music"].spawn = 1;
            }

            if ( level.splitscreen )
            {
                if ( isdefined( level.playedstartingmusic ) )
                    music = undefined;
                else
                    level.playedstartingmusic = 1;
            }

            if ( !isdefined( level.disableprematchmessages ) || level.disableprematchmessages == 0 )
            {
                thread maps\mp\gametypes_zm\_hud_message::showinitialfactionpopup( team );
                hintmessage = getobjectivehinttext( self.pers["team"] );

                if ( isdefined( hintmessage ) )
                    self thread maps\mp\gametypes_zm\_hud_message::hintmessage( hintmessage );

                if ( isdefined( game["dialog"]["gametype"] ) && ( !level.splitscreen || self == level.players[0] ) )
                {
                    if ( !isdefined( level.infinalfight ) || !level.infinalfight )
                    {
                        if ( level.hardcoremode )
                            self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "gametype_hardcore" );
                        else
                            self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "gametype" );
                    }
                }

                if ( team == game["attackers"] )
                    self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "offense_obj", "introboost" );
                else
                    self maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "defense_obj", "introboost" );
            }

            pixendevent();
        }
    }

    if ( getdvar( "scr_showperksonspawn" ) == "" )
        setdvar( "scr_showperksonspawn", "0" );

    if ( level.hardcoremode )
        setdvar( "scr_showperksonspawn", "0" );

    if ( !level.splitscreen && getdvarint( "scr_showperksonspawn" ) == 1 && game["state"] != "postgame" )
    {
        pixbeginevent( "showperksonspawn" );

        if ( level.perksenabled == 1 )
            self maps\mp\gametypes_zm\_hud_util::showperks();

        self thread maps\mp\gametypes_zm\_globallogic_ui::hideloadoutaftertime( 3.0 );
        self thread maps\mp\gametypes_zm\_globallogic_ui::hideloadoutondeath();
        pixendevent();
    }

    if ( isdefined( self.pers["momentum"] ) )
        self.momentum = self.pers["momentum"];

    pixendevent();
    waittillframeend;
    self notify( "spawned_player" );
    self logstring( "S " + self.origin[0] + " " + self.origin[1] + " " + self.origin[2] );
    setdvar( "scr_selecting_location", "" );
/#
    if ( getdvarint( _hash_F8D00F60 ) > 0 )
        self thread maps\mp\gametypes_zm\_globallogic_score::xpratethread();
#/
    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );

    if ( game["state"] == "postgame" )
    {
/#
        assert( !level.intermission );
#/
        self maps\mp\gametypes_zm\_globallogic_player::freezeplayerforroundend();
    }
}

spawnspectator( origin, angles )
{
    self notify( "spawned" );
    self notify( "end_respawn" );
    in_spawnspectator( origin, angles );
}

respawn_asspectator( origin, angles )
{
    in_spawnspectator( origin, angles );
}

in_spawnspectator( origin, angles )
{
    pixmarker( "BEGIN: in_spawnSpectator" );
    self setspawnvariables();

    if ( self.pers["team"] == "spectator" )
        self clearlowermessage();

    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    self.friendlydamage = undefined;

    if ( self.pers["team"] == "spectator" )
        self.statusicon = "";
    else
        self.statusicon = "hud_status_dead";

    maps\mp\gametypes_zm\_spectating::setspectatepermissionsformachine();
    [[ level.onspawnspectator ]]( origin, angles );

    if ( level.teambased && !level.splitscreen )
        self thread spectatorthirdpersonness();

    level thread maps\mp\gametypes_zm\_globallogic::updateteamstatus();
    pixmarker( "END: in_spawnSpectator" );
}

spectatorthirdpersonness()
{
    self endon( "disconnect" );
    self endon( "spawned" );
    self notify( "spectator_thirdperson_thread" );
    self endon( "spectator_thirdperson_thread" );
    self.spectatingthirdperson = 0;
}

forcespawn( time )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "spawned" );

    if ( !isdefined( time ) )
        time = 60;

    wait( time );

    if ( self.hasspawned )
        return;

    if ( self.pers["team"] == "spectator" )
        return;

    if ( !maps\mp\gametypes_zm\_globallogic_utils::isvalidclass( self.pers["class"] ) )
    {
        self.pers["class"] = "CLASS_CUSTOM1";
        self.class = self.pers["class"];
    }

    self maps\mp\gametypes_zm\_globallogic_ui::closemenus();
    self thread [[ level.spawnclient ]]();
}

kickifdontspawn()
{
/#
    if ( getdvarint( "scr_hostmigrationtest" ) == 1 )
        return;
#/
    if ( self ishost() )
        return;

    self kickifidontspawninternal();
}

kickifidontspawninternal()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "spawned" );
    waittime = 90;

    if ( getdvar( _hash_4257CF5C ) != "" )
        waittime = getdvarfloat( _hash_4257CF5C );

    mintime = 45;

    if ( getdvar( _hash_DF057E0 ) != "" )
        mintime = getdvarfloat( _hash_DF057E0 );

    starttime = gettime();
    kickwait( waittime );
    timepassed = ( gettime() - starttime ) / 1000;

    if ( timepassed < waittime - 0.1 && timepassed < mintime )
        return;

    if ( self.hasspawned )
        return;

    if ( sessionmodeisprivate() )
        return;

    if ( self.pers["team"] == "spectator" )
        return;

    kick( self getentitynumber() );
}

kickwait( waittime )
{
    level endon( "game_ended" );
    maps\mp\gametypes_zm\_hostmigration::waitlongdurationwithhostmigrationpause( waittime );
}

spawninterroundintermission()
{
    self notify( "spawned" );
    self notify( "end_respawn" );
    self setspawnvariables();
    self clearlowermessage();
    self freeze_player_controls( 0 );
    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    self.friendlydamage = undefined;
    self maps\mp\gametypes_zm\_globallogic_defaults::default_onspawnintermission();
    self setorigin( self.origin );
    self setplayerangles( self.angles );
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

spawnintermission( usedefaultcallback )
{
    self notify( "spawned" );
    self notify( "end_respawn" );
    self endon( "disconnect" );
    self setspawnvariables();
    self clearlowermessage();
    self freeze_player_controls( 0 );

    if ( level.rankedmatch && waslastround() )
    {
        if ( self.postgamemilestones || self.postgamecontracts || self.postgamepromotion )
        {
            if ( self.postgamepromotion )
                self playlocalsound( "mus_level_up" );
            else if ( self.postgamecontracts )
                self playlocalsound( "mus_challenge_complete" );
            else if ( self.postgamemilestones )
                self playlocalsound( "mus_contract_complete" );

            self closeingamemenu();
            self openmenu( game["menu_endgameupdate"] );
            waittime = 4.0;

            while ( waittime )
            {
                wait 0.25;
                waittime -= 0.25;
                self openmenu( game["menu_endgameupdate"] );
            }

            self closemenu();
        }
    }

    self.sessionstate = "intermission";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    self.friendlydamage = undefined;

    if ( isdefined( usedefaultcallback ) && usedefaultcallback )
        maps\mp\gametypes_zm\_globallogic_defaults::default_onspawnintermission();
    else
        [[ level.onspawnintermission ]]();

    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

spawnqueuedclientonteam( team )
{
    player_to_spawn = undefined;

    for ( i = 0; i < level.deadplayers[team].size; i++ )
    {
        player = level.deadplayers[team][i];

        if ( player.waitingtospawn )
            continue;

        player_to_spawn = player;
        break;
    }

    if ( isdefined( player_to_spawn ) )
    {
        player_to_spawn.allowqueuespawn = 1;
        player_to_spawn maps\mp\gametypes_zm\_globallogic_ui::closemenus();
        player_to_spawn thread [[ level.spawnclient ]]();
    }
}

spawnqueuedclient( dead_player_team, killer )
{
    if ( !level.playerqueuedrespawn )
        return;

    maps\mp\gametypes_zm\_globallogic_utils::waittillslowprocessallowed();
    spawn_team = undefined;

    if ( isdefined( killer ) && isdefined( killer.team ) && isdefined( level.teams[killer.team] ) )
        spawn_team = killer.team;

    if ( isdefined( spawn_team ) )
    {
        spawnqueuedclientonteam( spawn_team );
        return;
    }

    foreach ( team in level.teams )
    {
        if ( team == dead_player_team )
            continue;

        spawnqueuedclientonteam( team );
    }
}

allteamsnearscorelimit()
{
    if ( !level.teambased )
        return false;

    if ( level.scorelimit <= 1 )
        return false;

    foreach ( team in level.teams )
    {
        if ( !( game["teamScores"][team] >= level.scorelimit - 1 ) )
            return false;
    }

    return true;
}

shouldshowrespawnmessage()
{
    if ( waslastround() )
        return false;

    if ( isoneround() )
        return false;

    if ( isdefined( level.livesdonotreset ) && level.livesdonotreset )
        return false;

    if ( allteamsnearscorelimit() )
        return false;

    return true;
}

default_spawnmessage()
{
    setlowermessage( game["strings"]["spawn_next_round"] );
    self thread maps\mp\gametypes_zm\_globallogic_ui::removespawnmessageshortly( 3 );
}

showspawnmessage()
{
    if ( shouldshowrespawnmessage() )
        self thread [[ level.spawnmessage ]]();
}

spawnclient( timealreadypassed )
{
    pixbeginevent( "spawnClient" );
/#
    assert( isdefined( self.team ) );
#/
/#
    assert( maps\mp\gametypes_zm\_globallogic_utils::isvalidclass( self.class ) );
#/
    if ( !self mayspawn() )
    {
        currentorigin = self.origin;
        currentangles = self.angles;
        self showspawnmessage();
        self thread [[ level.spawnspectator ]]( currentorigin + vectorscale( ( 0, 0, 1 ), 60.0 ), currentangles );
        pixendevent();
        return;
    }

    if ( self.waitingtospawn )
    {
        pixendevent();
        return;
    }

    self.waitingtospawn = 1;
    self.allowqueuespawn = undefined;
    self waitandspawnclient( timealreadypassed );

    if ( isdefined( self ) )
        self.waitingtospawn = 0;

    pixendevent();
}

waitandspawnclient( timealreadypassed )
{
    self endon( "disconnect" );
    self endon( "end_respawn" );
    level endon( "game_ended" );

    if ( !isdefined( timealreadypassed ) )
        timealreadypassed = 0;

    spawnedasspectator = 0;

    if ( isdefined( self.teamkillpunish ) && self.teamkillpunish )
    {
        teamkilldelay = maps\mp\gametypes_zm\_globallogic_player::teamkilldelay();

        if ( teamkilldelay > timealreadypassed )
        {
            teamkilldelay -= timealreadypassed;
            timealreadypassed = 0;
        }
        else
        {
            timealreadypassed -= teamkilldelay;
            teamkilldelay = 0;
        }

        if ( teamkilldelay > 0 )
        {
            setlowermessage( &"MP_FRIENDLY_FIRE_WILL_NOT", teamkilldelay );
            self thread respawn_asspectator( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), self.angles );
            spawnedasspectator = 1;
            wait( teamkilldelay );
        }

        self.teamkillpunish = 0;
    }

    if ( !isdefined( self.wavespawnindex ) && isdefined( level.waveplayerspawnindex[self.team] ) )
    {
        self.wavespawnindex = level.waveplayerspawnindex[self.team];
        level.waveplayerspawnindex[self.team]++;
    }

    timeuntilspawn = timeuntilspawn( 0 );

    if ( timeuntilspawn > timealreadypassed )
    {
        timeuntilspawn -= timealreadypassed;
        timealreadypassed = 0;
    }
    else
    {
        timealreadypassed -= timeuntilspawn;
        timeuntilspawn = 0;
    }

    if ( timeuntilspawn > 0 )
    {
        if ( level.playerqueuedrespawn )
            setlowermessage( game["strings"]["you_will_spawn"], timeuntilspawn );
        else if ( self issplitscreen() )
            setlowermessage( game["strings"]["waiting_to_spawn_ss"], timeuntilspawn, 1 );
        else
            setlowermessage( game["strings"]["waiting_to_spawn"], timeuntilspawn );

        if ( !spawnedasspectator )
        {
            spawnorigin = self.origin + vectorscale( ( 0, 0, 1 ), 60.0 );
            spawnangles = self.angles;

            if ( isdefined( level.useintermissionpointsonwavespawn ) && [[ level.useintermissionpointsonwavespawn ]]() == 1 )
            {
                spawnpoint = maps\mp\gametypes_zm\_spawnlogic::getrandomintermissionpoint();

                if ( isdefined( spawnpoint ) )
                {
                    spawnorigin = spawnpoint.origin;
                    spawnangles = spawnpoint.angles;
                }
            }

            self thread respawn_asspectator( spawnorigin, spawnangles );
        }

        spawnedasspectator = 1;
        self maps\mp\gametypes_zm\_globallogic_utils::waitfortimeornotify( timeuntilspawn, "force_spawn" );
        self notify( "stop_wait_safe_spawn_button" );
    }

    wavebased = level.waverespawndelay > 0;

    if ( !level.playerforcerespawn && self.hasspawned && !wavebased && !self.wantsafespawn && !level.playerqueuedrespawn )
    {
        setlowermessage( game["strings"]["press_to_spawn"] );

        if ( !spawnedasspectator )
            self thread respawn_asspectator( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), self.angles );

        spawnedasspectator = 1;
        self waitrespawnorsafespawnbutton();
    }

    self.waitingtospawn = 0;
    self clearlowermessage();
    self.wavespawnindex = undefined;
    self.respawntimerstarttime = undefined;
    self thread [[ level.spawnplayer ]]();
}

waitrespawnorsafespawnbutton()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );

    while ( true )
    {
        if ( self usebuttonpressed() )
            break;

        wait 0.05;
    }
}

waitinspawnqueue()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );

    if ( !level.ingraceperiod && !level.usestartspawns )
    {
        currentorigin = self.origin;
        currentangles = self.angles;
        self thread [[ level.spawnspectator ]]( currentorigin + vectorscale( ( 0, 0, 1 ), 60.0 ), currentangles );

        self waittill( "queue_respawn" );
    }
}

setthirdperson( value )
{
    if ( !level.console )
        return;

    if ( !isdefined( self.spectatingthirdperson ) || value != self.spectatingthirdperson )
    {
        self.spectatingthirdperson = value;

        if ( value )
        {
            self setclientthirdperson( 1 );
            self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
        }
        else
        {
            self setclientthirdperson( 0 );
            self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
        }

        self resetfov();
    }
}

setspawnvariables()
{
    resettimeout();
    self stopshellshock();
    self stoprumble( "damage_heavy" );
}
