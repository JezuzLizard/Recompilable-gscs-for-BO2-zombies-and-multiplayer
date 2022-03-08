// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_treadfx;
#include maps\mp\gametypes\_tweakables;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\gametypes\_spawning;
#include maps\mp\_scoreevents;
#include maps\mp\_flashgrenades;
#include maps\mp\gametypes\_globallogic_utils;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_popups;
#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hostmigration;
#include maps\mp\killstreaks\_emp;
#include maps\mp\gametypes\_shellshock;
#include maps\mp\_challenges;

init()
{
    precachemodel( "veh_t6_drone_rcxd" );
    precachemodel( "veh_t6_drone_rcxd_alt" );
    precachevehicle( "rc_car_medium_mp" );
    precacherumble( "rcbomb_engine_stutter" );
    precacherumble( "rcbomb_slide" );
    loadtreadfx( "dust" );
    loadtreadfx( "concrete" );
    loadfx( "weapon/grenade/fx_spark_disabled_rc_car" );
    loadfx( "vehicle/light/fx_rcbomb_blinky_light" );
    loadfx( "vehicle/light/fx_rcbomb_solid_light" );
    loadfx( "vehicle/light/fx_rcbomb_light_green_os" );
    loadfx( "vehicle/light/fx_rcbomb_light_red_os" );
    maps\mp\_treadfx::preloadtreadfx( "rc_car_medium_mp" );
    level._effect["rcbombexplosion"] = loadfx( "maps/mp_maps/fx_mp_exp_rc_bomb" );
    car_size = getdvar( "scr_rcbomb_car_size" );

    if ( car_size == "" )
        setdvar( "scr_rcbomb_car_size", "1" );

    setdvar( "scr_rcbomb_notimeout", 0 );

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "killstreak", "allowrcbomb" ) )
    {
        maps\mp\killstreaks\_killstreaks::registerkillstreak( "rcbomb_mp", "rcbomb_mp", "killstreak_rcbomb", "rcbomb_used", ::usekillstreakrcbomb );
        maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "rcbomb_mp", &"KILLSTREAK_EARNED_RCBOMB", &"KILLSTREAK_RCBOMB_NOT_AVAILABLE", &"KILLSTREAK_RCBOMB_INBOUND" );
        maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "rcbomb_mp", "mpl_killstreak_rcbomb", "kls_rcbomb_used", "", "kls_rcbomb_enemy", "", "kls_rcbomb_ready" );
        maps\mp\killstreaks\_killstreaks::registerkillstreakdevdvar( "rcbomb_mp", "scr_givercbomb" );
        maps\mp\killstreaks\_killstreaks::allowkillstreakassists( "rcbomb_mp", 1 );
    }
}

register()
{
    registerclientfield( "vehicle", "rcbomb_death", 1, 1, "int" );
    registerclientfield( "vehicle", "rcbomb_countdown", 1, 2, "int" );
}

loadtreadfx( type )
{
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type );
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type + "_drift" );
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type + "_peel" );
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type + "_first_person" );
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type + "_reverse" );
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type + "_trail" );
    loadfx( "vehicle/treadfx/fx_treadfx_rcbomb_" + type + "_slow" );
}

