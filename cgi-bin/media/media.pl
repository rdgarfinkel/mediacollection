#!/usr/bin/perl

print "Content-type: text/html\nPragma: no-cache\n\n";

### "global" settings and script settings
###    base directory and static locations for certain parts of the site
$basedir="";

#  media
$directory="media";
$mediaitem="cgi-bin/$directory/media_";
$mediacheck="cgi-bin";
$thispage="media.pl";
$debug=$mediaitem."debug.txt";

#  headers for the admin pages
$dateupdated="2016.09.08";

&getqueries;

### header for admin pages
if ($dotype) {&header; &media;}
else {&header;&errorfatal("missing or invalid administration page<br>select a link above");}
# end

sub media {
	if ($dotype eq "books") {
		$mediaitem.="books.txt";
		$columns=7;
	} elsif ($dotype eq "games") {
		$mediaitem.="games.txt";
		$columns=14;
	} elsif ($dotype eq "music") {
		$mediaitem.="music.txt";
		$columns=13;
	} elsif ($dotype eq "videos") {
		$mediaitem.="videos.txt";
		$columns=13;
	} elsif ($dotype eq "debug") {
		$mediaitem.="debug.txt";
		$columns=3;
	} else {
		&errorfatal("missing \'dotype\'");
	}

	if ($dowhat eq "mediaedit") {&mediaedit;}
	elsif ($dowhat eq "mediaadd") {&mediaedit;}
	elsif ($dowhat eq "mediabarcode") {&mediaaddid;}
	elsif ($dowhat eq "mediaisbn") {&mediaaddid;}
	elsif ($dowhat eq "mediacheck") {&mediacheck;}
	elsif ($dowhat eq "mediawrite") {&mediawrite;}
	elsif ($dowhat eq "mediadelete") {&mediadelete;}
	elsif ($dowhat eq "debugview") {&debugview;}
	elsif ($dowhat eq "debugedit") {&debugedit;}
	elsif ($dowhat eq "debugwrite") {&debugwrite;}
	else {&mediamain;}


	sub mediamain {
		open (media,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@in = <media>;
		close (media);

		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";

		$count_title=1;

		if ($dotype eq 'books'){
			$count_ebook=0;
			$count_book=0;
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>Author(s)</th>\n     <th>EAC/UPC</th>\n     <th>ISBN</th>\n     <th>Type</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n    <tbody>\n";

			foreach $line(@in) {
				$line =~ s/\n//g;
				$line =~ tr/+/ /;
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
				$line =~ s/<!--(.|\n)*-->//g;
				$line =~ s/\"/\'\'/g;
				($title,$author,$eacupc,$isbn,$type) = split(/\|/,$line);  
				if ($title ne "#DATE#") {
					if ($type eq "ebook") {
						$count_ebook=$count_ebook+1;
					} else {
						$count_book=$count_book+1;
					}
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					$authordisplay=$author;
					$authordisplay =~ s/\'\'/\"/g;
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$titledisplay</a></div></td>\n     <td><div>$authordisplay</div></td>\n     <td>$eacupc</td>\n     <td>$isbn</td>\n     <td>$type</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
					$count_title=$count_title+1;
				} else {
					$update=$author;
				}
			}
			$count_title=$count_title-1;
			print "    <tr><td align=center colspan=$columns><b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>books $count_book || ebooks $count_ebook</td></tr>\n";
		} elsif ($dotype eq 'games'){
			$count_epic=0;
			$count_steam=0;
			$count_battlenet=0;
			$count_origin=0;
			$count_uplay=0;
			$count_nes=0;
			$count_wii=0;
			$count_ps2=0;
			$count_xboxonebc=0;
			$count_xboxonedk=0;
			$count_xboxonedl=0;
			$count_xbox360dk=0;
			$count_xbox360dl=0;
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>EAC/UPC</th>\n     <th>Battle.net</th>\n     <th>Epic</th>\n     <th>NES</th>\n     <th>Origin</th>\n     <th>PS2</th>\n     <th>Steam</th>\n     <th>Uplay</th>\n     <th>XBox 360</th>\n     <th>XBox One</th>\n     <th>Wii</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n    <tbody>\n";

			foreach $line(@in) {
				$line =~ s/\n//g;
				$line =~ tr/+/ /;
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
				$line =~ s/<!--(.|\n)*-->//g;
				$line =~ s/\"/\'\'/g;
				($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc) = split(/\|/,$line);  
				if ($title ne "#DATE#") {
					if ($epic eq "X") {
						$count_epic=$count_epic+1;
					}
					if ($steam eq "X") {
						$count_steam=$count_steam+1;
					}
					if ($battlenet eq "X") {
						$count_battlenet=$count_battlenet+1;
					}
					if ($origin eq "X") {
						$count_origin=$count_origin+1;
					}
					if ($uplay eq "X") {
						$count_uplay=$count_uplay+1;
					}
					if ($nes eq "X") {
						$count_nes=$count_nes+1;
					}
					if ($wii eq "X") {
						$count_wii=$count_wii+1;
					}
					if ($ps2 eq "X") {
						$count_ps2=$count_ps2+1;
					}
					if ($xboxone eq "X, BC") {
						$count_xboxonebc=$count_xboxonebc+1;
						$xboxonetotal=$xboxonetotal+1;
					}
					if ($xboxone eq "X, DK") {
						$count_xboxonedk=$count_xboxonedk+1;
						$xboxonetotal=$xboxonetotal+1;
					}
					if ($xboxone eq "X, DL") {
						$count_xboxonedl=$count_xboxonedl+1;
						$xboxonetotal=$xboxonetotal+1;
					}
					if ($xbox360 eq "X, DK") {
						$count_xbox360dk=$count_xbox360dk+1;
						$xbox360total=$xbox360total+1;
					}
					if ($xbox360 eq "X, DL") {
						$count_xbox360dl=$count_xbox360dl+1;
						$xbox360total=$xbox360total+1;
					}
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$battlenet</td>\n     <td>$epic</td>\n     <td>$nes</td>\n     <td>$origin</td>\n     <td>$ps2</td>\n     <td>$steam</td>\n     <td>$uplay</td>\n     <td>$xbox360</td>\n     <td>$xboxone</td>\n     <td>$wii</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
					$count_title=$count_title+1;
				} else {
					$update=$epic;
				}
			}
			$count_title=$count_title-1;
			print "    <tr><td align=center colspan=$columns><b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>Battle.net $count_battlenet || Epic $count_epic || NES $count_nes || Origin $count_origin || PS2 $count_ps2 || Steam $count_steam || uPlay $count_uplay || Wii $count_wii || XBox 360 $xbox360total || XBox One $xboxonetotal<br>XBox One backwards compatible $count_xboxonebc || XBox One disk $count_xboxonedk ||  XBox One download $count_xboxonedl || XBox 360 disk $count_xbox360dk || XBox 360 download $count_xbox360dl</td></tr>\n";
		} elsif ($dotype eq 'videos'){
			$count_tv=0;
			$count_movie=0;
			$count_bluray=0;
			$count_dvd=0;
			$count_amazon=0;
			$count_disneyanywhere=0;
			$count_googleplay=0;
			$count_itunes=0;
			$count_uvvu=0;
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>EAC/UPC</th>\n     <th>ISBN</th>\n     <th>Type</th>\n     <th>Physical<br>Media</th>\n     <th>Amazon</th>\n     <th>Disney<br>Anywhere</th>\n     <th>Google<br>Play</th>\n     <th>iTunes</th>\n     <th>UVVU</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n    <tbody>\n";

			foreach $line(@in) {
				$line =~ s/\n//g;
				$line =~ tr/+/ /;
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
				$line =~ s/<!--(.|\n)*-->//g;
				$line =~ s/\"/\'\'/g;
				($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn) = split(/\|/,$line);  
				if ($title ne "#DATE#") {
					$mediadisplay="";
					if ($type eq "TV") {
						$count_tv=$count_tv+1;
					} else {
						$count_movie=$count_movie+1;
					}
					if ($media eq "bluray") {
						$count_bluray=$count_bluray+1;
						$mediadisplay="BluRay";
					} elsif ($media eq "dvd") {
						$count_dvd=$count_dvd+1;
						$mediadisplay="DVD";
					} elsif ($media eq "diskcombo") {
						$count_bluray=$count_bluray+1;
						$count_dvd=$count_dvd+1;
						$mediadisplay="BluRay/DVD";
					}
					if ($amazon eq "X") {
						$count_amazon=$count_amazon+1;
					}
					if ($disneyanywhere eq "X") {
						$count_disneyanywhere=$count_disneyanywhere+1;
					}
					if ($googleplay eq "X") {
						$count_googleplay=$count_googleplay+1;
					}
					if ($itunes eq "X") {
						$count_itunes=$count_itunes+1;
					}
					if ($uvvu eq "X") {
						$count_uvvu=$count_uvvu+1;
					}
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$isbn</td>\n     <td>$type</td>\n     <td>$mediadisplay</td>\n     <td>$amazon</td>\n     <td>$disneyanywhere</td>\n     <td>$googleplay</td>\n     <td>$itunes</td>\n     <td>$uvvu</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
					$count_title=$count_title+1;
				} else {
					$update=$type;
				}
			}
			$count_title=$count_title-1;
			print "    <tr><td align=center colspan=$columns><b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>Movies $count_movie || TV $count_tv || BluRay $count_bluray || DVDs $count_dvd || Amazon Video $count_amazon || Disney Anywhere $count_disneyanywhere || Google Play $count_googleplay || iTunes $count_itunes || UVVU $count_uvvu</td></tr>\n";
		} elsif ($dotype eq 'music'){
			$count_cd=0;
			$count_amazon=0;
			$count_djbooth=0;
			$count_googleplay=0;
			$count_groove=0;
			$count_itunes=0;
			$count_reverbnation=0;
			$count_topspin=0;
			$count_rhapsody=0;
			print "    <thead>\n     <th>#</th>\n     <th>Artist &ndash; Title</th>\n     <th>EAC/UPC</th>\n     <th>CD</th>\n     <th>Amazon</th>\n     <th>DJ Booth</th>\n     <th>Google<br>Play</th>\n     <th>Groove</th>\n     <th>iTunes</th>\n     <th>ReverbNation</th>\n     <th>Rhapsody</th>\n     <th>TopSpin</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n    <tbody>\n";

			foreach $line(@in) {
				$line =~ s/\n//g;
				$line =~ tr/+/ /;
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
				$line =~ s/<!--(.|\n)*-->//g;
				$line =~ s/\"/\'\'/g;
				($artist,$title,$eacupc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody) = split(/\|/,$line);
				if ($artist ne "#DATE#") {
					if ($cd eq "X") {
						$count_cd=$count_cd+1;
					}
					if ($amazon eq "X") {
						$count_amazon=$count_amazon+1;
					} 
					if ($djbooth eq "X") {
						$count_djbooth=$count_djbooth+1;
					}
					if ($googleplay eq "X") {
						$count_googleplay=$count_googleplay+1;
					}
					if ($groove eq "X") {
						$count_groove=$count_groove+1;
					}
					if ($itunes eq "X") {
						$count_itunes=$count_itunes+1;
					}
					if ($reverbnation eq "X") {
						$count_reverbnation=$count_reverbnation+1;
					}
					if ($topspin eq "X") {
						$count_topspin=$count_topspin+1;
					}
					if ($rhapsody eq "X") {
						$count_rhapsody=$count_rhapsody+1;
					}
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					$artistdisplay=$artist;
					$artistdisplay =~ s/\'\'/\"/g;
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$artistdisplay &ndash; $titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$cd</td>\n     <td>$amazon</td>\n     <td>$djbooth</td>\n     <td>$googleplay</td>\n     <td>$groove</td>\n     <td>$itunes</td>\n     <td>$reverbnation</td>\n     <td>$rhapsody</td>\n     <td>$topspin</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
					$count_title=$count_title+1;
				} else {
					$update=$title;
				}
			}
			$count_title=$count_title-1;
			print "    <tr><td align=center colspan=$columns><b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>CD $count_cd || Amazon $count_amazon || DJ Booth $count_djbooth || Google Play $count_googleplay || Groove $count_groove || iTunes $count_itunes || ReverbNation $count_reverbnation || TopSpin $count_topspin || Rhapsody $count_rhapsody</td></tr>\n";
		}

		if ($dotype ne "debug") {
			print "    <tr><td align=center colspan=$columns><a href=\"$thispage?dowhat=mediaadd&dotype=$dotype\">Add Item</a></td></tr>\n";
		}
		print "    </tbody>\n";
		print "   </table>";

		&footer;
	}

	sub mediaedit{
		print "\n   <table cellspacing=2 cellpadding=2>\n";

		if ($showline) {
			$showline =~ tr/+/ /;
			$showline =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$showline =~ s/<!--(.|\n)*-->//g;
		}

		if ($dotype eq 'books'){
			if ($dowhat eq "mediaadd") {
				$author=$newauthor;
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
				$type=$newtype;
			} else {
				($title,$author,$eacupc,$isbn,$type)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Author:</th>\n      <td><input type=text name=newauthor value=\"$author\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td>\n       <input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Type:</th>\n      <td>\n";
			print "       <select name=newtype>\n";
			if ($type eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($type eq 'book'){
				print "        <option value=\"book\" selected>book</option>\n";
			} else {
				print "        <option value=\"book\">book</option>\n";
			}
			if ($type eq 'ebook'){
				print "        <option value=\"ebook\" selected>ebook</option>\n";
			} else {
				print "        <option value=\"ebook\">ebook</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";
		} elsif ($dotype eq 'games'){
			if ($dowhat eq "mediaadd") {
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
			} else {
				($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td>\n       <input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Epic:</th>\n      <td>\n";
			print "       <select name=newepic>\n";
			if ($epic eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($epic eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Steam:</th>\n      <td>\n";
			print "       <select name=newsteam>\n";
			if ($steam eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($steam eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Battlenet:</th>\n      <td>\n";
			print "       <select name=newbattlenet>\n";
			if ($battlenet eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($battlenet eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Origin:</th>\n      <td>\n";
			print "       <select name=neworigin>\n";
			if ($origin eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($origin eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>uPlay:</th>\n      <td>\n";
			print "       <select name=newuplay>\n";
			if ($uplay eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($uplay eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>NES:</th>\n      <td>\n";
			print "       <select name=newnes>\n";
			if ($nes eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($nes eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Wii:</th>\n      <td>\n";
			print "       <select name=newwii>\n";
			if ($wii eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($wii eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>PS2:</th>\n      <td>\n";
			print "       <select name=newps2>\n";
			if ($ps2 eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($ps2 eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>XBoxOne:</th>\n      <td>\n";
			print "       <select name=newxboxone>\n";
			if ($xboxone eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($xboxone eq 'X, BC'){
				print "        <option value=\"X, BC\" selected>X, backwards compatibility</option>\n";
			} else {
				print "        <option value=\"X, BC\">X, backwards compatibility</option>\n";
			}
			if ($xboxone eq 'X, DK'){
				print "        <option value=\"X, DK\" selected>X, disk</option>\n";
			} else {
				print "        <option value=\"X, DK\">X, disk</option>\n";
			}
			if ($xboxone eq 'X, DL'){
				print "        <option value=\"X, DL\" selected>X, download</option>\n";
			} else {
				print "        <option value=\"X, DL\">X, download</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>XBox360:</th>\n      <td>\n";
			print "       <select name=newxbox360>\n";
			if ($xbox360 eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";}
			if ($xbox360 eq 'X, DK'){
				print "        <option value=\"X, DK\" selected>X, disk</option>\n";
			} else {
				print "        <option value=\"X, DK\">X, disk</option>\n";
			}
			if ($xbox360 eq 'X, DL'){
				print "        <option value=\"X, DL\" selected>X, download</option>\n";
			} else {
				print "        <option value=\"X, DL\">X, download</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";
		} elsif ($dotype eq 'videos'){
			if ($dowhat eq "mediaadd") {
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
				$type=$newtype;
			} else {
				($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Type:</th>\n      <td>\n";
			print "       <select name=newtype>\n";
			if ($type eq 'Movie'){
				print "        <option value=\"Movie\" selected>Movie</option>\n";
			} else {
				print "        <option value=\"Movie\">Movie</option>\n";
			}
			if ($type eq 'TV'){
				print "        <option value=\"TV\" selected>TV</option>\n";
			} else {
				print "        <option value=\"TV\">TV</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Media:</th>\n      <td>\n";
			print "       <select name=newmedia>\n";
			if ($media eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($media eq 'dvd'){
				print "        <option value=\"dvd\" selected>DVD</option>\n";
			} else {
				print "        <option value=\"dvd\">DVD</option>\n";
			}
			if ($media eq 'bluray'){
				print "        <option value=\"bluray\" selected>BluRay</option>\n";
			} else {
				print "        <option value=\"bluray\">BluRay</option>\n";
			}
			if ($media eq 'diskcombo'){
				print "        <option value=\"diskcombo\" selected>BluRay/DVD</option>\n";
			} else {
				print "        <option value=\"diskcombo\">BluRay/DVD</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Amazon:</th>\n      <td>\n";
			print "       <select name=newamazon>\n";
			if ($amazon eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($amazon eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>DisneyAnywhere:</th>\n      <td>\n";
			print "       <select name=newdisneyanywhere>\n";
			if ($disneyanywhere eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($disneyanywhere eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>GooglePlay:</th>\n      <td>\n";
			print "       <select name=newgoogleplay>\n";
			if ($googleplay eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($googleplay eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>iTunes:</th>\n      <td>\n";
			print "       <select name=newitunes>\n";
			if ($itunes eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($itunes eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>UVVU:</th>\n      <td>\n";
			print "       <select name=newuvvu>\n";
			if ($uvvu eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($uvvu eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";
		} elsif ($dotype eq 'music'){
			if ($dowhat eq "mediaadd") {
				$artist=$newauthor;
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
			} else {
				($artist,$title,$eacupc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Artist:</th>\n      <td><input type=text name=newartist value=\"$artist\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>CD:</th>\n      <td>\n";
			print "       <select name=newcd>\n";
			if ($cd eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($cd eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Amazon:</th>\n      <td>\n";
			print "       <select name=newamazon>\n";
			if ($amazon eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($amazon eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>DJBooth:</th>\n      <td>\n";
			print "       <select name=newdjbooth>\n";
			if ($djbooth eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($djbooth eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>GooglePlay:</th>\n      <td>\n";
			print "       <select name=newgoogleplay>\n";
			if ($googleplay eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($googleplay eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>Groove:</th>\n      <td>\n";
			print "       <select name=newgroove>\n";
			if ($groove eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($groove eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>iTunes:</th>\n      <td>\n";
			print "       <select name=newitunes>\n";
			if ($itunes eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($itunes eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>ReverbNation:</th>\n      <td>\n";
			print "       <select name=newreverbnation>\n";
			if ($reverbnation eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($reverbnation eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";
			
			print "     <tr>\n      <th align=right>Rhapsody:</th>\n      <td>\n";
			print "       <select name=newrhapsody>\n";
			if ($rhapsody eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($rhapsody eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";

			print "     <tr>\n      <th align=right>TopSpin:</th>\n      <td>\n";
			print "       <select name=newtopspin>\n";
			if ($topspin eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($topspin eq 'X'){
				print "        <option value=\"X\" selected>X</option>\n";
			} else {
				print "        <option value=\"X\">X</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n     </tr>\n";
		}

		print "     <tr>\n      <td colspan=2 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <input type=hidden name=dowhat value=mediawrite>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=oldtitle value=\"$title\">\n";

		if ($dotype eq 'music'){
			print "     <input type=hidden name=oldartist value=\"$artist\">\n";
		}

		print "    </table>";

		&footer;
	}

	sub mediadelete {
		open (READINFO,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@infile = <READINFO>;
		close (READINFO);
		@infile=sort(@infile);

		if ($showline) {
			$showline =~ tr/+/ /;
			$showline =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$showline =~ s/<!--(.|\n)*-->//g;
		}
		($thisentry1,$thisentry2) = split(/\|/,$showline);

		if ($continue ne 'Yes') {
			print "\n   <P>Continuing this action will remove the entry for<br><br><b>$thisentry1";
			if ($dotype eq "music") {
				print " -  $thisentry2";
			}
			print "</b><br><br>Are you sure you want to do this?</P>\n   <input type=submit name=continue value=Yes>\n   <input type=button value=No onClick=\"history.back()\">\n   <input type=hidden name=gopage value=media>\n   <input type=hidden name=dotype value=$dotype>\n   <input type=hidden name=dowhat value=mediadelete>\n   <input type=hidden name=showline value=\"$showline\">";
			&footer;
		} else {
			$changed=0;
		}

		if ($dotype eq 'books'){
			($thistitle,$thisauthor,$thiseacupc,$thisisbn)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|<br>\n";
			$new="$thistitle|$thisauthor|$thiseacupc|$thisisbn|<br>\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$inauthor,$ineacupc,$inisbn,$intype) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $thistitle) {
					$changed=1;
					print "$thistitle removed<br><br>\n";
				} else {
					$writenew.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|\n";
					$preview.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|<br>\n";
				}
			}
		} elsif ($dotype eq 'games'){
			($thistitle,$thisepic,$thissteam,$thisbattlenet,$thisorigin,$thisuplay,$thisnes,$thiswii,$thisps2,$thisxboxone,$thisxbox360,$thiseacupc)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";
			$new="$thistitle|$thisepic|$thissteam|$thisbattlenet|$thisorigin|$thisuplay|$thisnes|$thiswii|$thisps2|$thisxboxone|$thisxbox360|$thiseacupc|<br>\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$inepic,$insteam,$inbattlenet,$inorigin,$inuplay,$innes,$inwii,$inps2,$inxboxone,$inxbox360,$ineacupc) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $thistitle) {
					$changed=1;
					print "$thistitle removed<br><br>\n";
				} else {
					$writenew.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|\n";
					$preview.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|<br>\n";
				}
			}
		} elsif ($dotype eq 'videos'){
			($thistitle,$thistype,$thismedia,$thisamazon,$thisdisneyanywhere,$thisgoogleplay,$thisitunes,$thisuvvu,$thiseacupc,$thisisbn)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|<br>\n";
			$new="$thistitle|$thistype|$thismedia|$thisamazon|$thisdisneyanywhere|$thisgoogleplay|$thisitunes|$thisuvvu|$thiseacupc|$thisisbn|\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$intype,$inmedia,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$ineacupc,$inisbn) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $thistitle) {
					$changed=1;
					print "$thistitle removed<br><br>\n";
				} else {
					$writenew.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|\n";
					$preview.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|<br>\n";
				}
			}
		} elsif ($dotype eq 'music'){
			($thisartist,$thistitle,$thiseacupc,$thiscd,$thisamazon,$thisdjbooth,$thisgoogleplay,$thisgroove,$thisitunes,$thisreverbnation,$thistopspin,$thisrhapsody)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";
			$new="$thisartist|$thistitle|$thiseacupc|$thiscd|$thisamazon|$thisdjbooth|$thisgoogleplay|$thisgroove|$thisitunes|$thisreverbnation|$thistopspin|$thisrhapsody|\n";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($inartist,$intitle,$ineacupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody) = split(/\|/,$line);
				if ($inartist eq "#DATE#") {
					#skip
				} elsif ($intitle eq $thistitle) {
					$changed=1;
					print "$thisartist, $thistitle removed<br><br>\n";
				} else {
					$writenew.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|\n";
					$preview.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|<br>\n";
				}
			}
		}

		if ($debugwrite eq "1") {
			open (WRITEINFO,">$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
			print (WRITEINFO $writenew);
			close (WRITEINFO);
		}

		if ($debugpreviewhide eq "1") {
			print "$writenew";
		}

		if ($debugpreviewshow eq "1") {
			print "$preview";
		}

		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=$thispage?dotype=$dotype\">\n";
		print "     <p><a href=\"$thispage?dotype=$dotype\">main screen</a>";
		&footer;
	}

	sub mediawrite {
		open (READINFO,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@infile = <READINFO>;
		close (READINFO);
		@infile=sort(@infile);

		$changed=0;

		if ($dotype eq 'books'){
			$writenew="#DATE#|$today|#|#|#|\n";
			$new="$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|\n";
			$preview="#DATE#|$today|#|#|#|<br>\n";
			$previewnew="$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|<br>\n";
			$mediawrite="$dotype|$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$inauthor,$ineacupc,$inisbn,$intype) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $oldtitle) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newtitle updated<br><br>\n";
				} else {
					$writenew.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|\n";
					$preview.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|<br>\n";
				}
			}
		} elsif ($dotype eq 'games'){
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$new="$newtitle|$newepic|$newsteam|$newbattlenet|$neworigin|$newuplay|$newnes|$newwii|$newps2|$newxboxone|$newxbox360|$neweacupc|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";
			$previewnew="$newtitle|$newepic|$newsteam|$newbattlenet|$neworigin|$newuplay|$newnes|$newwii|$newps2|$newxboxone|$newxbox360|$neweacupc|<br>\n";
			$mediawrite="$dotype|$newtitle||$neweacupc|$newisbn||";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$inepic,$insteam,$inbattlenet,$inorigin,$inuplay,$innes,$inwii,$inps2,$inxboxone,$inxbox360,$ineacupc) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $oldtitle) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newtitle updated<br><br>\n";
				} else {
					$writenew.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|\n";
					$preview.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|<br>\n";
				}
			}
		} elsif ($dotype eq 'videos'){
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|\n";
			$new="$newtitle|$newtype|$newmedia|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$neweacupc|$newisbn|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|<br>\n";
			$previewnew="$newtitle|$newtype|$newmedia|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$neweacupc|$newisbn|<br>\n";
			$mediawrite="$dotype|$newtitle||$neweacupc|$newisbn|$newtype|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($intitle,$intype,$inmedia,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$ineacupc,$inisbn) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					#skip
				} elsif ($intitle eq $oldtitle) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newtitle updated<br><br>\n";
				} else {
					$writenew.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|\n";
					$preview.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|<br>\n";
				}
			}
		} elsif ($dotype eq 'music'){
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$new="$newartist|$newtitle|$neweacupc|$newcd|$newamazon|$newdjbooth|$newgoogleplay|$newgroove|$newitunes|$newreverbnation|$newtopspin|$newrhapsody|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";
			$previewnew="$newartist|$newtitle|$neweacupc|$newcd|$newamazon|$newdjbooth|$newgoogleplay|$newgroove|$newitunes|$newreverbnation|$newtopspin|$newrhapsody|<br>\n";
			$mediawrite="$dotype|$newtitle|$newartist|$neweacupc|$newisbn|$newtype|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line\n";
				($inartist,$intitle,$ineacupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody) = split(/\|/,$line);
				if ($inartist eq "#DATE#") {
					#skip
				} elsif (($intitle eq $oldtitle) && ($inartist eq $oldartist)) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newartist, $newtitle updated<br><br>\n";
				} else {
					$writenew.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|\n";
					$preview.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|<br>\n";
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
			open (WRITEINFO,">$basedir/$mediaitem") || &error("error: mediaitem $mediaitem<br>");
			print (WRITEINFO $writenew);
			close (WRITEINFO);

			if ($neweacupc) {
				$mediaeacupc="eacupc/$neweacupc";
				#print "$neweacupc";
				#print "$basedir/$mediacheck/$mediaeacupc<br>\n";
				open (WRITEINFO,"+>$basedir/$mediacheck/$mediaeacupc") || &error("error: mediaeacupc $mediaeacupc<br>");
				print (WRITEINFO $mediawrite);
				close (WRITEINFO);
			}

			if ($newisbn) {
				$mediaisbn="isbn/$newisbn";
				#print "$newisbn";
				#print "$basedir/$mediacheck/$mediaisbn<br>\n";
				open (WRITEINFO,"+>$basedir/$mediacheck/$mediaisbn") || &error("error: mediaisbn $mediaisbn<br>");
				print (WRITEINFO $mediawrite);
				close (WRITEINFO);
			}
		}

		if ($debugpreviewhide eq "1") {
			print "<!--\n$writenew\n-->\n";
			print "<!--\n$mediawrite\n-->\n";
		}

		if ($debugpreviewshow eq "1") {
			print "<p>$preview</p>";
			print "<p>mediawrite: $mediawrite</p>";
		}

		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=$thispage?dotype=$dotype\">\n";
		print "     <p><a href=\"$thispage?dotype=$dotype\">main screen</a>";

		&footer;
	}
	
	sub mediaaddid{
		print "\n   <table cellspacing=2 cellpadding=2>\n";

		if ($addtype eq "eacupc"){
			print "     <tr>\n      <th align=right width=30%>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
		} elsif ($addtype eq "isbn"){
			print "     <tr>\n      <th align=right width=30%>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";
		}
		
		print "     <tr>\n      <td colspan=2 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <input type=hidden name=dowhat value=mediacheck>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=addtype value=$addtype>\n";

		print "    </table>";

		&footer;
	}

	sub mediacheck{
		print "\n   <table cellspacing=2 cellpadding=2>\n";

		$textcheck="";
		if ($neweacupc) {
			$mediacheck.="/eacupc/$neweacupc";
			$textcheck.="EAC/UPC code $neweacupc";
		}
		if ($newisbn) {
			$mediacheck.="/isbn/$newisbn";
			$textcheck.="ISBN code $newisbn";
		}
		print "checking for an existing entry for $textcheck<br>\n";
		#print "$mediacheck<br>\n";

		$foundentry=1;
		open (media,"$basedir/$mediacheck") || &error("did not find an entry for $textcheck<br>forwarding to create an entry<br>");
		@in = <media>;
		close (media);

		if ($foundentry eq 1) {
			print "found that entry!<br>forwarding to edit the entry<br>";
			for $line(@in) {
				($dotype,$title,$author,$eacupc,$isbn,$type) = split(/\|/,$line);
				#print "$dotype,$title,$author,$eacupc,$isbn,$type<br>\n";
			}
			print "<p><META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL='$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$eacupc&newisbn=$isbn&newtitle=$title&newauthor=$author&newtype=$type'\">\n";
			print "<a href=\"$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$eacupc&newisbn=$isbn&newtitle=$title&newauthor=$author&newtype=$type\">continue</a></p>";
		} else {
			print "<p><META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL='$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$neweacupc&newisbn=$newisbn'\">\n";
			print "<a href=\"$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$neweacupc&newisbn=$newisbn\">continue</a></p>";
		}

		print "    </table>";

		&footer;
	}

	sub debugview {
		open (media,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@in = <media>;
		close (media);

		print "\n   <table cellspacing=2 cellpadding=2 id=\"mytable\">\n";
		print "    <thead>\n     <th>enable write</th>\n     <th>preview hidden</th>\n     <th>preview shown</th>\n    </tr>\n    </thead>\n    <tbody>\n";

		foreach $line(@in) {
			$line=~s/\n//g;
			($debugwrite,$debugpreviewhide,$debugpreviewshow) = split(/\|/,$line);
			if ($debugwrite eq 0) {$dashwrite="off";} else {$dashwrite="on";}
			if ($debugpreviewhide eq 0) {$dashpreviewhide="off";} else {$dashpreviewhide="on";}
			if ($debugpreviewshow eq 0) {$dashpreviewshow="off";} else {$dashpreviewshow="on";}
			print "    <tr class=\"grid\">\n     <td>$dashwrite</td>\n     <td>$dashpreviewhide</td>\n     <td>$dashpreviewshow</td>\n    </tr>\n";
		}
		print "    <tr><td align=center colspan=$columns><a href=\"$thispage?dowhat=debugedit&dotype=$dotype&fromtype=$fromtype\">Change Debug</a></td></tr>\n";
		print "    </tbody>\n   </table>\n";
	}

	sub debugedit {
		open (media,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@in = <media>;
		close (media);
		print "\n   <table cellspacing=2 cellpadding=2 id=\"mytable\">\n";
		print "    <thead>\n     <th>enable write</th>\n     <th>preview hidden</th>\n     <th>preview shown</th>\n    </tr>\n    </thead>\n    <tbody>\n";

		foreach $line(@in) {
			$line=~s/\n//g;
			($debugwrite,$debugpreviewhide,$debugpreviewshow) = split(/\|/,$line);
			print "     <tr class=\"grid\">\n";

			print "      <td>\n";
			print "       <select name=debugwrite>\n";
			if ($debugwrite eq '0'){
				print "        <option value=\"0\" selected>off</option>\n";
			} else {
				print "        <option value=\"0\">off</option>\n";
			}
			if ($debugwrite eq '1'){
				print "        <option value=\"1\" selected>on</option>\n";
			} else {
				print "        <option value=\"1\">on</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n";

			print "      <td>\n";
			print "       <select name=debugpreviewhide>\n";
			if ($debugpreviewhide eq '0'){
				print "        <option value=\"0\" selected>off</option>\n";
			} else {
				print "        <option value=\"0\">off</option>\n";
			}
			if ($debugpreviewhide eq '1'){
				print "        <option value=\"1\" selected>on</option>\n";
			} else {
				print "        <option value=\"1\">on</option>\n";
			}
			print "       </select>\n";
			print "      </td>\n";

			print "      <td>\n";
			print "       <select name=debugpreviewshow>\n";
			if ($debugpreviewshow eq '0'){
				print "        <option value=\"0\" selected>off</option>\n";
			} else {
				print "        <option value=\"0\">off</option>\n";
			}
			if ($debugpreviewshow eq '1'){
				print "        <option value=\"1\" selected>on</option>\n";
			} else {
				print "        <option value=\"1\">on</option>\n";
			}
			
			print "       </select>\n";
			print "      </td>\n";
			print "     </tr>\n";
		}

		print "     <tr>\n      <td colspan=3 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <input type=hidden name=dowhat value=debugwrite>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=fromtype value=$fromtype>\n";
		print "    </tbody>\n   </table>\n";
	}

	sub debugwrite {
		$writenew="$editdebugwrite|$editdebugpreviewhide|$editdebugpreviewshow|";
		open (WRITEINFO,">$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		print (WRITEINFO $writenew);
		close (WRITEINFO);
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"4;URL=$thispage?dotype=$fromtype\">\n";
		print "     <p><a href=\"$thispage?dotype=$fromtype\">main screen</a>";
		&footer;
	}
}

sub header {
	local($e) = @_;
	print "$delay\n<html>\n<head>\n <title>EZ Editor: Media Admin</title>\n";
	print " <LINK HREF=\"/styles/adminstyle.css\" REL=\"stylesheet\" TYPE=\"text/css\" />\n";
	print "</head>\n<body topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0 OnLoad=\"document.myform.";
	if ($dowhat eq "mediabarcode") {print "neweacupc";} elsif ($dowhat eq "mediaisbn") {print "newisbn";} else {print "newtitle";}
	print ".focus();\">\n";
	print "<table width=100% height=100% border=1 align=center valign=center>\n";
	print " <tr>\n  <td height=20 colspan=3 valign=top align=center class=header>\n";
	print "   <table width=100% cellspacing=0 cellpadding=0 border=0>\n";
	print "    <tr>\n";
	if ($preview or $showhide) {
		print "     <td align=center class=header width=30%>Media Admin: write $write | preview $preview, $showhide</td>\n";
	} else {
		print "     <td align=center class=header width=35%>Media Admin: write $write</td>\n";
	}
	print "     <td align=center class=header width=35%>";
	if ($dotype ne "debug") {
		print "{ <a href=\"$thispage?dowhat=mediaadd&dotype=$dotype\">Add Item Manually</a> | <a href=\"$thispage?dowhat=mediabarcode&dotype=$dotype&addtype=eacupc\">Add Item by Barcode</a> | <a href=\"$thispage?dowhat=mediaisbn&dotype=$dotype&addtype=isbn\">Add Item by ISBN</a> }";
	}
	print "</td>\n";
	print "     <td align=center class=header width=33%>{ <a href=\"$thispage?dotype=debug&dowhat=debugview&fromtype=$dotype\">debug</a> | <a href=\"$thispage?dotype=books\">books</a> | <a href=\"$thispage?dotype=games\">games</a> | <a href=\"$thispage?dotype=music\">music</a> | <a href=\"$thispage?dotype=videos\">videos</a> }</td>\n";
	print "    </tr>\n   </table>\n  </td>\n </tr>\n\n <tr>\n <form method=get action=$thispage name=\"myform\">\n  <td align=center>";
}

sub footer {
	print "\n  </td>\n </tr>\n </form>\n</table>\n</body>\n</html>";
	exit;
}

sub error {
	local($e) = @_;
	print "$e\n";
	$foundentry=0;
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
	$today="$year.$mon.$day";

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
	$dotype=$FORM{'dotype'};
	$dowhat=$FORM{'dowhat'};
	$showline=$FORM{'showline'};
	$continue=$FORM{'continue'};
	$addtype=$FORM{'addtype'};
	## multi-use
	$newtitle=$FORM{'newtitle'};
	$oldtitle=$FORM{'oldtitle'};
	$neweacupc=$FORM{'neweacupc'};
	$oldeacupc=$FORM{'oldeacupc'};
	$newisbn=$FORM{'newisbn'};
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
	$newmedia=$FORM{'newmedia'};
	$oldmedia=$FORM{'oldmedia'};
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
