# /*
=pod
*/
/**
 * Web page pruning functions
 *
 * @author Gwénolé Lecorvé
 * @date 21/02/2007
 */

 /*
=cut

package WebPagePruner;

use Exporter;
use HTML::TreeBuilder;
use List::Util qw[min max];
use WebPageCleaner;
use strict;
use utf8;

my $verbose = 0 ;

our @ISA = qw/Exporter/;
our @EXPORT = qw/&extract_content/;
my $seuil_max = 0.3;

#######################################################################################
#
# Extraction contenu
#
#######################################################################################

##
#
#
sub element2html {
	my $node = shift;
	my $retour = "";
	my $t = 0;
	my $tab_ref = 0;
	if (ref $node) {
		$tab_ref = $node->content();
		foreach $t (@$tab_ref) {
			$retour .= element2html($t);
		}
	}
	else { $retour = $node; }
	return html2text($retour);
}



=pod
*/
/**
 * Calcule de le nombre de moyen de signes de ponctuation par lettre.\n
 * info: taille moyenne d'une phrase : 19 mots.\n
 *    nb de . | , | ; : 2.25\n
 *    -> moy : 0.12 signe de ponc par mot
 */
/*
=cut
sub punct_frequency {
	my $texte = shift;
	$texte =~ s/(\.\.\.+)/¶/g; #les ... comptent comme 1/2 ponctuation seulement (pour éviter de prendre des résumés)
	$texte =~ s/(\{.*?\}|\[.*\])|(\(\.\.\.\))/ /g;	#sans virer les parentheses
	my @tab = split(/\s+/,$texte);
	my $nb_mots = @tab+0;
	my $nb_ponc = grep(/[\.,;?!)(]/,@tab)+0;
	$nb_ponc += grep(/¶/,@tab)/2;
# 	if ($nb_mots != 0) { return $nb_ponc/($nb_mots); }
	if ($nb_mots-$nb_ponc != 0) { return $nb_ponc/($nb_mots-$nb_ponc); }
	else { return -1; }
}





=pod
*/
/**
 * Compte le nombre de mots par phrase contenant au moins une lettre.\n
 * exemple:\n
 * - Le CAC40 baisse de 1%. -> 4 (1% n'est pas compté)\n
 * - Le CAC40 baisse de 1%. De son coté, le Dow-jones marque 2 points. -> 11/2 = 5.5
 * - Le CAC40 en direct -> -1 (Ce n'est pas une phrase)
 * - Le CAC40 en direct. Créez un compte -> 4/2 = 1 ("créez un compte" est pas considéré comme une phrase mais les mots ne comptent pas dans le nombre de mots de manière à pénaliser)
 * @param un texte
 */
/*
=cut
sub lettered_word_number {
	my $texte = shift(@_);
	$texte =~ s/(\.\.\.)/./g;
# 	$texte =~ s/(\{.*?\}|\(.*?\)|\[.*\])/ /g; #si on exclut les parentheses
	$texte =~ s/(\{.*?\}|\[.*\])|(\(\.\.\.\))/ /g; #sinon
	$texte =~ s/\s+/ /g;
	my @tab_phr = split(/[\.\?!]\s/,$texte);
	my $nb_phr = @tab_phr;
	my @tab_mots = split(/ /,$texte);
	
	
	if ($texte !~ /[\.\?!]\s?$/) {
		pop(@tab_phr);
# 		$nb_phr--;
		@tab_mots = split(/ /,join(" ",@tab_phr));
	}
	if ($nb_phr > 0) {
		return grep(/[a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ]/i,@tab_mots)/($nb_phr);
	}
	else { 	return -1; }
}


=pod
*/
/**
 * Renvoie la fréquence des caractères spéciaux (ex: | ou / )
 * @param un texte
 */
/*
=cut
sub spec_char_frequency {
	my $texte = shift;
	$texte =~ s/\s+/ /g;
	my @tab_mots = split(/\s/, $texte);
	$texte =~ s/\s-\s/¶/gi;
	my @tab = $texte =~ /[^a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ0-9\.\?!:\-,;\'\"\(\)\s]/gi;
	my $n = $#tab;
	@tab = $texte =~ /[:\-\(\)]/gi;
	$n += 0.5*$#tab;
	if (@tab_mots > 0) {
		return @tab/@tab_mots;
	}
	else { return -1; }
}

=pod
*/
/**
 * Calcule le nombre de chiffres par lettre
 * @param un texte
 */
