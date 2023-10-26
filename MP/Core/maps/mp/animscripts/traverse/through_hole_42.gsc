// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\shared;

main()
{
    self endon( "killanimscript" );
    self traversemode( "nogravity" );
    self traversemode( "noclip" );
    startnode = self getnegotiationstartnode();
    assert( isdefined( startnode ) );
    self orientmode( "face angle", startnode.angles[1] );

    if ( isdefined( startnode.traverse_height ) )
    {
        realheight = startnode.traverse_height - startnode.origin[2];
        self thread teleportthread( realheight );
    }

    debug_anim_print( "traverse::through_hole()" );
    self setanimstate( "traverse_through_hole_42" );
    maps\mp\animscripts\shared::donotetracksfortime( 1.0, "done" );
    debug_anim_print( "traverse::through_hole()" );
    self.traversecomplete = 1;
}
