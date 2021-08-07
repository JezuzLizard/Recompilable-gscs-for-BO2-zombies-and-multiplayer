#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_globallogic_defaults;
#include maps/mp/_challenges;
#include maps/mp/_demo;
#include maps/mp/_scoreevents;
#include maps/mp/_popups;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/teams/_teams;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_callbacksetup;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

main() //checked matches cerberus output
{
	if ( getDvar( "mapname" ) == "mp_background" )
	{
		return;
	}
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	registertimelimit( 0, 1440 );
	registerroundlimit( 0, 10 );
	registerroundwinlimit( 0, 10 );
	registerroundswitch( 0, 9 );
	registernumlives( 0, 100 );
	registerscorelimit( 0, 5000 );
	level.scoreroundbased = getgametypesetting( "roundscorecarry" ) == 0;
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	if ( getDvar( "scr_ctf_spawnPointFacingAngle" ) == "" )
	{
		setdvar( "scr_ctf_spawnPointFacingAngle", "0" );
	}
	level.teambased = 1;
	level.overrideteamscore = 1;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onprecachegametype = ::onprecachegametype;
	level.onplayerkilled = ::onplayerkilled;
	level.onroundswitch = ::onroundswitch;
	level.onendgame = ::onendgame;
	level.onroundendgame = ::onroundendgame;
	level.gamemodespawndvars = ::ctf_gamemodespawndvars;
	level.getteamkillpenalty = ::ctf_getteamkillpenalty;
	level.getteamkillscore = ::ctf_getteamkillscore;
	level.setmatchscorehudelemforteam = ::setmatchscorehudelemforteam;
	level.shouldplayovertimeround = ::shouldplayovertimeround;
	if ( !isDefined( game[ "ctf_teamscore" ] ) )
	{
		game[ "ctf_teamscore" ][ "allies" ] = 0;
		game[ "ctf_teamscore" ][ "axis" ] = 0;
	}
	game[ "dialog" ][ "gametype" ] = "ctf_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hcctf_start";
	game[ "dialog" ][ "wetake_flag" ] = "ctf_wetake";
	game[ "dialog" ][ "theytake_flag" ] = "ctf_theytake";
	game[ "dialog" ][ "theydrop_flag" ] = "ctf_theydrop";
	game[ "dialog" ][ "wedrop_flag" ] = "ctf_wedrop";
	game[ "dialog" ][ "wereturn_flag" ] = "ctf_wereturn";
	game[ "dialog" ][ "theyreturn_flag" ] = "ctf_theyreturn";
	game[ "dialog" ][ "theycap_flag" ] = "ctf_theycap";
	game[ "dialog" ][ "wecap_flag" ] = "ctf_wecap";
	game[ "dialog" ][ "offense_obj" ] = "cap_start";
	game[ "dialog" ][ "defense_obj" ] = "cap_start";
	level.lastdialogtime = getTime();
	level thread ctf_icon_hide();
	if ( !sessionmodeissystemlink() && !sessionmodeisonlinegame() && issplitscreen() )
	{
		setscoreboardcolumns( "score", "kills", "captures", "returns", "deaths" );
	}
	else
	{
		setscoreboardcolumns( "score", "kills", "deaths", "captures", "returns" );
	}
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "ctf_flag", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "ctf_flag_enemy", 0 );
}

onprecachegametype() //checked matches cerberus output
{
	game[ "flag_dropped_sound" ] = "mp_war_objective_lost";
	game[ "flag_recovered_sound" ] = "mp_war_objective_taken";
	precachemodel( maps/mp/teams/_teams::getteamflagmodel( "allies" ) );
	precachemodel( maps/mp/teams/_teams::getteamflagmodel( "axis" ) );
	precachemodel( maps/mp/teams/_teams::getteamflagcarrymodel( "allies" ) );
	precachemodel( maps/mp/teams/_teams::getteamflagcarrymodel( "axis" ) );
	precacheshader( maps/mp/teams/_teams::getteamflagicon( "allies" ) );
	precacheshader( maps/mp/teams/_teams::getteamflagicon( "axis" ) );
	precachestring( &"MP_FLAG_TAKEN_BY" );
	precachestring( &"MP_ENEMY_FLAG_TAKEN" );
	precachestring( &"MP_FRIENDLY_FLAG_TAKEN" );
	precachestring( &"MP_FLAG_CAPTURED_BY" );
	precachestring( &"MP_ENEMY_FLAG_CAPTURED_BY" );
	precachestring( &"MP_FLAG_RETURNED_BY" );
	precachestring( &"MP_FLAG_RETURNED" );
	precachestring( &"MP_ENEMY_FLAG_RETURNED" );
	precachestring( &"MP_FRIENDLY_FLAG_RETURNED" );
	precachestring( &"MP_YOUR_FLAG_RETURNING_IN" );
	precachestring( &"MP_ENEMY_FLAG_RETURNING_IN" );
	precachestring( &"MP_FRIENDLY_FLAG_DROPPED_BY" );
	precachestring( &"MP_FRIENDLY_FLAG_DROPPED" );
	precachestring( &"MP_ENEMY_FLAG_DROPPED" );
	precachestring( &"MP_SUDDEN_DEATH" );
	precachestring( &"MP_CAP_LIMIT_REACHED" );
	precachestring( &"MP_CTF_CANT_CAPTURE_FLAG" );
	precachestring( &"MP_CTF_OVERTIME_WIN" );
	precachestring( &"MP_CTF_OVERTIME_ROUND_1" );
	precachestring( &"MP_CTF_OVERTIME_ROUND_2_WINNER" );
	precachestring( &"MP_CTF_OVERTIME_ROUND_2_LOSER" );
	precachestring( &"MP_CTF_OVERTIME_ROUND_2_TIE" );
	precachestring( &"MPUI_CTF_OVERTIME_FASTEST_CAP_TIME" );
	precachestring( &"MPUI_CTF_OVERTIME_DEFEAT_TIMELIMIT" );
	precachestring( &"MPUI_CTF_OVERTIME_DEFEAT_DID_NOT_DEFEND" );
	precachestring( &"allies_base" );
	precachestring( &"axis_base" );
	precachestring( &"allies_flag" );
	precachestring( &"axis_flag" );
	game[ "strings" ][ "score_limit_reached" ] = &"MP_CAP_LIMIT_REACHED";
}

