#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_heatseekingmissile;
#include maps/mp/gametypes/_spawning;
#include maps/mp/killstreaks/_helicopter;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_airsupport;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precachestring( &"MP_CIVILIAN_AIR_TRAFFIC" );
	precachestring( &"MP_AIR_SPACE_TOO_CROWDED" );
	precachevehicle( "heli_guard_mp" );
	precachemodel( "veh_t6_drone_overwatch_light" );
	precachemodel( "veh_t6_drone_overwatch_dark" );
	precacheturret( "littlebird_guard_minigun_mp" );
	precachemodel( "veh_iw_littlebird_minigun_left" );
	precachemodel( "veh_iw_littlebird_minigun_right" );
	registerkillstreak( "helicopter_guard_mp", "helicopter_guard_mp", "killstreak_helicopter_guard", "helicopter_used", ::tryuseheliguardsupport, 1 );
	registerkillstreakaltweapon( "helicopter_guard_mp", "littlebird_guard_minigun_mp" );
	registerkillstreakstrings( "helicopter_guard_mp", &"KILLSTREAK_EARNED_HELICOPTER_GUARD", &"KILLSTREAK_HELICOPTER_GUARD_NOT_AVAILABLE", &"KILLSTREAK_HELICOPTER_GUARD_INBOUND" );
	registerkillstreakdialog( "helicopter_guard_mp", "mpl_killstreak_lbguard_strt", "kls_littlebird_used", "", "kls_littlebird_enemy", "", "kls_littlebird_ready" );
	registerkillstreakdevdvar( "helicopter_guard_mp", "scr_givehelicopterguard" );
	setkillstreakteamkillpenaltyscale( "helicopter_guard_mp", 0 );
	shouldtimeout = setdvar( "scr_heli_guard_no_timeout", 0 );
	debuglittlebird = setdvar( "scr_heli_guard_debug", 0 );
	level._effect[ "heli_guard_light" ][ "friendly" ] = loadfx( "light/fx_vlight_mp_escort_eye_grn" );
	level._effect[ "heli_guard_light" ][ "enemy" ] = loadfx( "light/fx_vlight_mp_escort_eye_red" );
/#
	set_dvar_float_if_unset( "scr_lbguard_timeout", 60 );
#/
	level.heliguardflyovernfz = 0;
	if ( level.script == "mp_hydro" )
	{
		level.heliguardflyovernfz = 1;
	}
}

register()
{
	registerclientfield( "helicopter", "vehicle_is_firing", 1, 1, "int" );
}

