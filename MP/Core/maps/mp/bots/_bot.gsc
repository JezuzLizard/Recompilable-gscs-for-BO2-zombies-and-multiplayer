// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot_loadout;
#include maps\mp\bots\_bot_combat;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_weapons;
#include maps\mp\teams\_teams;
#include maps\mp\killstreaks\_radar;
#include maps\mp\bots\_bot;
#include maps\mp\bots\_bot_ctf;
#include maps\mp\bots\_bot_dem;
#include maps\mp\bots\_bot_dom;
#include maps\mp\bots\_bot_koth;
#include maps\mp\bots\_bot_hq;
#include maps\mp\bots\_bot_conf;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\gametypes\_dev;

init()
{
/#
    level thread bot_system_devgui_think();
#/
    level thread maps\mp\bots\_bot_loadout::init();

    if ( !bot_gametype_allowed() )
        return;

    if ( level.rankedmatch && !is_bot_ranked_match() )
        return;

    bot_friends = getdvarint( "bot_friends" );
    bot_enemies = getdvarint( "bot_enemies" );

    if ( bot_friends <= 0 && bot_enemies <= 0 )
        return;

    bot_wait_for_host();
    bot_set_difficulty();

    if ( is_bot_comp_stomp() )
    {
        team = bot_choose_comp_stomp_team();
        level thread bot_comp_stomp_think( team );
    }
    else if ( is_bot_ranked_match() )
        level thread bot_ranked_think();
    else
        level thread bot_local_think();
}

spawn_bot( team )
{
    bot = addtestclient();

    if ( isdefined( bot ) )
    {
        bot.pers["isBot"] = 1;

        if ( team != "autoassign" )
            bot.pers["team"] = team;

        bot thread bot_spawn_think( team );
        return true;
    }

    return false;
}

getenemyteamwithlowestplayercount( player_team )
{
    counts = [];

    foreach ( team in level.teams )
        counts[team] = 0;

    foreach ( player in level.players )
    {
        if ( !isdefined( player.team ) )
            continue;

        if ( !isdefined( counts[player.team] ) )
            continue;

        counts[player.team]++;
    }

    count = 999999;
    enemy_team = player_team;

    foreach ( team in level.teams )
    {
        if ( team == player_team )
            continue;

        if ( team == "spectator" )
            continue;

        if ( counts[team] < count )
        {
            enemy_team = team;
            count = counts[team];
        }
    }

    return enemy_team;
}

getenemyteamwithgreatestbotcount( player_team )
{
    counts = [];

    foreach ( team in level.teams )
        counts[team] = 0;

    foreach ( player in level.players )
    {
        if ( !isdefined( player.team ) )
            continue;

        if ( !isdefined( counts[player.team] ) )
            continue;

        if ( !player is_bot() )
            continue;

        counts[player.team]++;
    }

    count = -1;
    enemy_team = undefined;

    foreach ( team in level.teams )
    {
        if ( team == player_team )
            continue;

        if ( team == "spectator" )
            continue;

        if ( counts[team] > count )
        {
            enemy_team = team;
            count = counts[team];
        }
    }

    return enemy_team;
}

bot_wait_for_host()
{
    for ( host = gethostplayerforbots(); !isdefined( host ); host = gethostplayerforbots() )
        wait 0.25;

    if ( level.prematchperiod > 0 && level.inprematchperiod == 1 )
        wait 1;
}

bot_count_humans( team )
{
    players = get_players();
    count = 0;

    foreach ( player in players )
    {
        if ( player is_bot() )
            continue;

        if ( isdefined( team ) )
        {
            if ( getassignedteam( player ) == team )
                count++;

            continue;
        }

        count++;
    }

    return count;
}

bot_count_bots( team )
{
    players = get_players();
    count = 0;

    foreach ( player in players )
    {
        if ( !player is_bot() )
            continue;

        if ( isdefined( team ) )
        {
            if ( isdefined( player.team ) && player.team == team )
                count++;

            continue;
        }

        count++;
    }

    return count;
}

bot_count_enemy_bots( friend_team )
{
    if ( !level.teambased )
        return bot_count_bots();

    enemies = 0;

    foreach ( team in level.teams )
    {
        if ( team == friend_team )
            continue;

        enemies += bot_count_bots( team );
    }

    return enemies;
}

bot_choose_comp_stomp_team()
{
    host = gethostplayerforbots();
    assert( isdefined( host ) );
    teamkeys = getarraykeys( level.teams );
    assert( teamkeys.size == 2 );
    enemy_team = host.pers["team"];
    assert( isdefined( enemy_team ) && enemy_team != "spectator" );
    return getotherteam( enemy_team );
}

bot_comp_stomp_think( team )
{
    for (;;)
    {
        for (;;)
        {
            humans = bot_count_humans();
            bots = bot_count_bots();

            if ( humans == bots )
                break;

            if ( bots < humans )
                spawn_bot( team );

            if ( bots > humans )
                bot_comp_stomp_remove( team );

            wait 1;
        }

        wait 3;
    }
}

bot_comp_stomp_remove( team )
{
    players = get_players();
    bots = [];
    remove = undefined;

    foreach ( player in players )
    {
        if ( !isdefined( player.team ) )
            continue;

        if ( player is_bot() )
        {
            if ( level.teambased )
            {
                if ( player.team == team )
                    bots[bots.size] = player;

                continue;
            }

            bots[bots.size] = player;
        }
    }

    if ( !bots.size )
        return;

    foreach ( bot in bots )
    {
        if ( !bot maps\mp\bots\_bot_combat::bot_has_enemy() )
        {
            remove = bot;
            break;
        }
    }

    if ( !isdefined( remove ) )
        remove = random( bots );

    remove botleavegame();
}

bot_ranked_remove()
{
    if ( !level.teambased )
    {
        bot_comp_stomp_remove();
        return;
    }

    high = -1;
    highest_team = undefined;

    foreach ( team in level.teams )
    {
        count = countplayers( team );

        if ( count > high )
        {
            high = count;
            highest_team = team;
        }
    }

    bot_comp_stomp_remove( highest_team );
}

bot_ranked_count( team )
{
    count = countplayers( team );

    if ( count < 6 )
    {
        spawn_bot( team );
        return true;
    }
    else if ( count > 6 )
    {
        bot_comp_stomp_remove( team );
        return true;
    }

    return false;
}

bot_ranked_think()
{
    level endon( "game_ended" );
    wait 5;

    for (;;)
    {
        for (;;)
        {
            wait 1;
            teams = [];
            teams[0] = "axis";
            teams[1] = "allies";

            if ( cointoss() )
            {
                teams[0] = "allies";
                teams[1] = "axis";
            }

            if ( !bot_ranked_count( teams[0] ) && !bot_ranked_count( teams[1] ) )
                break;
        }

        level waittill_any( "connected", "disconnect" );
        wait 5;

        while ( isdefined( level.hostmigrationtimer ) )
            wait 1;
    }
}

bot_local_friends( expected_friends, max, host_team )
{
    if ( level.teambased )
    {
        players = get_players();
        friends = bot_count_bots( host_team );

        if ( friends < expected_friends && players.size < max )
        {
            spawn_bot( host_team );
            return true;
        }

        if ( friends > expected_friends )
        {
            bot_comp_stomp_remove( host_team );
            return true;
        }
    }

    return false;
}

