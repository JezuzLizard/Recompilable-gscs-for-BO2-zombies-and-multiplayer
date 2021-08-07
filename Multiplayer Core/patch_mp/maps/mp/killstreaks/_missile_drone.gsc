#include maps/mp/_challenges;
#include maps/mp/_scoreevents;
#include maps/mp/killstreaks/_dogs;
#include maps/mp/killstreaks/_missile_swarm;
#include maps/mp/_popups;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_airsupport;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/_utility;

#using_animtree( "mp_missile_drone" );

init()
{
	registerclientfield( "toplayer", "missile_drone_active", 1, 2, "int" );
	registerclientfield( "missile", "missile_drone_projectile_active", 1, 1, "int" );
	registerclientfield( "missile", "missile_drone_projectile_animate", 1, 1, "int" );
	level.missile_drone_flyheight = 2400;
	level.missile_drone_anim = %o_drone_hunter_launch;
	precacheitem( "missile_drone_projectile_mp" );
	loadfx( "weapon/missile/fx_missile_drone_light_red" );
	registerkillstreak( "inventory_missile_drone_mp", "inventory_missile_drone_mp", "killstreak_missile_drone", "missile_drone_used", ::missile_drone_killstreak, 1 );
	registerkillstreakstrings( "inventory_missile_drone_mp", &"KILLSTREAK_EARNED_MISSILE_DRONE", &"KILLSTREAK_MISSILE_DRONE_NOT_AVAILABLE", &"KILLSTREAK_MISSILE_DRONE_INBOUND" );
	registerkillstreakdialog( "inventory_missile_drone_mp", "mpl_killstreak_missile_drone", "kls_hkdrone_used", "", "kls_hkdrone_enemy", "", "kls_hkdrone_ready" );
	registerkillstreakdevdvar( "inventory_missile_drone_mp", "scr_givemissiledrone" );
	registerkillstreak( "missile_drone_mp", "missile_drone_mp", "killstreak_missile_drone", "missile_drone_used", ::missile_drone_killstreak, 1 );
	registerkillstreakaltweapon( "missile_drone_mp", "missile_drone_projectile_mp" );
	registerkillstreakaltweapon( "inventory_missile_drone_mp", "missile_drone_projectile_mp" );
	registerkillstreakstrings( "missile_drone_mp", &"KILLSTREAK_EARNED_MISSILE_DRONE", &"KILLSTREAK_MISSILE_DRONE_NOT_AVAILABLE", &"KILLSTREAK_MISSILE_DRONE_INBOUND" );
	registerkillstreakdialog( "missile_drone_mp", "mpl_killstreak_missile_drone", "kls_hkdrone_used", "", "kls_hkdrone_enemy", "", "kls_hkdrone_ready" );
	setkillstreakteamkillpenaltyscale( "missile_drone_mp", 0 );
}

missile_drone_killstreak( weaponname )
{
/#
	if ( weaponname != "missile_drone_mp" )
	{
		assert( weaponname == "inventory_missile_drone_mp" );
	}
#/
	level.missile_drone_origin = level.mapcenter + ( 0, 0, level.missile_drone_flyheight );
	hardpointtype = "missile_drone_mp";
	result = usemissiledrone( hardpointtype );
	if ( !isDefined( result ) || !result )
	{
		return 0;
	}
	return result;
}

usemissiledrone( hardpointtype )
{
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	self thread missiledronewatcher( hardpointtype );
	missileweapon = self getcurrentweapon();
	missileweapon = undefined;
	currentweapon = self getcurrentweapon();
	if ( ismissiledroneweapon( currentweapon ) )
	{
		missileweapon = currentweapon;
	}
/#
	assert( isDefined( missileweapon ) );
#/
	notifystring = self waittill_any_return( "weapon_change", "grenade_fire", "death" );
	if ( notifystring == "weapon_change" || notifystring == "death" )
	{
		return 0;
	}
	notifystring = self waittill_any_return( "weapon_change", "death" );
	if ( notifystring == "death" )
	{
		return 1;
	}
	if ( !isDefined( missileweapon ) )
	{
		return 0;
	}
	self takeweapon( missileweapon );
	if ( self hasweapon( missileweapon ) || self getammocount( missileweapon ) )
	{
		return 0;
	}
	return 1;
}

ismissiledroneweapon( weapon )
{
	if ( weapon == "missile_drone_mp" || weapon == "inventory_missile_drone_mp" )
	{
		return 1;
	}
	return 0;
}

