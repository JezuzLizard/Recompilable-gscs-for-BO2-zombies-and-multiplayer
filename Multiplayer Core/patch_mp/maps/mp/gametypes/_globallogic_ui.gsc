//checked includes match cerberus output
#include maps/mp/gametypes/_class;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/gametypes/_spectating;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_pregame;
#include maps/mp/teams/_teams;
#include maps/mp/bots/_bot;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	precachestring( &"MP_HALFTIME" );
	precachestring( &"MP_OVERTIME" );
	precachestring( &"MP_ROUNDEND" );
	precachestring( &"MP_INTERMISSION" );
	precachestring( &"MP_SWITCHING_SIDES_CAPS" );
	precachestring( &"MP_FRIENDLY_FIRE_WILL_NOT" );
	precachestring( &"MP_RAMPAGE" );
	precachestring( &"medal_received" );
	precachestring( &"killstreak_received" );
	precachestring( &"prox_grenade_notify" );
	precachestring( &"player_callout" );
	precachestring( &"score_event" );
	precachestring( &"rank_up" );
	precachestring( &"gun_level_complete" );
	precachestring( &"challenge_complete" );
	if ( level.splitscreen )
	{
		precachestring( &"MP_ENDED_GAME" );
	}
	else
	{
		precachestring( &"MP_HOST_ENDED_GAME" );
	}
}

setupcallbacks() //checked matches cerberus output
{
	level.autoassign = ::menuautoassign;
	level.spectator = ::menuspectator;
	level.class = ::menuclass;
	level.teammenu = ::menuteam;
}

hideloadoutaftertime( delay ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "perks_hidden" );
	wait delay;
	self thread hideallperks( 0.4 );
	self notify( "perks_hidden" );
}

hideloadoutondeath() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "perks_hidden" );
	self waittill( "death" );
	self hideallperks();
	self notify( "perks_hidden" );
}

hideloadoutonkill() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "perks_hidden" );
	self waittill( "killed_player" );
	self hideallperks();
	self notify( "perks_hidden" );
}

freegameplayhudelems() //checked changed to match cerberus output
{
	if ( isDefined( self.perkicon ) )
	{
		for ( numspecialties = 0; numspecialties < level.maxspecialties; numspecialties++ )
		{
			if ( isDefined( self.perkicon[ numspecialties ] ) )
			{
				self.perkicon[ numspecialties ] destroyelem();
				self.perkname[ numspecialties ] destroyelem();
			}
		}
	}
	if ( isDefined( self.perkhudelem ) )
	{
		self.perkhudelem destroyelem();
	}
	if ( isDefined( self.killstreakicon ) )
	{
		if ( isDefined( self.killstreakicon[ 0 ] ) )
		{
			self.killstreakicon[ 0 ] destroyelem();
		}
		if ( isDefined( self.killstreakicon[ 1 ] ) )
		{
			self.killstreakicon[ 1 ] destroyelem();
		}
		if ( isDefined( self.killstreakicon[ 2 ] ) )
		{
			self.killstreakicon[ 2 ] destroyelem();
		}
		if ( isDefined( self.killstreakicon[ 3 ] ) )
		{
			self.killstreakicon[ 3 ] destroyelem();
		}
		if ( isDefined( self.killstreakicon[ 4 ] ) )
		{
			self.killstreakicon[ 4 ] destroyelem();
		}
	}
	self notify( "perks_hidden" );
	if ( isDefined( self.lowermessage ) )
	{
		self.lowermessage destroyelem();
	}
	if ( isDefined( self.lowertimer ) )
	{
		self.lowertimer destroyelem();
	}
	if ( isDefined( self.proxbar ) )
	{
		self.proxbar destroyelem();
	}
	if ( isDefined( self.proxbartext ) )
	{
		self.proxbartext destroyelem();
	}
	if ( isDefined( self.carryicon ) )
	{
		self.carryicon destroyelem();
	}
	maps/mp/killstreaks/_killstreaks::destroykillstreaktimers();
}

teamplayercountsequal( playercounts ) //checked partially changed to match cerberus output did not use continue see github for more info
{
	count = undefined;
	foreach ( team in level.teams )
	{
		if ( !isDefined( count ) )
		{
			count = playercounts[ team ];
		}
		else
		{
			if ( count != playercounts[ team ] )
			{
				return 0;
			}
		}
	}
	return 1;
}

