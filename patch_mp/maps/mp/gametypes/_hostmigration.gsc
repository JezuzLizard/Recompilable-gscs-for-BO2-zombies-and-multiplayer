#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;
#include maps/mp/_utility;

debug_script_structs()
{
/#
	if ( isDefined( level.struct ) )
	{
		println( "*** Num structs " + level.struct.size );
		println( "" );
		i = 0;
		while ( i < level.struct.size )
		{
			struct = level.struct[ i ];
			if ( isDefined( struct.targetname ) )
			{
				println( "---" + i + " : " + struct.targetname );
				i++;
				continue;
			}
			else
			{
				println( "---" + i + " : " + "NONE" );
			}
			i++;
		}
	}
	else println( "*** No structs defined." );
#/
}

updatetimerpausedness()
{
	shouldbestopped = isDefined( level.hostmigrationtimer );
	if ( !level.timerstopped && shouldbestopped )
	{
		level.timerstopped = 1;
		level.timerpausetime = getTime();
	}
	else
	{
		if ( level.timerstopped && !shouldbestopped )
		{
			level.timerstopped = 0;
			level.discardtime += getTime() - level.timerpausetime;
		}
	}
}

callback_hostmigrationsave()
{
}

pausetimer()
{
	level.migrationtimerpausetime = getTime();
}

resumetimer()
{
	level.discardtime += getTime() - level.migrationtimerpausetime;
}

locktimer()
{
	level endon( "host_migration_begin" );
	level endon( "host_migration_end" );
	for ( ;; )
	{
		currtime = getTime();
		wait 0,05;
		if ( !level.timerstopped && isDefined( level.discardtime ) )
		{
			level.discardtime += getTime() - currtime;
		}
	}
}

callback_hostmigration()
{
	setslowmotion( 1, 1, 0 );
	makedvarserverinfo( "ui_guncycle", 0 );
	level.hostmigrationreturnedplayercount = 0;
	if ( level.inprematchperiod )
	{
		level waittill( "prematch_over" );
	}
	if ( level.gameended )
	{
/#
		println( "Migration starting at time " + getTime() + ", but game has ended, so no countdown." );
#/
		return;
	}
/#
	println( "Migration starting at time " + getTime() );
#/
	level.hostmigrationtimer = 1;
	sethostmigrationstatus( 1 );
	level notify( "host_migration_begin" );
	thread locktimer();
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		player thread hostmigrationtimerthink();
		i++;
	}
	level endon( "host_migration_begin" );
	hostmigrationwait();
	level.hostmigrationtimer = undefined;
	sethostmigrationstatus( 0 );
/#
	println( "Migration finished at time " + getTime() );
#/
	recordmatchbegin();
	level notify( "host_migration_end" );
}

matchstarttimerconsole_internal( counttime, matchstarttimer )
{
	waittillframeend;
	visionsetnaked( "mpIntro", 0 );
	level endon( "match_start_timer_beginning" );
	while ( counttime > 0 && !level.gameended )
	{
		matchstarttimer thread maps/mp/gametypes/_hud::fontpulse( level );
		wait ( matchstarttimer.inframes * 0,05 );
		matchstarttimer setvalue( counttime );
		if ( counttime == 2 )
		{
			visionsetnaked( getDvar( "mapname" ), 3 );
		}
		counttime--;

		wait ( 1 - ( matchstarttimer.inframes * 0,05 ) );
	}
}

matchstarttimerconsole( type, duration )
{
	level notify( "match_start_timer_beginning" );
	wait 0,05;
	matchstarttext = createserverfontstring( "objective", 1,5 );
	matchstarttext setpoint( "CENTER", "CENTER", 0, -40 );
	matchstarttext.sort = 1001;
	matchstarttext settext( game[ "strings" ][ "waiting_for_teams" ] );
	matchstarttext.foreground = 0;
	matchstarttext.hidewheninmenu = 1;
	matchstarttext settext( game[ "strings" ][ type ] );
	matchstarttimer = createserverfontstring( "objective", 2,2 );
	matchstarttimer setpoint( "CENTER", "CENTER", 0, 0 );
	matchstarttimer.sort = 1001;
	matchstarttimer.color = ( 1, 1, 0 );
	matchstarttimer.foreground = 0;
	matchstarttimer.hidewheninmenu = 1;
	matchstarttimer maps/mp/gametypes/_hud::fontpulseinit();
	counttime = int( duration );
	if ( counttime >= 2 )
	{
		matchstarttimerconsole_internal( counttime, matchstarttimer );
		visionsetnaked( getDvar( "mapname" ), 3 );
	}
	else
	{
		visionsetnaked( "mpIntro", 0 );
		visionsetnaked( getDvar( "mapname" ), 1 );
	}
	matchstarttimer destroyelem();
	matchstarttext destroyelem();
}