bot_local_enemies( expected_enemies, max, host_team )
{
    enemies = bot_count_enemy_bots( host_team );
    players = get_players();

    if ( enemies < expected_enemies && players.size < max )
    {
        team = getenemyteamwithlowestplayercount( host_team );
        spawn_bot( team );
        return true;
    }

    if ( enemies > expected_enemies )
    {
        team = getenemyteamwithgreatestbotcount( host_team );

        if ( isdefined( team ) )
            bot_comp_stomp_remove( team );

        return true;
    }

    return false;
}

bot_local_think()
{
    wait 5;
    host = gethostplayerforbots();
    assert( isdefined( host ) );
    host_team = host.team;

    if ( !isdefined( host_team ) || host_team == "spectator" )
        host_team = "allies";

    bot_expected_friends = getdvarint( "bot_friends" );
    bot_expected_enemies = getdvarint( "bot_enemies" );
    max_players = islocalgame() ? 10 : 18;

    for (;;)
    {
        for (;;)
        {
            if ( bot_local_friends( bot_expected_friends, max_players, host_team ) )
            {
                wait 0.5;
                continue;
            }

            if ( bot_local_enemies( bot_expected_enemies, max_players, host_team ) )
            {
                wait 0.5;
                continue;
            }

            break;
        }

        wait 3;
    }
}

is_bot_ranked_match()
{
    bot_enemies = getdvarint( "bot_enemies" );
    isdedicatedbotsoak = getdvarint( _hash_E76315E0 );
    return level.rankedmatch && bot_enemies && 0 == isdedicatedbotsoak;
}

is_bot_comp_stomp()
{
    return is_bot_ranked_match() && !getdvarint( "party_autoteams" );
}

bot_spawn_think( team )
{
    self endon( "disconnect" );

    while ( !isdefined( self.pers["bot_loadout"] ) )
        wait 0.1;

    while ( !isdefined( self.team ) )
        wait 0.05;

    if ( level.teambased )
    {
        self notify( "menuresponse", game["menu_team"], team );
        wait 0.5;
    }

    self notify( "joined_team" );
    bot_classes = bot_build_classes();
    self notify( "menuresponse", "changeclass", random( bot_classes ) );
}

bot_build_classes()
{
    bot_classes = [];

    if ( !self isitemlocked( maps\mp\gametypes\_rank::getitemindex( "feature_cac" ) ) )
    {
        bot_classes[bot_classes.size] = "custom0";
        bot_classes[bot_classes.size] = "custom1";
        bot_classes[bot_classes.size] = "custom2";
        bot_classes[bot_classes.size] = "custom3";
        bot_classes[bot_classes.size] = "custom4";

        if ( randomint( 100 ) < 10 )
        {
            bot_classes[bot_classes.size] = "class_smg";
            bot_classes[bot_classes.size] = "class_cqb";
            bot_classes[bot_classes.size] = "class_assault";
            bot_classes[bot_classes.size] = "class_lmg";
            bot_classes[bot_classes.size] = "class_sniper";
        }
    }
    else
    {
        bot_classes[bot_classes.size] = "class_smg";
        bot_classes[bot_classes.size] = "class_cqb";
        bot_classes[bot_classes.size] = "class_assault";
        bot_classes[bot_classes.size] = "class_lmg";
        bot_classes[bot_classes.size] = "class_sniper";
    }

    return bot_classes;
}

bot_choose_class()
{
    bot_classes = bot_build_classes();

    if ( ( self maps\mp\bots\_bot_combat::threat_requires_rocket( self.bot.attacker ) || self maps\mp\bots\_bot_combat::threat_is_qrdrone( self.bot.attacker ) ) && !maps\mp\bots\_bot_combat::threat_is_warthog( self.bot.attacker ) )
    {
        if ( randomint( 100 ) < 75 )
        {
            bot_classes[bot_classes.size] = "class_smg";
            bot_classes[bot_classes.size] = "class_cqb";
            bot_classes[bot_classes.size] = "class_assault";
            bot_classes[bot_classes.size] = "class_lmg";
            bot_classes[bot_classes.size] = "class_sniper";
        }

        for ( i = 0; i < bot_classes.size; i++ )
        {
            sidearm = self getloadoutweapon( i, "secondary" );

            if ( sidearm == "fhj18_mp" )
            {
                self notify( "menuresponse", "changeclass", bot_classes[i] );
                return;
            }
            else if ( sidearm == "smaw_mp" )
            {
                bot_classes[bot_classes.size] = bot_classes[i];
                bot_classes[bot_classes.size] = bot_classes[i];
                bot_classes[bot_classes.size] = bot_classes[i];
            }
        }
    }

    if ( maps\mp\bots\_bot_combat::threat_requires_rocket( self.bot.attacker ) || maps\mp\bots\_bot_combat::threat_is_warthog( self.bot.attacker ) )
    {
        for ( i = 0; i < bot_classes.size; i++ )
        {
            perks = self getloadoutperks( i );

            foreach ( perk in perks )
            {
                if ( perk == "specialty_nottargetedbyairsupport" )
                {
                    bot_classes[bot_classes.size] = bot_classes[i];
                    bot_classes[bot_classes.size] = bot_classes[i];
                    bot_classes[bot_classes.size] = bot_classes[i];
                }
            }
        }
    }

    self notify( "menuresponse", "changeclass", random( bot_classes ) );
}

bot_spawn()
{
    self endon( "disconnect" );
/#
    weapon = undefined;

    if ( getdvarint( "scr_botsHasPlayerWeapon" ) != 0 )
    {
        player = gethostplayer();
        weapon = player getcurrentweapon();
    }

    if ( getdvar( "devgui_bot_weapon" ) != "" )
        weapon = getdvar( "devgui_bot_weapon" );

    if ( isdefined( weapon ) )
    {
        self maps\mp\gametypes\_weapons::detach_all_weapons();
        self takeallweapons();
        self giveweapon( weapon );
        self switchtoweapon( weapon );
        self setspawnweapon( weapon );
        self maps\mp\teams\_teams::set_player_model( self.team, weapon );
    }
#/
    self bot_spawn_init();

    if ( isdefined( self.bot_first_spawn ) )
        self bot_choose_class();

    self.bot_first_spawn = 1;
    self thread bot_main();
/#
    self thread bot_devgui_think();
#/
}

bot_spawn_init()
{
    time = gettime();

    if ( !isdefined( self.bot ) )
    {
        self.bot = spawnstruct();
        self.bot.threat = spawnstruct();
    }

    self.bot.glass_origin = undefined;
    self.bot.ignore_entity = [];
    self.bot.previous_origin = self.origin;
    self.bot.time_ads = 0;
    self.bot.update_c4 = time + randomintrange( 1000, 3000 );
    self.bot.update_crate = time + randomintrange( 1000, 3000 );
    self.bot.update_crouch = time + randomintrange( 1000, 3000 );
    self.bot.update_failsafe = time + randomintrange( 1000, 3000 );
    self.bot.update_idle_lookat = time + randomintrange( 1000, 3000 );
    self.bot.update_killstreak = time + randomintrange( 1000, 3000 );
    self.bot.update_lookat = time + randomintrange( 1000, 3000 );
    self.bot.update_objective = time + randomintrange( 1000, 3000 );
    self.bot.update_objective_patrol = time + randomintrange( 1000, 3000 );
    self.bot.update_patrol = time + randomintrange( 1000, 3000 );
    self.bot.update_toss = time + randomintrange( 1000, 3000 );
    self.bot.update_launcher = time + randomintrange( 1000, 3000 );
    self.bot.update_weapon = time + randomintrange( 1000, 3000 );
    difficulty = bot_get_difficulty();

    switch ( difficulty )
    {
        case "easy":
            self.bot.think_interval = 0.5;
            self.bot.fov = 0.4226;
            break;
        case "normal":
            self.bot.think_interval = 0.25;
            self.bot.fov = 0.0872;
            break;
        case "hard":
            self.bot.think_interval = 0.2;
            self.bot.fov = -0.1736;
            break;
        case "fu":
            self.bot.think_interval = 0.1;
            self.bot.fov = -0.9396;
            break;
        default:
            self.bot.think_interval = 0.25;
            self.bot.fov = 0.0872;
            break;
    }

    self.bot.threat.entity = undefined;
    self.bot.threat.position = ( 0, 0, 0 );
    self.bot.threat.time_first_sight = 0;
    self.bot.threat.time_recent_sight = 0;
    self.bot.threat.time_aim_interval = 0;
    self.bot.threat.time_aim_correct = 0;
    self.bot.threat.update_riotshield = 0;
}

