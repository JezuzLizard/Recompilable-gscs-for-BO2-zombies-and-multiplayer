// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\animscripts\zm_shared;

init()
{
    if ( !maps\mp\zombies\_zm_weapons::is_weapon_included( "blundergat_zm" ) )
        return;
    else
    {
        precacheitem( "blundersplat_bullet_zm" );
        precacheitem( "blundersplat_explosive_dart_zm" );
    }

    level.zombie_spawners = getentarray( "zombie_spawner", "script_noteworthy" );
    array_thread( level.zombie_spawners, ::add_spawn_function, ::zombie_wait_for_blundersplat_hit );
    level.custom_derive_damage_refs = ::gib_on_blundergat_damage;
    level._effect["dart_light"] = loadfx( "weapon/crossbow/fx_trail_crossbow_blink_grn_os" );
    onplayerconnect_callback( ::blundersplat_on_player_connect );
}

blundersplat_on_player_connect()
{
    self thread wait_for_blundersplat_fired();
    self thread wait_for_blundersplat_upgraded_fired();
}

zombie_wait_for_blundersplat_hit()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( weaponname == "blundersplat_bullet_zm" )
        {
            if ( !isdefined( self.titus_tagged ) )
            {
                a_grenades = getentarray( "grenade", "classname" );

                if ( !isdefined( a_grenades ) || a_grenades.size <= 0 )
                    continue;

                self.titus_tagged = 1;

                foreach ( e_grenade in a_grenades )
                {
                    if ( isdefined( e_grenade.model ) && e_grenade.model == "t6_wpn_zmb_projectile_blundergat" )
                    {
                        if ( e_grenade islinkedto( self ) )
                        {
                            while ( true )
                            {
                                if ( !isdefined( e_grenade.fuse_time ) )
                                    wait_network_frame();
                                else
                                    break;
                            }

                            n_fuse_timer = e_grenade.fuse_time;
                            e_grenade thread _titus_grenade_detonate_on_target_death( self );
                        }
                    }
                }

                self thread _titus_target_animate_and_die( n_fuse_timer, inflictor );
                self thread _titus_target_check_for_grenade_hits();
            }
        }
    }
}

wait_for_blundersplat_fired()
{
    self endon( "disconnect" );

    self waittill( "spawned_player" );

    for (;;)
    {
        self waittill( "weapon_fired", str_weapon );

        if ( str_weapon == "blundersplat_zm" )
        {
            wait_network_frame();
            _titus_locate_target( 1 );
            wait_network_frame();
            _titus_locate_target( 1 );
            wait_network_frame();
            _titus_locate_target( 1 );
        }

        wait 0.5;
    }
}

wait_for_blundersplat_upgraded_fired()
{
    self endon( "disconnect" );

    self waittill( "spawned_player" );

    for (;;)
    {
        self waittill( "weapon_fired", str_weapon );

        if ( str_weapon == "blundersplat_upgraded_zm" )
        {
            wait_network_frame();
            _titus_locate_target( 0 );
            wait_network_frame();
            _titus_locate_target( 0 );
            wait_network_frame();
            _titus_locate_target( 0 );
        }
    }
}

_titus_locate_target( is_not_upgraded )
{
    if ( !isdefined( is_not_upgraded ) )
        is_not_upgraded = 1;

    fire_angles = self getplayerangles();
    fire_origin = self getplayercamerapos();
    a_targets = arraycombine( getaiarray( "axis" ), getvehiclearray( "axis" ), 0, 0 );
    a_targets = get_array_of_closest( self.origin, a_targets, undefined, undefined, 1500 );

    if ( is_not_upgraded )
        n_fuse_timer = randomfloatrange( 1.0, 2.5 );
    else
        n_fuse_timer = randomfloatrange( 3.0, 4.0 );

    foreach ( target in a_targets )
    {
        if ( within_fov( fire_origin, fire_angles, target.origin, cos( 30 ) ) )
        {
            if ( isai( target ) )
            {
                if ( !isdefined( target.titusmarked ) )
                {
                    a_tags = [];
                    a_tags[0] = "j_hip_le";
                    a_tags[1] = "j_hip_ri";
                    a_tags[2] = "j_spine4";
                    a_tags[3] = "j_elbow_le";
                    a_tags[4] = "j_elbow_ri";
                    a_tags[5] = "j_clavicle_le";
                    a_tags[6] = "j_clavicle_ri";
                    str_tag = a_tags[randomint( a_tags.size )];
                    b_trace_pass = bullettracepassed( fire_origin, target gettagorigin( str_tag ), 1, self, target );

                    if ( b_trace_pass )
                    {
                        target thread _titus_marked();
                        e_dart = magicbullet( "blundersplat_bullet_zm", fire_origin, target gettagorigin( str_tag ), self );
                        e_dart thread _titus_reset_grenade_fuse( n_fuse_timer, is_not_upgraded );
                        return;
                    }
                }
            }
        }
    }

    vec = anglestoforward( fire_angles );
    trace_end = fire_origin + vec * 20000;
    trace = bullettrace( fire_origin, trace_end, 1, self );
    offsetpos = trace["position"] + _titus_get_spread( 80 );
    e_dart = magicbullet( "blundersplat_bullet_zm", fire_origin, offsetpos, self );
    e_dart thread _titus_reset_grenade_fuse( n_fuse_timer );
}

