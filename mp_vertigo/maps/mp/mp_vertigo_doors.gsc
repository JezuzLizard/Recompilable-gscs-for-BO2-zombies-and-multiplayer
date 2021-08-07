#include maps/mp/_tacticalinsertion;
#include maps/mp/gametypes/_weaponobjects;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	triggers = getentarray( "trigger_multiple", "classname" );
	i = 0;
	while ( i < 2 )
	{
		door = getent( "vertigo_door" + i, "targetname" );
		o = ( i + 1 ) % 2;
		otherdoor = getent( "vertigo_door" + o, "targetname" );
		if ( !isDefined( door ) )
		{
			i++;
			continue;
		}
		else right = anglesToForward( door.angles );
		right = vectorScale( right, 54 );
		door.opened = 1;
		door.origin_opened = door.origin;
		door.force_open_time = 0;
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "flip" )
		{
			door.origin_closed = door.origin - right;
		}
		else
		{
			door.origin_closed = door.origin + right;
		}
		door.origin = door.origin_closed;
		pointa = door getpointinbounds( 1, 1, 1 );
		pointb = door getpointinbounds( -1, -1, -1 );
		door.mins = getminpoint( pointa, pointb ) - door.origin;
		door.maxs = getmaxpoint( pointa, pointb ) - door.origin;
		door setcandamage( 1 );
		door allowbottargetting( 0 );
		door.triggers = [];
		_a57 = triggers;
		_k57 = getFirstArrayKey( _a57 );
		while ( isDefined( _k57 ) )
		{
			trigger = _a57[ _k57 ];
			if ( isDefined( trigger.target ) )
			{
				if ( trigger.target == door.targetname )
				{
					trigger.mins = trigger getmins();
					trigger.maxs = trigger getmaxs();
					door.triggers[ door.triggers.size ] = trigger;
				}
			}
			_k57 = getNextArrayKey( _a57, _k57 );
		}
		door thread door_damage_think( otherdoor );
		if ( i > 0 )
		{
			door thread door_notify_think( i );
			i++;
			continue;
		}
		else
		{
			door thread door_think( i );
		}
		i++;
	}
}

getminpoint( pointa, pointb )
{
	point = [];
	point[ 0 ] = pointa[ 0 ];
	point[ 1 ] = pointa[ 1 ];
	point[ 2 ] = pointa[ 2 ];
	i = 0;
	while ( i < 3 )
	{
		if ( point[ i ] > pointb[ i ] )
		{
			point[ i ] = pointb[ i ];
		}
		i++;
	}
	return ( point[ 0 ], point[ 1 ], point[ 2 ] );
}

getmaxpoint( pointa, pointb )
{
	point = [];
	point[ 0 ] = pointa[ 0 ];
	point[ 1 ] = pointa[ 1 ];
	point[ 2 ] = pointa[ 2 ];
	i = 0;
	while ( i < 3 )
	{
		if ( point[ i ] < pointb[ i ] )
		{
			point[ i ] = pointb[ i ];
		}
		i++;
	}
	return ( point[ 0 ], point[ 1 ], point[ 2 ] );
}

door_think( index )
{
	wait ( 0,05 * index );
	self door_close();
	for ( ;; )
	{
		wait 0,25;
		if ( self door_should_open() )
		{
			level notify( "dooropen" );
			self door_open();
		}
		else
		{
			level notify( "doorclose" );
			self door_close();
		}
		self movement_process();
	}
}

door_notify_think( index )
{
	wait ( 0,05 * index );
	self door_close();
	for ( ;; )
	{
		event = level waittill_any_return( "dooropen", "doorclose" );
		if ( !isDefined( event ) )
		{
			continue;
		}
		else
		{
			if ( event == "dooropen" )
			{
				self door_open();
			}
			else
			{
				self door_close();
			}
			self movement_process();
		}
	}
}