bot_wakeup_think()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        wait( self.bot.think_interval );
        self notify( "wakeup" );
    }
}

bot_damage_think()
{
    self notify( "bot_damage_think" );
    self endon( "bot_damage_think" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "damage", damage, attacker, direction, point, mod, unused1, unused2, unused3, weapon, flags, inflictor );

        if ( attacker.classname == "worldspawn" )
            continue;

        if ( isdefined( weapon ) )
        {
            if ( weapon == "proximity_grenade_mp" || weapon == "proximity_grenade_aoe_mp" )
                continue;
            else if ( weapon == "claymore_mp" )
                continue;
            else if ( weapon == "satchel_charge_mp" )
                continue;
            else if ( weapon == "bouncingbetty_mp" )
                continue;
        }

        if ( isdefined( inflictor ) )
        {
            switch ( inflictor.classname )
            {
                case "script_vehicle":
                case "auto_turret":
                    attacker = inflictor;
                    break;
            }
        }

        if ( isdefined( attacker.viewlockedentity ) )
            attacker = attacker.viewlockedentity;

        if ( maps\mp\bots\_bot_combat::threat_requires_rocket( attacker ) || maps\mp\bots\_bot_combat::threat_is_warthog( attacker ) )
            level thread bot_killstreak_dangerous_think( self.origin, self.team, attacker );

        self.bot.attacker = attacker;
        self notify( "wakeup", damage, attacker, direction );
    }
}

bot_killcam_think()
{
    self notify( "bot_killcam_think" );
    self endon( "bot_killcam_think" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait_time = 0.5;

    if ( level.playerrespawndelay )
        wait_time = level.playerrespawndelay + 1.5;

    if ( !level.killcam )
        self waittill( "death" );
    else
        self waittill( "begin_killcam" );

    wait( wait_time );

    for (;;)
    {
        self pressusebutton( 0.1 );
        wait 0.5;
    }
}

bot_glass_think()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "glass", origin );

        self.bot.glass_origin = origin;
        self notify( "wakeup" );
    }
}

bot_main()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( level.inprematchperiod )
    {
        level waittill( "prematch_over" );

        self.bot.update_failsafe = gettime() + randomintrange( 1000, 3000 );
    }

    self thread bot_wakeup_think();
    self thread bot_damage_think();
    self thread bot_killcam_think();
    self thread bot_glass_think();

    for (;;)
    {
        self waittill( "wakeup", damage, attacker, direction );

        if ( self isremotecontrolling() )
            continue;

        self maps\mp\bots\_bot_combat::bot_combat_think( damage, attacker, direction );
        self bot_update_glass();
        self bot_update_patrol();
        self bot_update_lookat();
        self bot_update_killstreak();
        self bot_update_wander();
        self bot_update_c4();
        self bot_update_launcher();
        self bot_update_weapon();

        if ( cointoss() )
        {
            self bot_update_toss_flash();
            self bot_update_toss_frag();
        }
        else
        {
            self bot_update_toss_frag();
            self bot_update_toss_flash();
        }

        self [[ level.bot_gametype ]]();
    }
}

bot_failsafe_node_valid( nearest, node )
{
    if ( isdefined( node.script_noteworthy ) )
        return false;

    if ( node.origin[2] - self.origin[2] > 18 )
        return false;

    if ( nearest == node )
        return false;

    if ( !nodesvisible( nearest, node ) )
        return false;

    if ( self bot_friend_in_radius( node.origin, 32 ) )
        return false;

    if ( isdefined( level.spawn_all ) && level.spawn_all.size > 0 )
        spawns = arraysort( level.spawn_all, node.origin );
    else if ( isdefined( level.spawnpoints ) && level.spawnpoints.size > 0 )
        spawns = arraysort( level.spawnpoints, node.origin );
    else if ( isdefined( level.spawn_start ) && level.spawn_start.size > 0 )
    {
        spawns = arraycombine( level.spawn_start["allies"], level.spawn_start["axis"], 1, 0 );
        spawns = arraysort( spawns, node.origin );
    }
    else
        return false;

    goal = bot_nearest_node( spawns[0].origin );

    if ( isdefined( goal ) && findpath( node.origin, goal.origin, undefined, 0, 1 ) )
        return true;

    return false;
}

bot_get_mantle_start()
{
    dist = self getlookaheaddist();
    dir = self getlookaheaddir();

    if ( dist > 0 && isdefined( dir ) )
    {
        forward = anglestoforward( self.angles );

        if ( vectordot( dir, forward ) < 0 )
        {
            dir = vectorscale( dir, dist );
            origin = self.origin + dir;
            nodes = getnodesinradius( origin, 16, 0, 16, "Begin" );

            if ( nodes.size && nodes[0].spawnflags & 8388608 )
                return nodes[0];
        }
    }

    return undefined;
}

bot_is_traversing()
{
    if ( !self isonground() )
        return !self ismantling() && !self isonladder();

    return 0;
}

bot_update_failsafe()
{
    time = gettime();

    if ( time - self.spawntime < 7500 )
        return;

    if ( bot_is_traversing() )
    {
        wait 0.25;
        node = bot_get_mantle_start();

        if ( isdefined( node ) )
        {
            end = getnode( node.target, "targetname" );
            self clearlookat();
            self botsetfailsafenode( end );
            self wait_endon( 1, "goal" );
            self botsetfailsafenode();
            return;
        }
    }

    if ( time < self.bot.update_failsafe )
        return;

    if ( self ismantling() || self isonladder() || !self isonground() )
    {
        wait( randomfloatrange( 0.1, 0.25 ) );
        return;
    }

    if ( !self atgoal() && distance2dsquared( self.bot.previous_origin, self.origin ) < 256 )
    {
        nodes = getnodesinradius( self.origin, 512, 0 );
        nodes = array_randomize( nodes );
        nearest = bot_nearest_node( self.origin );
        failsafe = 0;

        if ( isdefined( nearest ) )
        {
            foreach ( node in nodes )
            {
                if ( !bot_failsafe_node_valid( nearest, node ) )
                    continue;

                self botsetfailsafenode( node );
                wait 0.5;
                self.bot.update_idle_lookat = 0;
                self bot_update_lookat();
                self cancelgoal( "enemy_patrol" );
                self wait_endon( 4, "goal" );
                self botsetfailsafenode();
                self bot_update_lookat();
                failsafe = 1;
                break;
            }
        }

        if ( !failsafe && nodes.size )
        {
            node = random( nodes );
            self botsetfailsafenode( node );
            wait 0.5;
            self.bot.update_idle_lookat = 0;
            self bot_update_lookat();
            self cancelgoal( "enemy_patrol" );
            self wait_endon( 4, "goal" );
            self botsetfailsafenode();
            self bot_update_lookat();
        }
    }

    self.bot.update_failsafe = gettime() + 3500;
    self.bot.previous_origin = self.origin;
}

