#include maps/mp/_utility;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;

append_missing_legs_suffix( animstate )
{
	if ( isDefined( self.has_legs ) && !self.has_legs && self hasanimstatefromasd( animstate + "_crawl" ) )
	{
		return animstate + "_crawl";
	}
	return animstate;
}

initanimtree( animscript )
{
	if ( animscript != "pain" && animscript != "death" )
	{
		self.a.special = "none";
	}
/#
	assert( isDefined( animscript ), "Animscript not specified in initAnimTree" );
#/
	self.a.script = animscript;
}

updateanimpose()
{
/#
	if ( self.a.movement != "stop" && self.a.movement != "walk" )
	{
		assert( self.a.movement == "run", "UpdateAnimPose " + self.a.pose + " " + self.a.movement );
	}
#/
	self.desired_anim_pose = undefined;
}

initialize( animscript )
{
	if ( isDefined( self.longdeathstarting ) )
	{
		if ( animscript != "pain" && animscript != "death" )
		{
			self dodamage( self.health + 100, self.origin );
		}
		if ( animscript != "pain" )
		{
			self.longdeathstarting = undefined;
			self notify( "kill_long_death" );
		}
	}
	if ( isDefined( self.a.mayonlydie ) && animscript != "death" )
	{
		self dodamage( self.health + 100, self.origin );
	}
	if ( isDefined( self.a.postscriptfunc ) )
	{
		scriptfunc = self.a.postscriptfunc;
		self.a.postscriptfunc = undefined;
		[[ scriptfunc ]]( animscript );
	}
	if ( animscript != "death" )
	{
		self.a.nodeath = 0;
	}
	self.isholdinggrenade = undefined;
	self.covernode = undefined;
	self.changingcoverpos = 0;
	self.a.scriptstarttime = getTime();
	self.a.atconcealmentnode = 0;
	if ( isDefined( self.node ) || self.node.type == "Conceal Crouch" && self.node.type == "Conceal Stand" )
	{
		self.a.atconcealmentnode = 1;
	}
	initanimtree( animscript );
	updateanimpose();
}

getnodeyawtoorigin( pos )
{
	if ( isDefined( self.node ) )
	{
		yaw = self.node.angles[ 1 ] - getyaw( pos );
	}
	else
	{
		yaw = self.angles[ 1 ] - getyaw( pos );
	}
	yaw = angleClamp180( yaw );
	return yaw;
}

getnodeyawtoenemy()
{
	pos = undefined;
	if ( isvalidenemy( self.enemy ) )
	{
		pos = self.enemy.origin;
	}
	else
	{
		if ( isDefined( self.node ) )
		{
			forward = anglesToForward( self.node.angles );
		}
		else
		{
			forward = anglesToForward( self.angles );
		}
		forward = vectorScale( forward, 150 );
		pos = self.origin + forward;
	}
	if ( isDefined( self.node ) )
	{
		yaw = self.node.angles[ 1 ] - getyaw( pos );
	}
	else
	{
		yaw = self.angles[ 1 ] - getyaw( pos );
	}
	yaw = angleClamp180( yaw );
	return yaw;
}

getcovernodeyawtoenemy()
{
	pos = undefined;
	if ( isvalidenemy( self.enemy ) )
	{
		pos = self.enemy.origin;
	}
	else
	{
		forward = anglesToForward( self.covernode.angles + self.animarray[ "angle_step_out" ][ self.a.cornermode ] );
		forward = vectorScale( forward, 150 );
		pos = self.origin + forward;
	}
	yaw = ( self.covernode.angles[ 1 ] + self.animarray[ "angle_step_out" ][ self.a.cornermode ] ) - getyaw( pos );
	yaw = angleClamp180( yaw );
	return yaw;
}

getyawtospot( spot )
{
	pos = spot;
	yaw = self.angles[ 1 ] - getyaw( pos );
	yaw = angleClamp180( yaw );
	return yaw;
}

