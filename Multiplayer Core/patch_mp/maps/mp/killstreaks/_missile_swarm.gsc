#include maps/mp/killstreaks/_dogs;
#include maps/mp/_challenges;
#include maps/mp/_scoreevents;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_airsupport;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.missile_swarm_max = 6;
	level.missile_swarm_flyheight = 3000;
	level.missile_swarm_flydist = 5000;
	set_dvar_float_if_unset( "scr_missile_swarm_lifetime", 40 );
	precacheitem( "missile_swarm_projectile_mp" );
	level.swarm_fx[ "swarm" ] = loadfx( "weapon/harpy_swarm/fx_hrpy_swrm_os_circle_neg_x" );
	level.swarm_fx[ "swarm_tail" ] = loadfx( "weapon/harpy_swarm/fx_hrpy_swrm_exhaust_trail_close" );
	level.missiledronesoundstart = "mpl_hk_scan";
	registerkillstreak( "missile_swarm_mp", "missile_swarm_mp", "killstreak_missile_swarm", "missile_swarm_used", ::swarm_killstreak, 1 );
	registerkillstreakaltweapon( "missile_swarm_mp", "missile_swarm_projectile_mp" );
	registerkillstreakstrings( "missile_swarm_mp", &"KILLSTREAK_EARNED_MISSILE_SWARM", &"KILLSTREAK_MISSILE_SWARM_NOT_AVAILABLE", &"KILLSTREAK_MISSILE_SWARM_INBOUND" );
	registerkillstreakdialog( "missile_swarm_mp", "mpl_killstreak_missile_swarm", "kls_swarm_used", "", "kls_swarm_enemy", "", "kls_swarm_ready" );
	registerkillstreakdevdvar( "missile_swarm_mp", "scr_givemissileswarm" );
	setkillstreakteamkillpenaltyscale( "missile_swarm_mp", 0 );
	maps/mp/killstreaks/_killstreaks::createkillstreaktimer( "missile_swarm_mp" );
	registerclientfield( "world", "missile_swarm", 1, 2, "int" );
/#
	set_dvar_int_if_unset( "scr_missile_swarm_cam", 0 );
#/
}

