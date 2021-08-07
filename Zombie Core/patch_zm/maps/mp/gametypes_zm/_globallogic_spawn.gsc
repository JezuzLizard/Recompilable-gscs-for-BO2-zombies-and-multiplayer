#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/gametypes_zm/_globallogic_defaults;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/gametypes_zm/_spectating;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/gametypes_zm/_globallogic_audio;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/gametypes_zm/_globallogic_player;
#include maps/mp/_utility;
#include common_scripts/utility;

timeuntilspawn( includeteamkilldelay ) //checked matches cerberus output
{
	if ( level.ingraceperiod && !self.hasspawned )
	{
		return 0;
	}
	respawndelay = 0;
	if ( self.hasspawned )
	{
		result = self [[ level.onrespawndelay ]]();
		if ( isDefined( result ) )
		{
			respawndelay = result;
		}
		else
		{
			respawndelay = level.playerrespawndelay;
		}
		if ( includeteamkilldelay && isDefined( self.teamkillpunish ) && self.teamkillpunish )
		{
			respawndelay += maps/mp/gametypes_zm/_globallogic_player::teamkilldelay();
		}
	}
	wavebased = level.waverespawndelay > 0;
	if ( wavebased )
	{
		return self timeuntilwavespawn( respawndelay );
	}
	return respawndelay;
}

allteamshaveexisted() //checked changed to match cerberus output
{
	foreach ( team in level.teams )
	{
		if ( !level.everexisted[ team ] )
		{
			return 0;
		}
	}
	return 1;
}

mayspawn() //checked partially changed to match cerberus output changed at own discretion
{
	if ( isDefined( level.mayspawn ) && !( self [[ level.mayspawn ]]() ) )
	{
		return 0;
	}
	if ( level.inovertime )
	{
		return 0;
	}
	if ( level.playerqueuedrespawn && !isDefined( self.allowqueuespawn ) && !level.ingraceperiod && !level.usestartspawns )
	{
		return 0;
	}
	if ( level.numlives )
	{
		if ( level.teambased )
		{
			gamehasstarted = allteamshaveexisted();
		}
		else
		{
			gamehasstarted = level.maxplayercount > 1;
			if ( gamehasstarted == 0 )
			{
				if ( !isoneround() && !isfirstround() )
				{
					gamehasstarted = 1;
				}
				else
				{
					gamehasstarted = 0;
				}
			}
		}
		if ( !self.pers[ "lives" ] && gamehasstarted )
		{
			return 0;
		}
		else if ( gamehasstarted )
		{
			if ( !level.ingraceperiod && !self.hasspawned && !level.wagermatch )
			{
				return 0;
			}
		}
	}
	return 1;
}

timeuntilwavespawn( minimumwait ) //checked matches cerberus output
{
	earliestspawntime = getTime() + ( minimumwait * 1000 );
	lastwavetime = level.lastwave[ self.pers[ "team" ] ];
	wavedelay = level.wavedelay[ self.pers[ "team" ] ] * 1000;
	if ( wavedelay == 0 )
	{
		return 0;
	}
	numwavespassedearliestspawntime = ( earliestspawntime - lastwavetime ) / wavedelay;
	numwaves = ceil( numwavespassedearliestspawntime );
	timeofspawn = lastwavetime + ( numwaves * wavedelay );
	if ( isDefined( self.wavespawnindex ) )
	{
		timeofspawn += 50 * self.wavespawnindex;
	}
	return ( timeofspawn - getTime() ) / 1000;
}

stoppoisoningandflareonspawn() //checked matches cerberus output
{
	self endon( "disconnect" );
	self.inpoisonarea = 0;
	self.inburnarea = 0;
	self.inflarevisionarea = 0;
	self.ingroundnapalm = 0;
}

spawnplayerprediction() //checked changed to match cerberus output dvar taken from beta dump
{
	self endon( "disconnect" );
	self endon( "end_respawn" );
	self endon( "game_ended" );
	self endon( "joined_spectators" );
	self endon( "spawned" );
	while ( 1 )
	{
		wait 0.5;
		if ( isDefined( level.onspawnplayerunified ) && getDvarInt( "scr_disableunifiedspawning" ) == 0 )
		{
			maps/mp/gametypes_zm/_spawning::onspawnplayer_unified( 1 );
		}
		else
		{
			self [[ level.onspawnplayer ]]( 1 );
		}
	}
}

