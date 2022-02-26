// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_turned;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_laststand;

init()
{
/#
    setdvar( "zombie_devgui", "" );
    setdvar( "scr_force_weapon", "" );
    setdvar( "scr_zombie_round", "1" );
    setdvar( "scr_zombie_dogs", "1" );
    setdvar( "scr_spawn_tesla", "" );
    setdvar( "scr_force_quantum_bomb_result", "" );
    level.devgui_add_weapon = ::devgui_add_weapon;
    level.devgui_add_ability = ::devgui_add_ability;
    level thread zombie_devgui_think();
    thread zombie_devgui_player_commands();
    thread diable_fog_in_noclip();
    thread zombie_weapon_devgui_think();
    thread devgui_zombie_healthbar();
#/
}

zombie_devgui_player_commands()
{
/#
    flag_wait( "start_zombie_round_logic" );
    wait 1;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        ip1 = i + 1;
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Give Money:1\" \"set zombie_devgui player" + ip1 + "_money\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Invulnerable:2\" \"set zombie_devgui player" + ip1 + "_invul_on\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Vulnerable:3\" \"set zombie_devgui player" + ip1 + "_invul_off\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Toggle Ignored:4\" \"set zombie_devgui player" + ip1 + "_ignore\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Mega Health:5\" \"set zombie_devgui player" + ip1 + "_health\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Down:6\" \"set zombie_devgui player" + ip1 + "_kill\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Revive:7\" \"set zombie_devgui player" + ip1 + "_revive\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Turn Player:8\" \"set zombie_devgui player" + ip1 + "_turnplayer\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Debug Pers:9\" \"set zombie_devgui player" + ip1 + "_debug_pers\" \n" );
        adddebugcommand( "devgui_cmd \"Zombies:1/Players:1/Player:1/" + players[i].name + "/Take Money:10\" \"set zombie_devgui player" + ip1 + "_moneydown\" \n" );
    }
#/
}

devgui_add_weapon_entry( hint, up, weapon_name, root )
{
/#
    rootslash = "";

    if ( isdefined( root ) && root.size )
        rootslash = root + "/";

    uppath = "/" + up;

    if ( up.size < 1 )
        uppath = "";

    cmd = "devgui_cmd \"Zombies:1/Weapons:10/" + rootslash + hint + uppath + "\" \"set zombie_devgui_gun " + weapon_name + "\" \n";
    adddebugcommand( cmd );
#/
}

devgui_add_weapon_and_attachments( hint, up, weapon_name, root )
{
/#
    devgui_add_weapon_entry( hint, up, weapon_name, root );
#/
}

devgui_add_weapon( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost )
{
/#
    if ( is_offhand_weapon( weapon_name ) && !is_melee_weapon( weapon_name ) )
        return;

    if ( !isdefined( level.devgui_weapons_added ) )
        level.devgui_weapons_added = 0;

    level.devgui_weapons_added++;

    if ( is_melee_weapon( weapon_name ) )
        devgui_add_weapon_and_attachments( weapon_name, "", weapon_name, "Melee:8" );
    else
        devgui_add_weapon_and_attachments( weapon_name, "", weapon_name, "" );
#/
}

zombie_weapon_devgui_think()
{
/#
    level.zombie_devgui_gun = getdvar( _hash_CE4F9F97 );
    level.zombie_devgui_att = getdvar( _hash_A965F402 );

    for (;;)
    {
        wait 0.25;
        cmd = getdvar( _hash_CE4F9F97 );

        if ( !isdefined( level.zombie_devgui_gun ) || level.zombie_devgui_gun != cmd )
        {
            level.zombie_devgui_gun = cmd;
            array_thread( get_players(), ::zombie_devgui_weapon_give, level.zombie_devgui_gun );
        }

        wait 0.25;
        att = getdvar( _hash_A965F402 );

        if ( !isdefined( level.zombie_devgui_att ) || level.zombie_devgui_att != att )
        {
            level.zombie_devgui_att = att;
            array_thread( get_players(), ::zombie_devgui_attachment_give, level.zombie_devgui_att );
        }
    }
#/
}

zombie_devgui_weapon_give( gun )
{
/#
    self maps\mp\zombies\_zm_weapons::weapon_give( gun, is_weapon_upgraded( gun ), 0 );
#/
}

zombie_devgui_attachment_give( gun )
{
/#
    newgun = maps\mp\zombies\_zm_weapons::get_base_name( self getcurrentweapon() ) + "+" + gun;
    self maps\mp\zombies\_zm_weapons::weapon_give( newgun, is_weapon_upgraded( gun ), 0 );
#/
}

devgui_add_ability( name, upgrade_active_func, stat_name, stat_desired_value, game_end_reset_if_not_achieved )
{
/#
    online_game = sessionmodeisonlinegame();

    if ( !online_game )
        return;

    if ( !is_true( level.devgui_watch_abilities ) )
    {
        cmd = "devgui_cmd \"Zombies:1/Players:1/Abilities:3/Disable All:1\" \"set zombie_devgui_give_ability _disable\" \n";
        adddebugcommand( cmd );
        cmd = "devgui_cmd \"Zombies:1/Players:1/Abilities:3/Enable All:2\" \"set zombie_devgui_give_ability _enable\" \n";
        adddebugcommand( cmd );
        level thread zombie_ability_devgui_think();
        level.devgui_watch_abilities = 1;
    }

    cmd = "devgui_cmd \"Zombies:1/Players:1/Abilities:3/" + name + "\" \"set zombie_devgui_give_ability " + name + "\" \n";
    adddebugcommand( cmd );
    cmd = "devgui_cmd \"Zombies:1/Players:1/Abilities:3/Take:3/" + name + "\" \"set zombie_devgui_take_ability " + name + "\" \n";
    adddebugcommand( cmd );
#/
}

zombie_devgui_ability_give( name )
{
/#
    pers_upgrade = level.pers_upgrades[name];

    if ( isdefined( pers_upgrade ) )
    {
        for ( i = 0; i < pers_upgrade.stat_names.size; i++ )
        {
            stat_name = pers_upgrade.stat_names[i];
            stat_value = pers_upgrade.stat_desired_values[i];
            self maps\mp\zombies\_zm_stats::set_global_stat( stat_name, stat_value );
            self.pers_upgrade_force_test = 1;
        }
    }
#/
}

zombie_devgui_ability_take( name )
{
/#
    pers_upgrade = level.pers_upgrades[name];

    if ( isdefined( pers_upgrade ) )
    {
        for ( i = 0; i < pers_upgrade.stat_names.size; i++ )
        {
            stat_name = pers_upgrade.stat_names[i];
            stat_value = 0;
            self maps\mp\zombies\_zm_stats::set_global_stat( stat_name, stat_value );
            self.pers_upgrade_force_test = 1;
        }
    }
#/
}

