#include codescripts/character;

main()
{
	self setmodel( "c_zom_zombie_buried_sgirl_body1" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_zom_zombie_buried_female_heads_als::main() );
	self attach( self.headmodel, "", 1 );
	self.hatmodel = codescripts/character::randomelement( xmodelalias/c_zom_zombie_buried_sgirl_hair_als::main() );
	self attach( self.hatmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
	self.torsodmg1 = "c_zom_zombie_buried_sgirl_g_upclean";
	self.torsodmg2 = "c_zom_zombie_buried_sgirl_g_rarmoff";
	self.torsodmg3 = "c_zom_zombie_buried_sgirl_g_larmoff";
	self.torsodmg5 = "c_zom_zombie_buried_sgirl_g_behead";
	self.legdmg1 = "c_zom_zombie_buried_sgirl_g_lowclean";
	self.legdmg2 = "c_zom_zombie_buried_sgirl_g_rlegoff";
	self.legdmg3 = "c_zom_zombie_buried_sgirl_g_llegoff";
	self.legdmg4 = "c_zom_zombie_buried_sgirl_g_legsoff";
	self.gibspawn1 = "c_zom_buried_g_rarmspawn";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_zom_buried_g_larmspawn";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_zom_buried_g_rlegspawn";
	self.gibspawntag3 = "J_Knee_RI";
	self.gibspawn4 = "c_zom_buried_g_llegspawn";
	self.gibspawntag4 = "J_Knee_LE";
}

precache()
{
	precachemodel( "c_zom_zombie_buried_sgirl_body1" );
	codescripts/character::precachemodelarray( xmodelalias/c_zom_zombie_buried_female_heads_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_zom_zombie_buried_sgirl_hair_als::main() );
	precachemodel( "c_zom_zombie_buried_sgirl_g_upclean" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_rarmoff" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_larmoff" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_behead" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_lowclean" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_rlegoff" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_llegoff" );
	precachemodel( "c_zom_zombie_buried_sgirl_g_legsoff" );
	precachemodel( "c_zom_buried_g_rarmspawn" );
	precachemodel( "c_zom_buried_g_larmspawn" );
	precachemodel( "c_zom_buried_g_rlegspawn" );
	precachemodel( "c_zom_buried_g_llegspawn" );
}