onstartgametype() //checked changed to match cerberus output
{
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	/*
/#
	setdebugsideswitch( game[ "switchedsides" ] );
#/
	*/
	setclientnamemode( "auto_change" );
	maps/mp/gametypes/_globallogic_score::resetteamscores();
	setobjectivetext( "allies", &"OBJECTIVES_CTF" );
	setobjectivetext( "axis", &"OBJECTIVES_CTF" );
	if ( level.splitscreen )
	{
		setobjectivescoretext( "allies", &"OBJECTIVES_CTF" );
		setobjectivescoretext( "axis", &"OBJECTIVES_CTF" );
	}
	else
	{
		setobjectivescoretext( "allies", &"OBJECTIVES_CTF_SCORE" );
		setobjectivescoretext( "axis", &"OBJECTIVES_CTF_SCORE" );
	}
	setobjectivehinttext( "allies", &"OBJECTIVES_CTF_HINT" );
	setobjectivehinttext( "axis", &"OBJECTIVES_CTF_HINT" );
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		[[ level._setteamscore ]]( "allies", 0 );
		[[ level._setteamscore ]]( "axis", 0 );
		registerscorelimit( 1, 1 );
		if ( isDefined( game[ "ctf_overtime_time_to_beat" ] ) )
		{
			registertimelimit( game[ "ctf_overtime_time_to_beat" ] / 60000, game[ "ctf_overtime_time_to_beat" ] / 60000 );
		}
		if ( game[ "overtime_round" ] == 1 )
		{
			setobjectivehinttext( "allies", &"MP_CTF_OVERTIME_ROUND_1" );
			setobjectivehinttext( "axis", &"MP_CTF_OVERTIME_ROUND_1" );
		}
		else if ( isDefined( game[ "ctf_overtime_first_winner" ] ) )
		{
			setobjectivehinttext( game[ "ctf_overtime_first_winner" ], &"MP_CTF_OVERTIME_ROUND_2_WINNER" );
			setobjectivehinttext( getotherteam( game[ "ctf_overtime_first_winner" ] ), &"MP_CTF_OVERTIME_ROUND_2_LOSER" );
		}
		else
		{
			setobjectivehinttext( "allies", &"MP_CTF_OVERTIME_ROUND_2_TIE" );
			setobjectivehinttext( "axis", &"MP_CTF_OVERTIME_ROUND_2_TIE" );
		}
	}
	allowed = [];
	allowed[ 0 ] = "ctf";
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 0, 0, -1 );
	level.spawnmaxs = ( 0, 0, -1 );
	maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_ctf_spawn_allies_start" );
	maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_ctf_spawn_axis_start" );
	maps/mp/gametypes/_spawnlogic::addspawnpoints( "allies", "mp_ctf_spawn_allies" );
	maps/mp/gametypes/_spawnlogic::addspawnpoints( "axis", "mp_ctf_spawn_axis" );
	maps/mp/gametypes/_spawning::updateallspawnpoints();
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.spawn_axis = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_ctf_spawn_axis" );
	level.spawn_allies = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_ctf_spawn_allies" );
	level.spawn_start = [];
	foreach ( team in level.teams )
	{
		level.spawn_start[ team ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_ctf_spawn_" + team + "_start" );
	}
	thread updategametypedvars();
	thread ctf();
}

shouldplayovertimeround() //checked matches cerberus output
{
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		if ( game[ "overtime_round" ] == 1 || !level.gameended )
		{
			return 1;
		}
		return 0;
	}
	if ( level.roundscorecarry )
	{
		if ( game[ "teamScores" ][ "allies" ] == game[ "teamScores" ][ "axis" ] || hitroundlimit() && game[ "teamScores" ][ "allies" ] == ( level.scorelimit - 1 ) )
		{
			return 1;
		}
	}
	else
	{
		alliesroundswon = getroundswon( "allies" );
		axisroundswon = getroundswon( "axis" );
		if ( level.roundwinlimit > 0 && axisroundswon == ( level.roundwinlimit - 1 ) && alliesroundswon == ( level.roundwinlimit - 1 ) )
		{
			return 1;
		}
		if ( hitroundlimit() && alliesroundswon == axisroundswon )
		{
			return 1;
		}
	}
	return 0;
}

minutesandsecondsstring( milliseconds ) //checked matches cerberus output
{
	minutes = floor( milliseconds / 60000 );
	milliseconds -= minutes * 60000;
	seconds = floor( milliseconds / 1000 );
	if ( seconds < 10 )
	{
		return ( minutes + ":0" ) + seconds;
	}
	else
	{
		return ( minutes + ":" ) + seconds;
	}
}

setmatchscorehudelemforteam( team ) //checked changed to match cerberus output
{
	if ( !isDefined( game[ "overtime_round" ] ) )
	{
		self maps/mp/gametypes/_hud_message::setmatchscorehudelemforteam( team );
	}
	else if ( isDefined( game[ "ctf_overtime_second_winner" ] ) && game[ "ctf_overtime_second_winner" ] == team )
	{
		self settext( minutesandsecondsstring( game[ "ctf_overtime_best_time" ] ) );
	}
	else if ( isDefined( game[ "ctf_overtime_first_winner" ] ) && game[ "ctf_overtime_first_winner" ] == team )
	{
		self settext( minutesandsecondsstring( game[ "ctf_overtime_time_to_beat" ] ) );
		return;
	}
	else
	{
		self settext( &"" );
	}
}

onroundswitch() //checked matches cerberus output
{
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	level.halftimetype = "halftime";
	game[ "switchedsides" ] = !game[ "switchedsides" ];
}

onendgame( winningteam ) //checked changed to match cerberus output
{
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		if ( game[ "overtime_round" ] == 1 )
		{
			if ( isDefined( winningteam ) && winningteam != "tie" )
			{
				game[ "ctf_overtime_first_winner" ] = winningteam;
				game[ "ctf_overtime_time_to_beat" ] = maps/mp/gametypes/_globallogic_utils::gettimepassed();
			}
		}
		else
		{
			game[ "ctf_overtime_second_winner" ] = winningteam;
			game[ "ctf_overtime_best_time" ] = maps/mp/gametypes/_globallogic_utils::gettimepassed();
		}
	}
}

