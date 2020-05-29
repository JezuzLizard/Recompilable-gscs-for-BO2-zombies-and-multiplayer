
loadtreadfx( vehicle )
{
	treadfx = vehicle.treadfxnamearray;
	if ( isDefined( treadfx ) )
	{
		vehicle.treadfx = [];
		if ( isDefined( treadfx[ "asphalt" ] ) && treadfx[ "asphalt" ] != "" )
		{
			vehicle.treadfx[ "asphalt" ] = loadfx( treadfx[ "asphalt" ] );
		}
		if ( isDefined( treadfx[ "bark" ] ) && treadfx[ "bark" ] != "" )
		{
			vehicle.treadfx[ "bark" ] = loadfx( treadfx[ "bark" ] );
		}
		if ( isDefined( treadfx[ "brick" ] ) && treadfx[ "brick" ] != "" )
		{
			vehicle.treadfx[ "brick" ] = loadfx( treadfx[ "brick" ] );
		}
		if ( isDefined( treadfx[ "carpet" ] ) && treadfx[ "carpet" ] != "" )
		{
			vehicle.treadfx[ "carpet" ] = loadfx( treadfx[ "carpet" ] );
		}
		if ( isDefined( treadfx[ "ceramic" ] ) && treadfx[ "ceramic" ] != "" )
		{
			vehicle.treadfx[ "ceramic" ] = loadfx( treadfx[ "ceramic" ] );
		}
		if ( isDefined( treadfx[ "cloth" ] ) && treadfx[ "cloth" ] != "" )
		{
			vehicle.treadfx[ "cloth" ] = loadfx( treadfx[ "cloth" ] );
		}
		if ( isDefined( treadfx[ "concrete" ] ) && treadfx[ "concrete" ] != "" )
		{
			vehicle.treadfx[ "concrete" ] = loadfx( treadfx[ "concrete" ] );
		}
		if ( isDefined( treadfx[ "cushion" ] ) && treadfx[ "cushion" ] != "" )
		{
			vehicle.treadfx[ "cushion" ] = loadfx( treadfx[ "cushion" ] );
		}
		if ( isDefined( treadfx[ "none" ] ) && treadfx[ "none" ] != "" )
		{
			vehicle.treadfx[ "none" ] = loadfx( treadfx[ "none" ] );
		}
		if ( isDefined( treadfx[ "dirt" ] ) && treadfx[ "dirt" ] != "" )
		{
			vehicle.treadfx[ "dirt" ] = loadfx( treadfx[ "dirt" ] );
		}
		if ( isDefined( treadfx[ "flesh" ] ) && treadfx[ "flesh" ] != "" )
		{
			vehicle.treadfx[ "flesh" ] = loadfx( treadfx[ "flesh" ] );
		}
		if ( isDefined( treadfx[ "foliage" ] ) && treadfx[ "foliage" ] != "" )
		{
			vehicle.treadfx[ "foliage" ] = loadfx( treadfx[ "foliage" ] );
		}
		if ( isDefined( treadfx[ "fruit" ] ) && treadfx[ "fruit" ] != "" )
		{
			vehicle.treadfx[ "fruit" ] = loadfx( treadfx[ "fruit" ] );
		}
		if ( isDefined( treadfx[ "glass" ] ) && treadfx[ "glass" ] != "" )
		{
			vehicle.treadfx[ "glass" ] = loadfx( treadfx[ "glass" ] );
		}
		if ( isDefined( treadfx[ "grass" ] ) && treadfx[ "grass" ] != "" )
		{
			vehicle.treadfx[ "grass" ] = loadfx( treadfx[ "grass" ] );
		}
		if ( isDefined( treadfx[ "gravel" ] ) && treadfx[ "gravel" ] != "" )
		{
			vehicle.treadfx[ "gravel" ] = loadfx( treadfx[ "gravel" ] );
		}
		if ( isDefined( treadfx[ "metal" ] ) && treadfx[ "metal" ] != "" )
		{
			vehicle.treadfx[ "metal" ] = loadfx( treadfx[ "metal" ] );
		}
		if ( isDefined( treadfx[ "mud" ] ) && treadfx[ "mud" ] != "" )
		{
			vehicle.treadfx[ "mud" ] = loadfx( treadfx[ "mud" ] );
		}
		if ( isDefined( treadfx[ "paintedmetal" ] ) && treadfx[ "paintedmetal" ] != "" )
		{
			vehicle.treadfx[ "paintedmetal" ] = loadfx( treadfx[ "paintedmetal" ] );
		}
		if ( isDefined( treadfx[ "paper" ] ) && treadfx[ "paper" ] != "" )
		{
			vehicle.treadfx[ "paper" ] = loadfx( treadfx[ "paper" ] );
		}
		if ( isDefined( treadfx[ "plaster" ] ) && treadfx[ "plaster" ] != "" )
		{
			vehicle.treadfx[ "plaster" ] = loadfx( treadfx[ "plaster" ] );
		}
		if ( isDefined( treadfx[ "plastic" ] ) && treadfx[ "plastic" ] != "" )
		{
			vehicle.treadfx[ "plastic" ] = loadfx( treadfx[ "plastic" ] );
		}
		if ( isDefined( treadfx[ "rock" ] ) && treadfx[ "rock" ] != "" )
		{
			vehicle.treadfx[ "rock" ] = loadfx( treadfx[ "rock" ] );
		}
		if ( isDefined( treadfx[ "rubber" ] ) && treadfx[ "rubber" ] != "" )
		{
			vehicle.treadfx[ "rubber" ] = loadfx( treadfx[ "rubber" ] );
		}
		if ( isDefined( treadfx[ "sand" ] ) && treadfx[ "sand" ] != "" )
		{
			vehicle.treadfx[ "sand" ] = loadfx( treadfx[ "sand" ] );
		}
		if ( isDefined( treadfx[ "water" ] ) && treadfx[ "water" ] != "" )
		{
			vehicle.treadfx[ "water" ] = loadfx( treadfx[ "water" ] );
		}
		if ( isDefined( treadfx[ "wood" ] ) && treadfx[ "wood" ] != "" )
		{
			vehicle.treadfx[ "wood" ] = loadfx( treadfx[ "wood" ] );
		}
	}
}

preloadtreadfx( vehicle )
{
	treadfx = getvehicletreadfxarray( vehicle );
	i = 0;
	while ( i < treadfx.size )
	{
		loadfx( treadfx[ i ] );
		i++;
	}
}
