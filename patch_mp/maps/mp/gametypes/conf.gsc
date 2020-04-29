#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_objpoints;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_spawnlogic;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

main()
{
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	registertimelimit( 0, 1440 );
	registerscorelimit( 0, 50000 );
	registerroundlimit( 0, 10 );
	registerroundswitch( 0, 9 );
	registerroundwinlimit( 0, 10 );
	registernumlives( 0, 100 );
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.scoreroundbased = 1;
	level.teambased = 1;
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onroundendgame = ::onroundendgame;
	level.onplayerkilled = ::onplayerkilled;
	level.onroundswitch = ::onroundswitch;
	level.overrideteamscore = 1;
	level.teamscoreperkill = getgametypesetting( "teamScorePerKill" );
	level.teamscoreperkillconfirmed = getgametypesetting( "teamScorePerKillConfirmed" );
	level.teamscoreperkilldenied = getgametypesetting( "teamScorePerKillDenied" );
	level.antiboostdistance = getgametypesetting( "antiBoostDistance" );
	game[ "dialog" ][ "gametype" ] = "kc_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "kc_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	game[ "dialog" ][ "kc_deny" ] = "kc_deny";
	game[ "dialog" ][ "kc_start" ] = "kc_start";
	game[ "dialog" ][ "kc_denied" ] = "mpl_kc_killdeny";
	level.conf_fx[ "vanish" ] = loadfx( "maps/mp_maps/fx_mp_kill_confirmed_vanish" );
	if ( !sessionmodeissystemlink() && !sessionmodeisonlinegame() && issplitscreen() )
	{
		setscoreboardcolumns( "score", "kills", "killsconfirmed", "killsdenied", "deaths" );
	}
	else
	{
		setscoreboardcolumns( "score", "kills", "deaths", "killsconfirmed", "killsdenied" );
	}
}

onprecachegametype()
{
	precachemodel( "p6_dogtags" );
	precachemodel( "p6_dogtags_friend" );
	precacheshader( "waypoint_dogtags" );
	precachestring( &"MP_KILL_DENIED" );
}

