#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zm_tomb_chamber;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_ai_mechz;
#include maps/mp/zombies/_zm_ai_mechz_ffotd;
#include maps/mp/zombies/_zm_ai_mechz_booster;
#include maps/mp/zombies/_zm_ai_mechz_ft;
#include maps/mp/zombies/_zm_ai_mechz_claw;
#include maps/mp/zombies/_zm_ai_mechz_dev;
#include maps/mp/zm_tomb_tank;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_net;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_zonemgr;

#using_animtree( "mechz_claw" );

precache()
{
	level thread mechz_setup_armor_pieces();
	precachemodel( "c_zom_mech_claw" );
	precachemodel( "c_zom_mech_faceplate" );
	precachemodel( "c_zom_mech_powersupply_cap" );
	level._effect[ "mech_dmg_sparks" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_sparks" );
	level._effect[ "mech_dmg_steam" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_steam" );
	level._effect[ "mech_booster" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_jump_booster" );
	level._effect[ "mech_wpn_source" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_wpn_source" );
	level._effect[ "mech_wpn_flamethrower" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_wpn_flamethrower" );
	level._effect[ "mech_booster_landing" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_jump_landing" );
	level._effect[ "mech_faceplate_dmg" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_armor_face" );
	level._effect[ "mech_armor_dmg" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_armor" );
	level._effect[ "mech_exhaust" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_exhaust_smoke" );
	level._effect[ "mech_booster_feet" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_jump_booster_sm" );
	level._effect[ "mech_headlamp" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_head_light" );
	level._effect[ "mech_footstep_steam" ] = loadfx( "maps/zombie_tomb/fx_tomb_mech_foot_step_steam" );
	setdvar( "zombie_double_wide_checks", 1 );
	precacherumble( "mechz_footsteps" );
	precacheshellshock( "lava_small" );
}

init()
{
	maps/mp/zombies/_zm_ai_mechz_ffotd::mechz_init_start();
	level.mechz_spawners = getentarray( "mechz_spawner", "script_noteworthy" );
	if ( level.mechz_spawners.size == 0 )
	{
		return;
	}
	i = 0;
	while ( i < level.mechz_spawners.size )
	{
		level.mechz_spawners[ i ].is_enabled = 1;
		level.mechz_spawners[ i ].script_forcespawn = 1;
		i++;
	}
	level.mechz_base_health = 5000;
	level.mechz_health = level.mechz_base_health;
	level.mechz_health_increase = 1000;
	level.mechz_round_count = 0;
	level.mechz_damage_percent = 0,1;
	level.mechz_remove_helmet_head_dmg_base = 500;
	level.mechz_remove_helmet_head_dmg = level.mechz_remove_helmet_head_dmg_base;
	level.mechz_remove_helmet_head_dmg_increase = 250;
	level.mechz_explosive_dmg_head_scaler = 0,25;
	level.mechz_helmet_health_percentage = 0,1;
	level.mechz_powerplant_expose_dmg_base = 300;
	level.mechz_powerplant_expose_dmg = level.mechz_powerplant_expose_base_dmg;
	level.mechz_powerplant_expose_dmg_increase = 100;
	level.mechz_powerplant_destroy_dmg_base = 500;
	level.mechz_powerplant_destroy_dmg = level.mechz_powerplant_destroy_dmg_base;
	level.mechz_powerplant_destroy_dmg_increase = 150;
	level.mechz_powerplant_expose_health_percentage = 0,05;
	level.mechz_powerplant_destroyed_health_percentage = 0,025;
	level.mechz_explosive_dmg_to_cancel_claw_percentage = 0,1;
	level.mechz_min_round_fq = 3;
	level.mechz_max_round_fq = 4;
	level.mechz_min_round_fq_solo = 4;
	level.mechz_max_round_fq_solo = 6;
	level.mechz_reset_dist_sq = 65536;
	level.mechz_sticky_dist_sq = 1048576;
	level.mechz_aggro_dist_sq = 16384;
	level.mechz_zombie_per_round = 1;
	level.mechz_left_to_spawn = 0;
	level.mechz_players_in_zone_spawn_point_cap = 120;
	level.mechz_shotgun_damage_mod = 1,5;
	level.mechz_failed_paths_to_jump = 3;
	level.mechz_jump_dist_threshold = 4410000;
	level.mechz_jump_delay = 3;
	level.mechz_player_flame_dmg = 10;
	level.mechz_half_front_arc = cos( 45 );
	level.mechz_ft_sweep_chance = 10;
	level.mechz_aim_max_pitch = 60;
	level.mechz_aim_max_yaw = 45;
	level.mechz_custom_goalradius = 48;
	level.mechz_custom_goalradius_sq = level.mechz_custom_goalradius * level.mechz_custom_goalradius;
	level.mechz_tank_knockdown_time = 5;
	level.mechz_robot_knockdown_time = 10;
	level.mechz_dist_for_sprint = 129600;
	level.mechz_dist_for_stop_sprint = 57600;
	level.mechz_claw_cooldown_time = 7000;
	level.mechz_flamethrower_cooldown_time = 5000;
	level.mechz_min_extra_spawn = 8;
	level.mechz_max_extra_spawn = 11;
	level.mechz_points_for_killer = 250;
	level.mechz_points_for_team = 500;
	level.mechz_points_for_helmet = 100;
	level.mechz_points_for_powerplant = 100;
	level.mechz_flogger_stun_time = 3;
	level.mechz_powerplant_stun_time = 4;
	flag_init( "mechz_launching_claw" );
	flag_init( "mechz_claw_move_complete" );
	registerclientfield( "actor", "mechz_fx", 14000, 12, "int" );
	registerclientfield( "toplayer", "mechz_grab", 14000, 1, "int" );
	level thread init_flamethrower_triggers();
	if ( isDefined( level.mechz_spawning_logic_override_func ) )
	{
		level thread [[ level.mechz_spawning_logic_override_func ]]();
	}
	else
	{
		level thread mechz_spawning_logic();
	}
	scriptmodelsuseanimtree( -1 );
/#
	setup_devgui();
#/
	maps/mp/zombies/_zm_ai_mechz_ffotd::mechz_init_end();
}

mechz_setup_armor_pieces()
{
	level.mechz_armor_info = [];
	level.mechz_armor_info[ 0 ] = spawnstruct();
	level.mechz_armor_info[ 0 ].model = "c_zom_mech_armor_knee_left";
	level.mechz_armor_info[ 0 ].tag = "J_Knee_Attach_LE";
	level.mechz_armor_info[ 1 ] = spawnstruct();
	level.mechz_armor_info[ 1 ].model = "c_zom_mech_armor_knee_right";
	level.mechz_armor_info[ 1 ].tag = "J_Knee_attach_RI";
	level.mechz_armor_info[ 2 ] = spawnstruct();
	level.mechz_armor_info[ 2 ].model = "c_zom_mech_armor_shoulder_left";
	level.mechz_armor_info[ 2 ].tag = "J_ShoulderArmor_LE";
	level.mechz_armor_info[ 3 ] = spawnstruct();
	level.mechz_armor_info[ 3 ].model = "c_zom_mech_armor_shoulder_right";
	level.mechz_armor_info[ 3 ].tag = "J_ShoulderArmor_RI";
	level.mechz_armor_info[ 4 ] = spawnstruct();
	level.mechz_armor_info[ 4 ].tag = "J_Root_Attach_LE";
	level.mechz_armor_info[ 5 ] = spawnstruct();
	level.mechz_armor_info[ 5 ].tag = "J_Root_Attach_RI";
	i = 0;
	while ( i < level.mechz_armor_info.size )
	{
		if ( isDefined( level.mechz_armor_info[ i ].model ) )
		{
			precachemodel( level.mechz_armor_info[ i ].model );
		}
		i++;
	}
}

mechz_setup_fx()
{
	self.fx_field = 0;
	self thread booster_fx_watcher();
	self thread flamethrower_fx_watcher();
}

clear_one_off_fx( fx_id )
{
	self endon( "death" );
	wait 10;
	self.fx_field &= fx_id;
	self setclientfield( "mechz_fx", self.fx_field );
}

traversal_booster_fx_watcher()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "traverse_anim", notetrack );
		if ( notetrack == "booster_on" )
		{
			self.fx_field |= 128;
			self.sndloopent playsound( "zmb_ai_mechz_rocket_start" );
			self.sndloopent playloopsound( "zmb_ai_mechz_rocket_loop", 0,75 );
		}
		else
		{
			if ( notetrack == "booster_off" )
			{
				self.fx_field &= 128;
				self.sndloopent playsound( "zmb_ai_mechz_rocket_stop" );
				self.sndloopent stoploopsound( 1 );
			}
		}
		self setclientfield( "mechz_fx", self.fx_field );
	}
}

booster_fx_watcher()
{
	self endon( "death" );
	self thread traversal_booster_fx_watcher();
	while ( 1 )
	{
		self waittill( "jump_anim", notetrack );
		if ( isDefined( self.mechz_hidden ) && self.mechz_hidden )
		{
			continue;
		}
		if ( notetrack == "booster_on" )
		{
			self.fx_field |= 128;
			self.sndloopent playsound( "zmb_ai_mechz_rocket_start" );
			self.sndloopent playloopsound( "zmb_ai_mechz_rocket_loop", 0,75 );
		}
		else if ( notetrack == "booster_off" )
		{
			self.fx_field &= 128;
			self.sndloopent playsound( "zmb_ai_mechz_rocket_stop" );
			self.sndloopent stoploopsound( 1 );
		}
		else
		{
			if ( notetrack == "impact" )
			{
				self.fx_field |= 512;
				if ( isDefined( self.has_helmet ) && self.has_helmet )
				{
					self.fx_field |= 2048;
				}
				self thread clear_one_off_fx( 512 );
			}
		}
		self setclientfield( "mechz_fx", self.fx_field );
	}
}

flamethrower_fx_watcher()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "flamethrower_anim", notetrack );
		if ( notetrack == "start_ft" )
		{
			self.fx_field |= 64;
		}
		else
		{
			if ( notetrack == "stop_ft" )
			{
				self.fx_field &= 64;
			}
		}
		self setclientfield( "mechz_fx", self.fx_field );
	}
}

fx_cleanup()
{
	self.fx_field = 0;
	self setclientfield( "mechz_fx", self.fx_field );
	wait_network_frame();
}

mechz_setup_snd()
{
	self.audio_type = "mechz";
	if ( !isDefined( self.sndloopent ) )
	{
		self.sndloopent = spawn( "script_origin", self.origin );
		self.sndloopent linkto( self, "tag_origin" );
		self thread snddeleteentondeath( self.sndloopent );
	}
	self thread play_ambient_mechz_vocals();
}

snddeleteentondeath( ent )
{
	self waittill( "death" );
	ent delete();
}

play_ambient_mechz_vocals()
{
	self endon( "death" );
	wait randomintrange( 2, 4 );
	while ( 1 )
	{
		if ( isDefined( self ) )
		{
			if ( isDefined( self.favoriteenemy ) && distance( self.origin, self.favoriteenemy.origin ) <= 150 )
			{
				break;
			}
			else
			{
				self playsound( "zmb_ai_mechz_vox_ambient" );
			}
		}
		wait randomfloatrange( 3, 6 );
	}
}

enable_mechz_rounds()
{
/#
	if ( getDvarInt( "zombie_cheat" ) >= 2 )
	{
		return;
#/
	}
	level.mechz_rounds_enabled = 1;
	flag_init( "mechz_round" );
	level thread mechz_round_tracker();
}

mechz_round_tracker()
{
	maps/mp/zombies/_zm_ai_mechz_ffotd::mechz_round_tracker_start();
	level.num_mechz_spawned = 0;
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while ( !isDefined( level.zombie_mechz_locations ) )
	{
		wait 0,05;
	}
	flag_wait( "activate_zone_nml" );
	mech_start_round_num = 8;
	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		mech_start_round_num = 8;
	}
	while ( level.round_number < mech_start_round_num )
	{
		level waittill( "between_round_over" );
	}
	level.next_mechz_round = level.round_number;
	level thread debug_print_mechz_round();
	while ( 1 )
	{
		maps/mp/zombies/_zm_ai_mechz_ffotd::mechz_round_tracker_loop_start();
		if ( level.num_mechz_spawned > 0 )
		{
			level.mechz_should_drop_powerup = 1;
		}
		while ( level.next_mechz_round <= level.round_number )
		{
			a_zombies = getaispeciesarray( level.zombie_team, "all" );
			_a485 = a_zombies;
			_k485 = getFirstArrayKey( _a485 );
			while ( isDefined( _k485 ) )
			{
				zombie = _a485[ _k485 ];
				if ( isDefined( zombie.is_mechz ) && zombie.is_mechz && isalive( zombie ) )
				{
					level.next_mechz_round++;
					break;
				}
				else
				{
					_k485 = getNextArrayKey( _a485, _k485 );
				}
			}
		}
		if ( level.mechz_left_to_spawn == 0 && level.next_mechz_round <= level.round_number )
		{
			mechz_health_increases();
			if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
			{
				level.mechz_zombie_per_round = 1;
			}
			else
			{
				if ( level.mechz_round_count < 2 )
				{
					level.mechz_zombie_per_round = 1;
					break;
				}
				else if ( level.mechz_round_count < 5 )
				{
					level.mechz_zombie_per_round = 2;
					break;
				}
				else
				{
					level.mechz_zombie_per_round = 3;
				}
			}
			level.mechz_left_to_spawn = level.mechz_zombie_per_round;
			mechz_spawning = level.mechz_left_to_spawn;
			wait randomfloatrange( 10, 15 );
			level notify( "spawn_mechz" );
			if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
			{
				n_round_gap = randomintrange( level.mechz_min_round_fq_solo, level.mechz_max_round_fq_solo );
			}
			else
			{
				n_round_gap = randomintrange( level.mechz_min_round_fq, level.mechz_max_round_fq );
			}
			level.next_mechz_round = level.round_number + n_round_gap;
			level.mechz_round_count++;
			level thread debug_print_mechz_round();
			level.num_mechz_spawned += mechz_spawning;
		}
		maps/mp/zombies/_zm_ai_mechz_ffotd::mechz_round_tracker_loop_end();
		level waittill( "between_round_over" );
		mechz_clear_spawns();
	}
}

debug_print_mechz_round()
{
	flag_wait( "start_zombie_round_logic" );
/#
	iprintln( "Next mechz Round = " + level.next_mechz_round );
#/
}

mechz_spawning_logic()
{
	level thread enable_mechz_rounds();
	while ( 1 )
	{
		level waittill( "spawn_mechz" );
		while ( level.mechz_left_to_spawn )
		{
			while ( level.zombie_mechz_locations.size < 1 )
			{
				wait randomfloatrange( 5, 10 );
			}
			ai = spawn_zombie( level.mechz_spawners[ 0 ] );
			ai thread mechz_spawn();
			level.mechz_left_to_spawn--;

			if ( level.mechz_left_to_spawn == 0 )
			{
				level thread response_to_air_raid_siren_vo();
			}
			ai thread mechz_hint_vo();
			wait randomfloatrange( 3, 6 );
		}
	}
}

mechz_prespawn()
{
}

mechz_attach_objects()
{
	self detachall();
	self.armor_state = [];
	i = 0;
	while ( i < level.mechz_armor_info.size )
	{
		self.armor_state[ i ] = spawnstruct();
		self.armor_state[ i ].index = i;
		self.armor_state[ i ].tag = level.mechz_armor_info[ i ].tag;
		if ( isDefined( level.mechz_armor_info[ i ].model ) )
		{
			self attach( level.mechz_armor_info[ i ].model, level.mechz_armor_info[ i ].tag, 1 );
			self.armor_state[ i ].model = level.mechz_armor_info[ i ].model;
		}
		i++;
	}
	if ( isDefined( self.m_claw ) )
	{
		self.m_claw delete();
		self.m_claw = undefined;
	}
	org = self gettagorigin( "tag_claw" );
	ang = self gettagangles( "tag_claw" );
	self.m_claw = spawn( "script_model", org );
	self.m_claw setmodel( "c_zom_mech_claw" );
	self.m_claw.angles = ang;
	self.m_claw linkto( self, "tag_claw" );
	self.m_claw useanimtree( -1 );
	if ( isDefined( self.m_claw_damage_trigger ) )
	{
		self.m_claw_damage_trigger unlink();
		self.m_claw_damage_trigger delete();
		self.m_claw_damage_trigger = undefined;
	}
	trigger_spawnflags = 0;
	trigger_radius = 3;
	trigger_height = 15;
	self.m_claw_damage_trigger = spawn( "trigger_damage", org, trigger_spawnflags, trigger_radius, trigger_height );
	self.m_claw_damage_trigger.angles = ang;
	self.m_claw_damage_trigger enablelinkto();
	self.m_claw_damage_trigger linkto( self, "tag_claw" );
	self thread mechz_claw_damage_trigger_thread();
	self attach( "c_zom_mech_faceplate", "J_Helmet", 0 );
	self.has_helmet = 1;
	self attach( "c_zom_mech_powersupply_cap", "tag_powersupply", 0 );
	self.has_powerplant = 1;
	self.powerplant_covered = 1;
	self.armor_state = array_randomize( self.armor_state );
}

mechz_set_starting_health()
{
	self.maxhealth = level.mechz_health;
	self.helmet_dmg = 0;
	self.helmet_dmg_for_removal = self.maxhealth * level.mechz_helmet_health_percentage;
	self.powerplant_cover_dmg = 0;
	self.powerplant_cover_dmg_for_removal = self.maxhealth * level.mechz_powerplant_expose_health_percentage;
	self.powerplant_dmg = 0;
	self.powerplant_dmg_for_destroy = self.maxhealth * level.mechz_powerplant_destroyed_health_percentage;
	level.mechz_explosive_dmg_to_cancel_claw = self.maxhealth * level.mechz_explosive_dmg_to_cancel_claw_percentage;
/#
	if ( getDvarInt( #"E7121222" ) > 0 )
	{
		println( "\nMZ: MechZ Starting Health: " + self.maxhealth );
		println( "\nMZ: MechZ Required Helmet Dmg: " + self.helmet_dmg_for_removal );
		println( "\nMZ: MechZ Required Powerplant Cover Dmg: " + self.powerplant_cover_dmg_for_removal );
		println( "\nMZ: MechZ Required Powerplant Dmg: " + self.powerplant_dmg_for_destroy );
#/
	}
	self.health = level.mechz_health;
	self.non_attacker_func = ::mechz_non_attacker_damage_override;
	self.non_attack_func_takes_attacker = 1;
	self.actor_damage_func = ::mechz_damage_override;
	self.instakill_func = ::mechz_instakill_override;
	self.nuke_damage_func = ::mechz_nuke_override;
}

mechz_spawn()
{
	self maps/mp/zombies/_zm_ai_mechz_ffotd::spawn_start();
	self endon( "death" );
	level endon( "intermission" );
	self mechz_attach_objects();
	self mechz_set_starting_health();
	self mechz_setup_fx();
	self mechz_setup_snd();
	level notify( "sam_clue_mechz" );
	self.closest_player_override = ::get_favorite_enemy;
	self.animname = "mechz_zombie";
	self.has_legs = 1;
	self.no_gib = 1;
	self.ignore_all_poi = 1;
	self.is_mechz = 1;
	self.ignore_enemy_count = 1;
	self.no_damage_points = 1;
	self.melee_anim_func = ::melee_anim_func;
	self.meleedamage = 75;
	self.custom_item_dmg = 2000;
	recalc_zombie_array();
	self setphysparams( 20, 0, 80 );
	self setcandamage( 0 );
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
	self.allowpain = 0;
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self maps/mp/zombies/_zm_spawner::zombie_setup_attack_properties();
	self.completed_emerging_into_playable_area = 1;
	self notify( "completed_emerging_into_playable_area" );
	self.no_powerups = 0;
	self setfreecameralockonallowed( 0 );
	self notsolid();
	self thread maps/mp/zombies/_zm_spawner::zombie_eye_glow();
	level thread maps/mp/zombies/_zm_spawner::zombie_death_event( self );
	self thread maps/mp/zombies/_zm_spawner::enemy_death_detection();
	if ( level.zombie_mechz_locations.size )
	{
		spawn_pos = self get_best_mechz_spawn_pos();
	}
	if ( !isDefined( spawn_pos ) )
	{
/#
		println( "ERROR: Tried to spawn mechz with no mechz spawn_positions!\n" );
		iprintln( "ERROR: Tried to spawn mechz with no mechz spawn_positions!" );
#/
		self delete();
		return;
	}
	if ( isDefined( level.mechz_force_spawn_pos ) )
	{
		spawn_pos = level.mechz_force_spawn_pos;
		level.mechz_force_spawn_pos = undefined;
	}
	if ( !isDefined( spawn_pos.angles ) )
	{
		spawn_pos.angles = ( 0, 0, 1 );
	}
	self thread mechz_death();
	self forceteleport( spawn_pos.origin, spawn_pos.angles );
	self playsound( "zmb_ai_mechz_incoming_alarm" );
	if ( !isDefined( spawn_pos.angles ) )
	{
		spawn_pos.angles = ( 0, 0, 1 );
	}
	self animscripted( spawn_pos.origin, spawn_pos.angles, "zm_spawn" );
	self maps/mp/animscripts/zm_shared::donotetracks( "jump_anim" );
	self setfreecameralockonallowed( 1 );
	self solid();
	self set_zombie_run_cycle( "walk" );
	if ( isDefined( level.mechz_find_flesh_override_func ) )
	{
		level thread [[ level.mechz_find_flesh_override_func ]]();
	}
	else
	{
		self thread mechz_find_flesh();
	}
	self thread mechz_jump_think( spawn_pos );
	self setcandamage( 1 );
	self init_anim_rate();
	self maps/mp/zombies/_zm_ai_mechz_ffotd::spawn_end();
}

get_closest_mechz_spawn_pos( org )
{
	best_dist = -1;
	best_pos = undefined;
	players = get_players();
	i = 0;
	while ( i < level.zombie_mechz_locations.size )
	{
		dist = distancesquared( org, level.zombie_mechz_locations[ i ].origin );
		if ( dist < best_dist || best_dist < 0 )
		{
			best_dist = dist;
			best_pos = level.zombie_mechz_locations[ i ];
		}
		i++;
	}
/#
	if ( !isDefined( best_pos ) )
	{
		println( "Error: Mechz could not find a valid jump pos from position ( " + self.origin[ 0 ] + ", " + self.origin[ 1 ] + ", " + self.origin[ 2 ] + " )" );
#/
	}
	return best_pos;
}

get_best_mechz_spawn_pos( ignore_used_positions )
{
	if ( !isDefined( ignore_used_positions ) )
	{
		ignore_used_positions = 0;
	}
	best_dist = -1;
	best_pos = undefined;
	players = get_players();
	i = 0;
	while ( i < level.zombie_mechz_locations.size )
	{
		if ( !ignore_used_positions && isDefined( level.zombie_mechz_locations[ i ].has_been_used ) && level.zombie_mechz_locations[ i ].has_been_used )
		{
			i++;
			continue;
		}
		else
		{
			if ( ignore_used_positions == 1 && isDefined( level.zombie_mechz_locations[ i ].used_cooldown ) && level.zombie_mechz_locations[ i ].used_cooldown )
			{
				i++;
				continue;
			}
			else
			{
				j = 0;
				while ( j < players.size )
				{
					if ( is_player_valid( players[ j ], 1, 1 ) )
					{
						dist = distancesquared( level.zombie_mechz_locations[ i ].origin, players[ j ].origin );
						if ( dist < best_dist || best_dist < 0 )
						{
							best_dist = dist;
							best_pos = level.zombie_mechz_locations[ i ];
						}
					}
					j++;
				}
			}
		}
		i++;
	}
	if ( ignore_used_positions && isDefined( best_pos ) )
	{
		best_pos thread jump_pos_used_cooldown();
	}
	if ( isDefined( best_pos ) )
	{
		best_pos.has_been_used = 1;
	}
	else
	{
		if ( level.zombie_mechz_locations.size > 0 )
		{
			return level.zombie_mechz_locations[ randomint( level.zombie_mechz_locations.size ) ];
		}
	}
	return best_pos;
}

mechz_clear_spawns()
{
	i = 0;
	while ( i < level.zombie_mechz_locations.size )
	{
		level.zombie_mechz_locations[ i ].has_been_used = 0;
		i++;
	}
}

jump_pos_used_cooldown()
{
	self.used_cooldown = 1;
	wait 5;
	self.used_cooldown = 0;
}

mechz_health_increases()
{
	if ( !isDefined( level.mechz_last_spawn_round ) || level.round_number > level.mechz_last_spawn_round )
	{
		a_players = getplayers();
		n_player_modifier = 1;
		if ( a_players.size > 1 )
		{
			n_player_modifier = a_players.size * 0,75;
		}
		level.mechz_health = int( n_player_modifier * ( level.mechz_base_health + ( level.mechz_health_increase * level.mechz_round_count ) ) );
		if ( level.mechz_health >= ( 22500 * n_player_modifier ) )
		{
			level.mechz_health = int( 22500 * n_player_modifier );
		}
		level.mechz_last_spawn_round = level.round_number;
	}
}

mechz_death()
{
	self endon( "mechz_cleanup" );
	thread mechz_cleanup();
	self waittill( "death" );
	death_origin = self.origin;
	if ( isDefined( self.robot_stomped ) && self.robot_stomped )
	{
		death_origin += vectorScale( ( 0, 0, 1 ), 90 );
	}
	self mechz_claw_detach();
	self release_flamethrower_trigger();
	self.fx_field = 0;
	self setclientfield( "mechz_fx", self.fx_field );
	self thread maps/mp/zombies/_zm_spawner::zombie_eye_glow_stop();
	self mechz_interrupt();
	if ( isDefined( self.favoriteenemy ) )
	{
		if ( isDefined( self.favoriteenemy.hunted_by ) )
		{
			self.favoriteenemy.hunted_by--;

		}
	}
	self thread mechz_explode( "tag_powersupply", death_origin );
	if ( get_current_zombie_count() == 0 && level.zombie_total == 0 )
	{
		level.last_mechz_origin = self.origin;
		level notify( "last_mechz_down" );
	}
	if ( isplayer( self.attacker ) )
	{
		event = "death";
		if ( issubstr( self.damageweapon, "knife_ballistic_" ) )
		{
			event = "ballistic_knife_death";
		}
		self.attacker delay_thread( 4, ::maps/mp/zombies/_zm_audio::create_and_play_dialog, "general", "mech_defeated" );
		self.attacker maps/mp/zombies/_zm_score::player_add_points( event, self.damagemod, self.damagelocation, 1 );
		self.attacker maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_mechz_killed", 0 );
		self.attacker maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_mechz_killed" );
		if ( isDefined( level.mechz_should_drop_powerup ) && level.mechz_should_drop_powerup )
		{
			wait_network_frame();
			wait_network_frame();
			level.mechz_should_drop_powerup = 0;
			if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
			{
				level.powerup_drop_count = level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] - 1;
			}
			level.zombie_vars[ "zombie_drop_item" ] = 1;
			level thread maps/mp/zombies/_zm_powerups::powerup_drop( self.origin );
		}
	}
}

mechz_explode( str_tag, death_origin )
{
	wait 2;
	v_origin = self gettagorigin( str_tag );
	level notify( "mechz_exploded" );
	playsoundatposition( "zmb_ai_mechz_death_explode", v_origin );
	playfx( level._effect[ "mechz_death" ], v_origin );
	radiusdamage( v_origin, 128, 100, 25, undefined, "MOD_GRENADE_SPLASH" );
	earthquake( 0,5, 1, v_origin, 256 );
	playrumbleonposition( "grenade_rumble", v_origin );
	level notify( "mechz_killed" );
}

mechz_cleanup()
{
	self waittill( "mechz_cleanup" );
	self mechz_interrupt();
	level.sndmechzistalking = 0;
	if ( isDefined( self.sndmechzmusicent ) )
	{
		self.sndmechzmusicent delete();
		self.sndmechzmusicent = undefined;
	}
	if ( isDefined( self.favoriteenemy ) )
	{
		if ( isDefined( self.favoriteenemy.hunted_by ) )
		{
			self.favoriteenemy.hunted_by--;

		}
	}
}

mechz_interrupt()
{
	self notify( "kill_claw" );
	self notify( "kill_ft" );
	self notify( "kill_jump" );
}

mechz_stun( time )
{
	self endon( "death" );
	if ( isalive( self ) && isDefined( self.not_interruptable ) || self.not_interruptable && isDefined( self.is_traversing ) && self.is_traversing )
	{
		return;
	}
	curr_time = 0;
	anim_time = self getanimlengthfromasd( "zm_stun", 0 );
	self mechz_interrupt();
	self mechz_claw_detach();
	wait 0,05;
	self.not_interruptable = 1;
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Stun setting not interruptable\n" );
#/
	}
	while ( curr_time < time )
	{
		self animscripted( self.origin, self.angles, "zm_stun" );
		self maps/mp/animscripts/zm_shared::donotetracks( "stun_anim" );
		self clearanim( %root, 0 );
		curr_time += anim_time;
	}
	self.not_interruptable = 0;
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Stun clearing not interruptable\n" );
#/
	}
}

mechz_tank_hit_callback()
{
	self endon( "death" );
	if ( isDefined( self.mechz_hit_by_tank ) && self.mechz_hit_by_tank )
	{
		return;
	}
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Tank damage setting not interruptable\n" );
#/
	}
	self.not_interruptable = 1;
	self.mechz_hit_by_tank = 1;
	self mechz_interrupt();
	v_trace_start = self.origin + vectorScale( ( 0, 0, 1 ), 100 );
	v_trace_end = self.origin - vectorScale( ( 0, 0, 1 ), 500 );
	v_trace = physicstrace( self.origin, v_trace_end, ( -15, -15, -5 ), ( 15, 15, 5 ), self );
	self.origin = v_trace[ "position" ];
	timer = 0;
	self animscripted( self.origin, self.angles, "zm_tank_hit_in" );
	self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
	anim_length = self getanimlengthfromasd( "zm_tank_hit_loop", 0 );
	while ( timer < level.mechz_tank_knockdown_time )
	{
		timer += anim_length;
		self animscripted( self.origin, self.angles, "zm_tank_hit_loop" );
		self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
	}
	self animscripted( self.origin, self.angles, "zm_tank_hit_out" );
	self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Tank damage clearing not interruptable\n" );
#/
	}
	self.not_interruptable = 0;
	self.mechz_hit_by_tank = 0;
	if ( !level.vh_tank ent_flag( "tank_moving" ) && self istouching( level.vh_tank ) )
	{
		self notsolid();
		self ghost();
		self.mechz_hidden = 1;
		if ( isDefined( self.m_claw ) )
		{
			self.m_claw ghost();
		}
		self.fx_field_old = self.fx_field;
		self thread maps/mp/zombies/_zm_spawner::zombie_eye_glow_stop();
		self fx_cleanup();
		self mechz_do_jump();
		self solid();
		self.mechz_hidden = 0;
	}
}

mechz_robot_stomp_callback()
{
	self endon( "death" );
	if ( isDefined( self.robot_stomped ) && self.robot_stomped )
	{
		return;
	}
	self.not_interruptable = 1;
	self.robot_stomped = 1;
	self mechz_interrupt();
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Robot stomp setting not interruptable\n" );
#/
	}
	self thread mechz_stomped_by_giant_robot_vo();
	v_trace_start = self.origin + vectorScale( ( 0, 0, 1 ), 100 );
	v_trace_end = self.origin - vectorScale( ( 0, 0, 1 ), 500 );
	v_trace = physicstrace( self.origin, v_trace_end, ( -15, -15, -5 ), ( 15, 15, 5 ), self );
	self.origin = v_trace[ "position" ];
	timer = 0;
	self animscripted( self.origin, self.angles, "zm_robot_hit_in" );
	self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
	anim_length = self getanimlengthfromasd( "zm_robot_hit_loop", 0 );
	while ( timer < level.mechz_robot_knockdown_time )
	{
		timer += anim_length;
		self animscripted( self.origin, self.angles, "zm_robot_hit_loop" );
		self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
	}
	self animscripted( self.origin, self.angles, "zm_robot_hit_out" );
	self maps/mp/animscripts/zm_shared::donotetracks( "jump_anim" );
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Robot stomp clearing not interruptable\n" );
#/
	}
	self.not_interruptable = 0;
	self.robot_stomped = 0;
}

