#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_ai_screecher;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

precache()
{
	precacheshader( "fullscreen_claw_left" );
	precacheshader( "fullscreen_claw_right" );
	precacheshader( "fullscreen_claw_bottom" );
	precachemodel( "p6_zm_screecher_hole" );
	precachemodel( "fx_axis_createfx" );
	precachestring( &"ZOMBIE_SCREECHER_ATTACH_FIRST" );
	level._effect[ "screecher_spawn_a" ] = loadfx( "maps/zombie/fx_zmb_screech_hand_dirt_burst" );
	level._effect[ "screecher_spawn_b" ] = loadfx( "maps/zombie/fx_zmb_screech_body_dirt_billowing" );
	level._effect[ "screecher_spawn_c" ] = loadfx( "maps/zombie/fx_zmb_screech_body_dirt_falling" );
	level._effect[ "screecher_hole" ] = loadfx( "maps/zombie/fx_zmb_screecher_hole" );
	level._effect[ "screecher_vortex" ] = loadfx( "maps/zombie/fx_zmb_screecher_vortex" );
	level._effect[ "screecher_death" ] = loadfx( "maps/zombie/fx_zmb_screech_death_ash" );
}

init()
{
	level.screecher_spawners = getentarray( "screecher_zombie_spawner", "script_noteworthy" );
	array_thread( level.screecher_spawners, ::add_spawn_function, ::screecher_prespawn );
	level.zombie_ai_limit_screecher = 2;
	level.zombie_screecher_count = 0;
	if ( !isDefined( level.vsmgr_prio_overlay_zm_ai_screecher_blur ) )
	{
		level.vsmgr_prio_overlay_zm_ai_screecher_blur = 50;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_ai_screecher_blur", 1, level.vsmgr_prio_overlay_zm_ai_screecher_blur, 1, 1, ::maps/mp/_visionset_mgr::vsmgr_timeout_lerp_thread_per_player, 0 );
	level thread screecher_spawning_logic();
/#
	level thread screecher_debug();
#/
	registerclientfield( "actor", "render_third_person", 1, 1, "int" );
	level.near_miss = 0;
}

screecher_debug()
{
/#
#/
}

screecher_spawning_logic()
{
	level endon( "intermission" );
	if ( level.intermission )
	{
		return;
	}
/#
	if ( getDvarInt( "zombie_cheat" ) == 2 || getDvarInt( "zombie_cheat" ) >= 4 )
	{
		return;
#/
	}
	if ( level.screecher_spawners.size < 1 )
	{
/#
		assertmsg( "No active spawners in the map.  Check to see if the zone is active and if it's pointing to spawners." );
#/
		return;
	}
	while ( 1 )
	{
		while ( !isDefined( level.zombie_screecher_locations ) || level.zombie_screecher_locations.size <= 0 )
		{
			wait 0,1;
		}
		while ( level.zombie_screecher_count >= level.zombie_ai_limit_screecher )
		{
			wait 0,1;
		}
		while ( getDvarInt( #"B0C0D38F" ) )
		{
			wait 0,1;
		}
		if ( !flag( "spawn_zombies" ) )
		{
			flag_wait( "spawn_zombies" );
		}
		valid_players_in_screecher_zone = 0;
		valid_players = [];
		while ( valid_players_in_screecher_zone <= 0 )
		{
			players = getplayers();
			valid_players_in_screecher_zone = 0;
			p = 0;
			while ( p < players.size )
			{
				if ( is_player_valid( players[ p ] ) && player_in_screecher_zone( players[ p ] ) && !isDefined( players[ p ].screecher ) )
				{
					valid_players_in_screecher_zone++;
					valid_players[ valid_players.size ] = players[ p ];
				}
				p++;
			}
			if ( players.size == 1 )
			{
				if ( is_player_valid( players[ 0 ] ) && !player_in_screecher_zone( players[ 0 ] ) )
				{
					level.spawn_delay = 1;
				}
			}
			wait 0,1;
		}
		if ( !isDefined( level.zombie_screecher_locations ) || level.zombie_screecher_locations.size <= 0 )
		{
			continue;
		}
		valid_players = array_randomize( valid_players );
		player_left_zone = 0;
		while ( isDefined( level.spawn_delay ) && level.spawn_delay )
		{
/#
			screecher_print( "delay spawning 5 secs" );
#/
			spawn_points = get_array_of_closest( valid_players[ 0 ].origin, level.zombie_screecher_locations );
			spawn_point = undefined;
			if ( spawn_points.size >= 3 )
			{
				spawn_point = spawn_points[ 2 ];
			}
			else if ( spawn_points.size >= 2 )
			{
				spawn_point = spawn_points[ 1 ];
			}
			else
			{
				if ( spawn_points.size >= 1 )
				{
					spawn_point = spawn_points[ 0 ];
				}
			}
			if ( isDefined( spawn_point ) )
			{
				playsoundatposition( "zmb_vocals_screecher_spawn", spawn_point.origin );
			}
			delay_time = getTime() + 5000;
			now_zone = getent( "screecher_spawn_now", "targetname" );
			while ( getTime() < delay_time )
			{
				in_zone = 0;
				if ( valid_players[ 0 ] istouching( now_zone ) )
				{
/#
					screecher_print( "in now zone" );
#/
					break;
				}
				else if ( !is_player_valid( valid_players[ 0 ] ) )
				{
					break;
				}
				else if ( player_in_screecher_zone( valid_players[ 0 ] ) )
				{
					in_zone = 1;
				}
				if ( !in_zone )
				{
					player_left_zone = 1;
					level.spawn_delay = 1;
					break;
				}
				else
				{
					wait 0,1;
				}
			}
		}
		if ( isDefined( player_left_zone ) && player_left_zone )
		{
			continue;
		}
		level.spawn_delay = 0;
		spawn_points = get_array_of_closest( valid_players[ 0 ].origin, level.zombie_screecher_locations );
		spawn_point = undefined;
		while ( !isDefined( spawn_points ) || spawn_points.size == 0 )
		{
			wait 0,1;
		}
		if ( !isDefined( level.last_spawn ) )
		{
			level.last_spawn_index = 0;
			level.last_spawn = [];
			level.last_spawn[ level.last_spawn_index ] = spawn_points[ 0 ];
			level.last_spawn_index = 1;
			spawn_point = spawn_points[ 0 ];
		}
		else _a250 = spawn_points;
		_k250 = getFirstArrayKey( _a250 );
		while ( isDefined( _k250 ) )
		{
			point = _a250[ _k250 ];
			if ( point == level.last_spawn[ 0 ] )
			{
			}
			else if ( isDefined( level.last_spawn[ 1 ] ) && point == level.last_spawn[ 1 ] )
			{
			}
			else
			{
				spawn_point = point;
				level.last_spawn[ level.last_spawn_index ] = spawn_point;
				level.last_spawn_index++;
				if ( level.last_spawn_index > 1 )
				{
					level.last_spawn_index = 0;
				}
				break;
			}
			_k250 = getNextArrayKey( _a250, _k250 );
		}
		if ( !isDefined( spawn_point ) )
		{
			spawn_point = spawn_points[ 0 ];
		}
		if ( isDefined( level.screecher_spawners ) )
		{
			spawner = random( level.screecher_spawners );
			ai = spawn_zombie( spawner, spawner.targetname, spawn_point );
		}
		if ( isDefined( ai ) )
		{
			ai.spawn_point = spawn_point;
			level.zombie_screecher_count++;
/#
			screecher_print( "screecher total " + level.zombie_screecher_count );
#/
		}
		wait level.zombie_vars[ "zombie_spawn_delay" ];
		wait 0,1;
	}
}

player_in_screecher_zone( player )
{
	if ( isDefined( level.is_player_in_screecher_zone ) )
	{
		infog = [[ level.is_player_in_screecher_zone ]]( player );
		return infog;
	}
	return 1;
}

screecher_should_runaway( player )
{
	players = get_players();
	if ( players.size == 1 )
	{
		if ( level.near_miss == 1 )
		{
			level.near_miss = 2;
/#
			screecher_print( "runaway from near_miss " + level.near_miss );
#/
			return 1;
		}
	}
	if ( isDefined( level.screecher_should_runaway ) )
	{
		return self [[ level.screecher_should_runaway ]]( player );
	}
	return 0;
}

screecher_get_closest_valid_player( origin, ignore_player )
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
	while ( !valid_player_found )
	{
		if ( isDefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
		{
			player = get_closest_player_using_paths( origin, players );
		}
		else
		{
			player = getclosest( origin, players );
		}
		if ( !isDefined( player ) )
		{
			return undefined;
		}
		if ( isDefined( level._zombie_using_humangun ) && level._zombie_using_humangun && isai( player ) )
		{
			return player;
		}
		if ( isDefined( player.screecher ) )
		{
			screecher_claimed = player.screecher != self;
		}
		if ( players.size == 1 && screecher_claimed )
		{
			return undefined;
		}
		while ( is_player_valid( player, 1 ) || !player_in_screecher_zone( player ) && screecher_claimed )
		{
			arrayremovevalue( players, player );
		}
		return player;
	}
}

zombie_pathing_home()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	level endon( "intermission" );
	self setgoalpos( self.startinglocation );
	self waittill( "goal" );
	playfx( level._effect[ "screecher_spawn_b" ], self.origin, ( 0, 0, 1 ) );
	self.no_powerups = 1;
	self setfreecameralockonallowed( 0 );
	self animscripted( self.origin, self.angles, "zm_burrow" );
	self playsound( "zmb_screecher_dig" );
	maps/mp/animscripts/zm_shared::donotetracks( "burrow_anim" );
	self delete();
}

screecher_find_flesh()
{
	self endon( "death" );
	level endon( "intermission" );
	self endon( "stop_find_flesh" );
	if ( level.intermission )
	{
		return;
	}
	self.helitarget = 1;
	self.ignoreme = 0;
	self.nododgemove = 1;
	self.ignore_player = [];
	self zombie_history( "find flesh -> start" );
	self.goalradius = 32;
	while ( 1 )
	{
		self.favoriteenemy = screecher_get_closest_valid_player( self.origin );
		if ( isDefined( self.favoriteenemy ) )
		{
			self thread zombie_pathing();
		}
		else
		{
			self thread screecher_runaway();
		}
		self.zombie_path_timer = getTime() + ( randomfloatrange( 1, 3 ) * 1000 );
		while ( getTime() < self.zombie_path_timer )
		{
			wait 0,1;
		}
		self notify( "path_timer_done" );
		self zombie_history( "find flesh -> bottom of loop" );
		debug_print( "Zombie is re-acquiring enemy, ending breadcrumb search" );
		self notify( "zombie_acquire_enemy" );
	}
}

screecher_prespawn()
{
	self endon( "death" );
	level endon( "intermission" );
	self.startinglocation = self.origin;
	self.animname = "screecher_zombie";
	self.audio_type = "screecher";
	self.has_legs = 1;
	self.no_gib = 1;
	self.isscreecher = 1;
	self.ignore_enemy_count = 1;
	recalc_zombie_array();
	self.cant_melee = 1;
	if ( isDefined( self.spawn_point ) )
	{
		spot = self.spawn_point;
		if ( !isDefined( spot.angles ) )
		{
			spot.angles = ( 0, 0, 1 );
		}
		self forceteleport( spot.origin, spot.angles );
	}
	self set_zombie_run_cycle( "super_sprint" );
	self setphysparams( 15, 0, 24 );
	self.actor_damage_func = ::screecher_damage_func;
	self.deathfunction = ::screecher_death_func;
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
	self.allowpain = 0;
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self.forcemovementscriptstate = 0;
	self maps/mp/zombies/_zm_spawner::zombie_setup_attack_properties();
	self maps/mp/zombies/_zm_spawner::zombie_complete_emerging_into_playable_area();
	self setfreecameralockonallowed( 0 );
	self.startinglocation = self.origin;
	self playsound( "zmb_vocals_screecher_spawn" );
	self thread play_screecher_fx();
	self thread play_screecher_damaged_yelps();
	self thread screecher_rise();
	self thread screecher_cleanup();
	self thread screecher_distance_tracking();
	self.anchor = spawn( "script_origin", self.origin );
	self.attack_time = 0;
	self.attack_delay = 1000;
	self.attack_delay_base = 1000;
	self.attack_delay_offset = 500;
	self.meleedamage = 5;
	self.ignore_inert = 1;
	self.player_score = 0;
	self.screecher_score = 0;
	if ( isDefined( level.screecher_init_done ) )
	{
		self thread [[ level.screecher_init_done ]]();
	}
}

play_screecher_fx()
{
/#
	if ( isDefined( level.screecher_nofx ) && level.screecher_nofx )
	{
		return;
#/
	}
	playfx( level._effect[ "screecher_spawn_a" ], self.origin, ( 0, 0, 1 ) );
	playfx( level._effect[ "screecher_spawn_b" ], self.origin, ( 0, 0, 1 ) );
	self waittill( "risen" );
	playfx( level._effect[ "screecher_spawn_c" ], self.origin, ( 0, 0, 1 ) );
}

play_screecher_damaged_yelps()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, dir, point, mod );
		if ( isDefined( attacker ) && isplayer( attacker ) )
		{
			self playsound( "zmb_vocals_screecher_pain" );
		}
	}
}

