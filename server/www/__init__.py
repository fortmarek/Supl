#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, jsonify, render_template
from flask_restful import Resource, Api, abort, reqparse
from templates.dbconnect import connection
import requests
from bs4 import BeautifulSoup

app = Flask(__name__, static_url_path="", static_folder="static")
api = Api(app)

class User(Resource):
    def get(self, user_id):
        c, conn = connection()
        json = {}
        json['clas_changes'] = []
        json['prof_changes'] = []
        clas_sql = "SELECT `clas_id` FROM `user_properties` WHERE `user_id`=%s AND `clas_id` IS NOT NULL"
        c.execute(clas_sql, (user_id))
        clas_ids = [clas_id[0] for clas_id in c.fetchall()]
        for clas_id in clas_ids:

                sql = "SELECT * FROM `changes` WHERE `clas_id`=%s ORDER BY date, change_id"
                c.execute(sql, (clas_id))
                clas_changes = c.fetchall()

                name_sql = "SELECT `clas_name` FROM `classes` WHERE `clas_id`=%s"
                c.execute(name_sql, (clas_id))
                clas_name = c.fetchone()[0]
                for change in clas_changes:
                    change_json = {}
                    change_json['clas_name'] = clas_name
                    change_json['change_id'] = change[0]
                    change_json['date'] = change[1].strftime('%d.%m.%Y')
                    change_json['properties'] = {}
                    property_json = {}
                    property_json['hour'] = change[2]
                    property_json['change'] = change[3]
                    property_json['subject'] = change[4]
                    property_json['group'] = change[5]
                    property_json['schoolroom'] = change[6]
                    property_json['professor_for_change'] = change[7]
                    property_json['professor_usual'] = change[8]
                    change_json['properties'] = property_json
                    json['clas_changes'].append(change_json)

        professor_sql = "SELECT `professor_id` FROM `user_properties` WHERE `user_id`=%s AND `professor_id` IS NOT NULL"
        c.execute(professor_sql, (user_id))
        prof_ids = [prof_id[0] for prof_id in c.fetchall()]

        for prof_id in prof_ids:
            prof_name_sql = "SELECT `professor` FROM `professors` WHERE `professor_id`=%s"
            c.execute(prof_name_sql, (prof_id))
            prof_name = c.fetchone()[0]
            sql = "SELECT * FROM `professor_changes` WHERE `professor_id`=%s ORDER BY date, hour"
            c.execute(sql, (prof_id))
            prof_changes = c.fetchall()
            for change in prof_changes:
                change_json = {}
                change_json['prof_name'] = prof_name
                change_json['change_id'] = change[0]
                change_json['date'] = change[1].strftime('%d.%m %y')
                change_json['properties'] = {}
                property_json = {}
                property_json['hour'] = change[2]
                property_json['change'] = change[3].replace(' ', '')
                property_json['subject'] = change[4]
                property_json['clas'] = change[5]
                property_json['schoolroom'] = change[6]
                property_json['professor_for_change'] = change[7]
                property_json['professor_usual'] = ""
                change_json['properties'] = property_json
                json['prof_changes'].append(change_json)

        conn.close()
        return jsonify(json)

    def post(self, user_id):
        c, conn = connection()
        sql = "SELECT * FROM `users` WHERE `user_id`=%s"
        c.execute(sql, (user_id))
        if c.fetchone() == None:
            post_sql = "INSERT INTO `users` (`user_id`) VALUES (%s)"
            c.execute(post_sql, (user_id))
            conn.commit()
        conn.close()

parser = reqparse.RequestParser()
parser.add_argument('school', type=str)
parser.add_argument('user', type=str)
parser.add_argument('key', type=str)
parser.add_argument('user', type=str)
parser.add_argument('clas', type=str)
parser.add_argument('token', type=str)
parser.add_argument('prof')

class Notification(Resource):
    def post(self, user_id):
        c, conn = connection()
        args = parser.parse_args()
        token = args['token']
        sql = "SELECT * FROM `users` WHERE `user_id`=%s AND `token`=%s"
        c.execute(sql, (user_id, token))
        if c.fetchone() == None:
            put_sql = "UPDATE `users` SET `token`=%s WHERE `user_id`=%s"
            c.execute(put_sql, (token, user_id))
            conn.commit()
        conn.close()
    def delete(self, user_id):
        c, conn = connection()
        sql = "UPDATE `users` SET `token`= NULL WHERE `user_id`=%s"
        c.execute(sql, (user_id))
        conn.commit()
        conn.close()


class Clas(Resource):
    def post(self):
        c, conn = connection()
        args = parser.parse_args()
        clas = args['clas'].encode('utf-8')
        school = args['school']
        user = args['user']
        sql = "SELECT `clas_id` FROM `classes` WHERE `clas_name`=%s AND `school`=%s"
        c.execute(sql, (clas, school))
        clas_object = c.fetchone()
        if clas_object == None:
            temp_sql = "SELECT * FROM `temporary_classes` WHERE `clas_name`=%s AND `school`=%s"
            c.execute(temp_sql, (clas, school))
            clas_object = c.fetchone()
            if clas_object == None:
                temp_add = "INSERT INTO `temporary_classes` (clas_name, school) VALUES (%s, %s)"
                c.execute(temp_add, (clas, school))
                clas_id = c.lastrowid
                insert_clas_property(c, "temp_properties", clas_id, user)
            else:
                clas_id = clas_object[0]
                insert_clas_property(c, "temp_properties", clas_id, user)
        else:
            clas_id = clas_object[0]
            insert_clas_property(c, "user_properties", clas_id, user)
        conn.commit()
        conn.close()

    def delete(self):
        c, conn = connection()
        args = parser.parse_args()
        clas = args['clas']
        file = open('/home/scrape/log-apache.txt', 'a')
        file.write("%s\n" % clas)
        file.close()
        school = args['school']
        user = args['user']
        sql = "SELECT `clas_id` FROM `classes` WHERE `clas_name`=%s AND `school`=%s"
        c.execute(sql, (clas, school))
        clas_object = c.fetchone()
        if clas_object == None:
            temp_sql = "SELECT * FROM `temporary_classes` WHERE `clas_name`=%s AND `school`=%s"
            c.execute(temp_sql, (clas, school))
            clas_object = c.fetchone()
            if clas_object != None:
                clas_id = clas_object[0]
                delete_clas_property(c, "temp_properties", clas_id, user)
        else:
            clas_id = clas_object[0]
            delete_clas_property(c, "user_properties", clas_id, user)
        conn.commit()
        conn.close()


