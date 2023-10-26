// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\zombies\_zm_zonemgr;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_tomb_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zm_tomb_tank;
#include maps\mp\zombies\_zm_ai_mechz_dev;
#include maps\mp\zombies\_zm_ai_mechz;
#include maps\mp\zombies\_zm_ai_mechz_ft;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weap_riotshield_tomb;

#using_animtree("mechz_claw");

mechz_claw_detach()
{
    if ( isdefined( self.m_claw ) )
    {
        self.m_claw setanim( %ai_zombie_mech_grapple_arm_open_idle, 1, 0.2, 1 );

        if ( isdefined( self.m_claw.fx_ent ) )
            self.m_claw.fx_ent delete();

        self.m_claw unlink();
        self.m_claw physicslaunch( self.m_claw.origin, ( 0, 0, -1 ) );
        self.m_claw thread mechz_delayed_item_delete();
        self.m_claw = undefined;
    }

    if ( isdefined( self.m_claw_damage_trigger ) )
    {
        self.m_claw_damage_trigger unlink();
        self.m_claw_damage_trigger delete();
        self.m_claw_damage_trigger = undefined;
    }
}

mechz_claw_release( bopenclaw )
{
    self.explosive_dmg_taken_on_grab_start = undefined;

    if ( isdefined( self.e_grabbed ) )
    {
        if ( isplayer( self.e_grabbed ) )
        {
            self.e_grabbed setclientfieldtoplayer( "mechz_grab", 0 );
            self.e_grabbed allowcrouch( 1 );
            self.e_grabbed allowprone( 1 );
        }

        if ( !isdefined( self.e_grabbed._fall_down_anchor ) )
        {
            trace_start = self.e_grabbed.origin + vectorscale( ( 0, 0, 1 ), 70.0 );
            trace_end = self.e_grabbed.origin + vectorscale( ( 0, 0, -1 ), 500.0 );
            drop_trace = playerphysicstrace( trace_start, trace_end ) + vectorscale( ( 0, 0, 1 ), 24.0 );
            self.e_grabbed unlink();
            self.e_grabbed setorigin( drop_trace );
        }

        self.e_grabbed = undefined;

        if ( isdefined( bopenclaw ) && bopenclaw )
            self.m_claw setanim( %ai_zombie_mech_grapple_arm_open_idle, 1, 0.2, 1 );
    }
}

mechz_claw_shot_pain_reaction()
{
    self mechz_interrupt();
    self animscripted( self.origin, self.angles, "zm_head_pain" );
    self maps\mp\animscripts\zm_shared::donotetracks( "head_pain_anim" );
}

ent_released_from_claw_grab_achievement( e_releaser, e_held_by_mechz )
{
    if ( isdefined( e_releaser ) && isdefined( e_held_by_mechz ) && isplayer( e_releaser ) && isplayer( e_held_by_mechz ) )
    {
        if ( e_releaser == e_held_by_mechz )
            e_releaser notify( "mechz_grab_released_self" );
        else
            e_releaser notify( "mechz_grab_released_friendly" );
    }
}

mechz_claw_notetracks()
{
    self endon( "death" );
    self endon( "kill_claw" );

    self waittillmatch( "grapple_anim", "muzzleflash" );

    self waittillmatch( "grapple_anim", "end" );
}

mechz_claw_aim( target_pos )
{
    self endon( "death" );
    self endon( "kill_claw" );
    self endon( "claw_complete" );
    aim_anim = mechz_get_aim_anim( "zm_grapple", target_pos );
    self animscripted( self.origin, self.angles, "zm_grapple_aim_start" );
    self thread mechz_claw_notetracks();
    self maps\mp\animscripts\zm_shared::donotetracks( "grapple_anim" );

    while ( flag( "mechz_launching_claw" ) )
    {
        self animscripted( self.origin, self.angles, aim_anim );
        self maps\mp\animscripts\zm_shared::donotetracks( "grapple_anim" );
        self clearanim( %root, 0.0 );
    }
}

