// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\gametypes_zm\_gameobjects;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_chugabud;
#include maps\mp\zombies\_zm_perks;

laststand_global_init()
{
    level.const_laststand_getup_count_start = 0;
    level.const_laststand_getup_bar_start = 0.5;
    level.const_laststand_getup_bar_regen = 0.0025;
    level.const_laststand_getup_bar_damage = 0.1;
}

init()
{
    if ( level.script == "frontend" )
        return;

    laststand_global_init();
    level.revive_tool = "syrette_zm";
    precacheitem( level.revive_tool );
    precachestring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
    precachestring( &"ZOMBIE_PLAYER_NEEDS_TO_BE_REVIVED" );
    precachestring( &"ZOMBIE_PLAYER_IS_REVIVING_YOU" );
    precachestring( &"ZOMBIE_REVIVING" );

    if ( !isdefined( level.laststandpistol ) )
    {
        level.laststandpistol = "m1911";
        precacheitem( level.laststandpistol );
    }

    level thread revive_hud_think();
    level.primaryprogressbarx = 0;
    level.primaryprogressbary = 110;
    level.primaryprogressbarheight = 4;
    level.primaryprogressbarwidth = 120;
    level.primaryprogressbary_ss = 280;

    if ( getdvar( _hash_A17166B0 ) == "" )
        setdvar( "revive_trigger_radius", "40" );

    level.laststandgetupallowed = 0;
}

player_is_in_laststand()
{
    if ( !( isdefined( self.no_revive_trigger ) && self.no_revive_trigger ) )
        return isdefined( self.revivetrigger );
    else
        return isdefined( self.laststand ) && self.laststand;
}

player_num_in_laststand()
{
    num = 0;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] player_is_in_laststand() )
            num++;
    }

    return num;
}

player_all_players_in_laststand()
{
    return player_num_in_laststand() == get_players().size;
}

player_any_player_in_laststand()
{
    return player_num_in_laststand() > 0;
}

player_last_stand_stats( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( isdefined( attacker ) && isplayer( attacker ) && attacker != self )
    {
        if ( "zcleansed" == level.gametype )
            maps\mp\_demo::bookmark( "kill", gettime(), self, attacker, 0, einflictor );

        if ( "zcleansed" == level.gametype )
        {
            if ( isdefined( attacker.is_zombie ) && !attacker.is_zombie )
                attacker.kills++;
            else
                attacker.downs++;
        }
        else
            attacker.kills++;

        attacker maps\mp\zombies\_zm_stats::increment_client_stat( "kills" );
        attacker maps\mp\zombies\_zm_stats::increment_player_stat( "kills" );

        if ( isdefined( sweapon ) )
        {
            dmgweapon = sweapon;

            if ( is_alt_weapon( dmgweapon ) )
                dmgweapon = weaponaltweaponname( dmgweapon );

            attacker addweaponstat( dmgweapon, "kills", 1 );
        }

        if ( is_headshot( sweapon, shitloc, smeansofdeath ) )
        {
            attacker.headshots++;
            attacker maps\mp\zombies\_zm_stats::increment_client_stat( "headshots" );
            attacker addweaponstat( sweapon, "headshots", 1 );
            attacker maps\mp\zombies\_zm_stats::increment_player_stat( "headshots" );
        }
    }

    self increment_downed_stat();

    if ( flag( "solo_game" ) && !self.lives && getnumconnectedplayers() < 2 )
    {
        self maps\mp\zombies\_zm_stats::increment_client_stat( "deaths" );
        self maps\mp\zombies\_zm_stats::increment_player_stat( "deaths" );
        self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
    }
}

increment_downed_stat()
{
    if ( "zcleansed" != level.gametype )
        self.downs++;

    self maps\mp\zombies\_zm_stats::increment_client_stat( "downs" );
    self add_weighted_down();
    self maps\mp\zombies\_zm_stats::increment_player_stat( "downs" );
    zonename = self get_current_zone();

    if ( !isdefined( zonename ) )
        zonename = "";

    self recordplayerdownzombies( zonename );
}

playerlaststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    self notify( "entering_last_stand" );

    if ( isdefined( level._game_module_player_laststand_callback ) )
        self [[ level._game_module_player_laststand_callback ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );

    if ( self player_is_in_laststand() )
        return;

    if ( isdefined( self.in_zombify_call ) && self.in_zombify_call )
        return;

    self thread player_last_stand_stats( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );

    if ( isdefined( level.playerlaststand_func ) )
        [[ level.playerlaststand_func ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );

    self.health = 1;
    self.laststand = 1;
    self.ignoreme = 1;
    self thread maps\mp\gametypes_zm\_gameobjects::onplayerlaststand();
    self thread maps\mp\zombies\_zm_buildables::onplayerlaststand();

    if ( !( isdefined( self.no_revive_trigger ) && self.no_revive_trigger ) )
        self revive_trigger_spawn();
    else
        self undolaststand();

    if ( isdefined( self.is_zombie ) && self.is_zombie )
    {
        self takeallweapons();

        if ( isdefined( attacker ) && isplayer( attacker ) && attacker != self )
            attacker notify( "killed_a_zombie_player", einflictor, self, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
    }
    else
    {
        self laststand_disable_player_weapons();
        self laststand_give_pistol();
    }

    if ( isdefined( level.playersuicideallowed ) && level.playersuicideallowed && get_players().size > 1 )
    {
        if ( !isdefined( level.canplayersuicide ) || self [[ level.canplayersuicide ]]() )
            self thread suicide_trigger_spawn();
    }

    if ( isdefined( self.disabled_perks ) )
        self.disabled_perks = [];

    if ( level.laststandgetupallowed )
        self thread laststand_getup();
    else
    {
        bleedout_time = getdvarfloat( "player_lastStandBleedoutTime" );
        self thread laststand_bleedout( bleedout_time );
    }

    if ( "zcleansed" != level.gametype )
        maps\mp\_demo::bookmark( "zm_player_downed", gettime(), self );

    self notify( "player_downed" );
    self thread refire_player_downed();
    self thread cleanup_laststand_on_disconnect();
}

refire_player_downed()
{
    self endon( "player_revived" );
    self endon( "death" );
    self endon( "disconnect" );
    wait 1.0;

    if ( self.num_perks )
        self notify( "player_downed" );
}

laststand_allowed( sweapon, smeansofdeath, shitloc )
{
    if ( level.laststandpistol == "none" )
        return false;

    return true;
}

laststand_disable_player_weapons()
{
    weaponinventory = self getweaponslist( 1 );
    self.lastactiveweapon = self getcurrentweapon();

    if ( self isthrowinggrenade() && is_offhand_weapon( self.lastactiveweapon ) )
    {
        primaryweapons = self getweaponslistprimaries();

        if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
        {
            self.lastactiveweapon = primaryweapons[0];
            self switchtoweaponimmediate( self.lastactiveweapon );
        }
    }

    self setlaststandprevweap( self.lastactiveweapon );
    self.laststandpistol = undefined;
    self.hadpistol = 0;

    if ( isdefined( self.weapon_taken_by_losing_specialty_additionalprimaryweapon ) && self.lastactiveweapon == self.weapon_taken_by_losing_specialty_additionalprimaryweapon )
    {
        self.lastactiveweapon = "none";
        self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;
    }

    for ( i = 0; i < weaponinventory.size; i++ )
    {
        weapon = weaponinventory[i];
        class = weaponclass( weapon );

        if ( issubstr( weapon, "knife_ballistic_" ) )
            class = "knife";

        if ( ( class == "pistol" || class == "pistol spread" || class == "pistolspread" ) && !isdefined( self.laststandpistol ) )
        {
            self.laststandpistol = weapon;
            self.hadpistol = 1;
        }

        if ( weapon == "syrette_zm" )
        {
            self maps\mp\zombies\_zm_stats::increment_client_stat( "failed_sacrifices" );
            self maps\mp\zombies\_zm_stats::increment_player_stat( "failed_sacrifices" );
        }
        else if ( is_zombie_perk_bottle( weapon ) )
        {
            self takeweapon( weapon );
            self.lastactiveweapon = "none";
            continue;
        }

        if ( isdefined( get_gamemode_var( "item_meat_name" ) ) )
        {
            if ( weapon == get_gamemode_var( "item_meat_name" ) )
            {
                self takeweapon( weapon );
                self.lastactiveweapon = "none";
                continue;
            }
        }
    }

    if ( isdefined( self.hadpistol ) && self.hadpistol == 1 && isdefined( level.zombie_last_stand_pistol_memory ) )
        self [[ level.zombie_last_stand_pistol_memory ]]();

    if ( !isdefined( self.laststandpistol ) )
        self.laststandpistol = level.laststandpistol;

    self disableweaponcycling();
    self notify( "weapons_taken_for_last_stand" );
}

laststand_enable_player_weapons()
{
    if ( isdefined( self.hadpistol ) && !self.hadpistol && isdefined( self.laststandpistol ) )
        self takeweapon( self.laststandpistol );

    if ( isdefined( self.hadpistol ) && self.hadpistol == 1 && isdefined( level.zombie_last_stand_ammo_return ) )
        [[ level.zombie_last_stand_ammo_return ]]();

    self enableweaponcycling();
    self enableoffhandweapons();

    if ( isdefined( self.lastactiveweapon ) && self.lastactiveweapon != "none" && self hasweapon( self.lastactiveweapon ) && !is_placeable_mine( self.lastactiveweapon ) && !is_equipment( self.lastactiveweapon ) )
        self switchtoweapon( self.lastactiveweapon );
    else
    {
        primaryweapons = self getweaponslistprimaries();

        if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
            self switchtoweapon( primaryweapons[0] );
    }
}

laststand_clean_up_on_disconnect( playerbeingrevived, revivergun )
{
    self endon( "do_revive_ended_normally" );
    revivetrigger = playerbeingrevived.revivetrigger;

    playerbeingrevived waittill( "disconnect" );

    if ( isdefined( revivetrigger ) )
        revivetrigger delete();

    self cleanup_suicide_hud();

    if ( isdefined( self.reviveprogressbar ) )
        self.reviveprogressbar destroyelem();

    if ( isdefined( self.revivetexthud ) )
        self.revivetexthud destroy();

    self revive_give_back_weapons( revivergun );
}

laststand_clean_up_reviving_any( playerbeingrevived )
{
    self endon( "do_revive_ended_normally" );
    playerbeingrevived waittill_any( "disconnect", "zombified", "stop_revive_trigger" );
    self.is_reviving_any--;

    if ( 0 > self.is_reviving_any )
        self.is_reviving_any = 0;
}

laststand_give_pistol()
{
/#
    assert( isdefined( self.laststandpistol ) );
#/
/#
    assert( self.laststandpistol != "none" );
#/
    if ( isdefined( level.zombie_last_stand ) )
        [[ level.zombie_last_stand ]]();
    else
    {
        self giveweapon( self.laststandpistol );
        self givemaxammo( self.laststandpistol );
        self switchtoweapon( self.laststandpistol );
    }
}

laststand_bleedout( delay )
{
    self endon( "player_revived" );
    self endon( "player_suicide" );
    self endon( "zombified" );
    self endon( "disconnect" );

    if ( isdefined( self.is_zombie ) && self.is_zombie || isdefined( self.no_revive_trigger ) && self.no_revive_trigger )
    {
        self notify( "bled_out" );
        wait_network_frame();
        self bleed_out();
        return;
    }

    setclientsysstate( "lsm", "1", self );
    self.bleedout_time = delay;

    while ( self.bleedout_time > int( delay * 0.5 ) )
    {
        self.bleedout_time -= 1;
        wait 1;
    }

    visionsetlaststand( "zombie_death", delay * 0.5 );

    while ( self.bleedout_time > 0 )
    {
        self.bleedout_time -= 1;
        wait 1;
    }

    while ( isdefined( self.revivetrigger ) && isdefined( self.revivetrigger.beingrevived ) && self.revivetrigger.beingrevived == 1 )
        wait 0.1;

    self notify( "bled_out" );
    wait_network_frame();
    self bleed_out();
}

bleed_out()
{
    self cleanup_suicide_hud();

    if ( isdefined( self.revivetrigger ) )
        self.revivetrigger delete();

    self.revivetrigger = undefined;
    setclientsysstate( "lsm", "0", self );
    self maps\mp\zombies\_zm_stats::increment_client_stat( "deaths" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "deaths" );
    self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
    self recordplayerdeathzombies();
    self maps\mp\zombies\_zm_equipment::equipment_take();

    if ( "zcleansed" != level.gametype )
        maps\mp\_demo::bookmark( "zm_player_bledout", gettime(), self, undefined, 1 );

    level notify( "bleed_out", self.characterindex );
    self undolaststand();

    if ( isdefined( level.is_zombie_level ) && level.is_zombie_level )
        self thread [[ level.player_becomes_zombie ]]();
    else if ( isdefined( level.is_specops_level ) && level.is_specops_level )
        self thread [[ level.spawnspectator ]]();
    else
        self.ignoreme = 0;
}

cleanup_suicide_hud()
{
    if ( isdefined( self.suicideprompt ) )
        self.suicideprompt destroy();

    self.suicideprompt = undefined;
}

clean_up_suicide_hud_on_end_game()
{
    self endon( "disconnect" );
    self endon( "zombified" );
    self endon( "stop_revive_trigger" );
    self endon( "player_revived" );
    self endon( "bled_out" );
    level waittill_any( "end_game", "stop_suicide_trigger" );
    self cleanup_suicide_hud();

    if ( isdefined( self.suicidetexthud ) )
        self.suicidetexthud destroy();

    if ( isdefined( self.suicideprogressbar ) )
        self.suicideprogressbar destroyelem();
}

clean_up_suicide_hud_on_bled_out()
{
    self endon( "disconnect" );
    self endon( "zombified" );
    self endon( "stop_revive_trigger" );
    self waittill_any( "bled_out", "player_revived", "fake_death" );
    self cleanup_suicide_hud();

    if ( isdefined( self.suicideprogressbar ) )
        self.suicideprogressbar destroyelem();

    if ( isdefined( self.suicidetexthud ) )
        self.suicidetexthud destroy();
}

suicide_trigger_spawn()
{
    radius = getdvarint( _hash_A17166B0 );
    self.suicideprompt = newclienthudelem( self );
    self.suicideprompt.alignx = "center";
    self.suicideprompt.aligny = "middle";
    self.suicideprompt.horzalign = "center";
    self.suicideprompt.vertalign = "bottom";
    self.suicideprompt.y = -170;

    if ( self issplitscreen() )
        self.suicideprompt.y = -132;

    self.suicideprompt.foreground = 1;
    self.suicideprompt.font = "default";
    self.suicideprompt.fontscale = 1.5;
    self.suicideprompt.alpha = 1;
    self.suicideprompt.color = ( 1, 1, 1 );
    self.suicideprompt.hidewheninmenu = 1;
    self thread suicide_trigger_think();
}

suicide_trigger_think()
{
    self endon( "disconnect" );
    self endon( "zombified" );
    self endon( "stop_revive_trigger" );
    self endon( "player_revived" );
    self endon( "bled_out" );
    self endon( "fake_death" );
    level endon( "end_game" );
    level endon( "stop_suicide_trigger" );
    self thread clean_up_suicide_hud_on_end_game();
    self thread clean_up_suicide_hud_on_bled_out();

    while ( self usebuttonpressed() )
        wait 1;

    if ( !isdefined( self.suicideprompt ) )
        return;

    while ( true )
    {
        wait 0.1;

        if ( !isdefined( self.suicideprompt ) )
            continue;

        self.suicideprompt settext( &"ZOMBIE_BUTTON_TO_SUICIDE" );

        if ( !self is_suiciding() )
            continue;

        self.pre_suicide_weapon = self getcurrentweapon();
        self giveweapon( level.suicide_weapon );
        self switchtoweapon( level.suicide_weapon );
        duration = self docowardswayanims();
        suicide_success = suicide_do_suicide( duration );
        self.laststand = undefined;
        self takeweapon( level.suicide_weapon );

        if ( suicide_success )
        {
            self notify( "player_suicide" );
            wait_network_frame();
            self maps\mp\zombies\_zm_stats::increment_client_stat( "suicides" );
            self bleed_out();
            return;
        }

        self switchtoweapon( self.pre_suicide_weapon );
        self.pre_suicide_weapon = undefined;
    }
}

suicide_do_suicide( duration )
{
    level endon( "end_game" );
    level endon( "stop_suicide_trigger" );
    suicidetime = duration;
    timer = 0;
    suicided = 0;
    self.suicideprompt settext( "" );

    if ( !isdefined( self.suicideprogressbar ) )
        self.suicideprogressbar = self createprimaryprogressbar();

    if ( !isdefined( self.suicidetexthud ) )
        self.suicidetexthud = newclienthudelem( self );

    self.suicideprogressbar updatebar( 0.01, 1 / suicidetime );
    self.suicidetexthud.alignx = "center";
    self.suicidetexthud.aligny = "middle";
    self.suicidetexthud.horzalign = "center";
    self.suicidetexthud.vertalign = "bottom";
    self.suicidetexthud.y = -173;

    if ( self issplitscreen() )
        self.suicidetexthud.y = -147;

    self.suicidetexthud.foreground = 1;
    self.suicidetexthud.font = "default";
    self.suicidetexthud.fontscale = 1.8;
    self.suicidetexthud.alpha = 1;
    self.suicidetexthud.color = ( 1, 1, 1 );
    self.suicidetexthud.hidewheninmenu = 1;
    self.suicidetexthud settext( &"ZOMBIE_SUICIDING" );

    while ( self is_suiciding() )
    {
        wait 0.05;
        timer += 0.05;

        if ( timer >= suicidetime )
        {
            suicided = 1;
            break;
        }
    }

    if ( isdefined( self.suicideprogressbar ) )
        self.suicideprogressbar destroyelem();

    if ( isdefined( self.suicidetexthud ) )
        self.suicidetexthud destroy();

    if ( isdefined( self.suicideprompt ) )
        self.suicideprompt settext( &"ZOMBIE_BUTTON_TO_SUICIDE" );

    return suicided;
}

can_suicide()
{
    if ( !isalive( self ) )
        return false;

    if ( !self player_is_in_laststand() )
        return false;

    if ( !isdefined( self.suicideprompt ) )
        return false;

    if ( isdefined( self.is_zombie ) && self.is_zombie )
        return false;

    if ( isdefined( level.intermission ) && level.intermission )
        return false;

    return true;
}

is_suiciding( revivee )
{
    return self usebuttonpressed() && can_suicide();
}

revive_trigger_spawn()
{
    if ( isdefined( level.revive_trigger_spawn_override_link ) )
        [[ level.revive_trigger_spawn_override_link ]]( self );
    else
    {
        radius = getdvarint( _hash_A17166B0 );
        self.revivetrigger = spawn( "trigger_radius", ( 0, 0, 0 ), 0, radius, radius );
        self.revivetrigger sethintstring( "" );
        self.revivetrigger setcursorhint( "HINT_NOICON" );
        self.revivetrigger setmovingplatformenabled( 1 );
        self.revivetrigger enablelinkto();
        self.revivetrigger.origin = self.origin;
        self.revivetrigger linkto( self );
        self.revivetrigger.beingrevived = 0;
        self.revivetrigger.createtime = gettime();
    }

    self thread revive_trigger_think();
}

revive_trigger_think()
{
    self endon( "disconnect" );
    self endon( "zombified" );
    self endon( "stop_revive_trigger" );
    level endon( "end_game" );
    self endon( "death" );

    while ( true )
    {
        wait 0.1;
        self.revivetrigger sethintstring( "" );
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            d = 0;
            d = self depthinwater();

            if ( players[i] can_revive( self ) || d > 20 )
            {
                self.revivetrigger setrevivehintstring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER", self.team );
                break;
            }
        }

        for ( i = 0; i < players.size; i++ )
        {
            reviver = players[i];

            if ( self == reviver || !reviver is_reviving( self ) )
                continue;

            gun = reviver getcurrentweapon();
/#
            assert( isdefined( gun ) );
#/
            if ( gun == level.revive_tool )
                continue;

            reviver giveweapon( level.revive_tool );
            reviver switchtoweapon( level.revive_tool );
            reviver setweaponammostock( level.revive_tool, 1 );
            revive_success = reviver revive_do_revive( self, gun );
            reviver revive_give_back_weapons( gun );

            if ( isplayer( self ) )
                self allowjump( 1 );

            self.laststand = undefined;

            if ( revive_success )
            {
                if ( isplayer( self ) )
                    maps\mp\zombies\_zm_chugabud::player_revived_cleanup_chugabud_corpse();

                self thread revive_success( reviver );
                self cleanup_suicide_hud();
                return;
            }
        }
    }
}

revive_give_back_weapons( gun )
{
    self takeweapon( level.revive_tool );

    if ( self player_is_in_laststand() )
        return;

    if ( gun != "none" && !is_placeable_mine( gun ) && gun != "equip_gasmask_zm" && gun != "lower_equip_gasmask_zm" && self hasweapon( gun ) )
        self switchtoweapon( gun );
    else
    {
        primaryweapons = self getweaponslistprimaries();

        if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
            self switchtoweapon( primaryweapons[0] );
    }
}

can_revive( revivee )
{
    if ( !isdefined( revivee.revivetrigger ) )
        return false;

    if ( !isalive( self ) )
        return false;

    if ( self player_is_in_laststand() )
        return false;

    if ( self.team != revivee.team )
        return false;

    if ( isdefined( self.is_zombie ) && self.is_zombie )
        return false;

    if ( self has_powerup_weapon() )
        return false;

    if ( isdefined( level.can_revive_use_depthinwater_test ) && level.can_revive_use_depthinwater_test && revivee depthinwater() > 10 )
        return true;

    if ( isdefined( level.can_revive ) && ![[ level.can_revive ]]( revivee ) )
        return false;

    if ( isdefined( level.can_revive_game_module ) && ![[ level.can_revive_game_module ]]( revivee ) )
        return false;

    ignore_sight_checks = 0;
    ignore_touch_checks = 0;

    if ( isdefined( level.revive_trigger_should_ignore_sight_checks ) )
    {
        ignore_sight_checks = [[ level.revive_trigger_should_ignore_sight_checks ]]( self );

        if ( ignore_sight_checks && isdefined( revivee.revivetrigger.beingrevived ) && revivee.revivetrigger.beingrevived == 1 )
            ignore_touch_checks = 1;
    }

    if ( !ignore_touch_checks )
    {
        if ( !self istouching( revivee.revivetrigger ) )
            return false;
    }

    if ( !ignore_sight_checks )
    {
        if ( !self is_facing( revivee ) )
            return false;

        if ( !sighttracepassed( self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), revivee.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), 0, undefined ) )
            return false;

        if ( !bullettracepassed( self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), revivee.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), 0, undefined ) )
            return false;
    }

    return true;
}

