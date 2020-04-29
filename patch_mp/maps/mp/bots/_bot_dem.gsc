#include maps/mp/bots/_bot_combat;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/dem;

bot_dem_think()
{
	while ( !isDefined( level.bombzones[ 0 ].dem_nodes ) )
	{
		_a11 = level.bombzones;
		_k11 = getFirstArrayKey( _a11 );
		while ( isDefined( _k11 ) )
		{
			zone = _a11[ _k11 ];
			zone.dem_nodes = [];
			zone.dem_nodes = getnodesinradius( zone.trigger.origin, 1024, 64, 128, "Path" );
			_k11 = getNextArrayKey( _a11, _k11 );
		}
	}
	if ( self.team == game[ "attackers" ] )
	{
		bot_dem_attack_think();
	}
	else
	{
		bot_dem_defend_think();
	}
}

bot_dem_attack_think()
{
	zones = dem_get_alive_zones();
	if ( !zones.size )
	{
		return;
	}
	while ( !isDefined( self.goal_flag ) )
	{
		zones = array_randomize( zones );
		_a42 = zones;
		_k42 = getFirstArrayKey( _a42 );
		while ( isDefined( _k42 ) )
		{
			zone = _a42[ _k42 ];
			if ( zones.size == 1 || is_true( zone.bombplanted ) && !is_true( zone.bombexploded ) )
			{
				self.goal_flag = zone;
				break;
			}
			else if ( randomint( 100 ) < 50 )
			{
				self.goal_flag = zone;
				break;
			}
			else
			{
				_k42 = getNextArrayKey( _a42, _k42 );
			}
		}
	}
	if ( isDefined( self.goal_flag ) )
	{
		if ( is_true( self.goal_flag.bombexploded ) )
		{
			self.goal_flag = undefined;
			self cancelgoal( "dem_guard" );
			self cancelgoal( "bomb" );
			return;
		}
		else if ( is_true( self.goal_flag.bombplanted ) )
		{
			self bot_dem_guard( self.goal_flag, self.goal_flag.dem_nodes, self.goal_flag.trigger.origin );
			return;
		}
		else if ( self bot_dem_friend_interacting( self.goal_flag.trigger.origin ) )
		{
			self bot_dem_guard( self.goal_flag, self.goal_flag.dem_nodes, self.goal_flag.trigger.origin );
			return;
		}
		else
		{
			self bot_dem_attack( self.goal_flag );
		}
	}
}

bot_dem_defend_think()
{
	zones = dem_get_alive_zones();
	if ( !zones.size )
	{
		return;
	}
	while ( !isDefined( self.goal_flag ) )
	{
		zones = array_randomize( zones );
		_a95 = zones;
		_k95 = getFirstArrayKey( _a95 );
		while ( isDefined( _k95 ) )
		{
			zone = _a95[ _k95 ];
			if ( zones.size == 1 || is_true( zone.bombplanted ) && !is_true( zone.bombexploded ) )
			{
				self.goal_flag = zone;
				break;
			}
			else if ( randomint( 100 ) < 50 )
			{
				self.goal_flag = zone;
				break;
			}
			else
			{
				_k95 = getNextArrayKey( _a95, _k95 );
			}
		}
	}
	if ( isDefined( self.goal_flag ) )
	{
		if ( is_true( self.goal_flag.bombexploded ) )
		{
			self.goal_flag = undefined;
			self cancelgoal( "dem_guard" );
			self cancelgoal( "bomb" );
			return;
		}
		else if ( is_true( self.goal_flag.bombplanted ) && !self bot_dem_friend_interacting( self.goal_flag.trigger.origin ) )
		{
			self bot_dem_defuse( self.goal_flag );
			return;
		}
		else
		{
			self bot_dem_guard( self.goal_flag, self.goal_flag.dem_nodes, self.goal_flag.trigger.origin );
		}
	}
}

bot_dem_attack( zone )
{
	self cancelgoal( "dem_guard" );
	if ( !self hasgoal( "bomb" ) )
	{
		self.bomb_goal = self dem_get_bomb_goal( zone.visuals[ 0 ] );
		if ( isDefined( self.bomb_goal ) )
		{
			self addgoal( self.bomb_goal, 48, 2, "bomb" );
		}
		return;
	}
	if ( !self atgoal( "bomb" ) )
	{
		if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_smoke( self.bomb_goal ) )
		{
			if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( self.bomb_goal ) )
			{
				self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( self.bomb_goal );
			}
		}
		return;
	}
	self addgoal( self.bomb_goal, 48, 4, "bomb" );
	self setstance( "prone" );
	self pressusebutton( level.planttime + 1 );
	wait 0,5;
	if ( is_true( self.isplanting ) )
	{
		wait ( level.planttime + 1 );
	}
	self pressusebutton( 0 );
	defenders = self bot_get_enemies();
	_a172 = defenders;
	_k172 = getFirstArrayKey( _a172 );
	while ( isDefined( _k172 ) )
	{
		defender = _a172[ _k172 ];
		if ( defender is_bot() )
		{
			defender.goal_flag = undefined;
		}
		_k172 = getNextArrayKey( _a172, _k172 );
	}
	self setstance( "crouch" );
	wait 0,25;
	self cancelgoal( "bomb" );
	self setstance( "stand" );
}

