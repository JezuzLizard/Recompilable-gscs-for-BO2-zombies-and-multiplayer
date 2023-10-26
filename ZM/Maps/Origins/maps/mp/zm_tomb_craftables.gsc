// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zm_tomb_main_quest;
#include maps\mp\zm_tomb_vo;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_ai_quadrotor;
#include maps\mp\zombies\_zm_equipment;

randomize_craftable_spawns()
{
    a_randomized_craftables = array( "gramophone_vinyl_ice", "gramophone_vinyl_air", "gramophone_vinyl_elec", "gramophone_vinyl_fire", "gramophone_vinyl_master", "gramophone_vinyl_player" );

    foreach ( str_craftable in a_randomized_craftables )
    {
        s_original_pos = getstruct( str_craftable, "targetname" );
        a_alt_locations = getstructarray( str_craftable + "_alt", "targetname" );
        n_loc_index = randomintrange( 0, a_alt_locations.size + 1 );

        if ( n_loc_index == a_alt_locations.size )
            continue;
        else
        {
            s_original_pos.origin = a_alt_locations[n_loc_index].origin;
            s_original_pos.angles = a_alt_locations[n_loc_index].angles;
        }
    }
}

init_craftables()
{
    precachemodel( "p6_zm_tm_quadrotor_stand" );
    flag_init( "quadrotor_cooling_down" );
    level.craftable_piece_count = 4;
    flag_init( "any_crystal_picked_up" );
    flag_init( "staff_air_zm_enabled" );
    flag_init( "staff_fire_zm_enabled" );
    flag_init( "staff_lightning_zm_enabled" );
    flag_init( "staff_water_zm_enabled" );
    register_clientfields();
    add_zombie_craftable( "equip_dieseldrone_zm", &"ZM_TOMB_CRQ", &"ZM_TOMB_CRQ", &"ZM_TOMB_TQ", ::onfullycrafted_quadrotor, 1 );
    add_zombie_craftable_vox_category( "equip_dieseldrone_zm", "build_dd" );
    make_zombie_craftable_open( "equip_dieseldrone_zm", "veh_t6_dlc_zm_quadrotor", ( 0, 0, 0 ), ( 0, -4, 10 ) );
    add_zombie_craftable( "tomb_shield_zm", &"ZM_TOMB_CRRI", undefined, &"ZOMBIE_BOUGHT_RIOT", undefined, 1 );
    add_zombie_craftable_vox_category( "tomb_shield_zm", "build_zs" );
    make_zombie_craftable_open( "tomb_shield_zm", "t6_wpn_zmb_shield_dlc4_dmg0_world", vectorscale( ( 0, -1, 0 ), 90.0 ), ( 0, 0, level.riotshield_placement_zoffset ) );
    add_zombie_craftable( "elemental_staff_fire", &"ZM_TOMB_CRF", &"ZM_TOMB_INS", &"ZM_TOMB_BOF", ::staff_fire_fullycrafted, 1 );
    add_zombie_craftable_vox_category( "elemental_staff_fire", "fire_staff" );
    add_zombie_craftable( "elemental_staff_air", &"ZM_TOMB_CRA", &"ZM_TOMB_INS", &"ZM_TOMB_BOA", ::staff_air_fullycrafted, 1 );
    add_zombie_craftable_vox_category( "elemental_staff_air", "air_staff" );
    add_zombie_craftable( "elemental_staff_lightning", &"ZM_TOMB_CRL", &"ZM_TOMB_INS", &"ZM_TOMB_BOL", ::staff_lightning_fullycrafted, 1 );
    add_zombie_craftable_vox_category( "elemental_staff_lightning", "light_staff" );
    add_zombie_craftable( "elemental_staff_water", &"ZM_TOMB_CRW", &"ZM_TOMB_INS", &"ZM_TOMB_BOW", ::staff_water_fullycrafted, 1 );
    add_zombie_craftable_vox_category( "elemental_staff_water", "ice_staff" );
    add_zombie_craftable( "gramophone", &"ZM_TOMB_CRAFT_GRAMOPHONE", &"ZM_TOMB_CRAFT_GRAMOPHONE", &"ZM_TOMB_BOUGHT_GRAMOPHONE", undefined, 0 );
    add_zombie_craftable_vox_category( "gramophone", "gramophone" );
    level.zombie_craftable_persistent_weapon = ::tomb_check_crafted_weapon_persistence;
    level.custom_craftable_validation = ::tomb_custom_craftable_validation;
    level.zombie_custom_equipment_setup = ::setup_quadrotor_purchase;
    level thread hide_staff_model();
    level.quadrotor_status = spawnstruct();
    level.quadrotor_status.crafted = 0;
    level.quadrotor_status.picked_up = 0;
    level.num_staffpieces_picked_up = [];
    level.n_staffs_crafted = 0;
}

add_craftable_cheat( craftable )
{
/#
    if ( !isdefined( level.cheat_craftables ) )
        level.cheat_craftables = [];

    foreach ( s_piece in craftable.a_piecestubs )
    {
        id_string = undefined;
        client_field_val = undefined;

        if ( isdefined( s_piece.client_field_id ) )
        {
            id_string = s_piece.client_field_id;
            client_field_val = id_string;
        }
        else if ( isdefined( s_piece.client_field_state ) )
        {
            id_string = "gem";
            client_field_val = s_piece.client_field_state;
        }
        else
            continue;

        tokens = strtok( id_string, "_" );
        display_string = "piece";

        foreach ( token in tokens )
        {
            if ( token != "piece" && token != "staff" && token != "zm" )
                display_string = display_string + "_" + token;
        }

        level.cheat_craftables["" + client_field_val] = s_piece;
        adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Craftables:1/" + craftable.name + "/" + display_string + "\" \"give_craftable " + client_field_val + "\"\n" );
        s_piece.waste = "waste";
    }

    flag_wait( "start_zombie_round_logic" );

    foreach ( s_piece in craftable.a_piecestubs )
    {
        s_piece craftable_waittill_spawned();
        s_piece.piecespawn.model thread puzzle_debug_position( "C", vectorscale( ( 0, 1, 0 ), 255.0 ), undefined, "show_craftable_locations" );
    }
#/
}

