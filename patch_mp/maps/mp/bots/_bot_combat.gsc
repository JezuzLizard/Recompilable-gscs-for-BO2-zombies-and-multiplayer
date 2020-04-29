#include maps/mp/gametypes/_weapon_utils;
#include maps/mp/bots/_bot;
#include maps/mp/_utility;
#include common_scripts/utility;

bot_combat_think( damage, attacker, direction )
{
	self allowattack( 0 );
	self pressads( 0 );
	for ( ;; )
	{
		if ( self atgoal( "enemy_patrol" ) )
		{
			self cancelgoal( "enemy_patrol" );
		}
		self maps/mp/bots/_bot::bot_update_failsafe();
		self maps/mp/bots/_bot::bot_update_crouch();
		self maps/mp/bots/_bot::bot_update_crate();
		if ( !bot_can_do_combat() )
		{
			return;
		}
		difficulty = maps/mp/bots/_bot::bot_get_difficulty();
/#
		if ( bot_has_enemy() )
		{
			if ( getDvarInt( "bot_IgnoreHumans" ) )
			{
				if ( isplayer( self.bot.threat.entity ) && !self.bot.threat.entity is_bot() )
				{
					self bot_combat_idle();
#/
				}
			}
		}
		sight = bot_best_enemy();
		bot_select_weapon();
		ent = self.bot.threat.entity;
		pos = self.bot.threat.position;
		if ( !sight )
		{
			if ( threat_is_player() )
			{
				if ( distancesquared( self.origin, ent.origin ) < 65536 )
				{
					prediction = self predictposition( ent, 4 );
					height = ent getplayerviewheight();
					self lookat( prediction + ( 0, 0, height ) );
					self addgoal( ent.origin, 24, 4, "enemy_patrol" );
					self allowattack( 0 );
					wait 0,05;
					continue;
				}
				else self addgoal( self.origin, 24, 3, "enemy_patrol" );
				if ( difficulty != "easy" && cointoss() )
				{
					self bot_combat_throw_lethal( pos );
					self bot_combat_throw_tactical( pos );
				}
				bot_combat_dead();
				self addgoal( pos, 24, 4, "enemy_patrol" );
			}
			bot_combat_idle( damage, attacker, direction );
			return;
		}
		else
		{
			if ( threat_dead() )
			{
				bot_combat_dead();
				return;
			}
		}
		bot_update_cover();
		bot_combat_main();
		if ( threat_is_turret() )
		{
			bot_turret_set_dangerous( ent );
			bot_combat_throw_smoke( ent.origin );
		}
		if ( !threat_is_turret() || threat_is_ai_tank() && threat_is_equipment() )
		{
			bot_combat_throw_emp( ent.origin );
			bot_combat_throw_lethal( ent.origin );
		}
		else
		{
			if ( threat_is_qrdrone() )
			{
				bot_combat_throw_emp( ent.origin );
				break;
			}
			else
			{
				if ( threat_requires_rocket( ent ) )
				{
					self cancelgoal( "enemy_patrol" );
					self addgoal( self.origin, 24, 4, "cover" );
				}
			}
		}
		if ( difficulty == "easy" )
		{
			wait 0,5;
			continue;
		}
		else if ( difficulty == "normal" )
		{
			wait 0,25;
			continue;
		}
		else if ( difficulty == "hard" )
		{
			wait 0,1;
			continue;
		}
		else
		{
			wait 0,05;
		}
	}
}

bot_can_do_combat()
{
	if ( self ismantling() || self isonladder() )
	{
		return 0;
	}
	return 1;
}

threat_dead()
{
	if ( bot_has_enemy() )
	{
		ent = self.bot.threat.entity;
		if ( threat_is_turret() )
		{
			if ( isDefined( ent.dead ) )
			{
				return ent.dead;
			}
		}
		else
		{
			if ( threat_is_qrdrone() )
			{
				if ( isDefined( ent.crash_accel ) )
				{
					return ent.crash_accel;
				}
			}
		}
		return !isalive( ent );
	}
	return 1;
}

bot_can_reload()
{
	weapon = self getcurrentweapon();
	if ( weapon == "none" )
	{
		return 0;
	}
	if ( !self getweaponammostock( weapon ) )
	{
		return 0;
	}
	if ( !self isreloading() || self isswitchingweapons() && self isthrowinggrenade() )
	{
		return 0;
	}
	return 1;
}

bot_combat_idle( damage, attacker, direction )
{
	self pressads( 0 );
	self allowattack( 0 );
	self allowsprint( 1 );
	bot_clear_enemy();
	weapon = self getcurrentweapon();
	if ( bot_can_reload() )
	{
		frac = 0,5;
		if ( bot_has_lmg() )
		{
			frac = 0,25;
		}
		frac += randomfloatrange( -0,1, 0,1 );
		if ( bot_weapon_ammo_frac() < frac )
		{
			self pressusebutton( 0,1 );
		}
	}
	if ( isDefined( damage ) )
	{
		bot_patrol_near_enemy( damage, attacker, direction );
		return;
	}
	self cancelgoal( "cover" );
	self cancelgoal( "flee" );
}

bot_combat_dead( damage )
{
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	switch( difficulty )
	{
		case "easy":
			wait 0,75;
			break;
		case "normal":
			wait 0,5;
			break;
		case "hard":
			wait 0,25;
			break;
		case "fu":
			wait 0,1;
			break;
	}
	self allowattack( 0 );
	switch( difficulty )
	{
		case "easy":
		case "normal":
			wait 1;
			break;
		case "hard":
			wait_endon( 0,5, "damage" );
			break;
		case "fu":
			wait_endon( 0,25, "damage" );
			break;
	}
	bot_clear_enemy();
}

