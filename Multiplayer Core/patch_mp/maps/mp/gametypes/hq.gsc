// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    if ( getdvar( "mapname" ) == "mp_background" )
        return;

    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
    registertimelimit( 0, 1440 );
    registerscorelimit( 0, 1000 );
    registernumlives( 0, 100 );
    registerroundswitch( 0, 9 );
    registerroundwinlimit( 0, 10 );
    maps\mp\gametypes\_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
    level.teambased = 1;
    level.doprematch = 1;
    level.overrideteamscore = 1;
    level.scoreroundbased = 1;
    level.onstartgametype = ::onstartgametype;
    level.onspawnplayer = ::onspawnplayer;
    level.onspawnplayerunified = ::onspawnplayerunified;
    level.playerspawnedcb = ::koth_playerspawnedcb;
    level.onroundswitch = ::onroundswitch;
    level.onplayerkilled = ::onplayerkilled;
    level.onendgame = ::onendgame;
    level.gamemodespawndvars = ::koth_gamemodespawndvars;
    precachestring( &"MP_WAITING_FOR_HQ" );
    precachestring( &"MP_HQ_CAPTURED_BY" );
    level.hqautodestroytime = getgametypesetting( "autoDestroyTime" );
    level.hqspawntime = getgametypesetting( "objectiveSpawnTime" );
    level.kothmode = getgametypesetting( "kothMode" );
    level.capturetime = getgametypesetting( "captureTime" );
    level.destroytime = getgametypesetting( "destroyTime" );
    level.delayplayer = getgametypesetting( "delayPlayer" );
    level.randomhqspawn = getgametypesetting( "randomObjectiveLocations" );
    level.maxrespawndelay = getgametypesetting( "timeLimit" ) * 60;
    level.iconoffset = vectorscale( ( 0, 0, 1 ), 32.0 );
    level.onrespawndelay = ::getrespawndelay;
    game["dialog"]["gametype"] = "hq_start";
    game["dialog"]["gametype_hardcore"] = "hchq_start";
    game["dialog"]["offense_obj"] = "cap_start";
    game["dialog"]["defense_obj"] = "cap_start";
    level.lastdialogtime = 0;
    level.radiospawnqueue = [];

    if ( !sessionmodeissystemlink() && !sessionmodeisonlinegame() && issplitscreen() )
        setscoreboardcolumns( "score", "kills", "captures", "defends", "deaths" );
    else
        setscoreboardcolumns( "score", "kills", "deaths", "captures", "defends" );
}

updateobjectivehintmessages( defenderteam, defendmessage, attackmessage )
{
    foreach ( team in level.teams )
    {
        if ( defenderteam == team )
        {
            game["strings"]["objective_hint_" + team] = defendmessage;
            continue;
        }

        game["strings"]["objective_hint_" + team] = attackmessage;
    }
}

updateobjectivehintmessage( message )
{
    foreach ( team in level.teams )
        game["strings"]["objective_hint_" + team] = message;
}

getrespawndelay()
{
    self.lowermessageoverride = undefined;

    if ( !isdefined( level.radio.gameobject ) )
        return undefined;

    hqowningteam = level.radio.gameobject maps\mp\gametypes\_gameobjects::getownerteam();

    if ( self.pers["team"] == hqowningteam )
    {
        if ( !isdefined( level.hqdestroytime ) )
            timeremaining = level.maxrespawndelay;
        else
            timeremaining = ( level.hqdestroytime - gettime() ) / 1000;

        if ( !level.playerobjectiveheldrespawndelay )
            return undefined;

        if ( level.playerobjectiveheldrespawndelay >= level.hqautodestroytime )
            self.lowermessageoverride = &"MP_WAITING_FOR_HQ";

        if ( level.delayplayer )
            return min( level.spawndelay, timeremaining );
        else
            return ceil( timeremaining );
    }
}

