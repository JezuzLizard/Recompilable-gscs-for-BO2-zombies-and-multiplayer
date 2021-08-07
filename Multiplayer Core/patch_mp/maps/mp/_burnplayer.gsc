//checked includes match cerberus output
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/_utility;
#include common_scripts/utility;

initburnplayer() //checked matches cerberus output
{
	level.flamedamage = 15;
	level.flameburntime = 1.5;
}

hitwithincendiary( attacker, inflictor, mod ) //checked changed to match cerberus output
{
	if ( isDefined( self.burning ) )
	{
		return;
	}
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
		tagarray[ tagarray.size ] = "J_Wrist_RI";
		tagarray[ tagarray.size ] = "J_Wrist_LE";
		tagarray[ tagarray.size ] = "J_Elbow_LE";
		tagarray[ tagarray.size ] = "J_Elbow_RI";
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
	}
	else
	{
		tagarray[ tagarray.size ] = "J_Wrist_RI";
		tagarray[ tagarray.size ] = "J_Wrist_LE";
		tagarray[ tagarray.size ] = "J_Elbow_LE";
		tagarray[ tagarray.size ] = "J_Elbow_RI";
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
		if ( isplayer( self ) && self.health > 0 )
		{
			self setburn( 3 );
		}
	}
	if ( isDefined( level._effect[ "character_fire_death_torso" ] ) )
	{
		for ( arrayIndex = 0; arrayIndex < tagArray.size;  arrayIndex++ )
		{
			playfxontag( level._effect[ "character_fire_death_sm" ], self, tagarray[ arrayindex ] );
		}
	}
	if ( isai( self ) )
	{
		playfxontag( level._effect[ "character_fire_death_torso" ], self, "J_Spine1" );
	}
	else
	{
		playfxontag( level._effect[ "character_fire_death_torso" ], self, "J_SpineLower" );
	}
	if ( !isalive( self ) )
	{
		return;
	}
	if ( isplayer( self ) )
	{
		self thread watchforwater( 7 );
		self thread watchfordeath();
	}
}

hitwithnapalmstrike( attacker, inflictor, mod ) //checked changed to match cerberus output
{
	if ( isDefined( self.burning ) || self hasperk( "specialty_fireproof" ) )
	{
		return;
	}
	self starttanning();
	self thread waitthenstoptanning( level.flameburntime );
	self endon( "disconnect" );
	attacker endon( "disconnect" );
	self endon( "death" );
	if ( isDefined( self.burning ) )
	{
		return;
	}
	self thread burn_blocker();
	waittillframeend;
	self.burning = 1;
	self thread burn_blocker();
	tagarray = [];
	if ( isai( self ) )
	{
		tagarray[ tagarray.size ] = "J_Wrist_RI";
		tagarray[ tagarray.size ] = "J_Wrist_LE";
		tagarray[ tagarray.size ] = "J_Elbow_LE";
		tagarray[ tagarray.size ] = "J_Elbow_RI";
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
	}
	else
	{
		tagarray[ tagarray.size ] = "J_Wrist_RI";
		tagarray[ tagarray.size ] = "J_Wrist_LE";
		tagarray[ tagarray.size ] = "J_Elbow_LE";
		tagarray[ tagarray.size ] = "J_Elbow_RI";
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
		if ( isplayer( self ) )
		{
			self setburn( 3 );
		}
	}
	if ( isDefined( level._effect[ "character_fire_death_sm" ] ) )
	{
		for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
		{
			playfxontag( level._effect[ "character_fire_death_sm" ], self, tagarray[ arrayindex ] );
			arrayindex++;
		}
	}
	if ( isDefined( level._effect[ "character_fire_death_torso" ] ) )
	{
		playfxontag( level._effect[ "character_fire_death_torso" ], self, "J_SpineLower" );
	}
	if ( !isalive( self ) )
	{
		return;
	}
	self thread donapalmstrikedamage( attacker, inflictor, mod );
	if ( isplayer( self ) )
	{
		self thread watchforwater( 7 );
		self thread watchfordeath();
	}
}

