#!/usr/bin/perl

### "Global" and script settings
## $basedir - Base directory and static locations for operations
$basedir="";

### MEDIA SETTINGS
## $directory - should be the folder where media.pl resides
$directory="media";
## $mediaitem - Directory where your data resides
$mediaitem="cgi-bin/$directory/media_";
## $mediacheck - Directory where the EAC/UPC/ISBN data. In my case, these are located in cgi-bin/eacupc and cgi-bin/isbn.
$mediacheck="cgi-bin";
## $thispage - "Global" link for accessing this page thru links. As of this writing, there's 33 instances of $thispage
##             throughout the script, if the name of the script changes, I/you only have to change it once. You're welcome! ;)
$thispage="media.pl";
## $debug - This is the location of the "debug" file, it sits right next to the other database files.
$debug=$mediaitem."debug.txt";


## $dateupdated - Date that the script was last updated
$dateupdated="2016.10.05";

## Calls to the 'getqueries' subroutine.
&getqueries;

### GENERATES THE ADMIN PAGES
## If $dotype exists, call the 'header' subroutine, then the 'media' subroutine.
if ($dotype) {&header; &media;}

## Since $dotype doesn't exist, call the 'header' subroutine, then stop the script with a friendly message on what to do next
else {&header;&errorfatal("missing or invalid administration page<br>select a link above");}