is_reviving( revivee )
{
    return self usebuttonpressed() && can_revive( revivee );
}

is_reviving_any()
{
    return isdefined( self.is_reviving_any ) && self.is_reviving_any;
}

is_facing( facee )
{
    orientation = self getplayerangles();
    forwardvec = anglestoforward( orientation );
    forwardvec2d = ( forwardvec[0], forwardvec[1], 0 );
    unitforwardvec2d = vectornormalize( forwardvec2d );
    tofaceevec = facee.origin - self.origin;
    tofaceevec2d = ( tofaceevec[0], tofaceevec[1], 0 );
    unittofaceevec2d = vectornormalize( tofaceevec2d );
    dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
    return dotproduct > 0.9;
}

revive_do_revive( playerbeingrevived, revivergun )
{
/#
    assert( self is_reviving( playerbeingrevived ) );
#/
    revivetime = 3;

    if ( self hasperk( "specialty_quickrevive" ) )
        revivetime /= 2;

    if ( self maps\mp\zombies\_zm_pers_upgrades_functions::pers_revive_active() )
        revivetime *= 0.5;

    timer = 0;
    revived = 0;
    playerbeingrevived.revivetrigger.beingrevived = 1;
    playerbeingrevived.revive_hud settext( &"ZOMBIE_PLAYER_IS_REVIVING_YOU", self );
    playerbeingrevived revive_hud_show_n_fade( 3.0 );
    playerbeingrevived.revivetrigger sethintstring( "" );

    if ( isplayer( playerbeingrevived ) )
        playerbeingrevived startrevive( self );

    if ( !isdefined( self.reviveprogressbar ) )
        self.reviveprogressbar = self createprimaryprogressbar();

    if ( !isdefined( self.revivetexthud ) )
        self.revivetexthud = newclienthudelem( self );

    self thread laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );

    if ( !isdefined( self.is_reviving_any ) )
        self.is_reviving_any = 0;

    self.is_reviving_any++;
    self thread laststand_clean_up_reviving_any( playerbeingrevived );
    self.reviveprogressbar updatebar( 0.01, 1 / revivetime );
    self.revivetexthud.alignx = "center";
    self.revivetexthud.aligny = "middle";
    self.revivetexthud.horzalign = "center";
    self.revivetexthud.vertalign = "bottom";
    self.revivetexthud.y = -113;

    if ( self issplitscreen() )
        self.revivetexthud.y = -347;

    self.revivetexthud.foreground = 1;
    self.revivetexthud.font = "default";
    self.revivetexthud.fontscale = 1.8;
    self.revivetexthud.alpha = 1;
    self.revivetexthud.color = ( 1, 1, 1 );
    self.revivetexthud.hidewheninmenu = 1;

    if ( self maps\mp\zombies\_zm_pers_upgrades_functions::pers_revive_active() )
        self.revivetexthud.color = ( 0.5, 0.5, 1.0 );

    self.revivetexthud settext( &"ZOMBIE_REVIVING" );
    self thread check_for_failed_revive( playerbeingrevived );

    while ( self is_reviving( playerbeingrevived ) )
    {
        wait 0.05;
        timer += 0.05;

        if ( self player_is_in_laststand() )
            break;

        if ( isdefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
            break;

        if ( timer >= revivetime )
        {
            revived = 1;
            break;
        }
    }

    if ( isdefined( self.reviveprogressbar ) )
        self.reviveprogressbar destroyelem();

    if ( isdefined( self.revivetexthud ) )
        self.revivetexthud destroy();

    if ( isdefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
    {

    }
    else if ( !revived )
    {
        if ( isplayer( playerbeingrevived ) )
            playerbeingrevived stoprevive( self );
    }

    playerbeingrevived.revivetrigger sethintstring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
    playerbeingrevived.revivetrigger.beingrevived = 0;
    self notify( "do_revive_ended_normally" );
    self.is_reviving_any--;

    if ( !revived )
        playerbeingrevived thread checkforbleedout( self );

    return revived;
}

checkforbleedout( player )
{
    self endon( "player_revived" );
    self endon( "player_suicide" );
    self endon( "disconnect" );
    player endon( "disconnect" );

    if ( is_classic() )
    {
        player.failed_revives++;
        player notify( "player_failed_revive" );
    }
}

auto_revive( reviver, dont_enable_weapons )
{
    if ( isdefined( self.revivetrigger ) )
    {
        self.revivetrigger.auto_revive = 1;

        if ( self.revivetrigger.beingrevived == 1 )
        {
            while ( true )
            {
                if ( self.revivetrigger.beingrevived == 0 )
                    break;

                wait_network_frame();
            }
        }

        self.revivetrigger.auto_trigger = 0;
    }

    self reviveplayer();
    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
    setclientsysstate( "lsm", "0", self );
    self notify( "stop_revive_trigger" );

    if ( isdefined( self.revivetrigger ) )
    {
        self.revivetrigger delete();
        self.revivetrigger = undefined;
    }

    self cleanup_suicide_hud();

    if ( !isdefined( dont_enable_weapons ) || dont_enable_weapons == 0 )
        self laststand_enable_player_weapons();

    self allowjump( 1 );
    self.ignoreme = 0;
    self.laststand = undefined;

    if ( !( isdefined( level.isresetting_grief ) && level.isresetting_grief ) )
    {
        reviver.revives++;
        reviver maps\mp\zombies\_zm_stats::increment_client_stat( "revives" );
        reviver maps\mp\zombies\_zm_stats::increment_player_stat( "revives" );
        self recordplayerrevivezombies( reviver );
        maps\mp\_demo::bookmark( "zm_player_revived", gettime(), self, reviver );
    }

    self notify( "player_revived", reviver );
}

remote_revive( reviver )
{
    if ( !self player_is_in_laststand() )
        return;

    self auto_revive( reviver );
}

revive_success( reviver, b_track_stats )
{
    if ( !isdefined( b_track_stats ) )
        b_track_stats = 1;

    if ( !isplayer( self ) )
    {
        self notify( "player_revived", reviver );
        return;
    }

    if ( isdefined( b_track_stats ) && b_track_stats )
        maps\mp\_demo::bookmark( "zm_player_revived", gettime(), self, reviver );

    self notify( "player_revived", reviver );
    self reviveplayer();
    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );

    if ( isdefined( self.pers_upgrades_awarded["perk_lose"] ) && self.pers_upgrades_awarded["perk_lose"] )
        self thread maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_perk_lose_restore();

    if ( !( isdefined( level.isresetting_grief ) && level.isresetting_grief ) && ( isdefined( b_track_stats ) && b_track_stats ) )
    {
        reviver.revives++;
        reviver maps\mp\zombies\_zm_stats::increment_client_stat( "revives" );
        reviver maps\mp\zombies\_zm_stats::increment_player_stat( "revives" );
        self recordplayerrevivezombies( reviver );
        reviver.upgrade_fx_origin = self.origin;
    }

    if ( is_classic() && ( isdefined( b_track_stats ) && b_track_stats ) )
        maps\mp\zombies\_zm_pers_upgrades_functions::pers_increment_revive_stat( reviver );

    if ( isdefined( b_track_stats ) && b_track_stats )
        reviver thread check_for_sacrifice();

    if ( isdefined( level.missioncallbacks ) )
    {

    }

    setclientsysstate( "lsm", "0", self );
    self.revivetrigger delete();
    self.revivetrigger = undefined;
    self cleanup_suicide_hud();
    self laststand_enable_player_weapons();
    self.ignoreme = 0;
}

