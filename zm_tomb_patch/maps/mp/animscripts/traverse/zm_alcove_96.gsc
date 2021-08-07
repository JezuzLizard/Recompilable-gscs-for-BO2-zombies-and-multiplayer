#include maps/mp/animscripts/traverse/zm_shared;
#include maps/mp/animscripts/traverse/shared;

main()
{
	self thread alcove_traverse_fx( "rise_billow" );
	dosimpletraverse( "alcove_96" );
}

alcove_traverse_fx( str_fx )
{
	self endon( "death" );
	wait 0,15;
	v_facing = anglesToForward( self.angles );
	v_offset = v_facing * 32;
	playfx( level._effect[ str_fx ], self.origin + v_offset );
	self playsound( "zmb_spawn_tomb" );
}
