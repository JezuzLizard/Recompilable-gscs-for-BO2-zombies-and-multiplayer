// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\gametypes_zm\_hud_util;

add_buildable_to_pool( stub, poolname )
{
    if ( !isdefined( level.buildablepools ) )
        level.buildablepools = [];

    if ( !isdefined( level.buildablepools[poolname] ) )
    {
        level.buildablepools[poolname] = spawnstruct();
        level.buildablepools[poolname].stubs = [];
    }

    level.buildablepools[poolname].stubs[level.buildablepools[poolname].stubs.size] = stub;

    if ( !isdefined( level.buildablepools[poolname].buildable_slot ) )
        level.buildablepools[poolname].buildable_slot = stub.buildablestruct.buildable_slot;
    else
        assert( level.buildablepools[poolname].buildable_slot == stub.buildablestruct.buildable_slot );

    stub.buildable_pool = level.buildablepools[poolname];
    stub.original_prompt_and_visibility_func = stub.prompt_and_visibility_func;
    stub.original_trigger_func = stub.trigger_func;
    stub.prompt_and_visibility_func = ::pooledbuildabletrigger_update_prompt;
    reregister_unitrigger( stub, ::pooled_buildable_place_think );
}

reregister_unitrigger( unitrigger_stub, new_trigger_func )
{
    static = 0;

    if ( isdefined( unitrigger_stub.in_zone ) )
        static = 1;

    unregister_unitrigger( unitrigger_stub );
    unitrigger_stub.trigger_func = new_trigger_func;

    if ( static )
        register_static_unitrigger( unitrigger_stub, new_trigger_func, 0 );
    else
        register_unitrigger( unitrigger_stub, new_trigger_func );
}

randomize_pooled_buildables( poolname )
{
    level waittill( "buildables_setup" );

    if ( isdefined( level.buildablepools[poolname] ) )
    {
        count = level.buildablepools[poolname].stubs.size;

        if ( count > 1 )
        {
            targets = [];

            for ( i = 0; i < count; i++ )
            {
                while ( true )
                {
                    p = randomint( count );

                    if ( !isdefined( targets[p] ) )
                    {
                        targets[p] = i;
                        break;
                    }
                }
            }

            for ( i = 0; i < count; i++ )
            {
                if ( isdefined( targets[i] ) && targets[i] != i )
                    swap_buildable_fields( level.buildablepools[poolname].stubs[i], level.buildablepools[poolname].stubs[targets[i]] );
            }
        }
    }
}

pooledbuildable_has_piece( piece )
{
    return isdefined( self pooledbuildable_stub_for_piece( piece ) );
}

pooledbuildable_stub_for_piece( piece )
{
    foreach ( stub in self.stubs )
    {
        if ( isdefined( stub.bound_to_buildable ) )
            continue;

        if ( stub.buildablezone buildable_has_piece( piece ) )
            return stub;
    }

    return undefined;
}

pooledbuildabletrigger_update_prompt( player )
{
    can_use = self.stub pooledbuildablestub_update_prompt( player, self );
    self sethintstring( self.stub.hint_string );

    if ( isdefined( self.stub.cursor_hint ) )
    {
        if ( self.stub.cursor_hint == "HINT_WEAPON" && isdefined( self.stub.cursor_hint_weapon ) )
            self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
        else
            self setcursorhint( self.stub.cursor_hint );
    }

    return can_use;
}

