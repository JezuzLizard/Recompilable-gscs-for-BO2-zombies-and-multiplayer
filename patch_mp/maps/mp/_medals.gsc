//checked includes match cerberus output
#include common_scripts/utility;
#include maps/mp/_scoreevents;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	level.medalinfo = [];
	level.medalcallbacks = [];
	level.numkills = 0;
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player.lastkilledby = undefined;
	}
}

setlastkilledby( attacker ) //checked matches cerberus output
{
	self.lastkilledby = attacker;
}

offenseglobalcount() //checked matches cerberus output
{
	level.globalteammedals++;
}

defenseglobalcount() //checked matches cerberus output
{
	level.globalteammedals++;
}

codecallback_medal( medalindex ) //checked matches cerberus output
{
	self luinotifyevent( &"medal_received", 1, medalindex );
	self luinotifyeventtospectators( &"medal_received", 1, medalindex );
}
