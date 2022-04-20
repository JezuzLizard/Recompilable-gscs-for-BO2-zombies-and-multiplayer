#include maps/mp/gametypes_zm/_spawnlogic;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	if ( !isDefined( level.gamemodespawndvars ) )
	{
		level.gamemodespawndvars = ::default_gamemodespawndvars;
	}
	level init_spawn_system();
	level.recently_deceased = [];
	_a74 = level.teams;
	_k74 = getFirstArrayKey( _a74 );
	while ( isDefined( _k74 ) )
	{
		team = _a74[ _k74 ];
		level.recently_deceased[ team ] = spawn_array_struct();
		_k74 = getNextArrayKey( _a74, _k74 );
	}
	level thread onplayerconnect();
	if ( getDvar( #"AD6C19FE" ) == "" )
	{
		level.spawn_visibility_check_max = 20;
	}
	else
	{
		level.spawn_visibility_check_max = getDvarInt( #"AD6C19FE" );
	}
	level.spawnprotectiontime = getgametypesetting( "spawnprotectiontime" );
/#
	setdvar( "scr_debug_spawn_player", "" );
	setdvar( "scr_debug_render_spawn_data", "1" );
	setdvar( "scr_debug_render_snapshotmode", "0" );
	setdvar( "scr_spawn_point_test_mode", "0" );
	level.test_spawn_point_index = 0;
	setdvar( "scr_debug_render_spawn_text", "1" );
#/
	return;
}

default_gamemodespawndvars( reset_dvars )
{
}

init_spawn_system()
{
	level.spawnsystem = spawnstruct();
	spawnsystem = level.spawnsystem;
	level get_player_spawning_dvars( 1 );
	level thread initialize_player_spawning_dvars();
	spawnsystem.einfluencer_shape_sphere = 0;
	spawnsystem.einfluencer_shape_cylinder = 1;
	spawnsystem.einfluencer_type_normal = 0;
	spawnsystem.einfluencer_type_player = 1;
	spawnsystem.einfluencer_type_weapon = 2;
	spawnsystem.einfluencer_type_dog = 3;
	spawnsystem.einfluencer_type_vehicle = 4;
	spawnsystem.einfluencer_type_game_mode = 6;
	spawnsystem.einfluencer_type_enemy_spawned = 7;
	spawnsystem.einfluencer_curve_constant = 0;
	spawnsystem.einfluencer_curve_linear = 1;
	spawnsystem.einfluencer_curve_steep = 2;
	spawnsystem.einfluencer_curve_inverse_linear = 3;
	spawnsystem.einfluencer_curve_negative_to_positive = 4;
	spawnsystem.ispawn_teammask = [];
	spawnsystem.ispawn_teammask_free = 1;
	spawnsystem.ispawn_teammask[ "free" ] = spawnsystem.ispawn_teammask_free;
	all = spawnsystem.ispawn_teammask_free;
	count = 1;
	_a146 = level.teams;
	_k146 = getFirstArrayKey( _a146 );
	while ( isDefined( _k146 ) )
	{
		team = _a146[ _k146 ];
		spawnsystem.ispawn_teammask[ team ] = 1 << count;
		all |= spawnsystem.ispawn_teammask[ team ];
		count++;
		_k146 = getNextArrayKey( _a146, _k146 );
	}
	spawnsystem.ispawn_teammask[ "all" ] = all;
}

onplayerconnect()
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill( "connecting", player );
		player setentertime( getTime() );
		player thread onplayerspawned();
		player thread ondisconnect();
		player thread onteamchange();
		player thread ongrenadethrow();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread initialspawnprotection( "specialty_nottargetedbyairsupport", 1 );
		self thread initialspawnprotection( "specialty_nokillstreakreticle", 0 );
		self thread initialspawnprotection( "specialty_nottargettedbysentry", 0 );
		if ( isDefined( self.pers[ "hasRadar" ] ) && self.pers[ "hasRadar" ] )
		{
			self.hasspyplane = 1;
		}
		self enable_player_influencers( 1 );
		self thread ondeath();
	}
}

ondeath()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self waittill( "death" );
	self enable_player_influencers( 0 );
	self create_body_influencers();
}

onteamchange()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	while ( 1 )
	{
		self waittill( "joined_team" );
		self player_influencers_set_team();
		wait 0,05;
	}
}

ongrenadethrow()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weaponname );
		level thread create_grenade_influencers( self.pers[ "team" ], weaponname, grenade );
		wait 0,05;
	}
}

ondisconnect()
{
	level endon( "game_ended" );
	self waittill( "disconnect" );
}

get_score_curve_index( curve )
{
	switch( curve )
	{
		case "linear":
			return level.spawnsystem.einfluencer_curve_linear;
		case "steep":
			return level.spawnsystem.einfluencer_curve_steep;
		case "inverse_linear":
			return level.spawnsystem.einfluencer_curve_linear;
		case "negative_to_positive":
			return level.spawnsystem.einfluencer_curve_negative_to_positive;
		case "constant":
		default:
			return level.spawnsystem.einfluencer_curve_constant;
	}
}

get_influencer_type_index( curve )
{
}

