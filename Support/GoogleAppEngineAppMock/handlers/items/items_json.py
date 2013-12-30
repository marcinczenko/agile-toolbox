import webapp2
import json

from models.questions import QuestionRepository


class ItemsJSON(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'application/json'

        number_of_items_to_be_fetched = self.request.get('n')

        if not number_of_items_to_be_fetched:
            items = QuestionRepository.all()
        else:
            items = QuestionRepository.fetch(int(number_of_items_to_be_fetched))

        items_json = []
        for item in items:
            items_json.append({'content': item})

        self.response.out.write(json.dumps(items_json))