tryuseheliguardsupport( lifeid )
{
	if ( isDefined( level.civilianjetflyby ) )
	{
		self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
		return 0;
	}
	if ( self isremotecontrolling() )
	{
		return 0;
	}
	if ( !isDefined( level.heli_paths ) || level.heli_paths.size <= 0 )
	{
		self iprintlnbold( &"MP_UNAVAILABLE_IN_LEVEL" );
		return 0;
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( "helicopter_guard_mp", self.team, 0, 1 );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	heliguard = createheliguardsupport( lifeid, killstreak_id );
	if ( !isDefined( heliguard ) )
	{
		return 0;
	}
	self thread startheliguardsupport( heliguard, lifeid );
	return 1;
}

createheliguardsupport( lifeid, killstreak_id )
{
	hardpointtype = "helicopter_guard_mp";
	closeststartnode = heliguardsupport_getcloseststartnode( self.origin );
	if ( isDefined( closeststartnode.angles ) )
	{
		startang = closeststartnode.angles;
	}
	else
	{
		startang = ( 0, 0, 1 );
	}
	closestnode = heliguardsupport_getclosestnode( self.origin );
	flyheight = max( self.origin[ 2 ] + 1600, getnoflyzoneheight( self.origin ) );
	forward = anglesToForward( self.angles );
	targetpos = ( ( self.origin * ( 0, 0, 1 ) ) + ( ( 0, 0, 1 ) * flyheight ) ) + ( forward * -100 );
	startpos = closeststartnode.origin;
	heliguard = spawnhelicopter( self, startpos, startang, "heli_guard_mp", "veh_t6_drone_overwatch_light" );
	if ( !isDefined( heliguard ) )
	{
		return;
	}
	target_set( heliguard, vectorScale( ( 0, 0, 1 ), 50 ) );
	heliguard setenemymodel( "veh_t6_drone_overwatch_dark" );
	heliguard.speed = 150;
	heliguard.followspeed = 40;
	heliguard setcandamage( 1 );
	heliguard.owner = self;
	heliguard.team = self.team;
	heliguard setmaxpitchroll( 45, 45 );
	heliguard setspeed( heliguard.speed, 100, 40 );
	heliguard setyawspeed( 120, 60 );
	heliguard setneargoalnotifydist( 512 );
	heliguard thread heliguardsupport_attacktargets();
	heliguard.killcount = 0;
	heliguard.streakname = "littlebird_support";
	heliguard.helitype = "littlebird";
	heliguard.targettingradius = 2000;
	heliguard.targetpos = targetpos;
	heliguard.currentnode = closestnode;
	heliguard.attract_strength = 10000;
	heliguard.attract_range = 150;
	heliguard.attractor = missile_createattractorent( heliguard, heliguard.attract_strength, heliguard.attract_range );
	heliguard.health = 999999;
	heliguard.maxhealth = level.heli_maxhealth;
	heliguard.rocketdamageoneshot = heliguard.maxhealth + 1;
	heliguard.crashtype = "explode";
	heliguard.destroyfunc = ::lbexplode;
	heliguard.targeting_delay = level.heli_targeting_delay;
	heliguard.hasdodged = 0;
	heliguard setdrawinfrared( 1 );
	self thread maps/mp/killstreaks/_helicopter::announcehelicopterinbound( hardpointtype );
	heliguard thread maps/mp/killstreaks/_helicopter::heli_targeting( 0, hardpointtype );
	heliguard thread maps/mp/killstreaks/_helicopter::heli_damage_monitor( hardpointtype );
	heliguard thread maps/mp/killstreaks/_helicopter::heli_kill_monitor( hardpointtype );
	heliguard thread maps/mp/killstreaks/_helicopter::heli_health( hardpointtype, self, undefined );
	heliguard maps/mp/gametypes/_spawning::create_helicopter_influencers( heliguard.team );
	heliguard thread heliguardsupport_watchtimeout();
	heliguard thread heliguardsupport_watchownerloss();
	heliguard thread heliguardsupport_watchownerdamage();
	heliguard thread heliguardsupport_watchroundend();
	heliguard.numflares = 1;
	heliguard.flareoffset = ( 0, 0, 1 );
	heliguard thread maps/mp/_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "explode", "death" );
	heliguard thread create_flare_ent( vectorScale( ( 0, 0, 1 ), 50 ) );
	heliguard.killstreak_id = killstreak_id;
	level.littlebirdguard = heliguard;
	return heliguard;
}

getmeshheight( littlebird, owner )
{
	if ( !owner isinsideheightlock() )
	{
		return maps/mp/killstreaks/_airsupport::getminimumflyheight();
	}
	maxmeshheight = littlebird getheliheightlockheight( owner.origin );
	return max( maxmeshheight, owner.origin[ 2 ] );
}

startheliguardsupport( littlebird, lifeid )
{
	level endon( "game_ended" );
	littlebird endon( "death" );
	littlebird setlookatent( self );
	maxmeshheight = getmeshheight( littlebird, self );
	height = getnoflyzoneheight( ( self.origin[ 0 ], self.origin[ 1 ], maxmeshheight ) );
	playermeshorigin = ( self.origin[ 0 ], self.origin[ 1 ], height );
	vectostart = vectornormalize( littlebird.origin - littlebird.targetpos );
	dist = 1500;
	target = littlebird.targetpos + ( vectostart * dist );
	collide = crossesnoflyzone( target, playermeshorigin );
	while ( isDefined( collide ) && dist > 0 )
	{
		dist -= 500;
		target = littlebird.targetpos + ( vectostart * dist );
		collide = crossesnoflyzone( target, playermeshorigin );
	}
	littlebird setvehgoalpos( target, 1 );
	target_setturretaquire( littlebird, 0 );
	littlebird waittill( "near_goal" );
	target_setturretaquire( littlebird, 1 );
	littlebird setvehgoalpos( playermeshorigin, 1 );
	littlebird waittill( "near_goal" );
	littlebird setspeed( littlebird.speed, 80, 30 );
	littlebird waittill( "goal" );
/#
	if ( getDvar( "scr_heli_guard_debug" ) == "1" )
	{
		debug_no_fly_zones();
#/
	}
	littlebird thread heliguardsupport_followplayer();
}