giveloadoutlevelspecific( team, class ) //checked matches cerberus output
{
	pixbeginevent( "giveLoadoutLevelSpecific" );
	if ( isDefined( level.givecustomcharacters ) )
	{
		self [[ level.givecustomcharacters ]]();
	}
	if ( isDefined( level.givecustomloadout ) )
	{
		self [[ level.givecustomloadout ]]();
	}
	pixendevent();
}

spawnplayer() //checked matches cerberus output dvars taken from beta dump
{
	pixbeginevent( "spawnPlayer_preUTS" );
	self endon( "disconnect" );
	self endon( "joined_spectators" );
	self notify( "spawned" );
	level notify( "player_spawned" );
	self notify( "end_respawn" );
	self setspawnvariables();
	if ( !self.hasspawned )
	{
		self.underscorechance = 70;
		self thread maps/mp/gametypes_zm/_globallogic_audio::sndstartmusicsystem();
	}
	if ( level.teambased )
	{
		self.sessionteam = self.team;
	}
	else
	{
		self.sessionteam = "none";
		self.ffateam = self.team;
	}
	hadspawned = self.hasspawned;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";
	self.damagedplayers = [];
	if ( getDvarInt( "scr_csmode" ) > 0 )
	{
		self.maxhealth = getDvarInt( "scr_csmode" );
	}
	else
	{
		self.maxhealth = level.playermaxhealth;
	}
	self.health = self.maxhealth;
	self.friendlydamage = undefined;
	self.hasspawned = 1;
	self.spawntime = getTime();
	self.afk = 0;
	if ( self.pers[ "lives" ] && !isDefined( level.takelivesondeath ) || level.takelivesondeath == 0 )
	{
		self.pers[ "lives" ]--;
		if ( self.pers[ "lives" ] == 0 )
		{
			level notify( "player_eliminated" );
			self notify( "player_eliminated" );
		}
	}
	self.laststand = undefined;
	self.revivingteammate = 0;
	self.burning = undefined;
	self.nextkillstreakfree = undefined;
	self.activeuavs = 0;
	self.activecounteruavs = 0;
	self.activesatellites = 0;
	self.deathmachinekills = 0;
	self.disabledweapon = 0;
	self resetusability();
	self maps/mp/gametypes_zm/_globallogic_player::resetattackerlist();
	self.diedonvehicle = undefined;
	if ( !self.wasaliveatmatchstart )
	{
		if ( level.ingraceperiod || maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() < 20000 )
		{
			self.wasaliveatmatchstart = 1;
		}
	}
	self setdepthoffield( 0, 0, 512, 512, 4, 0 );
	self resetfov();
	pixbeginevent( "onSpawnPlayer" );
	if ( isDefined( level.onspawnplayerunified ) && getDvarInt( "scr_disableunifiedspawning" ) == 0 )
	{
		self [[ level.onspawnplayerunified ]]();
	}
	else
	{
		self [[ level.onspawnplayer ]]( 0 );
	}
	if ( isDefined( level.playerspawnedcb ) )
	{
		self [[ level.playerspawnedcb ]]();
	}
	pixendevent();
	pixendevent();
	level thread maps/mp/gametypes_zm/_globallogic::updateteamstatus();
	pixbeginevent( "spawnPlayer_postUTS" );
	self thread stoppoisoningandflareonspawn();
	self stopburning();
	/*
/#
	assert( maps/mp/gametypes_zm/_globallogic_utils::isvalidclass( self.class ) );
#/
	*/
	self giveloadoutlevelspecific( self.team, self.class );
	if ( level.inprematchperiod )
	{
		self freeze_player_controls( 1 );
		team = self.pers[ "team" ];
		if ( isDefined( self.pers[ "music" ].spawn ) && self.pers[ "music" ].spawn == 0 )
		{
			if ( level.wagermatch )
			{
				music = "SPAWN_WAGER";
			}
			else
			{
				music = game[ "music" ][ "spawn_" + team ];
			}
			self thread maps/mp/gametypes_zm/_globallogic_audio::set_music_on_player( music, 0, 0 );
			self.pers[ "music" ].spawn = 1;
		}
		if ( level.splitscreen )
		{
			if ( isDefined( level.playedstartingmusic ) )
			{
				music = undefined;
			}
			else
			{
				level.playedstartingmusic = 1;
			}
		}
		if ( !isDefined( level.disableprematchmessages ) || level.disableprematchmessages == 0 )
		{
			thread maps/mp/gametypes_zm/_hud_message::showinitialfactionpopup( team );
			hintmessage = getobjectivehinttext( self.pers[ "team" ] );
			if ( isDefined( hintmessage ) )
			{
				self thread maps/mp/gametypes_zm/_hud_message::hintmessage( hintmessage );
			}
			if ( isDefined( game[ "dialog" ][ "gametype" ] ) && !level.splitscreen || self == level.players[ 0 ] )
			{
				if ( !isDefined( level.infinalfight ) || !level.infinalfight )
				{
					if ( level.hardcoremode )
					{
						self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "gametype_hardcore" );
					}
					else
					{
						self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "gametype" );
					}
				}
			}
			if ( team == game[ "attackers" ] )
			{
				self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "offense_obj", "introboost" );
			}
			else
			{
				self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "defense_obj", "introboost" );
			}
		}
	}
	else
	{
		self freeze_player_controls( 0 );
		self enableweapons();
		if ( !hadspawned && game[ "state" ] == "playing" )
		{
			pixbeginevent( "sound" );
			team = self.team;
			if ( isDefined( self.pers[ "music" ].spawn ) && self.pers[ "music" ].spawn == 0 )
			{
				self thread maps/mp/gametypes_zm/_globallogic_audio::set_music_on_player( "SPAWN_SHORT", 0, 0 );
				self.pers[ "music" ].spawn = 1;
			}
			if ( level.splitscreen )
			{
				if ( isDefined( level.playedstartingmusic ) )
				{
					music = undefined;
				}
				else
				{
					level.playedstartingmusic = 1;
				}
			}
			if ( !isDefined( level.disableprematchmessages ) || level.disableprematchmessages == 0 )
			{
				thread maps/mp/gametypes_zm/_hud_message::showinitialfactionpopup( team );
				hintmessage = getobjectivehinttext( self.pers[ "team" ] );
				if ( isDefined( hintmessage ) )
				{
					self thread maps/mp/gametypes_zm/_hud_message::hintmessage( hintmessage );
				}
				if ( isDefined( game[ "dialog" ][ "gametype" ] ) || !level.splitscreen && self == level.players[ 0 ] )
				{
					if ( !isDefined( level.infinalfight ) || !level.infinalfight )
					{
						if ( level.hardcoremode )
						{
							self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "gametype_hardcore" );
						}
						else
						{
							self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "gametype" );
						}
					}
				}
				if ( team == game[ "attackers" ] )
				{
					self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "offense_obj", "introboost" );
				}
				else
				{
					self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( "defense_obj", "introboost" );
				}
			}
			pixendevent();
		}
	}
	if ( getDvar( "scr_showperksonspawn" ) == "" )
	{
		setdvar( "scr_showperksonspawn", "0" );
	}
	if ( level.hardcoremode )
	{
		setdvar( "scr_showperksonspawn", "0" );
	}
	if ( !level.splitscreen && getDvarInt( "scr_showperksonspawn" ) == 1 && game[ "state" ] != "postgame" )
	{
		pixbeginevent( "showperksonspawn" );
		if ( level.perksenabled == 1 )
		{
			self maps/mp/gametypes_zm/_hud_util::showperks();
		}
		self thread maps/mp/gametypes_zm/_globallogic_ui::hideloadoutaftertime( 3 );
		self thread maps/mp/gametypes_zm/_globallogic_ui::hideloadoutondeath();
		pixendevent();
	}
	if ( isDefined( self.pers[ "momentum" ] ) )
	{
		self.momentum = self.pers[ "momentum" ];
	}
	pixendevent();
	waittillframeend;
	self notify( "spawned_player" );
	self logstring( "S " + self.origin[ 0 ] + " " + self.origin[ 1 ] + " " + self.origin[ 2 ] );
	setdvar( "scr_selecting_location", "" );
	/*
/#
	if ( getDvarInt( "scr_xprate" ) > 0 )
	{
		self thread maps/mp/gametypes_zm/_globallogic_score::xpratethread();
#/
	}
	*/
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	if ( game[ "state" ] == "postgame" )
	{
		/*
/#
		assert( !level.intermission );
#/
		*/
		self maps/mp/gametypes_zm/_globallogic_player::freezeplayerforroundend();
	}
}