zombie_ability_devgui_think()
{
/#
    level.zombie_devgui_give_ability = getdvar( _hash_E2245F05 );
    level.zombie_devgui_take_ability = getdvar( _hash_726367F );

    for (;;)
    {
        wait 0.25;
        cmd = getdvar( _hash_E2245F05 );

        if ( !isdefined( level.zombie_devgui_give_ability ) || level.zombie_devgui_give_ability != cmd )
        {
            if ( cmd == "_disable" )
                flag_set( "sq_minigame_active" );
            else if ( cmd == "_enable" )
                flag_clear( "sq_minigame_active" );
            else
            {
                level.zombie_devgui_give_ability = cmd;
                array_thread( get_players(), ::zombie_devgui_ability_give, level.zombie_devgui_give_ability );
            }
        }

        wait 0.25;
        cmd = getdvar( _hash_726367F );

        if ( !isdefined( level.zombie_devgui_take_ability ) || level.zombie_devgui_take_ability != cmd )
        {
            level.zombie_devgui_take_ability = cmd;
            array_thread( get_players(), ::zombie_devgui_ability_take, level.zombie_devgui_take_ability );
        }
    }
#/
}

zombie_healthbar( pos, dsquared )
{
/#
    if ( distancesquared( pos, self.origin ) > dsquared )
        return;

    rate = 1;

    if ( isdefined( self.maxhealth ) )
        rate = self.health / self.maxhealth;

    color = ( 1 - rate, rate, 0 );
    text = "" + int( self.health );
    print3d( self.origin + ( 0, 0, 0 ), text, color, 1, 0.5, 1 );
#/
}

devgui_zombie_healthbar()
{
/#
    while ( true )
    {
        if ( getdvarint( _hash_5B45DCAF ) == 1 )
        {
            lp = get_players()[0];
            zombies = getaispeciesarray( "all", "all" );

            if ( isdefined( zombies ) )
            {
                foreach ( zombie in zombies )
                    zombie zombie_healthbar( lp.origin, 360000 );
            }
        }

        wait 0.05;
    }
#/
}

zombie_devgui_watch_input()
{
/#
    flag_wait( "start_zombie_round_logic" );
    wait 1;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] thread watch_debug_input();
#/
}

damage_player()
{
/#
    self disableinvulnerability();
    self dodamage( self.health / 2, self.origin );
#/
}

kill_player()
{
/#
    self disableinvulnerability();
    death_from = ( randomfloatrange( -20, 20 ), randomfloatrange( -20, 20 ), randomfloatrange( -20, 20 ) );
    self dodamage( self.health + 666, self.origin + death_from );
#/
}

force_drink()
{
/#
    wait 0.01;
    lean = self allowlean( 0 );
    ads = self allowads( 0 );
    sprint = self allowsprint( 0 );
    crouch = self allowcrouch( 1 );
    prone = self allowprone( 0 );
    melee = self allowmelee( 0 );
    self increment_is_drinking();
    orgweapon = self getcurrentweapon();
    self giveweapon( "zombie_builder_zm" );
    self switchtoweapon( "zombie_builder_zm" );
    self.build_time = self.usetime;
    self.build_start_time = gettime();
    wait 2;
    self maps\mp\zombies\_zm_weapons::switch_back_primary_weapon( orgweapon );
    self takeweapon( "zombie_builder_zm" );

    if ( is_true( self.is_drinking ) )
        self decrement_is_drinking();

    self allowlean( lean );
    self allowads( ads );
    self allowsprint( sprint );
    self allowprone( prone );
    self allowcrouch( crouch );
    self allowmelee( melee );
#/
}

zombie_devgui_dpad_none()
{
/#
    self thread watch_debug_input();
#/
}

zombie_devgui_dpad_death()
{
/#
    self thread watch_debug_input( ::kill_player );
#/
}

zombie_devgui_dpad_damage()
{
/#
    self thread watch_debug_input( ::damage_player );
#/
}

zombie_devgui_dpad_changeweapon()
{
/#
    self thread watch_debug_input( ::force_drink );
#/
}

watch_debug_input( callback )
{
/#
    self endon( "disconnect" );
    self notify( "watch_debug_input" );
    self endon( "watch_debug_input" );
    level.devgui_dpad_watch = 0;

    if ( isdefined( callback ) )
    {
        level.devgui_dpad_watch = 1;

        for (;;)
        {
            if ( self actionslottwobuttonpressed() )
            {
                self thread [[ callback ]]();

                while ( self actionslottwobuttonpressed() )
                    wait 0.05;
            }

            wait 0.05;
        }
    }
#/
}

