// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_heatseekingmissile;
#include maps\mp\killstreaks\_supplydrop;
#include maps\mp\gametypes\_weaponobjects;

init()
{
    level.hackertoolmaxequipmentdistance = 2000;
    level.hackertoolmaxequipmentdistancesq = level.hackertoolmaxequipmentdistance * level.hackertoolmaxequipmentdistance;
    level.hackertoolnosighthackdistance = 750;
    level.hackertoollostsightlimitms = 450;
    level.hackertoollockonradius = 20;
    level.hackertoollockonfov = 65;
    level.hackertoolhacktimems = 0.5;
    level.equipmenthackertoolradius = 60;
    level.equipmenthackertooltimems = 50;
    level.carepackagehackertoolradius = 60;
    level.carepackagehackertooltimems = getgametypesetting( "crateCaptureTime" ) * 500;
    level.carepackagefriendlyhackertooltimems = getgametypesetting( "crateCaptureTime" ) * 2000;
    level.carepackageownerhackertooltimems = 250;
    level.sentryhackertoolradius = 80;
    level.sentryhackertooltimems = 4000;
    level.microwavehackertoolradius = 80;
    level.microwavehackertooltimems = 4000;
    level.vehiclehackertoolradius = 80;
    level.vehiclehackertooltimems = 4000;
    level.rcxdhackertooltimems = 1500;
    level.rcxdhackertoolradius = 20;
    level.uavhackertooltimems = 4000;
    level.uavhackertoolradius = 40;
    level.cuavhackertooltimems = 4000;
    level.cuavhackertoolradius = 40;
    level.carepackagechopperhackertooltimems = 3000;
    level.carepackagechopperhackertoolradius = 60;
    level.littlebirdhackertooltimems = 4000;
    level.littlebirdhackertoolradius = 80;
    level.qrdronehackertooltimems = 3000;
    level.qrdronehackertoolradius = 60;
    level.aitankhackertooltimems = 4000;
    level.aitankhackertoolradius = 60;
    level.stealthchopperhackertooltimems = 4000;
    level.stealthchopperhackertoolradius = 80;
    level.warthoghackertooltimems = 4000;
    level.warthoghackertoolradius = 80;
    level.lodestarhackertooltimems = 4000;
    level.lodestarhackertoolradius = 60;
    level.choppergunnerhackertooltimems = 4000;
    level.choppergunnerhackertoolradius = 260;
    thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self clearhackertarget();
        self thread watchhackertooluse();
        self thread watchhackertoolfired();
    }
}

clearhackertarget()
{
    self notify( "stop_lockon_sound" );
    self notify( "stop_locked_sound" );
    self.stingerlocksound = undefined;
    self stoprumble( "stinger_lock_rumble" );
    self.hackertoollockstarttime = 0;
    self.hackertoollockstarted = 0;
    self.hackertoollockfinalized = 0;
    self.hackertoollocktimeelapsed = 0.0;
    self setweaponheatpercent( "pda_hack_mp", 0.0 );

    if ( isdefined( self.hackertooltarget ) )
    {
        lockingon( self.hackertooltarget, 0 );
        lockedon( self.hackertooltarget, 0 );
    }

    self.hackertooltarget = undefined;
    self weaponlockfree();
    self weaponlocktargettooclose( 0 );
    self weaponlocknoclearance( 0 );
    self stoplocalsound( game["locking_on_sound"] );
    self stoplocalsound( game["locked_on_sound"] );
    self destroylockoncanceledmessage();
}

