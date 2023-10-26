// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zm_tomb_teleporter;
#include maps\mp\zm_tomb_vo;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_tomb_chamber;
#include maps\mp\zombies\_zm_challenges;
#include maps\mp\zm_tomb_challenges;
#include maps\mp\zm_tomb_tank;
#include maps\mp\zm_tomb_craftables;

setup_devgui()
{
/#
    execdevgui( "devgui_zombie_tomb" );
    level.custom_devgui = ::zombie_devgui_tomb;
    setdvar( "complete_puzzles1", "off" );
    setdvar( "complete_puzzles2", "off" );
    setdvar( "open_all_teleporters", "off" );
    setdvar( "show_craftable_locations", "off" );
    setdvar( "show_morse_code", "off" );
    setdvar( "sam_intro_skip", "off" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Quest:1/Open All Teleporters:1\" \"open_all_teleporters on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Quest:1/Skip Chamber Puzzles:2\" \"complete_puzzles1 on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Quest:1/Skip Top-side Puzzles:3\" \"complete_puzzles2 on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Quest:1/Show Craftable Locations:4\" \"show_craftable_locations on \"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Tomb:1/Quest:1/Skip Samantha Intro:5\" \"sam_intro_skip on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies:2/Tomb:1/Easter Ann:3/Show Morse Code:1\" \"show_morse_code on \"\n" );
    level thread watch_devgui_quadrotor();
    level thread watch_devgui_complete_puzzles();
    level thread watch_for_upgraded_staffs();
#/
}

zombie_devgui_tomb( cmd )
{
/#
    cmd_strings = strtok( cmd, " " );

    switch ( cmd_strings[0] )
    {
        case "force_recapture_start":
            level notify( "force_recapture_start" );
            break;
        case "force_capture_zone_6":
        case "force_capture_zone_5":
        case "force_capture_zone_4":
        case "force_capture_zone_3":
        case "force_capture_zone_2":
        case "force_capture_zone_1":
            level notify( "force_zone_capture", int( getsubstr( cmd_strings[0], 19 ) ) );
            break;
        case "force_recapture_zone_6":
        case "force_recapture_zone_5":
        case "force_recapture_zone_4":
        case "force_recapture_zone_3":
        case "force_recapture_zone_2":
        case "force_recapture_zone_1":
            level notify( "force_zone_recapture", int( getsubstr( cmd_strings[0], 21 ) ) );
            break;
    }
#/
}

watch_for_upgraded_staffs()
{
/#
    cmd = "";

    while ( true )
    {
        wait 0.25;

        if ( !isdefined( level.zombie_devgui_gun ) || level.zombie_devgui_gun != cmd )
        {
            a_players = get_players();

            foreach ( player in a_players )
            {
                has_upgraded_staff = 0;
                a_str_weapons = player getweaponslist();

                foreach ( str_weapon in a_str_weapons )
                {
                    if ( is_weapon_upgraded_staff( str_weapon ) )
                        has_upgraded_staff = 1;
                }

                if ( has_upgraded_staff )
                    player update_staff_accessories();
            }
        }
    }
#/
}

watch_devgui_complete_puzzles()
{
/#
    while ( true )
    {
        if ( getdvar( _hash_BB20372B ) == "on" || getdvar( _hash_BB20372C ) == "on" )
        {
            flag_set( "air_puzzle_1_complete" );
            flag_set( "ice_puzzle_1_complete" );
            flag_set( "electric_puzzle_1_complete" );
            flag_set( "fire_puzzle_1_complete" );
            flag_set( "chamber_puzzle_cheat" );
            setdvar( "complete_puzzles1", "off" );
            level notify( "open_all_gramophone_doors" );
        }

        if ( getdvar( _hash_A3C6E365 ) == "on" )
        {
            flag_set( "show_morse_code" );
            setdvar( "show_morse_code", "off" );
        }

        if ( getdvar( _hash_BB20372C ) == "on" )
        {
            flag_set( "air_puzzle_2_complete" );
            flag_set( "ice_puzzle_2_complete" );
            flag_set( "electric_puzzle_2_complete" );
            flag_set( "fire_puzzle_2_complete" );
            flag_set( "chamber_puzzle_cheat" );
            flag_set( "staff_air_zm_upgrade_unlocked" );
            flag_set( "staff_water_zm_upgrade_unlocked" );
            flag_set( "staff_fire_zm_upgrade_unlocked" );
            flag_set( "staff_lightning_zm_upgrade_unlocked" );
            setdvar( "complete_puzzles2", "off" );
        }

        if ( getdvar( _hash_273EAFA7 ) == "on" )
        {
            flag_set( "samantha_intro_done" );
            setdvar( "sam_intro_skip", "off" );
        }

        if ( getdvar( _hash_B7590487 ) == "on" )
        {
            maps\mp\zm_tomb_teleporter::stargate_teleport_enable( 1 );
            maps\mp\zm_tomb_teleporter::stargate_teleport_enable( 2 );
            maps\mp\zm_tomb_teleporter::stargate_teleport_enable( 3 );
            maps\mp\zm_tomb_teleporter::stargate_teleport_enable( 4 );
            setdvar( "open_all_teleporters", "off" );
            flag_set( "activate_zone_chamber" );
        }

        wait 0.5;
    }
#/
}

get_teleport_fx_from_enum( n_enum )
{
    switch ( n_enum )
    {
        case 1:
            return "teleport_fire";
        case 4:
            return "teleport_ice";
        case 3:
            return "teleport_elec";
        case 2:
        default:
            return "teleport_air";
    }
}

watch_devgui_quadrotor()
{
/#
    while ( getdvar( _hash_7D075455 ) != "on" )
        wait 0.1;

    players = getplayers();

    foreach ( player in players )
    {
        player set_player_equipment( "equip_dieseldrone_zm" );
        player giveweapon( "equip_dieseldrone_zm" );
        player setweaponammoclip( "equip_dieseldrone_zm", 1 );
        player thread show_equipment_hint( "equip_dieseldrone_zm" );
        player notify( "equip_dieseldrone_zm" + "_given" );
        player set_equipment_invisibility_to_player( "equip_dieseldrone_zm", 1 );
        player setactionslot( 1, "weapon", "equip_dieseldrone_zm" );
    }
#/
}

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

