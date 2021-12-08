#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "slowgun_zm" ) )
	{
		return;
	}
	registerclientfield( "actor", "slowgun_fx", 12000, 3, "int" );
	registerclientfield( "actor", "anim_rate", 7000, 5, "float" );
	registerclientfield( "allplayers", "anim_rate", 7000, 5, "float" );
	registerclientfield( "toplayer", "sndParalyzerLoop", 12000, 1, "int" );
	registerclientfield( "toplayer", "slowgun_fx", 12000, 1, "int" );
	level.sliquifier_distance_checks = 0;
	maps/mp/zombies/_zm_spawner::add_cusom_zombie_spawn_logic( ::slowgun_on_zombie_spawned );
	maps/mp/zombies/_zm_spawner::register_zombie_damage_callback( ::slowgun_zombie_damage_response );
	maps/mp/zombies/_zm_spawner::register_zombie_death_animscript_callback( ::slowgun_zombie_death_response );
	level._effect[ "zombie_slowgun_explosion" ] = loadfx( "weapon/paralyzer/fx_paralyzer_body_disintegrate" );
	level._effect[ "zombie_slowgun_explosion_ug" ] = loadfx( "weapon/paralyzer/fx_paralyzer_body_disintegrate_ug" );
	level._effect[ "zombie_slowgun_sizzle" ] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_dmg" );
	level._effect[ "zombie_slowgun_sizzle_ug" ] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_dmg_ug" );
	level._effect[ "player_slowgun_sizzle" ] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_noharm" );
	level._effect[ "player_slowgun_sizzle_ug" ] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_noharm" );
	level._effect[ "player_slowgun_sizzle_1st" ] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_noharm_view" );
	onplayerconnect_callback( ::slowgun_player_connect );
	level.slowgun_damage = 40;
	level.slowgun_damage_ug = 60;
	level.slowgun_damage_mod = "MOD_PROJECTILE_SPLASH";
	precacherumble( "damage_heavy" );
}

slowgun_player_connect() //checked matches cerberus output
{
	self thread watch_reset_anim_rate();
	self thread watch_slowgun_fired();
	self thread sndwatchforweapswitch();
}

sndwatchforweapswitch() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "weapon_change", weapon );
		if ( weapon == "slowgun_zm" || weapon == "slowgun_upgraded_zm" )
		{
			self setclientfieldtoplayer( "sndParalyzerLoop", 1 );
			self waittill( "weapon_change" );
			self setclientfieldtoplayer( "sndParalyzerLoop", 0 );
		}
	}
}

watch_reset_anim_rate() //checked matches cerberus output
{
	self set_anim_rate( 1 );
	self setclientfieldtoplayer( "slowgun_fx", 0 );
	while ( 1 )
	{
		self waittill_any( "spawned", "entering_last_stand", "player_revived", "player_suicide", "respawned" );
		self setclientfieldtoplayer( "slowgun_fx", 0 );
		self set_anim_rate( 1 );
	}
}

watch_slowgun_fired() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	for ( ;; )
	{
		self waittill( "weapon_fired", weapon );
		wait 0.05;
		if ( weapon == "slowgun_zm" )
		{
			self slowgun_fired( 0 );
		}
		else if ( weapon == "slowgun_upgraded_zm" )
		{
			self slowgun_fired( 1 );
		}
	}
}

slowgun_fired( upgraded ) //checked changed to match cerberus output
{
	origin = self getweaponmuzzlepoint();
	forward = self getweaponforwarddir();

	targets = self get_targets_in_range( upgraded, origin, forward );
	foreach ( target in targets )
	{
		if ( isplayer( target ) )
		{
			if ( is_player_valid( target ) && self != target )
			{
				target thread player_paralyzed( self, upgraded );
			}
		}
		if ( isdefined(target.paralyzer_hit_callback ) )
		{
			target thread [[ target.paralyzer_hit_callback ]]( self, upgraded );
		}
		target thread zombie_paralyzed( self, upgraded );
	}
	dot = vectordot( forward, ( 0, 0, -1 ) );
	if ( dot > 0.8 )
	{
		self thread player_paralyzed( self, upgraded );
	}
}