pooledbuildablestub_update_prompt( player, trigger )
{
    if ( !self anystub_update_prompt( player ) )
        return 0;

    can_use = 1;

    if ( isdefined( self.custom_buildablestub_update_prompt ) && !self [[ self.custom_buildablestub_update_prompt ]]( player ) )
        return 0;

    self.cursor_hint = "HINT_NOICON";
    self.cursor_hint_weapon = undefined;

    if ( !( isdefined( self.built ) && self.built ) )
    {
        slot = self.buildablestruct.buildable_slot;

        if ( !isdefined( player player_get_buildable_piece( slot ) ) )
        {
            if ( isdefined( level.zombie_buildables[self.equipname].hint_more ) )
                self.hint_string = level.zombie_buildables[self.equipname].hint_more;
            else
                self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";

            if ( isdefined( level.custom_buildable_need_part_vo ) )
                player thread [[ level.custom_buildable_need_part_vo ]]();

            return 0;
        }
        else if ( isdefined( self.bound_to_buildable ) && !self.bound_to_buildable.buildablezone buildable_has_piece( player player_get_buildable_piece( slot ) ) )
        {
            if ( isdefined( level.zombie_buildables[self.bound_to_buildable.equipname].hint_wrong ) )
                self.hint_string = level.zombie_buildables[self.bound_to_buildable.equipname].hint_wrong;
            else
                self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";

            if ( isdefined( level.custom_buildable_wrong_part_vo ) )
                player thread [[ level.custom_buildable_wrong_part_vo ]]();

            return 0;
        }
        else if ( !isdefined( self.bound_to_buildable ) && !self.buildable_pool pooledbuildable_has_piece( player player_get_buildable_piece( slot ) ) )
        {
            if ( isdefined( level.zombie_buildables[self.equipname].hint_wrong ) )
                self.hint_string = level.zombie_buildables[self.equipname].hint_wrong;
            else
                self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";

            return 0;
        }
        else if ( isdefined( self.bound_to_buildable ) )
        {
            assert( isdefined( level.zombie_buildables[self.equipname].hint ), "Missing buildable hint" );

            if ( isdefined( level.zombie_buildables[self.equipname].hint ) )
                self.hint_string = level.zombie_buildables[self.equipname].hint;
            else
                self.hint_string = "Missing buildable hint";
        }
        else
        {
            assert( isdefined( level.zombie_buildables[self.equipname].hint ), "Missing buildable hint" );

            if ( isdefined( level.zombie_buildables[self.equipname].hint ) )
                self.hint_string = level.zombie_buildables[self.equipname].hint;
            else
                self.hint_string = "Missing buildable hint";
        }
    }
    else
        return trigger [[ self.original_prompt_and_visibility_func ]]( player );

    return 1;
}

find_bench( bench_name )
{
    return getent( bench_name, "targetname" );
}

swap_buildable_fields( stub1, stub2 )
{
    tbz = stub2.buildablezone;
    stub2.buildablezone = stub1.buildablezone;
    stub2.buildablezone.stub = stub2;
    stub1.buildablezone = tbz;
    stub1.buildablezone.stub = stub1;
    tbs = stub2.buildablestruct;
    stub2.buildablestruct = stub1.buildablestruct;
    stub1.buildablestruct = tbs;
    te = stub2.equipname;
    stub2.equipname = stub1.equipname;
    stub1.equipname = te;
    th = stub2.hint_string;
    stub2.hint_string = stub1.hint_string;
    stub1.hint_string = th;
    ths = stub2.trigger_hintstring;
    stub2.trigger_hintstring = stub1.trigger_hintstring;
    stub1.trigger_hintstring = ths;
    tp = stub2.persistent;
    stub2.persistent = stub1.persistent;
    stub1.persistent = tp;
    tobu = stub2.onbeginuse;
    stub2.onbeginuse = stub1.onbeginuse;
    stub1.onbeginuse = tobu;
    tocu = stub2.oncantuse;
    stub2.oncantuse = stub1.oncantuse;
    stub1.oncantuse = tocu;
    toeu = stub2.onenduse;
    stub2.onenduse = stub1.onenduse;
    stub1.onenduse = toeu;
    tt = stub2.target;
    stub2.target = stub1.target;
    stub1.target = tt;
    ttn = stub2.targetname;
    stub2.targetname = stub1.targetname;
    stub1.targetname = ttn;
    twn = stub2.weaponname;
    stub2.weaponname = stub1.weaponname;
    stub1.weaponname = twn;
    pav = stub2.original_prompt_and_visibility_func;
    stub2.original_prompt_and_visibility_func = stub1.original_prompt_and_visibility_func;
    stub1.original_prompt_and_visibility_func = pav;
    bench1 = undefined;
    bench2 = undefined;
    transfer_pos_as_is = 1;

    if ( isdefined( stub1.model.target ) && isdefined( stub2.model.target ) )
    {
        bench1 = find_bench( stub1.model.target );
        bench2 = find_bench( stub2.model.target );

        if ( isdefined( bench1 ) && isdefined( bench2 ) )
        {
            transfer_pos_as_is = 0;
            w2lo1 = bench1 worldtolocalcoords( stub1.model.origin );
            w2la1 = stub1.model.angles - bench1.angles;
            w2lo2 = bench2 worldtolocalcoords( stub2.model.origin );
            w2la2 = stub2.model.angles - bench2.angles;
            stub1.model.origin = bench2 localtoworldcoords( w2lo1 );
            stub1.model.angles = bench2.angles + w2la1;
            stub2.model.origin = bench1 localtoworldcoords( w2lo2 );
            stub2.model.angles = bench1.angles + w2la2;
        }

        tmt = stub2.model.target;
        stub2.model.target = stub1.model.target;
        stub1.model.target = tmt;
    }

    tm = stub2.model;
    stub2.model = stub1.model;
    stub1.model = tm;

    if ( transfer_pos_as_is )
    {
        tmo = stub2.model.origin;
        tma = stub2.model.angles;
        stub2.model.origin = stub1.model.origin;
        stub2.model.angles = stub1.model.angles;
        stub1.model.origin = tmo;
        stub1.model.angles = tma;
    }
}

