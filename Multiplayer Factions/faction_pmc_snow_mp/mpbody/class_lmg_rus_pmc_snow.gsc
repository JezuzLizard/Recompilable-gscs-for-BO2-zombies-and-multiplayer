#include common_scripts/utility;

precache()
{
	precachemodel( "c_mul_mp_pmc_lmg_snw_fb" );
	precachemodel( "c_mul_mp_pmc_longsleeve_snw_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "team4" ][ "mg" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "axis" ][ "mg" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_mul_mp_pmc_lmg_snw_fb" );
	self setviewmodel( "c_mul_mp_pmc_longsleeve_snw_viewhands" );
	heads = [];
}
