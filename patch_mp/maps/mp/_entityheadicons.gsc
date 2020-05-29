#include common_scripts/utility;

init()
{
	if ( isDefined( level.initedentityheadicons ) )
	{
		return;
	}
	if ( level.createfx_enabled )
	{
		return;
	}
	level.initedentityheadicons = 1;
/#
	assert( isDefined( game[ "entity_headicon_allies" ] ), "Allied head icons are not defined.  Check the team set for the level." );
#/
/#
	assert( isDefined( game[ "entity_headicon_axis" ] ), "Axis head icons are not defined.  Check the team set for the level." );
#/
	precacheshader( game[ "entity_headicon_allies" ] );
	precacheshader( game[ "entity_headicon_axis" ] );
	if ( !level.teambased )
	{
		return;
	}
	level.entitieswithheadicons = [];
}

setentityheadicon( team, owner, offset, icon, constant_size )
{
	if ( !level.teambased && !isDefined( owner ) )
	{
		return;
	}
	if ( !isDefined( constant_size ) )
	{
		constant_size = 0;
	}
	if ( !isDefined( self.entityheadiconteam ) )
	{
		self.entityheadiconteam = "none";
		self.entityheadicons = [];
	}
	if ( level.teambased && !isDefined( owner ) )
	{
		if ( team == self.entityheadiconteam )
		{
			return;
		}
		self.entityheadiconteam = team;
	}
	if ( isDefined( offset ) )
	{
		self.entityheadiconoffset = offset;
	}
	else
	{
		self.entityheadiconoffset = ( 0, 0, 0 );
	}
	while ( isDefined( self.entityheadicons ) )
	{
		i = 0;
		while ( i < self.entityheadicons.size )
		{
			if ( isDefined( self.entityheadicons[ i ] ) )
			{
				self.entityheadicons[ i ] destroy();
			}
			i++;
		}
	}
	self.entityheadicons = [];
	self notify( "kill_entity_headicon_thread" );
	if ( !isDefined( icon ) )
	{
		icon = game[ "entity_headicon_" + team ];
	}
	if ( isDefined( owner ) && !level.teambased )
	{
		if ( !isplayer( owner ) )
		{
/#
			assert( isDefined( owner.owner ), "entity has to have an owner if it's not a player" );
#/
			owner = owner.owner;
		}
		owner updateentityheadclienticon( self, icon, constant_size );
	}
	else
	{
		if ( isDefined( owner ) && team != "none" )
		{
			owner updateentityheadteamicon( self, team, icon, constant_size );
		}
	}
	self thread destroyheadiconsondeath();
}

updateentityheadteamicon( entity, team, icon, constant_size )
{
	headicon = newteamhudelem( team );
	headicon.archived = 1;
	headicon.x = entity.entityheadiconoffset[ 0 ];
	headicon.y = entity.entityheadiconoffset[ 1 ];
	headicon.z = entity.entityheadiconoffset[ 2 ];
	headicon.alpha = 0,8;
	headicon setshader( icon, 6, 6 );
	headicon setwaypoint( constant_size );
	headicon settargetent( entity );
	entity.entityheadicons[ entity.entityheadicons.size ] = headicon;
}

updateentityheadclienticon( entity, icon, constant_size )
{
	headicon = newclienthudelem( self );
	headicon.archived = 1;
	headicon.x = entity.entityheadiconoffset[ 0 ];
	headicon.y = entity.entityheadiconoffset[ 1 ];
	headicon.z = entity.entityheadiconoffset[ 2 ];
	headicon.alpha = 0,8;
	headicon setshader( icon, 6, 6 );
	headicon setwaypoint( constant_size );
	headicon settargetent( entity );
	entity.entityheadicons[ entity.entityheadicons.size ] = headicon;
}

destroyheadiconsondeath()
{
	self waittill_any( "death", "hacked" );
	i = 0;
	while ( i < self.entityheadicons.size )
	{
		if ( isDefined( self.entityheadicons[ i ] ) )
		{
			self.entityheadicons[ i ] destroy();
		}
		i++;
	}
}

destroyentityheadicons()
{
	while ( isDefined( self.entityheadicons ) )
	{
		i = 0;
		while ( i < self.entityheadicons.size )
		{
			if ( isDefined( self.entityheadicons[ i ] ) )
			{
				self.entityheadicons[ i ] destroy();
			}
			i++;
		}
	}
}

updateentityheadiconpos( headicon )
{
	headicon.x = self.origin[ 0 ] + self.entityheadiconoffset[ 0 ];
	headicon.y = self.origin[ 1 ] + self.entityheadiconoffset[ 1 ];
	headicon.z = self.origin[ 2 ] + self.entityheadiconoffset[ 2 ];
}
