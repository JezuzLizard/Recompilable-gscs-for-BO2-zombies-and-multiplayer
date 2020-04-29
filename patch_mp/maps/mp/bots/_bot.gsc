#include maps/mp/gametypes/_dev;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/bots/_bot_conf;
#include maps/mp/bots/_bot_hq;
#include maps/mp/bots/_bot_koth;
#include maps/mp/bots/_bot_dom;
#include maps/mp/bots/_bot_dem;
#include maps/mp/bots/_bot_ctf;
#include maps/mp/bots/_bot;
#include maps/mp/killstreaks/_radar;
#include maps/mp/teams/_teams;
#include maps/mp/gametypes/_weapons;
#include maps/mp/gametypes/_rank;
#include maps/mp/bots/_bot_combat;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
/#
	level thread bot_system_devgui_think();
#/
	level thread maps/mp/bots/_bot_loadout::init();
	if ( !bot_gametype_allowed() )
	{
		return;
	}
	if ( level.rankedmatch && !is_bot_ranked_match() )
	{
		return;
	}
	bot_friends = getDvarInt( "bot_friends" );
	bot_enemies = getDvarInt( "bot_enemies" );
	if ( bot_friends <= 0 && bot_enemies <= 0 )
	{
		return;
	}
	bot_wait_for_host();
	bot_set_difficulty();
	if ( is_bot_comp_stomp() )
	{
		team = bot_choose_comp_stomp_team();
		level thread bot_comp_stomp_think( team );
	}
	else if ( is_bot_ranked_match() )
	{
		level thread bot_ranked_think();
	}
	else
	{
		level thread bot_local_think();
	}
}

spawn_bot( team )
{
	bot = addtestclient();
	if ( isDefined( bot ) )
	{
		bot.pers[ "isBot" ] = 1;
		if ( team != "autoassign" )
		{
			bot.pers[ "team" ] = team;
		}
		bot thread bot_spawn_think( team );
		return 1;
	}
	return 0;
}

getenemyteamwithlowestplayercount( player_team )
{
	counts = [];
	_a83 = level.teams;
	_k83 = getFirstArrayKey( _a83 );
	while ( isDefined( _k83 ) )
	{
		team = _a83[ _k83 ];
		counts[ team ] = 0;
		_k83 = getNextArrayKey( _a83, _k83 );
	}
	_a88 = level.players;
	_k88 = getFirstArrayKey( _a88 );
	while ( isDefined( _k88 ) )
	{
		player = _a88[ _k88 ];
		if ( !isDefined( player.team ) )
		{
		}
		else if ( !isDefined( counts[ player.team ] ) )
		{
		}
		else
		{
			counts[ player.team ]++;
		}
		_k88 = getNextArrayKey( _a88, _k88 );
	}
	count = 999999;
	enemy_team = player_team;
	_a102 = level.teams;
	_k102 = getFirstArrayKey( _a102 );
	while ( isDefined( _k102 ) )
	{
		team = _a102[ _k102 ];
		if ( team == player_team )
		{
		}
		else if ( team == "spectator" )
		{
		}
		else
		{
			if ( counts[ team ] < count )
			{
				enemy_team = team;
				count = counts[ team ];
			}
		}
		_k102 = getNextArrayKey( _a102, _k102 );
	}
	return enemy_team;
}

getenemyteamwithgreatestbotcount( player_team )
{
	counts = [];
	_a124 = level.teams;
	_k124 = getFirstArrayKey( _a124 );
	while ( isDefined( _k124 ) )
	{
		team = _a124[ _k124 ];
		counts[ team ] = 0;
		_k124 = getNextArrayKey( _a124, _k124 );
	}
	_a129 = level.players;
	_k129 = getFirstArrayKey( _a129 );
	while ( isDefined( _k129 ) )
	{
		player = _a129[ _k129 ];
		if ( !isDefined( player.team ) )
		{
		}
		else if ( !isDefined( counts[ player.team ] ) )
		{
		}
		else if ( !player is_bot() )
		{
		}
		else
		{
			counts[ player.team ]++;
		}
		_k129 = getNextArrayKey( _a129, _k129 );
	}
	count = -1;
	enemy_team = undefined;
	_a146 = level.teams;
	_k146 = getFirstArrayKey( _a146 );
	while ( isDefined( _k146 ) )
	{
		team = _a146[ _k146 ];
		if ( team == player_team )
		{
		}
		else if ( team == "spectator" )
		{
		}
		else
		{
			if ( counts[ team ] > count )
			{
				enemy_team = team;
				count = counts[ team ];
			}
		}
		_k146 = getNextArrayKey( _a146, _k146 );
	}
	return enemy_team;
}

bot_wait_for_host()
{
	host = gethostplayerforbots();
	while ( !isDefined( host ) )
	{
		wait 0,25;
		host = gethostplayerforbots();
	}
	if ( level.prematchperiod > 0 && level.inprematchperiod == 1 )
	{
		wait 1;
	}
}

bot_count_humans( team )
{
	players = get_players();
	count = 0;
	_a185 = players;
	_k185 = getFirstArrayKey( _a185 );
	while ( isDefined( _k185 ) )
	{
		player = _a185[ _k185 ];
		if ( player is_bot() )
		{
		}
		else if ( isDefined( team ) )
		{
			if ( getassignedteam( player ) == team )
			{
				count++;
			}
		}
		else
		{
			count++;
		}
		_k185 = getNextArrayKey( _a185, _k185 );
	}
	return count;
}

bot_count_bots( team )
{
	players = get_players();
	count = 0;
	_a213 = players;
	_k213 = getFirstArrayKey( _a213 );
	while ( isDefined( _k213 ) )
	{
		player = _a213[ _k213 ];
		if ( !player is_bot() )
		{
		}
		else if ( isDefined( team ) )
		{
			if ( isDefined( player.team ) && player.team == team )
			{
				count++;
			}
		}
		else
		{
			count++;
		}
		_k213 = getNextArrayKey( _a213, _k213 );
	}
	return count;
}

bot_count_enemy_bots( friend_team )
{
	if ( !level.teambased )
	{
		return bot_count_bots();
	}
	enemies = 0;
	_a245 = level.teams;
	_k245 = getFirstArrayKey( _a245 );
	while ( isDefined( _k245 ) )
	{
		team = _a245[ _k245 ];
		if ( team == friend_team )
		{
		}
		else
		{
			enemies += bot_count_bots( team );
		}
		_k245 = getNextArrayKey( _a245, _k245 );
	}
	return enemies;
}

bot_choose_comp_stomp_team()
{
	host = gethostplayerforbots();
/#
	assert( isDefined( host ) );
#/
	teamkeys = getarraykeys( level.teams );
/#
	assert( teamkeys.size == 2 );
#/
	enemy_team = host.pers[ "team" ];
/#
	if ( isDefined( enemy_team ) )
	{
		assert( enemy_team != "spectator" );
	}
#/
	return getotherteam( enemy_team );
}

bot_comp_stomp_think( team )
{
	for ( ;; )
	{
		humans = bot_count_humans();
		bots = bot_count_bots();
		if ( humans == bots )
		{
			break;
		}
		else
		{
			if ( bots < humans )
			{
				spawn_bot( team );
			}
			if ( bots > humans )
			{
				bot_comp_stomp_remove( team );
			}
			wait 1;
		}
	}
	wait 3;
}
}