bot_combat_main()
{
	weapon = self getcurrentweapon();
	currentammo = self getweaponammoclip( weapon ) + self getweaponammostock( weapon );
	if ( !currentammo || bot_has_melee_weapon() )
	{
		if ( threat_is_player() || threat_is_dog() )
		{
			bot_combat_melee( weapon );
		}
		return;
	}
	time = getTime();
	if ( !bot_should_hip_fire() )
	{
		ads = self.bot.threat.dot > 0,96;
	}
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	if ( ads )
	{
		self pressads( 1 );
	}
	else
	{
		self pressads( 0 );
	}
	if ( ads && self playerads() < 1 )
	{
		ratio = int( floor( bot_get_converge_time() / bot_get_converge_rate() ) );
		step = ratio % 50;
		self.bot.threat.time_aim_interval = ratio - step;
		self.bot.threat.time_aim_correct = time;
		ideal = bot_update_aim( 4 );
		bot_update_lookat( ideal, 0 );
		return;
	}
	frames = 4;
	frames += randomintrange( 0, 3 );
	if ( difficulty != "fu" )
	{
		if ( distancesquared( self.bot.threat.entity.origin, self.bot.threat.position ) > 225 )
		{
			self.bot.threat.time_aim_correct = time;
			if ( time > self.bot.threat.time_first_sight )
			{
				self.bot.threat.time_first_sight = time - 100;
			}
		}
	}
	if ( time >= self.bot.threat.time_aim_correct )
	{
		self.bot.threat.time_aim_correct += self.bot.threat.time_aim_interval;
		frac = ( time - self.bot.threat.time_first_sight ) / bot_get_converge_time();
		frac = clamp( frac, 0, 1 );
		if ( !threat_is_player() )
		{
			frac = 1;
		}
		self.bot.threat.aim_target = bot_update_aim( frames );
		self.bot.threat.position = self.bot.threat.entity.origin;
		bot_update_lookat( self.bot.threat.aim_target, frac );
	}
	if ( difficulty == "hard" || difficulty == "fu" )
	{
		if ( bot_on_target( self.bot.threat.entity.origin, 30 ) )
		{
			self allowattack( 1 );
		}
		else
		{
			self allowattack( 0 );
		}
	}
	else
	{
		if ( bot_on_target( self.bot.threat.aim_target, 45 ) )
		{
			self allowattack( 1 );
		}
		else
		{
			self allowattack( 0 );
		}
	}
	if ( threat_is_equipment() )
	{
		if ( bot_on_target( self.bot.threat.entity.origin, 3 ) )
		{
			self allowattack( 1 );
		}
		else
		{
			self allowattack( 0 );
		}
	}
	if ( isDefined( self.stingerlockstarted ) && self.stingerlockstarted )
	{
		self allowattack( self.stingerlockfinalized );
		return;
	}
	if ( threat_is_player() )
	{
		if ( self iscarryingturret() && self.bot.threat.dot > 0 )
		{
			self pressattackbutton();
		}
		if ( self.bot.threat.dot > 0 && distance2dsquared( self.origin, self.bot.threat.entity.origin ) < bot_get_melee_range_sq() )
		{
			self addgoal( self.bot.threat.entity.origin, 24, 4, "enemy_patrol" );
			self pressmelee();
		}
	}
	if ( threat_using_riotshield() )
	{
		self bot_riotshield_think( self.bot.threat.entity );
	}
	else
	{
		if ( bot_has_shotgun() )
		{
			self bot_shotgun_think();
		}
	}
}

bot_combat_melee( weapon )
{
	if ( !threat_is_player() && !threat_is_dog() )
	{
		threat_ignore( self.bot.threat.entity, 60 );
		self bot_clear_enemy();
		return;
	}
	self cancelgoal( "cover" );
	self pressads( 0 );
	self allowattack( 0 );
	for ( ;; )
	{
		if ( !isalive( self.bot.threat.entity ) )
		{
			self bot_clear_enemy();
			self cancelgoal( "enemy_patrol" );
			return;
		}
		if ( self isthrowinggrenade() || self isswitchingweapons() )
		{
			self cancelgoal( "enemy_patrol" );
			return;
		}
		if ( !bot_has_melee_weapon() && self getweaponammoclip( weapon ) )
		{
			self cancelgoal( "enemy_patrol" );
			return;
		}
		frames = 4;
		prediction = self predictposition( self.bot.threat.entity, frames );
		if ( !isplayer( self.bot.threat.entity ) )
		{
			height = self.bot.threat.entity getcentroid()[ 2 ] - prediction[ 2 ];
			return prediction + ( 0, 0, height );
		}
		else
		{
			height = self.bot.threat.entity getplayerviewheight();
		}
		self lookat( prediction + ( 0, 0, height ) );
		distsq = distance2dsquared( self.origin, prediction );
		dot = bot_dot_product( self.bot.threat.entity.origin );
		if ( dot > 0 && distsq < bot_get_melee_range_sq() )
		{
			if ( self.bot.threat.entity getstance() == "prone" )
			{
				self setstance( "crouch" );
			}
			if ( weapon == "knife_held_mp" )
			{
				self pressattackbutton();
				wait 0,1;
				break;
			}
			else
			{
				self pressmelee();
				wait 0,1;
			}
		}
		goal = self getgoal( "enemy_patrol" );
		if ( !isDefined( goal ) || distancesquared( prediction, goal ) > bot_get_melee_range_sq() )
		{
			if ( !findpath( self.origin, prediction, undefined, 0, 1 ) )
			{
				threat_ignore( self.bot.threat.entity, 10 );
				self bot_clear_enemy();
				self cancelgoal( "enemy_patrol" );
				return;
			}
			if ( weapon == "riotshield_mp" )
			{
				if ( maps/mp/bots/_bot::bot_get_difficulty() != "easy" )
				{
					self setstance( "crouch" );
					self allowsprint( 0 );
				}
			}
			self addgoal( prediction, 4, 4, "enemy_patrol" );
		}
		wait 0,05;
	}
}

bot_get_fov()
{
	weapon = self getcurrentweapon();
	reduction = 1;
	if ( weapon != "none" && isweaponscopeoverlay( weapon ) && self playerads() >= 1 )
	{
		reduction = 0,25;
	}
	return self.bot.fov * reduction;
}

