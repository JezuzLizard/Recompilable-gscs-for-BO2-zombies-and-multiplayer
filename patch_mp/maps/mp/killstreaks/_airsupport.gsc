#include maps/mp/gametypes/_weapons;
#include common_scripts/utility;
#include maps/mp/_utility;

initairsupport()
{
	if ( !isDefined( level.airsupportheightscale ) )
	{
		level.airsupportheightscale = 1;
	}
	level.airsupportheightscale = getdvarintdefault( "scr_airsupportHeightScale", level.airsupportheightscale );
	level.noflyzones = [];
	level.noflyzones = getentarray( "no_fly_zone", "targetname" );
	airsupport_heights = getstructarray( "air_support_height", "targetname" );
/#
	if ( airsupport_heights.size > 1 )
	{
		error( "Found more then one 'air_support_height' structs in the map" );
#/
	}
	airsupport_heights = getentarray( "air_support_height", "targetname" );
/#
	if ( airsupport_heights.size > 0 )
	{
		error( "Found an entity in the map with an 'air_support_height' targetname.  There should be only structs." );
#/
	}
	heli_height_meshes = getentarray( "heli_height_lock", "classname" );
/#
	if ( heli_height_meshes.size > 1 )
	{
		error( "Found more then one 'heli_height_lock' classname in the map" );
#/
	}
}

finishhardpointlocationusage( location, usedcallback )
{
	self notify( "used" );
	wait 0,05;
	return self [[ usedcallback ]]( location );
}

finishdualhardpointlocationusage( locationstart, locationend, usedcallback )
{
	self notify( "used" );
	wait 0,05;
	return self [[ usedcallback ]]( locationstart, locationend );
}

endselectionongameend()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "cancel_location" );
	self endon( "used" );
	self endon( "host_migration_begin" );
	level waittill( "game_ended" );
	self notify( "game_ended" );
}

endselectiononhostmigration()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "cancel_location" );
	self endon( "used" );
	self endon( "game_ended" );
	level waittill( "host_migration_begin" );
	self notify( "cancel_location" );
}

endselectionthink()
{
/#
	assert( isplayer( self ) );
#/
/#
	assert( isalive( self ) );
#/
/#
	assert( isDefined( self.selectinglocation ) );
#/
/#
	assert( self.selectinglocation == 1 );
#/
	self thread endselectionongameend();
	self thread endselectiononhostmigration();
	event = self waittill_any_return( "death", "disconnect", "cancel_location", "game_ended", "used", "weapon_change", "emp_jammed" );
	if ( event != "disconnect" )
	{
		self endlocationselection();
		self.selectinglocation = undefined;
	}
	if ( event != "used" )
	{
		self notify( "confirm_location" );
	}
}

stoploopsoundaftertime( time )
{
	self endon( "death" );
	wait time;
	self stoploopsound( 2 );
}

calculatefalltime( flyheight )
{
	gravity = getDvarInt( "bg_gravity" );
	time = sqrt( ( 2 * flyheight ) / gravity );
	return time;
}

calculatereleasetime( flytime, flyheight, flyspeed, bombspeedscale )
{
	falltime = calculatefalltime( flyheight );
	bomb_x = flyspeed * bombspeedscale * falltime;
	release_time = bomb_x / flyspeed;
	return ( flytime * 0,5 ) - release_time;
}

getminimumflyheight()
{
	airsupport_height = getstruct( "air_support_height", "targetname" );
	if ( isDefined( airsupport_height ) )
	{
		planeflyheight = airsupport_height.origin[ 2 ];
	}
	else
	{
/#
		println( "WARNING:  Missing air_support_height entity in the map.  Using default height." );
#/
		planeflyheight = 850;
		if ( isDefined( level.airsupportheightscale ) )
		{
			level.airsupportheightscale = getdvarintdefault( "scr_airsupportHeightScale", level.airsupportheightscale );
			planeflyheight *= getdvarintdefault( "scr_airsupportHeightScale", level.airsupportheightscale );
		}
		if ( isDefined( level.forceairsupportmapheight ) )
		{
			planeflyheight += level.forceairsupportmapheight;
		}
	}
	return planeflyheight;
}

