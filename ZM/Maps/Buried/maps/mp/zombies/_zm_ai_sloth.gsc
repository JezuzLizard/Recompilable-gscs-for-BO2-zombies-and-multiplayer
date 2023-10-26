// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_ai_sloth_buildables;
#include maps\mp\zombies\_zm_ai_sloth_crawler;
#include maps\mp\zombies\_zm_ai_sloth_magicbox;
#include maps\mp\zombies\_zm_ai_sloth_utility;
#include maps\mp\zombies\_zm_ai_sloth_ffotd;
#include maps\mp\zombies\_zm_ai_sloth;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_equip_headchopper;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\animscripts\zm_death;
#include maps\mp\animscripts\zm_run;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_weap_slowgun;
#include maps\mp\zombies\_zm_weap_time_bomb;

precache()
{
/#
    precachemodel( "fx_axis_createfx" );
#/
    level.small_magic_box = "p6_anim_zm_bu_magic_box_sml";
    level.small_turbine = "p6_anim_zm_bu_turbine_sml";
    precachemodel( level.small_magic_box );
    precachemodel( level.small_turbine );
    precache_fx();
    level._effect["barrier_break"] = loadfx( "maps/zombie_buried/fx_buried_barrier_break" );
    level._effect["fx_buried_sloth_building"] = loadfx( "maps/zombie_buried/fx_buried_sloth_building" );
    level._effect["fx_buried_sloth_box_slam"] = loadfx( "maps/zombie_buried/fx_buried_sloth_box_slam" );
    level._effect["fx_buried_sloth_drinking"] = loadfx( "maps/zombie_buried/fx_buried_sloth_drinking" );
    level._effect["fx_buried_sloth_eating"] = loadfx( "maps/zombie_buried/fx_buried_sloth_eating" );
    level._effect["fx_buried_sloth_glass_brk"] = loadfx( "maps/zombie_buried/fx_buried_sloth_glass_brk" );
    level._effect["fx_buried_sloth_powerup_cycle"] = loadfx( "maps/zombie_buried/fx_buried_sloth_powerup_cycle" );
}

precache_fx()
{

}

init()
{
    register_sloth_client_fields();
    flag_init( "sloth_blocker_towneast" );
    level.sloth_spawners = getentarray( "sloth_zombie_spawner", "script_noteworthy" );
    array_thread( level.sloth_spawners, ::add_spawn_function, maps\mp\zombies\_zm_ai_sloth::sloth_prespawn );
    level thread sloth_spawning_logic();
    level thread init_roam_points();
    level thread init_barricades();
    level thread init_interiors();
    level thread init_teleport_points();
    level thread init_candy_context();
    level thread init_build_buildables();
    level thread init_wallbuys();
    level thread init_generator();
    level thread init_fetch_buildables();
    level thread jail_cell_watcher();
    level thread init_hunched_volume();
    level thread init_crash_triggers();
    level thread watch_bar_couch();
    sloth_time_bomb_setup();
    level.wait_for_sloth = ::wait_for_sloth;
    level.ignore_stop_func = ::ignore_stop_func;
    level thread sloth_ffotd_init();
/#
    level.sloth_devgui_teleport = ::sloth_devgui_teleport;
    level.sloth_devgui_booze = ::sloth_devgui_booze;
    level.sloth_devgui_candy = ::sloth_devgui_candy;
    level.sloth_devgui_warp_to_jail = ::sloth_devgui_warp_to_jail;
    level.sloth_devgui_move_lamp = ::sloth_devgui_move_lamp;
    level.sloth_devgui_make_crawler = ::sloth_devgui_make_crawler;
    level.sloth_devgui_barricade = ::sloth_devgui_barricade;
    level.sloth_devgui_context = ::sloth_devgui_context;
    level.sloth_devgui_double_wide = ::sloth_devgui_double_wide;
    level thread sloth_debug_doors();
    level thread sloth_debug_barricade();
#/
}

register_sloth_client_fields()
{
    registerclientfield( "actor", "actor_is_sloth", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_berserk", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_ragdoll_zombie", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_vomit", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_buildable", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_drinking", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_eating", 12000, 1, "int" );
    registerclientfield( "actor", "sloth_glass_brk", 12000, 1, "int" );
}

init_interiors()
{
    level.interiors = [];
    level.interiors[level.interiors.size] = "zone_underground_jail";
    level.interiors[level.interiors.size] = "zone_underground_jail2";
    level.interiors[level.interiors.size] = "zone_underground_courthouse";
    level.interiors[level.interiors.size] = "zone_underground_bar";
    level.interiors[level.interiors.size] = "zone_morgue";
    level.interiors[level.interiors.size] = "zone_morgue_upstairs";
    level.interiors[level.interiors.size] = "zone_church_main";
    level.interiors[level.interiors.size] = "zone_church_upstairs";
    level.interiors[level.interiors.size] = "zone_stables";
    level.interiors[level.interiors.size] = "zone_bank";
    level.interiors[level.interiors.size] = "zone_candy_store";
    level.interiors[level.interiors.size] = "zone_candy_store_floor2";
    level.interiors[level.interiors.size] = "zone_toy_store";
    level.interiors[level.interiors.size] = "zone_toy_store_floor2";
    level.interiors[level.interiors.size] = "zone_general_store";
    level.interiors[level.interiors.size] = "zone_gun_store";
    level.interiors[level.interiors.size] = "zone_tunnels_north";
    level.interiors[level.interiors.size] = "zone_tunnels_north2";
    level.interiors[level.interiors.size] = "zone_tunnels_center";
    level.interiors[level.interiors.size] = "zone_tunnel_gun2stables";
    level.interiors[level.interiors.size] = "zone_tunnel_gun2saloon";
    level thread setup_door_markers();
}

init_teleport_points()
{
    level.maze_depart = getstructarray( "sloth_to_maze_begin", "targetname" );
    level.maze_arrive = getstructarray( "sloth_to_maze_end", "targetname" );
    level.courtyard_depart = getstructarray( "sloth_from_maze_begin", "targetname" );
    level.courtyard_arrive = getstructarray( "sloth_from_maze_end", "targetname" );
    level.maze_to_mansion = getstructarray( "sloth_maze_to_mansion", "targetname" );
}

sloth_init_roam_point()
{
    foreach ( point in level.roam_points )
    {
        if ( point.script_noteworthy == "zone_street_lightwest" )
        {
            self.current_roam = point;
            return;
        }
    }
}

watch_double_wide()
{
    self endon( "death" );
    level.double_wide_volume = getentarray( "ignore_double_wide", "targetname" );

    while ( true )
    {
        self.ignore_double_wide = 0;

        foreach ( volume in level.double_wide_volume )
        {
            if ( self istouching( volume ) )
                self.ignore_double_wide = 1;
        }

        if ( isdefined( level.double_wide_override ) )
            self [[ level.double_wide_override ]]();

        wait 0.2;
    }
}

watch_interiors()
{
    self endon( "death" );

    while ( true )
    {
        self.is_inside = 0;

        for ( i = 0; i < level.sloth_doors.size; i++ )
        {
            door_flag = level.sloth_doors[i].script_flag;

            if ( isdefined( door_flag ) )
            {
                if ( flag( door_flag ) )
                {
                    dist = distancesquared( self.origin, level.sloth_doors[i].origin );

                    if ( dist < 14400 )
                    {
                        self.is_inside = 1;
                        break;
                    }
                }
            }
        }

        for ( i = 0; i < level.sloth_hunched_structs.size; i++ )
        {
            dist = distancesquared( self.origin, level.sloth_hunched_structs[i].origin );

            if ( dist < 14400 )
            {
                self.is_inside = 1;
                break;
            }
        }

        if ( !self.is_inside )
        {
            for ( i = 0; i < level.interiors.size; i++ )
            {
                name = level.interiors[i];

                if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( name ) )
                {
                    self.is_inside = 1;
                    break;
                }
            }
        }

        if ( !self.is_inside )
        {
            if ( self istouching( level.hunched_volume ) )
                self.is_inside = 1;
        }

        if ( isdefined( level.interior_override ) )
            self [[ level.interior_override ]]();

        self sloth_update_double_wide();
        wait 0.1;
    }
}

sloth_update_double_wide()
{
/#
    if ( is_true( level.devgui_double_wide ) )
        return;
#/
    if ( is_true( self.ignore_double_wide ) || self.is_inside )
    {
        if ( self.using_double_wide )
        {
            self.using_double_wide = 0;
            setdvar( "zombie_double_wide_checks", 0 );
            self setphysparams( 15, 0, 73 );
/#
            setdvarint( "scr_sloth_debug_width", 15 );
            setdvarint( "scr_sloth_debug_height", 73 );
            self.debug_width = getdvarint( _hash_2443DFBB );
            self.debug_height = getdvarint( _hash_897C9AB4 );
#/
        }
    }
    else if ( !self.using_double_wide )
    {
        self.using_double_wide = 1;
        setdvar( "zombie_double_wide_checks", 1 );
        self setphysparams( 25, 0, 73 );
/#
        setdvarint( "scr_sloth_debug_width", 25 );
        setdvarint( "scr_sloth_debug_height", 73 );
        self.debug_width = getdvarint( _hash_2443DFBB );
        self.debug_height = getdvarint( _hash_897C9AB4 );
#/
    }
}

watch_zombies()
{
    self endon( "death" );
    level endon( "maxis_minigame_start" );

    while ( true )
    {
        all_far = 1;
        zombies = get_round_enemy_array();

        for ( i = 0; i < zombies.size; i++ )
        {
            zombie = zombies[i];
            dist = distancesquared( self.origin, zombie.origin );

            if ( dist <= 3600 )
            {
                self.near_zombies = 1;
                all_far = 0;
                continue;
            }

            if ( dist <= 14400 )
                all_far = 0;
        }

        if ( all_far )
            self.near_zombies = 0;

        wait 0.2;
    }
}

watch_player_zombies()
{
    self endon( "death" );
    self notify( "stop_player_watch" );
    self endon( "stop_player_watch" );
    level endon( "maxis_minigame_start" );

    while ( true )
    {
        if ( isdefined( self.candy_player ) )
        {
            self.target_zombies = [];
            zombies = get_round_enemy_array();

            for ( i = 0; i < zombies.size; i++ )
            {
                zombie = zombies[i];

                if ( !is_true( zombie.completed_emerging_into_playable_area ) )
                    continue;

                if ( is_true( zombie.is_traversing ) )
                    continue;

                z_delta = abs( self.candy_player.origin[2] - zombie.origin[2] );

                if ( z_delta > 120 )
                    continue;

                dist = distancesquared( self.candy_player.origin, zombie.origin );

                if ( dist <= 57600 )
                    self.target_zombies[self.target_zombies.size] = zombie;
            }
        }

        wait 0.2;
    }
}

watch_subwoofers()
{
    self endon( "death" );
    level endon( "maxis_minigame_start" );

    while ( true )
    {
        self.subwoofer = undefined;
        equipment = maps\mp\zombies\_zm_equipment::get_destructible_equipment_list();

        foreach ( item in equipment )
        {
            if ( isdefined( item.equipname ) && item.equipname == "equip_subwoofer_zm" )
            {
                if ( is_true( item.power_on ) )
                {
/#
                    self sloth_debug_context( item, sqrt( 32400 ) );
#/
                    dist = distancesquared( self.origin, item.origin );

                    if ( dist < 32400 )
                        self.subwoofer = item;
                }
            }
        }

        wait 0.2;
    }
}

watch_stink()
{
    self endon( "death" );
    level endon( "maxis_minigame_start" );

    while ( true )
    {
        self.stink = undefined;
        has_perk = 0;
        players = getplayers();

        foreach ( player in players )
        {
            if ( player hasperk( "specialty_nomotionsensor" ) )
            {
                has_perk = 1;
                break;
            }
        }

        if ( has_perk && isdefined( level.perk_vulture ) )
        {
            if ( isdefined( level.perk_vulture.zombie_stink_array ) && level.perk_vulture.zombie_stink_array.size > 0 )
            {
                foreach ( stink in level.perk_vulture.zombie_stink_array )
                {
/#
                    self sloth_debug_context( stink, 70 );
#/
                    dist = distancesquared( self.origin, stink.origin );

                    if ( dist < 4900 )
                        self.stink = stink;
                }
            }
        }

        wait 0.2;
    }
}

watch_pack_volume()
{
    volume = getent( "sloth_pack_volume", "targetname" );

    if ( isdefined( volume ) )
    {
        while ( true )
        {
            if ( self istouching( volume ) )
                self sloth_teleport_to_maze();

            wait 0.1;
        }
    }
}

watch_jail_door()
{
    self endon( "death" );

    while ( true )
    {
        level waittill( "cell_open" );

        if ( isdefined( level.jail_open_door ) )
            level thread [[ level.jail_open_door ]]( self.got_booze );
    }
}

sloth_teleport_to_maze()
{
    points = array_randomize( level.maze_arrive );
/#
    sloth_print( "teleporting to maze" );
#/
    self forceteleport( points[0].origin );

    if ( self.state == "berserk" )
        self sloth_set_state( "crash", 0 );

    wait 0.1;
}

is_towneast_open()
{
    if ( flag( "sloth_blocker_towneast" ) )
        return true;

    if ( is_general_store_open() )
        return true;

    if ( is_candy_store_open() )
        return true;

    return false;
}

is_maze_open()
{
    if ( flag( "mansion_lawn_door1" ) )
        return true;

    return false;
}

is_general_store_open()
{
    if ( flag( "general_store_door1" ) || flag( "general_store_door2" ) || flag( "general_store_door3" ) )
        return true;

    return false;
}

is_candy_store_open()
{
    if ( flag( "candy_store_door1" ) || flag( "candy2lighteast" ) )
        return true;

    return false;
}

is_bar_open()
{
    if ( flag( "bar_door1" ) )
        return true;

    if ( is_true( level.bar_couch ) )
        return true;

    return false;
}

