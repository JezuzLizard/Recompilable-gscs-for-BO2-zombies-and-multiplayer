// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zm_tomb_main_quest;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_powerup_zombie_blood;

init_shovel()
{
    precachemodel( "p6_zm_tm_dig_mound" );
    precachemodel( "p6_zm_tm_dig_mound_blood" );
    precachemodel( "p6_zm_tm_shovel" );
    precachemodel( "zombie_pickup_perk_bottle" );
    precachemodel( "t6_wpn_claymore_world" );
    maps\mp\zombies\_zm_audio_announcer::createvox( "blood_money", "powerup_blood_money" );
    onplayerconnect_callback( ::init_shovel_player );
    a_shovel_pos = getstructarray( "shovel_location", "targetname" );
    a_shovel_zone = [];

    foreach ( s_shovel_pos in a_shovel_pos )
    {
        if ( !isdefined( a_shovel_zone[s_shovel_pos.script_noteworthy] ) )
            a_shovel_zone[s_shovel_pos.script_noteworthy] = [];

        a_shovel_zone[s_shovel_pos.script_noteworthy][a_shovel_zone[s_shovel_pos.script_noteworthy].size] = s_shovel_pos;
    }

    foreach ( a_zone in a_shovel_zone )
    {
        s_pos = a_zone[randomint( a_zone.size )];
        m_shovel = spawn( "script_model", s_pos.origin );
        m_shovel.angles = s_pos.angles;
        m_shovel setmodel( "p6_zm_tm_shovel" );
        generate_shovel_unitrigger( m_shovel );
    }

    level.get_player_perk_purchase_limit = ::get_player_perk_purchase_limit;
    level.bonus_points_powerup_override = ::bonus_points_powerup_override;
    level thread dig_powerups_tracking();
    level thread dig_spots_init();
    registerclientfield( "world", "shovel_player1", 14000, 2, "int", undefined, 0 );
    registerclientfield( "world", "shovel_player2", 14000, 2, "int", undefined, 0 );
    registerclientfield( "world", "shovel_player3", 14000, 2, "int", undefined, 0 );
    registerclientfield( "world", "shovel_player4", 14000, 2, "int", undefined, 0 );
    registerclientfield( "world", "helmet_player1", 14000, 1, "int", undefined, 0 );
    registerclientfield( "world", "helmet_player2", 14000, 1, "int", undefined, 0 );
    registerclientfield( "world", "helmet_player3", 14000, 1, "int", undefined, 0 );
    registerclientfield( "world", "helmet_player4", 14000, 1, "int", undefined, 0 );
/#
    level thread setup_dig_devgui();
#/
}

init_shovel_player()
{
    self.dig_vars["has_shovel"] = 0;
    self.dig_vars["has_upgraded_shovel"] = 0;
    self.dig_vars["has_helmet"] = 0;
    self.dig_vars["n_spots_dug"] = 0;
    self.dig_vars["n_losing_streak"] = 0;
}

generate_shovel_unitrigger( e_shovel )
{
    s_unitrigger_stub = spawnstruct();
    s_unitrigger_stub.origin = e_shovel.origin + vectorscale( ( 0, 0, 1 ), 32.0 );
    s_unitrigger_stub.angles = e_shovel.angles;
    s_unitrigger_stub.radius = 32;
    s_unitrigger_stub.script_length = 64;
    s_unitrigger_stub.script_width = 64;
    s_unitrigger_stub.script_height = 64;
    s_unitrigger_stub.cursor_hint = "HINT_NOICON";
    s_unitrigger_stub.hint_string = &"ZM_TOMB_SHPU";
    s_unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
    s_unitrigger_stub.require_look_at = 1;
    s_unitrigger_stub.prompt_and_visibility_func = ::shovel_trigger_prompt_and_visiblity;
    s_unitrigger_stub.e_shovel = e_shovel;
    unitrigger_force_per_player_triggers( s_unitrigger_stub, 1 );
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( s_unitrigger_stub, ::shovel_unitrigger_think );
}

shovel_trigger_prompt_and_visiblity( e_player )
{
    can_use = self.stub shovel_prompt_update( e_player );
    self setinvisibletoplayer( e_player, !can_use );
    self sethintstring( self.stub.hint_string );
    return can_use;
}

shovel_prompt_update( e_player )
{
    if ( !self unitrigger_stub_show_hint_prompt_valid( e_player ) )
        return false;

    self.hint_string = &"ZM_TOMB_SHPU";

    if ( isdefined( e_player.dig_vars["has_shovel"] ) && e_player.dig_vars["has_shovel"] )
        self.hint_string = &"ZM_TOMB_SHAG";

    return true;
}

