//checked includes match cerberus output
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_weap_time_bomb;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_equip_headchopper;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

maze_precache() //checked changed to match cerberus output
{
	blocker_locations = getstructarray( "maze_blocker", "targetname" );
	model_list = [];
	for ( i = 0; i < blocker_locations.size; i++ )
	{
		model_list[ blocker_locations[ i ].model ] = 1;
	}
	model_names = getarraykeys( model_list );
	for ( i = 0; i < model_names.size; i++ )
	{
		precachemodel( model_names[ i ] );
	}
}

maze_nodes_link_unlink_internal( func_ptr, bignorechangeonmigrate ) //checked changed to match cerberus output
{
	for ( i = 0; i < self.blocked_nodes.size; i++ )
	{
		for ( j = 0; j < self.blocked_nodes[i].connected_nodes.size; j++ )
		{
			[[ func_ptr ]]( self.blocked_nodes[ i ], self.blocked_nodes[ i ].connected_nodes[ j ], bignorechangeonmigrate );
			[[ func_ptr ]]( self.blocked_nodes[ i ].connected_nodes[ j ], self.blocked_nodes[ i ], bignorechangeonmigrate );
		}
	}
}

link_nodes_for_blocker_location() //checked matches cerberus output
{
	self maze_nodes_link_unlink_internal( maps/mp/zombies/_zm_utility::link_nodes, 1 );
}

unlink_nodes_for_blocker_location() //checked matches cerberus output
{
	self maze_nodes_link_unlink_internal( maps/mp/zombies/_zm_utility::unlink_nodes, 0 );
}

init_maze_clientfields() //checked changed to match cerberus output
{
	blocker_locations = getstructarray( "maze_blocker", "targetname" );
	foreach ( blocker in blocker_locations ) 
	{
		registerclientfield( "world", "maze_blocker_" + blocker.script_noteworthy, 12000, 1, "int" );
	}
}

init_maze_permutations() //checked changed to match cerberus output
{
	blocker_locations = getstructarray( "maze_blocker", "targetname" );
	level._maze._blocker_locations = [];
	for ( i = 0; i < blocker_locations.size; i++ )
	{
		if ( isDefined( blocker_locations[ i ].target ) )
		{
			blocker_locations[ i ].blocked_nodes = getnodearray( blocker_locations[ i ].target, "targetname" );
			for ( j = 0; j < blocker_locations[i].blocked_nodes.size; j++ )
			{
				blocker_locations[ i ].blocked_nodes[ j ].connected_nodes = getnodearray( blocker_locations[ i ].blocked_nodes[ j ].target, "targetname" );
			}
		}
		else
		{
			blocker_locations[ i ].blocked_nodes = [];
		}
		level._maze._blocker_locations[ blocker_locations[ i ].script_noteworthy ] = blocker_locations[ i ];
	}
	level._maze._perms = array( array( "blocker_1", "blocker_2", "blocker_3", "blocker_4" ), array( "blocker_5", "blocker_6", "blocker_7", "blocker_8", "blocker_9" ), array( "blocker_1", "blocker_10", "blocker_6", "blocker_4", "blocker_11" ), array( "blocker_1", "blocker_3", "blocker_4", "blocker_12" ), array( "blocker_5", "blocker_6", "blocker_12", "blocker_13" ), array( "blocker_4", "blocker_6", "blocker_14" ) );
	randomize_maze_perms();
	level._maze._active_perm_list = [];
}

init_maze_blocker_pool() //checked changed to match cerberus output
{
	pool_size = 0;
	for ( i = 0; i < level._maze._perms.size; i++ )
	{
		if ( level._maze._perms[ i ].size > pool_size )
		{
			pool_size = level._maze._perms[ i ].size;
		}
	}
	level._maze._blocker_pool = [];
	for ( i = 0; i < pool_size; i++ )
	{
		ent = spawn( "script_model", level._maze.players_in_maze_volume.origin - vectorScale( ( 0, 0, 1 ), 300 ) );
		ent ghost();
		ent.in_use = 0;
		level._maze._blocker_pool[ i ] = ent;
	}
	level._maze._blocker_pool_num_free = pool_size;
}

free_blockers_available() //checked matches cerberus output
{
	return level._maze._blocker_pool_num_free > 0;
}