onstartgametype()
{
	setclientnamemode( "auto_change" );
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
	allowed[ 0 ] = level.gametype;
	maps/mp/gametypes/_gameobjects::main( allowed );
	level.spawnmins = ( 0, 0, 1 );
	level.spawnmaxs = ( 0, 0, 1 );
	_a109 = level.teams;
	_k109 = getFirstArrayKey( _a109 );
	while ( isDefined( _k109 ) )
	{
		team = _a109[ _k109 ];
		setobjectivetext( team, &"OBJECTIVES_CONF" );
		setobjectivehinttext( team, &"OBJECTIVES_CONF_HINT" );
		if ( level.splitscreen )
		{
			setobjectivescoretext( team, &"OBJECTIVES_CONF" );
		}
		else
		{
			setobjectivescoretext( team, &"OBJECTIVES_CONF_SCORE" );
		}
		maps/mp/gametypes/_spawnlogic::placespawnpoints( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, "mp_tdm_spawn" );
		_k109 = getNextArrayKey( _a109, _k109 );
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
	level.spawn_start = [];
	_a131 = level.teams;
	_k131 = getFirstArrayKey( _a131 );
	while ( isDefined( _k131 ) )
	{
		team = _a131[ _k131 ];
		level.spawn_start[ team ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
		_k131 = getNextArrayKey( _a131, _k131 );
	}
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	level.dogtags = [];
	if ( !isoneround() )
	{
		level.displayroundendtext = 1;
		if ( isscoreroundbased() )
		{
			maps/mp/gametypes/_globallogic_score::resetteamscores();
		}
	}
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( !isplayer( attacker ) || attacker.team == self.team )
	{
		return;
	}
	level thread spawndogtags( self, attacker );
	attacker maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( attacker.team, level.teamscoreperkill );
}

spawndogtags( victim, attacker )
{
	if ( isDefined( level.dogtags[ victim.entnum ] ) )
	{
		playfx( level.conf_fx[ "vanish" ], level.dogtags[ victim.entnum ].curorigin );
		level.dogtags[ victim.entnum ] notify( "reset" );
	}
	else
	{
		visuals[ 0 ] = spawn( "script_model", ( 0, 0, 1 ) );
		visuals[ 0 ] setmodel( "p6_dogtags" );
		visuals[ 1 ] = spawn( "script_model", ( 0, 0, 1 ) );
		visuals[ 1 ] setmodel( "p6_dogtags_friend" );
		trigger = spawn( "trigger_radius", ( 0, 0, 1 ), 0, 32, 32 );
		level.dogtags[ victim.entnum ] = maps/mp/gametypes/_gameobjects::createuseobject( "any", trigger, visuals, vectorScale( ( 0, 0, 1 ), 16 ) );
		_a189 = level.teams;
		_k189 = getFirstArrayKey( _a189 );
		while ( isDefined( _k189 ) )
		{
			team = _a189[ _k189 ];
			objective_delete( level.dogtags[ victim.entnum ].objid[ team ] );
			maps/mp/gametypes/_gameobjects::releaseobjid( level.dogtags[ victim.entnum ].objid[ team ] );
			maps/mp/gametypes/_objpoints::deleteobjpoint( level.dogtags[ victim.entnum ].objpoints[ team ] );
			_k189 = getNextArrayKey( _a189, _k189 );
		}
		level.dogtags[ victim.entnum ] maps/mp/gametypes/_gameobjects::setusetime( 0 );
		level.dogtags[ victim.entnum ].onuse = ::onuse;
		level.dogtags[ victim.entnum ].victim = victim;
		level.dogtags[ victim.entnum ].victimteam = victim.team;
		level.dogtags[ victim.entnum ].objid = maps/mp/gametypes/_gameobjects::getnextobjid();
		objective_add( level.dogtags[ victim.entnum ].objid, "invisible", ( 0, 0, 1 ) );
		objective_icon( level.dogtags[ victim.entnum ].objid, "waypoint_dogtags" );
		level thread clearonvictimdisconnect( victim );
		victim thread tagteamupdater( level.dogtags[ victim.entnum ] );
	}
	pos = victim.origin + vectorScale( ( 0, 0, 1 ), 14 );
	level.dogtags[ victim.entnum ].curorigin = pos;
	level.dogtags[ victim.entnum ].trigger.origin = pos;
	level.dogtags[ victim.entnum ].visuals[ 0 ].origin = pos;
	level.dogtags[ victim.entnum ].visuals[ 1 ].origin = pos;
	level.dogtags[ victim.entnum ] maps/mp/gametypes/_gameobjects::allowuse( "any" );
	level.dogtags[ victim.entnum ].visuals[ 0 ] thread showtoteam( level.dogtags[ victim.entnum ], attacker.team );
	level.dogtags[ victim.entnum ].visuals[ 1 ] thread showtoenemyteams( level.dogtags[ victim.entnum ], attacker.team );
	level.dogtags[ victim.entnum ].attacker = attacker;
	level.dogtags[ victim.entnum ].attackerteam = attacker.team;
	level.dogtags[ victim.entnum ].unreachable = undefined;
	level.dogtags[ victim.entnum ].tacinsert = 0;
	objective_position( level.dogtags[ victim.entnum ].objid, pos );
	objective_state( level.dogtags[ victim.entnum ].objid, "active" );
	objective_setinvisibletoall( level.dogtags[ victim.entnum ].objid );
	objective_setvisibletoplayer( level.dogtags[ victim.entnum ].objid, attacker );
	level.dogtags[ victim.entnum ] thread bounce();
	level notify( "dogtag_spawned" );
}

showtoteam( gameobject, team )
{
	gameobject endon( "death" );
	gameobject endon( "reset" );
	self hide();
	_a245 = level.players;
	_k245 = getFirstArrayKey( _a245 );
	while ( isDefined( _k245 ) )
	{
		player = _a245[ _k245 ];
		if ( player.team == team )
		{
			self showtoplayer( player );
		}
		_k245 = getNextArrayKey( _a245, _k245 );
	}
	for ( ;; )
	{
		level waittill( "joined_team" );
		self hide();
		_a256 = level.players;
		_k256 = getFirstArrayKey( _a256 );
		while ( isDefined( _k256 ) )
		{
			player = _a256[ _k256 ];
			if ( player.team == team )
			{
				self showtoplayer( player );
			}
			if ( gameobject.victimteam == player.team && player == gameobject.attacker )
			{
				objective_state( gameobject.objid, "invisible" );
			}
			_k256 = getNextArrayKey( _a256, _k256 );
		}
	}
}

showtoenemyteams( gameobject, friend_team )
{
	gameobject endon( "death" );
	gameobject endon( "reset" );
	self hide();
	_a274 = level.players;
	_k274 = getFirstArrayKey( _a274 );
	while ( isDefined( _k274 ) )
	{
		player = _a274[ _k274 ];
		if ( player.team != friend_team )
		{
			self showtoplayer( player );
		}
		_k274 = getNextArrayKey( _a274, _k274 );
	}
	for ( ;; )
	{
		level waittill( "joined_team" );
		self hide();
		_a285 = level.players;
		_k285 = getFirstArrayKey( _a285 );
		while ( isDefined( _k285 ) )
		{
			player = _a285[ _k285 ];
			if ( player.team != friend_team )
			{
				self showtoplayer( player );
			}
			if ( gameobject.victimteam == player.team && player == gameobject.attacker )
			{
				objective_state( gameobject.objid, "invisible" );
			}
			_k285 = getNextArrayKey( _a285, _k285 );
		}
	}
}

onuse( player )
{
	tacinsertboost = 0;
	if ( player.team != self.attackerteam )
	{
		self.trigger playsound( "mpl_killconfirm_tags_pickup" );
		player addplayerstat( "KILLSDENIED", 1 );
		player recordgameevent( "return" );
		if ( self.victim == player )
		{
			if ( self.tacinsert == 0 )
			{
				event = "retrieve_own_tags";
				splash = &"SPLASHES_TAGS_RETRIEVED";
			}
			else
			{
				tacinsertboost = 1;
			}
		}
		else
		{
			event = "kill_denied";
			splash = &"SPLASHES_KILL_DENIED";
		}
		if ( isDefined( self.attacker ) && self.attacker.team == self.attackerteam )
		{
			self.attacker luinotifyevent( &"player_callout", 2, &"MP_KILL_DENIED", player.entnum );
			self.attacker playlocalsound( game[ "dialog" ][ "kc_denied" ] );
		}
		if ( !tacinsertboost )
		{
			player maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "kc_deny" );
			player maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( player.team, level.teamscoreperkilldenied );
			player.pers[ "killsdenied" ]++;
			player.killsdenied = player.pers[ "killsdenied" ];
		}
	}
	else
	{
		self.trigger playsound( "mpl_killconfirm_tags_pickup" );
		event = "kill_confirmed";
		splash = &"SPLASHES_KILL_CONFIRMED";
		player addplayerstat( "KILLSCONFIRMED", 1 );
		player recordgameevent( "capture" );
/#
		assert( isDefined( player.lastkillconfirmedtime ) );
		assert( isDefined( player.lastkillconfirmedcount ) );
#/
		if ( self.attacker != player )
		{
			self.attacker thread onpickup( "teammate_kill_confirmed", splash );
		}
		player maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "kc_start" );
		player.pers[ "killsconfirmed" ]++;
		player.killsconfirmed = player.pers[ "killsconfirmed" ];
		player maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( player.team, level.teamscoreperkillconfirmed );
	}
	if ( !tacinsertboost )
	{
		player thread onpickup( event, splash );
		currenttime = getTime();
		if ( ( player.lastkillconfirmedtime + 1000 ) > currenttime )
		{
			player.lastkillconfirmedcount++;
			if ( player.lastkillconfirmedcount >= 3 )
			{
				maps/mp/_scoreevents::processscoreevent( "kill_confirmed_multi", player );
				player.lastkillconfirmedcount = 0;
			}
		}
		else
		{
			player.lastkillconfirmedcount = 1;
		}
		player.lastkillconfirmedtime = currenttime;
	}
	self resettags();
}

