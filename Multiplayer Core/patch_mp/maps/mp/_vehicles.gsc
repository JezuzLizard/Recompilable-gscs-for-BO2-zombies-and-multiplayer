// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\killstreaks\_rcbomb;
#include maps\mp\killstreaks\_qrdrone;
#include maps\mp\gametypes\_spawning;

#using_animtree("mp_vehicles");

init()
{
    precachevehicle( get_default_vehicle_name() );
    setdvar( "scr_veh_cleanupdebugprint", "0" );
    setdvar( "scr_veh_driversarehidden", "1" );
    setdvar( "scr_veh_driversareinvulnerable", "1" );
    setdvar( "scr_veh_alive_cleanuptimemin", "119" );
    setdvar( "scr_veh_alive_cleanuptimemax", "120" );
    setdvar( "scr_veh_dead_cleanuptimemin", "20" );
    setdvar( "scr_veh_dead_cleanuptimemax", "30" );
    setdvar( "scr_veh_cleanuptime_dmgfactor_min", "0.33" );
    setdvar( "scr_veh_cleanuptime_dmgfactor_max", "1.0" );
    setdvar( "scr_veh_cleanuptime_dmgfactor_deadtread", "0.25" );
    setdvar( "scr_veh_cleanuptime_dmgfraction_curve_begin", "0.0" );
    setdvar( "scr_veh_cleanuptime_dmgfraction_curve_end", "1.0" );
    setdvar( "scr_veh_cleanupabandoned", "1" );
    setdvar( "scr_veh_cleanupdrifted", "1" );
    setdvar( "scr_veh_cleanupmaxspeedmph", "1" );
    setdvar( "scr_veh_cleanupmindistancefeet", "75" );
    setdvar( "scr_veh_waittillstoppedandmindist_maxtime", "10" );
    setdvar( "scr_veh_waittillstoppedandmindist_maxtimeenabledistfeet", "5" );
    setdvar( "scr_veh_respawnafterhuskcleanup", "1" );
    setdvar( "scr_veh_respawntimemin", "50" );
    setdvar( "scr_veh_respawntimemax", "90" );
    setdvar( "scr_veh_respawnwait_maxiterations", "30" );
    setdvar( "scr_veh_respawnwait_iterationwaitseconds", "1" );
    setdvar( "scr_veh_disablerespawn", "0" );
    setdvar( "scr_veh_disableoverturndamage", "0" );
    setdvar( "scr_veh_explosion_spawnfx", "1" );
    setdvar( "scr_veh_explosion_doradiusdamage", "1" );
    setdvar( "scr_veh_explosion_radius", "256" );
    setdvar( "scr_veh_explosion_mindamage", "20" );
    setdvar( "scr_veh_explosion_maxdamage", "200" );
    setdvar( "scr_veh_ondeath_createhusk", "1" );
    setdvar( "scr_veh_ondeath_usevehicleashusk", "1" );
    setdvar( "scr_veh_explosion_husk_forcepointvariance", "30" );
    setdvar( "scr_veh_explosion_husk_horzvelocityvariance", "25" );
    setdvar( "scr_veh_explosion_husk_vertvelocitymin", "100" );
    setdvar( "scr_veh_explosion_husk_vertvelocitymax", "200" );
    setdvar( "scr_veh_explode_on_cleanup", "1" );
    setdvar( "scr_veh_disappear_maxwaittime", "60" );
    setdvar( "scr_veh_disappear_maxpreventdistancefeet", "30" );
    setdvar( "scr_veh_disappear_maxpreventvisibilityfeet", "150" );
    setdvar( "scr_veh_health_tank", "1350" );
    level.vehicle_drivers_are_invulnerable = getdvarint( "scr_veh_driversareinvulnerable" );
    level.onejectoccupants = ::vehicle_eject_all_occupants;
    level.vehiclehealths["panzer4_mp"] = 2600;
    level.vehiclehealths["t34_mp"] = 2600;
    setdvar( "scr_veh_health_jeep", "700" );

    if ( init_vehicle_entities() )
    {
        level.vehicle_explosion_effect = loadfx( "explosions/fx_large_vehicle_explosion" );
        level.veh_husk_models = [];

        if ( isdefined( level.use_new_veh_husks ) )
            level.veh_husk_models["t34_mp"] = "veh_t34_destroyed_mp";

        if ( isdefined( level.onaddvehiclehusks ) )
            [[ level.onaddvehiclehusks ]]();

        keys = getarraykeys( level.veh_husk_models );

        for ( i = 0; i < keys.size; i++ )
            precachemodel( level.veh_husk_models[keys[i]] );

        precacherumble( "tank_damage_light_mp" );
        precacherumble( "tank_damage_heavy_mp" );
        level._effect["tanksquish"] = loadfx( "maps/see2/fx_body_blood_splat" );
    }

    chopper_player_get_on_gun = %int_huey_gunner_on;
    chopper_door_open = %v_huey_door_open;
    chopper_door_open_state = %v_huey_door_open_state;
    chopper_door_closed_state = %v_huey_door_close_state;
    killbrushes = getentarray( "water_killbrush", "targetname" );

    foreach ( brush in killbrushes )
        brush thread water_killbrush_think();
}

water_killbrush_think()
{
    for (;;)
    {
        self waittill( "trigger", entity );

        if ( isdefined( entity ) )
        {
            if ( isdefined( entity.targetname ) )
            {
                if ( entity.targetname == "rcbomb" )
                    entity maps\mp\killstreaks\_rcbomb::rcbomb_force_explode();
                else if ( entity.targetname == "talon" && !is_true( entity.dead ) )
                    entity notify( "death" );
            }

            if ( isdefined( entity.helitype ) && entity.helitype == "qrdrone" )
                entity maps\mp\killstreaks\_qrdrone::qrdrone_force_destroy();
        }
    }
}

