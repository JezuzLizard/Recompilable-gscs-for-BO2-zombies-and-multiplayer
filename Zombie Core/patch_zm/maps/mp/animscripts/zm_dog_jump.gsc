// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\zm_shared;

main()
{
    self endon( "killanimscript" );
    debug_anim_print( "dog_jump::main()" );
    self setaimanimweights( 0, 0 );
    self.safetochangescript = 0;
    self setanimstatefromasd( "zm_traverse_wallhop" );
    maps\mp\animscripts\zm_shared::donotetracks( "traverse_wallhop" );
    self.safetochangescript = 1;
}