revive_force_revive( reviver )
{
/#
    assert( isdefined( self ) );
#/
/#
    assert( isplayer( self ) );
#/
/#
    assert( self player_is_in_laststand() );
#/
    self thread revive_success( reviver );
}

revive_hud_create()
{
    self.revive_hud = newclienthudelem( self );
    self.revive_hud.alignx = "center";
    self.revive_hud.aligny = "middle";
    self.revive_hud.horzalign = "center";
    self.revive_hud.vertalign = "bottom";
    self.revive_hud.foreground = 1;
    self.revive_hud.font = "default";
    self.revive_hud.fontscale = 1.5;
    self.revive_hud.alpha = 0;
    self.revive_hud.color = ( 1, 1, 1 );
    self.revive_hud.hidewheninmenu = 1;
    self.revive_hud settext( "" );
    self.revive_hud.y = -160;
}

revive_hud_think()
{
    self endon( "disconnect" );

    while ( true )
    {
        wait 0.1;

        if ( !player_any_player_in_laststand() )
            continue;

        players = get_players();
        playertorevive = undefined;

        for ( i = 0; i < players.size; i++ )
        {
            if ( !isdefined( players[i].revivetrigger ) || !isdefined( players[i].revivetrigger.createtime ) )
                continue;

            if ( !isdefined( playertorevive ) || playertorevive.revivetrigger.createtime > players[i].revivetrigger.createtime )
                playertorevive = players[i];
        }

        if ( isdefined( playertorevive ) )
        {
            for ( i = 0; i < players.size; i++ )
            {
                if ( players[i] player_is_in_laststand() )
                    continue;

                if ( getdvar( "g_gametype" ) == "vs" )
                {
                    if ( players[i].team != playertorevive.team )
                        continue;
                }

                if ( is_encounter() )
                {
                    if ( players[i].sessionteam != playertorevive.sessionteam )
                        continue;

                    if ( isdefined( level.hide_revive_message ) && level.hide_revive_message )
                        continue;
                }

                players[i] thread faderevivemessageover( playertorevive, 3.0 );
            }

            playertorevive.revivetrigger.createtime = undefined;
            wait 3.5;
        }
    }
}

