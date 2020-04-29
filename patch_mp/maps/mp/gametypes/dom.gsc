#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_popups;
#include maps/mp/_demo;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/teams/_teams;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
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
	registertimelimit( 0, 1440 );
	registerscorelimit( 0, 1000 );
	registerroundlimit( 0, 10 );
	registerroundwinlimit( 0, 10 );
	registerroundswitch( 0, 9 );
	registernumlives( 0, 100 );
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.scoreroundbased = getgametypesetting( "roundscorecarry" ) == 0;
	level.teambased = 1;
	level.overrideteamscore = 1;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onplayerkilled = ::onplayerkilled;
	level.onroundswitch = ::onroundswitch;
	level.onprecachegametype = ::onprecachegametype;
	level.onendgame = ::onendgame;
	level.gamemodespawndvars = ::dom_gamemodespawndvars;
	level.onroundendgame = ::onroundendgame;
	game[ "dialog" ][ "gametype" ] = "dom_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hcdom_start";
	game[ "dialog" ][ "offense_obj" ] = "cap_start";
	game[ "dialog" ][ "defense_obj" ] = "cap_start";
	level.lastdialogtime = 0;
	if ( !sessionmodeissystemlink() && !sessionmodeisonlinegame() && issplitscreen() )
	{
		setscoreboardcolumns( "score", "kills", "captures", "defends", "deaths" );
	}
	else
	{
		setscoreboardcolumns( "score", "kills", "deaths", "captures", "defends" );
	}
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_objective", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_objective_a", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_objective_b", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_objective_c", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_changing_a", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_changing_b", 0 );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "gamemode_changing_c", 0 );
}

onprecachegametype()
{
}

onstartgametype()
{
	setobjectivetext( "allies", &"OBJECTIVES_DOM" );
	setobjectivetext( "axis", &"OBJECTIVES_DOM" );
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
	if ( level.splitscreen )
	{
		setobjectivescoretext( "allies", &"OBJECTIVES_DOM" );
		setobjectivescoretext( "axis", &"OBJECTIVES_DOM" );
	}
	else
	{
		setobjectivescoretext( "allies", &"OBJECTIVES_DOM_SCORE" );
		setobjectivescoretext( "axis", &"OBJECTIVES_DOM_SCORE" );
	}
	setobjectivehinttext( "allies", &"OBJECTIVES_DOM_HINT" );
	setobjectivehinttext( "axis", &"OBJECTIVES_DOM_HINT" );
	level.flagbasefxid = [];
	level.flagbasefxid[ "allies" ] = loadfx( "misc/fx_ui_flagbase_" + game[ "allies" ] );
	level.flagbasefxid[ "axis" ] = loadfx( "misc/fx_ui_flagbase_" + game[ "axis" ] );
	setclientnamemode( "auto_change" );
	allowed[ 0 ] = "dom";
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 1, 1, 1 );
	level.spawnmaxs = ( 1, 1, 1 );
	maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_dom_spawn_allies_start" );
	maps/mp/gametypes/_spawnlogic::placespawnpoints( "mp_dom_spawn_axis_start" );
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.spawn_all = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dom_spawn" );
	level.spawn_start = [];
	_a194 = level.teams;
	_k194 = getFirstArrayKey( _a194 );
	while ( isDefined( _k194 ) )
	{
		team = _a194[ _k194 ];
		level.spawn_start[ team ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dom_spawn_" + team + "_start" );
		_k194 = getNextArrayKey( _a194, _k194 );
	}
	flagspawns = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dom_spawn_flag_a" );
	level.startpos[ "allies" ] = level.spawn_start[ "allies" ][ 0 ].origin;
	level.startpos[ "axis" ] = level.spawn_start[ "axis" ][ 0 ].origin;
	if ( !isoneround() && isscoreroundbased() )
	{
		maps/mp/gametypes/_globallogic_score::resetteamscores();
	}
	level.spawnsystem.unifiedsideswitching = 0;
	level thread watchforbflagcap();
	updategametypedvars();
	thread domflags();
	thread updatedomscores();
	level change_dom_spawns();
}

onspawnplayerunified()
{
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn )
{
	spawnpoint = undefined;
	spawnteam = self.pers[ "team" ];
	if ( game[ "switchedsides" ] )
	{
		spawnteam = getotherteam( spawnteam );
	}
	if ( !level.usestartspawns )
	{
		flagsowned = 0;
		enemyflagsowned = 0;
		enemyteam = getotherteam( self.pers[ "team" ] );
		i = 0;
		while ( i < level.flags.size )
		{
			team = level.flags[ i ] getflagteam();
			if ( team == self.pers[ "team" ] )
			{
				flagsowned++;
				i++;
				continue;
			}
			else
			{
				if ( team == enemyteam )
				{
					enemyflagsowned++;
				}
			}
			i++;
		}
		enemyteam = getotherteam( spawnteam );
		if ( flagsowned == level.flags.size )
		{
			enemybestspawnflag = level.bestspawnflag[ enemyteam ];
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_all, getspawnsboundingflag( enemybestspawnflag ) );
		}
		else if ( flagsowned > 0 )
		{
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_all, getboundaryflagspawns( spawnteam ) );
		}
		else
		{
			bestflag = undefined;
			if ( enemyflagsowned > 0 && enemyflagsowned < level.flags.size )
			{
				bestflag = getunownedflagneareststart( spawnteam );
			}
			if ( !isDefined( bestflag ) )
			{
				bestflag = level.bestspawnflag[ spawnteam ];
			}
			level.bestspawnflag[ spawnteam ] = bestflag;
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( level.spawn_all, bestflag.nearbyspawns );
		}
	}
	if ( !isDefined( spawnpoint ) )
	{
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( level.spawn_start[ spawnteam ] );
	}
/#
	assert( isDefined( spawnpoint ) );
#/
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "dom" );
	}
}

