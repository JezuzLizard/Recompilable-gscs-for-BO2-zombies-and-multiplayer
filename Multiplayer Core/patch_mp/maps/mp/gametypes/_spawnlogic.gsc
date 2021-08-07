//checked includes match cerberus output
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/_callbacksetup;
#include maps/mp/_utility;
#include common_scripts/utility;

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
	}
}

findboxcenter( mins, maxs ) //checked changed to match cerberus output
{
	center = ( 0, 0, 0 );
	center = maxs - mins;
	center = ( center[ 0 ] / 2, center[ 1 ] / 2, center[ 2 ] / 2 ) + mins;
	return center;
}

expandmins( mins, point ) //checked matches cerberus output
{
	if ( mins[ 0 ] > point[ 0 ] )
	{
		mins = ( point[ 0 ], mins[ 1 ], mins[ 2 ] );
	}
	if ( mins[ 1 ] > point[ 1 ] )
	{
		mins = ( mins[ 0 ], point[ 1 ], mins[ 2 ] );
	}
	if ( mins[ 2 ] > point[ 2 ] )
	{
		mins = ( mins[ 0 ], mins[ 1 ], point[ 2 ] );
	}
	return mins;
}

expandmaxs( maxs, point ) //checked matches cerberus output
{
	if ( maxs[ 0 ] < point[ 0 ] )
	{
		maxs = ( point[ 0 ], maxs[ 1 ], maxs[ 2 ] );
	}
	if ( maxs[ 1 ] < point[ 1 ] )
	{
		maxs = ( maxs[ 0 ], point[ 1 ], maxs[ 2 ] );
	}
	if ( maxs[ 2 ] < point[ 2 ] )
	{
		maxs = ( maxs[ 0 ], maxs[ 1 ], point[ 2 ] );
	}
	return maxs;
}

addspawnpointsinternal( team, spawnpointname ) //checked changed to match cerberus output
{
	oldspawnpoints = [];
	if ( level.teamspawnpoints[ team ].size )
	{
		oldspawnpoints = level.teamspawnpoints[ team ];
	}
	level.teamspawnpoints[ team ] = getspawnpointarray( spawnpointname );
	if ( !isDefined( level.spawnpoints ) )
	{
		level.spawnpoints = [];
	}
	for ( index = 0; index < level.teamspawnpoints[team].size; index++ )
	{
		spawnpoint = level.teamspawnpoints[ team ][ index ];
		if ( !isDefined( spawnpoint.inited ) )
		{
			spawnpoint spawnpointinit();
			level.spawnpoints[ level.spawnpoints.size ] = spawnpoint;
		}
	}
	for ( index = 0; index < oldspawnpoints.size; index++ )
	{
		origin = oldspawnpoints[ index ].origin;
		level.spawnmins = expandmins( level.spawnmins, origin );
		level.spawnmaxs = expandmaxs( level.spawnmaxs, origin );
		level.teamspawnpoints[ team ][ level.teamspawnpoints[ team ].size ] = oldspawnpoints[ index ];
	}
	if ( !level.teamspawnpoints[ team ].size )
	{
		/*
/#
		println( "^1ERROR: No " + spawnpointname + " spawnpoints found in level!" );
#/
		*/
		maps/mp/gametypes/_callbacksetup::abortlevel();
		wait 1;
		return;
	}
}

clearspawnpoints() //checked changed to match cerberus output
{
	foreach ( team in level.teams )
	{
		level.teamspawnpoints[ team ] = [];
	}
	level.spawnpoints = [];
	level.unified_spawn_points = undefined;
}

addspawnpoints( team, spawnpointname ) //checked matches cerberus output
{
	addspawnpointclassname( spawnpointname );
	addspawnpointteamclassname( team, spawnpointname );
	addspawnpointsinternal( team, spawnpointname );
}

rebuildspawnpoints( team ) //checked changed to match cerberus output
{
	level.teamspawnpoints[ team ] = [];
	for ( index = 0; index < level.spawn_point_team_class_names[team].size; index++ )
	{
		addspawnpointsinternal( team, level.spawn_point_team_class_names[ team ][ index ] );
	}
}

placespawnpoints( spawnpointname ) //checked changed to match cerberus output
{
	addspawnpointclassname( spawnpointname );
	spawnpoints = getspawnpointarray( spawnpointname );
	/*
/#
	if ( !isDefined( level.extraspawnpointsused ) )
	{
		level.extraspawnpointsused = [];
#/
	}
	*/
	if ( !spawnpoints.size )
	{
		/*
/#
		println( "^1No " + spawnpointname + " spawnpoints found in level!" );
#/
		*/
		maps/mp/gametypes/_callbacksetup::abortlevel();
		wait 1;
		return;
	}
	for ( index = 0; index < spawnpoints.size; index++ )
	{
		spawnpoints[ index ] spawnpointinit();
		/*
/#
		spawnpoints[ index ].fakeclassname = spawnpointname;
		level.extraspawnpointsused[ level.extraspawnpointsused.size ] = spawnpoints[ index ];
#/
		*/
	}
}

dropspawnpoints( spawnpointname ) //checked changed to match cerberus output
{
	spawnpoints = getspawnpointarray( spawnpointname );
	if ( !spawnpoints.size )
	{
		/*
/#
		println( "^1No " + spawnpointname + " spawnpoints found in level!" );
#/
		*/
		return;
	}
	for ( index = 0; index < spawnpoints.size; index++ )
	{
		spawnpoints[ index ] placespawnpoint();
	}
}

addspawnpointclassname( spawnpointclassname ) //checked matches cerberus output
{
	if ( !isDefined( level.spawn_point_class_names ) )
	{
		level.spawn_point_class_names = [];
	}
	level.spawn_point_class_names[ level.spawn_point_class_names.size ] = spawnpointclassname;
}

addspawnpointteamclassname( team, spawnpointclassname ) //checked matches cerberus output
{
	level.spawn_point_team_class_names[ team ][ level.spawn_point_team_class_names[ team ].size ] = spawnpointclassname;
}

getspawnpointarray( classname ) //checked changed to match cerberus output
{
	spawnpoints = getentarray( classname, "classname" );
	if ( !isDefined( level.extraspawnpoints ) || !isDefined( level.extraspawnpoints[ classname ] ) )
	{
		return spawnpoints;
	}
	for ( i = 0; i < level.extraspawnpoints[classname].size; i++ )
	{
		spawnpoints[ spawnpoints.size ] = level.extraspawnpoints[ classname ][ i ];
	}
	return spawnpoints;
}

spawnpointinit() //checked changed to match cerberus output
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
	spawnpoint.forward = anglesToForward( spawnpoint.angles );
	spawnpoint.sighttracepoint = spawnpoint.origin + vectorScale( ( 0, 0, 1 ), 50 );
	spawnpoint.inited = 1;
}

getteamspawnpoints( team ) //checked matches cerberus output
{
	return level.teamspawnpoints[ team ];
}

getspawnpoint_final( spawnpoints, useweights ) //checked partially changed to match cerberus output see info.md
{
	bestspawnpoint = undefined;
	if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
	{
		return undefined;
	}
	if ( !isDefined( useweights ) )
	{
		useweights = 1;
	}
	if ( useweights )
	{
		bestspawnpoint = getbestweightedspawnpoint( spawnpoints );
		thread spawnweightdebug( spawnpoints );
	}
	else 
	{
		i = 0;
		while ( i < spawnpoints.size )
		{
			if ( isDefined( self.lastspawnpoint ) && self.lastspawnpoint == spawnpoints[ i ] )
			{
				i++;
				continue;
			}
			if ( positionwouldtelefrag( spawnpoints[ i ].origin ) )
			{
				i++;
				continue;
			}
			bestspawnpoint = spawnpoints[ i ];
			break;
		}
		if ( !isDefined( bestspawnpoint ) )
		{
			if ( isDefined( self.lastspawnpoint ) && !positionwouldtelefrag( self.lastspawnpoint.origin ) )
			{
				for ( i = 0; i < spawnpoints.size; i++ )
				{
					if ( spawnpoints[ i ] == self.lastspawnpoint )
					{
						bestspawnpoint = spawnpoints[ i ];
						break;
					}
				}
			}
		}
	}
	if ( !isDefined( bestspawnpoint ) )
	{
		if ( useweights )
		{
			bestspawnpoint = spawnpoints[ randomint( spawnpoints.size ) ];
		}
		else
		{
			bestspawnpoint = spawnpoints[ 0 ];
		}
	}
	self finalizespawnpointchoice( bestspawnpoint );
	/*
/#
	self storespawndata( spawnpoints, useweights, bestspawnpoint );
#/
	*/
	return bestspawnpoint;
}

