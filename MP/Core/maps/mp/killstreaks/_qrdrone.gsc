// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\_treadfx;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_airsupport;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_heatseekingmissile;
#include maps\mp\gametypes\_spawning;
#include maps\mp\killstreaks\_remote_weapons;
#include maps\mp\_popups;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;
#include maps\mp\gametypes\_hostmigration;
#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_shellshock;
#include maps\mp\killstreaks\_ai_tank;

init()
{
    precachemodel( "veh_t6_drone_quad_rotor_mp" );
    precachemodel( "veh_t6_drone_quad_rotor_mp_alt" );
    precachemodel( "veh_t6_drone_quad_rotor_mp" );
    level.qrdrone_vehicle = "qrdrone_mp";
    precachevehicle( level.qrdrone_vehicle );
    precacheitem( "killstreak_qrdrone_mp" );
    precacheshader( "veh_hud_target" );
    precacheshader( "veh_hud_target_marked" );
    precacheshader( "veh_hud_target_unmarked" );
    precacheshader( "compassping_sentry_enemy" );
    precacheshader( "compassping_enemy_uav" );
    precacheshader( "hud_fofbox_hostile_vehicle" );
    precacheshader( "mp_hud_signal_strong" );
    precacheshader( "mp_hud_signal_failure" );
    precacherumble( "damage_light" );
    precachestring( &"MP_REMOTE_UAV_PLACE" );
    precachestring( &"MP_REMOTE_UAV_CANNOT_PLACE" );
    precachestring( &"SPLASHES_DESTROYED_REMOTE_UAV" );
    precachestring( &"SPLASHES_MARKED_BY_REMOTE_UAV" );
    precachestring( &"SPLASHES_REMOTE_UAV_MARKED" );
    precachestring( &"SPLASHES_TURRET_MARKED_BY_REMOTE_UAV" );
    precachestring( &"SPLASHES_REMOTE_UAV_ASSIST" );
    loadfx( "weapon/qr_drone/fx_qr_light_green_3p" );
    loadfx( "weapon/qr_drone/fx_qr_light_red_3p" );
    loadfx( "weapon/qr_drone/fx_qr_light_green_1p" );
    loadfx( "vehicle/treadfx/fx_heli_quadrotor_dust" );
    level.ai_tank_stun_fx = loadfx( "weapon/talon/fx_talon_emp_stun" );
    level.qrdrone_minigun_flash = loadfx( "weapon/muzzleflashes/fx_muz_mg_flash_3p" );
    level.qrdrone_fx["explode"] = loadfx( "weapon/qr_drone/fx_exp_qr_drone" );
    level._effect["quadrotor_nudge"] = loadfx( "weapon/qr_drone/fx_qr_drone_impact_sparks" );
    level._effect["quadrotor_damage"] = loadfx( "weapon/qr_drone/fx_qr_drone_damage_state" );
    level.qrdrone_dialog["launch"][0] = "ac130_plt_yeahcleared";
    level.qrdrone_dialog["launch"][1] = "ac130_plt_rollinin";
    level.qrdrone_dialog["launch"][2] = "ac130_plt_scanrange";
    level.qrdrone_dialog["out_of_range"][0] = "ac130_plt_cleanup";
    level.qrdrone_dialog["out_of_range"][1] = "ac130_plt_targetreset";
    level.qrdrone_dialog["track"][0] = "ac130_fco_moreenemy";
    level.qrdrone_dialog["track"][1] = "ac130_fco_getthatguy";
    level.qrdrone_dialog["track"][2] = "ac130_fco_guymovin";
    level.qrdrone_dialog["track"][3] = "ac130_fco_getperson";
    level.qrdrone_dialog["track"][4] = "ac130_fco_guyrunnin";
    level.qrdrone_dialog["track"][5] = "ac130_fco_gotarunner";
    level.qrdrone_dialog["track"][6] = "ac130_fco_backonthose";
    level.qrdrone_dialog["track"][7] = "ac130_fco_gonnagethim";
    level.qrdrone_dialog["track"][8] = "ac130_fco_personnelthere";
    level.qrdrone_dialog["track"][9] = "ac130_fco_rightthere";
    level.qrdrone_dialog["track"][10] = "ac130_fco_tracking";
    level.qrdrone_dialog["tag"][0] = "ac130_fco_nice";
    level.qrdrone_dialog["tag"][1] = "ac130_fco_yougothim";
    level.qrdrone_dialog["tag"][2] = "ac130_fco_yougothim2";
    level.qrdrone_dialog["tag"][3] = "ac130_fco_okyougothim";
    level.qrdrone_dialog["assist"][0] = "ac130_fco_goodkill";
    level.qrdrone_dialog["assist"][1] = "ac130_fco_thatsahit";
    level.qrdrone_dialog["assist"][2] = "ac130_fco_directhit";
    level.qrdrone_dialog["assist"][3] = "ac130_fco_rightontarget";
    level.qrdrone_lastdialogtime = 0;
    level.qrdrone_nodeployzones = getentarray( "no_vehicles", "targetname" );
    level._effect["qrdrone_prop"] = loadfx( "weapon/qr_drone/fx_qr_wash_3p" );
    maps\mp\_treadfx::preloadtreadfx( level.qrdrone_vehicle );
/#
    set_dvar_if_unset( "scr_QRDroneFlyTime", 60 );
#/
    shouldtimeout = setdvar( "scr_qrdrone_no_timeout", 0 );
    maps\mp\killstreaks\_killstreaks::registerkillstreak( "qrdrone_mp", "killstreak_qrdrone_mp", "killstreak_qrdrone", "qrdrone_used", ::tryuseqrdrone );
    maps\mp\killstreaks\_killstreaks::registerkillstreakaltweapon( "qrdrone_mp", "qrdrone_turret_mp" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "qrdrone_mp", &"KILLSTREAK_EARNED_QRDRONE", &"KILLSTREAK_QRDRONE_NOT_AVAILABLE", &"KILLSTREAK_QRDRONE_INBOUND" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "qrdrone_mp", "mpl_killstreak_qrdrone", "kls_recondrone_used", "", "kls_recondrone_enemy", "", "kls_recondrone_ready" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdevdvar( "qrdrone_mp", "scr_giveqrdrone" );
    maps\mp\killstreaks\_killstreaks::overrideentitycameraindemo( "qrdrone_mp", 1 );
    registerclientfield( "helicopter", "qrdrone_state", 1, 3, "int" );
}

tryuseqrdrone( lifeid )
{
    if ( self isusingremote() || isdefined( level.nukeincoming ) )
        return 0;

    if ( !self isonground() )
    {
        self iprintlnbold( &"KILLSTREAK_QRDRONE_NOT_PLACEABLE" );
        return 0;
    }

    streakname = "TODO";
    result = self givecarryqrdrone( lifeid, streakname );
    self.iscarrying = 0;
    return result;
}

givecarryqrdrone( lifeid, streakname )
{
    carryqrdrone = createcarryqrdrone( streakname, self );
    self setcarryingqrdrone( carryqrdrone );

    if ( isalive( self ) && isdefined( carryqrdrone ) )
    {
        origin = carryqrdrone.origin;
        angles = self.angles;
        carryqrdrone.soundent delete();
        carryqrdrone delete();
        result = self startqrdrone( lifeid, streakname, origin, angles );
    }
    else
        result = 0;

    return result;
}

createcarryqrdrone( streakname, owner )
{
    pos = owner.origin + anglestoforward( owner.angles ) * 4 + anglestoup( owner.angles ) * 50;
    carryqrdrone = spawnturret( "misc_turret", pos, "auto_gun_turret_mp" );
    carryqrdrone.turrettype = "sentry";
    carryqrdrone setturrettype( carryqrdrone.turrettype );
    carryqrdrone.origin = pos;
    carryqrdrone.angles = owner.angles;
    carryqrdrone.canbeplaced = 1;
    carryqrdrone makeunusable();
    carryqrdrone.owner = owner;
    carryqrdrone setowner( carryqrdrone.owner );
    carryqrdrone.scale = 3;
    carryqrdrone.inheliproximity = 0;
    carryqrdrone thread carryqrdrone_handleexistence();
    carryqrdrone.rangetrigger = getent( "qrdrone_range", "targetname" );

    if ( !isdefined( carryqrdrone.rangetrigger ) )
    {
        carryqrdrone.maxheight = int( maps\mp\killstreaks\_airsupport::getminimumflyheight() );
        carryqrdrone.maxdistance = 3600;
    }

    carryqrdrone.minheight = level.mapcenter[2] - 800;
    carryqrdrone.soundent = spawn( "script_origin", carryqrdrone.origin );
    carryqrdrone.soundent.angles = carryqrdrone.angles;
    carryqrdrone.soundent.origin = carryqrdrone.origin;
    carryqrdrone.soundent linkto( carryqrdrone );
    carryqrdrone.soundent playloopsound( "recondrone_idle_high" );
    return carryqrdrone;
}

watchforattack()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "place_carryQRDrone" );
    self endon( "cancel_carryQRDrone" );

    for (;;)
    {
        wait 0.05;

        if ( self attackbuttonpressed() )
            self notify( "place_carryQRDrone" );
    }
}

