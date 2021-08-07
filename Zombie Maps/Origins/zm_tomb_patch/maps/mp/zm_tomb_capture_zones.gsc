#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_magicbox_tomb;
#include maps/mp/zombies/_zm_challenges;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zm_tomb_capture_zones_ffotd;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zm_tomb_utility;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "fxanim_props_dlc4" );

init_capture_zones()
{
	maps/mp/zm_tomb_capture_zones_ffotd::capture_zone_init_start();
	precache_everything();
	declare_objectives();
	flag_init( "zone_capture_in_progress" );
	flag_init( "recapture_event_in_progress" );
	flag_init( "capture_zones_init_done" );
	flag_init( "recapture_zombies_cleared" );
	flag_init( "generator_under_attack" );
	flag_init( "all_zones_captured" );
	flag_init( "generator_lost_to_recapture_zombies" );
	root = %root;
	i = %fxanim_zom_tomb_generator_start_anim;
	i = %fxanim_zom_tomb_generator_up_idle_anim;
	i = %fxanim_zom_tomb_generator_down_idle_anim;
	i = %fxanim_zom_tomb_generator_end_anim;
	i = %fxanim_zom_tomb_generator_fluid_down_anim;
	i = %fxanim_zom_tomb_generator_fluid_up_anim;
	i = %fxanim_zom_tomb_generator_fluid_rotate_down_anim;
	i = %fxanim_zom_tomb_generator_fluid_rotate_up_anim;
	i = %fxanim_zom_tomb_packapunch_pc1_anim;
	i = %fxanim_zom_tomb_packapunch_pc2_anim;
	i = %fxanim_zom_tomb_packapunch_pc3_anim;
	i = %fxanim_zom_tomb_packapunch_pc4_anim;
	i = %fxanim_zom_tomb_packapunch_pc5_anim;
	i = %fxanim_zom_tomb_packapunch_pc6_anim;
	i = %fxanim_zom_tomb_packapunch_pc7_anim;
	i = %fxanim_zom_tomb_pack_return_pc1_anim;
	i = %fxanim_zom_tomb_pack_return_pc2_anim;
	i = %fxanim_zom_tomb_pack_return_pc3_anim;
	i = %fxanim_zom_tomb_pack_return_pc4_anim;
	i = %fxanim_zom_tomb_pack_return_pc5_anim;
	i = %fxanim_zom_tomb_pack_return_pc6_anim;
	i = %fxanim_zom_tomb_monolith_inductor_pull_anim;
	i = %fxanim_zom_tomb_monolith_inductor_pull_idle_anim;
	i = %fxanim_zom_tomb_monolith_inductor_release_anim;
	i = %fxanim_zom_tomb_monolith_inductor_shake_anim;
	i = %fxanim_zom_tomb_monolith_inductor_idle_anim;
	level thread setup_capture_zones();
}

precache_everything()
{
	precachemodel( "p6_zm_tm_zone_capture_hole" );
	precachemodel( "p6_zm_tm_packapunch" );
	precacherumble( "generator_active" );
	precachestring( &"ZM_TOMB_OBJ_CAPTURE_1" );
	precachestring( &"ZM_TOMB_OBJ_RECAPTURE_1" );
	precachestring( &"ZM_TOMB_OBJ_CAPTURE_2" );
	precachestring( &"ZM_TOMB_OBJ_RECAPTURE_2" );
	precachestring( &"ZM_TOMB_OBJ_RECAPTURE_ZOMBIE" );
}

declare_objectives()
{
	objective_add( 0, "invisible", ( 0, 0, 1 ), &"ZM_TOMB_OBJ_CAPTURE_1" );
	objective_add( 1, "invisible", ( 0, 0, 1 ), &"ZM_TOMB_OBJ_RECAPTURE_2" );
	objective_add( 2, "invisible", ( 0, 0, 1 ), &"ZM_TOMB_OBJ_CAPTURE_2" );
	objective_add( 3, "invisible", ( 0, 0, 1 ), &"ZM_TOMB_OBJ_RECAPTURE_ZOMBIE" );
}

init_pap_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

setup_capture_zones()
{
	spawner_capture_zombie = getent( "capture_zombie_spawner", "targetname" );
	spawner_capture_zombie add_spawn_function( ::capture_zombie_spawn_init );
	a_s_generator = getstructarray( "s_generator", "targetname" );
	registerclientfield( "world", "packapunch_anim", 14000, 3, "int" );
	registerclientfield( "actor", "zone_capture_zombie", 14000, 1, "int" );
	registerclientfield( "scriptmover", "zone_capture_emergence_hole", 14000, 1, "int" );
	registerclientfield( "world", "zc_change_progress_bar_color", 14000, 1, "int" );
	registerclientfield( "world", "zone_capture_hud_all_generators_captured", 14000, 1, "int" );
	registerclientfield( "world", "zone_capture_perk_machine_smoke_fx_always_on", 14000, 1, "int" );
	registerclientfield( "world", "pap_monolith_ring_shake", 14000, 1, "int" );
	_a149 = a_s_generator;
	_k149 = getFirstArrayKey( _a149 );
	while ( isDefined( _k149 ) )
	{
		struct = _a149[ _k149 ];
		registerclientfield( "world", struct.script_noteworthy, 14000, 7, "float" );
		registerclientfield( "world", "state_" + struct.script_noteworthy, 14000, 3, "int" );
		registerclientfield( "world", "zone_capture_hud_generator_" + struct.script_int, 14000, 2, "int" );
		registerclientfield( "world", "zone_capture_monolith_crystal_" + struct.script_int, 14000, 1, "int" );
		registerclientfield( "world", "zone_capture_perk_machine_smoke_fx_" + struct.script_int, 14000, 1, "int" );
		_k149 = getNextArrayKey( _a149, _k149 );
	}
	flag_wait( "start_zombie_round_logic" );
	level.magic_box_zbarrier_state_func = ::set_magic_box_zbarrier_state;
	level.custom_perk_validation = ::check_perk_machine_valid;
	level thread track_max_player_zombie_points();
	_a168 = a_s_generator;
	_k168 = getFirstArrayKey( _a168 );
	while ( isDefined( _k168 ) )
	{
		s_generator = _a168[ _k168 ];
		s_generator thread init_capture_zone();
		_k168 = getNextArrayKey( _a168, _k168 );
	}
	register_elements_powered_by_zone_capture_generators();
	setup_perk_machines_not_controlled_by_zone_capture();
	pack_a_punch_init();
	level thread recapture_round_tracker();
	level.zone_capture.recapture_zombies = [];
	level.zone_capture.last_zone_captured = undefined;
	level.zone_capture.spawn_func_capture_zombie = ::init_capture_zombie;
	level.zone_capture.spawn_func_recapture_zombie = ::init_recapture_zombie;
/#
	level thread watch_for_open_sesame();
	level thread debug_watch_for_zone_capture();
	level thread debug_watch_for_zone_recapture();
#/
	maps/mp/zombies/_zm_spawner::register_zombie_death_event_callback( ::recapture_zombie_death_func );
	level.custom_derive_damage_refs = ::zone_capture_gib_think;
	setup_inaccessible_zombie_attack_points();
	level thread quick_revive_game_type_watcher();
	level thread quick_revive_solo_leave_watcher();
	level thread all_zones_captured_vo();
	flag_set( "capture_zones_init_done" );
	level setclientfield( "zone_capture_perk_machine_smoke_fx_always_on", 1 );
	maps/mp/zm_tomb_capture_zones_ffotd::capture_zone_init_end();
}

all_zones_captured_vo()
{
	flag_wait( "all_zones_captured" );
	flag_waitopen( "story_vo_playing" );
	set_players_dontspeak( 1 );
	flag_set( "story_vo_playing" );
	e_speaker = get_closest_player_to_richtofen();
	if ( isDefined( e_speaker ) )
	{
		e_speaker set_player_dontspeak( 0 );
		e_speaker create_and_play_dialog( "zone_capture", "all_generators_captured" );
		e_speaker waittill_any( "done_speaking", "disconnect" );
	}
	e_richtofen = get_player_named( "Richtofen" );
	if ( isDefined( e_richtofen ) )
	{
		e_richtofen set_player_dontspeak( 0 );
		e_richtofen create_and_play_dialog( "zone_capture", "all_generators_captured" );
	}
	set_players_dontspeak( 0 );
	flag_clear( "story_vo_playing" );
}

get_closest_player_to_richtofen()
{
	a_players = get_players();
	e_speaker = undefined;
	e_richtofen = get_player_named( "Richtofen" );
	if ( isDefined( e_richtofen ) )
	{
		if ( a_players.size > 1 )
		{
			arrayremovevalue( a_players, e_richtofen, 0 );
			e_speaker = arraysort( a_players, e_richtofen.origin, 1 )[ 0 ];
		}
		else
		{
			e_speaker = undefined;
		}
	}
	else
	{
		e_speaker = get_random_speaker();
	}
	return e_speaker;
}

get_player_named( str_character_name )
{
	e_character = undefined;
	_a269 = get_players();
	_k269 = getFirstArrayKey( _a269 );
	while ( isDefined( _k269 ) )
	{
		player = _a269[ _k269 ];
		if ( isDefined( player.character_name ) && player.character_name == str_character_name )
		{
			e_character = player;
		}
		_k269 = getNextArrayKey( _a269, _k269 );
	}
	return e_character;
}

quick_revive_game_type_watcher()
{
	while ( 1 )
	{
		level waittill( "revive_hide" );
		wait 1;
		t_revive_machine = level.zone_capture.zones[ "generator_start_bunker" ].perk_machines[ "revive" ];
		if ( level.zone_capture.zones[ "generator_start_bunker" ] ent_flag( "player_controlled" ) )
		{
			level notify( "revive_on" );
			t_revive_machine.is_locked = 0;
			t_revive_machine maps/mp/zombies/_zm_perks::reset_vending_hint_string();
			continue;
		}
		else
		{
			level notify( "revive_off" );
			t_revive_machine.is_locked = 1;
			t_revive_machine sethintstring( &"ZM_TOMB_ZC" );
		}
	}
}

quick_revive_solo_leave_watcher()
{
	if ( flag_exists( "solo_revive" ) )
	{
		flag_wait( "solo_revive" );
		level setclientfield( "zone_capture_perk_machine_smoke_fx_1", 0 );
	}
}

revive_perk_fx_think()
{
	if ( flag_exists( "solo_revive" ) )
	{
		return !flag( "solo_revive" );
	}
}

setup_inaccessible_zombie_attack_points()
{
	set_attack_point_as_inaccessible( "generator_start_bunker", 5 );
	set_attack_point_as_inaccessible( "generator_start_bunker", 11 );
	set_attack_point_as_inaccessible( "generator_tank_trench", 4 );
	set_attack_point_as_inaccessible( "generator_tank_trench", 5 );
	set_attack_point_as_inaccessible( "generator_tank_trench", 6 );
}

set_attack_point_as_inaccessible( str_zone, n_index )
{
/#
	assert( isDefined( level.zone_capture.zones[ str_zone ] ), "set_attack_point_as_inaccessible couldn't find " + str_zone + " in level.zone_capture's zone array!" );
#/
	level.zone_capture.zones[ str_zone ] ent_flag_wait( "zone_initialized" );
/#
	assert( isDefined( level.zone_capture.zones[ str_zone ].zombie_attack_points[ n_index ] ), "set_attack_points_as_inaccessible couldn't find index " + n_index + " on zone " + str_zone );
#/
	level.zone_capture.zones[ str_zone ].zombie_attack_points[ n_index ].inaccessible = 1;
}

setup_perk_machines_not_controlled_by_zone_capture()
{
	level.zone_capture.perk_machines_always_on = array( "specialty_additionalprimaryweapon" );
}

