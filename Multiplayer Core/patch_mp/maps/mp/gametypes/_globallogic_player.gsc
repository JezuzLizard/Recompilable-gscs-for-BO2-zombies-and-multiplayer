//checked includes changed to match cerberus output
#include maps/mp/gametypes/_globallogic_vehicle;
#include maps/mp/_burnplayer;
#include maps/mp/gametypes/_deathicons;
#include maps/mp/gametypes/_tweakables;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_killcam;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/_medals;
#include maps/mp/killstreaks/_straferun;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_rank;
#include maps/mp/teams/_teams;
#include maps/mp/_demo;
#include maps/mp/gametypes/_weapon_utils;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_weapons;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/_vehicles;
#include maps/mp/gametypes/_class;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_spectating;
#include maps/mp/gametypes/_globallogic_spawn;
#include maps/mp/gametypes/_globallogic_ui;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_flashgrenades;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/_gamerep;
#include maps/mp/gametypes/_persistence;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/killstreaks/_killstreak_weapons;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/_utility;

freezeplayerforroundend() //checked matches cerberus output
{
	self clearlowermessage();
	self closemenu();
	self closeingamemenu();
	self freeze_player_controls( 1 );
	if ( !sessionmodeiszombiesgame() )
	{
		currentweapon = self getcurrentweapon();
		if ( maps/mp/killstreaks/_killstreaks::iskillstreakweapon( currentweapon ) && !maps/mp/killstreaks/_killstreak_weapons::isheldkillstreakweapon( currentweapon ) )
		{
			self takeweapon( currentweapon );
		}
	}
}

callback_playerconnect() //checked partially changed to match cerberus output partially changed to match beta dump
{
	thread notifyconnecting();
	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	if ( isDefined( level.reset_clientdvars ) )
	{
		self [[ level.reset_clientdvars ]]();
	}
	waittillframeend;
	self.statusicon = "";
	self.guid = self getguid();
	matchrecorderincrementheaderstat( "playerCountJoined", 1 );
	profilelog_begintiming( 4, "ship" );
	level notify( "connected", self );
	if ( self ishost() )
	{
		self thread maps/mp/gametypes/_globallogic::listenforgameend();
	}
	if ( !level.splitscreen && !isDefined( self.pers[ "score" ] ) )
	{
		iprintln( &"MP_CONNECTED", self );
	}
	if ( !isDefined( self.pers[ "score" ] ) )
	{
		self thread maps/mp/gametypes/_persistence::adjustrecentstats();
		self maps/mp/gametypes/_persistence::setafteractionreportstat( "valid", 0 );
		if ( gamemodeismode( level.gamemode_wager_match ) && !self ishost() )
		{
			self maps/mp/gametypes/_persistence::setafteractionreportstat( "wagerMatchFailed", 1 );
		}
		else
		{
			self maps/mp/gametypes/_persistence::setafteractionreportstat( "wagerMatchFailed", 0 );
		}
	}
	if ( level.rankedmatch && !isDefined( self.pers[ "matchesPlayedStatsTracked" ] ) || level.wagermatch && !isDefined( self.pers[ "matchesPlayedStatsTracked" ] ) || level.leaguematch && !isDefined( self.pers[ "matchesPlayedStatsTracked" ] ) )
	{
		gamemode = maps/mp/gametypes/_globallogic::getcurrentgamemode();
		self maps/mp/gametypes/_globallogic::incrementmatchcompletionstat( gamemode, "played", "started" );
		if ( !isDefined( self.pers[ "matchesHostedStatsTracked" ] ) && self islocaltohost() )
		{
			self maps/mp/gametypes/_globallogic::incrementmatchcompletionstat( gamemode, "hosted", "started" );
			self.pers[ "matchesHostedStatsTracked" ] = 1;
		}
		self.pers[ "matchesPlayedStatsTracked" ] = 1;
		self thread maps/mp/gametypes/_persistence::uploadstatssoon();
	}
	self maps/mp/_gamerep::gamerepplayerconnected();
	lpselfnum = self getentitynumber();
	lpguid = self getguid();
	logprint( "J;" + lpguid + ";" + lpselfnum + ";" + self.name + "\n" );
	bbprint( "mpjoins", "name %s client %s", self.name, lpselfnum );
	if ( !sessionmodeiszombiesgame() )
	{
		self setclientuivisibilityflag( "hud_visible", 1 );
	}
	if ( level.forceradar == 1 )
	{
		self.pers[ "hasRadar" ] = 1;
		self.hasspyplane = 1;
		level.activeuavs[ self getentitynumber() ] = 1;
	}
	if ( level.forceradar == 2 )
	{
		self setclientuivisibilityflag( "g_compassShowEnemies", level.forceradar );
	}
	else
	{
		self setclientuivisibilityflag( "g_compassShowEnemies", 0 );
	}
	self setclientplayersprinttime( level.playersprinttime );
	self setclientnumlives( level.numlives );
	makedvarserverinfo( "cg_drawTalk", 1 );
	if ( level.hardcoremode )
	{
		self setclientdrawtalk( 3 );
	}
	if ( sessionmodeiszombiesgame() )
	{
		self [[ level.player_stats_init ]]();
	}
	else
	{
		self maps/mp/gametypes/_globallogic_score::initpersstat( "score" );
		if ( level.resetplayerscoreeveryround )
		{
			self.pers[ "score" ] = 0;
		}
		self.score = self.pers[ "score" ];
		self maps/mp/gametypes/_globallogic_score::initpersstat( "pointstowin" );
		if ( level.scoreroundbased )
		{
			self.pers[ "pointstowin" ] = 0;
		}
		self.pointstowin = self.pers[ "pointstowin" ];
		self maps/mp/gametypes/_globallogic_score::initpersstat( "momentum", 0 );
		self.momentum = self maps/mp/gametypes/_globallogic_score::getpersstat( "momentum" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "suicides" );
		self.suicides = self maps/mp/gametypes/_globallogic_score::getpersstat( "suicides" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "headshots" );
		self.headshots = self maps/mp/gametypes/_globallogic_score::getpersstat( "headshots" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "challenges" );
		self.challenges = self maps/mp/gametypes/_globallogic_score::getpersstat( "challenges" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "kills" );
		self.kills = self maps/mp/gametypes/_globallogic_score::getpersstat( "kills" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "deaths" );
		self.deaths = self maps/mp/gametypes/_globallogic_score::getpersstat( "deaths" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "assists" );
		self.assists = self maps/mp/gametypes/_globallogic_score::getpersstat( "assists" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "defends", 0 );
		self.defends = self maps/mp/gametypes/_globallogic_score::getpersstat( "defends" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "offends", 0 );
		self.offends = self maps/mp/gametypes/_globallogic_score::getpersstat( "offends" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "plants", 0 );
		self.plants = self maps/mp/gametypes/_globallogic_score::getpersstat( "plants" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "defuses", 0 );
		self.defuses = self maps/mp/gametypes/_globallogic_score::getpersstat( "defuses" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "returns", 0 );
		self.returns = self maps/mp/gametypes/_globallogic_score::getpersstat( "returns" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "captures", 0 );
		self.captures = self maps/mp/gametypes/_globallogic_score::getpersstat( "captures" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "destructions", 0 );
		self.destructions = self maps/mp/gametypes/_globallogic_score::getpersstat( "destructions" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "backstabs", 0 );
		self.backstabs = self maps/mp/gametypes/_globallogic_score::getpersstat( "backstabs" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "longshots", 0 );
		self.longshots = self maps/mp/gametypes/_globallogic_score::getpersstat( "longshots" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "survived", 0 );
		self.survived = self maps/mp/gametypes/_globallogic_score::getpersstat( "survived" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "stabs", 0 );
		self.stabs = self maps/mp/gametypes/_globallogic_score::getpersstat( "stabs" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "tomahawks", 0 );
		self.tomahawks = self maps/mp/gametypes/_globallogic_score::getpersstat( "tomahawks" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "humiliated", 0 );
		self.humiliated = self maps/mp/gametypes/_globallogic_score::getpersstat( "humiliated" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "x2score", 0 );
		self.x2score = self maps/mp/gametypes/_globallogic_score::getpersstat( "x2score" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "agrkills", 0 );
		self.x2score = self maps/mp/gametypes/_globallogic_score::getpersstat( "agrkills" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "hacks", 0 );
		self.x2score = self maps/mp/gametypes/_globallogic_score::getpersstat( "hacks" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "killsconfirmed", 0 );
		self.killsconfirmed = self maps/mp/gametypes/_globallogic_score::getpersstat( "killsconfirmed" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "killsdenied", 0 );
		self.killsdenied = self maps/mp/gametypes/_globallogic_score::getpersstat( "killsdenied" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "sessionbans", 0 );
		self.sessionbans = self maps/mp/gametypes/_globallogic_score::getpersstat( "sessionbans" );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "gametypeban", 0 );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "time_played_total", 0 );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "time_played_alive", 0 );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "teamkills", 0 );
		self maps/mp/gametypes/_globallogic_score::initpersstat( "teamkills_nostats", 0 );
		self.teamkillpunish = 0;
		if ( level.minimumallowedteamkills >= 0 && self.pers[ "teamkills_nostats" ] > level.minimumallowedteamkills )
		{
			self thread reduceteamkillsovertime();
		}
	}
	if ( getDvar( "r_reflectionProbeGenerate" ) == "1" )
	{
		level waittill( "eternity" );
	}
	self.killedplayerscurrent = [];
	if ( !isDefined( self.pers[ "best_kill_streak" ] ) )
	{
		self.pers[ "killed_players" ] = [];
		self.pers[ "killed_by" ] = [];
		self.pers[ "nemesis_tracking" ] = [];
		self.pers[ "artillery_kills" ] = 0;
		self.pers[ "dog_kills" ] = 0;
		self.pers[ "nemesis_name" ] = "";
		self.pers[ "nemesis_rank" ] = 0;
		self.pers[ "nemesis_rankIcon" ] = 0;
		self.pers[ "nemesis_xp" ] = 0;
		self.pers[ "nemesis_xuid" ] = "";
		self.pers[ "best_kill_streak" ] = 0;
	}
	if ( !isDefined( self.pers[ "music" ] ) )
	{
		self.pers[ "music" ] = spawnstruct();
		self.pers[ "music" ].spawn = 0;
		self.pers[ "music" ].inque = 0;
		self.pers[ "music" ].currentstate = "SILENT";
		self.pers[ "music" ].previousstate = "SILENT";
		self.pers[ "music" ].nextstate = "UNDERSCORE";
		self.pers[ "music" ].returnstate = "UNDERSCORE";
	}
	self.leaderdialogqueue = [];
	self.leaderdialogactive = 0;
	self.leaderdialoggroups = [];
	self.currentleaderdialoggroup = "";
	self.currentleaderdialog = "";
	self.currentleaderdialogtime = 0;
	if ( !isDefined( self.pers[ "cur_kill_streak" ] ) )
	{
		self.pers[ "cur_kill_streak" ] = 0;
	}
	if ( !isDefined( self.pers[ "cur_total_kill_streak" ] ) )
	{
		self.pers[ "cur_total_kill_streak" ] = 0;
		self setplayercurrentstreak( 0 );
	}
	if ( !isDefined( self.pers[ "totalKillstreakCount" ] ) )
	{
		self.pers[ "totalKillstreakCount" ] = 0;
	}
	if ( !isDefined( self.pers[ "killstreaksEarnedThisKillstreak" ] ) )
	{
		self.pers[ "killstreaksEarnedThisKillstreak" ] = 0;
	}
	if ( is_true( level.usingscorestreaks ) && !isDefined( self.pers[ "killstreak_quantity" ] ) )
	{
		self.pers[ "killstreak_quantity" ] = [];
	}
	if ( is_true( level.usingscorestreaks ) && !isDefined( self.pers[ "held_killstreak_ammo_count" ] ) )
	{
		self.pers[ "held_killstreak_ammo_count" ] = [];
	}
	if ( is_true( level.usingscorestreaks ) && !isDefined( self.pers[ "held_killstreak_clip_count" ] ) )
	{
		self.pers[ "held_killstreak_clip_count" ] = [];
	}
	if ( !isDefined( self.pers[ "changed_class" ] ) )
	{
		self.pers[ "changed_class" ] = 0;
	}
	self.lastkilltime = 0;
	self.cur_death_streak = 0;
	self disabledeathstreak();
	self.death_streak = 0;
	self.kill_streak = 0;
	self.gametype_kill_streak = 0;
	self.spawnqueueindex = -1;
	self.deathtime = 0;
	if ( level.onlinegame )
	{
		self.death_streak = self getdstat( "HighestStats", "death_streak" );
		self.kill_streak = self getdstat( "HighestStats", "kill_streak" );
		self.gametype_kill_streak = self maps/mp/gametypes/_persistence::statgetwithgametype( "kill_streak" );
	}
	self.lastgrenadesuicidetime = -1;
	self.teamkillsthisround = 0;
	if ( isDefined( level.livesdonotreset ) || !level.livesdonotreset && !isDefined( self.pers[ "lives" ] ) )
	{
		self.pers[ "lives" ] = level.numlives;
	}
	if ( !level.teambased )
	{
	}
	self.hasspawned = 0;
	self.waitingtospawn = 0;
	self.wantsafespawn = 0;
	self.deathcount = 0;
	self.wasaliveatmatchstart = 0;
	self thread maps/mp/_flashgrenades::monitorflash();
	level.players[ level.players.size ] = self;
	if ( level.splitscreen )
	{
		setdvar( "splitscreen_playerNum", level.players.size );
	}
	if ( game[ "state" ] == "postgame" )
	{
		self.pers[ "needteam" ] = 1;
		self.pers[ "team" ] = "spectator";
		self.team = "spectator";
		self setclientuivisibilityflag( "hud_visible", 0 );
		self [[ level.spawnintermission ]]();
		self closemenu();
		self closeingamemenu();
		profilelog_endtiming( 4, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
		return;
	}
	if ( ( level.rankedmatch || level.wagermatch ) && !isDefined( self.pers[ "lossAlreadyReported" ] ) || level.leaguematch && !isDefined( self.pers[ "lossAlreadyReported" ] ) )
	{
		if ( level.leaguematch )
		{
			self recordleaguepreloser();
		}
		else
		{
			maps/mp/gametypes/_globallogic_score::updatelossstats( self );
		}
		self.pers[ "lossAlreadyReported" ] = 1;
	}
	if ( !isDefined( self.pers[ "winstreakAlreadyCleared" ] ) )
	{
		self maps/mp/gametypes/_globallogic_score::backupandclearwinstreaks();
		self.pers[ "winstreakAlreadyCleared" ] = 1;
	}
	if ( self istestclient() )
	{
		self.pers[ "isBot" ] = 1;
	}
	if ( level.rankedmatch || level.leaguematch )
	{
		self maps/mp/gametypes/_persistence::setafteractionreportstat( "demoFileID", "0" );
	}
	level endon( "game_ended" );
	if ( isDefined( level.hostmigrationtimer ) )
	{
		self thread maps/mp/gametypes/_hostmigration::hostmigrationtimerthink();
	}
	if ( level.oldschool )
	{
		self.pers["class"] = undefined;
		self.class = self.pers[ "class" ];
	}
	if ( isDefined( self.pers[ "team" ] ) )
	{
		self.team = self.pers[ "team" ];
	}
	if ( isDefined( self.pers[ "class" ] ) )
	{
		self.class = self.pers[ "class" ];
	}
	if ( !isDefined( self.pers[ "team" ] ) || isDefined( self.pers[ "needteam" ] ) )
	{
		self.pers[ "team" ] = "spectator";
		self.team = "spectator";
		self.sessionstate = "dead";
		self maps/mp/gametypes/_globallogic_ui::updateobjectivetext();
		[[ level.spawnspectator ]]();
		[[ level.autoassign ]]( 0 );
		if ( level.rankedmatch || level.leaguematch )
		{
			self thread maps/mp/gametypes/_globallogic_spawn::kickifdontspawn();
		}
		if ( self.pers[ "team" ] == "spectator" )
		{
			self.sessionteam = "spectator";
			if ( !level.teambased )
			{
				self.ffateam = "spectator";
			}
			self thread spectate_player_watcher();
		}
		if ( level.teambased )
		{
			self.sessionteam = self.pers[ "team" ];
			if ( !isalive( self ) )
			{
				self.statusicon = "hud_status_dead";
			}
			self thread maps/mp/gametypes/_spectating::setspectatepermissions();
		}
	}
	else if ( self.pers[ "team" ] == "spectator" )
	{
		self setclientscriptmainmenu( game[ "menu_class" ] );
		[[ level.spawnspectator ]]();
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		if ( !level.teambased )
		{
			self.ffateam = "spectator";
		}
		self thread spectate_player_watcher();
	}
	else
	{
		self.sessionteam = self.pers[ "team" ];
		self.sessionstate = "dead";
		if ( !level.teambased )
		{
			self.ffateam = self.pers[ "team" ];
		}
		self maps/mp/gametypes/_globallogic_ui::updateobjectivetext();
		[[ level.spawnspectator ]]();
		if ( maps/mp/gametypes/_globallogic_utils::isvalidclass( self.pers[ "class" ] ) )
		{
			self thread [[ level.spawnclient ]]();
		}
		else
		{
			self maps/mp/gametypes/_globallogic_ui::showmainmenuforteam();
		}
		self thread maps/mp/gametypes/_spectating::setspectatepermissions();
	}
	if ( self.sessionteam != "spectator" )
	{
		self thread maps/mp/gametypes/_spawning::onspawnplayer_unified( 1 );
	}
	profilelog_endtiming( 4, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
	if ( isDefined( self.pers[ "isBot" ] ) )
	{
		return;
	}
}

spectate_player_watcher() //checked changed to match beta dump
{
	self endon( "disconnect" );
	if ( !level.splitscreen && !level.hardcoremode && getDvarInt( "scr_showperksonspawn" ) == 1 && game[ "state" ] != "postgame" && !isDefined( self.perkhudelem ) )
	{
		if ( level.perksenabled == 1 )
		{
			self maps/mp/gametypes/_hud_util::showperks();
		}
		self thread maps/mp/gametypes/_globallogic_ui::hideloadoutaftertime( 0 );
	}
	self.watchingactiveclient = 1;
	self.waitingforplayerstext = undefined;
	while ( 1 )
	{
		if ( self.pers[ "team" ] != "spectator" || level.gameended )
		{
			self maps/mp/gametypes/_hud_message::clearshoutcasterwaitingmessage();
			self freezecontrols( 0 );
			self.watchingactiveclient = 0;
			return;
		}
		else 
		{
			count = 0;
			for ( i = 0; i < level.players.size; i++ )
			{
				if ( level.players[ i ].team != "spectator" )
				{
					count++;
					break;
				}
			}
			if ( count > 0 )
			{
				if ( !self.watchingactiveclient )
				{
					self maps/mp/gametypes/_hud_message::clearshoutcasterwaitingmessage();
					self freezecontrols( 0 );
				}
				self.watchingactiveclient = 1;
			}
			else
			{
				if ( self.watchingactiveclient )
				{
					[[ level.onspawnspectator ]]();
					self freezecontrols( 1 );
					self maps/mp/gametypes/_hud_message::setshoutcasterwaitingmessage();
				}
				self.watchingactiveclient = 0;
			}
			wait 0.5;
		}
	}
}

callback_playermigrated() //checked matches cerberus output
{
	/*
/#
	println( "Player " + self.name + " finished migrating at time " + getTime() );
#/
	*/
	if ( is_true( self.connected ) )
	{
		self maps/mp/gametypes/_globallogic_ui::updateobjectivetext();
	}
	level.hostmigrationreturnedplayercount++;
	if ( level.hostmigrationreturnedplayercount >= ( ( level.players.size * 2 ) / 3 ) )
	{
		/*
/#
		println( "2/3 of players have finished migrating" );
#/
		*/
		level notify( "hostmigration_enoughplayers" );
	}
}

callback_playerdisconnect() //checked changed to match cerberus output
{
	profilelog_begintiming( 5, "ship" );
	if ( game[ "state" ] != "postgame" && !level.gameended )
	{
		gamelength = maps/mp/gametypes/_globallogic::getgamelength();
		self maps/mp/gametypes/_globallogic::bbplayermatchend( gamelength, "MP_PLAYER_DISCONNECT", 0 );
	}
	self removeplayerondisconnect();
	if ( level.splitscreen )
	{
		players = level.players;
		if ( players.size <= 1 )
		{
			level thread maps/mp/gametypes/_globallogic::forceend();
		}
		setdvar( "splitscreen_playerNum", players.size );
	}
	if ( isDefined( self.score ) && isDefined( self.pers[ "team" ] ) )
	{
		self logstring( "team: score " + self.pers[ "team" ] + ":" + self.score );
		level.dropteam += 1;
	}
	[[ level.onplayerdisconnect ]]();
	lpselfnum = self getentitynumber();
	lpguid = self getguid();
	logprint( "Q;" + lpguid + ";" + lpselfnum + ";" + self.name + "\n" );
	self maps/mp/_gamerep::gamerepplayerdisconnected();
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[ entry ] == self )
		{
			while ( entry < ( level.players.size - 1 ) )
			{
				level.players[ entry ] = level.players[ entry + 1 ];
				entry++;
			}
			level.players[ entry ] = undefined;
			break;
		}
	}
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( isDefined( level.players[ entry ].pers[ "killed_players" ][ self.name ] ) )
		{
			level.players[ entry ].pers[ "killed_players" ][ self.name ] = undefined;
		}
		if ( isDefined( level.players[ entry ].killedplayerscurrent[ self.name ] ) )
		{
			level.players[ entry ].killedplayerscurrent[ self.name ] = undefined;
		}
		if ( isDefined( level.players[ entry ].pers[ "killed_by" ][ self.name ] ) )
		{
			level.players[ entry ].pers[ "killed_by" ][ self.name ] = undefined;
		}
		if ( isDefined( level.players[ entry ].pers[ "nemesis_tracking" ][ self.name ] ) )
		{
			level.players[ entry ].pers[ "nemesis_tracking" ][ self.name ] = undefined;
		}
		if ( level.players[ entry ].pers[ "nemesis_name" ] == self.name )
		{
			level.players[ entry ] choosenextbestnemesis();
		}
	}
	if ( level.gameended )
	{
		self maps/mp/gametypes/_globallogic::removedisconnectedplayerfromplacement();
	}
	level thread maps/mp/gametypes/_globallogic::updateteamstatus();
	profilelog_endtiming( 5, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
}