setcarryingqrdrone( carryqrdrone )
{
    self endon( "death" );
    self endon( "disconnect" );
    carryqrdrone thread carryqrdrone_setcarried( self );

    if ( !carryqrdrone.canbeplaced )
    {
        if ( self.team != "spectator" )
            self iprintlnbold( &"KILLSTREAK_QRDRONE_NOT_PLACEABLE" );

        if ( isdefined( carryqrdrone.soundent ) )
            carryqrdrone.soundent delete();

        carryqrdrone delete();
        return;
    }

    self.iscarrying = 0;
    carryqrdrone.carriedby = undefined;
    carryqrdrone playsound( "sentry_gun_plant" );
    carryqrdrone notify( "placed" );
}

carryqrdrone_setcarried( carrier )
{
    self setcandamage( 0 );
    self setcontents( 0 );
    self.carriedby = carrier;
    carrier.iscarrying = 1;
    carrier thread updatecarryqrdroneplacement( self );
    self notify( "carried" );
}

isinremotenodeploy()
{
    if ( isdefined( level.qrdrone_nodeployzones ) && level.qrdrone_nodeployzones.size )
    {
        foreach ( zone in level.qrdrone_nodeployzones )
        {
            if ( self istouching( zone ) )
                return true;
        }
    }

    return false;
}

