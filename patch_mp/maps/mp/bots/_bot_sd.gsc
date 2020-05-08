//changed includes to match cerberus output
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/bots/_bot_combat;
#include maps/mp/bots/_bot;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/_utility;
#include common_scripts/utility;

bot_sd_think() //checked changed to match cerberus output
{
	foreach ( zone in level.bombzones )
	{
		if ( !isDefined( zone.nearest_node ) )
		{
			nodes = getnodesinradiussorted( zone.trigger.origin, 256, 0 );
			/*
/#
			assert( nodes.size );
#/
			*/
			zone.nearest_node = nodes[ 0 ];
		}
	}
	zone = sd_get_planted_zone();
	if ( isDefined( zone ) )
	{
		self bot_sd_defender( zone, 1 );
	}
	else if ( self.team == game[ "attackers" ] )
	{
		if ( level.multibomb )
		{
			self.isbombcarrier = 1;
		}
		self bot_sd_attacker();
	}
	else
	{
		zone = random( level.bombzones );
		self bot_sd_defender( zone );
	}
}

bot_sd_attacker() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	if ( !level.multibomb && !isDefined( level.sdbomb.carrier ) && !level.bombplanted )
	{
		self cancelgoal( "sd_protect_carrier" );
		if ( !level.sdbomb maps/mp/gametypes/_gameobjects::isobjectawayfromhome() )
		{
			if ( !self maps/mp/bots/_bot::bot_friend_goal_in_radius( "sd_pickup", level.sdbomb.curorigin, 64 ) )
			{
				self addgoal( level.sdbomb.curorigin, 16, 4, "sd_pickup" );
				return;
			}
		}
		else
		{
			self addgoal( level.sdbomb.curorigin, 16, 4, "sd_pickup" );
			return;
		}
	}
	else
	{
		self cancelgoal( "sd_pickup" );
	}
	if ( is_true( self.isbombcarrier ) )
	{
		goal = self getgoal( "sd_plant" );
		if ( isDefined( goal ) )
		{
			if ( distancesquared( self.origin, goal ) < 2304 )
			{
				self setstance( "prone" );
				wait 0.5;
				self pressusebutton( level.planttime + 1 );
				wait 0.5;
				if ( is_true( self.isplanting ) )
				{
					wait ( level.planttime + 1 );
				}
				self pressusebutton( 0 );
				self setstance( "crouch" );
				wait 0.25;
				self cancelgoal( "sd_plant" );
				self setstance( "stand" );
			}
			return;
		}
		else if ( getTime() > self.bot[ "patrol_update" ] )
		{
			frac = sd_get_time_frac();
			if ( randomint( 100 ) < ( frac * 100 ) || frac > 0.85 )
			{
				zone = sd_get_closest_bomb();
				goal = sd_get_bomb_goal( zone.visuals[ 0 ] );
				if ( isDefined( goal ) )
				{
					if ( frac > 0.85 )
					{
						self addgoal( goal, 24, 4, "sd_plant" );
					}
					else
					{
						self addgoal( goal, 24, 3, "sd_plant" );
					}
				}
			}
			self.bot[ "patrol_update" ] = getTime() + randomintrange( 2500, 5000 );
		}
	}
	else if ( isDefined( level.sdbomb.carrier ) && !isplayer( level.sdbomb.carrier ) )
	{
		if ( !isDefined( self.protectcarrier ) )
		{
			if ( randomint( 100 ) > 70 )
			{
				self.protectcarrier = 1;
			}
			else
			{
				self.protectcarrier = 0;
			}
		}
		if ( self.protectcarrier )
		{
			goal = level.sdbomb.carrier getgoal( "sd_plant" );
			if ( isDefined( goal ) )
			{
				nodes = getnodesinradiussorted( goal, 256, 0 );
				if ( isDefined( nodes ) && nodes.size > 0 && !isDefined( self getgoal( "sd_protect_carrier" ) ) )
				{
					self addgoal( nodes[ randomint( nodes.size ) ], 24, 3, "sd_protect_carrier" );
				}
			}
		}
	}
}

