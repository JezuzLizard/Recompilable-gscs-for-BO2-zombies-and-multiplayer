#include maps/mp/zombies/_zm_ai_faller;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/animscripts/zm_run;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level._contextual_grab_lerp_time = 0,3;
	level.zombie_spawners = getentarray( "zombie_spawner", "script_noteworthy" );
	while ( isDefined( level.use_multiple_spawns ) && level.use_multiple_spawns )
	{
		level.zombie_spawn = [];
		i = 0;
		while ( i < level.zombie_spawners.size )
		{
			if ( isDefined( level.zombie_spawners[ i ].script_int ) )
			{
				int = level.zombie_spawners[ i ].script_int;
				if ( !isDefined( level.zombie_spawn[ int ] ) )
				{
					level.zombie_spawn[ int ] = [];
				}
				level.zombie_spawn[ int ][ level.zombie_spawn[ int ].size ] = level.zombie_spawners[ i ];
			}
			i++;
		}
	}
	precachemodel( "p6_anim_zm_barricade_board_01_upgrade" );
	precachemodel( "p6_anim_zm_barricade_board_02_upgrade" );
	precachemodel( "p6_anim_zm_barricade_board_03_upgrade" );
	precachemodel( "p6_anim_zm_barricade_board_04_upgrade" );
	precachemodel( "p6_anim_zm_barricade_board_05_upgrade" );
	precachemodel( "p6_anim_zm_barricade_board_06_upgrade" );
	while ( isDefined( level.ignore_spawner_func ) )
	{
		i = 0;
		while ( i < level.zombie_spawners.size )
		{
			ignore = [[ level.ignore_spawner_func ]]( level.zombie_spawners[ i ] );
			if ( ignore )
			{
				arrayremovevalue( level.zombie_spawners, level.zombie_spawners[ i ] );
			}
			i++;
		}
	}
	gametype = getDvar( "ui_gametype" );
	if ( !isDefined( level.attack_player_thru_boards_range ) )
	{
		level.attack_player_thru_boards_range = 109,8;
	}
	if ( isDefined( level._game_module_custom_spawn_init_func ) )
	{
		[[ level._game_module_custom_spawn_init_func ]]();
	}
	registerclientfield( "actor", "zombie_has_eyes", 1, 1, "int" );
	registerclientfield( "actor", "zombie_ragdoll_explode", 1, 1, "int" );
}

add_cusom_zombie_spawn_logic( func )
{
	if ( !isDefined( level._zombie_custom_spawn_logic ) )
	{
		level._zombie_custom_spawn_logic = [];
	}
	level._zombie_custom_spawn_logic[ level._zombie_custom_spawn_logic.size ] = func;
}

player_attacks_enemy( player, amount, type, point )
{
	team = undefined;
	if ( isDefined( self._race_team ) )
	{
		team = self._race_team;
	}
	if ( !isads( player ) )
	{
		[[ level.global_damage_func ]]( type, self.damagelocation, point, player, amount, team );
		return 0;
	}
	if ( !bullet_attack( type ) )
	{
		[[ level.global_damage_func ]]( type, self.damagelocation, point, player, amount, team );
		return 0;
	}
	[[ level.global_damage_func_ads ]]( type, self.damagelocation, point, player, amount, team );
	return 1;
}

player_attacker( attacker )
{
	if ( isplayer( attacker ) )
	{
		return 1;
	}
	return 0;
}

enemy_death_detection()
{
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		if ( !isDefined( amount ) )
		{
			continue;
		}
		else if ( !isalive( self ) || self.delayeddeath )
		{
			return;
		}
		if ( !player_attacker( attacker ) )
		{
			continue;
		}
		else
		{
			self.has_been_damaged_by_player = 1;
			self player_attacks_enemy( attacker, amount, type, point );
		}
	}
}

is_spawner_targeted_by_blocker( ent )
{
	while ( isDefined( ent.targetname ) )
	{
		targeters = getentarray( ent.targetname, "target" );
		i = 0;
		while ( i < targeters.size )
		{
			if ( targeters[ i ].targetname == "zombie_door" || targeters[ i ].targetname == "zombie_debris" )
			{
				return 1;
			}
			result = is_spawner_targeted_by_blocker( targeters[ i ] );
			if ( result )
			{
				return 1;
			}
			i++;
		}
	}
	return 0;
}

add_custom_zombie_spawn_logic( func )
{
	if ( !isDefined( level._zombie_custom_spawn_logic ) )
	{
		level._zombie_custom_spawn_logic = [];
	}
	level._zombie_custom_spawn_logic[ level._zombie_custom_spawn_logic.size ] = func;
}

zombie_spawn_init( animname_set )
{
	if ( !isDefined( animname_set ) )
	{
		animname_set = 0;
	}
	self.targetname = "zombie";
	self.script_noteworthy = undefined;
	recalc_zombie_array();
	if ( !animname_set )
	{
		self.animname = "zombie";
	}
	if ( isDefined( get_gamemode_var( "pre_init_zombie_spawn_func" ) ) )
	{
		self [[ get_gamemode_var( "pre_init_zombie_spawn_func" ) ]]();
	}
	self thread play_ambient_zombie_vocals();
	self.zmb_vocals_attack = "zmb_vocals_zombie_attack";
	self.ignoreall = 1;
	self.ignoreme = 1;
	self.allowdeath = 1;
	self.force_gib = 1;
	self.is_zombie = 1;
	self.has_legs = 1;
	self allowedstances( "stand" );
	self.zombie_damaged_by_bar_knockdown = 0;
	self.gibbed = 0;
	self.head_gibbed = 0;
	self.disablearrivals = 1;
	self.disableexits = 1;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;
	self.ignoresuppression = 1;
	self.suppressionthreshold = 1;
	self.nododgemove = 1;
	self.dontshootwhilemoving = 1;
	self.pathenemylookahead = 0;
	self.badplaceawareness = 0;
	self.chatinitialized = 0;
	self.a.disablepain = 1;
	self disable_react();
	if ( isDefined( level.zombie_health ) )
	{
		self.maxhealth = level.zombie_health;
		if ( isDefined( level.zombie_respawned_health ) && level.zombie_respawned_health.size > 0 )
		{
			self.health = level.zombie_respawned_health[ 0 ];
			arrayremovevalue( level.zombie_respawned_health, level.zombie_respawned_health[ 0 ] );
		}
		else
		{
			self.health = level.zombie_health;
		}
	}
	else
	{
		self.maxhealth = level.zombie_vars[ "zombie_health_start" ];
		self.health = self.maxhealth;
	}
	self.freezegun_damage = 0;
	self.dropweapon = 0;
	level thread zombie_death_event( self );
	self init_zombie_run_cycle();
	self thread zombie_think();
	self thread zombie_gib_on_damage();
	self thread zombie_damage_failsafe();
	self thread enemy_death_detection();
	if ( isDefined( level._zombie_custom_spawn_logic ) )
	{
		if ( isarray( level._zombie_custom_spawn_logic ) )
		{
			i = 0;
			while ( i < level._zombie_custom_spawn_logic.size )
			{
				self thread [[ level._zombie_custom_spawn_logic[ i ] ]]();
				i++;
			}
		}
		else self thread [[ level._zombie_custom_spawn_logic ]]();
	}
	if ( !isDefined( self.no_eye_glow ) || !self.no_eye_glow )
	{
		if ( isDefined( self.is_inert ) && !self.is_inert )
		{
			self thread delayed_zombie_eye_glow();
		}
	}
	self.deathfunction = ::zombie_death_animscript;
	self.flame_damage_time = 0;
	self.meleedamage = 60;
	self.no_powerups = 1;
	self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );
	self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
	self.tesla_head_gib_func = ::zombie_tesla_head_gib;
	self.team = level.zombie_team;
	if ( isDefined( level.achievement_monitor_func ) )
	{
		self [[ level.achievement_monitor_func ]]();
	}
	if ( isDefined( get_gamemode_var( "post_init_zombie_spawn_func" ) ) )
	{
		self [[ get_gamemode_var( "post_init_zombie_spawn_func" ) ]]();
	}
	if ( isDefined( level.zombie_init_done ) )
	{
		self [[ level.zombie_init_done ]]();
	}
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
}

delayed_zombie_eye_glow()
{
	self endon( "zombie_delete" );
	if ( isDefined( self.in_the_ground ) && self.in_the_ground )
	{
		while ( !isDefined( self.create_eyes ) )
		{
			wait 0,1;
		}
	}
	else wait 0,5;
	self zombie_eye_glow();
}

zombie_damage_failsafe()
{
	self endon( "death" );
	continue_failsafe_damage = 0;
	while ( 1 )
	{
		wait 0,5;
		if ( !isDefined( self.enemy ) || !isplayer( self.enemy ) )
		{
			continue;
		}
		if ( self istouching( self.enemy ) )
		{
			old_org = self.origin;
			if ( !continue_failsafe_damage )
			{
				wait 5;
			}
			while ( isDefined( self.enemy ) || !isplayer( self.enemy ) && self.enemy hasperk( "specialty_armorvest" ) )
			{
				continue;
			}
			if ( self istouching( self.enemy ) && !self.enemy maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isalive( self.enemy ) )
			{
				if ( distancesquared( old_org, self.origin ) < 3600 )
				{
					self.enemy dodamage( self.enemy.health + 1000, self.enemy.origin, self, self, "none", "MOD_RIFLE_BULLET" );
					continue_failsafe_damage = 1;
				}
			}
			continue;
		}
		else
		{
			continue_failsafe_damage = 0;
		}
	}
}

should_skip_teardown( find_flesh_struct_string )
{
	if ( isDefined( find_flesh_struct_string ) && find_flesh_struct_string == "find_flesh" )
	{
		return 1;
	}
	if ( isDefined( self.script_string ) && self.script_string == "zombie_chaser" )
	{
		return 1;
	}
	return 0;
}

