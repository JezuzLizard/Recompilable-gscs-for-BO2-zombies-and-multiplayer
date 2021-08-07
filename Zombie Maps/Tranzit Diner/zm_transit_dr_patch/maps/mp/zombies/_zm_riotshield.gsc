#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_weap_riotshield;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;

init()
{
	level.riotshield_name = "riotshield_zm";
	level.deployedshieldmodel = [];
	level.stowedshieldmodel = [];
	level.carriedshieldmodel = [];
	level.deployedshieldmodel[ 0 ] = "t6_wpn_zmb_shield_world";
	level.deployedshieldmodel[ 2 ] = "t6_wpn_zmb_shield_dmg1_world";
	level.deployedshieldmodel[ 3 ] = "t6_wpn_zmb_shield_dmg2_world";
	level.stowedshieldmodel[ 0 ] = "t6_wpn_zmb_shield_stow";
	level.stowedshieldmodel[ 2 ] = "t6_wpn_zmb_shield_dmg1_stow";
	level.stowedshieldmodel[ 3 ] = "t6_wpn_zmb_shield_dmg2_stow";
	level.carriedshieldmodel[ 0 ] = "t6_wpn_zmb_shield_world";
	level.carriedshieldmodel[ 2 ] = "t6_wpn_zmb_shield_dmg1_world";
	level.carriedshieldmodel[ 3 ] = "t6_wpn_zmb_shield_dmg2_world";
	level.viewshieldmodel[ 0 ] = "t6_wpn_zmb_shield_view";
	level.viewshieldmodel[ 2 ] = "t6_wpn_zmb_shield_dmg1_view";
	level.viewshieldmodel[ 3 ] = "t6_wpn_zmb_shield_dmg2_view";
	precachemodel( level.stowedshieldmodel[ 0 ] );
	precachemodel( level.stowedshieldmodel[ 2 ] );
	precachemodel( level.stowedshieldmodel[ 3 ] );
	precachemodel( level.carriedshieldmodel[ 0 ] );
	precachemodel( level.carriedshieldmodel[ 2 ] );
	precachemodel( level.carriedshieldmodel[ 3 ] );
	precachemodel( level.viewshieldmodel[ 0 ] );
	precachemodel( level.viewshieldmodel[ 2 ] );
	precachemodel( level.viewshieldmodel[ 3 ] );
	level.riotshield_placement_zoffset = 26;
}

attachriotshield( model, tag )
{
	if ( isDefined( self.prev_shield_model ) && isDefined( self.prev_shield_tag ) )
	{
		self detachshieldmodel( self.prev_shield_model, self.prev_shield_tag );
	}
	self.prev_shield_model = model;
	self.prev_shield_tag = tag;
	if ( isDefined( self.prev_shield_model ) && isDefined( self.prev_shield_tag ) )
	{
		self attachshieldmodel( self.prev_shield_model, self.prev_shield_tag );
	}
}

removeriotshield()
{
	if ( isDefined( self.prev_shield_model ) && isDefined( self.prev_shield_tag ) )
	{
		self detachshieldmodel( self.prev_shield_model, self.prev_shield_tag );
	}
	self.prev_shield_model = undefined;
	self.prev_shield_tag = undefined;
	if ( self getcurrentweapon() != level.riotshield_name )
	{
		return;
	}
	self setheldweaponmodel( 0 );
}

setriotshieldviewmodel( modelnum )
{
	self.prev_shield_viewmodel = modelnum;
	if ( self getcurrentweapon() != level.riotshield_name )
	{
		return;
	}
	if ( isDefined( self.prev_shield_viewmodel ) )
	{
		self setheldweaponmodel( self.prev_shield_viewmodel );
	}
	else
	{
		self setheldweaponmodel( 0 );
	}
}

specialriotshieldviewmodel()
{
	if ( self getcurrentweapon() != level.riotshield_name )
	{
		return;
	}
	self setheldweaponmodel( 3 );
}