finalizespawnpointchoice( spawnpoint ) //checked matches cerberus output
{
	time = getTime();
	self.lastspawnpoint = spawnpoint;
	self.lastspawntime = time;
	spawnpoint.lastspawnedplayer = self;
	spawnpoint.lastspawntime = time;
}

getbestweightedspawnpoint( spawnpoints ) //checked partially changed to match cerberus output see info.md
{
	maxsighttracedspawnpoints = 3;
	for ( try = 0; try <= maxsighttracedspawnpoints; try++ )
	{
		bestspawnpoints = [];
		bestweight = undefined;
		bestspawnpoint = undefined;
		i = 0;
		while ( i < spawnpoints.size )
		{
			if ( !isDefined( bestweight ) || spawnpoints[ i ].weight > bestweight )
			{
				if ( positionwouldtelefrag( spawnpoints[ i ].origin ) )
				{
					i++;
					continue;
				}
				bestspawnpoints = [];
				bestspawnpoints[ 0 ] = spawnpoints[ i ];
				bestweight = spawnpoints[ i ].weight;
				i++;
				continue;
			}
			if ( spawnpoints[ i ].weight == bestweight )
			{
				if ( positionwouldtelefrag( spawnpoints[ i ].origin ) )
				{
					i++;
					continue;
				}
				bestspawnpoints[ bestspawnpoints.size ] = spawnpoints[ i ];
			}
			i++;
		}
		if ( bestspawnpoints.size == 0 )
		{
			return undefined;
		}
		bestspawnpoint = bestspawnpoints[ randomint( bestspawnpoints.size ) ];
		if ( try == maxsighttracedspawnpoints )
		{
			return bestspawnpoint;
		}
		if ( isDefined( bestspawnpoint.lastsighttracetime ) && bestspawnpoint.lastsighttracetime == getTime() )
		{
			return bestspawnpoint;
		}
		if ( !lastminutesighttraces( bestspawnpoint ) )
		{
			return bestspawnpoint;
		}
		penalty = getlospenalty();
		/*
/#
		if ( level.storespawndata || level.debugspawning )
		{
			bestspawnpoint.spawndata[ bestspawnpoint.spawndata.size ] = "Last minute sight trace: -" + penalty;
#/
		}
		*/
		bestspawnpoint.weight -= penalty;
		bestspawnpoint.lastsighttracetime = getTime();
	}
}

checkbad( spawnpoint ) //checked partially changed to match cerberus output see info.md
{
	/*
/#
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( !isalive( player ) || player.sessionstate != "playing" )
		{
			i++;
			continue;
		}
		if ( level.teambased && player.team == self.team )
		{
			i++;
			continue;
		}
		losexists = bullettracepassed( player.origin + vectorScale( ( 0, 0, 1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined );
		if ( losexists )
		{
			thread badspawnline( spawnpoint.sighttracepoint, player.origin + vectorScale( ( 0, 0, 1 ), 50 ), self.name, player.name );
		}
		i++;
#/
	}
	*/
}

badspawnline( start, end, name1, name2 ) //checked changed to match cerberus output
{
	/*
/#
	dist = distance( start, end );
	for ( i = 0; i < 200; i++ )
	{
		line( start, end, ( 1, 0, 0 ) );
		print3d( start, "Bad spawn! " + name1 + ", dist = " + dist );
		print3d( end, name2 );
		wait 0.05;
#/
	}
	*/
}

storespawndata( spawnpoints, useweights, bestspawnpoint ) //checked partially changed to match cerberus output see info.md
{
	/*
/#
	if ( !isDefined( level.storespawndata ) || !level.storespawndata )
	{
		return;
	}
	level.storespawndata = getDvarInt( "scr_recordspawndata" );
	if ( !level.storespawndata )
	{
		return;
	}
	if ( !isDefined( level.spawnid ) )
	{
		level.spawngameid = randomint( 100 );
		level.spawnid = 0;
	}
	if ( bestspawnpoint.classname == "mp_global_intermission" )
	{
		return;
	}
	level.spawnid++;
	file = openfile( "spawndata.txt", "append" );
	fprintfields( file, ( level.spawngameid + "." ) + level.spawnid + "," + spawnpoints.size + "," + self.name );
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		str = vectostr( spawnpoints[ i ].origin ) + ",";
		if ( spawnpoints[ i ] == bestspawnpoint )
		{
			str += "1,";
		}
		else
		{
			str += "0,";
		}
		if ( !useweights )
		{
			str += "0,";
		}
		else
		{
			str += spawnpoints[ i ].weight + ",";
		}
		if ( !isDefined( spawnpoints[ i ].spawndata ) )
		{
			spawnpoints[ i ].spawndata = [];
		}
		if ( !isDefined( spawnpoints[ i ].sightchecks ) )
		{
			spawnpoints[ i ].sightchecks = [];
		}
		str += spawnpoints[ i ].spawndata.size + ",";
		for ( j = 0; j < spawnpoints[i].spawndata.size; j++ )
		{
			str += spawnpoints[ i ].spawndata[ j ] + ",";
		}
		str += spawnpoints[ i ].sightchecks.size + ",";
		for ( j = 0; j < spawnpoints[i].sightchecks.size; j++ )
		{
			str += ( spawnpoints[ i ].sightchecks[ j ].penalty + "," ) + vectostr( spawnpoints[ i ].origin ) + ",";
		}
		fprintfields( file, str );
	}
	obj = spawnstruct();
	getallalliedandenemyplayers( obj );
	numallies = 0;
	numenemies = 0;
	str = "";
	i = 0;
	while ( i < obj.allies.size )
	{
		if ( obj.allies[ i ] == self )
		{
			i++;
			continue;
		}
		numallies++;
		str += vectostr( obj.allies[ i ].origin ) + ",";
		i++;
	}
	for ( i = 0; i < obj.enemies.size; i++ )
	{
		numenemies++;
		str += vectostr( obj.enemies[ i ].origin ) + ",";
	}
	str = ( numallies + "," ) + numenemies + "," + str;
	fprintfields( file, str );
	otherdata = [];
	if ( isDefined( level.bombguy ) )
	{
		index = otherdata.size;
		otherdata[ index ] = spawnstruct();
		otherdata[ index ].origin = level.bombguy.origin + vectorScale( ( 0, 0, 1 ), 20 );
		otherdata[ index ].text = "Bomb holder";
	}
	else if ( isDefined( level.bombpos ) )
	{
		index = otherdata.size;
		otherdata[ index ] = spawnstruct();
		otherdata[ index ].origin = level.bombpos;
		otherdata[ index ].text = "Bomb";
	}
	if ( isDefined( level.flags ) )
	{
		for ( i = 0; i < level.flags.size; i++ )
		{
			index = otherdata.size;
			otherdata[ index ] = spawnstruct();
			otherdata[ index ].origin = level.flags[ i ].origin;
			otherdata[ index ].text = level.flags[ i ].useobj maps/mp/gametypes/_gameobjects::getownerteam() + " flag";
		}
	}
	str = otherdata.size + ",";
	for ( i = 0; i < otherdata.size; i++ )
	{
		str += vectostr( otherdata[ i ].origin ) + "," + otherdata[ i ].text + ",";
	}
	fprintfields( file, str );
	closefile( file );
	thisspawnid = ( level.spawngameid + "." ) + level.spawnid;
	self.thisspawnid = thisspawnid;
#/
	*/
}