bot_dem_guard( zone, nodes, origin )
{
	self cancelgoal( "bomb" );
	enemy = self bot_dem_enemy_interacting( origin );
	if ( isDefined( enemy ) )
	{
		self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( enemy.origin );
		self addgoal( enemy.origin, 128, 3, "dem_guard" );
		return;
	}
	enemy = self bot_dem_enemy_nearby( origin );
	if ( isDefined( enemy ) )
	{
		self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( enemy.origin );
		self addgoal( enemy.origin, 128, 3, "dem_guard" );
		return;
	}
	if ( self hasgoal( "dem_guard" ) && !self atgoal( "dem_guard" ) )
	{
		self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( origin );
		return;
	}
	node = random( nodes );
	self addgoal( node, 24, 2, "dem_guard" );
}

bot_dem_defuse( zone )
{
	self cancelgoal( "dem_guard" );
	if ( !self hasgoal( "bomb" ) )
	{
		self.bomb_goal = self dem_get_bomb_goal( zone.visuals[ 0 ] );
		if ( isDefined( self.bomb_goal ) )
		{
			self addgoal( self.bomb_goal, 48, 2, "bomb" );
		}
		return;
	}
	if ( !self atgoal( "bomb" ) )
	{
		if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_smoke( self.bomb_goal ) )
		{
			if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_proximity( self.bomb_goal ) )
			{
				self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( self.bomb_goal );
			}
		}
		if ( ( self.goal_flag.detonatetime - getTime() ) < 12000 )
		{
			self addgoal( self.bomb_goal, 48, 4, "bomb" );
		}
		return;
	}
	self addgoal( self.bomb_goal, 48, 4, "bomb" );
	if ( cointoss() )
	{
		self setstance( "crouch" );
	}
	else
	{
		self setstance( "prone" );
	}
	self pressusebutton( level.defusetime + 1 );
	wait 0,5;
	if ( is_true( self.isdefusing ) )
	{
		wait ( level.defusetime + 1 );
	}
	self pressusebutton( 0 );
	self setstance( "crouch" );
	wait 0,25;
	self cancelgoal( "bomb" );
	self setstance( "stand" );
}

bot_dem_enemy_interacting( origin )
{
	enemies = maps/mp/bots/_bot::bot_get_enemies();
	_a288 = enemies;
	_k288 = getFirstArrayKey( _a288 );
	while ( isDefined( _k288 ) )
	{
		enemy = _a288[ _k288 ];
		if ( distancesquared( enemy.origin, origin ) > 65536 )
		{
		}
		else
		{
			if ( is_true( enemy.isdefusing ) || is_true( enemy.isplanting ) )
			{
				return enemy;
			}
		}
		_k288 = getNextArrayKey( _a288, _k288 );
	}
	return undefined;
}

bot_dem_friend_interacting( origin )
{
	friends = maps/mp/bots/_bot::bot_get_friends();
	_a308 = friends;
	_k308 = getFirstArrayKey( _a308 );
	while ( isDefined( _k308 ) )
	{
		friend = _a308[ _k308 ];
		if ( distancesquared( friend.origin, origin ) > 65536 )
		{
		}
		else
		{
			if ( is_true( friend.isdefusing ) || is_true( friend.isplanting ) )
			{
				return 1;
			}
		}
		_k308 = getNextArrayKey( _a308, _k308 );
	}
	return 0;
}

bot_dem_enemy_nearby( origin )
{
	enemy = maps/mp/bots/_bot::bot_get_closest_enemy( origin, 1 );
	if ( isDefined( enemy ) )
	{
		if ( distancesquared( enemy.origin, origin ) < 1048576 )
		{
			return enemy;
		}
	}
	return undefined;
}

dem_get_alive_zones()
{
	zones = [];
	_a343 = level.bombzones;
	_k343 = getFirstArrayKey( _a343 );
	while ( isDefined( _k343 ) )
	{
		zone = _a343[ _k343 ];
		if ( is_true( zone.bombexploded ) )
		{
		}
		else
		{
			zones[ zones.size ] = zone;
		}
		_k343 = getNextArrayKey( _a343, _k343 );
	}
	return zones;
}

dem_get_bomb_goal( ent )
{
	while ( !isDefined( ent.bot_goals ) )
	{
		goals = [];
		ent.bot_goals = [];
		dir = anglesToForward( ent.angles );
		dir = vectorScale( dir, 32 );
		goals[ 0 ] = ent.origin + dir;
		goals[ 1 ] = ent.origin - dir;
		dir = anglesToRight( ent.angles );
		dir = vectorScale( dir, 48 );
		goals[ 2 ] = ent.origin + dir;
		goals[ 3 ] = ent.origin - dir;
		_a375 = goals;
		_k375 = getFirstArrayKey( _a375 );
		while ( isDefined( _k375 ) )
		{
			goal = _a375[ _k375 ];
			start = goal + vectorScale( ( 0, 0, 1 ), 128 );
			trace = bullettrace( start, goal, 0, undefined );
			ent.bot_goals[ ent.bot_goals.size ] = trace[ "position" ];
			_k375 = getNextArrayKey( _a375, _k375 );
		}
	}
	goals = array_randomize( ent.bot_goals );
	_a386 = goals;
	_k386 = getFirstArrayKey( _a386 );
	while ( isDefined( _k386 ) )
	{
		goal = _a386[ _k386 ];
		if ( findpath( self.origin, goal, 0 ) )
		{
			return goal;
		}
		_k386 = getNextArrayKey( _a386, _k386 );
	}
	return undefined;
}