onendgame( winningteam )
{
	i = 0;
	while ( i < level.domflags.size )
	{
		domflag = level.domflags[ i ];
		domflag maps/mp/gametypes/_gameobjects::allowuse( "none" );
		if ( isDefined( domflag.singleowner ) && domflag.singleowner == 1 )
		{
			team = domflag maps/mp/gametypes/_gameobjects::getownerteam();
			label = domflag maps/mp/gametypes/_gameobjects::getlabel();
			maps/mp/_challenges::holdflagentirematch( team, label );
		}
		i++;
	}
}

onroundendgame( roundwinner )
{
	if ( level.roundscorecarry == 0 )
	{
		_a318 = level.teams;
		_k318 = getFirstArrayKey( _a318 );
		while ( isDefined( _k318 ) )
		{
			team = _a318[ _k318 ];
			[[ level._setteamscore ]]( team, game[ "roundswon" ][ team ] );
			_k318 = getNextArrayKey( _a318, _k318 );
		}
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "roundswon" );
	}
	else
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbyteamscore();
	}
	return winner;
}

updategametypedvars()
{
	level.flagcapturetime = getgametypesetting( "captureTime" );
	level.playercapturelpm = getgametypesetting( "maxPlayerEventsPerMinute" );
	level.flagcapturelpm = getgametypesetting( "maxObjectiveEventsPerMinute" );
	level.playeroffensivemax = getgametypesetting( "maxPlayerOffensive" );
	level.playerdefensivemax = getgametypesetting( "maxPlayerDefensive" );
}

domflags()
{
	level.laststatus[ "allies" ] = 0;
	level.laststatus[ "axis" ] = 0;
	level.flagmodel[ "allies" ] = maps/mp/teams/_teams::getteamflagmodel( "allies" );
	level.flagmodel[ "axis" ] = maps/mp/teams/_teams::getteamflagmodel( "axis" );
	level.flagmodel[ "neutral" ] = maps/mp/teams/_teams::getteamflagmodel( "neutral" );
	precachemodel( level.flagmodel[ "allies" ] );
	precachemodel( level.flagmodel[ "axis" ] );
	precachemodel( level.flagmodel[ "neutral" ] );
	precachestring( &"MP_CAPTURING_FLAG" );
	precachestring( &"MP_LOSING_FLAG" );
	precachestring( &"MP_DOM_YOUR_FLAG_WAS_CAPTURED" );
	precachestring( &"MP_DOM_ENEMY_FLAG_CAPTURED" );
	precachestring( &"MP_DOM_NEUTRAL_FLAG_CAPTURED" );
	precachestring( &"MP_ENEMY_FLAG_CAPTURED_BY" );
	precachestring( &"MP_NEUTRAL_FLAG_CAPTURED_BY" );
	precachestring( &"MP_FRIENDLY_FLAG_CAPTURED_BY" );
	precachestring( &"MP_DOM_FLAG_A_CAPTURED_BY" );
	precachestring( &"MP_DOM_FLAG_B_CAPTURED_BY" );
	precachestring( &"MP_DOM_FLAG_C_CAPTURED_BY" );
	precachestring( &"MP_DOM_FLAG_D_CAPTURED_BY" );
	precachestring( &"MP_DOM_FLAG_E_CAPTURED_BY" );
	primaryflags = getentarray( "flag_primary", "targetname" );
	secondaryflags = getentarray( "flag_secondary", "targetname" );
	if ( ( primaryflags.size + secondaryflags.size ) < 2 )
	{
/#
		println( "^1Not enough domination flags found in level!" );
#/
		maps/mp/gametypes/_callbacksetup::abortlevel();
		return;
	}
	level.flags = [];
	index = 0;
	while ( index < primaryflags.size )
	{
		level.flags[ level.flags.size ] = primaryflags[ index ];
		index++;
	}
	index = 0;
	while ( index < secondaryflags.size )
	{
		level.flags[ level.flags.size ] = secondaryflags[ index ];
		index++;
	}
	level.domflags = [];
	index = 0;
	while ( index < level.flags.size )
	{
		trigger = level.flags[ index ];
		if ( isDefined( trigger.target ) )
		{
			visuals[ 0 ] = getent( trigger.target, "targetname" );
		}
		else
		{
			visuals[ 0 ] = spawn( "script_model", trigger.origin );
			visuals[ 0 ].angles = trigger.angles;
		}
		visuals[ 0 ] setmodel( level.flagmodel[ "neutral" ] );
		name = istring( trigger.script_label );
		precachestring( name );
		domflag = maps/mp/gametypes/_gameobjects::createuseobject( "neutral", trigger, visuals, ( 1, 1, 1 ), name );
		domflag maps/mp/gametypes/_gameobjects::allowuse( "enemy" );
		domflag maps/mp/gametypes/_gameobjects::setusetime( level.flagcapturetime );
		domflag maps/mp/gametypes/_gameobjects::setusetext( &"MP_CAPTURING_FLAG" );
		label = domflag maps/mp/gametypes/_gameobjects::getlabel();
		domflag.label = label;
		domflag.flagindex = trigger.script_index;
		domflag maps/mp/gametypes/_gameobjects::setvisibleteam( "any" );
		domflag.onuse = ::onuse;
		domflag.onbeginuse = ::onbeginuse;
		domflag.onuseupdate = ::onuseupdate;
		domflag.onenduse = ::onenduse;
		domflag.onupdateuserate = ::onupdateuserate;
		tracestart = visuals[ 0 ].origin + vectorScale( ( 1, 1, 1 ), 32 );
		traceend = visuals[ 0 ].origin + vectorScale( ( 1, 1, 1 ), 32 );
		trace = bullettrace( tracestart, traceend, 0, undefined );
		upangles = vectorToAngle( trace[ "normal" ] );
		domflag.baseeffectforward = anglesToForward( upangles );
		domflag.baseeffectright = anglesToRight( upangles );
		domflag.baseeffectpos = trace[ "position" ];
		level.flags[ index ].useobj = domflag;
		level.flags[ index ].adjflags = [];
		level.flags[ index ].nearbyspawns = [];
		domflag.levelflag = level.flags[ index ];
		level.domflags[ level.domflags.size ] = domflag;
		index++;
	}
	level.bestspawnflag = [];
	level.bestspawnflag[ "allies" ] = getunownedflagneareststart( "allies", undefined );
	level.bestspawnflag[ "axis" ] = getunownedflagneareststart( "axis", level.bestspawnflag[ "allies" ] );
	index = 0;
	while ( index < level.domflags.size )
	{
		level.domflags[ index ] createflagspawninfluencers();
		index++;
	}
	flagsetup();
/#
	thread domdebug();
#/
}

