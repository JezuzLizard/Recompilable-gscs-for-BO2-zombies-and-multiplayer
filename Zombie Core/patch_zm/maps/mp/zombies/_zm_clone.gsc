#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

//#using_animtree( "zm_ally" ); //cannot use this in gsc

init() //checked matches cerberus output
{
	init_mover_tree();
}

spawn_player_clone( player, origin, forceweapon, forcemodel ) //checked matches cerberus output
{
	if ( !isDefined( origin ) )
	{
		origin = player.origin;
	}
	primaryweapons = player getweaponslistprimaries();
	if ( isDefined( forceweapon ) )
	{
		weapon = forceweapon;
	}
	else if ( primaryweapons.size )
	{
		weapon = primaryweapons[ 0 ];
	}
	else
	{
		weapon = player getcurrentweapon();
	}
	weaponmodel = getweaponmodel( weapon );
	spawner = getent( "fake_player_spawner", "targetname" );
	if ( isDefined( spawner ) )
	{
		clone = spawner spawnactor();
		clone.origin = origin;
		clone.isactor = 1;
	}
	else
	{
		clone = spawn( "script_model", origin );
		clone.isactor = 0;
	}
	if ( isDefined( forcemodel ) )
	{
		clone setmodel( forcemodel );
	}
	else
	{
		clone setmodel( self.model );
		if ( isDefined( player.headmodel ) )
		{
			clone.headmodel = player.headmodel;
			clone attach( clone.headmodel, "", 1 );
		}
	}
	if ( weaponmodel != "" && weaponmodel != "none" )
	{
		clone attach( weaponmodel, "tag_weapon_right" );
	}
	clone.team = player.team;
	clone.is_inert = 1;
	clone.zombie_move_speed = "walk";
	clone.script_noteworthy = "corpse_clone";
	clone.actor_damage_func = ::clone_damage_func;
	return clone;
}

clone_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked changed to match cerberus output
{
	idamage = 0;
	if ( sweapon == "knife_ballistic_upgraded_zm" && sweapon == "knife_ballistic_bowie_upgraded_zm" || sweapon == "knife_ballistic_no_melee_upgraded_zm" && sweapon == "knife_ballistic_sickle_upgraded_zm" )
	{
		self notify( "player_revived" );
	}
	return idamage;
}

clone_give_weapon( weapon ) //checked matches cerberus output
{
	weaponmodel = getweaponmodel( weapon );
	if ( weaponmodel != "" && weaponmodel != "none" )
	{
		self attach( weaponmodel, "tag_weapon_right" );
	}
}

clone_animate( animtype ) //checked matches cerberus output
{
	if ( self.isactor )
	{
		self thread clone_actor_animate( animtype );
	}
	else
	{
		self thread clone_mover_animate( animtype );
	}
}

clone_actor_animate( animtype ) //checked matches cerberus output
{
	wait 0.1;
	switch( animtype )
	{
		case "laststand":
			self setanimstatefromasd( "laststand" );
			break;
		case "idle":
		default:
			self setanimstatefromasd( "idle" );
			break;
	}
}

init_mover_tree() //checked matches cerberus output
{
	scriptmodelsuseanimtree( -1 );
}

clone_mover_animate( animtype ) //checked matches cerberus output
{
	self useanimtree( -1 );
	switch( animtype )
	{
		case "laststand":
			self setanim( %pb_laststand_idle );
			break;
		case "afterlife":
			self setanim( %pb_afterlife_laststand_idle );
			break;
		case "chair":
			self setanim( %ai_actor_elec_chair_idle );
			break;
		case "falling":
			self setanim( %pb_falling_loop );
			break;
		case "idle":
		default:
			self setanim( %pb_stand_alert );
			break;
	}
}

