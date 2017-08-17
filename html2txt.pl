#!/usr/bin/perl
#
# Convert an HTML source into a plain text
#


use Encode::Guess qw/ascii latin9 utf-8 cp-1252/;
use Encode::Encoding;
use Encode;
# use POSIX qw(locale_h);
# use locale;
# use encoding ':locale';
use WebPageCleaner;
use WebPagePruner;
$|++;
if (@ARGV < 1) {
	usage();
}


sub try_decode {
	my $f = shift;
	my $in_txt = `cat $f`;

	my @candidates = ("utf-8", "latin9", "latin1", "cp-1252", "ascii");
	
	my $encoding = "";
	
	#try to find
	if ($in_txt =~ /<meta[^>]*charset=["']?([a-z0-9-]+)["']?[^>]*>/i) {
		$encoding = $1;
#			print STDERR "$f\t$encoding\n";
	}
	
	#try to guess otherwise
	else {
		foreach my $e (@candidates) {
			Encode::Guess->set_suspects($e);
		   	my $decoder = Encode::Guess->guess($in_txt);
		   	if (ref($decoder)) {
#		 		$out_txt = $decoder->decode($in_txt);
				$encoding = $e;

		 		break;
		   	}
		}
	}
	if ($encoding ne "") {
# 		print STDERR "$f\t$encoding\n";
		$out_txt = decode($encoding, $in_txt);
	}
	else {
# 		print STDERR "$f\tNOTHING\n";
		$out_txt = $in_txt;
	}
# 	$out_txt = decode("utf-8", $out_txt);
	return $out_txt;		
}

while (my $in = shift(@ARGV)) {
	#read and decode
	my $txt = try_decode($in);
	#simplify special characters
	clean_text(\$txt);

	#extract main content
	my $p_txt = extract_content(\$txt);
	$$p_txt =~ s/ ?\[\d+\] ?/ /g;
	print $$p_txt;
}



sub usage {
	warn <<EOF;
Usage:
    html2txt.pl <html_file>...

Synopsis:
    Prune and convert an HTML source into a plain text
EOF
	exit 0;
}