bot_get_converge_time()
{
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	switch( difficulty )
	{
		case "easy":
			return 3500;
			case "normal":
				return 2000;
				case "hard":
					return 1500;
					case "fu":
						return 100;
					}
					return 2000;
				}
			}
		}
	}
}

bot_get_converge_rate()
{
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	switch( difficulty )
	{
		case "easy":
			return 2;
			case "normal":
				return 4;
				case "hard":
					return 5;
					case "fu":
						return 7;
					}
					return 4;
				}
			}
		}
	}
}

bot_get_melee_range_sq()
{
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	switch( difficulty )
	{
		case "easy":
			return 1600;
			case "normal":
				return 4900;
				case "hard":
					return 4900;
					case "fu":
						return 4900;
					}
					return 4900;
				}
			}
		}
	}
}

bot_get_aim_error()
{
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	switch( difficulty )
	{
		case "easy":
			return 30;
			case "normal":
				return 20;
				case "hard":
					return 15;
					case "fu":
						return 2;
					}
					return 20;
				}
			}
		}
	}
}

bot_update_lookat( origin, frac )
{
	angles = vectorToAngle( origin - self.origin );
	right = anglesToRight( angles );
	error = bot_get_aim_error() * ( 1 - frac );
	if ( cointoss() )
	{
		error *= -1;
	}
	height = origin[ 2 ] - self.bot.threat.entity.origin[ 2 ];
	height *= 1 - frac;
	if ( cointoss() )
	{
		height *= -1;
	}
	end = origin + ( right * error );
	end += ( 0, 0, height );
	red = 1 - frac;
	green = frac;
	self lookat( end );
}

bot_on_target( aim_target, radius )
{
	angles = self getplayerangles();
	forward = anglesToForward( angles );
	origin = self getplayercamerapos();
	len = distance( aim_target, origin );
	end = origin + ( forward * len );
	if ( distance2dsquared( aim_target, end ) < ( radius * radius ) )
	{
		return 1;
	}
	return 0;
}

bot_dot_product( origin )
{
	angles = self getplayerangles();
	forward = anglesToForward( angles );
	delta = origin - self getplayercamerapos();
	delta = vectornormalize( delta );
	dot = vectordot( forward, delta );
	return dot;
}

bot_has_enemy()
{
	return isDefined( self.bot.threat.entity );
}

threat_is_player()
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) )
	{
		return isplayer( ent );
	}
}

threat_is_dog()
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) )
	{
		return isai( ent );
	}
}

threat_is_turret()
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) )
	{
		return ent.classname == "auto_turret";
	}
}

threat_is_ai_tank()
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) && isDefined( ent.targetname ) )
	{
		return ent.targetname == "talon";
	}
}

threat_is_qrdrone( ent )
{
	if ( !isDefined( ent ) )
	{
		ent = self.bot.threat.entity;
	}
	if ( isDefined( ent ) && isDefined( ent.helitype ) )
	{
		return ent.helitype == "qrdrone";
	}
}

threat_using_riotshield()
{
	if ( threat_is_player() )
	{
		weapon = self.bot.threat.entity getcurrentweapon();
		return weapon == "riotshield_mp";
	}
	return 0;
}

threat_is_equipment()
{
	ent = self.bot.threat.entity;
	if ( !isDefined( ent ) )
	{
		return 0;
	}
	if ( threat_is_player() )
	{
		return 0;
	}
	if ( isDefined( ent.model ) && ent.model == "t6_wpn_tac_insert_world" )
	{
		return 1;
	}
	if ( isDefined( ent.name ) )
	{
		return isweaponequipment( ent.name );
	}
}

bot_clear_enemy()
{
	self clearlookat();
	self.bot.threat.entity = undefined;
}

bot_best_enemy()
{
	fov = bot_get_fov();
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) )
	{
		if ( isplayer( ent ) || isai( ent ) )
		{
			dot = bot_dot_product( ent.origin );
			if ( dot >= fov )
			{
				if ( self botsighttracepassed( ent ) )
				{
					self.bot.threat.time_recent_sight = getTime();
					self.bot.threat.dot = dot;
					return 1;
				}
			}
		}
	}
	enemies = self getthreats( fov );
	_a791 = enemies;
	_k791 = getFirstArrayKey( _a791 );
	while ( isDefined( _k791 ) )
	{
		enemy = _a791[ _k791 ];
		if ( threat_should_ignore( enemy ) )
		{
		}
		else if ( !isplayer( enemy ) && enemy.classname != "grenade" )
		{
			if ( level.gametype == "hack" )
			{
				if ( enemy.classname == "script_vehicle" )
				{
				}
			}
			else if ( enemy.classname == "auto_turret" )
			{
				if ( isDefined( enemy.dead ) || enemy.dead && isDefined( enemy.carried ) && enemy.carried )
				{
				}
				else
				{
					if ( isDefined( enemy.turret_active ) && !enemy.turret_active )
					{
						break;
					}
				}
				else
				{
					if ( threat_requires_rocket( enemy ) )
					{
						if ( !bot_has_launcher() )
						{
							break;
						}
						else origin = self getplayercamerapos();
						angles = vectorToAngle( enemy.origin - origin );
						if ( angles[ 0 ] < 290 )
						{
							threat_ignore( enemy, 3,5 );
							break;
						}
					}
				}
				else
				{
					if ( self botsighttracepassed( enemy ) )
					{
						self.bot.threat.entity = enemy;
						self.bot.threat.time_first_sight = getTime();
						self.bot.threat.time_recent_sight = getTime();
						self.bot.threat.dot = bot_dot_product( enemy.origin );
						self.bot.threat.position = enemy.origin;
						return 1;
					}
				}
			}
		}
		_k791 = getNextArrayKey( _a791, _k791 );
	}
	return 0;
}

