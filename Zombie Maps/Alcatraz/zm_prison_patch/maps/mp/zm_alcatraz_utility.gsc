// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zm_alcatraz_weap_quest;
#include maps\mp\zombies\_zm_afterlife;

include_craftable( craftable_struct )
{
/#
    println( "ZM >> include_craftable = " + craftable_struct.name );
#/
    maps\mp\zombies\_zm_craftables::include_zombie_craftable( craftable_struct );
}

is_craftable()
{
    return self maps\mp\zombies\_zm_craftables::is_craftable();
}

is_part_crafted( craftable_name, part_modelname )
{
    return maps\mp\zombies\_zm_craftables::is_part_crafted( craftable_name, part_modelname );
}

wait_for_craftable( craftable_name )
{
    level waittill( craftable_name + "_crafted", player );

    return player;
}

is_team_on_golden_gate_bridge()
{
    players = getplayers();
    e_zone = getent( "zone_golden_gate_bridge", "targetname" );

    foreach ( player in players )
    {
        if ( player istouching( e_zone ) )
        {
            continue;
            continue;
        }

        return false;
    }

    return true;
}

create_tutorial_message( str_msg )
{
    if ( !isdefined( self.client_hint ) )
    {
        self.client_hint = newclienthudelem( self );
        self.client_hint.alignx = "center";
        self.client_hint.aligny = "middle";
        self.client_hint.horzalign = "center";
        self.client_hint.vertalign = "bottom";

        if ( self issplitscreen() )
            self.client_hint.y = -140;
        else
            self.client_hint.y = -250;

        self.client_hint.foreground = 1;
        self.client_hint.font = "default";
        self.client_hint.fontscale = 1.5;
        self.client_hint.alpha = 1;
        self.client_hint.foreground = 1;
        self.client_hint.hidewheninmenu = 1;
        self.client_hint.color = ( 1, 1, 1 );
    }

    self.client_hint settext( str_msg );
}

destroy_tutorial_message()
{
    if ( isdefined( self.client_hint ) )
    {
        self.client_hint fadeovertime( 0.5 );
        self.client_hint.alpha = 0;
        wait 0.5;

        if ( isdefined( self.client_hint ) )
        {
            self.client_hint destroy();
            self.client_hint = undefined;
        }
    }
}

get_array_of_farthest( org, array, excluders, max )
{
    sorted_array = get_array_of_closest( org, array, excluders );

    if ( isdefined( max ) )
    {
        temp_array = [];

        for ( i = 0; i < sorted_array.size; i++ )
            temp_array[temp_array.size] = sorted_array[sorted_array.size - i];

        sorted_array = temp_array;
    }

    sorted_array = array_reverse( sorted_array );
    return sorted_array;
}

drop_all_barriers()
{
    zkeys = getarraykeys( level.zones );

    for ( z = 0; z < level.zones.size; z++ )
    {
        if ( zkeys[z] != "zone_start" && zkeys[z] != "zone_library" )
        {
            zbarriers = get_all_zone_zbarriers( zkeys[z] );

            if ( !isdefined( zbarriers ) )
                continue;

            foreach ( zbarrier in zbarriers )
            {
                zbarrier_pieces = zbarrier getnumzbarrierpieces();

                for ( i = 0; i < zbarrier_pieces; i++ )
                {
                    zbarrier hidezbarrierpiece( i );
                    zbarrier setzbarrierpiecestate( i, "open" );
                }

                wait 0.05;
            }
        }
    }
}

get_all_zone_zbarriers( zone_name )
{
    if ( !isdefined( zone_name ) )
        return undefined;

    zone = level.zones[zone_name];
    return zone.zbarriers;
}

blundergat_change_hintstring( hint_string )
{
    self notify( "new_change_hint_string" );
    self endon( "new_change_hint_string" );

    while ( isdefined( self.is_locked ) && self.is_locked )
        wait 0.05;

    self sethintstring( hint_string );
    wait 0.05;
    self sethintstring( hint_string );
}

#using_animtree("fxanim_props");

blundergat_upgrade_station()
{
    t_upgrade = getent( "blundergat_upgrade", "targetname" );
    t_upgrade sethintstring( &"ZM_PRISON_CONVERT_START" );
    waittill_crafted( "packasplat" );
    m_converter = t_upgrade.m_upgrade_machine;
    v_angles = m_converter gettagangles( "tag_origin" );
    v_weapon_origin_offset = anglestoforward( v_angles ) * 1 + anglestoright( v_angles ) * 10 + anglestoup( v_angles ) * 1.75;
    v_weapon_angles_offset = ( 0, 90, -90 );
    m_converter.v_weapon_origin = m_converter gettagorigin( "tag_origin" ) + v_weapon_origin_offset;
    m_converter.v_weapon_angles = v_angles + v_weapon_angles_offset;
    m_converter useanimtree( -1 );
    m_converter.fxanims["close"] = %fxanim_zom_al_packasplat_start_anim;
    m_converter.fxanims["inject"] = %fxanim_zom_al_packasplat_idle_anim;
    m_converter.fxanims["open"] = %fxanim_zom_al_packasplat_end_anim;
    m_converter.n_start_time = getanimlength( m_converter.fxanims["close"] );
    m_converter.n_idle_time = getanimlength( m_converter.fxanims["inject"] );
    m_converter.n_end_time = getanimlength( m_converter.fxanims["open"] );

    while ( true )
    {
        t_upgrade thread blundergat_change_hintstring( &"ZM_PRISON_CONVERT_START" );

        t_upgrade waittill( "trigger", player );

        if ( isdefined( level.custom_craftable_validation ) )
        {
            valid = t_upgrade [[ level.custom_craftable_validation ]]( player );

            if ( !valid )
                continue;
        }

        str_valid_weapon = undefined;

        if ( player hasweapon( "blundergat_zm" ) )
            str_valid_weapon = "blundergat_zm";
        else if ( player hasweapon( "blundergat_upgraded_zm" ) )
            str_valid_weapon = "blundergat_upgraded_zm";

        if ( isdefined( str_valid_weapon ) )
        {
            player takeweapon( str_valid_weapon );
            player.is_pack_splatting = 1;
            t_upgrade setinvisibletoall();
            m_converter.worldgun = spawn_weapon_model( str_valid_weapon, undefined, m_converter.v_weapon_origin, m_converter.v_weapon_angles );
            m_converter blundergat_upgrade_station_inject( str_valid_weapon );
            t_upgrade thread blundergat_change_hintstring( &"ZM_PRISON_CONVERT_PICKUP" );

            if ( isdefined( player ) )
            {
                t_upgrade setvisibletoplayer( player );
                t_upgrade thread wait_for_player_to_take( player, str_valid_weapon );
            }

            t_upgrade thread wait_for_timeout();
            t_upgrade waittill_any( "acid_timeout", "acid_taken" );

            if ( isdefined( player ) )
                player.is_pack_splatting = undefined;

            m_converter.worldgun delete();
            wait 0.5;
            t_upgrade setvisibletoall();
        }
        else
        {
            t_upgrade thread blundergat_change_hintstring( &"ZM_PRISON_MISSING_BLUNDERGAT" );
            wait 2;
        }
    }
}