getyawtoenemy()
{
	pos = undefined;
	if ( isvalidenemy( self.enemy ) )
	{
		pos = self.enemy.origin;
	}
	else
	{
		forward = anglesToForward( self.angles );
		forward = vectorScale( forward, 150 );
		pos = self.origin + forward;
	}
	yaw = self.angles[ 1 ] - getyaw( pos );
	yaw = angleClamp180( yaw );
	return yaw;
}

getyaw( org )
{
	angles = vectorToAngle( org - self.origin );
	return angles[ 1 ];
}

getyaw2d( org )
{
	angles = vectorToAngle( ( org[ 0 ], org[ 1 ], 0 ) - ( self.origin[ 0 ], self.origin[ 1 ], 0 ) );
	return angles[ 1 ];
}

absyawtoenemy()
{
/#
	assert( isvalidenemy( self.enemy ) );
#/
	yaw = self.angles[ 1 ] - getyaw( self.enemy.origin );
	yaw = angleClamp180( yaw );
	if ( yaw < 0 )
	{
		yaw = -1 * yaw;
	}
	return yaw;
}

absyawtoenemy2d()
{
/#
	assert( isvalidenemy( self.enemy ) );
#/
	yaw = self.angles[ 1 ] - getyaw2d( self.enemy.origin );
	yaw = angleClamp180( yaw );
	if ( yaw < 0 )
	{
		yaw = -1 * yaw;
	}
	return yaw;
}

absyawtoorigin( org )
{
	yaw = self.angles[ 1 ] - getyaw( org );
	yaw = angleClamp180( yaw );
	if ( yaw < 0 )
	{
		yaw = -1 * yaw;
	}
	return yaw;
}

absyawtoangles( angles )
{
	yaw = self.angles[ 1 ] - angles;
	yaw = angleClamp180( yaw );
	if ( yaw < 0 )
	{
		yaw = -1 * yaw;
	}
	return yaw;
}

getyawfromorigin( org, start )
{
	angles = vectorToAngle( org - start );
	return angles[ 1 ];
}

getyawtotag( tag, org )
{
	yaw = self gettagangles( tag )[ 1 ] - getyawfromorigin( org, self gettagorigin( tag ) );
	yaw = angleClamp180( yaw );
	return yaw;
}

getyawtoorigin( org )
{
	yaw = self.angles[ 1 ] - getyaw( org );
	yaw = angleClamp180( yaw );
	return yaw;
}

geteyeyawtoorigin( org )
{
	yaw = self gettagangles( "TAG_EYE" )[ 1 ] - getyaw( org );
	yaw = angleClamp180( yaw );
	return yaw;
}

getcovernodeyawtoorigin( org )
{
	yaw = ( self.covernode.angles[ 1 ] + self.animarray[ "angle_step_out" ][ self.a.cornermode ] ) - getyaw( org );
	yaw = angleClamp180( yaw );
	return yaw;
}

isstanceallowedwrapper( stance )
{
	if ( isDefined( self.covernode ) )
	{
		return self.covernode doesnodeallowstance( stance );
	}
	return self isstanceallowed( stance );
}

getclaimednode()
{
	mynode = self.node;
	if ( isDefined( mynode ) || self nearnode( mynode ) && isDefined( self.covernode ) && mynode == self.covernode )
	{
		return mynode;
	}
	return undefined;
}

getnodetype()
{
	mynode = getclaimednode();
	if ( isDefined( mynode ) )
	{
		return mynode.type;
	}
	return "none";
}

getnodedirection()
{
	mynode = getclaimednode();
	if ( isDefined( mynode ) )
	{
		return mynode.angles[ 1 ];
	}
	return self.desiredangle;
}

getnodeforward()
{
	mynode = getclaimednode();
	if ( isDefined( mynode ) )
	{
		return anglesToForward( mynode.angles );
	}
	return anglesToForward( self.angles );
}

getnodeorigin()
{
	mynode = getclaimednode();
	if ( isDefined( mynode ) )
	{
		return mynode.origin;
	}
	return self.origin;
}

