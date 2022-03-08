// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_tweakables;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\gametypes\_battlechatter_mp;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_weapons;
#include maps\mp\_scoreevents;
#include maps\mp\killstreaks\_supplydrop;
#include maps\mp\gametypes\_dev;

init()
{
    precachemodel( "german_shepherd_vest" );
    precachemodel( "german_shepherd_vest_black" );
    level.dog_targets = [];
    level.dog_targets[level.dog_targets.size] = "trigger_radius";
    level.dog_targets[level.dog_targets.size] = "trigger_multiple";
    level.dog_targets[level.dog_targets.size] = "trigger_use_touch";
/#
    level thread devgui_dog_think();
#/
}

initkillstreak()
{
    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "killstreak", "allowdogs" ) )
    {
        maps\mp\killstreaks\_killstreaks::registerkillstreak( "dogs_mp", "dogs_mp", "killstreak_dogs", "dogs_used", ::usekillstreakdogs, 1 );
        maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "dogs_mp", &"KILLSTREAK_EARNED_DOGS", &"KILLSTREAK_DOGS_NOT_AVAILABLE", &"KILLSTREAK_DOGS_INBOUND" );
        maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "dogs_mp", "mpl_killstreak_dogs", "kls_dogs_used", "", "kls_dogs_enemy", "", "kls_dogs_ready" );
        maps\mp\killstreaks\_killstreaks::registerkillstreakdevdvar( "dogs_mp", "scr_givedogs" );
        maps\mp\killstreaks\_killstreaks::setkillstreakteamkillpenaltyscale( "dogs_mp", 0.0 );
        maps\mp\killstreaks\_killstreaks::registerkillstreakaltweapon( "dogs_mp", "dog_bite_mp" );
    }
}

usekillstreakdogs( hardpointtype )
{
    if ( !dog_killstreak_init() )
        return false;

    if ( !self maps\mp\killstreaks\_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) )
        return false;

    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( "dogs_mp", self.team );
    self thread ownerhadactivedogs();

    if ( killstreak_id == -1 )
        return false;

    if ( level.teambased )
    {
        foreach ( team in level.teams )
        {
            if ( team == self.team )
                continue;

            thread maps\mp\gametypes\_battlechatter_mp::onkillstreakused( "dogs", team );
        }
    }

    self maps\mp\killstreaks\_killstreaks::playkillstreakstartdialog( "dogs_mp", self.team, 1 );
    level.globalkillstreakscalled++;
    self addweaponstat( "dogs_mp", "used", 1 );
    ownerdeathcount = self.deathcount;
    level thread dog_manager_spawn_dogs( self, ownerdeathcount, killstreak_id );
    level notify( "called_in_the_dogs" );
    return true;
}

ownerhadactivedogs()
{
    self endon( "disconnect" );
    self.dogsactive = 1;
    self.dogsactivekillstreak = 0;
    self waittill_any( "death", "game_over", "dogs_complete" );
    self.dogsactivekillstreak = 0;
    self.dogsactive = undefined;
}

dog_killstreak_init()
{
    dog_spawner = getent( "dog_spawner", "targetname" );

    if ( !isdefined( dog_spawner ) )
    {
/#
        println( "No dog spawners found in map" );
#/
        return false;
    }

    spawns = getnodearray( "spawn", "script_noteworthy" );

    if ( spawns.size <= 0 )
    {
/#
        println( "No dog spawn nodes found in map" );
#/
        return false;
    }

    exits = getnodearray( "exit", "script_noteworthy" );

    if ( exits.size <= 0 )
    {
/#
        println( "No dog exit nodes found in map" );
#/
        return false;
    }

    return true;
}

dog_set_model()
{
    self setmodel( "german_shepherd_vest" );
    self setenemymodel( "german_shepherd_vest_black" );
}

init_dog()
{
/#
    assert( isai( self ) );
#/
    self.targetname = "attack_dog";
    self.animtree = "dog.atr";
    self.type = "dog";
    self.accuracy = 0.2;
    self.health = 100;
    self.maxhealth = 100;
    self.aiweapon = "dog_bite_mp";
    self.secondaryweapon = "";
    self.sidearm = "";
    self.grenadeammo = 0;
    self.goalradius = 128;
    self.nododgemove = 1;
    self.ignoresuppression = 1;
    self.suppressionthreshold = 1;
    self.disablearrivals = 0;
    self.pathenemyfightdist = 512;
    self.soundmod = "dog";
    self.meleeattackdist = 90;
    self thread dog_health_regen();
    self thread selfdefensechallenge();
}

