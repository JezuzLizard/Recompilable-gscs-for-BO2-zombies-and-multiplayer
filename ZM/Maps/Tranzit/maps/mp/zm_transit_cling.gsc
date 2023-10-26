// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

initializecling()
{
    setupclingtrigger();
}

setupclingtrigger()
{
    if ( !isdefined( level.the_bus ) )
        return;

    enablecling();
    triggers = [];
    level.cling_triggers = [];
    triggers = getentarray( "cling_trigger", "script_noteworthy" );

    for ( i = 0; i < triggers.size; i++ )
    {
        level.cling_triggers[i] = spawnstruct();
        level.cling_triggers[i].trigger = triggers[i];
        trigger = level.cling_triggers[i].trigger;
        trigger sethintstring( "Hold [{+activate}] To Cling To The Bus." );
        trigger setcursorhint( "HINT_NOICON" );
        makevisibletoall( trigger );
        trigger enablelinkto();
        trigger linkto( level.the_bus, "", level.the_bus worldtolocalcoords( trigger.origin ), trigger.angles - level.the_bus.angles );
        trigger thread setclingtriggervisibility( i );
        trigger thread clingtriggerusethink( i );
        level.cling_triggers[i].position = getent( trigger.target, "targetname" );
        position = level.cling_triggers[i].position;
        position linkto( level.the_bus, "", level.the_bus worldtolocalcoords( position.origin ), position.angles - level.the_bus.angles );
        level.cling_triggers[i].player = undefined;
    }

    disablecling();
}

enablecling()
{
    level.cling_enabled = 1;

    if ( isdefined( level.cling_triggers ) )
    {
        foreach ( struct in level.cling_triggers )
        {
            struct.trigger sethintstring( "Hold [{+activate}] To Cling To The Bus." );
            struct.trigger setteamfortrigger( "allies" );
        }
    }
}

disablecling()
{
    level.cling_enabled = 0;
    detachallplayersfromclinging();

    if ( isdefined( level.cling_triggers ) )
    {
        foreach ( struct in level.cling_triggers )
        {
            struct.trigger sethintstring( "" );
            struct.trigger setteamfortrigger( "none" );
        }
    }
}

makevisibletoall( trigger )
{
    players = get_players();

    for ( playerindex = 0; playerindex < players.size; playerindex++ )
        trigger setinvisibletoplayer( players[playerindex], 0 );
}

clingtriggerusethink( positionindex )
{
    while ( true )
    {
        self waittill( "trigger", who );

        if ( !level.cling_enabled )
            continue;

        if ( !who usebuttonpressed() )
            continue;

        if ( who in_revive_trigger() )
            continue;

        if ( isdefined( who.is_drinking ) && who.is_drinking == 1 )
            continue;

        if ( isdefined( level.cling_triggers[positionindex].player ) )
        {
            if ( level.cling_triggers[positionindex].player == who )
                dettachplayerfrombus( who, positionindex );

            continue;
        }

        attachplayertobus( who, positionindex );
        thread detachfrombusonevent( who, positionindex );
    }
}

setclingtriggervisibility( positionindex )
{
    while ( true )
    {
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            is_player_clinging = isdefined( level.cling_triggers[positionindex].player ) && level.cling_triggers[positionindex].player == players[i];
            no_player_clinging = !isdefined( level.cling_triggers[positionindex].player );

            if ( is_player_clinging || no_player_clinging && level.cling_enabled )
            {
                self setinvisibletoplayer( players[i], 0 );
                continue;
            }

            self setinvisibletoplayer( players[i], 1 );
        }

        wait 0.1;
    }
}

detachallplayersfromclinging()
{
    for ( positionindex = 0; positionindex < level.cling_triggers.size; positionindex++ )
    {
        if ( !isdefined( level.cling_triggers[positionindex] ) || !isdefined( level.cling_triggers[positionindex].player ) )
            continue;

        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( level.cling_triggers[positionindex].player == players[i] )
            {
                dettachplayerfrombus( players[i], positionindex );
                break;
            }
        }
    }
}

