#include maps/mp/bots/_bot_combat;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/koth;

bot_hq_think()
{
	time = getTime();
	if ( time < self.bot.update_objective )
	{
		return;
	}
	self.bot.update_objective = time + randomintrange( 500, 1500 );
	if ( bot_should_patrol_hq() )
	{
		self bot_patrol_hq();
	}
	else
	{
		if ( !bot_has_hq_goal() )
		{
			self bot_move_to_hq();
		}
	}
	if ( self bot_is_capturing_hq() )
	{
		self bot_capture_hq();
	}
	bot_hq_tactical_insertion();
	bot_hq_grenade();
	if ( !bot_is_capturing_hq() && !self atgoal( "hq_patrol" ) )
	{
		mine = getnearestnode( self.origin );
		node = hq_nearest_node();
		if ( isDefined( mine ) && nodesvisible( mine, node ) )
		{
			self lookat( level.radio.baseorigin + vectorScale( ( 0, 0, 1 ), 30 ) );
		}
	}
}

bot_has_hq_goal()
{
	origin = self getgoal( "hq_radio" );
	while ( isDefined( origin ) )
	{
		_a53 = level.radio.nodes;
		_k53 = getFirstArrayKey( _a53 );
		while ( isDefined( _k53 ) )
		{
			node = _a53[ _k53 ];
			if ( distancesquared( origin, node.origin ) < 4096 )
			{
				return 1;
			}
			_k53 = getNextArrayKey( _a53, _k53 );
		}
	}
	return 0;
}

bot_is_capturing_hq()
{
	return self atgoal( "hq_radio" );
}

bot_should_patrol_hq()
{
	if ( level.radio.gameobject.ownerteam == "neutral" )
	{
		return 0;
	}
	if ( level.radio.gameobject.ownerteam != self.team )
	{
		return 0;
	}
	if ( hq_is_contested() )
	{
		return 0;
	}
	return 1;
}

bot_patrol_hq()
{
	self cancelgoal( "hq_radio" );
	if ( self atgoal( "hq_patrol" ) )
	{
		node = getnearestnode( self.origin );
		if ( node.type == "Path" )
		{
			self setstance( "crouch" );
		}
		else
		{
			self setstance( "stand" );
		}
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
			self.bot.update_lookat = getTime() + randomintrange( 1500, 3000 );
		}
		goal = self getgoal( "hq_patrol" );
		nearest = hq_nearest_node();
		mine = getnearestnode( goal );
		if ( isDefined( mine ) && !nodesvisible( mine, nearest ) )
		{
			self clearlookat();
			self cancelgoal( "hq_patrol" );
		}
		if ( getTime() > self.bot.update_objective_patrol )
		{
			self clearlookat();
			self cancelgoal( "hq_patrol" );
		}
		return;
	}
	nearest = hq_nearest_node();
	if ( self hasgoal( "hq_patrol" ) )
	{
		goal = self getgoal( "hq_patrol" );
		if ( distancesquared( self.origin, goal ) < 65536 )
		{
			origin = self bot_get_look_at();
			self lookat( origin );
		}
		if ( distancesquared( self.origin, goal ) < 16384 )
		{
			self.bot.update_objective_patrol = getTime() + randomintrange( 3000, 6000 );
		}
		mine = getnearestnode( goal );
		if ( isDefined( mine ) && !nodesvisible( mine, nearest ) )
		{
			self clearlookat();
			self cancelgoal( "hq_patrol" );
		}
		return;
	}
	nodes = getvisiblenodes( nearest );
/#
	assert( nodes.size );
#/
	i = randomint( nodes.size );
	while ( i < nodes.size )
	{
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "hq_radio", nodes[ i ].origin, 128 ) == 0 )
		{
			if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "hq_patrol", nodes[ i ].origin, 256 ) == 0 )
			{
				self addgoal( nodes[ i ], 24, 3, "hq_patrol" );
				return;
			}
		}
		i++;
	}
}

bot_move_to_hq()
{
	self clearlookat();
	self cancelgoal( "hq_radio" );
	self cancelgoal( "hq_patrol" );
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
	nodes = array_randomize( level.radio.nodes );
	_a219 = nodes;
	_k219 = getFirstArrayKey( _a219 );
	while ( isDefined( _k219 ) )
	{
		node = _a219[ _k219 ];
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "hq_radio", node.origin, 64 ) == 0 )
		{
			self addgoal( node, 24, 3, "hq_radio" );
			return;
		}
		_k219 = getNextArrayKey( _a219, _k219 );
	}
	self addgoal( random( nodes ), 24, 3, "hq_radio" );
}

bot_get_look_at()
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
	spawn = random( level.spawnpoints );
	node = getvisiblenode( self.origin, spawn.origin );
	if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 16384 )
	{
		return node.origin;
	}
	return level.radio.baseorigin;
}

bot_capture_hq()
{
	self addgoal( self.origin, 24, 3, "hq_radio" );
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
		self.bot.update_lookat = getTime() + randomintrange( 1500, 3000 );
	}
}

any_other_team_touching( skip_team )
{
	_a307 = level.teams;
	_k307 = getFirstArrayKey( _a307 );
	while ( isDefined( _k307 ) )
	{
		team = _a307[ _k307 ];
		if ( team == skip_team )
		{
		}
		else
		{
			if ( level.radio.gameobject.numtouching[ team ] )
			{
				return 1;
			}
		}
		_k307 = getNextArrayKey( _a307, _k307 );
	}
	return 0;
}

is_hq_contested( skip_team )
{
	if ( any_other_team_touching( skip_team ) )
	{
		return 1;
	}
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( level.radio.baseorigin, 1 );
	if ( isDefined( enemy ) && distancesquared( enemy.origin, level.radio.baseorigin ) < 262144 )
	{
		return 1;
	}
	return 0;
}

bot_hq_grenade()
{
	enemies = bot_get_enemies();
	if ( !enemies.size )
	{
		return;
	}
	if ( self atgoal( "hq_patrol" ) || self atgoal( "hq_radio" ) )
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
	if ( !is_hq_contested( self.team ) )
	{
		self maps/mp/bots/_bot_combat::bot_combat_throw_smoke( level.radio.baseorigin );
		return;
	}
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( level.radio.baseorigin, 0 );
	if ( isDefined( enemy ) )
	{
		origin = enemy.origin;
	}
	else
	{
		origin = level.radio.baseorigin;
	}
	dir = vectornormalize( self.origin - origin );
	dir = ( 0, dir[ 1 ], 0 );
	origin += vectorScale( dir, 128 );
	if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( origin ) )
	{
		self maps/mp/bots/_bot_combat::bot_combat_throw_tactical( origin );
	}
}

bot_hq_tactical_insertion()
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
	node = hq_nearest_node();
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

hq_nearest_node()
{
	return random( level.radio.nodes );
}

hq_is_contested()
{
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( level.radio.baseorigin, 0 );
	if ( isDefined( enemy ) )
	{
		return distancesquared( enemy.origin, level.radio.baseorigin ) < ( level.radio.node_radius * level.radio.node_radius );
	}
}
