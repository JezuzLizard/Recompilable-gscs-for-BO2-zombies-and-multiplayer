// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weapons;

initairsupport()
{
    if ( !isdefined( level.airsupportheightscale ) )
        level.airsupportheightscale = 1;

    level.airsupportheightscale = getdvarintdefault( "scr_airsupportHeightScale", level.airsupportheightscale );
    level.noflyzones = [];
    level.noflyzones = getentarray( "no_fly_zone", "targetname" );
    airsupport_heights = getstructarray( "air_support_height", "targetname" );
/#
    if ( airsupport_heights.size > 1 )
        error( "Found more then one 'air_support_height' structs in the map" );
#/
    airsupport_heights = getentarray( "air_support_height", "targetname" );
/#
    if ( airsupport_heights.size > 0 )
        error( "Found an entity in the map with an 'air_support_height' targetname.  There should be only structs." );
#/
    heli_height_meshes = getentarray( "heli_height_lock", "classname" );
/#
    if ( heli_height_meshes.size > 1 )
        error( "Found more then one 'heli_height_lock' classname in the map" );
#/
}

finishhardpointlocationusage( location, usedcallback )
{
    self notify( "used" );
    wait 0.05;
    return self [[ usedcallback ]]( location );
}

finishdualhardpointlocationusage( locationstart, locationend, usedcallback )
{
    self notify( "used" );
    wait 0.05;
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
    assert( isplayer( self ) );
    assert( isalive( self ) );
    assert( isdefined( self.selectinglocation ) );
    assert( self.selectinglocation == 1 );
    self thread endselectionongameend();
    self thread endselectiononhostmigration();
    event = self waittill_any_return( "death", "disconnect", "cancel_location", "game_ended", "used", "weapon_change", "emp_jammed" );

    if ( event != "disconnect" )
    {
        self endlocationselection();
        self.selectinglocation = undefined;
    }

    if ( event != "used" )
        self notify( "confirm_location", undefined, undefined );
}

stoploopsoundaftertime( time )
{
    self endon( "death" );
    wait( time );
    self stoploopsound( 2 );
}

calculatefalltime( flyheight )
{
    gravity = getdvarint( "bg_gravity" );
    time = sqrt( 2 * flyheight / gravity );
    return time;
}

calculatereleasetime( flytime, flyheight, flyspeed, bombspeedscale )
{
    falltime = calculatefalltime( flyheight );
    bomb_x = flyspeed * bombspeedscale * falltime;
    release_time = bomb_x / flyspeed;
    return flytime * 0.5 - release_time;
}

getminimumflyheight()
{
    airsupport_height = getstruct( "air_support_height", "targetname" );

    if ( isdefined( airsupport_height ) )
        planeflyheight = airsupport_height.origin[2];
    else
    {
/#
        println( "WARNING:  Missing air_support_height entity in the map.  Using default height." );
#/
        planeflyheight = 850;

        if ( isdefined( level.airsupportheightscale ) )
        {
            level.airsupportheightscale = getdvarintdefault( "scr_airsupportHeightScale", level.airsupportheightscale );
            planeflyheight *= getdvarintdefault( "scr_airsupportHeightScale", level.airsupportheightscale );
        }

        if ( isdefined( level.forceairsupportmapheight ) )
            planeflyheight += level.forceairsupportmapheight;
    }

    return planeflyheight;
}

callstrike( flightplan )
{
    level.bomberdamagedents = [];
    level.bomberdamagedentscount = 0;
    level.bomberdamagedentsindex = 0;
    assert( flightplan.distance != 0, "callStrike can not be passed a zero fly distance" );
    planehalfdistance = flightplan.distance / 2;
    path = getstrikepath( flightplan.target, flightplan.height, planehalfdistance );
    startpoint = path["start"];
    endpoint = path["end"];
    flightplan.height = path["height"];
    direction = path["direction"];
    d = length( startpoint - endpoint );
    flytime = d / flightplan.speed;
    bombtime = calculatereleasetime( flytime, flightplan.height, flightplan.speed, flightplan.bombspeedscale );

    if ( bombtime < 0 )
        bombtime = 0;

    assert( flytime > bombtime );
    flightplan.owner endon( "disconnect" );
    requireddeathcount = flightplan.owner.deathcount;
    side = vectorcross( anglestoforward( direction ), ( 0, 0, 1 ) );
    plane_seperation = 25;
    side_offset = vectorscale( side, plane_seperation );
    level thread planestrike( flightplan.owner, requireddeathcount, startpoint, endpoint, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback );
    wait( flightplan.planespacing );
    level thread planestrike( flightplan.owner, requireddeathcount, startpoint + side_offset, endpoint + side_offset, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback );
    wait( flightplan.planespacing );
    side_offset = vectorscale( side, -1 * plane_seperation );
    level thread planestrike( flightplan.owner, requireddeathcount, startpoint + side_offset, endpoint + side_offset, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback );
}

