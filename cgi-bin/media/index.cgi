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

#  headers for the non-admin pages
$dateupdated="2016.10.07";

#  Open and process the "debug" file. On this page, the article sort is the only variable that matters.
open (debug,"$basedir/$debugitem") || &error("error: mediaitem $debugitem");
@in = <debug>;
close (debug);
for $line(@in) {
	($debugwrite,$debugpreviewhide,$debugpreviewshow,$debugthesort) = split(/\|/,$line);
}

#  Set content type of the page.
print "Content-TYPE: text/html\npragma: no-cache\n\n";
print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n";
print "<!--my media collection v$dateupdated-->\n";
print "<HTML>\n";
print "<HEAD>\n";
print " <script type=\"text/javascript\" src=\"/javascripts/gs_sortable.js\"></script>\n";
#print " <script type=\"text/javascript\" src=\"/javascripts/jquery-1.5.1.min.js\"></script>\n";
#print " <script type=\"text/javascript\" src=\"/javascripts/jquery.freezeheader.js\"></script>\n";
print " <script type=\"text/javascript\">\n  <!--\n";
print "   function SizedPop(dir,page,type,width,height) {\n    window.open('/cgi-bin/' + dir + '/' + page + '?dotype=' + type, dir, \n";
print "    'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=no,resizable=no,width=' + width + ',height=' + height);\n";
print "   }\n   self.name = \"main\";\n";

#  Get the query from the URI address
$query=$ENV{"QUERY_STRING"};
#  if $query equals games, set $mediaitem to look at the games.txt file, set the page title to "game," and set columns
if ($query eq "games") {
	$mediaitem.="games.txt";
	$pagetitle="game";
	$columns=12;
#  if $query equals videos, set $mediaitem to look at the videos.txt file, set the page title to "video," and set columns
} elsif ($query eq "videos") {
	$mediaitem.="videos.txt";
	$pagetitle="video";
	$columns=11;
#  if $query equals music, set $mediaitem to look at the music.txt file, set the page title to "music," and set columns
} elsif ($query eq "music") {
	$mediaitem.="music.txt";
	$pagetitle="music";
	$columns=11;
#  if $query equals books, set $mediaitem to look at the books.txt file, set the page title to "book," and set columns
} elsif ($query eq "books") {
	$mediaitem.="books.txt";
	$pagetitle="book";
	$columns=5;
#  if none of the above are true, then the $query is either incorrect or missing, so now $empty is set to 1, and page title
#  is set to "media." this also prevents the data table from being created.
} else {
	$empty="1";
	$pagetitle="media";
}

print "   var TSort_Data = new Array ('mytable'";
$sortcolumns=0;
while($sortcolumns < $columns){
	print ",'s'";
	$sortcolumns = $sortcolumns + 1;
}
print ");\n";

print "   tsRegister();\n";
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
print " </style>\n";

print "</HEAD>\n";
print "<BODY BGCOLOR=#ffffff>\n";


