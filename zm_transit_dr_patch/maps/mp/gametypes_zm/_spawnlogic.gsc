#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_callbacksetup;
#include maps/mp/_utility;
#include common_scripts/utility;

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
	}
}

findboxcenter( mins, maxs )
{
	center = ( -1, -1, -1 );
	center = maxs - mins;
	center = ( center[ 0 ] / 2, center[ 1 ] / 2, center[ 2 ] / 2 ) + mins;
	return center;
}

expandmins( mins, point )
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

expandmaxs( maxs, point )
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

addspawnpointsinternal( team, spawnpointname )
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
	index = 0;
	while ( index < level.teamspawnpoints[ team ].size )
	{
		spawnpoint = level.teamspawnpoints[ team ][ index ];
		if ( !isDefined( spawnpoint.inited ) )
		{
			spawnpoint spawnpointinit();
			level.spawnpoints[ level.spawnpoints.size ] = spawnpoint;
		}
		index++;
	}
	index = 0;
	while ( index < oldspawnpoints.size )
	{
		origin = oldspawnpoints[ index ].origin;
		level.spawnmins = expandmins( level.spawnmins, origin );
		level.spawnmaxs = expandmaxs( level.spawnmaxs, origin );
		level.teamspawnpoints[ team ][ level.teamspawnpoints[ team ].size ] = oldspawnpoints[ index ];
		index++;
	}
	if ( !level.teamspawnpoints[ team ].size )
	{
/#
		println( "^1ERROR: No " + spawnpointname + " spawnpoints found in level!" );
#/
		maps/mp/gametypes_zm/_callbacksetup::abortlevel();
		wait 1;
		return;
	}
}

clearspawnpoints()
{
	_a87 = level.teams;
	_k87 = getFirstArrayKey( _a87 );
	while ( isDefined( _k87 ) )
	{
		team = _a87[ _k87 ];
		level.teamspawnpoints[ team ] = [];
		_k87 = getNextArrayKey( _a87, _k87 );
	}
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
	level.teamspawnpoints[ team ] = [];
	index = 0;
	while ( index < level.spawn_point_team_class_names[ team ].size )
	{
		addspawnpointsinternal( team, level.spawn_point_team_class_names[ team ][ index ] );
		index++;
	}
}