bot_update_crouch()
{
    time = gettime();

    if ( time < self.bot.update_crouch )
        return;

    if ( self atgoal() )
        return;

    if ( self ismantling() || self isonladder() || !self isonground() )
        return;

    dist = self getlookaheaddist();

    if ( dist > 0 )
    {
        dir = self getlookaheaddir();
        assert( isdefined( dir ) );
        dir = vectorscale( dir, dist );
        start = self.origin + vectorscale( ( 0, 0, 1 ), 70.0 );
        end = start + dir;

        if ( dist >= 256 )
            self.bot.update_crouch = time + 1500;

        if ( self getstance() == "stand" )
        {
            trace = worldtrace( start, end );

            if ( trace["fraction"] < 1 )
            {
                self setstance( "crouch" );
                self.bot.update_crouch = time + 2500;
            }
        }
        else if ( self getstance() == "crouch" )
        {
            trace = worldtrace( start, end );

            if ( trace["fraction"] >= 1 )
                self setstance( "stand" );
        }
    }
}

bot_update_glass()
{
    if ( isdefined( self.bot.glass_origin ) )
    {
        forward = anglestoforward( self.angles );
        dir = vectornormalize( self.bot.glass_origin - self.origin );
        dot = vectordot( forward, dir );

        if ( dot > 0 )
        {
            self lookat( self.bot.glass_origin );
            wait_time = 0.5 * ( 1 - dot );
            wait_time = clamp( wait_time, 0.05, 0.5 );
            wait( wait_time );
            self pressmelee();
            wait 0.25;
            self clearlookat();
            self.bot.glass_origin = undefined;
        }
    }
}

bot_has_radar()
{
    if ( level.teambased )
        return maps\mp\killstreaks\_radar::teamhasspyplane( self.team ) || maps\mp\killstreaks\_radar::teamhassatellite( self.team );

    return isdefined( self.hasspyplane ) && self.hasspyplane || isdefined( self.hassatellite ) && self.hassatellite;
}

bot_get_enemies( on_radar = 0 )
{
    enemies = self getenemies( 1 );
/#
    for ( i = 0; i < enemies.size; i++ )
    {
        if ( enemies[i] isinmovemode( "ufo", "noclip" ) )
        {
            arrayremoveindex( enemies, i );
            i--;
        }
    }
#/
    if ( on_radar && !self bot_has_radar() )
    {
        for ( i = 0; i < enemies.size; i++ )
        {
            if ( !isdefined( enemies[i].lastfiretime ) )
            {
                arrayremoveindex( enemies, i );
                i--;
                continue;
            }

            if ( gettime() - enemies[i].lastfiretime > 2000 )
            {
                arrayremoveindex( enemies, i );
                i--;
            }
        }
    }

    return enemies;
}

bot_get_friends()
{
    friends = self getfriendlies( 1 );
/#
    for ( i = 0; i < friends.size; i++ )
    {
        if ( friends[i] isinmovemode( "ufo", "noclip" ) )
        {
            arrayremoveindex( friends, i );
            i--;
        }
    }
#/
    return friends;
}

bot_friend_goal_in_radius( goal_name, origin, radius )
{
    count = 0;
    friends = bot_get_friends();

    foreach ( friend in friends )
    {
        if ( friend is_bot() )
        {
            goal = friend getgoal( goal_name );

            if ( isdefined( goal ) && distancesquared( origin, goal ) < radius * radius )
                count++;
        }
    }

    return count;
}

bot_friend_in_radius( origin, radius )
{
    friends = bot_get_friends();

    foreach ( friend in friends )
    {
        if ( distancesquared( friend.origin, origin ) < radius * radius )
            return true;
    }

    return false;
}

bot_get_closest_enemy( origin, on_radar )
{
    enemies = self bot_get_enemies( on_radar );
    enemies = arraysort( enemies, origin );

    if ( enemies.size )
        return enemies[0];

    return undefined;
}

bot_update_wander()
{
    goal = self getgoal( "wander" );

    if ( isdefined( goal ) )
    {
        if ( distancesquared( goal, self.origin ) > 65536 )
            return;
    }

    if ( isdefined( level.spawn_all ) && level.spawn_all.size > 0 )
        spawns = arraysort( level.spawn_all, self.origin );
    else if ( isdefined( level.spawnpoints ) && level.spawnpoints.size > 0 )
        spawns = arraysort( level.spawnpoints, self.origin );
    else if ( isdefined( level.spawn_start ) && level.spawn_start.size > 0 )
    {
        spawns = arraycombine( level.spawn_start["allies"], level.spawn_start["axis"], 1, 0 );
        spawns = arraysort( spawns, self.origin );
    }
    else
        return;

    far = int( spawns.size / 2 );
    far = randomintrange( far, spawns.size );
    goal = bot_nearest_node( spawns[far].origin );

    if ( !isdefined( goal ) )
        return;

    self addgoal( goal, 24, 1, "wander" );
}

bot_get_look_at()
{
    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( self.origin, 1 );

    if ( isdefined( enemy ) )
    {
        node = getvisiblenode( self.origin, enemy.origin );

        if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
            return node.origin;
    }

    enemies = self maps\mp\bots\_bot::bot_get_enemies( 0 );

    if ( enemies.size )
        enemy = random( enemies );

    if ( isdefined( enemy ) )
    {
        node = getvisiblenode( self.origin, enemy.origin );

        if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
            return node.origin;
    }

    spawn = self getgoal( "wander" );

    if ( isdefined( spawn ) )
        node = getvisiblenode( self.origin, spawn );

    if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
        return node.origin;

    return undefined;
}

bot_update_lookat()
{
    path = isdefined( self getlookaheaddir() );

    if ( !path && gettime() > self.bot.update_idle_lookat )
    {
        origin = bot_get_look_at();

        if ( !isdefined( origin ) )
            return;

        self lookat( origin + vectorscale( ( 0, 0, 1 ), 16.0 ) );
        self.bot.update_idle_lookat = gettime() + randomintrange( 1500, 3000 );
    }
    else if ( path && self.bot.update_idle_lookat > 0 )
    {
        self clearlookat();
        self.bot.update_idle_lookat = 0;
    }
}

bot_update_patrol()
{
    closest = bot_get_closest_enemy( self.origin, 1 );

    if ( isdefined( closest ) && distancesquared( self.origin, closest.origin ) < 262144 )
    {
        goal = self getgoal( "enemy_patrol" );

        if ( isdefined( goal ) && distancesquared( goal, closest.origin ) > 16384 )
        {
            self cancelgoal( "enemy_patrol" );
            self.bot.update_patrol = 0;
        }
    }

    if ( gettime() < self.bot.update_patrol )
        return;

    self maps\mp\bots\_bot_combat::bot_patrol_near_enemy();
    self.bot.update_patrol = gettime() + randomintrange( 5000, 10000 );
}

bot_update_toss_flash()
{
    if ( bot_get_difficulty() == "easy" )
        return;

    time = gettime();

    if ( time - self.spawntime < 7500 )
        return;

    if ( time < self.bot.update_toss )
        return;

    self.bot.update_toss = time + 1500;

    if ( self getweaponammostock( "sensor_grenade_mp" ) <= 0 && self getweaponammostock( "proximity_grenade_mp" ) <= 0 && self getweaponammostock( "trophy_system_mp" ) <= 0 )
        return;

    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( self.origin, 1 );
    node = undefined;

    if ( isdefined( enemy ) )
        node = getvisiblenode( self.origin, enemy.origin );

    if ( isdefined( node ) && distancesquared( self.origin, node.origin ) < 65536 )
    {
        self lookat( node.origin );
        wait 0.75;
        self pressattackbutton( 2 );
        self.bot.update_toss = time + 20000;
        self clearlookat();
    }
}

