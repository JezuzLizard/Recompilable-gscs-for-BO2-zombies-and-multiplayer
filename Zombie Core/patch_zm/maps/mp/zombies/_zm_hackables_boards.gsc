// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equip_hacker;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_blockers;

hack_boards()
{
    windows = getstructarray( "exterior_goal", "targetname" );

    for ( i = 0; i < windows.size; i++ )
    {
        window = windows[i];
        struct = spawnstruct();
        spot = window;

        if ( isdefined( window.trigger_location ) )
            spot = window.trigger_location;

        org = groundpos( spot.origin ) + vectorscale( ( 0, 0, 1 ), 4.0 );
        r = 96;
        h = 96;

        if ( isdefined( spot.radius ) )
            r = spot.radius;

        if ( isdefined( spot.height ) )
            h = spot.height;

        struct.origin = org + vectorscale( ( 0, 0, 1 ), 48.0 );
        struct.radius = r;
        struct.height = h;
        struct.script_float = 2;
        struct.script_int = 0;
        struct.window = window;
        struct.no_bullet_trace = 1;
        struct.no_sight_check = 1;
        struct.dot_limit = 0.7;
        struct.no_touch_check = 1;
        struct.last_hacked_round = 0;
        struct.num_hacks = 0;
        maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( struct, ::board_hack, ::board_qualifier );
    }
}

board_hack( hacker )
{
    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self );
    num_chunks_checked = 0;
    last_repaired_chunk = undefined;

    if ( self.last_hacked_round != level.round_number )
    {
        self.last_hacked_round = level.round_number;
        self.num_hacks = 0;
    }

    self.num_hacks++;

    if ( self.num_hacks < 3 )
        hacker maps\mp\zombies\_zm_score::add_to_player_score( 100 );
    else
    {
        cost = int( min( 300, hacker.score ) );

        if ( cost )
            hacker maps\mp\zombies\_zm_score::minus_to_player_score( cost );
    }

    while ( true )
    {
        if ( all_chunks_intact( self.window, self.window.barrier_chunks ) )
            break;

        chunk = get_random_destroyed_chunk( self.window, self.window.barrier_chunks );

        if ( !isdefined( chunk ) )
            break;

        self.window thread maps\mp\zombies\_zm_blockers::replace_chunk( self.window, chunk, undefined, 0, 1 );
        last_repaired_chunk = chunk;

        if ( isdefined( self.clip ) )
        {
            self.window.clip enable_trigger();
            self.window.clip disconnectpaths();
        }
        else
            blocker_disconnect_paths( self.window.neg_start, self.window.neg_end );

        wait_network_frame();
        num_chunks_checked++;

        if ( num_chunks_checked >= 20 )
            break;
    }

    if ( isdefined( self.window.zbarrier ) )
    {
        if ( isdefined( last_repaired_chunk ) )
        {
            while ( self.window.zbarrier getzbarrierpiecestate( last_repaired_chunk ) == "closing" )
                wait 0.05;
        }
    }
    else
    {
        while ( isdefined( last_repaired_chunk ) && last_repaired_chunk.state == "mid_repair" )
            wait 0.05;
    }

    maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( self, ::board_hack, ::board_qualifier );
    self.window notify( "blocker_hacked" );
    self.window notify( "no valid boards" );
}

board_qualifier( player )
{
    if ( all_chunks_intact( self.window, self.window.barrier_chunks ) || no_valid_repairable_boards( self.window, self.window.barrier_chunks ) )
        return false;

    return true;
}
