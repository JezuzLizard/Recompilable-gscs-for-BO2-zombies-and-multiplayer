//checked includes match cerberus output
#include maps/mp/_utility;

music_init() //checked matches cerberus output
{
	/*
/#
	assert( level.clientscripts );
#/
	*/
	level.musicstate = "";
	registerclientsys( "musicCmd" );
}

setmusicstate( state, player ) //checked changed to match cerberus output
{
	if ( isDefined( level.musicstate ) )
	{
		if ( isDefined( player ) )
		{
			setclientsysstate( "musicCmd", state, player );
			return;
		}
		else if ( level.musicstate != state )
		{
			setclientsysstate( "musicCmd", state );
		}
	}
	level.musicstate = state;
}
