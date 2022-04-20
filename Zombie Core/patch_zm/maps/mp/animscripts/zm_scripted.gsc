
main()
{
	self endon( "death" );
	self notify( "killanimscript" );
	self endon( "end_sequence" );
	if ( !isDefined( self.codescripted[ "animState" ] ) )
	{
		return;
	}
	self startscriptedanim( self.codescripted[ "origin" ], self.codescripted[ "angles" ], self.codescripted[ "animState" ], self.codescripted[ "animSubState" ], self.codescripted[ "AnimMode" ] );
	self.a.script = "scripted";
	self.codescripted = undefined;
	if ( isDefined( self.deathstring_passed ) )
	{
		self.deathstring = self.deathstring_passed;
	}
	self waittill( "killanimscript" );
}

init( origin, angles, animstate, animsubstate, animmode )
{
	self.codescripted[ "origin" ] = origin;
	self.codescripted[ "angles" ] = angles;
	self.codescripted[ "animState" ] = animstate;
	self.codescripted[ "animSubState" ] = animsubstate;
	if ( isDefined( animmode ) )
	{
		self.codescripted[ "AnimMode" ] = animmode;
	}
	else
	{
		self.codescripted[ "AnimMode" ] = "normal";
	}
}

end_script()
{
}