threat_requires_rocket( enemy )
{
	if ( !isDefined( enemy ) || isplayer( enemy ) )
	{
		return 0;
	}
	if ( isDefined( enemy.helitype ) && enemy.helitype == "qrdrone" )
	{
		return 0;
	}
	if ( isDefined( enemy.targetname ) )
	{
		if ( enemy.targetname == "remote_mortar" )
		{
			return 1;
		}
		else
		{
			if ( enemy.targetname == "uav" || enemy.targetname == "counteruav" )
			{
				return 1;
			}
		}
	}
	if ( enemy.classname == "script_vehicle" && enemy.vehicleclass == "helicopter" )
	{
		return 1;
	}
	return 0;
}

threat_is_warthog( enemy )
{
	if ( !isDefined( enemy ) || isplayer( enemy ) )
	{
		return 0;
	}
	if ( enemy.classname == "script_vehicle" && enemy.vehicleclass == "plane" )
	{
		return 1;
	}
	return 0;
}

threat_should_ignore( entity )
{
	ignore_time = self.bot.ignore_entity[ entity getentitynumber() ];
	if ( isDefined( ignore_time ) )
	{
		if ( getTime() < ignore_time )
		{
			return 1;
		}
	}
	return 0;
}

threat_ignore( entity, secs )
{
	self.bot.ignore_entity[ entity getentitynumber() ] = getTime() + ( secs * 1000 );
}

bot_update_aim( frames )
{
	ent = self.bot.threat.entity;
	prediction = self predictposition( ent, frames );
	if ( bot_using_launcher() && !threat_requires_rocket( ent ) )
	{
		return prediction - ( 0, 0, randomintrange( 0, 10 ) );
	}
	if ( !threat_is_player() )
	{
		height = ent getcentroid()[ 2 ] - prediction[ 2 ];
		return prediction + ( 0, 0, height );
	}
	height = ent getplayerviewheight();
	if ( threat_using_riotshield() )
	{
		dot = ent bot_dot_product( self.origin );
		if ( dot > 0,8 && ent getstance() == "stand" )
		{
			return prediction + vectorScale( ( 0, 0, 1 ), 5 );
		}
	}
	torso = prediction + ( 0, 0, height / 1,6 );
	return torso;
}

bot_update_cover()
{
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return;
	}
	if ( bot_has_melee_weapon() )
	{
		self cancelgoal( "cover" );
		self cancelgoal( "flee" );
		return;
	}
	if ( threat_using_riotshield() )
	{
		self cancelgoal( "enemy_patrol" );
		self cancelgoal( "flee" );
		return;
	}
	enemy = self.bot.threat.entity;
	if ( threat_is_turret() && !bot_has_sniper() && !bot_has_melee_weapon() )
	{
		goal = enemy turret_get_attack_node();
		if ( isDefined( goal ) )
		{
			self cancelgoal( "enemy_patrol" );
			self addgoal( goal, 24, 3, "cover" );
		}
	}
	if ( !isplayer( enemy ) )
	{
		return;
	}
	dot = enemy bot_dot_product( self.origin );
	if ( dot < 0,8 && !bot_has_shotgun() )
	{
		self cancelgoal( "cover" );
		self cancelgoal( "flee" );
		return;
	}
	ammo_frac = bot_weapon_ammo_frac();
	health_frac = bot_health_frac();
	cover_score = dot - ammo_frac - health_frac;
	if ( bot_should_hip_fire() && !bot_has_shotgun() )
	{
		cover_score += 1;
	}
	if ( cover_score > 0,25 )
	{
		nodes = getnodesinradiussorted( self.origin, 1024, 256, 512, "Path", 8 );
		nearest = bot_nearest_node( enemy.origin );
		while ( isDefined( nearest ) && !self hasgoal( "flee" ) )
		{
			_a1018 = nodes;
			_k1018 = getFirstArrayKey( _a1018 );
			while ( isDefined( _k1018 ) )
			{
				node = _a1018[ _k1018 ];
				if ( !nodesvisible( nearest, node ) && !nodescanpath( nearest, node ) )
				{
					self cancelgoal( "cover" );
					self cancelgoal( "enemy_patrol" );
					self addgoal( node, 24, 4, "flee" );
					return;
				}
				_k1018 = getNextArrayKey( _a1018, _k1018 );
			}
		}
	}
	else if ( cover_score > -0,25 )
	{
		if ( self hasgoal( "cover" ) )
		{
			return;
		}
		nodes = getnodesinradiussorted( self.origin, 512, 0, 256, "Cover" );
		if ( !nodes.size )
		{
			nodes = getnodesinradiussorted( self.origin, 256, 0, 256, "Path", 8 );
		}
		nearest = bot_nearest_node( enemy.origin );
		while ( isDefined( nearest ) )
		{
			_a1048 = nodes;
			_k1048 = getFirstArrayKey( _a1048 );
			while ( isDefined( _k1048 ) )
			{
				node = _a1048[ _k1048 ];
				if ( !canclaimnode( node, self.team ) )
				{
				}
				else if ( node.type != "Path" && !within_fov( node.origin, node.angles, enemy.origin, bot_get_fov() ) )
				{
				}
				else
				{
					if ( !nodescanpath( nearest, node ) && nodesvisible( nearest, node ) )
					{
						if ( node.type == "Cover Left" )
						{
							right = anglesToRight( node.angles );
							dir = vectorScale( right, 16 );
							node = node.origin - dir;
						}
						else
						{
							if ( node.type == "Cover Right" )
							{
								right = anglesToRight( node.angles );
								dir = vectorScale( right, 16 );
								node = node.origin + dir;
							}
						}
						self cancelgoal( "flee" );
						self cancelgoal( "enemy_patrol" );
						self addgoal( node, 8, 4, "cover" );
						return;
					}
				}
				_k1048 = getNextArrayKey( _a1048, _k1048 );
			}
		}
	}
	else if ( bot_has_shotgun() )
	{
		self addgoal( enemy.origin, 24, 4, "cover" );
	}
}

