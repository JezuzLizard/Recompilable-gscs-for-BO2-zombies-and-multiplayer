// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

fxanim_init_dlc( localclientnum )
{
    a_fxanims = getentarray( localclientnum, "fxanim_dlc3", "targetname" );
    assert( a_fxanims.size <= level.fxanim_max_anims );

    for ( i = 0; i < a_fxanims.size; i++ )
    {
        if ( isdefined( a_fxanims[i].fxanim_parent ) )
        {
            parent = getent( localclientnum, a_fxanims[i].fxanim_parent, "targetname" );
            a_fxanims[a_fxanims.size] = parent;
            a_fxanims[i] thread _fxanim_model_link( localclientnum );
            continue;
        }

        a_fxanims[i] thread fxanim_think( localclientnum );
    }

    if ( isdefined( level.fx_anim_level_dlc_init ) )
        level thread [[ level.fx_anim_level_dlc_init ]]( localclientnum );
}

#using_animtree("fxanim_props_dlc3");

fxanim_think( localclientnum, random_wait, random_speed )
{
    self waittill_dobj( localclientnum );
    self thread _fxanim_hide();
    self _fxanim_wait();
    self useanimtree( #animtree );
    n_anim_count = self _fxanim_get_anim_count();
    self notify( "fxanim_start" );

    for ( n_current_anim = 0; n_current_anim < n_anim_count; n_current_anim++ )
    {
        str_scene = self _fxanim_get_scene_name( n_current_anim );

        if ( !self _fxanim_modifier( str_scene ) )
        {
            self _fxanim_animate( str_scene );
            self _fxanim_play_fx( localclientnum );
        }

        self _fxanim_change_anim( n_current_anim );
    }
}

_fxanim_hide()
{
    if ( isdefined( self.fxanim_hide ) && self.fxanim_hide )
    {
        self hide();

        self waittill( "fxanim_start" );

        self show();
    }
}

_fxanim_modifier( str_scene )
{
    switch ( str_scene )
    {
        case "delete":
            self delete();
            break;
        case "hide":
            self hide();
            break;
        default:
            return false;
            break;
    }

    return true;
}

_fxanim_wait()
{
    if ( isdefined( self.fxanim_waittill_1 ) )
    {
        if ( isdefined( self.fxanim_waittill_1 ) )
            _fxanim_change_anim( -1 );
    }

    if ( isdefined( self.fxanim_wait ) )
        wait( self.fxanim_wait );
    else if ( isdefined( self.fxanim_wait_min ) && isdefined( self.fxanim_wait_max ) )
    {
        n_wait_time = randomfloatrange( self.fxanim_wait_min, self.fxanim_wait_max );
        wait( n_wait_time );
    }
}

_fxanim_change_anim( n_fxanim_id )
{
    str_waittill = undefined;

    if ( n_fxanim_id == -1 && isdefined( self.fxanim_waittill_1 ) )
        str_waittill = self.fxanim_waittill_1;
    else if ( n_fxanim_id == 0 && isdefined( self.fxanim_waittill_2 ) )
        str_waittill = self.fxanim_waittill_2;
    else if ( n_fxanim_id == 1 && isdefined( self.fxanim_waittill_3 ) )
        str_waittill = self.fxanim_waittill_3;

    if ( !isdefined( str_waittill ) && n_fxanim_id != -1 )
        self _fxanim_wait_for_anim_to_end( n_fxanim_id );
    else
    {
        a_changer = strtok( str_waittill, "_" );

        level waittill( str_waittill );
    }
}

_fxanim_wait_for_anim_to_end( n_fxanim_id )
{
    str_scene = _fxanim_get_scene_name( n_fxanim_id );

    if ( issubstr( str_scene, "_loop" ) )
        self waittillmatch( "looping anim", "end" );
    else
        self waittillmatch( "single anim", "end" );
}

_fxanim_animate( str_scene )
{
    if ( !isdefined( level.scr_anim["fxanim_props_dlc3"][str_scene] ) )
    {
/#
        if ( isdefined( str_scene ) )
            println( "Error: fxanim entity at " + self.origin + " is missing animation: " + str_scene );
        else
            println( "Error: fxanim entity at " + self.origin + " is missing animation" );
#/
        return;
    }

    self animscripted( level.scr_anim["fxanim_props_dlc3"][str_scene], 1.0, 0.0, 1.0 );
}

_fxanim_play_fx( localclientnum )
{
    if ( isdefined( self.fxanim_fx_1 ) )
    {
        assert( isdefined( self.fxanim_fx_1_tag ), "KVP fxanim_fx_1_tag must be set on fxanim at " + self.origin );
        playfxontag( localclientnum, getfx( self.fxanim_fx_1 ), self, self.fxanim_fx_1_tag );
    }

    if ( isdefined( self.fxanim_fx_2 ) )
    {
        assert( isdefined( self.fxanim_fx_2_tag ), "KVP fxanim_fx_2_tag must be set on fxanim at " + self.origin );
        playfxontag( localclientnum, getfx( self.fxanim_fx_2 ), self, self.fxanim_fx_2_tag );
    }

    if ( isdefined( self.fxanim_fx_3 ) )
    {
        assert( isdefined( self.fxanim_fx_3_tag ), "KVP fxanim_fx_3_tag must be set on fxanim at " + self.origin );
        playfxontag( localclientnum, getfx( self.fxanim_fx_3 ), self, self.fxanim_fx_3_tag );
    }

    if ( isdefined( self.fxanim_fx_4 ) )
    {
        assert( isdefined( self.fxanim_fx_4_tag ), "KVP fxanim_fx_4_tag must be set on fxanim at " + self.origin );
        playfxontag( localclientnum, getfx( self.fxanim_fx_4 ), self, self.fxanim_fx_4_tag );
    }

    if ( isdefined( self.fxanim_fx_5 ) )
    {
        assert( isdefined( self.fxanim_fx_5_tag ), "KVP fxanim_fx_5_tag must be set on fxanim at " + self.origin );
        playfxontag( localclientnum, getfx( self.fxanim_fx_5 ), self, self.fxanim_fx_5_tag );
    }
}

_fxanim_get_anim_count()
{
    assert( isdefined( self.fxanim_scene_1 ), "fxanim at position " + self.origin + " needs at least one scene defined.  Use the KVP fxanim_scene_1" );
    n_fx_count = 0;

    if ( !isdefined( self.fxanim_scene_2 ) )
        n_fx_count = 1;
    else if ( !isdefined( self.fxanim_scene_3 ) )
        n_fx_count = 2;
    else
        n_fx_count = 3;

    return n_fx_count;
}

_fxanim_get_scene_name( n_anim_id )
{
    str_scene_name = undefined;

    switch ( n_anim_id )
    {
        case 0:
            str_scene_name = self.fxanim_scene_1;
            break;
        case 1:
            str_scene_name = self.fxanim_scene_2;
            break;
        case 2:
            str_scene_name = self.fxanim_scene_3;
            break;
    }

    return str_scene_name;
}

_fxanim_model_link( localclientnum )
{
    self waittill_dobj( localclientnum );
    assert( isdefined( self.fxanim_tag ), "Model at origin " + self.origin + " needs an fxanim_tag defined, to show which tag the model will link to" );
    m_parent = getent( localclientnum, self.fxanim_parent, "targetname" );
    assert( isdefined( m_parent ), "Model at origin " + self.origin + " does not have a proper parent.  Make sure the fxanim_parent matches the targetname of the fxanim" );
    m_parent waittill_dobj( localclientnum );
    self.origin = m_parent gettagorigin( self.fxanim_tag );
    self.angles = m_parent gettagangles( self.fxanim_tag );
    self linkto( m_parent, self.fxanim_tag );

    if ( isdefined( self.fxanim_hide ) )
    {
        self hide();

        m_parent waittill( "fxanim_start" );

        self show();
    }
}

getfx( fx )
{
    assert( isdefined( level._effect[fx] ), "Fx " + fx + " is not defined in level._effect." );
    return level._effect[fx];
}