zombie_devgui_think()
{
/#
    for (;;)
    {
        cmd = getdvar( "zombie_devgui" );

        switch ( cmd )
        {
            case "money":
                players = get_players();
                array_thread( players, ::zombie_devgui_give_money );
                break;
            case "player1_money":
                players = get_players();

                if ( players.size >= 1 )
                    players[0] thread zombie_devgui_give_money();

                break;
            case "player2_money":
                players = get_players();

                if ( players.size >= 2 )
                    players[1] thread zombie_devgui_give_money();

                break;
            case "player3_money":
                players = get_players();

                if ( players.size >= 3 )
                    players[2] thread zombie_devgui_give_money();

                break;
            case "player4_money":
                players = get_players();

                if ( players.size >= 4 )
                    players[3] thread zombie_devgui_give_money();

                break;
            case "moneydown":
                players = get_players();
                array_thread( players, ::zombie_devgui_take_money );
                break;
            case "player1_moneydown":
                players = get_players();

                if ( players.size >= 1 )
                    players[0] thread zombie_devgui_take_money();

                break;
            case "player2_moneydown":
                players = get_players();

                if ( players.size >= 2 )
                    players[1] thread zombie_devgui_take_money();

                break;
            case "player3_moneydown":
                players = get_players();

                if ( players.size >= 3 )
                    players[2] thread zombie_devgui_take_money();

                break;
            case "player4_moneydown":
                players = get_players();

                if ( players.size >= 4 )
                    players[3] thread zombie_devgui_take_money();

                break;
            case "health":
                array_thread( get_players(), ::zombie_devgui_give_health );
                break;
            case "player1_health":
                players = get_players();

                if ( players.size >= 1 )
                    players[0] thread zombie_devgui_give_health();

                break;
            case "player2_health":
                players = get_players();

                if ( players.size >= 2 )
                    players[1] thread zombie_devgui_give_health();

                break;
            case "player3_health":
                players = get_players();

                if ( players.size >= 3 )
                    players[2] thread zombie_devgui_give_health();

                break;
            case "player4_health":
                players = get_players();

                if ( players.size >= 4 )
                    players[3] thread zombie_devgui_give_health();

                break;
            case "ammo":
                array_thread( get_players(), ::zombie_devgui_toggle_ammo );
                break;
            case "ignore":
                array_thread( get_players(), ::zombie_devgui_toggle_ignore );
                break;
            case "player1_ignore":
                players = get_players();

                if ( players.size >= 1 )
                    players[0] thread zombie_devgui_toggle_ignore();

                break;
            case "player2_ignore":
                players = get_players();

                if ( players.size >= 2 )
                    players[1] thread zombie_devgui_toggle_ignore();

                break;
            case "player3_ignore":
                players = get_players();

                if ( players.size >= 3 )
                    players[2] thread zombie_devgui_toggle_ignore();

                break;
            case "player4_ignore":
                players = get_players();

                if ( players.size >= 4 )
                    players[3] thread zombie_devgui_toggle_ignore();

                break;
            case "invul_on":
                zombie_devgui_invulnerable( undefined, 1 );
                break;
            case "invul_off":
                zombie_devgui_invulnerable( undefined, 0 );
                break;
            case "player1_invul_on":
                zombie_devgui_invulnerable( 0, 1 );
                break;
            case "player1_invul_off":
                zombie_devgui_invulnerable( 0, 0 );
                break;
            case "player2_invul_on":
                zombie_devgui_invulnerable( 1, 1 );
                break;
            case "player2_invul_off":
                zombie_devgui_invulnerable( 1, 0 );
                break;
            case "player3_invul_on":
                zombie_devgui_invulnerable( 2, 1 );
                break;
            case "player3_invul_off":
                zombie_devgui_invulnerable( 2, 0 );
                break;
            case "player4_invul_on":
                zombie_devgui_invulnerable( 3, 1 );
                break;
            case "player4_invul_off":
                zombie_devgui_invulnerable( 3, 0 );
                break;
            case "revive_all":
                array_thread( get_players(), ::zombie_devgui_revive );
                break;
            case "player1_revive":
                players = get_players();

                if ( players.size >= 1 )
                    players[0] thread zombie_devgui_revive();

                break;
            case "player2_revive":
                players = get_players();

                if ( players.size >= 2 )
                    players[1] thread zombie_devgui_revive();

                break;
            case "player3_revive":
                players = get_players();

                if ( players.size >= 3 )
                    players[2] thread zombie_devgui_revive();

                break;
            case "player4_revive":
                players = get_players();

                if ( players.size >= 4 )
                    players[3] thread zombie_devgui_revive();

                break;
            case "player1_kill":
                players = get_players();

                if ( players.size >= 1 )
                    players[0] thread zombie_devgui_kill();

                break;
            case "player2_kill":
                players = get_players();

                if ( players.size >= 2 )
                    players[1] thread zombie_devgui_kill();

                break;
            case "player3_kill":
                players = get_players();

                if ( players.size >= 3 )
                    players[2] thread zombie_devgui_kill();

                break;
            case "player4_kill":
                players = get_players();

                if ( players.size >= 4 )
                    players[3] thread zombie_devgui_kill();

                break;
            case "spawn_friendly_bot":
                player = gethostplayer();
                team = player.team;
                devgui_bot_spawn( team );
                break;
            case "specialty_quickrevive":
                level.solo_lives_given = 0;
            case "specialty_showonradar":
            case "specialty_scavenger":
            case "specialty_rof":
            case "specialty_nomotionsensor":
            case "specialty_longersprint":
            case "specialty_grenadepulldeath":
            case "specialty_flakjacket":
            case "specialty_finalstand":
            case "specialty_fastreload":
            case "specialty_fastmeleerecovery":
            case "specialty_deadshot":
            case "specialty_armorvest":
            case "specialty_additionalprimaryweapon":
                zombie_devgui_give_perk( cmd );
                break;
            case "turnplayer":
                zombie_devgui_turn_player();
                break;
            case "player1_turnplayer":
                zombie_devgui_turn_player( 0 );
                break;
            case "player2_turnplayer":
                zombie_devgui_turn_player( 1 );
                break;
            case "player3_turnplayer":
                zombie_devgui_turn_player( 2 );
                break;
            case "player4_turnplayer":
                zombie_devgui_turn_player( 3 );
                break;
            case "player1_debug_pers":
                zombie_devgui_debug_pers( 0 );
                break;
            case "player2_debug_pers":
                zombie_devgui_debug_pers( 1 );
                break;
            case "player3_debug_pers":
                zombie_devgui_debug_pers( 2 );
                break;
            case "player4_debug_pers":
                zombie_devgui_debug_pers( 3 );
                break;
            case "tesla":
            case "random_weapon":
            case "nuke":
            case "minigun":
            case "meat_stink":
            case "lose_points_team":
            case "lose_perk":
            case "insta_kill":
            case "full_ammo":
            case "free_perk":
            case "fire_sale":
            case "empty_clip":
            case "double_points":
            case "carpenter":
            case "bonus_points_team":
            case "bonus_points_player":
            case "bonfire_sale":
                zombie_devgui_give_powerup( cmd, 1 );
                break;
            case "next_tesla":
            case "next_random_weapon":
            case "next_nuke":
            case "next_minigun":
            case "next_meat_stink":
            case "next_lose_points_team":
            case "next_lose_perk":
            case "next_insta_kill":
            case "next_full_ammo":
            case "next_free_perk":
            case "next_fire_sale":
            case "next_empty_clip":
            case "next_double_points":
            case "next_carpenter":
            case "next_bonus_points_team":
            case "next_bonus_points_player":
            case "next_bonfire_sale":
                zombie_devgui_give_powerup( getsubstr( cmd, 5 ), 0 );
                break;
            case "round":
                zombie_devgui_goto_round( getdvarint( _hash_D81B6E19 ) );
                break;
            case "round_next":
                zombie_devgui_goto_round( level.round_number + 1 );
                break;
            case "round_prev":
                zombie_devgui_goto_round( level.round_number - 1 );
                break;
            case "chest_move":
                if ( isdefined( level.chest_accessed ) )
                {
                    level notify( "devgui_chest_end_monitor" );
                    level.chest_accessed = 100;
                }

                break;
            case "chest_never_move":
                if ( isdefined( level.chest_accessed ) )
                    level thread zombie_devgui_chest_never_move();

                break;
            case "chest":
                if ( isdefined( level.zombie_weapons[getdvar( _hash_45ED7744 )] ) )
                {

                }

                break;
            case "quantum_bomb_random_result":
                setdvar( "scr_force_quantum_bomb_result", "" );
                break;
            case "give_gasmask":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_gasmask_zm" );
                break;
            case "give_hacker":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_hacker_zm" );
                break;
            case "give_turbine":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_turbine_zm" );
                break;
            case "give_turret":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_turret_zm" );
                break;
            case "give_electrictrap":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_electrictrap_zm" );
                break;
            case "give_riotshield":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "riotshield_zm" );
                break;
            case "give_jetgun":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "jetgun_zm" );
                break;
            case "give_springpad":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_springpad_zm" );
                break;
            case "give_subwoofer":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_subwoofer_zm" );
                break;
            case "give_headchopper":
                array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_headchopper_zm" );
                break;
            case "cool_jetgun":
                array_thread( get_players(), ::zombie_devgui_cool_jetgun );
                break;
            case "preserve_turbines":
                array_thread( get_players(), ::zombie_devgui_preserve_turbines );
                break;
            case "healthy_equipment":
                array_thread( get_players(), ::zombie_devgui_equipment_stays_healthy );
                break;
            case "disown_equipment":
                array_thread( get_players(), ::zombie_devgui_disown_equipment );
                break;
            case "buildable_drop":
                array_thread( get_players(), ::zombie_devgui_buildable_drop );
                break;
            case "build_busladder":
                zombie_devgui_build( "busladder" );
                break;
            case "build_bushatch":
                zombie_devgui_build( "bushatch" );
                break;
            case "build_dinerhatch":
                zombie_devgui_build( "dinerhatch" );
                break;
            case "build_cattlecatcher":
                zombie_devgui_build( "cattlecatcher" );
                break;
            case "build_pap":
                zombie_devgui_build( "pap" );
                break;
            case "build_riotshield_zm":
                zombie_devgui_build( "riotshield_zm" );
                break;
            case "build_powerswitch":
                zombie_devgui_build( "powerswitch" );
                break;
            case "build_turbine":
                zombie_devgui_build( "turbine" );
                break;
            case "build_turret":
                zombie_devgui_build( "turret" );
                break;
            case "build_electric_trap":
                zombie_devgui_build( "electric_trap" );
                break;
            case "build_jetgun_zm":
                zombie_devgui_build( "jetgun_zm" );
                break;
            case "build_sq_common":
                zombie_devgui_build( "sq_common" );
                break;
            case "build_springpad":
                zombie_devgui_build( "springpad_zm" );
                break;
            case "build_slipgun":
                zombie_devgui_build( "slipgun_zm" );
                break;
            case "build_keys":
                zombie_devgui_build( "keys_zm" );
                break;
            case "give_claymores":
                array_thread( get_players(), ::zombie_devgui_give_claymores );
                break;
            case "give_frags":
                array_thread( get_players(), ::zombie_devgui_give_frags );
                break;
            case "give_sticky":
                array_thread( get_players(), ::zombie_devgui_give_sticky );
                break;
            case "give_monkey":
                array_thread( get_players(), ::zombie_devgui_give_monkey );
                break;
            case "give_beacon":
                array_thread( get_players(), ::zombie_devgui_give_beacon );
                break;
            case "give_time_bomb":
                array_thread( get_players(), ::zombie_devgui_give_time_bomb );
                break;
            case "give_black_hole_bomb":
                array_thread( get_players(), ::zombie_devgui_give_black_hole_bomb );
                break;
            case "give_dolls":
                array_thread( get_players(), ::zombie_devgui_give_dolls );
                break;
            case "give_quantum_bomb":
                array_thread( get_players(), ::zombie_devgui_give_quantum_bomb );
                break;
            case "give_emp_bomb":
                array_thread( get_players(), ::zombie_devgui_give_emp_bomb );
                break;
            case "monkey_round":
                zombie_devgui_monkey_round();
                break;
            case "thief_round":
                zombie_devgui_thief_round();
                break;
            case "dog_round":
                zombie_devgui_dog_round( getdvarint( _hash_3CD25BFE ) );
                break;
            case "dog_round_skip":
                zombie_devgui_dog_round_skip();
                break;
            case "print_variables":
                zombie_devgui_dump_zombie_vars();
                break;
            case "pack_current_weapon":
                zombie_devgui_pack_current_weapon();
                break;
            case "unpack_current_weapon":
                zombie_devgui_unpack_current_weapon();
                break;
            case "reopt_current_weapon":
                zombie_devgui_reopt_current_weapon();
                break;
            case "weapon_take_all_fallback":
                zombie_devgui_take_weapons( 1 );
                break;
            case "weapon_take_all":
                zombie_devgui_take_weapons( 0 );
                break;
            case "weapon_take_current":
                zombie_devgui_take_weapon();
                break;
            case "power_on":
                flag_set( "power_on" );
                break;
            case "power_off":
                flag_clear( "power_on" );
                break;
            case "zombie_dpad_none":
                array_thread( get_players(), ::zombie_devgui_dpad_none );
                break;
            case "zombie_dpad_damage":
                array_thread( get_players(), ::zombie_devgui_dpad_damage );
                break;
            case "zombie_dpad_kill":
                array_thread( get_players(), ::zombie_devgui_dpad_death );
                break;
            case "zombie_dpad_drink":
                array_thread( get_players(), ::zombie_devgui_dpad_changeweapon );
                break;
            case "director_easy":
                zombie_devgui_director_easy();
                break;
            case "open_sesame":
                zombie_devgui_open_sesame();
                break;
            case "allow_fog":
                zombie_devgui_allow_fog();
                break;
            case "disable_kill_thread_toggle":
                zombie_devgui_disable_kill_thread_toggle();
                break;
            case "check_kill_thread_every_frame_toggle":
                zombie_devgui_check_kill_thread_every_frame_toggle();
                break;
            case "kill_thread_test_mode_toggle":
                zombie_devgui_kill_thread_test_mode_toggle();
                break;
            case "zombie_failsafe_debug_flush":
                level notify( "zombie_failsafe_debug_flush" );
                break;
            case "spawn":
                devgui_zombie_spawn();
                break;
            case "spawn_all":
                devgui_all_spawn();
                break;
            case "toggle_show_spawn_locations":
                devgui_toggle_show_spawn_locations();
                break;
            case "debug_hud":
                array_thread( get_players(), ::devgui_debug_hud );
                break;
            case "":
                break;
            default:
                if ( isdefined( level.custom_devgui ) )
                {
                    if ( isarray( level.custom_devgui ) )
                    {
                        i = 0;

                        do
                        {
                            b_found_entry = is_true( [[ level.custom_devgui[i] ]]( cmd ) );
                            i++;
                        }
                        while ( !b_found_entry && i < level.custom_devgui.size );
                    }
                    else
                        [[ level.custom_devgui ]]( cmd );
                }
                else
                {

                }

                break;
        }

        setdvar( "zombie_devgui", "" );
        wait 0.5;
    }
