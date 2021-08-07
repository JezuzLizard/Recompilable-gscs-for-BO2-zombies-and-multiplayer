
init()
{
	_a3 = level.teams;
	_k3 = getFirstArrayKey( _a3 );
	while ( isDefined( _k3 ) )
	{
		team = _a3[ _k3 ];
		level.spectateoverride[ team ] = spawnstruct();
		_k3 = getNextArrayKey( _a3, _k3 );
	}
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onjoinedteam();
		player thread onjoinedspectators();
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self setspectatepermissions();
	}
}

onjoinedteam()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_team" );
		self setspectatepermissionsformachine();
	}
}

onjoinedspectators()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_spectators" );
		self setspectatepermissionsformachine();
	}
}

updatespectatesettings()
{
	level endon( "game_ended" );
	index = 0;
	while ( index < level.players.size )
	{
		level.players[ index ] setspectatepermissions();
		index++;
	}
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
	return self.sessionteam;
}

otherlocalplayerstillalive()
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
			if ( isalive( level.players[ index ] ) )
			{
				return 1;
			}
		}
		index++;
	}
	return 0;
}

allowspectateallteams( allow )
{
	_a114 = level.teams;
	_k114 = getFirstArrayKey( _a114 );
	while ( isDefined( _k114 ) )
	{
		team = _a114[ _k114 ];
		self allowspectateteam( team, allow );
		_k114 = getNextArrayKey( _a114, _k114 );
	}
}

allowspectateallteamsexceptteam( skip_team, allow )
{
	_a122 = level.teams;
	_k122 = getFirstArrayKey( _a122 );
	while ( isDefined( _k122 ) )
	{
		team = _a122[ _k122 ];
		if ( team == skip_team )
		{
		}
		else
		{
			self allowspectateteam( team, allow );
		}
		_k122 = getNextArrayKey( _a122, _k122 );
	}
}

setspectatepermissions()
{
	team = self.sessionteam;
	if ( team == "spectator" )
	{
		if ( self issplitscreen() && !level.splitscreen )
		{
			team = getsplitscreenteam();
		}
		if ( team == "spectator" )
		{
			self allowspectateallteams( 1 );
			self allowspectateteam( "freelook", 0 );
			self allowspectateteam( "none", 1 );
			self allowspectateteam( "localplayers", 1 );
			return;
		}
	}
	spectatetype = level.spectatetype;
	switch( spectatetype )
	{
		case 0:
			self allowspectateallteams( 0 );
			self allowspectateteam( "freelook", 0 );
			self allowspectateteam( "none", 1 );
			self allowspectateteam( "localplayers", 0 );
			break;
		case 3:
			if ( self issplitscreen() && self otherlocalplayerstillalive() )
			{
				self allowspectateallteams( 0 );
				self allowspectateteam( "none", 0 );
				self allowspectateteam( "freelook", 0 );
				self allowspectateteam( "localplayers", 1 );
				break;
		}
		else
		{
			case 1:
				if ( !level.teambased )
				{
					self allowspectateallteams( 1 );
					self allowspectateteam( "none", 1 );
					self allowspectateteam( "freelook", 0 );
					self allowspectateteam( "localplayers", 1 );
				}
				else if ( isDefined( team ) && isDefined( level.teams[ team ] ) )
				{
					self allowspectateteam( team, 1 );
					self allowspectateallteamsexceptteam( team, 0 );
					self allowspectateteam( "freelook", 0 );
					self allowspectateteam( "none", 0 );
					self allowspectateteam( "localplayers", 1 );
				}
				else
				{
					self allowspectateallteams( 0 );
					self allowspectateteam( "freelook", 0 );
					self allowspectateteam( "none", 0 );
					self allowspectateteam( "localplayers", 1 );
				}
				break;
			case 2:
				self allowspectateallteams( 1 );
				self allowspectateteam( "freelook", 1 );
				self allowspectateteam( "none", 1 );
				self allowspectateteam( "localplayers", 1 );
				break;
		}
	}
	if ( isDefined( team ) && isDefined( level.teams[ team ] ) )
	{
		if ( isDefined( level.spectateoverride[ team ].allowfreespectate ) )
		{
			self allowspectateteam( "freelook", 1 );
		}
		if ( isDefined( level.spectateoverride[ team ].allowenemyspectate ) )
		{
			self allowspectateallteamsexceptteam( team, 1 );
		}
	}
}

setspectatepermissionsformachine()
{
	self setspectatepermissions();
	if ( !self issplitscreen() )
	{
		return;
	}
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
			level.players[ index ] setspectatepermissions();
		}
		index++;
	}
}