play_screecher_breathing_audio()
{
	wait 0,5;
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.loopsoundent ) )
	{
		self.loopsoundent = spawn( "script_origin", self.origin );
		self.loopsoundent linkto( self, "tag_origin" );
	}
	self.loopsoundent playloopsound( "zmb_vocals_screecher_breath" );
}

screecher_rise()
{
	self endon( "death" );
	self animscripted( self.origin, self.angles, "zm_rise" );
	maps/mp/animscripts/zm_shared::donotetracks( "rise_anim" );
	self notify( "risen" );
	self setfreecameralockonallowed( 1 );
	self.startinglocation = self.origin;
	self thread screecher_zombie_think();
	self thread play_screecher_breathing_audio();
/#
#/
}

screecher_zombie_think()
{
	self endon( "death" );
	min_dist = 96;
	max_dist = 144;
	height_tolerance = 32;
	self.state = "chase_init";
	self.isattacking = 0;
	self.nextspecial = getTime();
	for ( ;; )
	{
		switch( self.state )
		{
			case "chase_init":
				self screecher_chase();
				break;
			case "chase_update":
				self screecher_chase_update();
				break;
			case "attacking":
				self screecher_attacking();
				break;
		}
		wait 0,1;
	}
}

screecher_chase()
{
	self thread screecher_find_flesh();
	self.state = "chase_update";
}

