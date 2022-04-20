#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "thundergun_zm" ) )
	{
		return;
	}
	level._effect[ "thundergun_viewmodel_power_cell1" ] = loadfx( "weapon/thunder_gun/fx_thundergun_power_cell_view1" );
	level._effect[ "thundergun_viewmodel_power_cell2" ] = loadfx( "weapon/thunder_gun/fx_thundergun_power_cell_view2" );
	level._effect[ "thundergun_viewmodel_power_cell3" ] = loadfx( "weapon/thunder_gun/fx_thundergun_power_cell_view3" );
	level._effect[ "thundergun_viewmodel_steam" ] = loadfx( "weapon/thunder_gun/fx_thundergun_steam_view" );
	level._effect[ "thundergun_viewmodel_power_cell1_upgraded" ] = loadfx( "weapon/thunder_gun/fx_thundergun_power_cell_view1" );
	level._effect[ "thundergun_viewmodel_power_cell2_upgraded" ] = loadfx( "weapon/thunder_gun/fx_thundergun_power_cell_view2" );
	level._effect[ "thundergun_viewmodel_power_cell3_upgraded" ] = loadfx( "weapon/thunder_gun/fx_thundergun_power_cell_view3" );
	level._effect[ "thundergun_viewmodel_steam_upgraded" ] = loadfx( "weapon/thunder_gun/fx_thundergun_steam_view" );
	level._effect[ "thundergun_knockdown_ground" ] = loadfx( "weapon/thunder_gun/fx_thundergun_knockback_ground" );
	level._effect[ "thundergun_smoke_cloud" ] = loadfx( "weapon/thunder_gun/fx_thundergun_smoke_cloud" );
	set_zombie_var( "thundergun_cylinder_radius", 180 );
	set_zombie_var( "thundergun_fling_range", 480 );
	set_zombie_var( "thundergun_gib_range", 900 );
	set_zombie_var( "thundergun_gib_damage", 75 );
	set_zombie_var( "thundergun_knockdown_range", 1200 );
	set_zombie_var( "thundergun_knockdown_damage", 15 );
	level.thundergun_gib_refs = [];
	level.thundergun_gib_refs[ level.thundergun_gib_refs.size ] = "guts";
	level.thundergun_gib_refs[ level.thundergun_gib_refs.size ] = "right_arm";
	level.thundergun_gib_refs[ level.thundergun_gib_refs.size ] = "left_arm";
	level.basic_zombie_thundergun_knockdown = ::zombie_knockdown;
/#
	level thread thundergun_devgui_dvar_think();
#/
	onplayerconnect_callback( ::thundergun_on_player_connect );
}

thundergun_devgui_dvar_think()
{
/#
	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "thundergun_zm" ) )
	{
		return;
	}
	setdvar( "scr_thundergun_cylinder_radius", level.zombie_vars[ "thundergun_cylinder_radius" ] );
	setdvar( "scr_thundergun_fling_range", level.zombie_vars[ "thundergun_fling_range" ] );
	setdvar( "scr_thundergun_gib_range", level.zombie_vars[ "thundergun_gib_range" ] );
	setdvar( "scr_thundergun_gib_damage", level.zombie_vars[ "thundergun_gib_damage" ] );
	setdvar( "scr_thundergun_knockdown_range", level.zombie_vars[ "thundergun_knockdown_range" ] );
	setdvar( "scr_thundergun_knockdown_damage", level.zombie_vars[ "thundergun_knockdown_damage" ] );
	for ( ;; )
	{
		level.zombie_vars[ "thundergun_cylinder_radius" ] = getDvarInt( "scr_thundergun_cylinder_radius" );
		level.zombie_vars[ "thundergun_fling_range" ] = getDvarInt( "scr_thundergun_fling_range" );
		level.zombie_vars[ "thundergun_gib_range" ] = getDvarInt( "scr_thundergun_gib_range" );
		level.zombie_vars[ "thundergun_gib_damage" ] = getDvarInt( "scr_thundergun_gib_damage" );
		level.zombie_vars[ "thundergun_knockdown_range" ] = getDvarInt( "scr_thundergun_knockdown_range" );
		level.zombie_vars[ "thundergun_knockdown_damage" ] = getDvarInt( "scr_thundergun_knockdown_damage" );
		wait 0,5;
#/
	}
}

thundergun_on_player_connect()
{
	self thread wait_for_thundergun_fired();
}

wait_for_thundergun_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	for ( ;; )
	{
		self waittill( "weapon_fired" );
		currentweapon = self getcurrentweapon();
		if ( currentweapon == "thundergun_zm" || currentweapon == "thundergun_upgraded_zm" )
		{
			self thread thundergun_fired();
			view_pos = self gettagorigin( "tag_flash" ) - self getplayerviewheight();
			view_angles = self gettagangles( "tag_flash" );
			playfx( level._effect[ "thundergun_smoke_cloud" ], view_pos, anglesToForward( view_angles ), anglesToUp( view_angles ) );
		}
	}
}

