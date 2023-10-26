// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_riotshield;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm_audio;

init()
{
    maps\mp\zombies\_zm_riotshield::init();
    set_zombie_var( "riotshield_cylinder_radius", 360 );
    set_zombie_var( "riotshield_fling_range", 90 );
    set_zombie_var( "riotshield_gib_range", 90 );
    set_zombie_var( "riotshield_gib_damage", 75 );
    set_zombie_var( "riotshield_knockdown_range", 90 );
    set_zombie_var( "riotshield_knockdown_damage", 15 );
    set_zombie_var( "riotshield_hit_points", 2250 );
    set_zombie_var( "riotshield_fling_damage_shield", 100 );
    set_zombie_var( "riotshield_knockdown_damage_shield", 15 );
    level.riotshield_network_choke_count = 0;
    level.riotshield_gib_refs = [];
    level.riotshield_gib_refs[level.riotshield_gib_refs.size] = "guts";
    level.riotshield_gib_refs[level.riotshield_gib_refs.size] = "right_arm";
    level.riotshield_gib_refs[level.riotshield_gib_refs.size] = "left_arm";
    level.riotshield_damage_callback = ::player_damage_shield;
    level.deployed_riotshield_damage_callback = ::deployed_damage_shield;
    level.transferriotshield = ::transferriotshield;
    level.cantransferriotshield = ::cantransferriotshield;
    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::riotshield_zombie_damage_response );
    maps\mp\zombies\_zm_equipment::register_equipment( "riotshield_zm", &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", "riotshield_zm_icon", "riotshield", ::riotshield_activation_watcher_thread, undefined, ::dropshield, ::pickupshield );
    maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "riotshield", &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING" );
    onplayerconnect_callback( ::onplayerconnect );
}

onplayerconnect()
{
    self.player_shield_reset_health = ::player_init_shield_health;
    self.player_shield_apply_damage = ::player_damage_shield;
    self.player_shield_reset_location = ::player_init_shield_location;
    self thread watchriotshielduse();
    self thread watchriotshieldmelee();
    self thread player_watch_laststand();
}

dropshield()
{
    self.shield_placement = 0;
    self maps\mp\zombies\_zm_riotshield::updateriotshieldmodel();
    item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "t6_wpn_zmb_shield_world", "riotshield_zm", self.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), self.angles );

    if ( isdefined( item ) )
    {
        item.shielddamagetaken = self.shielddamagetaken;
        item.original_owner = self;
        item.owner = undefined;
        item.name = level.riotshield_name;
        item.isriotshield = 1;
        item deployed_damage_shield( 0 );
        item setscriptmoverflag( 0 );
        item.requires_pickup = 1;
        item thread watchtoofriendly( self );
    }

    self takeweapon( level.riotshield_name );
    return item;
}

watchtoofriendly( player )
{
    wait 1;

    if ( isdefined( self ) && isdefined( player ) && distance2dsquared( self.origin, player.origin ) < 36 )
    {
        if ( isalive( player ) )
            player playlocalsound( level.zmb_laugh_alias );

        player maps\mp\zombies\_zm_stats::increment_client_stat( "cheat_total", 0 );
        self deployed_damage_shield( 2000 );
    }
}

pickupshield( item )
{
    item.owner = self;
    damage = item.shielddamagetaken;
    damagemax = level.zombie_vars["riotshield_hit_points"];
    self.shielddamagetaken = damage;
    self player_set_shield_health( damage, damagemax );
}

placeshield( origin, angles )
{
    if ( self getcurrentweapon() != level.riotshield_name )
    {
        self switchtoweapon( level.riotshield_name );

        self waittill( "weapon_change" );
    }

    item = self maps\mp\zombies\_zm_riotshield::doriotshielddeploy( origin, angles );

    if ( isdefined( item ) )
    {
        item.origin = self.origin + vectorscale( ( 0, 0, 1 ), 30.0 );
        item.angles = self.angles;
        item.owner = self;
    }

    return item;
}