shovel_unitrigger_think()
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger", e_player );

        if ( e_player != self.parent_player )
            continue;

        if ( !( isdefined( e_player.dig_vars["has_shovel"] ) && e_player.dig_vars["has_shovel"] ) )
        {
            e_player.dig_vars["has_shovel"] = 1;
            e_player playsound( "zmb_craftable_pickup" );
            e_player dig_reward_dialog( "pickup_shovel" );
            n_player = e_player getentitynumber() + 1;
            level setclientfield( "shovel_player" + n_player, 1 );
            e_player thread dig_disconnect_watch( n_player, self.stub.e_shovel.origin, self.stub.e_shovel.angles );
            self.stub.e_shovel delete();
            maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
        }
    }
}

dig_reward_dialog( str_category )
{
    if ( !( isdefined( self.dig_vo_cooldown ) && self.dig_vo_cooldown ) )
    {
        self do_player_general_vox( "digging", str_category );

        if ( str_category != "pickup_shovel" )
            self thread dig_reward_vo_cooldown();
    }
}

dig_reward_vo_cooldown()
{
    self endon( "disconnect" );
    self.dig_vo_cooldown = 1;
    wait 60;
    self.dig_vo_cooldown = undefined;
}

unitrigger_stub_show_hint_prompt_valid( e_player )
{
    if ( !is_player_valid( e_player ) )
    {
        self.hint_string = "";
        return false;
    }

    return true;
}

dig_disconnect_watch( n_player, v_origin, v_angles )
{
    self waittill( "disconnect" );

    level setclientfield( "shovel_player" + n_player, 0 );
    level setclientfield( "helmet_player" + n_player, 0 );
    m_shovel = spawn( "script_model", v_origin );
    m_shovel.angles = v_angles;
    m_shovel setmodel( "p6_zm_tm_shovel" );
    generate_shovel_unitrigger( m_shovel );
}

dig_spots_init()
{
    flag_wait( "start_zombie_round_logic" );
    level.n_dig_spots_cur = 0;
    level.n_dig_spots_max = 15;
    level.a_dig_spots = getstructarray( "dig_spot", "targetname" );

    foreach ( s_dig_spot in level.a_dig_spots )
    {
        if ( !isdefined( s_dig_spot.angles ) )
            s_dig_spot.angles = ( 0, 0, 0 );

        if ( isdefined( s_dig_spot.script_noteworthy ) && s_dig_spot.script_noteworthy == "initial_spot" )
            s_dig_spot thread dig_spot_spawn();
        else
            s_dig_spot.dug = 1;

        s_dig_spot.str_zone = maps\mp\zombies\_zm_zonemgr::get_zone_from_position( s_dig_spot.origin + vectorscale( ( 0, 0, 1 ), 32.0 ), 1 );

        if ( !isdefined( s_dig_spot.str_zone ) )
        {
            s_dig_spot.str_zone = "";
/#
            assertmsg( "Dig spot at ( " + s_dig_spot.origin[0] + ", " + s_dig_spot.origin[1] + ", " + s_dig_spot.origin[2] + ") is not in a zone." );
#/
        }

        wait_network_frame();
    }

    level thread dig_spots_respawn();
}

dig_spots_respawn( a_dig_spots )
{
    while ( true )
    {
        level waittill( "end_of_round" );

        wait 2;
        a_dig_spots = array_randomize( level.a_dig_spots );
        n_respawned = 0;
        n_respawned_max = 3;

        if ( level.weather_snow > 0 )
            n_respawned_max = 0;
        else if ( level.weather_rain > 0 )
            n_respawned_max = 5;

        if ( level.weather_snow == 0 )
            n_respawned_max += randomint( get_players().size );

        for ( i = 0; i < a_dig_spots.size; i++ )
        {
            if ( isdefined( a_dig_spots[i].dug ) && a_dig_spots[i].dug && n_respawned < n_respawned_max && level.n_dig_spots_cur <= level.n_dig_spots_max )
            {
                a_dig_spots[i].dug = undefined;
                a_dig_spots[i] thread dig_spot_spawn();
                wait_network_frame();
                n_respawned++;
            }
        }

        if ( level.weather_snow > 0 && level.ice_staff_pieces.size > 0 )
        {
            foreach ( s_staff in level.ice_staff_pieces )
            {
                a_staff_spots = [];
                n_active_mounds = 0;

                foreach ( s_dig_spot in level.a_dig_spots )
                {
                    if ( isdefined( s_dig_spot.str_zone ) && issubstr( s_dig_spot.str_zone, s_staff.zone_substr ) )
                    {
                        if ( !( isdefined( s_dig_spot.dug ) && s_dig_spot.dug ) )
                        {
                            n_active_mounds++;
                            continue;
                        }

                        a_staff_spots[a_staff_spots.size] = s_dig_spot;
                    }
                }

                if ( n_active_mounds < 2 && a_staff_spots.size > 0 && level.n_dig_spots_cur <= level.n_dig_spots_max )
                {
                    n_index = randomint( a_staff_spots.size );
                    a_staff_spots[n_index].dug = undefined;
                    a_staff_spots[n_index] thread dig_spot_spawn();
                    arrayremoveindex( a_staff_spots, n_index );
                    n_active_mounds++;
                    wait_network_frame();
                }
            }
        }
    }
}

