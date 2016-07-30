import json
from dbconnect import connection

def insert_property(c, table, clas_id, user):
    find = "SELECT * FROM %s WHERE `clas_id`=%%s AND `user_id`=%%s" % (table,)
    c.execute(find, (clas_id, user))
    if c.fetchone() == None:
        property = "INSERT INTO %s (clas_id, user_id) VALUES (%%s, %%s)" % (table,)
        c.execute(property, (clas_id, user))

with open('_Installation.json', 'r') as installation:
    c, conn = connection()
    data = json.load(installation)
    for result in data['results']:
        url = ""
        try:
            url = result['url'].encode('utf-8')
            sql = "SELECT * FROM `schools` WHERE `school`=%s"
            c.execute(sql, (url))
            if c.fetchone() == None:
                add_sql = "INSERT INTO `schools` (`school`) VALUES (%s)"
                c.execute(add_sql, (url))
        except KeyError:
            pass

        id = result['installationId'].encode('utf-8')
        sql = "SELECT * FROM `users` WHERE `user_id`=%s"
        c.execute(sql, (id))
        if c.fetchone() == None:
            add_sql = "INSERT INTO `users` (`user_id`) VALUES (%s)"
            c.execute(add_sql, (id))

        token = ""

        try:
            if result['enabledNotifications'] == True:
                token = result['deviceToken'].encode('utf-8')
            else:
                token = "NULL"
        except KeyError:
            token = "NULL"
        token_sql = "SELECT * FROM `users` WHERE `user_id`=%s"
        c.execute(token_sql, (id))
        if c.fetchone() != None:
            add_sql = "UPDATE `users` SET `token`=%s WHERE `user_id`=%s;"
            c.execute(add_sql, (token, id))

        try:
            clas = result['class'].replace(' ', '').encode('utf-8')
            sql = "SELECT `clas_id` FROM `classes` WHERE `clas_name`=%s AND `school`=%s"
            c.execute(sql, (clas, url))
            clas_object = c.fetchone()
            if clas_object == None:
                temp_sql = "SELECT * FROM `temporary_classes` WHERE `clas_name`=%s AND `school`=%s"
                c.execute(temp_sql, (clas, url))
                clas_object = c.fetchone()
                if clas_object == None:
                    temp_add = "INSERT INTO `temporary_classes` (clas_name, school) VALUES (%s, %s)"
                    c.execute(temp_add, (clas, url))
                    clas_id = c.lastrowid
                    insert_property(c, "temp_properties", clas_id, id)
                else:
                    clas_id = clas_object[0]
                    insert_property(c, "temp_properties", clas_id, id)
            else:
                clas_id = clas_object[0]
                insert_property(c, "user_properties", clas_id, id)
        except KeyError:
            pass
        installation.close()
        conn.commit()


