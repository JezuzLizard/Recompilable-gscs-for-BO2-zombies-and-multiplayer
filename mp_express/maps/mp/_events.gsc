#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_utility;

add_timed_event( seconds, notify_string, client_notify_string )
{
/#
	assert( seconds >= 0 );
#/
	if ( level.timelimit > 0 )
	{
		level thread timed_event_monitor( seconds, notify_string, client_notify_string );
	}
}

timed_event_monitor( seconds, notify_string, client_notify_string )
{
	for ( ;; )
	{
		wait 0,5;
		if ( !isDefined( level.starttime ) )
		{
			continue;
		}
		else
		{
			millisecs_remaining = maps/mp/gametypes/_globallogic_utils::gettimeremaining();
			seconds_remaining = millisecs_remaining / 1000;
			if ( seconds_remaining <= seconds )
			{
				event_notify( notify_string, client_notify_string );
				return;
			}
		}
	}
}

add_score_event( score, notify_string, client_notify_string )
{
/#
	assert( score >= 0 );
#/
	if ( level.scorelimit > 0 )
	{
		if ( level.teambased )
		{
			level thread score_team_event_monitor( score, notify_string, client_notify_string );
			return;
		}
		else
		{
			level thread score_event_monitor( score, notify_string, client_notify_string );
		}
	}
}

any_team_reach_score( score )
{
	_a63 = level.teams;
	_k63 = getFirstArrayKey( _a63 );
	while ( isDefined( _k63 ) )
	{
		team = _a63[ _k63 ];
		if ( game[ "teamScores" ][ team ] >= score )
		{
			return 1;
		}
		_k63 = getNextArrayKey( _a63, _k63 );
	}
	return 0;
}

score_team_event_monitor( score, notify_string, client_notify_string )
{
	for ( ;; )
	{
		wait 0,5;
		if ( any_team_reach_score( score ) )
		{
			event_notify( notify_string, client_notify_string );
			return;
		}
	}
}

score_event_monitor( score, notify_string, client_notify_string )
{
	for ( ;; )
	{
		wait 0,5;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( isDefined( players[ i ].score ) && players[ i ].score >= score )
			{
				event_notify( notify_string, client_notify_string );
				return;
			}
			i++;
		}
	}
}

event_notify( notify_string, client_notify_string )
{
	if ( isDefined( notify_string ) )
	{
		level notify( notify_string );
	}
	if ( isDefined( client_notify_string ) )
	{
		clientnotify( client_notify_string );
	}
}
