
main()
{
	self setmodel( "c_zom_dlc0_zom_haz_body2" );
	self.headmodel = "c_zom_dlc0_zom_haz_head_mask";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
	self.torsodmg1 = "c_zom_dlc0_zom_haz_body2_upclean";
	self.torsodmg2 = "c_zom_dlc0_zom_haz_body2_rarmoff";
	self.torsodmg3 = "c_zom_dlc0_zom_haz_body2_larmoff";
	self.torsodmg5 = "c_zom_dlc0_zom_haz_body2_behead";
	self.legdmg1 = "c_zom_dlc0_zom_haz_body2_lowclean";
	self.legdmg2 = "c_zom_dlc0_zom_haz_body2_rlegoff";
	self.legdmg3 = "c_zom_dlc0_zom_haz_body2_llegoff";
	self.legdmg4 = "c_zom_dlc0_zom_haz_body2_legsoff";
	self.gibspawn1 = "c_zom_dlc0_zom_haz_body2_g_rarmspawn";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_zom_dlc0_zom_haz_body2_g_larmspawn";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_zom_dlc0_zom_haz_body2_g_rlegspawn";
	self.gibspawntag3 = "J_Knee_RI";
	self.gibspawn4 = "c_zom_dlc0_zom_haz_body2_g_llegspawn";
	self.gibspawntag4 = "J_Knee_LE";
}

precache()
{
	precachemodel( "c_zom_dlc0_zom_haz_body2" );
	precachemodel( "c_zom_dlc0_zom_haz_head_mask" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_upclean" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_rarmoff" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_larmoff" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_behead" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_lowclean" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_rlegoff" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_llegoff" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_legsoff" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_g_rarmspawn" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_g_larmspawn" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_g_rlegspawn" );
	precachemodel( "c_zom_dlc0_zom_haz_body2_g_llegspawn" );
}
