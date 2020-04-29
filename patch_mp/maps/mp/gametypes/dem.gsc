#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_challenges;
#include maps/mp/_popups;
#include maps/mp/_demo;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_spectating;
#include maps/mp/_scoreevents;
#include maps/mp/_medals;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_globallogic_defaults;
#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;

main()
{
	if ( getDvar( "mapname" ) == "mp_background" )
	{
		return;
	}
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	registerroundswitch( 0, 9 );
	registertimelimit( 0, 1440 );
	registerscorelimit( 0, 500 );
	registerroundlimit( 0, 12 );
	registerroundwinlimit( 0, 10 );
	registernumlives( 0, 100 );
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.teambased = 1;
	level.overrideteamscore = 1;
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.playerspawnedcb = ::dem_playerspawnedcb;
	level.onplayerkilled = ::onplayerkilled;
	level.ondeadevent = ::ondeadevent;
	level.ononeleftevent = ::ononeleftevent;
	level.ontimelimit = ::ontimelimit;
	level.onroundswitch = ::onroundswitch;
	level.getteamkillpenalty = ::dem_getteamkillpenalty;
	level.getteamkillscore = ::dem_getteamkillscore;
	level.gamemodespawndvars = ::gamemodespawndvars;
	level.gettimelimit = ::gettimelimit;
	level.shouldplayovertimeround = ::shouldplayovertimeround;
	level.lastbombexplodetime = undefined;
	level.lastbombexplodebyteam = undefined;
	level.ddbombmodel = [];
	level.endgameonscorelimit = 0;
	game[ "dialog" ][ "gametype" ] = "demo_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hcdemo_start";
	game[ "dialog" ][ "offense_obj" ] = "destroy_start";
	game[ "dialog" ][ "defense_obj" ] = "defend_start";
	game[ "dialog" ][ "sudden_death" ] = "suddendeath";
	if ( !sessionmodeissystemlink() && !sessionmodeisonlinegame() && issplitscreen() )
	{
		setscoreboardcolumns( "score", "kills", "plants", "defuses", "deaths" );
	}
	else
	{
		setscoreboardcolumns( "score", "kills", "deaths", "plants", "defuses" );
	}
}

onprecachegametype()
{
	game[ "bombmodelname" ] = "t5_weapon_briefcase_bomb_world";
	game[ "bombmodelnameobj" ] = "t5_weapon_briefcase_bomb_world";
	game[ "bomb_dropped_sound" ] = "mpl_flag_drop_plr";
	game[ "bomb_recovered_sound" ] = "mpl_flag_pickup_plr";
	precachemodel( game[ "bombmodelname" ] );
	precachemodel( game[ "bombmodelnameobj" ] );
	precacheshader( "waypoint_bomb" );
	precacheshader( "hud_suitcase_bomb" );
	precacheshader( "waypoint_target" );
	precacheshader( "waypoint_target_a" );
	precacheshader( "waypoint_target_b" );
	precacheshader( "waypoint_defend" );
	precacheshader( "waypoint_defend_a" );
	precacheshader( "waypoint_defend_b" );
	precacheshader( "waypoint_defuse" );
	precacheshader( "waypoint_defuse_a" );
	precacheshader( "waypoint_defuse_b" );
	precacheshader( "compass_waypoint_target" );
	precacheshader( "compass_waypoint_target_a" );
	precacheshader( "compass_waypoint_target_b" );
	precacheshader( "compass_waypoint_defend" );
	precacheshader( "compass_waypoint_defend_a" );
	precacheshader( "compass_waypoint_defend_b" );
	precacheshader( "compass_waypoint_defuse" );
	precacheshader( "compass_waypoint_defuse_a" );
	precacheshader( "compass_waypoint_defuse_b" );
	precachestring( &"MP_EXPLOSIVES_RECOVERED_BY" );
	precachestring( &"MP_EXPLOSIVES_DROPPED_BY" );
	precachestring( &"MP_EXPLOSIVES_PLANTED_BY" );
	precachestring( &"MP_EXPLOSIVES_DEFUSED_BY" );
	precachestring( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	precachestring( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	precachestring( &"MP_PLANTING_EXPLOSIVE" );
	precachestring( &"MP_DEFUSING_EXPLOSIVE" );
	precachestring( &"MP_TIME_EXTENDED" );
}

dem_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon )
{
	teamkill_penalty = maps/mp/gametypes/_globallogic_defaults::default_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon );
	if ( isDefined( self.isdefusing ) || self.isdefusing && isDefined( self.isplanting ) && self.isplanting )
	{
		teamkill_penalty *= level.teamkillpenaltymultiplier;
	}
	return teamkill_penalty;
}

dem_getteamkillscore( einflictor, attacker, smeansofdeath, sweapon )
{
	teamkill_score = maps/mp/gametypes/_rank::getscoreinfovalue( "team_kill" );
	if ( isDefined( self.isdefusing ) || self.isdefusing && isDefined( self.isplanting ) && self.isplanting )
	{
		teamkill_score *= level.teamkillscoremultiplier;
	}
	return int( teamkill_score );
}

onroundswitch()
{
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	if ( game[ "teamScores" ][ "allies" ] == ( level.scorelimit - 1 ) && game[ "teamScores" ][ "axis" ] == ( level.scorelimit - 1 ) )
	{
		aheadteam = getbetterteam();
		if ( aheadteam != game[ "defenders" ] )
		{
			game[ "switchedsides" ] = !game[ "switchedsides" ];
		}
		level.halftimetype = "overtime";
	}
	else
	{
		level.halftimetype = "halftime";
		game[ "switchedsides" ] = !game[ "switchedsides" ];
	}
}

