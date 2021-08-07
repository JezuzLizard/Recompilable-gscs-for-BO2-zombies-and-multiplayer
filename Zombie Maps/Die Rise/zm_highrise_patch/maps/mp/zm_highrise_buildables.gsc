#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_highrise_elevators;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_buildables()
{
	level.buildable_piece_count = 13;
	add_zombie_buildable( "springpad_zm", &"ZM_HIGHRISE_BUILD_SPRINGPAD", &"ZM_HIGHRISE_BUILDING_SPRINGPAD", &"ZM_HIGHRISE_BOUGHT_SPRINGPAD" );
	add_zombie_buildable( "slipgun_zm", &"ZM_HIGHRISE_BUILD_SLIPGUN", &"ZM_HIGHRISE_BUILDING_SLIPGUN", &"ZM_HIGHRISE_BOUGHT_SLIPGUN" );
	add_zombie_buildable( "keys_zm", &"ZM_HIGHRISE_BUILD_KEYS", &"ZM_HIGHRISE_BUILDING_KEYS", &"ZM_HIGHRISE_BOUGHT_KEYS" );
	add_zombie_buildable( "ekeys_zm", &"ZM_HIGHRISE_BUILD_KEYS", &"ZM_HIGHRISE_BUILDING_KEYS", &"ZM_HIGHRISE_BOUGHT_KEYS" );
	add_zombie_buildable( "sq_common", &"ZOMBIE_BUILD_SQ_COMMON", &"ZOMBIE_BUILDING_SQ_COMMON" );
}

include_buildables()
{
	springpad_door = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_door", 32, 64, 0, "zom_hud_trample_steam_screen", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_02", undefined, 1 );
	springpad_flag = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_bellows", 48, 15, 0, "zom_hud_trample_steam_bellow", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_04", undefined, 2 );
	springpad_motor = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_compressor", 48, 15, 0, "zom_hud_trample_steam_compressor", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_01", undefined, 3 );
	springpad_whistle = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_flag", 48, 15, 0, "zom_hud_trample_steam_whistle", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_03", undefined, 4 );
	springpad = spawnstruct();
	springpad.name = "springpad_zm";
	springpad add_buildable_piece( springpad_door );
	springpad add_buildable_piece( springpad_flag );
	springpad add_buildable_piece( springpad_motor );
	springpad add_buildable_piece( springpad_whistle );
	springpad.triggerthink = ::springpadbuildable;
	include_buildable( springpad );
	slipgun_canister = generate_zombie_buildable_piece( "slipgun_zm", "t6_zmb_buildable_slipgun_extinguisher", 32, 64, 0, "zom_hud_icon_buildable_slip_ext", ::onpickup_common, ::ondrop_common, undefined, "TAG_CO2", undefined, 5 );
	slipgun_cooker = generate_zombie_buildable_piece( "slipgun_zm", "t6_zmb_buildable_slipgun_cooker", 48, 15, 0, "zom_hud_icon_buildable_slip_cooker", ::onpickup_common, ::ondrop_common, undefined, "TAG_COOKER", undefined, 6 );
	slipgun_foot = generate_zombie_buildable_piece( "slipgun_zm", "t6_zmb_buildable_slipgun_foot", 48, 15, 0, "zom_hud_icon_buildable_slip_foot", ::onpickup_common, ::ondrop_common, undefined, "TAG_FOOT", undefined, 7 );
	slipgun_throttle = generate_zombie_buildable_piece( "slipgun_zm", "t6_zmb_buildable_slipgun_throttle", 48, 15, 0, "zom_hud_icon_buildable_slip_handle", ::onpickup_common, ::ondrop_common, undefined, "TAG_THROTTLE", undefined, 8 );
	slipgun = spawnstruct();
	slipgun.name = "slipgun_zm";
	slipgun add_buildable_piece( slipgun_canister );
	slipgun add_buildable_piece( slipgun_cooker );
	slipgun add_buildable_piece( slipgun_foot );
	slipgun add_buildable_piece( slipgun_throttle );
	slipgun.onbuyweapon = ::onbuyweapon_slipgun;
	slipgun.triggerthink = ::slipgunbuildable;
	slipgun.onuseplantobject = ::onuseplantobject_slipgun;
	include_buildable( slipgun );
	key_chain = generate_zombie_buildable_piece( "keys_zm", "P6_zm_hr_key", 32, 64, 2,4, "zom_hud_icon_epod_key", ::onpickup_keys, ::ondrop_keys, undefined, undefined, 0, 9 );
	key_chain.onspawn = ::onspawn_keys;
	key_chain manage_multiple_pieces( 4 );
	key = spawnstruct();
	key.name = "keys_zm";
	key add_buildable_piece( key_chain );
	key.triggerthink = ::keysbuildable;
	key.onuseplantobject = ::onuseplantobject_escapepodkey;
	key.buildablepieces[ 0 ].onspawn = ::onspawn_keys;
	include_buildable( key );
	ekey = spawnstruct();
	ekey.name = "ekeys_zm";
	ekey add_buildable_piece( key_chain );
	ekey.triggerthink = ::ekeysbuildable;
	ekey.onuseplantobject = ::onuseplantobject_elevatorkey;
	ekey.buildablepieces[ 0 ].onspawn = ::onspawn_keys;
	include_buildable( ekey );
	if ( !isDefined( level.gamedifficulty ) || level.gamedifficulty != 0 )
	{
		sq_common_electricbox = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_electric_box", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "tag_part_02", undefined, 10 );
		sq_common_meteor = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_meteor", 128, 64, 0, "zm_hud_icon_sq_meteor", ::onpickup_common, ::ondrop_common, undefined, "tag_part_04", undefined, 11 );
		sq_common_scaffolding = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_scaffolding", 64, 96, 0, "zm_hud_icon_sq_scafold", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 12 );
		sq_common_transceiver = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_transceiver", 64, 96, 0, "zm_hud_icon_sq_tranceiver", ::onpickup_common, ::ondrop_common, undefined, "tag_part_03", undefined, 13 );
		sqcommon = spawnstruct();
		sqcommon.name = "sq_common";
		sqcommon add_buildable_piece( sq_common_electricbox );
		sqcommon add_buildable_piece( sq_common_meteor );
		sqcommon add_buildable_piece( sq_common_scaffolding );
		sqcommon add_buildable_piece( sq_common_transceiver );
		sqcommon.triggerthink = ::sqcommonbuildable;
		include_buildable( sqcommon );
		maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "sq_common_buildable_trigger" );
	}
}

