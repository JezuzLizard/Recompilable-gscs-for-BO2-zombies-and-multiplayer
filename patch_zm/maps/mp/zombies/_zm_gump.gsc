#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked changed to match cerberus output //changed partially at own discretion
{	
/*
	if ( isDefined( level.disable_blackscreen_clientfield ) && level.disable_blackscreen_clientfield )
	{
		registerclientfield( "toplayer", "blackscreen", 1, 1, "int" );
	}
*/	//the value of level.disable_blackscreen_clientfield is not defined in any map file except buried meaning
	if ( !isDefined( level.disable_blackscreen_clientfield ) || !level.disable_blackscreen_clientfield )
	{
		registerclientfield( "toplayer", "blackscreen", 1, 1, "int" );
	}
	if ( !isDefined( level.uses_gumps ) )
	{
		level.uses_gumps = 0;
	}
	if ( isDefined( level.uses_gumps ) && level.uses_gumps )
	{
		onplayerconnect_callback( ::player_connect_gump );
	}
}

player_teleport_blackscreen_on() //checked matches cerberus output
{
	if ( isDefined( level.disable_blackscreen_clientfield ) && level.disable_blackscreen_clientfield )
	{
		return;
	}
	if ( isDefined( level.uses_gumps ) && level.uses_gumps )
	{
		self setclientfieldtoplayer( "blackscreen", 1 );
		wait 0.05;
		self setclientfieldtoplayer( "blackscreen", 0 );
	}
}

player_connect_gump() //checked matches cerberus output
{
}

player_watch_spectate_change() //checked matches cerberus output
{
	if ( isDefined( level.disable_blackscreen_clientfield ) && level.disable_blackscreen_clientfield )
	{
		return;
	}
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "spectator_cycle" );
		self setclientfieldtoplayer( "blackscreen", 1 );
		wait 0.05;
		self setclientfieldtoplayer( "blackscreen", 0 );
	}
}

gump_test()
{
/*
/#
	wait 10;
	pos1 = ( -4904, -7657, 4 );
	pos3 = ( 7918, -6506, 177 );
	pos2 = ( 1986, -73, 4 );
	players = get_players();
	if ( isDefined( players[ 0 ] ) )
	{
		players[ 0 ] setorigin( pos1 );
	}
	wait 0.05;
	if ( isDefined( players[ 1 ] ) )
	{
		players[ 1 ] setorigin( pos2 );
	}
	wait 0.05;
	if ( isDefined( players[ 2 ] ) )
	{
		players[ 2 ] setorigin( pos3 );
#/
	}
*/
}



