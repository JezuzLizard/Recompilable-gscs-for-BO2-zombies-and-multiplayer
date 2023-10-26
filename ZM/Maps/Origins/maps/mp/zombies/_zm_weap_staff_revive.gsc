// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_laststand;

init()
{
    onplayerconnect_callback( ::onplayerconnect );
}

onplayerconnect()
{
    self thread onplayerspawned();
}

onplayerspawned()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "spawned_player" );

        self thread watch_staff_revive_fired();
    }
}

watch_staff_revive_fired()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "missile_fire", e_projectile, str_weapon );

        if ( !( str_weapon == "staff_revive_zm" ) )
            continue;

        self waittill( "projectile_impact", e_ent, v_explode_point, n_radius, str_name, n_impact );

        self thread staff_revive_impact( v_explode_point );
    }
}

staff_revive_impact( v_explode_point )
{
    self endon( "disconnect" );
    e_closest_player = undefined;
    n_closest_dist_sq = 1024;
    playsoundatposition( "wpn_revivestaff_proj_impact", v_explode_point );
    a_e_players = getplayers();

    foreach ( e_player in a_e_players )
    {
        if ( e_player == self || !e_player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
            continue;

        n_dist_sq = distancesquared( v_explode_point, e_player.origin );

        if ( n_dist_sq < n_closest_dist_sq )
            e_closest_player = e_player;
    }

    if ( isdefined( e_closest_player ) )
    {
        e_closest_player notify( "remote_revive", self );
        e_closest_player playsoundtoplayer( "wpn_revivestaff_revive_plr", e_player );
        self notify( "revived_player_with_upgraded_staff" );
    }
}