watchhackertoolfired()
{
    self endon( "disconnect" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "hacker_tool_fired", hackertooltarget );

        if ( isdefined( hackertooltarget ) )
        {
            if ( isentityhackablecarepackage( hackertooltarget ) )
            {
                maps\mp\killstreaks\_supplydrop::givecratecapturemedal( hackertooltarget, self );
                hackertooltarget notify( "captured", self, 1 );
            }

            if ( isentityhackableweaponobject( hackertooltarget ) || isdefined( hackertooltarget.hackertrigger ) )
                hackertooltarget.hackertrigger notify( "trigger", self, 1 );
            else
            {
                if ( isdefined( hackertooltarget.classname ) && hackertooltarget.classname == "grenade" )
                    damage = 1;
                else if ( isdefined( hackertooltarget.maxhealth ) )
                    damage = hackertooltarget.maxhealth + 1;
                else
                    damage = 999999;

                if ( isdefined( hackertooltarget.numflares ) && hackertooltarget.numflares > 0 )
                {
                    damage = 1;
                    hackertooltarget.numflares--;
                    hackertooltarget maps\mp\_heatseekingmissile::missiletarget_playflarefx();
                }

                hackertooltarget dodamage( damage, self.origin, self, self, 0, "MOD_UNKNOWN", 0, "pda_hack_mp" );
            }

            self addplayerstat( "hack_enemy_target", 1 );
            self addweaponstat( "pda_hack_mp", "used", 1 );
        }

        clearhackertarget();
        self forceoffhandend();
        clip_ammo = self getweaponammoclip( "pda_hack_mp" );
        clip_ammo--;
        assert( clip_ammo >= 0 );
        self setweaponammoclip( "pda_hack_mp", clip_ammo );
        self switchtoweapon( self getlastweapon() );
    }
}

watchhackertooluse()
{
    self endon( "disconnect" );
    self endon( "death" );

    for (;;)
    {
        self waittill( "grenade_pullback", weapon );

        if ( weapon == "pda_hack_mp" )
        {
            wait 0.05;

            if ( self isusingoffhand() && self getcurrentoffhand() == "pda_hack_mp" )
            {
                self thread hackertooltargetloop();
                self thread watchhackertoolend();
                self thread watchforgrenadefire();
                self thread watchhackertoolinterrupt();
            }
        }
    }
}

watchhackertoolinterrupt()
{
    self endon( "disconnect" );
    self endon( "hacker_tool_fired" );
    self endon( "death" );
    self endon( "weapon_change" );
    self endon( "grenade_fire" );

    while ( true )
    {
        level waittill( "use_interrupt", interrupttarget );

        if ( self.hackertooltarget == interrupttarget )
            clearhackertarget();

        wait 0.05;
    }
}

watchhackertoolend()
{
    self endon( "disconnect" );
    self endon( "hacker_tool_fired" );
    msg = self waittill_any_return( "weapon_change", "death" );
    clearhackertarget();
}

watchforgrenadefire()
{
    self endon( "disconnect" );
    self endon( "hacker_tool_fired" );
    self endon( "weapon_change" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "grenade_fire", grenade, grenadename, respawnfromhack );

        if ( isdefined( respawnfromhack ) && respawnfromhack )
            continue;

        clearhackertarget();
        clip_ammo = self getweaponammoclip( "pda_hack_mp" );
        clip_max_ammo = weaponclipsize( "pda_hack_mp" );

        if ( clip_ammo < clip_max_ammo )
            clip_ammo++;

        self setweaponammoclip( "pda_hack_mp", clip_ammo );
        break;
    }
}

hackertooltargetloop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "weapon_change" );
    self endon( "grenade_fire" );

    while ( true )
    {
        wait 0.05;

        if ( self.hackertoollockfinalized )
        {
            if ( !self isvalidhackertooltarget( self.hackertooltarget ) )
            {
                self clearhackertarget();
                continue;
            }

            passed = self hackersoftsighttest();

            if ( !passed )
                continue;

            lockingon( self.hackertooltarget, 0 );
            lockedon( self.hackertooltarget, 1 );
            thread looplocallocksound( game["locked_on_sound"], 0.75 );
            self notify( "hacker_tool_fired", self.hackertooltarget );
            return;
        }

        if ( self.hackertoollockstarted )
        {
            if ( !self isvalidhackertooltarget( self.hackertooltarget ) )
            {
                self clearhackertarget();
                continue;
            }

            locklengthms = self gethacktime( self.hackertooltarget );

            if ( locklengthms == 0 )
            {
                self clearhackertarget();
                continue;
            }

            if ( self.hackertoollocktimeelapsed == 0.0 )
                self playlocalsound( "evt_hacker_hacking" );

            lockingon( self.hackertooltarget, 1 );
            lockedon( self.hackertooltarget, 0 );
            passed = self hackersoftsighttest();

            if ( !passed )
                continue;

            if ( self.hackertoollostsightlinetime == 0 )
            {
                self.hackertoollocktimeelapsed += 0.05;
                hackpercentage = self.hackertoollocktimeelapsed / ( locklengthms / 1000 );
                self setweaponheatpercent( "pda_hack_mp", hackpercentage );
            }

            if ( self.hackertoollocktimeelapsed < locklengthms / 1000 )
                continue;

            assert( isdefined( self.hackertooltarget ) );
            self notify( "stop_lockon_sound" );
            self.hackertoollockfinalized = 1;
            self weaponlockfinalize( self.hackertooltarget );
            continue;
        }

        besttarget = self getbesthackertooltarget();

        if ( !isdefined( besttarget ) )
        {
            self destroylockoncanceledmessage();
            continue;
        }

        if ( !self locksighttest( besttarget ) && distance2d( self.origin, besttarget.origin ) > level.hackertoolnosighthackdistance )
        {
            self destroylockoncanceledmessage();
            continue;
        }

        if ( self locksighttest( besttarget ) && isdefined( besttarget.lockondelay ) && besttarget.lockondelay )
        {
            self displaylockoncanceledmessage();
            continue;
        }

        self destroylockoncanceledmessage();
        initlockfield( besttarget );
        self.hackertooltarget = besttarget;
        self.hackertoollockstarttime = gettime();
        self.hackertoollockstarted = 1;
        self.hackertoollostsightlinetime = 0;
        self.hackertoollocktimeelapsed = 0.0;
        self setweaponheatpercent( "pda_hack_mp", 0.0 );
        self thread looplocalseeksound( game["locking_on_sound"], 0.6 );
    }
}

