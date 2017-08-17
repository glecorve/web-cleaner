# /*
=pod
*/
/**
 * This package is dedicated to reformating task on characters
 * due encoding differences between what's in (html) Web pages
 * and what's expected in output (latin1 in our case).
 *
 * @author Gwénolé Lecorvé
 * @date 21/02/2007
 */

 /*
=cut

package WebPageCleaner;

use Exporter;
use HTML::Entities;
use Encode::Guess qw/ascii latin9 utf8 cp-1252/;
use Encode::Encoding;
use Encode;
use POSIX qw(locale_h);
use locale;
# use encoding ':locale';


use strict;


my $verbose = 0;

our $BROWSER = "wget";


our @ISA = qw/Exporter/;
our @EXPORT = qw/&clean_text &html2text/;




my %LAUNCH_QUERY;





sub f {
  my $str = shift;
  return (ord($str) < 255? $str : $str);
}


=pod
*/
/**
 * Clean an HTML text by removing/replacing special characters
 * and by checking that the expected encoding (latin1)
 * @param $text un texte.
 */
/*
=cut
sub clean_text {
  my $p_text = shift;
  my $EXPECTED_ENCODING = 'utf8';

  my $decodage = 0;
  

#   	$$p_text = encode("utf8", $$p_text);
  
#  my $encoding = guess_encoding($$p_text);  
#  if (ref($encoding)) {
#    eval {
#      $$p_text = $encoding->decode($$p_text);
#      $$p_text = encode($EXPECTED_ENCODING,$$p_text);
#            $$p_text =~ s/[^!"#\$%&'\(\)\*\+,\-\.\/0123456789:;<=>\?\@ABCDEFGHIJKLMNOPQRSTUVWXYZ\[\\\]\^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¥§©ª« ¬\­®¯°±²³µ¶¹º »¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ?\n ]/ /g;
#    }
#  }
  
  
#   $$p_text =~ /(cleverly concealed.*unexplored aban)/;
#   foreach my $w (split(/ /,$1)) {
#   	foreach my $l (split(//, $w)) {
#   		print STDERR "$w\t$l\t".ord($l)."\n";
#   	}
#   }

    $$p_text =~ s/\x{2019}/'/g;
    $$p_text =~ s/\x{156}/'/g;
    $$p_text =~ s/&#[x](\d+);/"&#".hex($1).";"/ge;
    $$p_text =~ s/&#8217;?/'/g;
    $$p_text =~ s/&#146;?/'/g;
    $$p_text =~ s/\x{2018}/'/g;
    $$p_text =~ s/\x{2019}/'/g;
    $$p_text =~ s/\x{201B}/'/g;
    $$p_text =~ s/\x{02BB}/'/g;
    $$p_text =~ s/\x{055A}/'/g;
    $$p_text =~ s/\x{02BC}/'/g;
    $$p_text =~ s/\x{055A}/'/g;
    $$p_text =~ s/\x{0092}/'/g;
    $$p_text =~ s/`/'/g;
    $$p_text =~ s/’/'/g;
    $$p_text =~ s//'/g;
    $$p_text =~ s/&#198;?/AE/g;
    $$p_text =~ s/&#230;?/ae/g;
    $$p_text =~ s/&#338;?/OE/g;
    $$p_text =~ s/\234/oe/g;
    $$p_text =~ s/&#339;?/oe/g;
    $$p_text =~ s/&oelig;?/oe/g;
    
    $$p_text =~ s/&#8226;?/&#149;/g;
    $$p_text =~ s/&#8230;?/... /g;
    $$p_text =~ s/&hellip;?/... /g;
    $$p_text =~ s/\x{2026}/... /g;
    $$p_text =~ s//... /g;
    
    $$p_text =~ s//'/g;
    $$p_text =~ s/&#39;?/'/g;
    $$p_text =~ s/&#039;?/'/g;
    $$p_text =~ s/&#8216;?/'/g;
    $$p_text =~ s/&#8217;?/'/g;
    $$p_text =~ s/&#8218;?/'/g;
    $$p_text =~ s/&rsquo;?/'/g;

    $$p_text =~ s/\x{00AB} ?/"/g;
    $$p_text =~ s/ ?\x{00BB}/"/g;
    $$p_text =~ s/\x{201C}/"/g;
    $$p_text =~ s/\x{201D}/"/g;
    $$p_text =~ s//"/g;
    $$p_text =~ s//"/g;
    $$p_text =~ s// "/g;
    $$p_text =~ s/«/"/g;
    $$p_text =~ s/»/"/g;
    $$p_text =~ s/&#34;?/"/g;
    $$p_text =~ s/&#034;?/"/g;
    $$p_text =~ s/&#8220;?/"/g;
    $$p_text =~ s/&#8221;?/"/g;
    $$p_text =~ s/&#8222;?/"/g;
    $$p_text =~ s/&ldquo;?/"/g;
    $$p_text =~ s/&rdquo;?/"/g;
    $$p_text =~ s/&laquo;?/"/g;
    $$p_text =~ s/&raquo;?/"/g;
    $$p_text =~ s/&nbsp;?/ /g;
    
    $$p_text =~ s/\x{2010}/ - /g;
    $$p_text =~ s/\x{2011}/ - /g;
    $$p_text =~ s/\x{2012}/ - /g;
    $$p_text =~ s/\x{2013}/ - /g;
    $$p_text =~ s/\x{2053}/ - /g;
    $$p_text =~ s/&.?dash;?/-/g;
    $$p_text =~ s/—/ - /g;
    
    $$p_text =~ s/&bull;?/ • /g;
    $$p_text =~ s// ■ /g;
    $$p_text =~ s/&#(\d+)(;?)/($1<255?"&#$1$2":" ")/eg;
    
    #umlauts
    $$p_text =~ s/\x{00E4}/ä/g;
    $$p_text =~ s/\x{00C4}/Ä/g;
    $$p_text =~ s/\x{00CB}/ë/g;
    $$p_text =~ s/\x{00EB}/Ë/g;
    $$p_text =~ s/\x{00F6}/ö/g;
    $$p_text =~ s/\x{00D6}/Ö/g;
    $$p_text =~ s/\x{00FC}/ü/g;
    $$p_text =~ s/\x{00DC}/Ü/g;

	#weird characters
    $$p_text =~ s/\x{00DF}/ss/g;
    $$p_text =~ s/\x{1D6B}/ue/g;
    $$p_text =~ s/\x{FB00}/ff/g;
    $$p_text =~ s/\x{FB01}/fi/g;
    $$p_text =~ s/\x{FB02}/fl/g;
    $$p_text =~ s/\x{FB03}/ffi/g;
    $$p_text =~ s/\x{FB04}/ffl/g;
    $$p_text =~ s/\x{FB05}/ft/g;
    $$p_text =~ s/\x{FB06}/st/g;
    $$p_text =~ s/\x{0132}/IJ/g;
    $$p_text =~ s/\x{0133}/ij/g;
    
    
    $$p_text =~ s/\x{FFFD}s/'s/g;
    $$p_text =~ s/\x{FFFD}{2}oe/ "/g;
    $$p_text =~ s/â€\x{FFFD}{2}oe/ - /g;
    $$p_text =~ s/\x{FFFD} / - /g;
    
    $$p_text =~ s/\x//g;

    $$p_text =~ s/(\w)\?(\w)/$1'$2/g;

  $$p_text =~ s/( |\t)+/ /g;
  $$p_text =~ s/\n+/\n/g;
  $$p_text =~ s/ +/ /g;
  $$p_text =~ s/^ //gm;
  $$p_text =~ s/ $//gm;
#  $$p_text = encode("utf8", $$p_text);

}


=pod
*/
/**
 * Converts HTML strings into raw text with no markup
 * @param $html an HTML text
 */
 public: string html2text($html);
/*
=cut
sub html2text{
  my $html = shift;
  my $new_html = '';


  # Remove the HTML comments first (stolen from perldoc HTML::Parser)
  my $parser = HTML::Parser->new(default_h => 
                                   [sub { my $element = shift; $new_html = $new_html.$element }, 'text'],
                                 comment_h => [""],
                                 );
  # Also, remove <script> and <style> stuff
  $parser->ignore_elements(qw(script style));
  eval { $parser->parse($html); };
  $parser->eof;

  $html = $new_html;

  $html =~ s/\r//gm;

  # replace <BR> and <P> tags with \n (also, </BR>,</P>, <P/>, <BR/> )
  $html =~ s/\<(\/)?(BR|P).*?(\s*\/)?\>/ /mgi;
  # delete other HTML tags
  $html =~ s/\<[^>]+\>//mg;
  
  clean_text(\$html);

  # Replace HTML entities with normal text
  $html = decode_entities($html);  
  
  $html =~ s/\S\?\S/ /g;
  
  return $html;

}




1;

=pod
*/
}
=cut