callback_playermelee( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit ) //checked matches cerberus output
{
	hit = 1;
	if ( level.teambased && self.team == eattacker.team )
	{
		if ( level.friendlyfire == 0 )
		{
			hit = 0;
		}
	}
	self finishmeleehit( eattacker, sweapon, vorigin, vdir, boneindex, shieldhit, hit );
}

choosenextbestnemesis() //checked changed to match cerberus output
{
	nemesisarray = self.pers[ "nemesis_tracking" ];
	nemesisarraykeys = getarraykeys( nemesisarray );
	nemesisamount = 0;
	nemesisname = "";
	if ( nemesisarraykeys.size > 0 )
	{
		for ( i = 0; i < nemesisarraykeys.size; i++ )
		{
			nemesisarraykey = nemesisarraykeys[ i ];
			if ( nemesisarray[ nemesisarraykey ] > nemesisamount )
			{
				nemesisname = nemesisarraykey;
				nemesisamount = nemesisarray[ nemesisarraykey ];
			}
		}
	}
	self.pers[ "nemesis_name" ] = nemesisname;
	if ( nemesisname != "" )
	{
		for ( playerindex = 0; playerindex < level.players.size; playerindex++ )
		{
			if ( level.players[ playerindex ].name == nemesisname )
			{
				nemesisplayer = level.players[ playerindex ];
				self.pers[ "nemesis_rank" ] = nemesisplayer.pers[ "rank" ];
				self.pers[ "nemesis_rankIcon" ] = nemesisplayer.pers[ "rankxp" ];
				self.pers[ "nemesis_xp" ] = nemesisplayer.pers[ "prestige" ];
				self.pers[ "nemesis_xuid" ] = nemesisplayer getxuid( 1 );
				break;
			}
		}
	}
	else 
	{
		self.pers[ "nemesis_xuid" ] = "";
	}
}

removeplayerondisconnect() //checked changed to match cerberus output
{
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[ entry ] == self )
		{
			while ( entry < ( level.players.size - 1 ) )
			{
				level.players[ entry ] = level.players[ entry + 1 ];
				entry++;
			}
			level.players[ entry ] = undefined;
			break;
		}
	}
}

custom_gamemodes_modified_damage( victim, eattacker, idamage, smeansofdeath, sweapon, einflictor, shitloc ) //matches cerberus output
{
	if ( level.onlinegame && !sessionmodeisprivate() )
	{
		return idamage;
	}
	if ( isDefined( eattacker ) && isDefined( eattacker.damagemodifier ) )
	{
		idamage *= eattacker.damagemodifier;
	}
	if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" )
	{
		idamage = int( idamage * level.bulletdamagescalar );
	}
	return idamage;
}