missiledronewatcher( hardpointtype )
{
	self notify( "missileDroneWatcher" );
	self endon( "missileDroneWatcher" );
	self endon( "spawned_player" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	self endon( "death" );
	team = self.team;
	killstreak_id = maps/mp/killstreaks/_killstreakrules::killstreakstart( hardpointtype, team, 0, 0 );
	if ( killstreak_id == -1 )
	{
		self maps/mp/killstreaks/_killstreaks::switchtolastnonkillstreakweapon();
		return;
	}
	self thread checkforemp();
	self thread checkweaponchange( hardpointtype, team, killstreak_id );
	self thread watchownerdeath( hardpointtype, team, killstreak_id );
	self thread updatetargetting();
	self waittill( "grenade_fire", grenade, weapname );
	origin = grenade.origin;
	self notify( "missile_drone_active" );
	level thread maps/mp/_popups::displaykillstreakteammessagetoall( hardpointtype, self );
	self maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( hardpointtype, self.team, 1 );
	level.globalkillstreakscalled++;
	self addweaponstat( "missile_drone_mp", "used", 1 );
	self setclientfieldtoplayer( "missile_drone_active", 0 );
	grenade thread waitthendelete( 0,05 );
	grenade.origin += vectorScale( ( 0, 0, 1 ), 1000 );
	self thread domissiledrone( origin, weapname, killstreak_id, hardpointtype, team );
	self maps/mp/killstreaks/_killstreaks::switchtolastnonkillstreakweapon();
}

domissiledrone( origin, weapname, killstreak_id, hardpointtype, team )
{
	direction = self getplayerangles();
	forward = anglesToForward( direction );
	target = origin + vectorScale( forward, 10000 );
	debug_line( origin, target, ( 0,9, 0,1, 0,1 ) );
	projectile = maps/mp/killstreaks/_missile_swarm::projectile_spawn_utility( self, target, origin, "missile_drone_projectile_mp", "drone_missile", 0 );
	projectile missile_dronesetvisible( 1 );
	projectile.originaltarget = target;
	projectile thread maps/mp/killstreaks/_missile_swarm::projectile_abort_think();
	projectile thread drone_target_search( hardpointtype );
	projectile thread projectile_death_think();
	projectile thread watchdamage();
	projectile.targetname = "remote_drone";
	projectile playsound( "wpn_hunter_ignite" );
	projectile thread killstreak_stop_think( killstreak_id, hardpointtype, team );
	projectile setclientfield( "missile_drone_projectile_animate", 1 );
}

waitthendelete( waittime )
{
	self endon( "delete" );
	self endon( "death" );
	wait waittime;
	self delete();
}

projectile_death_think()
{
	self waittill( "death" );
	self.goal delete();
}

drone_target_acquired( hardpointtype, target )
{
	self endon( "death" );
	self notify( "drone_target_acquired" );
	self setclientfield( "missile_drone_projectile_active", 1 );
	self set_drone_target( hardpointtype, target );
}

drone_target_search( hardpointtype )
{
	self endon( "death" );
	if ( isDefined( self.dronetarget ) )
	{
		self drone_target_acquired( hardpointtype, self.dronetarget );
		self missile_settarget( self.goal );
	}
	self setclientfield( "missile_drone_projectile_active", 0 );
	searchdotprodminimums = [];
	searchdotprodminimums[ 0 ] = 0,9;
	searchdotprodminimums[ 1 ] = 0,7071;
	searchdotprodminimums[ 2 ] = 0,5;
	searchdotprodminimums[ 3 ] = 0;
	wait 0,1;
	searchcounter = 0;
	for ( ;; )
	{
		if ( !isDefined( self ) )
		{
			self notify( "death" );
		}
		target = self projectile_find_target( self.owner, searchdotprodminimums[ searchcounter ] );
		if ( searchcounter < ( searchdotprodminimums.size - 1 ) )
		{
			searchcounter++;
		}
		else if ( level.missile_drone_origin[ 2 ] != self.goal.origin[ 2 ] )
		{
			currentangles = self.angles;
			direction = vectornormalize( anglesToForward( self.angles ) );
			direction = vecscale( direction, 1024 );
			self.goal.origin = ( self.origin[ 0 ] + direction[ 0 ], self.origin[ 1 ] + direction[ 1 ], level.missile_drone_origin[ 2 ] );
/#
			debug_line( self.origin, self.goal.origin, ( 0, 0, 1 ), 5000 );
#/
		}
		else
		{
			currentangles = self.angles;
			direction = vectornormalize( anglesToForward( self.angles ) );
			direction = vecscale( direction, 1024 );
			self.goal.origin = ( level.missile_drone_origin[ 0 ] + direction[ 0 ], level.missile_drone_origin[ 1 ] + direction[ 1 ], level.missile_drone_origin[ 2 ] );
/#
			debug_line( self.origin, self.goal.origin, ( 0, 1, 1 ), 5000 );
#/
		}
		if ( isDefined( target ) )
		{
			self set_drone_target( hardpointtype, target );
			self missile_settarget( self.goal );
		}
		wait 0,25;
	}
}

vecscale( vec, scalar )
{
	return ( vec[ 0 ] * scalar, vec[ 1 ] * scalar, vec[ 2 ] * scalar );
}

set_drone_target( hardpointtype, target )
{
	self endon( "target_lost" );
	self thread check_target_lost( target );
	self.swarm_target = target[ "entity" ];
	target[ "entity" ].swarm = self;
	debug_line( self.origin, target[ "entity" ].origin, ( 0, 0, 1 ), 5000 );
	self missile_settarget( target[ "entity" ], target[ "offset" ] );
	self playsound( "veh_harpy_drone_swarm_incomming" );
	if ( !isDefined( target[ "entity" ].swarmsound ) || target[ "entity" ].swarmsound == 0 )
	{
		self thread target_sounds( target[ "entity" ] );
	}
	target[ "entity" ] notify( "stinger_fired_at_me" );
	self setclientfield( "missile_drone_projectile_active", 1 );
	target[ "entity" ] waittill_any( "death", "disconnect", "joined_team" );
	self setclientfield( "missile_drone_projectile_active", 0 );
	self missile_settarget( self.goal );
}

check_target_lost( target )
{
	self endon( "death" );
	target[ "entity" ] endon( "death" );
	target[ "entity" ] endon( "disconnect" );
	target[ "entity" ] endon( "joined_team" );
	failurelimit = 3;
	failurecount = 0;
	for ( ;; )
	{
/#
		debug_star( target[ "entity" ].origin, ( 0, 0, 1 ), 1000 );
		debug_star( self.origin, ( 0, 0, 1 ), 1000 );
#/
		if ( bullettracepassed( self.origin, target[ "entity" ].origin + target[ "offset" ], 0, target[ "entity" ] ) )
		{
/#
			debug_line( self.origin, target[ "entity" ].origin, ( 0, 0, 1 ), 1000 );
#/
			failurecount = 0;
		}
		else
		{
			failurecount++;
			if ( failurecount >= failurelimit )
			{
				self notify( "target_lost" );
				return;
			}
		}
		wait 0,25;
	}
}

projectile_find_target( owner, mincos )
{
	ks = self projectile_find_target_killstreak( owner, mincos );
	player = self projectile_find_target_player( owner, mincos );
	if ( isDefined( ks ) && !isDefined( player ) )
	{
		return ks;
	}
	else
	{
		if ( !isDefined( ks ) && isDefined( player ) )
		{
			return player;
		}
		else
		{
			if ( isDefined( ks ) && isDefined( player ) )
			{
				if ( player[ "dotprod" ] < ks[ "dotprod" ] )
				{
					return ks;
				}
				return player;
			}
		}
	}
	return undefined;
}

projectile_find_target_killstreak( owner, mincos )
{
	ks = [];
	ks[ "offset" ] = vectorScale( ( 0, 0, 1 ), 10 );
	targets = target_getarray();
	rcbombs = getentarray( "rcbomb", "targetname" );
	dogs = maps/mp/killstreaks/_dogs::dog_manager_get_dogs();
	targets = arraycombine( targets, rcbombs, 1, 0 );
	targets = arraycombine( targets, dogs, 1, 0 );
	if ( targets.size <= 0 )
	{
		return undefined;
	}
	targets = get_array_sorted_dot_prod( targets, mincos );
	_a389 = targets;
	_k389 = getFirstArrayKey( _a389 );
	while ( isDefined( _k389 ) )
	{
		target = _a389[ _k389 ];
		if ( isDefined( target.owner ) && target.owner == owner )
		{
		}
		else
		{
			if ( isDefined( target.script_owner ) && target.script_owner == owner )
			{
				break;
			}
			else
			{
				if ( level.teambased && isDefined( target.team ) )
				{
					if ( target.team == self.team )
					{
						break;
					}
				}
				else if ( level.teambased && isDefined( target.aiteam ) )
				{
					if ( target.aiteam == self.team )
					{
						break;
					}
				}
				else if ( isDefined( target.vehicletype ) && target.vehicletype == "heli_supplydrop_mp" )
				{
					break;
				}
				else
				{
					if ( bullettracepassed( self.origin, target.origin, 0, target ) )
					{
						ks[ "entity" ] = target;
						if ( isDefined( target.sorteddotprod ) )
						{
							ks[ "dotprod" ] = target.sorteddotprod;
						}
						else
						{
							ks[ "dotprod" ] = -1;
						}
						return ks;
					}
				}
			}
		}
		_k389 = getNextArrayKey( _a389, _k389 );
	}
	return undefined;
}

projectile_find_target_player( owner, mincos )
{
	target = [];
	players = self get_array_sorted_dot_prod( get_players(), mincos );
	if ( isplayer( self ) )
	{
		startoffset = self getplayerviewheight();
		startorigin = ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + startoffset );
		startangles = self getplayerangles();
/#
		debug_star( startorigin, ( 0, 0, 1 ), 1000 );
#/
	}
	else
	{
		startorigin = self.origin;
		startangles = self.angles;
	}
	bestplayerrating = -1;
	_a470 = players;
	_k470 = getFirstArrayKey( _a470 );
	while ( isDefined( _k470 ) )
	{
		player = _a470[ _k470 ];
		if ( !player_valid_target( player, owner.team, owner ) )
		{
		}
		else
		{
			currentplayeroffset = undefined;
			currentplayerdotprod = undefined;
			currentplayerrating = 0;
/#
			debug_star( player.origin, ( 0, 0, 1 ), 1000 );
#/
			if ( bullettracepassed( startorigin, player.origin, 0, player ) )
			{
/#
				debug_line( startorigin, player.origin, ( 0, 0, 1 ), 1000 );
#/
				if ( !isDefined( currentplayeroffset ) )
				{
					currentplayeroffset = ( 0, 0, 1 );
				}
				currentplayerrating += 4;
			}
			verticaloffset = player getplayerviewheight();
			playerheadoffset = ( 0, 0, verticaloffset );
/#
			debug_star( player.origin + playerheadoffset, ( 0, 0, 1 ), 1000 );
#/
			if ( bullettracepassed( startorigin, player.origin + playerheadoffset, 0, player ) )
			{
/#
				debug_line( startorigin, player.origin + playerheadoffset, ( 0, 0, 1 ), 1000 );
#/
				if ( !isDefined( currentplayeroffset ) )
				{
					currentplayeroffset = playerheadoffset;
				}
				currentplayerrating += 3;
			}
			end = player.origin + playerheadoffset + vectorScale( ( 0, 0, 1 ), 96 );
/#
			debug_star( end, ( 0, 0, 1 ), 1000 );
#/
			if ( bullettracepassed( player.origin + playerheadoffset, end, 0, player ) )
			{
/#
				debug_line( player.origin + playerheadoffset, end, ( 0, 0, 1 ), 1000 );
#/
				if ( !isDefined( currentplayeroffset ) )
				{
					currentplayeroffset = vectorScale( ( 0, 0, 1 ), 30 );
				}
				currentplayerrating += 2;
			}
			if ( currentplayerrating > bestplayerrating )
			{
				bestplayerrating = currentplayerrating;
				target[ "entity" ] = player;
				target[ "offset" ] = currentplayeroffset;
				if ( isDefined( player.sorteddotprod ) )
				{
					target[ "dotprod" ] = player.sorteddotprod;
				}
				else
				{
					target[ "dotprod" ] = -1;
				}
				if ( bestplayerrating >= 9 )
				{
					return target;
				}
			}
		}
		_k470 = getNextArrayKey( _a470, _k470 );
	}
	if ( bestplayerrating >= 3 )
	{
		return target;
	}
	return undefined;
}

