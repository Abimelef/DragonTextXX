# DragonTextXX
6809 assembler routines to enable 32, 51 or 64 column test on the Dragon 32 or Dragon 64 graphics screen

Txx – Routines for Switching Dragon 32 and 64 text output to the graphics screens
The routines are:
• T32 - 32 column by 24 row text in PMODE 4
• T51 - 51 column by 24 row text in PMODE 4
• T64 - 64 column by 24 row text in PMODE 4
• T32c - 32 column by 24 row colour text in PMODE 3
(T32w is also included, it is T32 with a silly font (Westminster) for demonstration purposes)

Quick Start

For quick demonstration “insert” the disk drive file txx.dsk into XROAR and load and run “DEMO.BAS”.
To run the programs separately insert txx.dsk , type “CLEAR 200,31000” and then LOAD and EXEC say “T64.BIN”. Then enter something like “PMODE 4:SCREEN 1,0:TEON” and you should be in T64 mode. Use “T32.BIN” for 32 column, “T32C.BIN” for 32 column colour and “T51.BIN” for 51 columns.
TEOFF returns you to the normal text screen, TCLS clears the graphics screen and resets the print position to the top left, AT x,y sets the print position to row x, column y. TCOL (no parameter) flips the colours when in monochrome mode. TCOL ink, paper (where both are 0 to 3) sets the ink and paper colours for the 32 column colour mode. Note that you will get an error if you try to set ink = paper.

Alternatively, if you are not using disks and want to run Txx on a real dragon:
Select one of the cassette files “Dragon 32” etc as the input cassette or set it up on your sound output device if you are connecting to a real Dragon
Clear some upper memory space (the address to clear above does not have to be precise, Txx sorts it out when it runs, the largest routine (“T32C”)needs about 1480 bytes to install and a little less when running)
e.g. Clear 200,31000
then CLOADM and EXEC.
This installs the routine and adds the new keywords to BASIC but does not activate the graphics text
For T32, T32west, T51 and T64
Enter PMODE 4:SCREEN 1,0:TEON
Or if you prefer
10 PMODE 4 20 SCREEN 1,0 30 TEON
RUN
For T32c use PMODE 3
You can also “LOAD” the .bin files directly into XROAR but do not use the “RUN” file option as it will crash (discussion below). Having loaded the bin file use EXEC addresses in the file “txx file sizes.txt”.

How it Works

When turned on the routines intercept the line in (to flash the cursor) and character out ram hooks and generates the appropriate characters on the graphics screen. It also uses the ram hook for key in to check for use of the clear and break keys since they both affect text output position.
The bitmaps for the graphics text characters are held at the top of memory. To save space only characters 32 to 132 are used. Characters are stored as eight, one byte slices. Using larger character sets is simple but typically you will need to reassemble the binaries (see below).

Txx comes in separate versions for each combination of 32, 51, 64 and 32 column colour and Dragon 32, Dragon 64 and Dragon 32 with disk system. The Dragon 32 versions should run on a 64 when it is in Dragon 32 mode. As far as I can tell you cannot have a Dragon 64 running in 64K mode with a disk system so there are no versions for that (though it maybe it would be possible to get Txx to reside in the unused 16K when a Dragon 64 is in 32K mode with disks running?).

Note that Txx needs some code to load that it does not need when running. Once loaded the routines call part of the BASIC CLEAR routine to reset the top of memory to just below the code it needs to run. This saves about 100 bytes. On the downside it wipes any BASIC variables in memory. It also caused a crash if you try to directly run a BIN file from XROAR. This seems to be because the run routine in XROAR seems to need the system stack intact and CLEAR resets it.

To improve speed and save memory when you use TCOL it changes the colours of the character set in memory. This means you get an error in colour mode if you try to set ink = paper. If the system allowed this you could never get the character set back to different ink and paper as the recolour routine could not tell what was meant to be ink and what was meant to be paper. You will also get an error if you try TEON in PMODE 1 or 2 as otherwise it could result in the system overwriting the BASIC program area.

