#include maps/mp/_demo;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	precachestring( &"ZOMBIE_BUILDING" );
	precachestring( &"ZOMBIE_BUILD_PIECE_MISSING" );
	precachestring( &"ZOMBIE_BUILD_PIECE_GRAB" );
	precacheitem( "zombie_builder_zm" );
	precacheitem( "buildable_piece_zm" );
	level.craftable_piece_swap_allowed = 1;
	zombie_craftables_callbacks = [];
	level.craftablepickups = [];
	level.craftables_crafted = [];
	level.a_uts_craftables = [];
	level.craftable_piece_count = 0;
	level._effect[ "building_dust" ] = loadfx( "maps/zombie/fx_zmb_buildable_assemble_dust" );
	if ( isDefined( level.init_craftables ) )
	{
		[[ level.init_craftables ]]();
	}
	open_table = spawnstruct();
	open_table.name = "open_table";
	open_table.triggerthink = ::opentablecraftable;
	open_table.custom_craftablestub_update_prompt = ::open_craftablestub_update_prompt;
	include_zombie_craftable( open_table );
	add_zombie_craftable( "open_table", &"" );
	if ( isDefined( level.use_swipe_protection ) )
	{
		onplayerconnect_callback( ::craftables_watch_swipes );
	}
}

anystub_update_prompt( player )
{
	if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || player in_revive_trigger() )
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

anystub_get_unitrigger_origin()
{
	if ( isDefined( self.origin_parent ) )
	{
		return self.origin_parent.origin;
	}
	return self.origin;
}

anystub_on_spawn_trigger( trigger )
{
	if ( isDefined( self.link_parent ) )
	{
		trigger enablelinkto();
		trigger linkto( self.link_parent );
		trigger setmovingplatformenabled( 1 );
	}
}

craftables_watch_swipes()
{
	self endon( "disconnect" );
	self notify( "craftables_watch_swipes" );
	self endon( "craftables_watch_swipes" );
	while ( 1 )
	{
		self waittill( "melee_swipe", zombie );
		while ( distancesquared( zombie.origin, self.origin ) > ( zombie.meleeattackdist * zombie.meleeattackdist ) )
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
				piece maps/mp/zombies/_zm_craftables::piece_unspawn();
				self maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_total", 0 );
				if ( isalive( self ) )
				{
					self playlocalsound( level.zmb_laugh_alias );
				}
			}
		}
	}
}

explosiondamage( damage, pos )
{
/#
	println( "ZM CRAFTABLE Explode do " + damage + " damage to " + self.name + "\n" );
#/
	self dodamage( damage, pos );
}

make_zombie_craftable_open( str_craftable, str_model, v_angle_offset, v_origin_offset )
{
/#
	assert( isDefined( level.zombie_craftablestubs[ str_craftable ] ), "Craftable " + str_craftable + " has not been added yet." );
#/
	precachemodel( str_model );
	s_craftable = level.zombie_craftablestubs[ str_craftable ];
	s_craftable.is_open_table = 1;
	s_craftable.str_model = str_model;
	s_craftable.v_angle_offset = v_angle_offset;
	s_craftable.v_origin_offset = v_origin_offset;
}

add_zombie_craftable( craftable_name, str_to_craft, str_crafting, str_taken, onfullycrafted, need_all_pieces )
{
	if ( !isDefined( level.zombie_include_craftables ) )
	{
		level.zombie_include_craftables = [];
	}
	if ( isDefined( level.zombie_include_craftables ) && !isDefined( level.zombie_include_craftables[ craftable_name ] ) )
	{
		return;
	}
	if ( isDefined( str_to_craft ) )
	{
		precachestring( str_to_craft );
	}
	if ( isDefined( str_crafting ) )
	{
		precachestring( str_crafting );
	}
	if ( isDefined( str_taken ) )
	{
		precachestring( str_taken );
	}
	craftable_struct = level.zombie_include_craftables[ craftable_name ];
	if ( !isDefined( level.zombie_craftablestubs ) )
	{
		level.zombie_craftablestubs = [];
	}
	craftable_struct.str_to_craft = str_to_craft;
	craftable_struct.str_crafting = str_crafting;
	craftable_struct.str_taken = str_taken;
	craftable_struct.onfullycrafted = onfullycrafted;
	craftable_struct.need_all_pieces = need_all_pieces;
/#
	println( "ZM >> Looking for craftable - " + craftable_struct.name );
#/
	level.zombie_craftablestubs[ craftable_struct.name ] = craftable_struct;
	if ( !level.createfx_enabled )
	{
		if ( level.zombie_craftablestubs.size == 2 )
		{
			bits = getminbitcountfornum( level.craftable_piece_count );
			registerclientfield( "toplayer", "craftable", 9000, bits, "int" );
		}
	}
}

add_zombie_craftable_vox_category( craftable_name, vox_id )
{
	craftable_struct = level.zombie_include_craftables[ craftable_name ];
	craftable_struct.vox_id = vox_id;
}

include_zombie_craftable( craftablestub )
{
	if ( !isDefined( level.zombie_include_craftables ) )
	{
		level.zombie_include_craftables = [];
	}
/#
	println( "ZM >> Including craftable - " + craftablestub.name );
#/
	level.zombie_include_craftables[ craftablestub.name ] = craftablestub;
}

generate_zombie_craftable_piece( craftablename, piecename, modelname, radius, height, drop_offset, hud_icon, onpickup, ondrop, oncrafted, use_spawn_num, tag_name, can_reuse, client_field_value, is_shared, vox_id )
{
	if ( !isDefined( is_shared ) )
	{
		is_shared = 0;
	}
	precachemodel( modelname );
	if ( isDefined( hud_icon ) )
	{
		precacheshader( hud_icon );
	}
	piecestub = spawnstruct();
	craftable_pieces = [];
	piece_alias = "";
	if ( !isDefined( piecename ) )
	{
		piecename = modelname;
	}
	craftable_pieces_structs = getstructarray( ( craftablename + "_" ) + piecename, "targetname" );
/#
	if ( craftable_pieces_structs.size < 1 )
	{
		println( "ERROR: Missing craftable piece <" + craftablename + "> <" + piecename + ">\n" );
#/
	}
	_a344 = craftable_pieces_structs;
	index = getFirstArrayKey( _a344 );
	while ( isDefined( index ) )
	{
		struct = _a344[ index ];
		craftable_pieces[ index ] = struct;
		craftable_pieces[ index ].hasspawned = 0;
		index = getNextArrayKey( _a344, index );
	}
	piecestub.spawns = craftable_pieces;
	piecestub.craftablename = craftablename;
	piecestub.piecename = piecename;
	piecestub.modelname = modelname;
	piecestub.hud_icon = hud_icon;
	piecestub.radius = radius;
	piecestub.height = height;
	piecestub.tag_name = tag_name;
	piecestub.can_reuse = can_reuse;
	piecestub.drop_offset = drop_offset;
	piecestub.max_instances = 256;
	piecestub.onpickup = onpickup;
	piecestub.ondrop = ondrop;
	piecestub.oncrafted = oncrafted;
	piecestub.use_spawn_num = use_spawn_num;
	piecestub.is_shared = is_shared;
	piecestub.vox_id = vox_id;
	if ( isDefined( client_field_value ) )
	{
		if ( isDefined( is_shared ) && is_shared )
		{
/#
			assert( isstring( client_field_value ), "Client field value for shared item (" + piecename + ") should be a string (the name of the ClientField to use)" );
#/
			piecestub.client_field_id = client_field_value;
		}
		else
		{
			piecestub.client_field_state = client_field_value;
		}
	}
	return piecestub;
}

manage_multiple_pieces( max_instances )
{
	self.max_instances = max_instances;
	self.managing_pieces = 1;
	self.piece_allocated = [];
}

combine_craftable_pieces( piece1, piece2, piece3 )
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

add_craftable_piece( piecestub, tag_name, can_reuse )
{
	if ( !isDefined( self.a_piecestubs ) )
	{
		self.a_piecestubs = [];
	}
	if ( isDefined( tag_name ) )
	{
		piecestub.tag_name = tag_name;
	}
	if ( isDefined( can_reuse ) )
	{
		piecestub.can_reuse = can_reuse;
	}
	self.a_piecestubs[ self.a_piecestubs.size ] = piecestub;
}

player_drop_piece_on_downed()
{
	self endon( "craftable_piece_released" );
	self waittill( "bled_out" );
	onplayerlaststand();
}

onplayerlaststand()
{
	piece = self.current_craftable_piece;
	if ( isDefined( piece ) )
	{
		return_to_start_pos = 0;
		if ( isDefined( level.safe_place_for_craftable_piece ) )
		{
			if ( !( self [[ level.safe_place_for_craftable_piece ]]( piece ) ) )
			{
				return_to_start_pos = 1;
			}
		}
		if ( return_to_start_pos )
		{
			piece piece_spawn_at();
		}
		else
		{
			piece piece_spawn_at( self.origin + vectorScale( ( 0, 0, 1 ), 5 ), self.angles );
		}
		if ( isDefined( piece.ondrop ) )
		{
			piece [[ piece.ondrop ]]( self );
		}
		self setclientfieldtoplayer( "craftable", 0 );
	}
	self.current_craftable_piece = undefined;
	self notify( "craftable_piece_released" );
}

piecestub_get_unitrigger_origin()
{
	if ( isDefined( self.origin_parent ) )
	{
		return self.origin_parent.origin + vectorScale( ( 0, 0, 1 ), 12 );
	}
	return self.origin;
}

generate_piece_unitrigger( classname, origin, angles, flags, radius, script_height, moving )
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
		unitrigger_stub.script_length = 13,5;
	}
	if ( isDefined( script_width ) )
	{
		unitrigger_stub.script_width = script_width;
	}
	else
	{
		unitrigger_stub.script_width = 27,5;
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
	if ( isDefined( moving ) && moving )
	{
		maps/mp/zombies/_zm_unitrigger::register_unitrigger( unitrigger_stub, ::piece_unitrigger_think );
	}
	else
	{
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::piece_unitrigger_think );
	}
	return unitrigger_stub;
}