track_max_player_zombie_points()
{
	while ( 1 )
	{
		a_players = get_players();
		_a356 = a_players;
		_k356 = getFirstArrayKey( _a356 );
		while ( isDefined( _k356 ) )
		{
			player = _a356[ _k356 ];
			player.n_capture_zombie_points = 0;
			_k356 = getNextArrayKey( _a356, _k356 );
		}
		level waittill( "between_round_over" );
	}
}

pack_a_punch_dummy_init()
{
}

pack_a_punch_init()
{
	vending_weapon_upgrade_trigger = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	level.pap_triggers = vending_weapon_upgrade_trigger;
	t_pap = getent( "specialty_weapupgrade", "script_noteworthy" );
	t_pap.machine ghost();
	t_pap.machine notsolid();
	t_pap.bump enablelinkto();
	t_pap.bump linkto( t_pap );
	level thread pack_a_punch_think();
}

pack_a_punch_think()
{
	while ( 1 )
	{
		flag_wait( "all_zones_captured" );
		pack_a_punch_enable();
		flag_waitopen( "all_zones_captured" );
		pack_a_punch_disable();
	}
}

pack_a_punch_enable()
{
	t_pap = getent( "specialty_weapupgrade", "script_noteworthy" );
	t_pap trigger_on();
	flag_set( "power_on" );
	level setclientfield( "zone_capture_hud_all_generators_captured", 1 );
	if ( !flag( "generator_lost_to_recapture_zombies" ) )
	{
		level notify( "all_zones_captured_none_lost" );
	}
}

pack_a_punch_disable()
{
	t_pap = getent( "specialty_weapupgrade", "script_noteworthy" );
	level setclientfield( "zone_capture_hud_all_generators_captured", 0 );
	flag_waitopen( "pack_machine_in_use" );
	t_pap trigger_off();
}

register_elements_powered_by_zone_capture_generators()
{
	register_random_perk_machine_for_zone( "generator_start_bunker", "starting_bunker" );
	register_perk_machine_for_zone( "generator_start_bunker", "revive", "vending_revive", ::revive_perk_fx_think );
	register_mystery_box_for_zone( "generator_start_bunker", "bunker_start_chest" );
	register_random_perk_machine_for_zone( "generator_tank_trench", "trenches_right" );
	register_mystery_box_for_zone( "generator_tank_trench", "bunker_tank_chest" );
	register_random_perk_machine_for_zone( "generator_mid_trench", "trenches_left" );
	register_perk_machine_for_zone( "generator_mid_trench", "sleight", "vending_sleight" );
	register_mystery_box_for_zone( "generator_mid_trench", "bunker_cp_chest" );
	register_random_perk_machine_for_zone( "generator_nml_right", "nml" );
	register_perk_machine_for_zone( "generator_nml_right", "juggernog", "vending_jugg" );
	register_mystery_box_for_zone( "generator_nml_right", "nml_open_chest" );
	register_random_perk_machine_for_zone( "generator_nml_left", "farmhouse" );
	register_perk_machine_for_zone( "generator_nml_left", "marathon", "vending_marathon" );
	register_mystery_box_for_zone( "generator_nml_left", "nml_farm_chest" );
	register_random_perk_machine_for_zone( "generator_church", "church" );
	register_mystery_box_for_zone( "generator_church", "village_church_chest" );
}

register_perk_machine_for_zone( str_zone_name, str_perk_name, str_machine_targetname, func_perk_fx_think )
{
/#
	assert( isDefined( level.zone_capture.zones[ str_zone_name ] ), "register_perk_machine_for_zone can't find " + str_zone_name + " has not been initialized in level.zone_capture.zones array!" );
#/
	if ( !isDefined( level.zone_capture.zones[ str_zone_name ].perk_machines ) )
	{
		level.zone_capture.zones[ str_zone_name ].perk_machines = [];
	}
	if ( !isDefined( level.zone_capture.zones[ str_zone_name ].perk_machines[ str_perk_name ] ) )
	{
		e_perk_machine_trigger = get_perk_machine_trigger_from_vending_entity( str_machine_targetname );
		e_perk_machine_trigger.str_zone_name = str_zone_name;
		level.zone_capture.zones[ str_zone_name ].perk_machines[ str_perk_name ] = e_perk_machine_trigger;
	}
	level.zone_capture.zones[ str_zone_name ].perk_fx_func = func_perk_fx_think;
}

register_random_perk_machine_for_zone( str_zone_name, str_identifier )
{
/#
	assert( isDefined( level.zone_capture.zones[ str_zone_name ] ), "register_random_perk_machine_for_zone can't find " + str_zone_name + " has not been initialized in level.zone_capture.zones array!" );
#/
	if ( !isDefined( level.zone_capture.zones[ str_zone_name ].perk_machines_random ) )
	{
		level.zone_capture.zones[ str_zone_name ].perk_machines_random = [];
	}
	a_random_perk_machines = getentarray( "random_perk_machine", "targetname" );
	_a492 = a_random_perk_machines;
	_k492 = getFirstArrayKey( _a492 );
	while ( isDefined( _k492 ) )
	{
		random_perk_machine = _a492[ _k492 ];
		if ( isDefined( random_perk_machine.script_string ) && random_perk_machine.script_string == str_identifier )
		{
			level.zone_capture.zones[ str_zone_name ].perk_machines_random[ level.zone_capture.zones[ str_zone_name ].perk_machines_random.size ] = random_perk_machine;
		}
		_k492 = getNextArrayKey( _a492, _k492 );
	}
}

register_mystery_box_for_zone( str_zone_name, str_identifier )
{
/#
	assert( isDefined( level.zone_capture.zones[ str_zone_name ] ), "register_mystery_box_for_zone can't find " + str_zone_name + " has not been initialized in level.zone_capture.zones array!" );
#/
	if ( !isDefined( level.zone_capture.zones[ str_zone_name ].mystery_boxes ) )
	{
		level.zone_capture.zones[ str_zone_name ].mystery_boxes = [];
	}
	s_mystery_box = get_mystery_box_from_script_noteworthy( str_identifier );
	s_mystery_box.unitrigger_stub.prompt_and_visibility_func = ::magic_box_trigger_update_prompt;
	s_mystery_box.unitrigger_stub.zone = str_zone_name;
	s_mystery_box.zone_capture_area = str_zone_name;
	s_mystery_box.zbarrier.zone_capture_area = str_zone_name;
	level.zone_capture.zones[ str_zone_name ].mystery_boxes[ level.zone_capture.zones[ str_zone_name ].mystery_boxes.size ] = s_mystery_box;
}

get_mystery_box_from_script_noteworthy( str_script_noteworthy )
{
	s_box = undefined;
	_a524 = level.chests;
	_k524 = getFirstArrayKey( _a524 );
	while ( isDefined( _k524 ) )
	{
		s_mystery_box = _a524[ _k524 ];
		if ( isDefined( s_mystery_box.script_noteworthy ) && s_mystery_box.script_noteworthy == str_script_noteworthy )
		{
			s_box = s_mystery_box;
		}
		_k524 = getNextArrayKey( _a524, _k524 );
	}
/#
	assert( isDefined( s_mystery_box ), "get_mystery_box_from_script_noteworthy() couldn't find a mystery box with script_noteworthy = " + str_script_noteworthy );
#/
	return s_box;
}

enable_perk_machines_in_zone()
{
	while ( isDefined( self.perk_machines ) && isarray( self.perk_machines ) )
	{
		a_keys = getarraykeys( self.perk_machines );
		i = 0;
		while ( i < a_keys.size )
		{
			level notify( a_keys[ i ] + "_on" );
			i++;
		}
		i = 0;
		while ( i < a_keys.size )
		{
			e_perk_trigger = self.perk_machines[ a_keys[ i ] ];
			e_perk_trigger.is_locked = 0;
			e_perk_trigger maps/mp/zombies/_zm_perks::reset_vending_hint_string();
			i++;
		}
	}
}

disable_perk_machines_in_zone()
{
	while ( isDefined( self.perk_machines ) && isarray( self.perk_machines ) )
	{
		a_keys = getarraykeys( self.perk_machines );
		i = 0;
		while ( i < a_keys.size )
		{
			level notify( a_keys[ i ] + "_off" );
			i++;
		}
		i = 0;
		while ( i < a_keys.size )
		{
			e_perk_trigger = self.perk_machines[ a_keys[ i ] ];
			e_perk_trigger.is_locked = 1;
			e_perk_trigger sethintstring( &"ZM_TOMB_ZC" );
			i++;
		}
	}
}

enable_random_perk_machines_in_zone()
{
	while ( isDefined( self.perk_machines_random ) && isarray( self.perk_machines_random ) )
	{
		_a586 = self.perk_machines_random;
		_k586 = getFirstArrayKey( _a586 );
		while ( isDefined( _k586 ) )
		{
			random_perk_machine = _a586[ _k586 ];
			random_perk_machine.is_locked = 0;
			random_perk_machine sethintstring( &"ZM_TOMB_RPB", level._random_zombie_perk_cost );
			_k586 = getNextArrayKey( _a586, _k586 );
		}
	}
}

disable_random_perk_machines_in_zone()
{
	while ( isDefined( self.perk_machines_random ) && isarray( self.perk_machines_random ) )
	{
		_a598 = self.perk_machines_random;
		_k598 = getFirstArrayKey( _a598 );
		while ( isDefined( _k598 ) )
		{
			random_perk_machine = _a598[ _k598 ];
			random_perk_machine.is_locked = 1;
			_k598 = getNextArrayKey( _a598, _k598 );
		}
	}
}

enable_mystery_boxes_in_zone()
{
	_a608 = self.mystery_boxes;
	_k608 = getFirstArrayKey( _a608 );
	while ( isDefined( _k608 ) )
	{
		mystery_box = _a608[ _k608 ];
		mystery_box.is_locked = 0;
		mystery_box.zbarrier set_magic_box_zbarrier_state( "player_controlled" );
		mystery_box.zbarrier setclientfield( "magicbox_runes", 1 );
		_k608 = getNextArrayKey( _a608, _k608 );
	}
}

disable_mystery_boxes_in_zone()
{
	_a621 = self.mystery_boxes;
	_k621 = getFirstArrayKey( _a621 );
	while ( isDefined( _k621 ) )
	{
		mystery_box = _a621[ _k621 ];
		mystery_box.is_locked = 1;
		mystery_box.zbarrier set_magic_box_zbarrier_state( "zombie_controlled" );
		mystery_box.zbarrier setclientfield( "magicbox_runes", 0 );
		_k621 = getNextArrayKey( _a621, _k621 );
	}
}

get_perk_machine_trigger_from_vending_entity( str_vending_machine_targetname )
{
	e_trigger = getent( str_vending_machine_targetname, "target" );
/#
	assert( isDefined( e_trigger ), "get_perk_machine_trigger_from_vending_entity couldn't find perk machine trigger with target = " + str_vending_machine_targetname );
#/
	return e_trigger;
}

check_perk_machine_valid( player )
{
	if ( isDefined( self.script_noteworthy ) && isinarray( level.zone_capture.perk_machines_always_on, self.script_noteworthy ) )
	{
		b_machine_valid = 1;
	}
	else
	{
/#
		assert( isDefined( self.str_zone_name ), "str_zone_name field missing on perk machine! This is required by the zone capture system!" );
#/
		b_machine_valid = level.zone_capture.zones[ self.str_zone_name ] ent_flag( "player_controlled" );
	}
	if ( !b_machine_valid )
	{
		player create_and_play_dialog( "lockdown", "power_off" );
	}
	return b_machine_valid;
}