autocraft_staffs()
{
    setdvar( "autocraft_staffs", "off" );
/#
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Craftables:1/Give All Staff Pieces:0\" \"autocraft_staffs on\"\n" );
#/
    while ( getdvar( _hash_373B6254 ) != "on" )
        wait_network_frame();

    flag_wait( "start_zombie_round_logic" );
    keys = getarraykeys( level.cheat_craftables );
    a_players = getplayers();

    foreach ( key in keys )
    {
        if ( issubstr( key, "staff" ) || issubstr( key, "record" ) )
        {
            s_piece = level.cheat_craftables[key];

            if ( isdefined( s_piece.piecespawn ) )
                a_players[0] maps\mp\zombies\_zm_craftables::player_take_piece( s_piece.piecespawn );
        }
    }

    for ( i = 1; i <= 4; i++ )
    {
        level notify( "player_teleported", a_players[0], i );
        wait_network_frame();
        piece_spawn = level.cheat_craftables["" + i].piecespawn;

        if ( isdefined( piece_spawn ) )
        {
            if ( isdefined( a_players[i - 1] ) )
            {
                a_players[i - 1] maps\mp\zombies\_zm_craftables::player_take_piece( piece_spawn );
                wait_network_frame();
            }
        }

        wait_network_frame();
    }
}

run_craftables_devgui()
{
/#
    level thread autocraft_staffs();
    setdvar( "give_craftable", "" );

    while ( true )
    {
        craftable_id = getdvar( _hash_817E2753 );

        if ( craftable_id != "" )
        {
            piece_spawn = level.cheat_craftables[craftable_id].piecespawn;

            if ( isdefined( piece_spawn ) )
            {
                players = getplayers();
                players[0] maps\mp\zombies\_zm_craftables::player_take_piece( piece_spawn );
            }

            setdvar( "give_craftable", "" );
        }

        wait 0.05;
    }
#/
}