restoreriotshieldviewmodel()
{
	if ( self getcurrentweapon() != level.riotshield_name )
	{
		return;
	}
	if ( isDefined( self.prev_shield_viewmodel ) )
	{
		self setheldweaponmodel( self.prev_shield_viewmodel );
	}
	else
	{
		self setheldweaponmodel( 0 );
	}
}

updateriotshieldmodel()
{
	if ( !isDefined( self.shield_damage_level ) )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	update = 0;
	if ( !isDefined( self.prev_shield_damage_level ) || self.prev_shield_damage_level != self.shield_damage_level )
	{
		self.prev_shield_damage_level = self.shield_damage_level;
		update = 1;
	}
	if ( !isDefined( self.prev_shield_placement ) || self.prev_shield_placement != self.shield_placement )
	{
		self.prev_shield_placement = self.shield_placement;
		update = 1;
	}
	if ( update )
	{
		if ( self.prev_shield_placement == 0 )
		{
			self attachriotshield();
			return;
		}
		else if ( self.prev_shield_placement == 1 )
		{
			self attachriotshield( level.carriedshieldmodel[ self.prev_shield_damage_level ], "tag_weapon_left" );
			self setriotshieldviewmodel( self.prev_shield_damage_level );
			return;
		}
		else if ( self.prev_shield_placement == 2 )
		{
			self attachriotshield( level.stowedshieldmodel[ self.prev_shield_damage_level ], "tag_stowed_back" );
			return;
		}
		else
		{
			if ( self.prev_shield_placement == 3 )
			{
				self attachriotshield();
				if ( isDefined( self.shield_ent ) )
				{
					self.shield_ent setmodel( level.deployedshieldmodel[ self.prev_shield_damage_level ] );
				}
			}
		}
	}
}

updatestandaloneriotshieldmodel()
{
	update = 0;
	if ( !isDefined( self.prev_shield_damage_level ) || self.prev_shield_damage_level != self.shield_damage_level )
	{
		self.prev_shield_damage_level = self.shield_damage_level;
		update = 1;
	}
	if ( update )
	{
		self setmodel( level.deployedshieldmodel[ self.prev_shield_damage_level ] );
	}
}

watchshieldlaststand()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "watchShieldLastStand" );
	self endon( "watchShieldLastStand" );
	while ( 1 )
	{
		self waittill( "weapons_taken_for_last_stand" );
		self.riotshield_hidden = 0;
		if ( isDefined( self.hasriotshield ) && self.hasriotshield )
		{
			if ( self.prev_shield_placement == 1 || self.prev_shield_placement == 2 )
			{
				self.riotshield_hidden = 2;
				self.shield_placement = 0;
				self updateriotshieldmodel();
			}
		}
		str_notify = self waittill_any_return( "player_revived", "bled_out" );
		if ( str_notify == "player_revived" )
		{
			if ( isDefined( self.riotshield_hidden ) && self.riotshield_hidden > 0 )
			{
				self.shield_placement = self.riotshield_hidden;
				self updateriotshieldmodel();
			}
		}
		else
		{
			self maps/mp/zombies/_zm_weap_riotshield::player_take_riotshield();
		}
		self.riotshield_hidden = undefined;
	}
}