readspawndata( desiredid, relativepos ) //dev call did not check
{
	/*
/#
	file = openfile( "spawndata.txt", "read" );
	if ( file < 0 )
	{
		return;
	}
	oldspawndata = level.curspawndata;
	level.curspawndata = undefined;
	prev = undefined;
	prevthisplayer = undefined;
	lookingfornextthisplayer = 0;
	lookingfornext = 0;
	if ( isDefined( relativepos ) && !isDefined( oldspawndata ) )
	{
		return;
	}
	while ( 1 )
	{
		if ( freadln( file ) <= 0 )
		{
			break;
		}
		else data = spawnstruct();
		data.id = fgetarg( file, 0 );
		numspawns = int( fgetarg( file, 1 ) );
		if ( numspawns > 256 )
		{
			break;
		}
		else data.playername = fgetarg( file, 2 );
		data.spawnpoints = [];
		data.friends = [];
		data.enemies = [];
		data.otherdata = [];
		i = 0;
		while ( i < numspawns )
		{
			if ( freadln( file ) <= 0 )
			{
				break;
			}
			else spawnpoint = spawnstruct();
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
				{
					data.minweight = spawnpoint.weight;
				}
				if ( spawnpoint.weight > data.maxweight )
				{
					data.maxweight = spawnpoint.weight;
				}
			}
			argnum = 4;
			numdata = int( fgetarg( file, 3 ) );
			if ( numdata > 256 )
			{
				break;
			}
			else j = 0;
			while ( j < numdata )
			{
				spawnpoint.data[ spawnpoint.data.size ] = fgetarg( file, argnum );
				argnum++;
				j++;
			}
			numsightchecks = int( fgetarg( file, argnum ) );
			argnum++;
			if ( numsightchecks > 256 )
			{
				break;
			}
			else
			{
				j = 0;
				while ( j < numsightchecks )
				{
					index = spawnpoint.sightchecks.size;
					spawnpoint.sightchecks[ index ] = spawnstruct();
					spawnpoint.sightchecks[ index ].penalty = int( fgetarg( file, argnum ) );
					argnum++;
					spawnpoint.sightchecks[ index ].origin = strtovec( fgetarg( file, argnum ) );
					argnum++;
					j++;
				}
				data.spawnpoints[ data.spawnpoints.size ] = spawnpoint;
				i++;
			}
		}
		if ( !isDefined( data.minweight ) )
		{
			data.minweight = -1;
			data.maxweight = 0;
		}
		if ( data.minweight == data.maxweight )
		{
			data.minweight -= 1;
		}
		if ( freadln( file ) <= 0 )
		{
			break;
		}
		else numfriends = int( fgetarg( file, 0 ) );
		numenemies = int( fgetarg( file, 1 ) );
		if ( numfriends > 32 || numenemies > 32 )
		{
			break;
		}
		else
		{
			argnum = 2;
			i = 0;
			while ( i < numfriends )
			{
				data.friends[ data.friends.size ] = strtovec( fgetarg( file, argnum ) );
				argnum++;
				i++;
			}
			i = 0;
			while ( i < numenemies )
			{
				data.enemies[ data.enemies.size ] = strtovec( fgetarg( file, argnum ) );
				argnum++;
				i++;
			}
			if ( freadln( file ) <= 0 )
			{
				break;
			}
			else numotherdata = int( fgetarg( file, 0 ) );
			argnum = 1;
			i = 0;
			while ( i < numotherdata )
			{
				otherdata = spawnstruct();
				otherdata.origin = strtovec( fgetarg( file, argnum ) );
				argnum++;
				otherdata.text = fgetarg( file, argnum );
				argnum++;
				data.otherdata[ data.otherdata.size ] = otherdata;
				i++;
			}
			if ( isDefined( relativepos ) )
			{
				if ( relativepos == "prevthisplayer" )
				{
					if ( data.id == oldspawndata.id )
					{
						level.curspawndata = prevthisplayer;
						break;
					}
					else }
				else if ( relativepos == "prev" )
				{
					if ( data.id == oldspawndata.id )
					{
						level.curspawndata = prev;
						break;
					}
					else }
				else if ( relativepos == "nextthisplayer" )
				{
					if ( lookingfornextthisplayer )
					{
						level.curspawndata = data;
						break;
					}
					else if ( data.id == oldspawndata.id )
					{
						lookingfornextthisplayer = 1;
					}
				}
				else if ( relativepos == "next" )
				{
					if ( lookingfornext )
					{
						level.curspawndata = data;
						break;
					}
					else if ( data.id == oldspawndata.id )
					{
						lookingfornext = 1;
					}
				}
			}
			else
			{
				if ( data.id == desiredid )
				{
					level.curspawndata = data;
					break;
				}
			}
			else
			{
				prev = data;
				if ( isDefined( oldspawndata ) && data.playername == oldspawndata.playername )
				{
					prevthisplayer = data;
				}
			}
		}
	}
	closefile( file );
#/
	*/
}

drawspawndata() //dev call did not check
{
	/*
/#
	level notify( "drawing_spawn_data" );
	level endon( "drawing_spawn_data" );
	textoffset = vectorScale( ( -1, -1, -1 ), 12 );
	while ( 1 )
	{
		while ( !isDefined( level.curspawndata ) )
		{
			wait 0,5;
		}
		i = 0;
		while ( i < level.curspawndata.friends.size )
		{
			print3d( level.curspawndata.friends[ i ], "=)", ( 0,5, 1, 0,5 ), 1, 5 );
			i++;
		}
		i = 0;
		while ( i < level.curspawndata.enemies.size )
		{
			print3d( level.curspawndata.enemies[ i ], "=(", ( 1, 0,5, 0,5 ), 1, 5 );
			i++;
		}
		i = 0;
		while ( i < level.curspawndata.otherdata.size )
		{
			print3d( level.curspawndata.otherdata[ i ].origin, level.curspawndata.otherdata[ i ].text, ( 0,5, 0,75, 1 ), 1, 2 );
			i++;
		}
		i = 0;
		while ( i < level.curspawndata.spawnpoints.size )
		{
			sp = level.curspawndata.spawnpoints[ i ];
			orig = sp.sighttracepoint;
			if ( sp.winner )
			{
				print3d( orig, level.curspawndata.playername + " spawned here", ( 0,5, 0,5, 1 ), 1, 2 );
				orig += textoffset;
			}
			amnt = ( sp.weight - level.curspawndata.minweight ) / ( level.curspawndata.maxweight - level.curspawndata.minweight );
			print3d( orig, "Weight: " + sp.weight, ( 1 - amnt, amnt, 0,5 ) );
			orig += textoffset;
			j = 0;
			while ( j < sp.data.size )
			{
				print3d( orig, sp.data[ j ], ( -1, -1, -1 ) );
				orig += textoffset;
				j++;
			}
			j = 0;
			while ( j < sp.sightchecks.size )
			{
				print3d( orig, "Sightchecks: -" + sp.sightchecks[ j ].penalty, ( 1, 0,5, 0,5 ) );
				orig += textoffset;
				j++;
			}
			i++;
		}
		wait 0,05;
#/
	}
	*/
}

vectostr( vec ) //dev call did not check
{
	/*
/#
	return int( vec[ 0 ] ) + "/" + int( vec[ 1 ] ) + "/" + int( vec[ 2 ] );
#/
	*/
}

strtovec( str ) //dev call did not check
{
	/*
/#
	parts = strtok( str, "/" );
	if ( parts.size != 3 )
	{
		return ( -1, -1, -1 );
	}
	return ( int( parts[ 0 ] ), int( parts[ 1 ] ), int( parts[ 2 ] ) );
#/
	*/
}

