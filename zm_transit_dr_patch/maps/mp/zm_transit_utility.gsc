#include maps/mp/_compass;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

playercanafford( player, cost )
{
	if ( !player usebuttonpressed() )
	{
		return 0;
	}
	if ( player in_revive_trigger() )
	{
		return 0;
	}
	if ( isDefined( cost ) )
	{
		if ( player.score < cost )
		{
			return 0;
		}
		player maps/mp/zombies/_zm_score::minus_to_player_score( cost );
	}
	return 1;
}

setinvisibletoall()
{
	players = get_players();
	playerindex = 0;
	while ( playerindex < players.size )
	{
		self setinvisibletoplayer( players[ playerindex ] );
		playerindex++;
	}
}

spawnandlinkfxtotag( effect, ent, tag )
{
	fxent = spawn( "script_model", ent gettagorigin( tag ) );
	fxent setmodel( "tag_origin" );
	fxent linkto( ent, tag );
	wait_network_frame();
	playfxontag( effect, fxent, "tag_origin" );
	return fxent;
}

spawnandlinkfxtooffset( effect, ent, offsetorigin, offsetangles )
{
	fxent = spawn( "script_model", ( 0, 0, 0 ) );
	fxent setmodel( "tag_origin" );
	fxent linkto( ent, "", offsetorigin, offsetangles );
	wait_network_frame();
	playfxontag( effect, fxent, "tag_origin" );
	return fxent;
}

custom_weapon_wall_prices()
{
	if ( !isDefined( level.zombie_include_weapons ) )
	{
		return;
	}
	weapon_spawns = [];
	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );
	i = 0;
	while ( i < weapon_spawns.size )
	{
		if ( !isDefined( level.zombie_weapons[ weapon_spawns[ i ].zombie_weapon_upgrade ] ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( weapon_spawns[ i ].script_int ) )
			{
				cost = weapon_spawns[ i ].script_int;
				level.zombie_weapons[ weapon_spawns[ i ].zombie_weapon_upgrade ].cost = cost;
			}
		}
		i++;
	}
}

pause_zombie_spawning()
{
	if ( !isDefined( level.spawnpausecount ) )
	{
		level.spawnpausecount = 0;
	}
	level.spawnpausecount++;
	flag_clear( "spawn_zombies" );
}

try_resume_zombie_spawning()
{
	if ( !isDefined( level.spawnpausecount ) )
	{
		level.spawnpausecount = 0;
	}
	level.spawnpausecount--;

	if ( level.spawnpausecount <= 0 )
	{
		level.spawnpausecount = 0;
		flag_set( "spawn_zombies" );
	}
}

triggerweaponslockerwatch()
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = ( 8236, -6844, 144 );
	unitrigger_stub.angles = vectorScale( ( 0, 0, 0 ), 30 );
	unitrigger_stub.script_length = 16;
	unitrigger_stub.script_width = 32;
	unitrigger_stub.script_height = 64;
	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length / 2 );
	unitrigger_stub.targetname = "weapon_locker";
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.clientfieldname = "weapon_locker";
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::triggerweaponslockerthinkupdateprompt;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::triggerweaponslockerthink );
}

triggerweaponslockerisvalidweapon( weaponname )
{
	if ( is_offhand_weapon( weaponname ) || is_limited_weapon( weaponname ) )
	{
		return 0;
	}
	return 1;
}

triggerweaponslockerisvalidweaponpromptupdate( player, weaponname )
{
	retrievingweapon = player maps/mp/zombies/_zm_stats::has_stored_weapondata();
	if ( !sessionmodeisonlinegame() )
	{
		if ( isDefined( player.stored_weapon_data ) )
		{
			retrievingweapon = 1;
		}
	}
	if ( !retrievingweapon )
	{
		if ( !triggerweaponslockerisvalidweapon( weaponname ) )
		{
			self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
		}
		else
		{
			self sethintstring( &"ZOMBIE_WEAPON_LOCKER_STORE" );
		}
	}
	else
	{
		self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
	}
}

triggerweaponslockerthinkupdateprompt( player )
{
	self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
	return 1;
}

