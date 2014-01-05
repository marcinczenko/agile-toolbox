import webapp2
import json
import time
from datetime import datetime

from models.questions import QuestionRepository


class ItemsJSON(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'application/json'

        number_of_items_to_fetch = self.request.get('n')
        threshold_id = self.request.get('id')

        if not threshold_id:
            threshold_id = -1

        time.sleep(1)

        if not number_of_items_to_fetch:
            items = QuestionRepository.all()
        else:
            items = QuestionRepository.fetch(int(number_of_items_to_fetch), int(threshold_id))

        items_json = []
        for item in items:
            items_json.append({'id': item.id, 'content': item.content,
                               'timestamp': item.timestamp.strftime('%A %d-%m-%Y %H:%M')})

        self.response.out.write(json.dumps(items_json))
