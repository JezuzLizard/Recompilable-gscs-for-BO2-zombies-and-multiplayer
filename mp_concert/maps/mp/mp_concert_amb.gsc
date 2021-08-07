#include common_scripts/utility;
#include maps/mp/_ambientpackage;
#include maps/mp/_utility;

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
	while ( 1 )
	{
		self waittill( "damage" );
		self playsound( self.script_noteworthy );
		wait 0,1;
	}
}
