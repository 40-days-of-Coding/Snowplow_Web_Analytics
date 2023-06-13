-- Select this data from the Street Trees dataset and transport it into a target table
-- Find the 10 addresses with the most trees planted along the street 
-- Find the number of trees at each address

SELECT
    address,
    COUNT(address) AS number_of_trees
FROM
    bigquery-public-data.san_francisco_trees.street_trees
WHERE
    address != "null"
GROUP BY address
ORDER BY number_of_trees DESC
LIMIT 10;
