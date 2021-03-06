#!/usr/bin/python


from bs4 import BeautifulSoup
from dbconnect import connection
import requests
import date_module
import classes
import professors
import traceback
from compiler.ast import flatten
import time

def get_html(link):
    # TODO: Install SSL Certificate Before Production
    try:
        r = requests.get(link, verify=False)
    except:
        return False
    soup = BeautifulSoup(r.text, 'html.parser')
    try:
        content = soup.find('meta', attrs={'http-equiv': 'Content-Type'})['content']
        index = content.find('=') + 1
        r.encoding = content[index:]
    except:
        r.encoding = "utf-8"

    text = r.text
    html = BeautifulSoup(text, 'html.parser')
    return html


def get_tables(table_name, old_dates_count, html):
    tables = []
    for table in html.find_all('table', table_name)[old_dates_count:]:
        tables.append(table)
    return tables

# Is the tag from the group that displays all days on one page or not?
def is_tag_simple(tag):
    if tag.find('#tr') != -1 or tag.find('#su') != -1:
        return True
    else:
        return False


# Does the link have ending '.htm'? If it does, then before going to changes page, we need to delete it and then append src
def get_basic_link(link):
    if link.find('.htm') != -1:
        final_link = link.rsplit('/', 1)[0]
        return final_link
    else:
        return link


def get_final_link(basic_link, suffix):
    final_link = basic_link + "/" + suffix
    return final_link


# When every day is on another page, getting the links is a little bit difficult
def get_individual_links(html, basic_link):
    dates = []
    individual_links = []
    if html == False:
        return []
    for string_date in html.find_all('option'):
        date = date_module.get_date(string_date)
        if date_module.is_date_present(date):
            final_link = get_final_link(basic_link, string_date['value'])
            individual_links.append(final_link)
        # Dates are from newest to oldest => in this case it means there is no chance of relevant date
        # No need to go through all of them
        elif len(dates) == 2 and dates[0] < dates[1]:
            break

    return individual_links

def get_schools():
    c, conn = connection()
    sql = "SELECT `school` FROM `schools`"
    c.execute(sql)
    schools = [school[0] for school in c.fetchall()]
    conn.close()
    return schools


def is_school_in_db(school):
    c, conn = connection()

    sql = "SELECT `school` FROM `schools` WHERE `school`=%s"
    c.execute(sql, (school))
    result = c.fetchone()
    if result == None:
        sql = "INSERT INTO `schools` (`school`) VALUES (%s)"
        c.execute(sql, (school))
        conn.commit()
        conn.close()
        return False
    else:
        conn.close()
        return True




def get_links(html, link):
    frame = html.find('frame', attrs={'name': 'surrmmdd'})

    try:
        src = frame['src']
    except TypeError:
        return []
    basic_link = get_basic_link(link)
    if is_tag_simple(src):
        final_link = get_final_link(basic_link, src)
        return [final_link]
    else:
        head_link = html.find('frame', attrs={'name': 'suplhlav'})['src']
        # That's how it's called in the original but translated (Czech in programming sucks :/ )
        head_basic_link = basic_link + "/" + head_link
        head_html = get_html(head_basic_link)
        return get_individual_links(head_html, basic_link)


def get_index(html):
    # FIX: Definitely need to check the values of the tags
    a = html.find('a')

    try:
        if a['name'].find('tr') != -1:
            return "1"
        else:
            return "3"
    except:
        return "3"


def fix_tables(html, old_dates_count, index, dates):
    dates_number = old_dates_count
    #print("D: {0}", (dates))
    for paragraph in html.body.find_all('p', recursive=False):
        try:
            if paragraph['class'][0] == 'textnormal_' + index and dates_number < len(dates) - 2:
                dates.pop(dates_number - 1)
                dates_number -= 1
                if len(dates) == 0:
                    return dates
            if paragraph['class'][0] == 'textlarge_' + index:
                dates_number += 1
        except KeyError:
            continue
        #except IndexError:
        #    print(dates)
        #    print(html)
    return dates

