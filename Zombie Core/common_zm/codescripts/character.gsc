// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

setmodelfromarray( a )
{
    self setmodel( a[randomint( a.size )] );
}

precachemodelarray( a )
{
    for ( i = 0; i < a.size; i++ )
        precachemodel( a[i] );
}

randomelement( a )
{
    return a[randomint( a.size )];
}

attachfromarray( a )
{
    self attach( randomelement( a ), "", 1 );
}

new()
{
    self detachall();
    oldgunhand = self.anim_gunhand;

    if ( !isdefined( oldgunhand ) )
        return;

    self.anim_gunhand = "none";
    self [[ anim.putguninhand ]]( oldgunhand );
}

save()
{
    info["gunHand"] = self.anim_gunhand;
    info["gunInHand"] = self.anim_guninhand;
    info["model"] = self.model;
    info["hatModel"] = self.hatmodel;
    info["gearModel"] = self.gearmodel;

    if ( isdefined( self.name ) )
    {
        info["name"] = self.name;
/#
        println( "Save: Guy has name ", self.name );
#/
    }
    else
    {
/#
        println( "save: Guy had no name!" );
#/
    }

    attachsize = self getattachsize();

    for ( i = 0; i < attachsize; i++ )
    {
        info["attach"][i]["model"] = self getattachmodelname( i );
        info["attach"][i]["tag"] = self getattachtagname( i );
    }

    return info;
}

load( info )
{
    self detachall();
    self.anim_gunhand = info["gunHand"];
    self.anim_guninhand = info["gunInHand"];
    self setmodel( info["model"] );
    self.hatmodel = info["hatModel"];
    self.gearmodel = info["gearModel"];

    if ( isdefined( info["name"] ) )
    {
        self.name = info["name"];
/#
        println( "Load: Guy has name ", self.name );
#/
    }
    else
    {
/#
        println( "Load: Guy had no name!" );
#/
    }

    attachinfo = info["attach"];
    attachsize = attachinfo.size;

    for ( i = 0; i < attachsize; i++ )
        self attach( attachinfo[i]["model"], attachinfo[i]["tag"] );
}

precache( info )
{
    if ( isdefined( info["name"] ) )
    {
/#
        println( "Precache: Guy has name ", info["name"] );
#/
    }
    else
    {
/#
        println( "Precache: Guy had no name!" );
#/
    }

    precachemodel( info["model"] );
    attachinfo = info["attach"];
    attachsize = attachinfo.size;

    for ( i = 0; i < attachsize; i++ )
        precachemodel( attachinfo[i]["model"] );
}

get_random_character( amount )
{
    self_info = strtok( self.classname, "_" );

    if ( self_info.size <= 2 )
        return randomint( amount );

    group = "auto";
    index = undefined;
    prefix = self_info[2];

    if ( isdefined( self.script_char_index ) )
        index = self.script_char_index;

    if ( isdefined( self.script_char_group ) )
    {
        type = "grouped";
        group = "group_" + self.script_char_group;
    }

    if ( !isdefined( level.character_index_cache ) )
        level.character_index_cache = [];

    if ( !isdefined( level.character_index_cache[prefix] ) )
        level.character_index_cache[prefix] = [];

    if ( !isdefined( level.character_index_cache[prefix][group] ) )
        initialize_character_group( prefix, group, amount );

    if ( !isdefined( index ) )
    {
        index = get_least_used_index( prefix, group );

        if ( !isdefined( index ) )
            index = randomint( 5000 );
    }

    while ( index >= amount )
        index -= amount;

    level.character_index_cache[prefix][group][index]++;
    return index;
}

get_least_used_index( prefix, group )
{
    lowest_indices = [];
    lowest_use = level.character_index_cache[prefix][group][0];
    lowest_indices[0] = 0;

    for ( i = 1; i < level.character_index_cache[prefix][group].size; i++ )
    {
        if ( level.character_index_cache[prefix][group][i] > lowest_use )
            continue;

        if ( level.character_index_cache[prefix][group][i] < lowest_use )
        {
            lowest_indices = [];
            lowest_use = level.character_index_cache[prefix][group][i];
        }

        lowest_indices[lowest_indices.size] = i;
    }
/#
    assert( lowest_indices.size, "Tried to spawn a character but the lowest indices didn't exist" );
#/
    return random( lowest_indices );
}

initialize_character_group( prefix, group, amount )
{
    for ( i = 0; i < amount; i++ )
        level.character_index_cache[prefix][group][i] = 0;
}

random( array )
{
    return array[randomint( array.size )];
}