planestrike( owner, requireddeathcount, pathstart, pathend, bombtime, flytime, flyspeed, bombspeedscale, direction, planespawnedfunction )
{
    if ( !isdefined( owner ) )
        return;

    plane = spawnplane( owner, "script_model", pathstart );
    plane.angles = direction;
    plane moveto( pathend, flytime, 0, 0 );
    thread debug_plane_line( flytime, flyspeed, pathstart, pathend );

    if ( isdefined( planespawnedfunction ) )
        plane [[ planespawnedfunction ]]( owner, requireddeathcount, pathstart, pathend, bombtime, bombspeedscale, flytime, flyspeed );

    wait( flytime );
    plane notify( "delete" );
    plane delete();
}

determinegroundpoint( player, position )
{
    ground = ( position[0], position[1], player.origin[2] );
    trace = bullettrace( ground + vectorscale( ( 0, 0, 1 ), 10000.0 ), ground, 0, undefined );
    return trace["position"];
}

determinetargetpoint( player, position )
{
    point = determinegroundpoint( player, position );
    return clamptarget( point );
}

getmintargetheight()
{
    return level.spawnmins[2] - 500;
}

getmaxtargetheight()
{
    return level.spawnmaxs[2] + 500;
}

clamptarget( target )
{
    min = getmintargetheight();
    max = getmaxtargetheight();

    if ( target[2] < min )
        target[2] = min;

    if ( target[2] > max )
        target[2] = max;

    return target;
}

_insidecylinder( point, base, radius, height )
{
    if ( isdefined( height ) )
    {
        if ( point[2] > base[2] + height )
            return false;
    }

    dist = distance2d( point, base );

    if ( dist < radius )
        return true;

    return false;
}

_insidenoflyzonebyindex( point, index, disregardheight )
{
    height = level.noflyzones[index].height;

    if ( isdefined( disregardheight ) )
        height = undefined;

    return _insidecylinder( point, level.noflyzones[index].origin, level.noflyzones[index].radius, height );
}

getnoflyzoneheight( point )
{
    height = point[2];
    origin = undefined;

    for ( i = 0; i < level.noflyzones.size; i++ )
    {
        if ( _insidenoflyzonebyindex( point, i ) )
        {
            if ( height < level.noflyzones[i].height )
            {
                height = level.noflyzones[i].height;
                origin = level.noflyzones[i].origin;
            }
        }
    }

    if ( !isdefined( origin ) )
        return point[2];

    return origin[2] + height;
}

insidenoflyzones( point, disregardheight )
{
    noflyzones = [];

    for ( i = 0; i < level.noflyzones.size; i++ )
    {
        if ( _insidenoflyzonebyindex( point, i, disregardheight ) )
            noflyzones[noflyzones.size] = i;
    }

    return noflyzones;
}

crossesnoflyzone( start, end )
{
    for ( i = 0; i < level.noflyzones.size; i++ )
    {
        point = closestpointonline( level.noflyzones[i].origin + ( 0, 0, 0.5 * level.noflyzones[i].height ), start, end );
        dist = distance2d( point, level.noflyzones[i].origin );

        if ( point[2] > level.noflyzones[i].origin[2] + level.noflyzones[i].height )
            continue;

        if ( dist < level.noflyzones[i].radius )
            return i;
    }

    return undefined;
}

crossesnoflyzones( start, end )
{
    zones = [];

    for ( i = 0; i < level.noflyzones.size; i++ )
    {
        point = closestpointonline( level.noflyzones[i].origin, start, end );
        dist = distance2d( point, level.noflyzones[i].origin );

        if ( point[2] > level.noflyzones[i].origin[2] + level.noflyzones[i].height )
            continue;

        if ( dist < level.noflyzones[i].radius )
            zones[zones.size] = i;
    }

    return zones;
}

getnoflyzoneheightcrossed( start, end, minheight )
{
    height = minheight;

    for ( i = 0; i < level.noflyzones.size; i++ )
    {
        point = closestpointonline( level.noflyzones[i].origin, start, end );
        dist = distance2d( point, level.noflyzones[i].origin );

        if ( dist < level.noflyzones[i].radius )
        {
            if ( height < level.noflyzones[i].height )
                height = level.noflyzones[i].height;
        }
    }

    return height;
}

