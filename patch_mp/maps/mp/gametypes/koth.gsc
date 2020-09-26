#include maps/mp/_medals;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_demo;
#include maps/mp/_popups;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_callbacksetup;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

main() //checked changed to match cerberus output
{
	if ( getDvar( "mapname" ) == "mp_background" )
	{
		return;
	}
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	registertimelimit( 0, 1440 );
	registerscorelimit( 0, 1000 );
	registernumlives( 0, 100 );
	registerroundswitch( 0, 9 );
	registerroundwinlimit( 0, 10 );
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.teambased = 1;
	level.doprematch = 1;
	level.overrideteamscore = 1;
	level.scoreroundbased = 1;
	level.kothstarttime = 0;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.playerspawnedcb = ::koth_playerspawnedcb;
	level.onroundswitch = ::onroundswitch;
	level.onplayerkilled = ::onplayerkilled;
	level.onendgame = ::onendgame;
	level.gamemodespawndvars = ::koth_gamemodespawndvars;
	loadfx( "maps/mp_maps/fx_mp_koth_marker_neutral_1" );
	loadfx( "maps/mp_maps/fx_mp_koth_marker_neutral_wndw" );
	precachestring( &"MP_WAITING_FOR_HQ" );
	precachestring( &"MP_KOTH_CAPTURED_BY" );
	precachestring( &"MP_KOTH_CAPTURED_BY_ENEMY" );
	precachestring( &"MP_KOTH_MOVING_IN" );
	precachestring( &"MP_CAPTURING_OBJECTIVE" );
	precachestring( &"MP_KOTH_CONTESTED_BY_ENEMY" );
	precachestring( &"MP_KOTH_AVAILABLE_IN" );
	registerclientfield( "world", "hardpoint", 1, 5, "int" );
	level.zoneautomovetime = getgametypesetting( "autoDestroyTime" );
	level.zonespawntime = getgametypesetting( "objectiveSpawnTime" );
	level.kothmode = getgametypesetting( "kothMode" );
	level.capturetime = getgametypesetting( "captureTime" );
	level.destroytime = getgametypesetting( "destroyTime" );
	level.delayplayer = getgametypesetting( "delayPlayer" );
	level.randomzonespawn = getgametypesetting( "randomObjectiveLocations" );
	level.scoreperplayer = getgametypesetting( "scorePerPlayer" );
	level.iconoffset = vectorScale( ( 0, 0, 1 ), 32 );
	level.onrespawndelay = ::getrespawndelay;
	game[ "dialog" ][ "gametype" ] = "koth_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "koth_start";
	game[ "dialog" ][ "offense_obj" ] = "cap_start";
	game[ "dialog" ][ "defense_obj" ] = "cap_start";
	game[ "objective_gained_sound" ] = "mpl_flagcapture_sting_friend";
	game[ "objective_lost_sound" ] = "mpl_flagcapture_sting_enemy";
	game[ "objective_contested_sound" ] = "mpl_flagreturn_sting";
	level.lastdialogtime = 0;
	level.zonespawnqueue = [];
	if ( !sessionmodeissystemlink() && !sessionmodeisonlinegame() && issplitscreen() )
	{
		setscoreboardcolumns( "score", "kills", "captures", "defends", "deaths" );
	}
	else
	{
		setscoreboardcolumns( "score", "kills", "deaths", "captures", "defends" );
	}
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_objective", 0 );
	/*
/#
	trigs = getentarray( "radiotrigger", "targetname" );
	foreach ( trig in trigs )
	{
		trig delete();
#/
	}
	*/
}

updateobjectivehintmessages( defenderteam, defendmessage, attackmessage ) //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	foreach ( team in level.teams )
	{
		if ( defenderteam == team )
		{
			game[ "strings" ][ "objective_hint_" + team ] = defendmessage;
		}
		else
		{
			game[ "strings" ][ "objective_hint_" + team ] = attackmessage;
		}
	}
}

updateobjectivehintmessage( message ) //checked changed to match cerberus output
{
	foreach ( team in level.teams )
	{
		game[ "strings" ][ "objective_hint_" + team ] = message;
	}
}

getrespawndelay() //checked matches cerberus output
{
	self.lowermessageoverride = undefined;
	if ( !isDefined( level.zone.gameobject ) )
	{
		return undefined;
	}
	zoneowningteam = level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam();
	if ( self.pers[ "team" ] == zoneowningteam )
	{
		if ( !isDefined( level.zonemovetime ) )
		{
			return undefined;
		}
		timeremaining = ( level.zonemovetime - getTime() ) / 1000;
		if ( !level.playerobjectiveheldrespawndelay )
		{
			return undefined;
		}
		if ( level.playerobjectiveheldrespawndelay >= level.zoneautomovetime )
		{
			self.lowermessageoverride = &"MP_WAITING_FOR_HQ";
		}
		if ( level.delayplayer )
		{
			return min( level.spawndelay, timeremaining );
		}
		else
		{
			return ceil( timeremaining );
		}
	}
}

