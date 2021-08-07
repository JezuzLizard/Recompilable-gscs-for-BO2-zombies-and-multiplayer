#include common_scripts/utility;

precache()
{
	precachemodel( "c_mul_mp_pmc_smg_fb" );
	precachemodel( "c_mul_mp_pmc_shortsleeve_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "team4" ][ "smg" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "axis" ][ "smg" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_mul_mp_pmc_smg_fb" );
	self setviewmodel( "c_mul_mp_pmc_shortsleeve_viewhands" );
	heads = [];
}
