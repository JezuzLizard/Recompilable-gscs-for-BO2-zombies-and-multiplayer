#include maps/mp/_utility;

init( id, playerbegincallback, playerendcallback ) //checked matches cerberus output
{
	precacheshader( "objpoint_default" );
	handler = spawnstruct();
	handler.id = id;
	handler.playerbegincallback = playerbegincallback;
	handler.playerendcallback = playerendcallback;
	handler.enabled = 0;
	handler.players = [];
	thread onplayerconnect( handler );
	level.handlerglobalflagval = 0;
	return handler;
}

enable( handler ) //checked partially changed to match cerberus output didn't change while loop to for loop to prevent infinite loop continue bug
{
	if ( handler.enabled )
	{
		return;
	}
	handler.enabled = 1;
	level.handlerglobalflagval++;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ].handlerflagval = level.handlerglobalflagval;
	}
	players = handler.players;
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].handlerflagval != level.handlerglobalflagval )
		{
			i++;
			continue;
		}
		if ( players[ i ].handlers[ handler.id ].ready )
		{
			players[ i ] handleplayer( handler );
		}
		i++;
	}
}
 
disable( handler ) //checked partially changed to match cerberus output didn't change while loop to for loop to prevent infinite loop continue bug
{
	if ( !handler.enabled )
	{
		return;
	}
	handler.enabled = 0;
	level.handlerglobalflagval++;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ].handlerflagval = level.handlerglobalflagval;
	}
	players = handler.players;
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].handlerflagval != level.handlerglobalflagval )
		{
			i++;
			continue;
		}
		if ( players[ i ].handlers[ handler.id ].ready )
		{
			players[ i ] unhandleplayer( handler, 0, 0 );
		}
		i++;
	}
}

onplayerconnect( handler ) //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		if ( !isDefined( player.handlers ) )
		{
			player.handlers = [];
		}
		player.handlers[ handler.id ] = spawnstruct();
		player.handlers[ handler.id ].ready = 0;
		player.handlers[ handler.id ].handled = 0;
		player.handlerflagval = -1;
		handler.players[ handler.players.size ] = player;
		player thread onplayerdisconnect( handler );
		player thread onplayerspawned( handler );
		player thread onjoinedteam( handler );
		player thread onjoinedspectators( handler );
		player thread onplayerkilled( handler );
	}
}

onplayerdisconnect( handler ) //checked changed to match cerberus output
{
	self waittill( "disconnect" );
	newplayers = [];
	for ( i = 0; i < handler.players.size; i++ )
	{
		if ( handler.players[ i ] != self )
		{
			newplayers[ newplayers.size ] = handler.players[ i ];
		}
	}
	handler.players = newplayers;
	self thread unhandleplayer( handler, 1, 1 );
}

onjoinedteam( handler ) //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_team" );
		self thread unhandleplayer( handler, 1, 0 );
	}
}

onjoinedspectators( handler ) //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_spectators" );
		self thread unhandleplayer( handler, 1, 0 );
	}
}

onplayerspawned( handler ) //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread handleplayer( handler );
	}
}

onplayerkilled( handler ) //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "killed_player" );
		self thread unhandleplayer( handler, 1, 0 );
	}
}

handleplayer( handler ) //checked matches cerberus output
{
	self.handlers[ handler.id ].ready = 1;
	if ( !handler.enabled )
	{
		return;
	}
	if ( self.handlers[ handler.id ].handled )
	{
		return;
	}
	self.handlers[ handler.id ].handled = 1;
	self thread [[ handler.playerbegincallback ]]();
}

unhandleplayer( handler, unsetready, disconnected ) //checked matches cerberus output
{
	if ( !disconnected && unsetready )
	{
		self.handlers[ handler.id ].ready = 0;
	}
	if ( !self.handlers[ handler.id ].handled )
	{
		return;
	}
	if ( !disconnected )
	{
		self.handlers[ handler.id ].handled = 0;
	}
	self thread [[ handler.playerendcallback ]]( disconnected );
}

