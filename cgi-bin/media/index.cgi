#!/usr/bin/perl

### "GLOBAL" SETTINGS AND SCRIPT SETTINGS
#  base directory and static locations for certain parts of the site
$basedir=$ENV{'DOCUMENT_ROOT'};

##  MEDIACOLLECTION SETTINGS
#  $directory should be where the media data is stored.
$directory="media";
#  $admindirectory should be the location where media.pl is stored, in case you have it in a separate password protected folder.
$admindirectory="media";
#  $mediaitem is the general location of the media data.
$mediaitem="cgi-bin/$directory/media_";
#  $debugitem is the debug file for the media data.
$debugitem="cgi-bin/$directory/media_debug.txt";
$thispage="index.cgi";
#  $empty gets the value of 0 here, and will be tested a little later on to be sure that there is a media type.
$empty="0";
#  $userAgent gets the platform being used by the browser
$userAgent=$ENV{"HTTP_USER_AGENT"};

#  headers for the non-admin pages
$dateupdated="2017.09.18";

#  Open and process the "debug" file. On this page, the article sort is the only variable that matters.
open (debug,"$basedir/$debugitem") || &error("error: mediaitem $debugitem");
@in = <debug>;
close (debug);
for $line(@in) {
	($debugwrite,$debugpreviewhide,$debugpreviewshow,$debugthesort,$debugmobile) = split(/\|/,$line);
}

#  Get the query from the URI address
$query=$ENV{"QUERY_STRING"};
#  if $query equals games, set $mediaitem to look at the games.txt file, set the page title to "game"
if ($query eq "games") {
	$mediaitem.="games.txt";
	$pagetitle="game";
#  if $query equals videos, set $mediaitem to look at the videos.txt file, set the page title to "video"
} elsif ($query eq "videos") {
	$mediaitem.="videos.txt";
	$pagetitle="video";
#  if $query equals music, set $mediaitem to look at the music.txt file, set the page title to "music"
} elsif ($query eq "music") {
	$mediaitem.="music.txt";
	$pagetitle="music";
#  if $query equals books, set $mediaitem to look at the books.txt file, set the page title to "book"
} elsif ($query eq "books") {
	$mediaitem.="books.txt";
	$pagetitle="book";
#  if none of the above are true, then the $query is either incorrect or missing, so now $empty is set to 1, and page title
#  is set to "media." this also prevents the data table from being created.
} else {
	$empty="1";
	$pagetitle="media";
}