hostmigrationwait()
{
	level endon( "game_ended" );
	if ( level.hostmigrationreturnedplayercount < ( ( level.players.size * 2 ) / 3 ) )
	{
		thread matchstarttimerconsole( "waiting_for_teams", 20 );
		hostmigrationwaitforplayers();
	}
	level notify( "host_migration_countdown_begin" );
	thread matchstarttimerconsole( "match_starting_in", 5 );
	wait 5;
}

waittillhostmigrationcountdown()
{
	level endon( "host_migration_end" );
	if ( !isDefined( level.hostmigrationtimer ) )
	{
		return;
	}
	level waittill( "host_migration_countdown_begin" );
}

hostmigrationwaitforplayers()
{
	level endon( "hostmigration_enoughplayers" );
	wait 15;
}

hostmigrationtimerthink_internal()
{
	level endon( "host_migration_begin" );
	level endon( "host_migration_end" );
	self.hostmigrationcontrolsfrozen = 0;
	while ( !isalive( self ) )
	{
		self waittill( "spawned" );
	}
	self.hostmigrationcontrolsfrozen = 1;
	self freezecontrols( 1 );
	level waittill( "host_migration_end" );
}

hostmigrationtimerthink()
{
	self endon( "disconnect" );
	level endon( "host_migration_begin" );
	hostmigrationtimerthink_internal();
	if ( self.hostmigrationcontrolsfrozen )
	{
		self freezecontrols( 0 );
	}
}

waittillhostmigrationdone()
{
	if ( !isDefined( level.hostmigrationtimer ) )
	{
		return 0;
	}
	starttime = getTime();
	level waittill( "host_migration_end" );
	return getTime() - starttime;
}

waittillhostmigrationstarts( duration )
{
	if ( isDefined( level.hostmigrationtimer ) )
	{
		return;
	}
	level endon( "host_migration_begin" );
	wait duration;
}

waitlongdurationwithhostmigrationpause( duration )
{
	if ( duration == 0 )
	{
		return;
	}
/#
	assert( duration > 0 );
#/
	starttime = getTime();
	endtime = getTime() + ( duration * 1000 );
	while ( getTime() < endtime )
	{
		waittillhostmigrationstarts( ( endtime - getTime() ) / 1000 );
		if ( isDefined( level.hostmigrationtimer ) )
		{
			timepassed = waittillhostmigrationdone();
			endtime += timepassed;
		}
	}
/#
	if ( getTime() != endtime )
	{
		println( "SCRIPT WARNING: gettime() = " + getTime() + " NOT EQUAL TO endtime = " + endtime );
#/
	}
	waittillhostmigrationdone();
	return getTime() - starttime;
}

waitlongdurationwithhostmigrationpauseemp( duration )
{
	if ( duration == 0 )
	{
		return;
	}
/#
	assert( duration > 0 );
#/
	starttime = getTime();
	empendtime = getTime() + ( duration * 1000 );
	level.empendtime = empendtime;
	while ( getTime() < empendtime )
	{
		waittillhostmigrationstarts( ( empendtime - getTime() ) / 1000 );
		if ( isDefined( level.hostmigrationtimer ) )
		{
			timepassed = waittillhostmigrationdone();
			if ( isDefined( empendtime ) )
			{
				empendtime += timepassed;
			}
		}
	}
/#
	if ( getTime() != empendtime )
	{
		println( "SCRIPT WARNING: gettime() = " + getTime() + " NOT EQUAL TO empendtime = " + empendtime );
#/
	}
	waittillhostmigrationdone();
	level.empendtime = undefined;
	return getTime() - starttime;
}

waitlongdurationwithgameendtimeupdate( duration )
{
	if ( duration == 0 )
	{
		return;
	}
/#
	assert( duration > 0 );
#/
	starttime = getTime();
	endtime = getTime() + ( duration * 1000 );
	while ( getTime() < endtime )
	{
		waittillhostmigrationstarts( ( endtime - getTime() ) / 1000 );
		while ( isDefined( level.hostmigrationtimer ) )
		{
			endtime += 1000;
			setgameendtime( int( endtime ) );
			wait 1;
		}
	}
/#
	if ( getTime() != endtime )
	{
		println( "SCRIPT WARNING: gettime() = " + getTime() + " NOT EQUAL TO endtime = " + endtime );
#/
	}
	while ( isDefined( level.hostmigrationtimer ) )
	{
		endtime += 1000;
		setgameendtime( int( endtime ) );
		wait 1;
	}
	return getTime() - starttime;
}
