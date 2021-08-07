#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread init_serverfaceanim();
	}
}

init_serverfaceanim()
{
	self.do_face_anims = 1;
	if ( !isDefined( level.face_event_handler ) )
	{
		level.face_event_handler = spawnstruct();
		level.face_event_handler.events = [];
		level.face_event_handler.events[ "death" ] = "face_death";
		level.face_event_handler.events[ "grenade danger" ] = "face_alert";
		level.face_event_handler.events[ "bulletwhizby" ] = "face_alert";
		level.face_event_handler.events[ "projectile_impact" ] = "face_alert";
		level.face_event_handler.events[ "explode" ] = "face_alert";
		level.face_event_handler.events[ "alert" ] = "face_alert";
		level.face_event_handler.events[ "shoot" ] = "face_shoot_single";
		level.face_event_handler.events[ "melee" ] = "face_melee";
		level.face_event_handler.events[ "damage" ] = "face_pain";
		level thread wait_for_face_event();
	}
}

wait_for_face_event()
{
	while ( 1 )
	{
		level waittill( "face", face_notify, ent );
		if ( isDefined( ent ) && isDefined( ent.do_face_anims ) && ent.do_face_anims )
		{
			if ( isDefined( level.face_event_handler.events[ face_notify ] ) )
			{
				ent sendfaceevent( level.face_event_handler.events[ face_notify ] );
			}
		}
	}
}