_titus_get_spread( n_spread )
{
    n_x = randomintrange( n_spread * -1, n_spread );
    n_y = randomintrange( n_spread * -1, n_spread );
    n_z = randomintrange( n_spread * -1, n_spread );
    return ( n_x, n_y, n_z );
}

_titus_marked()
{
    self endon( "death" );
    self.titusmarked = 1;
    wait 1;
    self.titusmarked = undefined;
}

_titus_target_animate_and_die( n_fuse_timer, inflictor )
{
    self endon( "death" );
    self endon( "titus_target_timeout" );
    self thread _titus_target_timeout( n_fuse_timer );
    self thread _titus_check_for_target_death( inflictor );
    self thread _blundersplat_target_acid_stun_anim();
    wait( n_fuse_timer );
    self notify( "killed_by_a_blundersplat", inflictor );
    self dodamage( self.health + 1000, self.origin );
}

_titus_target_check_for_grenade_hits()
{
    self endon( "death" );
    self endon( "titus_target_timeout" );

    while ( true )
    {
        self waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( weaponname == "blundersplat_bullet_zm" )
        {
            a_grenades = getentarray( "grenade", "classname" );

            foreach ( e_grenade in a_grenades )
            {
                if ( isdefined( e_grenade.model ) && e_grenade.model == "t6_wpn_zmb_projectile_blundergat" )
                {
                    if ( e_grenade islinkedto( self ) )
                        e_grenade thread _titus_grenade_detonate_on_target_death( self );
                }
            }
        }
    }
}

_titus_target_timeout( n_fuse_timer )
{
    self endon( "death" );
    wait( n_fuse_timer );
    self notify( "titus_target_timeout" );
}

_titus_check_for_target_death( inflictor )
{
    self waittill( "death" );

    self notify( "killed_by_a_blundersplat", inflictor );
    self notify( "titus_target_killed" );
}

_titus_grenade_detonate_on_target_death( target )
{
    self endon( "death" );
    target endon( "titus_target_timeout" );

    target waittill( "titus_target_killed" );

    self.fuse_reset = 1;
    self resetmissiledetonationtime( 0.05 );
}

_titus_reset_grenade_fuse( n_fuse_timer, is_not_upgraded )
{
    if ( !isdefined( is_not_upgraded ) )
        is_not_upgraded = 1;

    if ( !isdefined( n_fuse_timer ) )
        n_fuse_timer = randomfloatrange( 1, 1.5 );

    self waittill( "death" );

    a_grenades = getentarray( "grenade", "classname" );

    foreach ( e_grenade in a_grenades )
    {
        if ( isdefined( e_grenade.model ) && e_grenade.model == "t6_wpn_zmb_projectile_blundergat" && !isdefined( e_grenade.fuse_reset ) )
        {
            e_grenade.fuse_reset = 1;
            e_grenade.fuse_time = n_fuse_timer;
            e_grenade resetmissiledetonationtime( n_fuse_timer );

            if ( is_not_upgraded )
                e_grenade create_zombie_point_of_interest( 250, 5, 10000 );
            else
                e_grenade create_zombie_point_of_interest( 500, 10, 10000 );

            return;
        }
    }
}

gib_on_blundergat_damage( refs, point, weaponname )
{
    new_gib_ref = [];

    if ( isdefined( level.no_gib_in_wolf_area ) )
    {
        if ( [[ level.no_gib_in_wolf_area ]]() )
            return new_gib_ref;
    }

    if ( self.health <= 0 )
        return refs;
    else if ( weaponname == "blundergat_zm" || weaponname == "blundergat_upgraded_zm" )
    {
        new_gib_ref = self maps\mp\zombies\_zm_spawner::derive_damage_refs( point );
        return new_gib_ref;
    }

    return refs;
}

_blundersplat_target_acid_stun_anim()
{
    self endon( "death" );

    while ( true )
    {
        ground_ent = self getgroundent();

        if ( isdefined( ground_ent ) && !is_true( ground_ent.classname == "worldspawn" ) )
            self linkto( ground_ent );

        if ( is_true( self.has_legs ) )
            self animscripted( self.origin, self.angles, "zm_blundersplat_stun" );
        else
            self animscripted( self.origin, self.angles, "zm_blundersplat_stun_crawl" );

        self maps\mp\animscripts\zm_shared::donotetracks( "blundersplat_stunned_anim" );
    }
}