onpickup( event, splash )
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	while ( !isDefined( self.pers ) )
	{
		wait 0,05;
	}
	maps/mp/_scoreevents::processscoreevent( event, self );
}

resettags()
{
	self.attacker = undefined;
	self.unreachable = undefined;
	self notify( "reset" );
	self.visuals[ 0 ] hide();
	self.visuals[ 1 ] hide();
	self.curorigin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.trigger.origin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.visuals[ 0 ].origin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.visuals[ 1 ].origin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.tacinsert = 0;
	self maps/mp/gametypes/_gameobjects::allowuse( "none" );
	objective_state( self.objid, "invisible" );
}

bounce()
{
	level endon( "game_ended" );
	self endon( "reset" );
	bottompos = self.curorigin;
	toppos = self.curorigin + vectorScale( ( 0, 0, 1 ), 12 );
	while ( 1 )
	{
		self.visuals[ 0 ] moveto( toppos, 0,5, 0,15, 0,15 );
		self.visuals[ 0 ] rotateyaw( 180, 0,5 );
		self.visuals[ 1 ] moveto( toppos, 0,5, 0,15, 0,15 );
		self.visuals[ 1 ] rotateyaw( 180, 0,5 );
		wait 0,5;
		self.visuals[ 0 ] moveto( bottompos, 0,5, 0,15, 0,15 );
		self.visuals[ 0 ] rotateyaw( 180, 0,5 );
		self.visuals[ 1 ] moveto( bottompos, 0,5, 0,15, 0,15 );
		self.visuals[ 1 ] rotateyaw( 180, 0,5 );
		wait 0,5;
	}
}

