#!/usr/bin/perl

# - date/time
my($sec,$min,$hours,$day,$mon,$year)=localtime(time);
$year=$year+1900;

$dateupdated="2016.09.01";
$basedir="";
$mediaitem="$basedir/cgi-bin/media/media_";
$thispage="index.cgi";
$empty="0";

print "Content-TYPE: text/html\npragma: no-cache\n\n";
print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n";
print "<!--my media collection v$dateupdated-->\n";
print "<HTML>\n";
print "<HEAD>\n";
print " <script type=\"text/javascript\" src=\"/javascripts/gs_sortable.js\"></script>\n";
print " <script type=\"text/javascript\" src=\"/javascripts/jquery-1.5.1.min.js\"></script>\n";
print " <script type=\"text/javascript\" src=\"/javascripts/jquery.freezeheader.js\"></script>\n";
print " <script type=\"text/javascript\">\n  <!--\n";
print "  function SizedPop(dir,page,type,width,height) {\n    window.open('/cgi-bin/' + dir + '/' + page + '?dotype=' + type, dir, \n";
print "    'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=no,resizable=no,width=' + width + ',height=' + height);\n";
print "   }\n   self.name = \"main\";\n";

$query=$ENV{"QUERY_STRING"};
if ($query eq "games") {
        $mediaitem.="games.txt";
        $pagetitle="game";
        $columns=11;
        print "  var TSort_Data = new Array ('mytable', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's');\n";
} elsif ($query eq "videos") {
        $mediaitem.="videos.txt";
        $pagetitle="video";
        $columns=11;
        print "  var TSort_Data = new Array ('mytable', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's');\n";
} elsif ($query eq "music") {
        $mediaitem.="music.txt";
        $pagetitle="music";
        $columns=11;
        print "  var TSort_Data = new Array ('mytable', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's');\n";
} elsif ($query eq "books") {
        $mediaitem.="books.txt";
        $pagetitle="book";
        $columns=5;
        print "  var TSort_Data = new Array ('mytable', 's', 's', 's', 's', 's');\n";
} else {
	$empty="1";
        $pagetitle="media";
}
print "  tsRegister();\n";
print "  \$(document).ready(function(){\n";
print "    \$(\"table\").freezeHeader({ top: true, left: true });\n";
print "  });\n";
print "  //  -->\n";
print " </script>\n";

print " <TITLE>my $pagetitle collection</TITLE>\n";
print " <LINK HREF=\"/styles/helpstyle.css\" REL=\"stylesheet\" TYPE=\"text/css\" />\n";
print " <style>\n";
print "  #mytable {\n    border-collapse: collapse;\n  }\n\n";
print "  #mytable td, #my_table th {\n    border: 1px solid #ddd;\n    padding: 8px;\n    text-align:center;\n  }\n\n";
print "  #mytable td.title {\n    text-align:left;\n  }\n\n";
print "  #mytable tr:nth-child(even){background-color: #f2f2f2;}\n\n";
print "  #mytable tr:hover {background-color: #ddd;}\n\n";
print "  #mytable th {\n    padding-top: 12px;\n    padding-bottom: 12px;\n    background-color: #4CAF50;\n    color: white;\n  }\n";
print " </style>\n";

print "</HEAD>\n";
print "<BODY BGCOLOR=#ffffff>\n";

