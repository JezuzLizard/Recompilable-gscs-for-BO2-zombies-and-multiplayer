#include maps/mp/zm_alcatraz_travel;
#include maps/mp/zm_alcatraz_sq_vo;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_craftables()
{
	precachestring( &"ZM_PRISON_KEY_DOOR" );
	level.craftable_piece_count = 10;
	register_clientfields();
	add_zombie_craftable( "alcatraz_shield_zm", &"ZM_PRISON_CRAFT_RIOT", undefined, &"ZOMBIE_BOUGHT_RIOT", undefined, 1 );
	add_zombie_craftable_vox_category( "alcatraz_shield_zm", "build_zs" );
	make_zombie_craftable_open( "alcatraz_shield_zm", "t6_wpn_zmb_shield_dlc2_dmg0_world", vectorScale( ( 0, 0, 0 ), 90 ), ( 0, 0, level.riotshield_placement_zoffset ) );
	add_zombie_craftable( "packasplat", &"ZM_PRISON_CRAFT_PACKASPLAT", undefined, undefined, ::onfullycrafted_packasplat, 1 );
	add_zombie_craftable_vox_category( "packasplat", "build_bsm" );
	make_zombie_craftable_open( "packasplat", "p6_anim_zm_al_packasplat", vectorScale( ( 0, 0, 0 ), 90 ) );
	level.craftable_piece_swap_allowed = 0;
	add_zombie_craftable( "quest_key1" );
	add_zombie_craftable( "plane", &"ZM_PRISON_CRAFT_PLANE", &"ZM_PRISON_CRAFTING_PLANE", undefined, ::onfullycrafted_plane );
	add_zombie_craftable( "refuelable_plane", &"ZM_PRISON_REFUEL_PLANE", &"ZM_PRISON_REFUELING_PLANE", undefined, ::onfullycrafted_refueled );
	in_game_checklist_setup();
}