bot_update_toss_frag()
{
    if ( bot_get_difficulty() == "easy" )
        return;

    time = gettime();

    if ( time - self.spawntime < 7500 )
        return;

    if ( time < self.bot.update_toss )
        return;

    self.bot.update_toss = time + 1500;

    if ( self getweaponammostock( "bouncingbetty_mp" ) <= 0 && self getweaponammostock( "claymore_mp" ) <= 0 && self getweaponammostock( "satchel_charge_mp" ) <= 0 )
        return;

    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( self.origin, 1 );
    node = undefined;

    if ( isdefined( enemy ) )
        node = getvisiblenode( self.origin, enemy.origin );

    if ( isdefined( node ) && distancesquared( self.origin, node.origin ) < 65536 )
    {
        self lookat( node.origin );
        wait 0.75;
        self pressattackbutton( 1 );
        self.bot.update_toss = time + 20000;
        self clearlookat();
    }
}

bot_set_rank()
{
    players = get_players();
    ranks = [];
    bot_ranks = [];
    human_ranks = [];

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] == self )
            continue;

        if ( isdefined( players[i].pers["rank"] ) )
        {
            if ( players[i] is_bot() )
            {
                bot_ranks[bot_ranks.size] = players[i].pers["rank"];
                continue;
            }

            human_ranks[human_ranks.size] = players[i].pers["rank"];
        }
    }

    if ( !human_ranks.size )
        human_ranks[human_ranks.size] = 10;

    human_avg = array_average( human_ranks );

    while ( bot_ranks.size + human_ranks.size < 5 )
    {
        r = human_avg + randomintrange( -5, 5 );
        rank = clamp( r, 0, level.maxrank );
        human_ranks[human_ranks.size] = rank;
    }

    ranks = arraycombine( human_ranks, bot_ranks, 1, 0 );
    avg = array_average( ranks );
    s = array_std_deviation( ranks, avg );
    rank = int( random_normal_distribution( avg, s, 0, level.maxrank ) );
    self.pers["rank"] = rank;
    self.pers["rankxp"] = maps\mp\gametypes\_rank::getrankinfominxp( rank );
    self setrank( rank );
    self maps\mp\gametypes\_rank::syncxpstat();
}

bot_gametype_allowed()
{
    level.bot_gametype = ::gametype_void;

    switch ( level.gametype )
    {
        case "tdm":
        case "dm":
            return true;
        case "ctf":
            level.bot_gametype = maps\mp\bots\_bot_ctf::bot_ctf_think;
            return true;
        case "dem":
            level.bot_gametype = maps\mp\bots\_bot_dem::bot_dem_think;
            return true;
        case "dom":
            level.bot_gametype = maps\mp\bots\_bot_dom::bot_dom_think;
            return true;
        case "koth":
            level.bot_gametype = maps\mp\bots\_bot_koth::bot_koth_think;
            return true;
        case "hq":
            level.bot_gametype = maps\mp\bots\_bot_hq::bot_hq_think;
            return true;
        case "conf":
            level.bot_gametype = maps\mp\bots\_bot_conf::bot_conf_think;
            return true;
    }

    return false;
}

bot_get_difficulty()
{
    if ( !isdefined( level.bot_difficulty ) )
    {
        level.bot_difficulty = "normal";
        difficulty = getdvarintdefault( "bot_difficulty", 1 );

        if ( difficulty == 0 )
            level.bot_difficulty = "easy";
        else if ( difficulty == 1 )
            level.bot_difficulty = "normal";
        else if ( difficulty == 2 )
            level.bot_difficulty = "hard";
        else if ( difficulty == 3 )
            level.bot_difficulty = "fu";
    }

    return level.bot_difficulty;
}

bot_set_difficulty()
{
    difficulty = bot_get_difficulty();

    if ( difficulty == "fu" )
    {
        setdvar( "bot_MinDeathTime", "250" );
        setdvar( "bot_MaxDeathTime", "500" );
        setdvar( "bot_MinFireTime", "100" );
        setdvar( "bot_MaxFireTime", "250" );
        setdvar( "bot_PitchUp", "-5" );
        setdvar( "bot_PitchDown", "10" );
        setdvar( "bot_Fov", "160" );
        setdvar( "bot_MinAdsTime", "3000" );
        setdvar( "bot_MaxAdsTime", "5000" );
        setdvar( "bot_MinCrouchTime", "100" );
        setdvar( "bot_MaxCrouchTime", "400" );
        setdvar( "bot_TargetLeadBias", "2" );
        setdvar( "bot_MinReactionTime", "40" );
        setdvar( "bot_MaxReactionTime", "70" );
        setdvar( "bot_StrafeChance", "1" );
        setdvar( "bot_MinStrafeTime", "3000" );
        setdvar( "bot_MaxStrafeTime", "6000" );
        setdvar( "scr_help_dist", "512" );
        setdvar( "bot_AllowGrenades", "1" );
        setdvar( "bot_MinGrenadeTime", "1500" );
        setdvar( "bot_MaxGrenadeTime", "4000" );
        setdvar( "bot_MeleeDist", "70" );
        setdvar( "bot_YawSpeed", "2" );
    }
    else if ( difficulty == "hard" )
    {
        setdvar( "bot_MinDeathTime", "250" );
        setdvar( "bot_MaxDeathTime", "500" );
        setdvar( "bot_MinFireTime", "400" );
        setdvar( "bot_MaxFireTime", "600" );
        setdvar( "bot_PitchUp", "-5" );
        setdvar( "bot_PitchDown", "10" );
        setdvar( "bot_Fov", "100" );
        setdvar( "bot_MinAdsTime", "3000" );
        setdvar( "bot_MaxAdsTime", "5000" );
        setdvar( "bot_MinCrouchTime", "100" );
        setdvar( "bot_MaxCrouchTime", "400" );
        setdvar( "bot_TargetLeadBias", "2" );
        setdvar( "bot_MinReactionTime", "400" );
        setdvar( "bot_MaxReactionTime", "700" );
        setdvar( "bot_StrafeChance", "0.9" );
        setdvar( "bot_MinStrafeTime", "3000" );
        setdvar( "bot_MaxStrafeTime", "6000" );
        setdvar( "scr_help_dist", "384" );
        setdvar( "bot_AllowGrenades", "1" );
        setdvar( "bot_MinGrenadeTime", "1500" );
        setdvar( "bot_MaxGrenadeTime", "4000" );
        setdvar( "bot_MeleeDist", "70" );
        setdvar( "bot_YawSpeed", "1.4" );
    }
    else if ( difficulty == "easy" )
    {
        setdvar( "bot_MinDeathTime", "1000" );
        setdvar( "bot_MaxDeathTime", "2000" );
        setdvar( "bot_MinFireTime", "900" );
        setdvar( "bot_MaxFireTime", "1000" );
        setdvar( "bot_PitchUp", "-20" );
        setdvar( "bot_PitchDown", "40" );
        setdvar( "bot_Fov", "50" );
        setdvar( "bot_MinAdsTime", "3000" );
        setdvar( "bot_MaxAdsTime", "5000" );
        setdvar( "bot_MinCrouchTime", "4000" );
        setdvar( "bot_MaxCrouchTime", "6000" );
        setdvar( "bot_TargetLeadBias", "8" );
        setdvar( "bot_MinReactionTime", "1200" );
        setdvar( "bot_MaxReactionTime", "1600" );
        setdvar( "bot_StrafeChance", "0.1" );
        setdvar( "bot_MinStrafeTime", "3000" );
        setdvar( "bot_MaxStrafeTime", "6000" );
        setdvar( "scr_help_dist", "256" );
        setdvar( "bot_AllowGrenades", "0" );
        setdvar( "bot_MeleeDist", "40" );
    }
    else
    {
        setdvar( "bot_MinDeathTime", "500" );
        setdvar( "bot_MaxDeathTime", "1000" );
        setdvar( "bot_MinFireTime", "600" );
        setdvar( "bot_MaxFireTime", "800" );
        setdvar( "bot_PitchUp", "-10" );
        setdvar( "bot_PitchDown", "20" );
        setdvar( "bot_Fov", "70" );
        setdvar( "bot_MinAdsTime", "3000" );
        setdvar( "bot_MaxAdsTime", "5000" );
        setdvar( "bot_MinCrouchTime", "2000" );
        setdvar( "bot_MaxCrouchTime", "4000" );
        setdvar( "bot_TargetLeadBias", "4" );
        setdvar( "bot_MinReactionTime", "600" );
        setdvar( "bot_MaxReactionTime", "800" );
        setdvar( "bot_StrafeChance", "0.6" );
        setdvar( "bot_MinStrafeTime", "3000" );
        setdvar( "bot_MaxStrafeTime", "6000" );
        setdvar( "scr_help_dist", "256" );
        setdvar( "bot_AllowGrenades", "1" );
        setdvar( "bot_MinGrenadeTime", "1500" );
        setdvar( "bot_MaxGrenadeTime", "4000" );
        setdvar( "bot_MeleeDist", "70" );
        setdvar( "bot_YawSpeed", "1.2" );
    }

    if ( level.gametype == "oic" && difficulty == "fu" )
    {
        setdvar( "bot_MinReactionTime", "400" );
        setdvar( "bot_MaxReactionTime", "500" );
        setdvar( "bot_MinAdsTime", "1000" );
        setdvar( "bot_MaxAdsTime", "2000" );
    }

    if ( level.gametype == "oic" && ( difficulty == "hard" || difficulty == "fu" ) )
        setdvar( "bot_SprintDistance", "256" );
}

