// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_callbacksetup;
#include maps\mp\gametypes_zm\_gameobjects;
#include maps\mp\gametypes_zm\_spawnlogic;

onplayerconnect()
{
    for (;;)
        level waittill( "connected", player );
}

findboxcenter( mins, maxs )
{
    center = ( 0, 0, 0 );
    center = maxs - mins;
    center = ( center[0] / 2, center[1] / 2, center[2] / 2 ) + mins;
    return center;
}

expandmins( mins, point )
{
    if ( mins[0] > point[0] )
        mins = ( point[0], mins[1], mins[2] );

    if ( mins[1] > point[1] )
        mins = ( mins[0], point[1], mins[2] );

    if ( mins[2] > point[2] )
        mins = ( mins[0], mins[1], point[2] );

    return mins;
}

expandmaxs( maxs, point )
{
    if ( maxs[0] < point[0] )
        maxs = ( point[0], maxs[1], maxs[2] );

    if ( maxs[1] < point[1] )
        maxs = ( maxs[0], point[1], maxs[2] );

    if ( maxs[2] < point[2] )
        maxs = ( maxs[0], maxs[1], point[2] );

    return maxs;
}

addspawnpointsinternal( team, spawnpointname )
{
    oldspawnpoints = [];

    if ( level.teamspawnpoints[team].size )
        oldspawnpoints = level.teamspawnpoints[team];

    level.teamspawnpoints[team] = getspawnpointarray( spawnpointname );

    if ( !isdefined( level.spawnpoints ) )
        level.spawnpoints = [];

    for ( index = 0; index < level.teamspawnpoints[team].size; index++ )
    {
        spawnpoint = level.teamspawnpoints[team][index];

        if ( !isdefined( spawnpoint.inited ) )
        {
            spawnpoint spawnpointinit();
            level.spawnpoints[level.spawnpoints.size] = spawnpoint;
        }
    }

    for ( index = 0; index < oldspawnpoints.size; index++ )
    {
        origin = oldspawnpoints[index].origin;
        level.spawnmins = expandmins( level.spawnmins, origin );
        level.spawnmaxs = expandmaxs( level.spawnmaxs, origin );
        level.teamspawnpoints[team][level.teamspawnpoints[team].size] = oldspawnpoints[index];
    }

    if ( !level.teamspawnpoints[team].size )
    {
/#
        println( "^1ERROR: No " + spawnpointname + " spawnpoints found in level!" );
#/
        maps\mp\gametypes_zm\_callbacksetup::abortlevel();
        wait 1;
        return;
    }
}

clearspawnpoints()
{
    foreach ( team in level.teams )
        level.teamspawnpoints[team] = [];

    level.spawnpoints = [];
    level.unified_spawn_points = undefined;
}

addspawnpoints( team, spawnpointname )
{
    addspawnpointclassname( spawnpointname );
    addspawnpointteamclassname( team, spawnpointname );
    addspawnpointsinternal( team, spawnpointname );
}

rebuildspawnpoints( team )
{
    level.teamspawnpoints[team] = [];

    for ( index = 0; index < level.spawn_point_team_class_names[team].size; index++ )
        addspawnpointsinternal( team, level.spawn_point_team_class_names[team][index] );
}

placespawnpoints( spawnpointname )
{
    addspawnpointclassname( spawnpointname );
    spawnpoints = getspawnpointarray( spawnpointname );
/#
    if ( !isdefined( level.extraspawnpointsused ) )
        level.extraspawnpointsused = [];
#/
    if ( !spawnpoints.size )
    {
/#
        println( "^1No " + spawnpointname + " spawnpoints found in level!" );
#/
        maps\mp\gametypes_zm\_callbacksetup::abortlevel();
        wait 1;
        return;
    }

    for ( index = 0; index < spawnpoints.size; index++ )
    {
        spawnpoints[index] spawnpointinit();
/#
        spawnpoints[index].fakeclassname = spawnpointname;
        level.extraspawnpointsused[level.extraspawnpointsused.size] = spawnpoints[index];
#/
    }
}

dropspawnpoints( spawnpointname )
{
    spawnpoints = getspawnpointarray( spawnpointname );

    if ( !spawnpoints.size )
    {
/#
        println( "^1No " + spawnpointname + " spawnpoints found in level!" );
#/
        return;
    }

    for ( index = 0; index < spawnpoints.size; index++ )
        spawnpoints[index] placespawnpoint();
}

addspawnpointclassname( spawnpointclassname )
{
    if ( !isdefined( level.spawn_point_class_names ) )
        level.spawn_point_class_names = [];

    level.spawn_point_class_names[level.spawn_point_class_names.size] = spawnpointclassname;
}

addspawnpointteamclassname( team, spawnpointclassname )
{
    level.spawn_point_team_class_names[team][level.spawn_point_team_class_names[team].size] = spawnpointclassname;
}

getspawnpointarray( classname )
{
    spawnpoints = getentarray( classname, "classname" );

    if ( !isdefined( level.extraspawnpoints ) || !isdefined( level.extraspawnpoints[classname] ) )
        return spawnpoints;

    for ( i = 0; i < level.extraspawnpoints[classname].size; i++ )
        spawnpoints[spawnpoints.size] = level.extraspawnpoints[classname][i];

    return spawnpoints;
}

spawnpointinit()
{
    spawnpoint = self;
    origin = spawnpoint.origin;

    if ( !level.spawnminsmaxsprimed )
    {
        level.spawnmins = origin;
        level.spawnmaxs = origin;
        level.spawnminsmaxsprimed = 1;
    }
    else
    {
        level.spawnmins = expandmins( level.spawnmins, origin );
        level.spawnmaxs = expandmaxs( level.spawnmaxs, origin );
    }

    spawnpoint placespawnpoint();
    spawnpoint.forward = anglestoforward( spawnpoint.angles );
    spawnpoint.sighttracepoint = spawnpoint.origin + vectorscale( ( 0, 0, 1 ), 50.0 );
    spawnpoint.inited = 1;
}

getteamspawnpoints( team )
{
    return level.teamspawnpoints[team];
}

getspawnpoint_final( spawnpoints, useweights )
{
    bestspawnpoint = undefined;

    if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
        return undefined;

    if ( !isdefined( useweights ) )
        useweights = 1;

    if ( useweights )
    {
        bestspawnpoint = getbestweightedspawnpoint( spawnpoints );
        thread spawnweightdebug( spawnpoints );
    }
    else
    {
        for ( i = 0; i < spawnpoints.size; i++ )
        {
            if ( isdefined( self.lastspawnpoint ) && self.lastspawnpoint == spawnpoints[i] )
                continue;

            if ( positionwouldtelefrag( spawnpoints[i].origin ) )
                continue;

            bestspawnpoint = spawnpoints[i];
            break;
        }

        if ( !isdefined( bestspawnpoint ) )
        {
            if ( isdefined( self.lastspawnpoint ) && !positionwouldtelefrag( self.lastspawnpoint.origin ) )
            {
                for ( i = 0; i < spawnpoints.size; i++ )
                {
                    if ( spawnpoints[i] == self.lastspawnpoint )
                    {
                        bestspawnpoint = spawnpoints[i];
                        break;
                    }
                }
            }
        }
    }

    if ( !isdefined( bestspawnpoint ) )
    {
        if ( useweights )
            bestspawnpoint = spawnpoints[randomint( spawnpoints.size )];
        else
            bestspawnpoint = spawnpoints[0];
    }

    self finalizespawnpointchoice( bestspawnpoint );
/#
    self storespawndata( spawnpoints, useweights, bestspawnpoint );
#/
    return bestspawnpoint;
}

