#!/usr/bin/perl

### "global" settings and script settings
#  base directory and static locations for certain parts of the site
$basedir="";

#  media
$directory="media";
$mediaitem="cgi-bin/$directory/media_";
$thispage="transfer.pl";
$debug=$mediaitem."debug.txt";

#  headers for the admin pages
$dateupdated="2016.09.07";

&getqueries;

### header for admin pages
if ($dotype) {&header; &media;}
else {&header;&errorfatal("missing or invalid administration page<br>select a link above");}
# end

sub media {
		if ($dotype eq "videos") {
			$mediaitem.="videos.txt";
			$columns=13;
		}

		open (READINFO,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@infile = <READINFO>;
		close (READINFO);
		@infile=sort(@infile);

		$changed=0;

		if ($dotype eq 'videos'){
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|\n";
			$new="$newtitle|$newtype|$newbluray|$newdvd|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$newupc|$newisbn|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|<br>\n";
			$previewnew="$newtitle|$newtype|$newbluray|$newdvd|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$newupc|$newisbn|<br>\n";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$intype,$inbluray,$indvd,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$inupc,$inisbn) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $oldtitle) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newtitle updated<br><br>\n";
				} else {
					$inmedia="";
					if ($inbluray eq "X") {
						$inmedia="bluray";
					}
					if ($indvd eq "X") {
						$inmedia="dvd";
					}
					if ($indvd eq "X" && $inbluray eq "X") {
						$inmedia="diskcombo";
					}
					$writenew.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$inupc|$inisbn|\n";
					$preview.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$inupc|$inisbn|<br>\n";
				}
			}
		} elsif ($dotype eq 'music'){
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$new="$newartist|$newtitle|$newupc|$newcd|$newamazon|$newdjbooth|$newgoogleplay|$newgroove|$newitunes|$newreverbnation|$newtopspin|$newrhapsody|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";
			$previewnew="$newartist|$newtitle|$newupc|$newcd|$newamazon|$newdjbooth|$newgoogleplay|$newgroove|$newitunes|$newreverbnation|$newtopspin|$newrhapsody|<br>\n";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($inartist,$intitle,$inupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody) = split(/\|/,$line);
				if ($inartist eq "#DATE#") {
					#skip
				} elsif (($intitle eq $oldtitle) && ($inartist eq $oldartist)) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newartist, $newtitle updated<br><br>\n";
				} else {
					$writenew.="$inartist|$intitle|$inupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|\n";
					$preview.="$inartist|$intitle|$inupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|<br>\n";
				}
			}
		}

		if ($changed != 1) {
			$writenew.=$new;
			$preview.=$previewnew;
			if ($newartist) {
				print "$newartist, ";
			}
			print "$newtitle added<br><br>\n";
		}

		if ($debugwrite eq "1") {
			open (WRITEINFO,">$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
			print (WRITEINFO $writenew);
			close (WRITEINFO);
		}

		if ($debugpreviewhide eq "1") {
			print "<!--\n$writenew\n-->\n";
		}

		if ($debugpreviewshow eq "1") {
			print "$preview";
		}

		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=$thispage?dotype=$dotype\">\n";
		print "     <p><a href=\"$thispage?gopage=media&dotype=$dotype\">main screen</a>";
		&footer;
}

sub header {
	local($e) = @_;
	print "$delay\n<html>\n<head>\n <title>EZ Editor: Media Admin</title>\n";
	print " <LINK HREF=\"/styles/adminstyle.css\" REL=\"stylesheet\" TYPE=\"text/css\" />\n";
	print "</head>\n<body topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0>\n";
	print "<table width=100% height=100% border=1 align=center valign=center>\n";
	print " <tr>\n  <td height=20 colspan=3 valign=top align=center class=header>\n";
	print "   <table width=100% cellspacing=0 cellpadding=0 border=0>\n";
	print "    <tr>\n";
	if ($preview or $showhide) {
		print "     <td align=center class=header width=50%>Media Admin: write $write | preview $preview and $showhide</td>\n";
	} else {
		print "     <td align=center class=header width=50%>Media Admin: write $write</td>\n";
	}
	print "     <td align=center class=header width=50%>{ <a href=\"$thispage?dotype=debug&dowhat=debugview&fromtype=$dotype\">debugview</a> | <a href=\"$thispage?dotype=books\">books</a> | <a href=\"$thispage?dotype=games\">games</a> | <a href=\"$thispage?dotype=music\">music</a> | <a href=\"$thispage?dotype=videos\">videos</a> }</td>\n";
	print "    </tr>\n   </table>\n  </td>\n </tr>\n\n <tr>\n <form method=get action=$thispage>\n  <td align=center>";
}

sub footer {
	print "\n  </td>\n </tr>\n </form>\n</table>\n</body>\n</html>";
	exit;
}

sub error {
	local($e) = @_;
	print "$e\n";
}

sub errorfatal {
	local($e) = @_;
	print "\n   $e\n  </td>\n </tr>\n </form>\n</table>\n</body>\n</html>";
	exit;
}