piecetrigger_update_prompt( player )
{
	can_use = self.stub piecestub_update_prompt( player );
	self setinvisibletoplayer( player, !can_use );
	self sethintstring( self.stub.hint_string );
	return can_use;
}

piecestub_update_prompt( player )
{
	if ( !self anystub_update_prompt( player ) )
	{
		return 0;
	}
	if ( isDefined( player.current_craftable_piece ) && isDefined( self.piece.is_shared ) && !self.piece.is_shared )
	{
		if ( !level.craftable_piece_swap_allowed )
		{
			self.hint_string = &"ZM_CRAFTABLES_PIECE_NO_SWITCH";
		}
		else
		{
			spiece = self.piece;
			cpiece = player.current_craftable_piece;
			if ( spiece.piecename == cpiece.piecename && spiece.craftablename == cpiece.craftablename )
			{
				self.hint_string = "";
				return 0;
			}
			self.hint_string = &"ZOMBIE_BUILD_PIECE_SWITCH";
		}
	}
	else
	{
		self.hint_string = &"ZOMBIE_BUILD_PIECE_GRAB";
	}
	return 1;
}

piece_unitrigger_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( player != self.parent_player )
		{
			continue;
		}
		while ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		while ( !level.craftable_piece_swap_allowed && isDefined( player.current_craftable_piece ) && isDefined( self.stub.piece.is_shared ) && !self.stub.piece.is_shared )
		{
			continue;
		}
		while ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		status = player player_can_take_piece( self.stub.piece );
		if ( !status )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			continue;
		}
		else
		{
			player thread player_take_piece( self.stub.piece );
		}
	}
}

player_can_take_piece( piece )
{
	if ( !isDefined( piece ) )
	{
		return 0;
	}
	return 1;
}

dbline( from, to )
{
/#
	time = 20;
	while ( time > 0 )
	{
		line( from, to, ( 0, 0, 1 ), 0, 1 );
		time -= 0,05;
		wait 0,05;
#/
	}
}

player_throw_piece( piece, origin, dir, return_to_spawn, return_time, endangles )
{
/#
	assert( isDefined( piece ) );
#/
	if ( isDefined( piece ) )
	{
/#
		thread dbline( origin, origin + dir );
#/
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
			altmodel linkto( grenade, "", ( 0, 0, 1 ), ( 0, 0, 1 ) );
			grenade.altmodel = altmodel;
			grenade waittill( "stationary" );
			grenade_origin = grenade.origin;
			grenade_angles = grenade.angles;
			landed_on = grenade getgroundent();
			grenade delete();
			if ( isDefined( landed_on ) && landed_on == level )
			{
				done = 1;
				continue;
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
		if ( isDefined( return_to_spawn ) && return_to_spawn )
		{
			piece piece_wait_and_return( return_time );
		}
	}
}

watch_hit_players()
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

piece_wait_and_return( return_time )
{
	self endon( "pickup" );
	wait 0,15;
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

player_return_piece_to_original_spawn()
{
	self notify( "craftable_piece_released" );
	piece = self.current_craftable_piece;
	self.current_craftable_piece = undefined;
	if ( isDefined( piece ) )
	{
		piece piece_spawn_at();
		self setclientfieldtoplayer( "craftable", 0 );
	}
}

player_drop_piece_on_death()
{
	self notify( "craftable_piece_released" );
	self endon( "craftable_piece_released" );
	self thread player_drop_piece_on_downed();
	origin = self.origin;
	angles = self.angles;
	piece = self.current_craftable_piece;
	self waittill( "disconnect" );
	piece piece_spawn_at( origin, angles );
	if ( isDefined( self ) )
	{
		self setclientfieldtoplayer( "craftable", 0 );
	}
}

player_drop_piece( piece )
{
	if ( !isDefined( piece ) )
	{
		piece = self.current_craftable_piece;
	}
	if ( isDefined( piece ) )
	{
		piece.damage = 0;
		piece piece_spawn_at( self.origin, self.angles );
		self setclientfieldtoplayer( "craftable", 0 );
		if ( isDefined( piece.ondrop ) )
		{
			piece [[ piece.ondrop ]]( self );
		}
	}
	self.current_craftable_piece = undefined;
	self notify( "craftable_piece_released" );
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;
	if ( isDefined( piecestub.is_shared ) && !piecestub.is_shared && isDefined( self.current_craftable_piece ) )
	{
		other_piece = self.current_craftable_piece;
		self player_drop_piece( self.current_craftable_piece );
		other_piece.damage = damage;
		self do_player_general_vox( "general", "craft_swap" );
	}
	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}
	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}
	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );
	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}
	else
	{
		self.current_craftable_piece = piecespawn;
		self thread player_drop_piece_on_death();
	}
	self track_craftable_piece_pickedup( piecespawn );
}

player_destroy_piece( piece )
{
	if ( !isDefined( piece ) )
	{
		piece = self.current_craftable_piece;
	}
	if ( isDefined( piece ) )
	{
		self setclientfieldtoplayer( "craftable", 0 );
	}
	self.current_craftable_piece = undefined;
	self notify( "craftable_piece_released" );
}

claim_location( location )
{
	if ( !isDefined( level.craftable_claimed_locations ) )
	{
		level.craftable_claimed_locations = [];
	}
	if ( !isDefined( level.craftable_claimed_locations[ location ] ) )
	{
		level.craftable_claimed_locations[ location ] = 1;
		return 1;
	}
	return 0;
}

is_point_in_craft_trigger( point )
{
	candidate_list = [];
	_a952 = level.zones;
	_k952 = getFirstArrayKey( _a952 );
	while ( isDefined( _k952 ) )
	{
		zone = _a952[ _k952 ];
		if ( isDefined( zone.unitrigger_stubs ) )
		{
			candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
		}
		_k952 = getNextArrayKey( _a952, _k952 );
	}
	valid_range = 128;
	closest = maps/mp/zombies/_zm_unitrigger::get_closest_unitriggers( point, candidate_list, valid_range );
	index = 0;
	while ( index < closest.size )
	{
		if ( isDefined( closest[ index ].registered ) && closest[ index ].registered && isDefined( closest[ index ].piece ) )
		{
			return 1;
		}
		index++;
	}
	return 0;
}

piece_allocate_spawn( piecestub )
{
	self.current_spawn = 0;
	self.managed_spawn = 1;
	self.piecestub = piecestub;
	if ( self.spawns.size >= 1 && self.spawns.size > 1 )
	{
		any_good = 0;
		any_okay = 0;
		totalweight = 0;
		spawnweights = [];
		i = 0;
		while ( i < self.spawns.size )
		{
			if ( isDefined( piecestub.piece_allocated[ i ] ) && piecestub.piece_allocated[ i ] )
			{
				spawnweights[ i ] = 0;
			}
			else
			{
				if ( is_point_in_craft_trigger( self.spawns[ i ].origin ) )
				{
					any_okay = 1;
					spawnweights[ i ] = 0,01;
					break;
				}
				else
				{
					any_good = 1;
					spawnweights[ i ] = 1;
				}
			}
			totalweight += spawnweights[ i ];
			i++;
		}
/#
		if ( !any_good )
		{
			assert( any_okay, "There is nowhere to spawn this piece" );
		}
#/
		if ( any_good )
		{
			totalweight = float( int( totalweight ) );
		}
		r = randomfloat( totalweight );
		i = 0;
		while ( i < self.spawns.size )
		{
			if ( !any_good || spawnweights[ i ] >= 1 )
			{
				r -= spawnweights[ i ];
				if ( r < 0 )
				{
					self.current_spawn = i;
					piecestub.piece_allocated[ self.current_spawn ] = 1;
					return;
				}
			}
			i++;
		}
		self.current_spawn = randomint( self.spawns.size );
		piecestub.piece_allocated[ self.current_spawn ] = 1;
	}
}

piece_deallocate_spawn()
{
	if ( isDefined( self.current_spawn ) )
	{
		self.piecestub.piece_allocated[ self.current_spawn ] = 0;
		self.current_spawn = undefined;
	}
	self.start_origin = undefined;
}

piece_pick_random_spawn()
{
	self.current_spawn = 0;
	while ( self.spawns.size >= 1 && self.spawns.size > 1 )
	{
		self.current_spawn = randomint( self.spawns.size );
		while ( isDefined( self.spawns[ self.current_spawn ].claim_location ) && !claim_location( self.spawns[ self.current_spawn ].claim_location ) )
		{
			arrayremoveindex( self.spawns, self.current_spawn );
			if ( self.spawns.size < 1 )
			{
				self.current_spawn = 0;
/#
				println( "ERROR: All craftable spawn locations claimed" );
#/
				return;
			}
			self.current_spawn = randomint( self.spawns.size );
		}
	}
}

piece_set_spawn( num )
{
	self.current_spawn = 0;
	if ( self.spawns.size >= 1 && self.spawns.size > 1 )
	{
		self.current_spawn = int( min( num, self.spawns.size - 1 ) );
	}
}

piece_spawn_in( piecestub )
{
	if ( self.spawns.size < 1 )
	{
		return;
	}
	if ( isDefined( self.managed_spawn ) && self.managed_spawn )
	{
		if ( !isDefined( self.current_spawn ) )
		{
			self piece_allocate_spawn( self.piecestub );
		}
	}
	if ( !isDefined( self.current_spawn ) )
	{
		self.current_spawn = 0;
	}
	spawndef = self.spawns[ self.current_spawn ];
	self.unitrigger = generate_piece_unitrigger( "trigger_radius_use", spawndef.origin + vectorScale( ( 0, 0, 1 ), 12 ), spawndef.angles, 0, piecestub.radius, piecestub.height, 0 );
	self.unitrigger.piece = self;
	self.radius = piecestub.radius;
	self.height = piecestub.height;
	self.craftablename = piecestub.craftablename;
	self.piecename = piecestub.piecename;
	self.modelname = piecestub.modelname;
	self.hud_icon = piecestub.hud_icon;
	self.tag_name = piecestub.tag_name;
	self.drop_offset = piecestub.drop_offset;
	self.start_origin = spawndef.origin;
	self.start_angles = spawndef.angles;
	self.client_field_state = piecestub.client_field_state;
	self.is_shared = piecestub.is_shared;
	self.model = spawn( "script_model", self.start_origin );
	if ( isDefined( self.start_angles ) )
	{
		self.model.angles = self.start_angles;
	}
	self.model setmodel( piecestub.modelname );
	if ( isDefined( piecestub.onspawn ) )
	{
		self [[ piecestub.onspawn ]]();
	}
	self.model ghostindemo();
	self.model.hud_icon = piecestub.hud_icon;
	self.piecestub = piecestub;
	self.unitrigger.origin_parent = self.model;
}

