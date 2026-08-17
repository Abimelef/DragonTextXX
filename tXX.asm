;Txx © 2020 Allan K Macpherson
;LICENCE
;This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program. If not, see
;<http://www.gnu.org/licenses/>.


;TODO
;Add CoCo option ?
;would need system variable and ROM addresses changed

;compile once to check length, alter "FileSize" number to match and recompile. Leave commented out if passing size as parameter to assembler
;FileSize equ 1446	;decimal length of compiled file 

	org	$BFFF-FileSize			;code is position independant so this is not critical


;Modify the print routine and LasCol to change screen width from 64 colums to 32 or 51
;"uncomment" a line and set one of T32c etc to 1 if not passing as parameters in assembler command line (the latter is better as it allows use
;of a make file that will generate all versions of Txx in one go
;T32c equ 0					;set to 1 to compile for 32 column PMODE 3 colour text
;T32 equ 0					;set to 1 to compile for 32 column PMODE 4 monochrome text
;T51 equ 0					;set to 1 to compile for 51 column PMODE 4 monochrome text
;T64 equ 1					;set to 1 to compile for 62 column PMODE 4 monochrome text

;Compile for Dos?
;CompilingForDOS equ 0			;set to 1 to compile for Dos, 0 for no dos

CUMANA equ 0					;set to 1 to complule for CUMANA (Compiling for DOS should also be set to 1)

BlinkingCursor 	equ 1			;blinking cursor needs extra 46 bytes 
SolidCursor 	equ 0			;one, and only one of these two options should be set to 1. Using a solid cursor saves a few bytes

;Dragon 64 or 32?
;CompilingForDragon64 equ 0 	;do not set this to 1 and CompilingForDOS to 1 at the same time

;Header to make bin file load properly in XROAR
;Using "run" in XROAR will cause a crash. "Load" the bin file and then use EXEC $BFFF-filesize for D64 and $7FFF-filesize for D32

	FCB $55						;constant
	FCB $02						;file type $01 for BAS, $02 for BIN
	IF CompilingForDragon64
	FDB $BFFF-FileSize			;LOAD is the data load address
	ELSE

;	FDB $7FFF - FileSize
	FDB $8000 - FileSize

	ENDIF
	FDB FileSize				;decimal length of compiled file - compile once to check length, alter this number to match and recompile
	IF CompilingForDragon64
	FDB	$BFFF-FileSize			;EXEC is address stored in $9d:9e for default EXEC. If the BIN file is RUN this defines the entry point.
	ELSE
;	FDB $7FFF - FileSize
	FDB $8000
	ENDIF
	FCB $AA						;Constant

;Standard Dragon character or key codes
chrBackspace 			equ $08
chrWhiteSpace 			equ $20
chrBlackSpace			equ $80
chrNewLine 			equ $0D
chrNonPrint 			equ $1F			;last non printing chr

;Break and Clear keys
keyClear				equ $0C			;clear key
keyBreak				equ $1B			;escape key

;Dragon system variables in zero page
DeviceNumber 			equ $6F			;Device number, 0-console, -l-cassette, -2-printer
LRCursPos 				equ $88			;ordinary low res text cursor position
EOFFlag				    equ $70			;end of file flag
TopOfMemforBASIC		equ $27			;set by BASIC CLEAR statement
PMODENum				equ $B6			;Graphics PMODE number in use (0x00)
ScreenStartAddress	    equ $00BA		;holds start address of active graphics screen
ScreenEndAddress		equ $00B7		;one past end of active screen                                   
Stub1NumResWords        equ $12A        ;Stub 1 - number of reserved words
Stub1ResWrdTble         equ $12B        ;address of reserved words table
Stub1DispRoutine        equ $12D        ;address of stub1 dispatch table
SizeDosRWTable          equ $81         ;size of Stub1 reserved words table in ROM
DOSNumResWords          equ $1A         ;26 - the number of DOS reserved words (commands)
DOSResWordsTable        equ $DED4       ;Location of DOS reserved words list in ROM
DOSDispRoutine          equ $C64C       ;Location of DOS dispatch routine in ROM


;Dragon text and graphics screen addresses
LRTxtScreenStart 		equ $400
LRTxtScreen2ndPos		equ $401

;Dragon ROM routines
	IF CompilingForDragon64
NonConsoleChrIn 		equ $B513+$4000				;input chr routine if not from console
ScanKB					equ $8006+$4000				;scan keyboard
EndChrIn				equ $F4C2					;the ROM routine that deals with a character after input is in a different relative postion in the D64 
													;it is at $B4C2+$4000 rather than $B542+$4000. Maybe this is due to the autorepeat routine?
GetByteParamInB		    equ $8E51+$4000				;returns a one byte parameter from a BASIC command in b
FindAndSkipComma 		equ $89AA+$4000				;finds and skips a comma in BASIC command parameters
RaiseFCError			equ $8B8D+$4000				;raise function call error
RaiseSNError			equ $89B4+$4000				;raise syntax error
ProcessStdKeyword 	    equ $84ED+$4000				;routine that handles normal (i.e. not new) BASIC commands and functions
ClearCommand			equ $8584+$4000				;enters CLEAR command part way through to change memory settings
Printd					equ $957A+$4000				;prints value in d to DEVN, handy for debugging
TextScreenNewLine		equ $90A1+$4000				;advances print position to next line of text screen
PrintString			    equ $90E5+$4000				;Out String: Prints ASCIIZ string ptd to by X to DEVN
Pcls					equ $A8C4+$4000				;clears graphics screen to colour in b


	ELSE
NonConsoleChrIn 		equ $B513					;input chr routine if not from console
ScanKB					equ $8006					;scan keyboard
EndChrIn				equ $B542					;deal with chr after input (parse it etc)
GetByteParamInB		    equ $8E51					;returns a one byte parameter from a BASIC command in b
FindAndSkipComma 		equ $89AA					;finds and skips a comma in BASIC command parameters
RaiseFCError			equ $8B8D					;raise function call error
RaiseSNError			equ $89B4					;raise syntax error
ProcessStdKeyword 	    equ $84ED					;routine that handles normal (i.e. non added) BASIC commands and functions
ClearCommand			equ $8584					;enters CLEAR command part way through to change memory settings
Printd					equ $957A					;prints value in d to DEVN
TextScreenNewLine		equ $90A1					;advances print position to next line of text screen
PrintString			    equ $90e5					;Out String: Prints ASCIIZ string ptd to by X to DEVN
Pcls					equ $A8C4					;clears graphics screen to colour in b

	ENDIF

DTokLastC	            EQU	$CD                     ;Last regular basic keyword token
DDTokLastC              EQU $E7                     ;last DOS keyword token
TxxTokFirst             EQU $E8                     ;First Txx keyword token

DOSChrOut				equ $D917
DOSChrIn				equ $C27E


;Op codes
JmpOpCode 				equ $7E
RtsOpCode				equ $39

;RAM Hooks
RamHookChrOut			equ $167
RamHookChrOutAddress	equ $168
RamHookChrIn			equ $16A
RamHookChrInAddress		equ $16B

UsrPtr 				equ   $B0		    ; POINTER TO USR VECTOR BASE

	IF T32
NumCols 				equ $20			;screen width in columns 32 in decimal
LastCol					equ $1F
	ELSIF T32c
NumCols 				equ $20			;screen width in columns 32 in decimal
LastCol					equ $1F
	ELSIF T51
NumCols 				equ $33			;screen width in columns 51 in decimal
LastCol					equ $32
	ELSIF T64 
NumCols 				equ $40			;screen width in columns 64 in decimal
LastCol					equ $3F
	ENDIF
	
;all versions use a 24 line screen
LastRow 				equ $17			;row 23
NumRows 				equ $18			;screen depth in rows 24 in decimal

ChrSetSize				equ 808		;total number of bytes in character set

    IF CompilingForDos
NumNewWords equ 5		;Number of new words to be added
    ELSE
NumNewWords equ 6		;DOS needs a command (TEXIT) to remove Txx if versions (T32, T51, T64 etc) are to be swapped without a reset
    ENDIF



;================================================================
;entry point
;================================================================

;==================================
;Compiling for DOS
;==================================
;set up dispatch table for new basic words (allows code to be relocatable)
	IF CompilingForDOS          ;Using Stub2 to add new words when using DOS works in XROAR
                                ;but not not on an actual Dragon (I need to figure out why).

    LDA Stub1NumResWords        ;save number of DOS words          
    STA NumDosWords,PCR 
    LDX Stub1ResWrdTble         ;address of original DOS reserved words table
    STX DosWordTable,PCR

    ORCC #$50                   ;Binary 01010000 - sets FIRQ and IRQ to 1 i.e. disables interrupts
    LDX Stub1DispRoutine        ;Stub1 entry in zero page - address of dispatch routine
    STX DOSDespatch,PCR         ;Store address of Stub1 dispatch routine in DOSDespatch - used to jump to DOS command handler if command is not an added one                  
    LDX Stub1ResWrdTble         ;Stub1 address of reserved word table
    LEAY NewWords,PCR           ;Y= memory address of NewWords
  
    LDB #SizeDosRWTable         ;$81 number of bytes taken by Stub1 reserved words list (DOS Commands)
SCL LDA ,X+                     ;copy existing Stub1 reserved words table to memory starting at NewWords
                                ; (which will then have the ram disk new words following the DOS words)
    STA ,Y+
    DECB
    BNE SCL
    LDA #NumNewWords            ;A = number of new commands (10)
    ADDA Stub1NumResWords       ;add to existing number of commands in Stub1
    STA Stub1NumResWords        ;Stub1 num res words num equals the DOS total (if used) plus the num of new commands, this prob works with or without DOS!
    LEAX NewWords,PCR           ;Point Stub1 to moved and extended words table
    STX Stub1ResWrdTble
    LEAX Despatch,PCR           ;X = address of new DESPATCH table 
    STX Stub1DispRoutine        ;Point Stub1 at new DESPATCH table
    ANDCC #$AF                  ;Binary 1010111 - sets FIRQ and IRQ to zero enabling interrupts
;Set up jump table
	leax at,pcr
	stx JmpAt,pcr
	leax teon,pcr
	stx JmpTeon,pcr
	leax teoff,pcr
	stx JmpTeoff,pcr
	leax tcol,pcr
	stx JmpTcol,pcr
	leax tcls,pcr
	stx JmpTcls,pcr
    leax texit,pcr
    stx JmpTexit,pcr
 
    RTS
 
DOSDespatch RMB 2                   ;gets set to address of Stub1 dispatch table
NumDosWords RMB 1                   ;number of DOS words - stored for use by TEXIT
DosWordTable RMB 2                  ;DOS reserved words table - stored for use by TEXIT

Despatch
    CMPA #TxxTokFirst          ;DDTokLastC = last DOS keyword token so DDTokLastC+1 is the first Txx keyword                      
    BLO  DosCommand             ;not one of the new ones so go process a Dragon DOS command
    CMPA #TxxTokFirst+NumNewWords
    BHS DosCommand              ;Not a TXX command - prob not a DOS command either and probably an error by the ROM routine can handle it
    SUBA #TxxTokFirst           ;set up position in dispatch table to use
    LEAX NewWordsDespTbl,PCR    ;point x to Txx commands dispatch table    
    JMP ProcessStdKeyword       ;jump to ROM routine that will use the dispatch table to jump to the new command
DosCommand JMP [DOSDespatch,PCR];go process normal DOS command

    ELSE
;==================================
;Compiling non DOS Versions
;==================================
;Relocate user vectors	
	leax NewUser,pcr			;Relocate the USR
	stx UsrPtr					;vectors
	ldy #RaiseFCError			;and initialise
	lda #10 
wl2
	sty ,x++					;them to FC Error (so if Usr is used before setting the vectors an error results - this will wipe any existing Usr vectors)
	deca						;continue until all
	bne wl2					;done
;done relocating user vectors

	clr Stub1NumResWords+10			;indicate end of stubs
	lda #NumNewWords
	sta Stub1NumResWords
	leax NewWords,pcr
	stx Stub1ResWrdTble
	leax Dispatch,pcr
	stx Stub1DispRoutine

	leax at,pcr
	stx JmpAt,pcr
	leax teon,pcr
	stx JmpTeon,pcr
	leax teoff,pcr
	stx JmpTeoff,pcr
	leax tcol,pcr
	stx JmpTcol,pcr
	leax tcls,pcr
	stx JmpTcls,pcr
    RTS                     ;need this RTS if the code above to save bytes using the  clear routine is not used.
    
NewUser rmb 20					;Space for relocated USR vector table

    
Dispatch 				;token to be processed is in reg a
NumExistingWords equ $CE
	cmpa #NumExistingWords				;Check that (1A works with DOS cart inserted)
	blo err				;check token given
	cmpa #NumExistingWords+NumNewWords		;is within range
	bhs err				
	suba #NumExistingWords				;Convert to table index
	leax NewWordsDespTbl,pcr		;and set up table base
	jmp ProcessStdKeyword				;before jumping to BASIC
err jmp RaiseSNError		;jump to syntax error
 
    ENDIF                       
;============================================================
;End of different initialisation blocks for DOS and non DOS
;============================================================

NewWords 
    IF CompilingForDOS
    RMB 129                    ;reserve space for relocated Stub1 words (DOS Commands)
    ENDIF
;now the words we are adding 
	FCC /A/				;AT			change print position to row,column
	FCB 212
	FCC /TEO/			;TEON		TExt ON
	FCB 206
	FCC /TEOF/			;TEOFF		TExt OFF
	FCB 198
	FCC /TCO/			;TCOL		TExt Colours (no parameter for monochrome builds, ink,paper for T32c
	FCB 204
	FCC /TCL/			;TCLS		TextCLearScreen
	FCB 211
    IF CompilingForDOS
    FCC /TEXI/          ;TEXTIT     Text off and delete extra words (needed in DOS version to be able to switch between different column versions)       
    FCB 212
    ENDIF

NewWordsDespTbl
JmpAt rmb 2
JmpTeon rmb 2
JmpTeoff rmb 2
JmpTcol rmb 2
JmpTcls rmb 2
JmpTexit
    IF CompilingForDOS
    rmb 2
    ENDIF

;extra command for DOS to safely remove Txx from the system. 
;This allows a new version (e.g. different column number)
;to be loaded and run without a system reset.
texit                           
    IF CompilingForDOS
    lbsr teoff                  ;turn off text redirection and reset Stub1. 
    ORCC #$50                   ;Binary 01010000 - sets FIRQ and IRQ to 1 i.e. disables interrupts
    ldx DOSDespatch,PCR  
    stx Stub1DispRoutine        ;Stub1 entry in zero page - address of dispatch routine
    LDA NumDosWords,PCR         ;restore number of DOS words          
    STA Stub1NumResWords 
    LDX DosWordTable,PCR        ;restore address of original DOS reserved words table
    STX Stub1ResWrdTble            
    ANDCC #$AF                  ;Binary 1010111 - sets FIRQ and IRQ to zero enabling interrupts
    RTS    
    ENDIF

;set print position to row,col
at							;at command format is AT row,col
	jsr GetByteParamInB		;get row 
	cmpb #LastRow
	bgt fcerr
	stb row,pcr
	jsr FindAndSkipComma
	jsr GetByteParamInB		;get col
	cmpb #LastCol
	bgt fcerr
	stb col,pcr
	rts


fcerr jmp RaiseFCError


;Routines to set ink and paper colours
;##############################################
;T32c = T32 In PMODE 3 colour
	IF T32c

tcol						;sets the ink and paper colours
	jsr GetByteParamInB		;get ink no.
	cmpb #3					;max value for ink or paper
	bgt fcerr

	stb NewInk,pcr
	stb InkTemp,pcr

	jsr FindAndSkipComma		;get paper no.
	jsr GetByteParamInB	
	cmpb #3						;max value for ink or paper
	bgt fcerr

	cmpb NewInk,pcr
	beq fcerr					;cannot have ink = paper (all chr defintions would become blank and there would be no way to restore them
								;as TCOL depends on altering chr defintions (no reference set kept)
	stb NewPaper,pcr
	stb PaperTemp,pcr

;create a byte that is all paper to use in blanking bottom line when scrolling
	lda #%01010101				;this multiplied by paper colour will put paper colour in each nybble.
	mul
	stb paperByte,pcr

;set chr colours
;for each slice of a chr check rightmost bit pair to see whether it is paper or ink
;update new slice in b accordingly
;shift a and b two bits to the right
;repeat for all four bit pairs
;and change old ink to new ink and old paper to new paper

	ldb NewPaper,pcr				;shift NewPaper six bits left so bit pair is in the leftmost bits i.e. %0000011 becomes %11000000
	lda #64
	mul
	stb NewPaper,pcr

	ldb NewInk,pcr					;shift NewInk six bits left so bit pair is in the leftmost bits i.e. %0000011 becomes %11000000
	lda #64
	mul
	stb NewInk,pcr	


	ldu #0						;set chr loop counter to 0
	leax chrs,pcr				;point x at start of characters

chrColourSetLoop
	ldy #4							;count of bit pairs				
	lda ,x							;load a with a character slice
	clrb							;set b to zero
BitPairLoop							;BitPairNo
	anda #%00000011					;get two righmost bits of slice
	cmpa Paper,pcr					;check if they are set to current paper or ink
	beq BitPairSetToPaper
BitPairSetToInk
	orb NewInk,pcr					;set two leftmost bits of b to the new ink colour
	bra FinishedSettingBitPair
BitPairSetToPaper
	orb NewPaper,pcr				;set two leftmost bits of b to the new paper colour
FinishedSettingBitPair
	cmpy #1
	beq EndBitPairLoop
	lsrb							;shift b right by two bits
	lsrb
	lda ,x							;load a with character slice
	lsra							;shift it two bits right
	lsra
	sta ,x							;save it
	leay -1,y						;dec bit pair no counter
	bne BitPairLoop 				;next bit pair
EndBitPairLoop	
	stb ,x+							;store modified slice and point x at next slice
	leau 1,u
	cmpu #ChrSetSize
	bne chrColourSetLoop
EndChrLoop

	ldd InkTemp,pcr
	std Ink,pcr

	rts

ChrLoop rmb 2
Ink	FCB 1						;default to yellow text 
Paper FCB 2						;on blue background
NewInk rmb 1
NewPaper rmb 1	
BitPairNo rmb 1	
InkTemp rmb 1
PaperTemp rmb 1
paperByte FCB %10101010			;blue byte

	ELSE
;###############################################	
tcol							;for monochrome routines no parameter, just inverts chrs
	com Ink,pcr
	leax chrs,pcr
	ldy #0
chrColourLoop	
	com	,x+
	leay 1,y
	cmpy #ChrSetSize+1
	bne chrColourLoop
	rts

Ink	FCB 0						;0 = black, 255 = green/white

	ENDIF
;###############################################


;clear screen and set print position to top left
tcls
	lbsr ClearScreen
	rts


;{ teoff - text off routine
	IF CompilingForDOS
teoff
	ldx	#DOSChrIn
	stx	RamHookChrInAddress
	ldx #DOSChrOut
	stx RamHookChrOutAddress
	rts
	ELSE
teoff
	lda	#RtsOpCode
	sta	RamHookChrOut
	sta RamHookChrIn
	rts
	ENDIF
;}


;{ teon - turn hi-res text on
teon

	lda PMODENum							;check we are in the correct PMODE
	IF T32c								;Use of TEON with PMODE 1 or 2 could overwrite
	cmpa #3								;BASIC storage and cause a crash 
	lbne fcerr
	ELSE
	cmpa #4
	bne fcerr
	ENDIF

	lda	#JmpOpCode
	leax start,pcr
	stx	RamHookChrOutAddress				;change 2 and 3rd butes of ram hook to address of "start"
	sta	RamHookChrOut						;change ram hook to jmp op code
	leax keys,pcr							;address of routine to flash cursor and check for clear or break key during test input
	stx RamHookChrInAddress				;RAM hook for get single character from keyboard
	sta RamHookChrIn						;used to intercept clear key
	lbsr ClearScreen
	rts


row FCB 0						;row to print on (starts at row 0 goes up to LastRow)
col FCB 0						;column to print on (from zero to LastCol)

start										;entry point to print chr on screen
	tst	<DeviceNumber						;check it is printing to screen not cassette or printer
	beq	HandleChr							;if it is the screen go handle the character
	IF CompilingForDOS
	jmp DOSChrOut
	ELSE
	rts
	ENDIF
	
;Process character prior to printing if appropriate
HandleChr
	leas 2,s							;pop normal return address as we don't want to print to the text screen
	pshs y, x, b,a,u					;save register contents	
	ldx	#LRTxtScreen2ndPos			;needed to make sure we get proper line feeds during a list command
	stx	<LRCursPos						;set normal text cursor position to second space on screen
	cmpa #chrBackspace				;check for backspace
	bne notBackspace
;handle backspace key - should not get here if already at zero in chr buffer
	ldb col,pcr							;check cursor not at column zero
	bne StillOnSameRow 					;if not we can backspace by moving the cursor one to the left
	ldb row,pcr							;otherwise we need to move up a row
	beq UpdatePrintPos 					;unless already at position 0,0
	decb								;reduce row by one
	stb row,pcr	
	ldb #LastCol						;set column to rightmost
	stb col,pcr
	bra BlankPrevChar					;clear the previous chr
StillOnSameRow
	decb								;move one to the left
	stb	col,pcr
BlankPrevChar
	leay row,pcr
	lda	#chrWhiteSpace
	lbsr print
	bra UpdatePrintPos
notBackspace
	cmpa #chrNewLine					;is chr "newline" i.e. return 
	beq NewLine
	cmpa #chrNonPrint					;non printing chr?
	bhi PrintChr						;no so go print it
	bra UpdatePrintPos				
PrintChr
	leay row,pcr						;point y to row number (next byte is col number)
	lbsr print							;print chr in a to screen, y points to row|col
	inc col ,pcr						;move one to the right
UpdatePrintPos
	ldb col,pcr						;have we reached the end of a row
	cmpb #NumCols
	bne EndHandleChr					;no so jump to end of routine
	clr col,pcr							;new print position would be one column right of end of row
	inc row,pcr							;so increase the row number
	lda row,pcr						
	cmpa #NumRows						;check if we are on the last row
	bne EndHandleChr					;if not we are done
	bsr ScrollUp						;otherwise scroll the screen up
	lda #LastRow						;and set row to last row	
	sta row,pcr
EndHandleChr
	puls a, b, x, y, u,pc				;restore registers (including PC to jump back to calling routine)
;}

NewLine									;return key pressed or newline code sent
	ldb #NumCols						;
	stb col,pcr							;set column to past end of row to force UpdatePrintPos to start a new line 
	ldx	#LRTxtScreenStart				;set ordinary text screen cursor 
	stx	<LRCursPos
	bra	UpdatePrintPos

;{ Scroll Up Routine
ScrollUp
	ldx ScreenStartAddress				;Top left of high res screen
	leay $100,x							;add 8 x 32 = 256 to y to get first byte of second row
ScrollLoop
	ldd ,y++
	std ,x++
	cmpy ScreenEndAddress
	bne ScrollLoop

;blank bottom row

	IF T32c
	ldb paperByte,pcr
	lda paperByte,pcr
	ELSE
	ldb Ink,pcr
	lda Ink,pcr
	coma								;set msb of d to inverse of ink colour
	comb								;set lsb of d to inverse of ink colour
	ENDIF
BlankLoop
	std	,x++
	cmpx ScreenEndAddress
	bne BlankLoop
	rts



;routine to flash cursor while waiting for input (during INPUT command or code input)
;and check for clear screen or break key
;code is copied from the ROM routine but with changes to call the graphics clear screen routine
;when Clear is pressed, newline when Break is pressed
;and to show a cursor on the hi-res screen

keys
	clr	<EOFFlag					;not sure this is needed
	tst	<DeviceNumber				;check input is from console (not file on cassette etc)
	beq	ConsoleIn
	IF CompilingForDOS
	jmp DOSChrIn
	ELSE
	jmp	NonConsoleChrIn				;back to Dragon ROM to handle cassette input
	ENDIF
ConsoleIn
	leas	2,s						;pop return address so key not handled twice
	pshs	x, b					;save registers

	IF SolidCursor					;option to save some memory by not flashing the cursor
	bsr SetCursor
	ENDIF

KeyInLoop
	IF BlinkingCursor
	bsr	DoCursor					;flash cursor while executing basic INPUT command or normal line entry
	ENDIF
	jsr	ScanKB						;ROM routine to scan keyboard
	beq	KeyInLoop					;nothing pressed so keep waiting (and flashing the cursor)
	bsr ClearCursor					;a key was pressed so make sure we don't leave cursor on
	anda #%01111111				    ;mask high bit with 0111 1111
	cmpa #keyClear					;check for "clear" key pressed
	beq	ClearKeyPressed
;notClearKey
	cmpa #keyBreak					;check for "break" pressed
	bne	EndKeys
;break key pressed so force a new line
	pshs a
	lda #chrNewLine
	leay row,pcr
	lbsr print
	puls a
EndKeys
	jmp EndChrIn    				;back to ROM

ClearKeyPressed
	bsr ClearScreen
	bra EndKeys
	
ClearCursor					;print a blank space where the cursor was
	pshs a
	lda	#chrWhiteSpace
updateCursor
	leay	row,pcr			;point y at row|col
	lbsr	print				;go print it
	puls a
	rts

	IF SolidCursor
SetCursor					;print a blank space where the cursor was
	pshs a
	IF T32c
	lda #124				;underscore
	ELSE
	lda	#chrBlackSpace
	ENDIF
	bra updateCursor
	ENDIF

	IF BlinkingCursor

CursorDelay1	equ $C8
CursorDelay2	equ $FF
CurCount FCB CursorDelay2			;cursor timer
CursorStatus rmb 1				;cursor B or W

DoCursor
	pshs a,b,y,x
	ldy #CursorDelay1				;flash delay loop nested in two to allow check for key press while waiting to flip cursor
CurDelayLoop
	leay -1,y						;loop 1
	bne CurDelayLoop
	dec CurCount,pcr				;loop 2
	beq FlipCursor					;flip cursor
	bra CursorEnd					;go back and check for key press without flipping cursor
FlipCursor
	lda #CursorDelay2				;reset delay counter	
	sta CurCount,pcr				
	tst CursorStatus,pcr			;check current colour
	beq CursorToBlack				;if white/green jumpo to change to black
	clr CursorStatus,pcr 			;it is black so change to white/green
	lda #chrWhiteSpace			;load white space chr for printing
	bra UpdateCursor
CursorToBlack
	lda #chrBlackSpace			;load black space chr for printing
	com CursorStatus,pcr			;flip cursor status to $FF = black
UpdateCursor
	leay row,pcr					;y points to row|col
	lbsr print						;print cursor
CursorEnd
	puls a,b,y,x
	rts
	ENDIF

;Clear screen routines
	IF T32c
ClearScreen
	ldb Paper,pcr
	clr	row,pcr
	clr	col,pcr
	jmp Pcls						;borrow part of the PCLS routine in ROM
	ELSE
;for the monochrome versions
ClearScreen
	ldb Ink,pcr
	bne ClearToBlack
	ldb #3							;will clear screen to green/white
	bra DoScreenClear	 
ClearToBlack
	clrb							;will clear screen to black
DoScreenClear
	clr	row,pcr						;reset print position to top left
	clr	col,pcr
	jmp Pcls						;borrow part of the PCLS routine in ROM
	ENDIF

;Main print routine - a contains chr to print, y points to row|col pair of bytes
;so y points to row at first but add 1 to y and it will point to col
;each row takes 8 * 32 = 256 bytes of memory so multiply row by 256
;and add start of graphics screen to get start address of row to print on
;the mul opcode can only multiply by up to 255 so do it and add one more instance of row 
;number to mul by 256 i.e. start address of row = start of screen + row * 255 + row


print

;find start address of bitmap of chr to print
	suba #chrNonPrint+1		;chrs < 32 are non-printing so not included in chr bitmaps
	ldb	#$08					;8 slices (one slice to a byte) per character so mult chr code by 8
	mul
	leau chrs,pcr				;load u with start address of chr bitmaps
	leau d,u					;add d to u to get address of first byte slice of chr to be printed

;calculate starting address of row to print chr on
;256 bytes in a chr row so mul row number and add address of start of screen
;to get start address of row we will print on
;can quickly multiply by 256 by putting row number in a reg and 0 in b to make d = row x 256

	lda ,y+					;y initially points to col so a now equals colum no and y then points to row
	clrb						;d now = rows x 256 
	addd ScreenStartAddress
	tfr d,x					;x is start address of row to print on

;###########################################################################
	IF T32
;this is the most straightforward version as one character is one byte wide so each slice can be placed intoi graphics memory without
;additional processing

	ldb ,y						;a=col
	abx							;x = address where top slice of chr bitmap needs to end up
	ldb #8
PrintSliceLoop
	lda	,u+						;get chr slice
	sta	,x						;place slice on screen
	leax	32,x				;x = x +32 (32 bytes per row of high res screen)
	decb
	bne	PrintSliceLoop	
	rts

;###########################################################################	
	ELSIF T51
;This is a lot more complicated as slices of 5 bit wide characters will span different bytes on screen
;calculate bytes and bits to position in row byt dividing col by 8 
	ldb	,y								;load b with col number
	lda	#$05							;chr width
	mul									;d = pixel X co-ordinate of top left of where chr will be printed	
CBytes
	cmpb	#$08						;less than a byte (result of mul is in d but cannot be more than 5 x 50 so really its just in b and a=0 unless something has gone very badly wrong)
	blo	BytesCounted
	inca								;use a to count bytes in pixel x coord
	subb	#$08
	bra	CBytes

;now a = bytes and b = bits of pixel coordinate 
;e.g. printing at column 19 means starting at the 5 x 19 = 95th pixel = 11 bytes and 7 bits across from the left
BytesCounted
	exg	a,b								;bytes in b, bits in a
	abx									;add column no of byte to x to get the position to start printing at

;u points at chr slice, x points where to start printing, a = bits, y and b are free

	pshs a								;save bits on top of stack
	sta bitcount,pcr
;prepare mask
	ldd #%1111100000000000
ShiftMaskLoop
	tst bitcount,pcr
	beq MaskShiftDone
	lsra					;shift d right
	rorb				
	dec bitcount,pcr					;bit counter -1
	bra ShiftMaskLoop
MaskShiftDone
	std Mask,pcr

;loop to print each chr slice	
	lda #8
	sta PrintLoopCount,pcr
PrintLoop
	lda ,s					; a = bits
	sta bitcount,pcr
	lda ,u+				;load a with slice	
	ldb #%11111111			;set lsb of d to all green
ShiftSliceLoop
	tst bitcount,pcr
	beq ShiftSliceDone
	lsra					;shift right
	rorb
	ora #128				;set leftmost bit of a to 1	
	dec bitcount,pcr		;bit count - 1
	bra ShiftSliceLoop
ShiftSliceDone	
	std Slice,pcr

;Mask and print
	leay Mask,pcr					;Point y at Mask|Slice
	ldd ,y							;d = Mask
	ora ,x							;or d (a|b) with two adjacent chr slices from screen
	orb 1,x	
	std ,x							;update screen
	ldd 2,y							;d = Slice
	anda ,x							;and d (a|b) with two chr slices from screen
	andb 1,x
	std ,x							;update screen
	leax	32,x					;x = x +32 (32 bytes per row of high res screen)
	dec PrintLoopCount,pcr
	bne PrintLoop
	
	puls a						;clear bits from top of stack
	rts


bitcount rmb 1					;bit counter
Mask rmb 2						;
Slice rmb 2					;
PrintLoopCount FCB 1			;

;###########################################################################	
	ELSIF T64

;check if column is left or right hand of byte
	ldb	,y						;load b with column number (0 - 63)
	lsrb						;divide b by 2 to get byte (0 to 31) across screen width to print in
	bcc	PrintInLeftNybble		;jump to print in left half of byte (carry clear if column number is even, zero counts as even)

;u points to start of chr bitmap, b = byte (0 to 31) across screen width to print in
PrintInRightNybble				;print in right half of byte	- label only for clarity
	lda #%11110000
	bra StoreMasks
PrintInLeftNybble				;print in left half of byte
	lda #%00001111
StoreMasks
	sta mask1,pcr
	coma
	sta mask2,pcr
;print slices to screen
	abx							;add column no to x to get start address of print position
	ldb #8
PrintNybbleLoop
	lda ,x
	anda mask1,pcr
	sta	,x
	lda	,u+						;load a with chr bitmap slice
	anda mask2,pcr 			;set left nybble of chr slice to 0000 leaving chr pattern in right hand byte
	ora	,x						;set slice without wiping non-printing half of byte
	sta	,x
	leax	32,x				;x = x +32 (32 bytes per row of high res screen)
	decb
	bne	PrintNybbleLoop

	rts
mask1 rmb 1
mask2 rmb 1
	
;###########################################################################
	ELSIF T32c
	
	ldb ,y						;a=col
	abx							;add b to x to get address of byte to start at		
	ldb #8						;use b to count slices
PrintSliceLoop
	lda	,u+						;lda with slice
	sta	,x						;print it
	leax	32,x				;x = x +32 (32 bytes per row of high res screen)
	decb						;inc slice count
	bne	PrintSliceLoop	
	rts
	
	ENDIF
	;###########################################################################
;}

 

;Alternative character sets can be referenced here.
;Comment out the current one and add a reference to the new as needed
;Current references assume character sets are in a sub-folder call CHrBitMaps
chrs
	IF T32
	INCLUDEBIN "\ChrBitmaps\\t32ChrsBitmaps.bin"
;	INCLUDEBIN "\ChrBitmaps\\t32WestminsterChrsBitmaps.bin"
	ELSIF T51
	INCLUDEBIN "\ChrBitmaps\\t51chrsBitmaps.bin"
	ELSIF T64
	INCLUDEBIN "\ChrBitmaps\\t64chrsBitmaps.bin"
	ELSIF T32c
	INCLUDEBIN "\ChrBitmaps\\t32cChrsBitmaps.bin"
	ENDIF	
endchrs