/*
=cut 
sub digit_letter_ratio {
	my $texte = shift(@_);
	my @lettres = $texte =~ /[a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ]/gi;
	my @chiffres = $texte =~ /[0-9]/gi;
	if (@lettres > 0) { return @chiffres/@lettres; }
	else { return 0; }
}



=pod
*/
/**
 * Compte le nombre de mots d'un contenu
 * @param un texte
 */
/*
=cut
sub word_number {
	my $texte = shift(@_);
	$texte =~ s/[(\.\.\.)\.\?!\(\),:]/ /g;
	$texte =~ s/[^a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÔÙÛÜÇ\s]//gi;
	$texte =~ s/\s+/ /g;
	return (split(/ /,$texte)+0);
}
















my $NB_PARAM_DECISION = 9;
my %structured_tag;
	$structured_tag{"html"} = 1;
	$structured_tag{"body"} = 1;
	$structured_tag{"tr"} = 1;
	$structured_tag{"td"} = 1;
	$structured_tag{"div"} = 1;
# 	$structured_tag{"p"} = 1;
	$structured_tag{"h1"} = 1;
	$structured_tag{"h2"} = 1;
	$structured_tag{"h3"} = 1;
# 	$structured_tag{"h4"} = 1;
# 	$structured_tag{"h5"} = 1;
# 	$structured_tag{"h6"} = 1;
# 	$structured_tag{"h7"} = 1;
# 	$structured_tag{"h8"} = 1;
#	$structured_tag{"li"} = 1;
#	$structured_tag{"ul"} = 1;
	$structured_tag{"dl"} = 1;
	$structured_tag{"dd"} = 1;
	$structured_tag{"dt"} = 1;

my %ignored_tag;
	$ignored_tag{"head"} = 1;
	$ignored_tag{"frame"} = 1;
	$ignored_tag{"iframe"} = 1;
	$ignored_tag{"script"} = 1;
	$ignored_tag{"style"} = 1;
	$ignored_tag{"embed"} = 1;
	$ignored_tag{"object"} = 1;
	$ignored_tag{"link"} = 1;
	$ignored_tag{"hr"} = 1;
	$ignored_tag{"noscript"} = 1;
	$ignored_tag{"label"} = 1;
	$ignored_tag{"select"} = 1;



sub extract_decision_param {
	my $p_contenu_orig = shift;
  $$p_contenu_orig =~ s/\(c\)/©/g;
	my $contenu = $$p_contenu_orig;
	my @tab_nb_phrases = split(/[\.\?!]+\s/g,$contenu);
	my $nb_phrases = @tab_nb_phrases+0;

	my @mots = split(/ /,$contenu);
	my $nb_mots = @mots+0;

	my @lignes = split(/^$/m,$contenu);
	my $nb_lignes = max(@lignes+0,1);

	my $nb_mots_lettres = grep(/[a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ]/i,@mots);

	my @tab_nb_lettres = $contenu =~ /[a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ]/gi;
	my $nb_lettres = @tab_nb_lettres+0;

	my @tab_nb_chiffres = $contenu =~ /[0-9]/gi;
	my $nb_chiffres = @tab_nb_chiffres+0;

	my $nb_carac_spec = 0;
	   $contenu =~ s/\s-\s/¶/gi;
  
  my $nb_mots_maj = 0;
     $nb_mots_maj = $contenu =~ /^[A-ZÀÂÉÈËÎÏÔÙÛÜÇ]/g;
     $nb_mots_maj += $contenu =~ / [A-ZÀÂÉÈËÎÏÔÙÛÜÇ]/g;
     
	my @tab_spec_entier = $contenu =~ /\s[^a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ0-9\.\?!,;\'\"\)\(\%\s]\s/gi;
	my @tab_spec_demi = $contenu =~ /[^a-zA-ZàâéèêëîïôùûüÿçÀÂÉÈËÎÏÔÙÛÜÇ0-9\.\?!:\-,;\'\"\s]/gi;
	my @tab2_spec_entier = $contenu =~ /\s(?:\$|€|¥|£|%)\s/gi;
	my @tab2_spec_demi = $contenu =~ /(?:\$|€|¥|£|%)/gi;
	   $nb_carac_spec = 0.25*@tab_spec_demi+0.75*@tab_spec_entier+0.25*(0.25*@tab2_spec_demi+0.75*@tab2_spec_entier);

	my $nb_ponc = 0;
	   $contenu =~ s/(\{.*?\}|\[.*\])|\(\.\.\.\)/ /g;	#sans virer les parentheses
	my $nb_points_sus = $contenu =~ /(\.\.\.+)/; #les ... comptent comme 1/2 ponctuation seulement (pour éviter de prendre des résumés)
	   $nb_ponc = grep(/[\.,;?!]/,@mots)+ 0.5 * grep(/\:/,@mots) + 0.25 * grep(/(\)|\(|^-$)/,@mots);
	   $nb_ponc += $nb_points_sus/2;

	$nb_phrases += $nb_lignes-1;
#	$nb_mots /= $nb_lignes;
#	$nb_mots_lettres /= $nb_lignes;
#	$nb_lettres /= $nb_lignes;
#	$nb_chiffres /= $nb_lignes;
#	$nb_carac_spec /= $nb_lignes;
#	$nb_ponc /= $nb_lignes;
#	$nb_mots_maj /= $nb_lignes;

	my @param = ($p_contenu_orig, $nb_phrases, $nb_mots, $nb_mots_lettres, $nb_lettres, $nb_chiffres, $nb_carac_spec, $nb_ponc, $nb_mots_maj);
  
	return \@param;
}





sub merge_decision_param {
	my $p_param1 = shift;
	my $p_param2 = shift;
	my $p_contenu;
	my $p_param_res;
	@$p_param_res = ();
	for (my $i=0; $i < $NB_PARAM_DECISION; $i++) {
		#contenu
		if ($i == 0) {
			if (${$$p_param1[$i]} eq "") {
				$$p_param_res[$i] = $$p_param2[$i];
			}
			elsif (${$$p_param2[$i]} eq "") {
				$$p_param_res[$i] = $$p_param1[$i];
			}
			else {
				$$p_contenu = ${$$p_param1[$i]}." ".${$$p_param2[$i]};
        $$p_contenu =~ s/ +/ /g;
				$$p_param_res[$i] = $p_contenu;
			}
		}
		#nb phrases
		elsif ($i == 1) {
			if (($$p_param1[0] != undef && ${$$p_param1[0]} ne "") || ($$p_param2[0] != undef && ${$$p_param2[0]} ne "")) {
				my @tab_nb_phrases = split(/[\.\?!]+\s/g,${$$p_param_res[0]});
				$$p_param_res[$i] = @tab_nb_phrases+0;
			}
			else {
				$$p_param_res[$i] = $$p_param1[$i]+$$p_param2[$i];
			}
		}
		#sinon
		else {
			$$p_param_res[$i] = $$p_param1[$i]+$$p_param2[$i];
		}
	}
	return $p_param_res;
}



=pod
*/
/**
 * Renvoie un flottant entre 0 et 1 qui donne l'intérêt d'un contenu.
 * @param $contenu un texte
 */
