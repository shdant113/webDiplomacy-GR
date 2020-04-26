## THIS FILE IS FOR PYTHON 2. IF YOU RUN PYTHON 3, USE RUNALL.SH ##


## This file will run GR for the given month. 
## This script is optimized for usage on Mac OS because I use it. 
## Bash is different on different systems. This script may fail.
## If the script fails, you can run each GR script individually without issue.
## Instructions can be found at https://github.com/shdant113/webDiplomacy-GR.

if [ ! -d "/storeGR" ] 
	then 
		mkdir -p "storeGR" 
		echo "This run of GR will be stored in ./storeGR"
fi

# Retrieves first day of the month
# For reasons I do not know, the old GR scripts (not 1v1) want the first day
# of the next month. The new GR script (1v1) wants the first day of this month.
not1v1Date=$(date -v+1m -v1d +%s)
is1v1Date=$(date -v1d +%s)

echo $not1v1Date
echo $is1v1Date

# Overall GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 510 6 0 1000000 0 $not1v1Date
mv months Overall/
mv Overall storeGR/

# Gunboat GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 318 6 0 1000000 0 $not1v1Date
mv months Gunboat/
mv Gunboat storeGR/

# FP GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 82 6 0 1000000 0 $not1v1Date
mv months Classic/
mv Classic storeGR/

# Live GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 494 6 0 1000000 0 $not1v1Date
mv months Live/
mv Live/ storeGR/

# 1v1 GR
python 1v1_elo_p2.py ghostRatingData.txt 6 0 $is1v1Date
mv 1v1 storeGR

# clean CSVs
python gr_clean.py

