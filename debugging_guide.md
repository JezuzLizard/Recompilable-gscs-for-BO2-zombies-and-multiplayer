## The Basics

Each of the decompilers isn't able to 100% decompile scripts exactly as the original script is.

However if you compare the outputs of multiple decompilers its possible to get a clearer picture of what the developers had actually coded.

### Common Decompiler Errors

#### 2014 dump

The basic bo2 zombies dump featured in the readme is from 2014 and in this guide will be refered to as the 2014 dump.

The 2014 dump is the best dump to start with as a base script since while it has many errors its output is the most similar to the original decompiled scripts.
However, it struggles with properly placing devcalls, and misidentifies periods as commas so definitely check waits and other functions that use decimal inputs.
Additionally the 2014 dump doesn't ever use for loops or foreaches so as a result it uses some odd logic at times.

The 2014 dump also will misidentify if statements as while loops as well as improperly place if/else statements.
The 2014 dump may also misidentify conditions in if/else statements.
The 2014 dump may mistakenly add extra :: at the start of a pointer calling a function from another script.

Finally the 2014 dump has an issue where it uses the wrong numbers when dealing with functions using vector type functions.

#### Cerberus Decompiler dumps

The Cerberus Decompiler works well with if/else statements and can output code using for loops and foreaches unlike the 2014 dump.

However, the Cerberus Decompiler should not be used as a base script since its output is intended for use in bo3 scripting, and as a result would have a lot of errors.
The Cerberus Decompiler is similar to the 2014 dump except it doesn't misplace devcalls, and commas.
Just like the 2014 dump it may also misidentify if/else statement conditions.

### Debugging Methodology 

The current method used is to compare each function from a script from the 2014 dump to the Cerberus Decompiler's output,
Copying code from the Cerberus Decompiled output if the code from the 2014 dump looks wrong is recommended.
Each time you do this make sure to indicate that the code was checked in a comment next to the function so that way its easy to tell what functions have been checked and changed from their original outputs
Once you have checked the code in a script try compiling it and test it to see what errors occur.

Always check if statements with many different conditions. Never use continues in foreach or for loops it will cause an infinite loop for an unknown reason. Always check the numbers values and order of operations between the scripts the cerberus decompiler is always correct about the values of numbers but does not account for order of operations. Make use of the debugging mod once your script is compileable and runs without crashing( zombies only for now ).

If you need more help contact me on my Discord username JezuzLizard#7864.

**Common Errors**

Infinite While Loop Without Wait:

When its not possible to connect to the server but its running that means there is an infinite loop with no wait active.

This can also happen ingame but the zombies freeze and the ammo counter freezes.

This can also happen when a client connects so controls are frozen.

This can also happen with a blackscreen that doesn't pass.