/*
=cut

sub removal_decision {
	my $LE_SEUIL = shift;
	$LE_SEUIL /= 1.1;
# 	my $contenu = shift;
	my $p_param = shift;
	my ($p_contenu, $nb_phrases, $nb_mots, $nb_mots_lettres, $nb_lettres, $nb_chiffres, $nb_carac_spec, $nb_ponc, $nb_mots_maj) = @$p_param;

	if (@$p_param != $NB_PARAM_DECISION) {
		($p_contenu, $nb_phrases, $nb_mots, $nb_mots_lettres, $nb_lettres, $nb_chiffres, $nb_carac_spec, $nb_ponc, $nb_mots_maj) = @{extract_decision_param($p_contenu)};
	}







	my $verdict_ponc = -1;
	my $verdict_taille_phrase = -1;
	my $verdict_car_spec = -1;
	my $verdict_nb_mots = -1;
	my $verdict_nb_lettres = -1;
  my $verdict_nb_mots_maj = -1;
	my $verdict_chiffres_lettres = -1;
	my $EPSILON = 0.01;


	if ($nb_mots-$nb_ponc > 0) {
		$verdict_ponc = $nb_ponc / ($nb_mots-$nb_ponc);
	}
	if ($nb_phrases > 0) {
		$verdict_taille_phrase = $nb_mots_lettres / $nb_phrases;
	}
	if ($nb_mots > 0) {
		$verdict_car_spec = $nb_carac_spec / $nb_mots;
	}
	if ($nb_lettres > 0) {
		$verdict_chiffres_lettres = $nb_chiffres / $nb_lettres;
		if ($nb_lettres == 1) { $verdict_nb_lettres = -0.6; }
		if ($nb_lettres == 2) { $verdict_nb_lettres = 0; }
		if ($nb_lettres >= 3) { $verdict_nb_lettres = 0.75; }
#		if ($nb_lettres == 4) { $verdict_nb_lettres = 0.6; }
#		if ($nb_lettres >= 5) { $verdict_nb_lettres = 0.75; }
	}
  if (($nb_mots - $nb_phrases) != 0) {
    $verdict_nb_mots_maj = min(1.0- (($nb_mots_maj-$nb_phrases) / ($nb_mots-$nb_phrases)),1);
  }
	$verdict_nb_mots = $nb_mots;

	$verbose && print "LE SEUIL : $LE_SEUIL\n";
	$verbose && print "CONTENU: /".$$p_contenu."/\n";

	$verbose && print "[PARAM] NB PHRASES: $nb_phrases\n";
	$verbose && print "[PARAM] NB MOTS: $nb_mots\n";
	$verbose && print "[PARAM] NB MOTS LETTRES: $nb_mots_lettres\n";
	$verbose && print "[PARAM] NB LETTRES: $nb_lettres\n";
	$verbose && print "[PARAM] NB CHIFFRES: $nb_chiffres\n";
	$verbose && print "[PARAM] NB CARAC_SPEC: $nb_carac_spec\n";
	$verbose && print "[PARAM] NB PONCT: $nb_ponc\n";
  $verbose && print "[PARAM] NB MOTS MAJ: $nb_mots_maj\n";

	$verbose && print "PONC: ".$verdict_ponc."\n";
	$verbose && print "LG PHRASE: ".$verdict_taille_phrase."\n";
	$verbose && print "CAR SPEC: ".$verdict_car_spec."\n";
	$verbose && print "NB MOTS: ".$verdict_nb_mots."\n";
	$verbose && print "CHIF LETT: ".$verdict_chiffres_lettres."\n";
	$verbose && print "\n\n";


	
	if ($verdict_ponc <= 0) { $verdict_ponc = 0.0; }
	elsif ($verdict_ponc > 0.10) { $verdict_ponc = 1; }
	else { $verdict_ponc = $verdict_ponc/0.10; }
	
	if ($verdict_taille_phrase < 5) { $verdict_taille_phrase = -0.5; }
	elsif ($verdict_taille_phrase > 10 && $verdict_taille_phrase < 20) { $verdict_taille_phrase = 1; }
	elsif ($verdict_taille_phrase >= 25) { $verdict_taille_phrase = 0.75; }
	elsif ($verdict_taille_phrase >= 20 && $verdict_taille_phrase < 25) { $verdict_taille_phrase = 0.75+0.25*(($verdict_taille_phrase-20)/(25-18)); }
	else { $verdict_taille_phrase = -0.5 +1.5*($verdict_taille_phrase-5)/(10-5); }
		
	if ($verdict_car_spec < 0) { $verdict_car_spec = 0.75; }
	elsif ($verdict_car_spec > 0.1) { $verdict_car_spec = -0.6-0.8*($verdict_car_spec-0.1)/0.2; }
	else {  $verdict_car_spec = -0.6+1.35*((0.05-$verdict_car_spec)/0.05); }
	
	if ($verdict_nb_mots < 4) { $verdict_nb_mots = -0.2; }
	elsif ($verdict_nb_mots < 7) { $verdict_nb_mots = 0; }
	elsif ($verdict_nb_mots < 20) { $verdict_nb_mots = ($verdict_nb_mots-7)/(20-7); }
	else { $verdict_nb_mots = 1; }
	
	
	if ($verdict_chiffres_lettres < 0) { $verdict_chiffres_lettres = -0.22; }
	elsif ($verdict_chiffres_lettres > 0.8) { $verdict_chiffres_lettres = -0.22; }
	else { $verdict_chiffres_lettres = -0.22+0.97*(0.8-$verdict_chiffres_lettres)/0.8; }

	
	$verdict_ponc += $EPSILON;
	$verdict_taille_phrase += $EPSILON;
#	$verdict_car_spec += $EPSILON;
	$verdict_nb_mots += $EPSILON;
	$verdict_nb_mots_maj += $EPSILON;
	$verdict_chiffres_lettres += $EPSILON;
	
	my $exp = 2;
	my $var = (($verdict_ponc+$verdict_taille_phrase+$verdict_car_spec+$verdict_nb_mots+$verdict_chiffres_lettres+$verdict_nb_mots_maj)/6.0);
	$var = $var**2;
	my $res = (($verdict_ponc**$exp+abs($verdict_taille_phrase)*$verdict_taille_phrase+abs($verdict_car_spec)*$verdict_car_spec+$verdict_nb_mots_maj**$exp+$verdict_nb_mots**$exp+abs($verdict_chiffres_lettres)*$verdict_chiffres_lettres)/6.0);
	$verbose && print "(($verdict_ponc**$exp+abs($verdict_taille_phrase)*$verdict_taille_phrase+abs($verdict_car_spec)*$verdict_car_spec+$verdict_nb_mots_maj**$exp+$verdict_nb_mots**$exp+abs($verdict_chiffres_lettres)*$verdict_chiffres_lettres)/6.0)\n";
	$var = $res - $var;
	$verbose && print "Verdict: PONC=$verdict_ponc LG_PHR=$verdict_taille_phrase CAR_SPEC=$verdict_car_spec NB_MOTS=$verdict_nb_mots RAP_C_L=$verdict_chiffres_lettres\n";
	$verbose && print "VAR : $var\n";
	$verbose && print "RES : $res\n";
	$res = $res*(1-$var);
	$verbose && print "RES : $res\n";	
# 
	if ($res < $LE_SEUIL) {
		$verbose && print "VERDICT : no\n----------------------------------------------------------------\n";
		return (0, $res) ;
	}
	else {
		$verbose && print "VERDICT : yes\n----------------------------------------------------------------\n";
		return (1, $res);
	}
	
}

=pod
*/
/**
 * Extrait le contenu d'une page web sans les pubs, menus, titres, ...
 * de manière à obtenir du texte rédigé de manière convenable
 * @param la référence vers le noeud de l'arbre HTML
 * @return le texte filtré du noeud
 */
