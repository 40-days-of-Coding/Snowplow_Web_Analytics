<div class="entry-content clr" itemprop="text">
	
<h2>Using SQL to generate bulk data for Postgres&nbsp;table</h2>

<figure class="wp-block-image"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*8wUp9BxHcT7UCAyFHRZy4w.png" alt=""/></figure>

<h2><strong>Introduction</strong></h2>

<ul>
<li>Generating sample data for database testing is one of the common steps.</li>

<li>In the previous articles, we covered how to generate sample data in bulk <a href="https://medium.com/javarevisited/how-to-generate-mock-data-in-java-ff3b5f66f167" target="_blank" rel="noreferrer noopener"><strong>using plain Java</strong></a><strong> </strong>and <a href="https://medium.com/javarevisited/how-to-generate-sample-data-using-regex-in-java-1a7095be5ff0" target="_blank" rel="noreferrer noopener"><strong>using regex</strong></a>.</li>

<li>In this article, we will learn how we can use SQL and Postgres functions to generate N number of sample records in seconds.</li>
</ul>

<h2><strong>Schema</strong></h2>

<ul>
<li>Our schema is an <strong><em>Account</em></strong> table that looks like below which contains different columns such as username, password, email, etc.</li>
</ul>

<figure class="wp-block-image alignwide"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*ySurJrtykP2b1WOHqqfZGQ.png" alt=""/></figure>

<h2><strong>Generating Single Account Record</strong></h2>

<p><strong>Generating Random Usernames</strong></p>

<ul>
<li>Generating a username is the concatenation of a few names and numbers which is getting selected using the <strong>random()</strong> function.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
-- usernames
with usernames as (
select ((select (array&#91;'john', 'jane', 'jacky'])&#91;floor(random() * 3 + 1)]) || (floor(1000+random()*1000)::text)) as username
),
</pre></div>

<p><strong>Generating Random Passwords</strong></p>

<ul>
<li>Returning md5 of random text as password.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
-- password
passwords as (
SELECT md5(random()::text) as password
),
</pre></div>

<p><strong>Generating Random Email Domain</strong></p>

<ul>
<li>Picking email domains randomly from the list.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
email_domain as (
 select (array&#91;'@gmail.com', '@yahoo.com', '@outlook.com'])&#91;floor(random() * 3 + 1)] as domain
),
</pre></div>

<p><strong>Joining to Return Single Record</strong></p>

<ul>
<li>Now that we have randomness to choose different values for different columns we can write SQL to return them as a single record each time we execute the SQL.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
account_record as (
select username, password, (username || domain) as email 
from usernames 
join passwords
on 1=1 
join email_domain 
on 1=1
)
</pre></div>

<ul>
<li>Now selecting each field from the account record.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
select username, password, email, now(), now(), 1 from account_record;
</pre></div>

<h2><strong>Convert to Postgres Function</strong></h2>

<ul>
<li>We know how to generate a single unique account record, we can convert that logic to the postgres function as below.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
CREATE OR REPLACE FUNCTION sample_account_record() 
RETURNS TABLE(username text, password text, email text, created_at timestamp, last_login timestamp, permissions_id int)
AS 
$$
-- usernames
with usernames as (
select ((select (array&#91;'john', 'jane', 'jacky'])&#91;floor(random() * 3 + 1)]) || (floor(1000+random()*1000)::text)) as username
),

-- password
passwords as (
SELECT md5(random()::text) as password
),

-- email
email_domain as (
 select (array&#91;'@gmail.com', '@yahoo.com', '@outlook.com'])&#91;floor(random() * 3 + 1)] as domain
),

account_record as (
select username, password, (username || domain) as email 
from usernames 
join passwords
on 1=1 
join email_domain 
on 1=1
)

select username, password, email, now(), now(), 1 from account_record;
$$
LANGUAGE sql;
</pre></div>

<ul>
<li>Our function <strong>sample_account_record </strong>got created in Postgres.</li>
</ul>

<figure class="wp-block-image"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*-A9kCF5w_LNddmNarG2d6w.png" alt=""/></figure>

<ul>
<li>Now that we have everything natively as postgres function, we can just query select to that function and we will get our output.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
select * from sample_account_record()
</pre></div>

<figure class="wp-block-image"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*ObQ4py_J0nB3nlPlsyn9tA.png" alt=""/></figure>

<h2><strong>Generating Record In Bulk</strong></h2>

<ul>
<li>So far we are only generating a single record, but then we can use the <strong><em>generate_series()</em></strong> function from Postgres to generate N number of records.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
select 
sample_account_record() as record
from generate_series(1,5)
</pre></div>

<ul>
<li>The output contains different sample records for account schema but its format is not what we want. We are looking for each record as a separate column instead of a single CSV record inside the bracket.</li>
</ul>

<figure class="wp-block-image"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*y8DhajU7ljNrjtzzfeCejw.png" alt=""/></figure>

<ul>
<li>Let&#8217;s do some data processing to split that into multiple columns.</li>

<li>The very first thing we can do is to replace the bracket with nothing so that we can csv record without the bracket.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
 select 
 REGEXP_REPLACE( cast(sample_account_record() as text), '&#91;\(\)]', '', 'g')  as record
 from generate_series(1,50)
</pre></div>

<ul>
<li>The bracket has been removed.</li>
</ul>

<figure class="wp-block-image"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*JdDBlwF83QBu7as44J09Kg.png" alt=""/></figure>

<ul>
<li>Once we have csv record we can split them and assign them to different columns that they belong to.</li>
</ul>

<div class="wp-block-syntaxhighlighter-code "><pre class="brush: sql; title: ; notranslate" title="">
select 
split_part(cast(record as text), ',', 1) as username,
split_part(cast(record as text), ',', 2) as password,
split_part(cast(record as text), ',', 3) as email,
split_part(cast(record as text), ',', 4) as created_at, 
split_part(cast(record as text), ',', 5) as last_login,
split_part(cast(record as text), ',', 6) as permission
from(
 select 
 REGEXP_REPLACE( cast(sample_account_record() as text), '&#91;\(\)]', '', 'g')  as record
 from generate_series(1,5)
) x
</pre></div>

<ul>
<li>Our records now contain multiple columns with different records.</li>
</ul>

<figure class="wp-block-image"><img decoding="async" src="https://cdn-images-1.medium.com/max/1600/1*z8Qsk-zcA0f-zg3y5Q2eTA.png" alt=""/></figure>

<blockquote class="wp-block-quote">
<p>One thing to know is that we should be afraid to use this logic on STG and PROD instances since <strong>generate_series and </strong>other used Postgres functions<strong> </strong>might take a lot of computing time that might impact database. We can use it for developmement and testing purposes.</p>
</blockquote>

<h2><strong>Conclusion</strong></h2>

<ul>
<li>In this article, we learned how to generate sample records using SQL in postgres.</li>

<li>We also learned how to convert our SQL logic to the Postgres function and scale it to generate bulk inserts.</li>
</ul>


</div>
