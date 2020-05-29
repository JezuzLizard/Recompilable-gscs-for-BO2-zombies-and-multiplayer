#include maps/mp/gametypes/_spawning;
#include maps/mp/killstreaks/_qrdrone;
#include maps/mp/killstreaks/_rcbomb;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "mp_vehicles" );

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
	level.vehicle_drivers_are_invulnerable = getDvarInt( "scr_veh_driversareinvulnerable" );
	level.onejectoccupants = ::vehicle_eject_all_occupants;
	level.vehiclehealths[ "panzer4_mp" ] = 2600;
	level.vehiclehealths[ "t34_mp" ] = 2600;
	setdvar( "scr_veh_health_jeep", "700" );
	if ( init_vehicle_entities() )
	{
		level.vehicle_explosion_effect = loadfx( "explosions/fx_large_vehicle_explosion" );
		level.veh_husk_models = [];
		if ( isDefined( level.use_new_veh_husks ) )
		{
			level.veh_husk_models[ "t34_mp" ] = "veh_t34_destroyed_mp";
		}
		if ( isDefined( level.onaddvehiclehusks ) )
		{
			[[ level.onaddvehiclehusks ]]();
		}
		keys = getarraykeys( level.veh_husk_models );
		i = 0;
		while ( i < keys.size )
		{
			precachemodel( level.veh_husk_models[ keys[ i ] ] );
			i++;
		}
		precacherumble( "tank_damage_light_mp" );
		precacherumble( "tank_damage_heavy_mp" );
		level._effect[ "tanksquish" ] = loadfx( "maps/see2/fx_body_blood_splat" );
	}
	chopper_player_get_on_gun = %int_huey_gunner_on;
	chopper_door_open = %v_huey_door_open;
	chopper_door_open_state = %v_huey_door_open_state;
	chopper_door_closed_state = %v_huey_door_close_state;
	killbrushes = getentarray( "water_killbrush", "targetname" );
	_a123 = killbrushes;
	_k123 = getFirstArrayKey( _a123 );
	while ( isDefined( _k123 ) )
	{
		brush = _a123[ _k123 ];
		brush thread water_killbrush_think();
		_k123 = getNextArrayKey( _a123, _k123 );
	}
	return;
}

water_killbrush_think()
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isDefined( entity ) )
		{
			if ( isDefined( entity.targetname ) )
			{
				if ( entity.targetname == "rcbomb" )
				{
					entity maps/mp/killstreaks/_rcbomb::rcbomb_force_explode();
					break;
				}
				else
				{
					if ( entity.targetname == "talon" && !is_true( entity.dead ) )
					{
						entity notify( "death" );
					}
				}
			}
			if ( isDefined( entity.helitype ) && entity.helitype == "qrdrone" )
			{
				entity maps/mp/killstreaks/_qrdrone::qrdrone_force_destroy();
			}
		}
	}
}

initialize_vehicle_damage_effects_for_level()
{
	k_mild_damage_index = 0;
	k_moderate_damage_index = 1;
	k_severe_damage_index = 2;
	k_total_damage_index = 3;
	k_mild_damage_health_percentage = 0,85;
	k_moderate_damage_health_percentage = 0,55;
	k_severe_damage_health_percentage = 0,35;
	k_total_damage_health_percentage = 0;
	level.k_mild_damage_health_percentage = k_mild_damage_health_percentage;
	level.k_moderate_damage_health_percentage = k_moderate_damage_health_percentage;
	level.k_severe_damage_health_percentage = k_severe_damage_health_percentage;
	level.k_total_damage_health_percentage = k_total_damage_health_percentage;
	level.vehicles_damage_states = [];
	level.vehicles_husk_effects = [];
	level.vehicles_damage_treadfx = [];
	vehicle_name = get_default_vehicle_name();
	level.vehicles_damage_states[ vehicle_name ] = [];
	level.vehicles_damage_treadfx[ vehicle_name ] = [];
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ].health_percentage = k_mild_damage_health_percentage;
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ].effect_array = [];
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ].effect_array[ 0 ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ].effect_array[ 0 ].damage_effect = loadfx( "vehicle/vfire/fx_tank_sherman_smldr" );
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ].effect_array[ 0 ].sound_effect = undefined;
	level.vehicles_damage_states[ vehicle_name ][ k_mild_damage_index ].effect_array[ 0 ].vehicle_tag = "tag_origin";
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ].health_percentage = k_moderate_damage_health_percentage;
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ].effect_array = [];
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ].effect_array[ 0 ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ].effect_array[ 0 ].damage_effect = loadfx( "vehicle/vfire/fx_vfire_med_12" );
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ].effect_array[ 0 ].sound_effect = undefined;
	level.vehicles_damage_states[ vehicle_name ][ k_moderate_damage_index ].effect_array[ 0 ].vehicle_tag = "tag_origin";
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ].health_percentage = k_severe_damage_health_percentage;
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ].effect_array = [];
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ].effect_array[ 0 ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ].effect_array[ 0 ].damage_effect = loadfx( "vehicle/vfire/fx_vfire_sherman" );
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ].effect_array[ 0 ].sound_effect = undefined;
	level.vehicles_damage_states[ vehicle_name ][ k_severe_damage_index ].effect_array[ 0 ].vehicle_tag = "tag_origin";
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ].health_percentage = k_total_damage_health_percentage;
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ].effect_array = [];
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ].effect_array[ 0 ] = spawnstruct();
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ].effect_array[ 0 ].damage_effect = loadfx( "explosions/fx_large_vehicle_explosion" );
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ].effect_array[ 0 ].sound_effect = "vehicle_explo";
	level.vehicles_damage_states[ vehicle_name ][ k_total_damage_index ].effect_array[ 0 ].vehicle_tag = "tag_origin";
	default_husk_effects = spawnstruct();
	default_husk_effects.damage_effect = undefined;
	default_husk_effects.sound_effect = undefined;
	default_husk_effects.vehicle_tag = "tag_origin";
	level.vehicles_husk_effects[ vehicle_name ] = default_husk_effects;
	return;
}