if ($empty != "1") {
	open (media,"$basedir/$mediaitem") || print "error: $mediaitem";
	@in = <media>;
	close (media);
	$columns=0;

	if ($pagetitle eq "game") {
		foreach (@in) {
			($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$upc,$purchasedate) = split(/\|/,$_);
			if (substr($title,0,6) eq "#DATE#") {
				$dataupdated=substr($title,(length($title)-10),10);
				$showhide_epic=$epic;
				$showhide_steam=$steam;
				$showhide_battlenet=$battlenet;
				$showhide_origin=$origin;
				$showhide_uplay=$uplay;
				$showhide_nes=$nes;
				$showhide_wii=$wii;
				$showhide_ps2=$ps2;
				$showhide_xboxone=$xboxone;
				$showhide_xbox360=$xbox360;
				$showhide_upc=$upc;
				$showhide_purchasedate=$purchasedate;

				$table.= "   <th>Title</th>\n";$columns++;
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="   <th>UPC</th>\n";$columns++;}
				if (($showhide_battlenet eq "show") || ($showhide_battlenet eq "#")) {$table.="   <th>Battle.net</th>\n";$columns++;}
				if (($showhide_epic eq "show") || ($showhide_epic eq "#")) {$table.="   <th>Epic</th>\n";$columns++;}
				if (($showhide_nes eq "show") || ($showhide_nes eq "#")) {$table.="   <th>NES</th>\n";$columns++;}
				if (($showhide_origin eq "show") || ($showhide_origin eq "#")) {$table.="   <th>Origin</th>\n";$columns++;}
				if (($showhide_ps2 eq "show") || ($showhide_ps2 eq "#")) {$table.="   <th>PS2</th>\n";$columns++;}
				if (($showhide_steam eq "show") || ($showhide_steam eq "#")) {$table.="   <th>Steam</th>\n";$columns++;}
				if (($showhide_uplay eq "show") || ($showhide_uplay eq "#")) {$table.="   <th>uPlay</th>\n";$columns++;}
				if (($showhide_xbox360 eq "show") || ($showhide_xbox360 eq "#")) {$table.="   <th>XBox360</th>\n";$columns++;}
				if (($showhide_xboxone eq "show") || ($showhide_xboxone eq "#")) {$table.="   <th>XBoxOne</th>\n";$columns++;}
				if (($showhide_wii eq "show") || ($showhide_wii eq "#")) {$table.="   <th>Wii</th>\n";$columns++;}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="   <th>Purchase<br>Date</th>\n";$columns++;}
				$table.=" </thead>\n <tbody>\n";
				$mobiletable.= "   <thead>\n  <tr>\n   <th>Title</th>\n  </tr>\n </thead>\n <tbody>\n";
			} else {
				$titledisplay=$title;
				$titleinformation="";
				if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
					$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
				}
				if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
					$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
				}
				$titledisplay =~ s/\'\'/\"/g;
				$titledisplay =~ s/\(plus\)/+/g;
				$titledisplay =~ s/\(pound\)/#/g;
				$titledisplay =~ s/\(amp\)/\&/g;
				if ($debugmobile == "1") {
					if ($battlenet eq "X") {$titleinformation.="Battle.net<br>";}
					if ($epic eq "X") {$titleinformation.="Epic<br>";}
					if ($nes eq "X") {$titleinformation.="Nintendo Entertainment System<br>";}
					if ($origin eq "X") {$titleinformation.="Origin<br>";}
					if ($ps2 eq "X") {$titleinformation.="Sony PlayStation 2<br>";}
					if ($steam eq "X") {$titleinformation.="Steam<br>";}
					if ($uplay eq "X") {$titleinformation.="uPlay<br>";}
					if ($wii eq "X") {$titleinformation.="Nintendo Wii<br>";}
					if ($xbox360 eq "X, DL") {$titleinformation.="XBox360 Download<br>";} elsif ($xbox360 eq "X, DK") {$titleinformation.="XBox360 Disk<br>";}
					if ($xboxone eq "X, DL") {$titleinformation.="XBoxOne Download";}  elsif ($xboxone eq "X, DK") {$titleinformation.="XBoxOne Disk";} elsif ($xboxone eq "X, BC") {$titleinformation.="XBoxOne Backwards Compatibility";}
				}

				$table.= "  <tr class=\"grid\">\n   <td><div>$titledisplay</div></td>";
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="<td>$upc</td>";}
				if (($showhide_battlenet eq "show") || ($showhide_battlenet eq "#")) {$table.="<td>$battlenet</td>";}
				if (($showhide_epic eq "show") || ($showhide_epic eq "#")) {$table.="<td>$epic</td>";}
				if (($showhide_nes eq "show") || ($showhide_nes eq "#")) {$table.="<td>$nes</td>";}
				if (($showhide_origin eq "show") || ($showhide_origin eq "#")) {$table.="<td>$origin</td>";}
				if (($showhide_ps2 eq "show") || ($showhide_ps2 eq "#")) {$table.="<td>$ps2</td>";}
				if (($showhide_steam eq "show") || ($showhide_steam eq "#")) {$table.="<td>$steam</td>";}
				if (($showhide_uplay eq "show") || ($showhide_uplay eq "#")) {$table.="<td>$uplay</td>";}
				if (($showhide_xbox360 eq "show") || ($showhide_xbox360 eq "#")) {$table.="<td>$xbox360</td>";}
				if (($showhide_xboxone eq "show") || ($showhide_xboxone eq "#")) {$table.="<td>$xboxone</td>";}
				if (($showhide_wii eq "show") || ($showhide_wii eq "#")) {$table.="<td>$wii</td>";}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="<td>$purchasedate</td>";}
				$table.= "\n  </tr>\n";
				if ($debugmobile == "1") {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$titledisplay</b><br>$titleinformation</div></td>\n  </tr>\n";
				} else {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$titledisplay</b></div></td>\n  </tr>\n";
				}				
				
			}
		}
		$table.= " </tbody>\n";
		$mobiletable.= " </tbody>\n";
	} elsif ($pagetitle eq "video") {
		foreach (@in) {
			($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$upc,$isbn,$microsoft,$year,$purchasedate) = split(/\|/,$_);
			if (substr($title,0,6) eq "#DATE#") {
				$dataupdated=substr($title,(length($title)-10),10);
				$showhide_type=$type;
				$showhide_media=$media;
				$showhide_amazon=$amazon;
				$showhide_disneyanywhere=$disneyanywhere;
				$showhide_googleplay=$googleplay;
				$showhide_itunes=$itunes;
				$showhide_uvvu=$uvvu;
				$showhide_isbn=$isbn;
				$showhide_microsoft=$microsoft;
				$showhide_upc=$upc;
				$showhide_purchasedate=$purchasedate;

				$table.= "   <th>Title (Year)</th>\n";$columns++;
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="   <th>UPC</th>\n";$columns++;}
				if (($showhide_isbn eq "show") || ($showhide_isbn eq "#")) {$table.="   <th>ISBN</th>\n";$columns++;}
				if (($showhide_media eq "show") || ($showhide_media eq "#")) {$table.="   <th>Movie/TV</th>\n";$columns++;}
				if (($showhide_type eq "show") || ($showhide_type eq "#")) {$table.="   <th>Physical<br>Media</th>\n";$columns++;}
				if (($showhide_amazon eq "show") || ($showhide_amazon eq "#")) {$table.="   <th>Amazon</th>\n";$columns++;}
				if (($showhide_disneyanywhere eq "show") || ($showhide_disneyanywhere eq "#")) {$table.="   <th>Disney<br>Anywhere</th>\n";$columns++;}
				if (($showhide_googleplay eq "show") || ($showhide_googleplay eq "#")) {$table.="   <th>Google<br>Play</th>\n";$columns++;}
				if (($showhide_itunes eq "show") || ($showhide_itunes eq "#")) {$table.="   <th>iTunes</th>\n";$columns++;}
				if (($showhide_microsoft eq "show") || ($showhide_microsoft eq "#")) {$table.="   <th>Microsoft</th>\n";$columns++;}
				if (($showhide_uvvu eq "show") || ($showhide_uvvu eq "#")) {$table.="   <th>UVVU</th>";$columns++;}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="   <th>Purchase<br>Date</th>\n";$columns++;}
				$table.="\n  </tr>\n </thead>\n <tbody>\n";
				$mobiletable.= " <thead>\n  <tr>\n   <th>Title (Year)</th>\n  </tr>\n </thead>\n <tbody>\n";
			} else {
				$mediadisplay="";
				if ($media eq "bluray") {
					$mediadisplay="BluRay";
				} elsif ($media eq "dvd") {
					$mediadisplay="DVD";
				} elsif ($media eq "diskcombo") {
					$mediadisplay="BluRay/DVD";
				} elsif (($mediadisplay eq "") && ($amazon eq "X") || ($disneyanywhere eq "X") || ($googleplay eq "X") || ($itunes eq "X") || ($microsoft eq "X") || ($uvvu eq "X")) {
					$mediadisplay="Streaming";
				}

				$titledisplay=$title;
				if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
					$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
				}
				if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
					$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
				}
				$titledisplay =~ s/\'\'/\"/g;
				$titledisplay =~ s/\(plus\)/+/g;
				$titledisplay =~ s/\(pound\)/#/g;
				$titledisplay =~ s/\(amp\)/\&/g;

				if ($year) {$titledisplay.=" ($year)";}

				$titleinformation="$mediadisplay, $type";
				if ($debugmobile == "1") {
					$titleinformation.="<br>";
					if ($amazon eq "X") {$titleinformation.="Amazon Video<br>";}
					if ($itunes eq "X") {$titleinformation.="Apple iTunes<br>";}
					if ($disneyanywhere eq "X") {$titleinformation.="Disney Anywhere<br>";}
					if ($googleplay eq "X") {$titleinformation.="Google Play Video<br>";}
					if ($microsoft eq "X") {$titleinformation.="Microsoft Movies & TV<br>";}
					if ($uvvu eq "X") {$titleinformation.="UltraViolet<br>";}
				}

				$table.= "  <tr class=\"grid\">\n   <td class=\"title\"><div><b>$titledisplay</b></div></td>";
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="<td>$upc</td>";}
				if (($showhide_isbn eq "show") || ($showhide_isbn eq "#")) {$table.="<td>$isbn</td>";}
				if (($showhide_type eq "show") || ($showhide_type eq "#")) {$table.="<td>$type</td>";}
				if (($showhide_media eq "show") || ($showhide_media eq "#")) {$table.="<td>$mediadisplay</td>";}
				if (($showhide_amazon eq "show") || ($showhide_amazon eq "#")) {$table.="<td>$amazon</td>";}
				if (($showhide_disneyanywhere eq "show") || ($showhide_disneyanywhere eq "#")) {$table.="<td>$disneyanywhere</td>";}
				if (($showhide_googleplay eq "show") || ($showhide_googleplay eq "#")) {$table.="<td>$googleplay</td>";}
				if (($showhide_itunes eq "show") || ($showhide_itunes eq "#")) {$table.="<td>$itunes</td>";}
				if (($showhide_microsoft eq "show") || ($showhide_microsoft eq "#")) {$table.="<td>$microsoft</td>";}
				if (($showhide_uvvu eq "show") || ($showhide_uvvu eq "#")) {$table.="<td>$uvvu</td>";}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="<td>$purchasedate</td>";}
				$table.="\n  </tr>\n";
				if ($debugmobile == "1") {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$titledisplay</b><br>$titleinformation</div></td>\n  </tr>\n";
				} else {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$titledisplay</b></div></td>\n  </tr>\n";
				}
			}
		}
		$table.= " </tbody>\n";
		$mobiletable.= " </tbody>\n";
	}  elsif ($pagetitle eq "book") {
		foreach (@in) {
			($title,$author,$upc,$isbn,$type,$purchasedate) = split(/\|/,$_);
			if (substr($title,0,6) eq "#DATE#") {
				$dataupdated=substr($title,(length($title)-10),10);
				$showhide_type=$type;
				$showhide_isbn=$isbn;
				$showhide_upc=$upc;
				$showhide_purchasedate=$purchasedate;

				$table.= "   <th>Title</th>\n   <th>Author(s)</th>\n";
				$columns=$columns+2;
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="   <th>UPC</th>\n";$columns++;}
				if (($showhide_isbn eq "show") || ($showhide_isbn eq "#")) {$table.="   <th>ISBN</th>\n";$columns++;}
				if (($showhide_type eq "show") || ($showhide_type eq "#")) {$table.="   <th>Type</th>\n";$columns++;}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="   <th>Purchase<br>Date</th>\n";$columns++;}
				$table.= "</tr>\n </thead>\n <tbody>\n";
				$mobiletable.= "   <th>Title &ndash; Author(s)</th>\n  </tr>\n </thead>\n <tbody>\n";
			} else {
				$titledisplay=$title;
				if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
					$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
				}
				if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
					$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
				}
				$titledisplay =~ s/\'\'/\"/g;
				$titledisplay =~ s/\(plus\)/+/g;
				$titledisplay =~ s/\(pound\)/#/g;
				$titledisplay =~ s/\(amp\)/\&/g;
				$authordisplay=$author;
				$authordisplay =~ s/\'\'/\"/g;
				$authordisplay =~ s/\(plus\)/+/g;
				$authordisplay =~ s/\(pound\)/#/g;
				$authordisplay =~ s/\(amp\)/\&/g;
				if (($author) && $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {$titledisplay.=" &ndash; $authordisplay";}

				$titleinformation="";
				if ($debugmobile == "1") {
					if ($type eq "book") {$titleinformation.="Book<br>";} else {$titleinformation.="eBook<br>";}
				}
				$table.= "  <tr class=\"grid\">\n   <td><div>$titledisplay</div></td><td><div>$authordisplay</div></td>";
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="<td>$upc</td>";}
				if (($showhide_isbn eq "show") || ($showhide_isbn eq "#")) {$table.="<td>$isbn</td>";}
				if (($showhide_type eq "show") || ($showhide_type eq "#")) {$table.="<td>$type</td>";}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="<td>$purchasedate</td>";}
				$table.="\n  </tr>\n";
				if ($debugmobile == "1") {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$titledisplay</b><br>$titleinformation</div></td>\n  </tr>\n";
				} else {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$titledisplay</b></div></td>\n  </tr>\n";
				}
			}
		}
		$table.= " </tbody>\n";
		$mobiletable.= " </tbody>\n";
	}  elsif ($pagetitle eq "music") {
		foreach (@in) {
			($artist,$title,$upc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody,$purchasedate) = split(/\|/,$_);
			if (substr($artist,0,6) eq "#DATE#") {
				$dataupdated=substr($artist,(length($artist)-10),10);
				$showhide_cd=$cd;
				$showhide_djbooth=$djbooth;
				$showhide_amazon=$amazon;
				$showhide_groove=$groove;
				$showhide_googleplay=$googleplay;
				$showhide_itunes=$itunes;
				$showhide_reverbnation=$reverbnation;
				$showhide_topspin=$topspin;
				$showhide_rhapsody=$rhapsody;
				$showhide_upc=$upc;
				$showhide_purchasedate=$purchasedate;

				$table.= "   <th>Artist &ndash; Album</th>\n\n";
				$columns++;
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="   <th>UPC</th>\n";$columns++;}
				if (($showhide_cd eq "show") || ($showhide_cd eq "#")) {$table.="   <th>CD</th>\n";$columns++;}
				if (($showhide_amazon eq "show") || ($showhide_amazon eq "#")) {$table.="   <th>Amazon</th>\n";$columns++;}
				if (($showhide_djbooth eq "show") || ($showhide_djbooth eq "#")) {$table.="   <th>DJ Booth</th>\n";$columns++;}
				if (($showhide_googleplay eq "show") || ($showhide_googleplay eq "#")) {$table.="   <th>Google<br>Play</th>\n";$columns++;}
				if (($showhide_groove eq "show") || ($showhide_groove eq "#")) {$table.="   <th>Groove</th>\n";$columns++;}
				if (($showhide_itunes eq "show") || ($showhide_itunes eq "#")) {$table.="   <th>iTunes</th>\n";$columns++;}
				if (($showhide_reverbnation eq "show") || ($showhide_reverbnation eq "#")) {$table.="   <th>ReverbNation</th>\n";$columns++;}
				if (($showhide_rhapsody eq "show") || ($showhide_rhapsody eq "#")) {$table.="   <th>Rhapsody</th>\n";$columns++;}
				if (($showhide_topspin eq "show") || ($showhide_topspin eq "#")) {$table.="   <th>TopSpin</th>\n";$columns++;}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="   <th>Purchase<br>Date</th>\n";$columns++;}
				$table.= "  </tr>\n </thead>\n <tbody>\n";
				$mobiletable.= " <thead>\n  <tr>\n   <th>Title</th>\n  </tr>\n </thead>\n <tbody>\n";
			} else {
				$titledisplay=$title;
				if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
					$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
				}
				if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
					$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
				}
				$titledisplay =~ s/\'\'/\"/g;
				$titledisplay =~ s/\(plus\)/+/g;
				$titledisplay =~ s/\(pound\)/#/g;
				$titledisplay =~ s/\(amp\)/\&/g;
				$artistdisplay=$artist;
				$artistdisplay =~ s/\'\'/\"/g;
				$artistdisplay =~ s/\(plus\)/+/g;
				$artistdisplay =~ s/\(pound\)/#/g;
				$artistdisplay =~ s/\(amp\)/\&/g;

				$titleinformation="";
				if ($debugmobile == "1") {
					if ($amazon eq "X") {$titleinformation.="Amazon MP3<br>";}
					if ($cd eq "X") {$titleinformation="Compact Disc<br>";}
					if ($itunes eq "X") {$titleinformation.="Apple iTunes<br>";}
					if ($djbooth eq "X") {$titleinformation.="DJ Booth<br>";}
					if ($googleplay eq "X") {$titleinformation.="Google Play Music<br>";}
					if ($groove eq "X") {$titleinformation.="Microsoft Groove<br>";}
					if ($reverbnation eq "X") {$titleinformation.="ReverbNation<br>";}
					if ($rhapsody eq "X") {$titleinformation.="Rhapsody<br>";}
					if ($topspin eq "X") {$titleinformation.="TopSpin<br>";}
				}

				$table.= "  <tr class=\"grid\">\n   <td><div>$artistdisplay &ndash; $titledisplay</div></td>";
				if (($showhide_upc eq "show") || ($showhide_upc eq "#")) {$table.="<td>$upc</td>";}
				if (($showhide_cd eq "show") || ($showhide_cd eq "#")) {$table.="<td>$cd</td>";}
				if (($showhide_amazon eq "show") || ($showhide_amazon eq "#")) {$table.="<td>$amazon</td>";}
				if (($showhide_djbooth eq "show") || ($showhide_djbooth eq "#")) {$table.="<td>$djbooth</td>";}
				if (($showhide_googleplay eq "show") || ($showhide_googleplay eq "#")) {$table.="<td>$googleplay</td>";}
				if (($showhide_groove eq "show") || ($showhide_groove eq "#")) {$table.="<td>$groove</td>";}
				if (($showhide_itunes eq "show") || ($showhide_itunes eq "#")) {$table.="<td>$itunes</td>";}
				if (($showhide_reverbnation eq "show") || ($showhide_reverbnation eq "#")) {$table.="<td>$reverbnation</td>";}
				if (($showhide_rhapsody eq "show") || ($showhide_rhapsody eq "#")) {$table.="<td>$rhapsody</td>";}
				if (($showhide_topspin eq "show") || ($showhide_topspin eq "#")) {$table.="<td>$topspin</td>\n";}
				if (($showhide_purchasedate eq "show") || ($showhide_purchasedate eq "#")) {$table.="<td>$purchasedate</td>";}
				$table.="\n  </tr>\n";
				if ($debugmobile == "1") {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$artistdisplay &ndash; $titledisplay</b><br>$titleinformation</div></td>\n  </tr>\n";
				} else {
					$mobiletable.="  <tr class=\"grid\">\n   <td><div><b>$artistdisplay &ndash; $titledisplay</b></div></td>\n  </tr>\n";
				}				
			}
		}
		$table.= " </tbody>\n";
		$mobiletable.= " </tbody>\n";
	}
	$table.= "</table>\n</div>\n";
	$mobiletable.= "</table>\n</div>\n";
}

