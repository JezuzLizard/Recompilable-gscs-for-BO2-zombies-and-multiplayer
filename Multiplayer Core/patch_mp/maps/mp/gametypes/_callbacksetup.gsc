#include maps/mp/gametypes/_hostmigration;
#include maps/mp/gametypes/_globallogic_vehicle;
#include maps/mp/gametypes/_globallogic_actor;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/_audio;
#include maps/mp/_utility;
#include common_scripts/utility;

codecallback_startgametype() //checked matches cerberus output
{
	if ( !isDefined( level.gametypestarted ) || !level.gametypestarted )
	{
		[[ level.callbackstartgametype ]]();
		level.gametypestarted = 1;
	}
}

codecallback_finalizeinitialization() //checked matches cerberus output
{
	maps/mp/_utility::callback( "on_finalize_initialization" );
}

codecallback_playerconnect() //checked matches cerberus output
{
	self endon( "disconnect" );
	self thread maps/mp/_audio::monitor_player_sprint();
	[[ level.callbackplayerconnect ]]();
}

codecallback_playerdisconnect() //checked matches cerberus output
{
	self notify( "disconnect" );
	level notify( "disconnect" );
	client_num = self getentitynumber();
	[[ level.callbackplayerdisconnect ]]();
}

codecallback_hostmigration() //checked matches cerberus output
{
	/*
/#
	println( "****CodeCallback_HostMigration****" );
#/
	*/
	[[ level.callbackhostmigration ]]();
}

codecallback_hostmigrationsave() //checked matches cerberus output
{
	/*
/#
	println( "****CodeCallback_HostMigrationSave****" );
#/
	*/
	[[ level.callbackhostmigrationsave ]]();
}

codecallback_playermigrated() //checked matches cerberus output
{
	/*
/#
	println( "****CodeCallback_PlayerMigrated****" );
#/
	*/
	[[ level.callbackplayermigrated ]]();
}