onstartgametype() //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
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
	maps/mp/gametypes/_globallogic_score::resetteamscores();
	foreach ( team in level.teams )
	{
		setobjectivetext( team, &"OBJECTIVES_KOTH" );
		if ( level.splitscreen )
		{
			setobjectivescoretext( team, &"OBJECTIVES_KOTH" );
		}
		else
		{
			setobjectivescoretext( team, &"OBJECTIVES_KOTH_SCORE" );
		}
	}
	level.objectivehintpreparezone = &"MP_CONTROL_KOTH";
	level.objectivehintcapturezone = &"MP_CAPTURE_KOTH";
	level.objectivehintdefendhq = &"MP_DEFEND_KOTH";
	precachestring( level.objectivehintpreparezone );
	precachestring( level.objectivehintcapturezone );
	precachestring( level.objectivehintdefendhq );
	if ( level.zonespawntime )
	{
		updateobjectivehintmessage( level.objectivehintpreparezone );
	}
	else
	{
		updateobjectivehintmessage( level.objectivehintcapturezone );
	}
	setclientnamemode( "auto_change" );
	allowed = [];
	allowed[ 0 ] = "koth";
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 0, 0, 0 );
	level.spawnmaxs = ( 0, 0, 0 );
	foreach ( team in level.teams )
	{
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, "mp_tdm_spawn" );
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, "mp_multi_team_spawn" );
		maps/mp/gametypes/_spawnlogic::placespawnpoints( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
	level.spawn_start = [];
	foreach ( team in level.teams )
	{
		level.spawn_start[ team ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
	}
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.spawn_all = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_tdm_spawn" );
	if ( !level.spawn_all.size )
	{
		/*
/#
		println( "^1No mp_tdm_spawn spawnpoints in level!" );
#/
		*/
		maps/mp/gametypes/_callbacksetup::abortlevel();
		return;
	}
	thread setupzones();
	updategametypedvars();
	thread kothmainloop();
}

updategametypedvars() //checked matches cerberus output
{
	level.playercapturelpm = getgametypesetting( "maxPlayerEventsPerMinute" );
}

spawn_first_zone( delay ) //checked matches cerberus output
{
	if ( level.randomzonespawn == 1 )
	{
		level.zone = getnextzonefromqueue();
	}
	else
	{
		level.zone = getfirstzone();
	}
	if ( isDefined( level.zone ) )
	{
		logstring( "zone spawned: (" + level.zone.trigorigin[ 0 ] + "," + level.zone.trigorigin[ 1 ] + "," + level.zone.trigorigin[ 2 ] + ")" );
		level.zone enable_zone_spawn_influencer( 1 );
	}
	level.zone.gameobject.trigger allowtacticalinsertion( 0 );
	return;
}

spawn_next_zone() //checked matches cerberus output
{
	level.zone.gameobject.trigger allowtacticalinsertion( 1 );
	if ( level.randomzonespawn != 0 )
	{
		level.zone = getnextzonefromqueue();
	}
	else
	{
		level.zone = getnextzone();
	}
	if ( isDefined( level.zone ) )
	{
		logstring( "zone spawned: (" + level.zone.trigorigin[ 0 ] + "," + level.zone.trigorigin[ 1 ] + "," + level.zone.trigorigin[ 2 ] + ")" );
		level.zone enable_zone_spawn_influencer( 1 );
	}
	level.zone.gameobject.trigger allowtacticalinsertion( 0 );
	return;
}

getnumtouching() //checked changed to match cerberus output
{
	numtouching = 0;
	foreach ( team in level.teams )
	{
		numtouching += self.numtouching[ team ];
	}
	return numtouching;
}

togglezoneeffects( enabled ) //checked matches cerberus output
{
	index = 0;
	if ( enabled )
	{
		index = self.script_index;
	}
	level setclientfield( "hardpoint", index );
}

kothcaptureloop() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	level endon( "zone_moved" );
	level.kothstarttime = getTime();
	while ( 1 )
	{
		level.zone.gameobject maps/mp/gametypes/_gameobjects::allowuse( "any" );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setusetime( level.capturetime );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setusetext( &"MP_CAPTURING_OBJECTIVE" );
		numtouching = level.zone.gameobject getnumtouching();
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setmodelvisibility( 1 );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::mustmaintainclaim( 0 );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::cancontestclaim( 1 );
		level.zone.gameobject.onuse = ::onzonecapture;
		level.zone.gameobject.onbeginuse = ::onbeginuse;
		level.zone.gameobject.onenduse = ::onenduse;
		level.zone togglezoneeffects( 1 );
		msg = level waittill_any_return( "zone_captured", "zone_destroyed" );
		if ( msg == "zone_destroyed" )
		{
			continue;
		}
		ownerteam = level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam();
		foreach ( team in level.teams )
		{
			updateobjectivehintmessages( ownerteam, level.objectivehintdefendhq, level.objectivehintcapturezone );
		}
		level.zone.gameobject maps/mp/gametypes/_gameobjects::allowuse( "none" );
		level.zone.gameobject.onuse = undefined;
		level.zone.gameobject.onunoccupied = ::onzoneunoccupied;
		level.zone.gameobject.oncontested = ::onzonecontested;
		level.zone.gameobject.onuncontested = ::onzoneuncontested;
		level waittill( "zone_destroyed", destroy_team );
		if ( !level.kothmode || level.zonedestroyedbytimer )
		{
			return;
		}
		thread forcespawnteam( ownerteam );
		if ( isDefined( destroy_team ) )
		{
			level.zone.gameobject maps/mp/gametypes/_gameobjects::setownerteam( destroy_team );
		}
		else
		{
			level.zone.gameobject maps/mp/gametypes/_gameobjects::setownerteam( "none" );
		}
	}
}

