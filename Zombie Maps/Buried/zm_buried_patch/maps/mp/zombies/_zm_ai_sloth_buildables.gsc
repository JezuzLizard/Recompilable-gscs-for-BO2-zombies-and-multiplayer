#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_buried_buildables;
#include maps/mp/zm_buried;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_ai_sloth;
#include maps/mp/zombies/_zm_ai_sloth_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

build_buildable_condition()
{
	while ( level.sloth_buildable_zones.size > 0 )
	{
		i = 0;
		while ( i < level.sloth_buildable_zones.size )
		{
			zone = level.sloth_buildable_zones[ i ];
			if ( is_true( zone.built ) )
			{
				remove_zone = zone;
				i++;
				continue;
			}
			else piece_remaining = 0;
			pieces = zone.pieces;
			j = 0;
			while ( j < pieces.size )
			{
				if ( isDefined( pieces[ j ].unitrigger ) && !is_true( pieces[ j ].built ) )
				{
					piece_remaining = 1;
					break;
				}
				else
				{
					j++;
				}
			}
			if ( !piece_remaining )
			{
				i++;
				continue;
			}
			else
			{
				dist = distancesquared( zone.stub.origin, self.origin );
				if ( dist < 32400 )
				{
					self.buildable_zone = zone;
					return 1;
				}
			}
			i++;
		}
	}
	if ( isDefined( remove_zone ) )
	{
		arrayremovevalue( level.sloth_buildable_zones, remove_zone );
	}
	return 0;
}