door_should_open()
{
	if ( getTime() < self.force_open_time )
	{
		return 1;
	}
	_a170 = self.triggers;
	_k170 = getFirstArrayKey( _a170 );
	while ( isDefined( _k170 ) )
	{
		trigger = _a170[ _k170 ];
		if ( trigger trigger_is_occupied() )
		{
			return 1;
		}
		_k170 = getNextArrayKey( _a170, _k170 );
	}
	return 0;
}

door_open()
{
	if ( self.opened )
	{
		return;
	}
	dist = distance( self.origin_opened, self.origin );
	frac = dist / 54;
	time = clamp( frac * 0,3, 0,1, 0,3 );
	self moveto( self.origin_opened, time );
	self playsound( "mpl_drone_door_open" );
	self.opened = 1;
}

door_close()
{
	if ( !self.opened )
	{
		return;
	}
	dist = distance( self.origin_closed, self.origin );
	frac = dist / 54;
	time = clamp( frac * 0,3, 0,1, 0,3 );
	self moveto( self.origin_closed, time );
	self playsound( "mpl_drone_door_close" );
	self.opened = 0;
}

movement_process()
{
	moving = 0;
	if ( self.opened )
	{
		if ( distancesquared( self.origin, self.origin_opened ) > 0,001 )
		{
			moving = 1;
		}
	}
	else
	{
		if ( distancesquared( self.origin, self.origin_closed ) > 0,001 )
		{
			moving = 1;
		}
	}
	while ( moving )
	{
		entities = gettouchingvolume( self.origin, self.mins, self.maxs );
		_a238 = entities;
		_k238 = getFirstArrayKey( _a238 );
		while ( isDefined( _k238 ) )
		{
			entity = _a238[ _k238 ];
			if ( isDefined( entity.classname ) && entity.classname == "grenade" )
			{
				if ( !isDefined( entity.name ) )
				{
				}
				else if ( !isDefined( entity.owner ) )
				{
				}
				else watcher = entity.owner getwatcherforweapon( entity.name );
				if ( !isDefined( watcher ) )
				{
				}
				else watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined );
			}
			if ( self.opened )
			{
			}
			else if ( isDefined( entity.classname ) && entity.classname == "auto_turret" )
			{
				if ( !isDefined( entity.damagedtodeath ) || !entity.damagedtodeath )
				{
					entity domaxdamage( self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
				}
			}
			else
			{
				if ( isDefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
				{
					entity maps/mp/_tacticalinsertion::destroy_tactical_insertion();
				}
			}
			_k238 = getNextArrayKey( _a238, _k238 );
		}
	}
}

trigger_is_occupied()
{
	entities = gettouchingvolume( self.origin, self.mins, self.maxs );
	_a294 = entities;
	_k294 = getFirstArrayKey( _a294 );
	while ( isDefined( _k294 ) )
	{
		entity = _a294[ _k294 ];
		if ( isalive( entity ) )
		{
			if ( !isplayer( entity ) || isai( entity ) && isvehicle( entity ) )
			{
				return 1;
			}
		}
		_k294 = getNextArrayKey( _a294, _k294 );
	}
	return 0;
}

getwatcherforweapon( weapname )
{
	if ( !isDefined( self ) )
	{
		return undefined;
	}
	if ( !isplayer( self ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapname )
		{
			i++;
			continue;
		}
		else
		{
			return self.weaponobjectwatcherarray[ i ];
		}
		i++;
	}
	return undefined;
}

door_damage_think( otherdoor )
{
	self.maxhealth = 99999;
	self.health = self.maxhealth;
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags );
		self.maxhealth = 99999;
		self.health = self.maxhealth;
		if ( mod == "MOD_PISTOL_BULLET" || mod == "MOD_RIFLE_BULLET" )
		{
			self.force_open_time = getTime() + 1500;
			otherdoor.force_open_time = getTime() + 1500;
		}
	}
}