getspawnpoint_random( spawnpoints ) //checked changed to match cerberus output
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		j = randomint( spawnpoints.size );
		spawnpoint = spawnpoints[ i ];
		spawnpoints[ i ] = spawnpoints[ j ];
		spawnpoints[ j ] = spawnpoint;
	}
	return getspawnpoint_final( spawnpoints, 0 );
}

getallotherplayers() //checked partially changed to match cerberus output see info.md
{
	aliveplayers = [];
	i = 0;
	while ( i < level.players.size )
	{
		if ( !isDefined( level.players[ i ] ) )
		{
			i++;
			continue;
		}
		player = level.players[ i ];
		if ( player.sessionstate != "playing" || player == self )
		{
			i++;
			continue;
		}
		aliveplayers[ aliveplayers.size ] = player;
		i++;
	}
	return aliveplayers;
}

getallalliedandenemyplayers( obj ) //checked partially changed to match cerberus output changed at own discretion see info.md
{
	if ( level.teambased )
	{
		/*
/#
		assert( isDefined( level.teams[ self.team ] ) );
#/
		*/
		obj.allies = level.aliveplayers[ self.team ];
		obj.enemies = undefined;
		foreach ( team in level.teams )
		{
			if ( team == self.team )
			{
			}
			else if ( !isDefined( obj.enemies ) )
			{
				obj.enemies = level.aliveplayers[ team ];
			}
			else
			{
				i = 0;
				while ( i < level.aliveplayers[ team ].size )
				{
					obj.enemies[ obj.enemies.size ] = level.aliveplayers[ team ][ i ];
					i++;
				}
			}
		}
	}
	else 
	{
		obj.allies = [];
		obj.enemies = level.activeplayers;
	}
}

initweights( spawnpoints ) //checked changed to match cerberus output
{
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		spawnpoints[ i ].weight = 0;
	}
	/*
/#
	if ( level.storespawndata || level.debugspawning )
	{
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			spawnpoints[ i ].spawndata = [];
			spawnpoints[ i ].sightchecks = [];
#/
		}
	}
	*/
}

getspawnpoint_nearteam( spawnpoints, favoredspawnpoints ) //checked partially changed to match beta dump see info.md
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
	/*
/#
	if ( getDvar( "scr_spawn_randomly" ) == "" )
	{
		setdvar( "scr_spawn_randomly", "0" );
	}
	if ( getDvar( "scr_spawn_randomly" ) == "1" )
	{
		return getspawnpoint_random( spawnpoints );
#/
	}
	*/
	if ( getDvarInt( "scr_spawnsimple" ) > 0 )
	{
		return getspawnpoint_random( spawnpoints );
	}
	spawnlogic_begin();
	k_favored_spawn_point_bonus = 25000;
	initweights( spawnpoints );
	obj = spawnstruct();
	getallalliedandenemyplayers( obj );
	numplayers = obj.allies.size + obj.enemies.size;
	allieddistanceweight = 2;
	myteam = self.team;
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		spawnpoint = spawnpoints[ i ];
		if ( !isDefined( spawnpoint.numplayersatlastupdate ) )
		{
			spawnpoint.numplayersatlastupdate = 0;
		}
		if ( spawnpoint.numplayersatlastupdate > 0 )
		{
			allydistsum = spawnpoint.distsum[ myteam ];
			enemydistsum = spawnpoint.enemydistsum[ myteam ];
			spawnpoint.weight = ( enemydistsum - ( allieddistanceweight * allydistsum ) ) / spawnpoint.numplayersatlastupdate;
			/*
/#
			if ( level.storespawndata || level.debugspawning )
			{
				spawnpoint.spawndata[ spawnpoint.spawndata.size ] = "Base weight: " + int( spawnpoint.weight ) + " = (" + int( enemydistsum ) + " - " + allieddistanceweight + "*" + int( allydistsum ) + ") / " + spawnpoint.numplayersatlastupdate;
#/
			}
			*/
		}
		else
		{
			spawnpoint.weight = 0;
			/*
/#
			if ( level.storespawndata || level.debugspawning )
			{
				spawnpoint.spawndata[ spawnpoint.spawndata.size ] = "Base weight: 0";
#/
			}
			*/
		}
	}
	if ( isDefined( favoredspawnpoints ) )
	{
		i = 0;
		while ( i < favoredspawnpoints.size )
		{
			if ( isDefined( favoredspawnpoints[ i ].weight ) )
			{
				favoredspawnpoints[ i ].weight += k_favored_spawn_point_bonus;
				i++;
				continue;
			}
			favoredspawnpoints[ i ].weight = k_favored_spawn_point_bonus;
			i++;
		}
	}
	avoidsamespawn( spawnpoints );
	avoidspawnreuse( spawnpoints, 1 );
	avoidweapondamage( spawnpoints );
	avoidvisibleenemies( spawnpoints, 1 );
	result = getspawnpoint_final( spawnpoints );
	/*
/#
	if ( getDvar( "scr_spawn_showbad" ) == "" )
	{
		setdvar( "scr_spawn_showbad", "0" );
	}
	if ( getDvar( "scr_spawn_showbad" ) == "1" )
	{
		checkbad( result );
#/
	}
	*/
	return result;
}

getspawnpoint_dm( spawnpoints ) //checked changed to match cerberus output
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
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
				dist = distance( spawnpoints[ i ].origin, aliveplayers[ j ].origin );
				if ( dist < baddist )
				{
					nearbybadamount += ( baddist - dist ) / baddist;
				}
				distfromideal = abs( dist - idealdist );
				totaldistfromideal += distfromideal;
			}
			avgdistfromideal = totaldistfromideal / aliveplayers.size;
			welldistancedamount = ( idealdist - avgdistfromideal ) / idealdist;
			spawnpoints[ i ].weight = ( welldistancedamount - ( nearbybadamount * 2 ) ) + randomfloat( 0,2 );
		}
	}
	avoidsamespawn( spawnpoints );
	avoidspawnreuse( spawnpoints, 0 );
	avoidweapondamage( spawnpoints );
	avoidvisibleenemies( spawnpoints, 0 );
	return getspawnpoint_final( spawnpoints );
}

spawnlogic_begin() //checked matches cerberus output
{
	/*
/#
	level.storespawndata = getDvarInt( "scr_recordspawndata" );
	level.debugspawning = getDvarInt( "scr_spawnpointdebug" ) > 0;
#/
	*/
}

init() //checked changed to match cerberus output
{
	/*
/#
	if ( getDvar( "scr_recordspawndata" ) == "" )
	{
		setdvar( "scr_recordspawndata", 0 );
	}
	level.storespawndata = getDvarInt( "scr_recordspawndata" );
	if ( getDvar( "scr_killbots" ) == "" )
	{
		setdvar( "scr_killbots", 0 );
	}
	if ( getDvar( "scr_killbottimer" ) == "" )
	{
		setdvar( "scr_killbottimer", 0,25 );
	}
	thread loopbotspawns();
#/
	*/
	level.spawnlogic_deaths = [];
	level.spawnlogic_spawnkills = [];
	level.players = [];
	level.grenades = [];
	level.pipebombs = [];
	level.spawnmins = ( 0, 0, 0 );
	level.spawnmaxs = ( 0, 0, 0 );
	level.spawnminsmaxsprimed = 0;
	if ( isDefined( level.safespawns ) )
	{
		for ( i = 0; i < level.safespawns.size; i++ )
		{
			level.safespawns[ i ] spawnpointinit();
		}
	}
	if ( getDvar( "scr_spawn_enemyavoiddist" ) == "" )
	{
		setdvar( "scr_spawn_enemyavoiddist", "800" );
	}
	if ( getDvar( "scr_spawn_enemyavoidweight" ) == "" )
	{
		setdvar( "scr_spawn_enemyavoidweight", "0" );
	}
	/*
/#
	if ( getDvar( "scr_spawnsimple" ) == "" )
	{
		setdvar( "scr_spawnsimple", "0" );
	}
	if ( getDvar( "scr_spawnpointdebug" ) == "" )
	{
		setdvar( "scr_spawnpointdebug", "0" );
	}
	if ( getDvarInt( "scr_spawnpointdebug" ) > 0 )
	{
		thread showdeathsdebug();
		thread updatedeathinfodebug();
		thread profiledebug();
	}
	if ( level.storespawndata )
	{
		thread allowspawndatareading();
	}
	if ( getDvar( "scr_spawnprofile" ) == "" )
	{
		setdvar( "scr_spawnprofile", "0" );
	}
	thread watchspawnprofile();
	thread spawngraphcheck();
#/
	*/
}