initialize_vehicle_damage_effects_for_level()
{
    k_mild_damage_index = 0;
    k_moderate_damage_index = 1;
    k_severe_damage_index = 2;
    k_total_damage_index = 3;
    k_mild_damage_health_percentage = 0.85;
    k_moderate_damage_health_percentage = 0.55;
    k_severe_damage_health_percentage = 0.35;
    k_total_damage_health_percentage = 0;
    level.k_mild_damage_health_percentage = k_mild_damage_health_percentage;
    level.k_moderate_damage_health_percentage = k_moderate_damage_health_percentage;
    level.k_severe_damage_health_percentage = k_severe_damage_health_percentage;
    level.k_total_damage_health_percentage = k_total_damage_health_percentage;
    level.vehicles_damage_states = [];
    level.vehicles_husk_effects = [];
    level.vehicles_damage_treadfx = [];
    vehicle_name = get_default_vehicle_name();
    level.vehicles_damage_states[vehicle_name] = [];
    level.vehicles_damage_treadfx[vehicle_name] = [];
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index].health_percentage = k_mild_damage_health_percentage;
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array = [];
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0].damage_effect = loadfx( "vehicle/vfire/fx_tank_sherman_smldr" );
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0].sound_effect = undefined;
    level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0].vehicle_tag = "tag_origin";
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].health_percentage = k_moderate_damage_health_percentage;
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array = [];
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0].damage_effect = loadfx( "vehicle/vfire/fx_vfire_med_12" );
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0].sound_effect = undefined;
    level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0].vehicle_tag = "tag_origin";
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index].health_percentage = k_severe_damage_health_percentage;
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array = [];
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0].damage_effect = loadfx( "vehicle/vfire/fx_vfire_sherman" );
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0].sound_effect = undefined;
    level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0].vehicle_tag = "tag_origin";
    level.vehicles_damage_states[vehicle_name][k_total_damage_index] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_total_damage_index].health_percentage = k_total_damage_health_percentage;
    level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array = [];
    level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0] = spawnstruct();
    level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0].damage_effect = loadfx( "explosions/fx_large_vehicle_explosion" );
    level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0].sound_effect = "vehicle_explo";
    level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0].vehicle_tag = "tag_origin";
    default_husk_effects = spawnstruct();
    default_husk_effects.damage_effect = undefined;
    default_husk_effects.sound_effect = undefined;
    default_husk_effects.vehicle_tag = "tag_origin";
    level.vehicles_husk_effects[vehicle_name] = default_husk_effects;
}

get_vehicle_name( vehicle )
{
    name = "";

    if ( isdefined( vehicle ) )
    {
        if ( isdefined( vehicle.vehicletype ) )
            name = vehicle.vehicletype;
    }

    return name;
}

get_default_vehicle_name()
{
    return "defaultvehicle_mp";
}

get_vehicle_name_key_for_damage_states( vehicle )
{
    vehicle_name = get_vehicle_name( vehicle );

    if ( !isdefined( level.vehicles_damage_states[vehicle_name] ) )
        vehicle_name = get_default_vehicle_name();

    return vehicle_name;
}

get_vehicle_damage_state_index_from_health_percentage( vehicle )
{
    damage_state_index = -1;
    vehicle_name = get_vehicle_name_key_for_damage_states();

    for ( test_index = 0; test_index < level.vehicles_damage_states[vehicle_name].size; test_index++ )
    {
        if ( vehicle.current_health_percentage <= level.vehicles_damage_states[vehicle_name][test_index].health_percentage )
        {
            damage_state_index = test_index;
            continue;
        }

        break;
    }

    return damage_state_index;
}

update_damage_effects( vehicle, attacker )
{
    if ( vehicle.initial_state.health > 0 )
    {
        previous_damage_state_index = get_vehicle_damage_state_index_from_health_percentage( vehicle );
        vehicle.current_health_percentage = vehicle.health / vehicle.initial_state.health;
        current_damage_state_index = get_vehicle_damage_state_index_from_health_percentage( vehicle );

        if ( previous_damage_state_index != current_damage_state_index )
        {
            vehicle notify( "damage_state_changed" );

            if ( previous_damage_state_index < 0 )
                start_damage_state_index = 0;
            else
                start_damage_state_index = previous_damage_state_index + 1;

            play_damage_state_effects( vehicle, start_damage_state_index, current_damage_state_index );

            if ( vehicle.health <= 0 )
                vehicle kill_vehicle( attacker );
        }
    }
}

play_damage_state_effects( vehicle, start_damage_state_index, end_damage_state_index )
{
    vehicle_name = get_vehicle_name_key_for_damage_states( vehicle );

    for ( damage_state_index = start_damage_state_index; damage_state_index <= end_damage_state_index; damage_state_index++ )
    {
        for ( effect_index = 0; effect_index < level.vehicles_damage_states[vehicle_name][damage_state_index].effect_array.size; effect_index++ )
        {
            effects = level.vehicles_damage_states[vehicle_name][damage_state_index].effect_array[effect_index];
            vehicle thread play_vehicle_effects( effects );
        }
    }
}

play_vehicle_effects( effects, isdamagedtread )
{
    self endon( "delete" );
    self endon( "removed" );

    if ( !isdefined( isdamagedtread ) || isdamagedtread == 0 )
        self endon( "damage_state_changed" );

    if ( isdefined( effects.sound_effect ) )
        self playsound( effects.sound_effect );

    waittime = 0;

    if ( isdefined( effects.damage_effect_loop_time ) )
        waittime = effects.damage_effect_loop_time;

    while ( waittime > 0 )
    {
        if ( isdefined( effects.damage_effect ) )
            playfxontag( effects.damage_effect, self, effects.vehicle_tag );

        wait( waittime );
    }
}

