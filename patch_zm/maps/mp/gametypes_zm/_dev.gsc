#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
/#
	for ( ;; )
	{
		updatedevsettingszm();
		wait 0,5;
#/
	}
}

updatedevsettingszm()
{
/#
	if ( level.players.size > 0 )
	{
		if ( getDvar( "r_streamDumpDistance" ) == "3" )
		{
			if ( !isDefined( level.streamdumpteamindex ) )
			{
				level.streamdumpteamindex = 0;
			}
			else
			{
				level.streamdumpteamindex++;
			}
			numpoints = 0;
			spawnpoints = [];
			location = level.scr_zm_map_start_location;
			if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
			{
				location = level.default_start_location;
			}
			match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
			if ( level.streamdumpteamindex < level.teams.size )
			{
				structs = getstructarray( "initial_spawn", "script_noteworthy" );
				while ( isDefined( structs ) )
				{
					_a46 = structs;
					_k46 = getFirstArrayKey( _a46 );
					while ( isDefined( _k46 ) )
					{
						struct = _a46[ _k46 ];
						while ( isDefined( struct.script_string ) )
						{
							tokens = strtok( struct.script_string, " " );
							_a51 = tokens;
							_k51 = getFirstArrayKey( _a51 );
							while ( isDefined( _k51 ) )
							{
								token = _a51[ _k51 ];
								if ( token == match_string )
								{
									spawnpoints[ spawnpoints.size ] = struct;
								}
								_k51 = getNextArrayKey( _a51, _k51 );
							}
						}
						_k46 = getNextArrayKey( _a46, _k46 );
					}
				}
				if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
				{
					spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
				}
				if ( isDefined( spawnpoints ) )
				{
					numpoints = spawnpoints.size;
				}
			}
			if ( numpoints == 0 )
			{
				setdvar( "r_streamDumpDistance", "0" );
				level.streamdumpteamindex = -1;
				return;
			}
			else
			{
				averageorigin = ( 0, 0, 0 );
				averageangles = ( 0, 0, 0 );
				_a80 = spawnpoints;
				_k80 = getFirstArrayKey( _a80 );
				while ( isDefined( _k80 ) )
				{
					spawnpoint = _a80[ _k80 ];
					averageorigin += spawnpoint.origin / numpoints;
					averageangles += spawnpoint.angles / numpoints;
					_k80 = getNextArrayKey( _a80, _k80 );
				}
				level.players[ 0 ] setplayerangles( averageangles );
				level.players[ 0 ] setorigin( averageorigin );
				wait 0,05;
				setdvar( "r_streamDumpDistance", "2" );
#/
			}
		}
	}
}