/*
=cut
sub extract_content_rec {
	my $node = shift;
	my $seuil = shift; #seuil de décision (facultatif)
	my $p_param;
	my $CHAINE_VIDE = "";
	@$p_param = (\$CHAINE_VIDE);
	my $tagg = ((ref $node)?lc($node->tag()):"");
	my $coeff_mul = 2.0;
	my $seuil_min = 0.3;
	$seuil = max(min($seuil, $seuil_max),$seuil_min);
	my $seuil_init = $seuil;
	my $children = 0;
	my $p_param_temp;
	@$p_param_temp = ();
	my $last_tag = "";
	my @decision = ();
	my @to_process = ();
	my $tag_f = "";
	
	#si c'est un item de structuration de la page
	# recupérer son param et vérifier qu'il s'agit
	# de texte rédigé.
# 	print $tagg;
	if (ref($node) && $ignored_tag{$tagg} == 0) {
		$children = $node->content();
		@$p_param_temp = (\$CHAINE_VIDE);
		$last_tag = "";
		@decision = ();
		@to_process = ();
		$tag_f = "";
		foreach my $child (@$children) {
			#s'il s'agit du fils structurant (table, td...)
			# on decide directement s'il faut garder ou pas
			if (ref($child)) {
				$tag_f = lc($child->tag());
				if ($structured_tag{$tag_f} == 1) {
					#on decide pour ce qu'il y avait avant
					foreach my $c (@to_process) {
						$p_param_temp = merge_decision_param($p_param_temp, extract_content_rec($c, $seuil));
					}
					@decision = removal_decision($seuil_init, $p_param_temp);
					if ($decision[0] == 1) {
						$p_param = merge_decision_param($p_param, $p_param_temp);
					}
					$seuil = $seuil_init;
					@$p_param_temp = (\$CHAINE_VIDE);
					@to_process = ();
					#on analyse la structure
					#on ajoute ce qui aura été gardé dans l'appel recursif
					$p_param = merge_decision_param($p_param, extract_content_rec($child, $seuil));
					${$$p_param[0]} .= "\n";
				}
				elsif ($tag_f eq "br") {
					my $previous_child = pop(@to_process);
					$previous_child .= "\n";
					push(@to_process, $previous_child);
				}
				elsif ($ignored_tag{$tag_f} == 1) { }
				else {
					if (@to_process > 0) {
						if ($last_tag ne $tag_f) {
							$seuil /= $coeff_mul;
						}
						else {
							$seuil *= $coeff_mul;
						}
					}
					push(@to_process, $child);
				}
			}
			else {
				$tag_f = "";
					if (@to_process > 0) {
						if ($last_tag ne $tag_f) {
							$seuil /= $coeff_mul;
						}
						else {
							$seuil *= $coeff_mul;
						}
					}
				$child.="\n";
				push(@to_process, $child);
			}
			$last_tag = $tag_f;
		}

		foreach my $c (@to_process) {
			$p_param_temp = merge_decision_param($p_param_temp, extract_content_rec($c, $seuil));
		}
		@decision = removal_decision($seuil_init, $p_param_temp);
		if ($decision[0] == 1) {
			$p_param = merge_decision_param($p_param, $p_param_temp);
		}

		#verifie que la fréquence de la ponctuation est correcte
		# et que la taille moyenne des phrases l'est aussi.

		@decision = removal_decision($seuil_init, $p_param);
		if ($decision[0] == 0) {
			@$p_param = (\$CHAINE_VIDE);
		}
		else {
		}
	}
	else {
		#si c'est une balise qui ne s'affiche pas
		# on l'ignore
		if ($ignored_tag{$tagg} == 1) {
			if ($tagg eq "script") {
			}
			@$p_param = (\$CHAINE_VIDE);
		}
		else {
# 			#s'il s'agit de texte
# 			# traiter les caractères
			my $str = html2text($node);
			$p_param = extract_decision_param(\$str);
			@decision = removal_decision($seuil, $p_param);
			if ($decision[0] == 0) {
				@$p_param = (\$CHAINE_VIDE);
			}

		}
	}

	return $p_param;
}




=pod
*/
/**
 * Filtre la sortie de l'extraction de contenu ligne par ligne
 * en éliminant les lignes vraiment peu intéressantes (mm critère que précédemment mais avec un seuil à 0.15)
 * @param $texte du texte déjà filtré mais avec encore des pubs ou autres
 */