killstreak_stop_think( killstreak_id, hardpointtype, team )
{
	self waittill( "death" );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( hardpointtype, team, killstreak_id );
}

checkweaponchange( hardpointtype, team, killstreak_id )
{
	self endon( "spawned_player" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );
	self waittill( "weapon_change" );
	self setclientfieldtoplayer( "missile_drone_active", 0 );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( hardpointtype, team, killstreak_id );
}

watchownerdeath( hardpointtype, team, killstreak_id )
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	self endon( "missile_drone_active" );
	self waittill( "death" );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( hardpointtype, team, killstreak_id );
}

checkforemp()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	self endon( "death" );
	self endon( "grenade_fire" );
	self waittill( "emp_jammed" );
	self setclientfieldtoplayer( "missile_drone_active", 0 );
	self maps/mp/killstreaks/_killstreaks::switchtolastnonkillstreakweapon();
}

watchdamage()
{
	self endon( "death" );
	self setcandamage( 1 );
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( !isDefined( attacker ) || !isplayer( attacker ) )
		{
			continue;
		}
		else
		{
			if ( isplayer( attacker ) && level.teambased && isDefined( attacker.team ) && self.team == attacker.team && level.friendlyfire == 0 )
			{
				break;
			}
			else
			{
				if ( self.owner isenemyplayer( attacker ) )
				{
					maps/mp/_scoreevents::processscoreevent( "destroyed_missile_drone", attacker, self.owner, weaponname );
					attacker maps/mp/_challenges::addflyswatterstat( weaponname, self );
					break;
				}
				self detonate();
			}
		}
	}
}

