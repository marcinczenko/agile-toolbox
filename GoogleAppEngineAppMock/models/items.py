
class ItemsModel(object):
    number_of_test_items = 0;
    
    @staticmethod
    def all():
        return ["Test Item%d" % (item_index) for item_index in range(0,ItemsModel.number_of_test_items)]
    