screecher_chase_update()
{
	player = self.favoriteenemy;
	if ( isDefined( player ) )
	{
		dist = distance2dsquared( self.origin, player.origin );
		if ( dist < 57600 )
		{
			self screecher_attack();
			return;
		}
		if ( self screecher_should_runaway( player ) )
		{
			self thread screecher_runaway();
			return;
		}
	}
}

screecher_attack()
{
	self endon( "death" );
	player = self.favoriteenemy;
	if ( isDefined( player.screecher ) )
	{
		return;
	}
	else
	{
		player.screecher = self;
	}
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self animmode( "nogravity" );
	self playsound( "zmb_vocals_screecher_jump" );
	if ( isDefined( self.loopsoundent ) )
	{
		self.loopsoundent delete();
		self.loopsoundent = undefined;
	}
	self setanimstatefromasd( "zm_jump_up" );
	maps/mp/animscripts/zm_shared::donotetracks( "jump_up_anim" );
	asd_state = self screecher_fly_to_player( player );
	self setplayercollision( 0 );
	self setclientfield( "render_third_person", 1 );
	self linkto( self.favoriteenemy, "tag_origin" );
	self animscripted( self.favoriteenemy.origin, self.favoriteenemy.angles, asd_state );
	maps/mp/animscripts/zm_shared::donotetracks( "jump_land_success_anim" );
	org = self.favoriteenemy gettagorigin( "j_head" );
	angles = self.favoriteenemy gettagangles( "j_head" );
	self forceteleport( org, angles );
	self linkto( self.favoriteenemy, "j_head" );
	self animscripted( self.origin, self.angles, "zm_headpull" );
	self.linked_ent = self.favoriteenemy;
	self.linked_ent setmovespeedscale( 0,5 );
	self thread screecher_melee_button_watcher();
	self screecher_start_attack();
}

