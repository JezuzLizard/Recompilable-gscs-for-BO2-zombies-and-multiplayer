#include maps/mp/gametypes/_gameobjects;
#include maps/mp/bots/_bot_combat;
#include maps/mp/bots/_bot;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/ctf;

bot_ctf_think()
{
	time = getTime();
	if ( time < self.bot.update_objective )
	{
		return;
	}
	self.bot.update_objective = time + randomintrange( 500, 1500 );
	if ( maps/mp/bots/_bot::bot_get_difficulty() != "easy" )
	{
		flag_mine = ctf_get_flag( self.team );
		if ( flag_mine ishome() && distancesquared( self.origin, flag_mine.curorigin ) < 262144 )
		{
			nodes = getnodesinradius( flag_mine.curorigin, 256, 0, 64, "any", 8 );
			node = random( nodes );
			if ( cointoss() )
			{
			}
			else
			{
			}
			self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( node.origin, flag_mine.curorigin );
			if ( cointoss() )
			{
			}
			else
			{
			}
			self maps/mp/bots/_bot_combat::bot_combat_toss_frag( node.origin, flag_mine.curorigin );
			if ( cointoss() )
			{
			}
			else
			{
			}
			self maps/mp/bots/_bot_combat::bot_combat_toss_flash( node.origin, flag_mine.curorigin );
		}
	}
	if ( bot_should_patrol_flag() )
	{
		bot_patrol_flag();
		return;
	}
	self cancelgoal( "ctf_flag_patrol" );
	if ( !bot_ctf_defend() )
	{
		bot_ctf_capture();
	}
	flag_mine = ctf_get_flag( self.team );
	flag_enemy = ctf_get_flag( getotherteam( self.team ) );
	home_mine = flag_mine ctf_flag_get_home();
	if ( ctf_has_flag( flag_enemy ) && self issprinting() && distancesquared( self.origin, home_mine ) < 36864 )
	{
		if ( bot_dot_product( home_mine ) > 0,9 )
		{
			self bot_dive_to_prone( "stand" );
		}
	}
	else
	{
		if ( !flag_mine ishome() && !isDefined( flag_mine.carrier ) )
		{
			if ( self issprinting() && distancesquared( self.origin, flag_mine.curorigin ) < 36864 )
			{
				if ( bot_dot_product( flag_mine.curorigin ) > 0,9 )
				{
					self bot_dive_to_prone( "stand" );
				}
			}
		}
	}
}

bot_should_patrol_flag()
{
	flag_mine = ctf_get_flag( self.team );
	flag_enemy = ctf_get_flag( getotherteam( self.team ) );
	home_mine = flag_mine ctf_flag_get_home();
	if ( self hasgoal( "ctf_flag" ) && !self atgoal( "ctf_flag" ) )
	{
		return 0;
	}
	if ( ctf_has_flag( flag_enemy ) )
	{
		if ( !flag_mine ishome() )
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	if ( !flag_mine ishome() )
	{
		return 0;
	}
	if ( distancesquared( self.origin, flag_enemy.curorigin ) < 262144 )
	{
		return 0;
	}
	if ( bot_get_friends().size && self maps/mp/bots/_bot::bot_friend_goal_in_radius( "ctf_flag_patrol", home_mine, 1024 ) == 0 )
	{
		return 1;
	}
	return 0;
}

ctf_get_flag( team )
{
	_a115 = level.flags;
	_k115 = getFirstArrayKey( _a115 );
	while ( isDefined( _k115 ) )
	{
		f = _a115[ _k115 ];
		if ( f maps/mp/gametypes/_gameobjects::getownerteam() == team )
		{
			return f;
		}
		_k115 = getNextArrayKey( _a115, _k115 );
	}
	return undefined;
}

ctf_flag_get_home()
{
	return self.trigger.baseorigin;
}

ctf_has_flag( flag )
{
	if ( isDefined( flag.carrier ) )
	{
		return flag.carrier == self;
	}
}

bot_ctf_capture()
{
	flag_enemy = ctf_get_flag( getotherteam( self.team ) );
	flag_mine = ctf_get_flag( self.team );
	home_enemy = flag_enemy ctf_flag_get_home();
	home_mine = flag_mine ctf_flag_get_home();
	if ( ctf_has_flag( flag_enemy ) )
	{
		self addgoal( home_mine, 16, 4, "ctf_flag" );
	}
	else if ( isDefined( flag_enemy.carrier ) )
	{
		if ( self atgoal( "ctf_flag" ) )
		{
			self cancelgoal( "ctf_flag" );
		}
		goal = self getgoal( "ctf_flag" );
		if ( isDefined( goal ) && distancesquared( goal, flag_enemy.carrier.origin ) < 589824 )
		{
			return;
		}
		nodes = getnodesinradius( flag_enemy.carrier.origin, 512, 64, 256, "any", 8 );
		if ( nodes.size )
		{
			self addgoal( random( nodes ), 16, 3, "ctf_flag" );
		}
		else
		{
			self addgoal( flag_enemy.carrier.origin, 16, 3, "ctf_flag" );
		}
	}
	else
	{
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "ctf_flag", flag_enemy.curorigin, 16 ) <= 1 )
		{
			self addgoal( flag_enemy.curorigin, 16, 3, "ctf_flag" );
		}
	}
}