usekillstreakrcbomb( hardpointtype )
{
    if ( self maps\mp\killstreaks\_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
        return 0;

    if ( !self isonground() || self isusingremote() )
    {
        self iprintlnbold( &"KILLSTREAK_RCBOMB_NOT_PLACEABLE" );
        return 0;
    }

    placement = self.rcbombplacement;

    if ( !isdefined( placement ) )
        placement = getrcbombplacement();

    if ( !isdefined( placement ) )
    {
        self iprintlnbold( &"KILLSTREAK_RCBOMB_NOT_PLACEABLE" );
        return 0;
    }

    if ( maps\mp\killstreaks\_killstreaks::isinteractingwithobject() )
    {
        self iprintlnbold( &"KILLSTREAK_RCBOMB_NOT_PLACEABLE" );
        return 0;
    }

    self setusingremote( "rcbomb" );
    self freezecontrolswrapper( 1 );
    result = self maps\mp\killstreaks\_killstreaks::initridekillstreak( "rcbomb" );

    if ( result != "success" )
    {
        if ( result != "disconnect" )
            self clearusingremote();

        return 0;
    }

    if ( level.gameended )
        return 0;

    ret = self usercbomb( placement );

    if ( !isdefined( ret ) && level.gameended )
        ret = 1;
    else if ( !isdefined( ret ) )
        ret = 0;

    if ( isdefined( self ) )
        self clearusingremote();

    return ret;
}

spawnrcbomb( placement, team )
{
    car_size = getdvar( "scr_rcbomb_car_size" );
    model = "veh_t6_drone_rcxd";
    enemymodel = "veh_t6_drone_rcxd_alt";
    death_model = "veh_t6_drone_rcxd";
    car = "rc_car_medium_mp";
    vehicle = spawnvehicle( model, "rcbomb", car, placement.origin, placement.angles );
    vehicle makevehicleunusable();
    vehicle.death_model = death_model;
    vehicle.allowfriendlyfiredamageoverride = ::rccarallowfriendlyfiredamage;
    vehicle setenemymodel( enemymodel );
    vehicle enableaimassist();
    vehicle setowner( self );
    vehicle setvehicleteam( team );
    vehicle.team = team;
    vehicle setdrawinfrared( 1 );
    maps\mp\_treadfx::loadtreadfx( vehicle );
    vehicle maps\mp\gametypes\_spawning::create_rcbomb_influencers( team );
    return vehicle;
}

getrcbombplacement()
{
    return calculatespawnorigin( self.origin, self.angles );
}

giveplayercontrolofrcbomb()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self thread maps\mp\killstreaks\_killstreaks::playkillstreakstartdialog( "rcbomb_mp", self.team );
    level.globalkillstreakscalled++;
    self addweaponstat( "rcbomb_mp", "used", 1 );
    xpamount = maps\mp\killstreaks\_killstreaks::getxpamountforkillstreak( "rcbomb_mp" );

    if ( maps\mp\_scoreevents::shouldaddrankxp( self ) )
        self addrankxpvalue( "killstreakCalledIn", xpamount );

    self freeze_player_controls( 0 );
    self.rcbomb usevehicle( self, 0 );
    self thread playerdisconnectwaiter( self.rcbomb );
    self thread cardetonatewaiter( self.rcbomb );
    self thread exitcarwaiter( self.rcbomb );
    self thread gameendwatcher( self.rcbomb );
    self thread changeteamwaiter( self.rcbomb );
    self.rcbomb thread maps\mp\_flashgrenades::monitorrcbombflash();
    self thread cartimer( self.rcbomb );

    self waittill( "rcbomb_done" );
}

usercbomb( placement )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    hardpointtype = "rcbomb_mp";
    maps\mp\gametypes\_globallogic_utils::waittillslowprocessallowed();

    if ( !isdefined( self ) || !isalive( self ) || self isremotecontrolling() || self maps\mp\killstreaks\_killstreaks::isinteractingwithobject() )
    {
        self iprintlnbold( &"KILLSTREAK_RCBOMB_NOT_PLACEABLE" );
        return false;
    }

    if ( !isdefined( self.rcbomb ) )
    {
        self.rcbomb = self spawnrcbomb( placement, self.team );
        self.rcbomb thread carcleanupwaiter( self.rcbomb );
        self.rcbomb thread trigger_hurt_monitor();
        self.rcbomb.team = self.team;

        if ( !isdefined( self.rcbomb ) )
            return false;

        self maps\mp\gametypes\_weaponobjects::addweaponobjecttowatcher( "rcbomb", self.rcbomb );
    }

    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( hardpointtype, self.team, undefined, 0 );

    if ( killstreak_id == -1 )
    {
        if ( isdefined( self.rcbomb ) )
            self.rcbomb delete();

        return false;
    }

    self.rcbomb.killstreak_id = killstreak_id;
    self.enteringvehicle = 1;
    self thread updatekillstreakondisconnect();
    self thread updatekillstreakondeletion( self.team );
    self freeze_player_controls( 1 );

    if ( !isdefined( self ) || !isalive( self ) || !isdefined( self.rcbomb ) )
    {
        if ( isdefined( self ) )
        {
            self.enteringvehicle = 0;
            self notify( "weapon_object_destroyed" );
        }

        return false;
    }

    self thread giveplayercontrolofrcbomb();
    self.rcbomb thread watchforscramblers();
    self.killstreak_waitamount = 30000;
    self.enteringvehicle = 0;
    self stopshellshock();

    if ( isdefined( level.killstreaks[hardpointtype] ) && isdefined( level.killstreaks[hardpointtype].inboundtext ) )
        level thread maps\mp\_popups::displaykillstreakteammessagetoall( hardpointtype, self );

    if ( isdefined( level.rcbomb_vision ) )
        self thread setvisionsetwaiter();

    self updaterulesonend();
    return true;
}

