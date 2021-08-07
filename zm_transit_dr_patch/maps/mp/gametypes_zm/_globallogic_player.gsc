#include maps/mp/gametypes_zm/_globallogic_audio;
#include maps/mp/gametypes_zm/_tweakables;
#include maps/mp/_challenges;
#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/_demo;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/gametypes_zm/_spectating;
#include maps/mp/gametypes_zm/_globallogic_spawn;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_globallogic;
#include common_scripts/utility;
#include maps/mp/_utility;

freezeplayerforroundend()
{
	self clearlowermessage();
	self closemenu();
	self closeingamemenu();
	self freeze_player_controls( 1 );
	if ( !sessionmodeiszombiesgame() )
	{
		currentweapon = self getcurrentweapon();
	}
}

callback_playerconnect()
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
	profilelog_begintiming( 4, "ship" );
	level notify( "connected" );
	if ( self ishost() )
	{
		self thread maps/mp/gametypes_zm/_globallogic::listenforgameend();
	}
	if ( !level.splitscreen && !isDefined( self.pers[ "score" ] ) )
	{
		iprintln( &"MP_CONNECTED", self );
	}
	if ( !isDefined( self.pers[ "score" ] ) )
	{
		self thread maps/mp/zombies/_zm_stats::adjustrecentstats();
	}
	if ( gamemodeismode( level.gamemode_public_match ) && !isDefined( self.pers[ "matchesPlayedStatsTracked" ] ) )
	{
		gamemode = maps/mp/gametypes_zm/_globallogic::getcurrentgamemode();
		self maps/mp/gametypes_zm/_globallogic::incrementmatchcompletionstat( gamemode, "played", "started" );
		if ( !isDefined( self.pers[ "matchesHostedStatsTracked" ] ) && self islocaltohost() )
		{
			self maps/mp/gametypes_zm/_globallogic::incrementmatchcompletionstat( gamemode, "hosted", "started" );
			self.pers[ "matchesHostedStatsTracked" ] = 1;
		}
		self.pers[ "matchesPlayedStatsTracked" ] = 1;
		self thread maps/mp/zombies/_zm_stats::uploadstatssoon();
	}
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
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "score" );
		if ( level.resetplayerscoreeveryround )
		{
			self.pers[ "score" ] = 0;
		}
		self.score = self.pers[ "score" ];
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "momentum", 0 );
		self.momentum = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "momentum" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "suicides" );
		self.suicides = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "suicides" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "headshots" );
		self.headshots = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "headshots" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "challenges" );
		self.challenges = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "challenges" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "kills" );
		self.kills = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "kills" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "deaths" );
		self.deaths = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "deaths" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "assists" );
		self.assists = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "assists" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "defends", 0 );
		self.defends = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "defends" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "offends", 0 );
		self.offends = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "offends" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "plants", 0 );
		self.plants = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "plants" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "defuses", 0 );
		self.defuses = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "defuses" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "returns", 0 );
		self.returns = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "returns" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "captures", 0 );
		self.captures = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "captures" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "destructions", 0 );
		self.destructions = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "destructions" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "backstabs", 0 );
		self.backstabs = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "backstabs" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "longshots", 0 );
		self.longshots = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "longshots" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "survived", 0 );
		self.survived = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "survived" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "stabs", 0 );
		self.stabs = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "stabs" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "tomahawks", 0 );
		self.tomahawks = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "tomahawks" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "humiliated", 0 );
		self.humiliated = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "humiliated" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "x2score", 0 );
		self.x2score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "x2score" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "agrkills", 0 );
		self.x2score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "agrkills" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "hacks", 0 );
		self.x2score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "hacks" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sessionbans", 0 );
		self.sessionbans = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "sessionbans" );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "gametypeban", 0 );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "time_played_total", 0 );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "time_played_alive", 0 );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "teamkills", 0 );
		self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "teamkills_nostats", 0 );
		self.teamkillpunish = 0;
		if ( level.minimumallowedteamkills >= 0 && self.pers[ "teamkills_nostats" ] > level.minimumallowedteamkills )
		{
			self thread reduceteamkillsovertime();
		}
	}
	if ( getDvar( #"F7B30924" ) == "1" )
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
	if ( isDefined( level.usingscorestreaks ) && level.usingscorestreaks && !isDefined( self.pers[ "killstreak_quantity" ] ) )
	{
		self.pers[ "killstreak_quantity" ] = [];
	}
	if ( isDefined( level.usingscorestreaks ) && level.usingscorestreaks && !isDefined( self.pers[ "held_killstreak_ammo_count" ] ) )
	{
		self.pers[ "held_killstreak_ammo_count" ] = [];
	}
	self.lastkilltime = 0;
	self.cur_death_streak = 0;
	self disabledeathstreak();
	self.death_streak = 0;
	self.kill_streak = 0;
	self.gametype_kill_streak = 0;
	self.spawnqueueindex = -1;
	self.deathtime = 0;
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
	if ( level.scr_zm_ui_gametype_group == "zencounter" )
	{
		self maps/mp/zombies/_zm_stats::increment_client_stat( "losses" );
		self updatestatratio( "wlratio", "wins", "losses" );
		self maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "losses", 1 );
	}
	else
	{
		if ( level.scr_zm_ui_gametype_group == "zsurvival" )
		{
			if ( is_true( level.should_use_cia ) )
			{
				self luinotifyevent( &"hud_update_survival_team", 1, 2 );
			}
		}
	}
	level endon( "game_ended" );
	if ( isDefined( level.hostmigrationtimer ) )
	{
		self thread maps/mp/gametypes_zm/_hostmigration::hostmigrationtimerthink();
	}
	if ( level.oldschool )
	{
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
		self maps/mp/gametypes_zm/_globallogic_ui::updateobjectivetext();
		[[ level.spawnspectator ]]();
		if ( level.rankedmatch )
		{
			[[ level.autoassign ]]( 0 );
			self thread maps/mp/gametypes_zm/_globallogic_spawn::kickifdontspawn();
		}
		else
		{
			[[ level.autoassign ]]( 0 );
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
			self thread maps/mp/gametypes_zm/_spectating::setspectatepermissions();
		}
	}
	else
	{
		if ( self.pers[ "team" ] == "spectator" )
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
			self maps/mp/gametypes_zm/_globallogic_ui::updateobjectivetext();
			[[ level.spawnspectator ]]();
			if ( maps/mp/gametypes_zm/_globallogic_utils::isvalidclass( self.pers[ "class" ] ) )
			{
				self thread [[ level.spawnclient ]]();
			}
			else
			{
				self maps/mp/gametypes_zm/_globallogic_ui::showmainmenuforteam();
			}
			self thread maps/mp/gametypes_zm/_spectating::setspectatepermissions();
		}
	}
	if ( self.sessionteam != "spectator" )
	{
		self thread maps/mp/gametypes_zm/_spawning::onspawnplayer_unified( 1 );
	}
	profilelog_endtiming( 4, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
	if ( isDefined( self.pers[ "isBot" ] ) )
	{
		return;
	}
}

