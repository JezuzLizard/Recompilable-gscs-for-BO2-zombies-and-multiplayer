//checked includes match cerberus output
#include maps/mp/gametypes/_perplayer;

main() //checked matches cerberus output
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

startmonitoringtearusage() //checked matches cerberus output
{
	self thread monitortearusage();
}

stopmonitoringtearusage( disconnected ) //checked matches cerberus output
{
	self notify( "stop_monitoring_tear_usage" );
}

monitortearusage() //checked changed to match cerberus output
{
	self endon( "stop_monitoring_tear_usage" );
	wait 0.05;
	if ( !self hasweapon( "tear_grenade_mp" ) )
	{
		return;
	}
	prevammo = self getammocount( "tear_grenade_mp" );
	while ( 1 )
	{
		ammo = self getammocount( "tear_grenade_mp" );
		if ( ammo < prevammo )
		{
			num = prevammo - ammo;
			for ( i = 0; i < num; i++ )
			{
				grenades = getentarray( "grenade", "classname" );
				bestdist = undefined;
				bestg = undefined;
				for ( g = 0; g < grenades.size; g++ )
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
				}
				if ( isDefined( bestdist ) )
				{
					grenades[ bestg ].teargrenade = 1;
					grenades[ bestg ] thread teargrenade_think( self.team );
				}
			}
		}
		prevammo = ammo;
		wait 0.05;
	}
}

teargrenade_think( team ) //checked matches cerberus output
{
	wait level.teargrenadetimer;
	ent = spawnstruct();
	ent thread tear( self.origin );
}

tear( pos ) //checked changed to match beta dump
{
	trig = spawn( "trigger_radius", pos, 0, level.tearradius, level.tearheight );
	starttime = getTime();
	self thread teartimer();
	self endon( "tear_timeout" );
	while ( 1 )
	{
		trig waittill( "trigger", player );
		if ( player.sessionstate != "playing" )
		{
			continue;
		}
		time = ( getTime() - starttime ) / 1000;
		currad = level.tearradius;
		curheight = level.tearheight;
		if ( time < level.teargasfillduration )
		{
			currad = currad * ( time / level.teargasfillduration );
			curheight = curheight * ( time / level.teargasfillduration );
		}
		offset = ( player.origin + vectorScale( ( 0, 0, 1 ), 32 ) ) - pos;
		offset2d = ( offset[ 0 ], offset[ 1 ], 0 );
		if ( lengthsquared( offset2d ) > ( currad * currad ) )
		{
			continue;
		}
		if ( ( player.origin[ 2 ] - pos[ 2 ] ) > curheight )
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

teartimer() //checked matches cerberus output
{
	wait level.teargasduration;
	self notify( "tear_timeout" );
}

teargassuffering() //checked changed to match cerberus output
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
		wait 1;
	}
	self shellshock( "teargas", 1 );
	if ( self mayapplyscreeneffect() )
	{
		self.teargassuffering = undefined;
	}
}

drawcylinder( pos, rad, height ) //checked changed to match beta dump
{
	time = 0;
	while ( 1 )
	{
		currad = rad;
		curheight = height;
		if ( time < level.teargasfillduration )
		{
			currad = currad * ( time / level.teargasfillduration );
			curheight = curheight * ( time / level.teargasfillduration );
		}
		for ( r = 0; r < 20; r++ )
		{
			theta = ( r / 20 ) * 360;
			theta2 = ( ( r + 1 ) / 20 ) * 360;
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
		}
		time += 0.05;
		if ( time > level.teargasduration )
		{
			return;
		}
		wait 0.05;
	}
}