wait_for_player_to_take( player, str_valid_weapon )
{
    self endon( "acid_timeout" );
    player endon( "disconnect" );

    while ( true )
    {
        self waittill( "trigger", trigger_player );

        if ( isdefined( level.custom_craftable_validation ) )
        {
            valid = self [[ level.custom_craftable_validation ]]( player );

            if ( !valid )
                continue;
        }

        if ( trigger_player == player )
        {
            current_weapon = player getcurrentweapon();

            if ( is_player_valid( player ) && !( player.is_drinking > 0 ) && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && "none" != current_weapon && !player hacker_active() )
            {
                self notify( "acid_taken" );
                player notify( "acid_taken" );
                weapon_limit = 2;
                primaries = player getweaponslistprimaries();

                if ( isdefined( primaries ) && primaries.size >= weapon_limit )
                    player takeweapon( current_weapon );

                str_new_weapon = undefined;

                if ( str_valid_weapon == "blundergat_zm" )
                    str_new_weapon = "blundersplat_zm";
                else
                    str_new_weapon = "blundersplat_upgraded_zm";

                if ( player hasweapon( "blundersplat_zm" ) )
                    player givemaxammo( "blundersplat_zm" );
                else if ( player hasweapon( "blundersplat_upgraded_zm" ) )
                    player givemaxammo( "blundersplat_upgraded_zm" );
                else
                {
                    player giveweapon( str_new_weapon );
                    player switchtoweapon( str_new_weapon );
                }

                player thread do_player_general_vox( "general", "player_recieves_blundersplat" );
                player notify( "player_obtained_acidgat" );
                player thread player_lost_blundersplat_watcher();
                return;
            }
        }
    }
}

wait_for_timeout()
{
    self endon( "acid_taken" );
    wait 15;
    self notify( "acid_timeout" );
}

blundergat_upgrade_station_inject( str_weapon_model )
{
    wait 0.5;
    self playsound( "zmb_acidgat_upgrade_machine" );
    self setanim( self.fxanims["close"], 1, 0, 1 );
    wait( self.n_start_time );

    for ( i = 0; i < 3; i++ )
    {
        self setanim( self.fxanims["inject"], 1, 0, 1 );
        wait( self.n_idle_time );
    }

    self.worldgun delete();

    if ( str_weapon_model == "blundergat_zm" )
        self.worldgun = spawn_weapon_model( "blundersplat_zm", undefined, self.v_weapon_origin, self.v_weapon_angles );
    else
        self.worldgun = spawn_weapon_model( "blundersplat_upgraded_zm", undefined, self.v_weapon_origin, self.v_weapon_angles );

    self setanim( self.fxanims["open"], 1, 0, 1 );
    wait( self.n_end_time );
    wait 0.5;
}

player_lost_blundersplat_watcher()
{
    while ( isdefined( self ) )
    {
        if ( isalive( self ) )
        {
            primaries = self getweaponslistprimaries();

            if ( !isinarray( primaries, "blundersplat_zm" ) && !isinarray( primaries, "blundersplat_upgraded_zm" ) )
            {
                if ( !( isdefined( self.afterlife ) && self.afterlife ) )
                    break;
            }
        }

        wait 1.0;
    }
}

player_lightning_manager()
{
    self endon( "disconnect" );
    self.b_lightning = 0;
    a_bad_zones[0] = "zone_dryer";
    a_bad_zones[1] = "zone_studio";
    a_bad_zones[2] = "zone_citadel_stairs";
    a_bad_zones[3] = "cellblock_shower";
    a_bad_zones[4] = "zone_citadel";
    a_bad_zones[5] = "zone_infirmary";
    a_bad_zones[6] = "zone_infirmary_roof";
    a_bad_zones[7] = "zone_citadel_shower";

    while ( true )
    {
        str_player_zone = self get_player_zone();

        if ( !isdefined( str_player_zone ) )
        {
            wait 1;
            continue;
        }

        if ( isdefined( level.hostmigrationtimer ) )
        {
            level waittill( "host_migration_end" );

            self.b_lightning = 0;
            self setclientfieldtoplayer( "toggle_lightning", 0 );
            wait 1;
        }

        if ( isdefined( self.afterlife ) && self.afterlife || isdefined( self.scary_lightning ) && self.scary_lightning )
        {
            self.b_lightning = 0;
            self setclientfieldtoplayer( "toggle_lightning", 0 );

            while ( isdefined( self.afterlife ) && self.afterlife || isdefined( self.scary_lightning ) && self.scary_lightning )
                wait 0.05;
        }

        if ( isdefined( self.b_lightning ) && self.b_lightning )
        {
            foreach ( str_bad_zone in a_bad_zones )
            {
                if ( str_player_zone == str_bad_zone )
                {
                    self.b_lightning = 0;
                    self setclientfieldtoplayer( "toggle_lightning", 0 );
                    break;
                }
            }
        }
        else
        {
            self.b_lightning = 1;

            foreach ( str_bad_zone in a_bad_zones )
            {
                if ( str_player_zone == str_bad_zone )
                    self.b_lightning = 0;
            }

            if ( isdefined( self.b_lightning ) && self.b_lightning )
                self setclientfieldtoplayer( "toggle_lightning", 1 );
        }

        wait 1;
    }
}