trackriotshield()
{
	self endon( "death" );
	self endon( "disconnect" );
	self.hasriotshield = self hasweapon( level.riotshield_name );
	self.hasriotshieldequipped = self getcurrentweapon() == level.riotshield_name;
	self.shield_placement = 0;
	if ( self.hasriotshield )
	{
		if ( self.hasriotshieldequipped )
		{
			self.shield_placement = 1;
			self updateriotshieldmodel();
		}
		else
		{
			self.shield_placement = 2;
			self updateriotshieldmodel();
		}
	}
	for ( ;; )
	{
		self waittill( "weapon_change", newweapon );
		if ( newweapon == level.riotshield_name )
		{
			if ( self.hasriotshieldequipped )
			{
				continue;
			}
			else if ( isDefined( self.riotshieldentity ) )
			{
				self notify( "destroy_riotshield" );
			}
			self.shield_placement = 1;
			self updateriotshieldmodel();
			if ( self.hasriotshield )
			{
				break;
			}
			self.hasriotshield = 1;
			self.hasriotshieldequipped = 1;
			continue;
		}
		else if ( self ismantling() && newweapon == "none" )
		{
			continue;
		}
		else
		{
			if ( self.hasriotshieldequipped )
			{
/#
				assert( self.hasriotshield );
#/
				self.hasriotshield = self hasweapon( level.riotshield_name );
				if ( isDefined( self.riotshield_hidden ) && self.riotshield_hidden )
				{
				}
				else
				{
					if ( self.hasriotshield )
					{
						self.shield_placement = 2;
						break;
					}
					else if ( isDefined( self.shield_ent ) )
					{
/#
						assert( self.shield_placement == 3 );
#/
						break;
					}
					else
					{
						self.shield_placement = 0;
					}
				}
				self updateriotshieldmodel();
				self.hasriotshieldequipped = 0;
				break;
			}
			else
			{
				if ( self.hasriotshield )
				{
					if ( !self hasweapon( level.riotshield_name ) )
					{
						self.shield_placement = 0;
						self updateriotshieldmodel();
						self.hasriotshield = 0;
					}
				}
			}
		}
	}
}

updateriotshieldplacement()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "deploy_riotshield" );
	self endon( "start_riotshield_deploy" );
	self endon( "weapon_change" );
	while ( 1 )
	{
		placement = self canplaceriotshield( "raise_riotshield" );
		if ( placement[ "result" ] && riotshielddistancetest( placement[ "origin" ] ) )
		{
			self restoreriotshieldviewmodel();
			self setplacementhint( 1 );
		}
		else
		{
			self specialriotshieldviewmodel();
			self setplacementhint( 0 );
		}
		wait 0,05;
	}
}

startriotshielddeploy()
{
	self notify( "start_riotshield_deploy" );
	self thread updateriotshieldplacement();
	self thread watchriotshielddeploy();
}

spawnriotshieldcover( origin, angles )
{
	shield_ent = spawn( "script_model", origin, 1 );
	shield_ent.angles = angles;
	shield_ent setowner( self );
	shield_ent.owner = self;
	shield_ent.owner.shield_ent = shield_ent;
	shield_ent.isriotshield = 1;
	self.shield_placement = 3;
	self updateriotshieldmodel();
	shield_ent setscriptmoverflag( 0 );
	self thread maps/mp/zombies/_zm_buildables::delete_on_disconnect( shield_ent, "destroy_riotshield", 1 );
	maps/mp/zombies/_zm_equipment::destructible_equipment_list_add( shield_ent );
	return shield_ent;
}

watchriotshielddeploy()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "start_riotshield_deploy" );
	self waittill( "deploy_riotshield", deploy_attempt );
	self restoreriotshieldviewmodel();
	self setplacementhint( 1 );
	placement_hint = 0;
	if ( deploy_attempt )
	{
		placement = self canplaceriotshield( "deploy_riotshield" );
		if ( placement[ "result" ] && riotshielddistancetest( placement[ "origin" ] ) && self check_plant_position( placement[ "origin" ], placement[ "angles" ] ) )
		{
			self doriotshielddeploy( placement[ "origin" ], placement[ "angles" ] );
		}
		else
		{
			placement_hint = 1;
			clip_max_ammo = weaponclipsize( level.riotshield_name );
			self setweaponammoclip( level.riotshield_name, clip_max_ammo );
		}
	}
	else
	{
		placement_hint = 1;
	}
	if ( placement_hint )
	{
		self setriotshieldfailhint();
	}
}

