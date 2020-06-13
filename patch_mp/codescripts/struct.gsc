
initstructs() //checked matches cerberus output
{
	level.struct = [];
}

createstruct() //checked matches cerberus output
{
	struct = spawnstruct();
	level.struct[ level.struct.size ] = struct;
	return struct;
}

findstruct( position ) //checked changed to match cerberus output see info.md
{
	foreach ( _ in level.struct_class_names )
	{
		foreach ( s_array in level.struct_class_names[ key ] )
		{
			foreach ( struct in s_array )
			{
				if(distancesquared( struct.origin, position ) < 1 )
				{
					return struct;
				}
			}
		}
	}
}