zombie_think()
{
	self endon( "death" );
/#
	assert( !self.isdog );
#/
	self.ai_state = "zombie_think";
	find_flesh_struct_string = undefined;
	if ( isDefined( level.zombie_custom_think_logic ) )
	{
		shouldwait = self [[ level.zombie_custom_think_logic ]]();
		if ( shouldwait )
		{
			self waittill( "zombie_custom_think_done", find_flesh_struct_string );
		}
	}
	else if ( isDefined( self.start_inert ) && self.start_inert )
	{
		find_flesh_struct_string = "find_flesh";
	}
	else
	{
		if ( isDefined( self.custom_location ) )
		{
			self thread [[ self.custom_location ]]();
		}
		else
		{
			self thread do_zombie_spawn();
		}
		self waittill( "risen", find_flesh_struct_string );
	}
	node = undefined;
	desired_nodes = [];
	self.entrance_nodes = [];
	if ( isDefined( level.max_barrier_search_dist_override ) )
	{
		max_dist = level.max_barrier_search_dist_override;
	}
	else
	{
		max_dist = 500;
	}
	if ( !isDefined( find_flesh_struct_string ) && isDefined( self.target ) && self.target != "" )
	{
		desired_origin = get_desired_origin();
/#
		assert( isDefined( desired_origin ), "Spawner @ " + self.origin + " has a .target but did not find a target" );
#/
		origin = desired_origin;
		node = getclosest( origin, level.exterior_goals );
		self.entrance_nodes[ self.entrance_nodes.size ] = node;
		self zombie_history( "zombie_think -> #1 entrance (script_forcegoal) origin = " + self.entrance_nodes[ 0 ].origin );
	}
	else
	{
		if ( self should_skip_teardown( find_flesh_struct_string ) )
		{
			self zombie_setup_attack_properties();
			if ( isDefined( self.target ) )
			{
				end_at_node = getnode( self.target, "targetname" );
				if ( isDefined( end_at_node ) )
				{
					self setgoalnode( end_at_node );
					self waittill( "goal" );
				}
			}
			if ( isDefined( self.start_inert ) && self.start_inert )
			{
				self thread maps/mp/zombies/_zm_ai_basic::start_inert( 1 );
				self zombie_complete_emerging_into_playable_area();
			}
			else
			{
				self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
				self thread zombie_entered_playable();
			}
			return;
		}
		else if ( isDefined( find_flesh_struct_string ) )
		{
/#
			assert( isDefined( find_flesh_struct_string ) );
#/
			i = 0;
			while ( i < level.exterior_goals.size )
			{
				if ( level.exterior_goals[ i ].script_string == find_flesh_struct_string )
				{
					node = level.exterior_goals[ i ];
					break;
				}
				else
				{
					i++;
				}
			}
			self.entrance_nodes[ self.entrance_nodes.size ] = node;
			self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );
			self thread zombie_assure_node();
		}
		else
		{
			origin = self.origin;
			desired_origin = get_desired_origin();
			if ( isDefined( desired_origin ) )
			{
				origin = desired_origin;
			}
			nodes = get_array_of_closest( origin, level.exterior_goals, undefined, 3 );
			desired_nodes[ 0 ] = nodes[ 0 ];
			prev_dist = distance( self.origin, nodes[ 0 ].origin );
			i = 1;
			while ( i < nodes.size )
			{
				dist = distance( self.origin, nodes[ i ].origin );
				if ( ( dist - prev_dist ) > max_dist )
				{
					break;
				}
				else
				{
					prev_dist = dist;
					desired_nodes[ i ] = nodes[ i ];
					i++;
				}
			}
			node = desired_nodes[ 0 ];
			if ( desired_nodes.size > 1 )
			{
				node = desired_nodes[ randomint( desired_nodes.size ) ];
			}
			self.entrance_nodes = desired_nodes;
			self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );
			self thread zombie_assure_node();
		}
	}
/#
	assert( isDefined( node ), "Did not find a node!!! [Should not see this!]" );
#/
	level thread draw_line_ent_to_pos( self, node.origin, "goal" );
	self.first_node = node;
	self thread zombie_goto_entrance( node );
}

zombie_entered_playable()
{
	self endon( "death" );
	if ( !isDefined( level.playable_areas ) )
	{
		level.playable_areas = getentarray( "player_volume", "script_noteworthy" );
	}
	while ( 1 )
	{
		_a611 = level.playable_areas;
		_k611 = getFirstArrayKey( _a611 );
		while ( isDefined( _k611 ) )
		{
			area = _a611[ _k611 ];
			if ( self istouching( area ) )
			{
				self zombie_complete_emerging_into_playable_area();
				return;
			}
			_k611 = getNextArrayKey( _a611, _k611 );
		}
		wait 1;
	}
}

get_desired_origin()
{
	if ( isDefined( self.target ) )
	{
		ent = getent( self.target, "targetname" );
		if ( !isDefined( ent ) )
		{
			ent = getstruct( self.target, "targetname" );
		}
		if ( !isDefined( ent ) )
		{
			ent = getnode( self.target, "targetname" );
		}
/#
		assert( isDefined( ent ), "Cannot find the targeted ent/node/struct, "" + self.target + "" at " + self.origin );
#/
		return ent.origin;
	}
	return undefined;
}

zombie_goto_entrance( node, endon_bad_path )
{
/#
	assert( !self.isdog );
#/
	self endon( "death" );
	self endon( "stop_zombie_goto_entrance" );
	level endon( "intermission" );
	self.ai_state = "zombie_goto_entrance";
	if ( isDefined( endon_bad_path ) && endon_bad_path )
	{
		self endon( "bad_path" );
	}
	self zombie_history( "zombie_goto_entrance -> start goto entrance " + node.origin );
	self.got_to_entrance = 0;
	self.goalradius = 128;
	self setgoalpos( node.origin );
	self waittill( "goal" );
	self.got_to_entrance = 1;
	self zombie_history( "zombie_goto_entrance -> reached goto entrance " + node.origin );
	self tear_into_building();
	if ( isDefined( level.pre_aggro_pathfinding_func ) )
	{
		self [[ level.pre_aggro_pathfinding_func ]]();
	}
	barrier_pos = [];
	barrier_pos[ 0 ] = "m";
	barrier_pos[ 1 ] = "r";
	barrier_pos[ 2 ] = "l";
	self.barricade_enter = 1;
	animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_barricade_enter" );
	substate = "barrier_" + self.zombie_move_speed + "_" + barrier_pos[ self.attacking_spot_index ];
	self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, animstate, substate );
	maps/mp/animscripts/zm_shared::donotetracks( "barricade_enter_anim" );
	self zombie_setup_attack_properties();
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	self.pathenemyfightdist = 4;
	self zombie_complete_emerging_into_playable_area();
	self.pathenemyfightdist = 64;
	self.barricade_enter = 0;
}

zombie_assure_node()
{
	self endon( "death" );
	self endon( "goal" );
	level endon( "intermission" );
	start_pos = self.origin;
	while ( isDefined( self.entrance_nodes ) )
	{
		i = 0;
		while ( i < self.entrance_nodes.size )
		{
			if ( self zombie_bad_path() )
			{
				self zombie_history( "zombie_assure_node -> assigned assured node = " + self.entrance_nodes[ i ].origin );
/#
				println( "^1Zombie @ " + self.origin + " did not move for 1 second. Going to next closest node @ " + self.entrance_nodes[ i ].origin );
#/
				level thread draw_line_ent_to_pos( self, self.entrance_nodes[ i ].origin, "goal" );
				self.first_node = self.entrance_nodes[ i ];
				self setgoalpos( self.entrance_nodes[ i ].origin );
				i++;
				continue;
			}
			else
			{
				return;
			}
			i++;
		}
	}
	wait 2;
	nodes = get_array_of_closest( self.origin, level.exterior_goals, undefined, 20 );
	while ( isDefined( nodes ) )
	{
		self.entrance_nodes = nodes;
		i = 0;
		while ( i < self.entrance_nodes.size )
		{
			if ( self zombie_bad_path() )
			{
				self zombie_history( "zombie_assure_node -> assigned assured node = " + self.entrance_nodes[ i ].origin );
/#
				println( "^1Zombie @ " + self.origin + " did not move for 1 second. Going to next closest node @ " + self.entrance_nodes[ i ].origin );
#/
				level thread draw_line_ent_to_pos( self, self.entrance_nodes[ i ].origin, "goal" );
				self.first_node = self.entrance_nodes[ i ];
				self setgoalpos( self.entrance_nodes[ i ].origin );
				i++;
				continue;
			}
			else
			{
				return;
			}
			i++;
		}
	}
	self zombie_history( "zombie_assure_node -> failed to find a good entrance point" );
	wait 20;
	self dodamage( self.health + 10, self.origin );
	level.zombies_timeout_spawn++;
}

zombie_bad_path()
{
	self endon( "death" );
	self endon( "goal" );
	self thread zombie_bad_path_notify();
	self thread zombie_bad_path_timeout();
	self.zombie_bad_path = undefined;
	while ( !isDefined( self.zombie_bad_path ) )
	{
		wait 0,05;
	}
	self notify( "stop_zombie_bad_path" );
	return self.zombie_bad_path;
}

zombie_bad_path_notify()
{
	self endon( "death" );
	self endon( "stop_zombie_bad_path" );
	self waittill( "bad_path" );
	self.zombie_bad_path = 1;
}

zombie_bad_path_timeout()
{
	self endon( "death" );
	self endon( "stop_zombie_bad_path" );
	wait 2;
	self.zombie_bad_path = 0;
}

tear_into_building()
{
	self endon( "death" );
	self endon( "teleporting" );
	self zombie_history( "tear_into_building -> start" );
	while ( 1 )
	{
		if ( isDefined( self.first_node.script_noteworthy ) )
		{
			if ( self.first_node.script_noteworthy == "no_blocker" )
			{
				return;
			}
		}
		if ( !isDefined( self.first_node.target ) )
		{
			return;
		}
		if ( all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
		{
			self zombie_history( "tear_into_building -> all chunks destroyed" );
		}
		while ( !get_attack_spot( self.first_node ) )
		{
			self zombie_history( "tear_into_building -> Could not find an attack spot" );
			self thread do_a_taunt();
			wait 0,5;
		}
		self.goalradius = 2;
		angles = self.first_node.zbarrier.angles;
		self setgoalpos( self.attacking_spot, angles );
		self waittill( "goal" );
		self waittill_notify_or_timeout( "orientdone", 1 );
		self zombie_history( "tear_into_building -> Reach position and orientated" );
		if ( all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
		{
			self zombie_history( "tear_into_building -> all chunks destroyed" );
			i = 0;
			while ( i < self.first_node.attack_spots_taken.size )
			{
				self.first_node.attack_spots_taken[ i ] = 0;
				i++;
			}
			return;
		}
		while ( 1 )
		{
			if ( isDefined( self.zombie_board_tear_down_callback ) )
			{
				self [[ self.zombie_board_tear_down_callback ]]();
			}
			chunk = get_closest_non_destroyed_chunk( self.origin, self.first_node, self.first_node.barrier_chunks );
			if ( !isDefined( chunk ) )
			{
				while ( !all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
				{
					attack = self should_attack_player_thru_boards();
					if ( isDefined( attack ) && !attack && self.has_legs )
					{
						self do_a_taunt();
						continue;
					}
					else
					{
						wait 0,1;
					}
				}
				i = 0;
				while ( i < self.first_node.attack_spots_taken.size )
				{
					self.first_node.attack_spots_taken[ i ] = 0;
					i++;
				}
				return;
			}
			self zombie_history( "tear_into_building -> animating" );
			self.first_node.zbarrier setzbarrierpiecestate( chunk, "targetted_by_zombie" );
			self.first_node thread check_zbarrier_piece_for_zombie_inert( chunk, self.first_node.zbarrier, self );
			self.first_node thread check_zbarrier_piece_for_zombie_death( chunk, self.first_node.zbarrier, self );
			self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "teardown", self.animname );
			animstatebase = self.first_node.zbarrier getzbarrierpieceanimstate( chunk );
			animsubstate = "spot_" + self.attacking_spot_index + "_piece_" + self.first_node.zbarrier getzbarrierpieceanimsubstate( chunk );
			anim_sub_index = self getanimsubstatefromasd( animstatebase + "_in", animsubstate );
			self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, maps/mp/animscripts/zm_utility::append_missing_legs_suffix( animstatebase + "_in" ), anim_sub_index );
			self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
			while ( self.first_node.zbarrier.chunk_health[ chunk ] >= 0 )
			{
				self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, maps/mp/animscripts/zm_utility::append_missing_legs_suffix( animstatebase + "_loop" ), anim_sub_index );
				self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
				self.first_node.zbarrier.chunk_health[ chunk ]--;

			}
			self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, maps/mp/animscripts/zm_utility::append_missing_legs_suffix( animstatebase + "_out" ), anim_sub_index );
			self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
			self.lastchunk_destroy_time = getTime();
			attack = self should_attack_player_thru_boards();
			if ( isDefined( attack ) && !attack && self.has_legs )
			{
				self do_a_taunt();
			}
			if ( all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
			{
				i = 0;
				while ( i < self.first_node.attack_spots_taken.size )
				{
					self.first_node.attack_spots_taken[ i ] = 0;
					i++;
				}
				return;
			}
		}
		self reset_attack_spot();
	}
}

