
SET target=txx.asm

echo Files for Dragon 32 no disk operating system > "txx file sizes.txt"

REM assemble once to get file size
asm6809 %target% --define T32c=1 --define FileSize=2000 -o t32c.bin
REM get file size
FOR /F "usebackq" %%A IN ('t32c.bin') DO set size=%%~zA
REM assemble again passing correct file size as parameter
SET /A size = size-9
asm6809 %target% --define T32c=1 --define FileSize=%size% -o t32c.bin
SET /A exec = 32767-%size%+1
REM make a note of file size and EXEC address
echo T32c.bin size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T32=1 --define FileSize=2000 -o t32.bin
FOR /F "usebackq" %%A IN ('t32.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T32=1 --define FileSize=%size% -o t32.bin
SET /A exec = 32767-%size%+1
echo T32.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T51=1 --define FileSize=2000 -o T51.bin
FOR /F "usebackq" %%A IN ('T51.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T51=1 --define FileSize=%size% -o T51.bin
SET /A exec = 32767-%size%+1
echo T51.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T64=1 --define FileSize=2000 -o T64.bin
FOR /F "usebackq" %%A IN ('T64.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T64=1 --define FileSize=%size% -o T64.bin
SET /A exec = 32767-%size%+1
echo T64.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

echo. >> "txx file sizes.txt"


echo Files for Dragon 64 no disk operating system >> "txx file sizes.txt"

asm6809 %target% --define T32c=1 --define FileSize=2000 --define CompilingForDragon64=1 -o t32c-64.bin
FOR /F "usebackq" %%A IN ('t32c-64.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T32c=1 --define FileSize=%size% --define CompilingForDragon64=1 -o t32c-64.bin
SET /A exec = 49151-%size%
echo T32c-64.bin size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T32=1 --define FileSize=2000 --define CompilingForDragon64=1 -o t32-64.bin
FOR /F "usebackq" %%A IN ('t32-64.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T32=1 --define FileSize=%size% --define CompilingForDragon64=1 -o t32-64.bin
SET /A exec = 49151-%size
echo T32-64.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T51=1 --define FileSize=2000 --define CompilingForDragon64=1 -o T51-64.bin
FOR /F "usebackq" %%A IN ('T51-64.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T51=1 --define FileSize=%size% --define CompilingForDragon64=1 -o T51-64.bin
SET /A exec = 49151-%size%
echo T51-64.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T64=1 --define FileSize=2000 --define CompilingForDragon64=1 -o T64-64.bin
FOR /F "usebackq" %%A IN ('T64-64.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T64=1 --define FileSize=%size% --define CompilingForDragon64=1 -o T64-64.bin
SET /A exec = 49151-%size%
echo T64-64.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

echo. >> "txx file sizes.txt"

echo Files for Dragon 32 with disk operating system >> "txx file sizes.txt"


asm6809 %target% --define T32c=1 --define FileSize=2000 --define CompilingForDOS=1 -o t32c-dos.bin
FOR /F "usebackq" %%A IN ('t32c-dos.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T32c=1 --define FileSize=%size% --define CompilingForDOS=1 -o t32c-dos.bin
SET /A exec = 32767-%size%+1
echo T32c-dos.bin size = %size% , EXEC address = %exec% >> "txx file sizes.txt"


asm6809 %target% --define T32=1 --define FileSize=2000 --define CompilingForDOS=1 -o T32-dos.bin
FOR /F "usebackq" %%A IN ('T32-dos.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T32=1 --define FileSize=%size% --define CompilingForDOS=1 -o T32-dos.bin
SET /A exec = 32767-%size%+1
echo T32-dos.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T51=1 --define FileSize=2000 --define CompilingForDOS=1 -o T51-dos.bin
FOR /F "usebackq" %%A IN ('T51-dos.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T51=1 --define FileSize=%size% --define CompilingForDOS=1  -o T51-dos.bin
SET /A exec = 32767-%size%+1
echo T51-dos.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

asm6809 %target% --define T64=1 --define FileSize=2000 --define CompilingForDOS=1 -o T64-dos.bin
FOR /F "usebackq" %%A IN ('T64-dos.bin') DO set size=%%~zA
SET /A size = size-9
asm6809 %target% --define T64=1 --define FileSize=%size% --define CompilingForDOS=1 -o T64-dos.bin
SET /A exec = 32767-%size%+1
echo T64-dos.bin  size = %size% , EXEC address = %exec% >> "txx file sizes.txt"