mechz_delayed_item_delete()
{
	wait 30;
	self delete();
}

mechz_get_closest_valid_player()
{
	players = get_players();
	while ( isDefined( self.ignore_player ) )
	{
		i = 0;
		while ( i < self.ignore_player.size )
		{
			arrayremovevalue( players, self.ignore_player[ i ] );
			i++;
		}
	}
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( level._zombie_using_humangun ) && level._zombie_using_humangun && isai( players[ i ] ) )
		{
			return players[ i ];
		}
		if ( !is_player_valid( players[ i ], 1, 1 ) )
		{
			arrayremovevalue( players, players[ i ] );
			i--;

		}
		i++;
	}
	switch( players.size )
	{
		case 0:
			return undefined;
		case 1:
			return players[ 0 ];
		default:
			if ( isDefined( level.closest_player_override ) )
			{
				player = [[ level.closest_player_override ]]( self.origin, players );
			}
			else if ( isDefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
			{
				player = get_closest_player_using_paths( self.origin, players );
			}
			else
			{
				player = getclosest( self.origin, players );
			}
			return player;
	}
}

get_favorite_enemy( origin, players )
{
	mechz_targets = getplayers();
	least_hunted = undefined;
	best_hunted_val = -1;
	best_dist = -1;
	distances = [];
	if ( isDefined( self.favoriteenemy ) && is_player_valid( self.favoriteenemy, 1, 1 ) && !isDefined( self.favoriteenemy.in_giant_robot_head ) && !self.favoriteenemy maps/mp/zm_tomb_chamber::is_player_in_chamber() )
	{
/#
		assert( isDefined( self.favoriteenemy.hunted_by ) );
#/
		self.favoriteenemy.hunted_by--;

		least_hunted = self.favoriteenemy;
	}
	i = 0;
	while ( i < mechz_targets.size )
	{
		if ( !isDefined( mechz_targets[ i ].hunted_by ) || mechz_targets[ i ].hunted_by < 0 )
		{
			mechz_targets[ i ].hunted_by = 0;
		}
		if ( !is_player_valid( mechz_targets[ i ], 1, 1 ) )
		{
			i++;
			continue;
		}
		else
		{
			distances[ i ] = distancesquared( self.origin, mechz_targets[ i ].origin );
		}
		i++;
	}
	found_weapon_target = 0;
	i = 0;
	while ( i < mechz_targets.size )
	{
		if ( abs( mechz_targets[ i ].origin[ 2 ] - self.origin[ 2 ] ) > 60 )
		{
			i++;
			continue;
		}
		else dist = distances[ i ];
		if ( !isDefined( dist ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( dist < 50000 || dist < best_dist && best_dist < 0 )
			{
				found_weapon_target = 1;
				least_hunted = mechz_targets[ i ];
				best_dist = dist;
			}
		}
		i++;
	}
	if ( found_weapon_target )
	{
		least_hunted.hunted_by++;
		return least_hunted;
	}
	if ( isDefined( self.favoriteenemy ) && is_player_valid( self.favoriteenemy, 1, 1 ) )
	{
		if ( distancesquared( self.origin, self.favoriteenemy.origin ) <= level.mechz_sticky_dist_sq )
		{
			self.favoriteenemy.hunted_by++;
			return self.favoriteenemy;
		}
	}
	i = 0;
	while ( i < mechz_targets.size )
	{
		if ( isDefined( mechz_targets[ i ].in_giant_robot_head ) )
		{
			i++;
			continue;
		}
		else if ( mechz_targets[ i ] maps/mp/zm_tomb_chamber::is_player_in_chamber() )
		{
			i++;
			continue;
		}
		else if ( isDefined( distances[ i ] ) )
		{
			dist = distances[ i ];
		}
		else
		{
		}
		hunted = mechz_targets[ i ].hunted_by;
		if ( !isDefined( least_hunted ) || hunted <= least_hunted.hunted_by )
		{
			if ( dist < best_dist || best_dist < 0 )
			{
				least_hunted = mechz_targets[ i ];
				best_dist = dist;
			}
		}
		i++;
	}
	if ( isDefined( least_hunted ) )
	{
		least_hunted.hunted_by++;
	}
	return least_hunted;
}

mechz_check_in_arc( right_offset )
{
	origin = self.origin;
	if ( isDefined( right_offset ) )
	{
		right_angle = anglesToRight( self.angles );
		origin += right_angle * right_offset;
	}
	facing_vec = anglesToForward( self.angles );
	enemy_vec = self.favoriteenemy.origin - origin;
	enemy_yaw_vec = ( enemy_vec[ 0 ], enemy_vec[ 1 ], 0 );
	facing_yaw_vec = ( facing_vec[ 0 ], facing_vec[ 1 ], 0 );
	enemy_yaw_vec = vectornormalize( enemy_yaw_vec );
	facing_yaw_vec = vectornormalize( facing_yaw_vec );
	enemy_dot = vectordot( facing_yaw_vec, enemy_yaw_vec );
	if ( enemy_dot < cos( level.mechz_aim_max_yaw ) )
	{
		return 0;
	}
	enemy_angles = vectorToAngle( enemy_vec );
	if ( abs( angleClamp180( enemy_angles[ 0 ] ) ) > level.mechz_aim_max_pitch )
	{
		return 0;
	}
	return 1;
}

mechz_get_aim_anim( anim_prefix, target_pos, right_offset )
{
	in_arc = self mechz_check_in_arc( right_offset );
	if ( !in_arc )
	{
		return undefined;
	}
	origin = self.origin;
	if ( isDefined( right_offset ) )
	{
		right_angle = anglesToRight( self.angles );
		origin += right_angle * right_offset;
	}
	aiming_vec = vectorToAngle( target_pos - origin );
	pitch = angleClamp180( aiming_vec[ 0 ] );
	yaw = angleClamp180( self.angles[ 1 ] - aiming_vec[ 1 ] );
	centered_ud = abs( pitch ) < ( level.mechz_aim_max_pitch / 2 );
	centered_lr = abs( yaw ) < ( level.mechz_aim_max_yaw / 2 );
	right_anim = angleClamp180( self.angles[ 1 ] - aiming_vec[ 1 ] ) > 0;
	up_anim = pitch < 0;
	if ( centered_ud && centered_lr )
	{
		return anim_prefix + "_aim_5";
	}
	else
	{
		if ( centered_ud && right_anim )
		{
			return anim_prefix + "_aim_6";
		}
		else
		{
			if ( centered_ud )
			{
				return anim_prefix + "_aim_4";
			}
			else
			{
				if ( centered_lr && up_anim )
				{
					return anim_prefix + "_aim_8";
				}
				else
				{
					if ( centered_lr )
					{
						return anim_prefix + "_aim_2";
					}
					else
					{
						if ( right_anim && up_anim )
						{
							return anim_prefix + "_aim_9";
						}
						else
						{
							if ( right_anim )
							{
								return anim_prefix + "_aim_3";
							}
							else
							{
								if ( up_anim )
								{
									return anim_prefix + "_aim_7";
								}
								else
								{
									return anim_prefix + "_aim_1";
								}
							}
						}
					}
				}
			}
		}
	}
}

mechz_start_basic_find_flesh()
{
	self.goalradius = level.mechz_custom_goalradius;
	self.custom_goalradius_override = level.mechz_custom_goalradius;
	if ( !isDefined( self.ai_state ) || self.ai_state != "find_flesh" )
	{
		self.ai_state = "find_flesh";
		self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	}
}

mechz_stop_basic_find_flesh()
{
	if ( isDefined( self.ai_state ) && self.ai_state == "find_flesh" )
	{
		self.ai_state = undefined;
		self notify( "stop_find_flesh" );
		self notify( "zombie_acquire_enemy" );
	}
}

watch_for_player_dist()
{
	self endon( "death" );
	while ( 1 )
	{
		player = mechz_get_closest_valid_player();
		if ( isDefined( player ) && isDefined( player.is_player_slowed ) && player.is_player_slowed )
		{
			reset_dist = level.mechz_reset_dist_sq / 2;
		}
		else
		{
			reset_dist = level.mechz_reset_dist_sq;
		}
		if ( !isDefined( player ) || distancesquared( player.origin, self.origin ) > reset_dist )
		{
			self.disable_complex_behaviors = 0;
		}
		wait 0,5;
	}
}

mechz_find_flesh()
{
	self endon( "death" );
	level endon( "intermission" );
	if ( level.intermission )
	{
		return;
	}
	self.helitarget = 1;
	self.ignoreme = 0;
	self.nododgemove = 1;
	self.ignore_player = [];
	self.goalradius = 32;
	self.ai_state = "spawning";
	self thread watch_for_player_dist();
	for ( ;; )
	{
		while ( 1 )
		{
/#
			while ( isDefined( self.force_behavior ) && self.force_behavior )
			{
				wait 0,05;
#/
			}
			while ( isDefined( self.not_interruptable ) && self.not_interruptable )
			{
/#
				if ( getDvarInt( #"E7121222" ) > 1 )
				{
					println( "\nMZ: Not thinking since a behavior has set not_interruptable\n" );
#/
				}
				wait 0,05;
			}
			while ( isDefined( self.is_traversing ) && self.is_traversing )
			{
/#
				if ( getDvarInt( #"E7121222" ) > 1 )
				{
					println( "\nMZ: Not thinking since mech is traversing\n" );
#/
				}
				wait 0,05;
			}
			player = [[ self.closest_player_override ]]();
			self mechz_set_locomotion_speed();
/#
			if ( getDvarInt( #"E7121222" ) > 1 )
			{
				println( "\nMZ: Doing think\n" );
#/
			}
			self.favoriteenemy = player;
			while ( !isDefined( player ) )
			{
/#
				if ( getDvarInt( #"E7121222" ) > 1 )
				{
					println( "\n\tMZ: No Enemy, idling\n" );
#/
				}
				self.goal_pos = self.origin;
				self setgoalpos( self.goal_pos );
				self.ai_state = "idle";
				self setanimstatefromasd( "zm_idle" );
				wait 0,5;
			}
			if ( player entity_on_tank() )
			{
				if ( level.vh_tank ent_flag( "tank_moving" ) )
				{
					if ( isDefined( self.jump_pos ) && self mechz_in_range_for_jump() )
					{
/#
						if ( getDvarInt( #"E7121222" ) > 1 )
						{
							println( "\n\tMZ: Enemy on moving tank, do jump out and jump in when tank is stationary\n" );
#/
						}
						self mechz_do_jump( 1 );
						break;
					}
					else
					{
/#
						if ( getDvarInt( #"E7121222" ) > 1 )
						{
							println( "\n\tMZ: Enemy on moving tank, Jump Requested, going to jump pos\n" );
#/
						}
						if ( !isDefined( self.jump_pos ) )
						{
							self.jump_pos = get_closest_mechz_spawn_pos( self.origin );
						}
						if ( isDefined( self.jump_pos ) )
						{
							self.goal_pos = self.jump_pos.origin;
							self setgoalpos( self.goal_pos );
						}
						wait 0,5;
					}
				}
			}
			else /#
			if ( getDvarInt( #"E7121222" ) > 1 )
			{
				println( "\n\tMZ: Enemy on tank, targetting a tank pos\n" );
#/
			}
			self.disable_complex_behaviors = 0;
			self mechz_stop_basic_find_flesh();
			self.ai_state = "tracking_tank";
			self.goalradius = level.mechz_custom_goalradius;
			self.custom_goalradius_override = level.mechz_custom_goalradius;
			closest_tank_tag = level.vh_tank get_closest_mechz_tag_on_tank( self, self.origin );
			while ( !isDefined( closest_tank_tag ) )
			{
/#
				if ( getDvarInt( #"E7121222" ) > 1 )
				{
					println( "\n\tMZ: Enemy on tank, no closest tank pos found, continuing\n" );
#/
				}
				wait 0,5;
			}
			closest_tank_tag_pos = level.vh_tank gettagorigin( closest_tank_tag );
			while ( abs( self.origin[ 2 ] - closest_tank_tag_pos[ 2 ] ) >= level.mechz_custom_goalradius || distance2dsquared( self.origin, closest_tank_tag_pos ) >= level.mechz_custom_goalradius_sq )
			{
/#
				if ( getDvarInt( #"E7121222" ) > 1 )
				{
					println( "\n\tMZ: Enemy on tank, setting tank pos as goal\n" );
#/
				}
				self.goal_pos = closest_tank_tag_pos;
				self setgoalpos( self.goal_pos );
				self waittill_any_or_timeout( 0,5, "goal", "bad_path" );
				while ( !player entity_on_tank() )
				{
/#
					if ( getDvarInt( #"E7121222" ) > 1 )
					{
						println( "\n\tMZ: Enemy got off tank by the time we reached our goal, continuing\n" );
#/
					}
				}
			}
			if ( abs( self.origin[ 2 ] - closest_tank_tag_pos[ 2 ] ) < level.mechz_custom_goalradius && distance2dsquared( self.origin, closest_tank_tag_pos ) < level.mechz_custom_goalradius_sq )
			{
/#
				if ( getDvarInt( #"E7121222" ) > 1 )
				{
					println( "\n\tMZ: Enemy on tank, reached tank pos, doing flamethrower sweep\n" );
#/
				}
				self.angles = vectorToAngle( level.vh_tank.origin - self.origin );
				self mechz_do_flamethrower_attack( 1 );
				self notify( "tank_flamethrower_attack_complete" );
			}
		}
	}
	else if ( isDefined( self.jump_requested ) || self.jump_requested && isDefined( self.force_jump ) && self.force_jump )
	{
		if ( self mechz_in_range_for_jump() )
		{
			self mechz_do_jump();
		}
		else
		{
/#
			if ( getDvarInt( #"E7121222" ) > 1 )
			{
				println( "\n\tMZ: Jump Requested, going to jump pos\n" );
#/
			}
			self.goal_pos = self.jump_pos.origin;
			self setgoalpos( self.goal_pos );
			wait 0,5;
		}
	}
}
else if ( self.zombie_move_speed == "sprint" && isDefined( player ) )
{
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\n\tMZ: Sprinting\n" );
#/
	}
	self.goal_pos = player.origin;
	self setgoalpos( self.goal_pos );
	wait 0,5;
}
}
else if ( distancesquared( self.origin, player.origin ) < level.mechz_aggro_dist_sq )
{
/#
if ( getDvarInt( #"E7121222" ) > 1 )
{
	println( "\n\tMZ: Player very close, switching to melee only\n" );
#/
}
self.disable_complex_behaviors = 1;
}
else if ( self should_do_claw_attack() )
{
self mechz_do_claw_grab();
}
}
else while ( self should_do_flamethrower_attack() )
{
self mechz_do_flamethrower_attack();
}
/#
if ( getDvarInt( #"E7121222" ) > 1 )
{
println( "\n\tMZ: No special behavior valid, heading after player\n" );
#/
}
self.goal_pos = player.origin;
if ( isDefined( level.damage_prone_players_override_func ) )
{
level thread [[ level.damage_prone_players_override_func ]]();
}
else
{
self thread damage_prone_players();
}
mechz_start_basic_find_flesh();
wait 0,5;
}
}

damage_prone_players()
{
	self endon( "death" );
	a_players = getplayers();
	_a1878 = a_players;
	_k1878 = getFirstArrayKey( _a1878 );
	while ( isDefined( _k1878 ) )
	{
		player = _a1878[ _k1878 ];
		if ( isDefined( self.favoriteenemy ) && self.favoriteenemy == player )
		{
			n_dist = distance2dsquared( player.origin, self.origin );
			if ( n_dist < 2025 )
			{
				player_z = player.origin[ 2 ];
				mechz_z = self.origin[ 2 ];
				if ( player_z < mechz_z && ( mechz_z - player_z ) <= 75 )
				{
					if ( isDefined( self.meleedamage ) )
					{
						idamage = self.meleedamage;
					}
					else
					{
						idamage = 50;
					}
					player dodamage( idamage, self.origin, self, self, "none", "MOD_MELEE" );
				}
			}
		}
		_k1878 = getNextArrayKey( _a1878, _k1878 );
	}
}

melee_anim_func()
{
	self.next_leap_time = getTime() + 1500;
}

mechz_launch_armor_piece()
{
	if ( !isDefined( self.next_armor_piece ) )
	{
		self.next_armor_piece = 0;
	}
	if ( !isDefined( self.armor_state ) || self.next_armor_piece >= self.armor_state.size )
	{
/#
		println( "Trying to launch armor piece after all pieces have already been launched!" );
#/
		return;
	}
	if ( isDefined( self.armor_state[ self.next_armor_piece ].model ) )
	{
		self detach( self.armor_state[ self.next_armor_piece ].model, self.armor_state[ self.next_armor_piece ].tag );
	}
	self.fx_field |= 1 << self.armor_state[ self.next_armor_piece ].index;
	self setclientfield( "mechz_fx", self.fx_field );
	if ( sndmechzisnetworksafe( "destruction" ) )
	{
		self playsound( "zmb_ai_mechz_destruction" );
	}
	self.next_armor_piece++;
}

mechz_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, poffsettime, boneindex )
{
	num_tiers = level.mechz_armor_info.size + 1;
	old_health_tier = int( ( num_tiers * self.health ) / self.maxhealth );
	bonename = getpartname( "c_zom_mech_body", boneindex );
	if ( isDefined( attacker ) && isalive( attacker ) && isplayer( attacker ) || level.zombie_vars[ attacker.team ][ "zombie_insta_kill" ] && isDefined( attacker.personal_instakill ) && attacker.personal_instakill )
	{
		n_mechz_damage_percent = 1;
		n_mechz_headshot_modifier = 2;
	}
	else
	{
		n_mechz_damage_percent = level.mechz_damage_percent;
		n_mechz_headshot_modifier = 1;
	}
	if ( isDefined( weapon ) && is_weapon_shotgun( weapon ) )
	{
		n_mechz_damage_percent *= level.mechz_shotgun_damage_mod;
		n_mechz_headshot_modifier *= level.mechz_shotgun_damage_mod;
	}
	if ( damage <= 10 )
	{
		n_mechz_damage_percent = 1;
	}
	if ( is_explosive_damage( meansofdeath ) || issubstr( weapon, "staff" ) )
	{
		if ( n_mechz_damage_percent < 0,5 )
		{
			n_mechz_damage_percent = 0,5;
		}
		if ( isDefined( self.has_helmet ) && !self.has_helmet && issubstr( weapon, "staff" ) && n_mechz_damage_percent < 1 )
		{
			n_mechz_damage_percent = 1;
		}
		final_damage = damage * n_mechz_damage_percent;
		if ( !isDefined( self.explosive_dmg_taken ) )
		{
			self.explosive_dmg_taken = 0;
		}
		self.explosive_dmg_taken += final_damage;
		self.helmet_dmg += final_damage;
		if ( isDefined( self.explosive_dmg_taken_on_grab_start ) )
		{
			if ( isDefined( self.e_grabbed ) && ( self.explosive_dmg_taken - self.explosive_dmg_taken_on_grab_start ) > level.mechz_explosive_dmg_to_cancel_claw )
			{
				if ( isDefined( self.has_helmet ) && self.has_helmet || self.helmet_dmg < self.helmet_dmg_for_removal && isDefined( self.has_helmet ) && !self.has_helmet )
				{
					self thread mechz_claw_shot_pain_reaction();
				}
				self thread ent_released_from_claw_grab_achievement( attacker, self.e_grabbed );
				self thread mechz_claw_release();
			}
		}
	}
	else
	{
		if ( shitloc != "head" && shitloc != "helmet" )
		{
			if ( bonename == "tag_powersupply" )
			{
				final_damage = damage * n_mechz_damage_percent;
				if ( isDefined( self.powerplant_covered ) && !self.powerplant_covered )
				{
					self.powerplant_dmg += final_damage;
				}
				else
				{
					self.powerplant_cover_dmg += final_damage;
				}
			}
			if ( isDefined( self.e_grabbed ) && shitloc != "left_hand" || shitloc == "left_arm_lower" && shitloc == "left_arm_upper" )
			{
				if ( isDefined( self.e_grabbed ) )
				{
					self thread mechz_claw_shot_pain_reaction();
				}
				self thread ent_released_from_claw_grab_achievement( attacker, self.e_grabbed );
				self thread mechz_claw_release( 1 );
			}
			final_damage = damage * n_mechz_damage_percent;
		}
		else
		{
			if ( isDefined( self.has_helmet ) && !self.has_helmet )
			{
				final_damage = damage * n_mechz_headshot_modifier;
			}
			else
			{
				final_damage = damage * n_mechz_damage_percent;
				self.helmet_dmg += final_damage;
			}
		}
	}
	if ( !isDefined( weapon ) || weapon == "none" )
	{
		if ( !isplayer( attacker ) )
		{
			final_damage = 0;
		}
	}
	new_health_tier = int( ( num_tiers * ( self.health - final_damage ) ) / self.maxhealth );
	while ( old_health_tier > new_health_tier )
	{
		while ( old_health_tier > new_health_tier )
		{
/#
			if ( getDvarInt( #"E7121222" ) > 0 )
			{
				println( "\nMZ: Old tier: " + old_health_tier + "   New Health Tier: " + new_health_tier + "   Launching armor piece" );
#/
			}
			if ( old_health_tier < num_tiers )
			{
				self mechz_launch_armor_piece();
			}
			old_health_tier--;

		}
	}
	if ( isDefined( self.has_helmet ) && self.has_helmet && self.helmet_dmg >= self.helmet_dmg_for_removal )
	{
		self.has_helmet = 0;
		self detach( "c_zom_mech_faceplate", "J_Helmet" );
		if ( sndmechzisnetworksafe( "destruction" ) )
		{
			self playsound( "zmb_ai_mechz_destruction" );
		}
		if ( sndmechzisnetworksafe( "angry" ) )
		{
			self playsound( "zmb_ai_mechz_vox_angry" );
		}
		self.fx_field |= 1024;
		self.fx_field &= 2048;
		self setclientfield( "mechz_fx", self.fx_field );
		if ( isDefined( self.not_interruptable ) && !self.not_interruptable && isDefined( self.is_traversing ) && !self.is_traversing )
		{
			self mechz_interrupt();
			self animscripted( self.origin, self.angles, "zm_pain_faceplate" );
			self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim_faceplate" );
		}
		self thread shoot_mechz_head_vo();
	}
	if ( isDefined( self.powerplant_covered ) && self.powerplant_covered && self.powerplant_cover_dmg >= self.powerplant_cover_dmg_for_removal )
	{
		self.powerplant_covered = 0;
		self detach( "c_zom_mech_powersupply_cap", "tag_powersupply" );
		cap_model = spawn( "script_model", self gettagorigin( "tag_powersupply" ) );
		cap_model.angles = self gettagangles( "tag_powersupply" );
		cap_model setmodel( "c_zom_mech_powersupply_cap" );
		cap_model physicslaunch( cap_model.origin, anglesToForward( cap_model.angles ) );
		cap_model thread mechz_delayed_item_delete();
		if ( sndmechzisnetworksafe( "destruction" ) )
		{
			self playsound( "zmb_ai_mechz_destruction" );
		}
		if ( isDefined( self.not_interruptable ) && !self.not_interruptable && isDefined( self.is_traversing ) && !self.is_traversing )
		{
			self mechz_interrupt();
			self animscripted( self.origin, self.angles, "zm_pain_powercore" );
			self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim_powercore" );
		}
	}
	else
	{
		if ( isDefined( self.powerplant_covered ) && !self.powerplant_covered && isDefined( self.has_powerplant ) && self.has_powerplant && self.powerplant_dmg >= self.powerplant_dmg_for_destroy )
		{
			self.has_powerplant = 0;
			self thread mechz_stun( level.mechz_powerplant_stun_time );
			if ( sndmechzisnetworksafe( "destruction" ) )
			{
				self playsound( "zmb_ai_mechz_destruction" );
			}
		}
	}
/#
	if ( getDvarInt( #"E7121222" ) > 0 )
	{
		println( "\nMZ: Doing " + final_damage + " damage to mechz,   Health Remaining: " + self.health );
		if ( self.helmet_dmg < self.helmet_dmg_for_removal )
		{
			println( "\nMZ: Current helmet dmg: " + self.helmet_dmg + "    Required helmet dmg: " + self.helmet_dmg_for_removal );
#/
		}
	}
	return final_damage;
}

mechz_non_attacker_damage_override( damage, weapon, attacker )
{
	if ( attacker == level.vh_tank )
	{
		self thread mechz_tank_hit_callback();
	}
	return 0;
}

mechz_instakill_override()
{
	return;
}

mechz_nuke_override()
{
	self endon( "death" );
	wait randomfloatrange( 0,1, 0,7 );
	self playsound( "evt_nuked" );
	self dodamage( self.health * 0,25, self.origin );
	return;
}

mechz_set_locomotion_speed()
{
	self endon( "death" );
	self.prev_move_speed = self.zombie_move_speed;
	if ( !isDefined( self.favoriteenemy ) )
	{
		self.zombie_move_speed = "walk";
	}
	else if ( isDefined( self.force_run ) && self.force_run )
	{
		self.zombie_move_speed = "run";
	}
	else
	{
		if ( isDefined( self.force_sprint ) && self.force_sprint )
		{
			self.zombie_move_speed = "sprint";
		}
		else
		{
			if ( isDefined( self.favoriteenemy ) && self.favoriteenemy entity_on_tank() && isDefined( level.vh_tank ) && level.vh_tank ent_flag( "tank_activated" ) )
			{
				self.zombie_move_speed = "run";
			}
			else
			{
				if ( isDefined( self.favoriteenemy ) && distancesquared( self.origin, self.favoriteenemy.origin ) > level.mechz_dist_for_sprint )
				{
					self.zombie_move_speed = "run";
				}
				else
				{
					if ( isDefined( self.has_powerplant ) && !self.has_powerplant )
					{
						self.zombie_move_speed = "walk";
					}
					else
					{
						self.zombie_move_speed = "walk";
					}
				}
			}
		}
	}
	if ( self.zombie_move_speed == "sprint" && self.prev_move_speed != "sprint" )
	{
		self mechz_interrupt();
		self animscripted( self.origin, self.angles, "zm_sprint_intro" );
		self maps/mp/animscripts/zm_shared::donotetracks( "jump_anim" );
	}
	else
	{
		if ( self.zombie_move_speed != "sprint" && self.prev_move_speed == "sprint" )
		{
			self animscripted( self.origin, self.angles, "zm_sprint_outro" );
			self maps/mp/animscripts/zm_shared::donotetracks( "jump_anim" );
		}
	}
	self set_zombie_run_cycle( self.zombie_move_speed );
}

response_to_air_raid_siren_vo()
{
	wait 3;
	a_players = getplayers();
	if ( a_players.size == 0 )
	{
		return;
	}
	a_players = array_randomize( a_players );
	_a2280 = a_players;
	_k2280 = getFirstArrayKey( _a2280 );
	while ( isDefined( _k2280 ) )
	{
		player = _a2280[ _k2280 ];
		if ( is_player_valid( player ) )
		{
			if ( isDefined( player.dontspeak ) && !player.dontspeak )
			{
				if ( !isDefined( level.air_raid_siren_count ) )
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "siren_1st_time" );
					level.air_raid_siren_count = 1;
					while ( isDefined( player ) && isDefined( player.isspeaking ) && player.isspeaking )
					{
						wait 0,1;
					}
					level thread start_see_mech_zombie_vo();
					return;
				}
				else if ( level.mechz_zombie_per_round == 1 )
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "siren_generic" );
					return;
				}
				else player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "multiple_mechs" );
				return;
			}
		}
		else
		{
			_k2280 = getNextArrayKey( _a2280, _k2280 );
		}
	}
}

start_see_mech_zombie_vo()
{
	wait 1;
	a_zombies = getaispeciesarray( level.zombie_team, "all" );
	_a2321 = a_zombies;
	_k2321 = getFirstArrayKey( _a2321 );
	while ( isDefined( _k2321 ) )
	{
		zombie = _a2321[ _k2321 ];
		if ( isDefined( zombie.is_mechz ) && zombie.is_mechz )
		{
			ai_mechz = zombie;
		}
		_k2321 = getNextArrayKey( _a2321, _k2321 );
	}
	a_players = getplayers();
	if ( a_players.size == 0 )
	{
		return;
	}
	while ( isalive( ai_mechz ) )
	{
		_a2337 = a_players;
		_k2337 = getFirstArrayKey( _a2337 );
		while ( isDefined( _k2337 ) )
		{
			player = _a2337[ _k2337 ];
			player thread player_looking_at_mechz_watcher( ai_mechz );
			_k2337 = getNextArrayKey( _a2337, _k2337 );
		}
	}
}

player_looking_at_mechz_watcher( ai_mechz )
{
	self endon( "disconnect" );
	ai_mechz endon( "death" );
	level endon( "first_mech_zombie_seen" );
	while ( 1 )
	{
		if ( distancesquared( self.origin, ai_mechz.origin ) < 1000000 )
		{
			if ( self is_player_looking_at( ai_mechz.origin + vectorScale( ( 0, 0, 1 ), 60 ), 0,75 ) )
			{
				if ( isDefined( self.dontspeak ) && !self.dontspeak )
				{
					self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "discover_mech" );
					level notify( "first_mech_zombie_seen" );
					return;
				}
			}
		}
		else
		{
			wait 0,1;
		}
	}
}

mechz_grabbed_played_vo( ai_mechz )
{
	self endon( "disconnect" );
	self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "mech_grab" );
	while ( isDefined( self ) && isDefined( self.isspeaking ) && self.isspeaking )
	{
		wait 0,1;
	}
	wait 1;
	if ( isalive( ai_mechz ) && isDefined( ai_mechz.e_grabbed ) )
	{
		ai_mechz thread play_shoot_arm_hint_vo();
	}
}

play_shoot_arm_hint_vo()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( !isDefined( self.e_grabbed ) )
		{
			return;
		}
		a_players = getplayers();
		_a2399 = a_players;
		_k2399 = getFirstArrayKey( _a2399 );
		while ( isDefined( _k2399 ) )
		{
			player = _a2399[ _k2399 ];
			if ( player == self.e_grabbed )
			{
			}
			else
			{
				if ( distancesquared( self.origin, player.origin ) < 1000000 )
				{
					if ( player is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), 0,75 ) )
					{
						if ( isDefined( player.dontspeak ) && !player.dontspeak )
						{
							player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "shoot_mech_arm" );
							return;
						}
					}
				}
			}
			_k2399 = getNextArrayKey( _a2399, _k2399 );
		}
		wait 0,1;
	}
}

mechz_hint_vo()
{
	self endon( "death" );
	wait 30;
	while ( 1 )
	{
		while ( self.health > ( self.maxhealth * 0,5 ) )
		{
			wait 1;
		}
		while ( isDefined( self.powerplant_covered ) && !self.powerplant_covered )
		{
			wait 1;
		}
		a_players = getplayers();
		_a2444 = a_players;
		_k2444 = getFirstArrayKey( _a2444 );
		while ( isDefined( _k2444 ) )
		{
			player = _a2444[ _k2444 ];
			if ( isDefined( self.e_grabbed ) && self.e_grabbed == player )
			{
			}
			else
			{
				if ( distancesquared( self.origin, player.origin ) < 1000000 )
				{
					if ( player is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), 0,75 ) )
					{
						if ( isDefined( player.dontspeak ) && !player.dontspeak )
						{
							player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "shoot_mech_power" );
							return;
						}
					}
				}
			}
			_k2444 = getNextArrayKey( _a2444, _k2444 );
		}
		wait 0,1;
	}
}

shoot_mechz_head_vo()
{
	self endon( "death" );
	a_players = getplayers();
	_a2473 = a_players;
	_k2473 = getFirstArrayKey( _a2473 );
	while ( isDefined( _k2473 ) )
	{
		player = _a2473[ _k2473 ];
		if ( isDefined( self.e_grabbed ) && self.e_grabbed == player )
		{
		}
		else
		{
			if ( distancesquared( self.origin, player.origin ) < 1000000 )
			{
				if ( player is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), 0,75 ) )
				{
					if ( isDefined( player.dontspeak ) && !player.dontspeak )
					{
						player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "shoot_mech_head" );
						return;
					}
				}
			}
		}
		_k2473 = getNextArrayKey( _a2473, _k2473 );
	}
}

mechz_jump_vo()
{
	a_players = getplayers();
	_a2497 = a_players;
	_k2497 = getFirstArrayKey( _a2497 );
	while ( isDefined( _k2497 ) )
	{
		player = _a2497[ _k2497 ];
		if ( distancesquared( self.origin, player.origin ) < 1000000 )
		{
			if ( player is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), 0,5 ) )
			{
				if ( isDefined( player.dontspeak ) && !player.dontspeak )
				{
					player delay_thread( 3, ::maps/mp/zombies/_zm_audio::create_and_play_dialog, "general", "rspnd_mech_jump" );
					return;
				}
			}
		}
		_k2497 = getNextArrayKey( _a2497, _k2497 );
	}
}

mechz_stomped_by_giant_robot_vo()
{
	self endon( "death" );
	wait 5;
	a_players = getplayers();
	_a2520 = a_players;
	_k2520 = getFirstArrayKey( _a2520 );
	while ( isDefined( _k2520 ) )
	{
		player = _a2520[ _k2520 ];
		if ( distancesquared( self.origin, player.origin ) < 1000000 )
		{
			if ( player is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), 0,75 ) )
			{
				if ( isDefined( player.dontspeak ) && !player.dontspeak )
				{
					player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "robot_crush_mech" );
					return;
				}
			}
		}
		_k2520 = getNextArrayKey( _a2520, _k2520 );
	}
}

init_anim_rate()
{
	self setclientfield( "anim_rate", 1 );
	n_rate = self getclientfield( "anim_rate" );
	self setentityanimrate( n_rate );
}

sndmechzisnetworksafe( type )
{
	if ( !isDefined( level.sndmechz ) )
	{
		level.sndmechz = [];
	}
	if ( !isDefined( level.sndmechz[ type ] ) )
	{
		level thread sndmechznetworkchoke( type );
	}
	if ( level.sndmechz[ type ] > 1 )
	{
		return 0;
	}
	level.sndmechz[ type ]++;
	return 1;
}

sndmechznetworkchoke( type )
{
	while ( 1 )
	{
		level.sndmechz[ type ] = 0;
		wait_network_frame();
	}
}