spectate_player_watcher()
{
	self endon( "disconnect" );
	self.watchingactiveclient = 1;
	self.waitingforplayerstext = undefined;
	while ( 1 )
	{
		if ( self.pers[ "team" ] != "spectator" || level.gameended )
		{
			self maps/mp/gametypes_zm/_hud_message::clearshoutcasterwaitingmessage();
/#
			println( " Unfreeze controls 1" );
#/
			self freezecontrols( 0 );
			self.watchingactiveclient = 0;
			return;
		}
		else if ( !level.splitscreen && !level.hardcoremode && getDvarInt( "scr_showperksonspawn" ) == 1 && game[ "state" ] != "postgame" && !isDefined( self.perkhudelem ) )
		{
			if ( level.perksenabled == 1 )
			{
				self maps/mp/gametypes_zm/_hud_util::showperks();
			}
			self thread maps/mp/gametypes_zm/_globallogic_ui::hideloadoutaftertime( 0 );
		}
		count = 0;
		i = 0;
		while ( i < level.players.size )
		{
			if ( level.players[ i ].team != "spectator" )
			{
				count++;
				break;
			}
			else
			{
				i++;
			}
		}
		if ( count > 0 )
		{
			if ( !self.watchingactiveclient )
			{
				self maps/mp/gametypes_zm/_hud_message::clearshoutcasterwaitingmessage();
				self freezecontrols( 0 );
/#
				println( " Unfreeze controls 2" );
#/
			}
			self.watchingactiveclient = 1;
		}
		else
		{
			if ( self.watchingactiveclient )
			{
				[[ level.onspawnspectator ]]();
				self freezecontrols( 1 );
				self maps/mp/gametypes_zm/_hud_message::setshoutcasterwaitingmessage();
			}
			self.watchingactiveclient = 0;
		}
		wait 0,5;
	}
}

callback_playermigrated()
{
/#
	println( "Player " + self.name + " finished migrating at time " + getTime() );
#/
	if ( isDefined( self.connected ) && self.connected )
	{
		self maps/mp/gametypes_zm/_globallogic_ui::updateobjectivetext();
	}
	self thread inform_clientvm_of_migration();
	level.hostmigrationreturnedplayercount++;
	if ( level.hostmigrationreturnedplayercount >= ( ( level.players.size * 2 ) / 3 ) )
	{
/#
		println( "2/3 of players have finished migrating" );
#/
		level notify( "hostmigration_enoughplayers" );
	}
}

inform_clientvm_of_migration()
{
	self endon( "disconnect" );
	wait 1;
	self clientnotify( "hmo" );
/#
	println( "SERVER : Sent HMO to client " + self getentitynumber() );
#/
}