player_can_be_grabbed()
{
    if ( self getstance() == "prone" && ( isdefined( self.is_dtp ) && self.is_dtp ) )
        return false;

    if ( !is_player_valid( self, 1, 1 ) )
        return false;

    return true;
}

mechz_claw_explosive_watcher()
{
    if ( !isdefined( self.explosive_dmg_taken ) )
        self.explosive_dmg_taken = 0;

    self.explosive_dmg_taken_on_grab_start = self.explosive_dmg_taken;
}

mechz_unlink_on_laststand( mechz )
{
    self endon( "death" );
    self endon( "disconnect" );
    mechz endon( "death" );
    mechz endon( "claw_complete" );
    mechz endon( "kill_claw" );

    while ( true )
    {
        if ( isdefined( self ) && self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            mechz thread mechz_claw_release();
            return;
        }

        wait 0.05;
    }
}

claw_grapple()
{
    self endon( "death" );
    self endon( "kill_claw" );

    if ( !isdefined( self.favoriteenemy ) )
        return;

    v_claw_origin = self gettagorigin( "tag_claw" );
    v_claw_angles = vectortoangles( self.origin - self.favoriteenemy.origin );
    self.fx_field |= 256;
    self setclientfield( "mechz_fx", self.fx_field );
    self.m_claw setanim( %ai_zombie_mech_grapple_arm_open_idle, 1, 0, 1 );
    self.m_claw unlink();
    self.m_claw.fx_ent = spawn( "script_model", self.m_claw gettagorigin( "tag_claw" ) );
    self.m_claw.fx_ent.angles = self.m_claw gettagangles( "tag_claw" );
    self.m_claw.fx_ent setmodel( "tag_origin" );
    self.m_claw.fx_ent linkto( self.m_claw, "tag_claw" );
    network_safe_play_fx_on_tag( "mech_claw", 1, level._effect["mechz_claw"], self.m_claw.fx_ent, "tag_origin" );
    v_enemy_origin = self.favoriteenemy.origin + vectorscale( ( 0, 0, 1 ), 36.0 );
    n_dist = distance( v_claw_origin, v_enemy_origin );
    n_time = n_dist / 1200;
    self playsound( "zmb_ai_mechz_claw_fire" );
    self.m_claw moveto( v_enemy_origin, n_time );
    self.m_claw thread check_for_claw_move_complete();
    self.m_claw playloopsound( "zmb_ai_mechz_claw_loop_out", 0.1 );
    self.e_grabbed = undefined;

    do
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( !is_player_valid( player, 1, 1 ) || !player player_can_be_grabbed() )
                continue;

            n_dist_sq = distancesquared( player.origin + vectorscale( ( 0, 0, 1 ), 36.0 ), self.m_claw.origin );

            if ( n_dist_sq < 2304 )
            {
                if ( isdefined( player.hasriotshield ) && player.hasriotshield && player getcurrentweapon() == level.riotshield_name )
                {
                    shield_dmg = level.zombie_vars["riotshield_hit_points"];
                    player maps\mp\zombies\_zm_weap_riotshield_tomb::player_damage_shield( shield_dmg - 1, 1 );
                    wait 1;
                    player maps\mp\zombies\_zm_weap_riotshield_tomb::player_damage_shield( 1, 1 );
                }
                else
                {
                    self.e_grabbed = player;
                    self.e_grabbed setclientfieldtoplayer( "mechz_grab", 1 );
                    self.e_grabbed playerlinktodelta( self.m_claw, "tag_attach_player" );
                    self.e_grabbed setplayerangles( vectortoangles( self.origin - self.e_grabbed.origin ) );
                    self.e_grabbed playsound( "zmb_ai_mechz_claw_grab" );
                    self.e_grabbed setstance( "stand" );
                    self.e_grabbed allowcrouch( 0 );
                    self.e_grabbed allowprone( 0 );
                    self.e_grabbed thread mechz_grabbed_played_vo( self );

                    if ( !flag( "mechz_claw_move_complete" ) )
                        self.m_claw moveto( self.m_claw.origin, 0.05 );
                }

                break;
            }
        }

        wait 0.05;
    }
    while ( !flag( "mechz_claw_move_complete" ) && !isdefined( self.e_grabbed ) );

    if ( !isdefined( self.e_grabbed ) )
    {
        a_ai_zombies = get_round_enemy_array();

        foreach ( ai_zombie in a_ai_zombies )
        {
            if ( !isalive( ai_zombie ) || isdefined( ai_zombie.is_giant_robot ) && ai_zombie.is_giant_robot || isdefined( ai_zombie.is_mechz ) && ai_zombie.is_mechz )
                continue;

            n_dist_sq = distancesquared( ai_zombie.origin + vectorscale( ( 0, 0, 1 ), 36.0 ), self.m_claw.origin );

            if ( n_dist_sq < 2304 )
            {
                self.e_grabbed = ai_zombie;
                self.e_grabbed linkto( self.m_claw, "tag_attach_player", ( 0, 0, 0 ) );
                self.e_grabbed.mechz_grabbed_by = self;
                self.e_grabbed animcustom( ::zombie_grabbed_by_mechz_claw );
                break;
            }
        }
    }

    self.m_claw clearanim( %root, 0.2 );
    self.m_claw setanim( %ai_zombie_mech_grapple_arm_closed_idle, 1, 0.2, 1 );
    wait 0.5;

    if ( isdefined( self.e_grabbed ) )
        n_time = n_dist / 200;
    else
        n_time = n_dist / 1000;

    self mechz_claw_explosive_watcher();
    v_claw_origin = self gettagorigin( "tag_claw" );
    v_claw_angles = self gettagangles( "tag_claw" );
    self.m_claw moveto( v_claw_origin, max( 0.05, n_time ) );
    self.m_claw playloopsound( "zmb_ai_mechz_claw_loop_in", 0.1 );

    self.m_claw waittill( "movedone" );

    v_claw_origin = self gettagorigin( "tag_claw" );
    v_claw_angles = self gettagangles( "tag_claw" );
    self.m_claw playsound( "zmb_ai_mechz_claw_back" );
    self.m_claw stoploopsound( 1 );

    if ( maps\mp\zombies\_zm_ai_mechz::sndmechzisnetworksafe( "angry" ) )
        self playsound( "zmb_ai_mechz_vox_angry" );

    self.m_claw.origin = v_claw_origin;
    self.m_claw.angles = v_claw_angles;
    self.m_claw clearanim( %root, 0.2 );
    self.m_claw linkto( self, "tag_claw", ( 0, 0, 0 ) );
    self.m_claw setanim( %ai_zombie_mech_grapple_arm_closed_idle, 1, 0.2, 1 );
    self.m_claw.fx_ent delete();
    self.m_claw.fx_ent = undefined;
    self.fx_field &= ~256;
    self setclientfield( "mechz_fx", self.fx_field );
    flag_clear( "mechz_launching_claw" );

    if ( isdefined( self.e_grabbed ) )
    {
        if ( !isdefined( self.flamethrower_trigger ) )
            self mechz_flamethrower_initial_setup();

        if ( isplayer( self.e_grabbed ) && is_player_valid( self.e_grabbed ) )
            self.e_grabbed thread mechz_unlink_on_laststand( self );
        else if ( isai( self.e_grabbed ) )
            self.e_grabbed thread mechz_zombie_flamethrower_gib( self );

        self thread check_for_claw_damaged( self.e_grabbed );
        self animscripted( self.origin, self.angles, "zm_flamethrower_claw_victim" );
        self maps\mp\animscripts\zm_shared::donotetracks( "flamethrower_anim" );
    }

    flag_clear( "mechz_claw_move_complete" );
}