slowgun_get_enemies_in_range( upgraded, position, forward, possible_targets ) //checked changed to match cerberus output
{
	inner_range = 12;
	outer_range = 660;
	cylinder_radius = 48;
	level.slowgun_enemies = [];
	view_pos = position;
	if ( !isDefined( possible_targets ) )
	{
		return level.slowgun_enemies;
	}
	slowgun_inner_range_squared = inner_range * inner_range;
	slowgun_outer_range_squared = outer_range * outer_range;
	cylinder_radius_squared = cylinder_radius * cylinder_radius;
	forward_view_angles = forward;
	end_pos = view_pos + vectorScale( forward_view_angles, outer_range );
	i = 0;
	while ( i < possible_targets.size )
	{
		if ( !isdefined( possible_targets[ i ] ) || !isalive( possible_targets[ i ] ) )
		{
			i++;
			continue;
		}
		test_origin = possible_targets[ i ] getcentroid();
		test_range_squared = distancesquared( view_pos, test_origin );
		if ( test_range_squared > slowgun_outer_range_squared )
		{
			//possible_targets[ i ] slowgun_debug_print("range",  1, 0, 0 );
			i++;
			continue;
		}
		normal = vectornormalize( test_origin - view_pos );
		dot = vectordot(forward_view_angles, normal);
		if ( 0 > dot )
		{
			//possible_targets[ i ] slowgun_debug_print( "dot",  1, 0, 0 );
			i++;
			continue;
		}
		radial_origin = pointonsegmentnearesttopoint( view_pos, end_pos, test_origin );
		if ( distancesquared( test_origin, radial_origin ) > cylinder_radius_squared )
		{
			//possible_targets[ i ] slowgun_debug_print( "cylinder",  1, 0, 0 );
			i++;
			continue;
		}
		if ( 0 == possible_targets[ i ] damageconetrace( view_pos, self ) )
		{
			//possible_targets[ i ] slowgun_debug_print( "cone",  1, 0, 0 );
			i++;
			continue;
		}
		i++;
		level.slowgun_enemies[ level.slowgun_enemies.size ] = possible_targets [ i ];
	}
	return level.slowgun_enemies;
}


get_targets_in_range( upgraded, position, forward ) //checked matches cerberus output
{
	if ( !isDefined( self.slowgun_targets ) || getTime() - self.slowgun_target_time > 150 )
	{
		targets = [];
		possible_targets = getaispeciesarray( level.zombie_team, "all" );
		possible_targets = arraycombine( possible_targets, get_players(), 1, 0 );
		if ( isDefined( level.possible_slowgun_targets ) && level.possible_slowgun_targets.size > 0 )
		{
			possible_targets = arraycombine( possible_targets, level.possible_slowgun_targets, 1, 0 );
		}
		targets = slowgun_get_enemies_in_range( 0, position, forward, possible_targets );
		self.slowgun_targets = targets;
		self.slowgun_target_time = getTime();
	}
	return self.slowgun_targets;
}

slowgun_on_zombie_spawned() //checked matches cerberus output
{
	self set_anim_rate( 1 );
	self.paralyzer_hit_callback = ::zombie_paralyzed;
	self.paralyzer_damaged_multiplier = 1;
	self.paralyzer_score_time_ms = getTime();
	self.paralyzer_slowtime = 0;
	self setclientfield( "slowgun_fx", 0 );
}

can_be_paralyzed( zombie ) //checked matches cerberus output
{
	if ( is_true( zombie.is_ghost ) )
	{
		return 0;
	}
	if ( is_true( zombie.guts_explosion ) )
	{
		return 0;
	}
	if ( isDefined( zombie ) && zombie.health > 0 )
	{
		return 1;
	}
	return 0;
}

set_anim_rate( rate ) //checked matches cerberus output
{
	if ( isDefined( self ) )
	{
		self.slowgun_anim_rate = rate;
		if ( !is_true( level.ignore_slowgun_anim_rates ) && !is_true( self.ignore_slowgun_anim_rates ) )
		{
			self setclientfield( "anim_rate", rate );
			qrate = self getclientfield( "anim_rate" );
			self setentityanimrate( qrate );
			if ( isDefined( self.set_anim_rate ) )
			{
				self [[ self.set_anim_rate ]]( rate );
			}
		}
	}
}

reset_anim() //checked matches cerberus output
{
	wait_network_frame();
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( is_true( self.is_traversing ) )
	{
		animstate = self getanimstatefromasd();
		if ( !is_true( self.no_restart ) )
		{
			self.no_restart = 1;
			animstate += "_no_restart";
		}
		substate = self getanimsubstatefromasd();
		self setanimstatefromasd( animstate, substate );
	}
	else
	{
		self.needs_run_update = 1;
		self notify( "needs_run_update" );
	}
}