faderevivemessageover( playertorevive, time )
{
    revive_hud_show();
    self.revive_hud settext( &"ZOMBIE_PLAYER_NEEDS_TO_BE_REVIVED", playertorevive );
    self.revive_hud fadeovertime( time );
    self.revive_hud.alpha = 0;
}

revive_hud_show()
{
/#
    assert( isdefined( self ) );
#/
/#
    assert( isdefined( self.revive_hud ) );
#/
    self.revive_hud.alpha = 1;
}

revive_hud_show_n_fade( time )
{
    revive_hud_show();
    self.revive_hud fadeovertime( time );
    self.revive_hud.alpha = 0;
}

drawcylinder( pos, rad, height )
{
/#
    currad = rad;
    curheight = height;

    for ( r = 0; r < 20; r++ )
    {
        theta = r / 20 * 360;
        theta2 = ( r + 1 ) / 20 * 360;
        line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
        line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
        line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
    }
#/
}

get_lives_remaining()
{
/#
    assert( level.laststandgetupallowed, "Lives only exist in the Laststand type GETUP." );
#/
    if ( level.laststandgetupallowed && isdefined( self.laststand_info ) && isdefined( self.laststand_info.type_getup_lives ) )
        return max( 0, self.laststand_info.type_getup_lives );

    return 0;
}

