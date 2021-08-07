#include maps/mp/_demo;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	precachestring( &"ZOMBIE_BUILDING" );
	precachestring( &"ZOMBIE_BUILD_PIECE_MISSING" );
	precachestring( &"ZOMBIE_BUILD_PIECE_GRAB" );
	precacheitem( "zombie_builder_zm" );
	precacheitem( "buildable_piece_zm" );
	level.gameobjswapping = 1;
	zombie_buildables_callbacks = [];
	level.buildablepickups = [];
	level.buildables_built = [];
	level.buildable_stubs = [];
	level.buildable_piece_count = 0;
	level._effect[ "building_dust" ] = loadfx( "maps/zombie/fx_zmb_buildable_assemble_dust" );
	if ( isDefined( level.init_buildables ) )
	{
		[[ level.init_buildables ]]();
	}
	if ( isDefined( level.use_swipe_protection ) )
	{
		onplayerconnect_callback( ::buildables_watch_swipes );
	}
}

anystub_update_prompt( player ) //checked matches cerberus output
{
	if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || player maps/mp/zombies/_zm_utility::in_revive_trigger() )
	{
		self.hint_string = "";
		return 0;
	}
	if ( player isthrowinggrenade() )
	{
		self.hint_string = "";
		return 0;
	}
	if ( isDefined( player.is_drinking ) && player.is_drinking > 0 )
	{
		self.hint_string = "";
		return 0;
	}
	if ( isDefined( player.screecher_weapon ) )
	{
		self.hint_string = "";
		return 0;
	}
	return 1;
}

anystub_get_unitrigger_origin() //checked matches cerberus output
{
	if ( isDefined( self.origin_parent ) )
	{
		return self.origin_parent.origin;
	}
	return self.origin;
}

anystub_on_spawn_trigger( trigger ) //checked matches cerberus output
{
	if ( isDefined( self.link_parent ) )
	{
		trigger enablelinkto();
		trigger linkto( self.link_parent );
		trigger setmovingplatformenabled( 1 );
	}
}

buildables_watch_swipes() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self notify( "buildables_watch_swipes" );
	self endon( "buildables_watch_swipes" );
	while ( 1 )
	{
		self waittill( "melee_swipe", zombie );
		if ( distancesquared( zombie.origin, self.origin ) > zombie.meleeattackdist * zombie.meleeattackdist )
		{
			continue;
		}
		trigger = level._unitriggers.trigger_pool[ self getentitynumber() ];
		if ( isDefined( trigger ) && isDefined( trigger.stub.piece ) )
		{
			piece = trigger.stub.piece;
			if ( !isDefined( piece.damage ) )
			{
				piece.damage = 0;
			}
			piece.damage++;
			if ( piece.damage > 12 )
			{
				thread maps/mp/zombies/_zm_equipment::equipment_disappear_fx( trigger.stub maps/mp/zombies/_zm_unitrigger::unitrigger_origin() );
				piece maps/mp/zombies/_zm_buildables::piece_unspawn();
				self maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_total", 0 );
				if ( isalive( self ) )
				{
					self playlocalsound( level.zmb_laugh_alias );
				}
			}
		}
	}
}

explosiondamage( damage, pos ) //checked matches cerberus output
{
	/*
/#
	println( "ZM BUILDABLE Explode do " + damage + " damage to " + self.name + "\n" );
#/
	*/
	self dodamage( damage, pos );
}

add_zombie_buildable( buildable_name, hint, building, bought ) //checked matches cerberus output
{
	if ( !isDefined( level.zombie_include_buildables ) )
	{
		level.zombie_include_buildables = [];
	}
	if ( isDefined( level.zombie_include_buildables ) && !isDefined( level.zombie_include_buildables[ buildable_name ] ) )
	{
		return;
	}
	precachestring( hint );
	if ( isDefined( building ) )
	{
		precachestring( building );
	}
	if ( isDefined( bought ) )
	{
		precachestring( bought );
	}
	buildable_struct = level.zombie_include_buildables[ buildable_name ];
	if ( !isDefined( level.zombie_buildables ) )
	{
		level.zombie_buildables = [];
	}
	buildable_struct.hint = hint;
	buildable_struct.building = building;
	buildable_struct.bought = bought;
	/*
/#
	println( "ZM >> Looking for buildable - " + buildable_struct.name );
#/
	*/
	level.zombie_buildables[ buildable_struct.name ] = buildable_struct;
	if ( !level.createfx_enabled )
	{
		if ( level.zombie_buildables.size == 1 )
		{
			register_clientfields();
		}
	}
}

register_clientfields() //checked changed to match cerberus output
{
	if ( isDefined( level.buildable_slot_count ) )
	{
		for ( i = 0; i < level.buildable_slot_count; i++ )
		{
			bits = getminbitcountfornum( level.buildable_piece_counts[ i ] );
			registerclientfield( "toplayer", level.buildable_clientfields[ i ], 12000, bits, "int" );
		}
	}
	else
	{
		bits = getminbitcountfornum( level.buildable_piece_count );
		registerclientfield( "toplayer", "buildable", 1, bits, "int" );
	}
}

set_buildable_clientfield( slot, newvalue ) //checked matches cerberus output
{
	if ( isDefined( level.buildable_slot_count ) )
	{
		self setclientfieldtoplayer( level.buildable_clientfields[ slot ], newvalue );
	}
	else
	{
		self setclientfieldtoplayer( "buildable", newvalue );
	}
}

clear_buildable_clientfield( slot ) //checked matches cerberus output
{
	self set_buildable_clientfield( slot, 0 );
}

include_zombie_buildable( buiildable_struct ) //checked matches cerberus output
{
	if ( !isDefined( level.zombie_include_buildables ) )
	{
		level.zombie_include_buildables = [];
	}
	/*
/#
	println( "ZM >> Including buildable - " + buiildable_struct.name );
#/
	*/
	level.zombie_include_buildables[ buiildable_struct.name ] = buiildable_struct;
}

generate_zombie_buildable_piece( buildablename, modelname, radius, height, drop_offset, hud_icon, onpickup, ondrop, use_spawn_num, part_name, can_reuse, client_field_state, buildable_slot ) //checked changed to match cerberus output
{
	precachemodel( modelname );
	if ( isDefined( hud_icon ) )
	{
		precacheshader( hud_icon );
	}
	piece = spawnstruct();
	buildable_pieces = [];
	buildable_pieces_structs = patch_zm\common_scripts\utility::getstructarray( buildablename + "_" + modelname, "targetname" );
	/*
/#
	if ( buildable_pieces_structs.size < 1 )
	{
		println( "ERROR: Missing buildable piece <" + buildablename + "> <" + modelname + ">\n" );
#/
	}
	*/
	foreach ( struct in buildable_pieces_structs )
	{
		buildable_pieces[ index ] = struct;
		buildable_pieces[ index ].hasspawned = 0;
	}
	piece.spawns = buildable_pieces;
	piece.buildablename = buildablename;
	piece.modelname = modelname;
	piece.hud_icon = hud_icon;
	piece.radius = radius;
	piece.height = height;
	piece.part_name = part_name;
	piece.can_reuse = can_reuse;
	piece.drop_offset = drop_offset;
	piece.max_instances = 256;
	if ( isDefined( buildable_slot ) )
	{
		piece.buildable_slot = buildable_slot;
	}
	else
	{
		piece.buildable_slot = 0;
	}
	piece.onpickup = onpickup;
	piece.ondrop = ondrop;
	piece.use_spawn_num = use_spawn_num;
	piece.client_field_state = client_field_state;
	return piece;
}

manage_multiple_pieces( max_instances, min_instances ) //checked matches cerberus output
{
	self.max_instances = max_instances;
	self.min_instances = min_instances;
	self.managing_pieces = 1;
	self.piece_allocated = [];
}

buildable_set_force_spawn_location( str_kvp, str_name ) //checked matches cerberus output
{
	self.str_force_spawn_kvp = str_kvp;
	self.str_force_spawn_name = str_name;
}

buildable_use_cyclic_spawns( randomize_start_location ) //checked matches cerberus output
{
	self.use_cyclic_spawns = 1;
	self.randomize_cyclic_index = randomize_start_location;
}

combine_buildable_pieces( piece1, piece2, piece3 ) //checked matches cerberus output
{
	spawns1 = piece1.spawns;
	spawns2 = piece2.spawns;
	spawns = arraycombine( spawns1, spawns2, 1, 0 );
	if ( isDefined( piece3 ) )
	{
		spawns3 = piece3.spawns;
		spawns = arraycombine( spawns, spawns3, 1, 0 );
		spawns = array_randomize( spawns );
		piece3.spawns = spawns;
	}
	else
	{
		spawns = array_randomize( spawns );
	}
	piece1.spawns = spawns;
	piece2.spawns = spawns;
}

add_buildable_piece( piece, part_name, can_reuse ) //checked matches cerberus output
{
	if ( !isDefined( self.buildablepieces ) )
	{
		self.buildablepieces = [];
	}
	if ( isDefined( part_name ) )
	{
		piece.part_name = part_name;
	}
	if ( isDefined( can_reuse ) )
	{
		piece.can_reuse = can_reuse;
	}
	self.buildablepieces[ self.buildablepieces.size ] = piece;
	if ( !isDefined( self.buildable_slot ) )
	{
		self.buildable_slot = piece.buildable_slot;
	}
	else
	{
		/*
/#
		assert( self.buildable_slot == piece.buildable_slot );
#/
		*/
	}
}

create_zombie_buildable_piece( modelname, radius, height, hud_icon ) //checked matches cerberus output
{
	piece = generate_zombie_buildable_piece( self.name, modelname, radius, height, hud_icon );
	self add_buildable_piece( piece );
}

onplayerlaststand() //checked partially changed to match cerberus output
{
	pieces = self player_get_buildable_pieces();
	spawn_pos = [];
	spawn_pos[ 0 ] = self.origin;
	if ( pieces.size >= 2 )
	{
		nodes = getnodesinradiussorted( self.origin + vectorScale( ( 0, 0, 1 ), 30 ), 120, 30, 72, "path", 5 );
		i = 0;
		while ( i < pieces.size )
		{
			if ( i < nodes.size && check_point_in_playable_area( nodes[ i ].origin ) )
			{
				spawn_pos[ i ] = nodes[ i ].origin;
				i++;
				continue;
			}
			spawn_pos[ i ] = self.origin + vectorScale( ( 0, 0, 1 ), 5 );
			i++;
		}
	}
	spawnidx = 0;
	foreach ( piece in pieces )
	{
		slot = piece.buildable_slot;
		if ( isDefined( piece ) )
		{
			return_to_start_pos = 0;
			if ( isDefined( level.safe_place_for_buildable_piece ) )
			{
				if ( !( self [[ level.safe_place_for_buildable_piece ]]( piece ) ) )
				{
					return_to_start_pos = 1;
				}
			}
			if ( return_to_start_pos )
			{
				piece piece_spawn_at();
			}
			else if ( pieces.size < 2 )
			{
				piece piece_spawn_at( self.origin + vectorScale( ( 1, 1, 0 ), 5 ), self.angles );
			}
			else
			{
				piece piece_spawn_at( spawn_pos[ spawnidx ], self.angles );
			}
			if ( isDefined( piece.ondrop ) )
			{
				piece [[ piece.ondrop ]]( self );
			}
			self clear_buildable_clientfield( slot );
			spawnidx++;
		}
		self player_set_buildable_piece( undefined, slot );
		self notify( "piece_released" + slot );
	}
}