bot_comp_stomp_remove( team )
{
	players = get_players();
	bots = [];
	remove = undefined;
	_a310 = players;
	_k310 = getFirstArrayKey( _a310 );
	while ( isDefined( _k310 ) )
	{
		player = _a310[ _k310 ];
		if ( !isDefined( player.team ) )
		{
		}
		else if ( player is_bot() )
		{
			if ( level.teambased )
			{
				if ( player.team == team )
				{
					bots[ bots.size ] = player;
				}
				break;
			}
			else
			{
				bots[ bots.size ] = player;
			}
		}
		_k310 = getNextArrayKey( _a310, _k310 );
	}
	if ( !bots.size )
	{
		return;
	}
	_a339 = bots;
	_k339 = getFirstArrayKey( _a339 );
	while ( isDefined( _k339 ) )
	{
		bot = _a339[ _k339 ];
		if ( !bot maps/mp/bots/_bot_combat::bot_has_enemy() )
		{
			remove = bot;
			break;
		}
		else
		{
			_k339 = getNextArrayKey( _a339, _k339 );
		}
	}
	if ( !isDefined( remove ) )
	{
		remove = random( bots );
	}
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
	_a367 = level.teams;
	_k367 = getFirstArrayKey( _a367 );
	while ( isDefined( _k367 ) )
	{
		team = _a367[ _k367 ];
		count = countplayers( team );
		if ( count > high )
		{
			high = count;
			highest_team = team;
		}
		_k367 = getNextArrayKey( _a367, _k367 );
	}
	bot_comp_stomp_remove( highest_team );
}

bot_ranked_count( team )
{
	count = countplayers( team );
	if ( count < 6 )
	{
		spawn_bot( team );
		return 1;
	}
	else
	{
		if ( count > 6 )
		{
			bot_comp_stomp_remove( team );
			return 1;
		}
	}
	return 0;
}

bot_ranked_think()
{
	level endon( "game_ended" );
	wait 5;
	for ( ;; )
	{
		wait 1;
		teams = [];
		teams[ 0 ] = "axis";
		teams[ 1 ] = "allies";
		if ( cointoss() )
		{
			teams[ 0 ] = "allies";
			teams[ 1 ] = "axis";
		}
		if ( !bot_ranked_count( teams[ 0 ] ) && !bot_ranked_count( teams[ 1 ] ) )
		{
			break;
		}
		else
		{
		}
	}
	level waittill_any( "connected", "disconnect" );
	wait 5;
	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 1;
	}
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
			return 1;
		}
		if ( friends > expected_friends )
		{
			bot_comp_stomp_remove( host_team );
			return 1;
		}
	}
	return 0;
}

bot_local_enemies( expected_enemies, max, host_team )
{
	enemies = bot_count_enemy_bots( host_team );
	players = get_players();
	if ( enemies < expected_enemies && players.size < max )
	{
		team = getenemyteamwithlowestplayercount( host_team );
		spawn_bot( team );
		return 1;
	}
	if ( enemies > expected_enemies )
	{
		team = getenemyteamwithgreatestbotcount( host_team );
		if ( isDefined( team ) )
		{
			bot_comp_stomp_remove( team );
		}
		return 1;
	}
	return 0;
}

bot_local_think()
{
	wait 5;
	host = gethostplayerforbots();
/#
	assert( isDefined( host ) );
#/
	host_team = host.team;
	if ( !isDefined( host_team ) || host_team == "spectator" )
	{
		host_team = "allies";
	}
	bot_expected_friends = getDvarInt( "bot_friends" );
	bot_expected_enemies = getDvarInt( "bot_enemies" );
	if ( islocalgame() )
	{
	}
	else
	{
	}
	max_players = 18;
	for ( ;; )
	{
		if ( bot_local_friends( bot_expected_friends, max_players, host_team ) )
		{
			wait 0,5;
			continue;
		}
		else if ( bot_local_enemies( bot_expected_enemies, max_players, host_team ) )
		{
			wait 0,5;
			continue;
		}
		else
		{
		}
	}
	wait 3;
}
}

