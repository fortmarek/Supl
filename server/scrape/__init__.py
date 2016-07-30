from flask import Flask
from flask_restful import Resource, Api
from templates.dbconnect import connection
import pymysql
app = Flask(__name__)
api = Api(app)

conn = connection()
c = conn.cursor(pymysql.cursors.DictCursor)

class User(Resource):
    def get(self, user_id):
        json = {}
        sql = "SELECT `clas_id` FROM `user_classes` WHERE `user_id`=%s"
        c.execute(sql, (user_id))
        classes = [clas[0] for clas in c.fetchall()]
        for clas_id in classes:
            sql = "SELECT * FROM `changes` WHERE `clas_id`=%s"
            clas_json = c.execute(sql, (clas_id))
            json.update(clas_json)

        return json

api.add_resource(User, '/users/<user_id>')

if __name__ == '__main__':
    app.run(debug=True)


def clas_to_db(clas, school):
    c, conn = connection()

    sql = "SELECT `clas_name`, `school` FROM `classes` WHERE `clas_name`=%s AND `school`=%s"
    c.execute(sql, (clas, school))
    result = c.fetchone()
    if result == None:
        sql = "INSERT INTO `classes` (`clas_name`, `school`) VALUES (%s, %s)"
        c.execute(sql, (clas, school))
    conn.commit()
    conn.close()
