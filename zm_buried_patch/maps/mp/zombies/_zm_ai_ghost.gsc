#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weap_time_bomb;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_weap_slowgun;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_ai_ghost;
#include maps/mp/zombies/_zm_ai_ghost_ffotd;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "zm_buried_ghost" );

precache()
{
}

init_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

precache_fx()
{
	if ( !isDefined( level.ghost_effects ) )
	{
		level.ghost_effects = [];
		level.ghost_effects[ 1 ] = loadfx( "maps/zombie_buried/fx_buried_ghost_death" );
		level.ghost_effects[ 2 ] = loadfx( "maps/zombie_buried/fx_buried_ghost_drain" );
		level.ghost_effects[ 3 ] = loadfx( "maps/zombie_buried/fx_buried_ghost_spawn" );
		level.ghost_effects[ 4 ] = loadfx( "maps/zombie_buried/fx_buried_ghost_trail" );
		level.ghost_effects[ 5 ] = loadfx( "maps/zombie_buried/fx_buried_ghost_evaporation" );
		level.ghost_impact_effects[ 1 ] = loadfx( "maps/zombie_buried/fx_buried_ghost_impact" );
	}
}

init()
{
	maps/mp/zombies/_zm_ai_ghost_ffotd::ghost_init_start();
	register_client_fields();
	flag_init( "spawn_ghosts" );
	if ( !init_ghost_spawners() )
	{
		return;
	}
	init_ghost_zone();
	init_ghost_sounds();
	init_ghost_script_move_path_data();
	level.zombie_ai_limit_ghost = 4;
	level.zombie_ai_limit_ghost_per_player = 1;
	level.zombie_ghost_count = 0;
	level.ghost_health = 100;
	level.zombie_ghost_round_states = spawnstruct();
	level.zombie_ghost_round_states.any_player_in_ghost_zone = 0;
	level.zombie_ghost_round_states.active_zombie_locations = [];
	level.is_ghost_round_started = ::is_ghost_round_started;
	level.zombie_ghost_round_states.is_started = 0;
	level.zombie_ghost_round_states.is_first_ghost_round_finished = 0;
	level.zombie_ghost_round_states.current_ghost_round_number = 0;
	level.zombie_ghost_round_states.next_ghost_round_number = 0;
	level.zombie_ghost_round_states.presentation_stage_1_started = 0;
	level.zombie_ghost_round_states.presentation_stage_2_started = 0;
	level.zombie_ghost_round_states.presentation_stage_3_started = 0;
	level.zombie_ghost_round_states.is_teleporting = 0;
	level.zombie_ghost_round_states.round_count = 0;
	level thread ghost_round_presentation_think();
	if ( isDefined( level.ghost_round_think_override_func ) )
	{
		level thread [[ level.ghost_round_think_override_func ]]();
	}
	else
	{
		level thread ghost_round_think();
	}
	level thread player_in_ghost_zone_monitor();
	if ( isDefined( level.ghost_zone_spawning_think_override_func ) )
	{
		level thread [[ level.ghost_zone_spawning_think_override_func ]]();
	}
	else
	{
		level thread ghost_zone_spawning_think();
	}
	level thread ghost_vox_think();
	init_time_bomb_ghost_rounds();
/#
	level.force_no_ghost = 0;
	level.ghost_devgui_toggle_no_ghost = ::devgui_toggle_no_ghost;
	level.ghost_devgui_warp_to_mansion = ::devgui_warp_to_mansion;
#/
	maps/mp/zombies/_zm_ai_ghost_ffotd::ghost_init_end();
}

init_ghost_spawners()
{
	level.ghost_spawners = getentarray( "ghost_zombie_spawner", "script_noteworthy" );
	if ( level.ghost_spawners.size == 0 )
	{
		return 0;
	}
	array_thread( level.ghost_spawners, ::add_spawn_function, ::prespawn );
	_a131 = level.ghost_spawners;
	_k131 = getFirstArrayKey( _a131 );
	while ( isDefined( _k131 ) )
	{
		spawner = _a131[ _k131 ];
		if ( spawner.targetname == "female_ghost" )
		{
			level.female_ghost_spawner = spawner;
		}
		_k131 = getNextArrayKey( _a131, _k131 );
	}
	return 1;
}

init_ghost_script_move_path_data()
{
	level.ghost_script_move_sin = [];
	degree = 0;
	while ( degree < 360 )
	{
		level.ghost_script_move_sin[ level.ghost_script_move_sin.size ] = sin( degree );
		degree += 15;
	}
}

init_ghost_sounds()
{
	level.ghost_vox = [];
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_0";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_1";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_2";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_3";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_4";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_5";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_6";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_7";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_8";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_9";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_10";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_11";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_12";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_13";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_14";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_15";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_16";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_17";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_18";
	level.ghost_vox[ level.ghost_vox.size ] = "vox_fg_ghost_haunt_19";
}

init_ghost_zone()
{
	level.ghost_start_area = getent( "ghost_start_area", "targetname" );
	level.ghost_zone_door_clips = getentarray( "ghost_zone_door_clip", "targetname" );
	enable_ghost_zone_door_ai_clips();
	level.ghost_zone_start_lower_locations = getstructarray( "ghost_zone_start_lower_location", "targetname" );
	level.ghost_drop_down_locations = getstructarray( "ghost_start_zone_spawners", "targetname" );
	level.ghost_front_standing_locations = getstructarray( "ghost_front_standing_location", "targetname" );
	level.ghost_back_standing_locations = getstructarray( "ghost_back_standing_location", "targetname" );
	level.ghost_front_flying_out_path_starts = getstructarray( "ghost_front_flying_out_path_start", "targetname" );
	level.ghost_back_flying_out_path_starts = getstructarray( "ghost_back_flying_out_path_start", "targetname" );
	level.ghost_gazebo_pit_volume = getent( "sloth_pack_volume", "targetname" );
	level.ghost_gazebo_pit_perk_pos = getstruct( "ghost_gazebo_pit_perk_pos", "targetname" );
	level.ghost_entry_room_to_mansion = "ghost_to_maze_zone_1";
	level.ghost_entry_room_to_maze = "ghost_to_maze_zone_5";
	level.ghost_rooms = [];
	a_rooms = getentarray( "ghost_zone", "script_noteworthy" );
	_a216 = a_rooms;
	_k216 = getFirstArrayKey( _a216 );
	while ( isDefined( _k216 ) )
	{
		room = _a216[ _k216 ];
		str_targetname = room.targetname;
		if ( !isDefined( level.ghost_rooms[ str_targetname ] ) )
		{
			level.ghost_rooms[ str_targetname ] = spawnstruct();
			level.ghost_rooms[ str_targetname ].ghost_spawn_locations = [];
			level.ghost_rooms[ str_targetname ].volumes = [];
			level.ghost_rooms[ str_targetname ].name = str_targetname;
			if ( issubstr( str_targetname, "from_maze" ) )
			{
				level.ghost_rooms[ str_targetname ].from_maze = 1;
				break;
			}
			else
			{
				if ( issubstr( str_targetname, "to_maze" ) )
				{
					level.ghost_rooms[ str_targetname ].to_maze = 1;
				}
			}
		}
/#
		assert( isDefined( room.target ), "ghost zone with targetname '" + str_targetname + "' is missing spawner target! This is used to pair zones with spawners." );
#/
		a_ghost_spawn_locations = getstructarray( room.target, "targetname" );
		level.ghost_rooms[ str_targetname ].ghost_spawn_locations = arraycombine( a_ghost_spawn_locations, level.ghost_rooms[ str_targetname ].ghost_spawn_locations, 0, 0 );
		level.ghost_rooms[ str_targetname ].volumes[ level.ghost_rooms[ str_targetname ].volumes.size ] = room;
		if ( isDefined( room.script_string ) )
		{
			level.ghost_rooms[ str_targetname ].next_room_names = strtok( room.script_string, " " );
		}
		if ( isDefined( room.script_parameters ) )
		{
			level.ghost_rooms[ str_targetname ].previous_room_names = strtok( room.script_parameters, " " );
		}
		if ( isDefined( room.script_flag ) )
		{
			level.ghost_rooms[ str_targetname ].flag = room.script_flag;
		}
		_k216 = getNextArrayKey( _a216, _k216 );
	}
}

register_client_fields()
{
	registerclientfield( "actor", "ghost_impact_fx", 12000, 1, "int" );
	registerclientfield( "actor", "ghost_fx", 12000, 3, "int" );
	registerclientfield( "actor", "sndGhostAudio", 12000, 3, "int" );
	registerclientfield( "scriptmover", "ghost_fx", 12000, 3, "int" );
	registerclientfield( "scriptmover", "sndGhostAudio", 12000, 3, "int" );
	registerclientfield( "world", "ghost_round_light_state", 12000, 1, "int" );
}

is_player_fully_claimed( player )
{
	result = 0;
	if ( isDefined( player.ghost_count ) && player.ghost_count >= level.zombie_ai_limit_ghost_per_player )
	{
		result = 1;
	}
	return result;
}

ghost_zone_spawning_think()
{
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	if ( !isDefined( level.female_ghost_spawner ) )
	{
/#
		assertmsg( "No female ghost spawner in the map.  Check to see if the zone is active and if it's pointing to spawners." );
#/
		return;
	}
	while ( 1 )
	{
		while ( level.zombie_ghost_count >= level.zombie_ai_limit_ghost )
		{
			wait 0,1;
		}
		valid_player_count = 0;
		valid_players = [];
		while ( valid_player_count < 1 )
		{
			players = getplayers();
			valid_player_count = 0;
			_a319 = players;
			_k319 = getFirstArrayKey( _a319 );
			while ( isDefined( _k319 ) )
			{
				player = _a319[ _k319 ];
				if ( is_player_valid( player ) && !is_player_fully_claimed( player ) )
				{
					if ( isDefined( player.is_in_ghost_zone ) || player.is_in_ghost_zone && is_ghost_round_started() && isDefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone )
					{
						valid_player_count++;
						valid_players[ valid_players.size ] = player;
					}
				}
				_k319 = getNextArrayKey( _a319, _k319 );
			}
			wait 0,1;
		}
		valid_players = array_randomize( valid_players );
		spawn_point = get_best_spawn_point( valid_players[ 0 ] );
		while ( !isDefined( spawn_point ) )
		{
			wait 0,1;
		}
/#
		while ( isDefined( level.force_no_ghost ) && level.force_no_ghost )
		{
			wait 0,1;
#/
		}
		ghost_ai = undefined;
		if ( isDefined( level.female_ghost_spawner ) )
		{
			ghost_ai = spawn_zombie( level.female_ghost_spawner, level.female_ghost_spawner.targetname, spawn_point );
		}
		else
		{
/#
			assertmsg( "No female ghost spawner in the map." );
#/
			return;
		}
		if ( isDefined( ghost_ai ) )
		{
			ghost_ai setclientfield( "ghost_fx", 3 );
			ghost_ai.spawn_point = spawn_point;
			ghost_ai.is_ghost = 1;
			ghost_ai.is_spawned_in_ghost_zone = 1;
			ghost_ai.find_target = 1;
			level.zombie_ghost_count++;
/#
			ghost_print( "ghost total " + level.zombie_ghost_count );
#/
		}
		else
		{
/#
			assertmsg( "Female ghost: failed spawn" );
#/
			return;
		}
		wait 0,1;
	}
}