dig_spot_spawn()
{
    level.n_dig_spots_cur++;
    self.m_dig = spawn( "script_model", self.origin + vectorscale( ( 0, 0, -1 ), 40.0 ) );
    self.m_dig setmodel( "p6_zm_tm_dig_mound" );
    self.m_dig.angles = self.angles;
    self.m_dig moveto( self.origin, 3, 0, 1 );

    self.m_dig waittill( "movedone" );

    t_dig = tomb_spawn_trigger_radius( self.origin + vectorscale( ( 0, 0, 1 ), 20.0 ), 100, 1 );
    t_dig.prompt_and_visibility_func = ::dig_spot_trigger_visibility;
    t_dig.require_look_at = 1;
    t_dig waittill_dug( self );
    t_dig tomb_unitrigger_delete();
    t_dig = undefined;
    self.m_dig delete();
    self.m_dig = undefined;
}

dig_spot_trigger_visibility( player )
{
    if ( isdefined( player.dig_vars["has_shovel"] ) && player.dig_vars["has_shovel"] )
        self sethintstring( &"ZM_TOMB_X2D" );
    else
        self sethintstring( &"ZM_TOMB_NS" );

    return 1;
}

waittill_dug( s_dig_spot )
{
    while ( true )
    {
        self waittill( "trigger", player );

        if ( isdefined( player.dig_vars["has_shovel"] ) && player.dig_vars["has_shovel"] )
        {
            player playsound( "evt_dig" );
            s_dig_spot.dug = 1;
            level.n_dig_spots_cur--;
            playfx( level._effect["digging"], self.origin );
            player setclientfieldtoplayer( "player_rumble_and_shake", 1 );
            player maps\mp\zombies\_zm_stats::increment_client_stat( "tomb_dig", 0 );
            player maps\mp\zombies\_zm_stats::increment_player_stat( "tomb_dig" );
            s_staff_piece = s_dig_spot maps\mp\zm_tomb_main_quest::dig_spot_get_staff_piece( player );

            if ( isdefined( s_staff_piece ) )
            {
                s_staff_piece maps\mp\zm_tomb_main_quest::show_ice_staff_piece( self.origin );
                player dig_reward_dialog( "dig_staff_part" );
            }
            else
            {
                n_good_chance = 50;

                if ( player.dig_vars["n_spots_dug"] == 0 || player.dig_vars["n_losing_streak"] == 3 )
                {
                    player.dig_vars["n_losing_streak"] = 0;
                    n_good_chance = 100;
                }

                if ( player.dig_vars["has_upgraded_shovel"] )
                {
                    if ( !player.dig_vars["has_helmet"] )
                    {
                        n_helmet_roll = randomint( 100 );

                        if ( n_helmet_roll >= 95 )
                        {
                            player.dig_vars["has_helmet"] = 1;
                            n_player = player getentitynumber() + 1;
                            level setclientfield( "helmet_player" + n_player, 1 );
                            player playsoundtoplayer( "zmb_squest_golden_anything", player );
                            player maps\mp\zombies\_zm_stats::increment_client_stat( "tomb_golden_hard_hat", 0 );
                            player maps\mp\zombies\_zm_stats::increment_player_stat( "tomb_golden_hard_hat" );
                            return;
                        }
                    }

                    n_good_chance = 70;
                }

                n_prize_roll = randomint( 100 );

                if ( n_prize_roll > n_good_chance )
                {
                    if ( cointoss() )
                    {
                        player dig_reward_dialog( "dig_grenade" );
                        self thread dig_up_grenade( player );
                    }
                    else
                    {
                        player dig_reward_dialog( "dig_zombie" );
                        self thread dig_up_zombie( player, s_dig_spot );
                    }

                    player.dig_vars["n_losing_streak"]++;
                }
                else if ( cointoss() )
                    self thread dig_up_powerup( player );
                else
                {
                    player dig_reward_dialog( "dig_gun" );
                    self thread dig_up_weapon( player );
                }
            }

            if ( !player.dig_vars["has_upgraded_shovel"] )
            {
                player.dig_vars["n_spots_dug"]++;

                if ( player.dig_vars["n_spots_dug"] >= 30 )
                {
                    player.dig_vars["has_upgraded_shovel"] = 1;
                    player thread ee_zombie_blood_dig();
                    n_player = player getentitynumber() + 1;
                    level setclientfield( "shovel_player" + n_player, 2 );
                    player playsoundtoplayer( "zmb_squest_golden_anything", player );
                    player maps\mp\zombies\_zm_stats::increment_client_stat( "tomb_golden_shovel", 0 );
                    player maps\mp\zombies\_zm_stats::increment_player_stat( "tomb_golden_shovel" );
                }
            }

            return;
        }
    }
}