create_player_influencers()
{
/#
	assert( !isDefined( self.influencer_enemy_sphere ) );
#/
/#
	assert( !isDefined( self.influencer_weapon_cylinder ) );
#/
/#
	if ( level.teambased )
	{
		assert( !isDefined( self.influencer_friendly_sphere ) );
	}
#/
/#
	if ( level.teambased )
	{
		assert( !isDefined( self.influencer_friendly_cylinder ) );
	}
#/
	if ( !level.teambased )
	{
		team_mask = level.spawnsystem.ispawn_teammask_free;
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
		weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else if ( isDefined( self.pers[ "team" ] ) )
	{
		team = self.pers[ "team" ];
		team_mask = getteammask( team );
		other_team_mask = getotherteamsmask( team );
		weapon_team_mask = getotherteamsmask( team );
	}
	else
	{
		team_mask = 0;
		other_team_mask = 0;
		weapon_team_mask = 0;
	}
	if ( level.hardcoremode )
	{
		weapon_team_mask |= team_mask;
	}
	angles = self.angles;
	origin = self.origin;
	up = ( 0, 0, 0 );
	forward = ( 0, 0, 0 );
	cylinder_forward = up;
	cylinder_up = forward;
	self.influencer_enemy_sphere = addsphereinfluencer( level.spawnsystem.einfluencer_type_player, origin, level.spawnsystem.enemy_influencer_radius, level.spawnsystem.enemy_influencer_score, other_team_mask, "enemy,r,s", get_score_curve_index( level.spawnsystem.enemy_influencer_score_curve ), 0, self );
	if ( level.teambased )
	{
		cylinder_up = -1 * forward;
		self.influencer_friendly_sphere = addsphereinfluencer( level.spawnsystem.einfluencer_type_player, origin, level.spawnsystem.friend_weak_influencer_radius, level.spawnsystem.friend_weak_influencer_score, team_mask, "friend_weak,r,s", get_score_curve_index( level.spawnsystem.friend_weak_influencer_score_curve ), 0, self );
	}
	self.spawn_influencers_created = 1;
	if ( !isDefined( self.pers[ "team" ] ) || self.pers[ "team" ] == "spectator" )
	{
		self enable_player_influencers( 0 );
	}
}

remove_player_influencers()
{
	if ( level.teambased && isDefined( self.influencer_friendly_sphere ) )
	{
		removeinfluencer( self.influencer_friendly_sphere );
		self.influencer_friendly_sphere = undefined;
	}
	if ( level.teambased && isDefined( self.influencer_friendly_cylinder ) )
	{
		removeinfluencer( self.influencer_friendly_cylinder );
		self.influencer_friendly_cylinder = undefined;
	}
	if ( isDefined( self.influencer_enemy_sphere ) )
	{
		removeinfluencer( self.influencer_enemy_sphere );
		self.influencer_enemy_sphere = undefined;
	}
	if ( isDefined( self.influencer_weapon_cylinder ) )
	{
		removeinfluencer( self.influencer_weapon_cylinder );
		self.influencer_weapon_cylinder = undefined;
	}
}

enable_player_influencers( enabled )
{
	if ( !isDefined( self.spawn_influencers_created ) )
	{
		self create_player_influencers();
	}
	if ( isDefined( self.influencer_friendly_sphere ) )
	{
		enableinfluencer( self.influencer_friendly_sphere, enabled );
	}
	if ( isDefined( self.influencer_friendly_cylinder ) )
	{
		enableinfluencer( self.influencer_friendly_cylinder, enabled );
	}
	if ( isDefined( self.influencer_enemy_sphere ) )
	{
		enableinfluencer( self.influencer_enemy_sphere, enabled );
	}
	if ( isDefined( self.influencer_weapon_cylinder ) )
	{
		enableinfluencer( self.influencer_weapon_cylinder, enabled );
	}
}

player_influencers_set_team()
{
	if ( !level.teambased )
	{
		team_mask = level.spawnsystem.ispawn_teammask_free;
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
		weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		team = self.pers[ "team" ];
		team_mask = getteammask( team );
		other_team_mask = getotherteamsmask( team );
		weapon_team_mask = getotherteamsmask( team );
	}
	if ( level.friendlyfire != 0 && level.teambased )
	{
		weapon_team_mask |= team_mask;
	}
	if ( isDefined( self.influencer_friendly_sphere ) )
	{
		setinfluencerteammask( self.influencer_friendly_sphere, team_mask );
	}
	if ( isDefined( self.influencer_friendly_cylinder ) )
	{
		setinfluencerteammask( self.influencer_friendly_cylinder, team_mask );
	}
	if ( isDefined( self.influencer_enemy_sphere ) )
	{
		setinfluencerteammask( self.influencer_enemy_sphere, other_team_mask );
	}
	if ( isDefined( self.influencer_weapon_cylinder ) )
	{
		setinfluencerteammask( self.influencer_weapon_cylinder, weapon_team_mask );
	}
}

create_body_influencers()
{
	if ( level.teambased )
	{
		team_mask = getteammask( self.pers[ "team" ] );
	}
	else
	{
		team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.dead_friend_influencer_radius, level.spawnsystem.dead_friend_influencer_score, team_mask, "dead_friend,r,s", get_score_curve_index( level.spawnsystem.dead_friend_influencer_score_curve ), level.spawnsystem.dead_friend_influencer_timeout_seconds );
}

create_grenade_influencers( parent_team, weaponname, grenade )
{
	pixbeginevent( "create_grenade_influencers" );
	if ( !level.teambased )
	{
		weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		weapon_team_mask = getotherteamsmask( parent_team );
		if ( level.friendlyfire )
		{
			weapon_team_mask |= getteammask( parent_team );
		}
	}
	if ( issubstr( weaponname, "napalmblob" ) || issubstr( weaponname, "gl_" ) )
	{
		pixendevent();
		return;
	}
	timeout = 0;
	if ( weaponname == "tabun_gas_mp" )
	{
		timeout = 7;
	}
	if ( isDefined( grenade.origin ) )
	{
		if ( weaponname == "claymore_mp" || weaponname == "bouncingbetty_mp" )
		{
			addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, grenade.origin, level.spawnsystem.claymore_influencer_radius, level.spawnsystem.claymore_influencer_score, weapon_team_mask, "claymore,r,s", get_score_curve_index( level.spawnsystem.claymore_influencer_score_curve ), timeout, grenade );
		}
		else
		{
			addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, grenade.origin, level.spawnsystem.grenade_influencer_radius, level.spawnsystem.grenade_influencer_score, weapon_team_mask, "grenade,r,s", get_score_curve_index( level.spawnsystem.grenade_influencer_score_curve ), timeout, grenade );
		}
	}
	pixendevent();
}

