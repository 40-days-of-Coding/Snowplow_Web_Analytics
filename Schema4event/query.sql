
SELECT *
FROM raw.snowplow.event
WHERE collector_tstamp > '2020-04-22 18:00:00'
 and app_id = 'clrcrl.com'
 
LIMIT 100