get_vehicle_name( vehicle )
{
	name = "";
	if ( isDefined( vehicle ) )
	{
		if ( isDefined( vehicle.vehicletype ) )
		{
			name = vehicle.vehicletype;
		}
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
	if ( !isDefined( level.vehicles_damage_states[ vehicle_name ] ) )
	{
		vehicle_name = get_default_vehicle_name();
	}
	return vehicle_name;
}

get_vehicle_damage_state_index_from_health_percentage( vehicle )
{
	damage_state_index = -1;
	vehicle_name = get_vehicle_name_key_for_damage_states();
	test_index = 0;
	while ( test_index < level.vehicles_damage_states[ vehicle_name ].size )
	{
		if ( vehicle.current_health_percentage <= level.vehicles_damage_states[ vehicle_name ][ test_index ].health_percentage )
		{
			damage_state_index = test_index;
			test_index++;
			continue;
		}
		else
		{
		}
		test_index++;
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
			{
				start_damage_state_index = 0;
			}
			else
			{
				start_damage_state_index = previous_damage_state_index + 1;
			}
			play_damage_state_effects( vehicle, start_damage_state_index, current_damage_state_index );
			if ( vehicle.health <= 0 )
			{
				vehicle kill_vehicle( attacker );
			}
		}
	}
	return;
}

play_damage_state_effects( vehicle, start_damage_state_index, end_damage_state_index )
{
	vehicle_name = get_vehicle_name_key_for_damage_states( vehicle );
	damage_state_index = start_damage_state_index;
	while ( damage_state_index <= end_damage_state_index )
	{
		effect_index = 0;
		while ( effect_index < level.vehicles_damage_states[ vehicle_name ][ damage_state_index ].effect_array.size )
		{
			effects = level.vehicles_damage_states[ vehicle_name ][ damage_state_index ].effect_array[ effect_index ];
			vehicle thread play_vehicle_effects( effects );
			effect_index++;
		}
		damage_state_index++;
	}
	return;
}

play_vehicle_effects( effects, isdamagedtread )
{
	self endon( "delete" );
	self endon( "removed" );
	if ( !isDefined( isdamagedtread ) || isdamagedtread == 0 )
	{
		self endon( "damage_state_changed" );
	}
	if ( isDefined( effects.sound_effect ) )
	{
		self playsound( effects.sound_effect );
	}
	waittime = 0;
	if ( isDefined( effects.damage_effect_loop_time ) )
	{
		waittime = effects.damage_effect_loop_time;
	}
	while ( waittime > 0 )
	{
		if ( isDefined( effects.damage_effect ) )
		{
			playfxontag( effects.damage_effect, self, effects.vehicle_tag );
		}
		wait waittime;
	}
}

init_vehicle_entities()
{
	vehicles = getentarray( "script_vehicle", "classname" );
	array_thread( vehicles, ::init_original_vehicle );
	if ( isDefined( vehicles ) )
	{
		return vehicles.size;
	}
	return 0;
}

precache_vehicles()
{
}

register_vehicle()
{
	if ( !isDefined( level.vehicles_list ) )
	{
		level.vehicles_list = [];
	}
	level.vehicles_list[ level.vehicles_list.size ] = self;
}