piece_spawn_at( origin, angles, use_random_start )
{
	if ( self.spawns.size < 1 )
	{
		return;
	}
	if ( isDefined( self.managed_spawn ) && self.managed_spawn )
	{
		if ( !isDefined( self.current_spawn ) && !isDefined( origin ) )
		{
			self piece_allocate_spawn( self.piecestub );
			spawndef = self.spawns[ self.current_spawn ];
			self.start_origin = spawndef.origin;
			self.start_angles = spawndef.angles;
		}
	}
	else
	{
		if ( !isDefined( self.current_spawn ) )
		{
			self.current_spawn = 0;
		}
	}
	unitrigger_offset = vectorScale( ( 0, 0, 1 ), 12 );
	if ( isDefined( use_random_start ) && use_random_start )
	{
		self piece_pick_random_spawn();
		spawndef = self.spawns[ self.current_spawn ];
		self.start_origin = spawndef.origin;
		self.start_angles = spawndef.angles;
		origin = spawndef.origin;
		angles = spawndef.angles;
	}
	else
	{
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
/#
		if ( !isDefined( level.drop_offset ) )
		{
			level.drop_offset = 0;
		}
		origin += ( 0, 0, level.drop_offset );
		unitrigger_offset -= ( 0, 0, level.drop_offset );
#/
	}
	self.model = spawn( "script_model", origin );
	if ( isDefined( angles ) )
	{
		self.model.angles = angles;
	}
	self.model setmodel( self.modelname );
	if ( isDefined( level.equipment_safe_to_drop ) )
	{
		if ( !( [[ level.equipment_safe_to_drop ]]( self.model ) ) )
		{
			origin = self.start_origin;
			angles = self.start_angles;
			self.model.origin = origin;
			self.model.angles = angles;
		}
	}
	if ( isDefined( self.onspawn ) )
	{
		self [[ self.onspawn ]]();
	}
	if ( isDefined( self.model.canmove ) )
	{
		self.unitrigger = generate_piece_unitrigger( "trigger_radius_use", origin + unitrigger_offset, angles, 0, self.radius, self.height, self.model.canmove );
	}
	self.unitrigger.piece = self;
	self.model.hud_icon = self.hud_icon;
	self.unitrigger.origin_parent = self.model;
}

piece_unspawn()
{
	if ( isDefined( self.managed_spawn ) && self.managed_spawn )
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

piece_hide()
{
	if ( isDefined( self.model ) )
	{
		self.model ghost();
	}
}

piece_show()
{
	if ( isDefined( self.model ) )
	{
		self.model show();
	}
}

generate_piece( piecestub )
{
	piecespawn = spawnstruct();
	piecespawn.spawns = piecestub.spawns;
	if ( isDefined( piecestub.managing_pieces ) && piecestub.managing_pieces )
	{
		piecespawn piece_allocate_spawn( piecestub );
	}
	else
	{
		if ( isDefined( piecestub.use_spawn_num ) )
		{
			piecespawn piece_set_spawn( piecestub.use_spawn_num );
		}
		else
		{
			piecespawn piece_pick_random_spawn();
		}
	}
	piecespawn piece_spawn_in( piecestub );
	if ( piecespawn.spawns.size >= 1 )
	{
		piecespawn.hud_icon = piecestub.hud_icon;
	}
	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn.onpickup = piecestub.onpickup;
	}
	else
	{
		piecespawn.onpickup = ::onpickuputs;
	}
	if ( isDefined( piecestub.ondrop ) )
	{
		piecespawn.ondrop = piecestub.ondrop;
	}
	else
	{
		piecespawn.ondrop = ::ondroputs;
	}
	if ( isDefined( piecestub.oncrafted ) )
	{
		piecespawn.oncrafted = piecestub.oncrafted;
	}
	return piecespawn;
}

craftable_piece_unitriggers( craftable_name, origin )
{
/#
	assert( isDefined( craftable_name ) );
#/
/#
	assert( isDefined( level.zombie_craftablestubs[ craftable_name ] ), "Called craftable_think() without including the craftable - " + craftable_name );
#/
	craftable = level.zombie_craftablestubs[ craftable_name ];
	if ( !isDefined( craftable.a_piecestubs ) )
	{
		craftable.a_piecestubs = [];
	}
	flag_wait( "start_zombie_round_logic" );
	craftablespawn = spawnstruct();
	craftablespawn.craftable_name = craftable_name;
	if ( !isDefined( craftablespawn.a_piecespawns ) )
	{
		craftablespawn.a_piecespawns = [];
	}
	craftablepickups = [];
	_a1314 = craftable.a_piecestubs;
	_k1314 = getFirstArrayKey( _a1314 );
	while ( isDefined( _k1314 ) )
	{
		piecestub = _a1314[ _k1314 ];
		if ( !isDefined( piecestub.generated_instances ) )
		{
			piecestub.generated_instances = 0;
		}
		if ( isDefined( piecestub.piecespawn ) && isDefined( piecestub.can_reuse ) && piecestub.can_reuse )
		{
			piece = piecestub.piecespawn;
		}
		else
		{
			if ( piecestub.generated_instances >= piecestub.max_instances )
			{
				piece = piecestub.piecespawn;
				break;
			}
			else
			{
				piece = generate_piece( piecestub );
				piecestub.piecespawn = piece;
				piecestub.generated_instances++;
			}
		}
		craftablespawn.a_piecespawns[ craftablespawn.a_piecespawns.size ] = piece;
		_k1314 = getNextArrayKey( _a1314, _k1314 );
	}
	craftablespawn.stub = self;
	return craftablespawn;
}

hide_craftable_table_model( trigger_targetname )
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
			model ghost();
			model notsolid();
		}
	}
}

setup_unitrigger_craftable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	trig = getent( trigger_targetname, "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	return setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

setup_unitrigger_craftable_array( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	triggers = getentarray( trigger_targetname, "targetname" );
	stubs = [];
	_a1376 = triggers;
	_k1376 = getFirstArrayKey( _a1376 );
	while ( isDefined( _k1376 ) )
	{
		trig = _a1376[ _k1376 ];
		stubs[ stubs.size ] = setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
		_k1376 = getNextArrayKey( _a1376, _k1376 );
	}
	return stubs;
}

setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
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
		angles = ( 0, 0, 1 );
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
	if ( isDefined( level.zombie_craftablestubs[ equipname ].str_to_craft ) )
	{
		unitrigger_stub.hint_string = level.zombie_craftablestubs[ equipname ].str_to_craft;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
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
	if ( unitrigger_stub.equipname == "open_table" )
	{
		unitrigger_stub.a_uts_open_craftables_available = [];
		unitrigger_stub.n_open_craftable_choice = -1;
		unitrigger_stub.b_open_craftable_checking_input = 0;
	}
	unitrigger_stub.craftablespawn = unitrigger_stub craftable_piece_unitriggers( equipname, unitrigger_stub.origin );
	if ( delete_trigger )
	{
		trig delete();
	}
	level.a_uts_craftables[ level.a_uts_craftables.size ] = unitrigger_stub;
	return unitrigger_stub;
}

setup_craftable_pieces()
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.craftablestub = level.zombie_include_craftables[ self.name ];
	unitrigger_stub.equipname = self.name;
	unitrigger_stub.craftablespawn = unitrigger_stub craftable_piece_unitriggers( self.name, unitrigger_stub.origin );
	level.a_uts_craftables[ level.a_uts_craftables.size ] = unitrigger_stub;
	return unitrigger_stub;
}