init_capture_zone()
{
/#
	assert( isDefined( self.script_noteworthy ), "capture zone struct is missing script_noteworthy KVP! This is required for init_capture_zone()" );
#/
	if ( !isDefined( level.zone_capture ) )
	{
		level.zone_capture = spawnstruct();
	}
	if ( !isDefined( level.zone_capture.zones ) )
	{
		level.zone_capture.zones = [];
	}
/#
	assert( !isDefined( level.zone_capture.zones[ self.script_noteworthy ] ), "init_capture_zone() attempting to initialize an existing zone with name '" + self.script_noteworthy + "'" );
#/
	self.n_current_progress = 0;
	self.n_last_progress = 0;
	self setup_generator_unitrigger();
	self.str_zone = get_zone_from_position( self.origin, 1 );
	self.sndent = spawn( "script_origin", self.origin );
/#
	assert( isDefined( self.script_int ), "script_int KVP is required by init_capture_zone() to identify the objective index, but it's missing on zone '" + self.script_noteworthy + "'" );
#/
	self ent_flag_init( "attacked_by_recapture_zombies" );
	self ent_flag_init( "current_recapture_target_zone" );
	self ent_flag_init( "player_controlled" );
	self ent_flag_init( "zone_contested" );
	self ent_flag_init( "zone_initialized" );
	level.zone_capture.zones[ self.script_noteworthy ] = self;
	self set_zombie_controlled_area( 1 );
	self setup_zombie_attack_points();
	self ent_flag_set( "zone_initialized" );
	self thread wait_for_capture_trigger();
}

setup_generator_unitrigger()
{
	s_unitrigger_stub = spawnstruct();
	s_unitrigger_stub.origin = self.origin;
	s_unitrigger_stub.angles = self.angles;
	s_unitrigger_stub.radius = 32;
	s_unitrigger_stub.script_length = 128;
	s_unitrigger_stub.script_width = 128;
	s_unitrigger_stub.script_height = 128;
	s_unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_unitrigger_stub.hint_string = &"ZM_TOMB_CAP";
	s_unitrigger_stub.hint_parm1 = [[ ::get_generator_capture_start_cost ]]();
	s_unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger_stub.require_look_at = 1;
	s_unitrigger_stub.prompt_and_visibility_func = ::generator_trigger_prompt_and_visibility;
	s_unitrigger_stub.generator_struct = self;
	unitrigger_force_per_player_triggers( s_unitrigger_stub, 1 );
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( s_unitrigger_stub, ::generator_unitrigger_think );
}

generator_trigger_prompt_and_visibility( e_player )
{
	b_can_see_hint = 1;
	s_zone = self.stub.generator_struct;
	if ( s_zone ent_flag( "zone_contested" ) || s_zone ent_flag( "player_controlled" ) )
	{
		b_can_see_hint = 0;
	}
	if ( flag( "zone_capture_in_progress" ) )
	{
		self sethintstring( &"ZM_TOMB_ZCIP" );
	}
	else
	{
		self sethintstring( &"ZM_TOMB_CAP", get_generator_capture_start_cost() );
	}
	self setinvisibletoplayer( e_player, !b_can_see_hint );
	return b_can_see_hint;
}

generator_unitrigger_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		while ( is_player_valid( e_player ) || e_player is_reviving_any() && e_player != self.parent_player )
		{
			continue;
		}
		while ( e_player.score < get_generator_capture_start_cost() )
		{
			e_player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_capture" );
		}
		while ( flag( "zone_capture_in_progress" ) )
		{
			continue;
		}
		self setinvisibletoall();
		self.stub.generator_struct notify( "start_generator_capture" );
	}
}

setup_zombie_attack_points()
{
	self.zombie_attack_points = [];
	v_right = anglesToRight( self.angles );
	self add_attack_points_from_anchor_origin( self.origin, 0, 52 );
	self add_attack_points_from_anchor_origin( self.origin + ( v_right * 170 ), 4, 32 );
	self add_attack_points_from_anchor_origin( self.origin + ( ( v_right * -1 ) * 170 ), 8, 32 );
}

add_attack_points_from_anchor_origin( v_origin, n_start_index, n_scale )
{
	v_forward = anglesToForward( self.angles );
	v_right = anglesToRight( self.angles );
	self.zombie_attack_points[ n_start_index ] = init_attack_point( v_origin + ( v_forward * n_scale ), v_origin );
	self.zombie_attack_points[ n_start_index + 1 ] = init_attack_point( v_origin + ( v_right * n_scale ), v_origin );
	self.zombie_attack_points[ n_start_index + 2 ] = init_attack_point( v_origin + ( ( v_forward * -1 ) * n_scale ), v_origin );
	self.zombie_attack_points[ n_start_index + 3 ] = init_attack_point( v_origin + ( ( v_right * -1 ) * n_scale ), v_origin );
}

init_attack_point( v_origin, v_center_pillar )
{
	s_temp = spawnstruct();
	s_temp.is_claimed = 0;
	s_temp.claimed_by = undefined;
	s_temp.origin = v_origin;
	s_temp.inaccessible = 0;
	s_temp.v_center_pillar = v_center_pillar;
	return s_temp;
}

wait_for_capture_trigger()
{
	while ( 1 )
	{
		self waittill( "start_generator_capture", e_player );
		if ( !flag( "zone_capture_in_progress" ) )
		{
			flag_set( "zone_capture_in_progress" );
			self.generator_cost = get_generator_capture_start_cost();
			e_player minus_to_player_score( self.generator_cost );
			e_player delay_thread( 2,5, ::create_and_play_dialog, "zone_capture", "capture_started" );
			self maps/mp/zm_tomb_capture_zones_ffotd::capture_event_start();
			self thread monitor_capture_zombies();
			self thread activate_capture_zone();
			self ent_flag_wait( "zone_contested" );
			capture_event_handle_ai_limit();
			self ent_flag_waitopen( "zone_contested" );
			self maps/mp/zm_tomb_capture_zones_ffotd::capture_event_end();
			wait 1;
			if ( isDefined( e_player ) && self ent_flag( "player_controlled" ) )
			{
				self refund_generator_cost_if_player_captured_it( e_player );
			}
		}
		else
		{
			flag_wait( "zone_capture_in_progress" );
			flag_waitopen( "zone_capture_in_progress" );
		}
		capture_event_handle_ai_limit();
		if ( self ent_flag( "player_controlled" ) )
		{
			self ent_flag_waitopen( "player_controlled" );
		}
	}
}

refund_generator_cost_if_player_captured_it( e_player )
{
	if ( isinarray( self get_players_in_capture_zone(), e_player ) )
	{
		n_refund_amount = self.generator_cost;
		b_double_points_active = level.zombie_vars[ "allies" ][ "zombie_point_scalar" ] == 2;
		n_multiplier = 1;
		if ( b_double_points_active )
		{
			n_multiplier = 0,5;
		}
		e_player add_to_player_score( int( n_refund_amount * n_multiplier ) );
	}
}

get_generator_capture_start_cost()
{
	return 200 * get_players().size;
}

capture_event_handle_ai_limit()
{
	n_capture_zombies_needed = calculate_capture_event_zombies_needed();
	level.zombie_ai_limit = 24 - n_capture_zombies_needed;
	while ( get_current_zombie_count() > level.zombie_ai_limit )
	{
		ai_zombie = get_zombie_to_delete();
		if ( isDefined( ai_zombie ) )
		{
			ai_zombie thread delete_zombie_for_capture_event();
		}
		wait_network_frame();
	}
}

get_zombie_to_delete()
{
	ai_zombie = undefined;
	a_zombies = get_round_enemy_array();
	if ( a_zombies.size > 0 )
	{
		ai_zombie = random( a_zombies );
	}
	return ai_zombie;
}

delete_zombie_for_capture_event()
{
	if ( isDefined( self ) )
	{
		playfx( level._effect[ "tesla_elec_kill" ], self.origin );
		self ghost();
	}
	wait_network_frame();
	if ( isDefined( self ) )
	{
		self delete();
	}
}

calculate_capture_event_zombies_needed()
{
	n_capture_zombies_needed = get_capture_zombies_needed();
	n_recapture_zombies_needed = 0;
	if ( flag( "recapture_event_in_progress" ) )
	{
		n_recapture_zombies_needed = get_recapture_zombies_needed();
	}
	return n_capture_zombies_needed + n_recapture_zombies_needed;
}

get_capture_zombies_needed( b_per_zone )
{
	if ( !isDefined( b_per_zone ) )
	{
		b_per_zone = 0;
	}
	a_contested_zones = get_contested_zones();
	switch( a_contested_zones.size )
	{
		case 0:
			n_capture_zombies_needed = 0;
			n_capture_zombies_needed_per_zone = 0;
			break;
		case 1:
			n_capture_zombies_needed = 4;
			n_capture_zombies_needed_per_zone = 4;
			break;
		case 2:
			n_capture_zombies_needed = 6;
			n_capture_zombies_needed_per_zone = 3;
			break;
		case 3:
			n_capture_zombies_needed = 6;
			n_capture_zombies_needed_per_zone = 2;
			break;
		case 4:
			n_capture_zombies_needed = 8;
			n_capture_zombies_needed_per_zone = 2;
			break;
		default:
/#
			iprintlnbold( "get_capture_zombies_needed() unhandled case. active capture events = " + a_contested_zones.size );
#/
			n_capture_zombies_needed = 2 * a_contested_zones.size;
			n_capture_zombies_needed_per_zone = 2;
			break;
	}
	if ( b_per_zone )
	{
		b_capture_zombies_needed = n_capture_zombies_needed_per_zone;
	}
	return n_capture_zombies_needed;
}

set_capture_zombies_needed_per_zone()
{
	a_contested_zones = get_contested_zones();
	n_zombies_needed_per_zone = get_capture_zombies_needed( 1 );
	_a1032 = a_contested_zones;
	_k1032 = getFirstArrayKey( _a1032 );
	while ( isDefined( _k1032 ) )
	{
		zone = _a1032[ _k1032 ];
		if ( zone ent_flag( "current_recapture_target_zone" ) )
		{
		}
		else
		{
			zone.capture_zombie_limit = n_zombies_needed_per_zone;
		}
		_k1032 = getNextArrayKey( _a1032, _k1032 );
	}
	return n_zombies_needed_per_zone;
}

get_recapture_zombies_needed()
{
	if ( level.is_forever_solo_game )
	{
		n_recapture_zombies_needed = 4;
	}
	else
	{
		n_recapture_zombies_needed = 6;
	}
	return n_recapture_zombies_needed;
}

activate_capture_zone( b_show_emergence_holes )
{
	if ( !isDefined( b_show_emergence_holes ) )
	{
		b_show_emergence_holes = 1;
	}
	if ( !flag( "recapture_event_in_progress" ) )
	{
		self thread generator_initiated_vo();
	}
	self.a_emergence_hole_structs = getstructarray( self.target, "targetname" );
	self show_emergence_holes( b_show_emergence_holes );
	if ( flag( "recapture_event_in_progress" ) && self ent_flag( "current_recapture_target_zone" ) )
	{
		flag_wait_any( "generator_under_attack", "recapture_zombies_cleared" );
		if ( flag( "recapture_zombies_cleared" ) )
		{
			return;
		}
	}
	self capture_progress_think();
	self destroy_emergence_holes();
}

show_emergence_holes( b_show_emergence_holes )
{
	self destroy_emergence_holes();
	while ( b_show_emergence_holes )
	{
		self.a_spawner_holes = [];
		self.a_emergence_holes = [];
		_a1097 = self.a_emergence_hole_structs;
		_k1097 = getFirstArrayKey( _a1097 );
		while ( isDefined( _k1097 ) )
		{
			s_spawner_hole = _a1097[ _k1097 ];
			self.a_emergence_holes[ self.a_emergence_holes.size ] = s_spawner_hole emergence_hole_spawn();
			_k1097 = getNextArrayKey( _a1097, _k1097 );
		}
	}
}