updatecarryqrdroneplacement( carryqrdrone )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    carryqrdrone endon( "placed" );
    carryqrdrone endon( "death" );
    carryqrdrone.canbeplaced = 1;
    lastcanplacecarryqrdrone = -1;

    for (;;)
    {
        heightoffset = 18;

        switch ( self getstance() )
        {
            case "stand":
                heightoffset = 40;
                break;
            case "crouch":
                heightoffset = 25;
                break;
            case "prone":
                heightoffset = 10;
                break;
        }

        placement = self canplayerplacevehicle( 22, 22, 50, heightoffset, 0, 0 );
        carryqrdrone.origin = placement["origin"] + anglestoup( self.angles ) * 27;
        carryqrdrone.angles = placement["angles"];
        carryqrdrone.canbeplaced = self isonground() && placement["result"] && carryqrdrone qrdrone_in_range() && !carryqrdrone isinremotenodeploy();

        if ( carryqrdrone.canbeplaced != lastcanplacecarryqrdrone )
        {
            if ( carryqrdrone.canbeplaced )
            {
                if ( self attackbuttonpressed() )
                    self notify( "place_carryQRDrone" );
            }
            else
            {

            }
        }

        lastcanplacecarryqrdrone = carryqrdrone.canbeplaced;
        wait 0.05;
    }
}

carryqrdrone_handleexistence()
{
    level endon( "game_ended" );
    self endon( "death" );
    self.owner endon( "place_carryQRDrone" );
    self.owner endon( "cancel_carryQRDrone" );
    self.owner waittill_any( "death", "disconnect", "joined_team", "joined_spectators" );

    if ( isdefined( self ) )
        self delete();
}

removeremoteweapon()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    wait 0.7;
}

startqrdrone( lifeid, streakname, origin, angles )
{
    self lockplayerforqrdronelaunch();
    self setusingremote( streakname );
    self freezecontrolswrapper( 1 );
    result = self maps\mp\killstreaks\_killstreaks::initridekillstreak( "qrdrone" );

    if ( result != "success" || level.gameended )
    {
        if ( result != "disconnect" )
        {
            self freezecontrolswrapper( 0 );
            self maps\mp\killstreaks\_killstreakrules::iskillstreakallowed( "qrdrone_mp", self.team );
            self notify( "qrdrone_unlock" );
            self clearusingremote();
        }

        return false;
    }

    team = self.team;
    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( "qrdrone_mp", team, 0, 1 );

    if ( killstreak_id == -1 )
    {
        self notify( "qrdrone_unlock" );
        self freezecontrolswrapper( 0 );
        self clearusingremote();
        return false;
    }

    self notify( "qrdrone_unlock" );
    qrdrone = createqrdrone( lifeid, self, streakname, origin, angles, killstreak_id );
    self freezecontrolswrapper( 0 );

    if ( isdefined( qrdrone ) )
    {
        self thread qrdrone_ride( lifeid, qrdrone, streakname );

        qrdrone waittill( "end_remote" );

        maps\mp\killstreaks\_killstreakrules::killstreakstop( "qrdrone_mp", team, killstreak_id );
        return true;
    }
    else
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        self clearusingremote();
        maps\mp\killstreaks\_killstreakrules::killstreakstop( "qrdrone_mp", team, killstreak_id );
        return false;
    }
}

lockplayerforqrdronelaunch()
{
    lockspot = spawn( "script_origin", self.origin );
    lockspot hide();
    self playerlinkto( lockspot );
    self thread clearplayerlockfromqrdronelaunch( lockspot );
}

clearplayerlockfromqrdronelaunch( lockspot )
{
    level endon( "game_ended" );
    msg = self waittill_any_return( "disconnect", "death", "qrdrone_unlock" );
    lockspot delete();
}

createqrdrone( lifeid, owner, streakname, origin, angles, killstreak_id )
{
    qrdrone = spawnhelicopter( owner, origin, angles, level.qrdrone_vehicle, "veh_t6_drone_quad_rotor_mp" );

    if ( !isdefined( qrdrone ) )
        return undefined;

    qrdrone.lifeid = lifeid;
    qrdrone.team = owner.team;
    qrdrone.pers["team"] = owner.team;
    qrdrone.owner = owner;
    qrdrone.health = 999999;
    qrdrone.maxhealth = 250;
    qrdrone.damagetaken = 0;
    qrdrone.destroyed = 0;
    qrdrone setcandamage( 1 );
    qrdrone enableaimassist();
    qrdrone.smoking = 0;
    qrdrone.inheliproximity = 0;
    qrdrone.helitype = "qrdrone";
    qrdrone.markedplayers = [];
    qrdrone.isstunned = 0;
    qrdrone setenemymodel( "veh_t6_drone_quad_rotor_mp_alt" );
    qrdrone setdrawinfrared( 1 );
    qrdrone.killcament = qrdrone.owner;
    owner maps\mp\gametypes\_weaponobjects::addweaponobjecttowatcher( "qrdrone", qrdrone );
    qrdrone thread qrdrone_explode_on_notify( killstreak_id );
    qrdrone thread qrdrone_explode_on_game_end();
    qrdrone thread qrdrone_leave_on_timeout();
    qrdrone thread qrdrone_watch_distance();
    qrdrone thread qrdrone_watch_for_exit();
    qrdrone thread deleteonkillbrush( owner );
    target_set( qrdrone, ( 0, 0, 0 ) );
    target_setturretaquire( qrdrone, 0 );
    qrdrone.numflares = 0;
    qrdrone.flareoffset = vectorscale( ( 0, 0, -1 ), 100.0 );
    qrdrone thread maps\mp\_heatseekingmissile::missiletarget_lockonmonitor( self, "end_remote" );
    qrdrone thread maps\mp\_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "crashing" );
    qrdrone.emp_fx = spawn( "script_model", self.origin );
    qrdrone.emp_fx setmodel( "tag_origin" );
    qrdrone.emp_fx linkto( self, "tag_origin", vectorscale( ( 0, 0, -1 ), 20.0 ) + anglestoforward( self.angles ) * 6 );
    qrdrone maps\mp\gametypes\_spawning::create_qrdrone_influencers( qrdrone.team );
    return qrdrone;
}

