# webDiplomacyRatings

## GhostRatings

Ghost-Rating is an unofficial rating system developed by TheGhostmaker as an alternative to points. It intends to provide a more accurate measure of the ability of players, and also to give a better idea of how well people are doing compared to previously. The original version was developed in 2008, and based on the Elo used in chess, however the algorithm has been improved several times since then.

This code was written by TheGhostMaker, Alderian, and ghug. It is currently maintained by me, bo_sox48 on webDiplomacy. 

More info, and the ratings themselves, at http://tournaments.webdiplomacy.net/theghost-ratingslist

I occasionally add a dump of old data to this repo. The files in the dataDump and storeGR directories are stupidly large. Don't download them unless a catastrophy happens and they don't exist anywhere else.

These instructions were written by ghug.

---

THESE ARE INSTRUCTIONS FOR RUNNING GR. PLEASE FOLLOW ALL OF THEM.
GR IS SUPER SHITTY. IT'S AN AMALGAMATION OF A LOT OF CODE THAT
DIFFERENT PEOPLE WROTE WITHOUT A LOT OF TIME ON THEIR HANDS. IF YOU
FEEL INCLINED TO MAKE IT NICER, PLEASE FEEL FREE TO FIX IT. THANKS.

### TO RUN GR:
perl processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv [cat#] 6 0 1000000 0 [time]

Arguments:
command (perl)  
script (processDataDump.pl)  
data dump (ghostRatingData.txt, extract this from the zip at webdiplomacy.net/ghostRatingData.zip)  
variant file (defines the variants and how much to weight them)  
removed players (we removed banned players for a while but that was weird so we stopped)  
cat number (defines which games to include, existing category numbers are hardcoded below)  
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

GR must be run after midnight GMT on the first of the month in order to capture the last month.

### TO RUN ELO:
There's a user named Leonard H. "Bones" McCoy, MD (ID 12530) who seems to have
engineered himself to break everything. Just delete the comma in the data file.
Nobody likes him anyway. There may be more too, so if this is the issue, just
remove their commas as well.

python 1v1_elo.py ghostRatingData.txt 6 0 [time]

Arguments:  
command (python)  
script (1v1_elo.py)  
data dump  
cutoff length (default 6 = six months)  
start time (default 0)  
end time  

### TO CLEAN CSVs:
Create a directory where you store GR data. It should be arranged as follows:
...dir/  
	Overall/  
		2017-01.csv  
		2017-02.csv  
		2017-03.csv  
		...  
	Live/  
		2017-01.csv  
		...  
	Classic/  
		2017-01.csv  
		...  
	Gunboat/  
		2017-01.csv  
		...

Change line 12 of gr_clean.py so that the directory matches your new directory.
All of this only needs to be done once. New GR should just be arranged in this
directory.

python gr_clean.py

The program will prompt you for input. Enter the year and month (YYYY-MM) of the
month you'd like to clean. This makes everything pretty and human-readable. You
can also do this step with find/replace in Excel or similar if that's more your
speed.

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
