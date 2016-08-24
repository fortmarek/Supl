from dbconnect import connection
import notification
import supl

def get_values(td, date):
    # Navigation through the HTML tree, I recommend looking at bs4 docs and to the source code to understand what's going on
    sibling_index = 0
    suplObject = supl.Supl()
    suplObject.date = date.strftime('%Y-%m-%d')

    for sibling in td.next_siblings:
        if sibling == "\n":
            continue
        suplObject.get_supl(sibling, sibling_index)
        sibling_index += 1
    return suplObject

def supl_to_db(clas_id, supl):
    c, conn = connection()
    sql = "INSERT INTO `changes` (`clas_id`, `date`, `hour`, `change_name`, `subject`, `group_name`," \
          " `professor_for_change`, `professor_usual`, `schoolroom`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
    c.execute(sql, (clas_id, supl.date, supl.hour, supl.change, supl.subject,
                    supl.group, supl.professorForChange, supl.professorUsual, supl.schoolroom))
    conn.commit()
    conn.close()
    return c.lastrowid

def get_class_id(clas_name, school):
    c, conn = connection()
    sql = "SELECT `clas_id` FROM `classes` WHERE `clas_name`=%s AND `school`=%s"
    c.execute(sql, (clas_name, school))
    clas_id = c.fetchone()[0]

    conn.close()
    return clas_id

def get_classes(html):
    clas_list = []

    for td in html.find_all('td', width='11%'):
        if td.text != u'\xa0' and td.text not in clas_list:
            clas_list.append(td.text)

    return clas_list

def compare_changes(changes, clas_id, date, should_compare):
    c, conn = connection()
    sql = "SELECT * FROM `changes` WHERE `clas_id`=%s AND `date`=%s"
    c.execute(sql, (clas_id, date))
    i = 0
    change_id = 0
    old_changes = c.fetchall()

    if len(old_changes) == 0:
        for change in changes:
            if should_compare:
                notification.send_notifications(clas_id, 'clas_id')
            supl_to_db(clas_id, change)

    for change in old_changes:
        if i == 0:
            sql = "SELECT `change_id` FROM `changes` ORDER BY `change_id` DESC LIMIT 1"
            c.execute(sql)
            (change_id) = c.fetchone()

        if i == len(changes) - 1:
            supl_to_db(clas_id, changes[i])
            if len(old_changes) > len(changes) and should_compare:
                notification.send_notifications(clas_id, 'clas_id')
            delete(clas_id, date, change_id)
            break
        else:
            supl_to_db(clas_id, changes[i])

        if not supl.is_supl_same(change, changes[i]):
            if should_compare:
                notification.send_notifications(clas_id, 'clas_id')
            if i < len(changes):
                for change in changes[i + 1:]:
                    supl_to_db(clas_id, change)

                delete(clas_id, date, change_id)
                break
        i += 1
    delete(clas_id, date, change_id)


def delete(clas_id, date, change_id):
    c, conn = connection()
    delete = "DELETE FROM `changes` WHERE `clas_id`=%s AND `date`=%s AND `change_id` <= %s"
    c.execute(delete, (clas_id, date, change_id))
    conn.commit()
    conn.close()


def get_class_data(clas, table, date):

    class_changes = []
    # Need to keep this var => there is always name of the class and then the next changes
    # Are marked in the beginning not by the name but by empty string
    isCurrentClas = False
    for td in table.find_all('td', width='11%'):
        if td.text == clas:
            isCurrentClas = True
            suplObject = get_values(td, date)
            class_changes.append(suplObject)
        elif td.text == u'\xa0' and isCurrentClas:
            suplObject = get_values(td, date)
            class_changes.append(suplObject)
        else:
            isCurrentClas = False
    return class_changes

def data(html, student_tables, dates, school, should_compare):
    clas_list = get_classes(html)
    for clas in clas_list:
        clas_name = " ".join(clas.split()).encode('utf-8')
        clas_to_db(clas_name, school)
        clas_id = get_class_id(clas_name, school)
        tables_count = 0
        for table in student_tables:
            changes = get_class_data(clas, table, dates[tables_count])
            compare_changes(changes, clas_id, dates[tables_count], should_compare)
            tables_count += 1


def clas_to_db(clas_name, school):
    c, conn = connection()
    sql = "SELECT `clas_name`, `school`, `clas_id` FROM `classes` WHERE `clas_name`=%s AND `school`=%s"
    c.execute(sql, (clas_name, school))
    result = c.fetchone()
    if result == None:
        sql = "INSERT INTO `classes` (`clas_name`, `school`) VALUES (%s, %s)"
        c.execute(sql, (clas_name, school))
        clas_id = c.lastrowid
        find_sql = "SELECT `clas_id` FROM `temporary_classes` WHERE `clas_name`=%s AND `school`=%s"
        c.execute(find_sql, (clas_name, school))
        temp_clas = c.fetchone()
        if temp_clas == None:
            conn.commit()
            conn.close()
            return
        temp_clas_id, = temp_clas
        user_sql = "SELECT `user_id` FROM `temp_properties` WHERE `clas_id`=%s"
        c.execute(user_sql, (temp_clas_id))
        for user in c.fetchall():
            user_id = user[0]
            insert_sql = "INSERT INTO `user_properties` (`clas_id`, `user_id`) VALUES (%s, %s)"
            c.execute(insert_sql, (clas_id, user_id))
        delete_user_sql = "DELETE FROM `temp_properties` WHERE `clas_id`=%s"
        c.execute(delete_user_sql, (temp_clas_id))
        delete_sql = "DELETE FROM `temporary_classes` WHERE `clas_name`=%s AND `school`=%s"
        c.execute(delete_sql, (clas_name, school))

    conn.commit()
    conn.close()