is_bot_ranked_match()
{
	bot_enemies = getDvarInt( "bot_enemies" );
	isdedicatedbotsoak = getDvarInt( #"E76315E0" );
	if ( level.rankedmatch && bot_enemies )
	{
		return isdedicatedbotsoak == 0;
	}
}

is_bot_comp_stomp()
{
	if ( is_bot_ranked_match() )
	{
		return !getDvarInt( "party_autoteams" );
	}
}

bot_spawn_think( team )
{
	self endon( "disconnect" );
	while ( !isDefined( self.pers[ "bot_loadout" ] ) )
	{
		wait 0,1;
	}
	while ( !isDefined( self.team ) )
	{
		wait 0,05;
	}
	if ( level.teambased )
	{
		self notify( "menuresponse" );
		wait 0,5;
	}
	self notify( "joined_team" );
	bot_classes = bot_build_classes();
	self notify( "menuresponse" );
}

bot_build_classes()
{
	bot_classes = [];
	if ( !self isitemlocked( maps/mp/gametypes/_rank::getitemindex( "feature_cac" ) ) )
	{
		bot_classes[ bot_classes.size ] = "custom0";
		bot_classes[ bot_classes.size ] = "custom1";
		bot_classes[ bot_classes.size ] = "custom2";
		bot_classes[ bot_classes.size ] = "custom3";
		bot_classes[ bot_classes.size ] = "custom4";
		if ( randomint( 100 ) < 10 )
		{
			bot_classes[ bot_classes.size ] = "class_smg";
			bot_classes[ bot_classes.size ] = "class_cqb";
			bot_classes[ bot_classes.size ] = "class_assault";
			bot_classes[ bot_classes.size ] = "class_lmg";
			bot_classes[ bot_classes.size ] = "class_sniper";
		}
	}
	else
	{
		bot_classes[ bot_classes.size ] = "class_smg";
		bot_classes[ bot_classes.size ] = "class_cqb";
		bot_classes[ bot_classes.size ] = "class_assault";
		bot_classes[ bot_classes.size ] = "class_lmg";
		bot_classes[ bot_classes.size ] = "class_sniper";
	}
	return bot_classes;
}

bot_choose_class()
{
	bot_classes = bot_build_classes();
	while ( !self maps/mp/bots/_bot_combat::threat_requires_rocket( self.bot.attacker ) && self maps/mp/bots/_bot_combat::threat_is_qrdrone( self.bot.attacker ) && !maps/mp/bots/_bot_combat::threat_is_warthog( self.bot.attacker ) )
	{
		if ( randomint( 100 ) < 75 )
		{
			bot_classes[ bot_classes.size ] = "class_smg";
			bot_classes[ bot_classes.size ] = "class_cqb";
			bot_classes[ bot_classes.size ] = "class_assault";
			bot_classes[ bot_classes.size ] = "class_lmg";
			bot_classes[ bot_classes.size ] = "class_sniper";
		}
		i = 0;
		while ( i < bot_classes.size )
		{
			sidearm = self getloadoutweapon( i, "secondary" );
			if ( sidearm == "fhj18_mp" )
			{
				self notify( "menuresponse" );
				return;
				i++;
				continue;
			}
			else
			{
				if ( sidearm == "smaw_mp" )
				{
					bot_classes[ bot_classes.size ] = bot_classes[ i ];
					bot_classes[ bot_classes.size ] = bot_classes[ i ];
					bot_classes[ bot_classes.size ] = bot_classes[ i ];
				}
			}
			i++;
		}
	}
	while ( maps/mp/bots/_bot_combat::threat_requires_rocket( self.bot.attacker ) || maps/mp/bots/_bot_combat::threat_is_warthog( self.bot.attacker ) )
	{
		i = 0;
		while ( i < bot_classes.size )
		{
			perks = self getloadoutperks( i );
			_a642 = perks;
			_k642 = getFirstArrayKey( _a642 );
			while ( isDefined( _k642 ) )
			{
				perk = _a642[ _k642 ];
				if ( perk == "specialty_nottargetedbyairsupport" )
				{
					bot_classes[ bot_classes.size ] = bot_classes[ i ];
					bot_classes[ bot_classes.size ] = bot_classes[ i ];
					bot_classes[ bot_classes.size ] = bot_classes[ i ];
				}
				_k642 = getNextArrayKey( _a642, _k642 );
			}
			i++;
		}
	}
	self notify( "menuresponse" );
}

bot_spawn()
{
	self endon( "disconnect" );
/#
	weapon = undefined;
	if ( getDvarInt( "scr_botsHasPlayerWeapon" ) != 0 )
	{
		player = gethostplayer();
		weapon = player getcurrentweapon();
	}
	if ( getDvar( "devgui_bot_weapon" ) != "" )
	{
		weapon = getDvar( "devgui_bot_weapon" );
	}
	if ( isDefined( weapon ) )
	{
		self maps/mp/gametypes/_weapons::detach_all_weapons();
		self takeallweapons();
		self giveweapon( weapon );
		self switchtoweapon( weapon );
		self setspawnweapon( weapon );
		self maps/mp/teams/_teams::set_player_model( self.team, weapon );
#/
	}
	self bot_spawn_init();
	if ( isDefined( self.bot_first_spawn ) )
	{
		self bot_choose_class();
	}
	self.bot_first_spawn = 1;
	self thread bot_main();
/#
	self thread bot_devgui_think();
#/
}

bot_spawn_init()
{
	time = getTime();
	if ( !isDefined( self.bot ) )
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
	switch( difficulty )
	{
		case "easy":
			self.bot.think_interval = 0,5;
			self.bot.fov = 0,4226;
			break;
		case "normal":
			self.bot.think_interval = 0,25;
			self.bot.fov = 0,0872;
			break;
		case "hard":
			self.bot.think_interval = 0,2;
			self.bot.fov = -0,1736;
			break;
		case "fu":
			self.bot.think_interval = 0,1;
			self.bot.fov = -0,9396;
			break;
		default:
			self.bot.think_interval = 0,25;
			self.bot.fov = 0,0872;
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
	for ( ;; )
	{
		wait self.bot.think_interval;
		self notify( "wakeup" );
	}
}

bot_damage_think()
{
	self notify( "bot_damage_think" );
	self endon( "bot_damage_think" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction, point, mod, unused1, unused2, unused3, weapon, flags, inflictor );
		if ( attacker.classname == "worldspawn" )
		{
			continue;
		}
		else if ( isDefined( weapon ) )
		{
			if ( weapon == "proximity_grenade_mp" || weapon == "proximity_grenade_aoe_mp" )
			{
				continue;
			}
			else if ( weapon == "claymore_mp" )
			{
				continue;
			}
			else if ( weapon == "satchel_charge_mp" )
			{
				continue;
			}
			else if ( weapon == "bouncingbetty_mp" )
			{
				continue;
			}
		}
		else
		{
			if ( isDefined( inflictor ) )
			{
				switch( inflictor.classname )
				{
					case "auto_turret":
					case "script_vehicle":
						attacker = inflictor;
						break;
					break;
				}
			}
			if ( isDefined( attacker.viewlockedentity ) )
			{
				attacker = attacker.viewlockedentity;
			}
			if ( maps/mp/bots/_bot_combat::threat_requires_rocket( attacker ) || maps/mp/bots/_bot_combat::threat_is_warthog( attacker ) )
			{
				level thread bot_killstreak_dangerous_think( self.origin, self.team, attacker );
			}
			self.bot.attacker = attacker;
			self notify( "wakeup" );
		}
	}
}

bot_killcam_think()
{
	self notify( "bot_killcam_think" );
	self endon( "bot_killcam_think" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	wait_time = 0,5;
	if ( level.playerrespawndelay )
	{
		wait_time = level.playerrespawndelay + 1,5;
	}
	if ( !level.killcam )
	{
		self waittill( "death" );
	}
	else
	{
		self waittill( "begin_killcam" );
	}
	wait wait_time;
	for ( ;; )
	{
		self pressusebutton( 0,1 );
		wait 0,5;
	}
}

bot_glass_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
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
		self.bot.update_failsafe = getTime() + randomintrange( 1000, 3000 );
	}
	self thread bot_wakeup_think();
	self thread bot_damage_think();
	self thread bot_killcam_think();
	self thread bot_glass_think();
	for ( ;; )
	{
		self waittill( "wakeup", damage, attacker, direction );
		if ( self isremotecontrolling() )
		{
			continue;
		}
		else
		{
			self maps/mp/bots/_bot_combat::bot_combat_think( damage, attacker, direction );
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
}

bot_failsafe_node_valid( nearest, node )
{
	if ( isDefined( node.script_noteworthy ) )
	{
		return 0;
	}
	if ( ( node.origin[ 2 ] - self.origin[ 2 ] ) > 18 )
	{
		return 0;
	}
	if ( nearest == node )
	{
		return 0;
	}
	if ( !nodesvisible( nearest, node ) )
	{
		return 0;
	}
	if ( self bot_friend_in_radius( node.origin, 32 ) )
	{
		return 0;
	}
	if ( isDefined( level.spawn_all ) && level.spawn_all.size > 0 )
	{
		spawns = arraysort( level.spawn_all, node.origin );
	}
	else
	{
		if ( isDefined( level.spawnpoints ) && level.spawnpoints.size > 0 )
		{
			spawns = arraysort( level.spawnpoints, node.origin );
		}
		else
		{
			if ( isDefined( level.spawn_start ) && level.spawn_start.size > 0 )
			{
				spawns = arraycombine( level.spawn_start[ "allies" ], level.spawn_start[ "axis" ], 1, 0 );
				spawns = arraysort( spawns, node.origin );
			}
			else
			{
				return 0;
			}
		}
	}
	goal = bot_nearest_node( spawns[ 0 ].origin );
	if ( isDefined( goal ) && findpath( node.origin, goal.origin, undefined, 0, 1 ) )
	{
		return 1;
	}
	return 0;
}

bot_get_mantle_start()
{
	dist = self getlookaheaddist();
	dir = self getlookaheaddir();
	if ( dist > 0 && isDefined( dir ) )
	{
		forward = anglesToForward( self.angles );
		if ( vectordot( dir, forward ) < 0 )
		{
			dir = vectorScale( dir, dist );
			origin = self.origin + dir;
			nodes = getnodesinradius( origin, 16, 0, 16, "Begin" );
			if ( nodes.size && nodes[ 0 ].spawnflags & 8388608 )
			{
				return nodes[ 0 ];
			}
		}
	}
	return undefined;
}

bot_is_traversing()
{
	if ( !self isonground() )
	{
		if ( !self ismantling() )
		{
			return !self isonladder();
		}
	}
	return 0;
}

bot_update_failsafe()
{
	time = getTime();
	if ( ( time - self.spawntime ) < 7500 )
	{
		return;
	}
	if ( bot_is_traversing() )
	{
		wait 0,25;
		node = bot_get_mantle_start();
		if ( isDefined( node ) )
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
	{
		return;
	}
	if ( !self ismantling() || self isonladder() && !self isonground() )
	{
		wait randomfloatrange( 0,1, 0,25 );
		return;
	}
	if ( !self atgoal() && distance2dsquared( self.bot.previous_origin, self.origin ) < 256 )
	{
		nodes = getnodesinradius( self.origin, 512, 0 );
		nodes = array_randomize( nodes );
		nearest = bot_nearest_node( self.origin );
		failsafe = 0;
		while ( isDefined( nearest ) )
		{
			_a1092 = nodes;
			_k1092 = getFirstArrayKey( _a1092 );
			while ( isDefined( _k1092 ) )
			{
				node = _a1092[ _k1092 ];
				if ( !bot_failsafe_node_valid( nearest, node ) )
				{
				}
				else
				{
					self botsetfailsafenode( node );
					wait 0,5;
					self.bot.update_idle_lookat = 0;
					self bot_update_lookat();
					self cancelgoal( "enemy_patrol" );
					self wait_endon( 4, "goal" );
					self botsetfailsafenode();
					self bot_update_lookat();
					failsafe = 1;
					break;
				}
				_k1092 = getNextArrayKey( _a1092, _k1092 );
			}
		}
		if ( !failsafe && nodes.size )
		{
			node = random( nodes );
			self botsetfailsafenode( node );
			wait 0,5;
			self.bot.update_idle_lookat = 0;
			self bot_update_lookat();
			self cancelgoal( "enemy_patrol" );
			self wait_endon( 4, "goal" );
			self botsetfailsafenode();
			self bot_update_lookat();
		}
	}
	self.bot.update_failsafe = getTime() + 3500;
	self.bot.previous_origin = self.origin;
}

bot_update_crouch()
{
	time = getTime();
	if ( time < self.bot.update_crouch )
	{
		return;
	}
	if ( self atgoal() )
	{
		return;
	}
	if ( !self ismantling() || self isonladder() && !self isonground() )
	{
		return;
	}
	dist = self getlookaheaddist();
	if ( dist > 0 )
	{
		dir = self getlookaheaddir();
/#
		assert( isDefined( dir ) );
#/
		dir = vectorScale( dir, dist );
		start = self.origin + vectorScale( ( 0, 0, 0 ), 70 );
		end = start + dir;
		if ( dist >= 256 )
		{
			self.bot.update_crouch = time + 1500;
		}
		if ( self getstance() == "stand" )
		{
			trace = worldtrace( start, end );
			if ( trace[ "fraction" ] < 1 )
			{
				self setstance( "crouch" );
				self.bot.update_crouch = time + 2500;
			}
			return;
		}
		else
		{
			if ( self getstance() == "crouch" )
			{
				trace = worldtrace( start, end );
				if ( trace[ "fraction" ] >= 1 )
				{
					self setstance( "stand" );
				}
			}
		}
	}
}

bot_update_glass()
{
	if ( isDefined( self.bot.glass_origin ) )
	{
		forward = anglesToForward( self.angles );
		dir = vectornormalize( self.bot.glass_origin - self.origin );
		dot = vectordot( forward, dir );
		if ( dot > 0 )
		{
			self lookat( self.bot.glass_origin );
			wait_time = 0,5 * ( 1 - dot );
			wait_time = clamp( wait_time, 0,05, 0,5 );
			wait wait_time;
			self pressmelee();
			wait 0,25;
			self clearlookat();
			self.bot.glass_origin = undefined;
		}
	}
}

bot_has_radar()
{
	if ( level.teambased )
	{
		if ( !maps/mp/killstreaks/_radar::teamhasspyplane( self.team ) )
		{
			return maps/mp/killstreaks/_radar::teamhassatellite( self.team );
		}
	}
	if ( isDefined( self.hasspyplane ) && !self.hasspyplane )
	{
		if ( isDefined( self.hassatellite ) )
		{
			return self.hassatellite;
		}
	}
}

bot_get_enemies( on_radar )
{
	if ( !isDefined( on_radar ) )
	{
		on_radar = 0;
	}
	enemies = self getenemies( 1 );
/#
	i = 0;
	while ( i < enemies.size )
	{
		if ( enemies[ i ] isinmovemode( "ufo", "noclip" ) )
		{
			arrayremoveindex( enemies, i );
			i--;

		}
		i++;
#/
	}
	while ( on_radar && !self bot_has_radar() )
	{
		i = 0;
		while ( i < enemies.size )
		{
			if ( !isDefined( enemies[ i ].lastfiretime ) )
			{
				arrayremoveindex( enemies, i );
				i--;

				i++;
				continue;
			}
			else
			{
				if ( ( getTime() - enemies[ i ].lastfiretime ) > 2000 )
				{
					arrayremoveindex( enemies, i );
					i--;

				}
			}
			i++;
		}
	}
	return enemies;
}

bot_get_friends()
{
	friends = self getfriendlies( 1 );
/#
	i = 0;
	while ( i < friends.size )
	{
		if ( friends[ i ] isinmovemode( "ufo", "noclip" ) )
		{
			arrayremoveindex( friends, i );
			i--;

		}
		i++;
#/
	}
	return friends;
}

bot_friend_goal_in_radius( goal_name, origin, radius )
{
	count = 0;
	friends = bot_get_friends();
	_a1290 = friends;
	_k1290 = getFirstArrayKey( _a1290 );
	while ( isDefined( _k1290 ) )
	{
		friend = _a1290[ _k1290 ];
		if ( friend is_bot() )
		{
			goal = friend getgoal( goal_name );
			if ( isDefined( goal ) && distancesquared( origin, goal ) < ( radius * radius ) )
			{
				count++;
			}
		}
		_k1290 = getNextArrayKey( _a1290, _k1290 );
	}
	return count;
}

bot_friend_in_radius( origin, radius )
{
	friends = bot_get_friends();
	_a1310 = friends;
	_k1310 = getFirstArrayKey( _a1310 );
	while ( isDefined( _k1310 ) )
	{
		friend = _a1310[ _k1310 ];
		if ( distancesquared( friend.origin, origin ) < ( radius * radius ) )
		{
			return 1;
		}
		_k1310 = getNextArrayKey( _a1310, _k1310 );
	}
	return 0;
}

bot_get_closest_enemy( origin, on_radar )
{
	enemies = self bot_get_enemies( on_radar );
	enemies = arraysort( enemies, origin );
	if ( enemies.size )
	{
		return enemies[ 0 ];
	}
	return undefined;
}

bot_update_wander()
{
	goal = self getgoal( "wander" );
	if ( isDefined( goal ) )
	{
		if ( distancesquared( goal, self.origin ) > 65536 )
		{
			return;
		}
	}
	if ( isDefined( level.spawn_all ) && level.spawn_all.size > 0 )
	{
		spawns = arraysort( level.spawn_all, self.origin );
	}
	else
	{
		if ( isDefined( level.spawnpoints ) && level.spawnpoints.size > 0 )
		{
			spawns = arraysort( level.spawnpoints, self.origin );
		}
		else
		{
			if ( isDefined( level.spawn_start ) && level.spawn_start.size > 0 )
			{
				spawns = arraycombine( level.spawn_start[ "allies" ], level.spawn_start[ "axis" ], 1, 0 );
				spawns = arraysort( spawns, self.origin );
			}
			else
			{
				return;
			}
		}
	}
	far = int( spawns.size / 2 );
	far = randomintrange( far, spawns.size );
	goal = bot_nearest_node( spawns[ far ].origin );
	if ( !isDefined( goal ) )
	{
		return;
	}
	self addgoal( goal, 24, 1, "wander" );
}

bot_get_look_at()
{
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( self.origin, 1 );
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
		if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
		{
			return node.origin;
		}
	}
	enemies = self maps/mp/bots/_bot::bot_get_enemies( 0 );
	if ( enemies.size )
	{
		enemy = random( enemies );
	}
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
		if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
		{
			return node.origin;
		}
	}
	spawn = self getgoal( "wander" );
	if ( isDefined( spawn ) )
	{
		node = getvisiblenode( self.origin, spawn );
	}
	if ( isDefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
	{
		return node.origin;
	}
	return undefined;
}

bot_update_lookat()
{
	path = isDefined( self getlookaheaddir() );
	if ( !path && getTime() > self.bot.update_idle_lookat )
	{
		origin = bot_get_look_at();
		if ( !isDefined( origin ) )
		{
			return;
		}
		self lookat( origin + vectorScale( ( 0, 0, 0 ), 16 ) );
		self.bot.update_idle_lookat = getTime() + randomintrange( 1500, 3000 );
	}
	else
	{
		if ( path && self.bot.update_idle_lookat > 0 )
		{
			self clearlookat();
			self.bot.update_idle_lookat = 0;
		}
	}
}

bot_update_patrol()
{
	closest = bot_get_closest_enemy( self.origin, 1 );
	if ( isDefined( closest ) && distancesquared( self.origin, closest.origin ) < 262144 )
	{
		goal = self getgoal( "enemy_patrol" );
		if ( isDefined( goal ) && distancesquared( goal, closest.origin ) > 16384 )
		{
			self cancelgoal( "enemy_patrol" );
			self.bot.update_patrol = 0;
		}
	}
	if ( getTime() < self.bot.update_patrol )
	{
		return;
	}
	self maps/mp/bots/_bot_combat::bot_patrol_near_enemy();
	self.bot.update_patrol = getTime() + randomintrange( 5000, 10000 );
}

bot_update_toss_flash()
{
	if ( bot_get_difficulty() == "easy" )
	{
		return;
	}
	time = getTime();
	if ( ( time - self.spawntime ) < 7500 )
	{
		return;
	}
	if ( time < self.bot.update_toss )
	{
		return;
	}
	self.bot.update_toss = time + 1500;
	if ( self getweaponammostock( "sensor_grenade_mp" ) <= 0 && self getweaponammostock( "proximity_grenade_mp" ) <= 0 && self getweaponammostock( "trophy_system_mp" ) <= 0 )
	{
		return;
	}
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( self.origin, 1 );
	node = undefined;
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
	}
	if ( isDefined( node ) && distancesquared( self.origin, node.origin ) < 65536 )
	{
		self lookat( node.origin );
		wait 0,75;
		self pressattackbutton( 2 );
		self.bot.update_toss = time + 20000;
		self clearlookat();
	}
}

bot_update_toss_frag()
{
	if ( bot_get_difficulty() == "easy" )
	{
		return;
	}
	time = getTime();
	if ( ( time - self.spawntime ) < 7500 )
	{
		return;
	}
	if ( time < self.bot.update_toss )
	{
		return;
	}
	self.bot.update_toss = time + 1500;
	if ( self getweaponammostock( "bouncingbetty_mp" ) <= 0 && self getweaponammostock( "claymore_mp" ) <= 0 && self getweaponammostock( "satchel_charge_mp" ) <= 0 )
	{
		return;
	}
	enemy = self maps/mp/bots/_bot::bot_get_closest_enemy( self.origin, 1 );
	node = undefined;
	if ( isDefined( enemy ) )
	{
		node = getvisiblenode( self.origin, enemy.origin );
	}
	if ( isDefined( node ) && distancesquared( self.origin, node.origin ) < 65536 )
	{
		self lookat( node.origin );
		wait 0,75;
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
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] == self )
		{
			i++;
			continue;
		}
		else if ( isDefined( players[ i ].pers[ "rank" ] ) )
		{
			if ( players[ i ] is_bot() )
			{
				bot_ranks[ bot_ranks.size ] = players[ i ].pers[ "rank" ];
				i++;
				continue;
			}
			else
			{
				human_ranks[ human_ranks.size ] = players[ i ].pers[ "rank" ];
			}
		}
		i++;
	}
	if ( !human_ranks.size )
	{
		human_ranks[ human_ranks.size ] = 10;
	}
	human_avg = array_average( human_ranks );
	while ( ( bot_ranks.size + human_ranks.size ) < 5 )
	{
		r = human_avg + randomintrange( -5, 5 );
		rank = clamp( r, 0, level.maxrank );
		human_ranks[ human_ranks.size ] = rank;
	}
	ranks = arraycombine( human_ranks, bot_ranks, 1, 0 );
	avg = array_average( ranks );
	s = array_std_deviation( ranks, avg );
	rank = int( random_normal_distribution( avg, s, 0, level.maxrank ) );
	self.pers[ "rank" ] = rank;
	self.pers[ "rankxp" ] = maps/mp/gametypes/_rank::getrankinfominxp( rank );
	self setrank( rank );
	self maps/mp/gametypes/_rank::syncxpstat();
}