callstrike( flightplan )
{
	level.bomberdamagedents = [];
	level.bomberdamagedentscount = 0;
	level.bomberdamagedentsindex = 0;
/#
	assert( flightplan.distance != 0, "callStrike can not be passed a zero fly distance" );
#/
	planehalfdistance = flightplan.distance / 2;
	path = getstrikepath( flightplan.target, flightplan.height, planehalfdistance );
	startpoint = path[ "start" ];
	endpoint = path[ "end" ];
	flightplan.height = path[ "height" ];
	direction = path[ "direction" ];
	d = length( startpoint - endpoint );
	flytime = d / flightplan.speed;
	bombtime = calculatereleasetime( flytime, flightplan.height, flightplan.speed, flightplan.bombspeedscale );
	if ( bombtime < 0 )
	{
		bombtime = 0;
	}
/#
	assert( flytime > bombtime );
#/
	flightplan.owner endon( "disconnect" );
	requireddeathcount = flightplan.owner.deathcount;
	side = vectorcross( anglesToForward( direction ), ( 1, 1, 1 ) );
	plane_seperation = 25;
	side_offset = vectorScale( side, plane_seperation );
	level thread planestrike( flightplan.owner, requireddeathcount, startpoint, endpoint, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback );
	wait flightplan.planespacing;
	level thread planestrike( flightplan.owner, requireddeathcount, startpoint + side_offset, endpoint + side_offset, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback );
	wait flightplan.planespacing;
	side_offset = vectorScale( side, -1 * plane_seperation );
	level thread planestrike( flightplan.owner, requireddeathcount, startpoint + side_offset, endpoint + side_offset, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback );
}

planestrike( owner, requireddeathcount, pathstart, pathend, bombtime, flytime, flyspeed, bombspeedscale, direction, planespawnedfunction )
{
	if ( !isDefined( owner ) )
	{
		return;
	}
	plane = spawnplane( owner, "script_model", pathstart );
	plane.angles = direction;
	plane moveto( pathend, flytime, 0, 0 );
	thread debug_plane_line( flytime, flyspeed, pathstart, pathend );
	if ( isDefined( planespawnedfunction ) )
	{
		plane [[ planespawnedfunction ]]( owner, requireddeathcount, pathstart, pathend, bombtime, bombspeedscale, flytime, flyspeed );
	}
	wait flytime;
	plane notify( "delete" );
	plane delete();
}

determinegroundpoint( player, position )
{
	ground = ( position[ 0 ], position[ 1 ], player.origin[ 2 ] );
	trace = bullettrace( ground + vectorScale( ( 1, 1, 1 ), 10000 ), ground, 0, undefined );
	return trace[ "position" ];
}

determinetargetpoint( player, position )
{
	point = determinegroundpoint( player, position );
	return clamptarget( point );
}

getmintargetheight()
{
	return level.spawnmins[ 2 ] - 500;
}

getmaxtargetheight()
{
	return level.spawnmaxs[ 2 ] + 500;
}

clamptarget( target )
{
	min = getmintargetheight();
	max = getmaxtargetheight();
	if ( target[ 2 ] < min )
	{
		target[ 2 ] = min;
	}
	if ( target[ 2 ] > max )
	{
		target[ 2 ] = max;
	}
	return target;
}

_insidecylinder( point, base, radius, height )
{
	if ( isDefined( height ) )
	{
		if ( point[ 2 ] > ( base[ 2 ] + height ) )
		{
			return 0;
		}
	}
	dist = distance2d( point, base );
	if ( dist < radius )
	{
		return 1;
	}
	return 0;
}

_insidenoflyzonebyindex( point, index, disregardheight )
{
	height = level.noflyzones[ index ].height;
	if ( isDefined( disregardheight ) )
	{
		height = undefined;
	}
	return _insidecylinder( point, level.noflyzones[ index ].origin, level.noflyzones[ index ].radius, height );
}

getnoflyzoneheight( point )
{
	height = point[ 2 ];
	origin = undefined;
	i = 0;
	while ( i < level.noflyzones.size )
	{
		if ( _insidenoflyzonebyindex( point, i ) )
		{
			if ( height < level.noflyzones[ i ].height )
			{
				height = level.noflyzones[ i ].height;
				origin = level.noflyzones[ i ].origin;
			}
		}
		i++;
	}
	if ( !isDefined( origin ) )
	{
		return point[ 2 ];
	}
	return origin[ 2 ] + height;
}

