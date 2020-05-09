
init() //checked changed to match cerberus output
{
	foreach ( team in level.teams )
	{
		level.spectateoverride[ team ] = spawnstruct();
	}
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onjoinedteam();
		player thread onjoinedspectators();
		player thread onplayerspawned();
	}
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self setspectatepermissions();
	}
}

onjoinedteam() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_team" );
		self setspectatepermissionsformachine();
	}
}

onjoinedspectators() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_spectators" );
		self setspectatepermissionsformachine();
	}
}

updatespectatesettings() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	for ( index = 0; index < level.players.size; index++ )
	{
		level.players[ index ] setspectatepermissions();
	}
}

getsplitscreenteam() //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
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
	return self.sessionteam;
}

otherlocalplayerstillalive() //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
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
		if ( isalive( level.players[ index ] ) )
		{
			return 1;
		}
		index++;
	}
	return 0;
}

allowspectateallteams( allow ) //checked changed to match cerberus output
{
	foreach ( team in level.teams )
	{
		self allowspectateteam( team, allow );
	}
}

allowspectateallteamsexceptteam( skip_team, allow ) //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	foreach ( team in level.teams )
	{
		if ( team == skip_team )
		{
		}
		else
		{
			self allowspectateteam( team, allow );
		}
	}
}

setspectatepermissions() //checked changed to match cerberus output
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

setspectatepermissionsformachine() //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
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
		level.players[ index ] setspectatepermissions();
		index++;
	}
}