sub getqueries {
	print "Content-type: text/html\nPragma: no-cache\n\n";

	# current date/time
	my($sec,$min,$hours,$day,$mon,$year)=localtime(time);
	$mon=$mon+1;
	if(length($mon) eq '1') {$mon="0$mon";}
	if(length($day) eq '1') {$day="0$day";}
	$year=$year+1900;
	$today="$mon.$day.$year";

	## enable or disable update functions
	open (debug,"$basedir/$debug") || &error("error: mediaitem /$debug");
	@in = <debug>;
	close (debug);
	for $line(@in) {
		($debugwrite,$debugpreviewhide,$debugpreviewshow) = split(/\|/,$line);
	}

	# delay write information display
	if ($debugpreviewhide eq "1") {
		$preview="on";
		$showhide="hidden";
		$wait=10;
	}
	if ($debugpreviewshow eq "1") {
		$preview="on";
		$showhide="shown";
		$wait=10;
	}
	if ($debugwrite eq "1") {
		$write="enabled";
		$wait=4;
	} else {
		$write="disabled";
		$wait=10;
	}

	# retrieve information passed from/to scripts
	$delay="<!--ez editor v$dateupdated || today $today || debugpreviewshow $debugpreviewshow || debugpreviewhide $debugpreviewhide || wait $wait";
	@querys = split(/&/, $ENV{'QUERY_STRING'});
	foreach $query (@querys) {
		($name, $value) = split(/=/, $query);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ s/<!--(.|\n)*-->//g;
		$value =~ s/\"/\'\'/g;
		$value =~ s/\&/and/g;
		$FORM{$name} = $value;
		$delay.=" || $name = $value";
	}
	$delay.="-->";

	###### global
	$action=$FORM{'action'};
	#### media
	$dotype=$FORM{'dotype'};
	$dowhat=$FORM{'dowhat'};
	$showline=$FORM{'showline'};
	$continue=$FORM{'continue'};
	## global
	$newtitle=$FORM{'newtitle'};
	$oldtitle=$FORM{'oldtitle'};
	$newupc=$FORM{'newupc'};
	$newisbn=$FORM{'newisbn'};
	$oldupc=$FORM{'oldupc'};
	$oldisbn=$FORM{'oldisbn'};
	$newtype=$FORM{'newtype'};
	$oldtype=$FORM{'oldtype'};
	$newamazon=$FORM{'newamazon'};
	$oldamazon=$FORM{'oldamazon'};
	$newgoogleplay=$FORM{'newgoogleplay'};
	$oldgoogleplay=$FORM{'oldgoogleplay'};
	$newitunes=$FORM{'newitunes'};
	$olditunes=$FORM{'olditunes'};
	## books
	$newauthor=$FORM{'newauthor'};
	$oldauthor=$FORM{'oldauthor'};
	## games
	$newepic=$FORM{'newepic'};
	$oldepic=$FORM{'oldepic'};
	$newsteam=$FORM{'newsteam'};
	$oldsteam=$FORM{'oldsteam'};
	$newbattlenet=$FORM{'newbattlenet'};
	$oldbattlenet=$FORM{'oldbattlenet'};
	$neworigin=$FORM{'neworigin'};
	$oldorigin=$FORM{'oldorigin'};
	$newuplay=$FORM{'newuplay'};
	$olduplay=$FORM{'olduplay'};
	$newnes=$FORM{'newnes'};
	$oldnes=$FORM{'oldnes'};
	$newwii=$FORM{'newwii'};
	$oldwii=$FORM{'oldwii'};
	$newps2=$FORM{'newps2'};
	$oldps2=$FORM{'oldps2'};
	$newxboxone=$FORM{'newxboxone'};
	$oldxboxone=$FORM{'oldxboxone'};
	$newxbox360=$FORM{'newxbox360'};
	$oldxbox360=$FORM{'oldxbox360'};
	## videos
	$newbluray=$FORM{'newbluray'};
	$oldbluray=$FORM{'oldbluray'};
	$newdvd=$FORM{'newdvd'};
	$olddvd=$FORM{'olddvd'};
	$newdisneyanywhere=$FORM{'newdisneyanywhere'};
	$olddisneyanywhere=$FORM{'olddisneyanywhere'};
	$newuvvu=$FORM{'newuvvu'};
	$olduvvu=$FORM{'olduvvu'};
	## music
	$newartist=$FORM{'newartist'};
	$oldartist=$FORM{'oldartist'};
	$newdjbooth=$FORM{'newdjbooth'};
	$olddjbooth=$FORM{'olddjbooth'};
	$newcd=$FORM{'newcd'};
	$oldcd=$FORM{'oldcd'};
	$newgroove=$FORM{'newgroove'};
	$oldgroove=$FORM{'oldgroove'};
	$newrhapsody=$FORM{'newrhapsody'};
	$oldrhapsody=$FORM{'oldrhapsody'};
	$newtopspin=$FORM{'newtopspin'};
	$oldtopspin=$FORM{'oldtopspin'};
	$newreverbnation=$FORM{'newreverbnation'};
	$oldreverbnation=$FORM{'oldreverbnation'};
	## debug
	$editdebugwrite=$FORM{'debugwrite'};
	$editdebugpreviewhide=$FORM{'debugpreviewhide'};
	$editdebugpreviewshow=$FORM{'debugpreviewshow'};
	$fromtype=$FORM{'fromtype'};
}