heliguardsupport_followplayer()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "leaving" );
	if ( !isDefined( self.owner ) )
	{
		self thread heliguardsupport_leave();
		return;
	}
	self.owner endon( "disconnect" );
	self.owner endon( "joined_team" );
	self.owner endon( "joined_spectators" );
	self setspeed( self.followspeed, 20, 20 );
	while ( 1 )
	{
		if ( isDefined( self.owner ) && isalive( self.owner ) )
		{
			heliguardsupport_movetoplayer();
		}
		wait 3;
	}
}

heliguardsupport_movetoplayer()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "leaving" );
	self.owner endon( "death" );
	self.owner endon( "disconnect" );
	self.owner endon( "joined_team" );
	self.owner endon( "joined_spectators" );
	self notify( "heliGuardSupport_moveToPlayer" );
	self endon( "heliGuardSupport_moveToPlayer" );
	maxmeshheight = getmeshheight( self, self.owner );
	hovergoal = ( self.owner.origin[ 0 ], self.owner.origin[ 1 ], maxmeshheight );
/#
	littlebird_debug_line( self.origin, hovergoal, ( 0, 0, 1 ) );
#/
	zoneindex = crossesnoflyzone( self.origin, hovergoal );
	if ( isDefined( zoneindex ) && level.heliguardflyovernfz )
	{
		self.intransit = 1;
		noflyzoneheight = getnoflyzoneheightcrossed( hovergoal, self.origin, maxmeshheight );
		self setvehgoalpos( ( hovergoal[ 0 ], hovergoal[ 1 ], noflyzoneheight ), 1 );
		self waittill( "goal" );
		return;
	}
	if ( isDefined( zoneindex ) )
	{
/#
		littlebird_debug_text( "NO FLY ZONE between heli and hoverGoal" );
#/
		dist = distance2d( self.owner.origin, level.noflyzones[ zoneindex ].origin );
		zoneorgtoplayer2d = self.owner.origin - level.noflyzones[ zoneindex ].origin;
		zoneorgtoplayer2d *= ( 0, 0, 1 );
		zoneorgtochopper2d = self.origin - level.noflyzones[ zoneindex ].origin;
		zoneorgtochopper2d *= ( 0, 0, 1 );
		zoneorgatmeshheight = ( level.noflyzones[ zoneindex ].origin[ 0 ], level.noflyzones[ zoneindex ].origin[ 1 ], maxmeshheight );
		zoneorgtoadjpos = vectorScale( vectornormalize( zoneorgtoplayer2d ), level.noflyzones[ zoneindex ].radius + 150 );
		adjacentgoalpos = zoneorgtoadjpos + level.noflyzones[ zoneindex ].origin;
		adjacentgoalpos = ( adjacentgoalpos[ 0 ], adjacentgoalpos[ 1 ], maxmeshheight );
		zoneorgtoperpendicular = ( zoneorgtoadjpos[ 1 ], zoneorgtoadjpos[ 0 ] * -1, 0 );
		zoneorgtooppositeperpendicular = ( zoneorgtoadjpos[ 1 ] * -1, zoneorgtoadjpos[ 0 ], 0 );
		perpendiculargoalpos = zoneorgtoperpendicular + zoneorgatmeshheight;
		oppositeperpendiculargoalpos = zoneorgtooppositeperpendicular + zoneorgatmeshheight;
/#
		littlebird_debug_line( self.origin, perpendiculargoalpos, ( 0, 0, 1 ) );
		littlebird_debug_line( self.origin, oppositeperpendiculargoalpos, ( 0,2, 0,6, 1 ) );
#/
		if ( dist < level.noflyzones[ zoneindex ].radius )
		{
/#
			littlebird_debug_text( "Owner is in a no fly zone, find perimeter hover goal" );
			littlebird_debug_line( self.origin, adjacentgoalpos, ( 0, 0, 1 ) );
#/
			zoneindex = undefined;
			zoneindex = crossesnoflyzone( self.origin, adjacentgoalpos );
			if ( isDefined( zoneindex ) )
			{
/#
				littlebird_debug_text( "adjacentGoalPos is through no fly zone, move to perpendicular edge of cyl" );
#/
				hovergoal = perpendiculargoalpos;
			}
			else
			{
/#
				littlebird_debug_text( "adjacentGoalPos is NOT through fly zone, move to edge closest to player" );
#/
				hovergoal = adjacentgoalpos;
			}
		}
		else
		{
/#
			littlebird_debug_text( "Owner outside no fly zone, navigate around perimeter" );
			littlebird_debug_line( self.origin, perpendiculargoalpos, ( 0, 0, 1 ) );
#/
			hovergoal = perpendiculargoalpos;
		}
	}
	zoneindex = undefined;
	zoneindex = crossesnoflyzone( self.origin, hovergoal );
	if ( isDefined( zoneindex ) )
	{
/#
		littlebird_debug_text( "Try opposite perimeter goal" );
#/
		hovergoal = oppositeperpendiculargoalpos;
	}
	self.intransit = 1;
	self setvehgoalpos( ( hovergoal[ 0 ], hovergoal[ 1 ], maxmeshheight ), 1 );
	self waittill( "goal" );
}

