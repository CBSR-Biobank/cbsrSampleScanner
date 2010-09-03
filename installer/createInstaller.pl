#!/usr/bin/perl

$NSIS_PROGRAM = "c:/Program\\ Files/nsis/makensis";

$VERSION = "";
$CBSRSS_FOLDER = "";
$EXPORT_DIR = "";
$DLL_DIR = "";
$NSIS_DIR = "";



if($#ARGV == 1){
        $EXPORT_DIR = $ARGV[0];
        $EXPORT_DIR =~ s/\/$//;

        $NSIS_DIR = $ARGV[1];
        $NSIS_DIR =~ s/\/$//;
}
else{
        print "Usuage: createInstaller.pl ExportedEclipseProjectDirectory nsisConfigurationDirectory\n";
        exit 0;
}
print "\n";

#make temp directory
if(-d "tmp" ){
        `rm -rf tmp`;
}
mkdir "tmp";

-d "tmp" or die "could not create temp directory";


#get version number
`./7zip/7z.exe e $EXPORT_DIR/plugins/BioSampleScan_*.jar META-INF/MANIFEST.MF -otmp`;
-e "tmp/MANIFEST.MF" or die "failed to extract manifest file";

open(FH, "tmp/MANIFEST.MF") or die "could not open tmp/MANIFEST.MF";
while($line = <FH>){
        if($line =~ m/Bundle-Version: (.*)/ ){
                $VERSION = $1;
                $VERSION =~ s/\s+$//;
                $CBSRSS_FOLDER = "CbsrSampleScanner_v${VERSION}_win32";
                print "Found cbsrSampleScanner version: $VERSION\n";
                last;
        }
}
close(FH);
$VERSION ne "" or die "failed to find version number";


print "Copying the exported cbsrSampleScanner folder...\n";
`cp -R $EXPORT_DIR tmp/$CBSRSS_FOLDER`;
-d "tmp/$CBSRSS_FOLDER" or "could not create cbsrSampleScanner_v directory";

 print "Copying the nsis's...\n";
`cp -R $NSIS_DIR tmp/nsis`;
-d "tmp/nsis" or die "could not create nsis directory";

open(FH, "tmp/nsis/CbsrSampleScanner.nsi") or die "failed to open tmp/nsis/CbsrSampleScanner.nsi";
open(FHA, ">tmp/nsis/CbsrSampleScannerTMP.nsi") or die "failed to create tmp/nsis/CbsrSampleScannerTMP.nsi";
while($line = <FH>){
        if($line =~ m/define VERSION_STR/ ){
                $line =~ s/".*?"/"$VERSION"/;
                print "Modified nsis script line: $line";
        }
        print FHA $line;
}
close(FHA);
close(FH);
-e "tmp/nsis/CbsrSampleScannerTMP.nsi" or die "could not create customized nsis script";

print "Compiling nsis script...\n";
`$NSIS_PROGRAM tmp/nsis/CbsrSampleScannerTMP.nsi`;
-e "tmp/CbsrSampleScannerInstaller-${VERSION}.exe" or die "nsis could not create installer";

print "Moving installer...\n";
`mv tmp/CbsrSampleScannerInstaller-${VERSION}.exe .`;
-e "CbsrSampleScannerInstaller-${VERSION}.exe" or die "could not move installer";

print "Cleaning up....\n";
`rm -rf tmp`;
!(-d "tmp") or die "temp directory could not be removed";

print "Successfully created: CbsrSampleScannerInstaller-${VERSION}.exe\n";
