import webapp2
import cgi
import os.path

from handlers.items.items_json import ItemsJSON
from handlers.items.new_item import NewItem
from handlers.helpers import Ready
from models.items import ItemsModel

app = webapp2.WSGIApplication([('/items_json',ItemsJSON),
                               ('/ready',Ready),
                               ('/new_json_item',NewItem)],
                               debug=True)

def main():
   from paste import httpserver
   import argparse
   
   parser = argparse.ArgumentParser()
   parser.add_argument('-n',action="store",default=0,dest="number_of_items",type=int,help="Number of test items in data store after initialization.")

   ItemsModel.populate(parser.parse_args().number_of_items)
   
   file_dir = os.path.dirname(os.path.abspath(__file__))
   
   # httpserver.serve(app, host='192.168.0.31', ssl_pem='CA/192.168.0.31/server.pem')
   # httpserver.serve(app, host='localhost', port='443', ssl_pem='CA/localhost/server.pem')
   httpserver.serve(app, host='quantumagiletoolbox-dev.appspot.com', port='443', ssl_pem=os.path.join(file_dir,'CA/new-quantumagiletoolbox-dev.appspot.com/server.pem'))

if __name__ == '__main__':
   main()