_shouldignorenoflyzone( noflyzone, noflyzones )
{
    if ( !isdefined( noflyzone ) )
        return true;

    for ( i = 0; i < noflyzones.size; i++ )
    {
        if ( isdefined( noflyzones[i] ) && noflyzones[i] == noflyzone )
            return true;
    }

    return false;
}

_shouldignorestartgoalnoflyzone( noflyzone, startnoflyzones, goalnoflyzones )
{
    if ( !isdefined( noflyzone ) )
        return true;

    if ( _shouldignorenoflyzone( noflyzone, startnoflyzones ) )
        return true;

    if ( _shouldignorenoflyzone( noflyzone, goalnoflyzones ) )
        return true;

    return false;
}

gethelipath( start, goal )
{
    startnoflyzones = insidenoflyzones( start, 1 );
    thread debug_line( start, goal, ( 1, 1, 1 ) );
    goalnoflyzones = insidenoflyzones( goal );

    if ( goalnoflyzones.size )
        goal = ( goal[0], goal[1], getnoflyzoneheight( goal ) );

    goal_points = calculatepath( start, goal, startnoflyzones, goalnoflyzones );

    if ( !isdefined( goal_points ) )
        return undefined;

    assert( goal_points.size >= 1 );
    return goal_points;
}

followpath( path, donenotify, stopatgoal )
{
    for ( i = 0; i < path.size - 1; i++ )
    {
        self setvehgoalpos( path[i], 0 );
        thread debug_line( self.origin, path[i], ( 1, 1, 0 ) );

        self waittill( "goal" );
    }

    self setvehgoalpos( path[path.size - 1], stopatgoal );
    thread debug_line( self.origin, path[i], ( 1, 1, 0 ) );

    self waittill( "goal" );

    if ( isdefined( donenotify ) )
        self notify( donenotify );
}

setgoalposition( goal, donenotify, stopatgoal = 1 )
{
    start = self.origin;
    goal_points = gethelipath( start, goal );

    if ( !isdefined( goal_points ) )
    {
        goal_points = [];
        goal_points[0] = goal;
    }

    followpath( goal_points, donenotify, stopatgoal );
}

clearpath( start, end, startnoflyzone, goalnoflyzone )
{
    noflyzones = crossesnoflyzones( start, end );

    for ( i = 0; i < noflyzones.size; i++ )
    {
        if ( !_shouldignorestartgoalnoflyzone( noflyzones[i], startnoflyzone, goalnoflyzone ) )
            return false;
    }

    return true;
}

append_array( dst, src )
{
    for ( i = 0; i < src.size; i++ )
        dst[dst.size] = src[i];
}

calculatepath_r( start, end, points, startnoflyzones, goalnoflyzones, depth )
{
    depth--;

    if ( depth <= 0 )
    {
        points[points.size] = end;
        return points;
    }

    noflyzones = crossesnoflyzones( start, end );

    for ( i = 0; i < noflyzones.size; i++ )
    {
        noflyzone = noflyzones[i];

        if ( !_shouldignorestartgoalnoflyzone( noflyzone, startnoflyzones, goalnoflyzones ) )
            return undefined;
    }

    points[points.size] = end;
    return points;
}

calculatepath( start, end, startnoflyzones, goalnoflyzones )
{
    points = [];
    points = calculatepath_r( start, end, points, startnoflyzones, goalnoflyzones, 3 );

    if ( !isdefined( points ) )
        return undefined;

    assert( points.size >= 1 );
    debug_sphere( points[points.size - 1], 10, ( 1, 0, 0 ), 1, 1000 );
    point = start;

    for ( i = 0; i < points.size; i++ )
    {
        thread debug_line( point, points[i], ( 0, 1, 0 ) );
        debug_sphere( points[i], 10, ( 0, 0, 1 ), 1, 1000 );
        point = points[i];
    }

    return points;
}

_getstrikepathstartandend( goal, yaw, halfdistance )
{
    direction = ( 0, yaw, 0 );
    startpoint = goal + vectorscale( anglestoforward( direction ), -1 * halfdistance );
    endpoint = goal + vectorscale( anglestoforward( direction ), halfdistance );
    noflyzone = crossesnoflyzone( startpoint, endpoint );
    path = [];

    if ( isdefined( noflyzone ) )
    {
        path["noFlyZone"] = noflyzone;
        startpoint = ( startpoint[0], startpoint[1], level.noflyzones[noflyzone].origin[2] + level.noflyzones[noflyzone].height );
        endpoint = ( endpoint[0], endpoint[1], startpoint[2] );
    }
    else
        path["noFlyZone"] = undefined;

    path["start"] = startpoint;
    path["end"] = endpoint;
    path["direction"] = direction;
    return path;
}

