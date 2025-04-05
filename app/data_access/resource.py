from .db import DatabaseInstance


class ResourceRepository:
    def __init__(self, db: DatabaseInstance):
        self.db = db
        pass

    def all(self):
        return self.db.query(
            """
            SELECT * FROM beta.resources
            """
        )

    def find_by_id(self, id):
        return self.db.query(
            """
            SELECT * FROM beta.resources WHERE id = %s
            """,
            {'id': id},
        )

    def all_previews(self):
        return self.db.query(
            """
            SELECT * FROM beta.v_resource_previews
            """
        )