create_napalm_fire_influencers( point, direction, parent_team, duration )
{
	timeout = duration;
	weapon_team_mask = 0;
	offset = vectorScale( anglesToForward( direction ), 1100 );
	addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point + ( 2 * offset ), level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
	addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point + offset, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
	addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
	addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point - offset, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
}

create_auto_turret_influencer( point, parent_team, angles )
{
	if ( !level.teambased )
	{
		weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		weapon_team_mask = getotherteamsmask( parent_team );
	}
	projected_point = point + vectorScale( anglesToForward( angles ), level.spawnsystem.auto_turret_influencer_radius * 0,7 );
	influencerid = addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, projected_point, level.spawnsystem.auto_turret_influencer_radius, level.spawnsystem.auto_turret_influencer_score, weapon_team_mask, "auto_turret,r,s", get_score_curve_index( level.spawnsystem.auto_turret_influencer_score_curve ) );
	return influencerid;
}

create_dog_influencers()
{
	if ( !level.teambased )
	{
		dog_enemy_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		dog_enemy_team_mask = getotherteamsmask( self.aiteam );
	}
	addsphereinfluencer( level.spawnsystem.einfluencer_type_dog, self.origin, level.spawnsystem.dog_influencer_radius, level.spawnsystem.dog_influencer_score, dog_enemy_team_mask, "dog,r,s", get_score_curve_index( level.spawnsystem.dog_influencer_score_curve ), 0, self );
}

create_helicopter_influencers( parent_team )
{
	if ( !level.teambased )
	{
		team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		team_mask = getotherteamsmask( parent_team );
	}
	self.influencer_helicopter_cylinder = addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, ( 0, 0, 0 ), ( 0, 0, 0 ), level.spawnsystem.helicopter_influencer_radius, level.spawnsystem.helicopter_influencer_length, level.spawnsystem.helicopter_influencer_score, team_mask, "helicopter,r,s", get_score_curve_index( level.spawnsystem.helicopter_influencer_score_curve ), 0, self );
}

remove_helicopter_influencers()
{
	if ( isDefined( self.influencer_helicopter_cylinder ) )
	{
		removeinfluencer( self.influencer_helicopter_cylinder );
	}
	self.influencer_helicopter_cylinder = undefined;
}

create_tvmissile_influencers( parent_team )
{
	if ( !level.teambased || is_hardcore() )
	{
		team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		team_mask = getotherteamsmask( parent_team );
	}
	self.influencer_tvmissile_cylinder = addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, ( 0, 0, 0 ), ( 0, 0, 0 ), level.spawnsystem.tvmissile_influencer_radius, level.spawnsystem.tvmissile_influencer_length, level.spawnsystem.tvmissile_influencer_score, team_mask, "tvmissile,r,s", get_score_curve_index( level.spawnsystem.tvmissile_influencer_score_curve ), 0, self );
}

remove_tvmissile_influencers()
{
	if ( isDefined( self.influencer_tvmissile_cylinder ) )
	{
		removeinfluencer( self.influencer_tvmissile_cylinder );
	}
	self.influencer_tvmissile_cylinder = undefined;
}

create_artillery_influencers( point, radius )
{
	weapon_team_mask = 0;
	if ( radius < 0 )
	{
		thisradius = level.spawnsystem.artillery_influencer_radius;
	}
	else
	{
		thisradius = radius;
	}
	return addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, point + vectorScale( ( 0, 0, 0 ), 2000 ), ( 0, 0, 0 ), ( 0, 0, 0 ), thisradius, 5000, level.spawnsystem.artillery_influencer_score, weapon_team_mask, "artillery,s,r", get_score_curve_index( level.spawnsystem.artillery_influencer_score_curve ), 7 );
}