cantransferriotshield( fromplayer, toplayer )
{
    if ( isdefined( toplayer.screecher_weapon ) )
        return false;

    if ( isdefined( toplayer.is_drinking ) && toplayer.is_drinking > 0 )
        return false;

    if ( toplayer maps\mp\zombies\_zm_laststand::player_is_in_laststand() || toplayer in_revive_trigger() )
        return false;

    if ( toplayer isthrowinggrenade() )
        return false;

    if ( fromplayer == toplayer )
        return true;

    if ( toplayer is_player_equipment( level.riotshield_name ) && toplayer.shield_placement != 3 )
        return false;

    if ( fromplayer.session_team != toplayer.session_team )
        return false;

    return true;
}

transferriotshield( fromplayer, toplayer )
{
    damage = fromplayer.shielddamagetaken;
    toplayer player_take_riotshield();
    fromplayer player_take_riotshield();
    toplayer.shielddamagetaken = damage;
    toplayer.shield_placement = 3;
    toplayer.shield_damage_level = 0;
    toplayer maps\mp\zombies\_zm_equipment::equipment_give( "riotshield_zm" );
    toplayer switchtoweapon( "riotshield_zm" );
    damagemax = level.zombie_vars["riotshield_hit_points"];
    toplayer player_set_shield_health( damage, damagemax );
}

player_take_riotshield()
{
    self notify( "destroy_riotshield" );

    if ( self getcurrentweapon() == "riotshield_zm" )
    {
        new_primary = "";

        if ( isdefined( self.laststand ) && self.laststand )
        {
            new_primary = self.laststandpistol;
            self giveweapon( new_primary );
        }
        else
        {
            primaryweapons = self getweaponslistprimaries();

            for ( i = 0; i < primaryweapons.size; i++ )
            {
                if ( primaryweapons[i] != "riotshield_zm" )
                {
                    new_primary = primaryweapons[i];
                    break;
                }
            }

            if ( new_primary == "" )
            {
                self maps\mp\zombies\_zm_weapons::give_fallback_weapon();
                new_primary = "zombie_fists_zm";
            }
        }

        self switchtoweaponimmediate( new_primary );
        self playsound( "wpn_riotshield_zm_destroy" );

        self waittill( "weapon_change" );
    }

    self maps\mp\zombies\_zm_riotshield::removeriotshield();
    self maps\mp\zombies\_zm_equipment::equipment_take( "riotshield_zm" );
    self.hasriotshield = 0;
    self.hasriotshieldequipped = 0;
}

player_watch_laststand()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "entering_last_stand" );

        if ( self getcurrentweapon() == "riotshield_zm" )
        {
            new_primary = self.laststandpistol;
            self giveweapon( new_primary );
            self switchtoweaponimmediate( new_primary );
        }
    }
}

player_init_shield_health()
{
    retval = self.shielddamagetaken > 0;
    self.shielddamagetaken = 0;
    self.shield_damage_level = 0;
    self maps\mp\zombies\_zm_riotshield::updateriotshieldmodel();
    return retval;
}

player_init_shield_location()
{
    self.hasriotshield = 1;
    self.hasriotshieldequipped = 0;
    self.shield_placement = 2;
    self maps\mp\zombies\_zm_riotshield::updateriotshieldmodel();
}

player_set_shield_health( damage, max_damage )
{
    shieldhealth = int( 100 * ( max_damage - damage ) / max_damage );

    if ( shieldhealth >= 50 )
        self.shield_damage_level = 0;
    else if ( shieldhealth >= 25 )
        self.shield_damage_level = 2;
    else
        self.shield_damage_level = 3;

    self maps\mp\zombies\_zm_riotshield::updateriotshieldmodel();
}

