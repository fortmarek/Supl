import json


ids = []
urls = []
tokens = []
classes = []


with open('_Installation.json', 'r') as installation:
    data = json.load(installation)
    for result in data['results']:
        #print(result)
        try:
            urls.append(result['url'])
        except KeyError:
            pass
        ids.append(result['installationId'])

        try:
            if result['enabledNotifications'] == True:
                tokens.append(result['deviceToken'])
            else:
                tokens.append(None)
        except KeyError:
            tokens.append(None)
        try:
            clas = result['class'].replace(' ', '')
            classes.append(clas)
        except KeyError:
            pass
        installation.close()

urlss = []
with open('url.json', 'r') as url_file:
    data = json.load(url_file)
    for result in data['results']:
        for url in result['urlArray']:
            urlss.append(url)
print(urlss)