setting_tutorial_hud()
{
    client_hint = newclienthudelem( self );
    client_hint.x = 320;
    client_hint.y = 220;
    client_hint.alignx = "center";
    client_hint.aligny = "bottom";
    client_hint.fontscale = 1.6;
    client_hint.alpha = 1;
    client_hint.sort = 20;
    return client_hint;
}

riotshield_tutorial_hint()
{
    self waittill( "alcatraz_shield_zm_given" );

    wait 4;
    hud = setting_tutorial_hud();
    hud settext( &"ZM_PRISON_RIOTSHIELD_ATTACK" );
    self waittill_notify_or_timeout( "shield_attack", 3 );
    hud settext( &"ZM_PRISON_RIOTSHIELD_DEPLOY" );
    self waittill_notify_or_timeout( "shield_attack", 3 );
    hud destroy();
}

check_solo_status()
{
    if ( getnumexpectedplayers() == 1 && ( !sessionmodeisonlinegame() || !sessionmodeisprivate() ) )
        level.is_forever_solo_game = 1;
    else
        level.is_forever_solo_game = 0;
}

disable_powerup_if_player_on_bridge()
{
    self endon( "disconnect" );
    flag_wait( "afterlife_start_over" );

    while ( true )
    {
        if ( self maps\mp\zombies\_zm_zonemgr::is_player_in_zone( "zone_golden_gate_bridge" ) )
        {
            if ( flag( "zombie_drop_powerups" ) )
                flag_clear( "zombie_drop_powerups" );
        }

        wait 1;
    }
}

enable_powerup_if_no_player_on_bridge()
{
    flag_wait( "afterlife_start_over" );

    while ( true )
    {
        n_player_total = 0;
        n_player_total += get_players_in_zone( "zone_golden_gate_bridge" );

        if ( n_player_total == 0 && !flag( "zombie_drop_powerups" ) )
            flag_set( "zombie_drop_powerups" );

        wait 1;
    }
}

init_level_specific_audio()
{
    level.oh_shit_vo_cooldown = 0;
    level.wolf_kill_vo_cooldown = 0;
    level.wallbuys_purchased = 0;
    setdvar( "zombie_kills", "5" );
    setdvar( "zombie_kill_timer", "5" );

    if ( is_classic() )
    {
        level._audio_custom_response_line = ::alcatraz_audio_custom_response_line;
        level.audio_get_mod_type = ::alcatraz_audio_get_mod_type_override;
        level.custom_kill_damaged_vo = maps\mp\zombies\_zm_audio::custom_kill_damaged_vo;
        level._custom_zombie_oh_shit_vox_func = ::alcatraz_custom_zombie_oh_shit_vox;
        level.gib_on_damage = ::alcatraz_custom_crawler_spawned_vo;
        level thread alcatraz_first_magic_box_seen_vo();
        level._audio_custom_weapon_check = ::alcatraz_audio_custom_weapon_check;
        level thread brutus_spawn_vo_watcher();
        level thread brutus_killed_vo_watcher();
    }

    level thread setup_conversation_vo();
    alcatraz_add_player_dialogue( "player", "general", "no_money_weapon", "nomoney_generic", undefined );
    alcatraz_add_player_dialogue( "player", "general", "no_money_box", "nomoney_generic", undefined );
    alcatraz_add_player_dialogue( "player", "general", "perk_deny", "nomoney_generic", undefined );
    alcatraz_add_player_dialogue( "player", "perk", "specialty_armorvest", "perk_generic", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "perk", "specialty_fastreload", "perk_generic", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "perk", "specialty_rof", "perk_generic", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "perk", "specialty_deadshot", "perk_generic", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "perk", "specialty_grenadepulldeath", "perk_generic", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "kill", "closekill", "kill_close", undefined, 15 );
    alcatraz_add_player_dialogue( "player", "kill", "damage", "kill_damaged", undefined, 50 );
    alcatraz_add_player_dialogue( "player", "kill", "headshot", "kill_headshot", "resp_kill_headshot", 25 );
    alcatraz_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_0", "headshot_respond_to_plr_0", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_1", "headshot_respond_to_plr_1", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_2", "headshot_respond_to_plr_2", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_3", "headshot_respond_to_plr_3", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "kill", "headshot_respond_generic", "headshot_respond_generic", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "kill", "retriever", "kill_retriever", undefined, 15 );
    alcatraz_add_player_dialogue( "player", "kill", "redeemer", "kill_redeemer", undefined, 15 );
    alcatraz_add_player_dialogue( "player", "kill", "blundergat", "kill_blundergat", undefined, 15 );
    alcatraz_add_player_dialogue( "player", "kill", "acidgat", "kill_acidgat", undefined, 15 );
    alcatraz_add_player_dialogue( "player", "kill", "death_machine", "kill_death_machine", undefined, 15 );
    alcatraz_add_player_dialogue( "player", "kill", "wolf_kill", "wolf_kill", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "achievement", "earn_acheivement", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "revive_up", "heal_revived", "revive_player", 100 );
    alcatraz_add_player_dialogue( "player", "general", "revive_player", "revive_player", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "exert_sigh", "exert_sigh", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "exert_laugh", "exert_laugh", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "pain_high", "pain_high", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_pickup", "build_pickup", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_swap", "build_swap", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_add", "build_add", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_final", "build_final", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_bsm_pickup", "build_bsm_pickup", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_bsm_final", "build_bsm_final", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "player_recieves_blundersplat", "build_bsm_plc", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_zs_pickup", "build_zs_pickup", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_zs_final", "build_zs_final", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "build_zs_plc", "build_zs_plc", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "reboard", "rebuild_boards", undefined, 50 );
    alcatraz_add_player_dialogue( "player", "general", "discover_box", "discover_box", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "discover_wall_buy", "discover_wall_buy", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "generic_wall_buy", "generic_wall_buy", undefined, 25 );
    alcatraz_add_player_dialogue( "player", "general", "wpck_pap", "wpck_pap", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "portal_clue", "portal_clue", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "killswitch_clue", "killswitch_clue", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "power_off", "power_off", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "power_on", "power_on", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "electric_zap", "electric_zap", undefined, 25 );
    alcatraz_add_player_dialogue( "player", "general", "need_electricity", "need_electricity", undefined, 25 );
    alcatraz_add_player_dialogue( "player", "general", "use_gondola", "use_gondola", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "discover_trap", "discover_trap", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "start_trap", "start_trap", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "surrounded_respond_to_plr_0", "surrounded_respond_to_plr_0", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "surrounded_respond_to_plr_1", "surrounded_respond_to_plr_1", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "surrounded_respond_to_plr_2", "surrounded_respond_to_plr_2", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "surrounded_respond_to_plr_3", "surrounded_respond_to_plr_3", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "wolf_complete", "wolf_complete", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "wolf_final", "wolf_final", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "wolf_encounter", "wolf_encounter", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "brutus_encounter", "brutus_encounter", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "brutus_arrival", "brutus_arrival", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "brutus_reaction", "brutus_reaction", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "general", "brutus_defeated", "brutus_defeated", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "find_map", "find_map", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "response_map", "response_map", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_key", "sidequest_key", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_key_response", "sidequest_key_response", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_sheets", "sidequest_sheets", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_valves", "sidequest_valves", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_engine", "sidequest_engine", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_rigging", "sidequest_rigging", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_oxygen", "sidequest_oxygen", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_parts1_prog", "sidequest_parts1_prog", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_parts2_prog", "sidequest_parts2_prog", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_parts3_prog", "sidequest_parts3_prog", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_parts4_prog", "sidequest_parts4_prog", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_all_parts", "sidequest_all_parts", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "sidequest_roof_nag", "sidequest_roof_nag", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "build_plane", "build_plane", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "plane_takeoff", "plane_takeoff", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "plane_flight", "plane_flight", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "plane_crash", "plane_crash", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "free_fall", "free_fall", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "zombie_arrive_gg", "zombie_arrive_gg", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "chair_electrocution", "chair_electrocution", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "fuel_pickup", "fuel_pickup", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "start_2", "start_2", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "pick_up_easter_egg", "pick_up_egg", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "secret_poster", "secret_poster", undefined, 100 );
    alcatraz_add_player_dialogue( "player", "quest", "find_secret", "find_secret", undefined, 100 );
}