watchspawnprofile() //checked changed to match cerberus output
{
	/*
/#
	while ( 1 )
	{
		while ( 1 )
		{
			if ( getDvarInt( "scr_spawnprofile" ) > 0 )
			{
				break;
			}
			wait 0.05;
		}
		thread spawnprofile();
		while ( 1 )
		{
			if ( getDvarInt( "scr_spawnprofile" ) <= 0 )
			{
				break;
			}
			wait 0.05;
		}
		level notify( "stop_spawn_profile" );
#/
	}
	*/
}

spawnprofile() //checked matches cerberus output
{
	/*
/#
	level endon( "stop_spawn_profile" );
	while ( 1 )
	{
		if ( level.players.size > 0 && level.spawnpoints.size > 0 )
		{
			playernum = randomint( level.players.size );
			player = level.players[ playernum ];
			attempt = 1;
			while ( !isDefined( player ) && attempt < level.players.size )
			{
				playernum = ( playernum + 1 ) % level.players.size;
				attempt++;
				player = level.players[ playernum ];
			}
			player getspawnpoint_nearteam( level.spawnpoints );
		}
		wait 0.05;
#/
	}
	*/
}

spawngraphcheck() //checked changed to match cerberus output dvar taken from beta dump
{
	/*
/#
	while ( 1 )
	{
		if ( getDvarInt( "scr_spawngraph" ) < 1 )
		{
			wait 3;
		}
		thread spawngraph();
		return;
#/
	}
	*/
}

spawngraph() //dev call did not check
{
	/*
/#
	w = 20;
	h = 20;
	weightscale = 0,1;
	fakespawnpoints = [];
	corners = getentarray( "minimap_corner", "targetname" );
	if ( corners.size != 2 )
	{
		println( "^1 can't spawn graph: no minimap corners" );
		return;
	}
	min = corners[ 0 ].origin;
	max = corners[ 0 ].origin;
	if ( corners[ 1 ].origin[ 0 ] > max[ 0 ] )
	{
		max = ( corners[ 1 ].origin[ 0 ], max[ 1 ], max[ 2 ] );
	}
	else
	{
		min = ( corners[ 1 ].origin[ 0 ], min[ 1 ], min[ 2 ] );
	}
	if ( corners[ 1 ].origin[ 1 ] > max[ 1 ] )
	{
		max = ( max[ 0 ], corners[ 1 ].origin[ 1 ], max[ 2 ] );
	}
	else
	{
		min = ( min[ 0 ], corners[ 1 ].origin[ 1 ], min[ 2 ] );
	}
	i = 0;
	y = 0;
	while ( y < h )
	{
		yamnt = y / ( h - 1 );
		x = 0;
		while ( x < w )
		{
			xamnt = x / ( w - 1 );
			fakespawnpoints[ i ] = spawnstruct();
			fakespawnpoints[ i ].origin = ( ( min[ 0 ] * xamnt ) + ( max[ 0 ] * ( 1 - xamnt ) ), ( min[ 1 ] * yamnt ) + ( max[ 1 ] * ( 1 - yamnt ) ), min[ 2 ] );
			fakespawnpoints[ i ].angles = ( -1, -1, -1 );
			fakespawnpoints[ i ].forward = anglesToForward( fakespawnpoints[ i ].angles );
			fakespawnpoints[ i ].sighttracepoint = fakespawnpoints[ i ].origin;
			i++;
			x++;
		}
		y++;
	}
	didweights = 0;
	while ( 1 )
	{
		spawni = 0;
		numiters = 5;
		i = 0;
		while ( i < numiters )
		{
			if ( level.players.size && isDefined( level.players[ 0 ].team ) || level.players[ 0 ].team == "spectator" && !isDefined( level.players[ 0 ].class ) )
			{
				break;
			}
			else
			{
				endspawni = spawni + ( fakespawnpoints.size / numiters );
				if ( i == ( numiters - 1 ) )
				{
					endspawni = fakespawnpoints.size;
				}
				while ( spawni < endspawni )
				{
					spawnpointupdate( fakespawnpoints[ spawni ] );
					spawni++;
				}
				if ( didweights )
				{
					level.players[ 0 ] drawspawngraph( fakespawnpoints, w, h, weightscale );
				}
				wait 0,05;
				i++;
			}
		}
		while ( level.players.size && isDefined( level.players[ 0 ].team ) || level.players[ 0 ].team == "spectator" && !isDefined( level.players[ 0 ].class ) )
		{
			wait 1;
		}
		level.players[ 0 ] getspawnpoint_nearteam( fakespawnpoints );
		i = 0;
		while ( i < fakespawnpoints.size )
		{
			setupspawngraphpoint( fakespawnpoints[ i ], weightscale );
			i++;
		}
		didweights = 1;
		level.players[ 0 ] drawspawngraph( fakespawnpoints, w, h, weightscale );
		wait 0,05;
#/
	}
	*/
}

drawspawngraph( fakespawnpoints, w, h, weightscale ) //dev call did not check
{
	/*
/#
	i = 0;
	y = 0;
	while ( y < h )
	{
		yamnt = y / ( h - 1 );
		x = 0;
		while ( x < w )
		{
			xamnt = x / ( w - 1 );
			if ( y > 0 )
			{
				spawngraphline( fakespawnpoints[ i ], fakespawnpoints[ i - w ], weightscale );
			}
			if ( x > 0 )
			{
				spawngraphline( fakespawnpoints[ i ], fakespawnpoints[ i - 1 ], weightscale );
			}
			i++;
			x++;
		}
		y++;
#/
	}
	*/
}

setupspawngraphpoint( s1, weightscale ) //dev call did not check
{
	/*
/#
	s1.visible = 1;
	if ( s1.weight < ( -1000 / weightscale ) )
	{
		s1.visible = 0;
#/
	}
	*/
}

spawngraphline( s1, s2, weightscale ) //dev call did not check
{
	/*
/#
	if ( !s1.visible || !s2.visible )
	{
		return;
	}
	p1 = s1.origin + ( 0, 0, ( s1.weight * weightscale ) + 100 );
	p2 = s2.origin + ( 0, 0, ( s2.weight * weightscale ) + 100 );
	line( p1, p2, ( -1, -1, -1 ) );
#/
	*/
}

loopbotspawns() //dev call did not check
{
	/*
/#
	while ( 1 )
	{
		while ( getDvarInt( "scr_killbots" ) < 1 )
		{
			wait 3;
		}
		while ( !isDefined( level.players ) )
		{
			wait 0,05;
		}
		bots = [];
		i = 0;
		while ( i < level.players.size )
		{
			if ( !isDefined( level.players[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				if ( level.players[ i ].sessionstate == "playing" && issubstr( level.players[ i ].name, "bot" ) )
				{
					bots[ bots.size ] = level.players[ i ];
				}
			}
			i++;
		}
		while ( bots.size > 0 )
		{
			if ( getDvarInt( "scr_killbots" ) == 1 )
			{
				killer = bots[ randomint( bots.size ) ];
				victim = bots[ randomint( bots.size ) ];
				victim thread [[ level.callbackplayerdamage ]]( killer, killer, 1000, 0, "MOD_RIFLE_BULLET", "none", ( -1, -1, -1 ), ( -1, -1, -1 ), "none", 0, 0 );
				break;
			}
			else
			{
				numkills = getDvarInt( "scr_killbots" );
				lastvictim = undefined;
				index = 0;
				while ( index < numkills )
				{
					killer = bots[ randomint( bots.size ) ];
					victim = bots[ randomint( bots.size ) ];
					while ( isDefined( lastvictim ) && victim == lastvictim )
					{
						victim = bots[ randomint( bots.size ) ];
					}
					victim thread [[ level.callbackplayerdamage ]]( killer, killer, 1000, 0, "MOD_RIFLE_BULLET", "none", ( -1, -1, -1 ), ( -1, -1, -1 ), "none", 0, 0 );
					lastvictim = victim;
					index++;
				}
			}
		}
		if ( getDvar( "scr_killbottimer" ) != "" )
		{
			wait getDvarFloat( "scr_killbottimer" );
			continue;
		}
		else
		{
			wait 0,05;
		}
#/
	}
	*/
}