spawnspectator( origin, angles ) //checked matches cerberus output
{
	self notify( "spawned" );
	self notify( "end_respawn" );
	in_spawnspectator( origin, angles );
}

respawn_asspectator( origin, angles ) //checked matches cerberus output
{
	in_spawnspectator( origin, angles );
}

in_spawnspectator( origin, angles ) //checked matches cerberus output
{
	pixmarker( "BEGIN: in_spawnSpectator" );
	self setspawnvariables();
	if ( self.pers[ "team" ] == "spectator" )
	{
		self clearlowermessage();
	}
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	if ( self.pers[ "team" ] == "spectator" )
	{
		self.statusicon = "";
	}
	else
	{
		self.statusicon = "hud_status_dead";
	}
	maps/mp/gametypes_zm/_spectating::setspectatepermissionsformachine();
	[[ level.onspawnspectator ]]( origin, angles );
	if ( level.teambased && !level.splitscreen )
	{
		self thread spectatorthirdpersonness();
	}
	level thread maps/mp/gametypes_zm/_globallogic::updateteamstatus();
	pixmarker( "END: in_spawnSpectator" );
}

spectatorthirdpersonness() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "spawned" );
	self notify( "spectator_thirdperson_thread" );
	self endon( "spectator_thirdperson_thread" );
	self.spectatingthirdperson = 0;
}