codecallback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex ) //checked matches cerberus output
{
	self endon( "disconnect" );
	[[ level.callbackplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex );
}

codecallback_playerkilled( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration ) //checked matches cerberus output
{
	self endon( "disconnect" );
	[[ level.callbackplayerkilled ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration );
}

codecallback_playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration ) //checked matches cerberus output
{
	self endon( "disconnect" );
	[[ level.callbackplayerlaststand ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration );
}

codecallback_playermelee( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit ) //checked matches cerberus output
{
	self endon( "disconnect" );
	[[ level.callbackplayermelee ]]( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit );
}

codecallback_actordamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex ) //checked matches cerberus output
{
	[[ level.callbackactordamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex );
}

codecallback_actorkilled( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset ) //checked matches cerberus output
{
	[[ level.callbackactorkilled ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset );
}

codecallback_vehicledamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, damagefromunderneath, modelindex, partname ) //checked matches cerberus output
{
	[[ level.callbackvehicledamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, damagefromunderneath, modelindex, partname );
}

codecallback_vehicleradiusdamage( einflictor, eattacker, idamage, finnerdamage, fouterdamage, idflags, smeansofdeath, sweapon, vpoint, fradius, fconeanglecos, vconedir, timeoffset ) //checked matches cerberus output
{
	[[ level.callbackvehicleradiusdamage ]]( einflictor, eattacker, idamage, finnerdamage, fouterdamage, idflags, smeansofdeath, sweapon, vpoint, fradius, fconeanglecos, vconedir, timeoffset );
}

codecallback_faceeventnotify( notify_msg, ent ) //checked matches cerberus output 
{
	if ( isDefined( ent ) && is_true( ent.do_face_anims ) )
	{
		if ( isDefined( level.face_event_handler ) && isDefined( level.face_event_handler.events[ notify_msg ] ) )
		{
			ent sendfaceevent( level.face_event_handler.events[ notify_msg ] );
		}
	}
}

codecallback_menuresponse( action, arg ) //checked matches cerberus output
{
	if ( !isDefined( level.menuresponsequeue ) )
	{
		level.menuresponsequeue = [];
		level thread menuresponsequeuepump();
	}
	index = level.menuresponsequeue.size;
	level.menuresponsequeue[ index ] = spawnstruct();
	level.menuresponsequeue[ index ].action = action;
	level.menuresponsequeue[ index ].arg = arg;
	level.menuresponsequeue[ index ].ent = self;
	level notify( "menuresponse_queue" );
}

menuresponsequeuepump() //checked changed to match cerberus output
{
	while ( 1 )
	{
		level waittill( "menuresponse_queue" );
		level.menuresponsequeue[ 0 ].ent notify( "menuresponse", level.menuresponsequeue[0].action, level.menuresponsequeue[0].arg );
		arrayremoveindex( level.menuresponsequeue, 0, 0 );
		wait 0.05;
	}
}

setupcallbacks() //checked matches cerberus output
{
	setdefaultcallbacks();
	level.idflags_radius = 1;
	level.idflags_no_armor = 2;
	level.idflags_no_knockback = 4;
	level.idflags_penetration = 8;
	level.idflags_destructible_entity = 16;
	level.idflags_shield_explosive_impact = 32;
	level.idflags_shield_explosive_impact_huge = 64;
	level.idflags_shield_explosive_splash = 128;
	level.idflags_no_team_protection = 256;
	level.idflags_no_protection = 512;
	level.idflags_passthru = 1024;
}

setdefaultcallbacks() //checked matches cerberus output 
{
	level.callbackstartgametype = maps/mp/gametypes/_globallogic::callback_startgametype;
	level.callbackplayerconnect = maps/mp/gametypes/_globallogic_player::callback_playerconnect;
	level.callbackplayerdisconnect = maps/mp/gametypes/_globallogic_player::callback_playerdisconnect;
	level.callbackplayerdamage = maps/mp/gametypes/_globallogic_player::callback_playerdamage;
	level.callbackplayerkilled = maps/mp/gametypes/_globallogic_player::callback_playerkilled;
	level.callbackplayermelee = maps/mp/gametypes/_globallogic_player::callback_playermelee;
	level.callbackplayerlaststand = maps/mp/gametypes/_globallogic_player::callback_playerlaststand;
	level.callbackactordamage = maps/mp/gametypes/_globallogic_actor::callback_actordamage;
	level.callbackactorkilled = maps/mp/gametypes/_globallogic_actor::callback_actorkilled;
	level.callbackvehicledamage = maps/mp/gametypes/_globallogic_vehicle::callback_vehicledamage;
	level.callbackvehicleradiusdamage = maps/mp/gametypes/_globallogic_vehicle::callback_vehicleradiusdamage;
	level.callbackplayermigrated = maps/mp/gametypes/_globallogic_player::callback_playermigrated;
	level.callbackhostmigration = maps/mp/gametypes/_hostmigration::callback_hostmigration;
	level.callbackhostmigrationsave = maps/mp/gametypes/_hostmigration::callback_hostmigrationsave;
}

abortlevel() //checked matches cerberus output
{
	/*
/#
	println( "ERROR: Aborting level - gametype is not supported" );
#/
	*/
	level.callbackstartgametype = ::callbackvoid;
	level.callbackplayerconnect = ::callbackvoid;
	level.callbackplayerdisconnect = ::callbackvoid;
	level.callbackplayerdamage = ::callbackvoid;
	level.callbackplayerkilled = ::callbackvoid;
	level.callbackplayerlaststand = ::callbackvoid;
	level.callbackplayermelee = ::callbackvoid;
	level.callbackactordamage = ::callbackvoid;
	level.callbackactorkilled = ::callbackvoid;
	level.callbackvehicledamage = ::callbackvoid;
	setdvar( "g_gametype", "dm" );
	exitlevel( 0 );
}

codecallback_glasssmash( pos, dir ) //checked matches cerberus output
{
	level notify( "glass_smash" );
}

callbackvoid() //checked matches cerberus output
{
}