walkedthroughflames( attacker, inflictor, weapon ) //checked changed to match cerberus output
{
	if ( isDefined( self.burning ) || self hasperk( "specialty_fireproof" ) )
	{
		return;
	}
	self starttanning();
	self thread waitthenstoptanning( level.flameburntime );
	self endon( "disconnect" );
	waittillframeend;
	self.burning = 1;
	self thread burn_blocker();
	tagarray = [];
	if ( isai( self ) )
	{
		tagarray[ tagarray.size ] = "J_Wrist_RI";
		tagarray[ tagarray.size ] = "J_Wrist_LE";
		tagarray[ tagarray.size ] = "J_Elbow_LE";
		tagarray[ tagarray.size ] = "J_Elbow_RI";
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
	}
	else
	{
		tagarray[ tagarray.size ] = "J_Knee_RI";
		tagarray[ tagarray.size ] = "J_Knee_LE";
		tagarray[ tagarray.size ] = "J_Ankle_RI";
		tagarray[ tagarray.size ] = "J_Ankle_LE";
	}
	if ( isDefined( level._effect[ "character_fire_player_sm" ] ) )
	{
		for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
		{
			playfxontag( level._effect[ "character_fire_player_sm" ], self, tagarray[ arrayindex ] );
		}
	}
	if ( !isalive( self ) )
	{
		return;
	}
	self thread doflamedamage( attacker, inflictor, weapon, 1 );
	if ( isplayer( self ) )
	{
		self thread watchforwater( 7 );
		self thread watchfordeath();
	}
}

burnedwithflamethrower( attacker, inflictor, weapon ) //checked changed to match cerberus output
{
	if ( isDefined( self.burning ) )
	{
		return;
	}
	self starttanning();
	self thread waitthenstoptanning( level.flameburntime );
	self endon( "disconnect" );
	waittillframeend;
	self.burning = 1;
	self thread burn_blocker();
	tagarray = [];
	if ( isai( self ) )
	{
		tagarray[ 0 ] = "J_Spine1";
		tagarray[ 1 ] = "J_Elbow_LE";
		tagarray[ 2 ] = "J_Elbow_RI";
		tagarray[ 3 ] = "J_Head";
		tagarray[ 4 ] = "j_knee_ri";
		tagarray[ 5 ] = "j_knee_le";
	}
	else
	{
		tagarray[ 0 ] = "J_Elbow_RI";
		tagarray[ 1 ] = "j_knee_ri";
		tagarray[ 2 ] = "j_knee_le";
		if ( isplayer( self ) && self.health > 0 )
		{
			self setburn( 3 );
		}
	}
	if ( isplayer( self ) && isalive( self ) )
	{
		self thread watchforwater( 7 );
		self thread watchfordeath();
	}
	if ( isDefined( level._effect[ "character_fire_player_sm" ] ) )
	{
		for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
		{
			playfxontag( level._effect[ "character_fire_player_sm" ], self, tagarray[ arrayindex ] );
		}
	}
}

burnedwithdragonsbreath( attacker, inflictor, weapon ) //checked changed to match cerberus output
{
	if ( isDefined( self.burning ) )
	{
		return;
	}
	self starttanning();
	self thread waitthenstoptanning( level.flameburntime );
	self endon( "disconnect" );
	waittillframeend;
	self.burning = 1;
	self thread burn_blocker();
	tagarray = [];
	if ( isai( self ) )
	{
		tagarray[ 0 ] = "J_Spine1";
		tagarray[ 1 ] = "J_Elbow_LE";
		tagarray[ 2 ] = "J_Elbow_RI";
		tagarray[ 3 ] = "J_Head";
		tagarray[ 4 ] = "j_knee_ri";
		tagarray[ 5 ] = "j_knee_le";
	}
	else
	{
		tagarray[ 0 ] = "j_spinelower";
		tagarray[ 1 ] = "J_Elbow_RI";
		tagarray[ 2 ] = "j_knee_ri";
		tagarray[ 3 ] = "j_knee_le";
		if ( isplayer( self ) && self.health > 0 )
		{
			self setburn( 3 );
		}
	}
	if ( isplayer( self ) && isalive( self ) )
	{
		self thread watchforwater( 7 );
		self thread watchfordeath();
		return;
	}
	if ( isDefined( level._effect[ "character_fire_player_sm" ] ) )
	{
		for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
		{
			playfxontag( level._effect[ "character_fire_player_sm" ], self, tagarray[ arrayindex ] );
		}
	}
}