/*
=cut
sub post_filtering {
	my $p_texte = shift;
	my @tab = split(/\n/, $$p_texte);
	my $i = 0;
	my @tableau = ();
	my @score_tab = ();
	my @sortie = ();

	for ($i = 0; $i < @tab; $i++) {
		@tableau = extract_decision_param(\$tab[$i]);
		@score_tab = removal_decision(0.05, @tableau);
		$verbose && print "\t\t\t\t\t\t","[", $score_tab[0], "]","\n";
		if ($score_tab[0] == 1) {
			push(@sortie,$tab[$i]);
		}
		else { push(@sortie, "\n"); }
	}
	my $retour = join("\n", @sortie);
	if (($retour =~ tr/ //) < 50) { $retour = ""; } 
	return \$retour;
}


sub G {
  my ($x,$moy,$var) = @_;
 return 1/(sqrt($var)*2.506628274631000502) * exp(-0.5 * (($x-$moy)**2/$var) ); 
}


sub compute_mean_std_dev {
    my ($p_tab, $p_long, $deb, $fin, @coeff) = @_;
    my $moy = 0;
    my $var = 0;
    my $total = 0;
    $deb = int($deb);
    $fin = int($fin);
    for (my $i=$deb ; $i < $fin; $i++) {
      if ($$p_long[$i] > 0) {
        $moy += $$p_tab[$i]*$coeff[$i];
        $var += $$p_tab[$i]*($coeff[$i]**2);
        $total += $$p_tab[$i];
      }
    }
    if ($total > 0) {
      $moy /= $total;
      $var /= $total;
      $var = abs($var - $moy**2);
      my $MIN = 0.00000001;
      if ($var < $MIN) { $var = $MIN; }
      return ($moy,$var);
    }
    else { return (($deb+$fin/2),1); }
}


sub compute_error {
    my ($p_tab,$p_long,$deb,$fin,$taille,$moy,$var) = @_;
    my $sq_err = 0;
    my $norm = 0.0000001;
    for (my $i=0;$i < $taille;$i++) {
        $norm += G($i,$moy,$var); 
    }
    for (my $i=0;$i < $taille;$i++) {
        my $p = (G($i,$moy,$var))/$norm;
        my $e;
           $e = ($p*$$p_tab[$i]);
        $sq_err += $e;
    }
    return $sq_err;
}

=pod
*/
/**
 * Nettoie un texte prélablement filté par extract_content_rec
 * @param $texte du texte déjà filtré mais avec encore des pubs ou autres
 */
 public: string build_histogram($texte);