Creating the bin files

Txx.asm is the master assembly language file for all versions of Txx. Running the PC batch file makeTxx.bat (ideally from the command prompt so you can see any errors) will generate all versions of Txx.
makeTxx.bat sets key parameters used in the assembly language file as to which version of Txx to generate on each pass. They can be set manually within Txx.asm if you only wish to generate one version at a time. See comments in Txx.asm.
makeTxx.bat assembles each version of Txx.asm twice. The first time is to find the size of the assembled binary file and the second time to use that size to set the header of the binary file so XROAR knows where to load the binary so it is snug against the top of RAM. It also generates the text file “txx file sizes.txt” which lists the size and EXEC address of each version of Txx.
txxMake.bat assumes the assembler asm6809 is installed with its .exe file in the same folder as txxMake.bat etc or pointed to by your PATH system variable.

There is a switch in the Txx.asm file for systems using the Cumana disk interface. I have not tested this and the makeTxx.bat files will not generate Cumana versions. You will need to edit Txx.asm directly, reassemble and see if it works.
To turn XROAR bin files into Dragon cassette or disk files load the bin and then, before you run the bin, use CSAVEM “NAME”, start-address, top-of-RAM, start-address where start-address is found in “txx file sizes.txt” or by checking the file size after assembly and subtracting it from the top-of-RAM. For disk systems use SAVE “NAME”, start-address, top-of-RAM, start-address. The resulting files can be LOADed and EXECed directly in XROAR.

Character Sets

The character set is stored between whichever version of Txx is running and the top of RAM. Typically, there are 100 characters so the character set starts at 32767 - 800 in the Dragon 32 and 49272-800 in the Dragon 64. If you define a larger character set and reassemble the binaries to use it the characters will start at number of characters x 8 below the top of RAM. They can be changed directly by the Dragon by poking values to the appropriate memory addresses.

Character sets can be defined and edited using the Windows App DragonChrDesigner.exe (copy in the ChrBitMaps folder).

• Select character you wish to design by typing its ASC code in the box towards the top left, or clicking on it (if previously defined) in the box at the bottom that displays all characters.
• Characters are defined as black ink on green paper.
• Typically you need to leave a blank column on one side of a character and a blank line at the top or bottom so characters have spaces between them when printed. I’ve found it is better to leave the left column and top line blank as it reduces clashes with the screen border.
• For 32 column mode the characters are eight bits wide (less one for spacing) so you most letters you have seven bits to play with.
• For 51 column mode characters are five bits wide total. You must use the five leftmost bits of the character design grid. Anything in the rightmost three bits is ignored by Txx.
• For 64 column mode characters are four bits wide so only three are available for letters etc which is a challenge but just about works. You must use the four leftmost bits of the character design grid. Anything in the rightmost four bits will be lost (see next point).
• To speed up 64 column mode each character needs to be duplicated in the left and right four bits of each byte. The “Mirror” button does this for you. Use it before saving the character set. Top tip – keep one version of a 64 column character set un-mirrored and use it to work on before saving a mirrored set under a different name.
• Character sets for 32 column colour mode should be designed as if for 64 columns (but do not use mirror). Before saving check the “Save as colour 32 column PMODE 3” box and select the ink and paper colours (I recommend 1,2 to begin with). Once saved character sets for this mode become very difficult to edit (as two bits are used for each pixel) so save first under a different file name without checking the PMODE 3 box and use that version for further edits.
• The “nudge” buttons will move the whole character set one bit up, down, left or right. The bits that disappear off the screen when doing this cannot be retrieved so be careful.
• Alternative character sets you create can be loaded into Txx but changing the references at the bottom of the Txx.asm file.
• For larger character sets change the size limit in the box on the left of the screen (up to 255). There is no facility at present to allow characters below no. 32 to be defined.