craftable_has_piece( piece )
{
	i = 0;
	while ( i < self.a_piecespawns.size )
	{
		if ( self.a_piecespawns[ i ].piecename == piece.piecename && self.a_piecespawns[ i ].craftablename == piece.craftablename )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

get_actual_uts_craftable()
{
	if ( self.craftable_name == "open_table" && self.n_open_craftable_choice != -1 )
	{
		return self.stub.a_uts_open_craftables_available[ self.n_open_craftable_choice ];
	}
	else
	{
		return self.stub;
	}
}

get_actual_craftablespawn()
{
	if ( self.craftable_name == "open_table" && self.stub.n_open_craftable_choice != -1 && isDefined( self.stub.a_uts_open_craftables_available[ self.stub.n_open_craftable_choice ].craftablespawn ) )
	{
		return self.stub.a_uts_open_craftables_available[ self.stub.n_open_craftable_choice ].craftablespawn;
	}
	else
	{
		return self;
	}
}

craftable_can_use_shared_piece()
{
	uts_craftable = self.stub;
	if ( isDefined( uts_craftable.n_open_craftable_choice ) && uts_craftable.n_open_craftable_choice != -1 && isDefined( uts_craftable.a_uts_open_craftables_available[ uts_craftable.n_open_craftable_choice ] ) )
	{
		return 1;
	}
	if ( isDefined( uts_craftable.craftablestub.need_all_pieces ) && uts_craftable.craftablestub.need_all_pieces )
	{
		_a1595 = self.a_piecespawns;
		_k1595 = getFirstArrayKey( _a1595 );
		while ( isDefined( _k1595 ) )
		{
			piece = _a1595[ _k1595 ];
			if ( isDefined( piece.in_shared_inventory ) && !piece.in_shared_inventory )
			{
				return 0;
			}
			_k1595 = getNextArrayKey( _a1595, _k1595 );
		}
		return 1;
	}
	else
	{
		_a1608 = self.a_piecespawns;
		_k1608 = getFirstArrayKey( _a1608 );
		while ( isDefined( _k1608 ) )
		{
			piece = _a1608[ _k1608 ];
			if ( isDefined( piece.crafted ) && !piece.crafted && isDefined( piece.in_shared_inventory ) && piece.in_shared_inventory )
			{
				return 1;
			}
			_k1608 = getNextArrayKey( _a1608, _k1608 );
		}
	}
	return 0;
}

craftable_set_piece_crafted( piecespawn_check, player )
{
	craftablespawn_check = get_actual_craftablespawn();
	_a1625 = craftablespawn_check.a_piecespawns;
	_k1625 = getFirstArrayKey( _a1625 );
	while ( isDefined( _k1625 ) )
	{
		piecespawn = _a1625[ _k1625 ];
		if ( isDefined( piecespawn_check ) )
		{
			if ( piecespawn.piecename == piecespawn_check.piecename && piecespawn.craftablename == piecespawn_check.craftablename )
			{
				piecespawn.crafted = 1;
				if ( isDefined( piecespawn.oncrafted ) )
				{
					piecespawn thread [[ piecespawn.oncrafted ]]( player );
				}
			}
		}
		else
		{
			if ( isDefined( piecespawn.is_shared ) && piecespawn.is_shared && isDefined( piecespawn.in_shared_inventory ) && piecespawn.in_shared_inventory )
			{
				piecespawn.crafted = 1;
				if ( isDefined( piecespawn.oncrafted ) )
				{
					piecespawn thread [[ piecespawn.oncrafted ]]( player );
				}
				piecespawn.in_shared_inventory = 0;
			}
		}
		_k1625 = getNextArrayKey( _a1625, _k1625 );
	}
}

craftable_set_piece_crafting( piecespawn_check )
{
	craftablespawn_check = get_actual_craftablespawn();
	_a1664 = craftablespawn_check.a_piecespawns;
	_k1664 = getFirstArrayKey( _a1664 );
	while ( isDefined( _k1664 ) )
	{
		piecespawn = _a1664[ _k1664 ];
		if ( isDefined( piecespawn_check ) )
		{
			if ( piecespawn.piecename == piecespawn_check.piecename && piecespawn.craftablename == piecespawn_check.craftablename )
			{
				piecespawn.crafting = 1;
			}
		}
		if ( isDefined( piecespawn.is_shared ) && piecespawn.is_shared && isDefined( piecespawn.in_shared_inventory ) && piecespawn.in_shared_inventory )
		{
			piecespawn.crafting = 1;
		}
		_k1664 = getNextArrayKey( _a1664, _k1664 );
	}
}

craftable_clear_piece_crafting( piecespawn_check )
{
	if ( isDefined( piecespawn_check ) )
	{
		piecespawn_check.crafting = 0;
	}
	craftablespawn_check = get_actual_craftablespawn();
	_a1693 = craftablespawn_check.a_piecespawns;
	_k1693 = getFirstArrayKey( _a1693 );
	while ( isDefined( _k1693 ) )
	{
		piecespawn = _a1693[ _k1693 ];
		if ( isDefined( piecespawn.is_shared ) && piecespawn.is_shared && isDefined( piecespawn.in_shared_inventory ) && piecespawn.in_shared_inventory )
		{
			piecespawn.crafting = 0;
		}
		_k1693 = getNextArrayKey( _a1693, _k1693 );
	}
}

craftable_is_piece_crafted( piece )
{
	i = 0;
	while ( i < self.a_piecespawns.size )
	{
		if ( self.a_piecespawns[ i ].piecename == piece.piecename && self.a_piecespawns[ i ].craftablename == piece.craftablename )
		{
			if ( isDefined( self.a_piecespawns[ i ].crafted ) )
			{
				return self.a_piecespawns[ i ].crafted;
			}
		}
		i++;
	}
	return 0;
}

craftable_is_piece_crafting( piecespawn_check )
{
	craftablespawn_check = get_actual_craftablespawn();
	_a1720 = craftablespawn_check.a_piecespawns;
	_k1720 = getFirstArrayKey( _a1720 );
	while ( isDefined( _k1720 ) )
	{
		piecespawn = _a1720[ _k1720 ];
		if ( isDefined( piecespawn_check ) )
		{
			if ( piecespawn.piecename == piecespawn_check.piecename && piecespawn.craftablename == piecespawn_check.craftablename )
			{
				return piecespawn.crafting;
			}
		}
		if ( isDefined( piecespawn.is_shared ) && piecespawn.is_shared && isDefined( piecespawn.in_shared_inventory ) && piecespawn.in_shared_inventory && isDefined( piecespawn.crafting ) && piecespawn.crafting )
		{
			return 1;
		}
		_k1720 = getNextArrayKey( _a1720, _k1720 );
	}
	return 0;
}

craftable_is_piece_crafted_or_crafting( piece )
{
	i = 0;
	while ( i < self.a_piecespawns.size )
	{
		if ( self.a_piecespawns[ i ].piecename == piece.piecename && self.a_piecespawns[ i ].craftablename == piece.craftablename )
		{
			if ( isDefined( self.a_piecespawns[ i ].crafted ) && !self.a_piecespawns[ i ].crafted )
			{
				if ( isDefined( self.a_piecespawns[ i ].crafting ) )
				{
					return self.a_piecespawns[ i ].crafting;
				}
			}
		}
		i++;
	}
	return 0;
}

craftable_all_crafted()
{
	i = 0;
	while ( i < self.a_piecespawns.size )
	{
		if ( isDefined( self.a_piecespawns[ i ].crafted ) && !self.a_piecespawns[ i ].crafted )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

waittill_crafted( craftable_name )
{
	level waittill( craftable_name + "_crafted", player );
	return player;
}

player_can_craft( craftablespawn, continuing )
{
	if ( !isDefined( craftablespawn ) )
	{
		return 0;
	}
	if ( !craftablespawn craftable_can_use_shared_piece() )
	{
		if ( !isDefined( self.current_craftable_piece ) )
		{
			return 0;
		}
		if ( !craftablespawn craftable_has_piece( self.current_craftable_piece ) )
		{
			return 0;
		}
		if ( isDefined( continuing ) && continuing )
		{
			if ( craftablespawn craftable_is_piece_crafted( self.current_craftable_piece ) )
			{
				return 0;
			}
		}
		else
		{
			if ( craftablespawn craftable_is_piece_crafted_or_crafting( self.current_craftable_piece ) )
			{
				return 0;
			}
		}
	}
	if ( isDefined( craftablespawn.stub ) && isDefined( craftablespawn.stub.custom_craftablestub_update_prompt ) && isDefined( craftablespawn.stub.playertrigger[ 0 ] ) && isDefined( craftablespawn.stub.playertrigger[ 0 ].stub ) && !( craftablespawn.stub.playertrigger[ 0 ].stub [[ craftablespawn.stub.custom_craftablestub_update_prompt ]]( self, 1, craftablespawn.stub.playertrigger[ self getentitynumber() ] ) ) )
	{
		return 0;
	}
	return 1;
}

craftable_transfer_data()
{
	uts_craftable = self.stub;
	if ( uts_craftable.n_open_craftable_choice == -1 || !isDefined( uts_craftable.a_uts_open_craftables_available[ uts_craftable.n_open_craftable_choice ] ) )
	{
		return;
	}
	uts_source = uts_craftable.a_uts_open_craftables_available[ uts_craftable.n_open_craftable_choice ];
	uts_target = uts_craftable;
	uts_target.craftablestub = uts_source.craftablestub;
	uts_target.craftablespawn = uts_source.craftablespawn;
	uts_target.crafted = uts_source.crafted;
	uts_target.cursor_hint = uts_source.cursor_hint;
	uts_target.custom_craftable_update_prompt = uts_source.custom_craftable_update_prompt;
	uts_target.equipname = uts_source.equipname;
	uts_target.hint_string = uts_source.hint_string;
	uts_target.persistent = uts_source.persistent;
	uts_target.prompt_and_visibility_func = uts_source.prompt_and_visibility_func;
	uts_target.trigger_func = uts_source.trigger_func;
	uts_target.trigger_hintstring = uts_source.trigger_hintstring;
	uts_target.weaponname = uts_source.weaponname;
	uts_target.craftablespawn.stub = uts_target;
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( uts_source );
	uts_source craftablestub_remove();
	return uts_target;
}

player_craft( craftablespawn )
{
	craftablespawn craftable_set_piece_crafted( self.current_craftable_piece, self );
	if ( isDefined( self.current_craftable_piece ) && isDefined( self.current_craftable_piece.crafted ) && self.current_craftable_piece.crafted )
	{
		player_destroy_piece( self.current_craftable_piece );
	}
	if ( isDefined( craftablespawn.stub.n_open_craftable_choice ) )
	{
		uts_craftable = craftablespawn craftable_transfer_data();
		craftablespawn = uts_craftable.craftablespawn;
		update_open_table_status();
	}
	else
	{
		uts_craftable = craftablespawn.stub;
	}
	if ( !isDefined( uts_craftable.model ) && isDefined( uts_craftable.craftablestub.str_model ) )
	{
		craftablestub = uts_craftable.craftablestub;
		s_model = getstruct( uts_craftable.target, "targetname" );
		if ( isDefined( s_model ) )
		{
			m_spawn = spawn( "script_model", s_model.origin );
			if ( isDefined( craftablestub.v_origin_offset ) )
			{
				m_spawn.origin += craftablestub.v_origin_offset;
			}
			m_spawn.angles = s_model.angles;
			if ( isDefined( craftablestub.v_angle_offset ) )
			{
				m_spawn.angles += craftablestub.v_angle_offset;
			}
			m_spawn setmodel( craftablestub.str_model );
			uts_craftable.model = m_spawn;
		}
	}
	while ( isDefined( uts_craftable.model ) )
	{
		i = 0;
		while ( i < craftablespawn.a_piecespawns.size )
		{
			if ( isDefined( craftablespawn.a_piecespawns[ i ].tag_name ) )
			{
				uts_craftable.model notsolid();
				if ( isDefined( craftablespawn.a_piecespawns[ i ].crafted ) && !craftablespawn.a_piecespawns[ i ].crafted )
				{
					uts_craftable.model hidepart( craftablespawn.a_piecespawns[ i ].tag_name );
					i++;
					continue;
				}
				else
				{
					uts_craftable.model show();
					uts_craftable.model showpart( craftablespawn.a_piecespawns[ i ].tag_name );
				}
			}
			i++;
		}
	}
	self track_craftable_pieces_crafted( craftablespawn );
	if ( craftablespawn craftable_all_crafted() )
	{
		self player_finish_craftable( craftablespawn );
		self track_craftables_crafted( craftablespawn );
		if ( isDefined( level.craftable_crafted_custom_func ) )
		{
			self thread [[ level.craftable_crafted_custom_func ]]( craftablespawn );
		}
		self playsound( "zmb_buildable_complete" );
	}
	else
	{
		self playsound( "zmb_buildable_piece_add" );
/#
		assert( isDefined( level.zombie_craftablestubs[ craftablespawn.craftable_name ].str_crafting ), "Missing builing hint" );
#/
		if ( isDefined( level.zombie_craftablestubs[ craftablespawn.craftable_name ].str_crafting ) )
		{
			return level.zombie_craftablestubs[ craftablespawn.craftable_name ].str_crafting;
		}
	}
	return "";
}

update_open_table_status()
{
	b_open_craftables_remaining = 0;
	_a1963 = level.a_uts_craftables;
	_k1963 = getFirstArrayKey( _a1963 );
	while ( isDefined( _k1963 ) )
	{
		uts_craftable = _a1963[ _k1963 ];
		if ( isDefined( level.zombie_include_craftables[ uts_craftable.equipname ] ) && isDefined( level.zombie_include_craftables[ uts_craftable.equipname ].is_open_table ) && level.zombie_include_craftables[ uts_craftable.equipname ].is_open_table )
		{
			b_piece_crafted = 0;
			_a1970 = uts_craftable.craftablespawn.a_piecespawns;
			_k1970 = getFirstArrayKey( _a1970 );
			while ( isDefined( _k1970 ) )
			{
				piecespawn = _a1970[ _k1970 ];
				if ( isDefined( piecespawn.crafted ) && piecespawn.crafted )
				{
					b_piece_crafted = 1;
					break;
				}
				else
				{
					_k1970 = getNextArrayKey( _a1970, _k1970 );
				}
			}
			if ( !b_piece_crafted )
			{
				b_open_craftables_remaining = 1;
			}
		}
		_k1963 = getNextArrayKey( _a1963, _k1963 );
	}
	while ( !b_open_craftables_remaining )
	{
		_a1989 = level.a_uts_craftables;
		_k1989 = getFirstArrayKey( _a1989 );
		while ( isDefined( _k1989 ) )
		{
			uts_craftable = _a1989[ _k1989 ];
			if ( uts_craftable.equipname == "open_table" )
			{
				thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( uts_craftable );
			}
			_k1989 = getNextArrayKey( _a1989, _k1989 );
		}
	}
}

player_finish_craftable( craftablespawn )
{
	craftablespawn.crafted = 1;
	craftablespawn.stub.crafted = 1;
	craftablespawn notify( "crafted" );
	level.craftables_crafted[ craftablespawn.craftable_name ] = 1;
	level notify( craftablespawn.craftable_name + "_crafted" );
}

complete_craftable( str_craftable_name )
{
	_a2014 = level.a_uts_craftables;
	_k2014 = getFirstArrayKey( _a2014 );
	while ( isDefined( _k2014 ) )
	{
		uts_craftable = _a2014[ _k2014 ];
		if ( uts_craftable.craftablestub.name == str_craftable_name )
		{
			player = getplayers()[ 0 ];
			player player_finish_craftable( uts_craftable.craftablespawn );
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( uts_craftable );
			if ( isDefined( uts_craftable.craftablestub.onfullycrafted ) )
			{
				uts_craftable [[ uts_craftable.craftablestub.onfullycrafted ]]();
			}
			return;
		}
		_k2014 = getNextArrayKey( _a2014, _k2014 );
	}
}

craftablestub_remove()
{
	arrayremovevalue( level.a_uts_craftables, self );
}

craftabletrigger_update_prompt( player )
{
	can_use = self.stub craftablestub_update_prompt( player );
	self sethintstring( self.stub.hint_string );
	return can_use;
}

craftablestub_update_prompt( player, unitrigger )
{
	if ( !self anystub_update_prompt( player ) )
	{
		return 0;
	}
	if ( isDefined( self.is_locked ) && self.is_locked )
	{
		return 1;
	}
	can_use = 1;
	if ( isDefined( self.custom_craftablestub_update_prompt ) && !( self [[ self.custom_craftablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}
	if ( isDefined( self.crafted ) && !self.crafted )
	{
		if ( !self.craftablespawn craftable_can_use_shared_piece() )
		{
			if ( !isDefined( player.current_craftable_piece ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
				return 0;
			}
			else
			{
				if ( !self.craftablespawn craftable_has_piece( player.current_craftable_piece ) )
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
					return 0;
				}
			}
		}
/#
		assert( isDefined( level.zombie_craftablestubs[ self.equipname ].str_to_craft ), "Missing craftable hint" );
#/
		self.hint_string = level.zombie_craftablestubs[ self.equipname ].str_to_craft;
	}
	else
	{
		if ( self.persistent == 1 )
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
			self.hint_string = self.trigger_hintstring;
		}
		else if ( self.persistent == 2 )
		{
			if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.weaponname, undefined ) )
			{
				self.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
				return 0;
			}
			else
			{
				if ( isDefined( self.str_taken ) && self.str_taken )
				{
					self.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
					return 0;
				}
			}
			self.hint_string = self.trigger_hintstring;
		}
		else
		{
			self.hint_string = "";
			return 0;
		}
	}
	return 1;
}

choose_open_craftable( player )
{
	self endon( "kill_choose_open_craftable" );
	n_playernum = player getentitynumber();
	self.b_open_craftable_checking_input = 1;
	b_got_input = 1;
	hinttexthudelem = newclienthudelem( player );
	hinttexthudelem.alignx = "center";
	hinttexthudelem.aligny = "middle";
	hinttexthudelem.horzalign = "center";
	hinttexthudelem.vertalign = "bottom";
	hinttexthudelem.y = -100;
	if ( player issplitscreen() )
	{
		hinttexthudelem.y = -50;
	}
	hinttexthudelem.foreground = 1;
	hinttexthudelem.font = "default";
	hinttexthudelem.fontscale = 1;
	hinttexthudelem.alpha = 1;
	hinttexthudelem.color = ( 0, 0, 1 );
	hinttexthudelem settext( &"ZM_CRAFTABLES_CHANGE_BUILD" );
	if ( !isDefined( self.opencraftablehudelem ) )
	{
		self.opencraftablehudelem = [];
	}
	self.opencraftablehudelem[ n_playernum ] = hinttexthudelem;
	while ( isDefined( self.playertrigger[ n_playernum ] ) && !self.crafted )
	{
		if ( player actionslotonebuttonpressed() )
		{
			self.n_open_craftable_choice++;
			b_got_input = 1;
		}
		else
		{
			if ( player actionslottwobuttonpressed() )
			{
				self.n_open_craftable_choice--;

				b_got_input = 1;
			}
		}
		if ( self.n_open_craftable_choice >= self.a_uts_open_craftables_available.size )
		{
			self.n_open_craftable_choice = 0;
		}
		else
		{
			if ( self.n_open_craftable_choice < 0 )
			{
				self.n_open_craftable_choice = self.a_uts_open_craftables_available.size - 1;
			}
		}
		if ( b_got_input )
		{
			self.equipname = self.a_uts_open_craftables_available[ self.n_open_craftable_choice ].equipname;
			self.hint_string = self.a_uts_open_craftables_available[ self.n_open_craftable_choice ].hint_string;
			self.playertrigger[ n_playernum ] sethintstring( self.hint_string );
			b_got_input = 0;
		}
		if ( player is_player_looking_at( self.playertrigger[ n_playernum ].origin, 0,76 ) )
		{
			self.opencraftablehudelem[ n_playernum ].alpha = 1;
		}
		else
		{
			self.opencraftablehudelem[ n_playernum ].alpha = 0;
		}
		wait 0,05;
	}
	self.b_open_craftable_checking_input = 0;
	self.opencraftablehudelem[ n_playernum ] destroy();
}

open_craftablestub_update_prompt( player )
{
	if ( isDefined( self.crafted ) && !self.crafted )
	{
		self.a_uts_open_craftables_available = [];
		_a2235 = level.a_uts_craftables;
		_k2235 = getFirstArrayKey( _a2235 );
		while ( isDefined( _k2235 ) )
		{
			uts_craftable = _a2235[ _k2235 ];
			if ( isDefined( uts_craftable.craftablestub.is_open_table ) && uts_craftable.craftablestub.is_open_table && isDefined( uts_craftable.crafted ) && !uts_craftable.crafted && uts_craftable.craftablespawn.craftable_name != "open_table" && uts_craftable.craftablespawn craftable_can_use_shared_piece() )
			{
				self.a_uts_open_craftables_available[ self.a_uts_open_craftables_available.size ] = uts_craftable;
			}
			_k2235 = getNextArrayKey( _a2235, _k2235 );
		}
		if ( self.a_uts_open_craftables_available.size < 2 )
		{
			self notify( "kill_choose_open_craftable" );
			self.b_open_craftable_checking_input = 0;
			n_entitynum = player getentitynumber();
			if ( isDefined( self.opencraftablehudelem ) && isDefined( self.opencraftablehudelem[ n_entitynum ] ) )
			{
				self.opencraftablehudelem[ n_entitynum ] destroy();
			}
		}
		switch( self.a_uts_open_craftables_available.size )
		{
			case 0:
				if ( !isDefined( player.current_craftable_piece ) )
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
					self.n_open_craftable_choice = -1;
					return 0;
				}
				case 1:
					self.n_open_craftable_choice = 0;
					self.equipname = self.a_uts_open_craftables_available[ self.n_open_craftable_choice ].equipname;
					return 1;
				default:
					if ( !self.b_open_craftable_checking_input )
					{
						thread choose_open_craftable( player );
					}
					return 1;
			}
		}
		else
		{
			if ( self.persistent == 1 )
			{
				return 1;
			}
		}
		return 0;
	}
}

player_continue_crafting( craftablespawn )
{
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || self in_revive_trigger() )
	{
		return 0;
	}
	if ( !self player_can_craft( craftablespawn, 1 ) )
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
	if ( !craftablespawn craftable_is_piece_crafting( self.current_craftable_piece ) )
	{
		return 0;
	}
	trigger = craftablespawn.stub maps/mp/zombies/_zm_unitrigger::unitrigger_trigger( self );
	if ( craftablespawn.stub.script_unitrigger_type == "unitrigger_radius_use" )
	{
		torigin = craftablespawn.stub unitrigger_origin();
		porigin = self geteye();
		radius_sq = 2,25 * craftablespawn.stub.radius * craftablespawn.stub.radius;
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
	if ( isDefined( craftablespawn.stub.require_look_at ) && craftablespawn.stub.require_look_at && !self is_player_looking_at( trigger.origin, 0,76 ) )
	{
		return 0;
	}
	return 1;
}

player_progress_bar_update( start_time, craft_time )
{
	self endon( "entering_last_stand" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "craftable_progress_end" );
	while ( isDefined( self ) && ( getTime() - start_time ) < craft_time )
	{
		progress = ( getTime() - start_time ) / craft_time;
		if ( progress < 0 )
		{
			progress = 0;
		}
		if ( progress > 1 )
		{
			progress = 1;
		}
		self.usebar updatebar( progress );
		wait 0,05;
	}
}

player_progress_bar( start_time, craft_time )
{
	self.usebar = self createprimaryprogressbar();
	self.usebartext = self createprimaryprogressbartext();
	self.usebartext settext( &"ZOMBIE_BUILDING" );
	if ( isDefined( self ) && isDefined( start_time ) && isDefined( craft_time ) )
	{
		self player_progress_bar_update( start_time, craft_time );
	}
	self.usebartext destroyelem();
	self.usebar destroyelem();
}

craftable_use_hold_think_internal( player )
{
	wait 0,01;
	if ( !isDefined( self ) )
	{
		self notify( "craft_failed" );
		if ( isDefined( player.craftableaudio ) )
		{
			player.craftableaudio delete();
			player.craftableaudio = undefined;
		}
		return;
	}
	if ( !isDefined( self.usetime ) )
	{
		self.usetime = int( 3000 );
	}
	self.craft_time = self.usetime;
	self.craft_start_time = getTime();
	craft_time = self.craft_time;
	craft_start_time = self.craft_start_time;
	player disable_player_move_states( 1 );
	player increment_is_drinking();
	orgweapon = player getcurrentweapon();
	player giveweapon( "zombie_builder_zm" );
	player switchtoweapon( "zombie_builder_zm" );
	self.stub.craftablespawn craftable_set_piece_crafting( player.current_craftable_piece );
	player thread player_progress_bar( craft_start_time, craft_time );
	if ( isDefined( level.craftable_craft_custom_func ) )
	{
		player thread [[ level.craftable_craft_custom_func ]]( self.stub );
	}
	while ( isDefined( self ) && player player_continue_crafting( self.stub.craftablespawn ) && ( getTime() - self.craft_start_time ) < self.craft_time )
	{
		wait 0,05;
	}
	player notify( "craftable_progress_end" );
	player maps/mp/zombies/_zm_weapons::switch_back_primary_weapon( orgweapon );
	player takeweapon( "zombie_builder_zm" );
	if ( isDefined( player.is_drinking ) && player.is_drinking )
	{
		player decrement_is_drinking();
	}
	player enable_player_move_states();
	if ( isDefined( self ) && player player_continue_crafting( self.stub.craftablespawn ) && ( getTime() - self.craft_start_time ) >= self.craft_time )
	{
		self.stub.craftablespawn craftable_clear_piece_crafting( player.current_craftable_piece );
		self notify( "craft_succeed" );
	}
	else
	{
		if ( isDefined( player.craftableaudio ) )
		{
			player.craftableaudio delete();
			player.craftableaudio = undefined;
		}
		self.stub.craftablespawn craftable_clear_piece_crafting( player.current_craftable_piece );
		self notify( "craft_failed" );
	}
}

craftable_play_craft_fx( player )
{
	self endon( "kill_trigger" );
	self endon( "craft_succeed" );
	self endon( "craft_failed" );
	while ( 1 )
	{
		playfx( level._effect[ "building_dust" ], player getplayercamerapos(), player.angles );
		wait 0,5;
	}
}

craftable_use_hold_think( player )
{
	self thread craftable_play_craft_fx( player );
	self thread craftable_use_hold_think_internal( player );
	retval = self waittill_any_return( "craft_succeed", "craft_failed" );
	if ( retval == "craft_succeed" )
	{
		return 1;
	}
	return 0;
}

craftable_place_think()
{
	self endon( "kill_trigger" );
	player_crafted = undefined;
	while ( isDefined( self.stub.crafted ) && !self.stub.crafted )
	{
		self waittill( "trigger", player );
		while ( isDefined( level.custom_craftable_validation ) )
		{
			valid = self [[ level.custom_craftable_validation ]]( player );
			while ( !valid )
			{
				continue;
			}
		}
		while ( player != self.parent_player )
		{
			continue;
		}
		while ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		while ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		status = player player_can_craft( self.stub.craftablespawn );
		if ( !status )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			if ( isDefined( self.stub.oncantuse ) )
			{
				self.stub [[ self.stub.oncantuse ]]( player );
			}
			continue;
		}
		else
		{
			if ( isDefined( self.stub.onbeginuse ) )
			{
				self.stub [[ self.stub.onbeginuse ]]( player );
			}
			result = self craftable_use_hold_think( player );
			team = player.pers[ "team" ];
			if ( isDefined( self.stub.onenduse ) )
			{
				self.stub [[ self.stub.onenduse ]]( team, player, result );
			}
			while ( !result )
			{
				continue;
			}
			if ( isDefined( self.stub.onuse ) )
			{
				self.stub [[ self.stub.onuse ]]( player );
			}
			prompt = player player_craft( self.stub.craftablespawn );
			player_crafted = player;
			self.stub.hint_string = prompt;
			self sethintstring( self.stub.hint_string );
		}
	}
	if ( isDefined( self.stub.craftablestub.onfullycrafted ) )
	{
		b_result = self.stub [[ self.stub.craftablestub.onfullycrafted ]]();
		if ( !b_result )
		{
			return;
		}
	}
	if ( isDefined( player_crafted ) )
	{
	}
	if ( self.stub.persistent == 0 )
	{
		self.stub craftablestub_remove();
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.stub );
		return;
	}
	if ( self.stub.persistent == 3 )
	{
		stub_uncraft_craftable( self.stub, 1 );
		return;
	}
	if ( self.stub.persistent == 2 )
	{
		if ( isDefined( player_crafted ) )
		{
			self craftabletrigger_update_prompt( player_crafted );
		}
		if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
		{
			self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
			self sethintstring( self.stub.hint_string );
			return;
		}
		if ( isDefined( self.stub.str_taken ) && self.stub.str_taken )
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
			while ( isDefined( player.screecher_weapon ) )
			{
				continue;
			}
			while ( isDefined( level.custom_craftable_validation ) )
			{
				valid = self [[ level.custom_craftable_validation ]]( player );
				while ( !valid )
				{
					continue;
				}
			}
			if ( isDefined( self.stub.crafted ) && !self.stub.crafted )
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
				return;
			}
			while ( player != self.parent_player )
			{
				continue;
			}
			while ( !is_player_valid( player ) )
			{
				player thread ignore_triggers( 0,5 );
			}
			self.stub.bought = 1;
			if ( isDefined( self.stub.model ) )
			{
				self.stub.model thread model_fly_away();
			}
			player maps/mp/zombies/_zm_weapons::weapon_give( self.stub.weaponname );
			if ( isDefined( level.zombie_include_craftables[ self.stub.equipname ].onbuyweapon ) )
			{
				self [[ level.zombie_include_craftables[ self.stub.equipname ].onbuyweapon ]]( player );
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
			player track_craftables_pickedup( self.stub.weaponname );
		}
	}
	else while ( !isDefined( player_crafted ) || self craftabletrigger_update_prompt( player_crafted ) )
	{
		if ( isDefined( self.stub.model ) )
		{
			self.stub.model notsolid();
			self.stub.model show();
		}
		while ( self.stub.persistent == 1 )
		{
			self waittill( "trigger", player );
			while ( isDefined( player.screecher_weapon ) )
			{
				continue;
			}
			while ( isDefined( level.custom_craftable_validation ) )
			{
				valid = self [[ level.custom_craftable_validation ]]( player );
				while ( !valid )
				{
					continue;
				}
			}
			if ( isDefined( self.stub.crafted ) && !self.stub.crafted )
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
				return;
			}
			while ( player != self.parent_player )
			{
				continue;
			}
			while ( !is_player_valid( player ) )
			{
				player thread ignore_triggers( 0,5 );
			}
			while ( player has_player_equipment( self.stub.weaponname ) )
			{
				continue;
			}
			if ( !maps/mp/zombies/_zm_equipment::is_limited_equipment( self.stub.weaponname ) || !maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.stub.weaponname ) )
			{
				player maps/mp/zombies/_zm_equipment::equipment_buy( self.stub.weaponname );
				player giveweapon( self.stub.weaponname );
				player setweaponammoclip( self.stub.weaponname, 1 );
				if ( isDefined( level.zombie_include_craftables[ self.stub.equipname ].onbuyweapon ) )
				{
					self [[ level.zombie_include_craftables[ self.stub.equipname ].onbuyweapon ]]( player );
				}
				if ( self.stub.weaponname != "keys_zm" )
				{
					player setactionslot( 1, "weapon", self.stub.weaponname );
				}
				if ( isDefined( level.zombie_craftablestubs[ self.stub.equipname ].str_taken ) )
				{
					self.stub.hint_string = level.zombie_craftablestubs[ self.stub.equipname ].str_taken;
				}
				else
				{
					self.stub.hint_string = "";
				}
				self sethintstring( self.stub.hint_string );
				player track_craftables_pickedup( self.stub.craftablespawn );
				continue;
			}
			else
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
			}
		}
	}
}