figureoutattacker( eattacker ) //checked changed to match cerberus output
{
	if ( isDefined( eattacker ) )
	{
		if ( isai( eattacker ) && isDefined( eattacker.script_owner ) )
		{
			team = self.team;
			if ( isai( self ) && isDefined( self.aiteam ) )
			{
				team = self.aiteam;
			}
			if ( eattacker.script_owner.team != team )
			{
				eattacker = eattacker.script_owner;
			}
		}
		if ( eattacker.classname == "script_vehicle" && isDefined( eattacker.owner ) )
		{
			eattacker = eattacker.owner;
		}
		else if ( eattacker.classname == "auto_turret" && isDefined( eattacker.owner ) )
		{
			eattacker = eattacker.owner;
		}
	}
	return eattacker;
}

figureoutweapon( sweapon, einflictor ) //checked changed to match cerberus output
{
	if ( sweapon == "none" && isDefined( einflictor ) )
	{
		if ( isDefined( einflictor.targetname ) && einflictor.targetname == "explodable_barrel" )
		{
			sweapon = "explodable_barrel_mp";
		}
		else if ( isDefined( einflictor.destructible_type ) && issubstr( einflictor.destructible_type, "vehicle_" ) )
		{
			sweapon = "destructible_car_mp";
		}
	}
	return sweapon;
}

