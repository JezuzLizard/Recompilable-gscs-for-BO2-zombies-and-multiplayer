// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\animscripts\zm_combat;

meleecombat()
{
    self endon( "end_melee" );
    self endon( "killanimscript" );
    assert( canmeleeanyrange() );
    self orientmode( "face enemy" );

    if ( is_true( self.sliding_on_goo ) )
        self animmode( "slide" );
    else
        self animmode( "zonly_physics" );

    for (;;)
    {
        if ( isdefined( self.marked_for_death ) )
            return;

        if ( isdefined( self.enemy ) )
        {
            angles = vectortoangles( self.enemy.origin - self.origin );
            self orientmode( "face angle", angles[1] );
        }

        if ( isdefined( self.zmb_vocals_attack ) )
            self playsound( self.zmb_vocals_attack );

        if ( isdefined( self.nochangeduringmelee ) && self.nochangeduringmelee )
            self.safetochangescript = 0;

        if ( isdefined( self.is_inert ) && self.is_inert )
            return;

        set_zombie_melee_anim_state( self );

        if ( isdefined( self.melee_anim_func ) )
            self thread [[ self.melee_anim_func ]]();

        while ( true )
        {
            self waittill( "melee_anim", note );

            if ( note == "end" )
                break;
            else if ( note == "fire" )
            {
                if ( !isdefined( self.enemy ) )
                    break;

                if ( isdefined( self.dont_die_on_me ) && self.dont_die_on_me )
                    break;

                self.enemy notify( "melee_swipe", self );
                oldhealth = self.enemy.health;
                self melee();

                if ( !isdefined( self.enemy ) )
                    break;

                if ( self.enemy.health >= oldhealth )
                {
                    if ( isdefined( self.melee_miss_func ) )
                        self [[ self.melee_miss_func ]]();
                    else if ( isdefined( level.melee_miss_func ) )
                        self [[ level.melee_miss_func ]]();
                }
/#
                if ( getdvarint( _hash_7F11F572 ) )
                {
                    if ( self.enemy.health < oldhealth )
                    {
                        zombie_eye = self geteye();
                        player_eye = self.enemy geteye();
                        trace = bullettrace( zombie_eye, player_eye, 1, self );
                        hitpos = trace["position"];
                        dist = distance( zombie_eye, hitpos );
                        iprintln( "melee HIT " + dist );
                    }
                }
#/
            }
            else if ( note == "stop" )
            {
                if ( !cancontinuetomelee() )
                    break;
            }
        }

        if ( is_true( self.sliding_on_goo ) )
            self orientmode( "face enemy" );
        else
            self orientmode( "face default" );

        if ( isdefined( self.nochangeduringmelee ) && self.nochangeduringmelee || is_true( self.sliding_on_goo ) )
        {
            if ( isdefined( self.enemy ) )
            {
                dist_sq = distancesquared( self.origin, self.enemy.origin );

                if ( dist_sq > self.meleeattackdist * self.meleeattackdist )
                {
                    self.safetochangescript = 1;
                    wait 0.1;
                    break;
                }
            }
            else
            {
                self.safetochangescript = 1;
                wait 0.1;
                break;
            }
        }
    }

    if ( is_true( self.sliding_on_goo ) )
        self animmode( "slide" );
    else
        self animmode( "none" );

    self thread maps\mp\animscripts\zm_combat::main();
}

cancontinuetomelee()
{
    return canmeleeinternal( "already started" );
}

canmeleeanyrange()
{
    return canmeleeinternal( "any range" );
}

canmeleedesperate()
{
    return canmeleeinternal( "long range" );
}

canmelee()
{
    return canmeleeinternal( "normal" );
}

canmeleeinternal( state )
{
    if ( !issentient( self.enemy ) )
        return false;

    if ( !isalive( self.enemy ) )
        return false;

    if ( isdefined( self.disablemelee ) )
    {
        assert( self.disablemelee );
        return false;
    }

    yaw = abs( getyawtoenemy() );

    if ( yaw > 60 && state != "already started" || yaw > 110 )
        return false;

    enemypoint = self.enemy getorigin();
    vectoenemy = enemypoint - self.origin;
    self.enemydistancesq = lengthsquared( vectoenemy );

    if ( self.enemydistancesq <= anim.meleerangesq )
    {
        if ( !ismeleepathclear( vectoenemy, enemypoint ) )
            return false;

        return true;
    }

    if ( state != "any range" )
    {
        chargerangesq = anim.chargerangesq;

        if ( state == "long range" )
            chargerangesq = anim.chargelongrangesq;

        if ( self.enemydistancesq > chargerangesq )
            return false;
    }

    if ( state == "already started" )
        return false;

    if ( isdefined( self.check_melee_path ) && self.check_melee_path )
    {
        if ( !ismeleepathclear( vectoenemy, enemypoint ) )
        {
            self notify( "melee_path_blocked" );
            return false;
        }
    }

    if ( isdefined( level.can_melee ) )
    {
        if ( !self [[ level.can_melee ]]() )
            return false;
    }

    return true;
}

ismeleepathclear( vectoenemy, enemypoint )
{
    dirtoenemy = vectornormalize( ( vectoenemy[0], vectoenemy[1], 0 ) );
    meleepoint = enemypoint - ( dirtoenemy[0] * 28, dirtoenemy[1] * 28, 0 );

    if ( !self isingoal( meleepoint ) )
        return false;

    if ( self maymovetopoint( meleepoint ) )
        return true;

    trace1 = bullettrace( self.origin + vectorscale( ( 0, 0, 1 ), 20.0 ), meleepoint + vectorscale( ( 0, 0, 1 ), 20.0 ), 1, self );
    trace2 = bullettrace( self.origin + vectorscale( ( 0, 0, 1 ), 72.0 ), meleepoint + vectorscale( ( 0, 0, 1 ), 72.0 ), 1, self );

    if ( isdefined( trace1["fraction"] ) && trace1["fraction"] == 1 && isdefined( trace2["fraction"] ) && trace2["fraction"] == 1 )
        return true;

    if ( isdefined( trace1["entity"] ) && trace1["entity"] == self.enemy && isdefined( trace2["entity"] ) && trace2["entity"] == self.enemy )
        return true;

    if ( isdefined( level.zombie_melee_in_water ) && level.zombie_melee_in_water )
    {
        if ( isdefined( trace1["surfacetype"] ) && trace1["surfacetype"] == "water" && isdefined( trace2["fraction"] ) && trace2["fraction"] == 1 )
            return true;
    }

    return false;
}

set_zombie_melee_anim_state( zombie )
{
    if ( isdefined( level.melee_anim_state ) )
        melee_anim_state = self [[ level.melee_anim_state ]]();

    if ( !isdefined( melee_anim_state ) )
    {
        if ( !zombie.has_legs && zombie.a.gib_ref == "no_legs" )
            melee_anim_state = "zm_stumpy_melee";
        else
        {
            switch ( zombie.zombie_move_speed )
            {
                case "walk":
                    melee_anim_state = append_missing_legs_suffix( "zm_walk_melee" );
                    break;
                case "sprint":
                case "run":
                default:
                    melee_anim_state = append_missing_legs_suffix( "zm_run_melee" );
                    break;
            }
        }
    }

    zombie setanimstatefromasd( melee_anim_state );
}