getbetterteam()
{
	kills[ "allies" ] = 0;
	kills[ "axis" ] = 0;
	deaths[ "allies" ] = 0;
	deaths[ "axis" ] = 0;
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		team = player.pers[ "team" ];
		if ( isDefined( team ) || team == "allies" && team == "axis" )
		{
			kills[ team ] += player.kills;
			deaths[ team ] += player.deaths;
		}
		i++;
	}
	if ( kills[ "allies" ] > kills[ "axis" ] )
	{
		return "allies";
	}
	else
	{
		if ( kills[ "axis" ] > kills[ "allies" ] )
		{
			return "axis";
		}
	}
	if ( deaths[ "allies" ] < deaths[ "axis" ] )
	{
		return "allies";
	}
	else
	{
		if ( deaths[ "axis" ] < deaths[ "allies" ] )
		{
			return "axis";
		}
	}
	if ( randomint( 2 ) == 0 )
	{
		return "allies";
	}
	return "axis";
}

gamemodespawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.dem_enemy_base_influencer_score = set_dvar_float_if_unset( "scr_spawn_dem_enemy_base_influencer_score", "-500", reset_dvars );
	ss.dem_enemy_base_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dem_enemy_base_influencer_score_curve", "constant", reset_dvars );
	ss.dem_enemy_base_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dem_enemy_base_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
}

onstartgametype()
{
	setbombtimer( "A", 0 );
	setmatchflag( "bomb_timer_a", 0 );
	setbombtimer( "B", 0 );
	setmatchflag( "bomb_timer_b", 0 );
	level.usingextratime = 0;
	level.spawnsystem.unifiedsideswitching = 0;
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	if ( game[ "switchedsides" ] )
	{
		oldattackers = game[ "attackers" ];
		olddefenders = game[ "defenders" ];
		game[ "attackers" ] = olddefenders;
		game[ "defenders" ] = oldattackers;
	}
	setclientnamemode( "manual_change" );
	game[ "strings" ][ "target_destroyed" ] = &"MP_TARGET_DESTROYED";
	game[ "strings" ][ "bomb_defused" ] = &"MP_BOMB_DEFUSED";
	precachestring( game[ "strings" ][ "target_destroyed" ] );
	precachestring( game[ "strings" ][ "bomb_defused" ] );
	level._effect[ "bombexplosion" ] = loadfx( "maps/mp_maps/fx_mp_exp_bomb" );
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		setobjectivetext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER" );
		setobjectivetext( game[ "defenders" ], &"OBJECTIVES_DEM_ATTACKER" );
		if ( level.splitscreen )
		{
			setobjectivescoretext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER" );
			setobjectivescoretext( game[ "defenders" ], &"OBJECTIVES_DEM_ATTACKER" );
		}
		else
		{
			setobjectivescoretext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER_SCORE" );
			setobjectivescoretext( game[ "defenders" ], &"OBJECTIVES_DEM_ATTACKER_SCORE" );
		}
		setobjectivehinttext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER_HINT" );
		setobjectivehinttext( game[ "defenders" ], &"OBJECTIVES_DEM_ATTACKER_HINT" );
	}
	else
	{
		setobjectivetext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER" );
		setobjectivetext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER" );
		if ( level.splitscreen )
		{
			setobjectivescoretext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER" );
			setobjectivescoretext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER" );
		}
		else
		{
			setobjectivescoretext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER_SCORE" );
			setobjectivescoretext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER_SCORE" );
		}
		setobjectivehinttext( game[ "attackers" ], &"OBJECTIVES_DEM_ATTACKER_HINT" );
		setobjectivehinttext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER_HINT" );
	}
	level.dembombzonename = "bombzone_dem";
	bombzones = getentarray( level.dembombzonename, "targetname" );
	if ( bombzones.size == 0 )
	{
		level.dembombzonename = "bombzone";
	}
	allowed[ 0 ] = "sd";
	allowed[ 1 ] = level.dembombzonename;
	allowed[ 2 ] = "blocker";
	allowed[ 3 ] = "dem";
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 0, 0, 1 );
	level.spawnmaxs = ( 0, 0, 1 );
	maps/mp/gametypes/_spawnlogic::dropspawnpoints( "mp_dem_spawn_attacker_a" );
	maps/mp/gametypes/_spawnlogic::dropspawnpoints( "mp_dem_spawn_attacker_b" );
	maps/mp/gametypes/_spawnlogic::dropspawnpoints( "mp_dem_spawn_defender_a" );
	maps/mp/gametypes/_spawnlogic::dropspawnpoints( "mp_dem_spawn_defender_b" );
	if ( !isDefined( game[ "overtime_round" ] ) )
	{
		maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_dem_spawn_defender_start" );
		maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_dem_spawn_attacker_start" );
	}
	else
	{
		maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_dem_spawn_attackerOT_start" );
		maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_dem_spawn_defenderOT_start" );
	}
	maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "attackers" ], "mp_dem_spawn_attacker" );
	maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "defenders" ], "mp_dem_spawn_defender" );
	if ( !isDefined( game[ "overtime_round" ] ) )
	{
		maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "defenders" ], "mp_dem_spawn_defender_a" );
		maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "defenders" ], "mp_dem_spawn_defender_b" );
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.spawn_start = [];
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		level.spawn_start[ "axis" ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dem_spawn_attackerOT_start" );
		level.spawn_start[ "allies" ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dem_spawn_defenderOT_start" );
	}
	else
	{
		level.spawn_start[ "axis" ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dem_spawn_defender_start" );
		level.spawn_start[ "allies" ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dem_spawn_attacker_start" );
	}
	thread updategametypedvars();
	thread bombs();
}

onspawnplayerunified()
{
	self.isplanting = 0;
	self.isdefusing = 0;
	self.isbombcarrier = 0;
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn )
{
	if ( !predictedspawn )
	{
		self.isplanting = 0;
		self.isdefusing = 0;
		self.isbombcarrier = 0;
		if ( isDefined( self.carryicon ) )
		{
			self.carryicon destroyelem();
			self.carryicon = undefined;
		}
	}
	if ( !isDefined( game[ "overtime_round" ] ) )
	{
		if ( self.pers[ "team" ] == game[ "attackers" ] )
		{
			spawnpointname = "mp_dem_spawn_attacker_start";
		}
		else
		{
			spawnpointname = "mp_dem_spawn_defender_start";
		}
	}
	else if ( isDefined( game[ "overtime_round" ] ) )
	{
		if ( self.pers[ "team" ] == game[ "attackers" ] )
		{
			spawnpointname = "mp_dem_spawn_attackerOT_start";
		}
		else
		{
			spawnpointname = "mp_dem_spawn_defenderOT_start";
		}
	}
	spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( spawnpointname );
/#
	assert( spawnpoints.size );
#/
	spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( spawnpoints );
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "dem" );
	}
}