watch_bar_couch()
{
    self endon( "stop_watch_bar_couch" );
    bar_couch_pos = ( 1021, -1754, 172 );
    bar_couch_trigger = undefined;
    debris_triggers = getentarray( "zombie_debris", "targetname" );

    foreach ( trigger in debris_triggers )
    {
        dist = distancesquared( trigger.origin, bar_couch_pos );

        if ( dist < 4096 )
        {
            bar_couch_trigger = trigger;
            break;
        }
    }

    if ( isdefined( bar_couch_trigger ) )
    {
        bar_couch_trigger waittill( "trigger" );
/#
        sloth_print( "bar couch bought" );
#/
        level.bar_couch = 1;
    }
}

sloth_behind_mansion()
{
    foreach ( point in level.maze_arrive )
    {
        dist = distancesquared( self.origin, point.origin );

        if ( dist < 360000 )
            return true;
    }

    if ( self behind_mansion_zone() )
        return true;

    return false;
}

behind_mansion_zone()
{
    behind_zones = [];
    behind_zones[behind_zones.size] = "zone_mansion_backyard";
    behind_zones[behind_zones.size] = "zone_maze";
    behind_zones[behind_zones.size] = "zone_maze_staircase";

    foreach ( zone in behind_zones )
    {
        if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( zone ) )
            return true;
    }

    return false;
}

setup_door_markers()
{
    level.sloth_doors = [];
    level.sloth_hunched_structs = getstructarray( "hunched_struct", "targetname" );
    idx = 0;
    doors = getentarray( "zombie_door", "targetname" );

    foreach ( door in doors )
    {
        level.sloth_doors[idx] = spawnstruct();
        level.sloth_doors[idx].origin = door.origin;
        level.sloth_doors[idx].script_flag = door.script_flag;
        idx++;
    }

    barricades = getentarray( "sloth_barricade", "targetname" );

    foreach ( barricade in barricades )
    {
        if ( isdefined( barricade.script_noteworthy ) && barricade.script_noteworthy == "door" )
        {
            level.sloth_doors[idx] = spawnstruct();
            level.sloth_doors[idx].origin = barricade.origin;
            level.sloth_doors[idx].script_flag = barricade.script_flag;

            if ( barricade.script_flag == "jail_door1" )
            {
                level.jail_door = level.sloth_doors[idx];
/#
                level.jail_barricade = barricade;
#/
            }

            idx++;
        }
    }
}

init_roam_points()
{
    level.roam_points = getnodearray( "sloth_roam", "targetname" );
}

init_barricades()
{
    triggers = getentarray( "sloth_barricade", "targetname" );
    level.barricade_ents = [];

    foreach ( trigger in triggers )
    {
        trigger thread watch_barricade();
        level.barricade_ents[level.barricade_ents.size] = trigger.target;
    }
}

watch_barricade()
{
    self endon( "death" );
    self endon( "maxis_minigame_opens_barricade" );
    should_delete = !isdefined( self.script_string ) || self.script_string != "no_delete";

    if ( !should_delete )
        self.func_no_delete = ::hide_sloth_barrier;

    while ( true )
    {
        self waittill( "trigger", who );

        should_break = isdefined( level.sloth ) && who == level.sloth && who.state == "berserk" && is_true( who.run_berserk );
/#
        if ( isplayer( who ) && is_true( level.devgui_break ) )
        {
            level.devgui_break = 0;
            should_break = 1;
        }
#/
        if ( should_break )
        {
            if ( !isplayer( who ) )
            {
                who sloth_set_state( "crash", 1 );
                level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "sloth_escape" );
            }

            if ( isdefined( who.booze_player ) )
            {
                who.booze_player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_sloth_booze_break_barricade", 0 );
                who.booze_player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_sloth_booze_break_barricade" );
                reward_dist = distance( who.berserk_start_org, who.origin );
                points = int( reward_dist / 10 ) * 10;
                who.booze_player maps\mp\zombies\_zm_score::add_to_player_score( points );
                who.booze_player thread sloth_clears_path_vo();
                who.booze_player = undefined;
            }

            if ( isdefined( self.script_flag ) && level flag_exists( self.script_flag ) )
            {
/#
                sloth_print( "flag_set " + self.script_flag );
#/
                flag_set( self.script_flag );

                if ( self.script_flag == "jail_door1" )
                    level notify( "jail_barricade_down" );
            }

            if ( isdefined( self.script_noteworthy ) )
            {
                if ( self.script_noteworthy == "courtyard_fountain" )
                    level notify( "courtyard_fountain_open" );
            }

            if ( isdefined( self.script_int ) )
                exploder( self.script_int );

            pieces = getentarray( self.target, "targetname" );

            foreach ( piece in pieces )
            {
                if ( should_delete )
                {
                    piece delete();
                    continue;
                }

                piece hide_sloth_barrier();
            }

            self thread maps\mp\zombies\_zm_equip_headchopper::destroyheadchopperstouching( 0 );
            self playsound( "zmb_sloth_barrier_break" );
            level notify( "sloth_breaks_barrier" );

            if ( should_delete )
                self delete();
            else
                self hide_sloth_barrier();

            return;
        }
    }
}

sloth_clears_path_vo()
{
    self endon( "death" );
    self endon( "disconnect" );
    wait 2.0;
    self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sloth_clears_path" );
}

hide_sloth_barrier()
{
    self.is_hidden = 1;
    self notsolid();
    self ghost();

    if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "clip" )
        self connectpaths();
}

unhide_sloth_barrier()
{
    self.is_hidden = 0;
    self solid();
    self show();

    if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "clip" )
        self disconnectpaths();
}

is_barricade_ent( ent )
{
    for ( i = 0; i < level.barricade_ents.size; i++ )
    {
        if ( isdefined( ent.targetname ) )
        {
            if ( ent.targetname == level.barricade_ents[i] )
                return true;
        }
    }

    return false;
}

jail_cell_watcher()
{
    level.jail_cell_volume = getent( "jail_cell_volume", "targetname" );
}

init_hunched_volume()
{
    level.hunched_volume = getent( "hunched_volume", "targetname" );
}

init_crash_triggers()
{
    level.crash_triggers = getentarray( "crash_trigger", "targetname" );

    foreach ( trigger in level.crash_triggers )
        trigger thread watch_crash_trigger();
}

watch_crash_trigger()
{
    while ( true )
    {
        self waittill( "trigger", who );

        if ( who == level.sloth && who.state == "berserk" )
        {
/#
            sloth_print( "crash trigger" );
#/
            who setclientfield( "sloth_berserk", 0 );
            who sloth_set_state( "crash", 0 );
        }
    }
}

bell_ring()
{
    level endon( "maxis_minigame_start" );

    while ( true )
    {
        level waittill( "bell_rung" );

        if ( isdefined( level.sloth ) )
        {

        }
    }
}

wait_for_sloth( wait_state )
{
    level endon( "ignore_wait" );
    sloth = level.sloth;

    if ( isdefined( sloth ) )
    {
        sloth.bench = self;

        if ( wait_state == "gunshop_arrival" )
        {
            while ( true )
            {
                if ( sloth.state == "gunshop_candy" )
                    break;

                wait 0.1;
            }
        }
        else if ( wait_state == "gunshop_table" )
            sloth waittill( "table_eat_done" );
    }
}

wait_for_timeout()
{
    level endon( "candy_bench" );

    if ( isdefined( self.bench ) )
    {
        self.bench waittill( "weap_bench_off" );

        self.bench = undefined;
        self stop_action();
        self sloth_set_state( "roam" );
    }
}

wait_for_candy()
{
    if ( isdefined( self.bench ) )
        self.bench endon( "weap_bench_off" );

    level waittill( "candy_bench" );

    self sloth_set_state( "table_eat" );
}

init_build_buildables()
{
    level.sloth_buildables = [];
    level.sloth_buildables[level.sloth_buildables.size] = "riotshield_zm";
    level.sloth_buildables[level.sloth_buildables.size] = "turret";
    level.sloth_buildables[level.sloth_buildables.size] = "raygun";
    level.sloth_buildables[level.sloth_buildables.size] = "electric_trap";
    level.sloth_buildables[level.sloth_buildables.size] = "turbine";
    level.sloth_buildables[level.sloth_buildables.size] = "springpad_zm";
    level.sloth_buildables[level.sloth_buildables.size] = "subwoofer_zm";
    level.sloth_buildables[level.sloth_buildables.size] = "headchopper_zm";
    level.sloth_buildable_zones = [];

    level waittill( "buildables_setup" );

    wait 0.1;

    foreach ( sloth_buildable in level.sloth_buildables )
    {
        foreach ( stub in level.buildable_stubs )
        {
            if ( stub.buildablezone.buildable_name == sloth_buildable )
                level.sloth_buildable_zones[level.sloth_buildable_zones.size] = stub.buildablezone;
        }
    }
}

init_wallbuys()
{
    level waittill( "buildables_setup" );

    level.sloth_wallbuy_stubs = [];

    foreach ( stub in level.buildable_stubs )
    {
        if ( isdefined( stub.in_zone ) && stub.in_zone == "zone_mansion" )
            continue;

        if ( stub.buildablezone.buildable_name == "chalk" )
            level.sloth_wallbuy_stubs[level.sloth_wallbuy_stubs.size] = stub;
    }

    level.gunshop_zone = getent( "sloth_candyzone_gunshop", "targetname" );
}

init_generator()
{
    level waittill( "buildables_setup" );

    level.generator_zones = [];

    foreach ( stub in level.buildable_stubs )
    {
        if ( stub.buildablezone.buildable_name == "oillamp_zm" )
            level.generator_zones[level.generator_zones.size] = stub.buildablezone;
    }
}

init_fetch_buildables()
{
    power_items = [];
    power_items[power_items.size] = "turret";
    power_items[power_items.size] = "electric_trap";
    power_items[power_items.size] = "subwoofer_zm";
    level.power_zones = [];

    level waittill( "buildables_setup" );

    wait 0.1;

    foreach ( stub in level.buildable_stubs )
    {
        foreach ( item in power_items )
        {
            if ( stub.buildablezone.buildable_name == item )
            {
                level.power_zones[level.power_zones.size] = stub.buildablezone;
                continue;
            }

            if ( stub.buildablezone.buildable_name == "turbine" )
                level.turbine_zone = stub.buildablezone;
        }
    }
}

init_candy_context()
{
    register_candy_context( "protect", 95, ::protect_condition, ::protect_start, ::protect_update, ::protect_action );
    register_candy_context( "build_buildable", 40, ::build_buildable_condition, ::common_context_start, ::common_context_update, ::build_buildable_action, ::build_buildable_interrupt );
    register_candy_context( "wallbuy", 80, ::wallbuy_condition, ::common_context_start, ::common_context_update, ::wallbuy_action, ::wallbuy_interrupt );
    register_candy_context( "fetch_buildable", 50, ::fetch_buildable_condition, ::fetch_buildable_start, ::common_context_update, ::fetch_buildable_action, ::fetch_buildable_interrupt );
    register_candy_context( "box_lock", 65, ::box_lock_condition, ::common_context_start, ::common_context_update, ::box_lock_action );
    register_candy_context( "box_move", 70, ::box_move_condition, ::common_context_start, ::common_context_update, ::box_move_action, ::box_move_interrupt );
    register_candy_context( "box_spin", 75, ::box_spin_condition, ::common_context_start, ::common_context_update, ::box_spin_action );
    register_candy_context( "powerup_cycle", 30, ::powerup_cycle_condition, ::common_context_start, ::common_context_update, ::powerup_cycle_action );
    register_candy_context( "crawler", 85, ::crawler_condition, ::common_context_start, ::common_context_update, ::crawler_action );
}

register_candy_context( name, priority, func_condition, func_start, func_update, func_action, func_interrupt )
{
    if ( !isdefined( level.candy_context ) )
        level.candy_context = [];

    level.candy_context[name] = spawnstruct();
    level.candy_context[name].name = name;
    level.candy_context[name].priority = priority;
    level.candy_context[name].condition = func_condition;
    level.candy_context[name].start = func_start;
    level.candy_context[name].update = func_update;
    level.candy_context[name].action = func_action;
    level.candy_context[name].interrupt = func_interrupt;
}

unregister_candy_context( name )
{
    remove_context = undefined;

    if ( !isdefined( level.candy_context ) || level.candy_context.size == 0 )
        return;

    foreach ( context in level.candy_context )
    {
        if ( context.name == name )
        {
            remove_context = context;
            break;
        }
    }

    if ( isdefined( remove_context ) )
    {
        arrayremovevalue( level.candy_context, remove_context, 1 );
/#
        sloth_print( remove_context.name + " removed from candy context" );
#/
    }
}

sloth_grab_powerup()
{
    for ( i = 0; i < level.active_powerups.size; i++ )
    {
        powerup = level.active_powerups[i];
        dist = distancesquared( powerup.origin, self.origin );

        if ( dist < 9216 )
        {
            if ( isdefined( self.follow_player ) )
                self.follow_player.ignore_range_powerup = powerup;
        }
    }
}