callback_playerdisconnect()
{
	profilelog_begintiming( 5, "ship" );
	if ( game[ "state" ] != "postgame" && !level.gameended )
	{
		gamelength = maps/mp/gametypes_zm/_globallogic::getgamelength();
		self maps/mp/gametypes_zm/_globallogic::bbplayermatchend( gamelength, "MP_PLAYER_DISCONNECT", 0 );
	}
	self removeplayerondisconnect();
	if ( level.splitscreen )
	{
		players = level.players;
		if ( players.size <= 1 )
		{
			level thread maps/mp/gametypes_zm/_globallogic::forceend();
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
	entry = 0;
	while ( entry < level.players.size )
	{
		if ( level.players[ entry ] == self )
		{
			while ( entry < ( level.players.size - 1 ) )
			{
				level.players[ entry ] = level.players[ entry + 1 ];
				entry++;
			}
			break;
		}
		else
		{
			entry++;
		}
	}
	entry = 0;
	while ( entry < level.players.size )
	{
		if ( isDefined( level.players[ entry ].pers[ "killed_players" ][ self.name ] ) )
		{
		}
		if ( isDefined( level.players[ entry ].killedplayerscurrent[ self.name ] ) )
		{
		}
		if ( isDefined( level.players[ entry ].pers[ "killed_by" ][ self.name ] ) )
		{
		}
		if ( isDefined( level.players[ entry ].pers[ "nemesis_tracking" ][ self.name ] ) )
		{
		}
		if ( level.players[ entry ].pers[ "nemesis_name" ] == self.name )
		{
			level.players[ entry ] choosenextbestnemesis();
		}
		entry++;
	}
	if ( level.gameended )
	{
		self maps/mp/gametypes_zm/_globallogic::removedisconnectedplayerfromplacement();
	}
	level thread maps/mp/gametypes_zm/_globallogic::updateteamstatus();
	profilelog_endtiming( 5, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
}

callback_playermelee( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit )
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

choosenextbestnemesis()
{
	nemesisarray = self.pers[ "nemesis_tracking" ];
	nemesisarraykeys = getarraykeys( nemesisarray );
	nemesisamount = 0;
	nemesisname = "";
	while ( nemesisarraykeys.size > 0 )
	{
		i = 0;
		while ( i < nemesisarraykeys.size )
		{
			nemesisarraykey = nemesisarraykeys[ i ];
			if ( nemesisarray[ nemesisarraykey ] > nemesisamount )
			{
				nemesisname = nemesisarraykey;
				nemesisamount = nemesisarray[ nemesisarraykey ];
			}
			i++;
		}
	}
	self.pers[ "nemesis_name" ] = nemesisname;
	if ( nemesisname != "" )
	{
		playerindex = 0;
		while ( playerindex < level.players.size )
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
			else
			{
				playerindex++;
			}
		}
	}
	else self.pers[ "nemesis_xuid" ] = "";
}

removeplayerondisconnect()
{
	entry = 0;
	while ( entry < level.players.size )
	{
		if ( level.players[ entry ] == self )
		{
			while ( entry < ( level.players.size - 1 ) )
			{
				level.players[ entry ] = level.players[ entry + 1 ];
				entry++;
			}
			return;
		}
		else
		{
			entry++;
		}
	}
}

custom_gamemodes_modified_damage( victim, eattacker, idamage, smeansofdeath, sweapon, einflictor, shitloc )
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

figureoutattacker( eattacker )
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
		else
		{
			if ( eattacker.classname == "auto_turret" && isDefined( eattacker.owner ) )
			{
				eattacker = eattacker.owner;
			}
		}
	}
	return eattacker;
}

figureoutweapon( sweapon, einflictor )
{
	if ( sweapon == "none" && isDefined( einflictor ) )
	{
		if ( isDefined( einflictor.targetname ) && einflictor.targetname == "explodable_barrel" )
		{
			sweapon = "explodable_barrel_mp";
		}
		else
		{
			if ( isDefined( einflictor.destructible_type ) && issubstr( einflictor.destructible_type, "vehicle_" ) )
			{
				sweapon = "destructible_car_mp";
			}
		}
	}
	return sweapon;
}