finalizespawnpointchoice( spawnpoint )
{
    time = gettime();
    self.lastspawnpoint = spawnpoint;
    self.lastspawntime = time;
    spawnpoint.lastspawnedplayer = self;
    spawnpoint.lastspawntime = time;
}

getbestweightedspawnpoint( spawnpoints )
{
    maxsighttracedspawnpoints = 3;

    for ( try = 0; try <= maxsighttracedspawnpoints; try++ )
    {
        bestspawnpoints = [];
        bestweight = undefined;
        bestspawnpoint = undefined;

        for ( i = 0; i < spawnpoints.size; i++ )
        {
            if ( !isdefined( bestweight ) || spawnpoints[i].weight > bestweight )
            {
                if ( positionwouldtelefrag( spawnpoints[i].origin ) )
                    continue;

                bestspawnpoints = [];
                bestspawnpoints[0] = spawnpoints[i];
                bestweight = spawnpoints[i].weight;
                continue;
            }

            if ( spawnpoints[i].weight == bestweight )
            {
                if ( positionwouldtelefrag( spawnpoints[i].origin ) )
                    continue;

                bestspawnpoints[bestspawnpoints.size] = spawnpoints[i];
            }
        }

        if ( bestspawnpoints.size == 0 )
            return undefined;

        bestspawnpoint = bestspawnpoints[randomint( bestspawnpoints.size )];

        if ( try == maxsighttracedspawnpoints )
            return bestspawnpoint;

        if ( isdefined( bestspawnpoint.lastsighttracetime ) && bestspawnpoint.lastsighttracetime == gettime() )
            return bestspawnpoint;

        if ( !lastminutesighttraces( bestspawnpoint ) )
            return bestspawnpoint;

        penalty = getlospenalty();
/#
        if ( level.storespawndata || level.debugspawning )
            bestspawnpoint.spawndata[bestspawnpoint.spawndata.size] = "Last minute sight trace: -" + penalty;
#/
        bestspawnpoint.weight -= penalty;
        bestspawnpoint.lastsighttracetime = gettime();
    }
}

checkbad( spawnpoint )
{
/#
    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( !isalive( player ) || player.sessionstate != "playing" )
            continue;

        if ( level.teambased && player.team == self.team )
            continue;

        losexists = bullettracepassed( player.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), spawnpoint.sighttracepoint, 0, undefined );

        if ( losexists )
            thread badspawnline( spawnpoint.sighttracepoint, player.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), self.name, player.name );
    }
#/
}

badspawnline( start, end, name1, name2 )
{
/#
    dist = distance( start, end );

    for ( i = 0; i < 200; i++ )
    {
        line( start, end, ( 1, 0, 0 ) );
        print3d( start, "Bad spawn! " + name1 + ", dist = " + dist );
        print3d( end, name2 );
        wait 0.05;
    }
#/
}

storespawndata( spawnpoints, useweights, bestspawnpoint )
{
/#
    if ( !isdefined( level.storespawndata ) || !level.storespawndata )
        return;

    level.storespawndata = getdvarint( "scr_recordspawndata" );

    if ( !level.storespawndata )
        return;

    if ( !isdefined( level.spawnid ) )
    {
        level.spawngameid = randomint( 100 );
        level.spawnid = 0;
    }

    if ( bestspawnpoint.classname == "mp_global_intermission" )
        return;

    level.spawnid++;
    file = openfile( "spawndata.txt", "append" );
    fprintfields( file, level.spawngameid + "." + level.spawnid + "," + spawnpoints.size + "," + self.name );

    for ( i = 0; i < spawnpoints.size; i++ )
    {
        str = vectostr( spawnpoints[i].origin ) + ",";

        if ( spawnpoints[i] == bestspawnpoint )
            str += "1,";
        else
            str += "0,";

        if ( !useweights )
            str += "0,";
        else
            str += ( spawnpoints[i].weight + "," );

        if ( !isdefined( spawnpoints[i].spawndata ) )
            spawnpoints[i].spawndata = [];

        if ( !isdefined( spawnpoints[i].sightchecks ) )
            spawnpoints[i].sightchecks = [];

        str += ( spawnpoints[i].spawndata.size + "," );

        for ( j = 0; j < spawnpoints[i].spawndata.size; j++ )
            str += ( spawnpoints[i].spawndata[j] + "," );

        str += ( spawnpoints[i].sightchecks.size + "," );

        for ( j = 0; j < spawnpoints[i].sightchecks.size; j++ )
            str += ( spawnpoints[i].sightchecks[j].penalty + "," + vectostr( spawnpoints[i].origin ) + "," );

        fprintfields( file, str );
    }

    obj = spawnstruct();
    getallalliedandenemyplayers( obj );
    numallies = 0;
    numenemies = 0;
    str = "";

    for ( i = 0; i < obj.allies.size; i++ )
    {
        if ( obj.allies[i] == self )
            continue;

        numallies++;
        str += ( vectostr( obj.allies[i].origin ) + "," );
    }

    for ( i = 0; i < obj.enemies.size; i++ )
    {
        numenemies++;
        str += ( vectostr( obj.enemies[i].origin ) + "," );
    }

    str = numallies + "," + numenemies + "," + str;
    fprintfields( file, str );
    otherdata = [];

    if ( isdefined( level.bombguy ) )
    {
        index = otherdata.size;
        otherdata[index] = spawnstruct();
        otherdata[index].origin = level.bombguy.origin + vectorscale( ( 0, 0, 1 ), 20.0 );
        otherdata[index].text = "Bomb holder";
    }
    else if ( isdefined( level.bombpos ) )
    {
        index = otherdata.size;
        otherdata[index] = spawnstruct();
        otherdata[index].origin = level.bombpos;
        otherdata[index].text = "Bomb";
    }

    if ( isdefined( level.flags ) )
    {
        for ( i = 0; i < level.flags.size; i++ )
        {
            index = otherdata.size;
            otherdata[index] = spawnstruct();
            otherdata[index].origin = level.flags[i].origin;
            otherdata[index].text = level.flags[i].useobj maps\mp\gametypes_zm\_gameobjects::getownerteam() + " flag";
        }
    }

    str = otherdata.size + ",";

    for ( i = 0; i < otherdata.size; i++ )
        str += ( vectostr( otherdata[i].origin ) + "," + otherdata[i].text + "," );

    fprintfields( file, str );
    closefile( file );
    thisspawnid = level.spawngameid + "." + level.spawnid;

    if ( isdefined( self.thisspawnid ) )
    {

    }

    self.thisspawnid = thisspawnid;
#/
}

