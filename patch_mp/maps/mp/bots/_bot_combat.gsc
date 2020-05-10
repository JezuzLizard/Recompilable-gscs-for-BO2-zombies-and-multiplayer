#include maps/mp/gametypes/_weapon_utils;
#include maps/mp/bots/_bot;
#include maps/mp/_utility;
#include common_scripts/utility;

bot_combat_think( damage, attacker, direction ) //checked partially changed to match cerberus output changed at own discretion
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
		/*
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
		*/
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
					wait 0.05;
					continue;
				}
				else 
				{
					self addgoal( self.origin, 24, 3, "enemy_patrol" );
					if ( difficulty != "easy" && cointoss() )
					{
						self bot_combat_throw_lethal( pos );
						self bot_combat_throw_tactical( pos );
					}
					bot_combat_dead();
					self addgoal( pos, 24, 4, "enemy_patrol" );
				}
			}
			bot_combat_idle( damage, attacker, direction );
			return;
		}
		else if ( threat_dead() )
		{
			bot_combat_dead();
			return;
		}
		bot_update_cover();
		bot_combat_main();
		if ( threat_is_turret() )
		{
			bot_turret_set_dangerous( ent );
			bot_combat_throw_smoke( ent.origin );
		}
		if ( !threat_is_turret() || threat_is_ai_tank() || threat_is_equipment() )
		{
			bot_combat_throw_emp( ent.origin );
			bot_combat_throw_lethal( ent.origin );
		}
		else if ( threat_is_qrdrone() )
		{
			bot_combat_throw_emp( ent.origin );
			break;
		}
		else if ( threat_requires_rocket( ent ) )
		{
			self cancelgoal( "enemy_patrol" );
			self addgoal( self.origin, 24, 4, "cover" );
		}
		if ( difficulty == "easy" )
		{
			wait 0.5;
			continue;
		}
		if ( difficulty == "normal" )
		{
			wait 0.25;
			continue;
		}
		if ( difficulty == "hard" )
		{
			wait 0.1;
			continue;
		}
		wait 0.05; //fu difficulty
	}
}

bot_can_do_combat() //checked matches cerberus output
{
	if ( self ismantling() || self isonladder() )
	{
		return 0;
	}
	return 1;
}

threat_dead() //checked changed at own discretion
{
	if ( bot_has_enemy() )
	{
		ent = self.bot.threat.entity;
		if ( threat_is_turret() && isDefined( ent.dead ) && ent.dead )
		{
			return 1;
		}
		if ( threat_is_qrdrone() && isDefined( ent.crash_accel ) && ent.crash_accel )
		{
			return 1;
		}
		if ( !isalive( ent ) )
		{
			return 1;
		}
		return 0;
	}
	return 0;
}

bot_can_reload() //checked changed to match cerberus output
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
	if ( self isreloading() || self isswitchingweapons() || self isthrowinggrenade() )
	{
		return 0;
	}
	return 1;
}