/*
=cut
sub build_histogram {
	my $p_texte = shift;
	my @tab = split(/\n/, $$p_texte);
	my @long;
	my $taille_fenetre = 30;
	my @res;
	my $retour = "";

	my $m1=0;
	my $v1=0;
	my $taille = 0;

	my $taille_non_zero = 0;

	my $seuil = 0.5;
	my $somme = 0;
	my $somme_attenuation = 0;
	my $attenuation = 0;
	my $i = 0;
	my $j = 0;
	my @longueur = map { length($_)  } @tab;
	my $max = max(@longueur);

	@long = map {$_ * (1 / $max)} @longueur;

	#Compute the smoothed number of words per line for each line
	for ($i = 0; $i < @tab; $i++) {
		$somme = 0;
		$somme_attenuation = 0;
		$attenuation = 0;
		#avant
		for ($j = $i-$taille_fenetre; $j < $i; $j++) {
			$attenuation = exp(-0.5 * ((($j-$i)/(1.0*$taille_fenetre))**2) );
			$somme_attenuation += $attenuation;
			$somme += $attenuation*($j < 0? 0 : $long[$j]);
		}
		#la ligne
		$somme += $long[$i];
		$somme_attenuation += 1;
		#apres
		for ($j = $i+$taille_fenetre; $j > $i; $j--) {
			$attenuation = exp(-0.5 * ((($j-$i)/(1.0*$taille_fenetre))**2) );
			$somme_attenuation += $attenuation;
			$somme += $attenuation*($j > @tab-1 ? 0 : $long[$j]);
		}
		$res[$i] = ($somme / $somme_attenuation);
		$taille++;
	}
  #Look for the portion of the text with the biggest homogeneous density of words
  my %moy;
  my %var;
  my $a_best = 0;
  my $b_best = @res+0;
  my $taille = $b_best;
  my ($moy_best, $var_best) = compute_mean_std_dev(\@res,\@long,$a_best,$b_best, ($a_best..$b_best));
  my $err_best = compute_error(\@res, \@long, $a_best, $b_best, $taille, $moy_best, $var_best);
  my $mieux = 1;
  while ($mieux == 1) {
    $mieux = 0;
    my $a1 = $a_best;
    my $b1 = int($moy_best-1);
    my ($moy1, $var1) = compute_mean_std_dev(\@res,\@long,$a1,$b1,($a1..$b1));
    my $err1 = compute_error(\@res, \@long, $a1, $b1, $taille, $moy1, $var1);    
    
    my $a2 = int($moy_best+1);
    my $b2 = $b_best;
    my ($moy2, $var2) = compute_mean_std_dev(\@res,\@long,$a2,$b2, ($a2..$b2));
    my $err2 = compute_error(\@res, \@long, $a2, $b2, $taille, $moy2, $var2);    

    #move on right
    my ($a,$b);
    if ($err1 < $err2) {
        $a = $a_best+1;
	while ($long[$a] == 0) { $a++; }
        $b = $b_best;
    }
    #move on left
    if ($err1 > $err2) {
        $a = $a_best;
        $b = $b_best-1;
	while ($long[$b] == 0) { $b--; }
    }
    my ($moy, $var) = compute_mean_std_dev(\@res,\@long,$a,$b, ($a..$b));
    my $err = compute_error(\@res, \@long, $a, $b, $taille, $moy, $var);    
    
    if (($err >= $err_best) && ($a_best != $a || $b_best != $b)) {
      $mieux = 1;
        $a_best = $a;
        $b_best = $b;
        $err_best = $err;
        $moy_best = $moy;
        $var_best = $var;
    }
  }

#   $var_best = ($b_best-$a_best)/2;
  
  #Compute average and variance of the number of words for the most homogeneous text part
  my @P_ligne = ();
  for (my $i = 0; $i < $taille; $i++) {
	$P_ligne[$i] = G($i,$moy_best,$var_best);
  }
  my ($m1,$v1) = compute_mean_std_dev(\@P_ligne, \@long, 0, $taille, @res);
  
  
  
  #discard lines where the number of words is too far from what's expected
  my $max = G($moy_best,$moy_best,$var_best);
  my $max1 = G($m1,$m1,$v1);
#   print "lignes moy=$moy_best var=$var_best max=$max\n";
#   print "scores moy=$m1 var=$v1 max=$max1\n";
  for (my $i = 0; $i < $taille; $i++) {
#		print G($res[$i],$m1,$v1)."\n";
#		print G($i,$moy_best,$var_best)."\n";
#		print $tab[$i]."\n";
	if (G($res[$i],$m1,$v1) > 0.00001*$max1 && (G($i,$moy_best,$var_best) > 0.00001*$max)) {
          $retour .= $tab[$i]."\n";
      }
  }
  
  
	return \$retour;
}








sub f_block {
	my $p_block = shift;
	my $block_sep = shift;
	my @tableau = ();
	my @score_tab = ();
		my $j = 0;
		for ($j = 0; $j < $block_sep; $j++) {
			$$p_block =~ s/\n$//;
		}
		@tableau = extract_decision_param($p_block);
		@score_tab = removal_decision(0.6, @tableau);
		$verbose && print "\t\t\t\t\t\t","[", $score_tab[0], "]","\n";
		if ($score_tab[0] == 1) {
			return $$p_block;
		}
		else { return "\n"; }
		return;
}

sub block_filtering {
	my $p_texte = shift;
	my $block_sep = shift; #3 empty lines
	my $i = 0;
	my @sortie = ();
	my $n = 0;
	my $block = "";




	my @tab = split(/\n/, $$p_texte);
	for ($i = 0; $i < @tab; $i++) {
		if ($tab[$i] =~ /^$/) {
			$n++;
			if ($n == $block_sep) {
				push(@sortie, f_block(\$block,$block_sep));
				$block = "";
			}
		}
		else {
			$n=0;
		}
		$block .= $tab[$i]."\n";
	}
	if ($n < $block_sep) { push(@sortie, f_block(\$block,$block_sep)); }

	my $retour = join("\n", @sortie);
	if (($retour =~ tr/ //) < 50) { $retour = ""; } 
	return \$retour;
}









=pod
*/
/**
 * Rend le corps (la partie avec le contenu principale) d'une page HTML
 * @param $texte du code HTML
 */