teamwithlowestplayercount( playercounts, ignore_team ) //checked changed to match cerberus output
{
	count = 9999;
	lowest_team = undefined;
	foreach ( team in level.teams )
	{
		if ( count > playercounts[ team ] )
		{
			count = playercounts[ team ];
			lowest_team = team;
		}
	}
	return lowest_team;
}

menuautoassign( comingfrommenu ) //checked changed to match cerberus output
{
	teamkeys = getarraykeys( level.teams );
	assignment = teamkeys[ randomint( teamkeys.size ) ];
	self closemenus();
	if ( is_true( level.forceallallies ) )
	{
		assignment = "allies";
	}
	else if ( level.teambased )
	{
		if ( getDvarInt( "party_autoteams" ) == 1 )
		{
			if ( level.allow_teamchange == "1" || self.hasspawned && comingfrommenu )
			{
				assignment = "";
			}
		}
		else
		{
			team = getassignedteam( self );
			switch( team )
			{
				case 1:
					assignment = teamkeys[ 1 ];
					break;
				case 2:
					assignment = teamkeys[ 0 ];
					break;
				case 3:
					assignment = teamkeys[ 2 ];
					break;
				case 4:
					if ( !isDefined( level.forceautoassign ) || !level.forceautoassign )
					{
						self setclientscriptmainmenu( game[ "menu_class" ] );
						return;
					}
				default:
					assignment = "";
					if ( isDefined( level.teams[ team ] ) )
					{
						assignment = team;
					}
					else if ( team == "spectator" && !level.forceautoassign )
					{
						self setclientscriptmainmenu( game[ "menu_class" ] );
						return;
					}
			}
		}
		if ( assignment == "" || getDvarInt( "party_autoteams" ) == 0 )
		{
			if ( sessionmodeiszombiesgame() )
			{
				assignment = "allies";
			}
			else if ( maps/mp/bots/_bot::is_bot_comp_stomp() )
			{
				host = gethostplayerforbots();
				/*
/#
				assert( isDefined( host ) );
#/
				*/
				if ( !isDefined( host.team ) || host.team == "spectator" )
				{
					host.team = random( teamkeys );
				}
				if ( !self is_bot() )
				{
					assignment = host.team;
				}
				else
				{
					assignment = getotherteam( host.team );
				}
			}
			else 
			{
				playercounts = self maps/mp/teams/_teams::countplayers();
				if ( teamplayercountsequal( playercounts ) )
				{
					if ( !level.splitscreen && self issplitscreen() )
					{
						assignment = self getsplitscreenteam();
						if ( assignment == "" )
						{
							assignment = pickteamfromscores( teamkeys );
						}
					}
					else
					{
						assignment = pickteamfromscores( teamkeys );
					}
				}
				else
				{
					assignment = teamwithlowestplayercount( playercounts, "none" );
				}
			}
		}
		if ( assignment == self.pers[ "team" ] && self.sessionstate == "playing" || self.sessionstate == "dead" )
		{
			self beginclasschoice();
			return;
		}
	}
	else if ( getDvarInt( "party_autoteams" ) == 1 )
	{
		if ( level.allow_teamchange != "1" || !self.hasspawned && !comingfrommenu )
		{
			team = getassignedteam( self );
			if ( isDefined( level.teams[ team ] ) )
			{
				assignment = team;
			}
			else if ( team == "spectator" && !level.forceautoassign )
			{
				self setclientscriptmainmenu( game[ "menu_class" ] );
				return;
			}
		}
	}
	if ( assignment != self.pers[ "team" ] && self.sessionstate == "playing" || self.sessionstate == "dead" )
	{
		self.switching_teams = 1;
		self.joining_team = assignment;
		self.leaving_team = self.pers[ "team" ];
		self suicide();
	}
	self.pers[ "team" ] = assignment;
	self.team = assignment;
	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self updateobjectivetext();
	if ( level.teambased )
	{
		self.sessionteam = assignment;
	}
	else
	{
		self.sessionteam = "none";
		self.ffateam = assignment;
	}
	if ( !isalive( self ) )
	{
		self.statusicon = "hud_status_dead";
	}
	self notify( "joined_team" );
	level notify( "joined_team" );
	self notify( "end_respawn" );
	if ( ispregame() )
	{
		if ( !self is_bot() )
		{
			pclass = self maps/mp/gametypes/_pregame::get_pregame_class();
			self closemenu();
			self closeingamemenu();
			self.selectedclass = 1;
			self [[ level.class ]]( pclass );
			self setclientscriptmainmenu( game[ "menu_class" ] );
			return;
		}
	}
	if ( ispregamegamestarted() )
	{
		if ( self is_bot() && isDefined( self.pers[ "class" ] ) )
		{
			pclass = self.pers[ "class" ];
			self closemenu();
			self closeingamemenu();
			self.selectedclass = 1;
			self [[ level.class ]]( pclass );
			return;
		}
	}
	self beginclasschoice();
	self setclientscriptmainmenu( game[ "menu_class" ] );
}