check_solo_status()
{
    if ( getnumexpectedplayers() == 1 && ( !sessionmodeisonlinegame() || !sessionmodeisprivate() ) )
        level.is_forever_solo_game = 1;
    else
        level.is_forever_solo_game = 0;
}

player_slow_movement_speed_monitor()
{
    self endon( "disconnect" );
    n_movescale_delta_no_perk = 0.4 / 4.0;
    n_movescale_delta_staminup = 0.3 / 6.0;
    n_new_move_scale = 1.0;
    n_move_scale_delta = 1.0;
    self.n_move_scale = n_new_move_scale;

    while ( true )
    {
        is_player_slowed = 0;
        self.is_player_slowed = 0;

        foreach ( area in level.a_e_slow_areas )
        {
            if ( self istouching( area ) )
            {
                self setclientfieldtoplayer( "sndMudSlow", 1 );
                is_player_slowed = 1;
                self.is_player_slowed = 1;

                if ( !( isdefined( self.played_mud_vo ) && self.played_mud_vo ) && !( isdefined( self.dontspeak ) && self.dontspeak ) )
                    self thread maps\mp\zm_tomb_vo::struggle_mud_vo();

                if ( self hasperk( "specialty_longersprint" ) )
                {
                    n_new_move_scale = 0.7;
                    n_move_scale_delta = n_movescale_delta_staminup;
                }
                else
                {
                    n_new_move_scale = 0.6;
                    n_move_scale_delta = n_movescale_delta_no_perk;
                }

                break;
            }
        }

        if ( !is_player_slowed )
        {
            self setclientfieldtoplayer( "sndMudSlow", 0 );
            self notify( "mud_slowdown_cleared" );
            n_new_move_scale = 1.0;
        }

        if ( self.n_move_scale != n_new_move_scale )
        {
            if ( self.n_move_scale > n_new_move_scale + n_move_scale_delta )
                self.n_move_scale -= n_move_scale_delta;
            else
                self.n_move_scale = n_new_move_scale;

            self setmovespeedscale( self.n_move_scale );
        }

        wait 0.1;
    }
}

dug_zombie_spawn_init( animname_set = 0 )
{
    self.targetname = "zombie";
    self.script_noteworthy = undefined;

    if ( !animname_set )
        self.animname = "zombie";

    if ( isdefined( get_gamemode_var( "pre_init_zombie_spawn_func" ) ) )
        self [[ get_gamemode_var( "pre_init_zombie_spawn_func" ) ]]();

    self thread play_ambient_zombie_vocals();
    self.zmb_vocals_attack = "zmb_vocals_zombie_attack";
    self.ignoreall = 1;
    self.ignoreme = 1;
    self.allowdeath = 1;
    self.force_gib = 1;
    self.is_zombie = 1;
    self.has_legs = 1;
    self allowedstances( "stand" );
    self.zombie_damaged_by_bar_knockdown = 0;
    self.gibbed = 0;
    self.head_gibbed = 0;
    self setphysparams( 15, 0, 72 );
    self.disablearrivals = 1;
    self.disableexits = 1;
    self.grenadeawareness = 0;
    self.badplaceawareness = 0;
    self.ignoresuppression = 1;
    self.suppressionthreshold = 1;
    self.nododgemove = 1;
    self.dontshootwhilemoving = 1;
    self.pathenemylookahead = 0;
    self.badplaceawareness = 0;
    self.chatinitialized = 0;
    self.a.disablepain = 1;
    self disable_react();

    if ( isdefined( level.zombie_health ) )
    {
        self.maxhealth = level.zombie_health;

        if ( isdefined( level.zombie_respawned_health ) && level.zombie_respawned_health.size > 0 )
        {
            self.health = level.zombie_respawned_health[0];
            arrayremovevalue( level.zombie_respawned_health, level.zombie_respawned_health[0] );
        }
        else
            self.health = level.zombie_health;
    }
    else
    {
        self.maxhealth = level.zombie_vars["zombie_health_start"];
        self.health = self.maxhealth;
    }

    self.freezegun_damage = 0;
    self.dropweapon = 0;
    level thread zombie_death_event( self );
    self init_zombie_run_cycle();
    self thread dug_zombie_think();
    self thread zombie_gib_on_damage();
    self thread zombie_damage_failsafe();
    self thread enemy_death_detection();

    if ( isdefined( level._zombie_custom_spawn_logic ) )
    {
        if ( isarray( level._zombie_custom_spawn_logic ) )
        {
            for ( i = 0; i < level._zombie_custom_spawn_logic.size; i++ )
                self thread [[ level._zombie_custom_spawn_logic[i] ]]();
        }
        else
            self thread [[ level._zombie_custom_spawn_logic ]]();
    }

    if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
    {
        if ( !( isdefined( self.is_inert ) && self.is_inert ) )
            self thread delayed_zombie_eye_glow();
    }

    self.deathfunction = ::zombie_death_animscript;
    self.flame_damage_time = 0;
    self.meleedamage = 60;
    self.no_powerups = 1;
    self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );
    self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
    self.tesla_head_gib_func = ::zombie_tesla_head_gib;
    self.team = level.zombie_team;

    if ( isdefined( get_gamemode_var( "post_init_zombie_spawn_func" ) ) )
        self [[ get_gamemode_var( "post_init_zombie_spawn_func" ) ]]();

    if ( isdefined( level.zombie_init_done ) )
        self [[ level.zombie_init_done ]]();

    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
}

