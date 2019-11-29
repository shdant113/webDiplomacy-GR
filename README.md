# webDiplomacyRatings

## GhostRatings

Ghost-Rating is an unofficial rating system developed by TheGhostmaker as an alternative to points. It intends to provide a more accurate measure of the ability of players, and also to give a better idea of how well people are doing compared to previously. The original version was developed in 2008, and based on the Elo used in chess; however, the algorithm has been improved several times since then.

This code was written by TheGhostMaker, Alderian, ghug, and bo_sox48. It is currently maintained by me, bo_sox48 on webDiplomacy and shdant on Github. 

More info, and the ratings themselves, at http://tournaments.webdiplomacy.net/theghost-ratingslist.

(I occasionally add a dump of old data to this repo. The files in the dataDump and storeGR directories are stupidly large. Don't download them unless a catastrophy happens and they don't exist anywhere else.)

**Cloning this repo will take a long time because of this. Watch an episode of GoT or something in the meanwhile.**

These instructions were written by ghug and bo_sox48. To run GR, clone this repo and follow these instructions.

You need to have the Bash shell and Perl installed on your machine in order to run GR. GR must be run after midnight GMT on the first of the month in order to capture the last month.

---


### To run GR all at once (recommended):

In your command line, enter:

` bash runall.sh `

This script will create the default directory to store the GR output in that is configured throughout the GR files. If you have never run GR before, this will allow you to run it immediately without further configuration. If you do not want to use this directory, you will have to configure your own file storage. To do this, change the default directory on line 12 in gr_clean.py from storeGR/ to whatever you choose, and then do the same where necessary in the runall.sh file.

Prior to running this script, you will need to fix the ghostRatingData text file. The following users need to be removed from the file:

` 70000, 108388, 108982, 108980, 108983, 108979, 108978, 12530, 86197 `

Included in this group of users are the webDip AI bot accounts (who win a lot of games and do well particularly in 1v1, so it is necessary to remove them to keep the ratings pure) and some users who seem to have engineered themselves 
to break everything by having commas in their usernames despite only logging in like four times total. If there are more users that break the script, the error will only show up when running 1v1. Just remove them as well.

This should output a bunch of files into the aforementioned directory. Double check that they are all correct by comparing them to last month's data. It should be different, even if only slightly. Be careful with 1v1 in particular, as for some reason that I haven't yet figured out it sometimes runs last month instead of this month. In this case, you'll have to follow the instructions below for running ELO and use the unix date for the first of the following month, which will cover all games up to the first of this past month. If you can figure out what causes this and fix it, please do. 

Once the files have been exported, the program will prompt you for input. Enter the year and month (YYYY-MM) of the
month you'd like to clean. This makes everything pretty and human-readable. You can also do this step with find/replace in Excel or similar if that's more your speed.

If all has gone well, you should have all the files necessary to post GR. If all has not gone well, you might have to run each GR file individually. Directions for doing so can be found below.

---


### To run each GR file individually:

Prior to running this script, you will need to fix the ghostRatingData text file. The following users need to be removed from the file:

` 70000, 108388, 108982, 108980, 108983, 108979, 108978, 12530, 86197 `

Included in this group of users are the webDip AI bot accounts (who win a lot of games and do well particularly in 1v1, so it is necessary to remove them to keep the ratings pure) and some users who seem to have engineered themselves 
to break everything by having commas in their usernames despite only logging in like four times total. If there are more users that break the script, the error will only show up when running 1v1. Just remove them as well.

In your command line, enter:

` perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv [cat#] 6 0 1000000 0 [time] `

Arguments:
command (perl)  
script (gr_processDataDump.pl)  
data dump (ghostRatingData.txt, extract this from the zip at webdiplomacy.net/ghostRatingData.zip - 
if you don't have access, ask someone who does)  
variant file (defines the variants and how much to weight them)  
removed players (we removed banned players for a while but that was weird so we stopped)  
category number (defines which games to include, existing category numbers are hardcoded below)  
cutoff length (default 6 = six months)  
starting game ID (default 0)  
ending game ID (up this number if we ever get to a million games)  
starting time (unix time, default = 0, which is 01/01/1970)  
ending time (unix time, which is seconds since 01/01/1970 Use https://www.unixtimestamp.com/)

Category numbers:  
Overall: 510  
Gunboat: 318  
FP: 82  
Live: 494

This outputs a bunch of files called YYYY-MM.csv. Put them in a folder so they're not
overwritten the next time you run it. You can test that you're doing everything
right by checking past months against existing GR from the tournaments site.


### TO RUN ELO:

` python 1v1_elo.py ghostRatingData.txt 6 0 [time] `

Arguments:  
command (python)  
script (1v1_elo.py)  
data dump  
cutoff length (default 6 = six months)  
start time (default 0)  
end time  

For whatever reason, you may have to enter the end time 1 month in advance in order to capture all games up to the first of this month (i.e. for GR run through November 1, your end time may have to be the unix stamp for December 1). If you know why that is and can fix it, please do. I haven't figured it out. Please double check that your data is not identical to last month's GR and that the last game played column includes games from this month. If you're unsure, run it again this way.


### TO CLEAN CSVs:
Create a directory where you store GR data. It should be arranged as follows:


...dir/  
&nbsp;&nbsp;&nbsp;Overall/  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2017-01.csv  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2017-02.csv  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2017-03.csv  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...  
&nbsp;&nbsp;&nbsp;Live/  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2017-01.csv  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...  
&nbsp;&nbsp;&nbsp;Classic/  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2017-01.csv  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...  
&nbsp;&nbsp;&nbsp;Gunboat/  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2017-01.csv  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...


Change line 12 of gr_clean.py so that the directory matches your new directory.
All of this only needs to be done once. New GR should just be arranged in this
directory. You can then run:

` python gr_clean.py `

The program will prompt you for input. Enter the year and month (YYYY-MM) of the
month you'd like to clean. This makes everything pretty and human-readable. You
can also do this step with find/replace in Excel or similar if that's more your
speed.

---


### OTHER NECESSARY FILES
RemovedPlayers.csv - A list of players to not consider when running GR.
Formerly used to remove banned players, but currently left empty.
VarianstFile.csv - Settings for weighting of different press and map variants.

## GR Categorize:
gr_categorize.py contains some useful tools for segmenting and processing GR data. Mostly
useful for player of the year awards and the like. Hit up ghug;
he won't remember how to use it, but he'll figure it out for you since he's
friendly and he wrote it in the first place. Bo has no idea so don't ask him.

## EIDRaS Ratings
EIDRaS is an Elo like system for Diplomacy developed decades ago by some other people. Unfortunately, it's name is way worse than Ghost Rating. Check out these links for more information:
http://www.stabbeurfou.org/docs/articles/en/DP_S1998R_Diplomacys_New_Rating_System.html
and
http://uk.diplom.org/pouch//Email/Ratings/JDPR/describe.html

Adapted for webDiplomacy by Yonni.

## GR Maintainers:

The Ghostmaker, Alderian, jmo1121109, Hellenic Riot, ghug, bo_sox48