init_vehicle_entities()
{
    vehicles = getentarray( "script_vehicle", "classname" );
    array_thread( vehicles, ::init_original_vehicle );

    if ( isdefined( vehicles ) )
        return vehicles.size;

    return 0;
}

precache_vehicles()
{

}

register_vehicle()
{
    if ( !isdefined( level.vehicles_list ) )
        level.vehicles_list = [];

    level.vehicles_list[level.vehicles_list.size] = self;
}

manage_vehicles()
{
    if ( !isdefined( level.vehicles_list ) )
        return 1;
    else
    {
        max_vehicles = getmaxvehicles();
        newarray = [];

        for ( i = 0; i < level.vehicles_list.size; i++ )
        {
            if ( isdefined( level.vehicles_list[i] ) )
                newarray[newarray.size] = level.vehicles_list[i];
        }

        level.vehicles_list = newarray;
        vehiclestodelete = level.vehicles_list.size + 1 - max_vehicles;

        if ( vehiclestodelete > 0 )
        {
            newarray = [];

            for ( i = 0; i < level.vehicles_list.size; i++ )
            {
                vehicle = level.vehicles_list[i];

                if ( vehiclestodelete > 0 )
                {
                    if ( isdefined( vehicle.is_husk ) && !isdefined( vehicle.permanentlyremoved ) )
                    {
                        deleted = vehicle husk_do_cleanup();

                        if ( deleted )
                        {
                            vehiclestodelete--;
                            continue;
                        }
                    }
                }

                newarray[newarray.size] = vehicle;
            }

            level.vehicles_list = newarray;
        }

        return level.vehicles_list.size < max_vehicles;
    }
}

init_vehicle()
{
    self register_vehicle();

    if ( isdefined( level.vehiclehealths ) && isdefined( level.vehiclehealths[self.vehicletype] ) )
        self.maxhealth = level.vehiclehealths[self.vehicletype];
    else
    {
        self.maxhealth = getdvarint( "scr_veh_health_tank" );
/#
        println( "No health specified for vehicle type " + self.vehicletype + "! Using default..." );
#/
    }

    self.health = self.maxhealth;
    self vehicle_record_initial_values();
    self init_vehicle_threads();
    self maps\mp\gametypes\_spawning::create_vehicle_influencers();
}

initialize_vehicle_damage_state_data()
{
    if ( self.initial_state.health > 0 )
    {
        self.current_health_percentage = self.health / self.initial_state.health;
        self.previous_health_percentage = self.health / self.initial_state.health;
    }
    else
    {
        self.current_health_percentage = 1;
        self.previous_health_percentage = 1;
    }
}

init_original_vehicle()
{
    self.original_vehicle = 1;
    self init_vehicle();
}

vehicle_wait_player_enter_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );

    while ( true )
    {
        self waittill( "enter_vehicle", player );

        player thread player_wait_exit_vehicle_t();
        player player_update_vehicle_hud( 1, self );
    }
}

player_wait_exit_vehicle_t()
{
    self endon( "disconnect" );

    self waittill( "exit_vehicle", vehicle );

    self player_update_vehicle_hud( 0, vehicle );
}

vehicle_wait_damage_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );

    while ( true )
    {
        self waittill( "damage" );

        occupants = self getvehoccupants();

        if ( isdefined( occupants ) )
        {
            for ( i = 0; i < occupants.size; i++ )
                occupants[i] player_update_vehicle_hud( 1, self );
        }
    }
}

player_update_vehicle_hud( show, vehicle )
{
    if ( show )
    {
        if ( !isdefined( self.vehiclehud ) )
        {
            self.vehiclehud = createbar( ( 1, 1, 1 ), 64, 16 );
            self.vehiclehud setpoint( "CENTER", "BOTTOM", 0, -40 );
            self.vehiclehud.alpha = 0.75;
        }

        self.vehiclehud updatebar( vehicle.health / vehicle.initial_state.health );
    }
    else if ( isdefined( self.vehiclehud ) )
        self.vehiclehud destroyelem();

    if ( getdvar( _hash_480B1A1D ) != "" )
    {
        if ( getdvarint( _hash_480B1A1D ) != 0 )
        {
            if ( show )
            {
                if ( !isdefined( self.vehiclehudhealthnumbers ) )
                {
                    self.vehiclehudhealthnumbers = createfontstring( "default", 2.0 );
                    self.vehiclehudhealthnumbers setparent( self.vehiclehud );
                    self.vehiclehudhealthnumbers setpoint( "LEFT", "RIGHT", 8, 0 );
                    self.vehiclehudhealthnumbers.alpha = 0.75;
                    self.vehiclehudhealthnumbers.hidewheninmenu = 0;
                    self.vehiclehudhealthnumbers.archived = 0;
                }

                self.vehiclehudhealthnumbers setvalue( vehicle.health );
            }
            else if ( isdefined( self.vehiclehudhealthnumbers ) )
                self.vehiclehudhealthnumbers destroyelem();
        }
    }
}

init_vehicle_threads()
{
    self thread vehicle_fireweapon_t();
    self thread vehicle_abandoned_by_drift_t();
    self thread vehicle_abandoned_by_occupants_t();
    self thread vehicle_damage_t();
    self thread vehicle_ghost_entering_occupants_t();
    self thread vehicle_recycle_spawner_t();
    self thread vehicle_disconnect_paths();

    if ( isdefined( level.enablevehiclehealthbar ) && level.enablevehiclehealthbar )
    {
        self thread vehicle_wait_player_enter_t();
        self thread vehicle_wait_damage_t();
    }

    self thread vehicle_wait_tread_damage();
    self thread vehicle_overturn_eject_occupants();

    if ( getdvarint( "scr_veh_disableoverturndamage" ) == 0 )
        self thread vehicle_overturn_suicide();
/#
    self thread cleanup_debug_print_t();
    self thread cleanup_debug_print_clearmsg_t();
#/
}

