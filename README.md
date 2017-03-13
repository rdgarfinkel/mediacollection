# mediacollection
Simple data (no images to load) display and management for physical and digital music, video (movies/tv), books, and games collections

# first things first
If you will be using this on a public server, put the /cgi-bin/media/media.pl file within a separate directory that is password protected so that only you can add/amend/delete your database entries.<br>
Aside from editing the "#!/usr/bin/perl" line at the top of each script, things *should* work "directly out of the box." 

# demonstration
A demonstration of the script and it's abilities is online and available, with editing abilities enabled. No password is required for the admin side. Test it out as you wish, http://rgrfnkl.heliohost.org/cgi-bin/media/index.cgi.<br>
Please note that the "modification" date in the shown/hidden HTML on the demonstration sites may be newer than the one present here on Github. I do the coding offline on a local server, post it to the public site to verify it still works on there, then I'll post it here.

# requirements
For this script to run, you'll need to have a web server and it needs to be capable of running Perl scripts. It can be a public server or just a local server.<br>
I use Aprelium's Abyss Web Server for local server scripting/testing, free and available for Windows/Mac/Linux; http://aprelium.com/. Perl installation instructions can be found here: http://aprelium.com/abyssws/perl.html.<br>
The public server I use for the demonstration (as well as my other sites there) is also free; http://heliohost.org. You do need to remember to login to your account once a month to keep your account active, though I can say comfortably that your account and all files will be recovered if you do forget.

# optional
I highly recommend an external barcode scanner, since it will help tremendously when initially entering your items into the database; it will act as a keyboard input when adding thru either the EAC/UPC/ISBN entry, or as a manual entry. Personally,  I use a <b>:CueCat</b> that has been modified to have a USB connector, rather than a PS/2 connector; the :CueCat can be found thru ebay.com for less than $10 USD.

# what is included
- /javascripts/gs_sortable.js, http://www.allmyscripts.com/Table_Sort/index.html: allows for the dynamic sorting of table headers (only accessible when the page has not been scrolled down)<br>
- ~~/javascripts/jquery-1.5.1.min.js, http://jquery.com/, http://sizzlejs.com/: disabled, required for use of freezeheader below~~<br>
- ~~/javascripts/jquery.freezeheader.js, http://brentmuir.com/projects/freezeheader: disabled because it's unreliable in operation. freezes table header at the top of the screen when scrolling down~~

# items of note
- When using the <b>&</b> ampersand symbol in text fields, the editing feature didn't work. It seems that the 'query string' parsing splits this like it is a separate entry. Text replacement will occur server side, swapping the <b>&</b> symbol for <b>(amp)</b> text.
- When using the <b>"</b> double quotation symbol in text fields, the editing feature didn't work. When clicking an entry to edit, the browser would interpret the quotations as the end of an <b>A HREF</b> HTML tag. Text replacement will occur server side, swapping the <b>"</b> double quotation mark for <b>''</b> two single quotation symbols for storing the entries, and <b>''</b> two single quotation symbols will be swapped for the <b>"</b> double quotation mark for display in the user facing tables.
- When using the <b>#</b> pound symbol in text fields, the editing feature didn't work. I think what happens is the script thinks that the entry is supposed to be hidden, like it is a comment in Perl. When a pound sign is needed in titles, use <b>(pound)</b>. This will be entered into the database, and <b>(pound)</b> will be swapped for <b>#</b> pound symbol in the user facing tables.
- When using the <b>+</b> plus symbol, the editing feature works, but not as expected. The plus symbol is the indicator that forms use for spaces, and would be interpreted as such. When the <b>+</b> plus symbol is to be used within a text field, use <b>(plus)</b>. This will be entered into the database, and <b>(plus)</b> will be swapped for <b>+</b> plus symbol in the user facing tables.
- When movies are redone and the titles are the same, you'll get unwanted results when trying to edit one of the two entries. For example, the 1967 movie, *The Jungle Book* and the 2016 movie, *The Jungle Book*. When both exist in the database, both entries would be edited when editing one of the entries. To work around this, there is now a year input box within the media editor for videos, and entries are now compared by title and year, when the year has a value.
- The columns currently within each media section are the media types that I have. As an example, I don't have a Sony Playstation 1, 3, or 4 system/games, so those columns don't exist yet in the games section. If you need these or other options, file an issue here on Github, and I'll add whatever you need, or if anyone wants to contribute, that's okay too.

