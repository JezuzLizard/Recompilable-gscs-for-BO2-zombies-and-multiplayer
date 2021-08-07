
init() //checked matches cerberus output
{
	level.clientid = 0;
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player.clientid = level.clientid;
		level.clientid++;
	}
}