readspawndata( desiredid, relativepos )
{
/#
    file = openfile( "spawndata.txt", "read" );

    if ( file < 0 )
        return;

    oldspawndata = level.curspawndata;
    level.curspawndata = undefined;
    prev = undefined;
    prevthisplayer = undefined;
    lookingfornextthisplayer = 0;
    lookingfornext = 0;

    if ( isdefined( relativepos ) && !isdefined( oldspawndata ) )
        return;

    while ( true )
    {
        if ( freadln( file ) <= 0 )
            break;

        data = spawnstruct();
        data.id = fgetarg( file, 0 );
        numspawns = int( fgetarg( file, 1 ) );

        if ( numspawns > 256 )
            break;

        data.playername = fgetarg( file, 2 );
        data.spawnpoints = [];
        data.friends = [];
        data.enemies = [];
        data.otherdata = [];

        for ( i = 0; i < numspawns; i++ )
        {
            if ( freadln( file ) <= 0 )
                break;

            spawnpoint = spawnstruct();
            spawnpoint.origin = strtovec( fgetarg( file, 0 ) );
            spawnpoint.winner = int( fgetarg( file, 1 ) );
            spawnpoint.weight = int( fgetarg( file, 2 ) );
            spawnpoint.data = [];
            spawnpoint.sightchecks = [];

            if ( i == 0 )
            {
                data.minweight = spawnpoint.weight;
                data.maxweight = spawnpoint.weight;
            }
            else
            {
                if ( spawnpoint.weight < data.minweight )
                    data.minweight = spawnpoint.weight;

                if ( spawnpoint.weight > data.maxweight )
                    data.maxweight = spawnpoint.weight;
            }

            argnum = 4;
            numdata = int( fgetarg( file, 3 ) );

            if ( numdata > 256 )
                break;

            for ( j = 0; j < numdata; j++ )
            {
                spawnpoint.data[spawnpoint.data.size] = fgetarg( file, argnum );
                argnum++;
            }

            numsightchecks = int( fgetarg( file, argnum ) );
            argnum++;

            if ( numsightchecks > 256 )
                break;

            for ( j = 0; j < numsightchecks; j++ )
            {
                index = spawnpoint.sightchecks.size;
                spawnpoint.sightchecks[index] = spawnstruct();
                spawnpoint.sightchecks[index].penalty = int( fgetarg( file, argnum ) );
                argnum++;
                spawnpoint.sightchecks[index].origin = strtovec( fgetarg( file, argnum ) );
                argnum++;
            }

            data.spawnpoints[data.spawnpoints.size] = spawnpoint;
        }

        if ( !isdefined( data.minweight ) )
        {
            data.minweight = -1;
            data.maxweight = 0;
        }

        if ( data.minweight == data.maxweight )
            data.minweight -= 1;

        if ( freadln( file ) <= 0 )
            break;

        numfriends = int( fgetarg( file, 0 ) );
        numenemies = int( fgetarg( file, 1 ) );

        if ( numfriends > 32 || numenemies > 32 )
            break;

        argnum = 2;

        for ( i = 0; i < numfriends; i++ )
        {
            data.friends[data.friends.size] = strtovec( fgetarg( file, argnum ) );
            argnum++;
        }

        for ( i = 0; i < numenemies; i++ )
        {
            data.enemies[data.enemies.size] = strtovec( fgetarg( file, argnum ) );
            argnum++;
        }

        if ( freadln( file ) <= 0 )
            break;

        numotherdata = int( fgetarg( file, 0 ) );
        argnum = 1;

        for ( i = 0; i < numotherdata; i++ )
        {
            otherdata = spawnstruct();
            otherdata.origin = strtovec( fgetarg( file, argnum ) );
            argnum++;
            otherdata.text = fgetarg( file, argnum );
            argnum++;
            data.otherdata[data.otherdata.size] = otherdata;
        }

        if ( isdefined( relativepos ) )
        {
            if ( relativepos == "prevthisplayer" )
            {
                if ( data.id == oldspawndata.id )
                {
                    level.curspawndata = prevthisplayer;
                    break;
                }
            }
            else if ( relativepos == "prev" )
            {
                if ( data.id == oldspawndata.id )
                {
                    level.curspawndata = prev;
                    break;
                }
            }
            else if ( relativepos == "nextthisplayer" )
            {
                if ( lookingfornextthisplayer )
                {
                    level.curspawndata = data;
                    break;
                }
                else if ( data.id == oldspawndata.id )
                    lookingfornextthisplayer = 1;
            }
            else if ( relativepos == "next" )
            {
                if ( lookingfornext )
                {
                    level.curspawndata = data;
                    break;
                }
                else if ( data.id == oldspawndata.id )
                    lookingfornext = 1;
            }
        }
        else if ( data.id == desiredid )
        {
            level.curspawndata = data;
            break;
        }

        prev = data;

        if ( isdefined( oldspawndata ) && data.playername == oldspawndata.playername )
            prevthisplayer = data;
    }

    closefile( file );
#/
}

drawspawndata()
{
/#
    level notify( "drawing_spawn_data" );
    level endon( "drawing_spawn_data" );
    textoffset = vectorscale( ( 0, 0, -1 ), 12.0 );

    while ( true )
    {
        if ( !isdefined( level.curspawndata ) )
        {
            wait 0.5;
            continue;
        }

        for ( i = 0; i < level.curspawndata.friends.size; i++ )
            print3d( level.curspawndata.friends[i], "=)", ( 0.5, 1, 0.5 ), 1, 5 );

        for ( i = 0; i < level.curspawndata.enemies.size; i++ )
            print3d( level.curspawndata.enemies[i], "=(", ( 1, 0.5, 0.5 ), 1, 5 );

        for ( i = 0; i < level.curspawndata.otherdata.size; i++ )
            print3d( level.curspawndata.otherdata[i].origin, level.curspawndata.otherdata[i].text, ( 0.5, 0.75, 1 ), 1, 2 );

        for ( i = 0; i < level.curspawndata.spawnpoints.size; i++ )
        {
            sp = level.curspawndata.spawnpoints[i];
            orig = sp.sighttracepoint;

            if ( sp.winner )
            {
                print3d( orig, level.curspawndata.playername + " spawned here", ( 0.5, 0.5, 1 ), 1, 2 );
                orig += textoffset;
            }

            amnt = ( sp.weight - level.curspawndata.minweight ) / ( level.curspawndata.maxweight - level.curspawndata.minweight );
            print3d( orig, "Weight: " + sp.weight, ( 1 - amnt, amnt, 0.5 ) );
            orig += textoffset;

            for ( j = 0; j < sp.data.size; j++ )
            {
                print3d( orig, sp.data[j], ( 1, 1, 1 ) );
                orig += textoffset;
            }

            for ( j = 0; j < sp.sightchecks.size; j++ )
            {
                print3d( orig, "Sightchecks: -" + sp.sightchecks[j].penalty, ( 1, 0.5, 0.5 ) );
                orig += textoffset;
            }
        }

        wait 0.05;
    }
#/
}

vectostr( vec )
{
/#
    return int( vec[0] ) + "/" + int( vec[1] ) + "/" + int( vec[2] );
#/
}

strtovec( str )
{
/#
    parts = strtok( str, "/" );

    if ( parts.size != 3 )
        return ( 0, 0, 0 );

    return ( int( parts[0] ), int( parts[1] ), int( parts[2] ) );
#/
}

getspawnpoint_random( spawnpoints )
{
    if ( !isdefined( spawnpoints ) )
        return undefined;

    for ( i = 0; i < spawnpoints.size; i++ )
    {
        j = randomint( spawnpoints.size );
        spawnpoint = spawnpoints[i];
        spawnpoints[i] = spawnpoints[j];
        spawnpoints[j] = spawnpoint;
    }

    return getspawnpoint_final( spawnpoints, 0 );
}

getallotherplayers()
{
    aliveplayers = [];

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( !isdefined( level.players[i] ) )
            continue;

        player = level.players[i];

        if ( player.sessionstate != "playing" || player == self )
            continue;

        if ( isdefined( level.customalivecheck ) )
        {
            if ( ![[ level.customalivecheck ]]( player ) )
                continue;
        }

        aliveplayers[aliveplayers.size] = player;
    }

    return aliveplayers;
}

