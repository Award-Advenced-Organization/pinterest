@echo off
rem Fabrique les images des diagrammes (SVG et PNG) dans analyse\rendus,
rem a partir des sources PlantUML de analyse\.
rem Besoin : Java et D:\dev\plantuml\plantuml.jar.
setlocal
set RACINE=%~dp0..
set JAVA="C:\Program Files\Java\jdk-25\bin\java.exe"
set PLANTUML=D:\dev\plantuml\plantuml.jar
set OPTIONS=-Djava.awt.headless=true -DPLANTUML_LIMIT_SIZE=16384
if exist "%RACINE%\analyse\rendus" rmdir /s /q "%RACINE%\analyse\rendus"
mkdir "%RACINE%\analyse\rendus"
%JAVA% %OPTIONS% -jar "%PLANTUML%" -charset UTF-8 -tsvg -o "%RACINE%\analyse\rendus" "%RACINE%\analyse\*.puml" || exit /b 1
%JAVA% %OPTIONS% -jar "%PLANTUML%" -charset UTF-8 -tpng -Sdpi=200 -o "%RACINE%\analyse\rendus" "%RACINE%\analyse\*.puml" || exit /b 1
echo Diagrammes fabriques dans analyse\rendus.