triggerweaponslockerthink()
{
	self.parent_player thread triggerweaponslockerweaponchangethink( self );
	online_game = sessionmodeisonlinegame();
	while ( 1 )
	{
		self waittill( "trigger", player );
		retrievingweapon = player maps/mp/zombies/_zm_stats::has_stored_weapondata();
		if ( !online_game )
		{
			if ( isDefined( player.stored_weapon_data ) )
			{
				retrievingweapon = 1;
			}
		}
		if ( !retrievingweapon )
		{
			curweapon = player getcurrentweapon();
			curweapon = player maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( curweapon );
			while ( !triggerweaponslockerisvalidweapon( curweapon ) )
			{
				continue;
			}
			weapondata = player maps/mp/zombies/_zm_weapons::get_player_weapondata( player );
			player maps/mp/zombies/_zm_stats::set_stored_weapondata( weapondata );
			if ( !online_game )
			{
				player.stored_weapon_data = weapondata;
			}
/#
			assert( curweapon == weapondata[ "name" ], "weapon data does not match" );
#/
			player takeweapon( curweapon );
			primaries = player getweaponslistprimaries();
			if ( isDefined( primaries[ 0 ] ) )
			{
				player switchtoweapon( primaries[ 0 ] );
			}
			else
			{
				player maps/mp/zombies/_zm_weapons::give_fallback_weapon();
			}
			self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
			player playsoundtoplayer( "evt_fridge_locker_close", player );
		}
		else
		{
			curweapon = player getcurrentweapon();
			primaries = player getweaponslistprimaries();
			weapondata = player maps/mp/zombies/_zm_stats::get_stored_weapondata();
			weapontogive = player maps/mp/zombies/_zm_stats::get_map_weaponlocker_stat( "name" );
			if ( !online_game )
			{
				if ( isDefined( player.stored_weapon_data ) )
				{
					weapondata = player.stored_weapon_data;
					weapontogive = weapondata[ "name" ];
				}
			}
			curweap_base = maps/mp/zombies/_zm_weapons::get_base_weapon_name( curweapon, 1 );
			weap_base = maps/mp/zombies/_zm_weapons::get_base_weapon_name( weapontogive, 1 );
			while ( player has_weapon_or_upgrade( weap_base ) && weap_base != curweap_base )
			{
				self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
				wait 3;
				self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
			}
			if ( isDefined( player.weaponplusperkon ) && player.weaponplusperkon )
			{
				maxweapons = 3;
			}
			else
			{
				maxweapons = 2;
			}
			if ( isDefined( primaries ) || primaries.size >= maxweapons && weapontogive == curweapon )
			{
				curweapon = player maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( curweapon );
				while ( !triggerweaponslockerisvalidweapon( curweapon ) )
				{
					self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
					wait 3;
					self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
				}
				curweapondata = player maps/mp/zombies/_zm_weapons::get_player_weapondata( player );
				player takeweapon( curweapondata[ "name" ] );
				player maps/mp/zombies/_zm_weapons::weapondata_give( weapondata );
				player maps/mp/zombies/_zm_stats::clear_stored_weapondata();
				player maps/mp/zombies/_zm_stats::set_stored_weapondata( curweapondata );
				if ( !online_game )
				{
					player.stored_weapon_data = curweapondata;
				}
				player switchtoweapon( weapondata[ "name" ] );
				self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
			}
			else
			{
				player maps/mp/zombies/_zm_stats::clear_stored_weapondata();
				if ( !online_game )
				{
					player.stored_weapon_data = undefined;
				}
				player maps/mp/zombies/_zm_weapons::weapondata_give( weapondata );
				player switchtoweapon( weapondata[ "name" ] );
				self sethintstring( &"ZOMBIE_WEAPON_LOCKER_STORE" );
			}
			player playsoundtoplayer( "evt_fridge_locker_open", player );
		}
		wait 0,5;
	}
}