bot_combat_idle( damage, attacker, direction ) //checked matches cerberus output
{
	self pressads( 0 );
	self allowattack( 0 );
	self allowsprint( 1 );
	bot_clear_enemy();
	weapon = self getcurrentweapon();
	if ( bot_can_reload() )
	{
		frac = 0.5;
		if ( bot_has_lmg() )
		{
			frac = 0.25;
		}
		frac += randomfloatrange( -0.1, 0.1 );
		if ( bot_weapon_ammo_frac() < frac )
		{
			self pressusebutton( 0.1 );
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

bot_combat_dead( damage ) //checked matches cerberus output
{
	difficulty = maps/mp/bots/_bot::bot_get_difficulty();
	switch( difficulty )
	{
		case "easy":
			wait 0.75;
			break;
		case "normal":
			wait 0.5;
			break;
		case "hard":
			wait 0.25;
			break;
		case "fu":
			wait 0.1;
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
			wait_endon( 0.5, "damage" );
			break;
		case "fu":
			wait_endon( 0.25, "damage" );
			break;
	}
	bot_clear_enemy();
}

bot_combat_main() //checked partially changed to match cerberus output changed at own discretion
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
	if ( !bot_should_hip_fire() && self.bot.threat.dot > 0.96 )
	{
		ads = 1;
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
	else if ( bot_on_target( self.bot.threat.aim_target, 45 ) )
	{
		self allowattack( 1 );
	}
	else
	{
		self allowattack( 0 );
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
	else if ( bot_has_shotgun() )
	{
		self bot_shotgun_think();
	}
}

bot_combat_melee( weapon ) //checked partially changed to match cerberus output
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
				wait 0.1;
			}
			else
			{
				self pressmelee();
				wait 0.1;
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
		wait 0.05;
	}
}

bot_get_fov() //checked matches cerberus output
{
	weapon = self getcurrentweapon();
	reduction = 1;
	if ( weapon != "none" && isweaponscopeoverlay( weapon ) && self playerads() >= 1 )
	{
		reduction = 0.25;
	}
	return self.bot.fov * reduction;
}

bot_get_converge_time() //checked changed at own discretion
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
		default:
			return 2000;
	}
}

bot_get_converge_rate() //checked changed at own discretion
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
		default:
			return 4;
	}
}

bot_get_melee_range_sq() //checked changed at own discretion
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
		default:
			return 4900;
	}
}

bot_get_aim_error() //checked changed at own discretion
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
		default:			
			return 20;
	}
}

bot_update_lookat( origin, frac ) //checked matches cerberus output
{
	angles = vectorToAngles( origin - self.origin );
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

bot_on_target( aim_target, radius ) //checked matches cerberus output
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

bot_dot_product( origin ) //checked matches cerberus output
{
	angles = self getplayerangles();
	forward = anglesToForward( angles );
	delta = origin - self getplayercamerapos();
	delta = vectornormalize( delta );
	dot = vectordot( forward, delta );
	return dot;
}

bot_has_enemy() //checked changed at own discretion
{
	if ( isDefined( self.bot.threat.entity ) )
	{
		return 1;
	}
	return 0;
}

threat_is_player() //checked changed at own discretion
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) && isplayer( ent ) )
	{
		return 1;
	}
	return 0;
}

threat_is_dog() //checked changed at own discretion
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) && isai( ent ) )
	{
		return 1;
	}
	return 0;
}

threat_is_turret() //checked changed at own discretion
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) && ent.classname == "auto_turret" )
	{
		return 1;
	}
	return 0;
}

threat_is_ai_tank() //checked changed at own discretion
{
	ent = self.bot.threat.entity;
	if ( isDefined( ent ) && isDefined( ent.targetname ) && ent.targetname == "talon" )
	{
		return 1;
	}
	return 0;
}

threat_is_qrdrone( ent ) //checked changed at own discretion
{
	if ( !isDefined( ent ) )
	{
		ent = self.bot.threat.entity;
	}
	if ( isDefined( ent ) && isDefined( ent.helitype ) && ent.helitype == "qrdrone" )
	{
		return 1;
	}
	return 0;
}

threat_using_riotshield() //checked changed at own discretion
{
	if ( threat_is_player() )
	{
		weapon = self.bot.threat.entity getcurrentweapon();
		if ( weapon == "riotshield_mp" )
		{
			return ;
		}
	}
	return 0;
}

threat_is_equipment() //checked changed at own discretion
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
	if ( isDefined( ent.name ) && isweaponequipment( ent.name ) )
	{
		return 1;
	}
	return 0;
}

bot_clear_enemy() //checked matches cerberus output
{
	self clearlookat();
	self.bot.threat.entity = undefined;
}