bot_gametype_allowed()
{
	level.bot_gametype = ::gametype_void;
	switch( level.gametype )
	{
		case "dm":
		case "tdm":
			return 1;
		case "ctf":
			level.bot_gametype = ::maps/mp/bots/_bot_ctf::bot_ctf_think;
			return 1;
		case "dem":
			level.bot_gametype = ::maps/mp/bots/_bot_dem::bot_dem_think;
			return 1;
		case "dom":
			level.bot_gametype = ::maps/mp/bots/_bot_dom::bot_dom_think;
			return 1;
		case "koth":
			level.bot_gametype = ::maps/mp/bots/_bot_koth::bot_koth_think;
			return 1;
		case "hq":
			level.bot_gametype = ::maps/mp/bots/_bot_hq::bot_hq_think;
			return 1;
		case "conf":
			level.bot_gametype = ::maps/mp/bots/_bot_conf::bot_conf_think;
			return 1;
	}
	return 0;
}

bot_get_difficulty()
{
	if ( !isDefined( level.bot_difficulty ) )
	{
		level.bot_difficulty = "normal";
		difficulty = getdvarintdefault( "bot_difficulty", 1 );
		if ( difficulty == 0 )
		{
			level.bot_difficulty = "easy";
		}
		else if ( difficulty == 1 )
		{
			level.bot_difficulty = "normal";
		}
		else if ( difficulty == 2 )
		{
			level.bot_difficulty = "hard";
		}
		else
		{
			if ( difficulty == 3 )
			{
				level.bot_difficulty = "fu";
			}
		}
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
	if ( level.gametype == "oic" || difficulty == "hard" && difficulty == "fu" )
	{
		setdvar( "bot_SprintDistance", "256" );
	}
}

bot_update_c4()
{
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		return;
	}
	time = getTime();
	if ( time < self.bot.update_c4 )
	{
		return;
	}
	self.bot.update_c4 = time + randomintrange( 1000, 2000 );
	radius = getweaponexplosionradius( "satchel_charge_mp" );
	_a1817 = self.weaponobjectwatcherarray;
	_k1817 = getFirstArrayKey( _a1817 );
	while ( isDefined( _k1817 ) )
	{
		watcher = _a1817[ _k1817 ];
		if ( watcher.name == "satchel_charge" )
		{
			break;
		}
		else
		{
			_k1817 = getNextArrayKey( _a1817, _k1817 );
		}
	}
	while ( watcher.objectarray.size )
	{
		_a1827 = watcher.objectarray;
		_k1827 = getFirstArrayKey( _a1827 );
		while ( isDefined( _k1827 ) )
		{
			weapon = _a1827[ _k1827 ];
			if ( !isDefined( weapon ) )
			{
			}
			else
			{
				enemy = bot_get_closest_enemy( weapon.origin, 0 );
				if ( !isDefined( enemy ) )
				{
					return;
				}
				if ( distancesquared( enemy.origin, weapon.origin ) < ( radius * radius ) )
				{
					self pressattackbutton( 1 );
					return;
				}
			}
			_k1827 = getNextArrayKey( _a1827, _k1827 );
		}
	}
}