zombie_change_rate( time, newrate ) //checked matches cerberus output
{
	self set_anim_rate( newrate );
	if ( isDefined( self.reset_anim ) )
	{
		self thread [[ self.reset_anim ]]();
	}
	else
	{
		self thread reset_anim();
	}
	if ( time > 0 )
	{
		wait time;
	}
}

zombie_slow_for_time( time, multiplier ) //checked changed to match cerberus output
{
	if ( !isDefined( multiplier ) )
	{
		multiplier = 2;
	}
	paralyzer_time_per_frame = 0.1 * ( 1 + multiplier );
	if ( self.paralyzer_slowtime <= time )
	{
		self.paralyzer_slowtime = time + paralyzer_time_per_frame;
	}
	else
	{
		self.paralyzer_slowtime += paralyzer_time_per_frame;
	}
	if ( !isDefined( self.slowgun_anim_rate ) )
	{
		self.slowgun_anim_rate = 1;
	}
	if ( !isDefined( self.slowgun_desired_anim_rate ) )
	{
		self.slowgun_desired_anim_rate = 1;
	}
	if ( self.slowgun_desired_anim_rate > 0.3 )
	{
		self.slowgun_desired_anim_rate -= 0.2;
	}
	else
	{
		self.slowgun_desired_anim_rate = 0.05;
	}
	if ( is_true( self.slowing ) )
	{
		return;
	}
	self.slowing = 1;
	self.preserve_asd_substates = 1;
	self playloopsound( "wpn_paralyzer_slowed_loop", 0.1 );
	while ( self.paralyzer_slowtime > 0 && isalive( self ) )
	{
		if ( self.paralyzer_slowtime < 0.1 )
		{
			self.slowgun_desired_anim_rate = 1;
		}
		else if ( self.paralyzer_slowtime < ( 2 * 0.1 ) )
		{
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.8 );
		}
		else if ( self.paralyzer_slowtime < ( 3 * 0.1 ) )
		{
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.6 );
		}
		else if ( self.paralyzer_slowtime < ( 4 * 0.1 ) )
		{
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.4 );
		}
		else if ( self.paralyzer_slowtime < ( 5 * 0.1 ) )
		{
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.2 );
		}
		if ( self.slowgun_desired_anim_rate == self.slowgun_anim_rate )
		{
			self.paralyzer_slowtime -= 0.1;
			wait 0.1;
		}
		else if ( self.slowgun_desired_anim_rate >= self.slowgun_anim_rate )
		{
			new_rate = self.slowgun_desired_anim_rate;
			if ( ( self.slowgun_desired_anim_rate - self.slowgun_anim_rate ) > 0.2 )
			{
				new_rate = self.slowgun_anim_rate + 0.2;
			}
			self.paralyzer_slowtime -= 0.1;
			zombie_change_rate( 0.1, new_rate );
			self.paralyzer_damaged_multiplier = 1;
		}
		if ( self.slowgun_desired_anim_rate <= self.slowgun_anim_rate )
		{
			new_rate = self.slowgun_desired_anim_rate;
			if ( ( self.slowgun_anim_rate - self.slowgun_desired_anim_rate ) > 0.2 )
			{
				new_rate = self.slowgun_anim_rate - 0.2;
			}
			self.paralyzer_slowtime -= 0.25;
			zombie_change_rate( 0.25, new_rate );
		}
	}
	if ( self.slowgun_anim_rate < 1 )
	{
		self zombie_change_rate( 0, 1 );
	}
	self.preserve_asd_substates = 0;
	self.slowing = 0;
	self.paralyzer_damaged_multiplier = 1;
	self setclientfield( "slowgun_fx", 0 );
	self stoploopsound( 0.1 );
}