screecher_fly_to_player( player )
{
	self endon( "death" );
	self setanimstatefromasd( "zm_jump_loop" );
	self.anchor.origin = self.origin;
	self.anchor.angles = self.angles;
	self linkto( self.anchor );
	anim_id_back = self getanimfromasd( "zm_jump_land_success_fromback", 0 );
	anim_id_front = self getanimfromasd( "zm_jump_land_success_fromfront", 0 );
	end_time = getTime() + 2500;
	dist = undefined;
	dist_update = undefined;
	while ( end_time > getTime() )
	{
		goal_pos_back = getstartorigin( player.origin, player.angles, anim_id_back );
		goal_pos_front = getstartorigin( player.origin, player.angles, anim_id_front );
		dist_back = distancesquared( self.anchor.origin, goal_pos_back );
		dist_front = distancesquared( self.anchor.origin, goal_pos_front );
		goal_pos = goal_pos_back;
		goal_ang = getstartangles( player.origin, player.angles, anim_id_back );
		asd_state = "zm_jump_land_success_fromback";
		if ( dist_front < dist_back )
		{
			goal_pos = goal_pos_front;
			goal_ang = getstartangles( player.origin, player.angles, anim_id_front );
			asd_state = "zm_jump_land_success_fromfront";
		}
		facing_vec = goal_pos - self.anchor.origin;
		facing_angles = vectorToAngle( facing_vec );
		dist = length( facing_vec );
		if ( !isDefined( dist_update ) )
		{
			time = 0,5;
			vel = dist / time;
			dist_update = vel * 0,1;
		}
		if ( dist < dist_update )
		{
			self.anchor.origin = goal_pos;
			self.anchor.angles = goal_ang;
			break;
		}
		else
		{
			self.anchor.angles = facing_angles;
			unit_facing_vec = vectornormalize( facing_vec );
			new_pos = self.anchor.origin + vectorScale( unit_facing_vec, dist_update );
			self.anchor moveto( new_pos, 0,1 );
			wait 0,1;
		}
	}
	return asd_state;
}

