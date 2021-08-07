#include maps/mp/animscripts/shared;
#include maps/mp/animscripts/utility;

main()
{
	debug_anim_print( "dog_death::main()" );
	self setaimanimweights( 0, 0 );
	self endon( "killanimscript" );
	if ( isDefined( self.a.nodeath ) )
	{
/#
		assert( self.a.nodeath, "Nodeath needs to be set to true or undefined." );
#/
		wait 3;
		return;
	}
	self unlink();
	if ( isDefined( self.enemy ) && isDefined( self.enemy.syncedmeleetarget ) && self.enemy.syncedmeleetarget == self )
	{
		self.enemy.syncedmeleetarget = undefined;
	}
	death_anim = "death_" + getanimdirection( self.damageyaw );
/#
	println( death_anim );
#/
	self animmode( "gravity", 0 );
	debug_anim_print( "dog_death::main() - Setting " + death_anim );
	self setanimstate( death_anim );
	self maps/mp/animscripts/shared::donotetracks( "done" );
}
