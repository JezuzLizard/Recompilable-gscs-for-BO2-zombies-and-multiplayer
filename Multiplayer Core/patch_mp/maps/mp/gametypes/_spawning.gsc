// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( !isdefined( level.gamemodespawndvars ) )
        level.gamemodespawndvars = ::default_gamemodespawndvars;

    level init_spawn_system();
    level.recently_deceased = [];

    foreach ( team in level.teams )
        level.recently_deceased[team] = spawn_array_struct();

    level thread onplayerconnect();

    if ( getdvar( _hash_AD6C19FE ) == "" )
        level.spawn_visibility_check_max = 20;
    else
        level.spawn_visibility_check_max = getdvarint( _hash_AD6C19FE );

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
    spawnsystem.ispawn_teammask["free"] = spawnsystem.ispawn_teammask_free;
    all = spawnsystem.ispawn_teammask_free;
    count = 1;

    foreach ( team in level.teams )
    {
        spawnsystem.ispawn_teammask[team] = 1 << count;
        all |= spawnsystem.ispawn_teammask[team];
        count++;
    }

    spawnsystem.ispawn_teammask["all"] = all;
}

onplayerconnect()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "connecting", player );

        player setentertime( gettime() );
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

    for (;;)
    {
        self waittill( "spawned_player" );

        self maps\mp\killstreaks\_airsupport::clearmonitoredspeed();
        self thread initialspawnprotection();
        self thread monitorgpsjammer();

        if ( isdefined( self.pers["hasRadar"] ) && self.pers["hasRadar"] )
            self.hasspyplane = 1;

        self enable_player_influencers( 1 );
        self thread ondeath();
    }
}

monitorgpsjammer()
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( self hasperk( "specialty_gpsjammer" ) == 0 )
        return;

    self gpsjammeractive();
    graceperiods = getdvarintdefault( "perk_gpsjammer_graceperiods", 4 );
    minspeed = getdvarintdefault( "perk_gpsjammer_min_speed", 100 );
    mindistance = getdvarintdefault( "perk_gpsjammer_min_distance", 10 );
    timeperiod = getdvarintdefault( "perk_gpsjammer_time_period", 200 );
    timeperiodsec = timeperiod / 1000;
    minspeedsq = minspeed * minspeed;
    mindistancesq = mindistance * mindistance;

    if ( minspeedsq == 0 )
        return;

/#
    assert( timeperiodsec >= 0.05 );
#/

    if ( timeperiodsec < 0.05 )
        return;

    hasperk = 1;
    statechange = 0;
    faileddistancecheck = 0;
    currentfailcount = 0;
    timepassed = 0;
    timesincedistancecheck = 0;
    previousorigin = self.origin;
    gpsjammerprotection = 0;

    while ( true )
    {
/#
        graceperiods = getdvarintdefault( "perk_gpsjammer_graceperiods", graceperiods );
        minspeed = getdvarintdefault( "perk_gpsjammer_min_speed", minspeed );
        mindistance = getdvarintdefault( "perk_gpsjammer_min_distance", mindistance );
        timeperiod = getdvarintdefault( "perk_gpsjammer_time_period", timeperiod );
        timeperiodsec = timeperiod / 1000;
        minspeedsq = minspeed * minspeed;
        mindistancesq = mindistance * mindistance;
#/
        gpsjammerprotection = 0;

        if ( isusingremote() || is_true( self.isplanting ) || is_true( self.isdefusing ) )
            gpsjammerprotection = 1;
        else
        {
            if ( timesincedistancecheck > 1 )
            {
                timesincedistancecheck = 0;

                if ( distancesquared( previousorigin, self.origin ) < mindistancesq )
                    faileddistancecheck = 1;
                else
                    faileddistancecheck = 0;

                previousorigin = self.origin;
            }

            velocity = self getvelocity();
            speedsq = lengthsquared( velocity );

            if ( speedsq > minspeedsq && faileddistancecheck == 0 )
                gpsjammerprotection = 1;
        }

        if ( gpsjammerprotection == 1 )
        {
            currentfailcount = 0;

            if ( hasperk == 0 )
            {
                statechange = 0;
                hasperk = 1;
                self gpsjammeractive();
            }
        }
        else
        {
            currentfailcount++;

            if ( hasperk == 1 && currentfailcount >= graceperiods )
            {
                statechange = 1;
                hasperk = 0;
                self gpsjammerinactive();
            }
        }

        if ( statechange == 1 )
            level notify( "radar_status_change" );

        timesincedistancecheck += timeperiodsec;
        wait( timeperiodsec );
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

    while ( true )
    {
        self waittill( "joined_team" );

        self player_influencers_set_team();
        wait 0.05;
    }
}

ongrenadethrow()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    while ( true )
    {
        self waittill( "grenade_fire", grenade, weaponname );

        level thread create_grenade_influencers( self.pers["team"], weaponname, grenade );
        wait 0.05;
    }
}

ondisconnect()
{
    level endon( "game_ended" );

    self waittill( "disconnect" );
}