destroy_emergence_holes()
{
	while ( isDefined( self.a_emergence_holes ) && self.a_emergence_holes.size > 0 )
	{
		_a1108 = self.a_emergence_holes;
		_k1108 = getFirstArrayKey( _a1108 );
		while ( isDefined( _k1108 ) )
		{
			m_emergence_hole = _a1108[ _k1108 ];
			if ( isDefined( m_emergence_hole ) )
			{
				m_emergence_hole setclientfield( "zone_capture_emergence_hole", 0 );
				m_emergence_hole ghost();
				m_emergence_hole thread delete_self_after_time( randomfloatrange( 0,5, 2 ) );
			}
			wait_network_frame();
			_k1108 = getNextArrayKey( _a1108, _k1108 );
		}
	}
}

delete_self_after_time( n_time )
{
	wait n_time;
	if ( isDefined( self ) )
	{
		self delete();
	}
}

monitor_capture_zombies()
{
	self ent_flag_wait( "zone_contested" );
	e_spawner_capture_zombie = getent( "capture_zombie_spawner", "targetname" );
	self.capture_zombies = [];
	self.capture_zombie_limit = self set_capture_zombies_needed_per_zone();
	while ( self ent_flag( "zone_contested" ) )
	{
		self.capture_zombies = array_removedead( self.capture_zombies );
		if ( self.capture_zombies.size < self.capture_zombie_limit )
		{
			ai = spawn_zombie( e_spawner_capture_zombie );
			s_spawn_point = self get_emergence_hole_spawn_point();
			ai thread [[ level.zone_capture.spawn_func_capture_zombie ]]( self, s_spawn_point );
			self.capture_zombies[ self.capture_zombies.size ] = ai;
		}
		wait 0,5;
	}
}

monitor_recapture_zombies()
{
	e_spawner_capture_zombie = getent( "capture_zombie_spawner", "targetname" );
	self.capture_zombie_limit = get_recapture_zombies_needed();
	n_capture_zombie_spawns = 0;
	self thread play_vo_when_generator_is_attacked();
	while ( flag( "recapture_event_in_progress" ) && n_capture_zombie_spawns < self.capture_zombie_limit )
	{
		level.zone_capture.recapture_zombies = array_removedead( level.zone_capture.recapture_zombies );
		ai = spawn_zombie( e_spawner_capture_zombie );
		n_capture_zombie_spawns++;
		s_spawn_point = self get_emergence_hole_spawn_point();
		ai thread [[ level.zone_capture.spawn_func_recapture_zombie ]]( self, s_spawn_point );
		level.zone_capture.recapture_zombies[ level.zone_capture.recapture_zombies.size ] = ai;
		wait 0,5;
	}
	level monitor_recapture_zombie_count();
}

play_vo_when_generator_is_attacked()
{
	self endon( "zone_contested" );
	level endon( "recapture_event_in_progress" );
	self waittill( "zombies_attacking_generator" );
	broadcast_vo_category_to_team( "recapture_generator_attacked", 3,5 );
}

get_emergence_hole_spawn_point()
{
	while ( 1 )
	{
		if ( isDefined( self.a_emergence_hole_structs ) && self.a_emergence_hole_structs.size > 0 )
		{
			s_spawn_point = self get_unused_emergence_hole_spawn_point();
			s_spawn_point.spawned_zombie = 1;
			return s_spawn_point;
		}
		else
		{
			self.a_emergence_hole_structs = getstructarray( self.target, "targetname" );
		}
		wait 0,05;
	}
}

get_unused_emergence_hole_spawn_point()
{
	a_valid_spawn_points = [];
	b_all_points_used = 0;
	while ( !a_valid_spawn_points.size )
	{
		_a1237 = self.a_emergence_hole_structs;
		_k1237 = getFirstArrayKey( _a1237 );
		while ( isDefined( _k1237 ) )
		{
			s_emergence_hole = _a1237[ _k1237 ];
			if ( !isDefined( s_emergence_hole.spawned_zombie ) || b_all_points_used )
			{
				s_emergence_hole.spawned_zombie = 0;
			}
			if ( !s_emergence_hole.spawned_zombie )
			{
				a_valid_spawn_points[ a_valid_spawn_points.size ] = s_emergence_hole;
			}
			_k1237 = getNextArrayKey( _a1237, _k1237 );
		}
		if ( !a_valid_spawn_points.size )
		{
			b_all_points_used = 1;
		}
	}
	s_spawn_point = random( a_valid_spawn_points );
	return s_spawn_point;
}

emergence_hole_spawn()
{
	m_emergence_hole = spawn( "script_model", self.origin );
	m_emergence_hole.angles = self.angles;
	m_emergence_hole setmodel( "p6_zm_tm_zone_capture_hole" );
	wait_network_frame();
	m_emergence_hole setclientfield( "zone_capture_emergence_hole", 1 );
	return m_emergence_hole;
}

init_zone_capture_zombie_common( s_spawn_point )
{
	self setphysparams( 15, 0, 72 );
	self.ignore_enemy_count = 1;
	self dug_zombie_rise( s_spawn_point );
	self playsound( "zmb_vocals_capzomb_spawn" );
	self setclientfield( "zone_capture_zombie", 1 );
	self init_anim_rate();
}

init_anim_rate()
{
	self setclientfield( "anim_rate", 1 );
	n_rate = self getclientfield( "anim_rate" );
	self setentityanimrate( n_rate );
}

zone_capture_gib_think( refs, point, weaponname )
{
	if ( isDefined( self.is_recapture_zombie ) && self.is_recapture_zombie )
	{
		arrayremovevalue( refs, "right_leg", 0 );
		arrayremovevalue( refs, "left_leg", 0 );
		arrayremovevalue( refs, "no_legs", 0 );
	}
	return refs;
}

init_capture_zombie( zone_struct, s_spawn_point )
{
	self endon( "death" );
	self init_zone_capture_zombie_common( s_spawn_point );
	if ( isDefined( self.zombie_move_speed ) && self.zombie_move_speed == "walk" )
	{
		self.zombie_move_speed = "run";
		self set_zombie_run_cycle( "run" );
	}
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	find_flesh_struct_string = "find_flesh";
	self notify( "zombie_custom_think_done" );
	self thread capture_zombies_only_attack_nearby_players( zone_struct );
}

init_recapture_zombie( zone_struct, s_spawn_point )
{
	self endon( "death" );
	self.is_recapture_zombie = 1;
	self init_zone_capture_zombie_common( s_spawn_point );
	self.goalradius = 30;
	self.zombie_move_speed = "sprint";
	self.s_attack_generator = zone_struct;
	self.attacking_new_generator = 1;
	self.attacking_point = undefined;
	self thread recapture_zombie_poi_think();
	while ( 1 )
	{
		self.is_attacking_zone = 0;
		if ( self.zombie_has_point_of_interest )
		{
			v_attack_origin = self.point_of_interest;
		}
		else
		{
			if ( self.attacking_new_generator || !isDefined( self.attacking_point ) )
			{
				if ( isDefined( self.attacking_point ) )
				{
					self.attacking_point unclaim_attacking_point();
				}
				self.attacking_point = self get_unclaimed_attack_point( self.s_attack_generator );
			}
			v_attack_origin = self.attacking_point.origin;
		}
		self setgoalpos( v_attack_origin );
		self waittill_either( "goal", "poi_state_changed" );
		if ( !self.zombie_has_point_of_interest )
		{
			while ( distance( self.attacking_point.origin, self.origin ) > 50 )
			{
				continue;
			}
			self.is_attacking_zone = 1;
			if ( !isDefined( level.zone_capture.recapture_target ) || !isDefined( self.s_attack_generator.script_noteworthy ) && isDefined( level.zone_capture.recapture_target ) && isDefined( self.s_attack_generator.script_noteworthy ) && level.zone_capture.recapture_target == self.s_attack_generator.script_noteworthy )
			{
				flag_set( "generator_under_attack" );
				self.s_attack_generator ent_flag_set( "attacked_by_recapture_zombies" );
				self.attacking_new_generator = 0;
				zone_struct notify( "zombies_attacking_generator" );
			}
		}
		else
		{
			if ( isDefined( self.attacking_point ) )
			{
				self.attacking_point unclaim_attacking_point();
			}
		}
		self play_melee_attack_animation();
	}
}

