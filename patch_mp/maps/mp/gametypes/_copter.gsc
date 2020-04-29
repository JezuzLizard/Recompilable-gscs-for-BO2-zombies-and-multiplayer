
init()
{
	level.coptermodel = "vehicle_cobra_helicopter_fly";
	precachemodel( level.coptermodel );
	level.copter_maxaccel = 200;
	level.copter_maxvel = 700;
	level.copter_rotspeed = 90;
	level.copter_accellookahead = 2;
	level.coptercenteroffset = vectorScale( ( 0, 0, -1 ), 72 );
	level.coptertargetoffset = vectorScale( ( 0, 0, -1 ), 45 );
	level.copterexplosion = loadfx( "explosions/fx_default_explosion" );
	level.copterfinalexplosion = loadfx( "explosions/fx_large_vehicle_explosion" );
}

getabovebuildingslocation( location )
{
	trace = bullettrace( location + vectorScale( ( 0, 0, -1 ), 10000 ), location, 0, undefined );
	startorigin = trace[ "position" ] + vectorScale( ( 0, 0, -1 ), 514 );
	zpos = 0;
	maxxpos = 13;
	maxypos = 13;
	xpos = 0;
	while ( xpos < maxxpos )
	{
		ypos = 0;
		while ( ypos < maxypos )
		{
			thisstartorigin = startorigin + ( ( ( xpos / ( maxxpos - 1 ) ) - 0,5 ) * 1024, ( ( ypos / ( maxypos - 1 ) ) - 0,5 ) * 1024, 0 );
			thisorigin = bullettrace( thisstartorigin, thisstartorigin + vectorScale( ( 0, 0, -1 ), 10000 ), 0, undefined );
			zpos += thisorigin[ "position" ][ 2 ];
			ypos++;
		}
		xpos++;
	}
	zpos /= maxxpos * maxypos;
	zpos += 850;
	return ( location[ 0 ], location[ 1 ], zpos );
}

vectorangle( v1, v2 )
{
	dot = vectordot( v1, v2 );
	if ( dot >= 1 )
	{
		return 0;
	}
	else
	{
		if ( dot <= -1 )
		{
			return 180;
		}
	}
	return acos( dot );
}

vectortowardsothervector( v1, v2, angle )
{
	dot = vectordot( v1, v2 );
	if ( dot <= -1 )
	{
		return v1;
	}
	v3 = vectornormalize( v2 - vectorScale( v1, dot ) );
	return vectorScale( v1, cos( angle ) ) + vectorScale( v3, sin( angle ) );
}

veclength( v )
{
	return distance( ( 0, 0, -1 ), v );
}