dug_zombie_think()
{
    self endon( "death" );
    assert( !self.isdog );
    self.ai_state = "zombie_think";
    find_flesh_struct_string = undefined;

    self waittill( "zombie_custom_think_done", find_flesh_struct_string );

    node = undefined;
    desired_nodes = [];
    self.entrance_nodes = [];

    if ( isdefined( level.max_barrier_search_dist_override ) )
        max_dist = level.max_barrier_search_dist_override;
    else
        max_dist = 500;

    if ( !isdefined( find_flesh_struct_string ) && isdefined( self.target ) && self.target != "" )
    {
        desired_origin = get_desired_origin();
        assert( isdefined( desired_origin ), "Spawner @ " + self.origin + " has a .target but did not find a target" );
        origin = desired_origin;
        node = getclosest( origin, level.exterior_goals );
        self.entrance_nodes[self.entrance_nodes.size] = node;
        self zombie_history( "zombie_think -> #1 entrance (script_forcegoal) origin = " + self.entrance_nodes[0].origin );
    }
    else if ( self should_skip_teardown( find_flesh_struct_string ) )
    {
        self zombie_setup_attack_properties();

        if ( isdefined( self.target ) )
        {
            end_at_node = getnode( self.target, "targetname" );

            if ( isdefined( end_at_node ) )
            {
                self setgoalnode( end_at_node );

                self waittill( "goal" );
            }
        }

        if ( isdefined( self.start_inert ) && self.start_inert )
        {
            self thread maps\mp\zombies\_zm_ai_basic::start_inert( 1 );
            self zombie_complete_emerging_into_playable_area();
        }
        else
        {
            self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
            self thread dug_zombie_entered_playable();
        }

        return;
    }
    else if ( isdefined( find_flesh_struct_string ) )
    {
        assert( isdefined( find_flesh_struct_string ) );

        for ( i = 0; i < level.exterior_goals.size; i++ )
        {
            if ( level.exterior_goals[i].script_string == find_flesh_struct_string )
            {
                node = level.exterior_goals[i];
                break;
            }
        }

        self.entrance_nodes[self.entrance_nodes.size] = node;
        self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );
        self thread zombie_assure_node();
    }
    else
    {
        origin = self.origin;
        desired_origin = get_desired_origin();

        if ( isdefined( desired_origin ) )
            origin = desired_origin;

        nodes = get_array_of_closest( origin, level.exterior_goals, undefined, 3 );
        desired_nodes[0] = nodes[0];
        prev_dist = distance( self.origin, nodes[0].origin );

        for ( i = 1; i < nodes.size; i++ )
        {
            dist = distance( self.origin, nodes[i].origin );

            if ( dist - prev_dist > max_dist )
                break;

            prev_dist = dist;
            desired_nodes[i] = nodes[i];
        }

        node = desired_nodes[0];

        if ( desired_nodes.size > 1 )
            node = desired_nodes[randomint( desired_nodes.size )];

        self.entrance_nodes = desired_nodes;
        self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );
        self thread zombie_assure_node();
    }

    assert( isdefined( node ), "Did not find a node!!! [Should not see this!]" );
    level thread draw_line_ent_to_pos( self, node.origin, "goal" );
    self.first_node = node;
    self thread zombie_goto_entrance( node );
}

dug_zombie_entered_playable()
{
    self endon( "death" );

    if ( !isdefined( level.playable_areas ) )
        level.playable_areas = getentarray( "player_volume", "script_noteworthy" );

    while ( true )
    {
        foreach ( area in level.playable_areas )
        {
            if ( self istouching( area ) )
            {
                self dug_zombie_complete_emerging_into_playable_area();
                return;
            }
        }

        wait 1;
    }
}

dug_zombie_complete_emerging_into_playable_area()
{
    self.completed_emerging_into_playable_area = 1;
    self notify( "completed_emerging_into_playable_area" );
    self.no_powerups = 1;
    self thread zombie_free_cam_allowed();
}

dug_zombie_rise( spot, func_rise_fx = ::zombie_rise_fx )
{
    self endon( "death" );
    self.in_the_ground = 1;
    self.no_eye_glow = 1;
    self.anchor = spawn( "script_origin", self.origin );
    self.anchor.angles = self.angles;
    self linkto( self.anchor );

    if ( !isdefined( spot.angles ) )
        spot.angles = ( 0, 0, 0 );

    anim_org = spot.origin;
    anim_ang = spot.angles;
    self ghost();
    self.anchor moveto( anim_org, 0.05 );

    self.anchor waittill( "movedone" );

    target_org = get_desired_origin();

    if ( isdefined( target_org ) )
    {
        anim_ang = vectortoangles( target_org - self.origin );
        self.anchor rotateto( ( 0, anim_ang[1], 0 ), 0.05 );

        self.anchor waittill( "rotatedone" );
    }

    self unlink();

    if ( isdefined( self.anchor ) )
        self.anchor delete();

    self thread hide_pop();
    level thread zombie_rise_death( self, spot );
    spot thread [[ func_rise_fx ]]( self );
    substate = 0;

    if ( self.zombie_move_speed == "walk" )
        substate = randomint( 2 );
    else if ( self.zombie_move_speed == "run" )
        substate = 2;
    else if ( self.zombie_move_speed == "sprint" )
        substate = 3;

    self orientmode( "face default" );
    self playsound( "zmb_vocals_capzomb_spawn" );
    self animscripted( self.origin, spot.angles, "zm_dug_rise" );
    self maps\mp\animscripts\zm_shared::donotetracks( "rise_anim", ::handle_rise_notetracks, spot );
    self.no_eye_glow = 0;
    self thread zombie_eye_glow();
    self notify( "rise_anim_finished" );
    spot notify( "stop_zombie_rise_fx" );
    self.in_the_ground = 0;
    self notify( "risen", spot.script_string );
}

is_weapon_upgraded_staff( weapon )
{
    if ( weapon == "staff_water_upgraded_zm" )
        return true;
    else if ( weapon == "staff_lightning_upgraded_zm" )
        return true;
    else if ( weapon == "staff_fire_upgraded_zm" )
        return true;
    else if ( weapon == "staff_air_upgraded_zm" )
        return true;

    return false;
}

watch_staff_usage()
{
    self notify( "watch_staff_usage" );
    self endon( "watch_staff_usage" );
    self endon( "disconnect" );
    self setclientfieldtoplayer( "player_staff_charge", 0 );

    while ( true )
    {
        self waittill( "weapon_change", weapon );

        has_upgraded_staff = 0;
        has_revive_staff = 0;
        weapon_is_upgraded_staff = is_weapon_upgraded_staff( weapon );
        str_upgraded_staff_weapon = undefined;
        a_str_weapons = self getweaponslist();

        foreach ( str_weapon in a_str_weapons )
        {
            if ( is_weapon_upgraded_staff( str_weapon ) )
            {
                has_upgraded_staff = 1;
                str_upgraded_staff_weapon = str_weapon;
            }

            if ( str_weapon == "staff_revive_zm" )
                has_revive_staff = 1;
        }
/#
        if ( has_upgraded_staff && !has_revive_staff )
            has_revive_staff = 1;
#/
        if ( has_upgraded_staff && !has_revive_staff )
        {
            self takeweapon( str_upgraded_staff_weapon );
            has_upgraded_staff = 0;
        }

        if ( !has_upgraded_staff && has_revive_staff )
        {
            self takeweapon( "staff_revive_zm" );
            has_revive_staff = 0;
        }

        if ( !has_revive_staff || !weapon_is_upgraded_staff && "none" != weapon && "none" != weaponaltweaponname( weapon ) )
            self setactionslot( 3, "altmode" );
        else
            self setactionslot( 3, "weapon", "staff_revive_zm" );

        if ( weapon_is_upgraded_staff )
            self thread staff_charge_watch_wrapper( weapon );
    }
}