getallalliedandenemyplayers( obj )
{
    if ( level.teambased )
    {
        assert( isdefined( level.teams[self.team] ) );
        obj.allies = [];
        obj.enemies = [];

        for ( i = 0; i < level.players.size; i++ )
        {
            if ( !isdefined( level.players[i] ) )
                continue;

            player = level.players[i];

            if ( player.sessionstate != "playing" || player == self )
                continue;

            if ( isdefined( level.customalivecheck ) )
            {
                if ( ![[ level.customalivecheck ]]( player ) )
                    continue;
            }

            if ( player.team == self.team )
            {
                obj.allies[obj.allies.size] = player;
                continue;
            }

            obj.enemies[obj.enemies.size] = player;
        }
    }
    else
    {
        obj.allies = [];
        obj.enemies = level.activeplayers;
    }
}

initweights( spawnpoints )
{
    for ( i = 0; i < spawnpoints.size; i++ )
        spawnpoints[i].weight = 0;
/#
    if ( level.storespawndata || level.debugspawning )
    {
        for ( i = 0; i < spawnpoints.size; i++ )
        {
            spawnpoints[i].spawndata = [];
            spawnpoints[i].sightchecks = [];
        }
    }
#/
}

spawnpointupdate_zm( spawnpoint )
{
    foreach ( team in level.teams )
    {
        spawnpoint.distsum[team] = 0;
        spawnpoint.enemydistsum[team] = 0;
    }

    players = get_players();
    spawnpoint.numplayersatlastupdate = players.size;

    foreach ( player in players )
    {
        if ( !isdefined( player ) )
            continue;

        if ( player.sessionstate != "playing" )
            continue;

        if ( isdefined( level.customalivecheck ) )
        {
            if ( ![[ level.customalivecheck ]]( player ) )
                continue;
        }

        dist = distance( spawnpoint.origin, player.origin );
        spawnpoint.distsum[player.team] += dist;

        foreach ( team in level.teams )
        {
            if ( team != player.team )
                spawnpoint.enemydistsum[team] += dist;
        }
    }
}

getspawnpoint_nearteam( spawnpoints, favoredspawnpoints, forceallydistanceweight, forceenemydistanceweight )
{
    if ( !isdefined( spawnpoints ) )
        return undefined;
/#
    if ( getdvar( "scr_spawn_randomly" ) == "" )
        setdvar( "scr_spawn_randomly", "0" );

    if ( getdvar( "scr_spawn_randomly" ) == "1" )
        return getspawnpoint_random( spawnpoints );
#/
    if ( getdvarint( "scr_spawnsimple" ) > 0 )
        return getspawnpoint_random( spawnpoints );

    spawnlogic_begin();
    k_favored_spawn_point_bonus = 25000;
    initweights( spawnpoints );
    obj = spawnstruct();
    getallalliedandenemyplayers( obj );
    numplayers = obj.allies.size + obj.enemies.size;
    allieddistanceweight = 2;

    if ( isdefined( forceallydistanceweight ) )
        allieddistanceweight = forceallydistanceweight;

    enemydistanceweight = 1;

    if ( isdefined( forceenemydistanceweight ) )
        enemydistanceweight = forceenemydistanceweight;

    myteam = self.team;

    for ( i = 0; i < spawnpoints.size; i++ )
    {
        spawnpoint = spawnpoints[i];
        spawnpointupdate_zm( spawnpoint );

        if ( !isdefined( spawnpoint.numplayersatlastupdate ) )
            spawnpoint.numplayersatlastupdate = 0;

        if ( spawnpoint.numplayersatlastupdate > 0 )
        {
            allydistsum = spawnpoint.distsum[myteam];
            enemydistsum = spawnpoint.enemydistsum[myteam];
            spawnpoint.weight = ( enemydistanceweight * enemydistsum - allieddistanceweight * allydistsum ) / spawnpoint.numplayersatlastupdate;
/#
            if ( level.storespawndata || level.debugspawning )
                spawnpoint.spawndata[spawnpoint.spawndata.size] = "Base weight: " + int( spawnpoint.weight ) + " = (" + enemydistanceweight + "*" + int( enemydistsum ) + " - " + allieddistanceweight + "*" + int( allydistsum ) + ") / " + spawnpoint.numplayersatlastupdate;
#/
            continue;
        }

        spawnpoint.weight = 0;
/#
        if ( level.storespawndata || level.debugspawning )
            spawnpoint.spawndata[spawnpoint.spawndata.size] = "Base weight: 0";
#/
    }

    if ( isdefined( favoredspawnpoints ) )
    {
        for ( i = 0; i < favoredspawnpoints.size; i++ )
        {
            if ( isdefined( favoredspawnpoints[i].weight ) )
            {
                favoredspawnpoints[i].weight += k_favored_spawn_point_bonus;
                continue;
            }

            favoredspawnpoints[i].weight = k_favored_spawn_point_bonus;
        }
    }

    avoidsamespawn( spawnpoints );
    avoidspawnreuse( spawnpoints, 1 );
    avoidweapondamage( spawnpoints );
    avoidvisibleenemies( spawnpoints, 1 );
    result = getspawnpoint_final( spawnpoints );
/#
    if ( getdvar( "scr_spawn_showbad" ) == "" )
        setdvar( "scr_spawn_showbad", "0" );

    if ( getdvar( "scr_spawn_showbad" ) == "1" )
        checkbad( result );
#/
    return result;
}

getspawnpoint_dm( spawnpoints )
{
    if ( !isdefined( spawnpoints ) )
        return undefined;

    spawnlogic_begin();
    initweights( spawnpoints );
    aliveplayers = getallotherplayers();
    idealdist = 1600;
    baddist = 1200;

    if ( aliveplayers.size > 0 )
    {
        for ( i = 0; i < spawnpoints.size; i++ )
        {
            totaldistfromideal = 0;
            nearbybadamount = 0;

            for ( j = 0; j < aliveplayers.size; j++ )
            {
                dist = distance( spawnpoints[i].origin, aliveplayers[j].origin );

                if ( dist < baddist )
                    nearbybadamount += ( baddist - dist ) / baddist;

                distfromideal = abs( dist - idealdist );
                totaldistfromideal += distfromideal;
            }

            avgdistfromideal = totaldistfromideal / aliveplayers.size;
            welldistancedamount = ( idealdist - avgdistfromideal ) / idealdist;
            spawnpoints[i].weight = welldistancedamount - nearbybadamount * 2 + randomfloat( 0.2 );
        }
    }

    avoidsamespawn( spawnpoints );
    avoidspawnreuse( spawnpoints, 0 );
    avoidweapondamage( spawnpoints );
    avoidvisibleenemies( spawnpoints, 0 );
    return getspawnpoint_final( spawnpoints );
}

getspawnpoint_turned( spawnpoints, idealdist, baddist, idealdistteam, baddistteam )
{
    if ( !isdefined( spawnpoints ) )
        return undefined;

    spawnlogic_begin();
    initweights( spawnpoints );
    aliveplayers = getallotherplayers();

    if ( !isdefined( idealdist ) )
        idealdist = 1600;

    if ( !isdefined( idealdistteam ) )
        idealdistteam = 1200;

    if ( !isdefined( baddist ) )
        baddist = 1200;

    if ( !isdefined( baddistteam ) )
        baddistteam = 600;

    myteam = self.team;

    if ( aliveplayers.size > 0 )
    {
        for ( i = 0; i < spawnpoints.size; i++ )
        {
            totaldistfromideal = 0;
            nearbybadamount = 0;

            for ( j = 0; j < aliveplayers.size; j++ )
            {
                dist = distance( spawnpoints[i].origin, aliveplayers[j].origin );
                distfromideal = 0;

                if ( aliveplayers[j].team == myteam )
                {
                    if ( dist < baddistteam )
                        nearbybadamount += ( baddistteam - dist ) / baddistteam;

                    distfromideal = abs( dist - idealdistteam );
                }
                else
                {
                    if ( dist < baddist )
                        nearbybadamount += ( baddist - dist ) / baddist;

                    distfromideal = abs( dist - idealdist );
                }

                totaldistfromideal += distfromideal;
            }

            avgdistfromideal = totaldistfromideal / aliveplayers.size;
            welldistancedamount = ( idealdist - avgdistfromideal ) / idealdist;
            spawnpoints[i].weight = welldistancedamount - nearbybadamount * 2 + randomfloat( 0.2 );
        }
    }

    avoidsamespawn( spawnpoints );
    avoidspawnreuse( spawnpoints, 0 );
    avoidweapondamage( spawnpoints );
    avoidvisibleenemies( spawnpoints, 0 );
    return getspawnpoint_final( spawnpoints );
}