forcespawn( time ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "spawned" );
	if ( !isDefined( time ) )
	{
		time = 60;
	}
	wait time;
	if ( self.hasspawned )
	{
		return;
	}
	if ( self.pers[ "team" ] == "spectator" )
	{
		return;
	}
	if ( !maps/mp/gametypes_zm/_globallogic_utils::isvalidclass( self.pers[ "class" ] ) )
	{
		self.pers[ "class" ] = "CLASS_CUSTOM1";
		self.class = self.pers[ "class" ];
	}
	self maps/mp/gametypes_zm/_globallogic_ui::closemenus();
	self thread [[ level.spawnclient ]]();
}

kickifdontspawn() //checked matches cerberus output
{
	/*
/#
	if ( getDvarInt( "scr_hostmigrationtest" ) == 1 )
	{
		return;
#/
	}
	*/
	if ( self ishost() )
	{
		return;
	}
	self kickifidontspawninternal();
}

kickifidontspawninternal() //checked matches cerberus output dvars taken from beta dump
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "spawned" );
	waittime = 90;
	if ( getDvar( "scr_kick_time" ) != "" )
	{
		waittime = getDvarFloat( "scr_kick_time" );
	}
	mintime = 45;
	if ( getDvar( scr_kick_mintime) != "" )
	{
		mintime = getDvarFloat( scr_kick_mintime);
	}
	starttime = getTime();
	kickwait( waittime );
	timepassed = ( getTime() - starttime ) / 1000;
	if ( timepassed < ( waittime - 0.1 ) && timepassed < mintime )
	{
		return;
	}
	if ( self.hasspawned )
	{
		return;
	}
	if ( sessionmodeisprivate() )
	{
		return;
	}
	if ( self.pers[ "team" ] == "spectator" )
	{
		return;
	}
	kick( self getentitynumber() );
}

kickwait( waittime ) //checked matches cerberus output
{
	level endon( "game_ended" );
	maps/mp/gametypes_zm/_hostmigration::waitlongdurationwithhostmigrationpause( waittime );
}