check_plant_position( origin, angles )
{
	if ( isDefined( level.equipment_safe_to_drop ) )
	{
		ret = 1;
		test_ent = spawn( "script_model", origin );
		test_ent setmodel( level.deployedshieldmodel[ 0 ] );
		test_ent.angles = angles;
		if ( !( self [[ level.equipment_safe_to_drop ]]( test_ent ) ) )
		{
			ret = 0;
		}
		test_ent delete();
		return ret;
	}
	return 1;
}

doriotshielddeploy( origin, angles )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "start_riotshield_deploy" );
	self notify( "deployed_riotshield" );
	self maps/mp/zombies/_zm_buildables::track_placed_buildables( level.riotshield_name );
	if ( isDefined( self.current_equipment ) && self.current_equipment == level.riotshield_name )
	{
		self maps/mp/zombies/_zm_equipment::equipment_to_deployed( level.riotshield_name );
	}
	zoffset = level.riotshield_placement_zoffset;
	shield_ent = self spawnriotshieldcover( origin + ( 0, 0, zoffset ), angles );
	item_ent = deployriotshield( self, shield_ent );
	primaries = self getweaponslistprimaries();
/#
	assert( isDefined( item_ent ) );
	assert( !isDefined( self.riotshieldretrievetrigger ) );
	assert( !isDefined( self.riotshieldentity ) );
#/
	self maps/mp/zombies/_zm_weapons::switch_back_primary_weapon( primaries[ 0 ] );
	if ( isDefined( level.equipment_planted ) )
	{
		self [[ level.equipment_planted ]]( shield_ent, level.riotshield_name, self );
	}
	if ( isDefined( level.equipment_safe_to_drop ) )
	{
		if ( !( self [[ level.equipment_safe_to_drop ]]( shield_ent ) ) )
		{
			self notify( "destroy_riotshield" );
			shield_ent delete();
			item_ent delete();
			return;
		}
	}
	self.riotshieldretrievetrigger = item_ent;
	self.riotshieldentity = shield_ent;
	self thread watchdeployedriotshieldents();
	self thread deleteshieldondamage( self.riotshieldentity );
	self thread deleteshieldmodelonweaponpickup( self.riotshieldretrievetrigger );
	self thread deleteriotshieldonplayerdeath();
	self thread watchshieldtriggervisibility( self.riotshieldretrievetrigger );
	self.riotshieldentity thread watchdeployedriotshielddamage();
	return shield_ent;
}

riotshielddistancetest( origin )
{
/#
	assert( isDefined( origin ) );
#/
	min_dist_squared = getDvarFloat( "riotshield_deploy_limit_radius" );
	min_dist_squared *= min_dist_squared;
	i = 0;
	while ( i < level.players.size )
	{
		if ( isDefined( level.players[ i ].riotshieldentity ) )
		{
			dist_squared = distancesquared( level.players[ i ].riotshieldentity.origin, origin );
			if ( min_dist_squared > dist_squared )
			{
/#
				println( "Shield placement denied!  Failed distance check to other riotshields." );
#/
				return 0;
			}
		}
		i++;
	}
	return 1;
}

watchdeployedriotshieldents()
{
/#
	assert( isDefined( self.riotshieldretrievetrigger ) );
	assert( isDefined( self.riotshieldentity ) );
#/
	riotshieldretrievetrigger = self.riotshieldretrievetrigger;
	riotshieldentity = self.riotshieldentity;
	self waittill_any( "destroy_riotshield", "disconnect", "riotshield_zm_taken" );
	if ( isDefined( self ) )
	{
		self.shield_placement = 0;
		self updateriotshieldmodel();
	}
	if ( isDefined( riotshieldretrievetrigger ) )
	{
		riotshieldretrievetrigger delete();
	}
	if ( isDefined( riotshieldentity ) )
	{
		riotshieldentity delete();
	}
}