allowspawndatareading() //dev call did not check
{
	/*
/#
	setdvar( "scr_showspawnid", "" );
	prevval = getDvar( "scr_showspawnid" );
	prevrelval = getDvar( "scr_spawnidcycle" );
	readthistime = 0;
	while ( 1 )
	{
		val = getDvar( "scr_showspawnid" );
		relval = undefined;
		while ( !isDefined( val ) || val == prevval )
		{
			relval = getDvar( "scr_spawnidcycle" );
			if ( isDefined( relval ) && relval != "" )
			{
				setdvar( "scr_spawnidcycle", "" );
				break;
			}
			else
			{
				wait 0,5;
			}
		}
		prevval = val;
		readthistime = 0;
		readspawndata( val, relval );
		if ( !isDefined( level.curspawndata ) )
		{
			println( "No spawn data to draw." );
		}
		else
		{
			println( "Drawing spawn ID " + level.curspawndata.id );
		}
		thread drawspawndata();
#/
	}
	*/
}

showdeathsdebug() //dev call did not check 
{
	/*
/#
	while ( 1 )
	{
		while ( getDvar( "scr_spawnpointdebug" ) == "0" )
		{
			wait 3;
		}
		time = getTime();
		i = 0;
		while ( i < level.spawnlogic_deaths.size )
		{
			if ( isDefined( level.spawnlogic_deaths[ i ].los ) )
			{
				line( level.spawnlogic_deaths[ i ].org, level.spawnlogic_deaths[ i ].killorg, ( -1, -1, -1 ) );
			}
			else
			{
				line( level.spawnlogic_deaths[ i ].org, level.spawnlogic_deaths[ i ].killorg, ( -1, -1, -1 ) );
			}
			killer = level.spawnlogic_deaths[ i ].killer;
			if ( isDefined( killer ) && isalive( killer ) )
			{
				line( level.spawnlogic_deaths[ i ].killorg, killer.origin, ( 0,4, 0,4, 0,8 ) );
			}
			i++;
		}
		p = 0;
		while ( p < level.players.size )
		{
			if ( !isDefined( level.players[ p ] ) )
			{
				p++;
				continue;
			}
			else
			{
				if ( isDefined( level.players[ p ].spawnlogic_killdist ) )
				{
					print3d( level.players[ p ].origin + vectorScale( ( -1, -1, -1 ), 64 ), level.players[ p ].spawnlogic_killdist, ( -1, -1, -1 ) );
				}
			}
			p++;
		}
		oldspawnkills = level.spawnlogic_spawnkills;
		level.spawnlogic_spawnkills = [];
		i = 0;
		while ( i < oldspawnkills.size )
		{
			spawnkill = oldspawnkills[ i ];
			if ( spawnkill.dierwasspawner )
			{
				line( spawnkill.spawnpointorigin, spawnkill.dierorigin, ( 0,4, 0,5, 0,4 ) );
				line( spawnkill.dierorigin, spawnkill.killerorigin, ( 0, 1, 1 ) );
				print3d( spawnkill.dierorigin + vectorScale( ( -1, -1, -1 ), 32 ), "SPAWNKILLED!", ( 0, 1, 1 ) );
			}
			else
			{
				line( spawnkill.spawnpointorigin, spawnkill.killerorigin, ( 0,4, 0,5, 0,4 ) );
				line( spawnkill.killerorigin, spawnkill.dierorigin, ( 0, 1, 1 ) );
				print3d( spawnkill.dierorigin + vectorScale( ( -1, -1, -1 ), 32 ), "SPAWNDIED!", ( 0, 1, 1 ) );
			}
			if ( ( time - spawnkill.time ) < 60000 )
			{
				level.spawnlogic_spawnkills[ level.spawnlogic_spawnkills.size ] = oldspawnkills[ i ];
			}
			i++;
		}
		wait 0,05;
#/
	}
	*/
}

updatedeathinfodebug() //checked changed to match cerberus output
{
	while ( 1 )
	{
		if ( getDvar( "scr_spawnpointdebug" ) == "0" )
		{
			wait 3;
		}
		updatedeathinfo();
		wait 3;
	}
}

spawnweightdebug( spawnpoints ) //checked dev call did not check
{
	level notify( "stop_spawn_weight_debug" );
	level endon( "stop_spawn_weight_debug" );
	/*
/#
	while ( 1 )
	{
		while ( getDvar( "scr_spawnpointdebug" ) == "0" )
		{
			wait 3;
		}
		textoffset = vectorScale( ( -1, -1, -1 ), 12 );
		i = 0;
		while ( i < spawnpoints.size )
		{
			amnt = 1 * ( 1 - ( spawnpoints[ i ].weight / -100000 ) );
			if ( amnt < 0 )
			{
				amnt = 0;
			}
			if ( amnt > 1 )
			{
				amnt = 1;
			}
			orig = spawnpoints[ i ].origin + vectorScale( ( -1, -1, -1 ), 80 );
			print3d( orig, int( spawnpoints[ i ].weight ), ( 1, amnt, 0,5 ) );
			orig += textoffset;
			while ( isDefined( spawnpoints[ i ].spawndata ) )
			{
				j = 0;
				while ( j < spawnpoints[ i ].spawndata.size )
				{
					print3d( orig, spawnpoints[ i ].spawndata[ j ], vectorScale( ( -1, -1, -1 ), 0,5 ) );
					orig += textoffset;
					j++;
				}
			}
			while ( isDefined( spawnpoints[ i ].sightchecks ) )
			{
				j = 0;
				while ( j < spawnpoints[ i ].sightchecks.size )
				{
					if ( spawnpoints[ i ].sightchecks[ j ].penalty == 0 )
					{
						j++;
						continue;
					}
					else
					{
						print3d( orig, "Sight to enemy: -" + spawnpoints[ i ].sightchecks[ j ].penalty, vectorScale( ( -1, -1, -1 ), 0,5 ) );
						orig += textoffset;
					}
					j++;
				}
			}
			i++;
		}
		wait 0,05;
#/
	}
	*/
}

profiledebug() //checked changed to match cerberus output
{
	while ( 1 )
	{
		if ( getDvar( "scr_spawnpointprofile" ) != "1" )
		{
			wait 3;
		}
		for ( i = 0; i < level.spawnpoints.size; i++ )
		{
			level.spawnpoints[ i ].weight = randomint( 10000 );
		}
		if ( level.players.size > 0 )
		{
			level.players[ randomint( level.players.size ) ] getspawnpoint_nearteam( level.spawnpoints );
		}
		wait 0.05;
	}
}

debugnearbyplayers( players, origin ) //dev call did not check
{
	/*
/#
	if ( getDvar( "scr_spawnpointdebug" ) == "0" )
	{
		return;
	}
	starttime = getTime();
	while ( 1 )
	{
		i = 0;
		while ( i < players.size )
		{
			line( players[ i ].origin, origin, ( 0,5, 1, 0,5 ) );
			i++;
		}
		if ( ( getTime() - starttime ) > 5000 )
		{
			return;
		}
		wait 0,05;
#/
	}
	*/
}

deathoccured( dier, killer ) //checked matches cerberus output
{
}