bot_update_attack( enemy, dot_from, dot_to, sight, aim_target )
{
	self allowattack( 0 );
	self pressads( 0 );
	if ( sight == 0 )
	{
		return;
	}
	weapon = self getcurrentweapon();
	if ( weapon == "none" )
	{
		return;
	}
	radius = 50;
	if ( dot_to > 0,9 )
	{
		self pressads( 1 );
	}
	ads = 1;
	if ( bot_should_hip_fire() )
	{
		self pressads( 0 );
		ads = 0;
		radius = 15;
	}
	if ( isweaponscopeoverlay( weapon ) && ads )
	{
		if ( self playerads() < 1 )
		{
			self.bot.time_ads = getTime();
		}
		if ( getTime() < ( self.bot.time_ads + 1000 ) )
		{
			return;
		}
	}
	if ( !ads || self playerads() >= 1 )
	{
		self allowattack( 1 );
	}
}

bot_weapon_ammo_frac()
{
	if ( self isreloading() || self isswitchingweapons() )
	{
		return 0;
	}
	weapon = self getcurrentweapon();
	if ( weapon == "none" )
	{
		return 1;
	}
	total = weaponclipsize( weapon );
	if ( total <= 0 )
	{
		return 1;
	}
	current = self getweaponammoclip( weapon );
	return current / total;
}

bot_select_weapon()
{
	if ( !self isthrowinggrenade() || self isswitchingweapons() && self isreloading() )
	{
		return;
	}
	if ( !self isonground() )
	{
		return;
	}
	ent = self.bot.threat.entity;
	if ( !isDefined( ent ) )
	{
		return;
	}
	primaries = self getweaponslistprimaries();
	weapon = self getcurrentweapon();
	stock = self getweaponammostock( weapon );
	clip = self getweaponammoclip( weapon );
	if ( weapon == "none" )
	{
		return;
	}
	if ( threat_requires_rocket( ent ) || threat_is_qrdrone() )
	{
		if ( !bot_using_launcher() )
		{
			_a1202 = primaries;
			_k1202 = getFirstArrayKey( _a1202 );
			while ( isDefined( _k1202 ) )
			{
				primary = _a1202[ _k1202 ];
				if ( !self getweaponammoclip( primary ) && !self getweaponammostock( primary ) )
				{
				}
				else
				{
					if ( primary == "smaw_mp" || primary == "fhj18_mp" )
					{
						self switchtoweapon( primary );
						return;
					}
				}
				_k1202 = getNextArrayKey( _a1202, _k1202 );
			}
		}
		else if ( !clip && !stock && !threat_is_qrdrone() )
		{
			threat_ignore( ent, 5 );
		}
		return;
	}
	else
	{
		if ( weapon == "fhj18_mp" && !target_istarget( ent ) )
		{
			_a1225 = primaries;
			_k1225 = getFirstArrayKey( _a1225 );
			while ( isDefined( _k1225 ) )
			{
				primary = _a1225[ _k1225 ];
				if ( primary != weapon )
				{
					self switchtoweapon( primary );
					return;
				}
				_k1225 = getNextArrayKey( _a1225, _k1225 );
			}
			return;
		}
	}
	while ( !clip )
	{
		if ( stock )
		{
			if ( weaponhasattachment( weapon, "fastreload" ) )
			{
				return;
			}
		}
		_a1247 = primaries;
		_k1247 = getFirstArrayKey( _a1247 );
		while ( isDefined( _k1247 ) )
		{
			primary = _a1247[ _k1247 ];
			if ( primary == weapon || primary == "fhj18_mp" )
			{
			}
			else
			{
				if ( self getweaponammoclip( primary ) )
				{
					self switchtoweapon( primary );
					return;
				}
			}
			_k1247 = getNextArrayKey( _a1247, _k1247 );
		}
		while ( bot_using_launcher() || bot_has_lmg() )
		{
			_a1263 = primaries;
			_k1263 = getFirstArrayKey( _a1263 );
			while ( isDefined( _k1263 ) )
			{
				primary = _a1263[ _k1263 ];
				if ( primary == weapon || primary == "fhj18_mp" )
				{
				}
				else
				{
					self switchtoweapon( primary );
					return;
				}
				_k1263 = getNextArrayKey( _a1263, _k1263 );
			}
		}
	}
}

bot_has_shotgun()
{
	weapon = self getcurrentweapon();
	if ( weapon == "none" )
	{
		return 0;
	}
	if ( weaponisdualwield( weapon ) )
	{
		return 1;
	}
	if ( !bot_has_weapon_class( "spread" ) )
	{
		return bot_has_weapon_class( "pistol spread" );
	}
}

bot_has_crossbow()
{
	weapon = self getcurrentweapon();
	return weapon == "crossbow_mp";
}

bot_has_launcher()
{
	if ( self getweaponammoclip( "smaw_mp" ) > 0 || self getweaponammostock( "smaw_mp" ) > 0 )
	{
		return 1;
	}
	if ( self getweaponammoclip( "fhj18_mp" ) > 0 || self getweaponammostock( "fhj18_mp" ) > 0 )
	{
		return 1;
	}
	return 0;
}

bot_has_melee_weapon()
{
	weapon = self getcurrentweapon();
	if ( weapon == "fhj18_mp" )
	{
		if ( isDefined( self.bot.threat.entity ) && !target_istarget( self.bot.threat.entity ) )
		{
			return 1;
		}
	}
	if ( weapon != "riotshield_mp" )
	{
		return weapon == "knife_held_mp";
	}
}

bot_has_pistol()
{
	if ( !bot_has_weapon_class( "pistol" ) )
	{
		return bot_has_weapon_class( "pistol spread" );
	}
}

bot_has_lmg()
{
	return bot_has_weapon_class( "mg" );
}

bot_has_sniper()
{
	return bot_has_weapon_class( "sniper" );
}

bot_using_launcher()
{
	weapon = self getcurrentweapon();
	if ( weapon != "smaw_mp" && weapon != "fhj18_mp" )
	{
		return weapon == "usrpg_mp";
	}
}

