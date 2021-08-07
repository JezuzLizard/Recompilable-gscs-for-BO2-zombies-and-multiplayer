
main()
{
	self setmodel( "c_zom_cellbreaker_fb" );
	self.hatmodel = "c_zom_cellbreaker_helmet";
	self attach( self.hatmodel );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_zom_cellbreaker_fb" );
	precachemodel( "c_zom_cellbreaker_helmet" );
}