model_fly_away()
{
	self moveto( self.origin + vectorScale( ( 0, 0, 1 ), 40 ), 3 );
	direction = self.origin;
	direction = ( direction[ 1 ], direction[ 0 ], 0 );
	if ( direction[ 1 ] < 0 || direction[ 0 ] > 0 && direction[ 1 ] > 0 )
	{
		direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
	}
	else
	{
		if ( direction[ 0 ] < 0 )
		{
			direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
		}
	}
	self vibrate( direction, 10, 0,5, 4 );
	self waittill( "movedone" );
	self ghost();
	playfx( level._effect[ "poltergeist" ], self.origin );
}

find_craftable_stub( equipname )
{
	_a2752 = level.a_uts_craftables;
	_k2752 = getFirstArrayKey( _a2752 );
	while ( isDefined( _k2752 ) )
	{
		stub = _a2752[ _k2752 ];
		if ( stub.equipname == equipname )
		{
			return stub;
		}
		_k2752 = getNextArrayKey( _a2752, _k2752 );
	}
	return undefined;
}

uncraft_craftable( equipname, return_pieces, origin, angles )
{
	stub = find_craftable_stub( equipname );
	stub_uncraft_craftable( stub, return_pieces, origin, angles );
}

stub_uncraft_craftable( stub, return_pieces, origin, angles, use_random_start )
{
	if ( isDefined( stub ) )
	{
		craftable = stub.craftablespawn;
		craftable.crafted = 0;
		craftable.stub.crafted = 0;
		craftable notify( "uncrafted" );
		level.craftables_crafted[ craftable.craftable_name ] = 0;
		level notify( craftable.craftable_name + "_uncrafted" );
		i = 0;
		while ( i < craftable.a_piecespawns.size )
		{
			craftable.a_piecespawns[ i ].crafted = 0;
			if ( isDefined( craftable.a_piecespawns[ i ].tag_name ) )
			{
				craftable.stub.model notsolid();
				if ( isDefined( craftable.a_piecespawns[ i ].crafted ) && !craftable.a_piecespawns[ i ].crafted )
				{
					craftable.stub.model hidepart( craftable.a_piecespawns[ i ].tag_name );
					break;
				}
				else
				{
					craftable.stub.model show();
					craftable.stub.model showpart( craftable.a_piecespawns[ i ].tag_name );
				}
			}
			if ( isDefined( return_pieces ) && return_pieces )
			{
				craftable.a_piecespawns[ i ] piece_spawn_at( origin, angles, use_random_start );
			}
			i++;
		}
		if ( isDefined( craftable.stub.model ) )
		{
			craftable.stub.model ghost();
		}
	}
}

