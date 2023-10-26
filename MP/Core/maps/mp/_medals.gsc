// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\_scoreevents;
#include common_scripts\utility;

init()
{
    level.medalinfo = [];
    level.medalcallbacks = [];
    level.numkills = 0;
    level thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player.lastkilledby = undefined;
    }
}

setlastkilledby( attacker )
{
    self.lastkilledby = attacker;
}

offenseglobalcount()
{
    level.globalteammedals++;
}

defenseglobalcount()
{
    level.globalteammedals++;
}

codecallback_medal( medalindex )
{
    self luinotifyevent( &"medal_received", 1, medalindex );
    self luinotifyeventtospectators( &"medal_received", 1, medalindex );
}