deployed_set_shield_health( damage, max_damage )
{
    shieldhealth = int( 100 * ( max_damage - damage ) / max_damage );

    if ( shieldhealth >= 50 )
        self.shield_damage_level = 0;
    else if ( shieldhealth >= 25 )
        self.shield_damage_level = 2;
    else
        self.shield_damage_level = 3;

    self maps\mp\zombies\_zm_riotshield::updatestandaloneriotshieldmodel();
}

player_damage_shield( idamage, bheld )
{
    damagemax = level.zombie_vars["riotshield_hit_points"];

    if ( !isdefined( self.shielddamagetaken ) )
        self.shielddamagetaken = 0;

    self.shielddamagetaken += idamage;

    if ( self.shielddamagetaken >= damagemax )
    {
        if ( bheld || !isdefined( self.shield_ent ) )
        {
            self playrumbleonentity( "damage_heavy" );
            earthquake( 1.0, 0.75, self.origin, 100 );
        }
        else if ( isdefined( self.shield_ent ) )
        {
            if ( is_true( self.shield_ent.destroy_begun ) )
                return;

            self.shield_ent.destroy_begun = 1;
            shield_origin = self.shield_ent.origin;
            level thread maps\mp\zombies\_zm_equipment::equipment_disappear_fx( shield_origin, level._riotshield_dissapear_fx );
            wait 1;
            playsoundatposition( "wpn_riotshield_zm_destroy", shield_origin );
        }

        self thread player_take_riotshield();
    }
    else
    {
        if ( bheld )
        {
            self playrumbleonentity( "damage_light" );
            earthquake( 0.5, 0.5, self.origin, 100 );
        }

        self player_set_shield_health( self.shielddamagetaken, damagemax );
        self playsound( "fly_riotshield_zm_impact_zombies" );
    }
}

deployed_damage_shield( idamage )
{
    damagemax = level.zombie_vars["riotshield_hit_points"];

    if ( !isdefined( self.shielddamagetaken ) )
        self.shielddamagetaken = 0;

    self.shielddamagetaken += idamage;

    if ( self.shielddamagetaken >= damagemax )
    {
        shield_origin = self.origin;

        if ( isdefined( self.stub ) )
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );

        if ( isdefined( self.original_owner ) )
            self.original_owner maps\mp\zombies\_zm_equipment::equipment_take( "riotshield_zm" );

        maps\mp\zombies\_zm_equipment::equipment_disappear_fx( shield_origin, level._riotshield_dissapear_fx );
        playsoundatposition( "wpn_riotshield_zm_destroy", shield_origin );
        self_delete();
    }
    else
        self deployed_set_shield_health( self.shielddamagetaken, damagemax );
}

riotshield_activation_watcher_thread()
{
    self endon( "zombified" );
    self endon( "disconnect" );
    self endon( "riotshield_zm_taken" );

    while ( true )
        self waittill_either( "riotshield_zm_activate", "riotshield_zm_deactivate" );
}

watchriotshielduse()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.shielddamagetaken = 0;
    self thread maps\mp\zombies\_zm_riotshield::trackriotshield();
    self thread maps\mp\zombies\_zm_riotshield::trackequipmentchange();
    self thread maps\mp\zombies\_zm_riotshield::watchshieldlaststand();
    self thread trackstuckzombies();

    for (;;)
    {
        self waittill( "raise_riotshield" );

        self thread maps\mp\zombies\_zm_riotshield::startriotshielddeploy();
    }
}

watchriotshieldmelee()
{
    for (;;)
    {
        self waittill( "weapon_melee", weapon );

        if ( weapon == level.riotshield_name )
            self riotshield_melee();
    }
}

is_riotshield_damage( mod, player, amount )
{
    if ( mod == "MOD_MELEE" && player hasweapon( level.riotshield_name ) && amount < 10 )
        return true;

    return false;
}

riotshield_damage( amount )
{

}