springpadbuildable()
{
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "springpad_zm_buildable_trigger", "springpad_zm", "equip_springpad_zm", &"ZM_HIGHRISE_GRAB_SPRINGPAD", 1, 1 );
}

slipgunbuildable()
{
	level thread wait_for_slipgun();
	if ( isDefined( level.slipgun_as_equipment ) && !level.slipgun_as_equipment )
	{
		persist = 2;
	}
	else
	{
		persist = 1;
	}
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "slipgun_zm_buildable_trigger", "slipgun_zm", "slipgun_zm", &"ZM_HIGHRISE_GRAB_SLIPGUN", 1, persist );
}

keysbuildable()
{
	pod_key = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "escape_pod_key_console_trigger", "keys_zm", "keys_zm", "", 1, 3 );
	pod_key.prompt_and_visibility_func = ::escape_pod_key_prompt;
}

ekeysbuildable()
{
	elevator_keys = maps/mp/zombies/_zm_buildables::buildable_trigger_think_array( "elevator_key_console_trigger", "ekeys_zm", "keys_zm", "", 1, 3 );
	_a143 = elevator_keys;
	_k143 = getFirstArrayKey( _a143 );
	while ( isDefined( _k143 ) )
	{
		stub = _a143[ _k143 ];
		stub.prompt_and_visibility_func = ::elevator_key_prompt;
		stub.buildablezone.stat_name = "keys_zm";
		_k143 = getNextArrayKey( _a143, _k143 );
	}
}

ondrop_common( player )
{
/#
	println( "ZM >> Common part callback onDrop()" );
#/
	self droponelevator( player );
	self.piece_owner = undefined;
}

onpickup_common( player )
{
/#
	println( "ZM >> Common part callback onPickup()" );
#/
	player playsound( "zmb_buildable_pickup" );
	self pickupfromelevator();
	self.piece_owner = player;
}

sqcommonbuildable()
{
	level.sq_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "sq_common_buildable_trigger", "sq_common", "sq_common", "", 1, 0 );
}

onbuyweapon_slipgun( player )
{
	player givestartammo( self.stub.weaponname );
	player switchtoweapon( self.stub.weaponname );
	level notify( "slipgun_bought" );
}

wait_for_slipgun()
{
	level.zombie_include_weapons[ "slipgun_zm" ] = 0;
	if ( isDefined( level.slipgun_as_equipment ) && !level.slipgun_as_equipment )
	{
		level waittill( "slipgun_bought", player );
		level.zombie_include_weapons[ "slipgun_zm" ] = 1;
		level.zombie_weapons[ "slipgun_zm" ].is_in_box = 1;
	}
}

keyscreateglint()
{
	if ( !isDefined( self.model.glint_fx ) )
	{
		playfxontag( level._effect[ "elevator_glint" ], self.model, "tag_origin" );
	}
}

onspawn_keys()
{
	self keyscreateglint();
}

ondrop_keys( player )
{
	self keyscreateglint();
}

onpickup_keys( player )
{
}

