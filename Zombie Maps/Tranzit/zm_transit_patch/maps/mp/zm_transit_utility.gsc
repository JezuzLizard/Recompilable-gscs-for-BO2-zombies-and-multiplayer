#include maps/mp/_compass;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_audio;
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

automatonspeak( category, type, response, force_variant, override )
{
	if ( isDefined( level.automaton ) && !is_true( level.automaton.disabled_by_emp ) )
	{
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
	wait 0.1;
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

