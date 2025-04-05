-- Create materialized view for latest resource status
CREATE MATERIALIZED VIEW beta.v_latest_resource_status AS (
    WITH rank_list AS(
        SELECT
            resource_id,
            id,
            checked_at, 
            rank() OVER (PARTITION BY resource_id ORDER BY checked_at desc) as ranking
        FROM beta.resource_status
    )
    SELECT *
    FROM rank_list
    WHERE ranking = 1
);

-- Create view for resource previews
CREATE VIEW beta.v_resource_previews AS (
    SELECT 
        r.*,
        rs.id as latest_status_id,
        rs.checked_at as latest_status_timestamp,
        rs.status as latest_status,
        rs.status_code as latest_status_code,
        rs.status_text as latest_status_text
    FROM
        beta.resources r
    LEFT JOIN
        beta.v_latest_resource_status v
        ON r.id = v.resource_id
    LEFT JOIN
        beta.resource_status rs
        ON v.id = rs.id
);

-- Create view for collection previews
CREATE VIEW beta.v_collection_previews AS (
    WITH resource_counts AS (
        SELECT 
            collection_id,
            count(distinct(resource_id)) as linked_resources_count
        FROM
            beta.collection_resources
        GROUP BY 1
    ),
    primary_resources AS (
        SELECT
            collection_id,
            resource_id
        FROM
            beta.collection_resources
        WHERE is_primary = True
        -- TODO: Need to enforce that there is not more than 1 "primary" per collection
    )
    SELECT 
        c.*,
        rc.linked_resources_count,
        r.url as primary_resource_url
        -- TODO: Add here any business logic for determining overall collection status
        --  from the constituent resource statuses.
    FROM
        beta.collections c
    LEFT JOIN
        resource_counts rc
        ON c.id = rc.collection_id
    LEFT JOIN
        primary_resources pr
        ON c.id = pr.collection_id
    LEFT JOIN
        beta.resources r
        ON pr.resource_id = r.id
);
