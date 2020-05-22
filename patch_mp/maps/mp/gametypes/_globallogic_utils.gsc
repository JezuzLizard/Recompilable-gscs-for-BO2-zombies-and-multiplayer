//checked includes match cerberus output
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/_utility;

waittillslowprocessallowed() //checked matches cerberus output
{
	while ( level.lastslowprocessframe == getTime() )
	{
		wait 0.05;
	}
	level.lastslowprocessframe = getTime();
}

testmenu() //checked matches cerberus output
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
		self thread maps/mp/gametypes/_hud_message::notifymessage( notifydata );
	}
}

testshock() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		wait 3;
		numshots = randomint( 6 );
		for ( i = 0; i < numshots; i++ )
		{
			iprintlnbold( numshots );
			self shellshock( "frag_grenade_mp", 0,2 );
			wait 0.1;
		}
	}
}

testhps() //checked matches cerberus output
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
		if ( self thread maps/mp/killstreaks/_killstreaks::givekillstreak( hp ) )
		{
			self playlocalsound( level.killstreaks[ hp ].informdialog );
		}
		wait 20;
	}
}

timeuntilroundend() //checked matches cerberus output
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

gettimeremaining() //checked matches cerberus output
{
	return ( ( level.timelimit * 60 ) * 1000 ) - gettimepassed();
}

registerpostroundevent( eventfunc ) //checked matches cerberus output
{
	if ( !isDefined( level.postroundevents ) )
	{
		level.postroundevents = [];
	}
	level.postroundevents[ level.postroundevents.size ] = eventfunc;
}

executepostroundevents() //checked changed to match cerberus output
{
	if ( !isDefined( level.postroundevents ) )
	{
		return;
	}
	for ( i = 0; i < level.postroundevents.size; i++ ) 
	{
		[[ level.postroundevents[ i ] ]]();
	}
}

getvalueinrange( value, minvalue, maxvalue ) //checked changed to match cerberus output
{
	if ( value > maxvalue )
	{
		return maxvalue;
	}
	else if ( value < minvalue )
	{
		return minvalue;
	}
	else
	{
		return value;
	}
}

assertproperplacement() //checked partially changed to match cerberus output changed at own discretion
{
	/*
/#
	numplayers = level.placement[ "all" ].size;
	if ( level.teambased )
	{
		for ( i = 0; i < numplayers - 1; i++ )
		{
			if ( level.placement[ "all" ][ i ].score < level.placement[ "all" ][ i + 1 ].score )
			{
				println( "^1Placement array:" );
				for ( i = 0; i < numplayers; i++ )
				{
					player = level.placement[ "all" ][ i ];
					println( "^1" + i + ". " + player.name + ": " + player.score );
				}
				assertmsg( "Placement array was not properly sorted" );
				break;
			}
		}
	}
	else 
	{
		for ( i = 0; i < numplayers - 1; i++ )
		{
			if ( level.placement[ "all" ][ i ].pointstowin < level.placement[ "all" ][ i + 1 ].pointstowin )
			{
				println( "^1Placement array:" );
				for ( i = 0; i < numplayers; i++ )
				{
					player = level.placement[ "all" ][ i ];
					println( "^1" + i + ". " + player.name + ": " + player.pointstowin );
				}
				assertmsg( "Placement array was not properly sorted" );
				break;
			}
		}
	}
#/
	*/
}

isvalidclass( class ) //checked matches cerberus output
{
	if ( level.oldschool || sessionmodeiszombiesgame() )
	{
		/*
/#
		assert( !isDefined( class ) );
#/
		*/
		return 1;
	}
	if ( isDefined( class ) )
	{
		return class != "";
	}
}

playtickingsound( gametype_tick_sound ) //checked matches cerberus output
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
			wait 0.5;
		}
		else if ( time > 1 )
		{
			time -= 0,4;
			wait 0.4;
		}
		else
		{
			time -= 0,3;
			wait 0.3;
		}
		maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
	}
}

stoptickingsound() //checked matches cerberus output
{
	self notify( "stop_ticking" );
}