qrdrone_ride( lifeid, qrdrone, streakname )
{
    self.killstreak_waitamount = qrdrone.flytime * 1000;
    qrdrone.playerlinked = 1;
    self.restoreangles = self.angles;
    qrdrone usevehicle( self, 0 );
    self clientnotify( "qrfutz" );
    self maps\mp\killstreaks\_killstreaks::playkillstreakstartdialog( "qrdrone_mp", self.pers["team"] );
    level.globalkillstreakscalled++;
    self addweaponstat( "killstreak_qrdrone_mp", "used", 1 );
    self.qrdrone_ridelifeid = lifeid;
    self.qrdrone = qrdrone;
    self thread qrdrone_delaylaunchdialog( qrdrone );
    self thread qrdrone_fireguns( qrdrone );
    qrdrone thread play_lockon_sounds( self );

    if ( isdefined( level.qrdrone_vision ) )
        self setvisionsetwaiter();
}

qrdrone_delaylaunchdialog( qrdrone )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    qrdrone endon( "death" );
    qrdrone endon( "end_remote" );
    qrdrone endon( "end_launch_dialog" );
    wait 3;
    self qrdrone_dialog( "launch" );
}

qrdrone_unlink( qrdrone )
{
    if ( isdefined( qrdrone ) )
    {
        qrdrone.playerlinked = 0;
        self destroyhud();

        if ( isdefined( self.viewlockedentity ) )
        {
            self unlink();

            if ( isdefined( level.gameended ) && level.gameended )
                self freezecontrolswrapper( 1 );
        }
    }
}

qrdrone_endride( qrdrone )
{
    if ( isdefined( qrdrone ) )
    {
        qrdrone notify( "end_remote" );
        self clearusingremote();

        if ( level.gameended == 0 )
            self.killstreak_waitamount = undefined;

        self setplayerangles( self.restoreangles );

        if ( isalive( self ) )
            self switchtoweapon( self getlastweapon() );

        self thread qrdrone_freezebuffer();
    }

    self.qrdrone = undefined;
}

play_lockon_sounds( player )
{
    player endon( "disconnect" );
    self endon( "death" );
    self endon( "blowup" );
    self endon( "crashing" );
    level endon( "game_ended" );
    self endon( "end_remote" );
    self.locksounds = spawn( "script_model", self.origin );
    wait 0.1;
    self.locksounds linkto( self, "tag_player" );

    while ( true )
    {
        self waittill( "locking on" );

        while ( true )
        {
            if ( enemy_locking() )
            {
                self.locksounds playsoundtoplayer( "uin_alert_lockon", player );
                wait 0.125;
            }

            if ( enemy_locked() )
            {
                self.locksounds playsoundtoplayer( "uin_alert_lockon", player );
                wait 0.125;
            }

            if ( !enemy_locking() && !enemy_locked() )
            {
                self.locksounds stopsounds();
                break;
            }
        }
    }
}

enemy_locking()
{
    if ( isdefined( self.locking_on ) && self.locking_on )
        return true;

    return false;
}

enemy_locked()
{
    if ( isdefined( self.locked_on ) && self.locked_on )
        return true;

    return false;
}

qrdrone_freezebuffer()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    self freezecontrolswrapper( 1 );
    wait 0.5;
    self freezecontrolswrapper( 0 );
}

qrdrone_playerexit( qrdrone )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    qrdrone endon( "death" );
    qrdrone endon( "end_remote" );
    wait 2;

    while ( true )
    {
        timeused = 0;

        while ( self usebuttonpressed() )
        {
            timeused += 0.05;

            if ( timeused > 0.75 )
            {
                qrdrone thread qrdrone_leave();
                return;
            }

            wait 0.05;
        }

        wait 0.05;
    }
}

touchedkillbrush()
{
    if ( isdefined( self ) )
    {
        self setclientfield( "qrdrone_state", 3 );
        watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
        watcher thread waitanddetonate( self, 0.0 );
    }
}

deleteonkillbrush( player )
{
    player endon( "disconnect" );
    self endon( "death" );
    killbrushes = [];
    hurt = getentarray( "trigger_hurt", "classname" );

    foreach ( trig in hurt )
    {
        if ( trig.origin[2] <= player.origin[2] && ( !isdefined( trig.script_parameters ) || trig.script_parameters != "qrdrone_safe" ) )
            killbrushes[killbrushes.size] = trig;
    }

    crate_triggers = getentarray( "crate_kill_trigger", "targetname" );

    while ( true )
    {
        for ( i = 0; i < killbrushes.size; i++ )
        {
            if ( self istouching( killbrushes[i] ) )
            {
                self touchedkillbrush();
                return;
            }
        }

        foreach ( trigger in crate_triggers )
        {
            if ( trigger.active && self istouching( trigger ) )
            {
                self touchedkillbrush();
                return;
            }
        }

        if ( isdefined( level.levelkillbrushes ) )
        {
            foreach ( trigger in level.levelkillbrushes )
            {
                if ( self istouching( trigger ) )
                {
                    self touchedkillbrush();
                    return;
                }
            }
        }

        if ( level.script == "mp_castaway" )
        {
            origin = self.origin - vectorscale( ( 0, 0, 1 ), 12.0 );
            water = getwaterheight( origin );

            if ( water - origin[2] > 0 )
            {
                self touchedkillbrush();
                return;
            }
        }

        wait 0.1;
    }
}