######  Set content type of the page.
print "Content-TYPE: text/html\n\n";
print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n";
print "<!--my media collection v$dateupdated-->\n";
print "<HTML>\n";
print "<HEAD>\n";
if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {
	#skip
} else {
	print " <script type=\"text/javascript\" src=\"/javascripts/gs_sortable.js\"></script>\n";
	#print " <script type=\"text/javascript\" src=\"/javascripts/jquery-1.5.1.min.js\"></script>\n";
	#print " <script type=\"text/javascript\" src=\"/javascripts/jquery.freezeheader.js\"></script>\n";
}
print " <script type=\"text/javascript\">\n  <!--\n";
print "   function SizedPop(dir,page,type,width,height) {\n    window.open('/cgi-bin/' + dir + '/' + page + '?dotype=' + type, dir,\n";
print "    'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=no,width=' + width + ',height=' + height);\n   }\n";
print "   self.name = \"main\";\n";

if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {
	#skip
} else {
	print "   var TSort_Data = new Array ('mytable'";
	$sortcolumns=0;
	while($sortcolumns < $columns){
		print ",'s'";
		$sortcolumns = $sortcolumns + 1;
	}
	print ");\n";
	print "   tsRegister();\n";
}

print "  -->\n";
print " </script>\n";

print " <TITLE>my $pagetitle collection</TITLE>\n";
print " <LINK HREF=\"/styles/helpstyle.css\" REL=\"stylesheet\" TYPE=\"text/css\" />\n";
print " <style>\n";
print "  #mytable {\n    border-collapse: collapse;\n  }\n\n";
print "  #mytable td, #my_table th {\n    border: 1px solid #ddd;\n    padding: 8px;\n    text-align:center;\n  }\n\n";
print "  #mytable tr:nth-child(even){background-color: #f2f2f2;}\n\n";
print "  #mytable tr:hover {background-color: #ccc;}\n\n";
print "  #mytable th {\n    padding-top: 12px;\n    padding-bottom: 12px;\n    background-color: #4CAF50;\n    color: white;\n  }\n";
if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {
	#skip
} else {
	print "  TD DIV {width: 250px;}";
}
print " </style>\n";