riotshield_fling_zombie( player, fling_vec, index )
{
    if ( !isdefined( self ) || !isalive( self ) )
        return;

    if ( isdefined( self.ignore_riotshield ) && self.ignore_riotshield )
        return;

    if ( isdefined( self.riotshield_fling_func ) )
    {
        self [[ self.riotshield_fling_func ]]( player );
        return;
    }

    damage = 2500;
    self dodamage( damage, player.origin, player, player, "", "MOD_IMPACT" );

    if ( self.health < 1 )
    {
        self.riotshield_death = 1;
        self startragdoll();
        self launchragdoll( fling_vec );
    }
}

zombie_knockdown( player, gib )
{
    damage = level.zombie_vars["riotshield_knockdown_damage"];

    if ( isdefined( level.override_riotshield_damage_func ) )
        self [[ level.override_riotshield_damage_func ]]( player, gib );
    else
    {
        if ( gib )
        {
            self.a.gib_ref = random( level.riotshield_gib_refs );
            self thread maps\mp\animscripts\zm_death::do_gib();
        }

        self dodamage( damage, player.origin, player );
    }
}

riotshield_knockdown_zombie( player, gib )
{
    self endon( "death" );
    playsoundatposition( "vox_riotshield_forcehit", self.origin );
    playsoundatposition( "wpn_riotshield_proj_impact", self.origin );

    if ( !isdefined( self ) || !isalive( self ) )
        return;

    if ( isdefined( self.riotshield_knockdown_func ) )
        self [[ self.riotshield_knockdown_func ]]( player, gib );
    else
        self zombie_knockdown( player, gib );

    self dodamage( level.zombie_vars["riotshield_knockdown_damage"], player.origin, player );
    self playsound( "fly_riotshield_forcehit" );
}

riotshield_get_enemies_in_range()
{
    view_pos = self geteye();
    zombies = get_array_of_closest( view_pos, get_round_enemy_array(), undefined, undefined, 2 * level.zombie_vars["riotshield_knockdown_range"] );

    if ( !isdefined( zombies ) )
        return;

    knockdown_range_squared = level.zombie_vars["riotshield_knockdown_range"] * level.zombie_vars["riotshield_knockdown_range"];
    gib_range_squared = level.zombie_vars["riotshield_gib_range"] * level.zombie_vars["riotshield_gib_range"];
    fling_range_squared = level.zombie_vars["riotshield_fling_range"] * level.zombie_vars["riotshield_fling_range"];
    cylinder_radius_squared = level.zombie_vars["riotshield_cylinder_radius"] * level.zombie_vars["riotshield_cylinder_radius"];
    forward_view_angles = self getweaponforwarddir();
    end_pos = view_pos + vectorscale( forward_view_angles, level.zombie_vars["riotshield_knockdown_range"] );
/#
    if ( 2 == getdvarint( _hash_BF480CE9 ) )
    {
        near_circle_pos = view_pos + vectorscale( forward_view_angles, 2 );
        circle( near_circle_pos, level.zombie_vars["riotshield_cylinder_radius"], ( 1, 0, 0 ), 0, 0, 100 );
        line( near_circle_pos, end_pos, ( 0, 0, 1 ), 1, 0, 100 );
        circle( end_pos, level.zombie_vars["riotshield_cylinder_radius"], ( 1, 0, 0 ), 0, 0, 100 );
    }
#/
    for ( i = 0; i < zombies.size; i++ )
    {
        if ( !isdefined( zombies[i] ) || !isalive( zombies[i] ) )
            continue;

        test_origin = zombies[i] getcentroid();
        test_range_squared = distancesquared( view_pos, test_origin );

        if ( test_range_squared > knockdown_range_squared )
        {
            zombies[i] riotshield_debug_print( "range", ( 1, 0, 0 ) );
            return;
        }

        normal = vectornormalize( test_origin - view_pos );
        dot = vectordot( forward_view_angles, normal );

        if ( 0 > dot )
        {
            zombies[i] riotshield_debug_print( "dot", ( 1, 0, 0 ) );
            continue;
        }

        radial_origin = pointonsegmentnearesttopoint( view_pos, end_pos, test_origin );

        if ( distancesquared( test_origin, radial_origin ) > cylinder_radius_squared )
        {
            zombies[i] riotshield_debug_print( "cylinder", ( 1, 0, 0 ) );
            continue;
        }

        if ( 0 == zombies[i] damageconetrace( view_pos, self ) )
        {
            zombies[i] riotshield_debug_print( "cone", ( 1, 0, 0 ) );
            continue;
        }

        if ( test_range_squared < fling_range_squared )
        {
            level.riotshield_fling_enemies[level.riotshield_fling_enemies.size] = zombies[i];
            dist_mult = ( fling_range_squared - test_range_squared ) / fling_range_squared;
            fling_vec = vectornormalize( test_origin - view_pos );

            if ( 5000 < test_range_squared )
                fling_vec += vectornormalize( test_origin - radial_origin );

            fling_vec = ( fling_vec[0], fling_vec[1], abs( fling_vec[2] ) );
            fling_vec = vectorscale( fling_vec, 100 + 100 * dist_mult );
            level.riotshield_fling_vecs[level.riotshield_fling_vecs.size] = fling_vec;
            zombies[i] riotshield_debug_print( "fling", ( 0, 1, 0 ) );
            continue;
        }

        level.riotshield_knockdown_enemies[level.riotshield_knockdown_enemies.size] = zombies[i];
        level.riotshield_knockdown_gib[level.riotshield_knockdown_gib.size] = 0;
        zombies[i] riotshield_debug_print( "knockdown", ( 1, 1, 0 ) );
    }
}