heliguardsupport_movetoplayervertical( maxmeshheight )
{
	height = getnoflyzoneheightcrossed( self.origin, self.owner.origin, maxmeshheight );
	upperheight = max( self.origin[ 2 ], height );
	acquireupperheight = ( self.origin[ 0 ], self.origin[ 1 ], upperheight );
	hoveroverplayer = ( self.owner.origin[ 0 ], self.owner.origin[ 1 ], upperheight );
	hovercorrectheight = ( self.owner.origin[ 0 ], self.owner.origin[ 1 ], height );
	self.intransit = 1;
	self setvehgoalpos( acquireupperheight, 1 );
	self waittill( "goal" );
	self setvehgoalpos( hoveroverplayer, 1 );
	self waittill( "goal" );
	self setvehgoalpos( hovercorrectheight, 1 );
	self waittill( "goal" );
	self.intransit = 0;
}

heliguardsupport_watchtimeout()
{
	level endon( "game_ended" );
	self endon( "death" );
	self.owner endon( "disconnect" );
	self.owner endon( "joined_team" );
	self.owner endon( "joined_spectators" );
	timeout = 60;
/#
	timeout = getDvarFloat( #"E449EBB3" );
#/
	maps/mp/gametypes/_hostmigration::waitlongdurationwithhostmigrationpause( timeout );
	shouldtimeout = getDvar( "scr_heli_guard_no_timeout" );
	if ( shouldtimeout == "1" )
	{
		return;
	}
	self thread heliguardsupport_leave();
}

heliguardsupport_watchownerloss()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "leaving" );
	self.owner waittill_any( "disconnect", "joined_team", "joined_spectators" );
	self thread heliguardsupport_leave();
}

heliguardsupport_watchownerdamage()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "leaving" );
	self.owner endon( "disconnect" );
	self.owner endon( "joined_team" );
	self.owner endon( "joined_spectators" );
	while ( 1 )
	{
		self.owner waittill( "damage", damage, attacker, direction_vec, point, meansofdeath, modelname, tagname, partname, weapon, idflags );
		if ( isplayer( attacker ) )
		{
			if ( attacker != self.owner && distance2d( attacker.origin, self.origin ) <= self.targettingradius && attacker cantargetplayerwithspecialty() )
			{
				self setlookatent( attacker );
				self setgunnertargetent( attacker, vectorScale( ( 0, 0, 1 ), 50 ), 0 );
				self setturrettargetent( attacker, vectorScale( ( 0, 0, 1 ), 50 ) );
			}
		}
	}
}