watchforscramblers()
{
    self endon( "death" );

    while ( true )
    {
        scrambled = self getclientflag( 9 );
        shouldscramble = 0;
        players = level.players;

        for ( i = 0; i < players.size; i++ )
        {
            if ( !isdefined( players[i] ) || !isdefined( players[i].scrambler ) )
                continue;

            player = players[i];
            scrambler = player.scrambler;

            if ( level.teambased && self.team == player.team )
                continue;

            if ( !level.teambased && self.owner == player )
                continue;

            if ( distancesquared( scrambler.origin, self.origin ) < level.scramblerinnerradiussq )
            {
                shouldscramble = 1;
                break;
            }
        }

        if ( shouldscramble == 1 && scrambled == 0 )
            self setclientflag( 9 );
        else if ( shouldscramble == 0 && scrambled == 1 )
            self clearclientflag( 9 );

        wait_delay = randomfloatrange( 0.25, 0.5 );
        wait( wait_delay );
    }
}

updaterulesonend()
{
    team = self.rcbomb.team;
    killstreak_id = self.rcbomb.killstreak_id;
    self endon( "disconnect" );

    self waittill( "rcbomb_done" );

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "rcbomb_mp", team, killstreak_id );
}

updatekillstreakondisconnect()
{
    team = self.rcbomb.team;
    killstreak_id = self.rcbomb.killstreak_id;
    self endon( "rcbomb_done" );

    self waittill( "disconnect" );

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "rcbomb_mp", team, killstreak_id );
}

updatekillstreakondeletion( team )
{
    killstreak_id = self.rcbomb.killstreak_id;
    self endon( "disconnect" );
    self endon( "rcbomb_done" );

    self waittill( "weapon_object_destroyed" );

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "rcbomb_mp", team, killstreak_id );

    if ( isdefined( self.rcbomb ) )
        self.rcbomb delete();
}

cardetonatewaiter( vehicle )
{
    self endon( "disconnect" );
    vehicle endon( "death" );
    watcher = maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "rcbomb" );

    while ( !self attackbuttonpressed() )
        wait 0.05;

    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( vehicle, 0 );
    self thread maps\mp\gametypes\_hud::fadetoblackforxsec( getdvarfloat( _hash_CDE26736 ), getdvarfloat( _hash_AFCAD5CD ), getdvarfloat( _hash_88490433 ), getdvarfloat( _hash_A925AA4E ) );
}

jumpwaiter( vehicle )
{
    self endon( "disconnect" );
    vehicle endon( "death" );
    self.jump_hud = newclienthudelem( self );
    self.jump_hud.alignx = "left";
    self.jump_hud.aligny = "bottom";
    self.jump_hud.horzalign = "user_left";
    self.jump_hud.vertalign = "user_bottom";
    self.jump_hud.font = "small";
    self.jump_hud.hidewheninmenu = 1;
    self.jump_hud.x = 5;
    self.jump_hud.y = -60;
    self.jump_hud.fontscale = 1.25;

    while ( true )
    {
        self.jump_hud settext( "[{+gostand}]" + "Jump" );

        if ( self jumpbuttonpressed() )
        {
            vehicle launchvehicle( ( 0, 0, -1 ) * -10, vehicle.origin, 0 );
            self.jump_hud settext( "" );
            wait 5;
        }

        wait 0.05;
    }
}

