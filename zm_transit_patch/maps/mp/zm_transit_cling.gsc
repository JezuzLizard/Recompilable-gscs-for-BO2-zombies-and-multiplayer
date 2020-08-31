#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

initializecling()
{
	setupclingtrigger();
}

setupclingtrigger()
{
	if ( !isDefined( level.the_bus ) )
	{
		return;
	}
	enablecling();
	triggers = [];
	level.cling_triggers = [];
	triggers = getentarray( "cling_trigger", "script_noteworthy" );
	i = 0;
	while ( i < triggers.size )
	{
		level.cling_triggers[ i ] = spawnstruct();
		level.cling_triggers[ i ].trigger = triggers[ i ];
		trigger = level.cling_triggers[ i ].trigger;
		trigger sethintstring( "Hold [{+activate}] To Cling To The Bus." );
		trigger setcursorhint( "HINT_NOICON" );
		makevisibletoall( trigger );
		trigger enablelinkto();
		trigger linkto( level.the_bus, "", level.the_bus worldtolocalcoords( trigger.origin ), trigger.angles - level.the_bus.angles );
		trigger thread setclingtriggervisibility( i );
		trigger thread clingtriggerusethink( i );
		level.cling_triggers[ i ].position = getent( trigger.target, "targetname" );
		position = level.cling_triggers[ i ].position;
		position linkto( level.the_bus, "", level.the_bus worldtolocalcoords( position.origin ), position.angles - level.the_bus.angles );
		level.cling_triggers[ i ].player = undefined;
		i++;
	}
	disablecling();
}

enablecling()
{
	level.cling_enabled = 1;
	while ( isDefined( level.cling_triggers ) )
	{
		_a65 = level.cling_triggers;
		_k65 = getFirstArrayKey( _a65 );
		while ( isDefined( _k65 ) )
		{
			struct = _a65[ _k65 ];
			struct.trigger sethintstring( "Hold [{+activate}] To Cling To The Bus." );
			struct.trigger setteamfortrigger( "allies" );
			_k65 = getNextArrayKey( _a65, _k65 );
		}
	}
}

disablecling()
{
	level.cling_enabled = 0;
	detachallplayersfromclinging();
	while ( isDefined( level.cling_triggers ) )
	{
		_a81 = level.cling_triggers;
		_k81 = getFirstArrayKey( _a81 );
		while ( isDefined( _k81 ) )
		{
			struct = _a81[ _k81 ];
			struct.trigger sethintstring( "" );
			struct.trigger setteamfortrigger( "none" );
			_k81 = getNextArrayKey( _a81, _k81 );
		}
	}
}

makevisibletoall( trigger )
{
	players = get_players();
	playerindex = 0;
	while ( playerindex < players.size )
	{
		trigger setinvisibletoplayer( players[ playerindex ], 0 );
		playerindex++;
	}
}

clingtriggerusethink( positionindex )
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		while ( !level.cling_enabled )
		{
			continue;
		}
		while ( !who usebuttonpressed() )
		{
			continue;
		}
		while ( who in_revive_trigger() )
		{
			continue;
		}
		if ( isDefined( who.is_drinking ) && who.is_drinking == 1 )
		{
			continue;
		}
		while ( isDefined( level.cling_triggers[ positionindex ].player ) )
		{
			if ( level.cling_triggers[ positionindex ].player == who )
			{
				dettachplayerfrombus( who, positionindex );
			}
		}
		attachplayertobus( who, positionindex );
		thread detachfrombusonevent( who, positionindex );
	}
}

setclingtriggervisibility( positionindex )
{
	while ( 1 )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( isDefined( level.cling_triggers[ positionindex ].player ) )
			{
				is_player_clinging = level.cling_triggers[ positionindex ].player == players[ i ];
			}
			no_player_clinging = !isDefined( level.cling_triggers[ positionindex ].player );
			if ( is_player_clinging || no_player_clinging && level.cling_enabled )
			{
				self setinvisibletoplayer( players[ i ], 0 );
				i++;
				continue;
			}
			else
			{
				self setinvisibletoplayer( players[ i ], 1 );
			}
			i++;
		}
		wait 0,1;
	}
}

detachallplayersfromclinging()
{
	positionindex = 0;
	while ( positionindex < level.cling_triggers.size )
	{
		if ( !isDefined( level.cling_triggers[ positionindex ] ) || !isDefined( level.cling_triggers[ positionindex ].player ) )
		{
			positionindex++;
			continue;
		}
		else
		{
			players = get_players();
			i = 0;
			while ( i < players.size )
			{
				if ( level.cling_triggers[ positionindex ].player == players[ i ] )
				{
					dettachplayerfrombus( players[ i ], positionindex );
					positionindex++;
					continue;
				}
				else
				{
					i++;
				}
			}
		}
		positionindex++;
	}
}

