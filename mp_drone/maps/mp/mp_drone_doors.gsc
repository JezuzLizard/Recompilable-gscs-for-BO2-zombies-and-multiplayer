#include maps/mp/_tacticalinsertion;
#include maps/mp/gametypes/_weaponobjects;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	triggers = getentarray( "trigger_multiple", "classname" );
	i = 0;
	while ( i < 4 )
	{
		door = getent( "drone_door" + i, "targetname" );
		if ( !isDefined( door ) )
		{
			i++;
			continue;
		}
		else
		{
			right = anglesToForward( door.angles );
			right = vectorScale( right, 116 );
			door.opened = 1;
			door.origin_opened = door.origin;
			door.force_open_time = 0;
			if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "flip" )
			{
				door.origin_closed = door.origin + right;
			}
			else
			{
				door.origin_closed = door.origin - right;
			}
			door.mins = door getmins();
			door.maxs = door getmaxs();
			door setcandamage( 1 );
			door allowbottargetting( 0 );
			door.triggers = [];
			_a49 = triggers;
			_k49 = getFirstArrayKey( _a49 );
			while ( isDefined( _k49 ) )
			{
				trigger = _a49[ _k49 ];
				if ( isDefined( trigger.target ) )
				{
					if ( trigger.target == door.targetname )
					{
						trigger.mins = trigger getmins();
						trigger.maxs = trigger getmaxs();
						door.triggers[ door.triggers.size ] = trigger;
					}
				}
				_k49 = getNextArrayKey( _a49, _k49 );
			}
			door thread door_damage_think();
			door thread door_think( i );
		}
		i++;
	}
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
			self door_open();
		}
		else
		{
			self door_close();
		}
		self movement_process();
	}
}

door_should_open()
{
	if ( getTime() < self.force_open_time )
	{
		return 1;
	}
	_a97 = self.triggers;
	_k97 = getFirstArrayKey( _a97 );
	while ( isDefined( _k97 ) )
	{
		trigger = _a97[ _k97 ];
		if ( trigger trigger_is_occupied() )
		{
			return 1;
		}
		_k97 = getNextArrayKey( _a97, _k97 );
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
	frac = dist / 116;
	time = clamp( frac * 0,5, 0,1, 0,5 );
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
	frac = dist / 116;
	time = clamp( frac * 0,5, 0,1, 0,5 );
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
		_a165 = entities;
		_k165 = getFirstArrayKey( _a165 );
		while ( isDefined( _k165 ) )
		{
			entity = _a165[ _k165 ];
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
			_k165 = getNextArrayKey( _a165, _k165 );
		}
	}
}

trigger_is_occupied()
{
	entities = gettouchingvolume( self.origin, self.mins, self.maxs );
	_a221 = entities;
	_k221 = getFirstArrayKey( _a221 );
	while ( isDefined( _k221 ) )
	{
		entity = _a221[ _k221 ];
		if ( isalive( entity ) )
		{
			if ( !isplayer( entity ) || isai( entity ) && isvehicle( entity ) )
			{
				return 1;
			}
		}
		_k221 = getNextArrayKey( _a221, _k221 );
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

door_damage_think()
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
		}
	}
}