zombie_paralyzed( player, upgraded ) //checked changed to match cerberus output
{
	if ( !can_be_paralyzed( self ) )
	{
		return;
	}
	insta = player maps/mp/zombies/_zm_powerups::is_insta_kill_active();
	if ( upgraded )
	{
		self setclientfield( "slowgun_fx", 5 );
	}
	else
	{
		self setclientfield( "slowgun_fx", 1 );
	}
	if ( self.slowgun_anim_rate <= 0.1 || insta && self.slowgun_anim_rate <= 0.5 )
	{
		if ( upgraded )
		{
			damage = level.slowgun_damage_ug;
		}
		else
		{
			damage = level.slowgun_damage;
		}
		damage *= randomfloatrange( 0.667, 1.5 );
		damage *= self.paralyzer_damaged_multiplier;
		//extra code from cerberus output that was missing
		if ( !isdefined(self.paralyzer_damage ) )
		{
			self.paralyzer_damage = 0;
		}
		if ( self.paralyzer_damage > 47073 )
		{
			damage = damage * 47073 / self.paralyzer_damage;
		}
		self.paralyzer_damage = self.paralyzer_damage + damage;
		
		if ( insta )
		{
			damage = self.health + 666;
		}
		if ( isalive( self ) )
		{
			self dodamage( damage, player.origin, player, player, "none", level.slowgun_damage_mod, 0, "slowgun_zm" );
		}
		self.paralyzer_damaged_multiplier *= 1.15;
		//extra code from cerberus output
		self.paralyzer_damaged_multiplier = min( self.paralyzer_damaged_multiplier, 50 );
	}
	else
	{
		self.paralyzer_damaged_multiplier = 1;
	}
	self zombie_slow_for_time( 0.2 );
}

get_extra_damage( amount, mod, slow ) //checked matches cerberus output
{
	mult = 1 - slow;
	return amount * slow;
}

slowgun_zombie_damage_response( mod, hit_location, hit_origin, player, amount ) //checked changed to match cerberus output
{
	if ( !self is_slowgun_damage( self.damagemod, self.damageweapon ) )
	{
		if ( isDefined( self.slowgun_anim_rate ) && self.slowgun_anim_rate < 1 && mod != level.slowgun_damage_mod )
		{
			extra_damage = get_extra_damage( amount, mod, self.slowgun_anim_rate );
			if ( extra_damage > 0 )
			{
				if ( isalive( self ) )
				{
					self dodamage( extra_damage, hit_origin, player, player, hit_location, level.slowgun_damage_mod, 0, "slowgun_zm" );
				}
				if ( !isalive( self ) )
				{
					return 1;
				}
			}
		}
		return 0;
	}
	if ( ( getTime() - self.paralyzer_score_time_ms ) >= 500 )
	{
		self.paralyzer_score_time_ms = getTime();
		if ( self.paralyzer_damage < 47073 )
		{
			player maps/mp/zombies/_zm_score::player_add_points( "damage", mod, hit_location, self.isdog, level.zombie_team );
		}
	}
	if ( player maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
	{
		amount = self.health + 666;
	}
	if ( isalive( self ) )
	{
		self dodamage( amount, hit_origin, player, player, hit_location, mod, 0, "slowgun_zm" );
	}
	return 1;
}

explosion_choke() //checked matches cerberus output
{
	if ( !isDefined( level.slowgun_explosion_time ) )
	{
		level.slowgun_explosion_time = 0;
	}
	if ( level.slowgun_explosion_time != getTime() )
	{
		level.slowgun_explosion_count = 0;
		level.slowgun_explosion_time = getTime();
	}
	while ( level.slowgun_explosion_count > 4 )
	{
		wait 0.05;
		if ( level.slowgun_explosion_time != getTime() )
		{
			level.slowgun_explosion_count = 0;
			level.slowgun_explosion_time = getTime();
		}
	}
	level.slowgun_explosion_count++;
	return;
}

explode_into_dust( player, upgraded ) //checked matches cerberus output
{
	if ( isDefined( self.marked_for_insta_upgraded_death ) )
	{
		return;
	}
	explosion_choke();
	if ( upgraded )
	{
		self setclientfield( "slowgun_fx", 6 );
	}
	else
	{
		self setclientfield( "slowgun_fx", 2 );
	}
	self.guts_explosion = 1;
	self ghost();
}

slowgun_zombie_death_response() //checked matches cerberus output
{
	if ( !self is_slowgun_damage( self.damagemod, self.damageweapon ) )
	{
		return 0;
	}
	level maps/mp/zombies/_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );
	self thread explode_into_dust( self.attacker, self.damageweapon == "slowgun_upgraded_zm" );
	return 1;
}

is_slowgun_damage( mod, weapon ) //checked does not match cerberus output changed at own discretion
{
	if ( isDefined( weapon ) )
	{
		if ( weapon == "slowgun_upgraded_zm" || weapon == "slowgun_zm" )
		{
			return 1;
		}
	}
	return 0;
}