bot_sd_defender( zone, isplanted ) //checked partially changed to match cerberus output did not use foreach see github for more info
{
	bot_sd_grenade();
	if ( isDefined( isplanted ) && isplanted && self hasgoal( "sd_defend" ) )
	{
		goal = self getgoal( "sd_defend" );
		planted = sd_get_planted_zone();
		foreach ( zone in level.bombzones )
		{
			if ( planted != zone && distance2d( goal, zone.nearest_node.origin ) < distance2d( goal, planted.nearest_node.origin ) )
			{
				self cancelgoal( "sd_defend" );
			}
		}
	}
	else if ( self atgoal( "sd_defend" ) || self bot_need_to_defuse() )
	{
		bot_sd_defender_think( zone );
		if ( self hasgoal( "sd_defend" ) )
		{
			return;
		}
	}
	if ( self hasgoal( "enemy_patrol" ) )
	{
		goal = self getgoal( "enemy_patrol" );
		closezone = sd_get_closest_bomb();
		if ( distancesquared( goal, closezone.nearest_node.origin ) < 262144 )
		{
			self clearlookat();
			self cancelgoal( "sd_defend" );
			return;
		}
	}
	if ( self hasgoal( "sd_defend" ) )
	{
		self.bot[ "patrol_update" ] = getTime() + randomintrange( 2500, 5000 );
		return;
	}
	if ( self hasgoal( "enemy_patrol" ) )
	{
		return;
	}
	nodes = getvisiblenodes( zone.nearest_node );
	best = undefined;
	highest = -100;
	i = 0;
	while ( i < nodes.size )
	{
		if ( node[ i ].type == "BAD NODE" )
		{
			i++;
			continue;
		}
		if ( !canclaimnode( node[ i ], self.team ) )
		{
			i++;
			continue;
		}
		if ( distancesquared( node[ i ].origin, self.origin ) < 65536 )
		{
			i++;
			continue;
		}
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "sd_defend", node[ i ].origin, 256 ) > 0 )
		{
			i++;
			continue;
		}
		height = node[ i ].origin[ 2 ] - zone.nearest_node.origin[ 2 ];
		if ( isDefined( isplanted ) && isplanted )
		{
			dist = distance2d( node[ i ].origin, zone.nearest_node.origin );
			score = ( 10000 - dist ) + height;
		}
		else
		{
			score = height;
		}
		if ( score > highest )
		{
			highest = score;
			best = node;
		}
		i++;
	}
	if ( !isDefined( best ) )
	{
		return;
	}
	self addgoal( best, 24, 3, "sd_defend" );
}

bot_get_look_at() //checked matches cebrerus output
{
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( self.origin, 1 );
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
		if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 16384 )
		{
			return node.origin;
		}
	}
	enemies = self maps/mp/bots/_bot::bot_get_enemies( 0 );
	if ( enemies.size )
	{
		enemy = random( enemies );
	}
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
		if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 16384 )
		{
			return node.origin;
		}
	}
	zone = sd_get_closest_bomb();
	node = getvisiblenode( self.origin, zone.nearest_node.origin );
	if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 16384 )
	{
		return node.origin;
	}
	forward = anglesToForward( self getplayerangles() );
	origin = self geteye() + ( forward * 1024 );
	return origin;
}