#/
}

devgui_all_spawn()
{
/#
    player = gethostplayer();
    devgui_bot_spawn( player.team );
    wait 0.1;
    devgui_bot_spawn( player.team );
    wait 0.1;
    devgui_bot_spawn( player.team );
    wait 0.1;
    zombie_devgui_goto_round( 8 );
#/
}

devgui_toggle_show_spawn_locations()
{
/#
    if ( !isdefined( level.toggle_show_spawn_locations ) )
        level.toggle_show_spawn_locations = 1;
    else
        level.toggle_show_spawn_locations = !level.toggle_show_spawn_locations;
#/
}

devgui_zombie_spawn()
{
/#
    player = get_players()[0];
    spawnername = undefined;
    spawnername = "zombie_spawner";
    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    guy = undefined;
    spawners = getentarray( spawnername, "script_noteworthy" );
    spawner = spawners[0];
    guy = maps\mp\zombies\_zm_utility::spawn_zombie( spawner );

    if ( isdefined( guy ) )
    {
        wait 0.5;
        guy.origin = trace["position"];
        guy.angles = player.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
        guy forceteleport( trace["position"], player.angles + vectorscale( ( 0, 1, 0 ), 180.0 ) );
        guy thread maps\mp\zombies\_zm_ai_basic::find_flesh();
    }
#/
}

