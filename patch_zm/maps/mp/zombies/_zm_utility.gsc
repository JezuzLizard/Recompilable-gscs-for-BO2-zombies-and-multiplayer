#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_server_throttle;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/zm_run;
#include common_scripts/utility;
#include maps/mp/_utility;

init_utility()
{
}

is_classic()
{
	var = getDvar( "ui_zm_gamemodegroup" );
	if ( var == "zclassic" )
	{
		return 1;
	}
	return 0;
}

is_standard()
{
	var = getDvar( "ui_gametype" );
	if ( var == "zstandard" )
	{
		return 1;
	}
	return 0;
}

convertsecondstomilliseconds( seconds )
{
	return seconds * 1000;
}

is_player()
{
	if ( !isplayer( self ) )
	{
		if ( isDefined( self.pers ) )
		{
			if ( isDefined( self.pers[ "isBot" ] ) )
			{
				return self.pers[ "isBot" ];
			}
		}
	}
}

lerp( chunk )
{
	link = spawn( "script_origin", self getorigin() );
	link.angles = self.first_node.angles;
	self linkto( link );
	link rotateto( self.first_node.angles, level._contextual_grab_lerp_time );
	link moveto( self.attacking_spot, level._contextual_grab_lerp_time );
	link waittill_multiple( "rotatedone", "movedone" );
	self unlink();
	link delete();
	return;
}

clear_mature_blood()
{
	blood_patch = getentarray( "mature_blood", "targetname" );
	if ( is_mature() )
	{
		return;
	}
	while ( isDefined( blood_patch ) )
	{
		i = 0;
		while ( i < blood_patch.size )
		{
			blood_patch[ i ] delete();
			i++;
		}
	}
}

recalc_zombie_array()
{
}

clear_all_corpses()
{
	corpse_array = getcorpsearray();
	i = 0;
	while ( i < corpse_array.size )
	{
		if ( isDefined( corpse_array[ i ] ) )
		{
			corpse_array[ i ] delete();
		}
		i++;
	}
}

get_current_corpse_count()
{
	corpse_array = getcorpsearray();
	if ( isDefined( corpse_array ) )
	{
		return corpse_array.size;
	}
	return 0;
}

get_current_actor_count()
{
	count = 0;
	actors = getaispeciesarray( level.zombie_team, "all" );
	if ( isDefined( actors ) )
	{
		count += actors.size;
	}
	count += get_current_corpse_count();
	return count;
}

get_current_zombie_count()
{
	enemies = get_round_enemy_array();
	return enemies.size;
}

get_round_enemy_array()
{
	enemies = [];
	valid_enemies = [];
	enemies = getaispeciesarray( level.zombie_team, "all" );
	i = 0;
	while ( i < enemies.size )
	{
		if ( isDefined( enemies[ i ].ignore_enemy_count ) && enemies[ i ].ignore_enemy_count )
		{
			i++;
			continue;
		}
		else
		{
			valid_enemies[ valid_enemies.size ] = enemies[ i ];
		}
		i++;
	}
	return valid_enemies;
}

init_zombie_run_cycle()
{
	if ( isDefined( level.speed_change_round ) )
	{
		if ( level.round_number >= level.speed_change_round )
		{
			speed_percent = 0,2 + ( ( level.round_number - level.speed_change_round ) * 0,2 );
			speed_percent = min( speed_percent, 1 );
			change_round_max = int( level.speed_change_max * speed_percent );
			change_left = change_round_max - level.speed_change_num;
			if ( change_left == 0 )
			{
				self set_zombie_run_cycle();
				return;
			}
			change_speed = randomint( 100 );
			if ( change_speed > 80 )
			{
				self change_zombie_run_cycle();
				return;
			}
			zombie_count = get_current_zombie_count();
			zombie_left = level.zombie_ai_limit - zombie_count;
			if ( zombie_left == change_left )
			{
				self change_zombie_run_cycle();
				return;
			}
		}
	}
	self set_zombie_run_cycle();
}

change_zombie_run_cycle()
{
	level.speed_change_num++;
	if ( level.gamedifficulty == 0 )
	{
		self set_zombie_run_cycle( "sprint" );
	}
	else
	{
		self set_zombie_run_cycle( "walk" );
	}
	self thread speed_change_watcher();
}

speed_change_watcher()
{
	self waittill( "death" );
	if ( level.speed_change_num > 0 )
	{
		level.speed_change_num--;

	}
}

set_zombie_run_cycle( new_move_speed )
{
	self.zombie_move_speed_original = self.zombie_move_speed;
	if ( isDefined( new_move_speed ) )
	{
		self.zombie_move_speed = new_move_speed;
	}
	else if ( level.gamedifficulty == 0 )
	{
		self set_run_speed_easy();
	}
	else
	{
		self set_run_speed();
	}
	self maps/mp/animscripts/zm_run::needsupdate();
	self.deathanim = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_death" );
}

set_run_speed()
{
	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 35 );
	if ( rand <= 35 )
	{
		self.zombie_move_speed = "walk";
	}
	else if ( rand <= 70 )
	{
		self.zombie_move_speed = "run";
	}
	else
	{
		self.zombie_move_speed = "sprint";
	}
}

set_run_speed_easy()
{
	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 25 );
	if ( rand <= 35 )
	{
		self.zombie_move_speed = "walk";
	}
	else
	{
		self.zombie_move_speed = "run";
	}
}

spawn_zombie( spawner, target_name, spawn_point, round_number )
{
	if ( !isDefined( spawner ) )
	{
/#
		println( "ZM >> spawn_zombie - NO SPAWNER DEFINED" );
#/
		return undefined;
	}
	while ( getfreeactorcount() < 1 )
	{
		wait 0,05;
	}
	spawner.script_moveoverride = 1;
	if ( isDefined( spawner.script_forcespawn ) && spawner.script_forcespawn )
	{
		guy = spawner spawnactor();
		if ( isDefined( level.giveextrazombies ) )
		{
			guy [[ level.giveextrazombies ]]();
		}
		guy enableaimassist();
		if ( isDefined( round_number ) )
		{
			guy._starting_round_number = round_number;
		}
		guy.aiteam = level.zombie_team;
		guy clearentityowner();
		level.zombiemeleeplayercounter = 0;
		guy thread run_spawn_functions();
		guy forceteleport( spawner.origin );
		guy show();
	}
	spawner.count = 666;
	if ( !spawn_failed( guy ) )
	{
		if ( isDefined( target_name ) )
		{
			guy.targetname = target_name;
		}
		return guy;
	}
	return undefined;
}

run_spawn_functions()
{
	self endon( "death" );
	waittillframeend;
	i = 0;
	while ( i < level.spawn_funcs[ self.team ].size )
	{
		func = level.spawn_funcs[ self.team ][ i ];
		single_thread( self, func[ "function" ], func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ], func[ "param5" ] );
		i++;
	}
	if ( isDefined( self.spawn_funcs ) )
	{
		i = 0;
		while ( i < self.spawn_funcs.size )
		{
			func = self.spawn_funcs[ i ];
			single_thread( self, func[ "function" ], func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ] );
			i++;
		}
/#
		self.saved_spawn_functions = self.spawn_funcs;
#/
		self.spawn_funcs = undefined;
/#
		self.spawn_funcs = self.saved_spawn_functions;
		self.saved_spawn_functions = undefined;
#/
		self.spawn_funcs = undefined;
	}
}

create_simple_hud( client, team )
{
	if ( isDefined( team ) )
	{
		hud = newteamhudelem( team );
		hud.team = team;
	}
	else if ( isDefined( client ) )
	{
		hud = newclienthudelem( client );
	}
	else
	{
		hud = newhudelem();
	}
	level.hudelem_count++;
	hud.foreground = 1;
	hud.sort = 1;
	hud.hidewheninmenu = 0;
	return hud;
}

destroy_hud()
{
	level.hudelem_count--;

	self destroy();
}

all_chunks_intact( barrier, barrier_chunks )
{
	if ( isDefined( barrier.zbarrier ) )
	{
		pieces = barrier.zbarrier getzbarrierpieceindicesinstate( "closed" );
		if ( pieces.size != barrier.zbarrier getnumzbarrierpieces() )
		{
			return 0;
		}
	}
	else
	{
		i = 0;
		while ( i < barrier_chunks.size )
		{
			if ( barrier_chunks[ i ] get_chunk_state() != "repaired" )
			{
				return 0;
			}
			i++;
		}
	}
	return 1;
}

no_valid_repairable_boards( barrier, barrier_chunks )
{
	if ( isDefined( barrier.zbarrier ) )
	{
		pieces = barrier.zbarrier getzbarrierpieceindicesinstate( "open" );
		if ( pieces.size )
		{
			return 0;
		}
	}
	else
	{
		i = 0;
		while ( i < barrier_chunks.size )
		{
			if ( barrier_chunks[ i ] get_chunk_state() == "destroyed" )
			{
				return 0;
			}
			i++;
		}
	}
	return 1;
}

is_survival()
{
	var = getDvar( "ui_zm_gamemodegroup" );
	if ( var == "zsurvival" )
	{
		return 1;
	}
	return 0;
}

is_encounter()
{
	if ( isDefined( level._is_encounter ) && level._is_encounter )
	{
		return 1;
	}
	var = getDvar( "ui_zm_gamemodegroup" );
	if ( var == "zencounter" )
	{
		level._is_encounter = 1;
		return 1;
	}
	return 0;
}

all_chunks_destroyed( barrier, barrier_chunks )
{
	if ( isDefined( barrier.zbarrier ) )
	{
		pieces = arraycombine( barrier.zbarrier getzbarrierpieceindicesinstate( "open" ), barrier.zbarrier getzbarrierpieceindicesinstate( "opening" ), 1, 0 );
		if ( pieces.size != barrier.zbarrier getnumzbarrierpieces() )
		{
			return 0;
		}
	}
	else
	{
		while ( isDefined( barrier_chunks ) )
		{
/#
			assert( isDefined( barrier_chunks ), "_zm_utility::all_chunks_destroyed - Barrier chunks undefined" );
#/
			i = 0;
			while ( i < barrier_chunks.size )
			{
				if ( barrier_chunks[ i ] get_chunk_state() != "destroyed" )
				{
					return 0;
				}
				i++;
			}
		}
	}
	return 1;
}

check_point_in_playable_area( origin )
{
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	check_model = spawn( "script_model", origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	valid_point = 0;
	i = 0;
	while ( i < playable_area.size )
	{
		if ( check_model istouching( playable_area[ i ] ) )
		{
			valid_point = 1;
		}
		i++;
	}
	check_model delete();
	return valid_point;
}

check_point_in_enabled_zone( origin, zone_is_active, player_zones )
{
	if ( !isDefined( player_zones ) )
	{
		player_zones = getentarray( "player_volume", "script_noteworthy" );
	}
	if ( !isDefined( level.zones ) || !isDefined( player_zones ) )
	{
		return 1;
	}
	scr_org = spawn( "script_origin", origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	one_valid_zone = 0;
	i = 0;
	while ( i < player_zones.size )
	{
		if ( scr_org istouching( player_zones[ i ] ) )
		{
			zone = level.zones[ player_zones[ i ].targetname ];
			if ( isDefined( zone ) && isDefined( zone.is_enabled ) && zone.is_enabled )
			{
				if ( isDefined( zone_is_active ) && zone_is_active == 1 && isDefined( zone.is_active ) && !zone.is_active )
				{
					i++;
					continue;
				}
				else
				{
					one_valid_zone = 1;
					break;
				}
			}
		}
		else
		{
			i++;
		}
	}
	scr_org delete();
	return one_valid_zone;
}

round_up_to_ten( score )
{
	new_score = score - ( score % 10 );
	if ( new_score < score )
	{
		new_score += 10;
	}
	return new_score;
}

round_up_score( score, value )
{
	score = int( score );
	new_score = score - ( score % value );
	if ( new_score < score )
	{
		new_score += value;
	}
	return new_score;
}

random_tan()
{
	rand = randomint( 100 );
	if ( isDefined( level.char_percent_override ) )
	{
		percentnotcharred = level.char_percent_override;
	}
	else
	{
		percentnotcharred = 65;
	}
}

places_before_decimal( num )
{
	abs_num = abs( num );
	count = 0;
	while ( 1 )
	{
		abs_num *= 0,1;
		count += 1;
		if ( abs_num < 1 )
		{
			return count;
		}
	}
}

create_zombie_point_of_interest( attract_dist, num_attractors, added_poi_value, start_turned_on, initial_attract_func, arrival_attract_func, poi_team )
{
	if ( !isDefined( added_poi_value ) )
	{
		self.added_poi_value = 0;
	}
	else
	{
		self.added_poi_value = added_poi_value;
	}
	if ( !isDefined( start_turned_on ) )
	{
		start_turned_on = 1;
	}
	self.script_noteworthy = "zombie_poi";
	self.poi_active = start_turned_on;
	if ( isDefined( attract_dist ) )
	{
		self.poi_radius = attract_dist * attract_dist;
	}
	else
	{
		self.poi_radius = undefined;
	}
	self.num_poi_attracts = num_attractors;
	self.attract_to_origin = 1;
	self.attractor_array = [];
	self.initial_attract_func = undefined;
	self.arrival_attract_func = undefined;
	if ( isDefined( poi_team ) )
	{
		self._team = poi_team;
	}
	if ( isDefined( initial_attract_func ) )
	{
		self.initial_attract_func = initial_attract_func;
	}
	if ( isDefined( arrival_attract_func ) )
	{
		self.arrival_attract_func = arrival_attract_func;
	}
}

create_zombie_point_of_interest_attractor_positions( num_attract_dists, diff_per_dist, attractor_width )
{
	self endon( "death" );
	forward = ( 0, 0, 1 );
	if ( !isDefined( self.num_poi_attracts ) || isDefined( self.script_noteworthy ) && self.script_noteworthy != "zombie_poi" )
	{
		return;
	}
	if ( !isDefined( num_attract_dists ) )
	{
		num_attract_dists = 4;
	}
	if ( !isDefined( diff_per_dist ) )
	{
		diff_per_dist = 45;
	}
	if ( !isDefined( attractor_width ) )
	{
		attractor_width = 45;
	}
	self.attract_to_origin = 0;
	self.num_attract_dists = num_attract_dists;
	self.last_index = [];
	i = 0;
	while ( i < num_attract_dists )
	{
		self.last_index[ i ] = -1;
		i++;
	}
	self.attract_dists = [];
	i = 0;
	while ( i < self.num_attract_dists )
	{
		self.attract_dists[ i ] = diff_per_dist * ( i + 1 );
		i++;
	}
	max_positions = [];
	i = 0;
	while ( i < self.num_attract_dists )
	{
		max_positions[ i ] = int( ( 6,28 * self.attract_dists[ i ] ) / attractor_width );
		i++;
	}
	num_attracts_per_dist = self.num_poi_attracts / self.num_attract_dists;
	self.max_attractor_dist = self.attract_dists[ self.attract_dists.size - 1 ] * 1,1;
	diff = 0;
	actual_num_positions = [];
	i = 0;
	while ( i < self.num_attract_dists )
	{
		if ( num_attracts_per_dist > ( max_positions[ i ] + diff ) )
		{
			actual_num_positions[ i ] = max_positions[ i ];
			diff += num_attracts_per_dist - max_positions[ i ];
			i++;
			continue;
		}
		else
		{
			actual_num_positions[ i ] = num_attracts_per_dist + diff;
			diff = 0;
		}
		i++;
	}
	self.attractor_positions = [];
	failed = 0;
	angle_offset = 0;
	prev_last_index = -1;
	j = 0;
	while ( j < 4 )
	{
		if ( ( actual_num_positions[ j ] + failed ) < max_positions[ j ] )
		{
			actual_num_positions[ j ] += failed;
			failed = 0;
		}
		else
		{
			if ( actual_num_positions[ j ] < max_positions[ j ] )
			{
				actual_num_positions[ j ] = max_positions[ j ];
				failed = max_positions[ j ] - actual_num_positions[ j ];
			}
		}
		failed += self generated_radius_attract_positions( forward, angle_offset, actual_num_positions[ j ], self.attract_dists[ j ] );
		angle_offset += 15;
		self.last_index[ j ] = int( ( actual_num_positions[ j ] - failed ) + prev_last_index );
		prev_last_index = self.last_index[ j ];
		j++;
	}
	self notify( "attractor_positions_generated" );
	level notify( "attractor_positions_generated" );
}

generated_radius_attract_positions( forward, offset, num_positions, attract_radius )
{
	self endon( "death" );
	epsilon = 0,1;
	failed = 0;
	degs_per_pos = 360 / num_positions;
	i = offset;
	while ( i < ( 360 + offset ) )
	{
		altforward = forward * attract_radius;
		rotated_forward = ( ( cos( i ) * altforward[ 0 ] ) - ( sin( i ) * altforward[ 1 ] ), ( sin( i ) * altforward[ 0 ] ) + ( cos( i ) * altforward[ 1 ] ), altforward[ 2 ] );
		if ( isDefined( level.poi_positioning_func ) )
		{
			pos = [[ level.poi_positioning_func ]]( self.origin, rotated_forward );
		}
		else if ( isDefined( level.use_alternate_poi_positioning ) && level.use_alternate_poi_positioning )
		{
			pos = maps/mp/zombies/_zm_server_throttle::server_safe_ground_trace( "poi_trace", 10, self.origin + rotated_forward + vectorScale( ( 0, 0, 1 ), 10 ) );
		}
		else
		{
			pos = maps/mp/zombies/_zm_server_throttle::server_safe_ground_trace( "poi_trace", 10, self.origin + rotated_forward + vectorScale( ( 0, 0, 1 ), 100 ) );
		}
		if ( !isDefined( pos ) )
		{
			failed++;
		}
		else if ( isDefined( level.use_alternate_poi_positioning ) && level.use_alternate_poi_positioning )
		{
			if ( isDefined( self ) && isDefined( self.origin ) )
			{
				if ( self.origin[ 2 ] >= ( pos[ 2 ] - epsilon ) && ( self.origin[ 2 ] - pos[ 2 ] ) <= 150 )
				{
					pos_array = [];
					pos_array[ 0 ] = pos;
					pos_array[ 1 ] = self;
					self.attractor_positions[ self.attractor_positions.size ] = pos_array;
				}
			}
			else
			{
				failed++;
			}
		}
		else
		{
			if ( abs( pos[ 2 ] - self.origin[ 2 ] ) < 60 )
			{
				pos_array = [];
				pos_array[ 0 ] = pos;
				pos_array[ 1 ] = self;
				self.attractor_positions[ self.attractor_positions.size ] = pos_array;
				break;
			}
			else
			{
				failed++;
			}
		}
		i += degs_per_pos;
	}
	return failed;
}

debug_draw_attractor_positions()
{
/#
	while ( 1 )
	{
		for ( ;; )
		{
			while ( !isDefined( self.attractor_positions ) )
			{
				wait 0,05;
			}
		}
		i = 0;
		while ( i < self.attractor_positions.size )
		{
			line( self.origin, self.attractor_positions[ i ][ 0 ], ( 0, 0, 1 ), 1, 1 );
			i++;
		}
		wait 0,05;
		if ( !isDefined( self ) )
		{
			return;
		}
#/
	}
}

get_zombie_point_of_interest( origin, poi_array )
{
	if ( isDefined( self.ignore_all_poi ) && self.ignore_all_poi )
	{
		return undefined;
	}
	curr_radius = undefined;
	if ( isDefined( poi_array ) )
	{
		ent_array = poi_array;
	}
	else
	{
		ent_array = getentarray( "zombie_poi", "script_noteworthy" );
	}
	best_poi = undefined;
	position = undefined;
	best_dist = 100000000;
	i = 0;
	while ( i < ent_array.size )
	{
		if ( !isDefined( ent_array[ i ].poi_active ) || !ent_array[ i ].poi_active )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( self.ignore_poi_targetname ) && self.ignore_poi_targetname.size > 0 )
			{
				if ( isDefined( ent_array[ i ].targetname ) )
				{
					ignore = 0;
					j = 0;
					while ( j < self.ignore_poi_targetname.size )
					{
						if ( ent_array[ i ].targetname == self.ignore_poi_targetname[ j ] )
						{
							ignore = 1;
							break;
						}
						else
						{
							j++;
						}
					}
					if ( ignore )
					{
						i++;
						continue;
					}
				}
			}
			else if ( isDefined( self.ignore_poi ) && self.ignore_poi.size > 0 )
			{
				ignore = 0;
				j = 0;
				while ( j < self.ignore_poi.size )
				{
					if ( self.ignore_poi[ j ] == ent_array[ i ] )
					{
						ignore = 1;
						break;
					}
					else
					{
						j++;
					}
				}
				if ( ignore )
				{
					i++;
					continue;
				}
			}
			else
			{
				dist = distancesquared( origin, ent_array[ i ].origin );
				dist -= ent_array[ i ].added_poi_value;
				if ( isDefined( ent_array[ i ].poi_radius ) )
				{
					curr_radius = ent_array[ i ].poi_radius;
				}
				if ( isDefined( curr_radius ) && dist < curr_radius && dist < best_dist && ent_array[ i ] can_attract( self ) )
				{
					best_poi = ent_array[ i ];
					best_dist = dist;
				}
			}
		}
		i++;
	}
	if ( isDefined( best_poi ) )
	{
		if ( isDefined( best_poi._team ) )
		{
			if ( isDefined( self._race_team ) && self._race_team != best_poi._team )
			{
				return undefined;
			}
		}
		if ( isDefined( best_poi._new_ground_trace ) && best_poi._new_ground_trace )
		{
			position = [];
			position[ 0 ] = groundpos_ignore_water_new( best_poi.origin + vectorScale( ( 0, 0, 1 ), 100 ) );
			position[ 1 ] = self;
		}
		else
		{
			if ( isDefined( best_poi.attract_to_origin ) && best_poi.attract_to_origin )
			{
				position = [];
				position[ 0 ] = groundpos( best_poi.origin + vectorScale( ( 0, 0, 1 ), 100 ) );
				position[ 1 ] = self;
			}
			else
			{
				position = self add_poi_attractor( best_poi );
			}
		}
		if ( isDefined( best_poi.initial_attract_func ) )
		{
			self thread [[ best_poi.initial_attract_func ]]( best_poi );
		}
		if ( isDefined( best_poi.arrival_attract_func ) )
		{
			self thread [[ best_poi.arrival_attract_func ]]( best_poi );
		}
	}
	return position;
}