zombie_grabbed_by_mechz_claw()
{
    self endon( "death" );
    self setanimstatefromasd( "zm_grabbed_by_mech" );
    self.mechz_grabbed_by waittill_any( "death", "claw_complete", "kill_claw" );
}

check_for_claw_damaged( player )
{
    player endon( "death" );
    player endon( "disconnect" );
    self endon( "death" );
    self endon( "claw_complete" );
    self endon( "kill_claw" );
    self thread claw_damaged_mechz_endon_watcher( player );
    player thread claw_damaged_player_endon_watcher( self );
    self.m_claw setcandamage( 1 );

    while ( isdefined( self.e_grabbed ) )
    {
        self.m_claw waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( is_player_valid( inflictor ) )
        {
            self dodamage( 1, inflictor.origin, inflictor, inflictor, "left_hand", type );
            self.m_claw setcandamage( 0 );
            self notify( "claw_damaged" );
            break;
        }
    }
}

claw_damaged_mechz_endon_watcher( player )
{
    self endon( "claw_damaged" );
    player endon( "death" );
    player endon( "disconnect" );
    self waittill_any( "death", "claw_complete", "kill_claw" );

    if ( isdefined( self ) && isdefined( self.m_claw ) )
        self.m_claw setcandamage( 0 );
}

