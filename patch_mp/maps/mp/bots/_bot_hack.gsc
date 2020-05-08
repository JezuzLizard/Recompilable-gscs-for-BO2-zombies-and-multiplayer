#include maps/mp/bots/_bot;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/ctf;

bot_hack_tank_get_goal_origin( tank ) //checked changed to match cerberus output
{
	nodes = getnodesinradiussorted( tank.origin, 256, 0, 64, "Path" );
	foreach ( node in nodes )
	{
		dir = vectornormalize( node.origin - tank.origin );
		dir = vectorScale( dir, 32 );
		goal = tank.origin + dir;
		if ( findpath( self.origin, goal, 0 ) )
		{
			return goal;
		}
	}
	return undefined;
}

bot_hack_has_goal( tank ) //checked matches cerberus output
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

bot_hack_at_goal() //checked changed to match cerberus output
{
	if ( self atgoal( "hack" ) )
	{
		return 1;
	}
	goal = self getgoal( "hack" );
	if ( isDefined( goal ) )
	{
		tanks = getentarray( "talon", "targetname" );
		tanks = arraysort( tanks, self.origin );
		foreach ( tank in tanks )
		{
			if ( distancesquared( goal, tank.origin ) < 16384 )
			{
				if ( isDefined( tank.trigger ) && self istouching( tank.trigger ) )
				{
					return 1;
				}
			}
		}
	}
	return 0;
}

bot_hack_goal_pregame( tanks ) //checked partially changed to match cerberus output did not use foreach see github for more info
{
	i = 0;
	while ( i < tanks.size )
	{
		if ( isDefined( tanks[ i ].owner ) )
		{
			i++;
			continue;
		}
		if ( isDefined( tanks[ i ].team ) && tanks[ i ].team == self.team )
		{
			i++;
			continue;
		}
		goal = self bot_hack_tank_get_goal_origin( tanks[ i ] );
		if ( isDefined( goal ) )
		{
			if ( self addgoal( goal, 24, 2, "hack" ) )
			{
				self.goal_flag = tanks[ i ];
				return;
			}
		}
		i++;
	}
}

bot_hack_think() //checked partially changed to match cerberus output did not us foreach see github for more info
{
	if ( bot_hack_at_goal() )
	{
		self setstance( "crouch" );
		wait 0.25;
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
	i = 0;
	while ( i < tanks.size )
	{
		if ( isDefined( tanks[ i ].owner ) && tanks[ i ].owner == self )
		{
			i++;
			continue;
		}
		if ( !isDefined( tanks[ i ].owner ) )
		{
			if ( self bot_hack_has_goal( tanks[ i ] ) )
			{
				return;
			}
			goal = self bot_hack_tank_get_goal_origin( tanks[ i ] );
			if ( isDefined( goal ) )
			{
				self addgoal( goal, 24, 2, "hack" );
				return;
			}
		}
		if ( tanks[ i ].isstunned && distancesquared( self.origin, tanks[ i ].origin ) < 262144 )
		{
			goal = self bot_hack_tank_get_goal_origin( tanks[ i ] );
			if ( isDefined( goal ) )
			{
				self addgoal( goal, 24, 3, "hack" );
				return;
			}
		}
		i++;
	}
	if ( !maps/mp/bots/_bot::bot_vehicle_weapon_ammo( "emp_grenade_mp" ) )
	{
		ammo = getentarray( "weapon_scavenger_item_hack_mp", "classname" );
		ammo = arraysort( ammo, self.origin );
		foreach ( bag in ammo )
		{
			if ( findpath( self.origin, bag.origin, 0 ) )
			{
				self addgoal( bag.origin, 24, 2, "hack" );
				return;
			}
		}
		return;
	}
	i = 0;
	while ( i < tanks.size )
	{
		if ( isDefined( tanks[ i ].owner ) && tanks[ i ].owner == self )
		{
			i++;
			continue;
		}
		if ( tanks[ i ].isstunned )
		{
			i++;
			continue;
		}
		if ( self throwgrenade( "emp_grenade_mp", tanks[ i ].origin ) )
		{
			self waittill( "grenade_fire" );
			goal = self bot_hack_tank_get_goal_origin( tanks[ i ] );
			if ( isDefined( goal ) )
			{
				self addgoal( goal, 24, 3, "hack" );
				wait 0.5;
				return;
			}
		}
		i++;
	}
}

