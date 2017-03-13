#!/usr/bin/perl
$vers = "0.1";

#install modules with the
#following commands
#cpan install Path::Class

#
# Download robots.txt from target sites
# put in proper format for other tools
# such as webshot
#

# Add printing of comments
# Remove sites that just disallow /
#

 use LWP;
 use Path::Class qw/file/;
 use Getopt::Std;
 use POSIX qw/strftime/;



if (@ARGV < 2 )
{
 print "|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|\n";
 print "|         _{ / Robotix $vers \\ }_         |\n";
 print "| robots.txt downloader and formatter   |\n";
 print "| Author: Tyler Wrightson \@tbwrightson  |\n";
 print "|_______________________________________|\n\n";

 print "[-] Required Command Line Options\n";
 print "\t -i in file\n";
 print "\t -o out file\n";
 print "\n";
 print "[-] Optional Command Line Options\n";
 print "\t -t HTTP timeout (Default: 10 Seconds)\n";
 print "\n[i] Infile should have one site per line\n";
 print "    without robots.txt eg; http://test.com\n\n";
 exit 0;
}


  my %args;	
  # Specify Title for Output
  getopt('tio', \%args);

  $infile = $args{i};
  $outfile = $args{o};
  $timeout = $args{t};

if ( $timeout )
{
  $lwtimeout = $timeout;
}
else
{
 $lwtimeout = "10";
}

print "[+] Infile: $infile\n";
print "[+] Outfile: $outfile\n";

open(INFILE, $infile) || die("Could not open $infile");
open(OUTFILE, '>>' . $outfile);

$totalsites = 0;
$failedsitesnum = 0;

while( <INFILE> ) {
$totalpages = 0;
chomp($_);

$root = $_ ;
$site = $_ . "/robots.txt";

print "[+] Grabbing URL: $site \n";
print "\t[+] Following HTTP Redirects (if encountered)\n";


 our $ua = LWP::UserAgent->new( );

 $ua->ssl_opts( SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE, 
 SSL_hostname => '', verify_hostname => 0 );
 $ua->timeout($lwtimeout);
 

 my $resp = $ua->get( $site );

# If there's no error
if( ! $resp->is_error )
{
  #print "\t[+]Content is: \n";
  #print $resp->as_string;
  #Parse content of response
  $content = $resp->as_string;
  for(split(/\n/, $content))
  {
	#print "loop through content";
	if ( $_ =~ s/Disallow:// )
	{
	   $_=~ s/^\s+//; #removes any leading spaces
	   if ( $_ eq "/" )
	   {
	     #Skipping "/ of site";
	     #print "\t[!] Ignoring / Entry\n"
	   }
	   else
	   {
	     print OUTFILE $root . $_ . "\n";
	     $totalpages++;
	   }
	}
  }
 $totalsites++;
 print "\t[+] Total Links in robots: $totalpages\n";
}
 # END OF if error 
 
 else
 {
   print "\t[!] Skipping host $_ \n";
   print "\t[!] " . $resp->status_line . "\n";
   $failedsitesnum ++;
 } 

}



print "[!] Skipped a total of $failedsitesnum sites in $infile \n";
print "[I] Grabbed a total of $totalsites sites\n";	
print "[I] Robotix $vers Finished\n";

close(FILE);
close(OUTFILE);