is_player_in_ghost_room( player, room )
{
	_a392 = room.volumes;
	_k392 = getFirstArrayKey( _a392 );
	while ( isDefined( _k392 ) )
	{
		volume = _a392[ _k392 ];
		if ( player istouching( volume ) )
		{
			return 1;
		}
		_k392 = getNextArrayKey( _a392, _k392 );
	}
	return 0;
}

is_player_in_ghost_rooms( player, room_names )
{
	result = 0;
	while ( isDefined( room_names ) )
	{
		_a408 = room_names;
		_k408 = getFirstArrayKey( _a408 );
		while ( isDefined( _k408 ) )
		{
			room_name = _a408[ _k408 ];
			next_room = level.ghost_rooms[ room_name ];
			if ( is_player_in_ghost_room( player, next_room ) )
			{
				player.current_ghost_room_name = next_room.name;
				result = 1;
				break;
			}
			else
			{
				_k408 = getNextArrayKey( _a408, _k408 );
			}
		}
	}
	return result;
}

player_in_ghost_zone_monitor()
{
	level endon( "intermission" );
	if ( level.intermission )
	{
		return;
	}
	while ( 1 )
	{
		while ( isDefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone )
		{
			players = getplayers();
			_a437 = players;
			_k437 = getFirstArrayKey( _a437 );
			while ( isDefined( _k437 ) )
			{
				player = _a437[ _k437 ];
				if ( is_player_valid( player ) && isDefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone )
				{
					if ( isDefined( player.current_ghost_room_name ) )
					{
						current_room = level.ghost_rooms[ player.current_ghost_room_name ];
/#
						_a448 = current_room.ghost_spawn_locations;
						_k448 = getFirstArrayKey( _a448 );
						while ( isDefined( _k448 ) )
						{
							ghost_location = _a448[ _k448 ];
							draw_debug_star( ghost_location.origin, ( 1, 1, 1 ), 2 );
							_k448 = getNextArrayKey( _a448, _k448 );
						}
						_a452 = current_room.volumes;
						_k452 = getFirstArrayKey( _a452 );
						while ( isDefined( _k452 ) )
						{
							volume = _a452[ _k452 ];
							draw_debug_box( volume.origin, vectorScale( ( 1, 1, 1 ), 5 ), vectorScale( ( 1, 1, 1 ), 5 ), volume.angles[ 1 ], vectorScale( ( 1, 1, 1 ), 0,5 ), 2 );
							_k452 = getNextArrayKey( _a452, _k452 );
#/
						}
						if ( is_player_in_ghost_room( player, current_room ) )
						{
							player.current_ghost_room_name = current_room.name;
							break;
						}
						else if ( is_player_in_ghost_rooms( player, current_room.next_room_names ) )
						{
							break;
						}
						else if ( is_player_in_ghost_rooms( player, current_room.previous_room_names ) )
						{
							break;
						}
						else }
					else player.current_ghost_room_name = level.ghost_entry_room_to_mansion;
				}
				_k437 = getNextArrayKey( _a437, _k437 );
			}
		}
		wait 0,1;
	}
}

is_any_player_near_point( target, spawn_pos )
{
	players = getplayers();
	_a493 = players;
	_k493 = getFirstArrayKey( _a493 );
	while ( isDefined( _k493 ) )
	{
		player = _a493[ _k493 ];
		if ( target != player && is_player_valid( player ) )
		{
			dist_squared = distancesquared( player.origin, spawn_pos );
			if ( dist_squared < ( 84 * 84 ) )
			{
				return 1;
			}
		}
		_k493 = getNextArrayKey( _a493, _k493 );
	}
	return 0;
}

is_in_start_area()
{
	if ( isDefined( level.ghost_start_area ) && self istouching( level.ghost_start_area ) )
	{
		return 1;
	}
	return 0;
}

get_best_spawn_point( player )
{
	spawn_point = undefined;
	if ( isDefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone )
	{
		if ( isDefined( player.current_ghost_room_name ) )
		{
			min_distance_squared = 9600 * 9600;
			selected_locations = [];
			current_ghost_room_name = player.current_ghost_room_name;
			_a530 = level.ghost_rooms[ current_ghost_room_name ].ghost_spawn_locations;
			_k530 = getFirstArrayKey( _a530 );
			while ( isDefined( _k530 ) )
			{
				ghost_location = _a530[ _k530 ];
				player_eye_pos = player geteyeapprox();
				line_of_sight = sighttracepassed( player_eye_pos, ghost_location.origin, 0, self );
				if ( isDefined( line_of_sight ) && !line_of_sight )
				{
					if ( !self is_any_player_near_point( player, ghost_location.origin ) )
					{
						selected_locations[ selected_locations.size ] = ghost_location;
					}
				}
				_k530 = getNextArrayKey( _a530, _k530 );
			}
			if ( selected_locations.size > 0 )
			{
				selected_location = selected_locations[ randomint( selected_locations.size ) ];
/#
				draw_debug_line( player.origin, selected_location.origin, ( 1, 1, 1 ), 10, 0 );
#/
				return selected_location;
			}
		}
	}
	else
	{
		if ( is_ghost_round_started() && isDefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone )
		{
			if ( isDefined( player.current_ghost_room_name ) && player.current_ghost_room_name == level.ghost_entry_room_to_maze )
			{
				random_index = randomint( level.ghost_back_standing_locations.size );
				return level.ghost_back_standing_locations[ random_index ];
			}
			else
			{
				if ( player is_in_start_area() )
				{
					random_index = randomint( level.ghost_zone_start_lower_locations.size );
					return level.ghost_zone_start_lower_locations[ random_index ];
				}
				else
				{
					random_index = randomint( level.ghost_front_standing_locations.size );
					return level.ghost_front_standing_locations[ random_index ];
				}
			}
		}
	}
	return undefined;
}

check_players_in_ghost_zone()
{
	result = 0;
	players = getplayers();
	_a589 = players;
	_k589 = getFirstArrayKey( _a589 );
	while ( isDefined( _k589 ) )
	{
		player = _a589[ _k589 ];
		if ( is_player_valid( player, 0, 1 ) && player_in_ghost_zone( player ) )
		{
			result = 1;
		}
		_k589 = getNextArrayKey( _a589, _k589 );
	}
	return result;
}

player_in_ghost_zone( player )
{
	result = 0;
	if ( isDefined( level.is_player_in_ghost_zone ) )
	{
		result = [[ level.is_player_in_ghost_zone ]]( player );
	}
	player.is_in_ghost_zone = result;
	return result;
}

ghost_vox_think()
{
	level endon( "end_game" );
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	while ( 1 )
	{
		ghosts = get_current_ghosts();
		while ( ghosts.size > 0 )
		{
			_a628 = ghosts;
			_k628 = getFirstArrayKey( _a628 );
			while ( isDefined( _k628 ) )
			{
				ghost = _a628[ _k628 ];
				if ( isDefined( ghost.favoriteenemy ) && isDefined( ghost.favoriteenemy.ghost_talking ) && !ghost.favoriteenemy.ghost_talking )
				{
					ghost thread ghost_talk_to_target( ghost.favoriteenemy );
				}
				_k628 = getNextArrayKey( _a628, _k628 );
			}
		}
		wait randomintrange( 2, 6 );
	}
}

ghost_talk_to_target( player )
{
	self endon( "death" );
	level endon( "intermission" );
	vox_index = randomint( level.ghost_vox.size );
	vox_line = level.ghost_vox[ vox_index ];
	self playsoundtoplayer( vox_line, player );
	player.ghost_talking = 1;
	wait 6;
	player.ghost_talking = 0;
}

prespawn()
{
	self endon( "death" );
	level endon( "intermission" );
	self maps/mp/zombies/_zm_ai_ghost_ffotd::prespawn_start();
	self.startinglocation = self.origin;
	self.animname = "ghost_zombie";
	self.audio_type = "ghost";
	self.has_legs = 1;
	self.no_gib = 1;
	self.ignore_enemy_count = 1;
	self.ignore_equipment = 1;
	self.ignore_claymore = 0;
	self.force_killable_timer = 0;
	self.noplayermeleeblood = 1;
	self.paralyzer_hit_callback = ::paralyzer_callback;
	self.paralyzer_slowtime = 0;
	self.paralyzer_score_time_ms = getTime();
	self.ignore_slowgun_anim_rates = undefined;
	self.reset_anim = ::ghost_reset_anim;
	self.custom_springpad_fling = ::ghost_springpad_fling;
	self.bookcase_entering_callback = ::bookcase_entering_callback;
	self.ignore_subwoofer = 1;
	self.ignore_headchopper = 1;
	self.ignore_spring_pad = 1;
	recalc_zombie_array();
	self setphysparams( 15, 0, 72 );
	self.cant_melee = 1;
	if ( isDefined( self.spawn_point ) )
	{
		spot = self.spawn_point;
		if ( !isDefined( spot.angles ) )
		{
			spot.angles = ( 1, 1, 1 );
		}
		self forceteleport( spot.origin, spot.angles );
	}
	self set_zombie_run_cycle( "run" );
	self setanimstatefromasd( "zm_move_run" );
	self.actor_damage_func = ::ghost_damage_func;
	self.deathfunction = ::ghost_death_func;
	self.maxhealth = level.ghost_health;
	self.health = level.ghost_health;
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
	self.allowpain = 0;
	self.ignore_nuke = 1;
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self bloodimpact( "none" );
	self disableaimassist();
	self.forcemovementscriptstate = 0;
	self maps/mp/zombies/_zm_spawner::zombie_setup_attack_properties();
	if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
	{
		self.pathenemyfightdist = 0;
	}
	self maps/mp/zombies/_zm_spawner::zombie_complete_emerging_into_playable_area();
	self setfreecameralockonallowed( 0 );
	self.startinglocation = self.origin;
	if ( isDefined( level.ghost_custom_think_logic ) )
	{
		self [[ level.ghost_custom_think_logic ]]();
	}
	self.bad_path_failsafe = ::maps/mp/zombies/_zm_ai_ghost_ffotd::ghost_bad_path_failsafe;
	self thread ghost_think();
	self.attack_time = 0;
	self.ignore_inert = 1;
	self.subwoofer_burst_func = ::subwoofer_burst_func;
	self.subwoofer_fling_func = ::subwoofer_fling_func;
	self.subwoofer_knockdown_func = ::subwoofer_knockdown_func;
	self maps/mp/zombies/_zm_ai_ghost_ffotd::prespawn_end();
}