onroundendgame( winningteam ) //checked changed to match cerberus output
{
	if ( isDefined( game[ "overtime_round" ] ) )
	{
		if ( isDefined( game[ "ctf_overtime_first_winner" ] ) )
		{
			if ( !isDefined( winningteam ) || winningteam == "tie" )
			{
				winningteam = game[ "ctf_overtime_first_winner" ];
			}
			if ( game[ "ctf_overtime_first_winner" ] == winningteam )
			{
				level.endvictoryreasontext = &"MPUI_CTF_OVERTIME_FASTEST_CAP_TIME";
				level.enddefeatreasontext = &"MPUI_CTF_OVERTIME_DEFEAT_TIMELIMIT";
			}
			else
			{
				level.endvictoryreasontext = &"MPUI_CTF_OVERTIME_FASTEST_CAP_TIME";
				level.enddefeatreasontext = &"MPUI_CTF_OVERTIME_DEFEAT_DID_NOT_DEFEND";
			}
		}
		else if ( !isDefined( winningteam ) || winningteam == "tie" )
		{
			return "tie";
		}
		return winningteam;
	}
	if ( level.roundscorecarry == 0 )
	{
		foreach ( team in level.teams )
		{
			[[ level._setteamscore ]]( team, game[ "roundswon" ][ team ] );
		}
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "roundswon" );
	}
	else
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbyteamscore();
	}
	return winner;
}

onspawnplayerunified() //checked matches cerberus output
{
	self.isflagcarrier = 0;
	self.flagcarried = undefined;
	self clearclientflag( 0 );
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn ) //checked matches cerberus output
{
	self.isflagcarrier = 0;
	self.flagcarried = undefined;
	self clearclientflag( 0 );
	spawnteam = self.pers[ "team" ];
	if ( game[ "switchedsides" ] )
	{
		spawnteam = getotherteam( spawnteam );
	}
	if ( level.usestartspawns )
	{
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( level.spawn_start[ spawnteam ] );
	}
	else if ( spawnteam == "axis" )
	{
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_axis );
	}
	else
	{
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_allies );
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
		self spawn( spawnpoint.origin, spawnpoint.angles, "ctf" );
	}
}

updategametypedvars() //checked matches cerberus output
{
	level.flagcapturetime = getgametypesetting( "captureTime" );
	level.flagtouchreturntime = getgametypesetting( "defuseTime" );
	level.idleflagreturntime = getgametypesetting( "idleFlagResetTime" );
	level.flagrespawntime = getgametypesetting( "flagRespawnTime" );
	level.enemycarriervisible = getgametypesetting( "enemyCarrierVisible" );
	level.roundlimit = getgametypesetting( "roundLimit" );
	level.roundscorecarry = getgametypesetting( "roundscorecarry" );
	level.teamkillpenaltymultiplier = getgametypesetting( "teamKillPenalty" );
	level.teamkillscoremultiplier = getgametypesetting( "teamKillScore" );
	if ( level.flagtouchreturntime >= 0 && level.flagtouchreturntime != 63 )
	{
		level.touchreturn = 1;
	}
	else
	{
		level.touchreturn = 0;
	}
}

createflag( trigger ) //checked matches cerberus output
{
	visuals = [];
	if ( isDefined( trigger.target ) )
	{
		visuals[ 0 ] = getent( trigger.target, "targetname" );
	}
	else
	{
		visuals[ 0 ] = spawn( "script_model", trigger.origin );
		visuals[ 0 ].angles = trigger.angles;
	}
	entityteam = trigger.script_team;
	if ( game[ "switchedsides" ] )
	{
		entityteam = getotherteam( entityteam );
	}
	visuals[ 0 ] setmodel( maps/mp/teams/_teams::getteamflagmodel( entityteam ) );
	visuals[ 0 ] setteam( entityteam );
	flag = maps/mp/gametypes/_gameobjects::createcarryobject( entityteam, trigger, visuals, vectorScale( ( 0, 0, -1 ), 100 ), istring( entityteam + "_flag" ) );
	flag maps/mp/gametypes/_gameobjects::setteamusetime( "friendly", level.flagtouchreturntime );
	flag maps/mp/gametypes/_gameobjects::setteamusetime( "enemy", level.flagcapturetime );
	flag maps/mp/gametypes/_gameobjects::allowcarry( "enemy" );
	flag maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
	flag maps/mp/gametypes/_gameobjects::setvisiblecarriermodel( maps/mp/teams/_teams::getteamflagcarrymodel( entityteam ) );
	flag maps/mp/gametypes/_gameobjects::set2dicon( "friendly", level.icondefend2d );
	flag maps/mp/gametypes/_gameobjects::set3dicon( "friendly", level.icondefend3d );
	flag maps/mp/gametypes/_gameobjects::set2dicon( "enemy", level.iconcapture2d );
	flag maps/mp/gametypes/_gameobjects::set3dicon( "enemy", level.iconcapture3d );
	flag maps/mp/gametypes/_gameobjects::setcarryicon( maps/mp/teams/_teams::getteamflagicon( entityteam ) );
	if ( level.enemycarriervisible == 2 )
	{
		flag.objidpingfriendly = 1;
	}
	flag.allowweapons = 1;
	flag.onpickup = ::onpickup;
	flag.onpickupfailed = ::onpickup;
	flag.ondrop = ::ondrop;
	flag.onreset = ::onreset;
	if ( level.idleflagreturntime > 0 )
	{
		flag.autoresettime = level.idleflagreturntime;
	}
	else
	{
		flag.autoresettime = undefined;
	}
	return flag;
}

createflagzone( trigger ) //checked changed to match cerberus output
{
	visuals = [];
	entityteam = trigger.script_team;
	if ( game[ "switchedsides" ] )
	{
		entityteam = getotherteam( entityteam );
	}
	flagzone = maps/mp/gametypes/_gameobjects::createuseobject( entityteam, trigger, visuals, ( 0, 0, 0 ), istring( entityteam + "_base" ) );
	flagzone maps/mp/gametypes/_gameobjects::allowuse( "friendly" );
	flagzone maps/mp/gametypes/_gameobjects::setusetime( 0 );
	flagzone maps/mp/gametypes/_gameobjects::setusetext( &"MP_CAPTURING_FLAG" );
	flagzone maps/mp/gametypes/_gameobjects::setvisibleteam( "friendly" );
	enemyteam = getotherteam( entityteam );
	flagzone maps/mp/gametypes/_gameobjects::setkeyobject( level.teamflags[ enemyteam ] );
	flagzone.onuse = ::oncapture;
	flag = level.teamflags[ entityteam ];
	flag.flagbase = flagzone;
	flagzone.flag = flag;
	tracestart = trigger.origin + vectorScale( ( 0, 0, 1 ), 32 );
	traceend = trigger.origin + vectorScale( ( 0, 0, -1 ), 32 );
	trace = bullettrace( tracestart, traceend, 0, undefined );
	upangles = vectorToAngles( trace[ "normal" ] );
	flagzone.baseeffectforward = anglesToForward( upangles );
	flagzone.baseeffectright = anglesToRight( upangles );
	flagzone.baseeffectpos = trace[ "position" ];
	flagzone thread resetflagbaseeffect();
	flagzone createflagspawninfluencer( entityteam );
	return flagzone;
}