activate_zombie_point_of_interest()
{
	if ( self.script_noteworthy != "zombie_poi" )
	{
		return;
	}
	self.poi_active = 1;
}

deactivate_zombie_point_of_interest()
{
	if ( self.script_noteworthy != "zombie_poi" )
	{
		return;
	}
	i = 0;
	while ( i < self.attractor_array.size )
	{
		self.attractor_array[ i ] notify( "kill_poi" );
		i++;
	}
	self.attractor_array = [];
	self.claimed_attractor_positions = [];
	self.poi_active = 0;
}

assign_zombie_point_of_interest( origin, poi )
{
	position = undefined;
	doremovalthread = 0;
	if ( isDefined( poi ) && poi can_attract( self ) )
	{
		if ( !isDefined( poi.attractor_array ) || isDefined( poi.attractor_array ) && array_check_for_dupes( poi.attractor_array, self ) )
		{
			doremovalthread = 1;
		}
		position = self add_poi_attractor( poi );
		if ( isDefined( position ) && doremovalthread && !array_check_for_dupes( poi.attractor_array, self ) )
		{
			self thread update_on_poi_removal( poi );
		}
	}
	return position;
}

remove_poi_attractor( zombie_poi )
{
	if ( !isDefined( zombie_poi.attractor_array ) )
	{
		return;
	}
	i = 0;
	while ( i < zombie_poi.attractor_array.size )
	{
		if ( zombie_poi.attractor_array[ i ] == self )
		{
			self notify( "kill_poi" );
			arrayremovevalue( zombie_poi.attractor_array, zombie_poi.attractor_array[ i ] );
			arrayremovevalue( zombie_poi.claimed_attractor_positions, zombie_poi.claimed_attractor_positions[ i ] );
		}
		i++;
	}
}