player_explode_craftable( equipname, origin, speed, return_to_spawn, return_time )
{
	self explosiondamage( 50, origin );
	stub = find_craftable_stub( equipname );
	if ( isDefined( stub ) )
	{
		craftable = stub.craftablespawn;
		craftable.crafted = 0;
		craftable.stub.crafted = 0;
		craftable notify( "uncrafted" );
		level.craftables_crafted[ craftable.craftable_name ] = 0;
		level notify( craftable.craftable_name + "_uncrafted" );
		i = 0;
		while ( i < craftable.a_piecespawns.size )
		{
			craftable.a_piecespawns[ i ].crafted = 0;
			if ( isDefined( craftable.a_piecespawns[ i ].tag_name ) )
			{
				craftable.stub.model notsolid();
				if ( isDefined( craftable.a_piecespawns[ i ].crafted ) && !craftable.a_piecespawns[ i ].crafted )
				{
					craftable.stub.model hidepart( craftable.a_piecespawns[ i ].tag_name );
					break;
				}
				else
				{
					craftable.stub.model show();
					craftable.stub.model showpart( craftable.a_piecespawns[ i ].tag_name );
				}
			}
			ang = randomfloat( 360 );
			h = 0,25 + randomfloat( 0,5 );
			dir = ( sin( ang ), cos( ang ), h );
			self thread player_throw_piece( craftable.a_piecespawns[ i ], origin, speed * dir, return_to_spawn, return_time );
			i++;
		}
		craftable.stub.model ghost();
	}
}

