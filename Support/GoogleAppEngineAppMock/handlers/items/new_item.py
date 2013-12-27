import webapp2
import json

from models.items import ItemsModel


class NewItem(webapp2.RequestHandler):
    def post(self):
        new_json_item = json.loads(self.request.body)
        ItemsModel.add_item(new_json_item[0]['content'])
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('ADDED')
