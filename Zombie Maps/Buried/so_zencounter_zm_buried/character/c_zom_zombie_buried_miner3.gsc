#include codescripts/character;

main()
{
	self setmodel( "c_zom_zombie_buried_miner_body3" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_zom_zombie_buried_male_heads_als::main() );
	self attach( self.headmodel, "", 1 );
	self.hatmodel = "c_zom_zombie_buried_miner_hats2";
	self attach( self.hatmodel );
	self.voice = "american";
	self.skeleton = "base";
	self.torsodmg1 = "c_zom_zombie_buried_miner_g_upclean3";
	self.torsodmg2 = "c_zom_zombie_buried_miner_g_rarmoff3";
	self.torsodmg3 = "c_zom_zombie_buried_miner_g_larmoff3";
	self.legdmg1 = "c_zom_zombie_buried_miner_g_lowclean3";
	self.legdmg2 = "c_zom_zombie_buried_miner_g_rlegoff3";
	self.legdmg3 = "c_zom_zombie_buried_miner_g_llegoff3";
	self.legdmg4 = "c_zom_zombie_buried_miner_g_legsoff3";
	self.gibspawn1 = "c_zom_buried_g_rarmspawn";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_zom_buried_g_larmspawn";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_zom_buried_g_rlegspawn";
	self.gibspawntag3 = "J_knee_RI";
	self.gibspawn4 = "c_zom_buried_g_llegspawn";
	self.gibspawntag4 = "J_knee_LE";
	self.gibspawn5 = "c_zom_zombie_buried_miner_hats2";
	self.gibspawntag5 = "J_Head";
}

precache()
{
	precachemodel( "c_zom_zombie_buried_miner_body3" );
	codescripts/character::precachemodelarray( xmodelalias/c_zom_zombie_buried_male_heads_als::main() );
	precachemodel( "c_zom_zombie_buried_miner_hats2" );
	precachemodel( "c_zom_zombie_buried_miner_g_upclean3" );
	precachemodel( "c_zom_zombie_buried_miner_g_rarmoff3" );
	precachemodel( "c_zom_zombie_buried_miner_g_larmoff3" );
	precachemodel( "c_zom_zombie_buried_miner_g_lowclean3" );
	precachemodel( "c_zom_zombie_buried_miner_g_rlegoff3" );
	precachemodel( "c_zom_zombie_buried_miner_g_llegoff3" );
	precachemodel( "c_zom_zombie_buried_miner_g_legsoff3" );
	precachemodel( "c_zom_buried_g_rarmspawn" );
	precachemodel( "c_zom_buried_g_larmspawn" );
	precachemodel( "c_zom_buried_g_rlegspawn" );
	precachemodel( "c_zom_buried_g_llegspawn" );
	precachemodel( "c_zom_zombie_buried_miner_hats2" );
}