dem_playerspawnedcb()
{
	level notify( "spawned_player" );
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	thread checkallowspectating();
	bombzone = undefined;
	index = 0;
	while ( index < level.bombzones.size )
	{
		if ( !isDefined( level.bombzones[ index ].bombexploded ) || !level.bombzones[ index ].bombexploded )
		{
			dist = distance2d( self.origin, level.bombzones[ index ].curorigin );
			if ( dist < level.defaultoffenseradius )
			{
				bombzone = level.bombzones[ index ];
				break;
			}
			else dist = distance2d( attacker.origin, level.bombzones[ index ].curorigin );
			if ( dist < level.defaultoffenseradius )
			{
				inbombzone = 1;
				break;
			}
		}
		else
		{
			index++;
		}
	}
	if ( isDefined( bombzone ) && isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
	{
		if ( bombzone maps/mp/gametypes/_gameobjects::getownerteam() != attacker.team )
		{
			if ( !isDefined( attacker.dem_offends ) )
			{
				attacker.dem_offends = 0;
			}
			attacker.dem_offends++;
			if ( level.playeroffensivemax >= attacker.dem_offends )
			{
				attacker maps/mp/_medals::offenseglobalcount();
				attacker addplayerstatwithgametype( "OFFENDS", 1 );
				self recordkillmodifier( "defending" );
				maps/mp/_scoreevents::processscoreevent( "killed_defender", attacker, self, sweapon );
			}
			else
			{
/#
				attacker iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU OFFENSIVE CREDIT AS BOOSTING PREVENTION" );
#/
			}
		}
		else if ( !isDefined( attacker.dem_defends ) )
		{
			attacker.dem_defends = 0;
		}
		attacker.dem_defends++;
		if ( level.playerdefensivemax >= attacker.dem_defends )
		{
			if ( isDefined( attacker.pers[ "defends" ] ) )
			{
				attacker.pers[ "defends" ]++;
				attacker.defends = attacker.pers[ "defends" ];
			}
			attacker maps/mp/_medals::defenseglobalcount();
			attacker addplayerstatwithgametype( "DEFENDS", 1 );
			self recordkillmodifier( "assaulting" );
			maps/mp/_scoreevents::processscoreevent( "killed_attacker", attacker, self, sweapon );
		}
		else
		{
/#
			attacker iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU DEFENSIVE CREDIT AS BOOSTING PREVENTION" );
#/
		}
	}
	if ( self.isplanting == 1 )
	{
		self recordkillmodifier( "planting" );
	}
	if ( self.isdefusing == 1 )
	{
		self recordkillmodifier( "defusing" );
	}
}

checkallowspectating()
{
	self endon( "disconnect" );
	wait 0,05;
	update = 0;
	if ( level.numliveslivesleft = self.pers[ "lives" ];
	 && !level.alivecount[ game[ "attackers" ] ] && !livesleft )
	{
		level.spectateoverride[ game[ "attackers" ] ].allowenemyspectate = 1;
		update = 1;
	}
	if ( !level.alivecount[ game[ "defenders" ] ] && !livesleft )
	{
		level.spectateoverride[ game[ "defenders" ] ].allowenemyspectate = 1;
		update = 1;
	}
	if ( update )
	{
		maps/mp/gametypes/_spectating::updatespectatesettings();
	}
}

dem_endgame( winningteam, endreasontext )
{
	if ( isDefined( winningteam ) && winningteam != "tie" )
	{
		maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( winningteam, 1 );
	}
	thread maps/mp/gametypes/_globallogic::endgame( winningteam, endreasontext );
}

ondeadevent( team )
{
	if ( level.bombexploded || level.bombdefused )
	{
		return;
	}
	if ( team == "all" )
	{
		if ( level.bombplanted )
		{
			dem_endgame( game[ "attackers" ], game[ "strings" ][ game[ "defenders" ] + "_eliminated" ] );
		}
		else
		{
			dem_endgame( game[ "defenders" ], game[ "strings" ][ game[ "attackers" ] + "_eliminated" ] );
		}
	}
	else if ( team == game[ "attackers" ] )
	{
		if ( level.bombplanted )
		{
			return;
		}
		dem_endgame( game[ "defenders" ], game[ "strings" ][ game[ "attackers" ] + "_eliminated" ] );
	}
	else
	{
		if ( team == game[ "defenders" ] )
		{
			dem_endgame( game[ "attackers" ], game[ "strings" ][ game[ "defenders" ] + "_eliminated" ] );
		}
	}
}

ononeleftevent( team )
{
	if ( level.bombexploded || level.bombdefused )
	{
		return;
	}
	warnlastplayer( team );
}

ontimelimit()
{
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		dem_endgame( "tie", game[ "strings" ][ "time_limit_reached" ] );
	}
	else if ( level.teambased )
	{
		bombzonesleft = 0;
		index = 0;
		while ( index < level.bombzones.size )
		{
			if ( !isDefined( level.bombzones[ index ].bombexploded ) || !level.bombzones[ index ].bombexploded )
			{
				bombzonesleft++;
			}
			index++;
		}
		if ( bombzonesleft == 0 )
		{
			dem_endgame( game[ "attackers" ], game[ "strings" ][ "target_destroyed" ] );
		}
		else
		{
			dem_endgame( game[ "defenders" ], game[ "strings" ][ "time_limit_reached" ] );
		}
	}
	else
	{
		dem_endgame( "tie", game[ "strings" ][ "time_limit_reached" ] );
	}
}