create_vehicle_influencers()
{
	weapon_team_mask = 0;
	vehicleradius = 144;
	cylinderlength = level.spawnsystem.vehicle_influencer_lead_seconds;
	up = ( 0, 0, 0 );
	forward = ( 0, 0, 0 );
	cylinder_forward = up;
	cylinder_up = forward;
	return addcylinderinfluencer( level.spawnsystem.einfluencer_type_vehicle, self.origin, cylinder_forward, cylinder_up, vehicleradius, cylinderlength, level.spawnsystem.vehicle_influencer_score, weapon_team_mask, "vehicle,s", get_score_curve_index( level.spawnsystem.vehicle_influencer_score_curve ), 0, self );
}

create_rcbomb_influencers( team )
{
	if ( !level.teambased )
	{
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		other_team_mask = getotherteamsmask( team );
	}
	return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.rcbomb_influencer_radius, level.spawnsystem.rcbomb_influencer_score, other_team_mask, "rcbomb,r,s", get_score_curve_index( level.spawnsystem.rcbomb_influencer_score_curve ), 0, self );
}

create_qrdrone_influencers( team )
{
	if ( !level.teambased )
	{
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		other_team_mask = getotherteamsmask( team );
	}
	self.influencer_qrdrone_cylinder = addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, ( 0, 0, 0 ), ( 0, 0, 0 ), level.spawnsystem.qrdrone_cylinder_influencer_radius, level.spawnsystem.qrdrone_cylinder_influencer_length, level.spawnsystem.qrdrone_cylinder_influencer_score, other_team_mask, "qrdrone_cyl,r,s", get_score_curve_index( level.spawnsystem.qrdrone_cylinder_influencer_score_curve ), 0, self );
	return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.qrdrone_influencer_radius, level.spawnsystem.qrdrone_influencer_score, other_team_mask, "qrdrone,r,s", get_score_curve_index( level.spawnsystem.qrdrone_influencer_score_curve ), 0, self );
}

create_aitank_influencers( team )
{
	if ( !level.teambased )
	{
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		other_team_mask = getotherteamsmask( team );
	}
	return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.aitank_influencer_radius, level.spawnsystem.aitank_influencer_score, other_team_mask, "aitank,r,s", get_score_curve_index( level.spawnsystem.aitank_influencer_score_curve ), 0, self );
}

create_pegasus_influencer( origin, team )
{
	if ( !level.teambased )
	{
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		other_team_mask = getotherteamsmask( team );
	}
	return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, origin, level.spawnsystem.pegasus_influencer_radius, level.spawnsystem.pegasus_influencer_score, other_team_mask, "pegasus,r,s", get_score_curve_index( level.spawnsystem.pegasus_influencer_score_curve ), 0 );
}

create_map_placed_influencers()
{
	staticinfluencerents = getentarray( "mp_uspawn_influencer", "classname" );
	i = 0;
	while ( i < staticinfluencerents.size )
	{
		staticinfluencerent = staticinfluencerents[ i ];
		if ( isDefined( staticinfluencerent.script_gameobjectname ) && staticinfluencerent.script_gameobjectname == "twar" )
		{
			i++;
			continue;
		}
		else
		{
			create_map_placed_influencer( staticinfluencerent );
		}
		i++;
	}
}

create_map_placed_influencer( influencer_entity, optional_score_override )
{
	influencer_id = -1;
	if ( isDefined( influencer_entity.script_shape ) && isDefined( influencer_entity.script_score ) && isDefined( influencer_entity.script_score_curve ) )
	{
		switch( influencer_entity.script_shape )
		{
			case "sphere":
				if ( isDefined( influencer_entity.radius ) )
				{
					if ( isDefined( optional_score_override ) )
					{
						score = optional_score_override;
					}
					else
					{
						score = influencer_entity.script_score;
					}
					influencer_id = addsphereinfluencer( level.spawnsystem.einfluencer_type_game_mode, influencer_entity.origin, influencer_entity.radius, score, getteammask( influencer_entity.script_team ), "*map_defined", get_score_curve_index( influencer_entity.script_score_curve ) );
				}
				else
				{
/#
					assertmsg( "Radiant-placed sphere spawn influencers require 'radius' parameter" );
#/
				}
				break;
			case "cylinder":
				if ( isDefined( influencer_entity.radius ) && isDefined( influencer_entity.height ) )
				{
					if ( isDefined( optional_score_override ) )
					{
						score = optional_score_override;
					}
					else
					{
						score = influencer_entity.script_score;
					}
					influencer_id = addcylinderinfluencer( level.spawnsystem.einfluencer_type_game_mode, influencer_entity.origin, anglesToForward( influencer_entity.angles ), anglesToUp( influencer_entity.angles ), influencer_entity.radius, influencer_entity.height, score, getteammask( influencer_entity.script_team ), "*map_defined", get_score_curve_index( influencer_entity.script_score_curve ) );
				}
				else
				{
/#
					assertmsg( "Radiant-placed cylinder spawn influencers require 'radius' and 'height' parameters" );
#/
				}
				break;
			default:
/#
				assertmsg( "Unsupported script_shape value ("" + influencer_entity.script_shape + "") for unified spawning system static influencer.  Supported shapes are "cylinder" and "sphere"." );
#/
				break;
		}
	}
	else
	{
/#
		assertmsg( "Radiant-placed spawn influencers require 'script_shape', 'script_score' and 'script_score_curve' parameters" );
#/
	}
	return influencer_id;
}