kothmainloop() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	level.zonerevealtime = -100000;
	zonespawninginstr = &"MP_KOTH_AVAILABLE_IN";
	if ( level.kothmode )
	{
		zonedestroyedinfriendlystr = &"MP_HQ_DESPAWN_IN";
		zonedestroyedinenemystr = &"MP_KOTH_MOVING_IN";
	}
	else
	{
		zonedestroyedinfriendlystr = &"MP_HQ_REINFORCEMENTS_IN";
		zonedestroyedinenemystr = &"MP_HQ_DESPAWN_IN";
	}
	precachestring( zonespawninginstr );
	precachestring( zonedestroyedinfriendlystr );
	precachestring( zonedestroyedinenemystr );
	precachestring( &"MP_CAPTURING_HQ" );
	precachestring( &"MP_DESTROYING_HQ" );
	objective_name = istring( "objective" );
	precachestring( objective_name );
	spawn_first_zone();
	while ( level.inprematchperiod )
	{
		wait 0.05;
	}
	wait 5;
	timerdisplay = [];
	foreach ( team in level.teams )
	{
		timerdisplay[ team ] = createservertimer( "objective", 1.4, team );
		timerdisplay[ team ] setgamemodeinfopoint();
		timerdisplay[ team ].label = zonespawninginstr;
		timerdisplay[ team ].font = "extrasmall";
		timerdisplay[ team ].alpha = 0;
		timerdisplay[ team ].archived = 0;
		timerdisplay[ team ].hidewheninmenu = 1;
		timerdisplay[ team ].hidewheninkillcam = 1;
		timerdisplay[ team ].showplayerteamhudelemtospectator = 1;
		thread hidetimerdisplayongameend( timerdisplay[ team ] );
	}
	while ( 1 )
	{
		playsoundonplayers( "mp_suitcase_pickup" );
		maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_objective" );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_located" );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setmodelvisibility( 1 );
		level.zonerevealtime = getTime();
		if ( level.zonespawntime )
		{
			level.zone.gameobject maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
			level.zone.gameobject maps/mp/gametypes/_gameobjects::setflags( 1 );
			updateobjectivehintmessage( level.objectivehintpreparezone );
			foreach ( team in level.teams )
			{
				timerdisplay[ team ].label = zonespawninginstr;
				timerdisplay[ team ] settimer( level.zonespawntime );
				timerdisplay[ team ].alpha = 1;
			}
			wait level.zonespawntime;
			level.zone.gameobject maps/mp/gametypes/_gameobjects::setflags( 0 );
			maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_online" );
		}
		foreach ( team in level.teams )
		{
			timerdisplay[ team ].alpha = 0;
		}
		waittillframeend;
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "obj_capture", undefined, "gamemode_objective" );
		updateobjectivehintmessage( level.objectivehintcapturezone );
		playsoundonplayers( "mpl_hq_cap_us" );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::enableobject();
		level.zone.gameobject.capturecount = 0;
		if ( level.zoneautomovetime )
		{
			thread movezoneaftertime( level.zoneautomovetime );
			foreach ( team in level.teams )
			{
				timerdisplay[ team ] settimer( level.zoneautomovetime );
			}
			foreach ( team in level.teams )
			{
				timerdisplay[ team ].label = zonedestroyedinenemystr;
				timerdisplay[ team ].alpha = 1;
			}
		}
		else 
		{
			level.zonedestroyedbytimer = 0;
		}
		kothcaptureloop();
		ownerteam = level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam();
		if ( level.zone.gameobject.capturecount == 1 )
		{
			touchlist = [];
			touchkeys = getarraykeys( level.zone.gameobject.touchlist[ ownerteam ] );
			for ( i = 0; i < touchkeys.size; i++ )
			{
				touchlist[ touchkeys[ i ] ] = level.zone.gameobject.touchlist[ ownerteam ][ touchkeys[ i ] ];
			}
			thread give_held_credit( touchlist );
		}
		level.zone enable_zone_spawn_influencer( 0 );
		level.zone.gameobject.lastcaptureteam = undefined;
		level.zone.gameobject maps/mp/gametypes/_gameobjects::disableobject();
		level.zone.gameobject maps/mp/gametypes/_gameobjects::allowuse( "none" );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setownerteam( "neutral" );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::setmodelvisibility( 0 );
		level.zone.gameobject maps/mp/gametypes/_gameobjects::mustmaintainclaim( 0 );
		level.zone togglezoneeffects( 0 );
		level notify( "zone_reset" );
		foreach ( team in level.teams )
		{
			timerdisplay[ team ].alpha = 0;
		}
		spawn_next_zone();
		wait 0.5;
		thread forcespawnteam( ownerteam );
		wait 0.5;
	}
}

hidetimerdisplayongameend( timerdisplay ) //checked matches cerberus output
{
	level waittill( "game_ended" );
	timerdisplay.alpha = 0;
}

forcespawnteam( team ) //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( !isDefined( player ) )
		{
			i++;
			continue;
		}
		if ( player.pers[ "team" ] == team )
		{
			player notify( "force_spawn" );
			wait 0.1;
		}
		i++;
	}
}

onbeginuse( player ) //checked matches cerberus output
{
	ownerteam = self maps/mp/gametypes/_gameobjects::getownerteam();
	if ( ownerteam == "neutral" )
	{
		player thread maps/mp/gametypes/_battlechatter_mp::gametypespecificbattlechatter( "hq_protect", player.pers[ "team" ] );
	}
	else
	{
		player thread maps/mp/gametypes/_battlechatter_mp::gametypespecificbattlechatter( "hq_attack", player.pers[ "team" ] );
	}
}

onenduse( team, player, success ) //checked matches cerberus output
{
	player notify( "event_ended" );
}