dig_up_zombie( player, s_dig_spot )
{
    ai_zombie = spawn_zombie( level.dig_spawners[0] );
    ai_zombie endon( "death" );
    ai_zombie ghost();
    e_linker = spawn( "script_origin", ( 0, 0, 0 ) );
    e_linker.origin = ai_zombie.origin;
    e_linker.angles = ai_zombie.angles;
    ai_zombie linkto( e_linker );
    e_linker moveto( player.origin + vectorscale( ( 1, 1, 0 ), 100.0 ), 0.1 );

    e_linker waittill( "movedone" );

    ai_zombie unlink();
    e_linker delete();
    ai_zombie show();
    ai_zombie playsound( "evt_zombie_dig_dirt" );
    ai_zombie dug_zombie_rise( s_dig_spot );
    find_flesh_struct_string = "find_flesh";
    ai_zombie notify( "zombie_custom_think_done", find_flesh_struct_string );
}

dig_up_powerup( player )
{
    powerup = spawn( "script_model", self.origin );
    powerup endon( "powerup_grabbed" );
    powerup endon( "powerup_timedout" );
    a_rare_powerups = dig_get_rare_powerups( player );
    powerup_item = undefined;

    if ( level.dig_n_powerups_spawned + level.powerup_drop_count > 4 || level.dig_last_prize_rare || a_rare_powerups.size == 0 || randomint( 100 ) < 80 )
    {
        if ( level.dig_n_zombie_bloods_spawned < 1 && randomint( 100 ) > 70 )
        {
            powerup_item = "zombie_blood";
            level.dig_n_zombie_bloods_spawned++;
            level.dig_n_powerups_spawned++;
            player dig_reward_dialog( "dig_powerup" );
        }
        else
        {
            powerup_item = "bonus_points_player";
            player dig_reward_dialog( "dig_cash" );
        }

        level.dig_last_prize_rare = 0;
    }
    else
    {
        powerup_item = a_rare_powerups[randomint( a_rare_powerups.size )];
        level.dig_last_prize_rare = 1;
        level.dig_n_powerups_spawned++;
        player dig_reward_dialog( "dig_powerup" );
        dig_set_powerup_spawned( powerup_item );
    }

    powerup maps\mp\zombies\_zm_powerups::powerup_setup( powerup_item );
    powerup movez( 40, 0.6 );

    powerup waittill( "movedone" );

    powerup thread maps\mp\zombies\_zm_powerups::powerup_timeout();
    powerup thread maps\mp\zombies\_zm_powerups::powerup_wobble();
    powerup thread maps\mp\zombies\_zm_powerups::powerup_grab();
}

dig_get_rare_powerups( player )
{
    a_rare_powerups = [];
    a_possible_powerups = array( "nuke", "double_points" );

    if ( level.dig_magic_box_moved && !dig_has_powerup_spawned( "fire_sale" ) )
        a_possible_powerups[a_possible_powerups.size] = "fire_sale";

    if ( player.dig_vars["has_upgraded_shovel"] )
        a_possible_powerups = combinearrays( a_possible_powerups, array( "insta_kill", "full_ammo" ) );

    foreach ( powerup in a_possible_powerups )
    {
        if ( !dig_has_powerup_spawned( powerup ) )
            a_rare_powerups[a_rare_powerups.size] = powerup;
    }

    return a_rare_powerups;
}