playerdisconnectwaiter( vehicle )
{
    vehicle endon( "death" );
    self endon( "rcbomb_done" );

    self waittill( "disconnect" );

    vehicle delete();
}

gameendwatcher( vehicle )
{
    vehicle endon( "death" );
    self endon( "rcbomb_done" );

    level waittill( "game_ended" );

    watcher = maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "rcbomb" );
    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( vehicle, 0 );
    self thread maps\mp\gametypes\_hud::fadetoblackforxsec( getdvarfloat( _hash_CDE26736 ), getdvarfloat( _hash_AFCAD5CD ), getdvarfloat( _hash_88490433 ), getdvarfloat( _hash_A925AA4E ) );
}

exitcarwaiter( vehicle )
{
    self endon( "disconnect" );

    self waittill( "unlink" );

    self notify( "rcbomb_done" );
}

changeteamwaiter( vehicle )
{
    self endon( "disconnect" );
    self endon( "rcbomb_done" );
    vehicle endon( "death" );
    self waittill_either( "joined_team", "joined_spectators" );
    vehicle.owner unlink();
    self.killstreak_waitamount = undefined;
    vehicle delete();
}

cardeathwaiter( vehicle )
{
    self endon( "disconnect" );
    self endon( "rcbomb_done" );

    self waittill( "death" );

    maps\mp\killstreaks\_killstreaks::removeusedkillstreak( "rcbomb_mp" );
    self notify( "rcbomb_done" );
}

carcleanupwaiter( vehicle )
{
    self endon( "disconnect" );

    self waittill( "death" );

    self.rcbomb = undefined;
}

setvisionsetwaiter()
{
    self endon( "disconnect" );
    self useservervisionset( 1 );
    self setvisionsetforplayer( level.rcbomb_vision, 1 );

    self waittill( "rcbomb_done" );

    self useservervisionset( 0 );
}

cartimer( vehicle )
{
    self endon( "disconnect" );
    vehicle endon( "death" );

    if ( !level.vehiclestimed )
        return;
/#
    if ( getdvarint( "scr_rcbomb_notimeout" ) != 0 )
        return;
#/
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( 20 );
    vehicle setclientfield( "rcbomb_countdown", 1 );
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( 6 );
    vehicle setclientfield( "rcbomb_countdown", 2 );
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( 4 );
    watcher = maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "rcbomb" );
    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( vehicle, 0 );
}

detonateiftouchingsphere( origin, radius )
{
    if ( distancesquared( self.origin, origin ) < radius * radius )
        self rcbomb_force_explode();
}

detonatealliftouchingsphere( origin, radius )
{
    rcbombs = getentarray( "rcbomb", "targetname" );

    for ( index = 0; index < rcbombs.size; index++ )
        rcbombs[index] detonateiftouchingsphere( origin, radius );
}

blowup( attacker, weaponname )
{
    self.owner endon( "disconnect" );
    self endon( "death" );
    explosionorigin = self.origin;
    explosionangles = self.angles;

    if ( !isdefined( attacker ) )
        attacker = self.owner;

    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );
    origin = self.origin + vectorscale( ( 0, 0, 1 ), 10.0 );
    radius = 256;
    min_damage = 25;
    max_damage = 350;

    if ( !from_emp )
    {
        self radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_EXPLOSIVE", "rcbomb_mp" );
        physicsexplosionsphere( origin, radius, radius, 1, max_damage, min_damage );
        maps\mp\gametypes\_shellshock::rcbomb_earthquake( origin );
        playsoundatposition( "mpl_rc_exp", self.origin );
        playfx( level._effect["rcbombexplosion"], explosionorigin, ( 0, 0, 1 ) );
    }

    self setmodel( self.death_model );
    self hide();
    self setclientfield( "rcbomb_death", 1 );

    if ( attacker != self.owner && isplayer( attacker ) )
    {
        attacker maps\mp\_challenges::destroyrcbomb( weaponname );

        if ( self.owner isenemyplayer( attacker ) )
        {
            maps\mp\_scoreevents::processscoreevent( "destroyed_rcbomb", attacker, self.owner, weaponname );

            if ( isdefined( weaponname ) )
            {
                weaponstatname = "destroyed";
                attacker addweaponstat( weaponname, weaponstatname, 1 );
                level.globalkillstreaksdestroyed++;
                attacker addweaponstat( "rcbomb_mp", "destroyed", 1 );
                attacker addweaponstat( weaponname, "destroyed_controlled_killstreak", 1 );
            }
        }
        else
        {

        }
    }

    wait 1;

    if ( isdefined( self.neverdelete ) && self.neverdelete )
        return;

    if ( isdefined( self.owner.jump_hud ) )
        self.owner.jump_hud destroy();

    self.owner unlink();

    if ( isdefined( level.gameended ) && level.gameended )
        self.owner freezecontrolswrapper( 1 );

    self.owner.killstreak_waitamount = undefined;
    self delete();
}