build_template( type, model, typeoverride )
{
    if ( isdefined( typeoverride ) )
        type = typeoverride;

    if ( !isdefined( level.vehicle_death_fx ) )
        level.vehicle_death_fx = [];

    if ( !isdefined( level.vehicle_death_fx[type] ) )
        level.vehicle_death_fx[type] = [];

    level.vehicle_compassicon[type] = 0;
    level.vehicle_team[type] = "axis";
    level.vehicle_life[type] = 999;
    level.vehicle_hasmainturret[model] = 0;
    level.vehicle_mainturrets[model] = [];
    level.vtmodel = model;
    level.vttype = type;
}

build_rumble( rumble, scale, duration, radius, basetime, randomaditionaltime )
{
    if ( !isdefined( level.vehicle_rumble ) )
        level.vehicle_rumble = [];

    struct = build_quake( scale, duration, radius, basetime, randomaditionaltime );
/#
    assert( isdefined( rumble ) );
#/
    precacherumble( rumble );
    struct.rumble = rumble;
    level.vehicle_rumble[level.vttype] = struct;
    precacherumble( "tank_damaged_rumble_mp" );
}

build_quake( scale, duration, radius, basetime, randomaditionaltime )
{
    struct = spawnstruct();
    struct.scale = scale;
    struct.duration = duration;
    struct.radius = radius;

    if ( isdefined( basetime ) )
        struct.basetime = basetime;

    if ( isdefined( randomaditionaltime ) )
        struct.randomaditionaltime = randomaditionaltime;

    return struct;
}

build_exhaust( effect )
{
    level.vehicle_exhaust[level.vtmodel] = loadfx( effect );
}

cleanup_debug_print_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );
/#
    while ( true )
    {
        if ( isdefined( self.debug_message ) && getdvarint( "scr_veh_cleanupdebugprint" ) != 0 )
            print3d( self.origin + vectorscale( ( 0, 0, 1 ), 150.0 ), self.debug_message, ( 0, 1, 0 ), 1, 1, 1 );

        wait 0.01;
    }
#/
}

cleanup_debug_print_clearmsg_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );
/#
    while ( true )
    {
        self waittill( "enter_vehicle" );

        self.debug_message = undefined;
    }
#/
}

cleanup_debug_print( message )
{
/#
    self.debug_message = message;
#/
}

vehicle_abandoned_by_drift_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );
    self wait_then_cleanup_vehicle( "Drift Test", "scr_veh_cleanupdrifted" );
}

vehicle_abandoned_by_occupants_timeout_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );
    self wait_then_cleanup_vehicle( "Abandon Test", "scr_veh_cleanupabandoned" );
}

wait_then_cleanup_vehicle( test_name, cleanup_dvar_name )
{
    self endon( "enter_vehicle" );
    self wait_until_severely_damaged();
    self do_alive_cleanup_wait( test_name );
    self wait_for_vehicle_to_stop_outside_min_radius();
    self cleanup( test_name, cleanup_dvar_name, ::vehicle_recycle );
}

wait_until_severely_damaged()
{
    while ( true )
    {
        health_percentage = self.health / self.initial_state.health;

        if ( isdefined( level.k_severe_damage_health_percentage ) )
            self cleanup_debug_print( "Damage Test: Still healthy - (" + health_percentage + " >= " + level.k_severe_damage_health_percentage + ") and working treads" );
        else
            self cleanup_debug_print( "Damage Test: Still healthy and working treads" );

        self waittill( "damage" );

        health_percentage = self.health / self.initial_state.health;

        if ( health_percentage < level.k_severe_damage_health_percentage )
            break;
    }
}

get_random_cleanup_wait_time( state )
{
    varnameprefix = "scr_veh_" + state + "_cleanuptime";
    mintime = getdvarfloat( varnameprefix + "min" );
    maxtime = getdvarfloat( varnameprefix + "max" );

    if ( maxtime > mintime )
        return randomfloatrange( mintime, maxtime );
    else
        return maxtime;
}

do_alive_cleanup_wait( test_name )
{
    initialrandomwaitseconds = get_random_cleanup_wait_time( "alive" );
    secondswaited = 0.0;
    seconds_per_iteration = 1.0;

    while ( true )
    {
        curve_begin = getdvarfloat( "scr_veh_cleanuptime_dmgfraction_curve_begin" );
        curve_end = getdvarfloat( "scr_veh_cleanuptime_dmgfraction_curve_end" );
        factor_min = getdvarfloat( "scr_veh_cleanuptime_dmgfactor_min" );
        factor_max = getdvarfloat( "scr_veh_cleanuptime_dmgfactor_max" );
        treaddeaddamagefactor = getdvarfloat( "scr_veh_cleanuptime_dmgfactor_deadtread" );
        damagefraction = 0.0;

        if ( self is_vehicle() )
            damagefraction = ( self.initial_state.health - self.health ) / self.initial_state.health;
        else
            damagefraction = 1.0;

        damagefactor = 0.0;

        if ( damagefraction <= curve_begin )
            damagefactor = factor_max;
        else if ( damagefraction >= curve_end )
            damagefactor = factor_min;
        else
        {
            dydx = ( factor_min - factor_max ) / ( curve_end - curve_begin );
            damagefactor = factor_max + ( damagefraction - curve_begin ) * dydx;
        }

        totalsecstowait = initialrandomwaitseconds * damagefactor;

        if ( secondswaited >= totalsecstowait )
            break;

        self cleanup_debug_print( test_name + ": Waiting " + totalsecstowait - secondswaited + "s" );
        wait( seconds_per_iteration );
        secondswaited += seconds_per_iteration;
    }
}

do_dead_cleanup_wait( test_name )
{
    total_secs_to_wait = get_random_cleanup_wait_time( "dead" );
    seconds_waited = 0.0;
    seconds_per_iteration = 1.0;

    while ( seconds_waited < total_secs_to_wait )
    {
        self cleanup_debug_print( test_name + ": Waiting " + total_secs_to_wait - seconds_waited + "s" );
        wait( seconds_per_iteration );
        seconds_waited += seconds_per_iteration;
    }
}

