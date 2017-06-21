#!/usr/bin/perl

### MEDIACOLLECTION SETTINGS
## $media_check_eacupc - Directory where the EAC/UPC data. In my case, these are located in cgi-bin/eacupc.
$media_check_eacupc="cgi-bin/eacupc";
## $media_check_isbn - Directory where the ISBN data. In my case, these are located in cgi-bin/isbn.
$media_check_isbn="cgi-bin/isbn";
## $config_data - Location for the configuration data
$config_data="cgi-bin/media/media_debug.txt";
$config_indexsite="cgi-bin/media/index.cgi";
$config_adminsite="cgi-bin/media/media.pl";
$config_eacupcisbnsite="cgi-bin/media/media.pl";
## $media_eacupcisbndb - Location for the EAC/UPC/ISBN database
$media_eacupcisbndb="cgi-bin/media/eacupcisbn_db.txt";
## $media_read - Location for the media data
$media_read="cgi-bin/media/media_";
	$media_books=$media_read."books.txt";
	$media_games=$media_read."games.txt";
	$media_music=$media_read."music.txt";
	$media_videos=$media_read."videos.txt";

## $dateupdated - Date that the script was last updated
$dateupdated="2017.06.21";

## Calls to the 'getqueries' subroutine.
&getqueries;

### GENERATES THE ADMIN PAGES
## If $dotype exists, call the 'header' subroutine, then the 'media' subroutine.
if ($dotype) {&header; &media;}

## Since $dotype doesn't exist, call the 'header' subroutine, then stop the script with a friendly message on what to do next
else {&header;&errorfatal("missing or invalid administration page<br>select a link above");}


