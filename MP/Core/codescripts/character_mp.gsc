// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include codescripts\character;

setmodelfromarray( a )
{
    self setmodel( a[randomint( a.size )] );
}

precachemodelarray( a )
{
    for ( i = 0; i < a.size; i++ )
        precachemodel( a[i] );
}

attachfromarray( a )
{
    self attach( codescripts\character::randomelement( a ), "", 1 );
}