if ($empty != "1") {
  open (media,"$mediaitem") || print "error: $mediaitem";
  @in = <media>;
  close (media);

  #print "<!--@in-->";
  
  $table= "<table cellspacing=2 cellpadding=2 id=\"mytable\" class=\"data-table\">\n";
  $table.= " <colgroup>\n";
  $table.= "  <col style=\"background-color: #ddd\">\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
if ($pagetitle ne "book") {
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
  $table.= "  <col>\n";
}
  $table.= " </colgroup>\n";

  if ($pagetitle eq "game") {
    ##Video Games#|#Epic#|#Steam#|#Battle.net#|#Origin#|#uplay#|#NES#|#Wii#|#PS2#|#Xbox One#|#Xbox 360#|#UPC#|||||||||||
    $table.= " <thead>\n  <tr>\n   <th>Title</th>\n   <th>Epic</th>\n   <th>Steam</th>\n   <th>Battle.net</th>\n   <th>Origin</th>\n   <th>uplay</th>\n   <th>NES</th>\n   <th>Wii</th>\n   <th>PS2</th>\n   <th>XBox One</th>\n   <th>XBox 360</th>\n   <th>UPC</th>\n  </tr>\n </thead>\n";

    $table.= " <tbody>\n";
    foreach (@in) {
      ($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$upc) = split(/\|/,$_);
      if ($title eq "#DATE#") {
	    $dataupdated=$epic;
	  } elsif ($title ne "#Video Games#") {
        $table.= "  <tr class=\"grid\">\n   <td>$title</td><td>$epic</td><td>$steam</td><td>$battlenet</td><td>$origin</td><td>$uplay</td><td>$nes</td><td>$wii</td><td>$ps2</td><td>$xboxone</td><td>$xbox360</td><td>$upc</td>\n  </tr>\n";
      }
    }
    $table.= " </tbody>\n";
  } elsif ($pagetitle eq "video") {
    ##Movie#|#Movie/TV#|#BluRay#|#DVD#|#Amazon#|#Disney Anywhere#|#Google Play#|#iTunes#|#UVVU#|#UPC#|#ISBN#||
    $table.= " <thead>\n  <tr>\n   <th>Title</th>\n   <th>Movie/TV</th>\n   <th>Blu-Ray</th>\n   <th>DVD</th>\n   <th>Amazon</th>\n   <th>Disney Anywhere</th>\n   <th>Google Play</th>\n   <th>iTunes</th>\n   <th>UVVU</th>\n   <th>UPC</th>\n   <th>ISBN</th>\n  </tr>\n </thead>\n";

    $table.= " <tbody>\n";
    foreach (@in) {
      ($title,$type,$bluray,$dvd,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$upc,$isbn) = split(/\|/,$_);
      if ($title eq "#DATE#") {
	    $dataupdated=$type;
	  } elsif ($title ne "#Movie#") {
        $table.= "  <tr class=\"grid\">\n   <td class=\"title\">$title</td><td>$type</td><td>$bluray</td><td>$dvd</td><td>$amazon</td><td>$disneyanywhere</td><td>$googleplay</td><td>$itunes</td><td>$uvvu</td><td>$upc</td><td>$isbn</td>\n  </tr>\n";
      }
    }
    $table.= " </tbody>\n";
  }  elsif ($pagetitle eq "book") {
    ##Books#|#Authors#|#UPC#|#ISBN#|#Type#|
    $table.= " <thead>\n  <tr>\n   <th>Title</th>\n   <th>Authors</th>\n   <th>UPC</th>\n   <th>ISBN</th>\n   <th>Type</th>\n  </tr>\n </thead>\n";

    $table.= " <tbody>\n";
    foreach (@in) {
      ($title,$author,$upc,$isbn,$type) = split(/\|/,$_);
      if ($title eq "#DATE#") {
	    $dataupdated=$author;
	  } elsif ($title ne "#Books#") {
        $table.= "  <tr class=\"grid\">\n   <td>$title</td><td>$author</td><td>$upc</td><td>$isbn</td><td>$type</td>\n  </tr>\n";
      }
    }
    $table.= " </tbody>\n";
  }  elsif ($pagetitle eq "music") {
    ##Title#|#Artist#|#UPC#|#CD#|#Amazon#|#DJBooth#|#Google#|#iTunes#|#ReverbNation#|#TopSpin#|#Rhapsody#|
    $table.= " <thead>\n  <tr>\n   <th>Artist &ndash; Album</th>\n   <th>UPC</th>\n   <th>CD</th>\n   <th>Amazon</th>\n   <th>DJ Booth</th>\n  <th>Google Play</th>\n  <th>Groove</th>\n  <th>iTunes</th>\n  <th>ReverbNation</th>\n  <th>TopSpin</th>\n  <th>Rhapsody</th>\n  </tr>\n </thead>\n";

    $table.= " <tbody>\n";
    foreach (@in) {
      ($title,$artist,$upc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody) = split(/\|/,$_);
      if ($title eq "#DATE#") {
	    $dataupdated=$artist;
	  } elsif ($title ne "#Music#") {
        $table.= "  <tr class=\"grid\">\n   <td>$artist  $title</td><td>$upc</td><td>$cd</td><td>$amazon</td><td>$djbooth</td><td>$googleplay</td><td>$groove</td><td>$itunes</td><td>$reverbnation</td><td>$topspin</td><td>$rhapsody</td>\n  </tr>\n";
      }
    }
    $table.= " </tbody>\n";
  }
  $table.= "</table>\n";
}

print "<div align=left>";
if ($empty != "1") {
 print "data updated: $dataupdated | ";
}
print "<a href=\"javascript:SizedPop('mediademo','media.pl','$query',1325,625);\">admin</a> | ";
print "<a href=\"$thispage?books\">books</a> | ";
print "<a href=\"$thispage?games\">games</a> | ";
print "<a href=\"$thispage?music\">music</a> | ";
print "<a href=\"$thispage?videos\">videos</a>";
print "</div>\n";

print "<br>\n";

print $table;

print "</body>\n";
print "</html>";
exit;
