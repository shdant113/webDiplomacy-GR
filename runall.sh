rm ghostRatingData.txt
wget https://webdiplomacy.net/ghostRatingData.txt
perl GhostRater_ghug_392431984329.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 510 6 0 1000000 0 `date +%s`
mv months/* data/Overall/
perl GhostRater_ghug_392431984329.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 318 6 0 1000000 0 `date +%s`
mv months/* data/Gunboat/
perl GhostRater_ghug_392431984329.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 82 6 0 1000000 0 `date +%s`
mv months/* data/Classic/
perl GhostRater_ghug_392431984329.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 494 6 0 1000000 0 `date +%s`
mv months/* data/Live/
python 1v1_elo_new.py ghostRatingData.txt 6 0 `date +%s`
mv 1v1/* data/1v1/
python gr_clean.py