include_craftables()
{
    level thread run_craftables_devgui();
    craftable_name = "equip_dieseldrone_zm";
    quadrotor_body = generate_zombie_craftable_piece( craftable_name, "body", "veh_t6_dlc_zm_quad_piece_body", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_quadrotor_zm_body", 1, "build_dd" );
    quadrotor_brain = generate_zombie_craftable_piece( craftable_name, "brain", "veh_t6_dlc_zm_quad_piece_brain", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_quadrotor_zm_brain", 1, "build_dd_brain" );
    quadrotor_engine = generate_zombie_craftable_piece( craftable_name, "engine", "veh_t6_dlc_zm_quad_piece_engine", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_quadrotor_zm_engine", 1, "build_dd" );
    quadrotor = spawnstruct();
    quadrotor.name = craftable_name;
    quadrotor add_craftable_piece( quadrotor_body );
    quadrotor add_craftable_piece( quadrotor_brain );
    quadrotor add_craftable_piece( quadrotor_engine );
    quadrotor.triggerthink = ::quadrotorcraftable;
    include_zombie_craftable( quadrotor );
    level thread add_craftable_cheat( quadrotor );
    craftable_name = "tomb_shield_zm";
    riotshield_top = generate_zombie_craftable_piece( craftable_name, "top", "t6_wpn_zmb_shield_dlc4_top", 48, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_dolly", 1, "build_zs" );
    riotshield_door = generate_zombie_craftable_piece( craftable_name, "door", "t6_wpn_zmb_shield_dlc4_door", 48, 15, 25, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_door", 1, "build_zs" );
    riotshield_bracket = generate_zombie_craftable_piece( craftable_name, "bracket", "t6_wpn_zmb_shield_dlc4_bracket", 48, 15, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_clamp", 1, "build_zs" );
    riotshield = spawnstruct();
    riotshield.name = craftable_name;
    riotshield add_craftable_piece( riotshield_top );
    riotshield add_craftable_piece( riotshield_door );
    riotshield add_craftable_piece( riotshield_bracket );
    riotshield.onbuyweapon = ::onbuyweapon_riotshield;
    riotshield.triggerthink = ::riotshieldcraftable;
    include_craftable( riotshield );
    level thread add_craftable_cheat( riotshield );
    craftable_name = "elemental_staff_air";
    staff_air_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_air_part", 48, 64, 0, undefined, ::onpickup_aircrystal, ::ondrop_aircrystal, undefined, undefined, undefined, undefined, 2, 0, "crystal", 1 );
    staff_air_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_air_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_air", 1, "staff_part" );
    staff_air_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_air_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_air", 1, "staff_part" );
    staff_air_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_air", 1, "staff_part" );
    staff = spawnstruct();
    staff.name = craftable_name;
    staff add_craftable_piece( staff_air_gem );
    staff add_craftable_piece( staff_air_upper_staff );
    staff add_craftable_piece( staff_air_middle_staff );
    staff add_craftable_piece( staff_air_lower_staff );
    staff.triggerthink = ::staffcraftable_air;
    staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
    include_zombie_craftable( staff );
    level thread add_craftable_cheat( staff );
    count_staff_piece_pickup( array( staff_air_upper_staff, staff_air_middle_staff, staff_air_lower_staff ) );
    craftable_name = "elemental_staff_fire";
    staff_fire_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_fire_part", 48, 64, 0, undefined, ::onpickup_firecrystal, ::ondrop_firecrystal, undefined, undefined, undefined, undefined, 1, 0, "crystal", 1 );
    staff_fire_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_fire_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_fire", 1, "staff_part" );
    staff_fire_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_fire_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_fire", 1, "staff_part" );
    staff_fire_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 64, 128, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_fire", 1, "staff_part" );
    level thread maps\mp\zm_tomb_main_quest::staff_mechz_drop_pieces( staff_fire_lower_staff );
    level thread maps\mp\zm_tomb_main_quest::staff_biplane_drop_pieces( array( staff_fire_middle_staff ) );
    level thread maps\mp\zm_tomb_main_quest::staff_unlock_with_zone_capture( staff_fire_upper_staff );
    staff = spawnstruct();
    staff.name = craftable_name;
    staff add_craftable_piece( staff_fire_gem );
    staff add_craftable_piece( staff_fire_upper_staff );
    staff add_craftable_piece( staff_fire_middle_staff );
    staff add_craftable_piece( staff_fire_lower_staff );
    staff.triggerthink = ::staffcraftable_fire;
    staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
    include_zombie_craftable( staff );
    level thread add_craftable_cheat( staff );
    count_staff_piece_pickup( array( staff_fire_upper_staff, staff_fire_middle_staff, staff_fire_lower_staff ) );
    craftable_name = "elemental_staff_lightning";
    staff_lightning_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_bolt_part", 48, 64, 0, undefined, ::onpickup_lightningcrystal, ::ondrop_lightningcrystal, undefined, undefined, undefined, undefined, 3, 0, "crystal", 1 );
    staff_lightning_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_lightning_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_lightning", 1, "staff_part" );
    staff_lightning_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_bolt_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_lightning", 1, "staff_part" );
    staff_lightning_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_lightning", 1, "staff_part" );
    staff = spawnstruct();
    staff.name = craftable_name;
    staff add_craftable_piece( staff_lightning_gem );
    staff add_craftable_piece( staff_lightning_upper_staff );
    staff add_craftable_piece( staff_lightning_middle_staff );
    staff add_craftable_piece( staff_lightning_lower_staff );
    staff.triggerthink = ::staffcraftable_lightning;
    staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
    include_zombie_craftable( staff );
    level thread add_craftable_cheat( staff );
    count_staff_piece_pickup( array( staff_lightning_upper_staff, staff_lightning_middle_staff, staff_lightning_lower_staff ) );
    craftable_name = "elemental_staff_water";
    staff_water_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_water_part", 48, 64, 0, undefined, ::onpickup_watercrystal, ::ondrop_watercrystal, undefined, undefined, undefined, undefined, 4, 0, "crystal", 1 );
    staff_water_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_water_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_water", 1, "staff_part" );
    staff_water_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_water_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_water", 1, "staff_part" );
    staff_water_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_water", 1, "staff_part" );
    a_ice_staff_parts = array( staff_water_lower_staff, staff_water_middle_staff, staff_water_upper_staff );
    level thread maps\mp\zm_tomb_main_quest::staff_ice_dig_pieces( a_ice_staff_parts );
    staff = spawnstruct();
    staff.name = craftable_name;
    staff add_craftable_piece( staff_water_gem );
    staff add_craftable_piece( staff_water_upper_staff );
    staff add_craftable_piece( staff_water_middle_staff );
    staff add_craftable_piece( staff_water_lower_staff );
    staff.triggerthink = ::staffcraftable_water;
    staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
    include_zombie_craftable( staff );
    level thread add_craftable_cheat( staff );
    count_staff_piece_pickup( array( staff_water_upper_staff, staff_water_middle_staff, staff_water_lower_staff ) );
    craftable_name = "gramophone";
    vinyl_pickup_player = vinyl_add_pickup( craftable_name, "vinyl_player", "p6_zm_tm_gramophone", "piece_record_zm_player", undefined, "gramophone" );
    vinyl_pickup_master = vinyl_add_pickup( craftable_name, "vinyl_master", "p6_zm_tm_record_master", "piece_record_zm_vinyl_master", undefined, "record" );
    vinyl_pickup_air = vinyl_add_pickup( craftable_name, "vinyl_air", "p6_zm_tm_record_wind", "piece_record_zm_vinyl_air", "quest_state2", "record" );
    vinyl_pickup_ice = vinyl_add_pickup( craftable_name, "vinyl_ice", "p6_zm_tm_record_ice", "piece_record_zm_vinyl_water", "quest_state4", "record" );
    vinyl_pickup_fire = vinyl_add_pickup( craftable_name, "vinyl_fire", "p6_zm_tm_record_fire", "piece_record_zm_vinyl_fire", "quest_state1", "record" );
    vinyl_pickup_elec = vinyl_add_pickup( craftable_name, "vinyl_elec", "p6_zm_tm_record_lightning", "piece_record_zm_vinyl_lightning", "quest_state3", "record" );
    vinyl_pickup_player.sam_line = "gramophone_found";
    vinyl_pickup_master.sam_line = "master_found";
    vinyl_pickup_air.sam_line = "first_record_found";
    vinyl_pickup_ice.sam_line = "first_record_found";
    vinyl_pickup_fire.sam_line = "first_record_found";
    vinyl_pickup_elec.sam_line = "first_record_found";
    level thread maps\mp\zm_tomb_vo::watch_one_shot_samantha_line( "vox_sam_1st_record_found_0", "first_record_found" );
    level thread maps\mp\zm_tomb_vo::watch_one_shot_samantha_line( "vox_sam_gramophone_found_0", "gramophone_found" );
    level thread maps\mp\zm_tomb_vo::watch_one_shot_samantha_line( "vox_sam_master_found_0", "master_found" );
    gramophone = spawnstruct();
    gramophone.name = craftable_name;
    gramophone add_craftable_piece( vinyl_pickup_player );
    gramophone add_craftable_piece( vinyl_pickup_master );
    gramophone add_craftable_piece( vinyl_pickup_air );
    gramophone add_craftable_piece( vinyl_pickup_ice );
    gramophone add_craftable_piece( vinyl_pickup_fire );
    gramophone add_craftable_piece( vinyl_pickup_elec );
    gramophone.triggerthink = ::gramophonecraftable;
    include_zombie_craftable( gramophone );
    level thread add_craftable_cheat( gramophone );
    staff_fire_gem thread watch_part_pickup( "quest_state1", 2 );
    staff_air_gem thread watch_part_pickup( "quest_state2", 2 );
    staff_lightning_gem thread watch_part_pickup( "quest_state3", 2 );
    staff_water_gem thread watch_part_pickup( "quest_state4", 2 );
    staff_fire_gem thread staff_crystal_wait_for_teleport( 1 );
    staff_air_gem thread staff_crystal_wait_for_teleport( 2 );
    staff_lightning_gem thread staff_crystal_wait_for_teleport( 3 );
    staff_water_gem thread staff_crystal_wait_for_teleport( 4 );
    level thread maps\mp\zm_tomb_vo::staff_craft_vo();
    level thread maps\mp\zm_tomb_vo::samantha_discourage_think();
    level thread maps\mp\zm_tomb_vo::samantha_encourage_think();
    level thread craftable_add_glow_fx();
}

register_clientfields()
{
    bits = 1;
    registerclientfield( "world", "piece_quadrotor_zm_body", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_quadrotor_zm_brain", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_quadrotor_zm_engine", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_riotshield_dolly", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_riotshield_door", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_riotshield_clamp", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_gem_air", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_ustaff_air", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_mstaff_air", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_lstaff_air", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_gem_fire", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_ustaff_fire", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_mstaff_fire", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_lstaff_fire", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_gem_lightning", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_ustaff_lightning", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_mstaff_lightning", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_lstaff_lightning", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_gem_water", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_ustaff_water", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_mstaff_water", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_staff_zm_lstaff_water", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_record_zm_player", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_record_zm_vinyl_master", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_record_zm_vinyl_air", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_record_zm_vinyl_water", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_record_zm_vinyl_fire", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "piece_record_zm_vinyl_lightning", 14000, bits, "int", undefined, 0 );
    registerclientfield( "scriptmover", "element_glow_fx", 14000, 4, "int", undefined, 0 );
    registerclientfield( "scriptmover", "bryce_cake", 14000, 2, "int", undefined, 0 );
    registerclientfield( "scriptmover", "switch_spark", 14000, 1, "int", undefined, 0 );
    bits = getminbitcountfornum( 5 );
    registerclientfield( "world", "staff_player1", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "staff_player2", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "staff_player3", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "staff_player4", 14000, bits, "int", undefined, 0 );
    bits = getminbitcountfornum( 5 );
    registerclientfield( "world", "quest_state1", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "quest_state2", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "quest_state3", 14000, bits, "int", undefined, 0 );
    registerclientfield( "world", "quest_state4", 14000, bits, "int", undefined, 0 );
    registerclientfield( "toplayer", "sndMudSlow", 14000, 1, "int" );
}

craftable_add_glow_fx()
{
    flag_wait( "start_zombie_round_logic" );

    foreach ( s_craftable in level.zombie_include_craftables )
    {
        if ( !issubstr( s_craftable.name, "elemental_staff" ) )
            continue;

        n_elem = 0;

        if ( issubstr( s_craftable.name, "fire" ) )
            n_elem = 1;
        else if ( issubstr( s_craftable.name, "air" ) )
            n_elem = 2;
        else if ( issubstr( s_craftable.name, "lightning" ) )
            n_elem = 3;
        else if ( issubstr( s_craftable.name, "water" ) )
            n_elem = 4;
        else
        {
/#
            iprintlnbold( "ERROR: Unknown staff element type in craftable_add_glow_fx: " + s_craftable.name );
#/
            return;
        }

        foreach ( s_piece in s_craftable.a_piecestubs )
        {
            if ( s_piece.piecename == "gem" )
                continue;

            s_piece craftable_waittill_spawned();
            do_glow_now = n_elem == 3 || n_elem == 2;
            s_piece.piecespawn.model thread craftable_model_attach_glow( n_elem, do_glow_now );
        }
    }
}

craftable_model_attach_glow( n_elem, do_glow_now )
{
    self endon( "death" );

    if ( !do_glow_now )
        self waittill( "staff_piece_glow" );

    self setclientfield( "element_glow_fx", n_elem );
}

tomb_staff_update_prompt( player, b_set_hint_string_now, trigger )
{
    if ( isdefined( self.crafted ) && self.crafted )
        return true;

    self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";

    if ( isdefined( player ) )
    {
        if ( !isdefined( player.current_craftable_piece ) )
            return false;

        if ( !self.craftablespawn craftable_has_piece( player.current_craftable_piece ) )
        {
            self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
            return false;
        }
    }

    if ( level.staff_part_count[self.craftablespawn.craftable_name] == 0 )
    {
        self.hint_string = level.zombie_craftablestubs[self.equipname].str_to_craft;
        return true;
    }
    else
        return false;
}

init_craftable_choke()
{
    for ( level.craftables_spawned_this_frame = 0; 1; level.craftables_spawned_this_frame = 0 )
        wait_network_frame();
}

craftable_wait_your_turn()
{
    if ( !isdefined( level.craftables_spawned_this_frame ) )
        level thread init_craftable_choke();

    while ( level.craftables_spawned_this_frame >= 2 )
        wait_network_frame();

    level.craftables_spawned_this_frame++;
}

quadrotorcraftable()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "quadrotor_zm_craftable_trigger", "equip_dieseldrone_zm", "equip_dieseldrone_zm", &"ZM_TOMB_TQ", 1, 1 );
}

riotshieldcraftable()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "riotshield_zm_craftable_trigger", "tomb_shield_zm", "tomb_shield_zm", &"ZOMBIE_GRAB_RIOTSHIELD", 1, 1 );
}

staffcraftable_air()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "staff_air_craftable_trigger", "elemental_staff_air", "staff_air_zm", &"ZM_TOMB_PUAS", 1, 1 );
}