qrdrone_force_destroy()
{
    self setclientfield( "qrdrone_state", 3 );
    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
    watcher thread waitanddetonate( self, 0.0 );
}

qrdrone_get_damage_effect( health_pct )
{
    if ( health_pct > 0.5 )
        return level._effect["quadrotor_damage"];

    return undefined;
}

qrdrone_play_single_fx_on_tag( effect, tag )
{
    if ( isdefined( self.damage_fx_ent ) )
    {
        if ( self.damage_fx_ent.effect == effect )
            return;

        self.damage_fx_ent delete();
    }

    playfxontag( effect, self, "tag_origin" );
}

qrdrone_update_damage_fx( health_percent )
{
    effect = qrdrone_get_damage_effect( health_percent );

    if ( isdefined( effect ) )
        qrdrone_play_single_fx_on_tag( effect, "tag_origin" );
    else if ( isdefined( self.damage_fx_ent ) )
        self.damage_fx_ent delete();
}

qrdrone_damagewatcher()
{
    self endon( "death" );
    self.maxhealth = 999999;
    self.health = self.maxhealth;
    self.maxhealth = 225;
    low_health = 0;
    damage_taken = 0;

    for (;;)
    {
        self waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;

        self.owner playrumbleonentity( "damage_heavy" );
/#
        self.damage_debug = damage + " (" + weapon + ")";
#/
        if ( mod == "MOD_RIFLE_BULLET" || mod == "MOD_PISTOL_BULLET" )
        {
            if ( isplayer( attacker ) )
            {
                if ( attacker hasperk( "specialty_armorpiercing" ) )
                    damage += int( damage * level.cac_armorpiercing_data );
            }

            if ( weaponclass( weapon ) == "spread" )
                damage *= 2;
        }

        if ( weapon == "emp_grenade_mp" && mod == "MOD_GRENADE_SPLASH" )
        {
            damage_taken += 225;
            damage = 0;
        }

        if ( !self.isstunned )
        {
            if ( ( weapon == "proximity_grenade_mp" || weapon == "proximity_grenade_aoe_mp" ) && ( mod == "MOD_GRENADE_SPLASH" || mod == "MOD_GAS" ) )
            {
                self.isstunned = 1;
                self qrdrone_stun( 2 );
            }
        }

        self.attacker = attacker;
        self.owner sendkillstreakdamageevent( int( damage ) );
        damage_taken += damage;

        if ( damage_taken >= 225 )
        {
            self.owner sendkillstreakdamageevent( 200 );
            self qrdrone_death( attacker, weapon, dir, mod );
            return;
        }
        else
            qrdrone_update_damage_fx( float( damage_taken ) / 225 );
    }
}

qrdrone_stun( duration )
{
    self endon( "death" );
    self notify( "stunned" );
    self.owner freezecontrolswrapper( 1 );

    if ( isdefined( self.owner.fullscreen_static ) )
        self.owner thread maps\mp\killstreaks\_remote_weapons::stunstaticfx( duration );

    wait( duration );
    self.owner freezecontrolswrapper( 0 );
    self.isstunned = 0;
}

qrdrone_death( attacker, weapon, dir, damagetype )
{
    if ( isdefined( self.damage_fx_ent ) )
        self.damage_fx_ent delete();

    if ( isdefined( attacker ) && isplayer( attacker ) && attacker != self.owner )
    {
        level thread maps\mp\_popups::displayteammessagetoall( &"SCORE_DESTROYED_QRDRONE", attacker );

        if ( self.owner isenemyplayer( attacker ) )
        {
            attacker maps\mp\_challenges::destroyedqrdrone( damagetype, weapon );
            maps\mp\_scoreevents::processscoreevent( "destroyed_qrdrone", attacker, self.owner, weapon );
            attacker addweaponstat( weapon, "destroyed_qrdrone", 1 );
            attacker maps\mp\_challenges::addflyswatterstat( weapon, self );
            attacker addweaponstat( weapon, "destroyed_controlled_killstreak", 1 );
        }
        else
        {

        }
    }

    self thread qrdrone_crash_movement( attacker, dir );

    if ( weapon == "emp_grenade_mp" )
        playfxontag( level.ai_tank_stun_fx, self.emp_fx, "tag_origin" );

    self waittill( "crash_done" );

    if ( isdefined( self.emp_fx ) )
        self.emp_fx delete();

    self setclientfield( "qrdrone_state", 3 );
    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
    watcher thread waitanddetonate( self, 0.0, attacker, weapon );
}

death_fx()
{
    playfxontag( self.deathfx, self, self.deathfxtag );
    self playsound( "veh_qrdrone_sparks" );
}