isplayerimmunetokillstreak( eattacker, sweapon )
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

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
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
	if ( isDefined( self.candocombat ) && !self.candocombat )
	{
		return;
	}
	if ( isDefined( eattacker ) && isplayer( eattacker ) && isDefined( eattacker.candocombat ) && !eattacker.candocombat )
	{
		return;
	}
	if ( isDefined( level.hostmigrationtimer ) )
	{
		return;
	}
	if ( sweapon != "ai_tank_drone_gun_mp" && sweapon == "ai_tank_drone_rocket_mp" && !level.hardcoremode )
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
		self notify( "emp_grenaded" );
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
	if ( isDefined( einflictor ) && isDefined( einflictor.script_noteworthy ) && einflictor.script_noteworthy == "ragdoll_now" )
	{
		smeansofdeath = "MOD_FALLING";
	}
	if ( maps/mp/gametypes_zm/_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) && isplayer( eattacker ) )
	{
		smeansofdeath = "MOD_HEAD_SHOT";
	}
	if ( level.onplayerdamage != ::maps/mp/gametypes_zm/_globallogic::blank )
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
		else
		{
			if ( smeansofdeath == "MOD_HEAD_SHOT" )
			{
				idamage = 150;
			}
		}
	}
	if ( isDefined( eattacker ) && isplayer( eattacker ) && self.team != eattacker.team )
	{
		self.lastattackweapon = sweapon;
	}
	sweapon = figureoutweapon( sweapon, einflictor );
	pixendevent();
	if ( isplayer( eattacker ) )
	{
		attackerishittingteammate = self isenemyplayer( eattacker ) == 0;
	}
	if ( shitloc == "riotshield" )
	{
		if ( attackerishittingteammate && level.friendlyfire == 0 )
		{
			return;
		}
		if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" && !attackerishittingteammate )
		{
			previous_shield_damage = self.shielddamageblocked;
			self.shielddamageblocked += idamage;
			if ( isplayer( eattacker ) )
			{
				eattacker.lastattackedshieldplayer = self;
				eattacker.lastattackedshieldtime = getTime();
			}
			if ( ( self.shielddamageblocked % 400 ) < ( previous_shield_damage % 400 ) )
			{
				score_event = "shield_blocked_damage";
				if ( self.shielddamageblocked > 2000 )
				{
					score_event = "shield_blocked_damage_reduced";
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
	if ( isDefined( eattacker ) && eattacker != self && !friendly )
	{
		level.usestartspawns = 0;
	}
	pixbeginevent( "PlayerDamage log" );
/#
	if ( getDvarInt( "g_debugDamage" ) )
	{
		println( "client:" + self getentitynumber() + " health:" + self.health + " attacker:" + eattacker.clientid + " inflictor is player:" + isplayer( einflictor ) + " damage:" + idamage + " hitLoc:" + shitloc );
#/
	}
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

resetattackerlist()
{
	self.attackers = [];
	self.attackerdata = [];
	self.attackerdamage = [];
	self.firsttimedamaged = 0;
}

dodamagefeedback( sweapon, einflictor, idamage, smeansofdeath )
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

istacticalhitmarker( sweapon, smeansofdeath, idamage )
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
		else
		{
			if ( idamage == 1 )
			{
				return 1;
			}
		}
	}
	return 0;
}

doperkfeedback( player, sweapon, smeansofdeath, einflictor )
{
	perkfeedback = undefined;
	return perkfeedback;
}

isaikillstreakdamage( sweapon, einflictor )
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

finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	pixbeginevent( "finishPlayerDamageWrapper" );
	if ( !level.console && idflags & level.idflags_penetration && isplayer( eattacker ) )
	{
/#
		println( "penetrated:" + self getentitynumber() + " health:" + self.health + " attacker:" + eattacker.clientid + " inflictor is player:" + isplayer( einflictor ) + " damage:" + idamage + " hitLoc:" + shitloc );
#/
		eattacker addplayerstat( "penetration_shots", 1 );
	}
	self finishplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( getDvar( #"C8077F47" ) != "" )
	{
		self shellshock( "damage_mp", 0,2 );
	}
	self damageshellshockandrumble( eattacker, einflictor, sweapon, smeansofdeath, idamage );
	pixendevent();
}

allowedassistweapon( weapon )
{
	return 1;
}

callback_playerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
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
/#
		assert( isDefined( self.laststandparams ) );
#/
		if ( !level.teambased || isDefined( attacker ) && isplayer( attacker ) || attacker.team != self.team && attacker == self )
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
	obituaryweapon = undefined;
	if ( isDefined( attacker ) && attacker.classname != "trigger_hurt" && attacker.classname != "worldspawn" && isDefined( attacker.ismagicbullet ) && attacker.ismagicbullet != 1 && attacker == self && isDefined( self.attackers ) )
	{
		while ( !isDefined( bestplayer ) )
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
				else if ( !isDefined( self.attackerdamage[ player.clientid ] ) || !isDefined( self.attackerdamage[ player.clientid ].damage ) )
				{
					i++;
					continue;
				}
				else
				{
					if ( player == self || level.teambased && player.team == self.team )
					{
						i++;
						continue;
					}
					else
					{
						if ( ( self.attackerdamage[ player.clientid ].lasttimedamaged + 2500 ) < getTime() )
						{
							i++;
							continue;
						}
						else if ( !allowedassistweapon( self.attackerdamage[ player.clientid ].weapon ) )
						{
							i++;
							continue;
						}
						else if ( self.attackerdamage[ player.clientid ].damage > 1 && !isDefined( bestplayer ) )
						{
							bestplayer = player;
							bestplayermeansofdeath = self.attackerdamage[ player.clientid ].meansofdeath;
							bestplayerweapon = self.attackerdamage[ player.clientid ].weapon;
							i++;
							continue;
						}
						else
						{
							if ( isDefined( bestplayer ) && self.attackerdamage[ player.clientid ].damage > self.attackerdamage[ bestplayer.clientid ].damage )
							{
								bestplayer = player;
								bestplayermeansofdeath = self.attackerdamage[ player.clientid ].meansofdeath;
								bestplayerweapon = self.attackerdamage[ player.clientid ].weapon;
							}
						}
					}
				}
				i++;
			}
		}
		if ( isDefined( bestplayer ) )
		{
			self recordkillmodifier( "assistedsuicide" );
		}
	}
	if ( isDefined( bestplayer ) )
	{
		attacker = bestplayer;
		obituarymeansofdeath = bestplayermeansofdeath;
		obituaryweapon = bestplayerweapon;
	}
	if ( isplayer( attacker ) )
	{
	}
	if ( maps/mp/gametypes_zm/_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) && isplayer( attacker ) )
	{
		attacker playlocalsound( "prj_bullet_impact_headshot_helmet_nodie_2d" );
		smeansofdeath = "MOD_HEAD_SHOT";
	}
	self.deathtime = getTime();
	attacker = updateattacker( attacker, sweapon );
	einflictor = updateinflictor( einflictor );
	smeansofdeath = updatemeansofdeath( sweapon, smeansofdeath );
	if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped == 1 )
	{
		self detachshieldmodel( level.carriedshieldmodel, "tag_weapon_left" );
		self.hasriotshield = 0;
		self.hasriotshieldequipped = 0;
	}
	self thread updateglobalbotkilledcounter();
	if ( isplayer( attacker ) && attacker != self || !level.teambased && level.teambased && self.team != attacker.team )
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
		if ( isDefined( weaponname ) && !issubstr( weaponname, "gl_" ) || issubstr( weaponname, "mk_" ) && issubstr( weaponname, "ft_" ) )
		{
			weaponname = self.currentweapon;
		}
		if ( isDefined( weaponname ) )
		{
			self addweaponstat( weaponname, "deathsDuringUse", 1 );
		}
		if ( smeansofdeath != "MOD_FALLING" )
		{
			attacker addweaponstat( sweapon, "kills", 1 );
		}
		if ( smeansofdeath == "MOD_HEAD_SHOT" )
		{
			attacker addweaponstat( sweapon, "headshots", 1 );
		}
	}
	if ( !isDefined( obituarymeansofdeath ) )
	{
		obituarymeansofdeath = smeansofdeath;
	}
	if ( !isDefined( obituaryweapon ) )
	{
		obituaryweapon = sweapon;
	}
	if ( !isplayer( attacker ) || self isenemyplayer( attacker ) == 0 )
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
		if ( level.lastobituaryplayercount >= 4 )
		{
			level notify( "reset_obituary_count" );
			level.lastobituaryplayercount = 0;
			level.lastobituaryplayer = undefined;
		}
	}
	overrideentitycamera = 0;
	if ( level.teambased && isDefined( attacker.pers ) && self.team == attacker.team && obituarymeansofdeath == "MOD_GRENADE" && level.friendlyfire == 0 )
	{
		obituary( self, self, obituaryweapon, obituarymeansofdeath );
		maps/mp/_demo::bookmark( "kill", getTime(), self, self, 0, einflictor, overrideentitycamera );
	}
	else
	{
		obituary( self, attacker, obituaryweapon, obituarymeansofdeath );
		maps/mp/_demo::bookmark( "kill", getTime(), self, attacker, 0, einflictor, overrideentitycamera );
	}
	if ( !level.ingraceperiod )
	{
		self maps/mp/gametypes_zm/_weapons::dropscavengerfordeath( attacker );
		self maps/mp/gametypes_zm/_weapons::dropweaponfordeath( attacker );
		self maps/mp/gametypes_zm/_weapons::dropoffhand();
	}
	maps/mp/gametypes_zm/_spawnlogic::deathoccured( self, attacker );
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";
	self.killedplayerscurrent = [];
	self.deathcount++;
