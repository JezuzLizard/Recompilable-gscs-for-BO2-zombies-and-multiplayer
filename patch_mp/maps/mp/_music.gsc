#include maps/mp/_utility;

music_init()
{
/#
	assert( level.clientscripts );
#/
	level.musicstate = "";
	registerclientsys( "musicCmd" );
}

setmusicstate( state, player )
{
	if ( isDefined( level.musicstate ) )
	{
		if ( isDefined( player ) )
		{
			setclientsysstate( "musicCmd", state, player );
			return;
		}
		else
		{
			if ( level.musicstate != state )
			{
				setclientsysstate( "musicCmd", state );
			}
		}
	}
	level.musicstate = state;
}