qrdrone_crash_movement( attacker, hitdir )
{
    self endon( "crash_done" );
    self endon( "death" );
    self notify( "crashing" );
    self takeplayercontrol();
    self setmaxpitchroll( 90, 180 );
    self setphysacceleration( vectorscale( ( 0, 0, -1 ), 800.0 ) );
    side_dir = vectorcross( hitdir, ( 0, 0, 1 ) );
    side_dir_mag = randomfloatrange( -100, 100 );
    side_dir_mag += sign( side_dir_mag ) * 80;
    side_dir *= side_dir_mag;
    velocity = self getvelocity();
    self setvehvelocity( velocity + vectorscale( ( 0, 0, 1 ), 100.0 ) + vectornormalize( side_dir ) );
    ang_vel = self getangularvelocity();
    ang_vel = ( ang_vel[0] * 0.3, ang_vel[1], ang_vel[2] * 0.3 );
    yaw_vel = randomfloatrange( 0, 210 ) * sign( ang_vel[1] );
    yaw_vel += sign( yaw_vel ) * 180;
    ang_vel += ( randomfloatrange( -100, 100 ), yaw_vel, randomfloatrange( -200, 200 ) );
    self setangularvelocity( ang_vel );
    self.crash_accel = randomfloatrange( 75, 110 );
    self thread qrdrone_crash_accel();
    self thread qrdrone_collision();
    self playsound( "veh_qrdrone_dmg_hit" );
    self thread qrdrone_dmg_snd();
    wait 0.1;

    if ( randomint( 100 ) < 40 )
        self thread qrdrone_fire_for_time( randomfloatrange( 0.7, 2.0 ) );

    wait 2;
    self notify( "crash_done" );
}

qrdrone_dmg_snd()
{
    dmg_ent = spawn( "script_origin", self.origin );
    dmg_ent linkto( self );
    dmg_ent playloopsound( "veh_qrdrone_dmg_loop" );
    self waittill_any( "crash_done", "death" );
    dmg_ent stoploopsound( 0.2 );
    wait 2;
    dmg_ent delete();
}

qrdrone_fire_for_time( totalfiretime )
{
    self endon( "crash_done" );
    self endon( "change_state" );
    self endon( "death" );
    weaponname = self seatgetweapon( 0 );
    firetime = weaponfiretime( weaponname );
    time = 0;
    firecount = 1;

    while ( time < totalfiretime )
    {
        self fireweapon( undefined, undefined, firecount % 2 );
        firecount++;
        wait( firetime );
        time += firetime;
    }
}

qrdrone_crash_accel()
{
    self endon( "crash_done" );
    self endon( "death" );
    count = 0;

    while ( true )
    {
        velocity = self getvelocity();
        self setvehvelocity( velocity + anglestoup( self.angles ) * self.crash_accel );
        self.crash_accel *= 0.98;
        wait 0.1;
        count++;

        if ( count % 8 == 0 )
        {
            if ( randomint( 100 ) > 40 )
            {
                if ( velocity[2] > 150.0 )
                    self.crash_accel *= 0.75;
                else if ( velocity[2] < 40.0 && count < 60 )
                {
                    if ( abs( self.angles[0] ) > 30 || abs( self.angles[2] ) > 30 )
                        self.crash_accel = randomfloatrange( 160, 200 );
                    else
                        self.crash_accel = randomfloatrange( 85, 120 );
                }
            }
        }
    }
}

qrdrone_collision()
{
    self endon( "crash_done" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "veh_collision", velocity, normal );

        ang_vel = self getangularvelocity() * 0.5;
        self setangularvelocity( ang_vel );
        velocity = self getvelocity();

        if ( normal[2] < 0.7 )
        {
            self setvehvelocity( velocity + normal * 70 );
            self playsound( "veh_qrdrone_wall" );
            playfx( level._effect["quadrotor_nudge"], self.origin );
        }
        else
        {
            self playsound( "veh_qrdrone_explo" );
            self notify( "crash_done" );
        }
    }
}

qrdrone_watch_distance()
{
    self endon( "death" );
    self.owner inithud();
    qrdrone_height = getstruct( "qrdrone_height", "targetname" );

    if ( isdefined( qrdrone_height ) )
        self.maxheight = qrdrone_height.origin[2];
    else
        self.maxheight = int( maps\mp\killstreaks\_airsupport::getminimumflyheight() );

    self.maxdistance = 12800;
    self.minheight = level.mapcenter[2] - 800;
    self.centerref = spawn( "script_model", level.mapcenter );
    inrangepos = self.origin;
    self.rangecountdownactive = 0;

    while ( true )
    {
        if ( !self qrdrone_in_range() )
        {
            staticalpha = 0;

            while ( !self qrdrone_in_range() )
            {
                if ( !self.rangecountdownactive )
                {
                    self.rangecountdownactive = 1;
                    self thread qrdrone_rangecountdown();
                }

                if ( isdefined( self.heliinproximity ) )
                {
                    dist = distance( self.origin, self.heliinproximity.origin );
                    staticalpha = 1 - ( dist - 150 ) / 150;
                }
                else
                {
                    dist = distance( self.origin, inrangepos );
                    staticalpha = min( 0.7, dist / 200 );
                }

                self.owner set_static_alpha( staticalpha, self );
                wait 0.05;
            }

            self notify( "in_range" );
            self.rangecountdownactive = 0;
            self thread qrdrone_staticfade( staticalpha );
        }

        inrangepos = self.origin;
        wait 0.05;
    }
}

qrdrone_in_range()
{
    if ( self.origin[2] < self.maxheight && self.origin[2] > self.minheight && !self.inheliproximity )
    {
        if ( self ismissileinsideheightlock() )
            return true;
    }

    return false;
}

qrdrone_staticfade( staticalpha )
{
    self endon( "death" );

    while ( self qrdrone_in_range() )
    {
        staticalpha -= 0.05;

        if ( staticalpha < 0 )
        {
            self.owner set_static_alpha( staticalpha, self );
            break;
        }

        self.owner set_static_alpha( staticalpha, self );
        wait 0.05;
    }
}