create_enemy_spawned_influencers( origin, team )
{
	if ( !level.teambased )
	{
		other_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	else
	{
		other_team_mask = getotherteamsmask( team );
	}
	return addsphereinfluencer( level.spawnsystem.einfluencer_type_enemy_spawned, origin, level.spawnsystem.enemy_spawned_influencer_radius, level.spawnsystem.enemy_spawned_influencer_score, other_team_mask, "enemy_spawned,r,s", get_score_curve_index( level.spawnsystem.enemy_spawned_influencer_score_curve ), 7 );
}

updateallspawnpoints()
{
	_a1046 = level.teams;
	_k1046 = getFirstArrayKey( _a1046 );
	while ( isDefined( _k1046 ) )
	{
		team = _a1046[ _k1046 ];
		gatherspawnentities( team );
		_k1046 = getNextArrayKey( _a1046, _k1046 );
	}
	clearspawnpoints();
	if ( level.teambased )
	{
		_a1055 = level.teams;
		_k1055 = getFirstArrayKey( _a1055 );
		while ( isDefined( _k1055 ) )
		{
			team = _a1055[ _k1055 ];
			addspawnpoints( team, level.unified_spawn_points[ team ].a );
			_k1055 = getNextArrayKey( _a1055, _k1055 );
		}
	}
	else _a1062 = level.teams;
	_k1062 = getFirstArrayKey( _a1062 );
	while ( isDefined( _k1062 ) )
	{
		team = _a1062[ _k1062 ];
		addspawnpoints( "free", level.unified_spawn_points[ team ].a );
		_k1062 = getNextArrayKey( _a1062, _k1062 );
	}
	remove_unused_spawn_entities();
}

initialize_player_spawning_dvars()
{
/#
	reset_dvars = 1;
	while ( 1 )
	{
		get_player_spawning_dvars( reset_dvars );
		reset_dvars = 0;
		wait 2;
#/
	}
}

get_player_spawning_dvars( reset_dvars )
{
	k_player_height = get_player_height();
	player_height_times_10 = "" + ( 10 * k_player_height );
	ss = level.spawnsystem;
	player_influencer_radius = 15 * k_player_height;
	player_influencer_score = 150;
	dog_influencer_radius = 10 * k_player_height;
	dog_influencer_score = 150;
	ss.script_based_influencer_system = set_dvar_int_if_unset( "scr_script_based_influencer_system", "0", reset_dvars );
	ss.randomness_range = set_dvar_float_if_unset( "scr_spawn_randomness_range", "10", reset_dvars );
	ss.objective_facing_bonus = set_dvar_float_if_unset( "scr_spawn_objective_facing_bonus", "50", reset_dvars );
	ss.friend_weak_influencer_score = set_dvar_float_if_unset( "scr_spawn_friend_weak_influencer_score", "10", reset_dvars );
	ss.friend_weak_influencer_score_curve = set_dvar_if_unset( "scr_spawn_friend_weak_influencer_score_curve", "steep", reset_dvars );
	ss.friend_weak_influencer_radius = set_dvar_float_if_unset( "scr_spawn_friend_weak_influencer_radius", player_height_times_10, reset_dvars );
	ss.enemy_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_score", "-150", reset_dvars );
	ss.enemy_influencer_score_curve = set_dvar_if_unset( "scr_spawn_enemy_influencer_score_curve", "steep", reset_dvars );
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
	ss.dead_friend_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_timeout_seconds", "15", reset_dvars );
	ss.dead_friend_influencer_count = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_count", "7", reset_dvars );
	ss.dead_friend_influencer_score = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_score", "-100", reset_dvars );
	ss.dead_friend_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dead_friend_influencer_score_curve", "steep", reset_dvars );
	ss.dead_friend_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_radius", player_height_times_10, reset_dvars );
	ss.vehicle_influencer_score = set_dvar_float_if_unset( "scr_spawn_vehicle_influencer_score", "-50", reset_dvars );
	ss.vehicle_influencer_score_curve = set_dvar_if_unset( "scr_spawn_vehicle_influencer_score_curve", "linear", reset_dvars );
	ss.vehicle_influencer_lead_seconds = set_dvar_float_if_unset( "scr_spawn_vehicle_influencer_lead_seconds", "3", reset_dvars );
	ss.dog_influencer_score = set_dvar_float_if_unset( "scr_spawn_dog_influencer_score", "-150", reset_dvars );
	ss.dog_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dog_influencer_score_curve", "steep", reset_dvars );
	ss.dog_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dog_influencer_radius", "" + ( 15 * k_player_height ), reset_dvars );
	ss.artillery_influencer_score = set_dvar_float_if_unset( "scr_spawn_artillery_influencer_score", "-600", reset_dvars );
	ss.artillery_influencer_score_curve = set_dvar_if_unset( "scr_spawn_artillery_influencer_score_curve", "linear", reset_dvars );
	ss.artillery_influencer_radius = set_dvar_float_if_unset( "scr_spawn_artillery_influencer_radius", "1200", reset_dvars );
	ss.grenade_influencer_score = set_dvar_float_if_unset( "scr_spawn_grenade_influencer_score", "-300", reset_dvars );
	ss.grenade_influencer_score_curve = set_dvar_if_unset( "scr_spawn_grenade_influencer_score_curve", "linear", reset_dvars );
	ss.grenade_influencer_radius = set_dvar_float_if_unset( "scr_spawn_grenade_influencer_radius", "" + ( 8 * k_player_height ), reset_dvars );
	ss.grenade_endpoint_influencer_score = set_dvar_float_if_unset( "scr_spawn_grenade_endpoint_influencer_score", "-300", reset_dvars );
	ss.grenade_endpoint_influencer_score_curve = set_dvar_if_unset( "scr_spawn_grenade_endpoint_influencer_score_curve", "linear", reset_dvars );
	ss.grenade_endpoint_influencer_radius = set_dvar_float_if_unset( "scr_spawn_grenade_endpoint_influencer_radius", "" + ( 8 * k_player_height ), reset_dvars );
	ss.claymore_influencer_score = set_dvar_float_if_unset( "scr_spawn_claymore_influencer_score", "-150", reset_dvars );
	ss.claymore_influencer_score_curve = set_dvar_if_unset( "scr_spawn_claymore_influencer_score_curve", "steep", reset_dvars );
	ss.claymore_influencer_radius = set_dvar_float_if_unset( "scr_spawn_claymore_influencer_radius", "" + ( 9 * k_player_height ), reset_dvars );
	ss.napalm_influencer_score = set_dvar_float_if_unset( "scr_spawn_napalm_influencer_score", "-500", reset_dvars );
	ss.napalm_influencer_score_curve = set_dvar_if_unset( "scr_spawn_napalm_influencer_score_curve", "linear", reset_dvars );
	ss.napalm_influencer_radius = set_dvar_float_if_unset( "scr_spawn_napalm_influencer_radius", "" + 750, reset_dvars );
	ss.auto_turret_influencer_score = set_dvar_float_if_unset( "scr_spawn_auto_turret_influencer_score", "-650", reset_dvars );
	ss.auto_turret_influencer_score_curve = set_dvar_if_unset( "scr_spawn_auto_turret_influencer_score_curve", "linear", reset_dvars );
	ss.auto_turret_influencer_radius = set_dvar_float_if_unset( "scr_spawn_auto_turret_influencer_radius", "" + 1200, reset_dvars );
	ss.rcbomb_influencer_score = set_dvar_float_if_unset( "scr_spawn_rcbomb_influencer_score", "-200", reset_dvars );
	ss.rcbomb_influencer_score_curve = set_dvar_if_unset( "scr_spawn_rcbomb_influencer_score_curve", "steep", reset_dvars );
	ss.rcbomb_influencer_radius = set_dvar_float_if_unset( "scr_spawn_rcbomb_influencer_radius", "" + ( 25 * k_player_height ), reset_dvars );
	ss.qrdrone_influencer_score = set_dvar_float_if_unset( "scr_spawn_qrdrone_influencer_score", "-200", reset_dvars );
	ss.qrdrone_influencer_score_curve = set_dvar_if_unset( "scr_spawn_qrdrone_influencer_score_curve", "steep", reset_dvars );
	ss.qrdrone_influencer_radius = set_dvar_float_if_unset( "scr_spawn_qrdrone_influencer_radius", "" + ( 25 * k_player_height ), reset_dvars );
	ss.qrdrone_cylinder_influencer_score = set_dvar_float_if_unset( "scr_spawn_qrdrone_cylinder_influencer_score", "-300", reset_dvars );
	ss.qrdrone_cylinder_influencer_score_curve = set_dvar_if_unset( "scr_spawn_qrdrone_cylinder_influencer_score_curve", "linear", reset_dvars );
	ss.qrdrone_cylinder_influencer_radius = set_dvar_float_if_unset( "scr_spawn_qrdrone_cylinder_influencer_radius", 1000, reset_dvars );
	ss.qrdrone_cylinder_influencer_length = set_dvar_float_if_unset( "scr_spawn_qrdrone_cylinder_influencer_length", 2000, reset_dvars );
	ss.aitank_influencer_score = set_dvar_float_if_unset( "scr_spawn_aitank_influencer_score", "-200", reset_dvars );
	ss.aitank_influencer_score_curve = set_dvar_if_unset( "scr_spawn_aitank_influencer_score_curve", "linear", reset_dvars );
	ss.aitank_influencer_radius = set_dvar_float_if_unset( "scr_spawn_aitank_influencer_radius", "" + ( 25 * k_player_height ), reset_dvars );
	ss.enemy_spawned_influencer_score_curve = set_dvar_if_unset( "scr_spawn_enemy_spawned_influencer_score_curve", "constant", reset_dvars );
	if ( level.teambased )
	{
		ss.enemy_spawned_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_score", "-200", reset_dvars );
		ss.enemy_spawned_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_radius", "" + 1100, reset_dvars );
	}
	else
	{
		ss.enemy_spawned_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_score", "-100", reset_dvars );
		ss.enemy_spawned_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_radius", "" + 400, reset_dvars );
	}
	ss.helicopter_influencer_score = set_dvar_float_if_unset( "scr_spawn_helicopter_influencer_score", "-500", reset_dvars );
	ss.helicopter_influencer_score_curve = set_dvar_if_unset( "scr_spawn_helicopter_influencer_score_curve", "linear", reset_dvars );
	ss.helicopter_influencer_radius = set_dvar_float_if_unset( "scr_spawn_helicopter_influencer_radius", "" + 2000, reset_dvars );
	ss.helicopter_influencer_length = set_dvar_float_if_unset( "scr_spawn_helicopter_influencer_length", "" + 3500, reset_dvars );
	ss.tvmissile_influencer_score = set_dvar_float_if_unset( "scr_spawn_tvmissile_influencer_score", "-400", reset_dvars );
	ss.tvmissile_influencer_score_curve = set_dvar_if_unset( "scr_spawn_tvmissile_influencer_score_curve", "linear", reset_dvars );
	ss.tvmissile_influencer_radius = set_dvar_float_if_unset( "scr_spawn_tvmissile_influencer_radius", "" + 2000, reset_dvars );
	ss.tvmissile_influencer_length = set_dvar_float_if_unset( "scr_spawn_tvmissile_influencer_length", "" + 3000, reset_dvars );
	ss.pegasus_influencer_score = set_dvar_float_if_unset( "scr_spawn_pegasus_influencer_score", "-250", reset_dvars );
	ss.pegasus_influencer_score_curve = set_dvar_if_unset( "scr_spawn_pegasus_influencer_score_curve", "linear", reset_dvars );
	ss.pegasus_influencer_radius = set_dvar_float_if_unset( "scr_spawn_pegasus_influencer_radius", "" + ( 20 * k_player_height ), reset_dvars );
	if ( !isDefined( ss.unifiedsideswitching ) )
	{
		ss.unifiedsideswitching = 1;
	}
	set_dvar_int_if_unset( "spawnsystem_allow_non_team_spawns", "0", reset_dvars );
	[[ level.gamemodespawndvars ]]( reset_dvars );
	if ( isDefined( level.levelspawndvars ) )
	{
		[[ level.levelspawndvars ]]( reset_dvars );
	}
	setspawnpointrandomvariation( ss.randomness_range );
}

level_use_unified_spawning( use )
{
}

onspawnplayer_unified( predictedspawn )
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
/#
	if ( getDvarInt( "scr_spawn_point_test_mode" ) != 0 )
	{
		spawn_point = get_debug_spawnpoint( self );
		self spawn( spawn_point.origin, spawn_point.angles );
		return;
#/
	}
	use_new_spawn_system = 0;
	initial_spawn = 1;
	if ( isDefined( self.uspawn_already_spawned ) )
	{
		initial_spawn = !self.uspawn_already_spawned;
	}
	if ( level.usestartspawns )
	{
		use_new_spawn_system = 0;
	}
	if ( level.gametype == "sd" )
	{
		use_new_spawn_system = 0;
	}
	set_dvar_if_unset( "scr_spawn_force_unified", "0" );
	[[ level.onspawnplayer ]]( predictedspawn );
	if ( !predictedspawn )
	{
		self.uspawn_already_spawned = 1;
	}
	return;
}

