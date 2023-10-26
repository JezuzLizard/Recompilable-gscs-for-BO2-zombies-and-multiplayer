// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\killstreaks\_airsupport;
#include maps\mp\gametypes\_battlechatter_mp;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\_vehicles;
#include maps\mp\_heatseekingmissile;
#include maps\mp\_scoreevents;
#include maps\mp\_challenges;
#include maps\mp\killstreaks\_dogs;

init()
{
    level.straferunnumrockets = 7;
    level.straferunrocketdelay = 0.35;
    level.straferungunlookahead = 4000;
    level.straferungunoffset = -800;
    level.straferungunradius = 500;
    level.straferunexitunits = 20000;
    level.straferunmaxstrafes = 4;
    level.straferunflaredelay = 2;
    level.straferunshellshockduration = 2.5;
    level.straferunshellshockradius = 512;
    level.straferunkillsbeforeexit = 10;
    level.straferunnumkillcams = 5;
    level.straferunmodel = "veh_t6_air_a10f";
    level.straferunmodelenemy = "veh_t6_air_a10f_alt";
    level.straferunvehicle = "vehicle_straferun_mp";
    level.straferungunweapon = "straferun_gun_mp";
    level.straferungunsound = "wpn_a10_shot_loop_npc";
    level.straferunrocketweapon = "straferun_rockets_mp";
    level.straferunrockettags = [];
    level.straferunrockettags[0] = "tag_rocket_left";
    level.straferunrockettags[1] = "tag_rocket_right";
    level.straferuncontrailfx = loadfx( "vehicle/exhaust/fx_exhaust_a10_contrail" );
    level.straferunchafffx = loadfx( "weapon/straferun/fx_straferun_chaf" );
    level.straferunexplodefx = loadfx( "vehicle/vexplosion/fx_vexplode_vtol_mp" );
    level.straferunexplodesound = "evt_helicopter_midair_exp";
    level.straferunshellshock = "straferun";
    precachemodel( level.straferunmodel );
    precachemodel( level.straferunmodelenemy );
    precachevehicle( level.straferunvehicle );
    precacheitem( level.straferungunweapon );
    precacheitem( level.straferunrocketweapon );
    precacheshellshock( level.straferunshellshock );
    maps\mp\killstreaks\_killstreaks::registerkillstreak( "straferun_mp", "straferun_mp", "killstreak_straferun", "straferun_used", ::usekillstreakstraferun, 1 );
    maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "straferun_mp", &"MP_EARNED_STRAFERUN", &"KILLSTREAK_STRAFERUN_NOT_AVAILABLE", &"MP_WAR_STRAFERUN_INBOUND", &"MP_WAR_STRAFERUN_INBOUND_NEAR_YOUR_POSITION" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "straferun_mp", "mpl_killstreak_straferun", "kls_straferun_used", "", "kls_straferun_enemy", "", "kls_straferun_ready" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdevdvar( "straferun_mp", "scr_givestraferun" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakaltweapon( "straferun_mp", level.straferungunweapon );
    maps\mp\killstreaks\_killstreaks::registerkillstreakaltweapon( "straferun_mp", level.straferunrocketweapon );
    maps\mp\killstreaks\_killstreaks::setkillstreakteamkillpenaltyscale( "straferun_mp", 0.0 );
    createkillcams( level.straferunnumkillcams, level.straferunnumrockets );
}

playpilotdialog( dialog )
{
    soundalias = level.teamprefix[self.team] + self.pilotvoicenumber + "_" + dialog;

    if ( isdefined( self.owner ) )
    {
        if ( self.owner.pilotisspeaking )
        {
            while ( self.owner.pilotisspeaking )
                wait 0.2;
        }
    }

    if ( isdefined( self.owner ) )
    {
        self.owner playlocalsound( soundalias );
        self.owner.pilotisspeaking = 1;
        self.owner thread waitplaybacktime( soundalias );
        self.owner waittill_any( soundalias, "death", "disconnect" );

        if ( isdefined( self.owner ) )
            self.owner.pilotisspeaking = 0;
    }
}

usekillstreakstraferun( hardpointtype )
{
    startnode = getvehiclenode( "warthog_start", "targetname" );

    if ( !isdefined( startnode ) )
    {
/#
        println( "ERROR: Strafe run vehicle spline not found!" );
#/
        return false;
    }

    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( "straferun_mp", self.team, 0, 1 );

    if ( killstreak_id == -1 )
        return false;

    plane = spawnvehicle( level.straferunmodel, "straferun", level.straferunvehicle, startnode.origin, ( 0, 0, 0 ) );
    plane.attackers = [];
    plane.attackerdata = [];
    plane.attackerdamage = [];
    plane.flareattackerdamage = [];
    plane setvehicleteam( self.team );
    plane setenemymodel( level.straferunmodelenemy );
    plane.team = self.team;
    plane makevehicleunusable();
    plane thread cleanupondeath();
    plane.health = 999999;
    plane.maxhealth = 999999;
    plane setowner( self );
    plane.owner = self;
    plane.numstrafes = 0;
    plane.killstreak_id = killstreak_id;
    plane.numflares = 2;
    plane.fx_flare = loadfx( "weapon/straferun/fx_straferun_chaf" );
    plane.soundmod = "straferun";
    plane setdrawinfrared( 1 );
    self.straferunkills = 0;
    self.straferunbda = 0;
    self.pilotisspeaking = 0;
    plane.pilotvoicenumber = self.bcvoicenumber + 1;

    if ( plane.pilotvoicenumber > 3 )
        plane.pilotvoicenumber = 0;

    self maps\mp\killstreaks\_killstreaks::playkillstreakstartdialog( "straferun_mp", self.pers["team"] );
    level.globalkillstreakscalled++;
    self addweaponstat( "straferun_mp", "used", 1 );
    plane thread pilotdialogwait( "a10_used", 2.5 );
    target_set( plane, ( 0, 0, 0 ) );
    target_setturretaquire( plane, 0 );
    plane thread playcontrail();
    plane.gunsoundentity = spawn( "script_model", plane gettagorigin( "tag_flash" ) );
    plane.gunsoundentity linkto( plane, "tag_flash", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    plane resetkillcams();
    plane thread watchforotherkillstreaks();
    plane thread watchforkills();
    plane thread watchdamage();
    plane thread dostraferuns();
    plane thread maps\mp\_vehicles::follow_path( startnode );
    plane thread maps\mp\_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "death" );
    plane thread watchforownerexit( self );
    return true;
}

playcontrail()
{
    self endon( "death" );
    wait 0.1;
    playfxontag( level.straferuncontrailfx, self, "tag_origin" );
    self playloopsound( "veh_a10_engine_loop", 1 );
}

cleanupondeath()
{
    self waittill( "death" );

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "straferun_mp", self.team, self.killstreak_id );

    if ( isdefined( self.gunsoundentity ) )
    {
        self.gunsoundentity stoploopsound();
        self.gunsoundentity delete();
        self.gunsoundentity = undefined;
    }
}