bookcase_entering_callback( bookcase_door )
{
	self endon( "death" );
	while ( 1 )
	{
		if ( isDefined( bookcase_door._door_open ) && bookcase_door._door_open )
		{
			if ( isDefined( bookcase_door.door_moving ) && bookcase_door.door_moving )
			{
				self.need_wait = 1;
				wait 2,1;
				self.need_wait = 0;
			}
			else
			{
				self.need_wait = 0;
			}
			return;
		}
		else self.need_wait = 1;
		wait 0,1;
	}
}

ghost_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( sweapon == "equip_headchopper_zm" )
	{
		self.damageweapon_name = sweapon;
		self check_zombie_damage_callbacks( smeansofdeath, shitloc, vpoint, eattacker, idamage );
		self.damageweapon_name = undefined;
	}
	if ( idamage >= self.health )
	{
		self.killed_by = eattacker;
		self thread prepare_to_die();
	}
	self thread set_impact_effect();
	return idamage;
}

set_impact_effect()
{
	self endon( "death" );
	self setclientfield( "ghost_impact_fx", 1 );
	wait_network_frame();
	self setclientfield( "ghost_impact_fx", 0 );
}

prepare_to_die()
{
	qrate = self getclientfield( "anim_rate" );
	if ( qrate < 0,8 )
	{
		self.ignore_slowgun_anim_rates = 1;
		self setclientfield( "anim_rate", 1 );
		qrate = self getclientfield( "anim_rate" );
		self setentityanimrate( qrate );
		self.slowgun_anim_rate = qrate;
		wait_network_frame();
		self setclientfield( "anim_rate", 0,8 );
		qrate = self getclientfield( "anim_rate" );
		self setentityanimrate( qrate );
		wait_network_frame();
		ghost_reset_anim();
	}
}

ghost_reset_anim()
{
	if ( !isDefined( self ) )
	{
		return;
	}
	animstate = self getanimstatefromasd();
	substate = self getanimsubstatefromasd();
	if ( animstate == "zm_death" )
	{
		self setanimstatefromasd( "zm_death_no_restart", substate );
	}
	else
	{
		self maps/mp/zombies/_zm_weap_slowgun::reset_anim();
	}
}

wait_ghost_ghost( time )
{
	wait time;
	if ( isDefined( self ) )
	{
		self ghost();
	}
}

ghost_death_func()
{
	if ( get_current_ghost_count() == 0 )
	{
		level.ghost_round_last_ghost_origin = self.origin;
	}
	self stoploopsound( 1 );
	self playsound( "zmb_ai_ghost_death" );
	self setclientfield( "ghost_impact_fx", 1 );
	self setclientfield( "ghost_fx", 1 );
	self thread prepare_to_die();
	if ( isDefined( self.extra_custom_death_logic ) )
	{
		self thread [[ self.extra_custom_death_logic ]]();
	}
	qrate = self getclientfield( "anim_rate" );
	self setanimstatefromasd( "zm_death" );
	self thread wait_ghost_ghost( self getanimlengthfromasd( "zm_death", 0 ) );
	maps/mp/animscripts/zm_shared::donotetracks( "death_anim" );
	if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
	{
		level.zombie_ghost_count--;

		if ( isDefined( self.favoriteenemy ) )
		{
			if ( isDefined( self.favoriteenemy.ghost_count ) && self.favoriteenemy.ghost_count > 0 )
			{
				self.favoriteenemy.ghost_count--;

			}
		}
	}
	player = undefined;
	if ( is_player_valid( self.attacker ) )
	{
		give_player_rewards( self.attacker );
		player = self.attacker;
	}
	else
	{
		if ( isDefined( self.attacker ) && is_player_valid( self.attacker.owner ) )
		{
			give_player_rewards( self.attacker.owner );
			player = self.attacker.owner;
		}
	}
	if ( isDefined( player ) )
	{
		player maps/mp/zombies/_zm_stats::increment_client_stat( "buried_ghost_killed", 0 );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "buried_ghost_killed" );
	}
	self delete();
	return 1;
}

subwoofer_burst_func( weapon )
{
	self dodamage( self.health + 666, weapon.origin );
}

subwoofer_fling_func( weapon, fling_vec )
{
	self dodamage( self.health + 666, weapon.origin );
}

subwoofer_knockdown_func( weapon, gib )
{
}

ghost_think()
{
	self endon( "death" );
	level endon( "intermission" );
	if ( isDefined( level.ghost_round_presentation_ghost ) && level.ghost_round_presentation_ghost == self )
	{
		return;
	}
	if ( isDefined( level.ghost_custom_think_func_logic ) )
	{
		shouldwait = self [[ level.ghost_custom_think_func_logic ]]();
		if ( shouldwait )
		{
			self waittill( "ghost_custom_think_done", find_flesh_struct_string );
		}
	}
	self.ignore_slowgun_anim_rates = undefined;
	self maps/mp/zombies/_zm_weap_slowgun::set_anim_rate( 1 );
	self setclientfield( "slowgun_fx", 0 );
	self setclientfield( "sndGhostAudio", 1 );
	self init_thinking();
	if ( isDefined( self.need_script_move ) && self.need_script_move )
	{
		self start_script_move();
	}
	else
	{
		if ( isDefined( self.is_spawned_in_ghost_zone ) && !self.is_spawned_in_ghost_zone && isDefined( self.respawned_by_time_bomb ) && !self.respawned_by_time_bomb )
		{
			self start_spawn();
		}
		else
		{
			self start_chase();
		}
	}
	if ( isDefined( self.bad_path_failsafe ) )
	{
		self thread [[ self.bad_path_failsafe ]]();
	}
	while ( 1 )
	{
		switch( self.state )
		{
			case "script_move_update":
				self script_move_update();
				break;
			case "chase_update":
				self chase_update();
				break;
			case "drain_update":
				self drain_update();
				break;
			case "runaway_update":
				self runaway_update();
				break;
			case "evaporate_update":
				self evaporate_update();
				break;
			case "wait_update":
				self wait_update();
				break;
		}
		wait 0,1;
	}
}

start_spawn()
{
	self animscripted( self.origin, self.angles, "zm_spawn" );
	self maps/mp/animscripts/zm_shared::donotetracks( "spawn_anim" );
	self start_chase();
}

init_thinking()
{
	self thread find_flesh();
}

find_flesh()
{
	self endon( "death" );
	level endon( "intermission" );
	self endon( "stop_find_flesh" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	self.nododgemove = 1;
	self.ignore_player = [];
	self zombie_history( "ghost find flesh -> start" );
	self.goalradius = 32;
	while ( 1 )
	{
		if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
		{
			if ( isDefined( self.find_target ) && self.find_target )
			{
				self.favoriteenemy = get_closest_valid_player( self.origin );
				self.find_target = 0;
			}
		}
		else
		{
			self.favoriteenemy = get_closest_valid_player( self.origin );
		}
		if ( isDefined( self.favoriteenemy ) )
		{
			self thread zombie_pathing();
		}
		else
		{
			if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
			{
				self.find_target = 1;
			}
		}
		self.zombie_path_timer = getTime() + ( randomfloatrange( 1, 3 ) * 1000 );
		while ( getTime() < self.zombie_path_timer )
		{
			wait 0,1;
		}
		self notify( "path_timer_done" );
		self zombie_history( "ghost find flesh -> path timer done" );
		debug_print( "Zombie is re-acquiring enemy, ending breadcrumb search" );
		self notify( "zombie_acquire_enemy" );
	}
}

get_closest_valid_player( origin )
{
	valid_player_found = 0;
	players = get_players();
	while ( !valid_player_found )
	{
		player = get_closest_player( origin, players );
		if ( !isDefined( player ) )
		{
			return undefined;
		}
		if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
		{
			player_claimed_fully = is_player_fully_claimed( player );
			if ( players.size == 1 && player_claimed_fully )
			{
				return undefined;
			}
			while ( is_player_valid( player, 1 ) && !is_ghost_round_started() && isDefined( player.is_in_ghost_zone ) || !player.is_in_ghost_zone && player_claimed_fully )
			{
				arrayremovevalue( players, player );
			}
			if ( isDefined( player.is_in_ghost_zone ) && !player.is_in_ghost_zone && !player is_in_start_area() )
			{
				self.need_script_move = 1;
			}
			if ( !isDefined( player.ghost_count ) )
			{
				player.ghost_count = 1;
			}
			else
			{
				player.ghost_count += 1;
			}
		}
		else
		{
			while ( !is_player_valid( player, 1 ) )
			{
				arrayremovevalue( players, player );
			}
		}
		return player;
	}
}

get_closest_player( origin, players )
{
	min_length_to_player = 9999999;
	player_to_return = undefined;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		length_to_player = get_path_length_to_enemy( player );
		if ( length_to_player == 0 )
		{
			i++;
			continue;
		}
		else
		{
			if ( length_to_player < min_length_to_player )
			{
				min_length_to_player = length_to_player;
				player_to_return = player;
			}
		}
		i++;
	}
	if ( !isDefined( player_to_return ) )
	{
		player_to_return = getclosest( origin, players );
	}
	return player_to_return;
}

does_fall_into_pap_hole()
{
	if ( self istouching( level.ghost_gazebo_pit_volume ) )
	{
		self forceteleport( level.ghost_gazebo_pit_perk_pos.origin, ( 1, 1, 1 ) );
		wait 0,1;
		return 1;
	}
	return 0;
}

start_script_move()
{
	self.script_mover = spawn( "script_origin", self.origin );
	self.script_mover.angles = self.angles;
	self linkto( self.script_mover );
	self.state = "script_move_update";
	self setclientfield( "ghost_fx", 4 );
	player = self.favoriteenemy;
	if ( is_player_valid( player ) )
	{
		start_location = undefined;
		if ( isDefined( player.current_ghost_room_name ) && player.current_ghost_room_name == level.ghost_entry_room_to_maze )
		{
			start_location = level.ghost_back_flying_out_path_starts[ 0 ];
		}
		else
		{
			start_location = level.ghost_front_flying_out_path_starts[ 0 ];
		}
		self.script_move_target_node = self get_best_flying_target_node( player, start_location.origin );
	}
	self.script_move_sin_index = 0;
}

get_best_flying_target_node( player, start_loc )
{
	nearest_node = getnearestnode( player.origin );
	nodes = getnodesinradiussorted( player.origin, 540, 180, 60, "Path" );
	if ( !isDefined( nearest_node ) && nodes.size > 0 )
	{
		nearest_node = nodes[ 0 ];
	}
	selected_node = nearest_node;
	max_distance_squared = 0;
	start_pos = ( player.origin[ 0 ], player.origin[ 1 ], player.origin[ 2 ] + 60 );
	i = nodes.size - 1;
	while ( i >= 0 )
	{
		node = nodes[ i ];
		end_pos = ( node.origin[ 0 ], node.origin[ 1 ], node.origin[ 2 ] + 60 );
		line_of_sight = sighttracepassed( start_pos, end_pos, 0, player );
		if ( isDefined( line_of_sight ) && line_of_sight )
		{
			draw_debug_star( node.origin, ( 1, 1, 1 ), 100 );
			if ( is_within_view_2d( node.origin, player.origin, player.angles, 0,86 ) )
			{
				selected_node = node;
				break;
			}
			else
			{
				selected_node = node;
			}
			i--;

		}
	}
	return selected_node;
}

