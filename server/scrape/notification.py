# -*- coding: utf-8 -*-

from apns import APNs, Frame, Payload
from dbconnect import connection
import config
import time
import random

def get_tokens(id, property_type):
    c, conn = connection()
    tokens = []
    sql = "SELECT DISTINCT `user_id` FROM `user_properties` WHERE %s =%%s" % (property_type,)
    c.execute(sql, (id))
    users = c.fetchall()
    for user in users:
        token_sql = "SELECT `token` FROM `users` WHERE `user_id`=%s"
        c.execute(token_sql, (user))
        try:
            token = c.fetchone()[0]
            if token != None or token != 'NULL':
                tokens.append(token)
        except TypeError:
            continue
    conn.close()
    return tokens


def response_listener(error_response):
    file = open('/home/scrape/log-file.txt', 'a')
    file.write("Failed with: %s\n" % error_response)
    file.close()

def send_notifications(id, property_type):

    # Frame for sending multiple notifications
    # frame = Frame()
    # expiry = int(time.time()) + (60 * 60) # 1 hour
    # priority = 10

    apns = APNs(use_sandbox=True, cert_file=config.CERT, enhanced=True)
    message = unicode('Změna rozvrhu', 'utf-8')
    payload = Payload(alert=message, sound="default", badge=0, mutable_content=True)

    tokens = get_tokens(id, property_type)

    for token in tokens:

        if token == 'NULL' or token == None or token == '32bytes':
            continue

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

        if should_notify:
            file = open('/home/scrape/log-file.txt', 'a')
            file.write("Sent to %s\n" % token)
            file.close()

            apns.gateway_server.send_notification(token, payload)
            #identifier = random.getrandbits(32)
            #frame.add_item('c8a31f47c7b598bb3173c61e9243afd5cbea0530b5a0f96469c3def3b3d9c0b5', payload, identifier, expiry, priority)
            #frame.add_item(token, payload, identifier,
            #               expiry, priority)

    #apns.gateway_server.register_response_listener(response_listener)
    #apns.gateway_server.send_notification_multiple(frame)