if ($empty != "1") {
	open (media,"$basedir/$mediaitem") || print "error: $mediaitem";
	@in = <media>;
	close (media);

	#print "<!--@in-->";

	$table= "<div align=center>\n<table cellspacing=10 cellpadding=10 id=\"mytable\" class=\"data-table\">\n";
	$table.= " <colgroup>\n";
	$table.= "  <col style=\"background-color: #ddd\">\n";
  
	$mediacolumns=1;
	while($mediacolumns < $columns){
		$mediacolumns = $mediacolumns + 1;
		$table.= "  <col>\n";
	}
	$table.= " </colgroup>\n";

	if ($pagetitle eq "game") {
		##Video Games#|#Epic#|#Steam#|#Battle.net#|#Origin#|#uplay#|#NES#|#Wii#|#PS2#|#Xbox One#|#Xbox 360#|#UPC#|||||||||||
		$table.= " <thead>\n  <tr>\n   <th>Title</th>\n   <th>UPC</th>\n   <th>Battle.net</th>\n   <th>Epic</th>\n   <th>NES</th>\n   <th>Origin</th>\n   <th>PS2</th>\n   <th>Steam</th>\n   <th>Uplay</th>\n   <th>XBox 360</th>\n   <th>XBox One</th>\n   <th>Wii</th>\n  </tr>\n </thead>\n";

		$table.= " <tbody>\n";
		foreach (@in) {
			($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$upc) = split(/\|/,$_);
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
			if ($title eq "#DATE#") {
				$dataupdated=$epic;
			} else {
				$table.= "  <tr class=\"grid\">\n   <td><div>$titledisplay</div></td><td>$upc</td><td>$battlenet</td><td>$epic</td><td>$nes</td><td>$origin</td><td>$ps2</td><td>$steam</td><td>$uplay</td><td>$xbox360</td><td>$xboxone</td><td>$wii</td>\n  </tr>\n";
			}
		}
		$table.= " </tbody>\n";
	} elsif ($pagetitle eq "video") {
		##Movie#|#Movie/TV#|#Media#|#Amazon#|#Disney Anywhere#|#Google Play#|#iTunes#|#UVVU#|#UPC#|#ISBN#|#Microsoft#|
		$table.= " <thead>\n  <tr>\n   <th>Title (Year)</th>\n   <th>UPC</th>\n   <th>ISBN</th>\n   <th>Movie/TV</th>\n   <th>Physical<br>Media</th>\n   <th>Amazon</th>\n   <th>Disney<br>Anywhere</th>\n   <th>Google<br>Play</th>\n   <th>iTunes</th>\n   <th>Microsoft</th>\n<th>UVVU</th>\n  </tr>\n </thead>\n";

		$table.= " <tbody>\n";
		foreach (@in) {
			($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$upc,$isbn,$microsoft,$year) = split(/\|/,$_);
			$mediadisplay="";
			if ($media eq "bluray") {
				$mediadisplay="BluRay";
			} elsif ($media eq "dvd") {
				$mediadisplay="DVD";
			} elsif ($media eq "diskcombo") {
				$mediadisplay="BluRay/DVD";
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
			if ($year) {
				$titledisplay.=" ($year)";
			}
			if ($title eq "#DATE#") {
				$dataupdated=$type;
			} else {
				$table.= "  <tr class=\"grid\">\n   <td class=\"title\"><div>$titledisplay</div></td><td>$upc</td><td>$isbn</td><td>$type</td><td>$mediadisplay</td><td>$amazon</td><td>$disneyanywhere</td><td>$googleplay</td><td>$itunes</td><td>$microsoft</td><td>$uvvu</td>\n  </tr>\n";
			}
		}
		$table.= " </tbody>\n";
	}  elsif ($pagetitle eq "book") {
		##Books#|#Authors#|#UPC#|#ISBN#|#Type#|
		$table.= " <thead>\n  <tr>\n   <th>Title</th>\n   <th>Authors</th>\n   <th>UPC</th>\n   <th>ISBN</th>\n   <th>Type</th>\n  </tr>\n </thead>\n";

		$table.= " <tbody>\n";
		foreach (@in) {
			($title,$author,$upc,$isbn,$type) = split(/\|/,$_);
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
			if ($title eq "#DATE#") {
				$dataupdated=$author;
			} else {
				$table.= "  <tr class=\"grid\">\n   <td><div>$titledisplay</div></td><td><div>$authordisplay</div></td><td>$upc</td><td>$isbn</td><td>$type</td>\n  </tr>\n";
			}
		}
		$table.= " </tbody>\n";
	}  elsif ($pagetitle eq "music") {
		##Artist#|#Title#|#UPC#|#CD#|#Amazon#|#DJBooth#|#Google#|#Groove#|#iTunes#|#ReverbNation#|#TopSpin#|#Rhapsody#|
		$table.= " <thead>\n  <tr>\n   <th>Artist &ndash; Album</th>\n   <th>UPC</th>\n   <th>CD</th>\n   <th>Amazon</th>\n   <th>DJ Booth</th>\n   <th>Google Play</th>\n   <th>Groove</th>\n   <th>iTunes</th>\n   <th>ReverbNation</th>\n   <th>Rhapsody</th>\n   <th>TopSpin</th>\n  </tr>\n </thead>\n";

		$table.= " <tbody>\n";
		foreach (@in) {
			($artist,$title,$upc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody) = split(/\|/,$_);
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
			if ($artist eq "#DATE#") {
				$dataupdated=$title;
			} else {
				$table.= "  <tr class=\"grid\">\n   <td><div>$artistdisplay &ndash; $titledisplay</div></td><td>$upc</td><td>$cd</td><td>$amazon</td><td>$djbooth</td><td>$googleplay</td><td>$groove</td><td>$itunes</td><td>$reverbnation</td><td>$rhapsody</td><td>$topspin</td>\n  </tr>\n";
			}
		}
		$table.= " </tbody>\n";
	}
	$table.= "</table>\n</div>\n";
}

print "<div align=center>";
if ($empty != "1") {
 print "data updated: $dataupdated | ";
}
print "<a href=\"javascript:SizedPop('$admindirectory','media.pl','$query',1325,625);\">admin</a> | ";
print "<a href=\"$thispage?books\">books</a> | ";
print "<a href=\"$thispage?games\">games</a> | ";
print "<a href=\"$thispage?music\">music</a> | ";
print "<a href=\"$thispage?videos\">videos</a>";
print "</div>\n";

print "<br>\n";

print $table;

print "<br>\n<div align=center>";
print "<i>this script, <b>mediacollection</b>, is part of an open source Perl script available on <a href=\"https://github.com/rdgarfinkel/mediacollection\" target=\"_GitHub\">Github</a></i>";
print "</div>\n";

print "</body>\n";
print "</html>";
exit;
