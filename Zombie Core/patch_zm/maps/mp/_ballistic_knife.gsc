#include maps/mp/_challenges;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precachemodel( "t6_wpn_ballistic_knife_projectile" );
	precachemodel( "t6_wpn_ballistic_knife_blade_retrieve" );
}

onspawn( watcher, player )
{
	player endon( "death" );
	player endon( "disconnect" );
	level endon( "game_ended" );
	self waittill( "stationary", endpos, normal, angles, attacker, prey, bone );
	isfriendly = 0;
	if ( isDefined( endpos ) )
	{
		retrievable_model = spawn( "script_model", endpos );
		retrievable_model setmodel( "t6_wpn_ballistic_knife_projectile" );
		retrievable_model setteam( player.team );
		retrievable_model setowner( player );
		retrievable_model.owner = player;
		retrievable_model.angles = angles;
		retrievable_model.name = watcher.weapon;
		retrievable_model.targetname = "sticky_weapon";
		if ( isDefined( prey ) )
		{
			if ( level.teambased && isplayer( prey ) && player.team == prey.team )
			{
				isfriendly = 1;
			}
			else
			{
				if ( level.teambased && isai( prey ) && player.team == prey.aiteam )
				{
					isfriendly = 1;
				}
			}
			if ( !isfriendly )
			{
				if ( isalive( prey ) )
				{
					retrievable_model droptoground( retrievable_model.origin, 80 );
				}
				else
				{
					retrievable_model linkto( prey, bone );
				}
			}
			else
			{
				if ( isfriendly )
				{
					retrievable_model physicslaunch( normal, ( randomint( 10 ), randomint( 10 ), randomint( 10 ) ) );
					normal = ( 0, 0, 1 );
				}
			}
		}
		watcher.objectarray[ watcher.objectarray.size ] = retrievable_model;
		if ( isfriendly )
		{
			retrievable_model waittill( "stationary" );
		}
		retrievable_model thread dropknivestoground();
		if ( isfriendly )
		{
			player notify( "ballistic_knife_stationary" );
		}
		else
		{
			player notify( "ballistic_knife_stationary" );
		}
		retrievable_model thread wait_to_show_glowing_model( prey );
	}
}

wait_to_show_glowing_model( prey )
{
	level endon( "game_ended" );
	self endon( "death" );
	glowing_retrievable_model = spawn( "script_model", self.origin );
	self.glowing_model = glowing_retrievable_model;
	glowing_retrievable_model.angles = self.angles;
	glowing_retrievable_model linkto( self );
	if ( isDefined( prey ) && !isalive( prey ) )
	{
		wait 2;
	}
	glowing_retrievable_model setmodel( "t6_wpn_ballistic_knife_blade_retrieve" );
}

watch_shutdown()
{
	pickuptrigger = self.pickuptrigger;
	glowing_model = self.glowing_model;
	self waittill( "death" );
	if ( isDefined( pickuptrigger ) )
	{
		pickuptrigger delete();
	}
	if ( isDefined( glowing_model ) )
	{
		glowing_model delete();
	}
}

onspawnretrievetrigger( watcher, player )
{
	player endon( "death" );
	player endon( "disconnect" );
	level endon( "game_ended" );
	player waittill( "ballistic_knife_stationary", retrievable_model, normal, prey );
	if ( !isDefined( retrievable_model ) )
	{
		return;
	}
	vec_scale = 10;
	trigger_pos = [];
	if ( isDefined( prey ) || isplayer( prey ) && isai( prey ) )
	{
		trigger_pos[ 0 ] = prey.origin[ 0 ];
		trigger_pos[ 1 ] = prey.origin[ 1 ];
		trigger_pos[ 2 ] = prey.origin[ 2 ] + vec_scale;
	}
	else
	{
		trigger_pos[ 0 ] = retrievable_model.origin[ 0 ] + ( vec_scale * normal[ 0 ] );
		trigger_pos[ 1 ] = retrievable_model.origin[ 1 ] + ( vec_scale * normal[ 1 ] );
		trigger_pos[ 2 ] = retrievable_model.origin[ 2 ] + ( vec_scale * normal[ 2 ] );
	}
	trigger_pos[ 2 ] -= 50;
	pickup_trigger = spawn( "trigger_radius", ( trigger_pos[ 0 ], trigger_pos[ 1 ], trigger_pos[ 2 ] ), 0, 50, 100 );
	pickup_trigger.owner = player;
	retrievable_model.pickuptrigger = pickup_trigger;
	pickup_trigger enablelinkto();
	if ( isDefined( prey ) )
	{
		pickup_trigger linkto( prey );
	}
	else
	{
		pickup_trigger linkto( retrievable_model );
	}
	retrievable_model thread watch_use_trigger( pickup_trigger, retrievable_model, ::pick_up, watcher.pickupsoundplayer, watcher.pickupsound );
	retrievable_model thread watch_shutdown();
}