sloth_prespawn()
{
    self endon( "death" );
    level endon( "intermission" );
    level.sloth = self;

    if ( !isdefined( level.possible_slowgun_targets ) )
        level.possible_slowgun_targets = [];

    level.possible_slowgun_targets[level.possible_slowgun_targets.size] = self;
    self sloth_init_update_funcs();
    self sloth_init_start_funcs();
    self.has_legs = 1;
    self.no_gib = 1;
    self.nododgemove = 1;
    self.is_sloth = 1;
    self.ignore_enemy_count = 1;
    recalc_zombie_array();
    self setphysparams( 15, 0, 73 );
/#
    setdvarint( "scr_sloth_debug_width", 15 );
    setdvarint( "scr_sloth_debug_height", 73 );
    self.debug_width = getdvarint( _hash_2443DFBB );
    self.debug_height = getdvarint( _hash_897C9AB4 );
    self thread sloth_devgui_update_phys_params();
#/
    self.ignore_nuke = 1;
    self.ignore_lava_damage = 1;
    self.ignore_devgui_death = 1;
    self.ignore_electric_trap = 1;
    self.ignore_game_over_death = 1;
    self.ignore_enemyoverride = 1;
    self.ignore_solo_last_stand = 1;
    self.ignore_riotshield = 1;
    self.paralyzer_hit_callback = ::sloth_paralyzed;
    self.paralyzer_slowtime = 0;
    self.allowpain = 0;
    self.jail_start = getstruct( "sloth_idle_pos", "targetname" );
    self forceteleport( self.jail_start.origin, self.jail_start.angles );
    self.gunshop = getstruct( "sloth_gunshop", "targetname" );
    self set_zombie_run_cycle( "walk" );
    self.locomotion = "walk";
    self animmode( "normal" );
    self orientmode( "face enemy" );
    self maps\mp\zombies\_zm_spawner::zombie_setup_attack_properties();
    self maps\mp\zombies\_zm_spawner::zombie_complete_emerging_into_playable_area();
    self setfreecameralockonallowed( 0 );
    self.zmb_vocals_attack = "zmb_vocals_zombie_attack";

    if ( !isdefined( self.sndent ) )
    {
        origin = self gettagorigin( "J_neck" );
        self.sndent = spawn( "script_origin", origin );
        self.sndent linkto( self, "J_neck" );
    }

    self.meleedamage = 5;
    self.ignoreall = 1;
    self.ignoreme = 1;
    self.ignore_spring_pad = 1;
    self.ignore_headchopper = 1;
    self thread create_candy_booze_trigger();
    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
    self.needs_action = 1;
    self.actor_damage_func = ::sloth_damage_func;
    self.non_attacker_func = ::sloth_non_attacker;
    self.set_anim_rate = ::sloth_set_anim_rate;
    self.reset_anim = ::sloth_reset_anim;
    self sloth_set_traverse_funcs();
    self disableaimassist();
    self.goalradius = 16;
    self pushplayer( 1 );
    self.anchor = spawn( "script_origin", self.origin );
    self.anchor.angles = self.angles;
    self.is_inside = 1;
    self.near_zombies = 0;
    self.aiteam = "allies";
    self.using_double_wide = 0;
    self thread sloth_init_roam_point();
    self thread watch_double_wide();
    self thread watch_interiors();
    self thread watch_zombies();
    self thread watch_stink();
    self thread watch_pack_volume();
    self thread watch_jail_door();
    self thread watch_crash_pos();
    self.headbang_time = gettime();
    self.smell_time = gettime();
    self.leg_pain_time = gettime();
    self.to_maze = 1;
    self.from_maze = 0;
    self.damage_taken = 0;
    self setclientfield( "actor_is_sloth", 1 );
/#
    self thread sloth_debug_buildables();
#/
    self thread sloth_ffotd_prespawn();
}

sloth_set_traverse_funcs()
{
    self.pre_traverse = ::sloth_pre_traverse;
    self.post_traverse = ::sloth_post_traverse;
}

sloth_pre_traverse()
{
    if ( !self is_jail_state() )
    {
        if ( self.state == "context" )
        {
            if ( isdefined( self.buildable_model ) )
            {
                self setanimstatefromasd( "zm_sling_equipment" );
                self maps\mp\animscripts\zm_shared::donotetracks( "sling_equipment_anim" );
            }
            else if ( is_true( self.box_model_visible ) )
            {
                self setanimstatefromasd( "zm_sling_magicbox" );
                self maps\mp\animscripts\zm_shared::donotetracks( "sling_magicbox_anim" );
            }
        }
        else
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.gift_trigger );
    }
}

sloth_post_traverse()
{
    if ( !self is_jail_state() )
    {
        if ( self.state == "context" )
        {
            if ( isdefined( self.buildable_model ) )
            {
                self setanimstatefromasd( "zm_unsling_equipment" );
                self maps\mp\animscripts\zm_shared::donotetracks( "unsling_equipment_anim" );
            }
            else if ( is_true( self.box_model_visible ) )
            {
                self setanimstatefromasd( "zm_unsling_magicbox" );
                self maps\mp\animscripts\zm_shared::donotetracks( "unsling_magicbox_anim" );
            }
        }
        else
            maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
    }
}

sloth_spawning_logic()
{
    level endon( "intermission" );

    if ( level.intermission )
        return;
/#
    if ( getdvarint( _hash_FA81816F ) == 2 || getdvarint( _hash_FA81816F ) >= 4 )
        return;
#/
/#
    while ( !is_true( level.sloth_enable ) )
    {
        wait 0.2;
        continue;
    }
#/
    spawner = getent( "sloth_zombie_spawner", "script_noteworthy" );

    if ( !isdefined( spawner ) )
    {
/#
        assertmsg( "No sloth spawner in the map." );
#/
        return;
    }

    ai = spawn_zombie( spawner, "sloth" );

    if ( !isdefined( ai ) )
    {
/#
        assertmsg( "Sloth: failed spawn" );
#/
        return;
    }

    ai waittill( "zombie_init_done" );

    ai sloth_set_state( "jail_idle" );
    ai thread sloth_think();
/#

#/
    level._sloth_ai = ai;
}

sloth_init_update_funcs()
{
    self.update_funcs = [];
    self.update_funcs["jail_idle"] = ::update_jail_idle;
    self.update_funcs["jail_cower"] = ::update_jail_cower;
    self.update_funcs["jail_open"] = ::update_jail_open;
    self.update_funcs["jail_run"] = ::update_jail_run;
    self.update_funcs["jail_wait"] = ::update_jail_wait;
    self.update_funcs["jail_close"] = ::update_jail_close;
    self.update_funcs["player_idle"] = ::update_player_idle;
    self.update_funcs["roam"] = ::update_roam;
    self.update_funcs["follow"] = ::update_follow;
    self.update_funcs["mansion"] = ::update_mansion;
    self.update_funcs["berserk"] = ::update_berserk;
    self.update_funcs["eat"] = ::update_eat;
    self.update_funcs["crash"] = ::update_crash;
    self.update_funcs["gunshop_run"] = ::update_gunshop_run;
    self.update_funcs["gunshop_candy"] = ::update_gunshop_candy;
    self.update_funcs["table_eat"] = ::update_table_eat;
    self.update_funcs["headbang"] = ::update_headbang;
    self.update_funcs["smell"] = ::update_smell;
    self.update_funcs["context"] = ::update_context;
    self.locomotion_func = ::update_locomotion;
}

sloth_think()
{
    self endon( "death" );

    while ( true )
    {
        self [[ self.update_funcs[self.state] ]]();
        wait 0.1;
    }
}

update_jail_idle()
{
    if ( is_true( self.open_jail ) )
    {
        level notify( "cell_open" );
        self.open_jail = 0;
    }

    if ( is_true( level.cell_open ) )
    {
        self stop_action();
        self sloth_set_state( "jail_cower" );
        maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
    }
}

update_jail_cower()
{
    if ( is_true( self.got_booze ) && is_true( level.cell_open ) )
    {
        player = self get_player_to_follow();

        if ( isdefined( player ) )
        {
            self sloth_set_state( "follow", player );
            return;
        }
    }
}

update_jail_open()
{
    if ( self.needs_action )
        self sloth_set_state( "jail_cower" );
}

update_jail_run()
{
    if ( self.needs_action )
        self sloth_set_state( "jail_wait" );
}

update_jail_wait()
{
    players = get_players();

    foreach ( player in players )
    {
        if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_underground_jail" ) )
        {
            if ( is_holding_candybooze( player ) )
            {
                maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
                self sloth_set_state( "follow", player );
            }

            return;
        }
    }

    foreach ( player in players )
    {
        if ( is_player_valid( player ) )
        {
            dist = distancesquared( player.origin, level.jail_door.origin );

            if ( dist < 32400 )
                return;
        }
    }

    if ( self.needs_action )
        self sloth_set_state( "jail_close" );
}

update_jail_close()
{
    if ( self.needs_action )
        self sloth_set_state( "jail_idle" );
}

update_player_idle()
{
    if ( self sloth_is_pain() )
        return;

    if ( self sloth_is_traversing() )
        return;

    if ( isdefined( self.follow_player ) )
    {
        player = self.follow_player;

        if ( is_true( player.is_in_ghost_zone ) || !sloth_on_same_side( player ) )
        {
            self sloth_set_state( "mansion" );
            return;
        }

        if ( is_holding_candybooze( self.follow_player ) )
        {
            player_dist = distancesquared( self.origin, self.follow_player.origin );

            if ( player_dist > 20736 )
            {
                self sloth_set_state( "follow", self.follow_player );
                return;
            }
        }
        else
        {
            self sloth_set_state( "roam" );
            return;
        }

        self orientmode( "face point", self.follow_player.origin );
        gimme_anim = undefined;

        if ( is_holding( self.follow_player, "booze" ) )
            gimme_anim = "zm_gimme_booze";
        else if ( is_holding( self.follow_player, "candy" ) )
            gimme_anim = "zm_gimme_candy";

        if ( !is_true( self.damage_accumulating ) )
            self action_player_idle( gimme_anim );
    }
    else
        self sloth_set_state( "roam" );
}

update_locomotion()
{
    should_run = gettime() < self.leg_pain_time;

    if ( should_run )
    {
        self sloth_check_ragdolls();

        if ( self.zombie_move_speed == "run" )
        {
            if ( self.is_inside )
            {
                self set_zombie_run_cycle( "run_hunched" );
                self.locomotion = "run_hunched";
            }
        }
        else if ( self.zombie_move_speed == "run_hunched" )
        {
            if ( !self.is_inside )
            {
                self set_zombie_run_cycle( "run" );
                self.locomotion = "run";
            }
        }
        else if ( self.is_inside )
        {
            self set_zombie_run_cycle( "run_hunched" );
            self.locomotion = "run_hunched";
        }
        else
        {
            self set_zombie_run_cycle( "run" );
            self.locomotion = "run";
        }
    }
    else if ( self.zombie_move_speed == "run" || self.zombie_move_speed == "run_hunched" )
    {
        if ( self.is_inside )
        {
            self set_zombie_run_cycle( "walk_hunched" );
            self.locomotion = "walk_hunched";
        }
        else if ( self.near_zombies )
        {
            self set_zombie_run_cycle( "walk_scared" );
            self.locomotion = "walk_scared";
        }
        else
        {
            self set_zombie_run_cycle( "walk" );
            self.locomotion = "walk";
        }
    }
    else if ( self.zombie_move_speed == "walk" )
    {
        if ( self.is_inside )
        {
            self set_zombie_run_cycle( "walk_hunched" );
            self.locomotion = "walk_hunched";
        }
        else if ( self.near_zombies )
        {
            self set_zombie_run_cycle( "walk_scared" );
            self.locomotion = "walk_scared";
        }
    }
    else if ( self.zombie_move_speed == "walk_scared" )
    {
        if ( self.is_inside )
        {
            self set_zombie_run_cycle( "walk_hunched" );
            self.locomotion = "walk_hunched";
        }
        else if ( !self.near_zombies )
        {
            self set_zombie_run_cycle( "walk" );
            self.locomotion = "walk";
        }
    }
    else if ( self.zombie_move_speed == "walk_hunched" )
    {
        if ( !self.is_inside )
        {
            self set_zombie_run_cycle( "walk" );
            self.locomotion = "walk";
        }
    }
}

update_roam()
{
    if ( self sloth_is_pain() )
        return;

    self.ignore_timebomb_slowdown = 0;

    if ( isdefined( self.locomotion_func ) )
        self [[ self.locomotion_func ]]();

    player = self get_player_to_follow();

    if ( isdefined( player ) )
    {
        self sloth_set_state( "follow", player );
        return;
    }

    if ( isdefined( self.mansion_goal ) )
    {
        self setgoalpos( self.mansion_goal.origin );
        dist = distancesquared( self.origin, self.mansion_goal.origin );

        if ( dist < 1024 )
        {
            self action_teleport_to_courtyard();
            self stop_action();
            return;
        }
    }

    if ( self should_smell() )
    {
        self sloth_set_state( "smell" );
        return;
    }

    if ( is_true( self.needs_action ) )
    {
        points = array_randomize( level.roam_points );
        self thread action_roam_point( points[0] );
    }
}

get_player_to_follow()
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( is_holding_candybooze( player ) )
            return player;
    }
}

should_headbang()
{
    if ( self sloth_is_traversing() )
        return false;

    if ( isdefined( self.subwoofer ) )
    {
        if ( gettime() > self.headbang_time )
            return true;
    }

    return false;
}

should_smell()
{
    if ( self sloth_is_traversing() )
        return false;

    if ( isdefined( self.stink ) )
    {
        if ( gettime() > self.smell_time )
            return true;
    }

    return false;
}

update_follow()
{
    if ( self sloth_is_pain() )
        return;

    if ( isdefined( self.locomotion_func ) )
        self [[ self.locomotion_func ]]();

    if ( self should_smell() )
    {
        self sloth_set_state( "smell" );
        return;
    }

    player = self.follow_player;

    if ( isdefined( player ) )
    {
        if ( is_holding_candybooze( player ) )
        {
            player_dist = distancesquared( self.origin, player.origin );

            if ( is_true( player.is_in_ghost_zone ) || !sloth_on_same_side( player ) )
                self sloth_set_state( "mansion" );
            else if ( player_dist < 8100 )
                self sloth_set_state( "player_idle" );
            else
                self action_player_follow( player );
        }
        else
            self sloth_set_state( "roam" );
    }
}

sloth_on_same_side( player )
{
    if ( self sloth_behind_mansion() )
    {
        if ( player behind_mansion_zone() )
            return true;
    }
    else if ( !player behind_mansion_zone() )
        return true;

    return false;
}

