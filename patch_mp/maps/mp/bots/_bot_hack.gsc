#include maps/mp/bots/_bot;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/ctf;

bot_hack_tank_get_goal_origin( tank )
{
	nodes = getnodesinradiussorted( tank.origin, 256, 0, 64, "Path" );
	_a11 = nodes;
	_k11 = getFirstArrayKey( _a11 );
	while ( isDefined( _k11 ) )
	{
		node = _a11[ _k11 ];
		dir = vectornormalize( node.origin - tank.origin );
		dir = vectorScale( dir, 32 );
		goal = tank.origin + dir;
		if ( findpath( self.origin, goal, 0 ) )
		{
			return goal;
		}
		_k11 = getNextArrayKey( _a11, _k11 );
	}
	return undefined;
}

bot_hack_has_goal( tank )
{
	goal = self getgoal( "hack" );
	if ( isDefined( goal ) )
	{
		if ( distancesquared( goal, tank.origin ) < 16384 )
		{
			return 1;
		}
	}
	return 0;
}

bot_hack_at_goal()
{
	if ( self atgoal( "hack" ) )
	{
		return 1;
	}
	goal = self getgoal( "hack" );
	while ( isDefined( goal ) )
	{
		tanks = getentarray( "talon", "targetname" );
		tanks = arraysort( tanks, self.origin );
		_a56 = tanks;
		_k56 = getFirstArrayKey( _a56 );
		while ( isDefined( _k56 ) )
		{
			tank = _a56[ _k56 ];
			if ( distancesquared( goal, tank.origin ) < 16384 )
			{
				if ( isDefined( tank.trigger ) && self istouching( tank.trigger ) )
				{
					return 1;
				}
			}
			_k56 = getNextArrayKey( _a56, _k56 );
		}
	}
	return 0;
}

bot_hack_goal_pregame( tanks )
{
	_a73 = tanks;
	_k73 = getFirstArrayKey( _a73 );
	while ( isDefined( _k73 ) )
	{
		tank = _a73[ _k73 ];
		if ( isDefined( tank.owner ) )
		{
		}
		else if ( isDefined( tank.team ) && tank.team == self.team )
		{
		}
		else
		{
			goal = self bot_hack_tank_get_goal_origin( tank );
			if ( isDefined( goal ) )
			{
				if ( self addgoal( goal, 24, 2, "hack" ) )
				{
					self.goal_flag = tank;
					return;
				}
			}
		}
		_k73 = getNextArrayKey( _a73, _k73 );
	}
}

bot_hack_think()
{
	if ( bot_hack_at_goal() )
	{
		self setstance( "crouch" );
		wait 0,25;
		self addgoal( self.origin, 24, 4, "hack" );
		self pressusebutton( level.drone_hack_time + 1 );
		wait ( level.drone_hack_time + 1 );
		self setstance( "stand" );
		self cancelgoal( "hack" );
	}
	tanks = getentarray( "talon", "targetname" );
	tanks = arraysort( tanks, self.origin );
	if ( !is_true( level.drones_spawned ) )
	{
		self bot_hack_goal_pregame( tanks );
	}
	else
	{
		_a122 = tanks;
		_k122 = getFirstArrayKey( _a122 );
		while ( isDefined( _k122 ) )
		{
			tank = _a122[ _k122 ];
			if ( isDefined( tank.owner ) && tank.owner == self )
			{
			}
			else
			{
				if ( !isDefined( tank.owner ) )
				{
					if ( self bot_hack_has_goal( tank ) )
					{
						return;
					}
					goal = self bot_hack_tank_get_goal_origin( tank );
					if ( isDefined( goal ) )
					{
						self addgoal( goal, 24, 2, "hack" );
						return;
					}
				}
				if ( tank.isstunned && distancesquared( self.origin, tank.origin ) < 262144 )
				{
					goal = self bot_hack_tank_get_goal_origin( tank );
					if ( isDefined( goal ) )
					{
						self addgoal( goal, 24, 3, "hack" );
						return;
					}
				}
			}
			_k122 = getNextArrayKey( _a122, _k122 );
		}
		if ( !maps/mp/bots/_bot::bot_vehicle_weapon_ammo( "emp_grenade_mp" ) )
		{
			ammo = getentarray( "weapon_scavenger_item_hack_mp", "classname" );
			ammo = arraysort( ammo, self.origin );
			_a162 = ammo;
			_k162 = getFirstArrayKey( _a162 );
			while ( isDefined( _k162 ) )
			{
				bag = _a162[ _k162 ];
				if ( findpath( self.origin, bag.origin, 0 ) )
				{
					self addgoal( bag.origin, 24, 2, "hack" );
					return;
				}
				_k162 = getNextArrayKey( _a162, _k162 );
			}
			return;
		}
		_a174 = tanks;
		_k174 = getFirstArrayKey( _a174 );
		while ( isDefined( _k174 ) )
		{
			tank = _a174[ _k174 ];
			if ( isDefined( tank.owner ) && tank.owner == self )
			{
			}
			else
			{
				if ( tank.isstunned )
				{
					break;
				}
				else
				{
					if ( self throwgrenade( "emp_grenade_mp", tank.origin ) )
					{
						self waittill( "grenade_fire" );
						goal = self bot_hack_tank_get_goal_origin( tank );
						if ( isDefined( goal ) )
						{
							self addgoal( goal, 24, 3, "hack" );
							wait 0,5;
							return;
						}
					}
				}
			}
			_k174 = getNextArrayKey( _a174, _k174 );
		}
	}
}