bot_best_enemy() //checked partially changed to match cerberus output did not change while loop to foreach see github for more info
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
	i = 0;
	while ( i < enemies.size )
	{
		if ( threat_should_ignore( enemies[ i ] ) )
		{
			i++;
			continue;
		}
		if ( !isplayer( enemies[ i ] ) && enemies[ i ].classname != "grenade" )
		{
			if ( level.gametype == "hack" )
			{
				if ( enemies[ i ].classname == "script_vehicle" )
				{
					i++;
					continue;
				}
			}
			if ( enemies[ i ].classname == "auto_turret" )
			{
				if ( isDefined( enemies[ i ].dead ) && enemies[ i ].dead || isDefined( enemies[ i ].carried ) && enemies[ i ].carried )
				{	
					i++;
					continue;
				}
				if ( isDefined( enemies[ i ].turret_active ) && !enemies[ i ].turret_active )
				{
					i++;
					continue;
				}
			}
			if ( threat_requires_rocket( enemies[ i ] ) )
			{
				if ( !bot_has_launcher() )
				{
					i++;
					continue;
				}
				origin = self getplayercamerapos();
				angles = vectorToAngle( enemies[ i ].origin - origin );
				if ( angles[ 0 ] < 290 )
				{
					threat_ignore( enemies[ i ], 3.5 );
					i++;
					continue;
				}
			}
		}
		if ( self botsighttracepassed( enemies[ i ] ) )
		{
			self.bot.threat.entity = enemies[ i ];
			self.bot.threat.time_first_sight = getTime();
			self.bot.threat.time_recent_sight = getTime();
			self.bot.threat.dot = bot_dot_product( enemies[ i ].origin );
			self.bot.threat.position = enemies[ i ].origin;
			return 1;
		}
		i++;
	}
	return 0;
}

threat_requires_rocket( enemy ) //checked changed to match cerberus output
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
		else if ( enemy.targetname == "uav" || enemy.targetname == "counteruav" )
		{
			return 1;
		}
	}
	if ( enemy.classname == "script_vehicle" && enemy.vehicleclass == "helicopter" )
	{
		return 1;
	}
	return 0;
}

threat_is_warthog( enemy ) //checked matches cerberus output
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

threat_should_ignore( entity ) //checked matches cerberus output
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

threat_ignore( entity, secs ) //checked matches cerberus output
{
	self.bot.ignore_entity[ entity getentitynumber() ] = getTime() + secs * 1000;
}

bot_update_aim( frames ) //checked matches cerberus output
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
		if ( dot > 0.8 && ent getstance() == "stand" )
		{
			return prediction + vectorScale( ( 0, 0, 1 ), 5 );
		}
	}
	torso = prediction + ( 0, 0, height / 1.6 );
	return torso;
}

bot_update_cover() //checked partially changed to match cerberus output did not change while loop to foreach see the github for more info
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
	if ( dot < 0.8 && !bot_has_shotgun() )
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
	if ( cover_score > 0.25 )
	{
		nodes = getnodesinradiussorted( self.origin, 1024, 256, 512, "Path", 8 );
		nearest = bot_nearest_node( enemy.origin );
		if ( isDefined( nearest ) && !self hasgoal( "flee" ) )
		{
			foreach ( node in nodes )
			{
				if ( !nodesvisible( nearest, node ) && !nodescanpath( nearest, node ) )
				{
					self cancelgoal( "cover" );
					self cancelgoal( "enemy_patrol" );
					self addgoal( node, 24, 4, "flee" );
					return;
				}
			}
		}
	}
	else if ( cover_score > -0.25 )
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
		if ( isDefined( nearest ) )
		{
			i = 0;
			while ( i < nodes.size )
			{
				if ( !canclaimnode( nodes[ i ], self.team ) )
				{
					i++;
					continue;
				}
				else if ( nodes[ i ].type != "Path" && !within_fov( nodes[ i ].origin, nodes[ i ].angles, enemy.origin, bot_get_fov() ) )
				{
					i++;
					continue;
				}
				else
				{
					if ( !nodescanpath( nearest, nodes[ i ] ) && nodesvisible( nearest, nodes[ i ] ) )
					{
						if ( nodes[ i ].type == "Cover Left" )
						{
							right = anglesToRight( nodes[ i ].angles );
							dir = vectorScale( right, 16 );
							node = nodes[ i ].origin - dir;
						}
						else if ( nodes[ i ].type == "Cover Right" )
						{
							right = anglesToRight( nodes[ i ].angles );
							dir = vectorScale( right, 16 );
							node = nodes[ i ].origin + dir;
						}
						self cancelgoal( "flee" );
						self cancelgoal( "enemy_patrol" );
						self addgoal( nodes[ i ], 8, 4, "cover" );
						return;
					}
				}
				i++;
			}
		}
	}
	else if ( bot_has_shotgun() )
	{
		self addgoal( enemy.origin, 24, 4, "cover" );
	}
}