update_mansion()
{
    player = self.follow_player;

    if ( isdefined( player ) )
    {
        if ( is_holding_candybooze( player ) )
        {
            if ( is_true( player.is_in_ghost_zone ) )
            {
                name = player.current_ghost_room_name;

                if ( isdefined( name ) )
                {
                    room = level.ghost_rooms[name];

                    if ( is_true( room.to_maze ) )
                    {
                        self.to_maze = 1;
                        self.from_maze = 0;
                    }
                    else if ( is_true( room.from_maze ) )
                    {
                        self.to_maze = 0;
                        self.from_maze = 1;
                    }
                }
            }
            else
            {
                if ( self sloth_on_same_side( player ) )
                {
                    self sloth_set_state( "follow", player );
                    return;
                }

                if ( self sloth_behind_mansion() )
                {
                    self.to_maze = 0;
                    self.from_maze = 1;
                }
                else
                {
                    self.to_maze = 1;
                    self.from_maze = 0;
                }
            }

            if ( isdefined( self.teleporting ) )
            {
                if ( self.teleporting == "to_maze" )
                {
                    if ( self sloth_behind_mansion() )
                        self.teleporting = undefined;
                }
                else if ( self.teleporting == "to_courtyard" )
                {
                    if ( !self sloth_behind_mansion() )
                        self.teleporting = undefined;
                }

                return;
            }

            if ( is_true( self.to_maze ) && !self sloth_behind_mansion() )
                self action_navigate_mansion( level.maze_depart, level.maze_arrive );
            else if ( is_true( self.from_maze ) && self sloth_behind_mansion() )
                self action_navigate_mansion( level.courtyard_depart, level.courtyard_arrive );
        }
        else
            self sloth_set_state( "roam" );
    }
}

update_drink()
{
    if ( is_true( self.needs_action ) )
        self sloth_set_state( "berserk" );
}

sloth_check_ragdolls( ignore_zombie )
{
    non_ragdoll = 0;
    zombies = getaispeciesarray( level.zombie_team, "all" );

    for ( i = 0; i < zombies.size; i++ )
    {
        zombie = zombies[i];

        if ( is_true( zombie.is_sloth ) )
            continue;

        if ( isdefined( ignore_zombie ) && zombie == ignore_zombie )
            continue;

        if ( isdefined( self.crawler ) && zombie == self.crawler )
            continue;

        if ( self is_facing( zombie ) )
        {
            dist = distancesquared( self.origin, zombie.origin );

            if ( dist < 4096 )
            {
                if ( !self sloth_ragdoll_zombie( zombie ) )
                {
                    if ( !is_true( self.no_gib ) && non_ragdoll % 3 == 0 )
                    {
                        zombie.force_gib = 1;
                        zombie.a.gib_ref = random( array( "guts", "right_arm", "left_arm", "head" ) );
                        zombie thread maps\mp\animscripts\zm_death::do_gib();
                    }

                    non_ragdoll++;
                    zombie dodamage( zombie.health * 10, zombie.origin );
                    zombie playsound( "zmb_ai_sloth_attack_impact" );
                    zombie.noragdoll = 1;
                    zombie.nodeathragdoll = 1;
                    level.zombie_total++;
                }

                if ( isdefined( self.target_zombie ) && self.target_zombie == zombie )
                    self.target_zombie = undefined;
            }
        }
    }
}

sloth_ragdoll_zombie( zombie )
{
    if ( !isdefined( self.ragdolls ) )
        self.ragdolls = 0;

    if ( self.ragdolls < 4 )
    {
        self.ragdolls++;
        zombie dodamage( zombie.health * 10, zombie.origin );
        zombie playsound( "zmb_ai_sloth_attack_impact" );
        zombie startragdoll();
        zombie setclientfield( "sloth_ragdoll_zombie", 1 );
        level.zombie_total++;
        self thread sloth_ragdoll_wait();
        return true;
    }

    return false;
}

sloth_ragdoll_wait()
{
    self endon( "death" );
    wait 1;

    if ( self.ragdolls > 0 )
        self.ragdolls--;
}

sloth_kill_zombie( zombie )
{
    if ( !self sloth_ragdoll_zombie( zombie ) )
    {
        if ( !is_true( self.no_gib ) )
        {
            zombie.force_gib = 1;
            zombie.a.gib_ref = random( array( "guts", "right_arm", "left_arm", "head" ) );
            zombie thread maps\mp\animscripts\zm_death::do_gib();
        }

        zombie dodamage( zombie.health * 10, zombie.origin );
        zombie playsound( "zmb_ai_sloth_attack_impact" );
    }
}

update_berserk()
{
    if ( !is_true( self.run_berserk ) )
        return;

    self sloth_grab_powerup();
    self sloth_check_ragdolls();
    self.ignore_timebomb_slowdown = 1;
    start = self.origin + vectorscale( ( 0, 0, 1 ), 39.0 );
    facing = anglestoforward( self.angles );
    end = start + facing * 48;
    crash = 0;
    trace = physicstrace( start, end, vectorscale( ( -1, -1, 0 ), 15.0 ), vectorscale( ( 1, 1, 0 ), 15.0 ), self );
/#
    if ( getdvarint( _hash_B6252E7C ) == 2 )
        line( start, end, ( 1, 0, 0 ), 1, 0, 100 );
#/
    if ( isdefined( trace["entity"] ) )
    {
        hit_ent = trace["entity"];

        if ( is_true( hit_ent.is_zombie ) )
            return;
        else if ( isplayer( hit_ent ) )
        {
            if ( !is_true( self.slowing ) )
            {
                hit_ent dodamage( hit_ent.health, hit_ent.origin );
/#
                sloth_print( "hit player" );
#/
            }

            return;
        }
        else if ( is_barricade_ent( hit_ent ) )
        {
/#
            if ( isdefined( hit_ent.targetname ) )
                sloth_print( "hit barricade ent " + hit_ent.targetname );
#/
            return;
        }
        else
        {
/#
            if ( isdefined( hit_ent.targetname ) )
                sloth_print( "hit " + hit_ent.targetname );
#/
            if ( isdefined( hit_ent.targetname ) && hit_ent.targetname == "sloth_fountain_clip" )
            {
                fountain = getent( "courtyard_fountain", "script_noteworthy" );

                if ( isdefined( fountain ) )
                {
                    fountain notify( "trigger", self );
                    return;
                }
            }

            crash = 1;
        }
    }

    if ( isdefined( trace["fraction"] ) && trace["fraction"] < 1 )
        crash = 1;

    if ( gettime() > self.berserk_time + 500 )
    {
        dist = distancesquared( self.origin, self.berserk_org );

        if ( dist < 900 )
        {
/#
            sloth_print( "BERSERK FAILSAFE!!!" );
#/
            crash = 1;
        }

        self.berserk_org = self.origin;
        self.berserk_time = gettime();
    }

    if ( crash && self.state != "crash" )
    {
        self setclientfield( "sloth_berserk", 0 );
        self sloth_set_state( "crash", 0 );
    }
}

update_eat()
{
    if ( is_true( self.needs_action ) )
    {
        self setclientfield( "sloth_eating", 0 );

        if ( isdefined( self.candy_model ) )
            self.candy_model ghost();

        context = self check_contextual_actions();

        if ( isdefined( context ) )
        {
            if ( isdefined( self.candy_player ) )
            {
                self.candy_player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_sloth_candy_" + context.name, 0 );
                self.candy_player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_sloth_candy_" + context.name );
                self.candy_player thread sloth_feed_vo();
            }

            self sloth_set_state( "context", context );
            return;
        }

        self sloth_set_state( "roam" );
    }
}

update_crash()
{
    if ( is_true( self.needs_action ) )
    {
        self.reset_asd = undefined;
        maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
        self notify( "stop_berserk" );
        self sloth_set_state( "roam" );
    }
}

update_gunshop_run()
{
    if ( is_true( self.needs_action ) )
        self sloth_set_state( "gunshop_candy" );
}

update_gunshop_candy()
{

}

update_table_eat()
{
    if ( is_true( self.needs_action ) )
        self sloth_set_state( "roam" );
}

update_headbang()
{
    if ( gettime() > self.headbang_time )
    {
        self.headbang_time = gettime() + 30000;
        self stop_action();
        self sloth_set_state( "roam" );
    }
}

update_smell()
{
    if ( is_true( self.needs_action ) )
    {
        self.smell_time = gettime() + 30000;
        self sloth_set_state( "roam" );
    }
}

update_context()
{
    self [[ self.context.update ]]();
}

sloth_init_start_funcs()
{
    self.start_funcs = [];
    self.start_funcs["jail_idle"] = ::start_jail_idle;
    self.start_funcs["jail_cower"] = ::start_jail_cower;
    self.start_funcs["jail_open"] = ::start_jail_open;
    self.start_funcs["jail_run"] = ::start_jail_run;
    self.start_funcs["jail_wait"] = ::start_jail_wait;
    self.start_funcs["jail_close"] = ::start_jail_close;
    self.start_funcs["player_idle"] = ::start_player_idle;
    self.start_funcs["roam"] = ::start_roam;
    self.start_funcs["follow"] = ::start_follow;
    self.start_funcs["mansion"] = ::start_mansion;
    self.start_funcs["berserk"] = ::start_berserk;
    self.start_funcs["eat"] = ::start_eat;
    self.start_funcs["crash"] = ::start_crash;
    self.start_funcs["gunshop_run"] = ::start_gunshop_run;
    self.start_funcs["gunshop_candy"] = ::start_gunshop_candy;
    self.start_funcs["table_eat"] = ::start_table_eat;
    self.start_funcs["headbang"] = ::start_headbang;
    self.start_funcs["smell"] = ::start_smell;
    self.start_funcs["context"] = ::start_context;
}

sloth_set_state( state, param2 )
{
    if ( isdefined( self.start_funcs[state] ) )
    {
        result = 0;

        if ( isdefined( param2 ) )
            result = self [[ self.start_funcs[state] ]]( param2 );
        else
            result = self [[ self.start_funcs[state] ]]();

        if ( result == 1 )
        {
            self.state = state;
/#
            sloth_print( "change state to " + self.state );
#/
        }
    }
}

start_jail_idle()
{
    self thread action_jail_idle();
    self thread sndchangebreathingstate( "breathe" );
    return 1;
}

start_jail_cower()
{
    self thread action_jail_cower( self.got_booze );
    self thread sndchangebreathingstate( "scared" );
    return 1;
}

start_jail_close()
{
    self thread action_jail_close();
    self thread sndchangebreathingstate( "breathe" );
    return 1;
}

start_jail_open()
{
    self thread action_jail_open();
    return 1;
}

is_jail_state()
{
    states = [];
    states[states.size] = "jail_idle";
    states[states.size] = "jail_cower";
    states[states.size] = "jail_open";
    states[states.size] = "jail_run";
    states[states.size] = "jail_wait";
    states[states.size] = "jail_close";

    foreach ( state in states )
    {
        if ( self.state == state )
            return true;
    }

    return false;
}

start_jail_run( do_pain )
{
    if ( self is_jail_state() )
        return false;

    if ( self.state == "berserk" || self.state == "crash" )
        return false;

    if ( self sloth_is_traversing() )
        return false;

    if ( self.state == "gunshop_candy" || self.state == "table_eat" )
    {
        if ( isdefined( self.bench ) )
        {
            if ( isdefined( level.weapon_bench_reset ) )
                self.bench [[ level.weapon_bench_reset ]]();
        }
    }

    self stop_action();
    self thread sndchangebreathingstate( "scared" );
    self thread action_jail_run( self.jail_start.origin, do_pain );

    if ( self.state == "context" )
    {
        if ( isdefined( self.context.interrupt ) )
            self [[ self.context.interrupt ]]();
    }

    self sloth_init_roam_point();
    thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.gift_trigger );
    return true;
}

start_jail_wait()
{
    self stopanimscripted();
    self action_jail_wait();
    self thread sndchangebreathingstate( "scared" );
    return 1;
}

start_player_idle( lock )
{
    if ( self sloth_is_traversing() )
        return false;

    if ( self.state == "jail_cower" )
        return false;

    if ( is_true( lock ) )
    {
        self orientmode( "face default" );
        self.anchor.origin = self.origin;
        self.anchor.angles = self.angles;
        self linkto( self.anchor );
    }

    gimme_anim = undefined;

    if ( is_holding( self.follow_player, "booze" ) )
        gimme_anim = "zm_gimme_booze";
    else if ( is_holding( self.follow_player, "candy" ) )
        gimme_anim = "zm_gimme_candy";

    if ( !is_true( self.damage_accumulating ) )
        self action_player_idle( gimme_anim );

    self thread sndchangebreathingstate( "happy" );
    return true;
}

check_behind_mansion()
{
    if ( self sloth_behind_mansion() )
    {
/#
        sloth_print( "get back to mansion first" );
#/
        near = ( 3652, -500, 20 );

        foreach ( point in level.maze_to_mansion )
        {
            dist = distance( point.origin, near );

            if ( dist < 10 )
                self.mansion_goal = point;
        }
    }
    else
        self.mansion_goal = undefined;
}

start_roam()
{
    self stop_action();
    self thread sndchangebreathingstate( "breathe", "happy" );
    self maps\mp\animscripts\zm_run::needsupdate();
    self.follow_player = undefined;
    self.candy_player = undefined;
    self check_behind_mansion();
    return 1;
}

start_follow( player )
{
    self stop_action();
    self thread sndchangebreathingstate( "happy" );
    self set_zombie_run_cycle( "walk" );
    self.locomotion = "walk";
    self.follow_player = player;
    self.current_roam = undefined;
    return 1;
}

start_mansion()
{
    self stop_action();
    self thread sndchangebreathingstate( "scared" );
    self maps\mp\animscripts\zm_run::needsupdate();
    self.can_follow = 0;
    return 1;
}

