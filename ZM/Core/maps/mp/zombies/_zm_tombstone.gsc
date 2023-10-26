// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_perks;

init()
{
    onplayerconnect_callback( ::tombstone_player_init );
    level.tombstone_laststand_func = ::tombstone_laststand;
    level.tombstone_spawn_func = ::tombstone_spawn;
    level thread tombstone_hostmigration();

    if ( isdefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
        add_custom_limited_weapon_check( ::is_weapon_available_in_tombstone );
}

tombstone_player_init()
{
    while ( !isdefined( self.tombstone_index ) )
        wait 0.1;

    level.tombstones[self.tombstone_index] = spawnstruct();
}

tombstone_spawn()
{
    dc = spawn( "script_model", self.origin + vectorscale( ( 0, 0, 1 ), 40.0 ) );
    dc.angles = self.angles;
    dc setmodel( "tag_origin" );
    dc_icon = spawn( "script_model", self.origin + vectorscale( ( 0, 0, 1 ), 40.0 ) );
    dc_icon.angles = self.angles;
    dc_icon setmodel( "ch_tombstone1" );
    dc_icon linkto( dc );
    dc.icon = dc_icon;
    dc.script_noteworthy = "player_tombstone_model";
    dc.player = self;
    self thread tombstone_clear();
    dc thread tombstone_wobble();
    dc thread tombstone_revived( self );
    result = self waittill_any_return( "player_revived", "spawned_player", "disconnect" );

    if ( result == "player_revived" || result == "disconnect" )
    {
        dc notify( "tombstone_timedout" );
        dc_icon unlink();
        dc_icon delete();
        dc delete();
        return;
    }

    dc thread tombstone_timeout();
    dc thread tombstone_grab();
}

tombstone_clear()
{
    result = self waittill_any_return( "tombstone_timedout", "tombstone_grabbed" );
    level.tombstones[self.tombstone_index] = spawnstruct();
}

tombstone_revived( player )
{
    self endon( "tombstone_timedout" );
    player endon( "disconnect" );
    shown = 1;

    while ( isdefined( self ) && isdefined( player ) )
    {
        if ( isdefined( player.revivetrigger ) && ( isdefined( player.revivetrigger.beingrevived ) && player.revivetrigger.beingrevived ) )
        {
            if ( shown )
            {
                shown = 0;
                self.icon hide();
            }
        }
        else if ( !shown )
        {
            shown = 1;
            self.icon show();
        }

        wait 0.05;
    }
}

tombstone_laststand()
{
    primaries = self getweaponslistprimaries();
    currentweapon = self getcurrentweapon();
    dc = level.tombstones[self.tombstone_index];
    dc.player = self;
    dc.weapon = [];
    dc.current_weapon = -1;

    foreach ( index, weapon in primaries )
    {
        dc.weapon[index] = weapon;
        dc.stockcount[index] = self getweaponammostock( weapon );

        if ( weapon == currentweapon )
            dc.current_weapon = index;
    }

    if ( isdefined( self.hasriotshield ) && self.hasriotshield )
        dc.hasriotshield = 1;

    dc save_weapons_for_tombstone( self );

    if ( self hasweapon( "claymore_zm" ) )
    {
        dc.hasclaymore = 1;
        dc.claymoreclip = self getweaponammoclip( "claymore_zm" );
    }

    if ( self hasweapon( "emp_grenade_zm" ) )
    {
        dc.hasemp = 1;
        dc.empclip = self getweaponammoclip( "emp_grenade_zm" );
    }

    dc.perk = tombstone_save_perks( self );
    lethal_grenade = self get_player_lethal_grenade();

    if ( self hasweapon( lethal_grenade ) )
        dc.grenade = self getweaponammoclip( lethal_grenade );
    else
        dc.grenade = 0;

    if ( maps\mp\zombies\_zm_weap_cymbal_monkey::cymbal_monkey_exists() )
        dc.zombie_cymbal_monkey_count = self getweaponammoclip( "cymbal_monkey_zm" );
}

tombstone_save_perks( ent )
{
    perk_array = [];

    if ( ent hasperk( "specialty_armorvest" ) )
        perk_array[perk_array.size] = "specialty_armorvest";

    if ( ent hasperk( "specialty_deadshot" ) )
        perk_array[perk_array.size] = "specialty_deadshot";

    if ( ent hasperk( "specialty_fastreload" ) )
        perk_array[perk_array.size] = "specialty_fastreload";

    if ( ent hasperk( "specialty_flakjacket" ) )
        perk_array[perk_array.size] = "specialty_flakjacket";

    if ( ent hasperk( "specialty_longersprint" ) )
        perk_array[perk_array.size] = "specialty_longersprint";

    if ( ent hasperk( "specialty_quickrevive" ) )
        perk_array[perk_array.size] = "specialty_quickrevive";

    if ( ent hasperk( "specialty_rof" ) )
        perk_array[perk_array.size] = "specialty_rof";

    return perk_array;
}

tombstone_grab()
{
    self endon( "tombstone_timedout" );
    wait 1;

    while ( isdefined( self ) )
    {
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i].is_zombie )
                continue;

            if ( isdefined( self.player ) && players[i] == self.player )
            {
                tombstone_machine_triggers = getentarray( "specialty_scavenger", "script_noteworthy" );
                istombstonepowered = 0;

                foreach ( trigger in tombstone_machine_triggers )
                {
                    if ( isdefined( trigger.power_on ) && trigger.power_on || isdefined( trigger.turbine_power_on ) && trigger.turbine_power_on )
                        istombstonepowered = 1;
                }

                if ( istombstonepowered )
                {
                    dist = distance( players[i].origin, self.origin );

                    if ( dist < 64 )
                    {
                        playfx( level._effect["powerup_grabbed"], self.origin );
                        playfx( level._effect["powerup_grabbed_wave"], self.origin );
                        players[i] tombstone_give();
                        wait 0.1;
                        playsoundatposition( "zmb_tombstone_grab", self.origin );
                        self stoploopsound();
                        self.icon unlink();
                        self.icon delete();
                        self delete();
                        self notify( "tombstone_grabbed" );
                        players[i] clientnotify( "dc0" );
                        players[i] notify( "dance_on_my_grave" );
                    }
                }
            }
        }

        wait_network_frame();
    }
}