bot_update_c4()
{
    if ( !isdefined( self.weaponobjectwatcherarray ) )
        return;

    time = gettime();

    if ( time < self.bot.update_c4 )
        return;

    self.bot.update_c4 = time + randomintrange( 1000, 2000 );
    radius = getweaponexplosionradius( "satchel_charge_mp" );

    foreach ( watcher in self.weaponobjectwatcherarray )
    {
        if ( watcher.name == "satchel_charge" )
            break;
    }

    if ( watcher.objectarray.size )
    {
        foreach ( weapon in watcher.objectarray )
        {
            if ( !isdefined( weapon ) )
                continue;

            enemy = bot_get_closest_enemy( weapon.origin, 0 );

            if ( !isdefined( enemy ) )
                return;

            if ( distancesquared( enemy.origin, weapon.origin ) < radius * radius )
            {
                self pressattackbutton( 1 );
                return;
            }
        }
    }
}

bot_update_launcher()
{
    time = gettime();

    if ( time < self.bot.update_launcher )
        return;

    self.bot.update_launcher = time + randomintrange( 5000, 10000 );

    if ( !self maps\mp\bots\_bot_combat::bot_has_launcher() )
        return;

    enemies = self getthreats( -1 );

    foreach ( enemy in enemies )
    {
        if ( !target_istarget( enemy ) )
            continue;

        if ( maps\mp\bots\_bot_combat::threat_is_warthog( enemy ) )
            continue;

        if ( !maps\mp\bots\_bot_combat::threat_requires_rocket( enemy ) )
            continue;

        origin = self getplayercamerapos();
        angles = vectortoangles( enemy.origin - origin );

        if ( angles[0] < 290 )
            continue;

        if ( self botsighttracepassed( enemy ) )
        {
            self maps\mp\bots\_bot_combat::bot_lookat_entity( enemy );
            return;
        }
    }
}

bot_update_weapon()
{
    time = gettime();

    if ( time < self.bot.update_weapon )
        return;

    self.bot.update_weapon = time + randomintrange( 5000, 7500 );
    weapon = self getcurrentweapon();
    ammo = self getweaponammoclip( weapon ) + self getweaponammostock( weapon );

    if ( weapon == "none" )
        return;

    if ( self maps\mp\bots\_bot_combat::bot_can_reload() )
    {
        frac = 0.5;

        if ( maps\mp\bots\_bot_combat::bot_has_lmg() )
            frac = 0.25;

        frac += randomfloatrange( -0.1, 0.1 );

        if ( maps\mp\bots\_bot_combat::bot_weapon_ammo_frac() < frac )
        {
            self pressusebutton( 0.1 );
            return;
        }
    }

    if ( ammo && !self maps\mp\bots\_bot_combat::bot_has_pistol() && !self maps\mp\bots\_bot_combat::bot_using_launcher() )
        return;

    primaries = self getweaponslistprimaries();

    foreach ( primary in primaries )
    {
        if ( primary == "knife_held_mp" )
            continue;

        if ( primary != weapon && ( self getweaponammoclip( primary ) || self getweaponammostock( primary ) ) )
        {
            self switchtoweapon( primary );
            return;
        }
    }
}

bot_update_crate()
{
    time = gettime();

    if ( time < self.bot.update_crate )
        return;

    self.bot.update_crate = time + randomintrange( 1000, 3000 );
    self cancelgoal( "care package" );
    radius = getdvarfloat( "player_useRadius" );
    crates = getentarray( "care_package", "script_noteworthy" );

    foreach ( crate in crates )
    {
        if ( distancesquared( self.origin, crate.origin ) < radius * radius )
        {
            if ( isdefined( crate.hacker ) )
            {
                if ( crate.hacker == self )
                    continue;

                if ( crate.hacker.team == self.team )
                    continue;
            }

            if ( crate.owner == self )
                time = level.crateownerusetime / 1000 + 0.5;
            else
                time = level.cratenonownerusetime / 1000 + 0.5;

            self setstance( "crouch" );
            self addgoal( self.origin, 24, 4, "care package" );
            self pressusebutton( time );
            wait( time );
            self setstance( "stand" );
            self cancelgoal( "care package" );
            self.bot.update_crate = gettime() + randomintrange( 1000, 3000 );
            return;
        }
    }

    if ( self getweaponammostock( "pda_hack_mp" ) )
    {
        foreach ( crate in crates )
        {
            if ( !isdefined( crate.friendlyobjid ) )
                continue;

            if ( isdefined( crate.hacker ) )
            {
                if ( crate.hacker == self )
                    continue;

                if ( crate.hacker.team == self.team )
                    continue;
            }

            if ( self botsighttracepassed( crate ) )
            {
                self lookat( crate.origin );
                self addgoal( self.origin, 24, 4, "care package" );
                wait 0.75;
                start = gettime();

                if ( !isdefined( crate.owner ) )
                {
                    self cancelgoal( "care package" );
                    return;
                }

                if ( crate.owner == self )
                    end = level.crateownerusetime + 1000;
                else
                    end = level.cratenonownerusetime + 1000;

                while ( gettime() < start + end )
                {
                    self pressattackbutton( 2 );
                    wait 0.05;
                }

                self.bot.update_crate = gettime() + randomintrange( 1000, 3000 );
                self cancelgoal( "care package" );
                return;
            }
        }
    }
}

