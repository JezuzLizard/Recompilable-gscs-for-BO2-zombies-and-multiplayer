#include maps/mp/gametypes_zm/_globallogic_player;
#include maps/mp/gametypes_zm/_spectating;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

init()
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
	if ( sessionmodeiszombiesgame() )
	{
		precachestring( &"hud_update_survival_team" );
	}
	if ( level.splitscreen )
	{
		precachestring( &"MP_ENDED_GAME" );
	}
	else
	{
		precachestring( &"MP_HOST_ENDED_GAME" );
	}
}

setupcallbacks()
{
	level.autoassign = ::menuautoassign;
	level.spectator = ::menuspectator;
	level.class = ::menuclass;
	level.teammenu = ::menuteam;
}

hideloadoutaftertime( delay )
{
	self endon( "disconnect" );
	self endon( "perks_hidden" );
	wait delay;
	self thread hideallperks( 0,4 );
	self notify( "perks_hidden" );
}

hideloadoutondeath()
{
	self endon( "disconnect" );
	self endon( "perks_hidden" );
	self waittill( "death" );
	self hideallperks();
	self notify( "perks_hidden" );
}

hideloadoutonkill()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "perks_hidden" );
	self waittill( "killed_player" );
	self hideallperks();
	self notify( "perks_hidden" );
}

freegameplayhudelems()
{
	while ( isDefined( self.perkicon ) )
	{
		numspecialties = 0;
		while ( numspecialties < level.maxspecialties )
		{
			if ( isDefined( self.perkicon[ numspecialties ] ) )
			{
				self.perkicon[ numspecialties ] destroyelem();
				self.perkname[ numspecialties ] destroyelem();
			}
			numspecialties++;
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
}

teamplayercountsequal( playercounts )
{
	count = undefined;
	_a150 = level.teams;
	_k150 = getFirstArrayKey( _a150 );
	while ( isDefined( _k150 ) )
	{
		team = _a150[ _k150 ];
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
		_k150 = getNextArrayKey( _a150, _k150 );
	}
	return 1;
}

teamwithlowestplayercount( playercounts, ignore_team )
{
	count = 9999;
	lowest_team = undefined;
	_a169 = level.teams;
	_k169 = getFirstArrayKey( _a169 );
	while ( isDefined( _k169 ) )
	{
		team = _a169[ _k169 ];
		if ( count > playercounts[ team ] )
		{
			count = playercounts[ team ];
			lowest_team = team;
		}
		_k169 = getNextArrayKey( _a169, _k169 );
	}
	return lowest_team;
}

menuautoassign( comingfrommenu )
{
	teamkeys = getarraykeys( level.teams );
	assignment = teamkeys[ randomint( teamkeys.size ) ];
	self closemenus();
	if ( isDefined( level.forceallallies ) && level.forceallallies )
	{
		assignment = "allies";
	}
	else
	{
		if ( level.teambased )
		{
			if ( getDvarInt( "party_autoteams" ) == 1 )
			{
				if ( level.allow_teamchange == "1" || self.hasspawned && comingfrommenu )
				{
					assignment = "";
					break;
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
							else
							{
								if ( team == "spectator" && !level.forceautoassign )
								{
									self setclientscriptmainmenu( game[ "menu_class" ] );
									return;
								}
							}
					}
				}
			}
			if ( assignment == "" || getDvarInt( "party_autoteams" ) == 0 )
			{
				if ( sessionmodeiszombiesgame() )
				{
					assignment = "allies";
				}
			}
			if ( assignment == self.pers[ "team" ] || self.sessionstate == "playing" && self.sessionstate == "dead" )
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
				else
				{
					if ( team == "spectator" && !level.forceautoassign )
					{
						self setclientscriptmainmenu( game[ "menu_class" ] );
						return;
					}
				}
			}
		}
	}
	if ( assignment != self.pers[ "team" ] || self.sessionstate == "playing" && self.sessionstate == "dead" )
	{
		self.switching_teams = 1;
		self.joining_team = assignment;
		self.leaving_team = self.pers[ "team" ];
		self suicide();
	}
	self.pers[ "team" ] = assignment;
	self.team = assignment;
	self.class = undefined;
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
	self beginclasschoice();
	self setclientscriptmainmenu( game[ "menu_class" ] );
}

teamscoresequal()
{
	score = undefined;
	_a413 = level.teams;
	_k413 = getFirstArrayKey( _a413 );
	while ( isDefined( _k413 ) )
	{
		team = _a413[ _k413 ];
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
		_k413 = getNextArrayKey( _a413, _k413 );
	}
	return 1;
}

teamwithlowestscore()
{
	score = 99999999;
	lowest_team = undefined;
	_a432 = level.teams;
	_k432 = getFirstArrayKey( _a432 );
	while ( isDefined( _k432 ) )
	{
		team = _a432[ _k432 ];
		if ( score > getteamscore( team ) )
		{
			lowest_team = team;
		}
		_k432 = getNextArrayKey( _a432, _k432 );
	}
	return lowest_team;
}

pickteamfromscores( teams )
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

getsplitscreenteam()
{
	index = 0;
	while ( index < level.players.size )
	{
		if ( !isDefined( level.players[ index ] ) )
		{
			index++;
			continue;
		}
		else if ( level.players[ index ] == self )
		{
			index++;
			continue;
		}
		else if ( !self isplayeronsamemachine( level.players[ index ] ) )
		{
			index++;
			continue;
		}
		else
		{
			team = level.players[ index ].sessionteam;
			if ( team != "spectator" )
			{
				return team;
			}
		}
		index++;
	}
	return "";
}

updateobjectivetext()
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

closemenus()
{
	self closemenu();
	self closeingamemenu();
}

beginclasschoice( forcenewchoice )
{
/#
	assert( isDefined( level.teams[ self.pers[ "team" ] ] ) );
#/
	team = self.pers[ "team" ];
	if ( level.disablecac == 1 )
	{
		self.pers[ "class" ] = level.defaultclass;
		self.class = level.defaultclass;
		if ( self.sessionstate != "playing" && game[ "state" ] == "playing" )
		{
			self thread [[ level.spawnclient ]]();
		}
		level thread maps/mp/gametypes_zm/_globallogic::updateteamstatus();
		self thread maps/mp/gametypes_zm/_spectating::setspectatepermissionsformachine();
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

showmainmenuforteam()
{
/#
	assert( isDefined( level.teams[ self.pers[ "team" ] ] ) );
#/
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

menuteam( team )
{
	self closemenus();
	if ( !level.console && level.allow_teamchange == "0" && isDefined( self.hasdonecombat ) && self.hasdonecombat )
	{
		return;
	}
	if ( self.pers[ "team" ] != team )
	{
		if ( level.ingraceperiod || !isDefined( self.hasdonecombat ) && !self.hasdonecombat )
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
		self.class = undefined;
		self updateobjectivetext();
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

menuspectator()
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
		self.class = undefined;
		self updateobjectivetext();
		self.sessionteam = "spectator";
		if ( !level.teambased )
		{
			self.ffateam = "spectator";
		}
		[[ level.spawnspectator ]]();
		self thread maps/mp/gametypes_zm/_globallogic_player::spectate_player_watcher();
		self setclientscriptmainmenu( game[ "menu_class" ] );
		self notify( "joined_spectators" );
	}
}

menuclass( response )
{
	self closemenus();
}

removespawnmessageshortly( delay )
{
	self endon( "disconnect" );
	waittillframeend;
	self endon( "end_respawn" );
	wait delay;
	self clearlowermessage( 2 );
}
