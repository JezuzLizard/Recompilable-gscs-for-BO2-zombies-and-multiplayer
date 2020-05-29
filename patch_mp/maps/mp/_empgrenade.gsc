#include maps/mp/killstreaks/_emp;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precacheshellshock( "flashbang" );
	thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread monitorempgrenade();
	}
}

monitorempgrenade()
{
	self endon( "disconnect" );
	self endon( "death" );
	self.empendtime = 0;
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill( "emp_grenaded", attacker );
			if ( !isalive( self ) || self hasperk( "specialty_immuneemp" ) )
			{
				continue;
			}
			hurtvictim = 1;
			hurtattacker = 0;
/#
			assert( isDefined( self.team ) );
#/
			if ( level.teambased && isDefined( attacker ) && isDefined( attacker.team ) && attacker.team == self.team && attacker != self )
			{
				if ( level.friendlyfire == 0 )
				{
				}
			}
			else if ( level.friendlyfire == 1 )
			{
				hurtattacker = 0;
				hurtvictim = 1;
				break;
			}
			else if ( level.friendlyfire == 2 )
			{
				hurtvictim = 0;
				hurtattacker = 1;
				break;
			}
			else
			{
				if ( level.friendlyfire == 3 )
				{
					hurtattacker = 1;
					hurtvictim = 1;
				}
			}
		}
		if ( hurtvictim && isDefined( self ) )
		{
			self thread applyemp( attacker );
		}
		if ( hurtattacker && isDefined( attacker ) )
		{
			attacker thread applyemp( attacker );
		}
	}
}

applyemp( attacker )
{
	self notify( "applyEmp" );
	self endon( "applyEmp" );
	self endon( "disconnect" );
	self endon( "death" );
	wait 0,05;
	if ( self == attacker )
	{
		if ( isDefined( self.empendtime ) )
		{
			emp_time_left_ms = self.empendtime - getTime();
			if ( emp_time_left_ms > 1000 )
			{
				self.empduration = emp_time_left_ms / 1000;
			}
			else
			{
				self.empduration = 1;
			}
		}
		else
		{
			self.empduration = 1;
		}
	}
	else
	{
		self.empduration = 12;
	}
	self.empgrenaded = 1;
	self shellshock( "flashbang", 1 );
	self.empendtime = getTime() + ( self.empduration * 1000 );
	self thread emprumbleloop( 0,75 );
	self setempjammed( 1 );
	self thread empgrenadedeathwaiter();
	wait self.empduration;
	self notify( "empGrenadeTimedOut" );
	self checktoturnoffemp();
}

empgrenadedeathwaiter()
{
	self notify( "empGrenadeDeathWaiter" );
	self endon( "empGrenadeDeathWaiter" );
	self endon( "empGrenadeTimedOut" );
	self waittill( "death" );
	self checktoturnoffemp();
}

checktoturnoffemp()
{
	self.empgrenaded = 0;
	if ( level.teambased || maps/mp/killstreaks/_emp::emp_isteamemped( self.team ) && !level.teambased && isDefined( level.empplayer ) && level.empplayer != self )
	{
		return;
	}
	self setempjammed( 0 );
}

emprumbleloop( duration )
{
	self endon( "emp_rumble_loop" );
	self notify( "emp_rumble_loop" );
	goaltime = getTime() + ( duration * 1000 );
	while ( getTime() < goaltime )
	{
		self playrumbleonentity( "damage_heavy" );
		wait 0,05;
	}
}

watchempexplosion( owner, weaponname )
{
	owner endon( "disconnect" );
	owner endon( "team_changed" );
	self endon( "shutdown_empgrenade" );
	self thread watchempgrenadeshutdown();
	owner addweaponstat( weaponname, "used", 1 );
	self waittill( "explode", origin, surface );
	ents = getdamageableentarray( origin, 512 );
	_a223 = ents;
	_k223 = getFirstArrayKey( _a223 );
	while ( isDefined( _k223 ) )
	{
		ent = _a223[ _k223 ];
		ent dodamage( 1, origin, owner, owner, "none", "MOD_GRENADE_SPLASH", 0, weaponname );
		_k223 = getNextArrayKey( _a223, _k223 );
	}
}

watchempgrenadeshutdown()
{
	self endon( "explode" );
	self waittill( "death" );
	wait 0,05;
	self notify( "shutdown_empgrenade" );
}
