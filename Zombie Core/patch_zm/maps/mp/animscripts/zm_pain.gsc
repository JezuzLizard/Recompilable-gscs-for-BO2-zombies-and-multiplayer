#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;
#include common_scripts/utility;

main()
{
	self setflashbanged( 0 );
	if ( isDefined( self.longdeathstarting ) )
	{
		self waittill( "killanimscript" );
		return;
	}
	if ( self.a.disablepain )
	{
		return;
	}
}