thundergun_network_choke()
{
	level.thundergun_network_choke_count++;
	if ( level.thundergun_network_choke_count % 10 )
	{
		wait_network_frame();
		wait_network_frame();
		wait_network_frame();
	}
}

thundergun_fired()
{
	physicsexplosioncylinder( self.origin, 600, 240, 1 );
	if ( !isDefined( level.thundergun_knockdown_enemies ) )
	{
		level.thundergun_knockdown_enemies = [];
		level.thundergun_knockdown_gib = [];
		level.thundergun_fling_enemies = [];
		level.thundergun_fling_vecs = [];
	}
	self thundergun_get_enemies_in_range();
	level.thundergun_network_choke_count = 0;
	i = 0;
	while ( i < level.thundergun_fling_enemies.size )
	{
		thundergun_network_choke();
		level.thundergun_fling_enemies[ i ] thread thundergun_fling_zombie( self, level.thundergun_fling_vecs[ i ], i );
		i++;
	}
	i = 0;
	while ( i < level.thundergun_knockdown_enemies.size )
	{
		thundergun_network_choke();
		level.thundergun_knockdown_enemies[ i ] thread thundergun_knockdown_zombie( self, level.thundergun_knockdown_gib[ i ] );
		i++;
	}
	level.thundergun_knockdown_enemies = [];
	level.thundergun_knockdown_gib = [];
	level.thundergun_fling_enemies = [];
	level.thundergun_fling_vecs = [];
}

