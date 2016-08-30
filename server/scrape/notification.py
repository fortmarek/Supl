# -*- coding: utf-8 -*-

from apns import APNs, Frame, Payload
from dbconnect import connection
import config
import time
import random


def get_tokens(id, property_type):
    c, conn = connection()
    tokens = []
    sql = "SELECT `user_id` FROM `user_properties` WHERE %s =%%s" % (property_type,)
    c.execute(sql, (id))
    users = c.fetchall()
    for user in users:
        token_sql = "SELECT `token` FROM `users` WHERE `user_id`=%s"
        c.execute(token_sql, (user))
        token = c.fetchone()[0]
        if token != None or token != 'NULL':
            tokens.append(token)
    conn.close()
    return tokens



def send_notifications(id, property_type):

    # Frame for sending multiple notifications
    frame = Frame()
    expiry = time.time() + 3600
    priority = 10

    apns = APNs(use_sandbox=True, cert_file=config.CERT, enhanced=True)
    message = unicode('Změna rozvrhu', 'utf-8')
    payload = Payload(alert=message, sound="default", badge=0, mutable_content=True)

    tokens = get_tokens(id, property_type)

    should_notify = False

    for token in tokens:
        should_notify = True
        for line in reversed(list(open('/home/scrape/log-file.txt'))):
            try:
                # Finds the start of session
                int(line.rstrip().split()[-1])
                break
            except:
                if line.rstrip().find(token) != -1:
                    should_notify = False
                    break
        if should_notify and token != 'NULL':
            file = open('/home/scrape/log-file.txt', 'a')
            file.write("Sent to %s\n" % token)
            file.close()

            identifier = random.getrandbits(32)
            frame.add_item(token, payload, identifier, expiry, priority)

    if should_notify:
        pass
        #apns.gateway_server.send_notification_multiple(frame)