alcatraz_add_player_dialogue( speaker, category, type, alias, response, chance )
{
    level.vox zmbvoxadd( speaker, category, type, alias, response );

    if ( isdefined( chance ) )
        add_vox_response_chance( type, chance );
}

alcatraz_audio_get_mod_type_override( impact, mod, weapon, zombie, instakill, dist, player )
{
    close_dist = 4096;
    med_dist = 15376;
    far_dist = 75625;
    a_str_mod = [];

    if ( isdefined( zombie.my_soul_catcher ) )
    {
        if ( !( isdefined( zombie.my_soul_catcher.wolf_kill_cooldown ) && zombie.my_soul_catcher.wolf_kill_cooldown ) )
        {
            if ( !( isdefined( player.soul_catcher_cooldown ) && player.soul_catcher_cooldown ) )
            {
                if ( isdefined( zombie.my_soul_catcher.souls_received ) && zombie.my_soul_catcher.souls_received > 0 )
                    a_str_mod[a_str_mod.size] = "wolf_kill";
                else if ( isdefined( zombie.my_soul_catcher.souls_received ) && zombie.my_soul_catcher.souls_received == 0 )
                {
                    if ( !( isdefined( level.wolf_encounter_vo_played ) && level.wolf_encounter_vo_played ) )
                    {
                        if ( level.soul_catchers_charged == 0 )
                            zombie.my_soul_catcher thread maps\mp\zm_alcatraz_weap_quest::first_wolf_encounter_vo();
                    }
                }
            }
        }
    }

    if ( weapon == "blundergat_zm" || weapon == "blundergat_upgraded_zm" )
        a_str_mod[a_str_mod.size] = "blundergat";

    if ( isdefined( zombie.damageweapon ) && zombie.damageweapon == "blundersplat_explosive_dart_zm" )
        a_str_mod[a_str_mod.size] = "acidgat";

    if ( isdefined( zombie.damageweapon ) && zombie.damageweapon == "bouncing_tomahawk_zm" )
        a_str_mod[a_str_mod.size] = "retriever";

    if ( isdefined( zombie.damageweapon ) && zombie.damageweapon == "upgraded_tomahawk_zm" )
        a_str_mod[a_str_mod.size] = "redeemer";

    if ( weapon == "minigun_alcatraz_zm" || weapon == "minigun_alcatraz_upgraded_zm" )
        a_str_mod[a_str_mod.size] = "death_machine";

    if ( is_headshot( weapon, impact, mod ) && dist >= far_dist )
        a_str_mod[a_str_mod.size] = "headshot";

    if ( is_explosive_damage( mod ) && weapon != "ray_gun_zm" && weapon != "ray_gun_upgraded_zm" && !( isdefined( zombie.is_on_fire ) && zombie.is_on_fire ) )
    {
        if ( !isinarray( a_str_mod, "retriever" ) && !isinarray( a_str_mod, "redeemer" ) )
        {
            if ( !instakill )
                a_str_mod[a_str_mod.size] = "explosive";
            else
                a_str_mod[a_str_mod.size] = "weapon_instakill";
        }
    }

    if ( weapon == "ray_gun_zm" || weapon == "ray_gun_upgraded_zm" )
    {
        if ( dist > far_dist )
        {
            if ( !instakill )
                a_str_mod[a_str_mod.size] = "raygun";
            else
                a_str_mod[a_str_mod.size] = "weapon_instakill";
        }
    }

    if ( instakill )
    {
        if ( mod == "MOD_MELEE" )
            a_str_mod[a_str_mod.size] = "melee_instakill";
        else
            a_str_mod[a_str_mod.size] = "weapon_instakill";
    }

    if ( mod != "MOD_MELEE" && !zombie.has_legs )
        a_str_mod[a_str_mod.size] = "crawler";

    if ( mod != "MOD_BURNED" && dist < close_dist )
        a_str_mod[a_str_mod.size] = "closekill";

    if ( a_str_mod.size == 0 )
        str_mod_final = "default";
    else if ( a_str_mod.size == 1 )
        str_mod_final = a_str_mod[0];
    else
    {
        for ( i = 0; i < a_str_mod.size; i++ )
        {
            if ( cointoss() )
                str_mod_final = a_str_mod[i];
        }

        str_mod_final = a_str_mod[randomint( a_str_mod.size )];
    }

    if ( str_mod_final == "wolf_kill" )
        player thread wolf_kill_cooldown_watcher( zombie.my_soul_catcher );

    return str_mod_final;
}