thundergun_get_enemies_in_range()
{
	view_pos = self getweaponmuzzlepoint();
	zombies = get_array_of_closest( view_pos, get_round_enemy_array(), undefined, undefined, level.zombie_vars[ "thundergun_knockdown_range" ] );
	if ( !isDefined( zombies ) )
	{
		return;
	}
	knockdown_range_squared = level.zombie_vars[ "thundergun_knockdown_range" ] * level.zombie_vars[ "thundergun_knockdown_range" ];
	gib_range_squared = level.zombie_vars[ "thundergun_gib_range" ] * level.zombie_vars[ "thundergun_gib_range" ];
	fling_range_squared = level.zombie_vars[ "thundergun_fling_range" ] * level.zombie_vars[ "thundergun_fling_range" ];
	cylinder_radius_squared = level.zombie_vars[ "thundergun_cylinder_radius" ] * level.zombie_vars[ "thundergun_cylinder_radius" ];
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorScale( forward_view_angles, level.zombie_vars[ "thundergun_knockdown_range" ] );
/#
	if ( getDvarInt( #"AAC84AD6" ) == 2 )
	{
		near_circle_pos = view_pos + vectorScale( forward_view_angles, 2 );
		circle( near_circle_pos, level.zombie_vars[ "thundergun_cylinder_radius" ], ( 0, 0, 1 ), 0, 0, 100 );
		line( near_circle_pos, end_pos, ( 0, 0, 1 ), 1, 0, 100 );
		circle( end_pos, level.zombie_vars[ "thundergun_cylinder_radius" ], ( 0, 0, 1 ), 0, 0, 100 );
#/
	}
	i = 0;
	while ( i < zombies.size )
	{
		if ( !isDefined( zombies[ i ] ) || !isalive( zombies[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			test_origin = zombies[ i ] getcentroid();
			test_range_squared = distancesquared( view_pos, test_origin );
			if ( test_range_squared > knockdown_range_squared )
			{
				zombies[ i ] thundergun_debug_print( "range", ( 0, 0, 1 ) );
				return;
			}
			normal = vectornormalize( test_origin - view_pos );
			dot = vectordot( forward_view_angles, normal );
			if ( dot <= 0 )
			{
				zombies[ i ] thundergun_debug_print( "dot", ( 0, 0, 1 ) );
				i++;
				continue;
			}
			else radial_origin = pointonsegmentnearesttopoint( view_pos, end_pos, test_origin );
			if ( distancesquared( test_origin, radial_origin ) > cylinder_radius_squared )
			{
				zombies[ i ] thundergun_debug_print( "cylinder", ( 0, 0, 1 ) );
				i++;
				continue;
			}
			else if ( zombies[ i ] damageconetrace( view_pos, self ) == 0 )
			{
				zombies[ i ] thundergun_debug_print( "cone", ( 0, 0, 1 ) );
				i++;
				continue;
			}
			else if ( test_range_squared < fling_range_squared )
			{
				level.thundergun_fling_enemies[ level.thundergun_fling_enemies.size ] = zombies[ i ];
				dist_mult = ( fling_range_squared - test_range_squared ) / fling_range_squared;
				fling_vec = vectornormalize( test_origin - view_pos );
				if ( test_range_squared >= 5000 )
				{
					fling_vec += vectornormalize( test_origin - radial_origin );
				}
				fling_vec = ( fling_vec[ 0 ], fling_vec[ 1 ], abs( fling_vec[ 2 ] ) );
				fling_vec = vectorScale( fling_vec, 100 + ( 100 * dist_mult ) );
				level.thundergun_fling_vecs[ level.thundergun_fling_vecs.size ] = fling_vec;
				zombies[ i ] thread setup_thundergun_vox( self, 1, 0, 0 );
				i++;
				continue;
			}
			else if ( test_range_squared < gib_range_squared )
			{
				level.thundergun_knockdown_enemies[ level.thundergun_knockdown_enemies.size ] = zombies[ i ];
				level.thundergun_knockdown_gib[ level.thundergun_knockdown_gib.size ] = 1;
				zombies[ i ] thread setup_thundergun_vox( self, 0, 1, 0 );
				i++;
				continue;
			}
			else
			{
				level.thundergun_knockdown_enemies[ level.thundergun_knockdown_enemies.size ] = zombies[ i ];
				level.thundergun_knockdown_gib[ level.thundergun_knockdown_gib.size ] = 0;
				zombies[ i ] thread setup_thundergun_vox( self, 0, 0, 1 );
			}
		}
		i++;
	}
}

thundergun_debug_print( msg, color )
{
/#
	if ( !getDvarInt( #"AAC84AD6" ) )
	{
		return;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	print3d( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), msg, color, 1, 1, 40 );
#/
}

thundergun_fling_zombie( player, fling_vec, index )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.thundergun_fling_func ) )
	{
		self [[ self.thundergun_fling_func ]]( player );
		return;
	}
	self dodamage( self.health + 666, player.origin, player );
	if ( self.health <= 0 )
	{
		points = 10;
		if ( !index )
		{
			points = maps/mp/zombies/_zm_score::get_zombie_death_player_points();
		}
		else
		{
			if ( index == 1 )
			{
				points = 30;
			}
		}
		player maps/mp/zombies/_zm_score::player_add_points( "thundergun_fling", points );
		self startragdoll();
		self launchragdoll( fling_vec );
		self.thundergun_death = 1;
	}
}

zombie_knockdown( player, gib )
{
	if ( gib && !self.gibbed )
	{
		self.a.gib_ref = random( level.thundergun_gib_refs );
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	damage = level.zombie_vars[ "thundergun_knockdown_damage" ];
	if ( isDefined( level.override_thundergun_damage_func ) )
	{
		self [[ level.override_thundergun_damage_func ]]( player, gib );
	}
	else
	{
		self.thundergun_handle_pain_notetracks = ::handle_thundergun_pain_notetracks;
		self dodamage( damage, player.origin, player );
	}
}

thundergun_knockdown_zombie( player, gib )
{
	self endon( "death" );
	playsoundatposition( "vox_thundergun_forcehit", self.origin );
	playsoundatposition( "wpn_thundergun_proj_impact", self.origin );
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.thundergun_knockdown_func ) )
	{
		self [[ self.thundergun_knockdown_func ]]( player, gib );
	}
	else
	{
		self dodamage( level.zombie_vars[ "thundergun_knockdown_damage" ], player.origin, player );
	}
	if ( gib )
	{
		self.a.gib_ref = random( level.thundergun_gib_refs );
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	self.thundergun_handle_pain_notetracks = ::handle_thundergun_pain_notetracks;
	self dodamage( level.zombie_vars[ "thundergun_knockdown_damage" ], player.origin, player );
	self playsound( "fly_thundergun_forcehit" );
}

handle_thundergun_pain_notetracks( note )
{
	if ( note == "zombie_knockdown_ground_impact" )
	{
		playfx( level._effect[ "thundergun_knockdown_ground" ], self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
		self playsound( "fly_thundergun_forcehit" );
	}
}

is_thundergun_damage()
{
	if ( isDefined( self.damageweapon ) && self.damageweapon != "thundergun_zm" && self.damageweapon == "thundergun_upgraded_zm" )
	{
		if ( self.damagemod != "MOD_GRENADE" )
		{
			return self.damagemod != "MOD_GRENADE_SPLASH";
		}
	}
}

enemy_killed_by_thundergun()
{
	if ( isDefined( self.thundergun_death ) )
	{
		return self.thundergun_death == 1;
	}
}

thundergun_sound_thread()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	for ( ;; )
	{
		result = self waittill_any_return( "grenade_fire", "death", "player_downed", "weapon_change", "grenade_pullback" );
		if ( !isDefined( result ) )
		{
			continue;
		}
		else if ( result != "weapon_change" && result == "grenade_fire" && self getcurrentweapon() == "thundergun_zm" )
		{
			self playloopsound( "tesla_idle", 0,25 );
			continue;
		}
		else
		{
			self notify( "weap_away" );
			self stoploopsound( 0,25 );
		}
	}
}

setup_thundergun_vox( player, fling, gib, knockdown )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( !fling || gib && knockdown )
	{
		if ( randomintrange( 1, 100 ) <= 25 )
		{
		}
	}
	if ( fling )
	{
		if ( randomintrange( 1, 100 ) <= 30 )
		{
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "thundergun" );
		}
	}
}