getstrikepath( target, height, halfdistance, yaw )
{
    noflyzoneheight = getnoflyzoneheight( target );
    worldheight = target[2] + height;

    if ( noflyzoneheight > worldheight )
        worldheight = noflyzoneheight;

    goal = ( target[0], target[1], worldheight );
    path = [];

    if ( !isdefined( yaw ) || yaw != "random" )
    {
        for ( i = 0; i < 3; i++ )
        {
            path = _getstrikepathstartandend( goal, randomint( 360 ), halfdistance );

            if ( !isdefined( path["noFlyZone"] ) )
                break;
        }
    }
    else
        path = _getstrikepathstartandend( goal, yaw, halfdistance );

    path["height"] = worldheight - target[2];
    return path;
}

doglassdamage( pos, radius, max, min, mod )
{
    wait( randomfloatrange( 0.05, 0.15 ) );
    glassradiusdamage( pos, radius, max, min, mod );
}

entlosradiusdamage( ent, pos, radius, max, min, owner, einflictor )
{
    dist = distance( pos, ent.damagecenter );

    if ( ent.isplayer || ent.isactor )
    {
        assumed_ceiling_height = 800;
        eye_position = ent.entity geteye();
        head_height = eye_position[2];
        debug_display_time = 4000;
        trace = maps\mp\gametypes\_weapons::weapondamagetrace( ent.entity.origin, ent.entity.origin + ( 0, 0, assumed_ceiling_height ), 0, undefined );
        indoors = trace["fraction"] != 1;

        if ( indoors )
        {
            test_point = trace["position"];
            debug_star( test_point, ( 0, 1, 0 ), debug_display_time );
            trace = maps\mp\gametypes\_weapons::weapondamagetrace( ( test_point[0], test_point[1], head_height ), ( pos[0], pos[1], head_height ), 0, undefined );
            indoors = trace["fraction"] != 1;

            if ( indoors )
            {
                debug_star( ( pos[0], pos[1], head_height ), ( 0, 1, 0 ), debug_display_time );
                dist *= 4;

                if ( dist > radius )
                    return false;
            }
            else
            {
                debug_star( ( pos[0], pos[1], head_height ), ( 1, 0, 0 ), debug_display_time );
                trace = maps\mp\gametypes\_weapons::weapondamagetrace( ( pos[0], pos[1], head_height ), pos, 0, undefined );
                indoors = trace["fraction"] != 1;

                if ( indoors )
                {
                    debug_star( pos, ( 0, 1, 0 ), debug_display_time );
                    dist *= 4;

                    if ( dist > radius )
                        return false;
                }
                else
                    debug_star( pos, ( 1, 0, 0 ), debug_display_time );
            }
        }
        else
            debug_star( ent.entity.origin + ( 0, 0, assumed_ceiling_height ), ( 1, 0, 0 ), debug_display_time );
    }

    ent.damage = int( max + ( min - max ) * dist / radius );
    ent.pos = pos;
    ent.damageowner = owner;
    ent.einflictor = einflictor;
    return true;
}

debug_no_fly_zones()
{
/#
    for ( i = 0; i < level.noflyzones.size; i++ )
        debug_cylinder( level.noflyzones[i].origin, level.noflyzones[i].radius, level.noflyzones[i].height, ( 1, 1, 1 ), undefined, 5000 );
#/
}

debug_plane_line( flytime, flyspeed, pathstart, pathend )
{
    thread debug_line( pathstart, pathend, ( 1, 1, 1 ) );
    delta = vectornormalize( pathend - pathstart );

    for ( i = 0; i < flytime; i++ )
        thread debug_star( pathstart + vectorscale( delta, i * flyspeed ), ( 1, 0, 0 ) );
}

debug_draw_bomb_explosion( prevpos )
{
    self notify( "draw_explosion" );
    wait 0.05;
    self endon( "draw_explosion" );

    self waittill( "projectile_impact", weapon, position );

    thread debug_line( prevpos, position, ( 0.5, 1, 0 ) );
    thread debug_star( position, ( 1, 0, 0 ) );
}

debug_draw_bomb_path( projectile, color, time )
{
/#
    self endon( "death" );
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( !isdefined( color ) )
        color = ( 0.5, 1, 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1.0 )
    {
        prevpos = self.origin;

        while ( isdefined( self.origin ) )
        {
            thread debug_line( prevpos, self.origin, color, time );
            prevpos = self.origin;

            if ( isdefined( projectile ) && projectile )
                thread debug_draw_bomb_explosion( prevpos );

            wait 0.2;
        }
    }
#/
}

