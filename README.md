# mediacollection
Physical and digital music, video (movies/tv), books, and games collection display and management<br>
<br>
Each media type has it's own table headers on the administrative and non-administrative pages.<br>
In the non-administrative pages, at the top left, you'll see the date that the text database was last updated, and the table headers can be dynamically sorted when you are at the top of the resulting page.<br>
<br>
In the adminstrative pages, you'll see the date the text database was last updated at the bottom of the page, as well as an overall count of the media currently displayed, and as a breakdown of each individual category. here, you can also edit and delete media items.<br>
<br>
Also in the administrative pages, there's an additional option of "debugview," which can be used to be able to preview changes to the text database. After changing the options, you'll be redirected back to the media section that you were on previously. Here, you'll be able to:<br>
- enable write: enable/disable actual changes to your database<br>
- preview hidden: enable/disable a preview of the changes to the database in only the HTML code<br>
- preview shown: enable/disable a preview of the changes to the database within the adminstrative window

# first things first
If you will be using this on a public server, put the /cgi-bin/media/media.pl file within a separate directory that is password protected so that only you can add/amend/delete your database entries. <br>
Things should work "directly out of the box." You'll probably need to edit the $basedir variable in the index.cgi and media.pl scripts, and maybe the "#!/usr/bin/perl" line at the top of each script

# demonstration
A demonstration of the script and it's abilities is online and available, with editing abilities enabled, and no password is required for the admin side. Test it out as you wish:
http://rgarfinkel.heliohost.org/cgi-bin/mediademo/index.cgi
Please note that the "modification" date in the hidden HTML code for each script on the demonstrations may be newer than the one present here on Github. I do the coding offline, post it to the demo site to verify it still works on those live sites, then I'll post it here.

# requirements
For this script to run, you'll need to have a web server capable of running Perl scripts.

# what is included
The scripts below are only implemented on the non-adminsitrative page:
/javascripts/gs_sortable.js, http://www.allmyscripts.com/Table_Sort/index.html: allows for the dynamic sorting of table headers (only accessible when page has not been scrolled down)<br>
/javascripts/jquery-1.5.1.min.js, http://jquery.com/, http://sizzlejs.com/: disabled, but required for use of freezeheader below<br>
/javascripts/jquery.freezeheader.js, http://brentmuir.com/projects/freezeheader: disabled because it's unreliable in operation, freezes table header at the top of the screen when scrolling down

# items of note
While testing, when using the <b>&</b> ampersand symbol in text fields, the editing feature didn't work. It seems that the 'query string' parsing splits this like it is a separate entry. Text replacement will occur server side, swapping the <b>&</b> symbol for <b>and</b> text.<br>
While testing, when using double quotation <b>"</b> symbol in text fields, the editing feature didn't work. When clicking an entry to edit, the browser would interpret the quotations as the end of an <b>A HREF</b> HTML tag. Text replacement will occur server side, swapping the <b>"</b> symbol for <b>''</b> two single quotation symbols.<br>
When items are added, they'll be added to the bottom of the list. That entry can be sorted upon editing another entry and submitting.

# things to add
ability to hide/show columns, ie if you have columns not in use

# change log
2016.09.09<br>
Added the ability to add items based on ISBN codes or EAC/UPC barcodes! I haven't found a "universal" barcode service that can provide DVD/BluRay/CD/Movie/TV/Books barcodes, so I built one into the script. At the center of the top of the administration pages, there's now the option to add items based on ISBN and EAC/UPC barcodes. The only text input available there are either the ISBN or EAC/UPC barcode textbox. If the code is not found, you'll be directed to add it manually. Upon submitting the manual entry, the entry is created within the 'upc' or 'eacupc' folders that contains the items' EAC/UPC code, ISBN code, title, artist(s)/author(s), database type, and physical media type. I've started these folders with my collections of ISBN/UPC/EAC codes, hopefully more people can contribute theirs as well.<br>
When adding entries, the first text box in the editing screen receives focus so you can start typing right away, rather than clicking first then typing.<br>
2016.09.08<br>
video section, BluRay and DVD columns are now combined into one, which will allow adding more media types in the future, if needed (ie. VHS, LaserDisc, HD-DVD, etc. if it is requested). there is a "transfer" script that is in the cgi-bin/media folder that will combine the BluRay and DVD entries into one entry.<br>
2016.09.07<br>
forced width of title column on non-admin and admin pages<br>
changed color of row highlight to a darker color<br>
put UPC/ISBN closer to the left side, where appropriate on the different media types. some were on the left, others on the right<br>
turned off "fixed header" on the non-admin page; sometimes the header stayed fixed, other times not, and would sometimes not be scaled with the columns below<br>
