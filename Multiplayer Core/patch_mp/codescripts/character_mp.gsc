//checked includes matches cerberus output
#include codescripts/character;

setmodelfromarray( a ) //checked matches cerberus output
{
	self setmodel( a[ randomint( a.size ) ] );
}

precachemodelarray( a ) //checked changed to match cerberus output
{
	for ( i = 0; i < a.size; i++ ) 
	{
		precachemodel( a[ i ] );
	}
}

attachfromarray( a ) //checked matches cerberus output
{
	self attach( codescripts/character::randomelement( a ), "", 1 );
}