heliguardsupport_watchroundend()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "leaving" );
	self.owner endon( "disconnect" );
	self.owner endon( "joined_team" );
	self.owner endon( "joined_spectators" );
	level waittill( "round_end_finished" );
	self thread heliguardsupport_leave();
}

heliguardsupport_leave()
{
	self endon( "death" );
	self notify( "leaving" );
	level.littlebirdguard = undefined;
	self cleargunnertarget( 0 );
	self clearturrettarget();
	self clearlookatent();
	flyheight = getnoflyzoneheight( self.origin );
	targetpos = self.origin + ( anglesToForward( self.angles ) * 1500 ) + ( 0, 0, flyheight );
	collide = crossesnoflyzone( self.origin, targetpos );
	tries = 5;
	while ( isDefined( collide ) && tries > 0 )
	{
		yaw = randomint( 360 );
		targetpos = self.origin + ( anglesToForward( ( self.angles[ 0 ], yaw, self.angles[ 2 ] ) ) * 1500 ) + ( 0, 0, flyheight );
		collide = crossesnoflyzone( self.origin, targetpos );
		tries--;

	}
	if ( tries == 0 )
	{
		targetpos = self.origin + ( 0, 0, flyheight );
	}
	self setspeed( self.speed, 80 );
	self setmaxpitchroll( 45, 180 );
	self setvehgoalpos( targetpos );
	self waittill( "goal" );
	targetpos += anglesToForward( ( 0, self.angles[ 1 ], self.angles[ 2 ] ) ) * 14000;
	self setvehgoalpos( targetpos );
	self waittill( "goal" );
	self notify( "gone" );
	self removelittlebird();
}

helidestroyed()
{
	level.littlebirdguard = undefined;
	if ( !isDefined( self ) )
	{
		return;
	}
	self setspeed( 25, 5 );
	self thread lbspin( randomintrange( 180, 220 ) );
	wait randomfloatrange( 0,5, 1,5 );
	lbexplode();
}

lbexplode()
{
	self notify( "explode" );
	self removelittlebird();
}

lbspin( speed )
{
	self endon( "explode" );
	playfxontag( level.chopper_fx[ "explode" ][ "large" ], self, "tail_rotor_jnt" );
	self thread trail_fx( level.chopper_fx[ "smoke" ][ "trail" ], "tail_rotor_jnt", "stop tail smoke" );
	self setyawspeed( speed, speed, speed );
	while ( isDefined( self ) )
	{
		self settargetyaw( self.angles[ 1 ] + ( speed * 0,9 ) );
		wait 1;
	}
}

trail_fx( trail_fx, trail_tag, stop_notify )
{
	self notify( stop_notify );
	self endon( stop_notify );
	self endon( "death" );
	for ( ;; )
	{
		playfxontag( trail_fx, self, trail_tag );
		wait 0,05;
	}
}

removelittlebird()
{
	level.lbstrike = 0;
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "helicopter_guard_mp", self.team, self.killstreak_id );
	if ( isDefined( self.marker ) )
	{
		self.marker delete();
	}
	self delete();
}

heliguardsupport_watchsamproximity( player, missileteam, missiletarget, missilegroup )
{
	level endon( "game_ended" );
	missiletarget endon( "death" );
	i = 0;
	while ( i < missilegroup.size )
	{
		if ( isDefined( missilegroup[ i ] ) && !missiletarget.hasdodged )
		{
			missiletarget.hasdodged = 1;
			newtarget = spawn( "script_origin", missiletarget.origin );
			newtarget.angles = missiletarget.angles;
			newtarget movegravity( anglesToRight( missilegroup[ i ].angles ) * -1000, 0,05 );
			j = 0;
			while ( j < missilegroup.size )
			{
				if ( isDefined( missilegroup[ j ] ) )
				{
					missilegroup[ j ] settargetentity( newtarget );
				}
				j++;
			}
			dodgepoint = missiletarget.origin + ( anglesToRight( missilegroup[ i ].angles ) * 200 );
			missiletarget setspeed( missiletarget.speed, 100, 40 );
			missiletarget setvehgoalpos( dodgepoint, 1 );
			wait 2;
			missiletarget setspeed( missiletarget.followspeed, 20, 20 );
			return;
		}
		else
		{
			i++;
		}
	}
}