getunownedflagneareststart( team, excludeflag )
{
	best = undefined;
	bestdistsq = undefined;
	i = 0;
	while ( i < level.flags.size )
	{
		flag = level.flags[ i ];
		if ( flag getflagteam() != "neutral" )
		{
			i++;
			continue;
		}
		else
		{
			distsq = distancesquared( flag.origin, level.startpos[ team ] );
			if ( isDefined( excludeflag ) && flag != excludeflag || !isDefined( best ) && distsq < bestdistsq )
			{
				bestdistsq = distsq;
				best = flag;
			}
		}
		i++;
	}
	return best;
}

domdebug()
{
/#
	while ( 1 )
	{
		while ( getDvar( #"9F76D073" ) != "1" )
		{
			wait 2;
		}
		while ( 1 )
		{
			if ( getDvar( #"9F76D073" ) != "1" )
			{
				break;
			}
			else
			{
				i = 0;
				while ( i < level.flags.size )
				{
					j = 0;
					while ( j < level.flags[ i ].adjflags.size )
					{
						line( level.flags[ i ].origin, level.flags[ i ].adjflags[ j ].origin, ( 1, 1, 1 ) );
						j++;
					}
					j = 0;
					while ( j < level.flags[ i ].nearbyspawns.size )
					{
						line( level.flags[ i ].origin, level.flags[ i ].nearbyspawns[ j ].origin, ( 0,2, 0,2, 0,6 ) );
						j++;
					}
					if ( level.flags[ i ] == level.bestspawnflag[ "allies" ] )
					{
						print3d( level.flags[ i ].origin, "allies best spawn flag" );
					}
					if ( level.flags[ i ] == level.bestspawnflag[ "axis" ] )
					{
						print3d( level.flags[ i ].origin, "axis best spawn flag" );
					}
					i++;
				}
				wait 0,05;
			}
		}
#/
	}
}

onbeginuse( player )
{
	ownerteam = self maps/mp/gametypes/_gameobjects::getownerteam();
	self.didstatusnotify = 0;
	if ( ownerteam == "allies" )
	{
		otherteam = "axis";
	}
	else
	{
		otherteam = "allies";
	}
	if ( ownerteam == "neutral" )
	{
		otherteam = getotherteam( player.pers[ "team" ] );
		statusdialog( "securing" + self.label, player.pers[ "team" ], "gamemode_changing" + self.label );
		return;
	}
}

onuseupdate( team, progress, change )
{
	if ( progress > 0,05 && change && !self.didstatusnotify )
	{
		ownerteam = self maps/mp/gametypes/_gameobjects::getownerteam();
		if ( ownerteam == "neutral" )
		{
			otherteam = getotherteam( team );
			statusdialog( "securing" + self.label, team, "gamemode_changing" + self.label );
		}
		else
		{
			statusdialog( "losing" + self.label, ownerteam, "gamemode_changing" + self.label );
			statusdialog( "securing" + self.label, team, "gamemode_changing" + self.label );
		}
		self.didstatusnotify = 1;
	}
}

flushalldialog()
{
	maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_objective_a" );
	maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_objective_b" );
	maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_objective_c" );
	maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_changing_a" );
	maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_changing_b" );
	maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_changing_c" );
}

statusdialog( dialog, team, group, flushgroup )
{
	if ( isDefined( flushgroup ) )
	{
		maps/mp/gametypes/_globallogic_audio::flushgroupdialog( flushgroup );
	}
	maps/mp/gametypes/_globallogic_audio::leaderdialog( dialog, team, group );
}

onenduse( team, player, success )
{
	if ( !success )
	{
		maps/mp/gametypes/_globallogic_audio::flushgroupdialog( "gamemode_changing" + self.label );
	}
}

resetflagbaseeffect()
{
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

onuse( player )
{
	level notify( "flag_captured" );
	team = player.pers[ "team" ];
	oldteam = self maps/mp/gametypes/_gameobjects::getownerteam();
	label = self maps/mp/gametypes/_gameobjects::getlabel();
	player logstring( "flag captured: " + self.label );
	self maps/mp/gametypes/_gameobjects::setownerteam( team );
	self.visuals[ 0 ] setmodel( level.flagmodel[ team ] );
	setdvar( "scr_obj" + self maps/mp/gametypes/_gameobjects::getlabel(), team );
	self resetflagbaseeffect();
	level.usestartspawns = 0;
/#
	assert( team != "neutral" );
#/
	isbflag = 0;
	string = &"";
	switch( label )
	{
		case "_a":
			string = &"MP_DOM_FLAG_A_CAPTURED_BY";
			break;
		case "_b":
			string = &"MP_DOM_FLAG_B_CAPTURED_BY";
			isbflag = 1;
			break;
		case "_c":
			string = &"MP_DOM_FLAG_C_CAPTURED_BY";
			break;
		case "_d":
			string = &"MP_DOM_FLAG_D_CAPTURED_BY";
			break;
		case "_e":
			string = &"MP_DOM_FLAG_E_CAPTURED_BY";
			break;
		default:
		}
/#
		assert( string != &"" );
#/
		touchlist = [];
		touchkeys = getarraykeys( self.touchlist[ team ] );
		i = 0;
		while ( i < touchkeys.size )
		{
			touchlist[ touchkeys[ i ] ] = self.touchlist[ team ][ touchkeys[ i ] ];
			i++;
		}
		thread give_capture_credit( touchlist, string, oldteam, isbflag );
		bbprint( "mpobjective", "gametime %d objtype %s label %s team %s", getTime(), "dom_capture", label, team );
		if ( oldteam == "neutral" )
		{
			self.singleowner = 1;
			otherteam = getotherteam( team );
			thread printandsoundoneveryone( team, undefined, &"", undefined, "mp_war_objective_taken" );
			thread playsoundonplayers( "mus_dom_captured" + "_" + level.teampostfix[ team ] );
			if ( getteamflagcount( team ) == level.flags.size )
			{
				statusdialog( "secure_all", team, "gamemode_objective" );
				statusdialog( "lost_all", otherteam, "gamemode_objective" );
				flushalldialog();
			}
			else statusdialog( "secured" + self.label, team, "gamemode_objective" + self.label, "gamemode_changing" + self.label );
			statusdialog( "enemy" + self.label, otherteam, "gamemode_objective" + self.label, "gamemode_changing" + self.label );
			maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagcapture_sting_enemy", otherteam );
			maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagcapture_sting_friend", team );
		}
		else
		{
			self.singleowner = 0;
			thread printandsoundoneveryone( team, oldteam, &"", &"", "mp_war_objective_taken", "mp_war_objective_lost", "" );
			if ( getteamflagcount( team ) == level.flags.size )
			{
				statusdialog( "secure_all", team, "gamemode_objective" );
				statusdialog( "lost_all", oldteam, "gamemode_objective" );
				flushalldialog();
			}
			else
			{
				statusdialog( "secured" + self.label, team, "gamemode_objective" + self.label, "gamemode_changing" + self.label );
				if ( randomint( 2 ) )
				{
					statusdialog( "lost" + self.label, oldteam, "gamemode_objective" + self.label, "gamemode_changing" + self.label );
				}
				else
				{
					statusdialog( "enemy" + self.label, oldteam, "gamemode_objective" + self.label, "gamemode_changing" + self.label );
				}
				maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagcapture_sting_enemy", oldteam );
				maps/mp/gametypes/_globallogic_audio::play_2d_on_team( "mpl_flagcapture_sting_friend", team );
			}
			level.bestspawnflag[ oldteam ] = self.levelflag;
		}
		if ( dominated_challenge_check() )
		{
			level thread totaldomination( team );
		}
		self update_spawn_influencers( team );
		level change_dom_spawns();
	}
}

totaldomination( team )
{
	level endon( "flag_captured" );
	level endon( "game_ended" );
	wait 180;
	maps/mp/_challenges::totaldomination( team );
}

watchforbflagcap()
{
	level endon( "game_ended" );
	level endon( "endWatchForBFlagCapAfterTime" );
	level thread endwatchforbflagcapaftertime( 60 );
	for ( ;; )
	{
		level waittill( "b_flag_captured", player );
		player maps/mp/_challenges::capturedbfirstminute();
	}
}

endwatchforbflagcapaftertime( time )
{
	level endon( "game_ended" );
	wait 60;
	level notify( "endWatchForBFlagCapAfterTime" );
}

give_capture_credit( touchlist, string, lastownerteam, isbflag )
{
	time = getTime();
	wait 0,05;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	self updatecapsperminute( lastownerteam );
	players = getarraykeys( touchlist );
	i = 0;
	while ( i < players.size )
	{
		player_from_touchlist = touchlist[ players[ i ] ].player;
		player_from_touchlist updatecapsperminute( lastownerteam );
		if ( !isscoreboosting( player_from_touchlist, self ) )
		{
			player_from_touchlist maps/mp/_challenges::capturedobjective( time );
			if ( lastownerteam == "neutral" )
			{
				if ( isbflag )
				{
					maps/mp/_scoreevents::processscoreevent( "dom_point_neutral_b_secured", player_from_touchlist );
				}
				else
				{
					maps/mp/_scoreevents::processscoreevent( "dom_point_neutral_secured", player_from_touchlist );
				}
			}
			else
			{
				maps/mp/_scoreevents::processscoreevent( "dom_point_secured", player_from_touchlist );
			}
			player_from_touchlist recordgameevent( "capture" );
			if ( isbflag )
			{
				level notify( "b_flag_captured" );
			}
			if ( isDefined( player_from_touchlist.pers[ "captures" ] ) )
			{
				player_from_touchlist.pers[ "captures" ]++;
				player_from_touchlist.captures = player_from_touchlist.pers[ "captures" ];
			}
			maps/mp/_demo::bookmark( "event", getTime(), player_from_touchlist );
			player_from_touchlist addplayerstatwithgametype( "CAPTURES", 1 );
		}
		else
		{
/#
			player_from_touchlist iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU CAPTURE CREDIT AS BOOSTING PREVENTION" );
#/
		}
		level thread maps/mp/_popups::displayteammessagetoall( string, player_from_touchlist );
		i++;
	}
}

delayedleaderdialog( sound, team, label )
{
	wait 0,1;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	if ( !isDefined( label ) )
	{
		label = "";
	}
	maps/mp/gametypes/_globallogic_audio::leaderdialog( sound, team, "gamemode_objective" + label );
}

updatedomscores()
{
	while ( !level.gameended )
	{
		numownedflags = 0;
		scoring_teams = [];
		numflags = getteamflagcount( "allies" );
		numownedflags += numflags;
		if ( numflags )
		{
			scoring_teams[ scoring_teams.size ] = "allies";
			maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective_delaypostprocessing( "allies", numflags );
		}
		numflags = getteamflagcount( "axis" );
		numownedflags += numflags;
		if ( numflags )
		{
			scoring_teams[ scoring_teams.size ] = "axis";
			maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective_delaypostprocessing( "axis", numflags );
		}
		if ( numownedflags )
		{
			maps/mp/gametypes/_globallogic_score::postprocessteamscores( scoring_teams );
		}
		onscoreclosemusic();
		timepassed = maps/mp/gametypes/_globallogic_utils::gettimepassed();
		if ( ( timepassed / 1000 ) > 120 && numownedflags < 2 && ( timepassed / 1000 ) > 300 && numownedflags < 3 && gamemodeismode( level.gamemode_public_match ) )
		{
			thread maps/mp/gametypes/_globallogic::endgame( "tie", game[ "strings" ][ "time_limit_reached" ] );
			return;
		}
		wait 5;
		maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
	}
}

onscoreclosemusic()
{
	axisscore = [[ level._getteamscore ]]( "axis" );
	alliedscore = [[ level._getteamscore ]]( "allies" );
	scorelimit = level.scorelimit;
	scorethreshold = scorelimit * 0,1;
	scoredif = abs( axisscore - alliedscore );
	scorethresholdstart = abs( scorelimit - scorethreshold );
	scorelimitcheck = scorelimit - 10;
	if ( !isDefined( level.playingactionmusic ) )
	{
		level.playingactionmusic = 0;
	}
	if ( alliedscore > axisscore )
	{
		currentscore = alliedscore;
	}
	else
	{
		currentscore = axisscore;
	}
/#
	if ( getDvarInt( #"0BC4784C" ) > 0 )
	{
		println( "Music System Domination - scoreDif " + scoredif );
		println( "Music System Domination - axisScore " + axisscore );
		println( "Music System Domination - alliedScore " + alliedscore );
		println( "Music System Domination - scoreLimit " + scorelimit );
		println( "Music System Domination - currentScore " + currentscore );
		println( "Music System Domination - scoreThreshold " + scorethreshold );
		println( "Music System Domination - scoreDif " + scoredif );
		println( "Music System Domination - scoreThresholdStart " + scorethresholdstart );
#/
	}
	if ( scoredif <= scorethreshold && scorethresholdstart <= currentscore && level.playingactionmusic != 1 )
	{
		thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "TIME_OUT", "both" );
		thread maps/mp/gametypes/_globallogic_audio::actionmusicset();
	}
	else
	{
		return;
	}
}

onroundswitch()
{
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	game[ "switchedsides" ] = !game[ "switchedsides" ];
	if ( level.roundscorecarry == 0 )
	{
		[[ level._setteamscore ]]( "allies", game[ "roundswon" ][ "allies" ] );
		[[ level._setteamscore ]]( "axis", game[ "roundswon" ][ "axis" ] );
	}
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		scoreeventprocessed = 0;
		if ( attacker.touchtriggers.size && attacker.pers[ "team" ] != self.pers[ "team" ] )
		{
			triggerids = getarraykeys( attacker.touchtriggers );
			ownerteam = attacker.touchtriggers[ triggerids[ 0 ] ].useobj.ownerteam;
			team = attacker.pers[ "team" ];
			if ( team != ownerteam )
			{
				maps/mp/_scoreevents::processscoreevent( "kill_enemy_while_capping_dom", attacker, undefined, sweapon );
				scoreeventprocessed = 1;
			}
		}
		index = 0;
		while ( index < level.flags.size )
		{
			flagteam = "invalidTeam";
			inflagzone = 0;
			defendedflag = 0;
			offendedflag = 0;
			flagorigin = level.flags[ index ].origin;
			level.defaultoffenseradius = 300;
			dist = distance2d( self.origin, flagorigin );
			if ( dist < level.defaultoffenseradius )
			{
				inflagzone = 1;
				if ( level.flags[ index ] getflagteam() == attacker.pers[ "team" ] || level.flags[ index ] getflagteam() == "neutral" )
				{
					defendedflag = 1;
					break;
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
				if ( level.flags[ index ] getflagteam() == attacker.pers[ "team" ] || level.flags[ index ] getflagteam() == "neutral" )
				{
					defendedflag = 1;
					break;
				}
				else
				{
					offendedflag = 1;
				}
			}
			if ( inflagzone && isplayer( attacker ) && attacker.pers[ "team" ] != self.pers[ "team" ] )
			{
				if ( offendedflag )
				{
					if ( !isDefined( attacker.dom_defends ) )
					{
						attacker.dom_defends = 0;
					}
					attacker.dom_defends++;
					if ( level.playerdefensivemax >= attacker.dom_defends )
					{
						attacker addplayerstatwithgametype( "OFFENDS", 1 );
						if ( !scoreeventprocessed )
						{
							maps/mp/_scoreevents::processscoreevent( "killed_defender", attacker, undefined, sweapon );
						}
						self recordkillmodifier( "defending" );
						break;
					}
					else /#
					attacker iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU DEFENSIVE CREDIT AS BOOSTING PREVENTION" );
#/
				}
				if ( defendedflag )
				{
					if ( !isDefined( attacker.dom_offends ) )
					{
						attacker.dom_offends = 0;
					}
					attacker thread updateattackermultikills();
					attacker.dom_offends++;
					if ( level.playeroffensivemax >= attacker.dom_offends )
					{
						attacker.pers[ "defends" ]++;
						attacker.defends = attacker.pers[ "defends" ];
						attacker addplayerstatwithgametype( "DEFENDS", 1 );
						attacker recordgameevent( "return" );
						attacker maps/mp/_challenges::killedzoneattacker( sweapon );
						if ( !scoreeventprocessed )
						{
							maps/mp/_scoreevents::processscoreevent( "killed_attacker", attacker, undefined, sweapon );
						}
						self recordkillmodifier( "assaulting" );
						break;
					}
					else /#
					attacker iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU OFFENSIVE CREDIT AS BOOSTING PREVENTION" );
#/
				}
			}
			index++;
		}
		if ( self.touchtriggers.size && attacker.pers[ "team" ] != self.pers[ "team" ] )
		{
			triggerids = getarraykeys( self.touchtriggers );
			ownerteam = self.touchtriggers[ triggerids[ 0 ] ].useobj.ownerteam;
			team = self.pers[ "team" ];
			if ( team != ownerteam )
			{
				flag = self.touchtriggers[ triggerids[ 0 ] ].useobj;
				if ( isDefined( flag.contested ) && flag.contested == 1 )
				{
					attacker killwhilecontesting( flag );
				}
			}
		}
	}
}

killwhilecontesting( flag )
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
	flag waittill( "contest_over" );
	if ( playerteam != self.pers[ "team" ] || isDefined( self.spawntime ) && killtime < self.spawntime )
	{
		self.clearenemycount = 0;
		return;
	}
	if ( flag.ownerteam != playerteam && flag.ownerteam != "neutral" )
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

updateattackermultikills()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self notify( "updateDomRecentKills" );
	self endon( "updateDomRecentKills" );
	if ( !isDefined( self.recentdomattackerkillcount ) )
	{
		self.recentdomattackerkillcount = 0;
	}
	self.recentdomattackerkillcount++;
	wait 4;
	if ( self.recentdomattackerkillcount > 1 )
	{
		self maps/mp/_challenges::domattackermultikill( self.recentdomattackerkillcount );
	}
	self.recentdomattackerkillcount = 0;
}

getteamflagcount( team )
{
	score = 0;
	i = 0;
	while ( i < level.flags.size )
	{
		if ( level.domflags[ i ] maps/mp/gametypes/_gameobjects::getownerteam() == team )
		{
			score++;
		}
		i++;
	}
	return score;
}

getflagteam()
{
	return self.useobj maps/mp/gametypes/_gameobjects::getownerteam();
}

getboundaryflags()
{
	bflags = [];
	i = 0;
	while ( i < level.flags.size )
	{
		j = 0;
		while ( j < level.flags[ i ].adjflags.size )
		{
			if ( level.flags[ i ].useobj maps/mp/gametypes/_gameobjects::getownerteam() != level.flags[ i ].adjflags[ j ].useobj maps/mp/gametypes/_gameobjects::getownerteam() )
			{
				bflags[ bflags.size ] = level.flags[ i ];
				i++;
				continue;
			}
			else
			{
				j++;
			}
		}
		i++;
	}
	return bflags;
}

getboundaryflagspawns( team )
{
	spawns = [];
	bflags = getboundaryflags();
	i = 0;
	while ( i < bflags.size )
	{
		if ( isDefined( team ) && bflags[ i ] getflagteam() != team )
		{
			i++;
			continue;
		}
		else
		{
			j = 0;
			while ( j < bflags[ i ].nearbyspawns.size )
			{
				spawns[ spawns.size ] = bflags[ i ].nearbyspawns[ j ];
				j++;
			}
		}
		i++;
	}
	return spawns;
}

getspawnsboundingflag( avoidflag )
{
	spawns = [];
	i = 0;
	while ( i < level.flags.size )
	{
		flag = level.flags[ i ];
		if ( flag == avoidflag )
		{
			i++;
			continue;
		}
		else isbounding = 0;
		j = 0;
		while ( j < flag.adjflags.size )
		{
			if ( flag.adjflags[ j ] == avoidflag )
			{
				isbounding = 1;
				break;
			}
			else
			{
				j++;
			}
		}
		if ( !isbounding )
		{
			i++;
			continue;
		}
		else
		{
			j = 0;
			while ( j < flag.nearbyspawns.size )
			{
				spawns[ spawns.size ] = flag.nearbyspawns[ j ];
				j++;
			}
		}
		i++;
	}
	return spawns;
}

getownedandboundingflagspawns( team )
{
	spawns = [];
	i = 0;
	while ( i < level.flags.size )
	{
		if ( level.flags[ i ] getflagteam() == team )
		{
			s = 0;
			while ( s < level.flags[ i ].nearbyspawns.size )
			{
				spawns[ spawns.size ] = level.flags[ i ].nearbyspawns[ s ];
				s++;
			}
		}
		else j = 0;
		while ( j < level.flags[ i ].adjflags.size )
		{
			if ( level.flags[ i ].adjflags[ j ] getflagteam() == team )
			{
				s = 0;
				while ( s < level.flags[ i ].nearbyspawns.size )
				{
					spawns[ spawns.size ] = level.flags[ i ].nearbyspawns[ s ];
					s++;
				}
			}
			else j++;
		}
		i++;
	}
	return spawns;
}

getownedflagspawns( team )
{
	spawns = [];
	i = 0;
	while ( i < level.flags.size )
	{
		while ( level.flags[ i ] getflagteam() == team )
		{
			s = 0;
			while ( s < level.flags[ i ].nearbyspawns.size )
			{
				spawns[ spawns.size ] = level.flags[ i ].nearbyspawns[ s ];
				s++;
			}
		}
		i++;
	}
	return spawns;
}

flagsetup()
{
	maperrors = [];
	descriptorsbylinkname = [];
	descriptors = getentarray( "flag_descriptor", "targetname" );
	flags = level.flags;
	i = 0;
	while ( i < level.domflags.size )
	{
		closestdist = undefined;
		closestdesc = undefined;
		j = 0;
		while ( j < descriptors.size )
		{
			dist = distance( flags[ i ].origin, descriptors[ j ].origin );
			if ( !isDefined( closestdist ) || dist < closestdist )
			{
				closestdist = dist;
				closestdesc = descriptors[ j ];
			}
			j++;
		}
		if ( !isDefined( closestdesc ) )
		{
			maperrors[ maperrors.size ] = "there is no flag_descriptor in the map! see explanation in dom.gsc";
			break;
		}
		else
		{
			if ( isDefined( closestdesc.flag ) )
			{
				maperrors[ maperrors.size ] = "flag_descriptor with script_linkname "" + closestdesc.script_linkname + "" is nearby more than one flag; is there a unique descriptor near each flag?";
				i++;
				continue;
			}
			else
			{
				flags[ i ].descriptor = closestdesc;
				closestdesc.flag = flags[ i ];
				descriptorsbylinkname[ closestdesc.script_linkname ] = closestdesc;
			}
			i++;
		}
	}
	while ( maperrors.size == 0 )
	{
		i = 0;
		while ( i < flags.size )
		{
			if ( isDefined( flags[ i ].descriptor.script_linkto ) )
			{
				adjdescs = strtok( flags[ i ].descriptor.script_linkto, " " );
			}
			else
			{
				adjdescs = [];
			}
			j = 0;
			while ( j < adjdescs.size )
			{
				otherdesc = descriptorsbylinkname[ adjdescs[ j ] ];
				if ( !isDefined( otherdesc ) || otherdesc.targetname != "flag_descriptor" )
				{
					maperrors[ maperrors.size ] = "flag_descriptor with script_linkname "" + flags[ i ].descriptor.script_linkname + "" linked to "" + adjdescs[ j ] + "" which does not exist as a script_linkname of any other entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
					j++;
					continue;
				}
				else
				{
					adjflag = otherdesc.flag;
					if ( adjflag == flags[ i ] )
					{
						maperrors[ maperrors.size ] = "flag_descriptor with script_linkname "" + flags[ i ].descriptor.script_linkname + "" linked to itself";
						j++;
						continue;
					}
					else
					{
						flags[ i ].adjflags[ flags[ i ].adjflags.size ] = adjflag;
					}
				}
				j++;
			}
			i++;
		}
	}
	spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( "mp_dom_spawn" );
	i = 0;
	while ( i < spawnpoints.size )
	{
		if ( isDefined( spawnpoints[ i ].script_linkto ) )
		{
			desc = descriptorsbylinkname[ spawnpoints[ i ].script_linkto ];
			if ( !isDefined( desc ) || desc.targetname != "flag_descriptor" )
			{
				maperrors[ maperrors.size ] = "Spawnpoint at " + spawnpoints[ i ].origin + "" linked to "" + spawnpoints[ i ].script_linkto + "" which does not exist as a script_linkname of any entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
				i++;
				continue;
			}
			else
			{
				nearestflag = desc.flag;
			}
			else
			{
				nearestflag = undefined;
				nearestdist = undefined;
				j = 0;
				while ( j < flags.size )
				{
					dist = distancesquared( flags[ j ].origin, spawnpoints[ i ].origin );
					if ( !isDefined( nearestflag ) || dist < nearestdist )
					{
						nearestflag = flags[ j ];
						nearestdist = dist;
					}
					j++;
				}
			}
			nearestflag.nearbyspawns[ nearestflag.nearbyspawns.size ] = spawnpoints[ i ];
		}
		i++;
	}
	if ( maperrors.size > 0 )
	{
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
		maps/mp/gametypes/_callbacksetup::abortlevel();
		return;
	}
}

createflagspawninfluencers()
{
	ss = level.spawnsystem;
	flag_index = 0;
	while ( flag_index < level.flags.size )
	{
		if ( level.domflags[ flag_index ] == self )
		{
			break;
		}
		else
		{
			flag_index++;
		}
	}
	abc = [];
	abc[ 0 ] = "A";
	abc[ 1 ] = "B";
	abc[ 2 ] = "C";
	self.owned_flag_influencer = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.trigger.origin, ss.dom_owned_flag_influencer_radius[ flag_index ], ss.dom_owned_flag_influencer_score[ flag_index ], 0, "dom_owned_flag_" + abc[ flag_index ] + ",r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ss.dom_owned_flag_influencer_score_curve ) );
	self.neutral_flag_influencer = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.trigger.origin, ss.dom_unowned_flag_influencer_radius, ss.dom_unowned_flag_influencer_score, 0, "dom_unowned_flag,r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ss.dom_owned_flag_influencer_score_curve ) );
	self.enemy_flag_influencer = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, self.trigger.origin, ss.dom_enemy_flag_influencer_radius[ flag_index ], ss.dom_enemy_flag_influencer_score[ flag_index ], 0, "dom_enemy_flag_" + abc[ flag_index ] + ",r,s", maps/mp/gametypes/_spawning::get_score_curve_index( ss.dom_enemy_flag_influencer_score_curve ) );
	self update_spawn_influencers( "neutral" );
}

update_spawn_influencers( team )
{
/#
	assert( isDefined( self.neutral_flag_influencer ) );
#/
/#
	assert( isDefined( self.owned_flag_influencer ) );
#/
/#
	assert( isDefined( self.enemy_flag_influencer ) );
#/
	if ( team == "neutral" )
	{
		enableinfluencer( self.neutral_flag_influencer, 1 );
		enableinfluencer( self.owned_flag_influencer, 0 );
		enableinfluencer( self.enemy_flag_influencer, 0 );
	}
	else
	{
		enableinfluencer( self.neutral_flag_influencer, 0 );
		enableinfluencer( self.owned_flag_influencer, 1 );
		enableinfluencer( self.enemy_flag_influencer, 1 );
		setinfluencerteammask( self.owned_flag_influencer, getteammask( team ) );
		setinfluencerteammask( self.enemy_flag_influencer, getotherteamsmask( team ) );
	}
}

dom_gamemodespawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.dom_owned_flag_influencer_score = [];
	ss.dom_owned_flag_influencer_radius = [];
	ss.dom_owned_flag_influencer_score[ 0 ] = set_dvar_float_if_unset( "scr_spawn_dom_owned_flag_A_influencer_score", "10", reset_dvars );
	ss.dom_owned_flag_influencer_radius[ 0 ] = set_dvar_float_if_unset( "scr_spawn_dom_owned_flag_A_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.dom_owned_flag_influencer_score[ 1 ] = set_dvar_float_if_unset( "scr_spawn_dom_owned_flag_B_influencer_score", "10", reset_dvars );
	ss.dom_owned_flag_influencer_radius[ 1 ] = set_dvar_float_if_unset( "scr_spawn_dom_owned_flag_B_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.dom_owned_flag_influencer_score[ 2 ] = set_dvar_float_if_unset( "scr_spawn_dom_owned_flag_C_influencer_score", "10", reset_dvars );
	ss.dom_owned_flag_influencer_radius[ 2 ] = set_dvar_float_if_unset( "scr_spawn_dom_owned_flag_C_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.dom_owned_flag_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dom_owned_flag_influencer_score_curve", "constant", reset_dvars );
	ss.dom_enemy_flag_influencer_score = [];
	ss.dom_enemy_flag_influencer_radius = [];
	ss.dom_enemy_flag_influencer_score[ 0 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_A_influencer_score", "-50", reset_dvars );
	ss.dom_enemy_flag_influencer_radius[ 0 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_A_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.dom_enemy_flag_influencer_score[ 1 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_B_influencer_score", "-50", reset_dvars );
	ss.dom_enemy_flag_influencer_radius[ 1 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_B_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.dom_enemy_flag_influencer_score[ 2 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_C_influencer_score", "-50", reset_dvars );
	ss.dom_enemy_flag_influencer_radius[ 2 ] = set_dvar_float_if_unset( "scr_spawn_dom_enemy_flag_C_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
	ss.dom_enemy_flag_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dom_enemy_flag_influencer_score_curve", "constant", reset_dvars );
	ss.dom_unowned_flag_influencer_score = set_dvar_float_if_unset( "scr_spawn_dom_unowned_flag_influencer_score", "-500", reset_dvars );
	ss.dom_unowned_flag_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dom_unowned_flag_influencer_score_curve", "constant", reset_dvars );
	ss.dom_unowned_flag_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dom_unowned_flag_influencer_radius", "" + ( 15 * get_player_height() ), reset_dvars );
}

addspawnpointsforflag( team, flag_team, flagspawnname )
{
	if ( game[ "switchedsides" ] )
	{
		team = getotherteam( team );
	}
	otherteam = getotherteam( team );
	if ( flag_team != otherteam )
	{
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, flagspawnname );
	}
}

change_dom_spawns()
{
	maps/mp/gametypes/_spawnlogic::clearspawnpoints();
	maps/mp/gametypes/_spawnlogic::addspawnpoints( "allies", "mp_dom_spawn" );
	maps/mp/gametypes/_spawnlogic::addspawnpoints( "axis", "mp_dom_spawn" );
	flag_number = level.flags.size;
	if ( dominated_check() )
	{
		i = 0;
		while ( i < flag_number )
		{
			label = level.flags[ i ].useobj maps/mp/gametypes/_gameobjects::getlabel();
			flagspawnname = "mp_dom_spawn_flag" + label;
			maps/mp/gametypes/_spawnlogic::addspawnpoints( "allies", flagspawnname );
			maps/mp/gametypes/_spawnlogic::addspawnpoints( "axis", flagspawnname );
			i++;
		}
	}
	else i = 0;
	while ( i < flag_number )
	{
		label = level.flags[ i ].useobj maps/mp/gametypes/_gameobjects::getlabel();
		flagspawnname = "mp_dom_spawn_flag" + label;
		flag_team = level.flags[ i ] getflagteam();
		addspawnpointsforflag( "allies", flag_team, flagspawnname );
		addspawnpointsforflag( "axis", flag_team, flagspawnname );
		i++;
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
}

dominated_challenge_check()
{
	num_flags = level.flags.size;
	allied_flags = 0;
	axis_flags = 0;
	i = 0;
	while ( i < num_flags )
	{
		flag_team = level.flags[ i ] getflagteam();
		if ( flag_team == "allies" )
		{
			allied_flags++;
		}
		else if ( flag_team == "axis" )
		{
			axis_flags++;
		}
		else
		{
			return 0;
		}
		if ( allied_flags > 0 && axis_flags > 0 )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

dominated_check()
{
	num_flags = level.flags.size;
	allied_flags = 0;
	axis_flags = 0;
	i = 0;
	while ( i < num_flags )
	{
		flag_team = level.flags[ i ] getflagteam();
		if ( flag_team == "allies" )
		{
			allied_flags++;
		}
		else
		{
			if ( flag_team == "axis" )
			{
				axis_flags++;
			}
		}
		if ( allied_flags > 0 && axis_flags > 0 )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

updatecapsperminute( lastownerteam )
{
	if ( !isDefined( self.capsperminute ) )
	{
		self.numcaps = 0;
		self.capsperminute = 0;
	}
	if ( lastownerteam == "neutral" )
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

isscoreboosting( player, flag )
{
	if ( !level.rankedmatch )
	{
		return 0;
	}
	if ( player.capsperminute > level.playercapturelpm )
	{
		return 1;
	}
	if ( flag.capsperminute > level.flagcapturelpm )
	{
		return 1;
	}
	return 0;
}

onupdateuserate()
{
	if ( !isDefined( self.contested ) )
	{
		self.contested = 0;
	}
	numother = getnumtouchingexceptteam( self.ownerteam );
	numowners = self.numtouching[ self.claimteam ];
	previousstate = self.contested;
	if ( numother > 0 && numowners > 0 )
	{
		self.contested = 1;
	}
	else
	{
		if ( previousstate == 1 )
		{
			self notify( "contest_over" );
		}
		self.contested = 0;
	}
}
