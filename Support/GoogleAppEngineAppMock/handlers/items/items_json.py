import webapp2
import json

from models.items import ItemsModel

class ItemsJSON(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'application/json'
        
        items_json = []
        for item in ItemsModel.all():
            items_json.append({'content':item})
            
        self.response.out.write(json.dumps(items_json))