staffcraftable_fire()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "staff_fire_craftable_trigger", "elemental_staff_fire", "staff_fire_zm", &"ZM_TOMB_PUFS", 1, 1 );
}

staffcraftable_lightning()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "staff_lightning_craftable_trigger", "elemental_staff_lightning", "staff_lightning_zm", &"ZM_TOMB_PULS", 1, 1 );
}

staffcraftable_water()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "staff_water_craftable_trigger", "elemental_staff_water", "staff_water_zm", &"ZM_TOMB_PUIS", 1, 1 );
}

gramophonecraftable()
{
    craftable_wait_your_turn();
    maps\mp\zombies\_zm_craftables::craftable_trigger_think( "gramophone_craftable_trigger", "gramophone", "gramophone", &"ZOMBIE_GRAB_GRAMOPHONE", 1, 1 );
}

tankcraftableupdateprompt( player, sethintstringnow, buildabletrigger )
{
    if ( level.vh_tank getspeedmph() > 0.0 )
    {
        if ( isdefined( self ) )
        {
            self.hint_string = "";

            if ( isdefined( sethintstringnow ) && sethintstringnow && isdefined( buildabletrigger ) )
                buildabletrigger sethintstring( self.hint_string );
        }

        return false;
    }

    return true;
}

ondrop_common( player )
{
    self.piece_owner = undefined;
}

ondrop_crystal( player )
{
    ondrop_common( player );
    s_piece = self.piecestub;
    s_piece.piecespawn.canmove = 1;
    maps\mp\zombies\_zm_unitrigger::reregister_unitrigger_as_dynamic( s_piece.piecespawn.unitrigger );
    s_original_pos = getstruct( self.craftablename + "_" + self.piecename );
    s_piece.piecespawn.unitrigger trigger_off();
    s_piece.piecespawn.model ghost();
    s_piece.piecespawn.model moveto( s_original_pos.origin, 0.05 );

    s_piece.piecespawn.model waittill( "movedone" );

    s_piece.piecespawn.model show();
    s_piece.piecespawn.unitrigger trigger_on();
}

ondrop_firecrystal( player )
{
    level setclientfield( "piece_staff_zm_gem_fire", 0 );
    level setclientfield( "quest_state1", 1 );
    level setclientfield( "piece_record_zm_vinyl_fire", 0 );
    player clear_player_crystal( 1 );
    ondrop_crystal( player );
}