piecestub_get_unitrigger_origin() //checked matches cerberus output
{
	if ( isDefined( self.origin_parent ) )
	{
		return self.origin_parent.origin + vectorScale( ( 0, 0, 1 ), 12 );
	}
	return self.origin;
}

generate_piece_unitrigger( classname, origin, angles, flags, radius, script_height, moving ) //checked matches cerberus output
{
	if ( !isDefined( radius ) )
	{
		radius = 64;
	}
	if ( !isDefined( script_height ) )
	{
		script_height = 64;
	}
	script_width = script_height;
	if ( !isDefined( script_width ) )
	{
		script_width = 64;
	}
	script_length = script_height;
	if ( !isDefined( script_length ) )
	{
		script_length = 64;
	}
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = origin;
	if ( isDefined( script_length ) )
	{
		unitrigger_stub.script_length = script_length;
	}
	else
	{
		unitrigger_stub.script_length = 13.5;
	}
	if ( isDefined( script_width ) )
	{
		unitrigger_stub.script_width = script_width;
	}
	else
	{
		unitrigger_stub.script_width = 27.5;
	}
	if ( isDefined( script_height ) )
	{
		unitrigger_stub.script_height = script_height;
	}
	else
	{
		unitrigger_stub.script_height = 24;
	}
	unitrigger_stub.radius = radius;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.hint_string = &"ZOMBIE_BUILD_PIECE_GRAB";
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 0;
	switch( classname )
	{
		case "trigger_radius":
			unitrigger_stub.script_unitrigger_type = "unitrigger_radius";
			break;
		case "trigger_radius_use":
			unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
			break;
		case "trigger_box":
			unitrigger_stub.script_unitrigger_type = "unitrigger_box";
			break;
		case "trigger_box_use":
			unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
			break;
	}
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::piecetrigger_update_prompt;
	unitrigger_stub.originfunc = ::piecestub_get_unitrigger_origin;
	unitrigger_stub.onspawnfunc = ::anystub_on_spawn_trigger;
	if ( is_true( moving ) )
	{
		maps/mp/zombies/_zm_unitrigger::register_unitrigger( unitrigger_stub, ::piece_unitrigger_think );
	}
	else
	{
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::piece_unitrigger_think );
	}
	return unitrigger_stub;
}

piecetrigger_update_prompt( player ) //checked matches cerberus output
{
	can_use = self.stub piecestub_update_prompt( player );
	self setinvisibletoplayer( player, !can_use );
	if ( isDefined( self.stub.hint_parm1 ) )
	{
		self sethintstring( self.stub.hint_string, self.stub.hint_parm1 );
	}
	else
	{
		self sethintstring( self.stub.hint_string );
	}
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

piecestub_update_prompt( player ) //checked changed to match cerberus output
{
	if ( !self anystub_update_prompt( player ) )
	{
		self.cursor_hint = "HINT_NOICON";
		return 0;
	}
	if ( isDefined( player player_get_buildable_piece( self.piece.buildable_slot ) ) )
	{
		spiece = self.piece;
		cpiece = player player_get_buildable_piece( self.piece.buildable_slot );
		if ( spiece.modelname == cpiece.modelname && spiece.buildablename == cpiece.buildablename && isDefined( spiece.script_noteworthy ) || !isDefined( cpiece.script_noteworthy ) && spiece.script_noteworthy == cpiece.script_noteworthy )
		{
			self.hint_string = "";
			return 0;
		}
		if ( isDefined( spiece.hint_swap ) )
		{
			self.hint_string = spiece.hint_swap;
			self.hint_parm1 = self.piece.hint_swap_parm1;
		}
		else
		{
			self.hint_string = &"ZOMBIE_BUILD_PIECE_SWITCH";
		}
		if ( isDefined( self.piece.cursor_hint ) )
		{
			self.cursor_hint = self.piece.cursor_hint;
		}
		if ( isDefined( self.piece.cursor_hint_weapon ) )
		{
			self.cursor_hint_weapon = self.piece.cursor_hint_weapon;
		}
	}
	else if ( isDefined( self.piece.hint_grab ) )
	{
		self.hint_string = self.piece.hint_grab;
		self.hint_parm1 = self.piece.hint_grab_parm1;
	}
	else
	{
		self.hint_string = &"ZOMBIE_BUILD_PIECE_GRAB";
	}
	if ( isDefined( self.piece.cursor_hint ) )
	{
		self.cursor_hint = self.piece.cursor_hint;
	}
	if ( isDefined( self.piece.cursor_hint_weapon ) )
	{
		self.cursor_hint_weapon = self.piece.cursor_hint_weapon;
	}
	return 1;
}

piece_unitrigger_think() //checked changed to match cerberus output
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( player != self.parent_player )
		{
			continue;
		}
		if ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		status = player player_can_take_piece( self.stub.piece );
		if ( !status )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
		}
		else
		{
			player thread player_take_piece( self.stub.piece );
		}
	}
}

player_get_buildable_pieces() //checked matches cerberus output
{
	if ( !isDefined( self.current_buildable_pieces ) )
	{
		self.current_buildable_pieces = [];
	}
	return self.current_buildable_pieces;
}

player_get_buildable_piece( slot ) //checked matches cerberus output
{
	if ( !isDefined( slot ) )
	{
		slot = 0;
	}
	if ( !isDefined( self.current_buildable_pieces ) )
	{
		self.current_buildable_pieces = [];
	}
	return self.current_buildable_pieces[ slot ];
}

player_set_buildable_piece( piece, slot ) //checked matches cerberus output
{
	if ( !isDefined( slot ) )
	{
		slot = 0;
	}
	/*
/#
	if ( isDefined( slot ) && isDefined( piece ) && isDefined( piece.buildable_slot ) )
	{
		assert( slot == piece.buildable_slot );
#/
	}
	*/
	if ( !isDefined( self.current_buildable_pieces ) )
	{
		self.current_buildable_pieces = [];
	}
	self.current_buildable_pieces[ slot ] = piece;
}

player_can_take_piece( piece ) //checked matches cerberus output
{
	if ( !isDefined( piece ) )
	{
		return 0;
	}
	return 1;
}

dbline( from, to ) //checked matches cerberus output
{
	/*
/#
	time = 20;
	while ( time > 0 )
	{
		line( from, to, ( 0, 0, 1 ), 0, 1 );
		time -= 0.05;
		wait 0.05;
#/
	}
	*/
}

player_throw_piece( piece, origin, dir, return_to_spawn, return_time, endangles ) //checked changed to match cerberus output
{
	/*
/#
	assert( isDefined( piece ) );
#/
	*/
	if ( isDefined( piece ) )
	{
		/*
/#
		thread dbline( origin, origin + dir );
#/
		*/
		pass = 0;
		done = 0;
		altmodel = undefined;
		while ( pass < 2 && !done )
		{
			grenade = self magicgrenadetype( "buildable_piece_zm", origin, dir, 30000 );
			grenade thread watch_hit_players();
			grenade ghost();
			if ( !isDefined( altmodel ) )
			{
				altmodel = spawn( "script_model", grenade.origin );
				altmodel setmodel( piece.modelname );
			}
			altmodel.origin = grenade.angles;
			altmodel.angles = grenade.angles;
			altmodel linkto( grenade, "", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			grenade.altmodel = altmodel;
			grenade waittill( "stationary" );
			grenade_origin = grenade.origin;
			grenade_angles = grenade.angles;
			landed_on = grenade getgroundent();
			grenade delete();
			if ( isDefined( landed_on ) && landed_on == level )
			{
				done = 1;
			}
			else
			{
				origin = grenade_origin;
				dir = ( ( dir[ 0 ] * -1 ) / 10, ( dir[ 1 ] * -1 ) / 10, -1 );
				pass++;
			}
		}
		if ( !isDefined( endangles ) )
		{
			endangles = grenade_angles;
		}
		piece piece_spawn_at( grenade_origin, endangles );
		if ( isDefined( altmodel ) )
		{
			altmodel delete();
		}
		if ( isDefined( piece.ondrop ) )
		{
			piece [[ piece.ondrop ]]( self );
		}
		if ( is_true( return_to_spawn ) )
		{
			piece piece_wait_and_return( return_time );
		}
	}
}

watch_hit_players() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "stationary" );
	while ( isDefined( self ) )
	{
		self waittill( "grenade_bounce", pos, normal, ent );
		if ( isplayer( ent ) )
		{
			ent explosiondamage( 25, pos );
		}
	}
}

piece_wait_and_return( return_time ) //checked matches cerberus output
{
	self endon( "pickup" );
	wait 0.15;
	if ( isDefined( level.exploding_jetgun_fx ) )
	{
		playfxontag( level.exploding_jetgun_fx, self.model, "tag_origin" );
	}
	else
	{
		playfxontag( level._effect[ "powerup_on" ], self.model, "tag_origin" );
	}
	wait ( return_time - 6 );
	self piece_hide();
	wait 1;
	self piece_show();
	wait 1;
	self piece_hide();
	wait 1;
	self piece_show();
	wait 1;
	self piece_hide();
	wait 1;
	self piece_show();
	wait 1;
	self notify( "respawn" );
	self piece_unspawn();
	self piece_spawn_at();
}

player_return_piece_to_original_spawn( slot ) //checked matches cerberus output
{
	if ( !isDefined( slot ) )
	{
		slot = 0;
	}
	self notify( "piece_released" + slot );
	piece = self player_get_buildable_piece( slot );
	self player_set_buildable_piece( undefined, slot );
	if ( isDefined( piece ) )
	{
		piece piece_spawn_at();
		self clear_buildable_clientfield( slot );
	}
}

