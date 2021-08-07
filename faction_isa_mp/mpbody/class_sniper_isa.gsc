#include common_scripts/utility;

precache()
{
	precachemodel( "c_usa_mp_isa_sniper_fb" );
	precachemodel( "c_usa_mp_isa_sniper_viewhands" );
	if ( level.multiteam )
	{
		game[ "set_player_model" ][ "team5" ][ "rifle" ] = ::set_player_model;
	}
	else
	{
		game[ "set_player_model" ][ "allies" ][ "rifle" ] = ::set_player_model;
	}
}

set_player_model()
{
	self setmodel( "c_usa_mp_isa_sniper_fb" );
	self setviewmodel( "c_usa_mp_isa_sniper_viewhands" );
	heads = [];
}