get_spawn_node( owner, team )
{
    spawns = getnodearray( "spawn", "script_noteworthy" );
    return spawns[randomint( spawns.size )];
}

get_score_for_spawn( origin, team )
{
    players = get_players();
    score = 0;

    foreach ( player in players )
    {
        if ( !isdefined( player ) )
            continue;

        if ( !isalive( player ) )
            continue;

        if ( player.sessionstate != "playing" )
            continue;

        if ( distancesquared( player.origin, origin ) > 4194304 )
            continue;

        if ( player.team == team )
        {
            score++;
            continue;
        }

        score--;
    }

    return score;
}

dog_set_owner( owner, team, requireddeathcount )
{
    self setentityowner( owner );
    self.aiteam = team;
    self.requireddeathcount = requireddeathcount;
}

dog_create_spawn_influencer()
{
    self maps\mp\gametypes\_spawning::create_dog_influencers();
}

dog_manager_spawn_dog( owner, team, spawn_node, requireddeathcount )
{
    dog_spawner = getent( "dog_spawner", "targetname" );
    dog = dog_spawner spawnactor();
    dog forceteleport( spawn_node.origin, spawn_node.angles );
    dog init_dog();
    dog dog_set_owner( owner, team, requireddeathcount );
    dog dog_set_model();
    dog dog_create_spawn_influencer();
    dog thread dog_owner_kills();
    dog thread dog_notify_level_on_death();
    dog thread dog_patrol();
    dog thread maps\mp\gametypes\_weapons::monitor_dog_special_grenades();
    return dog;
}

dog_manager_spawn_dogs( owner, deathcount, killstreak_id )
{
    requireddeathcount = deathcount;
    team = owner.team;
    level.dog_abort = 0;
    owner thread dog_manager_abort();
    level thread dog_manager_game_ended();
    count = 0;

    while ( count < 10 )
    {
        if ( level.dog_abort )
            break;

        for ( dogs = dog_manager_get_dogs(); dogs.size < 5 && count < 10 && !level.dog_abort; dogs = dog_manager_get_dogs() )
        {
            node = get_spawn_node( owner, team );
            level dog_manager_spawn_dog( owner, team, node, requireddeathcount );
            count++;
            wait( randomfloatrange( 2, 5 ) );
        }

        level waittill( "dog_died" );
    }

    for (;;)
    {
        dogs = dog_manager_get_dogs();

        if ( dogs.size <= 0 )
        {
            maps\mp\killstreaks\_killstreakrules::killstreakstop( "dogs_mp", team, killstreak_id );

            if ( isdefined( owner ) )
                owner notify( "dogs_complete" );

            return;
        }

        level waittill( "dog_died" );
    }
}

dog_abort()
{
    level.dog_abort = 1;
    dogs = dog_manager_get_dogs();

    foreach ( dog in dogs )
        dog notify( "abort" );

    level notify( "dog_abort" );
}

dog_manager_abort()
{
    level endon( "dog_abort" );
    self wait_endon( 50, "disconnect", "joined_team", "joined_specators" );
    dog_abort();
}

dog_manager_game_ended()
{
    level endon( "dog_abort" );

    level waittill( "game_ended" );

    dog_abort();
}

dog_notify_level_on_death()
{
    self waittill( "death" );

    level notify( "dog_died" );
}

dog_leave()
{
    self clearentitytarget();
    self.ignoreall = 1;
    self.goalradius = 30;
    self setgoalnode( self dog_get_exit_node() );
    self wait_endon( 20, "goal", "bad_path" );
    self delete();
}