bot_has_minigun()
{
	weapon = self getcurrentweapon();
	if ( weapon != "minigun_mp" )
	{
		return weapon == "inventory_minigun_mp";
	}
}

bot_has_weapon_class( class )
{
	if ( self isreloading() )
	{
		return 0;
	}
	weapon = self getcurrentweapon();
	if ( weapon == "none" )
	{
		return 0;
	}
	return weaponclass( weapon ) == class;
}

bot_health_frac()
{
	return self.health / self.maxhealth;
}

bot_should_hip_fire()
{
	enemy = self.bot.threat.entity;
	weapon = self getcurrentweapon();
	if ( weapon == "none" )
	{
		return 0;
	}
	if ( weaponisdualwield( weapon ) )
	{
		return 1;
	}
	class = weaponclass( weapon );
	if ( isplayer( enemy ) && class == "spread" )
	{
		return 1;
	}
	distsq = distancesquared( self.origin, enemy.origin );
	distcheck = 0;
	switch( class )
	{
		case "mg":
			distcheck = 250;
			break;
		case "smg":
			distcheck = 350;
			break;
		case "spread":
			distcheck = 400;
			break;
		case "pistol":
			distcheck = 200;
			break;
		case "rocketlauncher":
			distcheck = 0;
			break;
		case "rifle":
		default:
			distcheck = 300;
			break;
	}
	if ( isweaponscopeoverlay( weapon ) )
	{
		distcheck = 500;
	}
	return distsq < ( distcheck * distcheck );
}

bot_patrol_near_enemy( damage, attacker, direction )
{
	if ( threat_is_warthog( attacker ) )
	{
		return;
	}
	if ( threat_requires_rocket( attacker ) && !self bot_has_launcher() )
	{
		return;
	}
	if ( isDefined( attacker ) )
	{
		self bot_lookat_entity( attacker );
	}
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return;
	}
	if ( !isDefined( attacker ) )
	{
		attacker = self maps/mp/bots/_bot::bot_get_closest_enemy( self.origin, 1 );
	}
	if ( !isDefined( attacker ) )
	{
		return;
	}
	if ( attacker.classname == "auto_turret" )
	{
		self bot_turret_set_dangerous( attacker );
	}
	node = bot_nearest_node( attacker.origin );
	if ( !isDefined( node ) )
	{
		nodes = getnodesinradiussorted( attacker.origin, 1024, 0, 512, "Path", 8 );
		if ( nodes.size )
		{
			node = nodes[ 0 ];
		}
	}
	if ( isDefined( node ) )
	{
		if ( isDefined( damage ) )
		{
			self addgoal( node, 24, 4, "enemy_patrol" );
			return;
		}
		else
		{
			self addgoal( node, 24, 2, "enemy_patrol" );
		}
	}
}

bot_nearest_node( origin )
{
	node = getnearestnode( origin );
	if ( isDefined( node ) )
	{
		return node;
	}
	nodes = getnodesinradiussorted( origin, 256, 0, 256 );
	if ( nodes.size )
	{
		return nodes[ 0 ];
	}
	return undefined;
}

bot_lookat_entity( entity )
{
	if ( isplayer( entity ) && entity getstance() != "prone" )
	{
		if ( distancesquared( self.origin, entity.origin ) < 65536 )
		{
			origin = entity getcentroid() + vectorScale( ( 0, 0, 1 ), 10 );
			self lookat( origin );
			return;
		}
	}
	offset = target_getoffset( entity );
	if ( isDefined( offset ) )
	{
		self lookat( entity.origin + offset );
	}
	else
	{
		self lookat( entity getcentroid() );
	}
}

bot_combat_throw_lethal( origin )
{
	weapons = self getweaponslist();
	radius = 256;
	if ( self hasperk( "specialty_flakjacket" ) )
	{
		radius *= 0,25;
	}
	if ( distancesquared( self.origin, origin ) < ( radius * radius ) )
	{
		return 0;
	}
	_a1562 = weapons;
	_k1562 = getFirstArrayKey( _a1562 );
	while ( isDefined( _k1562 ) )
	{
		weapon = _a1562[ _k1562 ];
		if ( self getweaponammostock( weapon ) <= 0 )
		{
		}
		else
		{
			if ( weapon == "frag_grenade_mp" || weapon == "sticky_grenade_mp" )
			{
				if ( self throwgrenade( weapon, origin ) )
				{
					return 1;
				}
			}
		}
		_k1562 = getNextArrayKey( _a1562, _k1562 );
	}
	return 0;
}

bot_combat_throw_tactical( origin )
{
	weapons = self getweaponslist();
	if ( !self hasperk( "specialty_flashprotection" ) )
	{
		if ( distancesquared( self.origin, origin ) < 422500 )
		{
			return 0;
		}
	}
	_a1593 = weapons;
	_k1593 = getFirstArrayKey( _a1593 );
	while ( isDefined( _k1593 ) )
	{
		weapon = _a1593[ _k1593 ];
		if ( self getweaponammostock( weapon ) <= 0 )
		{
		}
		else
		{
			if ( weapon == "flash_grenade_mp" || weapon == "concussion_grenade_mp" )
			{
				if ( self throwgrenade( weapon, origin ) )
				{
					return 1;
				}
			}
		}
		_k1593 = getNextArrayKey( _a1593, _k1593 );
	}
	return 0;
}

bot_combat_throw_smoke( origin )
{
	if ( self getweaponammostock( "willy_pete_mp" ) <= 0 )
	{
		return 0;
	}
	time = getTime();
	_a1621 = level.players;
	_k1621 = getFirstArrayKey( _a1621 );
	while ( isDefined( _k1621 ) )
	{
		player = _a1621[ _k1621 ];
		if ( !isDefined( player.smokegrenadetime ) )
		{
		}
		else if ( ( time - player.smokegrenadetime ) > 12000 )
		{
		}
		else
		{
			if ( distancesquared( origin, player.smokegrenadeposition ) < 65536 )
			{
				return 0;
			}
		}
		_k1621 = getNextArrayKey( _a1621, _k1621 );
	}
	return self throwgrenade( "willy_pete_mp", origin );
}

