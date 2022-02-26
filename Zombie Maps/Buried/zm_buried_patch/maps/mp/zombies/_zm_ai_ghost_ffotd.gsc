// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_buried;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_ai_ghost;

ghost_init_start()
{
    level ghost_bad_path_init();
    level.is_player_in_ghost_zone = ::is_player_in_ghost_zone;
    level ghost_bad_spawn_zone_init();
    level.ghost_round_start_monitor_time = 10;
}

ghost_init_end()
{
    disable_traversal_clip_around_mansion();
}

prespawn_start()
{

}

prespawn_end()
{

}

ghost_round_start()
{
    level thread ghost_teleport_to_playable_area();
}

ghost_round_end()
{
    disable_traversal_clip_around_mansion();
}

is_player_in_ghost_zone( player )
{
    result = 0;

    if ( !isdefined( level.ghost_zone_overrides ) )
        level.ghost_zone_overrides = getentarray( "ghost_round_override", "script_noteworthy" );

    is_player_in_override_trigger = 0;

    if ( isdefined( level.zombie_ghost_round_states ) && !is_true( level.zombie_ghost_round_states.is_started ) )
    {
        foreach ( trigger in level.ghost_zone_overrides )
        {
            if ( player istouching( trigger ) )
            {
                is_player_in_override_trigger = 1;
                break;
            }
        }
    }

    curr_zone = player get_current_zone();

    if ( !is_player_in_override_trigger && isdefined( curr_zone ) && curr_zone == "zone_mansion" )
        result = 1;

    return result;
}

ghost_bad_path_init()
{
    level.bad_zones = [];
    level.bad_zones[0] = spawnstruct();
    level.bad_zones[0].name = "zone_underground_courthouse";
    level.bad_zones[0].adjacent = [];
    level.bad_zones[0].adjacent[0] = "zone_underground_courthouse2";
    level.bad_zones[0].adjacent[1] = "zone_tunnels_north2";
    level.bad_zones[0].ignore_func = maps\mp\zm_buried::is_courthouse_open;
    level.bad_zones[1] = spawnstruct();
    level.bad_zones[1].name = "zone_underground_courthouse2";
    level.bad_zones[1].adjacent = [];
    level.bad_zones[1].adjacent[0] = "zone_underground_courthouse";
    level.bad_zones[1].adjacent[1] = "zone_tunnels_north2";
    level.bad_zones[1].ignore_func = maps\mp\zm_buried::is_courthouse_open;
    level.bad_zones[2] = spawnstruct();
    level.bad_zones[2].name = "zone_tunnels_north2";
    level.bad_zones[2].adjacent = [];
    level.bad_zones[2].adjacent[0] = "zone_underground_courthouse2";
    level.bad_zones[2].adjacent[1] = "zone_underground_courthouse";
    level.bad_zones[2].flag = "tunnels2courthouse";
    level.bad_zones[2].flag_adjacent = "zone_tunnels_north";
    level.bad_zones[2].ignore_func = maps\mp\zm_buried::is_courthouse_open;
    level.bad_zones[3] = spawnstruct();
    level.bad_zones[3].name = "zone_tunnels_north";
    level.bad_zones[3].adjacent = [];
    level.bad_zones[3].adjacent[0] = "zone_tunnels_center";
    level.bad_zones[3].flag = "tunnels2courthouse";
    level.bad_zones[3].flag_adjacent = "zone_tunnels_north2";
    level.bad_zones[3].ignore_func = maps\mp\zm_buried::is_tunnel_open;
    level.bad_zones[4] = spawnstruct();
    level.bad_zones[4].name = "zone_tunnels_center";
    level.bad_zones[4].adjacent = [];
    level.bad_zones[4].adjacent[0] = "zone_tunnels_north";
    level.bad_zones[4].adjacent[1] = "zone_tunnels_south";
    level.bad_zones[4].ignore_func = maps\mp\zm_buried::is_tunnel_open;
    level.bad_zones[5] = spawnstruct();
    level.bad_zones[5].name = "zone_tunnels_south";
    level.bad_zones[5].adjacent = [];
    level.bad_zones[5].adjacent[0] = "zone_tunnels_center";
    level.bad_zones[5].ignore_func = maps\mp\zm_buried::is_tunnel_open;
}

