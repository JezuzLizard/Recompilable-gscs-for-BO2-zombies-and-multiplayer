// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_laststand;

main()
{
    level thread inits();
    level thread chamber_wall_change_randomly();
}

inits()
{
    a_walls = getentarray( "chamber_wall", "script_noteworthy" );

    foreach ( e_wall in a_walls )
    {
        e_wall.down_origin = e_wall.origin;
        e_wall.up_origin = ( e_wall.origin[0], e_wall.origin[1], e_wall.origin[2] + 1000 );
    }

    level.n_chamber_wall_active = 0;
    flag_wait( "start_zombie_round_logic" );
    wait 3.0;

    foreach ( e_wall in a_walls )
    {
        e_wall moveto( e_wall.up_origin, 0.05 );
        e_wall connectpaths();
    }
/#
    level thread chamber_devgui();
#/
}

chamber_devgui()
{
/#
    setdvarint( "chamber_wall", 5 );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Chamber:1/Fire:1\" \"chamber_wall 1\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Chamber:1/Air:2\" \"chamber_wall 2\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Chamber:1/Lightning:3\" \"chamber_wall 3\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Chamber:1/Water:4\" \"chamber_wall 4\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Chamber:1/None:5\" \"chamber_wall 0\"\n" );
    level thread watch_chamber_wall();
#/
}

watch_chamber_wall()
{
/#
    while ( true )
    {
        if ( getdvarint( _hash_763A3046 ) != 5 )
        {
            chamber_change_walls( getdvarint( _hash_763A3046 ) );
            setdvarint( "chamber_wall", 5 );
        }

        wait 0.05;
    }
#/
}

cap_value( val, min, max )
{
    if ( val < min )
        return min;
    else if ( val > max )
        return max;
    else
        return val;
}

chamber_wall_dust()
{
    for ( i = 1; i <= 9; i++ )
    {
        playfxontag( level._effect["crypt_wall_drop"], self, "tag_fx_dust_0" + i );
        wait_network_frame();
    }
}

chamber_change_walls( n_element )
{
    if ( n_element == level.n_chamber_wall_active )
        return;

    e_current_wall = undefined;
    e_new_wall = undefined;
    playsoundatposition( "zmb_chamber_wallchange", ( 10342, -7921, -272 ) );
    a_walls = getentarray( "chamber_wall", "script_noteworthy" );

    foreach ( e_wall in a_walls )
    {
        if ( e_wall.script_int == n_element )
        {
            e_wall thread move_wall_down();
            continue;
        }

        if ( e_wall.script_int == level.n_chamber_wall_active )
            e_wall thread move_wall_up();
    }

    level.n_chamber_wall_active = n_element;
}

is_chamber_occupied()
{
    a_players = getplayers();

    foreach ( e_player in a_players )
    {
        if ( is_point_in_chamber( e_player.origin ) )
            return true;
    }

    return false;
}

is_point_in_chamber( v_origin )
{
    if ( !isdefined( level.s_chamber_center ) )
    {
        level.s_chamber_center = getstruct( "chamber_center", "targetname" );
        level.s_chamber_center.radius_sq = level.s_chamber_center.script_float * level.s_chamber_center.script_float;
    }

    return distance2dsquared( level.s_chamber_center.origin, v_origin ) < level.s_chamber_center.radius_sq;
}

chamber_wall_change_randomly()
{
    flag_wait( "start_zombie_round_logic" );
    a_element_enums = array( 1, 2, 3, 4 );
    level endon( "stop_random_chamber_walls" );

    for ( n_elem_prev = undefined; 1; n_elem_prev = n_elem )
    {
        while ( !is_chamber_occupied() )
            wait 1.0;

        flag_wait( "any_crystal_picked_up" );
        n_round = cap_value( level.round_number, 10, 30 );
        f_progression_pct = ( n_round - 10 ) / ( 30 - 10 );
        n_change_wall_time = lerpfloat( 15, 5, f_progression_pct );
        n_elem = random( a_element_enums );
        arrayremovevalue( a_element_enums, n_elem, 0 );

        if ( isdefined( n_elem_prev ) )
            a_element_enums[a_element_enums.size] = n_elem_prev;

        chamber_change_walls( n_elem );
        wait( n_change_wall_time );
    }
}

move_wall_up()
{
    self moveto( self.up_origin, 1 );

    self waittill( "movedone" );

    self connectpaths();
}

move_wall_down()
{
    self moveto( self.down_origin, 1 );

    self waittill( "movedone" );

    rumble_players_in_chamber( 2, 0.1 );
    self thread chamber_wall_dust();
    self disconnectpaths();
}

random_shuffle( a_items, item )
{
    b_done_shuffling = undefined;

    if ( !isdefined( item ) )
        item = a_items[a_items.size - 1];

    while ( !( isdefined( b_done_shuffling ) && b_done_shuffling ) )
    {
        a_items = array_randomize( a_items );

        if ( a_items[0] != item )
            b_done_shuffling = 1;

        wait 0.05;
    }

    return a_items;
}

tomb_chamber_find_exit_point()
{
    self endon( "death" );
    player = get_players()[0];
    dist_zombie = 0;
    dist_player = 0;
    dest = 0;
    away = vectornormalize( self.origin - player.origin );
    endpos = self.origin + vectorscale( away, 600 );
    locs = array_randomize( level.enemy_dog_locations );

    for ( i = 0; i < locs.size; i++ )
    {
        dist_zombie = distancesquared( locs[i].origin, endpos );
        dist_player = distancesquared( locs[i].origin, player.origin );

        if ( dist_zombie < dist_player )
        {
            dest = i;
            break;
        }
    }

    self notify( "stop_find_flesh" );
    self notify( "zombie_acquire_enemy" );

    if ( isdefined( locs[dest] ) )
        self setgoalpos( locs[dest].origin );

    self.b_wandering_in_chamber = 1;
    flag_wait( "player_active_in_chamber" );
    self.b_wandering_in_chamber = 0;
    self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
}

chamber_zombies_find_poi()
{
    zombies = getaiarray( level.zombie_team );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( isdefined( zombies[i].b_wandering_in_chamber ) && zombies[i].b_wandering_in_chamber )
            continue;

        if ( !is_point_in_chamber( zombies[i].origin ) )
            continue;

        zombies[i] thread tomb_chamber_find_exit_point();
    }
}

tomb_is_valid_target_in_chamber()
{
    a_players = getplayers();

    foreach ( e_player in a_players )
    {
        if ( e_player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
            continue;

        if ( isdefined( e_player.b_zombie_blood ) && e_player.b_zombie_blood || isdefined( e_player.ignoreme ) && e_player.ignoreme )
            continue;

        if ( !is_point_in_chamber( e_player.origin ) )
            continue;

        return true;
    }

    return false;
}

is_player_in_chamber()
{
    if ( is_point_in_chamber( self.origin ) )
        return true;
    else
        return false;
}

tomb_watch_chamber_player_activity()
{
    flag_init( "player_active_in_chamber" );
    flag_wait( "start_zombie_round_logic" );

    while ( true )
    {
        wait 1.0;

        if ( is_chamber_occupied() )
        {
            if ( tomb_is_valid_target_in_chamber() )
                flag_set( "player_active_in_chamber" );
            else
            {
                flag_clear( "player_active_in_chamber" );
                chamber_zombies_find_poi();
            }
        }
    }
}