bot_combat_throw_emp( origin )
{
	if ( self getweaponammostock( "emp_mp" ) <= 0 )
	{
		return 0;
	}
	return self throwgrenade( "emp_mp", origin );
}

bot_combat_throw_proximity( origin )
{
	_a1654 = level.missileentities;
	_k1654 = getFirstArrayKey( _a1654 );
	while ( isDefined( _k1654 ) )
	{
		missile = _a1654[ _k1654 ];
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 65536 )
		{
			return 0;
		}
		_k1654 = getNextArrayKey( _a1654, _k1654 );
	}
	return self throwgrenade( "proximity_grenade_mp", origin );
}

bot_combat_tactical_insertion( origin )
{
	_a1667 = level.missileentities;
	_k1667 = getFirstArrayKey( _a1667 );
	while ( isDefined( _k1667 ) )
	{
		missile = _a1667[ _k1667 ];
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 65536 )
		{
			return 0;
		}
		_k1667 = getNextArrayKey( _a1667, _k1667 );
	}
	return self throwgrenade( "tactical_insertion_mp", origin );
}

bot_combat_toss_flash( origin )
{
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return 0;
	}
	if ( self getweaponammostock( "sensor_grenade_mp" ) <= 0 && self getweaponammostock( "proximity_grenade_mp" ) <= 0 && self getweaponammostock( "trophy_system_mp" ) <= 0 )
	{
		return 0;
	}
	_a1690 = level.missileentities;
	_k1690 = getFirstArrayKey( _a1690 );
	while ( isDefined( _k1690 ) )
	{
		missile = _a1690[ _k1690 ];
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 65536 )
		{
			return 0;
		}
		_k1690 = getNextArrayKey( _a1690, _k1690 );
	}
	self pressattackbutton( 2 );
	return 1;
}

bot_combat_toss_frag( origin )
{
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return 0;
	}
	if ( self getweaponammostock( "bouncingbetty_mp" ) <= 0 && self getweaponammostock( "claymore_mp" ) <= 0 && self getweaponammostock( "satchel_charge_mp" ) <= 0 )
	{
		return 0;
	}
	_a1714 = level.missileentities;
	_k1714 = getFirstArrayKey( _a1714 );
	while ( isDefined( _k1714 ) )
	{
		missile = _a1714[ _k1714 ];
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 16384 )
		{
			return 0;
		}
		_k1714 = getNextArrayKey( _a1714, _k1714 );
	}
	self pressattackbutton( 1 );
	return 1;
}

bot_shotgun_think()
{
	if ( self isthrowinggrenade() || self isswitchingweapons() )
	{
		return;
	}
	enemy = self.bot.threat.entity;
	weapon = self getcurrentweapon();
	self allowattack( 0 );
	distsq = distancesquared( enemy.origin, self.origin );
	if ( threat_is_turret() )
	{
		goal = enemy turret_get_attack_node();
		if ( isDefined( goal ) )
		{
			self cancelgoal( "enemy_patrol" );
			self addgoal( goal, 24, 4, "cover" );
		}
		if ( weapon != "none" && !weaponisdualwield( weapon ) && distsq < 65536 )
		{
			self pressads( 1 );
		}
	}
	else
	{
		if ( self getweaponammoclip( weapon ) && distsq < 90000 )
		{
			self cancelgoal( "enemy_patrol" );
			self addgoal( self.origin, 24, 4, "cover" );
		}
	}
	dot = self bot_dot_product( self.bot.threat.aim_target );
	if ( distsq < 250000 && dot > 0,98 )
	{
		self allowattack( 1 );
		return;
	}
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return;
	}
	if ( self threat_is_player() )
	{
		dot = enemy bot_dot_product( self.origin );
		if ( dot < 0,9 )
		{
			return;
		}
	}
	else
	{
		return;
	}
	primaries = self getweaponslistprimaries();
	weapon = self getcurrentweapon();
	_a1793 = primaries;
	_k1793 = getFirstArrayKey( _a1793 );
	while ( isDefined( _k1793 ) )
	{
		primary = _a1793[ _k1793 ];
		if ( primary == weapon )
		{
		}
		else if ( !self getweaponammoclip( primary ) )
		{
		}
		else if ( maps/mp/gametypes/_weapon_utils::isguidedrocketlauncherweapon( primary ) )
		{
		}
		else class = weaponclass( primary );
		if ( class != "spread" && class != "pistol spread" || class == "melee" && class == "item" )
		{
		}
		else
		{
			if ( self switchtoweapon( primary ) )
			{
				return;
			}
		}
		_k1793 = getNextArrayKey( _a1793, _k1793 );
	}
	if ( self getweaponammostock( "willy_pete_mp" ) > 0 )
	{
		self pressattackbutton( 2 );
		return;
	}
}

bot_turret_set_dangerous( turret )
{
	if ( !level.teambased )
	{
		return;
	}
	if ( isDefined( turret.dead ) || turret.dead && isDefined( turret.carried ) && turret.carried )
	{
		return;
	}
	if ( isDefined( turret.turret_active ) && !turret.turret_active )
	{
		return;
	}
	if ( turret.dangerous_nodes.size )
	{
		return;
	}
	nearest = bot_turret_nearest_node( turret );
	if ( !isDefined( nearest ) )
	{
		return;
	}
	forward = anglesToForward( turret.angles );
	if ( turret.turrettype == "sentry" )
	{
		nodes = getvisiblenodes( nearest );
		_a1868 = nodes;
		_k1868 = getFirstArrayKey( _a1868 );
		while ( isDefined( _k1868 ) )
		{
			node = _a1868[ _k1868 ];
			dir = vectornormalize( node.origin - turret.origin );
			dot = vectordot( forward, dir );
			if ( dot >= 0,5 )
			{
				turret turret_mark_node_dangerous( node );
			}
			_k1868 = getNextArrayKey( _a1868, _k1868 );
		}
	}
	else while ( turret.turrettype == "microwave" )
	{
		nodes = getnodesinradius( turret.origin, level.microwave_radius, 0 );
		_a1883 = nodes;
		_k1883 = getFirstArrayKey( _a1883 );
		while ( isDefined( _k1883 ) )
		{
			node = _a1883[ _k1883 ];
			if ( !nodesvisible( nearest, node ) )
			{
			}
			else
			{
				dir = vectornormalize( node.origin - turret.origin );
				dot = vectordot( forward, dir );
				if ( dot >= level.microwave_turret_cone_dot )
				{
					turret turret_mark_node_dangerous( node );
				}
			}
			_k1883 = getNextArrayKey( _a1883, _k1883 );
		}
	}
}

