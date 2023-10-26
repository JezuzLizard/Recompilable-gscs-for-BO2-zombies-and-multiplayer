// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equip_hacker;

hack_perks()
{
    vending_triggers = getentarray( "zombie_vending", "targetname" );

    for ( i = 0; i < vending_triggers.size; i++ )
    {
        struct = spawnstruct();

        if ( isdefined( vending_triggers[i].machine ) )
            machine[0] = vending_triggers[i].machine;
        else
            machine = getentarray( vending_triggers[i].target, "targetname" );

        struct.origin = machine[0].origin + anglestoright( machine[0].angles ) * 18 + vectorscale( ( 0, 0, 1 ), 48.0 );
        struct.radius = 48;
        struct.height = 64;
        struct.script_float = 5;

        while ( !isdefined( vending_triggers[i].cost ) )
            wait 0.05;

        struct.script_int = int( vending_triggers[i].cost * -1 );
        struct.perk = vending_triggers[i];

        if ( isdefined( level._hack_perks_override ) )
            struct = struct [[ level._hack_perks_override ]]();

        vending_triggers[i].hackable = struct;
        maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( struct, ::perk_hack, ::perk_hack_qualifier );
    }

    level._solo_revive_machine_expire_func = ::solo_revive_expire_func;
}

solo_revive_expire_func()
{
    if ( isdefined( self.hackable ) )
    {
        maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self.hackable );
        self.hackable = undefined;
    }
}

perk_hack_qualifier( player )
{
    if ( isdefined( player._retain_perks ) )
        return false;

    if ( isdefined( self.perk ) && isdefined( self.perk.script_noteworthy ) )
    {
        if ( player hasperk( self.perk.script_noteworthy ) )
            return true;
    }

    return false;
}

perk_hack( hacker )
{
    if ( flag( "solo_game" ) && self.perk.script_noteworthy == "specialty_quickrevive" )
        hacker.lives--;

    hacker notify( self.perk.script_noteworthy + "_stop" );
    hacker playsoundtoplayer( "evt_perk_throwup", hacker );

    if ( isdefined( hacker.perk_hud ) )
    {
        keys = getarraykeys( hacker.perk_hud );

        for ( i = 0; i < hacker.perk_hud.size; i++ )
            hacker.perk_hud[keys[i]].x = i * 30;
    }
}