bot_ctf_defend()
{
	flag_enemy = ctf_get_flag( getotherteam( self.team ) );
	flag_mine = ctf_get_flag( self.team );
	home_enemy = flag_enemy ctf_flag_get_home();
	home_mine = flag_mine ctf_flag_get_home();
	if ( flag_mine ishome() )
	{
		return 0;
	}
	if ( ctf_has_flag( flag_enemy ) )
	{
		return 0;
	}
	if ( !isDefined( flag_mine.carrier ) )
	{
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "ctf_flag", flag_mine.curorigin, 16 ) <= 1 )
		{
			return self bot_ctf_add_goal( flag_mine.curorigin, 4, "ctf_flag" );
		}
	}
	else
	{
		if ( !flag_enemy ishome() || distance2dsquared( self.origin, home_enemy ) > 250000 )
		{
			return self bot_ctf_add_goal( flag_mine.curorigin, 4, "ctf_flag" );
		}
		else
		{
			if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "ctf_flag", home_enemy, 16 ) <= 1 )
			{
				self addgoal( home_enemy, 16, 4, "ctf_flag" );
			}
		}
	}
	return 1;
}

bot_ctf_add_goal( origin, goal_priority, goal_name )
{
	goal = undefined;
	if ( findpath( self.origin, origin, undefined, 0, 1 ) )
	{
		goal = origin;
	}
	else
	{
		node = bot_ctf_random_visible_node( origin );
		if ( isDefined( node ) )
		{
			if ( findpath( self.origin, node.origin, undefined, 0, 1 ) )
			{
				goal = node;
				self.bot.update_objective += randomintrange( 3000, 5000 );
			}
		}
	}
	if ( isDefined( goal ) )
	{
		self addgoal( goal, 16, goal_priority, goal_name );
		return 1;
	}
	return 0;
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
	flag_mine = ctf_get_flag( self.team );
	home_mine = flag_mine ctf_flag_get_home();
	return home_mine;
}

bot_patrol_flag()
{
	self cancelgoal( "ctf_flag" );
	flag_mine = ctf_get_flag( self.team );
	if ( self atgoal( "ctf_flag_patrol" ) )
	{
		node = getnearestnode( self.origin );
		if ( !isDefined( node ) )
		{
			self clearlookat();
			self cancelgoal( "ctf_flag_patrol" );
			return;
		}
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
		goal = self getgoal( "ctf_flag_patrol" );
		nearest = base_nearest_node( flag_mine );
		mine = getnearestnode( goal );
		if ( isDefined( mine ) && !nodesvisible( mine, nearest ) )
		{
			self clearlookat();
			self cancelgoal( "ctf_flag_patrol" );
		}
		if ( getTime() > self.bot.update_objective_patrol )
		{
			self clearlookat();
			self cancelgoal( "ctf_flag_patrol" );
		}
		return;
	}
	nearest = base_nearest_node( flag_mine );
	if ( self hasgoal( "ctf_flag_patrol" ) )
	{
		goal = self getgoal( "ctf_flag_patrol" );
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
			self cancelgoal( "ctf_flag_patrol" );
		}
		return;
	}
	if ( getTime() < self.bot.update_objective_patrol )
	{
		return;
	}
	nodes = getvisiblenodes( nearest );
/#
	assert( nodes.size );
#/
	i = randomint( nodes.size );
	while ( i < nodes.size )
	{
		if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "ctf_flag_patrol", nodes[ i ].origin, 256 ) == 0 )
		{
			self addgoal( nodes[ i ], 24, 3, "ctf_flag_patrol" );
			self.bot.update_objective_patrol = getTime() + randomintrange( 3000, 6000 );
			return;
		}
		i++;
	}
}

base_nearest_node( flag )
{
	home = flag ctf_flag_get_home();
	nodes = getnodesinradiussorted( home, 256, 0 );
/#
	assert( nodes.size );
#/
	return nodes[ 0 ];
}

bot_ctf_random_visible_node( origin )
{
	nodes = getnodesinradius( origin, 384, 0, 256 );
	nearest = maps/mp/bots/_bot_combat::bot_nearest_node( origin );
	while ( isDefined( nearest ) && nodes.size )
	{
		current = randomintrange( 0, nodes.size );
		i = 0;
		while ( i < nodes.size )
		{
			current = ( current + 1 ) % nodes.size;
			if ( nodesvisible( nodes[ current ], nearest ) )
			{
				return nodes[ current ];
			}
			i++;
		}
	}
	return undefined;
}