setjumpenabled( onoff ) //checked changed to match cerberus output
{
	if ( onoff )
	{
		if ( isDefined( self.jump_was_enabled ) )
		{
			self allowjump( self.jump_was_enabled );
			self.jump_was_enabled = undefined;
		}
		else
		{
			self allowjump( 1 );
		}
	}
	else if ( !isDefined( self.jump_was_enabled ) )
	{
		self.jump_was_enabled = self allowjump( 0 );
	}
}

get_ahead_ent() //checked changed to match cerberus output
{
	velocity = self getvelocity();
	if ( lengthsquared( velocity ) < 225 )
	{
		return undefined;
	}
	start = self geteyeapprox();
	end = start + ( velocity * 0.25 );
	mins = ( 0, 0, 0 );
	maxs = ( 0, 0, 0 );
	trace = physicstrace( start, end, vectorScale( ( -1, -1, 0 ), 15 ), vectorScale( ( 1, 1, 0 ), 15 ), self, level.physicstracemaskclip );
	if ( isDefined( trace[ "entity" ] ) )
	{
		return trace[ "entity" ];
	}
	else
	{
		if ( trace[ "fraction" ] < 0.99 || trace[ "surfacetype" ] != "none" )
		{
			return level;
		}
	}
	return undefined;
}

bump() //checked matched cerberus output
{
	self playrumbleonentity( "damage_heavy" );
	earthquake( 0.5, 0.15, self.origin, 1000, self );
}

player_fly_rumble() //checked matches cerberus output
{
	self endon( "player_slow_stop_flying" );
	self endon( "disconnect" );
	self endon( "platform_collapse" );
	self.slowgun_flying = 1;
	last_ground = self getgroundent();
	last_ahead = undefined;
	while ( 1 )
	{
		ground = self getgroundent();
		if ( isDefined( ground ) != isDefined( last_ground ) || ground != last_ground )
		{
			if ( isDefined( ground ) )
			{
				self bump();
			}
		}
		if ( isDefined( ground ) && !self.slowgun_flying )
		{
			self thread dont_tread_on_z();
			return;
		}
		last_ground = ground;
		if ( isDefined( ground ) )
		{
			last_ahead = undefined;
		}
		else
		{
			ahead = self get_ahead_ent();
			if ( isDefined( ahead ) )
			{
				if ( isDefined( ahead ) != isDefined( last_ahead ) || ahead != last_ahead )
				{
					self playsoundtoplayer( "zmb_invis_barrier_hit", self );
					chance = get_response_chance( "invisible_collision" );
					if ( chance > randomintrange( 1, 100 ) )
					{
						self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "invisible_collision" );
					}
					self bump();
				}
			}
			last_ahead = ahead;
		}
		wait 0.15;
	}
}

dont_tread_on_z() //checked matches cerberus output
{
	if ( !isDefined( level.ghost_head_damage ) )
	{
		level.ghost_head_damage = 30;
	}
	ground = self getgroundent();
	while ( isDefined( ground ) && isDefined( ground.team ) && ground.team == level.zombie_team )
	{
		first_ground = ground;
		while ( !isDefined( ground ) || isDefined( ground.team ) && ground.team == level.zombie_team )
		{
			if ( is_true( self.slowgun_flying ) )
			{
				return;
			}
			if ( isDefined( ground ) )
			{
				self dodamage( level.ghost_head_damage, ground.origin, ground );
				if ( is_true( ground.is_ghost ) )
				{
					level.ghost_head_damage *= 1.5;
					if ( self.score > 4000 )
					{
						self.score -= 4000;
					}
					else
					{
						self.score = 0;
					}
				}
			}
			else
			{
				self dodamage( level.ghost_head_damage, first_ground.origin, first_ground );
			}
			wait 0.25;
			ground = self getgroundent();
		}
	}
}

player_slow_for_time( time ) //checked matches cerberus output
{
	self notify( "player_slow_for_time" );
	self endon( "player_slow_for_time" );
	self endon( "disconnect" );
	if ( !is_true( self.slowgun_flying ) )
	{
		self thread player_fly_rumble();
	}
	self setclientfieldtoplayer( "slowgun_fx", 1 );
	self set_anim_rate( 0.05 );
	wait time;
	self set_anim_rate( 1 );
	self setclientfieldtoplayer( "slowgun_fx", 0 );
	self.slowgun_flying = 0;
}