safemod( a, b )
{
	result = int( a ) % b;
	result += b;
	return result % b;
}

angleclamp( angle )
{
	anglefrac = angle / 360;
	angle = ( anglefrac - floor( anglefrac ) ) * 360;
	return angle;
}

quadrantanimweights( yaw )
{
	forwardweight = ( 90 - abs( yaw ) ) / 90;
	leftweight = ( 90 - absangleclamp180( abs( yaw - 90 ) ) ) / 90;
	result[ "front" ] = 0;
	result[ "right" ] = 0;
	result[ "back" ] = 0;
	result[ "left" ] = 0;
	if ( isDefined( self.alwaysrunforward ) )
	{
/#
		assert( self.alwaysrunforward );
#/
		result[ "front" ] = 1;
		return result;
	}
	useleans = getDvarInt( "ai_useLeanRunAnimations" );
	if ( forwardweight > 0 )
	{
		result[ "front" ] = forwardweight;
		if ( leftweight > 0 )
		{
			result[ "left" ] = leftweight;
		}
		else
		{
			result[ "right" ] = -1 * leftweight;
		}
	}
	else if ( useleans )
	{
		result[ "back" ] = -1 * forwardweight;
		if ( leftweight > 0 )
		{
			result[ "left" ] = leftweight;
		}
		else
		{
			result[ "right" ] = -1 * leftweight;
		}
	}
	else backweight = -1 * forwardweight;
	if ( leftweight > backweight )
	{
		result[ "left" ] = 1;
	}
	else if ( leftweight < forwardweight )
	{
		result[ "right" ] = 1;
	}
	else
	{
		result[ "back" ] = 1;
	}
	return result;
}

getquadrant( angle )
{
	angle = angleclamp( angle );
	if ( angle < 45 || angle > 315 )
	{
		quadrant = "front";
	}
	else
	{
		if ( angle < 135 )
		{
			quadrant = "left";
		}
		else if ( angle < 225 )
		{
			quadrant = "back";
		}
		else
		{
			quadrant = "right";
		}
	}
	return quadrant;
}

isinset( input, set )
{
	i = set.size - 1;
	while ( i >= 0 )
	{
		if ( input == set[ i ] )
		{
			return 1;
		}
		i--;

	}
	return 0;
}

notifyaftertime( notifystring, killmestring, time )
{
	self endon( "death" );
	self endon( killmestring );
	wait time;
	self notify( notifystring );
}

drawstringtime( msg, org, color, timer )
{
/#
	maxtime = timer * 20;
	i = 0;
	while ( i < maxtime )
	{
		print3d( org, msg, color, 1, 1 );
		wait 0,05;
		i++;
#/
	}
}

showlastenemysightpos( string )
{
/#
	self notify( "got known enemy2" );
	self endon( "got known enemy2" );
	self endon( "death" );
	if ( !isvalidenemy( self.enemy ) )
	{
		return;
	}
	if ( self.enemy.team == "allies" )
	{
		color = ( 0,4, 0,7, 1 );
	}
	else
	{
		color = ( 1, 0,7, 0,4 );
	}
	while ( 1 )
	{
		wait 0,05;
		while ( !isDefined( self.lastenemysightpos ) )
		{
			continue;
		}
		print3d( self.lastenemysightpos, string, color, 1, 2,15 );
#/
	}
}

debugtimeout()
{
	wait 5;
	self notify( "timeout" );
}

debugposinternal( org, string, size )
{
/#
	self endon( "death" );
	self notify( "stop debug " + org );
	self endon( "stop debug " + org );
	ent = spawnstruct();
	ent thread debugtimeout();
	ent endon( "timeout" );
	if ( self.enemy.team == "allies" )
	{
		color = ( 0,4, 0,7, 1 );
	}
	else
	{
		color = ( 1, 0,7, 0,4 );
	}
	while ( 1 )
	{
		wait 0,05;
		print3d( org, string, color, 1, size );
#/
	}
}

