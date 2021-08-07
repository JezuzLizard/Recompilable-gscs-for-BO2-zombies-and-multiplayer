
main()
{
	destructibles = getentarray( "destructible", "targetname" );
	_a5 = destructibles;
	_k5 = getFirstArrayKey( _a5 );
	while ( isDefined( _k5 ) )
	{
		dest = _a5[ _k5 ];
		if ( dest.destructibledef == "veh_t6_dlc_electric_cart_destructible" )
		{
			dest thread cart_fire_think();
			dest thread cart_death_think();
		}
		_k5 = getNextArrayKey( _a5, _k5 );
	}
}

cart_fire_think()
{
	self endon( "car_dead" );
	for ( ;; )
	{
		self waittill( "broken", event );
		if ( event == "destructible_car_fire" )
		{
			self playloopsound( "amb_fire_med" );
			return;
		}
	}
}

cart_death_think()
{
	self waittill( "car_dead" );
	self playsound( "exp_barrel" );
}