player_drop_piece_on_death( slot ) //checked matches cerberus output
{
	self notify( "piece_released" + slot );
	self endon( "piece_released" + slot );
	origin = self.origin;
	angles = self.angles;
	piece = self player_get_buildable_piece( slot );
	self waittill( "death_or_disconnect" );
	piece piece_spawn_at( origin, angles );
	if ( isDefined( self ) )
	{
		self clear_buildable_clientfield( slot );
	}
	if ( isDefined( piece.ondrop ) )
	{
		piece [[ piece.ondrop ]]( self );
	}
}

player_drop_piece( piece, slot ) //checked matches cerberus output
{
	if ( !isDefined( slot ) )
	{
		slot = 0;
	}
	if ( !isDefined( piece ) )
	{
		piece = self player_get_buildable_piece( slot );
	}
	else
	{
		slot = piece.buildable_slot;
	}
	if ( isDefined( piece ) )
	{
		origin = self.origin;
		origintrace = groundtrace( origin + vectorScale( ( 0, 0, 1 ), 5 ), origin - vectorScale( ( 0, 0, 1 ), 999999 ), 0, self );
		if ( isDefined( origintrace[ "entity" ] ) )
		{
			origintrace = groundtrace( origintrace[ "entity" ].origin, origintrace[ "entity" ].origin - vectorScale( ( 0, 0, 1 ), 999999 ), 0, origintrace[ "entity" ] );
		}
		if ( isDefined( origintrace[ "position" ] ) )
		{
			origin = origintrace[ "position" ];
		}
		piece.damage = 0;
		piece piece_spawn_at( origin, self.angles );
		if ( isplayer( self ) )
		{
			self clear_buildable_clientfield( slot );
		}
		if ( isDefined( piece.ondrop ) )
		{
			piece [[ piece.ondrop ]]( self );
		}
	}
	self player_set_buildable_piece( undefined, slot );
	self notify( "piece_released" + slot );
}

player_take_piece( piece ) //checked matches cerberus output
{
	piece_slot = piece.buildable_slot;
	damage = piece.damage;
	if ( isDefined( self player_get_buildable_piece( piece_slot ) ) )
	{
		other_piece = self player_get_buildable_piece( piece_slot );
		self player_drop_piece( self player_get_buildable_piece( piece_slot ), piece_slot );
		other_piece.damage = damage;
		self do_player_general_vox( "general", "build_swap" );
	}
	if ( isDefined( piece.onpickup ) )
	{
		piece [[ piece.onpickup ]]( self );
	}
	piece piece_unspawn();
	piece notify( "pickup" );
	if ( isplayer( self ) )
	{
		if ( isDefined( piece.client_field_state ) )
		{
			self set_buildable_clientfield( piece_slot, piece.client_field_state );
		}
		self player_set_buildable_piece( piece, piece_slot );
		self thread player_drop_piece_on_death( piece_slot );
		self track_buildable_piece_pickedup( piece );
	}
}

player_destroy_piece( piece ) //checked matches cerberus output
{
	if ( !isDefined( piece ) )
	{
		piece = self player_get_buildable_piece();
	}
	if ( isplayer( self ) )
	{
		slot = piece.buildable_slot;
		if ( isDefined( piece ) )
		{
			piece piece_destroy();
			self clear_buildable_clientfield( slot );
		}
		self player_set_buildable_piece( undefined, slot );
		self notify( "piece_released" + slot );
	}
}

claim_location( location ) //checked matches cerberus output
{
	if ( !isDefined( level.buildable_claimed_locations ) )
	{
		level.buildable_claimed_locations = [];
	}
	if ( !isDefined( level.buildable_claimed_locations[ location ] ) )
	{
		level.buildable_claimed_locations[ location ] = 1;
		return 1;
	}
	return 0;
}

is_point_in_build_trigger( point ) //checked changed to match cerberus output
{
	candidate_list = [];
	foreach ( zone in level.zones )
	{
		if ( isDefined( zone.unitrigger_stubs ) )
		{
			candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
		}
	}
	valid_range = 128;
	closest = maps/mp/zombies/_zm_unitrigger::get_closest_unitriggers( point, candidate_list, valid_range );
	for ( index = 0; index < closest.size; index++ )
	{
		if ( isDefined( closest[ index ].registered ) && closest[ index ].registered && isDefined( closest[ index ].piece ) )
		{
			return 1;
		}
	}
	return 0;
}

piece_allocate_spawn( piecespawn ) //checked changed to match cerberus output
{
	self.current_spawn = 0;
	self.managed_spawn = 1;
	self.piecespawn = piecespawn;
	if ( isDefined( piecespawn.str_force_spawn_kvp ) )
	{
		s_struct = patch_zm\common_scripts\utility::getstruct( piecespawn.str_force_spawn_name, piecespawn.str_force_spawn_kvp );
		if ( isDefined( s_struct ) )
		{
			for ( i = 0; i < self.spawns.size; i++ )
			{
				if ( s_struct == self.spawns[ i ] )
				{
					self.current_spawn = i;
					piecespawn.piece_allocated[ self.current_spawn ] = 1;
					piecespawn.str_force_spawn_kvp = undefined;
					piecespawn.str_force_spawn_name = undefined;
					return;
				}
			}
		}
	}
	else if ( isDefined( piecespawn.use_cyclic_spawns ) )
	{
		piece_allocate_cyclic( piecespawn );
		return;
	}
	if ( self.spawns.size >= 1 && self.spawns.size > 1 )
	{
		any_good = 0;
		any_okay = 0;
		totalweight = 0;
		spawnweights = [];
		for ( i = 0; i < self.spawns.size; i++ )
		{
			if ( isDefined( piecespawn.piece_allocated[ i ] ) && piecespawn.piece_allocated[ i ] )
			{
				spawnweights[ i ] = 0;
			}
			else if ( isDefined( self.spawns[ i ].script_forcespawn ) && self.spawns[ i ].script_forcespawn )
			{
				switch( self.spawns[ i ].script_forcespawn )
				{
					case 4:
						spawnweights[ i ] = 0;
						break;
					case 1:
						self.spawns[ i ].script_forcespawn = 0;
					case 2:
						self.current_spawn = i;
						piecespawn.piece_allocated[ self.current_spawn ] = 1;
						return;
					case 3:
						self.spawns[ i ].script_forcespawn = 4;
						self.current_spawn = i;
						piecespawn.piece_allocated[ self.current_spawn ] = 1;
						return;
					default:
						any_okay = 1;
						spawnweights[ i ] = 0.01;
						break;
				}
			}
			else if ( is_point_in_build_trigger( self.spawns[ i ].origin ) )
			{
				any_okay = 1;
				spawnweights[ i ] = 0.01;
				break;
			}
			else
			{
				any_good = 1;
				spawnweights[ i ] = 1;
			}
			totalweight += spawnweights[ i ];
		}
		/*
/#
		if ( !any_good )
		{
			assert( any_okay, "There is nowhere to spawn this piece" );
		}
#/
		*/
		if ( any_good )
		{
			totalweight = float( int( totalweight ) );
		}
		r = randomfloat( totalweight );
		for ( i = 0; i < self.spawns.size; i++ )
		{
			if ( !any_good || spawnweights[ i ] >= 1 )
			{
				r -= spawnweights[ i ];
				if ( r < 0 )
				{
					self.current_spawn = i;
					piecespawn.piece_allocated[ self.current_spawn ] = 1;
					return;
				}
			}
		}
		self.current_spawn = randomint( self.spawns.size );
		piecespawn.piece_allocated[ self.current_spawn ] = 1;
	}
}

piece_allocate_cyclic( piecespawn ) //checked matches cerberus output
{
	if ( self.spawns.size > 1 )
	{
		if ( isDefined( piecespawn.randomize_cyclic_index ) )
		{
			piecespawn.randomize_cyclic_index = undefined;
			piecespawn.cyclic_index = randomint( self.spawns.size );
		}
		if ( !isDefined( piecespawn.cyclic_index ) )
		{
			piecespawn.cyclic_index = 0;
		}
		piecespawn.cyclic_index++;
		if ( piecespawn.cyclic_index >= self.spawns.size )
		{
			piecespawn.cyclic_index = 0;
		}
	}
	else
	{
		piecespawn.cyclic_index = 0;
	}
	self.current_spawn = piecespawn.cyclic_index;
	piecespawn.piece_allocated[ self.current_spawn ] = 1;
}

piece_deallocate_spawn() //checked matches cerberus output
{
	if ( isDefined( self.current_spawn ) )
	{
		self.piecespawn.piece_allocated[ self.current_spawn ] = 0;
		self.current_spawn = undefined;
	}
	self.start_origin = undefined;
}

piece_pick_random_spawn() //checked partially changed to match cerberus output did not change while loop to for loop
{
	self.current_spawn = 0;
	if ( self.spawns.size >= 1 && self.spawns.size > 1 )
	{
		self.current_spawn = randomint( self.spawns.size );
		while ( isDefined( self.spawns[ self.current_spawn ].claim_location ) && !claim_location( self.spawns[ self.current_spawn ].claim_location ) )
		{
			arrayremoveindex( self.spawns, self.current_spawn );
			if ( self.spawns.size < 1 )
			{
				self.current_spawn = 0;
				/*
/#
				println( "ERROR: All buildable spawn locations claimed" );
#/
				*/
				return;
			}
			self.current_spawn = randomint( self.spawns.size );
		}
	}
}

piece_set_spawn( num ) //checked matches cerberus output
{
	self.current_spawn = 0;
	if ( self.spawns.size >= 1 && self.spawns.size > 1 )
	{
		self.current_spawn = int( min( num, self.spawns.size - 1 ) );
	}
}

piece_spawn_in( piecespawn ) //checked matches cerberus output
{
	if ( self.spawns.size < 1 )
	{
		return;
	}
	if ( is_true( self.managed_spawn ) )
	{
		if ( !isDefined( self.current_spawn ) )
		{
			self piece_allocate_spawn( self.piecespawn );
		}
	}
	if ( !isDefined( self.current_spawn ) )
	{
		self.current_spawn = 0;
	}
	spawndef = self.spawns[ self.current_spawn ];
	self.script_noteworthy = spawndef.script_noteworthy;
	self.script_parameters = spawndef.script_parameters;
	self.unitrigger = generate_piece_unitrigger( "trigger_radius_use", spawndef.origin + vectorScale( ( 0, 0, 1 ), 12 ), spawndef.angles, 0, piecespawn.radius, piecespawn.height, 0 );
	self.unitrigger.piece = self;
	self.buildable_slot = piecespawn.buildable_slot;
	self.radius = piecespawn.radius;
	self.height = piecespawn.height;
	self.buildablename = piecespawn.buildablename;
	self.modelname = piecespawn.modelname;
	self.hud_icon = piecespawn.hud_icon;
	self.part_name = piecespawn.part_name;
	self.drop_offset = piecespawn.drop_offset;
	self.start_origin = spawndef.origin;
	self.start_angles = spawndef.angles;
	self.client_field_state = piecespawn.client_field_state;
	self.hint_grab = piecespawn.hint_grab;
	self.hint_swap = piecespawn.hint_swap;
	self.model = spawn( "script_model", self.start_origin );
	if ( isDefined( self.start_angles ) )
	{
		self.model.angles = self.start_angles;
	}
	self.model setmodel( piecespawn.modelname );
	self.model ghostindemo();
	self.model.hud_icon = piecespawn.hud_icon;
	self.piecespawn = piecespawn;
	self.unitrigger.origin_parent = self.model;
	self.building = undefined;
	self.onunspawn = piecespawn.onunspawn;
	self.ondestroy = piecespawn.ondestroy;
	if ( isDefined( piecespawn.onspawn ) )
	{
		self.onspawn = piecespawn.onspawn;
		self [[ piecespawn.onspawn ]]();
	}
}