cleanup( test_name, cleanup_dvar_name, cleanup_func )
{
    for ( keep_waiting = 1; keep_waiting; keep_waiting = 1 )
    {
        cleanupenabled = !isdefined( cleanup_dvar_name ) || getdvarint( cleanup_dvar_name ) != 0;

        if ( cleanupenabled != 0 )
        {
            self [[ cleanup_func ]]();
            break;
        }

        keep_waiting = 0;
        devblock( loc_395E );
        self cleanup_debug_print( "Cleanup disabled for " + test_name + " ( dvar = " + cleanup_dvar_name + " )" );
        wait 5.0;
    }
}

vehicle_wait_tread_damage()
{
    self endon( "death" );
    self endon( "delete" );
    vehicle_name = get_vehicle_name( self );

    while ( true )
    {
        self waittill( "broken", brokennotify );

        if ( brokennotify == "left_tread_destroyed" )
        {
            if ( isdefined( level.vehicles_damage_treadfx[vehicle_name] ) && isdefined( level.vehicles_damage_treadfx[vehicle_name][0] ) )
                self thread play_vehicle_effects( level.vehicles_damage_treadfx[vehicle_name][0], 1 );
        }
        else if ( brokennotify == "right_tread_destroyed" )
        {
            if ( isdefined( level.vehicles_damage_treadfx[vehicle_name] ) && isdefined( level.vehicles_damage_treadfx[vehicle_name][1] ) )
                self thread play_vehicle_effects( level.vehicles_damage_treadfx[vehicle_name][1], 1 );
        }
    }
}

wait_for_vehicle_to_stop_outside_min_radius()
{
    maxwaittime = getdvarfloat( "scr_veh_waittillstoppedandmindist_maxtime" );
    iterationwaitseconds = 1.0;
    maxwaittimeenabledistinches = 12 * getdvarfloat( "scr_veh_waittillstoppedandmindist_maxtimeenabledistfeet" );
    initialorigin = self.initial_state.origin;

    for ( totalsecondswaited = 0.0; totalsecondswaited < maxwaittime; totalsecondswaited += iterationwaitseconds )
    {
        speedmph = self getspeedmph();
        cutoffmph = getdvarfloat( "scr_veh_cleanupmaxspeedmph" );

        if ( speedmph > cutoffmph )
            cleanup_debug_print( "(" + maxwaittime - totalsecondswaited + "s) Speed: " + speedmph + ">" + cutoffmph );
        else
            break;

        wait( iterationwaitseconds );
    }
}

vehicle_abandoned_by_occupants_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );

    while ( true )
    {
        self waittill( "exit_vehicle" );

        occupants = self getvehoccupants();

        if ( occupants.size == 0 )
        {
            self play_start_stop_sound( "tank_shutdown_sfx" );
            self thread vehicle_abandoned_by_occupants_timeout_t();
        }
    }
}

play_start_stop_sound( sound_alias, modulation )
{
    if ( isdefined( self.start_stop_sfxid ) )
    {

    }

    self.start_stop_sfxid = self playsound( sound_alias );
}

vehicle_ghost_entering_occupants_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );

    while ( true )
    {
        self waittill( "enter_vehicle", player, seat );

        isdriver = seat == 0;

        if ( getdvarint( "scr_veh_driversarehidden" ) != 0 && isdriver )
            player ghost();

        occupants = self getvehoccupants();

        if ( occupants.size == 1 )
            self play_start_stop_sound( "tank_startup_sfx" );

        player thread player_change_seat_handler_t( self );
        player thread player_leave_vehicle_cleanup_t( self );
    }
}

player_is_occupant_invulnerable( smeansofdeath )
{
    if ( self isremotecontrolling() )
        return 0;

    if ( !isdefined( level.vehicle_drivers_are_invulnerable ) )
        level.vehicle_drivers_are_invulnerable = 0;

    invulnerable = level.vehicle_drivers_are_invulnerable && self player_is_driver();
    return invulnerable;
}

player_is_driver()
{
    if ( !isalive( self ) )
        return false;

    vehicle = self getvehicleoccupied();

    if ( isdefined( vehicle ) )
    {
        seat = vehicle getoccupantseat( self );

        if ( isdefined( seat ) && seat == 0 )
            return true;
    }

    return false;
}

player_change_seat_handler_t( vehicle )
{
    self endon( "disconnect" );
    self endon( "exit_vehicle" );

    while ( true )
    {
        self waittill( "change_seat", vehicle, oldseat, newseat );

        isdriver = newseat == 0;

        if ( isdriver )
        {
            if ( getdvarint( "scr_veh_driversarehidden" ) != 0 )
                self ghost();
        }
        else
            self show();
    }
}

player_leave_vehicle_cleanup_t( vehicle )
{
    self endon( "disconnect" );

    self waittill( "exit_vehicle" );

    currentweapon = self getcurrentweapon();

    if ( self.lastweapon != currentweapon && self.lastweapon != "none" )
        self switchtoweapon( self.lastweapon );

    self show();
}

vehicle_is_tank()
{
    return self.vehicletype == "sherman_mp" || self.vehicletype == "panzer4_mp" || self.vehicletype == "type97_mp" || self.vehicletype == "t34_mp";
}

vehicle_record_initial_values()
{
    if ( !isdefined( self.initial_state ) )
        self.initial_state = spawnstruct();

    if ( isdefined( self.origin ) )
        self.initial_state.origin = self.origin;

    if ( isdefined( self.angles ) )
        self.initial_state.angles = self.angles;

    if ( isdefined( self.health ) )
        self.initial_state.health = self.health;

    self initialize_vehicle_damage_state_data();
}