placespawnpoints( spawnpointname )
{
	addspawnpointclassname( spawnpointname );
	spawnpoints = getspawnpointarray( spawnpointname );
/#
	if ( !isDefined( level.extraspawnpointsused ) )
	{
		level.extraspawnpointsused = [];
#/
	}
	if ( !spawnpoints.size )
	{
/#
		println( "^1No " + spawnpointname + " spawnpoints found in level!" );
#/
		maps/mp/gametypes_zm/_callbacksetup::abortlevel();
		wait 1;
		return;
	}
	index = 0;
	while ( index < spawnpoints.size )
	{
		spawnpoints[ index ] spawnpointinit();
/#
		spawnpoints[ index ].fakeclassname = spawnpointname;
		level.extraspawnpointsused[ level.extraspawnpointsused.size ] = spawnpoints[ index ];
#/
		index++;
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
	index = 0;
	while ( index < spawnpoints.size )
	{
		spawnpoints[ index ] placespawnpoint();
		index++;
	}
}

addspawnpointclassname( spawnpointclassname )
{
	if ( !isDefined( level.spawn_point_class_names ) )
	{
		level.spawn_point_class_names = [];
	}
	level.spawn_point_class_names[ level.spawn_point_class_names.size ] = spawnpointclassname;
}

addspawnpointteamclassname( team, spawnpointclassname )
{
	level.spawn_point_team_class_names[ team ][ level.spawn_point_team_class_names[ team ].size ] = spawnpointclassname;
}

getspawnpointarray( classname )
{
	spawnpoints = getentarray( classname, "classname" );
	if ( !isDefined( level.extraspawnpoints ) || !isDefined( level.extraspawnpoints[ classname ] ) )
	{
		return spawnpoints;
	}
	i = 0;
	while ( i < level.extraspawnpoints[ classname ].size )
	{
		spawnpoints[ spawnpoints.size ] = level.extraspawnpoints[ classname ][ i ];
		i++;
	}
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
	spawnpoint.forward = anglesToForward( spawnpoint.angles );
	spawnpoint.sighttracepoint = spawnpoint.origin + vectorScale( ( -1, -1, -1 ), 50 );
	spawnpoint.inited = 1;
}

getteamspawnpoints( team )
{
	return level.teamspawnpoints[ team ];
}

getspawnpoint_final( spawnpoints, useweights )
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
	else i = 0;
	while ( i < spawnpoints.size )
	{
		if ( isDefined( self.lastspawnpoint ) && self.lastspawnpoint == spawnpoints[ i ] )
		{
			i++;
			continue;
		}
		else
		{
			if ( positionwouldtelefrag( spawnpoints[ i ].origin ) )
			{
				i++;
				continue;
			}
			else
			{
				bestspawnpoint = spawnpoints[ i ];
				break;
			}
		}
		i++;
	}
	while ( !isDefined( bestspawnpoint ) )
	{
		while ( isDefined( self.lastspawnpoint ) && !positionwouldtelefrag( self.lastspawnpoint.origin ) )
		{
			i = 0;
			while ( i < spawnpoints.size )
			{
				if ( spawnpoints[ i ] == self.lastspawnpoint )
				{
					bestspawnpoint = spawnpoints[ i ];
					break;
				}
				else
				{
					i++;
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
/#
	self storespawndata( spawnpoints, useweights, bestspawnpoint );
#/
	return bestspawnpoint;
}

finalizespawnpointchoice( spawnpoint )
{
	time = getTime();
	self.lastspawnpoint = spawnpoint;
	self.lastspawntime = time;
	spawnpoint.lastspawnedplayer = self;
	spawnpoint.lastspawntime = time;
}

getbestweightedspawnpoint( spawnpoints )
{
	maxsighttracedspawnpoints = 3;
	try = 0;
	while ( try <= maxsighttracedspawnpoints )
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
				else bestspawnpoints = [];
				bestspawnpoints[ 0 ] = spawnpoints[ i ];
				bestweight = spawnpoints[ i ].weight;
				i++;
				continue;
			}
			else
			{
				if ( spawnpoints[ i ].weight == bestweight )
				{
					if ( positionwouldtelefrag( spawnpoints[ i ].origin ) )
					{
						i++;
						continue;
					}
					else
					{
						bestspawnpoints[ bestspawnpoints.size ] = spawnpoints[ i ];
					}
				}
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
/#
		if ( level.storespawndata || level.debugspawning )
		{
			bestspawnpoint.spawndata[ bestspawnpoint.spawndata.size ] = "Last minute sight trace: -" + penalty;
#/
		}
		bestspawnpoint.weight -= penalty;
		bestspawnpoint.lastsighttracetime = getTime();
		try++;
	}
}

checkbad( spawnpoint )
{
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
		else
		{
			if ( level.teambased && player.team == self.team )
			{
				i++;
				continue;
			}
			else
			{
				losexists = bullettracepassed( player.origin + vectorScale( ( -1, -1, -1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined );
				if ( losexists )
				{
					thread badspawnline( spawnpoint.sighttracepoint, player.origin + vectorScale( ( -1, -1, -1 ), 50 ), self.name, player.name );
				}
			}
		}
		i++;
#/
	}
}

badspawnline( start, end, name1, name2 )
{
/#
	dist = distance( start, end );
	i = 0;
	while ( i < 200 )
	{
		line( start, end, ( -1, -1, -1 ) );
		print3d( start, "Bad spawn! " + name1 + ", dist = " + dist );
		print3d( end, name2 );
		wait 0,05;
		i++;
#/
	}
}

storespawndata( spawnpoints, useweights, bestspawnpoint )
{
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
	i = 0;
	while ( i < spawnpoints.size )
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
		j = 0;
		while ( j < spawnpoints[ i ].spawndata.size )
		{
			str += spawnpoints[ i ].spawndata[ j ] + ",";
			j++;
		}
		str += spawnpoints[ i ].sightchecks.size + ",";
		j = 0;
		while ( j < spawnpoints[ i ].sightchecks.size )
		{
			str += ( spawnpoints[ i ].sightchecks[ j ].penalty + "," ) + vectostr( spawnpoints[ i ].origin ) + ",";
			j++;
		}
		fprintfields( file, str );
		i++;
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
		else
		{
			numallies++;
			str += vectostr( obj.allies[ i ].origin ) + ",";
		}
		i++;
	}
	i = 0;
	while ( i < obj.enemies.size )
	{
		numenemies++;
		str += vectostr( obj.enemies[ i ].origin ) + ",";
		i++;
	}
	str = ( numallies + "," ) + numenemies + "," + str;
	fprintfields( file, str );
	otherdata = [];
	if ( isDefined( level.bombguy ) )
	{
		index = otherdata.size;
		otherdata[ index ] = spawnstruct();
		otherdata[ index ].origin = level.bombguy.origin + vectorScale( ( -1, -1, -1 ), 20 );
		otherdata[ index ].text = "Bomb holder";
	}
	else
	{
		if ( isDefined( level.bombpos ) )
		{
			index = otherdata.size;
			otherdata[ index ] = spawnstruct();
			otherdata[ index ].origin = level.bombpos;
			otherdata[ index ].text = "Bomb";
		}
	}
	while ( isDefined( level.flags ) )
	{
		i = 0;
		while ( i < level.flags.size )
		{
			index = otherdata.size;
			otherdata[ index ] = spawnstruct();
			otherdata[ index ].origin = level.flags[ i ].origin;
			otherdata[ index ].text = level.flags[ i ].useobj maps/mp/gametypes_zm/_gameobjects::getownerteam() + " flag";
			i++;
		}
	}
	str = otherdata.size + ",";
	i = 0;
	while ( i < otherdata.size )
	{
		str += vectostr( otherdata[ i ].origin ) + "," + otherdata[ i ].text + ",";
		i++;
	}
	fprintfields( file, str );
	closefile( file );
	thisspawnid = ( level.spawngameid + "." ) + level.spawnid;
	if ( isDefined( self.thisspawnid ) )
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
}

drawspawndata()
{
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
}

vectostr( vec )
{
/#
	return int( vec[ 0 ] ) + "/" + int( vec[ 1 ] ) + "/" + int( vec[ 2 ] );
#/
}

strtovec( str )
{
/#
	parts = strtok( str, "/" );
	if ( parts.size != 3 )
	{
		return ( -1, -1, -1 );
	}
	return ( int( parts[ 0 ] ), int( parts[ 1 ] ), int( parts[ 2 ] ) );
#/
}

getspawnpoint_random( spawnpoints )
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < spawnpoints.size )
	{
		j = randomint( spawnpoints.size );
		spawnpoint = spawnpoints[ i ];
		spawnpoints[ i ] = spawnpoints[ j ];
		spawnpoints[ j ] = spawnpoint;
		i++;
	}
	return getspawnpoint_final( spawnpoints, 0 );
}

getallotherplayers()
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
		else player = level.players[ i ];
		if ( player.sessionstate != "playing" || player == self )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( level.customalivecheck ) )
			{
				if ( !( [[ level.customalivecheck ]]( player ) ) )
				{
					i++;
					continue;
				}
			}
			else
			{
				aliveplayers[ aliveplayers.size ] = player;
			}
		}
		i++;
	}
	return aliveplayers;
}

