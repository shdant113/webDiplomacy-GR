# webDiplomacyRatings

THESE ARE INSTRUCTIONS FOR RUNNING GR. PLEASE FOLLOW ALL OF THEM.
GR IS SUPER SHITTY. IT'S AN AMALGAMATION OF A LOT OF CODE THAT
DIFFERENT PEOPLE WROTE WITHOUT A LOT OF TIME ON THEIR HANDS. IF YOU
FEEL INCLINED TO MAKE IT NICER, PLEASE FIX IT AND UPDATE THIS
DOCUMENT ACCORDINGLY. THANK YOU. -ghug


TO RUN GR:
perl GhostRater_ghug_392431984329.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv [cat#] 6 0 1000000 0 [time]

Arguments are:
command (perl)
script (GostRater....pl)
data dump (ghostRatingData.txt, extract this from the zip at webdiplomacy.net/ghostRatingData.zip)
variant file (defines the variants and how much to weight them)
removed players (we removed banned players for a while but that was weird so we stopped)
cat number (defines which games to include, existing category numbers are hardcoded below)
cutoff length (default six months)
starting game ID (0)
ending game ID (up this number if we ever get to a million games)
starting time (unix time, 0)
ending time (unix time, which is seconds since 01/01/1970 Use https://www.unixtimestamp.com/)

category numbers:
Overall: 510
Gunboat: 318
FP: 82
Live: 494

This outputs a bunch of files called YYYY-MM.csv. Put them in a folder so they're not
overwritten the next time you run it. You can test that you're doing everything
right by checking past months against existing GR from the tournaments site.

GR must be run after midnight GMT on the first of the month in order to capture the last month.


TO RUN ELO:
There's a user named Leonard H. "Bones" McCoy, MD (ID 12530) who seems to have
engineered himself to break everything. Just delete the comma in the data file.
Nobody likes him anyway. There may be more too, so if this is the issue, just
remove their commas as well.

python 1v1_elo.py ghostRatingData.txt 6 0 [time]

Arguments are:
command (python)
script (1v1_elo.py)
data dump
cutoff length (default six months)
start time
end time


TO CLEAN CSVs:
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


GR CATEGORIZE:
This contains some useful tools for segmenting and processing GR data. Mostly
useful for player of the year awards and the like. Hit up ghug;
he won't remember how to use it, but he'll figure it out for you since he's
friendly and he wrote it in the first place.