capture_zombie_rise_fx( ai_zombie )
{
	playfx( level._effect[ "zone_capture_zombie_spawn" ], self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
}

get_unclaimed_attack_point( s_zone )
{
	s_zone clean_up_unused_attack_points();
	n_claimed_center = s_zone get_claimed_attack_points_between_indicies( 0, 3 );
	n_claimed_left = s_zone get_claimed_attack_points_between_indicies( 4, 7 );
	n_claimed_right = s_zone get_claimed_attack_points_between_indicies( 8, 11 );
	b_use_center_pillar = n_claimed_center < 3;
	b_use_left_pillar = n_claimed_left < 1;
	b_use_right_pillar = n_claimed_right < 1;
	if ( b_use_center_pillar )
	{
		a_valid_attack_points = s_zone get_unclaimed_attack_points_between_indicies( 0, 3 );
	}
	else if ( b_use_left_pillar )
	{
		a_valid_attack_points = s_zone get_unclaimed_attack_points_between_indicies( 4, 7 );
	}
	else if ( b_use_right_pillar )
	{
		a_valid_attack_points = s_zone get_unclaimed_attack_points_between_indicies( 8, 11 );
	}
	else
	{
		a_valid_attack_points = s_zone get_unclaimed_attack_points_between_indicies( 0, 11 );
	}
	if ( a_valid_attack_points.size == 0 )
	{
		a_valid_attack_points = s_zone get_unclaimed_attack_points_between_indicies( 0, 11 );
	}
/#
	assert( a_valid_attack_points.size > 0, "get_unclaimed_attack_point() couldn't find any valid attack points in zone " + s_zone.script_noteworthy );
#/
	s_attack_point = random( a_valid_attack_points );
	s_attack_point.is_claimed = 1;
	s_attack_point.claimed_by = self;
	return s_attack_point;
}

clean_up_unused_attack_points()
{
	_a1472 = self.zombie_attack_points;
	_k1472 = getFirstArrayKey( _a1472 );
	while ( isDefined( _k1472 ) )
	{
		s_attack_point = _a1472[ _k1472 ];
		if ( s_attack_point.is_claimed && !isDefined( s_attack_point.claimed_by ) )
		{
			s_attack_point.is_claimed = 0;
			s_attack_point.claimed_by = undefined;
		}
		_k1472 = getNextArrayKey( _a1472, _k1472 );
	}
}

get_unclaimed_attack_points_between_indicies( n_start, n_end )
{
	a_valid_attack_points = [];
	i = n_start;
	while ( i < n_end )
	{
		if ( !self.zombie_attack_points[ i ].is_claimed && !self.zombie_attack_points[ i ].inaccessible )
		{
			a_valid_attack_points[ a_valid_attack_points.size ] = self.zombie_attack_points[ i ];
		}
		i++;
	}
	return a_valid_attack_points;
}

get_claimed_attack_points_between_indicies( n_start, n_end )
{
	a_valid_points = [];
	i = n_start;
	while ( i < n_end )
	{
		if ( self.zombie_attack_points[ i ].is_claimed )
		{
			a_valid_points[ a_valid_points.size ] = self.zombie_attack_points[ i ];
		}
		i++;
	}
	return a_valid_points.size;
}

unclaim_attacking_point()
{
	self.is_claimed = 0;
	self.claimed_by = undefined;
}

clear_all_zombie_attack_points_in_zone()
{
	_a1523 = self.zombie_attack_points;
	_k1523 = getFirstArrayKey( _a1523 );
	while ( isDefined( _k1523 ) )
	{
		s_attack_point = _a1523[ _k1523 ];
		s_attack_point unclaim_attacking_point();
		_k1523 = getNextArrayKey( _a1523, _k1523 );
	}
}

capture_zombies_only_attack_nearby_players( s_zone )
{
	self endon( "death" );
	n_goal_radius = self.goalradius;
	while ( 1 )
	{
		self.goalradius = n_goal_radius;
		while ( self should_capture_zombie_attack_generator( s_zone ) )
		{
			self notify( "stop_find_flesh" );
			self notify( "zombie_acquire_enemy" );
			self.goalradius = 30;
			if ( !isDefined( self.attacking_point ) )
			{
				self.attacking_point = self get_unclaimed_attack_point( s_zone );
			}
			self setgoalpos( self.attacking_point.origin );
			self thread cancel_generator_attack_if_player_gets_close_to_generator( s_zone );
			str_notify = self waittill_any_return( "goal", "stop_attacking_generator" );
			if ( !isDefined( str_notify ) || !isDefined( "stop_attacking_generator" ) && isDefined( str_notify ) && isDefined( "stop_attacking_generator" ) && str_notify == "stop_attacking_generator" )
			{
				self.attacking_point unclaim_attacking_point();
				break;
			}
			else
			{
				self play_melee_attack_animation();
			}
		}
		wait 0,5;
	}
}

cancel_generator_attack_if_player_gets_close_to_generator( s_zone )
{
	self notify( "generator_attack_cancel_think" );
	self endon( "generator_attack_cancel_think" );
	self endon( "death" );
	while ( 1 )
	{
		if ( !self should_capture_zombie_attack_generator( s_zone ) )
		{
			self notify( "stop_attacking_generator" );
			self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
			return;
		}
		else
		{
			wait randomfloatrange( 0,2, 1,5 );
		}
	}
}

should_capture_zombie_attack_generator( s_zone )
{
	a_players = get_players();
	a_valid_targets = arraysort( a_players, s_zone.origin, 1, undefined, 700 );
	_a1598 = a_players;
	_k1598 = getFirstArrayKey( _a1598 );
	while ( isDefined( _k1598 ) )
	{
		player = _a1598[ _k1598 ];
		if ( !isDefined( self.ignore_player ) )
		{
			self.ignore_player = [];
		}
		if ( isinarray( a_valid_targets, player ) )
		{
			b_is_valid_target = is_player_valid( player );
		}
		b_is_currently_ignored = isinarray( self.ignore_player, player );
		if ( b_is_valid_target && b_is_currently_ignored )
		{
			arrayremovevalue( self.ignore_player, player, 0 );
		}
		else
		{
			if ( !b_is_valid_target && !b_is_currently_ignored )
			{
				self.ignore_player[ self.ignore_player.size ] = player;
			}
		}
		_k1598 = getNextArrayKey( _a1598, _k1598 );
	}
	if ( isDefined( self.enemy ) )
	{
		if ( a_valid_targets.size != 0 )
		{
			b_should_attack_generator = self.ignore_player.size == a_players.size;
		}
	}
	return b_should_attack_generator;
}

play_melee_attack_animation()
{
	self endon( "death" );
	self endon( "poi_state_changed" );
	v_angles = self.angles;
	if ( isDefined( self.attacking_point ) )
	{
		v_angles = self.attacking_point.v_center_pillar - self.origin;
		v_angles = vectorToAngle( ( v_angles[ 0 ], v_angles[ 1 ], 0 ) );
	}
	self animscripted( self.origin, v_angles, "zm_generator_melee" );
	while ( 1 )
	{
		self waittill( "static_melee_anim", note );
		if ( note == "end" )
		{
			return;
		}
		else
		{
		}
	}
}

recapture_zombie_poi_think()
{
	self endon( "death" );
	self.zombie_has_point_of_interest = 0;
	while ( isDefined( self ) && isalive( self ) )
	{
		if ( isDefined( level._poi_override ) )
		{
			zombie_poi = self [[ level._poi_override ]]();
		}
		if ( !isDefined( zombie_poi ) )
		{
			zombie_poi = self get_zombie_point_of_interest( self.origin );
		}
		self.using_poi_last_check = self.zombie_has_point_of_interest;
		if ( isDefined( zombie_poi ) && isarray( zombie_poi ) && isDefined( zombie_poi[ 1 ] ) )
		{
			self.goalradius = 16;
			self.zombie_has_point_of_interest = 1;
			self.is_attacking_zone = 0;
			self.point_of_interest = zombie_poi[ 0 ];
		}
		else
		{
			self.goalradius = 30;
			self.zombie_has_point_of_interest = 0;
			self.point_of_interest = undefined;
			zombie_poi = undefined;
		}
		if ( self.using_poi_last_check != self.zombie_has_point_of_interest )
		{
			self notify( "poi_state_changed" );
			self stopanimscripted( 0,2 );
		}
		wait 1;
	}
}

kill_all_capture_zombies()
{
	while ( isDefined( self.capture_zombies ) && self.capture_zombies.size > 0 )
	{
		_a1702 = self.capture_zombies;
		_k1702 = getFirstArrayKey( _a1702 );
		while ( isDefined( _k1702 ) )
		{
			zombie = _a1702[ _k1702 ];
			if ( isDefined( zombie ) && isalive( zombie ) )
			{
				playfx( level._effect[ "tesla_elec_kill" ], zombie.origin );
				zombie dodamage( zombie.health + 100, zombie.origin );
			}
			wait_network_frame();
			_k1702 = getNextArrayKey( _a1702, _k1702 );
		}
		self.capture_zombies = array_removedead( self.capture_zombies );
	}
	self.capture_zombies = [];
}

kill_all_recapture_zombies()
{
	while ( isDefined( level.zone_capture.recapture_zombies ) && level.zone_capture.recapture_zombies.size > 0 )
	{
		_a1726 = level.zone_capture.recapture_zombies;
		_k1726 = getFirstArrayKey( _a1726 );
		while ( isDefined( _k1726 ) )
		{
			zombie = _a1726[ _k1726 ];
			if ( isDefined( zombie ) && isalive( zombie ) )
			{
				playfx( level._effect[ "tesla_elec_kill" ], zombie.origin );
				zombie dodamage( zombie.health + 100, zombie.origin );
			}
			wait_network_frame();
			_k1726 = getNextArrayKey( _a1726, _k1726 );
		}
		level.zone_capture.recapture_zombies = array_removedead( level.zone_capture.recapture_zombies );
	}
	level.zone_capture.recapture_zombies = [];
}

is_capture_area_occupied( parent_zone )
{
	if ( parent_zone.is_occupied )
	{
		return 1;
	}
	_a1754 = parent_zone.child_capture_zones;
	_k1754 = getFirstArrayKey( _a1754 );
	while ( isDefined( _k1754 ) )
	{
		s_child_zone = _a1754[ _k1754 ];
		if ( s_child_zone.is_occupied )
		{
			return 1;
		}
		_k1754 = getNextArrayKey( _a1754, _k1754 );
	}
	return 0;
}

set_player_controlled_area()
{
	level.zone_capture.last_zone_captured = self;
	self set_player_controlled_zone();
	self play_pap_anim( 1 );
}

update_captured_zone_count()
{
	level.total_capture_zones = get_captured_zone_count();
	if ( level.total_capture_zones == 6 )
	{
		flag_set( "all_zones_captured" );
	}
	else
	{
		flag_clear( "all_zones_captured" );
	}
}

get_captured_zone_count()
{
	n_player_controlled_zones = 0;
	_a1795 = level.zone_capture.zones;
	_k1795 = getFirstArrayKey( _a1795 );
	while ( isDefined( _k1795 ) )
	{
		generator = _a1795[ _k1795 ];
		if ( generator ent_flag( "player_controlled" ) )
		{
			n_player_controlled_zones++;
		}
		_k1795 = getNextArrayKey( _a1795, _k1795 );
	}
	return n_player_controlled_zones;
}

get_contested_zone_count()
{
	return get_contested_zones().size;
}

get_contested_zones()
{
	a_contested_zones = [];
	_a1815 = level.zone_capture.zones;
	_k1815 = getFirstArrayKey( _a1815 );
	while ( isDefined( _k1815 ) )
	{
		generator = _a1815[ _k1815 ];
		if ( generator ent_flag( "zone_contested" ) )
		{
			a_contested_zones[ a_contested_zones.size ] = generator;
		}
		_k1815 = getNextArrayKey( _a1815, _k1815 );
	}
	return a_contested_zones;
}

set_player_controlled_zone()
{
	self ent_flag_set( "player_controlled" );
	self ent_flag_clear( "attacked_by_recapture_zombies" );
	level setclientfield( "zone_capture_hud_generator_" + self.script_int, 1 );
	level setclientfield( "zone_capture_monolith_crystal_" + self.script_int, 0 );
	if ( !isDefined( self.perk_fx_func ) || [[ self.perk_fx_func ]]() )
	{
		level setclientfield( "zone_capture_perk_machine_smoke_fx_" + self.script_int, 1 );
	}
	self ent_flag_set( "player_controlled" );
	update_captured_zone_count();
	self enable_perk_machines_in_zone();
	self enable_random_perk_machines_in_zone();
	self enable_mystery_boxes_in_zone();
	level notify( "zone_captured_by_player" );
}

set_zombie_controlled_area( b_is_level_initializing )
{
	if ( !isDefined( b_is_level_initializing ) )
	{
		b_is_level_initializing = 0;
	}
	update_captured_zone_count();
	if ( b_is_level_initializing )
	{
		level setclientfield( "state_" + self.script_noteworthy, 3 );
		wait_network_frame();
		level setclientfield( "state_" + self.script_noteworthy, 0 );
	}
	if ( self ent_flag( "player_controlled" ) )
	{
		flag_set( "generator_lost_to_recapture_zombies" );
	}
	self set_zombie_controlled_zone( b_is_level_initializing );
	self play_pap_anim( 0 );
}

play_pap_anim( b_assemble )
{
	level setclientfield( "packapunch_anim", get_captured_zone_count() );
}

set_zombie_controlled_zone( b_is_level_initializing )
{
	if ( !isDefined( b_is_level_initializing ) )
	{
		b_is_level_initializing = 0;
	}
	n_hud_state = 2;
	if ( b_is_level_initializing )
	{
		n_hud_state = 0;
	}
	self ent_flag_clear( "player_controlled" );
	level setclientfield( "zone_capture_hud_generator_" + self.script_int, n_hud_state );
	level setclientfield( "zone_capture_monolith_crystal_" + self.script_int, 1 );
	level setclientfield( "zone_capture_perk_machine_smoke_fx_" + self.script_int, 0 );
	update_captured_zone_count();
	self disable_perk_machines_in_zone();
	self disable_random_perk_machines_in_zone();
	self disable_mystery_boxes_in_zone();
}

capture_progress_think()
{
	self init_capture_progress();
	self clear_zone_objective_index();
	self show_zone_capture_objective( 1 );
	self get_zone_objective_index();
	while ( self ent_flag( "zone_contested" ) )
	{
		a_players = get_players();
		a_players_in_capture_zone = self get_players_in_capture_zone();
		_a1930 = a_players;
		_k1930 = getFirstArrayKey( _a1930 );
		while ( isDefined( _k1930 ) )
		{
			player = _a1930[ _k1930 ];
			if ( isinarray( a_players_in_capture_zone, player ) )
			{
				if ( !flag( "recapture_event_in_progress" ) || !self ent_flag( "current_recapture_target_zone" ) )
				{
					objective_setplayerusing( self.n_objective_index, player );
				}
			}
			else
			{
				if ( is_player_valid( player ) )
				{
					objective_clearplayerusing( self.n_objective_index, player );
				}
			}
			_k1930 = getNextArrayKey( _a1930, _k1930 );
		}
		self.n_last_progress = self.n_current_progress;
		self.n_current_progress += self get_progress_rate( a_players_in_capture_zone.size, a_players.size );
		if ( self.n_last_progress != self.n_current_progress )
		{
			self.n_current_progress = clamp( self.n_current_progress, 0, 100 );
			objective_setprogress( self.n_objective_index, self.n_current_progress / 100 );
			self zone_capture_sound_state_think();
			level setclientfield( self.script_noteworthy, self.n_current_progress / 100 );
			self generator_set_state();
			if ( !flag( "recapture_event_in_progress" ) || !self ent_flag( "attacked_by_recapture_zombies" ) )
			{
				b_set_color_to_white = a_players_in_capture_zone.size > 0;
				if ( !flag( "recapture_event_in_progress" ) && self ent_flag( "current_recapture_target_zone" ) )
				{
					b_set_color_to_white = 1;
				}
				level setclientfield( "zc_change_progress_bar_color", b_set_color_to_white );
			}
			update_objective_on_momentum_change();
			if ( self.n_current_progress == 0 || self.n_current_progress == 100 && !self ent_flag( "attacked_by_recapture_zombies" ) )
			{
				self ent_flag_clear( "zone_contested" );
			}
		}
		show_zone_capture_debug_info();
		wait 0,1;
	}
	self ent_flag_clear( "attacked_by_recapture_zombies" );
	self handle_generator_capture();
	self clear_all_zombie_attack_points_in_zone();
}

update_objective_on_momentum_change()
{
	if ( self ent_flag( "current_recapture_target_zone" ) && !flag( "recapture_event_in_progress" ) && self.n_objective_index == 1 && self.n_current_progress > self.n_last_progress )
	{
		self clear_zone_objective_index();
		self show_zone_capture_objective( 1 );
		level setclientfield( "zc_change_progress_bar_color", 1 );
	}
}

get_zone_objective_index()
{
	if ( !isDefined( self.n_objective_index ) )
	{
		if ( self ent_flag( "current_recapture_target_zone" ) )
		{
			if ( flag( "recapture_event_in_progress" ) )
			{
				n_objective = 1;
			}
			else
			{
				n_objective = 2;
			}
		}
		else
		{
			n_objective = 0;
		}
		self.n_objective_index = n_objective;
	}
	return self.n_objective_index;
}

get_zones_using_objective_index( n_index )
{
	n_zones_using_objective_index = 0;
	_a2040 = level.zone_capture.zones;
	_k2040 = getFirstArrayKey( _a2040 );
	while ( isDefined( _k2040 ) )
	{
		zone = _a2040[ _k2040 ];
		if ( isDefined( zone.n_objective_index ) && zone.n_objective_index == n_index )
		{
			n_zones_using_objective_index++;
		}
		_k2040 = getNextArrayKey( _a2040, _k2040 );
	}
	return n_zones_using_objective_index;
}

zone_capture_sound_state_think()
{
	if ( !isDefined( self.is_playing_audio ) )
	{
		self.is_playing_audio = 0;
	}
	if ( self.n_current_progress > self.n_last_progress )
	{
		if ( self.is_playing_audio )
		{
			self.sndent stoploopsound();
			self.is_playing_audio = 0;
		}
	}
	else
	{
		if ( !self.is_playing_audio && flag( "generator_under_attack" ) )
		{
			self.sndent playloopsound( "zmb_capturezone_generator_alarm", 0,25 );
			self.is_playing_audio = 1;
		}
	}
}

handle_generator_capture()
{
	level setclientfield( "zc_change_progress_bar_color", 0 );
	self show_zone_capture_objective( 0 );
	if ( self.n_current_progress == 100 )
	{
		self players_capture_zone();
		self kill_all_capture_zombies();
	}
	else if ( self.n_current_progress == 0 )
	{
		while ( self ent_flag( "player_controlled" ) )
		{
			self.sndent stoploopsound( 0,25 );
			self thread generator_deactivated_vo();
			self.is_playing_audio = 0;
			_a2095 = get_players();
			_k2095 = getFirstArrayKey( _a2095 );
			while ( isDefined( _k2095 ) )
			{
				player = _a2095[ _k2095 ];
				player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_generator_lost", 0 );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_generator_lost" );
				_k2095 = getNextArrayKey( _a2095, _k2095 );
			}
		}
		self set_zombie_controlled_area();
		if ( flag( "recapture_event_in_progress" ) && get_captured_zone_count() > 0 )
		{
		}
		else
		{
			self kill_all_capture_zombies();
		}
	}
	if ( get_contested_zone_count() == 0 )
	{
		flag_clear( "zone_capture_in_progress" );
	}
}

