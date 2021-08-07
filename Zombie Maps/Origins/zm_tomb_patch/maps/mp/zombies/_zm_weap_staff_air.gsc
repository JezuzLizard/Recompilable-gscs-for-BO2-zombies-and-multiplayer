#include maps/mp/animscripts/shared;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level._effect[ "whirlwind" ] = loadfx( "weapon/zmb_staff/fx_zmb_staff_air_ug_impact_miss" );
	registerclientfield( "scriptmover", "whirlwind_play_fx", 14000, 1, "int" );
	registerclientfield( "actor", "air_staff_launch", 14000, 1, "int" );
	registerclientfield( "allplayers", "air_staff_source", 14000, 1, "int" );
	onplayerconnect_callback( ::onplayerconnect );
	maps/mp/zombies/_zm_ai_basic::init_inert_zombies();
	flag_init( "whirlwind_active" );
	maps/mp/zombies/_zm_spawner::register_zombie_damage_callback( ::staff_air_zombie_damage_response );
	maps/mp/zombies/_zm_spawner::register_zombie_death_event_callback( ::staff_air_death_event );
}

precache()
{
	precacheitem( "staff_air_melee_zm" );
}

onplayerconnect()
{
	self thread onplayerspawned();
}

onplayerspawned()
{
	self endon( "disconnect" );
	self thread watch_staff_air_fired();
	self thread watch_staff_air_impact();
	self thread watch_staff_usage();
}

air_projectile_delete()
{
	self endon( "death" );
	wait 0,75;
	self delete();
}

watch_staff_air_fired()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "missile_fire", e_projectile, str_weapon );
		if ( str_weapon == "staff_air_upgraded_zm" || str_weapon == "staff_air_zm" )
		{
			e_projectile thread air_projectile_delete();
			wind_damage_cone( str_weapon );
			self setclientfield( "air_staff_source", 1 );
			wait_network_frame();
			self setclientfield( "air_staff_source", 0 );
		}
	}
}

watch_staff_air_impact()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "projectile_impact", str_weap_name, v_explode_point, n_radius, projectile );
		if ( str_weap_name == "staff_air_upgraded2_zm" || str_weap_name == "staff_air_upgraded3_zm" )
		{
			self thread staff_air_find_source( v_explode_point, str_weap_name );
		}
	}
}

staff_air_find_source( v_detonate, str_weapon )
{
	self endon( "disconnect" );
	if ( !isDefined( v_detonate ) )
	{
		return;
	}
	a_zombies = getaiarray( level.zombie_team );
	a_zombies = get_array_of_closest( v_detonate, a_zombies );
	if ( a_zombies.size )
	{
		i = 0;
		while ( i < a_zombies.size )
		{
			if ( isalive( a_zombies[ i ] ) )
			{
				if ( is_true( a_zombies[ i ].staff_hit ) )
				{
					i++;
					continue;
				}
				else
				{
					if ( distance2dsquared( v_detonate, a_zombies[ i ].origin ) <= 10000 )
					{
						self thread staff_air_zombie_source( a_zombies[ 0 ], str_weapon );
					}
					else
					{
						self thread staff_air_position_source( v_detonate, str_weapon );
					}
					return;
				}
			}
			i++;
		}
	}
	else self thread staff_air_position_source( v_detonate, str_weapon );
}

staff_air_zombie_source( ai_zombie, str_weapon )
{
	self endon( "disconnect" );
	ai_zombie.staff_hit = 1;
	ai_zombie.is_source = 1;
	v_whirlwind_pos = ai_zombie.origin;
	self thread staff_air_position_source( v_whirlwind_pos, str_weapon );
	if ( !isDefined( ai_zombie.is_mechz ) )
	{
		self thread source_zombie_death( ai_zombie );
	}
}

staff_air_position_source( v_detonate, str_weapon )
{
	self endon( "disconnect" );
	if ( !isDefined( v_detonate ) )
	{
		return;
	}
	if ( flag( "whirlwind_active" ) )
	{
		level notify( "whirlwind_stopped" );
		while ( flag( "whirlwind_active" ) )
		{
			wait_network_frame();
		}
		wait 0,3;
	}
	flag_set( "whirlwind_active" );
	n_time = self.chargeshotlevel * 3,5;
	e_whirlwind = spawn( "script_model", v_detonate + vectorScale( ( 0, 0, 0 ), 100 ) );
	e_whirlwind setmodel( "tag_origin" );
	e_whirlwind.angles = vectorScale( ( 0, 0, 0 ), 90 );
	e_whirlwind thread puzzle_debug_position( "X", vectorScale( ( 0, 0, 0 ), 255 ) );
	e_whirlwind moveto( groundpos_ignore_water_new( e_whirlwind.origin ), 0,05 );
	e_whirlwind waittill( "movedone" );
	e_whirlwind setclientfield( "whirlwind_play_fx", 1 );
	e_whirlwind thread whirlwind_rumble_nearby_players( "whirlwind_active" );
	e_whirlwind thread whirlwind_timeout( n_time );
	wait 0,5;
	e_whirlwind.player_owner = self;
	e_whirlwind thread whirlwind_seek_zombies( self.chargeshotlevel, str_weapon );
}