getbesthackertooltarget()
{
    targetsvalid = [];
    targetsall = arraycombine( target_getarray(), level.missileentities, 0, 0 );
    targetsall = arraycombine( targetsall, level.hackertooltargets, 0, 0 );

    for ( idx = 0; idx < targetsall.size; idx++ )
    {
        target_ent = targetsall[idx];

        if ( !isdefined( target_ent ) || !isdefined( target_ent.owner ) )
            continue;
/#
        if ( getdvar( "scr_freelock" ) == "1" )
        {
            if ( self iswithinhackertoolreticle( targetsall[idx] ) )
                targetsvalid[targetsvalid.size] = targetsall[idx];

            continue;
        }
#/
        if ( level.teambased )
        {
            if ( isentityhackablecarepackage( target_ent ) )
            {
                if ( self iswithinhackertoolreticle( target_ent ) )
                    targetsvalid[targetsvalid.size] = target_ent;
            }
            else if ( isdefined( target_ent.team ) )
            {
                if ( target_ent.team != self.team )
                {
                    if ( self iswithinhackertoolreticle( target_ent ) )
                        targetsvalid[targetsvalid.size] = target_ent;
                }
            }
            else if ( isdefined( target_ent.owner.team ) )
            {
                if ( target_ent.owner.team != self.team )
                {
                    if ( self iswithinhackertoolreticle( target_ent ) )
                        targetsvalid[targetsvalid.size] = target_ent;
                }
            }

            continue;
        }

        if ( self iswithinhackertoolreticle( target_ent ) )
        {
            if ( isentityhackablecarepackage( target_ent ) )
            {
                targetsvalid[targetsvalid.size] = target_ent;
                continue;
            }

            if ( isdefined( target_ent.owner ) && self != target_ent.owner )
                targetsvalid[targetsvalid.size] = target_ent;
        }
    }

    chosenent = undefined;

    if ( targetsvalid.size != 0 )
        chosenent = targetsvalid[0];

    return chosenent;
}

iswithinhackertoolreticle( target )
{
    radius = gethackertoolradius( target );
    return target_isincircle( target, self, level.hackertoollockonfov, radius, 0.0 );
}

isentityhackableweaponobject( entity )
{
    if ( isdefined( entity.classname ) && entity.classname == "grenade" )
    {
        if ( isdefined( entity.name ) )
        {
            watcher = maps\mp\gametypes\_weaponobjects::getweaponobjectwatcherbyweapon( entity.name );

            if ( isdefined( watcher ) )
            {
                if ( watcher.hackable )
                {
/#
                    assert( isdefined( watcher.hackertoolradius ) );
                    assert( isdefined( watcher.hackertooltimems ) );
#/
                    return true;
                }
            }
        }
    }

    return false;
}

getweaponobjecthackerradius( entity )
{
/#
    assert( isdefined( entity.classname ) );
    assert( isdefined( entity.name ) );
#/
    watcher = maps\mp\gametypes\_weaponobjects::getweaponobjectwatcherbyweapon( entity.name );
/#
    assert( watcher.hackable );
    assert( isdefined( watcher.hackertoolradius ) );
#/
    return watcher.hackertoolradius;
}

