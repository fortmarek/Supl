import requests
from bs4 import BeautifulSoup
from dbconnect import connection

c, conn = connection()

sql = "SELECT * FROM schools"
c.execute(sql, ())
for (school,) in c.fetchall():
    try:
        r = requests.get(school, verify=False)
        r.encoding = 'iso-8859-2'
        text = r.text
        html = BeautifulSoup(text, 'html.parser')
        title = html.title
        print(school)
        print(title.text.encode('ascii', 'ignore'))
        if title.text.encode('ascii', 'ignore').find("Bakali - Supl") == -1:
            delete_sql = "DELETE FROM schools WHERE school =%s"
            c.execute(delete_sql, (school))
            conn.commit()
    except:
        print(school)


conn.close()