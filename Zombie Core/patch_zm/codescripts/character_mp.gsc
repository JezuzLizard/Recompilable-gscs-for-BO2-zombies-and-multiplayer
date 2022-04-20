#include codescripts/character;

setmodelfromarray( a )
{
	self setmodel( a[ randomint( a.size ) ] );
}

precachemodelarray( a )
{
	i = 0;
	while ( i < a.size )
	{
		precachemodel( a[ i ] );
		i++;
	}
}

attachfromarray( a )
{
	self attach( codescripts/character::randomelement( a ), "", 1 );
}