vehicle_fireweapon_t()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );

    for (;;)
    {
        self waittill( "turret_fire", player );

        if ( isdefined( player ) && isalive( player ) && player isinvehicle() )
            self fireweapon();
    }
}

vehicle_should_explode_on_cleanup()
{
    return getdvarint( "scr_veh_explode_on_cleanup" ) != 0;
}

vehicle_recycle()
{
    self wait_for_unnoticeable_cleanup_opportunity();
    self.recycling = 1;
    self suicide();
}

wait_for_vehicle_overturn()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );
    worldup = anglestoup( vectorscale( ( 0, 1, 0 ), 90.0 ) );
    overturned = 0;

    while ( !overturned )
    {
        if ( isdefined( self.angles ) )
        {
            up = anglestoup( self.angles );
            dot = vectordot( up, worldup );

            if ( dot <= 0.0 )
                overturned = 1;
        }

        if ( !overturned )
            wait 1.0;
    }
}

vehicle_overturn_eject_occupants()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );

    for (;;)
    {
        self waittill( "veh_ejectoccupants" );

        if ( isdefined( level.onejectoccupants ) )
            [[ level.onejectoccupants ]]();

        wait 0.25;
    }
}

vehicle_eject_all_occupants()
{
    occupants = self getvehoccupants();

    if ( isdefined( occupants ) )
    {
        for ( i = 0; i < occupants.size; i++ )
        {
            if ( isdefined( occupants[i] ) )
                occupants[i] unlink();
        }
    }
}

vehicle_overturn_suicide()
{
    self endon( "transmute" );
    self endon( "death" );
    self endon( "delete" );
    self wait_for_vehicle_overturn();
    seconds = randomfloatrange( 5, 7 );
    wait( seconds );
    damageorigin = self.origin + vectorscale( ( 0, 0, 1 ), 25.0 );
    self finishvehicleradiusdamage( self, self, 32000, 32000, 32000, 0, "MOD_EXPLOSIVE", "defaultweapon_mp", damageorigin, 400, -1, ( 0, 0, 1 ), 0 );
}

suicide()
{
    self kill_vehicle( self );
}

kill_vehicle( attacker )
{
    damageorigin = self.origin + ( 0, 0, 1 );
    self finishvehicleradiusdamage( attacker, attacker, 32000, 32000, 10, 0, "MOD_EXPLOSIVE", "defaultweapon_mp", damageorigin, 400, -1, ( 0, 0, 1 ), 0 );
}

value_with_default( preferred_value, default_value )
{
    if ( isdefined( preferred_value ) )
        return preferred_value;

    return default_value;
}

vehicle_transmute( attacker )
{
    deathorigin = self.origin;
    deathangles = self.angles;
    modelname = self vehgetmodel();
    vehicle_name = get_vehicle_name_key_for_damage_states( self );
    respawn_parameters = spawnstruct();
    respawn_parameters.origin = self.initial_state.origin;
    respawn_parameters.angles = self.initial_state.angles;
    respawn_parameters.health = self.initial_state.health;
    respawn_parameters.modelname = modelname;
    respawn_parameters.targetname = value_with_default( self.targetname, "" );
    respawn_parameters.vehicletype = value_with_default( self.vehicletype, "" );
    respawn_parameters.destructibledef = self.destructibledef;
    vehiclewasdestroyed = !isdefined( self.recycling );

    if ( vehiclewasdestroyed || vehicle_should_explode_on_cleanup() )
    {
        _spawn_explosion( deathorigin );

        if ( vehiclewasdestroyed && getdvarint( "scr_veh_explosion_doradiusdamage" ) != 0 )
        {
            explosionradius = getdvarint( "scr_veh_explosion_radius" );
            explosionmindamage = getdvarint( "scr_veh_explosion_mindamage" );
            explosionmaxdamage = getdvarint( "scr_veh_explosion_maxdamage" );
            self kill_vehicle( attacker );
            self radiusdamage( deathorigin, explosionradius, explosionmaxdamage, explosionmindamage, attacker, "MOD_EXPLOSIVE", self.vehicletype + "_explosion_mp" );
        }
    }

    self notify( "transmute" );
    respawn_vehicle_now = 1;

    if ( vehiclewasdestroyed && getdvarint( "scr_veh_ondeath_createhusk" ) != 0 )
    {
        if ( getdvarint( "scr_veh_ondeath_usevehicleashusk" ) != 0 )
        {
            husk = self;
            self.is_husk = 1;
        }
        else
            husk = _spawn_husk( deathorigin, deathangles, modelname );

        husk _init_husk( vehicle_name, respawn_parameters );

        if ( getdvarint( "scr_veh_respawnafterhuskcleanup" ) != 0 )
            respawn_vehicle_now = 0;
    }

    if ( !isdefined( self.is_husk ) )
        self remove_vehicle_from_world();

    if ( getdvarint( "scr_veh_disablerespawn" ) != 0 )
        respawn_vehicle_now = 0;

    if ( respawn_vehicle_now )
        respawn_vehicle( respawn_parameters );
}

respawn_vehicle( respawn_parameters )
{
    mintime = getdvarint( "scr_veh_respawntimemin" );
    maxtime = getdvarint( "scr_veh_respawntimemax" );
    seconds = randomfloatrange( mintime, maxtime );
    wait( seconds );
    wait_until_vehicle_position_wont_telefrag( respawn_parameters.origin );

    if ( !manage_vehicles() )
    {
/#
        iprintln( "Vehicle can't respawn because MAX_VEHICLES has been reached and none of the vehicles could be cleaned up." );
#/
    }
    else
    {
        if ( isdefined( respawn_parameters.destructibledef ) )
            vehicle = spawnvehicle( respawn_parameters.modelname, respawn_parameters.targetname, respawn_parameters.vehicletype, respawn_parameters.origin, respawn_parameters.angles, respawn_parameters.destructibledef );
        else
            vehicle = spawnvehicle( respawn_parameters.modelname, respawn_parameters.targetname, respawn_parameters.vehicletype, respawn_parameters.origin, respawn_parameters.angles );

        vehicle.vehicletype = respawn_parameters.vehicletype;
        vehicle.destructibledef = respawn_parameters.destructibledef;
        vehicle.health = respawn_parameters.health;
        vehicle init_vehicle();
        vehicle vehicle_telefrag_griefers_at_position( respawn_parameters.origin );
    }
}