staff_charge_watch()
{
    self endon( "disconnect" );
    self endon( "player_downed" );
    self endon( "weapon_change" );
    self endon( "weapon_fired" );

    while ( !self attackbuttonpressed() )
        wait 0.05;

    n_old_charge = 0;

    while ( true )
    {
        if ( n_old_charge != self.chargeshotlevel )
        {
            self setclientfieldtoplayer( "player_staff_charge", self.chargeshotlevel );
            n_old_charge = self.chargeshotlevel;
        }

        wait 0.1;
    }
}

staff_charge_watch_wrapper( weapon )
{
    self notify( "staff_charge_watch_wrapper" );
    self endon( "staff_charge_watch_wrapper" );
    self endon( "disconnect" );
    self setclientfieldtoplayer( "player_staff_charge", 0 );

    while ( is_weapon_upgraded_staff( weapon ) )
    {
        self staff_charge_watch();
        self setclientfieldtoplayer( "player_staff_charge", 0 );
        weapon = self getcurrentweapon();
    }
}

door_record_hint()
{
    hud = setting_tutorial_hud();
    hud settext( &"ZM_TOMB_RU" );
    wait 3;
    hud destroy();
}

swap_staff_hint()
{
    level notify( "staff_Hint" );
    hud = setting_tutorial_hud();
    hud settext( &"ZM_TOMB_OSO" );
    level waittill_any_or_timeout( 3.0, "staff_hint" );
    hud destroy();
}

door_gramophone_elsewhere_hint()
{
    hud = setting_tutorial_hud();
    hud settext( &"ZM_TOMB_GREL" );
    wait 3;
    hud destroy();
}

puzzle_debug_position( string_to_show, color, origin, str_dvar, n_show_time )
{
/#
    self endon( "death" );
    self endon( "stop_debug_position" );

    if ( !isdefined( string_to_show ) )
        string_to_show = "+";

    if ( !isdefined( color ) )
        color = vectorscale( ( 1, 1, 1 ), 255.0 );

    if ( isdefined( str_dvar ) )
    {
        while ( getdvar( _hash_93087F74 ) != "on" )
            wait 1.0;
    }

    while ( true )
    {
        if ( isdefined( origin ) )
            where_to_draw = origin;
        else
            where_to_draw = self.origin;

        print3d( where_to_draw, string_to_show, color, 1 );
        wait 0.1;

        if ( isdefined( n_show_time ) )
        {
            n_show_time -= 0.1;

            if ( n_show_time <= 0 )
                break;
        }
    }
#/
}

placeholder_puzzle_delete_ent( str_flag_name )
{
    self endon( "death" );
    flag_wait( str_flag_name );
    self delete();
}

placeholder_puzzle_spin_model()
{
    self endon( "death" );

    while ( true )
    {
        self rotateyaw( 360, 10, 0, 0 );
        wait 9.9;
    }
}

setting_tutorial_hud()
{
    client_hint = newclienthudelem( self );
    client_hint.alignx = "center";
    client_hint.aligny = "middle";
    client_hint.horzalign = "center";
    client_hint.vertalign = "bottom";
    client_hint.y = -120;
    client_hint.foreground = 1;
    client_hint.font = "default";
    client_hint.fontscale = 1.5;
    client_hint.alpha = 1;
    client_hint.color = ( 1, 1, 1 );
    return client_hint;
}

tomb_trigger_update_message( func_per_player_msg )
{
    a_players = getplayers();

    foreach ( e_player in a_players )
    {
        n_player = e_player getentitynumber();

        if ( !isdefined( self.stub.playertrigger[n_player] ) )
            continue;

        new_msg = self [[ func_per_player_msg ]]( e_player );
        self.stub.playertrigger[n_player].stored_hint_string = new_msg;
        self.stub.playertrigger[n_player] sethintstring( new_msg );
    }
}

set_unitrigger_hint_string( str_message )
{
    self.hint_string = str_message;
    maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self );
    maps\mp\zombies\_zm_unitrigger::register_unitrigger( self, ::tomb_unitrigger_think );
}

tomb_spawn_trigger_radius( origin, radius, use_trigger = 0, func_per_player_msg )
{
    trigger_stub = spawnstruct();
    trigger_stub.origin = origin;
    trigger_stub.radius = radius;

    if ( use_trigger )
    {
        trigger_stub.cursor_hint = "HINT_NOICON";
        trigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    }
    else
        trigger_stub.script_unitrigger_type = "unitrigger_radius";

    if ( isdefined( func_per_player_msg ) )
    {
        trigger_stub.func_update_msg = func_per_player_msg;
        maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( trigger_stub, 1 );
    }

    maps\mp\zombies\_zm_unitrigger::register_unitrigger( trigger_stub, ::tomb_unitrigger_think );
    return trigger_stub;
}

tomb_unitrigger_think()
{
    self endon( "kill_trigger" );

    if ( isdefined( self.stub.func_update_msg ) )
        self thread tomb_trigger_update_message( self.stub.func_update_msg );

    while ( true )
    {
        self waittill( "trigger", player );

        self.stub notify( "trigger", player );
    }
}

tomb_unitrigger_delete()
{
    maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self );
    self structdelete();
}

zombie_gib_all()
{
    if ( !isdefined( self ) )
        return;

    if ( isdefined( self.is_mechz ) && self.is_mechz )
        return;

    a_gib_ref = [];
    a_gib_ref[0] = level._zombie_gib_piece_index_all;
    self gib( "normal", a_gib_ref );
    self ghost();
    wait 0.4;

    if ( isdefined( self ) )
        self self_delete();
}

