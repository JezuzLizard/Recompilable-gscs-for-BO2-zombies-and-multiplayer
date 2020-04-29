#include maps/mp/bots/_bot_combat;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/koth;

bot_koth_think()
{
	if ( !isDefined( level.zone.trig.goal_radius ) )
	{
		maxs = level.zone.trig getmaxs();
		maxs = level.zone.trig.origin + maxs;
		level.zone.trig.goal_radius = distance( level.zone.trig.origin, maxs );
/#
		println( "distance: " + level.zone.trig.goal_radius );
#/
		ground = bullettrace( level.zone.gameobject.curorigin, level.zone.gameobject.curorigin - vectorScale( ( 0, 0, 1 ), 1024 ), 0, undefined );
		level.zone.trig.goal = ground[ "position" ] + vectorScale( ( 0, 0, 1 ), 8 );
	}
	if ( !bot_has_hill_goal() )
	{
		self bot_move_to_hill();
	}
	if ( self bot_is_at_hill() )
	{
		self bot_capture_hill();
	}
	bot_hill_tactical_insertion();
	bot_hill_grenade();
}

bot_has_hill_goal()
{
	origin = self getgoal( "koth_hill" );
	if ( isDefined( origin ) )
	{
		if ( distance2dsquared( level.zone.gameobject.curorigin, origin ) < ( level.zone.trig.goal_radius * level.zone.trig.goal_radius ) )
		{
			return 1;
		}
	}
	return 0;
}

bot_is_at_hill()
{
	return self atgoal( "koth_hill" );
}

bot_move_to_hill()
{
	if ( getTime() < ( self.bot.update_objective + 4000 ) )
	{
		return;
	}
	self clearlookat();
	self cancelgoal( "koth_hill" );
	if ( self getstance() == "prone" )
	{
		self setstance( "crouch" );
		wait 0,25;
	}
	if ( self getstance() == "crouch" )
	{
		self setstance( "stand" );
		wait 0,25;
	}
	nodes = getnodesinradiussorted( level.zone.trig.goal, level.zone.trig.goal_radius, 0, 128 );
	_a80 = nodes;
	_k80 = getFirstArrayKey( _a80 );
	while ( isDefined( _k80 ) )
	{
		node = _a80[ _k80 ];
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "koth_hill", node.origin, 64 ) == 0 )
		{
			if ( findpath( self.origin, node.origin, self, 0, 1 ) )
			{
				self addgoal( node, 24, 3, "koth_hill" );
				self.bot.update_objective = getTime();
				return;
			}
		}
		_k80 = getNextArrayKey( _a80, _k80 );
	}
}

bot_get_look_at()
{
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( self.origin, 1 );
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
		if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
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
		if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
		{
			return node.origin;
		}
	}
	spawn = random( level.spawnpoints );
	node = getvisiblenode( self.origin, spawn.origin );
	if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
	{
		return node.origin;
	}
	return level.zone.gameobject.curorigin;
}

bot_capture_hill()
{
	self addgoal( self.origin, 24, 3, "koth_hill" );
	self setstance( "crouch" );
	if ( getTime() > self.bot.update_lookat )
	{
		origin = self bot_get_look_at();
		z = 20;
		if ( distancesquared( origin, self.origin ) > 262144 )
		{
			z = randomintrange( 16, 60 );
		}
		self lookat( origin + ( 0, 0, z ) );
		if ( distancesquared( origin, self.origin ) > 65536 )
		{
			dir = vectornormalize( self.origin - origin );
			dir = vectorScale( dir, 256 );
			origin += dir;
		}
		self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( origin );
		while ( cointoss() && lengthsquared( self getvelocity() ) < 2 )
		{
			nodes = getnodesinradius( level.zone.trig.goal, level.zone.trig.goal_radius + 128, 0, 128 );
			i = randomintrange( 0, nodes.size );
			while ( i < nodes.size )
			{
				node = nodes[ i ];
				if ( distancesquared( node.origin, self.origin ) > 1024 )
				{
					if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "koth_hill", node.origin, 128 ) == 0 )
					{
						if ( findpath( self.origin, node.origin, self, 0, 1 ) )
						{
							self addgoal( node, 24, 3, "koth_hill" );
							self.bot.update_objective = getTime();
							break;
						}
					}
				}
				else
				{
					i++;
				}
			}
		}
		self.bot.update_lookat = getTime() + randomintrange( 1500, 3000 );
	}
}