swarm_killstreak( hardpointtype )
{
/#
	assert( hardpointtype == "missile_swarm_mp" );
#/
	level.missile_swarm_origin = level.mapcenter + ( 0, 0, level.missile_swarm_flyheight );
	if ( level.script == "mp_drone" )
	{
		level.missile_swarm_origin += ( -5000, 0, 2000 );
	}
	if ( level.script == "mp_la" )
	{
		level.missile_swarm_origin += vectorScale( ( 0, 0, 1 ), 2000 );
	}
	if ( level.script == "mp_turbine" )
	{
		level.missile_swarm_origin += vectorScale( ( 0, 0, 1 ), 1500 );
	}
	if ( level.script == "mp_downhill" )
	{
		level.missile_swarm_origin += ( 4000, 0, 1000 );
	}
	if ( level.script == "mp_hydro" )
	{
		level.missile_swarm_origin += vectorScale( ( 0, 0, 1 ), 5000 );
	}
	if ( level.script == "mp_magma" )
	{
		level.missile_swarm_origin += ( 0, -6000, 3000 );
	}
	if ( level.script == "mp_uplink" )
	{
		level.missile_swarm_origin += ( -6000, 0, 2000 );
	}
	if ( level.script == "mp_bridge" )
	{
		level.missile_swarm_origin += vectorScale( ( 0, 0, 1 ), 2000 );
	}
	if ( level.script == "mp_paintball" )
	{
		level.missile_swarm_origin += vectorScale( ( 0, 0, 1 ), 1000 );
	}
	if ( level.script == "mp_dig" )
	{
		level.missile_swarm_origin += ( -2000, -2000, 1000 );
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( "missile_swarm_mp", self.team, 0, 1 );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	level thread swarm_killstreak_start( self, killstreak_id );
	return 1;
}

swarm_killstreak_start( owner, killstreak_id )
{
	level endon( "swarm_end" );
	missiles = getentarray( "swarm_missile", "targetname" );
	_a102 = missiles;
	_k102 = getFirstArrayKey( _a102 );
	while ( isDefined( _k102 ) )
	{
		missile = _a102[ _k102 ];
		if ( isDefined( missile ) )
		{
			missile detonate();
			wait 0,1;
		}
		_k102 = getNextArrayKey( _a102, _k102 );
	}
	while ( isDefined( level.missile_swarm_fx ) )
	{
		i = 0;
		while ( i < level.missile_swarm_fx.size )
		{
			if ( isDefined( level.missile_swarm_fx[ i ] ) )
			{
				level.missile_swarm_fx[ i ] delete();
			}
			i++;
		}
	}
	level.missile_swarm_fx = undefined;
	level.missile_swarm_team = owner.team;
	level.missile_swarm_owner = owner;
	owner maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( "missile_swarm_mp", owner.pers[ "team" ] );
	level create_player_targeting_array( owner, owner.team );
	level.globalkillstreakscalled++;
	owner addweaponstat( "missile_swarm_mp", "used", 1 );
	level thread swarm_killstreak_abort( owner, killstreak_id );
	level thread swarm_killstreak_watch_for_emp( owner, killstreak_id );
	level thread swarm_killstreak_fx();
	wait 2;
	level thread swarm_think( owner, killstreak_id );
}

swarm_killstreak_end( owner, detonate, killstreak_id )
{
	level notify( "swarm_end" );
	if ( isDefined( detonate ) && detonate )
	{
		level setclientfield( "missile_swarm", 2 );
	}
	else
	{
		level setclientfield( "missile_swarm", 0 );
	}
	missiles = getentarray( "swarm_missile", "targetname" );
	if ( is_true( detonate ) )
	{
		i = 0;
		while ( i < level.missile_swarm_fx.size )
		{
			if ( isDefined( level.missile_swarm_fx[ i ] ) )
			{
				level.missile_swarm_fx[ i ] delete();
			}
			i++;
		}
		_a160 = missiles;
		_k160 = getFirstArrayKey( _a160 );
		while ( isDefined( _k160 ) )
		{
			missile = _a160[ _k160 ];
			if ( isDefined( missile ) )
			{
				missile detonate();
				wait 0,1;
			}
			_k160 = getNextArrayKey( _a160, _k160 );
		}
	}
	else _a171 = missiles;
	_k171 = getFirstArrayKey( _a171 );
	while ( isDefined( _k171 ) )
	{
		missile = _a171[ _k171 ];
		if ( isDefined( missile ) )
		{
			yaw = randomintrange( 0, 360 );
			angles = ( 0, yaw, 0 );
			forward = anglesToForward( angles );
			if ( isDefined( missile.goal ) )
			{
				missile.goal.origin = missile.origin + ( forward * level.missile_swarm_flydist * 1000 );
			}
		}
		_k171 = getNextArrayKey( _a171, _k171 );
	}
	wait 1;
	level.missile_swarm_sound stoploopsound( 2 );
	wait 2;
	level.missile_swarm_sound delete();
	recordstreakindex = level.killstreakindices[ level.killstreaks[ "missile_swarm_mp" ].menuname ];
	if ( isDefined( recordstreakindex ) )
	{
		owner recordkillstreakendevent( recordstreakindex );
	}
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "missile_swarm_mp", level.missile_swarm_team, killstreak_id );
	level.missile_swarm_owner = undefined;
	wait 4;
	missiles = getentarray( "swarm_missile", "targetname" );
	_a205 = missiles;
	_k205 = getFirstArrayKey( _a205 );
	while ( isDefined( _k205 ) )
	{
		missile = _a205[ _k205 ];
		if ( isDefined( missile ) )
		{
			missile delete();
			wait 0,1;
		}
		_k205 = getNextArrayKey( _a205, _k205 );
	}
	wait 6;
	i = 0;
	while ( i < level.missile_swarm_fx.size )
	{
		if ( isDefined( level.missile_swarm_fx[ i ] ) )
		{
			level.missile_swarm_fx[ i ] delete();
		}
		i++;
	}
}