/*
=cut
sub extract_content {
	my $p_texte = shift;
	my $texte;
	if ($p_texte == undef) {
		$texte = "";
	}
	else {
		$texte = $$p_texte;
	}
	
	$texte =~ s/\r\n/\n/gim;
	$texte =~ s/\r/\n/gim;
	
	#processing cut sentences (ending with -)
	# this shouldn't have big side effects since lines ending with a dash
	# are quite exclusively related to the case of cut words.
	#a-\nb ... -> a-b
	$texte =~ s/([a-z])- *[\n\r](?: *<[Bb][Rr]\/?>)? *([a-z])/$1-$2/gm;
	#1-\n2 ... -> 1-2
	$texte =~ s/([0-9])- *[\n\r](?: *<[Bb][Rr]\/?>)? *([0-9])/$1-$2/gm;
	#Abc-\nDef ... -> Abc-Def
	$texte =~ s/([A-Z]\w+)- *[\n\r](?: *<[Bb][Rr]\/?>)? *([A-Z]\w+)/$1-$2/gm;
	$texte =~ s/\n+/ /gm;
	$texte =~ s/( [a-z]+)- +/$1-/g;
	
	my $p_param_res;
	my $p_res = "";

	my $tree = HTML::TreeBuilder->new; # empty tree
	clean_text(\$texte);
	
	#remove layout markups
	my @LAYOUT_MARKUPS = ("b","i","u","a","strong","code", "em");
	foreach my $markup (@LAYOUT_MARKUPS) {
		$texte =~ s/<\/?$markup( .*?)?>/ /gi;
	}
	$texte =~ s/<h[4-6].*?>/ /gi;
	$texte =~ s/<\/h[4-6]>/<br>/gi;
	$texte =~ s/\n//g;
	$texte =~ s/<script(?:.|\n)*?<\/script>/ /ig;
	$texte =~ s/<!--(?:.|\n)*?-->/ /mg;

	$verbose && print $texte."\n\n";
	$tree->parse($texte);
	$tree->eof();
	$verbose && print STDERR "Pruning the DOM tree...\n";
	$seuil_max = 0.4;
	$p_param_res = extract_content_rec($tree, $seuil_max);
	$p_res = $$p_param_res[0];
	$tree = $tree->delete;
	$$p_res =~ s/\n +/\n/gi;
	$$p_res =~ s/ +\n/\n/gi;
	
	#compact remaining cut words
	#a-\nb ... -> a-b
	$$p_res =~ s/([a-z])-\n([a-z])/$1-$2/gm;
	#1-\n2 ... -> 1-2
	$$p_res =~ s/([0-9])-\n([0-9])/$1-$2/gm;
	#Abc-\nDef ... -> Abc-Def
	$$p_res =~ s/([A-Z]\w+)-\n([A-Z]\w+)/$1-$2/gm;
	
# 	print $$p_res."\n";
	
	$verbose && print STDERR "Looking for the most dense unpruned part.\n";
 	$verbose && print "BEFORE SEPARATING THE MAIN TEXT SOURCE FROM THE OTHER ONES:\n$$p_res\n--------------------------\n";
	$p_res =  block_filtering(build_histogram($p_res),2);
#	$$p_res =~ s/\n\n+/\n\n/mg;
	$verbose && print "--------------------------- END ------------------------------\n\n";
	return $p_res;
}


1;

=pod
*/
}
=cut

