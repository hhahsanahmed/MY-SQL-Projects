/*
Question #1: 
Vibestream is designed for users to share brief updates about 
how they are feeling, as such the platform enforces a character limit of 25. 
How many posts are exactly 25 characters long?

Expected column names: char_limit_posts
*/

-- q1 solution:

select count (*) as char_limit_posts
from posts
where length(content) = 25


/*

Question #2: 
Users JamesTiger8285 and RobertMermaid7605 are Vibestream’s most active posters.

Find the difference in the number of posts these two users made on each day 
that at least one of them made a post. Return dates where the absolute value of 
the difference between posts made is greater than 2 
(i.e dates where JamesTiger8285 made at least 3 more posts than RobertMermaid7605 or vice versa).

Expected column names: post_date
*/

-- q2 solution:

with u1 as (
	select posts.post_date, count(content) as count1
  from posts
  where posts.user_id = 3
  group by posts.post_date
),
u2 as (
	select posts.post_date, count(content) as count2
  from posts
  where posts.user_id = 68 
  group by posts.post_date
),
combined as (
    select 
        COALESCE(u1.post_date, u2.post_date) as post_date, 
        COALESCE(u1.count1, 0) as count1, 
        COALESCE(u2.count2, 0) as count2
    from u1
    full outer join u2 on u1.post_date = u2.post_date
)
select post_date
from combined
where ABS(count1 - count2) > 2
order by post_date;

/*
Question #3: 
Most users have relatively low engagement and few connections. 
User WilliamEagle6815, for example, has only 2 followers.

Network Analysts would say this user has two **1-step path** relationships. 
Having 2 followers doesn’t mean WilliamEagle6815 is isolated, however. 
Through his followers, he is indirectly connected to the larger Vibestream network.  

Consider all users up to 3 steps away from this user:

- 1-step path (X → WilliamEagle6815)
- 2-step path (Y → X → WilliamEagle6815)
- 3-step path (Z → Y → X → WilliamEagle6815)

Write a query to find follower_id of all users within 4 steps of WilliamEagle6815. 
Order by follower_id and return the top 10 records.

Expected column names: follower_id

*/

-- q3 solution:

with temp1 as (
  select 
  f1.followee_id AS step0,
  f1.follower_id as step1, 
  f2.follower_id as step2, 
  f3.follower_id as step3, 
  f4.follower_id as step4
	from 
  	follows as f1
		join follows as f2 on f1.follower_id = f2.followee_id
		join follows as f3 on f2.follower_id = f3.followee_id
		join follows as f4 on f3.follower_id = f4.followee_id
	where 
  	f1.followee_id = 97
), 
temp2 as (
  select distinct step1 as follower_id  from temp1
  union 
  select distinct step2 from temp1
  union 
  select distinct step3 from temp1
  union
  select distinct step4 from temp1
)
select follower_id
from temp2
order by follower_id ASC
limit 10;

/*
Question #4: 
Return top posters for 2023-11-30 and 2023-12-01. 
A top poster is a user who has the most OR second most number of posts 
in a given day. Include the number of posts in the result and 
order the result by post_date and user_id.

Expected column names: post_date, user_id, posts

</aside>
*/

-- q4 solution:

with topposter as (
  select
  	posts.post_date, posts.user_id, count(posts.content) as post,
 		rank () over (partition by posts.post_date order by count (posts.content) DESC) as rank
  from posts
  where posts.post_date in ('2023-11-30', '2023-12-01')
  group by posts.post_date, posts.user_id
)
select
    post_date,
  user_id,
  post
from topposter
where rank <= 2
order by post_date, user_id