get_free_blocker_model_from_pool() //checked changed to match cerberus output
{ 
	for ( i = 0; i < level._maze._blocker_pool.size; i++ )
	{
		if ( !level._maze._blocker_pool[ i ].in_use )
		{
			level._maze._blocker_pool[ i ].in_use = 1;
			level._maze._blocker_pool_num_free--;

			return level._maze._blocker_pool[ i ];
		}
	}
	/*
/#
	assertmsg( "zm_buried_maze : Blocker pool is empty." );
#/
	*/
	return undefined;
}

return_blocker_model_to_pool( ent ) //checked changed to match cerberus output
{
	ent ghost();
	ent.origin = level._maze.players_in_maze_volume.origin - vectorScale( ( 0, 0, 1 ), 300 );
	ent dontinterpolate();
	ent.in_use = 0;
	level._maze._blocker_pool_num_free++;
}

randomize_maze_perms() //checked matches cerberus output
{
	level._maze._perms = array_randomize( level._maze._perms );
	level._maze._cur_perm = 0;
}

init() //checked matches cerberus output
{
	level._maze = spawnstruct();
	level._maze.players_in_maze_volume = getent( "maze_player_volume", "targetname" );
	level._maze.players_can_see_maze_volume = getent( "maze_player_can_see_volume", "targetname" );
	init_maze_clientfields();
	init_maze_permutations();
	init_maze_blocker_pool();
	init_hedge_maze_spawnpoints();
	register_custom_spawner_entry( "hedge_location", ::maze_do_zombie_spawn );
	level thread maze_achievement_watcher();
	level thread vo_in_maze();
}

maze_blocker_sinks_thread( blocker ) //checked changed to match cerberus output
{
	self waittill( "lower_" + self.script_noteworthy );
	if ( flag( "start_zombie_round_logic" ) )
	{
		level setclientfield( "maze_blocker_" + self.script_noteworthy, 1 );
	}
	blocker maps/mp/zombies/_zm_equip_headchopper::destroyheadchopperstouching();
	blocker moveto( self.origin - vectorScale( ( 0, 0, 1 ), 96 ), 1 );
	blocker waittill( "movedone" );
	if ( flag( "start_zombie_round_logic" ) )
	{
		level setclientfield( "maze_blocker_" + self.script_noteworthy, 0 );
	}
	return_blocker_model_to_pool( blocker );
	self link_nodes_for_blocker_location();
}

delay_destroy_corpses_near_blocker() //checked changed to match cerberus output
{
	wait 0.2;
	corpses = getcorpsearray();
	if ( isDefined( corpses ) )
	{
		foreach ( corpse in corpses )
		{
			if ( distancesquared( corpse.origin, self.origin ) < 2304 )
			{
				corpse delete();
			}
		}
	}
}

maze_blocker_rises_thread() //checked changed to match cerberus output
{
	blocker = get_free_blocker_model_from_pool();
	self thread maze_blocker_sinks_thread( blocker );
	self unlink_nodes_for_blocker_location();
	blocker.origin = self.origin - vectorScale( ( 0, 0, 1 ), 96 );
	blocker.angles = self.angles;
	blocker setmodel( self.model );
	blocker dontinterpolate();
	blocker show();
	wait 0.05;
	if ( flag( "start_zombie_round_logic" ) )
	{
		level setclientfield( "maze_blocker_" + self.script_noteworthy, 1 );
	}
	blocker maps/mp/zombies/_zm_equip_headchopper::destroyheadchopperstouching();
	blocker moveto( self.origin, 0.65 );
	blocker thread delay_destroy_corpses_near_blocker();
	blocker waittill( "movedone" );
	if ( flag( "start_zombie_round_logic" ) )
	{
		level setclientfield( "maze_blocker_" + self.script_noteworthy, 0 );
	}
}

maze_do_perm_change() //checked changed to match cerberus output
{
	level._maze._cur_perm++;
	if ( level._maze._cur_perm == level._maze._perms.size )
	{
		randomize_maze_perms();
	}
	new_perm_list = level._maze._perms[ level._maze._cur_perm ];
	blockers_raise_list = [];
	blockers_lower_list = level._maze._active_perm_list;
	for ( i = 0; i < new_perm_list.size; i++ )
	{
		found = 0;
		for ( j = 0; j < level._maze._active_perm_list.size; j++ )
		{
			if ( new_perm_list[ i ] == level._maze._active_perm_list[ j ] )
			{
				found = 1;
				blockers_lower_list[ j ] = "";
				break;
			}
		}
		if ( !found )
		{
			blockers_raise_list[ blockers_raise_list.size ] = new_perm_list[ i ];
		}
	}
	level thread raise_new_perm_blockers( blockers_raise_list );
	level thread lower_old_perm_blockers( blockers_lower_list );
	level._maze._active_perm_list = level._maze._perms[ level._maze._cur_perm ];
}