do_a_taunt()
{
	self endon( "death" );
	if ( !self.has_legs )
	{
		return 0;
	}
	if ( !self.first_node.zbarrier zbarriersupportszombietaunts() )
	{
		return;
	}
	self.old_origin = self.origin;
	if ( getDvar( "zombie_taunt_freq" ) == "" )
	{
		setdvar( "zombie_taunt_freq", "5" );
	}
	freq = getDvarInt( "zombie_taunt_freq" );
	if ( freq >= randomint( 100 ) )
	{
		self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "taunt", self.animname );
		tauntstate = "zm_taunt";
		if ( isDefined( self.first_node.zbarrier ) && self.first_node.zbarrier getzbarriertauntanimstate() != "" )
		{
			tauntstate = self.first_node.zbarrier getzbarriertauntanimstate();
		}
		self animscripted( self.origin, self.angles, tauntstate );
		self taunt_notetracks( "taunt_anim" );
	}
}

taunt_notetracks( msg )
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( msg, notetrack );
		if ( notetrack == "end" )
		{
			self forceteleport( self.old_origin );
			return;
		}
	}
}

should_attack_player_thru_boards()
{
	if ( !self.has_legs )
	{
		return 0;
	}
	if ( isDefined( self.first_node.zbarrier ) )
	{
		if ( !self.first_node.zbarrier zbarriersupportszombiereachthroughattacks() )
		{
			return 0;
		}
	}
	if ( getDvar( "zombie_reachin_freq" ) == "" )
	{
		setdvar( "zombie_reachin_freq", "50" );
	}
	freq = getDvarInt( "zombie_reachin_freq" );
	players = get_players();
	attack = 0;
	self.player_targets = [];
	i = 0;
	while ( i < players.size )
	{
		if ( isalive( players[ i ] ) && !isDefined( players[ i ].revivetrigger ) && distance2d( self.origin, players[ i ].origin ) <= level.attack_player_thru_boards_range )
		{
			self.player_targets[ self.player_targets.size ] = players[ i ];
			attack = 1;
		}
		i++;
	}
	if ( !attack || freq < randomint( 100 ) )
	{
		return 0;
	}
	self.old_origin = self.origin;
	attackanimstate = "zm_window_melee";
	if ( isDefined( self.first_node.zbarrier ) && self.first_node.zbarrier getzbarrierreachthroughattackanimstate() != "" )
	{
		attackanimstate = self.first_node.zbarrier getzbarrierreachthroughattackanimstate();
	}
	self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "attack", self.animname );
	self animscripted( self.origin, self.angles, attackanimstate, self.attacking_spot_index - 1 );
	self window_notetracks( "window_melee_anim" );
	return 1;
}

window_notetracks( msg )
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( msg, notetrack );
		if ( notetrack == "end" )
		{
			self teleport( self.old_origin );
			return;
		}
		if ( notetrack == "fire" )
		{
			if ( self.ignoreall )
			{
				self.ignoreall = 0;
			}
			if ( isDefined( self.first_node ) )
			{
				_melee_dist_sq = 8100;
				if ( isDefined( level.attack_player_thru_boards_range ) )
				{
					_melee_dist_sq = level.attack_player_thru_boards_range * level.attack_player_thru_boards_range;
				}
				_trigger_dist_sq = 2601;
				i = 0;
				while ( i < self.player_targets.size )
				{
					playerdistsq = distance2dsquared( self.player_targets[ i ].origin, self.origin );
					heightdiff = abs( self.player_targets[ i ].origin[ 2 ] - self.origin[ 2 ] );
					if ( playerdistsq < _melee_dist_sq && ( heightdiff * heightdiff ) < _melee_dist_sq )
					{
						triggerdistsq = distance2dsquared( self.player_targets[ i ].origin, self.first_node.trigger_location.origin );
						heightdiff = abs( self.player_targets[ i ].origin[ 2 ] - self.first_node.trigger_location.origin[ 2 ] );
						if ( triggerdistsq < _trigger_dist_sq && ( heightdiff * heightdiff ) < _trigger_dist_sq )
						{
							self.player_targets[ i ] dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
							break;
						}
					}
					else
					{
						i++;
					}
				}
			}
			else self melee();
		}
	}
}

reset_attack_spot()
{
	if ( isDefined( self.attacking_node ) )
	{
		node = self.attacking_node;
		index = self.attacking_spot_index;
		node.attack_spots_taken[ index ] = 0;
		self.attacking_node = undefined;
		self.attacking_spot_index = undefined;
	}
}

get_attack_spot( node )
{
	index = get_attack_spot_index( node );
	if ( !isDefined( index ) )
	{
		return 0;
	}
	self.attacking_node = node;
	self.attacking_spot_index = index;
	node.attack_spots_taken[ index ] = 1;
	self.attacking_spot = node.attack_spots[ index ];
	return 1;
}

get_attack_spot_index( node )
{
	indexes = [];
	i = 0;
	while ( i < node.attack_spots.size )
	{
		if ( !node.attack_spots_taken[ i ] )
		{
			indexes[ indexes.size ] = i;
		}
		i++;
	}
	if ( indexes.size == 0 )
	{
		return undefined;
	}
	return indexes[ randomint( indexes.size ) ];
}

zombie_tear_notetracks( msg, chunk, node )
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( msg, notetrack );
		if ( notetrack == "end" )
		{
			return;
		}
		if ( notetrack != "board" || notetrack == "destroy_piece" && notetrack == "bar" )
		{
			node.zbarrier setzbarrierpiecestate( chunk, "opening" );
		}
	}
}

zombie_boardtear_offset_fx_horizontle( chunk, node )
{
	if ( isDefined( chunk.script_parameters ) || chunk.script_parameters == "repair_board" && chunk.script_parameters == "board" )
	{
		if ( isDefined( chunk.unbroken ) && chunk.unbroken == 1 )
		{
			if ( isDefined( chunk.material ) && chunk.material == "glass" )
			{
				playfx( level._effect[ "glass_break" ], chunk.origin, node.angles );
				chunk.unbroken = 0;
			}
			else
			{
				if ( isDefined( chunk.material ) && chunk.material == "metal" )
				{
					playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin );
					chunk.unbroken = 0;
				}
				else
				{
					if ( isDefined( chunk.material ) && chunk.material == "rock" )
					{
						if ( isDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
						{
							chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
						}
						else
						{
							playfx( level._effect[ "wall_break" ], chunk.origin );
						}
						chunk.unbroken = 0;
					}
				}
			}
		}
	}
	if ( isDefined( chunk.script_parameters ) && chunk.script_parameters == "barricade_vents" )
	{
		if ( isDefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
		{
			chunk setclientflag( level._zombie_scriptmover_flag_board_horizontal_fx );
		}
		else
		{
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin );
		}
	}
	else
	{
		if ( isDefined( chunk.material ) && chunk.material == "rock" )
		{
			if ( isDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
			{
				chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
			}
			return;
		}
		else
		{
			if ( isDefined( level.use_clientside_board_fx ) )
			{
				chunk setclientflag( level._zombie_scriptmover_flag_board_horizontal_fx );
				return;
			}
			else
			{
				playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( 0, 0, 0 ), 30 ) );
				wait randomfloatrange( 0,2, 0,4 );
				playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( 0, 0, 0 ), 30 ) );
			}
		}
	}
}

zombie_boardtear_offset_fx_verticle( chunk, node )
{
	if ( isDefined( chunk.script_parameters ) || chunk.script_parameters == "repair_board" && chunk.script_parameters == "board" )
	{
		if ( isDefined( chunk.unbroken ) && chunk.unbroken == 1 )
		{
			if ( isDefined( chunk.material ) && chunk.material == "glass" )
			{
				playfx( level._effect[ "glass_break" ], chunk.origin, node.angles );
				chunk.unbroken = 0;
			}
			else
			{
				if ( isDefined( chunk.material ) && chunk.material == "metal" )
				{
					playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin );
					chunk.unbroken = 0;
				}
				else
				{
					if ( isDefined( chunk.material ) && chunk.material == "rock" )
					{
						if ( isDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
						{
							chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
						}
						else
						{
							playfx( level._effect[ "wall_break" ], chunk.origin );
						}
						chunk.unbroken = 0;
					}
				}
			}
		}
	}
	if ( isDefined( chunk.script_parameters ) && chunk.script_parameters == "barricade_vents" )
	{
		if ( isDefined( level.use_clientside_board_fx ) )
		{
			chunk setclientflag( level._zombie_scriptmover_flag_board_vertical_fx );
		}
		else
		{
			playfx( level._effect[ "fx_zombie_bar_break" ], chunk.origin );
		}
	}
	else
	{
		if ( isDefined( chunk.material ) && chunk.material == "rock" )
		{
			if ( isDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
			{
				chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
			}
			return;
		}
		else
		{
			if ( isDefined( level.use_clientside_board_fx ) )
			{
				chunk setclientflag( level._zombie_scriptmover_flag_board_vertical_fx );
				return;
			}
			else
			{
				playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( 0, 0, 0 ), 30 ) );
				wait randomfloatrange( 0,2, 0,4 );
				playfx( level._effect[ "wood_chunk_destory" ], chunk.origin + vectorScale( ( 0, 0, 0 ), 30 ) );
			}
		}
	}
}

zombie_bartear_offset_fx_verticle( chunk )
{
	if ( isDefined( chunk.script_parameters ) || chunk.script_parameters == "bar" && chunk.script_noteworthy == "board" )
	{
		possible_tag_array_1 = [];
		possible_tag_array_1[ 0 ] = "Tag_fx_top";
		possible_tag_array_1[ 1 ] = "";
		possible_tag_array_1[ 2 ] = "Tag_fx_top";
		possible_tag_array_1[ 3 ] = "";
		possible_tag_array_2 = [];
		possible_tag_array_2[ 0 ] = "";
		possible_tag_array_2[ 1 ] = "Tag_fx_bottom";
		possible_tag_array_2[ 2 ] = "";
		possible_tag_array_2[ 3 ] = "Tag_fx_bottom";
		possible_tag_array_2 = array_randomize( possible_tag_array_2 );
		random_fx = [];
		random_fx[ 0 ] = level._effect[ "fx_zombie_bar_break" ];
		random_fx[ 1 ] = level._effect[ "fx_zombie_bar_break_lite" ];
		random_fx[ 2 ] = level._effect[ "fx_zombie_bar_break" ];
		random_fx[ 3 ] = level._effect[ "fx_zombie_bar_break_lite" ];
		random_fx = array_randomize( random_fx );
		switch( randomint( 9 ) )
		{
			case 0:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
				break;
			return;
			case 1:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_top" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_bottom" );
				break;
			return;
			case 2:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_bottom" );
				break;
			return;
			case 3:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_top" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
				break;
			return;
			case 4:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
				break;
			return;
			case 5:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_top" );
				break;
			return;
			case 6:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_bottom" );
				break;
			return;
			case 7:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_top" );
				break;
			return;
			case 8:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_bottom" );
				break;
			return;
		}
	}
}