bot_update_killstreak()
{
    if ( !level.loadoutkillstreaksenabled )
        return;

    time = gettime();

    if ( time < self.bot.update_killstreak )
        return;

    if ( self isweaponviewonlylinked() )
        return;
/#
    if ( !getdvarint( "scr_botsAllowKillstreaks" ) )
        return;
#/
    self.bot.update_killstreak = time + randomintrange( 1000, 3000 );
    weapons = self getweaponslist();
    ks_weapon = undefined;
    inventoryweapon = self getinventoryweapon();

    foreach ( weapon in weapons )
    {
        if ( self getweaponammoclip( weapon ) <= 0 && ( !isdefined( inventoryweapon ) || weapon != inventoryweapon ) )
            continue;

        if ( iskillstreakweapon( weapon ) )
        {
            killstreak = maps\mp\killstreaks\_killstreaks::getkillstreakforweapon( weapon );

            if ( self maps\mp\killstreaks\_killstreakrules::iskillstreakallowed( killstreak, self.team ) )
            {
                ks_weapon = weapon;
                break;
            }
        }
    }

    if ( !isdefined( ks_weapon ) )
        return;

    killstreak = maps\mp\killstreaks\_killstreaks::getkillstreakforweapon( ks_weapon );
    killstreak_ref = maps\mp\killstreaks\_killstreaks::getkillstreakmenuname( killstreak );

    if ( !isdefined( killstreak_ref ) )
        return;

    switch ( killstreak_ref )
    {
        case "killstreak_helicopter_comlink":
            bot_killstreak_location( 1, weapon );
            break;
        case "killstreak_planemortar":
            bot_killstreak_location( 3, weapon );
            break;
        case "killstreak_supply_drop":
        case "killstreak_missile_drone":
        case "killstreak_ai_tank_drop":
            self bot_use_supply_drop( weapon );
            break;
        case "killstreak_tow_turret":
        case "killstreak_microwave_turret":
        case "killstreak_auto_turret":
            self bot_turret_location( weapon );
            break;
        case "killstreak_remote_mortar":
        case "killstreak_rcbomb":
        case "killstreak_qrdrone":
        case "killstreak_helicopter_player_gunner":
            return;
        case "killstreak_remote_missile":
            if ( time - self.spawntime < 6000 )
            {
                self switchtoweapon( weapon );

                self waittill( "weapon_change_complete" );

                wait 1.5;
                self pressattackbutton();
            }

            return;
        default:
            self switchtoweapon( weapon );
            break;
    }
}

bot_get_vehicle_entity()
{
    if ( self isremotecontrolling() )
    {
        if ( isdefined( self.rcbomb ) )
            return self.rcbomb;
        else if ( isdefined( self.qrdrone ) )
            return self.qrdrone;
    }

    return undefined;
}

bot_rccar_think()
{
    self endon( "disconnect" );
    self endon( "rcbomb_done" );
    self endon( "weapon_object_destroyed" );
    level endon( "game_ended" );
    wait 2;
    self thread bot_rccar_kill();

    for (;;)
    {
        wait 0.5;
        ent = self bot_get_vehicle_entity();

        if ( !isdefined( ent ) )
            return;

        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if ( player == self )
                continue;

            if ( !isalive( player ) )
                continue;

            if ( level.teambased && player.team == self.team )
                continue;
/#
            if ( player isinmovemode( "ufo", "noclip" ) )
                continue;
#/
            if ( bot_get_difficulty() == "easy" )
            {
                if ( distancesquared( ent.origin, player.origin ) < 262144 )
                    self pressattackbutton();

                continue;
            }

            if ( distancesquared( ent.origin, player.origin ) < 40000 )
                self pressattackbutton();
        }
    }
}

bot_rccar_kill()
{
    self endon( "disconnect" );
    self endon( "rcbomb_done" );
    self endon( "weapon_object_destroyed" );
    level endon( "game_ended" );
    og_origin = self.origin;

    for (;;)
    {
        wait 1;
        ent = bot_get_vehicle_entity();

        if ( !isdefined( ent ) )
            return;

        if ( distancesquared( og_origin, ent.origin ) < 256 )
        {
            wait 2;

            if ( !isdefined( ent ) )
                return;

            if ( distancesquared( og_origin, ent.origin ) < 256 )
                self pressattackbutton();
        }

        og_origin = ent.origin;
    }
}

bot_turret_location( weapon )
{
    enemy = bot_get_closest_enemy( self.origin );

    if ( !isdefined( enemy ) )
        return;

    forward = anglestoforward( self getplayerangles() );
    forward = vectornormalize( forward );
    delta = enemy.origin - self.origin;
    delta = vectornormalize( delta );
    dot = vectordot( forward, delta );

    if ( dot < 0.707 )
        return;

    node = getvisiblenode( self.origin, enemy.origin );

    if ( !isdefined( node ) )
        return;

    if ( distancesquared( self.origin, node.origin ) < 262144 )
        return;

    delta = node.origin - self.origin;
    delta = vectornormalize( delta );
    dot = vectordot( forward, delta );

    if ( dot < 0.707 )
        return;

    self thread weapon_switch_failsafe();
    self switchtoweapon( weapon );

    self waittill( "weapon_change_complete" );

    self freeze_player_controls( 1 );
    wait 1;
    self freeze_player_controls( 0 );
    bot_use_item( weapon );
    self switchtoweapon( self.lastnonkillstreakweapon );
}

bot_use_supply_drop( weapon )
{
    if ( weapon == "inventory_supplydrop_mp" || weapon == "supplydrop_mp" )
    {
        if ( gettime() - self.spawntime > 5000 )
            return;
    }

    yaw = ( 0, self.angles[1], 0 );
    dir = anglestoforward( yaw );
    dir = vectornormalize( dir );
    drop_point = self.origin + vectorscale( dir, 384 );
    end = drop_point + vectorscale( ( 0, 0, 1 ), 2048.0 );

    if ( !sighttracepassed( drop_point, end, 0, undefined ) )
        return;

    if ( !sighttracepassed( self.origin, end, 0, undefined ) )
        return;

    end = drop_point - vectorscale( ( 0, 0, 1 ), 32.0 );

    if ( bullettracepassed( drop_point, end, 0, undefined ) )
        return;

    self addgoal( self.origin, 24, 4, "killstreak" );

    if ( weapon == "missile_drone_mp" || weapon == "inventory_missile_drone_mp" )
        self lookat( drop_point + vectorscale( ( 0, 0, 1 ), 384.0 ) );
    else
        self lookat( drop_point );

    wait 0.5;

    if ( self getcurrentweapon() != weapon )
    {
        self thread weapon_switch_failsafe();
        self switchtoweapon( weapon );

        self waittill( "weapon_change_complete" );
    }

    bot_use_item( weapon );
    self switchtoweapon( self.lastnonkillstreakweapon );
    self clearlookat();
    self cancelgoal( "killstreak" );
}

bot_use_item( weapon )
{
    self pressattackbutton();
    wait 0.5;

    for ( i = 0; i < 10; i++ )
    {
        if ( self getcurrentweapon() == weapon || self getcurrentweapon() == "none" )
            self pressattackbutton();
        else
            return;

        wait 0.5;
    }
}