onstartgametype()
{
    if ( !isdefined( game["switchedsides"] ) )
        game["switchedsides"] = 0;

    if ( game["switchedsides"] )
    {
        oldattackers = game["attackers"];
        olddefenders = game["defenders"];
        game["attackers"] = olddefenders;
        game["defenders"] = oldattackers;
    }

    maps\mp\gametypes\_globallogic_score::resetteamscores();

    foreach ( team in level.teams )
    {
        setobjectivetext( team, &"OBJECTIVES_KOTH" );

        if ( level.splitscreen )
        {
            setobjectivescoretext( team, &"OBJECTIVES_HQ" );
            continue;
        }

        setobjectivescoretext( team, &"OBJECTIVES_HQ_SCORE" );
    }

    level.objectivehintpreparehq = &"MP_CONTROL_HQ";
    level.objectivehintcapturehq = &"MP_CAPTURE_HQ";
    level.objectivehintdestroyhq = &"MP_DESTROY_HQ";
    level.objectivehintdefendhq = &"MP_DEFEND_HQ";
    precachestring( level.objectivehintpreparehq );
    precachestring( level.objectivehintcapturehq );
    precachestring( level.objectivehintdestroyhq );
    precachestring( level.objectivehintdefendhq );

    if ( level.kothmode )
        level.objectivehintdestroyhq = level.objectivehintcapturehq;

    if ( level.hqspawntime )
        updateobjectivehintmessage( level.objectivehintpreparehq );
    else
        updateobjectivehintmessage( level.objectivehintcapturehq );

    setclientnamemode( "auto_change" );
    allowed[0] = "hq";
    maps\mp\gametypes\_gameobjects::main( allowed );
    maps\mp\gametypes\_spawning::create_map_placed_influencers();
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );

    foreach ( team in level.teams )
    {
        maps\mp\gametypes\_spawnlogic::addspawnpoints( team, "mp_tdm_spawn" );
        maps\mp\gametypes\_spawnlogic::placespawnpoints( maps\mp\gametypes\_spawning::gettdmstartspawnname( team ) );
    }

    maps\mp\gametypes\_spawning::updateallspawnpoints();
    level.spawn_start = [];

    foreach ( team in level.teams )
        level.spawn_start[team] = maps\mp\gametypes\_spawnlogic::getspawnpointarray( maps\mp\gametypes\_spawning::gettdmstartspawnname( team ) );

    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getrandomintermissionpoint();
    setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
    level.spawn_all = maps\mp\gametypes\_spawnlogic::getspawnpointarray( "mp_tdm_spawn" );

    if ( !level.spawn_all.size )
    {
/#
        println( "^1No mp_tdm_spawn spawnpoints in level!" );
#/
        maps\mp\gametypes\_callbacksetup::abortlevel();
        return;
    }

    thread setupradios();
    thread hqmainloop();
}

spawn_first_radio( delay )
{
    if ( level.randomhqspawn == 1 )
        level.radio = getnextradiofromqueue();
    else
        level.radio = getfirstradio();

    logstring( "radio spawned: (" + level.radio.trigorigin[0] + "," + level.radio.trigorigin[1] + "," + level.radio.trigorigin[2] + ")" );
    level.radio enable_radio_spawn_influencer( 1 );
    return;
}

spawn_next_radio()
{
    if ( level.randomhqspawn != 0 )
        level.radio = getnextradiofromqueue();
    else
        level.radio = getnextradio();

    logstring( "radio spawned: (" + level.radio.trigorigin[0] + "," + level.radio.trigorigin[1] + "," + level.radio.trigorigin[2] + ")" );
    level.radio enable_radio_spawn_influencer( 1 );
    return;
}