zombie_bartear_offset_fx_horizontle( chunk )
{
	if ( isDefined( chunk.script_parameters ) || chunk.script_parameters == "bar" && chunk.script_noteworthy == "board" )
	{
		switch( randomint( 10 ) )
		{
			case 0:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 1:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_left" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 2:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 3:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_left" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 4:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
				wait randomfloatrange( 0, 0,3 );
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 5:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_left" );
				break;
			return;
			case 6:
				playfxontag( level._effect[ "fx_zombie_bar_break_lite" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 7:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
				break;
			return;
			case 8:
				playfxontag( level._effect[ "fx_zombie_bar_break" ], chunk, "Tag_fx_right" );
				break;
			return;
		}
	}
}

check_zbarrier_piece_for_zombie_inert( chunk_index, zbarrier, zombie )
{
	zombie endon( "completed_emerging_into_playable_area" );
	zombie waittill( "stop_zombie_goto_entrance" );
	if ( zbarrier getzbarrierpiecestate( chunk_index ) == "targetted_by_zombie" )
	{
		zbarrier setzbarrierpiecestate( chunk_index, "closed" );
	}
}

check_zbarrier_piece_for_zombie_death( chunk_index, zbarrier, zombie )
{
	while ( 1 )
	{
		if ( zbarrier getzbarrierpiecestate( chunk_index ) != "targetted_by_zombie" )
		{
			return;
		}
		if ( !isDefined( zombie ) || !isalive( zombie ) )
		{
			zbarrier setzbarrierpiecestate( chunk_index, "closed" );
			return;
		}
		wait 0,05;
	}
}

check_for_zombie_death( zombie )
{
	self endon( "destroyed" );
	wait 2,5;
	self maps/mp/zombies/_zm_blockers::update_states( "repaired" );
}

zombie_head_gib( attacker, means_of_death )
{
	self endon( "death" );
	if ( !is_mature() )
	{
		return 0;
	}
	if ( isDefined( self.head_gibbed ) && self.head_gibbed )
	{
		return;
	}
	self.head_gibbed = 1;
	self zombie_eye_glow_stop();
	size = self getattachsize();
	i = 0;
	while ( i < size )
	{
		model = self getattachmodelname( i );
		if ( issubstr( model, "head" ) )
		{
			if ( isDefined( self.hatmodel ) )
			{
				self detach( self.hatmodel, "" );
			}
			self play_sound_on_ent( "zombie_head_gib" );
			self detach( model, "" );
			if ( isDefined( self.torsodmg5 ) )
			{
				self attach( self.torsodmg5, "", 1 );
			}
			break;
		}
		else
		{
			i++;
		}
	}
	temp_array = [];
	temp_array[ 0 ] = level._zombie_gib_piece_index_head;
	self gib( "normal", temp_array );
	if ( isDefined( level.track_gibs ) )
	{
		level [[ level.track_gibs ]]( self, temp_array );
	}
	self thread damage_over_time( ceil( self.health * 0,2 ), 1, attacker, means_of_death );
}

damage_over_time( dmg, delay, attacker, means_of_death )
{
	self endon( "death" );
	self endon( "exploding" );
	if ( !isalive( self ) )
	{
		return;
	}
	if ( !isplayer( attacker ) )
	{
		attacker = self;
	}
	if ( !isDefined( means_of_death ) )
	{
		means_of_death = "MOD_UNKNOWN";
	}
	while ( 1 )
	{
		if ( isDefined( delay ) )
		{
			wait delay;
		}
		if ( isDefined( self ) )
		{
			self dodamage( dmg, self gettagorigin( "j_neck" ), attacker, self, self.damagelocation, means_of_death, 0, self.damageweapon );
		}
	}
}

head_should_gib( attacker, type, point )
{
	if ( !is_mature() )
	{
		return 0;
	}
	if ( self.head_gibbed )
	{
		return 0;
	}
	if ( !isDefined( attacker ) || !isplayer( attacker ) )
	{
		return 0;
	}
	low_health_percent = ( self.health / self.maxhealth ) * 100;
	if ( low_health_percent > 10 )
	{
		return 0;
	}
	weapon = attacker getcurrentweapon();
	if ( type != "MOD_RIFLE_BULLET" && type != "MOD_PISTOL_BULLET" )
	{
		if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
		{
			if ( distance( point, self gettagorigin( "j_head" ) ) > 55 )
			{
				return 0;
			}
			else
			{
				return 1;
			}
		}
		else
		{
			if ( type == "MOD_PROJECTILE" )
			{
				if ( distance( point, self gettagorigin( "j_head" ) ) > 10 )
				{
					return 0;
				}
				else
				{
					return 1;
				}
			}
			else
			{
				if ( weaponclass( weapon ) != "spread" )
				{
					return 0;
				}
			}
		}
	}
	if ( !self maps/mp/animscripts/zm_utility::damagelocationisany( "head", "helmet", "neck" ) )
	{
		return 0;
	}
	if ( weapon != "none" || weapon == level.start_weapon && weaponisgasweapon( self.weapon ) )
	{
		return 0;
	}
	return 1;
}

headshot_blood_fx()
{
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !is_mature() )
	{
		return;
	}
	fxtag = "j_neck";
	fxorigin = self gettagorigin( fxtag );
	upvec = anglesToUp( self gettagangles( fxtag ) );
	forwardvec = anglesToForward( self gettagangles( fxtag ) );
	playfx( level._effect[ "headshot" ], fxorigin, forwardvec, upvec );
	playfx( level._effect[ "headshot_nochunks" ], fxorigin, forwardvec, upvec );
	wait 0,3;
	if ( isDefined( self ) )
	{
		playfxontag( level._effect[ "bloodspurt" ], self, fxtag );
	}
}

zombie_gib_on_damage()
{
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, tagname, modelname, partname, weaponname );
		if ( !isDefined( self ) )
		{
			return;
		}
		while ( !self zombie_should_gib( amount, attacker, type ) )
		{
			continue;
		}
		while ( self head_should_gib( attacker, type, point ) && type != "MOD_BURNED" )
		{
			self zombie_head_gib( attacker, type );
		}
		if ( !self.gibbed )
		{
			while ( self maps/mp/animscripts/zm_utility::damagelocationisany( "head", "helmet", "neck" ) )
			{
				continue;
			}
			refs = [];
			switch( self.damagelocation )
			{
				case "torso_lower":
				case "torso_upper":
					refs[ refs.size ] = "guts";
					refs[ refs.size ] = "right_arm";
					break;
				case "right_arm_lower":
				case "right_arm_upper":
				case "right_hand":
					refs[ refs.size ] = "right_arm";
					break;
				case "left_arm_lower":
				case "left_arm_upper":
				case "left_hand":
					refs[ refs.size ] = "left_arm";
					break;
				case "right_foot":
				case "right_leg_lower":
				case "right_leg_upper":
					if ( self.health <= 0 )
					{
						refs[ refs.size ] = "right_leg";
						refs[ refs.size ] = "right_leg";
						refs[ refs.size ] = "right_leg";
						refs[ refs.size ] = "no_legs";
					}
					break;
				case "left_foot":
				case "left_leg_lower":
				case "left_leg_upper":
					if ( self.health <= 0 )
					{
						refs[ refs.size ] = "left_leg";
						refs[ refs.size ] = "left_leg";
						refs[ refs.size ] = "left_leg";
						refs[ refs.size ] = "no_legs";
					}
					break;
				default:
					if ( self.damagelocation == "none" )
					{
						if ( type != "MOD_GRENADE" && type != "MOD_GRENADE_SPLASH" || type == "MOD_PROJECTILE" && type == "MOD_PROJECTILE_SPLASH" )
						{
							refs = self derive_damage_refs( point );
							break;
					}
					else }
				else refs[ refs.size ] = "guts";
				refs[ refs.size ] = "right_arm";
				refs[ refs.size ] = "left_arm";
				refs[ refs.size ] = "right_leg";
				refs[ refs.size ] = "left_leg";
				refs[ refs.size ] = "no_legs";
				break;
		}
		if ( isDefined( level.custom_derive_damage_refs ) )
		{
			new_gib_ref = self [[ level.custom_derive_damage_refs ]]( point, weaponname );
			if ( new_gib_ref.size > 0 )
			{
				refs = new_gib_ref;
			}
		}
		if ( refs.size )
		{
			self.a.gib_ref = maps/mp/animscripts/zm_death::get_random( refs );
			if ( self.a.gib_ref != "no_legs" && self.a.gib_ref != "right_leg" && self.a.gib_ref == "left_leg" && self.health > 0 )
			{
				self.has_legs = 0;
				self allowedstances( "crouch" );
				self setphysparams( 15, 0, 24 );
				self allowpitchangle( 1 );
				self setpitchorient();
				health = self.health;
				health *= 0,1;
				self thread maps/mp/animscripts/zm_run::needsdelayedupdate();
				if ( isDefined( self.crawl_anim_override ) )
				{
					self [[ self.crawl_anim_override ]]();
				}
			}
		}
		if ( self.health > 0 )
		{
			self thread maps/mp/animscripts/zm_death::do_gib();
			if ( isDefined( level.gib_on_damage ) )
			{
				self thread [[ level.gib_on_damage ]]();
			}
		}
	}
}
}