warnlastplayer( team )
{
	if ( !isDefined( level.warnedlastplayer ) )
	{
		level.warnedlastplayer = [];
	}
	if ( isDefined( level.warnedlastplayer[ team ] ) )
	{
		return;
	}
	level.warnedlastplayer[ team ] = 1;
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team && isDefined( player.pers[ "class" ] ) )
		{
			if ( player.sessionstate == "playing" && !player.afk )
			{
				break;
			}
		}
		else
		{
			i++;
		}
	}
	if ( i == players.size )
	{
		return;
	}
	players[ i ] thread givelastattackerwarning();
}

givelastattackerwarning()
{
	self endon( "death" );
	self endon( "disconnect" );
	fullhealthtime = 0;
	interval = 0,05;
	while ( 1 )
	{
		if ( self.health != self.maxhealth )
		{
			fullhealthtime = 0;
		}
		else
		{
			fullhealthtime += interval;
		}
		wait interval;
		if ( self.health == self.maxhealth && fullhealthtime >= 3 )
		{
			break;
		}
		else
		{
		}
	}
	self maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "sudden_death" );
}

updategametypedvars()
{
	level.planttime = getgametypesetting( "plantTime" );
	level.defusetime = getgametypesetting( "defuseTime" );
	level.bombtimer = getgametypesetting( "bombTimer" );
	level.extratime = getgametypesetting( "extraTime" );
	level.overtimetimelimit = getgametypesetting( "OvertimetimeLimit" );
	level.teamkillpenaltymultiplier = getgametypesetting( "teamKillPenalty" );
	level.teamkillscoremultiplier = getgametypesetting( "teamKillScore" );
	level.playereventslpm = getgametypesetting( "maxPlayerEventsPerMinute" );
	level.bombeventslpm = getgametypesetting( "maxObjectiveEventsPerMinute" );
	level.playeroffensivemax = getgametypesetting( "maxPlayerOffensive" );
	level.playerdefensivemax = getgametypesetting( "maxPlayerDefensive" );
}

resetbombzone()
{
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		self maps/mp/gametypes/_gameobjects::setownerteam( "neutral" );
		self maps/mp/gametypes/_gameobjects::allowuse( "any" );
	}
	else
	{
		self maps/mp/gametypes/_gameobjects::allowuse( "enemy" );
	}
	self maps/mp/gametypes/_gameobjects::setusetime( level.planttime );
	self maps/mp/gametypes/_gameobjects::setusetext( &"MP_PLANTING_EXPLOSIVE" );
	self maps/mp/gametypes/_gameobjects::setusehinttext( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	self maps/mp/gametypes/_gameobjects::setkeyobject( level.ddbomb );
	self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", "waypoint_defend" + self.label );
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defend" + self.label );
	self maps/mp/gametypes/_gameobjects::set2dicon( "enemy", "waypoint_target" + self.label );
	self maps/mp/gametypes/_gameobjects::set3dicon( "enemy", "waypoint_target" + self.label );
	self maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
	self.useweapon = "briefcase_bomb_mp";
}

