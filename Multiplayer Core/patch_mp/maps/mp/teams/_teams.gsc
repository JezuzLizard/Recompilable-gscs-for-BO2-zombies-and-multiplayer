//checked includes match cerberus output
#include maps/mp/gametypes/_spectating;
#include maps/mp/gametypes/_globallogic_ui;
#include maps/mp/gametypes/_persistence;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	precacheshader( "mpflag_spectator" );
	game[ "strings" ][ "autobalance" ] = &"MP_AUTOBALANCE_NOW";
	precachestring( &"MP_AUTOBALANCE_NOW" );
	if ( getDvar( "scr_teambalance" ) == "" )
	{
		setdvar( "scr_teambalance", "0" );
	}
	level.teambalance = getDvarInt( "scr_teambalance" );
	level.teambalancetimer = 0;
	if ( getDvar( "scr_timeplayedcap" ) == "" )
	{
		setdvar( "scr_timeplayedcap", "1800" );
	}
	level.timeplayedcap = int( getDvarInt( "scr_timeplayedcap" ) );
	level.freeplayers = [];
	if ( level.teambased )
	{
		level.alliesplayers = [];
		level.axisplayers = [];
		level thread onplayerconnect();
		level thread updateteambalancedvar();
		wait 0.15;
		if ( level.rankedmatch || level.leaguematch )
		{
			level thread updateplayertimes();
		}
	}
	else
	{
		level thread onfreeplayerconnect();
		wait 0.15;
		if ( level.rankedmatch || level.leaguematch )
		{
			level thread updateplayertimes();
		}
	}
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onjoinedteam();
		player thread onjoinedspectators();
		player thread trackplayedtime();
	}
}

onfreeplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread trackfreeplayedtime();
	}
}

onjoinedteam() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_team" );
		self logstring( "joined team: " + self.pers[ "team" ] );
		self updateteamtime();
	}
}

onjoinedspectators() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_spectators" );
		self.pers["teamTime"] = undefined;
	}
}

trackplayedtime() //checked partially changed to match beta dump see info.md
{
	self endon( "disconnect" );
	foreach ( team in level.teams )
	{
		self.timeplayed[ team ] = 0;
	}
	self.timeplayed[ "free" ] = 0;
	self.timeplayed[ "other" ] = 0;
	self.timeplayed[ "alive" ] = 0;
	if ( level.gametype == "twar" && game[ "roundsplayed" ] >= 0 && self.timeplayed[ "total" ] >= 0 )
	{
		self.timeplayed[ "total" ] = 0;
	}
	if ( !isDefined( self.timeplayed[ "total" ] ) )
	{
		self.timeplayed[ "total" ] = 0;
	}
	while ( level.inprematchperiod )
	{
		wait 0.05;
	}
	for ( ;; )
	{
		if ( game[ "state" ] == "playing" )
		{
			if ( isDefined( level.teams[ self.sessionteam ] ) )
			{
				self.timeplayed[ self.sessionteam ]++;
				self.timeplayed[ "total" ]++;
				if ( isalive( self ) )
				{
					self.timeplayed[ "alive" ]++;
				}
			}
			else if ( self.sessionteam == "spectator" )
			{
				self.timeplayed[ "other" ]++;
			}
		}
		wait 1;
	}
}

updateplayertimes() //checked changed to match cerberus output
{
	nexttoupdate = 0;
	for ( ;; )
	{
		nexttoupdate++;
		if ( nexttoupdate >= level.players.size )
		{
			nexttoupdate = 0;
		}
		if ( isDefined( level.players[ nexttoupdate ] ) )
		{
			level.players[ nexttoupdate ] updateplayedtime();
			level.players[ nexttoupdate ] maps/mp/gametypes/_persistence::checkcontractexpirations();
		}
		wait 1;
	}
}

updateplayedtime() //checked changed to match cerberus output
{
	pixbeginevent( "updatePlayedTime" );
	foreach ( team in level.teams )
	{
		if ( self.timeplayed[ team ] )
		{
			self addplayerstat( "time_played_" + team, int( min( self.timeplayed[ team ], level.timeplayedcap ) ) );
			self addplayerstatwithgametype( "time_played_total", int( min( self.timeplayed[ team ], level.timeplayedcap ) ) );
		}
	}
	if ( self.timeplayed[ "other" ] )
	{
		self addplayerstat( "time_played_other", int( min( self.timeplayed[ "other" ], level.timeplayedcap ) ) );
		self addplayerstatwithgametype( "time_played_total", int( min( self.timeplayed[ "other" ], level.timeplayedcap ) ) );
	}
	if ( self.timeplayed[ "alive" ] )
	{
		timealive = int( min( self.timeplayed[ "alive" ], level.timeplayedcap ) );
		self maps/mp/gametypes/_persistence::incrementcontracttimes( timealive );
		self addplayerstat( "time_played_alive", timealive );
	}
	pixendevent();
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	foreach ( team in level.teams )
	{ 
		self.timeplayed[ team ] = 0;
	}
	self.timeplayed[ "other" ] = 0;
	self.timeplayed[ "alive" ] = 0;
}

