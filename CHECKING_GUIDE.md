## Setup

In order to begin properly checking scripts for future usage you need the following:

https://github.com/Scobalula/Cerberus-Repo

https://drive.google.com/drive/folders/1Nwv3uGFwpopIMMXDVcZdG0iq2vQAVHc-?usp=sharing

https://drive.google.com/file/d/1Rt3sAIoYhCgqhsotrElygta7-BXn-3ZM/view?usp=sharing

Next you need to choose the script you want to check from the decompiled.zip you downloaded. Some scripts are harder and larger than others making them more time consuming to check.
Before you choose a script to check make sure it hasn't already been checked/tested by going to each name fast file folder and browse the manifest.md for the script you'd like to check.
Once you have chosen a script to start checking you are ready for the next part of the guide.

Now that you have the script you'd like to check you need to do the following:

Decompile the same script from cerberus: Which can be done by dragging and dropping the fast file ontop of cerberus.CLI and then browsing the extracted scripts folder for the script you would then like to decompile.
After you find the specific script you want to decompile drag and drop it on cerberus.CLI and then browse the processed scripts folder.

Obtain an IDE that supports GSC language highlighting: GSC studio is included in one of the google drive links but you can also use Visual Studio Code with this plugin installed:
https://marketplace.visualstudio.com/items?itemName=atrX.vscode-codscript.

NOT ALWAYS APPLICABLE:

Look for your script in the Old bo2 dump with comments and use it as an extra resource to complement cerberus. Generally if in doubt rely on this dump more than cerberus since this dump is leak of actual source.
However this dump only covers the scripts released with the initial release of the game and is not always representative of the current state of the game. 

The same goes for the bo1 and bo3 decompiled scripts.

Now that you have your IDE, and the scripts setup you can now begin the checking phase. 

## Checking

#### Checking Includes

First you must always check the includes to make sure they exactly match cerberus. By match I mean the actual scripts are all there and mentioned. Do not change the includes to #using you will get a syntax error.
If they do write ```//checked includes match cerberus output``` at the very top of the includes list. If they do not match copy and paste the missing the whole include list from cerberus and change the #using to #include.
Then write ```//checked includes changed to match cerberus output```

The reason includes must be checked is that in some cases they may be missing and if a script is not included it will not be loaded into memory. If a script that is not loaded into memory is referenced the game will crash.

Another type of inlude is ```#using_animtree( animTree )``` this include allows for reference to the animTree in script. The current version of the compiler does not support anim trees so it will crash in most cases if compiled.
Unfortunately this means if the animTree is not included by another script attempting to reference it will cause a crash and many scripts that deal with animations cannot be used. This is a warning so you won't be surprised if a script you check doesn't work without the animTree.

All hope is not lost however. The bo2 GSC compiler is open source: https://github.com/msfwaifu/bo2-gsc-compiler so feel free to fix the issue and release the compiler.

### Checking Functions

#### Check types

There are 4 types of checks I do when checking functions. All check messages are placed to the right of the function name.

The first kind of check is ```//checked matches <dumps you referenced> output``` where only syntax errors had to be fixed.

If compared to the other dumps minor changes, even as minimal as changing a number to match cerberus or the commented dump, are required then you would write ```//checked changed to match <dumps you referenced> output```.

If cerberus has a heart attack trying to decompile the script and the commented version is not available as a reference and even if it is but is too old to be relevant you would alter the function as best you can and then write ```//checked partially changed to match <dumps you referenced> output```

If you encounter a function of which the entirety of its contents are within a dev call which looks like this /# #/ you comment out the contents using /* */ to comment out entire blocks of code and then write ```//dev call did not check```.
Dev calls are not compiled by the compiler as such may result in errors because functions that are not permitted to be run outside of a dev call will be considered outside a dev call.

Additionally, each of these types of checks can have an extra modifier which is simply a reference to info.md. While checking if you encounter any issues check info.md in addition to this guide because there are several compiler limitations that have to worked around to successfully compile.
Simply write ```//<type of check> see info.md and optionally the type of alteration required to make it compile properly```.

#### Checking Process

Now that you know what type of checks you have to be doing now I will go over how to properly check a script. First I recommend using the decompiled.zip dump as a baseline script instead of cerberus. Neither dump is perfect so you need to use both to get closer to parity with the original script.
The reason I recommend using the decompiled.zip version as the base is that it uses bo2 syntax instead of bo3 syntax which is what cerberus uses. So you don't have to spend time fixing all the random syntax errors that cerberus will have. Also the formatting will be identical to the other scripts on the github.

##### Checking Variables

BO2 GSC supports storing floats, ints, strings, anim references, structs, conditions, vectors, undefined, functions and arrays. In all cases cerberus and the commented dump will always get these right. The decompiled.zip dump will sometimes get the vectors wrong if they are in a vectorScale().
Always check if an array is initialized as an array which is done like this ```array = [];```. Otherwise all variables are initialized as the type they are set to.
Also if using the decompiled.zip dump as a base double check the function pointers that reference another scripts function, they will have extra :: at the front simply remove the extra ::.

##### Checking Dvars

Cerberus will nearly never have the name for a dvar. The decompiled.zip dump will occasionally have the dvars name and the commented dump will always have the dvars name. Replace any hashed dvars names with the ones from the commented dump if possible.
Generally if a dvar name is hashed its because its in a dev call so it may not be relevant in most situations.

##### Checking Loops
BO2 GSC supports foreach, while, and for loops, well as recursion( Treyarch never uses it though ). Breaks and continues are also supported however the compiler will compile it incorrectly if the continue is in a for or foreach loop. Replace continues with if/else statements if they are inside of a for loop or foreach.
Otherwise convert a foreach or for loop with a continue into a while loop which will support continues. The decompiled.zip dump will always have a version of a loop that would work without continues. Sometimes the decompiled.zip dump will confuse if statements as a while loop so replace them with if statements.
If you are using the decompiled.zip dump as a base convert any while loops into whatever the cerberus equivalent is since in most cases its better to use the cerberus output.

##### Checking if/else and switch statements

Generally the cerberus output gets if/else statements correctly and the commented dump will always be correct in this situation. The decompiled.zip dump will occasionally switch around the conditions in if statements.
Check info.md for any limitations for conditions.

##### Checking notifies

The decompiled.zip dump will always miss extra inputs from notifies, but cerberus and the commented dump will always have them.