debugpos( org, string )
{
	thread debugposinternal( org, string, 2,15 );
}

debugpossize( org, string, size )
{
	thread debugposinternal( org, string, size );
}

showdebugproc( frompoint, topoint, color, printtime )
{
/#
	self endon( "death" );
	timer = printtime * 20;
	i = 0;
	while ( i < timer )
	{
		wait 0,05;
		line( frompoint, topoint, color );
		i += 1;
#/
	}
}

showdebugline( frompoint, topoint, color, printtime )
{
	self thread showdebugproc( frompoint, topoint + vectorScale( ( 0, 0, 1 ), 5 ), color, printtime );
}

getnodeoffset( node )
{
	if ( isDefined( node.offset ) )
	{
		return node.offset;
	}
	cover_left_crouch_offset = ( -26, 0,4, 36 );
	cover_left_stand_offset = ( -32, 7, 63 );
	cover_right_crouch_offset = ( 43,5, 11, 36 );
	cover_right_stand_offset = ( 36, 8,3, 63 );
	cover_crouch_offset = ( 3,5, -12,5, 45 );
	cover_stand_offset = ( -3,7, -22, 63 );
	cornernode = 0;
	nodeoffset = ( 0, 0, 1 );
	right = anglesToRight( node.angles );
	forward = anglesToForward( node.angles );
	switch( node.type )
	{
		case "Cover Left":
		case "Cover Left Wide":
			if ( node isnodedontstand() && !node isnodedontcrouch() )
			{
				nodeoffset = calculatenodeoffset( right, forward, cover_left_crouch_offset );
			}
			else
			{
				nodeoffset = calculatenodeoffset( right, forward, cover_left_stand_offset );
			}
			break;
		case "Cover Right":
		case "Cover Right Wide":
			if ( node isnodedontstand() && !node isnodedontcrouch() )
			{
				nodeoffset = calculatenodeoffset( right, forward, cover_right_crouch_offset );
			}
			else
			{
				nodeoffset = calculatenodeoffset( right, forward, cover_right_stand_offset );
			}
			break;
		case "Conceal Stand":
		case "Cover Stand":
		case "Turret":
			nodeoffset = calculatenodeoffset( right, forward, cover_stand_offset );
			break;
		case "Conceal Crouch":
		case "Cover Crouch":
		case "Cover Crouch Window":
			nodeoffset = calculatenodeoffset( right, forward, cover_crouch_offset );
			break;
	}
	node.offset = nodeoffset;
	return node.offset;
}

calculatenodeoffset( right, forward, baseoffset )
{
	return vectorScale( right, baseoffset[ 0 ] ) + vectorScale( forward, baseoffset[ 1 ] ) + ( 0, 0, baseoffset[ 2 ] );
}

checkpitchvisibility( frompoint, topoint, atnode )
{
	pitch = angleClamp180( vectorToAngle( topoint - frompoint )[ 0 ] );
	if ( abs( pitch ) > 45 )
	{
		if ( isDefined( atnode ) && atnode.type != "Cover Crouch" && atnode.type != "Conceal Crouch" )
		{
			return 0;
		}
		if ( pitch > 45 || pitch < ( anim.covercrouchleanpitch - 45 ) )
		{
			return 0;
		}
	}
	return 1;
}

showlines( start, end, end2 )
{
/#
	for ( ;; )
	{
		line( start, end, ( 0, 0, 1 ), 1 );
		wait 0,05;
		line( start, end2, ( 0, 0, 1 ), 1 );
		wait 0,05;
#/
	}
}

anim_array( animarray, animweights )
{
	total_anims = animarray.size;
	idleanim = randomint( total_anims );
/#
	assert( total_anims );
#/
/#
	assert( animarray.size == animweights.size );
#/
	if ( total_anims == 1 )
	{
		return animarray[ 0 ];
	}
	weights = 0;
	total_weight = 0;
	i = 0;
	while ( i < total_anims )
	{
		total_weight += animweights[ i ];
		i++;
	}
	anim_play = randomfloat( total_weight );
	current_weight = 0;
	i = 0;
	while ( i < total_anims )
	{
		current_weight += animweights[ i ];
		if ( anim_play >= current_weight )
		{
			i++;
			continue;
		}
		else
		{
			idleanim = i;
			break;
		}
		i++;
	}
	return animarray[ idleanim ];
}

