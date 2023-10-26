// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\_ambientpackage;
#include common_scripts\utility;

main()
{
    level thread instruments_init();
}

instruments_init()
{
    inst_trigs = getentarray( "snd_instrument", "targetname" );
    array_thread( inst_trigs, ::play_instrument );
}

play_instrument()
{
    while ( true )
    {
        self waittill( "damage" );

        self playsound( self.script_noteworthy );
        wait 0.1;
    }
}
