@echo off
rem Imprime le cahier des charges en PDF avec Chrome, sans en-tete ni pied de
rem page du navigateur (les numeros de page viennent de la feuille de style).
rem Lancer outils\diagrammes.cmd avant, pour que les figures soient a jour.
setlocal
set RACINE=%~dp0..
set CHROME="C:\Program Files\Google\Chrome\Application\chrome.exe"
%CHROME% --headless=new --disable-gpu --no-pdf-header-footer --allow-file-access-from-files ^
  --print-to-pdf="%RACINE%\cahier\USW_Cahier_De_Charges_Groupe4_v2.pdf" ^
  "file:///%RACINE:\=/%/cahier/cahier-des-charges.html" || exit /b 1
echo PDF ecrit : cahier\USW_Cahier_De_Charges_Groupe4_v2.pdf