swarm_killstreak_abort( owner, killstreak_id )
{
	level endon( "swarm_end" );
	owner waittill_any( "disconnect", "joined_team", "joined_spectators", "emp_jammed" );
	level thread swarm_killstreak_end( owner, 1, killstreak_id );
}

swarm_killstreak_watch_for_emp( owner, killstreak_id )
{
	level endon( "swarm_end" );
	owner waittill( "emp_destroyed_missile_swarm", attacker );
	maps/mp/_scoreevents::processscoreevent( "destroyed_missile_swarm", attacker, owner, "emp_mp" );
	attacker maps/mp/_challenges::addflyswatterstat( "emp_mp" );
	level thread swarm_killstreak_end( owner, 1, killstreak_id );
}

swarm_killstreak_fx()
{
	level endon( "swarm_end" );
	level.missile_swarm_fx = [];
	yaw = randomint( 360 );
	level.missile_swarm_fx[ 0 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 0 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 0 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_fx[ 1 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 1 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 1 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_fx[ 2 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 2 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 2 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_fx[ 3 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 3 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 3 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_fx[ 4 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 4 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 4 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_fx[ 5 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 5 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 5 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_fx[ 6 ] = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_fx[ 6 ] setmodel( "tag_origin" );
	level.missile_swarm_fx[ 6 ].angles = ( -90, yaw, 0 );
	level.missile_swarm_sound = spawn( "script_model", level.missile_swarm_origin );
	level.missile_swarm_sound setmodel( "tag_origin" );
	level.missile_swarm_sound.angles = ( 0, 0, 1 );
	wait 0,1;
	playfxontag( level.swarm_fx[ "swarm" ], level.missile_swarm_fx[ 0 ], "tag_origin" );
	wait 2;
	level.missile_swarm_sound playloopsound( "veh_harpy_drone_swarm_lp", 3 );
	level setclientfield( "missile_swarm", 1 );
	current = 1;
	while ( 1 )
	{
		if ( !isDefined( level.missile_swarm_fx[ current ] ) )
		{
			level.missile_swarm_fx[ current ] = spawn( "script_model", level.missile_swarm_origin );
			level.missile_swarm_fx[ current ] setmodel( "tag_origin" );
		}
		yaw = randomint( 360 );
		if ( isDefined( level.missile_swarm_fx[ current ] ) )
		{
			level.missile_swarm_fx[ current ].angles = ( -90, yaw, 0 );
		}
		wait 0,1;
		if ( isDefined( level.missile_swarm_fx[ current ] ) )
		{
			playfxontag( level.swarm_fx[ "swarm" ], level.missile_swarm_fx[ current ], "tag_origin" );
		}
		current = ( current + 1 ) % 7;
		wait 1,9;
	}
}

swarm_think( owner, killstreak_id )
{
	level endon( "swarm_end" );
	lifetime = getDvarFloat( #"4FEEA279" );
	end_time = getTime() + ( lifetime * 1000 );
	level.missile_swarm_count = 0;
	while ( getTime() < end_time )
	{
/#
		assert( level.missile_swarm_count >= 0 );
#/
		while ( level.missile_swarm_count >= level.missile_swarm_max )
		{
			wait 0,5;
		}
		count = 1;
		level.missile_swarm_count += count;
		i = 0;
		while ( i < count )
		{
			self thread projectile_spawn( owner );
			i++;
		}
		wait ( ( level.missile_swarm_count / level.missile_swarm_max ) + 0,4 );
	}
	level thread swarm_killstreak_end( owner, undefined, killstreak_id );
}

projectile_cam( player )
{
/#
	player.swarm_cam = 1;
	wait 0,05;
	forward = anglesToForward( self.angles );
	cam = spawn( "script_model", ( self.origin + vectorScale( ( 0, 0, 1 ), 300 ) ) + ( forward * -200 ) );
	cam setmodel( "tag_origin" );
	cam linkto( self );
	player camerasetposition( cam );
	player camerasetlookat( self );
	player cameraactivate( 1 );
	self waittill( "death" );
	wait 1;
	player cameraactivate( 0 );
	cam delete();
	player.swarm_cam = 0;
#/
}

projectile_goal_move()
{
	self endon( "death" );
	for ( ;; )
	{
		wait 0,25;
		while ( distancesquared( self.origin, self.goal.origin ) < 65536 )
		{
			if ( distancesquared( self.origin, level.missile_swarm_origin ) > ( level.missile_swarm_flydist * level.missile_swarm_flydist ) )
			{
				self.goal.origin = level.missile_swarm_origin;
				break;
			}
			else
			{
				enemy = projectile_find_random_player( self.owner, self.team );
				if ( isDefined( enemy ) )
				{
					self.goal.origin = enemy.origin + ( 0, 0, self.origin[ 2 ] );
				}
				else
				{
					pitch = randomintrange( -45, 45 );
					yaw = randomintrange( 0, 360 );
					angles = ( 0, yaw, 0 );
					forward = anglesToForward( angles );
					self.goal.origin = self.origin + ( forward * level.missile_swarm_flydist );
				}
				nfz = crossesnoflyzone( self.origin, self.goal.origin );
				tries = 20;
				while ( isDefined( nfz ) && tries > 0 )
				{
					tries--;

					pitch = randomintrange( -45, 45 );
					yaw = randomintrange( 0, 360 );
					angles = ( 0, yaw, 0 );
					forward = anglesToForward( angles );
					self.goal.origin = self.origin + ( forward * level.missile_swarm_flydist );
					nfz = crossesnoflyzone( self.origin, self.goal.origin );
				}
			}
		}
	}
}

projectile_target_search( acceptskyexposure, acquiretime, allowplayeroffset )
{
	self endon( "death" );
	wait acquiretime;
	for ( ;; )
	{
		wait randomfloatrange( 0,5, 1 );
		target = self projectile_find_target( acceptskyexposure );
		if ( isDefined( target ) )
		{
			self.swarm_target = target[ "entity" ];
			target[ "entity" ].swarm = self;
			if ( allowplayeroffset )
			{
				self missile_settarget( target[ "entity" ], target[ "offset" ] );
				self missile_dronesetvisible( 1 );
			}
			else
			{
				self missile_settarget( target[ "entity" ] );
				self missile_dronesetvisible( 1 );
			}
			self playsound( "veh_harpy_drone_swarm_incomming" );
			if ( !isDefined( target[ "entity" ].swarmsound ) || target[ "entity" ].swarmsound == 0 )
			{
				self thread target_sounds( target[ "entity" ] );
			}
			target[ "entity" ] waittill_any( "death", "disconnect", "joined_team" );
			self missile_settarget( self.goal );
			self missile_dronesetvisible( 0 );
			break;
		}
	}
}

target_sounds( targetent )
{
	targetent endon( "death" );
	targetent endon( "disconnect" );
	targetent endon( "joined_team" );
	self endon( "death" );
	dist = 3000;
	if ( isDefined( self.warningsounddist ) )
	{
		dist = self.warningsounddist;
	}
	while ( distancesquared( self.origin, targetent.origin ) > ( dist * dist ) )
	{
		wait 0,05;
	}
	if ( isDefined( targetent.swarmsound ) && targetent.swarmsound == 1 )
	{
		return;
	}
	targetent.swarmsound = 1;
	self thread reset_sound_blocker( targetent );
	self thread target_stop_sounds( targetent );
	if ( isplayer( targetent ) )
	{
		targetent playlocalsound( level.missiledronesoundstart );
	}
	self playsound( level.missiledronesoundstart );
}

target_stop_sounds( targetent )
{
	targetent waittill_any( "disconnect", "death", "joined_team" );
	if ( isDefined( targetent ) && isplayer( targetent ) )
	{
		targetent stoplocalsound( level.missiledronesoundstart );
	}
}

reset_sound_blocker( target )
{
	wait 2;
	if ( isDefined( target ) )
	{
		target.swarmsound = 0;
	}
}

projectile_spawn( owner )
{
	level endon( "swarm_end" );
	upvector = ( 0, 0, randomintrange( level.missile_swarm_flyheight - 1500, level.missile_swarm_flyheight - 1000 ) );
	yaw = randomintrange( 0, 360 );
	angles = ( 0, yaw, 0 );
	forward = anglesToForward( angles );
	origin = ( level.mapcenter + upvector ) + ( forward * level.missile_swarm_flydist * -1 );
	target = ( level.mapcenter + upvector ) + ( forward * level.missile_swarm_flydist );
	enemy = projectile_find_random_player( owner, owner.team );
	if ( isDefined( enemy ) )
	{
		target = enemy.origin + upvector;
	}
	projectile = projectile_spawn_utility( owner, target, origin, "missile_swarm_projectile_mp", "swarm_missile", 1 );
	projectile thread projectile_abort_think();
	projectile thread projectile_target_search( cointoss(), 1, 1 );
	projectile thread projectile_death_think();
	projectile thread projectile_goal_move();
	wait 0,1;
	if ( isDefined( projectile ) )
	{
		projectile setclientfield( "missile_drone_projectile_animate", 1 );
	}
}

projectile_spawn_utility( owner, target, origin, weapon, targetname, movegoal )
{
	goal = spawn( "script_model", target );
	goal setmodel( "tag_origin" );
	p = magicbullet( weapon, origin, target, owner, goal );
	p.owner = owner;
	p.team = owner.team;
	p.goal = goal;
	p.targetname = "swarm_missile";
/#
	if ( !is_true( owner.swarm_cam ) && getDvarInt( #"492656A6" ) == 1 )
	{
		p thread projectile_cam( owner );
#/
	}
	return p;
}

projectile_death_think()
{
	self waittill( "death" );
	level.missile_swarm_count--;

	self.goal delete();
}

projectile_abort_think()
{
	self endon( "death" );
	self.owner waittill_any( "disconnect", "joined_team" );
	self detonate();
}

projectile_find_target( acceptskyexposure )
{
	ks = projectile_find_target_killstreak( acceptskyexposure );
	player = projectile_find_target_player( acceptskyexposure );
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
				if ( cointoss() )
				{
					return ks;
				}
				return player;
			}
		}
	}
	return undefined;
}

projectile_find_target_killstreak( acceptskyexposure )
{
	ks = [];
	ks[ "offset" ] = vectorScale( ( 0, 0, 1 ), 10 );
	targets = target_getarray();
	rcbombs = getentarray( "rcbomb", "targetname" );
	satellites = getentarray( "satellite", "targetname" );
	dogs = maps/mp/killstreaks/_dogs::dog_manager_get_dogs();
	targets = arraycombine( targets, rcbombs, 1, 0 );
	targets = arraycombine( targets, satellites, 1, 0 );
	targets = arraycombine( targets, dogs, 1, 0 );
	if ( targets.size <= 0 )
	{
		return undefined;
	}
	targets = arraysort( targets, self.origin );
	_a634 = targets;
	_k634 = getFirstArrayKey( _a634 );
	while ( isDefined( _k634 ) )
	{
		target = _a634[ _k634 ];
		if ( isDefined( target.owner ) && target.owner == self.owner )
		{
		}
		else
		{
			if ( isDefined( target.script_owner ) && target.script_owner == self.owner )
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
				else
				{
					if ( bullettracepassed( self.origin, target.origin, 0, target ) )
					{
						ks[ "entity" ] = target;
						return ks;
					}
					if ( acceptskyexposure && cointoss() )
					{
						end = target.origin + vectorScale( ( 0, 0, 1 ), 2048 );
						if ( bullettracepassed( target.origin, end, 0, target ) )
						{
							ks[ "entity" ] = target;
							return ks;
						}
					}
				}
			}
		}
		_k634 = getNextArrayKey( _a634, _k634 );
	}
	return undefined;
}

projectile_find_target_player( acceptexposedtosky )
{
	target = [];
	players = get_players();
	players = arraysort( players, self.origin );
	_a692 = players;
	_k692 = getFirstArrayKey( _a692 );
	while ( isDefined( _k692 ) )
	{
		player = _a692[ _k692 ];
		if ( !player_valid_target( player, self.team, self.owner ) )
		{
		}
		else
		{
			if ( bullettracepassed( self.origin, player.origin, 0, player ) )
			{
				target[ "entity" ] = player;
				target[ "offset" ] = ( 0, 0, 1 );
				return target;
			}
			if ( bullettracepassed( self.origin, player geteye(), 0, player ) )
			{
				target[ "entity" ] = player;
				target[ "offset" ] = vectorScale( ( 0, 0, 1 ), 50 );
				return target;
			}
			if ( acceptexposedtosky && cointoss() )
			{
				end = player.origin + vectorScale( ( 0, 0, 1 ), 2048 );
				if ( bullettracepassed( player.origin, end, 0, player ) )
				{
					target[ "entity" ] = player;
					target[ "offset" ] = vectorScale( ( 0, 0, 1 ), 30 );
					return target;
				}
			}
		}
		_k692 = getNextArrayKey( _a692, _k692 );
	}
	return undefined;
}

create_player_targeting_array( owner, team )
{
	level.playertargetedtimes = [];
	players = get_players();
	_a739 = players;
	_k739 = getFirstArrayKey( _a739 );
	while ( isDefined( _k739 ) )
	{
		player = _a739[ _k739 ];
		if ( !player_valid_target( player, team, owner ) )
		{
		}
		else
		{
			level.playertargetedtimes[ player.clientid ] = 0;
		}
		_k739 = getNextArrayKey( _a739, _k739 );
	}
}

projectile_find_random_player( owner, team )
{
	players = get_players();
	lowest = 10000;
	_a757 = players;
	_k757 = getFirstArrayKey( _a757 );
	while ( isDefined( _k757 ) )
	{
		player = _a757[ _k757 ];
		if ( !player_valid_target( player, team, owner ) )
		{
		}
		else
		{
			if ( !isDefined( level.playertargetedtimes[ player.clientid ] ) )
			{
				level.playertargetedtimes[ player.clientid ] = 0;
			}
			if ( level.playertargetedtimes[ player.clientid ] < lowest || level.playertargetedtimes[ player.clientid ] == lowest && randomint( 100 ) > 50 )
			{
				target = player;
				lowest = level.playertargetedtimes[ player.clientid ];
			}
		}
		_k757 = getNextArrayKey( _a757, _k757 );
	}
	if ( isDefined( target ) )
	{
		level.playertargetedtimes[ target.clientid ] += 1;
		return target;
	}
	return undefined;
}

player_valid_target( player, team, owner )
{
	if ( player.sessionstate != "playing" )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( player == owner )
	{
		return 0;
	}
	if ( level.teambased )
	{
		if ( team == player.team )
		{
			return 0;
		}
	}
	if ( player cantargetplayerwithspecialty() == 0 )
	{
		return 0;
	}
	if ( isDefined( player.lastspawntime ) && ( getTime() - player.lastspawntime ) < 3000 )
	{
		return 0;
	}
/#
	if ( player isinmovemode( "ufo", "noclip" ) )
	{
		return 0;
#/
	}
	return 1;
}