wolf_kill_cooldown_watcher( soul_catcher )
{
    self endon( "disconnect" );

    self waittill( "speaking", type );

    if ( type == "wolf_kill" )
    {
        self.soul_catcher_cooldown = 1;
        soul_catcher thread wolf_kill_cooldown();
    }
}

wolf_kill_cooldown()
{
    self.wolf_kill_cooldown = 1;
    wait 60;
    self.wolf_kill_cooldown = 0;
}

setup_conversation_vo()
{
    level.conscience_vo = [];
    level.conscience_vo["conscience_Finn_convo_1"] = [];
    level.conscience_vo["conscience_Finn_convo_1"][0] = "vox_plr_0_finn_self_2_0";
    level.conscience_vo["conscience_Finn_convo_1"][1] = "vox_plr_0_finn_self_2_1";
    level.conscience_vo["conscience_Finn_convo_1"][2] = "vox_plr_0_finn_self_2_2";
    level.conscience_vo["conscience_Finn_convo_1"][3] = "vox_plr_0_finn_self_2_3";
    level.conscience_vo["conscience_Finn_convo_1"][4] = "vox_plr_0_finn_self_2_4";
    level.conscience_vo["conscience_Finn_convo_2"] = [];
    level.conscience_vo["conscience_Finn_convo_2"][0] = "vox_plr_0_finn_self_3_0";
    level.conscience_vo["conscience_Finn_convo_2"][1] = "vox_plr_0_finn_self_3_1";
    level.conscience_vo["conscience_Finn_convo_2"][2] = "vox_plr_0_finn_self_3_2";
    level.conscience_vo["conscience_Finn_convo_2"][3] = "vox_plr_0_finn_self_3_3";
    level.conscience_vo["conscience_Finn_convo_2"][4] = "vox_plr_0_finn_self_3_4";
    level.conscience_vo["conscience_Finn_convo_2"][5] = "vox_plr_0_finn_self_3_5";
    level.conscience_vo["conscience_Sal_convo_1"] = [];
    level.conscience_vo["conscience_Sal_convo_1"][0] = "vox_plr_1_sal_self_2_0";
    level.conscience_vo["conscience_Sal_convo_1"][1] = "vox_plr_1_sal_self_2_1";
    level.conscience_vo["conscience_Sal_convo_1"][2] = "vox_plr_1_sal_self_2_2";
    level.conscience_vo["conscience_Sal_convo_1"][3] = "vox_plr_1_sal_self_2_3";
    level.conscience_vo["conscience_Sal_convo_1"][4] = "vox_plr_1_sal_self_2_4";
    level.conscience_vo["conscience_Sal_convo_1"][5] = "vox_plr_1_sal_self_2_5";
    level.conscience_vo["conscience_Sal_convo_2"] = [];
    level.conscience_vo["conscience_Sal_convo_2"][0] = "vox_plr_1_sal_self_3_0";
    level.conscience_vo["conscience_Sal_convo_2"][1] = "vox_plr_1_sal_self_3_1";
    level.conscience_vo["conscience_Sal_convo_2"][2] = "vox_plr_1_sal_self_3_2";
    level.conscience_vo["conscience_Sal_convo_2"][3] = "vox_plr_1_sal_self_3_3";
    level.conscience_vo["conscience_Sal_convo_2"][4] = "vox_plr_1_sal_self_3_4";
    level.conscience_vo["conscience_Billy_convo_1"] = [];
    level.conscience_vo["conscience_Billy_convo_1"][0] = "vox_plr_2_billy_self_2_0";
    level.conscience_vo["conscience_Billy_convo_1"][1] = "vox_plr_2_billy_self_2_1";
    level.conscience_vo["conscience_Billy_convo_1"][2] = "vox_plr_2_billy_self_2_2";
    level.conscience_vo["conscience_Billy_convo_1"][3] = "vox_plr_2_billy_self_2_3";
    level.conscience_vo["conscience_Billy_convo_1"][4] = "vox_plr_2_billy_self_2_4";
    level.conscience_vo["conscience_Billy_convo_2"] = [];
    level.conscience_vo["conscience_Billy_convo_2"][0] = "vox_plr_2_billy_self_3_0";
    level.conscience_vo["conscience_Billy_convo_2"][1] = "vox_plr_2_billy_self_3_1";
    level.conscience_vo["conscience_Billy_convo_2"][2] = "vox_plr_2_billy_self_3_2";
    level.conscience_vo["conscience_Billy_convo_2"][3] = "vox_plr_2_billy_self_3_3";
    level.conscience_vo["conscience_Billy_convo_2"][4] = "vox_plr_2_billy_self_3_4";
    level.conscience_vo["conscience_Arlington_convo_1"] = [];
    level.conscience_vo["conscience_Arlington_convo_1"][0] = "vox_plr_3_arlington_self_2_0";
    level.conscience_vo["conscience_Arlington_convo_1"][1] = "vox_plr_3_arlington_self_2_2";
    level.conscience_vo["conscience_Arlington_convo_1"][2] = "vox_plr_3_arlington_self_2_3";
    level.conscience_vo["conscience_Arlington_convo_1"][3] = "vox_plr_3_arlington_self_2_4";
    level.conscience_vo["conscience_Arlington_convo_1"][4] = "vox_plr_3_arlington_self_2_5";
    level.conscience_vo["conscience_Arlington_convo_2"] = [];
    level.conscience_vo["conscience_Arlington_convo_2"][0] = "vox_plr_3_arlington_self_3_0";
    level.conscience_vo["conscience_Arlington_convo_2"][1] = "vox_plr_3_arlington_self_3_1";
    level.conscience_vo["conscience_Arlington_convo_2"][2] = "vox_plr_3_arlington_self_3_2";
    level.conscience_vo["conscience_Arlington_convo_2"][3] = "vox_plr_3_arlington_self_3_3";
    level.conscience_vo["conscience_Arlington_convo_2"][4] = "vox_plr_3_arlington_self_3_4";
}

