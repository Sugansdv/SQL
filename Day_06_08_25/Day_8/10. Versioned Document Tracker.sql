CREATE DATABASE VersionedDocDB;

USE VersionedDocDB;

CREATE TABLE Documents (
    doc_id INT,
    doc_name VARCHAR(100),
    version INT,
    content TEXT,
    dependency_doc_id INT,
    created_at DATE
);

INSERT INTO Documents VALUES
(1, 'UserGuide', 1, 'Initial version', NULL, '2023-01-01'),
(1, 'UserGuide', 2, 'Added FAQ section', NULL, '2023-02-01'),
(1, 'UserGuide', 3, 'Updated screenshots', NULL, '2023-03-01'),
(2, 'APIReference', 1, 'Initial API', 1, '2023-01-15'),
(2, 'APIReference', 2, 'Added endpoints', 1, '2023-02-20'),
(3, 'IntegrationDoc', 1, 'Integrates UserGuide and APIReference', 2, '2023-03-10'),
(4, 'DeprecatedDoc', 1, 'Old guide', NULL, '2022-01-01');

-- ROW_NUMBER() to list versions per document
SELECT 
    doc_id,
    doc_name,
    version,
    ROW_NUMBER() OVER (PARTITION BY doc_id ORDER BY version DESC) AS version_rank
FROM Documents;

-- LAG() to compare changes between versions
SELECT 
    doc_id,
    doc_name,
    version,
    content,
    LAG(content) OVER (PARTITION BY doc_id ORDER BY version) AS previous_content
FROM Documents;

-- WITH RECURSIVE to trace dependencies between documents
WITH RECURSIVE DependencyTree AS (
    SELECT 
        doc_id,
        doc_name,
        version,
        dependency_doc_id,
        1 AS level
    FROM Documents
    WHERE dependency_doc_id IS NULL
    UNION ALL
    SELECT 
        d.doc_id,
        d.doc_name,
        d.version,
        d.dependency_doc_id,
        dt.level + 1
    FROM Documents d
    JOIN DependencyTree dt ON d.dependency_doc_id = dt.doc_id
)
SELECT * FROM DependencyTree;

-- CTEs for filtering current, outdated, or broken versions
WITH VersionRanks AS (
    SELECT 
        doc_id,
        doc_name,
        version,
        ROW_NUMBER() OVER (PARTITION BY doc_id ORDER BY version DESC) AS rn
    FROM Documents
),
BrokenDocs AS (
    SELECT d.*
    FROM Documents d
    LEFT JOIN Documents dep ON d.dependency_doc_id = dep.doc_id
    WHERE d.dependency_doc_id IS NOT NULL AND dep.doc_id IS NULL
)
SELECT * FROM VersionRanks WHERE rn = 1 -- current versions
UNION ALL
SELECT * FROM VersionRanks WHERE rn > 1 -- outdated versions
UNION ALL
SELECT * FROM BrokenDocs; -- broken dependencies