teamscoresequal() //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	score = undefined;
	foreach ( team in level.teams )
	{
		if ( !isDefined( score ) )
		{
			score = getteamscore( team );
		}
		else
		{
			if ( score != getteamscore( team ) )
			{
				return 0;
			}
		}
	}
	return 1;
}

teamwithlowestscore()
{
	score = 99999999;
	lowest_team = undefined;
	foreach ( team in level.teams )
	{
		if ( score > getteamscore( team ) )
		{
			lowest_team = team;
		}
	}
	return lowest_team;
}

pickteamfromscores( teams ) //checked matches cerberus output
{
	assignment = "allies";
	if ( teamscoresequal() )
	{
		assignment = teams[ randomint( teams.size ) ];
	}
	else
	{
		assignment = teamwithlowestscore();
	}
	return assignment;
}

getsplitscreenteam() //checked partially changed to match cerberus output did not use for loop see github for more info
{
	index = 0;
	while ( index < level.players.size )
	{
		if ( !isDefined( level.players[ index ] ) )
		{
			index++;
			continue;
		}
		if ( level.players[ index ] == self )
		{
			index++;
			continue;
		}
		if ( !self isplayeronsamemachine( level.players[ index ] ) )
		{
			index++;
			continue;
		}
		team = level.players[ index ].sessionteam;
		if ( team != "spectator" )
		{
			return team;
		}
		index++;
	}
	return "";
}

updateobjectivetext() //checked matches cerberus output
{
	if ( sessionmodeiszombiesgame() || self.pers[ "team" ] == "spectator" )
	{
		self setclientcgobjectivetext( "" );
		return;
	}
	if ( level.scorelimit > 0 )
	{
		self setclientcgobjectivetext( getobjectivescoretext( self.pers[ "team" ] ) );
	}
	else
	{
		self setclientcgobjectivetext( getobjectivetext( self.pers[ "team" ] ) );
	}
}

closemenus() //checked matches cerberus output
{
	self closemenu();
	self closeingamemenu();
}

beginclasschoice( forcenewchoice ) //checked matches cerberus output
{
	/*
/#
	assert( isDefined( level.teams[ self.pers[ "team" ] ] ) );
#/
	*/
	team = self.pers[ "team" ];
	if ( level.disableclassselection == 1 || getDvarInt( "migration_soak" ) == 1 )
	{
		self.pers[ "class" ] = level.defaultclass;
		self.class = level.defaultclass;
		if ( self.sessionstate != "playing" && game[ "state" ] == "playing" )
		{
			self thread [[ level.spawnclient ]]();
		}
		level thread maps/mp/gametypes/_globallogic::updateteamstatus();
		self thread maps/mp/gametypes/_spectating::setspectatepermissionsformachine();
		return;
	}
	if ( level.wagermatch )
	{
		self openmenu( game[ "menu_changeclass_wager" ] );
	}
	else if ( getDvarInt( "barebones_class_mode" ) )
	{
		self openmenu( game[ "menu_changeclass_barebones" ] );
	}
	else
	{
		self openmenu( game[ "menu_changeclass_" + team ] );
	}
}

showmainmenuforteam() //checked matches cerberus output
{
	/*
/#
	assert( isDefined( level.teams[ self.pers[ "team" ] ] ) );
#/
	*/
	team = self.pers[ "team" ];
	if ( level.wagermatch )
	{
		self openmenu( game[ "menu_changeclass_wager" ] );
	}
	else
	{
		self openmenu( game[ "menu_changeclass_" + team ] );
	}
}