alcatraz_custom_zombie_oh_shit_vox()
{
    self endon( "death_or_disconnect" );

    while ( true )
    {
        wait 1;

        if ( isdefined( self.oh_shit_vo_cooldown ) && self.oh_shit_vo_cooldown )
            continue;

        players = get_players();
        zombs = get_round_enemy_array();

        if ( players.size <= 1 )
        {
            n_distance = 250;
            n_zombies = 5;
            n_chance = 30;
            n_cooldown_time = 20;
        }
        else
        {
            n_distance = 250;
            n_zombies = 5;
            n_chance = 30;
            n_cooldown_time = 15;
        }

        close_zombs = 0;

        for ( i = 0; i < zombs.size; i++ )
        {
            if ( isdefined( zombs[i].favoriteenemy ) && zombs[i].favoriteenemy == self || !isdefined( zombs[i].favoriteenemy ) )
            {
                if ( distancesquared( zombs[i].origin, self.origin ) < n_distance * n_distance )
                    close_zombs++;
            }
        }

        if ( close_zombs >= n_zombies )
        {
            if ( randomint( 100 ) < n_chance && !( isdefined( self.isonbus ) && self.isonbus ) )
            {
                self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "oh_shit" );
                self thread global_oh_shit_cooldown_timer( n_cooldown_time );
                wait( n_cooldown_time );
            }
        }
    }
}

global_oh_shit_cooldown_timer( n_cooldown_time )
{
    self endon( "disconnect" );
    self.oh_shit_vo_cooldown = 1;
    wait( n_cooldown_time );
    self.oh_shit_vo_cooldown = 0;
}

alcatraz_custom_crawler_spawned_vo()
{
    self endon( "death" );

    if ( isdefined( self.a.gib_ref ) && isalive( self ) )
    {
        if ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "right_leg" || self.a.gib_ref == "left_leg" )
        {
            if ( isdefined( self.attacker ) && isplayer( self.attacker ) )
            {
                if ( isdefined( self.attacker.crawler_created_vo_cooldown ) && self.attacker.crawler_created_vo_cooldown )
                    return;

                rand = randomintrange( 0, 100 );

                if ( rand < 15 )
                {
                    self.attacker maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "crawl_spawn" );
                    self.attacker thread crawler_created_vo_cooldown();
                }
            }
        }
    }
}

crawler_created_vo_cooldown()
{
    self endon( "disconnect" );
    self.crawler_created_vo_cooldown = 1;
    wait 30;
    self.crawler_created_vo_cooldown = 0;
}

alcatraz_first_magic_box_seen_vo()
{
    flag_wait( "start_zombie_round_logic" );
    magicbox = level.chests[level.chest_index];
    a_players = getplayers();

    foreach ( player in a_players )
        player thread wait_and_play_first_magic_box_seen_vo( magicbox.unitrigger_stub );
}

wait_and_play_first_magic_box_seen_vo( struct )
{
    self endon( "disconnect" );
    level endon( "first_maigc_box_discovered" );

    while ( true )
    {
        if ( distancesquared( self.origin, struct.origin ) < 40000 )
        {
            if ( self is_player_looking_at( struct.origin, 0.25 ) )
            {
                if ( !( isdefined( self.dontspeak ) && self.dontspeak ) )
                {
                    self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "discover_box" );
                    level notify( "first_maigc_box_discovered" );
                    break;
                }
            }
        }

        wait 0.1;
    }
}

alcatraz_audio_custom_weapon_check( weapon, magic_box )
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( isdefined( magic_box ) && magic_box )
    {
        type = self maps\mp\zombies\_zm_weapons::weapon_type_check( weapon );
        return type;
    }

    if ( issubstr( weapon, "upgraded" ) )
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "wpck_pap" );
    else if ( level.wallbuys_purchased == 0 )
    {
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "discover_wall_buy" );
        level.wallbuys_purchased++;
    }
    else
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "generic_wall_buy" );

    return "crappy";
}

brutus_spawn_vo_watcher()
{
    level.total_brutuses_spawned = 0;

    while ( true )
    {
        level waittill( "brutus_spawned", ai_brutus );

        if ( !isdefined( ai_brutus ) )
            continue;

        if ( isdefined( level.brutus_spawn_vo_cooldown ) && level.brutus_spawn_vo_cooldown )
            continue;

        ai_brutus thread brutus_reaction_vo_watcher();
        ai_brutus thread brutus_helmet_pop_vo_watcher();

        if ( level.total_brutuses_spawned == 0 )
            str_vo_category = "brutus_encounter";
        else
            str_vo_category = "brutus_arrival";

        wait 3.0;

        if ( !isalive( ai_brutus ) )
            continue;

        a_players = getplayers();
        a_closest = get_array_of_closest( ai_brutus.origin, a_players );

        for ( i = 0; i < a_closest.size; i++ )
        {
            if ( !( isdefined( a_closest[i].dontspeak ) && a_closest[i].dontspeak ) )
            {
                if ( isalive( a_closest[i] ) && isalive( ai_brutus ) )
                {
                    a_closest[i] thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", str_vo_category );
                    level thread brutus_spawn_vo_cooldown();
                }
            }
        }
    }
}