insidenoflyzones( point, disregardheight )
{
	noflyzones = [];
	i = 0;
	while ( i < level.noflyzones.size )
	{
		if ( _insidenoflyzonebyindex( point, i, disregardheight ) )
		{
			noflyzones[ noflyzones.size ] = i;
		}
		i++;
	}
	return noflyzones;
}

crossesnoflyzone( start, end )
{
	i = 0;
	while ( i < level.noflyzones.size )
	{
		point = closestpointonline( level.noflyzones[ i ].origin + ( 0, 0, 0,5 * level.noflyzones[ i ].height ), start, end );
		dist = distance2d( point, level.noflyzones[ i ].origin );
		if ( point[ 2 ] > ( level.noflyzones[ i ].origin[ 2 ] + level.noflyzones[ i ].height ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( dist < level.noflyzones[ i ].radius )
			{
				return i;
			}
		}
		i++;
	}
	return undefined;
}

crossesnoflyzones( start, end )
{
	zones = [];
	i = 0;
	while ( i < level.noflyzones.size )
	{
		point = closestpointonline( level.noflyzones[ i ].origin, start, end );
		dist = distance2d( point, level.noflyzones[ i ].origin );
		if ( point[ 2 ] > ( level.noflyzones[ i ].origin[ 2 ] + level.noflyzones[ i ].height ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( dist < level.noflyzones[ i ].radius )
			{
				zones[ zones.size ] = i;
			}
		}
		i++;
	}
	return zones;
}

getnoflyzoneheightcrossed( start, end, minheight )
{
	height = minheight;
	i = 0;
	while ( i < level.noflyzones.size )
	{
		point = closestpointonline( level.noflyzones[ i ].origin, start, end );
		dist = distance2d( point, level.noflyzones[ i ].origin );
		if ( dist < level.noflyzones[ i ].radius )
		{
			if ( height < level.noflyzones[ i ].height )
			{
				height = level.noflyzones[ i ].height;
			}
		}
		i++;
	}
	return height;
}

_shouldignorenoflyzone( noflyzone, noflyzones )
{
	if ( !isDefined( noflyzone ) )
	{
		return 1;
	}
	i = 0;
	while ( i < noflyzones.size )
	{
		if ( isDefined( noflyzones[ i ] ) && noflyzones[ i ] == noflyzone )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

_shouldignorestartgoalnoflyzone( noflyzone, startnoflyzones, goalnoflyzones )
{
	if ( !isDefined( noflyzone ) )
	{
		return 1;
	}
	if ( _shouldignorenoflyzone( noflyzone, startnoflyzones ) )
	{
		return 1;
	}
	if ( _shouldignorenoflyzone( noflyzone, goalnoflyzones ) )
	{
		return 1;
	}
	return 0;
}

gethelipath( start, goal )
{
	startnoflyzones = insidenoflyzones( start, 1 );
	thread debug_line( start, goal, ( 1, 1, 1 ) );
	goalnoflyzones = insidenoflyzones( goal );
	if ( goalnoflyzones.size )
	{
		goal = ( goal[ 0 ], goal[ 1 ], getnoflyzoneheight( goal ) );
	}
	goal_points = calculatepath( start, goal, startnoflyzones, goalnoflyzones );
	if ( !isDefined( goal_points ) )
	{
		return undefined;
	}
/#
	assert( goal_points.size >= 1 );
#/
	return goal_points;
}

followpath( path, donenotify, stopatgoal )
{
	i = 0;
	while ( i < ( path.size - 1 ) )
	{
		self setvehgoalpos( path[ i ], 0 );
		thread debug_line( self.origin, path[ i ], ( 1, 1, 1 ) );
		self waittill( "goal" );
		i++;
	}
	self setvehgoalpos( path[ path.size - 1 ], stopatgoal );
	thread debug_line( self.origin, path[ i ], ( 1, 1, 1 ) );
	self waittill( "goal" );
	if ( isDefined( donenotify ) )
	{
		self notify( donenotify );
	}
}

setgoalposition( goal, donenotify, stopatgoal )
{
	if ( !isDefined( stopatgoal ) )
	{
		stopatgoal = 1;
	}
	start = self.origin;
	goal_points = gethelipath( start, goal );
	if ( !isDefined( goal_points ) )
	{
		goal_points = [];
		goal_points[ 0 ] = goal;
	}
	followpath( goal_points, donenotify, stopatgoal );
}

clearpath( start, end, startnoflyzone, goalnoflyzone )
{
	noflyzones = crossesnoflyzones( start, end );
	i = 0;
	while ( i < noflyzones.size )
	{
		if ( !_shouldignorestartgoalnoflyzone( noflyzones[ i ], startnoflyzone, goalnoflyzone ) )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

append_array( dst, src )
{
	i = 0;
	while ( i < src.size )
	{
		dst[ dst.size ] = src[ i ];
		i++;
	}
}

calculatepath_r( start, end, points, startnoflyzones, goalnoflyzones, depth )
{
	depth--;

	if ( depth <= 0 )
	{
		points[ points.size ] = end;
		return points;
	}
	noflyzones = crossesnoflyzones( start, end );
	i = 0;
	while ( i < noflyzones.size )
	{
		noflyzone = noflyzones[ i ];
		if ( !_shouldignorestartgoalnoflyzone( noflyzone, startnoflyzones, goalnoflyzones ) )
		{
			return undefined;
		}
		i++;
	}
	points[ points.size ] = end;
	return points;
}

calculatepath( start, end, startnoflyzones, goalnoflyzones )
{
	points = [];
	points = calculatepath_r( start, end, points, startnoflyzones, goalnoflyzones, 3 );
	if ( !isDefined( points ) )
	{
		return undefined;
	}
/#
	assert( points.size >= 1 );
#/
	debug_sphere( points[ points.size - 1 ], 10, ( 1, 1, 1 ), 1, 1000 );
	point = start;
	i = 0;
	while ( i < points.size )
	{
		thread debug_line( point, points[ i ], ( 1, 1, 1 ) );
		debug_sphere( points[ i ], 10, ( 1, 1, 1 ), 1, 1000 );
		point = points[ i ];
		i++;
	}
	return points;
}

_getstrikepathstartandend( goal, yaw, halfdistance )
{
	direction = ( 0, yaw, 0 );
	startpoint = goal + vectorScale( anglesToForward( direction ), -1 * halfdistance );
	endpoint = goal + vectorScale( anglesToForward( direction ), halfdistance );
	noflyzone = crossesnoflyzone( startpoint, endpoint );
	path = [];
	if ( isDefined( noflyzone ) )
	{
		path[ "noFlyZone" ] = noflyzone;
		startpoint = ( startpoint[ 0 ], startpoint[ 1 ], level.noflyzones[ noflyzone ].origin[ 2 ] + level.noflyzones[ noflyzone ].height );
		endpoint = ( endpoint[ 0 ], endpoint[ 1 ], startpoint[ 2 ] );
	}
	else
	{
	}
	path[ "start" ] = startpoint;
	path[ "end" ] = endpoint;
	path[ "direction" ] = direction;
	return path;
}

getstrikepath( target, height, halfdistance, yaw )
{
	noflyzoneheight = getnoflyzoneheight( target );
	worldheight = target[ 2 ] + height;
	if ( noflyzoneheight > worldheight )
	{
		worldheight = noflyzoneheight;
	}
	goal = ( target[ 0 ], target[ 1 ], worldheight );
	path = [];
	if ( !isDefined( yaw ) || yaw != "random" )
	{
		i = 0;
		while ( i < 3 )
		{
			path = _getstrikepathstartandend( goal, randomint( 360 ), halfdistance );
			if ( !isDefined( path[ "noFlyZone" ] ) )
			{
				break;
			}
			else
			{
				i++;
			}
		}
	}
	else path = _getstrikepathstartandend( goal, yaw, halfdistance );
	path[ "height" ] = worldheight - target[ 2 ];
	return path;
}

doglassdamage( pos, radius, max, min, mod )
{
	wait randomfloatrange( 0,05, 0,15 );
	glassradiusdamage( pos, radius, max, min, mod );
}

entlosradiusdamage( ent, pos, radius, max, min, owner, einflictor )
{
	dist = distance( pos, ent.damagecenter );
	if ( ent.isplayer || ent.isactor )
	{
		assumed_ceiling_height = 800;
		eye_position = ent.entity geteye();
		head_height = eye_position[ 2 ];
		debug_display_time = 4000;
		trace = maps/mp/gametypes/_weapons::weapondamagetrace( ent.entity.origin, ent.entity.origin + ( 0, 0, assumed_ceiling_height ), 0, undefined );
		indoors = trace[ "fraction" ] != 1;
		if ( indoors )
		{
			test_point = trace[ "position" ];
			debug_star( test_point, ( 1, 1, 1 ), debug_display_time );
			trace = maps/mp/gametypes/_weapons::weapondamagetrace( ( test_point[ 0 ], test_point[ 1 ], head_height ), ( pos[ 0 ], pos[ 1 ], head_height ), 0, undefined );
			indoors = trace[ "fraction" ] != 1;
			if ( indoors )
			{
				debug_star( ( pos[ 0 ], pos[ 1 ], head_height ), ( 1, 1, 1 ), debug_display_time );
				dist *= 4;
				if ( dist > radius )
				{
					return 0;
				}
			}
			else
			{
				debug_star( ( pos[ 0 ], pos[ 1 ], head_height ), ( 1, 1, 1 ), debug_display_time );
				trace = maps/mp/gametypes/_weapons::weapondamagetrace( ( pos[ 0 ], pos[ 1 ], head_height ), pos, 0, undefined );
				indoors = trace[ "fraction" ] != 1;
				if ( indoors )
				{
					debug_star( pos, ( 1, 1, 1 ), debug_display_time );
					dist *= 4;
					if ( dist > radius )
					{
						return 0;
					}
				}
				else
				{
					debug_star( pos, ( 1, 1, 1 ), debug_display_time );
				}
			}
		}
		else
		{
			debug_star( ent.entity.origin + ( 0, 0, assumed_ceiling_height ), ( 1, 1, 1 ), debug_display_time );
		}
	}
	ent.damage = int( max + ( ( ( min - max ) * dist ) / radius ) );
	ent.pos = pos;
	ent.damageowner = owner;
	ent.einflictor = einflictor;
	return 1;
}

debug_no_fly_zones()
{
/#
	i = 0;
	while ( i < level.noflyzones.size )
	{
		debug_cylinder( level.noflyzones[ i ].origin, level.noflyzones[ i ].radius, level.noflyzones[ i ].height, ( 1, 1, 1 ), undefined, 5000 );
		i++;
#/
	}
}

debug_plane_line( flytime, flyspeed, pathstart, pathend )
{
	thread debug_line( pathstart, pathend, ( 1, 1, 1 ) );
	delta = vectornormalize( pathend - pathstart );
	i = 0;
	while ( i < flytime )
	{
		thread debug_star( pathstart + vectorScale( delta, i * flyspeed ), ( 1, 1, 1 ) );
		i++;
	}
}

debug_draw_bomb_explosion( prevpos )
{
	self notify( "draw_explosion" );
	wait 0,05;
	self endon( "draw_explosion" );
	self waittill( "projectile_impact", weapon, position );
	thread debug_line( prevpos, position, ( 0,5, 1, 0 ) );
	thread debug_star( position, ( 1, 1, 1 ) );
}

debug_draw_bomb_path( projectile, color, time )
{
/#
	self endon( "death" );
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( !isDefined( color ) )
	{
		color = ( 0,5, 1, 0 );
	}
	while ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		prevpos = self.origin;
		while ( isDefined( self.origin ) )
		{
			thread debug_line( prevpos, self.origin, color, time );
			prevpos = self.origin;
			if ( isDefined( projectile ) && projectile )
			{
				thread debug_draw_bomb_explosion( prevpos );
			}
			wait 0,2;
#/
		}
	}
}

debug_print3d_simple( message, ent, offset, frames )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		if ( isDefined( frames ) )
		{
			thread draw_text( message, vectorScale( ( 1, 1, 1 ), 0,8 ), ent, offset, frames );
			return;
		}
		else
		{
			thread draw_text( message, vectorScale( ( 1, 1, 1 ), 0,8 ), ent, offset, 0 );
#/
		}
	}
}

draw_text( msg, color, ent, offset, frames )
{
/#
	if ( frames == 0 )
	{
		while ( isDefined( ent ) && isDefined( ent.origin ) )
		{
			print3d( ent.origin + offset, msg, color, 0,5, 4 );
			wait 0,05;
		}
	}
	else i = 0;
	while ( i < frames )
	{
		if ( !isDefined( ent ) )
		{
			return;
		}
		else
		{
			print3d( ent.origin + offset, msg, color, 0,5, 4 );
			wait 0,05;
			i++;
#/
		}
	}
}

debug_print3d( message, color, ent, origin_offset, frames )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		self thread draw_text( message, color, ent, origin_offset, frames );
#/
	}
}

debug_line( from, to, color, time, depthtest )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( depthtest ) )
		{
			depthtest = 1;
		}
		line( from, to, color, 1, depthtest, time );
