import webapp2


class Ready(webapp2.RequestHandler):
    URL = '/ready'

    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('OK')
