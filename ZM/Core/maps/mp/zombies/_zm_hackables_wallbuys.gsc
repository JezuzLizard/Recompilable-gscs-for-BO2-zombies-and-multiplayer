// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equip_hacker;

hack_wallbuys()
{
    weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );

    for ( i = 0; i < weapon_spawns.size; i++ )
    {
        if ( weapontype( weapon_spawns[i].zombie_weapon_upgrade ) == "grenade" )
            continue;

        if ( weapontype( weapon_spawns[i].zombie_weapon_upgrade ) == "melee" )
            continue;

        if ( weapontype( weapon_spawns[i].zombie_weapon_upgrade ) == "mine" )
            continue;

        if ( weapontype( weapon_spawns[i].zombie_weapon_upgrade ) == "bomb" )
            continue;

        struct = spawnstruct();
        struct.origin = weapon_spawns[i].origin;
        struct.radius = 48;
        struct.height = 48;
        struct.script_float = 2;
        struct.script_int = 3000;
        struct.wallbuy = weapon_spawns[i];
        maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( struct, ::wallbuy_hack );
    }

    bowie_triggers = getentarray( "bowie_upgrade", "targetname" );
    array_thread( bowie_triggers, maps\mp\zombies\_zm_equip_hacker::hide_hint_when_hackers_active );
}

wallbuy_hack( hacker )
{
    self.wallbuy.hacked = 1;
    self.clientfieldname = self.wallbuy.zombie_weapon_upgrade + "_" + self.origin;
    level setclientfield( self.clientfieldname, 2 );
    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self );
}