setupfordefusing()
{
	self maps/mp/gametypes/_gameobjects::allowuse( "friendly" );
	self maps/mp/gametypes/_gameobjects::setusetime( level.defusetime );
	self maps/mp/gametypes/_gameobjects::setusetext( &"MP_DEFUSING_EXPLOSIVE" );
	self maps/mp/gametypes/_gameobjects::setusehinttext( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	self maps/mp/gametypes/_gameobjects::setkeyobject( undefined );
	self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", "compass_waypoint_defuse" + self.label );
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defuse" + self.label );
	self maps/mp/gametypes/_gameobjects::set2dicon( "enemy", "compass_waypoint_defend" + self.label );
	self maps/mp/gametypes/_gameobjects::set3dicon( "enemy", "waypoint_defend" + self.label );
	self maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
}

bombs()
{
	level.bombaplanted = 0;
	level.bombbplanted = 0;
	level.bombplanted = 0;
	level.bombdefused = 0;
	level.bombexploded = 0;
	sdbomb = getent( "sd_bomb", "targetname" );
	if ( isDefined( sdbomb ) )
	{
		sdbomb delete();
	}
	precachemodel( "t5_weapon_briefcase_bomb_world" );
	level.bombzones = [];
	bombzones = getentarray( level.dembombzonename, "targetname" );
	index = 0;
	while ( index < bombzones.size )
	{
		trigger = bombzones[ index ];
		scriptlabel = trigger.script_label;
		visuals = getentarray( bombzones[ index ].target, "targetname" );
		clipbrushes = getentarray( "bombzone_clip" + scriptlabel, "targetname" );
		defusetrig = getent( visuals[ 0 ].target, "targetname" );
		bombsiteteamowner = game[ "defenders" ];
		bombsiteallowuse = "enemy";
		if ( isDefined( game[ "overtime_round" ] ) )
		{
			if ( scriptlabel != "_overtime" )
			{
				trigger delete();
				defusetrig delete();
				visuals[ 0 ] delete();
				_a831 = clipbrushes;
				_k831 = getFirstArrayKey( _a831 );
				while ( isDefined( _k831 ) )
				{
					clip = _a831[ _k831 ];
					clip delete();
					_k831 = getNextArrayKey( _a831, _k831 );
				}
			}
			else bombsiteteamowner = "neutral";
			bombsiteallowuse = "any";
			scriptlabel = "_a";
		}
		else
		{
			if ( scriptlabel == "_overtime" )
			{
				trigger delete();
				defusetrig delete();
				visuals[ 0 ] delete();
				_a846 = clipbrushes;
				_k846 = getFirstArrayKey( _a846 );
				while ( isDefined( _k846 ) )
				{
					clip = _a846[ _k846 ];
					clip delete();
					_k846 = getNextArrayKey( _a846, _k846 );
				}
			}
		}
		else name = istring( scriptlabel );
		precachestring( name );
		bombzone = maps/mp/gametypes/_gameobjects::createuseobject( bombsiteteamowner, trigger, visuals, ( 0, 0, 1 ), name );
		bombzone maps/mp/gametypes/_gameobjects::allowuse( bombsiteallowuse );
		bombzone maps/mp/gametypes/_gameobjects::setusetime( level.planttime );
		bombzone maps/mp/gametypes/_gameobjects::setusetext( &"MP_PLANTING_EXPLOSIVE" );
		bombzone maps/mp/gametypes/_gameobjects::setusehinttext( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
		bombzone maps/mp/gametypes/_gameobjects::setkeyobject( level.ddbomb );
		bombzone.label = scriptlabel;
		bombzone.index = index;
		bombzone maps/mp/gametypes/_gameobjects::set2dicon( "friendly", "compass_waypoint_defend" + scriptlabel );
		bombzone maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defend" + scriptlabel );
		bombzone maps/mp/gametypes/_gameobjects::set2dicon( "enemy", "compass_waypoint_target" + scriptlabel );
		bombzone maps/mp/gametypes/_gameobjects::set3dicon( "enemy", "waypoint_target" + scriptlabel );
		bombzone maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
		bombzone.onbeginuse = ::onbeginuse;
		bombzone.onenduse = ::onenduse;
		bombzone.onuse = ::onuseobject;
		bombzone.oncantuse = ::oncantuse;
		bombzone.useweapon = "briefcase_bomb_mp";
		bombzone.visuals[ 0 ].killcament = spawn( "script_model", bombzone.visuals[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 128 ) );
		i = 0;
		while ( i < visuals.size )
		{
			if ( isDefined( visuals[ i ].script_exploder ) )
			{
				bombzone.exploderindex = visuals[ i ].script_exploder;
				break;
			}
			else
			{
				i++;
			}
		}
		level.bombzones[ level.bombzones.size ] = bombzone;
		bombzone.bombdefusetrig = defusetrig;
/#
		assert( isDefined( bombzone.bombdefusetrig ) );
#/
		bombzone.bombdefusetrig.origin += vectorScale( ( 0, 0, 1 ), 10000 );
		bombzone.bombdefusetrig.label = scriptlabel;
		dem_enemy_base_influencer_score = level.spawnsystem.dem_enemy_base_influencer_score;
		dem_enemy_base_influencer_score_curve = level.spawnsystem.dem_enemy_base_influencer_score_curve;
		dem_enemy_base_influencer_radius = level.spawnsystem.dem_enemy_base_influencer_radius;
		team_mask = getteammask( game[ "attackers" ] );
		bombzone.spawninfluencer = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, trigger.origin, dem_enemy_base_influencer_radius, dem_enemy_base_influencer_score, team_mask, "dem_enemy_base,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( dem_enemy_base_influencer_score_curve ) );
		index++;
	}
	index = 0;
	while ( index < level.bombzones.size )
	{
		array = [];
		otherindex = 0;
		while ( otherindex < level.bombzones.size )
		{
			if ( otherindex != index )
			{
				array[ array.size ] = level.bombzones[ otherindex ];
			}
			otherindex++;
		}
		level.bombzones[ index ].otherbombzones = array;
		index++;
	}
}

onbeginuse( player )
{
	timeremaining = maps/mp/gametypes/_globallogic_utils::gettimeremaining();
	if ( timeremaining <= ( level.planttime * 1000 ) )
	{
		maps/mp/gametypes/_globallogic_utils::pausetimer();
		level.haspausedtimer = 1;
	}
	if ( self maps/mp/gametypes/_gameobjects::isfriendlyteam( player.pers[ "team" ] ) )
	{
		player playsound( "mpl_sd_bomb_defuse" );
		player.isdefusing = 1;
		player thread maps/mp/gametypes/_battlechatter_mp::gametypespecificbattlechatter( "sd_enemyplant", player.pers[ "team" ] );
		bestdistance = 9000000;
		closestbomb = undefined;
		if ( isDefined( level.ddbombmodel ) )
		{
			keys = getarraykeys( level.ddbombmodel );
			bomblabel = 0;
			while ( bomblabel < keys.size )
			{
				bomb = level.ddbombmodel[ keys[ bomblabel ] ];
				if ( !isDefined( bomb ) )
				{
					bomblabel++;
					continue;
				}
				else
				{
					dist = distancesquared( player.origin, bomb.origin );
					if ( dist < bestdistance )
					{
						bestdistance = dist;
						closestbomb = bomb;
					}
				}
				bomblabel++;
			}
/#
			assert( isDefined( closestbomb ) );
#/
			player.defusing = closestbomb;
			closestbomb hide();
		}
	}
	else
	{
		player.isplanting = 1;
		player thread maps/mp/gametypes/_battlechatter_mp::gametypespecificbattlechatter( "sd_friendlyplant", player.pers[ "team" ] );
	}
	player playsound( "fly_bomb_raise_plr" );
}

onenduse( team, player, result )
{
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( !level.bombaplanted && !level.bombbplanted )
	{
		maps/mp/gametypes/_globallogic_utils::resumetimer();
		level.haspausedtimer = 0;
	}
	player.isdefusing = 0;
	player.isplanting = 0;
	player notify( "event_ended" );
	if ( self maps/mp/gametypes/_gameobjects::isfriendlyteam( player.pers[ "team" ] ) )
	{
		if ( isDefined( player.defusing ) && !result )
		{
			player.defusing show();
		}
	}
}

oncantuse( player )
{
	player iprintlnbold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}

onuseobject( player )
{
	team = player.team;
	enemyteam = getotherteam( team );
	self updateeventsperminute();
	player updateeventsperminute();
	if ( !self maps/mp/gametypes/_gameobjects::isfriendlyteam( team ) )
	{
		self maps/mp/gametypes/_gameobjects::setflags( 1 );
		level thread bombplanted( self, player );
		player logstring( "bomb planted: " + self.label );
		bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "dem_bombplant", self.label, team );
		player notify( "bomb_planted" );
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_WE_PLANT", team, 0, 0, 5 );
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_THEY_PLANT", enemyteam, 0, 0, 5 );
		if ( isDefined( player.pers[ "plants" ] ) )
		{
			player.pers[ "plants" ]++;
			player.plants = player.pers[ "plants" ];
		}
		if ( !isscoreboosting( player, self ) )
		{
			maps/mp/_demo::bookmark( "event", getTime(), player );
			player addplayerstatwithgametype( "PLANTS", 1 );
			maps/mp/_scoreevents::processscoreevent( "planted_bomb", player );
			player recordgameevent( "plant" );
		}
		else
		{
/#
			player iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU PLANT CREDIT AS BOOSTING PREVENTION" );
#/
		}
		level thread maps/mp/_popups::displayteammessagetoall( &"MP_EXPLOSIVES_PLANTED_BY", player );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_planted" );
	}
	else
	{
		self maps/mp/gametypes/_gameobjects::setflags( 0 );
		player notify( "bomb_defused" );
		player logstring( "bomb defused: " + self.label );
		self thread bombdefused();
		self resetbombzone();
		bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "dem_bombdefused", self.label, team );
		if ( isDefined( player.pers[ "defuses" ] ) )
		{
			player.pers[ "defuses" ]++;
			player.defuses = player.pers[ "defuses" ];
		}
		if ( !isscoreboosting( player, self ) )
		{
			maps/mp/_demo::bookmark( "event", getTime(), player );
			player addplayerstatwithgametype( "DEFUSES", 1 );
			maps/mp/_scoreevents::processscoreevent( "defused_bomb", player );
			player recordgameevent( "defuse" );
		}
		else
		{
/#
			player iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU DEFUSE CREDIT AS BOOSTING PREVENTION" );
#/
		}
		level thread maps/mp/_popups::displayteammessagetoall( &"MP_EXPLOSIVES_DEFUSED_BY", player );
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_WE_DEFUSE", team, 0, 0, 5 );
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_THEY_DEFUSE", enemyteam, 0, 0, 5 );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_defused" );
	}
}

