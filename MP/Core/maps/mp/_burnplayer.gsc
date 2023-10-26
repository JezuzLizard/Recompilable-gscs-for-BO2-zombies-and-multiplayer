// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;

initburnplayer()
{
    level.flamedamage = 15;
    level.flameburntime = 1.5;
}

hitwithincendiary( attacker, inflictor, mod )
{
    if ( isdefined( self.burning ) )
        return;

    self starttanning();
    self thread waitthenstoptanning( level.flameburntime );
    self endon( "disconnect" );
    attacker endon( "disconnect" );
    waittillframeend;
    self.burning = 1;
    self thread burn_blocker();
    tagarray = [];

    if ( isai( self ) )
    {
        tagarray[tagarray.size] = "J_Wrist_RI";
        tagarray[tagarray.size] = "J_Wrist_LE";
        tagarray[tagarray.size] = "J_Elbow_LE";
        tagarray[tagarray.size] = "J_Elbow_RI";
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_RI";
        tagarray[tagarray.size] = "J_Ankle_LE";
    }
    else
    {
        tagarray[tagarray.size] = "J_Wrist_RI";
        tagarray[tagarray.size] = "J_Wrist_LE";
        tagarray[tagarray.size] = "J_Elbow_LE";
        tagarray[tagarray.size] = "J_Elbow_RI";
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_RI";
        tagarray[tagarray.size] = "J_Ankle_LE";

        if ( isplayer( self ) && self.health > 0 )
            self setburn( 3.0 );
    }

    if ( isdefined( level._effect["character_fire_death_torso"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( level._effect["character_fire_death_sm"], self, tagarray[arrayindex] );
    }

    if ( isai( self ) )
        playfxontag( level._effect["character_fire_death_torso"], self, "J_Spine1" );
    else
        playfxontag( level._effect["character_fire_death_torso"], self, "J_SpineLower" );

    if ( !isalive( self ) )
        return;

    if ( isplayer( self ) )
    {
        self thread watchforwater( 7 );
        self thread watchfordeath();
    }
}

hitwithnapalmstrike( attacker, inflictor, mod )
{
    if ( isdefined( self.burning ) || self hasperk( "specialty_fireproof" ) )
        return;

    self starttanning();
    self thread waitthenstoptanning( level.flameburntime );
    self endon( "disconnect" );
    attacker endon( "disconnect" );
    self endon( "death" );

    if ( isdefined( self.burning ) )
        return;

    self thread burn_blocker();
    waittillframeend;
    self.burning = 1;
    self thread burn_blocker();
    tagarray = [];

    if ( isai( self ) )
    {
        tagarray[tagarray.size] = "J_Wrist_RI";
        tagarray[tagarray.size] = "J_Wrist_LE";
        tagarray[tagarray.size] = "J_Elbow_LE";
        tagarray[tagarray.size] = "J_Elbow_RI";
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_RI";
        tagarray[tagarray.size] = "J_Ankle_LE";
    }
    else
    {
        tagarray[tagarray.size] = "J_Wrist_RI";
        tagarray[tagarray.size] = "J_Wrist_LE";
        tagarray[tagarray.size] = "J_Elbow_LE";
        tagarray[tagarray.size] = "J_Elbow_RI";
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_RI";
        tagarray[tagarray.size] = "J_Ankle_LE";

        if ( isplayer( self ) )
            self setburn( 3.0 );
    }

    if ( isdefined( level._effect["character_fire_death_sm"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( level._effect["character_fire_death_sm"], self, tagarray[arrayindex] );
    }

    if ( isdefined( level._effect["character_fire_death_torso"] ) )
        playfxontag( level._effect["character_fire_death_torso"], self, "J_SpineLower" );

    if ( !isalive( self ) )
        return;

    self thread donapalmstrikedamage( attacker, inflictor, mod );

    if ( isplayer( self ) )
    {
        self thread watchforwater( 7 );
        self thread watchfordeath();
    }
}

walkedthroughflames( attacker, inflictor, weapon )
{
    if ( isdefined( self.burning ) || self hasperk( "specialty_fireproof" ) )
        return;

    self starttanning();
    self thread waitthenstoptanning( level.flameburntime );
    self endon( "disconnect" );
    waittillframeend;
    self.burning = 1;
    self thread burn_blocker();
    tagarray = [];

    if ( isai( self ) )
    {
        tagarray[tagarray.size] = "J_Wrist_RI";
        tagarray[tagarray.size] = "J_Wrist_LE";
        tagarray[tagarray.size] = "J_Elbow_LE";
        tagarray[tagarray.size] = "J_Elbow_RI";
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_RI";
        tagarray[tagarray.size] = "J_Ankle_LE";
    }
    else
    {
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_RI";
        tagarray[tagarray.size] = "J_Ankle_LE";
    }

    if ( isdefined( level._effect["character_fire_player_sm"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( level._effect["character_fire_player_sm"], self, tagarray[arrayindex] );
    }

    if ( !isalive( self ) )
        return;

    self thread doflamedamage( attacker, inflictor, weapon, 1.0 );

    if ( isplayer( self ) )
    {
        self thread watchforwater( 7 );
        self thread watchfordeath();
    }
}

burnedwithflamethrower( attacker, inflictor, weapon )
{
    if ( isdefined( self.burning ) )
        return;

    self starttanning();
    self thread waitthenstoptanning( level.flameburntime );
    self endon( "disconnect" );
    waittillframeend;
    self.burning = 1;
    self thread burn_blocker();
    tagarray = [];

    if ( isai( self ) )
    {
        tagarray[0] = "J_Spine1";
        tagarray[1] = "J_Elbow_LE";
        tagarray[2] = "J_Elbow_RI";
        tagarray[3] = "J_Head";
        tagarray[4] = "j_knee_ri";
        tagarray[5] = "j_knee_le";
    }
    else
    {
        tagarray[0] = "J_Elbow_RI";
        tagarray[1] = "j_knee_ri";
        tagarray[2] = "j_knee_le";

        if ( isplayer( self ) && self.health > 0 )
            self setburn( 3.0 );
    }

    if ( isplayer( self ) && isalive( self ) )
    {
        self thread watchforwater( 7 );
        self thread watchfordeath();
    }

    if ( isdefined( level._effect["character_fire_player_sm"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( level._effect["character_fire_player_sm"], self, tagarray[arrayindex] );
    }
}

burnedwithdragonsbreath( attacker, inflictor, weapon )
{
    if ( isdefined( self.burning ) )
        return;

    self starttanning();
    self thread waitthenstoptanning( level.flameburntime );
    self endon( "disconnect" );
    waittillframeend;
    self.burning = 1;
    self thread burn_blocker();
    tagarray = [];

    if ( isai( self ) )
    {
        tagarray[0] = "J_Spine1";
        tagarray[1] = "J_Elbow_LE";
        tagarray[2] = "J_Elbow_RI";
        tagarray[3] = "J_Head";
        tagarray[4] = "j_knee_ri";
        tagarray[5] = "j_knee_le";
    }
    else
    {
        tagarray[0] = "j_spinelower";
        tagarray[1] = "J_Elbow_RI";
        tagarray[2] = "j_knee_ri";
        tagarray[3] = "j_knee_le";

        if ( isplayer( self ) && self.health > 0 )
            self setburn( 3.0 );
    }

    if ( isplayer( self ) && isalive( self ) )
    {
        self thread watchforwater( 7 );
        self thread watchfordeath();
        return;
    }

    if ( isdefined( level._effect["character_fire_player_sm"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( level._effect["character_fire_player_sm"], self, tagarray[arrayindex] );
    }
}

burnedtodeath()
{
    self.burning = 1;
    self thread burn_blocker();
    self starttanning();
    self thread doburningsound();
    self thread waitthenstoptanning( level.flameburntime );
}

watchfordeath()
{
    self endon( "disconnect" );
    self notify( "watching for death while on fire" );
    self endon( "watching for death while on fire" );

    self waittill( "death" );

    if ( isplayer( self ) )
        self _stopburning();

    self.burning = undefined;
}

watchforwater( time )
{
    self endon( "disconnect" );
    self notify( "watching for water" );
    self endon( "watching for water" );
    wait 0.1;
    looptime = 0.1;

    while ( time > 0 )
    {
        wait( looptime );

        if ( self depthofplayerinwater() > 0 )
        {
            finish_burn();
            time = 0;
        }

        time -= looptime;
    }
}

finish_burn()
{
    self notify( "stop burn damage" );
    tagarray = [];
    tagarray[0] = "j_spinelower";
    tagarray[1] = "J_Elbow_RI";
    tagarray[2] = "J_Head";
    tagarray[3] = "j_knee_ri";
    tagarray[4] = "j_knee_le";

    if ( isdefined( level._effect["fx_fire_player_sm_smk_2sec"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( level._effect["fx_fire_player_sm_smk_2sec"], self, tagarray[arrayindex] );
    }

    self.burning = undefined;
    self _stopburning();
    self.ingroundnapalm = 0;
}

donapalmstrikedamage( attacker, inflictor, mod )
{
    if ( isai( self ) )
    {
        dodognapalmstrikedamage( attacker, inflictor, mod );
        return;
    }

    self endon( "death" );
    self endon( "disconnect" );
    attacker endon( "disconnect" );
    self endon( "stop burn damage" );

    while ( isdefined( level.napalmstrikedamage ) && isdefined( self ) && self depthofplayerinwater() < 1 )
    {
        self dodamage( level.napalmstrikedamage, self.origin, attacker, attacker, "none", mod, 0, "napalm_mp" );
        wait 1;
    }
}

donapalmgrounddamage( attacker, inflictor, mod )
{
    if ( self hasperk( "specialty_fireproof" ) )
        return;

    if ( level.teambased )
    {
        if ( attacker != self && attacker.team == self.team )
            return;
    }

    if ( isai( self ) )
    {
        dodognapalmgrounddamage( attacker, inflictor, mod );
        return;
    }

    if ( isdefined( self.burning ) )
        return;

    self thread burn_blocker();
    self endon( "death" );
    self endon( "disconnect" );
    attacker endon( "disconnect" );
    self endon( "stop burn damage" );

    if ( isdefined( level.groundburntime ) )
    {
        if ( getdvar( _hash_6EC13261 ) == "" )
            waittime = level.groundburntime;
        else
            waittime = getdvarfloat( _hash_6EC13261 );
    }
    else
        waittime = 100;

    self walkedthroughflames( attacker, inflictor, "napalm_mp" );
    self.ingroundnapalm = 1;

    if ( isdefined( level.napalmgrounddamage ) )
    {
        if ( getdvar( _hash_3FFA6673 ) == "" )
            napalmgrounddamage = level.napalmgrounddamage;
        else
            napalmgrounddamage = getdvarfloat( _hash_3FFA6673 );

        while ( isdefined( self ) && isdefined( inflictor ) && self depthofplayerinwater() < 1 && waittime > 0 )
        {
            self dodamage( level.napalmgrounddamage, self.origin, attacker, inflictor, "none", mod, 0, "napalm_mp" );

            if ( isplayer( self ) )
                self setburn( 1.1 );

            wait 1;
            waittime -= 1;
        }
    }

    self.ingroundnapalm = 0;
}

dodognapalmstrikedamage( attacker, inflictor, mod )
{
    attacker endon( "disconnect" );
    self endon( "death" );
    self endon( "stop burn damage" );

    while ( isdefined( level.napalmstrikedamage ) && isdefined( self ) )
    {
        self dodamage( level.napalmstrikedamage, self.origin, attacker, attacker, "none", mod );
        wait 1;
    }
}

dodognapalmgrounddamage( attacker, inflictor, mod )
{
    attacker endon( "disconnect" );
    self endon( "death" );
    self endon( "stop burn damage" );

    while ( isdefined( level.napalmgrounddamage ) && isdefined( self ) )
    {
        self dodamage( level.napalmgrounddamage, self.origin, attacker, attacker, "none", mod, 0, "napalm_mp" );
        wait 1;
    }
}

burn_blocker()
{
    self endon( "disconnect" );
    self endon( "death" );
    wait 3;
    self.burning = undefined;
}

doflamedamage( attacker, inflictor, weapon, time )
{
    if ( isai( self ) )
    {
        dodogflamedamage( attacker, inflictor, weapon, time );
        return;
    }

    if ( isdefined( attacker ) )
        attacker endon( "disconnect" );

    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stop burn damage" );
    self thread doburningsound();
    self notify( "snd_burn_scream" );
    wait_time = 1.0;

    while ( isdefined( level.flamedamage ) && isdefined( self ) && self depthofplayerinwater() < 1 && time > 0 )
    {
        if ( isdefined( attacker ) && isdefined( inflictor ) && isdefined( weapon ) )
        {
            if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weapon, attacker ) )
                attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();

            self dodamage( level.flamedamage, self.origin, attacker, inflictor, "none", "MOD_BURNED", 0, weapon );
        }
        else
            self dodamage( level.flamedamage, self.origin );

        wait( wait_time );
        time -= wait_time;
    }

    self thread finish_burn();
}

dodogflamedamage( attacker, inflictor, weapon, time )
{
    if ( !isdefined( attacker ) || !isdefined( inflictor ) || !isdefined( weapon ) )
        return;

    attacker endon( "disconnect" );
    self endon( "death" );
    self endon( "stop burn damage" );
    self thread doburningsound();
    wait_time = 1.0;

    while ( isdefined( level.flamedamage ) && isdefined( self ) && time > 0 )
    {
        self dodamage( level.flamedamage, self.origin, attacker, inflictor, "none", "MOD_BURNED", 0, weapon );
        wait( wait_time );
        time -= wait_time;
    }
}

waitthenstoptanning( time )
{
    self endon( "disconnect" );
    self endon( "death" );
    wait( time );
    self _stopburning();
}

doburningsound()
{
    self endon( "disconnect" );
    self endon( "death" );
    fire_sound_ent = spawn( "script_origin", self.origin );
    fire_sound_ent linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    fire_sound_ent playloopsound( "mpl_player_burn_loop" );
    self thread firesounddeath( fire_sound_ent );

    self waittill( "StopBurnSound" );

    if ( isdefined( fire_sound_ent ) )
        fire_sound_ent stoploopsound( 0.5 );

    wait 0.5;

    if ( isdefined( fire_sound_ent ) )
        fire_sound_ent delete();
/#
    println( "sound stop burning" );
#/
}

_stopburning()
{
    self endon( "disconnect" );
    self notify( "StopBurnSound" );

    if ( isdefined( self ) )
        self stopburning();
}

firesounddeath( ent )
{
    ent endon( "death" );
    self waittill_any( "death", "disconnect" );
    ent delete();
/#
    println( "sound delete burning" );
#/
}
