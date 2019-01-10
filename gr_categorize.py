import csv, sys, zipfile
from collections import Counter

##copyright ghug, whenever now is

##script takes ghostrating zip file as argument, extracts into a directory
##inside the zip's parent directory, and adds filtered files for ghostrating
##categories as defined below

##categories in human readable format to allow for easy changing
##keys are data to filter, values are lists of values to match
classic = {'variantID':['1'],
           'potType':['Winner-takes-all', 'Sum-of-squares'],
           'phaseMinutes':['60', '120', '240', '360', '480', '600', '720',
                           '840', '960', '1080', '1200', '1320', '1440',
                           '1500', '2160', '2880', '3000', '4320', '5760',
                           '7200', '8640', '10080', '14400'],
           'pressType':['Regular', 'RulebookPress']}

gunboat = {'pressType':['NoPress']}

live = {'phaseMinutes':['5', '10', '15', '30']}

livegunboat = {'variantID':['1'],
               'pressType':['NoPress'],
               'phaseMinutes':['5', '10', '15', '30']}

longgunboat = {'variantID':['1'],
               'pressType':['NoPress'],
               'phaseMinutes':['60', '120', '240', '360', '480', '600', '720',
                           '840', '960', '1080', '1200', '1320', '1440',
                           '1500', '2160', '2880', '3000', '4320', '5760',
                           '7200', '8640', '10080', '14400']}

liveclassic = {'variantID':['1'],
               'potType':['Winner-takes-all', 'Sum-of-squares'],
               'phaseMinutes':['5', '10', '15', '30'],
               'pressType':['Regular', 'RulebookPress']}

nonlive = {'phaseMinutes':['60', '120', '240', '360', '480', '600', '720',
                           '840', '960', '1080', '1200', '1320', '1440',
                           '1500', '2160', '2880', '3000', '4320', '5760',
                           '7200', '8640', '10080', '14400']}

vs = {'variantID':['15', '23']}

fva = {'variantID':['15']}

gvi = {'variantID':['23']}

overall = {}

startdate = 1483228800

enddate = 1514764799

##categories = [classic, gunboat, live]
##filenames = ['classicGRData.txt', 'gunboatGRData.txt', 'liveGRData.txt']

categories = [classic, livegunboat, liveclassic, longgunboat, overall, live,
              nonlive, vs, fva, gvi]
      
filenames = ['longClassicGRData.txt', 'liveGunboatGRData.txt',
             'liveClassicGRData.txt', 'longGunboatGRData.txt',
             'overallGRData.txt', 'liveGRData.txt', 'nonliveGRData.txt']

num_cats = len(categories)
data = []
users = []
userdict = {}
for i in range(num_cats):
    data.append([])

##takes the first line of the csv file and converts the category descriptions
##from being based on data names to column numbers
##isolated so the category descriptions don't change if the dump does
def get_category_filters(columns):
    return map(lambda x: map(lambda y: x.get(y), columns), categories)    

##given a row of the csv (game) and a filter list for a category, return true
##iff the row belongs in the category
def match_row_filter(row, filt, row_len):
    for i in range(row_len):
        if filt[i]:
            if row[i] not in filt[i]:
                return False
    return True

def categorize(directory, export=True):
    with open(directory + 'ghostRatingData.txt', 'rb') as f:
        reader = csv.reader(f)
        header = reader.next()
        row_len = len(header)
        filters = get_category_filters(header)
        for row in reader:
            if len(row) == row_len:
                if row[10] != '':
                    time = int(row[10])
                    #if time > startdate and time < enddate and row[7] != 'Unranked':
                    if time > startdate and time < enddate:
                        for i in range(num_cats):
                            if match_row_filter(row, filters[i], row_len):
                                data[i].append(row)
            else:
                ##second csv
                for i in range(num_cats):
                    users.append(row)
                    userdict[row[0]] = row[1]

    if export:    
        for i in range(num_cats):
            with open(directory + filenames[i], 'wb') as f:
                writer = csv.writer(f)
                writer.writerows(data[i])
                writer.writerows(users)

def count_stat_percentage(category, column, stats, min_total=0):
    counts = Counter()
    totals = Counter()
    for row in data[category]:
        if row[column] in stats:
            counts[row[2]] += 1
        totals[row[2]] += 1
    percentages = []
    for user, count in counts.iteritems():
        if totals[user] >= min_total:
            percentages.append((userdict[user], float(count) / totals[user]))
    percentages.sort(key=lambda x: x[1], reverse=True)
    return percentages

def count_stat(category, column, stats):
    counts = Counter()
    for row in data[category]:
        if row[column] in stats:
            counts[row[2]] += 1
    totals = []
    for user, count in counts.iteritems():
        totals.append((userdict[user], count))
    totals.sort(key=lambda x: x[1], reverse=True)
    return totals

if __name__ == '__main__':
    z = zipfile.ZipFile(sys.argv[1])
    directory = sys.argv[1][:-4] + '/'
    z.extractall(directory)
    categorize(directory)