spawnlogic_begin()
{
/#
    level.storespawndata = getdvarint( "scr_recordspawndata" );
    level.debugspawning = getdvarint( "scr_spawnpointdebug" ) > 0;
#/
}

init()
{
/#
    if ( getdvar( "scr_recordspawndata" ) == "" )
        setdvar( "scr_recordspawndata", 0 );

    level.storespawndata = getdvarint( "scr_recordspawndata" );

    if ( getdvar( "scr_killbots" ) == "" )
        setdvar( "scr_killbots", 0 );

    if ( getdvar( "scr_killbottimer" ) == "" )
        setdvar( "scr_killbottimer", 0.25 );

    thread loopbotspawns();
#/
    level.spawnlogic_deaths = [];
    level.spawnlogic_spawnkills = [];
    level.players = [];
    level.grenades = [];
    level.pipebombs = [];
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );
    level.spawnminsmaxsprimed = 0;

    if ( isdefined( level.safespawns ) )
    {
        for ( i = 0; i < level.safespawns.size; i++ )
            level.safespawns[i] spawnpointinit();
    }

    if ( getdvar( "scr_spawn_enemyavoiddist" ) == "" )
        setdvar( "scr_spawn_enemyavoiddist", "800" );

    if ( getdvar( "scr_spawn_enemyavoidweight" ) == "" )
        setdvar( "scr_spawn_enemyavoidweight", "0" );
/#
    if ( getdvar( "scr_spawnsimple" ) == "" )
        setdvar( "scr_spawnsimple", "0" );

    if ( getdvar( "scr_spawnpointdebug" ) == "" )
        setdvar( "scr_spawnpointdebug", "0" );

    if ( getdvarint( "scr_spawnpointdebug" ) > 0 )
    {
        thread showdeathsdebug();
        thread updatedeathinfodebug();
        thread profiledebug();
    }

    if ( level.storespawndata )
        thread allowspawndatareading();

    if ( getdvar( "scr_spawnprofile" ) == "" )
        setdvar( "scr_spawnprofile", "0" );

    thread watchspawnprofile();
    thread spawngraphcheck();
#/
}

watchspawnprofile()
{
/#
    while ( true )
    {
        while ( true )
        {
            if ( getdvarint( "scr_spawnprofile" ) > 0 )
                break;

            wait 0.05;
        }

        thread spawnprofile();

        while ( true )
        {
            if ( getdvarint( "scr_spawnprofile" ) <= 0 )
                break;

            wait 0.05;
        }

        level notify( "stop_spawn_profile" );
    }
#/
}

spawnprofile()
{
/#
    level endon( "stop_spawn_profile" );

    while ( true )
    {
        if ( level.players.size > 0 && level.spawnpoints.size > 0 )
        {
            playernum = randomint( level.players.size );
            player = level.players[playernum];
            attempt = 1;

            while ( !isdefined( player ) && attempt < level.players.size )
            {
                playernum = ( playernum + 1 ) % level.players.size;
                attempt++;
                player = level.players[playernum];
            }

            player getspawnpoint_nearteam( level.spawnpoints );
        }

        wait 0.05;
    }
#/
}

spawngraphcheck()
{
/#
    while ( true )
    {
        if ( getdvarint( _hash_C25B6B47 ) < 1 )
        {
            wait 3;
            continue;
        }

        thread spawngraph();
        return;
    }
#/
}

spawngraph()
{
/#
    w = 20;
    h = 20;
    weightscale = 0.1;
    fakespawnpoints = [];
    corners = getentarray( "minimap_corner", "targetname" );

    if ( corners.size != 2 )
    {
        println( "^1 can't spawn graph: no minimap corners" );
        return;
    }

    min = corners[0].origin;
    max = corners[0].origin;

    if ( corners[1].origin[0] > max[0] )
        max = ( corners[1].origin[0], max[1], max[2] );
    else
        min = ( corners[1].origin[0], min[1], min[2] );

    if ( corners[1].origin[1] > max[1] )
        max = ( max[0], corners[1].origin[1], max[2] );
    else
        min = ( min[0], corners[1].origin[1], min[2] );

    i = 0;

    for ( y = 0; y < h; y++ )
    {
        yamnt = y / ( h - 1 );

        for ( x = 0; x < w; x++ )
        {
            xamnt = x / ( w - 1 );
            fakespawnpoints[i] = spawnstruct();
            fakespawnpoints[i].origin = ( min[0] * xamnt + max[0] * ( 1 - xamnt ), min[1] * yamnt + max[1] * ( 1 - yamnt ), min[2] );
            fakespawnpoints[i].angles = ( 0, 0, 0 );
            fakespawnpoints[i].forward = anglestoforward( fakespawnpoints[i].angles );
            fakespawnpoints[i].sighttracepoint = fakespawnpoints[i].origin;
            i++;
        }
    }

    didweights = 0;

    while ( true )
    {
        spawni = 0;
        numiters = 5;

        for ( i = 0; i < numiters; i++ )
        {
            if ( !level.players.size || !isdefined( level.players[0].team ) || level.players[0].team == "spectator" || !isdefined( level.players[0].class ) )
                break;

            endspawni = spawni + fakespawnpoints.size / numiters;

            if ( i == numiters - 1 )
                endspawni = fakespawnpoints.size;

            while ( spawni < endspawni )
            {
                spawnpointupdate( fakespawnpoints[spawni] );
                spawni++;
            }

            if ( didweights )
                level.players[0] drawspawngraph( fakespawnpoints, w, h, weightscale );

            wait 0.05;
        }

        if ( !level.players.size || !isdefined( level.players[0].team ) || level.players[0].team == "spectator" || !isdefined( level.players[0].class ) )
        {
            wait 1;
            continue;
        }

        level.players[0] getspawnpoint_nearteam( fakespawnpoints );

        for ( i = 0; i < fakespawnpoints.size; i++ )
            setupspawngraphpoint( fakespawnpoints[i], weightscale );

        didweights = 1;
        level.players[0] drawspawngraph( fakespawnpoints, w, h, weightscale );
        wait 0.05;
    }
#/
}

drawspawngraph( fakespawnpoints, w, h, weightscale )
{
/#
    i = 0;

    for ( y = 0; y < h; y++ )
    {
        yamnt = y / ( h - 1 );

        for ( x = 0; x < w; x++ )
        {
            xamnt = x / ( w - 1 );

            if ( y > 0 )
                spawngraphline( fakespawnpoints[i], fakespawnpoints[i - w], weightscale );

            if ( x > 0 )
                spawngraphline( fakespawnpoints[i], fakespawnpoints[i - 1], weightscale );

            i++;
        }
    }
#/
}