dig_up_grenade( player )
{
    player endon( "disconnect" );
    v_spawnpt = self.origin;
    grenade = "frag_grenade_zm";
    n_rand = randomintrange( 0, 4 );
    player magicgrenadetype( grenade, v_spawnpt, vectorscale( ( 0, 0, 1 ), 300.0 ), 3.0 );
    player playsound( "evt_grenade_digup" );

    if ( n_rand )
    {
        wait 0.3;

        if ( cointoss() )
            player magicgrenadetype( grenade, v_spawnpt, ( 50, 50, 300 ), 3.0 );
    }
}

dig_up_weapon( digger )
{
    a_common_weapons = array( "ballista_zm", "c96_zm", "870mcs_zm" );
    a_rare_weapons = array( "dsr50_zm", "srm1216_zm" );

    if ( digger.dig_vars["has_upgraded_shovel"] )
        a_rare_weapons = combinearrays( a_rare_weapons, array( "claymore_zm", "ak74u_zm", "ksg_zm", "mp40_zm", "mp44_zm" ) );

    str_weapon = undefined;

    if ( randomint( 100 ) < 90 )
        str_weapon = a_common_weapons[getarraykeys( a_common_weapons )[randomint( getarraykeys( a_common_weapons ).size )]];
    else
        str_weapon = a_rare_weapons[getarraykeys( a_rare_weapons )[randomint( getarraykeys( a_rare_weapons ).size )]];

    v_spawnpt = self.origin + ( 0, 0, 40 );
    v_spawnang = ( 0, 0, 0 );
    str_spec_model = undefined;

    if ( str_weapon == "claymore_zm" )
    {
        str_spec_model = "t6_wpn_claymore_world";
        v_spawnang += vectorscale( ( 0, 1, 0 ), 90.0 );
    }

    v_angles = digger getplayerangles();
    v_angles = ( 0, v_angles[1], 0 ) + vectorscale( ( 0, 1, 0 ), 90.0 ) + v_spawnang;
    m_weapon = spawn_weapon_model( str_weapon, str_spec_model, v_spawnpt, v_angles );

    if ( str_weapon == "claymore_zm" )
    {
        m_weapon setmodel( "t6_wpn_claymore_world" );
        v_spawnang += vectorscale( ( 0, 0, 1 ), 90.0 );
    }

    m_weapon.angles = v_angles;
    m_weapon playloopsound( "evt_weapon_digup" );
    m_weapon thread timer_til_despawn( v_spawnpt, 40 * -1 );
    m_weapon endon( "dig_up_weapon_timed_out" );
    playfxontag( level._effect["special_glow"], m_weapon, "tag_origin" );
    m_weapon.trigger = tomb_spawn_trigger_radius( v_spawnpt, 100, 1 );
    m_weapon.trigger.hint_string = &"ZM_TOMB_X2PU";
    m_weapon.trigger.hint_parm1 = getweapondisplayname( str_weapon );

    m_weapon.trigger waittill( "trigger", player );

    m_weapon.trigger notify( "weapon_grabbed" );
    m_weapon.trigger thread swap_weapon( str_weapon, player );

    if ( isdefined( m_weapon.trigger ) )
    {
        m_weapon.trigger tomb_unitrigger_delete();
        m_weapon.trigger = undefined;
    }

    if ( isdefined( m_weapon ) )
        m_weapon delete();

    if ( player != digger )
        digger notify( "dig_up_weapon_shared" );
}

swap_weapon( str_weapon, e_player )
{
    str_current_weapon = e_player getcurrentweapon();

    if ( str_weapon == "claymore_zm" )
    {
        if ( !e_player hasweapon( str_weapon ) )
        {
            e_player thread maps\mp\zombies\_zm_weap_claymore::show_claymore_hint( "claymore_purchased" );
            e_player thread maps\mp\zombies\_zm_weap_claymore::claymore_setup();
            e_player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "weapon_pickup", "grenade" );
        }
        else
            e_player givemaxammo( str_weapon );

        return;
    }

    if ( is_player_valid( e_player ) && !e_player.is_drinking && !is_placeable_mine( str_current_weapon ) && !is_equipment( str_current_weapon ) && level.revive_tool != str_current_weapon && "none" != str_current_weapon && !e_player hacker_active() )
    {
        if ( !e_player hasweapon( str_weapon ) )
            e_player take_old_weapon_and_give_new( str_current_weapon, str_weapon );
        else
            e_player givemaxammo( str_weapon );
    }
}