isplayerimmunetokillstreak( eattacker, sweapon ) //checked matches cerberus output
{
	if ( level.hardcoremode )
	{
		return 0;
	}
	if ( !isDefined( eattacker ) )
	{
		return 0;
	}
	if ( self != eattacker )
	{
		return 0;
	}
	if ( sweapon != "straferun_gun_mp" && sweapon != "straferun_rockets_mp" )
	{
		return 0;
	}
	return 1;
}

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked partially changed to match beta dump changed at own discretion
{
	profilelog_begintiming( 6, "ship" );
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	if ( self.sessionteam == "spectator" )
	{
		return;
	}
	if ( !is_true( self.candocombat ) )
	{
		return;
	}
	if ( isDefined( eattacker ) && isplayer( eattacker ) && !is_true( eattacker.candocombat ) )
	{
		return;
	}
	if ( isDefined( level.hostmigrationtimer ) )
	{
		return;
	}
	if ( sweapon == "ai_tank_drone_gun_mp" || sweapon == "ai_tank_drone_rocket_mp" && !level.hardcoremode )
	{
		if ( isDefined( eattacker ) && eattacker == self )
		{
			if ( isDefined( einflictor ) && isDefined( einflictor.from_ai ) )
			{
				return;
			}
		}
		if ( isDefined( eattacker ) && isDefined( eattacker.owner ) && eattacker.owner == self )
		{
			return;
		}
	}
	if ( sweapon == "emp_grenade_mp" )
	{
		if ( self hasperk( "specialty_immuneemp" ) )
		{
			return;
		}
		self notify( "emp_grenaded", eattacker );
	}
	if ( isDefined( eattacker ) )
	{
		idamage = maps/mp/gametypes/_class::cac_modified_damage( self, eattacker, idamage, smeansofdeath, sweapon, einflictor, shitloc );
	}
	idamage = custom_gamemodes_modified_damage( self, eattacker, idamage, smeansofdeath, sweapon, einflictor, shitloc );
	idamage = int( idamage );
	self.idflags = idflags;
	self.idflagstime = getTime();
	eattacker = figureoutattacker( eattacker );
	pixbeginevent( "PlayerDamage flags/tweaks" );
	if ( !isDefined( vdir ) )
	{
		idflags |= level.idflags_no_knockback;
	}
	friendly = 0;
	if ( self.health != self.maxhealth )
	{
		self notify( "snd_pain_player" );
	}
	if ( isDefined( einflictor ) && isDefined( einflictor.script_noteworthy ) )
	{
		if ( einflictor.script_noteworthy == "ragdoll_now" )
		{
			smeansofdeath = "MOD_FALLING";
		}
		if ( isDefined( level.overrideweaponfunc ) )
		{
			sweapon = [[ level.overrideweaponfunc ]]( sweapon, einflictor.script_noteworthy );
		}
	}
	if ( maps/mp/gametypes/_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) && isplayer( eattacker ) )
	{
		smeansofdeath = "MOD_HEAD_SHOT";
	}
	if ( level.onplayerdamage != maps/mp/gametypes/_globallogic::blank )
	{
		modifieddamage = [[ level.onplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		if ( isDefined( modifieddamage ) )
		{
			if ( modifieddamage <= 0 )
			{
				return;
			}
			idamage = modifieddamage;
		}
	}
	if ( level.onlyheadshots )
	{
		if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" )
		{
			return;
		}
		else if ( smeansofdeath == "MOD_HEAD_SHOT" )
		{
			idamage = 150;
		}
	}
	if ( self maps/mp/_vehicles::player_is_occupant_invulnerable( smeansofdeath ) )
	{
		return;
	}
	if ( isDefined( eattacker ) && isplayer( eattacker ) && self.team != eattacker.team )
	{
		self.lastattackweapon = sweapon;
	}
	sweapon = figureoutweapon( sweapon, einflictor );
	pixendevent();
	if ( idflags & level.idflags_penetration && isplayer( eattacker ) && eattacker hasperk( "specialty_bulletpenetration" ) )
	{
		self thread maps/mp/gametypes/_battlechatter_mp::perkspecificbattlechatter( "deepimpact", 1 );
	}
	if ( isplayer( eattacker ) && self isenemyplayer( eattacker ) == 0 )
	{
		attackerishittingteammate = 1;
	}
	else
	{
		attackerishittingteammate = 0;
	}
	if ( shitloc == "riotshield" )
	{
		if ( attackerishittingteammate && level.friendlyfire == 0 )
		{
			return;
		}
		if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) && !attackerishittingteammate )
		{
			if ( self.hasriotshieldequipped )
			{
				if ( isplayer( eattacker ) )
				{
					eattacker.lastattackedshieldplayer = self;
					eattacker.lastattackedshieldtime = getTime();
				}
				previous_shield_damage = self.shielddamageblocked;
				self.shielddamageblocked += idamage;
				if ( ( self.shielddamageblocked % 400 ) < ( previous_shield_damage % 400 ) )
				{
					score_event = "shield_blocked_damage";
					if ( self.shielddamageblocked > 2000 )
					{
						score_event = "shield_blocked_damage_reduced";
					}
					if ( isDefined( level.scoreinfo[ score_event ][ "value" ] ) )
					{
						self addweaponstat( "riotshield_mp", "score_from_blocked_damage", level.scoreinfo[ score_event ][ "value" ] );
					}
					thread maps/mp/_scoreevents::processscoreevent( score_event, self );
				}
			}
		}
		if ( idflags & level.idflags_shield_explosive_impact )
		{
			shitloc = "none";
			if ( idflags & level.idflags_shield_explosive_impact_huge )
			{
				idamage *= 0;
			}
		}
		else if ( idflags & level.idflags_shield_explosive_splash )
		{
			if ( isDefined( einflictor ) && isDefined( einflictor.stucktoplayer ) && einflictor.stucktoplayer == self )
			{
				idamage = 101;
			}
			shitloc = "none";
		}
		else
		{
			return;
		}
	}
	if ( idflags & level.idflags_no_protection )
	{
		if ( ( smeansofdeath == "MOD_GAS" || maps/mp/gametypes/_class::isexplosivedamage( undefined, smeansofdeath ) ) && isDefined( einflictor ) )
		{
			if ( ( einflictor.classname == "grenade" || sweapon == "tabun_gas_mp" ) && ( self.lastspawntime + 3500 ) > getTime() && distancesquared( einflictor.origin, self.lastspawnpoint.origin ) < 62500 )
			{
				return;
			}
			if ( self isplayerimmunetokillstreak( eattacker, sweapon ) )
			{
				return;
			}
			self.explosiveinfo = [];
			self.explosiveinfo[ "damageTime" ] = getTime();
			self.explosiveinfo[ "damageId" ] = einflictor getentitynumber();
			self.explosiveinfo[ "originalOwnerKill" ] = 0;
			self.explosiveinfo[ "bulletPenetrationKill" ] = 0;
			self.explosiveinfo[ "chainKill" ] = 0;
			self.explosiveinfo[ "damageExplosiveKill" ] = 0;
			self.explosiveinfo[ "chainKill" ] = 0;
			self.explosiveinfo[ "cookedKill" ] = 0;
			self.explosiveinfo[ "weapon" ] = sweapon;
			self.explosiveinfo[ "originalowner" ] = einflictor.originalowner;
			isfrag = sweapon == "frag_grenade_mp";
			if ( isDefined( eattacker ) && eattacker != self )
			{
				if ( ( sweapon == "satchel_charge_mp" || sweapon == "claymore_mp" ) && isDefined( eattacker ) && isDefined( einflictor.owner ) || sweapon == "bouncingbetty_mp" && isDefined( eattacker ) && isDefined( einflictor.owner ) )
				{
					self.explosiveinfo[ "originalOwnerKill" ] = einflictor.owner == self;
					self.explosiveinfo[ "damageExplosiveKill" ] = isDefined( einflictor.wasdamaged );
					self.explosiveinfo[ "chainKill" ] = isDefined( einflictor.waschained );
					self.explosiveinfo[ "wasJustPlanted" ] = isDefined( einflictor.wasjustplanted );
					self.explosiveinfo[ "bulletPenetrationKill" ] = isDefined( einflictor.wasdamagedfrombulletpenetration );
					self.explosiveinfo[ "cookedKill" ] = 0;
				}
				if ( sweapon == "sticky_grenade_mp" || sweapon == "explosive_bolt_mp" && isDefined( einflictor ) && isDefined( einflictor.stucktoplayer ) )
				{
					self.explosiveinfo[ "stuckToPlayer" ] = einflictor.stucktoplayer;
				}
				if ( sweapon == "proximity_grenade_mp" || sweapon == "proximity_grenade_aoe_mp" )
				{
					self.laststunnedby = eattacker;
					self.laststunnedtime = self.idflagstime;
				}
				if ( isDefined( eattacker.lastgrenadesuicidetime ) && eattacker.lastgrenadesuicidetime >= ( getTime() - 50 ) && isfrag )
				{
					self.explosiveinfo[ "suicideGrenadeKill" ] = 1;
				}
				else
				{
					self.explosiveinfo[ "suicideGrenadeKill" ] = 0;
				}
			}
			if ( isfrag )
			{
				self.explosiveinfo[ "cookedKill" ] = isDefined( einflictor.iscooked );
				self.explosiveinfo[ "throwbackKill" ] = isDefined( einflictor.threwback );
			}
			if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
			{
				self maps/mp/gametypes/_globallogic_score::setinflictorstat( einflictor, eattacker, sweapon );
			}
		}
		if ( smeansofdeath == "MOD_IMPACT" && isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
		{
			if ( sweapon != "knife_ballistic_mp" )
			{
				self maps/mp/gametypes/_globallogic_score::setinflictorstat( einflictor, eattacker, sweapon );
			}
			if ( sweapon == "hatchet_mp" && isDefined( einflictor ) )
			{
				self.explosiveinfo[ "projectile_bounced" ] = isDefined( einflictor.bounced );
			}
		}
		if ( isplayer( eattacker ) )
		{
			eattacker.pers[ "participation" ]++;
		}
		prevhealthratio = self.health / self.maxhealth;
		if ( level.teambased && isplayer( eattacker ) && self != eattacker && self.team == eattacker.team )
		{
			pixmarker( "BEGIN: PlayerDamage player" );
			if ( level.friendlyfire == 0 )
			{
				if ( sweapon == "artillery_mp" || sweapon == "airstrike_mp" || sweapon == "napalm_mp" || sweapon == "mortar_mp" )
				{
					self damageshellshockandrumble( eattacker, einflictor, sweapon, smeansofdeath, idamage );
				}
				return;
			}
			else if ( level.friendlyfire == 1 )
			{
				if ( idamage < 1 )
				{
					idamage = 1;
				}
				if ( level.friendlyfiredelay && level.friendlyfiredelaytime >= ( ( getTime() - level.starttime - level.discardtime ) / 1000 ) )
				{
					eattacker.lastdamagewasfromenemy = 0;
					eattacker.friendlydamage = 1;
					eattacker finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
					eattacker.friendlydamage = undefined;
				}
				else
				{
					self.lastdamagewasfromenemy = 0;
					self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
				}
			}
			else if ( level.friendlyfire == 2 && isalive( eattacker ) )
			{
				idamage = int( idamage * 0.5 );
				if ( idamage < 1 )
				{
					idamage = 1;
				}
				eattacker.lastdamagewasfromenemy = 0;
				eattacker.friendlydamage = 1;
				eattacker finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
				eattacker.friendlydamage = undefined;
			}
			else if ( level.friendlyfire == 3 && isalive( eattacker ) )
			{
				idamage = int( idamage * 0.5 );
				if ( idamage < 1 )
				{
					idamage = 1;
				}
				self.lastdamagewasfromenemy = 0;
				eattacker.lastdamagewasfromenemy = 0;
				self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
				eattacker.friendlydamage = 1;
				eattacker finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
				eattacker.friendlydamage = undefined;
			}
			friendly = 1;
			pixmarker( "END: PlayerDamage player" );
		}
		else
		{
			if ( idamage < 1 )
			{
				idamage = 1;
			}
			if ( isDefined( eattacker ) && isplayer( eattacker ) && allowedassistweapon( sweapon ) )
			{
				self trackattackerdamage( eattacker, idamage, smeansofdeath, sweapon );
			}
			giveinflictorownerassist( eattacker, einflictor, idamage, smeansofdeath, sweapon );
			if ( isDefined( eattacker ) )
			{
				level.lastlegitimateattacker = eattacker;
			}
			if ( isDefined( eattacker ) && isplayer( eattacker ) && isDefined( sweapon ) && !issubstr( smeansofdeath, "MOD_MELEE" ) )
			{
				eattacker thread maps/mp/gametypes/_weapons::checkhit( sweapon );
			}
			if ( ( smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" ) && isDefined( einflictor.iscooked ) )
			{
				self.wascooked = getTime();
			}
			else
			{
				self.wascooked = undefined;
			}
			if ( isDefined( eattacker ) && eattacker != self )
			{
				self.lastdamagewasfromenemy = 1;
			}
			else
			{
				self.lastdamagewasfromenemy = 0;
			}
			if ( self.lastdamagewasfromenemy )
			{
				if ( isplayer( eattacker ) )
				{
					if ( isDefined( eattacker.damagedplayers[ self.clientid ] ) == 0 )
					{
						eattacker.damagedplayers[ self.clientid ] = spawnstruct();
					}
					eattacker.damagedplayers[ self.clientid ].time = getTime();
					eattacker.damagedplayers[ self.clientid ].entity = self;
				}
			}
			self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		}
		if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
		{
			if ( dodamagefeedback( sweapon, einflictor, idamage, smeansofdeath ) )
			{
				if ( idamage > 0 )
				{
					if ( self.health > 0 )
					{
						perkfeedback = doperkfeedback( self, sweapon, smeansofdeath, einflictor );
					}
					eattacker thread maps/mp/gametypes/_damagefeedback::updatedamagefeedback( smeansofdeath, einflictor, perkfeedback );
				}
			}
		}
		self.hasdonecombat = 1;
	}
	if ( isDefined( eattacker ) && eattacker != self && !friendly )
	{
		level.usestartspawns = 0;
	}
	pixbeginevent( "PlayerDamage log" );
	/*
/#
	if ( getDvarInt( "g_debugDamage" ) )
	{
		println( "client:" + self getentitynumber() + " health:" + self.health + " attacker:" + eattacker.clientid + " inflictor is player:" + isplayer( einflictor ) + " damage:" + idamage + " hitLoc:" + shitloc );
#/
	}
	*/
	if ( self.sessionstate != "dead" )
	{
		lpselfnum = self getentitynumber();
		lpselfname = self.name;
		lpselfteam = self.team;
		lpselfguid = self getguid();
		lpattackerteam = "";
		lpattackerorigin = ( 0, 0, 0 );
		if ( isplayer( eattacker ) )
		{
			lpattacknum = eattacker getentitynumber();
			lpattackguid = eattacker getguid();
			lpattackname = eattacker.name;
			lpattackerteam = eattacker.team;
			lpattackerorigin = eattacker.origin;
			bbprint( "mpattacks", "gametime %d attackerspawnid %d attackerweapon %s attackerx %d attackery %d attackerz %d victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", getTime(), getplayerspawnid( eattacker ), sweapon, lpattackerorigin, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 0 );
		}
		else
		{
			lpattacknum = -1;
			lpattackguid = "";
			lpattackname = "";
			lpattackerteam = "world";
			bbprint( "mpattacks", "gametime %d attackerweapon %s victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", getTime(), sweapon, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 0 );
		}
		logprint( "D;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sweapon + ";" + idamage + ";" + smeansofdeath + ";" + shitloc + "\n" );
	}
	pixendevent();
	profilelog_endtiming( 6, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
}

resetattackerlist() //checked matches cerberus output
{
	self.attackers = [];
	self.attackerdata = [];
	self.attackerdamage = [];
	self.firsttimedamaged = 0;
}

dodamagefeedback( sweapon, einflictor, idamage, smeansofdeath ) //checked matches cerberus output
{
	if ( !isDefined( sweapon ) )
	{
		return 0;
	}
	if ( level.allowhitmarkers == 0 )
	{
		return 0;
	}
	if ( level.allowhitmarkers == 1 )
	{
		if ( isDefined( smeansofdeath ) && isDefined( idamage ) )
		{
			if ( istacticalhitmarker( sweapon, smeansofdeath, idamage ) )
			{
				return 0;
			}
		}
	}
	return 1;
}

istacticalhitmarker( sweapon, smeansofdeath, idamage ) //checked changed to match cerberus output 
{
	if ( isgrenade( sweapon ) )
	{
		if ( sweapon == "willy_pete_mp" )
		{
			if ( smeansofdeath == "MOD_GRENADE_SPLASH" )
			{
				return 1;
			}
		}
		else if ( idamage == 1 )
		{
			return 1;
		}
	}
	return 0;
}

doperkfeedback( player, sweapon, smeansofdeath, einflictor ) //checked changed to match cerberus output
{
	perkfeedback = undefined;
	hastacticalmask = maps/mp/gametypes/_class::hastacticalmask( player );
	hasflakjacket = player hasperk( "specialty_flakjacket" );
	isexplosivedamage = maps/mp/gametypes/_class::isexplosivedamage( sweapon, smeansofdeath );
	isflashorstundamage = maps/mp/gametypes/_weapon_utils::isflashorstundamage( sweapon, smeansofdeath );
	if ( isflashorstundamage && hastacticalmask )
	{
		perkfeedback = "tacticalMask";
	}
	else if ( isexplosivedamage && hasflakjacket && !isaikillstreakdamage( sweapon, einflictor ) )
	{
		perkfeedback = "flakjacket";
	}
	return perkfeedback;
}

isaikillstreakdamage( sweapon, einflictor ) //checked matches cerberus output
{
	switch( sweapon )
	{
		case "ai_tank_drone_rocket_mp":
			return isDefined( einflictor.firedbyai );
		case "missile_swarm_projectile_mp":
			return 1;
		case "planemortar_mp":
			return 1;
		case "chopper_minigun_mp":
			return 1;
		case "straferun_rockets_mp":
			return 1;
		case "littlebird_guard_minigun_mp":
			return 1;
		case "cobra_20mm_comlink_mp":
			return 1;
	}
	return 0;
}

finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked matches cerberus output dvar taken from beta dump
{
	pixbeginevent( "finishPlayerDamageWrapper" );
	if ( !level.console && idflags & level.idflags_penetration && isplayer( eattacker ) )
	{
		/*
/#
		println( "penetrated:" + self getentitynumber() + " health:" + self.health + " attacker:" + eattacker.clientid + " inflictor is player:" + isplayer( einflictor ) + " damage:" + idamage + " hitLoc:" + shitloc );
#/
		*/
		eattacker addplayerstat( "penetration_shots", 1 );
	}
	self finishplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( getDvar( "scr_csmode" ) != "" )
	{
		self shellshock( "damage_mp", 0.2 );
	}
	self damageshellshockandrumble( eattacker, einflictor, sweapon, smeansofdeath, idamage );
	pixendevent();
}

allowedassistweapon( weapon ) //checked matches cerberus output
{
	if ( !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( weapon ) )
	{
		return 1;
	}
	if ( maps/mp/killstreaks/_killstreaks::iskillstreakweaponassistallowed( weapon ) )
	{
		return 1;
	}
	return 0;
}

playerkilled_killstreaks( attacker, sweapon ) //checked matches cerberus output
{
	if ( !isDefined( self.switching_teams ) )
	{
		if ( isplayer( attacker ) && level.teambased && attacker != self && self.team == attacker.team )
		{
			self.pers[ "cur_kill_streak" ] = 0;
			self.pers[ "cur_total_kill_streak" ] = 0;
			self.pers[ "totalKillstreakCount" ] = 0;
			self.pers[ "killstreaksEarnedThisKillstreak" ] = 0;
			self setplayercurrentstreak( 0 );
		}
		else
		{
			self maps/mp/gametypes/_globallogic_score::incpersstat( "deaths", 1, 1, 1 );
			self.deaths = self maps/mp/gametypes/_globallogic_score::getpersstat( "deaths" );
			self updatestatratio( "kdratio", "kills", "deaths" );
			if ( self.pers[ "cur_kill_streak" ] > self.pers[ "best_kill_streak" ] )
			{
				self.pers[ "best_kill_streak" ] = self.pers[ "cur_kill_streak" ];
			}
			self.pers[ "kill_streak_before_death" ] = self.pers[ "cur_kill_streak" ];
			self.pers[ "cur_kill_streak" ] = 0;
			self.pers[ "cur_total_kill_streak" ] = 0;
			self.pers[ "totalKillstreakCount" ] = 0;
			self.pers[ "killstreaksEarnedThisKillstreak" ] = 0;
			self setplayercurrentstreak( 0 );
			self.cur_death_streak++;
			if ( self.cur_death_streak > self.death_streak )
			{
				if ( level.rankedmatch && !level.disablestattracking )
				{
					self setdstat( "HighestStats", "death_streak", self.cur_death_streak );
				}
				self.death_streak = self.cur_death_streak;
			}
			if ( self.cur_death_streak >= getDvarInt( "perk_deathStreakCountRequired" ) )
			{
				self enabledeathstreak();
			}
		}
	}
	else
	{
		self.pers[ "totalKillstreakCount" ] = 0;
		self.pers[ "killstreaksEarnedThisKillstreak" ] = 0;
	}
	if ( !sessionmodeiszombiesgame() && maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
	{
		level.globalkillstreaksdeathsfrom++;
	}
}

playerkilled_weaponstats( attacker, sweapon, smeansofdeath, wasinlaststand, lastweaponbeforedroppingintolaststand, inflictor ) //checked partially changed to match cerberus output see info.md
{
	if ( level.teambased && self.team != attacker.team && isplayer( attacker ) && attacker != self )
	{
		self addweaponstat( sweapon, "deaths", 1 );
		if ( wasinlaststand && isDefined( lastweaponbeforedroppingintolaststand ) )
		{
			weaponname = lastweaponbeforedroppingintolaststand;
		}
		else
		{
			weaponname = self.lastdroppableweapon;
		}
		if ( isDefined( weaponname ) )
		{
			self addweaponstat( weaponname, "deathsDuringUse", 1 );
		}
		if ( smeansofdeath != "MOD_FALLING" )
		{
			if ( sweapon == "explosive_bolt_mp" && isDefined( inflictor ) && isDefined( inflictor.ownerweaponatlaunch ) && inflictor.owneradsatlaunch )
			{
				attacker addweaponstat( inflictor.ownerweaponatlaunch, "kills", 1, attacker.class_num, 1 );
			}
			else
			{
				attacker addweaponstat( sweapon, "kills", 1, attacker.class_num );
			}
		}
		if ( smeansofdeath == "MOD_HEAD_SHOT" )
		{
			attacker addweaponstat( sweapon, "headshots", 1 );
		}
		if ( smeansofdeath == "MOD_PROJECTILE" )
		{
			attacker addweaponstat( sweapon, "direct_hit_kills", 1 );
		}
	}
	else if ( !level.teambased && isplayer( attacker ) && attacker != self )
	{
		self addweaponstat( sweapon, "deaths", 1 );
		if ( wasinlaststand && isDefined( lastweaponbeforedroppingintolaststand ) )
		{
			weaponname = lastweaponbeforedroppingintolaststand;
		}
		else
		{
			weaponname = self.lastdroppableweapon;
		}
		if ( isDefined( weaponname ) )
		{
			self addweaponstat( weaponname, "deathsDuringUse", 1 );
		}
		if ( smeansofdeath != "MOD_FALLING" )
		{
			if ( sweapon == "explosive_bolt_mp" && isDefined( inflictor ) && isDefined( inflictor.ownerweaponatlaunch ) && inflictor.owneradsatlaunch )
			{
				attacker addweaponstat( inflictor.ownerweaponatlaunch, "kills", 1, attacker.class_num, 1 );
			}
			else
			{
				attacker addweaponstat( sweapon, "kills", 1, attacker.class_num );
			}
		}
		if ( smeansofdeath == "MOD_HEAD_SHOT" )
		{
			attacker addweaponstat( sweapon, "headshots", 1 );
		}
		if ( smeansofdeath == "MOD_PROJECTILE" )
		{
			attacker addweaponstat( sweapon, "direct_hit_kills", 1 );
		}
	}
}

playerkilled_obituary( attacker, einflictor, sweapon, smeansofdeath ) //checked partially changed to match beta dump
{
	if ( isplayer( attacker ) || self isenemyplayer( attacker ) == 0 || isDefined( sweapon ) && maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
	{
		level notify( "reset_obituary_count" );
		level.lastobituaryplayercount = 0;
		level.lastobituaryplayer = undefined;
	}
	else
	{
		if ( isDefined( level.lastobituaryplayer ) && level.lastobituaryplayer == attacker )
		{
			level.lastobituaryplayercount++;
		}
		else
		{
			level notify( "reset_obituary_count" );
			level.lastobituaryplayer = attacker;
			level.lastobituaryplayercount = 1;
		}
		level thread maps/mp/_scoreevents::decrementlastobituaryplayercountafterfade();
		if ( level.lastobituaryplayercount >= 4 )
		{
			level notify( "reset_obituary_count" );
			level.lastobituaryplayercount = 0;
			level.lastobituaryplayer = undefined;
			self thread uninterruptedobitfeedkills( attacker, sweapon );
		}
	}
	overrideentitycamera = maps/mp/killstreaks/_killstreaks::shouldoverrideentitycameraindemo( attacker, sweapon );
	if ( level.teambased && isDefined( attacker.pers ) && self.team == attacker.team && smeansofdeath == "MOD_GRENADE" && level.friendlyfire == 0 )
	{
		obituary( self, self, sweapon, smeansofdeath );
		maps/mp/_demo::bookmark( "kill", getTime(), self, self, 0, einflictor, overrideentitycamera );
	}
	else
	{
		obituary( self, attacker, sweapon, smeansofdeath );
		maps/mp/_demo::bookmark( "kill", getTime(), self, attacker, 0, einflictor, overrideentitycamera );
	}
}

playerkilled_suicide( einflictor, attacker, smeansofdeath, sweapon, shitloc ) //checked matches cerberus output
{
	awardassists = 0;
	if ( isDefined( self.switching_teams ) )
	{
		if ( !level.teambased && isDefined( level.teams[ self.leaving_team ] ) && isDefined( level.teams[ self.joining_team ] ) && level.teams[ self.leaving_team ] != level.teams[ self.joining_team ] )
		{
			playercounts = self maps/mp/teams/_teams::countplayers();
			playercounts[ self.leaving_team ]--;

			playercounts[ self.joining_team ]++;
			if ( ( playercounts[ self.joining_team ] - playercounts[ self.leaving_team ] ) > 1 )
			{
				thread maps/mp/_scoreevents::processscoreevent( "suicide", self );
				self thread maps/mp/gametypes/_rank::giverankxp( "suicide" );
				self maps/mp/gametypes/_globallogic_score::incpersstat( "suicides", 1 );
				self.suicides = self maps/mp/gametypes/_globallogic_score::getpersstat( "suicides" );
			}
		}
	}
	else
	{
		thread maps/mp/_scoreevents::processscoreevent( "suicide", self );
		self maps/mp/gametypes/_globallogic_score::incpersstat( "suicides", 1 );
		self.suicides = self maps/mp/gametypes/_globallogic_score::getpersstat( "suicides" );
		if ( smeansofdeath == "MOD_SUICIDE" && shitloc == "none" && self.throwinggrenade )
		{
			self.lastgrenadesuicidetime = getTime();
		}
		if ( level.maxsuicidesbeforekick > 0 && level.maxsuicidesbeforekick <= self.suicides )
		{
			self notify( "teamKillKicked" );
			self suicidekick();
		}
		thread maps/mp/gametypes/_battlechatter_mp::onplayersuicideorteamkill( self, "suicide" );
		awardassists = 1;
		self.suicide = 1;
	}
	if ( isDefined( self.friendlydamage ) )
	{
		self iprintln( &"MP_FRIENDLY_FIRE_WILL_NOT" );
		if ( level.teamkillpointloss )
		{
			scoresub = self [[ level.getteamkillscore ]]( einflictor, attacker, smeansofdeath, sweapon );
			score = maps/mp/gametypes/_globallogic_score::_getplayerscore( attacker ) - scoresub;
			if ( score < 0 )
			{
				score = 0;
			}
			maps/mp/gametypes/_globallogic_score::_setplayerscore( attacker, score );
		}
	}
	return awardassists;
}

playerkilled_teamkill( einflictor, attacker, smeansofdeath, sweapon, shitloc ) //checked matches cerberus output
{
	thread maps/mp/_scoreevents::processscoreevent( "team_kill", attacker );
	self.teamkilled = 1;
	if ( !ignoreteamkills( sweapon, smeansofdeath ) )
	{
		teamkill_penalty = self [[ level.getteamkillpenalty ]]( einflictor, attacker, smeansofdeath, sweapon );
		attacker maps/mp/gametypes/_globallogic_score::incpersstat( "teamkills_nostats", teamkill_penalty, 0 );
		attacker maps/mp/gametypes/_globallogic_score::incpersstat( "teamkills", 1 );
		attacker.teamkillsthisround++;
		if ( level.teamkillpointloss )
		{
			scoresub = self [[ level.getteamkillscore ]]( einflictor, attacker, smeansofdeath, sweapon );
			score = maps/mp/gametypes/_globallogic_score::_getplayerscore( attacker ) - scoresub;
			if ( score < 0 )
			{
				score = 0;
			}
			maps/mp/gametypes/_globallogic_score::_setplayerscore( attacker, score );
		}
		if ( maps/mp/gametypes/_globallogic_utils::gettimepassed() < 5000 )
		{
			teamkilldelay = 1;
		}
		else if ( attacker.pers[ "teamkills_nostats" ] > 1 && maps/mp/gametypes/_globallogic_utils::gettimepassed() < ( 8000 + ( attacker.pers[ "teamkills_nostats" ] * 1000 ) ) )
		{
			teamkilldelay = 1;
		}
		else
		{
			teamkilldelay = attacker teamkilldelay();
		}
		if ( teamkilldelay > 0 )
		{
			attacker.teamkillpunish = 1;
			attacker thread wait_and_suicide();
			if ( attacker shouldteamkillkick( teamkilldelay ) )
			{
				attacker notify( "teamKillKicked" );
				attacker teamkillkick();
			}
			attacker thread reduceteamkillsovertime();
		}
		if ( isplayer( attacker ) )
		{
			thread maps/mp/gametypes/_battlechatter_mp::onplayersuicideorteamkill( attacker, "teamkill" );
		}
	}
}

wait_and_suicide() //checked matches cerberus output
{
	self endon( "disconnect" );
	self freezecontrolswrapper( 1 );
	wait 0.25;
	self suicide();
}

playerkilled_awardassists( einflictor, attacker, sweapon, lpattackteam ) //checked partially changed to match cerberus output see info.md
{
	pixbeginevent( "PlayerKilled assists" );
	if ( isDefined( self.attackers ) )
	{
		j = 0;
		while ( j < self.attackers.size )
		{
			player = self.attackers[ j ];
			if ( !isDefined( player ) )
			{
				j++;
				continue;
			}
			if ( player == attacker )
			{
				j++;
				continue;
			}
			if ( player.team != lpattackteam )
			{
				j++;
				continue;
			}
			damage_done = self.attackerdamage[ player.clientid ].damage;
			player thread maps/mp/gametypes/_globallogic_score::processassist( self, damage_done, self.attackerdamage[ player.clientid ].weapon );
			j++;
		}
	}
	if ( level.teambased )
	{
		self maps/mp/gametypes/_globallogic_score::processkillstreakassists( attacker, einflictor, sweapon );
	}
	if ( isDefined( self.lastattackedshieldplayer ) && isDefined( self.lastattackedshieldtime ) && self.lastattackedshieldplayer != attacker )
	{
		if ( ( getTime() - self.lastattackedshieldtime ) < 4000 )
		{
			self.lastattackedshieldplayer thread maps/mp/gametypes/_globallogic_score::processshieldassist( self );
		}
	}
	pixendevent();
}

playerkilled_kill( einflictor, attacker, smeansofdeath, sweapon, shitloc ) //checked changed to match cerberus output
{
	maps/mp/gametypes/_globallogic_score::inctotalkills( attacker.team );
	attacker thread maps/mp/gametypes/_globallogic_score::givekillstats( smeansofdeath, sweapon, self );
	if ( isalive( attacker ) )
	{
		pixbeginevent( "killstreak" );
		if ( !isDefined( einflictor ) || !isDefined( einflictor.requireddeathcount ) || attacker.deathcount == einflictor.requireddeathcount )
		{
			shouldgivekillstreak = maps/mp/killstreaks/_killstreaks::shouldgivekillstreak( sweapon );
			if ( shouldgivekillstreak )
			{
				attacker maps/mp/killstreaks/_killstreaks::addtokillstreakcount( sweapon );
			}
			attacker.pers[ "cur_total_kill_streak" ]++;
			attacker setplayercurrentstreak( attacker.pers[ "cur_total_kill_streak" ] );
			if ( isDefined( level.killstreaks ) && shouldgivekillstreak )
			{
				attacker.pers[ "cur_kill_streak" ]++;
				if ( attacker.pers[ "cur_kill_streak" ] >= 2 )
				{
					if ( attacker.pers[ "cur_kill_streak" ] == 10 )
					{
						attacker maps/mp/_challenges::killstreakten();
					}
					if ( attacker.pers[ "cur_kill_streak" ] <= 30 )
					{
						maps/mp/_scoreevents::processscoreevent( "killstreak_" + attacker.pers[ "cur_kill_streak" ], attacker, self, sweapon );
					}
					else
					{
						maps/mp/_scoreevents::processscoreevent( "killstreak_more_than_30", attacker, self, sweapon );
					}
				}
				if ( !isDefined( level.usingmomentum ) || !level.usingmomentum )
				{
					attacker thread maps/mp/killstreaks/_killstreaks::givekillstreakforstreak();
				}
			}
		}
		if ( isplayer( attacker ) )
		{
			self thread maps/mp/gametypes/_battlechatter_mp::onplayerkillstreak( attacker );
		}
		pixendevent();
	}
	if ( attacker.pers[ "cur_kill_streak" ] > attacker.kill_streak )
	{
		if ( level.rankedmatch && !level.disablestattracking )
		{
			attacker setdstat( "HighestStats", "kill_streak", attacker.pers[ "totalKillstreakCount" ] );
		}
		attacker.kill_streak = attacker.pers[ "cur_kill_streak" ];
	}
	if ( attacker.pers[ "cur_kill_streak" ] > attacker.gametype_kill_streak )
	{
		attacker maps/mp/gametypes/_persistence::statsetwithgametype( "kill_streak", attacker.pers[ "cur_kill_streak" ] );
		attacker.gametype_kill_streak = attacker.pers[ "cur_kill_streak" ];
	}
	killstreak = maps/mp/killstreaks/_killstreaks::getkillstreakforweapon( sweapon );
	if ( isDefined( killstreak ) )
	{
		if ( maps/mp/_scoreevents::isregisteredevent( killstreak ) )
		{
			maps/mp/_scoreevents::processscoreevent( killstreak, attacker, self, sweapon );
		}
		if ( sweapon == "straferun_gun_mp" || sweapon == "straferun_rockets_mp" )
		{
			attacker maps/mp/killstreaks/_straferun::addstraferunkill();
		}
	}
	else if ( smeansofdeath == "MOD_MELEE" && level.gametype == "gun" )
	{
	}
	else
	{
		maps/mp/_scoreevents::processscoreevent( "kill", attacker, self, sweapon );
	}
	if ( smeansofdeath == "MOD_HEAD_SHOT" )
	{
		maps/mp/_scoreevents::processscoreevent( "headshot", attacker, self, sweapon );
	}
	else if ( smeansofdeath == "MOD_MELEE" )
	{
		if ( sweapon == "riotshield_mp" )
		{
			maps/mp/_scoreevents::processscoreevent( "melee_kill_with_riot_shield", attacker, self, sweapon );
			if ( isDefined( attacker.class_num ) )
			{
				primaryweaponnum = attacker getloadoutitem( attacker.class_num, "primary" );
				secondaryweaponnum = attacker getloadoutitem( attacker.class_num, "secondary" );
				if ( primaryweaponnum && level.tbl_weaponids[ primaryweaponnum ][ "reference" ] == "riotshield" && !secondaryweaponnum || secondaryweaponnum && level.tbl_weaponids[ secondaryweaponnum ][ "reference" ] == "riotshield" && !primaryweaponnum )
				{
					attacker addweaponstat( sweapon, "NoLethalKills", 1 );
				}
			}
		}
		else
		{
			maps/mp/_scoreevents::processscoreevent( "melee_kill", attacker, self, sweapon );
		}
	}
	attacker thread maps/mp/gametypes/_globallogic_score::trackattackerkill( self.name, self.pers[ "rank" ], self.pers[ "rankxp" ], self.pers[ "prestige" ], self getxuid( 1 ) );
	attackername = attacker.name;
	self thread maps/mp/gametypes/_globallogic_score::trackattackeedeath( attackername, attacker.pers[ "rank" ], attacker.pers[ "rankxp" ], attacker.pers[ "prestige" ], attacker getxuid( 1 ) );
	self thread maps/mp/_medals::setlastkilledby( attacker );
	attacker thread maps/mp/gametypes/_globallogic_score::inckillstreaktracker( sweapon );
	if ( level.teambased && attacker.team != "spectator" )
	{
		if ( isai( attacker ) )
		{
			maps/mp/gametypes/_globallogic_score::giveteamscore( "kill", attacker.aiteam, attacker, self );
		}
		else
		{
			maps/mp/gametypes/_globallogic_score::giveteamscore( "kill", attacker.team, attacker, self );
		}
	}
	scoresub = level.deathpointloss;
	if ( scoresub != 0 )
	{
		maps/mp/gametypes/_globallogic_score::_setplayerscore( self, maps/mp/gametypes/_globallogic_score::_getplayerscore( self ) - scoresub );
	}
	level thread playkillbattlechatter( attacker, sweapon, self );
}

callback_playerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked partially changed to match cerberus output changed at own discretion
{
	profilelog_begintiming( 7, "ship" );
	self endon( "spawned" );
	self notify( "killed_player" );
	if ( self.sessionteam == "spectator" )
	{
		return;
	}
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	self needsrevive( 0 );
	if ( isDefined( self.burning ) && self.burning == 1 )
	{
		self setburn( 0 );
	}
	self.suicide = 0;
	self.teamkilled = 0;
	if ( isDefined( level.takelivesondeath ) && level.takelivesondeath == 1 )
	{
		if ( self.pers[ "lives" ] )
		{
			self.pers[ "lives" ]--;

			if ( self.pers[ "lives" ] == 0 )
			{
				level notify( "player_eliminated" );
				self notify( "player_eliminated" );
			}
		}
	}
	self thread flushgroupdialogonplayer( "item_destroyed" );
	sweapon = updateweapon( einflictor, sweapon );
	pixbeginevent( "PlayerKilled pre constants" );
	wasinlaststand = 0;
	deathtimeoffset = 0;
	lastweaponbeforedroppingintolaststand = undefined;
	attackerstance = undefined;
	self.laststandthislife = undefined;
	self.vattackerorigin = undefined;
	if ( isDefined( self.uselaststandparams ) )
	{
		self.uselaststandparams = undefined;
		/*
/#
		assert( isDefined( self.laststandparams ) );
#/
		*/
		if ( !level.teambased || !isDefined( attacker ) || !isplayer( attacker ) || attacker.team != self.team || attacker == self )
		{
			einflictor = self.laststandparams.einflictor;
			attacker = self.laststandparams.attacker;
			attackerstance = self.laststandparams.attackerstance;
			idamage = self.laststandparams.idamage;
			smeansofdeath = self.laststandparams.smeansofdeath;
			sweapon = self.laststandparams.sweapon;
			vdir = self.laststandparams.vdir;
			shitloc = self.laststandparams.shitloc;
			self.vattackerorigin = self.laststandparams.vattackerorigin;
			deathtimeoffset = ( getTime() - self.laststandparams.laststandstarttime ) / 1000;
			self thread maps/mp/gametypes/_battlechatter_mp::perkspecificbattlechatter( "secondchance" );
			if ( isDefined( self.previousprimary ) )
			{
				wasinlaststand = 1;
				lastweaponbeforedroppingintolaststand = self.previousprimary;
			}
		}
		self.laststandparams = undefined;
	}
	bestplayer = undefined;
	bestplayermeansofdeath = undefined;
	obituarymeansofdeath = undefined;
	bestplayerweapon = undefined;
	obituaryweapon = sweapon;
	assistedsuicide = 0;
	if ( !isDefined( attacker ) || attacker.classname == "trigger_hurt" || attacker.classname == "worldspawn" || isDefined( attacker.ismagicbullet ) && attacker.ismagicbullet != 1 || attacker == self && isDefined( self.attackers ) )
	{
		if ( !isDefined( bestplayer ) )
		{
			i = 0;
			while ( i < self.attackers.size )
			{
				player = self.attackers[ i ];
				if ( !isDefined( player ) )
				{
					i++;
					continue;
				}
				if ( !isDefined( self.attackerdamage[ player.clientid ] ) || !isDefined( self.attackerdamage[ player.clientid ].damage ) )
				{
					i++;
					continue;
				}
				if ( player == self || level.teambased && player.team == self.team )
				{
					i++;
					continue;
				}
				if ( ( self.attackerdamage[ player.clientid ].lasttimedamaged + 2500 ) < getTime() )
				{
					i++;
					continue;
				}
				if ( !allowedassistweapon( self.attackerdamage[ player.clientid ].weapon ) )
				{
					i++;
					continue;
				}
				if ( self.attackerdamage[ player.clientid ].damage > 1 && !isDefined( bestplayer ) )
				{
					bestplayer = player;
					bestplayermeansofdeath = self.attackerdamage[ player.clientid ].meansofdeath;
					bestplayerweapon = self.attackerdamage[ player.clientid ].weapon;
					i++;
					continue;
				}
				if ( isDefined( bestplayer ) && self.attackerdamage[ player.clientid ].damage > self.attackerdamage[ bestplayer.clientid ].damage )
				{
					bestplayer = player;
					bestplayermeansofdeath = self.attackerdamage[ player.clientid ].meansofdeath;
					bestplayerweapon = self.attackerdamage[ player.clientid ].weapon;
				}
				i++;
			}
		}
		if ( isDefined( bestplayer ) )
		{
			maps/mp/_scoreevents::processscoreevent( "assisted_suicide", bestplayer, self, sweapon );
			self recordkillmodifier( "assistedsuicide" );
			assistedsuicide = 1;
		}
	}
	if ( isDefined( bestplayer ) )
	{
		attacker = bestplayer;
		obituarymeansofdeath = bestplayermeansofdeath;
		obituaryweapon = bestplayerweapon;
		if ( isDefined( bestplayerweapon ) )
		{
			sweapon = bestplayerweapon;
		}
	}
	if ( isplayer( attacker ) )
	{
		attacker.damagedplayers[ self.clientid ] = undefined;
	}
	self.deathtime = getTime();
	attacker = updateattacker( attacker, sweapon );
	einflictor = updateinflictor( einflictor );
	smeansofdeath = self playerkilled_updatemeansofdeath( attacker, einflictor, sweapon, smeansofdeath, shitloc );
	if ( !isDefined( obituarymeansofdeath ) )
	{
		obituarymeansofdeath = smeansofdeath;
	}
	if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped == 1 )
	{
		self detachshieldmodel( level.carriedshieldmodel, "tag_weapon_left" );
		self.hasriotshield = 0;
		self.hasriotshieldequipped = 0;
	}
	self thread updateglobalbotkilledcounter();
	self playerkilled_weaponstats( attacker, sweapon, smeansofdeath, wasinlaststand, lastweaponbeforedroppingintolaststand, einflictor );
	self playerkilled_obituary( attacker, einflictor, obituaryweapon, obituarymeansofdeath );
	maps/mp/gametypes/_spawnlogic::deathoccured( self, attacker );
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";
	self.pers[ "weapon" ] = undefined;
	self.killedplayerscurrent = [];
	self.deathcount++;
	/*
/#
	println( "players(" + self.clientid + ") death count ++: " + self.deathcount );
#/
	*/
	self playerkilled_killstreaks( attacker, sweapon );
	lpselfnum = self getentitynumber();
	lpselfname = self.name;
	lpattackguid = "";
	lpattackname = "";
	lpselfteam = self.team;
	lpselfguid = self getguid();
	lpattackteam = "";
	lpattackorigin = ( 0, 0, 0 );
	lpattacknum = -1;
	awardassists = 0;
	wasteamkill = 0;
	wassuicide = 0;
	pixendevent();
	maps/mp/_scoreevents::processscoreevent( "death", self, self, sweapon );
	self.pers[ "resetMomentumOnSpawn" ] = 1;
	if ( isplayer( attacker ) )
	{
		lpattackguid = attacker getguid();
		lpattackname = attacker.name;
		lpattackteam = attacker.team;
		lpattackorigin = attacker.origin;
		if ( attacker == self || assistedsuicide == 1 )
		{
			dokillcam = 0;
			wassuicide = 1;
			awardassists = self playerkilled_suicide( einflictor, attacker, smeansofdeath, sweapon, shitloc );
		}
		else
		{
			pixbeginevent( "PlayerKilled attacker" );
			lpattacknum = attacker getentitynumber();
			dokillcam = 1;
			if ( level.teambased && self.team == attacker.team && smeansofdeath == "MOD_GRENADE" && level.friendlyfire == 0 )
			{
			}
			else if ( level.teambased && self.team == attacker.team )
			{
				wasteamkill = 1;
				self playerkilled_teamkill( einflictor, attacker, smeansofdeath, sweapon, shitloc );
			}
			else
			{
				self playerkilled_kill( einflictor, attacker, smeansofdeath, sweapon, shitloc );
				if ( level.teambased )
				{
					awardassists = 1;
				}
			}
			pixendevent();
		}
	}
	else if ( isDefined( attacker ) && attacker.classname == "trigger_hurt" || isDefined( attacker ) && attacker.classname == "worldspawn" )
	{
		dokillcam = 0;
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackteam = "world";
		thread maps/mp/_scoreevents::processscoreevent( "suicide", self );
		self maps/mp/gametypes/_globallogic_score::incpersstat( "suicides", 1 );
		self.suicides = self maps/mp/gametypes/_globallogic_score::getpersstat( "suicides" );
		self.suicide = 1;
		thread maps/mp/gametypes/_battlechatter_mp::onplayersuicideorteamkill( self, "suicide" );
		awardassists = 1;
		if ( level.maxsuicidesbeforekick > 0 && level.maxsuicidesbeforekick <= self.suicides )
		{
			self notify( "teamKillKicked" );
			self suicidekick();
		}
	}
	else
	{
		dokillcam = 0;
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackteam = "world";
		wassuicide = 1;
		if ( isDefined( einflictor ) && isDefined( einflictor.killcament ) )
		{
			dokillcam = 1;
			lpattacknum = self getentitynumber();
			wassuicide = 0;
		}
		if ( isDefined( attacker ) && isDefined( attacker.team ) && isDefined( level.teams[ attacker.team ] ) )
		{
			if ( attacker.team != self.team )
			{
				if ( level.teambased )
				{
					maps/mp/gametypes/_globallogic_score::giveteamscore( "kill", attacker.team, attacker, self );
				}
				wassuicide = 0;
			}
		}
		awardassists = 1;
	}
	if ( !level.ingraceperiod )
	{
		if ( smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH" && smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_EXPLOSIVE_SPLASH" && smeansofdeath != "MOD_PROJECTILE_SPLASH" )
		{
			self maps/mp/gametypes/_weapons::dropscavengerfordeath( attacker );
		}
		if ( !wasteamkill && !wassuicide )
		{
			self maps/mp/gametypes/_weapons::dropweaponfordeath( attacker, sweapon, smeansofdeath );
			self maps/mp/gametypes/_weapons::dropoffhand();
		}
	}
	if ( sessionmodeiszombiesgame() )
	{
		awardassists = 0;
	}
	if ( awardassists )
	{
		self playerkilled_awardassists( einflictor, attacker, sweapon, lpattackteam );
	}
	pixbeginevent( "PlayerKilled post constants" );
	self.lastattacker = attacker;
	self.lastdeathpos = self.origin;
	if ( ( !level.teambased || attacker.team != self.team ) && isDefined( attacker ) && isplayer( attacker ) && attacker != self )
	{
		self thread maps/mp/_challenges::playerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, shitloc, attackerstance );
	}
	else
	{
		self notify( "playerKilledChallengesProcessed" );
	}
	if ( isDefined( self.attackers ) )
	{
		self.attackers = [];
	}
	if ( isplayer( attacker ) )
	{
		if ( maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
		{
			killstreak = maps/mp/killstreaks/_killstreaks::getkillstreakforweapon( sweapon );
			bbprint( "mpattacks", "gametime %d attackerspawnid %d attackerweapon %s attackerx %d attackery %d attackerz %d victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d killstreak %s", getTime(), getplayerspawnid( attacker ), sweapon, lpattackorigin, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 1, killstreak );
		}
		else
		{
			bbprint( "mpattacks", "gametime %d attackerspawnid %d attackerweapon %s attackerx %d attackery %d attackerz %d victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", getTime(), getplayerspawnid( attacker ), sweapon, lpattackorigin, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 1 );
		}
	}
	else
	{
		bbprint( "mpattacks", "gametime %d attackerweapon %s victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", getTime(), sweapon, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 1 );
	}
	logprint( "K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackteam + ";" + lpattackname + ";" + sweapon + ";" + idamage + ";" + smeansofdeath + ";" + shitloc + "\n" );
	attackerstring = "none";
	if ( isplayer( attacker ) )
	{
		attackerstring = attacker getxuid() + "(" + lpattackname + ")";
	}
	self logstring( "d " + smeansofdeath + "(" + sweapon + ") a:" + attackerstring + " d:" + idamage + " l:" + shitloc + " @ " + int( self.origin[ 0 ] ) + " " + int( self.origin[ 1 ] ) + " " + int( self.origin[ 2 ] ) );
	level thread maps/mp/gametypes/_globallogic::updateteamstatus();
	killcamentity = self getkillcamentity( attacker, einflictor, sweapon );
	killcamentityindex = -1;
	killcamentitystarttime = 0;
	if ( isDefined( killcamentity ) )
	{
		killcamentityindex = killcamentity getentitynumber();
		if ( isDefined( killcamentity.starttime ) )
		{
			killcamentitystarttime = killcamentity.starttime;
		}
		else
		{
			killcamentitystarttime = killcamentity.birthtime;
		}
		if ( !isDefined( killcamentitystarttime ) )
		{
			killcamentitystarttime = 0;
		}
	}
	if ( isDefined( self.killstreak_waitamount ) && self.killstreak_waitamount > 0 )
	{
		dokillcam = 0;
	}
	self maps/mp/gametypes/_weapons::detachcarryobjectmodel();
	died_in_vehicle = 0;
	if ( isDefined( self.diedonvehicle ) )
	{
		died_in_vehicle = self.diedonvehicle;
	}
	hit_by_train = 0;
	if ( isDefined( attacker ) && isDefined( attacker.targetname ) && attacker.targetname == "train" )
	{
		hit_by_train = 1;
	}
	pixendevent();
	pixbeginevent( "PlayerKilled body and gibbing" );
	if ( !died_in_vehicle && !hit_by_train )
	{
		vattackerorigin = undefined;
		if ( isDefined( attacker ) )
		{
			vattackerorigin = attacker.origin;
		}
		ragdoll_now = 0;
		if ( is_true( self.usingvehicle ) && isDefined( self.vehicleposition ) && self.vehicleposition == 1 )
		{
			ragdoll_now = 1;
		}
		body = self cloneplayer( deathanimduration );
		if ( isDefined( body ) )
		{
			self createdeadbody( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_now, body );
		}
	}
	pixendevent();
	thread maps/mp/gametypes/_globallogic_spawn::spawnqueuedclient( self.team, attacker );
	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;
	self thread [[ level.onplayerkilled ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	for ( icb = 0; icb < level.onplayerkilledextraunthreadedcbs.size; icb++ )
	{
		self [[ level.onplayerkilledextraunthreadedcbs[ icb ] ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	}
	self.wantsafespawn = 0;
	perks = [];
	killstreaks = maps/mp/gametypes/_globallogic::getkillstreaks( attacker );
	if ( !isDefined( self.killstreak_waitamount ) )
	{
		self thread [[ level.spawnplayerprediction ]]();
	}
	profilelog_endtiming( 7, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
	if ( wasteamkill == 0 && assistedsuicide == 0 && hit_by_train == 0 && smeansofdeath != "MOD_SUICIDE" && isDefined( attacker ) && attacker.classname != "trigger_hurt" && attacker.classname != "worldspawn" && self != attacker && !isDefined( attacker.disablefinalkillcam ) )
	{
		level thread maps/mp/gametypes/_killcam::recordkillcamsettings( lpattacknum, self getentitynumber(), sweapon, self.deathtime, deathtimeoffset, psoffsettime, killcamentityindex, killcamentitystarttime, perks, killstreaks, attacker );
	}
	wait 0.25;
	weaponclass = getweaponclass( sweapon );
	if ( weaponclass == "weapon_sniper" )
	{
		self thread maps/mp/gametypes/_battlechatter_mp::killedbysniper( attacker );
	}
	else
	{
		self thread maps/mp/gametypes/_battlechatter_mp::playerkilled( attacker );
	}
	self.cancelkillcam = 0;
	self thread maps/mp/gametypes/_killcam::cancelkillcamonuse();
	defaultplayerdeathwatchtime = 1.75;
	if ( isDefined( level.overrideplayerdeathwatchtimer ) )
	{
		defaultplayerdeathwatchtime = [[ level.overrideplayerdeathwatchtimer ]]( defaultplayerdeathwatchtime );
	}
	maps/mp/gametypes/_globallogic_utils::waitfortimeornotifies( defaultplayerdeathwatchtime );
	self notify( "death_delay_finished" );
	/*
/#
	if ( getDvarInt( "scr_forcekillcam" ) != 0 )
	{
		dokillcam = 1;
		if ( lpattacknum < 0 )
		{
			lpattacknum = self getentitynumber();
#/
		}
	}
	*/
	if ( hit_by_train )
	{
		if ( killcamentitystarttime > ( self.deathtime - 2500 ) )
		{
			dokillcam = 0;
		}
	}
	if ( game[ "state" ] != "playing" )
	{
		return;
	}
	self.respawntimerstarttime = getTime();
	if ( !self.cancelkillcam && dokillcam && level.killcam )
	{
		if ( !level.numLives && !self.pers[ "lives" ] )
		{
			livesleft = 0;
		}
		else
		{
			livesleft = 1;
		}
		timeuntilspawn = maps/mp/gametypes/_globallogic_spawn::timeuntilspawn( 1 );
		if ( !level.playerqueuedrespawn && livesleft && timeuntilspawn <= 0 )
		{
			willrespawnimmediately = 1;
		}
		else
		{
			willrespawnimmediately = 0;
		}
		self maps/mp/gametypes/_killcam::killcam( lpattacknum, self getentitynumber(), killcamentity, killcamentityindex, killcamentitystarttime, sweapon, self.deathtime, deathtimeoffset, psoffsettime, willrespawnimmediately, maps/mp/gametypes/_globallogic_utils::timeuntilroundend(), perks, killstreaks, attacker );
	}
	if ( game[ "state" ] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamtargetentity = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}
	waittillkillstreakdone();
	userespawntime = 1;
	if ( isDefined( level.hostmigrationtimer ) )
	{
		userespawntime = 0;
	}
	maps/mp/gametypes/_hostmigration::waittillhostmigrationcountdown();
	if ( maps/mp/gametypes/_globallogic_utils::isvalidclass( self.class ) )
	{
		timepassed = undefined;
		if ( isDefined( self.respawntimerstarttime ) && userespawntime )
		{
			timepassed = ( getTime() - self.respawntimerstarttime ) / 1000;
		}
		self thread [[ level.spawnclient ]]( timepassed );
		self.respawntimerstarttime = undefined;
	}
}

updateglobalbotkilledcounter() //checked matches cerberus output
{
	if ( isDefined( self.pers[ "isBot" ] ) )
	{
		level.globallarryskilled++;
	}
}

waittillkillstreakdone() //checked matches cerberus output
{
	if ( isDefined( self.killstreak_waitamount ) )
	{
		starttime = getTime();
		waittime = self.killstreak_waitamount * 1000;
		while ( getTime() < ( starttime + waittime ) && isDefined( self.killstreak_waitamount ) )
		{
			wait 0.1;
		}
		wait 2;
		self.killstreak_waitamount = undefined;
	}
}

suicidekick() //checked matches cerberus output
{
	self maps/mp/gametypes/_globallogic_score::incpersstat( "sessionbans", 1 );
	self endon( "disconnect" );
	waittillframeend;
	maps/mp/gametypes/_globallogic::gamehistoryplayerkicked();
	ban( self getentitynumber() );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "kicked" );
}

teamkillkick() //checked matches cerberus output
{
	self maps/mp/gametypes/_globallogic_score::incpersstat( "sessionbans", 1 );
	self endon( "disconnect" );
	waittillframeend;
	playlistbanquantum = maps/mp/gametypes/_tweakables::gettweakablevalue( "team", "teamkillerplaylistbanquantum" );
	playlistbanpenalty = maps/mp/gametypes/_tweakables::gettweakablevalue( "team", "teamkillerplaylistbanpenalty" );
	if ( playlistbanquantum > 0 && playlistbanpenalty > 0 )
	{
		timeplayedtotal = self getdstat( "playerstatslist", "time_played_total", "StatValue" );
		minutesplayed = timeplayedtotal / 60;
		freebees = 2;
		banallowance = int( floor( minutesplayed / playlistbanquantum ) ) + freebees;
		if ( self.sessionbans > banallowance )
		{
			self setdstat( "playerstatslist", "gametypeban", "StatValue", timeplayedtotal + ( playlistbanpenalty * 60 ) );
		}
	}
	maps/mp/gametypes/_globallogic::gamehistoryplayerkicked();
	ban( self getentitynumber() );
	maps/mp/gametypes/_globallogic_audio::leaderdialog( "kicked" );
}

teamkilldelay() //checked matches cerberus output
{
	teamkills = self.pers[ "teamkills_nostats" ];
	if ( level.minimumallowedteamkills < 0 || teamkills <= level.minimumallowedteamkills )
	{
		return 0;
	}
	exceeded = teamkills - level.minimumallowedteamkills;
	return level.teamkillspawndelay * exceeded;
}

shouldteamkillkick( teamkilldelay ) //checked matches cerberus output
{
	if ( teamkilldelay && level.minimumallowedteamkills >= 0 )
	{
		if ( maps/mp/gametypes/_globallogic_utils::gettimepassed() >= 5000 )
		{
			return 1;
		}
		if ( self.pers[ "teamkills_nostats" ] > 1 )
		{
			return 1;
		}
	}
	return 0;
}

reduceteamkillsovertime() //checked changed to match cerberus output
{
	timeperoneteamkillreduction = 20;
	reductionpersecond = 1 / timeperoneteamkillreduction;
	while ( 1 )
	{
		if ( isalive( self ) )
		{
			self.pers[ "teamkills_nostats" ] -= reductionpersecond;
			if ( self.pers[ "teamkills_nostats" ] < level.minimumallowedteamkills )
			{
				self.pers[ "teamkills_nostats" ] = level.minimumallowedteamkills;
				break;
			}
		}
		wait 1;
	}
}

ignoreteamkills( sweapon, smeansofdeath ) //checked matches cerberus output
{
	if ( sessionmodeiszombiesgame() )
	{
		return 1;
	}
	if ( smeansofdeath == "MOD_MELEE" )
	{
		return 0;
	}
	if ( sweapon == "briefcase_bomb_mp" )
	{
		return 1;
	}
	if ( sweapon == "supplydrop_mp" )
	{
		return 1;
	}
	return 0;
}

callback_playerlaststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked matches cerberus output
{
}

damageshellshockandrumble( eattacker, einflictor, sweapon, smeansofdeath, idamage ) //checked matches cerberus output
{
	self thread maps/mp/gametypes/_weapons::onweapondamage( eattacker, einflictor, sweapon, smeansofdeath, idamage );
	self playrumbleonentity( "damage_heavy" );
}

createdeadbody( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body ) //checked changed to match cerberus output
{
	if ( smeansofdeath == "MOD_HIT_BY_OBJECT" && self getstance() == "prone" )
	{
		self.body = body;
		if ( !isDefined( self.switching_teams ) )
		{
			thread maps/mp/gametypes/_deathicons::adddeathicon( body, self, self.team, 5 );
		}
		return;
	}
	if ( isDefined( level.ragdoll_override ) && self [[ level.ragdoll_override ]]( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body ) )
	{
		return;
	}
	if ( ragdoll_jib || self isonladder() || self ismantling() || smeansofdeath == "MOD_CRUSH" || smeansofdeath == "MOD_HIT_BY_OBJECT" )
	{
		body startragdoll();
	}
	if ( !self isonground() )
	{
		if ( getDvarInt( "scr_disable_air_death_ragdoll" ) == 0 )
		{
			body startragdoll();
		}
	}
	if ( self is_explosive_ragdoll( sweapon, einflictor ) )
	{
		body start_explosive_ragdoll( vdir, sweapon );
	}
	thread delaystartragdoll( body, shitloc, vdir, sweapon, einflictor, smeansofdeath );
	if ( smeansofdeath == "MOD_BURNED" || isDefined( self.burning ) )
	{
		body maps/mp/_burnplayer::burnedtodeath();
	}
	if ( smeansofdeath == "MOD_CRUSH" )
	{
		body maps/mp/gametypes/_globallogic_vehicle::vehiclecrush();
	}
	self.body = body;
	if ( !isDefined( self.switching_teams ) )
	{
		thread maps/mp/gametypes/_deathicons::adddeathicon( body, self, self.team, 5 );
	}
}

is_explosive_ragdoll( weapon, inflictor ) //checked matches cerberus output
{
	if ( !isDefined( weapon ) )
	{
		return 0;
	}
	if ( weapon == "destructible_car_mp" || weapon == "explodable_barrel_mp" )
	{
		return 1;
	}
	if ( weapon == "sticky_grenade_mp" || weapon == "explosive_bolt_mp" )
	{
		if ( isDefined( inflictor ) && isDefined( inflictor.stucktoplayer ) )
		{
			if ( inflictor.stucktoplayer == self )
			{
				return 1;
			}
		}
	}
	return 0;
}

start_explosive_ragdoll( dir, weapon ) //checked partially changed to match cerberus output see info.md
{
	if ( !isDefined( self ) )
	{
		return;
	}
	x = randomintrange( 50, 100 );
	y = randomintrange( 50, 100 );
	z = randomintrange( 10, 20 );
	if ( ( weapon == "sticky_grenade_mp" || weapon == "explosive_bolt_mp" ) && isDefined( weapon ) )
	{
		if ( isDefined( dir ) && lengthsquared( dir ) > 0 )
		{
			x = dir[ 0 ] * x;
			y = dir[ 1 ] * y;
		}
	}
	else if ( cointoss() )
	{
		x *= -1;
	}
	if ( cointoss() )
	{
		y *= -1;
	}
	self startragdoll();
	self launchragdoll( ( x, y, z ) );
}

notifyconnecting() //checked changed to match cerberus output
{
	waittillframeend;
	if ( isDefined( self ) )
	{
		level notify( "connecting", self );
	}
}

delaystartragdoll( ent, shitloc, vdir, sweapon, einflictor, smeansofdeath ) //checked changed to match cerberus output
{
	if ( isDefined( ent ) )
	{
		deathanim = ent getcorpseanim();
		if ( animhasnotetrack( deathanim, "ignore_ragdoll" ) )
		{
			return;
		}
	}
	if ( level.oldschool )
	{
		if ( !isDefined( vdir ) )
		{
			vdir = ( 0, 0, 0 );
		}
		explosionpos = ent.origin + ( 0, 0, maps/mp/gametypes/_globallogic_utils::gethitlocheight( shitloc ) );
		explosionpos -= vdir * 20;
		explosionradius = 40;
		explosionforce = 0.75;
		if ( smeansofdeath == "MOD_IMPACT" || smeansofdeath == "MOD_EXPLOSIVE" || !issubstr( smeansofdeath, "MOD_GRENADE" ) || !issubstr( smeansofdeath, "MOD_PROJECTILE" ) || shitloc == "head" || shitloc == "helmet" )
		{
			explosionforce = 2.5;
		}
		ent startragdoll( 1 );
		wait 0.05;
		if ( !isDefined( ent ) )
		{
			return;
		}
		physicsexplosionsphere( explosionpos, explosionradius, explosionradius / 2, explosionforce );
		return;
	}
	wait 0.2;
	if ( !isDefined( ent ) )
	{
		return;
	}
	if ( ent isragdoll() )
	{
		return;
	}
	deathanim = ent getcorpseanim();
	startfrac = 0.35;
	if ( animhasnotetrack( deathanim, "start_ragdoll" ) )
	{
		times = getnotetracktimes( deathanim, "start_ragdoll" );
		if ( isDefined( times ) )
		{
			startfrac = times[ 0 ];
		}
	}
	waittime = startfrac * getanimlength( deathanim );
	wait waittime;
	if ( isDefined( ent ) )
	{
		ent startragdoll( 1 );
	}
}

trackattackerdamage( eattacker, idamage, smeansofdeath, sweapon ) //checked matches cerberus output
{
	/*
/#
	assert( isplayer( eattacker ) );
#/
	*/
	if ( self.attackerdata.size == 0 )
	{
		self.firsttimedamaged = getTime();
	}
	if ( !isDefined( self.attackerdata[ eattacker.clientid ] ) )
	{
		self.attackerdamage[ eattacker.clientid ] = spawnstruct();
		self.attackerdamage[ eattacker.clientid ].damage = idamage;
		self.attackerdamage[ eattacker.clientid ].meansofdeath = smeansofdeath;
		self.attackerdamage[ eattacker.clientid ].weapon = sweapon;
		self.attackerdamage[ eattacker.clientid ].time = getTime();
		self.attackers[ self.attackers.size ] = eattacker;
		self.attackerdata[ eattacker.clientid ] = 0;
	}
	else
	{
		self.attackerdamage[ eattacker.clientid ].damage += idamage;
		self.attackerdamage[ eattacker.clientid ].meansofdeath = smeansofdeath;
		self.attackerdamage[ eattacker.clientid ].weapon = sweapon;
		if ( !isDefined( self.attackerdamage[ eattacker.clientid ].time ) )
		{
			self.attackerdamage[ eattacker.clientid ].time = getTime();
		}
	}
	self.attackerdamage[ eattacker.clientid ].lasttimedamaged = getTime();
	if ( maps/mp/gametypes/_weapons::isprimaryweapon( sweapon ) )
	{
		self.attackerdata[ eattacker.clientid ] = 1;
	}
}

giveinflictorownerassist( eattacker, einflictor, idamage, smeansofdeath, sweapon ) //checked matches cerberus output
{
	if ( !isDefined( einflictor ) )
	{
		return;
	}
	if ( !isDefined( einflictor.owner ) )
	{
		return;
	}
	if ( !isDefined( einflictor.ownergetsassist ) )
	{
		return;
	}
	if ( !einflictor.ownergetsassist )
	{
		return;
	}
	/*
/#
	assert( isplayer( einflictor.owner ) );
#/
	*/
	self trackattackerdamage( einflictor.owner, idamage, smeansofdeath, sweapon );
}

playerkilled_updatemeansofdeath( attacker, einflictor, sweapon, smeansofdeath, shitloc ) //checked matches cerberus output
{
	if ( maps/mp/gametypes/_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) && isplayer( attacker ) )
	{
		return "MOD_HEAD_SHOT";
	}
	switch( sweapon )
	{
		case "crossbow_mp":
		case "knife_ballistic_mp":
			if ( smeansofdeath != "MOD_HEAD_SHOT" && smeansofdeath != "MOD_MELEE" )
			{
				smeansofdeath = "MOD_PISTOL_BULLET";
			}
			break;
		case "dog_bite_mp":
			smeansofdeath = "MOD_PISTOL_BULLET";
			break;
		case "destructible_car_mp":
			smeansofdeath = "MOD_EXPLOSIVE";
			break;
		case "explodable_barrel_mp":
			smeansofdeath = "MOD_EXPLOSIVE";
			break;
	}
	return smeansofdeath;
}

updateattacker( attacker, weapon ) //checked changed to match cerberus output
{
	if ( isai( attacker ) && isDefined( attacker.script_owner ) )
	{
		if ( !level.teambased || attacker.script_owner.team != self.team )
		{
			attacker = attacker.script_owner;
		}
	}
	if ( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	{
		attacker notify( "killed", self );
		attacker = attacker.owner;
	}
	if ( isai( attacker ) )
	{
		attacker notify( "killed", self );
	}
	if ( isDefined( self.capturinglastflag ) && self.capturinglastflag == 1 )
	{
		attacker.lastcapkiller = 1;
	}
	if ( isDefined( attacker ) && isDefined( weapon ) && weapon == "planemortar_mp" )
	{
		if ( !isDefined( attacker.planemortarbda ) )
		{
			attacker.planemortarbda = 0;
		}
		attacker.planemortarbda++;
	}
	if ( isDefined( attacker ) && isDefined( weapon ) && weapon == "straferun_rockets_mp" || weapon == "straferun_gun_mp" )
	{
		if ( isDefined( attacker.straferunbda ) )
		{
			attacker.straferunbda++;
		}
	}
	return attacker;
}

updateinflictor( einflictor ) //checked changed to match cerberus output
{
	if ( isDefined( einflictor ) && einflictor.classname == "script_vehicle" )
	{
		einflictor notify( "killed", self );
		if ( isDefined( einflictor.bda ) )
		{
			einflictor.bda++;
		}
	}
	return einflictor;
}

updateweapon( einflictor, sweapon ) //checked changed to match cerberus output
{
	if ( sweapon == "none" && isDefined( einflictor ) )
	{
		if ( isDefined( einflictor.targetname ) && einflictor.targetname == "explodable_barrel" )
		{
			sweapon = "explodable_barrel_mp";
		}
		else if ( isDefined( einflictor.destructible_type ) && issubstr( einflictor.destructible_type, "vehicle_" ) )
		{
			sweapon = "destructible_car_mp";
		}
	}
	return sweapon;
}

getclosestkillcamentity( attacker, killcamentities, depth ) //checked partially changed to match cerberus output see info.md
{
	if ( !isDefined( depth ) )
	{
		depth = 0;
	}
	closestkillcament = undefined;
	closestkillcamentindex = undefined;
	closestkillcamentdist = undefined;
	origin = undefined;
	foreach ( killcament in killcamentities )
	{
		if ( killcament == attacker )
		{
		}
		else
		{
			origin = killcament.origin;
			if ( isDefined( killcament.offsetpoint ) )
			{
				origin += killcament.offsetpoint;
			}
			dist = distancesquared( self.origin, origin );
			if ( !isDefined( closestkillcament ) || dist < closestkillcamentdist )
			{
				closestkillcament = killcament;
				closestkillcamentdist = dist;
				closestkillcamentindex = killcamentindex;
			}
		}
	}
	if ( depth < 3 && isDefined( closestkillcament ) )
	{
		if ( !bullettracepassed( closestkillcament.origin, self.origin, 0, self ) )
		{
			betterkillcament = getclosestkillcamentity( attacker, killcamentities, depth + 1 );
			if ( isDefined( betterkillcament ) )
			{
				closestkillcament = betterkillcament;
			}
		}
	}
	return closestkillcament;
}

getkillcamentity( attacker, einflictor, sweapon ) //checked changed to match cerberus output
{
	if ( !isDefined( einflictor ) )
	{
		return undefined;
	}
	if ( einflictor == attacker )
	{
		if ( !isDefined( einflictor.ismagicbullet ) )
		{
			return undefined;
		}
		if ( !is_true( einflictor.ismagicbullet ) )
		{
			return undefined;
		}
	}
	else if ( isDefined( level.levelspecifickillcam ) )
	{
		levelspecifickillcament = self [[ level.levelspecifickillcam ]]();
		if ( isDefined( levelspecifickillcament ) )
		{
			return levelspecifickillcament;
		}
	}
	if ( sweapon == "m220_tow_mp" )
	{
		return undefined;
	}
	if ( isDefined( einflictor.killcament ) )
	{
		if ( einflictor.killcament == attacker )
		{
			return undefined;
		}
		return einflictor.killcament;
	}
	else if ( isDefined( einflictor.killcamentities ) )
	{
		return getclosestkillcamentity( attacker, einflictor.killcamentities );
	}
	if ( isDefined( einflictor.script_gameobjectname ) && einflictor.script_gameobjectname == "bombzone" )
	{
		return einflictor.killcament;
	}
	return einflictor;
}

playkillbattlechatter( attacker, sweapon, victim ) //checked matches cerberus output
{
	if ( isplayer( attacker ) )
	{
		if ( !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
		{
			level thread maps/mp/gametypes/_battlechatter_mp::saykillbattlechatter( attacker, sweapon, victim );
		}
	}
}