def get_data(html, school, should_compare):
    # Indexes in names of CSS classes vary
    index = get_index(html)

    # Getting dates and count of old ones (don't need to extract data from those)
    (dates, old_dates_count) = date_module.get_dates(html, index)

    student_tables = get_tables('tb_supltrid_' + index, old_dates_count, html)
    professor_tables = get_tables('tb_suplucit_' + index, old_dates_count, html)

    if len(student_tables) < len(dates):
        dates = fix_tables(html, old_dates_count, index, dates)

    if len(dates) != 0 and len(student_tables) != 0:
        classes.data(html, student_tables, dates, school, should_compare)
    if len(dates) != 0 and len(professor_tables) != 0:
        professors.data(html, professor_tables, dates, school, should_compare)
    return dates


def delete_dates_not_present_for_professors(dates, school):
    c, conn = connection()

    select = "SELECT DISTINCT professor_changes.date FROM professor_changes, professors WHERE professors.school=%s" \
             " AND professor_changes.professor_id = professors.professor_id"
    c.execute(select, (school))
    all_dates = [date[0] for date in c.fetchall()]
    dates = flatten(dates)
    for date in all_dates:

        if date.date() not in dates:

            delete = "DELETE professor_changes FROM professor_changes JOIN professors ON professor_changes.professor_id = professors.professor_id" \
                     " WHERE professors.school=%s AND professor_changes.date=%s"
            c.execute(delete, (school, date))
    conn.commit()
    conn.close()

def delete_dates_not_present_for_clases(dates, school):
    c, conn = connection()

    select = "SELECT DISTINCT changes.date FROM changes, classes WHERE classes.school=%s" \
             " AND changes.clas_id = classes.clas_id"
    c.execute(select, (school))
    all_dates = [date[0] for date in c.fetchall()]
    dates = flatten(dates)

    for date in all_dates:

        if date.date() not in dates:
            delete = "DELETE changes FROM changes JOIN classes ON changes.clas_id = classes.clas_id WHERE classes.school=%s" \
                     " AND changes.date=%s"

            c.execute(delete, (school, date))
    conn.commit()
    conn.close()

def get_school_data(school, should_compare):

    # Initial html given by the user
    html = get_html(school)
    if html == False:
        return
    if html.text == "":
        return

    # Dates that are relevant and exist on the web
    current_dates = []

    # Changes not displayed on the initial html
    if html.find('a') == None:
        # Get individual links where the changes are stored and iterate through them
        links_list = get_links(html, school)
        for link in links_list:
            html = get_html(link)
            if html == False or html.text == "":
                continue
            dates = get_data(html, school, should_compare)
            current_dates.append(dates)
    else:
        dates = get_data(html, school, should_compare)
        current_dates.append(dates)
    delete_dates_not_present_for_professors(current_dates, school)
    delete_dates_not_present_for_clases(current_dates, school)

def check_school(school):
    if not is_school_in_db(school):
        get_school_data(school, False)


def run_scrape():
    import time
    timestamp = time.time()
    number = 0
    for line in reversed(list(open('/home/scrape/log-file.txt'))):
        try:
            number = int(line.rstrip().split()[-1]) + 1
            file = open('/home/scrape/log-file.txt', 'a')
            file.write("Run %d\n" % number)
            file.close()
            break
        except:
            pass
    if number == 0:
        file = open('/home/scrape/log-file.txt', 'w')
        file.write("Run %d\n" % number)
        file.close()

    schools = get_schools()

    try:
        for school in schools:
            print(school)
      #  for i in range(0, 1):
      #      school = 'http://old.gjk.cz/suplovani.php'
            get_school_data(school, True)
        file = open('/home/scrape/log-file.txt', 'a')
        file.write("Success\n")
        file.close()
    except Exception as e:
        file = open('/home/scrape/log-file.txt', 'a')
        file.write("%s\n" % traceback.format_exc())
        file.close()


# Mark session => notifications will not be sent twice

if __name__ == "__main__":
    run_scrape()