dog_patrol()
{
    self endon( "death" );
/#
    self endon( "debug_patrol" );
#/
    for (;;)
    {
        if ( level.dog_abort )
        {
            self dog_leave();
            return;
        }

        if ( isdefined( self.enemy ) )
        {
            wait( randomintrange( 3, 5 ) );
            continue;
        }

        nodes = [];
        objectives = dog_patrol_near_objective();

        for ( i = 0; i < objectives.size; i++ )
        {
            objective = random( objectives );
            nodes = getnodesinradius( objective.origin, 256, 64, 512, "Path", 16 );

            if ( nodes.size )
                break;
        }

        if ( !nodes.size )
        {
            player = self dog_patrol_near_enemy();

            if ( isdefined( player ) )
                nodes = getnodesinradius( player.origin, 1024, 0, 128, "Path", 8 );
        }

        if ( !nodes.size && isdefined( self.script_owner ) )
        {
            if ( isalive( self.script_owner ) && self.script_owner.sessionstate == "playing" )
                nodes = getnodesinradius( self.script_owner.origin, 512, 256, 512, "Path", 16 );
        }

        if ( !nodes.size )
            nodes = getnodesinradius( self.origin, 1024, 512, 512, "Path" );

        if ( nodes.size )
        {
            nodes = array_randomize( nodes );

            foreach ( node in nodes )
            {
                if ( isdefined( node.script_noteworthy ) )
                    continue;

                if ( isdefined( node.dog_claimed ) && isalive( node.dog_claimed ) )
                    continue;

                self setgoalnode( node );
                node.dog_claimed = self;
                nodes = [];
                event = self waittill_any_return( "goal", "bad_path", "enemy", "abort" );

                if ( event == "goal" )
                    wait_endon( randomintrange( 3, 5 ), "damage", "enemy", "abort" );

                node.dog_claimed = undefined;
                break;
            }
        }

        wait 0.5;
    }
}

dog_patrol_near_objective()
{
    if ( !isdefined( level.dog_objectives ) )
    {
        level.dog_objectives = [];
        level.dog_objective_next_update = 0;
    }

    if ( level.gametype == "tdm" || level.gametype == "dm" )
        return level.dog_objectives;

    if ( gettime() >= level.dog_objective_next_update )
    {
        level.dog_objectives = [];

        foreach ( target in level.dog_targets )
        {
            ents = getentarray( target, "classname" );

            foreach ( ent in ents )
            {
                if ( level.gametype == "koth" )
                {
                    if ( isdefined( ent.targetname ) && ent.targetname == "radiotrigger" )
                        level.dog_objectives[level.dog_objectives.size] = ent;

                    continue;
                }

                if ( level.gametype == "sd" )
                {
                    if ( isdefined( ent.targetname ) && ent.targetname == "bombzone" )
                        level.dog_objectives[level.dog_objectives.size] = ent;

                    continue;
                }

                if ( !isdefined( ent.script_gameobjectname ) )
                    continue;

                if ( !issubstr( ent.script_gameobjectname, level.gametype ) )
                    continue;

                level.dog_objectives[level.dog_objectives.size] = ent;
            }
        }

        level.dog_objective_next_update = gettime() + randomintrange( 5000, 10000 );
    }

    return level.dog_objectives;
}

dog_patrol_near_enemy()
{
    players = get_players();
    closest = undefined;
    distsq = 99999999;

    foreach ( player in players )
    {
        if ( !isdefined( player ) )
            continue;

        if ( !isalive( player ) )
            continue;

        if ( player.sessionstate != "playing" )
            continue;

        if ( isdefined( self.script_owner ) && player == self.script_owner )
            continue;

        if ( level.teambased )
        {
            if ( player.team == self.aiteam )
                continue;
        }

        if ( gettime() - player.lastfiretime > 3000 )
            continue;

        if ( !isdefined( closest ) )
        {
            closest = player;
            distsq = distancesquared( self.origin, player.origin );
            continue;
        }

        d = distancesquared( self.origin, player.origin );

        if ( d < distsq )
        {
            closest = player;
            distsq = d;
        }
    }

    return closest;
}

dog_manager_get_dogs()
{
    dogs = getentarray( "attack_dog", "targetname" );
    return dogs;
}

dog_owner_kills()
{
    if ( !isdefined( self.script_owner ) )
        return;

    self endon( "clear_owner" );
    self endon( "death" );
    self.script_owner endon( "disconnect" );

    while ( true )
    {
        self waittill( "killed", player );

        self.script_owner notify( "dog_handler" );
    }
}

dog_health_regen()
{
    self endon( "death" );
    interval = 0.5;
    regen_interval = int( self.health / 5 * interval );
    regen_start = 2;

    for (;;)
    {
        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        self trackattackerdamage( attacker, weaponname );
        self thread dog_health_regen_think( regen_start, interval, regen_interval );
    }
}