getallalliedandenemyplayers( obj )
{
	if ( level.teambased )
	{
/#
		assert( isDefined( level.teams[ self.team ] ) );
#/
		obj.allies = [];
		obj.enemies = [];
		i = 0;
		while ( i < level.players.size )
		{
			if ( !isDefined( level.players[ i ] ) )
			{
				i++;
				continue;
			}
			else player = level.players[ i ];
			if ( player.sessionstate != "playing" || player == self )
			{
				i++;
				continue;
			}
			else
			{
				if ( isDefined( level.customalivecheck ) )
				{
					if ( !( [[ level.customalivecheck ]]( player ) ) )
					{
						i++;
						continue;
					}
				}
				else if ( player.team == self.team )
				{
					obj.allies[ obj.allies.size ] = player;
					i++;
					continue;
				}
				else
				{
					obj.enemies[ obj.enemies.size ] = player;
				}
			}
			i++;
		}
	}
	else obj.allies = [];
	obj.enemies = level.activeplayers;
}

initweights( spawnpoints )
{
	i = 0;
	while ( i < spawnpoints.size )
	{
		spawnpoints[ i ].weight = 0;
		i++;
	}
/#
	while ( level.storespawndata || level.debugspawning )
	{
		i = 0;
		while ( i < spawnpoints.size )
		{
			spawnpoints[ i ].spawndata = [];
			spawnpoints[ i ].sightchecks = [];
			i++;
#/
		}
	}
}