think_craftables()
{
	_a2850 = level.zombie_include_craftables;
	_k2850 = getFirstArrayKey( _a2850 );
	while ( isDefined( _k2850 ) )
	{
		craftable = _a2850[ _k2850 ];
		if ( isDefined( craftable.triggerthink ) )
		{
			craftable [[ craftable.triggerthink ]]();
		}
		_k2850 = getNextArrayKey( _a2850, _k2850 );
	}
}

opentablecraftable()
{
	a_trigs = getentarray( "open_craftable_trigger", "targetname" );
	_a2864 = a_trigs;
	_k2864 = getFirstArrayKey( _a2864 );
	while ( isDefined( _k2864 ) )
	{
		trig = _a2864[ _k2864 ];
		setup_unitrigger_craftable_internal( trig, "open_table", "", "OPEN_CRAFTABLE", 1, 0 );
		_k2864 = getNextArrayKey( _a2864, _k2864 );
	}
}

craftable_trigger_think( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	return setup_unitrigger_craftable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

craftable_trigger_think_array( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	return setup_unitrigger_craftable_array( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

setup_vehicle_unitrigger_craftable( parent, trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	trig = getent( trigger_targetname, "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	unitrigger_stub = spawnstruct();
	unitrigger_stub.craftablestub = level.zombie_include_craftables[ equipname ];
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
	if ( isDefined( level.zombie_craftablestubs[ equipname ].str_to_craft ) )
	{
		unitrigger_stub.hint_string = level.zombie_craftablestubs[ equipname ].str_to_craft;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::craftabletrigger_update_prompt;
	maps/mp/zombies/_zm_unitrigger::register_unitrigger( unitrigger_stub, ::craftable_place_think );
	unitrigger_stub.piece_trigger = trig;
	trig.trigger_stub = unitrigger_stub;
	unitrigger_stub.craftablespawn = unitrigger_stub craftable_piece_unitriggers( equipname, unitrigger_stub.origin );
	if ( delete_trigger )
	{
		trig delete();
	}
	level.a_uts_craftables[ level.a_uts_craftables.size ] = unitrigger_stub;
	return unitrigger_stub;
}

vehicle_craftable_trigger_think( vehicle, trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent )
{
	return setup_vehicle_unitrigger_craftable( vehicle, trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

onpickuputs( player )
{
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Craftable piece recovered by - " + player.name );
#/
	}
}

ondroputs( player )
{
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Craftable piece dropped by - " + player.name );
#/
	}
	player notify( "event_ended" );
}

onbeginuseuts( player )
{
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Craftable piece begin use by - " + player.name );
#/
	}
	if ( isDefined( self.craftablestub.onbeginuse ) )
	{
		self [[ self.craftablestub.onbeginuse ]]( player );
	}
	if ( isDefined( player ) && !isDefined( player.craftableaudio ) )
	{
		player.craftableaudio = spawn( "script_origin", player.origin );
		player.craftableaudio playloopsound( "zmb_craftable_loop" );
	}
}

onenduseuts( team, player, result )
{
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Craftable piece end use by - " + player.name );
#/
	}
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( isDefined( player.craftableaudio ) )
	{
		player.craftableaudio delete();
		player.craftableaudio = undefined;
	}
	if ( isDefined( self.craftablestub.onenduse ) )
	{
		self [[ self.craftablestub.onenduse ]]( team, player, result );
	}
	player notify( "event_ended" );
}

oncantuseuts( player )
{
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Craftable piece can't use by - " + player.name );
#/
	}
	if ( isDefined( self.craftablestub.oncantuse ) )
	{
		self [[ self.craftablestub.oncantuse ]]( player );
	}
}

onuseplantobjectuts( player )
{
/#
	if ( isDefined( player ) && isDefined( player.name ) )
	{
		println( "ZM >> Craftable piece crafted by - " + player.name );
#/
	}
	if ( isDefined( self.craftablestub.onuseplantobject ) )
	{
		self [[ self.craftablestub.onuseplantobject ]]( player );
	}
	player notify( "bomb_planted" );
}

is_craftable()
{
	if ( !isDefined( level.zombie_craftablestubs ) )
	{
		return 0;
	}
	if ( isDefined( self.zombie_weapon_upgrade ) && isDefined( level.zombie_craftablestubs[ self.zombie_weapon_upgrade ] ) )
	{
		return 1;
	}
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "specialty_weapupgrade" )
	{
		if ( isDefined( level.craftables_crafted[ "pap" ] ) && level.craftables_crafted[ "pap" ] )
		{
			return 0;
		}
		return 1;
	}
	return 0;
}

craftable_crafted()
{
	self.a_piecespawns--;

}

craftable_complete()
{
	if ( self.a_piecespawns <= 0 )
	{
		return 1;
	}
	return 0;
}

get_craftable_hint( craftable_name )
{
/#
	assert( isDefined( level.zombie_craftablestubs[ craftable_name ] ), craftable_name + " was not included or is not part of the zombie weapon list." );
#/
	return level.zombie_craftablestubs[ craftable_name ].str_to_craft;
}

delete_on_disconnect( craftable, self_notify, skip_delete )
{
	craftable endon( "death" );
	self waittill( "disconnect" );
	if ( isDefined( self_notify ) )
	{
		self notify( self_notify );
	}
	if ( isDefined( skip_delete ) && !skip_delete )
	{
		if ( isDefined( craftable.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( craftable.stub );
			craftable.stub = undefined;
		}
		if ( isDefined( craftable ) )
		{
			craftable delete();
		}
	}
}

is_holding_part( craftable_name, piece_name )
{
	if ( isDefined( self.current_craftable_piece ) )
	{
		if ( self.current_craftable_piece.craftablename == craftable_name && self.current_craftable_piece.modelname == piece_name )
		{
			return 1;
		}
	}
	while ( isDefined( level.a_uts_craftables ) )
	{
		_a3223 = level.a_uts_craftables;
		_k3223 = getFirstArrayKey( _a3223 );
		while ( isDefined( _k3223 ) )
		{
			craftable_stub = _a3223[ _k3223 ];
			while ( craftable_stub.craftablestub.name == craftable_name )
			{
				_a3228 = craftable_stub.craftablespawn.a_piecespawns;
				_k3228 = getFirstArrayKey( _a3228 );
				while ( isDefined( _k3228 ) )
				{
					piece = _a3228[ _k3228 ];
					if ( piece.piecename == piece_name )
					{
						if ( isDefined( piece.in_shared_inventory ) && piece.in_shared_inventory )
						{
							return 1;
						}
					}
					_k3228 = getNextArrayKey( _a3228, _k3228 );
				}
			}
			_k3223 = getNextArrayKey( _a3223, _k3223 );
		}
	}
	return 0;
}

is_part_crafted( craftable_name, piece_name )
{
	while ( isDefined( level.a_uts_craftables ) )
	{
		_a3253 = level.a_uts_craftables;
		_k3253 = getFirstArrayKey( _a3253 );
		while ( isDefined( _k3253 ) )
		{
			craftable_stub = _a3253[ _k3253 ];
			while ( craftable_stub.craftablestub.name == craftable_name )
			{
				if ( isDefined( craftable_stub.crafted ) && craftable_stub.crafted )
				{
					return 1;
				}
				_a3264 = craftable_stub.craftablespawn.a_piecespawns;
				_k3264 = getFirstArrayKey( _a3264 );
				while ( isDefined( _k3264 ) )
				{
					piece = _a3264[ _k3264 ];
					if ( piece.piecename == piece_name )
					{
						if ( isDefined( piece.crafted ) && piece.crafted )
						{
							return 1;
						}
					}
					_k3264 = getNextArrayKey( _a3264, _k3264 );
				}
			}
			_k3253 = getNextArrayKey( _a3253, _k3253 );
		}
	}
	return 0;
}

track_craftable_piece_pickedup( piece )
{
	if ( !isDefined( piece ) || !isDefined( piece.craftablename ) )
	{
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_craftable_piece_pickedup() \n" );
#/
		return;
	}
	self add_map_craftable_stat( piece.craftablename, "pieces_pickedup", 1 );
	if ( isDefined( piece.piecestub.vox_id ) )
	{
		self thread do_player_general_vox( "general", piece.piecestub.vox_id + "_pickup" );
	}
	else
	{
		self thread do_player_general_vox( "general", "build_pickup" );
	}
}

track_craftable_pieces_crafted( craftable )
{
	if ( !isDefined( craftable ) || !isDefined( craftable.craftable_name ) )
	{
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_craftable_pieces_crafted() \n" );
#/
		return;
	}
	bname = craftable.craftable_name;
	if ( isDefined( craftable.stat_name ) )
	{
		bname = craftable.stat_name;
	}
	self add_map_craftable_stat( bname, "pieces_built", 1 );
	if ( !craftable craftable_all_crafted() )
	{
		self thread do_player_general_vox( "general", "build_add" );
	}
}

track_craftables_crafted( craftable )
{
	if ( !isDefined( craftable ) || !isDefined( craftable.craftable_name ) )
	{
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_craftables_crafted() \n" );
#/
		return;
	}
	bname = craftable.craftable_name;
	if ( isDefined( craftable.stat_name ) )
	{
		bname = craftable.stat_name;
	}
	self add_map_craftable_stat( bname, "buildable_built", 1 );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "buildables_built", 0 );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "buildables_built" );
	if ( isDefined( craftable.stub.craftablestub.vox_id ) )
	{
		self thread do_player_general_vox( "general", craftable.stub.craftablestub.vox_id + "_final" );
	}
}

