import re
from datetime import datetime

#### DATE ####

def get_date(date):
    date_string = re.search('\d{1,2}\.{1}\d{1,2}\.{1}\d{4}?', date.text).group(0)
    date = datetime.strptime(date_string, '%d.%m.%Y').date()
    return date

# I.E. is the date in the past?

def is_date_present(date):
    today = datetime.now()

    if today.date() > date:
        return False
    elif today.date() == date:
        if today.hour > 18:
            return False
        else:
            return True
    else:
        return True


def is_date_relevant(date):
    # converted_date = datetime.strptime("30.4.2016", '%d.%m.%Y')
    today = datetime.now()
    #today = datetime.strptime("22.6.2016", "%d.%m.%Y")

    if today.date() > date:
        return False
    elif today.date() == date:
        # In reality it's 14, time is not the same everywhere
        # TODO: Uncomment
        if today.hour > 8:
            return False
        else:
            return True
    else:
        return True


def get_dates(html, index):
    dates = []
    old_dates_count = 0
    for string_date in html.find_all('p', class_='textlarge_' + index):
        date = get_date(string_date)

        if is_date_present(date):
            dates.append(date)
        else:
            old_dates_count += 1
    return (dates, old_dates_count)