rccarallowfriendlyfiredamage( einflictor, eattacker, smeansofdeath, sweapon )
{
    if ( isdefined( eattacker ) && eattacker == self.owner )
        return true;

    if ( isdefined( einflictor ) && einflictor islinkedto( self ) )
        return true;

    return false;
}

getplacementstartheight()
{
    startheight = 50;

    switch ( self getstance() )
    {
        case "crouch":
            startheight = 30;
            break;
        case "prone":
            startheight = 15;
            break;
    }

    return startheight;
}

calculatespawnorigin( origin, angles )
{
    distance_from_player = 70;
    startheight = getplacementstartheight();
    mins = vectorscale( ( -1, -1, 0 ), 5.0 );
    maxs = ( 5, 5, 10 );
    startpoints = [];
    startangles = [];
    wheelcounts = [];
    testcheck = [];
    largestcount = 0;
    largestcountindex = 0;
    testangles = [];
    testangles[0] = ( 0, 0, 0 );
    testangles[1] = vectorscale( ( 0, 1, 0 ), 20.0 );
    testangles[2] = vectorscale( ( 0, -1, 0 ), 20.0 );
    testangles[3] = vectorscale( ( 0, 1, 0 ), 45.0 );
    testangles[4] = vectorscale( ( 0, -1, 0 ), 45.0 );
    heightoffset = 5;

    for ( i = 0; i < testangles.size; i++ )
    {
        testcheck[i] = 0;
        startangles[i] = ( 0, angles[1], 0 );
        startpoint = origin + vectorscale( anglestoforward( startangles[i] + testangles[i] ), distance_from_player );
        endpoint = startpoint - vectorscale( ( 0, 0, 1 ), 100.0 );
        startpoint += ( 0, 0, startheight );
        mask = level.physicstracemaskphysics | level.physicstracemaskvehicle;
        trace = physicstrace( startpoint, endpoint, mins, maxs, self, mask );

        if ( isdefined( trace["entity"] ) && isplayer( trace["entity"] ) )
        {
            wheelcounts[i] = 0;
            continue;
        }

        startpoints[i] = trace["position"] + ( 0, 0, heightoffset );
        wheelcounts[i] = testwheellocations( startpoints[i], startangles[i], heightoffset );

        if ( positionwouldtelefrag( startpoints[i] ) )
            continue;

        if ( largestcount < wheelcounts[i] )
        {
            largestcount = wheelcounts[i];
            largestcountindex = i;
        }

        if ( wheelcounts[i] >= 3 )
        {
            testcheck[i] = 1;

            if ( testspawnorigin( startpoints[i], startangles[i] ) )
            {
                placement = spawnstruct();
                placement.origin = startpoints[i];
                placement.angles = startangles[i];
                return placement;
            }
        }
    }

    for ( i = 0; i < testangles.size; i++ )
    {
        if ( !testcheck[i] )
        {
            if ( wheelcounts[i] >= 2 )
            {
                if ( testspawnorigin( startpoints[i], startangles[i] ) )
                {
                    placement = spawnstruct();
                    placement.origin = startpoints[i];
                    placement.angles = startangles[i];
                    return placement;
                }
            }
        }
    }

    return undefined;
}

