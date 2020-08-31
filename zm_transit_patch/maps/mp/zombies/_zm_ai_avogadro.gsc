#include maps/mp/zombies/_zm_weap_riotshield;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zm_transit_bus;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_ai_avogadro;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

precache()
{
	precacheshellshock( "electrocution" );
/#
	precachemodel( "fx_axis_createfx" );
#/
	precache_fx();
}

precache_fx()
{
	level._effect[ "avogadro_bolt" ] = loadfx( "maps/zombie/fx_zombie_tesla_bolt_secondary" );
	level._effect[ "avogadro_ascend" ] = loadfx( "maps/zombie/fx_zmb_avog_ascend" );
	level._effect[ "avogadro_ascend_aerial" ] = loadfx( "maps/zombie/fx_zmb_avog_ascend_aerial" );
	level._effect[ "avogadro_descend" ] = loadfx( "maps/zombie/fx_zmb_avog_descend" );
	level._effect[ "avogadro_phase_trail" ] = loadfx( "maps/zombie/fx_zmb_avog_phase_trail" );
	level._effect[ "avogadro_phasing" ] = loadfx( "maps/zombie/fx_zmb_avog_phasing" );
	level._effect[ "avogadro_health_full" ] = loadfx( "maps/zombie/fx_zmb_avog_health_full" );
	level._effect[ "avogadro_health_half" ] = loadfx( "maps/zombie/fx_zmb_avog_health_half" );
	level._effect[ "avogadro_health_low" ] = loadfx( "maps/zombie/fx_zmb_avog_health_low" );
}

init()
{
	init_phase_anims();
	init_regions();
	level.avogadro_spawners = getentarray( "avogadro_zombie_spawner", "script_noteworthy" );
	array_thread( level.avogadro_spawners, ::add_spawn_function, ::avogadro_prespawn );
	level.zombie_ai_limit_avogadro = 1;
	if ( !isDefined( level.vsmgr_prio_overlay_zm_ai_avogadro_electrified ) )
	{
		level.vsmgr_prio_overlay_zm_ai_avogadro_electrified = 75;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_ai_avogadro_electrified", 1, level.vsmgr_prio_overlay_zm_ai_avogadro_electrified, 15, 1, ::maps/mp/_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
	maps/mp/zombies/_zm::register_player_damage_callback( ::avogadro_player_damage_callback );
	level thread avogadro_spawning_logic();
}

init_phase_anims()
{
	level.avogadro_phase = [];
	level.avogadro_phase[ 0 ] = spawnstruct();
	level.avogadro_phase[ 0 ].animstate = "zm_teleport_forward";
	level.avogadro_phase[ 1 ] = spawnstruct();
	level.avogadro_phase[ 1 ].animstate = "zm_teleport_left";
	level.avogadro_phase[ 2 ] = spawnstruct();
	level.avogadro_phase[ 2 ].animstate = "zm_teleport_right";
	level.avogadro_phase[ 3 ] = spawnstruct();
	level.avogadro_phase[ 3 ].animstate = "zm_teleport_back";
}

init_regions()
{
	level.transit_region = [];
	level.transit_region[ "bus" ] = spawnstruct();
	level.transit_region[ "diner" ] = spawnstruct();
	level.transit_region[ "farm" ] = spawnstruct();
	level.transit_region[ "cornfield" ] = spawnstruct();
	level.transit_region[ "power" ] = spawnstruct();
	level.transit_region[ "town" ] = spawnstruct();
	level.transit_region[ "bus" ].zones = [];
	level.transit_region[ "bus" ].zones[ 0 ] = "zone_pri";
	level.transit_region[ "bus" ].zones[ 1 ] = "zone_station_ext";
	level.transit_region[ "bus" ].exploder = 200;
	level.transit_region[ "bus" ].sndorigin = ( -6909, 4531, 396 );
	level.transit_region[ "diner" ].zones = [];
	level.transit_region[ "diner" ].zones[ 0 ] = "zone_roadside_west";
	level.transit_region[ "diner" ].zones[ 1 ] = "zone_din";
	level.transit_region[ "diner" ].zones[ 2 ] = "zone_roadside_east";
	level.transit_region[ "diner" ].zones[ 3 ] = "zone_gas";
	level.transit_region[ "diner" ].zones[ 4 ] = "zone_gar";
	level.transit_region[ "diner" ].exploder = 220;
	level.transit_region[ "diner" ].sndorigin = ( -5239, -6842, 457 );
	level.transit_region[ "farm" ].zones = [];
	level.transit_region[ "farm" ].zones[ 0 ] = "zone_far";
	level.transit_region[ "farm" ].zones[ 1 ] = "zone_far_ext";
	level.transit_region[ "farm" ].zones[ 2 ] = "zone_brn";
	level.transit_region[ "farm" ].zones[ 3 ] = "zone_farm_house";
	level.transit_region[ "farm" ].exploder = 230;
	level.transit_region[ "farm" ].sndorigin = ( 7954, -5799, 582 );
	level.transit_region[ "cornfield" ].zones = [];
	level.transit_region[ "cornfield" ].zones[ 0 ] = "zone_amb_cornfield";
	level.transit_region[ "cornfield" ].zones[ 1 ] = "zone_cornfield_prototype";
	level.transit_region[ "cornfield" ].exploder = 240;
	level.transit_region[ "cornfield" ].sndorigin = ( 10278, -662, 324 );
	level.transit_region[ "power" ].zones = [];
	level.transit_region[ "power" ].zones[ 0 ] = "zone_prr";
	level.transit_region[ "power" ].zones[ 1 ] = "zone_pow";
	level.transit_region[ "power" ].zones[ 2 ] = "zone_pcr";
	level.transit_region[ "power" ].zones[ 3 ] = "zone_pow_warehouse";
	level.transit_region[ "power" ].exploder = 250;
	level.transit_region[ "power" ].sndorigin = ( 10391, 7604, -70 );
	level.transit_region[ "town" ].zones = [];
	level.transit_region[ "town" ].zones[ 0 ] = "zone_tow";
	level.transit_region[ "town" ].zones[ 1 ] = "zone_bar";
	level.transit_region[ "town" ].zones[ 2 ] = "zone_ban";
	level.transit_region[ "town" ].zones[ 3 ] = "zone_ban_vault";
	level.transit_region[ "town" ].zones[ 4 ] = "zone_town_north";
	level.transit_region[ "town" ].zones[ 5 ] = "zone_town_west";
	level.transit_region[ "town" ].zones[ 6 ] = "zone_town_south";
	level.transit_region[ "town" ].zones[ 7 ] = "zone_town_barber";
	level.transit_region[ "town" ].zones[ 8 ] = "zone_town_church";
	level.transit_region[ "town" ].zones[ 9 ] = "zone_town_east";
	level.transit_region[ "town" ].exploder = 260;
	level.transit_region[ "town" ].sndorigin = ( 1460, -416, 318 );
}

avogadro_prespawn()
{
	self endon( "death" );
	level endon( "intermission" );
	level.avogadro = self;
	self.has_legs = 1;
	self.no_gib = 1;
	self.is_avogadro = 1;
	self.ignore_enemy_count = 1;
	recalc_zombie_array();
	self.ignore_nuke = 1;
	self.ignore_lava_damage = 1;
	self.ignore_devgui_death = 1;
	self.ignore_electric_trap = 1;
	self.ignore_game_over_death = 1;
	self.ignore_enemyoverride = 1;
	self.ignore_solo_last_stand = 1;
	self.ignore_riotshield = 1;
	self.allowpain = 0;
	self.core_model = getent( "core_model", "targetname" );
	if ( isDefined( self.core_model ) )
	{
		if ( !isDefined( self.core_model.angles ) )
		{
			self.core_model.angles = ( 0, 0, 1 );
		}
		self forceteleport( self.core_model.origin, self.core_model.angles );
	}
	self set_zombie_run_cycle( "walk" );
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self maps/mp/zombies/_zm_spawner::zombie_setup_attack_properties();
	self maps/mp/zombies/_zm_spawner::zombie_complete_emerging_into_playable_area();
	self setfreecameralockonallowed( 0 );
	self.zmb_vocals_attack = "zmb_vocals_zombie_attack";
	self.meleedamage = 5;
	self.actor_damage_func = ::avogadro_damage_func;
	self.non_attacker_func = ::avogadro_non_attacker;
	self.anchor = spawn( "script_origin", self.origin );
	self.anchor.angles = self.angles;
	self.phase_time = 0;
	self.audio_loop_ent = spawn( "script_origin", self.origin );
	self.audio_loop_ent linkto( self, "tag_origin" );
	self.hit_by_melee = 0;
	self.damage_absorbed = 0;
	self.ignoreall = 1;
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
	self.stun_zombie = ::stun_avogadro;
	self.jetgun_fling_func = ::fling_avogadro;
	self.jetgun_drag_func = ::drag_avogadro;
	self.depot_lava_pit = ::busplowkillzombie;
	self.busplowkillzombie = ::busplowkillzombie;
	self.region_timer = getTime() + 500;
	self.shield = 1;
}

avogadro_spawning_logic()
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
	spawner = getent( "avogadro_zombie_spawner", "script_noteworthy" );
	if ( !isDefined( spawner ) )
	{
/#
		assertmsg( "No avogadro spawner in the map." );
#/
		return;
	}
	ai = spawn_zombie( spawner, "avogadro" );
	if ( !isDefined( ai ) )
	{
/#
		assertmsg( "Avogadro: failed spawn" );
#/
		return;
	}
	ai waittill( "zombie_init_done" );
	core_mover = getent( "core_mover", "targetname" );
	ai linkto( core_mover, "tag_origin" );
	ai.state = "chamber";
	ai setanimstatefromasd( "zm_chamber_idle" );
	ai thread avogadro_think();
	ai thread avogadro_bus_watcher();
}