array_check_for_dupes_using_compare( array, single, is_equal_fn )
{
	i = 0;
	while ( i < array.size )
	{
		if ( [[ is_equal_fn ]]( array[ i ], single ) )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

poi_locations_equal( loc1, loc2 )
{
	return loc1[ 0 ] == loc2[ 0 ];
}

add_poi_attractor( zombie_poi )
{
	if ( !isDefined( zombie_poi ) )
	{
		return;
	}
	if ( !isDefined( zombie_poi.attractor_array ) )
	{
		zombie_poi.attractor_array = [];
	}
	if ( array_check_for_dupes( zombie_poi.attractor_array, self ) )
	{
		if ( !isDefined( zombie_poi.claimed_attractor_positions ) )
		{
			zombie_poi.claimed_attractor_positions = [];
		}
		if ( !isDefined( zombie_poi.attractor_positions ) || zombie_poi.attractor_positions.size <= 0 )
		{
			return undefined;
		}
		start = -1;
		end = -1;
		last_index = -1;
		i = 0;
		while ( i < 4 )
		{
			if ( zombie_poi.claimed_attractor_positions.size < zombie_poi.last_index[ i ] )
			{
				start = last_index + 1;
				end = zombie_poi.last_index[ i ];
				break;
			}
			else
			{
				last_index = zombie_poi.last_index[ i ];
				i++;
			}
		}
		best_dist = 100000000;
		best_pos = undefined;
		if ( start < 0 )
		{
			start = 0;
		}
		if ( end < 0 )
		{
			return undefined;
		}
		i = int( start );
		while ( i <= int( end ) )
		{
			if ( !isDefined( zombie_poi.attractor_positions[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				if ( array_check_for_dupes_using_compare( zombie_poi.claimed_attractor_positions, zombie_poi.attractor_positions[ i ], ::poi_locations_equal ) )
				{
					if ( isDefined( zombie_poi.attractor_positions[ i ][ 0 ] ) && isDefined( self.origin ) )
					{
						dist = distancesquared( zombie_poi.attractor_positions[ i ][ 0 ], self.origin );
						if ( dist < best_dist || !isDefined( best_pos ) )
						{
							best_dist = dist;
							best_pos = zombie_poi.attractor_positions[ i ];
						}
					}
				}
			}
			i++;
		}
		if ( !isDefined( best_pos ) )
		{
			return undefined;
		}
		zombie_poi.attractor_array[ zombie_poi.attractor_array.size ] = self;
		self thread update_poi_on_death( zombie_poi );
		zombie_poi.claimed_attractor_positions[ zombie_poi.claimed_attractor_positions.size ] = best_pos;
		return best_pos;
	}
	else
	{
		i = 0;
		while ( i < zombie_poi.attractor_array.size )
		{
			if ( zombie_poi.attractor_array[ i ] == self )
			{
				if ( isDefined( zombie_poi.claimed_attractor_positions ) && isDefined( zombie_poi.claimed_attractor_positions[ i ] ) )
				{
					return zombie_poi.claimed_attractor_positions[ i ];
				}
			}
			i++;
		}
	}
	return undefined;
}

can_attract( attractor )
{
	if ( !isDefined( self.attractor_array ) )
	{
		self.attractor_array = [];
	}
	if ( isDefined( self.attracted_array ) && !isinarray( self.attracted_array, attractor ) )
	{
		return 0;
	}
	if ( !array_check_for_dupes( self.attractor_array, attractor ) )
	{
		return 1;
	}
	if ( isDefined( self.num_poi_attracts ) && self.attractor_array.size >= self.num_poi_attracts )
	{
		return 0;
	}
	return 1;
}

update_poi_on_death( zombie_poi )
{
	self endon( "kill_poi" );
	self waittill( "death" );
	self remove_poi_attractor( zombie_poi );
}

update_on_poi_removal( zombie_poi )
{
	zombie_poi waittill( "death" );
	if ( !isDefined( zombie_poi.attractor_array ) )
	{
		return;
	}
	i = 0;
	while ( i < zombie_poi.attractor_array.size )
	{
		if ( zombie_poi.attractor_array[ i ] == self )
		{
			arrayremoveindex( zombie_poi.attractor_array, i );
			arrayremoveindex( zombie_poi.claimed_attractor_positions, i );
		}
		i++;
	}
}

invalidate_attractor_pos( attractor_pos, zombie )
{
	if ( !isDefined( self ) || !isDefined( attractor_pos ) )
	{
		wait 0,1;
		return undefined;
	}
	if ( isDefined( self.attractor_positions ) && !array_check_for_dupes_using_compare( self.attractor_positions, attractor_pos, ::poi_locations_equal ) )
	{
		index = 0;
		i = 0;
		while ( i < self.attractor_positions.size )
		{
			if ( poi_locations_equal( self.attractor_positions[ i ], attractor_pos ) )
			{
				index = i;
			}
			i++;
		}
		i = 0;
		while ( i < self.last_index.size )
		{
			if ( index <= self.last_index[ i ] )
			{
				self.last_index[ i ]--;

			}
			i++;
		}
		arrayremovevalue( self.attractor_array, zombie );
		arrayremovevalue( self.attractor_positions, attractor_pos );
		i = 0;
		while ( i < self.claimed_attractor_positions.size )
		{
			if ( self.claimed_attractor_positions[ i ][ 0 ] == attractor_pos[ 0 ] )
			{
				arrayremovevalue( self.claimed_attractor_positions, self.claimed_attractor_positions[ i ] );
			}
			i++;
		}
	}
	else wait 0,1;
	return get_zombie_point_of_interest( zombie.origin );
}

remove_poi_from_ignore_list( poi )
{
	while ( isDefined( self.ignore_poi ) && self.ignore_poi.size > 0 )
	{
		i = 0;
		while ( i < self.ignore_poi.size )
		{
			if ( self.ignore_poi[ i ] == poi )
			{
				arrayremovevalue( self.ignore_poi, self.ignore_poi[ i ] );
				return;
			}
			i++;
		}
	}
}

add_poi_to_ignore_list( poi )
{
	if ( !isDefined( self.ignore_poi ) )
	{
		self.ignore_poi = [];
	}
	add_poi = 1;
	while ( self.ignore_poi.size > 0 )
	{
		i = 0;
		while ( i < self.ignore_poi.size )
		{
			if ( self.ignore_poi[ i ] == poi )
			{
				add_poi = 0;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	if ( add_poi )
	{
		self.ignore_poi[ self.ignore_poi.size ] = poi;
	}
}

default_validate_enemy_path_length( player )
{
	max_dist = 1296;
	d = distancesquared( self.origin, player.origin );
	if ( d <= max_dist )
	{
		return 1;
	}
	return 0;
}

get_path_length_to_enemy( enemy )
{
	path_length = self calcpathlength( enemy.origin );
	return path_length;
}

get_closest_player_using_paths( origin, players )
{
	min_length_to_player = 9999999;
	n_2d_distance_squared = 9999999;
	player_to_return = undefined;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		length_to_player = get_path_length_to_enemy( player );
		if ( isDefined( level.validate_enemy_path_length ) )
		{
			if ( length_to_player == 0 )
			{
				valid = self thread [[ level.validate_enemy_path_length ]]( player );
				if ( !valid )
				{
					i++;
					continue;
				}
			}
		}
		else if ( length_to_player < min_length_to_player )
		{
			min_length_to_player = length_to_player;
			player_to_return = player;
			n_2d_distance_squared = distance2dsquared( self.origin, player.origin );
			i++;
			continue;
		}
		else
		{
			if ( length_to_player == min_length_to_player && length_to_player <= 5 )
			{
				n_new_distance = distance2dsquared( self.origin, player.origin );
				if ( n_new_distance < n_2d_distance_squared )
				{
					min_length_to_player = length_to_player;
					player_to_return = player;
					n_2d_distance_squared = n_new_distance;
				}
			}
		}
		i++;
	}
	return player_to_return;
}

get_closest_valid_player( origin, ignore_player )
{
	valid_player_found = 0;
	players = get_players();
	if ( isDefined( level._zombie_using_humangun ) && level._zombie_using_humangun )
	{
		players = arraycombine( players, level._zombie_human_array, 0, 0 );
	}
	while ( isDefined( ignore_player ) )
	{
		i = 0;
		while ( i < ignore_player.size )
		{
			arrayremovevalue( players, ignore_player[ i ] );
			i++;
		}
	}
	done = 0;
	while ( players.size && !done )
	{
		done = 1;
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( !is_player_valid( player, 1 ) )
			{
				arrayremovevalue( players, player );
				done = 0;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	if ( players.size == 0 )
	{
		return undefined;
	}
	while ( !valid_player_found )
	{
		if ( isDefined( self.closest_player_override ) )
		{
			player = [[ self.closest_player_override ]]( origin, players );
		}
		else if ( isDefined( level.closest_player_override ) )
		{
			player = [[ level.closest_player_override ]]( origin, players );
		}
		else if ( isDefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
		{
			player = get_closest_player_using_paths( origin, players );
		}
		else
		{
			player = getclosest( origin, players );
		}
		if ( !isDefined( player ) || players.size == 0 )
		{
			return undefined;
		}
		if ( isDefined( level._zombie_using_humangun ) && level._zombie_using_humangun && isai( player ) )
		{
			return player;
		}
		while ( !is_player_valid( player, 1 ) )
		{
			arrayremovevalue( players, player );
			if ( players.size == 0 )
			{
				return undefined;
			}
		}
		return player;
	}
}

is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( isDefined( player.is_zombie ) && player.is_zombie == 1 )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( isDefined( self.intermission ) && self.intermission )
	{
		return 0;
	}
	if ( isDefined( ignore_laststand_players ) && !ignore_laststand_players )
	{
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			return 0;
		}
	}
	if ( isDefined( checkignoremeflag ) && checkignoremeflag && player.ignoreme )
	{
		return 0;
	}
	if ( isDefined( level.is_player_valid_override ) )
	{
		return [[ level.is_player_valid_override ]]( player );
	}
	return 1;
}

get_number_of_valid_players()
{
	players = get_players();
	num_player_valid = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( is_player_valid( players[ i ] ) )
		{
			num_player_valid += 1;
		}
		i++;
	}
	return num_player_valid;
}

in_revive_trigger()
{
	if ( isDefined( self.rt_time ) && ( self.rt_time + 100 ) >= getTime() )
	{
		return self.in_rt_cached;
	}
	self.rt_time = getTime();
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		current_player = players[ i ];
		if ( isDefined( current_player ) && isDefined( current_player.revivetrigger ) && isalive( current_player ) )
		{
			if ( self istouching( current_player.revivetrigger ) )
			{
				self.in_rt_cached = 1;
				return 1;
			}
		}
		i++;
	}
	self.in_rt_cached = 0;
	return 0;
}

get_closest_node( org, nodes )
{
	return getclosest( org, nodes );
}

non_destroyed_bar_board_order( origin, chunks )
{
	first_bars = [];
	first_bars1 = [];
	first_bars2 = [];
	i = 0;
	while ( i < chunks.size )
	{
		if ( isDefined( chunks[ i ].script_team ) && chunks[ i ].script_team == "classic_boards" )
		{
			if ( isDefined( chunks[ i ].script_parameters ) && chunks[ i ].script_parameters == "board" )
			{
				return get_closest_2d( origin, chunks );
			}
			else
			{
				if ( isDefined( chunks[ i ].script_team ) && chunks[ i ].script_team != "bar_board_variant1" && chunks[ i ].script_team != "bar_board_variant2" || chunks[ i ].script_team == "bar_board_variant4" && chunks[ i ].script_team == "bar_board_variant5" )
				{
					return undefined;
				}
			}
		}
		else
		{
			if ( isDefined( chunks[ i ].script_team ) && chunks[ i ].script_team == "new_barricade" )
			{
				if ( isDefined( chunks[ i ].script_parameters ) || chunks[ i ].script_parameters == "repair_board" && chunks[ i ].script_parameters == "barricade_vents" )
				{
					return get_closest_2d( origin, chunks );
				}
			}
		}
		i++;
	}
	i = 0;
	while ( i < chunks.size )
	{
		if ( isDefined( chunks[ i ].script_team ) || chunks[ i ].script_team == "6_bars_bent" && chunks[ i ].script_team == "6_bars_prestine" )
		{
			if ( isDefined( chunks[ i ].script_parameters ) && chunks[ i ].script_parameters == "bar" )
			{
				if ( isDefined( chunks[ i ].script_noteworthy ) )
				{
					if ( chunks[ i ].script_noteworthy == "4" || chunks[ i ].script_noteworthy == "6" )
					{
						first_bars[ first_bars.size ] = chunks[ i ];
					}
				}
			}
		}
		i++;
	}
	i = 0;
	while ( i < first_bars.size )
	{
		if ( isDefined( chunks[ i ].script_team ) || chunks[ i ].script_team == "6_bars_bent" && chunks[ i ].script_team == "6_bars_prestine" )
		{
			if ( isDefined( chunks[ i ].script_parameters ) && chunks[ i ].script_parameters == "bar" )
			{
				if ( !first_bars[ i ].destroyed )
				{
					return first_bars[ i ];
				}
			}
		}
		i++;
	}
	i = 0;
	while ( i < chunks.size )
	{
		if ( isDefined( chunks[ i ].script_team ) || chunks[ i ].script_team == "6_bars_bent" && chunks[ i ].script_team == "6_bars_prestine" )
		{
			if ( isDefined( chunks[ i ].script_parameters ) && chunks[ i ].script_parameters == "bar" )
			{
				if ( !chunks[ i ].destroyed )
				{
					return get_closest_2d( origin, chunks );
				}
			}
		}
		i++;
	}
}

non_destroyed_grate_order( origin, chunks_grate )
{
	grate_order = [];
	grate_order1 = [];
	grate_order2 = [];
	grate_order3 = [];
	grate_order4 = [];
	grate_order5 = [];
	grate_order6 = [];
	while ( isDefined( chunks_grate ) )
	{
		i = 0;
		while ( i < chunks_grate.size )
		{
			if ( isDefined( chunks_grate[ i ].script_parameters ) && chunks_grate[ i ].script_parameters == "grate" )
			{
				if ( isDefined( chunks_grate[ i ].script_noteworthy ) && chunks_grate[ i ].script_noteworthy == "1" )
				{
					grate_order1[ grate_order1.size ] = chunks_grate[ i ];
				}
				if ( isDefined( chunks_grate[ i ].script_noteworthy ) && chunks_grate[ i ].script_noteworthy == "2" )
				{
					grate_order2[ grate_order2.size ] = chunks_grate[ i ];
				}
				if ( isDefined( chunks_grate[ i ].script_noteworthy ) && chunks_grate[ i ].script_noteworthy == "3" )
				{
					grate_order3[ grate_order3.size ] = chunks_grate[ i ];
				}
				if ( isDefined( chunks_grate[ i ].script_noteworthy ) && chunks_grate[ i ].script_noteworthy == "4" )
				{
					grate_order4[ grate_order4.size ] = chunks_grate[ i ];
				}
				if ( isDefined( chunks_grate[ i ].script_noteworthy ) && chunks_grate[ i ].script_noteworthy == "5" )
				{
					grate_order5[ grate_order5.size ] = chunks_grate[ i ];
				}
				if ( isDefined( chunks_grate[ i ].script_noteworthy ) && chunks_grate[ i ].script_noteworthy == "6" )
				{
					grate_order6[ grate_order6.size ] = chunks_grate[ i ];
				}
			}
			i++;
		}
		i = 0;
		while ( i < chunks_grate.size )
		{
			if ( isDefined( chunks_grate[ i ].script_parameters ) && chunks_grate[ i ].script_parameters == "grate" )
			{
				if ( isDefined( grate_order1[ i ] ) )
				{
					if ( grate_order1[ i ].state == "repaired" )
					{
						grate_order2[ i ] thread show_grate_pull();
						return grate_order1[ i ];
					}
					if ( grate_order2[ i ].state == "repaired" )
					{
/#
						iprintlnbold( " pull bar2 " );
#/
						grate_order3[ i ] thread show_grate_pull();
						return grate_order2[ i ];
					}
					else
					{
						if ( grate_order3[ i ].state == "repaired" )
						{
/#
							iprintlnbold( " pull bar3 " );
#/
							grate_order4[ i ] thread show_grate_pull();
							return grate_order3[ i ];
						}
						else
						{
							if ( grate_order4[ i ].state == "repaired" )
							{
/#
								iprintlnbold( " pull bar4 " );
#/
								grate_order5[ i ] thread show_grate_pull();
								return grate_order4[ i ];
							}
							else
							{
								if ( grate_order5[ i ].state == "repaired" )
								{
/#
									iprintlnbold( " pull bar5 " );
#/
									grate_order6[ i ] thread show_grate_pull();
									return grate_order5[ i ];
								}
								else
								{
									if ( grate_order6[ i ].state == "repaired" )
									{
										return grate_order6[ i ];
									}
								}
							}
						}
					}
				}
			}
			i++;
		}
	}
}

non_destroyed_variant1_order( origin, chunks_variant1 )
{
	variant1_order = [];
	variant1_order1 = [];
	variant1_order2 = [];
	variant1_order3 = [];
	variant1_order4 = [];
	variant1_order5 = [];
	variant1_order6 = [];
	while ( isDefined( chunks_variant1 ) )
	{
		i = 0;
		while ( i < chunks_variant1.size )
		{
			if ( isDefined( chunks_variant1[ i ].script_team ) && chunks_variant1[ i ].script_team == "bar_board_variant1" )
			{
				if ( isDefined( chunks_variant1[ i ].script_noteworthy ) )
				{
					if ( chunks_variant1[ i ].script_noteworthy == "1" )
					{
						variant1_order1[ variant1_order1.size ] = chunks_variant1[ i ];
					}
					if ( chunks_variant1[ i ].script_noteworthy == "2" )
					{
						variant1_order2[ variant1_order2.size ] = chunks_variant1[ i ];
					}
					if ( chunks_variant1[ i ].script_noteworthy == "3" )
					{
						variant1_order3[ variant1_order3.size ] = chunks_variant1[ i ];
					}
					if ( chunks_variant1[ i ].script_noteworthy == "4" )
					{
						variant1_order4[ variant1_order4.size ] = chunks_variant1[ i ];
					}
					if ( chunks_variant1[ i ].script_noteworthy == "5" )
					{
						variant1_order5[ variant1_order5.size ] = chunks_variant1[ i ];
					}
					if ( chunks_variant1[ i ].script_noteworthy == "6" )
					{
						variant1_order6[ variant1_order6.size ] = chunks_variant1[ i ];
					}
				}
			}
			i++;
		}
		i = 0;
		while ( i < chunks_variant1.size )
		{
			if ( isDefined( chunks_variant1[ i ].script_team ) && chunks_variant1[ i ].script_team == "bar_board_variant1" )
			{
				if ( isDefined( variant1_order2[ i ] ) )
				{
					if ( variant1_order2[ i ].state == "repaired" )
					{
						return variant1_order2[ i ];
					}
					else
					{
						if ( variant1_order3[ i ].state == "repaired" )
						{
							return variant1_order3[ i ];
						}
						else
						{
							if ( variant1_order4[ i ].state == "repaired" )
							{
								return variant1_order4[ i ];
							}
							else
							{
								if ( variant1_order6[ i ].state == "repaired" )
								{
									return variant1_order6[ i ];
								}
								else
								{
									if ( variant1_order5[ i ].state == "repaired" )
									{
										return variant1_order5[ i ];
									}
									else
									{
										if ( variant1_order1[ i ].state == "repaired" )
										{
											return variant1_order1[ i ];
										}
									}
								}
							}
						}
					}
				}
			}
			i++;
		}
	}
}

non_destroyed_variant2_order( origin, chunks_variant2 )
{
	variant2_order = [];
	variant2_order1 = [];
	variant2_order2 = [];
	variant2_order3 = [];
	variant2_order4 = [];
	variant2_order5 = [];
	variant2_order6 = [];
	while ( isDefined( chunks_variant2 ) )
	{
		i = 0;
		while ( i < chunks_variant2.size )
		{
			if ( isDefined( chunks_variant2[ i ].script_team ) && chunks_variant2[ i ].script_team == "bar_board_variant2" )
			{
				if ( isDefined( chunks_variant2[ i ].script_noteworthy ) && chunks_variant2[ i ].script_noteworthy == "1" )
				{
					variant2_order1[ variant2_order1.size ] = chunks_variant2[ i ];
				}
				if ( isDefined( chunks_variant2[ i ].script_noteworthy ) && chunks_variant2[ i ].script_noteworthy == "2" )
				{
					variant2_order2[ variant2_order2.size ] = chunks_variant2[ i ];
				}
				if ( isDefined( chunks_variant2[ i ].script_noteworthy ) && chunks_variant2[ i ].script_noteworthy == "3" )
				{
					variant2_order3[ variant2_order3.size ] = chunks_variant2[ i ];
				}
				if ( isDefined( chunks_variant2[ i ].script_noteworthy ) && chunks_variant2[ i ].script_noteworthy == "4" )
				{
					variant2_order4[ variant2_order4.size ] = chunks_variant2[ i ];
				}
				if ( isDefined( chunks_variant2[ i ].script_noteworthy ) && chunks_variant2[ i ].script_noteworthy == "5" && isDefined( chunks_variant2[ i ].script_location ) && chunks_variant2[ i ].script_location == "5" )
				{
					variant2_order5[ variant2_order5.size ] = chunks_variant2[ i ];
				}
				if ( isDefined( chunks_variant2[ i ].script_noteworthy ) && chunks_variant2[ i ].script_noteworthy == "5" && isDefined( chunks_variant2[ i ].script_location ) && chunks_variant2[ i ].script_location == "6" )
				{
					variant2_order6[ variant2_order6.size ] = chunks_variant2[ i ];
				}
			}
			i++;
		}
		i = 0;
		while ( i < chunks_variant2.size )
		{
			if ( isDefined( chunks_variant2[ i ].script_team ) && chunks_variant2[ i ].script_team == "bar_board_variant2" )
			{
				if ( isDefined( variant2_order1[ i ] ) )
				{
					if ( variant2_order1[ i ].state == "repaired" )
					{
						return variant2_order1[ i ];
					}
					else
					{
						if ( variant2_order2[ i ].state == "repaired" )
						{
							return variant2_order2[ i ];
						}
						else
						{
							if ( variant2_order3[ i ].state == "repaired" )
							{
								return variant2_order3[ i ];
							}
							else
							{
								if ( variant2_order5[ i ].state == "repaired" )
								{
									return variant2_order5[ i ];
								}
								else
								{
									if ( variant2_order4[ i ].state == "repaired" )
									{
										return variant2_order4[ i ];
									}
									else
									{
										if ( variant2_order6[ i ].state == "repaired" )
										{
											return variant2_order6[ i ];
										}
									}
								}
							}
						}
					}
				}
			}
			i++;
		}
	}
}

non_destroyed_variant4_order( origin, chunks_variant4 )
{
	variant4_order = [];
	variant4_order1 = [];
	variant4_order2 = [];
	variant4_order3 = [];
	variant4_order4 = [];
	variant4_order5 = [];
	variant4_order6 = [];
	while ( isDefined( chunks_variant4 ) )
	{
		i = 0;
		while ( i < chunks_variant4.size )
		{
			if ( isDefined( chunks_variant4[ i ].script_team ) && chunks_variant4[ i ].script_team == "bar_board_variant4" )
			{
				if ( isDefined( chunks_variant4[ i ].script_noteworthy ) && chunks_variant4[ i ].script_noteworthy == "1" && !isDefined( chunks_variant4[ i ].script_location ) )
				{
					variant4_order1[ variant4_order1.size ] = chunks_variant4[ i ];
				}
				if ( isDefined( chunks_variant4[ i ].script_noteworthy ) && chunks_variant4[ i ].script_noteworthy == "2" )
				{
					variant4_order2[ variant4_order2.size ] = chunks_variant4[ i ];
				}
				if ( isDefined( chunks_variant4[ i ].script_noteworthy ) && chunks_variant4[ i ].script_noteworthy == "3" )
				{
					variant4_order3[ variant4_order3.size ] = chunks_variant4[ i ];
				}
				if ( isDefined( chunks_variant4[ i ].script_noteworthy ) && chunks_variant4[ i ].script_noteworthy == "1" && isDefined( chunks_variant4[ i ].script_location ) && chunks_variant4[ i ].script_location == "3" )
				{
					variant4_order4[ variant4_order4.size ] = chunks_variant4[ i ];
				}
				if ( isDefined( chunks_variant4[ i ].script_noteworthy ) && chunks_variant4[ i ].script_noteworthy == "5" )
				{
					variant4_order5[ variant4_order5.size ] = chunks_variant4[ i ];
				}
				if ( isDefined( chunks_variant4[ i ].script_noteworthy ) && chunks_variant4[ i ].script_noteworthy == "6" )
				{
					variant4_order6[ variant4_order6.size ] = chunks_variant4[ i ];
				}
			}
			i++;
		}
		i = 0;
		while ( i < chunks_variant4.size )
		{
			if ( isDefined( chunks_variant4[ i ].script_team ) && chunks_variant4[ i ].script_team == "bar_board_variant4" )
			{
				if ( isDefined( variant4_order1[ i ] ) )
				{
					if ( variant4_order1[ i ].state == "repaired" )
					{
						return variant4_order1[ i ];
					}
					else
					{
						if ( variant4_order6[ i ].state == "repaired" )
						{
							return variant4_order6[ i ];
						}
						else
						{
							if ( variant4_order3[ i ].state == "repaired" )
							{
								return variant4_order3[ i ];
							}
							else
							{
								if ( variant4_order4[ i ].state == "repaired" )
								{
									return variant4_order4[ i ];
								}
								else
								{
									if ( variant4_order2[ i ].state == "repaired" )
									{
										return variant4_order2[ i ];
									}
									else
									{
										if ( variant4_order5[ i ].state == "repaired" )
										{
											return variant4_order5[ i ];
										}
									}
								}
							}
						}
					}
				}
			}
			i++;
		}
	}
}

non_destroyed_variant5_order( origin, chunks_variant5 )
{
	variant5_order = [];
	variant5_order1 = [];
	variant5_order2 = [];
	variant5_order3 = [];
	variant5_order4 = [];
	variant5_order5 = [];
	variant5_order6 = [];
	while ( isDefined( chunks_variant5 ) )
	{
		i = 0;
		while ( i < chunks_variant5.size )
		{
			if ( isDefined( chunks_variant5[ i ].script_team ) && chunks_variant5[ i ].script_team == "bar_board_variant5" )
			{
				if ( isDefined( chunks_variant5[ i ].script_noteworthy ) )
				{
					if ( chunks_variant5[ i ].script_noteworthy == "1" && !isDefined( chunks_variant5[ i ].script_location ) )
					{
						variant5_order1[ variant5_order1.size ] = chunks_variant5[ i ];
					}
					if ( chunks_variant5[ i ].script_noteworthy == "2" )
					{
						variant5_order2[ variant5_order2.size ] = chunks_variant5[ i ];
					}
					if ( isDefined( chunks_variant5[ i ].script_noteworthy ) && chunks_variant5[ i ].script_noteworthy == "1" && isDefined( chunks_variant5[ i ].script_location ) && chunks_variant5[ i ].script_location == "3" )
					{
						variant5_order3[ variant5_order3.size ] = chunks_variant5[ i ];
					}
					if ( chunks_variant5[ i ].script_noteworthy == "4" )
					{
						variant5_order4[ variant5_order4.size ] = chunks_variant5[ i ];
					}
					if ( chunks_variant5[ i ].script_noteworthy == "5" )
					{
						variant5_order5[ variant5_order5.size ] = chunks_variant5[ i ];
					}
					if ( chunks_variant5[ i ].script_noteworthy == "6" )
					{
						variant5_order6[ variant5_order6.size ] = chunks_variant5[ i ];
					}
				}
			}
			i++;
		}
		i = 0;
		while ( i < chunks_variant5.size )
		{
			if ( isDefined( chunks_variant5[ i ].script_team ) && chunks_variant5[ i ].script_team == "bar_board_variant5" )
			{
				if ( isDefined( variant5_order1[ i ] ) )
				{
					if ( variant5_order1[ i ].state == "repaired" )
					{
						return variant5_order1[ i ];
					}
					else
					{
						if ( variant5_order6[ i ].state == "repaired" )
						{
							return variant5_order6[ i ];
						}
						else
						{
							if ( variant5_order3[ i ].state == "repaired" )
							{
								return variant5_order3[ i ];
							}
							else
							{
								if ( variant5_order2[ i ].state == "repaired" )
								{
									return variant5_order2[ i ];
								}
								else
								{
									if ( variant5_order5[ i ].state == "repaired" )
									{
										return variant5_order5[ i ];
									}
									else
									{
										if ( variant5_order4[ i ].state == "repaired" )
										{
											return variant5_order4[ i ];
										}
									}
								}
							}
						}
					}
				}
			}
			i++;
		}
	}
}

show_grate_pull()
{
	wait 0,53;
	self show();
	self vibrate( vectorScale( ( 0, 0, 1 ), 270 ), 0,2, 0,4, 0,4 );
}

get_closest_2d( origin, ents )
{
	if ( !isDefined( ents ) )
	{
		return undefined;
	}
	dist = distance2d( origin, ents[ 0 ].origin );
	index = 0;
	temp_array = [];
	i = 1;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].unbroken ) && ents[ i ].unbroken == 1 )
		{
			ents[ i ].index = i;
			temp_array[ temp_array.size ] = ents[ i ];
		}
		i++;
	}
	if ( temp_array.size > 0 )
	{
		index = temp_array[ randomintrange( 0, temp_array.size ) ].index;
		return ents[ index ];
	}
	else
	{
		i = 1;
		while ( i < ents.size )
		{
			temp_dist = distance2d( origin, ents[ i ].origin );
			if ( temp_dist < dist )
			{
				dist = temp_dist;
				index = i;
			}
			i++;
		}
		return ents[ index ];
	}
}

disable_trigger()
{
	if ( !isDefined( self.disabled ) || !self.disabled )
	{
		self.disabled = 1;
		self.origin -= vectorScale( ( 0, 0, 1 ), 10000 );
	}
}

enable_trigger()
{
	if ( !isDefined( self.disabled ) || !self.disabled )
	{
		return;
	}
	self.disabled = 0;
	self.origin += vectorScale( ( 0, 0, 1 ), 10000 );
}

in_playable_area()
{
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	if ( !isDefined( playable_area ) )
	{
/#
		println( "No playable area playable_area found! Assume EVERYWHERE is PLAYABLE" );
#/
		return 1;
	}
	i = 0;
	while ( i < playable_area.size )
	{
		if ( self istouching( playable_area[ i ] ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

get_closest_non_destroyed_chunk( origin, barrier, barrier_chunks )
{
	chunks = undefined;
	chunks_grate = undefined;
	chunks_grate = get_non_destroyed_chunks_grate( barrier, barrier_chunks );
	chunks = get_non_destroyed_chunks( barrier, barrier_chunks );
	if ( isDefined( barrier.zbarrier ) )
	{
		if ( isDefined( chunks ) )
		{
			return array_randomize( chunks )[ 0 ];
		}
		if ( isDefined( chunks_grate ) )
		{
			return array_randomize( chunks_grate )[ 0 ];
		}
	}
	else
	{
		if ( isDefined( chunks ) )
		{
			return non_destroyed_bar_board_order( origin, chunks );
		}
		else
		{
			if ( isDefined( chunks_grate ) )
			{
				return non_destroyed_grate_order( origin, chunks_grate );
			}
		}
	}
	return undefined;
}

get_random_destroyed_chunk( barrier, barrier_chunks )
{
	if ( isDefined( barrier.zbarrier ) )
	{
		ret = undefined;
		pieces = barrier.zbarrier getzbarrierpieceindicesinstate( "open" );
		if ( pieces.size )
		{
			ret = array_randomize( pieces )[ 0 ];
		}
		return ret;
	}
	else
	{
		chunk = undefined;
		chunks_repair_grate = undefined;
		chunks = get_destroyed_chunks( barrier_chunks );
		chunks_repair_grate = get_destroyed_repair_grates( barrier_chunks );
		if ( isDefined( chunks ) )
		{
			return chunks[ randomint( chunks.size ) ];
		}
		else
		{
			if ( isDefined( chunks_repair_grate ) )
			{
				return grate_order_destroyed( chunks_repair_grate );
			}
		}
		return undefined;
	}
}

get_destroyed_repair_grates( barrier_chunks )
{
	array = [];
	i = 0;
	while ( i < barrier_chunks.size )
	{
		if ( isDefined( barrier_chunks[ i ] ) )
		{
			if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "grate" )
			{
				array[ array.size ] = barrier_chunks[ i ];
			}
		}
		i++;
	}
	if ( array.size == 0 )
	{
		return undefined;
	}
	return array;
}

get_non_destroyed_chunks( barrier, barrier_chunks )
{
	if ( isDefined( barrier.zbarrier ) )
	{
		return barrier.zbarrier getzbarrierpieceindicesinstate( "closed" );
	}
	else
	{
		array = [];
		i = 0;
		while ( i < barrier_chunks.size )
		{
			if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "classic_boards" )
			{
				if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "board" )
				{
					if ( barrier_chunks[ i ] get_chunk_state() == "repaired" )
					{
						if ( barrier_chunks[ i ].origin == barrier_chunks[ i ].og_origin )
						{
							array[ array.size ] = barrier_chunks[ i ];
						}
					}
				}
			}
			if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "new_barricade" )
			{
				if ( isDefined( barrier_chunks[ i ].script_parameters ) || barrier_chunks[ i ].script_parameters == "repair_board" && barrier_chunks[ i ].script_parameters == "barricade_vents" )
				{
					if ( barrier_chunks[ i ] get_chunk_state() == "repaired" )
					{
						if ( barrier_chunks[ i ].origin == barrier_chunks[ i ].og_origin )
						{
							array[ array.size ] = barrier_chunks[ i ];
						}
					}
				}
				i++;
				continue;
			}
			else
			{
				if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "6_bars_bent" )
				{
					if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "bar" )
					{
						if ( barrier_chunks[ i ] get_chunk_state() == "repaired" )
						{
							if ( barrier_chunks[ i ].origin == barrier_chunks[ i ].og_origin )
							{
								array[ array.size ] = barrier_chunks[ i ];
							}
						}
					}
					i++;
					continue;
				}
				else
				{
					if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "6_bars_prestine" )
					{
						if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "bar" )
						{
							if ( barrier_chunks[ i ] get_chunk_state() == "repaired" )
							{
								if ( barrier_chunks[ i ].origin == barrier_chunks[ i ].og_origin )
								{
									array[ array.size ] = barrier_chunks[ i ];
								}
							}
						}
					}
				}
			}
			i++;
		}
		if ( array.size == 0 )
		{
			return undefined;
		}
		return array;
	}
}

