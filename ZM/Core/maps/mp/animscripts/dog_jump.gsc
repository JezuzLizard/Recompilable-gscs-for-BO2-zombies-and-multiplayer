// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\shared;

main()
{
    self endon( "killanimscript" );
    debug_anim_print( "dog_jump::main()" );
    self setaimanimweights( 0, 0 );
    self.safetochangescript = 0;
    self setanimstate( "traverse_wallhop" );
    maps\mp\animscripts\shared::donotetracks( "done" );
    self.safetochangescript = 1;
}