whirlwind_seek_zombies( n_level, str_weapon )
{
	self endon( "death" );
	self.b_found_zombies = 0;
	n_range = get_air_blast_range( n_level );
	while ( 1 )
	{
		a_zombies = staff_air_zombie_range( self.origin, n_range );
		if ( a_zombies.size )
		{
			self.b_found_zombies = 1;
			self thread whirlwind_kill_zombies( n_level, str_weapon );
			return;
		}
		else
		{
			wait 0,1;
		}
	}
}

whirlwind_timeout( n_time )
{
	self endon( "death" );
	level waittill_any_or_timeout( n_time, "whirlwind_stopped" );
	level notify( "whirlwind_stopped" );
	self setclientfield( "whirlwind_play_fx", 0 );
	self notify( "stop_debug_position" );
	flag_clear( "whirlwind_active" );
	wait 1,5;
	self delete();
}

move_along_ground_position( v_position, n_time )
{
	v_diff = vectornormalize( v_position - self.origin );
	v_newpos = self.origin + ( v_diff * 50 ) + vectorScale( ( 0, 0, 0 ), 50 );
	v_ground = groundpos_ignore_water_new( v_newpos );
	self moveto( v_ground, n_time );
}

whirlwind_kill_zombies( n_level, str_weapon )
{
	self endon( "death" );
	n_range = get_air_blast_range( n_level );
	self.n_charge_level = n_level;
	while ( 1 )
	{
		a_zombies = staff_air_zombie_range( self.origin, n_range );
		a_zombies = get_array_of_closest( self.origin, a_zombies );
		i = 0;
		while ( i < a_zombies.size )
		{
			if ( !isDefined( a_zombies[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( a_zombies[ i ].ai_state != "find_flesh" )
			{
				i++;
				continue;
			}
			else if ( is_true( a_zombies[ i ].is_mechz ) )
			{
				i++;
				continue;
			}
			else if ( is_true( self._whirlwind_attract_anim ) )
			{
				i++;
				continue;
			}
			else v_offset = ( 10, 10, 32 );
			if ( !bullet_trace_throttled( self.origin + v_offset, a_zombies[ i ].origin + v_offset, undefined ) )
			{
				i++;
				continue;
			}
			else if ( !isDefined( a_zombies[ i ] ) || !isalive( a_zombies[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				v_offset = ( -10, -10, 64 );
				if ( !bullet_trace_throttled( self.origin + v_offset, a_zombies[ i ].origin + v_offset, undefined ) )
				{
					i++;
					continue;
				}
				else if ( !isDefined( a_zombies[ i ] ) || !isalive( a_zombies[ i ] ) )
				{
					i++;
					continue;
				}
				else
				{
					a_zombies[ i ] thread whirlwind_drag_zombie( self, str_weapon );
					wait 0,5;
				}
			}
			i++;
		}
		wait_network_frame();
	}
}

whirlwind_drag_zombie( e_whirlwind, str_weapon )
{
	if ( isDefined( self.e_linker ) )
	{
		return;
	}
	self whirlwind_move_zombie( e_whirlwind );
	if ( isDefined( self ) && isDefined( e_whirlwind ) && flag( "whirlwind_active" ) )
	{
		player = e_whirlwind.player_owner;
		self do_damage_network_safe( player, self.health, str_weapon, "MOD_IMPACT" );
		level thread staff_air_gib( self );
	}
}

whirlwind_move_zombie( e_whirlwind )
{
	if ( isDefined( self.e_linker ) )
	{
		return;
	}
	self.e_linker = spawn( "script_origin", ( 0, 0, 0 ) );
	self.e_linker.origin = self.origin;
	self.e_linker.angles = self.angles;
	self linkto( self.e_linker );
	self thread whirlwind_unlink( e_whirlwind );
	if ( isDefined( e_whirlwind ) )
	{
		n_dist_sq = distance2dsquared( e_whirlwind.origin, self.origin );
	}
	n_fling_range_sq = 900;
	while ( isalive( self ) && n_dist_sq > n_fling_range_sq && isDefined( e_whirlwind ) && flag( "whirlwind_active" ) )
	{
		n_dist_sq = distance2dsquared( e_whirlwind.origin, self.origin );
		if ( isDefined( self.ai_state ) && self.ai_state == "find_flesh" )
		{
			b_supercharged = e_whirlwind.n_charge_level == 3;
			self thread whirlwind_attract_anim( e_whirlwind.origin, b_supercharged );
			n_movetime = 1;
			if ( b_supercharged )
			{
				n_movetime = 0,8;
			}
			self.e_linker thread move_along_ground_position( e_whirlwind.origin, n_movetime );
		}
		else
		{
		}
		wait 0,05;
	}
	self notify( "reached_whirlwind" );
	self.e_linker delete();
}

whirlwind_unlink( e_whirlwind )
{
	self endon( "death" );
	e_whirlwind waittill( "death" );
	self unlink();
}

source_zombie_death( ai_zombie )
{
	self endon( "disconnect" );
	n_range = get_air_blast_range( self.chargeshotlevel );
	tag = "J_SpineUpper";
	if ( ai_zombie.isdog )
	{
		tag = "J_Spine1";
	}
	v_source = ai_zombie gettagorigin( tag );
	ai_zombie thread staff_air_fling_zombie( self );
	a_zombies = staff_air_zombie_range( v_source, n_range );
	if ( !isDefined( a_zombies ) )
	{
		return;
	}
	self thread staff_air_proximity_kill( a_zombies );
}

get_air_blast_range( n_charge )
{
	switch( n_charge )
	{
		case 1:
			n_range = 100;
			break;
		default:
			n_range = 250;
			break;
	}
	return n_range;
}

staff_air_proximity_kill( a_zombies )
{
	self endon( "disconnect" );
	if ( !isDefined( a_zombies ) )
	{
		return;
	}
	i = 0;
	while ( i < a_zombies.size )
	{
		if ( isalive( a_zombies[ i ] ) )
		{
			a_zombies[ i ] thread staff_air_fling_zombie( self );
			wait 0,05;
		}
		i++;
	}
}

staff_air_zombie_range( v_source, n_range )
{
	a_enemies = [];
	a_zombies = getaiarray( level.zombie_team );
	a_zombies = get_array_of_closest( v_source, a_zombies );
	n_range_sq = n_range * n_range;
	while ( isDefined( a_zombies ) )
	{
		i = 0;
		while ( i < a_zombies.size )
		{
			if ( !isDefined( a_zombies[ i ] ) )
			{
				i++;
				continue;
			}
			else v_zombie_pos = a_zombies[ i ].origin;
			if ( isDefined( a_zombies[ i ].staff_hit ) && a_zombies[ i ].staff_hit == 1 )
			{
				i++;
				continue;
			}
			else
			{
				if ( distancesquared( v_source, v_zombie_pos ) > n_range_sq )
				{
					i++;
					continue;
				}
				else
				{
					a_enemies[ a_enemies.size ] = a_zombies[ i ];
				}
			}
			i++;
		}
	}
	return a_enemies;
}

staff_air_fling_zombie( player )
{
	player endon( "disconnect" );
	if ( !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.is_source ) || cointoss() )
	{
		self thread zombie_launch( player, "staff_air_upgraded_zm" );
	}
	else
	{
		self do_damage_network_safe( player, self.health, "staff_air_upgraded_zm", "MOD_IMPACT" );
		level thread staff_air_gib( self );
	}
}

zombie_launch( e_attacker, str_weapon )
{
	self do_damage_network_safe( e_attacker, self.health, str_weapon, "MOD_IMPACT" );
	if ( isDefined( level.ragdoll_limit_check ) && !( [[ level.ragdoll_limit_check ]]() ) )
	{
		level thread staff_air_gib( self );
	}
	else
	{
		self startragdoll();
		self setclientfield( "air_staff_launch", 1 );
	}
}

determine_launch_vector( e_attacker, ai_target )
{
	v_launch = ( vectornormalize( ai_target.origin - e_attacker.origin ) * randomintrange( 125, 150 ) ) + ( 0, 0, randomintrange( 75, 150 ) );
	return v_launch;
}

staff_air_gib( ai_zombie )
{
	if ( cointoss() )
	{
		ai_zombie thread zombie_gib_all();
	}
	ai_zombie thread zombie_gib_guts();
}

staff_air_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
	if ( self is_staff_air_damage() && mod != "MOD_MELEE" )
	{
		self thread stun_zombie();
		return 1;
	}
	return 0;
}

is_staff_air_damage()
{
	if ( isDefined( self.damageweapon ) && self.damageweapon != "staff_air_zm" && self.damageweapon == "staff_air_upgraded_zm" )
	{
		return !is_true( self.set_beacon_damage );
	}
}

staff_air_death_event()
{
	if ( is_staff_air_damage() && self.damagemod != "MOD_MELEE" )
	{
		if ( is_true( self.is_mechz ) )
		{
			return;
		}
		self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "death", self.animname );
		self thread zombie_eye_glow_stop();
		if ( isDefined( level.ragdoll_limit_check ) && !( [[ level.ragdoll_limit_check ]]() ) )
		{
			level thread staff_air_gib( self );
			return;
		}
		else
		{
			self startragdoll();
			self setclientfield( "air_staff_launch", 1 );
		}
	}
}

wind_damage_cone( str_weapon )
{
	fire_angles = self getplayerangles();
	fire_origin = self getplayercamerapos();
	a_targets = getaiarray( "axis" );
	a_targets = get_array_of_closest( self.origin, a_targets, undefined, 12, 400 );
	if ( str_weapon == "staff_air_upgraded_zm" )
	{
		n_damage = 3300;
		n_fov = 60;
	}
	else
	{
		n_damage = 2050;
		n_fov = 45;
	}
	_a675 = a_targets;
	_k675 = getFirstArrayKey( _a675 );
	while ( isDefined( _k675 ) )
	{
		target = _a675[ _k675 ];
		if ( isai( target ) )
		{
			if ( within_fov( fire_origin, fire_angles, target gettagorigin( "j_spine4" ), cos( n_fov ) ) )
			{
				if ( self maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
				{
					n_damage = target.health;
				}
				target do_damage_network_safe( self, n_damage, str_weapon, "MOD_IMPACT" );
			}
		}
		_k675 = getNextArrayKey( _a675, _k675 );
	}
}

stun_zombie()
{
	self endon( "death" );
	if ( is_true( self.is_mechz ) )
	{
		return;
	}
	if ( is_true( self.is_electrocuted ) )
	{
		return;
	}
	if ( !isDefined( self.ai_state ) || self.ai_state != "find_flesh" )
	{
		return;
	}
	self.forcemovementscriptstate = 1;
	self.ignoreall = 1;
	self.is_electrocuted = 1;
	tag = "J_SpineUpper";
	if ( self.isdog )
	{
		tag = "J_Spine1";
	}
	self animscripted( self.origin, self.angles, "zm_electric_stun" );
	self maps/mp/animscripts/shared::donotetracks( "stunned" );
	self.forcemovementscriptstate = 0;
	self.ignoreall = 0;
	self.is_electrocuted = 0;
}

whirlwind_attract_anim_watch_cancel()
{
	self endon( "death" );
	while ( flag( "whirlwind_active" ) )
	{
		wait_network_frame();
	}
	self.deathanim = undefined;
	self stopanimscripted();
	self._whirlwind_attract_anim = 0;
}

whirlwind_attract_anim( v_attract_point, b_move_fast )
{
	if ( !isDefined( b_move_fast ) )
	{
		b_move_fast = 0;
	}
	self endon( "death" );
	level endon( "whirlwind_stopped" );
	if ( is_true( self._whirlwind_attract_anim ) )
	{
		return;
	}
	v_angles_to_source = vectorToAngle( v_attract_point - self.origin );
	v_source_to_target = vectorToAngle( self.origin - v_attract_point );
	self.a.runblendtime = 0,9;
	if ( self.has_legs )
	{
		self.needs_run_update = 1;
		self._had_legs = 1;
		if ( b_move_fast )
		{
			self animscripted( self.origin, v_source_to_target, "zm_move_whirlwind_fast" );
		}
		else
		{
			self animscripted( self.origin, v_source_to_target, "zm_move_whirlwind" );
		}
	}
	else self.needs_run_update = 1;
	self._had_legs = 0;
	if ( b_move_fast )
	{
		self animscripted( self.origin, v_source_to_target, "zm_move_whirlwind_crawl" );
	}
	else
	{
		self animscripted( self.origin, v_source_to_target, "zm_move_whirlwind_fast_crawl" );
	}
	if ( is_true( self.nogravity ) )
	{
		self animmode( "none" );
		self.nogravity = undefined;
	}
	self._whirlwind_attract_anim = 1;
	self.a.runblendtime = self._normal_run_blend_time;
	self thread whirlwind_attract_anim_watch_cancel();
	self waittill( "reached_whirlwind" );
}