menuteam( team ) //checked changed to match cerberus output
{
	self closemenus();
	if ( !level.console && level.allow_teamchange == "0" && is_true( self.hasdonecombat ) )
	{
		return;
	}
	if ( self.pers[ "team" ] != team )
	{
		if ( level.ingraceperiod && !isDefined( self.hasdonecombat ) || !self.hasdonecombat )
		{
			self.hasspawned = 0;
		}
		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = 1;
			self.joining_team = team;
			self.leaving_team = self.pers[ "team" ];
			self suicide();
		}
		self.pers[ "team" ] = team;
		self.team = team;
		self.pers[ "class" ] = undefined;
		self.class = undefined;
		self.pers[ "weapon" ] = undefined;
		self.pers[ "savedmodel" ] = undefined;
		self updateobjectivetext();
		if ( !level.rankedmatch && !level.leaguematch )
		{
			self.sessionstate = "spectator";
		}
		if ( level.teambased )
		{
			self.sessionteam = team;
		}
		else
		{
			self.sessionteam = "none";
			self.ffateam = team;
		}
		self setclientscriptmainmenu( game[ "menu_class" ] );
		self notify( "joined_team" );
		level notify( "joined_team" );
		self notify( "end_respawn" );
	}
	self beginclasschoice();
}

menuspectator() //checked changed to match cerberus output
{
	self closemenus();
	if ( self.pers[ "team" ] != "spectator" )
	{
		if ( isalive( self ) )
		{
			self.switching_teams = 1;
			self.joining_team = "spectator";
			self.leaving_team = self.pers[ "team" ];
			self suicide();
		}
		self.pers[ "team" ] = "spectator";
		self.team = "spectator";
		self.pers[ "class" ] = undefined;
		self.class = undefined;
		self.pers[ "weapon" ] = undefined;
		self.pers[ "savedmodel" ] = undefined;
		self updateobjectivetext();
		self.sessionteam = "spectator";
		if ( !level.teambased )
		{
			self.ffateam = "spectator";
		}
		[[ level.spawnspectator ]]();
		self thread maps/mp/gametypes/_globallogic_player::spectate_player_watcher();
		self setclientscriptmainmenu( game[ "menu_class" ] );
		self notify( "joined_spectators" );
	}
}

menuclass( response ) //checked changed to match cerberus output
{
	self closemenus();
	if ( !isDefined( self.pers[ "team" ] ) || !isDefined( level.teams[ self.pers[ "team" ] ] ) )
	{
		return;
	}
	class = self maps/mp/gametypes/_class::getclasschoice( response );
	if ( isDefined( self.pers[ "class" ] ) && self.pers[ "class" ] == class )
	{
		return;
	}
	self.pers[ "changed_class" ] = 1;
	self notify( "changed_class" );
	if ( isDefined( self.curclass ) && self.curclass == class )
	{
		self.pers[ "changed_class" ] = 0;
	}
	if ( ispregame() )
	{
		self maps/mp/gametypes/_pregame::onplayerclasschange( response );
	}
	if ( self.sessionstate == "playing" )
	{
		self.pers[ "class" ] = class;
		self.class = class;
		if ( game[ "state" ] == "postgame" )
		{
			return;
		}
		if ( isDefined( self.usingsupplystation ) )
		{
			supplystationclasschange = self.usingsupplystation;
		}
		self.usingsupplystation = 0;
		if ( level.ingraceperiod && !self.hasdonecombat || supplystationclasschange )
		{
			self maps/mp/gametypes/_class::setclass( self.pers[ "class" ] );
			self.tag_stowed_back = undefined;
			self.tag_stowed_hip = undefined;
			self maps/mp/gametypes/_class::giveloadout( self.pers[ "team" ], self.pers[ "class" ] );
			self maps/mp/killstreaks/_killstreaks::giveownedkillstreak();
		}
		else if ( !self issplitscreen() )
		{
			self iprintlnbold( game[ "strings" ][ "change_class" ] );
		}
	}
	else
	{
		self.pers[ "class" ] = class;
		self.class = class;
		self.pers[ "weapon" ] = undefined;
		if ( game[ "state" ] == "postgame" )
		{
			return;
		}
		if ( self.sessionstate != "spectator" )
		{
			if ( self isinvehicle() )
			{
				return;
			}
			if ( self isremotecontrolling() )
			{
				return;
			}
			if ( self isweaponviewonlylinked() )
			{
				return 0;
			}
		}
		if ( game[ "state" ] == "playing" )
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
	level thread maps/mp/gametypes/_globallogic::updateteamstatus();
	self thread maps/mp/gametypes/_spectating::setspectatepermissionsformachine();
}

removespawnmessageshortly( delay ) //checked matches cerberus output
{
	self endon( "disconnect" );
	waittillframeend;
	self endon( "end_respawn" );
	wait delay;
	self clearlowermessage( 2 );
}