setupspawngraphpoint( s1, weightscale )
{
/#
    s1.visible = 1;

    if ( s1.weight < -1000 / weightscale )
        s1.visible = 0;
#/
}

spawngraphline( s1, s2, weightscale )
{
/#
    if ( !s1.visible || !s2.visible )
        return;

    p1 = s1.origin + ( 0, 0, s1.weight * weightscale + 100 );
    p2 = s2.origin + ( 0, 0, s2.weight * weightscale + 100 );
    line( p1, p2, ( 1, 1, 1 ) );
#/
}

loopbotspawns()
{
/#
    while ( true )
    {
        if ( getdvarint( "scr_killbots" ) < 1 )
        {
            wait 3;
            continue;
        }

        if ( !isdefined( level.players ) )
        {
            wait 0.05;
            continue;
        }

        bots = [];

        for ( i = 0; i < level.players.size; i++ )
        {
            if ( !isdefined( level.players[i] ) )
                continue;

            if ( level.players[i].sessionstate == "playing" && issubstr( level.players[i].name, "bot" ) )
                bots[bots.size] = level.players[i];
        }

        if ( bots.size > 0 )
        {
            if ( getdvarint( "scr_killbots" ) == 1 )
            {
                killer = bots[randomint( bots.size )];
                victim = bots[randomint( bots.size )];
                victim thread [[ level.callbackplayerdamage ]]( killer, killer, 1000, 0, "MOD_RIFLE_BULLET", "none", ( 0, 0, 0 ), ( 0, 0, 0 ), "none", 0, 0 );
            }
            else
            {
                numkills = getdvarint( "scr_killbots" );
                lastvictim = undefined;

                for ( index = 0; index < numkills; index++ )
                {
                    killer = bots[randomint( bots.size )];

                    for ( victim = bots[randomint( bots.size )]; isdefined( lastvictim ) && victim == lastvictim; victim = bots[randomint( bots.size )] )
                    {

                    }

                    victim thread [[ level.callbackplayerdamage ]]( killer, killer, 1000, 0, "MOD_RIFLE_BULLET", "none", ( 0, 0, 0 ), ( 0, 0, 0 ), "none", 0, 0 );
                    lastvictim = victim;
                }
            }
        }

        if ( getdvar( "scr_killbottimer" ) != "" )
            wait( getdvarfloat( "scr_killbottimer" ) );
        else
            wait 0.05;
    }
#/
}

allowspawndatareading()
{
/#
    setdvar( "scr_showspawnid", "" );
    prevval = getdvar( "scr_showspawnid" );
    prevrelval = getdvar( "scr_spawnidcycle" );
    readthistime = 0;

    while ( true )
    {
        val = getdvar( "scr_showspawnid" );
        relval = undefined;

        if ( !isdefined( val ) || val == prevval )
        {
            relval = getdvar( "scr_spawnidcycle" );

            if ( isdefined( relval ) && relval != "" )
                setdvar( "scr_spawnidcycle", "" );
            else
            {
                wait 0.5;
                continue;
            }
        }

        prevval = val;
        readthistime = 0;
        readspawndata( val, relval );

        if ( !isdefined( level.curspawndata ) )
            println( "No spawn data to draw." );
        else
            println( "Drawing spawn ID " + level.curspawndata.id );

        thread drawspawndata();
    }
#/
}

showdeathsdebug()
{
/#
    while ( true )
    {
        if ( getdvar( "scr_spawnpointdebug" ) == "0" )
        {
            wait 3;
            continue;
        }

        time = gettime();

        for ( i = 0; i < level.spawnlogic_deaths.size; i++ )
        {
            if ( isdefined( level.spawnlogic_deaths[i].los ) )
                line( level.spawnlogic_deaths[i].org, level.spawnlogic_deaths[i].killorg, ( 1, 0, 0 ) );
            else
                line( level.spawnlogic_deaths[i].org, level.spawnlogic_deaths[i].killorg, ( 1, 1, 1 ) );

            killer = level.spawnlogic_deaths[i].killer;

            if ( isdefined( killer ) && isalive( killer ) )
                line( level.spawnlogic_deaths[i].killorg, killer.origin, ( 0.4, 0.4, 0.8 ) );
        }

        for ( p = 0; p < level.players.size; p++ )
        {
            if ( !isdefined( level.players[p] ) )
                continue;

            if ( isdefined( level.players[p].spawnlogic_killdist ) )
                print3d( level.players[p].origin + vectorscale( ( 0, 0, 1 ), 64.0 ), level.players[p].spawnlogic_killdist, ( 1, 1, 1 ) );
        }

        oldspawnkills = level.spawnlogic_spawnkills;
        level.spawnlogic_spawnkills = [];

        for ( i = 0; i < oldspawnkills.size; i++ )
        {
            spawnkill = oldspawnkills[i];

            if ( spawnkill.dierwasspawner )
            {
                line( spawnkill.spawnpointorigin, spawnkill.dierorigin, ( 0.4, 0.5, 0.4 ) );
                line( spawnkill.dierorigin, spawnkill.killerorigin, ( 0, 1, 1 ) );
                print3d( spawnkill.dierorigin + vectorscale( ( 0, 0, 1 ), 32.0 ), "SPAWNKILLED!", ( 0, 1, 1 ) );
            }
            else
            {
                line( spawnkill.spawnpointorigin, spawnkill.killerorigin, ( 0.4, 0.5, 0.4 ) );
                line( spawnkill.killerorigin, spawnkill.dierorigin, ( 0, 1, 1 ) );
                print3d( spawnkill.dierorigin + vectorscale( ( 0, 0, 1 ), 32.0 ), "SPAWNDIED!", ( 0, 1, 1 ) );
            }

            if ( time - spawnkill.time < 60000 )
                level.spawnlogic_spawnkills[level.spawnlogic_spawnkills.size] = oldspawnkills[i];
        }

        wait 0.05;
    }
#/
}

updatedeathinfodebug()
{
    while ( true )
    {
        if ( getdvar( "scr_spawnpointdebug" ) == "0" )
        {
            wait 3;
            continue;
        }

        updatedeathinfo();
        wait 3;
    }
}

spawnweightdebug( spawnpoints )
{
    level notify( "stop_spawn_weight_debug" );
    level endon( "stop_spawn_weight_debug" );
/#
    while ( true )
    {
        if ( getdvar( "scr_spawnpointdebug" ) == "0" )
        {
            wait 3;
            continue;
        }

        textoffset = vectorscale( ( 0, 0, -1 ), 12.0 );

        for ( i = 0; i < spawnpoints.size; i++ )
        {
            amnt = 1 * ( 1 - spawnpoints[i].weight / -100000 );

            if ( amnt < 0 )
                amnt = 0;

            if ( amnt > 1 )
                amnt = 1;

            orig = spawnpoints[i].origin + vectorscale( ( 0, 0, 1 ), 80.0 );
            print3d( orig, int( spawnpoints[i].weight ), ( 1, amnt, 0.5 ) );
            orig += textoffset;

            if ( isdefined( spawnpoints[i].spawndata ) )
            {
                for ( j = 0; j < spawnpoints[i].spawndata.size; j++ )
                {
                    print3d( orig, spawnpoints[i].spawndata[j], vectorscale( ( 1, 1, 1 ), 0.5 ) );
                    orig += textoffset;
                }
            }

            if ( isdefined( spawnpoints[i].sightchecks ) )
            {
                for ( j = 0; j < spawnpoints[i].sightchecks.size; j++ )
                {
                    if ( spawnpoints[i].sightchecks[j].penalty == 0 )
                        continue;

                    print3d( orig, "Sight to enemy: -" + spawnpoints[i].sightchecks[j].penalty, vectorscale( ( 1, 1, 1 ), 0.5 ) );
                    orig += textoffset;
                }
            }
        }

        wait 0.05;
    }
#/
}