createflaghint( team, origin ) //checked matches cerberus output
{
	radius = 128;
	height = 64;
	trigger = spawn( "trigger_radius", origin, 0, radius, height );
	trigger sethintstring( &"MP_CTF_CANT_CAPTURE_FLAG" );
	trigger setcursorhint( "HINT_NOICON" );
	trigger.original_origin = origin;
	trigger turn_off();
	return trigger;
}

ctf() //checked changed to match cerberus output
{
	level.flags = [];
	level.teamflags = [];
	level.flagzones = [];
	level.teamflagzones = [];
	level.iconcapture3d = "waypoint_grab_red";
	level.iconcapture2d = "waypoint_grab_red";
	level.icondefend3d = "waypoint_defend_flag";
	level.icondefend2d = "waypoint_defend_flag";
	level.icondropped3d = "waypoint_defend_flag";
	level.icondropped2d = "waypoint_defend_flag";
	level.iconreturn3d = "waypoint_return_flag";
	level.iconreturn2d = "waypoint_return_flag";
	level.iconbase3d = "waypoint_defend_flag";
	level.iconescort3d = "waypoint_escort";
	level.iconescort2d = "waypoint_escort";
	level.iconkill3d = "waypoint_kill";
	level.iconkill2d = "waypoint_kill";
	level.iconwaitforflag3d = "waypoint_waitfor_flag";
	precacheshader( level.iconcapture3d );
	precacheshader( level.iconcapture2d );
	precacheshader( level.icondefend3d );
	precacheshader( level.icondefend2d );
	precacheshader( level.icondropped3d );
	precacheshader( level.icondropped2d );
	precacheshader( level.iconbase3d );
	precacheshader( level.iconreturn3d );
	precacheshader( level.iconreturn2d );
	precacheshader( level.iconescort3d );
	precacheshader( level.iconescort2d );
	precacheshader( level.iconkill3d );
	precacheshader( level.iconkill2d );
	precacheshader( level.iconwaitforflag3d );
	level.flagbasefxid = [];
	level.flagbasefxid[ "allies" ] = loadfx( "misc/fx_ui_flagbase_" + game[ "allies" ] );
	level.flagbasefxid[ "axis" ] = loadfx( "misc/fx_ui_flagbase_" + game[ "axis" ] );
	flag_triggers = getentarray( "ctf_flag_pickup_trig", "targetname" );
	if ( !isDefined( flag_triggers ) || flag_triggers.size != 2 )
	{
		/*
/#
		maps/mp/_utility::error( "Not enough ctf_flag_pickup_trig triggers found in map.  Need two." );
#/
		*/
		return;
	}
	for ( index = 0; index < flag_triggers.size; index++ )
	{
		trigger = flag_triggers[ index ];
		flag = createflag( trigger );
		team = flag maps/mp/gametypes/_gameobjects::getownerteam();
		level.flags[ level.flags.size ] = flag;
		level.teamflags[ team ] = flag;
	}
	flag_zones = getentarray( "ctf_flag_zone_trig", "targetname" );
	if ( !isDefined( flag_zones ) || flag_zones.size != 2 )
	{
		/*
/#
		maps/mp/_utility::error( "Not enough ctf_flag_zone_trig triggers found in map.  Need two." );
#/
		*/
		return;
	}
	for ( index = 0; index < flag_zones.size; index++ )
	{
		trigger = flag_zones[ index ];
		flagzone = createflagzone( trigger );
		team = flagzone maps/mp/gametypes/_gameobjects::getownerteam();
		level.flagzones[ level.flagzones.size ] = flagzone;
		level.teamflagzones[ team ] = flagzone;
		level.flaghints[ team ] = createflaghint( team, trigger.origin );
		facing_angle = getDvarInt( "scr_ctf_spawnPointFacingAngle" );
		setspawnpointsbaseweight( getotherteamsmask( team ), trigger.origin, facing_angle, level.spawnsystem.objective_facing_bonus );
	}
	createreturnmessageelems();
}

ctf_icon_hide() //checked matches cerberus output
{
	level waittill( "game_ended" );
	level.teamflags[ "allies" ] maps/mp/gametypes/_gameobjects::setvisibleteam( "none" );
	level.teamflags[ "axis" ] maps/mp/gametypes/_gameobjects::setvisibleteam( "none" );
}

removeinfluencers() //checked matches cerberus output
{
	if ( isDefined( self.spawn_influencer_enemy_carrier ) )
	{
		removeinfluencer( self.spawn_influencer_enemy_carrier );
		self.spawn_influencer_enemy_carrier = undefined;
	}
	if ( isDefined( self.spawn_influencer_friendly_carrier ) )
	{
		removeinfluencer( self.spawn_influencer_friendly_carrier );
		self.spawn_influencer_friendly_carrier = undefined;
	}
	if ( isDefined( self.spawn_influencer_dropped ) )
	{
		removeinfluencer( self.spawn_influencer_dropped );
		self.spawn_influencer_dropped = undefined;
	}
}

