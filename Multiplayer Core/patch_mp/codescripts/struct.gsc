// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

initstructs()
{
    level.struct = [];
}

createstruct()
{
    struct = spawnstruct();
    level.struct[level.struct.size] = struct;
    return struct;
}

findstruct( position )
{
    foreach ( key, _ in level.struct_class_names )
    {
        foreach ( val, s_array in level.struct_class_names[key] )
        {
            foreach ( struct in s_array )
            {
                if ( distancesquared( struct.origin, position ) < 1 )
                    return struct;
            }
        }
    }
}