heliguardsupport_getcloseststartnode( pos )
{
	closestnode = undefined;
	closestdistance = 999999;
	_a645 = level.heli_paths;
	_k645 = getFirstArrayKey( _a645 );
	while ( isDefined( _k645 ) )
	{
		path = _a645[ _k645 ];
		_a647 = path;
		_k647 = getFirstArrayKey( _a647 );
		while ( isDefined( _k647 ) )
		{
			loc = _a647[ _k647 ];
			nodedistance = distance( loc.origin, pos );
			if ( nodedistance < closestdistance )
			{
				closestnode = loc;
				closestdistance = nodedistance;
			}
			_k647 = getNextArrayKey( _a647, _k647 );
		}
		_k645 = getNextArrayKey( _a645, _k645 );
	}
	return closestnode;
}

heliguardsupport_getclosestnode( pos )
{
	closestnode = undefined;
	closestdistance = 999999;
	_a667 = level.heli_loop_paths;
	_k667 = getFirstArrayKey( _a667 );
	while ( isDefined( _k667 ) )
	{
		loc = _a667[ _k667 ];
		nodedistance = distance( loc.origin, pos );
		if ( nodedistance < closestdistance )
		{
			closestnode = loc;
			closestdistance = nodedistance;
		}
		_k667 = getNextArrayKey( _a667, _k667 );
	}
	return closestnode;
}

littlebird_debug_text( string )
{
/#
	if ( getDvar( "scr_heli_guard_debug" ) == "1" )
	{
		iprintln( string );
#/
	}
}

littlebird_debug_line( start, end, color )
{
/#
	if ( getDvar( "scr_heli_guard_debug" ) == "1" )
	{
		line( start, end, color, 1, 1, 300 );
#/
	}
}

heli_path_debug()
{
/#
	_a703 = level.heli_paths;
	_k703 = getFirstArrayKey( _a703 );
	while ( isDefined( _k703 ) )
	{
		path = _a703[ _k703 ];
		_a705 = path;
		_k705 = getFirstArrayKey( _a705 );
		while ( isDefined( _k705 ) )
		{
			loc = _a705[ _k705 ];
			prev = loc;
			target = loc.target;
			while ( isDefined( target ) )
			{
				target = getent( target, "targetname" );
				line( prev.origin, target.origin, ( 0, 0, 1 ), 1, 0, 50000 );
				debugstar( prev.origin, 50000, ( 0, 0, 1 ) );
				prev = target;
				target = prev.target;
			}
			_k705 = getNextArrayKey( _a705, _k705 );
		}
		_k703 = getNextArrayKey( _a703, _k703 );
	}
	_a722 = level.heli_loop_paths;
	_k722 = getFirstArrayKey( _a722 );
	while ( isDefined( _k722 ) )
	{
		loc = _a722[ _k722 ];
		prev = loc;
		target = loc.target;
		first = loc;
		while ( isDefined( target ) )
		{
			target = getent( target, "targetname" );
			line( prev.origin, target.origin, ( 0, 0, 1 ), 1, 0, 50000 );
			debugstar( prev.origin, 50000, ( 0, 0, 1 ) );
			prev = target;
			target = prev.target;
			if ( prev == first )
			{
				break;
			}
			else
			{
			}
		}
		_k722 = getNextArrayKey( _a722, _k722 );
#/
	}
}

heliguardsupport_getclosestlinkednode( pos )
{
	closestnode = undefined;
	totaldistance = distance2d( self.currentnode.origin, pos );
	closestdistance = totaldistance;
	target = self.currentnode.target;
	while ( isDefined( target ) )
	{
		nextnode = getent( target, "targetname" );
		if ( nextnode == self.currentnode )
		{
			break;
		}
		else
		{
			nodedistance = distance2d( nextnode.origin, pos );
			if ( nodedistance < totaldistance && nodedistance < closestdistance )
			{
				closestnode = nextnode;
				closestdistance = nodedistance;
			}
			target = nextnode.target;
		}
	}
	return closestnode;
}