update_lives_remaining( increment )
{
/#
    assert( level.laststandgetupallowed, "Lives only exist in the Laststand type GETUP." );
#/
/#
    assert( isdefined( increment ), "Must specify increment true or false" );
#/
    increment = isdefined( increment ) ? increment : 0;
    self.laststand_info.type_getup_lives = max( 0, increment ? self.laststand_info.type_getup_lives + 1 : self.laststand_info.type_getup_lives - 1 );
    self notify( "laststand_lives_updated" );
}

player_getup_setup()
{
/#
    println( "ZM >> player_getup_setup called" );
#/
    self.laststand_info = spawnstruct();
    self.laststand_info.type_getup_lives = level.const_laststand_getup_count_start;
}

laststand_getup()
{
    self endon( "player_revived" );
    self endon( "disconnect" );
/#
    println( "ZM >> laststand_getup called" );
#/
    self update_lives_remaining( 0 );
    setclientsysstate( "lsm", "1", self );
    self.laststand_info.getup_bar_value = level.const_laststand_getup_bar_start;
    self thread laststand_getup_hud();
    self thread laststand_getup_damage_watcher();

    while ( self.laststand_info.getup_bar_value < 1 )
    {
        self.laststand_info.getup_bar_value += level.const_laststand_getup_bar_regen;
        wait 0.05;
    }

    self auto_revive( self );
    setclientsysstate( "lsm", "0", self );
}