testwheellocations( origin, angles, heightoffset )
{
    forward = 13;
    side = 10;
    wheels = [];
    wheels[0] = ( forward, side, 0 );
    wheels[1] = ( forward, -1 * side, 0 );
    wheels[2] = ( -1 * forward, -1 * side, 0 );
    wheels[3] = ( -1 * forward, side, 0 );
    height = 5;
    touchcount = 0;
    yawangles = ( 0, angles[1], 0 );

    for ( i = 0; i < 4; i++ )
    {
        wheel = rotatepoint( wheels[i], yawangles );
        startpoint = origin + wheel;
        endpoint = startpoint + ( 0, 0, -1 * height - heightoffset );
        startpoint += ( 0, 0, height - heightoffset );
        trace = bullettrace( startpoint, endpoint, 0, self );

        if ( trace["fraction"] < 1 )
        {
            touchcount++;
            rcbomb_debug_line( startpoint, endpoint, ( 1, 0, 0 ) );
            continue;
        }

        rcbomb_debug_line( startpoint, endpoint, ( 0, 0, 1 ) );
    }

    return touchcount;
}

testspawnorigin( origin, angles )
{
    liftedorigin = origin + vectorscale( ( 0, 0, 1 ), 5.0 );
    size = 12;
    height = 15;
    mins = ( -1 * size, -1 * size, 0 );
    maxs = ( size, size, height );
    absmins = liftedorigin + mins;
    absmaxs = liftedorigin + maxs;

    if ( boundswouldtelefrag( absmins, absmaxs ) )
    {
        rcbomb_debug_box( liftedorigin, mins, maxs, ( 1, 0, 0 ) );
        return false;
    }
    else
        rcbomb_debug_box( liftedorigin, mins, maxs, ( 0, 0, 1 ) );

    startheight = getplacementstartheight();
    mask = level.physicstracemaskphysics | level.physicstracemaskvehicle | level.physicstracemaskwater;
    trace = physicstrace( liftedorigin, origin + ( 0, 0, 1 ), mins, maxs, self, mask );

    if ( trace["fraction"] < 1 )
    {
        rcbomb_debug_box( trace["position"], mins, maxs, ( 1, 0, 0 ) );
        return false;
    }
    else
        rcbomb_debug_box( origin + ( 0, 0, 1 ), mins, maxs, ( 0, 1, 0 ) );

    size = 2.5;
    height = size * 2;
    mins = ( -1 * size, -1 * size, 0 );
    maxs = ( size, size, height );
    sweeptrace = physicstrace( self.origin + ( 0, 0, startheight ), liftedorigin, mins, maxs, self, mask );

    if ( sweeptrace["fraction"] < 1 )
    {
        rcbomb_debug_box( sweeptrace["position"], mins, maxs, ( 1, 0, 0 ) );
        return false;
    }

    return true;
}

trigger_hurt_monitor()
{
    self endon( "death" );

    for (;;)
    {
        self waittill( "touch", ent );

        if ( ent.classname == "trigger_hurt" )
        {
            if ( level.script == "mp_castaway" )
            {
                if ( ent.spawnflags & 16 )
                {
                    if ( self depthinwater() < 23 )
                        continue;
                }
            }

            self rcbomb_force_explode();
            return;
        }
    }
}

rcbomb_force_explode()
{
    self endon( "death" );
/#
    assert( self.targetname == "rcbomb" );
#/
    while ( !isdefined( self getseatoccupant( 0 ) ) )
        wait 0.1;

    self dodamage( 10, self.origin + vectorscale( ( 0, 0, 1 ), 10.0 ), self.owner, self.owner, "none", "MOD_EXPLOSIVE" );
}

rcbomb_debug_box( origin, mins, maxs, color )
{
/#
    debug_rcbomb = getdvar( _hash_8EAE5CA0 );

    if ( debug_rcbomb == "1" )
        box( origin, mins, maxs, 0, color, 1, 1, 300 );
#/
}

rcbomb_debug_line( start, end, color )
{
/#
    debug_rcbomb = getdvar( _hash_8EAE5CA0 );

    if ( debug_rcbomb == "1" )
        line( start, end, color, 1, 1, 300 );
#/
}