get_score_curve_index( curve )
{
    switch ( curve )
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
    assert( !isdefined( self.influencer_enemy_sphere ) );
#/
/#
    assert( !isdefined( self.influencer_weapon_cylinder ) );
#/
/#
    assert( !level.teambased || !isdefined( self.influencer_friendly_sphere ) );
#/
/#
    assert( !level.teambased || !isdefined( self.influencer_friendly_cylinder ) );
#/

    if ( !level.teambased )
    {
        team_mask = level.spawnsystem.ispawn_teammask_free;
        other_team_mask = level.spawnsystem.ispawn_teammask_free;
        weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
    }
    else if ( isdefined( self.pers["team"] ) )
    {
        team = self.pers["team"];
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
        weapon_team_mask |= team_mask;

    angles = self.angles;
    origin = self.origin;
    up = ( 0, 0, 1 );
    forward = ( 1, 0, 0 );
    cylinder_forward = up;
    cylinder_up = forward;
    self.influencer_enemy_sphere = addsphereinfluencer( level.spawnsystem.einfluencer_type_player, origin, level.spawnsystem.enemy_influencer_radius, level.spawnsystem.enemy_influencer_score, other_team_mask, "enemy,r,s", get_score_curve_index( level.spawnsystem.enemy_influencer_score_curve ), 0, self );

    if ( level.teambased )
    {
        cylinder_up = -1.0 * forward;
        self.influencer_friendly_sphere = addsphereinfluencer( level.spawnsystem.einfluencer_type_player, origin, level.spawnsystem.friend_weak_influencer_radius, level.spawnsystem.friend_weak_influencer_score, team_mask, "friend_weak,r,s", get_score_curve_index( level.spawnsystem.friend_weak_influencer_score_curve ), 0, self );
    }

    self.spawn_influencers_created = 1;

    if ( !isdefined( self.pers["team"] ) || self.pers["team"] == "spectator" )
        self enable_player_influencers( 0 );
}

remove_player_influencers()
{
    if ( level.teambased && isdefined( self.influencer_friendly_sphere ) )
    {
        removeinfluencer( self.influencer_friendly_sphere );
        self.influencer_friendly_sphere = undefined;
    }

    if ( level.teambased && isdefined( self.influencer_friendly_cylinder ) )
    {
        removeinfluencer( self.influencer_friendly_cylinder );
        self.influencer_friendly_cylinder = undefined;
    }

    if ( isdefined( self.influencer_enemy_sphere ) )
    {
        removeinfluencer( self.influencer_enemy_sphere );
        self.influencer_enemy_sphere = undefined;
    }

    if ( isdefined( self.influencer_weapon_cylinder ) )
    {
        removeinfluencer( self.influencer_weapon_cylinder );
        self.influencer_weapon_cylinder = undefined;
    }
}

enable_player_influencers( enabled )
{
    if ( !isdefined( self.spawn_influencers_created ) )
        self create_player_influencers();

    if ( isdefined( self.influencer_friendly_sphere ) )
        enableinfluencer( self.influencer_friendly_sphere, enabled );

    if ( isdefined( self.influencer_friendly_cylinder ) )
        enableinfluencer( self.influencer_friendly_cylinder, enabled );

    if ( isdefined( self.influencer_enemy_sphere ) )
        enableinfluencer( self.influencer_enemy_sphere, enabled );

    if ( isdefined( self.influencer_weapon_cylinder ) )
        enableinfluencer( self.influencer_weapon_cylinder, enabled );
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
        team = self.pers["team"];
        team_mask = getteammask( team );
        other_team_mask = getotherteamsmask( team );
        weapon_team_mask = getotherteamsmask( team );
    }

    if ( level.friendlyfire != 0 && level.teambased )
        weapon_team_mask |= team_mask;

    if ( isdefined( self.influencer_friendly_sphere ) )
        setinfluencerteammask( self.influencer_friendly_sphere, team_mask );

    if ( isdefined( self.influencer_friendly_cylinder ) )
        setinfluencerteammask( self.influencer_friendly_cylinder, team_mask );

    if ( isdefined( self.influencer_enemy_sphere ) )
        setinfluencerteammask( self.influencer_enemy_sphere, other_team_mask );

    if ( isdefined( self.influencer_weapon_cylinder ) )
        setinfluencerteammask( self.influencer_weapon_cylinder, weapon_team_mask );
}

create_body_influencers()
{
    if ( level.teambased )
        team_mask = getteammask( self.pers["team"] );
    else
        team_mask = level.spawnsystem.ispawn_teammask_free;

    addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.dead_friend_influencer_radius, level.spawnsystem.dead_friend_influencer_score, team_mask, "dead_friend,r,s", get_score_curve_index( level.spawnsystem.dead_friend_influencer_score_curve ), level.spawnsystem.dead_friend_influencer_timeout_seconds );
}

create_grenade_influencers( parent_team, weaponname, grenade )
{
    pixbeginevent( "create_grenade_influencers" );

    if ( !level.teambased )
        weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
    {
        weapon_team_mask = getotherteamsmask( parent_team );

        if ( level.friendlyfire )
            weapon_team_mask |= getteammask( parent_team );
    }

    if ( issubstr( weaponname, "napalmblob" ) || issubstr( weaponname, "gl_" ) )
    {
        pixendevent();
        return;
    }

    timeout = 0;

    if ( weaponname == "tabun_gas_mp" )
        timeout = 7.0;

    if ( isdefined( grenade.origin ) )
    {
        if ( weaponname == "claymore_mp" || weaponname == "bouncingbetty_mp" )
            addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, grenade.origin, level.spawnsystem.claymore_influencer_radius, level.spawnsystem.claymore_influencer_score, weapon_team_mask, "claymore,r,s", get_score_curve_index( level.spawnsystem.claymore_influencer_score_curve ), timeout, grenade );
        else
            addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, grenade.origin, level.spawnsystem.grenade_influencer_radius, level.spawnsystem.grenade_influencer_score, weapon_team_mask, "grenade,r,s", get_score_curve_index( level.spawnsystem.grenade_influencer_score_curve ), timeout, grenade );
    }

    pixendevent();
}