any_other_team_touching( skip_team )
{
	_a194 = level.teams;
	_k194 = getFirstArrayKey( _a194 );
	while ( isDefined( _k194 ) )
	{
		team = _a194[ _k194 ];
		if ( team == skip_team )
		{
		}
		else
		{
			if ( level.zone.gameobject.numtouching[ team ] )
			{
				return 1;
			}
		}
		_k194 = getNextArrayKey( _a194, _k194 );
	}
	return 0;
}

is_hill_contested( skip_team )
{
	if ( any_other_team_touching( skip_team ) )
	{
		return 1;
	}
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( level.zone.gameobject.curorigin, 1 );
	if ( isDefined( enemy ) && distancesquared( enemy.origin, level.zone.gameobject.curorigin ) < 262144 )
	{
		return 1;
	}
	return 0;
}

bot_hill_grenade()
{
	enemies = bot_get_enemies();
	if ( !enemies.size )
	{
		return;
	}
	if ( self atgoal( "hill_patrol" ) || self atgoal( "koth_hill" ) )
	{
		if ( self getweaponammostock( "proximity_grenade_mp" ) > 0 )
		{
			origin = bot_get_look_at();
			if ( self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( origin ) )
			{
				return;
			}
		}
	}
	if ( !is_hill_contested( self.team ) )
	{
		if ( !isDefined( level.next_smoke_time ) )
		{
			level.next_smoke_time = 0;
		}
		if ( getTime() > level.next_smoke_time )
		{
			if ( self maps/mp/bots/_bot_combat::bot_combat_throw_smoke( level.zone.gameobject.curorigin ) )
			{
				level.next_smoke_time = getTime() + randomintrange( 60000, 120000 );
			}
		}
		return;
	}
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( level.zone.gameobject.curorigin, 0 );
	if ( isDefined( enemy ) )
	{
		origin = enemy.origin;
	}
	else
	{
		origin = level.zone.gameobject.curorigin;
	}
	dir = vectornormalize( self.origin - origin );
	dir = ( 0, dir[ 1 ], 0 );
	origin += vectorScale( dir, 128 );
	if ( maps/mp/bots/_bot::bot_get_difficulty() == "easy" )
	{
		if ( !isDefined( level.next_grenade_time ) )
		{
			level.next_grenade_time = 0;
		}
		if ( getTime() > level.next_grenade_time )
		{
			if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( origin ) )
			{
				self maps/mp/bots/_bot_combat::bot_combat_throw_tactical( origin );
			}
			else
			{
				level.next_grenade_time = getTime() + randomintrange( 60000, 120000 );
			}
		}
	}
	else
	{
		if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( origin ) )
		{
			self maps/mp/bots/_bot_combat::bot_combat_throw_tactical( origin );
		}
	}
}

bot_hill_tactical_insertion()
{
	if ( !self hasweapon( "tactical_insertion_mp" ) )
	{
		return;
	}
	dist = self getlookaheaddist();
	dir = self getlookaheaddir();
	if ( !isDefined( dist ) || !isDefined( dir ) )
	{
		return;
	}
	node = hill_nearest_node();
	mine = getnearestnode( self.origin );
	if ( isDefined( mine ) && !nodesvisible( mine, node ) )
	{
		origin = self.origin + vectorScale( dir, dist );
		next = getnearestnode( origin );
		if ( isDefined( next ) && nodesvisible( next, node ) )
		{
			bot_combat_tactical_insertion( self.origin );
		}
	}
}

hill_nearest_node()
{
	nodes = getnodesinradiussorted( level.zone.gameobject.curorigin, 256, 0 );
/#
	assert( nodes.size );
#/
	return nodes[ 0 ];
}