track_craftables_pickedup( craftable )
{
	if ( !isDefined( craftable ) )
	{
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED IN track_craftables_pickedup() \n" );
#/
		return;
	}
	stat_name = get_craftable_stat_name( craftable.craftable_name );
	if ( !isDefined( stat_name ) )
	{
/#
		println( "STAT TRACKING FAILURE: NO STAT NAME FOR " + craftable.craftable_name + "\n" );
#/
		return;
	}
	self add_map_craftable_stat( stat_name, "buildable_pickedup", 1 );
	if ( isDefined( craftable.stub.craftablestub.vox_id ) )
	{
		self thread do_player_general_vox( "general", craftable.stub.craftablestub.vox_id + "_plc" );
	}
	self say_pickup_craftable_vo( craftable, 0 );
}

track_craftables_planted( equipment )
{
	if ( !isDefined( equipment ) )
	{
/#
		println( "STAT TRACKING FAILURE: NOT DEFINED for track_craftables_planted() \n" );
#/
		return;
	}
	craftable_name = undefined;
	if ( isDefined( equipment.name ) )
	{
		craftable_name = get_craftable_stat_name( equipment.name );
	}
	if ( !isDefined( craftable_name ) )
	{
/#
		println( "STAT TRACKING FAILURE: NO CRAFTABLE NAME FOR track_craftables_planted() " + equipment.name + "\n" );
#/
		return;
	}
	maps/mp/_demo::bookmark( "zm_player_buildable_placed", getTime(), self );
	self add_map_craftable_stat( craftable_name, "buildable_placed", 1 );
}

placed_craftable_vo_timer()
{
	self endon( "disconnect" );
	self.craftable_timer = 1;
	wait 60;
	self.craftable_timer = 0;
}

craftable_pickedup_timer()
{
	self endon( "disconnect" );
	self.craftable_pickedup_timer = 1;
	wait 60;
	self.craftable_pickedup_timer = 0;
}

track_planted_craftables_pickedup( equipment )
{
	if ( !isDefined( equipment ) )
	{
		return;
	}
	if ( equipment != "equip_turbine_zm" && equipment != "equip_turret_zm" && equipment != "equip_electrictrap_zm" || equipment == "riotshield_zm" && equipment == "alcatraz_shield_zm" )
	{
		self maps/mp/zombies/_zm_stats::increment_client_stat( "planted_buildables_pickedup", 0 );
		self maps/mp/zombies/_zm_stats::increment_player_stat( "planted_buildables_pickedup" );
	}
	if ( isDefined( self.craftable_pickedup_timer ) && !self.craftable_pickedup_timer )
	{
		self say_pickup_craftable_vo( equipment, 1 );
		self thread craftable_pickedup_timer();
	}
}

track_placed_craftables( craftable_name )
{
	if ( !isDefined( craftable_name ) )
	{
		return;
	}
	self add_map_craftable_stat( craftable_name, "buildable_placed", 1 );
	vo_name = undefined;
	if ( craftable_name == level.riotshield_name )
	{
		vo_name = "craft_plc_shield";
	}
	if ( !isDefined( vo_name ) )
	{
		return;
	}
	self thread do_player_general_vox( "general", vo_name );
}

add_map_craftable_stat( piece_name, stat_name, value )
{
	if ( isDefined( piece_name ) || piece_name == "sq_common" && piece_name == "keys_zm" )
	{
		return;
	}
	self adddstat( "buildables", piece_name, stat_name, value );
}

say_pickup_craftable_vo( craftable_name, world )
{
}

get_craftable_vo_name( craftable_name )
{
}

get_craftable_stat_name( craftable_name )
{
	if ( isDefined( craftable_name ) )
	{
		switch( craftable_name )
		{
			case "equip_riotshield_zm":
				return "riotshield_zm";
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
		}
	}
	return craftable_name;
}

get_craftable_model( str_craftable )
{
	_a3544 = level.a_uts_craftables;
	_k3544 = getFirstArrayKey( _a3544 );
	while ( isDefined( _k3544 ) )
	{
		uts_craftable = _a3544[ _k3544 ];
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			if ( isDefined( uts_craftable.model ) )
			{
				return uts_craftable.model;
			}
		}
		else
		{
			_k3544 = getNextArrayKey( _a3544, _k3544 );
		}
	}
	return undefined;
}

get_craftable_piece( str_craftable, str_piece )
{
	_a3564 = level.a_uts_craftables;
	_k3564 = getFirstArrayKey( _a3564 );
	while ( isDefined( _k3564 ) )
	{
		uts_craftable = _a3564[ _k3564 ];
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			_a3568 = uts_craftable.craftablespawn.a_piecespawns;
			_k3568 = getFirstArrayKey( _a3568 );
			while ( isDefined( _k3568 ) )
			{
				piecespawn = _a3568[ _k3568 ];
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
				_k3568 = getNextArrayKey( _a3568, _k3568 );
			}
		}
		else _k3564 = getNextArrayKey( _a3564, _k3564 );
	}
	return undefined;
}

player_get_craftable_piece( str_craftable, str_piece )
{
	piecespawn = get_craftable_piece( str_craftable, str_piece );
	if ( isDefined( piecespawn ) )
	{
		self player_take_piece( piecespawn );
	}
}

get_craftable_piece_model( str_craftable, str_piece )
{
	_a3600 = level.a_uts_craftables;
	_k3600 = getFirstArrayKey( _a3600 );
	while ( isDefined( _k3600 ) )
	{
		uts_craftable = _a3600[ _k3600 ];
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			_a3604 = uts_craftable.craftablespawn.a_piecespawns;
			_k3604 = getFirstArrayKey( _a3604 );
			while ( isDefined( _k3604 ) )
			{
				piecespawn = _a3604[ _k3604 ];
				if ( piecespawn.piecename == str_piece && isDefined( piecespawn.model ) )
				{
					return piecespawn.model;
				}
				_k3604 = getNextArrayKey( _a3604, _k3604 );
			}
		}
		else _k3600 = getNextArrayKey( _a3600, _k3600 );
	}
	return undefined;
}