escape_pod_key_prompt( player )
{
	if ( !flag( "escape_pod_needs_reset" ) )
	{
		self.stub.hint_string = "";
		self sethintstring( self.stub.hint_string );
		return 0;
	}
	return self buildabletrigger_update_prompt( player );
}

onuseplantobject_escapepodkey( player )
{
	level notify( "reset_escape_pod" );
}

watch_elevator_prompt( player, trig )
{
	player notify( "watch_elevator_prompt" );
	player endon( "watch_elevator_prompt" );
	trig endon( "kill_trigger" );
	while ( 1 )
	{
		trig.stub.elevator waittill( "floor_changed" );
		if ( isDefined( self.stub.elevator ) )
		{
			if ( trig.stub.elevator maps/mp/zm_highrise_elevators::elevator_is_on_floor( trig.stub.floor ) )
			{
				thread maps/mp/zombies/_zm_unitrigger::cleanup_trigger( trig, player );
				return;
			}
		}
	}
}

elevator_key_prompt( player )
{
	if ( !isDefined( self.stub.elevator ) )
	{
		elevatorname = self.stub.script_noteworthy;
		if ( isDefined( elevatorname ) && isDefined( self.stub.script_parameters ) )
		{
			elevator = level.elevators[ elevatorname ];
			floor = int( self.stub.script_parameters );
			flevel = elevator maps/mp/zm_highrise_elevators::elevator_level_for_floor( floor );
			self.stub.elevator = elevator;
			self.stub.floor = flevel;
		}
	}
/#
	if ( !isDefined( self.stub.elevator ) )
	{
		if ( isDefined( self.stub.script_noteworthy ) )
		{
			error( "Cannot locate elevator " + self.stub.script_noteworthy );
		}
		else
		{
			error( "Cannot locate elevator " );
		}
	}
	else
	{
		color = vectorScale( ( 0, 0, 1 ), 0,7 );
		stop = self.stub.floor;
		floor = self.stub.elevator.floors[ "" + stop ].script_location;
		text = "call " + self.stub.script_noteworthy + " to stop " + stop + " floor " + floor + "";
		if ( getDvarInt( #"B67910B4" ) )
		{
			print3d( self.stub.origin, text, color, 1, 0,5, 300 );
#/
		}
	}
	if ( isDefined( self.stub.elevator ) )
	{
		if ( self.stub.elevator maps/mp/zm_highrise_elevators::elevator_is_on_floor( self.stub.floor ) )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			return 0;
		}
	}
	if ( !flag( "power_on" ) )
	{
		self.stub.hint_string = "";
		self sethintstring( self.stub.hint_string );
		return 0;
	}
	can_use = self buildabletrigger_update_prompt( player );
	if ( can_use )
	{
		thread watch_elevator_prompt( player, self );
	}
	return can_use;
}

onuseplantobject_elevatorkey( player )
{
	elevatorname = self.script_noteworthy;
	if ( isDefined( elevatorname ) && isDefined( self.script_parameters ) )
	{
		floor = int( self.script_parameters );
		elevator = level.elevators[ elevatorname ];
		if ( isDefined( elevator ) )
		{
			elevator.body.force_starting_floor = floor;
			elevator.body notify( "forcego" );
		}
	}
}

droponelevator( player )
{
	if ( isDefined( player ) && isDefined( player maps/mp/zm_highrise_elevators::object_is_on_elevator() ) && player maps/mp/zm_highrise_elevators::object_is_on_elevator() )
	{
		self.model linkto( player.elevator_parent );
		self.linked_to_elevator = 1;
		self.unitrigger.link_parent = player.elevator_parent;
	}
	else
	{
		self.unitrigger.link_parent = undefined;
	}
}

pickupfromelevator()
{
	if ( isDefined( self.linked_to_elevator ) && self.linked_to_elevator )
	{
		if ( isDefined( self.model ) )
		{
			self.model unlink();
		}
		self.linked_to_elevator = undefined;
	}
	if ( isDefined( self.unitrigger ) )
	{
		self.unitrigger.link_parent = undefined;
	}
}

onuseplantobject_slipgun( player )
{
/#
	println( "ZM >> Slipgun Buildable CallBack onUsePlantObject()" );
#/
	buildable = self.buildablezone;
	first_part = "TAG_COOKER";
	second_part = "TAG_BASE";
	i = 0;
	while ( i < buildable.pieces.size )
	{
		if ( buildable.pieces[ i ].part_name == first_part )
		{
			if ( isDefined( buildable.pieces[ i ].built ) || buildable.pieces[ i ].built && player.current_buildable_piece.part_name == first_part )
			{
				buildable.stub.model showpart( second_part );
				i++;
				continue;
			}
			else
			{
				buildable.stub.model hidepart( second_part );
			}
		}
		i++;
	}
}