zombie_gib_guts()
{
    if ( !isdefined( self ) )
        return;

    if ( isdefined( self.is_mechz ) && self.is_mechz )
        return;

    v_origin = self gettagorigin( "J_SpineLower" );

    if ( isdefined( v_origin ) )
    {
        v_forward = anglestoforward( ( 0, randomint( 360 ), 0 ) );
        playfx( level._effect["zombie_guts_explosion"], v_origin, v_forward );
    }

    wait_network_frame();

    if ( isdefined( self ) )
    {
        self ghost();
        wait( randomfloatrange( 0.4, 1.1 ) );

        if ( isdefined( self ) )
            self self_delete();
    }
}

link_platform_nodes( nd_1, nd_2 )
{
    if ( !nodesarelinked( nd_1, nd_2 ) )
        link_nodes( nd_1, nd_2 );

    if ( !nodesarelinked( nd_2, nd_1 ) )
        link_nodes( nd_2, nd_1 );
}

unlink_platform_nodes( nd_1, nd_2 )
{
    if ( nodesarelinked( nd_1, nd_2 ) )
        unlink_nodes( nd_1, nd_2 );

    if ( nodesarelinked( nd_2, nd_1 ) )
        unlink_nodes( nd_2, nd_1 );
}

init_weather_manager()
{
    level.weather_snow = 0;
    level.weather_rain = 0;
    level.weather_fog = 0;
    level.weather_vision = 0;
    level thread weather_manager();
    level thread rotate_skydome();
    onplayerconnect_callback( ::set_weather_to_player );
    level.force_weather = [];

    if ( cointoss() )
        level.force_weather[3] = "snow";
    else
        level.force_weather[4] = "snow";

    for ( i = 5; i <= 9; i++ )
    {
        if ( cointoss() )
        {
            level.force_weather[i] = "none";
            continue;
        }

        level.force_weather[i] = "rain";
    }

    level.force_weather[10] = "snow";
}

randomize_weather()
{
    weather_name = level.force_weather[level.round_number];

    if ( !isdefined( weather_name ) )
    {
        n_round_weather = randomint( 100 );
        rounds_since_snow = level.round_number - level.last_snow_round;
        rounds_since_rain = level.round_number - level.last_rain_round;

        if ( n_round_weather < 40 || rounds_since_snow > 3 )
            weather_name = "snow";
        else if ( n_round_weather < 80 || rounds_since_rain > 4 )
            weather_name = "rain";
        else
            weather_name = "none";
    }

    if ( weather_name == "snow" )
    {
        level.weather_snow = randomintrange( 1, 5 );
        level.weather_rain = 0;
        level.weather_vision = 2;
        level.last_snow_round = level.round_number;
    }
    else if ( weather_name == "rain" )
    {
        level.weather_snow = 0;
        level.weather_rain = randomintrange( 1, 5 );
        level.weather_vision = 1;
        level.last_rain_round = level.round_number;
    }
    else
    {
        level.weather_snow = 0;
        level.weather_rain = 0;
        level.weather_vision = 3;
    }
}

weather_manager()
{
    level.last_snow_round = 0;
    level.last_rain_round = 0;

    while ( true )
    {
        level waittill( "end_of_round" );

        randomize_weather();
        level setclientfield( "rain_level", level.weather_rain );
        level setclientfield( "snow_level", level.weather_snow );
        wait 2;

        foreach ( player in getplayers() )
        {
            if ( is_player_valid( player, 0, 1 ) )
                player set_weather_to_player();
        }
    }
}

set_weather_to_player()
{
    self setclientfieldtoplayer( "player_weather_visionset", level.weather_vision );
}

rotate_skydome()
{
    level.sky_rotation = 360;

    while ( true )
    {
        level.sky_rotation -= 0.025;

        if ( level.sky_rotation < 0 )
            level.sky_rotation += 360;

        setdvar( "r_skyRotation", level.sky_rotation );
        wait 0.1;
    }
}

play_puzzle_stinger_on_all_players()
{
    players = getplayers();

    foreach ( player in players )
        player playsound( "zmb_squest_step2_finished" );
}

puzzle_orb_move( v_to_pos )
{
    dist = distance( self.origin, v_to_pos );

    if ( dist == 0.0 )
        return;

    movetime = dist / 300;
    self moveto( v_to_pos, movetime, 0, 0 );

    self waittill( "movedone" );
}

puzzle_orb_follow_path( s_start )
{
    s_next_pos = s_start;

    while ( isdefined( s_next_pos ) )
    {
        self puzzle_orb_move( s_next_pos.origin );

        if ( isdefined( s_next_pos.target ) )
            s_next_pos = getstruct( s_next_pos.target, "targetname" );
        else
            s_next_pos = undefined;
    }
}

puzzle_orb_follow_return_path( s_start, n_element )
{
    a_path = [];
    s_next = s_start;

    while ( isdefined( s_next ) )
    {
        a_path[a_path.size] = s_next;

        if ( isdefined( s_next.target ) )
            s_next = getstruct( s_next.target, "targetname" );
        else
            s_next = undefined;
    }

    v_start = a_path[a_path.size - 1].origin + vectorscale( ( 0, 0, 1 ), 1000.0 );
    e_model = spawn( "script_model", v_start );
    e_model setmodel( s_start.model );
    e_model setclientfield( "element_glow_fx", n_element );
    playfxontag( level._effect["puzzle_orb_trail"], e_model, "tag_origin" );

    for ( i = a_path.size - 1; i >= 0; i-- )
        e_model puzzle_orb_move( a_path[i].origin );

    return e_model;
}

puzzle_orb_pillar_show()
{
    level notify( "sky_pillar_reset" );
    level endon( "sky_pillar_reset" );
    s_pillar = getstruct( "crypt_pillar", "targetname" );
    exploder( 333 );

    if ( isdefined( s_pillar.e_model ) )
        s_pillar.e_model delete();

    s_pillar.e_model = spawn( "script_model", s_pillar.origin );
    s_pillar.e_model endon( "death" );
    s_pillar.e_model ghost();
    s_pillar.e_model setmodel( "fxuse_sky_pillar_new" );
    s_pillar.e_model setclientfield( "sky_pillar", 1 );
    wait_network_frame();
    s_pillar.e_model show();
    wait 1.0;
    wait 27.5;
    s_pillar.e_model setclientfield( "sky_pillar", 0 );
    wait 1.0;
    s_pillar.e_model delete();
}

