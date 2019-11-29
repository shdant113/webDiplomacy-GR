
## This file will run GR for a given month. 
## If the script fails, you can run each GR script individually.
## Instructions can be found at https://github.com/shdant113/webDiplomacy-GR.

if [ ! -d "/storeGR" ] 
	then 
		mkdir -p "storeGR" 
		echo "This run of GR will be stored in ./storeGR"
fi

# Overall GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 510 6 0 1000000 0 `date +%s`
mv months Overall/
mv Overall storeGR/

# Gunboat GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 318 6 0 1000000 0 `date +%s`
mv months Gunboat/
mv Gunboat storeGR/

# FP GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 82 6 0 1000000 0 `date +%s`
mv months Classic/
mv Classic storeGR/

# Live GR
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 494 6 0 1000000 0 `date +%s`
mv months Live/
mv Live/ storeGR/

# 1v1 GR
python 1v1_elo.py ghostRatingData.txt 6 0 `date +%s`
mv 1v1 storeGR
python gr_clean.py