start_berserk( player )
{
    self thread remove_gift_trigger( 0.1 );

    if ( !is_true( self.got_booze ) )
        self.got_booze = 1;

    self.booze_player = player;
    self.berserk_start_org = self.origin;
    self.berserk_org = self.origin;
    self.booze_player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_sloth_booze_given", 0 );
    self.booze_player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_sloth_booze_given" );
    self setclientfield( "sloth_berserk", 1 );
    player thread sloth_feed_vo();
    closest = self get_facing_barricade();

    if ( !isdefined( closest ) )
    {
/#
        sloth_print( "failed to get barricade assist, try player" );
#/
        closest = player get_facing_barricade( 1 );

        if ( isdefined( closest ) )
            self.aim_barricade = closest;
    }

    self.run_berserk = 0;
    self action_berserk( self.follow_player );
    self thread sndchangebreathingstate( "angry" );
    return 1;
}

sloth_feed_vo()
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( !( isdefined( level.sloth_has_been_given_booze ) && level.sloth_has_been_given_booze ) )
    {
        level.sloth_has_been_given_booze = 1;
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "first_bersek" );
    }
    else
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sloth_generic_feed" );
}

sloth_debug_barricade()
{
/#
    while ( true )
    {
        player = gethostplayer();

        if ( !isdefined( player ) )
        {
            wait 1;
            continue;
        }

        if ( getdvarint( _hash_B6252E7C ) != 3 )
        {
            wait 1;
            continue;
        }

        closest = player get_facing_barricade( 1 );
        wait 1;
    }
#/
}

get_facing_barricade( ignore_segment_dist )
{
    max_dist = 144000000;
    closest = undefined;
    closest_dot = 0;
    closest_dot_position = 0;
    closest_dot_facing = 0;
    closest_segment_point = undefined;

    if ( isplayer( self ) )
    {
        angles = self getplayerangles();
        vec_forward = vectornormalize( anglestoforward( flat_angle( angles ) ) );
    }
    else
    {
        angles = self.angles;
        vec_forward = vectornormalize( anglestoforward( flat_angle( angles ) ) ) * -1;
    }

    triggers = getentarray( "sloth_barricade", "targetname" );

    for ( i = 0; i < triggers.size; i++ )
    {
        barricade = triggers[i];

        if ( isdefined( barricade ) )
        {
            if ( isdefined( barricade.script_noteworthy ) && barricade.script_noteworthy == "courtyard_fountain" )
                continue;

            ground_pos = groundpos( barricade.origin );
            start = ( self.origin[0], self.origin[1], ground_pos[2] );
            barricade_dist = distance( ground_pos, start );

            if ( barricade_dist > 900 )
                continue;

            segment_length = barricade_dist * 2;
            end = start + vec_forward * segment_length;
            segment_point = pointonsegmentnearesttopoint( start, end, ground_pos );
            vec_barricade = vectornormalize( anglestoforward( barricade.angles ) ) * -1;
            dot_barricade = vectordot( vec_forward, vec_barricade );

            if ( dot_barricade < 0.707 )
                continue;

            vec_position = vectornormalize( ground_pos - start );
            dot_position = vectordot( vec_position, vec_barricade );

            if ( dot_position < 0.707 )
                continue;

            dot_facing_pos = vectordot( vec_position, vec_forward );
            dist = distancesquared( ground_pos, segment_point );

            if ( !is_true( ignore_segment_dist ) )
            {
                if ( dist > 10000 )
                    continue;
            }

            if ( dist < max_dist )
            {
                max_dist = dist;
                closest = barricade;
                closest_segment_point = segment_point;
                closest_dot = dot_barricade;
                closest_dot_position = dot_position;
                closest_dot_facing = dot_facing_pos;
            }
        }
    }

    if ( isdefined( closest ) )
    {
        ground_pos = groundpos( closest.origin );
/#
        if ( getdvarint( _hash_B6252E7C ) == 3 )
            line( closest_segment_point, ground_pos, ( 0, 1, 0 ), 1, 0, 60 );
#/
        dist = distancesquared( closest_segment_point, ground_pos );
        self.aim_barricade = closest;
        barricade_dist = distance( self.origin, ground_pos );
/#
        if ( getdvarint( _hash_B6252E7C ) == 3 )
            line( self.origin, ground_pos, ( 1, 1, 1 ), 1, 0, 60 );
#/
    }

    return closest;
}

barricade_assist()
{
    max_dist = 144000000;
    closest = undefined;
    closest_dot = 0;
    closest_segment_point = undefined;
    vec_forward = vectornormalize( anglestoforward( self.angles ) );
    vec_backward = vec_forward * -1;
    triggers = getentarray( "sloth_barricade", "targetname" );

    for ( i = 0; i < triggers.size; i++ )
    {
        barricade = triggers[i];

        if ( isdefined( barricade ) )
        {
            ground_pos = groundpos( barricade.origin );
            barricade_dist = distance( ground_pos, self.origin );
            segment_length = barricade_dist * 2;
            sloth_start = self.origin;
            sloth_end = self.origin + vec_backward * segment_length;
            segment_point = pointonsegmentnearesttopoint( sloth_start, sloth_end, ground_pos );
            dist = distancesquared( ground_pos, segment_point );

            if ( dist < max_dist )
            {
                max_dist = dist;
                closest = barricade;
                closest_segment_point = segment_point;
            }
        }
    }

    if ( isdefined( closest ) )
    {
        ground_pos = groundpos( closest.origin );
/#
        if ( getdvarint( _hash_B6252E7C ) == 2 )
            line( closest_segment_point, ground_pos, ( 0, 1, 0 ), 1, 0, 500 );
#/
        dist = distancesquared( closest_segment_point, ground_pos );

        if ( dist < 10000 )
            self.aim_barricade = closest;
/#
        sloth_print( "dist: " + sqrt( dist ) + " max_dist: " + sqrt( max_dist ) );
#/
/#
        if ( getdvarint( _hash_B6252E7C ) == 2 )
            line( self.origin, ground_pos, ( 1, 1, 1 ), 1, 0, 500 );
#/
    }
}

start_eat( player )
{
    self thread remove_gift_trigger( 0.1 );
    self.candy_player = player;
    self.candy_player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_sloth_candy_given", 0 );
    self.candy_player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_sloth_candy_given" );
    self thread watch_player_zombies();
    twr_origin = self gettagorigin( "tag_weapon_right" );
    twr_angles = self gettagangles( "tag_weapon_right" );

    if ( !isdefined( self.candy_model ) )
    {
        self.candy_model = spawn( "script_model", twr_origin );
        self.candy_model.angles = twr_angles;
        self.candy_model setmodel( level.candy_model );
        self.candy_model linkto( self, "tag_weapon_right" );
    }
    else
        self.candy_model show();

    self setclientfield( "sloth_eating", 1 );
    self thread action_animscripted( "zm_eat_candy", "eat_candy_anim" );
    return 1;
}

start_crash( barricade )
{
    if ( self.state == "crash" )
        return false;

    if ( barricade )
    {
        self.reset_asd = "zm_barricade";
        self thread action_anim( "zm_barricade", "crash_anim" );
    }
    else
    {
        self.reset_asd = "zm_crash";
        self thread action_anim( "zm_crash", "crash_anim" );
    }

    self thread sndchangebreathingstate( "happy" );
/#
    if ( isdefined( self.debug_berserk ) )
    {
        elapsed = ( gettime() - self.debug_berserk ) / 1000;
        dist = distance( self.origin, self.debug_berserk_org );
        sloth_print( "berserk dist = " + dist + " elapsed = " + elapsed + " rate = " + dist / elapsed );
    }
#/
    return true;
}

start_gunshop_run()
{
    if ( self.state == "follow" || self.state == "roam" )
    {
        self thread action_gunshop_run();
        self thread sndchangebreathingstate( "breathe", "happy" );
        return true;
    }

    return false;
}

start_gunshop_candy()
{
    self thread wait_for_timeout();
    self thread wait_for_candy();
    self thread action_gunshop_candy();
    self thread sndchangebreathingstate( "happy" );
    return 1;
}

start_table_eat()
{
    self stop_action();
    self thread action_table_eat();
    return 1;
}

start_headbang()
{
    self stop_action();
    self.headbang_time = gettime() + 10000;
    self thread action_headbang();
    self thread sndchangebreathingstate( "happy" );
    return 1;
}

start_smell()
{
    self stop_action();
    self thread action_smell();
    self thread sndchangebreathingstate( "breathe", "happy" );
    return 1;
}

start_context( context )
{
    self stop_action();
    self thread sndchangebreathingstate( "happy", "angry" );
    self.ignore_common_run = 0;
    self.context = context;
    self [[ context.start ]]();
    return 1;
}

remove_gift_trigger( delay )
{
    if ( isdefined( delay ) )
        wait( delay );

    while ( true )
    {
        if ( isdefined( self.gift_trigger ) )
        {
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.gift_trigger );
            return;
        }

        wait 0.1;
    }
}

action_jail_idle()
{
    self endon( "stop_action" );
    self.needs_action = 0;
    self setgoalpos( self.origin );

    while ( true )
    {
        self animscripted( self.jail_start.origin, self.jail_start.angles, "zm_jail_idle" );
        maps\mp\animscripts\zm_shared::donotetracks( "jail_idle_anim" );
    }
}

action_jail_cower( jumpback )
{
    cower_trans = "zm_jail_2_cower";
    cower_idle = "zm_cower_idle";

    if ( is_true( jumpback ) )
    {
        cower_trans = "zm_jail_2_cower_jumpback";
        cower_idle = "zm_cower_jumpback_idle";
    }

    self.needs_action = 0;
    self animscripted( self.jail_start.origin, self.jail_start.angles, cower_trans );
    maps\mp\animscripts\zm_shared::donotetracks( "jail_2_cower_anim" );
    self.anchor.origin = self.origin;
    self.anchor.angles = self.angles;
    self linkto( self.anchor );
    self setgoalpos( self.origin );
    self setanimstatefromasd( cower_idle );
}

action_jail_open()
{
    self.needs_action = 0;
    self animscripted( self.jail_start.origin, self.jail_start.angles, "zm_jail_open" );
    maps\mp\animscripts\zm_shared::donotetracks( "jail_open_anim" );
    self.needs_action = 1;
}

action_jail_close()
{
    self.needs_action = 0;

    if ( isdefined( level.jail_close_door ) )
        level thread [[ level.jail_close_door ]]();

    self animscripted( self.jail_start.origin, self.jail_start.angles, "zm_cower_2_close" );
    self blend_notetracks( "cower_2_close_anim" );
    level notify( "cell_close" );
    self.needs_action = 1;
}

action_jail_wait()
{
    self.needs_action = 0;
    self setgoalpos( self.origin );
    self.anchor.origin = self.origin;
    self.anchor.angles = self.angles;
    self linkto( self.anchor );
    self setanimstatefromasd( "zm_cower_jumpback_idle" );
    self.needs_action = 1;
}

action_teleport_to_courtyard()
{
/#
    sloth_print( "teleport to courtyard" );
#/
    points = array_randomize( level.courtyard_arrive );
    self forceteleport( points[0].origin );
    self.mansion_goal = undefined;
}

finish_pain()
{
    self endon( "death" );
    self endon( "pain_done" );

    while ( true )
    {
        anim_state = self getanimstatefromasd();

        if ( !( anim_state == "zm_pain" || anim_state == "zm_pain_no_restart" ) )
        {
/#
            sloth_print( "pain was interrupted" );
#/
            self setanimstatefromasd( "zm_pain_no_restart" );
        }

        wait 0.1;
    }
}

action_jail_run( pos, do_pain )
{
    self.needs_action = 0;

    if ( isdefined( self.candy_model ) )
        self.candy_model ghost();

    if ( isdefined( self.booze_model ) )
        self.booze_model ghost();

    if ( is_true( do_pain ) )
    {
        if ( !self sloth_is_traversing() && !is_true( self.is_pain ) )
        {
            self.is_pain = 1;
            self setanimstatefromasd( "zm_pain" );
            self.reset_asd = "zm_pain";
            self thread finish_pain();
            maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
            self notify( "pain_done" );
            self.is_pain = 0;
        }
    }

    while ( true )
    {
        if ( !self sloth_is_pain() )
            break;

        wait 0.1;
    }

    self.reset_asd = undefined;
    self animmode( "normal" );
    self set_zombie_run_cycle( "run_wounded" );
    self.locomotion = "run_wounded";
    self thread sloth_retreat_vo();
    self check_behind_mansion();

    if ( isdefined( self.mansion_goal ) )
    {
        self setgoalpos( self.mansion_goal.origin );

        self waittill( "goal" );

        self action_teleport_to_courtyard();
    }

    self setgoalpos( pos );

    self waittill( "goal" );

    self animscripted( self.jail_start.origin, self.jail_start.angles, "zm_run_into_jail_cower" );
    self blend_notetracks( "run_into_jail_cower_anim" );
    self.needs_action = 1;
}

sloth_retreat_vo()
{
    wait 1.0;
    a_players = getplayers();
    a_closest = get_array_of_closest( self.origin, a_players );

    for ( i = 0; i < a_closest.size; i++ )
    {
        if ( !( isdefined( a_closest[i].dontspeak ) && a_closest[i].dontspeak ) )
        {
            if ( isalive( a_closest[i] ) )
                a_closest[i] thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sloth_retreat_cell" );
        }
    }
}

