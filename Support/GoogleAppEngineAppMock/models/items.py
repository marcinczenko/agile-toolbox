
class ItemsModel(object):
    items = []
    
    @staticmethod
    def all():
        return ItemsModel.items

    @staticmethod
    def fetch(n):
        return ItemsModel.items[0:n]
    
    @staticmethod
    def add_item(item):
        ItemsModel.items.insert(0, item)
            
    @staticmethod
    def populate(number_of_items):
        ItemsModel.items = ["Test Item%d" % item_index for item_index in range(0, number_of_items)]