claw_damaged_player_endon_watcher( mechz )
{
    mechz endon( "claw_damaged" );
    mechz endon( "death" );
    mechz endon( "claw_complete" );
    mechz endon( "kill_claw" );
    self waittill_any( "death", "disconnect" );

    if ( isdefined( mechz ) && isdefined( mechz.m_claw ) )
        mechz.m_claw setcandamage( 0 );
}

check_for_players_mid_grapple()
{
    self endon( "movedone" );

    while ( true )
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( !is_player_valid( player, 1, 1 ) || !player player_can_be_grabbed() )
                continue;

            n_dist_sq = distancesquared( player.origin + vectorscale( ( 0, 0, 1 ), 36.0 ), self.origin );

            if ( n_dist_sq < 2304 )
            {
                self moveto( self.origin, 0.05 );
                self notify( "movedone" );
                return;
            }
        }

        wait 0.05;
    }
}

check_for_claw_move_complete()
{
    self waittill( "movedone" );

    wait 0.05;
    flag_set( "mechz_claw_move_complete" );
}

mechz_zombie_flamethrower_gib( mechz )
{
    mechz waittillmatch( "flamethrower_anim", "start_ft" );

    if ( isalive( self ) )
    {
        self thread zombie_gib_all();
        self dodamage( self.health, self.origin, self );
    }
}

should_do_claw_attack()
{
    assert( isdefined( self.favoriteenemy ) );
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\n\\tMZ: Checking should claw\\n" );
#/
    if ( !( isdefined( self.has_powerplant ) && self.has_powerplant ) )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because powerplant has been destroyed\\n" );
#/
        return false;
    }

    if ( isdefined( self.disable_complex_behaviors ) && self.disable_complex_behaviors )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because doing force aggro\\n" );
#/
        return false;
    }

    if ( isdefined( self.not_interruptable ) && self.not_interruptable )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because another behavior has set not_interruptable\\n" );
#/
        return false;
    }

    if ( isdefined( self.last_claw_time ) && gettime() - self.last_claw_time < level.mechz_claw_cooldown_time )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because claw is on cooldown\\n" );
#/
        return false;
    }

    if ( !self mechz_check_in_arc() )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because target is not in front arc\\n" );
#/
        return false;
    }

    n_dist_sq = distancesquared( self.origin, self.favoriteenemy.origin );

    if ( n_dist_sq < 90000 || n_dist_sq > 1000000 )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because target is not in range\\n" );
#/
        return false;
    }

    if ( !self.favoriteenemy player_can_be_grabbed() )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because player is prone or dtp\\n" );
#/
        return false;
    }

    curr_zone = get_zone_from_position( self.origin + vectorscale( ( 0, 0, 1 ), 36.0 ) );

    if ( isdefined( curr_zone ) && "ug_bottom_zone" == curr_zone )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because mech is in main chamber\\n" );