trackattackerdamage( attacker, weapon )
{
    if ( !isdefined( attacker ) || !isplayer( attacker ) || !isdefined( self.script_owner ) )
        return;

    if ( level.teambased && attacker.team == self.script_owner.team || attacker == self )
        return;

    if ( !isdefined( self.attackerdata ) || !isdefined( self.attackers ) )
    {
        self.attackerdata = [];
        self.attackers = [];
    }

    if ( !isdefined( self.attackerdata[attacker.clientid] ) )
    {
        self.attackerclientid[attacker.clientid] = spawnstruct();
        self.attackers[self.attackers.size] = attacker;
    }
}

resetattackerdamage()
{
    self.attackerdata = [];
    self.attackers = [];
}

dog_health_regen_think( delay, interval, regen_interval )
{
    self endon( "death" );
    self endon( "damage" );
    wait( delay );

    for ( step = 0; step <= 5; step += interval )
    {
        if ( self.health >= 100 )
            break;

        self.health += regen_interval;
        wait( interval );
    }

    self resetattackerdamage();
    self.health = 100;
}

selfdefensechallenge()
{
    self waittill( "death", attacker );

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( isdefined( self.script_owner ) && self.script_owner == attacker )
            return;

        if ( level.teambased && isdefined( self.script_owner ) && self.script_owner.team == attacker.team )
            return;

        if ( isdefined( self.attackers ) )
        {
            foreach ( player in self.attackers )
            {
                if ( player != attacker )
                    maps\mp\_scoreevents::processscoreevent( "killed_dog_assist", player );
            }
        }

        attacker notify( "selfdefense_dog" );
    }
}

dog_get_exit_node()
{
    exits = getnodearray( "exit", "script_noteworthy" );
    return getclosest( self.origin, exits );
}

flash_dogs( area )
{
    self endon( "disconnect" );
    dogs = dog_manager_get_dogs();

    foreach ( dog in dogs )
    {
        if ( !isalive( dog ) )
            continue;

        if ( dog istouching( area ) )
        {
            do_flash = 1;

            if ( isplayer( self ) )
            {
                if ( level.teambased && dog.aiteam == self.team )
                    do_flash = 0;
                else if ( !level.teambased && isdefined( dog.script_owner ) && self == dog.script_owner )
                    do_flash = 0;
            }

            if ( isdefined( dog.lastflashed ) && dog.lastflashed + 1500 > gettime() )
                do_flash = 0;

            if ( do_flash )
            {
                dog setflashbanged( 1, 500 );
                dog.lastflashed = gettime();
            }
        }
    }
}

devgui_dog_think()
{
/#
    setdvar( "devgui_dog", "" );
    debug_patrol = 0;

    for (;;)
    {
        cmd = getdvar( "devgui_dog" );

        switch ( cmd )
        {
            case "spawn_friendly":
                player = gethostplayer();
                devgui_dog_spawn( player.team );
                break;
            case "spawn_enemy":
                player = gethostplayer();

                foreach ( team in level.teams )
                {
                    if ( team == player.team )
                        continue;

                    devgui_dog_spawn( team );
                }

                break;
            case "delete_dogs":
                level dog_abort();
                break;
            case "dog_camera":
                devgui_dog_camera();
                break;
            case "spawn_crate":
                devgui_crate_spawn();
                break;
            case "delete_crates":
                devgui_crate_delete();
                break;
            case "show_spawns":
                devgui_spawn_show();
                break;
            case "show_exits":
                devgui_exit_show();
                break;
            case "debug_route":
                devgui_debug_route();
                break;
        }

        if ( cmd != "" )
            setdvar( "devgui_dog", "" );

        wait 0.5;
    }
#/
}

devgui_dog_spawn( team )
{
/#
    player = gethostplayer();
    dog_spawner = getent( "dog_spawner", "targetname" );
    level.dog_abort = 0;

    if ( !isdefined( dog_spawner ) )
    {
        iprintln( "No dog spawners found in map" );
        return;
    }

    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    nodes = getnodesinradius( trace["position"], 256, 0, 128, "Path", 8 );

    if ( !nodes.size )
    {
        iprintln( "No nodes found near crosshair position" );
        return;
    }

    iprintln( "Spawning dog at your crosshair position" );
    node = getclosest( trace["position"], nodes );
    dog = dog_manager_spawn_dog( player, player.team, node, 5 );

    if ( team != player.team )
    {
        dog.aiteam = team;
        dog clearentityowner();
        dog notify( "clear_owner" );
    }
#/
}