bot_update_launcher()
{
	time = getTime();
	if ( time < self.bot.update_launcher )
	{
		return;
	}
	self.bot.update_launcher = time + randomintrange( 5000, 10000 );
	if ( !self maps/mp/bots/_bot_combat::bot_has_launcher() )
	{
		return;
	}
	enemies = self getthreats( -1 );
	_a1868 = enemies;
	_k1868 = getFirstArrayKey( _a1868 );
	while ( isDefined( _k1868 ) )
	{
		enemy = _a1868[ _k1868 ];
		if ( !target_istarget( enemy ) )
		{
		}
		else if ( maps/mp/bots/_bot_combat::threat_is_warthog( enemy ) )
		{
		}
		else if ( !maps/mp/bots/_bot_combat::threat_requires_rocket( enemy ) )
		{
		}
		else origin = self getplayercamerapos();
		angles = vectorToAngle( enemy.origin - origin );
		if ( angles[ 0 ] < 290 )
		{
		}
		else
		{
			if ( self botsighttracepassed( enemy ) )
			{
				self maps/mp/bots/_bot_combat::bot_lookat_entity( enemy );
				return;
			}
		}
		_k1868 = getNextArrayKey( _a1868, _k1868 );
	}
}

bot_update_weapon()
{
	time = getTime();
	if ( time < self.bot.update_weapon )
	{
		return;
	}
	self.bot.update_weapon = time + randomintrange( 5000, 7500 );
	weapon = self getcurrentweapon();
	ammo = self getweaponammoclip( weapon ) + self getweaponammostock( weapon );
	if ( weapon == "none" )
	{
		return;
	}
	if ( self maps/mp/bots/_bot_combat::bot_can_reload() )
	{
		frac = 0,5;
		if ( maps/mp/bots/_bot_combat::bot_has_lmg() )
		{
			frac = 0,25;
		}
		frac += randomfloatrange( -0,1, 0,1 );
		if ( maps/mp/bots/_bot_combat::bot_weapon_ammo_frac() < frac )
		{
			self pressusebutton( 0,1 );
			return;
		}
	}
	if ( ammo && !self maps/mp/bots/_bot_combat::bot_has_pistol() && !self maps/mp/bots/_bot_combat::bot_using_launcher() )
	{
		return;
	}
	primaries = self getweaponslistprimaries();
	_a1946 = primaries;
	_k1946 = getFirstArrayKey( _a1946 );
	while ( isDefined( _k1946 ) )
	{
		primary = _a1946[ _k1946 ];
		if ( primary == "knife_held_mp" )
		{
		}
		else
		{
			if ( primary != weapon || self getweaponammoclip( primary ) && self getweaponammostock( primary ) )
			{
				self switchtoweapon( primary );
				return;
			}
		}
		_k1946 = getNextArrayKey( _a1946, _k1946 );
	}
}

