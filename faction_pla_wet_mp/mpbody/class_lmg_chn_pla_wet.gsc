#include common_scripts/utility;

precache()
{
	precachemodel( "c_chn_mp_pla_lmg_w_fb" );
	precachemodel( "c_chn_mp_pla_armorsleeve_w_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "axis" ][ "mg" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "axis" ][ "mg" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_chn_mp_pla_lmg_w_fb" );
	self setviewmodel( "c_chn_mp_pla_armorsleeve_w_viewhands" );
	heads = [];
}