profiledebug()
{
    while ( true )
    {
        if ( getdvar( _hash_6A99E750 ) != "1" )
        {
            wait 3;
            continue;
        }

        for ( i = 0; i < level.spawnpoints.size; i++ )
            level.spawnpoints[i].weight = randomint( 10000 );

        if ( level.players.size > 0 )
            level.players[randomint( level.players.size )] getspawnpoint_nearteam( level.spawnpoints );

        wait 0.05;
    }
}

debugnearbyplayers( players, origin )
{
/#
    if ( getdvar( "scr_spawnpointdebug" ) == "0" )
        return;

    starttime = gettime();

    while ( true )
    {
        for ( i = 0; i < players.size; i++ )
            line( players[i].origin, origin, ( 0.5, 1, 0.5 ) );

        if ( gettime() - starttime > 5000 )
            return;

        wait 0.05;
    }
#/
}

deathoccured( dier, killer )
{

}

checkforsimilardeaths( deathinfo )
{
    for ( i = 0; i < level.spawnlogic_deaths.size; i++ )
    {
        if ( level.spawnlogic_deaths[i].killer == deathinfo.killer )
        {
            dist = distance( level.spawnlogic_deaths[i].org, deathinfo.org );

            if ( dist > 200 )
                continue;

            dist = distance( level.spawnlogic_deaths[i].killorg, deathinfo.killorg );

            if ( dist > 200 )
                continue;

            level.spawnlogic_deaths[i].remove = 1;
        }
    }
}

updatedeathinfo()
{
    time = gettime();

    for ( i = 0; i < level.spawnlogic_deaths.size; i++ )
    {
        deathinfo = level.spawnlogic_deaths[i];

        if ( time - deathinfo.time > 90000 || !isdefined( deathinfo.killer ) || !isalive( deathinfo.killer ) || !isdefined( level.teams[deathinfo.killer.team] ) || distance( deathinfo.killer.origin, deathinfo.killorg ) > 400 )
            level.spawnlogic_deaths[i].remove = 1;
    }

    oldarray = level.spawnlogic_deaths;
    level.spawnlogic_deaths = [];
    start = 0;

    if ( oldarray.size - 1024 > 0 )
        start = oldarray.size - 1024;

    for ( i = start; i < oldarray.size; i++ )
    {
        if ( !isdefined( oldarray[i].remove ) )
            level.spawnlogic_deaths[level.spawnlogic_deaths.size] = oldarray[i];
    }
}

ispointvulnerable( playerorigin )
{
    pos = self.origin + level.bettymodelcenteroffset;
    playerpos = playerorigin + vectorscale( ( 0, 0, 1 ), 32.0 );
    distsqrd = distancesquared( pos, playerpos );
    forward = anglestoforward( self.angles );

    if ( distsqrd < level.bettydetectionradius * level.bettydetectionradius )
    {
        playerdir = vectornormalize( playerpos - pos );
        angle = acos( vectordot( playerdir, forward ) );

        if ( angle < level.bettydetectionconeangle )
            return true;
    }

    return false;
}

avoidweapondamage( spawnpoints )
{
    if ( getdvar( _hash_FB71FB7 ) == "0" )
        return;

    weapondamagepenalty = 100000;

    if ( getdvar( _hash_76B8F046 ) != "" && getdvar( _hash_76B8F046 ) != "0" )
        weapondamagepenalty = getdvarfloat( _hash_76B8F046 );

    mingrenadedistsquared = 62500;

    for ( i = 0; i < spawnpoints.size; i++ )
    {
        for ( j = 0; j < level.grenades.size; j++ )
        {
            if ( !isdefined( level.grenades[j] ) )
                continue;

            if ( distancesquared( spawnpoints[i].origin, level.grenades[j].origin ) < mingrenadedistsquared )
            {
                spawnpoints[i].weight -= weapondamagepenalty;
/#
                if ( level.storespawndata || level.debugspawning )
                    spawnpoints[i].spawndata[spawnpoints[i].spawndata.size] = "Was near grenade: -" + int( weapondamagepenalty );
#/
            }
        }
    }
}

spawnperframeupdate()
{
    spawnpointindex = 0;

    while ( true )
    {
        wait 0.05;

        if ( !isdefined( level.spawnpoints ) )
            return;

        spawnpointindex = ( spawnpointindex + 1 ) % level.spawnpoints.size;
        spawnpoint = level.spawnpoints[spawnpointindex];
        spawnpointupdate( spawnpoint );
    }
}

getnonteamsum( skip_team, sums )
{
    value = 0;

    foreach ( team in level.teams )
    {
        if ( team == skip_team )
            continue;

        value += sums[team];
    }

    return value;
}

getnonteammindist( skip_team, mindists )
{
    dist = 9999999;

    foreach ( team in level.teams )
    {
        if ( team == skip_team )
            continue;

        if ( dist > mindists[team] )
            dist = mindists[team];
    }

    return dist;
}

spawnpointupdate( spawnpoint )
{
    if ( level.teambased )
    {
        sights = [];

        foreach ( team in level.teams )
        {
            spawnpoint.enemysights[team] = 0;
            sights[team] = 0;
            spawnpoint.nearbyplayers[team] = [];
        }
    }
    else
    {
        spawnpoint.enemysights = 0;
        spawnpoint.nearbyplayers["all"] = [];
    }

    spawnpointdir = spawnpoint.forward;
    debug = 0;
/#
    debug = getdvarint( "scr_spawnpointdebug" ) > 0;
#/
    mindist = [];
    distsum = [];

    if ( !level.teambased )
        mindist["all"] = 9999999;

    foreach ( team in level.teams )
    {
        spawnpoint.distsum[team] = 0;
        spawnpoint.enemydistsum[team] = 0;
        spawnpoint.minenemydist[team] = 9999999;
        mindist[team] = 9999999;
    }

    spawnpoint.numplayersatlastupdate = 0;

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( player.sessionstate != "playing" )
            continue;

        diff = player.origin - spawnpoint.origin;
        diff = ( diff[0], diff[1], 0 );
        dist = length( diff );
        team = "all";

        if ( level.teambased )
            team = player.team;

        if ( dist < 1024 )
            spawnpoint.nearbyplayers[team][spawnpoint.nearbyplayers[team].size] = player;

        if ( dist < mindist[team] )
            mindist[team] = dist;

        distsum[team] += dist;
        spawnpoint.numplayersatlastupdate++;
        pdir = anglestoforward( player.angles );

        if ( vectordot( spawnpointdir, diff ) < 0 && vectordot( pdir, diff ) > 0 )
            continue;

        losexists = bullettracepassed( player.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), spawnpoint.sighttracepoint, 0, undefined );
        spawnpoint.lastsighttracetime = gettime();

        if ( losexists )
        {
            if ( level.teambased )
                sights[player.team]++;
            else
                spawnpoint.enemysights++;
/#
            if ( debug )
                line( player.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), spawnpoint.sighttracepoint, ( 0.5, 1, 0.5 ) );
#/
        }
    }

    if ( level.teambased )
    {
        foreach ( team in level.teams )
        {
            spawnpoint.enemysights[team] = getnonteamsum( team, sights );
            spawnpoint.minenemydist[team] = getnonteammindist( team, mindist );
            spawnpoint.distsum[team] = distsum[team];
            spawnpoint.enemydistsum[team] = getnonteamsum( team, distsum );
        }
    }
    else
    {
        spawnpoint.distsum["all"] = distsum["all"];
        spawnpoint.enemydistsum["all"] = distsum["all"];
        spawnpoint.minenemydist["all"] = mindist["all"];
    }
}