get_non_destroyed_chunks_grate( barrier, barrier_chunks )
{
	if ( isDefined( barrier.zbarrier ) )
	{
		return barrier.zbarrier getzbarrierpieceindicesinstate( "closed" );
	}
	else
	{
		array = [];
		i = 0;
		while ( i < barrier_chunks.size )
		{
			if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "grate" )
			{
				if ( isDefined( barrier_chunks[ i ] ) )
				{
					array[ array.size ] = barrier_chunks[ i ];
				}
			}
			i++;
		}
		if ( array.size == 0 )
		{
			return undefined;
		}
		return array;
	}
}

get_non_destroyed_variant1( barrier_chunks )
{
	array = [];
	i = 0;
	while ( i < barrier_chunks.size )
	{
		if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "bar_board_variant1" )
		{
			if ( isDefined( barrier_chunks[ i ] ) )
			{
				array[ array.size ] = barrier_chunks[ i ];
			}
		}
		i++;
	}
	if ( array.size == 0 )
	{
		return undefined;
	}
	return array;
}

get_non_destroyed_variant2( barrier_chunks )
{
	array = [];
	i = 0;
	while ( i < barrier_chunks.size )
	{
		if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "bar_board_variant2" )
		{
			if ( isDefined( barrier_chunks[ i ] ) )
			{
				array[ array.size ] = barrier_chunks[ i ];
			}
		}
		i++;
	}
	if ( array.size == 0 )
	{
		return undefined;
	}
	return array;
}

get_non_destroyed_variant4( barrier_chunks )
{
	array = [];
	i = 0;
	while ( i < barrier_chunks.size )
	{
		if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "bar_board_variant4" )
		{
			if ( isDefined( barrier_chunks[ i ] ) )
			{
				array[ array.size ] = barrier_chunks[ i ];
			}
		}
		i++;
	}
	if ( array.size == 0 )
	{
		return undefined;
	}
	return array;
}

get_non_destroyed_variant5( barrier_chunks )
{
	array = [];
	i = 0;
	while ( i < barrier_chunks.size )
	{
		if ( isDefined( barrier_chunks[ i ].script_team ) && barrier_chunks[ i ].script_team == "bar_board_variant5" )
		{
			if ( isDefined( barrier_chunks[ i ] ) )
			{
				array[ array.size ] = barrier_chunks[ i ];
			}
		}
		i++;
	}
	if ( array.size == 0 )
	{
		return undefined;
	}
	return array;
}

get_destroyed_chunks( barrier_chunks )
{
	array = [];
	i = 0;
	while ( i < barrier_chunks.size )
	{
		if ( barrier_chunks[ i ] get_chunk_state() == "destroyed" )
		{
			if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "board" )
			{
				array[ array.size ] = barrier_chunks[ i ];
				i++;
				continue;
			}
			else
			{
				if ( isDefined( barrier_chunks[ i ].script_parameters ) || barrier_chunks[ i ].script_parameters == "repair_board" && barrier_chunks[ i ].script_parameters == "barricade_vents" )
				{
					array[ array.size ] = barrier_chunks[ i ];
					i++;
					continue;
				}
				else
				{
					if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "bar" )
					{
						array[ array.size ] = barrier_chunks[ i ];
						i++;
						continue;
					}
					else
					{
						if ( isDefined( barrier_chunks[ i ].script_parameters ) && barrier_chunks[ i ].script_parameters == "grate" )
						{
							return undefined;
						}
					}
				}
			}
		}
		i++;
	}
	if ( array.size == 0 )
	{
		return undefined;
	}
	return array;
}

grate_order_destroyed( chunks_repair_grate )
{
	grate_repair_order = [];
	grate_repair_order1 = [];
	grate_repair_order2 = [];
	grate_repair_order3 = [];
	grate_repair_order4 = [];
	grate_repair_order5 = [];
	grate_repair_order6 = [];
	i = 0;
	while ( i < chunks_repair_grate.size )
	{
		if ( isDefined( chunks_repair_grate[ i ].script_parameters ) && chunks_repair_grate[ i ].script_parameters == "grate" )
		{
			if ( isDefined( chunks_repair_grate[ i ].script_noteworthy ) && chunks_repair_grate[ i ].script_noteworthy == "1" )
			{
				grate_repair_order1[ grate_repair_order1.size ] = chunks_repair_grate[ i ];
			}
			if ( isDefined( chunks_repair_grate[ i ].script_noteworthy ) && chunks_repair_grate[ i ].script_noteworthy == "2" )
			{
				grate_repair_order2[ grate_repair_order2.size ] = chunks_repair_grate[ i ];
			}
			if ( isDefined( chunks_repair_grate[ i ].script_noteworthy ) && chunks_repair_grate[ i ].script_noteworthy == "3" )
			{
				grate_repair_order3[ grate_repair_order3.size ] = chunks_repair_grate[ i ];
			}
			if ( isDefined( chunks_repair_grate[ i ].script_noteworthy ) && chunks_repair_grate[ i ].script_noteworthy == "4" )
			{
				grate_repair_order4[ grate_repair_order4.size ] = chunks_repair_grate[ i ];
			}
			if ( isDefined( chunks_repair_grate[ i ].script_noteworthy ) && chunks_repair_grate[ i ].script_noteworthy == "5" )
			{
				grate_repair_order5[ grate_repair_order5.size ] = chunks_repair_grate[ i ];
			}
			if ( isDefined( chunks_repair_grate[ i ].script_noteworthy ) && chunks_repair_grate[ i ].script_noteworthy == "6" )
			{
				grate_repair_order6[ grate_repair_order6.size ] = chunks_repair_grate[ i ];
			}
		}
		i++;
	}
	i = 0;
	while ( i < chunks_repair_grate.size )
	{
		if ( isDefined( chunks_repair_grate[ i ].script_parameters ) && chunks_repair_grate[ i ].script_parameters == "grate" )
		{
			if ( isDefined( grate_repair_order1[ i ] ) )
			{
				if ( grate_repair_order6[ i ].state == "destroyed" )
				{
/#
					iprintlnbold( " Fix grate6 " );
#/
					return grate_repair_order6[ i ];
				}
				if ( grate_repair_order5[ i ].state == "destroyed" )
				{
/#
					iprintlnbold( " Fix grate5 " );
#/
					grate_repair_order6[ i ] thread show_grate_repair();
					return grate_repair_order5[ i ];
				}
				else
				{
					if ( grate_repair_order4[ i ].state == "destroyed" )
					{
/#
						iprintlnbold( " Fix grate4 " );
#/
						grate_repair_order5[ i ] thread show_grate_repair();
						return grate_repair_order4[ i ];
					}
					else
					{
						if ( grate_repair_order3[ i ].state == "destroyed" )
						{
/#
							iprintlnbold( " Fix grate3 " );
#/
							grate_repair_order4[ i ] thread show_grate_repair();
							return grate_repair_order3[ i ];
						}
						else
						{
							if ( grate_repair_order2[ i ].state == "destroyed" )
							{
/#
								iprintlnbold( " Fix grate2 " );
#/
								grate_repair_order3[ i ] thread show_grate_repair();
								return grate_repair_order2[ i ];
							}
							else
							{
								if ( grate_repair_order1[ i ].state == "destroyed" )
								{
/#
									iprintlnbold( " Fix grate1 " );
#/
									grate_repair_order2[ i ] thread show_grate_repair();
									return grate_repair_order1[ i ];
								}
							}
						}
					}
				}
			}
		}
		i++;
	}
}

show_grate_repair()
{
	wait 0,34;
	self hide();
}

get_chunk_state()
{
/#
	assert( isDefined( self.state ) );
#/
	return self.state;
}

