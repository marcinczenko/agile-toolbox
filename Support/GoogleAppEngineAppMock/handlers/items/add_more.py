import webapp2

from models.questions import QuestionRepository


class AddMore(webapp2.RequestHandler):
    def get(self):
        number_of_items_to_add = self.request.get('n')
        if not number_of_items_to_add:
            number_of_items_to_add = 10

        QuestionRepository.populate(int(number_of_items_to_add))

        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('OK')
