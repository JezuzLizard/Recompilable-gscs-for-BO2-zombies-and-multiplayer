#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/_utility;

waittillslowprocessallowed()
{
	while ( level.lastslowprocessframe == getTime() )
	{
		wait 0,05;
	}
	level.lastslowprocessframe = getTime();
}

testmenu()
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		wait 10;
		notifydata = spawnstruct();
		notifydata.titletext = &"MP_CHALLENGE_COMPLETED";
		notifydata.notifytext = "wheee";
		notifydata.sound = "mp_challenge_complete";
		self thread maps/mp/gametypes_zm/_hud_message::notifymessage( notifydata );
	}
}

testshock()
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		wait 3;
		numshots = randomint( 6 );
		i = 0;
		while ( i < numshots )
		{
			iprintlnbold( numshots );
			self shellshock( "frag_grenade_mp", 0,2 );
			wait 0,1;
			i++;
		}
	}
}

testhps()
{
	self endon( "death" );
	self endon( "disconnect" );
	hps = [];
	hps[ hps.size ] = "radar_mp";
	hps[ hps.size ] = "artillery_mp";
	hps[ hps.size ] = "dogs_mp";
	for ( ;; )
	{
		hp = "radar_mp";
		wait 20;
	}
}

timeuntilroundend()
{
	if ( level.gameended )
	{
		timepassed = ( getTime() - level.gameendtime ) / 1000;
		timeremaining = level.postroundtime - timepassed;
		if ( timeremaining < 0 )
		{
			return 0;
		}
		return timeremaining;
	}
	if ( level.inovertime )
	{
		return undefined;
	}
	if ( level.timelimit <= 0 )
	{
		return undefined;
	}
	if ( !isDefined( level.starttime ) )
	{
		return undefined;
	}
	timepassed = ( gettimepassed() - level.starttime ) / 1000;
	timeremaining = ( level.timelimit * 60 ) - timepassed;
	return timeremaining + level.postroundtime;
}

gettimeremaining()
{
	return ( ( level.timelimit * 60 ) * 1000 ) - gettimepassed();
}

registerpostroundevent( eventfunc )
{
	if ( !isDefined( level.postroundevents ) )
	{
		level.postroundevents = [];
	}
	level.postroundevents[ level.postroundevents.size ] = eventfunc;
}

executepostroundevents()
{
	if ( !isDefined( level.postroundevents ) )
	{
		return;
	}
	i = 0;
	while ( i < level.postroundevents.size )
	{
		[[ level.postroundevents[ i ] ]]();
		i++;
	}
}

getvalueinrange( value, minvalue, maxvalue )
{
	if ( value > maxvalue )
	{
		return maxvalue;
	}
	else
	{
		if ( value < minvalue )
		{
			return minvalue;
		}
		else
		{
			return value;
		}
	}
}

assertproperplacement()
{
/#
	numplayers = level.placement[ "all" ].size;
	i = 0;
	while ( i < ( numplayers - 1 ) )
	{
		if ( isDefined( level.placement[ "all" ][ i ] ) && isDefined( level.placement[ "all" ][ i + 1 ] ) )
		{
			if ( level.placement[ "all" ][ i ].score < level.placement[ "all" ][ i + 1 ].score )
			{
				println( "^1Placement array:" );
				i = 0;
				while ( i < numplayers )
				{
					player = level.placement[ "all" ][ i ];
					println( "^1" + i + ". " + player.name + ": " + player.score );
					i++;
				}
				assertmsg( "Placement array was not properly sorted" );
				return;
			}
		}
		else
		{
			i++;
#/
		}
	}
}

isvalidclass( class )
{
	if ( level.oldschool || sessionmodeiszombiesgame() )
	{
/#
		assert( !isDefined( class ) );
#/
		return 1;
	}
	if ( isDefined( class ) )
	{
		return class != "";
	}
}

playtickingsound( gametype_tick_sound )
{
	self endon( "death" );
	self endon( "stop_ticking" );
	level endon( "game_ended" );
	time = level.bombtimer;
	while ( 1 )
	{
		self playsound( gametype_tick_sound );
		if ( time > 10 )
		{
			time -= 1;
			wait 1;
		}
		else if ( time > 4 )
		{
			time -= 0,5;
			wait 0,5;
		}
		else if ( time > 1 )
		{
			time -= 0,4;
			wait 0,4;
		}
		else
		{
			time -= 0,3;
			wait 0,3;
		}
		maps/mp/gametypes_zm/_hostmigration::waittillhostmigrationdone();
	}
}

stoptickingsound()
{
	self notify( "stop_ticking" );
}

gametimer()
{
	level endon( "game_ended" );
	level waittill( "prematch_over" );
	level.starttime = getTime();
	level.discardtime = 0;
	if ( isDefined( game[ "roundMillisecondsAlreadyPassed" ] ) )
	{
		level.starttime -= game[ "roundMillisecondsAlreadyPassed" ];
	}
	prevtime = getTime();
	while ( game[ "state" ] == "playing" )
	{
		if ( !level.timerstopped )
		{
			game[ "timepassed" ] += getTime() - prevtime;
		}
		prevtime = getTime();
		wait 1;
	}
}