init_capture_progress()
{
	if ( !isDefined( level.zone_capture.rate_capture ) )
	{
		level.zone_capture.rate_capture = get_update_rate( 10 );
	}
	if ( !isDefined( level.zone_capture.rate_capture_solo ) )
	{
		level.zone_capture.rate_capture_solo = get_update_rate( 12 );
	}
	if ( !isDefined( level.zone_capture.rate_decay ) )
	{
		level.zone_capture.rate_decay = get_update_rate( 20 ) * -1;
	}
	if ( !isDefined( level.zone_capture.rate_recapture ) )
	{
		level.zone_capture.rate_recapture = get_update_rate( 40 ) * -1;
	}
	if ( !isDefined( level.zone_capture.rate_recapture_players ) )
	{
		level.zone_capture.rate_recapture_players = get_update_rate( 10 );
	}
	if ( !self ent_flag( "player_controlled" ) )
	{
		self.n_current_progress = 0;
		self ent_flag_clear( "attacked_by_recapture_zombies" );
	}
	self ent_flag_set( "zone_contested" );
}

get_progress_rate( n_players_in_zone, n_players_total )
{
	if ( flag( "recapture_event_in_progress" ) && self ent_flag( "current_recapture_target_zone" ) )
	{
		if ( self get_recapture_attacker_count() > 0 )
		{
			n_rate = level.zone_capture.rate_recapture;
		}
		else if ( !self ent_flag( "attacked_by_recapture_zombies" ) )
		{
			n_rate = 0;
		}
		else
		{
			n_rate = level.zone_capture.rate_recapture_players;
		}
	}
	else
	{
		if ( self ent_flag( "current_recapture_target_zone" ) )
		{
			n_rate = level.zone_capture.rate_recapture_players;
		}
		else if ( n_players_in_zone > 0 )
		{
			if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
			{
				n_rate = level.zone_capture.rate_capture_solo;
			}
			else
			{
				n_rate = level.zone_capture.rate_capture * ( n_players_in_zone / n_players_total );
			}
		}
		else
		{
			n_rate = level.zone_capture.rate_decay;
		}
	}
	return n_rate;
}

show_zone_capture_objective( b_show_objective )
{
	self get_zone_objective_index();
	if ( b_show_objective )
	{
		objective_position( self.n_objective_index, self.origin );
		objective_setgamemodeflags( self.n_objective_index, self.script_int );
		objective_state( self.n_objective_index, "active" );
	}
	else
	{
		self clear_zone_objective_index();
	}
}

clear_zone_objective_index()
{
	while ( isDefined( self.n_objective_index ) && get_zones_using_objective_index( self.n_objective_index ) < 2 )
	{
		objective_state( self.n_objective_index, "invisible" );
		a_players = get_players();
		_a2205 = a_players;
		_k2205 = getFirstArrayKey( _a2205 );
		while ( isDefined( _k2205 ) )
		{
			player = _a2205[ _k2205 ];
			objective_clearplayerusing( self.n_objective_index, player );
			_k2205 = getNextArrayKey( _a2205, _k2205 );
		}
	}
	self.n_objective_index = undefined;
}

hide_zone_objective_while_recapture_group_runs_to_next_generator( b_hide_icon )
{
	self clear_zone_objective_index();
	flag_clear( "generator_under_attack" );
	if ( !b_hide_icon )
	{
		recapture_zombie_group_icon_show();
	}
	wait 1;
	if ( !flag( "recapture_zombies_cleared" ) && !flag( "recapture_zombies_cleared" ) )
	{
		self thread generator_compromised_vo();
	}
}

recapture_zombie_group_icon_show()
{
	level endon( "recapture_zombies_cleared" );
	if ( isDefined( level.zone_capture.recapture_zombies ) && flag( "recapture_event_in_progress" ) )
	{
		while ( !level.zone_capture.recapture_zombies.size )
		{
			wait_network_frame();
			level.zone_capture.recapture_zombies = array_removedead( level.zone_capture.recapture_zombies );
		}
		flag_waitopen( "generator_under_attack" );
		if ( level.zone_capture.recapture_zombies.size > 0 )
		{
			ai_zombie = random( level.zone_capture.recapture_zombies );
			objective_state( 3, "active" );
			objective_onentity( 3, ai_zombie );
			ai_zombie thread recapture_zombie_icon_think();
		}
	}
}

recapture_zombie_icon_think()
{
	while ( isalive( self ) && !flag( "generator_under_attack" ) )
	{
/#
		debugstar( self.origin, 20, ( 0, 0, 1 ) );
#/
		wait 1;
	}
	recapture_zombie_group_icon_hide();
	wait_network_frame();
	if ( !flag( "recapture_zombies_cleared" ) )
	{
		recapture_zombie_group_icon_show();
	}
}

recapture_zombie_group_icon_hide()
{
	objective_state( 3, "invisible" );
	if ( isalive( self ) )
	{
		objective_clearentity( 3 );
	}
}

players_capture_zone()
{
	self.sndent playsound( "zmb_capturezone_success" );
	self.sndent stoploopsound( 0,25 );
	wait_network_frame();
	if ( !flag( "recapture_event_in_progress" ) && !self ent_flag( "player_controlled" ) )
	{
		self thread zone_capture_complete_vo();
	}
	reward_players_in_capture_zone();
	self set_player_controlled_area();
	wait_network_frame();
	playfx( level._effect[ "capture_complete" ], self.origin );
	level thread sndplaygeneratormusicstinger();
}

reward_players_in_capture_zone()
{
	b_challenge_exists = maps/mp/zombies/_zm_challenges::challenge_exists( "zc_zone_captures" );
	while ( !self ent_flag( "player_controlled" ) )
	{
		_a2321 = get_players_in_capture_zone();
		_k2321 = getFirstArrayKey( _a2321 );
		while ( isDefined( _k2321 ) )
		{
			player = _a2321[ _k2321 ];
			player notify( "completed_zone_capture" );
			player maps/mp/zombies/_zm_score::player_add_points( "bonus_points_powerup", 100 );
			if ( b_challenge_exists )
			{
				player maps/mp/zombies/_zm_challenges::increment_stat( "zc_zone_captures" );
			}
			player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_generator_captured", 0 );
			player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_generator_captured" );
			_k2321 = getNextArrayKey( _a2321, _k2321 );
		}
	}
}