oldtriggerweaponslockerthink()
{
	self.parent_player thread triggerweaponslockerweaponchangethink( self );
	while ( 1 )
	{
		self waittill( "trigger", who );
		curweapon = who getcurrentweapon();
		weapontogive = who maps/mp/zombies/_zm_stats::get_map_weaponlocker_stat( "name" );
		clipammotogive = who maps/mp/zombies/_zm_stats::get_map_weaponlocker_stat( "clip" );
		lh_clipammotogive = who maps/mp/zombies/_zm_stats::get_map_weaponlocker_stat( "lh_clip" );
		stockammotogive = who maps/mp/zombies/_zm_stats::get_map_weaponlocker_stat( "stock" );
		retrievingweapon = 1;
		if ( isstring( weapontogive ) || weapontogive == "" && isint( weapontogive ) && weapontogive == 0 )
		{
			retrievingweapon = 0;
		}
		if ( !retrievingweapon && !triggerweaponslockerisvalidweapon( curweapon ) )
		{
			continue;
		}
		juststoredweapon = 0;
		if ( !retrievingweapon )
		{
			weapontogive = undefined;
			clipammotogive = undefined;
			lh_clipammotogive = undefined;
			stockammotogive = undefined;
		}
		primaries = who getweaponslistprimaries();
		if ( isDefined( who.weaponplusperkon ) && who.weaponplusperkon )
		{
			maxweapons = 3;
		}
		else
		{
			maxweapons = 2;
		}
		haswallweapon = undefined;
		if ( maps/mp/zombies/_zm_weapons::is_weapon_upgraded( weapontogive ) )
		{
			if ( isDefined( weapontogive ) )
			{
				haswallweapon = who maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( maps/mp/zombies/_zm_weapons::get_base_weapon_name( weapontogive ) );
			}
		}
		else
		{
			if ( isDefined( weapontogive ) )
			{
				haswallweapon = who maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( weapontogive );
			}
		}
		if ( haswallweapon || isDefined( primaries ) && primaries.size < maxweapons )
		{
			storedweapon = undefined;
			storedammoclip = undefined;
			storedammolhclip = undefined;
			storedammostock = undefined;
			self sethintstring( &"ZOMBIE_WEAPON_LOCKER_STORE" );
			who playsoundtoplayer( "evt_fridge_locker_open", who );
		}
		else
		{
			storedweapon = who getcurrentweapon();
			dual_wield_name = weapondualwieldweaponname( storedweapon );
			juststoredweapon = 1;
			who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "name", storedweapon );
			who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "clip", who getweaponammoclip( storedweapon ) );
			if ( dual_wield_name != "none" )
			{
				who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "lh_clip", who getweaponammoclip( weapondualwieldweaponname( storedweapon ) ) );
			}
			else
			{
				who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "lh_clip", 0 );
			}
			who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "stock", who getweaponammostock( storedweapon ) );
			who takeweapon( storedweapon );
			if ( !isDefined( weapontogive ) )
			{
				primaries = who getweaponslistprimaries();
				who switchtoweapon( primaries[ 0 ] );
			}
			self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
			who playsoundtoplayer( "evt_fridge_locker_close", who );
		}
		if ( isDefined( weapontogive ) )
		{
			dual_wield_name = weapondualwieldweaponname( weapontogive );
			if ( haswallweapon )
			{
				curretclipammo = who getweaponammoclip( weapontogive );
				if ( isDefined( curretclipammo ) )
				{
					stockammotogive += curretclipammo;
				}
				curretstockammo = who getweaponammostock( weapontogive );
				if ( isDefined( curretstockammo ) )
				{
					stockammotogive += curretstockammo;
				}
				who setweaponammostock( weapontogive, stockammotogive );
			}
			else
			{
				who giveweapon( weapontogive, 0 );
				who setweaponammoclip( weapontogive, clipammotogive );
				if ( dual_wield_name != "none" )
				{
					who setweaponammoclip( weapondualwieldweaponname( weapontogive ), lh_clipammotogive );
				}
				who setweaponammostock( weapontogive, stockammotogive );
				who switchtoweapon( weapontogive );
				who playsoundtoplayer( "evt_fridge_locker_open", who );
				if ( !is_offhand_weapon( weapontogive ) )
				{
					who maps/mp/zombies/_zm_weapons::take_fallback_weapon();
				}
			}
			if ( !is_true( juststoredweapon ) )
			{
				who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "name", "" );
				who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "clip", 0 );
				who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "lh_clip", 0 );
				who maps/mp/zombies/_zm_stats::set_map_weaponlocker_stat( "stock", 0 );
			}
		}
		else
		{
			primaries = who getweaponslistprimaries();
			if ( primaries.size > 0 )
			{
				who switchtoweapon( primaries[ 0 ] );
			}
		}
		wait 0,5;
	}
}

triggerweaponslockerweaponchangethink( trigger )
{
	self endon( "disconnect" );
	self endon( "death" );
	trigger endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "weapon_change", newweapon );
		trigger triggerweaponslockerisvalidweaponpromptupdate( self, newweapon );
	}
}