sub media {
	# If $dowhat equals 'media_edit', go to the 'media_edit' subroutine
	if ($dowhat eq "media_edit") {&media_edit;}

	# If $dowhat equals 'media_add', go to the 'media_edit' subroutine
	elsif ($dowhat eq "media_add") {&media_edit;}

	# If $dowhat equals 'media_barcode' or 'media_isbn', go to the 'media_addid' subroutine
	elsif (($dowhat eq "media_barcode") || ($dowhat eq "media_isbn")) {&media_addid;}

	# If $dowhat equals 'media_check', go to the 'media_check' subroutine
	elsif ($dowhat eq "media_check") {&media_check;}

	# If $dowhat equals 'media_write', go to the 'media_write' subroutine
	elsif ($dowhat eq "media_write") {&media_write;}

	# If $dowhat equals 'media_delete', go to the 'media_delete' subroutine
	elsif ($dowhat eq "media_delete") {&media_delete;}

	# If $dowhat equals 'config_view', go to the 'config_view' subroutine
	elsif ($dowhat eq "config_view") {&config_view;}

	# If $dowhat equals 'config_edit', go to the 'config_edit' subroutine
	elsif ($dowhat eq "config_edit") {&config_edit;}

	# If $dowhat equals 'config_write', go to the 'config_write' subroutine
	elsif ($dowhat eq "config_write") {&config_write;}

	# If $dowhat equals 'config_columns_view', go to the 'config_columns_view' subroutine
	elsif ($dowhat eq "config_columns_view") {&config_columns_view;}

	# If $dowhat equals 'config_columns_edit', go to the 'config_columns_edit' subroutine
	elsif ($dowhat eq "config_columns_edit") {&config_columns_edit;}

	# If $dowhat equals 'config_columns_write', go to the 'config_columns_write' subroutine
	elsif ($dowhat eq "config_columns_write") {&config_columns_write;}

	# If $dowhat equals 'eacupcisbn_generate', go to the 'eacupcisbn_generate' subroutine
	elsif ($dowhat eq "eacupcisbn_generate") {&eacupcisbn_generate;}

	# If $dowhat equals 'eacupcisbn_compare', go to the 'eacupcisbn_compare' subroutine
	elsif ($dowhat eq "eacupcisbn_compare") {&eacupcisbn_compare;}

	# If $dowhat equals 'eacupc_edit' or 'isbn_edit', go to the 'edit' subroutine
	elsif (($dowhat eq "eacupc_edit") || ($dowhat eq "isbn_edit")) {&eacupcisbn_edit;}

	# If $dowhat equals 'eacupcisbn_write', go to the 'eacupcisbn_write' subroutine
	elsif ($dowhat eq "eacupcisbn_write") {&eacupcisbn_write;}

	# If $dowhat equals 'eacupcisbn_viewall', go to the 'eacupcisbn_viewall' subroutine
	elsif ($dowhat eq "eacupcisbn_viewall") {&eacupcisbn_viewall;}

	# Since $dowhat doesn't match anything above, generate the database table
	else {&media_main;}


	# media_main is the data display table
	sub media_main {
		# Read the entry for $media_read. $media_read is established within the 'getqueries' subroutine.
		open (media,"$basedir/$media_read") || &error("error: media_read data /$media_read");
		@in = <media>;
		close (media);

		# Begin table
		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";

		# $count_title is a 'global' variable for each media type, so that we can get a total number count of individual media types. It's
		# outside of the media type sections because it cuts down on repetition, since it would appear four times, once per media type. :)
		$count_title=0;

		# If $dotype equals books...
		if ($dotype eq 'books'){
			# Set variables below to 0
			$count_ebook=0;
			$count_book=0;

			# Generate table headers
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>Author(s)</th>\n     <th>EAC/UPC</th>\n     <th>ISBN</th>\n     <th>Type</th>\n     <th>Purchase<br>Date</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read media_read data line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($title,$author,$eacupc,$isbn,$type,$purchasedate) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if (substr($title,0,6) ne "#DATE#") {
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
					$titledisplay =~ s/\(amp\)/\&/g;
					$authordisplay=$author;
					$authordisplay =~ s/\'\'/\"/g;
					$authordisplay =~ s/\(plus\)/+/g;
					$authordisplay =~ s/\(pound\)/#/g;
					$authordisplay =~ s/\(amp\)/\&/g;

					# If $config_thesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($config_thesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $config_thesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($config_thesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_edit&showline=$line\">$titledisplay</a></div></td>\n     <td><div>$authordisplay</div></td>\n     <td>$eacupc</td>\n     <td>$isbn</td>\n     <td>$type</td>\n     <td>$purchasedate</td>\n     <td><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_delete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=substr($title,(length($title)-10),10);
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
			print "    <thead>\n     <th>#</th>\n     <th>Title</th>\n     <th>EAC/UPC</th>\n     <th>Battle.net</th>\n     <th>Epic</th>\n     <th>NES</th>\n     <th>Origin</th>\n     <th>PS2</th>\n     <th>Steam</th>\n     <th>Uplay</th>\n     <th>XBox 360</th>\n     <th>XBox One</th>\n     <th>Wii</th>\n    <th>Purchase<br>Date</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read media_read data line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc,$purchasedate) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if (substr($title,0,6) ne "#DATE#") {
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
					$titledisplay =~ s/\(amp\)/\&/g;

					# If $config_thesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($config_thesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $config_thesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($config_thesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_edit&showline=$line\">$titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$battlenet</td>\n     <td>$epic</td>\n     <td>$nes</td>\n     <td>$origin</td>\n     <td>$ps2</td>\n     <td>$steam</td>\n     <td>$uplay</td>\n     <td>$xbox360</td>\n     <td>$xboxone</td>\n     <td>$wii</td>\n     <td>$purchasedate</td>\n     <td><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_delete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=substr($title,(length($title)-10),10);
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
			print "    <thead>\n     <th>#</th>\n     <th>Title (Year)</th>\n     <th>EAC/UPC</th>\n     <th>ISBN</th>\n     <th>Type</th>\n     <th>Physical<br>Media</th>\n     <th>Amazon<br>Video</th>\n     <th>Disney<br>Anywhere</th>\n     <th>Google<br>Play</th>\n     <th>iTunes</th>\n     <th>Microsoft</th>\n     <th>UVVU</th>\n    <th>Purchase<br>Date</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read media_read data line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn,$microsoft,$year,$purchasedate) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if (substr($title,0,6) ne "#DATE#") {
					# $mediadisplay is set to empty text here because once it was set, it would keep that text and because it would
					# keep displaying it on the table until another media entry changed it, which threw off the media type count
					$mediadisplay="";

					# The code below breaks out the count of physical media types.
					#   If media is bluray, increment count for bluray by 1, and make $mediadisplay text say, "BluRay"
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
					} elsif (($mediadisplay eq "") && ($amazon eq "X") || ($disneyanywhere eq "X") || ($googleplay eq "X") || ($itunes eq "X") || ($microsoft eq "X") || ($uvvu eq "X")) {
						$mediadisplay="Streaming";
					}

					# The code below breaks out the count of TV and Movie media types.
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
					$titledisplay =~ s/\(amp\)/\&/g;

					# If $config_thesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($config_thesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $config_thesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($config_thesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# If $year exists, add the movie's year to the title
					if ($year) {
						$titledisplay.=" ($year)";
					}
					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_edit&showline=$line\">$titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$isbn</td>\n     <td>$type</td>\n     <td>$mediadisplay</td>\n     <td>$amazon</td>\n     <td>$disneyanywhere</td>\n     <td>$googleplay</td>\n     <td>$itunes</td>\n     <td>$microsoft</td>\n     <td>$uvvu</td>\n     <td>$purchasedate</td>\n     <td><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_delete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $title was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=substr($title,(length($title)-10),10);
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
			print "    <thead>\n     <th>#</th>\n     <th>Artist &ndash; Title</th>\n     <th>EAC/UPC</th>\n     <th>CD</th>\n     <th>Amazon</th>\n     <th>DJ Booth</th>\n     <th>Google<br>Play</th>\n     <th>Groove</th>\n     <th>iTunes</th>\n     <th>ReverbNation</th>\n     <th>Rhapsody</th>\n     <th>TopSpin</th>\n    <th>Purchase<br>Date</th>\n     <th>Delete</th>\n    </tr>\n    </thead>\n";

			# Beginning of table body
			print "    <tbody>\n";

			# Read media_read data line by line
			foreach $line(@in) {
				$line =~ s/\n//g;                                                  # Strips new line character
				$line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				# Split each variable by the | character
				($artist,$title,$eacupc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody,$purchasedate) = split(/\|/,$line);

				# If $title doesn't equal "#DATE#"
				if (substr($artist,0,6) ne "#DATE#") {
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
					$titledisplay =~ s/\(amp\)/\&/g;
					$artistdisplay=$artist;
					$artistdisplay =~ s/\'\'/\"/g;
					$artistdisplay =~ s/\(plus\)/+/g;
					$artistdisplay =~ s/\(pound\)/#/g;
					$artistdisplay =~ s/\(amp\)/\&/g;

					# If $config_thesort is equal to 0 and if the title ends with ", The", we'll put "The " at the beginning of the title, and remove ", The" from the end
					if ($config_thesort == "0" && substr($titledisplay,length($titledisplay)-5,5) eq ", The") {
						$titledisplay="The ".substr($titledisplay,0,length($titledisplay)-5);
					}
					# If $config_thesort is equal to 1 and if the title begins with "The ", we'll put ", The" at the end of the title, and remove "The" from the beginning
					if ($config_thesort == "1" && substr($titledisplay,0,4) eq "The ") {
						$titledisplay=substr($titledisplay,4,length($titledisplay)).", The";
					}

					# Now display the whole line of information
					print "    <tr class=\"grid\">\n     <td>$count_title</td><td><div><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_edit&showline=$line\">$artistdisplay &ndash; $titledisplay</a></div></td>\n     <td>$eacupc</td>\n     <td>$cd</td>\n     <td>$amazon</td>\n     <td>$djbooth</td>\n     <td>$googleplay</td>\n     <td>$groove</td>\n     <td>$itunes</td>\n     <td>$reverbnation</td>\n     <td>$rhapsody</td>\n     <td>$topspin</td>\n     <td>$purchasedate</td>\n     <td><a href=\"/$config_adminsite?dotype=$dotype&dowhat=media_delete&showline=$line\">delete</a></td>\n    </tr>\n";
				}
				# $artist was equal to "#DATE#", so we'll set $update with the date the database was last updated
				else {
					$update=substr($artist,(length($artist)-10),10);
				}
			}

			# End of the table body
			print "    </tbody>\n";

			# $tablestats will display the details that have been generated from the above code at a later time
			$tablestats="<b>script updated $dateupdated || database updated $update || total $dotype $count_title</b><br>\n   CD $count_cd || Amazon $count_amazon || DJ Booth $count_djbooth || Google Play $count_googleplay || Groove $count_groove || iTunes $count_itunes || ReverbNation $count_reverbnation || TopSpin $count_topspin || Rhapsody $count_rhapsody";
		}

		# If $dotype is not equal to "config" show the add item links 
		if ($dotype ne "config") {
			$tablestats.="<br>\n   <br>\n   <a href=\"/$config_adminsite?dowhat=media_add&dotype=$dotype\">Add Item Manually</a> | <a href=\"/$config_adminsite?dowhat=media_barcode&dotype=$dotype&addtype=eacupc\">Add Item by Barcode</a> | <a href=\"/$config_adminsite?dowhat=media_isbn&dotype=$dotype&addtype=isbn\">Add Item by ISBN</a>";
		}

		# End table
		print "   </table>";

		# Generate the footer
		&footer;
	}

	# media_edit is where media entries are edited
	sub media_edit {
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
			# If $dowhat equals "media_add"...
			if ($dowhat eq "media_add") {
				# This part is primarily for the addition of media based on EAC/UPC/ISBN codes. This essentially passes the information from
				# the "Add Item by EAC/UPC/ISBN" section to this part, whether information is found or not, and displays them in the correct
				# fields for further editing by the user for the various media types or services.
				$author=$newauthor;
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
				$type=$newtype;
			}
			# $dowhat doesn't equal "media_add", so the user has to be editing an already existing entry
			else {
				# Split each entry of $showline by the character '|'
				($title,$author,$eacupc,$isbn,$type,$purchasedate)=split(/\|/,$showline);
			}

			# Generate the necessary text input fields for adding/editing entries
			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Author:</th>\n      <td><input type=text name=newauthor value=\"$author\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td>\n       <input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";
			if ($purchasedate) {$todaysdate=$purchasedate;}
			print "     <tr>\n      <th align=right>Date:</th>\n      <td><input type=date id=newpurchasedate name=newpurchasedate value=\"$todaysdate\"/></td>\n     </tr>\n";

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
			if ($dowhat eq "media_add") {
				$title=$newtitle;
				$eacupc=$neweacupc;
			} else {
				($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc,$purchasedate)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td>\n       <input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			if ($purchasedate) {$todaysdate=$purchasedate;}
			print "     <tr>\n      <th align=right>Date:</th>\n      <td><input type=date id=newpurchasedate name=newpurchasedate value=\"$todaysdate\"/></td>\n     </tr>\n";

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
			if ($dowhat eq "media_add") {
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
				$type=$newtype;
			} else {
				($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn,$microsoft,$year,$purchasedate)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Year:</th>\n      <td><input type=text name=newyear value=\"$year\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";
			if ($purchasedate) {$todaysdate=$purchasedate;}
			print "     <tr>\n      <th align=right>Date:</th>\n      <td><input type=date id=\"newpurchasedate\" name=newpurchasedate value=\"$todaysdate\"/></td>\n     </tr>\n";

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
			if ($dowhat eq "media_add") {
				$artist=$newauthor;
				$title=$newtitle;
				$eacupc=$neweacupc;
				$isbn=$newisbn;
			} else {
				($artist,$title,$eacupc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody,$purchasedate)=split(/\|/,$showline);
			}

			print "     <tr>\n      <th align=right width=30%>Artist:</th>\n      <td><input type=text name=newartist value=\"$artist\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>Title:</th>\n      <td><input type=text name=newtitle value=\"$title\"></td>\n     </tr>\n";
			print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
			if ($purchasedate) {$todaysdate=$purchasedate;}
			print "     <tr>\n      <th align=right>Date:</th>\n      <td><input type=date id=newpurchasedate name=newpurchasedate value=\"$todaysdate\"/></td>\n     </tr>\n";

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

		#### End of 'media_edit' breakout, resuming text descriptions

		# Create 'Submit' and 'Cancel' buttons for the edits.
		print "     <tr>\n      <td colspan=2 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";

		# Hidden variables for passing onto the script for the next step to add/edit entries.
		# dotype passes on the current media type to the 'mediawrite' subroutine, once the entry is submitted
		# oldtitle is actually the current title, and is how 'mediawrite' finds an already existing entry for editing the entry
		print "     <input type=hidden name=dowhat value=media_write>\n";
		if (($dotype eq 'music') || ($dotype eq 'books') || ($dotype eq 'videos') || ($dotype eq 'games')) {
				print "     <input type=hidden name=dotype value=$dotype>\n";
		}
		print "     <input type=hidden name=oldtitle value=\"$title\">\n";

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

		# Generate the footer
		&footer;
	}

	sub media_delete {
		# Open and read $media_read
		open (READINFO,"$basedir/$media_read") || &error("error: media_read data /$media_read");
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
			($thisentry1,$null,$null,$null,$null,$null,$null,$null,$null,$null,$null,$thisentry2,$null)=split(/\|/,$showline);
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
			print "</b><br><br>Are you sure you want to do this?</P>\n   <input type=submit name=continue value=Yes>\n   <input type=button value=No onClick=\"history.back()\">\n   <input type=hidden name=gopage value=media>\n   <input type=hidden name=dotype value=$dotype>\n   <input type=hidden name=dowhat value=media_delete>\n   <input type=hidden name=showline value=\"$showline\">";

		# Generate the footer
		&footer;
		}

		#### Like before, this is repeated three more times, so only one breakout description
		# If $dotype equals 'books'...
		if ($dotype eq 'books'){
			($thistitle,$thisauthor,$thiseacupc,$thisisbn)=split(/\|/,$showline);
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$inauthor,$ineacupc,$inisbn,$intype,$inpurchasedate) = split(/\|/,$line);
				if (substr($intitle,0,6) eq "#DATE#") {
					# $writenew is the start of the text that will be written to the database.
					$writenew="#DATE#,$today|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|\n";
					# $preview is the start of the text that will be shown when show preview options are enabled.
					 $preview="#DATE#,$today|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|<br>\n";
				} else {
					# If $intitle equals $thistitle and if $inauthor equals $thisauthor...
					if (($intitle eq $thistitle) && ($inauthor eq $thisauthor)) {
						# this essentially acts as a skip also
						print "$thisauthor, $thistitle removed<br><br>\n";
					} else {
						$writenew.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|\n";
						 $preview.="$intitle|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|<br>\n";
					}
				}
			}
		} elsif ($dotype eq 'games'){
			($thistitle,$thisepic,$thissteam,$thisbattlenet,$thisorigin,$thisuplay,$thisnes,$thiswii,$thisps2,$thisxboxone,$thisxbox360,$thiseacupc,$thispurchasedate)=split(/\|/,$showline);
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$inepic,$insteam,$inbattlenet,$inorigin,$inuplay,$innes,$inwii,$inps2,$inxboxone,$inxbox360,$ineacupc,$inpurchasedate) = split(/\|/,$line);
				if (substr($intitle,0,6) eq "#DATE#") {
					$writenew="#DATE#,$today|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|\n";
					 $preview="#DATE#,$today|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|<br>\n";
				} else {
					if ($intitle eq $thistitle) {
						print "$thistitle removed<br><br>\n";
					} else {
						$writenew.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|\n";
						 $preview.="$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|<br>\n";
					}
				}
			}
		} elsif ($dotype eq 'videos'){
			($thistitle,$thistype,$thismedia,$thisamazon,$thisdisneyanywhere,$thisgoogleplay,$thisitunes,$thisuvvu,$thiseacupc,$thisisbn,$thismicrosoft,$thisyear,$thispurchasedate)=split(/\|/,$showline);
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$intype,$inmedia,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$ineacupc,$inisbn,$inmicrosoft,$inyear,$inpurchasedate) = split(/\|/,$line);
				if (substr($intitle,0,6) eq "#DATE#") {
					$writenew="#DATE#,$today|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|\n";
					 $preview="#DATE#,$today|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|<br>\n";
				} else {
					if (($intitle eq $thistitle) && ($inyear eq $thisyear)) {
						if ($thisyear) {
							$thistitle.=" ($thisyear)";
						}
						print "$thistitle removed<br><br>\n";
					} else {
						$writenew.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|\n";
						 $preview.="$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|<br>\n";
					}
				}
			}
		} elsif ($dotype eq 'music'){
			($thisartist,$thistitle,$thiseacupc,$thiscd,$thisamazon,$thisdjbooth,$thisgoogleplay,$thisgroove,$thisitunes,$thisreverbnation,$thistopspin,$thisrhapsody,$thispurchasedate)=split(/\|/,$showline);
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($inartist,$intitle,$ineacupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody,$inpurchasedate) = split(/\|/,$line);
				if (substr($inartist,0,6) eq "#DATE#") {
					$writenew="#DATE#,$today|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|\n";
					 $preview="#DATE#,$today|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|<br>\n";
				} else {
					if (($intitle eq $thistitle) && ($inartist eq $thisartist)) {
						print "$thisartist, $thistitle removed<br><br>\n";
					} else {
						$writenew.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|\n";
						 $preview.="$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|<br>\n";
					}
				}
			}
		}

		# If $config_write equals 1, update database with $writenew
		if ($config_write eq "1") {
			open (WRITEINFO,">$basedir/$media_read") || &error("error: media_read data /$media_read");
			print (WRITEINFO $writenew);
			close (WRITEINFO);
		}

		# If $config_previewhide equals "1", make the preview hidden within the HTML comments
		if ($config_previewhide eq "1") {
			print "$writenew";
		}

		# If $config_previewshow equals "1", make the preview shown within the administration window
		if ($config_previewshow eq "1") {
			print "$preview";
		}

		# Forward you back to the database table
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=/$config_adminsite?dotype=$dotype\">\n";
		print "     <p><a href=\"/$config_adminsite?dotype=$dotype\">main screen</a>";

		# Generate the footer
		&footer;
	}

	sub media_write {
		# Open and read $media_read
		open (READINFO,"$basedir/$media_read") || &error("error: media_read data /$media_read");
		@infile = <READINFO>;
		close (READINFO);
		@infile=sort(@infile);

		# $changed set to '0' for a little later on in this subroutine. Essentially what happens is a comparison between entries line
		# by line, and if it reaches the end of the database, without a match, then it's assumed that the entry is completely new.
		$changed=0;

		#### Like before, this is repeated three more times, so only one breakout description
		# If $dotype equals 'books'...
		if ($dotype eq 'books'){
			# the next two lines begin the unsorted_updatedb and unsorted_previewdb arrays, and begins establishing the date last modified of the database.
			# $update_entry is the new entry that can be written to the database, $previewentry creates the new entry for the preview.
			$update_entry="$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|$newpurchasedate|\n";
			$previewentry=$update_entry;
			# $mediawrite is the new EAC/UPC/ISBN entry that can be written to the database.
			$mediawrite="$dotype|$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				#print "$line<br>\n";
				($intitle,$inauthor,$ineacupc,$inisbn,$intype,$inpurchasedate) = split(/\|/,$line);
				if (substr($intitle,0,6) eq "#DATE#") {
					push(@unsorted_updateddb,"#DATE#,$today|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|\n");
					push(@unsorted_previewdb,"#DATE#,$today|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|\n");
				} else {
					if (substr($intitle,0,4) eq "The ") {
						$intitle=substr($intitle,4,length($intitle)).", The";
					}
					if ($intitle eq $oldtitle) {
						push(@unsorted_updateddb,$update_entry);
						push(@unsorted_previewdb,$previewentry);
						$changed=1;
						print "$newauthor, $newtitle updated<br><br>\n";
					} else {
						push(@unsorted_updateddb,"$intitle|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|\n");
						push(@unsorted_previewdb,"$intitle|$inauthor|$ineacupc|$inisbn|$intype|$inpurchasedate|\n");
					}
				}
			}
		} elsif ($dotype eq 'games'){
			$update_entry="$newtitle|$newepic|$newsteam|$newbattlenet|$neworigin|$newuplay|$newnes|$newwii|$newps2|$newxboxone|$newxbox360|$neweacupc|$newpurchasedate|\n";
			$previewentry=$update_entry;
			$mediawrite="$dotype|$newtitle||$neweacupc|$newisbn||";
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$inepic,$insteam,$inbattlenet,$inorigin,$inuplay,$innes,$inwii,$inps2,$inxboxone,$inxbox360,$ineacupc,$inpurchasedate) = split(/\|/,$line);
				if (substr($intitle,0,6) eq "#DATE#") {
					push(@unsorted_updateddb,"#DATE#,$today|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|\n");
					push(@unsorted_previewdb,"#DATE#,$today|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|\n");
				} else {
					if (substr($intitle,0,4) eq "The ") {
						$intitle=substr($intitle,4,length($intitle)).", The";
					}
					if ($intitle eq $oldtitle) {
						push(@unsorted_updateddb,$update_entry);
						push(@unsorted_previewdb,$previewentry);
						$changed=1;
						print "$newtitle updated<br><br>\n";
					} else {
						push(@unsorted_updateddb,"$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|\n");
						push(@unsorted_previewdb,"$intitle|$inepic|$insteam|$inbattlenet|$inorigin|$inuplay|$innes|$inwii|$inps2|$inxboxone|$inxbox360|$ineacupc|$inpurchasedate|\n");
					}
				}
			}
		} elsif ($dotype eq 'videos'){
			$update_entry="$newtitle|$newtype|$newmedia|$newamazon|$newdisneyanywhere|$newgoogleplay|$newitunes|$newuvvu|$neweacupc|$newisbn|$newmicrosoft|$newyear|$newpurchasedate|\n";
			$previewentry=$update_entry;
			$mediawrite="$dotype|$newtitle||$neweacupc|$newisbn|$newtype|$newyear|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($intitle,$intype,$inmedia,$inamazon,$indisneyanywhere,$ingoogleplay,$initunes,$inuvvu,$ineacupc,$inisbn,$inmicrosoft,$inyear,$inpurchasedate) = split(/\|/,$line);
				if (substr($intitle,0,6) eq "#DATE#") {
					push(@unsorted_updateddb,"#DATE#,$today|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|\n");
					push(@unsorted_previewdb,"#DATE#,$today|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|\n");
				} else {
					if (substr($intitle,0,4) eq "The ") {
						$intitle=substr($intitle,4,length($intitle)).", The";
					}
					if (($intitle eq $oldtitle) && ($inyear eq $oldyear)) {
						push(@unsorted_updateddb,$update_entry);
						push(@unsorted_previewdb,$previewentry);
						$changed=1;
						if ($oldyear) {
							$newtitle.=" ($newyear)";
						}
						print "$newtitle updated<br><br>\n";
					} else {
						push(@unsorted_updateddb,"$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|\n");
						push(@unsorted_previewdb,"$intitle|$intype|$inmedia|$inamazon|$indisneyanywhere|$ingoogleplay|$initunes|$inuvvu|$ineacupc|$inisbn|$inmicrosoft|$inyear|$inpurchasedate|\n");
					}
				}
			}
		} elsif ($dotype eq 'music'){
			$update_entry="$newartist|$newtitle|$neweacupc|$newcd|$newamazon|$newdjbooth|$newgoogleplay|$newgroove|$newitunes|$newreverbnation|$newtopspin|$newrhapsody|$newpurchasedate|\n";
			$previewentry=$update_entry;
			$mediawrite="$dotype|$newtitle|$newartist|$neweacupc|$newisbn|$newtype|";
			foreach $line(@infile) {
				$line=~s/\n//g;
				# print "$line\n";
				($inartist,$intitle,$ineacupc,$incd,$inamazon,$indjbooth,$ingoogleplay,$ingroove,$initunes,$inreverbnation,$intopspin,$inrhapsody,$inpurchasedate) = split(/\|/,$line);
				if (substr($inartist,0,6) eq "#DATE#") {
					push(@unsorted_updateddb,"#DATE#,$today|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|\n");
					push(@unsorted_previewdb,"#DATE#,$today|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|\n");
				} else {
					if (substr($intitle,0,4) eq "The ") {
						$intitle=substr($intitle,4,length($intitle)).", The";
					}
					if (($intitle eq $oldtitle) && ($inartist eq $oldartist)) {
						push(@unsorted_updateddb,$update_entry);
						push(@unsorted_previewdb,$previewentry);
						$changed=1;
						print "$newartist, $newtitle updated<br><br>\n";
					} else {
						push(@unsorted_updateddb,"$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|\n");
						push(@unsorted_previewdb,"$inartist|$intitle|$ineacupc|$incd|$inamazon|$indjbooth|$ingoogleplay|$ingroove|$initunes|$inreverbnation|$intopspin|$inrhapsody|$inpurchasedate|\n");
					}
				}
			}
		}

		# If $changed does not equal 1, then it is assumed that what has been entered is a completely new entry,
		# so we'll add $update_entry and #previewentry string to @unsorted_updateddb and @unsorted_previewdb arrays
		if ($changed != 1) {
			push(@unsorted_updateddb,$update_entry);
			push(@unsorted_previewdb,$previewentry);
			if ($newartist) {
				print "$newartist, ";
			}
			if ($newyear) {
				$newtitle.=" ($newyear)";
			}
			print "$newtitle added<br><br>\n";
		}

		# These next two sort the @unsorted_updateddb and @unsorted_previewdb arrays in alphabetical order.
		@sorted_updateddb = sort @unsorted_updateddb;
		@sorted_previewdb = sort @unsorted_previewdb;

		# If $config_write is equal to "1", then writing is enabled
		if ($config_write eq "1") {
			open (WRITEINFO,">$basedir/$media_read") || &error("error: media_read data $media_read<br>");
			print (WRITEINFO @sorted_updateddb);
			close (WRITEINFO);

			# If $neweacupc exists...
			if ($neweacupc) {
				$file_eacupc="$basedir/$media_check_eacupc/$neweacupc";
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
				$file_isbn="$basedir/$media_check_isbn/$newisbn";
				# Create an ISBN entry if the file does not exist
				unless (-e $file_isbn) {
					print "$newisbn ISBN entry added<br>\n";
					open (WRITEINFO,"+>$file_isbn") || &error("error: newisbn $newisbn<br>");
					print (WRITEINFO $mediawrite);
					close (WRITEINFO);
				}
			}
		}

		# If $config_previewhide equals 1, display the results as a hidden HTML comment
		if ($config_previewhide eq "1") {
			print "<!--\n unsorted_updateddb: @unsorted_updateddb\n-->\n";
			print "<!- \n sorted_updateddb: @sorted_updateddb\n-->\n";
			print "<!--\n unsorted_previewdb: @unsorted_previewdb\n-->\n";
			print "<!- \n sorted_previewdb: @sorted_previewdb\n-->\n";
			print "<!--\n mediawrite: $mediawrite\n-->\n";
		}

		# If $config_previewshow equals 1, display the results in the administration window
		if ($config_previewshow eq "1") {
			print "<p><b>unsorted_updateddb</b>: <div style=\"text-align:left;width:700px;\">";
			foreach (@unsorted_updateddb) {
 				print "$_<br>\n";
			}
			print "</div></p>\n";
			print "<p><b>sorted_updateddb</b>: <div style=\"text-align:left;width:700px;\">";
			foreach (@sorted_updateddb) {
 				print "$_<br>\n";
			}
			print "</div></p>\n";
			print "<p><b> unsorted_previewdb</b>: <div style=\"text-align:left;width:700px;\">";
			foreach (@unsorted_previewdb) {
 				print "$_<br>\n";
			}
			print "</div></p>\n";
			print "<p><b>sorted_previewdb</b>: <div style=\"text-align:left;width:700px;\">";
			foreach (@sorted_previewdb) {
 				print "$_<br>\n";
			}
			print "</div></p>\n";
			print "<p><b>mediawrite</b>: <div style=\"text-align:left;width:700px;\">$mediawrite</div></p>\n";
		}

		# Forward you back to the media database table
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=/$config_adminsite?dotype=$dotype\">\n";
		print "     <p><a href=\"/$config_adminsite?dotype=$dotype\">main screen</a>";

		# Generate the footer
		&footer;
	}

	sub media_addid {
		# This section only generates the EAC/UPC or ISBN text input for checking whether the entries exist.
		print "\n   <table cellspacing=2 cellpadding=2>\n";

		if ($addtype eq "eacupc"){
			print "     <tr>\n      <th align=right width=30%>EAC/UPC:</th>\n      <td><input type=text name=neweacupc value=\"$eacupc\"></td>\n     </tr>\n";
		} elsif ($addtype eq "isbn"){
			print "     <tr>\n      <th align=right width=30%>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$isbn\"></td>\n     </tr>\n";
		}
		
		print "     <tr>\n      <td colspan=2 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <input type=hidden name=dowhat value=media_check>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=addtype value=$addtype>\n";

		print "    </table>";

		# Generate the footer
		&footer;
	}

	sub media_check {
		# This section checks for the EAC/UPC or ISBN entries if they exist. If they do exist, then the information will be filled
		# for you! If not, then we'll forward you back to the 'media_edit' subroutine where you can enter the details in. By doing so,
		# this will create a new entry for that EAC/UPC/ISBN! :D
		print "\n   <table cellspacing=2 cellpadding=2>\n";


		# If $neweacupc exists...
		if ($neweacupc) {
			# We'll set $media_check to look for that file in the directory
			$media_check="$media_check_eacupc/$neweacupc";
			# We'll set $textcheck to show what EAC/UPC has been entered
			$textcheck="EAC/UPC code $neweacupc";
		}
		# If $newisbn exists...
		if ($newisbn) {
			# We'll set $media_check to look for that file in the directory
			$media_check="$media_check_isbn/$newisbn";
			# We'll set $textcheck to show what ISBN has been entered
			$textcheck="ISBN code $newisbn";
		}
		print "checking for an existing entry for $textcheck<br>\n";
		# print "$media_check<br>\n";

		# There's some trickery going on below! ;) $foundentry is established as '1', but there's no $foundentry=0; around
		# the read file area below?! What gives?!
		# If the file is not present, the || &error("") part calls the error subroutine, where $foundentry=0; is established.
		# Unfortunately, variables can't be set within subroutine calls, so that's the workaround.
		$foundentry=1;
		open (media,"$basedir/$media_check") || &error("did not find an entry for $textcheck<br>forwarding to create an entry<br>");
		@in = <media>;
		close (media);

		if ($foundentry eq 1) {
			print "found that entry!<br>forwarding to edit the entry<br>";
			for $line(@in) {
				($dotype,$title,$author,$eacupc,$isbn,$type,$year) = split(/\|/,$line);
				# print "$dotype,$title,$author,$eacupc,$isbn,$type,$year<br>\n";
			}
			print "<p><META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL='/$config_adminsite?dowhat=media_add&dotype=$dotype&neweacupc=$eacupc&newisbn=$isbn&newtitle=$title&newauthor=$author&newtype=$type&newyear=$year'\">\n";
			print "<a href=\"/$config_adminsite?dowhat=media_add&dotype=$dotype&neweacupc=$eacupc&newisbn=$isbn&newtitle=$title&newauthor=$author&newtype=$type&newyear=$year\">continue</a></p>";
		} else {
			print "<p><META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL='/$config_adminsite?dowhat=media_add&dotype=$dotype&neweacupc=$neweacupc&newisbn=$newisbn&newyear=$year'\">\n";
			print "<a href=\"/$config_adminsite?dowhat=media_add&dotype=$dotype&neweacupc=$neweacupc&newisbn=$newisbn&newyear=$year\">continue</a></p>";
		}

		print "    </table>";

		# Generate the footer
		&footer;
	}

	sub config_view {
		local($e) = @_;

		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\" width=75%>\n";

		if ($e) {
			print "<tr><td colspan=3>$e</td></tr>\n";
		}

		print "    <tbody>\n";
		print "     <tr><th width=34%>&nbsp;</th><th width=33%>CURRENT VALUES</th><th width=33%>CONFIG DEFAULTS</th></tr>\n";

		if ($config_write eq 0) {$dashwrite="off";} else {$dashwrite="on";}
		if ($config_previewhide eq 0) {$dashpreviewhide="off";} else {$dashpreviewhide="on";}
		if ($config_previewshow eq 0) {$dashpreviewshow="off";} else {$dashpreviewshow="on";}
		if ($config_thesort eq 0) {$dashthesort="off";} else {$dashthesort="on";}
		if ($config_mobile eq 0) {$dashmobile="off";} else {$dashmobile="on";}

		print "     <tr class=\"grid\">\n      <th>enable write</th>\n      <td>$dashwrite</td>\n      <td>on</td>\n     </tr>\n";
		print "     <tr class=\"grid\">\n      <th>preview hidden</th>\n      <td>$dashpreviewhide</td>\n      <td>off</td>\n     </tr>\n";
		print "     <tr class=\"grid\">\n      <th>preview shown</th>\n      <td>$dashpreviewshow</td>\n      <td>off</td>\n     </tr>\n";
		print "     <tr class=\"grid\">\n      <th>sort by</th>\n      <td>$dashthesort</td>\n      <td>off</td>\n     </tr>\n";
		print "     <tr class=\"grid\">\n      <th>mobile information</th>\n      <td>$dashmobile</td>\n      <td>off</td>\n     </tr>\n";

		print "     <tr><td align=center colspan=3><a href=\"/$config_adminsite?dowhat=config_edit&dotype=$dotype&fromtype=$fromtype\">Change Configuration</a> | <a href=\"/$config_adminsite?dotype=config&dowhat=config_columns_view\">Show/Hide Headers</a></td></tr>\n";
		print "     <tr>\n";
		print "      <td style=\"text-align:left\" colspan=3>\n";
		print "      <b>enable write</b>: enables content write when on, disabled when off<br>\n";
		print "      <b>preview hidden</b>: enables content preview within HTML comments when on, off disables<br>\n";
		print "      <b>preview shown</b>: enables content preview in this window when on, disabled when off<br>\n";
		print "      <b>sort by</b>: when on, titles beginning with 'The' appear with '<i>, The</i>' at the end, off disables<br>\n";
		print "      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This applies to both the administrative and non-administrative pages, but not to the<br>\n";
		print "      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;database. This is primarily for sorting purposes.<br>\n";
		print "      <b>mobile information</b>: when on, media type services are included under the entries, off disables<br>\n";
		print "      </td>\n";
		print "     </tr>\n";
		print "    </tbody>\n   </table>\n";

		# Generate the footer
		&footer;
	}

	sub config_edit {
		print "\n   <table cellspacing=10 cellpadding=10 id=\"mytable\" width=75%>\n";
		print "     <tr><th width=34%>HEADERS</th><th width=33%>CURRENT VALUES</th><th width=33%>CONFIG DEFAULTS</td></tr>\n";

		print "    <tr class=\"grid\">\n     <th>enable write</th>\n      <td>\n";
		print "       <select name=config_write>\n";
		if ($config_write eq '0'){
			print "        <option value=\"0\" selected>off</option>\n";
		} else {
			print "        <option value=\"0\">off</option>\n";
		}
		if ($config_write eq '1'){
			print "        <option value=\"1\" selected>on</option>\n";
		} else {
			print "        <option value=\"1\">on</option>\n";
		}
		print "       </select>\n";
		print "      </td>\n      <td>on</td>\n    </tr>\n";

		print "    <tr class=\"grid\">\n     <th>preview hidden</th>\n      <td>\n";
		print "       <select name=config_previewhide>\n";
		if ($config_previewhide eq '0'){
			print "        <option value=\"0\" selected>off</option>\n";
		} else {
			print "        <option value=\"0\">off</option>\n";
		}
		if ($config_previewhide eq '1'){
			print "        <option value=\"1\" selected>on</option>\n";
		} else {
			print "        <option value=\"1\">on</option>\n";
		}
		print "       </select>\n";
		print "      </td>\n      <td>off</td>\n    </tr>\n";

		print "    <tr class=\"grid\">\n     <th>preview shown</th>\n      <td>\n";
		print "       <select name=config_previewshow>\n";
		if ($config_previewshow eq '0'){
			print "        <option value=\"0\" selected>off</option>\n";
		} else {
			print "        <option value=\"0\">off</option>\n";
		}
		if ($config_previewshow eq '1'){
			print "        <option value=\"1\" selected>on</option>\n";
		} else {
			print "        <option value=\"1\">on</option>\n";
		}
		print "       </select>\n";
		print "      </td>\n      <td>off</td>\n    </tr>\n";

		print "    <tr class=\"grid\">\n     <th>sort by</th>\n      <td>\n";
		print "       <select name=config_thesort>\n";
		if ($config_thesort eq '0'){
			print "        <option value=\"0\" selected>off</option>\n";
		} else {
			print "        <option value=\"0\">off</option>\n";
		}
		if ($config_thesort eq '1'){
			print "        <option value=\"1\" selected>on</option>\n";
		} else {
			print "        <option value=\"1\">on</option>\n";
		}
		print "       </select>\n";
		print "      </td>\n      <td>off</td>\n    </tr>\n";

		print "    <tr class=\"grid\">\n     <th>mobile information</th>\n      <td>\n";
		print "       <select name=config_mobile>\n";
		if ($config_mobile eq '0'){
			print "        <option value=\"0\" selected>off</option>\n";
		} else {
			print "        <option value=\"0\">off</option>\n";
		}
		if ($config_mobile eq '1'){
			print "        <option value=\"1\" selected>on</option>\n";
		} else {
			print "        <option value=\"1\">on</option>\n";
		}
		print "       </select>\n";
		print "      </td>\n      <td>off</td>\n    </tr>\n";

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
		print "     <input type=hidden name=dowhat value=config_write>\n     <input type=hidden name=dotype value=$dotype>\n     <input type=hidden name=fromtype value=$fromtype>\n";
		print "    </tbody>\n   </table>\n";

		# Generate the footer
		&footer;
	}

	sub config_write {
		$writenew="$editconfig_write|$editconfig_previewhide|$editconfig_previewshow|$editconfig_thesort|$editconfig_mobile|";

		if ($config_previewhide eq "1") {
			print "<!--\n";
			print "    $writenew\n";
			print "    editconfig_write: $editconfig_write\n";
			print "    editconfig_previewhide: $editconfig_previewhide\n";
			print "    editconfig_previewshow: $editconfig_previewshow\n";
			print "    editconfig_thesort: $editconfig_thesort\n";
			print "    editconfig_mobile|: $editconfig_mobile\n";
			print "-->\n";
		}
		if ($config_previewshow eq "1") {
			print "$writenew<br>\n";
			print "editconfig_write: $editconfig_write<br>";
			print "editconfig_previewhide: $editconfig_previewhide<br>";
			print "editconfig_previewshow: $editconfig_previewshow<br>";
			print "editconfig_thesort: $editconfig_thesort<br>";
			print "editconfig_mobile|: $editconfig_mobile\n";
		}
		open (WRITEINFO,"+>$basedir/$config_data") || &error("error: config_data $basedir/$config_data");
		print (WRITEINFO $writenew);
		close (WRITEINFO);
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"10;URL=/$config_adminsite?dotype=$fromtype\">\n";
		print "     <p><a href=\"/$config_adminsite?dotype=$fromtype\">main screen</a>";

		# Generate the footer
		&footer;
	}

	sub config_columns_view {
		print "  <p>\n   Each green row contains all of the headers that are available for display in the non-administrative and administrative tables.<br>\n   Below these rows are the indicators of whether those headers will be shown or hidden on the non-administrative pages.\n<br>   The white background cells below the green rows indicate that these fields are always shown,<br>\n   while the grey background cells indicate that their visibility can be turned on or off.\n  </p>\n";

		print "   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <tbody>\n";

		# Read the entry for $media_books.
		open (books,"$basedir/$media_books") || &error("error: media_books data /$media_books");
		@media_books = <books>;
		close (books);

		print "     <tr>\n     <th>BOOKS</th>\n      <th>author</th>\n      <th>title</th>\n      <th>eacupc</th>\n      <th>isbn</th>\n      <th>type</th>\n      <th>purchasedate</th>\n     </tr>\n";

		print "     <tr>\n";
		foreach $books_line(@media_books) {
			$books_line =~ s/\n//g;                                                  # Strips new line character
			$books_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
			$books_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

			($books_title,$books_author,$books_eacupc,$books_isbn,$books_type,$books_purchasedate) = split(/\|/,$books_line);

			if (substr($books_title,0,6) eq "#DATE#") {
				print "     <td><a href=\"/$config_adminsite?dotype=books&dowhat=config_columns_edit\">CHANGE</a></td>\n     <td>author</td>\n     <td>title</td>\n";
				if (($books_eacupc eq "show") || ($books_eacupc eq "#")) {print "     <td class=edit>show</td>\n";} else {print "     <td class=edit>hide</td>\n";}
				if (($books_isbn eq "show") || ($books_isbn eq "#")) {print "     <td class=edit>show</td>\n";} else {print "     <td class=edit>hide</td>\n";}
				if (($books_type eq "show") || ($books_type eq "#")) {print "     <td class=edit>show</td>\n";} else {print "     <td class=edit>hide</td>\n";}
				if (($books_purchasedate eq "show") || ($books_purchasedate eq "#")) {print "     <td class=edit>show</td>\n";} else {print "     <td class=edit>hide</td>\n";}
			}
		}
		print "     </tr>\n";
		print "    </tbody>\n";
		print "   </table>\n";

		print "   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <tbody>\n";

		# Read the entry for $media_games.
		open (games,"$basedir/$media_games") || &error("error: media_games data /$media_games");
		@media_games = <games>;
		close (games);

		print "     <tr>\n      <th>GAMES</th>\n      <th>title</th>\n      <th>eacupc</th>\n      <th>epic</th>\n      <th>steam</th>\n      <th>battlenet</th>\n      <th>origin</th>\n      <th>uplay</th>\n      <th>nes</th>\n      <th>wii</th>\n      <th>ps2</th>\n      <th>xboxone</th>\n      <th>xbox360</th>\n      <th>purchasedate</th>\n     </tr>\n";

		print "     <tr>\n";
		foreach $games_line(@media_games) {
			$games_line =~ s/\n//g;                                                  # Strips new line character
			$games_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
			$games_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

			($games_title,$games_epic,$games_steam,$games_battlenet,$games_origin,$games_uplay,$games_nes,$games_wii,$games_ps2,$games_xboxone,$games_xbox360,$games_eacupc,$games_purchasedate) = split(/\|/,$games_line);

			if (substr($games_title,0,6) eq "#DATE#") {
				print "      <td><a href=\"/$config_adminsite?dotype=games&dowhat=config_columns_edit\">CHANGE</a></td>\n      <td>title</td>\n";
				if (($games_eacupc eq "show") || ($games_eacupc eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_epic eq "show") || ($games_epic eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_steam eq "show") || ($games_steam eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_battlenet eq "show") || ($games_battlenet eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_origin eq "show") || ($games_origin eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_uplay eq "show") || ($games_uplay eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_nes eq "show") || ($games_nes eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_wii eq "show") || ($games_wii eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_ps2 eq "show") || ($games_ps2 eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_xboxone eq "show") || ($games_xboxone eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_xbox360 eq "show") || ($games_xbox360 eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($games_purchasedate eq "show") || ($games_purchasedate eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
			}
		}
		print "     </tr>\n";
		print "    </tbody>\n";
		print "   </table>\n";

		print "   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <tbody>\n";

		# Read the entry for $media_music.
		open (music,"$basedir/$media_music") || &error("error: media_music data /$media_music");
		@media_music = <music>;
		close (music);

		print "     <tr>\n      <th>MUSIC</th>\n      <th>artist</th>\n      <th>title</th>\n     <th>eacupc</th>\n      <th>cd</th>\n      <th>amazon</th>\n      <th>djbooth</th>\n      <th>googleplay</th>\n      <th>groove</th>\n      <th>itunes</th>\n      <th>reverbnation</th>\n      <th>rhapsody</th>\n      <th>topspin</th>\n      <th>purchasedate</th>\n     </tr>\n";

		print "     <tr>\n";
		foreach $music_line(@media_music) {
			$music_line =~ s/\n//g;                                                  # Strips new line character
			$music_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
			$music_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

			($music_artist,$music_title,$music_eacupc,$music_cd,$music_amazon,$music_djbooth,$music_googleplay,$music_groove,$music_itunes,$music_reverbnation,$music_topspin,$music_rhapsody,$music_purchasedate) = split(/\|/,$music_line);

			if (substr($music_artist,0,6) eq "#DATE#") {
				print "      <td><a href=\"/$config_adminsite?dotype=music&dowhat=config_columns_edit\">CHANGE</a></td>\n      <td>artist</td>\n      <td>title</td>\n";
				if (($music_eacupc eq "show") || ($music_eacupc eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_cd eq "show") || ($music_cd eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_amazon eq "show") || ($music_amazon eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_djbooth eq "show") || ($music_djbooth eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_googleplay eq "show") || ($music_googleplay eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_groove eq "show") || ($music_groove eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_itunes eq "show") || ($music_itunes eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_reverbnation eq "show") || ($music_reverbnation eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_rhapsody eq "show") || ($music_rhapsody eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_topspin eq "show") || ($music_topspin eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($music_purchasedate eq "show") || ($music_purchasedate eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
			}
		}
		print "     </tr>\n";
		print "    </tbody>\n";
		print "   </table>\n";

		print "   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <tbody>\n";

		# Read the entry for $media_videos.
		open (video,"$basedir/$media_videos") || &error("error: media_videos data /$media_videos");
		@media_videos = <video>;
		close (video);

		print "     <tr>\n      <th>VIDEOS</th>\n      <th>title</th>\n      <th>year</th>\n      <th>eacupc</th>\n      <th>type</th>\n      <th>media</th>\n      <th>amazon</th>\n      <th>disneyanywhere</th>\n      <th>googleplay</th>\n      <th>itunes</th>\n      <th>uvvu</th>\n      <th>isbn</th>\n      <th>microsoft</th>\n      <th>purchasedate</th>\n     </tr>\n";
 
		print "     <tr>\n";
		foreach $video_line(@media_videos) {
			$video_line =~ s/\n//g;                                                  # Strips new line character
			$video_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
			$video_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

			($video_title,$video_type,$video_media,$video_amazon,$video_disneyanywhere,$video_googleplay,$video_itunes,$video_uvvu,$video_eacupc,$video_isbn,$video_microsoft,$video_year,$video_purchasedate) = split(/\|/,$video_line);

			if (substr($video_title,0,6) eq "#DATE#") {
				print "      <td><a href=\"/$config_adminsite?dotype=videos&dowhat=config_columns_edit\">CHANGE</a></td>\n      <td>title</td>\n      <td>year</td>\n";
				if (($video_eacupc eq "show") || ($video_eacupc eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_type eq "show") || ($video_type eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_media eq "show") || ($video_media eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_amazon eq "show") || ($video_amazon eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_disneyanywhere eq "show") || ($video_disneyanywhere eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_googleplay eq "show") || ($video_googleplay eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_itunes eq "show") || ($video_itunes eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_uvvu eq "show") || ($video_uvvu eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_isbn eq "show") || ($video_isbn eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_microsoft eq "show") || ($video_microsoft eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
				if (($video_purchasedate eq "show") || ($video_purchasedate eq "#")) {print "      <td class=edit>show</td>\n";} else {print "      <td class=edit>hide</td>\n";}
			}
		}
		print "     </tr>\n";
		print "    </tbody>\n";
		print "   </table>";

		# Generate the footer
		&footer;
	}

	sub config_columns_edit {
		print "   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <tbody>\n";

		if (($dotype eq "books") || ($dotype eq "music") || ($dotype eq "videos")) {$columns=3;} else {$columns=2;}
		if ($dotype eq "books") {
			# Read the entry for $media_books.
			open (books,"$basedir/$media_books") || &error("error: media_books data /$media_books");
			@media_books = <books>;
			close (books);

			print "     <tr>\n     <th>BOOKS</th>\n      <th>author</th>\n      <th>title</th>\n      <th>eacupc</th>\n      <th>isbn</th>\n      <th>type</th>\n      <th>purchasedate</th>\n     </tr>\n";

			print "     <tr>\n";
			foreach $books_line(@media_books) {
				$books_line =~ s/\n//g;                                                  # Strips new line character
				$books_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$books_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($books_title,$books_author,$books_eacupc,$books_isbn,$books_type,$books_purchasedate) = split(/\|/,$books_line);

				if (substr($books_title,0,6) eq "#DATE#") {
					print "      <td></td>\n      <td>author</td>\n      <td>title</td>\n";

					if (($books_eacupc eq "show") || ($books_eacupc eq "#")) {$books_eacupc_select_on="selected";} else {$books_eacupc_select_off="selected";}
					print "      <td class=edit><select name=column_books_eacupc><option value=\"show\" $books_eacupc_select_on>show</option><option value=\"hide\" $books_eacupc_select_off>hide</option></select></td>\n";
					$columns++;

					if (($books_isbn eq "show") || ($books_isbn eq "#")) {$books_isbn_select_on="selected";} else {$books_isbn_select_off="selected";}
					print "      <td class=edit><select name=column_books_isbn><option value=\"show\" $books_isbn_select_on>show</option><option value=\"hide\" $books_isbn_select_off>hide</option></select></td>\n";
					$columns++;

					if (($books_type eq "show") || ($books_type eq "#")) {$books_type_select_on="selected";} else {$books_type_select_off="selected";}
					print "      <td class=edit><select name=column_books_type><option value=\"show\" $books_type_select_on>show</option><option value=\"hide\" $books_type_select_off>hide</option></select></td>\n";
					$columns++;

					if (($books_purchasedate eq "show") || ($books_purchasedate eq "#")) {$books_purchasedate_select_on="selected";} else {$books_purchasedate_select_off="selected";}
					print "      <td class=edit><select name=column_books_purchasedate><option value=\"show\" $books_purchasedate_select_on>show</option><option value=\"hide\" $books_purchasedate_select_off>hide</option></select></td>\n";
					$columns++;
				}
			}
			print "     </tr>\n";
		} elsif ($dotype eq "games") {
			# Read the entry for $media_games.
			open (games,"$basedir/$media_games") || &error("error: media_games data /$media_games");
			@media_games = <games>;
			close (games);

			print "     <tr>\n      <th>GAMES</th>      <th>title</th>      <th>eacupc</th>      <th>epic</th>      <th>steam</th>      <th>battlenet</th>      <th>origin</th>      <th>uplay</th>      <th>nes</th>      <th>wii</th>      <th>ps2</th>      <th>xboxone</th>      <th>xbox360</th>      <th>purchasedate</th>     </tr>";

			print "     <tr>\n";
			foreach $games_line(@media_games) {
				$games_line =~ s/\n//g;                                                  # Strips new line character
				$games_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$games_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($games_title,$games_epic,$games_steam,$games_battlenet,$games_origin,$games_uplay,$games_nes,$games_wii,$games_ps2,$games_xboxone,$games_xbox360,$games_eacupc,$games_purchasedate) = split(/\|/,$games_line);

				if (substr($games_title,0,6) eq "#DATE#") {
					print "      <td></td>\n      <td>title</td>\n";

					if (($games_eacupc eq "show") || ($games_eacupc eq "#")) {$games_eacupc_select_on="selected";} else {$games_eacupc_select_off="selected";}
					print "      <td class=edit><select name=column_games_eacupc><option value=\"show\" $games_eacupc_select_on>show</option><option value=\"hide\" $games_eacupc_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_epic eq "show") || ($games_epic eq "#")) {$games_epic_select_on="selected";} else {$games_epic_select_off="selected";}
					print "      <td class=edit><select name=column_games_epic><option value=\"show\" $books_eacupc_select_on>show</option><option value=\"hide\" $games_epic_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_steam eq "show") || ($games_steam eq "#")) {$games_steam_select_on="selected";} else {$games_steam_select_off="selected";}
					print "      <td class=edit><select name=column_games_steam><option value=\"show\" $games_steam_select_on>show</option><option value=\"hide\" $games_steam_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_battlenet eq "show") || ($games_battlenet eq "#")) {$games_battlenet_select_on="selected";} else {$games_battlenet_select_off="selected";}
					print "      <td class=edit><select name=column_games_battlenet><option value=\"show\" $games_battlenet_select_on>show</option><option value=\"hide\" $games_battlenet_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_origin eq "show") || ($games_origin eq "#")) {$games_origin_select_on="selected";} else {$games_origin_select_off="selected";}
					print "      <td class=edit><select name=column_games_origin><option value=\"show\" $games_origin_select_on>show</option><option value=\"hide\" $games_origin_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_uplay eq "show") || ($games_uplay eq "#")) {$games_uplay_select_on="selected";} else {$games_uplay_select_off="selected";}
					print "      <td class=edit><select name=column_games_uplay><option value=\"show\" $games_uplay_select_on>show</option><option value=\"hide\" $games_uplay_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_nes eq "show") || ($games_nes eq "#")) {$games_nes_select_on="selected";} else {$games_nes_select_off="selected";}
					print "      <td class=edit><select name=column_games_nes><option value=\"show\" $games_nes_select_on>show</option><option value=\"hide\" $games_nes_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_wii eq "show") || ($games_wii eq "#")) {$games_wii_select_on="selected";} else {$games_wii_select_off="selected";}
					print "      <td class=edit><select name=column_games_wii><option value=\"show\" $games_wii_select_on>show</option><option value=\"hide\" $games_wii_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_ps2 eq "show") || ($games_ps2 eq "#")) {$games_ps2_select_on="selected";} else {$games_ps2_select_off="selected";}
					print "      <td class=edit><select name=column_games_ps2><option value=\"show\" $games_ps2_select_on>show</option><option value=\"hide\" $games_ps2_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_xboxone eq "show") || ($games_xboxone eq "#")) {$games_xboxone_select_on="selected";} else {$games_xboxone_select_off="selected";}
					print "      <td class=edit><select name=column_games_xboxone><option value=\"show\" $games_xboxone_select_on>show</option><option value=\"hide\" $games_xboxone_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_xbox360 eq "show") || ($games_xbox360 eq "#")) {$games_xbox360_select_on="selected";} else {$games_xbox360_select_off="selected";}
					print "      <td class=edit><select name=column_games_xbox360><option value=\"show\" $games_xbox360_select_on>show</option><option value=\"hide\" $games_xbox360_select_off>hide</option></select></td>\n";
					$columns++;

					if (($games_purchasedate eq "show") || ($games_purchasedate eq "#")) {$games_purchasedate_select_on="selected";} else {$games_purchasedate_select_off="selected";}
					print "      <td class=edit><select name=column_games_purchasedate><option value=\"show\" $games_purchasedate_select_on>show</option><option value=\"hide\" $games_purchasedate_select_off>hide</option></select></td>\n";
					$columns++;
				}
			}
			print "     </tr>\n";
		} elsif ($dotype eq "music") {
			# Read the entry for $media_music.
			open (music,"$basedir/$media_music") || &error("error: media_music data /$media_music");
			@media_music = <music>;
			close (music);

			print "     <tr>\n      <th>MUSIC</th>      <th>artist</th>      <th>title</th>     <th>eacupc</th>      <th>cd</th>      <th>amazon</th>      <th>djbooth</th>      <th>googleplay</th>     <th>groove</th>      <th>itunes</th>      <th>reverbnation</th>      <th>rhapsody</th>      <th>topspin</th>      <th>purchasedate</th>\n     </tr>";

			print "<tr>\n";
			foreach $music_line(@media_music) {
				$music_line =~ s/\n//g;                                                  # Strips new line character
				$music_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$music_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($music_artist,$music_title,$music_eacupc,$music_cd,$music_amazon,$music_djbooth,$music_googleplay,$music_groove,$music_itunes,$music_reverbnation,$music_topspin,$music_rhapsody,$music_purchasedate) = split(/\|/,$music_line);

				if (substr($music_artist,0,6) eq "#DATE#") {
					print "<td></td><td>artist</td><td>title</td>";
					if (($music_eacupc eq "show") || ($music_eacupc eq "#")) {$music_eacupc_select_on="selected";} else {$music_eacupc_select_off="selected";}
					print "      <td class=edit><select name=column_music_eacupc><option value=\"show\" $music_eacupc_select_on>show</option><option value=\"hide\" $music_eacupc_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_cd eq "show") || ($music_cd eq "#")) {$music_cd_select_on="selected";} else {$music_cd_select_off="selected";}
					print "      <td class=edit><select name=column_music_cd><option value=\"show\" $music_cd_select_on>show</option><option value=\"hide\" $music_cd_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_amazon eq "show") || ($music_amazon eq "#")) {$music_amazon_select_on="selected";} else {$music_amazon_select_off="selected";}
					print "      <td class=edit><select name=column_music_amazon><option value=\"show\" $music_amazon_select_on>show</option><option value=\"hide\" $music_amazon_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_djbooth eq "show") || ($music_djbooth eq "#")) {$music_djbooth_select_on="selected";} else {$music_djbooth_select_off="selected";}
					print "      <td class=edit><select name=column_music_djbooth><option value=\"show\" $music_djbooth_select_on>show</option><option value=\"hide\" $music_djbooth_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_googleplay eq "show") || ($music_googleplay eq "#")) {$music_googleplay_select_on="selected";} else {$music_googleplay_select_off="selected";}
					print "      <td class=edit><select name=column_music_googleplay><option value=\"show\" $music_googleplay_select_on>show</option><option value=\"hide\" $music_googleplay_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_groove eq "show") || ($music_groove eq "#")) {$music_groove_select_on="selected";} else {$music_groove_select_off="selected";}
					print "      <td class=edit><select name=column_music_groove><option value=\"show\" $music_groove_select_on>show</option><option value=\"hide\" $music_groove_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_itunes eq "show") || ($music_itunes eq "#")) {$music_itunes_select_on="selected";} else {$music_itunes_select_off="selected";}
					print "      <td class=edit><select name=column_music_itunes><option value=\"show\" $music_itunes_select_on>show</option><option value=\"hide\" $music_itunes_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_reverbnation eq "show") || ($music_reverbnation eq "#")) {$music_reverbnation_select_on="selected";} else {$music_reverbnation_select_off="selected";}
					print "      <td class=edit><select name=column_music_reverbnation><option value=\"show\" $music_reverbnation_select_on>show</option><option value=\"hide\" $music_reverbnation_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_rhapsody eq "show") || ($music_rhapsody eq "#")) {$music_rhapsody_select_on="selected";} else {$music_rhapsody_select_off="selected";}
					print "      <td class=edit><select name=column_music_rhapsody><option value=\"show\" $music_rhapsody_select_on>show</option><option value=\"hide\" $music_rhapsody_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_topspin eq "show") || ($music_topspin eq "#")) {$gmusic_topspin_select_on="selected";} else {$music_topspin_select_off="selected";}
					print "      <td class=edit><select name=column_music_topspin><option value=\"show\" $music_topspin_select_on>show</option><option value=\"hide\" $music_topspin_select_off>hide</option></select></td>\n";
					$columns++;

					if (($music_purchasedate eq "show") || ($music_purchasedate eq "#")) {$music_purchasedate_select_on="selected";} else {$music_purchasedate_select_off="selected";}
					print "      <td class=edit><select name=column_music_purchasedate><option value=\"show\" $music_purchasedate_select_on>show</option><option value=\"hide\" $music_purchasedate_select_off>hide</option></select></td>\n";
					$columns++;
				}
			}
			print "     </tr>\n";
		} elsif ($dotype eq "videos") {
			# Read the entry for $media_videos.
			open (video,"$basedir/$media_videos") || &error("error: media_videos data /$media_videos");
			@media_videos = <video>;
			close (video);

			print "     <tr>\n      <th>VIDEOS</th>      <th>title</th>      <th>year</th>      <th>eacupc</th>      <th>type</th>      <th>media</th>      <th>amazon</th>      <th>disneyanywhere</th>      <th>googleplay</th>     <th>itunes</th>      <th>uvvu</th>      <th>isbn</th>      <th>microsoft</th>      <th>purchasedate</th>     </tr>";
	 
			print "<tr>\n";
			foreach $video_line(@media_videos) {
				$video_line =~ s/\n//g;                                                  # Strips new line character
				$video_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$video_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($video_title,$video_type,$video_media,$video_amazon,$video_disneyanywhere,$video_googleplay,$video_itunes,$video_uvvu,$video_eacupc,$video_isbn,$video_microsoft,$video_year,$video_purchasedate) = split(/\|/,$video_line);

				if (substr($video_title,0,6) eq "#DATE#") {
					print "<td></td><td>title</td><td>year</td>";
					if (($video_eacupc eq "show") || ($video_eacupc eq "#")) {$video_eacupc_select_on="selected";} else {$video_eacupc_select_off="selected";}
					print "      <td class=edit><select name=column_video_eacupc><option value=\"show\" $video_eacupc_select_on>show</option><option value=\"hide\" $video_eacupc_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_type eq "show") || ($video_type eq "#")) {$video_type_select_on="selected";} else {$video_type_select_off="selected";}
					print "      <td class=edit><select name=column_video_type><option value=\"show\" $video_type_select_on>show</option><option value=\"hide\" $video_type_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_media eq "show") || ($video_media eq "#")) {$video_media_select_on="selected";} else {$video_media_select_off="selected";}
					print "      <td class=edit><select name=column_video_media><option value=\"show\" $video_media_select_on>show</option><option value=\"hide\" $video_media_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_amazon eq "show") || ($video_amazon eq "#")) {$video_amazon_select_on="selected";} else {$video_amazon_select_off="selected";}
					print "      <td class=edit><select name=column_video_amazon><option value=\"show\" $video_amazon_select_on>show</option><option value=\"hide\" $video_amazon_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_disneyanywhere eq "show") || ($video_disneyanywhere eq "#")) {$video_disneyanywhere_select_on="selected";} else {$video_disneyanywhere_select_off="selected";}
					print "      <td class=edit><select name=column_video_disneyanywhere><option value=\"show\" $video_disneyanywhere_select_on>show</option><option value=\"hide\" $video_disneyanywhere_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_googleplay eq "show") || ($video_googleplay eq "#")) {$video_googleplay_select_on="selected";} else {$video_googleplay_select_off="selected";}
					print "      <td class=edit><select name=column_video_googleplay><option value=\"show\" $video_googleplay_select_on>show</option><option value=\"hide\" $video_googleplay_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_itunes eq "show") || ($video_itunes eq "#")) {$video_itunes_select_on="selected";} else {$video_itunes_select_off="selected";}
					print "      <td class=edit><select name=column_video_itunes><option value=\"show\" $video_itunes_select_on>show</option><option value=\"hide\" $video_itunes_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_uvvu eq "show") || ($video_uvvu eq "#")) {$video_uvvu_select_on="selected";} else {$video_uvvu_select_off="selected";}
					print "      <td class=edit><select name=column_video_uvvu><option value=\"show\" $video_uvvu_select_on>show</option><option value=\"hide\" $video_uvvu_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_isbn eq "show") || ($video_isbn eq "#")) {$video_isbn_select_on="selected";} else {$video_isbn_select_off="selected";}
					print "      <td class=edit><select name=column_video_isbn><option value=\"show\" $video_isbn_select_on>show</option><option value=\"hide\" $video_isbn_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_microsoft eq "show") || ($video_microsoft eq "#")) {$video_microsoft_select_on="selected";} else {$video_microsoft_select_off="selected";}
					print "      <td class=edit><select name=column_video_microsoft><option value=\"show\" $video_microsoft_select_on>show</option><option value=\"hide\" $video_microsoft_select_off>hide</option></select></td>\n";
					$columns++;

					if (($video_purchasedate eq "show") || ($video_purchasedate eq "#")) {$video_purchasedate_select_on="selected";} else {$video_purchasedate_select_off="selected";}
					print "      <td class=edit><select name=column_video_purchasedate><option value=\"show\" $video_purchasedate_select_on>show</option><option value=\"hide\" $video_purchasedate_select_off>hide</option></select></td>\n";
					$columns++;
				}
			}
			print "     </tr>\n";
		}

		print "     <tr>\n      <td colspan=$columns align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "     <input type=hidden name=dowhat value=config_columns_write>\n";
		print "     <input type=hidden name=dotype value=$dotype>\n";
		print "     <input type=hidden name=fromtype value=config_columns_view>\n";
		print "    </tbody>\n";
		print "   </table>";

		# Generate the footer
		&footer;
	}

	sub config_columns_write{
		print "   <table cellspacing=10 cellpadding=10 id=\"mytable\">\n";
		print "    <tbody>\n";
		print "     <tr>\n     <td>\n";

		if (($dotype eq "books") || ($dotype eq "music") || ($dotype eq "videos")) {$columns=3;} else {$columns=2;}
		if ($dotype eq "books") {
			$writedatabase=$media_books;
			# Read the entry for $media_books.
			open (books,"$basedir/$media_books") || &error("error: media_books data /$media_books");
			@media_books = <books>;
			close (books);

			foreach $books_line(@media_books) {
				$books_line =~ s/\n//g;                                                  # Strips new line character
				$books_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$books_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($books_title,$books_author,$books_eacupc,$books_isbn,$books_type,$books_purchasedate) = split(/\|/,$books_line);

				if (substr($books_title,0,6) eq "#DATE#") {
					$dbentry="$books_title|$booksauthor|";
					if ($column_books_eacupc eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_books_isbn eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_books_type eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_books_purchasedate eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					push(@database_entries,"$dbentry\n");
				} else {
					push(@database_entries,"$books_title|$books_author|$books_eacupc|$books_isbn|$books_type|$books_purchasedate|\n");
				}
			}
		} elsif ($dotype eq "games") {
			$writedatabase=$media_games;
			# Read the entry for $media_games.
			open (games,"$basedir/$media_games") || &error("error: media_games data /$media_games");
			@media_games = <games>;
			close (games);

			foreach $games_line(@media_games) {
				$games_line =~ s/\n//g;                                                  # Strips new line character
				$games_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$games_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($games_title,$games_epic,$games_steam,$games_battlenet,$games_origin,$games_uplay,$games_nes,$games_wii,$games_ps2,$games_xboxone,$games_xbox360,$games_eacupc,$games_purchasedate) = split(/\|/,$games_line);

				if (substr($games_title,0,6) eq "#DATE#") {
					$dbentry="$games_title|";
					if ($column_games_epic eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_steam eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_battlenet eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_origin eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_uplay eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_nes eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_wii eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_ps2 eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_xboxone eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_xbox360 eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_eacupc eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_games_purchasedate eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					push(@database_entries,"$dbentry\n");
				} else {
					push(@database_entries,"$games_title|$games_epic|$games_steam|$games_battlenet|$games_origin|$games_uplay|$games_nes|$games_wii|$games_ps2|$games_xboxone|$games_xbox360|$games_eacupc|$games_purchasedate|\n");
				}
			}
		} elsif ($dotype eq "music") {
			$writedatabase=$media_music;
			# Read the entry for $media_music.
			open (music,"$basedir/$media_music") || &error("error: media_music data /$media_music");
			@media_music = <music>;
			close (music);

			foreach $music_line(@media_music) {
				$music_line =~ s/\n//g;                                                  # Strips new line character
				$music_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$music_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($music_artist,$music_title,$music_eacupc,$music_cd,$music_amazon,$music_djbooth,$music_googleplay,$music_groove,$music_itunes,$music_reverbnation,$music_topspin,$music_rhapsody,$music_purchasedate) = split(/\|/,$music_line);

				if (substr($music_artist,0,6) eq "#DATE#") {
					$dbentry="$music_artist|$music_title|";
					if ($column_music_eacupc eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_cd eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_amazon eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_djbooth eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_googleplay eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_groove eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_itunes eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_reverbnation eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_rhapsody eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_topspin eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_music_purchasedate eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					push(@database_entries,"$dbentry\n");
				} else {
					push(@database_entries,"$music_artist|$music_title|$music_eacupc|$music_cd|$music_amazon|$music_djbooth|$music_googleplay|$music_groove|$music_itunes|$music_reverbnation|$music_topspin|$music_rhapsody|$music_purchasedate|\n");
				}
			}
		} elsif ($dotype eq "videos") {
			$writedatabase=$media_videos;
			# Read the entry for $media_videos.
			open (video,"$basedir/$media_videos") || &error("error: media_videos data /$media_videos");
			@media_videos = <video>;
			close (video);

			foreach $video_line(@media_videos) {
				$video_line =~ s/\n//g;                                                  # Strips new line character
				$video_line =~ tr/+/ /;                                                  # Swaps plus signs for spaces
				$video_line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;        # Swap URIencoded characters for their real characters

				($video_title,$video_type,$video_media,$video_amazon,$video_disneyanywhere,$video_googleplay,$video_itunes,$video_uvvu,$video_eacupc,$video_isbn,$video_microsoft,$video_year,$video_purchasedate) = split(/\|/,$video_line);

				if (substr($video_title,0,6) eq "#DATE#") {
					$dbentry="$video_title|";
					if ($column_video_type eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_media eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_amazon eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_disneyanywhere eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_googleplay eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_itunes eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_uvvu eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_eacupc eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_isbn eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					if ($column_video_microsoft eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					$dbentry.="$video_year|";
					if ($column_video_purchasedate eq "show") {$dbentry.="show|";} else {$dbentry.="hide|";}
					push(@database_entries,"$dbentry\n");
				} else {
					push(@database_entries,"$video_title|$video_type|$video_media|$video_amazon|$video_disneyanywhere|$video_googleplay|$video_itunes|$video_uvvu|$video_eacupc|$video_isbn|$video_microsoft|$video_year|$video_purchasedate|\n");
				}
			}
		}

		if ($config_previewshow eq "1") {
			print "<p><b>database_entries</b>: <div style=\"text-align:left;width:700px;\">\n";
			foreach (@database_entries) {
				print "$_<br>\n";
			}
			print "</div></p>\n";
		}


		# If $config_write is equal to "1", then writing is enabled
		if ($config_write eq "1") {
			open (WRITEINFO,">$basedir/$writedatabase") || &error("error: writedatabase $writedatabases<br>");
			print (WRITEINFO @database_entries);
			close (WRITEINFO);
			print "Updated table header visibility!<br>";
		}

		print "      </td>\n";
		print "     </tr>\n";
		print "    </tbody>\n";
		print "   </table>";

		# Forward you back to the media database table
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"$wait;URL=/$config_adminsite?dowhat=config_columns_view&dotype=config\">\n";
		print "     <p><a href=\"/$config_adminsite?dowhat=config_columns_view&dotype=config\">main screen</a>";

		# Generate the footer
		&footer;
	}

	sub eacupcisbn_generate {
		if ($continue ne 'Yes') {
			print "\n   <P>Continuing this action will generate a database to compare your entries against the EAC, UPC, and ISBN data.<br><br>\n";
			print "   Are you sure you want to do this?</P>\n";
			print "   <input type=submit name=continue value=Yes>\n   <input type=button value=No onClick=\"history.back()\">\n   <input type=hidden name=dotype value=eacupcisbn>\n   <input type=hidden name=dowhat value=eacupcisbn_generate>\n   <input type=hidden name=showline value=\"$showline\">\n";

			# Generate footer
			&footer;
		}

		open (media,"$basedir/$media_books") || &error("error: media_books /$media_books");
		@in = <media>;
		close (media);

		print "\n   <table cellspacing=10 cellpadding=10>\n";

		$mediacodesdb="";

		foreach $line(@in) {
			($title,$author,$eacupc,$isbn,$type,$purchasedate) = split(/\|/,$line);
			$mediawrite_books="books|$title|$author|$eacupc|$isbn|$type||";
			if (substr($title,0,6) ne "#DATE#") {
				if ($isbn ne "") {
					#print "ISBN: $mediawrite_books $basedir/$media_check_isbn/$isbn<br>";
					unless (-e "$basedir/$media_check_isbn/$isbn") {
						open (WRITEINFO,"+>$basedir/$media_check_isbn/$isbn") || &error("error: mediaitem $basedir/$media_check_isbn/$isbn<br>");
						print (WRITEINFO $mediawrite_books);
						close (WRITEINFO);
					}
				}

				if ($eacupc ne "") {
					#print "EAC/UPC: $mediawrite_books<br>";
					unless (-e "$basedir/$media_check_eacupc/$eacupc") {
						open (WRITEINFO,"+>$basedir/$media_check_eacupc/$eacupc") || &error("error: mediaitem $basedir/$media_check_eacupc/$eacupc<br>");
						print (WRITEINFO $mediawrite_books);
						close (WRITEINFO);
					}
				}

				if (($isbn ne "") || ($eacupc ne "")) {
					push(@eacupcisbn_db,$mediawrite_books."\n");
				}
			}
		}

		open (media,"$basedir/$media_games") || &error("error: media_games /$media_games");
		@in = <media>;
		close (media);

		foreach $line(@in) {
			($title,$epic,$steam,$battlenet,$origin,$uplay,$nes,$wii,$ps2,$xboxone,$xbox360,$eacupc,$purchasedate) = split(/\|/,$line);
			$mediawrite_games="games|$title||$eacupc||||";
			if (substr($title,0,6) ne "#DATE#") {
				if ($eacupc ne "") {
					unless (-e "$basedir/$media_check_eacupc/$eacupc") {
						#print "EAC/UPC: $mediawrite_games<br>";
						open (WRITEINFO,"+>$basedir/$media_check_eacupc/$eacupc") || &error("error: mediaitem $basedir/$media_check_eacupc/$eacupc<br>");
						print (WRITEINFO $mediawrite_games);
						close (WRITEINFO);
					}
				}

				if ($eacupc ne "") {
					push(@eacupcisbn_db,$mediawrite_games."\n");
				}
			}
		}

		open (media,"$basedir/$media_music") || &error("error: media_music /$media_music");
		@in = <media>;
		close (media);

		foreach $line(@in) {
			($artist,$title,$eacupc,$cd,$amazon,$djbooth,$googleplay,$groove,$itunes,$reverbnation,$topspin,$rhapsody,$purchasedate) = split(/\|/,$line);
			$mediawrite_music="music|$title|$artist|$eacupc||||";
			if (substr($artist,0,6) ne "#DATE#") {
				if ($eacupc ne "") {
					unless (-e "$basedir/$media_check_eacupc/$eacupc") {
						#print "EAC/UPC: $mediawrite_music<br>";
						open (WRITEINFO,"+>$basedir/$media_check_eacupc/$eacupc") || &error("error: mediaitem $basedir/$media_check_eacupc/$eacupc<br>");
						print (WRITEINFO $mediawrite_music);
						close (WRITEINFO);
					}
				}

				if ($eacupc ne "") {
					push(@eacupcisbn_db,$mediawrite_music."\n");
				}
			}
		}

		open (media,"$basedir/$media_videos") || &error("error: media_videos /$media_videos");
		@in = <media>;
		close (media);

		foreach $line(@in) {
			($title,$type,$media,$amazon,$disneyanywhere,$googleplay,$itunes,$uvvu,$eacupc,$isbn,$microsoft,$year,$purchasedate) = split(/\|/,$line);
			$mediawrite_videos="videos|$title||$eacupc|$isbn|$type|$year|";
			if (substr($title,0,6) ne "#DATE#") {
				if ($isbn ne "") {
					unless (-e "$basedir/$media_check_isbn/$isbn") {
						#print "ISBN: $mediawrite_videos<br>";
						open (WRITEINFO,"+>$basedir/$media_check_isbn/$isbn") || &error("error: mediaitem $basedir/$media_check_isbn/$isbn<br>");
						print (WRITEINFO $mediawrite_videos);
						close (WRITEINFO);
					}
				}

				if ($eacupc ne "") {
					unless (-e "$basedir/$media_check_eacupc/$eacupc") {
						#print "EAC/UPC: $mediawrite_videos<br>";
						open (WRITEINFO,"+>$basedir/$media_check_eacupc/$eacupc") || &error("error: mediaitem /$media_check_eacupc/$eacupc<br>");
						print (WRITEINFO $mediawrite_videos);
						close (WRITEINFO);
					}
				}

				if (($isbn ne "") || ($eacupc ne "")) {
					push(@eacupcisbn_db,$mediawrite_videos."\n");
				}
			}
		}

		print "    </tbody>\n";
		print "   </table>";

		@sorted_eacupcisbn_db = sort @eacupcisbn_db;
		if ($config_write eq "1") {
			open (WRITEINFO,">$basedir/$media_eacupcisbndb") || &error("error: media_eacupcisbndb /media_eacupcisbndb");
			print (WRITEINFO @sorted_eacupcisbn_db);
			close (WRITEINFO);
		}

		print "   <p>\n    <b>sorted_eacupcisbn_db</b>:\n    <div style=\"text-align:left;width:800px;\">\n";
		foreach (@sorted_eacupcisbn_db) {
			$_ =~ s/[\r\n]+$//;
			print "     $_<br>\n";
		}
		print "    </div>\n   </p>\n";

		# Generate the footer
		&footer;
	}

	sub eacupcisbn_compare {
		open (media,"$basedir/$media_eacupcisbndb") || &error("error: media_eacupcisbndb $media_eacupcisbndb. Select <b>Generate Database</b> above to create your database for comparison.");
		@in = <media>;
		close (media);

		$count_books=0;
		$count_music=0;
		$count_games=0;
		$count_videos=0;

		print "\n   <table cellspacing=5 cellpadding=5 border=1 id=\"mytable\">\n";

		foreach $line(@in) {
			($entry1,$entry2,$entry3,$entry4,$entry5,$entry6,$entry7) = split(/\|/,$line);
			if ($entry1 eq "books") {
				if ($count_books < 1) {print "    <thead>\n     <tr><th>media</th><th>title</th><th>author</th><th>eac/upc</th></th><th>isbn</th><th>type</th><th></th></tr>\n    </thead>\n    <tbody>\n";$sections++;}
				$count_books++;
			} elsif ($entry1 eq "games") {
				if ($count_games < 1) {print "     <tr><td colspan=$columns></td></tr>\n    </tbody>\n";print "    <thead>\n     <tr><th>media</th><th>title</th><th></th><th>eac/upc</th><th></th><th></th><th></th></tr>\n    </thead>\n    <tbody>\n";$sections++;}
				$count_games++;
			} elsif ($entry1 eq "music") {
				if ($count_music < 1) {print "     <tr><td colspan=$columns></td></tr>\n    </tbody>\n";print "    <thead>\n     <tr><th>media</th><th>title</th><th>artist</th><th>eac/upc</th><th>isbn</th><th></th><th></th></tr>\n    </thead>\n    <tbody>\n";$sections++;}
				$count_music++;
			} elsif ($entry1 eq "videos") {
				if ($count_videos < 1) {print "     <tr><td colspan=$columns></td></tr>\n    </tbody>\n";print "    <thead>\n     <tr><th>media</th><th>title</th><th></th><th>eac/upc</th><th>isbn</th><th>type</th><th>year</th></tr>\n    </thead>\n    <tbody>\n";$sections++;}
				$count_videos++;
			}

			print "     <tr><td>$entry1</td><td>$entry2</td><td>$entry3</td><td>$entry4</td><td>$entry5</td><td>$entry6</td><td>$entry7</td></tr>\n";

			if ($entry4) {
				open (eacupc,"$basedir/$media_check_eacupc/$entry4") || &error("errorEACUPC: $basedir/$media_check_eacupc/$entry4");
				@readeacupc = <eacupc>;
				close (eacupc);
				for $eacupc(@readeacupc) {
					($checkeacupcentry1,$checkeacupcentry2,$checkeacupcentry3,$checkeacupcentry4,$checkeacupcentry5,$checkeacupcentry6,$checkeacupcentry7) = split(/\|/,$eacupc);
					if ($checkeacupcentry1 eq $entry1) {$entry1class="good";} else {$entry1class="bad";}
					if ($checkeacupcentry2 eq $entry2) {$entry2class="good";} else {$entry2class="bad";}
					if ($checkeacupcentry3 eq $entry3) {$entry3class="good";} else {$entry3class="bad";}
					if ($checkeacupcentry4 eq $entry4) {$entry4class="good";} else {$entry4class="bad";}
					if ($checkeacupcentry5 eq $entry5) {$entry5class="good";} else {$entry5class="bad";}
					if ($checkeacupcentry6 eq $entry6) {$entry6class="good";} else {$entry6class="bad";}
					if ($checkeacupcentry7 eq $entry7) {$entry7class="good";} else {$entry7class="bad";}
					print "     <tr><td class=$entry1class>$checkeacupcentry1</td><td class=$entry2class>$checkeacupcentry2</td><td class=$entry3class>$checkeacupcentry3</td><td class=$entry4class><a href=\"/$config_eacupcisbnsite?dowhat=eacupc_edit&dotype=eacupcisbn&fromtype=eacupcisbn_compare&entry=$checkeacupcentry4&showline=$line\">$checkeacupcentry4</a></td><td class=$entry5class>$checkeacupcentry5</td><td class=$entry6class>$checkeacupcentry6</td><td class=$entry7class>$checkeacupcentry7</td></tr>\n";
				}
			}
			if ($entry5) {
				open (isbn,"$basedir/$media_check_isbn/$entry5") || &error("errorISBN: $basedir/$media_check_isbn/$entry5");
				@readisbn = <isbn>;
				close (isbn);
				for $isbn(@readisbn) {
					($checkisbnentry1,$checkisbnentry2,$checkisbnentry3,$checkisbnentry4,$checkisbnentry5,$checkisbnentry6,$checkisbnentry7) = split(/\|/,$isbn);
					if ($checkisbnentry1 eq $entry1) {$entry1class="good";} else {$entry1class="bad";}
					if ($checkisbnentry2 eq $entry2) {$entry2class="good";} else {$entry2class="bad";}
					if ($checkisbnentry3 eq $entry3) {$entry3class="good";} else {$entry3class="bad";}
					if ($checkisbnentry4 eq $entry4) {$entry4class="good";} else {$entry4class="bad";}
					if ($checkisbnentry5 eq $entry5) {$entry5class="good";} else {$entry5class="bad";}
					if ($checkisbnentry6 eq $entry6) {$entry6class="good";} else {$entry6class="bad";}
					if ($checkisbnentry7 eq $entry7) {$entry7class="good";} else {$entry7class="bad";}
					print "     <tr><td class=$entry1class>$checkisbnentry1</td><td class=$entry2class>$checkisbnentry2</td><td class=$entry3class>$checkisbnentry3</td><td class=$entry4class>$checkisbnentry4</td><td class=$entry5class><a href=\"/$config_eacupcisbnsite?dowhat=isbn_edit&dotype=eacupcisbn&fromtype=eacupcisbn_compare&entry=$checkisbnentry5&showline=$line\">$checkisbnentry5</a></td><td class=$entry6class>$checkisbnentry6</td><td class=$entry7class>$checkisbnentry7</td></tr>\n";
				}
			}
		}

		print "    </tbody>\n   </table>";

		# Generate the footer
		&footer;
	}

	sub eacupcisbn_edit {
		if ($dowhat eq "isbn_edit") {
			$edittype="isbn";
			open (isbn,"$basedir/$media_check_isbn/$entry") || &error("error: ISBN $entry");
			@readisbn = <isbn>;
			close (isbn);
			for $isbn(@readisbn) {
				($entry1,$entry2,$entry3,$entry4,$entry5,$entry6,$entry7) = split(/\|/,$isbn);
			}
		} else {
			$edittype="eacupc";
			open (eacupc,"$basedir/$media_check_eacupc/$entry") || &error("error: EAC/UPC $entry");
			@readeacupc = <eacupc>;
			close (eacupc);
			for $eacupc(@readeacupc) {
				($entry1,$entry2,$entry3,$entry4,$entry5,$entry6,$entry7) = split(/\|/,$eacupc);
			}
		}

		($check_entry1,$check_entry2,$check_entry3,$check_entry4,$check_entry5,$check_entry6,$check_entry7) = split(/\|/,$showline);

		print "    <table>\n";

		my @list = split /,/, $entry1;
		#print "@list<br>";
		for (@list) {
			if ($_ eq "books") {
				$books_checked="checked=yes";
			}
			if ($_ eq "games") {
				$games_checked="checked=yes";
				if ($books_checked) {
					$multi=1;
				}
			}
			if ($_ eq "music") {
				$music_checked="checked=yes";
				if ($games_checked) {
					$multi=1;
				}
			}
			if ($_ eq "videos") {
				$video_checked="checked=yes";
				if ($music_checked) {
					$multi=1;
				}
			}
		}
		print "     <tr>\n      <td colspan=2 align=right>books: <input type=\"checkbox\" name=\"type_books\" value=\"1\" $books_checked> games: <input type=\"checkbox\" name=\"type_games\" value=\"1\" $games_checked> music: <input type=\"checkbox\" name=\"type_music\" value=\"1\" $music_checked> videos: <input type=\"checkbox\" name=\"type_videos\" value=\"1\" $video_checked></td><td></td></tr>\n";
		print "     <tr>\n      <th align=right width=30%>Title:</th>\n      <td><input type=text name=newtitle value=\"$entry2\"></td>\n      <td>$check_entry2</td>\n     </tr>\n";
		if (($entry1 eq "music") || ($entry1 eq "books") || ($multi eq "1")) {print "     <tr>\n      <th align=right>Author:</th>\n      <td><input type=text name=newauthor value=\"$entry3\"></td>\n      <td>$check_entry3</td>\n     </tr>\n";}
		print "     <tr>\n      <th align=right>EAC/UPC:</th>\n      <td>\n       <input type=text name=neweacupc value=\"$entry4\"></td>\n      <td>$check_entry4</td>\n     </tr>\n";
		if (($entry1 eq "books") || ($multi eq "1")) {print "     <tr>\n      <th align=right>ISBN:</th>\n      <td><input type=text name=newisbn value=\"$entry5\"></td>\n      <td>$check_entry5</td>\n     </tr>\n";}
		if (($entry1 eq "videos") || ($entry1 eq "books") || ($multi eq "1")) {print "     <tr>\n      <th align=right>Type:</th>\n      <td><input type=text name=newtype value=\"$entry6\"></td>\n      <td>$check_entry6</td>\n     </tr>\n";}
		if (($entry1 eq "videos") || ($multi eq "1")) {print "     <tr>\n      <th align=right>Year:</th>\n      <td><input type=text name=newyear value=\"$entry7\"></td>\n      <td>$check_entry7</td>\n     </tr>\n";}
		print "     <tr>\n      <td colspan=3 align=center>\n       <input type=button value=\"Cancel\" onClick=\"history.back()\">\n       <input type=submit value=\"Submit\">\n      </td>\n     </tr>\n";
		print "    </table>\n";

		print "     <input type=hidden name=dotype value=eacupcisbn>\n     <input type=hidden name=edittype value=$edittype>\n     <input type=hidden name=entry value=$entry>\n     <input type=hidden name=dowhat value=eacupcisbn_write>\n     <input type=hidden name=fromtype value=$fromtype>\n";

		# Generate the footer
		&footer;
	}

	sub eacupcisbn_write {
		if ($type_books) {
			$mediatype="books";
		}
		if ($type_games) {
			if ($mediatype) {
				$mediatype.=",games";
			} else {
				$mediatype="games";
			}
		}
		if ($type_music) {
			if ($mediatype) {
				$mediatype.=",music";
			} else {
				$mediatype="music";
			}
		}
		if ($type_videos) {
			if ($mediatype) {
				$mediatype.=",videos";
			} else {
				$mediatype="videos";
			}
		}
		$writefile="$mediatype|$newtitle|$newauthor|$neweacupc|$newisbn|$newtype|$newyear|";

		if ($edittype eq "eacupc") {
			$editentry="$media_check_eacupc/$entry";
		} else {
			$editentry="$media_check_isbn/$entry";
		}

		# If $config_write is equal to "1", then writing is enabled
		if ($config_write eq "1") {
			open (WRITEINFO,">$basedir/$editentry") || &error("error: editentry $edittype /$editentry<br>");
			print (WRITEINFO $writefile);
			close (WRITEINFO);
		}

		# If $config_previewhide equals 1, display the results as a hidden HTML comment
		if ($config_previewhide eq "1") {
			print "<!--\n writefile: $writefile\n-->\n";
		}

		# If $config_previewshow equals 1, display the results in the administration window
		if ($config_previewshow eq "1") {
			print "<p><b>writefile</b>: $writefile\n";
		}

		# Forward you back to the media database table
		print "     <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"4;URL=/$config_eacupcisbnsite?dowhat=$fromtype&dotype=eacupcisbn\">\n";
		print "     <p><a href=\"/$config_eacupcisbnsite?dowhat=$fromtype&dotype=eacupcisbn\">main screen</a>";

		# Generate the footer
		&footer;
	}

	sub eacupcisbn_viewall {
		# This generates a list of all files within the EAC/UPC folder for checking the database entries.
		my $eacupc_dir = "$basedir/$media_check_eacupc";
		#print "eacupc_dir: $eacupc_dir<br>";
		opendir(eacupc_tmp,"$eacupc_dir/"); 
		@sub_contents = grep !/\./ && !/^_/, sort readdir(eacupc_tmp);
		foreach $line(@sub_contents) {
			#print "$line: ";
			# Open individual items to put these all within a list.
			open (item,"$eacupc_dir/$line");
			@infile = <item>;
			foreach (@infile) {
				($entry1,$entry2,$entry3,$entry4,$entry5,$entry6,$entry7) = split(/\|/,$_);
				push(@unsorted,"$entry1|$entry2|$entry3|$entry4|$entry5|$entry6|$entry7|EACUPC|\n");
			}
			close (item);
		}
		closedir(eacupc_tmp);

		# This generates a list of all files within the ISBN folder for checking the database entries.
		my $isbn_dir = "$basedir/$media_check_isbn";
		#print "isbn_dir: $isbn_dir<br>";
		opendir(isbn_tmp,"$isbn_dir/"); 
		@sub_contents = grep !/\./ && !/^_/, sort readdir(isbn_tmp);
		foreach $line(@sub_contents) {
			#print "$line: ";
			# Open individual items to put these all within a list.
			open (item,"$isbn_dir/$line");
			@infile = <item>;
			foreach (@infile) {
				($entry1,$entry2,$entry3,$entry4,$entry5,$entry6,$entry7) = split(/\|/,$_);
				push(@unsorted,"$entry1|$entry2|$entry3|$entry4|$entry5|$entry6|$entry7|ISBN|\n");
			}
			close (item);
		}
		closedir(isbn_tmp);

		#print @unsorted;

		@sorted = sort @unsorted;

		print "\n   <table id=\"mytable\">\n";
		$rows=0;
		foreach (@sorted) {
			($entry1,$entry2,$entry3,$entry4,$entry5,$entry6,$entry7,$type) = split(/\|/,$_);
			if (($rows eq 0) || ($rows/20 eq int($rows/20))) {
				print "    <tr><th>MEDIA</th><th>TITLE</th><th>AUTHOR/ARTIST</th><th>EAC/UPC</th><th>ISBN</th><th>MEDIA TYPE</th><th>YEAR</th></tr>\n";
			}
			print "    <tr><td>$entry1</td><td>$entry2</td><td>$entry3</td>";
			if (($type eq "EACUPC") && ($entry4)) {
				print "<td style=\"background-color: #00cc33\"><a href=\"/$config_eacupcisbnsite?dowhat=eacupc_edit&dotype=eacupcisbn&fromtype=eacupcisbn_viewall&entry=$entry4\">$entry4</a></td>";
			} else {
				print "<td>$entry4</td>";
			}
			if (($type eq "ISBN") && ($entry5)) {
				print "<td style=\"background-color: #00cc33\"><a href=\"/$config_eacupcisbnsite?dowhat=isbn_edit&dotype=eacupcisbn&fromtype=eacupcisbn_viewall&entry=$entry5\">$entry5</a></td>";
			} else {
				print "<td>$entry5</td>";
			}
			print "<td>$entry6</td><td>$entry7</td></tr>\n";
			$rows++;
		}
		print "   </table>";

		#print @sorted;

		# Generate the footer
		&footer;
	}
}

sub header {
	local($e) = @_;
	print "$delay\n<html>\n<head>\n <title>EZ Editor: Media Admin</title>\n";
	print " <LINK HREF=\"/styles/adminstyle.css\" REL=\"stylesheet\" TYPE=\"text/css\" />\n";

	if ($dowhat eq "eacupcisbn_compare") {
		print " <style>th {background-color: #4CAF50; color: white;} td.bad {background-color: red; color: white;} td.good {background-color: green; color: white;}</style>\n";
	}

	if (($dotype eq "books") || ($dotype eq "music") || ($dotype eq "games") || ($dotype eq "videos")) {
		if (($dowhat ne "config_columns_view") && ($dowhat ne "config_columns_edit")) {
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
	}

	if ($dowhat eq "media_edit") {
		print " <script type=\"text/javascript\">\n";
		print "  var datefield=document.createElement(\"input\")\n";
		print "  datefield.setAttribute(\"type\", \"date\")\n";
		print "  if (datefield.type!=\"date\"){ //if browser doesn't support input type=\"date\", load files for jQuery UI Date Picker\n";
		print "    document.write('<link href=\"http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css\" rel=\"stylesheet\" type=\"text/css\"/>')\n";
		print "    document.write('<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js\"><\script>')\n";
		print "    document.write('<script src=\"http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js\"><\script>')\n";
		print "  }\n";
		print " </script>\n";

		print " <script>\n";
		print "  if (datefield.type!=\"date\"){ //if browser doesn't support input type=\"date\", initialize date picker widget:\n";
		print "   jQuery(function(\$){ //on document.ready\n";
		print "    \$('#newpurchasedate').datepicker();\n";
		print "   })\n";
		print "  }\n";
		print " </script>\n";
	}

	print "</head>\n<body topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0";
	if (($dowhat eq "media_barcode") || ($dowhat eq "media_isbn") || ($dowhat eq "media_edit") || ($dowhat eq "media_add")) {
		print " OnLoad=\"document.myform.";
		if ($dowhat eq "media_barcode") {
			print "neweacupc";
		} elsif ($dowhat eq "media_isbn") {
			print "newisbn";
		} elsif ($dotype eq "music") {
			print "newartist";
		} else {
			print "newtitle";
		}
		print ".focus();\"";
	}
	print ">\n";
	print "<table width=100% height=100% border=1 align=center valign=center>\n";
	print " <tr>\n  <td height=20 valign=top align=center>\n";
	print "   <table width=100% cellspacing=0 cellpadding=0 border=0>\n";
	print "    <tr>\n";
	
	$addtext="writing is $write";
	if ($preview or $showhide) {
		$addtext.=", preview $preview, $showhide";
	}
	print "     <td align=center class=header width=30%><b>Media Admin</b><br>$addtext</td>\n";

	if ($dotype ne "config") {
		$headerlinks="<a href=\"/$config_adminsite?dowhat=media_add&dotype=$dotype\">Add $media_text Manually</a> | <a href=\"/$config_adminsite?dowhat=media_barcode&dotype=$dotype&addtype=eacupc\">Add $media_text by Barcode</a> | <a href=\"/$config_adminsite?dowhat=media_isbn&dotype=$dotype&addtype=isbn\">Add $media_text by ISBN</a><br><a href=\"/$config_adminsite?dowhat=config_columns_edit&dotype=$dotype\">Show/Hide Columns</a>";
	}

	if ($dotype eq "eacupcisbn") {
		$headerlinks="<a href=\"/$config_adminsite?dotype=eacupcisbn&dowhat=eacupcisbn_generate\">Generate Database</a> | <a href=\"/$config_adminsite?dotype=eacupcisbn&dowhat=eacupcisbn_compare\">Compare Database Entries</a> | <a href=\"/$config_adminsite?dotype=eacupcisbn&dowhat=eacupcisbn_viewall\">View All Entries</a>";
	}
	print "     <td align=center class=header width=40%>$headerlinks</td>\n";

	print "     <td align=center class=header width=30%><a href=\"/$config_adminsite?dotype=books\">books</a> | <a href=\"/$config_adminsite?dotype=games\">games</a> | <a href=\"/$config_adminsite?dotype=music\">music</a> | <a href=\"/$config_adminsite?dotype=videos\">videos</a><br><a href=\"/$config_adminsite?dotype=config&dowhat=config_view&fromtype=$dotype\">config</a> | <a href=\"/$config_eacupcisbnsite?dotype=eacupcisbn&dowhat=eacupcisbn_compare\">EAC/UPC/ISBN database</a></td>\n";
	print "    </tr>\n   </table>\n  </td>\n </tr>\n\n <tr>\n <form method=post action=\"/$config_adminsite\" name=\"myform\">\n  <td align=center>";
}

sub footer {
	print "\n  </td>\n </tr>\n";
	print " <tr height=10>\n  <td align=center>\n";
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
	print "\n   $e\n";
	print " <tr height=10>\n  <td align=center>\n";
	print "   <i>this script, <b>mediacollection</b>, is part of an open source Perl script available on <a href=\"https://github.com/rdgarfinkel/mediacollection\" target=\"_GitHub\">Github</a></i>\n";
	print "  </td>\n </tr>\n </form>\n</table>\n</body>\n</html>";
	exit;
}

sub getqueries {
	# Set the content-type of the page to be an HTML file, and Pragma tries to force the browser
	# to always get a new version, and not cache the output
	print "Content-type: text/html\nPragma: no-cache\n\n";

	## $basedir - Base directory and static locations for operations
	$basedir=$ENV{'DOCUMENT_ROOT'};

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
	$todaysdate="$currentyear-$mnth-$day";

	## Enable or disable update functions
	open (config,"$basedir/$config_data") || &config_view("incomplete or missing configuration file, $config_data. please configure these scripts using the form below<br>");
	@in = <config>;
	close (config);
	for $line(@in) {
		($config_write,$config_previewhide,$config_previewshow,$config_thesort,$config_mobile) = split(/\|/,$line);
	}

	# Delay write information display
	if ($config_previewhide eq "1") {
		$preview="on";
		$showhide="hidden";
		$wait=10;
	}
	if ($config_previewshow eq "1") {
		$preview="on";
		$showhide="shown";
		$wait=10;
	}
	if ($config_write eq "1") {
		$write="enabled";
		$wait=4;
	} else {
		$write="disabled";
		$wait=10;
	}

	### Retrieve information passed from/to scripts

	# $delay is for diagnostic purposes, just to check that all variables appear correctly when running
	$delay="<!--ez editor v$dateupdated || today $today || config_previewshow $config_previewshow || config_previewhide $config_previewhide || config_mobile $config_mobile || wait $wait";

	# if the form request is a 'get', then process it, otherwise...
	if ($ENV{'REQUEST_METHOD'} eq 'GET') {
		@querys = split(/&/, $ENV{'QUERY_STRING'});
	}
	# the request is a 'post', process it....
	elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
		read (STDIN, $query, $ENV{'CONTENT_LENGTH'});
		@querys = split(/&/, $query);
	}

	# Get the QUERY_STRING from GET or POST and display as part of $delay
	#@querys = split(/&/, $ENV{'QUERY_STRING'});
	foreach $query (@querys) {
		($name, $value) = split(/=/, $query);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ s/<!--(.|\n)*-->//g;
		$value =~ s/\"/\'\'/g;
		$value =~ s/\&/\(amp\)/g;
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
	$fromtype=$FORM{'fromtype'};
	$entry=$FORM{'entry'};
	## Variable sets for EAC/UPC/ISBN editing
	$mediatype=$FORM{'mediatype'};
	$type_books=$FORM{'type_books'};
	$type_music=$FORM{'type_music'};
	$type_games=$FORM{'type_games'};
	$type_videos=$FORM{'type_videos'};
	$edittype=$FORM{'edittype'};
	## Multi-use variable sets
	$newtitle=$FORM{'newtitle'};
	$oldtitle=$FORM{'oldtitle'};
	$neweacupc=$FORM{'neweacupc'};
	$neweacupc=~s/[^\d]//gi;                   # remove any character besides numbers for EAC/UPC
	$oldeacupc=$FORM{'oldeacupc'};
	$newisbn=$FORM{'newisbn'};
	$newisbn=~s/[^\dxX]//gi;                   # remove any character besides numbers and x/X from ISBN
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
	$newpurchasedate=$FORM{'newpurchasedate'};
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
	## Variable sets for config
	$editconfig_write=$FORM{'config_write'};
	$editconfig_previewhide=$FORM{'config_previewhide'};
	$editconfig_previewshow=$FORM{'config_previewshow'};
	$editconfig_thesort=$FORM{'config_thesort'};
	$editconfig_mobile=$FORM{'config_mobile'};
	# Column edits
	$column_video_eacupc=$FORM{'column_video_eacupc'};
	$column_video_type=$FORM{'column_video_type'};
	$column_video_media=$FORM{'column_video_media'};
	$column_video_amazon=$FORM{'column_video_amazon'};
	$column_video_disneyanywhere=$FORM{'column_video_disneyanywhere'};
	$column_video_googleplay=$FORM{'column_video_googleplay'};
	$column_video_itunes=$FORM{'column_video_itunes'};
	$column_video_uvvu=$FORM{'column_video_uvvu'};
	$column_video_isbn=$FORM{'column_video_isbn'};
	$column_video_microsoft=$FORM{'column_video_microsoft'};
	$column_video_purchasedate=$FORM{'column_video_purchasedate'};
	$column_books_eacupc=$FORM{'column_books_eacupc'};
	$column_books_isbn=$FORM{'column_books_isbn'};
	$column_books_purchasedate=$FORM{'column_books_purchasedate'};
	$column_books_type=$FORM{'column_books_type'};
	$column_music_amazon=$FORM{'column_music_amazon'};
	$column_music_cd=$FORM{'column_music_cd'};
	$column_music_djbooth=$FORM{'column_music_djbooth'};
	$column_music_eacupc=$FORM{'column_music_eacupc'};
	$column_music_googleplay=$FORM{'column_music_googleplay'};
	$column_music_groove=$FORM{'column_music_groove'};
	$column_music_itunes=$FORM{'column_music_itunes'};
	$column_music_purchasedate=$FORM{'column_music_purchasedate'};
	$column_music_reverbnation=$FORM{'column_music_reverbnation'};
	$column_music_rhapsody=$FORM{'column_music_rhapsody'};
	$column_music_topspin=$FORM{'column_music_topspin'};
	$column_games_battlenet=$FORM{'column_games_battlenet'};
	$column_games_eacupc=$FORM{'column_games_eacupc'};
	$column_games_epic=$FORM{'column_games_epic'};
	$column_games_nes=$FORM{'column_games_nes'};
	$column_games_origin=$FORM{'column_games_origin'};
	$column_games_purchasedate=$FORM{'column_games_purchasedate'};
	$column_games_ps2=$FORM{'column_games_ps2'};
	$column_games_steam=$FORM{'column_games_steam'};
	$column_games_uplay=$FORM{'column_games_uplay'};
	$column_games_wii=$FORM{'column_games_wii'};
	$column_games_xbox360=$FORM{'column_games_xbox360'};
	$column_games_xboxone=$FORM{'column_games_xboxone'};

	## The next few lines define the location of $media_read for media types, and how many columns are in the data display table.
	if ($dotype eq "books") {
		$media_read.="books.txt";
		$media_text="Book";
		$columns=8;
	} elsif ($dotype eq "games") {
		$media_read.="games.txt";
		$media_text="Game";
		$columns=15;
	} elsif ($dotype eq "music") {
		$media_read.="music.txt";
		$media_text="Music";
		$columns=14;
	} elsif ($dotype eq "videos") {
		$media_read.="videos.txt";
		$media_text="Video";
		$columns=14;
	} elsif ($dotype eq "config") {
		if ($dowhat eq "") {$dowhat="config_view";}
		$columns=4;
	} elsif ($dotype eq "eacupcisbn") {
		if ($dowhat eq "") {$dowhat="eacupcisbn_compare";}
		$columns=7;
	} else {
		&header;
		&errorfatal("missing \'dotype\'");
		&footer;
	}
}