script_move_update()
{
	if ( isDefined( self.is_traversing ) && self.is_traversing )
	{
		return;
	}
	player = self.favoriteenemy;
	if ( is_player_valid( player ) && isDefined( self.script_move_target_node ) )
	{
		desired_angles = vectorToAngle( vectornormalize( player.origin - self.origin ) );
		distance_squared = distancesquared( self.origin, self.script_move_target_node.origin );
		if ( distance_squared < 24 )
		{
			self.script_mover.angles = desired_angles;
			self remove_script_mover();
			wait_network_frame();
			self setclientfield( "ghost_fx", 3 );
			self setclientfield( "sndGhostAudio", 1 );
			wait_network_frame();
			self start_chase();
			return;
		}
		draw_debug_star( self.script_move_target_node.origin, ( 1, 1, 1 ), 1 );
		target_node_pos = self.script_move_target_node.origin + vectorScale( ( 1, 1, 1 ), 36 );
		distance_squared_to_target_node_pos = distancesquared( self.origin, target_node_pos );
		moved_distance_during_interval = 80;
		if ( distance_squared_to_target_node_pos <= ( moved_distance_during_interval * moved_distance_during_interval ) )
		{
			target_point = self.script_move_target_node.origin;
			self.script_mover moveto( target_point, 0,1, 0, 0,1 );
			self.script_mover waittill( "movedone" );
			self.script_mover.angles = desired_angles;
		}
		else
		{
			distance_squared_to_player = distancesquared( self.origin, player.origin );
			if ( distance_squared_to_player < 540 && isDefined( self.script_mover.search_target_node_again ) && !self.script_mover.search_target_node_again )
			{
				self get_best_flying_target_node( player, self.script_move_target_node.origin );
				self.script_mover.search_target_node_again = 1;
			}
			if ( self.script_move_sin_index >= level.ghost_script_move_sin.size )
			{
				self.script_move_sin_index = 0;
			}
			move_dir = target_node_pos - self.origin;
			move_dir = vectornormalize( move_dir );
			target_point = self.origin + ( ( move_dir * 800 ) * 0,1 );
			x_offset = level.ghost_script_move_sin[ self.script_move_sin_index ] * 6;
			z_offset = level.ghost_script_move_sin[ self.script_move_sin_index ] * 12;
			target_point += ( x_offset, 0, z_offset );
			self.script_move_sin_index++;
			self.script_mover moveto( target_point, 0,1 );
			self.script_mover.angles = desired_angles;
			draw_debug_star( target_point, ( 1, 1, 1 ), 1 );
		}
	}
	else
	{
		self remove_script_mover();
		self start_evaporate( 1 );
	}
}

remove_script_mover()
{
	if ( isDefined( self.script_mover ) )
	{
		self dontinterpolate();
		self unlink();
		self.script_mover delete();
	}
}

start_chase()
{
	self set_zombie_run_cycle( "run" );
	self setanimstatefromasd( "zm_move_run" );
	self.state = "chase_update";
	self setclientfield( "ghost_fx", 4 );
}

chase_update()
{
	if ( isDefined( self.is_traversing ) && self.is_traversing )
	{
		return;
	}
	player = self.favoriteenemy;
	if ( is_player_valid( player ) )
	{
		if ( self should_runaway( player ) )
		{
			self start_runaway();
			return;
		}
		if ( self does_fall_into_pap_hole() )
		{
			self dodamage( self.health + 666, self.origin );
			return;
		}
		if ( self need_wait() )
		{
			self start_wait();
			return;
		}
		ghost_check_point = self.origin + ( 0, 0, 60 );
		player_eye_pos = player geteyeapprox();
		line_of_sight = sighttracepassed( ghost_check_point, player_eye_pos, 0, self );
		if ( isDefined( line_of_sight ) && line_of_sight && can_drain_points( self.origin, player.origin ) )
		{
			self start_drain();
			return;
		}
		distsquared = distancesquared( self.origin, player.origin );
		if ( distsquared > ( 300 * 300 ) )
		{
			if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone && isDefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone && isDefined( player.current_ghost_room_name ) )
			{
				current_room = level.ghost_rooms[ player.current_ghost_room_name ];
				if ( isDefined( current_room.flag ) && current_room.flag != "no_cleanup" || self is_in_close_rooms( current_room ) && self is_in_room( current_room ) && !self is_following_room_path( player, current_room ) )
				{
					set_chase_status( "run" );
				}
				else
				{
					self start_evaporate( 1 );
				}
			}
			else
			{
				set_chase_status( "run" );
				if ( distsquared > ( 9600 * 9600 ) )
				{
					teleport_location = level.ghost_front_flying_out_path_starts[ 0 ];
					self forceteleport( teleport_location.origin, ( 1, 1, 1 ) );
				}
			}
		}
		else if ( distsquared > ( 144 * 144 ) )
		{
			set_chase_status( "run" );
		}
		else
		{
			set_chase_status( "walk" );
		}
	}
	else
	{
		self set_zombie_run_cycle( "run" );
		if ( self getanimstatefromasd() != "zm_move_run" )
		{
			self setanimstatefromasd( "zm_move_run" );
		}
		self start_runaway();
	}
}

need_wait()
{
	if ( isDefined( self.need_wait ) )
	{
		return self.need_wait;
	}
}

start_wait()
{
	self setanimstatefromasd( "zm_idle" );
	self setclientfield( "ghost_fx", 4 );
	self.state = "wait_update";
}

wait_update()
{
	if ( isDefined( self.is_traversing ) && self.is_traversing )
	{
		return;
	}
	player = self.favoriteenemy;
	if ( is_player_valid( player ) )
	{
		ghost_check_point = self.origin + ( 0, 0, 60 );
		player_eye_pos = player geteyeapprox();
		line_of_sight = sighttracepassed( ghost_check_point, player_eye_pos, 0, self );
		if ( isDefined( line_of_sight ) && line_of_sight && can_drain_points( self.origin, player.origin ) )
		{
			self start_drain();
			return;
		}
		if ( !self need_wait() )
		{
			self start_chase();
		}
	}
	else
	{
		self set_zombie_run_cycle( "run" );
		if ( self getanimstatefromasd() != "zm_move_run" )
		{
			self setanimstatefromasd( "zm_move_run" );
		}
		self setclientfield( "ghost_fx", 4 );
		self start_runaway();
	}
}

start_evaporate( need_deletion )
{
	self setclientfield( "ghost_fx", 5 );
	wait 0,1;
	if ( isDefined( need_deletion ) && need_deletion )
	{
		level.zombie_ghost_count--;

		if ( isDefined( self.favoriteenemy ) )
		{
			if ( isDefined( self.favoriteenemy.ghost_count ) && self.favoriteenemy.ghost_count > 0 )
			{
				self.favoriteenemy.ghost_count--;

			}
		}
		self delete();
	}
	else
	{
		self.state = "evaporate_update";
		self ghost();
		self notsolid();
	}
}

should_be_deleted_during_evaporate_update( player )
{
	if ( isDefined( self.is_spawned_in_ghost_zone ) && !self.is_spawned_in_ghost_zone )
	{
		return 0;
	}
	if ( !isDefined( player ) )
	{
		return 1;
	}
	if ( isDefined( player.sessionstate ) || player.sessionstate == "spectator" && player.sessionstate == "intermission" )
	{
		return 1;
	}
	return 0;
}

evaporate_update()
{
	player = self.favoriteenemy;
	if ( should_be_deleted_during_evaporate_update( player ) )
	{
		if ( level.zombie_ghost_count > 0 )
		{
			level.zombie_ghost_count--;

		}
		self delete();
	}
	else
	{
		if ( is_player_valid( player ) )
		{
			self solid();
			self show();
			self start_chase();
		}
	}
}

is_within_capsule( point, origin, angles, radius, range )
{
	forward_dir = vectornormalize( anglesToForward( angles ) );
	start = origin + ( forward_dir * radius );
	end = start + ( forward_dir * range );
	point_intersect = pointonsegmentnearesttopoint( start, end, point );
	distance_squared = distancesquared( point_intersect, point );
	if ( distance_squared <= ( radius * radius ) )
	{
		return 1;
	}
	return 0;
}

is_within_view_2d( point, origin, angles, fov_cos )
{
	dot = get_dot_production_2d( point, origin, angles );
	if ( dot > fov_cos )
	{
		return 1;
	}
	return 0;
}

get_dot_production_2d( point, origin, angles )
{
	forward_dir = anglesToForward( angles );
	forward_dir = ( forward_dir[ 0 ], forward_dir[ 1 ], 0 );
	forward_dir = vectornormalize( forward_dir );
	to_point_dir = point - origin;
	to_point_dir = ( to_point_dir[ 0 ], to_point_dir[ 1 ], 0 );
	to_point_dir = vectornormalize( to_point_dir );
	return vectordot( forward_dir, to_point_dir );
}

is_in_room( room )
{
	_a1702 = room.volumes;
	_k1702 = getFirstArrayKey( _a1702 );
	while ( isDefined( _k1702 ) )
	{
		volume = _a1702[ _k1702 ];
		if ( self istouching( volume ) )
		{
			return 1;
		}
		_k1702 = getNextArrayKey( _a1702, _k1702 );
	}
	return 0;
}

is_in_rooms( room_names )
{
	_a1715 = room_names;
	_k1715 = getFirstArrayKey( _a1715 );
	while ( isDefined( _k1715 ) )
	{
		room_name = _a1715[ _k1715 ];
		room = level.ghost_rooms[ room_name ];
		if ( self is_in_room( room ) )
		{
			return 1;
		}
		_k1715 = getNextArrayKey( _a1715, _k1715 );
	}
	return 0;
}

is_in_next_rooms( room )
{
	if ( self is_in_rooms( room.next_room_names ) )
	{
		return 1;
	}
	return 0;
}

is_in_close_rooms( room )
{
	_a1742 = room.next_room_names;
	_k1742 = getFirstArrayKey( _a1742 );
	while ( isDefined( _k1742 ) )
	{
		next_room_name = _a1742[ _k1742 ];
		next_room = level.ghost_rooms[ next_room_name ];
		if ( self is_in_rooms( next_room.next_room_names ) )
		{
			return 1;
		}
		_k1742 = getNextArrayKey( _a1742, _k1742 );
	}
	if ( self is_in_rooms( room.next_room_names ) )
	{
		return 1;
	}
	return 0;
}

is_following_room_path( player, room )
{
	if ( isDefined( room.volumes[ 0 ].script_angles ) )
	{
		dot = get_dot_production_2d( player.origin, self.origin, room.volumes[ 0 ].script_angles );
		if ( dot > 0 )
		{
			return 1;
		}
	}
	return 0;
}