piece_spawn_at_with_notify_delay( origin, angles, str_notify, unbuild_respawn_fn ) //checked matches cerberus output
{
	level waittill( str_notify );
	piece_spawn_at( origin, angles );
	if ( isDefined( unbuild_respawn_fn ) )
	{
		self [[ unbuild_respawn_fn ]]();
	}
}

piece_spawn_at( origin, angles ) //checked changed to match cerberus output
{
	if ( self.spawns.size < 1 )
	{
		return;
	}
	if ( is_true( self.managed_spawn ) )
	{
		if ( !isDefined( self.current_spawn ) && !isDefined( origin ) )
		{
			self piece_allocate_spawn( self.piecespawn );
			spawndef = self.spawns[ self.current_spawn ];
			self.start_origin = spawndef.origin;
			self.start_angles = spawndef.angles;
		}
	}
	else if ( !isDefined( self.current_spawn ) )
	{
		self.current_spawn = 0;
	}
	unitrigger_offset = vectorScale( ( 0, 0, 1 ), 12 );
	if ( !isDefined( origin ) )
	{
		origin = self.start_origin;
	}
	else
	{
		origin += ( 0, 0, self.drop_offset );
		unitrigger_offset -= ( 0, 0, self.drop_offset );
	}
	if ( !isDefined( angles ) )
	{
		angles = self.start_angles;
	}
	/*
/#
	if ( !isDefined( level.drop_offset ) )
	{
		level.drop_offset = 0;
	}
	origin += ( 0, 0, level.drop_offset );
	unitrigger_offset -= ( 0, 0, level.drop_offset );
#/
	*/
	self.model = spawn( "script_model", origin );
	if ( isDefined( angles ) )
	{
		self.model.angles = angles;
	}
	self.model setmodel( self.modelname );
	if ( isDefined( level.equipment_safe_to_drop ) )
	{
		if ( ![[ level.equipment_safe_to_drop ]]( self.model ) )
		{
			origin = self.start_origin;
			angles = self.start_angles;
			self.model.origin = origin;
			self.model.angles = angles;
		}
	}
	if ( isDefined( self.model.canmove ) )
	{
		self.unitrigger = generate_piece_unitrigger( "trigger_radius_use", origin + unitrigger_offset, angles, 0, self.radius, self.height, self.model.canmove );
	}
	self.unitrigger.piece = self;
	self.model.hud_icon = self.hud_icon;
	self.unitrigger.origin_parent = self.model;
	self.building = undefined;
	if ( isDefined( self.onspawn ) )
	{
		self [[ self.onspawn ]]();
	}
}

piece_unspawn() //checked matches cerberus output
{
	if ( isDefined( self.onunspawn ) )
	{
		self [[ self.onunspawn ]]();
	}
	if ( is_true( self.managed_spawn ) )
	{
		self piece_deallocate_spawn();
	}
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

piece_hide() //checked matches cerberus output
{
	if ( isDefined( self.model ) )
	{
		self.model ghost();
	}
}

piece_show() //checked matches cerberus output
{
	if ( isDefined( self.model ) )
	{
		self.model show();
	}
}

piece_destroy() //checked matches cerberus output
{
	if ( isDefined( self.ondestroy ) )
	{
		self [[ self.ondestroy ]]();
	}
}

generate_piece( buildable_piece_spawns ) //checked changed to match cerberus output
{
	piece = spawnstruct();
	piece.spawns = buildable_piece_spawns.spawns;
	if ( isDefined( buildable_piece_spawns.managing_pieces ) && buildable_piece_spawns.managing_pieces )
	{
		piece piece_allocate_spawn( buildable_piece_spawns );
	}
	else if ( isDefined( buildable_piece_spawns.use_spawn_num ) )
	{
		piece piece_set_spawn( buildable_piece_spawns.use_spawn_num );
	}
	else
	{
		piece piece_pick_random_spawn();
	}
	piece piece_spawn_in( buildable_piece_spawns );
	if ( piece.spawns.size >= 1 )
	{
		piece.hud_icon = buildable_piece_spawns.hud_icon;
	}
	if ( isDefined( buildable_piece_spawns.onpickup ) )
	{
		piece.onpickup = buildable_piece_spawns.onpickup;
	}
	else
	{
		piece.onpickup = ::onpickuputs;
	}
	if ( isDefined( buildable_piece_spawns.ondrop ) )
	{
		piece.ondrop = buildable_piece_spawns.ondrop;
	}
	else
	{
		piece.ondrop = ::ondroputs;
	}
	return piece;
}

buildable_piece_unitriggers( buildable_name, origin ) //checked changed to match cerberus output
{
	/*
/#
	assert( isDefined( buildable_name ) );
#/
/#
	assert( isDefined( level.zombie_buildables[ buildable_name ] ), "Called buildable_think() without including the buildable - " + buildable_name );
#/
	*/
	buildable = level.zombie_buildables[ buildable_name ];
	if ( !isDefined( buildable.buildablepieces ) )
	{
		buildable.buildablepieces = [];
	}
	flag_wait( "start_zombie_round_logic" );
	buildablezone = spawnstruct();
	buildablezone.buildable_name = buildable_name;
	buildablezone.buildable_slot = buildable.buildable_slot;
	if ( !isDefined( buildablezone.pieces ) )
	{
		buildablezone.pieces = [];
	}
	buildablepickups = [];
	foreach ( buildablepiece in buildable.buildablepieces )
	{
		if ( !isDefined( buildablepiece.generated_instances ) )
		{
			buildablepiece.generated_instances = 0;
		}
		if ( isDefined( buildablepiece.generated_piece ) && is_true( buildablepiece.can_reuse ) )
		{
			piece = buildablepiece.generated_piece;
			break;
		}
		if ( buildablepiece.generated_instances >= buildablepiece.max_instances )
		{
			piece = buildablepiece.generated_piece;
			break;
		}
		piece = generate_piece( buildablepiece );
		buildablepiece.generated_piece = piece;
		buildablepiece.generated_instances++;
		if ( isDefined( buildablepiece.min_instances ) )
		{
			while ( buildablepiece.generated_instances < buildablepiece.min_instances )
			{
				piece = generate_piece( buildablepiece );
				buildablepiece.generated_piece = piece;
				buildablepiece.generated_instances++;
			}
		}
		buildablezone.pieces[ buildablezone.pieces.size ] = piece;
	}
	buildablezone.stub = self;
	return buildablezone;
}

hide_buildable_table_model( trigger_targetname ) //checked matches cerberus output
{
	trig = getent( trigger_targetname, "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	if ( isDefined( trig.target ) )
	{
		model = getent( trig.target, "targetname" );
		if ( isDefined( model ) )
		{
			model hide();
			model notsolid();
		}
	}
}

setup_unitrigger_buildable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked matches cerberus output
{
	trig = getent( trigger_targetname, "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	return setup_unitrigger_buildable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

setup_unitrigger_buildable_array( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked changed to match cerberus output
{
	triggers = getentarray( trigger_targetname, "targetname" );
	stubs = [];
	foreach ( trig in triggers )
	{
		stubs[ stubs.size ] = setup_unitrigger_buildable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
	}
	return stubs;
}

setup_unitrigger_buildable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked changed to match cerberus output
{
	if ( !isDefined( trig ) )
	{
		return;
	}
	unitrigger_stub = spawnstruct();
	unitrigger_stub.buildablestruct = level.zombie_include_buildables[ equipname ];
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
	unitrigger_stub.built = 0;
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
	if ( isDefined( level.zombie_buildables[ equipname ].hint ) )
	{
		unitrigger_stub.hint_string = level.zombie_buildables[ equipname ].hint;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::buildabletrigger_update_prompt;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buildable_place_think );
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
			unitrigger_stub.model hide();
			unitrigger_stub.model notsolid();
		}
	}
	unitrigger_stub.buildablezone = unitrigger_stub buildable_piece_unitriggers( equipname, unitrigger_stub.origin );
	if ( delete_trigger )
	{
		trig delete();
	}
	level.buildable_stubs[ level.buildable_stubs.size ] = unitrigger_stub;
	return unitrigger_stub;
}

buildable_has_piece( piece ) //checked changed to match cerberus output
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( self.pieces[ i ].modelname == piece.modelname && self.pieces[ i ].buildablename == piece.buildablename )
		{
			return 1;
		}
	}
	return 0;
}

buildable_set_piece_built( piece ) //checked changed to match cerberus output
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( self.pieces[ i ].modelname == piece.modelname && self.pieces[ i ].buildablename == piece.buildablename )
		{
			self.pieces[ i ].built = 1;
		}
	}
}

buildable_set_piece_building( piece ) //checked changed to match cerberus output
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( self.pieces[ i ].modelname == piece.modelname && self.pieces[ i ].buildablename == piece.buildablename )
		{
			self.pieces[ i ] = piece;
			self.pieces[ i ].building = 1;
		}
	}
}

buildable_clear_piece_building( piece ) //checked matches cerberus output
{
	if ( isDefined( piece ) )
	{
		piece.building = 0;
	}
}

buildable_is_piece_built( piece ) //checked partially changed to match cerberus output //changed at own discretion
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( self.pieces[ i ].modelname == piece.modelname && self.pieces[ i ].buildablename == piece.buildablename )
		{
			if ( isDefined( self.pieces[ i ].built ) && self.pieces[ i ].built )
			{
				return 1;
			}
		}
	}
	return 0;
}

buildable_is_piece_building( piece )
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( self.pieces[ i ].modelname == piece.modelname && self.pieces[ i ].buildablename == piece.buildablename )
		{
			if ( isDefined( self.pieces[ i ].building ) && self.pieces[ i ].building && self.pieces[ i ] == piece )
			{
				return 1;
			}
		}
	}
	return 0;
}

