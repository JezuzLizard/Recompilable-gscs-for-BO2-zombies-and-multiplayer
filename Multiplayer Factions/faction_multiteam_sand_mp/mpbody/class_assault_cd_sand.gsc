#include common_scripts/utility;

precache()
{
	precachemodel( "c_mul_mp_cordis_assault_ca_fb" );
	precachemodel( "c_mul_mp_cordis_assault_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "team6" ][ "default" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "axis" ][ "default" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_mul_mp_cordis_assault_ca_fb" );
	self setviewmodel( "c_mul_mp_cordis_assault_viewhands" );
	heads = [];
}