zombie_should_gib( amount, attacker, type )
{
	if ( !is_mature() )
	{
		return 0;
	}
	if ( !isDefined( type ) )
	{
		return 0;
	}
	if ( isDefined( self.is_on_fire ) && self.is_on_fire )
	{
		return 0;
	}
	if ( isDefined( self.no_gib ) && self.no_gib == 1 )
	{
		return 0;
	}
	switch( type )
	{
		case "MOD_BURNED":
		case "MOD_CRUSH":
		case "MOD_FALLING":
		case "MOD_SUICIDE":
		case "MOD_TELEFRAG":
		case "MOD_TRIGGER_HURT":
		case "MOD_UNKNOWN":
			return 0;
		case "MOD_MELEE":
			return 0;
	}
	if ( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" )
	{
		if ( !isDefined( attacker ) || !isplayer( attacker ) )
		{
			return 0;
		}
		weapon = attacker getcurrentweapon();
		if ( weapon == "none" || weapon == level.start_weapon )
		{
			return 0;
		}
		if ( weaponisgasweapon( self.weapon ) )
		{
			return 0;
		}
	}
	else
	{
		if ( type == "MOD_PROJECTILE" )
		{
			if ( isDefined( attacker ) && isplayer( attacker ) )
			{
				weapon = attacker getcurrentweapon();
				if ( weapon == "slipgun_zm" || weapon == "slipgun_upgraded_zm" )
				{
					return 0;
				}
			}
		}
	}
	prev_health = amount + self.health;
	if ( prev_health <= 0 )
	{
		prev_health = 1;
	}
	damage_percent = ( amount / prev_health ) * 100;
	if ( damage_percent < 10 )
	{
		return 0;
	}
	return 1;
}

derive_damage_refs( point )
{
	if ( !isDefined( level.gib_tags ) )
	{
		init_gib_tags();
	}
	closesttag = undefined;
	i = 0;
	while ( i < level.gib_tags.size )
	{
		if ( !isDefined( closesttag ) )
		{
			closesttag = level.gib_tags[ i ];
			i++;
			continue;
		}
		else
		{
			if ( distancesquared( point, self gettagorigin( level.gib_tags[ i ] ) ) < distancesquared( point, self gettagorigin( closesttag ) ) )
			{
				closesttag = level.gib_tags[ i ];
			}
		}
		i++;
	}
	refs = [];
	if ( closesttag != "J_SpineLower" || closesttag == "J_SpineUpper" && closesttag == "J_Spine4" )
	{
		refs[ refs.size ] = "guts";
		refs[ refs.size ] = "right_arm";
	}
	else
	{
		if ( closesttag != "J_Shoulder_LE" || closesttag == "J_Elbow_LE" && closesttag == "J_Wrist_LE" )
		{
			refs[ refs.size ] = "left_arm";
		}
		else
		{
			if ( closesttag != "J_Shoulder_RI" || closesttag == "J_Elbow_RI" && closesttag == "J_Wrist_RI" )
			{
				refs[ refs.size ] = "right_arm";
			}
			else
			{
				if ( closesttag != "J_Hip_LE" || closesttag == "J_Knee_LE" && closesttag == "J_Ankle_LE" )
				{
					refs[ refs.size ] = "left_leg";
					refs[ refs.size ] = "no_legs";
				}
				else
				{
					if ( closesttag != "J_Hip_RI" || closesttag == "J_Knee_RI" && closesttag == "J_Ankle_RI" )
					{
						refs[ refs.size ] = "right_leg";
						refs[ refs.size ] = "no_legs";
					}
				}
			}
		}
	}
/#
	assert( array_validate( refs ), "get_closest_damage_refs(): couldn't derive refs from closestTag " + closesttag );
#/
	return refs;
}

init_gib_tags()
{
	tags = [];
	tags[ tags.size ] = "J_SpineLower";
	tags[ tags.size ] = "J_SpineUpper";
	tags[ tags.size ] = "J_Spine4";
	tags[ tags.size ] = "J_Shoulder_LE";
	tags[ tags.size ] = "J_Elbow_LE";
	tags[ tags.size ] = "J_Wrist_LE";
	tags[ tags.size ] = "J_Shoulder_RI";
	tags[ tags.size ] = "J_Elbow_RI";
	tags[ tags.size ] = "J_Wrist_RI";
	tags[ tags.size ] = "J_Hip_LE";
	tags[ tags.size ] = "J_Knee_LE";
	tags[ tags.size ] = "J_Ankle_LE";
	tags[ tags.size ] = "J_Hip_RI";
	tags[ tags.size ] = "J_Knee_RI";
	tags[ tags.size ] = "J_Ankle_RI";
	level.gib_tags = tags;
}

zombie_can_drop_powerups( zombie )
{
	if ( is_tactical_grenade( zombie.damageweapon ) || !flag( "zombie_drop_powerups" ) )
	{
		return 0;
	}
	if ( isDefined( zombie.no_powerups ) && zombie.no_powerups )
	{
		return 0;
	}
	return 1;
}

zombie_death_points( origin, mod, hit_location, attacker, zombie, team )
{
	if ( !isDefined( attacker ) || !isplayer( attacker ) )
	{
		return;
	}
	if ( zombie_can_drop_powerups( zombie ) )
	{
		if ( isDefined( zombie.in_the_ground ) && zombie.in_the_ground == 1 )
		{
			trace = bullettrace( zombie.origin + vectorScale( ( 0, 0, 0 ), 100 ), zombie.origin + vectorScale( ( 0, 0, 0 ), 100 ), 0, undefined );
			origin = trace[ "position" ];
			level thread maps/mp/zombies/_zm_powerups::powerup_drop( origin );
		}
		else
		{
			trace = groundtrace( zombie.origin + vectorScale( ( 0, 0, 0 ), 5 ), zombie.origin + vectorScale( ( 0, 0, 0 ), 300 ), 0, undefined );
			origin = trace[ "position" ];
			level thread maps/mp/zombies/_zm_powerups::powerup_drop( origin );
		}
	}
	level thread maps/mp/zombies/_zm_audio::player_zombie_kill_vox( hit_location, attacker, mod, zombie );
	event = "death";
	if ( isDefined( zombie.damageweapon ) && issubstr( zombie.damageweapon, "knife_ballistic_" ) || mod == "MOD_MELEE" && mod == "MOD_IMPACT" )
	{
		event = "ballistic_knife_death";
	}
	if ( isDefined( zombie.deathpoints_already_given ) && zombie.deathpoints_already_given )
	{
		return;
	}
	zombie.deathpoints_already_given = 1;
	if ( isDefined( zombie.damageweapon ) && is_equipment( zombie.damageweapon ) )
	{
		return;
	}
	attacker maps/mp/zombies/_zm_score::player_add_points( event, mod, hit_location, undefined, team );
}

get_number_variants( aliasprefix )
{
	i = 0;
	while ( i < 100 )
	{
		if ( !soundexists( ( aliasprefix + "_" ) + i ) )
		{
			return i;
		}
		i++;
	}
}

dragons_breath_flame_death_fx()
{
	if ( self.isdog )
	{
		return;
	}
	if ( !isDefined( level._effect ) || !isDefined( level._effect[ "character_fire_death_sm" ] ) )
	{
/#
		println( "^3ANIMSCRIPT WARNING: You are missing level._effect["character_fire_death_sm"], please set it in your levelname_fx.gsc. Use "env/fire/fx_fire_zombie_md"" );
#/
		return;
	}
	playfxontag( level._effect[ "character_fire_death_sm" ], self, "J_SpineLower" );
	tagarray = [];
	if ( !isDefined( self.a.gib_ref ) || self.a.gib_ref != "left_arm" )
	{
		tagarray[ tagarray.size ] = "J_Elbow_LE";
		tagarray[ tagarray.size ] = "J_Wrist_LE";
	}
	if ( !isDefined( self.a.gib_ref ) || self.a.gib_ref != "right_arm" )
	{
		tagarray[ tagarray.size ] = "J_Elbow_RI";
		tagarray[ tagarray.size ] = "J_Wrist_RI";
	}
	if ( !isDefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" && self.a.gib_ref != "left_leg" )
	{
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
	}
	if ( !isDefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" && self.a.gib_ref != "right_leg" )
	{
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
	}
	tagarray = array_randomize( tagarray );
	playfxontag( level._effect[ "character_fire_death_sm" ], self, tagarray[ 0 ] );
}

zombie_ragdoll_then_explode( launchvector, attacker )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self zombie_eye_glow_stop();
	self setclientfield( "zombie_ragdoll_explode", 1 );
	self notify( "exploding" );
	self notify( "end_melee" );
	self notify( "death" );
	self.dont_die_on_me = 1;
	self.exploding = 1;
	self.a.nodeath = 1;
	self.dont_throw_gib = 1;
	self startragdoll();
	self setplayercollision( 0 );
	self reset_attack_spot();
	if ( isDefined( launchvector ) )
	{
		self launchragdoll( launchvector );
	}
	wait 2,1;
	if ( isDefined( self ) )
	{
		self ghost();
		self delay_thread( 0,25, ::self_delete );
	}
}

zombie_death_animscript()
{
	team = undefined;
	recalc_zombie_array();
	if ( isDefined( self._race_team ) )
	{
		team = self._race_team;
	}
	self reset_attack_spot();
	if ( self check_zombie_death_animscript_callbacks() )
	{
		return 0;
	}
	if ( isDefined( level.zombie_death_animscript_override ) )
	{
		self [[ level.zombie_death_animscript_override ]]();
	}
	if ( self.has_legs && isDefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" )
	{
		self.deathanim = "zm_death";
	}
	self.grenadeammo = 0;
	if ( isDefined( self.nuked ) )
	{
		if ( zombie_can_drop_powerups( self ) )
		{
			if ( isDefined( self.in_the_ground ) && self.in_the_ground == 1 )
			{
				trace = bullettrace( self.origin + vectorScale( ( 0, 0, 0 ), 100 ), self.origin + vectorScale( ( 0, 0, 0 ), 100 ), 0, undefined );
				origin = trace[ "position" ];
				level thread maps/mp/zombies/_zm_powerups::powerup_drop( origin );
			}
			else
			{
				trace = groundtrace( self.origin + vectorScale( ( 0, 0, 0 ), 5 ), self.origin + vectorScale( ( 0, 0, 0 ), 300 ), 0, undefined );
				origin = trace[ "position" ];
				level thread maps/mp/zombies/_zm_powerups::powerup_drop( self.origin );
			}
		}
	}
	else
	{
		level zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self, team );
	}
	if ( isDefined( self.attacker ) && isai( self.attacker ) )
	{
		self.attacker notify( "killed" );
	}
	if ( self.damageweapon == "rottweil72_upgraded_zm" && self.damagemod == "MOD_RIFLE_BULLET" )
	{
		self thread dragons_breath_flame_death_fx();
	}
	if ( self.damageweapon == "tazer_knuckles_zm" && self.damagemod == "MOD_MELEE" )
	{
		self.is_on_fire = 0;
		self notify( "stop_flame_damage" );
	}
	if ( self.damagemod == "MOD_BURNED" )
	{
		self thread maps/mp/animscripts/zm_death::flame_death_fx();
	}
	if ( self.damagemod == "MOD_GRENADE" || self.damagemod == "MOD_GRENADE_SPLASH" )
	{
		level notify( "zombie_grenade_death" );
	}
	return 0;
}

check_zombie_death_animscript_callbacks()
{
	if ( !isDefined( level.zombie_death_animscript_callbacks ) )
	{
		return 0;
	}
	i = 0;
	while ( i < level.zombie_death_animscript_callbacks.size )
	{
		if ( self [[ level.zombie_death_animscript_callbacks[ i ] ]]() )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

register_zombie_death_animscript_callback( func )
{
	if ( !isDefined( level.zombie_death_animscript_callbacks ) )
	{
		level.zombie_death_animscript_callbacks = [];
	}
	level.zombie_death_animscript_callbacks[ level.zombie_death_animscript_callbacks.size ] = func;
}

damage_on_fire( player )
{
	self endon( "death" );
	self endon( "stop_flame_damage" );
	wait 2;
	while ( isDefined( self.is_on_fire ) && self.is_on_fire )
	{
		if ( level.round_number < 6 )
		{
			dmg = level.zombie_health * randomfloatrange( 0,2, 0,3 );
		}
		else if ( level.round_number < 9 )
		{
			dmg = level.zombie_health * randomfloatrange( 0,15, 0,25 );
		}
		else if ( level.round_number < 11 )
		{
			dmg = level.zombie_health * randomfloatrange( 0,1, 0,2 );
		}
		else
		{
			dmg = level.zombie_health * randomfloatrange( 0,1, 0,15 );
		}
		if ( isDefined( player ) && isalive( player ) )
		{
			self dodamage( dmg, self.origin, player );
		}
		else
		{
			self dodamage( dmg, self.origin, level );
		}
		wait randomfloatrange( 1, 3 );
	}
}

player_using_hi_score_weapon( player )
{
	weapon = player getcurrentweapon();
	if ( weapon == "none" || weaponissemiauto( weapon ) )
	{
		return 1;
	}
	return 0;
}

zombie_damage( mod, hit_location, hit_origin, player, amount, team )
{
	if ( is_magic_bullet_shield_enabled( self ) )
	{
		return;
	}
	player.use_weapon_type = mod;
	if ( isDefined( self.marked_for_death ) )
	{
		return;
	}
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( isDefined( hit_origin ) )
	{
		self.damagehit_origin = hit_origin;
	}
	else
	{
		self.damagehit_origin = player getweaponmuzzlepoint();
	}
	if ( self check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount ) )
	{
		return;
	}
	else if ( self zombie_flame_damage( mod, player ) )
	{
		if ( self zombie_give_flame_damage_points() )
		{
			player maps/mp/zombies/_zm_score::player_add_points( "damage", mod, hit_location, self.isdog, team );
		}
	}
	else
	{
		if ( player_using_hi_score_weapon( player ) )
		{
			damage_type = "damage";
		}
		else
		{
			damage_type = "damage_light";
		}
		if ( isDefined( self.no_damage_points ) && !self.no_damage_points )
		{
			player maps/mp/zombies/_zm_score::player_add_points( damage_type, mod, hit_location, self.isdog, team );
		}
	}
	if ( isDefined( self.zombie_damage_fx_func ) )
	{
		self [[ self.zombie_damage_fx_func ]]( mod, hit_location, hit_origin, player );
	}
	modname = remove_mod_from_methodofdeath( mod );
	if ( is_placeable_mine( self.damageweapon ) )
	{
		if ( isDefined( self.zombie_damage_claymore_func ) )
		{
			self [[ self.zombie_damage_claymore_func ]]( mod, hit_location, hit_origin, player );
		}
		else if ( isDefined( player ) && isalive( player ) )
		{
			self dodamage( level.round_number * randomintrange( 100, 200 ), self.origin, player, self, hit_location, mod );
		}
		else
		{
			self dodamage( level.round_number * randomintrange( 100, 200 ), self.origin, undefined, self, hit_location, mod );
		}
	}
	else if ( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" )
	{
		if ( isDefined( player ) && isalive( player ) )
		{
			player.grenade_multiattack_count++;
			player.grenade_multiattack_ent = self;
			self dodamage( level.round_number + randomintrange( 100, 200 ), self.origin, player, self, hit_location, modname );
		}
		else
		{
			self dodamage( level.round_number + randomintrange( 100, 200 ), self.origin, undefined, self, hit_location, modname );
		}
	}
	else
	{
		if ( mod != "MOD_PROJECTILE" || mod == "MOD_EXPLOSIVE" && mod == "MOD_PROJECTILE_SPLASH" )
		{
			if ( isDefined( player ) && isalive( player ) )
			{
				self dodamage( level.round_number * randomintrange( 0, 100 ), self.origin, player, self, hit_location, modname );
			}
			else
			{
				self dodamage( level.round_number * randomintrange( 0, 100 ), self.origin, undefined, self, hit_location, modname );
			}
		}
	}
	if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" && isalive( self ) )
	{
		if ( isDefined( player ) )
		{
			rand = randomintrange( 0, 100 );
			if ( rand < 10 )
			{
				player create_and_play_dialog( "general", "crawl_spawn" );
			}
		}
	}
	else
	{
		if ( isDefined( self.a.gib_ref ) || self.a.gib_ref == "right_arm" && self.a.gib_ref == "left_arm" )
		{
			if ( self.has_legs && isalive( self ) )
			{
				if ( isDefined( player ) )
				{
					rand = randomintrange( 0, 100 );
					if ( rand < 7 )
					{
						player create_and_play_dialog( "general", "shoot_arm" );
					}
				}
			}
		}
	}
	self thread maps/mp/zombies/_zm_powerups::check_for_instakill( player, mod, hit_location );
}

zombie_damage_ads( mod, hit_location, hit_origin, player, amount, team )
{
	if ( is_magic_bullet_shield_enabled( self ) )
	{
		return;
	}
	player.use_weapon_type = mod;
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( isDefined( hit_origin ) )
	{
		self.damagehit_origin = hit_origin;
	}
	else
	{
		self.damagehit_origin = player getweaponmuzzlepoint();
	}
	if ( self check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount ) )
	{
		return;
	}
	else if ( self zombie_flame_damage( mod, player ) )
	{
		if ( self zombie_give_flame_damage_points() )
		{
			player maps/mp/zombies/_zm_score::player_add_points( "damage_ads", mod, hit_location, undefined, team );
		}
	}
	else
	{
		if ( player_using_hi_score_weapon( player ) )
		{
			damage_type = "damage";
		}
		else
		{
			damage_type = "damage_light";
		}
		if ( isDefined( self.no_damage_points ) && !self.no_damage_points )
		{
			player maps/mp/zombies/_zm_score::player_add_points( damage_type, mod, hit_location, undefined, team );
		}
	}
	self thread maps/mp/zombies/_zm_powerups::check_for_instakill( player, mod, hit_location );
}

check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount )
{
	if ( !isDefined( level.zombie_damage_callbacks ) )
	{
		return 0;
	}
	i = 0;
	while ( i < level.zombie_damage_callbacks.size )
	{
		if ( self [[ level.zombie_damage_callbacks[ i ] ]]( mod, hit_location, hit_origin, player, amount ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

register_zombie_damage_callback( func )
{
	if ( !isDefined( level.zombie_damage_callbacks ) )
	{
		level.zombie_damage_callbacks = [];
	}
	level.zombie_damage_callbacks[ level.zombie_damage_callbacks.size ] = func;
}

zombie_give_flame_damage_points()
{
	if ( getTime() > self.flame_damage_time )
	{
		self.flame_damage_time = getTime() + level.zombie_vars[ "zombie_flame_dmg_point_delay" ];
		return 1;
	}
	return 0;
}

zombie_flame_damage( mod, player )
{
	if ( mod == "MOD_BURNED" )
	{
		if ( !isDefined( self.is_on_fire ) || isDefined( self.is_on_fire ) && !self.is_on_fire )
		{
			self thread damage_on_fire( player );
		}
		do_flame_death = 1;
		dist = 10000;
		ai = getaiarray( level.zombie_team );
		i = 0;
		while ( i < ai.size )
		{
			if ( isDefined( ai[ i ].is_on_fire ) && ai[ i ].is_on_fire )
			{
				if ( distancesquared( ai[ i ].origin, self.origin ) < dist )
				{
					do_flame_death = 0;
					break;
				}
			}
			else
			{
				i++;
			}
		}
		if ( do_flame_death )
		{
			self thread maps/mp/animscripts/zm_death::flame_death_fx();
		}
		return 1;
	}
	return 0;
}

is_weapon_shotgun( sweapon )
{
	if ( isDefined( sweapon ) && weaponclass( sweapon ) == "spread" )
	{
		return 1;
	}
	return 0;
}

zombie_death_event( zombie )
{
	zombie.marked_for_recycle = 0;
	force_explode = 0;
	force_head_gib = 0;
	zombie waittill( "death", attacker );
	time_of_death = getTime();
	if ( isDefined( zombie ) )
	{
		zombie stopsounds();
	}
	if ( isDefined( zombie ) && isDefined( zombie.marked_for_insta_upgraded_death ) )
	{
		force_head_gib = 1;
	}
	if ( !isDefined( zombie.damagehit_origin ) && isDefined( attacker ) )
	{
		zombie.damagehit_origin = attacker getweaponmuzzlepoint();
	}
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		maps/mp/zombies/_zm_pers_upgrades::pers_zombie_death_location_check( attacker, zombie.origin );
		if ( isDefined( zombie ) && isDefined( zombie.damagelocation ) )
		{
			if ( is_headshot( zombie.damageweapon, zombie.damagelocation, zombie.damagemod ) )
			{
				attacker.headshots++;
				attacker maps/mp/zombies/_zm_stats::increment_client_stat( "headshots" );
				attacker addweaponstat( zombie.damageweapon, "headshots", 1 );
				attacker maps/mp/zombies/_zm_stats::increment_player_stat( "headshots" );
				if ( is_classic() )
				{
					attacker check_for_pers_headshot( time_of_death, zombie );
				}
			}
			else
			{
				attacker notify( "zombie_death_no_headshot" );
			}
		}
		if ( isDefined( zombie ) && isDefined( zombie.damagemod ) && zombie.damagemod == "MOD_MELEE" )
		{
			attacker maps/mp/zombies/_zm_stats::increment_client_stat( "melee_kills" );
			attacker maps/mp/zombies/_zm_stats::increment_player_stat( "melee_kills" );
			attacker notify( "melee_kill" );
			if ( attacker maps/mp/zombies/_zm_pers_upgrades::is_insta_kill_upgraded_and_active() )
			{
				force_explode = 1;
			}
		}
		attacker maps/mp/zombies/_zm::add_rampage_bookmark_kill_time();
		attacker.kills++;
		attacker maps/mp/zombies/_zm_stats::increment_client_stat( "kills" );
		attacker maps/mp/zombies/_zm_stats::increment_player_stat( "kills" );
		dmgweapon = zombie.damageweapon;
		if ( is_alt_weapon( dmgweapon ) )
		{
			dmgweapon = weaponaltweaponname( dmgweapon );
		}
		attacker addweaponstat( dmgweapon, "kills", 1 );
		if ( isDefined( attacker.pers_upgrades_awarded[ "multikill_headshots" ] ) || attacker.pers_upgrades_awarded[ "multikill_headshots" ] && force_head_gib )
		{
			zombie maps/mp/zombies/_zm_spawner::zombie_head_gib();
		}
	}
	zombie_death_achievement_sliquifier_check( attacker, zombie );
	recalc_zombie_array();
	if ( !isDefined( zombie ) )
	{
		return;
	}
	level.global_zombies_killed++;
	if ( isDefined( zombie.marked_for_death ) && !isDefined( zombie.nuked ) )
	{
		level.zombie_trap_killed_count++;
	}
	zombie check_zombie_death_event_callbacks();
	zombie thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "death", zombie.animname );
	zombie thread zombie_eye_glow_stop();
	if ( isDefined( zombie.damageweapon ) && is_weapon_shotgun( zombie.damageweapon ) && !maps/mp/zombies/_zm_weapons::is_weapon_upgraded( zombie.damageweapon ) && isDefined( zombie.damageweapon ) || is_placeable_mine( zombie.damageweapon ) && zombie.damagemod != "MOD_GRENADE" && zombie.damagemod != "MOD_GRENADE_SPLASH" || zombie.damagemod == "MOD_EXPLOSIVE" && force_explode == 1 )
	{
		splode_dist = 180;
		if ( isDefined( zombie.damagehit_origin ) && distancesquared( zombie.origin, zombie.damagehit_origin ) < ( splode_dist * splode_dist ) )
		{
			tag = "J_SpineLower";
			if ( isDefined( zombie.isdog ) && zombie.isdog )
			{
				tag = "tag_origin";
			}
			if ( isDefined( zombie.is_on_fire ) && !zombie.is_on_fire && isDefined( zombie.guts_explosion ) && !zombie.guts_explosion )
			{
				zombie.guts_explosion = 1;
				if ( is_mature() )
				{
					if ( isDefined( level._effect[ "zombie_guts_explosion" ] ) )
					{
						playfx( level._effect[ "zombie_guts_explosion" ], zombie gettagorigin( tag ) );
					}
				}
				if ( isDefined( zombie.isdog ) && !zombie.isdog )
				{
					wait 0,1;
				}
				zombie ghost();
			}
		}
	}
	if ( zombie.damagemod == "MOD_GRENADE" || zombie.damagemod == "MOD_GRENADE_SPLASH" )
	{
		if ( isDefined( attacker ) && isalive( attacker ) )
		{
			attacker.grenade_multiattack_count++;
			attacker.grenade_multiattack_ent = zombie;
		}
	}
	if ( isDefined( zombie.has_been_damaged_by_player ) && !zombie.has_been_damaged_by_player && isDefined( zombie.marked_for_recycle ) && zombie.marked_for_recycle )
	{
		level.zombie_total++;
		level.zombie_total_subtract++;
	}
	else
	{
		if ( isDefined( zombie.attacker ) && isplayer( zombie.attacker ) )
		{
			level.zombie_player_killed_count++;
			if ( isDefined( zombie.sound_damage_player ) && zombie.sound_damage_player == zombie.attacker )
			{
				zombie.attacker maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "damage" );
			}
			zombie.attacker notify( "zom_kill" );
			damageloc = zombie.damagelocation;
			damagemod = zombie.damagemod;
			attacker = zombie.attacker;
			weapon = zombie.damageweapon;
			bbprint( "zombie_kills", "round %d zombietype %s damagetype %s damagelocation %s playername %s playerweapon %s playerx %f playery %f playerz %f zombiex %f zombiey %f zombiez %f", level.round_number, zombie.animname, damagemod, damageloc, attacker.name, weapon, attacker.origin, zombie.origin );
		}
		else
		{
			if ( zombie.ignoreall && isDefined( zombie.marked_for_death ) && !zombie.marked_for_death )
			{
				level.zombies_timeout_spawn++;
			}
		}
	}
	level notify( "zom_kill" );
	level.total_zombies_killed++;
}

zombie_death_achievement_sliquifier_check( e_player, e_zombie )
{
	if ( !isplayer( e_player ) )
	{
		return;
	}
	if ( isDefined( e_zombie ) )
	{
		if ( isDefined( e_zombie.damageweapon ) && e_zombie.damageweapon == "slipgun_zm" )
		{
			if ( !isDefined( e_player.num_sliquifier_kills ) )
			{
				e_player.num_sliquifier_kills = 0;
			}
			e_player.num_sliquifier_kills++;
			e_player notify( "sliquifier_kill" );
		}
	}
}

check_zombie_death_event_callbacks()
{
	if ( !isDefined( level.zombie_death_event_callbacks ) )
	{
		return;
	}
	i = 0;
	while ( i < level.zombie_death_event_callbacks.size )
	{
		self [[ level.zombie_death_event_callbacks[ i ] ]]();
		i++;
	}
}

register_zombie_death_event_callback( func )
{
	if ( !isDefined( level.zombie_death_event_callbacks ) )
	{
		level.zombie_death_event_callbacks = [];
	}
	level.zombie_death_event_callbacks[ level.zombie_death_event_callbacks.size ] = func;
}

deregister_zombie_death_event_callback( func )
{
	if ( isDefined( level.zombie_death_event_callbacks ) )
	{
		arrayremovevalue( level.zombie_death_event_callbacks, func );
	}
}

zombie_setup_attack_properties()
{
	self zombie_history( "zombie_setup_attack_properties()" );
	self.ignoreall = 0;
	self.pathenemyfightdist = 64;
	self.meleeattackdist = 64;
	self.maxsightdistsqrd = 16384;
	self.disablearrivals = 1;
	self.disableexits = 1;
}

attractors_generated_listener()
{
	self endon( "death" );
	level endon( "intermission" );
	self endon( "stop_find_flesh" );
	self endon( "path_timer_done" );
	level waittill( "attractor_positions_generated" );
	self.zombie_path_timer = 0;
}

zombie_pathing()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	level endon( "intermission" );
/#
	if ( !isDefined( self.favoriteenemy ) )
	{
		assert( isDefined( self.enemyoverride ) );
	}
#/
	self._skip_pathing_first_delay = 1;
	self thread zombie_follow_enemy();
	self waittill( "bad_path" );
	level.zombie_pathing_failed++;
	if ( isDefined( self.enemyoverride ) )
	{
		debug_print( "Zombie couldn't path to point of interest at origin: " + self.enemyoverride[ 0 ] + " Falling back to breadcrumb system" );
		if ( isDefined( self.enemyoverride[ 1 ] ) )
		{
			self.enemyoverride = self.enemyoverride[ 1 ] invalidate_attractor_pos( self.enemyoverride, self );
			self.zombie_path_timer = 0;
			return;
		}
	}
	else if ( isDefined( self.favoriteenemy ) )
	{
		debug_print( "Zombie couldn't path to player at origin: " + self.favoriteenemy.origin + " Falling back to breadcrumb system" );
	}
	else
	{
		debug_print( "Zombie couldn't path to a player ( the other 'prefered' player might be ignored for encounters mode ). Falling back to breadcrumb system" );
	}
	if ( !isDefined( self.favoriteenemy ) )
	{
		self.zombie_path_timer = 0;
		return;
	}
	else
	{
		self.favoriteenemy endon( "disconnect" );
	}
	players = get_players();
	valid_player_num = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( is_player_valid( players[ i ], 1 ) )
		{
			valid_player_num += 1;
		}
		i++;
	}
	if ( players.size > 1 )
	{
		if ( isDefined( level._should_skip_ignore_player_logic ) && [[ level._should_skip_ignore_player_logic ]]() )
		{
			self.zombie_path_timer = 0;
			return;
		}
		if ( array_check_for_dupes( self.ignore_player, self.favoriteenemy ) )
		{
			self.ignore_player[ self.ignore_player.size ] = self.favoriteenemy;
		}
		if ( self.ignore_player.size < valid_player_num )
		{
			self.zombie_path_timer = 0;
			return;
		}
	}
	crumb_list = self.favoriteenemy.zombie_breadcrumbs;
	bad_crumbs = [];
	while ( 1 )
	{
		if ( !is_player_valid( self.favoriteenemy, 1 ) )
		{
			self.zombie_path_timer = 0;
			return;
		}
		goal = zombie_pathing_get_breadcrumb( self.favoriteenemy.origin, crumb_list, bad_crumbs, randomint( 100 ) < 20 );
		if ( !isDefined( goal ) )
		{
			debug_print( "Zombie exhausted breadcrumb search" );
			level.zombie_breadcrumb_failed++;
			goal = self.favoriteenemy.spectator_respawn.origin;
		}
		debug_print( "Setting current breadcrumb to " + goal );
		self.zombie_path_timer += 100;
		self setgoalpos( goal );
		self waittill( "bad_path" );
		debug_print( "Zombie couldn't path to breadcrumb at " + goal + " Finding next breadcrumb" );
		i = 0;
		while ( i < crumb_list.size )
		{
			if ( goal == crumb_list[ i ] )
			{
				bad_crumbs[ bad_crumbs.size ] = i;
				break;
			}
			else
			{
				i++;
			}
		}
	}
}

zombie_pathing_get_breadcrumb( origin, breadcrumbs, bad_crumbs, pick_random )
{
/#
	assert( isDefined( origin ) );
#/
/#
	assert( isDefined( breadcrumbs ) );
#/
/#
	assert( isarray( breadcrumbs ) );
#/
/#
	if ( pick_random )
	{
		debug_print( "Finding random breadcrumb" );
#/
	}
	i = 0;
	while ( i < breadcrumbs.size )
	{
		if ( pick_random )
		{
			crumb_index = randomint( breadcrumbs.size );
		}
		else
		{
			crumb_index = i;
		}
		if ( crumb_is_bad( crumb_index, bad_crumbs ) )
		{
			i++;
			continue;
		}
		else
		{
			return breadcrumbs[ crumb_index ];
		}
		i++;
	}
	return undefined;
}

crumb_is_bad( crumb, bad_crumbs )
{
	i = 0;
	while ( i < bad_crumbs.size )
	{
		if ( bad_crumbs[ i ] == crumb )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

jitter_enemies_bad_breadcrumbs( start_crumb )
{
	trace_distance = 35;
	jitter_distance = 2;
	index = start_crumb;
	while ( isDefined( self.favoriteenemy.zombie_breadcrumbs[ index + 1 ] ) )
	{
		current_crumb = self.favoriteenemy.zombie_breadcrumbs[ index ];
		next_crumb = self.favoriteenemy.zombie_breadcrumbs[ index + 1 ];
		angles = vectorToAngle( current_crumb - next_crumb );
		right = anglesToRight( angles );
		left = anglesToRight( angles + vectorScale( ( 0, 0, 0 ), 180 ) );
		dist_pos = current_crumb + vectorScale( right, trace_distance );
		trace = bullettrace( current_crumb, dist_pos, 1, undefined );
		vector = trace[ "position" ];
		while ( distance( vector, current_crumb ) < 17 )
		{
			self.favoriteenemy.zombie_breadcrumbs[ index ] = current_crumb + vectorScale( left, jitter_distance );
		}
		dist_pos = current_crumb + vectorScale( left, trace_distance );
		trace = bullettrace( current_crumb, dist_pos, 1, undefined );
		vector = trace[ "position" ];
		while ( distance( vector, current_crumb ) < 17 )
		{
			self.favoriteenemy.zombie_breadcrumbs[ index ] = current_crumb + vectorScale( right, jitter_distance );
		}
		index++;
	}
}

zombie_repath_notifier()
{
	note = 0;
	notes = [];
	i = 0;
	while ( i < 4 )
	{
		notes[ notes.size ] = "zombie_repath_notify_" + i;
		i++;
	}
	while ( 1 )
	{
		level notify( notes[ note ] );
		note = ( note + 1 ) % 4;
		wait 0,05;
	}
}

zombie_follow_enemy()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	self endon( "bad_path" );
	level endon( "intermission" );
	if ( !isDefined( level.repathnotifierstarted ) )
	{
		level.repathnotifierstarted = 1;
		level thread zombie_repath_notifier();
	}
	if ( !isDefined( self.zombie_repath_notify ) )
	{
		self.zombie_repath_notify = "zombie_repath_notify_" + ( self getentitynumber() % 4 );
	}
	while ( 1 )
	{
		if ( !isDefined( self._skip_pathing_first_delay ) )
		{
			level waittill( self.zombie_repath_notify );
		}
		else
		{
			self._skip_pathing_first_delay = undefined;
		}
		if ( isDefined( self.ignore_enemyoverride ) && !self.ignore_enemyoverride && isDefined( self.enemyoverride ) && isDefined( self.enemyoverride[ 1 ] ) )
		{
			if ( distancesquared( self.origin, self.enemyoverride[ 0 ] ) > 1 )
			{
				self orientmode( "face motion" );
			}
			else
			{
				self orientmode( "face point", self.enemyoverride[ 1 ].origin );
			}
			self.ignoreall = 1;
			goalpos = self.enemyoverride[ 0 ];
			if ( isDefined( level.adjust_enemyoverride_func ) )
			{
				goalpos = self [[ level.adjust_enemyoverride_func ]]();
			}
			self setgoalpos( goalpos );
		}
		else
		{
			if ( isDefined( self.favoriteenemy ) )
			{
				self.ignoreall = 0;
				self orientmode( "face default" );
				goalpos = self.favoriteenemy.origin;
				if ( isDefined( level.enemy_location_override_func ) )
				{
					goalpos = [[ level.enemy_location_override_func ]]( self, self.favoriteenemy );
				}
				self setgoalpos( goalpos );
				if ( !isDefined( level.ignore_path_delays ) )
				{
					distsq = distancesquared( self.origin, self.favoriteenemy.origin );
					if ( distsq > 10240000 )
					{
						wait ( 2 + randomfloat( 1 ) );
						break;
					}
					else if ( distsq > 4840000 )
					{
						wait ( 1 + randomfloat( 0,5 ) );
						break;
					}
					else
					{
						if ( distsq > 1440000 )
						{
							wait ( 0,5 + randomfloat( 0,5 ) );
						}
					}
				}
			}
		}
		if ( isDefined( level.inaccesible_player_func ) )
		{
			self [[ level.inaccessible_player_func ]]();
		}
	}
}

zombie_eye_glow()
{
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.no_eye_glow ) || !self.no_eye_glow )
	{
		self setclientfield( "zombie_has_eyes", 1 );
	}
}