pooled_buildable_place_think()
{
    self endon( "kill_trigger" );

    if ( isdefined( self.stub.built ) && self.stub.built )
        return buildable_place_think();

    player_built = undefined;

    while ( !( isdefined( self.stub.built ) && self.stub.built ) )
    {
        self waittill( "trigger", player );

        if ( player != self.parent_player )
            continue;

        if ( isdefined( player.screecher_weapon ) )
            continue;

        if ( !is_player_valid( player ) )
        {
            player thread ignore_triggers( 0.5 );
            continue;
        }

        bind_to = self.stub;
        slot = bind_to.buildablestruct.buildable_slot;

        if ( !isdefined( self.stub.bound_to_buildable ) )
            bind_to = self.stub.buildable_pool pooledbuildable_stub_for_piece( player player_get_buildable_piece( slot ) );

        if ( !isdefined( bind_to ) || isdefined( self.stub.bound_to_buildable ) && self.stub.bound_to_buildable != bind_to || isdefined( bind_to.bound_to_buildable ) && self.stub != bind_to.bound_to_buildable )
        {
            self.stub.hint_string = "";
            self sethintstring( self.stub.hint_string );

            if ( isdefined( self.stub.oncantuse ) )
                self.stub [[ self.stub.oncantuse ]]( player );

            continue;
        }

        status = player player_can_build( bind_to.buildablezone );

        if ( !status )
        {
            self.stub.hint_string = "";
            self sethintstring( self.stub.hint_string );

            if ( isdefined( bind_to.oncantuse ) )
                bind_to [[ bind_to.oncantuse ]]( player );
        }
        else
        {
            if ( isdefined( bind_to.onbeginuse ) )
                self.stub [[ bind_to.onbeginuse ]]( player );

            result = self buildable_use_hold_think( player, bind_to );
            team = player.pers["team"];

            if ( result )
            {
                if ( isdefined( self.stub.bound_to_buildable ) && self.stub.bound_to_buildable != bind_to )
                    result = 0;

                if ( isdefined( bind_to.bound_to_buildable ) && self.stub != bind_to.bound_to_buildable )
                    result = 0;
            }

            if ( isdefined( bind_to.onenduse ) )
                self.stub [[ bind_to.onenduse ]]( team, player, result );

            if ( !result )
                continue;

            if ( !isdefined( self.stub.bound_to_buildable ) && isdefined( bind_to ) )
            {
                if ( bind_to != self.stub )
                    swap_buildable_fields( self.stub, bind_to );

                self.stub.bound_to_buildable = self.stub;
            }

            if ( isdefined( self.stub.onuse ) )
                self.stub [[ self.stub.onuse ]]( player );

            if ( isdefined( player player_get_buildable_piece( slot ) ) )
            {
                prompt = player player_build( self.stub.buildablezone );
                player_built = player;
                self.stub.hint_string = prompt;
                self sethintstring( self.stub.hint_string );
            }
        }
    }

    switch ( self.stub.persistent )
    {
        case 1:
            self bptrigger_think_persistent( player_built );
            break;
        case 0:
            self bptrigger_think_one_time( player_built );
            break;
        case 3:
            self bptrigger_think_unbuild( player_built );
            break;
        case 2:
            self bptrigger_think_one_use_and_fly( player_built );
            break;
        case 4:
            self [[ self.stub.custom_completion_callback ]]( player_built );
            break;
    }
}