automatonspeak( category, type, response, force_variant, override )
{
	if ( isDefined( level.automaton ) && !is_true( level.automaton.disabled_by_emp ) )
	{
/#
		if ( getDvar( #"6DF184E8" ) == "" )
		{
			iprintlnbold( "Automaton VO: " + type );
#/
		}
		if ( type != "leaving" && type != "leaving_warning" )
		{
			level.automaton notify( "want_to_be_speaking" );
			level.automaton waittill( "startspeaking" );
		}
		level.automaton maps/mp/zombies/_zm_audio::create_and_play_dialog( category, type, response, force_variant, override );
	}
}

is_thedouche()
{
	return self.characterindex == 0;
}

is_theconspiracytheorist()
{
	return self.characterindex == 1;
}

is_thefarmersdaughter()
{
	return self.characterindex == 2;
}

is_theelectricalengineer()
{
	return self.characterindex == 3;
}

get_random_encounter_match( location )
{
	match_pool = [];
/#
	assert( match_pool.size > 0, "Could not find a random encounters match for " + location );
#/
	return random( match_pool );
}

transit_breakable_glass_init()
{
	glass = getentarray( "transit_glass", "targetname" );
	if ( level.splitscreen && getDvarInt( "splitscreen_playerCount" ) > 2 )
	{
		array_delete( glass );
		return;
	}
	array_thread( glass, ::transit_breakable_glass );
}

transit_breakable_glass()
{
	level endon( "intermission" );
	self.health = 99999;
	self setcandamage( 1 );
	self.damage_state = 0;
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, dmg_type );
		if ( isplayer( attacker ) )
		{
			if ( self.damage_state == 0 )
			{
				self glass_gets_destroyed();
				self.damage_state = 1;
				self playsound( "fly_glass_break" );
			}
		}
	}
}

glass_gets_destroyed()
{
	if ( isDefined( level._effect[ "glass_impact" ] ) )
	{
		playfx( level._effect[ "glass_impact" ], self.origin, anglesToForward( self.angles ) );
	}
	wait 0,1;
	if ( isDefined( self.model ) && self.damage_state == 0 )
	{
		self setmodel( self.model + "_broken" );
		self.damage_state = 1;
		return;
	}
	else
	{
		self delete();
		return;
	}
}

solo_tombstone_removal()
{
	if ( getnumexpectedplayers() > 1 )
	{
		return;
	}
	level notify( "tombstone_removed" );
	level thread maps/mp/zombies/_zm_perks::perk_machine_removal( "specialty_scavenger" );
}

sparking_power_lines()
{
	lines = getentarray( "power_line_sparking", "targetname" );
}

disconnect_door_zones( zone_a, zone_b, flag_name )
{
	level endon( "intermission" );
	level endon( "end_game" );
	while ( 1 )
	{
		flag_wait( flag_name );
		azone = level.zones[ zone_a ].adjacent_zones[ zone_b ];
		azone maps/mp/zombies/_zm_zonemgr::door_close_disconnect( flag_name );
	}
}

enable_morse_code()
{
	level clientnotify( "mc1" );
}

disable_morse_code()
{
	level clientnotify( "mc0" );
}

transit_pathnode_spawning()
{
	precachemodel( "collision_wall_128x128x10_standard" );
	precachemodel( "collision_wall_256x256x10_standard" );
	precachemodel( "collision_clip_64x64x256" );
	minimap_upperl = spawn( "script_origin", ( -12248, 9496, 552 ) );
	minimap_upperl.targetname = "minimap_corner";
	minimap_lowerr = spawn( "script_origin", ( 14472, -8496, -776 ) );
	minimap_lowerr.targetname = "minimap_corner";
	maps/mp/_compass::setupminimap( "compass_map_zm_transit" );
	flag_wait( "start_zombie_round_logic" );
	collision1 = spawn( "script_model", ( 2273, -126, 143 ) );
	collision1 setmodel( "collision_wall_128x128x10_standard" );
	collision1.angles = ( 0, 0, 0 );
	collision1 ghost();
	collision2 = spawn( "script_model", ( 2096, -126, 143 ) );
	collision2 setmodel( "collision_wall_128x128x10_standard" );
	collision2.angles = ( 0, 0, 0 );
	collision2 ghost();
	collision3 = spawn( "script_model", ( 1959, -126, 143 ) );
	collision3 setmodel( "collision_wall_128x128x10_standard" );
	collision3.angles = ( 0, 0, 0 );
	collision3 ghost();
	collision4 = spawn( "script_model", ( 12239, 8509, -688 ) );
	collision4 setmodel( "collision_wall_128x128x10_standard" );
	collision4.angles = ( 0, 0, 0 );
	collision4 ghost();
	collision5 = spawn( "script_model", ( 8320, -6679, 362 ) );
	collision5 setmodel( "collision_wall_256x256x10_standard" );
	collision5.angles = vectorScale( ( 0, 0, 0 ), 300 );
	collision5 ghost();
	collision5 = spawn( "script_model", ( 10068, 7272, -67 ) );
	collision5 setmodel( "collision_clip_64x64x256" );
	collision5.angles = ( 0, 0, 0 );
	collision5 ghost();
}
