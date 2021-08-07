//checked includes match cerberus output
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	precacheshader( "objpoint_default" );
	level.objpointnames = [];
	level.objpoints = [];
	if ( level.splitscreen )
	{
		level.objpointsize = 15;
	}
	else
	{
		level.objpointsize = 8;
	}
	level.objpoint_alpha_default = 0.5;
	level.objpointscale = 1;
}

createteamobjpoint( name, origin, team, shader, alpha, scale ) //checked matches cerberus output
{
	/*
/#
	if ( !isDefined( level.teams[ team ] ) )
	{
		assert( team == "all" );
	}
#/
	*/
	objpoint = getobjpointbyname( name );
	if ( isDefined( objpoint ) )
	{
		deleteobjpoint( objpoint );
	}
	if ( !isDefined( shader ) )
	{
		shader = "objpoint_default";
	}
	if ( !isDefined( scale ) )
	{
		scale = 1;
	}
	if ( team != "all" )
	{
		objpoint = newteamhudelem( team );
	}
	else
	{
		objpoint = newhudelem();
	}
	objpoint.name = name;
	objpoint.x = origin[ 0 ];
	objpoint.y = origin[ 1 ];
	objpoint.z = origin[ 2 ];
	objpoint.team = team;
	objpoint.isflashing = 0;
	objpoint.isshown = 1;
	objpoint.fadewhentargeted = 1;
	objpoint.archived = 0;
	objpoint setshader( shader, level.objpointsize, level.objpointsize );
	objpoint setwaypoint( 1 );
	if ( isDefined( alpha ) )
	{
		objpoint.alpha = alpha;
	}
	else
	{
		objpoint.alpha = level.objpoint_alpha_default;
	}
	objpoint.basealpha = objpoint.alpha;
	objpoint.index = level.objpointnames.size;
	level.objpoints[ name ] = objpoint;
	level.objpointnames[ level.objpointnames.size ] = name;
	return objpoint;
}

deleteobjpoint( oldobjpoint ) //checked changed to match cerberus output
{
	/*
/#
	assert( level.objpoints.size == level.objpointnames.size );
#/
	*/
	if ( level.objpoints.size == 1 )
	{
		/*
/#
		assert( level.objpointnames[ 0 ] == oldobjpoint.name );
#/
/#
		assert( isDefined( level.objpoints[ oldobjpoint.name ] ) );
#/
		*/
		level.objpoints = [];
		level.objpointnames = [];
		oldobjpoint destroy();
		return;
	}
	newindex = oldobjpoint.index;
	oldindex = level.objpointnames.size - 1;
	objpoint = getobjpointbyindex( oldindex );
	level.objpointnames[ newindex ] = objpoint.name;
	objpoint.index = newindex;
	level.objpointnames[oldindex] = undefined;
	level.objpoints[oldobjpoint.name] = undefined;
	oldobjpoint destroy();
}

updateorigin( origin ) //checked matches cerberus output
{
	if ( self.x != origin[ 0 ] )
	{
		self.x = origin[ 0 ];
	}
	if ( self.y != origin[ 1 ] )
	{
		self.y = origin[ 1 ];
	}
	if ( self.z != origin[ 2 ] )
	{
		self.z = origin[ 2 ];
	}
}

setoriginbyname( name, origin ) //checked matches cerberus output
{
	objpoint = getobjpointbyname( name );
	objpoint updateorigin( origin );
}

getobjpointbyname( name ) //checked matches cerberus output
{
	if ( isDefined( level.objpoints[ name ] ) )
	{
		return level.objpoints[ name ];
	}
	else
	{
		return undefined;
	}
}

getobjpointbyindex( index ) //checked matches cerberus output
{
	if ( isDefined( level.objpointnames[ index ] ) )
	{
		return level.objpoints[ level.objpointnames[ index ] ];
	}
	else
	{
		return undefined;
	}
}

startflashing() //checked matches cerberus output
{
	self endon( "stop_flashing_thread" );
	if ( self.isflashing )
	{
		return;
	}
	self.isflashing = 1;
	while ( self.isflashing )
	{
		self fadeovertime( 0.75 );
		self.alpha = 0.35 * self.basealpha;
		wait 0.75;
		self fadeovertime( 0.75 );
		self.alpha = self.basealpha;
		wait 0.75;
	}
	self.alpha = self.basealpha;
}

stopflashing() //checked matches cerberus output
{
	if ( !self.isflashing )
	{
		return;
	}
	self.isflashing = 0;
}