#/
	}
}

debug_star( origin, color, time )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( color ) )
		{
			color = ( 1, 1, 1 );
		}
		debugstar( origin, time, color );
#/
	}
}

debug_circle( origin, radius, color, time )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( color ) )
		{
			color = ( 1, 1, 1 );
		}
		circle( origin, radius, color, 1, 1, time );
#/
	}
}

debug_sphere( origin, radius, color, alpha, time )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( color ) )
		{
			color = ( 1, 1, 1 );
		}
		sides = int( 10 * ( 1 + int( radius / 100 ) ) );
		sphere( origin, radius, color, alpha, 1, sides, time );
#/
	}
}

debug_cylinder( origin, radius, height, color, mustrenderheight, time )
{
/#
	level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
	subdivision = 600;
	if ( isDefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
	{
		if ( !isDefined( time ) )
		{
			time = 1000;
		}
		if ( !isDefined( color ) )
		{
			color = ( 1, 1, 1 );
		}
		count = height / subdivision;
		i = 0;
		while ( i < count )
		{
			point = origin + ( 0, 0, i * subdivision );
			circle( point, radius, color, 1, 1, time );
			i++;
		}
		if ( isDefined( mustrenderheight ) )
		{
			point = origin + ( 0, 0, mustrenderheight );
			circle( point, radius, color, 1, 1, time );
#/
		}
	}
}

getpointonline( startpoint, endpoint, ratio )
{
	nextpoint = ( startpoint[ 0 ] + ( ( endpoint[ 0 ] - startpoint[ 0 ] ) * ratio ), startpoint[ 1 ] + ( ( endpoint[ 1 ] - startpoint[ 1 ] ) * ratio ), startpoint[ 2 ] + ( ( endpoint[ 2 ] - startpoint[ 2 ] ) * ratio ) );
	return nextpoint;
}

cantargetplayerwithspecialty()
{
	if ( self hasperk( "specialty_nottargetedbyairsupport" ) || isDefined( self.specialty_nottargetedbyairsupport ) && self.specialty_nottargetedbyairsupport )
	{
		if ( !isDefined( self.nottargettedai_underminspeedtimer ) || self.nottargettedai_underminspeedtimer < getDvarInt( "perk_nottargetedbyai_graceperiod" ) )
		{
			return 0;
		}
	}
	return 1;
}

monitorspeed( spawnprotectiontime )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( self hasperk( "specialty_nottargetedbyairsupport" ) == 0 )
	{
		return;
	}
	getDvar( #"B46C7AAF" );
	graceperiod = getDvarInt( "perk_nottargetedbyai_graceperiod" );
	minspeed = getDvarInt( "perk_nottargetedbyai_min_speed" );
	minspeedsq = minspeed * minspeed;
	waitperiod = 0,25;
	waitperiodmilliseconds = waitperiod * 1000;
	if ( minspeedsq == 0 )
	{
		return;
	}
	self.nottargettedai_underminspeedtimer = 0;
	if ( isDefined( spawnprotectiontime ) )
	{
		wait spawnprotectiontime;
	}
	while ( 1 )
	{
		velocity = self getvelocity();
		speedsq = lengthsquared( velocity );
		if ( speedsq < minspeedsq )
		{
			self.nottargettedai_underminspeedtimer += waitperiodmilliseconds;
		}
		else
		{
			self.nottargettedai_underminspeedtimer = 0;
		}
		wait waitperiod;
	}
}

clearmonitoredspeed()
{
	if ( isDefined( self.nottargettedai_underminspeedtimer ) )
	{
		self.nottargettedai_underminspeedtimer = 0;
	}
}