gettimepassed()
{
	if ( !isDefined( level.starttime ) )
	{
		return 0;
	}
	if ( level.timerstopped )
	{
		return level.timerpausetime - level.starttime - level.discardtime;
	}
	else
	{
		return getTime() - level.starttime - level.discardtime;
	}
}

pausetimer()
{
	if ( level.timerstopped )
	{
		return;
	}
	level.timerstopped = 1;
	level.timerpausetime = getTime();
}

resumetimer()
{
	if ( !level.timerstopped )
	{
		return;
	}
	level.timerstopped = 0;
	level.discardtime += getTime() - level.timerpausetime;
}

getscoreremaining( team )
{
/#
	if ( !isplayer( self ) )
	{
		assert( isDefined( team ) );
	}
#/
	scorelimit = level.scorelimit;
	if ( isplayer( self ) )
	{
		return scorelimit - maps/mp/gametypes_zm/_globallogic_score::_getplayerscore( self );
	}
	else
	{
		return scorelimit - getteamscore( team );
	}
}

getscoreperminute( team )
{
/#
	if ( !isplayer( self ) )
	{
		assert( isDefined( team ) );
	}
#/
	scorelimit = level.scorelimit;
	timelimit = level.timelimit;
	minutespassed = ( gettimepassed() / 60000 ) + 0,0001;
	if ( isplayer( self ) )
	{
		return maps/mp/gametypes_zm/_globallogic_score::_getplayerscore( self ) / minutespassed;
	}
	else
	{
		return getteamscore( team ) / minutespassed;
	}
}

getestimatedtimeuntilscorelimit( team )
{
/#
	if ( !isplayer( self ) )
	{
		assert( isDefined( team ) );
	}
#/
	scoreperminute = self getscoreperminute( team );
	scoreremaining = self getscoreremaining( team );
	if ( !scoreperminute )
	{
		return 999999;
	}
	return scoreremaining / scoreperminute;
}

rumbler()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		wait 0,1;
		self playrumbleonentity( "damage_heavy" );
	}
}

waitfortimeornotify( time, notifyname )
{
	self endon( notifyname );
	wait time;
}

waitfortimeornotifynoartillery( time, notifyname )
{
	self endon( notifyname );
	wait time;
	while ( isDefined( level.artilleryinprogress ) )
	{
/#
		assert( level.artilleryinprogress );
#/
		wait 0,25;
	}
}

isheadshot( sweapon, shitloc, smeansofdeath, einflictor )
{
	if ( shitloc != "head" && shitloc != "helmet" )
	{
		return 0;
	}
	switch( smeansofdeath )
	{
		case "MOD_BAYONET":
		case "MOD_MELEE":
			return 0;
		case "MOD_IMPACT":
			if ( sweapon != "knife_ballistic_mp" )
			{
				return 0;
			}
	}
	return 1;
}

gethitlocheight( shitloc )
{
	switch( shitloc )
	{
		case "head":
		case "helmet":
		case "neck":
			return 60;
		case "gun":
		case "left_arm_lower":
		case "left_arm_upper":
		case "left_hand":
		case "right_arm_lower":
		case "right_arm_upper":
		case "right_hand":
		case "torso_upper":
			return 48;
		case "torso_lower":
			return 40;
		case "left_leg_upper":
		case "right_leg_upper":
			return 32;
		case "left_leg_lower":
		case "right_leg_lower":
			return 10;
		case "left_foot":
		case "right_foot":
			return 5;
	}
	return 48;
}

debugline( start, end )
{
/#
	i = 0;
	while ( i < 50 )
	{
		line( start, end );
		wait 0,05;
		i++;
#/
	}
}

isexcluded( entity, entitylist )
{
	index = 0;
	while ( index < entitylist.size )
	{
		if ( entity == entitylist[ index ] )
		{
			return 1;
		}
		index++;
	}
	return 0;
}

waitfortimeornotifies( desireddelay )
{
	startedwaiting = getTime();
	waitedtime = ( getTime() - startedwaiting ) / 1000;
	if ( waitedtime < desireddelay )
	{
		wait ( desireddelay - waitedtime );
		return desireddelay;
	}
	else
	{
		return waitedtime;
	}
}

logteamwinstring( wintype, winner )
{
	log_string = wintype;
	if ( isDefined( winner ) )
	{
		log_string = ( log_string + ", win: " ) + winner;
	}
	_a469 = level.teams;
	_k469 = getFirstArrayKey( _a469 );
	while ( isDefined( _k469 ) )
	{
		team = _a469[ _k469 ];
		log_string = ( log_string + ", " ) + team + ": " + game[ "teamScores" ][ team ];
		_k469 = getNextArrayKey( _a469, _k469 );
	}
	logstring( log_string );
}