onzonecapture( player ) //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	capture_team = player.pers[ "team" ];
	capturetime = getTime();
	player logstring( "zone captured" );
	string = &"MP_KOTH_CAPTURED_BY";
	level.zone.gameobject.iscontested = 0;
	level.usestartspawns = 0;
	if ( !isDefined( self.lastcaptureteam ) || self.lastcaptureteam != capture_team )
	{
		touchlist = [];
		touchkeys = getarraykeys( self.touchlist[ capture_team ] );
		for ( i = 0; i < touchkeys.size; i++ )
		{
			touchlist[ touchkeys[ i ] ] = self.touchlist[ capture_team ][ touchkeys[ i ] ];
		}
		thread give_capture_credit( touchlist, string, capturetime, capture_team, self.lastcaptureteam );
	}
	level.kothcapteam = capture_team;
	oldteam = maps/mp/gametypes/_gameobjects::getownerteam();
	self maps/mp/gametypes/_gameobjects::setownerteam( capture_team );
	if ( !level.kothmode )
	{
		self maps/mp/gametypes/_gameobjects::setusetime( level.destroytime );
	}
	foreach ( team in level.teams )
	{
		if ( team == capture_team )
		{
			if ( isDefined( self.lastcaptureteam ) && self.lastcaptureteam != team )
			{
				maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_secured", team, "gamemode_objective" );
				for ( index = 0; index < level.players.size; index++ )
				{
					player = level.players[ index ];
					if ( player.pers[ "team" ] == team )
					{
						if ( ( player.lastkilltime + 500 ) > getTime() )
						{
							player maps/mp/_challenges::killedlastcontester();
						}
					}
				}
			}
			thread playsoundonplayers( game[ "objective_gained_sound" ], team );
		}
	  	else 
		{
			if ( oldteam == team )
			{
				maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_lost", team, "gamemode_objective" );
			}
			else if ( oldteam == "neutral" )
			{
				maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_captured", team, "gamemode_objective" );
			}
			thread playsoundonplayers( game[ "objective_lost_sound" ], team );
		}
	}
	level thread awardcapturepoints( capture_team, self.lastcaptureteam );
	self.capturecount++;
	self.lastcaptureteam = capture_team;
	self maps/mp/gametypes/_gameobjects::mustmaintainclaim( 1 );
	level notify( "zone_captured" );
	level notify( "zone_captured" + capture_team );
	player notify( "event_ended" );
}

give_capture_credit( touchlist, string, capturetime, capture_team, lastcaptureteam ) //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	wait 0.05;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	players = getarraykeys( touchlist );
	i = 0;
	while ( i < players.size )
	{
		player = touchlist[ players[ i ] ].player;
		player updatecapsperminute( lastcaptureteam );
		if ( !isscoreboosting( player ) )
		{
			player maps/mp/_challenges::capturedobjective( capturetime );
			if ( ( level.kothstarttime + 3000 ) > capturetime && level.kothcapteam == capture_team )
			{
				maps/mp/_scoreevents::processscoreevent( "quickly_secure_point", player );
			}
			maps/mp/_scoreevents::processscoreevent( "koth_secure", player );
			player recordgameevent( "capture" );
			level thread maps/mp/_popups::displayteammessagetoall( string, player );
			if ( isDefined( player.pers[ "captures" ] ) )
			{
				player.pers[ "captures" ]++;
				player.captures = player.pers[ "captures" ];
			}
			if ( ( level.kothstarttime + 500 ) > capturetime )
			{
				player maps/mp/_challenges::immediatecapture();
			}
			maps/mp/_demo::bookmark( "event", getTime(), player );
			player addplayerstatwithgametype( "CAPTURES", 1 );
			i++;
			continue;
		}
		/*
/#
		player iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU CAPTURE CREDIT AS BOOSTING PREVENTION" );
#/
		*/
		i++;
	}
}

give_held_credit( touchlist, team ) //checked changed to match cerberus output
{
	wait 0.05;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	players = getarraykeys( touchlist );
	for ( i = 0; i < players.size; i++ )
	{
		player = touchlist[ players[ i ] ].player;
	}
}

onzonedestroy( player ) //checked changed to match cerberus output
{
	destroyed_team = player.pers[ "team" ];
	player logstring( "zone destroyed" );
	maps/mp/_scoreevents::processscoreevent( "zone_destroyed", player );
	player recordgameevent( "destroy" );
	player addplayerstatwithgametype( "DESTRUCTIONS", 1 );
	if ( isDefined( player.pers[ "destructions" ] ) )
	{
		player.pers[ "destructions" ]++;
		player.destructions = player.pers[ "destructions" ];
	}
	destroyteammessage = &"MP_HQ_DESTROYED_BY";
	otherteammessage = &"MP_HQ_DESTROYED_BY_ENEMY";
	if ( level.kothmode )
	{
		destroyteammessage = &"MP_KOTH_CAPTURED_BY";
		otherteammessage = &"MP_KOTH_CAPTURED_BY_ENEMY";
	}
	level thread maps/mp/_popups::displayteammessagetoall( destroyteammessage, player );
	foreach ( team in level.teams )
	{
		if ( team == destroyed_team )
		{
			maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_secured", team, "gamemode_objective" );
		}
		else
		{
			maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_destroyed", team, "gamemode_objective" );
		}
	}
	level notify( "zone_destroyed", destroyed_team );
	if ( level.kothmode )
	{
		level thread awardcapturepoints( destroyed_team );
	}
	player notify( "event_ended" );
}

onzoneunoccupied() //checked matches cerberus output
{
	level notify( "zone_destroyed" );
	level.kothcapteam = "neutral";
	level.zone.gameobject.wasleftunoccupied = 1;
	level.zone.gameobject.iscontested = 0;
}

onzonecontested() //checked changed to match cerberus output
{
	zoneowningteam = level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam();
	level.zone.gameobject.wascontested = 1;
	level.zone.gameobject.iscontested = 1;
	foreach ( team in level.teams ) 
	{
		if ( team == zoneowningteam )
		{
			thread playsoundonplayers( game[ "objective_contested_sound" ], team );
			maps/mp/gametypes/_globallogic_audio::leaderdialog( "koth_contested", team, "gamemode_objective" );
		}
	}
}