brutus_spawn_vo_cooldown()
{
    level.brutus_spawn_vo_cooldown = 1;
    wait 30;
    level.brutus_spawn_vo_cooldown = 0;
}

brutus_reaction_vo_watcher()
{
    self endon( "death" );
    level endon( "restart_brutus_reaction_vo_watcher" );

    while ( isalive( self ) )
    {
        wait( randomfloatrange( 20, 40 ) );
        a_players = getplayers();
        a_closest = get_array_of_closest( self.origin, a_players );

        for ( i = 0; i < a_closest.size; i++ )
        {
            if ( !( isdefined( a_closest[i].dontspeak ) && a_closest[i].dontspeak ) )
            {
                if ( distancesquared( a_closest[i].origin, self.origin ) < 1000000 )
                    a_closest[i] thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "brutus_reaction" );
            }
        }
    }
}

brutus_helmet_pop_vo_watcher()
{
    self endon( "death" );

    level waittill( "brutus_helmet_removed", player );

    wait 3.0;

    if ( isalive( player ) )
        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "brutus_reaction" );

    level notify( "restart_brutus_reaction_vo_watcher" );
    self thread brutus_reaction_vo_watcher();
}

brutus_killed_vo_watcher()
{
    while ( true )
    {
        level waittill( "brutus_killed", player );

        wait 5.0;

        if ( isalive( player ) )
            player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "brutus_defeated" );
    }
}

easter_egg_song_vo( player )
{
    wait 3.5;

    if ( isalive( player ) )
        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "quest", "find_secret" );
    else
    {
        while ( true )
        {
            a_players = getplayers();

            foreach ( player in a_players )
            {
                if ( isalive( player ) )
                {
                    if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "quest", "find_secret" );
                }
            }
        }

        wait 0.1;
    }
}

player_portal_clue_vo()
{
    self endon( "death" );
    self endon( "disconnect" );
    flag_wait( "afterlife_start_over" );
    wait 1;

    while ( true )
    {
        self waittill( "player_fake_corpse_created" );

        self.e_afterlife_corpse waittill( "player_revived", e_reviver );

        if ( self == e_reviver && !level.someone_has_visited_nml )
        {
            wait 3;
            self do_player_general_vox( "general", "portal_clue", undefined, 100 );
            return;
        }

        wait 0.1;
    }
}

setup_personality_character_exerts()
{
    level.exert_sounds[1]["burp"][0] = "vox_plr_0_exert_burp_0";
    level.exert_sounds[1]["burp"][1] = "vox_plr_0_exert_burp_1";
    level.exert_sounds[1]["burp"][2] = "vox_plr_0_exert_burp_2";
    level.exert_sounds[1]["burp"][3] = "vox_plr_0_exert_burp_3";
    level.exert_sounds[1]["burp"][4] = "vox_plr_0_exert_burp_4";
    level.exert_sounds[1]["burp"][5] = "vox_plr_0_exert_burp_5";
    level.exert_sounds[1]["burp"][6] = "vox_plr_0_exert_burp_6";
    level.exert_sounds[2]["burp"][0] = "vox_plr_1_exert_burp_0";
    level.exert_sounds[2]["burp"][1] = "vox_plr_1_exert_burp_1";
    level.exert_sounds[2]["burp"][2] = "vox_plr_1_exert_burp_2";
    level.exert_sounds[2]["burp"][3] = "vox_plr_1_exert_burp_3";
    level.exert_sounds[3]["burp"][0] = "vox_plr_2_exert_burp_0";
    level.exert_sounds[3]["burp"][1] = "vox_plr_2_exert_burp_1";
    level.exert_sounds[3]["burp"][2] = "vox_plr_2_exert_burp_2";
    level.exert_sounds[3]["burp"][3] = "vox_plr_2_exert_burp_3";
    level.exert_sounds[3]["burp"][4] = "vox_plr_2_exert_burp_4";
    level.exert_sounds[3]["burp"][5] = "vox_plr_2_exert_burp_5";
    level.exert_sounds[3]["burp"][6] = "vox_plr_2_exert_burp_6";
    level.exert_sounds[4]["burp"][0] = "vox_plr_3_exert_burp_0";
    level.exert_sounds[4]["burp"][1] = "vox_plr_3_exert_burp_1";
    level.exert_sounds[4]["burp"][2] = "vox_plr_3_exert_burp_2";
    level.exert_sounds[4]["burp"][3] = "vox_plr_3_exert_burp_3";
    level.exert_sounds[4]["burp"][4] = "vox_plr_3_exert_burp_4";
    level.exert_sounds[4]["burp"][5] = "vox_plr_3_exert_burp_5";
    level.exert_sounds[4]["burp"][6] = "vox_plr_3_exert_burp_6";
    level.exert_sounds[1]["hitmed"][0] = "vox_plr_0_exert_pain_medium_0";
    level.exert_sounds[1]["hitmed"][1] = "vox_plr_0_exert_pain_medium_1";
    level.exert_sounds[1]["hitmed"][2] = "vox_plr_0_exert_pain_medium_2";
    level.exert_sounds[1]["hitmed"][3] = "vox_plr_0_exert_pain_medium_3";
    level.exert_sounds[2]["hitmed"][0] = "vox_plr_1_exert_pain_medium_0";
    level.exert_sounds[2]["hitmed"][1] = "vox_plr_1_exert_pain_medium_1";
    level.exert_sounds[2]["hitmed"][2] = "vox_plr_1_exert_pain_medium_2";
    level.exert_sounds[2]["hitmed"][3] = "vox_plr_1_exert_pain_medium_3";
    level.exert_sounds[3]["hitmed"][0] = "vox_plr_2_exert_pain_medium_0";
    level.exert_sounds[3]["hitmed"][1] = "vox_plr_2_exert_pain_medium_1";
    level.exert_sounds[3]["hitmed"][2] = "vox_plr_2_exert_pain_medium_2";
    level.exert_sounds[3]["hitmed"][3] = "vox_plr_2_exert_pain_medium_3";
    level.exert_sounds[4]["hitmed"][0] = "vox_plr_3_exert_pain_medium_0";
    level.exert_sounds[4]["hitmed"][1] = "vox_plr_3_exert_pain_medium_1";
    level.exert_sounds[4]["hitmed"][2] = "vox_plr_3_exert_pain_medium_2";
    level.exert_sounds[4]["hitmed"][3] = "vox_plr_3_exert_pain_medium_3";
    level.exert_sounds[1]["hitlrg"][0] = "vox_plr_0_exert_pain_high_0";
    level.exert_sounds[1]["hitlrg"][1] = "vox_plr_0_exert_pain_high_1";
    level.exert_sounds[1]["hitlrg"][2] = "vox_plr_0_exert_pain_high_2";
    level.exert_sounds[1]["hitlrg"][3] = "vox_plr_0_exert_pain_high_3";
    level.exert_sounds[2]["hitlrg"][0] = "vox_plr_1_exert_pain_high_0";
    level.exert_sounds[2]["hitlrg"][1] = "vox_plr_1_exert_pain_high_1";
    level.exert_sounds[2]["hitlrg"][2] = "vox_plr_1_exert_pain_high_2";
    level.exert_sounds[2]["hitlrg"][3] = "vox_plr_1_exert_pain_high_3";
    level.exert_sounds[3]["hitlrg"][0] = "vox_plr_2_exert_pain_high_0";
    level.exert_sounds[3]["hitlrg"][1] = "vox_plr_2_exert_pain_high_1";
    level.exert_sounds[3]["hitlrg"][2] = "vox_plr_2_exert_pain_high_2";
    level.exert_sounds[3]["hitlrg"][3] = "vox_plr_2_exert_pain_high_3";
    level.exert_sounds[4]["hitlrg"][0] = "vox_plr_3_exert_pain_high_0";
    level.exert_sounds[4]["hitlrg"][1] = "vox_plr_3_exert_pain_high_1";
    level.exert_sounds[4]["hitlrg"][2] = "vox_plr_3_exert_pain_high_2";
    level.exert_sounds[4]["hitlrg"][3] = "vox_plr_3_exert_pain_high_3";
}