checkforsimilardeaths( deathinfo ) //checked partially changed to match cerberus output see info.md
{
	i = 0;
	while ( i < level.spawnlogic_deaths.size )
	{
		if ( level.spawnlogic_deaths[ i ].killer == deathinfo.killer )
		{
			dist = distance( level.spawnlogic_deaths[ i ].org, deathinfo.org );
			if ( dist > 200 )
			{
				i++;
				continue;
			}
			dist = distance( level.spawnlogic_deaths[ i ].killorg, deathinfo.killorg );
			if ( dist > 200 )
			{
				i++;
				continue;
			}
			level.spawnlogic_deaths[ i ].remove = 1;
		}
		i++;
	}
}

updatedeathinfo() //checked changed to match cerberus output
{
	time = getTime();
	for ( i = 0; i < level.spawnlogic_deaths.size; i++ )
	{
		deathinfo = level.spawnlogic_deaths[ i ];
		if ( ( time - deathinfo.time ) > 90000 || isDefined( deathinfo.killer ) || isalive( deathinfo.killer ) || !isDefined( level.teams[ deathinfo.killer.team ] ) || distance( deathinfo.killer.origin, deathinfo.killorg ) > 400 )
		{
			level.spawnlogic_deaths[ i ].remove = 1;
		}
	}
	oldarray = level.spawnlogic_deaths;
	level.spawnlogic_deaths = [];
	start = 0;
	if ( ( oldarray.size - 1024 ) > 0 )
	{
		start = oldarray.size - 1024;
	}
	for ( i = start; i < oldarray.size; i++ )
	{
		if ( !isDefined( oldarray[ i ].remove ) )
		{
			level.spawnlogic_deaths[ level.spawnlogic_deaths.size ] = oldarray[ i ];
		}
	}
}

ispointvulnerable( playerorigin ) //checked changed to match cerberus output
{
	pos = self.origin + level.bettymodelcenteroffset;
	playerpos = playerorigin + vectorScale( ( 0, 0, 1 ), 32 );
	distsqrd = distancesquared( pos, playerpos );
	forward = anglesToForward( self.angles );
	if ( distsqrd < ( level.bettydetectionradius * level.bettydetectionradius ) )
	{
		playerdir = vectornormalize( playerpos - pos );
		angle = acos( vectordot( playerdir, forward ) );
		if ( angle < level.bettydetectionconeangle )
		{
			return 1;
		}
	}
	return 0;
}

avoidweapondamage( spawnpoints ) //checked partially changed to match cerberus output see info.md
{
	if ( getDvar( "scr_spawnpointnewlogic" ) == "0" )
	{
		return;
	}
	weapondamagepenalty = 100000;
	if ( getDvar( "scr_spawnpointdeathpenalty" ) != "" && getDvar( "scr_spawnpointdeathpenalty" ) != "0" )
	{
		weapondamagepenalty = getDvarFloat( "scr_spawnpointdeathpenalty" );
	}
	mingrenadedistsquared = 62500;
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		j = 0;
		while ( j < level.grenades.size )
		{
			if ( !isDefined( level.grenades[ j ] ) )
			{
				j++;
				continue;
			}
			if ( distancesquared( spawnpoints[ i ].origin, level.grenades[ j ].origin ) < mingrenadedistsquared )
			{
				spawnpoints[ i ].weight -= weapondamagepenalty;
				/*
/#
				if ( level.storespawndata || level.debugspawning )
				{
					spawnpoints[ i ].spawndata[ spawnpoints[ i ].spawndata.size ] = "Was near grenade: -" + int( weapondamagepenalty );
#/
				}
				*/
			}
			j++;
		}
	}
}

spawnperframeupdate() //checked matches cerberus output
{
	spawnpointindex = 0;
	while ( 1 )
	{
		wait 0.05;
		if ( !isDefined( level.spawnpoints ) )
		{
			return;
		}
		spawnpointindex = ( spawnpointindex + 1 ) % level.spawnpoints.size;
		spawnpoint = level.spawnpoints[ spawnpointindex ];
		spawnpointupdate( spawnpoint );
	}
}

getnonteamsum( skip_team, sums ) //checked partially changed to match cerberus output see info.md
{
	value = 0;
	foreach ( team in level.teams )
	{
		if ( team == skip_team )
		{
		}
		else
		{
			value += sums[ team ];
		}
	}
	return value;
}

getnonteammindist( skip_team, mindists ) //checked partially changed to match cerberus output see info.md
{
	dist = 9999999;
	foreach ( team in level.teams )
	{
		if ( team == skip_team )
		{
		}
		else
		{
			if ( dist > mindists[ team ] )
			{
				dist = mindists[ team ];
			}
		}
	}
	return dist;
}

