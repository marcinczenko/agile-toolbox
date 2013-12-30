import peewee


class SQLiteModel(peewee.Model):

    @classmethod
    def truncate(cls):
        peewee.RawQuery(cls, 'DELETE FROM question').execute()

    @classmethod
    def create_table_if_does_not_exist(cls):
        if not cls.table_exists():
            cls.create_table()

    class Meta:
        database = peewee.SqliteDatabase('/tmp/agiletoolbox-test.db', threadlocals=True)
        database.connect()