hqmainloop()
{
    level endon( "game_ended" );
    level.hqrevealtime = -100000;
    hqspawninginstr = &"MP_HQ_AVAILABLE_IN";

    if ( level.kothmode )
    {
        hqdestroyedinfriendlystr = &"MP_HQ_DESPAWN_IN";
        hqdestroyedinenemystr = &"MP_HQ_DESPAWN_IN";
    }
    else
    {
        hqdestroyedinfriendlystr = &"MP_HQ_REINFORCEMENTS_IN";
        hqdestroyedinenemystr = &"MP_HQ_DESPAWN_IN";
    }

    precachestring( hqspawninginstr );
    precachestring( hqdestroyedinfriendlystr );
    precachestring( hqdestroyedinenemystr );
    precachestring( &"MP_CAPTURING_HQ" );
    precachestring( &"MP_DESTROYING_HQ" );
    spawn_first_radio();
    objective_name = istring( "objective" );
    precachestring( objective_name );

    while ( level.inprematchperiod )
        wait 0.05;

    wait 5;
    timerdisplay = [];

    foreach ( team in level.teams )
    {
        timerdisplay[team] = createservertimer( "objective", 1.4, team );
        timerdisplay[team] setgamemodeinfopoint();
        timerdisplay[team].label = hqspawninginstr;
        timerdisplay[team].font = "small";
        timerdisplay[team].alpha = 0;
        timerdisplay[team].archived = 0;
        timerdisplay[team].hidewheninmenu = 1;
        timerdisplay[team].hidewheninkillcam = 1;
        timerdisplay[team].showplayerteamhudelemtospectator = 1;
        thread hidetimerdisplayongameend( timerdisplay[team] );
    }

    while ( true )
    {
        iprintln( &"MP_HQ_REVEALED" );
        playsoundonplayers( "mp_suitcase_pickup" );
        maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_located" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setmodelvisibility( 1 );
        level.hqrevealtime = gettime();
        maps\mp\killstreaks\_rcbomb::detonatealliftouchingsphere( level.radio.origin, 75 );

        if ( level.hqspawntime )
        {
            level.radio.gameobject maps\mp\gametypes\_gameobjects::setvisibleteam( "any" );
            level.radio.gameobject maps\mp\gametypes\_gameobjects::setflags( 1 );
            updateobjectivehintmessage( level.objectivehintpreparehq );

            foreach ( team in level.teams )
            {
                timerdisplay[team].label = hqspawninginstr;
                timerdisplay[team] settimer( level.hqspawntime );
                timerdisplay[team].alpha = 1;
            }

            wait( level.hqspawntime );
            level.radio.gameobject maps\mp\gametypes\_gameobjects::setflags( 0 );
            maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_online" );
        }

        foreach ( team in level.teams )
            timerdisplay[team].alpha = 0;

        waittillframeend;
        maps\mp\gametypes\_globallogic_audio::leaderdialog( "obj_capture" );
        updateobjectivehintmessage( level.objectivehintcapturehq );
        playsoundonplayers( "mpl_hq_cap_us" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::enableobject();
        level.radio.gameobject.onupdateuserate = ::onupdateuserate;
        level.radio.gameobject maps\mp\gametypes\_gameobjects::allowuse( "any" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setusetime( level.capturetime );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setusetext( &"MP_CAPTURING_HQ" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setvisibleteam( "any" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setmodelvisibility( 1 );
        level.radio.gameobject.onuse = ::onradiocapture;
        level.radio.gameobject.onbeginuse = ::onbeginuse;
        level.radio.gameobject.onenduse = ::onenduse;

        level waittill( "hq_captured" );

        ownerteam = level.radio.gameobject maps\mp\gametypes\_gameobjects::getownerteam();

        if ( level.hqautodestroytime )
        {
            thread destroyhqaftertime( level.hqautodestroytime, ownerteam );

            foreach ( team in level.teams )
                timerdisplay[team] settimer( level.hqautodestroytime );
        }
        else
            level.hqdestroyedbytimer = 0;

        while ( true )
        {
            ownerteam = level.radio.gameobject maps\mp\gametypes\_gameobjects::getownerteam();

            foreach ( team in level.teams )
                updateobjectivehintmessages( ownerteam, level.objectivehintdefendhq, level.objectivehintdestroyhq );

            level.radio.gameobject maps\mp\gametypes\_gameobjects::allowuse( "enemy" );

            if ( !level.kothmode )
                level.radio.gameobject maps\mp\gametypes\_gameobjects::setusetext( &"MP_DESTROYING_HQ" );

            level.radio.gameobject.onuse = ::onradiodestroy;

            if ( level.hqautodestroytime )
            {
                foreach ( team in level.teams )
                {
                    if ( team == ownerteam )
                        timerdisplay[team].label = hqdestroyedinfriendlystr;
                    else
                        timerdisplay[team].label = hqdestroyedinenemystr;

                    timerdisplay[team].alpha = 1;
                }
            }

            level thread dropallaroundhq();

            level waittill( "hq_destroyed", destroy_team );

            level.radio enable_radio_spawn_influencer( 0 );

            if ( !level.kothmode || level.hqdestroyedbytimer )
                break;

            thread forcespawnteam( ownerteam );

            if ( isdefined( destroy_team ) )
                level.radio.gameobject maps\mp\gametypes\_gameobjects::setownerteam( destroy_team );
        }

        level.radio.gameobject maps\mp\gametypes\_gameobjects::disableobject();
        level.radio.gameobject maps\mp\gametypes\_gameobjects::allowuse( "none" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setownerteam( "neutral" );
        level.radio.gameobject maps\mp\gametypes\_gameobjects::setmodelvisibility( 0 );
        level notify( "hq_reset" );

        foreach ( team in level.teams )
            timerdisplay[team].alpha = 0;

        spawn_next_radio();
        wait 0.05;
        thread forcespawnteam( ownerteam );
        wait 3.0;
    }
}

hidetimerdisplayongameend( timerdisplay )
{
    level waittill( "game_ended" );

    timerdisplay.alpha = 0;
}

forcespawnteam( team )
{
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( !isdefined( player ) )
            continue;

        if ( player.pers["team"] == team )
        {
            player notify( "force_spawn" );
            wait 0.1;
        }
    }
}

onbeginuse( player )
{
    ownerteam = self maps\mp\gametypes\_gameobjects::getownerteam();

    if ( ownerteam == "neutral" )
        player thread maps\mp\gametypes\_battlechatter_mp::gametypespecificbattlechatter( "hq_protect", player.pers["team"] );
    else
        player thread maps\mp\gametypes\_battlechatter_mp::gametypespecificbattlechatter( "hq_attack", player.pers["team"] );
}

onenduse( team, player, success )
{
    player notify( "event_ended" );
}

onradiocapture( player )
{
    capture_team = player.pers["team"];
    player logstring( "radio captured" );
    string = &"MP_HQ_CAPTURED_BY";
    level.usestartspawns = 0;
    thread give_capture_credit( self.touchlist[capture_team], string );
    oldteam = maps\mp\gametypes\_gameobjects::getownerteam();
    self maps\mp\gametypes\_gameobjects::setownerteam( capture_team );

    if ( !level.kothmode )
        self maps\mp\gametypes\_gameobjects::setusetime( level.destroytime );

    foreach ( team in level.teams )
    {
        if ( team == capture_team )
        {
            thread printonteamarg( &"MP_HQ_CAPTURED_BY", team, player );
            maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_secured", team );
            thread playsoundonplayers( "mp_war_objective_taken", team );
            continue;
        }

        thread printonteam( &"MP_HQ_CAPTURED_BY_ENEMY", team );
        maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_enemy_captured", team );
        thread playsoundonplayers( "mp_war_objective_lost", team );
    }

    level thread awardhqpoints( capture_team );
    level notify( "hq_captured" );
    player notify( "event_ended" );
}

give_capture_credit( touchlist, string )
{
    time = gettime();
    wait 0.05;
    maps\mp\gametypes\_globallogic_utils::waittillslowprocessallowed();
    players = getarraykeys( touchlist );

    for ( i = 0; i < players.size; i++ )
    {
        player_from_touchlist = touchlist[players[i]].player;
        player_from_touchlist maps\mp\_challenges::capturedobjective( time );
        maps\mp\_scoreevents::processscoreevent( "hq_secure", player_from_touchlist );
        player_from_touchlist recordgameevent( "capture" );
        level thread maps\mp\_popups::displayteammessagetoall( string, player_from_touchlist );

        if ( isdefined( player_from_touchlist.pers["captures"] ) )
        {
            player_from_touchlist.pers["captures"]++;
            player_from_touchlist.captures = player_from_touchlist.pers["captures"];
        }

        maps\mp\_demo::bookmark( "event", gettime(), player_from_touchlist );
        player_from_touchlist addplayerstatwithgametype( "CAPTURES", 1 );
    }
}

dropalltoground( origin, radius, stickyobjectradius )
{
    physicsexplosionsphere( origin, radius, radius, 0 );
    wait 0.05;
    maps\mp\gametypes\_weapons::dropweaponstoground( origin, radius );
    maps\mp\killstreaks\_supplydrop::dropcratestoground( origin, radius );
    level notify( "drop_objects_to_ground", origin, stickyobjectradius );
}

dropallaroundhq( radio )
{
    origin = level.radio.origin;

    level waittill( "hq_reset" );

    dropalltoground( origin, 100, 50 );
}

onradiodestroy( firstplayer )
{
    destroyed_team = firstplayer.pers["team"];
    touchlist = self.touchlist[destroyed_team];
    touchlistkeys = getarraykeys( touchlist );

    foreach ( index in touchlistkeys )
    {
        player = touchlist[index].player;
        player logstring( "radio destroyed" );
        maps\mp\_scoreevents::processscoreevent( "hq_destroyed", player );
        player recordgameevent( "destroy" );
        player addplayerstatwithgametype( "DESTRUCTIONS", 1 );

        if ( isdefined( player.pers["destructions"] ) )
        {
            player.pers["destructions"]++;
            player.destructions = player.pers["destructions"];
        }
    }

    destroyteammessage = &"MP_HQ_DESTROYED_BY";
    otherteammessage = &"MP_HQ_DESTROYED_BY_ENEMY";

    if ( level.kothmode )
    {
        destroyteammessage = &"MP_HQ_CAPTURED_BY";
        otherteammessage = &"MP_HQ_CAPTURED_BY_ENEMY";
    }

    level thread maps\mp\_popups::displayteammessagetoall( destroyteammessage, player );

    foreach ( team in level.teams )
    {
        if ( team == destroyed_team )
        {
            thread printonteamarg( destroyteammessage, team, player );
            maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_secured", team );
            continue;
        }

        thread printonteam( otherteammessage, team );
        maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_enemy_destroyed", team );
    }

    level notify( "hq_destroyed", destroyed_team );

    if ( level.kothmode )
        level thread awardhqpoints( destroyed_team );

    player notify( "event_ended" );
}

destroyhqaftertime( time, ownerteam )
{
    level endon( "game_ended" );
    level endon( "hq_reset" );
    level.hqdestroytime = gettime() + time * 1000;
    level.hqdestroyedbytimer = 0;
    wait( time );
    maps\mp\gametypes\_globallogic_audio::leaderdialog( "hq_offline" );
    level.hqdestroyedbytimer = 1;
    checkplayercount( ownerteam );
    level notify( "hq_destroyed" );
}

checkplayercount( ownerteam )
{
    lastplayeralive = undefined;
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i].team != ownerteam )
            continue;

        if ( isalive( players[i] ) )
        {
            if ( isdefined( lastplayeralive ) )
                return;

            lastplayeralive = players[i];
        }
    }

    if ( isdefined( lastplayeralive ) )
        maps\mp\_scoreevents::processscoreevent( "defend_hq_last_man_alive", lastplayeralive );
}

awardhqpoints( team )
{
    level endon( "game_ended" );
    level endon( "hq_destroyed" );
    level notify( "awardHQPointsRunning" );
    level endon( "awardHQPointsRunning" );
    seconds = 5;

    while ( !level.gameended )
    {
        maps\mp\gametypes\_globallogic_score::giveteamscoreforobjective( team, seconds );

        for ( index = 0; index < level.players.size; index++ )
        {
            player = level.players[index];

            if ( player.pers["team"] == team )
            {

            }
        }

        wait( seconds );
    }
}

onspawnplayerunified()
{
    maps\mp\gametypes\_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn )
{
    spawnpoint = undefined;

    if ( !level.usestartspawns )
    {
        if ( isdefined( level.radio ) )
        {
            if ( isdefined( level.radio.gameobject ) )
            {
                radioowningteam = level.radio.gameobject maps\mp\gametypes\_gameobjects::getownerteam();

                if ( self.pers["team"] == radioowningteam )
                    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_nearteam( level.spawn_all, level.radio.gameobject.nearspawns );
                else if ( level.spawndelay >= level.radioautomovetime && gettime() > level.radiorevealtime + 10000 )
                    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_nearteam( level.spawn_all );
                else
                    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_nearteam( level.spawn_all, level.radio.gameobject.outerspawns );
            }
        }
    }

    if ( !isdefined( spawnpoint ) )
    {
        spawnteam = self.pers["team"];
        spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_random( level.spawn_start[spawnteam] );
    }

/#
    assert( isdefined( spawnpoint ) );
#/

    if ( predictedspawn )
        self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
    else
        self spawn( spawnpoint.origin, spawnpoint.angles, "koth" );
}

koth_playerspawnedcb()
{
    self.lowermessageoverride = undefined;
}

compareradioindexes( radio_a, radio_b )
{
    script_index_a = radio_a.script_index;
    script_index_b = radio_b.script_index;

    if ( !isdefined( script_index_a ) && !isdefined( script_index_b ) )
        return false;

    if ( !isdefined( script_index_a ) && isdefined( script_index_b ) )
    {
/#
        println( "KOTH: Missing script_index on radio at " + radio_a.origin );
#/
        return true;
    }

    if ( isdefined( script_index_a ) && !isdefined( script_index_b ) )
    {
/#
        println( "KOTH: Missing script_index on radio at " + radio_b.origin );
#/
        return false;
    }

    if ( script_index_a > script_index_b )
        return true;

    return false;
}

getradioarray()
{
    radios = getentarray( "hq_hardpoint", "targetname" );

    if ( !isdefined( radios ) )
        return undefined;

    swapped = 1;

    for ( n = radios.size; swapped; n-- )
    {
        swapped = 0;

        for ( i = 0; i < n - 1; i++ )
        {
            if ( compareradioindexes( radios[i], radios[i + 1] ) )
            {
                temp = radios[i];
                radios[i] = radios[i + 1];
                radios[i + 1] = temp;
                swapped = 1;
            }
        }
    }

    return radios;
}

setupradios()
{
    maperrors = [];
    radios = getradioarray();

    if ( radios.size < 2 )
        maperrors[maperrors.size] = "There are not at least 2 entities with targetname \"radio\"";

    trigs = getentarray( "radiotrigger", "targetname" );

    for ( i = 0; i < radios.size; i++ )
    {
        errored = 0;
        radio = radios[i];
        radio.trig = undefined;

        for ( j = 0; j < trigs.size; j++ )
        {
            if ( radio istouching( trigs[j] ) )
            {
                if ( isdefined( radio.trig ) )
                {
                    maperrors[maperrors.size] = "Radio at " + radio.origin + " is touching more than one \"radiotrigger\" trigger";
                    errored = 1;
                    break;
                }

                radio.trig = trigs[j];
                break;
            }
        }

        if ( !isdefined( radio.trig ) )
        {
            if ( !errored )
            {
                maperrors[maperrors.size] = "Radio at " + radio.origin + " is not inside any \"radiotrigger\" trigger";
                continue;
            }
        }

/#
        assert( !errored );
#/
        radio.trigorigin = radio.trig.origin;
        visuals = [];
        visuals[0] = radio;
        othervisuals = getentarray( radio.target, "targetname" );

        for ( j = 0; j < othervisuals.size; j++ )
            visuals[visuals.size] = othervisuals[j];

        objective_name = istring( "objective" );
        precachestring( objective_name );
        radio setupnodes();
        radio.gameobject = maps\mp\gametypes\_gameobjects::createuseobject( "neutral", radio.trig, visuals, radio.origin - radio.trigorigin, objective_name );
        radio.gameobject maps\mp\gametypes\_gameobjects::disableobject();
        radio.gameobject maps\mp\gametypes\_gameobjects::setmodelvisibility( 0 );
        radio.trig.useobj = radio.gameobject;
        radio setupnearbyspawns();
        radio createradiospawninfluencer();
    }

    if ( maperrors.size > 0 )
    {
/#
        println( "^1------------ Map Errors ------------" );

        for ( i = 0; i < maperrors.size; i++ )
            println( maperrors[i] );

        println( "^1------------------------------------" );
        maps\mp\_utility::error( "Map errors. See above" );
#/
        maps\mp\gametypes\_callbacksetup::abortlevel();
        return;
    }

    level.radios = radios;
    level.prevradio = undefined;
    level.prevradio2 = undefined;
    return 1;
}

setupnearbyspawns()
{
    spawns = level.spawn_all;

    for ( i = 0; i < spawns.size; i++ )
        spawns[i].distsq = distancesquared( spawns[i].origin, self.origin );

    for ( i = 1; i < spawns.size; i++ )
    {
        thespawn = spawns[i];

        for ( j = i - 1; j >= 0 && thespawn.distsq < spawns[j].distsq; j-- )
            spawns[j + 1] = spawns[j];

        spawns[j + 1] = thespawn;
    }

    first = [];
    second = [];
    third = [];
    outer = [];
    thirdsize = spawns.size / 3;

    for ( i = 0; i <= thirdsize; i++ )
        first[first.size] = spawns[i];

    while ( i < spawns.size )
    {
        outer[outer.size] = spawns[i];

        if ( i <= thirdsize * 2 )
            second[second.size] = spawns[i];
        else
            third[third.size] = spawns[i];

        i++;
    }

    self.gameobject.nearspawns = first;
    self.gameobject.midspawns = second;
    self.gameobject.farspawns = third;
    self.gameobject.outerspawns = outer;
}

setupnodes()
{
    self.nodes = [];
    temp = spawn( "script_model", ( 0, 0, 0 ) );
    maxs = self.trig getpointinbounds( 1, 1, 1 );
    self.node_radius = distance( self.trig.origin, maxs );
    nodes = getnodesinradius( self.trig.origin, self.node_radius, 0, self.node_radius );

    foreach ( node in nodes )
    {
        temp.origin = node.origin;

        if ( temp istouching( self.trig ) )
            self.nodes[self.nodes.size] = node;
    }

/#
    assert( self.nodes.size );
#/
    temp delete();
}

getfirstradio()
{
    radio = level.radios[0];
    level.prevradio2 = level.prevradio;
    level.prevradio = radio;
    level.prevradioindex = 0;
    shuffleradios();
    arrayremovevalue( level.radiospawnqueue, radio );
    return radio;
}

getnextradio()
{
    nextradioindex = ( level.prevradioindex + 1 ) % level.radios.size;
    radio = level.radios[nextradioindex];
    level.prevradio2 = level.prevradio;
    level.prevradio = radio;
    level.prevradioindex = nextradioindex;
    return radio;
}

pickrandomradiotospawn()
{
    level.prevradioindex = randomint( level.radios.size );
    radio = level.radios[level.prevradioindex];
    level.prevradio2 = level.prevradio;
    level.prevradio = radio;
    return radio;
}

shuffleradios()
{
    level.radiospawnqueue = [];
    spawnqueue = arraycopy( level.radios );

    for ( total_left = spawnqueue.size; total_left > 0; total_left-- )
    {
        index = randomint( total_left );
        valid_radios = 0;

        for ( radio = 0; radio < level.radios.size; radio++ )
        {
            if ( !isdefined( spawnqueue[radio] ) )
                continue;

            if ( valid_radios == index )
            {
                if ( level.radiospawnqueue.size == 0 && isdefined( level.radio ) && level.radio == spawnqueue[radio] )
                    continue;

                level.radiospawnqueue[level.radiospawnqueue.size] = spawnqueue[radio];
                spawnqueue[radio] = undefined;
                break;
            }

            valid_radios++;
        }
    }
}

getnextradiofromqueue()
{
    if ( level.radiospawnqueue.size == 0 )
        shuffleradios();

/#
    assert( level.radiospawnqueue.size > 0 );
#/
    next_radio = level.radiospawnqueue[0];
    arrayremoveindex( level.radiospawnqueue, 0 );
    return next_radio;
}

getcountofteamswithplayers( num )
{
    has_players = 0;

    foreach ( team in level.teams )
    {
        if ( num[team] > 0 )
            has_players++;
    }

    return has_players;
}

getpointcost( avgpos, origin )
{
    avg_distance = 0;
    total_error = 0;
    distances = [];

    foreach ( team, position in avgpos )
    {
        distances[team] = distance( origin, avgpos[team] );
        avg_distance += distances[team];
    }

    avg_distance /= distances.size;

    foreach ( team, dist in distances )
    {
        err = distances[team] - avg_distance;
        total_error += err * err;
    }

    return total_error;
}

pickradiotospawn()
{
    foreach ( team in level.teams )
    {
        avgpos[team] = ( 0, 0, 0 );
        num[team] = 0;
    }

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( isalive( player ) )
        {
            avgpos[player.pers["team"]] += player.origin;
            num[player.pers["team"]]++;
        }
    }

    if ( getcountofteamswithplayers( num ) <= 1 )
    {
        for ( radio = level.radios[randomint( level.radios.size )]; isdefined( level.prevradio ) && radio == level.prevradio; radio = level.radios[randomint( level.radios.size )] )
        {

        }

        level.prevradio2 = level.prevradio;
        level.prevradio = radio;
        return radio;
    }

    foreach ( team in level.teams )
    {
        if ( num[team] == 0 )
        {
            avgpos[team] = undefined;
            continue;
        }

        avgpos[team] /= num[team];
    }

    bestradio = undefined;
    lowestcost = undefined;

    for ( i = 0; i < level.radios.size; i++ )
    {
        radio = level.radios[i];
        cost = getpointcost( avgpos, radio.origin );

        if ( isdefined( level.prevradio ) && radio == level.prevradio )
            continue;

        if ( isdefined( level.prevradio2 ) && radio == level.prevradio2 )
        {
            if ( level.radios.size > 2 )
                continue;
            else
                cost += 262144;
        }

        if ( !isdefined( lowestcost ) || cost < lowestcost )
        {
            lowestcost = cost;
            bestradio = radio;
        }
    }

/#
    assert( isdefined( bestradio ) );
#/
    level.prevradio2 = level.prevradio;
    level.prevradio = bestradio;
    return bestradio;
}

