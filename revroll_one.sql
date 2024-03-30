/*
Question #1: 
Installers receive performance based year end bonuses. Bonuses are calculated by taking 10% of the total value of parts installed by the installer.

Calculate the bonus earned by each installer rounded to a whole number. Sort the result by bonus in increasing order.

Expected column names: name, bonus
*/

-- q1 solution:

select
	installers.name,
  round(sum(price*0.1*quantity)) as bonus
from installers
join installs on installers.installer_id = installs.installer_id
join orders on orders.order_id = installs.order_id
join parts on orders.part_id = parts.part_id
group by installers.installer_id
order by bonus;



/*
Question #2: 
RevRoll encourages healthy competition. The company holds a “Install Derby” where installers face off to see who can change a part the fastest in a tournament style contest.

Derby points are awarded as follows:

- An installer receives three points if they win a match (i.e., Took less time to install the part).
- An installer receives one point if they draw a match (i.e., Took the same amount of time as their opponent).
- An installer receives no points if they lose a match (i.e., Took more time to install the part).

We need to calculate the scores of all installers after all matches. Return the result table ordered by `num_points` in decreasing order. 
In case of a tie, order the records by `installer_id` in increasing order.

Expected column names: `installer_id`, `name`, `num_points`

*/

-- q2 solution:

select
	installer_id,
  name,
  sum(case
    when derby_id is null then 0
    when installer_one_time = installer_two_time then 1
    else 3
  end) as num_points
from install_derby
right join installers
  on case
    when installer_one_time < installer_two_time then installers.installer_id = installer_one_id
    when installer_one_time > installer_two_time then installers.installer_id = installer_two_id
    else installers.installer_id = installer_one_id or installers.installer_id = installer_two_id
  end
group by installers.installer_id
order by num_points desc, installer_id;

/*
Question #3:

Write a query to find the fastest install time with its corresponding `derby_id` for each installer. 
In case of a tie, you should find the install with the smallest `derby_id`.

Return the result table ordered by `installer_id` in ascending order.

Expected column names: `derby_id`, `installer_id`, `install_time`
*/

-- q3 solution:

with
	times as (
    select
      derby_id,
      installer_id,
      case 
        when installer_id = installer_one_id then installer_one_time
        when installer_id = installer_two_id then installer_two_time
      end as install_time
    from installers
    join install_derby
      on installer_id = installer_one_id or installer_id = installer_two_id
    order by install_time, derby_id 
  ),
  min_times as (
    select *
    from times as t1
    where
      t1.install_time = (
        select min(t2.install_time) as min_time
        from times as t2
        where t2.installer_id = t1.installer_id
        group by t2.installer_id
      )
  )
select *
from min_times as t3
where
	t3.derby_id = (
  	select min(t4.derby_id) as min_derby
    from min_times as t4
    where t4.installer_id = t3.installer_id
    group by t4.installer_id
  )
order by installer_id;

/*
Question #4: 
Write a solution to calculate the total parts spending by customers paying for installs on each Friday of every week in November 2023. 
If there are no purchases on the Friday of a particular week, the parts total should be set to `0`.

Return the result table ordered by week of month in ascending order.

Expected column names: `november_fridays`, `parts_total`
*/

-- q4 solution:

select 
	install_date as november_fridays, 
  coalesce(sum(price*quantity), 0) as parts_total 
from (
  select
  	generate_series(
    	'2023-11-01'::date,
      '2023-12-01'::date,
      '1 day'::interval
    ) as date_series
) dates
left join installs on dates.date_series = installs.install_date
left join orders on orders.order_id = installs.order_id
left join parts on orders.part_id = parts.part_id
where extract(dow from install_date) = 5
  and extract (month from install_date) = 11
  and extract (year from install_date) = 2023
group by november_fridays;


 

