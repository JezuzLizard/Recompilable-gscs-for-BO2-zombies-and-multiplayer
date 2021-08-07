#include maps/mp/_ambientpackage;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	array_thread( getentarray( "advertisement", "targetname" ), ::advertisements );
}

advertisements()
{
	self playloopsound( "amb_" + self.script_noteworthy + "_ad" );
	self waittill( "damage" );
	self stoploopsound();
	self playloopsound( "amb_" + self.script_noteworthy + "_damaged_ad" );
}