ondrop_aircrystal( player )
{
    level setclientfield( "piece_staff_zm_gem_air", 0 );
    level setclientfield( "quest_state2", 1 );
    level setclientfield( "piece_record_zm_vinyl_air", 0 );
    player clear_player_crystal( 2 );
    ondrop_crystal( player );
}

ondrop_lightningcrystal( player )
{
    level setclientfield( "piece_staff_zm_gem_lightning", 0 );
    level setclientfield( "quest_state3", 1 );
    level setclientfield( "piece_record_zm_vinyl_lightning", 0 );
    player clear_player_crystal( 3 );
    ondrop_crystal( player );
}

ondrop_watercrystal( player )
{
    level setclientfield( "piece_staff_zm_gem_water", 0 );
    level setclientfield( "quest_state4", 1 );
    level setclientfield( "piece_record_zm_vinyl_water", 0 );
    player clear_player_crystal( 4 );
    ondrop_crystal( player );
}

clear_player_crystal( n_element )
{
    if ( n_element == self.crystal_id )
    {
        n_player = self getentitynumber() + 1;
        level setclientfield( "staff_player" + n_player, 0 );
        self.crystal_id = 0;
    }
}

piece_pickup_conversation( player )
{
    wait 1.0;

    while ( isdefined( player.isspeaking ) && player.isspeaking )
        wait_network_frame();

    if ( isdefined( self.piecestub.vo_line_notify ) )
    {
        level notify( "quest_progressed", player, 0 );
        level notify( self.piecestub.vo_line_notify, player );
    }
    else if ( isdefined( self.piecestub.sam_line ) )
    {
        level notify( "quest_progressed", player, 0 );
        level notify( self.piecestub.sam_line, player );
    }
    else
        level notify( "quest_progressed", player, 1 );
}

onpickup_common( player )
{
    player playsound( "zmb_craftable_pickup" );
    self.piece_owner = player;
    self thread piece_pickup_conversation( player );
/#
    foreach ( spawn in self.spawns )
        spawn notify( "stop_debug_position" );
#/
}

staff_pickup_vo()
{
    if ( !flag( "samantha_intro_done" ) )
        return;

    if ( !( isdefined( level.sam_staff_line_played ) && level.sam_staff_line_played ) )
    {
        level.sam_staff_line_played = 1;
        wait 1.0;
        maps\mp\zm_tomb_vo::set_players_dontspeak( 1 );
        maps\mp\zm_tomb_vo::samanthasay( "vox_sam_1st_staff_found_1_0", self, 1 );
        maps\mp\zm_tomb_vo::samanthasay( "vox_sam_1st_staff_found_2_0", self );
        maps\mp\zm_tomb_vo::set_players_dontspeak( 0 );
        self maps\mp\zombies\_zm_audio::create_and_play_dialog( "staff", "first_piece" );
    }
}

onpickup_staffpiece( player )
{
    onpickup_common( player );

    if ( !isdefined( level.num_staffpieces_picked_up[self.craftablename] ) )
        level.num_staffpieces_picked_up[self.craftablename] = 0;

    level.num_staffpieces_picked_up[self.craftablename]++;

    if ( level.num_staffpieces_picked_up[self.craftablename] == 3 )
        level notify( self.craftablename + "_all_pieces_found" );

    player thread staff_pickup_vo();
}

onpickup_crystal( player, elementname, elementenum )
{
    onpickup_common( player );
    level setclientfield( "piece_staff_zm_gem_" + elementname, 1 );
    n_player = player getentitynumber() + 1;
    level setclientfield( "staff_player" + n_player, elementenum );

    if ( flag( "any_crystal_picked_up" ) )
        self.piecestub.vox_id = undefined;

    flag_set( "any_crystal_picked_up" );
}

onpickup_firecrystal( player )
{
    level setclientfield( "quest_state1", 2 );
    player.crystal_id = 1;
    onpickup_crystal( player, "fire", 1 );
}

onpickup_aircrystal( player )
{
    level setclientfield( "quest_state2", 2 );
    player.crystal_id = 2;
    onpickup_crystal( player, "air", 2 );
}

onpickup_lightningcrystal( player )
{
    level setclientfield( "quest_state3", 2 );
    player.crystal_id = 3;
    onpickup_crystal( player, "lightning", 3 );
}

onpickup_watercrystal( player )
{
    level setclientfield( "quest_state4", 2 );
    player.crystal_id = 4;
    onpickup_crystal( player, "water", 4 );
}

vinyl_add_pickup( str_craftable_name, str_piece_name, str_model_name, str_bit_clientfield, str_quest_clientfield, str_vox_id )
{
    b_one_time_vo = 1;
    craftable = generate_zombie_craftable_piece( str_craftable_name, str_piece_name, str_model_name, 32, 62, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, str_bit_clientfield, 1, str_vox_id, b_one_time_vo );
    craftable thread watch_part_pickup( str_quest_clientfield, 1 );
    return craftable;
}

watch_part_pickup( str_quest_clientfield, n_clientfield_val )
{
    self craftable_waittill_spawned();

    self.piecespawn waittill( "pickup" );

    level notify( self.craftablename + "_" + self.piecename + "_picked_up" );

    if ( isdefined( str_quest_clientfield ) && isdefined( n_clientfield_val ) )
        level setclientfield( str_quest_clientfield, n_clientfield_val );
}

count_staff_piece_pickup( a_staff_pieces )
{
    if ( !isdefined( level.staff_part_count ) )
        level.staff_part_count = [];

    str_name = a_staff_pieces[0].craftablename;
    level.staff_part_count[str_name] = a_staff_pieces.size;

    foreach ( piece in a_staff_pieces )
    {
        assert( piece.craftablename == str_name );
        piece thread watch_staff_pickup();
    }
}

craftable_waittill_spawned()
{
    while ( !isdefined( self.piecespawn ) )
        wait_network_frame();
}

watch_staff_pickup()
{
    self craftable_waittill_spawned();

    self.piecespawn waittill( "pickup" );

    level.staff_part_count[self.craftablename]--;
}

onfullycrafted_quadrotor( player )
{
    level.quadrotor_status.crafted = 1;
    pickup_trig = level.quadrotor_status.pickup_trig;
    level.quadrotor_status.str_zone = maps\mp\zombies\_zm_zonemgr::get_zone_from_position( pickup_trig.origin, 1 );
    level.quadrotor_status.pickup_indicator = spawn( "script_model", pickup_trig.model.origin + vectorscale( ( 0, 0, -1 ), 10.0 ) );
    level.quadrotor_status.pickup_indicator setmodel( "p6_zm_tm_quadrotor_stand" );
    level notify( "quest_progressed", player, 1 );
    return 1;
}