sub media {
	# If $dowhat equals 'mediaedit', go to the 'mediaedit' subroutine
	if ($dowhat eq "mediaedit") {&mediaedit;}

	# If $dowhat equals 'mediaadd', go to the 'mediaedit' subroutine
	elsif ($dowhat eq "mediaadd") {&mediaedit;}

	# If $dowhat equals 'mediabarcode', go to the 'mediaaddid' subroutine
	elsif ($dowhat eq "mediabarcode") {&mediaaddid;}

	# If $dowhat equals 'mediaisbn', go to the 'mediaaddid' subroutine
	elsif ($dowhat eq "mediaisbn") {&mediaaddid;}

	# If $dowhat equals 'mediacheck', go to the 'mediacheck' subroutine
	elsif ($dowhat eq "mediacheck") {&mediacheck;}

	# If $dowhat equals 'mediawrite', go to the 'mediawrite' subroutine
	elsif ($dowhat eq "mediawrite") {&mediawrite;}

	# If $dowhat equals 'mediadelete', go to the 'mediadelete' subroutine
	elsif ($dowhat eq "mediadelete") {&mediadelete;}

	# If $dowhat equals 'debugview', go to the 'debugview' subroutine
	elsif ($dowhat eq "debugview") {&debugview;}

	# If $dowhat equals 'debugedit', go to the 'debugedit' subroutine
	elsif ($dowhat eq "debugedit") {&debugedit;}

	# If $dowhat equals 'debugwrite', go to the 'debugwrite' subroutine
	elsif ($dowhat eq "debugwrite") {&debugwrite;}

	# Since $dowhat doesn't match anything above, generate the database table
	else {&mediamain;}


	# mediamain is the data display table
	sub mediamain {
		# Read the entry for $mediaitem. $mediaitem is established within the 'getqueries' subroutine.
		open (media,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@in = <media>;
		close (media);

		# Begin table
		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";

		# $count_title is a 'global' variable for each media type, so that we can get a total number count of individual media types.
		# It's outside of the media type sections because it cuts down on repetition, since it would appear four times, once per type. :)
		$count_title=0;

		# If $dotype equals books...
		if ($dotype eq 'books'){
			# Set variables below to 0
			$count_ebook=0;
			$count_book=0;

			# Generate table headers
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>Author(s)</th>\n     <th>EAC/UPC</th>\n     <th>ISBN</th>\n     <th>Type</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read mediaitem line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($title,$author,$eacupc,$isbn,$type) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if ($title ne "#DATE#") {
					# Increment counters by 1
					$count_title=$count_title+1;
					if ($type eq "ebook") {
						$count_ebook=$count_ebook+1;
					} else {
						$count_book=$count_book+1;
					}

					# The next few lines swap double single quotation marks for a single double quotation mark, (plus) for a plus symbol, (pound) for the pound symbol, but keeps $title as is to not break the editing ability
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					$titledisplay =~ s/\(plus\)/+/g;
					$titledisplay =~ s/\(pound\)/#/g;
					$authordisplay=$author;
					$authordisplay =~ s/\'\'/\"/g;

					# If $debugthesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $debugthesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$titledisplay</a></div></td>\n     <td><div>$authordisplay</div></td>\n     <td>$eacupc</td>\n     <td>$isbn</td>\n     <td>$type</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=$author;
				}
			}

			# End of the table body
			print "    </tbody>\n";

			# $tablestats will display the details that have been generated from the above code at a later time
			$tablestats="<b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>books $count_book || ebooks $count_ebook";
		}
		# If $dotype equals games...
		elsif ($dotype eq 'games'){
			# Set variables below to 0
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

			# Generate table headers
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>EAC/UPC</th>\n     <th>Battle.net</th>\n     <th>Epic</th>\n     <th>NES</th>\n     <th>Origin</th>\n     <th>PS2</th>\n     <th>Steam</th>\n     <th>Uplay</th>\n     <th>XBox 360</th>\n     <th>XBox One</th>\n     <th>Wii</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read mediaitem line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if ($title ne "#DATE#") {
					# Increment counters by 1
					$count_title=$count_title+1;
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

					# The next few lines swap double single quotation marks for a single double quotation mark, (plus) for a plus symbol, (pound) for the pound symbol, but keeps $title as is to not break the editing ability
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					$titledisplay =~ s/\(plus\)/+/g;
					$titledisplay =~ s/\(pound\)/#/g;

					# If $debugthesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $debugthesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$battlenet</td>\n     <td>$epic</td>\n     <td>$nes</td>\n     <td>$origin</td>\n     <td>$ps2</td>\n     <td>$steam</td>\n     <td>$uplay</td>\n     <td>$xbox360</td>\n     <td>$xboxone</td>\n     <td>$wii</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=$epic;
				}
			}

			# End of the table body
			print "    </tbody>\n";

			# $tablestats will display the details that have been generated from the above code at a later time
			$tablestats="<b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>Battle.net $count_battlenet || Epic $count_epic || NES $count_nes || Origin $count_origin || PS2 $count_ps2 || Steam $count_steam || uPlay $count_uplay || Wii $count_wii || XBox 360 $xbox360total || XBox One $xboxonetotal<br>XBox One backwards compatible $count_xboxonebc || XBox One disk $count_xboxonedk ||  XBox One download $count_xboxonedl || XBox 360 disk $count_xbox360dk || XBox 360 download $count_xbox360dl";
		}
		# If $dotype equals videos...
		elsif ($dotype eq 'videos'){
			# Set variables below to 0
			$count_tv=0;
			$count_movie=0;
			$count_bluray=0;
			$count_dvd=0;
			$count_amazon=0;
			$count_disneyanywhere=0;
			$count_microsoft=0;
			$count_googleplay=0;
			$count_itunes=0;
			$count_uvvu=0;

			# Generate table headers
			print "    <thead>\n     <th>#</th>\n     <th>Title (Year)</th>\n     <th>EAC/UPC</th>\n     <th>ISBN</th>\n     <th>Type</th>\n     <th>Physical<br>Media</th>\n     <th>Amazon</th>\n     <th>Disney<br>Anywhere</th>\n     <th>Google<br>Play</th>\n     <th>iTunes</th>\n     <th>Microsoft</th>\n     <th>UVVU</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read mediaitem line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn,$microsoft,$year) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if ($title ne "#DATE#") {
					# $mediadisplay is set to empty text here because once it was set, it would keep that text until another change throwing off the media type count
					$mediadisplay="";

					# The code below is a breakout of physical media types.
					#   If media is bluray, increment count for bluray by 1, and make display text say, "BluRay"
					#   If media is dvd, increment count for dvd by 1, and make display text say, "DVD"
					#   If media is diskcombo, increment count for bluray and dvd by 1, and make display text say, "BluRay/DVD"
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

					# The code below is a breakout of TV and Movie media types.
					if ($type eq "TV") {
						$count_tv=$count_tv+1;
					} else {
						$count_movie=$count_movie+1;
					}

					# Increment counters by 1
					$count_title=$count_title+1;
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
					if ($microsoft eq "X") {
						$count_microsoft=$count_microsoft+1;
					}
					if ($uvvu eq "X") {
						$count_uvvu=$count_uvvu+1;
					}

					# The next few lines swap double single quotation marks for a single double quotation mark, (plus) for a plus symbol, (pound) for the pound symbol, but keeps $title as is to not break the editing ability
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					$titledisplay =~ s/\(plus\)/+/g;
					$titledisplay =~ s/\(pound\)/#/g;

					# If $debugthesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $debugthesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# If $year exists, add the movie's year to the title
					if ($year) {
						$titledisplay.=" ($year)";
					}
					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$isbn</td>\n     <td>$type</td>\n     <td>$mediadisplay</td>\n     <td>$amazon</td>\n     <td>$disneyanywhere</td>\n     <td>$googleplay</td>\n     <td>$itunes</td>\n     <td>$microsoft</td>\n     <td>$uvvu</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=$type;
				}
			}

			# End of the table body
			print "    </tbody>\n";

			# $tablestats will display the details that have been generated from the above code at a later time
			$tablestats="<b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>Movies $count_movie || TV $count_tv || BluRay $count_bluray || DVDs $count_dvd || Amazon Video $count_amazon || Disney Anywhere $count_disneyanywhere || Google Play $count_googleplay || iTunes $count_itunes || Microsoft $count_microsoft || UVVU $count_uvvu";
		}
		# If $dotype equals music...
		elsif ($dotype eq 'music'){
			# Set variables below to '0'
			$count_cd=0;
			$count_amazon=0;
			$count_djbooth=0;
			$count_googleplay=0;
			$count_groove=0;
			$count_itunes=0;
			$count_reverbnation=0;
			$count_topspin=0;
			$count_rhapsody=0;

			# Generate table headers
			print "    <thead>\n     <th>#</th>\n     <th>Artist &ndash; Title</th>\n     <th>EAC/UPC</th>\n     <th>CD</th>\n     <th>Amazon</th>\n     <th>DJ Booth</th>\n     <th>Google<br>Play</th>\n     <th>Groove</th>\n     <th>iTunes</th>\n     <th>ReverbNation</th>\n     <th>Rhapsody</th>\n     <th>TopSpin</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read mediaitem line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($artist,$title,$eacupc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if ($artist ne "#DATE#") {
					# Increment counters by 1
					$count_title=$count_title+1;
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

					# The next four lines swap double single quotation marks to a single double quotation mark, but keeps $title/$artist as is to not break the editing ability
					$titledisplay=$title;
					$titledisplay =~ s/\'\'/\"/g;
					$titledisplay =~ s/\(plus\)/+/g;
					$titledisplay =~ s/\(pound\)/#/g;
					$artistdisplay=$artist;
					$artistdisplay =~ s/\'\'/\"/g;

					# If $debugthesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($debugthesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $debugthesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($debugthesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"$thispage?dotype=$dotype&dowhat=mediaedit&showline=$line\">$artistdisplay &ndash; $titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$cd</td>\n     <td>$amazon</td>\n     <td>$djbooth</td>\n     <td>$googleplay</td>\n     <td>$groove</td>\n     <td>$itunes</td>\n     <td>$reverbnation</td>\n     <td>$rhapsody</td>\n     <td>$topspin</td>\n     <td><a href=\"$thispage?dotype=$dotype&dowhat=mediadelete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=$title;
				}
			}

			# End of the table body
			print "    </tbody>\n";

			# $tablestats will display the details that have been generated from the above code at a later time
			$tablestats="<b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>\n   CD $count_cd || Amazon $count_amazon || DJ Booth $count_djbooth || Google Play $count_googleplay || Groove $count_groove || iTunes $count_itunes || ReverbNation $count_reverbnation || TopSpin $count_topspin || Rhapsody $count_rhapsody";
		}

		# If $dotype is not equal to "debug" show the add item links 
		if ($dotype ne "debug") {
			$tablestats.="<br>\n   <br>\n   <a href=\"$thispage?dowhat=mediaadd&dotype=$dotype\">Add Item Manually</a> | <a href=\"$thispage?dowhat=mediabarcode&dotype=$dotype&addtype=eacupc\">Add Item by Barcode</a> | <a href=\"$thispage?dowhat=mediaisbn&dotype=$dotype&addtype=isbn\">Add Item by ISBN</a>";
		}

		# End table
		print "   </table>";

		# Generate the footer
		&footer;
	}


	# mediaedit is where media entries are edited
	sub mediaedit{
		# Begin table
		print "\n   <table cellspacing=2 cellpadding=2>\n";

		# If $showline exists, swap...
		if ($showline) {
			$showline =~ tr/+/ /;                                                  # Swaps plus signs for spaces
			$showline =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters
		}

		#### The next 600 or so lines are all constructed the same as the next section below (books).
		#### Therefore, I'm only providing text descriptions for the "books" type, since the structure of the rest is very similar.

		# If $dotype equals "books"...
		if ($dotype eq 'books'){
			# If $dowhat equals "mediaadd"...
			if ($dowhat eq "mediaadd") {
				# This part is primarily for the addition of media based on EAC/UPC/ISBN codes. This essentially passes the information from
				# the "Add Item by EAC/UPC/ISBN" section to this part, whether information is found or not, and displays them in the correct
				# fields for further editing by the user for the various media types or services.
				$author=$newauthor;
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
				$type=$newtype;
			}
			# $dowhat doesn't equal "mediaadd", so the user has to be editing an already existing entry
			else {
				# Split each entry with the character '|'
				($title,$author,$eacupc,$isbn,$type)=split(/\|/,$showline);
			}

			# Generate the necessary text input fields for adding/editing entries
			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\" onkeyup=\"this.value=this.value.replace(/['+']/g,'(plus)');\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Author:</th>\n      <td><input type=text name=newauthor value=\"$author\" onkeyup=\"this.value=this.value.replace(/['+']/g,'(plus)');\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td>\n       <input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";

			# Generate the dropdown menu for book type.
			print "     <tr>\n      <th align=right>Type:</th>\n      <td>\n";
			print "       <select name=newtype>\n";
			if ($type eq ''){
				# If $type has no value, have this option selected
				print "        <option value=\"\" selected></option>\n";
			} else {
				# If $type has no value, don't have this option selected
				print "        <option value=\"\"></option>\n";
			}

			if ($type eq 'book'){
				# If $type is 'book', have this option selected
				print "        <option value=\"book\" selected>book</option>\n";
			} else {
				# If $type is not 'book', don't have this option selected
				print "        <option value=\"book\">book</option>\n";
			}

			if ($type eq 'ebook'){
				# If $type is 'ebook', have this option selected
				print "        <option value=\"ebook\" selected>ebook</option>\n";
			} else {
				# If $type is not 'ebook', don't have this option selected
				print "        <option value=\"ebook\">ebook</option>\n";
			}

			print "       </select>\n";
			print "      </td>\n     </tr>\n";
		} elsif ($dotype eq 'games'){
			if ($dowhat eq "mediaadd") {
				$title=$newtitle;
				$eacupc=$neweacupc;
			} else {
				($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\" onkeyup=\"this.value=this.value.replace(/['+']/g,'(plus)');\"></td>\n     </tr>\n";
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
				($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn,$microsoft,$year)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\" onkeyup=\"this.value=this.value.replace(/['+']/g,'(plus)');\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Year:</th>\n      <td><input type=text name=newyear value=\"$year\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";

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

			print "     <tr>\n      <th align=right>Microsoft:</th>\n      <td>\n";
			print "       <select name=newmicrosoft>\n";
			if ($microsoft eq ''){
				print "        <option value=\"\" selected></option>\n";
			} else {
				print "        <option value=\"\"></option>\n";
			}
			if ($microsoft eq 'X'){
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

			print "     <tr>\n      <th align=right width=30%>Artist:</th>\n      <td><input type=text name=newartist value=\"$artist\" onkeyup=\"this.value=this.value.replace(/['+']/g,'(plus)');\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\" onkeyup=\"this.value=this.value.replace(/['+']/g,'(plus)');\"></td>\n     </tr>\n";
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

		#### End of 'mediaedit' breakout, resuming text descriptions

		# Create 'Submit' and 'Cancel' buttons for the edits.
		print "     <tr>\n      <td colspan=2 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";

		# Hidden variables for passing onto the script for the next step to add/edit entries.
		# dotype passes on the current media type to the 'mediawrite' subroutine, once the entry is submitted
		# oldtitle is actually the current title, and is how 'mediawrite' finds an already existing entry for editing the entry
		print "     <input type=hidden name=dowhat value=mediawrite>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=oldtitle value=\"$title\">\n";

		# If $continueeacupc equals "1", we'll keep continueeacupc set at 1. This will create the entry for the code once submitted.
		if ($continueeacupc eq 1) {
			print "     <input type=hidden name=continueeacupc value=1>\n";
		}

		# If $continueisbn equals "1", we'll keep continueisbn set at 1. This will create the entry for the code once submitted.
		if ($continueisbn eq 1) {
			print "     <input type=hidden name=continueisbn value=1>\n";
		}

		# If $dotype equals "music", "books", or "videos", there's a snag! The "games" media type is currently checked for existing
		# entries by only their title (I can't think of a case where there are multiple video games with the same title, if you can
		# think of a scenario where this would be a problem, file an issue on Github, and I'll adjust the code accordingly).
		if ($dotype eq 'music'){
			print "     <input type=hidden name=oldartist value=\"$artist\">\n";
		} elsif ($dotype eq 'books'){
			print "     <input type=hidden name=oldauthor value=\"$author\">\n";
		} elsif (($dotype eq 'videos') || ($dotype eq 'games')) {
			print "     <input type=hidden name=oldyear value=\"$year\">\n";
		}

		# End table
		print "    </table>";

		# Generate footer
		&footer;
	}

	sub mediadelete {
		# Open and read $mediaitem
		open (READINFO,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@infile = <READINFO>;
		close (READINFO);
		@infile=sort(@infile);

		# If $showline exists, swap...
		if ($showline) {
			$showline =~ tr/+/ /;                                                  # Swaps plus signs for spaces
			$showline =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters
		}

		# For 'books', 'games', and 'music', the database was setup ideally with the first two entries in the line being the identifiers
		# for the entries. The year variable was added late in the game for 'movies', so have to work around it using this.
		if ($dotype eq "videos") {
			($thisentry1,$null,$null,$null,$null,$null,$null,$null,$null,$null,$null,$thisentry2)=split(/\|/,$showline);
		} else {
			($thisentry1,$thisentry2) = split(/\|/,$showline);
		}

		# This is a preventative measure to verify that you actually want to delete an entry, in case it was an accidental click/tap.
		# If $continue does not equal "Yes"...
		if ($continue ne 'Yes') {
			print "\n   <P>Continuing this action will remove the entry for<br><br><b>$thisentry1";
			# If $dotype equals "music" or "books"...
			if ($dotype eq "music" || $dotype eq "books") {
				print " - $thisentry2";
			}
			# If $dotype equals "videos"
			elsif ($dotype eq "videos") {
				if ($thisentry2) {
					print " ($thisentry2)";
				}
			}
			print "</b><br><br>Are you sure you want to do this?</P>\n   <input type=submit name=continue value=Yes>\n   <input type=button value=No onClick=\"history.back()\">\n   <input type=hidden name=gopage value=media>\n   <input type=hidden name=dotype value=$dotype>\n   <input type=hidden name=dowhat value=mediadelete>\n   <input type=hidden name=showline value=\"$showline\">";

			# Generate footer
			&footer;
		}

		#### Like before, this is repeated three more times, so only one breakout description
		# If $dotype equals 'books'...
		if ($dotype eq 'books'){
			($thistitle,$thisauthor,$thiseacupc,$thisisbn)=split(/\|/,$showline);
			# $writenew is the start of the text that will be written to the database.
			$writenew="#DATE#|$today|#|#|#|\n";
			# $preview is the start of the text that will be shown when show preview options are enabled.
			$preview="#DATE#|$today|#|#|#|<br>\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$inauthor,$ineacupc,$inisbn,$intype) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					# skip
				}
				# If $intitle equals $thistitle and if $inauthor equals $thisauthor...
				elsif (($intitle eq $thistitle) && ($inauthor eq $thisauthor)) {
					# this essentially acts as a skip also
					print "$thisauthor, $thistitle removed<br><br>\n";
				} else {
					$writenew.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|\n";
					$preview.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|<br>\n";
				}
			}
		} elsif ($dotype eq 'games'){
			($thistitle,$thisepic,$thissteam,$thisbattlenet,$thisorigin,$thisuplay,$thisnes,$thiswii,$thisps2,$thisxboxone,$thisxbox360,$thiseacupc)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$inepic,$insteam,$inbattlenet,$inorigin,$inuplay,$innes,$inwii,$inps2,$inxboxone,$inxbox360,$ineacupc) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					# Skip
				} elsif ($intitle eq $thistitle) {
					print "$thistitle removed<br><br>\n";
				} else {
					$writenew.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|\n";
					$preview.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|<br>\n";
				}
			}
		} elsif ($dotype eq 'videos'){
			($thistitle,$thistype,$thismedia,$thisamazon,$thisdisneyanywhere,$thisgoogleplay,$thisitunes,$thisuvvu,$thiseacupc,$thisisbn,$thismicrosoft,$thisyear)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|<br>\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$intype,$inmedia,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$ineacupc,$inisbn,$inmicrosoft,$inyear) = split(/\|/,$line);
				if ($intitle eq "#DATE#") {
					# Skip
				} elsif (($intitle eq $thistitle) && ($inyear eq $thisyear)) {
					if ($thisyear) {
						$thistitle.=" ($thisyear)";
					}
					print "$thistitle removed<br><br>\n";
				} else {
					$writenew.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|\n";
					$preview.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|<br>\n";
				}
			}
		} elsif ($dotype eq 'music'){
			($thisartist,$thistitle,$thiseacupc,$thiscd,$thisamazon,$thisdjbooth,$thisgoogleplay,$thisgroove,$thisitunes,$thisreverbnation,$thistopspin,$thisrhapsody)=split(/\|/,$showline);
			$writenew="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|#|<br>\n";

			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($inartist,$intitle,$ineacupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody) = split(/\|/,$line);
				if ($inartist eq "#DATE#") {
					# Skip
				} elsif (($intitle eq $thistitle) && ($inartist eq $thisartist)) {
					print "$thisartist, $thistitle removed<br><br>\n";
				} else {
					$writenew.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|\n";
					$preview.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|<br>\n";
				}
			}
		}

		# If $debugwrite equals 1, update database with $writenew
		if ($debugwrite eq "1") {
			open (WRITEINFO,">$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
			print (WRITEINFO $writenew);
			close (WRITEINFO);
		}

		# If $debugpreviewhide equals "1", make the preview hidden within the HTML comments
		if ($debugpreviewhide eq "1") {
			print "$writenew";
		}

		# If $debugpreviewshow equals "1", make the preview shown within the administration window
		if ($debugpreviewshow eq "1") {
			print "$preview";
		}

		# Forward you back to the database table
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=$thispage?dotype=$dotype\">\n";
		print "     <p><a href=\"$thispage?dotype=$dotype\">main screen</a>";

		# Generate footer
		&footer;
	}

	sub mediawrite {
		# Open and read $mediaitem
		open (READINFO,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@infile = <READINFO>;
		close (READINFO);
		@infile=sort(@infile);

		# $changed set to '0' for a little later on in this subroutine. Essentially what happens is a comparison between entries line
		# by line, and if it reaches the end of the database, without a match, then it's assumed that the entry is completely new.
		$changed=0;

		#### Like before, this is repeated three more times, so only one breakout description
		# If $dotype equals 'books'...
		if ($dotype eq 'books'){
			# $writenew is the start of the text that will be written to the database.
			$writenew="#DATE#|$today|#|#|#|\n";
			# $new is the new entry that can be written to the database.
			$new="$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|\n";
			# $preview is the start of the text that will be written to the database.
			$preview="#DATE#|$today|#|#|#|<br>\n";
			# $previewnew is the new entry that can be written to the database.
			$previewnew="$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|<br>\n";
			# $mediawrite is the new EAC/UPC/ISBN entry that can be written to the database.
			$mediawrite="$dotype|$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$inauthor,$ineacupc,$inisbn,$intype) = split(/\|/,$line);
				if (substr($intitle,0,4) eq "The ") {
					$intitle=substr($intitle,4,length($intitle)).", The";
				}

				if ($intitle eq "#DATE#") {
					# Skip
				} elsif ($intitle eq $oldtitle) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					print "$newauthor, $newtitle updated<br><br>\n";
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
				# print "$line\n";
				($intitle,$inepic,$insteam,$inbattlenet,$inorigin,$inuplay,$innes,$inwii,$inps2,$inxboxone,$inxbox360,$ineacupc) = split(/\|/,$line);
				if (substr($intitle,0,4) eq "The ") {
					$intitle=substr($intitle,4,length($intitle)).", The";
				}
				if ($intitle eq "#DATE#") {
					# Skip
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
			$new="$newtitle|$newtype|$newmedia|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$neweacupc|$newisbn|$newmicrosoft|$newyear|\n";
			$preview="#DATE#|$today|#|#|#|#|#|#|#|#|#|<br>\n";
			$previewnew="$newtitle|$newtype|$newmedia|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$neweacupc|$newisbn|$newmicrosoft|$newyear|<br>\n";
			$mediawrite="$dotype|$newtitle||$neweacupc|$newisbn|$newtype|$newyear|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$intype,$inmedia,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$ineacupc,$inisbn,$inmicrosoft,$inyear) = split(/\|/,$line);
				if (substr($intitle,0,4) eq "The ") {
					$intitle=substr($intitle,4,length($intitle)).", The";
				}
				if ($intitle eq "#DATE#") {
					# Skip
				} elsif (($intitle eq $oldtitle) && ($inyear eq $oldyear)) {
					$writenew.=$new;
					$preview.=$previewnew;
					$changed=1;
					if ($oldyear) {
						$newtitle.=" ($newyear)";
					}
					print "$newtitle updated<br><br>\n";
				} else {
					$writenew.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|\n";
					$preview.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|<br>\n";
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
				# print "$line\n";
				($inartist,$intitle,$ineacupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody) = split(/\|/,$line);
				if (substr($intitle,0,4) eq "The ") {
					$intitle=substr($intitle,4,length($intitle)).", The";
				}
				if ($inartist eq "#DATE#") {
					# Skip
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

		# If $changed does not equal 1, then it is assumed that what has been entered is a completely new entry, so we'll add
		# $new to $writenew and $preview
		if ($changed != 1) {
			$writenew.=$new;
			$preview.=$previewnew;
			if ($newartist) {
				print "$newartist, ";
			}
			if ($newyear) {
				$newtitle.=" ($newyear)";
			}
			print "$newtitle added<br><br>\n";
		}

		# If $debugwrite is equal to "1", then writing is enabled
		if ($debugwrite eq "1") {
			open (WRITEINFO,">$basedir/$mediaitem") || &error("error: mediaitem $mediaitem<br>");
			print (WRITEINFO $writenew);
			close (WRITEINFO);

			# If $neweacupc exists...
			if ($neweacupc) {
				$file_eacupc="$basedir/$mediacheck/eacupc/$neweacupc";
				# Create an EAC/UPC entry if the file does not exist
				unless (-e $file_eacupc) {
					print "$neweacupc EAC/UPC entry added<br>\n";
					open (WRITEINFO,"+>$file_eacupc") || &error("error: neweacupc $neweacupc<br>");
					print (WRITEINFO $mediawrite);
					close (WRITEINFO);
				}
			}

			# If $newisbn exists...
			if ($newisbn) {
				$file_isbn="$basedir/$mediacheck/isbn/$newisbn";
				# Create an ISBN entry if the file does not exist
				unless (-e $file_isbn) {
					print "$newisbn ISBN entry added<br>\n";
					open (WRITEINFO,"+>$file_isbn") || &error("error: newisbn $newisbn<br>");
					print (WRITEINFO $mediawrite);
					close (WRITEINFO);
				}
			}
		}

		# If $debugpreviewhide equals 1, display the results as a hidden HTML comment
		if ($debugpreviewhide eq "1") {
			print "<!--\n$writenew\n-->\n";
			print "<!--\n$mediawrite\n-->\n";
		}

		# If $debugpreviewshow equals 1, display the results as in the administration window
		if ($debugpreviewshow eq "1") {
			print "<p>$preview</p>";
			print "<p>mediawrite: $mediawrite</p>";
		}

		# Forward you back to the media database table
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=$thispage?dotype=$dotype\">\n";
		print "     <p><a href=\"$thispage?dotype=$dotype\">main screen</a>";

		# Generate the footer
		&footer;
	}
	
	sub mediaaddid{
		# This section only generates the EAC/UPC or ISBN text input for checking whether the entries exist.
		print "\n   <table cellspacing=2 cellpadding=2>\n";

		if ($addtype eq "eacupc"){
			print "     <tr>\n      <th align=right width=30%>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
		} elsif ($addtype eq "isbn"){
			print "     <tr>\n      <th align=right width=30%>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";
		}
		
		print "     <tr>\n      <td colspan=2 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <input type=hidden name=dowhat value=mediacheck>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=addtype value=$addtype>\n";

		print "    </table>";

		# Generate the footer
		&footer;
	}

	sub mediacheck{
		# This section checks for the EAC/UPC or ISBN entries if they exist. If they do exist, then the information will be filled
		# for you! If not, then we'll forward you back to the 'mediaedit' subroutine where you can enter the details in. By doing so,
		# this will create a new entry for that EAC/UPC/ISBN! :D
		print "\n   <table cellspacing=2 cellpadding=2>\n";


		# If $neweacupc exists...
		if ($neweacupc) {
			# We'll set $mediacheck to look for that file in the directory
			$mediacheck.="/eacupc/$neweacupc";
			# We'll set $textcheck to show what EAC/UPC has been entered
			$textcheck="EAC/UPC code $neweacupc";
		}
		# If $newisbn exists...
		if ($newisbn) {
			# We'll set $mediacheck to look for that file in the directory
			$mediacheck.="/isbn/$newisbn";
			# We'll set $textcheck to show what ISBN has been entered
			$textcheck="ISBN code $newisbn";
		}
		print "checking for an existing entry for $textcheck<br>\n";
		# print "$mediacheck<br>\n";

		# There's some trickery going on below! ;) $foundentry is established as '1', but there's no $foundentry=0; around
		# the read file area below?! What gives?!
		# If the file is not present, the || &error("") part calls the error subroutine, where $foundentry=0; is established.
		# Unfortunately, variables can't be set within subroutine calls, so that's the workaround.
		$foundentry=1;
		open (media,"$basedir/$mediacheck") || &error("did not find an entry for $textcheck<br>forwarding to create an entry<br>");
		@in = <media>;
		close (media);

		if ($foundentry eq 1) {
			print "found that entry!<br>forwarding to edit the entry<br>";
			for $line(@in) {
				($dotype,$title,$author,$eacupc,$isbn,$type,$year) = split(/\|/,$line);
				# print "$dotype,$title,$author,$eacupc,$isbn,$type,$year<br>\n";
			}
			print "<p><META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL='$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$eacupc&newisbn=$isbn&newtitle=$title&newauthor=$author&newtype=$type&newyear=$year'\">\n";
			print "<a href=\"$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$eacupc&newisbn=$isbn&newtitle=$title&newauthor=$author&newtype=$type&newyear=$year\">continue</a></p>";
		} else {
			print "<p><META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL='$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$neweacupc&newisbn=$newisbn&newyear=$year'\">\n";
			print "<a href=\"$thispage?dowhat=mediaadd&dotype=$dotype&neweacupc=$neweacupc&newisbn=$newisbn&newyear=$year\">continue</a></p>";
		}

		print "    </table>";

		&footer;
	}

	sub debugview {
		open (media,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@in = <media>;
		close (media);

		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <thead>\n     <th>enable write</th>\n     <th>preview hidden</th>\n     <th>preview shown</th>\n     <th>sort by</th>\n    </tr>\n    </thead>\n    <tbody>\n";

		foreach $line(@in) {
			$line=~s/\n//g;
			($debugwrite,$debugpreviewhide,$debugpreviewshow,$debugthesort) = split(/\|/,$line);
			if ($debugwrite eq 0) {$dashwrite="off";} else {$dashwrite="on";}
			if ($debugpreviewhide eq 0) {$dashpreviewhide="off";} else {$dashpreviewhide="on";}
			if ($debugpreviewshow eq 0) {$dashpreviewshow="off";} else {$dashpreviewshow="on";}
			if ($debugthesort eq 0) {$dashthesort="off";} else {$dashthesort="on";}
			print "    <tr class=\"grid\">\n     <td>$dashwrite</td>\n     <td>$dashpreviewhide</td>\n     <td>$dashpreviewshow</td>\n     <td>$dashthesort</td>\n    </tr>\n";
		}

		print "    <tr><td align=center colspan=$columns><a href=\"$thispage?dowhat=debugedit&dotype=$dotype&fromtype=$fromtype\">Change Debug</a></td></tr>\n";
		print "    <tr>\n";
		print "     <td style=\"text-align:left\" colspan=$columns>\n";
		print "      <b>enable write</b>: enables content write when on, disabled when off<br>\n";
		print "      <b>preview hidden</b>: enables content preview within HTML comments when on, disabled when off<br>\n";
		print "      <b>preview shown</b>: enables content preview in this window when on, disabled when off<br>\n";
		print "      <b>sort by</b>: titles beginning with 'The' will instead appear with '<i>, The</i>' at the end when on, disabled when off<br>\n";
		print "      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;this applies to both the administrative and non-administrative pages, but not to the database,<br>\n";
		print "      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;primarily for sorting purposes\n";
		print "     </td>\n";
		print "    </tr>\n";
		print "    </tbody>\n   </table>\n";
	}

	sub debugedit {
		open (media,"$basedir/$mediaitem") || &error("error: mediaitem /$mediaitem");
		@in = <media>;
		close (media);
		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <thead>\n     <th>enable write</th>\n     <th>preview hidden</th>\n     <th>preview shown</th>\n     <th>sort by</th>\n    </tr>\n    </thead>\n    <tbody>\n";

		foreach $line(@in) {
			$line=~s/\n//g;
			($debugwrite,$debugpreviewhide,$debugpreviewshow,$debugthesort) = split(/\|/,$line);
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

			print "      <td>\n";
			print "       <select name=debugthesort>\n";
			if ($debugthesort eq '0'){
				print "        <option value=\"0\" selected>off</option>\n";
			} else {
				print "        <option value=\"0\">off</option>\n";
			}
			if ($debugthesort eq '1'){
				print "        <option value=\"1\" selected>on</option>\n";
			} else {
				print "        <option value=\"1\">on</option>\n";
			}
			
			print "       </select>\n";
			print "      </td>\n";
			print "     </tr>\n";
		}

		print "     <tr>\n      <td colspan=$columns align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <tr>\n";
		print "      <td style=\"text-align:left\" colspan=$columns>\n";
		print "       <b>enable write</b>: enables content write when on, disabled when off<br>\n";
		print "       <b>preview hidden</b>: enables content preview within HTML comments when on, disabled when off<br>\n";
		print "       <b>preview shown</b>: enables content preview in this window when on, disabled when off<br>\n";
		print "       <b>sort by</b>: titles beginning with 'The' will instead appear with '<i>, The</i>' at the end when on, disabled when off<br>\n";
		print "       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;this applies to both the administrative and non-administrative pages, but not to the database,<br>\n";
		print "       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;primarily for sorting purposes\n";
		print "      </td>\n";
		print "     </tr>\n";
		print "     <input type=hidden name=dowhat value=debugwrite>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=fromtype value=$fromtype>\n";
		print "    </tbody>\n   </table>\n";
	}

	sub debugwrite {
		$writenew="$editdebugwrite|$editdebugpreviewhide|$editdebugpreviewshow|$editdebugthesort|";
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
	if ($dotype ne "debug") {
		print " <script type=\"text/javascript\" src=\"/javascripts/gs_sortable.js\"></script>\n";
		print " <script type=\"text/javascript\">\n  <!--\n";

		print "   var TSort_Data = new Array ('mytable'";
		$sortcolumns=1;
		while($sortcolumns < $columns){
			print ",'s'";
			$sortcolumns = $sortcolumns + 1;
		}
		print ");\n";
		print "  -->\n";
		print " </script>\n";
	}

	print "</head>\n<body topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0 OnLoad=\"document.myform.";
	if ($dowhat eq "mediabarcode") {
		print "neweacupc";
	} elsif ($dowhat eq "mediaisbn") {
		print "newisbn";
	} elsif ($dotype eq "music") {
		print "newartist";
	} else {
		print "newtitle";
	}
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
	print "\n  </td>\n </tr>\n";
	print " <tr height=10>\n  <td align=center colspan=3>\n";
	if ($tablestats){
		print "   $tablestats<br>\n   <br>\n";
	}
	print "   <i>this script, <b>mediacollection</b>, is part of an open source Perl script available on <a href=\"https://github.com/rdgarfinkel/mediacollection\" target=\"_GitHub\">Github</a></i>\n";
	print "  </td>\n </tr>\n </form>\n</table>\n</body>\n</html>";
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
	# Set the content-type of the page to be an HTML file, and Pragma tries to force the browser
	# to always get a new version, and not cache the output
	print "Content-type: text/html\nPragma: no-cache\n\n";

	# Get the server's current date/time
	my($sec,$min,$hrs,$day,$mon,$currentyear)=localtime(time);
	$mon=$mon+1;
	if(length($mon) eq '1') {$mnth="0$mon";} else {$mnth=$mon;}
	if(length($day) eq '1') {$day="0$day";}
	if(length($hrs) eq '1') {$hrs="0$hrs";}
	if(length($min) eq '1') {$min="0$min";}
	if(length($sec) eq '1') {$sec="0$sec";}
	$currentyear=$currentyear+1900;
	$today="$currentyear.$mnth.$day";

	## Enable or disable update functions
	open (debug,"$basedir/$debug") || &error("error: debug $debug");
	@in = <debug>;
	close (debug);
	for $line(@in) {
		($debugwrite,$debugpreviewhide,$debugpreviewshow,$debugthesort) = split(/\|/,$line);
	}

	# Delay write information display
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

	### Retrieve information passed from/to scripts

	# $delay is for diagnostic purposes, just to check that all variables appear correctly when running
	$delay="<!--ez editor v$dateupdated || today $today || debugpreviewshow $debugpreviewshow || debugpreviewhide $debugpreviewhide || wait $wait";

	# Get the QUERY_STRING from URI and display as part of $delay
	@querys = split(/&/, $ENV{'QUERY_STRING'});
	foreach $query (@querys) {
		($name, $value) = split(/=/, $query);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ s/<!--(.|\n)*-->//g;
		$value =~ s/\"/\'\'/g;
		$value =~ s/\&/and/g;
		$value =~ s/#/\(pound\)/g;
		$FORM{$name} = $value;
		$delay.=" || $name = $value";
	}
	$delay.="-->";

	###### Global variable sets
	$action=$FORM{'action'};
	$dotype=$FORM{'dotype'};
	$dowhat=$FORM{'dowhat'};
	$showline=$FORM{'showline'};
	$continue=$FORM{'continue'};
	$continueisbn=$FORM{'continueisbn'};
	$continueeacupc=$FORM{'continueeacupc'};
	$addtype=$FORM{'addtype'};
	## Multi-use variable sets
	$newtitle=$FORM{'newtitle'};
	$oldtitle=$FORM{'oldtitle'};
	$neweacupc=$FORM{'neweacupc'};
	$neweacupc=~s/[^\d]//gi;                   # remove any character besides numbers for EAC/UPC
	$oldeacupc=$FORM{'oldeacupc'};
	$newisbn=$FORM{'newisbn'};
	$newisbn=~s/[^\dxX]//gi;                   # remove any character besides numbers and X from ISBN
	$newisbn=uc $newisbn;                      # force uppercase for ISBN
	$oldisbn=$FORM{'oldisbn'};
	$newtype=$FORM{'newtype'};
	$oldtype=$FORM{'oldtype'};
	$newamazon=$FORM{'newamazon'};
	$oldamazon=$FORM{'oldamazon'};
	$newgoogleplay=$FORM{'newgoogleplay'};
	$oldgoogleplay=$FORM{'oldgoogleplay'};
	$newitunes=$FORM{'newitunes'};
	$olditunes=$FORM{'olditunes'};
	## Variable sets for books
	$newauthor=$FORM{'newauthor'};
	$oldauthor=$FORM{'oldauthor'};
	## Variable sets for games
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
	## Variable sets for videos
	$newmedia=$FORM{'newmedia'};
	$oldmedia=$FORM{'oldmedia'};
	$newdisneyanywhere=$FORM{'newdisneyanywhere'};
	$olddisneyanywhere=$FORM{'olddisneyanywhere'};
	$newuvvu=$FORM{'newuvvu'};
	$olduvvu=$FORM{'olduvvu'};
	$newmicrosoft=$FORM{'newmicrosoft'};
	$oldmicrosoft=$FORM{'oldmicrosoft'};
	$newyear=$FORM{'newyear'};
	$oldyear=$FORM{'oldyear'};
	## Variable sets for music
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
	## Variable sets for debug
	$editdebugwrite=$FORM{'debugwrite'};
	$editdebugpreviewhide=$FORM{'debugpreviewhide'};
	$editdebugpreviewshow=$FORM{'debugpreviewshow'};
	$editdebugthesort=$FORM{'debugthesort'};
	$fromtype=$FORM{'fromtype'};

	## The next few lines define the location of $mediaitem for media types, and how many columns are in the data display table.
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
		if ($dowhat eq "") {$dowhat="debugview";}
		$mediaitem.="debug.txt";
		$columns=4;
	} else {
		&header;
		&errorfatal("missing \'dotype\'");
	}
}
