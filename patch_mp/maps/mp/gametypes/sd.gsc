#include maps/mp/gametypes/_hostmigration;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_demo;
#include maps/mp/_popups;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_spectating;
#include maps/mp/_medals;
#include maps/mp/_scoreevents;
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
	level.playerspawnedcb = ::sd_playerspawnedcb;
	level.onplayerkilled = ::onplayerkilled;
	level.ondeadevent = ::ondeadevent;
	level.ononeleftevent = ::ononeleftevent;
	level.ontimelimit = ::ontimelimit;
	level.onroundswitch = ::onroundswitch;
	level.getteamkillpenalty = ::sd_getteamkillpenalty;
	level.getteamkillscore = ::sd_getteamkillscore;
	level.iskillboosting = ::sd_iskillboosting;
	level.endgameonscorelimit = 0;
	game[ "dialog" ][ "gametype" ] = "sd_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hcsd_start";
	game[ "dialog" ][ "offense_obj" ] = "destroy_start";
	game[ "dialog" ][ "defense_obj" ] = "defend_start";
	game[ "dialog" ][ "sudden_death" ] = "generic_boost";
	game[ "dialog" ][ "last_one" ] = "encourage_last";
	game[ "dialog" ][ "halftime" ] = "sd_halftime";
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
	game[ "bomb_dropped_sound" ] = "mpl_flag_drop_plr";
	game[ "bomb_recovered_sound" ] = "mpl_flag_pickup_plr";
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
	precachestring( &"MP_EXPLOSIVES_BLOWUP_BY" );
	precachestring( &"MP_EXPLOSIVES_RECOVERED_BY" );
	precachestring( &"MP_EXPLOSIVES_DROPPED_BY" );
	precachestring( &"MP_EXPLOSIVES_PLANTED_BY" );
	precachestring( &"MP_EXPLOSIVES_DEFUSED_BY" );
	precachestring( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	precachestring( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	precachestring( &"MP_CANT_PLANT_WITHOUT_BOMB" );
	precachestring( &"MP_PLANTING_EXPLOSIVE" );
	precachestring( &"MP_DEFUSING_EXPLOSIVE" );
}

sd_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon )
{
	teamkill_penalty = maps/mp/gametypes/_globallogic_defaults::default_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon );
	if ( isDefined( self.isdefusing ) || self.isdefusing && isDefined( self.isplanting ) && self.isplanting )
	{
		teamkill_penalty *= level.teamkillpenaltymultiplier;
	}
	return teamkill_penalty;
}

sd_getteamkillscore( einflictor, attacker, smeansofdeath, sweapon )
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

onstartgametype()
{
	setbombtimer( "A", 0 );
	setmatchflag( "bomb_timer_a", 0 );
	setbombtimer( "B", 0 );
	setmatchflag( "bomb_timer_b", 0 );
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
	setobjectivetext( game[ "attackers" ], &"OBJECTIVES_SD_ATTACKER" );
	setobjectivetext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER" );
	if ( level.splitscreen )
	{
		setobjectivescoretext( game[ "attackers" ], &"OBJECTIVES_SD_ATTACKER" );
		setobjectivescoretext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER" );
	}
	else
	{
		setobjectivescoretext( game[ "attackers" ], &"OBJECTIVES_SD_ATTACKER_SCORE" );
		setobjectivescoretext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER_SCORE" );
	}
	setobjectivehinttext( game[ "attackers" ], &"OBJECTIVES_SD_ATTACKER_HINT" );
	setobjectivehinttext( game[ "defenders" ], &"OBJECTIVES_SD_DEFENDER_HINT" );
	allowed[ 0 ] = "sd";
	allowed[ 1 ] = "bombzone";
	allowed[ 2 ] = "blocker";
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 0, 0, 1 );
	level.spawnmaxs = ( 0, 0, 1 );
	maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_sd_spawn_attacker" );
	maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_sd_spawn_defender" );
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.spawn_start = [];
	level.spawn_start[ "axis" ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_sd_spawn_defender" );
	level.spawn_start[ "allies" ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_sd_spawn_attacker" );
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
	}
	if ( self.pers[ "team" ] == game[ "attackers" ] )
	{
		spawnpointname = "mp_sd_spawn_attacker";
	}
	else
	{
		spawnpointname = "mp_sd_spawn_defender";
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
		self spawn( spawnpoint.origin, spawnpoint.angles, "sd" );
	}
}

