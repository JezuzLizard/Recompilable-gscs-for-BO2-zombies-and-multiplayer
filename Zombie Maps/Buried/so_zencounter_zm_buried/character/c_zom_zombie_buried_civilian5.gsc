#include codescripts/character;

main()
{
	self setmodel( "c_zom_zombie_buried_civilian_body5" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_zom_zombie_buried_male_heads_als::main() );
	self attach( self.headmodel, "", 1 );
	self.hatmodel = "c_zom_zombie_buried_civilian_hats2";
	self attach( self.hatmodel );
	self.voice = "american";
	self.skeleton = "base";
	self.torsodmg1 = "c_zom_zombie_buried_civilian_g_upclean5";
	self.torsodmg2 = "c_zom_zombie_buried_civilian_g_rarmoff5";
	self.torsodmg3 = "c_zom_zombie_buried_civilian_g_larmoff5";
	self.torsodmg5 = "c_zom_zombie_buried_civilian_g_behead";
	self.legdmg1 = "c_zom_zombie_buried_civilian_g_lowclean5";
	self.legdmg2 = "c_zom_zombie_buried_civilian_g_rlegoff5";
	self.legdmg3 = "c_zom_zombie_buried_civilian_g_llegoff5";
	self.legdmg4 = "c_zom_zombie_buried_civilian_g_legsoff5";
	self.gibspawn1 = "c_zom_buried_g_rarmspawn";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_zom_buried_g_larmspawn";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_zom_buried_g_rlegspawn";
	self.gibspawntag3 = "J_Knee_RI";
	self.gibspawn4 = "c_zom_buried_g_llegspawn";
	self.gibspawntag4 = "J_Knee_LE";
	self.gibspawn5 = "c_zom_zombie_buried_civilian_hats2";
	self.gibspawntag5 = "J_Head";
}

precache()
{
	precachemodel( "c_zom_zombie_buried_civilian_body5" );
	codescripts/character::precachemodelarray( xmodelalias/c_zom_zombie_buried_male_heads_als::main() );
	precachemodel( "c_zom_zombie_buried_civilian_hats2" );
	precachemodel( "c_zom_zombie_buried_civilian_g_upclean5" );
	precachemodel( "c_zom_zombie_buried_civilian_g_rarmoff5" );
	precachemodel( "c_zom_zombie_buried_civilian_g_larmoff5" );
	precachemodel( "c_zom_zombie_buried_civilian_g_behead" );
	precachemodel( "c_zom_zombie_buried_civilian_g_lowclean5" );
	precachemodel( "c_zom_zombie_buried_civilian_g_rlegoff5" );
	precachemodel( "c_zom_zombie_buried_civilian_g_llegoff5" );
	precachemodel( "c_zom_zombie_buried_civilian_g_legsoff5" );
	precachemodel( "c_zom_buried_g_rarmspawn" );
	precachemodel( "c_zom_buried_g_larmspawn" );
	precachemodel( "c_zom_buried_g_rlegspawn" );
	precachemodel( "c_zom_buried_g_llegspawn" );
	precachemodel( "c_zom_zombie_buried_civilian_hats2" );
}