manage_vehicles()
{
	if ( !isDefined( level.vehicles_list ) )
	{
		return 1;
	}
	else
	{
		max_vehicles = getmaxvehicles();
		newarray = [];
		i = 0;
		while ( i < level.vehicles_list.size )
		{
			if ( isDefined( level.vehicles_list[ i ] ) )
			{
				newarray[ newarray.size ] = level.vehicles_list[ i ];
			}
			i++;
		}
		level.vehicles_list = newarray;
		vehiclestodelete = ( level.vehicles_list.size + 1 ) - max_vehicles;
		if ( vehiclestodelete > 0 )
		{
			newarray = [];
			i = 0;
			while ( i < level.vehicles_list.size )
			{
				vehicle = level.vehicles_list[ i ];
				if ( vehiclestodelete > 0 )
				{
					if ( isDefined( vehicle.is_husk ) && !isDefined( vehicle.permanentlyremoved ) )
					{
						deleted = vehicle husk_do_cleanup();
						if ( deleted )
						{
							vehiclestodelete--;

							i++;
							continue;
						}
					}
				}
				else
				{
					newarray[ newarray.size ] = vehicle;
				}
				i++;
			}
			level.vehicles_list = newarray;
		}
		return level.vehicles_list.size < max_vehicles;
	}
}

init_vehicle()
{
	self register_vehicle();
	if ( isDefined( level.vehiclehealths ) && isDefined( level.vehiclehealths[ self.vehicletype ] ) )
	{
		self.maxhealth = level.vehiclehealths[ self.vehicletype ];
	}
	else
	{
		self.maxhealth = getDvarInt( "scr_veh_health_tank" );
/#
		println( "No health specified for vehicle type " + self.vehicletype + "! Using default..." );
#/
	}
	self.health = self.maxhealth;
	self vehicle_record_initial_values();
	self init_vehicle_threads();
	self maps/mp/gametypes/_spawning::create_vehicle_influencers();
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
	return;
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
	while ( 1 )
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
	while ( 1 )
	{
		self waittill( "damage" );
		occupants = self getvehoccupants();
		while ( isDefined( occupants ) )
		{
			i = 0;
			while ( i < occupants.size )
			{
				occupants[ i ] player_update_vehicle_hud( 1, self );
				i++;
			}
		}
	}
}

