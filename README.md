# DeltaMacros
Macro recording tool that uses delta mouse movements, designed for games where normal macrorecorders fail.
It also records/plays back keyboard inputs.

This tool leverages the LLMouse/MouseDelta libraries by @evilC on the AHK forums:

https://www.autohotkey.com/boards/viewtopic.php?f=19&t=10159

https://www.autohotkey.com/boards/viewtopic.php?f=19&t=26137
They're included, so downloading them separately is not needed.

IMPORTANT: If you want to record the starting mouse position, you'll need to set "RecordInitialMousePos" to True. 

It's disabled by default as enabling it causes issues with games, which is the main purpose of this script.



You simply press F9 to start/stop the recording, which also saves it.

It'll be saved as currentscript_ some number, it avoids overwriting any existing ones.



Finishing the recording also starts the latest saved script, which can be played back with F4. 

Before you can record a new one you must quit out of the previous one with ALT-F12.

The scripts can also obviously be run by themselves, and the hotkeys are once again F4 and Alt-F12.


Thanks to @burque505 for the exit button code and @need4speed for making me notice I forgot to record mouse clicks.
