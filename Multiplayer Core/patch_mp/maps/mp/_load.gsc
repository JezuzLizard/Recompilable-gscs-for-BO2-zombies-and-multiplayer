// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_script_gen;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_tweakables;
#include maps\mp\_destructible;
#include maps\mp\_riotshield;
#include maps\mp\_vehicles;
#include maps\mp\killstreaks\_dogs;
#include maps\mp\killstreaks\_ai_tank;
#include maps\mp\killstreaks\_rcbomb;
#include maps\mp\killstreaks\_helicopter_guard;
#include maps\mp\_trophy_system;
#include maps\mp\_proximity_grenade;
#include maps\mp\_audio;
#include maps\mp\_busing;
#include maps\mp\_music;
#include maps\mp\_fxanim;
#include maps\mp\_interactive_objects;
#include maps\mp\_serverfaceanim_mp;
#include maps\mp\_art;
#include maps\mp\_createfx;
#include maps\mp\_global_fx;
#include maps\mp\_demo;
#include maps\mp\_development_dvars;
#include maps\mp\_load;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\gametypes\_spawnlogic;

main( bscriptgened, bcsvgened, bsgenabled )
{
    if ( !isdefined( level.script_gen_dump_reasons ) )
        level.script_gen_dump_reasons = [];

    if ( !isdefined( bsgenabled ) )
        level.script_gen_dump_reasons[level.script_gen_dump_reasons.size] = "First run";

    if ( !isdefined( bcsvgened ) )
        bcsvgened = 0;

    level.bcsvgened = bcsvgened;

    if ( !isdefined( bscriptgened ) )
        bscriptgened = 0;
    else
        bscriptgened = 1;

    level.bscriptgened = bscriptgened;
    level._loadstarted = 1;
    struct_class_init();
    level.clientscripts = getdvar( "cg_usingClientScripts" ) != "";
    level._client_exploders = [];
    level._client_exploder_ids = [];

    if ( !isdefined( level.flag ) )
    {
        level.flag = [];
        level.flags_lock = [];
    }

    if ( !isdefined( level.timeofday ) )
        level.timeofday = "day";

    flag_init( "scriptgen_done" );
    level.script_gen_dump_reasons = [];

    if ( !isdefined( level.script_gen_dump ) )
    {
        level.script_gen_dump = [];
        level.script_gen_dump_reasons[0] = "First run";
    }

    if ( !isdefined( level.script_gen_dump2 ) )
        level.script_gen_dump2 = [];

    if ( isdefined( level.createfxent ) )
        script_gen_dump_addline( "maps\mp\createfx\" + level.script + "_fx::main();", level.script + "_fx" );

    if ( isdefined( level.script_gen_dump_preload ) )
    {
        for ( i = 0; i < level.script_gen_dump_preload.size; i++ )
            script_gen_dump_addline( level.script_gen_dump_preload[i].string, level.script_gen_dump_preload[i].signature );
    }

    if ( getdvar( "scr_RequiredMapAspectratio" ) == "" )
        setdvar( "scr_RequiredMapAspectratio", "1" );

    setdvar( "r_waterFogTest", 0 );
    setdvar( "tu6_player_shallowWaterHeight", "0.0" );
    precacherumble( "reload_small" );
    precacherumble( "reload_medium" );
    precacherumble( "reload_large" );
    precacherumble( "reload_clipin" );
    precacherumble( "reload_clipout" );
    precacherumble( "reload_rechamber" );
    precacherumble( "pullout_small" );
    precacherumble( "buzz_high" );
    precacherumble( "riotshield_impact" );
    registerclientsys( "levelNotify" );
    level.aitriggerspawnflags = getaitriggerflags();
    level.vehicletriggerspawnflags = getvehicletriggerflags();
    level.physicstracemaskphysics = 1;
    level.physicstracemaskvehicle = 2;
    level.physicstracemaskwater = 4;
    level.physicstracemaskclip = 8;
    level.physicstracecontentsvehicleclip = 16;
    level.createfx_enabled = getdvar( "createfx" ) != "";

    if ( !sessionmodeiszombiesgame() )
    {
        thread maps\mp\gametypes\_spawning::init();
        thread maps\mp\gametypes\_tweakables::init();
        thread maps\mp\_destructible::init();
        thread maps\mp\_riotshield::register();
        thread maps\mp\_vehicles::init();
        thread maps\mp\killstreaks\_dogs::init();
        thread maps\mp\killstreaks\_ai_tank::register();
        thread maps\mp\killstreaks\_rcbomb::register();
        thread maps\mp\killstreaks\_helicopter_guard::register();
        thread maps\mp\_trophy_system::register();
        thread maps\mp\_proximity_grenade::register();
        maps\mp\_audio::init();
        thread maps\mp\_busing::businit();
        thread maps\mp\_music::music_init();
        thread maps\mp\_fxanim::init();
    }
    else
    {
        level thread start_intro_screen_zm();
        thread maps\mp\_interactive_objects::init();
        maps\mp\_audio::init();
        thread maps\mp\_busing::businit();
        thread maps\mp\_music::music_init();
        thread maps\mp\_fxanim::init();
        thread maps\mp\_serverfaceanim_mp::init();

        if ( level.createfx_enabled )
            setinitialplayersconnected();
    }

    visionsetnight( "default_night" );
    setup_traversals();
    maps\mp\_art::main();
    setupexploders();
    parse_structs();

    if ( sessionmodeiszombiesgame() )
        thread footsteps();
/#
    level thread level_notify_listener();
    level thread client_notify_listener();
#/
    thread maps\mp\_createfx::fx_init();

    if ( level.createfx_enabled )
    {
        calculate_map_center();
        maps\mp\_createfx::createfx();
    }

    if ( getdvar( "r_reflectionProbeGenerate" ) == "1" )
    {
        maps\mp\_global_fx::main();

        level waittill( "eternity" );
    }

    thread maps\mp\_global_fx::main();
    maps\mp\_demo::init();

    if ( !sessionmodeiszombiesgame() )
        thread maps\mp\_development_dvars::init();

    for ( p = 0; p < 6; p++ )
    {
        switch ( p )
        {
            case "0":
                triggertype = "trigger_multiple";
                break;
            case "1":
                triggertype = "trigger_once";
                break;
            case "2":
                triggertype = "trigger_use";
                break;
            case "3":
                triggertype = "trigger_radius";
                break;
            case "4":
                triggertype = "trigger_lookat";
                break;
            default:
/#
                assert( p == 5 );
#/
                triggertype = "trigger_damage";
                break;
        }

        triggers = getentarray( triggertype, "classname" );

        for ( i = 0; i < triggers.size; i++ )
        {
            if ( isdefined( triggers[i].script_prefab_exploder ) )
                triggers[i].script_exploder = triggers[i].script_prefab_exploder;

            if ( isdefined( triggers[i].script_exploder ) )
                level thread maps\mp\_load::exploder_load( triggers[i] );
        }
    }
}

level_notify_listener()
{
    while ( true )
    {
        val = getdvar( "level_notify" );

        if ( val != "" )
        {
            level notify( val );
            setdvar( "level_notify", "" );
        }

        wait 0.2;
    }
}

client_notify_listener()
{
    while ( true )
    {
        val = getdvar( "client_notify" );

        if ( val != "" )
        {
            clientnotify( val );
            setdvar( "client_notify", "" );
        }

        wait 0.2;
    }
}

footsteps()
{
    maps\mp\animscripts\utility::setfootstepeffect( "asphalt", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "brick", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "carpet", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "cloth", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "concrete", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "dirt", loadfx( "bio/player/fx_footstep_sand" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "foliage", loadfx( "bio/player/fx_footstep_sand" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "gravel", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "grass", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "metal", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "mud", loadfx( "bio/player/fx_footstep_mud" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "paper", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "plaster", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "rock", loadfx( "bio/player/fx_footstep_dust" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "sand", loadfx( "bio/player/fx_footstep_sand" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "water", loadfx( "bio/player/fx_footstep_water" ) );
    maps\mp\animscripts\utility::setfootstepeffect( "wood", loadfx( "bio/player/fx_footstep_dust" ) );
}

parse_structs()
{
    for ( i = 0; i < level.struct.size; i++ )
    {
        if ( isdefined( level.struct[i].targetname ) )
        {
            if ( level.struct[i].targetname == "flak_fire_fx" )
            {
                level._effect["flak20_fire_fx"] = loadfx( "weapon/tracer/fx_tracer_flak_single_noExp" );
                level._effect["flak38_fire_fx"] = loadfx( "weapon/tracer/fx_tracer_quad_20mm_Flak38_noExp" );
                level._effect["flak_cloudflash_night"] = loadfx( "weapon/flak/fx_flak_cloudflash_night" );
                level._effect["flak_burst_single"] = loadfx( "weapon/flak/fx_flak_single_day_dist" );
            }

            if ( level.struct[i].targetname == "fake_fire_fx" )
                level._effect["distant_muzzleflash"] = loadfx( "weapon/muzzleflashes/heavy" );

            if ( level.struct[i].targetname == "spotlight_fx" )
                level._effect["spotlight_beam"] = loadfx( "env/light/fx_ray_spotlight_md" );
        }
    }
}

exploder_load( trigger )
{
    level endon( "killexplodertridgers" + trigger.script_exploder );

    trigger waittill( "trigger" );

    if ( isdefined( trigger.script_chance ) && randomfloat( 1 ) > trigger.script_chance )
    {
        if ( isdefined( trigger.script_delay ) )
            wait( trigger.script_delay );
        else
            wait 4;

        level thread exploder_load( trigger );
        return;
    }

    maps\mp\_utility::exploder( trigger.script_exploder );
    level notify( "killexplodertridgers" + trigger.script_exploder );
}

setupexploders()
{
    ents = getentarray( "script_brushmodel", "classname" );
    smodels = getentarray( "script_model", "classname" );

    for ( i = 0; i < smodels.size; i++ )
        ents[ents.size] = smodels[i];

    for ( i = 0; i < ents.size; i++ )
    {
        if ( isdefined( ents[i].script_prefab_exploder ) )
            ents[i].script_exploder = ents[i].script_prefab_exploder;

        if ( isdefined( ents[i].script_exploder ) )
        {
            if ( ents[i].model == "fx" && ( !isdefined( ents[i].targetname ) || ents[i].targetname != "exploderchunk" ) )
            {
                ents[i] hide();
                continue;
            }

            if ( isdefined( ents[i].targetname ) && ents[i].targetname == "exploder" )
            {
                ents[i] hide();
                ents[i] notsolid();
                continue;
            }

            if ( isdefined( ents[i].targetname ) && ents[i].targetname == "exploderchunk" )
            {
                ents[i] hide();
                ents[i] notsolid();
            }
        }
    }

    script_exploders = [];
    potentialexploders = getentarray( "script_brushmodel", "classname" );

    for ( i = 0; i < potentialexploders.size; i++ )
    {
        if ( isdefined( potentialexploders[i].script_prefab_exploder ) )
            potentialexploders[i].script_exploder = potentialexploders[i].script_prefab_exploder;

        if ( isdefined( potentialexploders[i].script_exploder ) )
            script_exploders[script_exploders.size] = potentialexploders[i];
    }

    potentialexploders = getentarray( "script_model", "classname" );

    for ( i = 0; i < potentialexploders.size; i++ )
    {
        if ( isdefined( potentialexploders[i].script_prefab_exploder ) )
            potentialexploders[i].script_exploder = potentialexploders[i].script_prefab_exploder;

        if ( isdefined( potentialexploders[i].script_exploder ) )
            script_exploders[script_exploders.size] = potentialexploders[i];
    }

    potentialexploders = getentarray( "item_health", "classname" );

    for ( i = 0; i < potentialexploders.size; i++ )
    {
        if ( isdefined( potentialexploders[i].script_prefab_exploder ) )
            potentialexploders[i].script_exploder = potentialexploders[i].script_prefab_exploder;

        if ( isdefined( potentialexploders[i].script_exploder ) )
            script_exploders[script_exploders.size] = potentialexploders[i];
    }

    if ( !isdefined( level.createfxent ) )
        level.createfxent = [];

    acceptabletargetnames = [];
    acceptabletargetnames["exploderchunk visible"] = 1;
    acceptabletargetnames["exploderchunk"] = 1;
    acceptabletargetnames["exploder"] = 1;

    for ( i = 0; i < script_exploders.size; i++ )
    {
        exploder = script_exploders[i];
        ent = createexploder( exploder.script_fxid );
        ent.v = [];
        ent.v["origin"] = exploder.origin;
        ent.v["angles"] = exploder.angles;
        ent.v["delay"] = exploder.script_delay;
        ent.v["firefx"] = exploder.script_firefx;
        ent.v["firefxdelay"] = exploder.script_firefxdelay;
        ent.v["firefxsound"] = exploder.script_firefxsound;
        ent.v["firefxtimeout"] = exploder.script_firefxtimeout;
        ent.v["earthquake"] = exploder.script_earthquake;
        ent.v["damage"] = exploder.script_damage;
        ent.v["damage_radius"] = exploder.script_radius;
        ent.v["soundalias"] = exploder.script_soundalias;
        ent.v["repeat"] = exploder.script_repeat;
        ent.v["delay_min"] = exploder.script_delay_min;
        ent.v["delay_max"] = exploder.script_delay_max;
        ent.v["target"] = exploder.target;
        ent.v["ender"] = exploder.script_ender;
        ent.v["type"] = "exploder";

        if ( !isdefined( exploder.script_fxid ) )
            ent.v["fxid"] = "No FX";
        else
            ent.v["fxid"] = exploder.script_fxid;

        ent.v["exploder"] = exploder.script_exploder;
/#
        assert( isdefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );
#/
        if ( !isdefined( ent.v["delay"] ) )
            ent.v["delay"] = 0;

        if ( isdefined( exploder.target ) )
        {
            org = getent( ent.v["target"], "targetname" ).origin;
            ent.v["angles"] = vectortoangles( org - ent.v["origin"] );
        }

        if ( exploder.classname == "script_brushmodel" || isdefined( exploder.model ) )
        {
            ent.model = exploder;
            ent.model.disconnect_paths = exploder.script_disconnectpaths;
        }

        if ( isdefined( exploder.targetname ) && isdefined( acceptabletargetnames[exploder.targetname] ) )
            ent.v["exploder_type"] = exploder.targetname;
        else
            ent.v["exploder_type"] = "normal";

        ent maps\mp\_createfx::post_entity_creation_function();
    }

    level.createfxexploders = [];

    for ( i = 0; i < level.createfxent.size; i++ )
    {
        ent = level.createfxent[i];

        if ( ent.v["type"] != "exploder" )
            continue;

        ent.v["exploder_id"] = getexploderid( ent );

        if ( !isdefined( level.createfxexploders[ent.v["exploder"]] ) )
            level.createfxexploders[ent.v["exploder"]] = [];

        level.createfxexploders[ent.v["exploder"]][level.createfxexploders[ent.v["exploder"]].size] = ent;
    }
}

setup_traversals()
{
    potential_traverse_nodes = getallnodes();

    for ( i = 0; i < potential_traverse_nodes.size; i++ )
    {
        node = potential_traverse_nodes[i];

        if ( node.type == "Begin" )
            node maps\mp\animscripts\traverse\shared::init_traverse();
    }
}

calculate_map_center()
{
    if ( !isdefined( level.mapcenter ) )
    {
        level.nodesmins = ( 0, 0, 0 );
        level.nodesmaxs = ( 0, 0, 0 );
        level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.nodesmins, level.nodesmaxs );
/#
        println( "map center: ", level.mapcenter );
#/
        setmapcenter( level.mapcenter );
    }
}

start_intro_screen_zm()
{
    if ( level.createfx_enabled )
        return;

    if ( !isdefined( level.introscreen ) )
    {
        level.introscreen = newhudelem();
        level.introscreen.x = 0;
        level.introscreen.y = 0;
        level.introscreen.horzalign = "fullscreen";
        level.introscreen.vertalign = "fullscreen";
        level.introscreen.foreground = 0;
        level.introscreen setshader( "black", 640, 480 );
        wait 0.05;
    }

    level.introscreen.alpha = 1;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] freezecontrols( 1 );

    wait 1;
}
