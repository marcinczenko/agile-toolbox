import webapp2
import json
from datetime import datetime

from models.questions import QuestionRepository


class ItemsJSON(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'application/json'

        page = self.request.get('page')

        if not page:
            items = QuestionRepository.all()
        else:
            items = QuestionRepository.fetch_page(int(page))

        items_json = []
        for item in items:
            items_json.append({'content': item.content, 'timestamp': item.timestamp.strftime('%A %d-%m-%Y %H:%M')})

        self.response.out.write(json.dumps(items_json))