bot_update_crate()
{
	time = getTime();
	if ( time < self.bot.update_crate )
	{
		return;
	}
	self.bot.update_crate = time + randomintrange( 1000, 3000 );
	self cancelgoal( "care package" );
	radius = getDvarFloat( "player_useRadius" );
	crates = getentarray( "care_package", "script_noteworthy" );
	_a1977 = crates;
	_k1977 = getFirstArrayKey( _a1977 );
	while ( isDefined( _k1977 ) )
	{
		crate = _a1977[ _k1977 ];
		if ( distancesquared( self.origin, crate.origin ) < ( radius * radius ) )
		{
			if ( isDefined( crate.hacker ) )
			{
				if ( crate.hacker == self )
				{
					break;
				}
				else if ( crate.hacker.team == self.team )
				{
					break;
				}
			}
			else
			{
				if ( crate.owner == self )
				{
					time = ( level.crateownerusetime / 1000 ) + 0,5;
				}
				else
				{
					time = ( level.cratenonownerusetime / 1000 ) + 0,5;
				}
				self setstance( "crouch" );
				self addgoal( self.origin, 24, 4, "care package" );
				self pressusebutton( time );
				wait time;
				self setstance( "stand" );
				self cancelgoal( "care package" );
				self.bot.update_crate = getTime() + randomintrange( 1000, 3000 );
				return;
			}
		}
		_k1977 = getNextArrayKey( _a1977, _k1977 );
	}
	while ( self getweaponammostock( "pda_hack_mp" ) )
	{
		_a2020 = crates;
		_k2020 = getFirstArrayKey( _a2020 );
		while ( isDefined( _k2020 ) )
		{
			crate = _a2020[ _k2020 ];
			if ( !isDefined( crate.friendlyobjid ) )
			{
			}
			else if ( isDefined( crate.hacker ) )
			{
				if ( crate.hacker == self )
				{
				}
				else if ( crate.hacker.team == self.team )
				{
				}
			}
			else
			{
				if ( self botsighttracepassed( crate ) )
				{
					self lookat( crate.origin );
					self addgoal( self.origin, 24, 4, "care package" );
					wait 0,75;
					start = getTime();
					if ( !isDefined( crate.owner ) )
					{
						self cancelgoal( "care package" );
						return;
					}
					if ( crate.owner == self )
					{
						end = level.crateownerusetime + 1000;
					}
					else
					{
						end = level.cratenonownerusetime + 1000;
					}
					while ( getTime() < ( start + end ) )
					{
						self pressattackbutton( 2 );
						wait 0,05;
					}
					self.bot.update_crate = getTime() + randomintrange( 1000, 3000 );
					self cancelgoal( "care package" );
					return;
				}
			}
			_k2020 = getNextArrayKey( _a2020, _k2020 );
		}
	}
}