bot_killstreak_location( num, weapon )
{
    enemies = bot_get_enemies();

    if ( !enemies.size )
        return;

    if ( !self switchtoweapon( weapon ) )
        return;

    self waittill( "weapon_change" );

    self freeze_player_controls( 1 );
    wait_time = 1;

    while ( !isdefined( self.selectinglocation ) || self.selectinglocation == 0 )
    {
        wait 0.05;
        wait_time -= 0.05;

        if ( wait_time <= 0 )
        {
            self freeze_player_controls( 0 );
            self switchtoweapon( self.lastnonkillstreakweapon );
            return;
        }
    }

    wait 2;

    for ( i = 0; i < num; i++ )
    {
        enemies = bot_get_enemies();

        if ( enemies.size )
        {
            enemy = random( enemies );
            self notify( "confirm_location", enemy.origin, 0 );
        }

        wait 0.25;
    }

    self freeze_player_controls( 0 );
}

bot_killstreak_dangerous_think( origin, team, attacker )
{
    if ( !level.teambased )
        return;

    nodes = getnodesinradius( origin + vectorscale( ( 0, 0, 1 ), 384.0 ), 384, 0 );

    foreach ( node in nodes )
    {
        if ( node isdangerous( team ) )
            return;
    }

    foreach ( node in nodes )
        node setdangerous( team, 1 );

    attacker wait_endon( 25, "death" );

    foreach ( node in nodes )
        node setdangerous( team, 0 );
}

weapon_switch_failsafe()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "weapon_change_complete" );
    wait 10;
    self notify( "weapon_change_complete" );
}

bot_dive_to_prone( exit_stance )
{
    self pressdtpbutton();
    event = self waittill_any_timeout( 0.25, "dtp_start" );

    if ( event == "dtp_start" )
    {
        self waittill( "dtp_end" );

        self setstance( "prone" );
        wait 0.35;
        self setstance( exit_stance );
    }
}

gametype_void()
{

}

bot_debug_star( origin, seconds, color )
{
/#
    if ( !isdefined( seconds ) )
        seconds = 1;

    if ( !isdefined( color ) )
        color = ( 1, 0, 0 );

    frames = int( 20 * seconds );
    debugstar( origin, frames, color );
#/
}

bot_debug_circle( origin, radius, seconds, color )
{
/#
    if ( !isdefined( seconds ) )
        seconds = 1;

    if ( !isdefined( color ) )
        color = ( 1, 0, 0 );

    frames = int( 20 * seconds );
    circle( origin, radius, color, 0, 1, frames );
#/
}

bot_debug_box( origin, mins, maxs, yaw, seconds, color )
{
/#
    if ( !isdefined( yaw ) )
        yaw = 0;

    if ( !isdefined( seconds ) )
        seconds = 1;

    if ( !isdefined( color ) )
        color = ( 1, 0, 0 );

    frames = int( 20 * seconds );
    box( origin, mins, maxs, yaw, color, 1, 0, frames );
#/
}

bot_devgui_think()
{
/#
    self endon( "death" );
    self endon( "disconnect" );
    setdvar( "devgui_bot", "" );
    setdvar( "scr_bot_follow", "0" );

    for (;;)
    {
        wait 1;
        reset = 1;

        switch ( getdvar( "devgui_bot" ) )
        {
            case "crosshair":
                if ( getdvarint( "scr_bot_follow" ) != 0 )
                {
                    iprintln( "Bot following enabled" );
                    self thread bot_crosshair_follow();
                }
                else
                {
                    iprintln( "Bot following disabled" );
                    self notify( "crosshair_follow_off" );
                    setdvar( "bot_AllowMovement", "0" );
                }

                break;
            case "laststand":
                setdvar( "scr_forcelaststand", "1" );
                self setperk( "specialty_pistoldeath" );
                self setperk( "specialty_finalstand" );
                self dodamage( self.health, self.origin );
                break;
            case "":
            default:
                reset = 0;
                break;
        }

        if ( reset )
            setdvar( "devgui_bot", "" );
    }
#/
}

bot_system_devgui_think()
{
/#
    setdvar( "devgui_bot", "" );
    setdvar( "devgui_bot_weapon", "" );

    for (;;)
    {
        wait 1;
        reset = 1;

        switch ( getdvar( "devgui_bot" ) )
        {
            case "spawn_friendly":
                player = gethostplayer();
                team = player.team;
                devgui_bot_spawn( team );
                break;
            case "spawn_enemy":
                player = gethostplayer();
                team = getenemyteamwithlowestplayercount( player.team );
                devgui_bot_spawn( team );
                break;
            case "player_weapon":
            case "loadout":
                players = get_players();

                foreach ( player in players )
                {
                    if ( !player is_bot() )
                        continue;

                    host = gethostplayer();
                    weapon = host getcurrentweapon();
                    player maps\mp\gametypes\_weapons::detach_all_weapons();
                    player takeallweapons();
                    player giveweapon( weapon );
                    player switchtoweapon( weapon );
                    player setspawnweapon( weapon );
                    player maps\mp\teams\_teams::set_player_model( player.team, weapon );
                }

                break;
            case "routes":
                devgui_debug_route();
                break;
            case "":
            default:
                reset = 0;
                break;
        }

        if ( reset )
            setdvar( "devgui_bot", "" );
    }
#/
}

bot_crosshair_follow()
{
/#
    self notify( "crosshair_follow_off" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "crosshair_follow_off" );

    for (;;)
    {
        wait 1;
        setdvar( "bot_AllowMovement", "1" );
        setdvar( "bot_IgnoreHumans", "1" );
        setdvar( "bot_ForceStand", "1" );
        player = gethostplayerforbots();
        direction = player getplayerangles();
        direction_vec = anglestoforward( direction );
        eye = player geteye();
        scale = 8000;
        direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
        trace = bullettrace( eye, eye + direction_vec, 0, undefined );
        origin = trace["position"] + ( 0, 0, 0 );

        if ( distancesquared( self.origin, origin ) > 16384 )
        {

        }
    }
#/
}

bot_debug_patrol( node1, node2 )
{
/#
    self endon( "death" );
    self endon( "debug_patrol" );

    for (;;)
    {
        self addgoal( node1, 24, 4, "debug_route" );

        self waittill( "debug_route", result );

        if ( result == "failed" )
        {
            self cancelgoal( "debug_route" );
            wait 5;
        }

        self addgoal( node2, 24, 4, "debug_route" );

        self waittill( "debug_route", result );

        if ( result == "failed" )
        {
            self cancelgoal( "debug_route" );
            wait 5;
        }
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

    iprintln( "Sending bots to chosen nodes" );
    players = get_players();

    foreach ( player in players )
    {
        if ( !player is_bot() )
            continue;

        player notify( "debug_patrol" );
        player thread bot_debug_patrol( nodes[0], nodes[1] );
    }
#/
}

devgui_bot_spawn( team )
{
/#
    player = gethostplayer();
    direction = player getplayerangles();
    direction_vec = anglestoforward( direction );
    eye = player geteye();
    scale = 8000;
    direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );
    direction_vec = player.origin - trace["position"];
    direction = vectortoangles( direction_vec );
    bot = addtestclient();

    if ( !isdefined( bot ) )
    {
        println( "Could not add test client" );
        return;
    }

    bot.pers["isBot"] = 1;
    bot thread bot_spawn_think( team );
    yaw = direction[1];
    bot thread devgui_bot_spawn_think( trace["position"], yaw );
#/
}

devgui_bot_spawn_think( origin, yaw )
{
/#
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self setorigin( origin );
        angles = ( 0, yaw, 0 );
        self setplayerangles( angles );
    }
#/
}