bot_update_attack( enemy, dot_from, dot_to, sight, aim_target ) //checked matches cerberus output
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
	if ( dot_to > 0.9 )
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

bot_weapon_ammo_frac() //checked matches cerberus output
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

bot_select_weapon() //checked partially changed to match cerberus output did not change while loop to foreach see github for more info
{
	if ( self isthrowinggrenade() || self isswitchingweapons() || self isreloading() )
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
			i = 0;
			while ( i < primaries.size )
			{
				if ( !self getweaponammoclip( primaries[ i ] ) && !self getweaponammostock( primaries[ i ] ) )
				{
					i++;
					continue;
				}
				if ( primaries[ i ] == "smaw_mp" || primaries[ i ] == "fhj18_mp" )
				{
					self switchtoweapon( primaries[ i ] );
					return;
				}
				i++;
			}
		}
		else if ( !clip && !stock && !threat_is_qrdrone() )
		{
			threat_ignore( ent, 5 );
		}
		return;
	}
	else if ( weapon == "fhj18_mp" && !target_istarget( ent ) )
	{
		foreach ( primary in primaries )
		{
			if ( primary != weapon )
			{
				self switchtoweapon( primary );
				return;
			}
		}
		return;
	}
	if ( !clip )
	{
		if ( stock )
		{
			if ( weaponhasattachment( weapon, "fastreload" ) )
			{
				return;
			}
		}
		i = 0;
		while ( i < primaries.size )
		{
			if ( primaries[ i ] == weapon || primaries[ i ] == "fhj18_mp" )
			{
				i++;
				continue;
			}
			if ( self getweaponammoclip( primaries[ i ] ) )
			{
				self switchtoweapon( primaries[ i ] );
				return;
			}
			i++;
		}
		if ( bot_using_launcher() || bot_has_lmg() )
		{
			i = 0;
			while ( i < primaries.size )
			{
				if ( primaries[ i ] == weapon || primaries[ i ] == "fhj18_mp" )
				{
					i++;
					continue;
				}
				else
				{
					self switchtoweapon( primaries[ i ] );
					return;
				}
				i++;
			}
		}
	}
}

bot_has_shotgun() //checked changed at own discretion
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
	if ( bot_has_weapon_class( "spread" ) || bot_has_weapon_class( "pistol spread" ) )
	{
		return 1;
	}
	return 0;
}

bot_has_crossbow() //checked changed at own discretion
{
	weapon = self getcurrentweapon();
	if ( weapon == "crossbow_mp" )
	{
		return 1;
	}
	return 0;
}

bot_has_launcher() //checked matches cerberus output
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

bot_has_melee_weapon() //checked changed at own discretion
{
	weapon = self getcurrentweapon();
	if ( weapon == "fhj18_mp" )
	{
		if ( isDefined( self.bot.threat.entity ) && !target_istarget( self.bot.threat.entity ) )
		{
			return 1;
		}
	}
	if ( weapon == "riotshield_mp" || weapon == "knife_held_mp" )
	{
		return 1;
	}
	return 0;
}

