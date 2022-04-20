
initstructs()
{
	level.struct = [];
}

createstruct()
{
	struct = spawnstruct();
	level.struct[ level.struct.size ] = struct;
	return struct;
}

findstruct( position )
{
	_a20 = level.struct_class_names;
	key = getFirstArrayKey( _a20 );
	while ( isDefined( key ) )
	{
		_ = _a20[ key ];
		_a22 = level.struct_class_names[ key ];
		val = getFirstArrayKey( _a22 );
		while ( isDefined( val ) )
		{
			s_array = _a22[ val ];
			_a24 = s_array;
			_k24 = getFirstArrayKey( _a24 );
			while ( isDefined( _k24 ) )
			{
				struct = _a24[ _k24 ];
				if ( distancesquared( struct.origin, position ) < 1 )
				{
					return struct;
				}
				_k24 = getNextArrayKey( _a24, _k24 );
			}
			val = getNextArrayKey( _a22, val );
		}
		key = getNextArrayKey( _a20, key );
	}
}