is_float( num )
{
	val = num - int( num );
	if ( val != 0 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

array_limiter( array, total )
{
	new_array = [];
	i = 0;
	while ( i < array.size )
	{
		if ( i < total )
		{
			new_array[ new_array.size ] = array[ i ];
		}
		i++;
	}
	return new_array;
}

array_validate( array )
{
	if ( isDefined( array ) && array.size > 0 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

add_spawner( spawner )
{
	if ( isDefined( spawner.script_start ) && level.round_number < spawner.script_start )
	{
		return;
	}
	if ( isDefined( spawner.is_enabled ) && !spawner.is_enabled )
	{
		return;
	}
	if ( isDefined( spawner.has_been_added ) && spawner.has_been_added )
	{
		return;
	}
	spawner.has_been_added = 1;
	level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = spawner;
}

fake_physicslaunch( target_pos, power )
{
	start_pos = self.origin;
	gravity = getDvarInt( "bg_gravity" ) * -1;
	dist = distance( start_pos, target_pos );
	time = dist / power;
	delta = target_pos - start_pos;
	drop = ( 0,5 * gravity ) * ( time * time );
	velocity = ( delta[ 0 ] / time, delta[ 1 ] / time, ( delta[ 2 ] - drop ) / time );
	level thread draw_line_ent_to_pos( self, target_pos );
	self movegravity( velocity, time );
	return time;
}

add_zombie_hint( ref, text )
{
	if ( !isDefined( level.zombie_hints ) )
	{
		level.zombie_hints = [];
	}
	precachestring( text );
	level.zombie_hints[ ref ] = text;
}

get_zombie_hint( ref )
{
	if ( isDefined( level.zombie_hints[ ref ] ) )
	{
		return level.zombie_hints[ ref ];
	}
/#
	println( "UNABLE TO FIND HINT STRING " + ref );
#/
	return level.zombie_hints[ "undefined" ];
}

set_hint_string( ent, default_ref, cost )
{
	ref = default_ref;
	if ( isDefined( ent.script_hint ) )
	{
		ref = ent.script_hint;
	}
	if ( isDefined( level.legacy_hint_system ) && level.legacy_hint_system )
	{
		ref = ( ref + "_" ) + cost;
		self sethintstring( get_zombie_hint( ref ) );
	}
	else
	{
		hint = get_zombie_hint( ref );
		if ( isDefined( cost ) )
		{
			self sethintstring( hint, cost );
			return;
		}
		else
		{
			self sethintstring( hint );
		}
	}
}

get_hint_string( ent, default_ref, cost )
{
	ref = default_ref;
	if ( isDefined( ent.script_hint ) )
	{
		ref = ent.script_hint;
	}
	if ( isDefined( level.legacy_hint_system ) && level.legacy_hint_system && isDefined( cost ) )
	{
		ref = ( ref + "_" ) + cost;
	}
	return get_zombie_hint( ref );
}

unitrigger_set_hint_string( ent, default_ref, cost )
{
	triggers = [];
	if ( self.trigger_per_player )
	{
		triggers = self.playertrigger;
	}
	else
	{
		triggers[ 0 ] = self.trigger;
	}
	_a3000 = triggers;
	_k3000 = getFirstArrayKey( _a3000 );
	while ( isDefined( _k3000 ) )
	{
		trigger = _a3000[ _k3000 ];
		ref = default_ref;
		if ( isDefined( ent.script_hint ) )
		{
			ref = ent.script_hint;
		}
		if ( isDefined( level.legacy_hint_system ) && level.legacy_hint_system )
		{
			ref = ( ref + "_" ) + cost;
			trigger sethintstring( get_zombie_hint( ref ) );
		}
		else
		{
			hint = get_zombie_hint( ref );
			if ( isDefined( cost ) )
			{
				trigger sethintstring( hint, cost );
				break;
			}
			else
			{
				trigger sethintstring( hint );
			}
		}
		_k3000 = getNextArrayKey( _a3000, _k3000 );
	}
}

add_sound( ref, alias )
{
	if ( !isDefined( level.zombie_sounds ) )
	{
		level.zombie_sounds = [];
	}
	level.zombie_sounds[ ref ] = alias;
}

play_sound_at_pos( ref, pos, ent )
{
	if ( isDefined( ent ) )
	{
		if ( isDefined( ent.script_soundalias ) )
		{
			playsoundatposition( ent.script_soundalias, pos );
			return;
		}
		if ( isDefined( self.script_sound ) )
		{
			ref = self.script_sound;
		}
	}
	if ( ref == "none" )
	{
		return;
	}
	if ( !isDefined( level.zombie_sounds[ ref ] ) )
	{
/#
		assertmsg( "Sound "" + ref + "" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." );
#/
		return;
	}
	playsoundatposition( level.zombie_sounds[ ref ], pos );
}

play_sound_on_ent( ref )
{
	if ( isDefined( self.script_soundalias ) )
	{
		self playsound( self.script_soundalias );
		return;
	}
	if ( isDefined( self.script_sound ) )
	{
		ref = self.script_sound;
	}
	if ( ref == "none" )
	{
		return;
	}
	if ( !isDefined( level.zombie_sounds[ ref ] ) )
	{
/#
		assertmsg( "Sound "" + ref + "" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." );
#/
		return;
	}
	self playsound( level.zombie_sounds[ ref ] );
}

play_loopsound_on_ent( ref )
{
	if ( isDefined( self.script_firefxsound ) )
	{
		ref = self.script_firefxsound;
	}
	if ( ref == "none" )
	{
		return;
	}
	if ( !isDefined( level.zombie_sounds[ ref ] ) )
	{
/#
		assertmsg( "Sound "" + ref + "" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." );
#/
		return;
	}
	self playsound( level.zombie_sounds[ ref ] );
}

string_to_float( string )
{
	floatparts = strtok( string, "." );
	if ( floatparts.size == 1 )
	{
		return int( floatparts[ 0 ] );
	}
	whole = int( floatparts[ 0 ] );
	decimal = 0;
	i = floatparts[ 1 ].size - 1;
	while ( i >= 0 )
	{
		decimal = ( decimal / 10 ) + ( int( floatparts[ 1 ][ i ] ) / 10 );
		i--;

	}
	if ( whole >= 0 )
	{
		return whole + decimal;
	}
	else
	{
		return whole - decimal;
	}
}

onplayerconnect_callback( func )
{
	addcallback( "on_player_connect", func );
}

onplayerdisconnect_callback( func )
{
	addcallback( "on_player_disconnect", func );
}

set_zombie_var( var, value, is_float, column, is_team_based )
{
	if ( !isDefined( is_float ) )
	{
		is_float = 0;
	}
	if ( !isDefined( column ) )
	{
		column = 1;
	}
	table = "mp/zombiemode.csv";
	table_value = tablelookup( table, 0, var, column );
	if ( isDefined( table_value ) && table_value != "" )
	{
		if ( is_float )
		{
			value = float( table_value );
		}
		else
		{
			value = int( table_value );
		}
	}
	if ( isDefined( is_team_based ) && is_team_based )
	{
		_a3185 = level.teams;
		_k3185 = getFirstArrayKey( _a3185 );
		while ( isDefined( _k3185 ) )
		{
			team = _a3185[ _k3185 ];
			level.zombie_vars[ team ][ var ] = value;
			_k3185 = getNextArrayKey( _a3185, _k3185 );
		}
	}
	else level.zombie_vars[ var ] = value;
	return value;
}

get_table_var( table, var_name, value, is_float, column )
{
	if ( !isDefined( table ) )
	{
		table = "mp/zombiemode.csv";
	}
	if ( !isDefined( is_float ) )
	{
		is_float = 0;
	}
	if ( !isDefined( column ) )
	{
		column = 1;
	}
	table_value = tablelookup( table, 0, var_name, column );
	if ( isDefined( table_value ) && table_value != "" )
	{
		if ( is_float )
		{
			value = string_to_float( table_value );
		}
		else
		{
			value = int( table_value );
		}
	}
	return value;
}

hudelem_count()
{
/#
	max = 0;
	curr_total = 0;
	while ( 1 )
	{
		if ( level.hudelem_count > max )
		{
			max = level.hudelem_count;
		}
		println( "HudElems: " + level.hudelem_count + "[Peak: " + max + "]" );
		wait 0,05;
#/
	}
}

debug_round_advancer()
{
/#
	while ( 1 )
	{
		zombs = get_round_enemy_array();
		i = 0;
		while ( i < zombs.size )
		{
			zombs[ i ] dodamage( zombs[ i ].health + 666, ( 0, 0, 1 ) );
			wait 0,5;
			i++;
		}
#/
	}
}

print_run_speed( speed )
{
/#
	self endon( "death" );
	while ( 1 )
	{
		print3d( self.origin + vectorScale( ( 0, 0, 1 ), 64 ), speed, ( 0, 0, 1 ) );
		wait 0,05;
#/
	}
}

draw_line_ent_to_ent( ent1, ent2 )
{
/#
	if ( getDvarInt( "zombie_debug" ) != 1 )
	{
		return;
	}
	ent1 endon( "death" );
	ent2 endon( "death" );
	while ( 1 )
	{
		line( ent1.origin, ent2.origin );
		wait 0,05;
#/
	}
}

draw_line_ent_to_pos( ent, pos, end_on )
{
/#
	if ( getDvarInt( "zombie_debug" ) != 1 )
	{
		return;
	}
	ent endon( "death" );
	ent notify( "stop_draw_line_ent_to_pos" );
	ent endon( "stop_draw_line_ent_to_pos" );
	if ( isDefined( end_on ) )
	{
		ent endon( end_on );
	}
	while ( 1 )
	{
		line( ent.origin, pos );
		wait 0,05;
#/
	}
}

debug_print( msg )
{
/#
	if ( getDvarInt( "zombie_debug" ) > 0 )
	{
		println( "######### ZOMBIE: " + msg );
#/
	}
}

debug_blocker( pos, rad, height )
{
/#
	self notify( "stop_debug_blocker" );
	self endon( "stop_debug_blocker" );
	for ( ;; )
	{
		if ( getDvarInt( "zombie_debug" ) != 1 )
		{
			return;
		}
		wait 0,05;
		drawcylinder( pos, rad, height );
#/
	}
}

drawcylinder( pos, rad, height )
{
/#
	currad = rad;
	curheight = height;
	r = 0;
	while ( r < 20 )
	{
		theta = ( r / 20 ) * 360;
		theta2 = ( ( r + 1 ) / 20 ) * 360;
		line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
		line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
		line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
		r++;
#/
	}
}

print3d_at_pos( msg, pos, thread_endon, offset )
{
/#
	self endon( "death" );
	if ( isDefined( thread_endon ) )
	{
		self notify( thread_endon );
		self endon( thread_endon );
	}
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 1 );
	}
	while ( 1 )
	{
		print3d( self.origin + offset, msg );
		wait 0,05;
#/
	}
}

debug_breadcrumbs()
{
/#
	self endon( "disconnect" );
	self notify( "stop_debug_breadcrumbs" );
	self endon( "stop_debug_breadcrumbs" );
	while ( 1 )
	{
		while ( getDvarInt( "zombie_debug" ) != 1 )
		{
			wait 1;
		}
		i = 0;
		while ( i < self.zombie_breadcrumbs.size )
		{
			drawcylinder( self.zombie_breadcrumbs[ i ], 5, 5 );
			i++;
		}
		wait 0,05;
#/
	}
}

debug_attack_spots_taken()
{
/#
	self notify( "stop_debug_breadcrumbs" );
	self endon( "stop_debug_breadcrumbs" );
	while ( 1 )
	{
		while ( getDvarInt( "zombie_debug" ) != 2 )
		{
			wait 1;
		}
		wait 0,05;
		count = 0;
		i = 0;
		while ( i < self.attack_spots_taken.size )
		{
			if ( self.attack_spots_taken[ i ] )
			{
				count++;
				circle( self.attack_spots[ i ], 12, ( 0, 0, 1 ), 0, 1, 1 );
				i++;
				continue;
			}
			else
			{
				circle( self.attack_spots[ i ], 12, ( 0, 0, 1 ), 0, 1, 1 );
			}
			i++;
		}
		msg = "" + count + " / " + self.attack_spots_taken.size;
		print3d( self.origin, msg );
#/
	}
}

float_print3d( msg, time )
{
/#
	self endon( "death" );
	time = getTime() + ( time * 1000 );
	offset = vectorScale( ( 0, 0, 1 ), 72 );
	while ( getTime() < time )
	{
		offset += vectorScale( ( 0, 0, 1 ), 2 );
		print3d( self.origin + offset, msg, ( 0, 0, 1 ) );
		wait 0,05;
#/
	}
}

do_player_vo( snd, variation_count )
{
	index = maps/mp/zombies/_zm_weapons::get_player_index( self );
	sound = "zmb_vox_plr_" + index + "_" + snd;
	if ( isDefined( variation_count ) )
	{
		sound = ( sound + "_" ) + randomintrange( 0, variation_count );
	}
	if ( !isDefined( level.player_is_speaking ) )
	{
		level.player_is_speaking = 0;
	}
	if ( level.player_is_speaking == 0 )
	{
		level.player_is_speaking = 1;
		self playsoundwithnotify( sound, "sound_done" );
		self waittill( "sound_done" );
		wait 2;
		level.player_is_speaking = 0;
	}
}

stop_magic_bullet_shield()
{
	self.attackeraccuracy = 1;
	self notify( "stop_magic_bullet_shield" );
	self.magic_bullet_shield = undefined;
	self._mbs = undefined;
}

magic_bullet_shield()
{
	if ( isDefined( self.magic_bullet_shield ) && !self.magic_bullet_shield )
	{
		if ( isai( self ) || isplayer( self ) )
		{
			self.magic_bullet_shield = 1;
/#
			level thread debug_magic_bullet_shield_death( self );
#/
			if ( !isDefined( self._mbs ) )
			{
				self._mbs = spawnstruct();
			}
			if ( isai( self ) )
			{
/#
				assert( isalive( self ), "Tried to do magic_bullet_shield on a dead or undefined guy." );
#/
				self._mbs.last_pain_time = 0;
				self._mbs.ignore_time = 2;
				self._mbs.turret_ignore_time = 5;
			}
			self.attackeraccuracy = 0,1;
			return;
		}
		else
		{
/#
			assertmsg( "magic_bullet_shield does not support entity of classname '" + self.classname + "'." );
#/
		}
	}
}

debug_magic_bullet_shield_death( guy )
{
	targetname = "none";
	if ( isDefined( guy.targetname ) )
	{
		targetname = guy.targetname;
	}
	guy endon( "stop_magic_bullet_shield" );
	guy waittill( "death" );
/#
	assert( !isDefined( guy ), "Guy died with magic bullet shield on with targetname: " + targetname );
#/
}

is_magic_bullet_shield_enabled( ent )
{
	if ( !isDefined( ent ) )
	{
		return 0;
	}
	if ( isDefined( ent.magic_bullet_shield ) )
	{
		return ent.magic_bullet_shield == 1;
	}
}

really_play_2d_sound( sound )
{
	temp_ent = spawn( "script_origin", ( 0, 0, 1 ) );
	temp_ent playsoundwithnotify( sound, sound + "wait" );
	temp_ent waittill( sound + "wait" );
	wait 0,05;
	temp_ent delete();
}

play_sound_2d( sound )
{
	level thread really_play_2d_sound( sound );
}

include_weapon( weapon_name, in_box, collector, weighting_func )
{
/#
	println( "ZM >> include_weapon = " + weapon_name );
#/
	if ( !isDefined( in_box ) )
	{
		in_box = 1;
	}
	if ( !isDefined( collector ) )
	{
		collector = 0;
	}
	maps/mp/zombies/_zm_weapons::include_zombie_weapon( weapon_name, in_box, collector, weighting_func );
}

include_buildable( buildable_struct )
{
/#
	println( "ZM >> include_buildable = " + buildable_struct.name );
#/
	maps/mp/zombies/_zm_buildables::include_zombie_buildable( buildable_struct );
}

is_buildable_included( name )
{
	if ( isDefined( level.zombie_include_buildables[ name ] ) )
	{
		return 1;
	}
	return 0;
}

create_zombie_buildable_piece( modelname, radius, height, hud_icon )
{
/#
	println( "ZM >> create_zombie_buildable_piece = " + modelname );
#/
	self maps/mp/zombies/_zm_buildables::create_zombie_buildable_piece( modelname, radius, height, hud_icon );
}

is_buildable()
{
	return self maps/mp/zombies/_zm_buildables::is_buildable();
}

wait_for_buildable( buildable_name )
{
	level waittill( buildable_name + "_built", player );
	return player;
}

include_powered_item( power_on_func, power_off_func, range_func, cost_func, power_sources, start_power, target )
{
	return maps/mp/zombies/_zm_power::add_powered_item( power_on_func, power_off_func, range_func, cost_func, power_sources, start_power, target );
}

include_powerup( powerup_name )
{
	maps/mp/zombies/_zm_powerups::include_zombie_powerup( powerup_name );
}

include_equipment( equipment_name )
{
	maps/mp/zombies/_zm_equipment::include_zombie_equipment( equipment_name );
}

limit_equipment( equipment_name, limited )
{
	maps/mp/zombies/_zm_equipment::limit_zombie_equipment( equipment_name, limited );
}

trigger_invisible( enable )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( players[ i ] ) )
		{
			self setinvisibletoplayer( players[ i ], enable );
		}
		i++;
	}
}

print3d_ent( text, color, scale, offset, end_msg, overwrite )
{
	self endon( "death" );
	if ( isDefined( overwrite ) && overwrite && isDefined( self._debug_print3d_msg ) )
	{
		self notify( "end_print3d" );
		wait 0,05;
	}
	self endon( "end_print3d" );
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	if ( !isDefined( scale ) )
	{
		scale = 1;
	}
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 1 );
	}
	if ( isDefined( end_msg ) )
	{
		self endon( end_msg );
	}
	self._debug_print3d_msg = text;
/#
	while ( 1 )
	{
		print3d( self.origin + offset, self._debug_print3d_msg, color, scale );
		wait 0,05;
#/
	}
}

isexplosivedamage( meansofdeath )
{
	explosivedamage = "MOD_GRENADE MOD_GRENADE_SPLASH MOD_PROJECTILE_SPLASH MOD_EXPLOSIVE";
	if ( issubstr( explosivedamage, meansofdeath ) )
	{
		return 1;
	}
	return 0;
}

isprimarydamage( meansofdeath )
{
	if ( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" )
	{
		return 1;
	}
	return 0;
}

isfiredamage( weapon, meansofdeath )
{
	if ( !issubstr( weapon, "flame" ) && !issubstr( weapon, "molotov_" ) && issubstr( weapon, "napalmblob_" ) && meansofdeath != "MOD_BURNED" || meansofdeath == "MOD_GRENADE" && meansofdeath == "MOD_GRENADE_SPLASH" )
	{
		return 1;
	}
	return 0;
}

isplayerexplosiveweapon( weapon, meansofdeath )
{
	if ( !isexplosivedamage( meansofdeath ) )
	{
		return 0;
	}
	if ( weapon == "artillery_mp" )
	{
		return 0;
	}
	if ( issubstr( weapon, "turret" ) )
	{
		return 0;
	}
	return 1;
}

create_counter_hud( x )
{
	if ( !isDefined( x ) )
	{
		x = 0;
	}
	hud = create_simple_hud();
	hud.alignx = "left";
	hud.aligny = "top";
	hud.horzalign = "user_left";
	hud.vertalign = "user_top";
	hud.color = ( 0, 0, 1 );
	hud.fontscale = 32;
	hud.x = x;
	hud.alpha = 0;
	hud setshader( "hud_chalk_1", 64, 64 );
	return hud;
}

get_current_zone( return_zone )
{
	flag_wait( "zones_initialized" );
	z = 0;
	while ( z < level.zone_keys.size )
	{
		zone_name = level.zone_keys[ z ];
		zone = level.zones[ zone_name ];
		i = 0;
		while ( i < zone.volumes.size )
		{
			if ( self istouching( zone.volumes[ i ] ) )
			{
				if ( isDefined( return_zone ) && return_zone )
				{
					return zone;
				}
				return zone_name;
			}
			i++;
		}
		z++;
	}
	return undefined;
}

remove_mod_from_methodofdeath( mod )
{
	return mod;
}

clear_fog_threads()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] notify( "stop_fog" );
		i++;
	}
}

display_message( titletext, notifytext, duration )
{
	notifydata = spawnstruct();
	notifydata.titletext = notifytext;
	notifydata.notifytext = titletext;
	notifydata.sound = "mus_level_up";
	notifydata.duration = duration;
	notifydata.glowcolor = ( 0, 0, 1 );
	notifydata.color = ( 0, 0, 1 );
	notifydata.iconname = "hud_zombies_meat";
	self thread maps/mp/gametypes_zm/_hud_message::notifymessage( notifydata );
}

is_quad()
{
	return self.animname == "quad_zombie";
}

is_leaper()
{
	return self.animname == "leaper_zombie";
}

