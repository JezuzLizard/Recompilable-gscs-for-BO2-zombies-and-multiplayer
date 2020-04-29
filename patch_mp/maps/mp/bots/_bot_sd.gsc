#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/bots/_bot_combat;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/_utility;
#include common_scripts/utility;

bot_sd_think()
{
	_a8 = level.bombzones;
	_k8 = getFirstArrayKey( _a8 );
	while ( isDefined( _k8 ) )
	{
		zone = _a8[ _k8 ];
		if ( !isDefined( zone.nearest_node ) )
		{
			nodes = getnodesinradiussorted( zone.trigger.origin, 256, 0 );
/#
			assert( nodes.size );
#/
			zone.nearest_node = nodes[ 0 ];
		}
		_k8 = getNextArrayKey( _a8, _k8 );
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

bot_sd_attacker()
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
				wait 0,5;
				self pressusebutton( level.planttime + 1 );
				wait 0,5;
				if ( is_true( self.isplanting ) )
				{
					wait ( level.planttime + 1 );
				}
				self pressusebutton( 0 );
				self setstance( "crouch" );
				wait 0,25;
				self cancelgoal( "sd_plant" );
				self setstance( "stand" );
			}
			return;
		}
		else
		{
			if ( getTime() > self.bot[ "patrol_update" ] )
			{
				frac = sd_get_time_frac();
				if ( randomint( 100 ) < ( frac * 100 ) || frac > 0,85 )
				{
					zone = sd_get_closest_bomb();
					goal = sd_get_bomb_goal( zone.visuals[ 0 ] );
					if ( isDefined( goal ) )
					{
						if ( frac > 0,85 )
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
	}
	else
	{
		if ( isDefined( level.sdbomb.carrier ) && !isplayer( level.sdbomb.carrier ) )
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
}

bot_sd_defender( zone, isplanted )
{
	bot_sd_grenade();
	while ( isDefined( isplanted ) && isplanted && self hasgoal( "sd_defend" ) )
	{
		goal = self getgoal( "sd_defend" );
		planted = sd_get_planted_zone();
		_a159 = level.bombzones;
		_k159 = getFirstArrayKey( _a159 );
		while ( isDefined( _k159 ) )
		{
			zone = _a159[ _k159 ];
			if ( planted != zone && distance2d( goal, zone.nearest_node.origin ) < distance2d( goal, planted.nearest_node.origin ) )
			{
				self cancelgoal( "sd_defend" );
			}
			_k159 = getNextArrayKey( _a159, _k159 );
		}
	}
	if ( self atgoal( "sd_defend" ) || self bot_need_to_defuse() )
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
	_a208 = nodes;
	_k208 = getFirstArrayKey( _a208 );
	while ( isDefined( _k208 ) )
	{
		node = _a208[ _k208 ];
		if ( node.type == "BAD NODE" )
		{
		}
		else if ( !canclaimnode( node, self.team ) )
		{
		}
		else if ( distancesquared( node.origin, self.origin ) < 65536 )
		{
		}
		else if ( self maps/mp/bots/_bot::bot_friend_goal_in_radius( "sd_defend", node.origin, 256 ) > 0 )
		{
		}
		else
		{
			height = node.origin[ 2 ] - zone.nearest_node.origin[ 2 ];
			if ( isDefined( isplanted ) && isplanted )
			{
				dist = distance2d( node.origin, zone.nearest_node.origin );
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
		}
		_k208 = getNextArrayKey( _a208, _k208 );
	}
	if ( !isDefined( best ) )
	{
		return;
	}
	self addgoal( best, 24, 3, "sd_defend" );
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

bot_sd_defender_think( zone )
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
			wait 0,5;
			self pressusebutton( level.defusetime + 1 );
			wait 0,5;
			if ( is_true( self.isdefusing ) )
			{
				wait ( level.defusetime + 1 );
			}
			self pressusebutton( 0 );
			self setstance( "crouch" );
			wait 0,25;
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

bot_need_to_defuse()
{
	if ( level.bombplanted )
	{
		return self.team == game[ "defenders" ];
	}
}

sd_get_bomb_goal( ent )
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
	_a419 = goals;
	_k419 = getFirstArrayKey( _a419 );
	while ( isDefined( _k419 ) )
	{
		goal = _a419[ _k419 ];
		if ( findpath( self.origin, goal, 0 ) )
		{
			return goal;
		}
		_k419 = getNextArrayKey( _a419, _k419 );
	}
	return undefined;
}

sd_get_time_frac()
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

sd_get_closest_bomb()
{
	best = undefined;
	distsq = 9999999;
	_a450 = level.bombzones;
	_k450 = getFirstArrayKey( _a450 );
	while ( isDefined( _k450 ) )
	{
		zone = _a450[ _k450 ];
		d = distancesquared( self.origin, zone.curorigin );
		if ( !isDefined( best ) )
		{
			best = zone;
			distsq = d;
		}
		else
		{
			if ( d < distsq )
			{
				best = zone;
				distsq = d;
			}
		}
		_k450 = getNextArrayKey( _a450, _k450 );
	}
	return best;
}

sd_get_planted_zone()
{
	while ( level.bombplanted )
	{
		_a475 = level.bombzones;
		_k475 = getFirstArrayKey( _a475 );
		while ( isDefined( _k475 ) )
		{
			zone = _a475[ _k475 ];
			if ( zone.interactteam == "none" )
			{
				return zone;
			}
			_k475 = getNextArrayKey( _a475, _k475 );
		}
	}
	return undefined;
}

bot_sd_grenade()
{
	enemies = bot_get_enemies();
	if ( !enemies.size )
	{
		return;
	}
	zone = sd_get_closest_bomb();
	_a498 = enemies;
	_k498 = getFirstArrayKey( _a498 );
	while ( isDefined( _k498 ) )
	{
		enemy = _a498[ _k498 ];
		if ( distancesquared( enemy.origin, zone.nearest_node.origin ) < 147456 )
		{
			if ( !self maps/mp/bots/_bot_combat::bot_combat_throw_lethal( enemy.origin ) )
			{
				self maps/mp/bots/_bot_combat::bot_combat_throw_tactical( enemy.origin );
			}
			return;
		}
		_k498 = getNextArrayKey( _a498, _k498 );
	}
}
