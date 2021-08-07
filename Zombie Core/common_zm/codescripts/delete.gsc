
main()
{
/#
	assert( isDefined( self ) );
#/
	wait 0;
	if ( isDefined( self ) )
	{
/#
		if ( isDefined( self.classname ) )
		{
			if ( self.classname != "trigger_once" || self.classname == "trigger_radius" && self.classname == "trigger_multiple" )
			{
				println( "" );
				println( "*** trigger debug: delete.gsc is deleting trigger with ent#: " + self getentitynumber() + " at origin: " + self.origin );
				println( "" );
#/
			}
		}
		self delete();
	}
}
