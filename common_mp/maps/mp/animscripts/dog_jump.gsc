#include maps/mp/animscripts/shared;
#include maps/mp/animscripts/utility;

main()
{
	self endon( "killanimscript" );
	debug_anim_print( "dog_jump::main()" );
	self setaimanimweights( 0, 0 );
	self.safetochangescript = 0;
	self setanimstate( "traverse_wallhop" );
	maps/mp/animscripts/shared::donotetracks( "done" );
	self.safetochangescript = 1;
}
