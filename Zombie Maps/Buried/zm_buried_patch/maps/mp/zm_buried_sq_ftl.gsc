// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zm_buried_sq;
#include maps\mp\zm_buried_sq_ftl;
#include maps\mp\zombies\_zm_spawner;

init()
{
    flag_init( "ftl_lantern_charged" );
    declare_sidequest_stage( "sq", "ftl", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    level.sq_ftl_lantern_fuel = 0;

    if ( flag( "sq_is_max_tower_built" ) )
        level thread stage_vo_max();
    else
        level thread stage_vo_ric();

    level._cur_stage_name = "ftl";
    clientnotify( "ftl" );
}

stage_logic()
{
/#
    iprintlnbold( "FTL Started" );
#/
    if ( flag( "sq_is_max_tower_built" ) )
        max_fill_lantern_watcher();
    else
        ric_fill_lantern_watcher();

    flag_wait( "ftl_lantern_charged" );

    if ( flag( "sq_is_max_tower_built" ) )
        thread stage_vo_filled_max();
    else
        thread stage_vo_filled_ric();

    sq_ftl_show_marker();
    wait_for_buildable( "buried_sq_oillamp" );
    wait_network_frame();
    stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{

}

stage_vo_max()
{
    sq_ftl_maxis_vo_on_holder( "vox_maxi_sidequest_pl_0" );
    sq_ftl_maxis_vo_on_holder( "vox_maxi_sidequest_pl_1" );
    sq_ftl_maxis_vo_on_holder( "vox_maxi_sidequest_pl_3" );

    level waittill( "sq_ftl_lantern_inc" );

    sq_ftl_maxis_vo_on_holder( "vox_maxi_sidequest_pl_2" );
}

sq_ftl_maxis_vo_on_holder( str_vox )
{
    player = sq_ftl_get_lantern_holder();

    if ( isdefined( player ) )
        maxissay( str_vox, player );
}

sq_ftl_show_marker()
{
    m_marker = getent( "sq_lantern_symbol", "targetname" );
    m_marker.origin += vectorscale( ( 0, 0, 1 ), 2.0 );
    level.sq_lamp_generator_unitrig.origin = level.sq_lamp_generator_unitrig.realorigin;
}

sq_ftl_get_lantern_holder()
{
    players = get_players();

    foreach ( player in players )
    {
        if ( isdefined( player player_get_buildable_piece( 2 ) ) && isdefined( player player_get_buildable_piece( 2 ).buildablename == "sq_ghost_lamp" ) )
            return player;
    }
}

stage_vo_filled_max()
{
    maps\mp\zm_buried_sq_ftl::sq_ftl_maxis_vo_on_holder( "vox_maxi_sidequest_ll_0" );
}

stage_vo_ric()
{
    richtofensay( "vox_zmba_sidequest_pl_0", 12 );

    level waittill( "sq_ftl_lantern_inc" );

    richtofensay( "vox_zmba_sidequest_pl_1", 6 );
}

stage_vo_filled_ric()
{
    richtofensay( "vox_zmba_sidequest_ll_0", 10 );
    richtofensay( "vox_zmba_sidequest_ll_1", 7 );
}

max_fill_lantern_watcher()
{
    a_zombies = getaispeciesarray( level.zombie_team, "zombie" );
    array_thread( a_zombies, ::max_lantern_zombie_death_watcher );
    maps\mp\zombies\_zm_spawner::add_custom_zombie_spawn_logic( ::max_lantern_zombie_death_watcher );
}

max_lantern_zombie_death_watcher()
{
    level endon( "ftl_lantern_charged" );

    if ( flag( "ftl_lantern_charged" ) )
        return;

    self waittill( "death", attacker );

    if ( !isdefined( attacker ) || isplayer( attacker ) )
        return;

    players = getplayers();

    foreach ( player in players )
    {
        if ( isdefined( player player_get_buildable_piece( 2 ) ) && isdefined( player player_get_buildable_piece( 2 ).buildablename == "sq_ghost_lamp" ) )
        {
            if ( isdefined( self ) && distancesquared( player.origin, self.origin ) < 65536 )
                player ftl_lantern_increment();
        }
    }
}

ric_fill_lantern_watcher()
{
    a_axis = getaiarray( "axis" );
    a_ghost = [];

    foreach ( e_axis in a_axis )
    {
        if ( is_true( e_axis.is_ghost ) )
            a_ghost[a_ghost.size] = e_axis;
    }

    array_thread( a_ghost, ::ric_lantern_ghost_death_watcher );
    a_ghost_spawners = getspawnerarray( "ghost_zombie_spawner", "script_noteworthy" );
    array_thread( a_ghost_spawners, ::add_spawn_function, ::ric_lantern_ghost_death_watcher );
}

ric_lantern_ghost_death_watcher()
{
    level endon( "ftl_lantern_charged" );

    if ( flag( "ftl_lantern_charged" ) )
        return;

    self waittill( "death", attacker );

    players = getplayers();

    foreach ( player in players )
    {
        if ( isdefined( player player_get_buildable_piece( 2 ) ) && isdefined( player player_get_buildable_piece( 2 ).buildablename == "sq_ghost_lamp" ) )
        {
            if ( isdefined( self ) && distancesquared( player.origin, self.origin ) < 65536 )
                player ftl_lantern_increment();
        }
    }
}

ftl_lantern_increment()
{
    level.sq_ftl_lantern_fuel++;
    level notify( "sq_ftl_lantern_inc" );
    self playsound( "zmb_lantern_fill_" + level.sq_ftl_lantern_fuel );
/#
    iprintlnbold( "Fuel Level: " + level.sq_ftl_lantern_fuel );
#/
    if ( level.sq_ftl_lantern_fuel >= 10 )
    {
        self playsound( "zmb_lantern_fill_done" );
        flag_set( "ftl_lantern_charged" );
    }
}