can_drain_points( self_pos, target_pos )
{
	if ( isDefined( self.force_killable ) && self.force_killable )
	{
		return 0;
	}
	dist = distancesquared( self_pos, target_pos );
	if ( dist < ( 60 * 60 ) )
	{
		return 1;
	}
	return 0;
}

set_chase_status( move_speed )
{
	self setclientfield( "ghost_fx", 4 );
	if ( self.zombie_move_speed != move_speed )
	{
		self set_zombie_run_cycle( move_speed );
		self setanimstatefromasd( "zm_move_" + move_speed );
	}
}

start_drain()
{
	self setanimstatefromasd( "zm_drain" );
	self setclientfield( "ghost_fx", 2 );
	self.state = "drain_update";
}

drain_update()
{
	if ( isDefined( self.is_traversing ) && self.is_traversing )
	{
		return;
	}
	player = self.favoriteenemy;
	if ( is_player_valid( player ) )
	{
		if ( can_drain_points( self.origin, player.origin ) )
		{
			if ( self getanimstatefromasd() != "zm_drain" )
			{
				self setanimstatefromasd( "zm_drain" );
			}
			self orientmode( "face enemy" );
			if ( isDefined( self.is_draining ) && !self.is_draining )
			{
				self thread drain_player( player );
			}
		}
		else
		{
			self start_chase();
		}
	}
	else
	{
		self set_zombie_run_cycle( "run" );
		if ( self getanimstatefromasd() != "zm_move_run" )
		{
			self setanimstatefromasd( "zm_move_run" );
		}
		self setclientfield( "ghost_fx", 4 );
		self start_runaway();
	}
}

drain_player( player )
{
	self endon( "death" );
	self.is_draining = 1;
	player_drained = 0;
	points_to_drain = 2000;
	if ( player.score < points_to_drain )
	{
		if ( player.score > 0 )
		{
			points_to_drain = player.score;
		}
		else
		{
			points_to_drain = 0;
		}
	}
	if ( points_to_drain > 0 )
	{
		player maps/mp/zombies/_zm_score::minus_to_player_score( points_to_drain );
		player_drained = 1;
		player playsoundtoplayer( "zmb_ai_ghost_money_drain", player );
		level notify( "ghost_drained_player" );
	}
	else
	{
		if ( player.health > 0 && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			player dodamage( 25, self.origin, self );
			player_drained = 1;
			level notify( "ghost_damaged_player" );
		}
	}
	if ( player_drained )
	{
		give_player_rewards( player );
		player maps/mp/zombies/_zm_stats::increment_client_stat( "buried_ghost_drained_player", 0 );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "buried_ghost_drained_player" );
		wait 2;
	}
	self.is_draining = 0;
}

should_runaway( player )
{
	result = 0;
	if ( !is_ghost_round_started() && isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone && isDefined( player.is_in_ghost_zone ) && !player.is_in_ghost_zone )
	{
		path_lenth = self getpathlength();
		if ( path_lenth == 0 )
		{
			result = 1;
		}
	}
	return result;
}

start_runaway()
{
	wait 2;
	self.state = "runaway_update";
	self setgoalpos( self.startinglocation );
	self set_chase_status( "run" );
}

does_reach_runaway_goal()
{
	result = 0;
	dist_squared = distancesquared( self.origin, self.startinglocation );
	if ( dist_squared < ( 60 * 60 ) )
	{
		result = 1;
	}
	return result;
}

runaway_update()
{
	if ( isDefined( self.is_traversing ) && self.is_traversing )
	{
		return;
	}
	player = self.favoriteenemy;
	if ( is_player_valid( player ) || is_ghost_round_started() && isDefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone )
	{
		self.state = "chase_update";
		return;
	}
	if ( self does_fall_into_pap_hole() )
	{
		self dodamage( self.health + 666, self.origin );
		return;
	}
	if ( self does_reach_runaway_goal() )
	{
		should_delete = 1;
		if ( is_ghost_round_started() || isDefined( self.is_spawned_in_ghost_zone ) && !self.is_spawned_in_ghost_zone )
		{
			should_delete = 0;
		}
		self start_evaporate( should_delete );
	}
	else
	{
		self setgoalpos( self.startinglocation );
/#
		draw_debug_star( self.startinglocation, ( 1, 1, 1 ), 1 );
		draw_debug_line( self.origin, self.startinglocation, ( 1, 1, 1 ), 1, 0 );
#/
	}
}

paralyzer_callback( player, upgraded )
{
	if ( isDefined( self.ignore_slowgun_anim_rates ) && self.ignore_slowgun_anim_rates )
	{
		return;
	}
	if ( upgraded )
	{
		self setclientfield( "slowgun_fx", 5 );
	}
	else
	{
		self setclientfield( "slowgun_fx", 1 );
	}
	self maps/mp/zombies/_zm_weap_slowgun::zombie_slow_for_time( 0,3, 0 );
}

ghost_springpad_fling( weapon, attacker )
{
	self dodamage( self.health + 666, self.origin );
	weapon.springpad_kills++;
}

ghost_print( str )
{
/#
	if ( getDvarInt( #"151B6F17" ) )
	{
		iprintln( "ghost: " + str + "\n" );
		if ( isDefined( self ) )
		{
			if ( isDefined( self.debug_msg ) )
			{
				self.debug_msg[ self.debug_msg.size ] = str;
				return;
			}
			else
			{
				self.debug_msg = [];
				self.debug_msg[ self.debug_msg.size ] = str;
#/
			}
		}
	}
}

ghost_round_think()
{
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	for ( ;; )
	{
		while ( 1 )
		{
			level.zombie_ghost_round_states.any_player_in_ghost_zone = check_players_in_ghost_zone();
			if ( can_start_ghost_round() )
			{
				if ( ghost_round_start_conditions_met() )
				{
					start_ghost_round();
					break;
				}
				else
				{
					wait 0,1;
				}
			}
			while ( 1 )
			{
				if ( can_end_ghost_round() )
				{
					wait 0,5;
					end_ghost_round();
					break;
				}
				else
				{
					level.zombie_ghost_round_states.any_player_in_ghost_zone = check_players_in_ghost_zone();
					if ( isDefined( level.ghost_zone_teleport_logic ) )
					{
						[[ level.ghost_zone_teleport_logic ]]();
					}
					if ( isDefined( level.ghost_zone_fountain_teleport_logic ) )
					{
						[[ level.ghost_zone_fountain_teleport_logic ]]();
					}
					wait 0,1;
				}
			}
		}
		else check_sending_away_zombie_followers();
		wait 0,1;
	}
}

ghost_round_start_conditions_met()
{
	if ( isDefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone )
	{
		b_conditions_met = !is_ghost_round_started();
	}
	if ( isDefined( level.force_ghost_round_start ) || level.force_ghost_round_start && is_ghost_round_started() )
	{
		b_conditions_met = 1;
	}
	return b_conditions_met;
}

can_start_ghost_round()
{
/#
	if ( isDefined( level.force_no_ghost ) && level.force_no_ghost )
	{
		return 0;
#/
	}
	result = 0;
	if ( isDefined( level.zombie_ghost_round_states ) )
	{
		if ( isDefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) || !level.zombie_ghost_round_states.is_first_ghost_round_finished && level.round_number >= level.zombie_ghost_round_states.next_ghost_round_number )
		{
			result = 1;
		}
	}
	if ( isDefined( level.force_ghost_round_start ) && level.force_ghost_round_start )
	{
		result = 1;
	}
	return result;
}

set_ghost_round_number()
{
	if ( isDefined( level.zombie_ghost_round_states ) )
	{
		level.zombie_ghost_round_states.current_ghost_round_number = level.round_number;
		level.zombie_ghost_round_states.next_ghost_round_number = level.round_number + randomintrange( 4, 6 );
	}
}

is_ghost_round_started()
{
	if ( isDefined( level.zombie_ghost_round_states ) )
	{
		return level.zombie_ghost_round_states.is_started;
	}
	return 0;
}

start_ghost_round()
{
	level.zombie_ghost_round_states.is_started = 1;
	level.zombie_ghost_round_states.round_count++;
	flag_clear( "spawn_zombies" );
	flag_set( "spawn_ghosts" );
	disable_ghost_zone_door_ai_clips();
	clear_all_active_zombies();
	set_ghost_round_number();
	increase_ghost_health();
	ghost_round_presentation_reset();
	wait 0,5;
	level thread sndghostroundmus();
	level thread outside_ghost_zone_spawning_think();
	level thread player_moving_speed_scale_think();
	if ( !flag( "time_bomb_restore_active" ) )
	{
		level.force_ghost_round_start = undefined;
	}
	maps/mp/zombies/_zm_ai_ghost_ffotd::ghost_round_start();
}

increase_ghost_health()
{
	if ( level.zombie_ghost_round_states.round_count == 1 )
	{
		new_health = level.ghost_health + 300;
		if ( level.round_number > 5 )
		{
			new_health = int( 1600 * ( level.round_number / 20 ) );
		}
		level.ghost_health = new_health;
	}
	else if ( level.zombie_ghost_round_states.round_count == 2 )
	{
		level.ghost_health += 500;
	}
	else if ( level.zombie_ghost_round_states.round_count == 3 )
	{
		level.ghost_health += 400;
	}
	else
	{
		if ( level.zombie_ghost_round_states.round_count == 4 )
		{
			level.ghost_health = 1600;
		}
	}
	if ( level.ghost_health > 1600 )
	{
		level.ghost_health = 1600;
	}
}

enable_ghost_zone_door_ai_clips()
{
	while ( isDefined( level.ghost_zone_door_clips ) && level.ghost_zone_door_clips.size > 0 )
	{
		_a2256 = level.ghost_zone_door_clips;
		_k2256 = getFirstArrayKey( _a2256 );
		while ( isDefined( _k2256 ) )
		{
			door_clip = _a2256[ _k2256 ];
			door_clip solid();
			door_clip disconnectpaths();
			_k2256 = getNextArrayKey( _a2256, _k2256 );
		}
	}
}

disable_ghost_zone_door_ai_clips()
{
	while ( isDefined( level.ghost_zone_door_clips ) && level.ghost_zone_door_clips.size > 0 )
	{
		_a2269 = level.ghost_zone_door_clips;
		_k2269 = getFirstArrayKey( _a2269 );
		while ( isDefined( _k2269 ) )
		{
			door_clip = _a2269[ _k2269 ];
			door_clip notsolid();
			door_clip connectpaths();
			_k2269 = getNextArrayKey( _a2269, _k2269 );
		}
	}
}

clear_all_active_zombies()
{
	zombies = get_round_enemy_array();
	while ( isDefined( zombies ) )
	{
		level.zombie_ghost_round_states.round_zombie_total = level.zombie_total + zombies.size;
		_a2288 = zombies;
		_k2288 = getFirstArrayKey( _a2288 );
		while ( isDefined( _k2288 ) )
		{
			zombie = _a2288[ _k2288 ];
			if ( isDefined( zombie.is_ghost ) && !zombie.is_ghost )
			{
				spawn_point = spawnstruct();
				spawn_point.origin = zombie.origin;
				spawn_point.angles = zombie.angles;
				if ( isDefined( zombie.completed_emerging_into_playable_area ) && !zombie.completed_emerging_into_playable_area )
				{
					if ( isDefined( zombie.spawn_point ) && isDefined( zombie.spawn_point.script_string ) )
					{
						no_barrier_target = zombie.spawn_point.script_string == "find_flesh";
					}
					if ( no_barrier_target )
					{
						if ( isDefined( zombie.spawn_point.script_noteworthy ) && zombie.spawn_point.script_noteworthy == "faller_location" )
						{
							ground_pos = groundpos_ignore_water_new( zombie.spawn_point.origin );
							spawn_point.origin = ground_pos;
						}
					}
					else
					{
						origin = zombie.origin;
						desired_origin = zombie get_desired_origin();
						if ( isDefined( desired_origin ) )
						{
							origin = desired_origin;
						}
						nodes = get_array_of_closest( origin, level.exterior_goals, undefined, 1 );
						if ( nodes.size > 0 )
						{
							spawn_point.origin = nodes[ 0 ].neg_end.origin;
							spawn_point.angles = nodes[ 0 ].neg_end.angles;
						}
					}
				}
				else
				{
					if ( isDefined( level.sloth ) && isDefined( level.sloth.crawler ) && zombie == level.sloth.crawler )
					{
						spawn_point.origin = level.sloth.origin;
						spawn_point.angles = level.sloth.angles;
					}
				}
				level.zombie_ghost_round_states.active_zombie_locations[ level.zombie_ghost_round_states.active_zombie_locations.size ] = spawn_point;
				zombie.nodeathragdoll = 1;
				zombie.turning_into_ghost = 1;
				if ( isalive( zombie ) )
				{
					zombie dodamage( zombie.health + 666, zombie.origin );
				}
			}
			_k2288 = getNextArrayKey( _a2288, _k2288 );
		}
	}
}

reset_ghost_round_states()
{
	if ( !isDefined( level.zombie_ghost_round_states.round_zombie_total ) )
	{
		level.zombie_ghost_round_states.round_zombie_total = 0;
	}
	level.zombie_ghost_round_states.is_started = 0;
	if ( should_restore_zombie_total() )
	{
		if ( level.zombie_ghost_round_states.round_zombie_total > 0 )
		{
			level.zombie_total = level.zombie_ghost_round_states.round_zombie_total;
		}
	}
	level.zombie_ghost_round_states.round_zombie_total = 0;
	level.zombie_ghost_round_states.active_zombie_locations = [];
	if ( is_false( level.zombie_ghost_round_states.is_first_ghost_round_finished ) )
	{
		level.zombie_ghost_round_states.is_first_ghost_round_finished = 1;
	}
}

should_restore_zombie_total()
{
	if ( flag( "time_bomb_restore_active" ) )
	{
		if ( flag( "time_bomb_restore_active" ) )
		{
			return maps/mp/zombies/_zm_weap_time_bomb::get_time_bomb_saved_round_type() == "ghost";
		}
	}
}

can_end_ghost_round()
{
	if ( isDefined( level.force_ghost_round_end ) && level.force_ghost_round_end )
	{
		return 1;
	}
	if ( isDefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && !level.zombie_ghost_round_states.any_player_in_ghost_zone && get_current_ghost_count() <= 0 )
	{
		return 1;
	}
	return 0;
}

end_ghost_round()
{
	reset_ghost_round_states();
	if ( should_last_ghost_drop_powerup() )
	{
		trace = groundtrace( level.ghost_round_last_ghost_origin + vectorScale( ( 1, 1, 1 ), 10 ), level.ghost_round_last_ghost_origin + vectorScale( ( 1, 1, 1 ), 150 ), 0, undefined, 1 );
		power_up_origin = trace[ "position" ];
		powerup = level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "free_perk", power_up_origin );
		if ( isDefined( powerup ) )
		{
			powerup.ghost_powerup = 1;
		}
		level.ghost_round_last_ghost_origin_last = level.ghost_round_last_ghost_origin;
		level.ghost_round_last_ghost_origin = undefined;
	}
	level setclientfield( "ghost_round_light_state", 0 );
	enable_ghost_zone_door_ai_clips();
	level notify( "ghost_round_end" );
	if ( isDefined( level.force_ghost_round_end ) && level.force_ghost_round_end )
	{
		level.force_ghost_round_end = undefined;
		return;
	}
	flag_set( "spawn_zombies" );
	flag_clear( "spawn_ghosts" );
	maps/mp/zombies/_zm_ai_ghost_ffotd::ghost_round_end();
}

