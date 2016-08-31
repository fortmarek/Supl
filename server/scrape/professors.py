#!/usr/bin/env python
# -*- coding: utf-8 -*-

import professor
import date_module
import notification
from dbconnect import connection


def get_values(td, date):
    # Navigation through the HTML tree, I recommend looking at bs4 docs and to the source code to understand what's going on
    sibling_index = 0
    professor_object = professor.Professor()
    professor_object.date = date.strftime('%Y-%m-%d')

    for sibling in td.next_siblings:
        if sibling == "\n":
            continue

        professor_object.get_supl(sibling, sibling_index)
        sibling_index += 1
    return professor_object

def change_to_db(professor_id, prof):
    c, conn = connection()

    sql = "INSERT INTO `professor_changes` (`professor_id`, `date`, `hour`, `change_name`, `subject`, `clas`,`schoolroom`, `reason`)" \
          " VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"

    c.execute(sql, (professor_id, prof.date, prof.hour, prof.change, prof.subject,
                    prof.clas, prof.schoolroom, prof.reason))
    conn.commit()
    conn.close()
    return c.lastrowid

def get_prof_id(prof_name, school):
    c, conn = connection()
    sql = "SELECT `professor_id` FROM `professors` WHERE `professor`=%s AND `school`=%s"
    c.execute(sql, (prof_name, school))
    professor_id = c.fetchone()[0]

    conn.close()
    return professor_id

def get_professors(html):
    prof_list = []

    for td in html.find_all('td', width='27%'):
        if td.text != u'\xa0' and td.text not in prof_list:
            prof_list.append(td.text)

    return prof_list

def compare_changes(changes, prof_id, date, should_compare):
    c, conn = connection()
    sql = "SELECT * FROM `professor_changes` WHERE `professor_id`=%s AND `date`=%s"
    c.execute(sql, (prof_id, date))
    i = 0
    change_id = 0
    old_changes = c.fetchall()

    if len(old_changes) == 0:
        for change in changes:
            if should_compare:
                notification.send_notifications(prof_id, 'professor_id')
            change_to_db(prof_id, change)

    for change in old_changes:
        if i == 0:
            sql = "SELECT `change_id` FROM `professor_changes` ORDER BY `change_id` DESC LIMIT 1"
            c.execute(sql)
            (change_id) = c.fetchone()
        if i == len(changes) - 1:
            change_to_db(prof_id, changes[i])
            if len(old_changes) > len(changes) and should_compare:
                notification.send_notifications(prof_id, 'professor_id')
            delete(prof_id, date, change_id)
            break
        else:
            change_to_db(prof_id, changes[i])

        if not professor.is_change_same(change, changes[i]):
            if should_compare:
                notification.send_notifications(prof_id, 'professor_id')
            if i < len(changes):
                for change in changes[i + 1:]:
                    change_to_db(prof_id, change)
                delete(prof_id, date, change_id)
                break
        i += 1
    delete(prof_id, date, change_id)

def delete(prof_id, date, change_id):
    c, conn = connection()
    delete = "DELETE FROM `professor_changes` WHERE `professor_id`=%s AND `date`=%s AND `change_id` <= %s"
    c.execute(delete, (prof_id, date, change_id))
    conn.commit()
    conn.close()

def get_prof_data(professor, table, date):

    prof_changes = []
    # Need to keep is_current_clas => there is always name of the class and then the next changes
    # Are marked in the beginning not by the name but by empty string
    is_current_clas = False
    for td in table.find_all('td', width='27%'):
        if td.text == professor:
            is_current_clas = True
            professor_object = get_values(td, date)
            prof_changes.append(professor_object)

        elif td.text == u'\xa0' and is_current_clas:
            professor_object = get_values(td, date)
            prof_changes.append(professor_object)

        else:
            is_current_clas = False
    return prof_changes

def data(html, professor_tables, dates, school, should_compare):
    prof_list = get_professors(html)
    for professor in prof_list:
        prof_name = " ".join(professor.split()).encode('utf-8')
        prof_to_db(prof_name, school)
        professor_id = get_prof_id(prof_name, school)
        tables_count = 0
        prof_changes = []
        for table in professor_tables:
            changes = get_prof_data(professor, table, dates[tables_count])
            prof_changes += changes
            compare_changes(prof_changes, professor_id, dates[tables_count], should_compare)
            tables_count += 1


def prof_to_db(prof_name, school):
    c, conn = connection()

    sql = "SELECT `professor`, `school`, `professor_id` FROM `professors` WHERE `professor`=%s AND `school`=%s"
    c.execute(sql, (prof_name, school))
    result = c.fetchone()
    if result == None:
        sql = "INSERT INTO `professors` (`professor`, `school`) VALUES (%s, %s)"
        c.execute(sql, (prof_name, school))
        prof_id = c.lastrowid
        find_sql = "SELECT `professor_id` FROM `temporary_professors` WHERE `professor`=%s AND `school`=%s"
        c.execute(find_sql, (prof_name, school))
        temp_prof = c.fetchone()
        if temp_prof == None:
            conn.commit()
            conn.close()
            return
        temp_prof_id, = temp_prof
        user_sql = "SELECT `user_id` FROM `temp_properties` WHERE `professor_id`=%s"
        c.execute(user_sql, (temp_prof_id))
        for user in c.fetchall():
            user_id = user[0]
            insert_sql = "INSERT INTO `user_properties` (`professor_id`, `user_id`) VALUES (%s, %s)"
            c.execute(insert_sql, (prof_id, user_id))
        delete_user_sql = "DELETE FROM `temp_properties` WHERE `professor_id`=%s"
        c.execute(delete_user_sql, (temp_prof_id))
        delete_sql = "DELETE FROM `temporary_professors` WHERE `professor`=%s AND `school`=%s"
        c.execute(delete_sql, (prof_name, school))
    conn.commit()
    conn.close()