notforcedcover()
{
	if ( self.a.forced_cover != "none" )
	{
		return self.a.forced_cover == "Show";
	}
}

forcedcover( msg )
{
	if ( isDefined( self.a.forced_cover ) )
	{
		return self.a.forced_cover == msg;
	}
}

print3dtime( timer, org, msg, color, alpha, scale )
{
/#
	newtime = timer / 0,05;
	i = 0;
	while ( i < newtime )
	{
		print3d( org, msg, color, alpha, scale );
		wait 0,05;
		i++;
#/
	}
}

print3drise( org, msg, color, alpha, scale )
{
/#
	newtime = 100;
	up = 0;
	org = org;
	i = 0;
	while ( i < newtime )
	{
		up += 0,5;
		print3d( org + ( 0, 0, up ), msg, color, alpha, scale );
		wait 0,05;
		i++;
#/
	}
}

crossproduct( vec1, vec2 )
{
	return ( ( vec1[ 0 ] * vec2[ 1 ] ) - ( vec1[ 1 ] * vec2[ 0 ] ) ) > 0;
}

scriptchange()
{
	self.a.current_script = "none";
	self notify( anim.scriptchange );
}

delayedscriptchange()
{
	wait 0,05;
	scriptchange();
}

getgrenademodel()
{
	return getweaponmodel( self.grenadeweapon );
}

sawenemymove( timer )
{
	if ( !isDefined( timer ) )
	{
		timer = 500;
	}
	return ( getTime() - self.personalsighttime ) < timer;
}

canthrowgrenade()
{
	if ( !self.grenadeammo )
	{
		return 0;
	}
	if ( self.script_forcegrenade )
	{
		return 1;
	}
	return isplayer( self.enemy );
}