buildable_is_piece_built_or_building( piece ) //checked partially changed to match cerberus output //changed at own discretion
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( self.pieces[ i ].modelname == piece.modelname && self.pieces[ i ].buildablename == piece.buildablename )
		{
			if ( !is_true( self.pieces[ i ].built ) )
			{
				if ( is_true( self.pieces[ i ].building ) )
				{
					return 1;
				}
			}
		}
		i++;
	}
	return 0;
}

buildable_all_built() //checked changed to match cerberus output
{
	for ( i = 0; i < self.pieces.size; i++ )
	{
		if ( !is_true( self.pieces[ i ].built ) )
		{
			return 0;
		}
	}
	return 1;
}

player_can_build( buildable, continuing ) //checked changed to match cerberus output
{
	if ( !isDefined( buildable ) )
	{
		return 0;
	}
	if ( !isDefined( self player_get_buildable_piece( buildable.buildable_slot ) ) )
	{
		return 0;
	}
	if ( !buildable buildable_has_piece( self player_get_buildable_piece( buildable.buildable_slot ) ) )
	{
		return 0;
	}
	if ( is_true( continuing ) )
	{
		if ( buildable buildable_is_piece_built( self player_get_buildable_piece( buildable.buildable_slot ) ) )
		{
			return 0;
		}
	}
	else if ( buildable buildable_is_piece_built_or_building( self player_get_buildable_piece( buildable.buildable_slot ) ) )
	{
		return 0;
	}
	if ( isDefined( buildable.stub ) && isDefined( buildable.stub.custom_buildablestub_update_prompt ) && isDefined( buildable.stub.playertrigger[ 0 ] ) && isDefined( buildable.stub.playertrigger[ 0 ].stub ) && !( buildable.stub.playertrigger[ 0 ].stub [[ buildable.stub.custom_buildablestub_update_prompt ]]( self, 1, buildable.stub.playertrigger[ 0 ] ) ) )
	{
		return 0;
	}
	return 1;
}

player_build( buildable, pieces ) //checked partially changed to match cerberus output 
{
	if ( isDefined( pieces ) )
	{
		for ( i = 0; i < pieces.size; i++ )
		{
			buildable buildable_set_piece_built( pieces[ i ] );
			player_destroy_piece( pieces[ i ] );
		}
	}
	else
	{
		buildable buildable_set_piece_built( self player_get_buildable_piece( buildable.buildable_slot ) );
		player_destroy_piece( self player_get_buildable_piece( buildable.buildable_slot ) );
	}
	if ( isDefined( buildable.stub.model ) )
	{
		i = 0;
		while ( i < buildable.pieces.size )
		{
			if ( isDefined( buildable.pieces[ i ].part_name ) )
			{
				buildable.stub.model notsolid();
				if ( !is_true( buildable.pieces[ i ].built ) )
				{
					buildable.stub.model hidepart( buildable.pieces[ i ].part_name );
					i++;
					continue;
				}
				buildable.stub.model show();
				buildable.stub.model showpart( buildable.pieces[ i ].part_name );
			}
			i++;
		}
	}
	else if ( isplayer( self ) )
	{
		self track_buildable_pieces_built( buildable );
	}
	if ( buildable buildable_all_built() )
	{
		self player_finish_buildable( buildable );
		buildable.stub buildablestub_finish_build( self );
		if ( isplayer( self ) )
		{
			self track_buildables_built( buildable );
		}
		if ( isDefined( level.buildable_built_custom_func ) )
		{
			self thread [[ level.buildable_built_custom_func ]]( buildable );
		}
		alias = sndbuildablecompletealias( buildable.buildable_name );
		self playsound( alias );
	}
	else
	{
		self playsound( "zmb_buildable_piece_add" );
		/*
/#
		assert( isDefined( level.zombie_buildables[ buildable.buildable_name ].building ), "Missing builing hint" );
#/
		*/
		if ( isDefined( level.zombie_buildables[ buildable.buildable_name ].building ) )
		{
			return level.zombie_buildables[ buildable.buildable_name ].building;
		}
	}
	return "";
}

sndbuildablecompletealias( name ) //checked matches cerberus output
{
	alias = undefined;
	switch( name )
	{
		case "chalk":
			alias = "zmb_chalk_complete";
			break;
		default:
			alias = "zmb_buildable_complete";
			break;
	}
	return alias;
}

player_finish_buildable( buildable ) //checked matches cerberus output
{
	buildable.built = 1;
	buildable.stub.built = 1;
	buildable notify( "built" );
	level.buildables_built[ buildable.buildable_name ] = 1;
	level notify( buildable.buildable_name + "_built" );
}

buildablestub_finish_build( player ) //checked matches cerberus output
{
	player player_finish_buildable( self.buildablezone );
}

buildablestub_remove() //checked matches cerberus output
{
	arrayremovevalue( level.buildable_stubs, self );
}

buildabletrigger_update_prompt( player ) //checked matches cerberus output
{
	can_use = self.stub buildablestub_update_prompt( player );
	self sethintstring( self.stub.hint_string );
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

buildablestub_update_prompt( player ) //checked changed to match cerberus output
{
	if ( !self anystub_update_prompt( player ) )
	{
		return 0;
	}
	can_use = 1;
	if ( isDefined( self.buildablestub_reject_func ) )
	{
		rval = self [[ self.buildablestub_reject_func ]]( player );
		if ( rval )
		{
			return 0;
		}
	}
	if ( isDefined( self.custom_buildablestub_update_prompt ) && !self [[ self.custom_buildablestub_update_prompt ]]( player ) )
	{
		return 0;
	}
	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		slot = self.buildablestruct.buildable_slot;
		if ( !isDefined( player player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}
			return 0;
		}
		else if ( !self.buildablezone buildable_has_piece( player player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
			}
			return 0;
		}
		else
		{
			/*
		/#
			assert( isDefined( level.zombie_buildables[ self.equipname ].hint ), "Missing buildable hint" );
		#/
			*/
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint;
			}
			else
			{
				self.hint_string = "Missing buildable hint";
			}
		}
	}
	else if ( self.persistent == 1 )
	{
		if ( maps/mp/zombies/_zm_equipment::is_limited_equipment( self.weaponname ) && maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.weaponname ) )
		{
			self.hint_string = &"ZOMBIE_BUILD_PIECE_ONLY_ONE";
			return 0;
		}
		if ( player has_player_equipment( self.weaponname ) )
		{
			self.hint_string = &"ZOMBIE_BUILD_PIECE_HAVE_ONE";
			return 0;
		}
		/*
		if ( getDvarInt( #"1F0A2129" ) )
		{
			self.cursor_hint = "HINT_WEAPON";
			self.cursor_hint_weapon = self.weaponname;
		}
		*/
		self.hint_string = self.trigger_hintstring;
	}
	else if ( self.persistent == 2 )
	{
		if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.weaponname, undefined ) )
		{
			self.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
			return 0;
		}
		else if ( is_true( self.bought ) )
		{
			self.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
			return 0;
		}
		self.hint_string = self.trigger_hintstring;
	}
	else
	{
		self.hint_string = "";
		return 0;
	}
	return 1;
}

player_continue_building( buildablezone, build_stub ) //checked matches cerberus output
{
	if ( !isDefined( build_stub ) )
	{
		build_stub = buildablezone.stub;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || self maps/mp/zombies/_zm_utility::in_revive_trigger() )
	{
		return 0;
	}
	if ( self isthrowinggrenade() )
	{
		return 0;
	}
	if ( !self player_can_build( buildablezone, 1 ) )
	{
		return 0;
	}
	if ( isDefined( self.screecher ) )
	{
		return 0;
	}
	if ( !self usebuttonpressed() )
	{
		return 0;
	}
	slot = build_stub.buildablestruct.buildable_slot;
	if ( !buildablezone buildable_is_piece_building( self player_get_buildable_piece( slot ) ) )
	{
		return 0;
	}
	trigger = build_stub maps/mp/zombies/_zm_unitrigger::unitrigger_trigger( self );
	if ( build_stub.script_unitrigger_type == "unitrigger_radius_use" )
	{
		torigin = build_stub unitrigger_origin();
		porigin = self geteye();
		radius_sq = 2.25 * build_stub.test_radius_sq;
		if ( distance2dsquared( torigin, porigin ) > radius_sq )
		{
			return 0;
		}
	}
	else
	{
		if ( !isDefined( trigger ) || !trigger istouching( self ) )
		{
			return 0;
		}
	}
	if ( is_true( build_stub.require_look_at ) && !self is_player_looking_at( trigger.origin, 0.4 ) )
	{
		return 0;
	}
	return 1;
}

player_progress_bar_update( start_time, build_time ) //checked partially matches cerberus output but order of operations may need to be adjusted
{
	self endon( "entering_last_stand" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "buildable_progress_end" );
	while ( isDefined( self ) && ( getTime() - start_time ) < build_time )
	{
		progress = ( getTime() - start_time ) / build_time;
		if ( progress < 0 )
		{
			progress = 0;
		}
		if ( progress > 1 )
		{
			progress = 1;
		}
		self.usebar updatebar( progress );
		wait 0.05;
	}
}

player_progress_bar( start_time, build_time, building_prompt ) //checked matches cerberus output
{
	self.usebar = self createprimaryprogressbar();
	self.usebartext = self createprimaryprogressbartext();
	if ( isDefined( building_prompt ) )
	{
		self.usebartext settext( building_prompt );
	}
	else
	{
		self.usebartext settext( &"ZOMBIE_BUILDING" );
	}
	if ( isDefined( self ) && isDefined( start_time ) && isDefined( build_time ) )
	{
		self player_progress_bar_update( start_time, build_time );
	}
	self.usebartext destroyelem();
	self.usebar destroyelem();
}