player_paralyzed( byplayer, upgraded ) //checked changed to match cerberus output
{
	self notify( "player_paralyzed" );
	self endon( "player_paralyzed" );
	self endon( "death" );
	if ( isDefined( level.slowgun_allow_player_paralyze ) )
	{
		if ( !self [[ level.slowgun_allow_player_paralyze ]]() )
		{
			return;
		}
	}
	if ( self != byplayer )
	{
		sizzle = "player_slowgun_sizzle";
		if ( upgraded )
		{
			sizzle = "player_slowgun_sizzle_ug";
		}
		if ( isDefined( level._effect[ sizzle ] ) )
		{
			playfxontag( level._effect[ sizzle ], self, "J_SpineLower" );
		}
	}
	self thread player_slow_for_time( 0.25 );
}

slowgun_debug_print( msg, color )
{
/*
/#
	if ( getDvarInt( #"61A711C2" ) != 2 )
	{
		return;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 1, 0 );
	}
	print3d( self.origin + vectorScale( ( 0, 1, 0 ), 60 ), msg, color, 1, 1, 40 );
#/
*/
}

show_anim_rate( pos, dsquared )
{
/*
/#
	if ( distancesquared( pos, self.origin ) > dsquared )
	{
		return;
	}
	rate = self getentityanimrate();
	color = ( 1 - rate, rate, 0 );
	text = "" + int( rate * 100 ) + " S";
	print3d( self.origin + ( 0, 1, 0 ), text, color, 1, 0,5, 1 );
#/
*/
}

show_slow_time( pos, dsquared, insta )
{
/*
/#
	if ( distancesquared( pos, self.origin ) > dsquared )
	{
		return;
	}
	rate = self.paralyzer_slowtime;
	if ( !isDefined( rate ) || rate < 0,05 )
	{
		return;
	}
	if ( self getentityanimrate() <= 0,1 || insta && self getentityanimrate() <= 0,5 )
	{
		color = ( 0, 1, 0 );
	}
	else
	{
		color = ( 0, 1, 0 );
	}
	text = "" + rate + "";
	print3d( self.origin + vectorScale( ( 0, 1, 0 ), 50 ), text, color, 1, 0,5, 1 );
#/
*/
}

show_anim_rates()
{
/*
/#
	while ( 1 )
	{
		if ( getDvarInt( #"61A711C2" ) == 1 )
		{
			lp = get_players()[ 0 ];
			insta = lp maps/mp/zombies/_zm_powerups::is_insta_kill_active();
			zombies = getaispeciesarray( "all", "all" );
			while ( isDefined( zombies ) )
			{
				_a858 = zombies;
				_k858 = getFirstArrayKey( _a858 );
				while ( isDefined( _k858 ) )
				{
					zombie = _a858[ _k858 ];
					zombie show_slow_time( lp.origin, 360000, insta );
					_k858 = getNextArrayKey( _a858, _k858 );
				}
			}
			if ( isDefined( level.sloth ) )
			{
				level.sloth show_slow_time( lp.origin, 360000, 0 );
			}
		}
		while ( getDvarInt( #"61A711C2" ) == 3 )
		{
			lp = get_players()[ 0 ];
			_a871 = get_players();
			_k871 = getFirstArrayKey( _a871 );
			while ( isDefined( _k871 ) )
			{
				player = _a871[ _k871 ];
				player show_anim_rate( lp.origin, 360000 );
				_k871 = getNextArrayKey( _a871, _k871 );
			}
			zombies = getaispeciesarray( "all", "all" );
			while ( isDefined( zombies ) )
			{
				_a879 = zombies;
				_k879 = getFirstArrayKey( _a879 );
				while ( isDefined( _k879 ) )
				{
					zombie = _a879[ _k879 ];
					zombie show_anim_rate( lp.origin, 360000 );
					_k879 = getNextArrayKey( _a879, _k879 );
				}
			}
		}
		wait 0,05;
#/
	}
*/
}

show_muzzle( origin, forward )
{
/*
/#
	if ( getDvarInt( #"61A711C2" ) == 4 )
	{
		seconds = 0,25;
		grey = vectorScale( ( 0, 1, 0 ), 0,3 );
		green = ( 0, 1, 0 );
		start = origin;
		end = origin + ( 12 * forward );
		frames = int( 20 * seconds );
		line( start, end, green, 1, 0, frames );
#/
	}
*/
}