take_old_weapon_and_give_new( current_weapon, weapon )
{
    a_weapons = self getweaponslistprimaries();

    if ( isdefined( a_weapons ) && a_weapons.size >= get_player_weapon_limit( self ) )
        self takeweapon( current_weapon );

    self giveweapon( weapon );
    self switchtoweapon( weapon );
}

timer_til_despawn( v_float, n_dist )
{
    self endon( "weapon_grabbed" );
    putbacktime = 12;
    self movez( n_dist, putbacktime, putbacktime * 0.5 );

    self waittill( "movedone" );

    self notify( "dig_up_weapon_timed_out" );

    if ( isdefined( self.trigger ) )
    {
        self.trigger tomb_unitrigger_delete();
        self.trigger = undefined;
    }

    if ( isdefined( self ) )
        self delete();
}

get_player_perk_purchase_limit()
{
    if ( isdefined( self.player_perk_purchase_limit ) )
        return self.player_perk_purchase_limit;

    return level.perk_purchase_limit;
}

increment_player_perk_purchase_limit()
{
    if ( !isdefined( self.player_perk_purchase_limit ) )
        self.player_perk_purchase_limit = level.perk_purchase_limit;

    if ( self.player_perk_purchase_limit < 8 )
        self.player_perk_purchase_limit++;
}

ee_zombie_blood_dig()
{
    self endon( "disconnect" );
    n_z_spots_found = 0;
    a_z_spots = getstructarray( "zombie_blood_dig_spot", "targetname" );
    self.t_zombie_blood_dig = spawn( "trigger_radius_use", ( 0, 0, 0 ), 0, 100, 50 );
    self.t_zombie_blood_dig.e_unique_player = self;
    self.t_zombie_blood_dig triggerignoreteam();
    self.t_zombie_blood_dig setcursorhint( "HINT_NOICON" );
    self.t_zombie_blood_dig sethintstring( &"ZM_TOMB_X2D" );
    self.t_zombie_blood_dig maps\mp\zombies\_zm_powerup_zombie_blood::make_zombie_blood_entity();

    while ( n_z_spots_found < 4 )
    {
        a_randomized = array_randomize( a_z_spots );
        n_index = undefined;

        for ( i = 0; i < a_randomized.size; i++ )
        {
            if ( !isdefined( a_randomized[i].n_player ) )
            {
                n_index = i;
                break;
            }
        }

        assert( isdefined( n_index ), "No more zombie blood dig spots.  Add more to the map." );
        s_z_spot = a_randomized[n_index];
        s_z_spot.n_player = self getentitynumber();
        s_z_spot create_zombie_blood_dig_spot( self );
        n_z_spots_found++;

        level waittill( "end_of_round" );
    }

    self.t_zombie_blood_dig delete();
}

ee_zombie_blood_dig_disconnect_watch()
{
    self waittill( "disconnect" );

    if ( isdefined( self.t_zombie_blood_dig ) )
        self.t_zombie_blood_dig delete();

    a_z_spots = getstructarray( "zombie_blood_dig_spot", "targetname" );

    foreach ( s_pos in a_z_spots )
    {
        if ( isdefined( s_pos.n_player ) && s_pos.n_player == self getentitynumber() )
            s_pos.n_player = undefined;

        if ( isdefined( s_pos.m_dig ) )
            s_pos delete();
    }
}

create_zombie_blood_dig_spot( e_player )
{
    self.m_dig = spawn( "script_model", self.origin + vectorscale( ( 0, 0, -1 ), 40.0 ) );
    self.m_dig.angles = self.angles;
    self.m_dig setmodel( "p6_zm_tm_dig_mound_blood" );
    self.m_dig maps\mp\zombies\_zm_powerup_zombie_blood::make_zombie_blood_entity();
    self.m_dig moveto( self.origin, 3, 0, 1 );

    self.m_dig waittill( "movedone" );

    self.m_dig.e_unique_player = e_player;
/#
    self thread puzzle_debug_position( "+", vectorscale( ( 0, 0, 1 ), 255.0 ), self.origin );
#/
    e_player.t_zombie_blood_dig.origin = self.origin + vectorscale( ( 0, 0, 1 ), 20.0 );
    e_player.t_zombie_blood_dig waittill_zombie_blood_dug( self );
/#
    self notify( "stop_debug_position" );
#/
}

