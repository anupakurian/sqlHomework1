use sakila;
select * from actor limit 10;

#1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name,
# "Joe." What is one query would you use to obtain this information?
select actor_id, first_name,last_name 
from actor 
where first_name='Joe';

#2b. Find all actors whose last name contain the letters GEN
select * from actor where last_name like '%GEN%';

#2c. Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%LI%'
order by last_name,first_name;

#2d. Using IN, display the country_id and country columns 
#of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country 
where country
IN ('Afghanistan','Bangladesh','China') ;

#3a. You want to keep a description of each actor. You don't think you will be performing 
#queries on a description, so create a column in the table actor named description and use 
#the data type BLOB (Make sure to research the type BLOB,
# as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB; 

#3b. Very quickly you realize that entering descriptions for each actor is too much effort.
# Delete the description column.
ALTER TABLE actor DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
select LASt_name,count(*)  from actor where last_name is not null group by last_name;

#4bList last names of actors and the number of actors who have that last name,
# but only for names that are shared by at least two actors
select LASt_name,count(*)  from actor 
where last_name is not null
group by last_name
having count(*) >=2
;


#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table
# as GROUCHO WILLIAMS. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
update actor set first_name='HARPO' where last_name='WILLIAMS' and first_name='GROUCHO';

#4d In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name='GROUCHO' where first_name='HARPO';

SET SQL_SAFE_UPDATES = 1;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

#6a. Use JOIN to display the first and last names, as well as the address, 
#of each staff member. Use the tables staff and address:
select a.first_name, a.last_name, b.address,b.address2 
from staff a 
left join address b
on a.address_id=b.address_id;

#6b. Use JOIN to display the total amount rung up by 
#each staff member in August of 2005. Use tables staff and payment.
select a.staff_id,a.first_name,a.last_name , b.customer_id,  b.payment_date,sum(b.amount)
from staff a 
inner join payment b
on a.staff_id=b.customer_id
where month(b.payment_date)='08'
group by a.staff_id,a.first_name,a.last_name , b.customer_id,  b.payment_date
;

#6c. List each film and the number of actors who are listed for that film.
# Use tables film_actor and film. Use inner join.

select b.title,count(a.film_id) as noOfActors  from film_actor a 
inner join film b
on a.film_id = b.film_id
group by b.title
order by b.title;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(a.film_id) as noofCopies from inventory a  
inner join film b
on a.film_id=b.film_id where title like 'Hunchback%'
;
#6 copies

#6e. Using the tables payment and customer and the JOIN command, list the
# total paid by each customer. List the customers alphabetically by last name:

select a.customer_id, b.first_name, b.last_name, sum(a.amount) 
from payment a 
inner join customer b 
on a.customer_id=b.customer_id
group by a.customer_id
order by b.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared
# in popularity. Use subqueries to display
# the titles of movies starting with the letters K and Q whose language is English.

select a.title from film a where a.title like 'K%' or  a.title like 'Q%' and a.language_id in  
(select b.language_id from language b where name='English');

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor where actor_id in 
(select actor_id from film_actor where 
film_id in (select film_id from film where title= 'Alone Trip'));


#7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
#email addresses of all Canadian customers. Use joins to retrieve this information.
select a.first_name,a.last_name,a.email,d.country from customer a
inner join address b
inner join city c
inner join country d
on a.address_id = b.address_id
and b.city_id = c.city_id
and c.country_id= d.country_id
where d.country= 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family
# movies for a promotion. Identify all movies categorized as family films.

select a.title,c.name from film a 
inner join film_category b
inner join category c
on a.film_id=b.film_id
and b.category_id=c.category_id
where c.name='Family';

#7e. Display the most frequently rented movies in descending order.
select x.title, count(*) as cnt from  
(select b.inventory_id,b.film_id,c.title
from rental a 
inner join inventory b
inner join film c
on a.inventory_id =b.inventory_id
and b.film_id=c.film_id) x
group by x.title
order by cnt desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
select b.store_id,sum(a.amount) as TotalAmt from payment a 
inner join staff b
on a.staff_id=b.staff_id
group by b.store_id
order by TotalAmt desc
;

#7g. Write a query to display for each store its store ID, city, and country.
select a.store_id, b.city_id,c.city,d.country from store a
inner join address b
inner join city c
inner join country d
on a.address_id=b.address_id
and b.city_id=c.city_id
and c.country_id=d.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select a.name, sum(e.amount) as grossAmt from category a inner join film_category b
inner join inventory c
inner join rental  d
inner join payment e
on a.category_id =b.category_id
and b.film_id=c.film_id
and d.inventory_id=c.inventory_id
and d.rental_id=e.rental_id
group by a.name order by grossAmt desc
;


#8a. In your new role as an executive, you would like to have an easy way of viewing the 
#Top five genres by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as (
select a.name, sum(e.amount) as grossAmt from category a inner join film_category b
inner join inventory c
inner join rental  d
inner join payment e
on a.category_id =b.category_id
and b.film_id=c.film_id
and d.inventory_id=c.inventory_id
and d.rental_id=e.rental_id
group by a.name order by grossAmt desc);
#8b. How would you display the view that you created in 8a?

select * from top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;