ondrop( player )
{
	if ( !level.bombplanted )
	{
		if ( isDefined( player ) )
		{
			player logstring( "bomb dropped" );
		}
		else
		{
			logstring( "bomb dropped" );
		}
	}
	player notify( "event_ended" );
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_bomb" );
	maps/mp/_utility::playsoundonplayers( game[ "bomb_dropped_sound" ], game[ "attackers" ] );
}

onpickup( player )
{
	player.isbombcarrier = 1;
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defend" );
	if ( !level.bombdefused )
	{
		thread playsoundonplayers( "mus_sd_pickup" + "_" + level.teampostfix[ player.pers[ "team" ] ], player.pers[ "team" ] );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_taken", player.pers[ "team" ] );
		player logstring( "bomb taken" );
	}
	maps/mp/_utility::playsoundonplayers( game[ "bomb_recovered_sound" ], game[ "attackers" ] );
}

onreset()
{
}

bombreset( label, reason )
{
	if ( label == "_a" )
	{
		level.bombaplanted = 0;
		setbombtimer( "A", 0 );
	}
	else
	{
		level.bombbplanted = 0;
		setbombtimer( "B", 0 );
	}
	setmatchflag( "bomb_timer" + label, 0 );
	if ( !level.bombaplanted && !level.bombbplanted )
	{
		maps/mp/gametypes/_globallogic_utils::resumetimer();
	}
	self.visuals[ 0 ] maps/mp/gametypes/_globallogic_utils::stoptickingsound();
}

