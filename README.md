## This repository is archived, as the Ghost Ratings have been fully integrated into webDiplomacy.
https://www.webdiplomacy.net/contrib/phpBB3/viewtopic.php?f=5&p=186794#p186794

---


# webDiplomacyRatings

## GhostRatings

Ghost-Rating is an unofficial rating system developed by TheGhostmaker as an alternative to points. It intends to provide a more accurate measure of the ability of players, and also to give a better idea of how well people are doing compared to previously. The original version was developed in 2008, and based on the Elo used in chess; however, the algorithm has been improved several times since then.

This code was written by TheGhostMaker, Alderian, ghug, and bo_sox48. It is currently maintained by me, bo_sox48 on webDiplomacy and shdant on Github. 

More info, and the ratings themselves, at http://tournaments.webdiplomacy.net/theghost-ratingslist.

(I occasionally add a dump of old data to this repo. The files in the dataDump and storeGR directories are stupidly large. Don't download them unless a catastrophy happens and they don't exist anywhere else.)

**Cloning this repo will take a long time because of this. Watch an episode of GoT or something in the meanwhile.**

These instructions were written by ghug and bo_sox48. To run GR, clone this repo and follow these instructions.

These instructions are written for Python 3 users. GR can still be run with Python 2. You also need to have Bash and Perl installed on your machine in order to run GR. The Bash `runall` scripts here are optimized for Mac OS, but the suggested Python `runall` scripts are cross compatible. GR must be run after midnight GMT on the first of the month in order to capture the last month. 

---

### To run GR all at once (recommended):

#### If you are using Python 3:

In your command line, enter:

` python runall.py `

For Python 2 instructions, see below. 

This script will create the default directory to store the GR output in that is configured throughout the GR files. If you have never run GR before, this will allow you to run it immediately without further configuration. If you do not want to use this directory, you will have to configure your own file storage. To do this, change the default directory (variable `name` in `gr_clean.py`) from storeGR/ to whatever you choose, and then do the same where necessary in the `runall.py` file.

This script is configured to run on Mac OS. If you are not on Mac OS, this script can fail. In that case, you can run each script individually without issue.

Prior to running this script, you will need to fix the ghostRatingData text file. The following users need to be removed from the file:

` 
Leonard H. "Bones" McCoy, MD
Dan "kazakhstan" the man, Sheeh 
`

These two users manage to break the 1v1 script by having a comma in their username, and unfortunately I do not know of a way to fix it in Python. Just remove them. Neither is active, and one of them is a multi anyway. 

Once the script begins to run, it should output a bunch of files into the aforementioned directory. Double check that they are all correct by comparing them to last month's data. It should be different, even if only slightly. The easiest way to see this is to check the last column, which shows the last played game. Someone should have a game in the month you're calculating.

If all has gone well, you should have all the files necessary to post GR. If all has not gone well, you might have to run each GR file individually. Directions for doing so can be found below.

---


### To run each GR file individually:

Prior to running this script, you will need to fix the ghostRatingData text file. The following users need to be removed from the file:

` 
Leonard H. "Bones" McCoy, MD
Dan "kazakhstan" the man, Sheeh 
`

These two users manage to break the 1v1 script by having a comma in their username, and unfortunately I do not know of a way to fix it in Python. Just remove them. Neither is active, and one of them is a multi anyway. 

For each non-1v1 script, enter in your command line:

` perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv [cat#] 6 0 1000000 0 [time] `

Arguments:
command (perl)  
script (gr_processDataDump.pl)  
data dump (ghostRatingData.txt, extract this from the zip at webdiplomacy.net/ghostRatingData.zip - if you don't have access, ask someone who does)  
variant file (defines the variants and how much to weight them)  
removed players (we removed banned players for a while but that was weird so we stopped)  
category number (defines which games to include, existing category numbers are hardcoded below)  
cutoff length (default 6 = six months)  
starting game ID (default 0)  
ending game ID (up this number if we ever get to a million games)  
starting time (unix time, default = 0, which is 01/01/1970)  
ending time (unix time, which is seconds since 01/01/1970. Use https://www.unixtimestamp.com/)

Category numbers:  
Overall: 510  
Gunboat: 318  
FP: 82  
Live: 494

This outputs a bunch of files called GhostRatings-YYYY-MM.csv. Put them in a folder so they're not overwritten the next time you run it. You can test that you're doing everything right by checking past months against existing GR from the tournaments site, or by noting that new games are played in the latest games column.


### TO RUN ELO:

#### If you are using Python 3:

` python3 1v1_elo.py ghostRatingData.txt 6 0 [time] `

For Python 2 instructions, see below.

Arguments:  
command (python)  
script (1v1_elo.py)  
data dump  
cutoff length (default 6 = six months)  
start time (default 0)  
end time  

For whatever reason, you may have to enter the end time 1 month in advance in order to capture all games up to the first of this month (i.e. for GR run through November 1, your end time may have to be the unix stamp for December 1). If you know why that is and can fix it, please do. I haven't figured it out. Please double check that your data is not identical to last month's GR and that the last game played column includes games from this month. If you're unsure, run it again this way.


### TO CLEAN CSVs:

When you create them, the outputted CSVs are not human readable and need to be filtered. Create a directory where you store GR data. It should be arranged as follows:


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

` python3 gr_clean.py `

The program will prompt you for input. Enter the year and month (YYYY-MM) of the month you'd like to clean. This makes everything pretty and human-readable. You can also do this step with find/replace in Excel or similar if that's more your speed.

---


### OTHER NECESSARY FILES
RemovedPlayers.csv - A list of players to not consider when running GR.
Formerly used to remove banned players, but currently left empty.
VariantsFile.csv - Settings for weighting of different press and map variants.

## GR Categorize:
gr_categorize.py contains some useful tools for segmenting and processing GR data. Mostly useful for player of the year awards and the like. Hit up ghug; he won't remember how to use it, but he'll figure it out for you since he's friendly and he wrote it in the first place. Bo has no idea so don't ask him.

## EIDRaS Ratings
EIDRaS is an Elo like system for Diplomacy developed decades ago by some other people. Unfortunately, it's name is way worse than Ghost Rating. Check out these links for more information: http://www.stabbeurfou.org/docs/articles/en/DP_S1998R_Diplomacys_New_Rating_System.html and http://uk.diplom.org/pouch//Email/Ratings/JDPR/describe.html.

Adapted for webDiplomacy by Yonni.

## GR Maintainers:

The Ghostmaker, Alderian, jmo1121109, Hellenic Riot, ghug, bo_sox48

---


### Python 2 instructions:

While Python 2 is past its life cycle, you can still use Python 2 to run GR. For the most part, you will use the same instructions as are written above. The only differences are the following:

Instead of running `bash/python runall` to run all scripts, you will need to use this command:

` bash runall_p2.sh `

If you are running each script individually, you can follow the aforementioned instructions for Overall, Classic, Live, and Gunboat ratings. For 1v1, you can follow the aforementioned instructions but will need to use this command in your CLI, substituting your Python 2 alias for `python` if yours is different:

` python 1v1_elo_p2.py ghostRatingData.txt 6 0 [time] `

To clean CSVs, use this command:

` python gr_clean.py `

To contribute to easier maintenance of the Ghost Ratings, feel free to pull down this repository and make improvements. However, more valuable and useful improvements can be made by contributing to webDiplomacy's actual application. Ghost Ratings will be integrated soon, and these scripts will then be deprecated.