alcatraz_audio_custom_response_line( player, index, category, type )
{
    if ( type == "revive_up" )
        player thread play_vo_category_on_closest_player( "general", "revive_player" );
    else if ( type == "headshot" )
    {
        if ( cointoss() )
            player thread play_vo_category_on_closest_player( "kill", "headshot_respond_to_plr_" + player.characterindex );
        else
            player thread play_vo_category_on_closest_player( "kill", "headshot_respond_generic" );
    }
    else if ( type == "oh_shit" )
    {
        player thread play_vo_category_on_closest_player( "general", "surrounded_respond_to_plr_" + player.characterindex );
        player thread global_oh_shit_cooldown_timer( 15 );
    }
}

play_vo_category_on_closest_player( category, type )
{
    a_players = getplayers();

    if ( a_players.size <= 1 )
        return;

    arrayremovevalue( a_players, self );
    a_closest = arraysort( a_players, self.origin, 1 );

    if ( distancesquared( self.origin, a_closest[0].origin ) <= 250000 )
    {
        if ( isalive( a_closest[0] ) )
            a_closest[0] maps\mp\zombies\_zm_audio::create_and_play_dialog( category, type );
    }
}

check_for_special_weapon_limit_exist( weapon )
{
    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        if ( weapon == "ray_gun_zm" )
        {
            if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) || maps\mp\zombies\_zm_afterlife::is_weapon_available_in_afterlife_corpse( "raygun_mark2_zm", self ) )
                return false;
        }

        if ( weapon == "raygun_mark2_zm" )
        {
            if ( self has_weapon_or_upgrade( "ray_gun_zm" ) || maps\mp\zombies\_zm_afterlife::is_weapon_available_in_afterlife_corpse( "ray_gun_zm", self ) )
                return false;

            if ( randomint( 100 ) >= 33 )
                return false;
        }
    }

    if ( weapon != "blundergat_zm" && weapon != "minigun_alcatraz_zm" )
        return true;

    players = get_players();
    count = 0;

    if ( weapon == "blundergat_zm" )
    {
        if ( self maps\mp\zombies\_zm_weapons::has_weapon_or_upgrade( "blundersplat_zm" ) )
            return false;

        if ( self afterlife_weapon_limit_check( "blundergat_zm" ) )
            return false;

        limit = level.limited_weapons["blundergat_zm"];
    }
    else
    {
        if ( self afterlife_weapon_limit_check( "minigun_alcatraz_zm" ) )
            return false;

        limit = level.limited_weapons["minigun_alcatraz_zm"];
    }

    for ( i = 0; i < players.size; i++ )
    {
        if ( weapon == "blundergat_zm" )
        {
            if ( players[i] has_weapon_or_upgrade( "blundersplat_zm" ) || isdefined( players[i].is_pack_splatting ) && players[i].is_pack_splatting )
            {
                count++;
                continue;
            }
        }

        if ( players[i] afterlife_weapon_limit_check( weapon ) )
            count++;
    }

    if ( count >= limit )
        return false;

    return true;
}

afterlife_weapon_limit_check( limited_weapon )
{
    if ( isdefined( self.afterlife ) && self.afterlife )
    {
        if ( limited_weapon == "blundergat_zm" )
        {
            foreach ( weapon in self.loadout.weapons )
            {
                if ( weapon == "blundergat_zm" || weapon == "blundergat_upgraded_zm" || weapon == "blundersplat_zm" || weapon == "blundersplat_upgraded_zm" )
                    return true;
            }
        }
        else if ( limited_weapon == "minigun_alcatraz_zm" )
        {
            foreach ( weapon in self.loadout.weapons )
            {
                if ( weapon == "minigun_alcatraz_zm" || weapon == "minigun_alcatraz_upgraded_zm" )
                    return true;
            }
        }
    }

    return false;
}

door_rumble_on_buy()
{
    self setclientfieldtoplayer( "rumble_door_open", 1 );
    wait_network_frame();
    self setclientfieldtoplayer( "rumble_door_open", 0 );
}