onbuyweapon_riotshield( player )
{
    if ( isdefined( player.player_shield_reset_health ) )
        player [[ player.player_shield_reset_health ]]();

    if ( isdefined( player.player_shield_reset_location ) )
        player [[ player.player_shield_reset_location ]]();
}

staff_fullycrafted( modelname, elementenum )
{
    player = get_closest_player( self.origin );
    staff_model = getent( modelname, "targetname" );
    staff_info = get_staff_info_from_element_index( elementenum );
    staff_model useweaponmodel( staff_info.weapname );
    staff_model showallparts();
    level notify( "quest_progressed", player, 0 );

    if ( !isdefined( staff_model.inused ) )
    {
        staff_model show();
        staff_model.inused = 1;
        level.n_staffs_crafted++;

        if ( level.n_staffs_crafted == 4 )
            flag_set( "ee_all_staffs_crafted" );
    }

    str_fieldname = "quest_state" + elementenum;
    level setclientfield( str_fieldname, 3 );
    return 1;
}

staff_fire_fullycrafted()
{
    level thread sndplaystaffstingeronce( "fire" );
    return staff_fullycrafted( "craftable_staff_fire_zm", 1 );
}

staff_air_fullycrafted()
{
    level thread sndplaystaffstingeronce( "wind" );
    return staff_fullycrafted( "craftable_staff_air_zm", 2 );
}

staff_lightning_fullycrafted()
{
    level thread sndplaystaffstingeronce( "lightning" );
    return staff_fullycrafted( "craftable_staff_lightning_zm", 3 );
}

staff_water_fullycrafted()
{
    level thread sndplaystaffstingeronce( "ice" );
    return staff_fullycrafted( "craftable_staff_water_zm", 4 );
}

sndplaystaffstingeronce( type )
{
    if ( !isdefined( level.sndstaffbuilt ) )
        level.sndstaffbuilt = [];

    if ( !isinarray( level.sndstaffbuilt, type ) )
    {
        level.sndstaffbuilt[level.sndstaffbuilt.size] = type;
        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "staff_" + type );
    }
}

quadrotor_watcher( player )
{
    quadrotor_set_unavailable();
    player thread quadrotor_return_condition_watcher();
    player thread quadrotor_control_thread();

    level waittill( "drone_available" );

    level.maxis_quadrotor = undefined;

    if ( flag( "ee_quadrotor_disabled" ) )
        flag_waitopen( "ee_quadrotor_disabled" );

    quadrotor_set_available();
}

quadrotor_return_condition_watcher()
{
    self waittill_any( "bled_out", "disconnect" );

    if ( isdefined( level.maxis_quadrotor ) )
        level notify( "drone_should_return" );
    else
        level notify( "drone_available" );
}

quadrotor_control_thread()
{
    self endon( "bled_out" );
    self endon( "disconnect" );

    while ( true )
    {
        if ( self actionslottwobuttonpressed() && self hasweapon( "equip_dieseldrone_zm" ) )
        {
            self waittill( "weapon_change_complete" );

            self playsound( "veh_qrdrone_takeoff" );
            weapons = self getweaponslistprimaries();
            self switchtoweapon( weapons[0] );

            self waittill( "weapon_change_complete" );

            if ( self hasweapon( "equip_dieseldrone_zm" ) )
            {
                self takeweapon( "equip_dieseldrone_zm" );
                self setactionslot( 2, "" );
            }

            str_vehicle = "heli_quadrotor_zm";

            if ( flag( "ee_maxis_drone_retrieved" ) )
                str_vehicle = "heli_quadrotor_upgraded_zm";

            qr = spawnvehicle( "veh_t6_dlc_zm_quadrotor", "quadrotor_ai", str_vehicle, self.origin + vectorscale( ( 0, 0, 1 ), 96.0 ), self.angles );
            level thread quadrotor_death_watcher( qr );
            qr thread quadrotor_instance_watcher( self );
            return;
        }

        wait 0.05;
    }
}

quadrotor_debug_send_home( player_owner )
{
    self endon( "drone_should_return" );
    level endon( "drone_available" );

    while ( true )
    {
        if ( player_owner actionslottwobuttonpressed() )
            self quadrotor_fly_back_to_table();

        wait 0.05;
    }
}

quadrotor_instance_watcher( player_owner )
{
    self endon( "death" );
    self.player_owner = player_owner;
    self.health = 200;
    level.maxis_quadrotor = self;
    self makevehicleunusable();
    self thread maps\mp\zombies\_zm_ai_quadrotor::quadrotor_think();
    self thread follow_ent( player_owner );
    self thread quadrotor_timer();

    level waittill( "drone_should_return" );

    self quadrotor_fly_back_to_table();
}

quadrotor_death_watcher( quadrotor )
{
    level endon( "drone_available" );

    quadrotor waittill( "death" );

    level notify( "drone_available" );
}

quadrotor_fly_back_to_table()
{
    self endon( "death" );
    level endon( "drone_available" );

    if ( isdefined( self ) )
    {
/#
        iprintln( "Maxis sez: time to bounce" );
#/
        self.returning_home = 1;
        self thread quadrotor_fly_back_to_table_timeout();
        self waittill_any( "attempting_return", "return_timeout" );
    }

    if ( isdefined( self ) )
        self waittill_any( "near_goal", "force_goal", "reached_end_node", "return_timeout" );

    if ( isdefined( self ) )
    {
        playfx( level._effect["tesla_elec_kill"], self.origin );
        self playsound( "zmb_qrdrone_leave" );
        self delete();
/#
        iprintln( "Maxis deleted" );
#/
    }

    level notify( "drone_available" );
}

report_notify( str_notify )
{
    self waittill( str_notify );

    iprintln( str_notify );
}

quadrotor_fly_back_to_table_timeout()
{
    self endon( "death" );
    level endon( "drone_available" );
    wait 30;

    if ( isdefined( self ) )
    {
        self delete();
/#
        iprintln( "Maxis deleted" );
#/
    }

    self notify( "return_timeout" );
}