buildable_use_hold_think_internal( player, bind_stub ) //checked changed to match cerberus output order of operations may need to be checked
{
	if ( !isDefined( bind_stub ) )
	{
		bind_stub = self.stub;
	}
	wait 0.01;
	if ( !isDefined( self ) )
	{
		self notify( "build_failed" );
		if ( isDefined( player.buildableaudio ) )
		{
			player.buildableaudio delete();
			player.buildableaudio = undefined;
		}
		return;
	}
	if ( !isDefined( self.usetime ) )
	{
		self.usetime = int( 3000 );
	}
	self.build_time = self.usetime;
	self.build_start_time = getTime();
	build_time = self.build_time;
	build_start_time = self.build_start_time;
	player disable_player_move_states( 1 );
	player increment_is_drinking();
	orgweapon = player getcurrentweapon();
	build_weapon = "zombie_builder_zm";
	if ( isDefined( bind_stub.build_weapon ) )
	{
		build_weapon = bind_stub.build_weapon;
	}
	player giveweapon( build_weapon );
	player switchtoweapon( build_weapon );
	slot = bind_stub.buildablestruct.buildable_slot;
	bind_stub.buildablezone buildable_set_piece_building( player player_get_buildable_piece( slot ) );
	player thread player_progress_bar( build_start_time, build_time, bind_stub.building_prompt );
	if ( isDefined( level.buildable_build_custom_func ) )
	{
		player thread [[ level.buildable_build_custom_func ]]( self.stub );
	}
	while ( isDefined( self ) && player player_continue_building( bind_stub.buildablezone, self.stub ) && ( getTime() - self.build_start_time ) < self.build_time )
	{
		wait 0.05;
	}
	player notify( "buildable_progress_end" );
	player maps/mp/zombies/_zm_weapons::switch_back_primary_weapon( orgweapon );
	player takeweapon( "zombie_builder_zm" );
	if ( is_true( player.is_drinking ) )
	{
		player decrement_is_drinking();
	}
	player enable_player_move_states();
	if ( isDefined( self ) && player player_continue_building( bind_stub.buildablezone, self.stub ) && ( getTime() - self.build_start_time ) >= self.build_time )
	{
		buildable_clear_piece_building( player player_get_buildable_piece( slot ) );
		self notify( "build_succeed" );
	}
	else if ( isDefined( player.buildableaudio ) )
	{
		player.buildableaudio delete();
		player.buildableaudio = undefined;
	}
	buildable_clear_piece_building( player player_get_buildable_piece( slot ) );
	self notify( "build_failed" );
}

buildable_play_build_fx( player ) //checked matches cerberus output
{
	self endon( "kill_trigger" );
	self endon( "build_succeed" );
	self endon( "build_failed" );
	while ( 1 )
	{
		playfx( level._effect[ "building_dust" ], player getplayercamerapos(), player.angles );
		wait 0.5;
	}
}

buildable_use_hold_think( player, bind_stub ) //checked matches cerberus output
{
	if ( !isDefined( bind_stub ) )
	{
		bind_stub = self.stub;
	}
	self thread buildable_play_build_fx( player );
	self thread buildable_use_hold_think_internal( player, bind_stub );
	retval = self waittill_any_return( "build_succeed", "build_failed" );
	if ( retval == "build_succeed" )
	{
		return 1;
	}
	return 0;
}

buildable_place_think() //checked partially changed to match cerberus output //changed at own discretion
{
	self endon( "kill_trigger" );
	player_built = undefined;
	while ( !is_true( self.stub.built ) )
	{
		self waittill( "trigger", player );
		if ( player != self.parent_player )
		{
			continue;
		}
		if ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
		}
		status = player player_can_build( self.stub.buildablezone );
		if ( !status )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			if ( isDefined( self.stub.oncantuse ) )
			{
				self.stub [[ self.stub.oncantuse ]]( player );
			}
			//continue;
		}
		else if ( isDefined( self.stub.onbeginuse ) )
		{
			self.stub [[ self.stub.onbeginuse ]]( player );
		}
		result = self buildable_use_hold_think( player );
		team = player.pers[ "team" ];
		if ( isDefined( self.stub.onenduse ) )
		{
			self.stub [[ self.stub.onenduse ]]( team, player, result );
		}
		if ( !result )
		{
			continue;
		}
		if ( isDefined( self.stub.onuse ) )
		{
			self.stub [[ self.stub.onuse ]]( player );
		}
		slot = self.stub.buildablestruct.buildable_slot;
		if ( isDefined( player player_get_buildable_piece( slot ) ) )
		{
			prompt = player player_build( self.stub.buildablezone );
			player_built = player;
			self.stub.hint_string = prompt;
		}
		self sethintstring( self.stub.hint_string );
	}
	if ( isDefined( player_built ) )
	{
		switch( self.stub.persistent )
		{
			case 1:
				self bptrigger_think_persistent( player_built );
				break;
			case 0:
				self bptrigger_think_one_time( player_built );
				break;
			case 3:
				self bptrigger_think_unbuild( player_built );
				break;
			case 2:
				self bptrigger_think_one_use_and_fly( player_built );
				break;
			case 4:
				self [[ self.stub.custom_completion_callback ]]( player_built );
				break;
		}
	}
}

bptrigger_think_one_time( player_built ) //checked matches cerberus output
{
	self.stub buildablestub_remove();
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.stub );
}

bptrigger_think_unbuild( player_built ) //checked matches cerberus output
{
	stub_unbuild_buildable( self.stub, 1 );
}

bptrigger_think_one_use_and_fly( player_built ) //checked changed to match cerberus output
{
	if ( isDefined( player_built ) )
	{
		self buildabletrigger_update_prompt( player_built );
	}
	if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
	{
		self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
		self sethintstring( self.stub.hint_string );
		return;
	}
	if ( is_true( self.stub.bought ) )
	{
		self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
		self sethintstring( self.stub.hint_string );
		return;
	}
	if ( isDefined( self.stub.model ) )
	{
		self.stub.model notsolid();
		self.stub.model show();
	}
	while ( self.stub.persistent == 2 )
	{
		self waittill( "trigger", player );
		if ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
		{
			self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
			self sethintstring( self.stub.hint_string );
			return;
		}
		if ( !is_true( self.stub.built ) )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			return;
		}
		if ( player != self.parent_player )
		{
			continue;
		}
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		self.stub.bought = 1;
		if ( isDefined( self.stub.model ) )
		{
			self.stub.model thread model_fly_away();
		}
		player maps/mp/zombies/_zm_weapons::weapon_give( self.stub.weaponname );
		if ( isDefined( level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ) )
		{
			self [[ level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ]]( player );
		}
		if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
		{
			self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
		}
		else
		{
			self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
		}
		self sethintstring( self.stub.hint_string );
		player track_buildables_pickedup( self.stub.weaponname );
	}
}

bptrigger_think_persistent( player_built ) //checked changed to match cerberus output
{
	if ( !isDefined( player_built ) || self [[ self.stub.prompt_and_visibility_func ]]( player_built ) )
	{
		if ( isDefined( self.stub.model ) )
		{
			self.stub.model notsolid();
			self.stub.model show();
		}
		while ( self.stub.persistent == 1 )
		{
			self waittill( "trigger", player );
			if ( isDefined( player.screecher_weapon ) )
			{
				continue;
			}
			if ( !is_true( self.stub.built ) )
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
				self setcursorhint( "HINT_NOICON" );
				return;
			}
			if ( player != self.parent_player )
			{
				continue;
			}
			if ( !is_player_valid( player ) )
			{
				player thread ignore_triggers( 0.5 );
			}
			if ( player has_player_equipment( self.stub.weaponname ) )
			{
				continue;
			}
			if ( isDefined( self.stub.buildablestruct.onbought ) )
			{
				self [[ self.stub.buildablestruct.onbought ]]( player );
				continue;
			}
			else if ( !maps/mp/zombies/_zm_equipment::is_limited_equipment( self.stub.weaponname ) || !maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.stub.weaponname ) )
			{
				player maps/mp/zombies/_zm_equipment::equipment_buy( self.stub.weaponname );
				player giveweapon( self.stub.weaponname );
				player setweaponammoclip( self.stub.weaponname, 1 );
				if ( isDefined( level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ) )
				{
					self [[ level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ]]( player );
				}
				if ( self.stub.weaponname != "keys_zm" )
				{
					player setactionslot( 1, "weapon", self.stub.weaponname );
				}
				self.stub.cursor_hint = "HINT_NOICON";
				self.stub.cursor_hint_weapon = undefined;
				self setcursorhint( self.stub.cursor_hint );
				if ( isDefined( level.zombie_buildables[ self.stub.equipname ].bought ) )
				{
					self.stub.hint_string = level.zombie_buildables[ self.stub.equipname ].bought;
				}
				else
				{
					self.stub.hint_string = "";
				}
				self sethintstring( self.stub.hint_string );
				player track_buildables_pickedup( self.stub.weaponname );
			}
			else
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
				self.stub.cursor_hint = "HINT_NOICON";
				self.stub.cursor_hint_weapon = undefined;
				self setcursorhint( self.stub.cursor_hint );
			}
		}
	}
}

bptrigger_think_unbuild_no_return( player ) //checked matches cerberus output
{
	stub_unbuild_buildable( self.stub, 0 );
}

bpstub_set_custom_think_callback( callback ) //checked matches cerberus output
{
	self.persistent = 4;
	self.custom_completion_callback = callback;
}

model_fly_away() //checked changed to match cerberus output
{
	self moveto( self.origin + vectorScale( ( 0, 0, 1 ), 40 ), 3 );
	direction = self.origin;
	direction = ( direction[ 1 ], direction[ 0 ], 0 );
	if ( direction[ 1 ] < 0 || direction[ 0 ] > 0 && direction[ 1 ] > 0 )
	{
		direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
	}
	else if ( direction[ 0 ] < 0 )
	{
		direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
	}
	self vibrate( direction, 10, 0.5, 4 );
	self waittill( "movedone" );
	self hide();
	playfx( level._effect[ "poltergeist" ], self.origin );
}

find_buildable_stub( equipname ) //checked changed to match cerberus output
{
	foreach ( stub in level.buildable_stubs )
	{
		if ( stub.equipname == equipname )
		{
			return stub;
		}
	}
	return undefined;
}

unbuild_buildable( equipname, return_pieces, origin, angles ) //checked matches cerberus output
{
	stub = find_buildable_stub( equipname );
	stub_unbuild_buildable( stub, return_pieces, origin, angles );
}

stub_unbuild_buildable( stub, return_pieces, origin, angles ) //checked partially changed to match cerberus output //did not change while loop to for loop
{
	if ( isDefined( stub ) )
	{
		buildable = stub.buildablezone;
		buildable.built = 0;
		buildable.stub.built = 0;
		buildable notify( "unbuilt" );
		level.buildables_built[ buildable.buildable_name ] = 0;
		level notify( buildable.buildable_name + "_unbuilt" );
		i = 0;
		while ( i < buildable.pieces.size )
		{
			buildable.pieces[ i ].built = 0;
			if ( isDefined( buildable.pieces[ i ].part_name ) )
			{
				buildable.stub.model notsolid();
				if ( is_true( buildable.pieces[ i ].built ) )
				{
					buildable.stub.model hidepart( buildable.pieces[ i ].part_name );
				}
				else
				{
					buildable.stub.model show();
					buildable.stub.model showpart( buildable.pieces[ i ].part_name );
				}
			}
			if ( is_true( return_pieces ) )
			{
				if ( isDefined( buildable.stub.str_unbuild_notify ) )
				{
					buildable.pieces[ i ] thread piece_spawn_at_with_notify_delay( origin, angles, buildable.stub.str_unbuild_notify, buildable.stub.unbuild_respawn_fn );
					i++;
					continue;
				}
				buildable.pieces[ i ] piece_spawn_at( origin, angles );
			}
			i++;
		}
		if ( isDefined( buildable.stub.model ) )
		{
			buildable.stub.model hide();
		}
	}
}