spawninterroundintermission() //checked matches cerberus output
{
	self notify( "spawned" );
	self notify( "end_respawn" );
	self setspawnvariables();
	self clearlowermessage();
	self freeze_player_controls( 0 );
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	self maps/mp/gametypes_zm/_globallogic_defaults::default_onspawnintermission();
	self setorigin( self.origin );
	self setplayerangles( self.angles );
	self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

spawnintermission( usedefaultcallback ) //checked changed to match cerberus output
{
	self notify( "spawned" );
	self notify( "end_respawn" );
	self endon( "disconnect" );
	self setspawnvariables();
	self clearlowermessage();
	self freeze_player_controls( 0 );
	if ( level.rankedmatch && waslastround() )
	{
		if ( self.postgamemilestones || self.postgamecontracts || self.postgamepromotion )
		{
			if ( self.postgamepromotion )
			{
				self playlocalsound( "mus_level_up" );
			}
			else if ( self.postgamecontracts )
			{
				self playlocalsound( "mus_challenge_complete" );
			}
			else
			{
				if ( self.postgamemilestones )
				{
					self playlocalsound( "mus_contract_complete" );
				}
			}
			self closeingamemenu();
			self openmenu( game[ "menu_endgameupdate" ] );
			waittime = 4;
			while ( waittime )
			{
				wait 0.25;
				waittime -= 0.25;
				self openmenu( game[ "menu_endgameupdate" ] );
			}
			self closemenu();
		}
	}
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	if ( isDefined( usedefaultcallback ) && usedefaultcallback )
	{
		maps/mp/gametypes_zm/_globallogic_defaults::default_onspawnintermission();
	}
	else
	{
		[[ level.onspawnintermission ]]();
	}
	self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

spawnqueuedclientonteam( team ) //checked partially changed to match cerberus output see info.md
{
	player_to_spawn = undefined;
	for ( i = 0; i < level.deadplayers[team].size; i++ )
	{
		player = level.deadplayers[ team ][ i ];
		if ( player.waitingtospawn )
		{
		}
		else
		{
			player_to_spawn = player;
			break;
		}
	}
	if ( isDefined( player_to_spawn ) )
	{
		player_to_spawn.allowqueuespawn = 1;
		player_to_spawn maps/mp/gametypes_zm/_globallogic_ui::closemenus();
		player_to_spawn thread [[ level.spawnclient ]]();
	}
}

spawnqueuedclient( dead_player_team, killer ) //checked partially changed to match cerberus output see info.md
{
	if ( !level.playerqueuedrespawn )
	{
		return;
	}
	maps/mp/gametypes_zm/_globallogic_utils::waittillslowprocessallowed();
	spawn_team = undefined;
	if ( isDefined( killer ) && isDefined( killer.team ) && isDefined( level.teams[ killer.team ] ) )
	{
		spawn_team = killer.team;
	}
	if ( isDefined( spawn_team ) )
	{
		spawnqueuedclientonteam( spawn_team );
		return;
	}
	foreach ( team in level.teams )
	{
		if ( team == dead_player_team )
		{
		}
		else
		{
			spawnqueuedclientonteam( team );
		}
	}
}

allteamsnearscorelimit() //checked changed to match cerberus output
{
	if ( !level.teambased )
	{
		return 0;
	}
	if ( level.scorelimit <= 1 )
	{
		return 0;
	}
	foreach ( team in level.teams )
	{
		if ( !( game[ "teamScores" ][ team ] >= ( level.scoreLimit - 1 ) ) )
		{
			return 0;
		}
	}
	return 1;
}

shouldshowrespawnmessage() //checked matches cerberus output
{
	if ( waslastround() )
	{
		return 0;
	}
	if ( isoneround() )
	{
		return 0;
	}
	if ( isDefined( level.livesdonotreset ) && level.livesdonotreset )
	{
		return 0;
	}
	if ( allteamsnearscorelimit() )
	{
		return 0;
	}
	return 1;
}

default_spawnmessage() //checked matches cerberus output
{
	setlowermessage( game[ "strings" ][ "spawn_next_round" ] );
	self thread maps/mp/gametypes_zm/_globallogic_ui::removespawnmessageshortly( 3 );
}

showspawnmessage() //checked matches cerberus output
{
	if ( shouldshowrespawnmessage() )
	{
		self thread [[ level.spawnmessage ]]();
	}
}

spawnclient( timealreadypassed ) //checked matches cerberus output
{
	pixbeginevent( "spawnClient" );
	/*
/#
	assert( isDefined( self.team ) );
#/
/#
	assert( maps/mp/gametypes_zm/_globallogic_utils::isvalidclass( self.class ) );
#/
	*/
	if ( !self mayspawn() )
	{
		currentorigin = self.origin;
		currentangles = self.angles;
		self showspawnmessage();
		self thread [[ level.spawnspectator ]]( currentorigin + vectorScale( ( 0, 0, 1 ), 60 ), currentangles );
		pixendevent();
		return;
	}
	if ( self.waitingtospawn )
	{
		pixendevent();
		return;
	}
	self.waitingtospawn = 1;
	self.allowqueuespawn = undefined;
	self waitandspawnclient( timealreadypassed );
	if ( isDefined( self ) )
	{
		self.waitingtospawn = 0;
	}
	pixendevent();
}

waitandspawnclient( timealreadypassed ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_respawn" );
	level endon( "game_ended" );
	if ( !isDefined( timealreadypassed ) )
	{
		timealreadypassed = 0;
	}
	spawnedasspectator = 0;
	if ( isDefined( self.teamkillpunish ) && self.teamkillpunish )
	{
		teamkilldelay = maps/mp/gametypes_zm/_globallogic_player::teamkilldelay();
		if ( teamkilldelay > timealreadypassed )
		{
			teamkilldelay -= timealreadypassed;
			timealreadypassed = 0;
		}
		else
		{
			timealreadypassed -= teamkilldelay;
			teamkilldelay = 0;
		}
		if ( teamkilldelay > 0 )
		{
			setlowermessage( &"MP_FRIENDLY_FIRE_WILL_NOT", teamkilldelay );
			self thread respawn_asspectator( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), self.angles );
			spawnedasspectator = 1;
			wait teamkilldelay;
		}
		self.teamkillpunish = 0;
	}
	if ( !isDefined( self.wavespawnindex ) && isDefined( level.waveplayerspawnindex[ self.team ] ) )
	{
		self.wavespawnindex = level.waveplayerspawnindex[ self.team ];
		level.waveplayerspawnindex[ self.team ]++;
	}
	timeuntilspawn = timeuntilspawn( 0 );
	if ( timeuntilspawn > timealreadypassed )
	{
		timeuntilspawn -= timealreadypassed;
		timealreadypassed = 0;
	}
	else
	{
		timealreadypassed -= timeuntilspawn;
		timeuntilspawn = 0;
	}
	if ( timeuntilspawn > 0 )
	{
		if ( level.playerqueuedrespawn )
		{
			setlowermessage( game[ "strings" ][ "you_will_spawn" ], timeuntilspawn );
		}
		else if ( self issplitscreen() )
		{
			setlowermessage( game[ "strings" ][ "waiting_to_spawn_ss" ], timeuntilspawn, 1 );
		}
		else
		{
			setlowermessage( game[ "strings" ][ "waiting_to_spawn" ], timeuntilspawn );
		}
		if ( !spawnedasspectator )
		{
			spawnorigin = self.origin + vectorScale( ( 0, 0, 1 ), 60 );
			spawnangles = self.angles;
			if ( isDefined( level.useintermissionpointsonwavespawn ) && [[ level.useintermissionpointsonwavespawn ]]() == 1 )
			{
				spawnpoint = maps/mp/gametypes_zm/_spawnlogic::getrandomintermissionpoint();
				if ( isDefined( spawnpoint ) )
				{
					spawnorigin = spawnpoint.origin;
					spawnangles = spawnpoint.angles;
				}
			}
			self thread respawn_asspectator( spawnorigin, spawnangles );
		}
		spawnedasspectator = 1;
		self maps/mp/gametypes_zm/_globallogic_utils::waitfortimeornotify( timeuntilspawn, "force_spawn" );
		self notify( "stop_wait_safe_spawn_button" );
	}
	wavebased = level.waverespawndelay > 0;
	if ( !level.playerforcerespawn && self.hasspawned && !wavebased && !self.wantsafespawn && !level.playerqueuedrespawn )
	{
		setlowermessage( game[ "strings" ][ "press_to_spawn" ] );
		if ( !spawnedasspectator )
		{
			self thread respawn_asspectator( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), self.angles );
		}
		spawnedasspectator = 1;
		self waitrespawnorsafespawnbutton();
	}
	self.waitingtospawn = 0;
	self clearlowermessage();
	self.wavespawnindex = undefined;
	self.respawntimerstarttime = undefined;
	self thread [[ level.spawnplayer ]]();
}

waitrespawnorsafespawnbutton() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "end_respawn" );
	while ( 1 )
	{
		if ( self usebuttonpressed() )
		{
			return;
		}
		wait 0.05;
	}
}

waitinspawnqueue() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_respawn" );
	if ( !level.ingraceperiod && !level.usestartspawns )
	{
		currentorigin = self.origin;
		currentangles = self.angles;
		self thread [[ level.spawnspectator ]]( currentorigin + vectorScale( ( 0, 0, 1 ), 60 ), currentangles );
		self waittill( "queue_respawn" );
	}
}

setthirdperson( value ) //checked matches cerberus output
{
	if ( !level.console )
	{
		return;
	}
	if ( !isDefined( self.spectatingthirdperson ) || value != self.spectatingthirdperson )
	{
		self.spectatingthirdperson = value;
		if ( value )
		{
			self setclientthirdperson( 1 );
			self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
		}
		else
		{
			self setclientthirdperson( 0 );
			self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
		}
		self resetfov();
	}
}

setspawnvariables() //checked matches cerberus output
{
	resettimeout();
	self stopshellshock();
	self stoprumble( "damage_heavy" );
}