dropbombmodel( player, site )
{
	trace = bullettrace( player.origin + vectorScale( ( 0, 0, 1 ), 20 ), player.origin - vectorScale( ( 0, 0, 1 ), 2000 ), 0, player );
	tempangle = randomfloat( 360 );
	forward = ( cos( tempangle ), sin( tempangle ), 0 );
	forward = vectornormalize( forward - vectorScale( trace[ "normal" ], vectordot( forward, trace[ "normal" ] ) ) );
	dropangles = vectorToAngle( forward );
	if ( isDefined( trace[ "surfacetype" ] ) && trace[ "surfacetype" ] == "water" )
	{
		phystrace = playerphysicstrace( player.origin + vectorScale( ( 0, 0, 1 ), 20 ), player.origin - vectorScale( ( 0, 0, 1 ), 2000 ) );
		if ( isDefined( phystrace ) )
		{
			trace[ "position" ] = phystrace;
		}
	}
	level.ddbombmodel[ site ] = spawn( "script_model", trace[ "position" ] );
	level.ddbombmodel[ site ].angles = dropangles;
	level.ddbombmodel[ site ] setmodel( "prop_suitcase_bomb" );
}

bombplanted( destroyedobj, player )
{
	level endon( "game_ended" );
	destroyedobj endon( "bomb_defused" );
	team = player.team;
	game[ "challenge" ][ team ][ "plantedBomb" ] = 1;
	maps/mp/gametypes/_globallogic_utils::pausetimer();
	destroyedobj.bombplanted = 1;
	destroyedobj.visuals[ 0 ] thread maps/mp/gametypes/_globallogic_utils::playtickingsound( "mpl_sab_ui_suitcasebomb_timer" );
	destroyedobj.tickingobject = destroyedobj.visuals[ 0 ];
	label = destroyedobj.label;
	detonatetime = int( getTime() + ( level.bombtimer * 1000 ) );
	updatebombtimers( label, detonatetime );
	destroyedobj.detonatetime = detonatetime;
	trace = bullettrace( player.origin + vectorScale( ( 0, 0, 1 ), 20 ), player.origin - vectorScale( ( 0, 0, 1 ), 2000 ), 0, player );
	tempangle = randomfloat( 360 );
	forward = ( cos( tempangle ), sin( tempangle ), 0 );
	forward = vectornormalize( forward - vectorScale( trace[ "normal" ], vectordot( forward, trace[ "normal" ] ) ) );
	dropangles = vectorToAngle( forward );
	self dropbombmodel( player, destroyedobj.label );
	destroyedobj maps/mp/gametypes/_gameobjects::allowuse( "none" );
	destroyedobj maps/mp/gametypes/_gameobjects::setvisibleteam( "none" );
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		destroyedobj maps/mp/gametypes/_gameobjects::setownerteam( getotherteam( player.team ) );
	}
	destroyedobj setupfordefusing();
	player.isbombcarrier = 0;
	game[ "challenge" ][ team ][ "plantedBomb" ] = 1;
	destroyedobj waitlongdurationwithbombtimeupdate( label, level.bombtimer );
	destroyedobj bombreset( label, "bomb_exploded" );
	if ( level.gameended )
	{
		return;
	}
	bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "dem_bombexplode", label, team );
	destroyedobj.bombexploded = 1;
	game[ "challenge" ][ team ][ "destroyedBombSite" ] = 1;
	explosionorigin = destroyedobj.curorigin;
	level.ddbombmodel[ destroyedobj.label ] delete();
	if ( isDefined( player ) )
	{
		destroyedobj.visuals[ 0 ] radiusdamage( explosionorigin, 512, 200, 20, player, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );
		player addplayerstatwithgametype( "DESTRUCTIONS", 1 );
		level thread maps/mp/_popups::displayteammessagetoall( &"MP_EXPLOSIVES_BLOWUP_BY", player );
		maps/mp/_scoreevents::processscoreevent( "bomb_detonated", player );
		player recordgameevent( "destroy" );
	}
	else
	{
		destroyedobj.visuals[ 0 ] radiusdamage( explosionorigin, 512, 200, 20, undefined, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );
	}
	currenttime = getTime();
	while ( isDefined( level.lastbombexplodetime ) && level.lastbombexplodebyteam == player.team )
	{
		while ( ( level.lastbombexplodetime + 10000 ) > currenttime )
		{
			i = 0;
			while ( i < level.players.size )
			{
				if ( level.players[ i ].team == player.team )
				{
					level.players[ i ] maps/mp/_challenges::bothbombsdetonatewithintime();
				}
				i++;
			}
		}
	}
	level.lastbombexplodetime = currenttime;
	level.lastbombexplodebyteam = player.team;
	rot = randomfloat( 360 );
	explosioneffect = spawnfx( level._effect[ "bombexplosion" ], explosionorigin + vectorScale( ( 0, 0, 1 ), 50 ), ( 0, 0, 1 ), ( cos( rot ), sin( rot ), 0 ) );
	triggerfx( explosioneffect );
	thread playsoundinspace( "mpl_sd_exp_suitcase_bomb_main", explosionorigin );
	if ( isDefined( destroyedobj.exploderindex ) )
	{
		exploder( destroyedobj.exploderindex );
	}
	bombzonesleft = 0;
	index = 0;
	while ( index < level.bombzones.size )
	{
		if ( !isDefined( level.bombzones[ index ].bombexploded ) || !level.bombzones[ index ].bombexploded )
		{
			bombzonesleft++;
		}
		index++;
	}
	destroyedobj maps/mp/gametypes/_gameobjects::disableobject();
	if ( bombzonesleft == 0 )
	{
		maps/mp/gametypes/_globallogic_utils::pausetimer();
		level.haspausedtimer = 1;
		setgameendtime( 0 );
		wait 3;
		dem_endgame( team, game[ "strings" ][ "target_destroyed" ] );
	}
	else
	{
		enemyteam = getotherteam( team );
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_WE_SCORE", team, 0, 0, 5 );
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_THEY_SCORE", enemyteam, 0, 0, 5 );
		if ( [[ level.gettimelimit ]]() > 0 )
		{
			level.usingextratime = 1;
		}
		removeinfluencer( destroyedobj.spawninfluencer );
		destroyedobj.spawninfluencer = undefined;
		maps/mp/gametypes/_spawnlogic::clearspawnpoints();
		maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "attackers" ], "mp_dem_spawn_attacker" );
		maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "defenders" ], "mp_dem_spawn_defender" );
		if ( label == "_a" )
		{
			maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "attackers" ], "mp_dem_spawn_attacker_a" );
			maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "defenders" ], "mp_dem_spawn_defender_b" );
		}
		else
		{
			maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "attackers" ], "mp_dem_spawn_attacker_b" );
			maps/mp/gametypes/_spawnlogic::addspawnpoints( game[ "defenders" ], "mp_dem_spawn_defender_a" );
		}
		maps/mp/gametypes/_spawning::updateallspawnpoints();
	}
}