tombstone_give()
{
    dc = level.tombstones[self.tombstone_index];

    if ( !flag( "solo_game" ) )
    {
        primaries = self getweaponslistprimaries();

        if ( dc.weapon.size > 1 || primaries.size > 1 )
        {
            foreach ( weapon in primaries )
                self takeweapon( weapon );
        }

        for ( i = 0; i < dc.weapon.size; i++ )
        {
            if ( !isdefined( dc.weapon[i] ) )
                continue;

            if ( dc.weapon[i] == "none" )
                continue;

            weapon = dc.weapon[i];
            stock = dc.stockcount[i];

            if ( !self hasweapon( weapon ) )
            {
                self giveweapon( weapon, 0, self maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
                self setweaponammoclip( weapon, weaponclipsize( weapon ) );
                self setweaponammostock( weapon, stock );

                if ( i == dc.current_weapon )
                    self switchtoweapon( weapon );
            }
        }
    }

    if ( isdefined( dc.hasriotshield ) && dc.hasriotshield )
    {
        self maps\mp\zombies\_zm_equipment::equipment_give( "riotshield_zm" );

        if ( isdefined( self.player_shield_reset_health ) )
            self [[ self.player_shield_reset_health ]]();
    }

    dc restore_weapons_for_tombstone( self );

    if ( isdefined( dc.hasclaymore ) && dc.hasclaymore && !self hasweapon( "claymore_zm" ) )
    {
        self giveweapon( "claymore_zm" );
        self set_player_placeable_mine( "claymore_zm" );
        self setactionslot( 4, "weapon", "claymore_zm" );
        self setweaponammoclip( "claymore_zm", dc.claymoreclip );
    }

    if ( isdefined( dc.hasemp ) && dc.hasemp )
    {
        self giveweapon( "emp_grenade_zm" );
        self setweaponammoclip( "emp_grenade_zm", dc.empclip );
    }

    if ( isdefined( dc.perk ) && dc.perk.size > 0 )
    {
        for ( i = 0; i < dc.perk.size; i++ )
        {
            if ( self hasperk( dc.perk[i] ) )
                continue;

            if ( dc.perk[i] == "specialty_quickrevive" && flag( "solo_game" ) )
                continue;

            maps\mp\zombies\_zm_perks::give_perk( dc.perk[i] );
        }
    }

    if ( dc.grenade > 0 && !flag( "solo_game" ) )
    {
        curgrenadecount = 0;

        if ( self hasweapon( self get_player_lethal_grenade() ) )
            self getweaponammoclip( self get_player_lethal_grenade() );
        else
            self giveweapon( self get_player_lethal_grenade() );

        self setweaponammoclip( self get_player_lethal_grenade(), dc.grenade + curgrenadecount );
    }

    if ( maps\mp\zombies\_zm_weap_cymbal_monkey::cymbal_monkey_exists() && !flag( "solo_game" ) )
    {
        if ( dc.zombie_cymbal_monkey_count )
        {
            self maps\mp\zombies\_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
            self setweaponammoclip( "cymbal_monkey_zm", dc.zombie_cymbal_monkey_count );
        }
    }
}

tombstone_wobble()
{
    self endon( "tombstone_grabbed" );
    self endon( "tombstone_timedout" );

    if ( isdefined( self ) )
    {
        wait 1;
        playfxontag( level._effect["powerup_on"], self, "tag_origin" );
        self playsound( "zmb_tombstone_spawn" );
        self playloopsound( "zmb_tombstone_looper" );
    }

    while ( isdefined( self ) )
    {
        self rotateyaw( 360, 3 );
        wait 2.9;
    }
}

tombstone_timeout()
{
    self endon( "tombstone_grabbed" );
    self thread playtombstonetimeraudio();
    wait 48.5;

    for ( i = 0; i < 40; i++ )
    {
        if ( i % 2 )
            self.icon ghost();
        else
            self.icon show();

        if ( i < 15 )
        {
            wait 0.5;
            continue;
        }

        if ( i < 25 )
        {
            wait 0.25;
            continue;
        }

        wait 0.1;
    }

    self notify( "tombstone_timedout" );
    self.icon unlink();
    self.icon delete();
    self delete();
}

playtombstonetimeraudio()
{
    self endon( "tombstone_grabbed" );
    self endon( "tombstone_timedout" );
    player = self.player;
    self thread playtombstonetimerout( player );

    while ( true )
    {
        player playsoundtoplayer( "zmb_tombstone_timer_count", player );
        wait 1;
    }
}

playtombstonetimerout( player )
{
    self endon( "tombstone_grabbed" );

    self waittill( "tombstone_timedout" );

    player playsoundtoplayer( "zmb_tombstone_timer_out", player );
}

save_weapons_for_tombstone( player )
{
    self.tombstone_melee_weapons = [];

    for ( i = 0; i < level._melee_weapons.size; i++ )
        self save_weapon_for_tombstone( player, level._melee_weapons[i].weapon_name );
}

save_weapon_for_tombstone( player, weapon_name )
{
    if ( player hasweapon( weapon_name ) )
        self.tombstone_melee_weapons[weapon_name] = 1;
}

restore_weapons_for_tombstone( player )
{
    for ( i = 0; i < level._melee_weapons.size; i++ )
        self restore_weapon_for_tombstone( player, level._melee_weapons[i].weapon_name );

    self.tombstone_melee_weapons = undefined;
}

restore_weapon_for_tombstone( player, weapon_name )
{
    if ( !isdefined( weapon_name ) || !isdefined( self.tombstone_melee_weapons ) || !isdefined( self.tombstone_melee_weapons[weapon_name] ) )
        return;

    if ( isdefined( self.tombstone_melee_weapons[weapon_name] ) && self.tombstone_melee_weapons[weapon_name] )
    {
        player giveweapon( weapon_name );
        player change_melee_weapon( weapon_name, "none" );
        self.tombstone_melee_weapons[weapon_name] = 0;
    }
}

tombstone_hostmigration()
{
    level endon( "end_game" );
    level notify( "tombstone_hostmigration" );
    level endon( "tombstone_hostmigration" );

    while ( true )
    {
        level waittill( "host_migration_end" );

        tombstones = getentarray( "player_tombstone_model", "script_noteworthy" );

        foreach ( model in tombstones )
            playfxontag( level._effect["powerup_on"], model, "tag_origin" );
    }
}

is_weapon_available_in_tombstone( weapon, player_to_check )
{
    count = 0;
    upgradedweapon = weapon;

    if ( isdefined( level.zombie_weapons[weapon] ) && isdefined( level.zombie_weapons[weapon].upgrade_name ) )
        upgradedweapon = level.zombie_weapons[weapon].upgrade_name;

    for ( tombstone_index = 0; tombstone_index < level.tombstones.size; tombstone_index++ )
    {
        dc = level.tombstones[tombstone_index];

        if ( !isdefined( dc.weapon ) )
            continue;

        if ( isdefined( player_to_check ) && dc.player != player_to_check )
            continue;

        for ( weapon_index = 0; weapon_index < dc.weapon.size; weapon_index++ )
        {
            if ( !isdefined( dc.weapon[weapon_index] ) )
                continue;

            tombstone_weapon = dc.weapon[weapon_index];

            if ( tombstone_weapon == weapon || tombstone_weapon == upgradedweapon )
                count++;
        }
    }

    return count;
}