# things to add/research
- Make code comments on files and processes for helping others' understand what is doing what. (media.pl is close to finished, index.cgi will be next)
- Work on the wiki for this project.
- EAC/UPC/ISBN approval script to verify that public entries are at a good quality.
- Researching other options for having a fixed header upon scrolling. The one that was in place is not 100% reliable.
- Hosted website with these scripts put online, with member signup abilities- researching how to do member logins now.
- With games having additional downloadable content, I'll be adding an option for this specifically just for games, where ideally the entries will show up indented underneath the game the content is connected to. I'm not sure how I'll implement it yet.

# things to add way down the road<br>
- TheAudioDB.com, imdb.com, themoviedb.org, thetvdb.com, musicbrainz.org and/or thegamesdb.net integration would be awesome, but I don't know enough about API usage currently to do these, hopefully someone can step up with these abilities.

# change log
- 2017.03.12
  - Administration: with the 2017.03.12 update, the database changes broke the EAC/UPC/ISBN database generation, this is now fixed.
- 2017.03.10
  - Administration: "media.cgi" file contains the following modifications/updates:
    - Thru the administration, you can now show/hide columns from view on the non-administrative pages. To edit these, navigate to the media type and now underneath the "Add by UPC/EAC/ISBN" links at the top, there is also a "Show/Hide Columns" link. Technically, this is integrated into the 'config' pages, so there's also a link to see the current state of each media type's available columns being hidden or shown.
    - There is now a "Purchased Date" column integrated into the database views for each media type. It can be hidden or shown.
  - Non-administrative: "index.cgi" file contains the following modifications/updates:
    - The automated column count of table headers is now present, and full columns can now be hidden/shown.
  - General note
    - The first line of each database had to be changed a bit, as I didn't realize that having the date in the second entry would cause issues for the column show/hide ability. So, rather than "#DATE#|2017.02.18|", this will now be "#DATE#,2017.02.18|". The good news is the database is forgiving for leaving it alone. If you don't want to make the change manually, you won't see the database revision date until the columns are shown/hidden or until a new addition/revision/deletion is performed on the database.
- 2017.01.05
  - Administration: Ability to add the date that media was purchased; by default, it'll use the current date, but the date can be changed to be any date. Currently, the only place the dates show up is in the media editing screens, a "most recent purchase" may be implemented in the future.
  - Non-administrative: When browsing the collection pages from a mobile device, it's only a one column view with physical/digital media listed underneath the titles/authors/artists, rather than the full table.
- 2016.10.31
  - Administration: With this update, the entire EAC/UPC and ISBN directory is displayed for review in the EAC/UPC/ISBN database link, and you can also edit entries from within the web interface.
  - Non-administrative: When accessing the index.cgi site thru Firefox, I noticed that the scrollbars weren't available in the pop-up administration window. This is now fixed.
- 2016.10.25
  - Administration: 2016.10.20 update had some variable naming adjustments that I missed, now fixed with this update.
- 2016.10.20
  - Administration: There's now a EAC/UPC/ISBN entry comparison/editing option, in which the media type's database of entries is compared with their EAC/UPC/ISBN entries, when available. Individual cells are highlighted cells green if they match, or red if they don't match. It's not necessarily a bad thing if they don't match, of course. It's limited only to what is in your database, it doesn't open each EAC/UPC/ISBN entry within each directory.
  - Administration: Made naming adjustments to the variables, subroutines and links, ie 'debug' is now 'config'.
  - Administration: Media edits now 'POST' data to the script, so edits are generally unlimited in length.
  - Administration: The header of the admin pages is now two lines in height, so I spread out the links a bit.
  - Administration: The automatic switch of the <b>+</b> plus symbol worked well at times, but I found that it also caused issues. For example, typing the apostrophe would be replaced with <b>(plus)</b> as well, for whatever reason; you'll have to do this manually now.
- 2016.10.07
  - Administration: When adding entries, it will be sorted into the database.
  - Administration: $basedir is now automatically discovered by the scripts.
  - Administration: (amp) can now be used so that the ampersand symbol appears in the user facing tables.
  - Administration: Some code cleanup and optimizing.