player_update_vehicle_hud( show, vehicle )
{
	if ( show )
	{
		if ( !isDefined( self.vehiclehud ) )
		{
			self.vehiclehud = createbar( ( 0, 0, 1 ), 64, 16 );
			self.vehiclehud setpoint( "CENTER", "BOTTOM", 0, -40 );
			self.vehiclehud.alpha = 0,75;
		}
		self.vehiclehud updatebar( vehicle.health / vehicle.initial_state.health );
	}
	else
	{
		if ( isDefined( self.vehiclehud ) )
		{
			self.vehiclehud destroyelem();
		}
	}
	if ( getDvar( #"480B1A1D" ) != "" )
	{
		if ( getDvarInt( #"480B1A1D" ) != 0 )
		{
			if ( show )
			{
				if ( !isDefined( self.vehiclehudhealthnumbers ) )
				{
					self.vehiclehudhealthnumbers = createfontstring( "default", 2 );
					self.vehiclehudhealthnumbers setparent( self.vehiclehud );
					self.vehiclehudhealthnumbers setpoint( "LEFT", "RIGHT", 8, 0 );
					self.vehiclehudhealthnumbers.alpha = 0,75;
					self.vehiclehudhealthnumbers.hidewheninmenu = 0;
					self.vehiclehudhealthnumbers.archived = 0;
				}
				self.vehiclehudhealthnumbers setvalue( vehicle.health );
				return;
			}
			else
			{
				if ( isDefined( self.vehiclehudhealthnumbers ) )
				{
					self.vehiclehudhealthnumbers destroyelem();
				}
			}
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
	if ( isDefined( level.enablevehiclehealthbar ) && level.enablevehiclehealthbar )
	{
		self thread vehicle_wait_player_enter_t();
		self thread vehicle_wait_damage_t();
	}
	self thread vehicle_wait_tread_damage();
	self thread vehicle_overturn_eject_occupants();
	if ( getDvarInt( "scr_veh_disableoverturndamage" ) == 0 )
	{
		self thread vehicle_overturn_suicide();
	}
/#
	self thread cleanup_debug_print_t();
	self thread cleanup_debug_print_clearmsg_t();
#/
}

build_template( type, model, typeoverride )
{
	if ( isDefined( typeoverride ) )
	{
		type = typeoverride;
	}
	if ( !isDefined( level.vehicle_death_fx ) )
	{
		level.vehicle_death_fx = [];
	}
	if ( !isDefined( level.vehicle_death_fx[ type ] ) )
	{
		level.vehicle_death_fx[ type ] = [];
	}
	level.vehicle_compassicon[ type ] = 0;
	level.vehicle_team[ type ] = "axis";
	level.vehicle_life[ type ] = 999;
	level.vehicle_hasmainturret[ model ] = 0;
	level.vehicle_mainturrets[ model ] = [];
	level.vtmodel = model;
	level.vttype = type;
}

build_rumble( rumble, scale, duration, radius, basetime, randomaditionaltime )
{
	if ( !isDefined( level.vehicle_rumble ) )
	{
		level.vehicle_rumble = [];
	}
	struct = build_quake( scale, duration, radius, basetime, randomaditionaltime );
/#
	assert( isDefined( rumble ) );
#/
	precacherumble( rumble );
	struct.rumble = rumble;
	level.vehicle_rumble[ level.vttype ] = struct;
	precacherumble( "tank_damaged_rumble_mp" );
}

build_quake( scale, duration, radius, basetime, randomaditionaltime )
{
	struct = spawnstruct();
	struct.scale = scale;
	struct.duration = duration;
	struct.radius = radius;
	if ( isDefined( basetime ) )
	{
		struct.basetime = basetime;
	}
	if ( isDefined( randomaditionaltime ) )
	{
		struct.randomaditionaltime = randomaditionaltime;
	}
	return struct;
}

build_exhaust( effect )
{
	level.vehicle_exhaust[ level.vtmodel ] = loadfx( effect );
}

cleanup_debug_print_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
/#
	while ( 1 )
	{
		if ( isDefined( self.debug_message ) && getDvarInt( "scr_veh_cleanupdebugprint" ) != 0 )
		{
			print3d( self.origin + vectorScale( ( 0, 0, 1 ), 150 ), self.debug_message, ( 0, 0, 1 ), 1, 1, 1 );
		}
		wait 0,01;
#/
	}
}

cleanup_debug_print_clearmsg_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
/#
	while ( 1 )
	{
		self waittill( "enter_vehicle" );
		self.debug_message = undefined;
#/
	}
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
	while ( 1 )
	{
		health_percentage = self.health / self.initial_state.health;
		if ( isDefined( level.k_severe_damage_health_percentage ) )
		{
			self cleanup_debug_print( "Damage Test: Still healthy - (" + health_percentage + " >= " + level.k_severe_damage_health_percentage + ") and working treads" );
		}
		else
		{
			self cleanup_debug_print( "Damage Test: Still healthy and working treads" );
		}
		self waittill( "damage" );
		health_percentage = self.health / self.initial_state.health;
		if ( health_percentage < level.k_severe_damage_health_percentage )
		{
			return;
		}
		else
		{
		}
	}
}

get_random_cleanup_wait_time( state )
{
	varnameprefix = "scr_veh_" + state + "_cleanuptime";
	mintime = getDvarFloat( varnameprefix + "min" );
	maxtime = getDvarFloat( varnameprefix + "max" );
	if ( maxtime > mintime )
	{
		return randomfloatrange( mintime, maxtime );
	}
	else
	{
		return maxtime;
	}
}

do_alive_cleanup_wait( test_name )
{
	initialrandomwaitseconds = get_random_cleanup_wait_time( "alive" );
	secondswaited = 0;
	seconds_per_iteration = 1;
	while ( 1 )
	{
		curve_begin = getDvarFloat( "scr_veh_cleanuptime_dmgfraction_curve_begin" );
		curve_end = getDvarFloat( "scr_veh_cleanuptime_dmgfraction_curve_end" );
		factor_min = getDvarFloat( "scr_veh_cleanuptime_dmgfactor_min" );
		factor_max = getDvarFloat( "scr_veh_cleanuptime_dmgfactor_max" );
		treaddeaddamagefactor = getDvarFloat( "scr_veh_cleanuptime_dmgfactor_deadtread" );
		damagefraction = 0;
		if ( self is_vehicle() )
		{
			damagefraction = ( self.initial_state.health - self.health ) / self.initial_state.health;
		}
		else
		{
			damagefraction = 1;
		}
		damagefactor = 0;
		if ( damagefraction <= curve_begin )
		{
			damagefactor = factor_max;
		}
		else if ( damagefraction >= curve_end )
		{
			damagefactor = factor_min;
		}
		else
		{
			dydx = ( factor_min - factor_max ) / ( curve_end - curve_begin );
			damagefactor = factor_max + ( ( damagefraction - curve_begin ) * dydx );
		}
		totalsecstowait = initialrandomwaitseconds * damagefactor;
		if ( secondswaited >= totalsecstowait )
		{
			return;
		}
		else
		{
			self cleanup_debug_print( ( test_name + ": Waiting " ) + ( totalsecstowait - secondswaited ) + "s" );
			wait seconds_per_iteration;
			secondswaited += seconds_per_iteration;
		}
	}
}

do_dead_cleanup_wait( test_name )
{
	total_secs_to_wait = get_random_cleanup_wait_time( "dead" );
	seconds_waited = 0;
	seconds_per_iteration = 1;
	while ( seconds_waited < total_secs_to_wait )
	{
		self cleanup_debug_print( ( test_name + ": Waiting " ) + ( total_secs_to_wait - seconds_waited ) + "s" );
		wait seconds_per_iteration;
		seconds_waited += seconds_per_iteration;
	}
}

cleanup( test_name, cleanup_dvar_name, cleanup_func )
{
	keep_waiting = 1;
	while ( keep_waiting )
	{
		if ( isDefined( cleanup_dvar_name ) )
		{
			cleanupenabled = getDvarInt( cleanup_dvar_name ) != 0;
		}
		if ( cleanupenabled != 0 )
		{
			self [[ cleanup_func ]]();
			return;
		}
		else
		{
			keep_waiting = 0;
/#
			self cleanup_debug_print( "Cleanup disabled for " + test_name + " ( dvar = " + cleanup_dvar_name + " )" );
			wait 5;
			keep_waiting = 1;
#/
		}
	}
}

vehicle_wait_tread_damage()
{
	self endon( "death" );
	self endon( "delete" );
	vehicle_name = get_vehicle_name( self );
	while ( 1 )
	{
		self waittill( "broken", brokennotify );
		if ( brokennotify == "left_tread_destroyed" )
		{
			if ( isDefined( level.vehicles_damage_treadfx[ vehicle_name ] ) && isDefined( level.vehicles_damage_treadfx[ vehicle_name ][ 0 ] ) )
			{
				self thread play_vehicle_effects( level.vehicles_damage_treadfx[ vehicle_name ][ 0 ], 1 );
			}
			continue;
		}
		else
		{
			if ( brokennotify == "right_tread_destroyed" )
			{
				if ( isDefined( level.vehicles_damage_treadfx[ vehicle_name ] ) && isDefined( level.vehicles_damage_treadfx[ vehicle_name ][ 1 ] ) )
				{
					self thread play_vehicle_effects( level.vehicles_damage_treadfx[ vehicle_name ][ 1 ], 1 );
				}
			}
		}
	}
}

wait_for_vehicle_to_stop_outside_min_radius()
{
	maxwaittime = getDvarFloat( "scr_veh_waittillstoppedandmindist_maxtime" );
	iterationwaitseconds = 1;
	maxwaittimeenabledistinches = 12 * getDvarFloat( "scr_veh_waittillstoppedandmindist_maxtimeenabledistfeet" );
	initialorigin = self.initial_state.origin;
	totalsecondswaited = 0;
	while ( totalsecondswaited < maxwaittime )
	{
		speedmph = self getspeedmph();
		cutoffmph = getDvarFloat( "scr_veh_cleanupmaxspeedmph" );
		if ( speedmph > cutoffmph )
		{
			cleanup_debug_print( "(" + ( maxwaittime - totalsecondswaited ) + "s) Speed: " + speedmph + ">" + cutoffmph );
		}
		else
		{
		}
		wait iterationwaitseconds;
		totalsecondswaited += iterationwaitseconds;
	}
}

vehicle_abandoned_by_occupants_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	while ( 1 )
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
	if ( isDefined( self.start_stop_sfxid ) )
	{
	}
	self.start_stop_sfxid = self playsound( sound_alias );
}

vehicle_ghost_entering_occupants_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	while ( 1 )
	{
		self waittill( "enter_vehicle", player, seat );
		isdriver = seat == 0;
		if ( getDvarInt( "scr_veh_driversarehidden" ) != 0 && isdriver )
		{
			player ghost();
		}
		occupants = self getvehoccupants();
		if ( occupants.size == 1 )
		{
			self play_start_stop_sound( "tank_startup_sfx" );
		}
		player thread player_change_seat_handler_t( self );
		player thread player_leave_vehicle_cleanup_t( self );
	}
}

player_is_occupant_invulnerable( smeansofdeath )
{
	if ( self isremotecontrolling() )
	{
		return 0;
	}
	if ( !isDefined( level.vehicle_drivers_are_invulnerable ) )
	{
		level.vehicle_drivers_are_invulnerable = 0;
	}
	if ( level.vehicle_drivers_are_invulnerable )
	{
		invulnerable = self player_is_driver();
	}
	return invulnerable;
}

player_is_driver()
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	vehicle = self getvehicleoccupied();
	if ( isDefined( vehicle ) )
	{
		seat = vehicle getoccupantseat( self );
		if ( isDefined( seat ) && seat == 0 )
		{
			return 1;
		}
	}
	return 0;
}

player_change_seat_handler_t( vehicle )
{
	self endon( "disconnect" );
	self endon( "exit_vehicle" );
	while ( 1 )
	{
		self waittill( "change_seat", vehicle, oldseat, newseat );
		isdriver = newseat == 0;
		if ( isdriver )
		{
			if ( getDvarInt( "scr_veh_driversarehidden" ) != 0 )
			{
				self ghost();
			}
			continue;
		}
		else
		{
			self show();
		}
	}
}

player_leave_vehicle_cleanup_t( vehicle )
{
	self endon( "disconnect" );
	self waittill( "exit_vehicle" );
	currentweapon = self getcurrentweapon();
	if ( self.lastweapon != currentweapon && self.lastweapon != "none" )
	{
		self switchtoweapon( self.lastweapon );
	}
	self show();
}

vehicle_is_tank()
{
	if ( self.vehicletype != "sherman_mp" && self.vehicletype != "panzer4_mp" && self.vehicletype != "type97_mp" )
	{
		return self.vehicletype == "t34_mp";
	}
}

vehicle_record_initial_values()
{
	if ( !isDefined( self.initial_state ) )
	{
		self.initial_state = spawnstruct();
	}
	if ( isDefined( self.origin ) )
	{
		self.initial_state.origin = self.origin;
	}
	if ( isDefined( self.angles ) )
	{
		self.initial_state.angles = self.angles;
	}
	if ( isDefined( self.health ) )
	{
		self.initial_state.health = self.health;
	}
	self initialize_vehicle_damage_state_data();
	return;
}

vehicle_fireweapon_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	for ( ;; )
	{
		self waittill( "turret_fire", player );
		if ( isDefined( player ) && isalive( player ) && player isinvehicle() )
		{
			self fireweapon();
		}
	}
}