spawnpointupdate( spawnpoint ) //checked changed to match cerberus output
{
	if ( level.teambased )
	{
		sights = [];
		foreach ( team in level.teams )
		{
			spawnpoint.enemysights[ team ] = 0;
			sights[ team ] = 0;
			spawnpoint.nearbyplayers[ team ] = [];
		}
	}
	else 
	{
		spawnpoint.enemysights = 0;
		spawnpoint.nearbyplayers[ "all" ] = [];
	}
	spawnpointdir = spawnpoint.forward;
	debug = 0;
	/*
/#
	debug = getDvarInt( "scr_spawnpointdebug" ) > 0;
#/
	*/
	mindist = [];
	distsum = [];
	if ( !level.teambased )
	{
		mindist[ "all" ] = 9999999;
	}
	foreach ( team in level.teams )
	{
		spawnpoint.distsum[ team ] = 0;
		spawnpoint.enemydistsum[ team ] = 0;
		spawnpoint.minenemydist[ team ] = 9999999;
		mindist[ team ] = 9999999;
	}
	spawnpoint.numplayersatlastupdate = 0;
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( player.sessionstate != "playing" )
		{
			i++;
			continue;
		}
		diff = player.origin - spawnpoint.origin;
		diff = ( diff[ 0 ], diff[ 1 ], 0 );
		dist = length( diff );
		team = "all";
		if ( level.teambased )
		{
			team = player.team;
		}
		if ( dist < 1024 )
		{
			spawnpoint.nearbyplayers[ team ][ spawnpoint.nearbyplayers[ team ].size ] = player;
		}
		if ( dist < mindist[ team ] )
		{
			mindist[ team ] = dist;
		}
		distsum[ team ] += dist;
		spawnpoint.numplayersatlastupdate++;
		pdir = anglesToForward( player.angles );
		if ( vectordot( spawnpointdir, diff ) < 0 && vectordot( pdir, diff ) > 0 )
		{
			i++;
			continue;
		}
		losexists = bullettracepassed( player.origin + vectorScale( ( -1, -1, -1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined );
		spawnpoint.lastsighttracetime = getTime();
		if ( losexists )
		{
			if ( level.teambased )
			{
				sights[ player.team ]++;
			}
			else
			{
				spawnpoint.enemysights++;
			}
			/*
/#
			if ( debug )
			{
				line( player.origin + vectorScale( ( 0, 0, 1 ), 50 ), spawnpoint.sighttracepoint, ( 0.5, 1, 0.5 ) );
#/
			}
			*/
		}
		i++;
	}
	if ( level.teambased )
	{
		foreach ( team in level.teams )
		{
			spawnpoint.enemysights[ team ] = getnonteamsum( team, sights );
			spawnpoint.minenemydist[ team ] = getnonteammindist( team, mindist );
			spawnpoint.distsum[ team ] = distsum[ team ];
			spawnpoint.enemydistsum[ team ] = getnonteamsum( team, distsum );
		}
	}
	else
	{
		spawnpoint.distsum[ "all" ] = distsum[ "all" ];
		spawnpoint.enemydistsum[ "all" ] = distsum[ "all" ];
		spawnpoint.minenemydist[ "all" ] = mindist[ "all" ];
	}
}

getlospenalty() //checked matches cerberus output dvars taken from beta dump
{
	if ( getDvar( "scr_spawnpointlospenalty" ) != "" && getDvar( "scr_spawnpointlospenalty" ) != "0" )
	{
		return getDvarFloat( "scr_spawnpointlospenalty" );
	}
	return 100000;
}

lastminutesighttraces( spawnpoint ) //checked partially changed to match cerberus output see info.md
{
	if ( !isDefined( spawnpoint.nearbyplayers ) )
	{
		return 0;
	}
	closest = undefined;
	closestdistsq = undefined;
	secondclosest = undefined;
	secondclosestdistsq = undefined;
	foreach ( team in spawnpoint.nearbyplayers )
	{
		if ( team == self.team )
		{
		}
		else
		{
			i = 0;
			while ( i < spawnpoint.nearbyplayers[ team ].size )
			{
				player = spawnpoint.nearbyplayers[ team ][ i ];
				if ( !isDefined( player ) )
				{
					i++;
					continue;
				}
				if ( player.sessionstate != "playing" )
				{
					i++;
					continue;
				}
				if ( player == self )
				{
					i++;
					continue;
				}
				distsq = distancesquared( spawnpoint.origin, player.origin );
				if ( !isDefined( closest ) || distsq < closestdistsq )
				{
					secondclosest = closest;
					secondclosestdistsq = closestdistsq;
					closest = player;
					closestdistsq = distsq;
				}
				else if ( !isDefined( secondclosest ) || distsq < secondclosestdistsq )
				{
					secondclosest = player;
					secondclosestdistsq = distsq;
				}
				i++;
			}
		}
	}
	if ( isDefined( closest ) )
	{
		if ( bullettracepassed( closest.origin + vectorScale( ( 0, 0, 1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined ) )
		{
			return 1;
		}
	}
	if ( isDefined( secondclosest ) )
	{
		if ( bullettracepassed( secondclosest.origin + vectorScale( ( 0, 0, 1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined ) )
		{
			return 1;
		}
	}
	return 0;
}

avoidvisibleenemies( spawnpoints, teambased ) //checked partially changed to match beta dump see info.md
{
	if ( getDvar( "scr_spawnpointnewlogic" ) == "0" )
	{
		return;
	}
	lospenalty = getlospenalty();
	mindistteam = self.team;
	if ( teambased )
	{
		i = 0;
		while ( i < spawnpoints.size )
		{
			if ( !isDefined( spawnpoints[ i ].enemysights ) )
			{
				i++;
				continue;
			}
			penalty = lospenalty * spawnpoints[ i ].enemysights[ self.team ];
			spawnpoints[ i ].weight -= penalty;
			/*
/#
			if ( level.storespawndata || level.debugspawning )
			{
				index = spawnpoints[ i ].sightchecks.size;
				spawnpoints[ i ].sightchecks[ index ] = spawnstruct();
				spawnpoints[ i ].sightchecks[ index ].penalty = penalty;
#/
			}
			*/
			i++;
		}
	}
	else
	{
		i = 0;
		while ( i < spawnpoints.size )
		{
			if ( !isDefined( spawnpoints[ i ].enemysights ) )
			{
				i++;
				continue;
			}
			penalty = lospenalty * spawnpoints[ i ].enemysights;
			spawnpoints[ i ].weight -= penalty;
			/*
/#
			if ( level.storespawndata || level.debugspawning )
			{
				index = spawnpoints[ i ].sightchecks.size;
				spawnpoints[ i ].sightchecks[ index ] = spawnstruct();
				spawnpoints[ i ].sightchecks[ index ].penalty = penalty;
#/
			}
			*/
			i++;
		}
	}
	mindistteam = "all";
	avoidweight = getDvarFloat( "scr_spawn_enemyavoidweight" );
	if ( avoidweight != 0 )
	{
		nearbyenemyouterrange = getDvarFloat( "scr_spawn_enemyavoiddist" );
		nearbyenemyouterrangesq = nearbyenemyouterrange * nearbyenemyouterrange;
		nearbyenemypenalty = 1500 * avoidweight;
		nearbyenemyminorpenalty = 800 * avoidweight;
		lastattackerorigin = vectorScale( ( -1, -1, -1 ), 99999 );
		lastdeathpos = vectorScale( ( -1, -1, -1 ), 99999 );
		if ( isalive( self.lastattacker ) )
		{
			lastattackerorigin = self.lastattacker.origin;
		}
		if ( isDefined( self.lastdeathpos ) )
		{
			lastdeathpos = self.lastdeathpos;
		}
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			mindist = spawnpoints[ i ].minenemydist[ mindistteam ];
			if ( mindist < ( nearbyenemyouterrange * 2 ) )
			{
				penalty = nearbyenemyminorpenalty * ( 1 - ( mindist / ( nearbyenemyouterrange * 2 ) ) );
				if ( mindist < nearbyenemyouterrange )
				{
					penalty += nearbyenemypenalty * ( 1 - ( mindist / nearbyenemyouterrange ) );
				}
				if ( penalty > 0 )
				{
					spawnpoints[ i ].weight -= penalty;
					/*
/#
					if ( level.storespawndata || level.debugspawning )
					{
						spawnpoints[ i ].spawndata[ spawnpoints[ i ].spawndata.size ] = "Nearest enemy at " + int( spawnpoints[ i ].minenemydist[ mindistteam ] ) + " units: -" + int( penalty );
#/
					}
					*/
				}
			}
		}
	}
}

avoidspawnreuse( spawnpoints, teambased ) //checked partially changed to match beta dump see info.md
{
	if ( getDvar( "scr_spawnpointnewlogic" ) == "0" )
	{
		return;
	}
	time = getTime();
	maxtime = 10000;
	maxdistsq = 1048576;
	i = 0;
	while ( i < spawnpoints.size )
	{
		spawnpoint = spawnpoints[ i ];
		if ( isDefined( spawnpoint.lastspawnedplayer ) || !isDefined( spawnpoint.lastspawntime ) || !isalive( spawnpoint.lastspawnedplayer ) )
		{
			i++;
			continue;
		}
		if ( spawnpoint.lastspawnedplayer == self )
		{
			i++;
			continue;
		}
		if ( teambased && spawnpoint.lastspawnedplayer.team == self.team )
		{
			i++;
			continue;
		}
		timepassed = time - spawnpoint.lastspawntime;
		if ( timepassed < maxtime )
		{
			distsq = distancesquared( spawnpoint.lastspawnedplayer.origin, spawnpoint.origin );
			if ( distsq < maxdistsq )
			{
				worsen = ( 5000 * ( 1 - ( distsq / maxdistsq ) ) ) * ( 1 - ( timepassed / maxtime ) );
				spawnpoint.weight -= worsen;
				/*
/#
				if ( level.storespawndata || level.debugspawning )
				{
					spawnpoint.spawndata[ spawnpoint.spawndata.size ] = "Was recently used: -" + worsen;
#/
				}
				*/
			}
			else
			{
				spawnpoint.lastspawnedplayer = undefined;
			}
		}
		else
		{
			spawnpoint.lastspawnedplayer = undefined;
		}
		i++;
	}
}

avoidsamespawn( spawnpoints ) //checked changed to match cerberus output
{
	if ( getDvar( "scr_spawnpointnewlogic" ) == "0" )
	{
		return;
	}
	if ( !isDefined( self.lastspawnpoint ) )
	{
		return;
	}
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( spawnpoints[ i ] == self.lastspawnpoint )
		{
			spawnpoints[ i ].weight -= 50000;
			/*
/#
			if ( level.storespawndata || level.debugspawning )
			{
				spawnpoints[ i ].spawndata[ spawnpoints[ i ].spawndata.size ] = "Was last spawnpoint: -50000";
#/
			}
			*/
			return;
		}
	}
}

getrandomintermissionpoint() //checked matches cerberus output
{
	spawnpoints = getentarray( "mp_global_intermission", "classname" );
	if ( !spawnpoints.size )
	{
		spawnpoints = getentarray( "info_player_start", "classname" );
	}
	/*
/#
	assert( spawnpoints.size );
#/
	*/
	spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( spawnpoints );
	return spawnpoint;
}