quadrotor_timer()
{
    self endon( "death" );
    level endon( "drone_available" );
    wait 80;
    vox_line = "vox_maxi_drone_cool_down_" + randomintrange( 0, 2 );
    self thread maps\mp\zm_tomb_vo::maxissay( vox_line, self );
    wait 10;
    vox_line = "vox_maxi_drone_cool_down_2";
    self thread maps\mp\zm_tomb_vo::maxissay( vox_line, self );
    level notify( "drone_should_return" );
}

quadrotor_set_available()
{
/#
    iprintln( "Quad returned to table" );
#/
    playfx( level._effect["tesla_elec_kill"], level.quadrotor_status.pickup_trig.model.origin );
    level.quadrotor_status.pickup_trig.model playsound( "zmb_qrdrone_leave" );
    level.quadrotor_status.picked_up = 0;
    level.quadrotor_status.pickup_trig.model show();
    flag_set( "quadrotor_cooling_down" );
    str_zone = level.quadrotor_status.str_zone;

    switch ( str_zone )
    {
        case "zone_nml_9":
            setclientfield( "cooldown_steam", 1 );
            break;
        case "zone_bunker_5a":
            setclientfield( "cooldown_steam", 2 );
            break;
        case "zone_village_1":
            setclientfield( "cooldown_steam", 3 );
            break;
    }

    vox_line = "vox_maxi_drone_cool_down_3";
    thread maxissay( vox_line, level.quadrotor_status.pickup_trig.model );
    wait 60;
    flag_clear( "quadrotor_cooling_down" );
    setclientfield( "cooldown_steam", 0 );
    level.quadrotor_status.pickup_trig trigger_on();
    vox_line = "vox_maxi_drone_cool_down_4";
    maxissay( vox_line, level.quadrotor_status.pickup_trig.model );
}

quadrotor_set_unavailable()
{
    level.quadrotor_status.picked_up = 1;
    level.quadrotor_status.pickup_trig trigger_off();
    level.quadrotor_status.pickup_trig.model ghost();
}

sqcommoncraftable()
{
    level.sq_craftable = maps\mp\zombies\_zm_craftables::craftable_trigger_think( "sq_common_craftable_trigger", "sq_common", "sq_common", "", 1, 0 );
}

droponmover( player )
{

}

pickupfrommover()
{

}

setup_quadrotor_purchase( player )
{
    if ( self.stub.weaponname == "equip_dieseldrone_zm" )
    {
        if ( players_has_weapon( "equip_dieseldrone_zm" ) )
            return true;

        quadrotor = getentarray( "quadrotor_ai", "targetname" );

        if ( quadrotor.size >= 1 )
            return true;

        quadrotor_set_unavailable();
        player giveweapon( "equip_dieseldrone_zm" );
        player setweaponammoclip( "equip_dieseldrone_zm", 1 );
        player playsoundtoplayer( "zmb_buildable_pickup_complete", player );

        if ( isdefined( self.stub.craftablestub.use_actionslot ) )
            player setactionslot( self.stub.craftablestub.use_actionslot, "weapon", "equip_dieseldrone_zm" );
        else
            player setactionslot( 2, "weapon", "equip_dieseldrone_zm" );

        player notify( "equip_dieseldrone_zm_given" );
        level thread quadrotor_watcher( player );
        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "build_dd_plc" );
        return true;
    }

    return false;
}

players_has_weapon( weaponname )
{
    players = getplayers();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] hasweapon( weaponname ) )
            return true;
    }

    return false;
}

tomb_custom_craftable_validation( player )
{
    if ( self.stub.equipname == "equip_dieseldrone_zm" )
    {
        level.quadrotor_status.pickup_trig = self.stub;

        if ( level.quadrotor_status.crafted )
            return !level.quadrotor_status.picked_up && !flag( "quadrotor_cooling_down" );
    }

    if ( !issubstr( self.stub.weaponname, "staff" ) )
        return 1;

    str_craftable = self.stub.equipname;

    if ( !( isdefined( level.craftables_crafted[str_craftable] ) && level.craftables_crafted[str_craftable] ) )
        return 1;

    if ( !player can_pickup_staff() )
        return 0;

    s_elemental_staff = get_staff_info_from_weapon_name( self.stub.weaponname, 0 );
    str_weapon_check = s_elemental_staff.weapname;
    a_weapons = player getweaponslistprimaries();

    foreach ( weapon in a_weapons )
    {
        if ( issubstr( weapon, "staff" ) && weapon != str_weapon_check )
            player takeweapon( weapon );
    }

    return 1;
}

tomb_check_crafted_weapon_persistence( player )
{
    if ( self.stub.equipname == "equip_dieseldrone_zm" )
    {
        if ( level.quadrotor_status.picked_up )
            return true;
        else if ( level.quadrotor_status.crafted )
            return false;
    }
    else if ( self.stub.weaponname == "staff_air_zm" || self.stub.weaponname == "staff_fire_zm" || self.stub.weaponname == "staff_lightning_zm" || self.stub.weaponname == "staff_water_zm" )
    {
        if ( self is_unclaimed_staff_weapon( self.stub.weaponname ) )
        {
            s_elemental_staff = get_staff_info_from_weapon_name( self.stub.weaponname, 0 );
            player maps\mp\zombies\_zm_weapons::weapon_give( s_elemental_staff.weapname, 0, 0 );

            if ( isdefined( s_elemental_staff.prev_ammo_stock ) && isdefined( s_elemental_staff.prev_ammo_clip ) )
            {
                player setweaponammostock( s_elemental_staff.weapname, s_elemental_staff.prev_ammo_stock );
                player setweaponammoclip( s_elemental_staff.weapname, s_elemental_staff.prev_ammo_clip );
            }

            if ( isdefined( level.zombie_craftablestubs[self.stub.equipname].str_taken ) )
                self.stub.hint_string = level.zombie_craftablestubs[self.stub.equipname].str_taken;
            else
                self.stub.hint_string = "";

            self sethintstring( self.stub.hint_string );
            player track_craftables_pickedup( self.stub.craftablespawn );
            model = getent( "craftable_" + self.stub.weaponname, "targetname" );
            model ghost();
            self.stub thread track_crafted_staff_trigger();
            self.stub thread track_staff_weapon_respawn( player );
            set_player_staff( self.stub.weaponname, player );
        }
        else
        {
            self.stub.hint_string = "";
            self sethintstring( self.stub.hint_string );
        }

        return true;
    }

    return false;
}