waittill_zombie_blood_dug( s_dig_spot )
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( isdefined( player.dig_vars["has_shovel"] ) && player.dig_vars["has_shovel"] )
        {
            player.t_zombie_blood_dig.origin = ( 0, 0, 0 );
            player playsound( "evt_dig" );
            playfx( level._effect["digging"], self.origin );
            s_dig_spot.m_dig delete();
            spawn_perk_upgrade_bottle( s_dig_spot.origin, player );
            return;
        }
    }
}

spawn_perk_upgrade_bottle( v_origin, e_player )
{
    m_bottle = spawn( "script_model", v_origin + vectorscale( ( 0, 0, 1 ), 40.0 ) );
    m_bottle setmodel( "zombie_pickup_perk_bottle" );
    m_bottle.angles = vectorscale( ( 1, 0, 0 ), 10.0 );
    m_bottle setinvisibletoall();
    m_bottle setvisibletoplayer( e_player );
    m_fx = spawn( "script_model", m_bottle.origin );
    m_fx setmodel( "tag_origin" );
    m_fx setinvisibletoall();
    m_fx setvisibletoplayer( e_player );
    playfxontag( level._effect["special_glow"], m_fx, "tag_origin" );
    m_bottle linkto( m_fx );
    m_fx thread rotate_perk_upgrade_bottle();

    while ( isdefined( e_player ) && !e_player istouching( m_bottle ) )
        wait 0.05;

    m_bottle delete();
    m_fx delete();

    if ( isdefined( e_player ) )
    {
        e_player increment_player_perk_purchase_limit();
        e_player maps\mp\zombies\_zm_stats::increment_client_stat( "tomb_perk_extension", 0 );
        e_player maps\mp\zombies\_zm_stats::increment_player_stat( "tomb_perk_extension" );
    }
}

rotate_perk_upgrade_bottle()
{
    self endon( "death" );

    while ( true )
    {
        self rotateyaw( 360, 5 );

        self waittill( "rotatedone" );
    }
}

bonus_points_powerup_override()
{
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "blood_money" );
    points = randomintrange( 1, 6 ) * 50;
    return points;
}

dig_powerups_tracking()
{
    level endon( "end_game" );
    level.dig_powerups_tracking = [];
    level.dig_magic_box_moved = 0;
    level.dig_last_prize_rare = 0;
    level.dig_n_zombie_bloods_spawned = 0;

    for ( level.dig_n_powerups_spawned = 0; 1; level.dig_n_powerups_spawned = 0 )
    {
        level waittill( "end_of_round" );

        foreach ( str_powerup, value in level.dig_powerups_tracking )
            level.dig_powerups_tracking[str_powerup] = 0;

        level.dig_n_zombie_bloods_spawned = 0;
    }
}

dig_has_powerup_spawned( str_powerup )
{
    if ( !isdefined( level.dig_powerups_tracking[str_powerup] ) )
        level.dig_powerups_tracking[str_powerup] = 0;

    return level.dig_powerups_tracking[str_powerup];
}

dig_set_powerup_spawned( str_powerup )
{
    level.dig_powerups_tracking[str_powerup] = 1;
}

setup_dig_devgui()
{
/#
    setdvar( "give_shovel", "off" );
    setdvar( "give_golden_shovel", "off" );
    setdvar( "give_helmet", "off" );
    setdvar( "spawn_max_mounds", "off" );
    setdvar( "spawn_all_mounds", "off" );
    setdvar( "test_blood_mounds", "off" );
    setdvar( "force_weather_rain", "off" );
    setdvar( "force_weather_snow", "off" );
    setdvar( "force_weather_none", "off" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Digging:1/Give Shovel:1\" \"give_shovel on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Digging:1/Give Golden Shovel:2\" \"give_golden_shovel on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Digging:1/Give Helmet:3\" \"give_helmet on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Digging:1/Spawn Max Mounds:4\" \"spawn_max_mounds on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Digging:1/Spawn All Mounds:5\" \"spawn_all_mounds on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Digging:1/Test Blood Mounds:6\" \"test_blood_mounds on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Weather:1/Rain:1\" \"force_weather_rain on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Weather:1/Snow:2\" \"force_weather_snow on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Weather:1/Clear:3\" \"force_weather_none on\"\n" );
    level thread watch_devgui_dig();
#/
}

