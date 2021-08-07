#include common_scripts/utility;

precache()
{
	precachemodel( "c_usa_mp_seal6_shotgun_w_fb" );
	precachemodel( "c_usa_mp_seal6_shortsleeve_w_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "allies" ][ "spread" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "allies" ][ "spread" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_usa_mp_seal6_shotgun_w_fb" );
	self setviewmodel( "c_usa_mp_seal6_shortsleeve_w_viewhands" );
	heads = [];
}