onroundswitch()
{
    game["switchedsides"] = !game["switchedsides"];
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( !isplayer( attacker ) || !self.touchtriggers.size && !attacker.touchtriggers.size || attacker.pers["team"] == self.pers["team"] )
        return;

    medalgiven = 0;
    scoreeventprocessed = 0;

    if ( attacker.touchtriggers.size )
    {
        triggerids = getarraykeys( attacker.touchtriggers );
        ownerteam = attacker.touchtriggers[triggerids[0]].useobj.ownerteam;
        team = attacker.pers["team"];

        if ( team == ownerteam || ownerteam == "neutral" )
        {
            if ( !medalgiven )
            {
                if ( isdefined( attacker.pers["defends"] ) )
                {
                    attacker.pers["defends"]++;
                    attacker.defends = attacker.pers["defends"];
                }

                attacker maps\mp\_medals::defenseglobalcount();
                medalgiven = 1;
                attacker addplayerstatwithgametype( "DEFENDS", 1 );
                attacker recordgameevent( "return" );
            }

            attacker maps\mp\_challenges::killedzoneattacker( sweapon );

            if ( team != ownerteam )
                maps\mp\_scoreevents::processscoreevent( "kill_enemy_while_capping_hq", attacker, undefined, sweapon );
            else
                maps\mp\_scoreevents::processscoreevent( "killed_attacker", attacker, undefined, sweapon );

            self recordkillmodifier( "assaulting" );
            scoreeventprocessed = 1;
        }
        else
        {
            if ( !medalgiven )
            {
                attacker maps\mp\_medals::offenseglobalcount();
                medalgiven = 1;
                attacker addplayerstatwithgametype( "OFFENDS", 1 );
            }

            maps\mp\_scoreevents::processscoreevent( "kill_enemy_while_capping_hq", attacker, undefined, sweapon );
            self recordkillmodifier( "defending" );
            scoreeventprocessed = 1;
        }
    }

    if ( self.touchtriggers.size )
    {
        triggerids = getarraykeys( self.touchtriggers );
        ownerteam = self.touchtriggers[triggerids[0]].useobj.ownerteam;
        team = self.pers["team"];

        if ( team == ownerteam )
        {
            if ( !medalgiven )
            {
                attacker maps\mp\_medals::offenseglobalcount();
                attacker addplayerstatwithgametype( "OFFENDS", 1 );
                medalgiven = 1;
            }

            if ( !scoreeventprocessed )
            {
                maps\mp\_scoreevents::processscoreevent( "killed_defender", attacker, undefined, sweapon );
                self recordkillmodifier( "defending" );
                scoreeventprocessed = 1;
            }
        }
        else
        {
            if ( !medalgiven )
            {
                if ( isdefined( attacker.pers["defends"] ) )
                {
                    attacker.pers["defends"]++;
                    attacker.defends = attacker.pers["defends"];
                }

                attacker maps\mp\_medals::defenseglobalcount();
                medalgiven = 1;
                attacker addplayerstatwithgametype( "DEFENDS", 1 );
                attacker recordgameevent( "return" );
            }

            if ( !scoreeventprocessed )
            {
                attacker maps\mp\_challenges::killedzoneattacker( sweapon );
                maps\mp\_scoreevents::processscoreevent( "killed_attacker", attacker, undefined, sweapon );
                self recordkillmodifier( "assaulting" );
                scoreeventprocessed = 1;
            }
        }

        if ( scoreeventprocessed == 1 )
            attacker killwhilecontesting( self.touchtriggers[triggerids[0]].useobj );
    }
}

