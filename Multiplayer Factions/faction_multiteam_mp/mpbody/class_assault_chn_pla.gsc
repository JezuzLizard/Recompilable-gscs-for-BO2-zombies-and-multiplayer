#include common_scripts/utility;

precache()
{
	precachemodel( "c_chn_mp_pla_assault_fb" );
	precachemodel( "c_chn_mp_pla_longsleeve_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "axis" ][ "default" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "axis" ][ "default" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_chn_mp_pla_assault_fb" );
	self setviewmodel( "c_chn_mp_pla_longsleeve_viewhands" );
	heads = [];
}