onzoneuncontested( lastclaimteam ) //checked matches cerberus output
{
	/*
/#
	assert( lastclaimteam == level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam() );
#/
	*/
	level.zone.gameobject.iscontested = 0;
	level.zone.gameobject maps/mp/gametypes/_gameobjects::setclaimteam( lastclaimteam );
}

movezoneaftertime( time ) //checked matches cerberus output
{
	level endon( "game_ended" );
	level endon( "zone_reset" );
	level.zonemovetime = getTime() + ( time * 1000 );
	level.zonedestroyedbytimer = 0;
	wait time;
	if ( !isDefined( level.zone.gameobject.wascontested ) || level.zone.gameobject.wascontested == 0 )
	{
		if ( !isDefined( level.zone.gameobject.wasleftunoccupied ) || level.zone.gameobject.wasleftunoccupied == 0 )
		{
			zoneowningteam = level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam();
			maps/mp/_challenges::controlzoneentirely( zoneowningteam );
		}
	}
	level.zonedestroyedbytimer = 1;
	level notify( "zone_moved" );
}

awardcapturepoints( team, lastcaptureteam ) //checked matches cerberus output
{
	level endon( "game_ended" );
	level endon( "zone_destroyed" );
	level endon( "zone_reset" );
	level endon( "zone_moved" );
	level notify( "awardCapturePointsRunning" );
	level endon( "awardCapturePointsRunning" );
	seconds = 1;
	score = 1;
	while ( !level.gameended )
	{
		wait seconds;
		maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
		if ( !level.zone.gameobject.iscontested )
		{
			if ( level.scoreperplayer )
			{
				score = level.zone.gameobject.numtouching[ team ];
			}
			maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( team, score );
		}
	}
}

onspawnplayerunified() //checked matches cerberus output
{
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn ) //checked matches cerberus output
{
	spawnpoint = undefined;
	if ( !level.usestartspawns )
	{
		if ( isDefined( level.zone ) )
		{
			if ( isDefined( level.zone.gameobject ) )
			{
				zoneowningteam = level.zone.gameobject maps/mp/gametypes/_gameobjects::getownerteam();
				if ( self.pers[ "team" ] == zoneowningteam )
				{
					spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_all, level.zone.gameobject.nearspawns );
				}
				else if ( level.spawndelay >= level.zoneautomovetime && getTime() > ( level.zonerevealtime + 10000 ) )
				{
					spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_all );
				}
				else
				{
					spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_all, level.zone.gameobject.outerspawns );
				}
			}
		}
	}
	if ( !isDefined( spawnpoint ) )
	{
		spawnteam = self.pers[ "team" ];
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( level.spawn_start[ spawnteam ] );
	}
	/*
/#
	assert( isDefined( spawnpoint ) );
#/
	*/
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "koth" );
	}
}

koth_playerspawnedcb() //checked matches cerberus output
{
	self.lowermessageoverride = undefined;
}

comparezoneindexes( zone_a, zone_b ) //checked matches cerberus output
{
	script_index_a = zone_a.script_index;
	script_index_b = zone_b.script_index;
	if ( !isDefined( script_index_a ) && !isDefined( script_index_b ) )
	{
		return 0;
	}
	if ( !isDefined( script_index_a ) && isDefined( script_index_b ) )
	{
		/*
/#
		println( "KOTH: Missing script_index on zone at " + zone_a.origin );
#/
		*/
		return 1;
	}
	if ( isDefined( script_index_a ) && !isDefined( script_index_b ) )
	{
		/*
/#
		println( "KOTH: Missing script_index on zone at " + zone_b.origin );
#/
		*/
		return 0;
	}
	if ( script_index_a > script_index_b )
	{
		return 1;
	}
	return 0;
}

getzonearray() //checked changed to match cerberus output
{
	zones = getentarray( "koth_zone_center", "targetname" );
	if ( !isDefined( zones ) )
	{
		return undefined;
	}
	swapped = 1;
	n = zones.size;
	while ( swapped )
	{
		swapped = 0;
		for ( i = 0; i < n - 1; i++ )
		{
			if ( comparezoneindexes( zones[ i ], zones[ i + 1 ] ) )
			{
				temp = zones[ i ];
				zones[ i ] = zones[ i + 1 ];
				zones[ i + 1 ] = temp;
				swapped = 1;
			}
		}
		n--;

	}
	return zones;
}

setupzones() //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	maperrors = [];
	zones = getzonearray();
	trigs = getentarray( "koth_zone_trigger", "targetname" );
	i = 0;
	while ( i < zones.size )
	{
		errored = 0;
		zone = zones[ i ];
		zone.trig = undefined;
		for ( j = 0; j < trigs.size; j++ )
		{
			if ( zone istouching( trigs[ j ] ) )
			{
				if ( isDefined( zone.trig ) )
				{
					maperrors[ maperrors.size ] = "Zone at " + zone.origin + " is touching more than one zonetrigger trigger";
					errored = 1;
					break;
				}
				zone.trig = trigs[ j ];
				break;
			}
		}
		if ( !isDefined( zone.trig ) )
		{
			if ( !errored )
			{
				maperrors[ maperrors.size ] = "Zone at " + zone.origin + " is not inside any zonetrigger trigger";
				i++;
				continue;
			}
		}
		/*
/#
		assert( !errored );
#/
		*/
		zone.trigorigin = zone.trig.origin;
		visuals = [];
		visuals[ 0 ] = zone;
		if ( isDefined( zone.target ) )
		{
			othervisuals = getentarray( zone.target, "targetname" );
			for ( j = 0; j < othervisuals.size; j++ )
			{
				visuals[ visuals.size ] = othervisuals[ j ];
			}
		}
		objective_name = istring( "objective" );
		precachestring( objective_name );
		zone.gameobject = maps/mp/gametypes/_gameobjects::createuseobject( "neutral", zone.trig, visuals, ( 0, 0, 0 ), objective_name );
		zone.gameobject maps/mp/gametypes/_gameobjects::disableobject();
		zone.gameobject maps/mp/gametypes/_gameobjects::setmodelvisibility( 0 );
		zone.trig.useobj = zone.gameobject;
		zone setupnearbyspawns();
		zone createzonespawninfluencer();
		i++;
	}
	if ( maperrors.size > 0 )
	{
		/*
/#
		println( "^1------------ Map Errors ------------" );
		i = 0;
		while ( i < maperrors.size )
		{
			println( maperrors[ i ] );
			i++;
		}
		println( "^1------------------------------------" );
		maps/mp/_utility::error( "Map errors. See above" );
#/
		*/
		maps/mp/gametypes/_callbacksetup::abortlevel();
		return;
	}
	level.zones = zones;
	level.prevzone = undefined;
	level.prevzone2 = undefined;
	setupzoneexclusions();
	return 1;
}