raise_new_perm_blockers( list ) //checked changed to match cerberus output
{
	for ( i = 0; i < list.size; i++ )
	{
		while ( !free_blockers_available() )
		{
			wait 0.1;
		}
		level._maze._blocker_locations[ list[ i ] ] thread maze_blocker_rises_thread();
		wait 0.25;
	}
}

lower_old_perm_blockers( list ) //checked changed to match cerberus output
{
	for ( i = 0; i < list.size; i++ )
	{
		if ( list[ i ] != "" )
		{
			level._maze._blocker_locations[ list[ i ] ] notify( "lower_" + list[ i ] );
		}
		wait 0.25;
	}
}

maze_debug_print( str ) //checked matches cerberus output could not find dvar
{
	/*
/#
	if ( getDvar( #"55B04A98" ) != "" )
	{
		println( "Maze : " + str );
#/
	}
	*/
}

maze_can_change() //checked changed to match cerberus output
{
	players = getplayers();
	foreach ( player in players )
	{
		if ( player.sessionstate != "spectator" && player istouching( level._maze.players_in_maze_volume ) )
		{
			maze_debug_print( "Player " + player getentitynumber() + " in maze volume.  Maze cannot change." );
			return 0;
		}
	}
	foreach ( player in players )
	{
		if ( player.sessionstate != "spectator" && player istouching( level._maze.players_can_see_maze_volume ) )
		{
			if ( player maps/mp/zombies/_zm_utility::is_player_looking_at( level._maze.players_in_maze_volume.origin, 0.5, 0 ) )
			{
				maze_debug_print( "Player " + player getentitynumber() + " looking at maze.  Maze cannot change." );
				return 0;
			}
		}
	}
	maze_debug_print( "Maze mutating." );
	return 1;
}

maze_think() //checked matches cerberus output
{
	wait 0.1;
	while ( 1 )
	{
		if ( maze_can_change() )
		{
			maze_do_perm_change();
			level notify( "zm_buried_maze_changed" );
		}
		wait 10;
	}
}

init_hedge_maze_spawnpoints() //checked matches cerberus output
{
	level.maze_hedge_spawnpoints = getstructarray( "custom_spawner_entry hedge_location", "script_noteworthy" );
}

maze_do_zombie_spawn( spot ) //checked partially changed to match cerberus output see info.md
{
	self endon( "death" );
	spots = level.maze_hedge_spawnpoints;
	spot = undefined;
	/*
/#
	assert( spots.size > 0, "No spawn locations found" );
#/
	*/
	players_in_maze = maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_maze", 1 );
	if ( isDefined( players_in_maze ) && players_in_maze.size != 0 )
	{
		player = random( players_in_maze );
		maxdistance = 256;
		if ( randomint( 100 ) > 75 )
		{
			maxdistance = 512;
		}
		closest_spots = get_array_of_closest( player.origin, spots, undefined, undefined, maxdistance );
		favoritespots = [];
		foreach ( close_spot in closest_spots )
		{
			if ( within_fov( close_spot.origin, close_spot.angles, player.origin, -0.75 ) )
			{
				favoritespots[ favoritespots.size ] = close_spot;
			}
			else
			{
				if ( randomint( 100 ) > 75 )
				{
					favoritespots[ favoritespots.size ] = close_spot;
				}
			}
		}
		if ( isDefined( favoritespots ) && favoritespots.size >= 2 )
		{
			spot = random( favoritespots );
		}
		else if ( isDefined( closest_spots ) && closest_spots.size > 0 )
		{
			spot = random( closest_spots );
		}
	}
	if ( !isDefined( spot ) )
	{
		spot = random( spots );
	}
	self.spawn_point = spot;
	if ( isDefined( spot.target ) )
	{
		self.target = spot.target;
	}
	if ( isDefined( spot.zone_name ) )
	{
		self.zone_name = spot.zone_name;
	}
	if ( isDefined( spot.script_parameters ) )
	{
		self.script_parameters = spot.script_parameters;
	}
	self thread maze_do_zombie_rise( spot );
}