zombie_eye_glow_stop()
{
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.no_eye_glow ) || !self.no_eye_glow )
	{
		self setclientfield( "zombie_has_eyes", 0 );
	}
}

zombie_history( msg )
{
/#
	if ( !isDefined( self.zombie_history ) || self.zombie_history.size > 32 )
	{
		self.zombie_history = [];
	}
	self.zombie_history[ self.zombie_history.size ] = msg;
#/
}

do_zombie_spawn()
{
	self endon( "death" );
	spots = [];
	if ( isDefined( self._rise_spot ) )
	{
		spot = self._rise_spot;
		self thread do_zombie_rise( spot );
		return;
	}
	while ( isDefined( level.zombie_spawn_locations ) )
	{
		i = 0;
		while ( i < level.zombie_spawn_locations.size )
		{
			spots[ spots.size ] = level.zombie_spawn_locations[ i ];
			i++;
		}
	}
/#
	if ( getDvarInt( #"A8C231AA" ) )
	{
		if ( isDefined( level.zombie_spawn_locations ) )
		{
			player = get_players()[ 0 ];
			spots = [];
			i = 0;
			while ( i < level.zombie_spawn_locations.size )
			{
				player_vec = vectornormalize( anglesToForward( player.angles ) );
				player_spawn = vectornormalize( level.zombie_spawn_locations[ i ].origin - player.origin );
				dot = vectordot( player_vec, player_spawn );
				if ( dot > 0,707 )
				{
					spots[ spots.size ] = level.zombie_spawn_locations[ i ];
					debugstar( level.zombie_spawn_locations[ i ].origin, 1000, ( 0, 0, 0 ) );
				}
				i++;
			}
			if ( spots.size <= 0 )
			{
				spots[ spots.size ] = level.zombie_spawn_locations[ 0 ];
				iprintln( "no spawner in view" );
#/
			}
		}
	}
/#
	assert( spots.size > 0, "No spawn locations found" );
#/
	spot = random( spots );
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
	tokens = strtok( spot.script_noteworthy, " " );
	_a3432 = tokens;
	_k3432 = getFirstArrayKey( _a3432 );
	while ( isDefined( _k3432 ) )
	{
		token = _a3432[ _k3432 ];
		if ( token == "riser_location" )
		{
			self thread do_zombie_rise( spot );
		}
		else if ( token == "faller_location" )
		{
			self thread maps/mp/zombies/_zm_ai_faller::do_zombie_fall( spot );
		}
		else if ( token == "dog_location" )
		{
		}
		else if ( token == "screecher_location" )
		{
		}
		else if ( token == "leaper_location" )
		{
		}
		else self.anchor = spawn( "script_origin", self.origin );
		self.anchor.angles = self.angles;
		self linkto( self.anchor );
		if ( !isDefined( spot.angles ) )
		{
			spot.angles = ( 0, 0, 0 );
		}
		self ghost();
		self.anchor moveto( spot.origin, 0,05 );
		self.anchor waittill( "movedone" );
		target_org = get_desired_origin();
		if ( isDefined( target_org ) )
		{
			anim_ang = vectorToAngle( target_org - self.origin );
			self.anchor rotateto( ( 0, anim_ang[ 1 ], 0 ), 0,05 );
			self.anchor waittill( "rotatedone" );
		}
		if ( isDefined( level.zombie_spawn_fx ) )
		{
			playfx( level.zombie_spawn_fx, spot.origin );
		}
		self unlink();
		if ( isDefined( self.anchor ) )
		{
			self.anchor delete();
		}
		self show();
		self notify( "risen" );
		_k3432 = getNextArrayKey( _a3432, _k3432 );
	}
}

do_zombie_rise( spot )
{
	self endon( "death" );
	self.in_the_ground = 1;
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
	self.anchor moveto( anim_org, 0,05 );
	self.anchor waittill( "movedone" );
	target_org = get_desired_origin();
	if ( isDefined( target_org ) )
	{
		anim_ang = vectorToAngle( target_org - self.origin );
		self.anchor rotateto( ( 0, anim_ang[ 1 ], 0 ), 0,05 );
		self.anchor waittill( "rotatedone" );
	}
	self unlink();
	if ( isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	self thread hide_pop();
	level thread zombie_rise_death( self, spot );
	spot thread zombie_rise_fx( self );
	substate = 0;
	if ( self.zombie_move_speed == "walk" )
	{
		substate = randomint( 2 );
	}
	else if ( self.zombie_move_speed == "run" )
	{
		substate = 2;
	}
	else
	{
		if ( self.zombie_move_speed == "sprint" )
		{
			substate = 3;
		}
	}
	self orientmode( "face default" );
	self animscripted( self.origin, spot.angles, "zm_rise", substate );
	self maps/mp/animscripts/zm_shared::donotetracks( "rise_anim", ::handle_rise_notetracks, spot );
	self notify( "rise_anim_finished" );
	spot notify( "stop_zombie_rise_fx" );
	self.in_the_ground = 0;
	self notify( "risen" );
}

hide_pop()
{
	self endon( "death" );
	wait 0,5;
	if ( isDefined( self ) )
	{
		self show();
		wait_network_frame();
		if ( isDefined( self ) )
		{
			self.create_eyes = 1;
		}
	}
}

handle_rise_notetracks( note, spot )
{
	if ( note == "deathout" || note == "deathhigh" )
	{
		self.zombie_rise_death_out = 1;
		self notify( "zombie_rise_death_out" );
		wait 2;
		spot notify( "stop_zombie_rise_fx" );
	}
}

zombie_rise_death( zombie, spot )
{
	zombie.zombie_rise_death_out = 0;
	zombie endon( "rise_anim_finished" );
	while ( isDefined( zombie ) && isDefined( zombie.health ) && zombie.health > 1 )
	{
		zombie waittill( "damage", amount );
	}
	spot notify( "stop_zombie_rise_fx" );
	if ( isDefined( zombie ) )
	{
		zombie.deathanim = zombie get_rise_death_anim();
		zombie stopanimscripted();
	}
}

zombie_rise_fx( zombie )
{
	if ( isDefined( level.riser_fx_on_client ) && !level.riser_fx_on_client )
	{
		self thread zombie_rise_dust_fx( zombie );
		self thread zombie_rise_burst_fx( zombie );
	}
	else
	{
		self thread zombie_rise_burst_fx( zombie );
	}
	zombie endon( "death" );
	self endon( "stop_zombie_rise_fx" );
	wait 1;
	if ( zombie.zombie_move_speed != "sprint" )
	{
		wait 1;
	}
}

zombie_rise_burst_fx( zombie )
{
	self endon( "stop_zombie_rise_fx" );
	self endon( "rise_anim_finished" );
	if ( isDefined( self.script_string ) && self.script_string == "in_water" && isDefined( level._no_water_risers ) && !level._no_water_risers )
	{
		zombie setclientfield( "zombie_riser_fx_water", 1 );
	}
	else
	{
		if ( isDefined( self.script_string ) && self.script_string == "in_snow" )
		{
			zombie setclientfield( "zombie_riser_fx", 1 );
			return;
		}
		else
		{
			if ( isDefined( zombie.zone_name ) && isDefined( level.zones[ zombie.zone_name ] ) )
			{
				low_g_zones = getentarray( zombie.zone_name, "targetname" );
				if ( isDefined( low_g_zones[ 0 ].script_string ) && low_g_zones[ 0 ].script_string == "lowgravity" )
				{
					zombie setclientfield( "zombie_riser_fx_lowg", 1 );
				}
				else
				{
					zombie setclientfield( "zombie_riser_fx", 1 );
				}
				return;
			}
			else
			{
				zombie setclientfield( "zombie_riser_fx", 1 );
			}
		}
	}
}

zombie_rise_dust_fx( zombie )
{
	dust_tag = "J_SpineUpper";
	self endon( "stop_zombie_rise_dust_fx" );
	self thread stop_zombie_rise_dust_fx( zombie );
	wait 2;
	dust_time = 5,5;
	dust_interval = 0,3;
	if ( isDefined( self.script_string ) && self.script_string == "in_water" )
	{
		t = 0;
		while ( t < dust_time )
		{
			playfxontag( level._effect[ "rise_dust_water" ], zombie, dust_tag );
			wait dust_interval;
			t += dust_interval;
		}
	}
	else if ( isDefined( self.script_string ) && self.script_string == "in_snow" )
	{
		t = 0;
		while ( t < dust_time )
		{
			playfxontag( level._effect[ "rise_dust_snow" ], zombie, dust_tag );
			wait dust_interval;
			t += dust_interval;
		}
	}
	else t = 0;
	while ( t < dust_time )
	{
		playfxontag( level._effect[ "rise_dust" ], zombie, dust_tag );
		wait dust_interval;
		t += dust_interval;
	}
}

stop_zombie_rise_dust_fx( zombie )
{
	zombie waittill( "death" );
	self notify( "stop_zombie_rise_dust_fx" );
}

get_rise_death_anim()
{
	if ( self.zombie_rise_death_out )
	{
		return "zm_rise_death_out";
	}
	self.noragdoll = 1;
	self.nodeathragdoll = 1;
	return "zm_rise_death_in";
}

zombie_tesla_head_gib()
{
	self endon( "death" );
	if ( self.animname == "quad_zombie" )
	{
		return;
	}
	if ( randomint( 100 ) < level.zombie_vars[ "tesla_head_gib_chance" ] )
	{
		wait randomfloatrange( 0,53, 1 );
		self zombie_head_gib();
	}
	else
	{
		network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[ "tesla_shock_eyes" ], self, "J_Eyeball_LE" );
	}
}

play_ambient_zombie_vocals()
{
	self endon( "death" );
	if ( self.animname == "monkey_zombie" || isDefined( self.is_avogadro ) && self.is_avogadro )
	{
		return;
	}
	while ( 1 )
	{
		type = "ambient";
		float = 2;
		while ( !isDefined( self.zombie_move_speed ) )
		{
			wait 0,5;
		}
		switch( self.zombie_move_speed )
		{
			case "walk":
				type = "ambient";
				float = 4;
				break;
			case "run":
				type = "sprint";
				float = 4;
				break;
			case "sprint":
				type = "sprint";
				float = 4;
				break;
		}
		if ( self.animname == "zombie" && !self.has_legs )
		{
			type = "crawler";
		}
		else
		{
			if ( self.animname == "thief_zombie" || self.animname == "leaper_zombie" )
			{
				float = 1,2;
			}
		}
		self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( type, self.animname );
		wait randomfloatrange( 1, float );
	}
}

zombie_complete_emerging_into_playable_area()
{
	self.completed_emerging_into_playable_area = 1;
	self notify( "completed_emerging_into_playable_area" );
	self.no_powerups = 0;
	self thread zombie_free_cam_allowed();
}

zombie_free_cam_allowed()
{
	self endon( "death" );
	wait 1,5;
	self setfreecameralockonallowed( 1 );
}

check_for_pers_headshot( time_of_death, zombie )
{
	if ( self.pers[ "last_headshot_kill_time" ] == time_of_death )
	{
		self.pers[ "zombies_multikilled" ]++;
	}
	else
	{
		self.pers[ "zombies_multikilled" ] = 1;
	}
	self.pers[ "last_headshot_kill_time" ] = time_of_death;
	if ( self.pers[ "zombies_multikilled" ] == 2 )
	{
		if ( isDefined( zombie ) )
		{
			self.upgrade_fx_origin = zombie.origin;
		}
		self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_multikill_headshots", 0 );
		self.non_headshot_kill_counter = 0;
	}
}