devgui_bot_spawn( team )
{
/#
    player = gethostplayer();
    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    direction_vec = player.origin - trace["position"];
    direction = vectortoangles( direction_vec );
    bot = addtestclient();

    if ( !isdefined( bot ) )
    {
        println( "Could not add test client" );
        return;
    }

    bot.pers["isBot"] = 1;
    bot.equipment_enabled = 0;
    bot maps\mp\zombies\_zm::reset_rampage_bookmark_kill_times();
    bot.team = "allies";
    bot._player_entnum = bot getentitynumber();
    yaw = direction[1];
    bot thread devgui_bot_spawn_think( trace["position"], yaw );
#/
}

devgui_bot_spawn_think( origin, yaw )
{
/#
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self setorigin( origin );
        angles = ( 0, yaw, 0 );
        self setplayerangles( angles );
    }
#/
}

zombie_devgui_open_sesame()
{
/#
    setdvar( "zombie_unlock_all", 1 );
    flag_set( "power_on" );
    players = get_players();
    array_thread( players, ::zombie_devgui_give_money );
    zombie_doors = getentarray( "zombie_door", "targetname" );

    for ( i = 0; i < zombie_doors.size; i++ )
    {
        zombie_doors[i] notify( "trigger", players[0] );

        if ( is_true( zombie_doors[i].power_door_ignore_flag_wait ) )
            zombie_doors[i] notify( "power_on" );

        wait 0.05;
    }

    zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );

    for ( i = 0; i < zombie_airlock_doors.size; i++ )
    {
        zombie_airlock_doors[i] notify( "trigger", players[0] );
        wait 0.05;
    }

    zombie_debris = getentarray( "zombie_debris", "targetname" );

    for ( i = 0; i < zombie_debris.size; i++ )
    {
        zombie_debris[i] notify( "trigger", players[0] );
        wait 0.05;
    }

    zombie_devgui_build( undefined );
    level notify( "open_sesame" );
    wait 1;
    setdvar( "zombie_unlock_all", 0 );
#/
}

any_player_in_noclip()
{
/#
    foreach ( player in get_players() )
    {
        if ( player isinmovemode( "ufo", "noclip" ) )
            return true;
    }

    return false;
#/
}

diable_fog_in_noclip()
{
/#
    level.fog_disabled_in_noclip = 1;
    level endon( "allowfoginnoclip" );
    flag_wait( "start_zombie_round_logic" );

    while ( true )
    {
        while ( !any_player_in_noclip() )
            wait 1;

        setdvar( "scr_fog_disable", "1" );
        setdvar( "r_fog_disable", "1" );

        if ( isdefined( level.culldist ) )
            setculldist( 0 );

        while ( any_player_in_noclip() )
            wait 1;

        setdvar( "scr_fog_disable", "0" );
        setdvar( "r_fog_disable", "0" );

        if ( isdefined( level.culldist ) )
            setculldist( level.culldist );
    }
#/
}

zombie_devgui_allow_fog()
{
/#
    if ( level.fog_disabled_in_noclip )
    {
        level notify( "allowfoginnoclip" );
        level.fog_disabled_in_noclip = 0;
        setdvar( "scr_fog_disable", "0" );
        setdvar( "r_fog_disable", "0" );
    }
    else
        thread diable_fog_in_noclip();
#/
}

zombie_devgui_give_money()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;
    self maps\mp\zombies\_zm_score::add_to_player_score( 100000 );
#/
}

zombie_devgui_take_money()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );

    if ( self.score > 100 )
        self maps\mp\zombies\_zm_score::minus_to_player_score( int( self.score / 2 ) );
    else
        self maps\mp\zombies\_zm_score::minus_to_player_score( self.score );
#/
}

zombie_devgui_turn_player( index )
{
/#
    players = get_players();

    if ( !isdefined( index ) || index >= players.size )
        player = players[0];
    else
        player = players[index];

    assert( isdefined( player ) );
    assert( isplayer( player ) );
    assert( isalive( player ) );
    level.devcheater = 1;

    if ( player hasperk( "specialty_noname" ) )
    {
        println( "Player turned HUMAN" );
        player maps\mp\zombies\_zm_turned::turn_to_human();
    }
    else
    {
        println( "Player turned ZOMBIE" );
        player maps\mp\zombies\_zm_turned::turn_to_zombie();
    }
#/
}

zombie_devgui_debug_pers( index )
{
/#
    players = get_players();

    if ( !isdefined( index ) || index >= players.size )
        player = players[0];
    else
        player = players[index];

    assert( isdefined( player ) );
    assert( isplayer( player ) );
    assert( isalive( player ) );
    level.devcheater = 1;
    println( "\n\n----------------------------------------------------------------------------------------------" );
    println( "Active Persistent upgrades [count=" + level.pers_upgrades_keys.size + "]" );

    for ( pers_upgrade_index = 0; pers_upgrade_index < level.pers_upgrades_keys.size; pers_upgrade_index++ )
    {
        name = level.pers_upgrades_keys[pers_upgrade_index];
        println( pers_upgrade_index + ">pers_upgrade name = " + name );
        pers_upgrade = level.pers_upgrades[name];

        for ( i = 0; i < pers_upgrade.stat_names.size; i++ )
        {
            stat_name = pers_upgrade.stat_names[i];
            stat_desired_value = pers_upgrade.stat_desired_values[i];
            player_current_stat_value = player maps\mp\zombies\_zm_stats::get_global_stat( stat_name );
            println( "  " + i + ")stat_name = " + stat_name );
            println( "  " + i + ")stat_desired_values = " + stat_desired_value );
            println( "  " + i + ")player_current_stat_value = " + player_current_stat_value );
        }

        if ( is_true( player.pers_upgrades_awarded[name] ) )
        {
            println( "PLAYER HAS - " + name );
            continue;
        }

        println( "PLAYER DOES NOT HAVE - " + name );
    }

    println( "----------------------------------------------------------------------------------------------\n\n" );
#/
}

zombie_devgui_cool_jetgun()
{
/#
    if ( isdefined( level.zm_devgui_jetgun_never_overheat ) )
        self thread [[ level.zm_devgui_jetgun_never_overheat ]]();
#/
}

zombie_devgui_preserve_turbines()
{
/#
    self endon( "disconnect" );
    self notify( "preserve_turbines" );
    self endon( "preserve_turbines" );

    if ( !is_true( self.preserving_turbines ) )
    {
        self.preserving_turbines = 1;

        while ( true )
        {
            self.turbine_health = 1200;
            wait 1;
        }
    }

    self.preserving_turbines = 0;
#/
}

