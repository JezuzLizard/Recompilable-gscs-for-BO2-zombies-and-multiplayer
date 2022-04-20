#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
		player thread onplayerdeath();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	self._bbdata = [];
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self._bbdata[ "score" ] = 0;
		self._bbdata[ "momentum" ] = 0;
		self._bbdata[ "spawntime" ] = getTime();
		self._bbdata[ "shots" ] = 0;
		self._bbdata[ "hits" ] = 0;
	}
}

onplayerdisconnect()
{
	for ( ;; )
	{
		self waittill( "disconnect" );
		self commitspawndata();
		return;
	}
}

onplayerdeath()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "death" );
		self commitspawndata();
	}
}

commitspawndata()
{
/#
	assert( isDefined( self._bbdata ) );
#/
	if ( !isDefined( self._bbdata ) )
	{
		return;
	}
	bbprint( "mpplayerlives", "gametime %d spawnid %d lifescore %d lifemomentum %d lifetime %d name %s", getTime(), getplayerspawnid( self ), self._bbdata[ "score" ], self._bbdata[ "momentum" ], getTime() - self._bbdata[ "spawntime" ], self.name );
}

commitweapondata( spawnid, currentweapon, time0 )
{
/#
	assert( isDefined( self._bbdata ) );
#/
	if ( !isDefined( self._bbdata ) )
	{
		return;
	}
	time1 = getTime();
	bbprint( "mpweapons", "spawnid %d name %s duration %d shots %d hits %d", spawnid, currentweapon, time1 - time0, self._bbdata[ "shots" ], self._bbdata[ "hits" ] );
	self._bbdata[ "shots" ] = 0;
	self._bbdata[ "hits" ] = 0;
}

bbaddtostat( statname, delta )
{
	if ( isDefined( self._bbdata ) && isDefined( self._bbdata[ statname ] ) )
	{
		self._bbdata[ statname ] += delta;
	}
}