any_player_looking_at_plinth( min_lookat_dot, n_near_dist_sq )
{
    players = getplayers();

    foreach ( player in players )
    {
        dist_sq = distance2dsquared( player.origin, self.origin );

        if ( dist_sq < n_near_dist_sq )
        {
            fvec = anglestoforward( player.angles );
            to_self = self.origin - player.origin;
            to_self = vectornormalize( to_self );
            dot_to_self = vectordot( to_self, fvec );

            if ( dot_to_self > min_lookat_dot )
                return true;
        }
    }

    return false;
}

puzzle_orb_ready_to_leave( str_zone, min_lookat_dot, n_near_dist_sq )
{
    if ( !level.zones[str_zone].is_occupied || flag( "chamber_puzzle_cheat" ) )
        return 1;

    return any_player_looking_at_plinth( min_lookat_dot, n_near_dist_sq );
}

puzzle_orb_chamber_to_crypt( str_start_point, e_gem_pos )
{
    a_puzzle_flags = strtok( e_gem_pos.script_flag, " " );
    assert( a_puzzle_flags.size == 2 );

    foreach ( str_flag in a_puzzle_flags )
        assert( level flag_exists( str_flag ) );

    flag_wait( a_puzzle_flags[0] );
    s_start = getstruct( str_start_point, "targetname" );
    e_model = spawn( "script_model", s_start.origin );
    e_model setmodel( s_start.model );
    e_model.script_int = e_gem_pos.script_int;
    wait_network_frame();
    e_model playsound( "zmb_squest_crystal_leave" );
    wait_network_frame();
    e_model playloopsound( "zmb_squest_crystal_loop", 1 );
    str_zone = maps\mp\zombies\_zm_zonemgr::get_zone_from_position( s_start.origin, 1 );
    time_looking_at_orb = 0.0;
    min_lookat_dot = cos( 30 );
    n_near_dist_sq = 32400;

    while ( time_looking_at_orb < 1.0 )
    {
        wait 0.1;

        if ( s_start puzzle_orb_ready_to_leave( str_zone, min_lookat_dot, n_near_dist_sq ) )
            time_looking_at_orb += 0.1;
        else
            time_looking_at_orb = 0.0;
    }

    wait_network_frame();
    playfxontag( level._effect["puzzle_orb_trail"], e_model, "tag_origin" );
    wait_network_frame();
    s_next_pos = getstruct( s_start.target, "targetname" );
    e_model puzzle_orb_follow_path( s_next_pos );
    v_sky_pos = e_model.origin;
    v_sky_pos = ( v_sky_pos[0], v_sky_pos[1], v_sky_pos[2] + 1000 );
    e_model puzzle_orb_move( v_sky_pos );
    e_model ghost();
    s_descend_start = getstruct( "orb_crypt_descent_path", "targetname" );
    v_pos_above_gem = s_descend_start.origin + vectorscale( ( 0, 0, 1 ), 3000.0 );
    e_model moveto( v_pos_above_gem, 0.05, 0, 0 );

    e_model waittill( "movedone" );

    flag_wait( a_puzzle_flags[1] );
    e_model show();
    level thread puzzle_orb_pillar_show();
    e_model puzzle_orb_follow_path( s_descend_start );
    flag_set( "disc_rotation_active" );
    e_model puzzle_orb_move( e_gem_pos.origin );
    e_model_nofx = spawn( "script_model", e_model.origin );
    e_model_nofx setmodel( e_model.model );
    e_model_nofx.script_int = e_gem_pos.script_int;
    e_model delete();
    wait_network_frame();
    e_model_nofx playsound( "zmb_squest_crystal_arrive" );
    wait_network_frame();
    e_model_nofx playloopsound( "zmb_squest_crystal_loop", 1 );
    flag_clear( "disc_rotation_active" );
    return e_model_nofx;
}

capture_zombie_spawn_init( animname_set = 0 )
{
    self.targetname = "capture_zombie_ai";

    if ( !animname_set )
        self.animname = "zombie";

    self.sndname = "capzomb";

    if ( isdefined( get_gamemode_var( "pre_init_zombie_spawn_func" ) ) )
        self [[ get_gamemode_var( "pre_init_zombie_spawn_func" ) ]]();

    self thread play_ambient_zombie_vocals();
    self.zmb_vocals_attack = "zmb_vocals_capzomb_attack";
    self.no_damage_points = 1;
    self.deathpoints_already_given = 1;
    self.ignore_enemy_count = 1;
    self.ignoreall = 1;
    self.ignoreme = 1;
    self.allowdeath = 1;
    self.force_gib = 1;
    self.is_zombie = 1;
    self.has_legs = 1;
    self allowedstances( "stand" );
    self.zombie_damaged_by_bar_knockdown = 0;
    self.gibbed = 0;
    self.head_gibbed = 0;
    self.disablearrivals = 1;
    self.disableexits = 1;
    self.grenadeawareness = 0;
    self.badplaceawareness = 0;
    self.ignoresuppression = 1;
    self.suppressionthreshold = 1;
    self.nododgemove = 1;
    self.dontshootwhilemoving = 1;
    self.pathenemylookahead = 0;
    self.badplaceawareness = 0;
    self.chatinitialized = 0;
    self.a.disablepain = 1;
    self disable_react();

    if ( isdefined( level.zombie_health ) )
    {
        self.maxhealth = level.zombie_health;

        if ( isdefined( level.zombie_respawned_health ) && level.zombie_respawned_health.size > 0 )
        {
            self.health = level.zombie_respawned_health[0];
            arrayremovevalue( level.zombie_respawned_health, level.zombie_respawned_health[0] );
        }
        else
            self.health = level.zombie_health;
    }
    else
    {
        self.maxhealth = level.zombie_vars["zombie_health_start"];
        self.health = self.maxhealth;
    }

    self.freezegun_damage = 0;
    self.dropweapon = 0;
    level thread zombie_death_event( self );
    self set_zombie_run_cycle();
    self thread dug_zombie_think();
    self thread zombie_gib_on_damage();
    self thread zombie_damage_failsafe();
    self thread enemy_death_detection();

    if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
    {
        if ( !( isdefined( self.is_inert ) && self.is_inert ) )
            self thread delayed_zombie_eye_glow();
    }

    self.deathfunction = ::zombie_death_animscript;
    self.flame_damage_time = 0;
    self.meleedamage = 60;
    self.no_powerups = 1;
    self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );
    self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
    self.tesla_head_gib_func = ::zombie_tesla_head_gib;
    self.team = level.zombie_team;

    if ( isdefined( get_gamemode_var( "post_init_zombie_spawn_func" ) ) )
        self [[ get_gamemode_var( "post_init_zombie_spawn_func" ) ]]();

    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
}

