#include maps/mp/animscripts/shared;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/traverse/shared;

main()
{
	self endon( "killanimscript" );
	self traversemode( "nogravity" );
	self traversemode( "noclip" );
	startnode = self getnegotiationstartnode();
/#
	assert( isDefined( startnode ) );
#/
	self orientmode( "face angle", startnode.angles[ 1 ] );
	if ( isDefined( startnode.traverse_height ) )
	{
		realheight = startnode.traverse_height - startnode.origin[ 2 ];
		self thread teleportthread( realheight );
	}
	debug_anim_print( "traverse::through_hole()" );
	self setanimstate( "traverse_through_hole_42" );
	maps/mp/animscripts/shared::donotetracksfortime( 1, "done" );
	debug_anim_print( "traverse::through_hole()" );
	self.traversecomplete = 1;
}