should_last_ghost_drop_powerup()
{
	if ( flag( "time_bomb_restore_active" ) )
	{
		return 0;
	}
	if ( !isDefined( level.ghost_round_last_ghost_origin ) )
	{
		return 0;
	}
	return 1;
}

sndghostroundmus()
{
	level endon( "ghost_round_end" );
	ent = spawn( "script_origin", ( 1, 1, 1 ) );
	level.sndroundwait = 1;
	ent thread sndghostroundmus_end();
	ent endon( "sndGhostRoundEnd" );
	ent playsound( "mus_ghost_round_start" );
	wait 11;
	ent playloopsound( "mus_ghost_round_loop", 3 );
}

sndghostroundmus_end()
{
	level waittill( "ghost_round_end" );
	self notify( "sndGhostRoundEnd" );
	self stoploopsound( 1 );
	self playsoundwithnotify( "mus_ghost_round_over", "stingerDone" );
	self waittill( "stingerDone" );
	self delete();
	level.sndroundwait = 0;
}

sndghostroundready()
{
	level notify( "sndGhostRoundReady" );
	level endon( "sndGhostRoundReady" );
	mansion = ( 2830, 555, 436 );
	while ( 1 )
	{
		level waittill( "between_round_over" );
		if ( level.zombie_ghost_round_states.next_ghost_round_number == level.round_number )
		{
			playsoundatposition( "zmb_ghost_round_srt", mansion );
			ent = spawn( "script_origin", mansion );
			ent playloopsound( "zmb_ghost_round_lp", 3 );
			ent thread sndghostroundready_stoplp();
			break;
		}
		else
		{
		}
	}
	wait 15;
	level notify( "sndStopRoundReadyLp" );
}

sndghostroundready_stoplp()
{
	level waittill_either( "sndStopRoundReadyLp", "sndGhostRoundReady" );
	self stoploopsound( 3 );
	wait 3;
	self delete();
}

check_sending_away_zombie_followers()
{
	if ( flag_exists( "time_bomb_restore_active" ) && flag( "time_bomb_restore_active" ) )
	{
		return;
	}
	players = getplayers();
	valid_player_in_ghost_zone_count = 0;
	valid_player_count = 0;
	_a2522 = players;
	_k2522 = getFirstArrayKey( _a2522 );
	while ( isDefined( _k2522 ) )
	{
		player = _a2522[ _k2522 ];
		if ( is_player_valid( player ) )
		{
			valid_player_count++;
			if ( isDefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone )
			{
				valid_player_in_ghost_zone_count++;
				break;
			}
			else
			{
				player.zombie_followers_sent_away = 0;
			}
		}
		_k2522 = getNextArrayKey( _a2522, _k2522 );
	}
	if ( valid_player_count > 0 && valid_player_in_ghost_zone_count == valid_player_count )
	{
		if ( flag( "spawn_zombies" ) )
		{
			flag_clear( "spawn_zombies" );
		}
		zombies = get_round_enemy_array();
		_a2561 = zombies;
		_k2561 = getFirstArrayKey( _a2561 );
		while ( isDefined( _k2561 ) )
		{
			zombie = _a2561[ _k2561 ];
			if ( is_true( zombie.completed_emerging_into_playable_area ) && !is_true( zombie.zombie_path_bad ) )
			{
				zombie notify( "bad_path" );
			}
			_k2561 = getNextArrayKey( _a2561, _k2561 );
		}
	}
	else if ( !flag( "spawn_zombies" ) )
	{
		flag_set( "spawn_zombies" );
	}
}