sd_playerspawnedcb()
{
	level notify( "spawned_player" );
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	thread checkallowspectating();
	if ( isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
	{
		maps/mp/_scoreevents::processscoreevent( "kill_sd", attacker, self, sweapon );
	}
	inbombzone = 0;
	index = 0;
	while ( index < level.bombzones.size )
	{
		dist = distance2d( self.origin, level.bombzones[ index ].curorigin );
		if ( dist < level.defaultoffenseradius )
		{
			inbombzone = 1;
		}
		index++;
	}
	if ( inbombzone && isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
	{
		if ( game[ "defenders" ] == self.pers[ "team" ] )
		{
			attacker maps/mp/_medals::offenseglobalcount();
			attacker addplayerstatwithgametype( "OFFENDS", 1 );
			self recordkillmodifier( "defending" );
			maps/mp/_scoreevents::processscoreevent( "killed_defender", attacker, self, sweapon );
		}
		else
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
	}
	if ( isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] && isDefined( self.isbombcarrier ) && self.isbombcarrier == 1 )
	{
		self recordkillmodifier( "carrying" );
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

sd_endgame( winningteam, endreasontext )
{
	if ( isDefined( winningteam ) )
	{
		maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective_delaypostprocessing( winningteam, 1 );
	}
	thread maps/mp/gametypes/_globallogic::endgame( winningteam, endreasontext );
}

sd_endgamewithkillcam( winningteam, endreasontext )
{
	sd_endgame( winningteam, endreasontext );
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
			sd_endgamewithkillcam( game[ "attackers" ], game[ "strings" ][ game[ "defenders" ] + "_eliminated" ] );
		}
		else
		{
			sd_endgamewithkillcam( game[ "defenders" ], game[ "strings" ][ game[ "attackers" ] + "_eliminated" ] );
		}
	}
	else if ( team == game[ "attackers" ] )
	{
		if ( level.bombplanted )
		{
			return;
		}
		sd_endgamewithkillcam( game[ "defenders" ], game[ "strings" ][ game[ "attackers" ] + "_eliminated" ] );
	}
	else
	{
		if ( team == game[ "defenders" ] )
		{
			sd_endgamewithkillcam( game[ "attackers" ], game[ "strings" ][ game[ "defenders" ] + "_eliminated" ] );
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
	if ( level.teambased )
	{
		sd_endgame( game[ "defenders" ], game[ "strings" ][ "time_limit_reached" ] );
	}
	else
	{
		sd_endgame( undefined, game[ "strings" ][ "time_limit_reached" ] );
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
	players[ i ] thread givelastattackerwarning( team );
}

givelastattackerwarning( team )
{
	self endon( "death" );
	self endon( "disconnect" );
	fullhealthtime = 0;
	interval = 0,05;
	self.lastmansd = 1;
	enemyteam = game[ "defenders" ];
	if ( team == enemyteam )
	{
		enemyteam = game[ "attackers" ];
	}
	if ( level.alivecount[ enemyteam ] > 2 )
	{
		self.lastmansddefeat3enemies = 1;
	}
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
	self maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "last_one" );
	self playlocalsound( "mus_last_stand" );
}

updategametypedvars()
{
	level.planttime = getgametypesetting( "plantTime" );
	level.defusetime = getgametypesetting( "defuseTime" );
	level.bombtimer = getgametypesetting( "bombTimer" );
	level.multibomb = getgametypesetting( "multiBomb" );
	level.teamkillpenaltymultiplier = getgametypesetting( "teamKillPenalty" );
	level.teamkillscoremultiplier = getgametypesetting( "teamKillScore" );
	level.playerkillsmax = getgametypesetting( "playerKillsMax" );
	level.totalkillsmax = getgametypesetting( "totalKillsMax" );
}

bombs()
{
	level.bombplanted = 0;
	level.bombdefused = 0;
	level.bombexploded = 0;
	trigger = getent( "sd_bomb_pickup_trig", "targetname" );
	if ( !isDefined( trigger ) )
	{
/#
		maps/mp/_utility::error( "No sd_bomb_pickup_trig trigger found in map." );
#/
		return;
	}
	visuals[ 0 ] = getent( "sd_bomb", "targetname" );
	if ( !isDefined( visuals[ 0 ] ) )
	{
/#
		maps/mp/_utility::error( "No sd_bomb script_model found in map." );
#/
		return;
	}
	precachemodel( "prop_suitcase_bomb" );
	precachestring( &"bomb" );
	if ( !level.multibomb )
	{
		level.sdbomb = maps/mp/gametypes/_gameobjects::createcarryobject( game[ "attackers" ], trigger, visuals, vectorScale( ( 0, 0, 1 ), 32 ), &"bomb" );
		level.sdbomb maps/mp/gametypes/_gameobjects::allowcarry( "friendly" );
		level.sdbomb maps/mp/gametypes/_gameobjects::set2dicon( "friendly", "compass_waypoint_bomb" );
		level.sdbomb maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_bomb" );
		level.sdbomb maps/mp/gametypes/_gameobjects::setvisibleteam( "friendly" );
		level.sdbomb maps/mp/gametypes/_gameobjects::setcarryicon( "hud_suitcase_bomb" );
		level.sdbomb.allowweapons = 1;
		level.sdbomb.onpickup = ::onpickup;
		level.sdbomb.ondrop = ::ondrop;
	}
	else
	{
		trigger delete();
		visuals[ 0 ] delete();
	}
	level.bombzones = [];
	bombzones = getentarray( "bombzone", "targetname" );
	index = 0;
	while ( index < bombzones.size )
	{
		trigger = bombzones[ index ];
		visuals = getentarray( bombzones[ index ].target, "targetname" );
		name = istring( trigger.script_label );
		precachestring( name );
		precachestring( istring( "defuse" + trigger.script_label ) );
		bombzone = maps/mp/gametypes/_gameobjects::createuseobject( game[ "defenders" ], trigger, visuals, ( 0, 0, 1 ), name );
		bombzone maps/mp/gametypes/_gameobjects::allowuse( "enemy" );
		bombzone maps/mp/gametypes/_gameobjects::setusetime( level.planttime );
		bombzone maps/mp/gametypes/_gameobjects::setusetext( &"MP_PLANTING_EXPLOSIVE" );
		bombzone maps/mp/gametypes/_gameobjects::setusehinttext( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
		if ( !level.multibomb )
		{
			bombzone maps/mp/gametypes/_gameobjects::setkeyobject( level.sdbomb );
		}
		label = bombzone maps/mp/gametypes/_gameobjects::getlabel();
		bombzone.label = label;
		bombzone maps/mp/gametypes/_gameobjects::set2dicon( "friendly", "compass_waypoint_defend" + label );
		bombzone maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defend" + label );
		bombzone maps/mp/gametypes/_gameobjects::set2dicon( "enemy", "compass_waypoint_target" + label );
		bombzone maps/mp/gametypes/_gameobjects::set3dicon( "enemy", "waypoint_target" + label );
		bombzone maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
		bombzone.onbeginuse = ::onbeginuse;
		bombzone.onenduse = ::onenduse;
		bombzone.onuse = ::onuseplantobject;
		bombzone.oncantuse = ::oncantuse;
		bombzone.useweapon = "briefcase_bomb_mp";
		bombzone.visuals[ 0 ].killcament = spawn( "script_model", bombzone.visuals[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 128 ) );
		if ( !level.multibomb )
		{
			bombzone.trigger setinvisibletoall();
		}
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
		bombzone.bombdefusetrig = getent( visuals[ 0 ].target, "targetname" );
/#
		assert( isDefined( bombzone.bombdefusetrig ) );
#/
		bombzone.bombdefusetrig.origin += vectorScale( ( 0, 0, 1 ), 10000 );
		bombzone.bombdefusetrig.label = label;
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
	if ( self maps/mp/gametypes/_gameobjects::isfriendlyteam( player.pers[ "team" ] ) )
	{
		player playsound( "mpl_sd_bomb_defuse" );
		player.isdefusing = 1;
		player thread maps/mp/gametypes/_battlechatter_mp::gametypespecificbattlechatter( "sd_enemyplant", player.pers[ "team" ] );
		if ( isDefined( level.sdbombmodel ) )
		{
			level.sdbombmodel hide();
		}
	}
	else
	{
		player.isplanting = 1;
		player thread maps/mp/gametypes/_battlechatter_mp::gametypespecificbattlechatter( "sd_friendlyplant", player.pers[ "team" ] );
		while ( level.multibomb )
		{
			i = 0;
			while ( i < self.otherbombzones.size )
			{
				self.otherbombzones[ i ] maps/mp/gametypes/_gameobjects::disableobject();
				i++;
			}
		}
	}
	player playsound( "fly_bomb_raise_plr" );
}

onenduse( team, player, result )
{
	if ( !isDefined( player ) )
	{
		return;
	}
	player.isdefusing = 0;
	player.isplanting = 0;
	player notify( "event_ended" );
	if ( self maps/mp/gametypes/_gameobjects::isfriendlyteam( player.pers[ "team" ] ) )
	{
		if ( isDefined( level.sdbombmodel ) && !result )
		{
			level.sdbombmodel show();
		}
	}
	else
	{
		while ( level.multibomb && !result )
		{
			i = 0;
			while ( i < self.otherbombzones.size )
			{
				self.otherbombzones[ i ] maps/mp/gametypes/_gameobjects::enableobject();
				i++;
			}
		}
	}
}

oncantuse( player )
{
	player iprintlnbold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}

onuseplantobject( player )
{
	if ( !self maps/mp/gametypes/_gameobjects::isfriendlyteam( player.pers[ "team" ] ) )
	{
		self maps/mp/gametypes/_gameobjects::setflags( 1 );
		level thread bombplanted( self, player );
		player logstring( "bomb planted: " + self.label );
		index = 0;
		while ( index < level.bombzones.size )
		{
			if ( level.bombzones[ index ] == self )
			{
				index++;
				continue;
			}
			else
			{
				level.bombzones[ index ] maps/mp/gametypes/_gameobjects::disableobject();
			}
			index++;
		}
		thread playsoundonplayers( "mus_sd_planted" + "_" + level.teampostfix[ player.pers[ "team" ] ] );
		player notify( "bomb_planted" );
		level thread maps/mp/_popups::displayteammessagetoall( &"MP_EXPLOSIVES_PLANTED_BY", player );
		if ( isDefined( player.pers[ "plants" ] ) )
		{
			player.pers[ "plants" ]++;
			player.plants = player.pers[ "plants" ];
		}
		maps/mp/_demo::bookmark( "event", getTime(), player );
		player addplayerstatwithgametype( "PLANTS", 1 );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_planted" );
		maps/mp/_scoreevents::processscoreevent( "planted_bomb", player );
		player recordgameevent( "plant" );
	}
}

onusedefuseobject( player )
{
	self maps/mp/gametypes/_gameobjects::setflags( 0 );
	player notify( "bomb_defused" );
	player logstring( "bomb defused: " + self.label );
	bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "sd_bombdefuse", self.label, player.pers[ "team" ] );
	level thread bombdefused();
	self maps/mp/gametypes/_gameobjects::disableobject();
	level thread maps/mp/_popups::displayteammessagetoall( &"MP_EXPLOSIVES_DEFUSED_BY", player );
	if ( isDefined( player.pers[ "defuses" ] ) )
	{
		player.pers[ "defuses" ]++;
		player.defuses = player.pers[ "defuses" ];
	}
	player addplayerstatwithgametype( "DEFUSES", 1 );
	maps/mp/_demo::bookmark( "event", getTime(), player );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_defused" );
	if ( isDefined( player.lastmansd ) && player.lastmansd == 1 )
	{
		maps/mp/_scoreevents::processscoreevent( "defused_bomb_last_man_alive", player );
	}
	else
	{
		maps/mp/_scoreevents::processscoreevent( "defused_bomb", player );
	}
	player recordgameevent( "defuse" );
}

ondrop( player )
{
	if ( !level.bombplanted )
	{
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_lost", game[ "attackers" ] );
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
	player recordgameevent( "pickup" );
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defend" );
	if ( !level.bombdefused )
	{
		if ( isDefined( player ) && isDefined( player.name ) )
		{
			player addplayerstatwithgametype( "PICKUPS", 1 );
		}
		team = self maps/mp/gametypes/_gameobjects::getownerteam();
		otherteam = getotherteam( team );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "bomb_acquired", game[ "attackers" ] );
		player logstring( "bomb taken" );
	}
	maps/mp/_utility::playsoundonplayers( game[ "bomb_recovered_sound" ], game[ "attackers" ] );
	i = 0;
	while ( i < level.bombzones.size )
	{
		level.bombzones[ i ].trigger setinvisibletoall();
		level.bombzones[ i ].trigger setvisibletoplayer( player );
		i++;
	}
}

onreset()
{
}

bombplantedmusicdelay()
{
	level endon( "bomb_defused" );
	time = level.bombtimer - 30;
/#
	if ( getDvarInt( #"0BC4784C" ) > 0 )
	{
		println( "Music System - waiting to set TIME_OUT: " + time );
#/
	}
	if ( time > 1 )
	{
		wait time;
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "TIME_OUT", "both" );
	}
}

bombplanted( destroyedobj, player )
{
	maps/mp/gametypes/_globallogic_utils::pausetimer();
	level.bombplanted = 1;
	team = player.pers[ "team" ];
	destroyedobj.visuals[ 0 ] thread maps/mp/gametypes/_globallogic_utils::playtickingsound( "mpl_sab_ui_suitcasebomb_timer" );
	level thread bombplantedmusicdelay();
	level.tickingobject = destroyedobj.visuals[ 0 ];
	level.timelimitoverride = 1;
	setgameendtime( int( getTime() + ( level.bombtimer * 1000 ) ) );
	label = destroyedobj maps/mp/gametypes/_gameobjects::getlabel();
	setmatchflag( "bomb_timer" + label, 1 );
	if ( label == "_a" )
	{
		setbombtimer( "A", int( getTime() + ( level.bombtimer * 1000 ) ) );
	}
	else
	{
		setbombtimer( "B", int( getTime() + ( level.bombtimer * 1000 ) ) );
	}
	bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "sd_bombplant", label, team );
	if ( !level.multibomb )
	{
		level.sdbomb maps/mp/gametypes/_gameobjects::allowcarry( "none" );
		level.sdbomb maps/mp/gametypes/_gameobjects::setvisibleteam( "none" );
		level.sdbomb maps/mp/gametypes/_gameobjects::setdropped();
		level.sdbombmodel = level.sdbomb.visuals[ 0 ];
	}
	else
	{
		index = 0;
		while ( index < level.players.size )
		{
			if ( isDefined( level.players[ index ].carryicon ) )
			{
				level.players[ index ].carryicon destroyelem();
			}
			index++;
		}
		trace = bullettrace( player.origin + vectorScale( ( 0, 0, 1 ), 20 ), player.origin - vectorScale( ( 0, 0, 1 ), 2000 ), 0, player );
		tempangle = randomfloat( 360 );
		forward = ( cos( tempangle ), sin( tempangle ), 0 );
		forward = vectornormalize( forward - vectorScale( trace[ "normal" ], vectordot( forward, trace[ "normal" ] ) ) );
		dropangles = vectorToAngle( forward );
		level.sdbombmodel = spawn( "script_model", trace[ "position" ] );
		level.sdbombmodel.angles = dropangles;
		level.sdbombmodel setmodel( "prop_suitcase_bomb" );
	}
	destroyedobj maps/mp/gametypes/_gameobjects::allowuse( "none" );
	destroyedobj maps/mp/gametypes/_gameobjects::setvisibleteam( "none" );
	label = destroyedobj maps/mp/gametypes/_gameobjects::getlabel();
	trigger = destroyedobj.bombdefusetrig;
	trigger.origin = level.sdbombmodel.origin;
	visuals = [];
	defuseobject = maps/mp/gametypes/_gameobjects::createuseobject( game[ "defenders" ], trigger, visuals, vectorScale( ( 0, 0, 1 ), 32 ), istring( "defuse" + label ) );
	defuseobject maps/mp/gametypes/_gameobjects::allowuse( "friendly" );
	defuseobject maps/mp/gametypes/_gameobjects::setusetime( level.defusetime );
	defuseobject maps/mp/gametypes/_gameobjects::setusetext( &"MP_DEFUSING_EXPLOSIVE" );
	defuseobject maps/mp/gametypes/_gameobjects::setusehinttext( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	defuseobject maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
	defuseobject maps/mp/gametypes/_gameobjects::set2dicon( "friendly", "compass_waypoint_defuse" + label );
	defuseobject maps/mp/gametypes/_gameobjects::set2dicon( "enemy", "compass_waypoint_defend" + label );
	defuseobject maps/mp/gametypes/_gameobjects::set3dicon( "friendly", "waypoint_defuse" + label );
	defuseobject maps/mp/gametypes/_gameobjects::set3dicon( "enemy", "waypoint_defend" + label );
	defuseobject maps/mp/gametypes/_gameobjects::setflags( 1 );
	defuseobject.label = label;
	defuseobject.onbeginuse = ::onbeginuse;
	defuseobject.onenduse = ::onenduse;
	defuseobject.onuse = ::onusedefuseobject;
	defuseobject.useweapon = "briefcase_bomb_defuse_mp";
	player.isbombcarrier = 0;
	bombtimerwait();
	setbombtimer( "A", 0 );
	setbombtimer( "B", 0 );
	setmatchflag( "bomb_timer_a", 0 );
	setmatchflag( "bomb_timer_b", 0 );
	destroyedobj.visuals[ 0 ] maps/mp/gametypes/_globallogic_utils::stoptickingsound();
	if ( level.gameended || level.bombdefused )
	{
		return;
	}
	level.bombexploded = 1;
	bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "sd_bombexplode", label, team );
	explosionorigin = level.sdbombmodel.origin + vectorScale( ( 0, 0, 1 ), 12 );
	level.sdbombmodel hide();
	if ( isDefined( player ) )
	{
		destroyedobj.visuals[ 0 ] radiusdamage( explosionorigin, 512, 200, 20, player, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );
		level thread maps/mp/_popups::displayteammessagetoall( &"MP_EXPLOSIVES_BLOWUP_BY", player );
		maps/mp/_scoreevents::processscoreevent( "bomb_detonated", player );
		player addplayerstatwithgametype( "DESTRUCTIONS", 1 );
		player recordgameevent( "destroy" );
	}
	else
	{
		destroyedobj.visuals[ 0 ] radiusdamage( explosionorigin, 512, 200, 20, undefined, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );
	}
	rot = randomfloat( 360 );
	explosioneffect = spawnfx( level._effect[ "bombexplosion" ], explosionorigin + vectorScale( ( 0, 0, 1 ), 50 ), ( 0, 0, 1 ), ( cos( rot ), sin( rot ), 0 ) );
	triggerfx( explosioneffect );
	thread playsoundinspace( "mpl_sd_exp_suitcase_bomb_main", explosionorigin );
	if ( isDefined( destroyedobj.exploderindex ) )
	{
		exploder( destroyedobj.exploderindex );
	}
	index = 0;
	while ( index < level.bombzones.size )
	{
		level.bombzones[ index ] maps/mp/gametypes/_gameobjects::disableobject();
		index++;
	}
	defuseobject maps/mp/gametypes/_gameobjects::disableobject();
	setgameendtime( 0 );
	wait 3;
	sd_endgame( game[ "attackers" ], game[ "strings" ][ "target_destroyed" ] );
}

bombtimerwait()
{
	level endon( "game_ended" );
	level endon( "bomb_defused" );
	maps/mp/gametypes/_hostmigration::waitlongdurationwithgameendtimeupdate( level.bombtimer );
}

bombdefused()
{
	level.tickingobject maps/mp/gametypes/_globallogic_utils::stoptickingsound();
	level.bombdefused = 1;
	setbombtimer( "A", 0 );
	setbombtimer( "B", 0 );
	setmatchflag( "bomb_timer_a", 0 );
	setmatchflag( "bomb_timer_b", 0 );
	level notify( "bomb_defused" );
	thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "SILENT", "both" );
	wait 1,5;
	setgameendtime( 0 );
	sd_endgame( game[ "defenders" ], game[ "strings" ][ "bomb_defused" ] );
}

sd_iskillboosting()
{
	roundsplayed = maps/mp/_utility::getroundsplayed();
	if ( level.playerkillsmax == 0 )
	{
		return 0;
	}
	if ( game[ "totalKills" ] > ( level.totalkillsmax * ( roundsplayed + 1 ) ) )
	{
		return 1;
	}
	if ( self.kills > ( level.playerkillsmax * ( roundsplayed + 1 ) ) )
	{
		return 1;
	}
	if ( level.teambased || self.team == "allies" && self.team == "axis" )
	{
		if ( game[ "totalKillsTeam" ][ self.team ] > ( level.playerkillsmax * ( roundsplayed + 1 ) ) )
		{
			return 1;
		}
	}
	return 0;
}