setupzoneexclusions() //checked changed to match cerberus output
{
	if ( !isDefined( level.levelkothdisable ) )
	{
		return;
	}
	foreach ( nullzone in level.levelkothdisable )
	{
		mindist = 1410065408;
		foundzone = undefined;
		foreach ( zone in level.zones )
		{
			distance = distancesquared( nullzone.origin, zone.origin );
			if ( distance < mindist )
			{
				foundzone = zone;
				mindist = distance;
			}
		}
		if ( isDefined( foundzone ) )
		{
			if ( !isDefined( foundzone.gameobject.exclusions ) )
			{
				foundzone.gameobject.exclusions = [];
			}
			foundzone.gameobject.exclusions[ foundzone.gameobject.exclusions.size ] = nullzone;
		}
	}
}

setupnearbyspawns() //checked changed to match cerberus output
{
	spawns = level.spawn_all;
	for ( i = 0; i < spawns.size; i++ )
	{
		spawns[ i ].distsq = distancesquared( spawns[ i ].origin, self.origin );
	}
	for ( i = 1; i < spawns.size; i++ )
	{
		thespawn = spawns[ i ];
		for ( j = i - 1; j >= 0 && thespawn.distsq < spawns[j].distsq; j-- )
		{
			spawns[ j + 1 ] = spawns[ j ];
		}
		spawns[ j + 1 ] = thespawn;
	}
	first = [];
	second = [];
	third = [];
	outer = [];
	thirdsize = spawns.size / 3;
	for ( i = 0; i <= thirdsize; i++ )
	{
		first[ first.size ] = spawns[ i ];
	}
	while ( i < spawns.size )
	{
		outer[ outer.size ] = spawns[ i ];
		if ( i <= ( thirdsize * 2 ) )
		{
			second[ second.size ] = spawns[ i ];
			i++;
		}
		else
		{
			third[ third.size ] = spawns[ i ];
		}
		i++;
	}
	self.gameobject.nearspawns = first;
	self.gameobject.midspawns = second;
	self.gameobject.farspawns = third;
	self.gameobject.outerspawns = outer;
}

getfirstzone() //checked matches cerberus output
{
	zone = level.zones[ 0 ];
	level.prevzone2 = level.prevzone;
	level.prevzone = zone;
	level.prevzoneindex = 0;
	shufflezones();
	arrayremovevalue( level.zonespawnqueue, zone );
	return zone;
}

getnextzone() //checked matches cerberus output
{
	nextzoneindex = ( level.prevzoneindex + 1 ) % level.zones.size;
	zone = level.zones[ nextzoneindex ];
	level.prevzone2 = level.prevzone;
	level.prevzone = zone;
	level.prevzoneindex = nextzoneindex;
	return zone;
}

pickrandomzonetospawn() //checked matches cerberus output
{
	level.prevzoneindex = randomint( level.zones.size );
	zone = level.zones[ level.prevzoneindex ];
	level.prevzone2 = level.prevzone;
	level.prevzone = zone;
	return zone;
}

shufflezones() //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	level.zonespawnqueue = [];
	spawnqueue = arraycopy( level.zones );
	for ( total_left = spawnqueue.size; total_left > 0; total_left-- )
	{
		index = randomint( total_left );
		valid_zones = 0;
		zone = 0;
		while ( zone < level.zones.size )
		{
			if ( !isDefined( spawnqueue[ zone ] ) )
			{
				zone++;
				continue;
			}
			if ( valid_zones == index )
			{
				if ( level.zonespawnqueue.size == 0 && isDefined( level.zone ) && level.zone == spawnqueue[ zone ] )
				{
					zone++;
					continue;
				}
				level.zonespawnqueue[ level.zonespawnqueue.size ] = spawnqueue[ zone ];
				spawnqueue[zone] = undefined;
				break;
			}
			valid_zones++;
			zone++;
		}
	}
}

getnextzonefromqueue() //checked matches cerberus output
{
	if ( level.zonespawnqueue.size == 0 )
	{
		shufflezones();
	}
	/*
/#
	assert( level.zonespawnqueue.size > 0 );
#/
	*/
	next_zone = level.zonespawnqueue[ 0 ];
	arrayremoveindex( level.zonespawnqueue, 0 );
	return next_zone;
}

getcountofteamswithplayers( num ) //checked changed to match cerberus output
{
	has_players = 0;
	foreach ( team in level.teams )
	{
		if ( num[ team ] > 0 )
		{
			has_players++;
		}
	}
	return has_players;
}