burnedtodeath() //checked matches cerberus output
{
	self.burning = 1;
	self thread burn_blocker();
	self starttanning();
	self thread doburningsound();
	self thread waitthenstoptanning( level.flameburntime );
}

watchfordeath() //checked matches cerberus output
{
	self endon( "disconnect" );
	self notify( "watching for death while on fire" );
	self endon( "watching for death while on fire" );
	self waittill( "death" );
	if ( isplayer( self ) )
	{
		self _stopburning();
	}
	self.burning = undefined;
}

watchforwater( time ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self notify( "watching for water" );
	self endon( "watching for water" );
	wait 0.1;
	looptime = 0.1;
	while ( time > 0 )
	{
		wait looptime;
		if ( self depthofplayerinwater() > 0 )
		{
			finish_burn();
			time = 0;
		}
		time -= looptime;
	}
}

finish_burn() //checked changed to match cerberus output
{
	self notify( "stop burn damage" );
	tagarray = [];
	tagarray[ 0 ] = "j_spinelower";
	tagarray[ 1 ] = "J_Elbow_RI";
	tagarray[ 2 ] = "J_Head";
	tagarray[ 3 ] = "j_knee_ri";
	tagarray[ 4 ] = "j_knee_le";
	if ( isDefined( level._effect[ "fx_fire_player_sm_smk_2sec" ] ) )
	{
		for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
		{
			playfxontag( level._effect[ "fx_fire_player_sm_smk_2sec" ], self, tagarray[ arrayindex ] );
		}
	}
	self.burning = undefined;
	self _stopburning();
	self.ingroundnapalm = 0;
}

donapalmstrikedamage( attacker, inflictor, mod ) //checked matches cerberus output
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
	while ( isDefined( level.napalmstrikedamage ) && isDefined( self ) && self depthofplayerinwater() < 1 )
	{
		self dodamage( level.napalmstrikedamage, self.origin, attacker, attacker, "none", mod, 0, "napalm_mp" );
		wait 1;
	}
}

donapalmgrounddamage( attacker, inflictor, mod ) //checked changed to match cerberus output dvars taken from beta dump
{
	if ( self hasperk( "specialty_fireproof" ) )
	{
		return;
	}
	if ( level.teambased )
	{
		if ( attacker != self && attacker.team == self.team )
		{
			return;
		}
	}
	if ( isai( self ) )
	{
		dodognapalmgrounddamage( attacker, inflictor, mod );
		return;
	}
	if ( isDefined( self.burning ) )
	{
		return;
	}
	self thread burn_blocker();
	self endon( "death" );
	self endon( "disconnect" );
	attacker endon( "disconnect" );
	self endon( "stop burn damage" );
	if ( isDefined( level.groundburntime ) )
	{
		if ( getDvar( "scr_groundBurnTime" ) == "" )
		{
			waittime = level.groundburntime;
		}
		else
		{
			waittime = getDvarFloat( "scr_groundBurnTime" );
		}
	}
	else
	{
		waittime = 100;
	}
	self walkedthroughflames( attacker, inflictor, "napalm_mp" );
	self.ingroundnapalm = 1;
	while ( isDefined( level.napalmgrounddamage ) )
	{
		if ( getDvar( "scr_napalmGroundDamage" ) == "" )
		{
			napalmgrounddamage = level.napalmgrounddamage;
		}
		else
		{
			napalmgrounddamage = getDvarFloat( "scr_napalmGroundDamage" );
		}
		while ( isDefined( self ) && isDefined( inflictor ) && self depthofplayerinwater() < 1 && waittime > 0 )
		{
			self dodamage( level.napalmgrounddamage, self.origin, attacker, inflictor, "none", mod, 0, "napalm_mp" );
			if ( isplayer( self ) )
			{
				self setburn( 1.1 );
			}
			wait 1;
			waittime -= 1;
		}
	}
	self.ingroundnapalm = 0;
}