createcopter( location, team, damagetrig )
{
	location = getabovebuildingslocation( location );
	scriptorigin = spawn( "script_origin", location );
	scriptorigin.angles = vectorToAngle( ( 0, 0, -1 ) );
	copter = spawn( "script_model", location );
	copter.angles = vectorToAngle( ( 0, 0, -1 ) );
	copter linkto( scriptorigin );
	scriptorigin.copter = copter;
	copter setmodel( level.coptermodel );
	copter playloopsound( "mp_copter_ambience" );
	damagetrig.origin = scriptorigin.origin;
	damagetrig thread mylinkto( scriptorigin );
	scriptorigin.damagetrig = damagetrig;
	scriptorigin.finaldest = location;
	scriptorigin.finalzdest = location[ 2 ];
	scriptorigin.desireddir = ( 0, 0, -1 );
	scriptorigin.desireddirentity = undefined;
	scriptorigin.desireddirentityoffset = ( 0, 0, -1 );
	scriptorigin.vel = ( 0, 0, -1 );
	scriptorigin.dontascend = 0;
	scriptorigin.health = 2000;
	if ( getDvar( #"A8262D2E" ) != "" )
	{
		scriptorigin.health = getDvarFloat( #"A8262D2E" );
	}
	scriptorigin.team = team;
	scriptorigin thread copterai();
	scriptorigin thread copterdamage( damagetrig );
	return scriptorigin;
}

makecopterpassive()
{
	self.damagetrig notify( "unlink" );
	self.damagetrig = undefined;
	self notify( "passive" );
	self.desireddirentity = undefined;
	self.desireddir = undefined;
}

makecopteractive( damagetrig )
{
	damagetrig.origin = self.origin;
	damagetrig thread mylinkto( self );
	self.damagetrig = damagetrig;
	self thread copterai();
	self thread copterdamage( damagetrig );
}

mylinkto( obj )
{
	self endon( "unlink" );
	while ( 1 )
	{
		self.angles = obj.angles;
		self.origin = obj.origin;
		wait 0,1;
	}
}

setcopterdefensearea( areaent )
{
	self.areaent = areaent;
	self.areadescentpoints = [];
	if ( isDefined( areaent.target ) )
	{
		self.areadescentpoints = getentarray( areaent.target, "targetname" );
	}
	i = 0;
	while ( i < self.areadescentpoints.size )
	{
		self.areadescentpoints[ i ].targetent = getent( self.areadescentpoints[ i ].target, "targetname" );
		i++;
	}
}

copterai()
{
	self thread coptermove();
	self thread coptershoot();
	self endon( "death" );
	self endon( "passive" );
	flying = 1;
	descendingent = undefined;
	reacheddescendingent = 0;
	returningtoarea = 0;
	while ( 1 )
	{
		while ( !isDefined( self.areaent ) )
		{
			wait 1;
		}
		players = level.players;
		enemytargets = [];
		while ( self.team != "neutral" )
		{
			i = 0;
			while ( i < players.size )
			{
				if ( isalive( players[ i ] ) && isDefined( players[ i ].pers[ "team" ] ) && players[ i ].pers[ "team" ] != self.team && !isDefined( players[ i ].usingobj ) )
				{
					playerorigin = players[ i ].origin;
					playerorigin = ( playerorigin[ 0 ], playerorigin[ 1 ], self.areaent.origin[ 2 ] );
					if ( distance( playerorigin, self.areaent.origin ) < self.areaent.radius )
					{
						enemytargets[ enemytargets.size ] = players[ i ];
					}
				}
				i++;
			}
		}
		insidetargets = [];
		outsidetargets = [];
		skyheight = bullettrace( self.origin, self.origin + vectorScale( ( 0, 0, -1 ), 10000 ), 0, undefined )[ "position" ][ 2 ] - 10;
		besttarget = undefined;
		bestweight = 0;
		i = 0;
		while ( i < enemytargets.size )
		{
			inside = 0;
			trace = bullettrace( enemytargets[ i ].origin + vectorScale( ( 0, 0, -1 ), 10 ), enemytargets[ i ].origin + vectorScale( ( 0, 0, -1 ), 10000 ), 0, undefined );
			if ( trace[ "position" ][ 2 ] >= skyheight )
			{
				outsidetargets[ outsidetargets.size ] = enemytargets[ i ];
				i++;
				continue;
			}
			else
			{
				insidetargets[ insidetargets.size ] = enemytargets[ i ];
			}
			i++;
		}
		gotopos = undefined;
		calcedgotopos = 0;
		olddescendingent = undefined;
		if ( flying )
		{
			if ( outsidetargets.size == 0 && insidetargets.size > 0 && self.areadescentpoints.size > 0 )
			{
				flying = 0;
				result = determinebestent( insidetargets, self.areadescentpoints, self.origin );
				descendingent = result[ "descendEnt" ];
				if ( isDefined( descendingent ) )
				{
					gotopos = result[ "position" ];
					break;
				}
				else
				{
					flying = 1;
				}
			}
		}
		else olddescendingent = descendingent;
		if ( insidetargets.size == 0 )
		{
			flying = 1;
		}
		else
		{
			if ( outsidetargets.size > 0 )
			{
				if ( !isDefined( descendingent ) )
				{
					flying = 1;
					break;
				}
				else
				{
					calcedgotopos = 1;
					gotopos = determinebestpos( insidetargets, descendingent, self.origin );
					if ( !isDefined( gotopos ) )
					{
						flying = 1;
					}
				}
			}
			if ( isDefined( descendingent ) )
			{
				if ( !calcedgotopos )
				{
					gotopos = determinebestpos( insidetargets, descendingent, self.origin );
				}
			}
			if ( !isDefined( gotopos ) )
			{
				result = determinebestent( insidetargets, self.areadescentpoints, self.origin );
				if ( isDefined( result[ "descendEnt" ] ) )
				{
					descendingent = result[ "descendEnt" ];
					gotopos = result[ "position" ];
					reacheddescendingent = 0;
					break;
				}
				else if ( isDefined( descendingent ) )
				{
					if ( isDefined( self.finaldest ) )
					{
						gotopos = self.finaldest;
					}
					else
					{
						gotopos = descendingent.origin;
					}
					break;
				}
				else
				{
					gotopos = undefined;
				}
			}
			if ( !isDefined( gotopos ) )
			{
				flying = 1;
			}
		}
		if ( flying )
		{
			desireddist = 2560;
			disttoarea = distance( ( self.origin[ 0 ], self.origin[ 1 ], self.areaent.origin[ 2 ] ), self.areaent.origin );
			if ( outsidetargets.size == 0 && disttoarea > ( self.areaent.radius + ( desireddist * 0,25 ) ) )
			{
				returningtoarea = 1;
			}
			else
			{
				if ( disttoarea < ( self.areaent.radius * 0,5 ) )
				{
					returningtoarea = 0;
				}
			}
			while ( outsidetargets.size == 0 && !returningtoarea )
			{
				while ( self.team != "neutral" )
				{
					i = 0;
					while ( i < players.size )
					{
						if ( isalive( players[ i ] ) && isDefined( players[ i ].pers[ "team" ] ) && players[ i ].pers[ "team" ] != self.team && !isDefined( players[ i ].usingobj ) )
						{
							playerorigin = players[ i ].origin;
							playerorigin = ( playerorigin[ 0 ], playerorigin[ 1 ], self.areaent.origin[ 2 ] );
							if ( distance( players[ i ].origin, self.areaent.origin ) > self.areaent.radius )
							{
								outsidetargets[ outsidetargets.size ] = players[ i ];
							}
						}
						i++;
					}
				}
			}
			best = undefined;
			bestdist = 0;
			i = 0;
			while ( i < outsidetargets.size )
			{
				dist = abs( distance( outsidetargets[ i ].origin, self.origin ) - desireddist );
				if ( !isDefined( best ) || dist < bestdist )
				{
					best = outsidetargets[ i ];
					bestdist = dist;
				}
				i++;
			}
			if ( isDefined( best ) )
			{
				attackpos = best.origin + level.coptertargetoffset;
				gotopos = determinebestattackpos( attackpos, self.origin, desireddist );
				self setcopterdest( gotopos, 0 );
				self.desireddir = vectornormalize( attackpos - gotopos );
				self.desireddirentity = best;
				self.desireddirentityoffset = level.coptertargetoffset;
				wait 1;
			}
			else
			{
				gotopos = getrandompos( self.areaent.origin, self.areaent.radius );
				self setcopterdest( gotopos, 0 );
				self.desireddir = undefined;
				self.desireddirentity = undefined;
				wait 1;
			}
			continue;
		}
		else if ( distance( self.origin, descendingent.origin ) < descendingent.radius )
		{
			reacheddescendingent = 1;
		}
		if ( isDefined( olddescendingent ) )
		{
			godirectly = olddescendingent == descendingent;
		}
		if ( godirectly )
		{
			godirectly = reacheddescendingent;
		}
		self.desireddir = vectornormalize( descendingent.targetent.origin - gotopos - level.coptercenteroffset );
		self.desireddirentity = descendingent.targetent;
		self.desireddirentityoffset = ( 0, 0, -1 );
		if ( gotopos != self.origin )
		{
			self setcopterdest( gotopos - level.coptercenteroffset, 1, godirectly );
			wait 0,3;
			continue;
		}
		else
		{
			wait 0,3;
		}
	}
}

determinebestpos( targets, descendent, startorigin )
{
	targetpos = descendent.targetent.origin;
	circleradius = distance( targetpos, descendent.origin );
	bestpoint = undefined;
	bestdist = 0;
	i = 0;
	while ( i < targets.size )
	{
		enemypos = targets[ i ].origin + level.coptertargetoffset;
		passed = bullettracepassed( enemypos, targetpos, 0, undefined );
		if ( passed )
		{
			dir = targetpos - enemypos;
			dir = ( dir[ 0 ], dir[ 1 ], 0 );
			isect = vectorScale( vectornormalize( dir ), circleradius ) + targetpos;
			isect = ( isect[ 0 ], isect[ 1 ], descendent.origin[ 2 ] );
			dist = distance( isect, descendent.origin );
			if ( dist <= descendent.radius )
			{
				dist = distance( isect, startorigin );
				if ( !isDefined( bestpoint ) || dist < bestdist )
				{
					bestdist = dist;
					bestpoint = isect;
				}
			}
		}
		i++;
	}
	return bestpoint;
}

determinebestent( targets, descendents, startorigin )
{
	result = [];
	bestpos = undefined;
	bestent = 0;
	bestdist = 0;
	i = 0;
	while ( i < descendents.size )
	{
		thispos = determinebestpos( targets, descendents[ i ], startorigin );
		if ( isDefined( thispos ) )
		{
			thisdist = distance( thispos, startorigin );
			if ( !isDefined( bestpos ) || thisdist < bestdist )
			{
				bestpos = thispos;
				bestent = i;
				bestdist = thisdist;
			}
		}
		i++;
	}
	if ( isDefined( bestpos ) )
	{
		result[ "descendEnt" ] = descendents[ bestent ];
		result[ "position" ] = bestpos;
		return result;
	}
	return result;
}

determinebestattackpos( targetpos, curpos, desireddist )
{
	targetposcopterheight = ( targetpos[ 0 ], targetpos[ 1 ], curpos[ 2 ] );
	attackdirx = curpos - targetposcopterheight;
	attackdirx = vectornormalize( attackdirx );
	attackdiry = ( 0 - attackdirx[ 1 ], attackdirx[ 0 ], 0 );
	bestpos = undefined;
	bestdist = 0;
	i = 0;
	while ( i < 8 )
	{
		theta = ( i / 8 ) * 360;
		thisdir = vectorScale( attackdirx, cos( theta ) ) + vectorScale( attackdiry, sin( theta ) );
		traceend = targetposcopterheight + vectorScale( thisdir, desireddist );
		losexists = bullettracepassed( targetpos, traceend, 0, undefined );
		if ( losexists )
		{
			thisdist = distance( traceend, curpos );
			if ( !isDefined( bestpos ) || thisdist < bestdist )
			{
				bestpos = traceend;
				bestdist = thisdist;
			}
		}
		i++;
	}
	gotopos = undefined;
	if ( isDefined( bestpos ) )
	{
		gotopos = bestpos;
	}
	else dist = distance( targetposcopterheight, curpos );
	if ( dist > desireddist )
	{
		gotopos = self.origin + vectorScale( vectornormalize( attackdirx ), 0 - dist - desireddist );
	}
	else
	{
		gotopos = self.origin;
	}
	return gotopos;
}

getrandompos( origin, radius )
{
	pos = origin + ( ( randomfloat( 2 ) - 1 ) * radius, ( randomfloat( 2 ) - 1 ) * radius, 0 );
	while ( distancesquared( pos, origin ) > ( radius * radius ) )
	{
		pos = origin + ( ( randomfloat( 2 ) - 1 ) * radius, ( randomfloat( 2 ) - 1 ) * radius, 0 );
	}
	return pos;
}

coptershoot()
{
	self endon( "death" );
	self endon( "passive" );
	costhreshold = cos( 10 );
	while ( 1 )
	{
		if ( isDefined( self.desireddirentity ) && isDefined( self.desireddirentity.origin ) )
		{
			mypos = self.origin + level.coptercenteroffset;
			enemypos = self.desireddirentity.origin + self.desireddirentityoffset;
			curdir = anglesToForward( self.angles );
			enemydirraw = enemypos - mypos;
			enemydir = vectornormalize( enemydirraw );
			if ( vectordot( curdir, enemydir ) > costhreshold )
			{
				canseetarget = bullettracepassed( mypos, enemypos, 0, undefined );
				if ( !canseetarget && isplayer( self.desireddirentity ) && isalive( self.desireddirentity ) )
				{
					canseetarget = bullettracepassed( mypos, self.desireddirentity geteye(), 0, undefined );
				}
				if ( canseetarget )
				{
					self playsound( "mp_copter_shoot" );
					numshots = 20;
					i = 0;
					while ( i < numshots )
					{
						mypos = self.origin + level.coptercenteroffset;
						dir = anglesToForward( self.angles );
						dir += ( ( randomfloat( 2 ) - 1 ) * 0,015, ( randomfloat( 2 ) - 1 ) * 0,015, ( randomfloat( 2 ) - 1 ) * 0,015 );
						dir = vectornormalize( dir );
						self mymagicbullet( mypos, dir );
						wait 0,075;
						i++;
					}
					wait 0,25;
				}
			}
		}
		wait 0,25;
	}
}

mymagicbullet( pos, dir )
{
	damage = 20;
	if ( getDvar( #"9E8F8CB7" ) != "" )
	{
		damage = getDvarInt( #"9E8F8CB7" );
	}
	trace = bullettrace( pos, pos + vectorScale( dir, 10000 ), 1, undefined );
	if ( isDefined( trace[ "entity" ] ) && isplayer( trace[ "entity" ] ) && isalive( trace[ "entity" ] ) )
	{
		trace[ "entity" ] thread [[ level.callbackplayerdamage ]]( self, self, damage, 0, "MOD_RIFLE_BULLET", "copter", self.origin, dir, "none", 0, 0 );
	}
}

setcopterdest( newlocation, descend, dontascend )
{
	self.finaldest = getabovebuildingslocation( newlocation );
	if ( isDefined( descend ) && descend )
	{
		self.finalzdest = newlocation[ 2 ];
	}
	else
	{
		self.finalzdest = self.finaldest[ 2 ];
	}
	self.intransit = 1;
	self.dontascend = 0;
	if ( isDefined( dontascend ) )
	{
		self.dontascend = dontascend;
	}
}

notifyarrived()
{
	wait 0,05;
	self notify( "arrived" );
}

coptermove()
{
	self endon( "death" );
	if ( isDefined( self.coptermoverunning ) )
	{
		return;
	}
	self.coptermoverunning = 1;
	self.intransit = 0;
	interval = 0,15;
	zinterp = 0,1;
	tiltamnt = 0;
	while ( 1 )
	{
		horizdistsquared = distancesquared( ( self.origin[ 0 ], self.origin[ 1 ], 0 ), ( self.finaldest[ 0 ], self.finaldest[ 1 ], 0 ) );
		donemoving = horizdistsquared < 100;
		neardest = horizdistsquared < 65536;
		self.intransit = 1;
		desiredz = 0;
		movinghorizontally = 1;
		movingvertically = 0;
		if ( self.dontascend )
		{
			movingvertically = 1;
		}
		else if ( !neardest )
		{
			desiredz = getabovebuildingslocation( self.origin )[ 2 ];
			movinghorizontally = abs( self.origin[ 2 ] - desiredz ) <= 256;
			movingvertically = !movinghorizontally;
		}
		else
		{
			movingvertically = 1;
		}
		if ( movinghorizontally )
		{
			if ( movingvertically )
			{
				thisdest = ( self.finaldest[ 0 ], self.finaldest[ 1 ], self.finalzdest );
			}
			else
			{
				thisdest = self.finaldest;
			}
		}
		else
		{
/#
			assert( movingvertically );
#/
			thisdest = ( self.origin[ 0 ], self.origin[ 1 ], desiredz );
		}
		movevec = thisdest - self.origin;
		idealaccel = vectorScale( thisdest - ( self.origin + vectorScale( self.vel, level.copter_accellookahead ) ), interval );
		vlen = veclength( idealaccel );
		if ( vlen > level.copter_maxaccel )
		{
			idealaccel = vectorScale( idealaccel, level.copter_maxaccel / vlen );
		}
		self.vel += idealaccel;
		vlen = veclength( self.vel );
		if ( vlen > level.copter_maxvel )
		{
			self.vel = vectorScale( self.vel, level.copter_maxvel / vlen );
		}
		thisdest = self.origin + vectorScale( self.vel, interval );
		self moveto( thisdest, interval * 0,999 );
		speed = veclength( self.vel );
		if ( isDefined( self.desireddirentity ) && isDefined( self.desireddirentity.origin ) )
		{
			self.destdir = vectornormalize( ( self.desireddirentity.origin + self.desireddirentityoffset ) - ( self.origin + level.coptercenteroffset ) );
		}
		else
		{
			if ( isDefined( self.desireddir ) )
			{
				self.destdir = self.desireddir;
				break;
			}
			else if ( movingvertically )
			{
				self.destdir = anglesToForward( self.angles );
				self.destdir = vectornormalize( ( self.destdir[ 0 ], self.destdir[ 1 ], 0 ) );
				break;
			}
			else
			{
				tiltamnt = speed / level.copter_maxvel;
				tiltamnt = ( tiltamnt - 0,1 ) / 0,9;
				if ( tiltamnt < 0 )
				{
					tiltamnt = 0;
				}
				self.destdir = movevec;
				self.destdir = vectornormalize( ( self.destdir[ 0 ], self.destdir[ 1 ], 0 ) );
				tiltamnt *= 1 - ( vectorangle( anglesToForward( self.angles ), self.destdir ) / 180 );
				self.destdir = vectornormalize( ( self.destdir[ 0 ], self.destdir[ 1 ], tiltamnt * -0,4 ) );
			}
		}
		newdir = self.destdir;
		if ( newdir[ 2 ] < -0,4 )
		{
			newdir = vectornormalize( ( newdir[ 0 ], newdir[ 1 ], -0,4 ) );
		}
		copterangles = self.angles;
		copterangles = combineangles( copterangles, vectorScale( ( 0, 0, -1 ), 90 ) );
		olddir = anglesToForward( copterangles );
		thisrotspeed = level.copter_rotspeed;
		olddir2d = vectornormalize( ( olddir[ 0 ], olddir[ 1 ], 0 ) );
		newdir2d = vectornormalize( ( newdir[ 0 ], newdir[ 1 ], 0 ) );
		angle = vectorangle( olddir2d, newdir2d );
		angle3d = vectorangle( olddir, newdir );
		if ( angle > 0,001 && thisrotspeed > 0,001 )
		{
			thisangle = thisrotspeed * interval;
			if ( thisangle > angle )
			{
				thisangle = angle;
			}
			newdir2d = vectortowardsothervector( olddir2d, newdir2d, thisangle );
			oldz = olddir[ 2 ] / veclength( ( olddir[ 0 ], olddir[ 1 ], 0 ) );
			newz = newdir[ 2 ] / veclength( ( newdir[ 0 ], newdir[ 1 ], 0 ) );
			interpz = oldz + ( ( newz - oldz ) * ( thisangle / angle ) );
			newdir = vectornormalize( ( newdir2d[ 0 ], newdir2d[ 1 ], interpz ) );
			copterangles = vectorToAngle( newdir );
			copterangles = combineangles( copterangles, vectorScale( ( 0, 0, -1 ), 90 ) );
			self rotateto( copterangles, interval * 0,999 );
		}
		else
		{
			if ( angle3d > 0,001 && thisrotspeed > 0,001 )
			{
				thisangle = thisrotspeed * interval;
				if ( thisangle > angle3d )
				{
					thisangle = angle3d;
				}
				newdir = vectortowardsothervector( olddir, newdir, thisangle );
				newdir = vectornormalize( newdir );
				copterangles = vectorToAngle( newdir );
				copterangles = combineangles( copterangles, vectorScale( ( 0, 0, -1 ), 90 ) );
				self rotateto( copterangles, interval * 0,999 );
			}
		}
		wait interval;
	}
}

copterdamage( damagetrig )
{
	self endon( "passive" );
	while ( 1 )
	{
		damagetrig waittill( "damage", amount, attacker );
		while ( isDefined( attacker ) && isplayer( attacker ) && isDefined( attacker.pers[ "team" ] ) && attacker.pers[ "team" ] == self.team )
		{
			continue;
		}
		self.health -= amount;
		if ( self.health <= 0 )
		{
			self thread copterdie();
			return;
		}
	}
}

copterdie()
{
	self endon( "passive" );
	self death_notify_wrapper();
	self.dead = 1;
	self thread copterexplodefx();
	interval = 0,2;
	rottime = 15;
	self rotateyaw( 360 + randomfloat( 360 ), rottime );
	self rotatepitch( 360 + randomfloat( 360 ), rottime );
	self rotateroll( 360 + randomfloat( 360 ), rottime );
	while ( 1 )
	{
		self.vel += vectorScale( vectorScale( ( 0, 0, -1 ), 200 ), interval );
		newpos = self.origin + vectorScale( self.vel, interval );
		pathclear = bullettracepassed( self.origin, newpos, 0, undefined );
		if ( !pathclear )
		{
			break;
		}
		else
		{
			self moveto( newpos, interval * 0,999 );
			wait interval;
		}
	}
	playfx( level.copterfinalexplosion, self.origin );
	fakeself = spawn( "script_origin", self.origin );
	fakeself playsound( "mp_copter_explosion" );
	self notify( "finaldeath" );
	deletecopter();
	wait 2;
	fakeself delete();
}

deletecopter()
{
	if ( isDefined( self.damagetrig ) )
	{
		self.damagetrig notify( "unlink" );
		self.damagetrig = undefined;
	}
	self.copter delete();
	self delete();
}

copterexplodefx()
{
	self endon( "finaldeath" );
	while ( 1 )
	{
		playfx( level.copterexplosion, self.origin );
		self playsound( "mp_copter_explosion" );
		wait ( 0,5 + randomfloat( 1 ) );
	}
}