getspawnpoint( player_entity, predictedspawn )
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
	if ( level.teambased )
	{
		point_team = player_entity.pers[ "team" ];
		influencer_team = player_entity.pers[ "team" ];
	}
	else
	{
		point_team = "free";
		influencer_team = "free";
	}
	if ( level.teambased && isDefined( game[ "switchedsides" ] ) && game[ "switchedsides" ] && level.spawnsystem.unifiedsideswitching )
	{
		point_team = getotherteam( point_team );
	}
	best_spawn_entity = get_best_spawnpoint( point_team, influencer_team, player_entity, predictedspawn );
	if ( !predictedspawn )
	{
		player_entity.last_spawn_origin = best_spawn_entity.origin;
	}
	return best_spawn_entity;
}

get_debug_spawnpoint( player )
{
	if ( level.teambased )
	{
		team = player.pers[ "team" ];
	}
	else
	{
		team = "free";
	}
	index = level.test_spawn_point_index;
	level.test_spawn_point_index++;
	if ( team == "free" )
	{
		spawn_counts = 0;
		_a1409 = level.teams;
		_k1409 = getFirstArrayKey( _a1409 );
		while ( isDefined( _k1409 ) )
		{
			team = _a1409[ _k1409 ];
			spawn_counts += level.unified_spawn_points[ team ].a.size;
			_k1409 = getNextArrayKey( _a1409, _k1409 );
		}
		if ( level.test_spawn_point_index >= spawn_counts )
		{
			level.test_spawn_point_index = 0;
		}
		count = 0;
		_a1420 = level.teams;
		_k1420 = getFirstArrayKey( _a1420 );
		while ( isDefined( _k1420 ) )
		{
			team = _a1420[ _k1420 ];
			size = level.unified_spawn_points[ team ].a.size;
			if ( level.test_spawn_point_index < ( count + size ) )
			{
				return level.unified_spawn_points[ team ].a[ level.test_spawn_point_index - count ];
			}
			count += size;
			_k1420 = getNextArrayKey( _a1420, _k1420 );
		}
	}
	else if ( level.test_spawn_point_index >= level.unified_spawn_points[ team ].a.size )
	{
		level.test_spawn_point_index = 0;
	}
	return level.unified_spawn_points[ team ].a[ level.test_spawn_point_index ];
}