debug_print3d_simple( message, ent, offset, frames )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1.0 )
    {
        if ( isdefined( frames ) )
            thread draw_text( message, vectorscale( ( 1, 1, 1 ), 0.8 ), ent, offset, frames );
        else
            thread draw_text( message, vectorscale( ( 1, 1, 1 ), 0.8 ), ent, offset, 0 );
    }
#/
}

draw_text( msg, color, ent, offset, frames )
{
/#
    if ( frames == 0 )
    {
        while ( isdefined( ent ) && isdefined( ent.origin ) )
        {
            print3d( ent.origin + offset, msg, color, 0.5, 4 );
            wait 0.05;
        }
    }
    else
    {
        for ( i = 0; i < frames; i++ )
        {
            if ( !isdefined( ent ) )
                break;

            print3d( ent.origin + offset, msg, color, 0.5, 4 );
            wait 0.05;
        }
    }
#/
}

debug_print3d( message, color, ent, origin_offset, frames )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1.0 )
        self thread draw_text( message, color, ent, origin_offset, frames );
#/
}

debug_line( from, to, color, time, depthtest )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1.0 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( depthtest ) )
            depthtest = 1;

        line( from, to, color, 1, depthtest, time );
    }
#/
}

debug_star( origin, color, time )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1.0 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        debugstar( origin, time, color );
    }
#/
}

debug_circle( origin, radius, color, time )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        circle( origin, radius, color, 1, 1, time );
    }
#/
}

debug_sphere( origin, radius, color, alpha, time )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        sides = int( 10 * ( 1 + int( radius / 100 ) ) );
        sphere( origin, radius, color, alpha, 1, sides, time );
    }
#/
}

debug_cylinder( origin, radius, height, color, mustrenderheight, time )
{
/#
    level.airsupport_debug = getdvarintdefault( "scr_airsupport_debug", 0 );
    subdivision = 600;

    if ( isdefined( level.airsupport_debug ) && level.airsupport_debug == 1 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        count = height / subdivision;

        for ( i = 0; i < count; i++ )
        {
            point = origin + ( 0, 0, i * subdivision );
            circle( point, radius, color, 1, 1, time );
        }

        if ( isdefined( mustrenderheight ) )
        {
            point = origin + ( 0, 0, mustrenderheight );
            circle( point, radius, color, 1, 1, time );
        }
    }
#/
}

getpointonline( startpoint, endpoint, ratio )
{
    nextpoint = ( startpoint[0] + ( endpoint[0] - startpoint[0] ) * ratio, startpoint[1] + ( endpoint[1] - startpoint[1] ) * ratio, startpoint[2] + ( endpoint[2] - startpoint[2] ) * ratio );
    return nextpoint;
}

cantargetplayerwithspecialty()
{
    if ( self hasperk( "specialty_nottargetedbyairsupport" ) || isdefined( self.specialty_nottargetedbyairsupport ) && self.specialty_nottargetedbyairsupport )
    {
        if ( !isdefined( self.nottargettedai_underminspeedtimer ) || self.nottargettedai_underminspeedtimer < getdvarint( "perk_nottargetedbyai_graceperiod" ) )
            return false;
    }

    return true;
}

monitorspeed( spawnprotectiontime )
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( self hasperk( "specialty_nottargetedbyairsupport" ) == 0 )
        return;

    getdvar( _hash_B46C7AAF );
    graceperiod = getdvarint( "perk_nottargetedbyai_graceperiod" );
    minspeed = getdvarint( "perk_nottargetedbyai_min_speed" );
    minspeedsq = minspeed * minspeed;
    waitperiod = 0.25;
    waitperiodmilliseconds = waitperiod * 1000;

    if ( minspeedsq == 0 )
        return;

    self.nottargettedai_underminspeedtimer = 0;

    if ( isdefined( spawnprotectiontime ) )
        wait( spawnprotectiontime );

    while ( true )
    {
        velocity = self getvelocity();
        speedsq = lengthsquared( velocity );

        if ( speedsq < minspeedsq )
            self.nottargettedai_underminspeedtimer += waitperiodmilliseconds;
        else
            self.nottargettedai_underminspeedtimer = 0;

        wait( waitperiod );
    }
}

clearmonitoredspeed()
{
    if ( isdefined( self.nottargettedai_underminspeedtimer ) )
        self.nottargettedai_underminspeedtimer = 0;
}