watchdamage()
{
    self endon( "death" );
    self.maxhealth = 999999;
    self.health = self.maxhealth;
    self.maxhealth = 1000;
    low_health = 0;
    damage_taken = 0;

    for (;;)
    {
        self waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;
/#
        self.damage_debug = damage + " (" + weapon + ")";
#/
        if ( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" || mod == "MOD_EXPLOSIVE" )
            damage += 1000;

        self.attacker = attacker;
        damage_taken += damage;

        if ( damage_taken >= 1000 )
        {
            self thread explode();

            if ( self.owner isenemyplayer( attacker ) )
            {
                maps\mp\_scoreevents::processscoreevent( "destroyed_strafe_run", attacker, self.owner, weapon );
                attacker maps\mp\_challenges::addflyswatterstat( weapon, self );
            }
            else
            {

            }

            return;
        }
    }
}

watchforotherkillstreaks()
{
    self endon( "death" );

    for (;;)
    {
        level waittill( "killstreak_started", hardpointtype, teamname, attacker );

        if ( !isdefined( self.owner ) )
        {
            self thread explode();
            return;
        }

        if ( hardpointtype == "emp_mp" )
        {
            if ( self.owner isenemyplayer( attacker ) )
            {
                self thread explode();
                maps\mp\_scoreevents::processscoreevent( "destroyed_strafe_run", attacker, self.owner, hardpointtype );
                attacker maps\mp\_challenges::addflyswatterstat( hardpointtype, self );
                return;
            }
        }
        else if ( hardpointtype == "missile_swarm_mp" )
        {
            if ( self.owner isenemyplayer( attacker ) )
                self.leavenexttime = 1;
        }
    }
}

watchforkills()
{
    self endon( "death" );

    for (;;)
    {
        self waittill( "killed", player );

        if ( isplayer( player ) )
            continue;
    }
}

watchforownerexit( owner )
{
    self endon( "death" );
    owner waittill_any( "disconnect", "joined_team", "joined_spectator" );
    self.leavenexttime = 1;
}

addstraferunkill()
{
    if ( !isdefined( self.straferunkills ) )
        self.straferunkills = 0;

    self.straferunkills++;
}

dostraferuns()
{
    self endon( "death" );

    for (;;)
    {
        self waittill( "noteworthy", noteworthy, noteworthynode );

        if ( noteworthy == "strafe_start" )
        {
            self.straferungunlookahead = level.straferungunlookahead;
            self.straferungunradius = level.straferungunradius;
            self.straferungunoffset = level.straferungunoffset;
/#
            self.straferungunlookahead = getdvarintdefault( _hash_DFF9F5CE, level.straferungunlookahead );
            self.straferungunradius = getdvarintdefault( _hash_74D7F06E, level.straferungunradius );
            self.straferungunoffset = getdvarintdefault( _hash_6E34324D, level.straferungunoffset );
#/
            if ( isdefined( noteworthynode ) )
            {
                if ( isdefined( noteworthynode.script_parameters ) )
                    self.straferungunlookahead = float( noteworthynode.script_parameters );

                if ( isdefined( noteworthynode.script_radius ) )
                    self.straferungunradius = float( noteworthynode.script_radius );

                if ( isdefined( noteworthynode.script_float ) )
                    self.straferungunoffset = float( noteworthynode.script_float );
            }

            if ( isdefined( self.owner ) )
                self thread startstrafe();

            continue;
        }

        if ( noteworthy == "strafe_stop" )
        {
            self stopstrafe();
            continue;
        }

        if ( noteworthy == "strafe_leave" )
        {
            if ( self shouldleavemap() )
            {
                self thread leavemap();
                self thread pilotdialogwait( "a10_leave", 5 );
                continue;
            }

            self thread pilotdialogwait( "a10_strafe", 3 );
        }
    }
}

fireflares()
{
    self endon( "death" );
    self endon( "strafe_start" );
    wait 0.1;

    for (;;)
    {
        chaff_fx = spawn( "script_model", self.origin );
        chaff_fx.angles = vectorscale( ( 0, 1, 0 ), 180.0 );
        chaff_fx setmodel( "tag_origin" );
        chaff_fx linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
        wait 0.1;
        playfxontag( level.straferunchafffx, chaff_fx, "tag_origin" );
        chaff_fx playsound( "wpn_a10_drop_chaff" );
        chaff_fx thread deleteaftertimethread( level.straferunflaredelay );
        wait( level.straferunflaredelay );
    }
}

startstrafe()
{
    self endon( "death" );
    self endon( "strafe_stop" );

    if ( isdefined( self.strafing ) )
    {
        iprintlnbold( "TRYING TO STRAFE WHEN ALREADY STRAFING!\\n" );
        return;
    }

    self.strafing = 1;
    self thread pilotdialogwait( "kls_hit", 3.5 );

    if ( self.numstrafes == 0 )
        self firststrafe();

    self thread firerockets();
    self thread startstrafekillcams();
    count = 0;
    weaponshoottime = weaponfiretime( level.straferungunweapon );

    for (;;)
    {
        gunorigin = self gettagorigin( "tag_flash" );
        gunorigin += ( 0, 0, self.straferungunoffset );
        forward = anglestoforward( self.angles );
        forwardnoz = vectornormalize( ( forward[0], forward[1], 0 ) );
        right = vectorcross( forwardnoz, ( 0, 0, 1 ) );
        perfectattackstartvector = gunorigin + vectorscale( forwardnoz, self.straferungunlookahead );
        attackstartvector = perfectattackstartvector + vectorscale( right, randomfloatrange( 0 - self.straferungunradius, self.straferungunradius ) );
        trace = bullettrace( attackstartvector, ( attackstartvector[0], attackstartvector[1], -500 ), 0, self, 0, 1 );
        self setturrettargetvec( trace["position"] );
        self fireweapon( "tag_flash" );
        self.gunsoundentity playloopsound( level.straferungunsound );
        self shellshockplayers( trace["position"] );
/#
        if ( getdvarintdefault( _hash_B575F615, 0 ) )
        {
            time = 300;
            debug_line( attackstartvector, trace["position"] - vectorscale( ( 0, 0, 1 ), 20.0 ), ( 1, 0, 0 ), time, 0 );

            if ( count % 30 == 0 )
            {
                trace = bullettrace( perfectattackstartvector, ( perfectattackstartvector[0], perfectattackstartvector[1], -100000 ), 0, self, 0, 1 );
                debug_line( trace["position"] + vectorscale( ( 0, 0, 1 ), 20.0 ), trace["position"] - vectorscale( ( 0, 0, 1 ), 20.0 ), ( 0, 0, 1 ), time, 0 );
            }
        }
#/
        count++;
        wait( weaponshoottime );
    }
}

firststrafe()
{

}

firerockets()
{
    self notify( "firing_rockets" );
    self endon( "death" );
    self endon( "strafe_stop" );
    self endon( "firing_rockets" );
    self.owner endon( "disconnect" );
    forward = anglestoforward( self.angles );
    self.firedrockettargets = [];

    for ( rocketindex = 0; rocketindex < level.straferunnumrockets; rocketindex++ )
    {
        rockettag = level.straferunrockettags[rocketindex % level.straferunrockettags.size];
        targets = getvalidtargets();
        rocketorigin = self gettagorigin( rockettag );
        targetorigin = rocketorigin + forward * 10000;

        if ( targets.size > 0 )
        {
            selectedtarget = undefined;

            foreach ( target in targets )
            {
                alreadyattacked = 0;

                foreach ( oldtarget in self.firedrockettargets )
                {
                    if ( oldtarget == target )
                    {
                        alreadyattacked = 1;
                        break;
                    }
                }

                if ( !alreadyattacked )
                {
                    selectedtarget = target;
                    break;
                }
            }

            if ( isdefined( selectedtarget ) )
            {
                self.firedrockettargets[self.firedrockettargets.size] = selectedtarget;
                targetorigin = deadrecontargetorigin( rocketorigin, selectedtarget );
            }
        }

        rocketorigin = self gettagorigin( rockettag );
        rocket = magicbullet( level.straferunrocketweapon, rocketorigin, rocketorigin + forward, self.owner );

        if ( isdefined( selectedtarget ) )
            rocket missile_settarget( selectedtarget, ( 0, 0, 0 ) );

        rocket.soundmod = "straferun";
        rocket attachkillcamtorocket( level.straferunkillcams.rockets[rocketindex], selectedtarget, targetorigin );
/#
        if ( getdvarintdefault( _hash_9191CAAA, 0 ) )
            rocket thread debug_draw_bomb_path( undefined, vectorscale( ( 0, 1, 0 ), 0.5 ), 400 );
#/
        wait( level.straferunrocketdelay );
    }
}

stopstrafe()
{
    self notify( "strafe_stop" );
    self.strafing = undefined;
    self thread resetkillcams( 3 );
    self clearturrettarget();
    owner = self.owner;

    if ( owner.straferunbda == 0 )
        bdadialog = "kls_killn";

    if ( owner.straferunbda == 1 )
        bdadialog = "kls_kill1";

    if ( owner.straferunbda == 2 )
        bdadialog = "kls_kill2";

    if ( owner.straferunbda == 3 )
        bdadialog = "kls_kill3";

    if ( owner.straferunbda > 3 )
        bdadialog = "kls_killm";

    if ( isdefined( bdadialog ) )
        self thread pilotdialogwait( bdadialog, 3.5 );

    owner.straferunbda = 0;
    self.gunsoundentity stoploopsound();
    self.gunsoundentity playsound( "wpn_a10_shot_decay_npc" );
    self.numstrafes++;
}

pilotdialogwait( dialog, time )
{
    self endon( "death" );

    if ( isdefined( time ) )
        wait( time );

    playpilotdialog( dialog );
}

shouldleavemap()
{
    if ( isdefined( self.leavenexttime ) && self.leavenexttime )
        return true;

    if ( self.numstrafes >= level.straferunmaxstrafes )
        return true;

    if ( self.owner.straferunkills >= level.straferunkillsbeforeexit )
        return true;

    return false;
}

leavemap()
{
    self unlinkkillcams();
    exitorigin = self.origin + vectorscale( anglestoforward( self.angles ), level.straferunexitunits );
    self setyawspeed( 5, 999, 999 );
    self setvehgoalpos( exitorigin, 1 );
    wait 5;

    if ( isdefined( self ) )
        self delete();
}

explode()
{
    self endon( "delete" );
    forward = self.origin + vectorscale( ( 0, 0, 1 ), 100.0 ) - self.origin;
    playfx( level.straferunexplodefx, self.origin, forward );
    self playsound( level.straferunexplodesound );
    wait 0.1;

    if ( isdefined( self ) )
        self delete();
}

cantargetentity( entity )
{
    heli_centroid = self.origin + vectorscale( ( 0, 0, -1 ), 160.0 );
    heli_forward_norm = anglestoforward( self.angles );
    heli_turret_point = heli_centroid + 144 * heli_forward_norm;
    visible_amount = entity sightconetrace( heli_turret_point, self );

    if ( visible_amount < level.heli_target_recognition )
        return false;

    return true;
}

cantargetplayer( player )
{
    if ( !isalive( player ) || player.sessionstate != "playing" )
        return 0;

    if ( player == self.owner )
        return 0;

    if ( player cantargetplayerwithspecialty() == 0 )
        return 0;

    if ( !isdefined( player.team ) )
        return 0;

    if ( level.teambased && player.team == self.team )
        return 0;

    if ( player.team == "spectator" )
        return 0;

    if ( isdefined( player.spawntime ) && ( gettime() - player.spawntime ) / 1000 <= level.heli_target_spawnprotection )
        return 0;

    if ( !targetinfrontofplane( player ) )
        return 0;

    if ( player isinmovemode( "noclip" ) )
        return 0;

    return cantargetentity( player );
}

cantargetactor( actor )
{
    if ( !isdefined( actor ) )
        return 0;

    if ( level.teambased && actor.aiteam == self.team )
        return 0;

    if ( isdefined( actor.script_owner ) && self.owner == actor.script_owner )
        return 0;

    if ( !targetinfrontofplane( actor ) )
        return 0;

    return cantargetentity( actor );
}

targetinfrontofplane( target )
{
    forward_dir = anglestoforward( self.angles );
    target_delta = vectornormalize( target.origin - self.origin );
    dot = vectordot( forward_dir, target_delta );

    if ( dot < 0.5 )
        return true;

    return true;
}

getvalidtargets()
{
    targets = [];

    foreach ( player in level.players )
    {
        if ( self cantargetplayer( player ) )
        {
            if ( isdefined( player ) )
                targets[targets.size] = player;
        }
    }

    dogs = maps\mp\killstreaks\_dogs::dog_manager_get_dogs();

    foreach ( dog in dogs )
    {
        if ( self cantargetactor( dog ) )
            targets[targets.size] = dog;
    }

    tanks = getentarray( "talon", "targetname" );

    foreach ( tank in tanks )
    {
        if ( self cantargetactor( tank ) )
            targets[targets.size] = tank;
    }

    return targets;
}

deadrecontargetorigin( rocket_start, target )
{
    target_velocity = target getvelocity();
    missile_speed = 7000;
    target_delta = target.origin - rocket_start;
    target_dist = length( target_delta );
    time_to_target = target_dist / missile_speed;
    return target.origin + target_velocity * time_to_target;
}

shellshockplayers( origin )
{
    foreach ( player in level.players )
    {
        if ( !isalive( player ) )
            continue;

        if ( player == self.owner )
            continue;

        if ( !isdefined( player.team ) )
            continue;

        if ( level.teambased && player.team == self.team )
            continue;

        if ( distancesquared( player.origin, origin ) <= level.straferunshellshockradius * level.straferunshellshockradius )
            player thread straferunshellshock();
    }
}

straferunshellshock()
{
    self endon( "disconnect" );

    if ( isdefined( self.beingstraferunshellshocked ) && self.beingstraferunshellshocked )
        return;

    self.beingstraferunshellshocked = 1;
    self shellshock( level.straferunshellshock, level.straferunshellshockduration );
    wait( level.straferunshellshockduration + 1 );
    self.beingstraferunshellshocked = 0;
}

createkillcams( numkillcams, numrockets )
{
    if ( !isdefined( level.straferunkillcams ) )
    {
        level.straferunkillcams = spawnstruct();
        level.straferunkillcams.rockets = [];

        for ( i = 0; i < numrockets; i++ )
            level.straferunkillcams.rockets[level.straferunkillcams.rockets.size] = createkillcament();

        level.straferunkillcams.strafes = [];

        for ( i = 0; i < numkillcams; i++ )
        {
            level.straferunkillcams.strafes[level.straferunkillcams.strafes.size] = createkillcament();
/#
            if ( getdvarintdefault( _hash_9191CAAA, 0 ) )
                level.straferunkillcams.strafes[i] thread debug_draw_bomb_path( undefined, vectorscale( ( 0, 0, 1 ), 0.5 ), 200 );
#/
        }
    }
}

resetkillcams( time )
{
    self endon( "death" );

    if ( isdefined( time ) )
        wait( time );

    for ( i = 0; i < level.straferunkillcams.rockets.size; i++ )
        level.straferunkillcams.rockets[i] resetrocketkillcament( self, i );

    for ( i = 0; i < level.straferunkillcams.strafes.size; i++ )
        level.straferunkillcams.strafes[i] resetkillcament( self );
}

unlinkkillcams()
{
    for ( i = 0; i < level.straferunkillcams.rockets.size; i++ )
        level.straferunkillcams.rockets[i] unlink();

    for ( i = 0; i < level.straferunkillcams.strafes.size; i++ )
        level.straferunkillcams.strafes[i] unlink();
}

createkillcament()
{
    killcament = spawn( "script_model", ( 0, 0, 0 ) );
    killcament setfovforkillcam( 25 );
    return killcament;
}

resetkillcament( parent )
{
    self notify( "reset" );
    parent endon( "death" );
    offset_x = getdvarintdefault( _hash_33660DD8, -3000 );
    offset_y = getdvarintdefault( _hash_33660DD9, 0 );
    offset_z = getdvarintdefault( _hash_33660DDA, 740 );
    self linkto( parent, "tag_origin", ( offset_x, offset_y, offset_z ), vectorscale( ( 1, 0, 0 ), 10.0 ) );
    self thread unlinkwhenparentdies( parent );
}

resetrocketkillcament( parent, rocketindex )
{
    self notify( "reset" );
    parent endon( "death" );
    offset_x = getdvarintdefault( _hash_33660DD8, -3000 );
    offset_y = getdvarintdefault( _hash_33660DD9, 0 );
    offset_z = getdvarintdefault( _hash_33660DDA, 740 );
    rockettag = level.straferunrockettags[rocketindex % level.straferunrockettags.size];
    self linkto( parent, rockettag, ( offset_x, offset_y, offset_z ), vectorscale( ( 1, 0, 0 ), 10.0 ) );
    self thread unlinkwhenparentdies( parent );
}

deletewhenparentdies( parent )
{
    parent waittill( "death" );

    self delete();
}

unlinkwhenparentdies( parent )
{
    self endon( "reset" );
    self endon( "unlink" );

    parent waittill( "death" );

    self unlink();
}

attachkillcamtorocket( killcament, selectedtarget, targetorigin )
{
    offset_x = getdvarintdefault( _hash_218B2530, -400 );
    offset_y = getdvarintdefault( _hash_218B2531, 0 );
    offset_z = getdvarintdefault( _hash_218B2532, 110 );
    self.killcament = killcament;
    forward = vectorscale( anglestoforward( self.angles ), offset_x );
    right = vectorscale( anglestoright( self.angles ), offset_y );
    up = vectorscale( anglestoup( self.angles ), offset_z );
    killcament unlink();
    killcament.angles = ( 0, 0, 0 );
    killcament.origin = self.origin;
    killcament linkto( self, "", ( offset_x, offset_y, offset_z ), vectorscale( ( 1, 0, 0 ), 9.0 ) );
    killcament thread unlinkwhenclose( selectedtarget, targetorigin, self );
}

unlinkwhenclose( selectedtarget, targetorigin, plane )
{
    plane endon( "death" );
    self notify( "unlink_when_close" );
    self endon( "unlink_when_close" );
    distsqr = 1000000;

    while ( true )
    {
        if ( isdefined( selectedtarget ) )
        {
            if ( distancesquared( self.origin, selectedtarget.origin ) < distsqr )
            {
                self unlink();
                self.angles = ( 0, 0, 0 );
                return;
            }
        }
        else if ( distancesquared( self.origin, targetorigin ) < distsqr )
        {
            self unlink();
            self.angles = ( 0, 0, 0 );
            return;
        }

        wait 0.1;
    }
}

getlookaheadorigin( previous_origin, next_origin, lookahead )
{
    delta = next_origin - previous_origin;
    forwardnoz = vectornormalize( ( delta[0], delta[1], 0 ) );
    origin = next_origin + vectorscale( forwardnoz, lookahead );
    return origin;
}

strafekillcam( parent, node, distance )
{
    parent endon( "death" );
    self endon( "reset" );
    wait 0.05;
    self notify( "unlink" );
    self unlink();
    self.angles = ( 0, 0, 0 );
    accel_time = 0.2;
    speed = 20000;
    start_height_offset = -800;
    stop_height = level.mapcenter[2] - 500;
    start_origin_struct = getoriginalongstrafepath( node, self.origin, distance );
    start_origin = start_origin_struct.origin;
    node = start_origin_struct.node;
    previous_origin = self.origin;
    start_origin = getlookaheadorigin( previous_origin, start_origin, parent.straferungunlookahead + 1000 );
    trace = bullettrace( ( start_origin[0], start_origin[1], start_origin[2] + start_height_offset ), ( start_origin[0], start_origin[1], stop_height ), 0, parent, 0, 1 );
    pathheight = trace["position"][2];
    self killcammoveto( trace["position"], speed, accel_time, pathheight );
    speed = 500;

    while ( isdefined( node ) )
    {
        previous_origin = node.origin;
        node = getvehiclenode( node.target, "targetname" );
        start_origin = getlookaheadorigin( previous_origin, node.origin, parent.straferungunlookahead + 1000 );
        trace = bullettrace( ( start_origin[0], start_origin[1], start_origin[2] + start_height_offset ), ( start_origin[0], start_origin[1], stop_height ), 0, parent, 0, 1 );
        self killcammoveto( trace["position"], speed, 0, pathheight );
    }
}

killcammoveto( goal, speed, accel, pathheight )
{
    self endon( "reset" );
    height_offset = randomintrange( 350, 450 );
    origin = ( goal[0], goal[1], goal[2] + height_offset );
    dist = distance( origin, self.origin );
    time = dist / speed;

    if ( accel > time )
        accel = time;

    self moveto( origin, time, accel, 0 );

    self waittill( "movedone" );
}

startstrafekillcams()
{
    node = getvehiclenode( self.currentnode.target, "targetname" );
    strafe_dist = getstrafedistance( node );
    strafe_increment = strafe_dist / ( level.straferunkillcams.strafes.size + 1 );
    current_dist = 10;

    for ( i = 0; i < level.straferunkillcams.strafes.size; i++ )
    {
        level.straferunkillcams.strafes[i] thread strafekillcam( self, node, current_dist );
        current_dist += strafe_increment;
    }
}

getstrafedistance( node )
{
    previous_node = node;
    next_node = getvehiclenode( previous_node.target, "targetname" );
    dist = 0;

    while ( ( !isdefined( previous_node.script_noteworthy ) || previous_node.script_noteworthy != "strafe_stop" ) && next_node != node )
    {
        dist += distance( ( previous_node.origin[0], previous_node.origin[1], 0 ), ( next_node.origin[0], next_node.origin[1], 0 ) );
        previous_node = next_node;
        next_node = getvehiclenode( previous_node.target, "targetname" );
    }

    return dist;
}

getoriginalongstrafepath( node, start_origin, distance_along )
{
    origin_node = spawnstruct();
    seg_dist = distance( ( start_origin[0], start_origin[1], 0 ), ( node.origin[0], node.origin[1], 0 ) );
    dist = 0;

    if ( dist + seg_dist > distance_along )
    {
        forwardvec = vectornormalize( ( node.origin[0], node.origin[1], 0 ) - ( start_origin[0], start_origin[1], 0 ) );
        origin_node.origin = start_origin + forwardvec * ( distance_along - dist );
        origin_node.node = node;
        return origin_node;
    }

    dist = seg_dist;
    previous_node = node;

    for ( next_node = getvehiclenode( previous_node.target, "targetname" ); ( !isdefined( previous_node.script_noteworthy ) || previous_node.script_noteworthy != "strafe_stop" ) && next_node != node; next_node = getvehiclenode( previous_node.target, "targetname" ) )
    {
        seg_dist = distance( ( previous_node.origin[0], previous_node.origin[1], 0 ), ( next_node.origin[0], next_node.origin[1], 0 ) );

        if ( dist + seg_dist > distance_along )
        {
            forwardvec = vectornormalize( next_node.origin - previous_node.origin );
            origin_node.origin = previous_node.origin + forwardvec * ( distance_along - dist );
            origin_node.node = previous_node;
            return origin_node;
        }

        dist += seg_dist;
        previous_node = next_node;
    }
}
