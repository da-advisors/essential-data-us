from .db import DatabaseInstance


class CollectionRepository:
    def __init__(self, db: DatabaseInstance):
        self.db = db
        pass

    def all(self):
        return self.db.query(
            """
            SELECT * FROM beta.collections;
            """
        )

    def find_by_id(self, id: str):
        return self.db.query(
            """
            SELECT * FROM beta.collections WHERE id = %s;
            """,
            {'id': id},
        )

    def all_previews(self):
        return self.db.query(
            """
            SELECT * FROM beta.v_collection_previews;
            """
        )

    def find_resources_by_collection_id(self, collection_id: str):
        return self.db.query(
            """
            WITH linkages AS (
                SELECT
                    collection_id,
                    resource_id,
                    is_primary
                FROM beta.collection_resources
                WHERE collection_id = %s
            )
            SELECT 
                r.*,
                linkages.is_primary 
            FROM beta.resources r
            LEFT JOIN
                linkages
                ON r.id = linkages.resource_id;
            """,
            {'collection_id': collection_id},
        )
