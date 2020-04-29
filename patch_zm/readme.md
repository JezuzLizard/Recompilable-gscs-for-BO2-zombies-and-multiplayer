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
patch_zm/maps/mp/zombies/_zm_audio.gsc
patch_zm/maps/mp/zombies/_zm_audio_announcer.gsc
patch_zm/maps/mp/zombies/_zm_bot.gsc
patch_zm/maps/mp/zombies/_zm_clone.gsc
patch_zm/maps/mp/zombies/_zm_ffotd.gsc
patch_zm/maps/mp/zombies/_zm_gump.gsc
patch_zm/maps/mp/zombies/_zm_magicbox.gsc
patch_zm/maps/mp/zombies/_zm_net.gsc
patch_zm/maps/mp/zombies/_zm_perk_electric_cherry.gsc
patch_zm/maps/mp/zombies/_zm_perks.gsc
patch_zm/maps/mp/zombies/_zm_pers_upgrades.gsc
patch_zm/maps/mp/zombies/_zm_pers_upgrades_system.gsc
patch_zm/maps/mp/zombies/_zm_powerups.gsc
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
patch_zm/maps/mp/zombies/_zm_spawner.gsc
patch_zm/maps/mp/zombies/_zm_utility.gsc
patch_zm/maps/mp/zombies/_zm_weapons.gsc
```
### The following scripts compile and run serverside but clients cannot join due to exe_client_field_mismatch
```
patch_zm/maps/mp/zombies/_zm.gsc
```
### The following scripts compile but cause a minidump or other severe error:
```
patch_zm/maps/mp/zombies/_load.gsc
patch_zm/maps/mp/zombies/_zm_pers_upgrades_functions.gsc
```
### The following scripts have been checked, but they have not been tested yet
```
patch_zm/maps/mp/zombies/_zm_blockers.gsc
patch_zm/maps/mp/zombies/_zm_buildables.gsc
patch_zm/maps/mp/zombies/_zm_equip_turbine.gsc
patch_zm/maps/mp/zombies/_zm_game_module.gsc
patch_zm/maps/mp/zombies/_zm_laststand.gsc
patch_zm/maps/mp/zombies/_zm_magicbox_lock.gsc
patch_zm/maps/mp/zombies/_zm_playerhealth.gsc
patch_zm/maps/mp/zombies/_zm_power.gsc
patch_zm/maps/mp/zombies/_zm_sidequests.gsc
patch_zm/maps/mp/zombies/_zm_stats.gsc
patch_zm/maps/mp/zombies/_zm_traps.gsc
patch_zm/maps/mp/zombies/_zm_turned.gsc
patch_zm/maps/mp/zombies/_zm_unitrigger.gsc
patch_zm/maps/mp/zombies/_zm_weap_cymbal_monkey.gsc
```
### The following scripts are not checked yet, uploaded to setup a baseline:
```
patch_zm/maps/mp/gametypes_zm/_callbacksetup.gsc
patch_zm/maps/mp/gametypes_zm/_damagefeedback.gsc
patch_zm/maps/mp/gametypes_zm/_dev.gsc
patch_zm/maps/mp/gametypes_zm/_gameobjects.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_actor.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_audio.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_defaults.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_player.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_score.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_spawn.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_ui.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_utils.gsc
patch_zm/maps/mp/gametypes_zm/_globallogic_vehicle.gsc
patch_zm/maps/mp/gametypes_zm/_gv_actions.gsc
patch_zm/maps/mp/gametypes_zm/_healthoverlay.gsc
patch_zm/maps/mp/gametypes_zm/_hostmigration.gsc
patch_zm/maps/mp/gametypes_zm/_hud.gsc
patch_zm/maps/mp/gametypes_zm/_hud_message.gsc
patch_zm/maps/mp/gametypes_zm/_hud_util.gsc
patch_zm/maps/mp/gametypes_zm/_menus.gsc
patch_zm/maps/mp/gametypes_zm/_perplayer.gsc
patch_zm/maps/mp/gametypes_zm/_serversettings.gsc
patch_zm/maps/mp/gametypes_zm/_spawning.gsc
patch_zm/maps/mp/gametypes_zm/_spawnlogic.gsc
patch_zm/maps/mp/gametypes_zm/_spectating.gsc
patch_zm/maps/mp/gametypes_zm/_tweakables.gsc
patch_zm/maps/mp/gametypes_zm/_weapon_utils.gsc
patch_zm/maps/mp/gametypes_zm/_weaponobjects.gsc
patch_zm/maps/mp/gametypes_zm/_weapons.gsc
```
### The following scripts have not been checked using the proper debugging methods:
```
//I will put these off to towards much later since the hacker and gas mask are parts of the game that do not exist inside the game in any capacity whatsoever.
//Therefore, whether or not they work is irrelevant.
patch_zm/maps/mp/zombies/_zm_devgui.gsc
patch_zm/maps/mp/zombies/_zm_chugabud.gsc
patch_zm/maps/mp/zombies/_zm_equipment.gsc
patch_zm/maps/mp/zombies/_zm_equip_hacker.gsc
patch_zm/maps/mp/zombies/_zm_equip_gasmask.gsc
patch_zm/maps/mp/zombies/_zm_hackables_boards.gsc
patch_zm/maps/mp/zombies/_zm_hackables_box.gsc
patch_zm/maps/mp/zombies/_zm_hackables_doors.gsc
patch_zm/maps/mp/zombies/_zm_hackables_packapunch.gsc
patch_zm/maps/mp/zombies/_zm_hackables_perks.gsc
patch_zm/maps/mp/zombies/_zm_hackables_powerups.gsc
patch_zm/maps/mp/zombies/_zm_hackables_wallbuys.gsc
patch_zm/maps/mp/zombies/_zm_jump_pad.gsc
patch_zm/maps/mp/zombies/_zm_mgturret.gsc
```
### notes:
```
The shaders that _zm_timer.gsc relies on do not exist.
```