get_array_sorted_dot_prod( array, mincos )
{
	if ( isplayer( self ) )
	{
		org = self.origin;
		angles = self getplayerangles();
/#
		assert( isDefined( angles ) );
#/
	}
	else
	{
		org = self.origin;
/#
		assert( isDefined( self.angles ) );
#/
		angles = self.angles;
	}
	forwardvec = vectornormalize( anglesToForward( angles ) );
	dotprod = [];
	index = [];
	i = 0;
	while ( i < array.size )
	{
/#
		assert( isDefined( forwardvec ) );
#/
/#
		assert( isDefined( array[ i ] ) );
#/
/#
		assert( isDefined( array[ i ].origin ) );
#/
/#
		assert( isDefined( org ) );
#/
		cosa = vectordot( forwardvec, vectornormalize( array[ i ].origin - org ) );
/#
		assert( isDefined( cosa ) );
#/
		if ( isDefined( mincos ) && cosa < mincos )
		{
			i++;
			continue;
		}
		else
		{
			array[ i ].sorteddotprod = cosa;
			dotprod[ dotprod.size ] = cosa;
			index[ index.size ] = i;
		}
		i++;
	}
	for ( ;; )
	{
		change = 0;
		i = 0;
		while ( i < ( dotprod.size - 1 ) )
		{
			if ( dotprod[ i ] >= dotprod[ i + 1 ] )
			{
				i++;
				continue;
			}
			else
			{
				change = 1;
				temp = dotprod[ i ];
				dotprod[ i ] = dotprod[ i + 1 ];
				dotprod[ i + 1 ] = temp;
				temp = index[ i ];
				index[ i ] = index[ i + 1 ];
				index[ i + 1 ] = temp;
			}
			i++;
		}
		if ( !change )
		{
			break;
		}
		else
		{
		}
	}
	newarray = [];
	i = 0;
	while ( i < dotprod.size )
	{
		newarray[ i ] = array[ index[ i ] ];
		i++;
	}
	return newarray;
}

updatetargetting()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	self endon( "death" );
	self endon( "grenade_fire" );
	mincos = getdvarfloatdefault( "scr_missile_drone_min_cos", 0,9 );
	updatewait = getdvarfloatdefault( "scr_missile_drone_update_wait", 0,5 );
	for ( ;; )
	{
		self.dronetarget = self projectile_find_target( self, mincos );
		if ( isDefined( self.dronetarget ) )
		{
			self thread clearinvaliddronetarget();
			self setclientfieldtoplayer( "missile_drone_active", 2 );
		}
		else
		{
			self setclientfieldtoplayer( "missile_drone_active", 1 );
		}
		wait updatewait;
	}
}

clearinvaliddronetarget()
{
	self endon( "death" );
	self notify( "clearInvalidDroneTarget" );
	self endon( "clearInvalidDroneTarget" );
	self endon( "drone_target_acquired" );
	self.dronetarget[ "entity" ] waittill_any( "death", "disconnect", "joined_team" );
	self.dronetarget = undefined;
}