updateteamtime() //checked matches cerberus output
{
	if ( game[ "state" ] != "playing" )
	{
		return;
	}
	self.pers[ "teamTime" ] = getTime();
}

updateteambalancedvar() //checked matches cerberus output
{
	for ( ;; )
	{
		teambalance = getDvarInt( "scr_teambalance" );
		if ( level.teambalance != teambalance )
		{
			level.teambalance = getDvarInt( "scr_teambalance" );
		}
		timeplayedcap = getDvarInt( "scr_timeplayedcap" );
		if ( level.timeplayedcap != timeplayedcap )
		{
			level.timeplayedcap = int( getDvarInt( "scr_timeplayedcap" ) );
		}
		wait 1;
	}
}

changeteam( team ) //checked changed to match cerberus output
{
	if ( self.sessionstate != "dead" )
	{
		self.switching_teams = 1;
		self.joining_team = team;
		self.leaving_team = self.pers[ "team" ];
		self suicide();
	}
	self.pers[ "team" ] = team;
	self.team = team;
	self.pers["weapon"] = undefined;
	self.pers["spawnweapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self.pers["teamTime"] = undefined;
	self.sessionteam = self.pers[ "team" ];
	if ( !level.teambased )
	{
		self.ffateam = team;
	}
	self maps/mp/gametypes/_globallogic_ui::updateobjectivetext();
	self maps/mp/gametypes/_spectating::setspectatepermissions();
	self setclientscriptmainmenu( game[ "menu_class" ] );
	self openmenu( game[ "menu_class" ] );
	self notify( "end_respawn" );
}

countplayers() //checked partially changed to match cerberus output see info.md
{
	players = level.players;
	playercounts = [];
	foreach ( team in level.teams )
	{
		playercounts[ team ] = 0;
	}
	foreach ( player in level.players )
	{
		if ( player == self )
		{
		}
		else
		{
			team = player.pers[ "team" ];
			if ( isDefined( team ) && isDefined( level.teams[ team ] ) )
			{
				playercounts[ team ]++;
			}
		}
	}
	return playercounts;
}

trackfreeplayedtime() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	foreach ( team in level.teams )
	{
		self.timeplayed[ team ] = 0;
	}
	self.timeplayed[ "other" ] = 0;
	self.timeplayed[ "total" ] = 0;
	self.timeplayed[ "alive" ] = 0;
	for ( ;; )
	{
		if ( game[ "state" ] == "playing" )
		{
			team = self.pers[ "team" ];
			if ( isDefined( team ) && isDefined( level.teams[ team ] ) && self.sessionteam != "spectator" )
			{
				self.timeplayed[ team ]++;
				self.timeplayed[ "total" ]++;
				if ( isalive( self ) )
				{
					self.timeplayed[ "alive" ]++;
				}
			}
			else
			{
				self.timeplayed[ "other" ]++;
			}
		}
		wait 1;
	}
}

set_player_model( team, weapon ) //checked matches cerberus output
{
	weaponclass = getweaponclass( weapon );
	bodytype = "default";
	switch( weaponclass )
	{
		case "weapon_sniper":
			bodytype = "rifle";
			break;
		case "weapon_cqb":
			bodytype = "spread";
			break;
		case "weapon_lmg":
			bodytype = "mg";
			break;
		case "weapon_smg":
			bodytype = "smg";
			break;
	}
	self detachall();
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	if ( level.multiteam )
	{
		bodytype = "default";
		switch( team )
		{
			case "team7":
			case "team8":
				team = "allies";
				break;
		}
	}
	self [[ game[ "set_player_model" ][ team ][ bodytype ] ]]();
}

getteamflagmodel( teamref ) //checked matches cerberus output
{
	/*
/#
	assert( isDefined( game[ "flagmodels" ] ) );
#/
/#
	assert( isDefined( game[ "flagmodels" ][ teamref ] ) );
#/
	*/
	return game[ "flagmodels" ][ teamref ];
}

getteamflagcarrymodel( teamref ) //checked matches cerberus output
{
	/*
/#
	assert( isDefined( game[ "carry_flagmodels" ] ) );
#/
/#
	assert( isDefined( game[ "carry_flagmodels" ][ teamref ] ) );
#/
	*/
	return game[ "carry_flagmodels" ][ teamref ];
}

getteamflagicon( teamref ) //checked matches cerberus output
{
	/*
/#
	assert( isDefined( game[ "carry_icon" ] ) );
#/
/#
	assert( isDefined( game[ "carry_icon" ][ teamref ] ) );
#/
	*/
	return game[ "carry_icon" ][ teamref ];
}

