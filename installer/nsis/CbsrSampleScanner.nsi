;NSIS Modern User Interface version 1.69
;Original templates by Joost Verburg
;Redesigned for BZFlag by blast007
;Redesigned for Cbsr Sample Scanner by Thomas Polasek

;--------------------------------
;CbsrSampleScanner Version Variables

  !define VERSION_STR "0.3.5.a" 
  !define EXPORTED_CBSRSAMPLESCANNER "CbsrSampleScanner_v${VERSION_STR}_win32"
  !define EXECUTABLE "BioSampleScan.exe"

;--------------------------------
;Compression options

  ;If you want to comment these
  ;out while testing, it speeds
  ;up the installer compile time
  ;Uncomment to reduce installer
  ;size by ~35%
  
  ;SetCompress off
  SetCompress auto
  SetCompressor /SOLID lzma

;--------------------------------
;Include Modern UI

  !include "MUI.nsh"

;--------------------------------
;Configuration

  ;General
  Name "CbsrSampleScanner ${VERSION_STR}"
  OutFile "..\CbsrSampleScannerInstaller-${VERSION_STR}.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\CbsrSampleScanner"

  ; Make it look pretty in XP
  XPStyle on

;--------------------------------
;Variables
  Var STARTMENU_STR
  Var STARTMENU_FOLDER
  Var INSTALL_DIR_STR
  
  

;--------------------------------
;Interface Settings

  ;Icons
  !define MUI_ICON "samplescanner.ico"
  !define MUI_UNICON "uninstall.ico"

  ;Bitmaps
  !define MUI_WELCOMEFINISHPAGE_BITMAP "side.bmp"
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP "side.bmp"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "header.bmp"
  !define MUI_COMPONENTSPAGE_CHECKBITMAP "${NSISDIR}\Contrib\Graphics\Checks\simple-round2.bmp"

  !define MUI_COMPONENTSPAGE_SMALLDESC

  ;Show a warning before aborting install
  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  ;Welcome page configuration
  !define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of CbsrSampleScanner ${VERSION_STR}.\r\n\rCbsrSampleScanner is an application you must get.\r\n\r\nClick Next to continue."

  
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "licence.rtf"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY

  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\CbsrSampleScanner" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !define MUI_STARTMENUPAGE_DEFAULTFOLDER "CbsrSampleScanner"

  !insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER

  !insertmacro MUI_PAGE_INSTFILES
  
  ;Finished page configuration
  !define MUI_FINISHPAGE_NOAUTOCLOSE
  !define MUI_FINISHPAGE_LINK "http://aicml-med/"
  !define MUI_FINISHPAGE_LINK_LOCATION "http://aicml-med/"
  

  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

  !define MUI_UNFINISHPAGE_NOAUTOCLOSE
  !insertmacro MUI_UNPAGE_FINISH
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"


!macro MACRO_UNINSTALL

  ; remove the directory we will be installing to. (if it exists)
  RMDir /R "$INSTDIR"

  ; remove the previous installation
  ReadRegStr $INSTALL_DIR_STR HKLM SOFTWARE\CbsrSampleScanner "Install_Dir"
  IfErrors +2 0
  RMDir /R "$INSTALL_DIR_STR"

  ;delete startmenu (directory stored in registry)
  ReadRegStr $STARTMENU_STR HKLM SOFTWARE\CbsrSampleScanner "Start Menu Folder"
  IfErrors +2 0
  RMDir /R "$SMPROGRAMS\$STARTMENU_STR"
  
  ;delete quicklaunch, desktop
  Delete "$QUICKLAUNCH\CbsrSampleScanner.lnk"
  Delete "$DESKTOP\CbsrSampleScanner.lnk"
  
   ;remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CbsrSampleScanner"
  DeleteRegKey HKLM "SOFTWARE\CbsrSampleScanner"
  DeleteRegKey HKCU "Software\CbsrSampleScanner"
!macroend

;--------------------------------
;Installer Sections

Section "!CbsrSampleScanner Core(Required)" CbsrSampleScanner
  ;Make it required
  SectionIn RO
  
  !insertmacro MACRO_UNINSTALL
 
  goto INSTALL_CBSRSS_CORE  
  

INSTALL_CBSRSS_CORE:
  ; copy over the exported sample scanner directory
  SetOutPath $INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}
  File /r ..\${EXPORTED_CBSRSAMPLESCANNER}\*
  
  ; make the doc dir
  SetOutPath $INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\doc
  File licence.rtf
  
  ;Write CbsrSampleScanner registry keys
  WriteRegStr HKLM SOFTWARE\CbsrSampleScanner "Version" "${VERSION_STR}"
  WriteRegStr HKLM SOFTWARE\CbsrSampleScanner "Install_Dir" "$INSTDIR"
  WriteRegStr HKLM SOFTWARE\CbsrSampleScanner "CbsrSampleScanner" "Artificial Intelligence usually beats natural stupidity."
  
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CbsrSampleScanner" "DisplayName" "CbsrSampleScanner (remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CbsrSampleScanner" "UninstallString" '"$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\uninstall.exe"'
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
    ;Main start menu shortcuts
    SetOutPath $INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\uninstall.exe" "" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\uninstall.exe" 0
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\CbsrSampleScanner.lnk" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\${EXECUTABLE}" "" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\${EXECUTABLE}" 0
  !insertmacro MUI_STARTMENU_WRITE_END

SectionEnd

Section "Quick Launch Shortcuts" QuickLaunch
  ;shortcut in the "quick launch bar"
  SetOutPath $INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}
  CreateShortCut "$QUICKLAUNCH\CbsrSampleScanner.lnk" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\${EXECUTABLE}" "" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\${EXECUTABLE}" 0
SectionEnd

Section "Desktop Icon" Desktop
  ;shortcut on the "desktop"
  SetOutPath $INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}
  CreateShortCut "$DESKTOP\CbsrSampleScanner.lnk" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\${EXECUTABLE}" "" "$INSTDIR\${EXPORTED_CBSRSAMPLESCANNER}\${EXECUTABLE}" 0
SectionEnd

;--------------------------------
;Descriptions

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${CbsrSampleScanner} "Install the main CbsrSampleScanner application"
    !insertmacro MUI_DESCRIPTION_TEXT ${QuickLaunch} "Adds a shortcut in the Quick Launch toolbar."
    !insertmacro MUI_DESCRIPTION_TEXT ${Desktop} "Adds a shortcut on the desktop."
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------


Section "Uninstall"
   !insertmacro MACRO_UNINSTALL
SectionEnd
