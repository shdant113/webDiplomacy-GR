# rm ghostRatingData.txt
# wget https://webdiplomacy.net/ghostRatingData.txt
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 510 6 0 1000000 0 `date +%s`
mv months Overall/
mv Overall storeGR/
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 318 6 0 1000000 0 `date +%s`
mv months Gunboat/
mv Gunboat storeGR/
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 82 6 0 1000000 0 `date +%s`
mv months Classic/
mv Classic storeGR/
perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv 494 6 0 1000000 0 `date +%s`
mv months Live/
mv Live/ storeGR/
python 1v1_elo.py ghostRatingData.txt 6 0 `date +%s`
mv 1v1 storeGR
python gr_clean.py