action_roam_point( point )
{
    self endon( "death" );
    self notify( "stop_action" );
    self endon( "stop_action" );
    self.needs_action = 0;

    if ( isdefined( self.current_roam ) )
    {
        if ( point.script_noteworthy != self.current_roam.script_noteworthy )
        {
/#
            sloth_print( "using sloth_mover " + self.current_roam.script_noteworthy );
#/
            sub_goal_array = getstructarray( self.current_roam.script_noteworthy, "script_noteworthy" );

            foreach ( sg in sub_goal_array )
            {
                if ( isdefined( sg.targetname ) && sg.targetname == "player_respawn_point" )
                    continue;

                sub_goal = sg;
            }

            ground_pos = groundpos( sub_goal.origin );
            self sloth_check_turn( ground_pos, 0 );
            self setgoalpos( ground_pos );

            self waittill( "goal" );

            sub_goal_next = getstruct( sub_goal.target, "targetname" );
            ground_pos = groundpos( sub_goal_next.origin );
            self sloth_check_turn( ground_pos, 0 );
            self setgoalpos( ground_pos );

            self waittill( "goal" );
        }
    }

    self sloth_check_turn( point.origin, 0 );
    self setgoalnode( point );

    self waittill( "goal" );

    self.current_roam = point;
    self.needs_action = 1;
}

action_player_idle( gimme_anim )
{
    self.needs_action = 0;
    self setgoalpos( self.origin );

    if ( isdefined( gimme_anim ) )
        self setanimstatefromasd( gimme_anim );
    else
        self setanimstatefromasd( "zm_player_idle" );
}

action_navigate_mansion( depart_points, arrive_points )
{
    if ( !isdefined( self.teleport ) )
    {
        points = array_randomize( depart_points );

        for ( i = 0; i < points.size; i++ )
        {
            end = i + 1;

            if ( end == points.size )
                end = 0;

            points[i].next = points[end];
        }

        self.teleport = points[0];
        self setgoalpos( self.teleport.origin );
    }
    else
    {
        dist = distancesquared( self.origin, self.teleport.origin );

        if ( dist < 1024 )
        {
            if ( self player_can_see_sloth() )
            {
/#
                sloth_print( "player can see sloth, try another spot" );
#/
                self.teleport = self.teleport.next;
                self setgoalpos( self.teleport.origin );
                return;
            }

            if ( depart_points[0].targetname == level.maze_depart[0].targetname )
            {
/#
                sloth_print( "teleport to maze" );
#/
                self.teleporting = "to_maze";
            }
            else
            {
/#
                sloth_print( "teleport to courtyard" );
#/
                self.teleporting = "to_courtyard";
            }

            arrive = array_randomize( arrive_points );
            self forceteleport( arrive[0].origin );
            self setgoalpos( arrive[0].origin );
            self.teleport = undefined;
            self.teleport_time = gettime();
        }
    }
}

player_can_see_sloth()
{
    players = get_players();

    foreach ( player in players )
    {
        if ( player.sessionstate == "spectator" )
            continue;

        if ( player is_player_looking_at( self.origin, 0.7, 0, undefined ) )
            return true;
    }

    return false;
}

sloth_check_turn( pos, dot_limit = -0.707 )
{
    self endon( "death" );

    if ( !isdefined( self.locomotion ) )
    {
/#
        sloth_print( "tried turn but no locomotion defined" );
#/
        return;
    }

    if ( is_true( self.is_turning ) )
        return;

    vec_forward = vectornormalize( anglestoforward( self.angles ) );
    vec_goal = vectornormalize( pos - self.origin );
    dot = vectordot( vec_forward, vec_goal );

    if ( dot < dot_limit )
    {
        turn_asd = "zm_sloth_" + self.locomotion + "_turn_180";

        if ( !self hasanimstatefromasd( turn_asd ) )
        {
/#
            sloth_print( "no turn for " + turn_asd );
#/
            return;
        }
        else
        {
            self.is_turning = 1;
            self animcustom( ::sloth_do_turn_anim );
            anim_length = self getanimlengthfromasd( turn_asd, 0 );
            self waittill_notify_or_timeout( "turn_anim_done", anim_length );
            self.is_turning = 0;
        }
    }
}

sloth_do_turn_anim()
{
    self endon( "death" );
    self endon( "stop_action" );
    turn_asd = "zm_sloth_" + self.locomotion + "_turn_180";
/#
    sloth_print( turn_asd );
#/
    self setanimstatefromasd( turn_asd );

    if ( isdefined( self.crawler ) )
    {
        turn_crawler_asd = "zm_crawler_crawlerhold_walk";

        if ( self.is_inside )
            turn_crawler_asd += "_hunched";

        turn_crawler_asd += "_turn_180";
        self.crawler setanimstatefromasd( turn_crawler_asd );
    }

    maps\mp\animscripts\zm_shared::donotetracks( "sloth_turn_180_anim" );
    self notify( "turn_anim_done" );
    self.is_turning = 0;
}

action_player_follow( player )
{
    origin = player.origin;

    if ( is_true( player.slowgun_flying ) )
    {
        ground_ent = player getgroundent();

        if ( !isdefined( ground_ent ) )
        {
            ground_pos = groundpos( player.origin );
            node = getnearestnode( ground_pos );

            if ( !isdefined( node ) )
                node = getnearestnode( self.origin );

            if ( isdefined( node ) )
                origin = node.origin;
        }
    }

    self setgoalpos( origin );
}

action_player_ask( gimme_anim )
{
    self endon( "stop_action" );

    if ( !isdefined( gimme_anim ) )
    {
        self.needs_action = 1;
        return;
    }

    self.needs_action = 0;
    self setanimstatefromasd( gimme_anim );
    maps\mp\animscripts\zm_shared::donotetracks( "gimme_anim" );
    self.needs_action = 1;
}

action_berserk( player )
{
    self.needs_action = 0;
    self animcustom( ::custom_berserk );
}

action_anim( asd_name, notify_name )
{
    self endon( "death" );
    self.needs_action = 0;
    self setanimstatefromasd( asd_name );
    maps\mp\animscripts\zm_shared::donotetracks( notify_name );
    self.needs_action = 1;
}

action_animscripted( asd_name, notify_name, origin, angles )
{
    self endon( "death" );
    org = self.origin;
    ang = self.angles;

    if ( isdefined( origin ) )
        org = origin;

    if ( isdefined( angles ) )
        ang = angles;

    self.needs_action = 0;
    self animscripted( org, ang, asd_name );
    maps\mp\animscripts\zm_shared::donotetracks( notify_name );
    self.needs_action = 1;
}

custom_berserk()
{
    self endon( "death" );
    self setanimstatefromasd( "zm_drink_booze" );
    twr_origin = self gettagorigin( "tag_weapon_right" );
    twr_angles = self gettagangles( "tag_weapon_right" );

    if ( !isdefined( self.booze_model ) )
    {
        self.booze_model = spawn( "script_model", twr_origin );
        self.booze_model.angles = twr_angles;
        self.booze_model setmodel( level.booze_model );
        self.booze_model linkto( self, "tag_weapon_right" );
    }
    else
        self.booze_model show();

    self thread booze_wait();
    self setclientfield( "sloth_drinking", 1 );
    self blend_notetracks( "drink_booze_anim" );

    if ( isdefined( self.aim_barricade ) )
    {
/#
        if ( isdefined( self.aim_barricade.script_noteworthy ) )
            sloth_print( "aiming at: " + self.aim_barricade.script_noteworthy );
#/
        self orientmode( "face point", self.aim_barricade.origin );
    }

    self setanimstatefromasd( "zm_drink_booze_aim" );
    self setclientfield( "sloth_glass_brk", 0 );
    self setclientfield( "sloth_drinking", 0 );
    self thread kill_near_zombies();
    self blend_notetracks( "drink_booze_aim_anim" );
    self notify( "stop_kill_near_zombies" );

    if ( isdefined( self.aim_barricade ) )
    {
        self orientmode( "face default" );
        self.aim_barricade = undefined;
    }

    self.berserk_time = gettime();
    self.run_berserk = 1;
    self animmode( "gravity" );
    self setanimstatefromasd( "zm_move_run_berserk" );
    self.reset_asd = "zm_move_run_berserk";

    if ( isdefined( self.booze_player ) )
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sloth_run" );
/#
    self.debug_berserk = gettime();
    self.debug_berserk_org = self.origin;
#/
    self waittill( "stop_berserk" );

    self animmode( "normal" );
    self.run_berserk = 0;
    self.needs_action = 1;
}

blend_notetracks( animname )
{
    self endon( "death" );

    self waittillmatch( animname, "blend" );
}

kill_near_zombies()
{
    self endon( "death" );
    self endon( "stop_kill_near_zombies" );
    gibbed = 0;
    zombies = getaispeciesarray( level.zombie_team, "all" );

    for ( i = 0; i < zombies.size; i++ )
    {
        zombie = zombies[i];

        if ( is_true( zombie.is_sloth ) )
            continue;

        dist = distancesquared( self.origin, zombie.origin );

        if ( dist < 4096 )
        {
            if ( !is_true( self.no_gib ) && gibbed % 3 == 0 )
            {
                zombie.force_gib = 1;
                zombie.a.gib_ref = random( array( "guts", "right_arm", "left_arm", "head" ) );
                zombie thread maps\mp\animscripts\zm_death::do_gib();
            }

            gibbed++;
            zombie dodamage( zombie.health * 10, zombie.origin );
            zombie.noragdoll = 1;
            zombie.nodeathragdoll = 1;
            level.zombie_total++;
        }
    }
}

booze_wait()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "drink_booze_anim", note );

        if ( note == "hitground" || note == "end" )
        {
            self setclientfield( "sloth_glass_brk", 1 );

            if ( isdefined( self.booze_model ) )
                self.booze_model ghost();

            break;
        }
    }
}

action_gunshop_run()
{
    self endon( "death" );
    self.needs_action = 0;
    self set_zombie_run_cycle( "run" );
    self.locomotion = "run";
    self setgoalpos( self.gunshop.origin );

    self waittill( "goal" );

    self set_zombie_run_cycle( "walk" );
    self.locomotion = "walk";
    self.needs_action = 1;
}

action_gunshop_candy()
{
    self endon( "death" );
    self endon( "stop_action" );
    self.needs_action = 0;
    self setgoalpos( self.origin );

    while ( true )
    {
        self animscripted( self.origin, self.angles, "zm_player_idle" );
        maps\mp\animscripts\zm_shared::donotetracks( "player_idle_anim" );
    }
}

action_table_eat()
{
    self endon( "death" );
    self endon( "stop_action" );
    asd = "zm_eat_candy_storage_table";
    table_org = self.origin;
    align_org = self.origin;
    align_angles = self.angles;

    if ( isdefined( self.bench ) )
    {
        table = getent( self.bench.target, "targetname" );
        anim_id = self getanimfromasd( asd, 0 );
        table_org = getstartorigin( table.origin, table.angles, anim_id );
        align_org = table.origin;
        align_angles = table.angles;
    }

    self.needs_action = 0;
    self setgoalpos( table_org );

    self waittill( "goal" );

    self animscripted( align_org, align_angles, asd );
    maps\mp\animscripts\zm_shared::donotetracks( "eat_candy_storage_table_anim" );
    self notify( "table_eat_done" );
    self.needs_action = 1;
}

action_headbang()
{
    self endon( "death" );
    self endon( "stop_action" );
    self.needs_action = 0;
    self setgoalpos( self.origin );

    while ( true )
    {
        self animscripted( self.origin, self.angles, "zm_headbang" );
        maps\mp\animscripts\zm_shared::donotetracks( "headbang_anim" );
    }
}

action_smell()
{
    self endon( "death" );
    self endon( "stop_action" );
    self.needs_action = 0;
    self setgoalpos( self.origin );
    self animscripted( self.origin, self.angles, "zm_smell_react" );
    maps\mp\animscripts\zm_shared::donotetracks( "smell_react_anim" );
    self.needs_action = 1;
}

stop_action()
{
    self notify( "stop_action" );
    self.is_turning = 0;
    self.teleport = undefined;
    self.needs_action = 1;
    self stopanimscripted();
    self unlink();
    self orientmode( "face default" );
}

check_contextual_actions()
{
    context = undefined;
    keys = getarraykeys( level.candy_context );

    for ( i = 0; i < keys.size; i++ )
    {
        if ( self [[ level.candy_context[keys[i]].condition ]]() )
        {
            if ( isdefined( context ) )
            {
                if ( level.candy_context[keys[i]].priority < context.priority )
                    context = level.candy_context[keys[i]];

                continue;
            }

            context = level.candy_context[keys[i]];
        }
    }

    return context;
}

common_context_start()
{
/#
    sloth_print( self.context.name );
#/
    self.context_done = 0;
    self thread [[ self.context.action ]]();
}

common_context_update()
{
    if ( is_true( self.context_done ) )
    {
        maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
        self orientmode( "face default" );
        self set_zombie_run_cycle( "walk" );
        self.locomotion = "walk";
        self sloth_set_state( "roam" );
    }
    else
    {
        if ( !is_true( self.ignore_common_run ) )
            self common_context_run( "run" );

        anim_state = self getanimstatefromasd();

        if ( anim_state == "zm_move_run" || anim_state == "zm_move_run_hunched" )
            self sloth_check_ragdolls();
    }
}

common_context_run( move_run )
{
    if ( self.is_inside )
        move_run += "_hunched";

    if ( self.zombie_move_speed != move_run )
    {
        self set_zombie_run_cycle( move_run );
        self.locomotion = move_run;
    }
    else if ( is_true( self.was_idle ) )
    {
        self.was_idle = 0;
        self maps\mp\animscripts\zm_run::needsupdate();
    }
}

common_context_action()
{
    self common_context_run( "run" );
}

protect_condition()
{
    return 1;
}

protect_start()
{
/#
    sloth_print( "protect " + self.candy_player.name );
#/
    self.protect_time = gettime();
    self thread protect_action();
    self thread sndchangebreathingstate( "angry" );
}

protect_update()
{
    if ( is_true( self.candy_player.is_in_ghost_zone ) || gettime() - self.protect_time > 45000 || should_ignore_candybooze( self.candy_player ) )
    {
        if ( isdefined( self.target_zombie ) )
            self.target_zombie = undefined;

        maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
        self notify( "stop_player_watch" );
        self set_zombie_run_cycle( "walk" );
        self.locomotion = "walk";
        self sloth_set_state( "roam" );
        self orientmode( "face default" );
    }
}