bot_update_killstreak()
{
	if ( !level.loadoutkillstreaksenabled )
	{
		return;
	}
	time = getTime();
	if ( time < self.bot.update_killstreak )
	{
		return;
	}
	if ( self isweaponviewonlylinked() )
	{
		return;
	}
/#
	if ( !getDvarInt( "scr_botsAllowKillstreaks" ) )
	{
		return;
#/
	}
	self.bot.update_killstreak = time + randomintrange( 1000, 3000 );
	weapons = self getweaponslist();
	ks_weapon = undefined;
	inventoryweapon = self getinventoryweapon();
	_a2109 = weapons;
	_k2109 = getFirstArrayKey( _a2109 );
	while ( isDefined( _k2109 ) )
	{
		weapon = _a2109[ _k2109 ];
		if ( self getweaponammoclip( weapon ) <= 0 || !isDefined( inventoryweapon ) && weapon != inventoryweapon )
		{
		}
		else
		{
			if ( iskillstreakweapon( weapon ) )
			{
				killstreak = maps/mp/killstreaks/_killstreaks::getkillstreakforweapon( weapon );
				if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( killstreak, self.team ) )
				{
					ks_weapon = weapon;
					break;
				}
			}
		}
		else
		{
			_k2109 = getNextArrayKey( _a2109, _k2109 );
		}
	}
	if ( !isDefined( ks_weapon ) )
	{
		return;
	}
	killstreak = maps/mp/killstreaks/_killstreaks::getkillstreakforweapon( ks_weapon );
	killstreak_ref = maps/mp/killstreaks/_killstreaks::getkillstreakmenuname( killstreak );
	if ( !isDefined( killstreak_ref ) )
	{
		return;
	}
	switch( killstreak_ref )
	{
		case "killstreak_helicopter_comlink":
			bot_killstreak_location( 1, weapon );
			break;
		case "killstreak_planemortar":
			bot_killstreak_location( 3, weapon );
			break;
		case "killstreak_ai_tank_drop":
		case "killstreak_missile_drone":
		case "killstreak_supply_drop":
			self bot_use_supply_drop( weapon );
			break;
		case "killstreak_auto_turret":
		case "killstreak_microwave_turret":
		case "killstreak_tow_turret":
			self bot_turret_location( weapon );
			break;
		case "killstreak_helicopter_player_gunner":
		case "killstreak_qrdrone":
		case "killstreak_rcbomb":
		case "killstreak_remote_mortar":
			return;
			case "killstreak_remote_missile":
				if ( ( time - self.spawntime ) < 6000 )
				{
					self switchtoweapon( weapon );
					self waittill( "weapon_change_complete" );
					wait 1,5;
					self pressattackbutton();
				}
				return;
				default:
					self switchtoweapon( weapon );
					break;
			}
		}
	}
}

bot_get_vehicle_entity()
{
	if ( self isremotecontrolling() )
	{
		if ( isDefined( self.rcbomb ) )
		{
			return self.rcbomb;
		}
		else
		{
			if ( isDefined( self.qrdrone ) )
			{
				return self.qrdrone;
			}
		}
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
	for ( ;; )
	{
		wait 0,5;
		ent = self bot_get_vehicle_entity();
		if ( !isDefined( ent ) )
		{
			return;
		}
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( player == self )
			{
				i++;
				continue;
			}
			else if ( !isalive( player ) )
			{
				i++;
				continue;
			}
			else if ( level.teambased && player.team == self.team )
			{
				i++;
				continue;
			}
			else
			{
/#
				if ( player isinmovemode( "ufo", "noclip" ) )
				{
					i++;
					continue;
#/
				}
				else if ( bot_get_difficulty() == "easy" )
				{
					if ( distancesquared( ent.origin, player.origin ) < 262144 )
					{
						self pressattackbutton();
					}
					i++;
					continue;
				}
				else
				{
					if ( distancesquared( ent.origin, player.origin ) < 40000 )
					{
						self pressattackbutton();
					}
				}
			}
			i++;
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
	for ( ;; )
	{
		wait 1;
		ent = bot_get_vehicle_entity();
		if ( !isDefined( ent ) )
		{
			return;
		}
		if ( distancesquared( og_origin, ent.origin ) < 256 )
		{
			wait 2;
			if ( !isDefined( ent ) )
			{
				return;
			}
			if ( distancesquared( og_origin, ent.origin ) < 256 )
			{
				self pressattackbutton();
			}
		}
		og_origin = ent.origin;
	}
}

bot_turret_location( weapon )
{
	enemy = bot_get_closest_enemy( self.origin );
	if ( !isDefined( enemy ) )
	{
		return;
	}
	forward = anglesToForward( self getplayerangles() );
	forward = vectornormalize( forward );
	delta = enemy.origin - self.origin;
	delta = vectornormalize( delta );
	dot = vectordot( forward, delta );
	if ( dot < 0,707 )
	{
		return;
	}
	node = getvisiblenode( self.origin, enemy.origin );
	if ( !isDefined( node ) )
	{
		return;
	}
	if ( distancesquared( self.origin, node.origin ) < 262144 )
	{
		return;
	}
	delta = node.origin - self.origin;
	delta = vectornormalize( delta );
	dot = vectordot( forward, delta );
	if ( dot < 0,707 )
	{
		return;
	}
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
		if ( ( getTime() - self.spawntime ) > 5000 )
		{
			return;
		}
	}
	yaw = ( 0, self.angles[ 1 ], 0 );
	dir = anglesToForward( yaw );
	dir = vectornormalize( dir );
	drop_point = self.origin + vectorScale( dir, 384 );
	end = drop_point + vectorScale( ( 0, 0, 0 ), 2048 );
	if ( !sighttracepassed( drop_point, end, 0, undefined ) )
	{
		return;
	}
	if ( !sighttracepassed( self.origin, end, 0, undefined ) )
	{
		return;
	}
	end = drop_point - vectorScale( ( 0, 0, 0 ), 32 );
	if ( bullettracepassed( drop_point, end, 0, undefined ) )
	{
		return;
	}
	self addgoal( self.origin, 24, 4, "killstreak" );
	if ( weapon == "missile_drone_mp" || weapon == "inventory_missile_drone_mp" )
	{
		self lookat( drop_point + vectorScale( ( 0, 0, 0 ), 384 ) );
	}
	else
	{
		self lookat( drop_point );
	}
	wait 0,5;
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
	wait 0,5;
	i = 0;
	while ( i < 10 )
	{
		if ( self getcurrentweapon() == weapon || self getcurrentweapon() == "none" )
		{
			self pressattackbutton();
		}
		else
		{
			return;
		}
		wait 0,5;
		i++;
	}
}

bot_killstreak_location( num, weapon )
{
	enemies = bot_get_enemies();
	if ( !enemies.size )
	{
		return;
	}
	if ( !self switchtoweapon( weapon ) )
	{
		return;
	}
	self waittill( "weapon_change" );
	self freeze_player_controls( 1 );
	wait_time = 1;
	while ( !isDefined( self.selectinglocation ) || self.selectinglocation == 0 )
	{
		wait 0,05;
		wait_time -= 0,05;
		if ( wait_time <= 0 )
		{
			self freeze_player_controls( 0 );
			self switchtoweapon( self.lastnonkillstreakweapon );
			return;
		}
	}
	wait 2;
	i = 0;
	while ( i < num )
	{
		enemies = bot_get_enemies();
		if ( enemies.size )
		{
			enemy = random( enemies );
			self notify( "confirm_location" );
		}
		wait 0,25;
		i++;
	}
	self freeze_player_controls( 0 );
}

bot_killstreak_dangerous_think( origin, team, attacker )
{
	if ( !level.teambased )
	{
		return;
	}
	nodes = getnodesinradius( origin + vectorScale( ( 0, 0, 0 ), 384 ), 384, 0 );
	_a2505 = nodes;
	_k2505 = getFirstArrayKey( _a2505 );
	while ( isDefined( _k2505 ) )
	{
		node = _a2505[ _k2505 ];
		if ( node isdangerous( team ) )
		{
			return;
		}
		_k2505 = getNextArrayKey( _a2505, _k2505 );
	}
	_a2513 = nodes;
	_k2513 = getFirstArrayKey( _a2513 );
	while ( isDefined( _k2513 ) )
	{
		node = _a2513[ _k2513 ];
		node setdangerous( team, 1 );
		_k2513 = getNextArrayKey( _a2513, _k2513 );
	}
	attacker wait_endon( 25, "death" );
	_a2520 = nodes;
	_k2520 = getFirstArrayKey( _a2520 );
	while ( isDefined( _k2520 ) )
	{
		node = _a2520[ _k2520 ];
		node setdangerous( team, 0 );
		_k2520 = getNextArrayKey( _a2520, _k2520 );
	}
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
	event = self waittill_any_timeout( 0,25, "dtp_start" );
	if ( event == "dtp_start" )
	{
		self waittill( "dtp_end" );
		self setstance( "prone" );
		wait 0,35;
		self setstance( exit_stance );
	}
}

gametype_void()
{
}

bot_debug_star( origin, seconds, color )
{
/#
	if ( !isDefined( seconds ) )
	{
		seconds = 1;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 0 );
	}
	frames = int( 20 * seconds );
	debugstar( origin, frames, color );
#/
}