ondrop( player ) //checked matches cerberus output
{
	if ( isDefined( player ) )
	{
		player clearclientflag( 0 );
	}
	team = self maps/mp/gametypes/_gameobjects::getownerteam();
	otherteam = getotherteam( team );
	bbprint( "mpobjective", "gametime %d objtype %s team %s", getTime(), "ctf_flagdropped", team );
	self.visuals[ 0 ] setclientflag( 6 );
	if ( level.touchreturn )
	{
		self maps/mp/gametypes/_gameobjects::allowcarry( "any" );
		level.flaghints[ otherteam ] turn_off();
	}
	if ( isDefined( player ) )
	{
		printandsoundoneveryone( team, undefined, &"", undefined, "mp_war_objective_lost" );
		level thread maps/mp/_popups::displayteammessagetoteam( &"MP_FRIENDLY_FLAG_DROPPED", player, team );
		level thread maps/mp/_popups::displayteammessagetoteam( &"MP_ENEMY_FLAG_DROPPED", player, otherteam );
	}
	else
	{
		printandsoundoneveryone( team, undefined, &"", undefined, "mp_war_objective_lost" );
	}
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "wedrop_flag", otherteam, "ctf_flag" );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "theydrop_flag", team, "ctf_flag_enemy" );
	if ( isDefined( player ) )
	{
		player logstring( team + " flag dropped" );
	}
	else
	{
		logstring( team + " flag dropped" );
	}
	if ( isDefined( player ) )
	{
		player playlocalsound( "mpl_flag_drop_plr" );
	}
	maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagdrop_sting_friend", otherteam );
	maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagdrop_sting_enemy", team );
	if ( level.touchreturn )
	{
		self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", level.iconreturn3d );
		self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", level.iconreturn2d );
	}
	else
	{
		self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", level.icondropped3d );
		self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", level.icondropped2d );
	}
	self maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
	self maps/mp/gametypes/_gameobjects::set3dicon( "enemy", level.iconcapture3d );
	self maps/mp/gametypes/_gameobjects::set2dicon( "enemy", level.iconcapture2d );
	thread maps/mp/_utility::playsoundonplayers( game[ "flag_dropped_sound" ], game[ "attackers" ] );
	self thread returnflagaftertimemsg( level.idleflagreturntime );
	if ( isDefined( player ) )
	{
		self removeinfluencers();
	}
	else
	{
		self.spawn_influencer_friendly_carrier = undefined;
		self.spawn_influencer_enemy_carrier = undefined;
	}
	ss = level.spawnsystem;
	player_team_mask = getteammask( otherteam );
	enemy_team_mask = getteammask( team );
	if ( isDefined( player ) )
	{
		flag_origin = player.origin;
	}
	else
	{
		flag_origin = self.curorigin;
	}
	self.spawn_influencer_dropped = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, flag_origin, ss.ctf_dropped_influencer_radius, ss.ctf_dropped_influencer_score, player_team_mask | enemy_team_mask, "ctf_flag_dropped,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ss.ctf_dropped_influencer_score_curve ), level.idleflagreturntime, self.trigger );
}

onpickup( player ) //checked matches cerberus output
{
	carrierkilledby = self.carrierkilledby;
	self.carrierkilledby = undefined;
	if ( isDefined( self.spawn_influencer_dropped ) )
	{
		removeinfluencer( self.spawn_influencer_dropped );
		self.spawn_influencer_dropped = undefined;
	}
	player addplayerstatwithgametype( "PICKUPS", 1 );
	if ( level.touchreturn )
	{
		self maps/mp/gametypes/_gameobjects::allowcarry( "enemy" );
	}
	self removeinfluencers();
	team = self maps/mp/gametypes/_gameobjects::getownerteam();
	otherteam = getotherteam( team );
	self clearreturnflaghudelems();
	if ( isDefined( player ) && player.pers[ "team" ] == team )
	{
		self notify( "picked_up" );
		printandsoundoneveryone( team, undefined, &"", undefined, "mp_obj_returned" );
		if ( isDefined( player.pers[ "returns" ] ) )
		{
			player.pers[ "returns" ]++;
			player.returns = player.pers[ "returns" ];
		}
		if ( isDefined( carrierkilledby ) && carrierkilledby == player )
		{
			maps/mp/_scoreevents::processscoreevent( "flag_carrier_kill_return_close", player );
		}
		else
		{
			if ( distancesquared( self.trigger.baseorigin, player.origin ) > 90000 )
			{
				maps/mp/_scoreevents::processscoreevent( "flag_return", player );
			}
		}
		maps/mp/_demo::bookmark( "event", getTime(), player );
		player addplayerstatwithgametype( "RETURNS", 1 );
		level thread maps/mp/_popups::displayteammessagetoteam( &"MP_FRIENDLY_FLAG_RETURNED", player, team );
		level thread maps/mp/_popups::displayteammessagetoteam( &"MP_ENEMY_FLAG_RETURNED", player, otherteam );
		self.visuals[ 0 ] clearclientflag( 6 );
		self maps/mp/gametypes/_gameobjects::setflags( 0 );
		bbprint( "mpobjective", "gametime %d objtype %s team %s", getTime(), "ctf_flagreturn", team );
		player recordgameevent( "return" );
		self returnflag();
		self maps/mp/gametypes/_gameobjects::returnhome();
		if ( isDefined( player ) )
		{
			player logstring( team + " flag returned" );
		}
		else
		{
			logstring( team + " flag returned" );
		}
		return;
	}
	else
	{
		bbprint( "mpobjective", "gametime %d objtype %s team %s", getTime(), "ctf_flagpickup", team );
		player recordgameevent( "pickup" );
		maps/mp/_scoreevents::processscoreevent( "flag_grab", player );
		maps/mp/_demo::bookmark( "event", getTime(), player );
		printandsoundoneveryone( otherteam, undefined, &"", undefined, "mp_obj_taken", "mp_enemy_obj_taken" );
		level thread maps/mp/_popups::displayteammessagetoteam( &"MP_FRIENDLY_FLAG_TAKEN", player, team );
		level thread maps/mp/_popups::displayteammessagetoteam( &"MP_ENEMY_FLAG_TAKEN", player, otherteam );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "wetake_flag", otherteam, "ctf_flag" );
		maps/mp/gametypes/_globallogic_audio::leaderdialog( "theytake_flag", team, "ctf_flag_enemy" );
		player.isflagcarrier = 1;
		player.flagcarried = self;
		player playlocalsound( "mpl_flag_pickup_plr" );
		player setclientflag( 0 );
		self maps/mp/gametypes/_gameobjects::setflags( 1 );
		maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagget_sting_friend", otherteam );
		maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagget_sting_enemy", team );
		if ( level.enemycarriervisible )
		{
			self maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
		}
		else
		{
			self maps/mp/gametypes/_gameobjects::setvisibleteam( "enemy" );
		}
		self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", level.iconkill2d );
		self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", level.iconkill3d );
		self maps/mp/gametypes/_gameobjects::set2dicon( "enemy", level.iconescort2d );
		self maps/mp/gametypes/_gameobjects::set3dicon( "enemy", level.iconescort3d );
		player thread claim_trigger( level.flaghints[ otherteam ] );
		update_hints();
		player logstring( team + " flag taken" );
		ss = level.spawnsystem;
		player_team_mask = getteammask( otherteam );
		enemy_team_mask = getteammask( team );
		self.spawn_influencer_enemy_carrier = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, player.origin, ss.ctf_enemy_carrier_influencer_radius, ss.ctf_enemy_carrier_influencer_score, enemy_team_mask, "ctf_flag_enemy_carrier,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ss.ctf_enemy_carrier_influencer_score_curve ), 0, player );
		self.spawn_influencer_friendly_carrier = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, player.origin, ss.ctf_friendly_carrier_influencer_radius, ss.ctf_friendly_carrier_influencer_score, player_team_mask, "ctf_flag_friendly_carrier,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ss.ctf_friendly_carrier_influencer_score_curve ), 0, player );
	}
}