killwhilecontesting( radio )
{
    self notify( "killWhileContesting" );
    self endon( "killWhileContesting" );
    self endon( "disconnect" );
    killtime = gettime();
    playerteam = self.pers["team"];

    if ( !isdefined( self.clearenemycount ) )
        self.clearenemycount = 0;

    self.clearenemycount++;

    radio waittill( "state_change" );

    if ( playerteam != self.pers["team"] || isdefined( self.spawntime ) && killtime < self.spawntime )
    {
        self.clearenemycount = 0;
        return;
    }

    if ( radio.ownerteam != playerteam && radio.ownerteam != "neutral" )
    {
        self.clearenemycount = 0;
        return;
    }

    if ( self.clearenemycount >= 2 && killtime + 200 > gettime() )
        maps\mp\_scoreevents::processscoreevent( "clear_2_attackers", self );

    self.clearenemycount = 0;
}

onendgame( winningteam )
{
    for ( i = 0; i < level.radios.size; i++ )
        level.radios[i].gameobject maps\mp\gametypes\_gameobjects::allowuse( "none" );
}

createradiospawninfluencer()
{
    hq_objective_influencer_score = level.spawnsystem.hq_objective_influencer_score;
    hq_objective_influencer_score_curve = level.spawnsystem.hq_objective_influencer_score_curve;
    hq_objective_influencer_radius = level.spawnsystem.hq_objective_influencer_radius;
    hq_objective_influencer_inner_score = level.spawnsystem.hq_objective_influencer_inner_score;
    hq_objective_influencer_inner_score_curve = level.spawnsystem.hq_objective_influencer_inner_score_curve;
    hq_objective_influencer_inner_radius = level.spawnsystem.hq_objective_influencer_inner_radius;
    self.spawn_influencer = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.gameobject.curorigin, hq_objective_influencer_radius, hq_objective_influencer_score, 0, "hq_objective,r,s", maps\mp\gametypes\_spawning::get_score_curve_index( hq_objective_influencer_score_curve ) );
    self.spawn_influencer_inner = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.gameobject.curorigin, hq_objective_influencer_inner_radius, hq_objective_influencer_inner_score, 0, "hq_objective_inner,r,s", maps\mp\gametypes\_spawning::get_score_curve_index( hq_objective_influencer_inner_score_curve ) );
    self enable_radio_spawn_influencer( 0 );
}