getweaponobjecthacktimems( entity )
{
/#
    assert( isdefined( entity.classname ) );
    assert( isdefined( entity.name ) );
#/
    watcher = maps\mp\gametypes\_weaponobjects::getweaponobjectwatcherbyweapon( entity.name );
/#
    assert( watcher.hackable );
    assert( isdefined( watcher.hackertooltimems ) );
#/
    return watcher.hackertooltimems;
}

isentityhackablecarepackage( entity )
{
    if ( isdefined( entity.model ) )
        return entity.model == "t6_wpn_supply_drop_ally";
    else
        return 0;
}

isvalidhackertooltarget( ent )
{
    if ( !isdefined( ent ) )
        return false;

    if ( self isusingremote() )
        return false;

    if ( self isempjammed() )
        return false;

    if ( !target_istarget( ent ) && !isentityhackableweaponobject( ent ) && !isinarray( level.hackertooltargets, ent ) )
        return false;

    if ( isentityhackableweaponobject( ent ) )
    {
        if ( distancesquared( self.origin, ent.origin ) > level.hackertoolmaxequipmentdistancesq )
            return false;
    }

    return true;
}

hackersoftsighttest()
{
    passed = 1;
    locklengthms = 0;

    if ( isdefined( self.hackertooltarget ) )
        locklengthms = self gethacktime( self.hackertooltarget );

    if ( self isempjammed() || locklengthms == 0 )
    {
        self clearhackertarget();
        passed = 0;
    }
    else if ( iswithinhackertoolreticle( self.hackertooltarget ) )
        self.hackertoollostsightlinetime = 0;
    else
    {
        if ( self.hackertoollostsightlinetime == 0 )
            self.hackertoollostsightlinetime = gettime();

        timepassed = gettime() - self.hackertoollostsightlinetime;

        if ( timepassed >= level.hackertoollostsightlimitms )
        {
            self clearhackertarget();
            passed = 0;
        }
    }

    return passed;
}

registerwithhackertool( radius, hacktimems )
{
    self endon( "death" );

    if ( isdefined( radius ) )
        self.hackertoolradius = radius;
    else
        self.hackertoolradius = level.hackertoollockonradius;

    if ( isdefined( hacktimems ) )
        self.hackertooltimems = hacktimems;
    else
        self.hackertooltimems = level.hackertoolhacktimems;

    self thread watchhackableentitydeath();
    level.hackertooltargets[level.hackertooltargets.size] = self;
}

watchhackableentitydeath()
{
    self waittill( "death" );

    arrayremovevalue( level.hackertooltargets, self );
}

gethackertoolradius( target )
{
    radius = 20;

    if ( isentityhackablecarepackage( target ) )
    {
        assert( isdefined( target.hackertoolradius ) );
        radius = target.hackertoolradius;
    }
    else if ( isentityhackableweaponobject( target ) )
        radius = getweaponobjecthackerradius( target );
    else if ( isdefined( target.hackertoolradius ) )
        radius = target.hackertoolradius;
    else
    {
        radius = level.vehiclehackertoolradius;

        switch ( target.model )
        {
            case "veh_t6_drone_uav":
                radius = level.uavhackertoolradius;
                break;
            case "veh_t6_drone_cuav":
                radius = level.cuavhackertoolradius;
                break;
            case "t5_veh_rcbomb_axis":
                radius = level.rcxdhackertoolradius;
                break;
            case "veh_iw_mh6_littlebird_mp":
                radius = level.carepackagechopperhackertoolradius;
                break;
            case "veh_t6_drone_quad_rotor_mp_alt":
            case "veh_t6_drone_quad_rotor_mp":
                radius = level.qrdronehackertoolradius;
                break;
            case "veh_t6_drone_tank_alt":
            case "veh_t6_drone_tank":
                radius = level.aitankhackertoolradius;
                break;
            case "veh_t6_air_attack_heli_mp_light":
            case "veh_t6_air_attack_heli_mp_dark":
                radius = level.stealthchopperhackertoolradius;
                break;
            case "veh_t6_drone_overwatch_light":
            case "veh_t6_drone_overwatch_dark":
                radius = level.littlebirdhackertoolradius;
                break;
            case "veh_t6_drone_pegasus":
                radius = level.lodestarhackertoolradius;
                break;
            case "veh_iw_air_apache_killstreak":
                radius = level.choppergunnerhackertoolradius;
                break;
            case "veh_t6_air_a10f_alt":
            case "veh_t6_air_a10f":
                radius = level.warthoghackertoolradius;
                break;
        }
    }

    return radius;
}

