# mediacollection
physical and digital video (movies/tv), books, and games collection display and management<br>
<br>
each media type has it's own table headers, and is dynamically sortable by the table headers when you are at the top of the resulting page.<br>
in the non-administrative pages, at the top left, you'll see the date that the text database was last updated.<br>
in the adminstrative pages, you'll see the date the text database was last updated at the bottom of the page, as well as an overall count of the media currently displayed, as well as a breakdown of each individual category. here, you can also edit and delete media items.<br>
also in the administrative pages, there's an additional option of "debugview." here, you'll be able to:<br>
- enable write: enable/disable actual changes to your database<br>
- preview hidden: enable/disable a preview of the changes to the database in only the HTML code<br>
- preview shown: enable/disable a preview of the changes to the database within the adminstrative window

# first things first
if you will be using this on a public server, put the /cgi-bin/media/media.pl file within a separate directory that is password protected so that only you can add/amend/delete your database entries<br>
things should work "directly out of the box." you'll probably need to edit the $basedir variable in the index.cgi and media.pl scripts, and maybe the "#!/usr/bin/perl" line at the top of each script

# demonstration
a demonstration of the script and it's abilities is online and available, with editing abilities enabled, and no password required for the admin side. test it out as you wish:
http://rgarfinkel.heliohost.org/cgi-bin/mediademo/index.cgi

# requirements
for this script to run, you'll need to have a web server capable of running Perl scripts.

# what is included
/javascripts/gs_sortable.js, http://www.allmyscripts.com/Table_Sort/index.html: allows for the dynamic sorting of table headers (only accessible when page has not been scrolled down)<br>
/javascripts/jquery-1.5.1.min.js, http://jquery.com/, http://sizzlejs.com/: required for use of freezeheader below<br>
/javascripts/jquery.freezeheader.js, http://brentmuir.com/projects/freezeheader: freezes table header at the top of the screen when scrolling down

# still to do!
add music section, debating on how to implement this, ie sort by artist or album title, or artist and album title

# may do/fix?
automatic item fill in with UPC code<br>
when items are added, they'll be added to the bottom of the list, disregarding any type of sort. currently, the only way to organize the list is to go into an item to edit, do not make any changes, then submit the edit.