zombie_devgui_equipment_stays_healthy()
{
/#
    self endon( "disconnect" );
    self notify( "preserve_equipment" );
    self endon( "preserve_equipment" );

    if ( !is_true( self.preserving_equipment ) )
    {
        self.preserving_equipment = 1;

        while ( true )
        {
            self.equipment_damage = [];
            self.shielddamagetaken = 0;

            if ( isdefined( level.destructible_equipment ) )
            {
                foreach ( equip in level.destructible_equipment )
                {
                    if ( isdefined( equip ) )
                    {
                        equip.shielddamagetaken = 0;
                        equip.damage = 0;
                        equip.headchopper_kills = 0;
                        equip.springpad_kills = 0;
                        equip.subwoofer_kills = 0;
                    }
                }
            }

            wait 0.1;
        }
    }

    self.preserving_equipment = 0;
#/
}

zombie_devgui_disown_equipment()
{
/#
    self.deployed_equipment = [];
#/
}

zombie_devgui_equipment_give( equipment )
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( is_equipment_included( equipment ) )
        self maps\mp\zombies\_zm_equipment::equipment_buy( equipment );
#/
}

zombie_devgui_buildable_drop()
{
/#
    if ( isdefined( level.buildable_slot_count ) )
    {
        for ( i = 0; i < level.buildable_slot_count; i++ )
            self maps\mp\zombies\_zm_buildables::player_drop_piece( undefined, i );
    }
    else
        self maps\mp\zombies\_zm_buildables::player_drop_piece();
#/
}

zombie_devgui_build( buildable )
{
/#
    player = get_players()[0];

    for ( i = 0; i < level.buildable_stubs.size; i++ )
    {
        if ( !isdefined( buildable ) || level.buildable_stubs[i].equipname == buildable )
        {
            if ( !isdefined( buildable ) && is_true( level.buildable_stubs[i].ignore_open_sesame ) )
                continue;

            if ( isdefined( buildable ) || level.buildable_stubs[i].persistent != 3 )
                level.buildable_stubs[i] maps\mp\zombies\_zm_buildables::buildablestub_finish_build( player );
        }
    }
#/
}

zombie_devgui_give_claymores()
{
/#
    self endon( "disconnect" );
    self notify( "give_planted_grenade_thread" );
    self endon( "give_planted_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_placeable_mine() ) )
        self takeweapon( self get_player_placeable_mine() );

    self thread maps\mp\zombies\_zm_weap_claymore::claymore_setup();

    while ( true )
    {
        self givemaxammo( "claymore_zm" );
        wait 1;
    }
#/
}

zombie_devgui_give_lethal( weapon )
{
/#
    self endon( "disconnect" );
    self notify( "give_lethal_grenade_thread" );
    self endon( "give_lethal_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_lethal_grenade() ) )
        self takeweapon( self get_player_lethal_grenade() );

    self giveweapon( weapon );
    self set_player_lethal_grenade( weapon );

    while ( true )
    {
        self givemaxammo( weapon );
        wait 1;
    }
#/
}

zombie_devgui_give_frags()
{
/#
    zombie_devgui_give_lethal( "frag_grenade_zm" );
#/
}

zombie_devgui_give_sticky()
{
/#
    zombie_devgui_give_lethal( "sticky_grenade_zm" );
#/
}

zombie_devgui_give_monkey()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_devgui_cymbal_monkey_give ) )
    {
        self [[ level.zombiemode_devgui_cymbal_monkey_give ]]();

        while ( true )
        {
            self givemaxammo( "cymbal_monkey_zm" );
            wait 1;
        }
    }
#/
}

zombie_devgui_give_beacon()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_devgui_beacon_give ) )
    {
        self [[ level.zombiemode_devgui_beacon_give ]]();

        while ( true )
        {
            self givemaxammo( "beacon_zm" );
            wait 1;
        }
    }
#/
}

zombie_devgui_give_time_bomb()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_time_bomb_give_func ) )
        self [[ level.zombiemode_time_bomb_give_func ]]();
#/
}

zombie_devgui_give_black_hole_bomb()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_devgui_black_hole_bomb_give ) )
    {
        self [[ level.zombiemode_devgui_black_hole_bomb_give ]]();

        while ( true )
        {
            self givemaxammo( "zombie_black_hole_bomb" );
            wait 1;
        }
    }
#/
}

zombie_devgui_give_dolls()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_devgui_nesting_dolls_give ) )
    {
        self [[ level.zombiemode_devgui_nesting_dolls_give ]]();

        while ( true )
        {
            self givemaxammo( "zombie_nesting_dolls" );
            wait 1;
        }
    }
#/
}

zombie_devgui_give_quantum_bomb()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_devgui_quantum_bomb_give ) )
    {
        self [[ level.zombiemode_devgui_quantum_bomb_give ]]();

        while ( true )
        {
            self givemaxammo( "zombie_quantum_bomb" );
            wait 1;
        }
    }
#/
}

zombie_devgui_give_emp_bomb()
{
/#
    self endon( "disconnect" );
    self notify( "give_tactical_grenade_thread" );
    self endon( "give_tactical_grenade_thread" );
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    level.devcheater = 1;

    if ( isdefined( self get_player_tactical_grenade() ) )
        self takeweapon( self get_player_tactical_grenade() );

    if ( isdefined( level.zombiemode_devgui_emp_bomb_give ) )
    {
        self [[ level.zombiemode_devgui_emp_bomb_give ]]();

        while ( true )
        {
            self givemaxammo( "emp_grenade_zm" );
            wait 1;
        }
    }
#/
}

zombie_devgui_invulnerable( playerindex, onoff )
{
/#
    players = get_players();

    if ( !isdefined( playerindex ) )
    {
        for ( i = 0; i < players.size; i++ )
            zombie_devgui_invulnerable( i, onoff );
    }
    else if ( players.size > playerindex )
    {
        if ( onoff )
            players[playerindex] enableinvulnerability();
        else
            players[playerindex] disableinvulnerability();
    }
#/
}

zombie_devgui_kill()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    self disableinvulnerability();
    death_from = ( randomfloatrange( -20, 20 ), randomfloatrange( -20, 20 ), randomfloatrange( -20, 20 ) );
    self dodamage( self.health + 666, self.origin + death_from );
#/
}

zombie_devgui_toggle_ammo()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    self notify( "devgui_toggle_ammo" );
    self endon( "devgui_toggle_ammo" );
    self.ammo4evah = !is_true( self.ammo4evah );

    while ( isdefined( self ) && self.ammo4evah )
    {
        weapon = self getcurrentweapon();

        if ( weapon != "none" )
        {
            self setweaponoverheating( 0, 0 );
            max = weaponmaxammo( weapon );

            if ( isdefined( max ) )
                self setweaponammostock( weapon, max );

            if ( isdefined( self get_player_tactical_grenade() ) )
                self givemaxammo( self get_player_tactical_grenade() );

            if ( isdefined( self get_player_lethal_grenade() ) )
                self givemaxammo( self get_player_lethal_grenade() );
        }

        wait 1;
    }