player_explode_buildable( equipname, origin, speed, return_to_spawn, return_time ) //checked changed to match cerberus output
{
	self explosiondamage( 50, origin );
	stub = find_buildable_stub( equipname );
	if ( isDefined( stub ) )
	{
		buildable = stub.buildablezone;
		buildable.built = 0;
		buildable.stub.built = 0;
		buildable notify( "unbuilt" );
		level.buildables_built[ buildable.buildable_name ] = 0;
		level notify( buildable.buildable_name + "_unbuilt" );
		for ( i = 0; i < buildable.pieces.size; i++ )
		{
			buildable.pieces[ i ].built = 0;
			if ( isDefined( buildable.pieces[ i ].part_name ) )
			{
				buildable.stub.model notsolid();
				if ( !is_true( buildable.pieces[ i ].built ) )
				{
					buildable.stub.model hidepart( buildable.pieces[ i ].part_name );
				}
				else
				{
					buildable.stub.model show();
					buildable.stub.model showpart( buildable.pieces[ i ].part_name );
				}
			}
			ang = randomfloat( 360 );
			h = 0.25 + randomfloat( 0.5 );
			dir = ( sin( ang ), cos( ang ), h );
			self thread player_throw_piece( buildable.pieces[ i ], origin, speed * dir, return_to_spawn, return_time );
		}
		buildable.stub.model hide();
	}
}

think_buildables() //checked changed to match cerberus output
{
	foreach ( buildable in level.zombie_include_buildables )
	{
		if ( isDefined( buildable.triggerthink ) )
		{
			level [[ buildable.triggerthink ]]();
			wait_network_frame();
		}
	}
	level notify( "buildables_setup" );
}