protect_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self setclientfield( "sloth_berserk", 0 );

    if ( !isdefined( level.sloth_protect ) )
        level.sloth_protect = 1;
    else
        level.sloth_protect++;

    while ( true )
    {
        if ( !isdefined( self.target_zombie ) || self.target_zombie.health <= 0 )
        {
            if ( self.target_zombies.size > 0 )
            {
                closest = undefined;
                closest_dist = undefined;

                for ( i = 0; i < self.target_zombies.size; i++ )
                {
                    zombie = self.target_zombies[i];

                    if ( zombie.health > 0 )
                    {
                        dist = distancesquared( self.candy_player.origin, zombie.origin );

                        if ( !isdefined( closest ) || dist < closest_dist )
                        {
                            closest = zombie;
                            closest_dist = dist;
                        }
                    }
                }

                if ( isdefined( closest ) )
                    self.target_zombie = closest;
            }
        }

        if ( isdefined( self.target_zombie ) )
        {
            dist = distancesquared( self.origin, self.target_zombie.origin );

            if ( dist < 4096 )
            {
                self sloth_check_turn( self.target_zombie.origin, -0.923 );
                self.anchor.origin = self.origin;
                self.anchor.angles = flat_angle( vectortoangles( self.target_zombie.origin - self.origin ) );
                self animscripted( self.anchor.origin, self.anchor.angles, "zm_melee_attack" );
                maps\mp\animscripts\zm_shared::donotetracks( "melee_attack", ::sloth_melee_notetracks );
                self.target_zombie = undefined;
            }
            else
            {
                self sloth_check_turn( self.target_zombie.origin, -0.923 );
                self setgoalpos( self.target_zombie.origin );
                self common_context_run( "run_frantic" );
                self sloth_check_ragdolls( self.target_zombie );
/#
                if ( getdvarint( _hash_B6252E7C ) == 2 )
                    line( self.origin, self.target_zombie.origin, ( 0, 1, 0 ), 1, 0, 6 );
#/
            }
        }
        else
        {
            dist = distancesquared( self.origin, self.candy_player.origin );

            if ( dist < 32400 && !self sloth_is_traversing() )
            {
                self setgoalpos( self.origin );
                self setanimstatefromasd( "zm_idle_protect" );
                self.was_idle = 1;
            }
            else
            {
                self sloth_check_turn( self.candy_player.origin, -0.923 );
                self setgoalpos( self.candy_player.origin );
                self common_context_run( "run_frantic" );
                self sloth_check_ragdolls( self.target_zombie );
            }
        }

        wait 0.1;
    }
}

sloth_melee_notetracks( note )
{
    if ( note == "j_wrist_ri" || note == "j_wrist_le" || note == "j_ball_ri" )
    {
        if ( isdefined( self.target_zombie ) )
        {
            playfxontag( level._effect["headshot_nochunks"], self.target_zombie, "j_head" );
            self sloth_kill_zombie( self.target_zombie );
        }

        self sloth_check_ragdolls( self.target_zombie );
    }
}

lamp_condition()
{
    if ( !isdefined( level.oillamp ) )
        return false;

    if ( !isdefined( level.oillamp.unitrigger ) || is_true( level.oillamp.built ) )
        return false;

    for ( i = 0; i < level.generator_zones.size; i++ )
    {
        zone = level.generator_zones[i];
        dist = distancesquared( zone.stub.origin, self.origin );

        if ( dist < 14400 )
        {
            self.buildable_zone = zone;
            return true;
        }
    }

    return false;
}

lamp_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self set_zombie_run_cycle( "run" );
    self.locomotion = "run";
    self maps\mp\animscripts\zm_run::needsupdate();
    self.oillamp = level.oillamp;
    lamp_gone = 0;

    while ( true )
    {
        if ( self.oillamp != level.oillamp )
        {
/#
            sloth_print( "lamp moved" );
#/
            self.oillamp = level.oillamp;
        }

        if ( isdefined( self.oillamp.unitrigger ) && !is_true( self.oillamp.built ) )
        {
            self setgoalpos( self.oillamp.unitrigger.origin );
            dist = distancesquared( self.oillamp.unitrigger.origin, self.origin );

            if ( dist < 4096 )
                break;
        }
        else
        {
            lamp_gone = 1;
            break;
        }

        wait 0.1;
    }

    if ( lamp_gone )
    {
/#
        sloth_print( "lamp is gone" );
#/
        self.context_done = 1;
        return;
    }
/#
    sloth_print( "got lamp" );
#/
    self.oillamp maps\mp\zombies\_zm_buildables::piece_unspawn();
    self action_animscripted( "zm_wallbuy_remove", "wallbuy_remove_anim" );
    stub = self.buildable_zone.stub;
    vec_right = vectornormalize( anglestoright( stub.angles ) );
    ground_pos = stub.origin - vec_right * 60;
    ground_pos = groundpos( ground_pos );
    self setgoalpos( ground_pos );

    self waittill( "goal" );

    generator_angle = vectortoangles( vec_right );
    self orientmode( "face angle", generator_angle[1] );
    wait 0.75;
    self action_animscripted( "zm_wallbuy_add", "wallbuy_add_anim" );
    self player_set_buildable_piece( self.oillamp, 1 );
    self maps\mp\zombies\_zm_buildables::player_build( self.buildable_zone );
/#
    sloth_print( "placed lamp" );
#/
    self.context_done = 1;
}

powerup_cycle_condition()
{
    if ( level.active_powerups.size > 0 )
    {
        foreach ( powerup in level.active_powerups )
        {
            ground_pos = groundpos( powerup.origin );
/#
            self sloth_debug_context( powerup, sqrt( 32400 ) );
#/
            dist = distancesquared( self.origin, ground_pos );

            if ( dist < 32400 )
            {
                self.active_powerup = powerup;
                self.active_powerup notify( "powerup_reset" );
                self.active_powerup show();
                return true;
            }
        }
    }

    return false;
}

powerup_cycle_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self common_context_action();
/#
    level.zombie_devgui_power = 0;
#/
    if ( isdefined( self.active_powerup ) )
    {
        powerup_pos = groundpos( self.active_powerup.origin );
        dest_pos = powerup_pos;
        too_close = 0;
        dist = distancesquared( self.origin, powerup_pos );

        if ( dist < 2116 )
        {
            too_close = 1;
/#
            sloth_print( "too close to powerup: " + sqrt( dist ) );
#/
            vec_forward = vectornormalize( anglestoforward( self.angles ) );
            dest_pos = groundpos( self.active_powerup.origin + vec_forward * 100 );
        }

        self setgoalpos( dest_pos );
        time_started = gettime();

        while ( true )
        {
            dist = distancesquared( self.origin, powerup_pos );

            if ( too_close )
            {
                self orientmode( "face point", powerup_pos );

                if ( dist > 2500 )
                {
                    self setgoalpos( self.origin );

                    if ( is_facing( self.active_powerup ) )
                        break;
                }

                if ( gettime() - time_started > 3000 )
                {
/#
                    sloth_print( "couldn't get away" );
#/
                    break;
                }
            }
            else if ( dist < 3136 )
            {
                self setgoalpos( self.origin );
                break;
            }

            wait 0.1;
        }

        if ( isdefined( self.active_powerup ) )
        {
            if ( !too_close )
                self sloth_face_object( self.active_powerup, "point", powerup_pos );
        }

        if ( isdefined( self.active_powerup ) )
        {
            self.anchor.origin = self.origin;
            self.anchor.angles = flat_angle( vectortoangles( powerup_pos - self.origin ) );
            self animscripted( self.anchor.origin, self.anchor.angles, "zm_cycle_powerup" );
            maps\mp\animscripts\zm_shared::donotetracks( "cycle_powerup_anim", ::powerup_change );
        }
    }

    self.context_done = 1;
}

powerup_change( note )
{
    if ( note == "change" )
    {
        if ( isdefined( self.active_powerup ) )
        {
            playfx( level._effect["fx_buried_sloth_powerup_cycle"], self.active_powerup.origin );
            powerup = maps\mp\zombies\_zm_powerups::get_valid_powerup();
            struct = level.zombie_powerups[powerup];

            if ( self.active_powerup.powerup_name == struct.powerup_name )
            {
                powerup = maps\mp\zombies\_zm_powerups::get_valid_powerup();
                struct = level.zombie_powerups[powerup];
            }

            self.active_powerup setmodel( struct.model_name );
            self.active_powerup.powerup_name = struct.powerup_name;
            self.active_powerup.hint = struct.hint;
            self.active_powerup.solo = struct.solo;
            self.active_powerup.caution = struct.caution;
            self.active_powerup.zombie_grabbable = struct.zombie_grabbable;
            self.active_powerup.func_should_drop_with_regular_powerups = struct.func_should_drop_with_regular_powerups;
            self.active_powerup thread maps\mp\zombies\_zm_powerups::powerup_timeout();

            if ( isdefined( struct.fx ) )
                self.active_powerup.fx = struct.fx;
        }
    }
}

dance_condition()
{
    if ( isdefined( level.sloth_protect ) )
    {
        next_protect = level.sloth_protect + 1;

        if ( next_protect % 3 == 0 )
            return true;
    }

    return false;
}

dance_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self common_context_action();
    self setclientfield( "sloth_vomit", 0 );
    self.dance_end = gettime() + 30000;
    level.sloth_protect = 0;

    while ( true )
    {
        if ( gettime() >= self.dance_end )
            break;

        self animscripted( self.origin, self.angles, "zm_dance" );
        maps\mp\animscripts\zm_shared::donotetracks( "dance_anim", ::dance_attack );
        wait 0.1;
    }

    self notify( "stop_dance" );
    self animscripted( self.origin, self.angles, "zm_vomit" );
    maps\mp\animscripts\zm_shared::donotetracks( "vomit_anim", ::vomit_notetrack );
    self.context_done = 1;
}

dance_attack( note )
{
    if ( note == "fire" )
    {
        zombies = get_round_enemy_array();

        for ( i = 0; i < zombies.size; i++ )
        {
            zombie = zombies[i];
            dist = distancesquared( self.origin, zombie.origin );

            if ( dist < 4096 )
            {
                zombie dodamage( zombie.health * 10, zombie.origin );
                zombie playsound( "zmb_ai_sloth_attack_impact" );
            }
        }
    }
}

vomit_notetrack( note )
{
    if ( note == "vomit" )
        self setclientfield( "sloth_vomit", 1 );
}

sloth_paralyzed( player, upgraded )
{
    sizzle = "zombie_slowgun_sizzle";

    if ( upgraded )
        sizzle = "zombie_slowgun_sizzle_ug";

    if ( isdefined( level._effect[sizzle] ) )
        playfxontag( level._effect[sizzle], self, "J_SpineLower" );

    self maps\mp\zombies\_zm_weap_slowgun::zombie_slow_for_time( 0.3 );
}

is_holding_candybooze( player )
{
    if ( is_holding( player, "candy" ) || is_holding( player, "booze" ) )
        return true;

    return false;
}

is_holding( player, name )
{
    if ( should_ignore_candybooze( player ) )
        return false;

    piece = player player_get_buildable_piece( 1 );

    if ( isdefined( piece ) )
    {
        if ( isdefined( piece.buildablename ) && piece.buildablename == name )
            return true;
    }

    return false;
}

create_candy_booze_trigger()
{
    if ( !is_buildable_included( "sloth" ) )
        return;

    gift_trigger = maps\mp\zombies\_zm_buildables::ai_buildable_trigger_think( self, "sloth", "sloth", "", 3 );
    gift_trigger bpstub_set_custom_think_callback( ::bptrigger_think_unbuild_no_return );
    gift_trigger.onbeginuse = ::onbeginusecandybooze;
    gift_trigger.onenduse = ::onendusecandybooze;
    gift_trigger.onuse = ::onuseplantobjectcandybooze;
    gift_trigger.oncantuse = ::oncantusecandybooze;
    gift_trigger.prompt_and_visibility_func = ::sloth_gift_prompt;
    gift_trigger.originfunc = ::sloth_get_unitrigger_origin;
    gift_trigger.buildablestruct.building = "";
    gift_trigger.building_prompt = &"ZM_BURIED_GIVING";
    gift_trigger.build_weapon = "no_hands_zm";
    gift_trigger.ignore_open_sesame = 1;
    gift_trigger.usetime = int( 750 );
    gift_trigger.radius = 96;
    self.gift_trigger = gift_trigger;
    gift_trigger thread watch_prompt_reassessment();
    level thread wait_start_candy_booze( gift_trigger.buildablezone.pieces[1] );

    self waittill( "death" );

    gift_trigger maps\mp\zombies\_zm_buildables::buildablestub_remove();
    thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( gift_trigger );
}

wait_start_candy_booze( piece )
{
    piece piece_unspawn();
    level.jail_barricade_down = 0;

    level waittill( "jail_barricade_down" );

    level.jail_barricade_down = 1;
    piece piece_spawn_at();
}

watch_prompt_reassessment()
{
    self.inactive_reasses_time = 0.2;
    self.active_reasses_time = 0.2;

    level waittill( "jail_barricade_down" );

    self.inactive_reasses_time = 0.3;
    self.active_reasses_time = 0.3;
}

is_facing( facee, dot_limit = 0.7 )
{
    if ( isplayer( self ) )
        orientation = self getplayerangles();
    else
        orientation = self.angles;

    forwardvec = anglestoforward( orientation );
    forwardvec2d = ( forwardvec[0], forwardvec[1], 0 );
    unitforwardvec2d = vectornormalize( forwardvec2d );
    tofaceevec = facee.origin - self.origin;
    tofaceevec2d = ( tofaceevec[0], tofaceevec[1], 0 );
    unittofaceevec2d = vectornormalize( tofaceevec2d );
    dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
    return dotproduct > dot_limit;
}

