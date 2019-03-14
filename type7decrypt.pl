#!/usr/bin/perl
# Stolen from Alex @ www.question-defense.com

use File::Copy;
 
############################################################################
# Vigenere translation table
############################################################################
@V=(0x64, 0x73, 0x66, 0x64, 0x3b, 0x6b, 0x66, 0x6f, 0x41, 0x2c, 0x2e,
    0x69, 0x79, 0x65, 0x77, 0x72, 0x6b, 0x6c, 0x64, 0x4a, 0x4b, 0x44,
    0x48, 0x53, 0x55, 0x42, 0x73, 0x67, 0x76, 0x63, 0x61, 0x36, 0x39,
    0x38, 0x33, 0x34, 0x6e, 0x63, 0x78, 0x76, 0x39, 0x38, 0x37, 0x33,
    0x32, 0x35, 0x34, 0x6b, 0x3b, 0x66, 0x67, 0x38, 0x37);
############################################################################
 
############################################################################
# Usage guidelines
############################################################################
if ($ARGV[0] eq ""){
   print "This script reveals the IOS passwords obfuscated using the Vigenere algorithm.\n";
   print "\n";
   print "Usage guidelines:\n";
   print " type7decrypt.pl 04480E051A33490E     # Reveals a single password\n";
   print " type7decrypt.pl running-config.rcf   # Changes all passwords in a file to cleartext\n";
   print "                                  # Original file stored with .bak extension\n";
}
 
############################################################################
# Process arguments and execute
############################################################################
if(open(F,"<$ARGV[0]")){    # If argument passed can be opened then convert a file
  open(FO,">cdcout.rcf") || die("Cannot open 'cdcout.rcf' for writing ($!)\n");
  while(<F>){
    if (/(.*password\s)(7\s)([0-9a-fA-F]{4,})/){     # Find password commands
      my $d=Decrypt($3);                             # Deobfuscate passwords
      s/(.*password\s)(7\s)([0-9a-fA-F]{4,})/$1$d/;  # Remove '7' and add cleartext password
    }
    print FO $_;
  }
  close(F);
  close(FO);
  copy($ARGV[0],"$ARGV[0].bak")||die("Cannot copy '$ARGV[0]' to '$ARGV[0].bak'");
  copy("cdcout.rcf",$ARGV[0])||die("Cannot copy '$ARGV[0]' to '$ARGV[0].bak'");
  unlink "cdcout.rcf";
}else{                      # If argument passed cannot be opened it is a single password
  print Decrypt($ARGV[0]) . "\n";
}
 
############################################################################
# Vigenere decryption/deobfuscation function
############################################################################
sub Decrypt{
  my $pw=shift(@_);                             # Retrieve input obfuscated password
  my $i=substr($pw,0,2);                        # Initial index into Vigenere translation table
  my $c=2;                                      # Initial pointer
  my $r="";                                     # Variable to hold cleartext password
  while ($c<length($pw)){                       # Process each pair of hex values
    $r.=chr(hex(substr($pw,$c,2))^$V[$i++]);    # Vigenere reverse translation
    $c+=2;                                      # Move pointer to next hex pair
    $i%=53;                                     # Vigenere table wrap around
  }                                             #
  return $r;                                    # Return cleartext password
}


