# mediacollection
video (movies/tv), books, and games media collection display and management

# first things first
if you will be using this on a public server, put the /cgi-bin/media/media.pl file within a separate directory that is password protected so that only you can add/amend/delete your database<br>
things should work "directly out of the box." you'll probably need to edit the $basedir variable in the index.cgi and media.pl scripts

# demonstration
a demonstration of the script and it's abilities is online and available, with editing abilities enabled, and no password required for the admin side. test it out as you wish:
http://rgarfinkel.heliohost.org/cgi-bin/mediademo/index.pl

# requirements
for this script to run, you'll need to have a web server capable of running Perl scripts.

# what is included
/javascripts/gs_sortable.js, http://www.allmyscripts.com/Table_Sort/index.html: allows for the sorting of table headers (only accessible when page has not been scrolled down)<br>
/javascripts/jquery-1.5.1.min.js, http://jquery.com/, http://sizzlejs.com/: required for use of freezeheader below<br>
/javascripts/jquery.freezeheader.js, http://brentmuir.com/projects/freezeheader: freezes table header at the top of the screen when scrolling down

# still to do
make music section functioning<br>
automatic item fill in with UPC code??