shock_onpain()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "stop_shock_onpain" );
	self endon( "stop_shock_onpain" );
	if ( getDvar( "blurpain" ) == "" )
	{
		setdvar( "blurpain", "on" );
	}
	for ( ;; )
	{
		while ( 1 )
		{
			oldhealth = self.health;
			self waittill( "damage", damage, attacker, direction_vec, point, mod );
			if ( isDefined( level.shock_onpain ) && !level.shock_onpain )
			{
				continue;
			}
			if ( isDefined( self.shock_onpain ) && !self.shock_onpain )
			{
				continue;
			}
			while ( self.health < 1 )
			{
				continue;
			}
			if ( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" )
			{
			}
		}
		else if ( mod != "MOD_GRENADE_SPLASH" || mod == "MOD_GRENADE" && mod == "MOD_EXPLOSIVE" )
		{
			shocktype = undefined;
			shocklight = undefined;
			if ( isDefined( self.is_burning ) && self.is_burning )
			{
				shocktype = "lava";
				shocklight = "lava_small";
			}
			self shock_onexplosion( damage, shocktype, shocklight );
			continue;
		}
		else
		{
			if ( getDvar( "blurpain" ) == "on" )
			{
				self shellshock( "pain", 0,5 );
			}
		}
	}
}

shock_onexplosion( damage, shocktype, shocklight )
{
	time = 0;
	scaled_damage = ( 100 * damage ) / self.maxhealth;
	if ( scaled_damage >= 90 )
	{
		time = 4;
	}
	else if ( scaled_damage >= 50 )
	{
		time = 3;
	}
	else if ( scaled_damage >= 25 )
	{
		time = 2;
	}
	else
	{
		if ( scaled_damage > 10 )
		{
			time = 1;
		}
	}
	if ( time )
	{
		if ( !isDefined( shocktype ) )
		{
			shocktype = "explosion";
		}
		self shellshock( shocktype, time );
	}
	else
	{
		if ( isDefined( shocklight ) )
		{
			self shellshock( shocklight, time );
		}
	}
}

increment_is_drinking()
{
/#
	if ( isDefined( level.devgui_dpad_watch ) && level.devgui_dpad_watch )
	{
		self.is_drinking++;
		return;
#/
	}
	if ( !isDefined( self.is_drinking ) )
	{
		self.is_drinking = 0;
	}
	if ( self.is_drinking == 0 )
	{
		self disableoffhandweapons();
		self disableweaponcycling();
	}
	self.is_drinking++;
}

is_multiple_drinking()
{
	return self.is_drinking > 1;
}

decrement_is_drinking()
{
	if ( self.is_drinking > 0 )
	{
		self.is_drinking--;

	}
	else
	{
/#
		assertmsg( "making is_drinking less than 0" );
#/
	}
	if ( self.is_drinking == 0 )
	{
		self enableoffhandweapons();
		self enableweaponcycling();
	}
}

clear_is_drinking()
{
	self.is_drinking = 0;
	self enableoffhandweapons();
	self enableweaponcycling();
}

getweaponclasszm( weapon )
{
/#
	assert( isDefined( weapon ) );
#/
	if ( !isDefined( weapon ) )
	{
		return undefined;
	}
	if ( !isDefined( level.weaponclassarray ) )
	{
		level.weaponclassarray = [];
	}
	if ( isDefined( level.weaponclassarray[ weapon ] ) )
	{
		return level.weaponclassarray[ weapon ];
	}
	baseweaponindex = getbaseweaponitemindex( weapon ) + 1;
	weaponclass = tablelookupcolumnforrow( "zm/zm_statstable.csv", baseweaponindex, 2 );
	level.weaponclassarray[ weapon ] = weaponclass;
	return weaponclass;
}

spawn_weapon_model( weapon, model, origin, angles, options )
{
	if ( !isDefined( model ) )
	{
		model = getweaponmodel( weapon );
	}
	weapon_model = spawn( "script_model", origin );
	if ( isDefined( angles ) )
	{
		weapon_model.angles = angles;
	}
	if ( isDefined( options ) )
	{
		weapon_model useweaponmodel( weapon, model, options );
	}
	else
	{
		weapon_model useweaponmodel( weapon, model );
	}
	return weapon_model;
}

is_limited_weapon( weapname )
{
	if ( isDefined( level.limited_weapons ) )
	{
		if ( isDefined( level.limited_weapons[ weapname ] ) )
		{
			return 1;
		}
	}
	return 0;
}

is_alt_weapon( weapname )
{
	if ( getsubstr( weapname, 0, 3 ) == "gl_" )
	{
		return 1;
	}
	if ( getsubstr( weapname, 0, 3 ) == "sf_" )
	{
		return 1;
	}
	if ( getsubstr( weapname, 0, 10 ) == "dualoptic_" )
	{
		return 1;
	}
	return 0;
}

is_grenade_launcher( weapname )
{
	if ( weapname != "m32_zm" )
	{
		return weapname == "m32_upgraded_zm";
	}
}

register_lethal_grenade_for_level( weaponname )
{
	if ( is_lethal_grenade( weaponname ) )
	{
		return;
	}
	if ( !isDefined( level.zombie_lethal_grenade_list ) )
	{
		level.zombie_lethal_grenade_list = [];
	}
	level.zombie_lethal_grenade_list[ weaponname ] = weaponname;
}

is_lethal_grenade( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( level.zombie_lethal_grenade_list ) )
	{
		return 0;
	}
	return isDefined( level.zombie_lethal_grenade_list[ weaponname ] );
}

is_player_lethal_grenade( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( self.current_lethal_grenade ) )
	{
		return 0;
	}
	return self.current_lethal_grenade == weaponname;
}

get_player_lethal_grenade()
{
	grenade = "";
	if ( isDefined( self.current_lethal_grenade ) )
	{
		grenade = self.current_lethal_grenade;
	}
	return grenade;
}

set_player_lethal_grenade( weaponname )
{
	self.current_lethal_grenade = weaponname;
}

init_player_lethal_grenade()
{
	self set_player_lethal_grenade( level.zombie_lethal_grenade_player_init );
}

register_tactical_grenade_for_level( weaponname )
{
	if ( is_tactical_grenade( weaponname ) )
	{
		return;
	}
	if ( !isDefined( level.zombie_tactical_grenade_list ) )
	{
		level.zombie_tactical_grenade_list = [];
	}
	level.zombie_tactical_grenade_list[ weaponname ] = weaponname;
}

is_tactical_grenade( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( level.zombie_tactical_grenade_list ) )
	{
		return 0;
	}
	return isDefined( level.zombie_tactical_grenade_list[ weaponname ] );
}

is_player_tactical_grenade( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( self.current_tactical_grenade ) )
	{
		return 0;
	}
	return self.current_tactical_grenade == weaponname;
}

get_player_tactical_grenade()
{
	tactical = "";
	if ( isDefined( self.current_tactical_grenade ) )
	{
		tactical = self.current_tactical_grenade;
	}
	return tactical;
}

set_player_tactical_grenade( weaponname )
{
	self notify( "new_tactical_grenade" );
	self.current_tactical_grenade = weaponname;
}

init_player_tactical_grenade()
{
	self set_player_tactical_grenade( level.zombie_tactical_grenade_player_init );
}

register_placeable_mine_for_level( weaponname )
{
	if ( is_placeable_mine( weaponname ) )
	{
		return;
	}
	if ( !isDefined( level.zombie_placeable_mine_list ) )
	{
		level.zombie_placeable_mine_list = [];
	}
	level.zombie_placeable_mine_list[ weaponname ] = weaponname;
}

is_placeable_mine( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( level.zombie_placeable_mine_list ) )
	{
		return 0;
	}
	return isDefined( level.zombie_placeable_mine_list[ weaponname ] );
}

is_player_placeable_mine( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( self.current_placeable_mine ) )
	{
		return 0;
	}
	return self.current_placeable_mine == weaponname;
}

get_player_placeable_mine()
{
	return self.current_placeable_mine;
}

set_player_placeable_mine( weaponname )
{
	self.current_placeable_mine = weaponname;
}

init_player_placeable_mine()
{
	self set_player_placeable_mine( level.zombie_placeable_mine_player_init );
}

register_melee_weapon_for_level( weaponname )
{
	if ( is_melee_weapon( weaponname ) )
	{
		return;
	}
	if ( !isDefined( level.zombie_melee_weapon_list ) )
	{
		level.zombie_melee_weapon_list = [];
	}
	level.zombie_melee_weapon_list[ weaponname ] = weaponname;
}

is_melee_weapon( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( level.zombie_melee_weapon_list ) )
	{
		return 0;
	}
	return isDefined( level.zombie_melee_weapon_list[ weaponname ] );
}

is_player_melee_weapon( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( self.current_melee_weapon ) )
	{
		return 0;
	}
	return self.current_melee_weapon == weaponname;
}

get_player_melee_weapon()
{
	return self.current_melee_weapon;
}

set_player_melee_weapon( weaponname )
{
	self.current_melee_weapon = weaponname;
}

init_player_melee_weapon()
{
	self set_player_melee_weapon( level.zombie_melee_weapon_player_init );
}

should_watch_for_emp()
{
	return isDefined( level.zombie_weapons[ "emp_grenade_zm" ] );
}

register_equipment_for_level( weaponname )
{
	if ( is_equipment( weaponname ) )
	{
		return;
	}
	if ( !isDefined( level.zombie_equipment_list ) )
	{
		level.zombie_equipment_list = [];
	}
	level.zombie_equipment_list[ weaponname ] = weaponname;
}

is_equipment( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( level.zombie_equipment_list ) )
	{
		return 0;
	}
	return isDefined( level.zombie_equipment_list[ weaponname ] );
}

is_equipment_that_blocks_purchase( weaponname )
{
	return is_equipment( weaponname );
}

is_player_equipment( weaponname )
{
	if ( !isDefined( weaponname ) || !isDefined( self.current_equipment ) )
	{
		return 0;
	}
	return self.current_equipment == weaponname;
}

has_deployed_equipment( weaponname )
{
	if ( isDefined( weaponname ) || !isDefined( self.deployed_equipment ) && self.deployed_equipment.size < 1 )
	{
		return 0;
	}
	i = 0;
	while ( i < self.deployed_equipment.size )
	{
		if ( self.deployed_equipment[ i ] == weaponname )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

has_player_equipment( weaponname )
{
	if ( !self is_player_equipment( weaponname ) )
	{
		return self has_deployed_equipment( weaponname );
	}
}

get_player_equipment()
{
	return self.current_equipment;
}

hacker_active()
{
	return self maps/mp/zombies/_zm_equipment::is_equipment_active( "equip_hacker_zm" );
}

set_player_equipment( weaponname )
{
	if ( !isDefined( self.current_equipment_active ) )
	{
		self.current_equipment_active = [];
	}
	if ( isDefined( weaponname ) )
	{
		self.current_equipment_active[ weaponname ] = 0;
	}
	if ( !isDefined( self.equipment_got_in_round ) )
	{
		self.equipment_got_in_round = [];
	}
	if ( isDefined( weaponname ) )
	{
		self.equipment_got_in_round[ weaponname ] = level.round_number;
	}
	self.current_equipment = weaponname;
}

init_player_equipment()
{
	self set_player_equipment( level.zombie_equipment_player_init );
}

register_offhand_weapons_for_level_defaults()
{
	if ( isDefined( level.register_offhand_weapons_for_level_defaults_override ) )
	{
		[[ level.register_offhand_weapons_for_level_defaults_override ]]();
		return;
	}
	register_lethal_grenade_for_level( "frag_grenade_zm" );
	level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
	register_tactical_grenade_for_level( "cymbal_monkey_zm" );
	level.zombie_tactical_grenade_player_init = undefined;
	register_placeable_mine_for_level( "claymore_zm" );
	level.zombie_placeable_mine_player_init = undefined;
	register_melee_weapon_for_level( "knife_zm" );
	register_melee_weapon_for_level( "bowie_knife_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm";
	level.zombie_equipment_player_init = undefined;
}

init_player_offhand_weapons()
{
	init_player_lethal_grenade();
	init_player_tactical_grenade();
	init_player_placeable_mine();
	init_player_melee_weapon();
	init_player_equipment();
}

is_offhand_weapon( weaponname )
{
	if ( !is_lethal_grenade( weaponname ) && !is_tactical_grenade( weaponname ) && !is_placeable_mine( weaponname ) && !is_melee_weapon( weaponname ) )
	{
		return is_equipment( weaponname );
	}
}

is_player_offhand_weapon( weaponname )
{
	if ( !self is_player_lethal_grenade( weaponname ) && !self is_player_tactical_grenade( weaponname ) && !self is_player_placeable_mine( weaponname ) && !self is_player_melee_weapon( weaponname ) )
	{
		return self is_player_equipment( weaponname );
	}
}

has_powerup_weapon()
{
	if ( isDefined( self.has_powerup_weapon ) )
	{
		return self.has_powerup_weapon;
	}
}

give_start_weapon( switch_to_weapon )
{
	self giveweapon( level.start_weapon );
	self givestartammo( level.start_weapon );
	if ( isDefined( switch_to_weapon ) && switch_to_weapon )
	{
		self switchtoweapon( level.start_weapon );
	}
}

array_flag_wait_any( flag_array )
{
	if ( !isDefined( level._array_flag_wait_any_calls ) )
	{
		level._n_array_flag_wait_any_calls = 0;
	}
	else
	{
		level._n_array_flag_wait_any_calls++;
	}
	str_condition = "array_flag_wait_call_" + level._n_array_flag_wait_any_calls;
	index = 0;
	while ( index < flag_array.size )
	{
		level thread array_flag_wait_any_thread( flag_array[ index ], str_condition );
		index++;
	}
	level waittill( str_condition );
}

array_flag_wait_any_thread( flag_name, condition )
{
	level endon( condition );
	flag_wait( flag_name );
	level notify( condition );
}

array_removedead( array )
{
	newarray = [];
	if ( !isDefined( array ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < array.size )
	{
		if ( !isalive( array[ i ] ) || isDefined( array[ i ].isacorpse ) && array[ i ].isacorpse )
		{
			i++;
			continue;
		}
		else
		{
			newarray[ newarray.size ] = array[ i ];
		}
		i++;
	}
	return newarray;
}

groundpos( origin )
{
	return bullettrace( origin, origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self )[ "position" ];
}

groundpos_ignore_water( origin )
{
	return bullettrace( origin, origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self, 1 )[ "position" ];
}

groundpos_ignore_water_new( origin )
{
	return groundtrace( origin, origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self, 1 )[ "position" ];
}

waittill_notify_or_timeout( msg, timer )
{
	self endon( msg );
	wait timer;
	return timer;
}

self_delete()
{
	if ( isDefined( self ) )
	{
		self delete();
	}
}

script_delay()
{
	if ( isDefined( self.script_delay ) )
	{
		wait self.script_delay;
		return 1;
	}
	else
	{
		if ( isDefined( self.script_delay_min ) && isDefined( self.script_delay_max ) )
		{
			wait randomfloatrange( self.script_delay_min, self.script_delay_max );
			return 1;
		}
	}
	return 0;
}

button_held_think( which_button )
{
	self endon( "disconnect" );
	if ( !isDefined( self._holding_button ) )
	{
		self._holding_button = [];
	}
	self._holding_button[ which_button ] = 0;
	time_started = 0;
	use_time = 250;
	while ( 1 )
	{
		if ( self._holding_button[ which_button ] )
		{
			if ( !( self [[ level._button_funcs[ which_button ] ]]() ) )
			{
				self._holding_button[ which_button ] = 0;
			}
		}
		else if ( self [[ level._button_funcs[ which_button ] ]]() )
		{
			if ( time_started == 0 )
			{
				time_started = getTime();
			}
			if ( ( getTime() - time_started ) > use_time )
			{
				self._holding_button[ which_button ] = 1;
			}
		}
		else
		{
			if ( time_started != 0 )
			{
				time_started = 0;
			}
		}
		wait 0,05;
	}
}

use_button_held()
{
	init_button_wrappers();
	if ( !isDefined( self._use_button_think_threaded ) )
	{
		self thread button_held_think( level.button_use );
		self._use_button_think_threaded = 1;
	}
	return self._holding_button[ level.button_use ];
}

ads_button_held()
{
	init_button_wrappers();
	if ( !isDefined( self._ads_button_think_threaded ) )
	{
		self thread button_held_think( level.button_ads );
		self._ads_button_think_threaded = 1;
	}
	return self._holding_button[ level.button_ads ];
}

attack_button_held()
{
	init_button_wrappers();
	if ( !isDefined( self._attack_button_think_threaded ) )
	{
		self thread button_held_think( level.button_attack );
		self._attack_button_think_threaded = 1;
	}
	return self._holding_button[ level.button_attack ];
}

use_button_pressed()
{
	return self usebuttonpressed();
}

ads_button_pressed()
{
	return self adsbuttonpressed();
}

attack_button_pressed()
{
	return self attackbuttonpressed();
}

init_button_wrappers()
{
	if ( !isDefined( level._button_funcs ) )
	{
		level.button_use = 0;
		level.button_ads = 1;
		level.button_attack = 2;
		level._button_funcs[ level.button_use ] = ::use_button_pressed;
		level._button_funcs[ level.button_ads ] = ::ads_button_pressed;
		level._button_funcs[ level.button_attack ] = ::attack_button_pressed;
	}
}

wait_network_frame()
{
	if ( numremoteclients() )
	{
		snapshot_ids = getsnapshotindexarray();
		acked = undefined;
		while ( !isDefined( acked ) )
		{
			level waittill( "snapacknowledged" );
			acked = snapshotacknowledged( snapshot_ids );
		}
	}
	else wait 0,1;
}

ignore_triggers( timer )
{
	self endon( "death" );
	self.ignoretriggers = 1;
	if ( isDefined( timer ) )
	{
		wait timer;
	}
	else
	{
		wait 0,5;
	}
	self.ignoretriggers = 0;
}

giveachievement_wrapper( achievement, all_players )
{
	if ( achievement == "" )
	{
		return;
	}
	if ( isDefined( level.zm_disable_recording_stats ) && level.zm_disable_recording_stats )
	{
		return;
	}
	achievement_lower = tolower( achievement );
	global_counter = 0;
	if ( isDefined( all_players ) && all_players )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			players[ i ] giveachievement( achievement );
			has_achievement = players[ i ] maps/mp/zombies/_zm_stats::get_global_stat( achievement_lower );
			if ( isDefined( has_achievement ) && !has_achievement )
			{
				global_counter++;
			}
			players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( achievement_lower, 0 );
			if ( issplitscreen() || i == 0 && !issplitscreen() )
			{
				if ( isDefined( level.achievement_sound_func ) )
				{
					players[ i ] thread [[ level.achievement_sound_func ]]( achievement_lower );
				}
			}
			i++;
		}
	}
	else if ( !isplayer( self ) )
	{
/#
		println( "^1self needs to be a player for _utility::giveachievement_wrapper()" );
#/
		return;
	}
	self giveachievement( achievement );
	has_achievement = self maps/mp/zombies/_zm_stats::get_global_stat( achievement_lower );
	if ( isDefined( has_achievement ) && !has_achievement )
	{
		global_counter++;
	}
	self maps/mp/zombies/_zm_stats::increment_client_stat( achievement_lower, 0 );
	if ( isDefined( level.achievement_sound_func ) )
	{
		self thread [[ level.achievement_sound_func ]]( achievement_lower );
	}
	if ( global_counter )
	{
		incrementcounter( "global_" + achievement_lower, global_counter );
	}
}

spawn_failed( spawn )
{
	if ( isDefined( spawn ) && isalive( spawn ) )
	{
		if ( isalive( spawn ) )
		{
			return 0;
		}
	}
	return 1;
}

getyaw( org )
{
	angles = vectorToAngle( org - self.origin );
	return angles[ 1 ];
}

getyawtospot( spot )
{
	pos = spot;
	yaw = self.angles[ 1 ] - getyaw( pos );
	yaw = angleClamp180( yaw );
	return yaw;
}

add_spawn_function( function, param1, param2, param3, param4 )
{
/#
	if ( isDefined( level._loadstarted ) )
	{
		assert( !isalive( self ), "Tried to add_spawn_function to a living guy." );
	}
#/
	func = [];
	func[ "function" ] = function;
	func[ "param1" ] = param1;
	func[ "param2" ] = param2;
	func[ "param3" ] = param3;
	func[ "param4" ] = param4;
	if ( !isDefined( self.spawn_funcs ) )
	{
		self.spawn_funcs = [];
	}
	self.spawn_funcs[ self.spawn_funcs.size ] = func;
}

disable_react()
{
/#
	assert( isalive( self ), "Tried to disable react on a non ai" );
#/
	self.a.disablereact = 1;
	self.allowreact = 0;
}

enable_react()
{
/#
	assert( isalive( self ), "Tried to enable react on a non ai" );
#/
	self.a.disablereact = 0;
	self.allowreact = 1;
}

flag_wait_or_timeout( flagname, timer )
{
	start_time = getTime();
	for ( ;; )
	{
		if ( level.flag[ flagname ] )
		{
			return;
		}
		else if ( getTime() >= ( start_time + ( timer * 1000 ) ) )
		{
			return;
		}
		else
		{
			wait_for_flag_or_time_elapses( flagname, timer );
		}
	}
}

wait_for_flag_or_time_elapses( flagname, timer )
{
	level endon( flagname );
	wait timer;
}

isads( player )
{
	return player playerads() > 0,5;
}

bullet_attack( type )
{
	if ( type == "MOD_PISTOL_BULLET" )
	{
		return 1;
	}
	return type == "MOD_RIFLE_BULLET";
}

pick_up()
{
	player = self.owner;
	self destroy_ent();
	clip_ammo = player getweaponammoclip( self.name );
	clip_max_ammo = weaponclipsize( self.name );
	if ( clip_ammo < clip_max_ammo )
	{
		clip_ammo++;
	}
	player setweaponammoclip( self.name, clip_ammo );
}

destroy_ent()
{
	self delete();
}

waittill_not_moving()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "detonated" );
	level endon( "game_ended" );
	if ( self.classname == "grenade" )
	{
		self waittill( "stationary" );
	}
	else prevorigin = self.origin;
	while ( 1 )
	{
		wait 0,15;
		if ( self.origin == prevorigin )
		{
			return;
		}
		else
		{
			prevorigin = self.origin;
		}
	}
}