show_zone_capture_debug_info()
{
/#
	while ( getDvarInt( #"1AD074DA" ) > 0 )
	{
		print3d( self.origin, "progress = " + self.n_current_progress, ( 0, 0, 1 ) );
		circle( groundtrace( self.origin, self.origin - vectorScale( ( 0, 0, 1 ), 1000 ), 0, undefined )[ "position" ], 220, ( 0, 0, 1 ), 0, 4 );
		_a2349 = self.zombie_attack_points;
		n_index = getFirstArrayKey( _a2349 );
		while ( isDefined( n_index ) )
		{
			attack_point = _a2349[ n_index ];
			if ( attack_point.inaccessible )
			{
				v_color = ( 0, 0, 1 );
			}
			else if ( attack_point.is_claimed )
			{
				v_color = ( 0, 0, 1 );
			}
			else
			{
				v_color = ( 0, 0, 1 );
			}
			debugstar( attack_point.origin, 4, v_color );
			print3d( attack_point.origin + vectorScale( ( 0, 0, 1 ), 10 ), n_index, v_color, 1, 1, 4 );
			n_index = getNextArrayKey( _a2349, n_index );
#/
		}
	}
}

get_players_in_capture_zone()
{
	a_players_in_capture_zone = [];
	_a2376 = get_players();
	_k2376 = getFirstArrayKey( _a2376 );
	while ( isDefined( _k2376 ) )
	{
		player = _a2376[ _k2376 ];
		if ( is_player_valid( player ) && distance2dsquared( player.origin, self.origin ) < 48400 && player.origin[ 2 ] > ( self.origin[ 2 ] + -20 ) )
		{
			a_players_in_capture_zone[ a_players_in_capture_zone.size ] = player;
		}
		_k2376 = getNextArrayKey( _a2376, _k2376 );
	}
	return a_players_in_capture_zone;
}

get_update_rate( n_duration )
{
	n_change_per_update = ( 100 / n_duration ) * 0,1;
	return n_change_per_update;
}

generator_set_state()
{
	n_generator_state = level getclientfield( "state_" + self.script_noteworthy );
	if ( self.n_current_progress == 0 )
	{
		self generator_state_turn_off();
	}
	else if ( n_generator_state == 0 && self.n_current_progress > 0 )
	{
		self generator_state_turn_on();
	}
	else
	{
		if ( self can_start_generator_power_up_anim() )
		{
			self generator_state_power_up();
			return;
		}
		else
		{
			if ( n_generator_state == 2 && self.n_current_progress < self.n_last_progress )
			{
				self generator_state_power_down();
				if ( !flag( "recapture_event_in_progress" ) )
				{
					self thread generator_interrupted_vo();
				}
			}
		}
	}
}

generator_state_turn_on()
{
	level setclientfield( "state_" + self.script_noteworthy, 1 );
	self.n_time_started_generator = getTime();
}

generator_state_power_up()
{
	level setclientfield( "state_" + self.script_noteworthy, 2 );
}

generator_state_power_down()
{
	if ( self ent_flag( "attacked_by_recapture_zombies" ) )
	{
		n_state = 5;
	}
	else
	{
		n_state = 3;
	}
	level setclientfield( "state_" + self.script_noteworthy, n_state );
}

generator_state_turn_off()
{
	level setclientfield( "state_" + self.script_noteworthy, 4 );
	self thread generator_turns_off_after_anim();
}

generator_turns_off_after_anim()
{
	wait getanimlength( %fxanim_zom_tomb_generator_end_anim );
	self generator_state_off();
}

generator_state_off()
{
	level setclientfield( "state_" + self.script_noteworthy, 0 );
}

can_start_generator_power_up_anim()
{
	if ( !isDefined( self.n_time_started_generator ) )
	{
		self.n_time_started_generator = 0;
	}
	if ( !isDefined( self.n_time_start_anim ) )
	{
		self.n_time_start_anim = getanimlength( %fxanim_zom_tomb_generator_start_anim );
	}
	if ( self.n_current_progress > self.n_last_progress )
	{
		return ( ( getTime() - self.n_time_started_generator ) * 0,001 ) > self.n_time_start_anim;
	}
}

get_recapture_attacker_count()
{
	n_zone_attacker_count = 0;
	_a2475 = level.zone_capture.recapture_zombies;
	_k2475 = getFirstArrayKey( _a2475 );
	while ( isDefined( _k2475 ) )
	{
		zombie = _a2475[ _k2475 ];
		if ( isalive( zombie ) && isDefined( zombie.is_attacking_zone ) && zombie.is_attacking_zone && !isDefined( self.script_noteworthy ) || !isDefined( level.zone_capture.recapture_target ) && isDefined( self.script_noteworthy ) && isDefined( level.zone_capture.recapture_target ) && self.script_noteworthy == level.zone_capture.recapture_target )
		{
			n_zone_attacker_count++;
		}
		_k2475 = getNextArrayKey( _a2475, _k2475 );
	}
	return n_zone_attacker_count;
}

watch_for_open_sesame()
{
/#
	level waittill( "open_sesame" );
	level.b_open_sesame = 1;
	a_generators = getstructarray( "s_generator", "targetname" );
	_a2495 = a_generators;
	_k2495 = getFirstArrayKey( _a2495 );
	while ( isDefined( _k2495 ) )
	{
		s_generator = _a2495[ _k2495 ];
		s_temp = level.zone_capture.zones[ s_generator.script_noteworthy ];
		s_temp debug_set_generator_active();
		wait_network_frame();
		_k2495 = getNextArrayKey( _a2495, _k2495 );
#/
	}
}

debug_watch_for_zone_capture()
{
/#
	while ( 1 )
	{
		level waittill( "force_zone_capture", n_zone );
		_a2510 = level.zone_capture.zones;
		_k2510 = getFirstArrayKey( _a2510 );
		while ( isDefined( _k2510 ) )
		{
			zone = _a2510[ _k2510 ];
			if ( zone.script_int == n_zone && !zone ent_flag( "player_controlled" ) )
			{
				zone debug_set_generator_active();
			}
			_k2510 = getNextArrayKey( _a2510, _k2510 );
		}
#/
	}
}

debug_watch_for_zone_recapture()
{
/#
	while ( 1 )
	{
		level waittill( "force_zone_recapture", n_zone );
		_a2526 = level.zone_capture.zones;
		_k2526 = getFirstArrayKey( _a2526 );
		while ( isDefined( _k2526 ) )
		{
			zone = _a2526[ _k2526 ];
			if ( zone.script_int == n_zone && zone ent_flag( "player_controlled" ) )
			{
				zone debug_set_generator_inactive();
			}
			_k2526 = getNextArrayKey( _a2526, _k2526 );
		}
#/
	}
}

debug_set_generator_active()
{
/#
	self set_player_controlled_area();
	self.n_current_progress = 100;
	self generator_state_power_up();
	level setclientfield( self.script_noteworthy, self.n_current_progress / 100 );
#/
}

debug_set_generator_inactive()
{
/#
	self set_zombie_controlled_area();
	self.n_current_progress = 0;
	self generator_state_turn_off();
	level setclientfield( self.script_noteworthy, self.n_current_progress / 100 );
#/
}

set_magic_box_zbarrier_state( state )
{
	i = 0;
	while ( i < self getnumzbarrierpieces() )
	{
		self hidezbarrierpiece( i );
		i++;
	}
	self notify( "zbarrier_state_change" );
	switch( state )
	{
		case "away":
			self showzbarrierpiece( 0 );
			self.state = "away";
			self.owner.is_locked = 0;
			break;
		case "arriving":
			self showzbarrierpiece( 1 );
			self thread magic_box_arrives();
			self.state = "arriving";
			break;
		case "initial":
			self showzbarrierpiece( 1 );
			self thread magic_box_initial();
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, ::maps/mp/zombies/_zm_magicbox::magicbox_unitrigger_think );
			self.state = "close";
			break;
		case "open":
			self showzbarrierpiece( 2 );
			self thread maps/mp/zombies/_zm_magicbox_tomb::magic_box_opens();
			self.state = "open";
			break;
		case "close":
			self showzbarrierpiece( 2 );
			self thread maps/mp/zombies/_zm_magicbox_tomb::magic_box_closes();
			self.state = "close";
			break;
		case "leaving":
			self showzbarrierpiece( 1 );
			self thread magic_box_leaves();
			self.state = "leaving";
			self.owner.is_locked = 0;
			break;
		case "zombie_controlled":
			if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] )
			{
				self showzbarrierpiece( 2 );
				self setclientfield( "magicbox_amb_fx", 0 );
			}
			if ( self.state == "initial" || self.state == "close" )
			{
				self showzbarrierpiece( 1 );
				self setclientfield( "magicbox_amb_fx", 1 );
			}
			else
			{
				if ( self.state == "away" )
				{
					self showzbarrierpiece( 0 );
					self setclientfield( "magicbox_amb_fx", 0 );
				}
				else
				{
					if ( self.state == "open" || self.state == "leaving" )
					{
						self showzbarrierpiece( 2 );
						self setclientfield( "magicbox_amb_fx", 0 );
					}
				}
			}
			break;
		case "player_controlled":
			if ( self.state == "arriving" || self.state == "close" )
			{
				self showzbarrierpiece( 2 );
				self setclientfield( "magicbox_amb_fx", 2 );
				break;
		}
		else
		{
			if ( self.state == "away" )
			{
				self showzbarrierpiece( 0 );
				self setclientfield( "magicbox_amb_fx", 3 );
			}
			break;
		return;
		default:
			if ( isDefined( level.custom_magicbox_state_handler ) )
			{
				self [[ level.custom_magicbox_state_handler ]]( state );
			}
			break;
		return;
	}
}
}

magic_box_trigger_update_prompt( player )
{
	can_use = self magic_box_stub_update_prompt( player );
	if ( isDefined( self.stub.hint_string ) )
	{
		if ( isDefined( self.stub.hint_parm1 ) )
		{
			self sethintstring( self.stub.hint_string, self.stub.hint_parm1 );
		}
		else
		{
			self sethintstring( self.stub.hint_string );
		}
	}
	return can_use;
}

magic_box_stub_update_prompt( player )
{
	self setcursorhint( "HINT_NOICON" );
	if ( !self trigger_visible_to_player( player ) )
	{
		return 0;
	}
	self.stub.hint_parm1 = undefined;
	if ( isDefined( self.stub.trigger_target.grab_weapon_hint ) && self.stub.trigger_target.grab_weapon_hint )
	{
		self.stub.hint_string = &"ZOMBIE_TRADE_WEAPONS";
	}
	else
	{
		if ( !level.zone_capture.zones[ self.stub.zone ] ent_flag( "player_controlled" ) )
		{
			self.stub.hint_string = &"ZM_TOMB_ZC";
			return 0;
		}
		else
		{
			self.stub.hint_parm1 = self.stub.trigger_target.zombie_cost;
			self.stub.hint_string = get_hint_string( self, "default_treasure_chest" );
		}
	}
	return 1;
}