watchdeployedriotshielddamage()
{
	self endon( "death" );
	damagemax = getDvarInt( "riotshield_deployed_health" );
	self.damagetaken = 0;
	while ( 1 )
	{
		self.maxhealth = 100000;
		self.health = self.maxhealth;
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		if ( isDefined( level.players_can_damage_riotshields ) && !level.players_can_damage_riotshields )
		{
			continue;
		}
		if ( !isDefined( attacker ) || !isplayer( attacker ) )
		{
			continue;
		}
/#
		if ( isDefined( self.owner ) )
		{
			assert( isDefined( self.owner.team ) );
		}
#/
		while ( is_encounter() && attacker.team == self.owner.team && attacker != self.owner )
		{
			continue;
		}
		if ( isDefined( level.riotshield_damage_callback ) )
		{
			self.owner [[ level.riotshield_damage_callback ]]( damage, 0 );
			continue;
		}
		else
		{
			if ( type == "MOD_MELEE" )
			{
				damage *= getDvarFloat( "riotshield_melee_damage_scale" );
			}
			else if ( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" )
			{
				damage *= getDvarFloat( "riotshield_bullet_damage_scale" );
			}
			else
			{
				if ( type != "MOD_GRENADE" && type != "MOD_GRENADE_SPLASH" && type != "MOD_EXPLOSIVE" && type != "MOD_EXPLOSIVE_SPLASH" || type == "MOD_PROJECTILE" && type == "MOD_PROJECTILE_SPLASH" )
				{
					damage *= getDvarFloat( "riotshield_explosive_damage_scale" );
					break;
				}
				else
				{
					if ( type == "MOD_IMPACT" )
					{
						damage *= getDvarFloat( "riotshield_projectile_damage_scale" );
					}
				}
			}
			self.damagetaken += damage;
			if ( self.damagetaken >= damagemax )
			{
				self damagethendestroyriotshield();
			}
		}
	}
}

damagethendestroyriotshield()
{
	self endon( "death" );
	self.owner.riotshieldretrievetrigger delete();
	self notsolid();
	self setclientflag( 14 );
	wait getDvarFloat( "riotshield_destroyed_cleanup_time" );
	self.owner notify( "destroy_riotshield" );
}

deleteshieldondamage( shield_ent )
{
	shield_ent waittill( "death" );
	self notify( "destroy_riotshield" );
}

deleteshieldmodelonweaponpickup( shield_trigger )
{
	shield_trigger waittill( "trigger", player );
	self maps/mp/zombies/_zm_equipment::equipment_from_deployed( level.riotshield_name );
	self notify( "destroy_riotshield" );
	if ( self != player )
	{
		if ( isDefined( level.transferriotshield ) )
		{
			[[ level.transferriotshield ]]( self, player );
		}
	}
}

watchshieldtriggervisibility( trigger )
{
	self endon( "death" );
	trigger endon( "death" );
	while ( isDefined( trigger ) )
	{
		players = get_players();
		_a740 = players;
		_k740 = getFirstArrayKey( _a740 );
		while ( isDefined( _k740 ) )
		{
			player = _a740[ _k740 ];
			pickup = 1;
			if ( !isDefined( player ) )
			{
			}
			else
			{
				if ( isDefined( level.cantransferriotshield ) )
				{
					pickup = [[ level.cantransferriotshield ]]( self, player );
				}
				if ( !isDefined( trigger ) )
				{
					return;
				}
				if ( pickup )
				{
					trigger setvisibletoplayer( player );
				}
				else
				{
					trigger setinvisibletoplayer( player );
				}
				wait 0,05;
			}
			_k740 = getNextArrayKey( _a740, _k740 );
		}
		wait 0,05;
	}
}

deleteriotshieldonplayerdeath()
{
	self.riotshieldentity endon( "death" );
	self waittill( "death" );
	self notify( "destroy_riotshield" );
}
