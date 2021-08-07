#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

onplayerconnect_sq_wth()
{
	if ( !isDefined( level.wth_lookat_point ) )
	{
		level.wth_lookat_point = getstruct( "struct_gg_look", "targetname" );
	}
	self thread track_player_eyes();
	self thread play_scary_lightning();
}

track_player_eyes()
{
	self endon( "disconnect" );
	b_saw_the_wth = 0;
	while ( !b_saw_the_wth )
	{
		n_time = 0;
		while ( self adsbuttonpressed() && n_time < 25 )
		{
			n_time++;
			wait 0,05;
		}
		if ( n_time >= 25 && self adsbuttonpressed() && self maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_roof" ) && sq_is_weapon_sniper( self getcurrentweapon() ) && is_player_looking_at( level.wth_lookat_point.origin, 0,9, 0, undefined ) )
		{
			self do_player_general_vox( "general", "scare_react", undefined, 100 );
			self playsoundtoplayer( "zmb_easteregg_face", self );
			self.wth_elem = newclienthudelem( self );
			self.wth_elem.horzalign = "fullscreen";
			self.wth_elem.vertalign = "fullscreen";
			self.wth_elem.sort = 1000;
			self.wth_elem.foreground = 0;
			self.wth_elem setshader( "zm_al_wth_zombie", 640, 480 );
			self.wth_elem.hidewheninmenu = 1;
			j_time = 0;
			while ( self adsbuttonpressed() && j_time < 5 )
			{
				j_time++;
				wait 0,05;
			}
			self.wth_elem destroy();
			b_saw_the_wth = 1;
		}
		wait 0,05;
	}
}

sq_is_weapon_sniper( str_weapon )
{
	a_snipers = array( "dsr50", "barretm82" );
	_a77 = a_snipers;
	_k77 = getFirstArrayKey( _a77 );
	while ( isDefined( _k77 ) )
	{
		str_sniper = _a77[ _k77 ];
		if ( issubstr( str_weapon, str_sniper ) && !issubstr( str_weapon, "+is" ) )
		{
			return 1;
		}
		_k77 = getNextArrayKey( _a77, _k77 );
	}
	return 0;
}

play_scary_lightning()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		while ( self maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_golden_gate_bridge" ) && isDefined( self.b_lightning ) || !self.b_lightning && flag( "plane_zapped" ) )
		{
			wait 0,25;
		}
		if ( randomint( 100000 ) == 1337 )
		{
			self.scary_lighting = 1;
			level setclientfield( "scripted_lightning_flash", 1 );
			wait_network_frame();
			self.sl_elem = newclienthudelem( self );
			self.sl_elem.horzalign = "fullscreen";
			self.sl_elem.vertalign = "fullscreen";
			self.sl_elem.sort = 1000;
			self.sl_elem.foreground = 0;
			self.sl_elem.alpha = 0,6;
			self.sl_elem setshader( "zm_al_wth_zombie", 640, 480 );
			self.sl_elem.hidewheninmenu = 1;
			self.sl_elem.alpha = 0;
			self.sl_elem fadeovertime( 0,1 );
			wait_network_frame();
			self.sl_elem.alpha = 0,6;
			self.sl_elem fadeovertime( 0,1 );
			wait_network_frame();
			self.sl_elem.alpha = 0;
			self.sl_elem fadeovertime( 0,1 );
			wait_network_frame();
			self.sl_elem destroy();
			self.scary_lightning = 0;
			wait 10;
			level setclientfield( "scripted_lightning_flash", 0 );
		}
		wait 1;
	}
}