attachplayertobus( player, positionindex )
{
    turn_angle = 130;
    pitch_up = 25;

    if ( positionisupgraded( positionindex ) )
    {
        turn_angle = 180;
        pitch_up = 120;
    }

    level.cling_triggers[positionindex].player = player;

    if ( positionisbl( positionindex ) )
        player playerlinktodelta( level.cling_triggers[positionindex].position, "tag_origin", 1, 180, turn_angle, pitch_up, 120, 1 );
    else if ( positionisbr( positionindex ) )
        player playerlinktodelta( level.cling_triggers[positionindex].position, "tag_origin", 1, turn_angle, 180, pitch_up, 120, 1 );
    else
    {
        level.cling_triggers[positionindex].player = undefined;
        return;
    }

    level.cling_triggers[positionindex].trigger sethintstring( "Hold [{+activate}] To Let Go Of The Bus." );
    player disableplayerweapons( positionindex );
}

positionisbl( positionindex )
{
    return level.cling_triggers[positionindex].position.script_string == "back_left";
}

positionisbr( positionindex )
{
    return level.cling_triggers[positionindex].position.script_string == "back_right";
}

positionisupgraded( positionindex )
{
    return positionisbl( positionindex ) && isdefined( level.the_bus.upgrades["PlatformL"] ) && level.the_bus.upgrades["PlatformL"].installed || positionisbr( positionindex ) && isdefined( level.the_bus.upgrades["PlatformR"] ) && level.the_bus.upgrades["PlatformR"].installed;
}

dettachplayerfrombus( player, positionindex )
{
    level.cling_triggers[positionindex].trigger sethintstring( "Hold [{+activate}] To Cling To The Bus." );

    if ( !isdefined( level.cling_triggers[positionindex].player ) )
        return;

    player unlink();
    level.cling_triggers[positionindex].player = undefined;
    player enableplayerweapons( positionindex );
    player notify( "cling_dettached" );
}

detachfrombusonevent( player, positionindex )
{
    player endon( "cling_dettached" );
    player waittill_any( "fake_death", "death", "player_downed" );
    dettachplayerfrombus( player, positionindex );
}

disableplayerweapons( positionindex )
{
    weaponinventory = self getweaponslist( 1 );
    self.lastactiveweapon = self getcurrentweapon();
    self.clingpistol = undefined;
    self.hadclingpistol = 0;

    if ( !positionisupgraded( positionindex ) )
    {
        for ( i = 0; i < weaponinventory.size; i++ )
        {
            weapon = weaponinventory[i];

            if ( weaponclass( weapon ) == "pistol" && ( !isdefined( self.clingpistol ) || weapon == self.lastactiveweapon || self.clingpistol == "m1911_zm" ) )
            {
                self.clingpistol = weapon;
                self.hadclingpistol = 1;
            }
        }

        if ( !isdefined( self.clingpistol ) )
        {
            self giveweapon( "m1911_zm" );
            self.clingpistol = "m1911_zm";
        }

        self switchtoweapon( self.clingpistol );
        self disableweaponcycling();
        self disableoffhandweapons();
        self allowcrouch( 0 );
    }

    self allowlean( 0 );
    self allowsprint( 0 );
    self allowprone( 0 );
}

enableplayerweapons( positionindex )
{
    self allowlean( 1 );
    self allowsprint( 1 );
    self allowprone( 1 );

    if ( !positionisupgraded( positionindex ) )
    {
        if ( !self.hadclingpistol )
            self takeweapon( "m1911_zm" );

        self enableweaponcycling();
        self enableoffhandweapons();
        self allowcrouch( 1 );

        if ( self.lastactiveweapon != "none" && self.lastactiveweapon != "mortar_round" && self.lastactiveweapon != "mine_bouncing_betty" && self.lastactiveweapon != "claymore_zm" )
            self switchtoweapon( self.lastactiveweapon );
        else
        {
            primaryweapons = self getweaponslistprimaries();

            if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
                self switchtoweapon( primaryweapons[0] );
        }
    }
}

playerisclingingtobus()
{
    if ( !isdefined( level.cling_triggers ) )
        return false;

    for ( i = 0; i < level.cling_triggers.size; i++ )
    {
        if ( !isdefined( level.cling_triggers[i] ) || !isdefined( level.cling_triggers[i].player ) )
            continue;

        if ( level.cling_triggers[i].player == self )
            return true;
    }

    return false;
}

_getnumplayersclinging()
{
    num_clinging = 0;

    for ( i = 0; i < level.cling_triggers.size; i++ )
    {
        if ( isdefined( level.cling_triggers[i] ) && isdefined( level.cling_triggers[i].player ) )
            num_clinging++;
    }

    return num_clinging;
}

_getbusattackposition( player )
{
    pos = ( -208, 0, 48 );
    return level.the_bus localtoworldcoords( pos );
}