onpickupmusicstate( player ) //checked changed at own discretion
{
	self endon( "disconnect" );
	self endon( "death" );
	wait 6;
	if (player.isFlagCarrier)
	{
		//imported from bo1 ctf.gsc
		player thread maps\mp\gametypes\_globallogic_audio::set_music_on_player( "SUSPENSE", false, false);	
	}
}

ishome() //checked matches cerberus output
{
	if ( isDefined( self.carrier ) )
	{
		return 0;
	}
	if ( self.curorigin != self.trigger.baseorigin )
	{
		return 0;
	}
	return 1;
}

returnflag() //checked matches cerberus output
{
	team = self maps/mp/gametypes/_gameobjects::getownerteam();
	otherteam = getotherteam( team );
	maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagreturn_sting", team );
	maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagreturn_sting", otherteam );
	level.teamflagzones[ otherteam ] maps/mp/gametypes/_gameobjects::allowuse( "friendly" );
	level.teamflagzones[ otherteam ] maps/mp/gametypes/_gameobjects::setvisibleteam( "friendly" );
	update_hints();
	if ( level.touchreturn )
	{
		self maps/mp/gametypes/_gameobjects::allowcarry( "enemy" );
	}
	self maps/mp/gametypes/_gameobjects::returnhome();
	self maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", level.icondefend3d );
	self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", level.icondefend2d );
	self maps/mp/gametypes/_gameobjects::set3dicon( "enemy", level.iconcapture3d );
	self maps/mp/gametypes/_gameobjects::set2dicon( "enemy", level.iconcapture2d );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "wereturn_flag", team, "ctf_flag_enemy" );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "theyreturn_flag", otherteam, "ctf_flag" );
}

oncapture( player ) //checked matches cerberus output
{
	team = player.pers[ "team" ];
	enemyteam = getotherteam( team );
	time = getTime();
	playerteamsflag = level.teamflags[ team ];
	if ( playerteamsflag maps/mp/gametypes/_gameobjects::isobjectawayfromhome() )
	{
		return;
	}
	printandsoundoneveryone( team, undefined, &"", undefined, "mp_obj_captured", "mp_enemy_obj_captured" );
	bbprint( "mpobjective", "gametime %d objtype %s team %s", time, "ctf_flagcapture", enemyteam );
	game[ "challenge" ][ team ][ "capturedFlag" ] = 1;
	player maps/mp/_challenges::capturedobjective( time );
	if ( isDefined( player.pers[ "captures" ] ) )
	{
		player.pers[ "captures" ]++;
		player.captures = player.pers[ "captures" ];
	}
	maps/mp/_demo::bookmark( "event", getTime(), player );
	player addplayerstatwithgametype( "CAPTURES", 1 );
	level thread maps/mp/_popups::displayteammessagetoteam( &"MP_ENEMY_FLAG_CAPTURED", player, team );
	level thread maps/mp/_popups::displayteammessagetoteam( &"MP_FRIENDLY_FLAG_CAPTURED", player, enemyteam );
	maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagcapture_sting_enemy", enemyteam );
	maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagcapture_sting_friend", team );
	player giveflagcapturexp( player );
	player logstring( enemyteam + " flag captured" );
	flag = player.carryobject;
	flag.dontannouncereturn = 1;
	flag maps/mp/gametypes/_gameobjects::returnhome();
	flag.dontannouncereturn = undefined;
	otherteam = getotherteam( team );
	level.teamflags[ otherteam ] maps/mp/gametypes/_gameobjects::allowcarry( "enemy" );
	level.teamflags[ otherteam ] maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
	level.teamflags[ otherteam ] maps/mp/gametypes/_gameobjects::returnhome();
	level.teamflagzones[ otherteam ] maps/mp/gametypes/_gameobjects::allowuse( "friendly" );
	player.isflagcarrier = 0;
	player.flagcarried = undefined;
	player clearclientflag( 0 );
	maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( team, 1 );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "wecap_flag", team, "ctf_flag" );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "theycap_flag", enemyteam, "ctf_flag_enemy" );
	flag removeinfluencers();
}

giveflagcapturexp( player ) //checked matches cerberus output
{
	maps/mp/_scoreevents::processscoreevent( "flag_capture", player );
	player recordgameevent( "capture" );
}

onreset() //checked matches cerberus output
{
	update_hints();
	team = self maps/mp/gametypes/_gameobjects::getownerteam();
	self maps/mp/gametypes/_gameobjects::set3dicon( "friendly", level.icondefend3d );
	self maps/mp/gametypes/_gameobjects::set2dicon( "friendly", level.icondefend2d );
	self maps/mp/gametypes/_gameobjects::set3dicon( "enemy", level.iconcapture3d );
	self maps/mp/gametypes/_gameobjects::set2dicon( "enemy", level.iconcapture2d );
	if ( level.touchreturn )
	{
		self maps/mp/gametypes/_gameobjects::allowcarry( "enemy" );
	}
	level.teamflagzones[ team ] maps/mp/gametypes/_gameobjects::setvisibleteam( "friendly" );
	level.teamflagzones[ team ] maps/mp/gametypes/_gameobjects::allowuse( "friendly" );
	self.visuals[ 0 ] clearclientflag( 6 );
	self maps/mp/gametypes/_gameobjects::setflags( 0 );
	self clearreturnflaghudelems();
}