bot_turret_nearest_node( turret )
{
	nodes = getnodesinradiussorted( turret.origin, 256, 0 );
	forward = anglesToForward( turret.angles );
	_a1906 = nodes;
	_k1906 = getFirstArrayKey( _a1906 );
	while ( isDefined( _k1906 ) )
	{
		node = _a1906[ _k1906 ];
		dir = vectornormalize( node.origin - turret.origin );
		dot = vectordot( forward, dir );
		if ( dot > 0,5 )
		{
			return node;
		}
		_k1906 = getNextArrayKey( _a1906, _k1906 );
	}
	if ( nodes.size )
	{
		return nodes[ 0 ];
	}
	return undefined;
}

turret_mark_node_dangerous( node )
{
	_a1927 = level.teams;
	_k1927 = getFirstArrayKey( _a1927 );
	while ( isDefined( _k1927 ) )
	{
		team = _a1927[ _k1927 ];
		if ( team == self.owner.team )
		{
		}
		else
		{
			node setdangerous( team, 1 );
		}
		_k1927 = getNextArrayKey( _a1927, _k1927 );
	}
	self.dangerous_nodes[ self.dangerous_nodes.size ] = node;
}

turret_get_attack_node()
{
	nearest = bot_nearest_node( self.origin );
	if ( !isDefined( nearest ) )
	{
		return undefined;
	}
	nodes = getnodesinradiussorted( self.origin, 512, 64 );
	forward = anglesToForward( self.angles );
	_a1952 = nodes;
	_k1952 = getFirstArrayKey( _a1952 );
	while ( isDefined( _k1952 ) )
	{
		node = _a1952[ _k1952 ];
		if ( !nodesvisible( node, nearest ) )
		{
		}
		else
		{
			dir = vectornormalize( node.origin - self.origin );
			dot = vectordot( forward, dir );
			if ( dot < 0,5 )
			{
				return node;
			}
		}
		_k1952 = getNextArrayKey( _a1952, _k1952 );
	}
	return undefined;
}

bot_riotshield_think( enemy )
{
	dot = enemy bot_dot_product( self.origin );
	if ( !bot_has_crossbow() && !bot_using_launcher() && enemy getstance() != "stand" )
	{
		if ( dot > 0,8 )
		{
			self allowattack( 0 );
		}
	}
	forward = anglesToForward( enemy.angles );
	origin = enemy.origin + ( forward * randomintrange( 256, 512 ) );
	if ( self bot_combat_throw_lethal( origin ) )
	{
		return;
	}
	if ( self bot_combat_throw_tactical( origin ) )
	{
		return;
	}
	if ( self throwgrenade( "proximity_grenade_mp", origin ) )
	{
		return;
	}
	if ( self atgoal( "cover" ) )
	{
		self.bot.threat.update_riotshield = 0;
	}
	if ( getTime() > self.bot.threat.update_riotshield )
	{
		self thread bot_riotshield_dangerous_think( enemy );
		self.bot.threat.update_riotshield = getTime() + randomintrange( 5000, 7500 );
	}
}

bot_riotshield_dangerous_think( enemy, goal )
{
	nearest = bot_nearest_node( enemy.origin );
	if ( !isDefined( nearest ) )
	{
		threat_ignore( enemy, 10 );
		return;
	}
	nodes = getnodesinradius( enemy.origin, 768, 0 );
	if ( !nodes.size )
	{
		threat_ignore( enemy, 10 );
		return;
	}
	nodes = array_randomize( nodes );
	forward = anglesToForward( enemy.angles );
	_a2037 = nodes;
	_k2037 = getFirstArrayKey( _a2037 );
	while ( isDefined( _k2037 ) )
	{
		node = _a2037[ _k2037 ];
		if ( !nodesvisible( node, nearest ) )
		{
		}
		else
		{
			dir = vectornormalize( node.origin - enemy.origin );
			dot = vectordot( forward, dir );
			if ( dot < 0 )
			{
				if ( distancesquared( self.origin, enemy.origin ) < 262144 )
				{
					self addgoal( node, 24, 4, "cover" );
				}
				else
				{
					self addgoal( node, 24, 3, "cover" );
				}
				break;
			}
		}
		else
		{
			_k2037 = getNextArrayKey( _a2037, _k2037 );
		}
	}
	if ( !level.teambased )
	{
		return;
	}
	nodes = getnodesinradius( enemy.origin, 512, 0 );
	_a2069 = nodes;
	_k2069 = getFirstArrayKey( _a2069 );
	while ( isDefined( _k2069 ) )
	{
		node = _a2069[ _k2069 ];
		dir = vectornormalize( node.origin - enemy.origin );
		dot = vectordot( forward, dir );
		if ( dot >= 0,5 )
		{
			node setdangerous( self.team, 1 );
		}
		_k2069 = getNextArrayKey( _a2069, _k2069 );
	}
	enemy wait_endon( 5, "death" );
	_a2082 = nodes;
	_k2082 = getFirstArrayKey( _a2082 );
	while ( isDefined( _k2082 ) )
	{
		node = _a2082[ _k2082 ];
		node setdangerous( self.team, 0 );
		_k2082 = getNextArrayKey( _a2082, _k2082 );
	}
}