/#
	println( "players(" + self.clientid + ") death count ++: " + self.deathcount );
#/
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
			self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "deaths", 1, 1, 1 );
			self.deaths = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "deaths" );
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
				if ( level.rankedmatch )
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
	pixendevent();
	self resetplayermomentumondeath();
	if ( isplayer( attacker ) )
	{
		lpattackguid = attacker getguid();
		lpattackname = attacker.name;
		lpattackteam = attacker.team;
		lpattackorigin = attacker.origin;
		if ( attacker == self )
		{
			dokillcam = 0;
			self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "suicides", 1 );
			self.suicides = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "suicides" );
			if ( smeansofdeath == "MOD_SUICIDE" && shitloc == "none" && self.throwinggrenade )
			{
				self.lastgrenadesuicidetime = getTime();
			}
			awardassists = 1;
			self.suicide = 1;
			if ( isDefined( self.friendlydamage ) )
			{
				self iprintln( &"MP_FRIENDLY_FIRE_WILL_NOT" );
				if ( level.teamkillpointloss )
				{
					scoresub = self [[ level.getteamkillscore ]]( einflictor, attacker, smeansofdeath, sweapon );
					maps/mp/gametypes_zm/_globallogic_score::_setplayerscore( attacker, maps/mp/gametypes_zm/_globallogic_score::_getplayerscore( attacker ) - scoresub );
				}
			}
		}
		else
		{
			pixbeginevent( "PlayerKilled attacker" );
			lpattacknum = attacker getentitynumber();
			dokillcam = 1;
			if ( level.teambased && self.team == attacker.team && smeansofdeath == "MOD_GRENADE" && level.friendlyfire == 0 )
			{
			}
			else
			{
				if ( level.teambased && self.team == attacker.team )
				{
					if ( !ignoreteamkills( sweapon, smeansofdeath ) )
					{
						teamkill_penalty = self [[ level.getteamkillpenalty ]]( einflictor, attacker, smeansofdeath, sweapon );
						attacker maps/mp/gametypes_zm/_globallogic_score::incpersstat( "teamkills_nostats", teamkill_penalty, 0 );
						attacker maps/mp/gametypes_zm/_globallogic_score::incpersstat( "teamkills", 1 );
						attacker.teamkillsthisround++;
						if ( level.teamkillpointloss )
						{
							scoresub = self [[ level.getteamkillscore ]]( einflictor, attacker, smeansofdeath, sweapon );
							maps/mp/gametypes_zm/_globallogic_score::_setplayerscore( attacker, maps/mp/gametypes_zm/_globallogic_score::_getplayerscore( attacker ) - scoresub );
						}
						if ( maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() < 5000 )
						{
							teamkilldelay = 1;
						}
						else if ( attacker.pers[ "teamkills_nostats" ] > 1 && maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() < ( 8000 + ( attacker.pers[ "teamkills_nostats" ] * 1000 ) ) )
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
							attacker suicide();
							if ( attacker shouldteamkillkick( teamkilldelay ) )
							{
								attacker teamkillkick();
							}
							attacker thread reduceteamkillsovertime();
						}
					}
				}
				else
				{
					maps/mp/gametypes_zm/_globallogic_score::inctotalkills( attacker.team );
					attacker thread maps/mp/gametypes_zm/_globallogic_score::givekillstats( smeansofdeath, sweapon, self );
					if ( isalive( attacker ) )
					{
						pixbeginevent( "killstreak" );
						if ( isDefined( einflictor ) || !isDefined( einflictor.requireddeathcount ) && attacker.deathcount == einflictor.requireddeathcount )
						{
							shouldgivekillstreak = 0;
							attacker.pers[ "cur_total_kill_streak" ]++;
							attacker setplayercurrentstreak( attacker.pers[ "cur_total_kill_streak" ] );
							if ( isDefined( level.killstreaks ) && shouldgivekillstreak )
							{
								attacker.pers[ "cur_kill_streak" ]++;
								if ( attacker.pers[ "cur_kill_streak" ] >= 3 )
								{
									if ( attacker.pers[ "cur_kill_streak" ] <= 30 )
									{
									}
								}
							}
						}
						pixendevent();
					}
					if ( attacker.pers[ "cur_kill_streak" ] > attacker.kill_streak )
					{
						if ( level.rankedmatch )
						{
							attacker setdstat( "HighestStats", "kill_streak", attacker.pers[ "totalKillstreakCount" ] );
						}
						attacker.kill_streak = attacker.pers[ "cur_kill_streak" ];
					}
					killstreak = undefined;
					if ( isDefined( killstreak ) )
					{
					}
					else if ( smeansofdeath == "MOD_HEAD_SHOT" )
					{
					}
					else if ( smeansofdeath == "MOD_MELEE" )
					{
						if ( sweapon == "riotshield_mp" )
						{
						}
					}
					attacker thread maps/mp/gametypes_zm/_globallogic_score::trackattackerkill( self.name, self.pers[ "rank" ], self.pers[ "rankxp" ], self.pers[ "prestige" ], self getxuid( 1 ) );
					attackername = attacker.name;
					self thread maps/mp/gametypes_zm/_globallogic_score::trackattackeedeath( attackername, attacker.pers[ "rank" ], attacker.pers[ "rankxp" ], attacker.pers[ "prestige" ], attacker getxuid( 1 ) );
					attacker thread maps/mp/gametypes_zm/_globallogic_score::inckillstreaktracker( sweapon );
					if ( level.teambased && attacker.team != "spectator" )
					{
						if ( isai( attacker ) )
						{
							maps/mp/gametypes_zm/_globallogic_score::giveteamscore( "kill", attacker.aiteam, attacker, self );
						}
						else
						{
							maps/mp/gametypes_zm/_globallogic_score::giveteamscore( "kill", attacker.team, attacker, self );
						}
					}
					scoresub = level.deathpointloss;
					if ( scoresub != 0 )
					{
						maps/mp/gametypes_zm/_globallogic_score::_setplayerscore( self, maps/mp/gametypes_zm/_globallogic_score::_getplayerscore( self ) - scoresub );
					}
					level thread playkillbattlechatter( attacker, sweapon, self );
					if ( level.teambased )
					{
						awardassists = 1;
					}
				}
			}
			pixendevent();
		}
	}
	else if ( isDefined( attacker ) || attacker.classname == "trigger_hurt" && attacker.classname == "worldspawn" )
	{
		dokillcam = 0;
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackteam = "world";
		self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "suicides", 1 );
		self.suicides = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "suicides" );
		awardassists = 1;
	}
	else
	{
		dokillcam = 0;
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackteam = "world";
		if ( isDefined( einflictor ) && isDefined( einflictor.killcament ) )
		{
			dokillcam = 1;
			lpattacknum = self getentitynumber();
		}
		if ( isDefined( attacker ) && isDefined( attacker.team ) && isDefined( level.teams[ attacker.team ] ) )
		{
			if ( attacker.team != self.team )
			{
				if ( level.teambased )
				{
					maps/mp/gametypes_zm/_globallogic_score::giveteamscore( "kill", attacker.team, attacker, self );
				}
			}
		}
		awardassists = 1;
	}
	if ( sessionmodeiszombiesgame() )
	{
		awardassists = 0;
	}
	if ( awardassists )
	{
		pixbeginevent( "PlayerKilled assists" );
		while ( isDefined( self.attackers ) )
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
				else if ( player == attacker )
				{
					j++;
					continue;
				}
				else if ( player.team != lpattackteam )
				{
					j++;
					continue;
				}
				else
				{
					damage_done = self.attackerdamage[ player.clientid ].damage;
					player thread maps/mp/gametypes_zm/_globallogic_score::processassist( self, damage_done, self.attackerdamage[ player.clientid ].weapon );
				}
				j++;
			}
		}
		if ( isDefined( self.lastattackedshieldplayer ) && isDefined( self.lastattackedshieldtime ) && self.lastattackedshieldplayer != attacker )
		{
			if ( ( getTime() - self.lastattackedshieldtime ) < 4000 )
			{
				self.lastattackedshieldplayer thread maps/mp/gametypes_zm/_globallogic_score::processshieldassist( self );
			}
		}
		pixendevent();
	}
	pixbeginevent( "PlayerKilled post constants" );
	self.lastattacker = attacker;
	self.lastdeathpos = self.origin;
	if ( isDefined( attacker ) && isplayer( attacker ) && attacker != self || !level.teambased && attacker.team != self.team )
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
		bbprint( "mpattacks", "gametime %d attackerspawnid %d attackerweapon %s attackerx %d attackery %d attackerz %d victimspawnid %d victimx %d victimy %d victimz %d damage %d damagetype %s damagelocation %s death %d", getTime(), getplayerspawnid( attacker ), sweapon, lpattackorigin, getplayerspawnid( self ), self.origin, idamage, smeansofdeath, shitloc, 1 );
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
	level thread maps/mp/gametypes_zm/_globallogic::updateteamstatus();
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
	self maps/mp/gametypes_zm/_weapons::detachcarryobjectmodel();
	died_in_vehicle = 0;
	if ( isDefined( self.diedonvehicle ) )
	{
		died_in_vehicle = self.diedonvehicle;
	}
	pixendevent();
	pixbeginevent( "PlayerKilled body and gibbing" );
	if ( !died_in_vehicle )
	{
		vattackerorigin = undefined;
		if ( isDefined( attacker ) )
		{
			vattackerorigin = attacker.origin;
		}
		ragdoll_now = 0;
		if ( isDefined( self.usingvehicle ) && self.usingvehicle && isDefined( self.vehicleposition ) && self.vehicleposition == 1 )
		{
			ragdoll_now = 1;
		}
		body = self cloneplayer( deathanimduration );
		self createdeadbody( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_now, body );
	}
	pixendevent();
	thread maps/mp/gametypes_zm/_globallogic_spawn::spawnqueuedclient( self.team, attacker );
	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;
	self thread [[ level.onplayerkilled ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	icb = 0;
	while ( icb < level.onplayerkilledextraunthreadedcbs.size )
	{
		self [[ level.onplayerkilledextraunthreadedcbs[ icb ] ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
		icb++;
	}
	self.wantsafespawn = 0;
	perks = [];
	killstreaks = maps/mp/gametypes_zm/_globallogic::getkillstreaks( attacker );
	if ( !isDefined( self.killstreak_waitamount ) )
	{
		self thread [[ level.spawnplayerprediction ]]();
	}
	profilelog_endtiming( 7, "gs=" + game[ "state" ] + " zom=" + sessionmodeiszombiesgame() );
	wait 0,25;
	weaponclass = getweaponclass( sweapon );
	self.cancelkillcam = 0;
	defaultplayerdeathwatchtime = 1,75;
	if ( isDefined( level.overrideplayerdeathwatchtimer ) )
	{
		defaultplayerdeathwatchtime = [[ level.overrideplayerdeathwatchtimer ]]( defaultplayerdeathwatchtime );
	}
	maps/mp/gametypes_zm/_globallogic_utils::waitfortimeornotifies( defaultplayerdeathwatchtime );
	self notify( "death_delay_finished" );
/#
	if ( getDvarInt( #"C1849218" ) != 0 )
	{
		dokillcam = 1;
		if ( lpattacknum < 0 )
		{
			lpattacknum = self getentitynumber();
#/
		}
	}
	if ( game[ "state" ] != "playing" )
	{
		return;
	}
	self.respawntimerstarttime = getTime();
	if ( !self.cancelkillcam && dokillcam && level.killcam )
	{
		if ( level.numliveslivesleft = self.pers[ "lives" ];
		timeuntilspawn = maps/mp/gametypes_zm/_globallogic_spawn::timeuntilspawn( 1 );
		 && livesleft && timeuntilspawn <= 0 )
		{
			willrespawnimmediately = !level.playerqueuedrespawn;
		}
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
	if ( maps/mp/gametypes_zm/_globallogic_utils::isvalidclass( self.class ) )
	{
		timepassed = undefined;
		if ( isDefined( self.respawntimerstarttime ) )
		{
			timepassed = ( getTime() - self.respawntimerstarttime ) / 1000;
		}
		self thread [[ level.spawnclient ]]( timepassed );
		self.respawntimerstarttime = undefined;
	}
}

updateglobalbotkilledcounter()
{
	if ( isDefined( self.pers[ "isBot" ] ) )
	{
		level.globallarryskilled++;
	}
}

waittillkillstreakdone()
{
	if ( isDefined( self.killstreak_waitamount ) )
	{
		starttime = getTime();
		waittime = self.killstreak_waitamount * 1000;
		while ( getTime() < ( starttime + waittime ) && isDefined( self.killstreak_waitamount ) )
		{
			wait 0,1;
		}
		wait 2;
		self.killstreak_waitamount = undefined;
	}
}

teamkillkick()
{
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "sessionbans", 1 );
	self endon( "disconnect" );
	waittillframeend;
	playlistbanquantum = maps/mp/gametypes_zm/_tweakables::gettweakablevalue( "team", "teamkillerplaylistbanquantum" );
	playlistbanpenalty = maps/mp/gametypes_zm/_tweakables::gettweakablevalue( "team", "teamkillerplaylistbanpenalty" );
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
	if ( self is_bot() )
	{
		level notify( "bot_kicked" );
	}
	ban( self getentitynumber() );
	maps/mp/gametypes_zm/_globallogic_audio::leaderdialog( "kicked" );
}

teamkilldelay()
{
	teamkills = self.pers[ "teamkills_nostats" ];
	if ( level.minimumallowedteamkills < 0 || teamkills <= level.minimumallowedteamkills )
	{
		return 0;
	}
	exceeded = teamkills - level.minimumallowedteamkills;
	return level.teamkillspawndelay * exceeded;
}

shouldteamkillkick( teamkilldelay )
{
	if ( teamkilldelay && level.minimumallowedteamkills >= 0 )
	{
		if ( maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() >= 5000 )
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

reduceteamkillsovertime()
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
				return;
			}
		}
		else
		{
			wait 1;
		}
	}
}

ignoreteamkills( sweapon, smeansofdeath )
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

callback_playerlaststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
}

damageshellshockandrumble( eattacker, einflictor, sweapon, smeansofdeath, idamage )
{
	self thread maps/mp/gametypes_zm/_weapons::onweapondamage( eattacker, einflictor, sweapon, smeansofdeath, idamage );
	self playrumbleonentity( "damage_heavy" );
}

createdeadbody( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body )
{
	if ( smeansofdeath == "MOD_HIT_BY_OBJECT" && self getstance() == "prone" )
	{
		self.body = body;
		return;
	}
	if ( isDefined( level.ragdoll_override ) && self [[ level.ragdoll_override ]]() )
	{
		return;
	}
	if ( !ragdoll_jib && !self isonladder() && !self ismantling() || smeansofdeath == "MOD_CRUSH" && smeansofdeath == "MOD_HIT_BY_OBJECT" )
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
	self.body = body;
}

is_explosive_ragdoll( weapon, inflictor )
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

start_explosive_ragdoll( dir, weapon )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	x = randomintrange( 50, 100 );
	y = randomintrange( 50, 100 );
	z = randomintrange( 10, 20 );
	if ( isDefined( weapon ) || weapon == "sticky_grenade_mp" && weapon == "explosive_bolt_mp" )
	{
		if ( isDefined( dir ) && lengthsquared( dir ) > 0 )
		{
			x = dir[ 0 ] * x;
			y = dir[ 1 ] * y;
		}
	}
	else
	{
		if ( cointoss() )
		{
			x *= -1;
		}
		if ( cointoss() )
		{
			y *= -1;
		}
	}
	self startragdoll();
	self launchragdoll( ( x, y, z ) );
}

notifyconnecting()
{
	waittillframeend;
	if ( isDefined( self ) )
	{
		level notify( "connecting" );
	}
}

delaystartragdoll( ent, shitloc, vdir, sweapon, einflictor, smeansofdeath )
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
		explosionpos = ent.origin + ( 0, 0, maps/mp/gametypes_zm/_globallogic_utils::gethitlocheight( shitloc ) );
		explosionpos -= vdir * 20;
		explosionradius = 40;
		explosionforce = 0,75;
		if ( smeansofdeath != "MOD_IMPACT" && smeansofdeath != "MOD_EXPLOSIVE" && !issubstr( smeansofdeath, "MOD_GRENADE" ) && !issubstr( smeansofdeath, "MOD_PROJECTILE" ) || shitloc == "head" && shitloc == "helmet" )
		{
			explosionforce = 2,5;
		}
		ent startragdoll( 1 );
		wait 0,05;
		if ( !isDefined( ent ) )
		{
			return;
		}
		physicsexplosionsphere( explosionpos, explosionradius, explosionradius / 2, explosionforce );
		return;
	}
	wait 0,2;
	if ( !isDefined( ent ) )
	{
		return;
	}
	if ( ent isragdoll() )
	{
		return;
	}
	deathanim = ent getcorpseanim();
	startfrac = 0,35;
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