ghost_bad_path_failsafe()
{
    self endon( "death" );
    self notify( "stop_bad_path_failsafe" );
    self endon( "stop_bad_path_failsafe" );
    self thread non_ghost_round_failsafe();

    while ( true )
    {
        player = self.favoriteenemy;

        if ( isdefined( player ) )
        {
            in_bad_zone = 0;

            foreach ( zone in level.bad_zones )
            {
                if ( isdefined( zone.ignore_func ) )
                {
                    if ( level [[ zone.ignore_func ]]() )
                        break;
                }

                if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( zone.name ) )
                {
                    if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( zone.name ) )
                        break;

                    ghost_is_adjacent = 0;

                    foreach ( adjacent in zone.adjacent )
                    {
                        if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( adjacent ) )
                        {
                            ghost_is_adjacent = 1;
                            break;
                        }
                    }

                    if ( isdefined( zone.flag ) && flag( zone.flag ) )
                    {
                        if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( zone.flag_adjacent ) )
                            ghost_is_adjacent = 1;
                    }

                    if ( !ghost_is_adjacent )
                    {
                        in_bad_zone = 1;
                        break;
                    }
                }
            }

            if ( in_bad_zone )
            {
                nodes = getnodesinradiussorted( player.origin, 540, 180, 60, "Path" );

                if ( nodes.size > 0 )
                    node = nodes[randomint( nodes.size )];
                else
                    node = getnearestnode( player.origin );

                if ( isdefined( node ) )
                {
                    while ( true )
                    {
                        if ( !is_true( self.is_traversing ) )
                            break;

                        wait 0.1;
                    }

                    self forceteleport( node.origin, ( 0, 0, 0 ) );
                }
            }
        }

        wait 0.25;
    }
}

non_ghost_round_failsafe()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "bad_path" );

        if ( self.state == "runaway_update" )
        {
            if ( !maps\mp\zombies\_zm_ai_ghost::is_ghost_round_started() && is_true( self.is_spawned_in_ghost_zone ) )
            {
                self maps\mp\zombies\_zm_ai_ghost::start_evaporate( 1 );
                return;
            }
        }

        wait 0.25;
    }
}

disable_traversal_clip_around_mansion()
{
    if ( isdefined( level.ghost_zone_door_clips ) && level.ghost_zone_door_clips.size > 0 )
    {
        foreach ( door_clip in level.ghost_zone_door_clips )
            door_clip notsolid();
    }
}

ghost_bad_spawn_zone_init()
{
    level.ghost_bad_spawn_zones = [];
    level.ghost_bad_spawn_zones[0] = "zone_mansion_backyard";
    level.ghost_bad_spawn_zones[1] = "zone_maze";
    level.ghost_bad_spawn_zones[2] = "zone_maze_staircase";
}

can_use_mansion_back_flying_out_node( zone_name )
{
    if ( zone_name == "zone_mansion_backyard" )
        return true;

    if ( zone_name == "zone_maze" )
        return true;

    if ( zone_name == "zone_maze_staircase" )
        return true;

    return false;
}

ghost_teleport_to_playable_area()
{
    level endon( "intermission" );

    if ( level.intermission )
        return;

    level endon( "ghost_round_end" );
    monitor_time = 0;

    while ( true )
    {
        ghosts = get_current_ghosts();

        foreach ( ghost in ghosts )
        {
            if ( !is_true( self.is_spawned_in_ghost_zone ) && !is_true( self.is_teleported_in_bad_zone ) )
            {
                foreach ( bad_spawn_zone_name in level.ghost_bad_spawn_zones )
                {
                    if ( ghost maps\mp\zombies\_zm_zonemgr::entity_in_zone( bad_spawn_zone_name ) )
                    {
                        if ( is_player_valid( ghost.favoriteenemy ) )
                        {
                            destination_node = ghost maps\mp\zombies\_zm_ai_ghost::get_best_flying_target_node( ghost.favoriteenemy );

                            if ( isdefined( destination_node ) )
                            {
                                ghost forceteleport( destination_node.origin, ( 0, 0, 0 ) );
                                self.is_teleported_in_bad_zone = 1;
                            }
                        }

                        if ( !is_true( self.is_teleported_in_bad_zone ) )
                        {
                            if ( can_use_mansion_back_flying_out_node( bad_spawn_zone_name ) )
                                ghost forceteleport( level.ghost_back_flying_out_path_starts[0].origin, ( 0, 0, 0 ) );
                            else
                                ghost forceteleport( level.ghost_front_flying_out_path_starts[0].origin, ( 0, 0, 0 ) );

                            self.is_teleported_in_bad_zone = 1;
                        }
                    }
                }
            }
        }

        monitor_time += 0.1;

        if ( monitor_time > level.ghost_round_start_monitor_time )
            break;

        wait 0.1;
    }
}