watch_devgui_dig()
{
/#
    while ( true )
    {
        if ( getdvar( _hash_C817F0A0 ) == "on" )
        {
            setdvar( "give_shovel", "off" );

            foreach ( player in getplayers() )
            {
                player.dig_vars["has_shovel"] = 1;
                n_player = player getentitynumber() + 1;
                level setclientfield( "shovel_player" + n_player, 1 );
            }
        }

        if ( getdvar( _hash_8B880FB8 ) == "on" )
        {
            setdvar( "give_golden_shovel", "off" );

            foreach ( player in getplayers() )
            {
                player.dig_vars["has_shovel"] = 1;
                player.dig_vars["has_upgraded_shovel"] = 1;
                player thread ee_zombie_blood_dig();
                n_player = player getentitynumber() + 1;
                level setclientfield( "shovel_player" + n_player, 2 );
            }
        }

        if ( getdvar( _hash_AE371CCE ) == "on" )
        {
            setdvar( "give_helmet", "off" );

            foreach ( player in getplayers() )
            {
                player.dig_vars["has_helmet"] = 1;
                n_player = player getentitynumber() + 1;
                level setclientfield( "helmet_player" + n_player, 1 );
            }
        }

        if ( getdvar( _hash_B92412E8 ) == "on" )
        {
            setdvar( "spawn_max_mounds", "off" );
            a_dig_spots = array_randomize( level.a_dig_spots );

            for ( i = 0; i < a_dig_spots.size; i++ )
            {
                if ( isdefined( a_dig_spots[i].dug ) && a_dig_spots[i].dug && level.n_dig_spots_cur <= level.n_dig_spots_max )
                {
                    a_dig_spots[i].dug = undefined;
                    a_dig_spots[i] thread dig_spot_spawn();
                    wait_network_frame();
                }
            }
        }

        if ( getdvar( _hash_76E825DB ) == "on" )
        {
            setdvar( "spawn_all_mounds", "off" );
            a_dig_spots = array_randomize( level.a_dig_spots );

            for ( i = 0; i < a_dig_spots.size; i++ )
            {
                if ( isdefined( a_dig_spots[i].dug ) && a_dig_spots[i].dug )
                {
                    a_dig_spots[i].dug = undefined;
                    a_dig_spots[i] thread dig_spot_spawn();
                    wait_network_frame();
                }
            }
        }

        if ( getdvar( _hash_9D237849 ) == "on" )
        {
            setdvar( "test_blood_mounds", "off" );
            a_z_spots = getstructarray( "zombie_blood_dig_spot", "targetname" );

            foreach ( s_spot in a_z_spots )
            {
                s_spot.m_dig = spawn( "script_model", s_spot.origin + vectorscale( ( 0, 0, -1 ), 40.0 ) );
                s_spot.m_dig.angles = s_spot.angles;
                s_spot.m_dig setmodel( "p6_zm_tm_dig_mound_blood" );
                s_spot.m_dig moveto( s_spot.origin, 3, 0, 1 );
                wait_network_frame();
            }
        }

        if ( getdvar( _hash_6A4B6CAC ) == "on" )
        {
            setdvar( "force_weather_rain", "off" );
            level.weather_snow = 0;
            level.weather_rain = 5;
            level.weather_vision = 1;
            level setclientfield( "rain_level", level.weather_rain );
            level setclientfield( "snow_level", level.weather_snow );
            wait 1;

            foreach ( player in getplayers() )
            {
                if ( is_player_valid( player, 0, 1 ) )
                    player set_weather_to_player();
            }
        }

        if ( getdvar( _hash_6A4C3129 ) == "on" )
        {
            setdvar( "force_weather_snow", "off" );
            level.weather_snow = 5;
            level.weather_rain = 0;
            level.weather_vision = 2;
            level setclientfield( "rain_level", level.weather_rain );
            level setclientfield( "snow_level", level.weather_snow );
            wait 1;

            foreach ( player in getplayers() )
            {
                if ( is_player_valid( player, 0, 1 ) )
                    player set_weather_to_player();
            }
        }

        if ( getdvar( _hash_6A497752 ) == "on" )
        {
            setdvar( "force_weather_none", "off" );
            level.weather_snow = 0;
            level.weather_rain = 0;
            level.weather_vision = 3;
            level setclientfield( "rain_level", level.weather_rain );
            level setclientfield( "snow_level", level.weather_snow );
            wait 1;

            foreach ( player in getplayers() )
            {
                if ( is_player_valid( player, 0, 1 ) )
                    player set_weather_to_player();
            }
        }

        wait 0.05;
    }
#/
}