trackattackerdamage( eattacker, idamage, smeansofdeath, sweapon )
{
/#
	assert( isplayer( eattacker ) );
#/
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
	if ( maps/mp/gametypes_zm/_weapons::isprimaryweapon( sweapon ) )
	{
		self.attackerdata[ eattacker.clientid ] = 1;
	}
}

giveinflictorownerassist( eattacker, einflictor, idamage, smeansofdeath, sweapon )
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
/#
	assert( isplayer( einflictor.owner ) );
#/
	self trackattackerdamage( einflictor.owner, idamage, smeansofdeath, sweapon );
}

updatemeansofdeath( sweapon, smeansofdeath )
{
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

updateattacker( attacker, weapon )
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
		attacker notify( "killed" );
		attacker = attacker.owner;
	}
	if ( isai( attacker ) )
	{
		attacker notify( "killed" );
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
	return attacker;
}

updateinflictor( einflictor )
{
	if ( isDefined( einflictor ) && einflictor.classname == "script_vehicle" )
	{
		einflictor notify( "killed" );
		if ( isDefined( einflictor.bda ) )
		{
			einflictor.bda++;
		}
	}
	return einflictor;
}

updateweapon( einflictor, sweapon )
{
	if ( sweapon == "none" && isDefined( einflictor ) )
	{
		if ( isDefined( einflictor.targetname ) && einflictor.targetname == "explodable_barrel" )
		{
			sweapon = "explodable_barrel_mp";
		}
		else
		{
			if ( isDefined( einflictor.destructible_type ) && issubstr( einflictor.destructible_type, "vehicle_" ) )
			{
				sweapon = "destructible_car_mp";
			}
		}
	}
	return sweapon;
}

