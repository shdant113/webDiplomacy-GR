import csv, datetime, sys, os
from collections import Counter
from bisect import bisect_left

variant_ids =  ["15", "23"]
default_rating = 100.0
k = 32

##There's a user named Leonard H. "Bones" McCoy, MD (ID 12530) who seems to have
##engineered himself to break everything. Just delete the comma in the data file.
##Nobody likes him anyway

##splits the file into two lists of lines, the first containing 1v1 game data
##and the second containing usernames
def read_file(path, time_cutoff):
    game_lines = []
    users={}
    with open(path) as f:
        reader = csv.reader(f)#, quotechar='"', escapechar='\\', quoting=csv.QUOTE_ALL)
        l = len(reader.next())
        for row in reader:
            if len(row) == l:
                if row[10] == '':
                    continue
                time = int(row[10])
                if row[0] in variant_ids and time <= time_cutoff[1] and time >= time_cutoff[0]:
                    game_lines.append(row)
            else:
                break
        reader.next()
        for row in reader:
            users[row[0]] = (row[1], int(row[2]))
    game_lines.sort(key=lambda x: int(x[10]))
    return game_lines, users

def process_games(lines, users):
    ratings = {}
    peak_ratings = {}
    last_dates = {}
    games = Counter()
    old_games = Counter()
    old_ratings = {}
    old_ranks = {}
    month = datetime.datetime.fromtimestamp(int(lines[0][10])
                                            ).strftime('%Y-%m')
    for i in range(0, len(lines), 2):
        id1 = lines[i][2]
        id2 = lines[i+1][2]
        if id1 in ratings:
            r1 = ratings[id1]
        else:
            r1 = default_rating
            peak_ratings[id1] = default_rating
        if id2 in ratings:
            r2 = ratings[id2]
        else:
            r2 = default_rating
            peak_ratings[id2] = default_rating
        if lines[i][5] == 'Drawn':
            result = .5
        elif lines[i][5] == 'Won':
            result = 1
        else:
            result = 0
        new_ratings = process_game(r1, r2, result)
        ratings[id1], ratings[id2]= new_ratings
        peak_ratings[id1] = max(peak_ratings[id1], new_ratings[0])
        peak_ratings[id2] = max(peak_ratings[id2], new_ratings[1])
        finish_time = int(lines[i][10])
        last_dates[id1] = finish_time
        last_dates[id2] = finish_time
        new_month = datetime.datetime.fromtimestamp(int(lines[i][10])
                                            ).strftime('%Y-%m')
        games[id1] += 1
        games[id2] += 1
        if new_month != month:
            month = new_month
            old_ranks = export_month(month, ratings, last_dates, games,
                                     old_games, old_ratings, old_ranks,
                                     peak_ratings, users)
            old_games = dict(games)
            old_ratings = dict(ratings)

##result is 1 for p1 win, .5 for draw, 0 for loss
def process_game(r1, r2, result):
    R1 = 10**(r1/400)
    R2 = 10**(r2/400)
    E1 = R1 / (R1 + R2)
    E2 = R2 / (R1 + R2)
    S2 = 1 - result
    r1 += k * (result - E1)
    r2 += k * (S2 - E2)
    return r1, r2

def export_month(monthstr, ratings, last_dates, games, old_games, old_ratings,
                 old_ranks, peak_ratings, users):
    year, month = map(int, monthstr.split('-'))
    cut = year * 12 + month - dropoff
    cut_year = cut / 12
    cut_month = cut % 12
    if cut_month == 0:
        cut_month = 12
        cut_year -= 1
    unix_cut = (datetime.datetime(cut_year, cut_month, 1) -
                datetime.datetime(1970, 1, 1)).total_seconds()
    sort = []
    lines = []
    
    for user, time in last_dates.iteritems():
        if time > unix_cut and not users[user][1]:
            rating = ratings[user]
            line = [0, users[user][0], user, rating, games[user],
                    peak_ratings[user]]
            if user in old_ranks:
                line.append(0)
                line.append(games[user] - old_games[user])
                line.append(rating - old_ratings[user])
            elif user in old_ratings:
                line.append("Re-Entry")
                line.append("Re-Entry")
                line.append("Re-Entry")
            else:
                line.append("New Entry")
                line.append("New Entry")
                line.append("New Entry")
            line.append(datetime.datetime.fromtimestamp(int(last_dates[user])
                                            ).strftime('%Y-%m-%d'))
            i = bisect_left(sort, rating)
            sort.insert(i, rating)
            lines.insert(len(lines) - i, line)

    ranks = {}

    for i in range(len(lines)):
        lines[i][0] = i + 1
        if lines[i][6] == 0:
            lines[i][6] = old_ranks[lines[i][2]] - (i + 1)
        ranks[lines[i][2]] = i + 1

    lines.insert(0, ['Rank', 'Player', 'PlayerID', 'Elo Rating',
                     'Games Played', 'Peak Elo Rating', 'ChangeRank',
                     'ChangeGames', 'ChangeRating', 'Last Game Date'])

    with open('1v1/' + monthstr + '.csv', 'w') as csvfile:
        writer = csv.writer(csvfile, lineterminator='\n')
        for line in lines:
            writer.writerow(line)

    print(monthstr + ' exported')
    return ranks

    
            
            

##args
##rating data file
##months before dropoff
##start time
##end time
##python 1v1_elo.py ghostRatingData.txt 6 0 [time]
if __name__ == '__main__':
    if len(sys.argv) != 5:
        print("incorrect usage")
        sys.exit(0)
    datafile, dropoff, a, b = sys.argv[1:]
    dropoff = int(dropoff)
    if not os.path.exists('1v1'):
        os.makedirs('1v1')
    games, users = read_file(datafile, (int(a), int(b)))
    process_games(games, users)