maze_do_zombie_rise( spot ) //checked changed to match cerberus output
{
	self endon( "death" );
	self.in_the_ground = 1;
	if ( isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	self.anchor = spawn( "script_origin", self.origin );
	self.anchor.angles = self.angles;
	self linkto( self.anchor );
	if ( !isDefined( spot.angles ) )
	{
		spot.angles = ( 0, 0, 0 );
	}
	anim_org = spot.origin;
	anim_ang = spot.angles;
	anim_org += ( 0, 0, 0 );
	self ghost();
	self.anchor moveto( anim_org, 0.05 );
	self.anchor waittill( "movedone" );
	target_org = get_desired_origin();
	if ( isDefined( target_org ) )
	{
		anim_ang = vectorToAngles( target_org - self.origin );
		self.anchor rotateto( ( 0, anim_ang[ 1 ], 0 ), 0.05 );
		self.anchor waittill( "rotatedone" );
	}
	self unlink();
	if ( isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	self thread maps/mp/zombies/_zm_spawner::hide_pop();
	level thread maps/mp/zombies/_zm_spawner::zombie_rise_death( self, spot );
	spot thread maps/mp/zombies/_zm_spawner::zombie_rise_fx( self );
	substate = 0;
	if ( self.zombie_move_speed == "walk" )
	{
		substate = randomint( 2 );
	}
	else
	{
		substate = 1;
	}
	self orientmode( "face default" );
	self animscripted( spot.origin, spot.angles, "zm_rise_hedge", substate );
	self notify( "rise_anim_finished" );
	spot notify( "stop_zombie_rise_fx" );
	self.in_the_ground = 0;
	self notify( "risen", spot.script_string );
}

maze_achievement_watcher() //checked matches cerberus output
{
	while ( 1 )
	{
		level waittill( "start_of_round" );
		start_maze_achievement_threads();
		level waittill( "end_of_round" );
		check_maze_achievement_threads();
	}
}

start_maze_achievement_threads() //checked partially changed to match cerberus output see info.md
{
	if ( level.round_number >= 20 )
	{
		foreach ( player in get_players() )
		{
			player.achievement_player_started_round_in_maze = player is_player_in_zone( "zone_maze" );
			if ( player.achievement_player_started_round_in_maze )
			{
				player thread watch_player_in_maze();
			}
			else
			{
				player notify( "_maze_achievement_think_done" );
			}
		}
	}
}

watch_player_in_maze() //checked matches cerberus output
{
	self notify( "_maze_achievement_think_done" );
	self endon( "_maze_achievement_think_done" );
	self endon( "death_or_disconnect" );
	self.achievement_player_stayed_in_maze_for_entire_round = 1;
	while ( self.achievement_player_stayed_in_maze_for_entire_round )
	{
		self.achievement_player_stayed_in_maze_for_entire_round = self is_player_in_zone( "zone_maze" );
		wait randomfloatrange( 0.5, 1 );
	}
}

check_maze_achievement_threads() //checked changed to match cerberus output
{
	if ( level.round_number >= 20 )
	{
		foreach ( player in get_players() )
		{
			if ( isDefined( player.achievement_player_started_round_in_maze ) && player.achievement_player_started_round_in_maze && isDefined( player.achievement_player_stayed_in_maze_for_entire_round ) && player.achievement_player_stayed_in_maze_for_entire_round && level._time_bomb.last_round_restored != ( level.round_number - 1 ) && !maps/mp/zombies/_zm_weap_time_bomb::is_time_bomb_round_change() )
			{
				/*
/#
				iprintlnbold( player.name + " got achievement MAZED AND CONFUSED" );
#/
				*/
				player notify( "player_stayed_in_maze_for_entire_high_level_round" );
				player notify( "_maze_achievement_think_done" );
			}
		}
	}
}

vo_in_maze() //checked did not change to match cerberus output
{
	flag_wait( "mansion_door1" );
	nwaittime = 300;
	nminwait = 5;
	nmaxwait = 10;
	while ( 1 )
	{
		aplayersinzone = maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_maze", 1 );
		while ( !isDefined( aplayersinzone ) || aplayersinzone.size == 0 )
		{
			wait randomintrange( nminwait, nmaxwait );
			aplayersinzone = maps/mp/zombies/_zm_zonemgr::get_players_in_zone( "zone_maze", 1 );
		}
		random( aplayersinzone ) maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "in_maze" );
		nminwait = 13;
		nmaxwait = 37;
		wait nwaittime;
	}
}