getclosestkillcamentity( attacker, killcamentities, depth )
{
	if ( !isDefined( depth ) )
	{
		depth = 0;
	}
	closestkillcament = undefined;
	closestkillcamentindex = undefined;
	closestkillcamentdist = undefined;
	origin = undefined;
	_a2792 = killcamentities;
	killcamentindex = getFirstArrayKey( _a2792 );
	while ( isDefined( killcamentindex ) )
	{
		killcament = _a2792[ killcamentindex ];
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
		killcamentindex = getNextArrayKey( _a2792, killcamentindex );
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

getkillcamentity( attacker, einflictor, sweapon )
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
		if ( isDefined( einflictor.ismagicbullet ) && !einflictor.ismagicbullet )
		{
			return undefined;
		}
	}
	else
	{
		if ( isDefined( level.levelspecifickillcam ) )
		{
			levelspecifickillcament = self [[ level.levelspecifickillcam ]]();
			if ( isDefined( levelspecifickillcament ) )
			{
				return levelspecifickillcament;
			}
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
	else
	{
		if ( isDefined( einflictor.killcamentities ) )
		{
			return getclosestkillcamentity( attacker, einflictor.killcamentities );
		}
	}
	if ( isDefined( einflictor.script_gameobjectname ) && einflictor.script_gameobjectname == "bombzone" )
	{
		return einflictor.killcament;
	}
	return einflictor;
}

playkillbattlechatter( attacker, sweapon, victim )
{
}
