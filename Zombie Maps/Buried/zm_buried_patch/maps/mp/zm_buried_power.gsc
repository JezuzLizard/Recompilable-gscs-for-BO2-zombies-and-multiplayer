#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

electric_switch()
{
	trig = getent( "use_elec_switch", "targetname" );
	master_switch = getent( "elec_switch", "targetname" );
	master_switch notsolid();
	trig sethintstring( &"ZOMBIE_ELECTRIC_SWITCH" );
	trig setvisibletoall();
	trig waittill( "trigger", user );
	trig setinvisibletoall();
	master_switch rotateroll( -90, 0,3 );
	master_switch playsound( "zmb_switch_flip" );
	master_switch playsound( "zmb_poweron" );
	level delay_thread( 11,8, ::sndpoweronmusicstinger );
	if ( isDefined( user ) )
	{
		user thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "power", "power_on" );
	}
	level thread maps/mp/zombies/_zm_perks::perk_unpause_all_perks();
	master_switch waittill( "rotatedone" );
	playfx( level._effect[ "switch_sparks" ], master_switch.origin + ( 0, 12, -60 ), anglesToForward( master_switch.angles ) );
	master_switch playsound( "zmb_turn_on" );
	level notify( "electric_door" );
	clientnotify( "power_on" );
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
}

sndpoweronmusicstinger()
{
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "poweron" );
}