#/
}

zombie_devgui_toggle_ignore()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    self.ignoreme = !self.ignoreme;

    if ( self.ignoreme )
        setdvar( "ai_showFailedPaths", 0 );
#/
}

zombie_devgui_revive()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    self reviveplayer();
    self notify( "stop_revive_trigger" );

    if ( isdefined( self.revivetrigger ) )
    {
        self.revivetrigger delete();
        self.revivetrigger = undefined;
    }

    self allowjump( 1 );
    self.ignoreme = 0;
    self.laststand = undefined;
    self notify( "player_revived", self );
#/
}

zombie_devgui_give_health()
{
/#
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    assert( isalive( self ) );
    self notify( "devgui_health" );
    self endon( "devgui_health" );
    self endon( "disconnect" );
    self endon( "death" );
    level.devcheater = 1;

    while ( true )
    {
        self.maxhealth = 100000;
        self.health = 100000;
        self waittill_any( "player_revived", "perk_used", "spawned_player" );
        wait 2;
    }
#/
}

zombie_devgui_give_perk( perk )
{
/#
    vending_triggers = getentarray( "zombie_vending", "targetname" );
    player = get_players()[0];
    level.devcheater = 1;

    if ( vending_triggers.size < 1 )
        return;

    for ( i = 0; i < vending_triggers.size; i++ )
    {
        if ( vending_triggers[i].script_noteworthy == perk )
        {
            vending_triggers[i] notify( "trigger", player );
            return;
        }
    }
#/
}

zombie_devgui_give_powerup( powerup_name, now, origin )
{
/#
    player = get_players()[0];
    found = 0;
    level.devcheater = 1;

    for ( i = 0; i < level.zombie_powerup_array.size; i++ )
    {
        if ( level.zombie_powerup_array[i] == powerup_name )
        {
            level.zombie_powerup_index = i;
            found = 1;
            break;
        }
    }

    if ( !found )
        return;

    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    level.zombie_devgui_power = 1;
    level.zombie_vars["zombie_drop_item"] = 1;
    level.powerup_drop_count = 0;

    if ( isdefined( origin ) )
        level thread maps\mp\zombies\_zm_powerups::powerup_drop( origin );
    else if ( !isdefined( now ) || now )
        level thread maps\mp\zombies\_zm_powerups::powerup_drop( trace["position"] );
#/
}

zombie_devgui_goto_round( target_round )
{
/#
    player = get_players()[0];

    if ( target_round < 1 )
        target_round = 1;

    level.devcheater = 1;
    level.zombie_total = 0;
    maps\mp\zombies\_zm::ai_calculate_health( target_round );
    level.round_number = target_round - 1;
    level notify( "kill_round" );
    wait 1;
    zombies = get_round_enemy_array();

    if ( isdefined( zombies ) )
    {
        for ( i = 0; i < zombies.size; i++ )
        {
            if ( is_true( zombies[i].ignore_devgui_death ) )
                continue;

            zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
        }
    }
#/
}

zombie_devgui_monkey_round()
{
/#
    if ( isdefined( level.next_monkey_round ) )
        zombie_devgui_goto_round( level.next_monkey_round );
#/
}

zombie_devgui_thief_round()
{
/#
    if ( isdefined( level.next_thief_round ) )
        zombie_devgui_goto_round( level.next_thief_round );
#/
}

zombie_devgui_dog_round( num_dogs )
{
/#
    if ( !isdefined( level.dogs_enabled ) || !level.dogs_enabled )
        return;

    if ( !isdefined( level.dog_rounds_enabled ) || !level.dog_rounds_enabled )
        return;

    if ( !isdefined( level.enemy_dog_spawns ) || level.enemy_dog_spawns.size < 1 )
        return;

    if ( !flag( "dog_round" ) )
        setdvar( "force_dogs", num_dogs );
    else
    {

    }

    zombie_devgui_goto_round( level.round_number + 1 );
#/
}

zombie_devgui_dog_round_skip()
{
/#
    if ( isdefined( level.next_dog_round ) )
        zombie_devgui_goto_round( level.next_dog_round );
#/
}

zombie_devgui_dump_zombie_vars()
{
/#
    if ( !isdefined( level.zombie_vars ) )
        return;

    if ( level.zombie_vars.size > 0 )
        println( "#### Zombie Variables ####" );
    else
        return;

    var_names = getarraykeys( level.zombie_vars );

    for ( i = 0; i < level.zombie_vars.size; i++ )
    {
        key = var_names[i];
        println( key + ":     " + level.zombie_vars[key] );
    }

    println( "##### End Zombie Variables #####" );
#/
}

zombie_devgui_pack_current_weapon()
{
/#
    players = get_players();
    reviver = players[0];
    level.devcheater = 1;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            weap = maps\mp\zombies\_zm_weapons::get_base_name( players[i] getcurrentweapon() );
            weapon = get_upgrade( weap );

            if ( isdefined( weapon ) )
            {
                players[i] takeweapon( weap );
                players[i] giveweapon( weapon, 0, players[i] maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
                players[i] givestartammo( weapon );
                players[i] switchtoweapon( weapon );
            }
        }
    }
#/
}

zombie_devgui_unpack_current_weapon()
{
/#
    players = get_players();
    reviver = players[0];
    level.devcheater = 1;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            weap = players[i] getcurrentweapon();
            weapon = maps\mp\zombies\_zm_weapons::get_base_weapon_name( weap, 1 );

            if ( isdefined( weapon ) )
            {
                players[i] takeweapon( weap );
                players[i] giveweapon( weapon, 0, players[i] maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
                players[i] givestartammo( weapon );
                players[i] switchtoweapon( weapon );
            }
        }
    }
#/
}

zombie_devgui_reopt_current_weapon()
{
/#
    players = get_players();
    reviver = players[0];
    level.devcheater = 1;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            weap = players[i] getcurrentweapon();
            weapon = weap;

            if ( isdefined( weapon ) )
            {
                if ( isdefined( players[i].pack_a_punch_weapon_options ) )
                    players[i].pack_a_punch_weapon_options[weapon] = undefined;

                players[i] takeweapon( weap );
                players[i] giveweapon( weapon, 0, players[i] maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
                players[i] givestartammo( weapon );
                players[i] switchtoweapon( weapon );
            }
        }
    }
#/
}

zombie_devgui_take_weapon()
{
/#
    players = get_players();
    reviver = players[0];
    level.devcheater = 1;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            weap = players[i] getcurrentweapon();
            weapon = weap;

            if ( isdefined( weapon ) )
            {
                players[i] takeweapon( weap );
                players[i] switch_back_primary_weapon( undefined );
            }
        }
    }
#/
}

zombie_devgui_take_weapons( give_fallback )
{
/#
    players = get_players();
    reviver = players[0];
    level.devcheater = 1;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            players[i] takeallweapons();

            if ( give_fallback )
                players[i] give_fallback_weapon();
        }
    }