remove_vehicle_from_world()
{
    self notify( "removed" );

    if ( isdefined( self.original_vehicle ) )
    {
        if ( !isdefined( self.permanentlyremoved ) )
        {
            self.permanentlyremoved = 1;
            self thread hide_vehicle();
        }

        return false;
    }
    else
    {
        self _delete_entity();
        return true;
    }
}

_delete_entity()
{
/#

#/
    self delete();
}

hide_vehicle()
{
    under_the_world = ( self.origin[0], self.origin[1], self.origin[2] - 10000 );
    self.origin = under_the_world;
    wait 0.1;
    self hide();
    self notify( "hidden_permanently" );
}

wait_for_unnoticeable_cleanup_opportunity()
{
    maxpreventdistancefeet = getdvarint( "scr_veh_disappear_maxpreventdistancefeet" );
    maxpreventvisibilityfeet = getdvarint( "scr_veh_disappear_maxpreventvisibilityfeet" );
    maxpreventdistanceinchessq = 144 * maxpreventdistancefeet * maxpreventdistancefeet;
    maxpreventvisibilityinchessq = 144 * maxpreventvisibilityfeet * maxpreventvisibilityfeet;
    maxsecondstowait = getdvarfloat( "scr_veh_disappear_maxwaittime" );
    iterationwaitseconds = 1.0;

    for ( secondswaited = 0.0; secondswaited < maxsecondstowait; secondswaited += iterationwaitseconds )
    {
        players_s = get_all_alive_players_s();
        oktocleanup = 1;

        for ( j = 0; j < players_s.a.size && oktocleanup; j++ )
        {
            player = players_s.a[j];
            distinchessq = distancesquared( self.origin, player.origin );

            if ( distinchessq < maxpreventdistanceinchessq )
            {
                self cleanup_debug_print( "(" + maxsecondstowait - secondswaited + "s) Player too close: " + distinchessq + "<" + maxpreventdistanceinchessq );
                oktocleanup = 0;
                continue;
            }

            if ( distinchessq < maxpreventvisibilityinchessq )
            {
                vehiclevisibilityfromplayer = self sightconetrace( player.origin, player, anglestoforward( player.angles ) );

                if ( vehiclevisibilityfromplayer > 0 )
                {
                    self cleanup_debug_print( "(" + maxsecondstowait - secondswaited + "s) Player can see" );
                    oktocleanup = 0;
                }
            }
        }

        if ( oktocleanup )
            return;

        wait( iterationwaitseconds );
    }
}

wait_until_vehicle_position_wont_telefrag( position )
{
    maxiterations = getdvarint( "scr_veh_respawnwait_maxiterations" );
    iterationwaitseconds = getdvarint( "scr_veh_respawnwait_iterationwaitseconds" );

    for ( i = 0; i < maxiterations; i++ )
    {
        if ( !vehicle_position_will_telefrag( position ) )
            return;

        wait( iterationwaitseconds );
    }
}

vehicle_position_will_telefrag( position )
{
    players_s = get_all_alive_players_s();

    for ( i = 0; i < players_s.a.size; i++ )
    {
        if ( players_s.a[i] player_vehicle_position_will_telefrag( position ) )
            return true;
    }

    return false;
}

vehicle_telefrag_griefers_at_position( position )
{
    attacker = self;
    inflictor = self;
    players_s = get_all_alive_players_s();

    for ( i = 0; i < players_s.a.size; i++ )
    {
        player = players_s.a[i];

        if ( player player_vehicle_position_will_telefrag( position ) )
            player dodamage( 20000, player.origin + ( 0, 0, 1 ), attacker, inflictor, "none" );
    }
}

player_vehicle_position_will_telefrag( position )
{
    distanceinches = 240;
    mindistinchessq = distanceinches * distanceinches;
    distinchessq = distancesquared( self.origin, position );
    return distinchessq < mindistinchessq;
}

vehicle_recycle_spawner_t()
{
    self endon( "delete" );

    self waittill( "death", attacker );

    if ( isdefined( self ) )
        self vehicle_transmute( attacker );
}

vehicle_play_explosion_sound()
{
    self playsound( "car_explo_large" );
}

vehicle_damage_t()
{
    self endon( "delete" );
    self endon( "removed" );

    for (;;)
    {
        self waittill( "damage", damage, attacker );

        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( !isalive( players[i] ) )
                continue;

            vehicle = players[i] getvehicleoccupied();

            if ( isdefined( vehicle ) && self == vehicle && players[i] player_is_driver() )
            {
                if ( damage > 0 )
                    earthquake( damage / 400, 1.0, players[i].origin, 512, players[i] );

                if ( damage > 100.0 )
                {
/#
                    println( "Playing heavy rumble." );
#/
                    players[i] playrumbleonentity( "tank_damage_heavy_mp" );
                    continue;
                }

                if ( damage > 10.0 )
                {
/#
                    println( "Playing light rumble." );
#/
                    players[i] playrumbleonentity( "tank_damage_light_mp" );
                }
            }
        }

        update_damage_effects( self, attacker );

        if ( self.health <= 0 )
            return;
    }
}

_spawn_husk( origin, angles, modelname )
{
    husk = spawn( "script_model", origin );
    husk.angles = angles;
    husk setmodel( modelname );
    husk.health = 1;
    husk setcandamage( 0 );
    return husk;
}

