#include maps/mp/zombies/_zm_perk_vulture;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

enable_vulture_perk_for_level()
{
	maps/mp/zombies/_zm_perks::register_perk_basic_info( "specialty_nomotionsensor", "vulture", 3000, &"ZOMBIE_PERK_VULTURE", "zombie_perk_bottle_vulture" );
	maps/mp/zombies/_zm_perks::register_perk_precache_func( "specialty_nomotionsensor", ::vulture_precache );
	maps/mp/zombies/_zm_perks::register_perk_clientfields( "specialty_nomotionsensor", ::vulture_register_clientfield, ::vulture_set_clientfield );
	maps/mp/zombies/_zm_perks::register_perk_threads( "specialty_nomotionsensor", ::give_vulture_perk, ::take_vulture_perk );
	maps/mp/zombies/_zm_perks::register_perk_machine( "specialty_nomotionsensor", ::vulture_perk_machine_setup, ::vulture_perk_machine_think );
	maps/mp/zombies/_zm_perks::register_perk_host_migration_func( "specialty_nomotionsensor", ::vulture_host_migration_func );
}

vulture_precache()
{
	precacheitem( "zombie_perk_bottle_vulture" );
	precacheshader( "specialty_vulture_zombies" );
	precachestring( &"ZOMBIE_PERK_VULTURE" );
	precachemodel( "p6_zm_vending_vultureaid" );
	precachemodel( "p6_zm_vending_vultureaid_on" );
	precachemodel( "p6_zm_perk_vulture_ammo" );
	precachemodel( "p6_zm_perk_vulture_points" );
	level._effect[ "vulture_light" ] = loadfx( "misc/fx_zombie_cola_jugg_on" );
	level._effect[ "vulture_perk_zombie_stink" ] = loadfx( "maps/zombie/fx_zm_vulture_perk_stink" );
	level._effect[ "vulture_perk_zombie_stink_trail" ] = loadfx( "maps/zombie/fx_zm_vulture_perk_stink_trail" );
	level._effect[ "vulture_perk_bonus_drop" ] = loadfx( "misc/fx_zombie_powerup_vulture" );
	level._effect[ "vulture_drop_picked_up" ] = loadfx( "misc/fx_zombie_powerup_grab" );
	level._effect[ "vulture_perk_wallbuy_static" ] = loadfx( "maps/zombie/fx_zm_vulture_wallbuy_rifle" );
	level._effect[ "vulture_perk_wallbuy_dynamic" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_question" );
	level._effect[ "vulture_perk_machine_glow_doubletap" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_dbltap" );
	level._effect[ "vulture_perk_machine_glow_juggernog" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_jugg" );
	level._effect[ "vulture_perk_machine_glow_revive" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_revive" );
	level._effect[ "vulture_perk_machine_glow_speed" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_speed" );
	level._effect[ "vulture_perk_machine_glow_marathon" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_marathon" );
	level._effect[ "vulture_perk_machine_glow_mule_kick" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_mule" );
	level._effect[ "vulture_perk_machine_glow_pack_a_punch" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_pap" );
	level._effect[ "vulture_perk_machine_glow_vulture" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_vulture" );
	level._effect[ "vulture_perk_mystery_box_glow" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_mystery_box" );
	level._effect[ "vulture_perk_powerup_drop" ] = loadfx( "maps/zombie/fx_zm_vulture_glow_powerup" );
	level._effect[ "vulture_perk_zombie_eye_glow" ] = loadfx( "misc/fx_zombie_eye_vulture" );
	onplayerconnect_callback( ::vulture_player_connect_callback );
}

vulture_player_connect_callback()
{
	self thread end_game_turn_off_vulture_overlay();
}

end_game_turn_off_vulture_overlay()
{
	self endon( "disconnect" );
	level waittill( "end_game" );
	self thread take_vulture_perk();
}

init_vulture()
{
	setdvarint( "zombies_perk_vulture_pickup_time", 12 );
	setdvarint( "zombies_perk_vulture_pickup_time_stink", 16 );
	setdvarint( "zombies_perk_vulture_drop_chance", 65 );
	setdvarint( "zombies_perk_vulture_ammo_chance", 33 );
	setdvarint( "zombies_perk_vulture_points_chance", 33 );
	setdvarint( "zombies_perk_vulture_stink_chance", 33 );
	setdvarint( "zombies_perk_vulture_drops_max", 20 );
	setdvarint( "zombies_perk_vulture_network_drops_max", 5 );
	setdvarint( "zombies_perk_vulture_network_time_frame", 250 );
	setdvarint( "zombies_perk_vulture_spawn_stink_zombie_cooldown", 12 );
	setdvarint( "zombies_perk_vulture_max_stink_zombies", 4 );
	level.perk_vulture = spawnstruct();
	level.perk_vulture.zombie_stink_array = [];
	level.perk_vulture.drop_time_last = 0;
	level.perk_vulture.drop_slots_for_network = 0;
	level.perk_vulture.last_stink_zombie_spawned = 0;
	level.perk_vulture.use_exit_behavior = 0;
	level.perk_vulture.clientfields = spawnstruct();
	level.perk_vulture.clientfields.scriptmovers = [];
	level.perk_vulture.clientfields.scriptmovers[ "vulture_stink_fx" ] = 0;
	level.perk_vulture.clientfields.scriptmovers[ "vulture_drop_fx" ] = 1;
	level.perk_vulture.clientfields.scriptmovers[ "vulture_drop_pickup" ] = 2;
	level.perk_vulture.clientfields.scriptmovers[ "vulture_powerup_drop" ] = 3;
	level.perk_vulture.clientfields.actors = [];
	level.perk_vulture.clientfields.actors[ "vulture_stink_trail_fx" ] = 0;
	level.perk_vulture.clientfields.actors[ "vulture_eye_glow" ] = 1;
	level.perk_vulture.clientfields.toplayer = [];
	level.perk_vulture.clientfields.toplayer[ "vulture_perk_active" ] = 0;
	registerclientfield( "toplayer", "vulture_perk_toplayer", 12000, 1, "int" );
	registerclientfield( "actor", "vulture_perk_actor", 12000, 2, "int" );
	registerclientfield( "scriptmover", "vulture_perk_scriptmover", 12000, 4, "int" );
	registerclientfield( "zbarrier", "vulture_perk_zbarrier", 12000, 1, "int" );
	registerclientfield( "toplayer", "sndVultureStink", 12000, 1, "int" );
	registerclientfield( "world", "vulture_perk_disable_solo_quick_revive_glow", 12000, 1, "int" );
	registerclientfield( "toplayer", "vulture_perk_disease_meter", 12000, 5, "float" );
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "vulture_stink_overlay", 12000, 120, 31, 1 );
	maps/mp/zombies/_zm_spawner::add_cusom_zombie_spawn_logic( ::vulture_zombie_spawn_func );
	register_zombie_death_event_callback( ::zombies_drop_stink_on_death );
	level thread vulture_perk_watch_mystery_box();
	level thread vulture_perk_watch_fire_sale();
	level thread vulture_perk_watch_powerup_drops();
	level thread vulture_handle_solo_quick_revive();
/#
	assert( !isDefined( level.exit_level_func ), "vulture perk is attempting to use level.exit_level_func, but one already exists for this level!" );
#/
	level.exit_level_func = ::vulture_zombies_find_exit_point;
	level.perk_vulture.invalid_bonus_ammo_weapons = array( "time_bomb_zm", "time_bomb_detonator_zm" );
	if ( !isDefined( level.perk_vulture.func_zombies_find_valid_exit_locations ) )
	{
		level.perk_vulture.func_zombies_find_valid_exit_locations = ::get_valid_exit_points_for_zombie;
	}
	setup_splitscreen_optimizations();
	initialize_bonus_entity_pool();
	initialize_stink_entity_pool();
/#
	level.vulture_devgui_spawn_stink = ::vulture_devgui_spawn_stink;
#/
}

add_additional_stink_locations_for_zone( str_zone, a_zones )
{
	if ( !isDefined( level.perk_vulture.zones_for_extra_stink_locations ) )
	{
		level.perk_vulture.zones_for_extra_stink_locations = [];
	}
	level.perk_vulture.zones_for_extra_stink_locations[ str_zone ] = a_zones;
}

vulture_register_clientfield()
{
	registerclientfield( "toplayer", "perk_vulture", 12000, 2, "int" );
}

vulture_set_clientfield( state )
{
	self setclientfieldtoplayer( "perk_vulture", state );
}

give_vulture_perk()
{
	vulture_debug_text( "player " + self getentitynumber() + " has vulture perk!" );
	if ( !isDefined( self.perk_vulture ) )
	{
		self.perk_vulture = spawnstruct();
	}
	self.perk_vulture.active = 1;
	self vulture_vision_toggle( 1 );
	self vulture_clientfield_toplayer_set( "vulture_perk_active" );
	self thread _vulture_perk_think();
}

take_vulture_perk()
{
	if ( isDefined( self.perk_vulture ) && isDefined( self.perk_vulture.active ) && self.perk_vulture.active )
	{
		vulture_debug_text( "player " + self getentitynumber() + " has lost vulture perk!" );
		self.perk_vulture.active = 0;
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self.ignoreme = 0;
		}
		self vulture_vision_toggle( 0 );
		self vulture_clientfield_toplayer_clear( "vulture_perk_active" );
		self set_vulture_overlay( 0 );
		self.vulture_stink_value = 0;
		self setclientfieldtoplayer( "vulture_perk_disease_meter", 0 );
		self notify( "vulture_perk_lost" );
	}
}

vulture_host_migration_func()
{
	a_vulture_perk_machines = getentarray( "vending_vulture", "targetname" );
	_a235 = a_vulture_perk_machines;
	_k235 = getFirstArrayKey( _a235 );
	while ( isDefined( _k235 ) )
	{
		perk_machine = _a235[ _k235 ];
		if ( isDefined( perk_machine.model ) && perk_machine.model == "p6_zm_vending_vultureaid_on" )
		{
			perk_machine maps/mp/zombies/_zm_perks::perk_fx( undefined, 1 );
			perk_machine thread maps/mp/zombies/_zm_perks::perk_fx( "vulture_light" );
		}
		_k235 = getNextArrayKey( _a235, _k235 );
	}
}

vulture_perk_add_invalid_bonus_ammo_weapon( str_weapon )
{
/#
	assert( isDefined( level.perk_vulture ), "vulture_perk_add_invalid_bonus_ammo_weapon() was called before vulture perk was initialized. Make sure this is called after the vulture perk initialization func!" );
#/
	level.perk_vulture.invalid_bonus_ammo_weapons[ level.perk_vulture.invalid_bonus_ammo_weapons.size ] = str_weapon;
}

vulture_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_vulture_jingle";
	use_trigger.script_string = "vulture_perk";
	use_trigger.script_label = "mus_perks_vulture_sting";
	use_trigger.target = "vending_vulture";
	perk_machine.script_string = "vulture_perk";
	perk_machine.targetname = "vending_vulture";
	bump_trigger.script_string = "vulture_perk";
}

vulture_perk_machine_think()
{
	init_vulture();
	while ( 1 )
	{
		machine = getentarray( "vending_vulture", "targetname" );
		machine_triggers = getentarray( "vending_vulture", "target" );
		array_thread( machine_triggers, ::maps/mp/zombies/_zm_perks::set_power_on, 0 );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "p6_zm_vending_vultureaid" );
			i++;
		}
		level waittill( "specialty_nomotionsensor" + "_on" );
		level notify( "specialty_nomotionsensor" + "_power_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "p6_zm_vending_vultureaid_on" );
			machine[ i ] vibrate( vectorScale( ( 0, 0, 1 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread maps/mp/zombies/_zm_perks::perk_fx( "vulture_light" );
			machine[ i ] thread maps/mp/zombies/_zm_perks::play_loop_on_machine();
			i++;
		}
		array_thread( machine_triggers, ::maps/mp/zombies/_zm_perks::set_power_on, 1 );
		level waittill( "specialty_nomotionsensor" + "_off" );
		array_thread( machine, ::maps/mp/zombies/_zm_perks::turn_perk_off );
	}
}

do_vulture_death( player )
{
	if ( isDefined( self ) )
	{
		self thread _do_vulture_death( player );
	}
}

_do_vulture_death( player )
{
	if ( should_do_vulture_drop( self.origin ) )
	{
		str_bonus = get_vulture_drop_type();
		str_identifier = "_" + self getentitynumber() + "_" + getTime();
		v_drop_origin = groundtrace( self.origin + vectorScale( ( 0, 0, 1 ), 50 ), self.origin - vectorScale( ( 0, 0, 1 ), 100 ), 0, self )[ "position" ];
		player thread show_debug_info( self.origin, str_identifier, str_bonus );
		self thread vulture_drop_funcs( self.origin, player, str_identifier, str_bonus );
	}
}

vulture_drop_funcs( v_origin, player, str_identifier, str_bonus )
{
	vulture_drop_count_increment();
	switch( str_bonus )
	{
		case "ammo":
			e_temp = player _vulture_drop_model( str_identifier, "p6_zm_perk_vulture_ammo", v_origin, vectorScale( ( 0, 0, 1 ), 15 ) );
			self thread check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus );
			break;
		case "points":
			e_temp = player _vulture_drop_model( str_identifier, "p6_zm_perk_vulture_points", v_origin, vectorScale( ( 0, 0, 1 ), 15 ) );
			self thread check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus );
			break;
		case "stink":
			self _drop_zombie_stink( player, str_identifier, str_bonus );
			break;
	}
}

_drop_zombie_stink( player, str_identifier, str_bonus )
{
	self clear_zombie_stink_fx();
	e_temp = player zombie_drops_stink( self, str_identifier );
	e_temp = player _vulture_spawn_fx( str_identifier, self.origin, str_bonus, e_temp );
	clean_up_stink( e_temp );
}

zombie_drops_stink( ai_zombie, str_identifier )
{
	e_temp = ai_zombie.stink_ent;
	if ( isDefined( e_temp ) )
	{
		e_temp thread delay_showing_vulture_ent( self, ai_zombie.origin );
		level.perk_vulture.zombie_stink_array[ level.perk_vulture.zombie_stink_array.size ] = e_temp;
		self delay_notify( str_identifier, getDvarInt( #"DDE8D546" ) );
	}
	return e_temp;
}

delay_showing_vulture_ent( player, v_moveto_pos, str_model, func )
{
	self.drop_time = getTime();
	wait_network_frame();
	wait_network_frame();
	self.origin = v_moveto_pos;
	wait_network_frame();
	if ( isDefined( str_model ) )
	{
		self setmodel( str_model );
	}
	self show();
	if ( isplayer( player ) )
	{
		self setinvisibletoall();
		self setvisibletoplayer( player );
	}
	if ( isDefined( func ) )
	{
		self [[ func ]]();
	}
}

clean_up_stink( e_temp )
{
	e_temp vulture_clientfield_scriptmover_clear( "vulture_stink_fx" );
	arrayremovevalue( level.perk_vulture.zombie_stink_array, e_temp, 0 );
	wait 4;
	e_temp clear_stink_ent();
}

_delete_vulture_ent( n_delay )
{
	if ( !isDefined( n_delay ) )
	{
		n_delay = 0;
	}
	if ( n_delay > 0 )
	{
		self ghost();
		wait n_delay;
	}
	self clear_bonus_ent();
}

_vulture_drop_model( str_identifier, str_model, v_model_origin, v_offset )
{
	if ( !isDefined( v_offset ) )
	{
		v_offset = ( 0, 0, 1 );
	}
	if ( !isDefined( self.perk_vulture_models ) )
	{
		self.perk_vulture_models = [];
	}
	e_temp = get_unused_bonus_ent();
	if ( !isDefined( e_temp ) )
	{
		self notify( str_identifier );
		return;
	}
	e_temp thread delay_showing_vulture_ent( self, v_model_origin + v_offset, str_model, ::set_vulture_drop_fx );
	self.perk_vulture_models[ self.perk_vulture_models.size ] = e_temp;
	e_temp setinvisibletoall();
	e_temp setvisibletoplayer( self );
	e_temp thread _vulture_drop_model_thread( str_identifier, self );
	return e_temp;
}

set_vulture_drop_fx()
{
	self vulture_clientfield_scriptmover_set( "vulture_drop_fx" );
}

_vulture_drop_model_thread( str_identifier, player )
{
	self thread _vulture_model_blink_timeout( player );
	player waittill_any( str_identifier, "death_or_disconnect", "vulture_perk_lost" );
	self vulture_clientfield_scriptmover_clear( "vulture_drop_fx" );
	n_delete_delay = 0,1;
	if ( isDefined( self.picked_up ) && self.picked_up )
	{
		self _play_vulture_drop_pickup_fx();
		n_delete_delay = 1;
	}
	if ( isDefined( player.perk_vulture_models ) )
	{
		arrayremovevalue( player.perk_vulture_models, self, 0 );
		self.perk_vulture_models = remove_undefined_from_array( player.perk_vulture_models );
	}
	self _delete_vulture_ent( n_delete_delay );
}

_vulture_model_blink_timeout( player )
{
	self endon( "death" );
	player endon( "death" );
	player endon( "disconnect" );
	self endon( "stop_vulture_behavior" );
	n_time_total = getDvarInt( #"34FA67DE" );
	n_frames = n_time_total * 20;
	n_section = int( n_frames / 6 );
	n_flash_slow = n_section * 3;
	n_flash_medium = n_section * 4;
	n_flash_fast = n_section * 5;
	b_show = 1;
	i = 0;
	while ( i < n_frames )
	{
		if ( i < n_flash_slow )
		{
			n_multiplier = n_flash_slow;
		}
		else if ( i < n_flash_medium )
		{
			n_multiplier = 10;
		}
		else if ( i < n_flash_fast )
		{
			n_multiplier = 5;
		}
		else
		{
			n_multiplier = 2;
		}
		if ( b_show )
		{
			self show();
			self setinvisibletoall();
			self setvisibletoplayer( player );
		}
		else
		{
			self ghost();
		}
		b_show = !b_show;
		i += n_multiplier;
		wait ( 0,05 * n_multiplier );
	}
}

_vulture_spawn_fx( str_identifier, v_fx_origin, str_bonus, e_temp )
{
	b_delete = 0;
	if ( !isDefined( e_temp ) )
	{
		e_temp = get_unused_bonus_ent();
		if ( !isDefined( e_temp ) )
		{
			self notify( str_identifier );
			return;
		}
		b_delete = 1;
	}
	e_temp thread delay_showing_vulture_ent( self, v_fx_origin, "tag_origin", ::clientfield_set_vulture_stink_enabled );
	if ( isplayer( self ) )
	{
		self waittill_any( str_identifier, "disconnect", "vulture_perk_lost" );
	}
	else
	{
		self waittill( str_identifier );
	}
	if ( b_delete )
	{
		e_temp _delete_vulture_ent();
	}
	return e_temp;
}

clientfield_set_vulture_stink_enabled()
{
	self vulture_clientfield_scriptmover_set( "vulture_stink_fx" );
}

should_do_vulture_drop( v_death_origin )
{
	b_is_inside_playable_area = check_point_in_enabled_zone( v_death_origin, 1 );
	b_ents_are_available = get_unused_bonus_ent_count() > 0;
	b_network_slots_available = level.perk_vulture.drop_slots_for_network < getDvarInt( #"1786213A" );
	n_roll = randomint( 100 );
	b_passed_roll = n_roll > ( 100 - getDvarInt( #"70E3B3FA" ) );
	if ( isDefined( self.is_stink_zombie ) )
	{
		b_is_stink_zombie = self.is_stink_zombie;
	}
	if ( !b_is_stink_zombie )
	{
		if ( b_is_inside_playable_area && b_ents_are_available && b_network_slots_available )
		{
			b_should_drop = b_passed_roll;
		}
	}
	return b_should_drop;
}

get_vulture_drop_type()
{
	n_chance_ammo = getDvarInt( #"F75E07AF" );
	n_chance_points = getDvarInt( #"D7BCDBE2" );
	n_chance_stink = getDvarInt( #"4918C38E" );
	n_total_weight = n_chance_ammo + n_chance_points;
	n_cutoff_ammo = n_chance_ammo;
	n_cutoff_points = n_chance_ammo + n_chance_points;
	n_roll = randomint( n_total_weight );
	if ( n_roll < n_cutoff_ammo )
	{
		str_bonus = "ammo";
	}
	else
	{
		str_bonus = "points";
	}
	if ( isDefined( self.is_stink_zombie ) && self.is_stink_zombie )
	{
		str_bonus = "stink";
	}
	return str_bonus;
}

show_debug_info( v_drop_point, str_identifier, str_bonus )
{
/#
	n_radius = 32;
	if ( str_bonus == "stink" )
	{
		n_radius = 70;
	}
	while ( getDvarInt( #"38E68F2B" ) )
	{
		self endon( str_identifier );
		vulture_debug_text( "zombie dropped " + str_bonus );
		i = 0;
		while ( i < ( get_vulture_drop_duration( str_bonus ) * 20 ) )
		{
			circle( v_drop_point, n_radius, get_debug_circle_color( str_bonus ), 0, 1, 1 );
			wait 0,05;
			i++;
#/
		}
	}
}

get_vulture_drop_duration( str_bonus )
{
	str_dvar = "zombies_perk_vulture_pickup_time";
	if ( str_bonus == "stink" )
	{
		str_dvar = "zombies_perk_vulture_pickup_time_stink";
	}
	n_duration = getDvarInt( str_dvar );
	return n_duration;
}

get_debug_circle_color( str_bonus )
{
	switch( str_bonus )
	{
		case "ammo":
			v_color = ( 0, 0, 1 );
			break;
		case "points":
			v_color = ( 0, 0, 1 );
			break;
		case "stink":
			v_color = ( 0, 0, 1 );
			break;
		default:
			v_color = ( 0, 0, 1 );
			break;
	}
	return v_color;
}

check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus )
{
	if ( !isDefined( e_temp ) )
	{
		return;
	}
	player endon( "death" );
	player endon( "disconnect" );
	e_temp endon( "death" );
	e_temp endon( "stop_vulture_behavior" );
	wait_network_frame();
	n_times_to_check = int( get_vulture_drop_duration( str_bonus ) / 0,15 );
	i = 0;
	while ( i < n_times_to_check )
	{
		b_player_inside_radius = distancesquared( e_temp.origin, player.origin ) < 1024;
		if ( b_player_inside_radius )
		{
			e_temp.picked_up = 1;
			break;
		}
		else
		{
			wait 0,15;
			i++;
		}
	}
	player notify( str_identifier );
	if ( b_player_inside_radius )
	{
		player give_vulture_bonus( str_bonus );
	}
}

_handle_zombie_stink( b_player_inside_radius )
{
	if ( !isDefined( self.perk_vulture.is_in_zombie_stink ) )
	{
		self.perk_vulture.is_in_zombie_stink = 0;
	}
	b_in_stink_last_check = self.perk_vulture.is_in_zombie_stink;
	self.perk_vulture.is_in_zombie_stink = b_player_inside_radius;
	if ( self.perk_vulture.is_in_zombie_stink )
	{
		n_current_time = getTime();
		if ( !b_in_stink_last_check )
		{
			self.perk_vulture.stink_time_entered = n_current_time;
			self toggle_stink_overlay( 1 );
			self thread stink_react_vo();
		}
		if ( isDefined( self.perk_vulture.stink_time_entered ) )
		{
			b_should_ignore_player = ( ( n_current_time - self.perk_vulture.stink_time_entered ) * 0,001 ) >= 0;
		}
		if ( b_should_ignore_player )
		{
			self.ignoreme = 1;
		}
		if ( get_targetable_player_count() == 0 || !self are_any_players_in_adjacent_zone() )
		{
			if ( b_should_ignore_player && !level.perk_vulture.use_exit_behavior )
			{
				level.perk_vulture.use_exit_behavior = 1;
				level.default_find_exit_position_override = ::vulture_perk_should_zombies_resume_find_flesh;
				self thread vulture_zombies_find_exit_point();
			}
		}
	}
	else
	{
		if ( b_in_stink_last_check )
		{
			self.perk_vulture.stink_time_exit = getTime();
			self thread _zombies_reacquire_player_after_leaving_stink();
		}
	}
}

stink_react_vo()
{
	self endon( "death" );
	self endon( "disconnect" );
	wait 1;
	chance = get_response_chance( "vulture_stink" );
	if ( chance > randomintrange( 1, 100 ) )
	{
		self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "vulture_stink" );
	}
}

get_targetable_player_count()
{
	n_targetable_player_count = 0;
	_a819 = get_players();
	_k819 = getFirstArrayKey( _a819 );
	while ( isDefined( _k819 ) )
	{
		player = _a819[ _k819 ];
		if ( !isDefined( player.ignoreme ) || !player.ignoreme )
		{
			n_targetable_player_count++;
		}
		_k819 = getNextArrayKey( _a819, _k819 );
	}
	return n_targetable_player_count;
}

are_any_players_in_adjacent_zone()
{
	b_players_in_adjacent_zone = 0;
	str_zone = self maps/mp/zombies/_zm_zonemgr::get_player_zone();
	_a836 = get_players();
	_k836 = getFirstArrayKey( _a836 );
	while ( isDefined( _k836 ) )
	{
		player = _a836[ _k836 ];
		if ( player == self )
		{
		}
		else
		{
			str_zone_compare = player maps/mp/zombies/_zm_zonemgr::get_player_zone();
			if ( isinarray( level.zones[ str_zone ].adjacent_zones, str_zone_compare ) && isDefined( level.zones[ str_zone ].adjacent_zones[ str_zone_compare ].is_connected ) && level.zones[ str_zone ].adjacent_zones[ str_zone_compare ].is_connected )
			{
				b_players_in_adjacent_zone = 1;
				break;
			}
		}
		else
		{
			_k836 = getNextArrayKey( _a836, _k836 );
		}
	}
	return b_players_in_adjacent_zone;
}

toggle_stink_overlay( b_show_overlay )
{
	if ( !isDefined( self.vulture_stink_value ) )
	{
		self.vulture_stink_value = 0;
	}
	if ( b_show_overlay )
	{
		self thread _ramp_up_stink_overlay();
	}
	else
	{
		self thread _ramp_down_stink_overlay();
	}
}

_ramp_up_stink_overlay( b_instant_change )
{
	if ( !isDefined( b_instant_change ) )
	{
		b_instant_change = 0;
	}
	self notify( "vulture_perk_stink_ramp_up_done" );
	self endon( "vulture_perk_stink_ramp_up_done" );
	self endon( "death_or_disconnect" );
	self endon( "vulture_perk_lost" );
	self setclientfieldtoplayer( "sndVultureStink", 1 );
	if ( !isDefined( level.perk_vulture.stink_change_increment ) )
	{
		level.perk_vulture.stink_change_increment = ( pow( 2, 5 ) * 0,25 ) / 8;
	}
	while ( self.perk_vulture.is_in_zombie_stink )
	{
		self.vulture_stink_value += level.perk_vulture.stink_change_increment;
		if ( self.vulture_stink_value > ( pow( 2, 5 ) - 1 ) )
		{
			self.vulture_stink_value = pow( 2, 5 ) - 1;
		}
		fraction = self _get_disease_meter_fraction();
		self setclientfieldtoplayer( "vulture_perk_disease_meter", fraction );
		self set_vulture_overlay( fraction );
		vulture_debug_text( "disease counter = " + self.vulture_stink_value );
		wait 0,25;
	}
}

set_vulture_overlay( fraction )
{
	state = level.vsmgr[ "overlay" ].info[ "vulture_stink_overlay" ].state;
	if ( fraction > 0 )
	{
		state maps/mp/_visionset_mgr::vsmgr_set_state_active( self, 1 - fraction );
	}
	else
	{
		state maps/mp/_visionset_mgr::vsmgr_set_state_inactive( self );
	}
}

_get_disease_meter_fraction()
{
	return self.vulture_stink_value / ( pow( 2, 5 ) - 1 );
}

_ramp_down_stink_overlay( b_instant_change )
{
	if ( !isDefined( b_instant_change ) )
	{
		b_instant_change = 0;
	}
	self notify( "vulture_perk_stink_ramp_down_done" );
	self endon( "vulture_perk_stink_ramp_down_done" );
	self endon( "death_or_disconnect" );
	self endon( "vulture_perk_lost" );
	self setclientfieldtoplayer( "sndVultureStink", 0 );
	if ( !isDefined( level.perk_vulture.stink_change_decrement ) )
	{
		level.perk_vulture.stink_change_decrement = ( pow( 2, 5 ) * 0,25 ) / 4;
	}
	while ( !self.perk_vulture.is_in_zombie_stink && self.vulture_stink_value > 0 )
	{
		self.vulture_stink_value -= level.perk_vulture.stink_change_decrement;
		if ( self.vulture_stink_value < 0 )
		{
			self.vulture_stink_value = 0;
		}
		fraction = self _get_disease_meter_fraction();
		self set_vulture_overlay( fraction );
		self setclientfieldtoplayer( "vulture_perk_disease_meter", fraction );
		vulture_debug_text( "disease counter = " + self.vulture_stink_value );
		wait 0,25;
	}
}

_zombies_reacquire_player_after_leaving_stink()
{
	self endon( "death_or_disconnect" );
	self notify( "vulture_perk_stop_zombie_reacquire_player" );
	self endon( "vulture_perk_stop_zombie_reacquire_player" );
	self toggle_stink_overlay( 0 );
	while ( self.vulture_stink_value > 0 )
	{
		vulture_debug_text( "zombies ignoring player..." );
		wait 0,25;
	}
	self.ignoreme = 0;
	level.perk_vulture.use_exit_behavior = 0;
}

vulture_perk_should_zombies_resume_find_flesh()
{
	b_should_find_flesh = !is_player_in_zombie_stink();
	return b_should_find_flesh;
}

is_player_in_zombie_stink()
{
	a_players = get_players();
	b_player_in_zombie_stink = 0;
	i = 0;
	while ( !b_player_in_zombie_stink && i < a_players.size )
	{
		if ( isDefined( a_players[ i ].is_in_zombie_stink ) && a_players[ i ].is_in_zombie_stink )
		{
			b_player_in_zombie_stink = 1;
		}
		i++;
	}
	return b_player_in_zombie_stink;
}

give_vulture_bonus( str_bonus )
{
	switch( str_bonus )
	{
		case "ammo":
			self give_bonus_ammo();
			break;
		case "points":
			self give_bonus_points();
			break;
		case "stink":
			self give_bonus_stink();
			break;
		default:
/#
			assert( "invalid bonus string '" + str_bonus + "' used in give_vulture_bonus()!" );
#/
			break;
	}
}

give_bonus_ammo()
{
	str_weapon_current = self getcurrentweapon();
	if ( str_weapon_current != "none" )
	{
		n_heat_value = self isweaponoverheating( 1, str_weapon_current );
		n_fuel_total = weaponfuellife( str_weapon_current );
		b_is_fuel_weapon = n_fuel_total > 0;
		b_is_overheating_weapon = n_heat_value > 0;
		if ( b_is_overheating_weapon )
		{
			n_ammo_refunded = randomintrange( 1, 3 );
			b_weapon_is_overheating = self isweaponoverheating();
			self setweaponoverheating( b_weapon_is_overheating, n_heat_value - n_ammo_refunded );
		}
		else if ( b_is_fuel_weapon )
		{
			n_fuel_used = self getweaponammofuel( str_weapon_current );
			n_fuel_refunded = randomintrange( int( n_fuel_total * 0,01 ), int( n_fuel_total * 0,03 ) );
			self setweaponammofuel( str_weapon_current, n_fuel_used - n_fuel_refunded );
			n_ammo_refunded = ( n_fuel_refunded / n_fuel_total ) * 100;
		}
		else
		{
			if ( is_valid_ammo_bonus_weapon( str_weapon_current ) )
			{
				n_ammo_count_current = self getweaponammostock( str_weapon_current );
				n_ammo_count_max = weaponmaxammo( str_weapon_current );
				n_ammo_refunded = clamp( int( n_ammo_count_max * randomfloatrange( 0, 0,025 ) ), 1, n_ammo_count_max );
				b_is_custom_weapon = self handle_custom_weapon_refunds( str_weapon_current );
				if ( !b_is_custom_weapon )
				{
					self setweaponammostock( str_weapon_current, n_ammo_count_current + n_ammo_refunded );
				}
			}
		}
		self playsoundtoplayer( "zmb_vulture_drop_pickup_ammo", self );
		chance = get_response_chance( "vulture_ammo_drop" );
		if ( chance > randomintrange( 1, 100 ) )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "vulture_ammo_drop" );
		}
/#
		if ( getDvarInt( #"38E68F2B" ) )
		{
			if ( !isDefined( n_ammo_refunded ) )
			{
				n_ammo_refunded = 0;
			}
			vulture_debug_text( ( str_weapon_current + " bullets given: " ) + n_ammo_refunded );
#/
		}
	}
}

is_valid_ammo_bonus_weapon( str_weapon )
{
	if ( !is_placeable_mine( str_weapon ) && !maps/mp/zombies/_zm_equipment::is_placeable_equipment( str_weapon )return !isinarray( level.perk_vulture.invalid_bonus_ammo_weapons, str_weapon );
}

_play_vulture_drop_pickup_fx()
{
	self vulture_clientfield_scriptmover_set( "vulture_drop_pickup" );
}

give_bonus_points( v_fx_origin )
{
	n_multiplier = randomintrange( 1, 5 );
	self maps/mp/zombies/_zm_score::player_add_points( "vulture", 5 * n_multiplier );
	self playsoundtoplayer( "zmb_vulture_drop_pickup_money", self );
	chance = get_response_chance( "vulture_money_drop" );
	if ( chance > randomintrange( 1, 100 ) )
	{
		self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "vulture_money_drop" );
	}
}

give_bonus_stink( v_drop_origin )
{
	self _handle_zombie_stink( 0 );
}

_vulture_perk_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "vulture_perk_lost" );
	while ( 1 )
	{
		b_player_in_zombie_stink = 0;
		if ( !isDefined( level.perk_vulture.zombie_stink_array ) )
		{
			level.perk_vulture.zombie_stink_array = [];
		}
		if ( level.perk_vulture.zombie_stink_array.size > 0 )
		{
			a_close_points = arraysort( level.perk_vulture.zombie_stink_array, self.origin, 1, 300 );
			if ( a_close_points.size > 0 )
			{
				b_player_in_zombie_stink = self _is_player_in_zombie_stink( a_close_points );
			}
		}
		self _handle_zombie_stink( b_player_in_zombie_stink );
		wait randomfloatrange( 0,25, 0,5 );
	}
}

_is_player_in_zombie_stink( a_points )
{
	b_is_in_stink = 0;
	i = 0;
	while ( i < a_points.size )
	{
		if ( distancesquared( a_points[ i ].origin, self.origin ) < 4900 )
		{
			b_is_in_stink = 1;
		}
		i++;
	}
	return b_is_in_stink;
}

vulture_drop_count_increment()
{
	level.perk_vulture.drop_slots_for_network++;
	level thread _decrement_network_slots_after_time();
}

_decrement_network_slots_after_time()
{
	wait ( getDvarInt( #"DB295746" ) * 0,001 );
	level.perk_vulture.drop_slots_for_network--;

}

vulture_zombie_spawn_func()
{
	self endon( "death" );
	self thread add_zombie_eye_glow();
	self waittill( "completed_emerging_into_playable_area" );
	while ( self should_zombie_have_stink() )
	{
		self stink_zombie_array_add();
/#
		while ( isDefined( self.stink_ent ) )
		{
			while ( 1 )
			{
				if ( getDvarInt( #"38E68F2B" ) )
				{
					debugstar( self.origin, 2, ( 0, 0, 1 ) );
				}
				wait 0,1;
#/
			}
		}
	}
}

add_zombie_eye_glow()
{
	self endon( "death" );
	self waittill( "risen" );
	self vulture_clientfield_actor_set( "vulture_eye_glow" );
}

zombies_drop_stink_on_death()
{
	self vulture_clientfield_actor_clear( "vulture_eye_glow" );
	if ( isDefined( self.attacker ) && isplayer( self.attacker ) && self.attacker hasperk( "specialty_nomotionsensor" ) )
	{
		self thread do_vulture_death( self.attacker );
	}
	else
	{
		if ( isDefined( self.is_stink_zombie ) && self.is_stink_zombie && isDefined( self.stink_ent ) )
		{
			str_identifier = "_" + self getentitynumber() + "_" + getTime();
			self thread _drop_zombie_stink( level, str_identifier, "stink" );
		}
	}
}

clear_zombie_stink_fx()
{
	self vulture_clientfield_actor_clear( "vulture_stink_trail_fx" );
}

stink_zombie_array_add()
{
	if ( get_unused_stink_ent_count() > 0 )
	{
		self.stink_ent = get_unused_stink_ent();
		if ( isDefined( self.stink_ent ) )
		{
			self.stink_ent.owner = self;
			wait_network_frame();
			wait_network_frame();
			self.stink_ent thread _show_debug_location();
			self vulture_clientfield_actor_set( "vulture_stink_trail_fx" );
			level.perk_vulture.last_stink_zombie_spawned = getTime();
			self.is_stink_zombie = 1;
		}
	}
	else
	{
		self.is_stink_zombie = 0;
	}
}

should_zombie_have_stink()
{
	if ( isDefined( self.animname ) )
	{
		b_is_zombie = self.animname == "zombie";
	}
	b_cooldown_up = ( getTime() - level.perk_vulture.last_stink_zombie_spawned ) > ( getDvarInt( #"47A03A7E" ) * 1000 );
	b_roll_passed = ( 100 - randomint( 100 ) ) > 50;
	b_stink_ent_available = get_unused_stink_ent_count() > 0;
	if ( b_is_zombie && b_roll_passed && b_cooldown_up )
	{
		b_should_have_stink = b_stink_ent_available;
	}
	return b_should_have_stink;
}

vulture_debug_text( str_text )
{
/#
	if ( getDvarInt( #"38E68F2B" ) )
	{
		iprintln( str_text );
#/
	}
}

vulture_clientfield_scriptmover_set( str_field_name )
{
/#
	assert( isDefined( level.perk_vulture.clientfields.scriptmovers[ str_field_name ] ), str_field_name + " is not a valid client field for vulture perk!" );
#/
	n_value = self getclientfield( "vulture_perk_scriptmover" );
	n_value |= 1 << level.perk_vulture.clientfields.scriptmovers[ str_field_name ];
	self setclientfield( "vulture_perk_scriptmover", n_value );
}

vulture_clientfield_scriptmover_clear( str_field_name )
{
/#
	assert( isDefined( level.perk_vulture.clientfields.scriptmovers[ str_field_name ] ), str_field_name + " is not a valid client field for vulture perk!" );
#/
	n_value = self getclientfield( "vulture_perk_scriptmover" );
	n_value &= 1 << level.perk_vulture.clientfields.scriptmovers[ str_field_name ];
	self setclientfield( "vulture_perk_scriptmover", n_value );
}

vulture_clientfield_actor_set( str_field_name )
{
/#
	assert( isDefined( level.perk_vulture.clientfields.actors[ str_field_name ] ), str_field_name + " is not a valid field for vulture_clientfield_actor_set!" );
#/
	n_value = getclientfield( "vulture_perk_actor" );
	n_value |= 1 << level.perk_vulture.clientfields.actors[ str_field_name ];
	self setclientfield( "vulture_perk_actor", n_value );
}

vulture_clientfield_actor_clear( str_field_name )
{
/#
	assert( isDefined( level.perk_vulture.clientfields.actors[ str_field_name ] ), str_field_name + " is not a valid field for vulture_clientfield_actor_clear!" );
#/
	n_value = getclientfield( "vulture_perk_actor" );
	n_value &= 1 << level.perk_vulture.clientfields.actors[ str_field_name ];
	self setclientfield( "vulture_perk_actor", n_value );
}

vulture_clientfield_toplayer_set( str_field_name )
{
/#
	assert( isDefined( level.perk_vulture.clientfields.toplayer[ str_field_name ] ), str_field_name + " is not a valid client field for vulture perk!" );
#/
	n_value = self getclientfieldtoplayer( "vulture_perk_toplayer" );
	n_value |= 1 << level.perk_vulture.clientfields.toplayer[ str_field_name ];
	self setclientfieldtoplayer( "vulture_perk_toplayer", n_value );
}

vulture_clientfield_toplayer_clear( str_field_name )
{
/#
	assert( isDefined( level.perk_vulture.clientfields.toplayer[ str_field_name ] ), str_field_name + " is not a valid client field for vulture perk!" );
#/
	n_value = self getclientfieldtoplayer( "vulture_perk_toplayer" );
	n_value &= 1 << level.perk_vulture.clientfields.toplayer[ str_field_name ];
	self setclientfieldtoplayer( "vulture_perk_toplayer", n_value );
}

vulture_perk_watch_mystery_box()
{
	wait_network_frame();
	while ( isDefined( level.chests ) && level.chests.size > 0 && isDefined( level.chest_index ) )
	{
		level.chests[ level.chest_index ].zbarrier vulture_perk_shows_mystery_box( 1 );
		flag_wait( "moving_chest_now" );
		level.chests[ level.chest_index ].zbarrier vulture_perk_shows_mystery_box( 0 );
		flag_waitopen( "moving_chest_now" );
	}
}

vulture_perk_shows_mystery_box( b_show )
{
	self setclientfield( "vulture_perk_zbarrier", b_show );
}

vulture_perk_watch_fire_sale()
{
	wait_network_frame();
	while ( isDefined( level.chests ) && level.chests.size > 0 )
	{
		level waittill( "powerup fire sale" );
		i = 0;
		while ( i < level.chests.size )
		{
			if ( i != level.chest_index )
			{
				level.chests[ i ] thread vulture_fire_sale_box_fx_enable();
			}
			i++;
		}
		level waittill( "fire_sale_off" );
		i = 0;
		while ( i < level.chests.size )
		{
			if ( i != level.chest_index )
			{
				level.chests[ i ] thread vulture_fire_sale_box_fx_disable();
			}
			i++;
		}
	}
}

vulture_fire_sale_box_fx_enable()
{
	if ( self.zbarrier.state == "arriving" )
	{
		self.zbarrier waittill( "arrived" );
	}
	self.zbarrier setclientfield( "vulture_perk_zbarrier", 1 );
}

vulture_fire_sale_box_fx_disable()
{
	self.zbarrier setclientfield( "vulture_perk_zbarrier", 0 );
}

vulture_perk_watch_powerup_drops()
{
	while ( 1 )
	{
		level waittill( "powerup_dropped", m_powerup );
		m_powerup thread _powerup_drop_think();
	}
}

_powerup_drop_think()
{
	e_temp = spawn( "script_model", self.origin );
	e_temp setmodel( "tag_origin" );
	e_temp vulture_clientfield_scriptmover_set( "vulture_powerup_drop" );
	self waittill_any( "powerup_timedout", "powerup_grabbed", "death" );
	e_temp vulture_clientfield_scriptmover_clear( "vulture_powerup_drop" );
	wait_network_frame();
	wait_network_frame();
	wait_network_frame();
	e_temp delete();
}

vulture_zombies_find_exit_point()
{
/#
	while ( getDvarInt( #"38E68F2B" ) > 0 )
	{
		_a1459 = level.enemy_dog_locations;
		_k1459 = getFirstArrayKey( _a1459 );
		while ( isDefined( _k1459 ) )
		{
			struct = _a1459[ _k1459 ];
			debugstar( struct.origin, 200, ( 0, 0, 1 ) );
			_k1459 = getNextArrayKey( _a1459, _k1459 );
#/
		}
	}
	a_zombies = get_round_enemy_array();
	i = 0;
	while ( i < a_zombies.size )
	{
		a_zombies[ i ] thread zombie_goes_to_exit_location();
		i++;
	}
}

zombie_goes_to_exit_location()
{
	self endon( "death" );
	if ( isDefined( self.completed_emerging_into_playable_area ) && !self.completed_emerging_into_playable_area )
	{
		self waittill( "completed_emerging_into_playable_area" );
		wait 1;
	}
	s_goal = _get_zombie_exit_point();
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	if ( isDefined( s_goal ) )
	{
		self setgoalpos( s_goal.origin );
	}
	while ( 1 )
	{
		b_passed_override = 1;
		if ( isDefined( level.default_find_exit_position_override ) )
		{
			b_passed_override = [[ level.default_find_exit_position_override ]]();
		}
		if ( !flag( "wait_and_revive" ) && b_passed_override )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

_get_zombie_exit_point()
{
	player = get_players()[ 0 ];
	n_dot_best = 9999999;
	a_exit_points = self [[ level.perk_vulture.func_zombies_find_valid_exit_locations ]]();
/#
	assert( a_exit_points.size > 0, "_get_zombie_exit_point() couldn't find any zombie exit points for player at " + player.origin + "! Add more dog_locations!" );
#/
	i = 0;
	while ( i < a_exit_points.size )
	{
		v_to_player = vectornormalize( player.origin - self.origin );
		v_to_goal = a_exit_points[ i ].origin - self.origin;
		n_dot = vectordot( v_to_player, v_to_goal );
		if ( n_dot < n_dot_best && distancesquared( player.origin, a_exit_points[ i ].origin ) > 360000 )
		{
			nd_best = a_exit_points[ i ];
			n_dot_best = n_dot;
		}
/#
		if ( getDvarInt( #"38E68F2B" ) )
		{
			debugstar( a_exit_points[ i ].origin, 200, ( 0, 0, 1 ) );
#/
		}
		i++;
	}
	return nd_best;
}

get_valid_exit_points_for_zombie()
{
	a_exit_points = level.enemy_dog_locations;
	while ( isDefined( level.perk_vulture.zones_for_extra_stink_locations ) && level.perk_vulture.zones_for_extra_stink_locations.size > 0 )
	{
		a_zones_with_extra_stink_locations = getarraykeys( level.perk_vulture.zones_for_extra_stink_locations );
		_a1560 = level.active_zone_names;
		_k1560 = getFirstArrayKey( _a1560 );
		while ( isDefined( _k1560 ) )
		{
			zone = _a1560[ _k1560 ];
			while ( isinarray( a_zones_with_extra_stink_locations, zone ) )
			{
				a_zones_temp = level.perk_vulture.zones_for_extra_stink_locations[ zone ];
				i = 0;
				while ( i < a_zones_temp.size )
				{
					a_exit_points = arraycombine( a_exit_points, get_zone_dog_locations( a_zones_temp[ i ] ), 0, 0 );
					i++;
				}
			}
			_k1560 = getNextArrayKey( _a1560, _k1560 );
		}
	}
	return a_exit_points;
}

get_zone_dog_locations( str_zone )
{
	a_dog_locations = [];
	if ( isDefined( level.zones[ str_zone ] ) && isDefined( level.zones[ str_zone ].dog_locations ) )
	{
		a_dog_locations = level.zones[ str_zone ].dog_locations;
	}
	return a_dog_locations;
}

vulture_vision_toggle( b_enable )
{
}

vulture_handle_solo_quick_revive()
{
	flag_wait( "initial_blackscreen_passed" );
	if ( flag( "solo_game" ) )
	{
		flag_wait( "solo_revive" );
		setclientfield( "vulture_perk_disable_solo_quick_revive_glow", 1 );
	}
}

vulture_devgui_spawn_stink()
{
/#
	player = gethostplayer();
	forward_dir = vectornormalize( anglesToForward( player.angles ) );
	target_pos = player.origin + ( forward_dir * 100 ) + vectorScale( ( 0, 0, 1 ), 50 );
	target_pos_down = target_pos + vectorScale( ( 0, 0, 1 ), 150 );
	str_bonus = "stink";
	str_identifier = "_" + "test_" + getTime();
	drop_pos = groundtrace( target_pos, target_pos_down, 0, player )[ "position" ];
	setdvarint( "zombies_debug_vulture_perk", 1 );
	player thread show_debug_info( drop_pos, str_identifier, str_bonus );
	e_temp = player maps/mp/zombies/_zm_perk_vulture::zombie_drops_stink( drop_pos, str_identifier );
	e_temp = player maps/mp/zombies/_zm_perk_vulture::_vulture_spawn_fx( str_identifier, drop_pos, str_bonus, e_temp );
	maps/mp/zombies/_zm_perk_vulture::clean_up_stink( e_temp );
#/
}

setup_splitscreen_optimizations()
{
	if ( level.splitscreen && getDvarInt( "splitscreen_playerCount" ) > 2 )
	{
		setdvarint( "zombies_perk_vulture_drops_max", int( getDvarInt( #"612F9831" ) * 0,5 ) );
		setdvarint( "zombies_perk_vulture_spawn_stink_zombie_cooldown", int( getDvarInt( #"47A03A7E" ) * 2 ) );
		setdvarint( "zombies_perk_vulture_max_stink_zombies", int( getDvarInt( #"16BCAE6A" ) * 0,5 ) );
	}
}

initialize_bonus_entity_pool()
{
	n_ent_pool_size = getDvarInt( #"612F9831" );
	level.perk_vulture.bonus_drop_ent_pool = [];
	i = 0;
	while ( i < n_ent_pool_size )
	{
		e_temp = spawn( "script_model", ( 0, 0, 1 ) );
		e_temp setmodel( "tag_origin" );
		e_temp.targetname = "vulture_perk_bonus_pool_ent";
		e_temp.in_use = 0;
		level.perk_vulture.bonus_drop_ent_pool[ level.perk_vulture.bonus_drop_ent_pool.size ] = e_temp;
		i++;
	}
}

get_unused_bonus_ent()
{
	e_found = undefined;
	i = 0;
	while ( i < level.perk_vulture.bonus_drop_ent_pool.size && !isDefined( e_found ) )
	{
		if ( !level.perk_vulture.bonus_drop_ent_pool[ i ].in_use )
		{
			e_found = level.perk_vulture.bonus_drop_ent_pool[ i ];
			e_found.in_use = 1;
		}
		i++;
	}
	return e_found;
}

get_unused_bonus_ent_count()
{
	n_found = 0;
	i = 0;
	while ( i < level.perk_vulture.bonus_drop_ent_pool.size )
	{
		if ( !level.perk_vulture.bonus_drop_ent_pool[ i ].in_use )
		{
			n_found++;
		}
		i++;
	}
	return n_found;
}

clear_bonus_ent()
{
	self notify( "stop_vulture_behavior" );
	self vulture_clientfield_scriptmover_clear( "vulture_drop_fx" );
	self.in_use = 0;
	self setmodel( "tag_origin" );
	self ghost();
}

initialize_stink_entity_pool()
{
	n_ent_pool_size = getDvarInt( #"16BCAE6A" );
	level.perk_vulture.stink_ent_pool = [];
	i = 0;
	while ( i < n_ent_pool_size )
	{
		e_temp = spawn( "script_model", ( 0, 0, 1 ) );
		e_temp setmodel( "tag_origin" );
		e_temp.targetname = "vulture_perk_bonus_pool_ent";
		e_temp.in_use = 0;
		level.perk_vulture.stink_ent_pool[ level.perk_vulture.stink_ent_pool.size ] = e_temp;
		i++;
	}
}

get_unused_stink_ent_count()
{
	n_found = 0;
	i = 0;
	while ( i < level.perk_vulture.stink_ent_pool.size )
	{
		if ( !level.perk_vulture.stink_ent_pool[ i ].in_use )
		{
			n_found++;
			i++;
			continue;
		}
		else
		{
			if ( !isDefined( level.perk_vulture.stink_ent_pool[ i ].owner ) && !isDefined( level.perk_vulture.stink_ent_pool[ i ].drop_time ) )
			{
				level.perk_vulture.stink_ent_pool[ i ] clear_stink_ent();
				n_found++;
			}
		}
		i++;
	}
	return n_found;
}

get_unused_stink_ent()
{
	e_found = undefined;
	i = 0;
	while ( i < level.perk_vulture.stink_ent_pool.size && !isDefined( e_found ) )
	{
		if ( !level.perk_vulture.stink_ent_pool[ i ].in_use )
		{
			e_found = level.perk_vulture.stink_ent_pool[ i ];
			e_found.in_use = 1;
			vulture_debug_text( "vulture stink >> ent " + e_found getentitynumber() + " in use" );
		}
		i++;
	}
	return e_found;
}

clear_stink_ent()
{
	vulture_debug_text( "vulture stink >> ent " + self getentitynumber() + " CLEAR" );
	self vulture_clientfield_scriptmover_clear( "vulture_stink_fx" );
	self notify( "stop_vulture_behavior" );
	self.in_use = 0;
	self.drop_time = undefined;
	self.owner = undefined;
	self setmodel( "tag_origin" );
	self ghost();
}

_show_debug_location()
{
/#
	while ( self.in_use )
	{
		if ( getDvarInt( #"38E68F2B" ) > 0 )
		{
			debugstar( self.origin, 1, ( 0, 0, 1 ) );
			print3d( self.origin, self getentitynumber(), ( 0, 0, 1 ), 1, 1, 1 );
		}
		wait 0,05;
#/
	}
}

handle_custom_weapon_refunds( str_weapon )
{
	b_is_custom_weapon = 0;
	if ( issubstr( str_weapon, "knife_ballistic" ) )
	{
		self _refund_oldest_ballistic_knife( str_weapon );
		b_is_custom_weapon = 1;
	}
	return b_is_custom_weapon;
}

_refund_oldest_ballistic_knife( str_weapon )
{
	self endon( "death_or_disconnect" );
	self endon( "vulture_perk_lost" );
	if ( isDefined( self.weaponobjectwatcherarray ) && self.weaponobjectwatcherarray.size > 0 )
	{
		b_found_weapon_object = 0;
		i = 0;
		while ( i < self.weaponobjectwatcherarray.size )
		{
			if ( isDefined( self.weaponobjectwatcherarray[ i ].weapon ) && self.weaponobjectwatcherarray[ i ].weapon == str_weapon )
			{
				s_found = self.weaponobjectwatcherarray[ i ];
				break;
			}
			else
			{
				i++;
			}
		}
		if ( isDefined( s_found ) )
		{
			if ( isDefined( s_found.objectarray ) && s_found.objectarray.size > 0 )
			{
				e_oldest = undefined;
				i = 0;
				while ( i < s_found.objectarray.size )
				{
					if ( isDefined( s_found.objectarray[ i ] ) )
					{
						if ( isDefined( s_found.objectarray[ i ].retrievabletrigger ) && isDefined( s_found.objectarray[ i ].retrievabletrigger.owner ) || s_found.objectarray[ i ].retrievabletrigger.owner != self && !isDefined( s_found.objectarray[ i ].birthtime ) )
						{
							i++;
							continue;
						}
						else
						{
							if ( !isDefined( e_oldest ) )
							{
								e_oldest = s_found.objectarray[ i ];
							}
							if ( s_found.objectarray[ i ].birthtime < e_oldest.birthtime )
							{
								e_oldest = s_found.objectarray[ i ];
							}
						}
					}
					i++;
				}
				if ( isDefined( e_oldest ) )
				{
					e_oldest.retrievabletrigger.force_pickup = 1;
					e_oldest.retrievabletrigger notify( "trigger" );
				}
			}
		}
	}
}