bot_debug_circle( origin, radius, seconds, color )
{
/#
	if ( !isDefined( seconds ) )
	{
		seconds = 1;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 0 );
	}
	frames = int( 20 * seconds );
	circle( origin, radius, color, 0, 1, frames );
#/
}

bot_debug_box( origin, mins, maxs, yaw, seconds, color )
{
/#
	if ( !isDefined( yaw ) )
	{
		yaw = 0;
	}
	if ( !isDefined( seconds ) )
	{
		seconds = 1;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 0 );
	}
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
	for ( ;; )
	{
		wait 1;
		reset = 1;
		switch( getDvar( "devgui_bot" ) )
		{
			case "crosshair":
				if ( getDvarInt( "scr_bot_follow" ) != 0 )
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
		{
			setdvar( "devgui_bot", "" );
		}
#/
	}
}

bot_system_devgui_think()
{
/#
	setdvar( "devgui_bot", "" );
	setdvar( "devgui_bot_weapon", "" );
	for ( ;; )
	{
		wait 1;
		reset = 1;
		switch( getDvar( "devgui_bot" ) )
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
			case "loadout":
			case "player_weapon":
				players = get_players();
				_a2692 = players;
				_k2692 = getFirstArrayKey( _a2692 );
				while ( isDefined( _k2692 ) )
				{
					player = _a2692[ _k2692 ];
					if ( !player is_bot() )
					{
					}
					else
					{
						host = gethostplayer();
						weapon = host getcurrentweapon();
						player maps/mp/gametypes/_weapons::detach_all_weapons();
						player takeallweapons();
						player giveweapon( weapon );
						player switchtoweapon( weapon );
						player setspawnweapon( weapon );
						player maps/mp/teams/_teams::set_player_model( player.team, weapon );
					}
					_k2692 = getNextArrayKey( _a2692, _k2692 );
				}
				case "routes":
					devgui_debug_route();
					break;
				case "":
				default:
					reset = 0;
					break;
			}
			if ( reset )
			{
				setdvar( "devgui_bot", "" );
			}
#/
		}
	}
}

bot_crosshair_follow()
{
/#
	self notify( "crosshair_follow_off" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "crosshair_follow_off" );
	for ( ;; )
	{
		wait 1;
		setdvar( "bot_AllowMovement", "1" );
		setdvar( "bot_IgnoreHumans", "1" );
		setdvar( "bot_ForceStand", "1" );
		player = gethostplayerforbots();
		direction = player getplayerangles();
		direction_vec = anglesToForward( direction );
		eye = player geteye();
		scale = 8000;
		direction_vec = ( direction_vec[ 0 ] * scale, direction_vec[ 1 ] * scale, direction_vec[ 2 ] * scale );
		trace = bullettrace( eye, eye + direction_vec, 0, undefined );
		origin = trace[ "position" ] + ( 0, 0, 0 );
		if ( distancesquared( self.origin, origin ) > 16384 )
		{
		}
#/
	}
}

bot_debug_patrol( node1, node2 )
{
/#
	self endon( "death" );
	self endon( "debug_patrol" );
	for ( ;; )
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
#/
	}
}

devgui_debug_route()
{
/#
	iprintln( "Choose nodes with 'A' or press 'B' to cancel" );
	nodes = maps/mp/gametypes/_dev::dev_get_node_pair();
	if ( !isDefined( nodes ) )
	{
		iprintln( "Route Debug Cancelled" );
		return;
	}
	iprintln( "Sending bots to chosen nodes" );
	players = get_players();
	_a2804 = players;
	_k2804 = getFirstArrayKey( _a2804 );
	while ( isDefined( _k2804 ) )
	{
		player = _a2804[ _k2804 ];
		if ( !player is_bot() )
		{
		}
		else
		{
			player notify( "debug_patrol" );
			player thread bot_debug_patrol( nodes[ 0 ], nodes[ 1 ] );
		}
		_k2804 = getNextArrayKey( _a2804, _k2804 );
#/
	}
}

devgui_bot_spawn( team )
{
/#
	player = gethostplayer();
	direction = player getplayerangles();
	direction_vec = anglesToForward( direction );
	eye = player geteye();
	scale = 8000;
	direction_vec = ( direction_vec[ 0 ] * scale, direction_vec[ 1 ] * scale, direction_vec[ 2 ] * scale );
	trace = bullettrace( eye, eye + direction_vec, 0, undefined );
	direction_vec = player.origin - trace[ "position" ];
	direction = vectorToAngle( direction_vec );
	bot = addtestclient();
	if ( !isDefined( bot ) )
	{
		println( "Could not add test client" );
		return;
	}
	bot.pers[ "isBot" ] = 1;
	bot thread bot_spawn_think( team );
	yaw = direction[ 1 ];
	bot thread devgui_bot_spawn_think( trace[ "position" ], yaw );
#/
}

devgui_bot_spawn_think( origin, yaw )
{
/#
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self setorigin( origin );
		angles = ( 0, yaw, 0 );
		self setplayerangles( angles );
#/
	}
}