bot_has_pistol() //checked changed at own discretion
{
	if ( bot_has_weapon_class( "pistol" ) || bot_has_weapon_class( "pistol spread" ) )
	{
		return 1;
	}
	return 0;
}

bot_has_lmg() //checked changed at own discretion
{
	if ( bot_has_weapon_class( "mg" ) )
	{
		return 1;
	}
	return 0;
}

bot_has_sniper() //checked changed at own discretion
{
	if ( bot_has_weapon_class( "sniper" ) )
	{
		return 1;
	}
	return 0;
}

bot_using_launcher() //checked changed at own discretion
{
	weapon = self getcurrentweapon();
	if ( weapon == "smaw_mp" || weapon == "fhj18_mp" || weapon == "usrpg_mp" )
	{
		return 1;
	}
	return 0;
}

bot_has_minigun() //checked changed at own discretion
{
	weapon = self getcurrentweapon();
	if ( weapon == "minigun_mp" || weapon == "inventory_minigun_mp" )
	{
		return 1;
	}
	return 0;
}

bot_has_weapon_class( class ) //checked changed at own discretion
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
	if ( weaponclass( weapon ) == class )
	{
		return 1;
	}
	return 0;
}

bot_health_frac() //checked matches cerberus output
{
	return self.health / self.maxhealth;
}

bot_should_hip_fire() //checked matches cerberus output
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

bot_patrol_near_enemy( damage, attacker, direction ) //checked matches cerberus output
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

bot_nearest_node( origin ) //checked matches cerberus output
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

bot_lookat_entity( entity ) //checked matches cerberus output
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