get_best_spawnpoint( point_team, influencer_team, player, predictedspawn )
{
	if ( level.teambased )
	{
		vis_team_mask = getotherteamsmask( player.pers[ "team" ] );
	}
	else
	{
		vis_team_mask = level.spawnsystem.ispawn_teammask_free;
	}
	scored_spawn_points = getsortedspawnpoints( point_team, influencer_team, vis_team_mask, player, predictedspawn );
/#
	assert( scored_spawn_points.size > 0 );
#/
/#
	assert( scored_spawn_points.size == 1 );
#/
	if ( !predictedspawn )
	{
		bbprint( "mpspawnpointsused", "reason %s x %d y %d z %d", "point used", scored_spawn_points[ 0 ].origin );
	}
	return scored_spawn_points[ 0 ];
}

gatherspawnentities( player_team )
{
	if ( !isDefined( level.unified_spawn_points ) )
	{
		level.unified_spawn_points = [];
	}
	else
	{
		if ( isDefined( level.unified_spawn_points[ player_team ] ) )
		{
			return level.unified_spawn_points[ player_team ];
		}
	}
	spawn_entities_s = spawn_array_struct();
	spawn_entities_s.a = getentarray( "mp_uspawn_point", "classname" );
	if ( !isDefined( spawn_entities_s.a ) )
	{
		spawn_entities_s.a = [];
	}
	legacy_spawn_points = maps/mp/gametypes_zm/_spawnlogic::getteamspawnpoints( player_team );
	legacy_spawn_index = 0;
	while ( legacy_spawn_index < legacy_spawn_points.size )
	{
		spawn_entities_s.a[ spawn_entities_s.a.size ] = legacy_spawn_points[ legacy_spawn_index ];
		legacy_spawn_index++;
	}
	level.unified_spawn_points[ player_team ] = spawn_entities_s;
	return spawn_entities_s;
}