vehicle_should_explode_on_cleanup()
{
	return getDvarInt( "scr_veh_explode_on_cleanup" ) != 0;
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
	worldup = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	overturned = 0;
	while ( !overturned )
	{
		if ( isDefined( self.angles ) )
		{
			up = anglesToUp( self.angles );
			dot = vectordot( up, worldup );
			if ( dot <= 0 )
			{
				overturned = 1;
			}
		}
		if ( !overturned )
		{
			wait 1;
		}
	}
}

vehicle_overturn_eject_occupants()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	for ( ;; )
	{
		self waittill( "veh_ejectoccupants" );
		if ( isDefined( level.onejectoccupants ) )
		{
			[[ level.onejectoccupants ]]();
		}
		wait 0,25;
	}
}

vehicle_eject_all_occupants()
{
	occupants = self getvehoccupants();
	while ( isDefined( occupants ) )
	{
		i = 0;
		while ( i < occupants.size )
		{
			if ( isDefined( occupants[ i ] ) )
			{
				occupants[ i ] unlink();
			}
			i++;
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
	wait seconds;
	damageorigin = self.origin + vectorScale( ( 0, 0, 1 ), 25 );
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
	if ( isDefined( preferred_value ) )
	{
		return preferred_value;
	}
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
	vehiclewasdestroyed = !isDefined( self.recycling );
	if ( vehiclewasdestroyed || vehicle_should_explode_on_cleanup() )
	{
		_spawn_explosion( deathorigin );
		if ( vehiclewasdestroyed && getDvarInt( "scr_veh_explosion_doradiusdamage" ) != 0 )
		{
			explosionradius = getDvarInt( "scr_veh_explosion_radius" );
			explosionmindamage = getDvarInt( "scr_veh_explosion_mindamage" );
			explosionmaxdamage = getDvarInt( "scr_veh_explosion_maxdamage" );
			self kill_vehicle( attacker );
			self radiusdamage( deathorigin, explosionradius, explosionmaxdamage, explosionmindamage, attacker, "MOD_EXPLOSIVE", self.vehicletype + "_explosion_mp" );
		}
	}
	self notify( "transmute" );
	respawn_vehicle_now = 1;
	if ( vehiclewasdestroyed && getDvarInt( "scr_veh_ondeath_createhusk" ) != 0 )
	{
		if ( getDvarInt( "scr_veh_ondeath_usevehicleashusk" ) != 0 )
		{
			husk = self;
			self.is_husk = 1;
		}
		else
		{
			husk = _spawn_husk( deathorigin, deathangles, modelname );
		}
		husk _init_husk( vehicle_name, respawn_parameters );
		if ( getDvarInt( "scr_veh_respawnafterhuskcleanup" ) != 0 )
		{
			respawn_vehicle_now = 0;
		}
	}
	if ( !isDefined( self.is_husk ) )
	{
		self remove_vehicle_from_world();
	}
	if ( getDvarInt( "scr_veh_disablerespawn" ) != 0 )
	{
		respawn_vehicle_now = 0;
	}
	if ( respawn_vehicle_now )
	{
		respawn_vehicle( respawn_parameters );
	}
}

respawn_vehicle( respawn_parameters )
{
	mintime = getDvarInt( "scr_veh_respawntimemin" );
	maxtime = getDvarInt( "scr_veh_respawntimemax" );
	seconds = randomfloatrange( mintime, maxtime );
	wait seconds;
	wait_until_vehicle_position_wont_telefrag( respawn_parameters.origin );
	if ( !manage_vehicles() )
	{
/#
		iprintln( "Vehicle can't respawn because MAX_VEHICLES has been reached and none of the vehicles could be cleaned up." );
#/
	}
	else
	{
		if ( isDefined( respawn_parameters.destructibledef ) )
		{
			vehicle = spawnvehicle( respawn_parameters.modelname, respawn_parameters.targetname, respawn_parameters.vehicletype, respawn_parameters.origin, respawn_parameters.angles, respawn_parameters.destructibledef );
		}
		else
		{
			vehicle = spawnvehicle( respawn_parameters.modelname, respawn_parameters.targetname, respawn_parameters.vehicletype, respawn_parameters.origin, respawn_parameters.angles );
		}
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
	if ( isDefined( self.original_vehicle ) )
	{
		if ( !isDefined( self.permanentlyremoved ) )
		{
			self.permanentlyremoved = 1;
			self thread hide_vehicle();
		}
		return 0;
	}
	else
	{
		self _delete_entity();
		return 1;
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
	under_the_world = ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] - 10000 );
	self.origin = under_the_world;
	wait 0,1;
	self hide();
	self notify( "hidden_permanently" );
}

wait_for_unnoticeable_cleanup_opportunity()
{
	maxpreventdistancefeet = getDvarInt( "scr_veh_disappear_maxpreventdistancefeet" );
	maxpreventvisibilityfeet = getDvarInt( "scr_veh_disappear_maxpreventvisibilityfeet" );
	maxpreventdistanceinchessq = 144 * maxpreventdistancefeet * maxpreventdistancefeet;
	maxpreventvisibilityinchessq = 144 * maxpreventvisibilityfeet * maxpreventvisibilityfeet;
	maxsecondstowait = getDvarFloat( "scr_veh_disappear_maxwaittime" );
	iterationwaitseconds = 1;
	secondswaited = 0;
	while ( secondswaited < maxsecondstowait )
	{
		players_s = get_all_alive_players_s();
		oktocleanup = 1;
		j = 0;
		while ( j < players_s.a.size && oktocleanup )
		{
			player = players_s.a[ j ];
			distinchessq = distancesquared( self.origin, player.origin );
			if ( distinchessq < maxpreventdistanceinchessq )
			{
				self cleanup_debug_print( "(" + ( maxsecondstowait - secondswaited ) + "s) Player too close: " + distinchessq + "<" + maxpreventdistanceinchessq );
				oktocleanup = 0;
				j++;
				continue;
			}
			else
			{
				if ( distinchessq < maxpreventvisibilityinchessq )
				{
					vehiclevisibilityfromplayer = self sightconetrace( player.origin, player, anglesToForward( player.angles ) );
					if ( vehiclevisibilityfromplayer > 0 )
					{
						self cleanup_debug_print( "(" + ( maxsecondstowait - secondswaited ) + "s) Player can see" );
						oktocleanup = 0;
					}
				}
			}
			j++;
		}
		if ( oktocleanup )
		{
			return;
		}
		wait iterationwaitseconds;
		secondswaited += iterationwaitseconds;
	}
}

wait_until_vehicle_position_wont_telefrag( position )
{
	maxiterations = getDvarInt( "scr_veh_respawnwait_maxiterations" );
	iterationwaitseconds = getDvarInt( "scr_veh_respawnwait_iterationwaitseconds" );
	i = 0;
	while ( i < maxiterations )
	{
		if ( !vehicle_position_will_telefrag( position ) )
		{
			return;
		}
		wait iterationwaitseconds;
		i++;
	}
}

vehicle_position_will_telefrag( position )
{
	players_s = get_all_alive_players_s();
	i = 0;
	while ( i < players_s.a.size )
	{
		if ( players_s.a[ i ] player_vehicle_position_will_telefrag( position ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

vehicle_telefrag_griefers_at_position( position )
{
	attacker = self;
	inflictor = self;
	players_s = get_all_alive_players_s();
	i = 0;
	while ( i < players_s.a.size )
	{
		player = players_s.a[ i ];
		if ( player player_vehicle_position_will_telefrag( position ) )
		{
			player dodamage( 20000, player.origin + ( 0, 0, 1 ), attacker, inflictor, "none" );
		}
		i++;
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
	if ( isDefined( self ) )
	{
		self vehicle_transmute( attacker );
	}
}

vehicle_play_explosion_sound()
{
	self playsound( "car_explo_large" );
}

vehicle_damage_t()
{
	self endon( "delete" );
	self endon( "removed" );
	for ( ;; )
	{
		self waittill( "damage", damage, attacker );
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( !isalive( players[ i ] ) )
			{
				i++;
				continue;
			}
			else vehicle = players[ i ] getvehicleoccupied();
			if ( isDefined( vehicle ) && self == vehicle && players[ i ] player_is_driver() )
			{
				if ( damage > 0 )
				{
					earthquake( damage / 400, 1, players[ i ].origin, 512, players[ i ] );
				}
				if ( damage > 100 )
				{
/#
					println( "Playing heavy rumble." );
#/
					players[ i ] playrumbleonentity( "tank_damage_heavy_mp" );
					i++;
					continue;
				}
				else
				{
					if ( damage > 10 )
					{
/#
						println( "Playing light rumble." );
#/
						players[ i ] playrumbleonentity( "tank_damage_light_mp" );
					}
				}
			}
			i++;
		}
		update_damage_effects( self, attacker );
		if ( self.health <= 0 )
		{
			return;
		}
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
	return isDefined( self.vehicletype );
}

swap_to_husk_model()
{
	if ( isDefined( self.vehicletype ) )
	{
		husk_model = level.veh_husk_models[ self.vehicletype ];
		if ( isDefined( husk_model ) )
		{
			self setmodel( husk_model );
		}
	}
}

_init_husk( vehicle_name, respawn_parameters )
{
	self swap_to_husk_model();
	effects = level.vehicles_husk_effects[ vehicle_name ];
	self play_vehicle_effects( effects );
	self.respawn_parameters = respawn_parameters;
	forcepointvariance = getDvarInt( "scr_veh_explosion_husk_forcepointvariance" );
	horzvelocityvariance = getDvarInt( "scr_veh_explosion_husk_horzvelocityvariance" );
	vertvelocitymin = getDvarInt( "scr_veh_explosion_husk_vertvelocitymin" );
	vertvelocitymax = getDvarInt( "scr_veh_explosion_husk_vertvelocitymax" );
	forcepointx = randomfloatrange( 0 - forcepointvariance, forcepointvariance );
	forcepointy = randomfloatrange( 0 - forcepointvariance, forcepointvariance );
	forcepoint = ( forcepointx, forcepointy, 0 );
	forcepoint += self.origin;
	initialvelocityx = randomfloatrange( 0 - horzvelocityvariance, horzvelocityvariance );
	initialvelocityy = randomfloatrange( 0 - horzvelocityvariance, horzvelocityvariance );
	initialvelocityz = randomfloatrange( vertvelocitymin, vertvelocitymax );
	initialvelocity = ( initialvelocityx, initialvelocityy, initialvelocityz );
	if ( self is_vehicle() )
	{
		self launchvehicle( initialvelocity, forcepoint );
	}
	else
	{
		self physicslaunch( forcepoint, initialvelocity );
	}
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
	if ( getDvarInt( "scr_veh_respawnafterhuskcleanup" ) != 0 )
	{
		if ( getDvarInt( "scr_veh_disablerespawn" ) == 0 )
		{
			respawn_vehicle( respawn_parameters );
		}
	}
}

husk_do_cleanup()
{
	self _spawn_explosion( self.origin );
	if ( self is_vehicle() )
	{
		return self remove_vehicle_from_world();
	}
	else
	{
		self _delete_entity();
		return 1;
	}
}

_spawn_explosion( origin )
{
	if ( getDvarInt( "scr_veh_explosion_spawnfx" ) == 0 )
	{
		return;
	}
	if ( isDefined( level.vehicle_explosion_effect ) )
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
		occupant = occupants[ 0 ];
		if ( isplayer( occupant ) )
		{
			return occupant.team;
		}
	}
	return "free";
}

vehicledeathwaiter()
{
	self notify( "vehicleDeathWaiter" );
	self endon( "vehicleDeathWaiter" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "vehicle_death", vehicle_died );
		if ( vehicle_died )
		{
			self.diedonvehicle = 1;
			continue;
		}
		else
		{
			self.diedonturret = 1;
		}
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
	if ( isDefined( self.script_disconnectpaths ) && !self.script_disconnectpaths )
	{
		self.dontdisconnectpaths = 1;
		return;
	}
	wait randomfloat( 1 );
	while ( isDefined( self ) )
	{
		while ( self getspeed() < 1 )
		{
			if ( !isDefined( self.dontdisconnectpaths ) )
			{
				self disconnectpaths();
			}
			self notify( "speed_zero_path_disconnect" );
			while ( self getspeed() < 1 )
			{
				wait 0,05;
			}
		}
		self connectpaths();
		wait 1;
	}
}

follow_path( node )
{
	self endon( "death" );
/#
	assert( isDefined( node ), "vehicle_path() called without a path" );
#/
	self notify( "newpath" );
	if ( isDefined( node ) )
	{
		self.attachedpath = node;
	}
	pathstart = self.attachedpath;
	self.currentnode = self.attachedpath;
	if ( !isDefined( pathstart ) )
	{
		return;
	}
	self attachpath( pathstart );
	self startpath();
	self endon( "newpath" );
	nextpoint = pathstart;
	while ( isDefined( nextpoint ) )
	{
		self waittill( "reached_node", nextpoint );
		self.currentnode = nextpoint;
		nextpoint notify( "trigger" );
		if ( isDefined( nextpoint.script_noteworthy ) )
		{
			self notify( nextpoint.script_noteworthy );
			self notify( "noteworthy" );
		}
		waittillframeend;
	}
}