def insert_clas_property(c, table, clas_id, user):
    find = "SELECT * FROM %s WHERE `clas_id`=%%s AND `user_id`=%%s" % (table,)
    c.execute(find, (clas_id, user))
    if c.fetchone() == None:
        property = "INSERT INTO %s (clas_id, user_id) VALUES (%%s, %%s)" % (table,)
        c.execute(property, (clas_id, user))

def delete_clas_property(c, table, clas_id, user):
    find = "SELECT * FROM %s WHERE `clas_id`=%%s AND `user_id`=%%s" % (table,)
    c.execute(find, (clas_id, user))
    if c.fetchone() != None:
        property = "DELETE FROM %s WHERE `clas_id`=%%s AND `user_id`=%%s" % (table,)
        c.execute(property, (clas_id, user))

class Prof(Resource):
    def post(self):
        c, conn = connection()
        args = parser.parse_args()
        prof = args['prof'].encode('utf-8')
        school = args['school']
        user = args['user']
        sql = "SELECT `professor_id` FROM `professors` WHERE `professor`=%s AND `school`=%s"
        c.execute(sql, (prof, school))
        prof_object = c.fetchone()
        if prof_object == None:
            temp_sql = "SELECT * FROM `temporary_professors` WHERE `professor`=%s AND `school`=%s"
            c.execute(temp_sql, (prof, school))
            prof_object = c.fetchone()
            if prof_object == None:
                temp_add = "INSERT INTO `temporary_professors` (professor, school) VALUES (%s, %s)"
                c.execute(temp_add, (prof, school))
                prof_id = c.lastrowid
                insert_prof_property(c, "temp_properties", prof_id, user)
            else:
                prof_id = prof_object[0]
                insert_prof_property(c, "temp_properties", prof_id, user)
        else:
            prof_id = prof_object[0]
            insert_prof_property(c, "user_properties", prof_id, user)
        conn.commit()
        conn.close()

    def delete(self):
        c, conn = connection()
        args = parser.parse_args()
        prof = args['prof'].encode('utf-8')
        school = args['school']
        user = args['user']
        sql = "SELECT `professor_id` FROM `professors` WHERE `professor`=%s AND `school`=%s"
        c.execute(sql, (prof, school))
        prof_object = c.fetchone()
        if prof_object == None:
            temp_sql = "SELECT * FROM `temporary_professors` WHERE `professor`=%s AND `school`=%s"
            c.execute(temp_sql, (prof, school))
            prof_object = c.fetchone()
            if prof_object != None:
                prof_id = prof_object[0]
                delete_prof_property(c, "temp_properties", prof_id, user)
        else:
            prof_id = prof_object[0]
            delete_prof_property(c, "user_properties", prof_id, user)
        conn.commit()
        conn.close()

def insert_prof_property(c, table, prof_id, user):
    find = "SELECT * FROM %s WHERE `professor_id`=%%s AND `user_id`=%%s" % (table,)
    c.execute(find, (prof_id, user))
    if c.fetchone() == None:
        property = "INSERT INTO %s (professor_id, user_id) VALUES (%%s, %%s)" % (table,)
        c.execute(property, (prof_id, user))

def delete_prof_property(c, table, prof_id, user):
    find = "SELECT * FROM %s WHERE `professor_id`=%%s AND `user_id`=%%s" % (table,)
    c.execute(find, (prof_id, user))
    if c.fetchone() != None:
        property = "DELETE FROM %s WHERE `professor_id`=%%s AND `user_id`=%%s" % (table,)
        c.execute(property, (prof_id, user))

class School(Resource):
    def post(self):
        c, conn = connection()
        # TODO: Key authentication
        args = parser.parse_args()
        school = args['school']
        try:
            r = requests.get(school, verify=False)
            r.encoding = 'iso-8859-2'
            text = r.text
            html = BeautifulSoup(text, 'html.parser')
            title = html.title
            if title.text.encode('ascii', 'ignore').find("Bakali") == -1:
                conn.close()
                abort(400, message="URL není z Bakaláři")
        except:
            abort(400, message="Neplatné URL")

        import sys
        import os
        sys.path.append(os.path.abspath("/home/scrape"))
        from scrape import check_school
        check_school(school)

        return {"message" : "Povedlo se"}


api.add_resource(User, '/users/<string:user_id>')
api.add_resource(School, '/schools')
api.add_resource(Clas, '/classes')
api.add_resource(Prof, '/professors')
api.add_resource(Notification, '/users/<string:user_id>/notification')


# THIS IS FOR PORTFOLIO (I'M SAVING MYSELF SOME TIME AND RESOURCES AND MONEY   ...

@app.route('/')
def html():
    return render_template('main.html')