spawnpointupdate_zm( spawnpoint )
{
	_a906 = level.teams;
	_k906 = getFirstArrayKey( _a906 );
	while ( isDefined( _k906 ) )
	{
		team = _a906[ _k906 ];
		spawnpoint.distsum[ team ] = 0;
		spawnpoint.enemydistsum[ team ] = 0;
		_k906 = getNextArrayKey( _a906, _k906 );
	}
	players = get_players();
	spawnpoint.numplayersatlastupdate = players.size;
	_a913 = players;
	_k913 = getFirstArrayKey( _a913 );
	while ( isDefined( _k913 ) )
	{
		player = _a913[ _k913 ];
		if ( !isDefined( player ) )
		{
		}
		else if ( player.sessionstate != "playing" )
		{
		}
		else if ( isDefined( level.customalivecheck ) )
		{
			if ( !( [[ level.customalivecheck ]]( player ) ) )
			{
			}
		}
		else
		{
			dist = distance( spawnpoint.origin, player.origin );
			spawnpoint.distsum[ player.team ] += dist;
			_a924 = level.teams;
			_k924 = getFirstArrayKey( _a924 );
			while ( isDefined( _k924 ) )
			{
				team = _a924[ _k924 ];
				if ( team != player.team )
				{
					spawnpoint.enemydistsum[ team ] += dist;
				}
				_k924 = getNextArrayKey( _a924, _k924 );
			}
		}
		_k913 = getNextArrayKey( _a913, _k913 );
	}
}

getspawnpoint_nearteam( spawnpoints, favoredspawnpoints, forceallydistanceweight, forceenemydistanceweight )
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
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
	if ( isDefined( forceallydistanceweight ) )
	{
		allieddistanceweight = forceallydistanceweight;
	}
	enemydistanceweight = 1;
	if ( isDefined( forceenemydistanceweight ) )
	{
		enemydistanceweight = forceenemydistanceweight;
	}
	myteam = self.team;
	i = 0;
	while ( i < spawnpoints.size )
	{
		spawnpoint = spawnpoints[ i ];
		spawnpointupdate_zm( spawnpoint );
		if ( !isDefined( spawnpoint.numplayersatlastupdate ) )
		{
			spawnpoint.numplayersatlastupdate = 0;
		}
		if ( spawnpoint.numplayersatlastupdate > 0 )
		{
			allydistsum = spawnpoint.distsum[ myteam ];
			enemydistsum = spawnpoint.enemydistsum[ myteam ];
			spawnpoint.weight = ( ( enemydistanceweight * enemydistsum ) - ( allieddistanceweight * allydistsum ) ) / spawnpoint.numplayersatlastupdate;
/#
			if ( level.storespawndata || level.debugspawning )
			{
				spawnpoint.spawndata[ spawnpoint.spawndata.size ] = "Base weight: " + int( spawnpoint.weight ) + " = (" + enemydistanceweight + "*" + int( enemydistsum ) + " - " + allieddistanceweight + "*" + int( allydistsum ) + ") / " + spawnpoint.numplayersatlastupdate;
#/
			}
			i++;
			continue;
		}
		else
		{
			spawnpoint.weight = 0;
/#
			if ( level.storespawndata || level.debugspawning )
			{
				spawnpoint.spawndata[ spawnpoint.spawndata.size ] = "Base weight: 0";
#/
			}
		}
		i++;
	}
	while ( isDefined( favoredspawnpoints ) )
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
			else
			{
				favoredspawnpoints[ i ].weight = k_favored_spawn_point_bonus;
			}
			i++;
		}
	}
	avoidsamespawn( spawnpoints );
	avoidspawnreuse( spawnpoints, 1 );
	avoidweapondamage( spawnpoints );
	avoidvisibleenemies( spawnpoints, 1 );
	result = getspawnpoint_final( spawnpoints );
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
	return result;
}