get_closest_player( org )
{
	players = [];
	players = get_players();
	return getclosest( org, players );
}

ent_flag_wait( msg )
{
	self endon( "death" );
	while ( !self.ent_flag[ msg ] )
	{
		self waittill( msg );
	}
}

ent_flag_wait_either( flag1, flag2 )
{
	self endon( "death" );
	for ( ;; )
	{
		if ( ent_flag( flag1 ) )
		{
			return;
		}
		if ( ent_flag( flag2 ) )
		{
			return;
		}
		self waittill_either( flag1, flag2 );
	}
}

ent_wait_for_flag_or_time_elapses( flagname, timer )
{
	self endon( flagname );
	wait timer;
}

ent_flag_wait_or_timeout( flagname, timer )
{
	self endon( "death" );
	start_time = getTime();
	for ( ;; )
	{
		if ( self.ent_flag[ flagname ] )
		{
			return;
		}
		else if ( getTime() >= ( start_time + ( timer * 1000 ) ) )
		{
			return;
		}
		else
		{
			self ent_wait_for_flag_or_time_elapses( flagname, timer );
		}
	}
}

ent_flag_waitopen( msg )
{
	self endon( "death" );
	while ( self.ent_flag[ msg ] )
	{
		self waittill( msg );
	}
}

ent_flag_init( message, val )
{
	if ( !isDefined( self.ent_flag ) )
	{
		self.ent_flag = [];
		self.ent_flags_lock = [];
	}
	if ( !isDefined( level.first_frame ) )
	{
/#
		assert( !isDefined( self.ent_flag[ message ] ), "Attempt to reinitialize existing flag '" + message + "' on entity." );
#/
	}
	if ( isDefined( val ) && val )
	{
		self.ent_flag[ message ] = 1;
/#
		self.ent_flags_lock[ message ] = 1;
#/
	}
	else
	{
		self.ent_flag[ message ] = 0;
/#
		self.ent_flags_lock[ message ] = 0;
#/
	}
}

ent_flag_exist( message )
{
	if ( isDefined( self.ent_flag ) && isDefined( self.ent_flag[ message ] ) )
	{
		return 1;
	}
	return 0;
}

ent_flag_set_delayed( message, delay )
{
	wait delay;
	self ent_flag_set( message );
}

ent_flag_set( message )
{
/#
	assert( isDefined( self ), "Attempt to set a flag on entity that is not defined" );
	assert( isDefined( self.ent_flag[ message ] ), "Attempt to set a flag before calling flag_init: '" + message + "'." );
	assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = 1;
#/
	self.ent_flag[ message ] = 1;
	self notify( message );
}

ent_flag_toggle( message )
{
	if ( self ent_flag( message ) )
	{
		self ent_flag_clear( message );
	}
	else
	{
		self ent_flag_set( message );
	}
}

ent_flag_clear( message )
{
/#
	assert( isDefined( self ), "Attempt to clear a flag on entity that is not defined" );
	assert( isDefined( self.ent_flag[ message ] ), "Attempt to set a flag before calling flag_init: '" + message + "'." );
	assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = 0;
#/
	if ( self.ent_flag[ message ] )
	{
		self.ent_flag[ message ] = 0;
		self notify( message );
	}
}

ent_flag_clear_delayed( message, delay )
{
	wait delay;
	self ent_flag_clear( message );
}

ent_flag( message )
{
/#
	assert( isDefined( message ), "Tried to check flag but the flag was not defined." );
#/
/#
	assert( isDefined( self.ent_flag[ message ] ), "Tried to check entity flag '" + message + "', but the flag was not initialized." );
#/
	if ( !self.ent_flag[ message ] )
	{
		return 0;
	}
	return 1;
}

ent_flag_init_ai_standards()
{
	message_array = [];
	message_array[ message_array.size ] = "goal";
	message_array[ message_array.size ] = "damage";
	i = 0;
	while ( i < message_array.size )
	{
		self ent_flag_init( message_array[ i ] );
		self thread ent_flag_wait_ai_standards( message_array[ i ] );
		i++;
	}
}

ent_flag_wait_ai_standards( message )
{
	self endon( "death" );
	self waittill( message );
	self.ent_flag[ message ] = 1;
}

flat_angle( angle )
{
	rangle = ( 0, angle[ 1 ], 0 );
	return rangle;
}

waittill_any_or_timeout( timer, string1, string2, string3, string4, string5 )
{
/#
	assert( isDefined( string1 ) );
#/
	self endon( string1 );
	if ( isDefined( string2 ) )
	{
		self endon( string2 );
	}
	if ( isDefined( string3 ) )
	{
		self endon( string3 );
	}
	if ( isDefined( string4 ) )
	{
		self endon( string4 );
	}
	if ( isDefined( string5 ) )
	{
		self endon( string5 );
	}
	wait timer;
}

clear_run_anim()
{
	self.alwaysrunforward = undefined;
	self.a.combatrunanim = undefined;
	self.run_noncombatanim = undefined;
	self.walk_combatanim = undefined;
	self.walk_noncombatanim = undefined;
	self.precombatrunenabled = 1;
}

track_players_intersection_tracker()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "end_game" );
	wait 5;
	while ( 1 )
	{
		killed_players = 0;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate != "playing" )
			{
				i++;
				continue;
			}
			else
			{
				j = 0;
				while ( j < players.size )
				{
					if ( j != i || players[ j ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ j ].sessionstate != "playing" )
					{
						j++;
						continue;
					}
					else
					{
						if ( isDefined( level.player_intersection_tracker_override ) )
						{
							if ( players[ i ] [[ level.player_intersection_tracker_override ]]( players[ j ] ) )
							{
								j++;
								continue;
							}
						}
						else playeri_origin = players[ i ].origin;
						playerj_origin = players[ j ].origin;
						if ( abs( playeri_origin[ 2 ] - playerj_origin[ 2 ] ) > 60 )
						{
							j++;
							continue;
						}
						else distance_apart = distance2d( playeri_origin, playerj_origin );
						if ( abs( distance_apart ) > 18 )
						{
							j++;
							continue;
						}
						else
						{
/#
							iprintlnbold( "PLAYERS ARE TOO FRIENDLY!!!!!" );
#/
							players[ i ] dodamage( 1000, ( 0, 0, 1 ) );
							players[ j ] dodamage( 1000, ( 0, 0, 1 ) );
							if ( !killed_players )
							{
								players[ i ] playlocalsound( level.zmb_laugh_alias );
							}
							players[ i ] maps/mp/zombies/_zm_stats::increment_map_cheat_stat( "cheat_too_friendly" );
							players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_too_friendly", 0 );
							players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_total", 0 );
							players[ j ] maps/mp/zombies/_zm_stats::increment_map_cheat_stat( "cheat_too_friendly" );
							players[ j ] maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_too_friendly", 0 );
							players[ j ] maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_total", 0 );
							killed_players = 1;
						}
					}
					j++;
				}
			}
			i++;
		}
		wait 0,5;
	}
}

get_eye()
{
	if ( isplayer( self ) )
	{
		linked_ent = self getlinkedent();
		if ( isDefined( linked_ent ) && getDvarInt( "cg_cameraUseTagCamera" ) > 0 )
		{
			camera = linked_ent gettagorigin( "tag_camera" );
			if ( isDefined( camera ) )
			{
				return camera;
			}
		}
	}
	pos = self geteye();
	return pos;
}

is_player_looking_at( origin, dot, do_trace, ignore_ent )
{
/#
	assert( isplayer( self ), "player_looking_at must be called on a player." );
#/
	if ( !isDefined( dot ) )
	{
		dot = 0,7;
	}
	if ( !isDefined( do_trace ) )
	{
		do_trace = 1;
	}
	eye = self get_eye();
	delta_vec = anglesToForward( vectorToAngle( origin - eye ) );
	view_vec = anglesToForward( self getplayerangles() );
	new_dot = vectordot( delta_vec, view_vec );
	if ( new_dot >= dot )
	{
		if ( do_trace )
		{
			return bullettracepassed( origin, eye, 0, ignore_ent );
		}
		else
		{
			return 1;
		}
	}
	return 0;
}

add_gametype( gt, dummy1, name, dummy2 )
{
}

add_gameloc( gl, dummy1, name, dummy2 )
{
}

get_closest_index( org, array, dist )
{
	if ( !isDefined( dist ) )
	{
		dist = 9999999;
	}
	distsq = dist * dist;
	if ( array.size < 1 )
	{
		return;
	}
	index = undefined;
	i = 0;
	while ( i < array.size )
	{
		newdistsq = distancesquared( array[ i ].origin, org );
		if ( newdistsq >= distsq )
		{
			i++;
			continue;
		}
		else
		{
			distsq = newdistsq;
			index = i;
		}
		i++;
	}
	return index;
}

is_valid_zombie_spawn_point( point )
{
	liftedorigin = point.origin + vectorScale( ( 0, 0, 1 ), 5 );
	size = 48;
	height = 64;
	mins = ( -1 * size, -1 * size, 0 );
	maxs = ( size, size, height );
	absmins = liftedorigin + mins;
	absmaxs = liftedorigin + maxs;
	if ( boundswouldtelefrag( absmins, absmaxs ) )
	{
		return 0;
	}
	return 1;
}

get_closest_index_to_entity( entity, array, dist, extra_check )
{
	org = entity.origin;
	if ( !isDefined( dist ) )
	{
		dist = 9999999;
	}
	distsq = dist * dist;
	if ( array.size < 1 )
	{
		return;
	}
	index = undefined;
	i = 0;
	while ( i < array.size )
	{
		if ( isDefined( extra_check ) && !( [[ extra_check ]]( entity, array[ i ] ) ) )
		{
			i++;
			continue;
		}
		else
		{
			newdistsq = distancesquared( array[ i ].origin, org );
			if ( newdistsq >= distsq )
			{
				i++;
				continue;
			}
			else
			{
				distsq = newdistsq;
				index = i;
			}
		}
		i++;
	}
	return index;
}

set_gamemode_var( var, val )
{
	if ( !isDefined( game[ "gamemode_match" ] ) )
	{
		game[ "gamemode_match" ] = [];
	}
	game[ "gamemode_match" ][ var ] = val;
}

set_gamemode_var_once( var, val )
{
	if ( !isDefined( game[ "gamemode_match" ] ) )
	{
		game[ "gamemode_match" ] = [];
	}
	if ( !isDefined( game[ "gamemode_match" ][ var ] ) )
	{
		game[ "gamemode_match" ][ var ] = val;
	}
}

set_game_var( var, val )
{
	game[ var ] = val;
}

set_game_var_once( var, val )
{
	if ( !isDefined( game[ var ] ) )
	{
		game[ var ] = val;
	}
}

get_game_var( var )
{
	if ( isDefined( game[ var ] ) )
	{
		return game[ var ];
	}
	return undefined;
}

get_gamemode_var( var )
{
	if ( isDefined( game[ "gamemode_match" ] ) && isDefined( game[ "gamemode_match" ][ var ] ) )
	{
		return game[ "gamemode_match" ][ var ];
	}
	return undefined;
}

waittill_subset( min_num, string1, string2, string3, string4, string5 )
{
	self endon( "death" );
	ent = spawnstruct();
	ent.threads = 0;
	returned_threads = 0;
	if ( isDefined( string1 ) )
	{
		self thread waittill_string( string1, ent );
		ent.threads++;
	}
	if ( isDefined( string2 ) )
	{
		self thread waittill_string( string2, ent );
		ent.threads++;
	}
	if ( isDefined( string3 ) )
	{
		self thread waittill_string( string3, ent );
		ent.threads++;
	}
	if ( isDefined( string4 ) )
	{
		self thread waittill_string( string4, ent );
		ent.threads++;
	}
	if ( isDefined( string5 ) )
	{
		self thread waittill_string( string5, ent );
		ent.threads++;
	}
	while ( ent.threads )
	{
		ent waittill( "returned" );
		ent.threads--;

		returned_threads++;
		if ( returned_threads >= min_num )
		{
			break;
		}
		else
		{
		}
	}
	ent notify( "die" );
}

is_headshot( sweapon, shitloc, smeansofdeath )
{
	if ( shitloc != "head" && shitloc != "helmet" )
	{
		return 0;
	}
	if ( smeansofdeath == "MOD_IMPACT" && issubstr( sweapon, "knife_ballistic" ) )
	{
		return 1;
	}
	if ( smeansofdeath != "MOD_MELEE" && smeansofdeath != "MOD_BAYONET" && smeansofdeath != "MOD_IMPACT" )
	{
		return smeansofdeath != "MOD_UNKNOWN";
	}
}

is_jumping()
{
	ground_ent = self getgroundent();
	return !isDefined( ground_ent );
}

is_explosive_damage( mod )
{
	if ( !isDefined( mod ) )
	{
		return 0;
	}
	if ( mod != "MOD_GRENADE" && mod != "MOD_GRENADE_SPLASH" && mod != "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" && mod == "MOD_EXPLOSIVE" )
	{
		return 1;
	}
	return 0;
}

sndswitchannouncervox( who )
{
	switch( who )
	{
		case "sam":
			game[ "zmbdialog" ][ "prefix" ] = "vox_zmba_sam";
			level.zmb_laugh_alias = "zmb_laugh_sam";
			level.sndannouncerisrich = 0;
			break;
		case "richtofen":
			game[ "zmbdialog" ][ "prefix" ] = "vox_zmba";
			level.zmb_laugh_alias = "zmb_laugh_richtofen";
			level.sndannouncerisrich = 1;
			break;
	}
}