riotshield_network_choke()
{
    level.riotshield_network_choke_count++;

    if ( !( level.riotshield_network_choke_count % 10 ) )
    {
        wait_network_frame();
        wait_network_frame();
        wait_network_frame();
    }
}

riotshield_melee()
{
    if ( !isdefined( level.riotshield_knockdown_enemies ) )
    {
        level.riotshield_knockdown_enemies = [];
        level.riotshield_knockdown_gib = [];
        level.riotshield_fling_enemies = [];
        level.riotshield_fling_vecs = [];
    }

    self riotshield_get_enemies_in_range();
    shield_damage = 0;
    level.riotshield_network_choke_count = 0;

    for ( i = 0; i < level.riotshield_fling_enemies.size; i++ )
    {
        riotshield_network_choke();

        if ( isdefined( level.riotshield_fling_enemies[i] ) )
        {
            level.riotshield_fling_enemies[i] thread riotshield_fling_zombie( self, level.riotshield_fling_vecs[i], i );
            shield_damage += level.zombie_vars["riotshield_fling_damage_shield"];
        }
    }

    for ( i = 0; i < level.riotshield_knockdown_enemies.size; i++ )
    {
        riotshield_network_choke();
        level.riotshield_knockdown_enemies[i] thread riotshield_knockdown_zombie( self, level.riotshield_knockdown_gib[i] );
        shield_damage += level.zombie_vars["riotshield_knockdown_damage_shield"];
    }

    level.riotshield_knockdown_enemies = [];
    level.riotshield_knockdown_gib = [];
    level.riotshield_fling_enemies = [];
    level.riotshield_fling_vecs = [];

    if ( shield_damage )
        self player_damage_shield( shield_damage, 0 );
}

trackstuckzombies()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "deployed_riotshield" );

        if ( isdefined( self.riotshieldentity ) )
            self thread watchstuckzombies();
    }
}