avogadro_think()
{
	while ( 1 )
	{
		while ( isDefined( self.in_pain ) && self.in_pain )
		{
			wait 0,1;
		}
		switch( self.state )
		{
			case "chamber":
				wait_idle();
				break;
			case "wait_for_player":
				player_look();
				break;
			case "idle":
				chase_player();
				break;
			case "chasing":
				chase_update();
				break;
			case "chasing_bus":
				chase_bus_update();
				break;
			case "cloud":
				cloud_update();
				break;
			case "stay_attached":
				attach_update();
				break;
		}
		wait 0,1;
	}
}

avogadro_bus_watcher()
{
	plow_trigger = getent( "trigger_plow", "targetname" );
	while ( 1 )
	{
		while ( self.state == "chasing_bus" || self.state == "attacking_bus" )
		{
			wait 0,1;
		}
		if ( isDefined( level.the_bus ) && isDefined( level.the_bus.ismoving ) && level.the_bus.ismoving && level.the_bus getspeedmph() > 5 )
		{
			if ( self istouching( plow_trigger ) )
			{
				phase_node = getnode( "back_door_node", "targetname" );
				self avogadro_teleport( phase_node.origin, phase_node.angles, 1 );
			}
		}
		wait 0,1;
	}
}

busplowkillzombie()
{
	if ( isDefined( self.is_teleport ) && self.is_teleport )
	{
		return;
	}
	phase_node = getnode( "back_door_node", "targetname" );
	self avogadro_teleport( phase_node.origin, phase_node.angles, 1 );
}

phase_from_bus()
{
	self ghost();
	self notsolid();
	wait 3;
	self show();
	self solid();
	self notify( "phase_from_bus_done" );
}