#/
}

get_upgrade( weaponname )
{
/#
    if ( isdefined( level.zombie_weapons[weaponname] ) && isdefined( level.zombie_weapons[weaponname].upgrade_name ) )
        return maps\mp\zombies\_zm_weapons::get_upgrade_weapon( weaponname, 0 );
    else
        return maps\mp\zombies\_zm_weapons::get_upgrade_weapon( weaponname, 1 );
#/
}

zombie_devgui_director_easy()
{
/#
    if ( isdefined( level.director_devgui_health ) )
        [[ level.director_devgui_health ]]();
#/
}

zombie_devgui_chest_never_move()
{
/#
    level notify( "devgui_chest_end_monitor" );
    level endon( "devgui_chest_end_monitor" );

    for (;;)
    {
        level.chest_accessed = 0;
        wait 5;
    }
#/
}

zombie_devgui_disable_kill_thread_toggle()
{
/#
    if ( !is_true( level.disable_kill_thread ) )
        level.disable_kill_thread = 1;
    else
        level.disable_kill_thread = 0;
#/
}

zombie_devgui_check_kill_thread_every_frame_toggle()
{
/#
    if ( !is_true( level.check_kill_thread_every_frame ) )
        level.check_kill_thread_every_frame = 1;
    else
        level.check_kill_thread_every_frame = 0;
#/
}

zombie_devgui_kill_thread_test_mode_toggle()
{
/#
    if ( !is_true( level.kill_thread_test_mode ) )
        level.kill_thread_test_mode = 1;
    else
        level.kill_thread_test_mode = 0;
#/
}

showonespawnpoint( spawn_point, color, notification, height, print )
{
/#
    if ( !isdefined( height ) || height <= 0 )
        height = get_player_height();

    if ( !isdefined( print ) )
        print = spawn_point.classname;

    center = spawn_point.origin;
    forward = anglestoforward( spawn_point.angles );
    right = anglestoright( spawn_point.angles );
    forward = vectorscale( forward, 16 );
    right = vectorscale( right, 16 );
    a = center + forward - right;
    b = center + forward + right;
    c = center - forward + right;
    d = center - forward - right;
    thread lineuntilnotified( a, b, color, 0, notification );
    thread lineuntilnotified( b, c, color, 0, notification );
    thread lineuntilnotified( c, d, color, 0, notification );
    thread lineuntilnotified( d, a, color, 0, notification );
    thread lineuntilnotified( a, a + ( 0, 0, height ), color, 0, notification );
    thread lineuntilnotified( b, b + ( 0, 0, height ), color, 0, notification );
    thread lineuntilnotified( c, c + ( 0, 0, height ), color, 0, notification );
    thread lineuntilnotified( d, d + ( 0, 0, height ), color, 0, notification );
    a += ( 0, 0, height );
    b += ( 0, 0, height );
    c += ( 0, 0, height );
    d += ( 0, 0, height );
    thread lineuntilnotified( a, b, color, 0, notification );
    thread lineuntilnotified( b, c, color, 0, notification );
    thread lineuntilnotified( c, d, color, 0, notification );
    thread lineuntilnotified( d, a, color, 0, notification );
    center += ( 0, 0, height / 2 );
    arrow_forward = anglestoforward( spawn_point.angles );
    arrowhead_forward = anglestoforward( spawn_point.angles );
    arrowhead_right = anglestoright( spawn_point.angles );
    arrow_forward = vectorscale( arrow_forward, 32 );
    arrowhead_forward = vectorscale( arrowhead_forward, 24 );
    arrowhead_right = vectorscale( arrowhead_right, 8 );
    a = center + arrow_forward;
    b = center + arrowhead_forward - arrowhead_right;
    c = center + arrowhead_forward + arrowhead_right;
    thread lineuntilnotified( center, a, color, 0, notification );
    thread lineuntilnotified( a, b, color, 0, notification );
    thread lineuntilnotified( a, c, color, 0, notification );
    thread print3duntilnotified( spawn_point.origin + ( 0, 0, height ), print, color, 1, 1, notification );
    return;
#/
}

print3duntilnotified( origin, text, color, alpha, scale, notification )
{
/#
    level endon( notification );

    for (;;)
    {
        print3d( origin, text, color, alpha, scale );
        wait 0.05;
    }
#/
}

lineuntilnotified( start, end, color, depthtest, notification )
{
/#
    level endon( notification );

    for (;;)
    {
        line( start, end, color, depthtest );
        wait 0.05;
    }
#/
}

devgui_debug_hud()
{
/#
    if ( isdefined( self get_player_lethal_grenade() ) )
        self givemaxammo( self get_player_lethal_grenade() );

    self thread maps\mp\zombies\_zm_weap_claymore::claymore_setup();

    if ( isdefined( level.zombiemode_time_bomb_give_func ) )
    {
        if ( isdefined( self get_player_tactical_grenade() ) )
            self takeweapon( self get_player_tactical_grenade() );

        self [[ level.zombiemode_time_bomb_give_func ]]();
    }
    else if ( isdefined( level.zombiemode_devgui_cymbal_monkey_give ) )
    {
        if ( isdefined( self get_player_tactical_grenade() ) )
            self takeweapon( self get_player_tactical_grenade() );

        self [[ level.zombiemode_devgui_cymbal_monkey_give ]]();
    }
    else if ( isdefined( self get_player_tactical_grenade() ) )
        self givemaxammo( self get_player_tactical_grenade() );

    if ( isdefined( level.zombie_include_equipment ) && !isdefined( self get_player_equipment() ) )
    {
        equipment = getarraykeys( level.zombie_include_equipment );

        if ( isdefined( equipment[0] ) )
            self zombie_devgui_equipment_give( equipment[0] );
    }

    candidate_list = [];

    foreach ( zone in level.zones )
    {
        if ( isdefined( zone.unitrigger_stubs ) )
            candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
    }

    foreach ( stub in candidate_list )
    {
        if ( isdefined( stub.piece ) && isdefined( stub.piece.buildable_slot ) )
        {
            if ( !isdefined( self player_get_buildable_piece( stub.piece.buildable_slot ) ) )
                self thread maps\mp\zombies\_zm_buildables::player_take_piece( stub.piece );
        }
    }

    for ( i = 0; i < 10; i++ )
    {
        zombie_devgui_give_powerup( "free_perk", 1, self.origin );
        wait 0.25;
    }

    zombie_devgui_give_powerup( "insta_kill", 1, self.origin );
    wait 0.25;
    zombie_devgui_give_powerup( "double_points", 1, self.origin );
    wait 0.25;
    zombie_devgui_give_powerup( "fire_sale", 1, self.origin );
    wait 0.25;
    zombie_devgui_give_powerup( "minigun", 1, self.origin );
    wait 0.25;
    zombie_devgui_give_powerup( "bonfire_sale", 1, self.origin );
    wait 0.25;
    self weapon_give( "tar21_upgraded_zm+gl" );
#/
}