enable_radio_spawn_influencer( enabled )
{
    if ( isdefined( self.spawn_influencer ) )
    {
        enableinfluencer( self.spawn_influencer, enabled );
        enableinfluencer( self.spawn_influencer_inner, enabled );
    }
}

koth_gamemodespawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.hq_objective_influencer_score = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_score", "200", reset_dvars );
    ss.hq_objective_influencer_score_curve = set_dvar_if_unset( "scr_spawn_hq_objective_influencer_score_curve", "linear", reset_dvars );
    ss.hq_objective_influencer_radius = 4000;
    ss.hq_objective_influencer_inner_score = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_score", "-600", reset_dvars );
    ss.hq_objective_influencer_inner_score_curve = "constant";
    ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "2000", reset_dvars );
    ss.hq_initial_spawns_influencer_score = set_dvar_float_if_unset( "scr_spawn_hq_initial_spawns_influencer_score", "200", reset_dvars );
    ss.hq_initial_spawns_influencer_score_curve = set_dvar_if_unset( "scr_spawn_hq_initial_spawns_influencer_score_curve", "linear", reset_dvars );
    ss.hq_initial_spawns_influencer_radius = set_dvar_float_if_unset( "scr_spawn_hq_initial_spawns_influencer_radius", "" + 10.0 * get_player_height(), reset_dvars );
}

onupdateuserate()
{
    if ( !isdefined( self.currentcontendercount ) )
        self.currentcontendercount = 0;

    numothers = getnumtouchingexceptteam( self.ownerteam );
    numowners = self.numtouching[self.ownerteam];
    previousstate = self.currentcontendercount;

    if ( numothers == 0 && numowners == 0 )
        self.currentcontendercount = 0;
    else if ( self.ownerteam == "neutral" )
    {
        numotherclaim = getnumtouchingexceptteam( self.claimteam );

        if ( numotherclaim > 0 )
            self.currentcontendercount = 2;
        else
            self.currentcontendercount = 1;
    }
    else if ( numothers > 0 )
        self.currentcontendercount = 1;
    else
        self.currentcontendercount = 0;

    if ( self.currentcontendercount != previousstate )
        self notify( "state_change" );
}