recapture_round_tracker()
{
	n_next_recapture_round = 10;
	while ( 1 )
	{
/#
		iprintln( "Next Recapture Round = " + n_next_recapture_round );
#/
		level waittill_any( "between_round_over", "force_recapture_start" );
/#
		if ( getDvarInt( #"EF89C4FC" ) > 0 )
		{
			n_next_recapture_round = level.round_number;
#/
		}
		if ( level.round_number >= n_next_recapture_round && !flag( "zone_capture_in_progress" ) && get_captured_zone_count() >= get_player_controlled_zone_count_for_recapture() )
		{
			n_next_recapture_round = level.round_number + randomintrange( 3, 6 );
			level thread recapture_round_start();
		}
	}
}

get_player_controlled_zone_count_for_recapture()
{
	n_zones_required = 4;
/#
	if ( getDvarInt( #"EF89C4FC" ) > 0 )
	{
		n_zones_required = 1;
#/
	}
	return n_zones_required;
}

get_recapture_zone( s_last_recapture_zone )
{
	a_s_player_zones = [];
	_a2770 = level.zone_capture.zones;
	str_key = getFirstArrayKey( _a2770 );
	while ( isDefined( str_key ) )
	{
		s_zone = _a2770[ str_key ];
		if ( s_zone ent_flag( "player_controlled" ) )
		{
			a_s_player_zones[ str_key ] = s_zone;
		}
		str_key = getNextArrayKey( _a2770, str_key );
	}
	s_recapture_zone = undefined;
	while ( a_s_player_zones.size )
	{
		if ( isDefined( s_last_recapture_zone ) )
		{
			n_distance_closest = undefined;
			_a2788 = a_s_player_zones;
			_k2788 = getFirstArrayKey( _a2788 );
			while ( isDefined( _k2788 ) )
			{
				s_zone = _a2788[ _k2788 ];
				n_distance = distancesquared( s_zone.origin, s_last_recapture_zone.origin );
				if ( !isDefined( n_distance_closest ) || n_distance < n_distance_closest )
				{
					s_recapture_zone = s_zone;
					n_distance_closest = n_distance;
				}
				_k2788 = getNextArrayKey( _a2788, _k2788 );
			}
		}
		else s_recapture_zone = random( a_s_player_zones );
/#
		while ( getDvarInt( #"8178CABA" ) > 0 )
		{
			n_zone = getDvarInt( #"8178CABA" );
			_a2808 = level.zone_capture.zones;
			_k2808 = getFirstArrayKey( _a2808 );
			while ( isDefined( _k2808 ) )
			{
				zone = _a2808[ _k2808 ];
				if ( n_zone == zone.script_int && zone ent_flag( "player_controlled" ) )
				{
					s_recapture_zone = zone;
					break;
				}
				else
				{
					_k2808 = getNextArrayKey( _a2808, _k2808 );
#/
				}
			}
		}
	}
	return s_recapture_zone;
}

recapture_round_start()
{
	flag_set( "recapture_event_in_progress" );
	flag_clear( "recapture_zombies_cleared" );
	flag_clear( "generator_under_attack" );
	level.recapture_zombies_killed = 0;
	b_is_first_generator_attack = 1;
	s_recapture_target_zone = undefined;
	capture_event_handle_ai_limit();
	recapture_round_audio_starts();
	while ( !flag( "recapture_zombies_cleared" ) && get_captured_zone_count() > 0 )
	{
		s_recapture_target_zone = get_recapture_zone( s_recapture_target_zone );
		level.zone_capture.recapture_target = s_recapture_target_zone.script_noteworthy;
		s_recapture_target_zone maps/mp/zm_tomb_capture_zones_ffotd::recapture_event_start();
		if ( b_is_first_generator_attack )
		{
			s_recapture_target_zone thread monitor_recapture_zombies();
		}
		set_recapture_zombie_attack_target( s_recapture_target_zone );
		s_recapture_target_zone thread generator_under_attack_warnings();
		s_recapture_target_zone ent_flag_set( "current_recapture_target_zone" );
		s_recapture_target_zone thread hide_zone_objective_while_recapture_group_runs_to_next_generator( b_is_first_generator_attack );
		s_recapture_target_zone activate_capture_zone( b_is_first_generator_attack );
		s_recapture_target_zone ent_flag_clear( "attacked_by_recapture_zombies" );
		s_recapture_target_zone ent_flag_clear( "current_recapture_target_zone" );
		if ( b_is_first_generator_attack && !s_recapture_target_zone ent_flag( "player_controlled" ) )
		{
			delay_thread( 3, ::broadcast_vo_category_to_team, "recapture_started" );
		}
		b_is_first_generator_attack = 0;
		s_recapture_target_zone maps/mp/zm_tomb_capture_zones_ffotd::recapture_event_end();
		wait 0,05;
	}
	if ( s_recapture_target_zone.n_current_progress == 0 || s_recapture_target_zone.n_current_progress == 100 )
	{
		s_recapture_target_zone handle_generator_capture();
	}
	capture_event_handle_ai_limit();
	kill_all_recapture_zombies();
	recapture_round_audio_ends();
	flag_clear( "recapture_event_in_progress" );
	flag_clear( "generator_under_attack" );
}

broadcast_vo_category_to_team( str_category, n_delay )
{
	if ( !isDefined( n_delay ) )
	{
		n_delay = 1;
	}
	a_players = get_players();
	a_speakers = [];
	e_speaker = get_random_speaker( a_players );
	a_speakers[ a_speakers.size ] = e_speaker;
	arrayremovevalue( a_players, e_speaker );
	a_players = e_speaker get_players_too_far_to_hear( a_players );
	i = 0;
	while ( i < a_speakers.size )
	{
		a_speakers[ i ] delay_thread( n_delay, ::create_and_play_dialog, "zone_capture", str_category );
		i++;
	}
}

get_players_too_far_to_hear( a_players )
{
	a_distant = [];
	_a2921 = a_players;
	_k2921 = getFirstArrayKey( _a2921 );
	while ( isDefined( _k2921 ) )
	{
		player = _a2921[ _k2921 ];
		if ( distancesquared( player.origin, self.origin ) > 640000 && is_player_valid( player ) && !player isplayeronsamemachine( self ) )
		{
			a_distant[ a_distant.size ] = player;
		}
		_k2921 = getNextArrayKey( _a2921, _k2921 );
	}
	return a_distant;
}

get_random_speaker( a_players )
{
	if ( !isDefined( a_players ) )
	{
		a_players = get_players();
	}
	a_valid_players = [];
	_a2942 = a_players;
	_k2942 = getFirstArrayKey( _a2942 );
	while ( isDefined( _k2942 ) )
	{
		player = _a2942[ _k2942 ];
		if ( is_player_valid( player ) )
		{
			a_valid_players[ a_valid_players.size ] = player;
		}
		_k2942 = getNextArrayKey( _a2942, _k2942 );
	}
	return random( a_valid_players );
}

set_recapture_zombie_attack_target( s_recapture_target_zone )
{
	flag_clear( "generator_under_attack" );
	s_recapture_target_zone ent_flag_clear( "attacked_by_recapture_zombies" );
	_a2958 = level.zone_capture.recapture_zombies;
	_k2958 = getFirstArrayKey( _a2958 );
	while ( isDefined( _k2958 ) )
	{
		zombie = _a2958[ _k2958 ];
		zombie.is_attacking_zone = 0;
		zombie.s_attack_generator = s_recapture_target_zone;
		zombie.attacking_new_generator = 1;
		_k2958 = getNextArrayKey( _a2958, _k2958 );
	}
}

sndrecaptureroundloop()
{
	level endon( "sndEndRoundLoop" );
	wait 5;
	ent = spawn( "script_origin", ( 0, 0, 1 ) );
	ent playloopsound( "mus_recapture_round_loop", 5 );
	ent thread sndrecaptureroundloop_stop();
}

sndrecaptureroundloop_stop()
{
	flag_wait( "recapture_zombies_cleared" );
	self stoploopsound( 2 );
	wait 2;
	self delete();
}

monitor_recapture_zombie_count()
{
	while ( 1 )
	{
		level.zone_capture.recapture_zombies = array_removedead( level.zone_capture.recapture_zombies );
		if ( level.zone_capture.recapture_zombies.size == 0 )
		{
			flag_set( "recapture_zombies_cleared" );
			flag_clear( "recapture_event_in_progress" );
			flag_clear( "generator_under_attack" );
			if ( isDefined( level.zone_capture.recapture_target ) )
			{
				level.zone_capture.zones[ level.zone_capture.recapture_target ] ent_flag_clear( "attacked_by_recapture_zombies" );
				level.zone_capture.recapture_target = undefined;
			}
			return;
		}
		else
		{
			wait 1;
		}
	}
}

recapture_zombie_death_func()
{
	if ( isDefined( self.is_recapture_zombie ) && self.is_recapture_zombie )
	{
		level.recapture_zombies_killed++;
		while ( isDefined( self.attacker ) && isplayer( self.attacker ) && level.recapture_zombies_killed == get_recapture_zombies_needed() )
		{
			self.attacker thread delay_thread( 2, ::create_and_play_dialog, "zone_capture", "recapture_prevented" );
			_a3017 = get_players();
			_k3017 = getFirstArrayKey( _a3017 );
			while ( isDefined( _k3017 ) )
			{
				player = _a3017[ _k3017 ];
				player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_generator_defended", 0 );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_generator_defended" );
				_k3017 = getNextArrayKey( _a3017, _k3017 );
			}
		}
		if ( level.recapture_zombies_killed == get_recapture_zombies_needed() && flag( "generator_under_attack" ) )
		{
			self drop_max_ammo_at_death_location();
		}
	}
}

drop_max_ammo_at_death_location()
{
	if ( isDefined( self ) )
	{
		v_powerup_origin = groundtrace( self.origin + vectorScale( ( 0, 0, 1 ), 10 ), self.origin + vectorScale( ( 0, 0, 1 ), 150 ), 0, undefined, 1 )[ "position" ];
	}
	if ( isDefined( v_powerup_origin ) )
	{
		level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "full_ammo", v_powerup_origin );
	}
}

generator_under_attack_warnings()
{
	flag_wait_any( "generator_under_attack", "recapture_zombies_cleared" );
	if ( !flag( "recapture_zombies_cleared" ) )
	{
		e_alarm_sound = spawn( "script_origin", self.origin );
		e_alarm_sound playloopsound( "zmb_capturezone_losing" );
		e_alarm_sound thread play_flare_effect();
		wait 0,5;
		flag_waitopen( "generator_under_attack" );
		e_alarm_sound stoploopsound( 0,2 );
		wait 0,5;
		e_alarm_sound delete();
	}
}

play_flare_effect()
{
	self endon( "death" );
	n_end_time = getTime() + 5000;
	while ( flag( "generator_under_attack" ) )
	{
		playfx( level._effect[ "lght_marker_flare" ], self.origin );
		wait 4;
	}
}

recapture_round_audio_starts()
{
	level.music_round_override = 1;
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "dog_start" );
	level thread sndrecaptureroundloop();
}

recapture_round_audio_ends()
{
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "dog_end" );
	level.music_round_override = 0;
	level notify( "sndEndRoundLoop" );
}

custom_vending_power_on()
{
}

custom_vending_power_off()
{
}

generator_initiated_vo()
{
	e_vo_origin = spawn( "script_origin", self.origin );
	level.maxis_generator_vo = 1;
	e_vo_origin playsoundwithnotify( "vox_maxi_generator_initiate_0", "vox_maxi_generator_initiate_0_done" );
	e_vo_origin waittill( "vox_maxi_generator_initiate_0_done" );
	level.maxis_generator_vo = 0;
	e_vo_origin delete();
}

zone_capture_complete_vo()
{
	e_vo_origin = spawn( "script_origin", self.origin );
	e_vo_origin playsoundwithnotify( "vox_maxi_generator_process_complete_0", "vox_maxi_generator_process_complete_0_done" );
	e_vo_origin waittill( "vox_maxi_generator_process_complete_0_done" );
	e_vo_origin playsoundwithnotify( "vox_maxi_generator_" + self.script_int + "_activated_0", "vox_maxi_generator_" + self.script_int + "_activated_0_done" );
	e_vo_origin waittill( "vox_maxi_generator_" + self.script_int + "_activated_0_done" );
	e_vo_origin delete();
}

generator_interrupted_vo()
{
	e_vo_origin = spawn( "script_origin", self.origin );
	e_vo_origin playsoundwithnotify( "vox_maxi_generator_interrupted_0", "vox_maxi_generator_interrupted_0_done" );
	e_vo_origin waittill( "vox_maxi_generator_interrupted_0_done" );
	e_vo_origin delete();
}

generator_compromised_vo()
{
	e_vo_origin = spawn( "script_origin", self.origin );
	e_vo_origin playsoundwithnotify( "vox_maxi_generator_" + self.script_int + "_compromised_0", "vox_maxi_generator_" + self.script_int + "_compromised_0_done" );
	e_vo_origin waittill( "vox_maxi_generator_" + self.script_int + "_compromised_0_done" );
	e_vo_origin delete();
}

generator_deactivated_vo()
{
	e_vo_origin = spawn( "script_origin", self.origin );
	e_vo_origin playsoundwithnotify( "vox_maxi_generator_" + self.script_int + "_deactivated_0", "vox_maxi_generator_" + self.script_int + "_deactivated_0_done" );
	e_vo_origin waittill( "vox_maxi_generator_" + self.script_int + "_deactivated_0_done" );
	e_vo_origin delete();
}

sndplaygeneratormusicstinger()
{
	num = get_captured_zone_count();
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "generator_" + num );
}
