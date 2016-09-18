# mediacollection
Physical and digital music, video (movies/tv), books, and games collection display and management

# first things first
If you will be using this on a public server, put the /cgi-bin/media/media.pl file within a separate directory that is password protected so that only you can add/amend/delete your database entries.<br>
Things *should* work "directly out of the box." You'll need to edit the $basedir variable in the index.cgi and media.pl scripts, and maybe the "#!/usr/bin/perl" line at the top of each script

# demonstration
A demonstration of the script and it's abilities is online and available, with editing abilities enabled. No password is required for the admin side. Test it out as you wish, http://rgarfinkel.heliohost.org/cgi-bin/mediademo/index.cgi<br>
Please note that the "modification" date in the shown/hidden HTML on the demonstration sites may be newer than the one present here on Github. I do the coding offline on a local server, post it to the public site to verify it still works on there, then I'll post it here.

# requirements
For this script to run, you'll need to have a web server and it needs to be capable of running Perl scripts. It can be a public server or just a local server.<br>
I use Aprelium's Abyss Web Server for local server scripting/testing, free and available for Windows/Mac/Linux; http://aprelium.com/. Perl installation instructions are here: http://aprelium.com/abyssws/perl.html.<br>
The public server I use for the demonstration (as well as my other sites there) is also free; http://heliohost.org. Highly suggest signing up with the Stevie server if you go with this option, the Johnny server isn't quite as good. You do need to remember to login to your account once a month to keep your account (your account and all files will be recovered if you forget).

# what is included
- /javascripts/gs_sortable.js, http://www.allmyscripts.com/Table_Sort/index.html: allows for the dynamic sorting of table headers (only accessible when page has not been scrolled down)<br>
- /javascripts/jquery-1.5.1.min.js, http://jquery.com/, http://sizzlejs.com/: disabled, required for use of freezeheader below<br>
- /javascripts/jquery.freezeheader.js, http://brentmuir.com/projects/freezeheader: disabled because it's unreliable in operation. freezes table header at the top of the screen when scrolling down

# items of note
- While testing, when using the <b>&</b> ampersand symbol in text fields, the editing feature didn't work. It seems that the 'query string' parsing splits this like it is a separate entry. Text replacement will occur server side, swapping the <b>&</b> symbol for <b>and</b> text.
- While testing, when using the <b>"</b> double quotation mark in text fields, the editing feature didn't work. When clicking an entry to edit, the browser would interpret the quotations as the end of an <b>A HREF</b> HTML tag. Text replacement will occur server side, swapping the <b>"</b> double quotation mark for <b>''</b> two single quotation symbols for storing the entries, and <b>''</b> two single quotation symbols will be swapped for the <b>"</b> double quotation mark for display in the user facing tables.
- When items are added, they'll be added to the bottom of the list. That entry can be sorted upon editing another entry and submitting, unless I can find a way to do this upon adding entries.
- When movies are redone and the titles are the same, you'll get unwanted results when trying to edit one of the two entries. For example, the 1967 movie, *The Jungle Book* and the 2016 movie, *The Jungle Book*. When both exist in the database, both entries would be edited when editing one of the entries. To work around this, use the movie's year in the title as well, for example, *The Jungle Book (1967)* or *The Jungle Book (2016).*
- The columns within each media section are the media types that I have access to. So, I didn't add Sony Playstation 1, 3, or 4 columns in the games section, as an example. If you need these, file an issue here on Github, and I'll add whatever you need.

# things to add
- Make code comments on files and processes for helping others' understand what is doing what.
- Work on the wiki for this project.
- EAC/UPC/ISBN approval script to verify that entries are at a good quality, and not spam.
- Ability to hide/show columns, ie if there are media types not in use. This will require a slight rewrite of some code, but will make additions of media types easier in the future. Currently columns numbers are adjusted manually by myself, so when a column is added, I have to increment a variable number by one. The method I've come up with will essentially automate this, and I'll no longer need to manually adjust that variable. This will not require adjustments to the database files, either.
- Researching other options for having a fixed header upon scrolling. The one that was in place is not 100% reliable.
- TheAudioDB.com, imdb.com, themoviedb.org, thetvdb.com, and musicbrainz.org integration would be awesome, but I don't know enough about API usage currently to do these, hopefully someone can step up with these abilities.

# change log
- Next update
  - Up until now, when EAC/UPC/ISBN codes were found, the entry was overwritten upon each edit. Now entries are only created and not updated. *This isn't implemented yet, but will be on the next update.*
- 2016.09.16
  - Some code cleanup/rearranging.
  - Added the ability to sort the table columns in the administration pages.
  - In the 'debug' menu, there's now an option for sorting titles with "The" at the beginning, and this effects both the non-administration and administration side. Using *The Sandlot* as an example, when 'sort by' is on, the title will appear as, *Sandlot, The*. Otherwise, it will appear as *The Sandlot*. For adding/changing *The Sandlot*, you can enter *Sandlot, The* or *The Sandlot*, and it will be entered into the database as *Sandlot, The* server side.
  - Added descriptions for the functions of each option in the 'debug' menu.
  - If I add more options on the 'debug' menu, I may switch the name to be 'options' instead.
  - While testing the sorting in the administration side, the media collection totals would sometimes also be included in the sort. To prevent this from happening now, those totals now appear separate of the sortable table.
  - When you first visited the non-administration page, there would be no 'dotype' variable passed to the administration page, if you clicked on the admin link. This would result in the administration page displaying only the text, "missing 'dotype'." This is now fixed, and shows the headers as well.
- 2016.09.09
  - Added the ability to add items based on ISBN codes or EAC/UPC barcodes! I haven't found a "universal" barcode service that can provide DVD/BluRay/CD/Movie/TV/Books barcodes, so I built one into the script. At the center of the top of the administration pages, there's now the option to add items based on ISBN and EAC/UPC barcodes. The only text input available there are either the ISBN or EAC/UPC barcode textbox. If the code is not found, you'll be directed to add it manually. Upon submitting the manual entry, the entry is created within the 'upc' or 'eacupc' folders that contains the items' EAC/UPC code, ISBN code, title, artist(s)/author(s), database type, and physical media type. I've started these folders with my collections of ISBN/UPC/EAC codes, hopefully more people can contribute theirs as well.
  - When adding entries, the first text box in the editing screen receives focus so you can start typing right away, rather than clicking first then typing.
- 2016.09.08
  - In the video section, BluRay and DVD columns are now combined into one, which will allow for adding more media types in the future, if needed (ie. VHS, LaserDisc, HD-DVD, etc. if it is requested). There is a "transfer" script that is in the cgi-bin/media folder that will combine the BluRay and DVD entries into one entry, run it only once.
- 2016.09.07
  - Forced width of title column on non-admin and admin pages
  - Changed color of row highlight to a darker color
  - Put UPC/ISBN closer to the left side, where appropriate on the different media types. some were on the left, others on the right
  - Turned off "fixed header" on the non-admin page; sometimes the header stayed fixed, other times not, and would sometimes not be scaled with the columns below