getpointcost( avgpos, origin ) //checked changed to match cerberus output
{
	avg_distance = 0;
	total_error = 0;
	distances = [];
	foreach ( position in avgpos )
	{
		distances[ team ] = distance( origin, avgpos[ team ] );
		avg_distance += distances[ team ];
	}
	avg_distance /= distances.size;
	foreach ( dist in distances )
	{
		err = distances[ team ] - avg_distance;
		total_error += err * err;
	}
	return total_error;
}

pickzonetospawn() //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	foreach ( team in level.teams )
	{
		avgpos[ team ] = ( 0, 0, 0 );
		num[ team ] = 0;
	}
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];
		if ( isalive( player ) )
		{
			avgpos[ player.pers[ "team" ] ] += player.origin;
			num[ player.pers[ "team" ] ]++;
		}
	}
	if ( getcountofteamswithplayers( num ) <= 1 )
	{
		zone = level.zones[ randomint( level.zones.size ) ];
		while ( isDefined( level.prevzone ) && zone == level.prevzone )
		{
			zone = level.zones[ randomint( level.zones.size ) ];
		}
		level.prevzone2 = level.prevzone;
		level.prevzone = zone;
		return zone;
	}
	foreach ( team in level.teams )
	{
		if ( num[ team ] == 0 )
		{
			avgpos[team] = undefined;
		}
		else
		{
			avgpos[ team ] /= num[ team ];
		}
	}
	bestzone = undefined;
	lowestcost = undefined;
	i = 0;
	while ( i < level.zones.size )
	{
		zone = level.zones[ i ];
		cost = getpointcost( avgpos, zone.origin );
		if ( isDefined( level.prevzone ) && zone == level.prevzone )
		{
			i++;
			continue;
		}
		if ( isDefined( level.prevzone2 ) && zone == level.prevzone2 )
		{
			if ( level.zones.size > 2 )
			{
				i++;
				continue;
			}
			else 
			{
				cost += 262144;
			}
		}
		if ( !isDefined( lowestcost ) || cost < lowestcost )
		{
			lowestcost = cost;
			bestzone = zone;
		}
		i++;
	}
	/*
/#
	assert( isDefined( bestzone ) );
#/
	*/
	level.prevzone2 = level.prevzone;
	level.prevzone = bestzone;
	return bestzone;
}