is_unclaimed_staff_weapon( str_weapon )
{
    if ( !maps\mp\zombies\_zm_equipment::is_limited_equipment( str_weapon ) )
        return true;
    else
    {
        s_elemental_staff = get_staff_info_from_weapon_name( str_weapon, 0 );
        str_weapon_check = s_elemental_staff.weapname;
        players = get_players();

        foreach ( player in players )
        {
            if ( isdefined( player ) && player has_weapon_or_upgrade( str_weapon_check ) )
                return false;
        }
    }

    return true;
}

get_staff_info_from_weapon_name( str_name, b_base_info_only = 1 )
{
    foreach ( s_staff in level.a_elemental_staffs )
    {
        if ( s_staff.weapname == str_name || s_staff.upgrade.weapname == str_name )
        {
            if ( s_staff.charger.is_charged && !b_base_info_only )
                return s_staff.upgrade;
            else
                return s_staff;
        }
    }

    return undefined;
}

get_staff_info_from_element_index( n_index )
{
    foreach ( s_staff in level.a_elemental_staffs )
    {
        if ( s_staff.enum == n_index )
            return s_staff;
    }

    return undefined;
}

track_crafted_staff_trigger()
{
    s_elemental_staff = get_staff_info_from_weapon_name( self.weaponname, 1 );

    if ( !isdefined( self.base_weaponname ) )
        self.base_weaponname = s_elemental_staff.weapname;

    flag_waitopen( self.base_weaponname + "_enabled" );
    self trigger_off();
    flag_wait( self.base_weaponname + "_enabled" );
    self trigger_on();
}

track_staff_weapon_respawn( player )
{
    self notify( "kill_track_staff_weapon_respawn" );
    self endon( "kill_track_staff_weapon_respawn" );
    s_elemental_staff = get_staff_info_from_weapon_name( self.weaponname, 1 );
    s_upgraded_staff = s_elemental_staff.upgrade;

    if ( !isdefined( self.base_weaponname ) )
        self.base_weaponname = s_elemental_staff.weapname;

    flag_clear( self.base_weaponname + "_enabled" );

    for ( has_weapon = 0; isalive( player ); has_weapon = 0 )
    {
        if ( isdefined( s_elemental_staff.charger.is_inserted ) && s_elemental_staff.charger.is_inserted || isdefined( s_upgraded_staff.charger.is_inserted ) && s_upgraded_staff.charger.is_inserted || isdefined( s_upgraded_staff.ee_in_use ) && s_upgraded_staff.ee_in_use )
            has_weapon = 1;
        else
        {
            weapons = player getweaponslistprimaries();

            foreach ( weapon in weapons )
            {
                n_melee_element = 0;

                if ( weapon == self.base_weaponname )
                {
                    s_elemental_staff.prev_ammo_stock = player getweaponammostock( weapon );
                    s_elemental_staff.prev_ammo_clip = player getweaponammoclip( weapon );
                    has_weapon = 1;
                }
                else if ( weapon == s_upgraded_staff.weapname )
                {
                    s_upgraded_staff.prev_ammo_stock = player getweaponammostock( weapon );
                    s_upgraded_staff.prev_ammo_clip = player getweaponammoclip( weapon );
                    has_weapon = 1;
                    n_melee_element = s_upgraded_staff.enum;
                }

                if ( player hasweapon( "staff_revive_zm" ) )
                {
                    s_upgraded_staff.revive_ammo_stock = player getweaponammostock( "staff_revive_zm" );
                    s_upgraded_staff.revive_ammo_clip = player getweaponammoclip( "staff_revive_zm" );
                }

                if ( has_weapon && !( isdefined( player.one_inch_punch_flag_has_been_init ) && player.one_inch_punch_flag_has_been_init ) && n_melee_element != 0 )
                {
                    cur_weapon = player getcurrentweapon();

                    if ( cur_weapon != weapon && ( isdefined( player.use_staff_melee ) && player.use_staff_melee ) )
                    {
                        player update_staff_accessories( 0 );
                        continue;
                    }

                    if ( cur_weapon == weapon && !( isdefined( player.use_staff_melee ) && player.use_staff_melee ) )
                        player update_staff_accessories( n_melee_element );
                }
            }
        }

        if ( !has_weapon )
            break;

        wait 0.5;
    }

    b_staff_in_use = 0;
    a_players = getplayers();

    foreach ( check_player in a_players )
    {
        weapons = check_player getweaponslistprimaries();

        foreach ( weapon in weapons )
        {
            if ( weapon == self.base_weaponname || weapon == s_upgraded_staff.weapname )
                b_staff_in_use = 1;
        }
    }

    if ( !b_staff_in_use )
    {
        model = getent( "craftable_" + self.base_weaponname, "targetname" );
        model show();
        flag_set( self.base_weaponname + "_enabled" );
    }

    clear_player_staff( self.base_weaponname, player );
}

set_player_staff( str_weaponname, e_player )
{
    s_staff = get_staff_info_from_weapon_name( str_weaponname );
    s_staff.e_owner = e_player;
    n_player = e_player getentitynumber() + 1;
    e_player.staff_enum = s_staff.enum;
    level setclientfield( "staff_player" + n_player, s_staff.enum );
    e_player update_staff_accessories( s_staff.enum );
/#
    iprintlnbold( "Player " + n_player + " has staff " + s_staff.enum );
#/
}

clear_player_staff_by_player_number( n_player )
{
    level setclientfield( "staff_player" + n_player, 0 );
}

clear_player_staff( str_weaponname, e_owner )
{
    s_staff = get_staff_info_from_weapon_name( str_weaponname );

    if ( isdefined( e_owner ) && isdefined( s_staff.e_owner ) && e_owner != s_staff.e_owner )
        return;

    if ( !isdefined( e_owner ) )
        e_owner = s_staff.e_owner;

    if ( isdefined( e_owner ) )
    {
        if ( !isdefined( e_owner.staff_enum ) && !isdefined( s_staff.enum ) || isdefined( e_owner.staff_enum ) && isdefined( s_staff.enum ) && e_owner.staff_enum == s_staff.enum )
        {
            n_player = e_owner getentitynumber() + 1;
            e_owner.staff_enum = 0;
            level setclientfield( "staff_player" + n_player, 0 );
            e_owner update_staff_accessories( 0 );
        }
    }
/#
    iprintlnbold( "Nobody has staff " + s_staff.enum );
#/
    s_staff.e_owner = undefined;
}

hide_staff_model()
{
    staffs = getentarray( "craftable_staff_model", "script_noteworthy" );

    foreach ( stave in staffs )
        stave ghost();
}
