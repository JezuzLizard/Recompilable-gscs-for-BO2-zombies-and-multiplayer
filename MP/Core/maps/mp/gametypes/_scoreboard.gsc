// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( level.createfx_enabled )
        return;

    if ( sessionmodeiszombiesgame() )
    {
        setdvar( "g_TeamIcon_Axis", "faction_cia" );
        setdvar( "g_TeamIcon_Allies", "faction_cdc" );
    }
    else
    {
        setdvar( "g_TeamIcon_Axis", game["icons"]["axis"] );
        setdvar( "g_TeamIcon_Allies", game["icons"]["allies"] );
    }
}