common_move_to_table( stub, table, asd_name, check_pickup )
{
	if ( !isDefined( table ) )
	{
/#
		assertmsg( "Table not found for " + self.buildable_zone.buildable_name );
#/
		self.context_done = 1;
		return 0;
	}
	anim_id = self getanimfromasd( asd_name, 0 );
	start_org = getstartorigin( table.origin, table.angles, anim_id );
	start_ang = getstartangles( table.origin, table.angles, anim_id );
	self setgoalpos( start_org );
	while ( 1 )
	{
		if ( is_true( check_pickup ) )
		{
			if ( self.candy_player is_player_equipment( stub.weaponname ) )
			{
/#
				sloth_print( stub.weaponname + " was picked up" );
#/
				self.context_done = 1;
				return 0;
			}
		}
		if ( isDefined( self.buildable_zone ) && stub != self.buildable_zone.stub )
		{
/#
			sloth_print( "location change during pathing" );
#/
			stub = self.buildable_zone.stub;
			table = getent( stub.model.target, "targetname" );
			if ( !isDefined( table ) )
			{
/#
				assertmsg( "Table not found for " + self.buildable_zone.buildable_name );
#/
				self.context_done = 1;
				return 0;
			}
			start_org = getstartorigin( table.origin, table.angles, anim_id );
			start_ang = getstartangles( table.origin, table.angles, anim_id );
			self setgoalpos( start_org );
		}
		dist = distancesquared( self.origin, start_org );
		if ( dist < 1024 )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	self setgoalpos( self.origin );
	self sloth_face_object( table, "angle", start_ang[ 1 ], 0,9 );
	return 1;
}

build_buildable_action()
{
	self endon( "death" );
	self endon( "stop_action" );
	self maps/mp/zombies/_zm_ai_sloth::common_context_action();
	stub = self.buildable_zone.stub;
	table = getent( stub.model.target, "targetname" );
	if ( !self common_move_to_table( stub, table, "zm_make_buildable_intro" ) )
	{
		return;
	}
	self maps/mp/zombies/_zm_ai_sloth::action_animscripted( "zm_make_buildable_intro", "make_buildable_intro_anim", table.origin, table.angles );
/#
	sloth_print( "looking for " + self.buildable_zone.buildable_name + " pieces" );
#/
	store = getstruct( "sloth_general_store", "targetname" );
	self setgoalpos( store.origin );
	self waittill( "goal" );
	self.pieces = [];
	while ( isDefined( self.buildable_zone ) )
	{
		pieces = self.buildable_zone.pieces;
		if ( pieces.size == 0 )
		{
/#
			sloth_print( "no pieces available" );
#/
			self.context_done = 1;
			return;
		}
		i = 0;
		while ( i < pieces.size )
		{
			if ( isDefined( pieces[ i ].unitrigger ) && !is_true( pieces[ i ].built ) )
			{
/#
				if ( getDvarInt( #"B6252E7C" ) == 2 )
				{
					line( self.origin, pieces[ i ].start_origin, ( 1, 1, 1 ), 1, 0, 1000 );
#/
				}
				self maps/mp/zombies/_zm_buildables::player_take_piece( pieces[ i ] );
				self.pieces[ self.pieces.size ] = pieces[ i ];
			}
			i++;
		}
	}
	self animscripted( self.origin, self.angles, "zm_pickup_part" );
	maps/mp/animscripts/zm_shared::donotetracks( "pickup_part_anim" );
/#
	sloth_print( "took " + self.pieces.size + " pieces" );
#/
	if ( !self common_move_to_table( stub, table, "zm_make_buildable" ) )
	{
		return;
	}
	self.buildable_zone.stub.bound_to_buildable = self.buildable_zone.stub;
	if ( stub != self.buildable_zone.stub )
	{
		stub = self.buildable_zone.stub;
		table = getent( stub.model.target, "targetname" );
	}
	self thread build_buildable_fx( table );
	self animscripted( table.origin, table.angles, "zm_make_buildable" );
	wait 2,5;
	self notify( "stop_buildable_fx" );
	self maps/mp/zombies/_zm_buildables::player_build( self.buildable_zone, self.pieces );
	if ( isDefined( self.buildable_zone.stub.onuse ) )
	{
		self.buildable_zone.stub [[ self.buildable_zone.stub.onuse ]]( self );
	}
	self.pieces = undefined;
	self.context_done = 1;
}

build_buildable_fx( table )
{
	self endon( "death" );
	self notify( "stop_buildable_fx" );
	self endon( "stop_buildable_fx" );
	while ( 1 )
	{
		playfx( level._effect[ "fx_buried_sloth_building" ], table.origin );
		wait 0,25;
	}
}

build_buildable_interrupt()
{
	while ( isDefined( self.pieces ) && self.pieces.size > 0 )
	{
		_a238 = self.pieces;
		_k238 = getFirstArrayKey( _a238 );
		while ( isDefined( _k238 ) )
		{
			piece = _a238[ _k238 ];
			piece maps/mp/zombies/_zm_buildables::piece_spawn_at();
			_k238 = getNextArrayKey( _a238, _k238 );
		}
	}
}

fetch_buildable_condition()
{
	self.turbine = undefined;
	turbines = [];
	equipment = maps/mp/zombies/_zm_equipment::get_destructible_equipment_list();
	_a254 = equipment;
	_k254 = getFirstArrayKey( _a254 );
	while ( isDefined( _k254 ) )
	{
		item = _a254[ _k254 ];
		if ( !isDefined( item.equipname ) )
		{
		}
		else
		{
			if ( item.equipname == "equip_turbine_zm" )
			{
/#
				self sloth_debug_context( item, sqrt( 32400 ) );
#/
				dist = distancesquared( item.origin, self.origin );
				if ( dist < 32400 )
				{
					self.power_stubs = get_power_stubs( self.candy_player );
					if ( self.power_stubs.size > 0 )
					{
						self.turbine = item;
						return 1;
					}
					else
					{
						localpower = item.owner.localpower;
						if ( check_localpower_list( localpower.added_list ) || check_localpower_list( localpower.enabled_list ) )
						{
							self.turbine = item;
							return 1;
						}
					}
				}
				turbines[ turbines.size ] = item;
			}
		}
		_k254 = getNextArrayKey( _a254, _k254 );
	}
	_a290 = equipment;
	_k290 = getFirstArrayKey( _a290 );
	while ( isDefined( _k290 ) )
	{
		item = _a290[ _k290 ];
		if ( !isDefined( item.equipname ) )
		{
		}
		else
		{
			while ( item.equipname != "equip_turret_zm" || item.equipname == "equip_electrictrap_zm" && item.equipname == "equip_subwoofer_zm" )
			{
/#
				self sloth_debug_context( item, sqrt( 32400 ) );
#/
				dist = distancesquared( item.origin, self.origin );
				while ( dist < 32400 )
				{
					while ( is_true( item.power_on ) )
					{
						_a307 = turbines;
						_k307 = getFirstArrayKey( _a307 );
						while ( isDefined( _k307 ) )
						{
							turbine = _a307[ _k307 ];
							if ( is_turbine_powering_item( turbine, item ) )
							{
								self.turbine = turbine;
								return 1;
							}
							_k307 = getNextArrayKey( _a307, _k307 );
						}
					}
				}
			}
		}
		_k290 = getNextArrayKey( _a290, _k290 );
	}
	_a320 = equipment;
	_k320 = getFirstArrayKey( _a320 );
	while ( isDefined( _k320 ) )
	{
		item = _a320[ _k320 ];
		if ( !isDefined( item.equipname ) )
		{
		}
		else if ( item.equipname != "equip_turret_zm" || item.equipname == "equip_electrictrap_zm" && item.equipname == "equip_subwoofer_zm" )
		{
/#
			self sloth_debug_context( item, sqrt( 32400 ) );
#/
			dist = distancesquared( item.origin, self.origin );
			if ( dist < 32400 )
			{
				if ( is_true( level.turbine_zone.built ) )
				{
					self.power_item = item;
					return 1;
				}
				else
				{
/#
					sloth_print( "turbine not built" );
#/
				}
			}
		}
		_k320 = getNextArrayKey( _a320, _k320 );
	}
	return 0;
}

is_turbine_powering_item( turbine, item )
{
	localpower = turbine.owner.localpower;
	while ( isDefined( localpower.added_list ) )
	{
		_a358 = localpower.added_list;
		_k358 = getFirstArrayKey( _a358 );
		while ( isDefined( _k358 ) )
		{
			added = _a358[ _k358 ];
			if ( added == item )
			{
				return 1;
			}
			_k358 = getNextArrayKey( _a358, _k358 );
		}
	}
	while ( isDefined( localpower.enabled_list ) )
	{
		_a368 = localpower.enabled_list;
		_k368 = getFirstArrayKey( _a368 );
		while ( isDefined( _k368 ) )
		{
			enabled = _a368[ _k368 ];
			if ( enabled == item )
			{
				return 1;
			}
			_k368 = getNextArrayKey( _a368, _k368 );
		}
	}
	return 0;
}

get_power_stubs( player )
{
	power_stubs = [];
	_a382 = level.power_zones;
	_k382 = getFirstArrayKey( _a382 );
	while ( isDefined( _k382 ) )
	{
		zone = _a382[ _k382 ];
		if ( is_true( zone.built ) )
		{
			if ( !player has_player_equipment( zone.stub.weaponname ) )
			{
				power_stubs[ power_stubs.size ] = zone.stub;
			}
		}
		_k382 = getNextArrayKey( _a382, _k382 );
	}
	return power_stubs;
}

fetch_buildable_start()
{
/#
	sloth_print( self.context.name );
#/
	self.context_done = 0;
	self.pi_origin = undefined;
	if ( isDefined( self.turbine ) )
	{
		localpower = self.turbine.owner.localpower;
		if ( check_localpower_list( localpower.added_list ) || check_localpower_list( localpower.enabled_list ) )
		{
/#
			sloth_print( "has powered item, go get turbine" );
#/
			self thread fetch_buildable_action( "turbine" );
			return;
		}
/#
		sloth_print( "find a power item" );
#/
		self thread fetch_buildable_action( "power_item" );
	}
	else
	{
		if ( isDefined( self.power_item ) )
		{
/#
			sloth_print( "power item needs turbine" );
#/
			self.pi_origin = self.power_item.origin;
			self thread fetch_buildable_action( "turbine" );
		}
	}
}

check_localpower_list( list )
{
	while ( isDefined( list ) )
	{
		_a436 = list;
		_k436 = getFirstArrayKey( _a436 );
		while ( isDefined( _k436 ) )
		{
			item = _a436[ _k436 ];
			item_name = item.target.name;
			if ( !isDefined( item_name ) )
			{
			}
			else
			{
				if ( item_name != "equip_turret_zm" || item_name == "equip_electrictrap_zm" && item_name == "equip_subwoofer_zm" )
				{
					return 1;
				}
			}
			_k436 = getNextArrayKey( _a436, _k436 );
		}
	}
	return 0;
}

fetch_buildable_action( item )
{
	self endon( "death" );
	self endon( "stop_action" );
	self maps/mp/zombies/_zm_ai_sloth::common_context_action();
	player = self.candy_player;
	if ( item == "turbine" )
	{
		if ( isDefined( self.turbine ) )
		{
			plant_origin = self.turbine.origin;
			plant_angles = self.turbine.angles;
		}
		stub = level.turbine_zone.stub;
	}
	else
	{
		if ( item == "power_item" )
		{
			self.power_stubs = array_randomize( self.power_stubs );
			stub = self.power_stubs[ 0 ];
		}
	}
	append_name = "equipment";
	pickup_asd = "zm_pickup_" + append_name;
	table = getent( stub.model.target, "targetname" );
	if ( !self common_move_to_table( stub, table, pickup_asd, 1 ) )
	{
		return;
	}
	self.buildable_item = item;
	self animscripted( table.origin, table.angles, pickup_asd );
	maps/mp/animscripts/zm_shared::donotetracks( "pickup_equipment_anim", ::pickup_notetracks, stub );
	if ( player is_player_equipment( stub.weaponname ) )
	{
/#
		sloth_print( "during anim player picked up " + stub.weaponname );
#/
		self.context_done = 1;
		return;
	}
	if ( !player has_deployed_equipment( stub.weaponname ) )
	{
		player.deployed_equipment[ player.deployed_equipment.size ] = stub.weaponname;
	}
/#
	sloth_print( "got " + stub.equipname );
#/
	if ( isDefined( self.turbine ) )
	{
		ground_pos = self.turbine.origin;
	}
	else if ( isDefined( self.power_item ) )
	{
		ground_pos = self.power_item.origin;
	}
	else
	{
		ground_pos = self.pi_origin;
	}
	run_asd = "run_holding_" + append_name;
	self.ignore_common_run = 1;
	self set_zombie_run_cycle( run_asd );
	self.locomotion = run_asd;
	self setgoalpos( ground_pos );
	range = 10000;
	if ( item == "power_item" || isDefined( self.power_item ) )
	{
		range = 25600;
	}
	while ( 1 )
	{
		while ( self sloth_is_traversing() )
		{
			wait 0,1;
		}
		dist = distancesquared( self.origin, ground_pos );
		if ( dist < range )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	if ( item == "turbine" )
	{
		if ( isDefined( self.turbine ) )
		{
			self orientmode( "face point", self.turbine.origin );
			self animscripted( self.origin, flat_angle( vectorToAngle( self.turbine.origin - self.origin ) ), "zm_kick_equipment" );
			maps/mp/animscripts/zm_shared::donotetracks( "kick_equipment_anim", ::destroy_item, self.turbine );
			self orientmode( "face default" );
			self animscripted( self.origin, self.angles, "zm_idle_equipment" );
			wait 3;
		}
	}
	if ( !isDefined( plant_origin ) )
	{
		plant_origin = self.origin;
		plant_angles = self.angles;
	}
	drop_asd = "zm_drop_" + append_name;
	self maps/mp/zombies/_zm_ai_sloth::action_animscripted( drop_asd, "drop_equipment_anim" );
	if ( player has_player_equipment( stub.weaponname ) )
	{
		player equipment_take( stub.weaponname );
	}
	player player_set_equipment_damage( stub.weaponname, 0 );
	if ( !player has_deployed_equipment( stub.weaponname ) )
	{
		player.deployed_equipment[ player.deployed_equipment.size ] = stub.weaponname;
	}
	if ( isDefined( self.buildable_model ) )
	{
		self.buildable_model unlink();
		self.buildable_model delete();
	}
	equipment = stub.weaponname;
	plant_origin = self gettagorigin( "tag_weapon_right" );
	plant_angles = self gettagangles( "tag_weapon_right" );
	replacement = player [[ level.zombie_equipment[ equipment ].place_fn ]]( plant_origin, plant_angles );
	if ( isDefined( replacement ) )
	{
		replacement.owner = player;
		replacement.original_owner = player;
		replacement.name = equipment;
		player notify( "equipment_placed" );
		if ( isDefined( level.equipment_planted ) )
		{
			player [[ level.equipment_planted ]]( replacement, equipment, self );
		}
	}
	self.context_done = 1;
}

pickup_notetracks( note, stub )
{
	if ( note == "pickup" )
	{
		tag_name = "tag_stowed_back";
		twr_origin = self gettagorigin( tag_name );
		twr_angles = self gettagangles( tag_name );
		self.buildable_model = spawn( "script_model", twr_origin );
		self.buildable_model.angles = twr_angles;
		if ( self.buildable_item == "turbine" )
		{
			self.buildable_model setmodel( level.small_turbine );
		}
		else
		{
			self.buildable_model setmodel( stub.model.model );
		}
		self.buildable_model linkto( self, tag_name );
	}
}

destroy_item( note, item )
{
	if ( note == "kick" )
	{
		if ( isDefined( item ) )
		{
			if ( isDefined( item.owner ) )
			{
				item.owner thread maps/mp/zombies/_zm_equipment::player_damage_equipment( item.equipname, 1001, item.origin );
				return;
			}
			else
			{
				item thread maps/mp/zombies/_zm_equipment::dropped_equipment_destroy( 1 );
			}
		}
	}
}

fetch_buildable_interrupt()
{
	if ( isDefined( self.buildable_model ) )
	{
		self.buildable_model unlink();
		self.buildable_model delete();
	}
}

wallbuy_condition()
{
	if ( !wallbuy_get_stub_array().size )
	{
		return 0;
	}
	if ( !wallbuy_get_piece_array().size )
	{
		return 0;
	}
	if ( isDefined( level.gunshop_zone ) )
	{
		if ( self istouching( level.gunshop_zone ) )
		{
/#
			sloth_print( "using new gunshop zone" );
#/
			return 1;
		}
	}
	else
	{
		if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_gun_store" ) )
		{
			return 1;
		}
	}
	return 0;
}

wallbuy_get_stub_array()
{
	stubs = [];
	i = 0;
	while ( i < level.sloth_wallbuy_stubs.size )
	{
		stub = level.sloth_wallbuy_stubs[ i ];
		if ( !isDefined( stub.in_zone ) )
		{
/#
			iprintln( "WALLBUY NOT IN VALID ZONE" );
#/
			i++;
			continue;
		}
		else if ( !level.zones[ stub.in_zone ].is_enabled )
		{
			i++;
			continue;
		}
		else if ( is_true( stub.built ) )
		{
			remove_stub = stub;
			i++;
			continue;
		}
		else if ( stub.in_zone == "zone_general_store" )
		{
			if ( !is_general_store_open() )
			{
				i++;
				continue;
			}
		}
		else if ( stub.in_zone == "zone_underground_courthouse2" )
		{
			if ( !maps/mp/zm_buried::is_courthouse_open() )
			{
				i++;
				continue;
			}
		}
		else if ( stub.in_zone == "zone_tunnels_center" )
		{
			if ( !maps/mp/zm_buried::is_tunnel_open() )
			{
				i++;
				continue;
			}
		}
		else
		{
			stubs[ stubs.size ] = stub;
		}
		i++;
	}
	if ( isDefined( remove_stub ) )
	{
		arrayremovevalue( level.sloth_wallbuy_stubs, remove_stub );
	}
	return stubs;
}

wallbuy_get_piece_array()
{
	pieces = [];
	i = 0;
	while ( i < level.chalk_pieces.size )
	{
		piece = level.chalk_pieces[ i ];
		if ( isDefined( piece.unitrigger ) && !is_true( piece.built ) )
		{
			pieces[ pieces.size ] = piece;
		}
		i++;
	}
	return pieces;
}

wallbuy_action()
{
	self endon( "death" );
	self endon( "stop_action" );
	self maps/mp/zombies/_zm_ai_sloth::common_context_action();
	wallbuy_struct = getstruct( "sloth_allign_gunshop", "targetname" );
	asd_name = "zm_wallbuy_remove";
	anim_id = self getanimfromasd( asd_name, 0 );
	start_org = getstartorigin( wallbuy_struct.origin, wallbuy_struct.angles, anim_id );
	start_ang = getstartangles( wallbuy_struct.origin, wallbuy_struct.angles, anim_id );
	self setgoalpos( start_org );
	self waittill( "goal" );
	self setgoalpos( self.origin );
	self sloth_face_object( undefined, "angle", start_ang[ 1 ], 0,9 );
	self animscripted( wallbuy_struct.origin, wallbuy_struct.angles, asd_name );
	maps/mp/animscripts/zm_shared::donotetracks( "wallbuy_remove_anim", ::wallbuy_grab_pieces );
	if ( !self.wallbuy_stubs.size || !self.wallbuy_pieces.size )
	{
		self.context_done = 1;
		return;
	}
	i = 0;
	while ( i < self.pieces_needed )
	{
		stub = self.wallbuy_stubs[ i ];
		vec_right = vectornormalize( anglesToRight( stub.angles ) );
		org = stub.origin - ( vec_right * 60 );
		org = groundpos( org );
		self setgoalpos( org );
		skip_piece = 0;
		while ( 1 )
		{
			if ( is_true( stub.built ) )
			{
/#
				sloth_print( "stub was built during pathing" );
#/
				skip_piece = 1;
				break;
			}
			else dist = distancesquared( self.origin, org );
			if ( dist < 576 )
			{
				break;
			}
			else
			{
				wait 0,1;
			}
		}
		if ( !skip_piece )
		{
			self setgoalpos( self.origin );
			chalk_angle = vectorToAngle( vec_right );
			self sloth_face_object( stub, "angle", chalk_angle[ 1 ], 0,9 );
			if ( is_true( stub.built ) )
			{
/#
				sloth_print( "stub was built during facing" );
#/
				skip_piece = 1;
			}
		}
		self player_set_buildable_piece( self.wallbuy_pieces[ i ], 1 );
		current_piece = self player_get_buildable_piece( 1 );
		if ( skip_piece )
		{
			arrayremovevalue( self.wallbuy_pieces_taken, current_piece );
			current_piece maps/mp/zm_buried_buildables::ondrop_chalk( self );
			self orientmode( "face default" );
			i++;
			continue;
		}
		else
		{
			self thread player_draw_chalk( stub );
			self maps/mp/zombies/_zm_ai_sloth::action_animscripted( "zm_wallbuy_add", "wallbuy_add_anim", org, chalk_angle );
			self notify( "end_chalk_dust" );
			playsoundatposition( "zmb_cha_ching_loud", stub.origin );
			if ( is_true( stub.built ) )
			{
				current_piece maps/mp/zm_buried_buildables::ondrop_chalk( self );
/#
				sloth_print( "stub was built during anim" );
#/
			}
			else
			{
				stub maps/mp/zm_buried_buildables::onuseplantobject_chalk( self );
				stub buildablestub_finish_build( self );
				stub buildablestub_remove();
				thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
/#
				sloth_print( "built " + self player_get_buildable_piece( 1 ).script_noteworthy );
#/
			}
			arrayremovevalue( self.wallbuy_pieces_taken, self player_get_buildable_piece( 1 ) );
			self orientmode( "face default" );
		}
		i++;
	}
	self.context_done = 1;
}

wallbuy_grab_pieces( note )
{
	while ( note == "pulled" )
	{
		self.wallbuy_stubs = wallbuy_get_stub_array();
		self.wallbuy_pieces = wallbuy_get_piece_array();
		self.pieces_needed = self.wallbuy_stubs.size;
		if ( self.pieces_needed > self.wallbuy_pieces.size )
		{
			self.pieces_needed = self.wallbuy_pieces.size;
		}
		self.wallbuy_pieces = array_randomize( self.wallbuy_pieces );
		self.wallbuy_pieces_taken = [];
		i = 0;
		while ( i < self.pieces_needed )
		{
			self.wallbuy_pieces_taken[ i ] = self.wallbuy_pieces[ i ];
			self.wallbuy_pieces[ i ] maps/mp/zombies/_zm_buildables::piece_unspawn();
			i++;
		}
	}
}

wallbuy_interrupt()
{
	while ( isDefined( self.wallbuy_pieces_taken ) && self.wallbuy_pieces_taken.size > 0 )
	{
		_a920 = self.wallbuy_pieces_taken;
		_k920 = getFirstArrayKey( _a920 );
		while ( isDefined( _k920 ) )
		{
			wallbuy = _a920[ _k920 ];
			wallbuy maps/mp/zm_buried_buildables::ondrop_chalk( self );
			_k920 = getNextArrayKey( _a920, _k920 );
		}
	}
}