heliguardsupport_arraycontains( array, compare )
{
	if ( array.size <= 0 )
	{
		return 0;
	}
	_a783 = array;
	_k783 = getFirstArrayKey( _a783 );
	while ( isDefined( _k783 ) )
	{
		member = _a783[ _k783 ];
		if ( member == compare )
		{
			return 1;
		}
		_k783 = getNextArrayKey( _a783, _k783 );
	}
	return 0;
}

heliguardsupport_getlinkedstructs()
{
	array = [];
	return array;
}

heliguardsupport_setairstartnodes()
{
	level.air_start_nodes = getstructarray( "chopper_boss_path_start", "targetname" );
	_a817 = level.air_start_nodes;
	_k817 = getFirstArrayKey( _a817 );
	while ( isDefined( _k817 ) )
	{
		loc = _a817[ _k817 ];
		loc.neighbors = loc heliguardsupport_getlinkedstructs();
		_k817 = getNextArrayKey( _a817, _k817 );
	}
}

heliguardsupport_setairnodemesh()
{
	level.air_node_mesh = getstructarray( "so_chopper_boss_path_struct", "script_noteworthy" );
	_a828 = level.air_node_mesh;
	_k828 = getFirstArrayKey( _a828 );
	while ( isDefined( _k828 ) )
	{
		loc = _a828[ _k828 ];
		loc.neighbors = loc heliguardsupport_getlinkedstructs();
		_a835 = level.air_node_mesh;
		_k835 = getFirstArrayKey( _a835 );
		while ( isDefined( _k835 ) )
		{
			other_loc = _a835[ _k835 ];
			if ( loc == other_loc )
			{
			}
			else
			{
				if ( !heliguardsupport_arraycontains( loc.neighbors, other_loc ) && heliguardsupport_arraycontains( other_loc heliguardsupport_getlinkedstructs(), loc ) )
				{
					loc.neighbors[ loc.neighbors.size ] = other_loc;
				}
			}
			_k835 = getNextArrayKey( _a835, _k835 );
		}
		_k828 = getNextArrayKey( _a828, _k828 );
	}
}

heliguardsupport_attacktargets()
{
	self endon( "death" );
	level endon( "game_ended" );
	self endon( "leaving" );
	for ( ;; )
	{
		self heliguardsupport_firestart();
	}
}

heliguardsupport_firestart()
{
	self endon( "death" );
	self endon( "leaving" );
	self endon( "stop_shooting" );
	level endon( "game_ended" );
	for ( ;; )
	{
		numshots = randomintrange( 10, 21 );
		if ( !isDefined( self.primarytarget ) )
		{
			self waittill( "primary acquired" );
		}
		while ( isDefined( self.primarytarget ) )
		{
			targetent = self.primarytarget;
			self thread heliguardsupport_firestop( targetent );
			self setlookatent( targetent );
			self setgunnertargetent( targetent, vectorScale( ( 0, 0, 1 ), 50 ), 0 );
			self setturrettargetent( targetent, vectorScale( ( 0, 0, 1 ), 50 ) );
			self waittill( "turret_on_target" );
			wait 0,2;
			self setclientfield( "vehicle_is_firing", 1 );
			i = 0;
			while ( i < numshots )
			{
				self firegunnerweapon( 0, self );
				self fireweapon();
				wait 0,15;
				i++;
			}
		}
		self setclientfield( "vehicle_is_firing", 0 );
		self clearturrettarget();
		self cleargunnertarget( 0 );
		wait randomfloatrange( 1, 2 );
	}
}

heliguardsupport_firestop( targetent )
{
	self endon( "death" );
	self endon( "leaving" );
	self notify( "heli_guard_target_death_watcher" );
	self endon( "heli_guard_target_death_watcher" );
	targetent waittill_any( "death", "disconnect" );
	self setclientfield( "vehicle_is_firing", 0 );
	self notify( "stop_shooting" );
	self.primarytarget = undefined;
	self setlookatent( self.owner );
	self cleargunnertarget( 0 );
	self clearturrettarget();
}