#/
        return false;
    }

    clip_mask = level.physicstracemaskclip | level.physicstracemaskphysics;
    claw_origin = self.origin + vectorscale( ( 0, 0, 1 ), 65.0 );
    trace = physicstrace( claw_origin, self.favoriteenemy.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), ( -15, -15, -20 ), ( 15, 15, 40 ), self, clip_mask );
    b_cansee = trace["fraction"] == 1.0 || isdefined( trace["entity"] ) && trace["entity"] == self.favoriteenemy;

    if ( !b_cansee )
    {
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\t\\tMZ: Not doing claw because capsule trace failed\\n" );
#/
        return false;
    }

    return true;
}

mechz_do_claw_grab()
{
    self endon( "death" );
    self endon( "kill_claw" );
/#
    if ( getdvarint( _hash_E7121222 ) > 0 )
        println( "\\n\\tMZ: Doing Claw Attack\\n" );
#/
    assert( isdefined( self.favoriteenemy ) );
    self thread mechz_kill_claw_watcher();
    self.last_claw_time = gettime();
    target_pos = self.favoriteenemy.origin + vectorscale( ( 0, 0, 1 ), 30.0 );
    self thread mechz_stop_basic_find_flesh();
    self.ai_state = "grapple_attempt";
    flag_set( "mechz_launching_claw" );
    self thread mechz_claw_aim( target_pos );
    self orientmode( "face enemy" );

    self waittillmatch( "grapple_anim", "muzzleflash" );

    self claw_grapple();
    self mechz_claw_cleanup();
}

mechz_kill_claw_watcher()
{
    self endon( "claw_complete" );
    self waittill_either( "death", "kill_claw" );
    self mechz_claw_cleanup();
}

mechz_claw_cleanup()
{
    self.fx_field &= ~256;
    self.fx_field &= ~64;
    self setclientfield( "mechz_fx", self.fx_field );
    self mechz_claw_release();

    if ( isdefined( self.m_claw ) )
    {
        self.m_claw clearanim( %root, 0.2 );

        if ( isdefined( self.m_claw.fx_ent ) )
        {
            self.m_claw.fx_ent delete();
            self.m_claw.fx_ent = undefined;
        }

        if ( !( isdefined( self.has_powerplant ) && self.has_powerplant ) )
        {
            self mechz_claw_detach();
            flag_clear( "mechz_launching_claw" );
        }
        else
        {
            if ( !self.m_claw islinkedto( self ) )
            {
                v_claw_origin = self gettagorigin( "tag_claw" );
                v_claw_angles = self gettagangles( "tag_claw" );
                n_dist = distance( self.m_claw.origin, v_claw_origin );
                n_time = n_dist / 1000;
                self.m_claw moveto( v_claw_origin, max( 0.05, n_time ) );
                self.m_claw playloopsound( "zmb_ai_mechz_claw_loop_in", 0.1 );

                self.m_claw waittill( "movedone" );

                v_claw_origin = self gettagorigin( "tag_claw" );
                v_claw_angles = self gettagangles( "tag_claw" );
                self.m_claw playsound( "zmb_ai_mechz_claw_back" );
                self.m_claw stoploopsound( 1 );
                self.m_claw.origin = v_claw_origin;
                self.m_claw.angles = v_claw_angles;
                self.m_claw clearanim( %root, 0.2 );
                self.m_claw linkto( self, "tag_claw", ( 0, 0, 0 ) );
            }

            self.m_claw setanim( %ai_zombie_mech_grapple_arm_closed_idle, 1, 0.2, 1 );
        }
    }

    self notify( "claw_complete" );
}

mechz_claw_damage_trigger_thread()
{
    self endon( "death" );
    self.m_claw_damage_trigger endon( "death" );

    while ( true )
    {
        self.m_claw_damage_trigger waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( self.m_claw islinkedto( self ) )
            continue;

        if ( is_player_valid( inflictor ) )
        {
            self dodamage( 1, inflictor.origin, inflictor, inflictor, "left_hand", type );
            self.m_claw setcandamage( 0 );
            self notify( "claw_damaged" );
        }
    }
}