onroundswitch() //checked matches cerberus output
{
	game[ "switchedsides" ] = !game[ "switchedsides" ];
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked changed to match cerberus output
{
	if ( isplayer( attacker ) || level.capturetime && !self.touchtriggers.size && !attacker.touchtriggers.size || attacker.pers[ "team" ] == self.pers[ "team" ] )
	{
		return;
	}
	medalgiven = 0;
	scoreeventprocessed = 0;
	ownerteam = undefined;
	if ( level.capturetime == 0 )
	{
		if ( !isDefined( level.zone ) )
		{
			return;
		}
		ownerteam = level.zone.gameobject.ownerteam;
		if ( !isDefined( ownerteam ) || ownerteam == "neutral" )
		{
			return;
		}
	}
	if ( self.touchtriggers.size || level.capturetime == 0 && self istouching( level.zone.trig ) )
	{
		if ( level.capturetime > 0 )
		{
			triggerids = getarraykeys( self.touchtriggers );
			ownerteam = self.touchtriggers[ triggerids[ 0 ] ].useobj.ownerteam;
		}
		if ( ownerteam != "neutral" )
		{
			attacker.lastkilltime = getTime();
			team = self.pers[ "team" ];
			if ( team == ownerteam )
			{
				if ( !medalgiven )
				{
					attacker maps/mp/_medals::offenseglobalcount();
					attacker addplayerstatwithgametype( "OFFENDS", 1 );
					medalgiven = 1;
				}
				maps/mp/_scoreevents::processscoreevent( "hardpoint_kill", attacker, undefined, sweapon );
				self recordkillmodifier( "defending" );
				scoreeventprocessed = 1;
			}
			else 
			{
				if ( !medalgiven )
				{
					if ( isDefined( attacker.pers[ "defends" ] ) )
					{
						attacker.pers[ "defends" ]++;
						attacker.defends = attacker.pers[ "defends" ];
					}
					attacker maps/mp/_medals::defenseglobalcount();
					medalgiven = 1;
					attacker addplayerstatwithgametype( "DEFENDS", 1 );
					attacker recordgameevent( "return" );
				}
				attacker maps/mp/_challenges::killedzoneattacker( sweapon );
				maps/mp/_scoreevents::processscoreevent( "hardpoint_kill", attacker, undefined, sweapon );
				self recordkillmodifier( "assaulting" );
				scoreeventprocessed = 1;
			}
		}
	}
	if ( attacker.touchtriggers.size || level.capturetime == 0 && attacker istouching( level.zone.trig ) )
	{
		if ( level.capturetime > 0 )
		{
			triggerids = getarraykeys( attacker.touchtriggers );
			ownerteam = attacker.touchtriggers[ triggerids[ 0 ] ].useobj.ownerteam;
		}
		if ( ownerteam != "neutral" )
		{
			team = attacker.pers[ "team" ];
			if ( team == ownerteam )
			{
				if ( !medalgiven )
				{
					if ( isDefined( attacker.pers[ "defends" ] ) )
					{
						attacker.pers[ "defends" ]++;
						attacker.defends = attacker.pers[ "defends" ];
					}
					attacker maps/mp/_medals::defenseglobalcount();
					medalgiven = 1;
					attacker addplayerstatwithgametype( "DEFENDS", 1 );
					attacker recordgameevent( "return" );
				}
				if ( scoreeventprocessed == 0 )
				{
					attacker maps/mp/_challenges::killedzoneattacker( sweapon );
					maps/mp/_scoreevents::processscoreevent( "hardpoint_kill", attacker, undefined, sweapon );
					self recordkillmodifier( "assaulting" );
				}
			}
			else 
			{
				if ( !medalgiven )
				{
					attacker maps/mp/_medals::offenseglobalcount();
					medalgiven = 1;
					attacker addplayerstatwithgametype( "OFFENDS", 1 );
				}
				if ( scoreeventprocessed == 0 )
				{
					maps/mp/_scoreevents::processscoreevent( "hardpoint_kill", attacker, undefined, sweapon );
					self recordkillmodifier( "defending" );
				}
			}
		}
	}
	if ( medalgiven == 1 )
	{
		if ( level.zone.gameobject.iscontested == 1 )
		{
			attacker thread killwhilecontesting();
		}
	}
}

killwhilecontesting() //checked changed to match cerberus output
{
	self notify( "killWhileContesting" );
	self endon( "killWhileContesting" );
	self endon( "disconnect" );
	killtime = getTime();
	playerteam = self.pers[ "team" ];
	if ( !isDefined( self.clearenemycount ) )
	{
		self.clearenemycount = 0;
	}
	self.clearenemycount++;
	zonereturn = level waittill_any_return( "zone_captured" + playerteam, "zone_destroyed", "zone_captured", "death" );
	if ( zonereturn != "zone_destroyed" || zonereturn == "death" || playerteam != self.pers[ "team" ] )
	{
		self.clearenemycount = 0;
		return;
	}
	if ( self.clearenemycount >= 2 && ( killtime + 200 ) > getTime() )
	{
		maps/mp/_scoreevents::processscoreevent( "clear_2_attackers", self );
	}
	self.clearenemycount = 0;
}

onendgame( winningteam ) //checked changed to match cerberus output
{
	for ( i = 0; i < level.zones.size; i++ )
	{
		level.zones[ i ].gameobject maps/mp/gametypes/_gameobjects::allowuse( "none" );
	}
}

createzonespawninfluencer() //checked matches cerberus output
{
	koth_objective_influencer_score = level.spawnsystem.koth_objective_influencer_score;
	koth_objective_influencer_score_curve = level.spawnsystem.koth_objective_influencer_score_curve;
	koth_objective_influencer_radius = level.spawnsystem.koth_objective_influencer_radius;
	koth_objective_influencer_inner_score = level.spawnsystem.koth_objective_influencer_inner_score;
	koth_objective_influencer_inner_score_curve = level.spawnsystem.koth_objective_influencer_inner_score_curve;
	koth_objective_influencer_inner_radius = level.spawnsystem.koth_objective_influencer_inner_radius;
	self.spawn_influencer = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.gameobject.curorigin, koth_objective_influencer_radius, koth_objective_influencer_score, 0, "koth_objective,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( koth_objective_influencer_score_curve ) );
	self.spawn_influencer_inner = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.gameobject.curorigin, koth_objective_influencer_inner_radius, koth_objective_influencer_inner_score, 0, "koth_objective,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( koth_objective_influencer_inner_score_curve ) );
	self enable_zone_spawn_influencer( 0 );
}

enable_zone_spawn_influencer( enabled ) //checked matches cerberus output
{
	if ( isDefined( self.spawn_influencer ) )
	{
		enableinfluencer( self.spawn_influencer, enabled );
		enableinfluencer( self.spawn_influencer_inner, enabled );
	}
}

koth_gamemodespawndvars( reset_dvars ) //checked matches cerberus output
{
	ss = level.spawnsystem;
	ss.koth_objective_influencer_score = set_dvar_float_if_unset( "scr_spawn_koth_objective_influencer_score", "200", reset_dvars );
	ss.koth_objective_influencer_score_curve = set_dvar_if_unset( "scr_spawn_koth_objective_influencer_score_curve", "linear", reset_dvars );
	ss.koth_objective_influencer_radius = set_dvar_float_if_unset( "scr_spawn_koth_objective_influencer_radius", "" + 4000, reset_dvars );
	ss.koth_objective_influencer_inner_score = -800;
	ss.koth_objective_influencer_inner_score_curve = "constant";
	ss.koth_objective_influencer_inner_radius = 1000;
	ss.koth_initial_spawns_influencer_score = set_dvar_float_if_unset( "scr_spawn_koth_initial_spawns_influencer_score", "200", reset_dvars );
	ss.koth_initial_spawns_influencer_score_curve = set_dvar_if_unset( "scr_spawn_koth_initial_spawns_influencer_score_curve", "linear", reset_dvars );
	ss.koth_initial_spawns_influencer_radius = set_dvar_float_if_unset( "scr_spawn_koth_initial_spawns_influencer_radius", "" + ( 10 * get_player_height() ), reset_dvars );
}

updatecapsperminute( lastownerteam ) //checked matches cerberus output
{
	if ( !isDefined( self.capsperminute ) )
	{
		self.numcaps = 0;
		self.capsperminute = 0;
	}
	if ( !isDefined( lastownerteam ) || lastownerteam == "neutral" )
	{
		return;
	}
	self.numcaps++;
	minutespassed = maps/mp/gametypes/_globallogic_utils::gettimepassed() / 60000;
	if ( isplayer( self ) && isDefined( self.timeplayed[ "total" ] ) )
	{
		minutespassed = self.timeplayed[ "total" ] / 60;
	}
	self.capsperminute = self.numcaps / minutespassed;
	if ( self.capsperminute > self.numcaps )
	{
		self.capsperminute = self.numcaps;
	}
}

isscoreboosting( player ) //checked matches cerberus output
{
	if ( !level.rankedmatch )
	{
		return 0;
	}
	if ( player.capsperminute > level.playercapturelpm )
	{
		return 1;
	}
	return 0;
}