gametimer() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	level waittill( "prematch_over" );
	level.starttime = getTime();
	level.discardtime = 0;
	if ( isDefined( game[ "roundMillisecondsAlreadyPassed" ] ) )
	{
		level.starttime -= game[ "roundMillisecondsAlreadyPassed" ];
		game["roundMillisecondsAlreadyPassed"] = undefined;
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

gettimepassed() //checked matches cerberus output
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

pausetimer() //checked matches cerberus output
{
	if ( level.timerstopped )
	{
		return;
	}
	level.timerstopped = 1;
	level.timerpausetime = getTime();
}

resumetimer() //checked matches cerberus output
{
	if ( !level.timerstopped )
	{
		return;
	}
	level.timerstopped = 0;
	level.discardtime += getTime() - level.timerpausetime;
}

getscoreremaining( team ) //checked matches cerberus output
{
	/*
/#
	if ( !isplayer( self ) )
	{
		assert( isDefined( team ) );
	}
#/
	*/
	scorelimit = level.scorelimit;
	if ( isplayer( self ) )
	{
		return scorelimit - maps/mp/gametypes/_globallogic_score::_getplayerscore( self );
	}
	else
	{
		return scorelimit - getteamscore( team );
	}
}

getteamscoreforround( team ) //checked matches cerberus output
{
	if ( level.roundscorecarry && isDefined( game[ "lastroundscore" ][ team ] ) )
	{
		return getteamscore( team ) - game[ "lastroundscore" ][ team ];
	}
	return getteamscore( team );
}

getscoreperminute( team ) //checked matches cerberus output
{
	/*
/#
	if ( !isplayer( self ) )
	{
		assert( isDefined( team ) );
	}
#/
	*/
	scorelimit = level.scorelimit;
	timelimit = level.timelimit;
	minutespassed = ( gettimepassed() / 60000 ) + 0.0001;
	if ( isplayer( self ) )
	{
		return maps/mp/gametypes/_globallogic_score::_getplayerscore( self ) / minutespassed;
	}
	else
	{
		return getteamscoreforround( team ) / minutespassed;
	}
}

getestimatedtimeuntilscorelimit( team ) //checked matches cerberus output
{
	/*
/#
	if ( !isplayer( self ) )
	{
		assert( isDefined( team ) );
	}
#/
	*/
	scoreperminute = self getscoreperminute( team );
	scoreremaining = self getscoreremaining( team );
	if ( !scoreperminute )
	{
		return 999999;
	}
	return scoreremaining / scoreperminute;
}

rumbler() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		wait 0.1;
		self playrumbleonentity( "damage_heavy" );
	}
}

waitfortimeornotify( time, notifyname ) //checked matches cerberus output
{
	self endon( notifyname );
	wait time;
}

waitfortimeornotifynoartillery( time, notifyname ) //checked matches cerberus output
{
	self endon( notifyname );
	wait time;
	while ( isDefined( level.artilleryinprogress ) )
	{
		/*
/#
		assert( level.artilleryinprogress );
#/
		*/
		wait 0.25;
	}
}

isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) //checked changed to match cerberus output
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
	if ( maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
	{
		if ( isDefined( einflictor ) || !isDefined( einflictor.controlled ) || einflictor.controlled == 0 )
		{
			return 0;
		}
	}
	return 1;
}

gethitlocheight( shitloc ) //checked matches cerberus output
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

debugline( start, end ) //checked changed to match cerberus output
{
	/*
/#
	for ( i = 0; i < 50; i++ )
	{
		line( start, end );
		wait 0.05;
#/
	}
	*/
}

isexcluded( entity, entitylist ) //checked changed to match cerberus output
{
	for ( index = 0; index < entitylist.size; index++ )
	{
		if ( entity == entitylist[ index ] )
		{
			return 1;
		}
	}
	return 0;
}

waitfortimeornotifies( desireddelay ) //checked matches cerberus output
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

logteamwinstring( wintype, winner ) //checked changed to match cerberus output
{
	log_string = wintype;
	if ( isDefined( winner ) )
	{
		log_string = ( log_string + ", win: " ) + winner;
	}
	foreach ( team in level.teams )
	{
		log_string = ( log_string + ", " ) + team + ": " + game[ "teamScores" ][ team ];
	}
	logstring( log_string );
}