rumble_players_in_chamber( n_rumble_enum, n_rumble_time = 0.1 )
{
    a_players = getplayers();
    a_rumbled_players = [];

    foreach ( e_player in a_players )
    {
        if ( maps\mp\zm_tomb_chamber::is_point_in_chamber( e_player.origin ) )
        {
            e_player setclientfieldtoplayer( "player_rumble_and_shake", n_rumble_enum );
            a_rumbled_players[a_rumbled_players.size] = e_player;
        }
    }

    wait( n_rumble_time );

    foreach ( e_player in a_rumbled_players )
        e_player setclientfieldtoplayer( "player_rumble_and_shake", 0 );
}

rumble_nearby_players( v_center, n_range, n_rumble_enum )
{
    n_range_sq = n_range * n_range;
    a_players = getplayers();
    a_rumbled_players = [];

    foreach ( e_player in a_players )
    {
        if ( distancesquared( v_center, e_player.origin ) < n_range_sq )
        {
            e_player setclientfieldtoplayer( "player_rumble_and_shake", n_rumble_enum );
            a_rumbled_players[a_rumbled_players.size] = e_player;
        }
    }

    wait_network_frame();

    foreach ( e_player in a_rumbled_players )
        e_player setclientfieldtoplayer( "player_rumble_and_shake", 0 );
}

whirlwind_rumble_player( e_whirlwind, str_active_flag )
{
    if ( isdefined( self.whirlwind_rumble_on ) && self.whirlwind_rumble_on )
        return;

    self.whirlwind_rumble_on = 1;
    n_rumble_level = 1;
    self setclientfieldtoplayer( "player_rumble_and_shake", 4 );
    dist_sq = distancesquared( self.origin, e_whirlwind.origin );
    range_inner_sq = 10000;
    range_sq = 90000;

    while ( dist_sq < range_sq )
    {
        wait 0.05;

        if ( !isdefined( e_whirlwind ) )
            break;

        if ( isdefined( str_active_flag ) )
        {
            if ( !flag( str_active_flag ) )
                break;
        }

        dist_sq = distancesquared( self.origin, e_whirlwind.origin );

        if ( n_rumble_level == 1 && dist_sq < range_inner_sq )
        {
            n_rumble_level = 2;
            self setclientfieldtoplayer( "player_rumble_and_shake", 5 );
        }
        else if ( n_rumble_level == 2 && dist_sq >= range_inner_sq )
        {
            n_rumble_level = 1;
            self setclientfieldtoplayer( "player_rumble_and_shake", 4 );
        }
    }

    self setclientfieldtoplayer( "player_rumble_and_shake", 0 );
    self.whirlwind_rumble_on = 0;
}

whirlwind_rumble_nearby_players( str_active_flag )
{
    range_sq = 90000;

    while ( flag( str_active_flag ) )
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            dist_sq = distancesquared( self.origin, player.origin );

            if ( dist_sq < range_sq )
                player thread whirlwind_rumble_player( self, str_active_flag );
        }

        wait_network_frame();
    }
}

clean_up_bunker_doors()
{
    a_door_models = getentarray( "bunker_door", "script_noteworthy" );
    array_thread( a_door_models, ::bunker_door_clean_up );
}

bunker_door_clean_up()
{
    self waittill( "movedone" );

    self delete();
}

adjustments_for_solo()
{
    if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
    {
        a_door_buys = getentarray( "zombie_door", "targetname" );
        array_thread( a_door_buys, ::door_price_reduction_for_solo );
        a_debris_buys = getentarray( "zombie_debris", "targetname" );
        array_thread( a_debris_buys, ::door_price_reduction_for_solo );
        change_weapon_cost( "beretta93r_zm", 750 );
        change_weapon_cost( "870mcs_zm", 750 );
    }
}

door_price_reduction_for_solo()
{
    if ( self.zombie_cost >= 750 )
    {
        self.zombie_cost -= 250;

        if ( self.zombie_cost >= 2500 )
            self.zombie_cost -= 250;

        if ( self.targetname == "zombie_door" )
            self set_hint_string( self, "default_buy_door", self.zombie_cost );
        else
            self set_hint_string( self, "default_buy_debris", self.zombie_cost );
    }
}

change_weapon_cost( str_weapon, n_cost )
{
    level.zombie_weapons[str_weapon].cost = n_cost;
    level.zombie_weapons[str_weapon].ammo_cost = round_up_to_ten( int( n_cost * 0.5 ) );
}

zone_capture_powerup()
{
    while ( true )
    {
        flag_wait( "zone_capture_in_progress" );
        flag_waitopen( "zone_capture_in_progress" );
        wait 2;

        foreach ( generator in level.zone_capture.zones )
        {
            if ( generator ent_flag( "player_controlled" ) )
            {
                foreach ( uts_box in level.a_uts_challenge_boxes )
                {
                    if ( uts_box.str_location == "start_bunker" )
                    {
                        if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
                            level thread maps\mp\zombies\_zm_challenges::open_box( undefined, uts_box, maps\mp\zm_tomb_challenges::reward_powerup_double_points, -1 );
                        else
                            level thread maps\mp\zombies\_zm_challenges::open_box( undefined, uts_box, maps\mp\zm_tomb_challenges::reward_powerup_zombie_blood, -1 );

                        return;
                    }
                }
            }
        }
    }
}

traversal_blocker()
{
    flag_wait( "activate_zone_nml" );
    m_traversal_blocker = getent( "traversal_blocker", "targetname" );
    m_traversal_blocker connectpaths();
    m_traversal_blocker delete();
}

_kill_zombie_network_safe_internal( e_attacker, str_weapon )
{
    if ( !isdefined( self ) )
        return;

    if ( !isalive( self ) )
        return;

    self.staff_dmg = str_weapon;
    self dodamage( self.health, self.origin, e_attacker, e_attacker, "none", self.kill_damagetype, 0, str_weapon );
}

_damage_zombie_network_safe_internal( e_attacker, str_weapon, n_damage_amt )
{
    if ( !isdefined( self ) )
        return;

    if ( !isalive( self ) )
        return;

    self dodamage( n_damage_amt, self.origin, e_attacker, e_attacker, "none", self.kill_damagetype, 0, str_weapon );
}