bot_combat_throw_lethal( origin ) //checked partially changed to match cerberus output did not change while loop to foreach see the github for more info
{
	weapons = self getweaponslist();
	radius = 256;
	if ( self hasperk( "specialty_flakjacket" ) )
	{
		radius *= 0.25;
	}
	if ( distancesquared( self.origin, origin ) < radius * radius )
	{
		return 0;
	}
	i = 0;
	while ( i < weapons.size )
	{
		if ( self getweaponammostock( weapons[ i ] ) <= 0 )
		{
			i++;
			continue;
		}
		if ( weapons[ i ] == "frag_grenade_mp" || weapons[ i ] == "sticky_grenade_mp" )
		{
			if ( self throwgrenade( weapons[ i ], origin ) )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

bot_combat_throw_tactical( origin ) //checked partially changed to match cerberus output did not change while loop to foreach see the github for more info
{
	weapons = self getweaponslist();
	if ( !self hasperk( "specialty_flashprotection" ) )
	{
		if ( distancesquared( self.origin, origin ) < 422500 )
		{
			return 0;
		}
	}
	i = 0;
	while ( i < weapons.size )
	{
		if ( self getweaponammostock( weapons[ i ] ) <= 0 )
		{
			i++;
			continue;
		}
		if ( weapons[ i ] == "flash_grenade_mp" || weapons[ i ] == "concussion_grenade_mp" )
		{
			if ( self throwgrenade( weapons[ i ], origin ) )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

bot_combat_throw_smoke( origin ) //checked partially changed to match cerberus output did not change while loop to foreach see the github for more info
{
	if ( self getweaponammostock( "willy_pete_mp" ) <= 0 )
	{
		return 0;
	}
	time = getTime();
	i = 0;
	players = get_players();
	while ( i < players.size )
	{
		if ( !isDefined( players[ i ].smokegrenadetime ) )
		{
			i++;
			continue;
		}
		if ( ( time - players[ i ].smokegrenadetime ) > 12000 )
		{
			i++;
			continue;
		}
		if ( distancesquared( origin, players[ i ].smokegrenadeposition ) < 65536 )
		{
			return 0;
		}
		i++;
	}
	return self throwgrenade( "willy_pete_mp", origin );
}

bot_combat_throw_emp( origin ) //checked matches cerberus output
{
	if ( self getweaponammostock( "emp_mp" ) <= 0 )
	{
		return 0;
	}
	return self throwgrenade( "emp_mp", origin );
}

bot_combat_throw_proximity( origin ) //checked changed to match cerberus output
{
	foreach ( missile in level.missileentities )
	{
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 65536 )
		{
			return 0;
		}
	}
	return self throwgrenade( "proximity_grenade_mp", origin );
}

bot_combat_tactical_insertion( origin ) //checked changed to match cerberus output
{
	foreach ( missile in level.missileentities )
	{
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 65536 )
		{
			return 0;
		}
	}
	return self throwgrenade( "tactical_insertion_mp", origin );
}

bot_combat_toss_flash( origin ) //checked changed to match cerberus output
{
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return 0;
	}
	if ( self getweaponammostock( "sensor_grenade_mp" ) <= 0 && self getweaponammostock( "proximity_grenade_mp" ) <= 0 && self getweaponammostock( "trophy_system_mp" ) <= 0 )
	{
		return 0;
	}
	foreach ( missile in level.missileentities )
	{
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 65536 )
		{
			return 0;
		}
	}
	self pressattackbutton( 2 );
	return 1;
}

bot_combat_toss_frag( origin ) //checked changed to match cerberus output
{
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		return 0;
	}
	if ( self getweaponammostock( "bouncingbetty_mp" ) <= 0 && self getweaponammostock( "claymore_mp" ) <= 0 && self getweaponammostock( "satchel_charge_mp" ) <= 0 )
	{
		return 0;
	}
	foreach ( missile in level.missileentities )
	{
		if ( isDefined( missile ) && distancesquared( missile.origin, origin ) < 16384 )
		{
			return 0;
		}
	}
	self pressattackbutton( 1 );
	return 1;
}

bot_shotgun_think() //checked partially changed to match cerberus output did not change foreach to while loop see github for more info
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
	else if ( self getweaponammoclip( weapon ) && distsq < 90000 )
	{
		self cancelgoal( "enemy_patrol" );
		self addgoal( self.origin, 24, 4, "cover" );
	}
	dot = self bot_dot_product( self.bot.threat.aim_target );
	if ( distsq < 250000 && dot > 0.98 )
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
		if ( dot < 0.9 )
		{
			return;
		}
	}
	else
	{
		return;
	}
	primariesArray = self getweaponslistprimaries();
	weapon = self getcurrentweapon();
	i = 0;
	primaries = getArrayKeys( primariesArray );
	while ( i < primaries.size )
	{
		if ( primaries[ i ] == weapon )
		{
			i++;
			continue;
		}
		if ( !self getweaponammoclip( primaries[ i ] ) )
		{
			i++;
			continue;
		}
		if ( maps/mp/gametypes/_weapon_utils::isguidedrocketlauncherweapon( primaries[ i ] ) )
		{
			i++;
			continue;
		}
		class = weaponclass( primaries[ i ] );
		if ( class == "spread" || class == "pistol spread" || class == "melee" && class == "item" )
		{
			i++;
			continue;
		}
		if ( self switchtoweapon( primaries[ i ] ) )
		{
			return;
		}
		i++;
	}
	if ( self getweaponammostock( "willy_pete_mp" ) > 0 )
	{
		self pressattackbutton( 2 );
		return;
	}
}

bot_turret_set_dangerous( turret ) //checked partially changed to match cerberus output did not change while loop to foreach see github for more info
{
	if ( !level.teambased )
	{
		return;
	}
	if ( isDefined( turret.dead ) && turret.dead || isDefined( turret.carried ) && turret.carried )
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
		foreach ( node in nodes )
		{
			dir = vectornormalize( node.origin - turret.origin );
			dot = vectordot( forward, dir );
			if ( dot >= 0.5 )
			{
				turret turret_mark_node_dangerous( node );
			}
		}
	}
	if ( turret.turrettype == "microwave" )
	{
		nodes = getnodesinradius( turret.origin, level.microwave_radius, 0 );
		i = 0;
		while ( i < nodes.size )
		{
			if ( !nodesvisible( nearest, nodes[ i ] ) )
			{
				i++;
				continue;
			}
			dir = vectornormalize( nodes[ i ].origin - turret.origin );
			dot = vectordot( forward, dir );
			if ( dot >= level.microwave_turret_cone_dot )
			{
				turret turret_mark_node_dangerous( nodes[ i ] );
			}
			i++;
		}
	}
}