create_napalm_fire_influencers( point, direction, parent_team, duration )
{
    timeout = duration;
    weapon_team_mask = 0;
    offset = vectorscale( anglestoforward( direction ), 1100 );
    addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point + 2.0 * offset, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
    addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point + offset, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
    addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
    addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, point - offset, level.spawnsystem.napalm_influencer_radius, level.spawnsystem.napalm_influencer_score, weapon_team_mask, "napalm,r,s", get_score_curve_index( level.spawnsystem.napalm_influencer_score_curve ), timeout );
}

create_auto_turret_influencer( point, parent_team, angles )
{
    if ( !level.teambased )
        weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        weapon_team_mask = getotherteamsmask( parent_team );

    projected_point = point + vectorscale( anglestoforward( angles ), level.spawnsystem.auto_turret_influencer_radius * 0.7 );
    influencerid = addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, projected_point, level.spawnsystem.auto_turret_influencer_radius, level.spawnsystem.auto_turret_influencer_score, weapon_team_mask, "auto_turret,r,s", get_score_curve_index( level.spawnsystem.auto_turret_influencer_score_curve ) );
    return influencerid;
}

create_auto_turret_influencer_close( point, parent_team, angles )
{
    if ( !level.teambased )
        weapon_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        weapon_team_mask = getotherteamsmask( parent_team );

    projected_point = point + vectorscale( anglestoforward( angles ), level.spawnsystem.auto_turret_influencer_close_radius * 0.7 );
    influencerid = addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, projected_point, level.spawnsystem.auto_turret_influencer_close_radius, level.spawnsystem.auto_turret_influencer_close_score, weapon_team_mask, "auto_turret_close,r,s", get_score_curve_index( level.spawnsystem.auto_turret_influencer_close_score_curve ) );
    return influencerid;
}

create_dog_influencers()
{
    if ( !level.teambased )
        dog_enemy_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        dog_enemy_team_mask = getotherteamsmask( self.aiteam );

    addsphereinfluencer( level.spawnsystem.einfluencer_type_dog, self.origin, level.spawnsystem.dog_influencer_radius, level.spawnsystem.dog_influencer_score, dog_enemy_team_mask, "dog,r,s", get_score_curve_index( level.spawnsystem.dog_influencer_score_curve ), 0, self );
}

create_helicopter_influencers( parent_team )
{
    if ( !level.teambased )
        team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        team_mask = getotherteamsmask( parent_team );

    self.influencer_helicopter_cylinder = addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, ( 0, 0, 0 ), ( 0, 0, 0 ), level.spawnsystem.helicopter_influencer_radius, level.spawnsystem.helicopter_influencer_length, level.spawnsystem.helicopter_influencer_score, team_mask, "helicopter,r,s", get_score_curve_index( level.spawnsystem.helicopter_influencer_score_curve ), 0, self );
}

remove_helicopter_influencers()
{
    if ( isdefined( self.influencer_helicopter_cylinder ) )
        removeinfluencer( self.influencer_helicopter_cylinder );

    self.influencer_helicopter_cylinder = undefined;
}

create_tvmissile_influencers( parent_team )
{
    if ( !level.teambased || is_hardcore() )
        team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        team_mask = getotherteamsmask( parent_team );

    self.influencer_tvmissile_cylinder = addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, ( 0, 0, 0 ), ( 0, 0, 0 ), level.spawnsystem.tvmissile_influencer_radius, level.spawnsystem.tvmissile_influencer_length, level.spawnsystem.tvmissile_influencer_score, team_mask, "tvmissile,r,s", get_score_curve_index( level.spawnsystem.tvmissile_influencer_score_curve ), 0, self );
}

remove_tvmissile_influencers()
{
    if ( isdefined( self.influencer_tvmissile_cylinder ) )
        removeinfluencer( self.influencer_tvmissile_cylinder );

    self.influencer_tvmissile_cylinder = undefined;
}

create_artillery_influencers( point, radius )
{
    weapon_team_mask = 0;

    if ( radius < 0 )
        thisradius = level.spawnsystem.artillery_influencer_radius;
    else
        thisradius = radius;

    return addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, point + vectorscale( ( 0, 0, -1 ), 2000.0 ), ( 1, 0, 0 ), ( 0, 0, 1 ), thisradius, 5000, level.spawnsystem.artillery_influencer_score, weapon_team_mask, "artillery,s,r", get_score_curve_index( level.spawnsystem.artillery_influencer_score_curve ), 7 );
}

