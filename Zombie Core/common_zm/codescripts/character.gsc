
setmodelfromarray( a )
{
	self setmodel( a[ randomint( a.size ) ] );
}

precachemodelarray( a )
{
	i = 0;
	while ( i < a.size )
	{
		precachemodel( a[ i ] );
		i++;
	}
}

randomelement( a )
{
	return a[ randomint( a.size ) ];
}

attachfromarray( a )
{
	self attach( randomelement( a ), "", 1 );
}

new()
{
	self detachall();
	oldgunhand = self.anim_gunhand;
	if ( !isDefined( oldgunhand ) )
	{
		return;
	}
	self.anim_gunhand = "none";
	self [[ anim.putguninhand ]]( oldgunhand );
}

save()
{
	info[ "gunHand" ] = self.anim_gunhand;
	info[ "gunInHand" ] = self.anim_guninhand;
	info[ "model" ] = self.model;
	info[ "hatModel" ] = self.hatmodel;
	info[ "gearModel" ] = self.gearmodel;
	if ( isDefined( self.name ) )
	{
		info[ "name" ] = self.name;
/#
		println( "Save: Guy has name ", self.name );
#/
	}
	else
	{
/#
		println( "save: Guy had no name!" );
#/
	}
	attachsize = self getattachsize();
	i = 0;
	while ( i < attachsize )
	{
		info[ "attach" ][ i ][ "model" ] = self getattachmodelname( i );
		info[ "attach" ][ i ][ "tag" ] = self getattachtagname( i );
		i++;
	}
	return info;
}

load( info )
{
	self detachall();
	self.anim_gunhand = info[ "gunHand" ];
	self.anim_guninhand = info[ "gunInHand" ];
	self setmodel( info[ "model" ] );
	self.hatmodel = info[ "hatModel" ];
	self.gearmodel = info[ "gearModel" ];
	if ( isDefined( info[ "name" ] ) )
	{
		self.name = info[ "name" ];
/#
		println( "Load: Guy has name ", self.name );
#/
	}
	else
	{
/#
		println( "Load: Guy had no name!" );
#/
	}
	attachinfo = info[ "attach" ];
	attachsize = attachinfo.size;
	i = 0;
	while ( i < attachsize )
	{
		self attach( attachinfo[ i ][ "model" ], attachinfo[ i ][ "tag" ] );
		i++;
	}
}

precache( info )
{
	if ( isDefined( info[ "name" ] ) )
	{
/#
		println( "Precache: Guy has name ", info[ "name" ] );
#/
	}
	else
	{
/#
		println( "Precache: Guy had no name!" );
#/
	}
	precachemodel( info[ "model" ] );
	attachinfo = info[ "attach" ];
	attachsize = attachinfo.size;
	i = 0;
	while ( i < attachsize )
	{
		precachemodel( attachinfo[ i ][ "model" ] );
		i++;
	}
}

get_random_character( amount )
{
	self_info = strtok( self.classname, "_" );
	if ( self_info.size <= 2 )
	{
		return randomint( amount );
	}
	group = "auto";
	index = undefined;
	prefix = self_info[ 2 ];
	if ( isDefined( self.script_char_index ) )
	{
		index = self.script_char_index;
	}
	if ( isDefined( self.script_char_group ) )
	{
		type = "grouped";
		group = "group_" + self.script_char_group;
	}
	if ( !isDefined( level.character_index_cache ) )
	{
		level.character_index_cache = [];
	}
	if ( !isDefined( level.character_index_cache[ prefix ] ) )
	{
		level.character_index_cache[ prefix ] = [];
	}
	if ( !isDefined( level.character_index_cache[ prefix ][ group ] ) )
	{
		initialize_character_group( prefix, group, amount );
	}
	if ( !isDefined( index ) )
	{
		index = get_least_used_index( prefix, group );
		if ( !isDefined( index ) )
		{
			index = randomint( 5000 );
		}
	}
	while ( index >= amount )
	{
		index -= amount;
	}
	level.character_index_cache[ prefix ][ group ][ index ]++;
	return index;
}

get_least_used_index( prefix, group )
{
	lowest_indices = [];
	lowest_use = level.character_index_cache[ prefix ][ group ][ 0 ];
	lowest_indices[ 0 ] = 0;
	i = 1;
	while ( i < level.character_index_cache[ prefix ][ group ].size )
	{
		if ( level.character_index_cache[ prefix ][ group ][ i ] > lowest_use )
		{
			i++;
			continue;
		}
		else
		{
			if ( level.character_index_cache[ prefix ][ group ][ i ] < lowest_use )
			{
				lowest_indices = [];
				lowest_use = level.character_index_cache[ prefix ][ group ][ i ];
			}
			lowest_indices[ lowest_indices.size ] = i;
		}
		i++;
	}
/#
	assert( lowest_indices.size, "Tried to spawn a character but the lowest indices didn't exist" );
#/
	return random( lowest_indices );
}

initialize_character_group( prefix, group, amount )
{
	i = 0;
	while ( i < amount )
	{
		level.character_index_cache[ prefix ][ group ][ i ] = 0;
		i++;
	}
}

random( array )
{
	return array[ randomint( array.size ) ];
}
