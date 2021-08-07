#include maps/mp/killstreaks/_supplydrop;
#include maps/mp/_tacticalinsertion;
#include maps/mp/gametypes/_weaponobjects;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precachestring( &"MP_LIFT_OPERATE" );
	precachestring( &"MP_LIFT_COOLDOWN" );
	trigger = getent( "lift_trigger", "targetname" );
	platform = getent( "lift_platform", "targetname" );
	if ( !isDefined( trigger ) || !isDefined( platform ) )
	{
		return;
	}
	trigger enablelinkto();
	trigger linkto( platform );
	part = getent( "lift_part", "targetname" );
	if ( isDefined( part ) )
	{
		part linkto( platform );
	}
	level thread lift_think( trigger, platform );
}

lift_think( trigger, platform )
{
	level waittill( "prematch_over" );
	location = 0;
	for ( ;; )
	{
		trigger sethintstring( &"MP_LIFT_OPERATE" );
		trigger waittill( "trigger" );
		trigger sethintstring( &"MP_LIFT_COOLDOWN" );
		if ( location == 0 )
		{
			goal = platform.origin + vectorScale( ( 0, 0, 1 ), 128 );
			location = 1;
		}
		else
		{
			goal = platform.origin - vectorScale( ( 0, 0, 1 ), 128 );
			location = 0;
		}
		platform thread lift_move_think( goal );
		platform waittill( "movedone" );
		if ( location == 1 )
		{
			trigger thread lift_auto_lower_think();
		}
		wait 10;
	}
}

lift_move_think( goal )
{
	self endon( "movedone" );
	timer = 5;
	self moveto( goal, 5 );
	while ( timer >= 0 )
	{
		self destroy_equipment();
		self destroy_tactical_insertions();
		self destroy_supply_crates();
		self destroy_corpses();
		self destroy_stuck_weapons();
		wait 0,5;
		timer -= 0,5;
	}
}

lift_auto_lower_think()
{
	self endon( "trigger" );
	wait 30;
	self notify( "trigger" );
}

destroy_equipment()
{
	grenades = getentarray( "grenade", "classname" );
	i = 0;
	while ( i < grenades.size )
	{
		item = grenades[ i ];
		if ( !isDefined( item.name ) )
		{
			i++;
			continue;
		}
		else if ( !isDefined( item.owner ) )
		{
			i++;
			continue;
		}
		else if ( !isweaponequipment( item.name ) )
		{
			i++;
			continue;
		}
		else if ( !item istouching( self ) )
		{
			i++;
			continue;
		}
		else watcher = item.owner getwatcherforweapon( item.name );
		if ( !isDefined( watcher ) )
		{
			i++;
			continue;
		}
		else
		{
			watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( item, 0, undefined );
		}
		i++;
	}
}

destroy_tactical_insertions()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( !isDefined( player.tacticalinsertion ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( player.tacticalinsertion istouching( self ) )
			{
				player.tacticalinsertion maps/mp/_tacticalinsertion::destroy_tactical_insertion();
			}
		}
		i++;
	}
}

destroy_supply_crates()
{
	crates = getentarray( "care_package", "script_noteworthy" );
	i = 0;
	while ( i < crates.size )
	{
		crate = crates[ i ];
		if ( crate istouching( self ) )
		{
			playfx( level._supply_drop_explosion_fx, crate.origin );
			playsoundatposition( "wpn_grenade_explode", crate.origin );
			wait 0,1;
			crate maps/mp/killstreaks/_supplydrop::cratedelete();
		}
		i++;
	}
}

destroy_corpses()
{
	corpses = getcorpsearray();
	i = 0;
	while ( i < corpses.size )
	{
		if ( distance2dsquared( corpses[ i ].origin, self.origin ) < 1048576 )
		{
			corpses[ i ] delete();
		}
		i++;
	}
}

destroy_stuck_weapons()
{
	weapons = getentarray( "sticky_weapon", "targetname" );
	origin = self getpointinbounds( 0, 0, -0,6 );
	z_cutoff = origin[ 2 ];
	i = 0;
	while ( i < weapons.size )
	{
		weapon = weapons[ i ];
		if ( weapon istouching( self ) && weapon.origin[ 2 ] > z_cutoff )
		{
			weapon delete();
		}
		i++;
	}
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