dodognapalmstrikedamage( attacker, inflictor, mod ) //checked matches cerberus output
{
	attacker endon( "disconnect" );
	self endon( "death" );
	self endon( "stop burn damage" );
	while ( isDefined( level.napalmstrikedamage ) && isDefined( self ) )
	{
		self dodamage( level.napalmstrikedamage, self.origin, attacker, attacker, "none", mod );
		wait 1;
	}
}

dodognapalmgrounddamage( attacker, inflictor, mod ) //checked matches cerberus output
{
	attacker endon( "disconnect" );
	self endon( "death" );
	self endon( "stop burn damage" );
	while ( isDefined( level.napalmgrounddamage ) && isDefined( self ) )
	{
		self dodamage( level.napalmgrounddamage, self.origin, attacker, attacker, "none", mod, 0, "napalm_mp" );
		wait 1;
	}
}

burn_blocker() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	wait 3;
	self.burning = undefined;
}

doflamedamage( attacker, inflictor, weapon, time ) //checked matches cerberus output
{
	if ( isai( self ) )
	{
		dodogflamedamage( attacker, inflictor, weapon, time );
		return;
	}
	if ( isDefined( attacker ) )
	{
		attacker endon( "disconnect" );
	}
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "stop burn damage" );
	self thread doburningsound();
	self notify( "snd_burn_scream" );
	wait_time = 1;
	while ( isDefined( level.flamedamage ) && isDefined( self ) && self depthofplayerinwater() < 1 && time > 0 )
	{
		if ( isDefined( attacker ) && isDefined( inflictor ) && isDefined( weapon ) )
		{
			if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weapon, attacker ) )
			{
				attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback();
			}
			self dodamage( level.flamedamage, self.origin, attacker, inflictor, "none", "MOD_BURNED", 0, weapon );
		}
		else
		{
			self dodamage( level.flamedamage, self.origin );
		}
		wait wait_time;
		time -= wait_time;
	}
	self thread finish_burn();
}

dodogflamedamage( attacker, inflictor, weapon, time ) //checked changed to match cerberus output
{
	if ( isDefined( attacker ) || !isDefined( inflictor ) || !isDefined( weapon ) )
	{
		return;
	}
	attacker endon( "disconnect" );
	self endon( "death" );
	self endon( "stop burn damage" );
	self thread doburningsound();
	wait_time = 1;
	while ( isDefined( level.flamedamage ) && isDefined( self ) && time > 0 )
	{
		self dodamage( level.flamedamage, self.origin, attacker, inflictor, "none", "MOD_BURNED", 0, weapon );
		wait wait_time;
		time -= wait_time;
	}
}

waitthenstoptanning( time ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	wait time;
	self _stopburning();
}

doburningsound() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	fire_sound_ent = spawn( "script_origin", self.origin );
	fire_sound_ent linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	fire_sound_ent playloopsound( "mpl_player_burn_loop" );
	self thread firesounddeath( fire_sound_ent );
	self waittill( "StopBurnSound" );
	if ( isDefined( fire_sound_ent ) )
	{
		fire_sound_ent stoploopsound( 0.5 );
	}
	wait 0.5;
	if ( isDefined( fire_sound_ent ) )
	{
		fire_sound_ent delete();
	}
	/*
/#
	println( "sound stop burning" );
#/
	*/
}

_stopburning() //checked matches cerberus output
{
	self endon( "disconnect" );
	self notify( "StopBurnSound" );
	if ( isDefined( self ) )
	{
		self stopburning();
	}
}

firesounddeath( ent ) //checked matches cerberus output
{
	ent endon( "death" );
	self waittill_any( "death", "disconnect" );
	ent delete();
	/*
/#
	println( "sound delete burning" );
#/
	*/
}
