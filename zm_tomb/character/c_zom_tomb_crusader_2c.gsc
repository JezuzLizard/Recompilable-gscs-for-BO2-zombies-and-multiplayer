#include codescripts/character;

main()
{
	self setmodel( "c_zom_tomb_crusader_body_2c" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_zom_tomb_crusader_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.hatmodel = "c_zom_tomb_crusader_hat_2";
	self attach( self.hatmodel );
	self.voice = "american";
	self.skeleton = "base";
	self.torsodmg1 = "c_zom_tomb_crusader_body_g_upclean_2c";
	self.torsodmg2 = "c_zom_tomb_crusader_body_g_rarm_2c";
	self.torsodmg3 = "c_zom_tomb_crusader_body_g_larm_2c";
	self.torsodmg5 = "c_zom_tomb_german_body_g_behead";
	self.legdmg1 = "c_zom_tomb_crusader_body_g_lowclean_2c";
	self.legdmg2 = "c_zom_tomb_crusader_body_g_rleg_2c";
	self.legdmg3 = "c_zom_tomb_crusader_body_g_lleg_2c";
	self.legdmg4 = "c_zom_tomb_crusader_body_g_legsoff_2c";
	self.gibspawn1 = "c_zom_buried_g_rarmspawn";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_zom_buried_g_larmspawn";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_zom_buried_g_rlegspawn";
	self.gibspawntag3 = "J_Knee_RI";
	self.gibspawn4 = "c_zom_buried_g_llegspawn";
	self.gibspawntag4 = "J_Knee_LE";
	self.gibspawn5 = "c_zom_tomb_crusader_hat_1";
	self.gibspawntag5 = "J_Head";
}

precache()
{
	precachemodel( "c_zom_tomb_crusader_body_2c" );
	codescripts/character::precachemodelarray( xmodelalias/c_zom_tomb_crusader_head_als::main() );
	precachemodel( "c_zom_tomb_crusader_hat_2" );
	precachemodel( "c_zom_tomb_crusader_body_g_upclean_2c" );
	precachemodel( "c_zom_tomb_crusader_body_g_rarm_2c" );
	precachemodel( "c_zom_tomb_crusader_body_g_larm_2c" );
	precachemodel( "c_zom_tomb_german_body_g_behead" );
	precachemodel( "c_zom_tomb_crusader_body_g_lowclean_2c" );
	precachemodel( "c_zom_tomb_crusader_body_g_rleg_2c" );
	precachemodel( "c_zom_tomb_crusader_body_g_lleg_2c" );
	precachemodel( "c_zom_tomb_crusader_body_g_legsoff_2c" );
	precachemodel( "c_zom_buried_g_rarmspawn" );
	precachemodel( "c_zom_buried_g_larmspawn" );
	precachemodel( "c_zom_buried_g_rlegspawn" );
	precachemodel( "c_zom_buried_g_llegspawn" );
	precachemodel( "c_zom_tomb_crusader_hat_1" );
}