random_weight( array )
{
	idleanim = randomint( array.size );
	while ( array.size > 1 )
	{
		anim_weight = 0;
		i = 0;
		while ( i < array.size )
		{
			anim_weight += array[ i ];
			i++;
		}
		anim_play = randomfloat( anim_weight );
		anim_weight = 0;
		i = 0;
		while ( i < array.size )
		{
			anim_weight += array[ i ];
			if ( anim_play < anim_weight )
			{
				idleanim = i;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	return idleanim;
}

setfootstepeffect( name, fx )
{
/#
	assert( isDefined( name ), "Need to define the footstep surface type." );
#/
/#
	assert( isDefined( fx ), "Need to define the mud footstep effect." );
#/
	if ( !isDefined( anim.optionalstepeffects ) )
	{
		anim.optionalstepeffects = [];
	}
	anim.optionalstepeffects[ anim.optionalstepeffects.size ] = name;
	level._effect[ "step_" + name ] = fx;
	anim.optionalstepeffectfunction = ::maps/mp/animscripts/zm_shared::playfootstepeffect;
}

persistentdebugline( start, end )
{
/#
	self endon( "death" );
	level notify( "newdebugline" );
	level endon( "newdebugline" );
	for ( ;; )
	{
		line( start, end, ( 0,3, 1, 0 ), 1 );
		wait 0,05;
#/
	}
}

isnodedontstand()
{
	return ( self.spawnflags & 4 ) == 4;
}

isnodedontcrouch()
{
	return ( self.spawnflags & 8 ) == 8;
}

doesnodeallowstance( stance )
{
	if ( stance == "stand" )
	{
		return !self isnodedontstand();
	}
	else
	{
/#
		assert( stance == "crouch" );
#/
		return !self isnodedontcrouch();
	}
}

animarray( animname )
{
/#
	assert( isDefined( self.a.array ) );
#/
/#
	if ( !isDefined( self.a.array[ animname ] ) )
	{
		dumpanimarray();
		assert( isDefined( self.a.array[ animname ] ), "self.a.array[ "" + animname + "" ] is undefined" );
#/
	}
	return self.a.array[ animname ];
}

animarrayanyexist( animname )
{
/#
	assert( isDefined( self.a.array ) );
#/
/#
	if ( !isDefined( self.a.array[ animname ] ) )
	{
		dumpanimarray();
		assert( isDefined( self.a.array[ animname ] ), "self.a.array[ "" + animname + "" ] is undefined" );
#/
	}
	return self.a.array[ animname ].size > 0;
}

animarraypickrandom( animname )
{
/#
	assert( isDefined( self.a.array ) );
#/
/#
	if ( !isDefined( self.a.array[ animname ] ) )
	{
		dumpanimarray();
		assert( isDefined( self.a.array[ animname ] ), "self.a.array[ "" + animname + "" ] is undefined" );
#/
	}
/#
	assert( self.a.array[ animname ].size > 0 );
#/
	if ( self.a.array[ animname ].size > 1 )
	{
		index = randomint( self.a.array[ animname ].size );
	}
	else
	{
		index = 0;
	}
	return self.a.array[ animname ][ index ];
}

dumpanimarray()
{
/#
	println( "self.a.array:" );
	keys = getarraykeys( self.a.array );
	i = 0;
	while ( i < keys.size )
	{
		if ( isarray( self.a.array[ keys[ i ] ] ) )
		{
			println( " array[ "" + keys[ i ] + "" ] = {array of size " + self.a.array[ keys[ i ] ].size + "}" );
			i++;
			continue;
		}
		else
		{
			println( " array[ "" + keys[ i ] + "" ] = ", self.a.array[ keys[ i ] ] );
		}
		i++;
#/
	}
}

getanimendpos( theanim )
{
	movedelta = getmovedelta( theanim, 0, 1 );
	return self localtoworldcoords( movedelta );
}

isvalidenemy( enemy )
{
	if ( !isDefined( enemy ) )
	{
		return 0;
	}
	return 1;
}

damagelocationisany( a, b, c, d, e, f, g, h, i, j, k, ovr )
{
	if ( !isDefined( a ) )
	{
		return 0;
	}
	if ( self.damagelocation == a )
	{
		return 1;
	}
	if ( !isDefined( b ) )
	{
		return 0;
	}
	if ( self.damagelocation == b )
	{
		return 1;
	}
	if ( !isDefined( c ) )
	{
		return 0;
	}
	if ( self.damagelocation == c )
	{
		return 1;
	}
	if ( !isDefined( d ) )
	{
		return 0;
	}
	if ( self.damagelocation == d )
	{
		return 1;
	}
	if ( !isDefined( e ) )
	{
		return 0;
	}
	if ( self.damagelocation == e )
	{
		return 1;
	}
	if ( !isDefined( f ) )
	{
		return 0;
	}
	if ( self.damagelocation == f )
	{
		return 1;
	}
	if ( !isDefined( g ) )
	{
		return 0;
	}
	if ( self.damagelocation == g )
	{
		return 1;
	}
	if ( !isDefined( h ) )
	{
		return 0;
	}
	if ( self.damagelocation == h )
	{
		return 1;
	}
	if ( !isDefined( i ) )
	{
		return 0;
	}
	if ( self.damagelocation == i )
	{
		return 1;
	}
	if ( !isDefined( j ) )
	{
		return 0;
	}
	if ( self.damagelocation == j )
	{
		return 1;
	}
	if ( !isDefined( k ) )
	{
		return 0;
	}
	if ( self.damagelocation == k )
	{
		return 1;
	}
/#
	assert( !isDefined( ovr ) );
#/
	return 0;
}

ragdolldeath( moveanim )
{
	self endon( "killanimscript" );
	lastorg = self.origin;
	movevec = ( 0, 0, 1 );
	for ( ;; )
	{
		wait 0,05;
		force = distance( self.origin, lastorg );
		lastorg = self.origin;
		if ( self.health == 1 )
		{
			self.a.nodeath = 1;
			self startragdoll();
			wait 0,05;
			physicsexplosionsphere( lastorg, 600, 0, force * 0,1 );
			self notify( "killanimscript" );
			return;
		}
	}
}

iscqbwalking()
{
	if ( isDefined( self.cqbwalking ) )
	{
		return self.cqbwalking;
	}
}

squared( value )
{
	return value * value;
}

randomizeidleset()
{
	self.a.idleset = randomint( 2 );
}

getrandomintfromseed( intseed, intmax )
{
/#
	assert( intmax > 0 );
#/
	index = intseed % anim.randominttablesize;
	return anim.randominttable[ index ] % intmax;
}

is_banzai()
{
	if ( isDefined( self.banzai ) )
	{
		return self.banzai;
	}
}

is_heavy_machine_gun()
{
	if ( isDefined( self.heavy_machine_gunner ) )
	{
		return self.heavy_machine_gunner;
	}
}

is_zombie()
{
	if ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		return 1;
	}
	return 0;
}

is_civilian()
{
	if ( isDefined( self.is_civilian ) && self.is_civilian )
	{
		return 1;
	}
	return 0;
}

is_zombie_gibbed()
{
	if ( self is_zombie() )
	{
		return self.gibbed;
	}
}

set_zombie_gibbed()
{
	if ( self is_zombie() )
	{
		self.gibbed = 1;
	}
}

is_skeleton( skeleton )
{
	if ( skeleton == "base" && issubstr( get_skeleton(), "scaled" ) )
	{
		return 1;
	}
	return get_skeleton() == skeleton;
}

get_skeleton()
{
	if ( isDefined( self.skeleton ) )
	{
		return self.skeleton;
	}
	else
	{
		return "base";
	}
}

debug_anim_print( text )
{
/#
	if ( isDefined( level.dog_debug_anims ) && level.dog_debug_anims )
	{
		println( ( text + " " ) + getTime() );
	}
	if ( isDefined( level.dog_debug_anims_ent ) && level.dog_debug_anims_ent == self getentnum() )
	{
		println( ( text + " " ) + getTime() );
#/
	}
}

debug_turn_print( text, line )
{
/#
	if ( isDefined( level.dog_debug_turns ) && level.dog_debug_turns == self getentnum() )
	{
		duration = 200;
		currentyawcolor = ( 0, 0, 1 );
		lookaheadyawcolor = ( 0, 0, 1 );
		desiredyawcolor = ( 0, 0, 1 );
		currentyaw = angleClamp180( self.angles[ 1 ] );
		desiredyaw = angleClamp180( self.desiredangle );
		lookaheaddir = self.lookaheaddir;
		lookaheadangles = vectorToAngle( lookaheaddir );
		lookaheadyaw = angleClamp180( lookaheadangles[ 1 ] );
		println( ( text + " " ) + getTime() + " cur: " + currentyaw + " look: " + lookaheadyaw + " desired: " + desiredyaw );
#/
	}
}

play_sound_on_tag_endon_death( alias, tag )
{
	maps/mp/_utility::play_sound_on_tag( alias, tag );
}

play_sound_in_space( alias, origin, master )
{
	org = spawn( "script_origin", ( 0, 0, 1 ) );
	if ( !isDefined( origin ) )
	{
		origin = self.origin;
	}
	org.origin = origin;
	if ( isDefined( master ) && master )
	{
		org playsoundasmaster( alias );
	}
	else
	{
		org playsound( alias );
	}
	if ( isDefined( org ) )
	{
		org delete();
	}
}

wait_network_frame()
{
	if ( numremoteclients() )
	{
		snapshot_ids = getsnapshotindexarray();
		acked = undefined;
		while ( !isDefined( acked ) )
		{
			level waittill( "snapacknowledged" );
			acked = snapshotacknowledged( snapshot_ids );
		}
	}
	else wait 0,1;
}