wait_idle()
{
/#
	if ( getDvarInt( #"CFA4158E" ) )
	{
		self.state = "wait_for_player";
		self unlink();
#/
	}
	if ( flag( "power_on" ) )
	{
		self.state = "wait_for_player";
		self unlink();
	}
}

player_look()
{
	players = get_players();
	_a427 = players;
	_k427 = getFirstArrayKey( _a427 );
	while ( isDefined( _k427 ) )
	{
		player = _a427[ _k427 ];
		vec_enemy = self.origin - player.origin;
		vec_facing = anglesToForward( player.angles );
		norm_facing = vectornormalize( vec_facing );
		norm_enemy = vectornormalize( vec_enemy );
		dot = vectordot( norm_facing, norm_enemy );
		if ( dot > 0,707 )
		{
/#
			avogadro_print( "player spotted" );
#/
			self avogadro_exit( "chamber" );
		}
		_k427 = getNextArrayKey( _a427, _k427 );
	}
/#
	if ( getDvarInt( #"CFA4158E" ) )
	{
		avogadro_print( "player_look ignored" );
		self avogadro_exit( "chamber" );
#/
	}
}

chase_player()
{
	self.state = "chasing";
	self set_zombie_run_cycle( "run" );
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

chase_update()
{
	if ( self check_bus_attack() )
	{
		self chase_bus();
	}
	else if ( self check_phase() )
	{
		self do_phase();
	}
	else
	{
		if ( self check_range_attack() )
		{
			self range_attack();
		}
	}
	if ( self region_empty() )
	{
		self avogadro_exit( "exit_idle" );
	}
}

check_bus_attack()
{
	if ( isDefined( self.favoriteenemy ) && isDefined( self.favoriteenemy.isonbus ) && self.favoriteenemy.isonbus )
	{
		return 1;
	}
	return 0;
}

chase_bus()
{
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self.chase_bus_entry = undefined;
	dist_curr = 0;
	_a515 = level.the_bus.openings;
	_k515 = getFirstArrayKey( _a515 );
	while ( isDefined( _k515 ) )
	{
		opening = _a515[ _k515 ];
		if ( !isDefined( self.chase_bus_entry ) )
		{
			self.chase_bus_entry = opening;
			dist_curr = distance2dsquared( self.origin, level.the_bus gettagorigin( self.chase_bus_entry.tagname ) );
		}
		else
		{
			dist_next = distance2dsquared( self.origin, level.the_bus gettagorigin( opening.tagname ) );
			if ( dist_next < dist_curr )
			{
				dist_curr = dist_next;
				self.chase_bus_entry = opening;
			}
		}
		_k515 = getNextArrayKey( _a515, _k515 );
	}
	self set_zombie_run_cycle( "sprint" );
	self.state = "chasing_bus";
}

chase_bus_update()
{
	bus = level.the_bus;
	if ( isDefined( bus ) && bus.numplayerson == 0 )
	{
		self chase_player();
		return;
	}
	tag_pos = level.the_bus gettagorigin( self.chase_bus_entry.tagname );
	self setgoalpos( tag_pos );
	if ( bus getspeedmph() > 5 )
	{
		self.phase_state = level.avogadro_phase[ 0 ].animstate;
		self.phase_substate = 0;
		self setfreecameralockonallowed( 0 );
		self.ignoreall = 1;
		self thread phase_failsafe();
		self animcustom( ::play_phase_anim );
/#
		avogadro_print( "long phase after bus" );
#/
		self waittill( "phase_anim_done" );
		self.ignoreall = 0;
		self setfreecameralockonallowed( 1 );
	}
	dist_sq = distancesquared( self.origin, tag_pos );
	if ( dist_sq < 14400 )
	{
		self bus_attack();
	}
}

bus_attack()
{
	self endon( "stunned" );
	self endon( "stop_bus_attack" );
	bus_attack_struct = [];
	bus_attack_struct[ 0 ] = spawnstruct();
	bus_attack_struct[ 0 ].window_tag = "window_left_rear_jnt";
	bus_attack_struct[ 0 ].substate = "bus_attack_back";
	bus_attack_struct[ 1 ] = spawnstruct();
	bus_attack_struct[ 1 ].window_tag = "window_right_front_jnt";
	bus_attack_struct[ 1 ].substate = "bus_attack_front";
	bus_attack_struct[ 2 ] = spawnstruct();
	bus_attack_struct[ 2 ].window_tag = "window_left_2_jnt";
	bus_attack_struct[ 2 ].substate = "bus_attack_left";
	bus_attack_struct[ 3 ] = spawnstruct();
	bus_attack_struct[ 3 ].window_tag = "window_right_3_jnt";
	bus_attack_struct[ 3 ].substate = "bus_attack_right";
	random_attack_struct = array_randomize( bus_attack_struct );
	self.state = "attacking_bus";
	self.bus_attack_time = 0;
	self.bus_disabled = 0;
	self.ignoreall = 1;
	i = 0;
	while ( i < 4 )
	{
		while ( isDefined( self.in_pain ) && self.in_pain )
		{
			wait 0,1;
		}
		attack_struct = random_attack_struct[ i ];
/#
		window = getDvarInt( #"5628DC9F" );
		if ( window >= 0 )
		{
			attack_struct = bus_attack_struct[ window ];
#/
		}
		self bus_disable( attack_struct );
		if ( self.bus_disabled )
		{
			break;
		}
		else
		{
			i++;
		}
	}
	if ( !self.bus_disabled )
	{
		self.shield = 1;
		self unlink();
		self avogadro_exit( "bus" );
	}
	else
	{
		level.the_bus thread maps/mp/zm_transit_bus::bus_disabled_by_emp( 30 );
		self attach_to_bus();
	}
}

attach_to_bus()
{
	self endon( "death" );
	self endon( "stop_health" );
	if ( level.the_bus.numaliveplayersridingbus > 0 )
	{
/#
		avogadro_print( "stay_attached " + self.bus_attack_struct.substate );
#/
		origin = level.the_bus gettagorigin( self.bus_attack_struct.window_tag );
		angles = level.the_bus gettagangles( self.bus_attack_struct.window_tag );
		self show();
		self.shield = 0;
		self animscripted( origin, angles, "zm_bus_attack", self.bus_attack_struct.substate );
		self.bus_shock_time = 0;
		self.state = "stay_attached";
		return;
	}
	self detach_from_bus();
}

attach_update()
{
	if ( level.the_bus.numaliveplayersridingbus > 0 )
	{
		wait 0,1;
		self.bus_shock_time += 0,1;
		while ( self.bus_shock_time >= 2 )
		{
			self.bus_shock_time = 0;
			players = get_players();
			_a702 = players;
			_k702 = getFirstArrayKey( _a702 );
			while ( isDefined( _k702 ) )
			{
				player = _a702[ _k702 ];
				if ( isDefined( player.isonbus ) && player.isonbus )
				{
					maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_ai_avogadro_electrified", player, 1, 1 );
					player shellshock( "electrocution", 1 );
					player notify( "avogadro_damage_taken" );
				}
				_k702 = getNextArrayKey( _a702, _k702 );
			}
		}
		return;
	}
	self detach_from_bus();
}

detach_from_bus()
{
	self unlink();
/#
	avogadro_print( "unlinking from bus window" );
#/
	bus_forward = vectornormalize( anglesToForward( level.the_bus.angles ) );
	unlink_pos = level.the_bus.origin + vectorScale( bus_forward, -144 );
	unlink_pos = groundpos_ignore_water_new( unlink_pos + vectorScale( ( 0, 0, 1 ), 60 ) );
	self.shield = 1;
	self avogadro_teleport( unlink_pos, self.angles, 1 );
	self.state = "idle";
	self.ignoreall = 0;
}

bus_disable_show( time )
{
	self endon( "death" );
	wait time;
	self.shield = 0;
	self show();
}

bus_disable( bus_attack_struct )
{
	self endon( "melee_pain" );
	self.bus_attack_struct = bus_attack_struct;
	origin = level.the_bus gettagorigin( bus_attack_struct.window_tag );
	angles = level.the_bus gettagangles( bus_attack_struct.window_tag );
	self avogadro_teleport( origin, angles, 0,5, bus_attack_struct.window_tag );
	self linkto( level.the_bus, bus_attack_struct.window_tag );
	bus_disable_show( 0,1 );
	origin = level.the_bus gettagorigin( bus_attack_struct.window_tag );
	angles = level.the_bus gettagangles( bus_attack_struct.window_tag );
	self animscripted( origin, angles, "zm_bus_attack", bus_attack_struct.substate );
/#
	avogadro_print( "bus_disable " + bus_attack_struct.substate );
#/
	success = 0;
	self.mod_melee = 0;
	self.bus_shock_time = 0;
	level thread maps/mp/zm_transit_bus::do_player_bus_zombie_vox( "avogadro_onbus", 45 );
	while ( 1 )
	{
		wait 0,1;
		self.bus_attack_time += 0,1;
		if ( self.bus_attack_time >= 20 )
		{
			self.bus_disabled = 1;
			level thread maps/mp/zm_transit_bus::do_player_bus_zombie_vox( "avogadro_stopbus", 45 );
			return;
		}
		else
		{
			self.bus_shock_time += 0,1;
			while ( self.bus_shock_time >= 2 )
			{
				self.bus_shock_time = 0;
				players = get_players();
				_a796 = players;
				_k796 = getFirstArrayKey( _a796 );
				while ( isDefined( _k796 ) )
				{
					player = _a796[ _k796 ];
					if ( isDefined( player.isonbus ) && player.isonbus )
					{
						maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_ai_avogadro_electrified", player, 1, 1 );
						player shellshock( "electrocution", 1 );
						player notify( "avogadro_damage_taken" );
						player thread do_player_general_vox( "general", "avogadro_attack", 30, 45 );
					}
					_k796 = getNextArrayKey( _a796, _k796 );
				}
			}
			if ( level.the_bus.numaliveplayersridingbus == 0 )
			{
				self detach_from_bus();
				self notify( "stop_bus_attack" );
			}
		}
	}
}

avogadro_exit( from )
{
	self.state = "exiting";
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self setfreecameralockonallowed( 0 );
	self.audio_loop_ent stoploopsound( 0,5 );
	self notify( "stop_health" );
	if ( isDefined( self.health_fx ) )
	{
		self.health_fx unlink();
		self.health_fx delete();
	}
	if ( isDefined( from ) )
	{
		if ( from == "bus" )
		{
			self playsound( "zmb_avogadro_death_short" );
			playfx( level._effect[ "avogadro_ascend_aerial" ], self.origin );
			self animscripted( self.origin, self.angles, "zm_bus_win" );
			maps/mp/animscripts/zm_shared::donotetracks( "bus_win_anim" );
		}
		else if ( from == "chamber" )
		{
			self playsound( "zmb_avogadro_death_short" );
			playfx( level._effect[ "avogadro_ascend" ], self.origin );
			self animscripted( self.origin, self.angles, "zm_chamber_out" );
			wait 0,4;
			self ghost();
			stop_exploder( 500 );
		}
		else
		{
			self playsound( "zmb_avogadro_death" );
			playfx( level._effect[ "avogadro_ascend" ], self.origin );
			self animscripted( self.origin, self.angles, "zm_exit" );
			maps/mp/animscripts/zm_shared::donotetracks( "exit_anim" );
		}
	}
	else
	{
		self playsound( "zmb_avogadro_death" );
		playfx( level._effect[ "avogadro_ascend" ], self.origin );
		self animscripted( self.origin, self.angles, "zm_exit" );
		maps/mp/animscripts/zm_shared::donotetracks( "exit_anim" );
	}
	if ( !isDefined( from ) || from != "chamber" )
	{
		level thread do_avogadro_flee_vo( self );
	}
	self ghost();
	self.hit_by_melee = 0;
	self.anchor.origin = self.origin;
	self.anchor.angles = self.angles;
	self linkto( self.anchor );
	if ( isDefined( from ) && from == "exit_idle" )
	{
		self.return_round = level.round_number + 1;
	}
	else
	{
		self.return_round = level.round_number + randomintrange( 2, 5 );
	}
	level.next_avogadro_round = self.return_round;
	self.state = "cloud";
	self thread cloud_update_fx();
}

cloud_update_fx()
{
	self endon( "cloud_fx_end" );
	level endon( "end_game" );
	region = [];
	region[ 0 ] = "bus";
	region[ 1 ] = "diner";
	region[ 2 ] = "farm";
	region[ 3 ] = "cornfield";
	region[ 4 ] = "power";
	region[ 5 ] = "town";
	self.current_region = undefined;
	if ( !isDefined( self.sndent ) )
	{
		self.sndent = spawn( "script_origin", ( 0, 0, 1 ) );
		self.sndent playloopsound( "zmb_avogadro_thunder_overhead" );
	}
	cloud_time = getTime();
	vo_counter = 0;
	while ( 1 )
	{
		if ( getTime() >= cloud_time )
		{
			if ( isDefined( self.current_region ) )
			{
				exploder_num = level.transit_region[ self.current_region ].exploder;
				stop_exploder( exploder_num );
			}
			rand_region = array_randomize( region );
			region_str = rand_region[ 0 ];
			if ( !isDefined( self.current_region ) )
			{
				region_str = region[ 4 ];
			}
/#
			idx = getDvarInt( #"FD251E42" );
			if ( idx >= 0 )
			{
				region_str = region[ idx ];
			}
			avogadro_print( "clouds in region " + region_str );
#/
			self.current_region = region_str;
			exploder_num = level.transit_region[ region_str ].exploder;
			exploder( exploder_num );
			self.sndent moveto( level.transit_region[ region_str ].sndorigin, 3 );
			cloud_time = getTime() + 30000;
		}
		if ( vo_counter > 50 )
		{
			player = self get_player_in_region();
			if ( isDefined( player ) )
			{
				if ( isDefined( self._in_cloud ) && self._in_cloud )
				{
					player thread do_player_general_vox( "general", "avogadro_above", 90, 10 );
				}
				else
				{
					player thread do_player_general_vox( "general", "avogadro_arrive", 60, 40 );
				}
			}
			else
			{
				level thread avogadro_storm_vox();
			}
			vo_counter = 0;
		}
		wait 0,1;
		vo_counter++;
	}
}

cloud_update()
{
	self endon( "melee_pain" );
	return_from_cloud = 0;
	self._in_cloud = 1;
	if ( level.round_number >= self.return_round )
	{
/#
		avogadro_print( "return from round" );
#/
		return_from_cloud = 1;
		self._in_cloud = 0;
	}
	while ( isDefined( return_from_cloud ) && return_from_cloud )
	{
/#
		avogadro_print( "time to come back in " + self.current_region );
#/
		self notify( "cloud_fx_end" );
		new_origin = cloud_find_spawn();
		if ( isDefined( self.sndent ) )
		{
			self.sndent delete();
			self.sndent = undefined;
		}
		if ( !isDefined( new_origin ) )
		{
			new_origin = maps/mp/zombies/_zm::check_for_valid_spawn_near_team();
		}
		while ( isDefined( new_origin ) )
		{
			self thread avogadro_update_health();
			playsoundatposition( "zmb_avogadro_spawn_3d", new_origin );
			self.audio_loop_ent playloopsound( "zmb_avogadro_loop", 0,5 );
			self unlink();
			ground_pos = groundpos_ignore_water_new( new_origin + vectorScale( ( 0, 0, 1 ), 60 ) );
			playfx( level._effect[ "avogadro_descend" ], ground_pos );
			self animscripted( ground_pos, self.anchor.angles, "zm_arrival" );
			maps/mp/animscripts/zm_shared::donotetracks( "arrival_anim" );
			self setfreecameralockonallowed( 1 );
			time_to_leave = getTime() + 30000;
			while ( 1 )
			{
				if ( getTime() > time_to_leave )
				{
/#
					avogadro_print( "enemy never showed - leaving" );
#/
					self avogadro_exit( "exit_idle" );
					return;
				}
				if ( self enemy_in_region() )
				{
					self.ignoreall = 0;
					self.state = "idle";
					return;
				}
				wait 0,1;
			}
		}
	}
}

enemy_in_region()
{
	zones = level.transit_region[ self.current_region ].zones;
	_a1071 = zones;
	_k1071 = getFirstArrayKey( _a1071 );
	while ( isDefined( _k1071 ) )
	{
		zone = _a1071[ _k1071 ];
		if ( level.zones[ zone ].is_occupied )
		{
			self.ignoreall = 0;
			self.state = "idle";
			return 1;
		}
		_k1071 = getNextArrayKey( _a1071, _k1071 );
	}
	return 0;
}

get_player_in_region()
{
	players = get_players();
	players = array_randomize( players );
	zones = level.transit_region[ self.current_region ].zones;
	_a1091 = zones;
	_k1091 = getFirstArrayKey( _a1091 );
	while ( isDefined( _k1091 ) )
	{
		zone = _a1091[ _k1091 ];
		while ( level.zones[ zone ].is_occupied )
		{
			_a1095 = players;
			_k1095 = getFirstArrayKey( _a1095 );
			while ( isDefined( _k1095 ) )
			{
				player = _a1095[ _k1095 ];
				if ( player maps/mp/zombies/_zm_zonemgr::is_player_in_zone( zone ) )
				{
					return player;
				}
				_k1095 = getNextArrayKey( _a1095, _k1095 );
			}
		}
		_k1091 = getNextArrayKey( _a1091, _k1091 );
	}
	return undefined;
}

cloud_find_spawn()
{
	zones = level.transit_region[ self.current_region ].zones;
	use_points = [];
	_a1116 = zones;
	_k1116 = getFirstArrayKey( _a1116 );
	while ( isDefined( _k1116 ) )
	{
		zone = _a1116[ _k1116 ];
		if ( zone == "zone_pri" )
		{
			if ( !level.zones[ zone ].is_occupied )
			{
				if ( !flag( "OnPriDoorYar2" ) )
				{
/#
					avogadro_print( "zone_pri not occupied and door is closed" );
#/
				}
			}
		}
		else
		{
			while ( level.zones[ zone ].is_enabled && level.zones[ zone ].is_spawning_allowed )
			{
				locations = level.zones[ zone ].avogadro_locations;
				_a1135 = locations;
				_k1135 = getFirstArrayKey( _a1135 );
				while ( isDefined( _k1135 ) )
				{
					loc = _a1135[ _k1135 ];
					use_points[ use_points.size ] = loc;
					_k1135 = getNextArrayKey( _a1135, _k1135 );
				}
			}
		}
		_k1116 = getNextArrayKey( _a1116, _k1116 );
	}
	if ( use_points.size > 0 )
	{
		use_points = array_randomize( use_points );
		return use_points[ 0 ].origin;
	}
	return undefined;
}

avogadro_reveal( show_time )
{
	self endon( "death" );
	self show();
	wait show_time;
	self ghost();
}

avogadro_teleport( dest_pos, dest_angles, lerp_time, tag_override )
{
	self.is_teleport = 1;
	self.phase_fx = spawn( "script_model", self.origin );
	self.phase_fx setmodel( "tag_origin" );
	self.phase_fx linkto( self );
	wait 0,1;
	playfxontag( level._effect[ "avogadro_phase_trail" ], self.phase_fx, "tag_origin" );
	playfx( level._effect[ "avogadro_phasing" ], self.origin );
	self avogadro_reveal( 0,1 );
	self playsound( "zmb_avogadro_warp_out" );
	self.anchor.origin = self.origin;
	self.anchor.angles = self.angles;
	self linkto( self.anchor );
	self.anchor moveto( dest_pos, lerp_time );
	self.anchor waittill( "movedone" );
	self.anchor.origin = dest_pos;
	self.anchor.angles = dest_angles;
	self unlink();
	wait 0,1;
	if ( isDefined( tag_override ) )
	{
		dest_pos = level.the_bus gettagorigin( tag_override );
		dest_angles = level.the_bus gettagangles( tag_override );
	}
	self forceteleport( dest_pos, dest_angles );
	playfx( level._effect[ "avogadro_phasing" ], self.origin );
	if ( isDefined( self.phase_fx ) )
	{
		self.phase_fx delete();
	}
	self avogadro_reveal( 0,1 );
	self playsound( "zmb_avogadro_warp_in" );
	self.is_teleport = 0;
}

check_range_attack()
{
/#
	if ( getDvarInt( #"A40002E9" ) )
	{
		return 0;
#/
	}
	enemy = self.favoriteenemy;
	if ( isDefined( enemy ) )
	{
		vec_enemy = enemy.origin - self.origin;
		dist_sq = lengthsquared( vec_enemy );
		if ( dist_sq > 14400 && dist_sq < 360000 )
		{
			vec_facing = anglesToForward( self.angles );
			norm_facing = vectornormalize( vec_facing );
			norm_enemy = vectornormalize( vec_enemy );
			dot = vectordot( norm_facing, norm_enemy );
			if ( dot > 0,99 )
			{
				enemy_eye_pos = enemy geteye();
				eye_pos = self geteye();
				passed = bullettracepassed( eye_pos, enemy_eye_pos, 0, undefined );
				if ( passed )
				{
					return 1;
				}
			}
		}
	}
	return 0;
}

range_attack()
{
	self endon( "melee_pain" );
	enemy = self.favoriteenemy;
	if ( isDefined( enemy ) )
	{
		self thread shoot_bolt_wait( "ranged_attack", enemy );
		self show();
		self animscripted( self.origin, self.angles, "zm_ranged_attack_in" );
		maps/mp/animscripts/zm_shared::donotetracks( "ranged_attack" );
		self animscripted( self.origin, self.angles, "zm_ranged_attack_loop" );
		maps/mp/animscripts/zm_shared::donotetracks( "ranged_attack" );
		self animscripted( self.origin, self.angles, "zm_ranged_attack_out" );
		maps/mp/animscripts/zm_shared::donotetracks( "ranged_attack" );
		self.shield = 1;
		self thread avogadro_update_health();
		self ghost();
	}
}

shoot_bolt_wait( animname, enemy )
{
	self endon( "melee_pain" );
	self waittillmatch( animname );
	return "fire";
	self.shield = 0;
	self notify( "stop_health" );
	if ( isDefined( self.health_fx ) )
	{
		self.health_fx unlink();
		self.health_fx delete();
	}
	self thread shoot_bolt( enemy );
}

shoot_bolt( enemy )
{
	source_pos = self gettagorigin( "tag_weapon_right" );
	target_pos = enemy geteye();
	bolt = spawn( "script_model", source_pos );
	bolt setmodel( "tag_origin" );
	wait 0,1;
	self playsound( "zmb_avogadro_attack" );
	fx = playfxontag( level._effect[ "avogadro_bolt" ], bolt, "tag_origin" );
	bolt moveto( target_pos, 0,2 );
	bolt waittill( "movedone" );
	bolt.owner = self;
	bolt check_bolt_impact( enemy );
	bolt delete();
}

check_bolt_impact( enemy )
{
	if ( is_player_valid( enemy ) )
	{
		enemy_eye_pos = enemy geteye();
		dist_sq = distancesquared( self.origin, enemy_eye_pos );
		if ( dist_sq < 4096 )
		{
			passed = bullettracepassed( self.origin, enemy_eye_pos, 0, undefined );
			if ( passed )
			{
				maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_ai_avogadro_electrified", enemy, 1, 1 );
				enemy shellshock( "electrocution", 1 );
				enemy playsoundtoplayer( "zmb_avogadro_electrified", enemy );
				enemy dodamage( 60, enemy.origin );
				enemy notify( "avogadro_damage_taken" );
			}
		}
	}
}

region_empty()
{
	if ( getTime() >= self.region_timer )
	{
		player = self get_player_in_region();
		if ( isDefined( player ) )
		{
			self.region_timer = getTime() + 500;
			return 0;
		}
/#
		debug_dist_sq = 0;
#/
		players = getplayers();
		_a1371 = players;
		_k1371 = getFirstArrayKey( _a1371 );
		while ( isDefined( _k1371 ) )
		{
			player = _a1371[ _k1371 ];
			if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
			}
			else
			{
				dist_sq = distancesquared( self.origin, player.origin );
/#
				debug_dist_sq = distance( self.origin, player.origin );
#/
				if ( dist_sq < 9000000 )
				{
					self.region_timer = getTime() + 500;
					return 0;
				}
			}
			_k1371 = getNextArrayKey( _a1371, _k1371 );
		}
		self.region_timer = getTime() + 500;
/#
		avogadro_print( "no one left to kill " + debug_dist_sq );
#/
		return 1;
	}
	return 0;
}

get_random_phase_state()
{
	index = randomint( 4 );
	state = level.avogadro_phase[ index ].animstate;
	return state;
}

check_phase()
{
/#
	if ( getDvarInt( #"CFB33742" ) )
	{
		return 0;
#/
	}
	if ( getTime() > self.phase_time )
	{
		if ( isDefined( self.is_traversing ) && self.is_traversing )
		{
			self.phase_time = getTime() + 2000;
			return 0;
		}
		self.phase_state = get_random_phase_state();
		self.phase_substate = randomint( 3 );
		anim_id = self getanimfromasd( self.phase_state, self.phase_substate );
		if ( self maymovefrompointtopoint( self.origin, getanimendpos( anim_id ) ) )
		{
			return 1;
		}
	}
	return 0;
}

do_phase()
{
	self endon( "death" );
	self.state = "phasing";
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self setfreecameralockonallowed( 0 );
	self.ignoreall = 1;
	self thread phase_failsafe();
	self animcustom( ::play_phase_anim );
	self waittill( "phase_anim_done" );
	self.ignoreall = 0;
	self setfreecameralockonallowed( 1 );
	self.state = "idle";
}

play_phase_anim()
{
	self endon( "death" );
	self endon( "phase_anim_done" );
	self.phase_fx = spawn( "script_model", self.origin );
	self.phase_fx setmodel( "tag_origin" );
	self.phase_fx linkto( self );
	wait 0,05;
	playfxontag( level._effect[ "avogadro_phase_trail" ], self.phase_fx, "tag_origin" );
	playfx( level._effect[ "avogadro_phasing" ], self.origin );
	self avogadro_reveal( 0,1 );
	self playsound( "zmb_avogadro_warp_out" );
	self orientmode( "face enemy" );
	self setanimstatefromasd( self.phase_state, self.phase_substate );
	maps/mp/animscripts/zm_shared::donotetracks( "teleport_anim" );
	self.phase_fx delete();
	playfx( level._effect[ "avogadro_phasing" ], self.origin );
	self avogadro_reveal( 0,1 );
	self orientmode( "face default" );
	self playsound( "zmb_avogadro_warp_in" );
	self.phase_time = getTime() + 2000;
	self notify( "phase_anim_done" );
}

phase_failsafe()
{
	self endon( "phase_anim_done" );
	wait 1;
	if ( self.state == "phasing" || self.state == "chasing_bus" )
	{
/#
		avogadro_print( "phasing too long, failsafe kicking in" );
#/
		if ( isDefined( self.phase_fx ) )
		{
			self.phase_fx delete();
		}
		playfx( level._effect[ "avogadro_phasing" ], self.origin );
		self avogadro_reveal( 0,1 );
		self orientmode( "face default" );
		self playsound( "zmb_avogadro_warp_in" );
		self.phase_time = getTime() + 2000;
		self notify( "phase_anim_done" );
	}
}

avogadro_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( einflictor ) && isDefined( einflictor.is_avogadro ) && einflictor.is_avogadro )
	{
		if ( smeansofdeath == "MOD_MELEE" )
		{
			maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_ai_avogadro_electrified", self, 0,25, 1 );
			self shellshock( "electrocution", 0,25 );
			self notify( "avogadro_damage_taken" );
			self thread do_player_general_vox( "general", "avogadro_attack", 15, 45 );
		}
	}
	return -1;
}

avogadro_pain_watcher()
{
	self notify( "stop_pain_watcher" );
	self endon( "stop_pain_watcher" );
	wait 4;
	if ( isDefined( self.in_pain ) && self.in_pain )
	{
		self.in_pain = 0;
/#
		avogadro_print( "in_pain for too long" );
#/
	}
}

avogadro_pain( einflictor )
{
	self endon( "melee_pain" );
	self.in_pain = 1;
	self playsound( "zmb_avogadro_pain" );
	self thread avogadro_pain_watcher();
	substate = 0;
	origin = self.origin;
	angles = self.angles;
	animstate = "zm_pain";
	if ( self.state == "attacking_bus" || self.state == "stay_attached" )
	{
		tag = self.bus_attack_struct.window_tag;
		if ( tag == "window_left_rear_jnt" )
		{
			animstate = "zm_bus_back_pain";
		}
		else
		{
			animstate = "zm_bus_pain";
		}
		origin = level.the_bus gettagorigin( tag );
		angles = level.the_bus gettagangles( tag );
	}
	if ( self.hit_by_melee < 4 )
	{
		self thread avogadro_update_health();
		self animscripted( origin, angles, animstate, substate );
		maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
		self ghost();
		self.phase_time = getTime() - 1;
		if ( self.state == "stay_attached" )
		{
			self attach_to_bus();
		}
	}
	else self notify( "stop_bus_attack" );
	level notify( "avogadro_defeated" );
	if ( isDefined( einflictor ) && isplayer( einflictor ) )
	{
		einflictor maps/mp/zombies/_zm_stats::increment_client_stat( "avogadro_defeated", 0 );
		einflictor maps/mp/zombies/_zm_stats::increment_player_stat( "avogadro_defeated" );
	}
	if ( flag( "power_on" ) && flag( "switches_on" ) && self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr" ) )
	{
/#
		avogadro_print( "come back on power" );
#/
		self show();
		self.in_pain = 0;
/#
		avogadro_print( "pain cleared from zone_prr" );
#/
		self notify( "stop_pain_watcher" );
		self avogadro_teleport( self.core_model.origin, self.core_model.angles, 1 );
		core_mover = getent( "core_mover", "targetname" );
		self linkto( core_mover, "tag_origin" );
		while ( flag( "power_on" ) )
		{
			wait 0,1;
		}
		self show();
		self.state = "chamber";
		self setanimstatefromasd( "zm_chamber_idle" );
	}
	else
	{
/#
		if ( !flag( "power_on" ) )
		{
			avogadro_print( "no power" );
		}
		if ( !flag( "switches_on" ) )
		{
			avogadro_print( "no switches" );
		}
		if ( !self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr" ) )
		{
			avogadro_print( "no zone" );
#/
		}
		self show();
		self avogadro_exit();
	}
	self.in_pain = 0;
/#
	avogadro_print( "pain cleared normal" );
#/
	self notify( "stop_pain_watcher" );
}

avogadro_update_health()
{
	self endon( "death" );
	self notify( "stop_health" );
	self endon( "stop_health" );
	while ( 1 )
	{
		self avogadro_update_health_fx();
		wait 0,4;
	}
}

avogadro_update_health_fx()
{
	self endon( "death" );
	if ( !isDefined( self.health_fx ) )
	{
		tag_origin = self gettagorigin( "J_SpineUpper" );
		tag_angles = self gettagangles( "J_SpineUpper" );
		self.health_fx = spawn( "script_model", tag_origin );
		self.health_fx.angles = tag_angles;
		self.health_fx setmodel( "tag_origin" );
		self.health_fx linkto( self );
		wait 0,1;
	}
	if ( self.hit_by_melee == 0 )
	{
		playfxontag( level._effect[ "avogadro_health_full" ], self.health_fx, "tag_origin" );
	}
	else if ( self.hit_by_melee <= 2 )
	{
		playfxontag( level._effect[ "avogadro_health_half" ], self.health_fx, "tag_origin" );
	}
	else
	{
		playfxontag( level._effect[ "avogadro_health_low" ], self.health_fx, "tag_origin" );
	}
}

avogadro_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( self.state == "exiting" || self.state == "phasing" )
	{
		return 0;
	}
	if ( smeansofdeath == "MOD_MELEE" )
	{
		if ( isplayer( einflictor ) )
		{
			if ( isDefined( einflictor.avogadro_melee_time ) )
			{
			}
			if ( self.shield )
			{
				einflictor.avogadro_melee_time = getTime();
				maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_ai_avogadro_electrified", einflictor, 0,25, 1 );
				einflictor shellshock( "electrocution", 0,25 );
				einflictor notify( "avogadro_damage_taken" );
			}
			if ( sweapon == "riotshield_zm" )
			{
				shield_damage = level.zombie_vars[ "riotshield_fling_damage_shield" ];
				einflictor maps/mp/zombies/_zm_weap_riotshield::player_damage_shield( shield_damage, 0 );
			}
		}
		if ( !self.shield )
		{
			self.shield = 1;
			self notify( "melee_pain" );
			if ( sweapon == "tazer_knuckles_zm" )
			{
				self.hit_by_melee += 2;
			}
			else
			{
				self.hit_by_melee++;
			}
			self thread avogadro_pain( einflictor );
/#
			avogadro_print( "hit_by_melee: " + self.hit_by_melee );
#/
			if ( isplayer( einflictor ) )
			{
				einflictor thread do_player_general_vox( "general", "avogadro_wound", 30, 35 );
				level notify( "avogadro_stabbed" );
			}
		}
		else
		{
/#
			avogadro_print( "shield up, no damage" );
#/
		}
	}
	else
	{
		self update_damage_absorbed( idamage );
	}
	return 0;
}

update_damage_absorbed( damage )
{
	if ( self.hit_by_melee > 0 )
	{
		self.damage_absorbed += damage;
		if ( self.damage_absorbed >= 1000 )
		{
			self.damage_absorbed = 0;
			self.hit_by_melee--;

/#
			avogadro_print( "regen - hit_by_melee: " + self.hit_by_melee );
#/
		}
	}
}

avogadro_non_attacker( damage, weapon )
{
	if ( weapon == "zombie_bullet_crouch_zm" )
	{
		self update_damage_absorbed( damage );
	}
	return 0;
}

stun_avogadro()
{
	ignore_emp_states = [];
	ignore_emp_states[ 0 ] = "phasing";
	ignore_emp_states[ 1 ] = "chamber";
	ignore_emp_states[ 2 ] = "wait_for_player";
	ignore_emp_states[ 3 ] = "exiting";
	ignore_emp_states[ 4 ] = "cloud";
	_a1854 = ignore_emp_states;
	_k1854 = getFirstArrayKey( _a1854 );
	while ( isDefined( _k1854 ) )
	{
		state = _a1854[ _k1854 ];
		if ( self.state == state )
		{
			return;
		}
		_k1854 = getNextArrayKey( _a1854, _k1854 );
	}
	if ( self.hit_by_melee < 4 )
	{
/#
		avogadro_print( "stunned during " + self.state );
#/
		level notify( "stun_avogadro" );
		self notify( "stunned" );
		self notify( "melee_pain" );
		self.hit_by_melee += 4;
		self thread avogadro_pain();
	}
}

fling_avogadro( player )
{
}

drag_avogadro( vdir )
{
}

avogadro_debug_axis()
{
/#
	self endon( "death" );
	while ( 1 )
	{
		if ( !isDefined( self.debug_axis ) )
		{
			self.debug_axis = spawn( "script_model", self.origin );
			self.debug_axis setmodel( "fx_axis_createfx" );
		}
		else
		{
			self.debug_axis.origin = self.origin;
			self.debug_axis.angles = self.angles;
		}
		wait 0,1;
#/
	}
}

avogadro_print( str )
{
/#
	if ( getDvarInt( #"92514885" ) )
	{
		iprintln( "avogadro: " + str );
		if ( isDefined( self.debug_msg ) )
		{
			self.debug_msg[ self.debug_msg.size ] = str;
			if ( self.debug_msg.size > 64 )
			{
				self.debug_msg = [];
			}
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

do_avogadro_flee_vo( avogadro )
{
	players = get_players();
	_a1944 = players;
	_k1944 = getFirstArrayKey( _a1944 );
	while ( isDefined( _k1944 ) )
	{
		player = _a1944[ _k1944 ];
		if ( distancesquared( player.origin, avogadro.origin ) < 250000 )
		{
			player thread do_player_general_vox( "general", "avogadro_flee", 30, 45 );
			return;
		}
		_k1944 = getNextArrayKey( _a1944, _k1944 );
	}
}

avogadro_storm_vox()
{
	if ( isDefined( level.checking_avogadro_storm_vox ) && level.checking_avogadro_storm_vox )
	{
		return;
	}
	level.checking_avogadro_storm_vox = 1;
	players = get_players();
	players = array_randomize( players );
	_a1963 = players;
	_k1963 = getFirstArrayKey( _a1963 );
	while ( isDefined( _k1963 ) )
	{
		player = _a1963[ _k1963 ];
		if ( !player maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_tbu" ) && !player maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_amb_tunnel" ) && !player maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_prr" ) || player maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_pcr" ) && player maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_pow_warehouse" ) )
		{
		}
		else
		{
			player thread do_player_general_vox( "general", "avogadro_storm", 120, 2 );
		}
		_k1963 = getNextArrayKey( _a1963, _k1963 );
	}
	wait 5;
	level.checking_avogadro_storm_vox = 0;
}
