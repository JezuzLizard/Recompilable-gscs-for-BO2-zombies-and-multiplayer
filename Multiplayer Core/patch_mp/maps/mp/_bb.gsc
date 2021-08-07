//includes match cerberus output
#include common_scripts/utility;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
		player thread onplayerdeath();
	}
}

onplayerspawned() //checked matches cerberus output
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

onplayerdisconnect() //checked changed to match beta dump
{
	for ( ;; )
	{
		self waittill( "disconnect" );
		self commitspawndata();
		break;
	}
}

onplayerdeath() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "death" );
		self commitspawndata();
	}
}

commitspawndata() //checked matches cerberus output
{
	/*
/#
	assert( isDefined( self._bbdata ) );
#/
	*/
	if ( !isDefined( self._bbdata ) )
	{
		return;
	}
	bbprint( "mpplayerlives", "gametime %d spawnid %d lifescore %d lifemomentum %d lifetime %d name %s", getTime(), getplayerspawnid( self ), self._bbdata[ "score" ], self._bbdata[ "momentum" ], getTime() - self._bbdata[ "spawntime" ], self.name );
}

commitweapondata( spawnid, currentweapon, time0 ) //checked matches cerberus output
{
	/*
/#
	assert( isDefined( self._bbdata ) );
#/
	*/
	if ( !isDefined( self._bbdata ) )
	{
		return;
	}
	time1 = getTime();
	bbprint( "mpweapons", "spawnid %d name %s duration %d shots %d hits %d", spawnid, currentweapon, time1 - time0, self._bbdata[ "shots" ], self._bbdata[ "hits" ] );
	self._bbdata[ "shots" ] = 0;
	self._bbdata[ "hits" ] = 0;
}

bbaddtostat( statname, delta ) //checked matches cerberus output
{
	if ( isDefined( self._bbdata ) && isDefined( self._bbdata[ statname ] ) )
	{
		self._bbdata[ statname ] += delta;
	}
}