getotherflag( flag ) //checked matches cerberus output
{
	if ( flag == level.flags[ 0 ] )
	{
		return level.flags[ 1 ];
	}
	return level.flags[ 0 ];
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked changed to match cerberus output
{
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		for ( index = 0; index < level.flags.size; index++ )
		{
			flagteam = "invalidTeam";
			inflagzone = 0;
			defendedflag = 0;
			offendedflag = 0;
			flagcarrier = level.flags[ index ].carrier;
			if ( isDefined( flagcarrier ) )
			{
				flagorigin = level.flags[ index ].carrier.origin;
				iscarried = 1;
				if ( isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
				{
					if ( isDefined( level.flags[ index ].carrier.attackerdata ) )
					{
						if ( level.flags[ index ].carrier != attacker )
						{
							if ( isDefined( level.flags[ index ].carrier.attackerdata[ self.clientid ] ) )
							{
								maps/mp/_scoreevents::processscoreevent( "rescue_flag_carrier", attacker, undefined, sweapon );
							}
						}
					}
				}
			}
			else
			{
				flagorigin = level.flags[ index ].curorigin;
				iscarried = 0;
			}
			dist = distance2d( self.origin, flagorigin );
			if ( dist < level.defaultoffenseradius )
			{
				inflagzone = 1;
				if ( level.flags[ index ].ownerteam == attacker.pers[ "team" ] )
				{
					defendedflag = 1;
				}
				else
				{
					offendedflag = 1;
				}
			}
			dist = distance2d( attacker.origin, flagorigin );
			if ( dist < level.defaultoffenseradius )
			{
				inflagzone = 1;
				if ( level.flags[ index ].ownerteam == attacker.pers[ "team" ] )
				{
					defendedflag = 1;
				}
				else
				{
					offendedflag = 1;
				}
			}
			if ( inflagzone && isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
			{
				if ( defendedflag )
				{
					attacker addplayerstatwithgametype( "DEFENDS", 1 );
					if ( is_true( self.isflagcarrier ) )
					{
						maps/mp/_scoreevents::processscoreevent( "kill_flag_carrier", attacker, undefined, sweapon );
					}
					else
					{
						maps/mp/_scoreevents::processscoreevent( "killed_attacker", attacker, undefined, sweapon );
					}
					self recordkillmodifier( "assaulting" );
				}
				if ( offendedflag )
				{
					attacker addplayerstatwithgametype( "OFFENDS", 1 );
					if ( iscarried == 1 )
					{
						if ( isDefined( flagcarrier ) && attacker == flagcarrier )
						{
							maps/mp/_scoreevents::processscoreevent( "killed_enemy_while_carrying_flag", attacker, undefined, sweapon );
						}
						else
						{
							maps/mp/_scoreevents::processscoreevent( "defend_flag_carrier", attacker, undefined, sweapon );
						}
					}
					else
					{
						maps/mp/_scoreevents::processscoreevent( "killed_defender", attacker, undefined, sweapon );
					}
					self recordkillmodifier( "defending" );
				}
			}
		}
	}
	else if ( !isDefined( self.isflagcarrier ) || !self.isflagcarrier )
	{
		return;
	}
	if ( isDefined( attacker ) && isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
	{
		if ( isDefined( self.flagcarried ) )
		{
			for ( index = 0; index < level.flags.size; index++ )
			{
				currentflag = level.flags[ index ];
				if ( currentflag.ownerteam == self.team )
				{
					if ( currentflag.curorigin == currentflag.trigger.baseorigin )
					{
						dist = distance2d( self.origin, currentflag.curorigin );
						if ( dist < level.defaultoffenseradius )
						{
							self.flagcarried.carrierkilledby = attacker;
							break;
						}
					}
				}
			}
		}
		attacker recordgameevent( "kill_carrier" );
		self recordkillmodifier( "carrying" );
	}
}

createreturnmessageelems() //checked matches cerberus output
{
	level.returnmessageelems = [];
	level.returnmessageelems[ "allies" ][ "axis" ] = createservertimer( "objective", 1.4, "allies" );
	level.returnmessageelems[ "allies" ][ "axis" ] setpoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	level.returnmessageelems[ "allies" ][ "axis" ].label = &"MP_ENEMY_FLAG_RETURNING_IN";
	level.returnmessageelems[ "allies" ][ "axis" ].alpha = 0;
	level.returnmessageelems[ "allies" ][ "axis" ].archived = 0;
	level.returnmessageelems[ "allies" ][ "allies" ] = createservertimer( "objective", 1.4, "allies" );
	level.returnmessageelems[ "allies" ][ "allies" ] setpoint( "TOPRIGHT", "TOPRIGHT", 0, 20 );
	level.returnmessageelems[ "allies" ][ "allies" ].label = &"MP_YOUR_FLAG_RETURNING_IN";
	level.returnmessageelems[ "allies" ][ "allies" ].alpha = 0;
	level.returnmessageelems[ "allies" ][ "allies" ].archived = 0;
	level.returnmessageelems[ "axis" ][ "allies" ] = createservertimer( "objective", 1.4, "axis" );
	level.returnmessageelems[ "axis" ][ "allies" ] setpoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	level.returnmessageelems[ "axis" ][ "allies" ].label = &"MP_ENEMY_FLAG_RETURNING_IN";
	level.returnmessageelems[ "axis" ][ "allies" ].alpha = 0;
	level.returnmessageelems[ "axis" ][ "allies" ].archived = 0;
	level.returnmessageelems[ "axis" ][ "axis" ] = createservertimer( "objective", 1.4, "axis" );
	level.returnmessageelems[ "axis" ][ "axis" ] setpoint( "TOPRIGHT", "TOPRIGHT", 0, 20 );
	level.returnmessageelems[ "axis" ][ "axis" ].label = &"MP_YOUR_FLAG_RETURNING_IN";
	level.returnmessageelems[ "axis" ][ "axis" ].alpha = 0;
	level.returnmessageelems[ "axis" ][ "axis" ].archived = 0;
}

returnflagaftertimemsg( time ) //checked matches cerberus output
{
	if ( level.touchreturn || level.idleflagreturntime == 0 )
	{
		return;
	}
	self notify( "returnFlagAfterTimeMsg" );
	self endon( "returnFlagAfterTimeMsg" );
	result = returnflaghudelems( time );
	self removeinfluencers();
	self clearreturnflaghudelems();
	if ( !isDefined( result ) )
	{
		return;
	}
}

returnflaghudelems( time ) //checked matches cerberus output
{
	self endon( "picked_up" );
	level endon( "game_ended" );
	ownerteam = self maps/mp/gametypes/_gameobjects::getownerteam();
	/*
/#
	assert( !level.returnmessageelems[ "axis" ][ ownerteam ].alpha );
#/
	*/
	level.returnmessageelems[ "axis" ][ ownerteam ].alpha = 1;
	level.returnmessageelems[ "axis" ][ ownerteam ] settimer( time );
	/*
/#
	assert( !level.returnmessageelems[ "allies" ][ ownerteam ].alpha );
#/
	*/
	level.returnmessageelems[ "allies" ][ ownerteam ].alpha = 1;
	level.returnmessageelems[ "allies" ][ ownerteam ] settimer( time );
	if ( time <= 0 )
	{
		return 0;
	}
	else
	{
		wait time;
	}
	return 1;
}

clearreturnflaghudelems() //checked matches cerberus output
{
	ownerteam = self maps/mp/gametypes/_gameobjects::getownerteam();
	level.returnmessageelems[ "allies" ][ ownerteam ].alpha = 0;
	level.returnmessageelems[ "axis" ][ ownerteam ].alpha = 0;
}

resetflagbaseeffect() //checked matches cerberus output
{
	wait 0.1;
	if ( isDefined( self.baseeffect ) )
	{
		self.baseeffect delete();
	}
	team = self maps/mp/gametypes/_gameobjects::getownerteam();
	if ( team != "axis" && team != "allies" )
	{
		return;
	}
	fxid = level.flagbasefxid[ team ];
	self.baseeffect = spawnfx( fxid, self.baseeffectpos, self.baseeffectforward, self.baseeffectright );
	triggerfx( self.baseeffect );
}

turn_on() //checked matches cerberus output 
{
	if ( level.hardcoremode )
	{
		return;
	}
	self.origin = self.original_origin;
}

turn_off() //checked matches cerberus output
{
	self.origin = ( self.original_origin[ 0 ], self.original_origin[ 1 ], self.original_origin[ 2 ] - 10000 );
}

update_hints() //checked matches cerberus output
{
	allied_flag = level.teamflags[ "allies" ];
	axis_flag = level.teamflags[ "axis" ];
	if ( !level.touchreturn )
	{
		return;
	}
	if ( isDefined( allied_flag.carrier ) && axis_flag maps/mp/gametypes/_gameobjects::isobjectawayfromhome() )
	{
		level.flaghints[ "axis" ] turn_on();
	}
	else
	{
		level.flaghints[ "axis" ] turn_off();
	}
	if ( isDefined( axis_flag.carrier ) && allied_flag maps/mp/gametypes/_gameobjects::isobjectawayfromhome() )
	{
		level.flaghints[ "allies" ] turn_on();
	}
	else
	{
		level.flaghints[ "allies" ] turn_off();
	}
}

claim_trigger( trigger ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self clientclaimtrigger( trigger );
	self waittill( "drop_object" );
	self clientreleasetrigger( trigger );
}

createflagspawninfluencer( entityteam ) //checked matches cerberus output
{
	ctf_friendly_base_influencer_score = level.spawnsystem.ctf_friendly_base_influencer_score;
	ctf_friendly_base_influencer_score_curve = level.spawnsystem.ctf_friendly_base_influencer_score_curve;
	ctf_friendly_base_influencer_radius = level.spawnsystem.ctf_friendly_base_influencer_radius;
	ctf_enemy_base_influencer_score = level.spawnsystem.ctf_enemy_base_influencer_score;
	ctf_enemy_base_influencer_score_curve = level.spawnsystem.ctf_enemy_base_influencer_score_curve;
	ctf_enemy_base_influencer_radius = level.spawnsystem.ctf_enemy_base_influencer_radius;
	otherteam = getotherteam( entityteam );
	team_mask = getteammask( entityteam );
	other_team_mask = getteammask( otherteam );
	self.spawn_influencer_friendly = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.trigger.origin, ctf_friendly_base_influencer_radius, ctf_friendly_base_influencer_score, team_mask, "ctf_friendly_base,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ctf_friendly_base_influencer_score_curve ) );
	self.spawn_influencer_enemy = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.trigger.origin, ctf_enemy_base_influencer_radius, ctf_enemy_base_influencer_score, other_team_mask, "ctf_enemy_base,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ctf_enemy_base_influencer_score_curve ) );
}

ctf_gamemodespawndvars( reset_dvars ) //checked matches cerberus output
{
	ss = level.spawnsystem;
	ss.ctf_friendly_base_influencer_score = set_dvar_float_if_unset( "scr_spawn_ctf_friendly_base_influencer_score", "0", reset_dvars );
	ss.ctf_friendly_base_influencer_score_curve = set_dvar_if_unset( "scr_spawn_ctf_friendly_base_influencer_score_curve", "constant", reset_dvars );
	ss.ctf_friendly_base_influencer_radius = set_dvar_float_if_unset( "scr_spawn_ctf_friendly_base_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.ctf_enemy_base_influencer_score = set_dvar_float_if_unset( "scr_spawn_ctf_enemy_base_influencer_score", "-500", reset_dvars );
	ss.ctf_enemy_base_influencer_score_curve = set_dvar_if_unset( "scr_spawn_ctf_enemy_base_influencer_score_curve", "constant", reset_dvars );
	ss.ctf_enemy_base_influencer_radius = set_dvar_float_if_unset( "scr_spawn_ctf_enemy_base_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.ctf_enemy_carrier_influencer_score = set_dvar_float_if_unset( "scr_spawn_ctf_enemy_carrier_influencer_score", "0", reset_dvars );
	ss.ctf_enemy_carrier_influencer_score_curve = set_dvar_if_unset( "scr_spawn_ctf_enemy_carrier_influencer_score_curve", "constant", reset_dvars );
	ss.ctf_enemy_carrier_influencer_radius = set_dvar_float_if_unset( "scr_spawn_ctf_enemy_carrier_influencer_radius", "" + ( 10 * get_player_height() ), reset_dvars );
	ss.ctf_friendly_carrier_influencer_score = set_dvar_float_if_unset( "scr_spawn_ctf_friendly_carrier_influencer_score", "0", reset_dvars );
	ss.ctf_friendly_carrier_influencer_score_curve = set_dvar_if_unset( "scr_spawn_ctf_friendly_carrier_influencer_score_curve", "constant", reset_dvars );
	ss.ctf_friendly_carrier_influencer_radius = set_dvar_float_if_unset( "scr_spawn_ctf_friendly_carrier_influencer_radius", "" + ( 8 * get_player_height() ), reset_dvars );
	ss.ctf_dropped_influencer_score = set_dvar_float_if_unset( "scr_spawn_ctf_dropped_influencer_score", "0", reset_dvars );
	ss.ctf_dropped_influencer_score_curve = set_dvar_if_unset( "scr_spawn_ctf_dropped_influencer_score_curve", "constant", reset_dvars );
	ss.ctf_dropped_influencer_radius = set_dvar_float_if_unset( "scr_spawn_ctf_dropped_influencer_radius", "" + ( 10 * get_player_height() ), reset_dvars );
}

ctf_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon ) //checked matches cerberus output
{
	teamkill_penalty = maps/mp/gametypes/_globallogic_defaults::default_getteamkillpenalty( einflictor, attacker, smeansofdeath, sweapon );
	if ( is_true( self.isflagcarrier ) )
	{
		teamkill_penalty *= level.teamkillpenaltymultiplier;
	}
	return teamkill_penalty;
}

ctf_getteamkillscore( einflictor, attacker, smeansofdeath, sweapon ) //checked matches cerberus output
{
	teamkill_score = maps/mp/gametypes/_rank::getscoreinfovalue( "kill" );
	if ( is_true( self.isflagcarrier ) )
	{
		teamkill_score *= level.teamkillscoremultiplier;
	}
	return int( teamkill_score );
}