laststand_getup_damage_watcher()
{
    self endon( "player_revived" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "damage" );

        self.laststand_info.getup_bar_value -= level.const_laststand_getup_bar_damage;

        if ( self.laststand_info.getup_bar_value < 0 )
            self.laststand_info.getup_bar_value = 0;
    }
}

laststand_getup_hud()
{
    self endon( "player_revived" );
    self endon( "disconnect" );
    hudelem = newclienthudelem( self );
    hudelem.alignx = "left";
    hudelem.aligny = "middle";
    hudelem.horzalign = "left";
    hudelem.vertalign = "middle";
    hudelem.x = 5;
    hudelem.y = 170;
    hudelem.font = "big";
    hudelem.fontscale = 1.5;
    hudelem.foreground = 1;
    hudelem.hidewheninmenu = 1;
    hudelem.hidewhendead = 1;
    hudelem.sort = 2;
    hudelem.label = &"SO_WAR_LASTSTAND_GETUP_BAR";
    self thread laststand_getup_hud_destroy( hudelem );

    while ( true )
    {
        hudelem setvalue( self.laststand_info.getup_bar_value );
        wait 0.05;
    }
}

laststand_getup_hud_destroy( hudelem )
{
    self waittill_either( "player_revived", "disconnect" );
    hudelem destroy();
}