gettimelimit()
{
	timelimit = maps/mp/gametypes/_globallogic_defaults::default_gettimelimit();
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		timelimit = level.overtimetimelimit;
	}
	if ( level.usingextratime )
	{
		return timelimit + level.extratime;
	}
	return timelimit;
}

shouldplayovertimeround()
{
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		return 0;
	}
	if ( game[ "teamScores" ][ "allies" ] == ( level.scorelimit - 1 ) && game[ "teamScores" ][ "axis" ] == ( level.scorelimit - 1 ) )
	{
		return 1;
	}
	return 0;
}

waitlongdurationwithbombtimeupdate( whichbomb, duration )
{
	if ( duration == 0 )
	{
		return;
	}
/#
	assert( duration > 0 );
#/
	starttime = getTime();
	endtime = getTime() + ( duration * 1000 );
	while ( getTime() < endtime )
	{
		maps/mp/gametypes/_hostmigration::waittillhostmigrationstarts( ( endtime - getTime() ) / 1000 );
		while ( isDefined( level.hostmigrationtimer ) )
		{
			endtime += 250;
			updatebombtimers( whichbomb, endtime );
			wait 0,25;
		}
	}
/#
	if ( getTime() != endtime )
	{
		println( "SCRIPT WARNING: gettime() = " + getTime() + " NOT EQUAL TO endtime = " + endtime );
#/
	}
	while ( isDefined( level.hostmigrationtimer ) )
	{
		endtime += 250;
		updatebombtimers( whichbomb, endtime );
		wait 0,25;
	}
	return getTime() - starttime;
}

updatebombtimers( whichbomb, detonatetime )
{
	if ( whichbomb == "_a" )
	{
		level.bombaplanted = 1;
		setbombtimer( "A", int( detonatetime ) );
	}
	else
	{
		level.bombbplanted = 1;
		setbombtimer( "B", int( detonatetime ) );
	}
	setmatchflag( "bomb_timer" + whichbomb, int( detonatetime ) );
}

bombdefused()
{
	self.tickingobject maps/mp/gametypes/_globallogic_utils::stoptickingsound();
	self maps/mp/gametypes/_gameobjects::allowuse( "none" );
	self maps/mp/gametypes/_gameobjects::setvisibleteam( "none" );
	self.bombdefused = 1;
	self notify( "bomb_defused" );
	self.bombplanted = 0;
	self bombreset( self.label, "bomb_defused" );
}

play_one_left_underscore( team, enemyteam )
{
	wait 3;
	if ( !isDefined( team ) || !isDefined( enemyteam ) )
	{
		return;
	}
	thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_ONE_LEFT_UNDERSCORE", team, 0, 0 );
	thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "DEM_ONE_LEFT_UNDERSCORE", enemyteam, 0, 0 );
}

updateeventsperminute()
{
	if ( !isDefined( self.eventsperminute ) )
	{
		self.numbombevents = 0;
		self.eventsperminute = 0;
	}
	self.numbombevents++;
	minutespassed = maps/mp/gametypes/_globallogic_utils::gettimepassed() / 60000;
	if ( isplayer( self ) && isDefined( self.timeplayed[ "total" ] ) )
	{
		minutespassed = self.timeplayed[ "total" ] / 60;
	}
	self.eventsperminute = self.numbombevents / minutespassed;
	if ( self.eventsperminute > self.numbombevents )
	{
		self.eventsperminute = self.numbombevents;
	}
}

isscoreboosting( player, flag )
{
	if ( !level.rankedmatch )
	{
		return 0;
	}
	if ( player.eventsperminute > level.playereventslpm )
	{
		return 1;
	}
	if ( flag.eventsperminute > level.bombeventslpm )
	{
		return 1;
	}
	return 0;
}