qrdrone_rangecountdown()
{
    self endon( "death" );
    self endon( "in_range" );

    if ( isdefined( self.heliinproximity ) )
        countdown = 6.1;
    else
        countdown = 6.1;

    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( countdown );
    self setclientfield( "qrdrone_state", 3 );
    self.owner notify( "stop_signal_failure" );
    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0 );
}

qrdrone_explode_on_notify( killstreak_id )
{
    self endon( "death" );
    self endon( "end_ride" );
    self.owner waittill_any( "disconnect", "joined_team", "joined_spectators" );

    if ( isdefined( self.owner ) )
    {
        self.owner clearusingremote();
        self.owner destroyhud();
        self.owner.killstreak_waitamount = 0;
        self.owner qrdrone_endride( self );
    }
    else
        maps\mp\killstreaks\_killstreakrules::killstreakstop( "qrdrone_mp", self.team, killstreak_id );

    self setclientfield( "qrdrone_state", 3 );
    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0 );
}

qrdrone_explode_on_game_end()
{
    self endon( "death" );

    level waittill( "game_ended" );

    self setclientfield( "qrdrone_state", 3 );
    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
    watcher maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0 );
    self.owner qrdrone_endride( self );
}

qrdrone_leave_on_timeout()
{
    self endon( "death" );

    if ( !level.vehiclestimed )
        return;

    self.flytime = 60.0;
    waittime = self.flytime - 10;
/#
    set_dvar_int_if_unset( "scr_QRDroneFlyTime", self.flytime );
    self.flytime = getdvarint( "scr_QRDroneFlyTime" );
    waittime = self.flytime - 10;

    if ( waittime < 0 )
    {
        wait( self.flytime );
        self setclientfield( "qrdrone_state", 3 );
        watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
        watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0 );
        return;
    }
#/
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( waittime );
    shouldtimeout = getdvar( "scr_qrdrone_no_timeout" );

    if ( shouldtimeout == "1" )
        return;

    self setclientfield( "qrdrone_state", 1 );
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( 6 );
    self setclientfield( "qrdrone_state", 2 );
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( 4 );
    self setclientfield( "qrdrone_state", 3 );
    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0 );
}

qrdrone_leave()
{
    level endon( "game_ended" );
    self endon( "death" );
    self notify( "leaving" );
    self.owner qrdrone_unlink( self );
    self.owner qrdrone_endride( self );
    self notify( "death" );
}

qrdrone_exit_button_pressed()
{
    return self usebuttonpressed();
}

qrdrone_watch_for_exit()
{
    level endon( "game_ended" );
    self endon( "death" );
    self.owner endon( "disconnect" );
    wait 1;

    while ( true )
    {
        timeused = 0;

        while ( self.owner qrdrone_exit_button_pressed() )
        {
            timeused += 0.05;

            if ( timeused > 0.25 )
            {
                self setclientfield( "qrdrone_state", 3 );
                watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
                watcher thread waitanddetonate( self, 0.0, self.owner );
                return;
            }

            wait 0.05;
        }

        wait 0.05;
    }
}

qrdrone_cleanup()
{
    if ( level.gameended )
        return;

    if ( isdefined( self.owner ) )
    {
        if ( self.playerlinked == 1 )
            self.owner qrdrone_unlink( self );

        self.owner qrdrone_endride( self );
    }

    if ( isdefined( self.scrambler ) )
        self.scrambler delete();

    if ( isdefined( self ) && isdefined( self.centerref ) )
        self.centerref delete();

    target_setturretaquire( self, 0 );

    if ( isdefined( self.damage_fx_ent ) )
        self.damage_fx_ent delete();

    if ( isdefined( self.emp_fx ) )
        self.emp_fx delete();

    self delete();
}

qrdrone_light_fx()
{
    playfxontag( level.chopper_fx["light"]["belly"], self, "tag_light_nose" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["tail"], self, "tag_light_tail1" );
}

qrdrone_dialog( dialoggroup )
{
    if ( dialoggroup == "tag" )
        waittime = 1000;
    else
        waittime = 5000;

    if ( gettime() - level.qrdrone_lastdialogtime < waittime )
        return;

    level.qrdrone_lastdialogtime = gettime();
    randomindex = randomint( level.qrdrone_dialog[dialoggroup].size );
    soundalias = level.qrdrone_dialog[dialoggroup][randomindex];
    self playlocalsound( soundalias );
}

qrdrone_watchheliproximity()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "end_remote" );

    while ( true )
    {
        inheliproximity = 0;

        if ( !self.inheliproximity && inheliproximity )
            self.inheliproximity = 1;
        else if ( self.inheliproximity && !inheliproximity )
        {
            self.inheliproximity = 0;
            self.heliinproximity = undefined;
        }

        wait 0.05;
    }
}

qrdrone_detonatewaiter()
{
    self.owner endon( "disconnect" );
    self endon( "death" );

    while ( self.owner attackbuttonpressed() )
        wait 0.05;

    watcher = self.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );

    while ( !self.owner attackbuttonpressed() )
        wait 0.05;

    self setclientfield( "qrdrone_state", 3 );
    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0 );
    self.owner thread maps\mp\gametypes\_hud::fadetoblackforxsec( getdvarfloat( _hash_CDE26736 ), getdvarfloat( _hash_AFCAD5CD ), getdvarfloat( _hash_88490433 ), getdvarfloat( _hash_A925AA4E ) );
}