do_player_general_vox( category, type, timer, chance )
{
	if ( isDefined( timer ) && isDefined( level.votimer[ type ] ) && level.votimer[ type ] > 0 )
	{
		return;
	}
	if ( !isDefined( chance ) )
	{
		chance = maps/mp/zombies/_zm_audio::get_response_chance( type );
	}
	if ( chance > randomint( 100 ) )
	{
		self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( category, type );
		if ( isDefined( timer ) )
		{
			level.votimer[ type ] = timer;
			level thread general_vox_timer( level.votimer[ type ], type );
		}
	}
}

general_vox_timer( timer, type )
{
	level endon( "end_game" );
/#
	println( "ZM >> VOX TIMER STARTED FOR  " + type + " ( " + timer + ")" );
#/
	while ( timer > 0 )
	{
		wait 1;
		timer--;

	}
	level.votimer[ type ] = timer;
/#
	println( "ZM >> VOX TIMER ENDED FOR  " + type + " ( " + timer + ")" );
#/
}

create_vox_timer( type )
{
	level.votimer[ type ] = 0;
}

play_vox_to_player( category, type, force_variant )
{
	self thread maps/mp/zombies/_zm_audio::playvoxtoplayer( category, type, force_variant );
}

is_favorite_weapon( weapon_to_check )
{
	if ( !isDefined( self.favorite_wall_weapons_list ) )
	{
		return 0;
	}
	_a6174 = self.favorite_wall_weapons_list;
	_k6174 = getFirstArrayKey( _a6174 );
	while ( isDefined( _k6174 ) )
	{
		weapon = _a6174[ _k6174 ];
		if ( weapon_to_check == weapon )
		{
			return 1;
		}
		_k6174 = getNextArrayKey( _a6174, _k6174 );
	}
	return 0;
}

add_vox_response_chance( event, chance )
{
	level.response_chances[ event ] = chance;
}

set_demo_intermission_point()
{
	spawnpoints = getentarray( "mp_global_intermission", "classname" );
	if ( !spawnpoints.size )
	{
		return;
	}
	spawnpoint = spawnpoints[ 0 ];
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
	i = 0;
	while ( i < spawnpoints.size )
	{
		while ( isDefined( spawnpoints[ i ].script_string ) )
		{
			tokens = strtok( spawnpoints[ i ].script_string, " " );
			_a6214 = tokens;
			_k6214 = getFirstArrayKey( _a6214 );
			while ( isDefined( _k6214 ) )
			{
				token = _a6214[ _k6214 ];
				if ( token == match_string )
				{
					spawnpoint = spawnpoints[ i ];
					i = spawnpoints.size;
					i++;
					continue;
				}
				else
				{
					_k6214 = getNextArrayKey( _a6214, _k6214 );
				}
			}
		}
		i++;
	}
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
}

register_map_navcard( navcard_on_map, navcard_needed_for_computer )
{
	level.navcard_needed = navcard_needed_for_computer;
	level.map_navcard = navcard_on_map;
}

does_player_have_map_navcard( player )
{
	return player maps/mp/zombies/_zm_stats::get_global_stat( level.map_navcard );
}

does_player_have_correct_navcard( player )
{
	if ( !isDefined( level.navcard_needed ) )
	{
		return 0;
	}
	return player maps/mp/zombies/_zm_stats::get_global_stat( level.navcard_needed );
}

place_navcard( str_model, str_stat, org, angles )
{
	navcard = spawn( "script_model", org );
	navcard setmodel( str_model );
	navcard.angles = angles;
	wait 1;
	navcard_pickup_trig = spawn( "trigger_radius_use", org, 0, 84, 72 );
	navcard_pickup_trig setcursorhint( "HINT_NOICON" );
	navcard_pickup_trig sethintstring( &"ZOMBIE_NAVCARD_PICKUP" );
	navcard_pickup_trig triggerignoreteam();
	a_navcard_stats = array( "navcard_held_zm_transit", "navcard_held_zm_highrise", "navcard_held_zm_buried" );
	is_holding_card = 0;
	str_placing_stat = undefined;
	while ( 1 )
	{
		navcard_pickup_trig waittill( "trigger", who );
		if ( is_player_valid( who ) )
		{
			_a6274 = a_navcard_stats;
			_k6274 = getFirstArrayKey( _a6274 );
			while ( isDefined( _k6274 ) )
			{
				str_cur_stat = _a6274[ _k6274 ];
				if ( who maps/mp/zombies/_zm_stats::get_global_stat( str_cur_stat ) )
				{
					str_placing_stat = str_cur_stat;
					is_holding_card = 1;
					who maps/mp/zombies/_zm_stats::set_global_stat( str_cur_stat, 0 );
				}
				_k6274 = getNextArrayKey( _a6274, _k6274 );
			}
			who playsound( "zmb_buildable_piece_add" );
			who maps/mp/zombies/_zm_stats::set_global_stat( str_stat, 1 );
			who.navcard_grabbed = str_stat;
			wait_network_frame();
			is_stat = who maps/mp/zombies/_zm_stats::get_global_stat( str_stat );
			thread sq_refresh_player_navcard_hud();
			break;
		}
		else
		{
		}
	}
	navcard delete();
	navcard_pickup_trig delete();
	if ( is_holding_card )
	{
		level thread place_navcard( str_model, str_placing_stat, org, angles );
	}
}

sq_refresh_player_navcard_hud()
{
	if ( !isDefined( level.navcards ) )
	{
		return;
	}
	players = get_players();
	_a6311 = players;
	_k6311 = getFirstArrayKey( _a6311 );
	while ( isDefined( _k6311 ) )
	{
		player = _a6311[ _k6311 ];
		player thread sq_refresh_player_navcard_hud_internal();
		_k6311 = getNextArrayKey( _a6311, _k6311 );
	}
}

sq_refresh_player_navcard_hud_internal()
{
	self endon( "disconnect" );
	navcard_bits = 0;
	i = 0;
	while ( i < level.navcards.size )
	{
		hasit = self maps/mp/zombies/_zm_stats::get_global_stat( level.navcards[ i ] );
		if ( isDefined( self.navcard_grabbed ) && self.navcard_grabbed == level.navcards[ i ] )
		{
			hasit = 1;
		}
		if ( hasit )
		{
			navcard_bits += 1 << i;
		}
		i++;
	}
	wait_network_frame();
	self setclientfield( "navcard_held", 0 );
	if ( navcard_bits > 0 )
	{
		wait_network_frame();
		self setclientfield( "navcard_held", navcard_bits );
	}
}

set_player_is_female( onoff )
{
	if ( isDefined( level.use_female_animations ) && level.use_female_animations )
	{
		female_perk = "specialty_gpsjammer";
		if ( onoff )
		{
			self setperk( female_perk );
			return;
		}
		else
		{
			self unsetperk( female_perk );
		}
	}
}

disable_player_move_states( forcestancechange )
{
	self allowcrouch( 1 );
	self allowlean( 0 );
	self allowads( 0 );
	self allowsprint( 0 );
	self allowprone( 0 );
	self allowmelee( 0 );
	if ( isDefined( forcestancechange ) && forcestancechange == 1 )
	{
		if ( self getstance() == "prone" )
		{
			self setstance( "crouch" );
		}
	}
}

enable_player_move_states()
{
	if ( !isDefined( self._allow_lean ) || self._allow_lean == 1 )
	{
		self allowlean( 1 );
	}
	if ( !isDefined( self._allow_ads ) || self._allow_ads == 1 )
	{
		self allowads( 1 );
	}
	if ( !isDefined( self._allow_sprint ) || self._allow_sprint == 1 )
	{
		self allowsprint( 1 );
	}
	if ( !isDefined( self._allow_prone ) || self._allow_prone == 1 )
	{
		self allowprone( 1 );
	}
	if ( !isDefined( self._allow_melee ) || self._allow_melee == 1 )
	{
		self allowmelee( 1 );
	}
}

check_and_create_node_lists()
{
	if ( !isDefined( level._link_node_list ) )
	{
		level._link_node_list = [];
	}
	if ( !isDefined( level._unlink_node_list ) )
	{
		level._unlink_node_list = [];
	}
}

link_nodes( a, b, bdontunlinkonmigrate )
{
	if ( !isDefined( bdontunlinkonmigrate ) )
	{
		bdontunlinkonmigrate = 0;
	}
	if ( nodesarelinked( a, b ) )
	{
		return;
	}
	check_and_create_node_lists();
	a_index_string = "" + a.origin;
	b_index_string = "" + b.origin;
	if ( !isDefined( level._link_node_list[ a_index_string ] ) )
	{
		level._link_node_list[ a_index_string ] = spawnstruct();
		level._link_node_list[ a_index_string ].node = a;
		level._link_node_list[ a_index_string ].links = [];
		level._link_node_list[ a_index_string ].ignore_on_migrate = [];
	}
	if ( !isDefined( level._link_node_list[ a_index_string ].links[ b_index_string ] ) )
	{
		level._link_node_list[ a_index_string ].links[ b_index_string ] = b;
		level._link_node_list[ a_index_string ].ignore_on_migrate[ b_index_string ] = bdontunlinkonmigrate;
	}
	if ( isDefined( level._unlink_node_list[ a_index_string ] ) )
	{
		if ( isDefined( level._unlink_node_list[ a_index_string ].links[ b_index_string ] ) )
		{
		}
	}
	linknodes( a, b );
}

unlink_nodes( a, b, bdontlinkonmigrate )
{
	if ( !isDefined( bdontlinkonmigrate ) )
	{
		bdontlinkonmigrate = 0;
	}
	if ( !nodesarelinked( a, b ) )
	{
		return;
	}
	check_and_create_node_lists();
	a_index_string = "" + a.origin;
	b_index_string = "" + b.origin;
	if ( !isDefined( level._unlink_node_list[ a_index_string ] ) )
	{
		level._unlink_node_list[ a_index_string ] = spawnstruct();
		level._unlink_node_list[ a_index_string ].node = a;
		level._unlink_node_list[ a_index_string ].links = [];
		level._unlink_node_list[ a_index_string ].ignore_on_migrate = [];
	}
	if ( !isDefined( level._unlink_node_list[ a_index_string ].links[ b_index_string ] ) )
	{
		level._unlink_node_list[ a_index_string ].links[ b_index_string ] = b;
		level._unlink_node_list[ a_index_string ].ignore_on_migrate[ b_index_string ] = bdontlinkonmigrate;
	}
	if ( isDefined( level._link_node_list[ a_index_string ] ) )
	{
		if ( isDefined( level._link_node_list[ a_index_string ].links[ b_index_string ] ) )
		{
		}
	}
	unlinknodes( a, b );
}

spawn_path_node( origin, angles, k1, v1, k2, v2 )
{
	if ( !isDefined( level._spawned_path_nodes ) )
	{
		level._spawned_path_nodes = [];
	}
	node = spawnstruct();
	node.origin = origin;
	node.angles = angles;
	node.k1 = k1;
	node.v1 = v1;
	node.k2 = k2;
	node.v2 = v2;
	node.node = spawn_path_node_internal( origin, angles, k1, v1, k2, v2 );
	level._spawned_path_nodes[ level._spawned_path_nodes.size ] = node;
	return node.node;
}

spawn_path_node_internal( origin, angles, k1, v1, k2, v2 )
{
	if ( isDefined( k2 ) )
	{
		return spawnpathnode( "node_pathnode", origin, angles, k1, v1, k2, v2 );
	}
	else
	{
		if ( isDefined( k1 ) )
		{
			return spawnpathnode( "node_pathnode", origin, angles, k1, v1 );
		}
		else
		{
			return spawnpathnode( "node_pathnode", origin, angles );
		}
	}
	return undefined;
}

delete_spawned_path_nodes()
{
}

respawn_path_nodes()
{
	if ( !isDefined( level._spawned_path_nodes ) )
	{
		return;
	}
	i = 0;
	while ( i < level._spawned_path_nodes.size )
	{
		node_struct = level._spawned_path_nodes[ i ];
/#
		println( "Re-spawning spawned path node @ " + node_struct.origin );
#/
		node_struct.node = spawn_path_node_internal( node_struct.origin, node_struct.angles, node_struct.k1, node_struct.v1, node_struct.k2, node_struct.v2 );
		i++;
	}
}

link_changes_internal_internal( list, func )
{
	keys = getarraykeys( list );
	i = 0;
	while ( i < keys.size )
	{
		node = list[ keys[ i ] ].node;
		node_keys = getarraykeys( list[ keys[ i ] ].links );
		j = 0;
		while ( j < node_keys.size )
		{
			if ( isDefined( list[ keys[ i ] ].links[ node_keys[ j ] ] ) )
			{
				if ( isDefined( list[ keys[ i ] ].ignore_on_migrate[ node_keys[ j ] ] ) && list[ keys[ i ] ].ignore_on_migrate[ node_keys[ j ] ] )
				{
/#
					println( "Node at " + keys[ i ] + " to node at " + node_keys[ j ] + " - IGNORED" );
#/
					j++;
					continue;
				}
				else
				{
/#
					println( "Node at " + keys[ i ] + " to node at " + node_keys[ j ] );
#/
					[[ func ]]( node, list[ keys[ i ] ].links[ node_keys[ j ] ] );
				}
			}
			j++;
		}
		i++;
	}
}

link_changes_internal( func_for_link_list, func_for_unlink_list )
{
	if ( isDefined( level._link_node_list ) )
	{
/#
		println( "Link List" );
#/
		link_changes_internal_internal( level._link_node_list, func_for_link_list );
	}
	if ( isDefined( level._unlink_node_list ) )
	{
/#
		println( "UnLink List" );
#/
		link_changes_internal_internal( level._unlink_node_list, func_for_unlink_list );
	}
}

link_nodes_wrapper( a, b )
{
	if ( !nodesarelinked( a, b ) )
	{
		linknodes( a, b );
	}
}

unlink_nodes_wrapper( a, b )
{
	if ( nodesarelinked( a, b ) )
	{
		unlinknodes( a, b );
	}
}

undo_link_changes()
{
/#
	println( "***" );
	println( "***" );
	println( "*** Undoing link changes" );
#/
	link_changes_internal( ::unlink_nodes_wrapper, ::link_nodes_wrapper );
	delete_spawned_path_nodes();
}

redo_link_changes()
{
/#
	println( "***" );
	println( "***" );
	println( "*** Redoing link changes" );
#/
	respawn_path_nodes();
	link_changes_internal( ::link_nodes_wrapper, ::unlink_nodes_wrapper );
}

set_player_tombstone_index()
{
	if ( !isDefined( level.tombstone_index ) )
	{
		level.tombstone_index = 0;
	}
	if ( !isDefined( self.tombstone_index ) )
	{
		self.tombstone_index = level.tombstone_index;
		level.tombstone_index++;
	}
}

hotjoin_setup_player( viewmodel )
{
	if ( is_true( level.passed_introscreen ) && !isDefined( self.first_spawn ) && !isDefined( self.characterindex ) )
	{
		self.first_spawn = 1;
		self setviewmodel( viewmodel );
		return 1;
	}
	return 0;
}

is_temporary_zombie_weapon( str_weapon )
{
	if ( !is_zombie_perk_bottle( str_weapon ) && level.revive_tool != str_weapon && str_weapon != "zombie_builder_zm" && str_weapon != "chalk_draw_zm" && str_weapon != "no_hands_zm" )
	{
		return str_weapon == level.machine_assets[ "packapunch" ].weapon;
	}
}

is_gametype_active( a_gametypes )
{
	b_is_gametype_active = 0;
	if ( !isarray( a_gametypes ) )
	{
		a_gametypes = array( a_gametypes );
	}
	i = 0;
	while ( i < a_gametypes.size )
	{
		if ( getDvar( "g_gametype" ) == a_gametypes[ i ] )
		{
			b_is_gametype_active = 1;
		}
		i++;
	}
	return b_is_gametype_active;
}

is_createfx_active()
{
	if ( !isDefined( level.createfx_enabled ) )
	{
		level.createfx_enabled = getDvar( "createfx" ) != "";
	}
	return level.createfx_enabled;
}

is_zombie_perk_bottle( str_weapon )
{
	switch( str_weapon )
	{
		case "zombie_perk_bottle_additionalprimaryweapon":
		case "zombie_perk_bottle_cherry":
		case "zombie_perk_bottle_deadshot":
		case "zombie_perk_bottle_doubletap":
		case "zombie_perk_bottle_jugg":
		case "zombie_perk_bottle_marathon":
		case "zombie_perk_bottle_nuke":
		case "zombie_perk_bottle_oneinch":
		case "zombie_perk_bottle_revive":
		case "zombie_perk_bottle_sixth_sense":
		case "zombie_perk_bottle_sleight":
		case "zombie_perk_bottle_tombstone":
		case "zombie_perk_bottle_vulture":
		case "zombie_perk_bottle_whoswho":
			b_is_perk_bottle = 1;
			break;
		default:
			b_is_perk_bottle = 0;
			break;
	}
	return b_is_perk_bottle;
}

register_custom_spawner_entry( spot_noteworthy, func )
{
	if ( !isDefined( level.custom_spawner_entry ) )
	{
		level.custom_spawner_entry = [];
	}
	level.custom_spawner_entry[ spot_noteworthy ] = func;
}

get_player_weapon_limit( player )
{
	if ( isDefined( level.get_player_weapon_limit ) )
	{
		return [[ level.get_player_weapon_limit ]]( player );
	}
	weapon_limit = 2;
	if ( player hasperk( "specialty_additionalprimaryweapon" ) )
	{
		weapon_limit = level.additionalprimaryweapon_limit;
	}
	return weapon_limit;
}

get_player_perk_purchase_limit()
{
	if ( isDefined( level.get_player_perk_purchase_limit ) )
	{
		return self [[ level.get_player_perk_purchase_limit ]]();
	}
	return level.perk_purchase_limit;
}
