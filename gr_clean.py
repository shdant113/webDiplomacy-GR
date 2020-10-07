# Cleans CSVs for GR to make them human readable
# Written by ghug, maintained by bo_sox48

import csv, sys

input_date = ''
if len(sys.argv) > 1:
    input_date = sys.argv[1]
else:
    input_date = input('year-month (yyyy-mm): ')

changes = [   # a dictionary of changes to make, find 'key' substitue with 'value'
    ('\"-\"0', ''), # I assume both 'key' and 'value' are strings
    ('\"', '')
    ]

banned = '\"-\"1'

name = 'storeGR/'
date = 'GhostRatings-' + input_date + '.csv'

def clean(filename):
    new_rows = [] # a holder for our modified rows when we make them
    ban_count = 0
    first = True
    with open(filename, 'rb') as f:
        reader = csv.reader(f) # pass the file to our csv reader
        for row in reader:     # iterate over the rows in the file
            new_row = []    # at first, just copy the row
            add = True
            for x in row:
                changed = False
                if banned in x:
                    ban_count += 1
                    add = False
                for key, value in changes:
                    if key in x:
                        x = x.replace(key, value)
                new_row.append(x)
            if add:
                if first:
                    first = False
                else:
                    new_row[0] = str(int(new_row[0]) - ban_count)
                new_rows.append(new_row) # add the modified rows
        

    with open(filename, 'wb') as f:
        # Overwrite the old file with the modified rows
        writer = csv.writer(f)
        writer.writerows(new_rows)

clean(name+'Overall/'+date)
clean(name+'Live/'+date)
clean(name+'Classic/'+date)
clean(name+'Gunboat/'+date)