devgui_dog_camera()
{
/#
    player = gethostplayer();

    if ( !isdefined( level.devgui_dog_camera ) )
        level.devgui_dog_camera = 0;

    dog = undefined;
    dogs = dog_manager_get_dogs();

    if ( dogs.size <= 0 )
    {
        level.devgui_dog_camera = undefined;
        player cameraactivate( 0 );
        return;
    }

    for ( i = 0; i < dogs.size; i++ )
    {
        dog = dogs[i];

        if ( !isdefined( dog ) || !isalive( dog ) )
        {
            dog = undefined;
            continue;
        }

        if ( !isdefined( dog.cam ) )
        {
            forward = anglestoforward( dog.angles );
            dog.cam = spawn( "script_model", dog.origin + vectorscale( ( 0, 0, 1 ), 50.0 ) + forward * -100 );
            dog.cam setmodel( "tag_origin" );
            dog.cam linkto( dog );
        }

        if ( dog getentitynumber() <= level.devgui_dog_camera )
        {
            dog = undefined;
            continue;
        }

        break;
    }

    if ( isdefined( dog ) )
    {
        level.devgui_dog_camera = dog getentitynumber();
        player camerasetposition( dog.cam );
        player camerasetlookat( dog );
        player cameraactivate( 1 );
    }
    else
    {
        level.devgui_dog_camera = undefined;
        player cameraactivate( 0 );
    }
#/
}

devgui_crate_spawn()
{
/#
    player = gethostplayer();
    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    killcament = spawn( "script_model", player.origin );
    level thread maps\mp\killstreaks\_supplydrop::dropcrate( trace["position"] + vectorscale( ( 0, 0, 1 ), 25.0 ), direction, "supplydrop_mp", player, player.team, killcament );
#/
}

devgui_crate_delete()
{
/#
    if ( !isdefined( level.devgui_crates ) )
        return;

    for ( i = 0; i < level.devgui_crates.size; i++ )
        level.devgui_crates[i] delete();

    level.devgui_crates = [];
#/
}

devgui_spawn_show()
{
/#
    if ( !isdefined( level.dog_spawn_show ) )
        level.dog_spawn_show = 1;
    else
        level.dog_spawn_show = !level.dog_spawn_show;

    if ( !level.dog_spawn_show )
    {
        level notify( "hide_dog_spawns" );
        return;
    }

    spawns = getnodearray( "spawn", "script_noteworthy" );
    color = ( 0, 1, 0 );

    for ( i = 0; i < spawns.size; i++ )
        maps\mp\gametypes\_dev::showonespawnpoint( spawns[i], color, "hide_dog_spawns", 32, "dog_spawn" );
#/
}

devgui_exit_show()
{
/#
    if ( !isdefined( level.dog_exit_show ) )
        level.dog_exit_show = 1;
    else
        level.dog_exit_show = !level.dog_exit_show;

    if ( !level.dog_exit_show )
    {
        level notify( "hide_dog_exits" );
        return;
    }

    exits = getnodearray( "exit", "script_noteworthy" );
    color = ( 1, 0, 0 );

    for ( i = 0; i < exits.size; i++ )
        maps\mp\gametypes\_dev::showonespawnpoint( exits[i], color, "hide_dog_exits", 32, "dog_exit" );
#/
}

dog_debug_patrol( node1, node2 )
{
/#
    self endon( "death" );
    self endon( "debug_patrol" );

    for (;;)
    {
        self setgoalnode( node1 );
        self waittill_any( "goal", "bad_path" );
        wait 1;
        self setgoalnode( node2 );
        self waittill_any( "goal", "bad_path" );
        wait 1;
    }
#/
}

devgui_debug_route()
{
/#
    iprintln( "Choose nodes with 'A' or press 'B' to cancel" );
    nodes = maps\mp\gametypes\_dev::dev_get_node_pair();

    if ( !isdefined( nodes ) )
    {
        iprintln( "Route Debug Cancelled" );
        return;
    }

    iprintln( "Sending dog to chosen nodes" );
    dogs = dog_manager_get_dogs();

    if ( isdefined( dogs[0] ) )
    {
        dogs[0] notify( "debug_patrol" );
        dogs[0] thread dog_debug_patrol( nodes[0], nodes[1] );
    }
#/
}