do_damage_network_safe( e_attacker, n_amount, str_weapon, str_mod )
{
    if ( isdefined( self.is_mechz ) && self.is_mechz )
        self dodamage( n_amount, self.origin, e_attacker, e_attacker, "none", str_mod, 0, str_weapon );
    else if ( n_amount < self.health )
    {
        self.kill_damagetype = str_mod;
        maps\mp\zombies\_zm_net::network_safe_init( "dodamage", 6 );
        self maps\mp\zombies\_zm_net::network_choke_action( "dodamage", ::_damage_zombie_network_safe_internal, e_attacker, str_weapon, n_amount );
    }
    else
    {
        self.kill_damagetype = str_mod;
        maps\mp\zombies\_zm_net::network_safe_init( "dodamage_kill", 4 );
        self maps\mp\zombies\_zm_net::network_choke_action( "dodamage_kill", ::_kill_zombie_network_safe_internal, e_attacker, str_weapon );
    }
}

_throttle_bullet_trace_think()
{
    do
    {
        level.bullet_traces_this_frame = 0;
        wait_network_frame();
    }
    while ( 1 );
}

bullet_trace_throttled( v_start, v_end, e_ignore )
{
    if ( !isdefined( level.bullet_traces_this_frame ) )
        level thread _throttle_bullet_trace_think();

    while ( level.bullet_traces_this_frame >= 2 )
        wait_network_frame();

    level.bullet_traces_this_frame++;
    return bullettracepassed( v_start, v_end, 0, e_ignore );
}

tomb_get_closest_player_using_paths( origin, players )
{
    min_length_to_player = 9999999;
    n_2d_distance_squared = 9999999;
    player_to_return = undefined;
    dist_to_tank = undefined;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( !isdefined( player ) )
            continue;

        if ( isdefined( player.b_already_on_tank ) && player.b_already_on_tank )
        {
            if ( !isdefined( dist_to_tank ) )
            {
                length_to_player = self maps\mp\zm_tomb_tank::tomb_get_path_length_to_tank();
                dist_to_tank = length_to_player;
            }
            else
                length_to_player = dist_to_tank;
        }
        else
            length_to_player = self get_path_length_to_enemy( player );

        if ( isdefined( level.validate_enemy_path_length ) )
        {
            if ( length_to_player == 0 )
            {
                valid = self thread [[ level.validate_enemy_path_length ]]( player );

                if ( !valid )
                    continue;
            }
        }

        if ( length_to_player < min_length_to_player )
        {
            min_length_to_player = length_to_player;
            player_to_return = player;
            n_2d_distance_squared = distance2dsquared( self.origin, player.origin );
            continue;
        }

        if ( length_to_player == min_length_to_player && length_to_player <= 5 )
        {
            n_new_distance = distance2dsquared( self.origin, player.origin );

            if ( n_new_distance < n_2d_distance_squared )
            {
                min_length_to_player = length_to_player;
                player_to_return = player;
                n_2d_distance_squared = n_new_distance;
            }
        }
    }

    return player_to_return;
}

update_staff_accessories( n_element_index )
{
/#
    if ( !isdefined( n_element_index ) )
    {
        n_element_index = 0;
        str_weapon = self getcurrentweapon();

        if ( is_weapon_upgraded_staff( str_weapon ) )
        {
            s_info = maps\mp\zm_tomb_craftables::get_staff_info_from_weapon_name( str_weapon );

            if ( isdefined( s_info ) )
            {
                n_element_index = s_info.enum;
                s_info.charger.is_charged = 1;
            }
        }
    }
#/
    if ( !( isdefined( self.one_inch_punch_flag_has_been_init ) && self.one_inch_punch_flag_has_been_init ) )
    {
        cur_weapon = self get_player_melee_weapon();
        weapon_to_keep = "knife_zm";
        self.use_staff_melee = 0;

        if ( n_element_index != 0 )
        {
            staff_info = maps\mp\zm_tomb_craftables::get_staff_info_from_element_index( n_element_index );

            if ( staff_info.charger.is_charged )
                staff_info = staff_info.upgrade;

            if ( isdefined( staff_info.melee ) )
            {
                weapon_to_keep = staff_info.melee;
                self.use_staff_melee = 1;
            }
        }

        melee_changed = 0;

        if ( cur_weapon != weapon_to_keep )
        {
            self takeweapon( cur_weapon );
            self giveweapon( weapon_to_keep );
            self set_player_melee_weapon( weapon_to_keep );
            melee_changed = 1;
        }
    }

    has_revive = self hasweapon( "staff_revive_zm" );
    has_upgraded_staff = 0;
    a_weapons = self getweaponslistprimaries();
    staff_info = maps\mp\zm_tomb_craftables::get_staff_info_from_element_index( n_element_index );

    foreach ( str_weapon in a_weapons )
    {
        if ( is_weapon_upgraded_staff( str_weapon ) )
            has_upgraded_staff = 1;
    }

    if ( has_revive && !has_upgraded_staff )
    {
        self setactionslot( 3, "altmode" );
        self takeweapon( "staff_revive_zm" );
    }
    else if ( !has_revive && has_upgraded_staff )
    {
        self setactionslot( 3, "weapon", "staff_revive_zm" );
        self giveweapon( "staff_revive_zm" );

        if ( isdefined( staff_info ) )
        {
            if ( isdefined( staff_info.upgrade.revive_ammo_stock ) )
            {
                self setweaponammostock( "staff_revive_zm", staff_info.upgrade.revive_ammo_stock );
                self setweaponammoclip( "staff_revive_zm", staff_info.upgrade.revive_ammo_clip );
            }
        }
    }
}

get_round_enemy_array_wrapper()
{
    if ( isdefined( level.custom_get_round_enemy_array_func ) )
        a_enemies = [[ level.custom_get_round_enemy_array_func ]]();
    else
        a_enemies = get_round_enemy_array();

    return a_enemies;
}

add_ragdoll()
{
    level.n_active_ragdolls++;
    wait 1;

    if ( level.n_active_ragdolls > 0 )
        level.n_active_ragdolls--;
}

ragdoll_attempt()
{
    if ( level.n_active_ragdolls >= 4 )
        return false;

    level thread add_ragdoll();
    return true;
}