check_for_sacrifice()
{
    self delay_notify( "sacrifice_denied", 1 );
    self endon( "sacrifice_denied" );

    self waittill( "player_downed" );

    self maps\mp\zombies\_zm_stats::increment_client_stat( "sacrifices" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "sacrifices" );
}

check_for_failed_revive( playerbeingrevived )
{
    self endon( "disconnect" );
    playerbeingrevived endon( "disconnect" );
    playerbeingrevived endon( "player_suicide" );
    self notify( "checking_for_failed_revive" );
    self endon( "checking_for_failed_revive" );
    playerbeingrevived endon( "player_revived" );

    playerbeingrevived waittill( "bled_out" );

    self maps\mp\zombies\_zm_stats::increment_client_stat( "failed_revives" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "failed_revives" );
}

add_weighted_down()
{
    if ( !level.curr_gametype_affects_rank )
        return;

    weighted_down = 1000;

    if ( level.round_number > 0 )
        weighted_down = int( 1000.0 / ceil( level.round_number / 5.0 ) );

    self addplayerstat( "weighted_downs", weighted_down );
}

cleanup_laststand_on_disconnect()
{
    self endon( "player_revived" );
    self endon( "player_suicide" );
    self endon( "bled_out" );
    trig = self.revivetrigger;

    self waittill( "disconnect" );

    if ( isdefined( trig ) )
        trig delete();
}