bot_turret_nearest_node( turret ) //checked changed to match cerberus output
{
	nodes = getnodesinradiussorted( turret.origin, 256, 0 );
	forward = anglesToForward( turret.angles );
	foreach ( node in nodes )
	{
		dir = vectornormalize( node.origin - turret.origin );
		dot = vectordot( forward, dir );
		if ( dot > 0.5 )
		{
			return node;
		}
	}
	if ( nodes.size )
	{
		return nodes[ 0 ];
	}
	return undefined;
}

turret_mark_node_dangerous( node ) //checked partially changed to match cerberus output did not change while loop to foreach see github for more info
{
	i = 0;
	teams = getArrayKeys( level.teams );
	while ( i < level.teams.size )
	{
		if ( teams[ i ] == self.owner.team )
		{
			i++;
			continue;
		}
		node setdangerous( teams[ i ], 1 );
		i++;
	}
	self.dangerous_nodes[ self.dangerous_nodes.size ] = node;
}

turret_get_attack_node() //checked partially changed to match cerberus output did not change while loop to foreach see github for more info
{
	nearest = bot_nearest_node( self.origin );
	if ( !isDefined( nearest ) )
	{
		return undefined;
	}
	nodes = getnodesinradiussorted( self.origin, 512, 64 );
	forward = anglesToForward( self.angles );
	i = 0;
	while ( i < nodes.size )
	{
		if ( !nodesvisible( nodes[ i ], nearest ) )
		{
			i++;
			continue;
		}
		dir = vectornormalize( nodes[ i ].origin - self.origin );
		dot = vectordot( forward, dir );
		if ( dot < 0.5 )
		{
			return nodes[ i ];
		}
		i++;
	}
	return undefined;
}

bot_riotshield_think( enemy ) //checked matches cerberus output
{
	dot = enemy bot_dot_product( self.origin );
	if ( !bot_has_crossbow() && !bot_using_launcher() && enemy getstance() != "stand" )
	{
		if ( dot > 0.8 )
		{
			self allowattack( 0 );
		}
	}
	forward = anglesToForward( enemy.angles );
	origin = enemy.origin + forward * randomintrange( 256, 512 );
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

bot_riotshield_dangerous_think( enemy, goal ) //checked partially changed to match cerberus output
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
	i = 0;
	while ( i < nodes.size )
	{
		if ( !nodesvisible( nodes[ i ], nearest ) )
		{
			i++;
			continue;
		}
		dir = vectornormalize( nodes[ i ].origin - enemy.origin );
		dot = vectordot( forward, dir );
		if ( dot < 0 )
		{
			if ( distancesquared( self.origin, enemy.origin ) < 262144 )
			{
				self addgoal( nodes[ i ], 24, 4, "cover" );
			}
			else
			{
				self addgoal( nodes[ i ], 24, 3, "cover" );
			}
			break;
		}
		i++;
	}
	if ( !level.teambased )
	{
		return;
	}
	nodes = getnodesinradius( enemy.origin, 512, 0 );
	foreach ( node in nodes )
	{
		dir = vectornormalize( node.origin - enemy.origin );
		dot = vectordot( forward, dir );
		if ( dot >= 0.5 )
		{
			node setdangerous( self.team, 1 );
		}
	}
	enemy wait_endon( 5, "death" );
	foreach ( node in nodes )
	{
		node setdangerous( self.team, 0 );
	}
}





