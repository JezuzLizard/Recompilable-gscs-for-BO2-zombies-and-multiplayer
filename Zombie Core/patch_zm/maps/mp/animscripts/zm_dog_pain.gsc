#include maps/mp/animscripts/utility;

main()
{
	debug_anim_print( "dog_pain::main() " );
	self endon( "killanimscript" );
	self setaimanimweights( 0, 0 );
}
