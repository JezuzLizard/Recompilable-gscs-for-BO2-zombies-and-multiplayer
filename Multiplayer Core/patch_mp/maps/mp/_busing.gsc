//checked includes match cerberus output
#include maps/mp/_utility;

businit() //checked matches cerberus output
{
	/*
/#
	assert( level.clientscripts );
#/
	*/
	level.busstate = "";
	registerclientsys( "busCmd" );
}

setbusstate( state ) //checked matches cerberus output
{
	if ( level.busstate != state )
	{
		setclientsysstate( "busCmd", state );
	}
	level.busstate = state;
}