create_vehicle_influencers()
{
    weapon_team_mask = 0;
    vehicleradius = 144;
    cylinderlength = level.spawnsystem.vehicle_influencer_lead_seconds;
    up = ( 0, 0, 1 );
    forward = ( 1, 0, 0 );
    cylinder_forward = up;
    cylinder_up = forward;
    return addcylinderinfluencer( level.spawnsystem.einfluencer_type_vehicle, self.origin, cylinder_forward, cylinder_up, vehicleradius, cylinderlength, level.spawnsystem.vehicle_influencer_score, weapon_team_mask, "vehicle,s", get_score_curve_index( level.spawnsystem.vehicle_influencer_score_curve ), 0, self );
}

create_rcbomb_influencers( team )
{
    if ( !level.teambased )
        other_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        other_team_mask = getotherteamsmask( team );

    return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.rcbomb_influencer_radius, level.spawnsystem.rcbomb_influencer_score, other_team_mask, "rcbomb,r,s", get_score_curve_index( level.spawnsystem.rcbomb_influencer_score_curve ), 0, self );
}

create_qrdrone_influencers( team )
{
    if ( !level.teambased )
        other_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        other_team_mask = getotherteamsmask( team );

    self.influencer_qrdrone_cylinder = addcylinderinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, ( 0, 0, 0 ), ( 0, 0, 0 ), level.spawnsystem.qrdrone_cylinder_influencer_radius, level.spawnsystem.qrdrone_cylinder_influencer_length, level.spawnsystem.qrdrone_cylinder_influencer_score, other_team_mask, "qrdrone_cyl,r,s", get_score_curve_index( level.spawnsystem.qrdrone_cylinder_influencer_score_curve ), 0, self );
    return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.qrdrone_influencer_radius, level.spawnsystem.qrdrone_influencer_score, other_team_mask, "qrdrone,r,s", get_score_curve_index( level.spawnsystem.qrdrone_influencer_score_curve ), 0, self );
}

create_aitank_influencers( team )
{
    if ( !level.teambased )
        other_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        other_team_mask = getotherteamsmask( team );

    return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, self.origin, level.spawnsystem.aitank_influencer_radius, level.spawnsystem.aitank_influencer_score, other_team_mask, "aitank,r,s", get_score_curve_index( level.spawnsystem.aitank_influencer_score_curve ), 0, self );
}

create_pegasus_influencer( origin, team )
{
    if ( !level.teambased )
        other_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        other_team_mask = getotherteamsmask( team );

    return addsphereinfluencer( level.spawnsystem.einfluencer_type_normal, origin, level.spawnsystem.pegasus_influencer_radius, level.spawnsystem.pegasus_influencer_score, other_team_mask, "pegasus,r,s", get_score_curve_index( level.spawnsystem.pegasus_influencer_score_curve ), 0 );
}

create_map_placed_influencers()
{
    staticinfluencerents = getentarray( "mp_uspawn_influencer", "classname" );

    for ( i = 0; i < staticinfluencerents.size; i++ )
    {
        staticinfluencerent = staticinfluencerents[i];

        if ( isdefined( staticinfluencerent.script_gameobjectname ) && staticinfluencerent.script_gameobjectname == "twar" )
            continue;

        create_map_placed_influencer( staticinfluencerent );
    }
}

