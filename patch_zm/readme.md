### The following gscs compile and run successfully with no known errors:
```
patch_zm/maps/mp/gametypes_zm/_clientids.gsc
patch_zm/maps/mp/gametypes_zm/_globalentities.gsc
patch_zm/maps/mp/gametypes_zm/_scoreboard.gsc
patch_zm/maps/mp/gametypes_zm/_shellshock.gsc
patch_zm/maps/mp/gametypes_zm/zclassic.gsc
patch_zm/maps/mp/zombies/_zm_ai_basic.gsc
patch_zm/maps/mp/zombies/_zm_ai_dogs.gsc
patch_zm/maps/mp/zombies/_zm_ai_faller.gsc
patch_zm/maps/mp/zombies/_zm_bot.gsc
patch_zm/maps/mp/zombies/_zm_clone.gsc
patch_zm/maps/mp/zombies/_zm_equip_hacker.gsc
patch_zm/maps/mp/zombies/_zm_equip_gasmask.gsc
patch_zm/maps/mp/zombies/_zm_ffotd.gsc
patch_zm/maps/mp/zombies/_zm_hackables_boards.gsc
patch_zm/maps/mp/zombies/_zm_hackables_box.gsc
patch_zm/maps/mp/zombies/_zm_hackables_doors.gsc
patch_zm/maps/mp/zombies/_zm_hackables_packapunch.gsc
patch_zm/maps/mp/zombies/_zm_hackables_perks.gsc
patch_zm/maps/mp/zombies/_zm_hackables_powerups.gsc
patch_zm/maps/mp/zombies/_zm_hackables_wallbuys.gsc
patch_zm/maps/mp/zombies/_zm_net.gsc
patch_zm/maps/mp/zombies/_zm_perk_electric_cherry.gsc
patch_zm/maps/mp/zombies/_zm_pers_upgrades.gsc
patch_zm/maps/mp/zombies/_zm_pers_upgrades_functions.gsc
patch_zm/maps/mp/zombies/_zm_pers_upgrades_system.gsc
patch_zm/maps/mp/zombies/_zm_server_throttle.gsc
patch_zm/maps/mp/zombies/_zm_score.gsc
patch_zm/maps/mp/zombies/_zm_tombstone.gsc
patch_zm/maps/mp/zombies/_zm_zonemgr.gsc
```
### The following scripts compile and run successfully with minor errors:
```
patch_zm/maps/mp/zombies/_zm_timer.gsc
```
### The following scripts compile and run successfully with major errors:
```
patch_zm/maps/mp/gametypes_zm/_zm_gametype.gsc
patch_zm/maps/mp/zombies/_zm_chugabud.gsc
patch_zm/maps/mp/zombies/_zm_magicbox.gsc
patch_zm/maps/mp/zombies/_zm_perks.gsc
patch_zm/maps/mp/zombies/_zm_powerups.gsc
patch_zm/maps/mp/zombies/_zm_weapons.gsc

```
### The following scripts compile and run serverside but clients cannot join due to exe_client_field_mismatch
```
patch_zm/maps/mp/zombies/_zm.gsc
patch_zm/maps/mp/zombies/_zm_gump.gsc
patch_zm/maps/mp/zombies/_zm_equipment.gsc
```
### The following scripts compile but cause a minidump or other severe error:
```
patch_zm/maps/mp/zombies/_load.gsc
```

### The following scripts are not tested yet, uploaded to setup a baseline:
```
patch_zm/maps/mp/zombies/_zm_audio.gsc
patch_zm/maps/mp/zombies/_zm_audio_announcer.gsc
```

### notes:
```
The shaders that _zm_timer.gsc relies on do not exist.
```