is_hardcore()
{
	if ( isDefined( level.hardcoremode ) )
	{
		return level.hardcoremode;
	}
}

teams_have_enmity( team1, team2 )
{
	if ( isDefined( team1 ) || !isDefined( team2 ) && level.gametype == "dm" )
	{
		return 1;
	}
	if ( team1 != "neutral" && team2 != "neutral" )
	{
		return team1 != team2;
	}
}

remove_unused_spawn_entities()
{
	spawn_entity_types = [];
	spawn_entity_types[ spawn_entity_types.size ] = "mp_dm_spawn";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_tdm_spawn_allies_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_tdm_spawn_axis_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_tdm_spawn";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_ctf_spawn_allies_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_ctf_spawn_axis_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_ctf_spawn_allies";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_ctf_spawn_axis";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_dom_spawn_allies_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_dom_spawn_axis_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_dom_spawn";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_sab_spawn_allies_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_sab_spawn_axis_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_sab_spawn_allies";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_sab_spawn_axis";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_sd_spawn_attacker";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_sd_spawn_defender";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_twar_spawn_axis_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_twar_spawn_allies_start";
	spawn_entity_types[ spawn_entity_types.size ] = "mp_twar_spawn";
	i = 0;
	while ( i < spawn_entity_types.size )
	{
		if ( spawn_point_class_name_being_used( spawn_entity_types[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			spawnpoints = maps/mp/gametypes_zm/_spawnlogic::getspawnpointarray( spawn_entity_types[ i ] );
			delete_all_spawns( spawnpoints );
		}
		i++;
	}
}

delete_all_spawns( spawnpoints )
{
	i = 0;
	while ( i < spawnpoints.size )
	{
		spawnpoints[ i ] delete();
		i++;
	}
}

spawn_point_class_name_being_used( name )
{
	if ( !isDefined( level.spawn_point_class_names ) )
	{
		return 0;
	}
	i = 0;
	while ( i < level.spawn_point_class_names.size )
	{
		if ( level.spawn_point_class_names[ i ] == name )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

codecallback_updatespawnpoints()
{
	_a1624 = level.teams;
	_k1624 = getFirstArrayKey( _a1624 );
	while ( isDefined( _k1624 ) )
	{
		team = _a1624[ _k1624 ];
		maps/mp/gametypes_zm/_spawnlogic::rebuildspawnpoints( team );
		_k1624 = getNextArrayKey( _a1624, _k1624 );
	}
	level.unified_spawn_points = undefined;
	updateallspawnpoints();
}

initialspawnprotection( specialtyname, spawnmonitorspeed )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( level.spawnprotectiontime ) || level.spawnprotectiontime == 0 )
	{
		return;
	}
	if ( specialtyname == "specialty_nottargetedbyairsupport" )
	{
		self.specialty_nottargetedbyairsupport = 1;
		wait level.spawnprotectiontime;
		self.specialty_nottargetedbyairsupport = undefined;
	}
	else
	{
		if ( !self hasperk( specialtyname ) )
		{
			self setperk( specialtyname );
			wait level.spawnprotectiontime;
			self unsetperk( specialtyname );
		}
	}
}