getspawnpoint_dm( spawnpoints )
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
	while ( aliveplayers.size > 0 )
	{
		i = 0;
		while ( i < spawnpoints.size )
		{
			totaldistfromideal = 0;
			nearbybadamount = 0;
			j = 0;
			while ( j < aliveplayers.size )
			{
				dist = distance( spawnpoints[ i ].origin, aliveplayers[ j ].origin );
				if ( dist < baddist )
				{
					nearbybadamount += ( baddist - dist ) / baddist;
				}
				distfromideal = abs( dist - idealdist );
				totaldistfromideal += distfromideal;
				j++;
			}
			avgdistfromideal = totaldistfromideal / aliveplayers.size;
			welldistancedamount = ( idealdist - avgdistfromideal ) / idealdist;
			spawnpoints[ i ].weight = ( welldistancedamount - ( nearbybadamount * 2 ) ) + randomfloat( 0,2 );
			i++;
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
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
	spawnlogic_begin();
	initweights( spawnpoints );
	aliveplayers = getallotherplayers();
	if ( !isDefined( idealdist ) )
	{
		idealdist = 1600;
	}
	if ( !isDefined( idealdistteam ) )
	{
		idealdistteam = 1200;
	}
	if ( !isDefined( baddist ) )
	{
		baddist = 1200;
	}
	if ( !isDefined( baddistteam ) )
	{
		baddistteam = 600;
	}
	myteam = self.team;
	while ( aliveplayers.size > 0 )
	{
		i = 0;
		while ( i < spawnpoints.size )
		{
			totaldistfromideal = 0;
			nearbybadamount = 0;
			j = 0;
			while ( j < aliveplayers.size )
			{
				dist = distance( spawnpoints[ i ].origin, aliveplayers[ j ].origin );
				distfromideal = 0;
				if ( aliveplayers[ j ].team == myteam )
				{
					if ( dist < baddistteam )
					{
						nearbybadamount += ( baddistteam - dist ) / baddistteam;
					}
					distfromideal = abs( dist - idealdistteam );
				}
				else
				{
					if ( dist < baddist )
					{
						nearbybadamount += ( baddist - dist ) / baddist;
					}
					distfromideal = abs( dist - idealdist );
				}
				totaldistfromideal += distfromideal;
				j++;
			}
			avgdistfromideal = totaldistfromideal / aliveplayers.size;
			welldistancedamount = ( idealdist - avgdistfromideal ) / idealdist;
			spawnpoints[ i ].weight = ( welldistancedamount - ( nearbybadamount * 2 ) ) + randomfloat( 0,2 );
			i++;
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
	level.storespawndata = getDvarInt( "scr_recordspawndata" );
	level.debugspawning = getDvarInt( "scr_spawnpointdebug" ) > 0;
#/
}

init()
{
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
	level.spawnlogic_deaths = [];
	level.spawnlogic_spawnkills = [];
	level.players = [];
	level.grenades = [];
	level.pipebombs = [];
	level.spawnmins = ( -1, -1, -1 );
	level.spawnmaxs = ( -1, -1, -1 );
	level.spawnminsmaxsprimed = 0;
	while ( isDefined( level.safespawns ) )
	{
		i = 0;
		while ( i < level.safespawns.size )
		{
			level.safespawns[ i ] spawnpointinit();
			i++;
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
}

watchspawnprofile()
{
/#
	while ( 1 )
	{
		while ( 1 )
		{
			if ( getDvarInt( "scr_spawnprofile" ) > 0 )
			{
				break;
			}
			else
			{
				wait 0,05;
			}
		}
		thread spawnprofile();
		while ( 1 )
		{
			if ( getDvarInt( "scr_spawnprofile" ) <= 0 )
			{
				break;
			}
			else
			{
				wait 0,05;
			}
		}
		level notify( "stop_spawn_profile" );
#/
	}
}

spawnprofile()
{
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
		wait 0,05;
#/
	}
}

spawngraphcheck()
{
/#
	while ( 1 )
	{
		while ( getDvarInt( #"C25B6B47" ) < 1 )
		{
			wait 3;
		}
		thread spawngraph();
		return;
#/
	}
}

spawngraph()
{
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
}

drawspawngraph( fakespawnpoints, w, h, weightscale )
{
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
}

setupspawngraphpoint( s1, weightscale )
{
/#
	s1.visible = 1;
	if ( s1.weight < ( -1000 / weightscale ) )
	{
		s1.visible = 0;
#/
	}
}

spawngraphline( s1, s2, weightscale )
{
/#
	if ( !s1.visible || !s2.visible )
	{
		return;
	}
	p1 = s1.origin + ( 0, 0, ( s1.weight * weightscale ) + 100 );
	p2 = s2.origin + ( 0, 0, ( s2.weight * weightscale ) + 100 );
	line( p1, p2, ( -1, -1, -1 ) );
#/
}

loopbotspawns()
{
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
}

allowspawndatareading()
{
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
}

showdeathsdebug()
{
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
}

updatedeathinfodebug()
{
	while ( 1 )
	{
		while ( getDvar( "scr_spawnpointdebug" ) == "0" )
		{
			wait 3;
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
}

profiledebug()
{
	while ( 1 )
	{
		while ( getDvar( #"6A99E750" ) != "1" )
		{
			wait 3;
		}
		i = 0;
		while ( i < level.spawnpoints.size )
		{
			level.spawnpoints[ i ].weight = randomint( 10000 );
			i++;
		}
		if ( level.players.size > 0 )
		{
			level.players[ randomint( level.players.size ) ] getspawnpoint_nearteam( level.spawnpoints );
		}
		wait 0,05;
	}
}

debugnearbyplayers( players, origin )
{
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
}

deathoccured( dier, killer )
{
}

checkforsimilardeaths( deathinfo )
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
			else dist = distance( level.spawnlogic_deaths[ i ].killorg, deathinfo.killorg );
			if ( dist > 200 )
			{
				i++;
				continue;
			}
			else
			{
				level.spawnlogic_deaths[ i ].remove = 1;
			}
		}
		i++;
	}
}

updatedeathinfo()
{
	time = getTime();
	i = 0;
	while ( i < level.spawnlogic_deaths.size )
	{
		deathinfo = level.spawnlogic_deaths[ i ];
		if ( ( time - deathinfo.time ) > 90000 && isDefined( deathinfo.killer ) && isalive( deathinfo.killer ) || !isDefined( level.teams[ deathinfo.killer.team ] ) && distance( deathinfo.killer.origin, deathinfo.killorg ) > 400 )
		{
			level.spawnlogic_deaths[ i ].remove = 1;
		}
		i++;
	}
	oldarray = level.spawnlogic_deaths;
	level.spawnlogic_deaths = [];
	start = 0;
	if ( ( oldarray.size - 1024 ) > 0 )
	{
		start = oldarray.size - 1024;
	}
	i = start;
	while ( i < oldarray.size )
	{
		if ( !isDefined( oldarray[ i ].remove ) )
		{
			level.spawnlogic_deaths[ level.spawnlogic_deaths.size ] = oldarray[ i ];
		}
		i++;
	}
}

ispointvulnerable( playerorigin )
{
	pos = self.origin + level.bettymodelcenteroffset;
	playerpos = playerorigin + vectorScale( ( -1, -1, -1 ), 32 );
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

avoidweapondamage( spawnpoints )
{
	if ( getDvar( #"0FB71FB7" ) == "0" )
	{
		return;
	}
	weapondamagepenalty = 100000;
	if ( getDvar( #"76B8F046" ) != "" && getDvar( #"76B8F046" ) != "0" )
	{
		weapondamagepenalty = getDvarFloat( #"76B8F046" );
	}
	mingrenadedistsquared = 62500;
	i = 0;
	while ( i < spawnpoints.size )
	{
		j = 0;
		while ( j < level.grenades.size )
		{
			if ( !isDefined( level.grenades[ j ] ) )
			{
				j++;
				continue;
			}
			else
			{
				if ( distancesquared( spawnpoints[ i ].origin, level.grenades[ j ].origin ) < mingrenadedistsquared )
				{
					spawnpoints[ i ].weight -= weapondamagepenalty;
/#
					if ( level.storespawndata || level.debugspawning )
					{
						spawnpoints[ i ].spawndata[ spawnpoints[ i ].spawndata.size ] = "Was near grenade: -" + int( weapondamagepenalty );
#/
					}
				}
			}
			j++;
		}
		i++;
	}
}

spawnperframeupdate()
{
	spawnpointindex = 0;
	while ( 1 )
	{
		wait 0,05;
		if ( !isDefined( level.spawnpoints ) )
		{
			return;
		}
		spawnpointindex = ( spawnpointindex + 1 ) % level.spawnpoints.size;
		spawnpoint = level.spawnpoints[ spawnpointindex ];
		spawnpointupdate( spawnpoint );
	}
}

getnonteamsum( skip_team, sums )
{
	value = 0;
	_a1986 = level.teams;
	_k1986 = getFirstArrayKey( _a1986 );
	while ( isDefined( _k1986 ) )
	{
		team = _a1986[ _k1986 ];
		if ( team == skip_team )
		{
		}
		else
		{
			value += sums[ team ];
		}
		_k1986 = getNextArrayKey( _a1986, _k1986 );
	}
	return value;
}

getnonteammindist( skip_team, mindists )
{
	dist = 9999999;
	_a2000 = level.teams;
	_k2000 = getFirstArrayKey( _a2000 );
	while ( isDefined( _k2000 ) )
	{
		team = _a2000[ _k2000 ];
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
		_k2000 = getNextArrayKey( _a2000, _k2000 );
	}
	return dist;
}

spawnpointupdate( spawnpoint )
{
	if ( level.teambased )
	{
		sights = [];
		_a2018 = level.teams;
		_k2018 = getFirstArrayKey( _a2018 );
		while ( isDefined( _k2018 ) )
		{
			team = _a2018[ _k2018 ];
			spawnpoint.enemysights[ team ] = 0;
			sights[ team ] = 0;
			spawnpoint.nearbyplayers[ team ] = [];
			_k2018 = getNextArrayKey( _a2018, _k2018 );
		}
	}
	else spawnpoint.enemysights = 0;
	spawnpoint.nearbyplayers[ "all" ] = [];
	spawnpointdir = spawnpoint.forward;
	debug = 0;
/#
	debug = getDvarInt( "scr_spawnpointdebug" ) > 0;
#/
	mindist = [];
	distsum = [];
	if ( !level.teambased )
	{
		mindist[ "all" ] = 9999999;
	}
	_a2047 = level.teams;
	_k2047 = getFirstArrayKey( _a2047 );
	while ( isDefined( _k2047 ) )
	{
		team = _a2047[ _k2047 ];
		spawnpoint.distsum[ team ] = 0;
		spawnpoint.enemydistsum[ team ] = 0;
		spawnpoint.minenemydist[ team ] = 9999999;
		mindist[ team ] = 9999999;
		_k2047 = getNextArrayKey( _a2047, _k2047 );
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
		else diff = player.origin - spawnpoint.origin;
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
		else
		{
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
/#
				if ( debug )
				{
					line( player.origin + vectorScale( ( -1, -1, -1 ), 50 ), spawnpoint.sighttracepoint, ( 0,5, 1, 0,5 ) );
#/
				}
			}
		}
		i++;
	}
	if ( level.teambased )
	{
		_a2128 = level.teams;
		_k2128 = getFirstArrayKey( _a2128 );
		while ( isDefined( _k2128 ) )
		{
			team = _a2128[ _k2128 ];
			spawnpoint.enemysights[ team ] = getnonteamsum( team, sights );
			spawnpoint.minenemydist[ team ] = getnonteammindist( team, mindist );
			spawnpoint.distsum[ team ] = distsum[ team ];
			spawnpoint.enemydistsum[ team ] = getnonteamsum( team, distsum );
			_k2128 = getNextArrayKey( _a2128, _k2128 );
		}
	}
	else spawnpoint.distsum[ "all" ] = distsum[ "all" ];
	spawnpoint.enemydistsum[ "all" ] = distsum[ "all" ];
	spawnpoint.minenemydist[ "all" ] = mindist[ "all" ];
}

getlospenalty()
{
	if ( getDvar( #"CACDB8AA" ) != "" && getDvar( #"CACDB8AA" ) != "0" )
	{
		return getDvarFloat( #"CACDB8AA" );
	}
	return 100000;
}

lastminutesighttraces( spawnpoint )
{
	if ( !isDefined( spawnpoint.nearbyplayers ) )
	{
		return 0;
	}
	closest = undefined;
	closestdistsq = undefined;
	secondclosest = undefined;
	secondclosestdistsq = undefined;
	_a2162 = spawnpoint.nearbyplayers;
	_k2162 = getFirstArrayKey( _a2162 );
	while ( isDefined( _k2162 ) )
	{
		team = _a2162[ _k2162 ];
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
				else if ( player.sessionstate != "playing" )
				{
					i++;
					continue;
				}
				else if ( player == self )
				{
					i++;
					continue;
				}
				else distsq = distancesquared( spawnpoint.origin, player.origin );
				if ( !isDefined( closest ) || distsq < closestdistsq )
				{
					secondclosest = closest;
					secondclosestdistsq = closestdistsq;
					closest = player;
					closestdistsq = distsq;
					i++;
					continue;
				}
				else
				{
					if ( !isDefined( secondclosest ) || distsq < secondclosestdistsq )
					{
						secondclosest = player;
						secondclosestdistsq = distsq;
					}
				}
				i++;
			}
		}
		_k2162 = getNextArrayKey( _a2162, _k2162 );
	}
	if ( isDefined( closest ) )
	{
		if ( bullettracepassed( closest.origin + vectorScale( ( -1, -1, -1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined ) )
		{
			return 1;
		}
	}
	if ( isDefined( secondclosest ) )
	{
		if ( bullettracepassed( secondclosest.origin + vectorScale( ( -1, -1, -1 ), 50 ), spawnpoint.sighttracepoint, 0, undefined ) )
		{
			return 1;
		}
	}
	return 0;
}

avoidvisibleenemies( spawnpoints, teambased )
{
	if ( getDvar( #"0FB71FB7" ) == "0" )
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
			else
			{
				penalty = lospenalty * spawnpoints[ i ].enemysights[ self.team ];
				spawnpoints[ i ].weight -= penalty;
/#
				if ( level.storespawndata || level.debugspawning )
				{
					index = spawnpoints[ i ].sightchecks.size;
					spawnpoints[ i ].sightchecks[ index ] = spawnstruct();
					spawnpoints[ i ].sightchecks[ index ].penalty = penalty;
#/
				}
			}
			i++;
		}
	}
	else i = 0;
	while ( i < spawnpoints.size )
	{
		if ( !isDefined( spawnpoints[ i ].enemysights ) )
		{
			i++;
			continue;
		}
		else
		{
			penalty = lospenalty * spawnpoints[ i ].enemysights;
			spawnpoints[ i ].weight -= penalty;
/#
			if ( level.storespawndata || level.debugspawning )
			{
				index = spawnpoints[ i ].sightchecks.size;
				spawnpoints[ i ].sightchecks[ index ] = spawnstruct();
				spawnpoints[ i ].sightchecks[ index ].penalty = penalty;
#/
			}
		}
		i++;
	}
	mindistteam = "all";
	avoidweight = getDvarFloat( "scr_spawn_enemyavoidweight" );
	while ( avoidweight != 0 )
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
		i = 0;
		while ( i < spawnpoints.size )
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
/#
					if ( level.storespawndata || level.debugspawning )
					{
						spawnpoints[ i ].spawndata[ spawnpoints[ i ].spawndata.size ] = "Nearest enemy at " + int( spawnpoints[ i ].minenemydist[ mindistteam ] ) + " units: -" + int( penalty );
#/
					}
				}
			}
			i++;
		}
	}
}

avoidspawnreuse( spawnpoints, teambased )
{
	if ( getDvar( #"0FB71FB7" ) == "0" )
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
		if ( isDefined( spawnpoint.lastspawnedplayer ) || !isDefined( spawnpoint.lastspawntime ) && !isalive( spawnpoint.lastspawnedplayer ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( spawnpoint.lastspawnedplayer == self )
			{
				i++;
				continue;
			}
			else if ( teambased && spawnpoint.lastspawnedplayer.team == self.team )
			{
				i++;
				continue;
			}
			else
			{
				timepassed = time - spawnpoint.lastspawntime;
				if ( timepassed < maxtime )
				{
					distsq = distancesquared( spawnpoint.lastspawnedplayer.origin, spawnpoint.origin );
					if ( distsq < maxdistsq )
					{
						worsen = ( 5000 * ( 1 - ( distsq / maxdistsq ) ) ) * ( 1 - ( timepassed / maxtime ) );
						spawnpoint.weight -= worsen;
/#
						if ( level.storespawndata || level.debugspawning )
						{
							spawnpoint.spawndata[ spawnpoint.spawndata.size ] = "Was recently used: -" + worsen;
#/
						}
					}
					else
					{
						spawnpoint.lastspawnedplayer = undefined;
					}
					i++;
					continue;
				}
				else
				{
					spawnpoint.lastspawnedplayer = undefined;
				}
			}
		}
		i++;
	}
}

avoidsamespawn( spawnpoints )
{
	if ( getDvar( #"0FB71FB7" ) == "0" )
	{
		return;
	}
	if ( !isDefined( self.lastspawnpoint ) )
	{
		return;
	}
	i = 0;
	while ( i < spawnpoints.size )
	{
		if ( spawnpoints[ i ] == self.lastspawnpoint )
		{
			spawnpoints[ i ].weight -= 50000;
/#
			if ( level.storespawndata || level.debugspawning )
			{
				spawnpoints[ i ].spawndata[ spawnpoints[ i ].spawndata.size ] = "Was last spawnpoint: -50000";
#/
			}
			return;
		}
		else
		{
			i++;
		}
	}
}

getrandomintermissionpoint()
{
	spawnpoints = getentarray( "mp_global_intermission", "classname" );
	if ( !spawnpoints.size )
	{
		spawnpoints = getentarray( "info_player_start", "classname" );
	}
/#
	assert( spawnpoints.size );
#/
	spawnpoint = maps/mp/gametypes_zm/_spawnlogic::getspawnpoint_random( spawnpoints );
	return spawnpoint;
}