attack_shield( shield )
{
    self endon( "death" );
    shield.owner endon( "death" );
    shield.owner endon( "disconnect" );
    shield.owner endon( "start_riotshield_deploy" );
    shield.owner endon( "destroy_riotshield" );

    if ( isdefined( self.doing_shield_attack ) && self.doing_shield_attack )
        return 0;

    self.old_origin = self.origin;

    if ( getdvar( _hash_B253DFE7 ) == "" )
        setdvar( "zombie_shield_attack_freq", "15" );

    freq = getdvarint( _hash_B253DFE7 );
    self.doing_shield_attack = 1;
    self.enemyoverride[0] = shield.origin;
    self.enemyoverride[1] = shield;
    wait( randomint( 100 ) / 100.0 );
    self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "attack", self.animname );
    attackanim = "zm_riotshield_melee";

    if ( !self.has_legs )
        attackanim += "_crawl";

    self orientmode( "face point", shield.origin );
    self animscripted( self.origin, flat_angle( vectortoangles( shield.origin - self.origin ) ), attackanim );

    if ( isdefined( shield.owner.player_shield_apply_damage ) )
        shield.owner [[ shield.owner.player_shield_apply_damage ]]( 100, 0 );
    else
        shield.owner player_damage_shield( 100, 0 );

    self thread attack_shield_stop( shield );
    wait( randomint( 100 ) / 100.0 );
    self.doing_shield_attack = 0;
    self orientmode( "face default" );
}

attack_shield_stop( shield )
{
    self notify( "attack_shield_stop" );
    self endon( "attack_shield_stop" );
    self endon( "death" );

    shield waittill( "death" );

    self stopanimscripted();

    if ( isdefined( self.doing_shield_attack ) && self.doing_shield_attack )
    {
        breachanim = "zm_riotshield_breakthrough";

        if ( !self.has_legs )
            breachanim += "_crawl";

        self animscripted( self.origin, flat_angle( self.angles ), breachanim );
    }
}

window_notetracks( msg, player )
{
    self endon( "death" );

    while ( true )
    {
        self waittill( msg, notetrack );

        if ( notetrack == "end" )
            return;

        if ( notetrack == "fire" )
            player player_damage_shield( 100, 0 );
    }
}

watchstuckzombies()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "start_riotshield_deploy" );
    self endon( "destroy_riotshield" );
    self endon( "deployed_riotshield" );
    level endon( "intermission" );
    self.riotshieldentity maps\mp\zombies\_zm_equipment::item_attract_zombies();
}

riotshield_active()
{
    return self maps\mp\zombies\_zm_equipment::is_equipment_active( "riotshield_zm" );
}

riotshield_debug_print( msg, color )
{
/#
    if ( !getdvarint( _hash_BF480CE9 ) )
        return;

    if ( !isdefined( color ) )
        color = ( 1, 1, 1 );

    print3d( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), msg, color, 1, 1, 40 );
#/
}

shield_zombie_attract_func( poi )
{

}

shield_zombie_arrive_func( poi )
{
    self endon( "death" );
    self endon( "zombie_acquire_enemy" );
    self endon( "path_timer_done" );

    self waittill( "goal" );

    if ( isdefined( poi.owner ) )
    {
        poi.owner player_damage_shield( 100, 0 );

        if ( isdefined( poi.owner.player_shield_apply_damage ) )
            poi.owner [[ poi.owner.player_shield_apply_damage ]]( 100, 0 );
    }
}

createriotshieldattractor()
{
    self create_zombie_point_of_interest( 50, 8, 0, 1, ::shield_zombie_attract_func, ::shield_zombie_arrive_func );
    self thread create_zombie_point_of_interest_attractor_positions( 4, 15, 15 );
    return get_zombie_point_of_interest( self.origin );
}

riotshield_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
    if ( self is_riotshield_damage( mod, player, amount ) )
    {
        self riotshield_damage( amount );
        return true;
    }

    return false;
}

watchriotshieldattractor()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "start_riotshield_deploy" );
    self endon( "destroy_riotshield" );
    self endon( "deployed_riotshield" );
    poi = self.riotshieldentity createriotshieldattractor();
}

trackriotshieldattractor()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "deployed_riotshield" );

        self thread watchriotshieldattractor();
    }
}