timeout( victim )
{
	level endon( "game_ended" );
	victim endon( "disconnect" );
	self notify( "timeout" );
	self endon( "timeout" );
	level maps/mp/gametypes/_hostmigration::waitlongdurationwithhostmigrationpause( 30 );
	self.visuals[ 0 ] hide();
	self.visuals[ 1 ] hide();
	self.curorigin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.trigger.origin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.visuals[ 0 ].origin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.visuals[ 1 ].origin = vectorScale( ( 0, 0, 1 ), 1000 );
	self.tacinsert = 0;
	self maps/mp/gametypes/_gameobjects::allowuse( "none" );
}

tagteamupdater( tags )
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "joined_team" );
		tags.victimteam = self.team;
		tags resettags();
	}
}

clearonvictimdisconnect( victim )
{
	level endon( "game_ended" );
	guid = victim.entnum;
	victim waittill( "disconnect" );
	if ( isDefined( level.dogtags[ guid ] ) )
	{
		level.dogtags[ guid ] maps/mp/gametypes/_gameobjects::allowuse( "none" );
		playfx( level.conf_fx[ "vanish" ], level.dogtags[ guid ].curorigin );
		level.dogtags[ guid ] notify( "reset" );
		wait 0,05;
		if ( isDefined( level.dogtags[ guid ] ) )
		{
			objective_delete( level.dogtags[ guid ].objid );
			level.dogtags[ guid ].trigger delete();
			i = 0;
			while ( i < level.dogtags[ guid ].visuals.size )
			{
				level.dogtags[ guid ].visuals[ i ] delete();
				i++;
			}
			level.dogtags[ guid ] notify( "deleted" );
		}
	}
}

onspawnplayerunified()
{
	self.usingobj = undefined;
	if ( level.usestartspawns && !level.ingraceperiod )
	{
		level.usestartspawns = 0;
	}
	self.lastkillconfirmedtime = 0;
	self.lastkillconfirmedcount = 0;
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
	if ( level.rankedmatch || level.leaguematch )
	{
		if ( isDefined( self.tacticalinsertiontime ) && ( self.tacticalinsertiontime + 100 ) > getTime() )
		{
			mindist = level.antiboostdistance;
			mindistsqr = mindist * mindist;
			distsqr = distancesquared( self.origin, level.dogtags[ self.entnum ].curorigin );
			if ( distsqr < mindistsqr )
			{
				level.dogtags[ self.entnum ].tacinsert = 1;
			}
		}
	}
}

onspawnplayer( predictedspawn )
{
	pixbeginevent( "TDM:onSpawnPlayer" );
	self.usingobj = undefined;
	spawnteam = self.pers[ "team" ];
	if ( level.ingraceperiod )
	{
		spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( spawnteam ) );
		if ( !spawnpoints.size )
		{
			spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( spawnteam ) );
		}
		if ( !spawnpoints.size )
		{
			spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( spawnteam );
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( spawnpoints );
		}
		else
		{
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( spawnpoints );
		}
	}
	else
	{
		spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( spawnteam );
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( spawnpoints );
	}
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "tdm" );
	}
	pixendevent();
}

onroundswitch()
{
	game[ "switchedsides" ] = !game[ "switchedsides" ];
}

onroundendgame( roundwinner )
{
	return maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "roundswon" );
}