qrdrone_fireguns( qrdrone )
{
    self endon( "disconnect" );
    qrdrone endon( "death" );
    qrdrone endon( "blowup" );
    qrdrone endon( "crashing" );
    level endon( "game_ended" );
    qrdrone endon( "end_remote" );
    wait 1;

    while ( true )
    {
        if ( self attackbuttonpressed() )
        {
            qrdrone fireweapon( "tag_flash" );
            firetime = weaponfiretime( "qrdrone_turret_mp" );
            wait( firetime );
        }
        else
            wait 0.05;
    }
}

qrdrone_blowup( attacker, weaponname )
{
    self.owner endon( "disconnect" );
    self endon( "death" );
    self notify( "blowup" );
    explosionorigin = self.origin;
    explosionangles = self.angles;

    if ( !isdefined( attacker ) )
        attacker = self.owner;

    origin = self.origin + vectorscale( ( 0, 0, 1 ), 10.0 );
    radius = 256;
    min_damage = 10;
    max_damage = 35;

    if ( isdefined( attacker ) )
        self radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_EXPLOSIVE", "qrdrone_turret_mp" );

    physicsexplosionsphere( origin, radius, radius, 1, max_damage, min_damage );
    maps\mp\gametypes\_shellshock::rcbomb_earthquake( origin );
    playsoundatposition( "veh_qrdrone_explo", self.origin );
    playfx( level.qrdrone_fx["explode"], explosionorigin, ( 0, 0, 1 ) );
    self hide();

    if ( isdefined( self.owner ) )
    {
        self.owner clientnotify( "qrdrone_blowup" );

        if ( attacker != self.owner )
        {
            if ( isdefined( weaponname ) )
            {
                weaponstatname = "destroyed";

                switch ( weaponname )
                {
                    case "tow_turret_mp":
                    case "tow_turret_drop_mp":
                    case "auto_tow_mp":
                        weaponstatname = "kills";
                        break;
                }

                attacker addweaponstat( weaponname, weaponstatname, 1 );
                level.globalkillstreaksdestroyed++;
                attacker addweaponstat( "qrdrone_turret_mp", "destroyed", 1 );
            }
        }

        self.owner maps\mp\killstreaks\_ai_tank::destroy_remote_hud();
        self.owner freezecontrolswrapper( 1 );
        self.owner sendkillstreakdamageevent( 600 );
        wait 0.75;
        self.owner thread maps\mp\gametypes\_hud::fadetoblackforxsec( 0, 0.25, 0.1, 0.25 );
        wait 0.25;
        self.owner qrdrone_unlink( self );
        self.owner freezecontrolswrapper( 0 );

        if ( isdefined( self.neverdelete ) && self.neverdelete )
            return;
    }

    qrdrone_cleanup();
}

setvisionsetwaiter()
{
    self endon( "disconnect" );
    self useservervisionset( 1 );
    self setvisionsetforplayer( level.qrdrone_vision, 1 );

    self.qrdrone waittill( "end_remote" );

    self useservervisionset( 0 );
}

inithud()
{
    self.leaving_play_area = newclienthudelem( self );
    self.leaving_play_area.fontscale = 1.25;
    self.leaving_play_area.x = 24;
    self.leaving_play_area.y = -44;
    self.leaving_play_area.alignx = "right";
    self.leaving_play_area.aligny = "bottom";
    self.leaving_play_area.horzalign = "user_right";
    self.leaving_play_area.vertalign = "user_bottom";
    self.leaving_play_area.hidewhendead = 0;
    self.leaving_play_area.hidewheninmenu = 0;
    self.leaving_play_area.immunetodemogamehudsettings = 1;
    self.leaving_play_area.archived = 0;
    self.leaving_play_area.alpha = 0.7;
    self.leaving_play_area setshader( "mp_hud_signal_strong", 160, 80 );
}

destroyhud()
{
    if ( isdefined( self ) )
    {
        self notify( "stop_signal_failure" );
        self.flashingsignalfailure = 0;

        if ( isdefined( self.leaving_play_area ) )
            self.leaving_play_area destroy();

        if ( isdefined( self.fullscreen_static ) )
            self.fullscreen_static destroy();

        self maps\mp\killstreaks\_ai_tank::destroy_remote_hud();
        self clientnotify( "nofutz" );
    }
}

set_static_alpha( alpha, drone )
{
    if ( isdefined( self.fullscreen_static ) )
        self.fullscreen_static.alpha = alpha;

    if ( isdefined( self.leaving_play_area ) )
    {
        if ( alpha > 0 )
        {
            if ( !isdefined( self.flashingsignalfailure ) || !self.flashingsignalfailure )
            {
                self thread flash_signal_failure( drone );
                self.flashingsignalfailure = 1;
            }
        }
        else
        {
            self notify( "stop_signal_failure" );
            self.leaving_play_area setshader( "mp_hud_signal_strong", 160, 80 );
            self.leaving_play_area.alpha = 0.7;
            self.flashingsignalfailure = 0;
        }
    }
}

flash_signal_failure( drone )
{
    self endon( "stop_signal_failure" );
    self.leaving_play_area setshader( "mp_hud_signal_failure", 160, 80 );
    i = 0;

    for (;;)
    {
        self.leaving_play_area.alpha = 1;
        drone playsoundtoplayer( "uin_alert_lockon", self );

        if ( i < 6 )
            wait 0.4;
        else
            wait 0.2;

        self.leaving_play_area.alpha = 0;

        if ( i < 5 )
            wait 0.2;
        else
            wait 0.1;

        i++;
    }
}