buildable_trigger_think( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked matches cerberus output
{
	return setup_unitrigger_buildable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

buildable_trigger_think_array( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked matches cerberus output
{
	return setup_unitrigger_buildable_array( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

buildable_set_unbuild_notify_delay( str_equipname, str_unbuild_notify, unbuild_respawn_fn ) //checked matches cerberus output
{
	stub = find_buildable_stub( str_equipname );
	stub.str_unbuild_notify = str_unbuild_notify;
	stub.unbuild_respawn_fn = unbuild_respawn_fn;
}

setup_vehicle_unitrigger_buildable( parent, trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked matches cerberus output
{
	trig = getent( trigger_targetname, "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	unitrigger_stub = spawnstruct();
	unitrigger_stub.buildablestruct = level.zombie_include_buildables[ equipname ];
	unitrigger_stub.link_parent = parent;
	unitrigger_stub.origin_parent = trig;
	unitrigger_stub.trigger_targetname = trigger_targetname;
	unitrigger_stub.originfunc = ::anystub_get_unitrigger_origin;
	unitrigger_stub.onspawnfunc = ::anystub_on_spawn_trigger;
	unitrigger_stub.origin = trig.origin;
	unitrigger_stub.angles = trig.angles;
	unitrigger_stub.equipname = equipname;
	unitrigger_stub.weaponname = weaponname;
	unitrigger_stub.trigger_hintstring = trigger_hintstring;
	unitrigger_stub.delete_trigger = delete_trigger;
	unitrigger_stub.built = 0;
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
		unitrigger_stub.script_length = 24;
	}
	if ( isDefined( trig.script_width ) )
	{
		unitrigger_stub.script_width = trig.script_width;
	}
	else
	{
		unitrigger_stub.script_width = 64;
	}
	if ( isDefined( trig.script_height ) )
	{
		unitrigger_stub.script_height = trig.script_height;
	}
	else
	{
		unitrigger_stub.script_height = 24;
	}
	if ( isDefined( trig.radius ) )
	{
		unitrigger_stub.radius = trig.radius;
	}
	else
	{
		unitrigger_stub.radius = 64;
	}
	unitrigger_stub.target = trig.target;
	unitrigger_stub.targetname = trig.targetname + "_trigger";
	unitrigger_stub.script_noteworthy = trig.script_noteworthy;
	unitrigger_stub.script_parameters = trig.script_parameters;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( isDefined( level.zombie_buildables[ equipname ].hint ) )
	{
		unitrigger_stub.hint_string = level.zombie_buildables[ equipname ].hint;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::buildabletrigger_update_prompt;
	maps/mp/zombies/_zm_unitrigger::register_unitrigger( unitrigger_stub, ::buildable_place_think );
	unitrigger_stub.piece_trigger = trig;
	trig.trigger_stub = unitrigger_stub;
	unitrigger_stub.buildablezone = unitrigger_stub buildable_piece_unitriggers( equipname, unitrigger_stub.origin );
	if ( delete_trigger )
	{
		trig delete();
	}
	level.buildable_stubs[ level.buildable_stubs.size ] = unitrigger_stub;
	return unitrigger_stub;
}

vehicle_buildable_trigger_think( vehicle, trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) //checked matches cerberus output
{
	return setup_vehicle_unitrigger_buildable( vehicle, trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

ai_buildable_trigger_think( parent, equipname, weaponname, trigger_hintstring, persistent ) //checked matches cerberus output
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.buildablestruct = level.zombie_include_buildables[ equipname ];
	unitrigger_stub.link_parent = parent;
	unitrigger_stub.origin_parent = parent;
	unitrigger_stub.originfunc = ::anystub_get_unitrigger_origin;
	unitrigger_stub.onspawnfunc = ::anystub_on_spawn_trigger;
	unitrigger_stub.origin = parent.origin;
	unitrigger_stub.angles = parent.angles;
	unitrigger_stub.equipname = equipname;
	unitrigger_stub.weaponname = weaponname;
	unitrigger_stub.trigger_hintstring = trigger_hintstring;
	unitrigger_stub.delete_trigger = 1;
	unitrigger_stub.built = 0;
	unitrigger_stub.persistent = persistent;
	unitrigger_stub.usetime = int( 3000 );
	unitrigger_stub.onbeginuse = ::onbeginuseuts;
	unitrigger_stub.onenduse = ::onenduseuts;
	unitrigger_stub.onuse = ::onuseplantobjectuts;
	unitrigger_stub.oncantuse = ::oncantuseuts;
	unitrigger_stub.script_length = 64;
	unitrigger_stub.script_width = 64;
	unitrigger_stub.script_height = 54;
	unitrigger_stub.radius = 64;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( isDefined( level.zombie_buildables[ equipname ].hint ) )
	{
		unitrigger_stub.hint_string = level.zombie_buildables[ equipname ].hint;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	unitrigger_stub.require_look_at = 0;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::buildabletrigger_update_prompt;
	maps/mp/zombies/_zm_unitrigger::register_unitrigger( unitrigger_stub, ::buildable_place_think );
	unitrigger_stub.buildablezone = unitrigger_stub buildable_piece_unitriggers( equipname, unitrigger_stub.origin );
	level.buildable_stubs[ level.buildable_stubs.size ] = unitrigger_stub;
	return unitrigger_stub;
}

onpickuputs( player ) //checked matches cerberus output
{
	/*
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Buildable piece recovered by - " + player.name );
#/
	}
	*/
}

ondroputs( player ) //checked matches cerberus output
{
	/*
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Buildable piece dropped by - " + player.name );
#/
	}
	*/
	player notify( "event_ended" );
}

onbeginuseuts( player ) //checked matches cerberus output
{
	/*
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Buildable piece begin use by - " + player.name );
#/
	}
	*/
	if ( isDefined( self.buildablestruct.onbeginuse ) )
	{
		self [[ self.buildablestruct.onbeginuse ]]( player );
	}
	if ( isDefined( player ) && !isDefined( player.buildableaudio ) )
	{
		alias = sndbuildableusealias( self.targetname );
		player.buildableaudio = spawn( "script_origin", player.origin );
		player.buildableaudio playloopsound( alias );
	}
}

sndbuildableusealias( name ) //checked matches cerberus output
{
	alias = undefined;
	switch( name )
	{
		case "cell_door_trigger":
			alias = "zmb_jail_buildable";
			break;
		case "generator_use_trigger":
			alias = "zmb_generator_buildable";
			break;
		case "chalk_buildable_trigger":
			alias = "zmb_chalk_loop";
			break;
		default:
			alias = "zmb_buildable_loop";
			break;
	}
	return alias;
}

onenduseuts( team, player, result ) //checked matches cerberus output
{
	/*
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Buildable piece end use by - " + player.name );
#/
	}
	*/
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( isDefined( player.buildableaudio ) )
	{
		player.buildableaudio delete();
		player.buildableaudio = undefined;
	}
	if ( isDefined( self.buildablestruct.onenduse ) )
	{
		self [[ self.buildablestruct.onenduse ]]( team, player, result );
	}
	player notify( "event_ended" );
}
 
oncantuseuts( player ) //checked matches cerberus output
{
	/*
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Buildable piece can't use by - " + player.name );
#/
	}
	*/
	if ( isDefined( self.buildablestruct.oncantuse ) )
	{
		self [[ self.buildablestruct.oncantuse ]]( player );
	}
}

onuseplantobjectuts( player ) //checked matches cerberus output
{
	/*
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Buildable piece crafted by - " + player.name );
#/
	}
	*/
	if ( isDefined( self.buildablestruct.onuseplantobject ) )
	{
		self [[ self.buildablestruct.onuseplantobject ]]( player );
	}
	player notify( "bomb_planted" );
}

add_zombie_buildable_vox_category( buildable_name, vox_id ) //checked matches cerberus output
{
	buildable_struct = level.zombie_include_buildables[ buildable_name ];
	buildable_struct.vox_id = vox_id;
}

add_zombie_buildable_piece_vox_category( buildable_name, vox_id, timer ) //checked matches cerberus output
{
	buildable_struct = level.zombie_include_buildables[ buildable_name ];
	buildable_struct.piece_vox_id = vox_id;
	buildable_struct.piece_vox_timer = timer;
}

is_buildable() //checked matches cerberus output
{
	if ( !isDefined( level.zombie_buildables ) )
	{
		return 0;
	}
	if ( isDefined( self.zombie_weapon_upgrade ) && isDefined( level.zombie_buildables[ self.zombie_weapon_upgrade ] ) )
	{
		return 1;
	}
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "specialty_weapupgrade" )
	{
		if ( isDefined( level.buildables_built[ "pap" ] ) && level.buildables_built[ "pap" ] )
		{
			return 0;
		}
		return 1;
	}
	return 0;
}

buildable_crafted() //checked matches cerberus output
{
	self.pieces--;

}

buildable_complete() //checked matches cerberus output
{
	if ( self.pieces <= 0 )
	{
		return 1;
	}
	return 0;
}

get_buildable_hint( buildable_name ) //checked matches cerberus output
{
	/*
/#
	assert( isDefined( level.zombie_buildables[ buildable_name ] ), buildable_name + " was not included or is not part of the zombie weapon list." );
#/
	*/
	return level.zombie_buildables[ buildable_name ].hint;
}

delete_on_disconnect( buildable, self_notify, skip_delete ) //checked matches cerberus output
{
	buildable endon( "death" );
	self waittill( "disconnect" );
	if ( isDefined( self_notify ) )
	{
		self notify( self_notify );
	}
	if ( isDefined( skip_delete ) && !skip_delete )
	{
		if ( isDefined( buildable.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( buildable.stub );
			buildable.stub = undefined;
		}
		if ( isDefined( buildable ) )
		{
			buildable delete();
		}
	}
}

get_buildable_pickup( buildablename, modelname ) //checked changed to match cerberus output
{
	foreach ( buildablepickup in level.buildablepickups )
	{
		if ( buildablepickup[ 0 ].buildablestruct.name == buildablename && buildablepickup[ 0 ].visuals[ 0 ].model == modelname )
		{
			return buildablepickup[ 0 ];
		}
	}
	return undefined;
}

track_buildable_piece_pickedup( piece ) //checked matches cerberus output
{
	if ( !isDefined( piece ) || !isDefined( piece.buildablename ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_buildable_piece_pickedup() \n" );
#/
		*/
		return;
	}
	self add_map_buildable_stat( piece.buildablename, "pieces_pickedup", 1 );
	buildable_struct = level.zombie_include_buildables[ piece.buildablename ];
	if ( isDefined( buildable_struct.piece_vox_id ) )
	{
		if ( isDefined( self.a_buildable_piece_pickedup_vox_cooldown ) && isinarray( self.a_buildable_piece_pickedup_vox_cooldown, buildable_struct.piece_vox_id ) )
		{
			return;
		}
		self thread do_player_general_vox( "general", buildable_struct.piece_vox_id + "_pickup" );
		if ( isDefined( buildable_struct.piece_vox_timer ) )
		{
			self thread buildable_piece_pickedup_vox_cooldown( buildable_struct.piece_vox_id, buildable_struct.piece_vox_timer );
		}
	}
	else
	{
		self thread do_player_general_vox( "general", "build_pickup" );
	}
}

buildable_piece_pickedup_vox_cooldown( piece_vox_id, timer ) //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( !isDefined( self.a_buildable_piece_pickedup_vox_cooldown ) )
	{
		self.a_buildable_piece_pickedup_vox_cooldown = [];
	}
	self.a_buildable_piece_pickedup_vox_cooldown[ self.a_buildable_piece_pickedup_vox_cooldown.size ] = piece_vox_id;
	wait timer;
	arrayremovevalue( self.a_buildable_piece_pickedup_vox_cooldown, piece_vox_id );
}

track_buildable_pieces_built( buildable ) //checked matches cerberus output
{
	if ( !isDefined( buildable ) || !isDefined( buildable.buildable_name ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_buildable_pieces_built() \n" );
#/
		*/
		return;
	}
	bname = buildable.buildable_name;
	if ( isDefined( buildable.stat_name ) )
	{
		bname = buildable.stat_name;
	}
	self add_map_buildable_stat( bname, "pieces_built", 1 );
	if ( !buildable buildable_all_built() )
	{
		if ( isDefined( level.zombie_include_buildables[ buildable.buildable_name ] ) && isDefined( level.zombie_include_buildables[ buildable.buildable_name ].snd_build_add_vo_override ) )
		{
			self thread [[ level.zombie_include_buildables[ buildable.buildable_name ].snd_build_add_vo_override ]]();
			return;
		}
		else
		{
			self thread do_player_general_vox( "general", "build_add" );
		}
	}
}

track_buildables_built( buildable ) //checked matches cerberus output
{
	if ( !isDefined( buildable ) || !isDefined( buildable.buildable_name ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_buildables_built() \n" );
#/
		*/
		return;
	}
	bname = buildable.buildable_name;
	if ( isDefined( buildable.stat_name ) )
	{
		bname = buildable.stat_name;
	}
	self add_map_buildable_stat( bname, "buildable_built", 1 );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "buildables_built", 0 );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "buildables_built" );
	if ( isDefined( buildable.stub.buildablestruct.vox_id ) )
	{
		self thread do_player_general_vox( "general", "build_" + buildable.stub.buildablestruct.vox_id + "_final" );
	}
}

track_buildables_pickedup( buildable ) //checked matches cerberus output
{
	if ( !isDefined( buildable ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_buildables_pickedup() \n" );
#/
		*/
		return;
	}
	stat_name = get_buildable_stat_name( buildable );
	if ( !isDefined( stat_name ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NO STAT NAME FOR " + buildable + "\n" );
#/
		*/
		return;
	}
	self add_map_buildable_stat( stat_name, "buildable_pickedup", 1 );
	self say_pickup_buildable_vo( buildable, 0 );
}

track_buildables_planted( equipment ) //checked matches cerberus output
{
	if ( !isDefined( equipment ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED for track_buildables_planted() \n" );
#/
		*/
		return;
	}
	buildable_name = undefined;
	if ( isDefined( equipment.name ) )
	{
		buildable_name = get_buildable_stat_name( equipment.name );
	}
	if ( !isDefined( buildable_name ) )
	{
		/*
/#
		println( "STAT TRACKING FAILURE: NO BUILDABLE NAME FOR track_buildables_planted() " + equipment.name + "\n" );
#/
		*/
		return;
	}
	maps/mp/_demo::bookmark( "zm_player_buildable_placed", getTime(), self );
	self add_map_buildable_stat( buildable_name, "buildable_placed", 1 );
	vo_name = "build_plc_" + buildable_name;
	if ( buildable_name == "electric_trap" )
	{
		vo_name = "build_plc_trap";
	}
	if ( !is_true( self.buildable_timer ) )
	{
		self thread do_player_general_vox( "general", vo_name );
		self thread placed_buildable_vo_timer();
	}
}

placed_buildable_vo_timer() //checked matches cerberus output
{
	self endon( "disconnect" );
	self.buildable_timer = 1;
	wait 60;
	self.buildable_timer = 0;
}

buildable_pickedup_timer() //checked matches cerberus output
{
	self endon( "disconnect" );
	self.buildable_pickedup_timer = 1;
	wait 60;
	self.buildable_pickedup_timer = 0;
}

track_planted_buildables_pickedup( equipment ) //checked changed to match cerberus output
{
	if ( !isDefined( equipment ) )
	{
		return;
	}
	if ( equipment == "equip_turbine_zm" || equipment == "equip_turret_zm" || equipment == "equip_electrictrap_zm" || equipment == "riotshield_zm" )
	{
		self maps/mp/zombies/_zm_stats::increment_client_stat( "planted_buildables_pickedup", 0 );
		self maps/mp/zombies/_zm_stats::increment_player_stat( "planted_buildables_pickedup" );
	}
	if ( !is_true( self.buildable_pickedup_timer ) )
	{
		self say_pickup_buildable_vo( equipment, 1 );
		self thread buildable_pickedup_timer();
	}
}

track_placed_buildables( buildable_name ) //checked matches cerberus output
{
	if ( !isDefined( buildable_name ) )
	{
		return;
	}
	self add_map_buildable_stat( buildable_name, "buildable_placed", 1 );
	vo_name = undefined;
	if ( buildable_name == level.riotshield_name )
	{
		vo_name = "build_plc_shield";
	}
	if ( !isDefined( vo_name ) )
	{
		return;
	}
	self thread do_player_general_vox( "general", vo_name );
}

add_map_buildable_stat( piece_name, stat_name, value ) //checked changed to match cerberus output
{
	if ( isDefined( piece_name ) || piece_name == "sq_common" || piece_name == "keys_zm" || piece_name == "oillamp_zm" )
	{
		return;
	}
	if ( is_true( level.zm_disable_recording_stats ) || is_true( level.zm_disable_recording_buildable_stats ) )
	{
		return;
	}
	self adddstat( "buildables", piece_name, stat_name, value );
}

say_pickup_buildable_vo( buildable_name, world ) //checked matches cerberus output
{
	if ( is_true( self.buildable_pickedup_timer ) )
	{
		return;
	}
	name = get_buildable_vo_name( buildable_name );
	if ( !isDefined( name ) )
	{
		return;
	}
	vo_name = "build_pck_b" + name;
	if ( is_true( world ) )
	{
		vo_name = "build_pck_w" + name;
	}
	if ( !isDefined( level.transit_buildable_vo_override ) || !( self [[ level.transit_buildable_vo_override ]]( name, world ) ) )
	{
		self thread do_player_general_vox( "general", vo_name );
		self thread buildable_pickedup_timer();
	}
}

get_buildable_vo_name( buildable_name ) //checked matches cerberus output
{
	switch( buildable_name )
	{
		case "equip_turbine_zm":
			return "turbine";
		case "equip_turret_zm":
			return "turret";
		case "equip_electrictrap_zm":
			return "trap";
		case "riotshield_zm":
			return "shield";
		case "jetgun_zm":
			return "jetgun";
		case "equip_springpad_zm":
			return "springpad_zm";
		case "equip_slipgun_zm":
			return "slipgun_zm";
		case "equip_headchopper_zm":
			return "headchopper_zm";
		case "equip_subwoofer_zm":
			return "subwoofer_zm";
	}
	return undefined;
}

get_buildable_stat_name( buildable ) //checked matches cerberus output
{
	if ( isDefined( buildable ) )
	{
		switch( buildable )
		{
			case "equip_turbine_zm":
				return "turbine";
			case "equip_turret_zm":
				return "turret";
			case "equip_electrictrap_zm":
				return "electric_trap";
			case "equip_springpad_zm":
				return "springpad_zm";
			case "equip_slipgun_zm":
				return "slipgun_zm";
			case "equip_headchopper_zm":
				return "headchopper_zm";
			case "equip_subwoofer_zm":
				return "subwoofer_zm";
		}
		return undefined;
	}
}