getlospenalty()
{
    if ( getdvar( _hash_CACDB8AA ) != "" && getdvar( _hash_CACDB8AA ) != "0" )
        return getdvarfloat( _hash_CACDB8AA );

    return 100000;
}

lastminutesighttraces( spawnpoint )
{
    if ( !isdefined( spawnpoint.nearbyplayers ) )
        return false;

    closest = undefined;
    closestdistsq = undefined;
    secondclosest = undefined;
    secondclosestdistsq = undefined;

    foreach ( team in spawnpoint.nearbyplayers )
    {
        if ( team == self.team )
            continue;

        for ( i = 0; i < spawnpoint.nearbyplayers[team].size; i++ )
        {
            player = spawnpoint.nearbyplayers[team][i];

            if ( !isdefined( player ) )
                continue;

            if ( player.sessionstate != "playing" )
                continue;

            if ( player == self )
                continue;

            distsq = distancesquared( spawnpoint.origin, player.origin );

            if ( !isdefined( closest ) || distsq < closestdistsq )
            {
                secondclosest = closest;
                secondclosestdistsq = closestdistsq;
                closest = player;
                closestdistsq = distsq;
                continue;
            }

            if ( !isdefined( secondclosest ) || distsq < secondclosestdistsq )
            {
                secondclosest = player;
                secondclosestdistsq = distsq;
            }
        }
    }

    if ( isdefined( closest ) )
    {
        if ( bullettracepassed( closest.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), spawnpoint.sighttracepoint, 0, undefined ) )
            return true;
    }

    if ( isdefined( secondclosest ) )
    {
        if ( bullettracepassed( secondclosest.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), spawnpoint.sighttracepoint, 0, undefined ) )
            return true;
    }

    return false;
}

avoidvisibleenemies( spawnpoints, teambased )
{
    if ( getdvar( _hash_FB71FB7 ) == "0" )
        return;

    lospenalty = getlospenalty();
    mindistteam = self.team;

    if ( teambased )
    {
        for ( i = 0; i < spawnpoints.size; i++ )
        {
            if ( !isdefined( spawnpoints[i].enemysights ) )
                continue;

            penalty = lospenalty * spawnpoints[i].enemysights[self.team];
            spawnpoints[i].weight -= penalty;
/#
            if ( level.storespawndata || level.debugspawning )
            {
                index = spawnpoints[i].sightchecks.size;
                spawnpoints[i].sightchecks[index] = spawnstruct();
                spawnpoints[i].sightchecks[index].penalty = penalty;
            }
#/
        }
    }
    else
    {
        for ( i = 0; i < spawnpoints.size; i++ )
        {
            if ( !isdefined( spawnpoints[i].enemysights ) )
                continue;

            penalty = lospenalty * spawnpoints[i].enemysights;
            spawnpoints[i].weight -= penalty;
/#
            if ( level.storespawndata || level.debugspawning )
            {
                index = spawnpoints[i].sightchecks.size;
                spawnpoints[i].sightchecks[index] = spawnstruct();
                spawnpoints[i].sightchecks[index].penalty = penalty;
            }
#/
        }

        mindistteam = "all";
    }

    avoidweight = getdvarfloat( "scr_spawn_enemyavoidweight" );

    if ( avoidweight != 0 )
    {
        nearbyenemyouterrange = getdvarfloat( "scr_spawn_enemyavoiddist" );
        nearbyenemyouterrangesq = nearbyenemyouterrange * nearbyenemyouterrange;
        nearbyenemypenalty = 1500 * avoidweight;
        nearbyenemyminorpenalty = 800 * avoidweight;
        lastattackerorigin = vectorscale( ( -1, -1, -1 ), 99999.0 );
        lastdeathpos = vectorscale( ( -1, -1, -1 ), 99999.0 );

        if ( isalive( self.lastattacker ) )
            lastattackerorigin = self.lastattacker.origin;

        if ( isdefined( self.lastdeathpos ) )
            lastdeathpos = self.lastdeathpos;

        for ( i = 0; i < spawnpoints.size; i++ )
        {
            mindist = spawnpoints[i].minenemydist[mindistteam];

            if ( mindist < nearbyenemyouterrange * 2 )
            {
                penalty = nearbyenemyminorpenalty * ( 1 - mindist / nearbyenemyouterrange * 2 );

                if ( mindist < nearbyenemyouterrange )
                    penalty += nearbyenemypenalty * ( 1 - mindist / nearbyenemyouterrange );

                if ( penalty > 0 )
                {
                    spawnpoints[i].weight -= penalty;
/#
                    if ( level.storespawndata || level.debugspawning )
                        spawnpoints[i].spawndata[spawnpoints[i].spawndata.size] = "Nearest enemy at " + int( spawnpoints[i].minenemydist[mindistteam] ) + " units: -" + int( penalty );
#/
                }
            }
        }
    }
}

avoidspawnreuse( spawnpoints, teambased )
{
    if ( getdvar( _hash_FB71FB7 ) == "0" )
        return;

    time = gettime();
    maxtime = 10000;
    maxdistsq = 1048576;

    for ( i = 0; i < spawnpoints.size; i++ )
    {
        spawnpoint = spawnpoints[i];

        if ( !isdefined( spawnpoint.lastspawnedplayer ) || !isdefined( spawnpoint.lastspawntime ) || !isalive( spawnpoint.lastspawnedplayer ) )
            continue;

        if ( spawnpoint.lastspawnedplayer == self )
            continue;

        if ( teambased && spawnpoint.lastspawnedplayer.team == self.team )
            continue;

        timepassed = time - spawnpoint.lastspawntime;

        if ( timepassed < maxtime )
        {
            distsq = distancesquared( spawnpoint.lastspawnedplayer.origin, spawnpoint.origin );

            if ( distsq < maxdistsq )
            {
                worsen = 5000 * ( 1 - distsq / maxdistsq ) * ( 1 - timepassed / maxtime );
                spawnpoint.weight -= worsen;
/#
                if ( level.storespawndata || level.debugspawning )
                    spawnpoint.spawndata[spawnpoint.spawndata.size] = "Was recently used: -" + worsen;
#/
            }
            else
                spawnpoint.lastspawnedplayer = undefined;

            continue;
        }

        spawnpoint.lastspawnedplayer = undefined;
    }
}

avoidsamespawn( spawnpoints )
{
    if ( getdvar( _hash_FB71FB7 ) == "0" )
        return;

    if ( !isdefined( self.lastspawnpoint ) )
        return;

    for ( i = 0; i < spawnpoints.size; i++ )
    {
        if ( spawnpoints[i] == self.lastspawnpoint )
        {
            spawnpoints[i].weight -= 50000;
/#
            if ( level.storespawndata || level.debugspawning )
                spawnpoints[i].spawndata[spawnpoints[i].spawndata.size] = "Was last spawnpoint: -50000";
#/
            break;
        }
    }
}

getrandomintermissionpoint()
{
    spawnpoints = getentarray( "mp_global_intermission", "classname" );

    if ( !spawnpoints.size )
        spawnpoints = getentarray( "info_player_start", "classname" );

    assert( spawnpoints.size );
    spawnpoint = maps\mp\gametypes_zm\_spawnlogic::getspawnpoint_random( spawnpoints );
    return spawnpoint;
}