bot_sd_defender_think( zone ) //checked matches cerberus output
{
	if ( self bot_need_to_defuse() )
	{
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "sd_defuse", level.sdbombmodel.origin, 16 ) > 0 )
		{
			return;
		}
		self clearlookat();
		goal = self getgoal( "sd_defuse" );
		if ( isDefined( goal ) && distancesquared( self.origin, goal ) < 2304 )
		{
			self setstance( "prone" );
			wait 0.5;
			self pressusebutton( level.defusetime + 1 );
			wait 0.5;
			if ( is_true( self.isdefusing ) )
			{
				wait ( level.defusetime + 1 );
			}
			self pressusebutton( 0 );
			self setstance( "crouch" );
			wait 0.25;
			self cancelgoal( "sd_defuse" );
			self setstance( "stand" );
			return;
		}
		if ( !isDefined( goal ) && distance2dsquared( self.origin, level.sdbombmodel.origin ) < 1000000 )
		{
			self addgoal( level.sdbombmodel.origin, 24, 4, "sd_defuse" );
		}
		return;
	}
	if ( getTime() > self.bot[ "patrol_update" ] )
	{
		if ( cointoss() )
		{
			self clearlookat();
			self cancelgoal( "sd_defend" );
			return;
		}
		self.bot[ "patrol_update" ] = getTime() + randomintrange( 2500, 5000 );
	}
	if ( self hasgoal( "enemy_patrol" ) )
	{
		goal = self getgoal( "enemy_patrol" );
		zone = sd_get_closest_bomb();
		if ( distancesquared( goal, zone.nearest_node.origin ) < 262144 )
		{
			self clearlookat();
			self cancelgoal( "sd_defend" );
			return;
		}
	}
	if ( getTime() > self.bot[ "lookat_update" ] )
	{
		origin = self bot_get_look_at();
		z = 20;
		if ( distancesquared( origin, self.origin ) > 262144 )
		{
			z = randomintrange( 16, 60 );
		}
		self lookat( origin + ( 0, 0, z ) );
		self.bot[ "lookat_update" ] = getTime() + randomintrange( 1500, 3000 );
		if ( distancesquared( origin, self.origin ) > 65536 )
		{
			dir = vectornormalize( self.origin - origin );
			dir = vectorScale( dir, 256 );
			origin += dir;
		}
		self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( origin );
	}
}

bot_need_to_defuse() //checked changed at own discretion
{
	if ( level.bombplanted && self.team == game[ "defenders" ] )
	{
		return 1;
	}
	return 0;
}

sd_get_bomb_goal( ent ) //checked changed to match cerberus output
{
	goals = [];
	dir = anglesToForward( ent.angles );
	dir = vectorScale( dir, 32 );
	goals[ 0 ] = ent.origin + dir;
	goals[ 1 ] = ent.origin - dir;
	dir = anglesToRight( ent.angles );
	dir = vectorScale( dir, 48 );
	goals[ 2 ] = ent.origin + dir;
	goals[ 3 ] = ent.origin - dir;
	goals = array_randomize( goals );
	foreach ( goal in goals )
	{
		if ( findpath( self.origin, goal, 0 ) )
		{
			return goal;
		}
	}
	return undefined;
}

sd_get_time_frac() //checked matches cerberus output
{
	remaining = maps/mp/gametypes/_globallogic_utils::gettimeremaining();
	end = ( level.timelimit * 60 ) * 1000;
	if ( end == 0 )
	{
		end = self.spawntime + 120000;
		remaining = end - getTime();
	}
	return 1 - ( remaining / end );
}

sd_get_closest_bomb() //checked partially changed to match cerberus output did not use continue see github for more info
{
	best = undefined;
	distsq = 9999999;
	foreach ( zone in level.bombzones )
	{
		d = distancesquared( self.origin, zone.curorigin );
		if ( !isDefined( best ) )
		{
			best = zone;
			distsq = d;
		}
		else if ( d < distsq )
		{
			best = zone;
			distsq = d;
		}
	}
	return best;
}

sd_get_planted_zone() //checked changed to match cerberus output
{
	if ( level.bombplanted )
	{
		foreach ( zone in level.bombzones )
		{
			if ( zone.interactteam == "none" )
			{
				return zone;
			}
		}
	}
	return undefined;
}

bot_sd_grenade() //checked changed to match cerberus output
{
	enemies = bot_get_enemies();
	if ( !enemies.size )
	{
		return;
	}
	zone = sd_get_closest_bomb();
	foreach ( enemy in enemies )
	{
		if ( distancesquared( enemy.origin, zone.nearest_node.origin ) < 147456 )
		{
			if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( enemy.origin ) )
			{
				self maps/mp/bots/_bot_combat::bot_combat_throw_tactical( enemy.origin );
			}
			return;
		}
	}
}