gethacktime( target )
{
    time = 500;

    if ( isentityhackablecarepackage( target ) )
    {
        assert( isdefined( target.hackertooltimems ) );

        if ( isdefined( target.owner ) && target.owner == self )
            time = level.carepackageownerhackertooltimems;
        else if ( isdefined( target.owner ) && target.owner.team == self.team )
            time = level.carepackagefriendlyhackertooltimems;
        else
            time = level.carepackagehackertooltimems;
    }
    else if ( isentityhackableweaponobject( target ) )
        time = getweaponobjecthacktimems( target );
    else if ( isdefined( target.hackertooltimems ) )
        time = target.hackertooltimems;
    else
    {
        time = level.vehiclehackertooltimems;

        switch ( target.model )
        {
            case "veh_t6_drone_uav":
                time = level.uavhackertooltimems;
                break;
            case "veh_t6_drone_cuav":
                time = level.cuavhackertooltimems;
                break;
            case "t5_veh_rcbomb_axis":
                time = level.rcxdhackertooltimems;
                break;
            case "veh_t6_drone_supply_alt":
            case "veh_t6_drone_supply_alt":
                time = level.carepackagechopperhackertooltimems;
                break;
            case "veh_t6_drone_quad_rotor_mp_alt":
            case "veh_t6_drone_quad_rotor_mp":
                time = level.qrdronehackertooltimems;
                break;
            case "veh_t6_drone_tank_alt":
            case "veh_t6_drone_tank":
                time = level.aitankhackertooltimems;
                break;
            case "veh_t6_air_attack_heli_mp_light":
            case "veh_t6_air_attack_heli_mp_dark":
                time = level.stealthchopperhackertooltimems;
                break;
            case "veh_t6_drone_overwatch_light":
            case "veh_t6_drone_overwatch_dark":
                time = level.littlebirdhackertooltimems;
                break;
            case "veh_t6_drone_pegasus":
                time = level.lodestarhackertooltimems;
                break;
            case "veh_t6_air_v78_vtol_killstreak_alt":
            case "veh_t6_air_v78_vtol_killstreak":
                time = level.choppergunnerhackertooltimems;
                break;
            case "veh_t6_air_a10f_alt":
            case "veh_t6_air_a10f":
                time = level.warthoghackertooltimems;
                break;
        }
    }

    return time;
}

tunables()
{
/#
    while ( true )
    {
        level.hackertoollostsightlimitms = weapons_get_dvar_int( "scr_hackerToolLostSightLimitMs", 1000 );
        level.hackertoollockonradius = weapons_get_dvar( "scr_hackerToolLockOnRadius", 20 );
        level.hackertoollockonfov = weapons_get_dvar_int( "scr_hackerToolLockOnFOV", 65 );
        level.rcxd_time = weapons_get_dvar( "scr_rcxd_time", 1.5 );
        level.uav_time = weapons_get_dvar_int( "scr_uav_time", 4 );
        level.cuav_time = weapons_get_dvar_int( "scr_cuav_time", 4 );
        level.care_package_chopper_time = weapons_get_dvar_int( "scr_care_package_chopper_time", 3 );
        level.guardian_time = weapons_get_dvar_int( "scr_guardian_time", 5 );
        level.sentry_time = weapons_get_dvar_int( "scr_sentry_time", 5 );
        level.wasp_time = weapons_get_dvar_int( "scr_wasp_time", 5 );
        level.agr_time = weapons_get_dvar_int( "scr_agr_time", 5 );
        level.stealth_helicopter_time = weapons_get_dvar_int( "scr_stealth_helicopter_time", 7 );
        level.escort_drone_time = weapons_get_dvar_int( "scr_escort_drone_time", 7 );
        level.warthog_time = weapons_get_dvar_int( "scr_warthog_time", 7 );
        level.lodestar_time = weapons_get_dvar_int( "scr_lodestar_time", 7 );
        level.chopper_gunner_time = weapons_get_dvar_int( "scr_chopper_gunner_time", 7 );
        wait 1.0;
    }
#/
}