if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i) {
	print " <META NAME=\"VIEWPORT\" CONTENT=\"WIDTH=DEVICE-WIDTH\"/>\n";
}
print "</HEAD>\n";

print "<BODY BGCOLOR=#ffffff>\n";

print "<div align=center>\n<table cellspacing=10 cellpadding=10 id=\"mytable\" class=\"data-table\">\n";
if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {
	print " <colgroup>\n"; 
	$mediacolumns=0;
	while($mediacolumns < $columns){
		$mediacolumns = $mediacolumns + 1;
		print "  <col>\n";
	}
	print " </colgroup>\n";
}
print " <thead>\n  <tr>\n";

print "<div align=center>";
if ($empty != "1") {
	#print "columns: $columns | ";
	print "data updated: $dataupdated";
	if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {
		print "<br>";
	} else {
		print " | ";
	}
}
if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i || $userAgent =~ m/iPad/i ) {
	#skip
} else {
	print "<a href=\"javascript:SizedPop('$admindirectory','media.pl','$query',1350,625);\">admin</a> | ";
}
print "<a href=\"$thispage?books\">books</a> | ";
print "<a href=\"$thispage?games\">games</a> | ";
print "<a href=\"$thispage?music\">music</a> | ";
print "<a href=\"$thispage?videos\">videos</a>";
print "</div>\n";

print "<br>\n";

if ( $userAgent =~ m/iPhone/i || $userAgent =~ m/IEMobile/i) {
	print $mobiletable;
} else {
	print $table;
}

print "<br>\n<div align=center>";
print "<i>this script, <b>mediacollection</b>, is part of an open source Perl script available on <a href=\"https://github.com/rdgarfinkel/mediacollection\" target=\"_GitHub\">Github</a></i>";
print "</div>\n";

print "</body>\n";
print "</html>";
exit;
