#include maps/mp/gametypes/_perplayer;

main()
{
	level.tearradius = 170;
	level.tearheight = 128;
	level.teargasfillduration = 7;
	level.teargasduration = 23;
	level.tearsufferingduration = 3;
	level.teargrenadetimer = 4;
	precacheshellshock( "teargas" );
	fgmonitor = maps/mp/gametypes/_perplayer::init( "tear_grenade_monitor", ::startmonitoringtearusage, ::stopmonitoringtearusage );
	maps/mp/gametypes/_perplayer::enable( fgmonitor );
}

startmonitoringtearusage()
{
	self thread monitortearusage();
}

stopmonitoringtearusage( disconnected )
{
	self notify( "stop_monitoring_tear_usage" );
}

monitortearusage()
{
	self endon( "stop_monitoring_tear_usage" );
	wait 0,05;
	if ( !self hasweapon( "tear_grenade_mp" ) )
	{
		return;
	}
	prevammo = self getammocount( "tear_grenade_mp" );
	while ( 1 )
	{
		ammo = self getammocount( "tear_grenade_mp" );
		while ( ammo < prevammo )
		{
			num = prevammo - ammo;
/#
#/
			i = 0;
			while ( i < num )
			{
				grenades = getentarray( "grenade", "classname" );
				bestdist = undefined;
				bestg = undefined;
				g = 0;
				while ( g < grenades.size )
				{
					if ( !isDefined( grenades[ g ].teargrenade ) )
					{
						dist = distance( grenades[ g ].origin, self.origin + vectorScale( ( 0, 0, 1 ), 48 ) );
						if ( !isDefined( bestdist ) || dist < bestdist )
						{
							bestdist = dist;
							bestg = g;
						}
					}
					g++;
				}
				if ( isDefined( bestdist ) )
				{
					grenades[ bestg ].teargrenade = 1;
					grenades[ bestg ] thread teargrenade_think( self.team );
				}
				i++;
			}
		}
		prevammo = ammo;
		wait 0,05;
	}
}

teargrenade_think( team )
{
	wait level.teargrenadetimer;
	ent = spawnstruct();
	ent thread tear( self.origin );
}

tear( pos )
{
	trig = spawn( "trigger_radius", pos, 0, level.tearradius, level.tearheight );
	starttime = getTime();
	self thread teartimer();
	self endon( "tear_timeout" );
	while ( 1 )
	{
		trig waittill( "trigger", player );
		while ( player.sessionstate != "playing" )
		{
			continue;
		}
		time = ( getTime() - starttime ) / 1000;
		currad = level.tearradius;
		curheight = level.tearheight;
		if ( time < level.teargasfillduration )
		{
			currad *= time / level.teargasfillduration;
			curheight *= time / level.teargasfillduration;
		}
		offset = ( player.origin + vectorScale( ( 0, 0, 1 ), 32 ) ) - pos;
		offset2d = ( offset[ 0 ], offset[ 1 ], 0 );
		while ( lengthsquared( offset2d ) > ( currad * currad ) )
		{
			continue;
		}
		while ( ( player.origin[ 2 ] - pos[ 2 ] ) > curheight )
		{
			continue;
		}
		player.teargasstarttime = getTime();
		if ( !isDefined( player.teargassuffering ) )
		{
			player thread teargassuffering();
		}
	}
}

teartimer()
{
	wait level.teargasduration;
	self notify( "tear_timeout" );
}

teargassuffering()
{
	self endon( "death" );
	self endon( "disconnect" );
	self.teargassuffering = 1;
	if ( self mayapplyscreeneffect() )
	{
		self shellshock( "teargas", 60 );
	}
	while ( 1 )
	{
		if ( ( getTime() - self.teargasstarttime ) > ( level.tearsufferingduration * 1000 ) )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	self shellshock( "teargas", 1 );
	if ( self mayapplyscreeneffect() )
	{
		self.teargassuffering = undefined;
	}
}

drawcylinder( pos, rad, height )
{
	time = 0;
	while ( 1 )
	{
		currad = rad;
		curheight = height;
		if ( time < level.teargasfillduration )
		{
			currad *= time / level.teargasfillduration;
			curheight *= time / level.teargasfillduration;
		}
		r = 0;
		while ( r < 20 )
		{
			theta = ( r / 20 ) * 360;
			theta2 = ( ( r + 1 ) / 20 ) * 360;
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
			r++;
		}
		time += 0,05;
		if ( time > level.teargasduration )
		{
			return;
		}
		else
		{
			wait 0,05;
		}
	}
}