watch_use_trigger( trigger, model, callback, playersoundonuse, npcsoundonuse )
{
	self endon( "death" );
	self endon( "delete" );
	level endon( "game_ended" );
	max_ammo = weaponmaxammo( "knife_ballistic_mp" ) + 1;
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		while ( !isalive( player ) )
		{
			continue;
		}
		while ( !player isonground() )
		{
			continue;
		}
		if ( isDefined( trigger.triggerteam ) && player.team != trigger.triggerteam )
		{
			continue;
		}
		if ( isDefined( trigger.claimedby ) && player != trigger.claimedby )
		{
			continue;
		}
		while ( !player hasweapon( "knife_ballistic_mp" ) )
		{
			continue;
		}
		ammo_stock = player getweaponammostock( "knife_ballistic_mp" );
		ammo_clip = player getweaponammoclip( "knife_ballistic_mp" );
		current_weapon = player getcurrentweapon();
		total_ammo = ammo_stock + ammo_clip;
		hasreloaded = 1;
		if ( total_ammo > 0 && ammo_stock == total_ammo && current_weapon == "knife_ballistic_mp" )
		{
			hasreloaded = 0;
		}
		if ( total_ammo >= max_ammo || !hasreloaded )
		{
			continue;
		}
		if ( isDefined( playersoundonuse ) )
		{
			player playlocalsound( playersoundonuse );
		}
		if ( isDefined( npcsoundonuse ) )
		{
			player playsound( npcsoundonuse );
		}
		self thread [[ callback ]]( player );
		return;
	}
}

pick_up( player )
{
	self destroy_ent();
	current_weapon = player getcurrentweapon();
	player maps/mp/_challenges::pickedupballisticknife();
	if ( current_weapon != "knife_ballistic_mp" )
	{
		clip_ammo = player getweaponammoclip( "knife_ballistic_mp" );
		if ( !clip_ammo )
		{
			player setweaponammoclip( "knife_ballistic_mp", 1 );
		}
		else
		{
			new_ammo_stock = player getweaponammostock( "knife_ballistic_mp" ) + 1;
			player setweaponammostock( "knife_ballistic_mp", new_ammo_stock );
		}
	}
	else
	{
		new_ammo_stock = player getweaponammostock( "knife_ballistic_mp" ) + 1;
		player setweaponammostock( "knife_ballistic_mp", new_ammo_stock );
	}
}

destroy_ent()
{
	if ( isDefined( self ) )
	{
		pickuptrigger = self.pickuptrigger;
		if ( isDefined( pickuptrigger ) )
		{
			pickuptrigger delete();
		}
		if ( isDefined( self.glowing_model ) )
		{
			self.glowing_model delete();
		}
		self delete();
	}
}

dropknivestoground()
{
	self endon( "death" );
	for ( ;; )
	{
		level waittill( "drop_objects_to_ground", origin, radius );
		self droptoground( origin, radius );
	}
}

droptoground( origin, radius )
{
	if ( distancesquared( origin, self.origin ) < ( radius * radius ) )
	{
		self physicslaunch( ( 0, 0, 1 ), vectorScale( ( 0, 0, 1 ), 5 ) );
		self thread updateretrievetrigger();
	}
}

updateretrievetrigger()
{
	self endon( "death" );
	self waittill( "stationary" );
	trigger = self.pickuptrigger;
	trigger.origin = ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + 10 );
	trigger linkto( self );
}