send_away_zombie_follower( player )
{
	self endon( "death" );
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;
	awaydir = self.origin - player.origin;
	awaydir = ( awaydir[ 0 ], awaydir[ 1 ], 0 );
	awaydir = vectornormalize( awaydir );
	endpos = self.origin + vectorScale( awaydir, 600 );
	locs = array_randomize( level.enemy_dog_locations );
	i = 0;
	while ( i < locs.size )
	{
		dist_zombie = distancesquared( locs[ i ].origin, endpos );
		dist_player = distancesquared( locs[ i ].origin, player.origin );
		if ( dist_zombie < dist_player )
		{
			dest = i;
			break;
		}
		else
		{
			i++;
		}
	}
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	if ( isDefined( locs[ dest ] ) )
	{
		self setgoalpos( locs[ dest ].origin );
	}
	wait 5;
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

outside_ghost_zone_spawning_think()
{
	level endon( "intermission" );
	if ( level.intermission )
	{
		return;
	}
	level endon( "ghost_round_end" );
	if ( !isDefined( level.female_ghost_spawner ) )
	{
/#
		assertmsg( "No female ghost spawner in the map." );
#/
		return;
	}
	while ( isDefined( level.zombie_ghost_round_states.active_zombie_locations ) )
	{
		i = 0;
		while ( i < level.zombie_ghost_round_states.active_zombie_locations.size )
		{
			if ( i >= 20 )
			{
				return;
			}
			spawn_point = level.zombie_ghost_round_states.active_zombie_locations[ i ];
			ghost_ai = spawn_zombie( level.female_ghost_spawner, level.female_ghost_spawner.targetname, spawn_point );
			if ( isDefined( ghost_ai ) )
			{
				ghost_ai setclientfield( "ghost_fx", 3 );
				ghost_ai.spawn_point = spawn_point;
				ghost_ai.is_ghost = 1;
			}
			else
			{
/#
				assertmsg( "female ghost outside ghost zone: failed spawn" );
#/
				return;
			}
			wait randomfloat( 0,3 );
			wait_network_frame();
			i++;
		}
	}
}

get_current_ghost_count()
{
	ghost_count = 0;
	ais = getaiarray( level.zombie_team );
	_a2673 = ais;
	_k2673 = getFirstArrayKey( _a2673 );
	while ( isDefined( _k2673 ) )
	{
		ai = _a2673[ _k2673 ];
		if ( isDefined( ai.is_ghost ) && ai.is_ghost )
		{
			ghost_count++;
		}
		_k2673 = getNextArrayKey( _a2673, _k2673 );
	}
	return ghost_count;
}

get_current_ghosts()
{
	ghosts = [];
	ais = getaiarray( level.zombie_team );
	_a2688 = ais;
	_k2688 = getFirstArrayKey( _a2688 );
	while ( isDefined( _k2688 ) )
	{
		ai = _a2688[ _k2688 ];
		if ( isDefined( ai.is_ghost ) && ai.is_ghost )
		{
			ghosts[ ghosts.size ] = ai;
		}
		_k2688 = getNextArrayKey( _a2688, _k2688 );
	}
	return ghosts;
}

set_player_moving_speed_scale( player, move_speed_scale )
{
	if ( isDefined( player ) )
	{
		player setmovespeedscale( move_speed_scale );
	}
}

player_moving_speed_scale_think()
{
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	level endon( "ghost_round_end" );
	while ( 1 )
	{
		players = get_players();
		_a2723 = players;
		_k2723 = getFirstArrayKey( _a2723 );
		while ( isDefined( _k2723 ) )
		{
			player = _a2723[ _k2723 ];
			if ( !is_player_valid( player, undefined, 1 ) )
			{
			}
			else if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				set_player_moving_speed_scale( player, 1 );
			}
			else
			{
				if ( isDefined( player.ghost_next_drain_time_left ) )
				{
					player.ghost_next_drain_time_left -= 0,1;
				}
				player_slow_down = 0;
				ais = getaiarray( level.zombie_team );
				_a2743 = ais;
				_k2743 = getFirstArrayKey( _a2743 );
				while ( isDefined( _k2743 ) )
				{
					ai = _a2743[ _k2743 ];
					if ( isDefined( ai.is_ghost ) && ai.is_ghost && can_drain_points( ai.origin, player.origin ) )
					{
						player_slow_down = 1;
						set_player_moving_speed_scale( player, 0,5 );
						if ( isDefined( player.ghost_next_drain_time_left ) && player.ghost_next_drain_time_left < 0 && isDefined( ai.favoriteenemy ) && player != ai.favoriteenemy )
						{
							give_player_rewards( player );
							points_to_drain = 2000;
							if ( player.score < points_to_drain )
							{
								if ( player.score > 0 )
								{
									points_to_drain = player.score;
									break;
								}
								else
								{
									points_to_drain = 0;
								}
							}
							if ( points_to_drain > 0 )
							{
								player maps/mp/zombies/_zm_score::minus_to_player_score( points_to_drain );
								player playsoundtoplayer( "zmb_ai_ghost_money_drain", player );
							}
							else
							{
								if ( player.health > 0 && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
								{
									player dodamage( 25, ai.origin, ai );
								}
							}
							player.ghost_next_drain_time_left = 2;
						}
						break;
					}
					else
					{
						_k2743 = getNextArrayKey( _a2743, _k2743 );
					}
				}
				if ( player_slow_down == 0 )
				{
					set_player_moving_speed_scale( player, 1 );
				}
			}
			_k2723 = getNextArrayKey( _a2723, _k2723 );
		}
		wait 0,1;
	}
}

give_player_rewards( player )
{
	if ( player is_player_placeable_mine( "claymore_zm" ) )
	{
		claymore_count = player getweaponammostock( "claymore_zm" ) + 1;
		if ( claymore_count >= 2 )
		{
			claymore_count = 2;
			player notify( "zmb_disable_claymore_prompt" );
		}
		player setweaponammostock( "claymore_zm", claymore_count );
	}
	else
	{
		lethal_grenade_name = player get_player_lethal_grenade();
		if ( player hasweapon( lethal_grenade_name ) )
		{
			lethal_grenade_count = player getweaponammoclip( lethal_grenade_name ) + 1;
			if ( lethal_grenade_count > 4 )
			{
				lethal_grenade_count = 4;
			}
			player setweaponammoclip( lethal_grenade_name, lethal_grenade_count );
		}
	}
}

set_player_current_ghost_zone( player, ghost_zone_name )
{
	if ( isDefined( player ) )
	{
		player.current_ghost_room_name = ghost_zone_name;
	}
}

can_start_ghost_round_presentation()
{
/#
	if ( isDefined( level.force_no_ghost ) && level.force_no_ghost )
	{
		return 0;
#/
	}
	if ( isDefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished )
	{
		if ( level.round_number < ( level.zombie_ghost_round_states.current_ghost_round_number + 4 ) )
		{
			return 0;
		}
	}
	if ( is_ghost_round_started() )
	{
		return 0;
	}
	if ( flag( "time_bomb_round_killed" ) && !flag( "time_bomb_enemies_restored" ) )
	{
		return 0;
	}
	return 1;
}

can_start_ghost_round_presentation_stage_1()
{
	if ( isDefined( level.zombie_ghost_round_states.presentation_stage_1_started ) && level.zombie_ghost_round_states.presentation_stage_1_started )
	{
		return 0;
	}
	return 1;
}

can_start_ghost_round_presentation_stage_2()
{
	if ( isDefined( level.zombie_ghost_round_states.presentation_stage_2_started ) && level.zombie_ghost_round_states.presentation_stage_2_started )
	{
		return 0;
	}
	if ( isDefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished )
	{
		if ( level.round_number < ( ( level.zombie_ghost_round_states.current_ghost_round_number + 4 ) + 1 ) )
		{
			return 0;
		}
	}
	return 1;
}

can_start_ghost_round_presentation_stage_3()
{
	if ( isDefined( level.zombie_ghost_round_states.presentation_stage_3_started ) && level.zombie_ghost_round_states.presentation_stage_3_started )
	{
		return 0;
	}
	if ( isDefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished )
	{
		if ( level.round_number < ( ( level.zombie_ghost_round_states.current_ghost_round_number + 4 ) + 2 ) )
		{
			return 0;
		}
	}
	return 1;
}

get_next_spot_during_ghost_round_presentation()
{
	if ( isDefined( level.current_ghost_window_index ) )
	{
		standing_location_index = randomint( level.ghost_front_standing_locations.size );
		while ( standing_location_index == level.current_ghost_window_index )
		{
			standing_location_index = randomint( level.ghost_front_standing_locations.size );
		}
		level.current_ghost_window_index = standing_location_index;
	}
	else
	{
		level.current_ghost_window_index = 1;
	}
	return level.ghost_front_standing_locations[ level.current_ghost_window_index ];
}

spawn_ghost_round_presentation_ghost()
{
	spawn_point = get_next_spot_during_ghost_round_presentation();
	ghost = spawn( "script_model", spawn_point.origin );
	ghost.angles = spawn_point.angles;
	ghost setmodel( "c_zom_zombie_buried_ghost_woman_fb" );
	if ( isDefined( ghost ) )
	{
		ghost.spawn_point = spawn_point;
		ghost.for_ghost_round_presentation = 1;
		level.ghost_round_presentation_ghost = ghost;
	}
	else
	{
/#
		assertmsg( "ghost round presentation ghost: failed spawn" );
#/
		return;
	}
	wait 0,5;
	ghost useanimtree( -1 );
	ghost setanim( %ai_zombie_ghost_idle );
	ghost.script_mover = spawn( "script_origin", ghost.origin );
	ghost.script_mover.angles = ghost.angles;
	ghost linkto( ghost.script_mover );
	ghost setclientfield( "sndGhostAudio", 1 );
}

ghost_round_presentation_think()
{
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	if ( !isDefined( level.sndmansionent ) )
	{
		level.sndmansionent = spawn( "script_origin", ( 2830, 555, 436 ) );
	}
	flag_wait( "start_zombie_round_logic" );
	while ( 1 )
	{
		if ( can_start_ghost_round_presentation() )
		{
			if ( can_start_ghost_round_presentation_stage_1() )
			{
				level.zombie_ghost_round_states.presentation_stage_1_started = 1;
				spawn_ghost_round_presentation_ghost();
				if ( isDefined( level.ghost_round_presentation_ghost ) )
				{
					level.ghost_round_presentation_ghost thread ghost_switch_windows();
				}
			}
			if ( can_start_ghost_round_presentation_stage_2() )
			{
				level.zombie_ghost_round_states.presentation_stage_2_started = 1;
				level.sndmansionent playloopsound( "zmb_ghost_round_lp_quiet", 3 );
				level setclientfield( "ghost_round_light_state", 1 );
			}
			if ( can_start_ghost_round_presentation_stage_3() )
			{
				level.zombie_ghost_round_states.presentation_stage_3_started = 1;
				level.sndmansionent playloopsound( "zmb_ghost_round_lp_loud", 3 );
				if ( isDefined( level.ghost_round_presentation_ghost ) )
				{
					level.ghost_round_presentation_ghost thread ghost_round_presentation_sound();
				}
			}
		}
		wait 0,1;
	}
}

ghost_switch_windows()
{
	level endon( "intermission" );
	self endon( "death" );
	while ( 1 )
	{
		next_spot = get_next_spot_during_ghost_round_presentation();
		self setclientfield( "ghost_fx", 5 );
		self setclientfield( "sndGhostAudio", 0 );
		self ghost();
		self.script_mover moveto( next_spot.origin, 1 );
		self.script_mover waittill( "movedone" );
		self.script_mover.origin = next_spot.origin;
		self.script_mover.angles = next_spot.angles;
		self setclientfield( "ghost_fx", 3 );
		self setclientfield( "sndGhostAudio", 1 );
		self show();
		wait 6;
	}
}

ghost_round_presentation_sound()
{
	level endon( "intermission" );
	self endon( "death" );
	while ( 1 )
	{
		players = getplayers();
		_a3071 = players;
		_k3071 = getFirstArrayKey( _a3071 );
		while ( isDefined( _k3071 ) )
		{
			player = _a3071[ _k3071 ];
			if ( is_player_valid( player ) )
			{
				vox_index = randomint( level.ghost_vox.size );
				vox_line = level.ghost_vox[ vox_index ];
				self playsoundtoplayer( vox_line, player );
			}
			_k3071 = getNextArrayKey( _a3071, _k3071 );
		}
		wait randomintrange( 2, 6 );
	}
}

ghost_round_presentation_reset()
{
	if ( isDefined( level.sndmansionent ) )
	{
		level.sndmansionent stoploopsound( 3 );
	}
	if ( isDefined( level.ghost_round_presentation_ghost ) )
	{
		level.ghost_round_presentation_ghost.skip_death_notetracks = 1;
		level.ghost_round_presentation_ghost.nodeathragdoll = 1;
		level.ghost_round_presentation_ghost setclientfield( "ghost_fx", 5 );
		wait_network_frame();
		level.ghost_round_presentation_ghost delete();
		level.ghost_round_presentation_ghost = undefined;
	}
	level.zombie_ghost_round_states.presentation_stage_1_started = 0;
	level.zombie_ghost_round_states.presentation_stage_2_started = 0;
	level.zombie_ghost_round_states.presentation_stage_3_started = 0;
}

behave_after_fountain_transport( player )
{
	wait 1;
	if ( isDefined( player ) )
	{
		set_player_current_ghost_zone( player, undefined );
		level.zombie_ghost_round_states.is_teleporting = 1;
		ais = getaiarray( level.zombie_team );
		ghost_teleport_point_index = 0;
		ais_need_teleported = [];
		_a3133 = ais;
		_k3133 = getFirstArrayKey( _a3133 );
		while ( isDefined( _k3133 ) )
		{
			ai = _a3133[ _k3133 ];
			if ( isDefined( ai.is_ghost ) && ai.is_ghost && isDefined( ai.favoriteenemy ) && ai.favoriteenemy == player )
			{
				ais_need_teleported[ ais_need_teleported.size ] = ai;
			}
			_k3133 = getNextArrayKey( _a3133, _k3133 );
		}
		_a3141 = ais_need_teleported;
		_k3141 = getFirstArrayKey( _a3141 );
		while ( isDefined( _k3141 ) )
		{
			ai_need_teleported = _a3141[ _k3141 ];
			if ( ghost_teleport_point_index == level.ghost_zone_start_lower_locations.size )
			{
				ghost_teleport_point_index = 0;
			}
			teleport_point_origin = level.ghost_zone_start_lower_locations[ ghost_teleport_point_index ].origin;
			teleport_point_angles = level.ghost_zone_start_lower_locations[ ghost_teleport_point_index ].angles;
			ai_need_teleported forceteleport( teleport_point_origin, teleport_point_angles );
			ghost_teleport_point_index++;
			wait_network_frame();
			_k3141 = getNextArrayKey( _a3141, _k3141 );
		}
		wait 1;
		level.zombie_ghost_round_states.is_teleporting = 0;
	}
}

init_time_bomb_ghost_rounds()
{
	register_time_bomb_enemy( "ghost", ::is_ghost_round, ::save_ghost_data, ::time_bomb_respawns_ghosts );
	level.ghost_custom_think_logic = ::time_bomb_ghost_respawn_think;
	maps/mp/zombies/_zm_weap_time_bomb::time_bomb_add_custom_func_global_save( ::time_bomb_global_data_save_ghosts );
	maps/mp/zombies/_zm_weap_time_bomb::time_bomb_add_custom_func_global_restore( ::time_bomb_global_data_restore_ghosts );
	level._time_bomb.custom_funcs_get_enemies = ::time_bomb_custom_get_enemy_func;
	maps/mp/zombies/_zm_weap_time_bomb::register_time_bomb_enemy_save_filter( "zombie", ::is_ghost );
}

is_ghost()
{
	if ( isDefined( self.is_ghost )return !self.is_ghost;
}

is_ghost_round()
{
	return flag( "spawn_ghosts" );
}

save_ghost_data( s_data )
{
	s_data.origin = self.origin;
	s_data.angles = self.angles;
	s_data.is_ghost = self.is_ghost;
	s_data.spawn_point = self.spawn_point;
	if ( level.zombie_ghost_round_states.any_player_in_ghost_zone )
	{
		s_data.is_spawned_in_ghost_zone = self.is_spawned_in_ghost_zone;
	}
	else
	{
		s_data.is_spawned_in_ghost_zone = 0;
	}
	s_data.is_spawned_in_ghost_zone_actual = self.is_spawned_in_ghost_zone;
	s_data.find_target = self.find_target;
	s_data.favoriteenemy = self.favoriteenemy;
	s_data.ignore_timebomb_slowdown = self.ignore_timebomb_slowdown;
}

time_bomb_respawns_ghosts( save_struct )
{
	flag_clear( "spawn_ghosts" );
	ghost_round_presentation_reset();
	level.force_ghost_round_end = 1;
	level.force_ghost_round_start = 1;
	level waittill( "ghost_round_end" );
	level thread respawn_ghosts_outside_mansion( save_struct );
	level thread _respawn_ghost_failsafe();
	if ( !save_struct.custom_data.ghost_data.round_first_done )
	{
		level.zombie_ghost_round_states.is_first_ghost_round_finished = 0;
	}
	flag_wait( "time_bomb_enemies_restored" );
	level.force_ghost_round_end = undefined;
	level.force_ghost_round_start = undefined;
	level.zombie_ghost_round_states.is_started = save_struct.custom_data.ghost_data.round_started;
}

respawn_ghosts_outside_mansion( save_struct )
{
	a_spawns_outside_mansion = [];
	i = 0;
	while ( i < save_struct.enemies.size )
	{
		if ( isDefined( save_struct.enemies[ i ].is_spawned_in_ghost_zone ) && !save_struct.enemies[ i ].is_spawned_in_ghost_zone )
		{
			a_spawns_outside_mansion[ a_spawns_outside_mansion.size ] = save_struct.enemies[ i ];
		}
		i++;
	}
	level.zombie_ghost_round_states.active_zombie_locations = a_spawns_outside_mansion;
	save_struct.total_respawns = a_spawns_outside_mansion.size;
}

time_bomb_custom_get_enemy_func()
{
	a_enemies = [];
	a_valid_enemies = [];
	a_enemies = getaispeciesarray( level.zombie_team, "all" );
	i = 0;
	while ( i < a_enemies.size )
	{
		if ( isDefined( a_enemies[ i ].ignore_enemy_count ) && a_enemies[ i ].ignore_enemy_count && isDefined( a_enemies[ i ].is_ghost ) || !a_enemies[ i ].is_ghost && isDefined( level.ghost_round_presentation_ghost ) && level.ghost_round_presentation_ghost == a_enemies[ i ] )
		{
			i++;
			continue;
		}
		else
		{
			a_valid_enemies[ a_valid_enemies.size ] = a_enemies[ i ];
		}
		i++;
	}
	return a_valid_enemies;
}

time_bomb_global_data_save_ghosts()
{
	s_temp = spawnstruct();
	s_temp.ghost_count = level.zombie_ghost_count;
	s_temp.round_started = level.zombie_ghost_round_states.is_started;
	s_temp.round_first_done = level.zombie_ghost_round_states.is_first_ghost_round_finished;
	s_temp.round_next = level.zombie_ghost_round_states.next_ghost_round_number;
	s_temp.zombie_total = level.zombie_ghost_round_states.round_zombie_total;
	self.ghost_data = s_temp;
}

time_bomb_global_data_restore_ghosts()
{
	level.zombie_ghost_count = 0;
	level.zombie_ghost_round_states.is_started = self.ghost_data.round_started;
	level.zombie_ghost_round_states.is_first_ghost_round_finished = self.ghost_data.round_first_done;
	level.zombie_ghost_round_states.next_ghost_round_number = self.ghost_data.round_next;
	level.zombie_ghost_round_states.round_zombie_total = self.ghost_data.zombie_total;
	_a3311 = get_players();
	_k3311 = getFirstArrayKey( _a3311 );
	while ( isDefined( _k3311 ) )
	{
		player = _a3311[ _k3311 ];
		player.ghost_count = 0;
		_k3311 = getNextArrayKey( _a3311, _k3311 );
	}
}

time_bomb_ghost_respawn_think()
{
	if ( flag( "time_bomb_round_killed" ) && !flag( "time_bomb_enemies_restored" ) )
	{
		if ( isDefined( level.timebomb_override_struct ) )
		{
			save_struct = level.timebomb_override_struct;
		}
		else
		{
			save_struct = level.time_bomb_save_data;
		}
		if ( !isDefined( save_struct.respawn_counter ) )
		{
			save_struct.respawn_counter = 0;
		}
		n_index = save_struct.respawn_counter;
		save_struct.respawn_counter++;
		if ( save_struct.enemies.size > 0 && isDefined( save_struct.enemies ) && n_index < save_struct.enemies.size )
		{
			while ( isDefined( save_struct.enemies[ n_index ] ) && isDefined( save_struct.enemies[ n_index ].is_spawned_in_ghost_zone ) && save_struct.enemies[ n_index ].is_spawned_in_ghost_zone )
			{
				save_struct.respawn_counter++;
				n_index = save_struct.respawn_counter;
			}
			if ( isDefined( save_struct.enemies[ n_index ] ) )
			{
				self _restore_ghost_data( save_struct, n_index );
			}
		}
		if ( save_struct.respawn_counter >= save_struct.enemies.size || save_struct.enemies.size == 0 )
		{
			flag_set( "time_bomb_enemies_restored" );
			level.zombie_ghost_round_states.active_zombie_locations = [];
		}
		flag_wait( "time_bomb_enemies_restored" );
		self thread restore_ghost_failsafe();
	}
}

restore_ghost_failsafe()
{
	self endon( "death" );
	wait randomfloatrange( 2, 3 );
	if ( !isDefined( self.state ) )
	{
		self.respawned_by_time_bomb = 1;
		self thread ghost_think();
	}
	else
	{
		if ( isDefined( level.ghost_round_presentation_ghost ) && level.ghost_round_presentation_ghost == self )
		{
			ghost_round_presentation_reset();
			wait_network_frame();
			self thread ghost_think();
		}
	}
	self.passed_failsafe = 1;
}

_restore_ghost_data( save_struct, n_index )
{
	s_data = save_struct.enemies[ n_index ];
	playfxontag( level._effect[ "time_bomb_respawns_enemy" ], self, "J_SpineLower" );
	self.origin = s_data.origin;
	self.angles = s_data.angles;
	self.is_ghost = s_data.is_ghost;
	self.spawn_point = s_data.spawn_point;
	self.is_spawned_in_ghost_zone = s_data.is_spawned_in_ghost_zone;
	self.find_target = s_data.find_target;
	if ( isDefined( s_data.favoriteenemy ) )
	{
		self.favoriteenemy = s_data.favoriteenemy;
	}
	self.ignore_timebomb_slowdown = 1;
	self setgoalpos( self.origin );
}

_respawn_ghost_failsafe()
{
	n_counter = 0;
	while ( !flag( "time_bomb_enemies_restored" ) && n_counter < 20 )
	{
		if ( get_current_actor_count() >= level.zombie_ai_limit || isDefined( level.time_bomb_save_data.total_respawns ) && level.time_bomb_save_data.total_respawns == 0 )
		{
			flag_set( "time_bomb_enemies_restored" );
		}
		n_counter++;
		wait 0,5;
	}
	flag_set( "time_bomb_enemies_restored" );
}

devgui_warp_to_mansion()
{
/#
	player = gethostplayer();
	player setorigin( ( 2324, 560, 148 ) );
	player setplayerangles( ( 1, 1, 1 ) );
#/
}

devgui_toggle_no_ghost()
{
/#
	level.force_no_ghost = !level.force_no_ghost;
#/
}

draw_debug_line( from, to, color, time, depth_test )
{
/#
	if ( isDefined( level.ghost_debug ) && level.ghost_debug )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		line( from, to, color, 1, depth_test, time );
#/
	}
}

draw_debug_star( origin, color, time )
{
/#
	if ( isDefined( level.ghost_debug ) && level.ghost_debug )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( color ) )
		{
			color = ( 1, 1, 1 );
		}
		debugstar( origin, time, color );
#/
	}
}

draw_debug_box( origin, mins, maxs, yaw, color, time )
{
/#
	if ( isDefined( level.ghost_debug ) && level.ghost_debug )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( color ) )
		{
			color = ( 1, 1, 1 );
		}
		box( origin, mins, maxs, yaw, color, 1, 0, 1 );
#/
	}
}