include_key_craftable( craftable_name, model_name )
{
	part_key = generate_zombie_craftable_piece( craftable_name, undefined, model_name, 32, 15, 0, undefined, ::onpickup_key, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	part = spawnstruct();
	part.name = craftable_name;
	part add_craftable_piece( part_key );
	part.triggerthink = ::maps/mp/zombies/_zm_craftables::setup_craftable_pieces;
	include_craftable( part );
}

include_craftables()
{
	level.zombie_include_craftables[ "open_table" ].custom_craftablestub_update_prompt = ::prison_open_craftablestub_update_prompt;
	craftable_name = "alcatraz_shield_zm";
	riotshield_dolly = generate_zombie_craftable_piece( craftable_name, "dolly", "t6_wpn_zmb_shield_dlc2_dolly", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_dolly", 1, "build_zs" );
	riotshield_door = generate_zombie_craftable_piece( craftable_name, "door", "t6_wpn_zmb_shield_dlc2_door", 48, 15, 25, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_door", 1, "build_zs" );
	riotshield_clamp = generate_zombie_craftable_piece( craftable_name, "clamp", "t6_wpn_zmb_shield_dlc2_shackles", 32, 15, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_clamp", 1, "build_zs" );
	riotshield = spawnstruct();
	riotshield.name = craftable_name;
	riotshield add_craftable_piece( riotshield_dolly );
	riotshield add_craftable_piece( riotshield_door );
	riotshield add_craftable_piece( riotshield_clamp );
	riotshield.onbuyweapon = ::onbuyweapon_riotshield;
	riotshield.triggerthink = ::riotshieldcraftable;
	include_craftable( riotshield );
	craftable_name = "packasplat";
	packasplat_case = generate_zombie_craftable_piece( craftable_name, "case", "p6_zm_al_packasplat_suitcase", 48, 36, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_case", 1, "build_bsm" );
	packasplat_fuse = generate_zombie_craftable_piece( craftable_name, "fuse", "p6_zm_al_packasplat_engine", 32, 36, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_fuse", 1, "build_bsm" );
	packasplat_blood = generate_zombie_craftable_piece( craftable_name, "blood", "p6_zm_al_packasplat_iv", 32, 15, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_blood", 1, "build_bsm" );
	packasplat = spawnstruct();
	packasplat.name = craftable_name;
	packasplat add_craftable_piece( packasplat_case );
	packasplat add_craftable_piece( packasplat_fuse );
	packasplat add_craftable_piece( packasplat_blood );
	packasplat.triggerthink = ::packasplatcraftable;
	include_craftable( packasplat );
	include_key_craftable( "quest_key1", "p6_zm_al_key" );
	craftable_name = "plane";
	plane_cloth = generate_zombie_craftable_piece( craftable_name, "cloth", "p6_zm_al_clothes_pile_lrg", 48, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_origin", undefined, 1 );
	plane_fueltanks = generate_zombie_craftable_piece( craftable_name, "fueltanks", "veh_t6_dlc_zombie_part_fuel", 32, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_feul_tanks", undefined, 2 );
	plane_engine = generate_zombie_craftable_piece( craftable_name, "engine", "veh_t6_dlc_zombie_part_engine", 32, 62, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_origin", undefined, 3 );
	plane_steering = generate_zombie_craftable_piece( craftable_name, "steering", "veh_t6_dlc_zombie_part_control", 32, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_control_mechanism", undefined, 4 );
	plane_rigging = generate_zombie_craftable_piece( craftable_name, "rigging", "veh_t6_dlc_zombie_part_rigging", 32, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_origin", undefined, 5 );
	if ( level.is_forever_solo_game )
	{
		plane_cloth.is_shared = 1;
		plane_fueltanks.is_shared = 1;
		plane_engine.is_shared = 1;
		plane_steering.is_shared = 1;
		plane_rigging.is_shared = 1;
		plane_cloth.client_field_state = undefined;
		plane_fueltanks.client_field_state = undefined;
		plane_engine.client_field_state = undefined;
		plane_steering.client_field_state = undefined;
		plane_rigging.client_field_state = undefined;
	}
	plane_cloth.pickup_alias = "sidequest_sheets";
	plane_fueltanks.pickup_alias = "sidequest_oxygen";
	plane_engine.pickup_alias = "sidequest_engine";
	plane_steering.pickup_alias = "sidequest_valves";
	plane_rigging.pickup_alias = "sidequest_rigging";
	plane = spawnstruct();
	plane.name = craftable_name;
	plane add_craftable_piece( plane_cloth );
	plane add_craftable_piece( plane_engine );
	plane add_craftable_piece( plane_fueltanks );
	plane add_craftable_piece( plane_steering );
	plane add_craftable_piece( plane_rigging );
	plane.triggerthink = ::planecraftable;
	plane.custom_craftablestub_update_prompt = ::prison_plane_update_prompt;
	include_craftable( plane );
	craftable_name = "refuelable_plane";
	refuelable_plane_gas1 = generate_zombie_craftable_piece( craftable_name, "fuel1", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 6 );
	refuelable_plane_gas2 = generate_zombie_craftable_piece( craftable_name, "fuel2", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 7 );
	refuelable_plane_gas3 = generate_zombie_craftable_piece( craftable_name, "fuel3", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 8 );
	refuelable_plane_gas4 = generate_zombie_craftable_piece( craftable_name, "fuel4", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 9 );
	refuelable_plane_gas5 = generate_zombie_craftable_piece( craftable_name, "fuel5", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 10 );
	if ( level.is_forever_solo_game )
	{
		refuelable_plane_gas1.is_shared = 1;
		refuelable_plane_gas2.is_shared = 1;
		refuelable_plane_gas3.is_shared = 1;
		refuelable_plane_gas4.is_shared = 1;
		refuelable_plane_gas5.is_shared = 1;
		refuelable_plane_gas1.client_field_state = undefined;
		refuelable_plane_gas2.client_field_state = undefined;
		refuelable_plane_gas3.client_field_state = undefined;
		refuelable_plane_gas4.client_field_state = undefined;
		refuelable_plane_gas5.client_field_state = undefined;
	}
	refuelable_plane = spawnstruct();
	refuelable_plane.name = craftable_name;
	refuelable_plane add_craftable_piece( refuelable_plane_gas1 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas2 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas3 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas4 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas5 );
	refuelable_plane.triggerthink = ::planefuelable;
	plane.custom_craftablestub_update_prompt = ::prison_plane_update_prompt;
	include_craftable( refuelable_plane );
}

register_clientfields()
{
	bits = 1;
	registerclientfield( "world", "piece_riotshield_dolly", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_riotshield_door", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_riotshield_clamp", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_packasplat_fuse", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_packasplat_case", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_packasplat_blood", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_key_warden", 9000, bits, "int", undefined, 0 );
	bits = getminbitcountfornum( 10 );
	registerclientfield( "world", "piece_player1", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_player2", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_player3", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "piece_player4", 9000, bits, "int", undefined, 0 );
	bits = getminbitcountfornum( 7 );
	registerclientfield( "world", "quest_state1", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "quest_state2", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "quest_state3", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "quest_state4", 9000, bits, "int", undefined, 0 );
	registerclientfield( "world", "quest_state5", 9000, bits, "int", undefined, 0 );
	bits = 1;
	registerclientfield( "world", "quest_plane_craft_complete", 9000, bits, "int", undefined, 0 );
}

riotshieldcraftable()
{
	maps/mp/zombies/_zm_craftables::craftable_trigger_think( "riotshield_zm_craftable_trigger", "alcatraz_shield_zm", "alcatraz_shield_zm", &"ZOMBIE_GRAB_RIOTSHIELD", 1, 1 );
}

packasplatcraftable()
{
	maps/mp/zombies/_zm_craftables::craftable_trigger_think( "packasplat_craftable_trigger", "packasplat", "packasplat", undefined, 1, 0 );
}

planecraftable()
{
	level thread alcatraz_craftable_trigger_think( "plane_craftable_trigger", "plane", "plane", "", 1, 0 );
	level setclientfield( "quest_plane_craft_complete", 0 );
	i = 1;
	while ( i <= 5 )
	{
		level setclientfield( "quest_state" + i, 2 );
		i++;
	}
}

planefuelable()
{
	level thread planefuelable_think();
}

planefuelable_think()
{
	flag_wait( "spawn_fuel_tanks" );
	t_plane_fuelable = getent( "plane_fuelable_trigger", "targetname" );
	t_plane_fuelable trigger_on();
	i = 1;
	while ( i <= 5 )
	{
		level setclientfield( "quest_state" + i, 5 );
		i++;
	}
	alcatraz_craftable_trigger_think( "plane_fuelable_trigger", "refuelable_plane", "refuelable_plane", "", 1, 0 );
}

ondrop_common( player )
{
/#
	println( "ZM >> Common part callback onDrop()" );
#/
	self droponmover( player );
	self.piece_owner = undefined;
}

onpickup_common( player )
{
/#
	println( "ZM >> Common part callback onPickup()" );
#/
	player playsound( "zmb_craftable_pickup" );
	self pickupfrommover();
	self.piece_owner = player;
}

ondisconnect_common( player )
{
	level endon( "crafted_" + self.piecename );
	level endon( "dropped_" + self.piecename );
	player_num = player getentitynumber() + 1;
	player waittill( "disconnect" );
	switch( self.piecename )
	{
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_dropped( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_dropped( "fueltank" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_dropped( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_dropped( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_dropped( "rigging" );
			break;
	}
	level setclientfield( field_name, 2 );
	level setclientfield( "piece_player" + player_num, 0 );
	m_plane_piece = get_craftable_piece_model( "plane", self.piecename );
	if ( isDefined( m_plane_piece ) )
	{
		playfxontag( level._effect[ "quest_item_glow" ], m_plane_piece, "tag_origin" );
	}
	m_fuel_can = get_craftable_piece_model( "refuelable_plane", self.piecename );
	if ( isDefined( m_fuel_can ) )
	{
		playfxontag( level._effect[ "quest_item_glow" ], m_fuel_can, "tag_origin" );
	}
}

prison_open_craftablestub_update_prompt( player, b_set_hint_string_now, trigger )
{
	valid = maps/mp/zombies/_zm_craftables::open_craftablestub_update_prompt( player );
	return valid;
}

onpickup_key( player )
{
	flag_set( "key_found" );
	if ( level.is_master_key_west )
	{
		level clientnotify( "fxanim_west_pulley_up_start" );
	}
	else
	{
		level clientnotify( "fxanim_east_pulley_up_start" );
	}
	a_m_checklist = getentarray( "plane_checklist", "targetname" );
	_a429 = a_m_checklist;
	_k429 = getFirstArrayKey( _a429 );
	while ( isDefined( _k429 ) )
	{
		m_checklist = _a429[ _k429 ];
		m_checklist showpart( "j_check_key" );
		m_checklist showpart( "j_strike_key" );
		_k429 = getNextArrayKey( _a429, _k429 );
	}
	a_door_structs = getstructarray( "quest_trigger", "script_noteworthy" );
	_a437 = a_door_structs;
	_k437 = getFirstArrayKey( _a437 );
	while ( isDefined( _k437 ) )
	{
		struct = _a437[ _k437 ];
		if ( isDefined( struct.unitrigger_stub ) )
		{
			struct.unitrigger_stub maps/mp/zombies/_zm_unitrigger::run_visibility_function_for_all_triggers();
		}
		_k437 = getNextArrayKey( _a437, _k437 );
	}
	player playsound( "evt_key_pickup" );
	player thread do_player_general_vox( "quest", "sidequest_key_response", undefined, 100 );
	level setclientfield( "piece_key_warden", 1 );
}

prison_plane_update_prompt( player, b_set_hint_string_now, trigger )
{
	return 1;
}

ondrop_plane( player )
{
/#
	println( "ZM >> Common part callback onDrop()" );
#/
	level notify( "dropped_" + self.piecename );
	level.plane_pieces_picked_up -= 1;
	self droponmover( player );
	self.piece_owner = undefined;
	playfxontag( level._effect[ "quest_item_glow" ], self.model, "tag_origin" );
	switch( self.piecename )
	{
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_dropped( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_dropped( "fueltank" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_dropped( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_dropped( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_dropped( "rigging" );
			break;
	}
	level setclientfield( field_name, 2 );
	if ( !level.is_forever_solo_game )
	{
		player_num = player getentitynumber() + 1;
		level setclientfield( "piece_player" + player_num, 0 );
	}
}

onpickup_plane( player )
{
/#
	println( "ZM >> Common part callback onPickup()" );
#/
	if ( !isDefined( level.plane_pieces_picked_up ) )
	{
		level.plane_pieces_picked_up = 0;
		level.sndplanepieces = 1;
	}
	level.plane_pieces_picked_up += 1;
	if ( level.plane_pieces_picked_up == 5 )
	{
		level thread roof_nag_vo();
	}
	if ( level.sndplanepieces == level.plane_pieces_picked_up )
	{
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "piece_" + level.sndplanepieces );
		level.sndplanepieces++;
	}
	player playsound( "zmb_craftable_pickup" );
	vo_alias_call = undefined;
	vo_alias_response = undefined;
	self pickupfrommover();
	self.piece_owner = player;
	switch( self.piecename )
	{
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_picked_up( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_picked_up( "fueltank" );
			flag_set( "docks_gates_remain_open" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_picked_up( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_picked_up( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_picked_up( "rigging" );
			break;
	}
	level setclientfield( field_name, 3 );
	if ( !level.is_forever_solo_game )
	{
		player_num = player getentitynumber() + 1;
		level setclientfield( "piece_player" + player_num, self.client_field_state );
	}
	vo_alias_call = self check_if_newly_found();
	if ( isDefined( vo_alias_call ) )
	{
		level thread play_plane_piece_call_and_response_vo( player, vo_alias_call );
	}
	self thread ondisconnect_common( player );
}

check_if_newly_found()
{
	if ( !flag( self.piecename + "_found" ) )
	{
		switch( self.piecename )
		{
			case "fueltanks":
				vo_alias_call = "sidequest_oxygen";
				break;
			case "cloth":
				vo_alias_call = "sidequest_sheets";
				break;
			case "engine":
				vo_alias_call = "sidequest_engine";
				break;
			case "steering":
				vo_alias_call = "sidequest_valves";
				break;
			case "rigging":
				vo_alias_call = "sidequest_rigging";
				break;
		}
		level.n_plane_pieces_found++;
		flag_set( self.piecename + "_found" );
		if ( self.piecename == "cloth" )
		{
			level clientnotify( "fxanim_dryer_hide_start" );
		}
		return vo_alias_call;
	}
}

play_plane_piece_call_and_response_vo( player, vo_alias_call )
{
	player endon( "death" );
	player endon( "disconnect" );
	n_response_range = 1500;
	players = getplayers();
	if ( !flag( "story_vo_playing" ) )
	{
		flag_set( "story_vo_playing" );
		player do_player_general_vox( "quest", vo_alias_call, undefined, 100 );
		wait 5;
		if ( players.size > 1 )
		{
			arrayremovevalue( players, player );
			closest_other_player = getclosest( player.origin, players );
			if ( isDefined( closest_other_player ) )
			{
				n_dist = distance( player.origin, closest_other_player.origin );
				if ( isDefined( closest_other_player ) && n_dist < n_response_range )
				{
					if ( level.n_plane_pieces_found < 5 )
					{
						vo_alias_response = "sidequest_parts" + level.n_plane_pieces_found + "_prog";
					}
					else
					{
						vo_alias_response = "sidequest_all_parts";
					}
					closest_other_player do_player_general_vox( "quest", vo_alias_response, undefined, 100 );
				}
			}
		}
		flag_clear( "story_vo_playing" );
	}
}

roof_nag_vo()
{
	level notify( "roof_nag_vo" );
	level endon( "roof_nag_vo" );
	zone_roof = getent( "zone_roof", "targetname" );
	zone_roof_infirmary = getent( "zone_roof_infirmary", "targetname" );
	n_roof_nag_wait = 60;
	n_roof_nag_max_times = 3;
	while ( !flag( "plane_built" ) && n_roof_nag_max_times > 0 )
	{
		wait n_roof_nag_wait;
		b_is_a_player_on_the_roof = 0;
		players = getplayers();
		_a696 = players;
		_k696 = getFirstArrayKey( _a696 );
		while ( isDefined( _k696 ) )
		{
			player = _a696[ _k696 ];
			if ( player istouching( zone_roof ) || player istouching( zone_roof_infirmary ) )
			{
				b_is_a_player_on_the_roof = 1;
			}
			_k696 = getNextArrayKey( _a696, _k696 );
		}
		if ( !b_is_a_player_on_the_roof )
		{
			if ( level.plane_pieces_picked_up == 5 )
			{
				player = players[ randomintrange( 0, players.size ) ];
				if ( isDefined( player ) )
				{
					player do_player_general_vox( "quest", "sidequest_roof_nag", undefined, 100 );
					n_roof_nag_wait *= 1,5;
					n_roof_nag_max_times--;

				}
			}
		}
	}
}

oncrafted_plane( player )
{
	level notify( "crafted_" + self.piecename );
	m_plane_hideable_engine = getent( "plane_hideable_engine", "targetname" );
	m_plane_hideable_clothes_pile = getent( "plane_hideable_clothes_pile", "targetname" );
	m_plane_hideable_engine ghost();
	m_plane_hideable_clothes_pile ghost();
	plane_craftable = getent( "plane_craftable", "targetname" );
	plane_craftable hidepart( "tag_support_upper" );
	plane_craftable hidepart( "tag_wings_down" );
	plane_craftable hidepart( "tag_wing_skins_down" );
	plane_craftable hidepart( "tag_wing_skins_up" );
	plane_craftable hidepart( "tag_engines_down" );
	plane_craftable hidepart( "tag_engines_up" );
	plane_craftable hidepart( "tag_engines_down" );
	plane_craftable hidepart( "tag_engines_up" );
	plane_craftable hidepart( "tag_engine_ground" );
	plane_craftable hidepart( "tag_clothes_ground" );
	plane_craftable hidepart( "tag_fuel_hose" );
	if ( !isDefined( level.sndplanecrafted ) )
	{
		level.sndplanecrafted = 0;
	}
	level.sndplanecrafted++;
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "plane_crafted_" + level.sndplanecrafted );
	if ( is_part_crafted( "plane", "rigging" ) )
	{
		plane_craftable showpart( "tag_support_upper" );
		if ( is_part_crafted( "plane", "cloth" ) )
		{
			plane_craftable showpart( "tag_wing_skins_up" );
		}
		if ( is_part_crafted( "plane", "engine" ) )
		{
			plane_craftable showpart( "tag_engines_up" );
		}
	}
	else
	{
		plane_craftable showpart( "tag_wings_down" );
		if ( is_part_crafted( "plane", "cloth" ) )
		{
			m_plane_hideable_clothes_pile show();
		}
		if ( is_part_crafted( "plane", "engine" ) )
		{
			m_plane_hideable_engine show();
		}
	}
	if ( is_part_crafted( "plane", "steering" ) && is_part_crafted( "plane", "fueltanks" ) )
	{
		plane_craftable showpart( "tag_fuel_hose" );
	}
	switch( self.piecename )
	{
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_crafted( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_crafted( "fueltank" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_crafted( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_crafted( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_crafted( "rigging" );
			break;
	}
	level setclientfield( field_name, 4 );
	if ( !level.is_forever_solo_game )
	{
		player_num = player getentitynumber() + 1;
		level setclientfield( "piece_player" + player_num, 0 );
	}
}

ondrop_fuel( player )
{
	level notify( "dropped_" + self.piecename );
	self.piece_owner = undefined;
	playfxontag( level._effect[ "quest_item_glow" ], self.model, "tag_origin" );
	if ( isDefined( level.sndfuelpieces ) )
	{
		level.sndfuelpieces--;

	}
	switch( self.piecename )
	{
		case "fuel1":
			field_name = "quest_state1";
			break;
		case "fuel2":
			field_name = "quest_state2";
			break;
		case "fuel3":
			field_name = "quest_state3";
			break;
		case "fuel4":
			field_name = "quest_state4";
			break;
		case "fuel5":
			field_name = "quest_state5";
			break;
	}
	level setclientfield( field_name, 5 );
	if ( !level.is_forever_solo_game )
	{
		player_num = player getentitynumber() + 1;
		level setclientfield( "piece_player" + player_num, 0 );
	}
}

onpickup_fuel( player )
{
	player playsound( "zmb_craftable_pickup" );
	if ( !isDefined( level.sndfuelpieces ) || level.sndfuelpieces >= 5 )
	{
		level.sndfuelpieces = 0;
	}
	level.sndfuelpieces++;
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "gas_" + level.sndfuelpieces );
	self pickupfrommover();
	self.piece_owner = player;
	if ( isDefined( player ) )
	{
		player do_player_general_vox( "quest", "fuel_pickup", undefined, 100 );
	}
	switch( self.piecename )
	{
		case "fuel1":
			field_name = "quest_state1";
			break;
		case "fuel2":
			field_name = "quest_state2";
			break;
		case "fuel3":
			field_name = "quest_state3";
			break;
		case "fuel4":
			field_name = "quest_state4";
			break;
		case "fuel5":
			field_name = "quest_state5";
			break;
	}
	level setclientfield( field_name, 6 );
	if ( !level.is_forever_solo_game )
	{
		player_num = player getentitynumber() + 1;
		level setclientfield( "piece_player" + player_num, self.client_field_state );
	}
	self thread ondisconnect_common( player );
}

oncrafted_fuel( player )
{
	level notify( "crafted_" + self.piecename );
	level.n_plane_fuel_count++;
	switch( self.piecename )
	{
		case "fuel1":
			field_name = "quest_state1";
			break;
		case "fuel2":
			field_name = "quest_state2";
			break;
		case "fuel3":
			field_name = "quest_state3";
			break;
		case "fuel4":
			field_name = "quest_state4";
			break;
		case "fuel5":
			field_name = "quest_state5";
			break;
	}
	level setclientfield( field_name, 7 );
	if ( !level.is_forever_solo_game )
	{
		player_num = player getentitynumber() + 1;
		level setclientfield( "piece_player" + player_num, 0 );
	}
}

onfullycrafted_plane( player )
{
	flag_set( "plane_built" );
	level thread maps/mp/zm_alcatraz_sq_vo::escape_flight_vo();
	level notify( "roof_nag_vo" );
	level setclientfield( "quest_plane_craft_complete", 1 );
	return 0;
}

onfullycrafted_packasplat( player )
{
	t_upgrade = getent( "blundergat_upgrade", "targetname" );
	t_upgrade.target = self.target;
	t_upgrade.origin = self.origin;
	t_upgrade.angles = self.angles;
	t_upgrade.m_upgrade_machine = get_craftable_model( "packasplat" );
	return 1;
}

onfullycrafted_refueled( player )
{
	flag_set( "plane_built" );
	level thread maps/mp/zm_alcatraz_sq_vo::escape_flight_vo();
	level notify( "roof_nag_vo" );
	thread onfullycrafted_refueled_think( player );
	return 0;
}

onfullycrafted_refueled_think( player )
{
	flag_wait( "spawn_fuel_tanks" );
	i = 1;
	while ( i <= 5 )
	{
		level setclientfield( "quest_state" + i, 5 );
		i++;
	}
	maps/mp/zombies/_zm_craftables::stub_uncraft_craftable( self, 1, undefined, undefined, 1 );
}

sqcommoncraftable()
{
	level.sq_craftable = maps/mp/zombies/_zm_craftables::craftable_trigger_think( "sq_common_craftable_trigger", "sq_common", "sq_common", "", 1, 0 );
}

onbuyweapon_riotshield( player )
{
	if ( isDefined( player.player_shield_reset_health ) )
	{
		player [[ player.player_shield_reset_health ]]();
	}
	if ( isDefined( player.player_shield_reset_location ) )
	{
		player [[ player.player_shield_reset_location ]]();
	}
}

onbuyweapon_plane( player )
{
	level notify( "plane_takeoff" );
	iprintlnbold( "Plane Bought" );
}

droponmover( player )
{
	while ( isDefined( player ) && player maps/mp/zm_alcatraz_travel::is_player_on_gondola() )
	{
		str_location = undefined;
		if ( isDefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving && isDefined( level.e_gondola.destination ) )
		{
			str_location = level.e_gondola.destination;
		}
		else
		{
			str_location = level.e_gondola.location;
		}
		if ( !isDefined( str_location ) )
		{
			str_location = "roof";
		}
		a_s_part_teleport = getstructarray( "gondola_dropped_parts_" + str_location, "targetname" );
		_a1104 = a_s_part_teleport;
		_k1104 = getFirstArrayKey( _a1104 );
		while ( isDefined( _k1104 ) )
		{
			struct = _a1104[ _k1104 ];
			if ( isDefined( struct.occupied ) && !struct.occupied )
			{
				self.model.origin = struct.origin;
				self.model.angles = struct.angles;
				struct.occupied = 1;
				self.unitrigger.struct_teleport = struct;
				return;
			}
			else
			{
				_k1104 = getNextArrayKey( _a1104, _k1104 );
			}
		}
	}
}

pickupfrommover()
{
	if ( isDefined( self.unitrigger ) )
	{
		if ( isDefined( self.unitrigger.struct_teleport ) )
		{
			self.unitrigger.struct_teleport.occupied = 0;
			self.unitrigger.struct_teleport = undefined;
		}
	}
}

in_game_checklist_setup()
{
	a_m_checklist = getentarray( "plane_checklist", "targetname" );
	a_str_partnames = [];
	a_str_partnames[ 0 ] = "sheets";
	a_str_partnames[ 1 ] = "fueltank";
	a_str_partnames[ 2 ] = "engine";
	a_str_partnames[ 3 ] = "contval";
	a_str_partnames[ 4 ] = "rigging";
	a_str_partnames[ 5 ] = "key";
	_a1143 = a_m_checklist;
	_k1143 = getFirstArrayKey( _a1143 );
	while ( isDefined( _k1143 ) )
	{
		m_checklist = _a1143[ _k1143 ];
		_a1145 = a_str_partnames;
		_k1145 = getFirstArrayKey( _a1145 );
		while ( isDefined( _k1145 ) )
		{
			str_partname = _a1145[ _k1145 ];
			m_checklist hidepart( "j_check_" + str_partname );
			m_checklist hidepart( "j_strike_" + str_partname );
			_k1145 = getNextArrayKey( _a1145, _k1145 );
		}
		_k1143 = getNextArrayKey( _a1143, _k1143 );
	}
}

in_game_checklist_plane_piece_picked_up( str_partname )
{
	a_m_checklist = getentarray( "plane_checklist", "targetname" );
	_a1157 = a_m_checklist;
	_k1157 = getFirstArrayKey( _a1157 );
	while ( isDefined( _k1157 ) )
	{
		m_checklist = _a1157[ _k1157 ];
		m_checklist showpart( "j_check_" + str_partname );
		_k1157 = getNextArrayKey( _a1157, _k1157 );
	}
}

in_game_checklist_plane_piece_dropped( str_partname )
{
	a_m_checklist = getentarray( "plane_checklist", "targetname" );
	_a1167 = a_m_checklist;
	_k1167 = getFirstArrayKey( _a1167 );
	while ( isDefined( _k1167 ) )
	{
		m_checklist = _a1167[ _k1167 ];
		m_checklist hidepart( "j_check_" + str_partname );
		_k1167 = getNextArrayKey( _a1167, _k1167 );
	}
}

in_game_checklist_plane_piece_crafted( str_partname )
{
	a_m_checklist = getentarray( "plane_checklist", "targetname" );
	_a1177 = a_m_checklist;
	_k1177 = getFirstArrayKey( _a1177 );
	while ( isDefined( _k1177 ) )
	{
		m_checklist = _a1177[ _k1177 ];
		m_checklist showpart( "j_strike_" + str_partname );
		_k1177 = getNextArrayKey( _a1177, _k1177 );
	}
}

alcatraz_craftable_trigger_think( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	return alcatraz_setup_unitrigger_craftable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

alcatraz_setup_unitrigger_craftable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	trig = getent( trigger_targetname, "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	trig.script_length = 386;
	return alcatraz_setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

alcatraz_setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	if ( !isDefined( trig ) )
	{
		return;
	}
	unitrigger_stub = spawnstruct();
	unitrigger_stub.craftablestub = level.zombie_include_craftables[ equipname ];
	angles = trig.script_angles;
	if ( !isDefined( angles ) )
	{
		angles = ( 0, 0, 0 );
	}
	unitrigger_stub.origin = trig.origin + ( anglesToRight( angles ) * -6 );
	unitrigger_stub.angles = trig.angles;
	if ( isDefined( trig.script_angles ) )
	{
		unitrigger_stub.angles = trig.script_angles;
	}
	unitrigger_stub.equipname = equipname;
	unitrigger_stub.weaponname = weaponname;
	unitrigger_stub.trigger_hintstring = trigger_hintstring;
	unitrigger_stub.delete_trigger = delete_trigger;
	unitrigger_stub.crafted = 0;
	unitrigger_stub.persistent = persistent;
	unitrigger_stub.usetime = int( 3000 );
	unitrigger_stub.onbeginuse = ::onbeginuseuts;
	unitrigger_stub.onenduse = ::onenduseuts;
	unitrigger_stub.onuse = ::onuseplantobjectuts;
	unitrigger_stub.oncantuse = ::oncantuseuts;
	if ( isDefined( trig.script_length ) )
	{
		unitrigger_stub.script_length = trig.script_length;
	}
	else
	{
		unitrigger_stub.script_length = 32;
	}
	if ( isDefined( trig.script_width ) )
	{
		unitrigger_stub.script_width = trig.script_width;
	}
	else
	{
		unitrigger_stub.script_width = 100;
	}
	if ( isDefined( trig.script_height ) )
	{
		unitrigger_stub.script_height = trig.script_height;
	}
	else
	{
		unitrigger_stub.script_height = 64;
	}
	unitrigger_stub.target = trig.target;
	unitrigger_stub.targetname = trig.targetname;
	unitrigger_stub.script_noteworthy = trig.script_noteworthy;
	unitrigger_stub.script_parameters = trig.script_parameters;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( isDefined( level.zombie_craftablestubs[ equipname ].hint ) )
	{
		unitrigger_stub.hint_string = level.zombie_craftablestubs[ equipname ].hint;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 0;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( isDefined( unitrigger_stub.craftablestub.custom_craftablestub_update_prompt ) )
	{
		unitrigger_stub.custom_craftablestub_update_prompt = unitrigger_stub.craftablestub.custom_craftablestub_update_prompt;
	}
	unitrigger_stub.prompt_and_visibility_func = ::craftabletrigger_update_prompt;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::craftable_place_think );
	unitrigger_stub.piece_trigger = trig;
	trig.trigger_stub = unitrigger_stub;
	unitrigger_stub.zombie_weapon_upgrade = trig.zombie_weapon_upgrade;
	if ( isDefined( unitrigger_stub.target ) )
	{
		unitrigger_stub.model = getent( unitrigger_stub.target, "targetname" );
		if ( isDefined( unitrigger_stub.model ) )
		{
			if ( isDefined( unitrigger_stub.zombie_weapon_upgrade ) )
			{
				unitrigger_stub.model useweaponhidetags( unitrigger_stub.zombie_weapon_upgrade );
			}
			unitrigger_stub.model ghost();
			unitrigger_stub.model notsolid();
		}
	}
	unitrigger_stub.craftablespawn = unitrigger_stub craftable_piece_unitriggers( equipname, unitrigger_stub.origin );
	if ( delete_trigger )
	{
		trig delete();
	}
	level.a_uts_craftables[ level.a_uts_craftables.size ] = unitrigger_stub;
	return unitrigger_stub;
}
