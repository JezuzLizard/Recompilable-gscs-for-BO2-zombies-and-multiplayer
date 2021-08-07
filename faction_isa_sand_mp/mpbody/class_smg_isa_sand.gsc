#include common_scripts/utility;

precache()
{
	precachemodel( "c_usa_mp_isa_smg_ca_fb" );
	precachemodel( "c_usa_mp_isa_smg_ca_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "team5" ][ "smg" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "allies" ][ "smg" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_usa_mp_isa_smg_ca_fb" );
	self setviewmodel( "c_usa_mp_isa_smg_ca_viewhands" );
	heads = [];
}
