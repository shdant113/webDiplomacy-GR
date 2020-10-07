"""
Runs all scripts necessary in order to process GR for the current month.

System requirements:
Python 3, Perl, Bash

I (bo_sox48) wrote this script for myself, so if you end up maintaining GR, you may need to set your Python 3 CLI alias to "python"
or just change the commands in this script to match your Python 3 alias

If something breaks, read the stack carefully. Odds are it is not this script that is broken

"""

import os
from datetime import datetime
from dateutil import relativedelta

# Run each category of GR
def run_category(date, category = "Elo", num = 0):
    if category != "Elo":
        os.system('perl gr_processDataDump.pl ghostRatingData.txt Variantsfile.csv RemovedPlayers.csv ' + str(num) + ' 6 0 1000000 0 ' + date.strftime('%s'))
        os.system('mv months ' + category)
        os.system('mv ' + category + ' storeGR')
    else:
        os.system('python 1v1_elo.py ghostRatingData.txt 6 0 ' + date.strftime('%s'))
        os.system('mv 1v1 storeGR')

# Clean CSVs, make them publishable
def clean(date):
    os.system('python gr_clean.py ' + date)

# Main executable
def exec(categories, reg_date, elo_date, clean_date):
    num = 0
    for c in categories: 
        if c == "Overall":
            num = 510
        elif c == "Gunboat":
            num = 318
        elif c == "Classic":
            num = 82
        elif c == "Live":
            num = 494

        if c != "Elo": 
            print("Calculating " + c + " ratings")
            run_category(reg_date, c, num)
        else:
            print("Calculating 1v1 ratings")
            run_category(elo_date)

    clean(clean_date)


if __name__ == '__main__':
    if not os.path.exists('storeGR'):
        os.makedirs('storeGR')

    # All current GR categories
    categories = ["Overall", "Gunboat", "Classic", "Live", "Elo"]

    # Retrieve first date of the month
    date = datetime.today().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    clean_date = str(date.year) + '-' + str(date.month)

    # For some reason, ELO wants the first date of next month. Idk
    elo_date = date + relativedelta.relativedelta(months=1)

    print("This run of GR will be stored in the /storeGR directory.")

    exec(categories, date, elo_date, clean_date)

