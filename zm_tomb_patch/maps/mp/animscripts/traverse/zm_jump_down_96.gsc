#include maps/mp/animscripts/traverse/zm_shared;
#include maps/mp/animscripts/traverse/shared;

main()
{
	if ( isDefined( self.isdog ) && self.isdog )
	{
		dog_jump_down( 96, 7 );
	}
	else
	{
		dosimpletraverse( "jump_down_96" );
	}
}