is_vehicle()
{
    return isdefined( self.vehicletype );
}

swap_to_husk_model()
{
    if ( isdefined( self.vehicletype ) )
    {
        husk_model = level.veh_husk_models[self.vehicletype];

        if ( isdefined( husk_model ) )
            self setmodel( husk_model );
    }
}

_init_husk( vehicle_name, respawn_parameters )
{
    self swap_to_husk_model();
    effects = level.vehicles_husk_effects[vehicle_name];
    self play_vehicle_effects( effects );
    self.respawn_parameters = respawn_parameters;
    forcepointvariance = getdvarint( "scr_veh_explosion_husk_forcepointvariance" );
    horzvelocityvariance = getdvarint( "scr_veh_explosion_husk_horzvelocityvariance" );
    vertvelocitymin = getdvarint( "scr_veh_explosion_husk_vertvelocitymin" );
    vertvelocitymax = getdvarint( "scr_veh_explosion_husk_vertvelocitymax" );
    forcepointx = randomfloatrange( 0 - forcepointvariance, forcepointvariance );
    forcepointy = randomfloatrange( 0 - forcepointvariance, forcepointvariance );
    forcepoint = ( forcepointx, forcepointy, 0 );
    forcepoint += self.origin;
    initialvelocityx = randomfloatrange( 0 - horzvelocityvariance, horzvelocityvariance );
    initialvelocityy = randomfloatrange( 0 - horzvelocityvariance, horzvelocityvariance );
    initialvelocityz = randomfloatrange( vertvelocitymin, vertvelocitymax );
    initialvelocity = ( initialvelocityx, initialvelocityy, initialvelocityz );

    if ( self is_vehicle() )
        self launchvehicle( initialvelocity, forcepoint );
    else
        self physicslaunch( forcepoint, initialvelocity );

    self thread husk_cleanup_t();
/#
    self thread cleanup_debug_print_t();
#/
}

husk_cleanup_t()
{
    self endon( "death" );
    self endon( "delete" );
    self endon( "hidden_permanently" );
    respawn_parameters = self.respawn_parameters;
    self do_dead_cleanup_wait( "Husk Cleanup Test" );
    self wait_for_unnoticeable_cleanup_opportunity();
    self thread final_husk_cleanup_t( respawn_parameters );
}

final_husk_cleanup_t( respawn_parameters )
{
    self husk_do_cleanup();

    if ( getdvarint( "scr_veh_respawnafterhuskcleanup" ) != 0 )
    {
        if ( getdvarint( "scr_veh_disablerespawn" ) == 0 )
            respawn_vehicle( respawn_parameters );
    }
}

husk_do_cleanup()
{
    self _spawn_explosion( self.origin );

    if ( self is_vehicle() )
        return self remove_vehicle_from_world();
    else
    {
        self _delete_entity();
        return 1;
    }
}

_spawn_explosion( origin )
{
    if ( getdvarint( "scr_veh_explosion_spawnfx" ) == 0 )
        return;

    if ( isdefined( level.vehicle_explosion_effect ) )
    {
        forward = ( 0, 0, 1 );
        rot = randomfloat( 360 );
        up = ( cos( rot ), sin( rot ), 0 );
        playfx( level.vehicle_explosion_effect, origin, forward, up );
    }

    thread _play_sound_in_space( "vehicle_explo", origin );
}

_play_sound_in_space( soundeffectname, origin )
{
    org = spawn( "script_origin", origin );
    org.origin = origin;
    org playsound( soundeffectname );
    wait 10;
    org delete();
}

vehicle_get_occupant_team()
{
    occupants = self getvehoccupants();

    if ( occupants.size != 0 )
    {
        occupant = occupants[0];

        if ( isplayer( occupant ) )
            return occupant.team;
    }

    return "free";
}

vehicledeathwaiter()
{
    self notify( "vehicleDeathWaiter" );
    self endon( "vehicleDeathWaiter" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "vehicle_death", vehicle_died );

        if ( vehicle_died )
            self.diedonvehicle = 1;
        else
            self.diedonturret = 1;
    }
}

turretdeathwaiter()
{

}

vehicle_kill_disconnect_paths_forever()
{
    self notify( "kill_disconnect_paths_forever" );
}

vehicle_disconnect_paths()
{
    self endon( "death" );
    self endon( "kill_disconnect_paths_forever" );

    if ( isdefined( self.script_disconnectpaths ) && !self.script_disconnectpaths )
    {
        self.dontdisconnectpaths = 1;
        return;
    }

    wait( randomfloat( 1 ) );

    while ( isdefined( self ) )
    {
        if ( self getspeed() < 1 )
        {
            if ( !isdefined( self.dontdisconnectpaths ) )
                self disconnectpaths();

            self notify( "speed_zero_path_disconnect" );

            while ( self getspeed() < 1 )
                wait 0.05;
        }

        self connectpaths();
        wait 1;
    }
}

follow_path( node )
{
    self endon( "death" );
/#
    assert( isdefined( node ), "vehicle_path() called without a path" );
#/
    self notify( "newpath" );

    if ( isdefined( node ) )
        self.attachedpath = node;

    pathstart = self.attachedpath;
    self.currentnode = self.attachedpath;

    if ( !isdefined( pathstart ) )
        return;

    self attachpath( pathstart );
    self startpath();
    self endon( "newpath" );
    nextpoint = pathstart;

    while ( isdefined( nextpoint ) )
    {
        self waittill( "reached_node", nextpoint );

        self.currentnode = nextpoint;
        nextpoint notify( "trigger", self );

        if ( isdefined( nextpoint.script_noteworthy ) )
        {
            self notify( nextpoint.script_noteworthy );
            self notify( "noteworthy", nextpoint.script_noteworthy, nextpoint );
        }

        waittillframeend;
    }
}
