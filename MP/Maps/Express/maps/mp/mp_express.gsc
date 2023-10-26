// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\mp_express_fx;
#include maps\mp\_load;
#include maps\mp\_compass;
#include maps\mp\mp_express_amb;
#include maps\mp\mp_express_train;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_express_fx::main();
    maps\mp\_load::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_express" );
    maps\mp\mp_express_amb::main();
    game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
    game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
    game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
    game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
    game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";
    game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
    game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
    game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
    game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
    game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";
    registerclientfield( "vehicle", "train_moving", 1, 1, "int" );
    registerclientfield( "scriptmover", "train_moving", 1, 1, "int" );

    if ( getgametypesetting( "allowMapScripting" ) )
        maps\mp\mp_express_train::init();
/#
    level thread devgui_express();
    execdevgui( "devgui_mp_express" );
#/
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1900", reset_dvars );
}

devgui_express()
{
/#
    setdvar( "devgui_notify", "" );

    for (;;)
    {
        wait 0.5;
        devgui_string = getdvar( "devgui_notify" );

        switch ( devgui_string )
        {
            case "":
                break;
            case "train_start":
                level notify( "train_start" );
                break;
            default:
                break;
        }

        if ( getdvar( "devgui_notify" ) != "" )
            setdvar( "devgui_notify", "" );
    }
#/
}