sloth_get_unitrigger_origin()
{
    if ( isdefined( self.origin_parent ) )
    {
        forward = anglestoforward( self.origin_parent.angles );
        return self.origin_parent.origin + vectorscale( ( 0, 0, 1 ), 35.0 ) + 32 * forward;
    }

    return self.origin;
}

sloth_gift_prompt( player )
{
    can_use = 1;
    active = isdefined( self.thread_running ) && self.thread_running;
    sloth = self.stub.link_parent;

    if ( active )
        dotlimit = 0.7;
    else
        dotlimit = 0.75;

    if ( !player is_facing( sloth, dotlimit ) || !sloth is_facing( player, dotlimit ) )
    {
        self.stub.hint_string = "";
        self sethintstring( self.stub.hint_string );
        can_use = 0;
    }
    else if ( active )
        can_use = 1;
    else
    {
        piece = player player_get_buildable_piece( 1 );

        if ( isdefined( piece ) )
        {
            if ( piece.buildablename == "candy" )
                level.zombie_buildables["sloth"].hint = &"ZM_BURIED_CANDY_GV";
            else
                level.zombie_buildables["sloth"].hint = &"ZM_BURIED_BOOZE_GV";
        }

        can_use = self buildabletrigger_update_prompt( player );
    }

    if ( can_use )
        self.reassess_time = self.stub.active_reasses_time;

    return can_use;
}

onbeginusecandybooze( player )
{
    sloth = self.origin_parent;
    sloth sloth_set_state( "player_idle", 1 );
}

onendusecandybooze( team, player, result )
{
    sloth = self.origin_parent;

    if ( sloth.state != "jail_cower" || result )
        sloth unlink();
}

oncantusecandybooze( player )
{

}

onuseplantobjectcandybooze( player )
{
    if ( !isdefined( player player_get_buildable_piece( 1 ) ) )
        return;

    self.hint_string = "";

    switch ( player player_get_buildable_piece( 1 ).buildablename )
    {
        case "booze":
            if ( level.sloth.state == "eat" )
                return;

            level.sloth sloth_set_state( "berserk", player );
            break;
        case "candy":
            if ( level.sloth.state == "berserk" )
                return;

            level.sloth sloth_set_state( "eat", player );
            player notify( "player_gives_sloth_candy" );
            break;
    }

    self.built = 1;
}

sloth_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( sweapon == "equip_headchopper_zm" )
    {
        self.damageweapon_name = sweapon;
        self check_zombie_damage_callbacks( smeansofdeath, shitloc, vpoint, eattacker, idamage );
        self.damageweapon_name = undefined;
    }

    if ( isdefined( self.sloth_damage_func ) )
    {
        damage = self [[ self.sloth_damage_func ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
        return damage;
    }

    if ( smeansofdeath == level.slowgun_damage_mod && sweapon == "slowgun_zm" )
        return 0;

    if ( smeansofdeath == "MOD_MELEE" )
    {
        self sloth_leg_pain();
        return 0;
    }

    if ( self.state == "jail_idle" )
    {
        self stop_action();
        self sloth_set_state( "jail_cower" );
        maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
        return 0;
    }

    if ( smeansofdeath == "MOD_EXPLOSIVE" || smeansofdeath == "MOD_EXPLOSIVE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" )
    {
        do_pain = self sloth_pain_react();
        self sloth_set_state( "jail_run", do_pain );
        return 0;
    }

    if ( !is_true( self.damage_accumulating ) )
        self thread sloth_accumulate_damage( idamage );
    else
    {
        self.damage_taken += idamage;
        self.num_hits++;
    }

    return 0;
}

sloth_pain_react()
{
    if ( self.state == "roam" || self.state == "follow" || self.state == "player_idle" )
    {
        if ( !self sloth_is_traversing() )
            return true;
    }

    return false;
}

sloth_accumulate_damage( amount )
{
    self endon( "death" );
    self notify( "stop_accumulation" );
    self endon( "stop_accumulation" );
    self.damage_accumulating = 1;
    self.damage_taken = amount;
    self.num_hits = 1;

    if ( self sloth_pain_react() )
    {
        self.is_pain = 1;
        prev_anim_state = self getanimstatefromasd();

        if ( self.state == "roam" || self.state == "follow" )
            self animmode( "gravity" );

        self setanimstatefromasd( "zm_pain" );
        self.reset_asd = "zm_pain";
        maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );

        if ( self.state == "roam" || self.state == "follow" )
            self animmode( "normal" );

        self.is_pain = 0;
        self.reset_asd = undefined;
        self setanimstatefromasd( prev_anim_state );
    }
    else
        wait 1;
/#
    sloth_print( "num hits: " + self.num_hits );
#/
    self.damage_accumulating = 0;

    if ( self.num_hits >= 3 )
        self sloth_set_state( "jail_run", 0 );
}

sloth_leg_pain()
{
    self.leg_pain_time = gettime() + 4000;
}

sloth_non_attacker( damage, weapon )
{
    return 0;
}

sloth_set_anim_rate( rate )
{
    if ( isdefined( self.crawler ) )
        self.crawler maps\mp\zombies\_zm_weap_slowgun::set_anim_rate( rate );
}

sloth_reset_anim()
{
    self endon( "death" );

    if ( self.state == "jail_idle" )
    {
        self animscripted( self.jail_start.origin, self.jail_start.angles, "zm_jail_idle" );
        maps\mp\animscripts\zm_shared::donotetracks( "jail_idle_anim" );
    }
    else if ( isdefined( self.reset_asd ) )
        self setanimstatefromasd( self.reset_asd );
    else
        self maps\mp\zombies\_zm_weap_slowgun::reset_anim();
}

sloth_time_bomb_setup()
{
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_add_custom_func_global_save( ::time_bomb_global_data_save_sloth );
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_add_custom_func_global_restore( ::time_bomb_global_data_restore_sloth );
}

time_bomb_global_data_save_sloth()
{

}

time_bomb_global_data_restore_sloth()
{
    players = getplayers();

    foreach ( player in players )
    {
        if ( player istouching( level.jail_cell_volume ) )
        {
            if ( !is_true( level.cell_open ) )
                level.sloth.open_jail = 1;
        }
    }
}

sndchangebreathingstate( type1, type2 )
{
    self notify( "sndStateChange" );
    self endon( "sndStateChange" );
    alias = "zmb_ai_sloth_lp_" + type1;

    if ( isdefined( type2 ) )
    {
        if ( cointoss() )
            alias = "zmb_ai_sloth_lp_" + type2;
    }

    self.sndent stoploopsound( 0.75 );
    wait 0.75;
    self.sndent playloopsound( alias, 0.75 );
}

ignore_stop_func()
{
    if ( is_true( self.is_inert ) )
        return true;

    return false;
}

sloth_debug_axis()
{
/#
    self endon( "death" );

    if ( !isdefined( self.debug_axis ) )
    {
        org = self gettagorigin( "tag_weapon_right" );
        ang = self gettagangles( "tag_weapon_right" );
        self.debug_axis = spawn( "script_model", org );
        self.debug_axis.angles = ang;
        self.debug_axis setmodel( "fx_axis_createfx" );
        self.debug_axis linkto( self, "tag_weapon_right" );
    }
#/
}

sloth_debug_doors()
{
/#
    while ( true )
    {
        if ( is_true( level.sloth_debug_doors ) )
        {
            foreach ( door in level.sloth_doors )
            {
/#
                debugstar( door.origin, 100, ( 1, 1, 1 ) );
                circle( door.origin, 120, ( 1, 1, 1 ), 0, 1, 100 );
#/
            }
        }

        wait 1;
    }
#/
}

sloth_debug_buildables()
{
/#
    while ( true )
    {
        if ( is_true( level.sloth_debug_buildables ) )
        {
            if ( !isdefined( self.buildable_model ) )
            {
                tag_name = "tag_stowed_back";
                twr_origin = self gettagorigin( tag_name );
                twr_angles = self gettagangles( tag_name );
                self.devgui_buildable = 1;
                self.buildable_model = spawn( "script_model", twr_origin );
                self.buildable_model.angles = twr_angles;
                self.buildable_model setmodel( level.small_turbine );
                self.buildable_model linkto( self, tag_name );
            }

            foreach ( zone in level.sloth_buildable_zones )
            {
/#
                debugstar( zone.stub.origin, 100, ( 1, 1, 1 ) );
#/
            }
        }
        else if ( is_true( self.devgui_buildable ) )
        {
            self.devgui_buildable = 0;

            if ( isdefined( self.buildable_model ) )
            {
                self.buildable_model unlink();
                self.buildable_model delete();
            }
        }

        wait 1;
    }
#/
}

sloth_debug_input()
{
/#
    level.player_candy = 0;
    wait 2;

    while ( true )
    {
        if ( !getdvarint( _hash_B6252E7C ) )
        {
            wait 0.2;
            continue;
        }

        twr_origin = self gettagorigin( "tag_weapon_right" );
/#
        debugstar( twr_origin, 6, ( 1, 1, 1 ) );
#/
        player = get_players()[0];

        if ( player actionslotonebuttonpressed() )
        {

        }
        else if ( player actionslottwobuttonpressed() )
        {

        }
        else if ( player actionslotthreebuttonpressed() )
        {

        }
        else if ( player actionslotfourbuttonpressed() )
        {

        }

        wait 0.1;
    }
#/
}

sloth_devgui_teleport()
{
/#
    sloth = level.sloth;

    if ( isdefined( sloth ) )
    {
        player = gethostplayer();
        direction = player getplayerangles();
        direction_vec = anglestoforward( direction );
        eye = player geteye();
        scale = 8000;
        direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
        trace = bullettrace( eye, eye + direction_vec, 0, undefined );

        if ( sloth.state == "jail_idle" )
        {
            maps\mp\zombies\_zm_unitrigger::register_unitrigger( sloth.gift_trigger, maps\mp\zombies\_zm_buildables::buildable_place_think );
            level.devgui_break = 1;
            level.jail_barricade notify( "trigger", player );
        }

        sloth forceteleport( trace["position"] );
        sloth.got_booze = 1;
        level notify( "cell_open" );

        if ( sloth.state != "context" )
        {
            sloth stop_action();
            sloth sloth_set_state( "roam" );
        }
    }
#/
}

sloth_devgui_barricade()
{
/#
    player = gethostplayer();
    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    pos = trace["position"];
    closest = 0;
    triggers = getentarray( "sloth_barricade", "targetname" );

    for ( i = 0; i < triggers.size; i++ )
    {
        trigger = triggers[i];
        dist = distancesquared( trigger.origin, pos );

        if ( i == 0 )
        {
            dist_max = dist;
            continue;
        }

        if ( dist < dist_max )
        {
            closest = i;
            dist_max = dist;
        }
    }

    level.devgui_break = 1;
    triggers[closest] notify( "trigger", player );
#/
}

sloth_devgui_context()
{
/#
    sloth = level.sloth;

    if ( isdefined( sloth ) )
    {
        sloth.context_debug = 1;
        sloth check_contextual_actions();
    }
#/
}

sloth_devgui_booze()
{
/#
    sloth = level.sloth;

    if ( isdefined( sloth ) )
    {
        player = gethostplayer();
        sloth stop_action();
        sloth sloth_set_state( "berserk", player );
    }
#/
}

sloth_devgui_candy()
{
/#
    sloth = level.sloth;

    if ( isdefined( sloth ) )
    {
        player = gethostplayer();
        sloth stop_action();
        sloth sloth_set_state( "eat", player );
    }
#/
}

sloth_devgui_warp_to_jail()
{
/#
    player = gethostplayer();
    player setorigin( ( -1142, 557, 28 ) );
    player setplayerangles( vectorscale( ( 0, 1, 0 ), 90.0 ) );
#/
}

sloth_devgui_move_lamp()
{
/#
    level.oillamp maps\mp\zombies\_zm_buildables::piece_unspawn();
    level.oillamp maps\mp\zombies\_zm_buildables::piece_spawn_at();
#/
}

sloth_devgui_make_crawler()
{
/#
    zombies = get_round_enemy_array();

    foreach ( zombie in zombies )
    {
        gib_style = [];
        gib_style[gib_style.size] = "no_legs";
        gib_style[gib_style.size] = "right_leg";
        gib_style[gib_style.size] = "left_leg";
        gib_style = array_randomize( gib_style );
        zombie.a.gib_ref = gib_style[0];
        zombie.has_legs = 0;
        zombie allowedstances( "crouch" );
        zombie setphysparams( 15, 0, 24 );
        zombie allowpitchangle( 1 );
        zombie setpitchorient();
        health = zombie.health;
        health *= 0.1;
        zombie thread maps\mp\animscripts\zm_run::needsdelayedupdate();
        zombie thread maps\mp\animscripts\zm_death::do_gib();
    }
#/
}

sloth_devgui_double_wide()
{
/#
    if ( getdvar( "zombie_double_wide_checks" ) == "1" )
    {
        setdvar( "zombie_double_wide_checks", 0 );
        iprintln( "double wide disabled" );
        level.devgui_double_wide = 0;
    }
    else
    {
        setdvar( "zombie_double_wide_checks", 1 );
        iprintln( "double wide enabled" );
        level.devgui_double_wide = 1;
    }
#/
}

sloth_devgui_update_phys_params()
{
/#
    while ( true )
    {
        devgui_width = getdvarint( _hash_2443DFBB );
        devgui_height = getdvarint( _hash_897C9AB4 );

        if ( self.debug_width != devgui_width || self.debug_height != devgui_height )
        {
            self.debug_width = devgui_width;
            self.debug_height = devgui_height;
            self setphysparams( self.debug_width, 0, self.debug_height );
        }

        wait 0.2;
    }
#/
}