create_map_placed_influencer( influencer_entity, optional_score_override )
{
    influencer_id = -1;

    if ( isdefined( influencer_entity.script_shape ) && isdefined( influencer_entity.script_score ) && isdefined( influencer_entity.script_score_curve ) )
    {
        switch ( influencer_entity.script_shape )
        {
            case "sphere":
                if ( isdefined( influencer_entity.radius ) )
                {
                    if ( isdefined( optional_score_override ) )
                        score = optional_score_override;
                    else
                        score = influencer_entity.script_score;

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
                if ( isdefined( influencer_entity.radius ) && isdefined( influencer_entity.height ) )
                {
                    if ( isdefined( optional_score_override ) )
                        score = optional_score_override;
                    else
                        score = influencer_entity.script_score;

                    influencer_id = addcylinderinfluencer( level.spawnsystem.einfluencer_type_game_mode, influencer_entity.origin, anglestoforward( influencer_entity.angles ), anglestoup( influencer_entity.angles ), influencer_entity.radius, influencer_entity.height, score, getteammask( influencer_entity.script_team ), "*map_defined", get_score_curve_index( influencer_entity.script_score_curve ) );
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
                assertmsg( "Unsupported script_shape value (\"" + influencer_entity.script_shape + "\") for unified spawning system static influencer.  Supported shapes are \"cylinder\" and \"sphere\"." );
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
        other_team_mask = level.spawnsystem.ispawn_teammask_free;
    else
        other_team_mask = getotherteamsmask( team );

    return addsphereinfluencer( level.spawnsystem.einfluencer_type_enemy_spawned, origin, level.spawnsystem.enemy_spawned_influencer_radius, level.spawnsystem.enemy_spawned_influencer_score, other_team_mask, "enemy_spawned,r,s", get_score_curve_index( level.spawnsystem.enemy_spawned_influencer_score_curve ), level.spawnsystem.enemy_spawned_influencer_timeout_seconds );
}

updateallspawnpoints()
{
    foreach ( team in level.teams )
        gatherspawnentities( team );

    clearspawnpoints();

    if ( level.teambased )
    {
        foreach ( team in level.teams )
            addspawnpoints( team, level.unified_spawn_points[team].a );
    }
    else
    {
        foreach ( team in level.teams )
            addspawnpoints( "free", level.unified_spawn_points[team].a );
    }

    remove_unused_spawn_entities();
}

initialize_player_spawning_dvars()
{
/#
    reset_dvars = 1;

    while ( true )
    {
        get_player_spawning_dvars( reset_dvars );
        reset_dvars = 0;
        wait 2;
    }
#/
}

get_player_spawning_dvars( reset_dvars )
{
    k_player_height = get_player_height();
    player_height_times_10 = "" + 10.0 * k_player_height;
    ss = level.spawnsystem;
    player_influencer_radius = 15.0 * k_player_height;
    player_influencer_score = 150.0;
    dog_influencer_radius = 10.0 * k_player_height;
    dog_influencer_score = 150.0;
    ss.script_based_influencer_system = set_dvar_int_if_unset( "scr_script_based_influencer_system", "0", reset_dvars );
    ss.randomness_range = set_dvar_float_if_unset( "scr_spawn_randomness_range", "0", reset_dvars );
    ss.objective_facing_bonus = set_dvar_float_if_unset( "scr_spawn_objective_facing_bonus", "0", reset_dvars );

    if ( level.multiteam )
    {
        ss.friend_weak_influencer_score = set_dvar_float_if_unset( "scr_spawn_friend_weak_influencer_score", "200", reset_dvars );
        ss.friend_weak_influencer_score_curve = set_dvar_if_unset( "scr_spawn_friend_weak_influencer_score_curve", "linear", reset_dvars );
        ss.friend_weak_influencer_radius = set_dvar_float_if_unset( "scr_spawn_friend_weak_influencer_radius", "1200", reset_dvars );
    }
    else
    {
        ss.friend_weak_influencer_score = set_dvar_float_if_unset( "scr_spawn_friend_weak_influencer_score", "20", reset_dvars );
        ss.friend_weak_influencer_score_curve = set_dvar_if_unset( "scr_spawn_friend_weak_influencer_score_curve", "linear", reset_dvars );
        ss.friend_weak_influencer_radius = set_dvar_float_if_unset( "scr_spawn_friend_weak_influencer_radius", "700", reset_dvars );
    }

    ss.enemy_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_score", "-150", reset_dvars );
    ss.enemy_influencer_score_curve = set_dvar_if_unset( "scr_spawn_enemy_influencer_score_curve", "linear", reset_dvars );
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
    ss.dead_friend_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_timeout_seconds", "20", reset_dvars );
    ss.dead_friend_influencer_count = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_count", "7", reset_dvars );
    ss.dead_friend_influencer_score = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_score", "-100", reset_dvars );
    ss.dead_friend_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dead_friend_influencer_score_curve", "steep", reset_dvars );
    ss.dead_friend_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_radius", player_height_times_10, reset_dvars );
    ss.vehicle_influencer_score = set_dvar_float_if_unset( "scr_spawn_vehicle_influencer_score", "-50", reset_dvars );
    ss.vehicle_influencer_score_curve = set_dvar_if_unset( "scr_spawn_vehicle_influencer_score_curve", "linear", reset_dvars );
    ss.vehicle_influencer_lead_seconds = set_dvar_float_if_unset( "scr_spawn_vehicle_influencer_lead_seconds", "3", reset_dvars );
    ss.dog_influencer_score = set_dvar_float_if_unset( "scr_spawn_dog_influencer_score", "-150", reset_dvars );
    ss.dog_influencer_score_curve = set_dvar_if_unset( "scr_spawn_dog_influencer_score_curve", "steep", reset_dvars );
    ss.dog_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dog_influencer_radius", "" + 15.0 * k_player_height, reset_dvars );
    ss.artillery_influencer_score = set_dvar_float_if_unset( "scr_spawn_artillery_influencer_score", "-600", reset_dvars );
    ss.artillery_influencer_score_curve = set_dvar_if_unset( "scr_spawn_artillery_influencer_score_curve", "linear", reset_dvars );
    ss.artillery_influencer_radius = set_dvar_float_if_unset( "scr_spawn_artillery_influencer_radius", "1200", reset_dvars );
    ss.grenade_influencer_score = set_dvar_float_if_unset( "scr_spawn_grenade_influencer_score", "-300", reset_dvars );
    ss.grenade_influencer_score_curve = set_dvar_if_unset( "scr_spawn_grenade_influencer_score_curve", "linear", reset_dvars );
    ss.grenade_influencer_radius = set_dvar_float_if_unset( "scr_spawn_grenade_influencer_radius", "" + 8.0 * k_player_height, reset_dvars );
    ss.grenade_endpoint_influencer_score = set_dvar_float_if_unset( "scr_spawn_grenade_endpoint_influencer_score", "-300", reset_dvars );
    ss.grenade_endpoint_influencer_score_curve = set_dvar_if_unset( "scr_spawn_grenade_endpoint_influencer_score_curve", "linear", reset_dvars );
    ss.grenade_endpoint_influencer_radius = set_dvar_float_if_unset( "scr_spawn_grenade_endpoint_influencer_radius", "" + 8.0 * k_player_height, reset_dvars );
    ss.claymore_influencer_score = set_dvar_float_if_unset( "scr_spawn_claymore_influencer_score", "-150", reset_dvars );
    ss.claymore_influencer_score_curve = set_dvar_if_unset( "scr_spawn_claymore_influencer_score_curve", "steep", reset_dvars );
    ss.claymore_influencer_radius = set_dvar_float_if_unset( "scr_spawn_claymore_influencer_radius", "" + 9.0 * k_player_height, reset_dvars );
    ss.napalm_influencer_score = set_dvar_float_if_unset( "scr_spawn_napalm_influencer_score", "-500", reset_dvars );
    ss.napalm_influencer_score_curve = set_dvar_if_unset( "scr_spawn_napalm_influencer_score_curve", "linear", reset_dvars );
    ss.napalm_influencer_radius = set_dvar_float_if_unset( "scr_spawn_napalm_influencer_radius", "" + 750, reset_dvars );
    ss.auto_turret_influencer_score = set_dvar_float_if_unset( "scr_spawn_auto_turret_influencer_score", "-650", reset_dvars );
    ss.auto_turret_influencer_score_curve = set_dvar_if_unset( "scr_spawn_auto_turret_influencer_score_curve", "linear", reset_dvars );
    ss.auto_turret_influencer_radius = set_dvar_float_if_unset( "scr_spawn_auto_turret_influencer_radius", "" + 1200, reset_dvars );
    ss.auto_turret_influencer_close_score = set_dvar_float_if_unset( "scr_spawn_auto_turret_influencer_close_score", "-250000", reset_dvars );
    ss.auto_turret_influencer_close_score_curve = set_dvar_if_unset( "scr_spawn_auto_turret_influencer_close_score_curve", "constant", reset_dvars );
    ss.auto_turret_influencer_close_radius = set_dvar_float_if_unset( "scr_spawn_auto_turret_influencer_close_radius", "" + 500, reset_dvars );
    ss.rcbomb_influencer_score = set_dvar_float_if_unset( "scr_spawn_rcbomb_influencer_score", "-200", reset_dvars );
    ss.rcbomb_influencer_score_curve = set_dvar_if_unset( "scr_spawn_rcbomb_influencer_score_curve", "steep", reset_dvars );
    ss.rcbomb_influencer_radius = set_dvar_float_if_unset( "scr_spawn_rcbomb_influencer_radius", "" + 25.0 * k_player_height, reset_dvars );
    ss.qrdrone_influencer_score = set_dvar_float_if_unset( "scr_spawn_qrdrone_influencer_score", "-200", reset_dvars );
    ss.qrdrone_influencer_score_curve = set_dvar_if_unset( "scr_spawn_qrdrone_influencer_score_curve", "steep", reset_dvars );
    ss.qrdrone_influencer_radius = set_dvar_float_if_unset( "scr_spawn_qrdrone_influencer_radius", "" + 25.0 * k_player_height, reset_dvars );
    ss.qrdrone_cylinder_influencer_score = set_dvar_float_if_unset( "scr_spawn_qrdrone_cylinder_influencer_score", "-300", reset_dvars );
    ss.qrdrone_cylinder_influencer_score_curve = set_dvar_if_unset( "scr_spawn_qrdrone_cylinder_influencer_score_curve", "linear", reset_dvars );
    ss.qrdrone_cylinder_influencer_radius = set_dvar_float_if_unset( "scr_spawn_qrdrone_cylinder_influencer_radius", 1000, reset_dvars );
    ss.qrdrone_cylinder_influencer_length = set_dvar_float_if_unset( "scr_spawn_qrdrone_cylinder_influencer_length", 2000, reset_dvars );
    ss.aitank_influencer_score = set_dvar_float_if_unset( "scr_spawn_aitank_influencer_score", "-200", reset_dvars );
    ss.aitank_influencer_score_curve = set_dvar_if_unset( "scr_spawn_aitank_influencer_score_curve", "linear", reset_dvars );
    ss.aitank_influencer_radius = set_dvar_float_if_unset( "scr_spawn_aitank_influencer_radius", "" + 25.0 * k_player_height, reset_dvars );
    ss.enemy_spawned_influencer_score_curve = set_dvar_if_unset( "scr_spawn_enemy_spawned_influencer_score_curve", "constant", reset_dvars );

    if ( level.multiteam )
    {
        ss.enemy_spawned_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_score", "-400", reset_dvars );
        ss.enemy_spawned_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_radius", "" + 1100, reset_dvars );
    }
    else if ( level.teambased )
    {
        ss.enemy_spawned_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_score", "-400", reset_dvars );
        ss.enemy_spawned_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_radius", "" + 1100, reset_dvars );
    }
    else
    {
        ss.enemy_spawned_influencer_score = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_score", "-400", reset_dvars );
        ss.enemy_spawned_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_radius", "" + 1000, reset_dvars );
    }

    ss.enemy_spawned_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_enemy_spawned_influencer_timeout_seconds", "7", reset_dvars );
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
    ss.pegasus_influencer_radius = set_dvar_float_if_unset( "scr_spawn_pegasus_influencer_radius", "" + 20.0 * k_player_height, reset_dvars );

    if ( !isdefined( ss.unifiedsideswitching ) )
        ss.unifiedsideswitching = 1;

    [[ level.gamemodespawndvars ]]( reset_dvars );

    if ( isdefined( level.levelspawndvars ) )
        [[ level.levelspawndvars ]]( reset_dvars );

    setspawnpointrandomvariation( ss.randomness_range );
}

level_use_unified_spawning( use )
{

}

onspawnplayer_unified( predictedspawn )
{
    if ( !isdefined( predictedspawn ) )
        predictedspawn = 0;

/#
    if ( getdvarint( "scr_spawn_point_test_mode" ) != 0 )
    {
        spawn_point = get_debug_spawnpoint( self );
        self spawn( spawn_point.origin, spawn_point.angles );
        return;
    }
#/
    use_new_spawn_system = 1;
    initial_spawn = 1;

    if ( isdefined( self.uspawn_already_spawned ) )
        initial_spawn = !self.uspawn_already_spawned;

    if ( level.usestartspawns )
        use_new_spawn_system = 0;

    if ( level.gametype == "sd" )
        use_new_spawn_system = 0;

    set_dvar_if_unset( "scr_spawn_force_unified", "0" );
    spawnoverride = self maps\mp\_tacticalinsertion::overridespawn( predictedspawn );

    if ( use_new_spawn_system || getdvarint( "scr_spawn_force_unified" ) != 0 )
    {
        if ( !spawnoverride )
        {
            spawn_point = getspawnpoint( self, predictedspawn );

            if ( isdefined( spawn_point ) )
            {
                if ( predictedspawn )
                    self predictspawnpoint( spawn_point.origin, spawn_point.angles );
                else
                {
                    create_enemy_spawned_influencers( spawn_point.origin, self.pers["team"] );
                    self spawn( spawn_point.origin, spawn_point.angles );
                }
            }
            else
            {
/#
                println( "ERROR: unable to locate a usable spawn point for player" );
#/
                maps\mp\gametypes\_callbacksetup::abortlevel();
            }
        }
        else if ( predictedspawn && isdefined( self.tacticalinsertion ) )
            self predictspawnpoint( self.tacticalinsertion.origin, self.tacticalinsertion.angles );

        if ( !predictedspawn )
        {
            self.lastspawntime = gettime();
            self enable_player_influencers( 1 );
        }
    }
    else if ( !spawnoverride )
        [[ level.onspawnplayer ]]( predictedspawn );

    if ( !predictedspawn )
        self.uspawn_already_spawned = 1;

    return;
}

getspawnpoint( player_entity, predictedspawn )
{
    if ( !isdefined( predictedspawn ) )
        predictedspawn = 0;

    if ( level.teambased )
    {
        point_team = player_entity.pers["team"];
        influencer_team = player_entity.pers["team"];
    }
    else
    {
        point_team = "free";
        influencer_team = "free";
    }

    if ( level.teambased && isdefined( game["switchedsides"] ) && game["switchedsides"] && level.spawnsystem.unifiedsideswitching )
        point_team = getotherteam( point_team );

    best_spawn_entity = get_best_spawnpoint( point_team, influencer_team, player_entity, predictedspawn );

    if ( !predictedspawn )
        player_entity.last_spawn_origin = best_spawn_entity.origin;

    return best_spawn_entity;
}

get_debug_spawnpoint( player )
{
    if ( level.teambased )
        team = player.pers["team"];
    else
        team = "free";

    index = level.test_spawn_point_index;
    level.test_spawn_point_index++;

    if ( team == "free" )
    {
        spawn_counts = 0;

        foreach ( team in level.teams )
            spawn_counts += level.unified_spawn_points[team].a.size;

        if ( level.test_spawn_point_index >= spawn_counts )
            level.test_spawn_point_index = 0;

        count = 0;

        foreach ( team in level.teams )
        {
            size = level.unified_spawn_points[team].a.size;

            if ( level.test_spawn_point_index < count + size )
                return level.unified_spawn_points[team].a[level.test_spawn_point_index - count];

            count += size;
        }
    }
    else
    {
        if ( level.test_spawn_point_index >= level.unified_spawn_points[team].a.size )
            level.test_spawn_point_index = 0;

        return level.unified_spawn_points[team].a[level.test_spawn_point_index];
    }
}

get_best_spawnpoint( point_team, influencer_team, player, predictedspawn )
{
    if ( level.teambased )
        vis_team_mask = getotherteamsmask( player.pers["team"] );
    else
        vis_team_mask = level.spawnsystem.ispawn_teammask_free;

    scored_spawn_points = getsortedspawnpoints( point_team, influencer_team, vis_team_mask, player, predictedspawn );
/#
    assert( scored_spawn_points.size > 0 );
#/
/#
    assert( scored_spawn_points.size == 1 );
#/

    if ( !predictedspawn )
        bbprint( "mpspawnpointsused", "reason %s x %d y %d z %d", "point used", scored_spawn_points[0].origin );

    return scored_spawn_points[0];
}

gatherspawnentities( player_team )
{
    if ( !isdefined( level.unified_spawn_points ) )
        level.unified_spawn_points = [];
    else if ( isdefined( level.unified_spawn_points[player_team] ) )
        return level.unified_spawn_points[player_team];

    spawn_entities_s = spawn_array_struct();
    spawn_entities_s.a = getentarray( "mp_uspawn_point", "classname" );

    if ( !isdefined( spawn_entities_s.a ) )
        spawn_entities_s.a = [];

    legacy_spawn_points = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( player_team );

    for ( legacy_spawn_index = 0; legacy_spawn_index < legacy_spawn_points.size; legacy_spawn_index++ )
        spawn_entities_s.a[spawn_entities_s.a.size] = legacy_spawn_points[legacy_spawn_index];

    level.unified_spawn_points[player_team] = spawn_entities_s;
    return spawn_entities_s;
}

is_hardcore()
{
    return isdefined( level.hardcoremode ) && level.hardcoremode;
}

teams_have_enmity( team1, team2 )
{
    if ( !isdefined( team1 ) || !isdefined( team2 ) || level.gametype == "dm" )
        return 1;

    return team1 != "neutral" && team2 != "neutral" && team1 != team2;
}

remove_unused_spawn_entities()
{
    spawn_entity_types = [];
    spawn_entity_types[spawn_entity_types.size] = "mp_dm_spawn";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_allies_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_axis_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_team1_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_team2_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_team3_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_team4_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_team5_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn_team6_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_tdm_spawn";
    spawn_entity_types[spawn_entity_types.size] = "mp_ctf_spawn_allies_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_ctf_spawn_axis_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_ctf_spawn_allies";
    spawn_entity_types[spawn_entity_types.size] = "mp_ctf_spawn_axis";
    spawn_entity_types[spawn_entity_types.size] = "mp_dom_spawn_allies_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_dom_spawn_axis_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_dom_spawn_flag_a";
    spawn_entity_types[spawn_entity_types.size] = "mp_dom_spawn_flag_b";
    spawn_entity_types[spawn_entity_types.size] = "mp_dom_spawn_flag_c";
    spawn_entity_types[spawn_entity_types.size] = "mp_dom_spawn";
    spawn_entity_types[spawn_entity_types.size] = "mp_sab_spawn_allies_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_sab_spawn_axis_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_sab_spawn_allies";
    spawn_entity_types[spawn_entity_types.size] = "mp_sab_spawn_axis";
    spawn_entity_types[spawn_entity_types.size] = "mp_sd_spawn_attacker";
    spawn_entity_types[spawn_entity_types.size] = "mp_sd_spawn_defender";
    spawn_entity_types[spawn_entity_types.size] = "mp_dem_spawn_attacker_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_dem_spawn_defender_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_dem_spawn_attackerOT_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_dem_spawn_defenderOT_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_dem_spawn_attacker";
    spawn_entity_types[spawn_entity_types.size] = "mp_dem_spawn_defender";
    spawn_entity_types[spawn_entity_types.size] = "mp_twar_spawn_axis_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_twar_spawn_allies_start";
    spawn_entity_types[spawn_entity_types.size] = "mp_twar_spawn";

    for ( i = 0; i < spawn_entity_types.size; i++ )
    {
        if ( spawn_point_class_name_being_used( spawn_entity_types[i] ) )
            continue;

        spawnpoints = maps\mp\gametypes\_spawnlogic::getspawnpointarray( spawn_entity_types[i] );
        delete_all_spawns( spawnpoints );
    }
}

delete_all_spawns( spawnpoints )
{
    for ( i = 0; i < spawnpoints.size; i++ )
        spawnpoints[i] delete();
}

spawn_point_class_name_being_used( name )
{
    if ( !isdefined( level.spawn_point_class_names ) )
        return false;

    for ( i = 0; i < level.spawn_point_class_names.size; i++ )
    {
        if ( level.spawn_point_class_names[i] == name )
            return true;
    }

    return false;
}

codecallback_updatespawnpoints()
{
    foreach ( team in level.teams )
        maps\mp\gametypes\_spawnlogic::rebuildspawnpoints( team );

    level.unified_spawn_points = undefined;
    updateallspawnpoints();
}

initialspawnprotection()
{
    self endon( "death" );
    self endon( "disconnect" );
    self thread maps\mp\killstreaks\_airsupport::monitorspeed( level.spawnprotectiontime );

    if ( !isdefined( level.spawnprotectiontime ) || level.spawnprotectiontime == 0 )
        return;

    self.specialty_nottargetedbyairsupport = 1;
    self spawnprotectionactive();
    wait( level.spawnprotectiontime );
    self spawnprotectioninactive();
    self.specialty_nottargetedbyairsupport = undefined;
}

getteamstartspawnname( team, spawnpointnamebase )
{
    spawn_point_team_name = team;

    if ( !level.multiteam && game["switchedsides"] )
        spawn_point_team_name = getotherteam( team );

    if ( level.multiteam )
    {
        if ( team == "axis" )
            spawn_point_team_name = "team1";
        else if ( team == "allies" )
            spawn_point_team_name = "team2";

        if ( !isoneround() )
        {
            number = int( getsubstr( spawn_point_team_name, 4, 5 ) ) - 1;
            number = ( number + game["roundsplayed"] ) % level.teams.size + 1;
            spawn_point_team_name = "team" + number;
        }
    }

    return spawnpointnamebase + "_" + spawn_point_team_name + "_start";
}

gettdmstartspawnname( team )
{
    return getteamstartspawnname( team, "mp_tdm_spawn" );
}