attachplayertobus( player, positionindex )
{
	turn_angle = 130;
	pitch_up = 25;
	if ( positionisupgraded( positionindex ) )
	{
		turn_angle = 180;
		pitch_up = 120;
	}
	level.cling_triggers[ positionindex ].player = player;
	if ( positionisbl( positionindex ) )
	{
		player playerlinktodelta( level.cling_triggers[ positionindex ].position, "tag_origin", 1, 180, turn_angle, pitch_up, 120, 1 );
	}
	else if ( positionisbr( positionindex ) )
	{
		player playerlinktodelta( level.cling_triggers[ positionindex ].position, "tag_origin", 1, turn_angle, 180, pitch_up, 120, 1 );
	}
	else
	{
		level.cling_triggers[ positionindex ].player = undefined;
		return;
	}
	level.cling_triggers[ positionindex ].trigger sethintstring( "Hold [{+activate}] To Let Go Of The Bus." );
	player disableplayerweapons( positionindex );
}

positionisbl( positionindex )
{
	return level.cling_triggers[ positionindex ].position.script_string == "back_left";
}

positionisbr( positionindex )
{
	return level.cling_triggers[ positionindex ].position.script_string == "back_right";
}

positionisupgraded( positionindex )
{
	if ( positionisbl( positionindex ) && isDefined( level.the_bus.upgrades[ "PlatformL" ] ) && !level.the_bus.upgrades[ "PlatformL" ].installed )
	{
		if ( positionisbr( positionindex ) && isDefined( level.the_bus.upgrades[ "PlatformR" ] ) )
		{
			return level.the_bus.upgrades[ "PlatformR" ].installed;
		}
	}
}

dettachplayerfrombus( player, positionindex )
{
	level.cling_triggers[ positionindex ].trigger sethintstring( "Hold [{+activate}] To Cling To The Bus." );
	if ( !isDefined( level.cling_triggers[ positionindex ].player ) )
	{
		return;
	}
	player unlink();
	level.cling_triggers[ positionindex ].player = undefined;
	player enableplayerweapons( positionindex );
	player notify( "cling_dettached" );
}

detachfrombusonevent( player, positionindex )
{
	player endon( "cling_dettached" );
	player waittill_any( "fake_death", "death", "player_downed" );
	dettachplayerfrombus( player, positionindex );
}

disableplayerweapons( positionindex )
{
	weaponinventory = self getweaponslist( 1 );
	self.lastactiveweapon = self getcurrentweapon();
	self.clingpistol = undefined;
	self.hadclingpistol = 0;
	if ( !positionisupgraded( positionindex ) )
	{
		i = 0;
		while ( i < weaponinventory.size )
		{
			weapon = weaponinventory[ i ];
			if ( weaponclass( weapon ) == "pistol" && isDefined( self.clingpistol ) || weapon == self.lastactiveweapon && self.clingpistol == "m1911_zm" )
			{
				self.clingpistol = weapon;
				self.hadclingpistol = 1;
			}
			i++;
		}
		if ( !isDefined( self.clingpistol ) )
		{
			self giveweapon( "m1911_zm" );
			self.clingpistol = "m1911_zm";
		}
		self switchtoweapon( self.clingpistol );
		self disableweaponcycling();
		self disableoffhandweapons();
		self allowcrouch( 0 );
	}
	self allowlean( 0 );
	self allowsprint( 0 );
	self allowprone( 0 );
}

enableplayerweapons( positionindex )
{
	self allowlean( 1 );
	self allowsprint( 1 );
	self allowprone( 1 );
	if ( !positionisupgraded( positionindex ) )
	{
		if ( !self.hadclingpistol )
		{
			self takeweapon( "m1911_zm" );
		}
		self enableweaponcycling();
		self enableoffhandweapons();
		self allowcrouch( 1 );
		if ( self.lastactiveweapon != "none" && self.lastactiveweapon != "mortar_round" && self.lastactiveweapon != "mine_bouncing_betty" && self.lastactiveweapon != "claymore_zm" )
		{
			self switchtoweapon( self.lastactiveweapon );
			return;
		}
		else
		{
			primaryweapons = self getweaponslistprimaries();
			if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
			{
				self switchtoweapon( primaryweapons[ 0 ] );
			}
		}
	}
}

playerisclingingtobus()
{
	if ( !isDefined( level.cling_triggers ) )
	{
		return 0;
	}
	i = 0;
	while ( i < level.cling_triggers.size )
	{
		if ( !isDefined( level.cling_triggers[ i ] ) || !isDefined( level.cling_triggers[ i ].player ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( level.cling_triggers[ i ].player == self )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

_getnumplayersclinging()
{
	num_clinging = 0;
	i = 0;
	while ( i < level.cling_triggers.size )
	{
		if ( isDefined( level.cling_triggers[ i ] ) && isDefined( level.cling_triggers[ i ].player ) )
		{
			num_clinging++;
		}
		i++;
	}
	return num_clinging;
}

_getbusattackposition( player )
{
	pos = ( -208, 0, 48 );
	return level.the_bus localtoworldcoords( pos );
}