- 2016.10.05
  - ~~Administration: Added ability for new/editing titles to have the ability to swap the <b>+</b> plus symbol for <b>(plus)</b> automatically upon entry by the user.~~
  - Administration: EAC/UPC barcodes are strictly numbers. If anything else is entered, it is stripped server-side.
  - Administration: ISBN barcodes are strictly numbers and the upper/lowercase letter 'X'. If anything else is entered, it is stripped server-side, and 'x' will be capitalized.
- 2016.10.01
  - Administration: When items have specific symbols, they don't always make it through to the text title, for example, Ed Sheeran's album, "+", because the script interprets the plus symbol as a space. In this case, you can't use the plus symbol directly in the title, and it can't be automatically swapped, at least server side- I'd like to find a way to swap these prior to submitting using JavaScript client side. Currently, the only workaround is to use <b>(plus)</b> instead.
  - Administration: The <b>#</b> pound symbol is another case, and it seems this is because Perl interprets it as a comment within the script, and it breaks the editing ability. The <b>#</b> pound symbol will be automatically swapped for <b>(pound)</b> server side.
  - Administration: Found an error in the code on the admin side where the month was lost on date updated entry, now fixed.
  - Non-administrative: Table display on non-admin side is now centered, and also contains the github mention footer.
- 2016.09.19
  - Administration: Up until now, when EAC/UPC/ISBN codes were found, the entry was overwritten upon each edit. Now entries are only created and not updated/overwritten.
  - Administration: Added a year input option to videos on the administration side, and also added the display of the year on the non-administrative side. I now have two movies that were named the same, and editing one would edit the other. This is now fixed, as long as one or both of the movies have a year attached to it.
- 2016.09.16
  - Administration: Some code cleanup/rearranging.
  - Administration: Added the ability to sort the table columns in the administration pages.
  - Administration: In the 'config' menu, there's now an option for sorting titles with "The" at the beginning, and this effects both the non-administration and administration side. Using *The Sandlot* as an example, when 'sort by' is on, the title will appear as, *Sandlot, The*. Otherwise, it will appear as *The Sandlot*. For adding/changing *The Sandlot*, you can enter *Sandlot, The* or *The Sandlot*, it will be entered into the database as *Sandlot, The* regardless.
  - Administration: Added descriptions for the functions of each option in the 'config' menu.
  - ~~Administration: If I add more options on the 'debug' menu, I may switch the name to be 'options' instead.~~
  - Administration: While testing the sorting in the administration side, the media collection totals would sometimes also be included in the sort. To prevent this from happening now, those totals now appear separate of the sortable table.
  - Non-administrative: When you first visited the non-administration page, there would be no 'dotype' variable passed to the administration page, if you clicked on the admin link. This would result in the administration page displaying only the text, "missing 'dotype'." This is now fixed, and shows the headers as well.
- 2016.09.09
  - Administration: Added the ability to add items based on ISBN codes or EAC/UPC barcodes! I haven't found a "universal" barcode service that can provide DVD/BluRay/CD/Movie/TV/Books barcodes, so I built one into the script. At the center of the top of the administration pages, there's now the option to add items based on ISBN and EAC/UPC barcodes. The only text input available there are either the ISBN or EAC/UPC barcode textbox. If the code is not found, you'll be directed to add it manually. Upon submitting the manual entry, the entry is created within the 'upc' or 'eacupc' folders that contains the items' EAC/UPC code, ISBN code, title, artist(s)/author(s), database type, and physical media type. I've started these folders with my collections of ISBN/UPC/EAC codes, hopefully more people can contribute theirs as well.
  - Administration: When adding entries, the first text box in the editing screen receives focus so you can start typing right away, rather than clicking first then typing.
- 2016.09.08
  - Administration: Prior to this update, in the video section, BluRay and DVD were separate columns. Going forward, these are now combined into one, which will allow for adding more media types in the future, if needed (ie. VHS, LaserDisc, HD-DVD, etc. if there are requests for these). There is a "transfer" script that is in the cgi-bin/media folder that will combine the BluRay and DVD entries into one entry, run it *<b>only</b>* once.
- 2016.09.07
  - Administration/Non-administrative: Forced width of title column on non-admin and admin pages
  - Administration: Changed color of row highlight to a darker color
  - Administration: Put UPC/ISBN closer to the left side, where appropriate on the different media types. some were on the left, others on the right
  - Non-administrative: Turned off "fixed header" on the non-admin page; sometimes the header stayed fixed, other times not, and would sometimes not be scaled with the columns below