finish_planting_equipment()
{
	while ( self isthrowinggrenade() && is_equipment( self getcurrentweapon() ) )
	{
		wait 0,05;
	}
}

screecher_start_attack()
{
	player = self.favoriteenemy;
	if ( is_player_valid( player ) )
	{
		player playsoundtoplayer( "zmb_screecher_impact", player );
		player finish_planting_equipment();
		player allowprone( 0 );
		player.screecher_weapon = player getcurrentweapon();
		player giveweapon( "screecher_arms_zm" );
		throwing_grenade = 0;
		if ( player isthrowinggrenade() )
		{
			throwing_grenade = 1;
			primaryweapons = player getweaponslistprimaries();
			if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
			{
				player.screecher_weapon = primaryweapons[ 0 ];
				player forcegrenadethrow();
				player switchtoweaponimmediate( "screecher_arms_zm" );
			}
		}
		else if ( player.screecher_weapon == "riotshield_zm" )
		{
			player switchtoweaponimmediate( "screecher_arms_zm" );
		}
		else
		{
			player switchtoweapon( "screecher_arms_zm" );
		}
		player increment_is_drinking();
		wait 0,5;
		player clientnotify( "scrStrt" );
		if ( player isthrowinggrenade() && !throwing_grenade )
		{
			primaryweapons = player getweaponslistprimaries();
			if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
			{
				player.screecher_weapon = primaryweapons[ 0 ];
				player forcegrenadethrow();
				player switchtoweaponimmediate( "screecher_arms_zm" );
			}
		}
		self.state = "attacking";
		self.attack_time = getTime();
		if ( !getDvarInt( #"E7EF8EB7" ) )
		{
			player startpoisoning();
		}
		self thread screecher_player_down();
	}
	else
	{
		self screecher_detach( player );
	}
}

screecher_player_down()
{
	self endon( "death" );
	self endon( "runaway" );
	player = self.linked_ent;
	player endon( "death" );
	player endon( "disconnect" );
	player waittill( "player_downed" );
	self thread screecher_detach( player );
}

screecher_first_seen_hint_think()
{
	if ( !flag( "solo_game" ) )
	{
		return;
	}
	fade_time = 3;
	hudelem = self maps/mp/gametypes_zm/_hud_util::createfontstring( "objective", 2 );
	hudelem maps/mp/gametypes_zm/_hud_util::setpoint( "TOP", undefined, 0, 200 );
	hudelem.label = &"ZOMBIE_SCREECHER_ATTACH_FIRST";
	hudelem.sort = 0,5;
	hudelem.alpha = 1;
	hudelem fadeovertime( fade_time );
	hudelem.alpha = 0;
	wait fade_time;
	hudelem destroy();
}

screecher_attacking()
{
	player = self.favoriteenemy;
	if ( !isDefined( player ) )
	{
		self thread screecher_detach( player );
		return;
	}
	if ( isDefined( player.screecher_seen_hint ) && !player.screecher_seen_hint )
	{
		player thread screecher_first_seen_hint_think();
		player.screecher_seen_hint = 1;
	}
	if ( screecher_should_runaway( player ) )
	{
		self thread screecher_detach( player );
		player thread do_player_general_vox( "general", "screecher_jumpoff" );
		return;
	}
	if ( self.attack_time < getTime() )
	{
		scratch_score = 5;
		players = get_players();
		self.screecher_score += scratch_score;
		killed_player = self screecher_check_score();
		if ( player.health > 0 && isDefined( killed_player ) && !killed_player )
		{
			self.attack_delay = self.attack_delay_base + randomint( self.attack_delay_offset );
			self.attack_time = getTime() + self.attack_delay;
			self thread claw_fx( player, self.attack_delay * 0,001 );
			self playsound( "zmb_vocals_screecher_attack" );
			player playsoundtoplayer( "zmb_screecher_scratch", player );
			player thread do_player_general_vox( "general", "screecher_attack" );
			players = get_players();
			if ( players.size == 1 )
			{
				if ( level.near_miss == 0 )
				{
					level.near_miss = 1;
/#
					screecher_print( "first attack near_miss " + level.near_miss );
#/
				}
			}
		}
	}
}

screecher_runaway()
{
	self endon( "death" );
/#
	screecher_print( "runaway" );
#/
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self notify( "runaway" );
	self.state = "runaway";
	self.ignoreall = 1;
	self setgoalpos( self.startinglocation );
	self waittill( "goal" );
	playfx( level._effect[ "screecher_spawn_b" ], self.origin, ( 0, 0, 1 ) );
	self.no_powerups = 1;
	self setfreecameralockonallowed( 0 );
	self animscripted( self.origin, self.angles, "zm_burrow" );
	self playsound( "zmb_screecher_dig" );
	maps/mp/animscripts/zm_shared::donotetracks( "burrow_anim" );
	self delete();
}

screecher_detach( player )
{
	self endon( "death" );
	self.state = "detached";
	if ( !isDefined( self.linked_ent ) )
	{
		return;
	}
/#
	screecher_print( "detach" );
#/
	if ( isDefined( player ) )
	{
		player clientnotify( "scrEnd" );
		if ( isDefined( player.isonbus ) && !player.isonbus )
		{
			player allowprone( 1 );
		}
		player takeweapon( "screecher_arms_zm" );
		if ( !getDvarInt( #"E7EF8EB7" ) )
		{
			player stoppoisoning();
		}
		if ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isDefined( player.intermission ) && !player.intermission )
		{
			player decrement_is_drinking();
		}
		if ( isDefined( player.screecher_weapon ) && player.screecher_weapon != "none" && is_player_valid( player ) && !is_equipment_that_blocks_purchase( player.screecher_weapon ) )
		{
			player switchtoweapon( player.screecher_weapon );
		}
		else
		{
			if ( flag( "solo_game" ) && player hasperk( "specialty_quickrevive" ) )
			{
			}
			else
			{
				if ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
				{
					primaryweapons = player getweaponslistprimaries();
					if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
					{
						player switchtoweapon( primaryweapons[ 0 ] );
					}
				}
			}
		}
		player.screecher_weapon = undefined;
	}
	self unlink();
	self setclientfield( "render_third_person", 0 );
	if ( isDefined( self.linked_ent ) )
	{
		self.linked_ent.screecher = undefined;
		self.linked_ent setmovespeedscale( 1 );
		self.linked_ent = undefined;
	}
	self.green_light = player.green_light;
	self animcustom( ::screecher_jump_down );
	self waittill( "jump_down_done" );
	maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_ai_screecher_blur", player );
	self animmode( "normal" );
	self.ignoreall = 1;
	self setplayercollision( 1 );
	if ( isDefined( level.screecher_should_burrow ) )
	{
		if ( self [[ level.screecher_should_burrow ]]() )
		{
/#
			screecher_print( "should burrow" );
#/
			return;
		}
	}
	self thread screecher_runaway();
}

screecher_jump_down()
{
	self endon( "death" );
	self setanimstatefromasd( "zm_headpull_success" );
	wait 0,6;
	self notify( "jump_down_done" );
}

create_claw_fx_hud( player )
{
	self.claw_fx = newclienthudelem( player );
	self.claw_fx.horzalign = "fullscreen";
	self.claw_fx.vertalign = "fullscreen";
}

choose_claw_fx()
{
	direction = [];
	direction[ direction.size ] = "fullscreen_claw_left";
	direction[ direction.size ] = "fullscreen_claw_right";
	direction[ direction.size ] = "fullscreen_claw_bottom";
	direction = array_randomize( direction );
	self.claw_fx setshader( direction[ 0 ], 640, 480 );
	self.claw_fx.alpha = 1;
}

claw_fx( player, timeout )
{
	self endon( "death" );
	claw_timeout = 0,25;
	if ( !isDefined( self.claw_fx ) )
	{
		self create_claw_fx_hud( player );
	}
	self choose_claw_fx();
	self.claw_fx fadeovertime( claw_timeout );
	self.claw_fx.alpha = 0;
	earthquake( randomfloatrange( 0,4, 0,5 ), claw_timeout, player.origin, 250 );
	maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_ai_screecher_blur", player, 0,25 );
}

screecher_cleanup()
{
	self waittill( "death", attacker );
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		if ( isDefined( self.damagelocation ) && isDefined( self.damagemod ) )
		{
			level thread maps/mp/zombies/_zm_audio::player_zombie_kill_vox( self.damagelocation, attacker, self.damagemod, self );
		}
	}
	if ( isDefined( self.loopsoundent ) )
	{
		self.loopsoundent delete();
		self.loopsoundent = undefined;
	}
	player = self.linked_ent;
	if ( isDefined( player ) )
	{
		player playsound( "zmb_vocals_screecher_death" );
		player setmovespeedscale( 1 );
		maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_ai_screecher_blur", player );
		if ( isDefined( player.screecher_weapon ) )
		{
			player clientnotify( "scrEnd" );
			if ( isDefined( player.isonbus ) && !player.isonbus )
			{
				player allowprone( 1 );
			}
			player takeweapon( "screecher_arms_zm" );
			if ( !getDvarInt( #"E7EF8EB7" ) )
			{
				player stoppoisoning();
			}
			if ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isDefined( player.intermission ) && !player.intermission )
			{
				player decrement_is_drinking();
			}
			if ( player.screecher_weapon != "none" && is_player_valid( player ) )
			{
				player switchtoweapon( player.screecher_weapon );
			}
			else
			{
				primaryweapons = player getweaponslistprimaries();
				if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
				{
					player switchtoweapon( primaryweapons[ 0 ] );
				}
			}
			player.screecher_weapon = undefined;
		}
	}
	if ( isDefined( self.claw_fx ) )
	{
		self.claw_fx destroy();
	}
	if ( isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	if ( isDefined( level.screecher_cleanup ) )
	{
		self [[ level.screecher_cleanup ]]();
	}
	if ( level.zombie_screecher_count > 0 )
	{
		level.zombie_screecher_count--;

/#
		screecher_print( "screecher total " + level.zombie_screecher_count );
#/
	}
}

screecher_distance_tracking()
{
	self endon( "death" );
	while ( 1 )
	{
		can_delete = 1;
		players = get_players();
		_a1304 = players;
		_k1304 = getFirstArrayKey( _a1304 );
		while ( isDefined( _k1304 ) )
		{
			player = _a1304[ _k1304 ];
			if ( player.sessionstate == "spectator" )
			{
			}
			else dist_sq = distancesquared( self.origin, player.origin );
			if ( dist_sq >= 4000000 )
			{
			}
			else
			{
				can_see = player maps/mp/zombies/_zm_utility::is_player_looking_at( self.origin, 0,9, 0 );
				if ( can_see || dist_sq < 1000000 )
				{
					can_delete = 0;
					break;
				}
			}
			else
			{
				_k1304 = getNextArrayKey( _a1304, _k1304 );
			}
		}
		if ( can_delete )
		{
			self notify( "zombie_delete" );
			if ( isDefined( self.anchor ) )
			{
				self.anchor delete();
			}
			self delete();
			recalc_zombie_array();
		}
		wait 0,1;
	}
}

screecher_melee_button_watcher()
{
	self endon( "death" );
	while ( isDefined( self.linked_ent ) )
	{
		player = self.linked_ent;
		while ( player meleebuttonpressed() && player ismeleeing() )
		{
			self screecher_melee_damage( player );
			while ( player meleebuttonpressed() || player ismeleeing() )
			{
				wait 0,05;
			}
		}
		wait 0,05;
	}
}

screecher_melee_damage( player )
{
	one_player = 0;
	melee_score = 0;
	if ( player hasweapon( "bowie_knife_zm" ) )
	{
		if ( one_player )
		{
			melee_score = 30;
		}
		else
		{
			melee_score = 10;
		}
	}
	else if ( player hasweapon( "tazer_knuckles_zm" ) )
	{
		if ( one_player )
		{
			melee_score = 30;
		}
		else
		{
			melee_score = 15;
		}
	}
	else if ( one_player )
	{
		melee_score = 15;
	}
	else
	{
		melee_score = 6;
	}
	extra_score = 0;
	if ( self.screecher_score > 0 && !one_player )
	{
		if ( melee_score > self.screecher_score )
		{
			extra_score = melee_score - self.screecher_score;
			self.screecher_score = 0;
		}
		else
		{
			self.screecher_score -= melee_score;
		}
	}
	if ( self.screecher_score <= 0 || one_player )
	{
		self.player_score += melee_score;
		if ( extra_score > 0 )
		{
			self.player_score += extra_score;
		}
	}
	self playsound( "zmb_vocals_screecher_pain" );
	if ( level.zombie_vars[ player.team ][ "zombie_insta_kill" ] )
	{
		self.player_score = 30;
	}
	else
	{
		player thread do_player_general_vox( "general", "screecher_cut" );
	}
/#
	if ( getDvarInt( #"6A65F83E" ) )
	{
		self.player_score = 30;
#/
	}
	self screecher_check_score();
}

screecher_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( isDefined( self.linked_ent ) )
	{
		if ( isplayer( einflictor ) && smeansofdeath == "MOD_MELEE" )
		{
			return 0;
		}
	}
	return idamage;
}

screecher_death_func()
{
	self unlink();
	self.noragdoll = 1;
	self setanimstatefromasd( "zm_death" );
	maps/mp/animscripts/zm_shared::donotetracks( "death_anim" );
	playfx( level._effect[ "screecher_death" ], self.origin );
	if ( isDefined( self.attacker ) && isplayer( self.attacker ) )
	{
		self.attacker maps/mp/zombies/_zm_stats::increment_client_stat( "screechers_killed", 0 );
		self.attacker maps/mp/zombies/_zm_stats::increment_player_stat( "screechers_killed" );
	}
	self delete();
	return 1;
}

screecher_check_score()
{
	if ( self.player_score >= 30 )
	{
		player = self.linked_ent;
		if ( isDefined( player ) )
		{
			player notify( "i_dont_think_they_exist" );
			player maps/mp/zombies/_zm_stats::increment_client_stat( "screecher_minigames_won", 0 );
			player maps/mp/zombies/_zm_stats::increment_player_stat( "screecher_minigames_won" );
		}
		self dodamage( self.health + 666, self.origin );
	}
	else
	{
		if ( self.screecher_score >= 15 )
		{
/#
			if ( getDvarInt( #"6A65F83E" ) )
			{
				return 0;
#/
			}
			player = self.linked_ent;
			if ( isDefined( player ) )
			{
				self.meleedamage = player.health;
				player dodamage( player.health, self.origin, self );
				self screecher_detach( player );
				player maps/mp/zombies/_zm_stats::increment_client_stat( "screecher_minigames_lost", 0 );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "screecher_minigames_lost" );
				return 1;
			}
		}
	}
/#
	screecher_print( "score: player " + self.player_score + " screecher " + self.screecher_score );
#/
	return 0;
}

kill_all_players()
{
	foreach ( player in level.players )
	{
		player doDamage( player.health + 666, player.origin );
	}
}

screecher_debug_axis()
{
/#
	self endon( "death" );
	while ( 1 )
	{
		if ( isDefined( self.favoriteenemy ) )
		{
			player = self.favoriteenemy;
			anim_id = self getanimfromasd( "zm_jump_land_success", 0 );
			org = getstartorigin( player.origin, player.angles, anim_id );
			angles = getstartangles( player.origin, player.angles, anim_id );
			if ( !isDefined( player.bone_fxaxis ) )
			{
				player.bone_fxaxis = spawn( "script_model", org );
				player.bone_fxaxis setmodel( "fx_axis_createfx" );
			}
			if ( isDefined( player.bone_fxaxis ) )
			{
				player.bone_fxaxis.origin = org;
				player.bone_fxaxis.angles = angles;
			}
		}
		wait 0,1;
#/
	}
}

screecher_print( str )
{
/#
	if ( getDvarInt( #"72C3A9C6" ) )
	{
		iprintln( "screecher: " + str + "\n" );
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
